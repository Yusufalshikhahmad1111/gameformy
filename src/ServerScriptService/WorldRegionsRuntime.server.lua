-- Kingdoms Conquest — Static World Regions Runtime
-- The four maps and the lobby are editable Workspace prefabs. This script only
-- adds interaction, labels, and safe travel between them.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local MAPS = {
	Syria = "SYRIA",
	SaudiArabia = "SAUDI ARABIA",
	Palestine = "PALESTINE",
	Europe = "EUROPE",
}

local function addLabel(part, title, subtitle)
	if not part or not part:IsA("BasePart") or part:FindFirstChild("RegionLabel") then return end
	local gui = Instance.new("BillboardGui")
	gui.Name = "RegionLabel"
	gui.Size = UDim2.fromOffset(240, 70)
	gui.StudsOffset = Vector3.new(0, 6, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 500
	gui.Parent = part

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.fromScale(1, .58)
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = Color3.fromRGB(239, 226, 193)
	titleLabel.TextStrokeTransparency = .2
	titleLabel.Text = title
	titleLabel.Parent = gui

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.fromScale(0,.58)
	sub.Size = UDim2.fromScale(1,.35)
	sub.Font = Enum.Font.GothamMedium
	sub.TextScaled = true
	sub.TextColor3 = Color3.fromRGB(196,190,174)
	sub.Text = subtitle
	sub.Parent = gui
end

local function addTravelPrompt(part, actionText, objectText, callback)
	if not part or not part:IsA("BasePart") then return end
	local prompt = part:FindFirstChild("TravelPrompt")
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = "TravelPrompt"
		prompt.ActionText = actionText
		prompt.ObjectText = objectText
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
		prompt.HoldDuration = .15
		prompt.MaxActivationDistance = 18
		prompt.RequiresLineOfSight = false
		prompt.Parent = part
	end
	prompt.Triggered:Connect(function(player)
		if Workspace:GetAttribute("MatchActive") == true then return end
		callback(player)
	end)
end

local function teleportTo(player, destination)
	local character = player.Character
	if not character or not destination then return end
	character:PivotTo(destination.CFrame + Vector3.new(0,5,0))
end

local function prepareMap(mapId, display)
	local map = Workspace:FindFirstChild("Map_"..mapId)
	if not map then return end
	for _, castle in ipairs(map:GetChildren()) do
		if castle:IsA("Model") and castle.Name:sub(-7) == "_Castle" then
			local province = castle.Name:sub(1, #castle.Name - 7)
			castle:SetAttribute("Province", province)
			castle:SetAttribute("CityName", province)
			local keep = castle:FindFirstChild("Keep", true)
			if keep and not keep:FindFirstChild("CityLabel") then
				local gui = Instance.new("BillboardGui")
				gui.Name = "CityLabel"
				gui.Size = UDim2.fromOffset(180, 44)
				gui.StudsOffset = Vector3.new(0, 11, 0)
				gui.AlwaysOnTop = true
				gui.MaxDistance = 280
				gui.Parent = keep
				local label = Instance.new("TextLabel")
				label.BackgroundTransparency = 1
				label.Size = UDim2.fromScale(1,1)
				label.Font = Enum.Font.GothamBold
				label.TextScaled = true
				label.TextColor3 = Color3.fromRGB(239,226,193)
				label.TextStrokeTransparency = .25
				label.Text = province
				label.Parent = gui
			end
			local gates = castle:FindFirstChild("Gates", true)
			if gates then
				for _, gate in ipairs(gates:GetChildren()) do
					if gate:IsA("BasePart") then
						gate:SetAttribute("Province", province)
						gate:SetAttribute("Gate", gate.Name)
					end
				end
			end
		end
	end
end


-- Lobby -> any world.
local lobby = Workspace:FindFirstChild("KingdomsLobbyEntrance")
if lobby then
	for mapId, display in pairs(MAPS) do
		local portal = lobby:FindFirstChild("Portal_"..mapId, true)
		local map = Workspace:FindFirstChild("Map_"..mapId)
		local destination = map and map:FindFirstChild("VisitorSpawn", true)
		if portal and destination then
			addLabel(portal, display, "PRESS E • VISIT REGION")
			addTravelPrompt(portal, "Visit "..display, "World Region", function(player)
				teleportTo(player, destination)
			end)
		end
	end
end

-- World -> lobby and world -> world.
for mapId, display in pairs(MAPS) do
	prepareMap(mapId, display)
	local map = Workspace:FindFirstChild("Map_"..mapId)
	if map then
		local visitor = map:FindFirstChild("VisitorSpawn", true)
		local back = map:FindFirstChild("ReturnToLobby", true)
		if visitor then addLabel(visitor, display, "WORLD REGION • "..mapId) end
		if back and lobby then
			addLabel(back, "KINGDOMS LOBBY", "PRESS E • RETURN")
			local lobbySpawn = lobby:FindFirstChild("KingdomsLobbySpawnLocation", true) or lobby:FindFirstChild("LobbySpawn", true)
			addTravelPrompt(back, "Return to Lobby", "Kingdoms", function(player)
				teleportTo(player, lobbySpawn)
			end)
		end

		for otherId, otherDisplay in pairs(MAPS) do
			if otherId ~= mapId then
				local pad = Instance.new("Part")
				pad.Name = "TravelTo_"..otherId
				pad.Size = Vector3.new(8,1,8)
				pad.Position = (visitor and visitor.Position or Vector3.zero) + Vector3.new(0,0,14 + (table.find({"Syria","SaudiArabia","Palestine","Europe"}, otherId) or 1)*5)
				pad.Anchored = true
				pad.CanCollide = false
				pad.Transparency = .45
				pad.Material = Enum.Material.Neon
				pad.Color = Color3.fromRGB(218,177,82)
				pad.Parent = map
				addLabel(pad, otherDisplay, "PRESS E • TRAVEL")
				local otherMap = Workspace:FindFirstChild("Map_"..otherId)
				local destination = otherMap and otherMap:FindFirstChild("VisitorSpawn", true)
				if destination then
					addTravelPrompt(pad, "Travel to "..otherDisplay, "World Region", function(player)
						teleportTo(player, destination)
					end)
				end
			end
		end
	end
end

print("[KingdomsConquest] Static world regions loaded: Lobby + Syria + Saudi Arabia + Palestine + Europe")
