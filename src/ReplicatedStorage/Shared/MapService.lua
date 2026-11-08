-- Kingdoms Conquest — World Map Service
-- Converts geographic MapPacks into the runtime province/castle graph.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local MapService = {}

local cache = {}

local function build(pack)
    local map = {
        Name = pack.Id,
        DisplayName = pack.DisplayName,
        VictoryRatio = pack.VictoryRatio,
        Spawns = pack.Spawns,
        ProvinceOrder = {},
        Provinces = {},
        Cities = {},
        Edges = pack.Edges or {},
    }

    for _, city in ipairs(pack.Cities or {}) do
        table.insert(map.ProvinceOrder, city.Id)
        local position = Vector3.new(city.X, 0, city.Z)
        map.Cities[city.Id] = city
        map.Provinces[city.Id] = {
            Index = #map.ProvinceOrder,
            Position = position,
            Size = city.Capital and Vector3.new(42, 2, 42) or Vector3.new(34, 2, 34),
            Strategic = city.Capital == true,
            Income = city.Income or 7,
            CityName = city.Name,
            ProvinceName = city.Province,
            Capital = city.Capital == true,
            StartingOwners = {},
        }
    end

    -- Neutral by default. Match bootstrap assigns starting territories.
    return map
end

function MapService.GetMap(mapId, teamCount)
    mapId = mapId or Config.Game.MapId
    teamCount = math.clamp(tonumber(teamCount) or Config.Game.TeamCount or 2, 2, 4)
    local cacheKey = mapId .. ":" .. tostring(teamCount)
    if cache[cacheKey] then return cache[cacheKey] end

    if Config.MapPacks[mapId] then
        cache[cacheKey] = build(Config.MapPacks[mapId])
        local total = #cache[cacheKey].ProvinceOrder
        for index, cityId in ipairs(cache[cacheKey].ProvinceOrder) do
            local team = ((index - 1) % teamCount) + 1
            if index > total - teamCount then team = ((index - 1) % teamCount) + 1 end
            cache[cacheKey].Provinces[cityId].StartingOwners = {[team] = 1}
        end
        return cache[cacheKey]
    end

    if Config.Maps[mapId] then
        cache[cacheKey] = Config.Maps[mapId]
        return cache[cacheKey]
    end

    cache[cacheKey] = Config.Maps.Heartland
    return cache[cacheKey]
end

function MapService.ListMaps()
    local result = {}
    for id, pack in pairs(Config.MapPacks or {}) do
        table.insert(result, {
            Id = id,
            DisplayName = pack.DisplayName,
            Region = pack.Region,
            DefaultTeamCount = pack.DefaultTeamCount,
            CityCount = #pack.Cities,
        })
    end
    table.sort(result, function(a,b) return a.DisplayName < b.DisplayName end)
    return result
end

function MapService.GetCity(mapId, cityId)
    local map = MapService.GetMap(mapId)
    return map.Cities and map.Cities[cityId]
end

return MapService
