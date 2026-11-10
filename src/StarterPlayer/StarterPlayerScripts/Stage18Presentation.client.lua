-- Kingdoms Conquest — Stage 18 world presentation layer
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local remotes = ReplicatedStorage:WaitForChild("KingdomsRemotes", 15)
if not remotes then return end

local vfxRemote = remotes:WaitForChild("VFX", 8)
local feedbackRemote = remotes:WaitForChild("Feedback", 8)
if not vfxRemote then return end

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local TEAM_COLORS = {}
for teamId, info in pairs(Config.Teams or {}) do
	TEAM_COLORS[teamId] = info.Color
end

local trackedCastles = {}
local trackedArmies = {}
local lastAudioAt = {}
local lastDustAt = {}
local lastUpdate = 0

local function teamColor(teamId)
	return TEAM_COLORS[tonumber(teamId) or 0] or Color3.fromRGB(210, 194, 158)
end

local function isGameplayProxy(instance)
	local gameplayRoot = Workspace:FindFirstChild("KingdomsConquest")
	return gameplayRoot and instance:IsDescendantOf(gameplayRoot) == true
end

local function normalizeSoundId(value)
	if type(value) ~= "string" or value == "" then return nil end
	if string.find(value, "rbxassetid://", 1, true) then
		return value
	end
	if tonumber(value) then
		return "rbxassetid://" .. value
	end
	return value
end

local function playOptionalAudio(kind, volume, cooldown)
	local attributes = Config.Stage18 and Config.Stage18.OptionalAudioAttributes
	local attributeName = attributes and attributes[kind]
	if not attributeName then return end

	local soundId = normalizeSoundId(Workspace:GetAttribute(attributeName))
	if not soundId then return end

	local now = os.clock()
	local minimumGap = cooldown or 0.2
	if now - (lastAudioAt[kind] or 0) < minimumGap then return end
	lastAudioAt[kind] = now

	local sound = Instance.new("Sound")
	sound.Name = "KC_Stage18_" .. tostring(kind)
	sound.SoundId = soundId
	sound.Volume = volume or 0.35
	sound.PlaybackSpeed = 0.97 + math.random() * 0.06
	sound.RollOffMaxDistance = 180
	sound.Parent = SoundService
	sound:Play()
	Debris:AddItem(sound, 4)
end

local function makeBurst(position, size, color)
	local pulse = Instance.new("Part")
	pulse.Name = "KC_Stage18_Pulse"
	pulse.Shape = Enum.PartType.Ball
	pulse.Size = Vector3.new(1, 1, 1)
	pulse.Position = position + Vector3.new(0, 0.8, 0)
	pulse.Anchored = true
	pulse.CanCollide = false
	pulse.CanTouch = false
	pulse.CanQuery = false
	pulse.Material = Enum.Material.Neon
	pulse.Color = color
	pulse.Transparency = 0.12
	pulse.Parent = Workspace

	TweenService:Create(
		pulse,
		TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = Vector3.new(size, size, size), Transparency = 1}
	):Play()
	Debris:AddItem(pulse, 0.5)
end

local function makeRing(position, color)
	local ring = Instance.new("Part")
	ring.Name = "KC_Stage18_TerritoryPulse"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.22, 1.6, 1.6)
	ring.CFrame = CFrame.new(position + Vector3.new(0, 0.25, 0))
	ring.Anchored = true
	ring.CanCollide = false
	ring.CanTouch = false
	ring.CanQuery = false
	ring.Material = Enum.Material.Neon
	ring.Color = color
	ring.Transparency = 0.18
	ring.Parent = Workspace

	TweenService:Create(
		ring,
		TweenInfo.new((Config.Stage18 and Config.Stage18.CapturePulseSeconds) or 0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = Vector3.new(0.22, 18, 18), Transparency = 1}
	):Play()
	Debris:AddItem(ring, 1.0)
end

local function spawnDust(position, amount, scale, cooldownKey)
	local count = math.clamp(amount or 3, 2, 5)
	local now = os.clock()
	local key = cooldownKey or tostring(position)
	if now - (lastDustAt[key] or 0) < ((Config.Stage18 and Config.Stage18.DustInterval) or 0.75) then
		return
	end
	lastDustAt[key] = now

	for index = 1, count do
		local dust = Instance.new("Part")
		dust.Name = "KC_Stage18_Dust"
		dust.Shape = Enum.PartType.Ball
		local size = (0.35 + math.random() * 0.35) * (scale or 1)
		dust.Size = Vector3.new(size, size, size)
		dust.Position = position + Vector3.new(
			(math.random() - 0.5) * 2.2,
			0.25 + math.random() * 0.35,
			(math.random() - 0.5) * 2.2
		)
		dust.Anchored = true
		dust.CanCollide = false
		dust.CanTouch = false
		dust.CanQuery = false
		dust.Material = Enum.Material.Sand
		dust.Color = Color3.fromRGB(157, 137, 103)
		dust.Transparency = 0.25
		dust.Parent = Workspace

		TweenService:Create(
			dust,
			TweenInfo.new(0.5 + math.random() * 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Position = dust.Position + Vector3.new(
					(math.random() - 0.5) * 1.5,
					0.8 + math.random() * 1.2,
					(math.random() - 0.5) * 1.5
				),
				Size = Vector3.new(size * 1.7, size * 1.7, size * 1.7),
				Transparency = 1,
			}
		):Play()
		Debris:AddItem(dust, 0.9)
	end
end

local function findProvinceTerritory(castle)
	local province = castle:GetAttribute("Province")
	if type(province) ~= "string" then return nil end
	local container = castle.Parent
	if not container then return nil end
	return container:FindFirstChild(province .. "_Territory", true)
end

local function captureBannerColor(castle, owner)
	local color = teamColor(owner)
	local banner = castle:FindFirstChild("BannerCloth", true)
	if banner and banner:IsA("BasePart") then
		TweenService:Create(
			banner,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Color = color}
		):Play()
	end

	local gates = castle:FindFirstChild("Gates", true)
	if gates then
		for _, gate in ipairs(gates:GetChildren()) do
			if gate:IsA("BasePart") then
				TweenService:Create(
					gate,
					TweenInfo.new(0.35),
					{Color = color}
				):Play()
			end
		end
	end

	local territory = findProvinceTerritory(castle)
	if territory and territory:IsA("BasePart") then
		local base = territory.Color
		local flash = base:Lerp(color, 0.42)
		TweenService:Create(territory, TweenInfo.new(0.22), {Color = flash}):Play()
		task.delay(0.25, function()
			if territory.Parent then
				TweenService:Create(territory, TweenInfo.new(0.5), {
					Color = color:Lerp(Color3.fromRGB(92, 115, 80), 0.55)
				}):Play()
			end
		end)
	end

	local center = castle:GetPivot().Position
	makeRing(center, color)
	makeBurst(center + Vector3.new(0, 2, 0), 5.5, color)
	playOptionalAudio("CastleCaptured", 0.55, 1.0)
end

local function updateCastleCaptureVisual(castle)
	local state = tostring(castle:GetAttribute("CastleState") or "Safe")
	local garrison = tonumber(castle:GetAttribute("Garrison")) or 0
	local captureTeam = tonumber(castle:GetAttribute("CaptureTeam")) or 0

	local gates = castle:FindFirstChild("Gates", true)
	if gates then
		for _, gate in ipairs(gates:GetChildren()) do
			if gate:IsA("BasePart") then
				local contested = state == "Contested" or state == "Assaulted"
				gate.Material = contested and Enum.Material.Neon or Enum.Material.Neon
				gate.Transparency = contested and 0.08 or 0.38
				if captureTeam > 0 then
					gate.Color = teamColor(captureTeam)
				end
			end
		end
	end

	local keep = castle:FindFirstChild("Keep", true)
	if not keep or not keep:IsA("BasePart") then return end

	local progress = 0
	if state == "Assaulted" or state == "Contested" then
		local tier = tostring(castle:GetAttribute("CastleTier") or "Regional")
		local seconds = (Config.Game and Config.Game.CaptureSeconds) or 10
		local raw = tonumber(castle:GetAttribute("CaptureProgress")) or 0
		progress = math.clamp(raw / math.max(1, seconds), 0, 1)
		if state == "Assaulted" and garrison <= 0 then
			progress = math.max(progress, 0.12)
		end
		keep:SetAttribute("Stage18CaptureTier", tier)
	end

	local progressGui = keep:FindFirstChild("Stage18Capture")
	if not progressGui then
		progressGui = Instance.new("BillboardGui")
		progressGui.Name = "Stage18Capture"
		progressGui.Size = UDim2.fromOffset(150, 18)
		progressGui.StudsOffset = Vector3.new(0, keep.Size.Y * 0.55 + 4, 0)
		progressGui.AlwaysOnTop = true
		progressGui.MaxDistance = 180
		progressGui.Enabled = false
		progressGui.Parent = keep

		local bg = Instance.new("Frame")
		bg.Name = "Background"
		bg.BackgroundColor3 = Color3.fromRGB(40, 36, 31)
		bg.BorderSizePixel = 0
		bg.Size = UDim2.fromScale(1, 0.62)
		bg.Parent = progressGui

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.BackgroundColor3 = Color3.fromRGB(214, 175, 92)
		fill.BorderSizePixel = 0
		fill.Size = UDim2.fromScale(0, 1)
		fill.Parent = bg

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.BackgroundTransparency = 1
		label.Position = UDim2.fromScale(0, 0.64)
		label.Size = UDim2.fromScale(1, 0.55)
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.TextStrokeTransparency = 0.25
		label.TextColor3 = Color3.fromRGB(238, 224, 194)
		label.Parent = progressGui
	end

	progressGui.Enabled = progress > 0
	local bg = progressGui:FindFirstChild("Background")
	local fill = bg and bg:FindFirstChild("Fill")
	local label = progressGui:FindFirstChild("Label")
	if fill then
		fill.BackgroundColor3 = teamColor(captureTeam)
		TweenService:Create(fill, TweenInfo.new(0.12), {
			Size = UDim2.fromScale(progress, 1),
		}):Play()
	end
	if label then
		label.Text = progress > 0
			and string.format("%s  %d%%", state:upper(), math.floor(progress * 100))
			or ""
	end
end

local function trackCastle(model)
	if not model:IsA("Model") or isGameplayProxy(model) then return end
	if model:GetAttribute("Stage16ArtReady") ~= true then return end
	if model:GetAttribute("CastleTier") == nil then return end
	if trackedCastles[model] then return end

	local pole = model:FindFirstChild("HeroBannerPole", true)
	local cloth = model:FindFirstChild("BannerCloth", true)
	if not pole or not cloth or not pole:IsA("BasePart") or not cloth:IsA("BasePart") then
		return
	end

	local relative = pole.CFrame:ToObjectSpace(cloth.CFrame)
	trackedCastles[model] = {
		Pole = pole,
		Cloth = cloth,
		Relative = relative,
		Phase = math.random() * math.pi * 2,
		LastOwner = tonumber(model:GetAttribute("Owner")) or 0,
		LastState = tostring(model:GetAttribute("CastleState") or "Safe"),
	}

	updateCastleCaptureVisual(model)

	model:GetAttributeChangedSignal("Owner"):Connect(function()
		local state = trackedCastles[model]
		if not state then return end
		local owner = tonumber(model:GetAttribute("Owner")) or 0
		if owner ~= state.LastOwner then
			state.LastOwner = owner
			captureBannerColor(model, owner)
		end
	end)

	model:GetAttributeChangedSignal("CastleState"):Connect(function()
		local state = trackedCastles[model]
		if not state then return end
		local nextState = tostring(model:GetAttribute("CastleState") or "Safe")
		if nextState ~= state.LastState then
			state.LastState = nextState
			if nextState == "Contested" then
				playOptionalAudio("CastleContested", 0.32, 0.8)
			end
		end
		updateCastleCaptureVisual(model)
	end)

	model:GetAttributeChangedSignal("Garrison"):Connect(function()
		updateCastleCaptureVisual(model)
	end)
	model:GetAttributeChangedSignal("CaptureTeam"):Connect(function()
		updateCastleCaptureVisual(model)
	end)
end

local function trackArmy(model)
	if not model:IsA("Model") or not isGameplayProxy(model) then return end
	if model:GetAttribute("Stage16ArtReady") ~= true then return end
	local armyId = model:GetAttribute("ArmyId")
	if armyId == nil or trackedArmies[model] then return end

	local banner = model:FindFirstChild("ArmyBanner")
	local pole = banner and banner:FindFirstChild("Pole")
	local pennant = banner and banner:FindFirstChild("Pennant")
	local accent = banner and banner:FindFirstChild("PennantAccent")
	local anchor = model:FindFirstChild("ArmyAnchor")
	if not banner or not pole or not pennant or not pole:IsA("BasePart") or not pennant:IsA("BasePart") then
		return
	end

	trackedArmies[model] = {
		ArmyId = armyId,
		Pole = pole,
		Pennant = pennant,
		Accent = accent,
		PennantRelative = pole.CFrame:ToObjectSpace(pennant.CFrame),
		AccentRelative = accent and pole.CFrame:ToObjectSpace(accent.CFrame) or nil,
		Phase = math.random() * math.pi * 2,
		LastPosition = anchor and anchor.Position or model:GetPivot().Position,
	}
end

local function discover()
	for _, instance in ipairs(Workspace:GetDescendants()) do
		if instance:IsA("Model") then
			trackCastle(instance)
			trackArmy(instance)
		end
	end
end

discover()

Workspace.DescendantAdded:Connect(function(instance)
	if instance:IsA("Model") then
		task.defer(function()
			trackCastle(instance)
			trackArmy(instance)
		end)
	end
end)

Workspace.DescendantRemoving:Connect(function(instance)
	trackedCastles[instance] = nil
	trackedArmies[instance] = nil
	if trackedArmies[instance] then
		lastDustAt[instance] = nil
	end
end)

if feedbackRemote then
	feedbackRemote.OnClientEvent:Connect(function(kind)
		if kind == "ARMY_CREATED" or kind == "SOLDIER_RECRUITED" then
			playOptionalAudio("Selection", 0.12, 0.2)
		elseif kind == "REMATCH_ACCEPTED" then
			playOptionalAudio("Command", 0.16, 0.35)
		end
	end)
end

vfxRemote.OnClientEvent:Connect(function(kind, position, teamOrType, defeated)
	if typeof(position) ~= "Vector3" then return end

	if kind == "CastleCaptured" then
		local color = teamColor(teamOrType)
		makeRing(position, color)
		makeBurst(position + Vector3.new(0, 1.5, 0), 6, color)
		spawnDust(position, 5, 1.25)
		playOptionalAudio("CastleCaptured", 0.55, 1.0)
	elseif kind == "CastleHit" then
		makeBurst(position, defeated and 4.5 or 2.6, Color3.fromRGB(225, 188, 103))
		playOptionalAudio("BattleImpact", 0.16, 0.18)
	elseif kind == "Arrow" then
		playOptionalAudio("BowRelease", 0.10, 0.12)
		if defeated then
			local impactPosition = typeof(teamOrType) == "Vector3" and teamOrType or position
			makeBurst(impactPosition, 3.2, Color3.fromRGB(220, 187, 119))
			playOptionalAudio("BattleImpact", 0.16, 0.18)
		end
	elseif kind == "Melee" then
		makeBurst(position, defeated and 3.8 or 2.2, Color3.fromRGB(205, 201, 184))
		playOptionalAudio("MeleeImpact", 0.12, 0.12)
		if defeated then
			playOptionalAudio("ArmyDestroyed", 0.18, 0.4)
		end
	end
end)

RunService.RenderStepped:Connect(function()
	local now = os.clock()
	local dt = now - lastUpdate
	lastUpdate = now

	for model, state in pairs(trackedCastles) do
		if not model.Parent or not state.Pole.Parent or not state.Cloth.Parent then
			trackedCastles[model] = nil
		else
			local point = state.Pole.Position
			if camera and (camera.CFrame.Position - point).Magnitude <= 450 then
				local swayDegrees = Config.Stage18.BannerSwayDegrees or 4.5
				local speed = Config.Stage18.BannerSwaySpeed or 2
				local sway = math.sin(now * speed + state.Phase) * math.rad(swayDegrees)
				state.Cloth.CFrame = state.Pole.CFrame
					* state.Relative
					* CFrame.Angles(0, 0, sway)
			end
			if dt >= 0.08 then
				updateCastleCaptureVisual(model)
			end
		end
	end

	for model, state in pairs(trackedArmies) do
		if not model.Parent or not state.Pole.Parent or not state.Pennant.Parent then
			trackedArmies[model] = nil
		else
			local swayDegrees = Config.Stage18.BannerSwayDegrees or 4.5
			local speed = Config.Stage18.BannerSwaySpeed or 2
			local sway = math.sin(now * speed + state.Phase) * math.rad(swayDegrees * 1.35)
			state.Pennant.CFrame = state.Pole.CFrame
				* state.PennantRelative
				* CFrame.Angles(0, 0, sway)
			if state.Accent and state.Accent.Parent and state.AccentRelative then
				state.Accent.CFrame = state.Pole.CFrame
					* state.AccentRelative
					* CFrame.Angles(0, 0, sway)
			end

			local position = state.Pole.Position
			if (position - state.LastPosition).Magnitude > 0.8 then
				spawnDust(position + Vector3.new(0, 0.15, 0), 2, 0.8, model)
				state.LastPosition = position
			end
		end
	end
end)
