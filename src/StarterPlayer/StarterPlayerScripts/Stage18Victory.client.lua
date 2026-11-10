-- Kingdoms Conquest — Stage 18 match result and rematch presentation
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage.Shared.Config)
local remotes = ReplicatedStorage:WaitForChild("KingdomsRemotes", 15)
if not remotes then return end

local stateRemote = remotes:WaitForChild("State", 8)
local commandRemote = remotes:WaitForChild("Command", 8)
local feedbackRemote = remotes:WaitForChild("Feedback", 8)
if not stateRemote or not commandRemote then return end

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "KingdomsStage18Results"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 140
gui.Enabled = false
gui.Parent = player:WaitForChild("PlayerGui")

local backdrop = Instance.new("Frame")
backdrop.BackgroundColor3 = Color3.fromRGB(18, 17, 14)
backdrop.BackgroundTransparency = 0.18
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.Parent = gui

local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.5)
card.Size = UDim2.new(0.86, 0, 0.72, 0)
card.BackgroundColor3 = Color3.fromRGB(38, 34, 28)
card.BackgroundTransparency = 0.05
card.BorderSizePixel = 0
card.Parent = backdrop
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(201, 174, 116)
stroke.Transparency = 0.25
stroke.Thickness = 2
stroke.Parent = card

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromScale(0.06, 0.08)
title.Size = UDim2.fromScale(0.88, 0.16)
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(236, 222, 190)
title.TextStrokeTransparency = 0.2
title.Parent = card

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromScale(0.07, 0.23)
subtitle.Size = UDim2.fromScale(0.86, 0.08)
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextScaled = true
subtitle.TextColor3 = Color3.fromRGB(203, 193, 171)
subtitle.Parent = card

local summary = Instance.new("TextLabel")
summary.BackgroundTransparency = 1
summary.Position = UDim2.fromScale(0.08, 0.34)
summary.Size = UDim2.fromScale(0.84, 0.34)
summary.Font = Enum.Font.Gotham
summary.TextSize = 20
summary.TextWrapped = true
summary.TextXAlignment = Enum.TextXAlignment.Left
summary.TextYAlignment = Enum.TextYAlignment.Top
summary.TextColor3 = Color3.fromRGB(226, 217, 197)
summary.Parent = card

local rematch = Instance.new("TextButton")
rematch.Text = "REMATCH  •  مباراة جديدة"
rematch.Font = Enum.Font.GothamBold
rematch.TextScaled = true
rematch.TextColor3 = Color3.fromRGB(30, 28, 24)
rematch.BackgroundColor3 = Color3.fromRGB(218, 183, 106)
rematch.AutoButtonColor = true
rematch.Size = UDim2.new(0.38, 0, 0.11, 0)
rematch.Position = UDim2.fromScale(0.09, 0.80)
rematch.Parent = card
Instance.new("UICorner", rematch).CornerRadius = UDim.new(0, 10)

local closeButton = Instance.new("TextButton")
closeButton.Text = "CLOSE  •  إغلاق"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.TextColor3 = Color3.fromRGB(228, 219, 198)
closeButton.BackgroundColor3 = Color3.fromRGB(73, 64, 53)
closeButton.AutoButtonColor = true
closeButton.Size = UDim2.new(0.38, 0, 0.11, 0)
closeButton.Position = UDim2.fromScale(0.53, 0.80)
closeButton.Parent = card
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 10)

local function playResultSound(winner, team)
	local attributes = Config.Stage18 and Config.Stage18.OptionalAudioAttributes
	local key = winner == team and "Victory" or (winner == 0 and "Command" or "Defeat")
	local attributeName = attributes and attributes[key]
	local soundId = attributeName and workspace:GetAttribute(attributeName)
	if type(soundId) ~= "string" or soundId == "" then return end
	if not string.find(soundId, "rbxassetid://", 1, true) and tonumber(soundId) then
		soundId = "rbxassetid://" .. soundId
	end

	local sound = Instance.new("Sound")
	sound.Name = "KC_Stage18_Result"
	sound.SoundId = soundId
	sound.Volume = 0.5
	sound.Parent = SoundService
	sound:Play()
	Debris:AddItem(sound, 5)
end

local function openResult(payload)
	local team = tonumber(payload.Team) or 0
	local winner = tonumber(payload.Winner) or 0
	local summaryData = payload.Summary or {}

	local outcome
	if winner == team then
		outcome = "VICTORY  •  النصر"
	elseif winner == 0 then
		outcome = "DRAW  •  تعادل"
	else
		outcome = "DEFEAT  •  الهزيمة"
	end

	title.Text = outcome
	subtitle.Text = string.format(
		"%s  •  %s  •  %ds",
		tostring(payload.MapId or "MAP"),
		winner == 0 and "DRAW" or ("TEAM " .. tostring(winner)),
		tonumber(payload.Duration) or 0
	)

	summary.Text = string.format(
		"Territory  •  %d\n"
			.. "Surviving Armies  •  %d\n"
			.. "Surviving Soldiers  •  %d\n"
			.. "Field Reward  •  %d XP\n"
			.. "Gold  •  %d    Supplies  •  %d\n\n"
			.. "الإقليم  •  %d\n"
			.. "الجيوش الباقية  •  %d\n"
			.. "الجنود الباقون  •  %d",
		tonumber(summaryData.Territories) or 0,
		tonumber(summaryData.SurvivingArmies) or 0,
		tonumber(summaryData.SurvivingSoldiers) or 0,
		tonumber(summaryData.FieldReward) or 0,
		tonumber(summaryData.Gold) or 0,
		tonumber(summaryData.Supplies) or 0,
		tonumber(summaryData.Territories) or 0,
		tonumber(summaryData.SurvivingArmies) or 0,
		tonumber(summaryData.SurvivingSoldiers) or 0
	)

	gui.Enabled = true
	card.Position = UDim2.fromScale(0.5, 0.56)
	TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.5),
	}):Play()

	playResultSound(winner, team)
end

local function closeResult()
	gui.Enabled = false
end

rematch.Activated:Connect(function()
	if workspace:GetAttribute("MatchActive") == true then return end
	commandRemote:FireServer("Rematch", {})
end)

closeButton.Activated:Connect(closeResult)

if feedbackRemote then
	feedbackRemote.OnClientEvent:Connect(function(kind)
		if kind == "REMATCH_ACCEPTED" then
			closeResult()
		end
	end)
end

stateRemote.OnClientEvent:Connect(function(payload)
	if type(payload) ~= "table" then return end
	if payload.MatchOver == true then
		openResult(payload)
	end
end)

workspace:GetAttributeChangedSignal("MatchActive"):Connect(function()
	if workspace:GetAttribute("MatchActive") == true then
		closeResult()
	end
end)
