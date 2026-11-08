-- Kingdoms Conquest — Static World Regions Runtime
-- Static prefabs are the source of truth. Runtime only adds interaction.
local Workspace = game:GetService("Workspace")

local MAPS = {
    {Id = "Syria", Display = "SYRIA", Color = Color3.fromRGB(112, 142, 94)},
    {Id = "SaudiArabia", Display = "SAUDI ARABIA", Color = Color3.fromRGB(185, 145, 70)},
    {Id = "Palestine", Display = "PALESTINE", Color = Color3.fromRGB(126, 104, 82)},
    {Id = "Europe", Display = "EUROPE", Color = Color3.fromRGB(85, 118, 101)},
}

local function getMap(id)
    return Workspace:FindFirstChild("Map_" .. id)
end

local function getLobby()
    return Workspace:FindFirstChild("KingdomsLobbyEntrance")
end

local function addPrompt(part, actionText, objectText, callback, holdDuration)
    if not part or not part:IsA("BasePart") then return nil end
    local prompt = part:FindFirstChild("TravelPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.Name = "TravelPrompt"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
        prompt.HoldDuration = holdDuration or 0.15
        prompt.MaxActivationDistance = 14
        prompt.RequiresLineOfSight = false
        prompt.Style = Enum.ProximityPromptStyle.Default
        prompt.Parent = part
    end
    prompt.ActionText = actionText
    prompt.ObjectText = objectText
    if not prompt:GetAttribute("KCBound") then
        prompt:SetAttribute("KCBound", true)
        prompt.Triggered:Connect(function(player)
            if Workspace:GetAttribute("MatchActive") == true then return end
            callback(player)
        end)
    end
    return prompt
end

local function addRegionHeader(part, title, subtitle)
    if not part or not part:IsA("BasePart") or part:FindFirstChild("RegionHeader") then return end
    local gui = Instance.new("BillboardGui")
    gui.Name = "RegionHeader"
    gui.Size = UDim2.fromOffset(190, 54)
    gui.StudsOffset = Vector3.new(0, 6, 0)
    gui.AlwaysOnTop = false
    gui.MaxDistance = 110
    gui.Parent = part

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.fromScale(1, 0.6)
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextScaled = true
    titleLabel.TextColor3 = Color3.fromRGB(239, 226, 193)
    titleLabel.TextStrokeTransparency = 0.35
    titleLabel.Text = title
    titleLabel.Parent = gui

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Position = UDim2.fromScale(0, 0.6)
    subtitleLabel.Size = UDim2.fromScale(1, 0.32)
    subtitleLabel.Font = Enum.Font.GothamMedium
    subtitleLabel.TextScaled = true
    subtitleLabel.TextColor3 = Color3.fromRGB(190, 186, 172)
    subtitleLabel.Text = subtitle
    subtitleLabel.Parent = gui
end

local function teleportTo(player, destination)
    local character = player.Character
    if not character or not destination then return end
    character:PivotTo(destination.CFrame + Vector3.new(0, 4, 0))
end

-- Lobby portals: one prompt per portal, no stacked floating travel labels.
local lobby = getLobby()
if lobby then
    for _, mapInfo in ipairs(MAPS) do
        local portal = lobby:FindFirstChild("Portal_" .. mapInfo.Id, true)
        local destinationMap = getMap(mapInfo.Id)
        local destination = destinationMap and destinationMap:FindFirstChild("VisitorSpawn", true)
        if portal and destination then
            addPrompt(portal, "Travel", mapInfo.Display, function(player)
                teleportTo(player, destination)
            end, 0.15)
        end
    end
end

-- World regions: clean arrival point, one return prompt, and three travel prompts.
for _, mapInfo in ipairs(MAPS) do
    local map = getMap(mapInfo.Id)
    if map then
        local visitor = map:FindFirstChild("VisitorSpawn", true)
        local back = map:FindFirstChild("ReturnToLobby", true)
        if visitor then
            addRegionHeader(visitor, mapInfo.Display, "WORLD REGION")
        end

        if back and lobby then
            local lobbySpawn = lobby:FindFirstChild("KingdomsLobbySpawnLocation", true) or lobby:FindFirstChild("LobbySpawn", true)
            addPrompt(back, "Return", "KINGDOMS LOBBY", function(player)
                teleportTo(player, lobbySpawn)
            end, 0.15)
        end

        -- Remove any stale runtime travel pads from older builds.
        for _, child in ipairs(map:GetChildren()) do
            if child:IsA("BasePart") and child.Name:match("^TravelTo_") then
                child:Destroy()
            end
        end

        local offsets = {
            Vector3.new(-18, 0, 16),
            Vector3.new(0, 0, 20),
            Vector3.new(18, 0, 16),
        }

        local slot = 0
        for _, targetInfo in ipairs(MAPS) do
            if targetInfo.Id ~= mapInfo.Id then
                slot += 1
                local targetMap = getMap(targetInfo.Id)
                local destination = targetMap and targetMap:FindFirstChild("VisitorSpawn", true)
                if visitor and destination then
                    local pad = Instance.new("Part")
                    pad.Name = "TravelTo_" .. targetInfo.Id
                    pad.Size = Vector3.new(7, 1, 7)
                    pad.Position = visitor.Position + offsets[slot]
                    pad.Anchored = true
                    pad.CanCollide = false
                    pad.Transparency = 0.18
                    pad.Material = Enum.Material.Slate
                    pad.Color = targetInfo.Color
                    pad.Parent = map
                    addPrompt(pad, "Travel", targetInfo.Display, function(player)
                        teleportTo(player, destination)
                    end, 0.15)
                end
            end
        end
    end
end

print("[KingdomsConquest] Static world regions loaded: Lobby + Syria + Saudi Arabia + Palestine + Europe")
