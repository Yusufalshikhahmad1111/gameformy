-- Kingdoms Conquest — Stage 12 Army Runtime Gate
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local StateSchemas = require(ReplicatedStorage.Shared.StateSchemas)
local ArmyService = require(script.Parent.Services.ArmyService)
local SoldierService = require(script.Parent.Services.SoldierService)

local valid = true
for armyType, definition in pairs(Config.ArmyTypes or {}) do
    if not ArmyService.IsValidType(Config, armyType) then
        valid = false
        warn("[KingdomsConquest][Stage12] invalid army type: " .. tostring(armyType))
    end
    if (tonumber(definition.InitialSoldiers) or 0) < 1 then
        valid = false
        warn("[KingdomsConquest][Stage12] no initial soldiers: " .. tostring(armyType))
    end
    if (tonumber(definition.MaxSoldiers) or 0) < (tonumber(definition.InitialSoldiers) or 0) then
        valid = false
        warn("[KingdomsConquest][Stage12] max soldiers below initial size: " .. tostring(armyType))
    end
end

local probe = SoldierService.Create(Config, {
    Id = "STAGE12-PROBE",
    ArmyId = 0,
    Role = "Spearmen",
    PersonalitySeed = 12012026,
})

valid = valid and SoldierService.IsAlive(probe) and (probe.Power or 0) > 0 and (probe.Morale or 0) > 0

workspace:SetAttribute("KC_Stage12Ready", valid)
workspace:SetAttribute("KC_Stage12StateSchemaVersion", StateSchemas.Version)
workspace:SetAttribute("KC_Stage12Studio", RunService:IsStudio())

print(string.format(
    "[KingdomsConquest][Stage12] army/soldier system %s | studio=%s | schema=v%d",
    valid and "ready" or "FAILED",
    tostring(RunService:IsStudio()),
    StateSchemas.Version
))
