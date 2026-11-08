-- Kingdoms Conquest — Stage 9 World Art Runtime
-- Builds reusable, map-aware visual language from MapPacks/MapService data.
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
if Workspace:GetAttribute("KC_BootstrapReady") ~= true then
	Workspace:GetAttributeChangedSignal("KC_BootstrapReady"):Wait()
end
if Workspace:GetAttribute("KC_RuntimeReady") ~= true then
	Workspace:GetAttributeChangedSignal("KC_RuntimeReady"):Wait()
end
local MapService = require(ReplicatedStorage.Shared.MapService)

local mapId = Workspace:GetAttribute("KC_MapId") or Config.Game.MapId
local teamCount = math.clamp(tonumber(Workspace:GetAttribute("KC_TeamCount")) or Config.Game.TeamCount or 2, 2, 4)
local selectedMap = MapService.GetMap(mapId, teamCount)
local pack = Config.MapPacks and Config.MapPacks[selectedMap.Name]
local art = (pack and pack.Art) or {}

local root = Workspace:WaitForChild("KingdomsConquest")
local provinces = root:WaitForChild("Provinces")
local terrain = root:WaitForChild("Terrain")

local function make(parent, name, size, position, color, material, canCollide)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.CanCollide = canCollide == true
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function addRoad(a, b, width)
	local delta = b - a
	local flatDelta = Vector3.new(delta.X, 0, delta.Z)
	local distance = flatDelta.Magnitude
	if distance < 2 then return end

	-- Roads connect castle gates instead of cutting through castle centers.
	local trim = math.min(18, distance * 0.28)
	local direction = flatDelta.Unit
	local startPoint = Vector3.new(a.X, 0.12, a.Z) + direction * trim
	local endPoint = Vector3.new(b.X, 0.12, b.Z) - direction * trim
	local roadDelta = endPoint - startPoint
	local roadDistance = Vector3.new(roadDelta.X, 0, roadDelta.Z).Magnitude
	if roadDistance < 4 then return end

	local midpoint = Vector3.new((startPoint.X+endPoint.X)/2, 0.12, (startPoint.Z+endPoint.Z)/2)
	local road = make(terrain, "Road_" .. tostring(math.floor(a.X)) .. "_" .. tostring(b.X), Vector3.new(width or 7, 0.35, roadDistance), midpoint, art.Road or Color3.fromRGB(118,111,98), Enum.Material.Cobblestone, false)
	road.CFrame = CFrame.lookAt(midpoint, Vector3.new(endPoint.X, midpoint.Y, endPoint.Z))
end

local function addTree(position, scale)
	local trunk=make(terrain,"TreeTrunk",Vector3.new(1.8,6,1.8)*scale,position+Vector3.new(0,3*scale,0),art.Trunk or Color3.fromRGB(79,59,43),Enum.Material.Wood,false)
	local crown=make(terrain,"TreeCrown",Vector3.new(7,7,7)*scale,position+Vector3.new(0,6.5*scale,0),art.Tree or Color3.fromRGB(54,86,57),Enum.Material.Grass,false)
	crown.Shape=Enum.PartType.Ball
	trunk.CastShadow=true
	crown.CastShadow=true
end

local function addRock(position, scale)
	local rock=make(terrain,"Rock",Vector3.new(4,2.5,3)*scale,position+Vector3.new(0,1.1*scale,0),art.DarkStone or Color3.fromRGB(88,86,79),Enum.Material.Slate,false)
	rock.Shape=Enum.PartType.Ball
	rock.Orientation=Vector3.new(0,math.random(0,180),0)
end

local function addLandmark(castle, data)
	local tier = castle:GetAttribute("CastleTier")
	local keep=castle:FindFirstChild("Keep")
	if not keep then return end

	-- Stage 1 owns the playable castle geometry and its four real gate openings.
	-- Stage 9 only adds presentation metadata here to avoid duplicate/out-of-footprint towers.
	local existingTowers = castle:FindFirstChild("Towers")
	if existingTowers then
		existingTowers:SetAttribute("PresentationReady", true)
	end

	local banner=castle:FindFirstChild("Banner")
	if banner then
		banner:SetAttribute("CastleTier",tier)
		banner:SetAttribute("CityName",data.CityName or castle.Name)
		local badge=Instance.new("BillboardGui")
		badge.Name="CastleTierBadge"
		badge.Size=UDim2.fromOffset(90,24)
		badge.StudsOffset=Vector3.new(0,tier=="Capital" and 8 or 5,0)
		badge.AlwaysOnTop=true
		badge.MaxDistance=260
		badge.Parent=banner
		local label=Instance.new("TextLabel")
		label.BackgroundTransparency=1
		label.Size=UDim2.fromScale(1,1)
		label.Font=Enum.Font.GothamBold
		label.TextScaled=true
		label.TextStrokeTransparency=.35
		label.TextColor3=art.BannerTrim or Color3.fromRGB(229,214,182)
		label.Text=(tier=="Capital" and "CAPITAL" or tier=="Major" and "MAJOR CITY" or "CASTLE")
		label.Parent=badge
	end
end

-- Visual graph follows the same MapService graph used by gameplay.
local cities=selectedMap.Cities or {}
for _,edge in ipairs(selectedMap.Edges or {}) do
	local a=cities[edge[1]]
	local b=cities[edge[2]]
	if a and b then
		addRoad(Vector3.new(a.X,0,a.Z),Vector3.new(b.X,0,b.Z),(a.Capital or b.Capital) and 9 or 7)
	end
end

-- Regional scatter: deterministic from node index, kept outside capture zones.
for index,cityId in ipairs(selectedMap.ProvinceOrder or {}) do
	local data=cities[cityId]
	local node=selectedMap.Provinces[cityId]
	if data and node then
		local offsets={
			Vector3.new(-20,0,20),Vector3.new(20,0,18),
			Vector3.new(-22,0,-18),Vector3.new(22,0,-20),
		}
		local offset=offsets[((index-1)%#offsets)+1]
		addTree(node.Position+offset, data.Capital and 1.0 or 0.8)
		if index%3==0 then addRock(node.Position-offset, data.Capital and 1.1 or 0.8) end
	end
end

for cityId,data in pairs(cities) do
	local castle=provinces:FindFirstChild(cityId.."_Castle")
	if castle then addLandmark(castle,data) end
end

-- Regional visual accents.
local accent=Instance.new("Folder")
accent.Name="Stage9RegionalAccents"
accent.Parent=terrain
accent:SetAttribute("MapId",selectedMap.Name)
accent:SetAttribute("Theme",art.Theme or "DEFAULT")

if selectedMap.River then
	local river=terrain:FindFirstChild("River")
	if river then river.Color=art.River or river.Color end
	for _,crossingId in ipairs(pack and pack.RiverCrossings or {}) do
		local city=cities[crossingId]
		if city then
			local bridge=make(accent,"Bridge_"..crossingId,Vector3.new(18,1,24),Vector3.new((selectedMap.River and selectedMap.River.Center.X) or city.X,1.0,city.Z),art.Stone or Color3.fromRGB(130,120,105),Enum.Material.WoodPlanks,false)
			bridge:SetAttribute("CrossingCity",crossingId)
		end
	end
end

print("[KingdomsConquest] Stage 9 world art initialized:", selectedMap.Name, art.Theme or "DEFAULT")
