-- Kingdoms Conquest — CastleService
-- Stage 13: castle garrison and assault state.
local CastleService = {}

local clamp = function(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local DefaultTierConfig = {
    Capital = {Garrison=140, Defense=1.35, Recovery=1.6, Stabilization=12},
    Major = {Garrison=95, Defense=1.18, Recovery=1.35, Stabilization=9},
    Regional = {Garrison=60, Defense=1.00, Recovery=1.05, Stabilization=7},
}

function CastleService.GetTierConfig(tier, config)
    local source = config and config.Castles or DefaultTierConfig
    return source[tier] or source.Regional or DefaultTierConfig.Regional
end

function CastleService.Create(provinceName, tier, owner, config)
    local cfg = CastleService.GetTierConfig(tier, config)
    return {
        Province = provinceName,
        Tier = tier,
        Owner = owner or 0,
        State = "Safe",
        Garrison = cfg.Garrison,
        MaxGarrison = cfg.Garrison,
        DefenseMultiplier = cfg.Defense,
        StabilizationRemaining = 0,
        AssaultTeam = 0,
        CaptureProgress = 0,
    }
end

function CastleService.IsStabilizing(castle)
    return (castle.StabilizationRemaining or 0) > 0
end

function CastleService.GetGarrisonRatio(castle)
    return clamp((castle.Garrison or 0) / math.max(1, castle.MaxGarrison or 1), 0, 1)
end

function CastleService.ApplyAssault(castle, attackerPower, dt)
    if not castle or castle.Garrison <= 0 then return 0 end
    local damage = math.max(0, (attackerPower or 0) * 0.065 * dt)
    castle.Garrison = math.max(0, castle.Garrison - damage)
    castle.State = "Assaulted"
    return damage
end

function CastleService.GetGarrisonFireDamage(castle, targetPower)
    if not castle or castle.Garrison <= 0 then return 0 end
    local ratio = math.max(0.25, math.min(1, (castle.Garrison or 0) / math.max(1, castle.MaxGarrison or 1)))
    local tier = CastleService.GetTierConfig(castle.Tier)
    return math.max(1, (castle.Garrison * 0.012 + tier.Defense * 2.2) * ratio * math.max(0.4, math.min(1.2, (targetPower or 0) / 80)))
end

function CastleService.AdvanceCapture(castle, team, dt, captureSeconds, decayPerSecond, config)
    if not castle or CastleService.IsStabilizing(castle) then return false end
    if (castle.Garrison or 0) > 0 then return false end

    if castle.AssaultTeam ~= team then
        castle.AssaultTeam = team
        castle.CaptureProgress = 0
    end

    castle.CaptureProgress += dt

    if castle.CaptureProgress >= captureSeconds then
        castle.Owner = team
        castle.AssaultTeam = 0
        castle.CaptureProgress = 0
        castle.Garrison = castle.MaxGarrison
        castle.StabilizationRemaining = CastleService.GetTierConfig(castle.Tier, config).Stabilization
        castle.State = "Stabilizing"
        return true
    end

    return false
end

function CastleService.Contest(castle)
    castle.State = "Contested"
end

function CastleService.TickRecovery(castle, dt, config)
    if not castle then return end

    if castle.StabilizationRemaining > 0 then
        castle.StabilizationRemaining = math.max(0, castle.StabilizationRemaining - dt)
        if castle.StabilizationRemaining <= 0 then
            castle.State = "Safe"
        end
        return
    end

    if castle.State ~= "Assaulted" and castle.State ~= "Contested" then
        local cfg = CastleService.GetTierConfig(castle.Tier, config)
        castle.Garrison = math.min(castle.MaxGarrison, castle.Garrison + cfg.Recovery * dt)
        if castle.Garrison >= castle.MaxGarrison then
            castle.State = "Safe"
        end
    end
end

function CastleService.PublicState(castle)
    return {
        Province = castle.Province,
        Tier = castle.Tier,
        Owner = castle.Owner,
        State = castle.State,
        Garrison = math.floor(castle.Garrison or 0),
        MaxGarrison = castle.MaxGarrison,
        CaptureTeam = castle.AssaultTeam,
        CaptureProgress = castle.CaptureProgress,
        StabilizationRemaining = castle.StabilizationRemaining,
    }
end

return CastleService
