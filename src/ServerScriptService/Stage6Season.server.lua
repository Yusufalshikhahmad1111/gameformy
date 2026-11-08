local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage.Shared.Config)

local season=Config.Seasons[1]
local remotes=ReplicatedStorage:FindFirstChild("Stage6SeasonRemotes")
if remotes then remotes:Destroy() end
remotes=Instance.new("Folder")
remotes.Name="Stage6SeasonRemotes"
remotes.Parent=ReplicatedStorage

local request=Instance.new("RemoteFunction")
request.Name="RequestSeason"
request.Parent=remotes
local changed=Instance.new("RemoteEvent")
changed.Name="SeasonChanged"
changed.Parent=remotes

local seasonXP={}
local function current()
 if not season then return nil end
 local now=os.time()
 local finish=season.StartUnix+season.DurationSeconds
 return {Id=season.Id,DisplayName=season.DisplayName,Theme=season.Theme,StartUnix=season.StartUnix,EndUnix=finish,Active=now>=season.StartUnix and now<finish}
end
local function push(p)
 local s=current()
 if s then changed:FireClient(p,{Season=s,XP=seasonXP[p] or 0}) end
end
local function award(p,amount)
 if not p or not p:IsDescendantOf(Players) then return end
 local s=current()
 if not s or not s.Active then return end
 seasonXP[p]=(seasonXP[p] or 0)+math.max(0,amount)
 p:SetAttribute("SeasonXP",seasonXP[p])
 push(p)
end
request.OnServerInvoke=function(p)
 local s=current()
 return s and {Season=s,XP=seasonXP[p] or 0} or nil
end
local capture=ReplicatedStorage:WaitForChild("KingdomsProvinceCaptured",10)
if capture then capture.Event:Connect(function(_,teamId)
 for _,p in ipairs(Players:GetPlayers()) do
  if p:GetAttribute("TeamId")==teamId then award(p,season.XPPerCapture or 35) end
 end
end) end
local result=ReplicatedStorage:WaitForChild("KingdomsMatchResult",10)
if result then result.Event:Connect(function(winner)
 for _,p in ipairs(Players:GetPlayers()) do
  if p:GetAttribute("TeamId")==winner then award(p,season.XPPerWin or 100) end
 end
end) end
Players.PlayerAdded:Connect(function(p)
 seasonXP[p]=0
 task.defer(function() push(p) end)
end)
Players.PlayerRemoving:Connect(function(p) seasonXP[p]=nil end)
print("[KingdomsConquest] Stage 6 seasonal content initialized.")
