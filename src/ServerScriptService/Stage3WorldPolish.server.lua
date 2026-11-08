local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local selectedMap = Config.Maps[Config.Game.MapId] or Config.Maps.Heartland
local root = Workspace:WaitForChild("KingdomsConquest")
local provinces = root:WaitForChild("Provinces")
local terrain = root:WaitForChild("Terrain")

local function make(parent,name,size,position,color,material)
	local p=Instance.new("Part")
	p.Name=name
	p.Size=size
	p.Position=position
	p.Anchored=true
	p.CanCollide=true
	p.Material=material
	p.Color=color
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	p.Parent=parent
	return p
end

local function addPath(position,size,rotation)
	local p=make(terrain,"StoneRoad",size,position,Color3.fromRGB(118,111,98),Enum.Material.Cobblestone)
	p.CFrame=CFrame.new(position)*CFrame.Angles(0,rotation or 0,0)
end

local function addTree(position,scale)
	local trunk=make(terrain,"TreeTrunk",Vector3.new(2,7,2)*scale,position+Vector3.new(0,3.5*scale,0),Color3.fromRGB(79,59,43),Enum.Material.Wood)
	trunk.CanCollide=false
	local crown=make(terrain,"TreeCrown",Vector3.new(8,8,8)*scale,position+Vector3.new(0,8*scale,0),Color3.fromRGB(54,86,57),Enum.Material.Grass)
	crown.Shape=Enum.PartType.Ball
	crown.CanCollide=false
end

local function addCastleDetail(castle,isCentral)
	local keep=castle:FindFirstChild("Keep")
	if keep and isCentral then
		for i=1,4 do
			local angle=math.rad((i-1)*90)
			make(castle,"HeroTower"..i,Vector3.new(5,16,5),keep.Position+Vector3.new(math.cos(angle)*12,6,math.sin(angle)*12),Color3.fromRGB(72,72,70),Enum.Material.Slate)
		end
	end
	local banner=castle:FindFirstChild("Banner")
	if banner then
		local sigil=Instance.new("BillboardGui")
		sigil.Name="HeraldicBadge"
		sigil.Size=UDim2.fromOffset(58,58)
		sigil.StudsOffset=Vector3.new(0,5,0)
		sigil.AlwaysOnTop=true
		sigil.Parent=banner
		local circle=Instance.new("Frame")
		circle.Size=UDim2.fromScale(1,1)
		circle.BackgroundColor3=banner.Color
		circle.BackgroundTransparency=0.15
		circle.BorderSizePixel=0
		circle.Parent=sigil
		local corner=Instance.new("UICorner")
		corner.CornerRadius=UDim.new(1,0)
		corner.Parent=circle
		local mark=Instance.new("TextLabel")
		mark.BackgroundTransparency=1
		mark.Size=UDim2.fromScale(1,1)
		mark.Text="✦"
		mark.Font=Enum.Font.GothamBold
		mark.TextScaled=true
		mark.TextColor3=Color3.fromRGB(238,228,201)
		mark.Parent=circle
	end
end

local center=selectedMap.Provinces[selectedMap.ProvinceOrder[math.ceil(#selectedMap.ProvinceOrder/2)]]
if center then addPath(center.Position,Vector3.new(9,0.3,110),0) end
addPath(Vector3.new(-45,0,18),Vector3.new(85,0.3,9),math.rad(4))
addPath(Vector3.new(45,0,18),Vector3.new(85,0.3,9),math.rad(-4))
addPath(Vector3.new(0,0,72),Vector3.new(9,0.3,90),0)

for provinceName,_ in pairs(selectedMap.Provinces) do
	local castle=provinces:FindFirstChild(provinceName.."_Castle")
	if castle then addCastleDetail(castle,provinceName=="Central Keep") end
end

for _,data in pairs(selectedMap.Provinces) do
	for i=1,4 do
		local sign=data.Position+Vector3.new((i-2.5)*13,0,16+(i%2)*7)
		addTree(sign,0.7+(i%2)*0.15)
	end
end

for i=1,14 do
	local x=-132+(i%7)*42
	local z=-135+math.floor(i/7)*35
	addTree(Vector3.new(x,0,z),0.8)
end

local marker=Instance.new("Part")
marker.Name="CentralObjectiveMarker"
marker.Size=Vector3.new(2,18,2)
marker.Position=(center and center.Position or Vector3.new(0,0,0))+Vector3.new(0,10,-8)
marker.Anchored=true
marker.CanCollide=false
marker.Material=Enum.Material.Neon
marker.Color=Color3.fromRGB(222,181,97)
marker.Transparency=0.55
marker.Parent=terrain

print("[KingdomsConquest] Stage 3 world presentation initialized.")