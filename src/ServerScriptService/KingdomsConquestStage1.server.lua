-- Kingdoms Conquest — Stage 1 Graybox Vertical Slice
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage.Shared.Config)
local RateLimiter = require(ReplicatedStorage.Shared.RateLimiter)
local MapService = require(ReplicatedStorage.Shared.MapService)
local NetworkContract = require(ReplicatedStorage.Shared.NetworkContract)
local StateSchemas = require(ReplicatedStorage.Shared.StateSchemas)
local ArmyService = require(script.Parent.Services.ArmyService)
local SoldierService = require(script.Parent.Services.SoldierService)
local CombatService = require(script.Parent.Services.CombatService)
local CastleService = require(script.Parent.Services.CastleService)
local EconomyService = require(script.Parent.Services.EconomyService)
local MatchService = require(script.Parent.Services.MatchService)
local CaptureService = require(script.Parent.Services.CaptureService)
local BotCommanderService = require(script.Parent.Services.BotCommanderService)

if workspace:GetAttribute("KC_BootstrapReady") ~= true then
	workspace:GetAttributeChangedSignal("KC_BootstrapReady"):Wait()
end

-- Stage 11: one authoritative remote hierarchy. Never destroy/recreate remotes
-- during startup; client scripts may already be waiting on this folder.
local remotes, remoteSet = NetworkContract.Ensure()
local commandRemote = remoteSet.Command
local vfxRemote = remoteSet.VFX
local stateRemote = remoteSet.State
local requestState = remoteSet.RequestState
local feedbackRemote = remoteSet.Feedback
workspace:SetAttribute("KC_NetworkContractVersion", NetworkContract.Version)

local root = Instance.new("Folder")
root.Name = "KingdomsConquest"
root.Parent = workspace

local terrainFolder = Instance.new("Folder")
terrainFolder.Name = "Terrain"
terrainFolder.Parent = root

local provinceFolder = Instance.new("Folder")
provinceFolder.Name = "Provinces"
provinceFolder.Parent = root

local armyFolder = Instance.new("Folder")
armyFolder.Name = "Armies"
armyFolder.Parent = root

local spawnFolder = Instance.new("Folder")
spawnFolder.Name = "Spawns"
spawnFolder.Parent = root

local activeTeamCount = math.clamp(tonumber(workspace:GetAttribute("KC_TeamCount")) or tonumber(Config.Game.TeamCount) or 2, 2, 4)
Config.Game.TeamCount = activeTeamCount
local selectedMap = MapService.GetMap(workspace:GetAttribute("KC_MapId") or Config.Game.MapId, activeTeamCount)
Config.Game.MapId = selectedMap.Name
local staticMap = workspace:FindFirstChild("Map_" .. selectedMap.Name)

local teamObjects = {}
local teamSupplies = {}
for teamId = 1, activeTeamCount do teamSupplies[teamId] = 60 end
local armies = {}
local playerSelectedArmy = {}
local nextArmyId = 0
local pingCooldown = {}
local botCommanders = {}
local botByTeam = {}
local terrainZones = {}
local matchStartedAt = 0
local matchEnded = false
local provinceCaptureEvent = ReplicatedStorage:FindFirstChild("KingdomsProvinceCaptured")
if not provinceCaptureEvent then
	provinceCaptureEvent = Instance.new("BindableEvent")
	provinceCaptureEvent.Name = "KingdomsProvinceCaptured"
	provinceCaptureEvent.Parent = ReplicatedStorage
end
local matchResultEvent = ReplicatedStorage:FindFirstChild("KingdomsMatchResult")
if not matchResultEvent then
	matchResultEvent = Instance.new("BindableEvent")
	matchResultEvent.Name = "KingdomsMatchResult"
	matchResultEvent.Parent = ReplicatedStorage
end

local function initialOwner(data)
	local owners = data.StartingOwners or {}
	return owners[activeTeamCount] or 0
end

local function terrainMultiplier(position)
	local river = terrainZones.River
	if river and math.abs(position.X - river.Center.X) <= river.HalfX and math.abs(position.Z - river.Center.Z) <= river.HalfZ then
		return river.Speed
	end
	return 1
end

local provinceStates = {}
local mapNodes = {}
for name, data in pairs(selectedMap.Provinces) do
	mapNodes[name] = {Name=data.CityName or name, Province=data.ProvinceName or name, Position=data.Position, Capital=data.Capital == true}
	local tier = data.Capital and "Capital" or (data.Strategic and "Major" or "Regional")
	provinceStates[name] = {
		Owner=initialOwner(data),
		CaptureTeam=0,
		CaptureProgress=0,
		Income=data.Income,
		Strategic=data.Strategic,
		Castle=CastleService.Create(name, tier, initialOwner(data), Config),
	}
end

local function computeWorldHalfExtent(map)
	local maximum = 180
	for _, data in pairs(map.Provinces or {}) do
		maximum = math.max(maximum, math.abs(data.Position.X), math.abs(data.Position.Z))
	end
	for _, position in pairs(map.Spawns or {}) do
		if typeof(position) == "Vector3" then
			maximum = math.max(maximum, math.abs(position.X), math.abs(position.Z))
		end
	end
	return math.max(350, math.ceil((maximum + 90) / 50) * 50)
end

local WORLD_HALF_EXTENT = computeWorldHalfExtent(selectedMap)
local ARMY_Y = 3

local function makePart(parent, name, size, position, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function addBillboard(part, text, color)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(220, 50)
	gui.StudsOffset = Vector3.new(0, 10, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 220
	gui.Parent = part
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Font = Enum.Font.GothamBold
	t.Text = text
	t.TextColor3 = color
	t.TextScaled = true
	t.TextStrokeTransparency = 0.25
	t.Parent = gui
end

local function ownerColor(owner)
	local team = Config.Teams[owner]
	if team then return team.Color end
	return Color3.fromRGB(150, 144, 128)
end

local function createTeam(number, info)
	local old = Teams:FindFirstChild(info.Name)
	if old then old:Destroy() end
	local t = Instance.new("Team")
	t.Name = info.Name
	t.TeamColor = info.BrickColor
	t.AutoAssignable = false
	t.Parent = Teams
	teamObjects[number] = t
end

for teamId = 1, activeTeamCount do createTeam(teamId, Config.Teams[teamId]) end

local art = (Config.MapPacks and Config.MapPacks[selectedMap.Name] and Config.MapPacks[selectedMap.Name].Art) or {}
Lighting.Brightness = 2
Lighting.ClockTime = 14
Lighting.EnvironmentDiffuseScale = 0.6
Lighting.EnvironmentSpecularScale = 0.25
Lighting.FogEnd = 900
Lighting.FogColor = art.Ground or Color3.fromRGB(173, 184, 169)
local mapExtent = WORLD_HALF_EXTENT * 2
makePart(terrainFolder, "WorldFloor", Vector3.new(mapExtent, 2, mapExtent), Vector3.new(0, -1, 0), art.Grass or Color3.fromRGB(76, 105, 67), Enum.Material.Grass)
local riverData = selectedMap.River or {Center=Vector3.new(0,0,0), HalfX=0, HalfZ=0, Speed=0.55, Size=Vector3.new(0,0.3,0)}
local river = makePart(terrainFolder, "River", riverData.Size, riverData.Center + Vector3.new(0, 0.1, 0), art.River or Color3.fromRGB(72, 125, 154), Enum.Material.Glass)
terrainZones.River = riverData
river.Transparency = 0.35
river.CanCollide = false

local function createCastle(provinceName, data)
	local castleTier = data.Capital and "Capital" or (data.Strategic and "Major" or "Regional")
	local model = Instance.new("Model")
	model.Name = provinceName .. "_Castle"
	model.Parent = provinceFolder
	model:SetAttribute("Province", provinceName)
	model:SetAttribute("CastleTier", castleTier)
	model:SetAttribute("CityName", data.CityName or provinceName)
	model:SetAttribute("RegionName", data.ProvinceName or provinceName)

	local base = data.Position
	local footprint = castleTier == "Capital" and 32 or castleTier == "Major" and 30 or 26
	local wallHalf = footprint * 0.5 - 1.5
	local gateWidth = castleTier == "Capital" and 8 or 7
	local wallHeight = castleTier == "Capital" and 8 or 7
	local keepSize = castleTier == "Capital" and 14 or castleTier == "Major" and 12 or 10
	local keepHeight = castleTier == "Capital" and 18 or castleTier == "Major" and 15 or 12
	local stone = art.Stone or Color3.fromRGB(112, 108, 99)
	local darkStone = art.DarkStone or Color3.fromRGB(82, 82, 80)
	local gateColor = ownerColor(initialOwner(data))

	makePart(model, "Courtyard", Vector3.new(footprint, 2, footprint), base + Vector3.new(0, 1, 0), stone, Enum.Material.Cobblestone)
	makePart(model, "Keep", Vector3.new(keepSize, keepHeight, keepSize), base + Vector3.new(0, keepHeight * 0.5 + 1, 0), darkStone, Enum.Material.Slate)

	local function wallSegment(name, size, position)
		makePart(model, name, size, position, stone, Enum.Material.Cobblestone)
	end

	local halfGap = gateWidth * 0.5
	local sideLength = wallHalf - halfGap
	local segmentLength = math.max(4, sideLength)
	local segmentOffset = halfGap + segmentLength * 0.5

	-- Four real wall openings for the capture gates.
	wallSegment("WallNorthL", Vector3.new(segmentLength, wallHeight, 3), base + Vector3.new(-segmentOffset, wallHeight * 0.5, -wallHalf))
	wallSegment("WallNorthR", Vector3.new(segmentLength, wallHeight, 3), base + Vector3.new(segmentOffset, wallHeight * 0.5, -wallHalf))
	wallSegment("WallSouthL", Vector3.new(segmentLength, wallHeight, 3), base + Vector3.new(-segmentOffset, wallHeight * 0.5, wallHalf))
	wallSegment("WallSouthR", Vector3.new(segmentLength, wallHeight, 3), base + Vector3.new(segmentOffset, wallHeight * 0.5, wallHalf))
	wallSegment("WallEastN", Vector3.new(3, wallHeight, segmentLength), base + Vector3.new(wallHalf, wallHeight * 0.5, -segmentOffset))
	wallSegment("WallEastS", Vector3.new(3, wallHeight, segmentLength), base + Vector3.new(wallHalf, wallHeight * 0.5, segmentOffset))
	wallSegment("WallWestN", Vector3.new(3, wallHeight, segmentLength), base + Vector3.new(-wallHalf, wallHeight * 0.5, -segmentOffset))
	wallSegment("WallWestS", Vector3.new(3, wallHeight, segmentLength), base + Vector3.new(-wallHalf, wallHeight * 0.5, segmentOffset))

	local banner = makePart(model, "Banner", Vector3.new(1.2, castleTier == "Capital" and 10 or 8, 1.2), base + Vector3.new(0, castleTier == "Capital" and 18 or 15, 0), gateColor, Enum.Material.Wood)
	banner.CanCollide = false
	addBillboard(banner, (data.CityName or provinceName) .. "  •  " .. castleTier, gateColor)

	local towers = Instance.new("Folder")
	towers.Name = "Towers"
	towers.Parent = model
	local towerRadius = wallHalf - 1
	local towerSize = castleTier == "Capital" and 5 or 4.5
	local towerHeight = castleTier == "Capital" and 11 or 9
	for i, offset in ipairs({
		Vector3.new(-towerRadius, towerHeight * 0.5, -towerRadius),
		Vector3.new(towerRadius, towerHeight * 0.5, -towerRadius),
		Vector3.new(-towerRadius, towerHeight * 0.5, towerRadius),
		Vector3.new(towerRadius, towerHeight * 0.5, towerRadius),
	}) do
		makePart(towers, "Tower" .. i, Vector3.new(towerSize, towerHeight, towerSize), base + offset, darkStone, Enum.Material.Slate)
	end

	local gates = Instance.new("Folder")
	gates.Name = "Gates"
	gates.Parent = model

	local gateSpecs = {
		North = {position = base + Vector3.new(0, 1.2, -wallHalf - 0.5), size = Vector3.new(gateWidth, 0.6, 5)},
		East = {position = base + Vector3.new(wallHalf + 0.5, 1.2, 0), size = Vector3.new(5, 0.6, gateWidth)},
		South = {position = base + Vector3.new(0, 1.2, wallHalf + 0.5), size = Vector3.new(gateWidth, 0.6, 5)},
		West = {position = base + Vector3.new(-wallHalf - 0.5, 1.2, 0), size = Vector3.new(5, 0.6, gateWidth)},
	}

	for gateName, spec in pairs(gateSpecs) do
		local gate = makePart(gates, gateName, spec.size, spec.position, gateColor, Enum.Material.Neon)
		gate.Transparency = 0.38
		gate.CanCollide = false
		gate:SetAttribute("Gate", gateName)
		gate:SetAttribute("Province", provinceName)

		local marker = Instance.new("BillboardGui")
		marker.Name = "GateMarker"
		marker.Size = UDim2.fromOffset(110, 28)
		marker.StudsOffset = Vector3.new(0, 4.5, 0)
		marker.AlwaysOnTop = true
		marker.MaxDistance = 160
		marker.Parent = gate
		local markerLabel = Instance.new("TextLabel")
		markerLabel.BackgroundTransparency = 1
		markerLabel.Size = UDim2.fromScale(1, 1)
		markerLabel.Font = Enum.Font.GothamBold
		markerLabel.TextScaled = true
		markerLabel.TextStrokeTransparency = 0.2
		markerLabel.TextColor3 = gateColor
		markerLabel.Text = "▲ GATE"
		markerLabel.Parent = marker
	end

	local captureHint = Instance.new("BillboardGui")
	captureHint.Name = "CaptureHint"
	captureHint.Size = UDim2.fromOffset(220, 32)
	captureHint.StudsOffset = Vector3.new(0, castleTier == "Capital" and 23 or 18, 0)
	captureHint.AlwaysOnTop = true
	captureHint.MaxDistance = 180
	captureHint.Parent = model:FindFirstChild("Keep")
	local hintLabel = Instance.new("TextLabel")
	hintLabel.BackgroundTransparency = 1
	hintLabel.Size = UDim2.fromScale(1, 1)
	hintLabel.Font = Enum.Font.GothamBold
	hintLabel.TextScaled = true
	hintLabel.TextStrokeTransparency = 0.2
	hintLabel.TextColor3 = Color3.fromRGB(236, 221, 181)
	hintLabel.Text = "ENTER GATE • HOLD 10s"
	hintLabel.Parent = captureHint
end
for name, data in pairs(selectedMap.Provinces) do
	local zone = makePart(provinceFolder, name .. "_Territory", data.Size, data.Position, Color3.fromRGB(94, 121, 78), Enum.Material.Grass)
	zone:SetAttribute("Owner", initialOwner(data))
	zone.Transparency = 0.15
	zone.CanCollide = true
	zone:SetAttribute("Province", name)
	addBillboard(zone, (data.CityName or name) .. "  •  " .. (data.ProvinceName or name), Color3.fromRGB(235, 228, 210))
	createCastle(name, data)
end

for team = 1, activeTeamCount do
	local position = selectedMap.Spawns[team] or Vector3.new(0, 3, 0)
	local spawnPart = makePart(spawnFolder, "Team" .. team, Vector3.new(16, 1, 16), position, ownerColor(team), Enum.Material.Neon)
	spawnPart.Transparency = 0.55
	spawnPart.CanCollide = false
end

-- The editable map prefabs in Workspace are the visible world. Stage 1 keeps only
-- invisible gameplay proxies for authoritative capture/pathfinding state.
for _, descendant in ipairs(root:GetDescendants()) do
	if descendant:IsA("BasePart") then
		descendant.Transparency = 1
		descendant.CanCollide = false
	end
	if descendant:IsA("BillboardGui") then
		descendant.Enabled = false
	end
end

-- Stage 3+ clients must only proceed after the complete runtime world exists.
workspace:SetAttribute("KC_RuntimeReady", true)

local function findTeamForPlayer(player)
	local id = player:GetAttribute("TeamId")
	if id and teamObjects[id] then return id end
	for teamId, teamObject in pairs(teamObjects) do if player.Team == teamObject then return teamId end end
	return 1
end

local function teamCount(number)
	local count = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if findTeamForPlayer(player) == number then count += 1 end
	end
	return count
end

local function assignTeam(player)
	local requested = player:GetAttribute("TeamId")
	local number = (requested and requested >= 1 and requested <= activeTeamCount) and requested or (function()
	local bestId, bestCount = 1, math.huge
	for teamId = 1, activeTeamCount do
		local count = teamCount(teamId)
		if count < bestCount then bestId, bestCount = teamId, count end
	end
	return bestId
end)()
	player.Team = teamObjects[number]
	player.Neutral = false
	player:SetAttribute("TeamId", number)
end

local function startMatchClock()
	if matchStartedAt == 0 and workspace:GetAttribute("MatchActive") == true then
		matchStartedAt = os.clock()
		workspace:SetAttribute("MatchStartedAt", os.time())
	end
end

local function lobbySpawnPart()
	local lobby = workspace:FindFirstChild("KingdomsLobbyEntrance")
	if not lobby then return nil end
	return lobby:FindFirstChild("KingdomsLobbySpawnLocation", true) or lobby:FindFirstChild("LobbySpawn", true)
end

local function teleportPlayerForState(player)
	local character = player.Character
	if not character then return end
	if workspace:GetAttribute("MatchActive") == true then
		local number = findTeamForPlayer(player)
		local spawnPart = spawnFolder:FindFirstChild("Team" .. number)
		if spawnPart then
			character:PivotTo(spawnPart.CFrame + Vector3.new(0, 4, 0))
		end
	else
		local spawnPart = lobbySpawnPart()
		if spawnPart then
			character:PivotTo(spawnPart.CFrame + Vector3.new(0, 4, 0))
		end
	end
end

local function characterSpawn(player, character)
	task.defer(function()
		teleportPlayerForState(player)
	end)
end

workspace:GetAttributeChangedSignal("MatchActive"):Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		task.defer(function()
			teleportPlayerForState(player)
		end)
	end
end)

local function formationOffset(formation, index)
	local offsets = {
		Line = {Vector3.new(-6,0,-3),Vector3.new(-2,0,-3),Vector3.new(2,0,-3),Vector3.new(6,0,-3),Vector3.new(-4,0,2),Vector3.new(0,0,2),Vector3.new(4,0,2),Vector3.new(8,0,2)},
		Wedge = {Vector3.new(0,0,-6),Vector3.new(-3,0,-2),Vector3.new(3,0,-2),Vector3.new(-6,0,2),Vector3.new(0,0,2),Vector3.new(6,0,2),Vector3.new(-9,0,6),Vector3.new(9,0,6)},
		Column = {Vector3.new(0,0,-10),Vector3.new(0,0,-6),Vector3.new(0,0,-2),Vector3.new(0,0,2),Vector3.new(0,0,6),Vector3.new(0,0,10),Vector3.new(0,0,14),Vector3.new(0,0,18)},
		Spread = {Vector3.new(-9,0,-5),Vector3.new(-3,0,-7),Vector3.new(3,0,-7),Vector3.new(9,0,-5),Vector3.new(-9,0,5),Vector3.new(-3,0,7),Vector3.new(3,0,7),Vector3.new(9,0,5)},
	}
	return offsets[formation] and offsets[formation][index] or offsets.Line[index]
end

local function sortedAliveSoldiers(army)
	local list = {}
	for _, soldier in pairs(army.Soldiers or {}) do
		if SoldierService.IsAlive(soldier) then
			table.insert(list, soldier)
		end
	end
	table.sort(list, function(x, y)
		return tostring(x.Id) < tostring(y.Id)
	end)
	return list
end

local function buildSoldierVisual(armyModel, soldier, position, forward, teamColor, classInfo)
	local model = Instance.new("Model")
	model.Name = "Soldier_" .. tostring(soldier.Id)
	model:SetAttribute("SoldierId", tostring(soldier.Id))
	model:SetAttribute("ArmyId", armyModel:GetAttribute("ArmyId"))
	model.Parent = armyModel

	local root = makePart(model, "Root", Vector3.new(1.2, 0.5, 1.2), position, teamColor, Enum.Material.SmoothPlastic)
	root.Transparency = 1
	root.CanCollide = false
	model.PrimaryPart = root

	local skin = Color3.fromRGB(214, 177, 139)
	local cloth = classInfo.Color
	local dark = Color3.fromRGB(48, 48, 44)

	local function add(name, size, offset, color, material)
		local p = makePart(model, name, size, position + offset, color, material)
		p.CanCollide = false
		return p
	end

	if armyModel:GetAttribute("ArmyType") == "Cavalry" then
		add("HorseBody", Vector3.new(3.4, 2, 4.8), Vector3.new(0, 1.35, 0), dark, Enum.Material.SmoothPlastic)
		add("HorseHead", Vector3.new(1.8, 2.1, 1.9), Vector3.new(0, 2.7, -1.8), dark, Enum.Material.SmoothPlastic)
		add("RiderBody", Vector3.new(1.4, 2.3, 1.1), Vector3.new(0, 3.7, 0), cloth, Enum.Material.Fabric)
		add("RiderHead", Vector3.new(1.25, 1.25, 1.25), Vector3.new(0, 5.35, 0), skin, Enum.Material.SmoothPlastic)
		add("Lance", Vector3.new(0.16, 4.8, 0.16), Vector3.new(0.9, 4.6, -0.8), classInfo.Accent, Enum.Material.Metal)
	else
		add("Body", Vector3.new(1.45, 2.3, 1.05), Vector3.new(0, 1.7, 0), cloth, Enum.Material.Fabric)
		add("Head", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 3.35, 0), skin, Enum.Material.SmoothPlastic)
		add("LegL", Vector3.new(0.5, 1.7, 0.62), Vector3.new(-0.4, 0.25, 0), dark, Enum.Material.SmoothPlastic)
		add("LegR", Vector3.new(0.5, 1.7, 0.62), Vector3.new(0.4, 0.25, 0), dark, Enum.Material.SmoothPlastic)
		if armyModel:GetAttribute("ArmyType") == "Spearmen" then
			add("Spear", Vector3.new(0.15, 4.6, 0.15), Vector3.new(0.92, 2.8, -0.3), classInfo.Accent, Enum.Material.Wood)
			add("Shield", Vector3.new(1.05, 1.35, 0.25), Vector3.new(-0.86, 1.8, -0.15), teamColor, Enum.Material.Metal)
		else
			add("Bow", Vector3.new(0.22, 2.55, 0.22), Vector3.new(0.9, 2.2, -0.25), classInfo.Accent, Enum.Material.Wood)
			add("Quiver", Vector3.new(0.55, 1.4, 0.35), Vector3.new(-0.75, 2.05, 0.2), dark, Enum.Material.Fabric)
		end
	end

	local healthGui = Instance.new("BillboardGui")
	healthGui.Name = "SoldierHealth"
	healthGui.Size = UDim2.fromOffset(54, 14)
	healthGui.StudsOffset = Vector3.new(0, 6.2, 0)
	healthGui.AlwaysOnTop = true
	healthGui.MaxDistance = 90
	healthGui.Parent = root
	local health = Instance.new("Frame")
	health.BackgroundColor3 = Color3.fromRGB(40, 40, 36)
	health.BorderSizePixel = 0
	health.Size = UDim2.fromScale(1, 0.42)
	health.Parent = healthGui
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BorderSizePixel = 0
	fill.BackgroundColor3 = teamColor
	fill.Size = UDim2.fromScale(math.max(0.04, soldier.Health / math.max(1, soldier.MaxHealth)), 1)
	fill.Parent = health

	model:PivotTo(CFrame.lookAt(position, position + forward))
	return model
end

local function makeArmyVisual(army)
	if army.Model then army.Model:Destroy() end

	local model = Instance.new("Model")
	model.Name = "Army_" .. army.Id
	model.Parent = armyFolder
	model:SetAttribute("ArmyId", army.Id)
	model:SetAttribute("OwnerUserId", army.Owner.UserId)
	model:SetAttribute("ArmyType", army.Type)

	local color = ownerColor(army.Team)
	local classInfo = Config.ArmyTypes[army.Type]
	local anchor = makePart(model, "ArmyAnchor", Vector3.new(2, 1, 2), army.Position, color, Enum.Material.SmoothPlastic)
	anchor.Transparency = 1
	anchor.CanCollide = false

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ArmyLabel"
	billboard.Size = UDim2.fromOffset(230, 56)
	billboard.StudsOffset = Vector3.new(0, 9, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 220
	billboard.Parent = anchor

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 0.58)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.15
	label.Parent = billboard

	local stateLabel = Instance.new("TextLabel")
	stateLabel.Name = "State"
	stateLabel.BackgroundTransparency = 1
	stateLabel.Position = UDim2.fromScale(0, 0.56)
	stateLabel.Size = UDim2.fromScale(1, 0.38)
	stateLabel.Font = Enum.Font.GothamMedium
	stateLabel.TextScaled = true
	stateLabel.TextColor3 = Color3.fromRGB(225, 218, 202)
	stateLabel.TextStrokeTransparency = 0.25
	stateLabel.Parent = billboard

	army.Model = model
	army.SoldierModels = {}
	local soldiers = sortedAliveSoldiers(army)
	for index, soldier in ipairs(soldiers) do
		local offset = ArmyService.GetFormationOffset(army.Formation, index, #soldiers)
		local position = army.Position + offset
		army.SoldierModels[soldier.Id] = buildSoldierVisual(model, soldier, position, Vector3.new(0, 0, 1), color, classInfo)
	end
end

local function syncArmyVisual(army)
	if not army.Model or not army.Model.Parent then
		if ArmyService.IsAlive(army) then makeArmyVisual(army) end
		return
	end

	local anchor = army.Model:FindFirstChild("ArmyAnchor")
	if anchor then anchor.Position = army.Position end

	local soldiers = sortedAliveSoldiers(army)
	local count = #soldiers
	local targetDelta = army.TargetPosition - army.Position
	local forward = targetDelta.Magnitude > 0.2 and targetDelta.Unit or Vector3.new(0, 0, 1)

	for index, soldier in ipairs(soldiers) do
		local offset = ArmyService.GetFormationOffset(army.Formation, index, count)
		local position = army.Position + offset
		local soldierModel = army.SoldierModels and army.SoldierModels[soldier.Id]
		if not soldierModel or not soldierModel.Parent then
			makeArmyVisual(army)
			return
		end
		soldierModel:PivotTo(CFrame.lookAt(position, position + forward))
		local root = soldierModel:FindFirstChild("Root")
		local healthGui = root and root:FindFirstChild("SoldierHealth")
		local fill = healthGui and healthGui:FindFirstChild("Fill", true)
		if fill and fill:IsA("Frame") then
			fill.Size = UDim2.fromScale(math.max(0.04, soldier.Health / math.max(1, soldier.MaxHealth)), 1)
		end
	end

	local labelGui = anchor and anchor:FindFirstChild("ArmyLabel")
	local label = labelGui and labelGui:FindFirstChild("Text")
	local stateLabel = labelGui and labelGui:FindFirstChild("State")
	local classInfo = Config.ArmyTypes[army.Type]
	if label and classInfo then
		label.Text = string.format("%s • %d/%d", classInfo.Label, army.SoldierCount or count, count)
	end
	if stateLabel then
		local order = army.Order or "Hold"
		stateLabel.Text = string.format("%s  •  %s  •  MOR %d  •  FAT %d", order:upper(), tostring(army.CombatState or "SEARCHING"):upper(), math.floor(army.Morale or 0), math.floor(army.Fatigue or 0))
	end
end

local function playerRoot(player)
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function addSoldierToArmy(owner, army, armyType)
	if not army or not ArmyService.IsAlive(army) then
		return false, "ARMY_NOT_ACTIVE"
	end
	local info = Config.ArmyTypes[armyType or army.Type]
	if not info then return false, "UNKNOWN_ARMY" end
	if army.Type ~= (armyType or army.Type) then
		return false, "ROLE_MISMATCH"
	end

	local maxSoldiers = ArmyService.GetMaxSoldiers(info)
	if (army.SoldierCount or 0) >= maxSoldiers then
		return false, "ARMY_FULL"
	end

	local cost = ArmyService.GetRecruitCost(info, 1)
	local team = army.Team
	if (teamSupplies[team] or 0) < cost then
		return false, "NEED_" .. tostring(cost) .. "_SUPPLIES"
	end

	teamSupplies[team] -= cost
	local soldierId = ArmyService.NextSoldierId(army)
	local seedOwnerId = owner and owner.UserId or 0
	local soldier = SoldierService.Create(Config, {
		Id = soldierId,
		ArmyId = army.Id,
		Role = army.Type,
		PersonalitySeed = (army.Id * 1009) + army.SoldierSequence * 7919 + seedOwnerId,
	})
	army.Soldiers[soldier.Id] = soldier
	ArmyService.RefreshAggregate(army, SoldierService)
	makeArmyVisual(army)

	if typeof(owner) == "Instance" and owner:IsA("Player") then
		playerSelectedArmy[owner] = army.Id
		feedbackRemote:FireClient(owner, "SOLDIER_RECRUITED", {
			ArmyId = army.Id,
			ArmyType = army.Type,
			SoldierId = soldier.Id,
			SoldierCount = army.SoldierCount,
			Cost = cost,
			Supplies = teamSupplies[team],
		})
	end
	return true, soldier
end

local function createArmyForOwner(owner, team, armyType, spawnBase)
	if workspace:GetAttribute("MatchActive") ~= true or matchEnded then
		return nil, "MATCH_NOT_ACTIVE"
	end
	local info = Config.ArmyTypes[armyType]
	if not info then
		return nil, "UNKNOWN_ARMY"
	end

	local initialCount = math.min(
		ArmyService.GetInitialSoldierCount(info),
		ArmyService.GetMaxSoldiers(info)
	)
	local unitCost = ArmyService.GetRecruitCost(info, 1)
	local affordable = math.floor((teamSupplies[team] or 0) / math.max(1, unitCost))
	local soldierCount = math.min(initialCount, affordable)
	if soldierCount <= 0 then
		return nil, "NEED_" .. tostring(unitCost) .. "_SUPPLIES"
	end

	nextArmyId += 1
	local spawnPosition = spawnBase or selectedMap.Spawns[team] or Vector3.new(0, ARMY_Y, 0)
	local offsetSeed = (nextArmyId - 1) % 5
	local spawnOffsets = {
		Vector3.new(8, 0, 0),
		Vector3.new(-8, 0, 0),
		Vector3.new(0, 0, 8),
		Vector3.new(0, 0, -8),
		Vector3.new(10, 0, 10),
	}
	spawnPosition += spawnOffsets[offsetSeed + 1]

	local army = ArmyService.GetDefaultState(Config, {
		Id = nextArmyId,
		Owner = owner,
		Team = team,
		Type = armyType,
		Position = Vector3.new(spawnPosition.X, ARMY_Y, spawnPosition.Z),
		TargetPosition = Vector3.new(spawnPosition.X, ARMY_Y, spawnPosition.Z),
		FallbackPosition = selectedMap.Spawns[team] or spawnPosition,
	})
	armies[army.Id] = army

	local totalCost = 0
	for _ = 1, soldierCount do
		local soldierId = ArmyService.NextSoldierId(army)
		local seedOwnerId = owner and owner.UserId or 0
		local soldier = SoldierService.Create(Config, {
			Id = soldierId,
			ArmyId = army.Id,
			Role = armyType,
			PersonalitySeed = (army.Id * 1009) + army.SoldierSequence * 7919 + seedOwnerId,
		})
		army.Soldiers[soldier.Id] = soldier
		totalCost += unitCost
	end

	teamSupplies[team] -= totalCost
	ArmyService.RefreshAggregate(army, SoldierService)
	makeArmyVisual(army)

	if owner and owner:IsA and owner:IsA("Player") then
		playerSelectedArmy[owner] = army.Id
		feedbackRemote:FireClient(owner, "ARMY_CREATED", {
			ArmyId = army.Id,
			ArmyType = armyType,
			SoldierCount = army.SoldierCount,
			Cost = totalCost,
			CostPerSoldier = unitCost,
			Supplies = teamSupplies[team],
		})
	end

	return army
end

local function createArmy(player, armyType)
	local team = findTeamForPlayer(player)
	local rootPart = playerRoot(player)
	local spawnBase = rootPart and rootPart.Position or selectedMap.Spawns[team]
	return createArmyForOwner(player, team, armyType, spawnBase)
end

local function armyOwnedBy(player, armyId)
	local army = armies[armyId]
	return army and army.Owner == player and army.Model and army.Model.Parent
end

local function playersNearPosition(position, radius)
	local found = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local rootPart = playerRoot(player)
		if rootPart and (rootPart.Position - position).Magnitude <= radius then
			table.insert(found, player)
		end
	end
	return found
end

local function updateStaticProvinceVisual(name)
	local state = provinceStates[name]
	local mapModel = staticMap
	if not mapModel or not state then return end
	local color = ownerColor(state.Owner)
	local castle = mapModel:FindFirstChild(name .. "_Castle", true)
	if castle then
		local banner = castle:FindFirstChild("Banner", true)
		if banner and banner:IsA("BasePart") then banner.Color = color end
		local gates = castle:FindFirstChild("Gates", true)
		if gates then
			for _, gate in ipairs(gates:GetChildren()) do
				if gate:IsA("BasePart") then gate.Color = color end
			end
		end
	end
	local territory = mapModel:FindFirstChild(name .. "_Territory", true)
	if territory and territory:IsA("BasePart") then
		territory.Color = color:Lerp(Color3.fromRGB(92, 115, 80), 0.55)
	end
end

local function updateProvinceVisual(name)
	local state = provinceStates[name]
	local model = provinceFolder:FindFirstChild(name .. "_Castle")
	if not model then return end
	local color = ownerColor(state.Owner)
	local banner = model:FindFirstChild("Banner")
	if banner then banner.Color = color end
	local gates = model:FindFirstChild("Gates")
	if gates then for _, gate in ipairs(gates:GetChildren()) do gate.Color = color end end
	local territory = provinceFolder:FindFirstChild(name .. "_Territory")
	if territory then
		territory.Color = color:Lerp(Color3.fromRGB(92, 115, 80), 0.55)
		territory:SetAttribute("Owner", state.Owner)
	end
	updateStaticProvinceVisual(name)
end

for name in pairs(provinceStates) do
	updateStaticProvinceVisual(name)
end

local function gatePresence(provinceName)
	local model = provinceFolder:FindFirstChild(provinceName .. "_Castle")
	local gates = model and model:FindFirstChild("Gates")
	if not gates then return {}, 0, 0 end

	local presentTeams = {}
	local activeArmies = {}
	for _, gate in ipairs(gates:GetChildren()) do
		for _, army in pairs(armies) do
			if ArmyService.IsAlive(army) and (army.Position - gate.Position).Magnitude <= 14 then
				presentTeams[army.Team] = true
				activeArmies[army.Id] = army
			end
		end
	end

	local activeTeam = 0
	local teamCount = 0
	for team in pairs(presentTeams) do
		teamCount += 1
		activeTeam = team
	end
	return presentTeams, activeTeam, teamCount
end

local function captureTick(dt)
	for name, state in pairs(provinceStates) do
		local castle = state.Castle
		if castle then
			local _, activeTeam, teamCount = gatePresence(name)
			local attackerPower, defenderPower = 0, 0

			local model = provinceFolder:FindFirstChild(name .. "_Castle")
			local gates = model and model:FindFirstChild("Gates")
			if gates then
				for _, gate in ipairs(gates:GetChildren()) do
					for _, army in pairs(armies) do
						if ArmyService.IsAlive(army) and (army.Position - gate.Position).Magnitude <= 14 then
							ArmyService.RefreshAggregate(army, SoldierService)
							if army.Team == castle.Owner then
								defenderPower += army.Power
							else
								attackerPower += army.Power
							end
						end
					end
				end
			end

			if teamCount > 1 then
				castle.State = "Contested"
				castle.CaptureProgress = math.max(0, castle.CaptureProgress - Config.Game.CaptureDecayPerSecond * dt)
			elseif teamCount == 1 and activeTeam ~= castle.Owner then
				if castle.Garrison > 0 then
					CastleService.ApplyAssault(castle, attackerPower / math.max(1, 1 + defenderPower * 0.02), dt)
					castle.State = "Assaulted"
					local bestTarget = nil
					for _, army in pairs(armies) do
						if ArmyService.IsAlive(army) and army.Team == activeTeam then
							if not bestTarget or army.SoldierCount < bestTarget.SoldierCount then
								bestTarget = army
							end
						end
					end
					if bestTarget then
						local targetSoldier = nil
						for _, soldier in pairs(bestTarget.Soldiers or {}) do
							if SoldierService.IsAlive(soldier) and (not targetSoldier or soldier.Health < targetSoldier.Health) then
								targetSoldier = soldier
							end
						end
						if targetSoldier then
							local damage = CastleService.GetGarrisonFireDamage(castle, bestTarget.Power)
							local killed = SoldierService.ApplyDamage(targetSoldier, damage)
							ArmyService.RefreshAggregate(bestTarget, SoldierService)
							vfxRemote:FireAllClients("CastleHit", bestTarget.Position, castle.Garrison <= 0, killed)
							if killed then
								makeArmyVisual(bestTarget)
							else
								syncArmyVisual(bestTarget)
							end
						end
					end
					for _, army in pairs(armies) do
						if ArmyService.IsAlive(army) and army.Team == activeTeam then
							for _, soldier in pairs(army.Soldiers) do
								if SoldierService.IsAlive(soldier) then
									soldier.Morale = math.max(0, soldier.Morale - 0.35 * dt)
								end
							end
							ArmyService.RefreshAggregate(army, SoldierService)
						end
					end
				else
					castle.State = "Assaulted"
					local oldOwner = castle.Owner
					local captured = CastleService.AdvanceCapture(
						castle,
						activeTeam,
						dt,
						Config.Game.CaptureSeconds,
						Config.Game.CaptureDecayPerSecond,
						Config
					)
					state.CaptureTeam = castle.AssaultTeam
					state.CaptureProgress = castle.CaptureProgress
					if captured then
						state.Owner = activeTeam
						state.CaptureTeam = 0
						state.CaptureProgress = 0
						updateProvinceVisual(name)
						provinceCaptureEvent:Fire(name, activeTeam, oldOwner)
						vfxRemote:FireAllClients("CastleCaptured", model and model:GetPivot().Position or Vector3.zero, activeTeam, true)
					end
				end
			elseif teamCount == 1 and activeTeam == castle.Owner then
				castle.State = "Safe"
				castle.AssaultTeam = 0
				castle.CaptureProgress = 0
			else
				CastleService.TickRecovery(castle, dt, Config)
				state.CaptureTeam = castle.AssaultTeam
				state.CaptureProgress = castle.CaptureProgress
			end

			if model then
				model:SetAttribute("CastleState", castle.State)
				model:SetAttribute("Garrison", math.floor(castle.Garrison))
				model:SetAttribute("CaptureTeam", castle.AssaultTeam or 0)
			end
		end
	end
end

local function moveArmy(army, target)
	local flatTarget = Vector3.new(target.X, ARMY_Y, target.Z)
	if (flatTarget - army.Position).Magnitude > WORLD_HALF_EXTENT * 1.6 then return false end
	if math.abs(flatTarget.X) > WORLD_HALF_EXTENT - 8 or math.abs(flatTarget.Z) > WORLD_HALF_EXTENT - 8 then return false end
	army.TargetPosition = flatTarget
	army.AttackTarget = nil
	if army.Order ~= "Retreat" then
		army.Order = "Move"
	end
	army.CombatState = "Searching"
	return true
end

local function removeArmy(id)
	local army = armies[id]
	if not army then return end
	if army.Model then army.Model:Destroy() end
	if army.Owner and playerSelectedArmy[army.Owner] == army.Id then
		playerSelectedArmy[army.Owner] = nil
	end
	armies[id] = nil
end


local function countHumanPlayersOnTeam(teamId)
	local count = 0
	for _, player in ipairs(Players:GetPlayers()) do
		if findTeamForPlayer(player) == teamId then count += 1 end
	end
	return count
end

local function clearBots()
	for teamId, bot in pairs(botByTeam) do
		for id, army in pairs(armies) do
			if army.Owner == bot then
				removeArmy(id)
			end
		end
		botByTeam[teamId] = nil
	end
	for id in pairs(botCommanders) do
		botCommanders[id] = nil
	end
end

local function ensureBotCommanders()
	clearBots()
	for teamId = 1, activeTeamCount do
		if countHumanPlayersOnTeam(teamId) == 0 then
			local difficulty = teamId == 1 and "Veteran" or (teamId % 3 == 0 and "Warlord" or "Recruit")
			local spawn = selectedMap.Spawns[teamId] or Vector3.new(0, ARMY_Y, 0)
			local bot = BotCommanderService.Create(teamId, teamId, difficulty, spawn)
			botCommanders[teamId] = bot
			botByTeam[teamId] = bot
		end
	end

	for teamId, bot in pairs(botByTeam) do
		bot.State = "Recruiting"
		local armyType = BotCommanderService.ChooseRecruitment(teamSupplies[teamId] or 0, 0, bot.Difficulty)
		if armyType then
			local army = createArmyForOwner(bot, teamId, armyType, bot.SpawnPosition)
			if army then
				bot.ArmyIds[army.Id] = true
				bot.State = "Idle"
			end
		end
	end

	workspace:SetAttribute("KC_BotsReady", true)
end

local function removeDeadBotArmyRefs()
	for _, bot in pairs(botByTeam) do
		for armyId in pairs(bot.ArmyIds) do
			if not armies[armyId] then
				bot.ArmyIds[armyId] = nil
			end
		end
	end
end

local function nearestEnemyStrength(bot, position)
	local strength = 0
	for _, army in pairs(armies) do
		if army.Team ~= bot.Team and ArmyService.IsAlive(army) then
			local distance = (army.Position - position).Magnitude
			if distance < 80 then
				strength += BotCommanderService.GetArmyStrength(army) * (1 - distance / 80)
			end
		end
	end
	return strength
end

local function botThink(bot, now, dt)
	if not BotCommanderService.IsHealthy(bot) then return end
	bot.ThinkAccumulator += dt
	local profile = BotCommanderService.GetProfile(bot.Difficulty)
	if bot.ThinkAccumulator < profile.ThinkSeconds then return end
	bot.ThinkAccumulator = 0

	removeDeadBotArmyRefs()

	local armyCount = 0
	for armyId in pairs(bot.ArmyIds) do
		if armies[armyId] and ArmyService.IsAlive(armies[armyId]) then armyCount += 1 end
	end

	local bestProvince, bestScore = BotCommanderService.FindBestProvince(bot, provinceStates, selectedMap, armies, now)
	if not bestProvince then
		bot.State = "Idle"
		return
	end

	local targetData = selectedMap.Provinces[bestProvince]
	local targetState = provinceStates[bestProvince]

	local chosenArmy = BotCommanderService.ChooseArmyForObjective(bot, targetData.Position, armies)
	local enemyThreat = nearestEnemyStrength(bot, targetData.Position)

	if not chosenArmy then
		bot.State = "Recruiting"
		local recruitType = BotCommanderService.ChooseRecruitment(teamSupplies[bot.Team] or 0, armyCount, bot.Difficulty)
		if recruitType then
			local army = createArmyForOwner(bot, bot.Team, recruitType, bot.SpawnPosition)
			if army then
				bot.ArmyIds[army.Id] = true
				bot.State = "Marching"
			end
		end
		return
	end

	if BotCommanderService.ShouldRetreat(chosenArmy, enemyThreat) then
		chosenArmy.Order = "Retreat"
		chosenArmy.CombatState = "Retreating"
		chosenArmy.TargetPosition = chosenArmy.FallbackPosition or bot.SpawnPosition
		bot.State = "Retreating"
		bot.LastAction = "Retreat"
		return
	end

	if targetState.Owner == bot.Team and enemyThreat > BotCommanderService.GetArmyStrength(chosenArmy) * 1.15 then
		chosenArmy.Order = "Hold"
		chosenArmy.TargetPosition = chosenArmy.Position
		bot.State = "Defending"
		bot.LastAction = "Defend " .. bestProvince
		return
	end

	chosenArmy.Formation = BotCommanderService.ChooseFormation(chosenArmy, "Spearmen", bot.Difficulty)
	chosenArmy.TargetPosition = targetData.Position
	chosenArmy.Order = targetState.Owner ~= bot.Team and "Attack" or "Move"
	chosenArmy.CombatState = "Approaching"
	bot.ObjectiveId = bestProvince
	bot.State = targetState.Owner ~= bot.Team and "Attacking" or "Marching"
	bot.LastAction = (chosenArmy.Order == "Attack" and "Attack " or "Move ") .. bestProvince
end


local function firstAliveSoldier(army)
	local chosen = nil
	for _, soldier in pairs(army.Soldiers or {}) do
		if SoldierService.IsAlive(soldier) then
			if not chosen or soldier.Health < chosen.Health then
				chosen = soldier
			end
		end
	end
	return chosen
end

local function chooseRangedSoldier(army)
	local chosen = nil
	for _, soldier in pairs(army.Soldiers or {}) do
		if SoldierService.IsAlive(soldier) and (not chosen or soldier.Accuracy > chosen.Accuracy) then
			chosen = soldier
		end
	end
	return chosen
end

local function beginRetreat(army)
	army.Order = "Retreat"
	army.CombatState = "Retreating"
	army.AttackTarget = nil
	army.TargetPosition = army.FallbackPosition or army.Position
	for _, soldier in pairs(army.Soldiers or {}) do
		if SoldierService.IsAlive(soldier) then
			soldier.Morale = math.min(100, soldier.Morale + 1.5)
		end
	end
end

local function resolveArmyAttack(army, target, dt)
	local info = Config.ArmyTypes[army.Type]
	if not info or not ArmyService.IsAlive(target) then return false end

	ArmyService.RefreshAggregate(army, SoldierService)
	ArmyService.RefreshAggregate(target, SoldierService)

	local terrain = CombatService.GetTerrainModifiers(army.Position, terrainZones)
	local range = CombatService.GetAttackRange(army, info, Config, terrain.Range)
	local distance = (army.Position - target.Position).Magnitude

	if distance > range then
		army.TargetPosition = target.Position
		army.CombatState = "Approaching"
		return false
	end

	army.TargetPosition = army.Position
	army.CombatState = CombatService.IsRanged(army) and "Ranged" or "Engaging"
	army._cooldown = (army._cooldown or 0) - dt
	if army._cooldown > 0 then return false end

	local defender = firstAliveSoldier(target)
	local attackerSoldier = CombatService.IsRanged(army) and chooseRangedSoldier(army) or firstAliveSoldier(army)
	if not defender or not attackerSoldier then return false end

	local hitChance = CombatService.GetHitChance(army, target, attackerSoldier, terrain.Range)
	local rng = Random.new(attackerSoldier.PersonalitySeed + math.floor(os.clock() * 30) + army.Id)
	if rng:NextNumber() > hitChance then
		SoldierService.AddFatigue(attackerSoldier, CombatService.IsRanged(army) and 0.45 or 0.7)
		army._cooldown = ArmyService.GetAttackCooldown(info, army.Morale, army.Fatigue)
		if CombatService.IsRanged(army) then
			vfxRemote:FireAllClients("ArrowMiss", army.Position, target.Position, army.Team)
		else
			vfxRemote:FireAllClients("Melee", target.Position, army.Type, false)
		end
		return true
	end

	local formationMultiplier = CombatService.GetFormationModifier(army.Formation, "Attack")
	local damage = CombatService.GetBaseDamage(army, target, attackerSoldier, formationMultiplier, defender.Defense)
	if CombatService.IsRanged(army) then
		damage *= Config.Combat.RangedDamageMultiplier
	end
	if army.Type == "Cavalry" then
		damage *= terrain.Cavalry
	end

	local killed = SoldierService.ApplyDamage(defender, damage)
	attackerSoldier.Experience += killed and 2 or 0.5
	SoldierService.AddFatigue(attackerSoldier, CombatService.IsRanged(army) and 0.55 or 0.85)

	if killed then
		for _, soldier in pairs(target.Soldiers or {}) do
			if SoldierService.IsAlive(soldier) then
				soldier.Morale = math.max(0, soldier.Morale - 3.2)
			end
		end
	end

	ArmyService.RefreshAggregate(army, SoldierService)
	ArmyService.RefreshAggregate(target, SoldierService)

	if CombatService.IsRanged(army) then
		vfxRemote:FireAllClients("Arrow", army.Position, target.Position, army.Team, killed)
	else
		vfxRemote:FireAllClients("Melee", target.Position, army.Type, killed)
	end

	army._cooldown = ArmyService.GetAttackCooldown(info, army.Morale, army.Fatigue)

	if target.SoldierCount <= 0 then
		removeArmy(target.Id)
	else
		if killed then
			makeArmyVisual(target)
		else
			syncArmyVisual(target)
		end
	end
	return true
end

local function attackTick(dt)
	for _, army in pairs(armies) do
		if ArmyService.IsAlive(army) then
			ArmyService.RefreshAggregate(army, SoldierService)

			if CombatService.GetRetreatThreshold(army, Config) and army.Order ~= "Retreat" then
				beginRetreat(army)
			end

			if army.Order == "Retreat" then
				if (army.Position - (army.FallbackPosition or army.Position)).Magnitude <= 4 then
					army.CombatState = "Recovering"
					army.TargetPosition = army.Position
				else
					army.CombatState = "Retreating"
				end
			else
				local target = armies[army.AttackTarget]
				if not target or not ArmyService.IsAlive(target) then
					target = CombatService.ChooseTarget(army, armies, SoldierService, Config)
					if target then
						army.AttackTarget = target.Id
						army.Order = "Attack"
					end
				end

				if target then
					resolveArmyAttack(army, target, dt)
				else
					army.CombatState = "Searching"
				end
			end
		end
	end
end

commandRemote.OnServerEvent:Connect(function(player, action, payload)
	if type(action) ~= "string" or type(payload) ~= "table" then return end
	local valid, reason = StateSchemas.ValidateArmyCommand(action, payload, Config)
	if not valid then
		feedbackRemote:FireClient(player, "COMMAND_REJECTED", {Reason = reason})
		return
	end
	if not RateLimiter.Allow("KCCommand", player.UserId, 1, 24) then return end
	if action == "Ping" then
		if not RateLimiter.Allow("KCPing", player.UserId, 1, 2) then return end
		local now = os.clock()
		if now - (pingCooldown[player] or 0) < 0.8 then return end
		local p = payload.Position
		if typeof(p) == "Vector3" and (p - Vector3.new(0,0,0)).Magnitude < 400 then
			pingCooldown[player] = now
			vfxRemote:FireAllClients("Ping", p, findTeamForPlayer(player), payload.Kind or "ATTACK")
		end
		return
	end
	if action == "RequestArmy" then
		local armyType = payload.ArmyType
		if type(armyType) ~= "string" then return end
		local army, reason = createArmy(player, armyType)
		if not army then
			feedbackRemote:FireClient(player, "ARMY_FAILED", {Reason = reason or "UNAVAILABLE"})
		end
		return
	end

	if action == "RecruitSoldier" then
		local id = tonumber(payload.ArmyId)
		local army = id and armyOwnedBy(player, id)
		if not army then
			feedbackRemote:FireClient(player, "ARMY_FAILED", {Reason = "ARMY_NOT_FOUND"})
			return
		end
		local ok, result = addSoldierToArmy(player, army, army.Type)
		if not ok then
			feedbackRemote:FireClient(player, "ARMY_FAILED", {Reason = result})
		end
		return
	end

	if action == "SelectArmy" then
		local id = tonumber(payload.ArmyId)
		if id and armyOwnedBy(player, id) then playerSelectedArmy[player] = id end
		return
	end

	local id = tonumber(payload.ArmyId)
	local army = id and armyOwnedBy(player, id)
	if not army then return end

	if action == "Move" then
		local p = payload.Position
		if typeof(p) == "Vector3" and p.X == p.X and p.Y == p.Y and p.Z == p.Z then
			if moveArmy(army, p) then army.Order = "Move" end
		end
	elseif action == "Hold" then
		army.TargetPosition = army.Position
		army.AttackTarget = nil
		army.Order = "Hold"
	elseif action == "Formation" then
		if RateLimiter.Allow("KCFormation", player.UserId, 1, 6) and Config.Formations[payload.Formation] then
			army.Formation = payload.Formation
			syncArmyVisual(army)
		end
	elseif action == "Attack" then
		local targetId = tonumber(payload.TargetArmyId)
		local target = targetId and armies[targetId]
		if target and target.Team ~= army.Team and target.Model and target.Model.Parent then
			army.AttackTarget = target.Id
			army.Order = "Attack"
		end
	end
end)

local function publicArmyState(army)
	return {
		Id = army.Id,
		Team = army.Team,
		OwnerUserId = army.Owner.UserId,
		Type = army.Type,
		Position = army.Position,
		TargetPosition = army.TargetPosition,
		Formation = army.Formation,
		Order = army.Order or "Hold",
		AttackTarget = army.AttackTarget,
		CombatState = army.CombatState or "Searching",
		Health = army.Health,
		MaxHealth = army.MaxHealth,
		SoldierCount = army.SoldierCount or 0,
		Power = army.Power or 0,
		Defense = army.Defense or 0,
		Morale = army.Morale or 0,
		Fatigue = army.Fatigue or 0,
		Experience = army.Experience or 0,
	}
end

requestState.OnServerInvoke = function(player)
	local states = {}
	for name, state in pairs(provinceStates) do
		states[name] = {
			Owner = state.Owner,
			CaptureTeam = state.CaptureTeam,
			CaptureProgress = state.CaptureProgress,
			Income = state.Income,
		}
	end

	local publicArmies = {}
	for id, army in pairs(armies) do
		if ArmyService.IsAlive(army) then
			publicArmies[tostring(id)] = publicArmyState(army)
		end
	end

	return {
		Team = findTeamForPlayer(player),
		TeamCount = activeTeamCount,
		MapId = selectedMap.Name,
		TotalProvinces = #selectedMap.ProvinceOrder,
		Supplies = teamSupplies[findTeamForPlayer(player)],
		Provinces = states,
		SelectedArmy = playerSelectedArmy[player] or 0,
		Armies = publicArmies,
		Bots = (function()
			local result = {}
			for teamId, bot in pairs(botByTeam) do
				result[tostring(teamId)] = {Team=bot.Team, Name=bot.Name, Difficulty=bot.Difficulty, State=bot.State, LastAction=bot.LastAction, ObjectiveId=bot.ObjectiveId}
			end
			return result
		end)(),
		Castles = (function()
			local result = {}
			for name, province in pairs(provinceStates) do
				if province.Castle then result[name] = CastleService.PublicState(province.Castle) end
			end
			return result
		end)(),
	}
end

local function publishState()
	for _, player in ipairs(Players:GetPlayers()) do
		local team = findTeamForPlayer(player)
		local owned = 0
		local capture = {}
		for name, state in pairs(provinceStates) do
			if state.Owner == team then owned += 1 end
			capture[name] = {
				Owner = state.Owner,
				CaptureTeam = state.CaptureTeam,
				CaptureProgress = state.CaptureProgress,
			}
		end

		local publicArmies = {}
		for id, army in pairs(armies) do
			if ArmyService.IsAlive(army) then
				publicArmies[tostring(id)] = publicArmyState(army)
			end
		end

		stateRemote:FireClient(player, {
			Team = team,
			Supplies = teamSupplies[team],
			Owned = owned,
			TeamCount = activeTeamCount,
			MapId = selectedMap.Name,
			TotalProvinces = #selectedMap.ProvinceOrder,
			MapNodes = mapNodes,
			MapEdges = selectedMap.Edges or {},
			Provinces = capture,
			SelectedArmy = playerSelectedArmy[player] or 0,
			Armies = publicArmies,
			Bots = (function()
				local result = {}
				for teamId, bot in pairs(botByTeam) do
					result[tostring(teamId)] = {Team=bot.Team, Name=bot.Name, Difficulty=bot.Difficulty, State=bot.State, LastAction=bot.LastAction, ObjectiveId=bot.ObjectiveId}
				end
				return result
			end)(),
			Castles = (function()
				local result = {}
				for name, province in pairs(provinceStates) do
					if province.Castle then result[name] = CastleService.PublicState(province.Castle) end
				end
				return result
			end)(),
		})
	end
end

local function finishMatch(winner, reason)
	if matchEnded then return end
	matchEnded = true
	workspace:SetAttribute("MatchActive", false)
	local duration = matchStartedAt > 0 and math.floor(os.clock() - matchStartedAt) or 0
	local ownership = {}
	for name, state in pairs(provinceStates) do
		ownership[name] = state.Owner
	end
	matchResultEvent:Fire(winner, reason, duration, ownership)
	for _, p in ipairs(Players:GetPlayers()) do
		stateRemote:FireClient(p, {MatchOver=true, Team=findTeamForPlayer(p), Winner=winner, Reason=reason, Duration=duration, MapId=selectedMap.Name})
	end
end

Players.PlayerRemoving:Connect(function(player)
	local toRemove = {}
	for id, army in pairs(armies) do
		if army.Owner == player then table.insert(toRemove, id) end
	end
	for _, id in ipairs(toRemove) do removeArmy(id) end
	playerSelectedArmy[player] = nil
end)

local function setupPlayer(player)
	assignTeam(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(0.2)
		-- The lobby owns pre-match spawning. Stage 1 only moves characters into
		-- their battlefield spawn after the server explicitly activates a match.
		if workspace:GetAttribute("MatchActive") == true then
			characterSpawn(player, character)
			if not playerSelectedArmy[player] then
				createArmy(player, "Spearmen")
			end
		end
	end)
	if player.Character and workspace:GetAttribute("MatchActive") == true then
		characterSpawn(player, player.Character)
		if not playerSelectedArmy[player] then
			createArmy(player, "Spearmen")
		end
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerAdded:Connect(function(player)
	setupPlayer(player)
	startMatchClock()
end)

task.spawn(function()
	while true do
		for team = 1, activeTeamCount do
			local income = 0
			for _, state in pairs(provinceStates) do
				if state.Owner == team then
					income += state.Income
				end
			end
			teamSupplies[team] += math.floor(income / 6)
		end
		task.wait(Config.Game.EconomyTickSeconds)
	end
end)

local broadcastClock = 0
local captureClock = 0
local attackClock = 0
local resultClock = 0
local soldierClock = 0
local botClock = 0

RunService.Heartbeat:Connect(function(dt)
	captureClock += dt
	attackClock += dt
	broadcastClock += dt
	soldierClock += dt
	botClock += dt

	for _, army in pairs(armies) do
		local info = Config.ArmyTypes[army.Type]
		local distance = (army.TargetPosition - army.Position).Magnitude
		if distance > 0.5 and ArmyService.IsAlive(army) then
			local step = ArmyService.GetMovementSpeed(info, terrainMultiplier(army.Position), army.Morale, army.Fatigue) * dt
			local nextPos = distance <= step and army.TargetPosition or army.Position:Lerp(army.TargetPosition, step / math.max(distance, 0.001))
			army.Position = Vector3.new(nextPos.X, ARMY_Y, nextPos.Z)
		end
	end


	if soldierClock >= 0.25 then
		for _, army in pairs(armies) do
			if ArmyService.IsAlive(army) then
				local moving = (army.TargetPosition - army.Position).Magnitude > 0.5
				for _, soldier in pairs(army.Soldiers) do
					if SoldierService.IsAlive(soldier) then
						if moving then
							SoldierService.AddFatigue(soldier, 0.45 * soldierClock)
						else
							SoldierService.Recover(soldier, 0.7 * soldierClock)
						end
					end
				end
				ArmyService.RefreshAggregate(army, SoldierService)
				syncArmyVisual(army)
			end
		end
		soldierClock = 0
	end

	if captureClock >= 0.25 then
		captureTick(captureClock)
		captureClock = 0
	end
	if attackClock >= 0.1 then
		attackTick(attackClock)
		attackClock = 0
	end
	if broadcastClock >= math.max(0.25, Config.Game.StateBroadcastSeconds) then
		publishState()
		broadcastClock = 0
	end

	if botClock >= 0.2 and workspace:GetAttribute("MatchActive") == true then
		local now = os.clock()
		for _, bot in pairs(botByTeam) do
			botThink(bot, now, botClock)
		end
		botClock = 0
	end

	if not matchEnded and matchStartedAt > 0 then
		resultClock += dt
		if resultClock >= 1 then
			resultClock = 0
			local ownedCounts = {}
			for teamId = 1, activeTeamCount do ownedCounts[teamId] = 0 end
			for _, state in pairs(provinceStates) do if ownedCounts[state.Owner] ~= nil then ownedCounts[state.Owner] += 1 end end
			local target = MatchService.GetVictoryTarget(#selectedMap.ProvinceOrder, selectedMap.VictoryRatio or Config.Game.VictoryRatio)
			for teamId = 1, activeTeamCount do
				if ownedCounts[teamId] >= target then finishMatch(teamId, "territory_victory"); break end
			end
			if not matchEnded and os.clock() - matchStartedAt >= Config.Game.MatchLengthSeconds then
				local winner, best = 0, -1
				for teamId = 1, activeTeamCount do if ownedCounts[teamId] > best then winner, best = teamId, ownedCounts[teamId] elseif ownedCounts[teamId] == best then winner = 0 end end
				finishMatch(winner, winner == 0 and "draw_time_limit" or "time_limit")
			end
		end
	end
end)

workspace:GetAttributeChangedSignal("MatchActive"):Connect(function()
	if workspace:GetAttribute("MatchActive") == true then
		startMatchClock()
		for _, player in ipairs(Players:GetPlayers()) do
			assignTeam(player)
			if player.Character then
				characterSpawn(player, player.Character)
			end
			if not playerSelectedArmy[player] then
				createArmy(player, "Spearmen")
			end
		end
		ensureBotCommanders()
	else
		matchStartedAt = 0
		matchEnded = false
		clearBots()
		workspace:SetAttribute("KC_BotsReady", false)
		for id, army in pairs(armies) do
			if army.Model then army.Model:Destroy() end
			armies[id] = nil
		end
		for team = 1, activeTeamCount do
			teamSupplies[team] = 60
		end
		nextArmyId = 0
		for name, state in pairs(provinceStates) do
			state.CaptureTeam = 0
			state.CaptureProgress = 0
			state.IncomeStartAt = 0
			state.Owner = initialOwner(selectedMap.Provinces[name])
			local tier = selectedMap.Provinces[name].Capital and "Capital" or (selectedMap.Provinces[name].Strategic and "Major" or "Regional")
			state.Castle = CastleService.Create(name, tier, state.Owner, Config)
			updateProvinceVisual(name)
		end
		for player in pairs(playerSelectedArmy) do
			playerSelectedArmy[player] = nil
		end
	end
end)
if workspace:GetAttribute("MatchActive") == true then
	startMatchClock()
	for _, player in ipairs(Players:GetPlayers()) do
		assignTeam(player)
		if not playerSelectedArmy[player] then createArmy(player, "Spearmen") end
	end
	ensureBotCommanders()
end

print("[KingdomsConquest] Stage 1/2 authoritative runtime initialized.")