local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("KingdomsRemotes")
local command = remotes:WaitForChild("Command")
local stateRemote = remotes:WaitForChild("State")
local requestState = remotes:WaitForChild("RequestState")

local selectedArmy = 0
local mode = "Move"
local state = requestState:InvokeServer()
local ui = {}

local function create(className, props, parent)
	local x = Instance.new(className)
	for k,v in pairs(props) do x[k] = v end
	x.Parent = parent
	return x
end

local gui = create("ScreenGui", {Name="KingdomsHUD", ResetOnSpawn=false, IgnoreGuiInset=true}, player:WaitForChild("PlayerGui"))

local top = create("Frame", {
	Name="TopBar", AnchorPoint=Vector2.new(0.5,0), Position=UDim2.fromScale(0.5,0.025), Size=UDim2.fromScale(0.92,0.09),
	BackgroundColor3=Color3.fromRGB(24,29,31), BackgroundTransparency=0.08, BorderSizePixel=0
}, gui)
create("UICorner",{CornerRadius=UDim.new(0,10)},top)
ui.title=create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromScale(0.02,0.08),Size=UDim2.fromScale(0.28,0.82),Font=Enum.Font.GothamBold,Text="KINGDOMS CONQUEST",TextColor3=Color3.fromRGB(235,226,204),TextScaled=true,TextXAlignment=Enum.TextXAlignment.Left},top)
ui.status=create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromScale(0.32,0.08),Size=UDim2.fromScale(0.42,0.82),Font=Enum.Font.Gotham,Text="",TextColor3=Color3.fromRGB(210,208,198),TextScaled=true},top)
ui.supplies=create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromScale(0.76,0.08),Size=UDim2.fromScale(0.22,0.82),Font=Enum.Font.GothamBold,Text="",TextColor3=Color3.fromRGB(224,181,99),TextScaled=true,TextXAlignment=Enum.TextXAlignment.Right},top)

local right = create("Frame",{Name="TerritoryPanel",AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(0.975,0.15),Size=UDim2.fromScale(0.19,0.4),BackgroundColor3=Color3.fromRGB(24,29,31),BackgroundTransparency=0.08,BorderSizePixel=0},gui)
create("UICorner",{CornerRadius=UDim.new(0,10)},right)
create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromScale(0.08,0.04),Size=UDim2.fromScale(0.84,0.12),Font=Enum.Font.GothamBold,Text="TERRITORY",TextColor3=Color3.fromRGB(235,226,204),TextScaled=true},right)
ui.provinces=create("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromScale(0.08,0.17),Size=UDim2.fromScale(0.84,0.79),Font=Enum.Font.Gotham,Text="",TextColor3=Color3.fromRGB(215,215,208),TextScaled=false,TextSize=14,TextYAlignment=Enum.TextYAlignment.Top,TextXAlignment=Enum.TextXAlignment.Left},right)

local bottom = create("Frame",{Name="CommandBar",AnchorPoint=Vector2.new(0.5,1),Position=UDim2.fromScale(0.5,0.965),Size=UDim2.fromScale(0.72,0.18),BackgroundColor3=Color3.fromRGB(24,29,31),BackgroundTransparency=0.06,BorderSizePixel=0},gui)
create("UICorner",{CornerRadius=UDim.new(0,12)},bottom)
local layout=create("UIGridLayout",{CellSize=UDim2.fromScale(0.145,0.72),CellPadding=UDim2.fromScale(0.012,0),HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center},bottom)

local function button(text, callback)
	local b=create("TextButton",{Text=text,Font=Enum.Font.GothamBold,TextScaled=true,TextColor3=Color3.fromRGB(234,228,214),BackgroundColor3=Color3.fromRGB(48,55,56),AutoButtonColor=true},bottom)
	create("UICorner",{CornerRadius=UDim.new(0,8)},b)
	b.MouseButton1Click:Connect(callback)
	return b
end

local function setMode(newMode)
	mode=newMode
end

button("MOVE",function() setMode("Move") end)
button("ATTACK",function() setMode("Attack") end)
button("HOLD",function() setMode("Hold") end)
button("LINE",function() if selectedArmy~=0 then command:FireServer("Formation",{ArmyId=selectedArmy,Formation="Line"}) end end)
button("WEDGE",function() if selectedArmy~=0 then command:FireServer("Formation",{ArmyId=selectedArmy,Formation="Wedge"}) end end)
button("SPREAD",function() if selectedArmy~=0 then command:FireServer("Formation",{ArmyId=selectedArmy,Formation="Spread"}) end end)
button("SPEARS",function() command:FireServer("RequestArmy",{ArmyType="Spearmen"}) end)
button("ARCHERS",function() command:FireServer("RequestArmy",{ArmyType="Archers"}) end)
button("CAVALRY",function() command:FireServer("RequestArmy",{ArmyType="Cavalry"}) end)

local info = create("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(0.5,1),Position=UDim2.fromScale(0.5,0.78),Size=UDim2.fromScale(0.55,0.05),Font=Enum.Font.Gotham,Text="Click your army to select • Move/Attack then click battlefield",TextColor3=Color3.fromRGB(220,214,199),TextScaled=true},gui)

local function raycast()
	local mousePos = UserInputService:GetMouseLocation()
	local camera = Workspace.CurrentCamera
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	if player.Character then params.FilterDescendantsInstances={player.Character} end
	return Workspace:Raycast(ray.Origin,ray.Direction*600,params)
end

local function findArmyId(instance)
	local current=instance
	while current and current ~= Workspace do
		local id=current:GetAttribute("ArmyId")
		if id then return id end
		current=current.Parent
	end
	return nil
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local hit=raycast()
		if not hit then return end
		local armyId=findArmyId(hit.Instance)
		if armyId then
			selectedArmy=armyId
			command:FireServer("SelectArmy",{ArmyId=armyId})
			return
		end
		if selectedArmy==0 then return end
		if mode=="Move" then
			command:FireServer("Move",{ArmyId=selectedArmy,Position=hit.Position})
		elseif mode=="Hold" then
			command:FireServer("Hold",{ArmyId=selectedArmy})
		elseif mode=="Attack" then
			local targetId=findArmyId(hit.Instance)
			if targetId then command:FireServer("Attack",{ArmyId=selectedArmy,TargetArmyId=targetId}) end
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode==Enum.KeyCode.M then mode="Move" end
	if input.KeyCode==Enum.KeyCode.A then mode="Attack" end
	if input.KeyCode==Enum.KeyCode.H then mode="Hold" end
	if input.KeyCode==Enum.KeyCode.One and selectedArmy~=0 then command:FireServer("Formation",{ArmyId=selectedArmy,Formation="Line"}) end
	if input.KeyCode==Enum.KeyCode.Two and selectedArmy~=0 then command:FireServer("Formation",{ArmyId=selectedArmy,Formation="Wedge"}) end
	if input.KeyCode==Enum.KeyCode.Three and selectedArmy~=0 then command:FireServer("Formation",{ArmyId=selectedArmy,Formation="Spread"}) end
end)

local function render(s)
	selectedArmy=s.SelectedArmy or selectedArmy
	ui.status.Text="TEAM "..tostring(s.Team).."   |   TERRITORY "..tostring(s.Owned).."/6   |   MODE "..mode
	ui.supplies.Text="SUPPLIES  "..tostring(math.floor(s.Supplies or 0))
	local lines={}
	for name,data in pairs(s.Provinces or {}) do
		local owner = data.Owner==0 and "NEUTRAL" or data.Owner==1 and "CRIMSON" or "AZURE"
		local progress = data.CaptureProgress and data.CaptureProgress > 0 and ("  "..math.floor(data.CaptureProgress).."s") or ""
		table.insert(lines,name.."  •  "..owner..progress)
	end
	table.sort(lines)
	ui.provinces.Text=table.concat(lines,"\n")
end

stateRemote.OnClientEvent:Connect(function(s)
	if s.MatchOver then
		ui.status.Text="VICTORY • TEAM "..tostring(s.Winner)
		ui.title.Text="MATCH COMPLETE"
		return
	end
	render(s)
end)

render(state)

-- Stage 3 presentation layer
local toast = create("TextLabel", {BackgroundColor3=Color3.fromRGB(29,34,34), BackgroundTransparency=0.08, AnchorPoint=Vector2.new(0.5,0), Position=UDim2.fromScale(0.5,0.13), Size=UDim2.fromScale(0.38,0.055), Font=Enum.Font.GothamMedium, Text="", TextColor3=Color3.fromRGB(238,228,207), TextScaled=true, Visible=false}, gui)
create("UICorner",{CornerRadius=UDim.new(0,9)},toast)
local function announce(text)
 toast.Text=text; toast.Visible=true
 task.delay(2.4,function() toast.Visible=false end)
end

local oldRender=render
render=function(s)
 oldRender(s)
 if s.Team then
  local teamName=s.Team==1 and "CRIMSON" or "AZURE"
  ui.status.Text=teamName.."  |  TERRITORY "..tostring(s.Owned).."/6  |  "..mode:upper()
 end
end

stateRemote.OnClientEvent:Connect(function(s)
 if s.MatchOver then return end
 if s.Provinces then
  for name,data in pairs(s.Provinces) do
   if data.CaptureProgress and data.CaptureProgress > 0 then announce("CAPTURING  •  "..name) end
  end
 end
end)
