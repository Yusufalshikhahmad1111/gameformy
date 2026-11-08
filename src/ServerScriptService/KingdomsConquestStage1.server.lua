-- Kingdoms Conquest — Stage 1 Graybox Vertical Slice
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage.Shared.Config)
local RateLimiter = require(ReplicatedStorage.Shared.RateLimiter)
local MapService = require(ReplicatedStorage.Shared.MapService)

if workspace:GetAttribute("KC_BootstrapReady") ~= true then
	workspace:GetAttributeChangedSignal("KC_BootstrapReady"):Wait()
end

local remotes = ReplicatedStorage:FindFirstChild("KingdomsRemotes")
if remotes then remotes:Destroy() end
remotes = Instance.new("Folder")
remotes.Name = "KingdomsRemotes"
remotes.Parent = ReplicatedStorage

local commandRemote = Instance.new("RemoteEvent")
commandRemote.Name = "Command"
commandRemote.Parent = remotes

local vfxRemote = Instance.new("UnreliableRemoteEvent")
vfxRemote.Name = "VFX"
vfxRemote.Parent = remotes

local stateRemote = Instance.new("RemoteEvent")
stateRemote.Name = "State"
stateRemote.Parent = remotes

local requestState = Instance.new("RemoteFunction")
requestState.Name = "RequestState"
requestState.Parent = remotes

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

local teamObjects = {}
local teamSupplies = {}
for teamId = 1, activeTeamCount do teamSupplies[teamId] = 60 end
local armies = {}
local playerSelectedArmy = {}
local nextArmyId = 0
local pingCooldown = {}
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
	provinceStates[name] = {Owner=initialOwner(data), CaptureTeam=0, CaptureProgress=0, Income=data.Income, Strategic=data.Strategic}
end

local WORLD_HALF_EXTENT = 350
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
	makePart(model, "Courtyard", data.Capital and Vector3.new(56, 2, 48) or Vector3.new(44, 2, 38), base + Vector3.new(0, 2, 0), art.Stone or Color3.fromRGB(112, 108, 99), Enum.Material.Cobblestone)
	makePart(model, "Keep", data.Capital and Vector3.new(22, 24, 22) or Vector3.new(18, 18, 18), base + Vector3.new(0, data.Capital and 14 or 11, 0), art.DarkStone or Color3.fromRGB(82, 82, 80), Enum.Material.Slate)

	local wallY = base.Y + (data.Capital and 7 or 6)
	makePart(model, "WallNorth", Vector3.new(58, 10, 3), base + Vector3.new(0, wallY, -28), art.Stone or Color3.fromRGB(104, 101, 95), Enum.Material.Cobblestone)
	makePart(model, "WallSouth", Vector3.new(58, 10, 3), base + Vector3.new(0, wallY, 28), Color3.fromRGB(104, 101, 95), Enum.Material.Cobblestone)
	makePart(model, "WallEast", Vector3.new(3, 10, 58), base + Vector3.new(28, wallY, 0), Color3.fromRGB(104, 101, 95), Enum.Material.Cobblestone)
	makePart(model, "WallWest", Vector3.new(3, 10, 58), base + Vector3.new(-28, wallY, 0), Color3.fromRGB(104, 101, 95), Enum.Material.Cobblestone)

	local banner = makePart(model, "Banner", Vector3.new(1.5, 12, 1.5), base + Vector3.new(0, data.Capital and 22 or 16, -10), ownerColor(initialOwner(data)), Enum.Material.Wood)
	banner.CanCollide = false
	addBillboard(banner, (data.CityName or provinceName) .. "  •  " .. castleTier, ownerColor(initialOwner(data)))

	local gates = Instance.new("Folder")
	gates.Name = "Gates"
	gates.Parent = model
	local gateDistance = data.Capital and 39 or 33
	local gateOffsets = {
		North = Vector3.new(0, 1.5, -gateDistance),
		East = Vector3.new(gateDistance, 1.5, 0),
		South = Vector3.new(0, 1.5, gateDistance),
		West = Vector3.new(-gateDistance, 1.5, 0),
	}
	for gateName, offset in pairs(gateOffsets) do
		local gate = makePart(gates, gateName, Vector3.new(16, 1, 16), base + offset, ownerColor(initialOwner(data)), Enum.Material.Neon)
		gate.Transparency = 0.78
		gate.CanCollide = false
		gate:SetAttribute("Gate", gateName)
		gate:SetAttribute("Province", provinceName)
	end
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

local function characterSpawn(player, character)
	local number = findTeamForPlayer(player)
	local spawnPart = spawnFolder:FindFirstChild("Team" .. number)
	if spawnPart then
		character:PivotTo(spawnPart.CFrame + Vector3.new(0, 4, 0))
	end
end

local function formationOffset(formation, index)
	local offsets = {
		Line = {Vector3.new(-6,0,-3),Vector3.new(-2,0,-3),Vector3.new(2,0,-3),Vector3.new(6,0,-3),Vector3.new(-4,0,2),Vector3.new(0,0,2),Vector3.new(4,0,2),Vector3.new(8,0,2)},
		Wedge = {Vector3.new(0,0,-6),Vector3.new(-3,0,-2),Vector3.new(3,0,-2),Vector3.new(-6,0,2),Vector3.new(0,0,2),Vector3.new(6,0,2),Vector3.new(-9,0,6),Vector3.new(9,0,6)},
		Column = {Vector3.new(0,0,-10),Vector3.new(0,0,-6),Vector3.new(0,0,-2),Vector3.new(0,0,2),Vector3.new(0,0,6),Vector3.new(0,0,10),Vector3.new(0,0,14),Vector3.new(0,0,18)},
		Spread = {Vector3.new(-9,0,-5),Vector3.new(-3,0,-7),Vector3.new(3,0,-7),Vector3.new(9,0,-5),Vector3.new(-9,0,5),Vector3.new(-3,0,7),Vector3.new(3,0,7),Vector3.new(9,0,5)},
	}
	return offsets[formation] and offsets[formation][index] or offsets.Line[index]
end

local function makeArmyVisual(army)
	local model = Instance.new("Model")
	model.Name = "Army_" .. army.Id
	model.Parent = armyFolder
	model:SetAttribute("ArmyId", army.Id)
	model:SetAttribute("OwnerUserId", army.Owner.UserId)

	local color = ownerColor(army.Team)
	local rootPart = makePart(model, "Root", Vector3.new(4, 2, 4), army.Position, color, Enum.Material.SmoothPlastic)
	rootPart.Transparency = 0.35
	rootPart.CanCollide = false

	local offsets = {
		Vector3.new(-5,0,-3), Vector3.new(0,0,-3), Vector3.new(5,0,-3),
		Vector3.new(-3,0,0), Vector3.new(3,0,0),
		Vector3.new(-5,0,3), Vector3.new(0,0,3), Vector3.new(5,0,3),
	}
	local classInfo = Config.ArmyTypes[army.Type]
	for i = 1, #offsets do
		local offset = formationOffset(army.Formation, i)
		local unit = makePart(model, "Unit" .. i, Vector3.new(2.2, 3.6, 2.2), army.Position + offset, classInfo.Color, Enum.Material.SmoothPlastic)
		unit.CanCollide = false
		unit.Shape = Enum.PartType.Cylinder
		unit:SetAttribute("FormationIndex", i)
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ArmyLabel"
	billboard.Size = UDim2.fromOffset(180, 38)
	billboard.StudsOffset = Vector3.new(0, 7, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = rootPart
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1,1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.2
	label.Text = classInfo.Label
	label.Parent = billboard
	army.Model = model
end

local function syncArmyVisual(army)
	if not army.Model or not army.Model.Parent then return end
	local model = army.Model
	model:PivotTo(CFrame.new(army.Position))
	for _, unit in ipairs(model:GetChildren()) do
		local index = unit:GetAttribute("FormationIndex")
		if index then unit.Position = army.Position + formationOffset(army.Formation, index) end
	end
	local rootPart = model:FindFirstChild("Root")
	if rootPart then
		local label = rootPart:FindFirstChild("ArmyLabel")
		if label and label:FindFirstChildOfClass("TextLabel") then
			local hp = math.max(0, math.floor(army.Health))
			label:FindFirstChildOfClass("TextLabel").Text = Config.ArmyTypes[army.Type].Label .. "  " .. hp
		end
	end
end

local function createArmy(player, armyType)
	if workspace:GetAttribute("MatchActive") ~= true or matchEnded then return nil, "MATCH_NOT_ACTIVE" end
	local team = findTeamForPlayer(player)
	local info = Config.ArmyTypes[armyType]
	if not info or teamSupplies[team] < info.Cost then return nil, "INSUFFICIENT SUPPLIES" end
	teamSupplies[team] -= info.Cost
	nextArmyId += 1
	local spawnBase = selectedMap.Spawns[team] or Vector3.new(0, ARMY_Y, 0)
	local spawnPosition = Vector3.new(spawnBase.X, ARMY_Y, spawnBase.Z)
	local army = {
		Id = nextArmyId,
		Owner = player,
		Team = team,
		Type = armyType,
		Formation = "Line",
		Position = spawnPosition,
		TargetPosition = spawnPosition,
		Health = info.Health,
		MaxHealth = info.Health,
		AttackTarget = nil,
		Model = nil,
	}
	armies[army.Id] = army
	makeArmyVisual(army)
	playerSelectedArmy[player] = army.Id
	return army
end

local function armyOwnedBy(player, armyId)
	local army = armies[armyId]
	return army and army.Owner == player and army.Model and army.Model.Parent
end

local function playerRoot(player)
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
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
end

local function captureTick(dt)
	for name, state in pairs(provinceStates) do
		local model = provinceFolder:FindFirstChild(name .. "_Castle")
		local gates = model and model:FindFirstChild("Gates")
		if gates then
			local presentTeams = {}
			for _, gate in ipairs(gates:GetChildren()) do
				for _, player in ipairs(playersNearPosition(gate.Position, 9)) do
					presentTeams[findTeamForPlayer(player)] = true
				end
				for _, army in pairs(armies) do
					if (army.Position - gate.Position).Magnitude <= 12 then
						presentTeams[army.Team] = true
					end
				end
			end

			local activeTeam = 0
			local teamCount = 0
			for team in pairs(presentTeams) do
				teamCount += 1
				activeTeam = team
			end

			if teamCount == 1 then
				local teamIsAttacker = state.Owner == 0 or activeTeam ~= state.Owner
				if teamIsAttacker then
					if state.CaptureTeam ~= activeTeam then
						state.CaptureTeam = activeTeam
						state.CaptureProgress = 0
					end
					state.CaptureProgress += dt
					if state.CaptureProgress >= Config.Game.CaptureSeconds then
						local oldOwner = state.Owner
						state.Owner = activeTeam
						state.CaptureTeam = 0
						state.CaptureProgress = 0
						updateProvinceVisual(name)
						provinceCaptureEvent:Fire(name, activeTeam, oldOwner)
					end
				elseif state.CaptureProgress > 0 then
					state.CaptureProgress = math.max(0, state.CaptureProgress - Config.Game.CaptureDecayPerSecond * dt)
				end
			elseif teamCount > 1 then
				-- Contesting stops capture progress; it does not punish either side.
			elseif state.CaptureProgress > 0 then
				state.CaptureProgress = math.max(0, state.CaptureProgress - Config.Game.CaptureDecayPerSecond * dt)
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
	return true
end

local function removeArmy(id)
	local army = armies[id]
	if not army then return end
	if army.Model then army.Model:Destroy() end
	armies[id] = nil
end

local function attackTick(dt)
	for _, army in pairs(armies) do
		if army.AttackTarget then
			local target = armies[army.AttackTarget]
			if not target then
				army.AttackTarget = nil
			else
				local distance = (army.Position - target.Position).Magnitude
				local info = Config.ArmyTypes[army.Type]
				if distance <= info.AttackRange then
					army._cooldown = (army._cooldown or 0) - dt
					if army._cooldown <= 0 then
						local multiplier = 1
						if army.Type == "Spearmen" and target.Type == "Cavalry" then multiplier = 1.35 end
						if army.Type == "Cavalry" and target.Type == "Archers" then multiplier = 1.35 end
						if army.Type == "Archers" and target.Type == "Spearmen" then multiplier = 1.10 end
						target.Health -= info.Damage * multiplier
						vfxRemote:FireAllClients("Hit", target.Position, army.Type, target.Health <= 0)
						army._cooldown = info.AttackCooldown
						if target.Health <= 0 then removeArmy(target.Id) end
					end
				else
					army.TargetPosition = target.Position
				end
			end
		end
	end
end

commandRemote.OnServerEvent:Connect(function(player, action, payload)
	if type(action) ~= "string" or type(payload) ~= "table" then return end
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
		createArmy(player, armyType)
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
		if typeof(p) == "Vector3" and p.X == p.X and p.Y == p.Y and p.Z == p.Z then moveArmy(army, p) end
	elseif action == "Hold" then
		army.TargetPosition = army.Position
		army.AttackTarget = nil
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
		end
	end
end)

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
	return {
		Team = findTeamForPlayer(player),
		TeamCount = activeTeamCount,
		MapId = selectedMap.Name,
		TotalProvinces = #selectedMap.ProvinceOrder,
		Supplies = teamSupplies[findTeamForPlayer(player)],
		Provinces = states,
		SelectedArmy = playerSelectedArmy[player] or 0,
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
			MapNodes = mapNodes,
			MapEdges = selectedMap.Edges or {},
			SelectedArmy = playerSelectedArmy[player] or 0,
			Armies = (function()
				local result = {}
				for id, army in pairs(armies) do
					result[tostring(id)] = {Team=army.Team, OwnerUserId=army.Owner.UserId, Position=army.Position, Type=army.Type, Formation=army.Formation, Health=army.Health, MaxHealth=army.MaxHealth}
				end
				return result
			end)()
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
		characterSpawn(player, character)
		if workspace:GetAttribute("MatchActive") == true and not playerSelectedArmy[player] then
			createArmy(player, "Spearmen")
		end
	end)
	if player.Character then
		characterSpawn(player, player.Character)
		if workspace:GetAttribute("MatchActive") == true and not playerSelectedArmy[player] then
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

RunService.Heartbeat:Connect(function(dt)
	captureClock += dt
	attackClock += dt
	broadcastClock += dt

	for _, army in pairs(armies) do
		local info = Config.ArmyTypes[army.Type]
		local distance = (army.TargetPosition - army.Position).Magnitude
		if distance > 0.5 then
			local step = info.MoveSpeed * terrainMultiplier(army.Position) * dt
			local nextPos = distance <= step and army.TargetPosition or army.Position:Lerp(army.TargetPosition, step / distance)
			army.Position = Vector3.new(nextPos.X, ARMY_Y, nextPos.Z)
			syncArmyVisual(army)
		end
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

	if not matchEnded and matchStartedAt > 0 then
		resultClock += dt
		if resultClock >= 1 then
			resultClock = 0
			local ownedCounts = {}
			for teamId = 1, activeTeamCount do ownedCounts[teamId] = 0 end
			for _, state in pairs(provinceStates) do if ownedCounts[state.Owner] ~= nil then ownedCounts[state.Owner] += 1 end end
			local target = math.max(1, math.ceil(#selectedMap.ProvinceOrder * (selectedMap.VictoryRatio or Config.Game.VictoryRatio)))
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

workspace:GetAttributeChangedSignal("MatchActive"):Connect(startMatchClock)
if workspace:GetAttribute("MatchActive") == true then startMatchClock() end

print("[KingdomsConquest] Stage 1/2 authoritative runtime initialized.")