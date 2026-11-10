-- Kingdoms Conquest — Stage 16 World 2.0 / 3D Art Production
-- Visual-only production layer for the editable world prefabs.
-- Gameplay remains authoritative in Stage 1 + services; this script never creates
-- a second gameplay graph or replaces capture/combat/economy state.

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage.Shared.Config)
local MapService = require(ReplicatedStorage.Shared.MapService)
local WorldBuilder = require(script.Parent.Services.WorldBuilder)

local MAP_IDS = {"Syria", "SaudiArabia", "Palestine", "Europe"}

local STATE_COLORS = {
	Safe = Color3.fromRGB(91, 178, 116),
	Contested = Color3.fromRGB(235, 194, 74),
	Assaulted = Color3.fromRGB(218, 84, 70),
	Stabilizing = Color3.fromRGB(92, 157, 196),
	Neutral = Color3.fromRGB(184, 171, 143),
}

local function teamColor(teamId)
	local team = Config.Teams[tonumber(teamId) or 0]
	return team and team.Color or STATE_COLORS.Neutral
end

local function mapArt(mapId)
	local pack = Config.MapPacks[mapId]
	return (pack and pack.Art) or {}
end

local function makePart(parent, name, size, position, color, material, transparency)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Transparency = transparency or 0
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makePointLight(parent, color)
	local light = Instance.new("PointLight")
	light.Name = "WarmLight"
	light.Color = color
	light.Brightness = 0.65
	light.Range = 12
	light.Shadows = false
	light.Parent = parent
end

local function clearStage16(container)
	local old = container:FindFirstChild("Stage16Art")
	if old then
		old:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "Stage16Art"
	folder.Parent = container
	folder:SetAttribute("ProductionStage", 16)
	return folder
end

local function getCastleCenter(castle)
	local courtyard = castle:FindFirstChild("Courtyard", true)
	if courtyard and courtyard:IsA("BasePart") then
		return courtyard.Position
	end
	local keep = castle:FindFirstChild("Keep", true)
	if keep and keep:IsA("BasePart") then
		return keep.Position
	end
	return castle:GetPivot().Position
end

local function addCrenellations(parent, basePart, count, color)
	if not basePart or not basePart:IsA("BasePart") then
		return
	end
	local width = basePart.Size.X
	local depth = basePart.Size.Z
	local topY = basePart.Position.Y + basePart.Size.Y * 0.5 + 0.45
	local halfX = math.max(1.4, width * 0.42)
	local halfZ = math.max(1.4, depth * 0.42)
	local merlonSize = Vector3.new(math.max(1.2, width * 0.18), 0.9, math.max(1.2, depth * 0.18))
	local points = {
		Vector3.new(-halfX, topY, -halfZ),
		Vector3.new(halfX, topY, -halfZ),
		Vector3.new(-halfX, topY, halfZ),
		Vector3.new(halfX, topY, halfZ),
	}
	for index = 1, math.min(count, #points) do
		makePart(parent, "Merlon_" .. index, merlonSize, points[index], color, Enum.Material.Cobblestone, 0)
	end
end

local function buildKeepRoof(castleArt, keep, art, tier)
	if not keep or not keep:IsA("BasePart") then
		return
	end
	local roofColor = art.DarkStone or Color3.fromRGB(74, 72, 68)
	local roofSize = Vector3.new(keep.Size.X + 1.4, 0.7, keep.Size.Z + 1.4)
	local roof = makePart(
		castleArt,
		"KeepRoof",
		roofSize,
		keep.Position + Vector3.new(0, keep.Size.Y * 0.5 + 0.35, 0),
		roofColor,
		Enum.Material.Slate,
		0
	)
	roof.CastShadow = true
	addCrenellations(castleArt, roof, tier == "Capital" and 4 or 4, art.Stone or Color3.fromRGB(144, 132, 110))

	local cap = makePart(
		castleArt,
		"KeepCrown",
		Vector3.new(math.max(3, keep.Size.X * 0.55), 0.8, math.max(3, keep.Size.Z * 0.55)),
		roof.Position + Vector3.new(0, 0.75, 0),
		art.Stone or Color3.fromRGB(144, 132, 110),
		Enum.Material.Cobblestone,
		0
	)
	cap.CastShadow = true
end

local function buildTowerCaps(castleArt, towers, art)
	if not towers then
		return
	end
	local stone = art.Stone or Color3.fromRGB(144, 132, 110)
	for index, tower in ipairs(towers:GetChildren()) do
		if tower:IsA("BasePart") then
			local cap = makePart(
				castleArt,
				"TowerCap_" .. index,
				Vector3.new(tower.Size.X + 0.8, 0.6, tower.Size.Z + 0.8),
				tower.Position + Vector3.new(0, tower.Size.Y * 0.5 + 0.3, 0),
				stone,
				Enum.Material.Cobblestone,
				0
			)
			cap.CastShadow = true
			addCrenellations(castleArt, tower, 4, stone)
		end
	end
end

local function buildGateHouse(castleArt, gateName, gate, art)
	if not gate:IsA("BasePart") then
		return
	end

	local stone = art.Stone or Color3.fromRGB(144, 132, 110)
	local darkStone = art.DarkStone or Color3.fromRGB(82, 80, 76)
	local gateWidth = math.max(gate.Size.X, gate.Size.Z)
	local y = gate.Position.Y + 3.2
	local vertical = gateName == "East" or gateName == "West"

	local p1, p2, beam
	if vertical then
		local sideOffset = math.max(2.4, gate.Size.Z * 0.5 + 1.4)
		p1 = Vector3.new(gate.Position.X, y, gate.Position.Z - sideOffset)
		p2 = Vector3.new(gate.Position.X, y, gate.Position.Z + sideOffset)
		beam = Vector3.new(3.2, 2.0, gateWidth + 3.8)
	else
		local sideOffset = math.max(2.4, gate.Size.X * 0.5 + 1.4)
		p1 = Vector3.new(gate.Position.X - sideOffset, y, gate.Position.Z)
		p2 = Vector3.new(gate.Position.X + sideOffset, y, gate.Position.Z)
		beam = Vector3.new(gateWidth + 3.8, 2.0, 3.2)
	end

	makePart(castleArt, gateName .. "_GatePillarL", Vector3.new(3.2, 6.4, 3.2), p1, stone, Enum.Material.Cobblestone, 0)
	makePart(castleArt, gateName .. "_GatePillarR", Vector3.new(3.2, 6.4, 3.2), p2, stone, Enum.Material.Cobblestone, 0)
	makePart(castleArt, gateName .. "_GateBeam", beam, Vector3.new(gate.Position.X, gate.Position.Y + 6.1, gate.Position.Z), darkStone, Enum.Material.Slate, 0)

	local slatCount = 3
	for index = 1, slatCount do
		local offset = (index - 2) * 1.25
		local position
		local size
		if vertical then
			position = gate.Position + Vector3.new(0, 2.1, offset)
			size = Vector3.new(0.25, 4.0, 0.25)
		else
			position = gate.Position + Vector3.new(offset, 2.1, 0)
			size = Vector3.new(0.25, 4.0, 0.25)
		end
		makePart(castleArt, gateName .. "_Portcullis_" .. index, size, position, darkStone, Enum.Material.Metal, 0.05)
	end

	local lantern = makePart(
		castleArt,
		gateName .. "_Lantern",
		Vector3.new(1.0, 1.0, 1.0),
		Vector3.new(gate.Position.X, gate.Position.Y + 7.1, gate.Position.Z),
		Color3.fromRGB(255, 199, 84),
		Enum.Material.Neon,
		0.05
	)
	lantern.Shape = Enum.PartType.Ball
	makePointLight(lantern, Color3.fromRGB(255, 184, 86))
end

local function buildBanner(castleArt, castle, center, color, tier)
	local banner = castle:FindFirstChild("Banner", true)
	local bannerY = center.Y + (tier == "Capital" and 16 or 13)
	if banner and banner:IsA("BasePart") then
		bannerY = banner.Position.Y
	end

	local pole = makePart(
		castleArt,
		"HeroBannerPole",
		Vector3.new(0.35, tier == "Capital" and 12 or 9, 0.35),
		Vector3.new(center.X, bannerY + 2.5, center.Z),
		Color3.fromRGB(80, 69, 54),
		Enum.Material.Wood,
		0
	)
	pole.CastShadow = true

	local cloth = makePart(
		castleArt,
		"BannerCloth",
		Vector3.new(tier == "Capital" and 4.2 or 3.4, tier == "Capital" and 2.3 or 2.0, 0.22),
		Vector3.new(center.X + (tier == "Capital" and 1.8 or 1.4), bannerY + (tier == "Capital" and 6.0 or 4.8), center.Z),
		color,
		Enum.Material.Fabric,
		0
	)
	cloth:SetAttribute("OwnerVisual", true)
	cloth.CastShadow = true

	local tip = makePart(
		castleArt,
		"BannerTip",
		Vector3.new(0.5, 0.5, 0.5),
		pole.Position + Vector3.new(0, pole.Size.Y * 0.5 + 0.4, 0),
		color,
		Enum.Material.Metal,
		0
	)
	tip.Shape = Enum.PartType.Ball
end

local function buildOwnerMarkers(castleArt, center, footprint)
	local folder = Instance.new("Folder")
	folder.Name = "OwnerMarkers"
	folder.Parent = castleArt
	local markerSize = math.max(2.0, footprint * 0.08)
	local offsets = {
		Vector3.new(-footprint * 0.42, 1.8, -footprint * 0.42),
		Vector3.new(footprint * 0.42, 1.8, -footprint * 0.42),
		Vector3.new(-footprint * 0.42, 1.8, footprint * 0.42),
		Vector3.new(footprint * 0.42, 1.8, footprint * 0.42),
	}
	for index, offset in ipairs(offsets) do
		local marker = makePart(
			folder,
			"Marker_" .. index,
			Vector3.new(markerSize, 0.7, markerSize),
			center + offset,
			STATE_COLORS.Neutral,
			Enum.Material.Neon,
			0.45
		)
		marker:SetAttribute("OwnerVisual", true)
	end
	return folder
end

local function buildCityBlock(castleArt, center, art, tier, index)
	local radius = tier == "Capital" and 34 or tier == "Major" and 31 or 28
	local angle = math.rad((index - 1) * 120 + (tier == "Capital" and 30 or 0))
	local position = center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
	local scale = tier == "Capital" and 1.0 or tier == "Major" and 0.9 or 0.78

	local house = Instance.new("Model")
	house.Name = "CityHouse_" .. index
	house.Parent = castleArt

	local body = makePart(
		house,
		"Body",
		Vector3.new(7, 4.6, 6) * scale,
		position + Vector3.new(0, 2.3 * scale, 0),
		art.Stone or Color3.fromRGB(144, 132, 110),
		Enum.Material.Cobblestone,
		0
	)
	body.CastShadow = true

	local roof = makePart(
		house,
		"Roof",
		Vector3.new(7.8, 1.0, 6.8) * scale,
		position + Vector3.new(0, 5.0 * scale, 0),
		art.DarkStone or Color3.fromRGB(78, 75, 70),
		Enum.Material.Slate,
		0
	)
	roof.CastShadow = true

	makePart(
		house,
		"Door",
		Vector3.new(1.0, 2.0, 0.22) * scale,
		position + Vector3.new(0, 1.0 * scale, -3.02 * scale),
		Color3.fromRGB(73, 53, 39),
		Enum.Material.Wood,
		0
	)

	local window = makePart(
		house,
		"Window",
		Vector3.new(1.1, 0.8, 0.18) * scale,
		position + Vector3.new(-2.0 * scale, 2.7 * scale, -3.03 * scale),
		art.River or Color3.fromRGB(79, 117, 135),
		Enum.Material.Glass,
		0.15
	)
	window.CastShadow = false
end

local function buildLandscapeAccents(mapModel, mapId, art)
	local folder = clearStage16(mapModel)
	folder.Name = "Stage16Art"
	local terrain = mapModel:FindFirstChild("Terrain", true)
	if not terrain then
		return folder
	end

	local mapPack = Config.MapPacks[mapId]
	local origin = (MapService.GetMap(mapId, mapPack and mapPack.DefaultTeamCount or 2) or {}).Origin or Vector3.zero
	local theme = art.Theme or "DEFAULT"
	local hillMaterial = theme == "DESERT_SANDSTONE" and Enum.Material.Sand or Enum.Material.Slate
	local hillColor = theme == "DESERT_SANDSTONE"
		and (art.Ground or Color3.fromRGB(170, 140, 90))
		or (art.DarkStone or Color3.fromRGB(91, 88, 82))

	local landscape = Instance.new("Folder")
	landscape.Name = "TerrainPresentation"
	landscape.Parent = folder
	landscape:SetAttribute("Theme", theme)

	local points = {
		Vector3.new(origin.X - 230, 4, origin.Z - 205),
		Vector3.new(origin.X + 220, 3, origin.Z - 180),
		Vector3.new(origin.X - 210, 4, origin.Z + 190),
		Vector3.new(origin.X + 230, 3, origin.Z + 205),
		Vector3.new(origin.X - 300, 2, origin.Z + 40),
		Vector3.new(origin.X + 300, 2, origin.Z - 15),
	}

	for index, point in ipairs(points) do
		local size = (index % 2 == 0) and Vector3.new(95, 12, 58) or Vector3.new(75, 9, 52)
		local hill = makePart(
			landscape,
			"Hill_" .. index,
			size,
			point,
			hillColor,
			hillMaterial,
			0
		)
		hill.Shape = Enum.PartType.Ball
		hill.CastShadow = true
		hill.CanQuery = false
	end

	local fogStone = art.DarkStone or Color3.fromRGB(92, 88, 80)
	for index, edge in ipairs(mapPack and mapPack.Edges or {}) do
		local cityA = MapService.GetCity(mapId, edge[1])
		local cityB = MapService.GetCity(mapId, edge[2])
		if cityA and cityB and index <= 10 then
			local a = cityA.Position
			local b = cityB.Position
			local direction = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
			if direction.Magnitude > 1 then
				local midpoint = a:Lerp(b, 0.5) + Vector3.new(0, 0.6, 0)
				local marker = makePart(
					landscape,
					"RoadStone_" .. index,
					Vector3.new(3.0, 1.1, 1.8),
					midpoint,
					fogStone,
					Enum.Material.Slate,
					0
				)
				marker.CFrame = CFrame.lookAt(midpoint, Vector3.new(b.X, midpoint.Y, b.Z))
				marker.CastShadow = true
			end
		end
	end

	return folder
end

local function buildCastle(mapModel, mapId, city, art)
	local castle = mapModel:FindFirstChild(city.Id .. "_Castle", true)
	if not castle or not castle:IsA("Model") then
		return false, "missing-castle"
	end

	local tier = city.Capital and "Capital" or ((city.Income or 0) >= 9 and "Major" or "Regional")
	local previousArt = castle:FindFirstChild("Stage16Art")
	if previousArt then
		previousArt:Destroy()
	end
	castle:SetAttribute("CastleTier", castle:GetAttribute("CastleTier") or tier)
	castle:SetAttribute("Stage16ArtReady", true)
	castle:SetAttribute("CityName", city.Name)
	castle:SetAttribute("MapId", mapId)

	local castleArt = Instance.new("Folder")
	castleArt.Name = "Stage16Art"
	castleArt.Parent = castle
	castleArt:SetAttribute("Tier", tier)
	castleArt:SetAttribute("CityName", city.Name)

	local center = getCastleCenter(castle)
	local keep = castle:FindFirstChild("Keep", true)
	local towers = castle:FindFirstChild("Towers", true)
	local gates = castle:FindFirstChild("Gates", true)
	local footprint = tier == "Capital" and 32 or tier == "Major" and 30 or 26

	if not gates then
		gates = Instance.new("Folder")
		gates.Name = "Gates"
		gates.Parent = castle
	end

	buildKeepRoof(castleArt, keep, art, tier)
	buildTowerCaps(castleArt, towers, art)

	local gateNames = {"North", "East", "South", "West"}
	for _, gateName in ipairs(gateNames) do
		local gate = gates:FindFirstChild(gateName)
		if not gate then
			local offset = gateName == "North" and Vector3.new(0, 1.2, -footprint * 0.5 - 0.5)
				or gateName == "South" and Vector3.new(0, 1.2, footprint * 0.5 + 0.5)
				or gateName == "East" and Vector3.new(footprint * 0.5 + 0.5, 1.2, 0)
				or Vector3.new(-footprint * 0.5 - 0.5, 1.2, 0)
			local size = (gateName == "East" or gateName == "West")
				and Vector3.new(5, 0.6, 7)
				or Vector3.new(7, 0.6, 5)
			gate = makePart(gates, gateName, size, center + offset, STATE_COLORS.Neutral, Enum.Material.Neon, 0.55)
			gate:SetAttribute("Gate", gateName)
			gate:SetAttribute("Province", city.Id)
		end
		buildGateHouse(castleArt, gateName, gate, art)
	end

	local owner = tonumber(castle:GetAttribute("Owner")) or 0
	buildBanner(castleArt, castle, center, teamColor(owner), tier)
	local markers = buildOwnerMarkers(castleArt, center, footprint)

	local stateIndicator = makePart(
		castleArt,
		"StateIndicator",
		Vector3.new(math.max(7, footprint * 0.28), 0.42, 1.2),
		center + Vector3.new(0, 1.5, footprint * 0.23),
		STATE_COLORS.Neutral,
		Enum.Material.Neon,
		0.18
	)
	stateIndicator:SetAttribute("StateVisual", true)

	local display = Instance.new("BillboardGui")
	display.Name = "Stage16Landmark"
	display.Size = UDim2.fromOffset(tier == "Capital" and 190 or 150, tier == "Capital" and 50 or 40)
	display.StudsOffset = Vector3.new(0, tier == "Capital" and 24 or 19, 0)
	display.AlwaysOnTop = true
	display.MaxDistance = tier == "Capital" and 320 or 250
	display.Parent = castleArt

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 0.2
	label.BackgroundColor3 = Color3.fromRGB(45, 40, 31)
	label.BorderSizePixel = 0
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextStrokeTransparency = 0.25
	label.TextColor3 = Color3.fromRGB(240, 225, 190)
	label.Text = string.upper(city.Name) .. "  •  " .. string.upper(tier)
	label.Parent = display

	local nearestCityDistance = math.huge
	local mapData = MapService.GetMap(mapId, (Config.MapPacks[mapId] and Config.MapPacks[mapId].DefaultTeamCount) or 2)
	for otherId, otherCity in pairs(mapData.Cities or {}) do
		if otherId ~= city.Id and otherCity.Position then
			nearestCityDistance = math.min(nearestCityDistance, (center - otherCity.Position).Magnitude)
		end
	end
	local houseCount = tier == "Capital" and 3 or tier == "Major" and 2 or 1
	-- Dense city clusters must stay readable: do not add outer houses when
	-- another castle is too close to the presentation ring.
	if nearestCityDistance < 52 then
		houseCount = 0
	elseif nearestCityDistance < 70 then
		houseCount = math.min(houseCount, 1)
	end
	for index = 1, houseCount do
		buildCityBlock(castleArt, center, art, tier, index)
	end

	-- State/ownership visuals are intentionally small and sit inside the castle
	-- footprint so they can never cover the gameplay gates.
	markers:SetAttribute("MapId", mapId)
	return true
end

local function refreshCastleVisual(castle)
	local artFolder = castle:FindFirstChild("Stage16Art")
	if not artFolder then
		return
	end

	local owner = tonumber(castle:GetAttribute("Owner")) or 0
	local state = tostring(castle:GetAttribute("CastleState") or "Safe")
	local color = teamColor(owner)
	local stateColor = STATE_COLORS[state] or color

	local banner = artFolder:FindFirstChild("BannerCloth")
	if banner and banner:IsA("BasePart") then
		banner.Color = color
	end

	local markers = artFolder:FindFirstChild("OwnerMarkers")
	if markers then
		for _, marker in ipairs(markers:GetChildren()) do
			if marker:IsA("BasePart") then
				marker.Color = color
				marker.Transparency = owner > 0 and 0.22 or 0.52
			end
		end
	end

	local stateIndicator = artFolder:FindFirstChild("StateIndicator")
	if stateIndicator and stateIndicator:IsA("BasePart") then
		stateIndicator.Color = stateColor
		stateIndicator.Transparency = state == "Safe" and 0.30 or 0.06
	end
end

local function wireCastleState(castle)
	refreshCastleVisual(castle)
	for _, attribute in ipairs({"Owner", "CastleState", "Garrison", "CaptureTeam"}) do
		castle:GetAttributeChangedSignal(attribute):Connect(function()
			refreshCastleVisual(castle)
		end)
	end
end

local function validateMap(mapId, mapModel)
	local failures = {}
	local pack = Config.MapPacks[mapId]
	if not pack then
		table.insert(failures, "missing-config:" .. mapId)
		return failures
	end

	local ok, reason = WorldBuilder.ValidateStaticMap(Workspace, mapId)
	if not ok then
		table.insert(failures, reason)
	end

	local terrain = mapModel:FindFirstChild("Terrain", true)
	if not terrain or not terrain:FindFirstChild("WorldFloor", true) then
		table.insert(failures, "missing-world-floor")
	end

	local roads = terrain and terrain:FindFirstChild("Roads", true)
	if roads and #roads:GetChildren() == 0 then
		table.insert(failures, "empty-road-network")
	end

	for _, city in ipairs(pack.Cities or {}) do
		local castle = mapModel:FindFirstChild(city.Id .. "_Castle", true)
		if not castle then
			table.insert(failures, "missing-castle:" .. city.Id)
			continue
		end
		local gates = castle:FindFirstChild("Gates", true)
		local gateCount = 0
		if gates then
			for _, gateName in ipairs({"North", "East", "South", "West"}) do
				if gates:FindFirstChild(gateName) then
					gateCount += 1
				end
			end
		end
		if gateCount < 4 then
			table.insert(failures, string.format("castle-gates:%s:%d/4", city.Id, gateCount))
		end
		if not castle:GetAttribute("Stage16ArtReady") then
			table.insert(failures, "art-missing:" .. city.Id)
		end
	end

	-- Spatial sanity: castle footprints must remain visibly separated.
	local previous = {}
	for _, city in ipairs(pack.Cities or {}) do
		local castle = mapModel:FindFirstChild(city.Id .. "_Castle", true)
		if castle then
			local center = getCastleCenter(castle)
			-- Match the authored castle footprint plus a small visual safety margin;
			-- this intentionally avoids false positives for dense city clusters.
			local radius = city.Capital and 18 or ((city.Income or 0) >= 9 and 17 or 15)
			for _, item in ipairs(previous) do
				if (center - item.center).Magnitude < radius + item.radius then
					table.insert(failures, string.format(
						"castle-overlap:%s<->%s:%.1f",
						city.Id,
						item.id,
						(center - item.center).Magnitude
					))
				end
			end
			table.insert(previous, {id = city.Id, center = center, radius = radius})
		end
	end

	return failures
end

local function applyLighting()
	local existingAtmosphere = Lighting:FindFirstChild("KC_Stage16Atmosphere")
	if not existingAtmosphere then
		local atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "KC_Stage16Atmosphere"
		atmosphere.Density = 0.24
		atmosphere.Offset = 0.15
		atmosphere.Color = Color3.fromRGB(214, 204, 182)
		atmosphere.Decay = Color3.fromRGB(102, 92, 74)
		atmosphere.Glare = 0.04
		atmosphere.Haze = 0.7
		atmosphere.Parent = Lighting
	end

	local colorCorrection = Lighting:FindFirstChild("KC_Stage16Color")
	if not colorCorrection then
		colorCorrection = Instance.new("ColorCorrectionEffect")
		colorCorrection.Name = "KC_Stage16Color"
		colorCorrection.Brightness = 0.02
		colorCorrection.Contrast = 0.08
		colorCorrection.Saturation = -0.03
		colorCorrection.TintColor = Color3.fromRGB(255, 247, 228)
		colorCorrection.Parent = Lighting
	end

	Lighting.Brightness = math.max(Lighting.Brightness, 2)
	Lighting.EnvironmentDiffuseScale = 0.45
	Lighting.EnvironmentSpecularScale = 0.45
end

if Workspace:GetAttribute("KC_RuntimeReady") ~= true then
	Workspace:GetAttributeChangedSignal("KC_RuntimeReady"):Wait()
end

applyLighting()

local allFailures = {}
local builtMaps = 0
local builtCastles = 0

for _, mapId in ipairs(MAP_IDS) do
	local mapModel = Workspace:FindFirstChild("Map_" .. mapId)
	if not mapModel then
		table.insert(allFailures, "missing-map-model:" .. mapId)
		continue
	end

	local artFolder = buildLandscapeAccents(mapModel, mapId, mapArt(mapId))
	builtMaps += 1

	local pack = Config.MapPacks[mapId]
	for _, city in ipairs(pack.Cities or {}) do
		local success = buildCastle(mapModel, mapId, city, mapArt(mapId))
		if success then
			builtCastles += 1
			local castle = mapModel:FindFirstChild(city.Id .. "_Castle", true)
			wireCastleState(castle)
		end
	end

	local failures = validateMap(mapId, mapModel)
	for _, failure in ipairs(failures) do
		table.insert(allFailures, mapId .. ":" .. failure)
	end

	artFolder:SetAttribute("CastleCount", #pack.Cities)
	artFolder:SetAttribute("ValidationFailures", #failures)
end

Workspace:SetAttribute("KC_Stage16Ready", #allFailures == 0)
Workspace:SetAttribute("KC_Stage16Studio", RunService:IsStudio())
Workspace:SetAttribute("KC_Stage16MapCount", builtMaps)
Workspace:SetAttribute("KC_Stage16CastleCount", builtCastles)
Workspace:SetAttribute("KC_Stage16AuditFailures", #allFailures)

print(string.format(
	"[KingdomsConquest][Stage16] world art %s | maps=%d | castles=%d | failures=%d | studio=%s",
	#allFailures == 0 and "ready" or "FAILED",
	builtMaps,
	builtCastles,
	#allFailures,
	tostring(RunService:IsStudio())
))

if #allFailures > 0 then
	warn("[KingdomsConquest][Stage16] " .. table.concat(allFailures, " | "))
end
