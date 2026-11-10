-- Kingdoms Conquest — BotCommanderService
-- Stage 14: decision making only. Bots use the same Army/Combat/Castle rules as humans.
local BotCommanderService = {}

local Difficulty = {
    Recruit = {
        ThinkSeconds = 3.2,
        Horizon = 0.75,
        AttackBias = 0.85,
        DefenseBias = 1.00,
        EconomyBias = 0.85,
        RiskTolerance = 0.75,
    },
    Veteran = {
        ThinkSeconds = 2.0,
        Horizon = 1.0,
        AttackBias = 1.05,
        DefenseBias = 1.08,
        EconomyBias = 1.0,
        RiskTolerance = 1.0,
    },
    Warlord = {
        ThinkSeconds = 1.15,
        Horizon = 1.3,
        AttackBias = 1.18,
        DefenseBias = 1.22,
        EconomyBias = 1.12,
        RiskTolerance = 1.2,
    },
}

function BotCommanderService.GetProfile(difficulty)
    return Difficulty[difficulty] or Difficulty.Recruit
end

function BotCommanderService.Create(id, team, difficulty, spawnPosition)
    local profile = BotCommanderService.GetProfile(difficulty)
    return {
        Id = id,
        UserId = -100000 - id,
        Name = "Commander " .. tostring(id),
        Team = team,
        Difficulty = difficulty,
        State = "Idle",
        ThinkAccumulator = profile.ThinkSeconds,
        LastAction = "Spawned",
        FailedActions = {},
        PreferredTarget = nil,
        SpawnPosition = spawnPosition,
        CapitalProvince = nil,
        ArmyIds = {},
        ObjectiveId = nil,
        ObjectiveFailureCount = 0,
    }
end

function BotCommanderService.IsHealthy(bot)
    return bot and bot.Team and bot.State ~= "Disabled"
end

function BotCommanderService.GetArmyStrength(army)
    if not army then return 0 end
    local morale = 0.7 + (army.Morale or 0) / 333
    local fatigue = 1 - (army.Fatigue or 0) / 250
    return math.max(0, (army.Power or 0) * morale * fatigue)
end

function BotCommanderService.ScoreProvince(bot, provinceName, provinceState, provinceData, mapData, armies, now)
    if not provinceState or not provinceData then return -math.huge end
    local profile = BotCommanderService.GetProfile(bot.Difficulty)

    local score = 0
    score += (provinceData.Income or 0) * 2.1 * profile.EconomyBias
    if provinceData.Strategic then
        score += 18 * profile.AttackBias
    end
    if provinceData.Capital then
        score += 38 * profile.DefenseBias
    end

    if provinceState.Owner == 0 then
        score += 16
    elseif provinceState.Owner ~= bot.Team then
        score += 24 * profile.AttackBias
        if provinceState.Owner == bot.Team then score -= 30 end
    else
        score -= 20
    end

    local objectivePosition = provinceData.Position
    local nearestDistance = math.huge
    for _, army in pairs(armies or {}) do
        if army.Team == bot.Team and (army.SoldierCount or 0) > 0 then
            nearestDistance = math.min(nearestDistance, (army.Position - objectivePosition).Magnitude)
        end
    end
    if nearestDistance < math.huge then
        score -= nearestDistance * (0.045 / math.max(0.5, profile.Horizon))
    end

    local threat = 0
    for _, army in pairs(armies or {}) do
        if army.Team ~= bot.Team and (army.SoldierCount or 0) > 0 then
            local d = (army.Position - objectivePosition).Magnitude
            if d <= 70 then
                threat += BotCommanderService.GetArmyStrength(army) * (1 - d / 70)
            end
        end
    end
    score += threat * 0.08 * profile.DefenseBias

    if bot.FailedActions[provinceName] and now < bot.FailedActions[provinceName] then
        score -= 30
    end

    return score
end

function BotCommanderService.FindBestProvince(bot, provinceStates, mapData, armies, now)
    local bestName, bestScore = nil, -math.huge
    for name, state in pairs(provinceStates or {}) do
        local data = mapData.Provinces[name]
        local score = BotCommanderService.ScoreProvince(bot, name, state, data, mapData, armies, now)
        if score > bestScore then
            bestName, bestScore = name, score
        end
    end
    return bestName, bestScore
end

function BotCommanderService.ShouldRetreat(army, enemyStrength)
    local ownStrength = BotCommanderService.GetArmyStrength(army)
    if ownStrength <= 0 then return true end
    if (army.Morale or 0) < 24 then return true end
    if enemyStrength > ownStrength * 1.75 then return true end
    return false
end

function BotCommanderService.ChooseArmyForObjective(bot, objectivePosition, armies)
    local best, bestScore = nil, -math.huge
    for _, army in pairs(armies or {}) do
        if army.Owner and army.Owner.UserId == bot.UserId and army.Team == bot.Team and (army.SoldierCount or 0) > 0 then
            local distance = (army.Position - objectivePosition).Magnitude
            local strength = BotCommanderService.GetArmyStrength(army)
            local score = strength * 0.08 - distance * 0.02
            if army.Order == "Retreat" then score -= 25 end
            if army.Fatigue > 80 then score -= 10 end
            if score > bestScore then
                best = army
                bestScore = score
            end
        end
    end
    return best
end

function BotCommanderService.ChooseFormation(army, targetType, difficulty)
    if army.Type == "Spearmen" and targetType == "Cavalry" then
        return "Line"
    end
    if army.Type == "Cavalry" then
        return difficulty == "Warlord" and "Wedge" or "Line"
    end
    if army.Type == "Archers" then
        return "Spread"
    end
    return "Line"
end

function BotCommanderService.ChooseRecruitment(teamSupplies, armyCount, difficulty)
    local profile = BotCommanderService.GetProfile(difficulty)
    if teamSupplies < 15 then return nil end
    if armyCount == 0 then return "Spearmen" end
    if teamSupplies >= 32 * profile.EconomyBias then return "Cavalry" end
    if teamSupplies >= 24 * profile.EconomyBias then return "Archers" end
    return "Spearmen"
end

function BotCommanderService.RecordFailure(bot, objectiveName, now)
    bot.FailedActions[objectiveName] = now + 12 + bot.ObjectiveFailureCount * 4
    bot.ObjectiveFailureCount += 1
end

return BotCommanderService
