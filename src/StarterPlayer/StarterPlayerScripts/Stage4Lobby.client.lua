-- Kingdoms Conquest — Stage 10 Lobby / Party UI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local UITheme = require(ReplicatedStorage.Shared.UITheme)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Stage4Remotes")
local action = remotes:WaitForChild("Action")
local stateRemote = remotes:WaitForChild("State")
local requestState = remotes:WaitForChild("RequestState")

local isTouch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local gui = Instance.new("ScreenGui")
gui.Name = "KingdomsStage4Lobby"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 200
gui.Parent = player:WaitForChild("PlayerGui")

local backdrop = Instance.new("Frame")
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(12, 16, 15)
backdrop.BackgroundTransparency = 0.12
backdrop.BorderSizePixel = 0
backdrop.Parent = gui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = isTouch and UDim2.fromScale(0.92, 0.88) or UDim2.fromScale(0.78, 0.84)
panel.BackgroundColor3 = Color3.fromRGB(27, 32, 31)
panel.BorderSizePixel = 0
panel.Parent = backdrop
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 18)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(111, 101, 82)
stroke.Transparency = 0.22
stroke.Thickness = 1
stroke.Parent = panel

local function label(parent, value, pos, size, font, color)
    local x = Instance.new("TextLabel")
    x.BackgroundTransparency = 1
    x.Position = pos
    x.Size = size
    x.Font = font
    x.Text = value
    x.TextColor3 = color
    x.TextScaled = true
    x.TextWrapped = true
    x.Parent = parent
    return x
end

local function button(parent, value, pos, size, callback)
    local b = Instance.new("TextButton")
    b.Position = pos
    b.Size = size
    b.Text = value
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.TextWrapped = true
    b.TextColor3 = Color3.fromRGB(238, 232, 219)
    b.BackgroundColor3 = Color3.fromRGB(57, 63, 61)
    b.AutoButtonColor = true
    b.BorderSizePixel = 0
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.Activated:Connect(callback)
    return b
end

label(panel, "KINGDOMS CONQUEST", UDim2.fromScale(0.06, 0.045), UDim2.fromScale(0.88, 0.075), Enum.Font.GothamBold, Color3.fromRGB(239, 229, 207))
label(panel, "MULTIPLAYER COMMAND  •  CHOOSE YOUR BATTLEFIELD", UDim2.fromScale(0.06, 0.115), UDim2.fromScale(0.88, 0.045), Enum.Font.GothamMedium, Color3.fromRGB(173, 168, 156))

local selectedMap = "Syria"
local selectedTeams = 2

local mapLabel = label(panel, "BATTLEFIELD  •  SYRIA", UDim2.fromScale(0.06, 0.19), UDim2.fromScale(0.41, 0.055), Enum.Font.GothamBold, Color3.fromRGB(226, 194, 121))
local teamsLabel = label(panel, "TEAMS  •  2", UDim2.fromScale(0.53, 0.19), UDim2.fromScale(0.41, 0.055), Enum.Font.GothamBold, Color3.fromRGB(226, 194, 121))

local mapsFrame = Instance.new("Frame")
mapsFrame.BackgroundTransparency = 1
mapsFrame.Position = UDim2.fromScale(0.06, 0.255)
mapsFrame.Size = UDim2.fromScale(0.41, 0.225)
mapsFrame.Parent = panel

local teamsFrame = Instance.new("Frame")
teamsFrame.BackgroundTransparency = 1
teamsFrame.Position = UDim2.fromScale(0.53, 0.255)
teamsFrame.Size = UDim2.fromScale(0.41, 0.225)
teamsFrame.Parent = panel

local mapButtons = {
    {Id = "Syria", Text = "SYRIA"},
    {Id = "SaudiArabia", Text = "SAUDI"},
    {Id = "Palestine", Text = "PALESTINE"},
    {Id = "Europe", Text = "EUROPE"},
}

local mapDetails = {
    Syria = "LEVANT  •  12 CASTLES  •  MEDIUM",
    SaudiArabia = "ARABIAN PENINSULA  •  12 CASTLES  •  HARD",
    Palestine = "LEVANT  •  12 CASTLES  •  MEDIUM",
    Europe = "EUROPE  •  16 CASTLES  •  EXPERT",
}

local mapInfo = label(panel, mapDetails[selectedMap], UDim2.fromScale(0.06, 0.49), UDim2.fromScale(0.88, 0.045), Enum.Font.Gotham, Color3.fromRGB(181, 177, 166))

local mapButtonRefs = {}
for i, item in ipairs(mapButtons) do
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)
    local b = button(mapsFrame, item.Text,
        UDim2.fromScale(col * 0.52, row * 0.54),
        UDim2.fromScale(0.48, 0.44),
        function()
            selectedMap = item.Id
            mapLabel.Text = "BATTLEFIELD  •  " .. string.upper(item.Text)
            mapInfo.Text = mapDetails[item.Id] or "SELECTED BATTLEFIELD"
            action:FireServer("SetMap", {MapId = selectedMap, TeamCount = selectedTeams})
        end)
    mapButtonRefs[item.Id] = b
end

local teamButtonRefs = {}
for i = 2, 4 do
    local row = i - 2
    local b = button(teamsFrame, tostring(i) .. " TEAMS",
        UDim2.fromScale(0, row * 0.35),
        UDim2.fromScale(1, 0.28),
        function()
            selectedTeams = i
            teamsLabel.Text = "TEAMS  •  " .. tostring(i)
            action:FireServer("SetMap", {MapId = selectedMap, TeamCount = selectedTeams})
        end)
    teamButtonRefs[i] = b
end

local partySection = Instance.new("Frame")
partySection.Position = UDim2.fromScale(0.06, 0.555)
partySection.Size = UDim2.fromScale(0.88, 0.145)
partySection.BackgroundColor3 = Color3.fromRGB(35, 41, 40)
partySection.BorderSizePixel = 0
partySection.Parent = panel
Instance.new("UICorner", partySection).CornerRadius = UDim.new(0, 12)

local partyText = label(partySection, "NO PARTY", UDim2.fromScale(0.04, 0.10), UDim2.fromScale(0.92, 0.29), Enum.Font.GothamBold, Color3.fromRGB(224, 219, 205))
local memberText = label(partySection, "Create a party or join one with a 6-digit code.", UDim2.fromScale(0.04, 0.43), UDim2.fromScale(0.92, 0.24), Enum.Font.Gotham, Color3.fromRGB(189, 187, 180))
local statusText = label(partySection, "Lobby ready", UDim2.fromScale(0.04, 0.71), UDim2.fromScale(0.92, 0.18), Enum.Font.GothamMedium, Color3.fromRGB(226, 194, 121))

local actionsFrame = Instance.new("Frame")
actionsFrame.BackgroundTransparency = 1
actionsFrame.Position = UDim2.fromScale(0.06, 0.735)
actionsFrame.Size = UDim2.fromScale(0.88, 0.115)
actionsFrame.Parent = panel

local createButton = button(actionsFrame, "CREATE PARTY", UDim2.fromScale(0, 0), UDim2.fromScale(0.31, 0.88), function()
    action:FireServer("CreateParty")
end)

local codeBox = Instance.new("TextBox")
codeBox.Position = UDim2.fromScale(0.345, 0)
codeBox.Size = UDim2.fromScale(0.31, 0.88)
codeBox.PlaceholderText = "6-digit code"
codeBox.Text = ""
codeBox.Font = Enum.Font.GothamBold
codeBox.TextScaled = true
codeBox.TextColor3 = Color3.fromRGB(237, 232, 220)
codeBox.PlaceholderColor3 = Color3.fromRGB(157, 157, 151)
codeBox.BackgroundColor3 = Color3.fromRGB(47, 53, 52)
codeBox.BorderSizePixel = 0
codeBox.ClearTextOnFocus = false
codeBox.Parent = actionsFrame
Instance.new("UICorner", codeBox).CornerRadius = UDim.new(0, 10)

local joinButton = button(actionsFrame, "JOIN", UDim2.fromScale(0.69, 0), UDim2.fromScale(0.31, 0.88), function()
    action:FireServer("JoinParty", {Code = codeBox.Text})
end)

local bottomFrame = Instance.new("Frame")
bottomFrame.BackgroundTransparency = 1
bottomFrame.Position = UDim2.fromScale(0.06, 0.86)
bottomFrame.Size = UDim2.fromScale(0.88, 0.10)
bottomFrame.Parent = panel

local queueButton = button(bottomFrame, "QUEUE MATCH", UDim2.fromScale(0, 0), UDim2.fromScale(0.31, 0.88), function()
    action:FireServer("Queue")
end)

local leaveButton = button(bottomFrame, "LEAVE", UDim2.fromScale(0.345, 0), UDim2.fromScale(0.31, 0.88), function()
    action:FireServer("LeaveParty")
end)

local practiceButton = button(bottomFrame, "PRACTICE", UDim2.fromScale(0.69, 0), UDim2.fromScale(0.31, 0.88), function()
    action:FireServer("StartPractice")
end)

local function render(s)
    if not s then
        return
    end

    selectedMap = s.Party and s.Party.MapId or selectedMap
    selectedTeams = s.Party and s.Party.TeamCount or selectedTeams

    mapLabel.Text = "BATTLEFIELD  •  " .. string.upper(selectedMap)
    mapInfo.Text = mapDetails[selectedMap] or "SELECTED BATTLEFIELD"
    teamsLabel.Text = "TEAMS  •  " .. tostring(selectedTeams)
    statusText.Text = s.Status or "Lobby ready"

    local active = s.MatchActive == true
    backdrop.Visible = not active

    if active then
        return
    end

    if s.Party then
        partyText.Text = "PARTY  •  " .. tostring(s.Party.Code)
        local names = {}
        for _, member in ipairs(s.Party.Members or {}) do
            local crown = member.UserId == s.Party.LeaderUserId and " ★" or ""
            table.insert(names, member.Name .. crown .. (member.Online and "" or "  [offline]"))
        end
        memberText.Text = table.concat(names, "   •   ")
        queueButton.Text = s.Party.Queued and "SEARCHING…" or "QUEUE MATCH"
        leaveButton.Text = s.Party.Queued and "CANCEL QUEUE" or "LEAVE"
    else
        partyText.Text = "NO PARTY"
        memberText.Text = "Create a party or join one with a 6-digit code."
        queueButton.Text = "QUEUE MATCH"
        leaveButton.Text = "LEAVE"
    end
end

stateRemote.OnClientEvent:Connect(render)

local ok, state = pcall(function()
    return requestState:InvokeServer()
end)
if ok then
    render(state)
end
