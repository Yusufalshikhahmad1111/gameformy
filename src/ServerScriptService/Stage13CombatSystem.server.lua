-- Kingdoms Conquest — Stage 13 runtime gate
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local StateSchemas = require(ReplicatedStorage.Shared.StateSchemas)
local CombatService = require(script.Parent.Services.CombatService)
local CastleService = require(script.Parent.Services.CastleService)
local SoldierService = require(script.Parent.Services.SoldierService)

local valid = true

local attacker = {
    Type = "Archers",
    Formation = "Line",
    Morale = 90,
    Fatigue = 0,
    Position = Vector3.new(0, 0, 0),
    SoldierCount = 4,
    Power = 76,
    Health = 180,
    MaxHealth = 180,
}
local defender = {
    Type = "Spearmen",
    Formation = "Line",
    Morale = 90,
    Fatigue = 0,
    Position = Vector3.new(20, 0, 0),
    SoldierCount = 4,
    Power = 56,
    Health = 240,
    MaxHealth = 240,
}

valid = valid and CombatService.IsRanged(attacker) == true
valid = valid and CombatService.GetAttackRange(attacker, Config.ArmyTypes.Archers, Config, 1) > 30

local target = CombatService.GetRolePriority("Cavalry", "Archers")
valid = valid and target > 1

local castle = CastleService.Create("Stage13Probe", "Regional", 1, Config)
local startingGarrison = castle.Garrison
CastleService.ApplyAssault(castle, 500, 1)
valid = valid and castle.Garrison < startingGarrison

local sample = SoldierService.Create(Config, {
    Id = "STAGE13-PROBE",
    ArmyId = 1,
    Role = "Archers",
    PersonalitySeed = 13132026,
})
local hitChance = CombatService.GetHitChance(attacker, defender, sample, 1)
valid = valid and hitChance > 0 and hitChance <= 1

workspace:SetAttribute("KC_Stage13Ready", valid)
workspace:SetAttribute("KC_Stage13StateSchemaVersion", StateSchemas.Version)
workspace:SetAttribute("KC_Stage13Studio", RunService:IsStudio())

print(string.format(
    "[KingdomsConquest][Stage13] combat/castle system %s | studio=%s | schema=v%d",
    valid and "ready" or "FAILED",
    tostring(RunService:IsStudio()),
    StateSchemas.Version
))
