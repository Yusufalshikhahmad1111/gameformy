-- Kingdoms Conquest — ArmyService
-- Stage 12: army orchestration helpers; individual Soldier state lives in SoldierService.
local ArmyService = {}

local function clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

function ArmyService.GetDefinition(config, armyType)
    return config and config.ArmyTypes and config.ArmyTypes[armyType]
end

function ArmyService.IsValidType(config, armyType)
    return ArmyService.GetDefinition(config, armyType) ~= nil
end

function ArmyService.GetCombatMultiplier(attackerType, targetType)
    if attackerType == "Spearmen" and targetType == "Cavalry" then return 1.35 end
    if attackerType == "Cavalry" and targetType == "Archers" then return 1.35 end
    if attackerType == "Archers" and targetType == "Spearmen" then return 1.10 end
    return 1
end

function ArmyService.GetMovementSpeed(definition, terrainMultiplier, morale, fatigue)
    local base = math.max(0, (definition and (definition.MoveSpeed or definition.Speed)) or 0)
    local moraleMultiplier = 0.75 + clamp(tonumber(morale) or 100, 0, 100) / 400
    local fatigueMultiplier = 1 - clamp(tonumber(fatigue) or 0, 0, 100) / 250
    return math.max(0, base * (terrainMultiplier or 1) * moraleMultiplier * fatigueMultiplier)
end

function ArmyService.GetAttackCooldown(definition, morale, fatigue)
    local base = math.max(0.05, definition and definition.AttackCooldown or 1)
    local fatiguePenalty = 1 + clamp(tonumber(fatigue) or 0, 0, 100) / 250
    local moraleBonus = 1 - clamp(tonumber(morale) or 100, 0, 100) / 900
    return math.max(0.05, base * fatiguePenalty * moraleBonus)
end

function ArmyService.GetAttackDamage(definition, attackerType, targetType, power)
    if not definition then return 0 end
    local base = tonumber(power) or tonumber(definition.Damage) or 0
    return base * ArmyService.GetCombatMultiplier(attackerType, targetType)
end

function ArmyService.GetDefaultFormation(config)
    if config and config.Formations and config.Formations.Line then
        return "Line"
    end
    return "Line"
end

function ArmyService.GetDefaultState(config, payload)
    local definition = ArmyService.GetDefinition(config, payload.Type)
    assert(definition, "invalid army type")
    return {
        Id = payload.Id,
        Team = payload.Team,
        Owner = payload.Owner,
        Type = payload.Type,
        Formation = payload.Formation or ArmyService.GetDefaultFormation(config),
        Order = payload.Order or "Hold",
        Position = payload.Position,
        TargetPosition = payload.TargetPosition or payload.Position,
        Health = 0,
        MaxHealth = 0,
        Morale = 100,
        Fatigue = 0,
        Experience = 0,
        Power = 0,
        Defense = 0,
        Soldiers = {},
        SoldierSequence = 0,
        AttackTarget = nil,
        Model = nil,
    }
end

function ArmyService.NextSoldierId(army)
    army.SoldierSequence = (army.SoldierSequence or 0) + 1
    return string.format("A%s-S%s", tostring(army.Id), tostring(army.SoldierSequence))
end

function ArmyService.GetRecruitCost(definition, count)
    local unitCost = tonumber(definition and (definition.CostPerSoldier or definition.Cost)) or 0
    return unitCost * math.max(1, tonumber(count) or 1)
end

function ArmyService.GetInitialSoldierCount(definition)
    return math.max(1, tonumber(definition and definition.InitialSoldiers) or 4)
end

function ArmyService.GetMaxSoldiers(definition)
    return math.max(1, tonumber(definition and definition.MaxSoldiers) or 24)
end

function ArmyService.RefreshAggregate(army, soldierService)
    local aggregate = soldierService.Aggregate(army.Soldiers)
    army.Health = aggregate.Health
    army.MaxHealth = aggregate.MaxHealth
    army.Morale = aggregate.Morale
    army.Fatigue = aggregate.Fatigue
    army.Experience = aggregate.Experience
    army.Power = aggregate.Power
    army.Defense = aggregate.Defense
    army.SoldierCount = aggregate.SoldierCount
    return aggregate
end

function ArmyService.IsAlive(army)
    return army ~= nil and (army.SoldierCount or 0) > 0 and (army.Health or 0) > 0
end

function ArmyService.GetFormationSpacing(formation)
    if formation == "Column" then return 3.4 end
    if formation == "Spread" then return 6.2 end
    if formation == "Wedge" then return 4.4 end
    return 4
end

function ArmyService.GetFormationOffset(formation, index, count)
    local spacing = ArmyService.GetFormationSpacing(formation)
    local n = math.max(1, count)
    local idx = math.max(1, index)
    if formation == "Wedge" then
        local row = math.floor((idx - 1) / 2)
        local side = ((idx - 1) % 2 == 0) and -1 or 1
        return Vector3.new(side * row * spacing * 0.48, 0, row * spacing * 0.78)
    elseif formation == "Column" then
        return Vector3.new(0, 0, (idx - 1) * spacing)
    elseif formation == "Spread" then
        local columns = math.max(2, math.ceil(math.sqrt(n)))
        local row = math.floor((idx - 1) / columns)
        local col = (idx - 1) % columns
        return Vector3.new((col - (columns - 1) / 2) * spacing, 0, row * spacing * 0.9)
    end

    local columns = math.min(8, math.max(2, math.ceil(math.sqrt(n * 1.5))))
    local row = math.floor((idx - 1) / columns)
    local col = (idx - 1) % columns
    return Vector3.new((col - (columns - 1) / 2) * spacing, 0, row * spacing)
end

return ArmyService
