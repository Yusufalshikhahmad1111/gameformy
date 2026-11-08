-- Kingdoms Conquest — Stage 10 Unified Responsive HUD
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local Workspace=game:GetService("Workspace")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("KingdomsRemotes")
local command=remotes:WaitForChild("Command")
local stateRemote=remotes:WaitForChild("State")
local requestState=remotes:WaitForChild("RequestState")
local UITheme=require(ReplicatedStorage.Shared.UITheme)

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

local function frame(parent,pos,size,color,trans)
 local x=Instance.new("Frame"); x.Position=pos; x.Size=size; x.BackgroundColor3=color; x.BackgroundTransparency=trans or 0; x.BorderSizePixel=0; x.Parent=parent
 Instance.new("UICorner",x).CornerRadius=UDim.new(0,10)
 return x
end
local function text(parent,value,pos,size,font,color)
 local x=Instance.new("TextLabel"); x.BackgroundTransparency=1; x.Position=pos; x.Size=size; x.Font=font or Enum.Font.Gotham; x.Text=value; x.TextColor3=color or UITheme.Colors.White; x.TextScaled=true; x.Parent=parent; return x
end
local function btn(parent,value,pos,size,callback)
 local x=Instance.new("TextButton"); x.Position=pos; x.Size=size; x.Text=value; x.Font=Enum.Font.GothamBold; x.TextScaled=true; x.TextColor3=UITheme.Colors.White; x.BackgroundColor3=UITheme.Colors.Surface3; x.BorderSizePixel=0; x.AutoButtonColor=true; x.Parent=parent
 Instance.new("UICorner",x).CornerRadius=UDim.new(0,8)
 x.Activated:Connect(callback)
 return x
end

local top=frame(root,UDim2.fromScale(.03,.025),UDim2.fromScale(.94,.075),UITheme.Colors.Surface,.06)
local teamText=text(top,"",UDim2.fromScale(.025,.12),UDim2.fromScale(.27,.76),Enum.Font.GothamBold,UITheme.Colors.Parchment)
local objective=text(top,"",UDim2.fromScale(.30,.12),UDim2.fromScale(.42,.76),Enum.Font.GothamMedium,UITheme.Colors.Muted)
local supply=text(top,"",UDim2.fromScale(.73,.12),UDim2.fromScale(.24,.76),Enum.Font.GothamBold,UITheme.Colors.Brass)
supply.TextXAlignment=Enum.TextXAlignment.Right

local context=frame(root,UDim2.fromScale(.03,.115),UDim2.fromScale(.27,.115),UITheme.Colors.Surface,.04)
local contextTitle=text(context,UITheme.T(lang,"army"),UDim2.fromScale(.06,.08),UDim2.fromScale(.88,.25),Enum.Font.GothamBold,UITheme.Colors.Parchment)
local contextBody=text(context,UITheme.T(lang,"selectArmy"),UDim2.fromScale(.06,.35),UDim2.fromScale(.88,.53),Enum.Font.Gotham,UITheme.Colors.Muted)
contextBody.TextWrapped=true

local modeBar=frame(root,UDim2.fromScale(.27,.855),UDim2.fromScale(.46,.115),UITheme.Colors.Surface,.04)
local buttons={}
local modes={"Move","Attack","Hold"}
for i,m in ipairs(modes) do
 buttons[m]=btn(modeBar,UITheme.T(lang,m:lower()),UDim2.fromScale(.025+(i-1)*.325,.17),UDim2.fromScale(.30,.66),function()
  mode=m
  for n,b in pairs(buttons) do b.BackgroundColor3=(n==mode) and UITheme.Colors.Brass or UITheme.Colors.Surface3 end
 end)
end
for n,b in pairs(buttons) do b.BackgroundColor3=(n==mode) and UITheme.Colors.Brass or UITheme.Colors.Surface3 end

local formationBar=frame(root,UDim2.fromScale(.27,.785),UDim2.fromScale(.46,.06),UITheme.Colors.Surface,.05)
for i,f in ipairs({"Line","Wedge","Spread"}) do
 btn(formationBar,UITheme.T(lang,f:lower()),UDim2.fromScale(.025+(i-1)*.325,.12),UDim2.fromScale(.30,.76),function()
  if selectedArmy~=0 then command:FireServer("Formation",{ArmyId=selectedArmy,Formation=f}) end
 end)
end

local info=frame(root,UDim2.fromScale(.03,.76),UDim2.fromScale(.22,.16),UITheme.Colors.Surface,.04)
text(info,"",UDim2.fromScale(.08,.08),UDim2.fromScale(.84,.82),Enum.Font.GothamMedium,UITheme.Colors.Muted).Name="Hint"

local mobileBar=nil
if mobile then
 mobileBar=frame(root,UDim2.fromScale(.04,.79),UDim2.fromScale(.92,.17),UITheme.Colors.Surface,.02)
 local actionWheel=btn(mobileBar,"⚔",UDim2.fromScale(.02,.12),UDim2.fromScale(.19,.72),function()
  mode=mode=="Attack" and "Move" or "Attack"
 end)
 for i,m in ipairs({"Move","Attack","Hold"}) do
  local b=btn(mobileBar,UITheme.T(lang,m:lower()),UDim2.fromScale(.23+(i-1)*.25,.12),UDim2.fromScale(.21,.72),function() mode=m end)
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

local function announce(message)
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
  selectedArmy=tonumber(army) or 0
  command:FireServer("SelectArmy",{ArmyId=selectedArmy})
  contextTitle.Text=UITheme.T(lang,"army").." #"..tostring(selectedArmy)
  contextBody.Text=UITheme.T(lang,"selectArmy").." • "..UITheme.T(lang,mode:lower())
  announce("ARMY #"..tostring(selectedArmy).." SELECTED")
  return
 end
 if province then
  selectedCastle=province
  castlePanel.Visible=true
  castleTitle.Text=tostring(province)
  castleBody.Text=UITheme.T(lang,"castle").." • "..UITheme.T(lang,mode:lower()).."\n"..UITheme.T(lang,"territory")..": "..tostring((state.Provinces and state.Provinces[province] and state.Provinces[province].Owner) or 0)
  if selectedArmy~=0 then
   if mode=="Move" then command:FireServer("Move",{ArmyId=selectedArmy,Position=hit.Position})
   elseif mode=="Hold" then command:FireServer("Hold",{ArmyId=selectedArmy})
   end
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

local function render(s)
 state=s or state
 local team=s.Team or 0
 teamText.Text=UITheme.TeamName(team,lang).."  •  "..UITheme.T(lang,"territory").." "..tostring(s.Owned or 0).."/"..tostring(s.TotalProvinces or 0)
 supply.Text=UITheme.T(lang,"supplies").."  "..tostring(math.floor(s.Supplies or 0))
 objective.Text=UITheme.T(lang,"objective").."  •  "..tostring(s.MapId or "WORLD").."  •  "..tostring(s.TeamCount or 2).." TEAMS"
 local hint=info:FindFirstChild("Hint")
 if hint then hint.Text=selectedArmy==0 and UITheme.T(lang,"selectArmy") or UITheme.T(lang,mode:lower()) end
 if s.MatchOver then
  announce((s.Winner==team and UITheme.T(lang,"victory") or UITheme.T(lang,"defeat")).."  •  "..tostring(s.MapId or "WORLD"))
 end
end
stateRemote.OnClientEvent:Connect(render)
local ok,s=pcall(function() return requestState:InvokeServer() end)
if ok and s then render(s) end
