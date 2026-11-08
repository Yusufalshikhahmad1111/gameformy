-- Kingdoms Conquest — World Map Service
-- Converts geographic MapPacks into the runtime province/castle graph.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local MapService = {}

local WORLD_SCALE = 2
local WORLD_ORIGINS = {
	Syria = Vector3.new(-1100, 0, -1100),
	SaudiArabia = Vector3.new(1100, 0, -1100),
	Palestine = Vector3.new(-1100, 0, 1100),
	Europe = Vector3.new(1100, 0, 1100),
}
local cache = {}

local function scaledVector3(value, origin)
    if typeof(value) == "Vector3" then
        return Vector3.new(value.X * WORLD_SCALE + (origin and origin.X or 0), value.Y + (origin and origin.Y or 0), value.Z * WORLD_SCALE + (origin and origin.Z or 0))
    end
    return value
end

local function scaledCity(city, origin)
    local copy = {}
    for key, value in pairs(city) do
        copy[key] = value
    end
    copy.X = (tonumber(city.X) or 0) * WORLD_SCALE
    copy.Z = (tonumber(city.Z) or 0) * WORLD_SCALE
    copy.X += origin.X
    copy.Z += origin.Z
    copy.Position = Vector3.new(copy.X, 0, copy.Z)
    return copy
end

local function scaleRiver(river, origin)
    if type(river) ~= "table" then
        return nil
    end
    local result = {}
    for key, value in pairs(river) do
        result[key] = value
    end
    if typeof(river.Center) == "Vector3" then
        result.Center = scaledVector3(river.Center, origin)
    end
    if typeof(river.Size) == "Vector3" then
        result.Size = Vector3.new(river.Size.X * WORLD_SCALE, river.Size.Y, river.Size.Z * WORLD_SCALE)
    end
    if type(river.HalfX) == "number" then
        result.HalfX = river.HalfX * WORLD_SCALE
    end
    if type(river.HalfZ) == "number" then
        result.HalfZ = river.HalfZ * WORLD_SCALE
    end
    return result
end

local function scaleSpawns(spawns, origin)
    local result = {}
    for teamId, position in pairs(spawns or {}) do
        result[teamId] = scaledVector3(position, origin)
    end
    return result
end

local function build(pack)
    local origin = WORLD_ORIGINS[pack.Id] or Vector3.new(0, 0, 0)
    local map = {
        Name = pack.Id,
        DisplayName = pack.DisplayName,
        VictoryRatio = pack.VictoryRatio,
        Description = pack.Description,
        Difficulty = pack.Difficulty,
        Art = pack.Art,
        Origin = origin,
        River = scaleRiver(pack.River, origin),
        RiverCrossings = pack.RiverCrossings or {},
        Spawns = scaleSpawns(pack.Spawns, origin),
        ProvinceOrder = {},
        Provinces = {},
        Cities = {},
        Edges = pack.Edges or {},
    }

    for _, sourceCity in ipairs(pack.Cities or {}) do
        local city = scaledCity(sourceCity, origin)
        table.insert(map.ProvinceOrder, city.Id)
        local position = city.Position
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
        -- Give each participating team one visually separated home castle.
        -- Remaining nodes stay neutral until players capture them.
        for index, cityId in ipairs(cache[cacheKey].ProvinceOrder) do
            if index <= teamCount then
                cache[cacheKey].Provinces[cityId].StartingOwners = {[teamCount] = index}
            else
                cache[cacheKey].Provinces[cityId].StartingOwners = {}
            end
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
