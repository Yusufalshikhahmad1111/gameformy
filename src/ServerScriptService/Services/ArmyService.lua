-- Kingdoms Conquest — ArmyService
-- Pure rules/helpers first; orchestration remains in the match runtime until Stage 12.
local ArmyService = {}

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

function ArmyService.GetMovementSpeed(definition, terrainMultiplier)
    return math.max(0, (definition and definition.MoveSpeed or 0) * (terrainMultiplier or 1))
end

function ArmyService.GetAttackCooldown(definition)
    return math.max(0.05, definition and definition.AttackCooldown or 1)
end

function ArmyService.GetAttackDamage(definition, attackerType, targetType)
    if not definition then return 0 end
    return (definition.Damage or 0) * ArmyService.GetCombatMultiplier(attackerType, targetType)
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
        Position = payload.Position,
        TargetPosition = payload.TargetPosition or payload.Position,
        Health = definition.Health,
        MaxHealth = definition.Health,
        Morale = 100,
        Fatigue = 0,
        Experience = 0,
        AttackTarget = nil,
        Model = nil,
    }
end

function ArmyService.IsAlive(army)
    return army ~= nil and (army.Health or 0) > 0
end

return ArmyService
