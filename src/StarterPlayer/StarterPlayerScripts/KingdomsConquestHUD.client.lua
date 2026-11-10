-- Kingdoms Conquest — Stage 10 Unified Responsive HUD
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local Workspace=game:GetService("Workspace")
local player=Players.LocalPlayer
if workspace:GetAttribute("KC_RuntimeReady") ~= true then
	workspace:GetAttributeChangedSignal("KC_RuntimeReady"):Wait()
end
local remotes=ReplicatedStorage:WaitForChild("KingdomsRemotes", 15)
if not remotes then return end
local command=remotes:WaitForChild("Command")
local stateRemote=remotes:WaitForChild("State")
local requestState=remotes:WaitForChild("RequestState")
local feedbackRemote=remotes:WaitForChild("Feedback")
local UITheme=require(ReplicatedStorage.Shared.UITheme)
local Config=require(ReplicatedStorage.Shared.Config)

local stage4Remotes = ReplicatedStorage:WaitForChild("Stage4Remotes", 15)
if not stage4Remotes then return end
local stage4StateRemote = stage4Remotes:WaitForChild("State", 15)
if not stage4StateRemote then return end

local lang="en"
local state={}
local selectedArmy=0
local mode="Move"
local selectedCastle=nil
local mobile=UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local root=Instance.new("ScreenGui")
root.Name="KingdomsStage10HUD"
root.ResetOnSpawn=false
root.IgnoreGuiInset=true
root.DisplayOrder=100
root.Parent=player:WaitForChild("PlayerGui")
root.Enabled = false

local function frame(parent,pos,size,color,trans)
 local x=Instance.new("Frame"); x.Position=pos; x.Size=size; x.BackgroundColor3=color; x.BackgroundTransparency=trans or 0; x.BorderSizePixel=0; x.Parent=parent
 Instance.new("UICorner",x).CornerRadius=UDim.new(0,10)
 return x
end
local function text(parent,value,pos,size,font,color)
 local x=Instance.new("TextLabel"); x.BackgroundTransparency=1; x.Position=pos; x.Size=size; x.Font=font or Enum.Font.Gotham; x.Text=value; x.TextColor3=color or UITheme.Colors.White; x.TextScaled=true; x.Parent=parent; return x
end
local function btn(parent,value,pos,size,callback)
 local x=Instance.new("TextButton")
 x.Position=pos; x.Size=size; x.Text=value; x.Font=Enum.Font.GothamBold
 x.TextScaled=true; x.TextWrapped=true; x.TextColor3=UITheme.Colors.White
 x.BackgroundColor3=UITheme.Colors.Surface3; x.BorderSizePixel=0; x.AutoButtonColor=true
 x.Parent=parent
 Instance.new("UICorner",x).CornerRadius=UDim.new(0,8)
 x.Activated:Connect(callback)
 return x
end

local function labeledButton(parent, icon, title, subtitle, pos, size, callback)
 local b=Instance.new("TextButton")
 b.Position=pos; b.Size=size; b.Text=""; b.BackgroundColor3=UITheme.Colors.Surface3
 b.BorderSizePixel=0; b.AutoButtonColor=true; b.Parent=parent
 Instance.new("UICorner",b).CornerRadius=UDim.new(0,9)

 local iconLabel=Instance.new("TextLabel")
 iconLabel.BackgroundTransparency=1; iconLabel.Position=UDim2.fromScale(.03,.12); iconLabel.Size=UDim2.fromScale(.18,.70)
 iconLabel.Font=Enum.Font.GothamBold; iconLabel.Text=icon; iconLabel.TextScaled=true
 iconLabel.TextColor3=UITheme.Colors.Brass; iconLabel.Parent=b

 local titleLabel=Instance.new("TextLabel")
 titleLabel.BackgroundTransparency=1; titleLabel.Position=UDim2.fromScale(.23,.08); titleLabel.Size=UDim2.fromScale(.73,.43)
 titleLabel.Font=Enum.Font.GothamBold; titleLabel.Text=title; titleLabel.TextScaled=true
 titleLabel.TextColor3=UITheme.Colors.White; titleLabel.Parent=b

 local subLabel=Instance.new("TextLabel")
 subLabel.BackgroundTransparency=1; subLabel.Position=UDim2.fromScale(.23,.51); subLabel.Size=UDim2.fromScale(.73,.34)
 subLabel.Font=Enum.Font.Gotham; subLabel.Text=subtitle; subLabel.TextScaled=true
 subLabel.TextColor3=UITheme.Colors.Muted; subLabel.Parent=b

 b.Activated:Connect(callback)
 return b
end

local top=frame(root,UDim2.fromScale(.03,.025),UDim2.fromScale(.94,.075),UITheme.Colors.Surface,.06)
local teamText=text(top,"",UDim2.fromScale(.025,.12),UDim2.fromScale(.27,.76),Enum.Font.GothamBold,UITheme.Colors.Parchment)
local objective=text(top,"",UDim2.fromScale(.30,.12),UDim2.fromScale(.42,.76),Enum.Font.GothamMedium,UITheme.Colors.Muted)
local supply=text(top,"",UDim2.fromScale(.73,.12),UDim2.fromScale(.24,.76),Enum.Font.GothamBold,UITheme.Colors.Brass)
supply.TextXAlignment=Enum.TextXAlignment.Right

local context=frame(root,UDim2.fromScale(.03,.115),UDim2.fromScale(.27,.115),UITheme.Colors.Surface,.04)
local contextTitle=text(context,UITheme.T(lang,"army"),UDim2.fromScale(.06,.08),UDim2.fromScale(.88,.25),Enum.Font.GothamBold,UITheme.Colors.Parchment)
local contextBody=text(context,"SELECT AN ARMY\nThen choose a command below.",UDim2.fromScale(.06,.35),UDim2.fromScale(.88,.53),Enum.Font.Gotham,UITheme.Colors.Muted)
contextBody.TextWrapped=true

local modeBar=frame(root,UDim2.fromScale(.27,.845),UDim2.fromScale(.46,.13),UITheme.Colors.Surface,.04)
local modeTitle=text(modeBar,"COMMAND  •  CLICK A MODE, THEN CLICK THE WORLD",UDim2.fromScale(.03,.04),UDim2.fromScale(.94,.24),Enum.Font.GothamBold,UITheme.Colors.Parchment)
local announce

local buttons={}
local modes={{id="Move",icon="➜",hint="Move to clicked ground"},{id="Attack",icon="⚔",hint="Attack enemy army"},{id="Hold",icon="■",hint="Stop and hold position"}}
for i,entry in ipairs(modes) do
 buttons[entry.id]=labeledButton(modeBar,entry.icon,UITheme.T(lang,entry.id:lower()),entry.hint,
  UDim2.fromScale(.025+(i-1)*.325,.31),UDim2.fromScale(.30,.60),function()
   mode=entry.id
   for n,b in pairs(buttons) do b.BackgroundColor3=(n==mode) and UITheme.Colors.Brass or UITheme.Colors.Surface3 end
   contextBody.Text=selectedArmy==0 and UITheme.T(lang,"selectArmy") or (UITheme.T(lang,mode:lower()).." • "..(entry.hint))
  end)
end
for n,b in pairs(buttons) do b.BackgroundColor3=(n==mode) and UITheme.Colors.Brass or UITheme.Colors.Surface3 end

local formationBar=frame(root,UDim2.fromScale(.27,.775),UDim2.fromScale(.46,.06),UITheme.Colors.Surface,.05)
text(formationBar,"FORMATION",UDim2.fromScale(.02,.12),UDim2.fromScale(.17,.76),Enum.Font.GothamBold,UITheme.Colors.Parchment)
for i,f in ipairs({"Line","Wedge","Spread"}) do
 btn(formationBar,UITheme.T(lang,f:lower()),UDim2.fromScale(.20+(i-1)*.265,.12),UDim2.fromScale(.24,.76),function()
  if selectedArmy~=0 then
   command:FireServer("Formation",{ArmyId=selectedArmy,Formation=f})
   announce("FORMATION • "..f)
  else
   announce("SELECT AN ARMY FIRST")
  end
 end)
end

local recruitBar=frame(root,UDim2.fromScale(.69,.60),UDim2.fromScale(.28,.16),UITheme.Colors.Surface,.04)
text(recruitBar,"RECRUIT  •  PAY WITH SUPPLIES",UDim2.fromScale(.04,.04),UDim2.fromScale(.92,.20),Enum.Font.GothamBold,UITheme.Colors.Parchment)
local armyDefs={
 {id="Spearmen",icon="⚔",gold=Config.ArmyTypes.Spearmen.GoldCostPerSoldier,sup=Config.ArmyTypes.Spearmen.SupplyCostPerSoldier,sub="per soldier"},
 {id="Archers",icon="➶",gold=Config.ArmyTypes.Archers.GoldCostPerSoldier,sup=Config.ArmyTypes.Archers.SupplyCostPerSoldier,sub="per soldier"},
 {id="Cavalry",icon="♞",gold=Config.ArmyTypes.Cavalry.GoldCostPerSoldier,sup=Config.ArmyTypes.Cavalry.SupplyCostPerSoldier,sub="per soldier"},
}
for i,armyDef in ipairs(armyDefs) do
 labeledButton(recruitBar,armyDef.icon,armyDef.id:upper(),tostring(armyDef.gold).." G + "..tostring(armyDef.sup).." S • "..armyDef.sub,
  UDim2.fromScale(.03+(i-1)*.32,.29),UDim2.fromScale(.30,.61),function()
   local selected = state.Armies and state.Armies[tostring(selectedArmy)]
   if selected and selected.Type == armyDef.id then
    command:FireServer("RecruitSoldier",{ArmyId=selectedArmy})
   else
    command:FireServer("RequestArmy",{ArmyType=armyDef.id})
   end
  end)
end

local info=frame(root,UDim2.fromScale(.03,.62),UDim2.fromScale(.22,.18),UITheme.Colors.Surface,.04)
text(info,"SELECT AN ARMY\n1) Recruit above\n2) Click your army\n3) Choose Move / Attack / Hold\n4) Click the map",UDim2.fromScale(.08,.08),UDim2.fromScale(.84,.84),Enum.Font.GothamMedium,UITheme.Colors.Muted).Name="Hint"

local mobileBar=nil
if mobile then
 modeBar.Visible=false
 formationBar.Visible=false
 recruitBar.Visible=false
 info.Visible=false
 context.Visible=false
 mobileBar=frame(root,UDim2.fromScale(.03,.76),UDim2.fromScale(.94,.21),UITheme.Colors.Surface,.02)
 local actionWheel=btn(mobileBar,"⚔",UDim2.fromScale(.02,.12),UDim2.fromScale(.19,.72),function()
  mode=mode=="Attack" and "Move" or "Attack"
 end)
 for i,m in ipairs({"Move","Attack","Hold"}) do
  local b=btn(mobileBar,UITheme.T(lang,m:lower()),UDim2.fromScale(.03+(i-1)*.24,.12),UDim2.fromScale(.21,.34),function() mode=m end)
 end
 local recruitTypes={{id="Spearmen",icon="⚔"},{id="Archers",icon="➶"},{id="Cavalry",icon="♞"}}
 for i,a in ipairs(recruitTypes) do
  btn(mobileBar,a.icon.." "..a.id,UDim2.fromScale(.03+(i-1)*.32,.53),UDim2.fromScale(.29,.34),function()
   command:FireServer("RequestArmy",{ArmyType=a.id})
  end)
 end
end

local castlePanel=frame(root,UDim2.fromScale(.69,.115),UDim2.fromScale(.28,.23),UITheme.Colors.Surface,.03)
castlePanel.Visible=false
local castleTitle=text(castlePanel,"",UDim2.fromScale(.06,.08),UDim2.fromScale(.88,.22),Enum.Font.GothamBold,UITheme.Colors.Parchment)
local castleBody=text(castlePanel,"",UDim2.fromScale(.06,.33),UDim2.fromScale(.88,.58),Enum.Font.Gotham,UITheme.Colors.Muted)
castleBody.TextWrapped=true

local toast=frame(root,UDim2.fromScale(.35,.12),UDim2.fromScale(.30,.06),UITheme.Colors.Surface,.04)
toast.Visible=false
local toastText=text(toast,"",UDim2.fromScale(.05,.05),UDim2.fromScale(.90,.9),Enum.Font.GothamBold,UITheme.Colors.Parchment)

announce = function(message)
 toastText.Text=message; toast.Visible=true
 task.delay(2.2,function() if toastText.Text==message then toast.Visible=false end end)
end

local function raycast()
 local p=UserInputService:GetMouseLocation()
 local cam=Workspace.CurrentCamera
 if not cam then return end
 local ray=cam:ViewportPointToRay(p.X,p.Y)
 local params=RaycastParams.new()
 params.FilterType=Enum.RaycastFilterType.Exclude
 params.FilterDescendantsInstances=player.Character and {player.Character} or {}
 return Workspace:Raycast(ray.Origin,ray.Direction*700,params)
end
local function attributeUp(instance,name)
 local x=instance
 while x and x~=Workspace do
  local v=x:GetAttribute(name)
  if v~=nil then return v end
  x=x.Parent
 end
end

local function clickWorld()
 local hit=raycast(); if not hit then return end
 local army=attributeUp(hit.Instance,"ArmyId")
 local province=attributeUp(hit.Instance,"Province")
 if army then
  local targetId=tonumber(army) or 0
  if mode=="Attack" and selectedArmy~=0 and targetId~=selectedArmy then
   command:FireServer("Attack",{ArmyId=selectedArmy,TargetArmyId=targetId})
   announce("ATTACK ORDER • ARMY #"..tostring(targetId))
  else
   selectedArmy=targetId
   command:FireServer("SelectArmy",{ArmyId=selectedArmy})
   contextTitle.Text=UITheme.T(lang,"army").." #"..tostring(selectedArmy)
   contextBody.Text=UITheme.T(lang,"selectArmy").." • "..UITheme.T(lang,mode:lower())
   announce("ARMY #"..tostring(selectedArmy).." SELECTED")
  end
  return
 end
 if province then
  selectedCastle=province
  castlePanel.Visible=true
  castleTitle.Text=tostring(province)
  local castleState = state.Castles and state.Castles[province]
  if castleState then
   castleBody.Text=string.format(
    "%s • %s\nOWNER: %s\nSTATE: %s\nGARRISON: %d/%d\nCAPTURE: %d%%\n%s",
    tostring(province),
    tostring(castleState.Tier or "REGIONAL"),
    tostring(castleState.Owner or 0),
    tostring(castleState.State or "Safe"):upper(),
    tonumber(castleState.Garrison) or 0,
    tonumber(castleState.MaxGarrison) or 0,
    math.floor((tonumber(castleState.CaptureProgress) or 0) / math.max(1, (tonumber(state.MatchCaptureSeconds) or 10)) * 100),
    (castleState.StabilizationRemaining or 0) > 0 and "STABILIZING" or "ARMY AT GATE TO ASSAULT"
   )
  else
   castleBody.Text=UITheme.T(lang,"castle").." • "..UITheme.T(lang,mode:lower()).."\n"..UITheme.T(lang,"territory")..": "..tostring((state.Provinces and state.Provinces[province] and state.Provinces[province].Owner) or 0)
  end
  if selectedArmy~=0 then
   if mode=="Move" then
    command:FireServer("Move",{ArmyId=selectedArmy,Position=hit.Position})
    announce("MOVE ORDER • "..tostring(province))
   elseif mode=="Hold" then
    command:FireServer("Hold",{ArmyId=selectedArmy})
    announce("HOLD ORDER")
   elseif mode=="Attack" then
    announce("ATTACK MODE • CLICK AN ENEMY ARMY")
   end
  else
   announce("CASTLE • "..tostring(province).." • WALK TO A GATE TO CAPTURE")
  end
  return
 end
 if selectedArmy~=0 and mode=="Move" then command:FireServer("Move",{ArmyId=selectedArmy,Position=hit.Position}) end
end

UserInputService.InputBegan:Connect(function(input,processed)
 if processed then return end
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then clickWorld() end
 if input.KeyCode==Enum.KeyCode.M then mode="Move" end
 if input.KeyCode==Enum.KeyCode.A then mode="Attack" end
 if input.KeyCode==Enum.KeyCode.H then mode="Hold" end
 if input.KeyCode==Enum.KeyCode.One and selectedArmy~=0 then command:FireServer("Formation",{ArmyId=selectedArmy,Formation="Line"}) end
 if input.KeyCode==Enum.KeyCode.Two and selectedArmy~=0 then command:FireServer("Formation",{ArmyId=selectedArmy,Formation="Wedge"}) end
 if input.KeyCode==Enum.KeyCode.Three and selectedArmy~=0 then command:FireServer("Formation",{ArmyId=selectedArmy,Formation="Spread"}) end
end)

feedbackRemote.OnClientEvent:Connect(function(kind,payload)
 if kind=="ARMY_CREATED" then
  selectedArmy=tonumber(payload.ArmyId) or selectedArmy
  contextTitle.Text="ARMY #"..tostring(selectedArmy).." • "..tostring(payload.ArmyType)
  contextBody.Text="Army created and selected.\nMove mode is ready."
  announce(string.format("ARMY READY • %d SOLDIERS • -%dG -%dS", tonumber(payload.SoldierCount) or 0, math.floor(payload.CostGold or 0), math.floor(payload.CostSupplies or 0)))
 elseif kind=="SOLDIER_RECRUITED" then
  announce(string.format("+1 SOLDIER • %s • %d TOTAL • -%dG -%dS", tostring(payload.ArmyType), tonumber(payload.SoldierCount) or 0, math.floor(payload.CostGold or 0), math.floor(payload.CostSupplies or 0)))
 elseif kind=="ARMY_FAILED" then
  announce("RECRUIT FAILED • "..tostring(payload.Reason))
 elseif kind=="COMMAND_REJECTED" then
  announce("COMMAND REJECTED • "..tostring(payload.Reason))
 end
end)

local function render(s)
 state=s or state
 selectedArmy=tonumber(s.SelectedArmy) or selectedArmy
 local team=s.Team or 0
 teamText.Text=UITheme.TeamName(team,lang).."  •  "..UITheme.T(lang,"territory").." "..tostring(s.Owned or 0).."/"..tostring(s.TotalProvinces or 0)
 supply.Text=string.format("GOLD %d • SUP %d • IN %s/m • UP %s/m", math.floor(s.Gold or 0), math.floor(s.Supplies or 0), tostring(math.floor((s.Economy and s.Economy.GoldIncomePerMinute) or 0)), tostring(math.floor((s.Economy and s.Economy.UpkeepGoldPerMinute) or 0)))
 objective.Text=UITheme.T(lang,"objective").."  •  "..tostring(s.MapId or "WORLD").."  •  "..tostring(s.TeamCount or 2).." TEAMS"
 local hint=info:FindFirstChild("Hint")
 if hint then
 if selectedArmy==0 then
  hint.Text="SELECT AN ARMY\nRecruit with the buttons above."
 else
  hint.Text="ARMY #"..tostring(selectedArmy).."\n"..mode.." selected • click the world"
 end
end
if selectedArmy~=0 then
 local selectedState = s.Armies and s.Armies[tostring(selectedArmy)]
 if selectedState then
  contextTitle.Text=string.format("ARMY #%d • %s", selectedArmy, tostring(selectedState.Type):upper())
  contextBody.Text=string.format(
   "%d soldiers • %d/%d HP\nMORALE %d • FATIGUE %d\nPOWER %.0f • %s • %s\nECONOMY: %s\nClick the world to issue orders.",
   tonumber(selectedState.SoldierCount) or 0,
   math.floor(selectedState.Health or 0),
   math.floor(selectedState.MaxHealth or 0),
   math.floor(selectedState.Morale or 0),
   math.floor(selectedState.Fatigue or 0),
   tonumber(selectedState.Power) or 0,
   tostring(selectedState.Formation or "Line"),
   tostring(selectedState.Order or "Hold"),
   ((s.Economy and s.Economy.EconomyStrain) and "UPKEEP STRAIN" or ((s.Economy and s.Economy.Comeback) and "COMEBACK BONUS" or "STABLE"))
  )
 else
  selectedArmy=0
  contextTitle.Text=UITheme.T(lang,"army")
  contextBody.Text="ARMY LOST OR DISBANDED\nRecruit a new army."
 end
end
 if selectedCastle and state.Castles and state.Castles[selectedCastle] then
  local castleState = state.Castles[selectedCastle]
  castlePanel.Visible = true
  castleTitle.Text = tostring(selectedCastle)
  castleBody.Text = string.format(
   "%s • %s\nOWNER: %s\nSTATE: %s\nGARRISON: %d/%d\nCAPTURE: %d%%",
   tostring(selectedCastle),
   tostring(castleState.Tier or "REGIONAL"),
   tostring(castleState.Owner or 0),
   tostring(castleState.State or "Safe"):upper(),
   tonumber(castleState.Garrison) or 0,
   tonumber(castleState.MaxGarrison) or 0,
   math.floor((tonumber(castleState.CaptureProgress) or 0) / math.max(1, tonumber(s.MatchCaptureSeconds) or 10) * 100)
  )
 end
 if s.MatchOver then
  announce((s.Winner==team and UITheme.T(lang,"victory") or UITheme.T(lang,"defeat")).."  •  "..tostring(s.MapId or "WORLD"))
 end
end
stateRemote.OnClientEvent:Connect(render)

stage4StateRemote.OnClientEvent:Connect(function(s)
 if type(s) ~= "table" then return end
 root.Enabled = s.MatchActive == true
end)

local ok,s=pcall(function() return requestState:InvokeServer() end)
if ok and s then
 render(s)
 root.Enabled = Workspace:GetAttribute("MatchActive") == true
end

Workspace:GetAttributeChangedSignal("MatchActive"):Connect(function()
 root.Enabled = Workspace:GetAttribute("MatchActive") == true
end)
