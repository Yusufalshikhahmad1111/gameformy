-- Kingdoms Conquest — MatchService
local MatchService = {}

function MatchService.GetVictoryTarget(totalProvinces, victoryRatio)
    return math.max(1, math.ceil(totalProvinces * victoryRatio))
end

function MatchService.GetWinnerByOwnership(ownedCounts, activeTeamCount)
    local winner, best = 0, -1
    for teamId = 1, activeTeamCount do
        local count = ownedCounts[teamId] or 0
        if count > best then
            winner, best = teamId, count
        elseif count == best then
            winner = 0
        end
    end
    return winner, best
end

function MatchService.IsTimeUp(startedAt, now, matchLengthSeconds)
    return startedAt > 0 and (now - startedAt) >= matchLengthSeconds
end

return MatchService
