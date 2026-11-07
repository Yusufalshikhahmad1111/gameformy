local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local WorldBuilder = {}

local function part(parent, name, size, cframe, material, color)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Anchored = true
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color or Color3.fromRGB(80,80,80)
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function label(parent, text, offset, color)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(220, 52)
	gui.StudsOffset = offset or Vector3.new(0,7,0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 220
	gui.Parent = parent
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1,1)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.Text = text
	t.TextColor3 = color or Color3.new(1,1,1)
	t.TextStrokeTransparency = 0.35
	t.Parent = gui
end

local function castle(parent, provinceName, position, owner)
	local model = Instance.new("Model")
	model.Name = provinceName .. "_Castle"
	model.Parent = parent
	local ownerColor = owner == 1 and Config.Team.Red.Color or owner == 2 and Config.Team.Blue.Color or Color3.fromRGB(148,143,130)
	part(model,"Keep",Vector3.new(20,16,20),CFrame.new(position+Vector3.new(0,9,0)),Enum.Material.Slate,Color3.fromRGB(86,84,82))
	part(model,"Courtyard",Vector3.new(38,2,34),CFrame.new(position+Vector3.new(0,2,0)),Enum.Material.Cobblestone,Color3.fromRGB(106,103,96))
	local wallY=position.Y+5
	for _,v in ipairs({
		{"WallN",Vector3.new(52,8,3),position+Vector3.new(0,wallY,-24)},
		{"WallS",Vector3.new(52,8,3),position+Vector3.new(0,wallY,24)},
		{"WallE",Vector3.new(3,8,52),position+Vector3.new(24,wallY,0)},
		{"WallW",Vector3.new(3,8,52),position+Vector3.new(-24,wallY,0)},
	}) do part(model,v[1],v[2],CFrame.new(v[3]),Enum.Material.Cobblestone,Color3.fromRGB(111,108,101)) end
	local gates=Instance.new("Folder")
	gates.Name="Gates"
	gates.Parent=model
	for name,offset in pairs({
		North=Vector3.new(0,1.5,-27),East=Vector3.new(27,1.5,0),South=Vector3.new(0,1.5,27),West=Vector3.new(-27,1.5,0)
	}) do
		local zone=part(gates,name,Vector3.new(14,1,14),CFrame.new(position+offset),Enum.Material.Neon,ownerColor)
		zone.Transparency=0.78
		zone.CanCollide=false
		zone:SetAttribute("Gate",name)
	end
	local banner=part(model,"Banner",Vector3.new(1,11,1),CFrame.new(position+Vector3.new(0,14,-7)),Enum.Material.Wood,ownerColor)
	banner.CanCollide=false
	label(banner,provinceName.."  •  CASTLE",Vector3.new(0,2,0),ownerColor)
end

function WorldBuilder.Build()
	local old=workspace:FindFirstChild("KingdomsConquest")
	if old then old:Destroy() end
	local root=Instance.new("Folder")
	root.Name="KingdomsConquest"
	root.Parent=workspace
	local terrain=Instance.new("Folder")
	terrain.Name="Terrain"
	terrain.Parent=root
	part(terrain,"WorldFloor",Vector3.new(290,2,290),CFrame.new(0,-1,0),Enum.Material.Grass,Color3.fromRGB(82,112,71))
	for name,data in pairs(Config.Provinces) do
		local province=Instance.new("Model")
		province.Name=name
		province:SetAttribute("Owner",data.Home)
		province.Parent=root
		local p=part(province,"Province",data.Size,CFrame.new(data.Position),Enum.Material.Grass,Color3.fromRGB(92,125,80))
		label(p,name,Vector3.new(0,2.5,0),Color3.fromRGB(232,225,205))
		castle(province,name,data.Position,data.Home)
	end
	local river=part(terrain,"River",Vector3.new(22,0.3,260),CFrame.new(38,0,0),Enum.Material.Glass,Color3.fromRGB(67,125,158))
	river.Transparency=0.35
	river.CanCollide=false
	local spawns=Instance.new("Folder")
	spawns.Name="Spawns"
	spawns.Parent=root
	for team,pos in pairs({[1]=Vector3.new(0,3,-118),[2]=Vector3.new(0,3,128)}) do
		local s=part(spawns,"Team"..team,Vector3.new(14,1,14),CFrame.new(pos),Enum.Material.Neon,team==1 and Config.Team.Red.Color or Config.Team.Blue.Color)
		s.Transparency=0.55
		s.CanCollide=false
	end
	return root
end

return WorldBuilder