-- Kingdoms Conquest — WorldBuilder contract
-- Stage 11 makes world construction an explicit responsibility. The existing
-- runtime keeps compatibility while Stage 16 supplies the final art pipeline.
local WorldBuilder = {}

function WorldBuilder.GetStaticMap(workspace, mapId)
    return workspace:FindFirstChild("Map_" .. tostring(mapId))
end

function WorldBuilder.ValidateStaticMap(workspace, mapId)
    local map = WorldBuilder.GetStaticMap(workspace, mapId)
    if not map then return false, "missing-static-map" end
    local visitor = map:FindFirstChild("VisitorSpawn", true)
    local returnPad = map:FindFirstChild("ReturnToLobby", true)
    if not visitor then return false, "missing-visitor-spawn" end
    if not returnPad then return false, "missing-return-pad" end
    return true
end

return WorldBuilder
