-- Kingdoms Conquest — EconomyService
local EconomyService = {}

function EconomyService.CanAfford(amount, cost)
    return (tonumber(amount) or 0) >= (tonumber(cost) or 0)
end

function EconomyService.ApplyCost(balance, cost)
    return math.max(0, (tonumber(balance) or 0) - (tonumber(cost) or 0))
end

function EconomyService.GetProvinceIncome(provinceStates, team)
    local income = 0
    for _, state in pairs(provinceStates or {}) do
        if state.Owner == team then
            income += tonumber(state.Income) or 0
        end
    end
    return income
end

function EconomyService.TickSupplies(teamSupplies, provinceStates, activeTeamCount, tickSeconds)
    local divisor = math.max(1, tonumber(tickSeconds) or 1)
    for team = 1, activeTeamCount do
        local income = EconomyService.GetProvinceIncome(provinceStates, team)
        teamSupplies[team] = (teamSupplies[team] or 0) + math.floor(income / divisor)
    end
    return teamSupplies
end

return EconomyService
