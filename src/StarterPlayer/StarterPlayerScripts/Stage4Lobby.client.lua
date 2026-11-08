-- Kingdoms Conquest — Stage 4 Lobby / Party UI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Stage4Remotes")
local action = remotes:WaitForChild("Action")
local stateRemote = remotes:WaitForChild("State")
local requestState = remotes:WaitForChild("RequestState")

local gui = Instance.new("ScreenGui")
gui.Name = "KingdomsStage4Lobby"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 90
gui.Parent = player:WaitForChild("PlayerGui")

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(15, 18, 18)
backdrop.BackgroundTransparency = 0.12
backdrop.BorderSizePixel = 0
backdrop.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.58, 0.68)
panel.BackgroundColor3 = Color3.fromRGB(29, 34, 34)
panel.BorderSizePixel = 0
panel.Parent = backdrop
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 18)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(102, 94, 77)
stroke.Transparency = 0.35
stroke.Thickness = 1
stroke.Parent = panel

local function label(parent, text, pos, size, font, color)
	local x = Instance.new("TextLabel")
	x.BackgroundTransparency = 1
	x.Position = pos
	x.Size = size
	x.Font = font
	x.Text = text
	x.TextColor3 = color
	x.TextScaled = true
	x.Parent = parent
	return x
end

label(panel, "KINGDOMS CONQUEST", UDim2.fromScale(0.08, 0.07), UDim2.fromScale(0.84, 0.10), Enum.Font.GothamBold, Color3.fromRGB(238, 228, 205))
label(panel, "MULTIPLAYER COMMAND", UDim2.fromScale(0.08, 0.16), UDim2.fromScale(0.84, 0.06), Enum.Font.GothamMedium, Color3.fromRGB(173, 168, 156))

local partyText = label(panel, "NO PARTY", UDim2.fromScale(0.08, 0.27), UDim2.fromScale(0.84, 0.12), Enum.Font.GothamBold, Color3.fromRGB(218, 213, 202))
local memberText = label(panel, "", UDim2.fromScale(0.08, 0.40), UDim2.fromScale(0.84, 0.12), Enum.Font.Gotham, Color3.fromRGB(190, 188, 181))
local statusText = label(panel, "Connecting…", UDim2.fromScale(0.08, 0.54), UDim2.fromScale(0.84, 0.08), Enum.Font.GothamMedium, Color3.fromRGB(222, 191, 117))

local function button(text, pos, size, callback)
	local b = Instance.new("TextButton")
	b.Position = pos
	b.Size = size
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.TextColor3 = Color3.fromRGB(236, 230, 214)
	b.BackgroundColor3 = Color3.fromRGB(55, 61, 60)
	b.AutoButtonColor = true
	b.BorderSizePixel = 0
	b.Parent = panel
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
	b.MouseButton1Click:Connect(callback)
	return b
end

local createButton = button("CREATE PARTY", UDim2.fromScale(0.08, 0.66), UDim2.fromScale(0.26, 0.10), function()
	action:FireServer("CreateParty")
end)

local codeBox = Instance.new("TextBox")
codeBox.Position = UDim2.fromScale(0.37, 0.66)
codeBox.Size = UDim2.fromScale(0.26, 0.10)
codeBox.PlaceholderText = "6-digit code"
codeBox.Text = ""
codeBox.Font = Enum.Font.GothamBold
codeBox.TextScaled = true
codeBox.TextColor3 = Color3.fromRGB(237, 232, 220)
codeBox.BackgroundColor3 = Color3.fromRGB(46, 52, 51)
codeBox.BorderSizePixel = 0
codeBox.ClearTextOnFocus = false
codeBox.Parent = panel
Instance.new("UICorner", codeBox).CornerRadius = UDim.new(0, 10)

local joinButton = button("JOIN", UDim2.fromScale(0.66, 0.66), UDim2.fromScale(0.26, 0.10), function()
	action:FireServer("JoinParty", {Code = codeBox.Text})
end)

local queueButton = button("QUEUE MATCH", UDim2.fromScale(0.08, 0.79), UDim2.fromScale(0.26, 0.10), function()
	action:FireServer("Queue")
end)

local leaveButton = button("LEAVE", UDim2.fromScale(0.37, 0.79), UDim2.fromScale(0.26, 0.10), function()
	action:FireServer("LeaveParty")
end)

local practiceButton = button("PRACTICE", UDim2.fromScale(0.66, 0.79), UDim2.fromScale(0.26, 0.10), function()
	action:FireServer("StartPractice")
end)

local function render(s)
	if not s then return end
	statusText.Text = s.Status or "Lobby ready"
	backdrop.Visible = not s.MatchActive

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
	end
end

stateRemote.OnClientEvent:Connect(render)

local ok, state = pcall(function()
	return requestState:InvokeServer()
end)
if ok then render(state) end
