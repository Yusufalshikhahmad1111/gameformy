-- Kingdoms Conquest — Stage 15 economy runtime gate
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local EconomyService = require(script.Parent.Services.EconomyService)
local StateSchemas = require(ReplicatedStorage.Shared.StateSchemas)

local valid = true

local mapData = {
    TeamCount = 2,
    ProvinceOrder = {"Capital", "Road", "Outpost"},
    Edges = {
        {"Capital", "Road"},
        {"Road", "Outpost"},
    },
    Provinces = {
        Capital = {Income = 12, Capital = true},
        Road = {Income = 8, Capital = false},
        Outpost = {Income = 10, Capital = false},
    },
}

local provinces = {
    Capital = {Owner = 1, Income = 12, Castle = {StabilizationRemaining = 0}},
    Road = {Owner = 1, Income = 8, Castle = {StabilizationRemaining = 0}},
    Outpost = {Owner = 2, Income = 10, Castle = {StabilizationRemaining = 0}},
}

local connected = EconomyService.GetConnectedProvinces(provinces, mapData, 1, "Capital")
local snapshot = EconomyService.ComputeTeamEconomy(
    provinces,
    mapData,
    {},
    1,
    Config,
    2
)

local cost = EconomyService.GetRecruitmentCost(
    Config.ArmyTypes.Spearmen,
    1,
    {RecruitmentMultiplier = 1},
    Config.ArmyTypes.Spearmen.SupplyCostPerSoldier
)

valid = valid and connected.Capital == true
valid = valid and connected.Road == true
valid = valid and connected.Outpost == nil
valid = valid and snapshot.GoldIncomePerMinute > 0
valid = valid and snapshot.ConnectedProvinces == 2
valid = valid and cost.Gold > 0 and cost.Supplies > 0

workspace:SetAttribute("KC_Stage15Ready", valid)
workspace:SetAttribute("KC_Stage15StateSchemaVersion", StateSchemas.Version)
workspace:SetAttribute("KC_Stage15Studio", RunService:IsStudio())

print(string.format(
    "[KingdomsConquest][Stage15] economy system %s | studio=%s | schema=v%d",
    valid and "ready" or "FAILED",
    tostring(RunService:IsStudio()),
    StateSchemas.Version
))
