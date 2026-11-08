local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local AnalyticsService = game:GetService("AnalyticsService")

local PROFILE_STORE = DataStoreService:GetDataStore("KC_PlayerProfiles_v1")
local PROFILE_VERSION = 1
local SAVE_RETRIES = 3
local AUTOSAVE_SECONDS = 90
local DAILY_REWARD = 100
local XP_PER_LEVEL = 500
local DEFAULT = {Version=PROFILE_VERSION, XP=0, Level=1, Coins=0, Wins=0, Losses=0, Matches=0, Captures=0, Kills=0, BestMatchSeconds=0, CurrentStreak=0, BestStreak=0, LastDailyUtc="", OwnedCosmetics={"Banner_Default"}, EquippedBanner="Banner_Default", Achievements={}}
local profiles, dirty, saving = {}, {}, {}

local remotes = ReplicatedStorage:FindFirstChild("Stage5Remotes")
if remotes then remotes:Destroy() end
remotes = Instance.new("Folder"); remotes.Name="Stage5Remotes"; remotes.Parent=ReplicatedStorage
local requestProfile=Instance.new("RemoteFunction"); requestProfile.Name="RequestProfile"; requestProfile.Parent=remotes
local profileChanged=Instance.new("RemoteEvent"); profileChanged.Name="ProfileChanged"; profileChanged.Parent=remotes
local profileAction=Instance.new("RemoteEvent"); profileAction.Name="ProfileAction"; profileAction.Parent=remotes

local function cloneDefault()
 local r={}
 for k,v in pairs(DEFAULT) do
  if type(v)=="table" then local t={}; for i,x in ipairs(v) do t[i]=x end; r[k]=t else r[k]=v end
 end
 return r
end
local function normalize(data)
 local r=cloneDefault(); if type(data)~="table" then return r end
 for k,v in pairs(r) do if data[k]~=nil and type(data[k])==type(v) then r[k]=data[k] end end
 if type(data.OwnedCosmetics)=="table" then r.OwnedCosmetics=data.OwnedCosmetics end
 if type(data.Achievements)=="table" then r.Achievements=data.Achievements end
 r.Version=PROFILE_VERSION; return r
end
local function key(p) return "u_"..tostring(p.UserId) end
local function utcDay() return os.date("!%Y-%m-%d") end
local function levelForXP(xp) return math.max(1,math.floor(xp/XP_PER_LEVEL)+1) end
local function analytics(p,name,value) pcall(function() AnalyticsService:LogCustomEvent(p,name,value or 1) end) end
local function publicProfile(d)
 local a={}; for id,v in pairs(d.Achievements or {}) do if v then table.insert(a,id) end end; table.sort(a)
 return {XP=d.XP,Level=d.Level,Coins=d.Coins,Wins=d.Wins,Losses=d.Losses,Matches=d.Matches,Captures=d.Captures,Kills=d.Kills,CurrentStreak=d.CurrentStreak,BestStreak=d.BestStreak,EquippedBanner=d.EquippedBanner,OwnedCosmetics=d.OwnedCosmetics,Achievements=a,XPIntoLevel=d.XP%XP_PER_LEVEL,XPToNext=XP_PER_LEVEL-(d.XP%XP_PER_LEVEL),CanClaimDaily=d.LastDailyUtc~=utcDay()}
end
local function push(p) if profiles[p] then profileChanged:FireClient(p,publicProfile(profiles[p])) end end
local function dirtyMark(p) dirty[p]=true; push(p) end
local function awardXP(p,amount,eventName)
 local d=profiles[p]; if not d then return end
 local old=d.Level; d.XP=math.max(0,d.XP+math.max(0,amount)); d.Level=levelForXP(d.XP);
 if d.Level>old then d.Coins+=50*(d.Level-old); analytics(p,"KC_Level_Up",d.Level) end
 dirtyMark(p); analytics(p,"KC_XP_Awarded",amount)
end
local function unlock(p,id)
 local d=profiles[p]; if not d or d.Achievements[id] then return end
 d.Achievements[id]=true; d.Coins+=75; dirtyMark(p); analytics(p,"KC_Achievement",1)
end
local function save(p,reason)
 local d=profiles[p]; if not d or saving[p] then return false end; saving[p]=true; local snapshot=normalize(d); local ok=false
 for attempt=1,SAVE_RETRIES do
  local success=pcall(function() PROFILE_STORE:UpdateAsync(key(p),function(old) local m=normalize(old); for k,v in pairs(snapshot) do m[k]=v end; m.Version=PROFILE_VERSION; return m end) end)
  if success then ok=true; break end; task.wait(attempt)
 end
 if ok then dirty[p]=nil else warn("[KingdomsConquest][Stage5] Profile save failed",p.UserId,reason or "unknown") end
 saving[p]=nil; return ok
end
local function load(p)
 local raw; local ok=pcall(function() raw=PROFILE_STORE:GetAsync(key(p)) end); profiles[p]=normalize(ok and raw or nil); dirty[p]=false; p:SetAttribute("ProfileLoaded",true); p:SetAttribute("Level",profiles[p].Level); push(p)
 if not ok then warn("[KingdomsConquest][Stage5] Profile load failed; safe defaults",p.UserId) end
end
local function claimDaily(p)
 local d=profiles[p]; if not d or d.LastDailyUtc==utcDay() then return false end
 d.LastDailyUtc=utcDay(); d.Coins+=DAILY_REWARD; awardXP(p,50,"daily"); dirtyMark(p); analytics(p,"KC_DailyReward",DAILY_REWARD); return true
end
local function equipBanner(p,bannerId)
 local d=profiles[p]; if not d or type(bannerId)~="string" then return false end
 for _,owned in ipairs(d.OwnedCosmetics) do if owned==bannerId then d.EquippedBanner=bannerId; dirtyMark(p); return true end end
 return false
end
requestProfile.OnServerInvoke=function(p) return profiles[p] and publicProfile(profiles[p]) or nil end
profileAction.OnServerEvent:Connect(function(p,action,payload)
 if type(action)~="string" then return end
 if action=="ClaimDaily" then claimDaily(p) elseif action=="EquipBanner" then equipBanner(p,payload and payload.BannerId) end
end)

local captureEvent=ReplicatedStorage:WaitForChild("KingdomsProvinceCaptured",10)
if captureEvent then captureEvent.Event:Connect(function(_,teamId)
 for _,p in ipairs(Players:GetPlayers()) do if p:GetAttribute("TeamId")==teamId and profiles[p] then local d=profiles[p]; d.Captures+=1; awardXP(p,100,"capture"); if d.Captures==1 then unlock(p,"First_Capture") end; if d.Captures>=10 then unlock(p,"Veteran_Capturer") end end end
end) end
local resultEvent=ReplicatedStorage:WaitForChild("KingdomsMatchResult",10)
if resultEvent then resultEvent.Event:Connect(function(winner,_,duration)
 for _,p in ipairs(Players:GetPlayers()) do
  local d=profiles[p]; if d then local team=p:GetAttribute("TeamId") or 0; d.Matches+=1
   if team~=0 and team==winner then d.Wins+=1; d.CurrentStreak+=1; d.BestStreak=math.max(d.BestStreak,d.CurrentStreak); d.Coins+=250; awardXP(p,300,"win"); if d.Wins==1 then unlock(p,"First_Victory") end; if d.Wins>=10 then unlock(p,"Warlord") end
   else d.Losses+=1; d.CurrentStreak=0; awardXP(p,100,"match") end
   if duration and duration>0 and (d.BestMatchSeconds==0 or duration<d.BestMatchSeconds) then d.BestMatchSeconds=duration end
   dirtyMark(p); analytics(p,"KC_Match_Complete",team==winner and 1 or 0)
  end
 end
end) end

Players.PlayerAdded:Connect(function(p) load(p); task.defer(function() if profiles[p] then claimDaily(p); push(p) end end) end)
Players.PlayerRemoving:Connect(function(p) save(p,"PlayerRemoving"); profiles[p]=nil; dirty[p]=nil; saving[p]=nil end)
task.spawn(function() while true do task.wait(AUTOSAVE_SECONDS); for p in pairs(profiles) do if dirty[p] then save(p,"Autosave") end end end end)
game:BindToClose(function() for p in pairs(profiles) do task.spawn(function() save(p,"Shutdown") end) end; local deadline=os.clock()+25; while os.clock()<deadline do local busy=false; for _ in pairs(saving) do busy=true break end; if not busy then break end; task.wait(.1) end end)
print("[KingdomsConquest] Stage 5 progression/profile initialized.")