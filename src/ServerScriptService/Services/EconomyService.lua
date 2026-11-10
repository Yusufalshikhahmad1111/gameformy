-- Kingdoms Conquest — EconomyService
-- Stage 15: territory-backed gold, supplies, upkeep, connectivity and comeback rules.
local EconomyService = {}

local DEFAULT_CONNECTED = 1.0
local DEFAULT_DISCONNECTED = 0.55
local DEFAULT_STABILIZED = 0.60

local function clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function edgeGraph(mapData)
    local graph = {}
    for _, name in ipairs(mapData.ProvinceOrder or {}) do
        graph[name] = {}
    end
    for _, edge in ipairs(mapData.Edges or {}) do
        local a, b = edge[1], edge[2]
        if graph[a] and graph[b] then
            table.insert(graph[a], b)
            table.insert(graph[b], a)
        end
    end
    return graph
end

function EconomyService.GetHomeCapital(provinceStates, mapData, team)
    local order = mapData.ProvinceOrder or {}
    for _, name in ipairs(order) do
        local state = provinceStates[name]
        local data = mapData.Provinces[name]
        if state and data and state.Owner == team and data.StartingOwners and data.StartingOwners[mapData.TeamCount or 0] == team then
            return name
        end
    end

    for _, name in ipairs(order) do
        local state = provinceStates[name]
        if state and state.Owner == team then
            return name
        end
    end

    return nil
end

function EconomyService.GetConnectedProvinces(provinceStates, mapData, team, homeCapital)
    local graph = edgeGraph(mapData)
    local connected = {}
    if not homeCapital or not provinceStates[homeCapital] or provinceStates[homeCapital].Owner ~= team then
        return connected
    end

    local queue = {homeCapital}
    connected[homeCapital] = true
    local head = 1

    while queue[head] do
        local current = queue[head]
        head += 1
        for _, nextProvince in ipairs(graph[current] or {}) do
            if not connected[nextProvince] and provinceStates[nextProvince] and provinceStates[nextProvince].Owner == team then
                connected[nextProvince] = true
                table.insert(queue, nextProvince)
            end
        end
    end

    return connected
end

function EconomyService.GetConnectionMultiplier(isConnected, provinceIsCapital, config)
    if provinceIsCapital then return 1.0 end
    local economy = config and config.Economy
    local connected = economy and economy.ConnectedIncomeMultiplier or DEFAULT_CONNECTED
    local disconnected = economy and economy.DisconnectedIncomeMultiplier or DEFAULT_DISCONNECTED
    return isConnected and connected or disconnected
end

function EconomyService.GetStabilizationMultiplier(castle, config)
    if castle and (castle.StabilizationRemaining or 0) > 0 then
        return (config and config.Economy and config.Economy.StabilizedIncomeMultiplier) or DEFAULT_STABILIZED
    end
    return 1.0
end

function EconomyService.GetProvinceGoldPerMinute(provinceState, provinceData, connected, config)
    if not provinceState or provinceState.Owner == 0 then return 0 end
    local base = tonumber(provinceState.Income) or tonumber(provinceData and provinceData.Income) or 0
    local connection = EconomyService.GetConnectionMultiplier(connected, provinceData and provinceData.Capital == true, config)
    local stabilization = EconomyService.GetStabilizationMultiplier(provinceState.Castle, config)
    return base * connection * stabilization
end

function EconomyService.GetProvinceSupplyPerMinute(provinceState, provinceData, connected, config)
    local ratio = (config and config.Economy and config.Economy.SupplyIncomeRatio) or 0.28
    return EconomyService.GetProvinceGoldPerMinute(provinceState, provinceData, connected, config) * ratio
end

function EconomyService.GetArmyUpkeepPerMinute(army, config)
    if not army or not army.Type then return 0 end
    local definition = config and config.ArmyTypes and config.ArmyTypes[army.Type]
    if not definition then return 0 end
    return (tonumber(army.SoldierCount) or 0) * (tonumber(definition.UpkeepGoldPerMinute) or 0)
end

function EconomyService.GetTeamUpkeepPerMinute(armies, team, config)
    local total = 0
    for _, army in pairs(armies or {}) do
        if army.Team == team and (army.SoldierCount or 0) > 0 then
            total += EconomyService.GetArmyUpkeepPerMinute(army, config)
        end
    end
    return total
end

function EconomyService.GetOwnedProvinceCount(provinceStates, team)
    local count = 0
    for _, state in pairs(provinceStates or {}) do
        if state.Owner == team then count += 1 end
    end
    return count
end

function EconomyService.GetComebackModifiers(provinceStates, team, totalProvinces, config)
    local owned = EconomyService.GetOwnedProvinceCount(provinceStates, team)
    local ratio = owned / math.max(1, totalProvinces or 1)

    if ratio <= 0.30 then
        local economy = config and config.Economy or {}
        return {
            IncomeMultiplier = economy.ComebackIncomeMultiplier or 1.12,
            RecruitmentMultiplier = economy.ComebackRecruitmentMultiplier or 0.90,
            ReinforcementMultiplier = economy.ComebackReinforcementMultiplier or 0.88,
            IsComeback = true,
        }
    end

    return {
        IncomeMultiplier = 1.0,
        RecruitmentMultiplier = 1.0,
        ReinforcementMultiplier = 1.0,
        IsComeback = false,
    }
end

function EconomyService.ComputeTeamEconomy(provinceStates, mapData, armies, team, config, teamCount)
    local homeCapital = EconomyService.GetHomeCapital(provinceStates, mapData, team)
    local connected = EconomyService.GetConnectedProvinces(provinceStates, mapData, team, homeCapital)
    local totalProvinces = #(mapData.ProvinceOrder or {})
    local comeback = EconomyService.GetComebackModifiers(provinceStates, team, totalProvinces, config)

    local goldIncome = 0
    local supplyIncome = 0
    local connectedCount = 0
    local stabilizedCount = 0

    for name, state in pairs(provinceStates or {}) do
        if state.Owner == team then
            local data = mapData.Provinces[name] or {}
            local isConnected = connected[name] == true
            if isConnected then connectedCount += 1 end
            if state.Castle and (state.Castle.StabilizationRemaining or 0) > 0 then
                stabilizedCount += 1
            end
            goldIncome += EconomyService.GetProvinceGoldPerMinute(state, data, isConnected, config)
            supplyIncome += EconomyService.GetProvinceSupplyPerMinute(state, data, isConnected, config)
        end
    end

    goldIncome *= comeback.IncomeMultiplier
    supplyIncome *= comeback.IncomeMultiplier

    local upkeep = EconomyService.GetTeamUpkeepPerMinute(armies, team, config)

    return {
        HomeCapital = homeCapital,
        GoldIncomePerMinute = goldIncome,
        SupplyIncomePerMinute = supplyIncome,
        UpkeepGoldPerMinute = upkeep,
        NetGoldPerMinute = goldIncome - upkeep,
        ConnectedProvinces = connectedCount,
        OwnedProvinces = EconomyService.GetOwnedProvinceCount(provinceStates, team),
        StabilizedProvinces = stabilizedCount,
        Comeback = comeback.IsComeback,
        RecruitmentMultiplier = comeback.RecruitmentMultiplier,
        ReinforcementMultiplier = comeback.ReinforcementMultiplier,
    }
end

function EconomyService.Tick(teamGold, teamSupplies, teamStates, provinceStates, mapData, armies, activeTeamCount, config, dt)
    local result = {}
    local seconds = math.max(0.1, tonumber(dt) or 1)

    for team = 1, activeTeamCount do
        local snapshot = EconomyService.ComputeTeamEconomy(
            provinceStates,
            mapData,
            armies,
            team,
            config,
            activeTeamCount
        )
        local goldDelta = snapshot.NetGoldPerMinute * (seconds / 60)
        local supplyDelta = snapshot.SupplyIncomePerMinute * (seconds / 60)

        teamGold[team] = math.max(0, (teamGold[team] or 0) + goldDelta)
        teamSupplies[team] = math.max(0, (teamSupplies[team] or 0) + supplyDelta)

        local strain = snapshot.NetGoldPerMinute < 0
        if strain then
            for _, army in pairs(armies or {}) do
                if army.Team == team and army.Soldiers and (army.SoldierCount or 0) > 0 then
                    for _, soldier in pairs(army.Soldiers) do
                        if soldier.Alive then
                            soldier.Morale = math.max(0, (soldier.Morale or 0) - 0.18 * seconds)
                            soldier.Fatigue = math.min(100, (soldier.Fatigue or 0) + 0.08 * seconds)
                        end
                    end
                end
            end
        end

        teamStates[team] = snapshot
        teamStates[team].EconomyStrain = strain
        teamStates[team].Gold = teamGold[team]
        teamStates[team].Supplies = teamSupplies[team]
        result[team] = teamStates[team]
    end

    return result
end

function EconomyService.GetRecruitmentCost(definition, count, teamState, suppliesCost)
    local quantity = math.max(1, tonumber(count) or 1)
    local gold = (tonumber(definition and definition.GoldCostPerSoldier) or 0) * quantity
    local supplies = (tonumber(suppliesCost or definition and definition.SupplyCostPerSoldier) or 0) * quantity
    local multiplier = teamState and teamState.RecruitmentMultiplier or 1

    return {
        Gold = gold * multiplier,
        Supplies = supplies,
    }
end

function EconomyService.GetReinforcementCost(definition, teamState)
    local result = EconomyService.GetRecruitmentCost(
        definition,
        1,
        teamState,
        tonumber(definition and definition.SupplyCostPerSoldier)
    )
    local multiplier = teamState and teamState.ReinforcementMultiplier or 1
    result.Gold *= multiplier
    return result
end

function EconomyService.CanAfford(teamGold, teamSupplies, cost)
    return (tonumber(teamGold) or 0) >= (tonumber(cost and cost.Gold) or 0)
        and (tonumber(teamSupplies) or 0) >= (tonumber(cost and cost.Supplies) or 0)
end

function EconomyService.ApplyCost(teamGold, teamSupplies, cost)
    return
        math.max(0, (tonumber(teamGold) or 0) - (tonumber(cost and cost.Gold) or 0)),
        math.max(0, (tonumber(teamSupplies) or 0) - (tonumber(cost and cost.Supplies) or 0))
end

function EconomyService.TickSupplies(teamSupplies, provinceStates, activeTeamCount, tickSeconds)
    local divisor = math.max(1, tonumber(tickSeconds) or 1)
    for team = 1, activeTeamCount do
        local income = EconomyService.GetProvinceIncome(provinceStates, team)
        teamSupplies[team] = (teamSupplies[team] or 0) + math.floor(income / divisor)
    end
    return teamSupplies
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

return EconomyService
