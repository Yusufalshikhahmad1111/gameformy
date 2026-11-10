-- Kingdoms Conquest — SoldierService
-- Stage 12: individual soldier state and army aggregation rules.
local SoldierService = {}

local function clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function seeded(seed)
    return Random.new(math.floor(seed or 1))
end

function SoldierService.Create(config, payload)
    local definition = config.ArmyTypes[payload.Role]
    assert(definition, "invalid soldier role")

    local seed = payload.PersonalitySeed or math.random(1, 2^30)
    local rng = seeded(seed)

    local function variance(amount)
        return (rng:NextNumber() * 2 - 1) * amount
    end

    return {
        Id = payload.Id,
        ArmyId = payload.ArmyId,
        Role = payload.Role,
        Level = payload.Level or 1,
        Health = payload.Health or definition.SoldierHealth or definition.Health,
        MaxHealth = payload.MaxHealth or definition.SoldierHealth or definition.Health,
        Power = clamp((definition.Power or definition.Damage or 10) + variance(definition.PowerVariance or 2), 1, 200),
        Defense = clamp((definition.Defense or 10) + variance(definition.DefenseVariance or 2), 1, 200),
        Range = definition.Range or definition.AttackRange or 10,
        Accuracy = clamp((definition.Accuracy or 0.8) + variance(definition.AccuracyVariance or 0.05), 0.25, 1),
        Speed = clamp((definition.Speed or definition.MoveSpeed or 10) + variance(definition.SpeedVariance or 2), 1, 100),
        Morale = payload.Morale or clamp(82 + variance(10), 35, 100),
        Discipline = clamp(payload.Discipline or 78 + variance(12), 25, 100),
        Fatigue = clamp(payload.Fatigue or 0, 0, 100),
        Experience = payload.Experience or 0,
        PersonalitySeed = seed,
        Alive = true,
    }
end

function SoldierService.IsAlive(soldier)
    return soldier ~= nil and soldier.Alive ~= false and (soldier.Health or 0) > 0
end

function SoldierService.ApplyDamage(soldier, amount)
    if not SoldierService.IsAlive(soldier) then
        return false
    end
    soldier.Health = math.max(0, soldier.Health - math.max(0, amount or 0))
    if soldier.Health <= 0 then
        soldier.Alive = false
        soldier.Morale = 0
        return true
    end
    soldier.Morale = math.max(0, soldier.Morale - math.min(18, (amount or 0) * 0.15))
    return false
end

function SoldierService.AddFatigue(soldier, amount)
    if not soldier then return end
    soldier.Fatigue = clamp((soldier.Fatigue or 0) + math.max(0, amount or 0), 0, 100)
end

function SoldierService.Recover(soldier, amount)
    if not SoldierService.IsAlive(soldier) then return end
    soldier.Fatigue = clamp((soldier.Fatigue or 0) - math.max(0, amount or 0), 0, 100)
    soldier.Morale = clamp((soldier.Morale or 0) + math.max(0, amount or 0) * 0.45, 0, 100)
end

function SoldierService.GetEffectivePower(soldier)
    if not SoldierService.IsAlive(soldier) then return 0 end
    local morale = 0.72 + (soldier.Morale or 0) / 250
    local fatigue = 1 - (soldier.Fatigue or 0) / 250
    local level = 1 + math.max(0, (soldier.Level or 1) - 1) * 0.04
    return math.max(0, (soldier.Power or 0) * morale * fatigue * level)
end

function SoldierService.GetEffectiveDefense(soldier)
    if not SoldierService.IsAlive(soldier) then return 0 end
    local morale = 0.75 + (soldier.Morale or 0) / 400
    local fatigue = 1 - (soldier.Fatigue or 0) / 300
    return math.max(0, (soldier.Defense or 0) * morale * fatigue)
end

function SoldierService.GetEffectiveAccuracy(soldier)
    if not SoldierService.IsAlive(soldier) then return 0 end
    local morale = 0.7 + (soldier.Morale or 0) / 333
    local fatigue = 1 - (soldier.Fatigue or 0) / 250
    return clamp((soldier.Accuracy or 0.5) * morale * fatigue, 0.1, 1)
end

function SoldierService.Aggregate(soldiers)
    local count, health, maxHealth = 0, 0, 0
    local morale, fatigue, experience = 0, 0, 0
    local power, defense = 0, 0
    for _, soldier in pairs(soldiers or {}) do
        if SoldierService.IsAlive(soldier) then
            count += 1
            health += soldier.Health or 0
            maxHealth += soldier.MaxHealth or 0
            morale += soldier.Morale or 0
            fatigue += soldier.Fatigue or 0
            experience += soldier.Experience or 0
            power += SoldierService.GetEffectivePower(soldier)
            defense += SoldierService.GetEffectiveDefense(soldier)
        end
    end

    if count == 0 then
        return {
            SoldierCount = 0,
            Health = 0,
            MaxHealth = maxHealth,
            Morale = 0,
            Fatigue = 100,
            Experience = 0,
            Power = 0,
            Defense = 0,
        }
    end

    return {
        SoldierCount = count,
        Health = health,
        MaxHealth = maxHealth,
        Morale = morale / count,
        Fatigue = fatigue / count,
        Experience = experience / count,
        Power = power,
        Defense = defense,
    }
end

return SoldierService
