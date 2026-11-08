-- Kingdoms Conquest — CaptureService
local CaptureService = {}

function CaptureService.ResolvePresence(presentTeams)
    local activeTeam = 0
    local count = 0
    for team in pairs(presentTeams or {}) do
        count += 1
        activeTeam = team
    end
    return activeTeam, count
end

function CaptureService.CanCapture(state, activeTeam)
    if not state or activeTeam == 0 then return false end
    return state.Owner == 0 or activeTeam ~= state.Owner
end

function CaptureService.Advance(state, activeTeam, dt, captureSeconds, decayPerSecond)
    if not state or activeTeam == 0 then return false end
    if CaptureService.CanCapture(state, activeTeam) then
        if state.CaptureTeam ~= activeTeam then
            state.CaptureTeam = activeTeam
            state.CaptureProgress = 0
        end
        state.CaptureProgress += dt
        if state.CaptureProgress >= captureSeconds then
            state.Owner = activeTeam
            state.CaptureTeam = 0
            state.CaptureProgress = 0
            return true
        end
        return false
    end

    if (state.CaptureProgress or 0) > 0 then
        state.CaptureProgress = math.max(0, state.CaptureProgress - decayPerSecond * dt)
    end
    return false
end

function CaptureService.Decay(state, dt, decayPerSecond)
    if not state or (state.CaptureProgress or 0) <= 0 then return end
    state.CaptureProgress = math.max(0, state.CaptureProgress - decayPerSecond * dt)
end

return CaptureService
