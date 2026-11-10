-- Kingdoms Conquest — Stage 14 bot runtime gate
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local BotCommanderService = require(script.Parent.Services.BotCommanderService)

local valid = true
local difficulties = (Config.Bots and Config.Bots.Difficulties) or {"Recruit", "Veteran", "Warlord"}

for _, difficulty in ipairs(difficulties) do
    local profile = BotCommanderService.GetProfile(difficulty)
    if type(profile) ~= "table" or (profile.ThinkSeconds or 0) <= 0 then
        valid = false
        warn("[KingdomsConquest][Stage14] invalid bot difficulty: " .. tostring(difficulty))
    end
end

local probe = BotCommanderService.Create(999, 2, "Veteran", Vector3.new(0, 3, 0))
valid = valid and BotCommanderService.IsHealthy(probe)
valid = valid and (probe.UserId or 0) < 0
valid = valid and type(probe.ArmyIds) == "table"

workspace:SetAttribute("KC_Stage14Ready", valid)
workspace:SetAttribute("KC_Stage14Studio", RunService:IsStudio())

print(string.format(
    "[KingdomsConquest][Stage14] bot commander system %s | studio=%s",
    valid and "ready" or "FAILED",
    tostring(RunService:IsStudio())
))
