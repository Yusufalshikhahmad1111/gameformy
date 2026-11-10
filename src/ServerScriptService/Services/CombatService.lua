-- Kingdoms Conquest — CombatService
-- Stage 13: deterministic battlefield combat rules.
local CombatService = {}

local function clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

function CombatService.GetFormationModifier(formation, stat)
    local values = {
        Line = {Attack=1.00, Defense=1.10, Range=1.00, Cohesion=1.15},
        Wedge = {Attack=1.20, Defense=0.92, Range=0.95, Cohesion=0.92},
        Column = {Attack=0.82, Defense=0.90, Range=0.90, Cohesion=1.05},
        Spread = {Attack=0.90, Defense=0.94, Range=1.08, Cohesion=0.78},
    }
    return (values[formation] and values[formation][stat]) or 1
end

function CombatService.GetRolePriority(attackerType, defenderType)
    if attackerType == "Cavalry" and defenderType == "Archers" then return 1.4 end
    if attackerType == "Spearmen" and defenderType == "Cavalry" then return 1.45 end
    if attackerType == "Archers" and defenderType == "Spearmen" then return 1.25 end
    if attackerType == defenderType then return 0.9 end
    return 1
end

function CombatService.GetDetectionRange(army, config)
    local base = config and config.Combat and config.Combat.DetectionRange or 48
    if army.Type == "Cavalry" then base = 58 end
    if army.Type == "Archers" then base = 52 end
    return base * CombatService.GetFormationModifier(army.Formation, "Range")
end

function CombatService.ChooseTarget(army, armies, SoldierService)
    local best, bestScore = nil, -math.huge
    local detectRange = CombatService.GetDetectionRange(army, nil)

    for _, candidate in pairs(armies or {}) do
        if candidate ~= army
            and candidate.Team ~= army.Team
            and candidate.Model
            and candidate.Model.Parent
            and (candidate.SoldierCount or 0) > 0
        then
            local distance = (army.Position - candidate.Position).Magnitude
            if distance <= detectRange then
                local targetPriority = CombatService.GetRolePriority(army.Type, candidate.Type)
                local healthRatio = (candidate.Health or 0) / math.max(1, candidate.MaxHealth or 1)
                local woundedPriority = 1 + (1 - healthRatio) * 0.4
                local distanceScore = 1 - clamp(distance / detectRange, 0, 1)
                local score = targetPriority * 2 + woundedPriority + distanceScore

                if army.Order == "Attack" and army.AttackTarget == candidate.Id then
                    score += 4
                end

                if score > bestScore then
                    bestScore = score
                    best = candidate
                end
            end
        end
    end

    return best
end

function CombatService.IsRanged(army)
    return army.Type == "Archers"
end

function CombatService.GetAttackRange(army, definition, config, terrainModifier)
    local range = definition.AttackRange or 10
    return range * CombatService.GetFormationModifier(army.Formation, "Range") * (terrainModifier or 1)
end

function CombatService.GetHitChance(attacker, defender, soldier, terrainRangeModifier)
    local base = soldier and soldier.Accuracy or 0.75
    local morale = 0.70 + (attacker.Morale or 0) / 333
    local fatigue = 1 - (attacker.Fatigue or 0) / 250
    local formation = CombatService.GetFormationModifier(attacker.Formation, "Cohesion")
    local rangePenalty = terrainRangeModifier or 1
    return clamp(base * morale * fatigue * formation * rangePenalty, 0.18, 0.98)
end

function CombatService.GetBaseDamage(attacker, defender, soldier, formationMultiplier, defense)
    local power = (soldier and soldier.Power) or (attacker.Power or 0)
    local roleMultiplier = CombatService.GetRolePriority(attacker.Type, defender.Type)
    local defenseValue = math.max(1, defense or 1)
    return math.max(1, power * formationMultiplier * roleMultiplier / (1 + defenseValue / 36))
end

function CombatService.GetRetreatThreshold(army, config)
    local morale = army.Morale or 0
    local fatigue = army.Fatigue or 0
    local healthRatio = (army.Health or 0) / math.max(1, army.MaxHealth or 1)

    local threshold = config and config.Combat and config.Combat.RetreatHealthRatio or 0.22
    threshold += math.max(0, 55 - morale) / 300
    threshold += math.max(0, fatigue - 70) / 500

    local retreatMorale = config and config.Combat and config.Combat.RetreatMorale or 20
    return healthRatio <= threshold or morale <= retreatMorale
end

function CombatService.CanDisengage(army, target)
    if not target then return true end
    return (army.Morale or 0) >= 28 and (army.Fatigue or 0) < 90
end

return CombatService

function CombatService.GetTerrainModifiers(position, terrainZones)
    local river = terrainZones and terrainZones.River
    if river and position
        and math.abs(position.X - river.Center.X) <= river.HalfX
        and math.abs(position.Z - river.Center.Z) <= river.HalfZ
    then
        return {
            Range = 0.88,
            Defense = 1.05,
            Cavalry = 0.78,
            Movement = river.Speed or 0.55,
        }
    end

    return {
        Range = 1,
        Defense = 1,
        Cavalry = 1,
        Movement = 1,
    }
end

function CombatService.ShouldAutoAcquire(army)
    return army
        and army.Order ~= "Retreat"
        and army.Order ~= "Hold"
        and (army.CombatState == nil or army.CombatState == "Searching")
end
