-- Kingdoms Conquest — Stage 7 Launch Bootstrap
-- Resolves mode/map from server-safe defaults and TeleportData before the battlefield is built.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)

local DEFAULT_MAP = Config.Maps.Heartland and "Heartland" or next(Config.Maps)
local DEFAULT_TEAMS = 2

local function validMap(mapId)
    return type(mapId) == "string" and Config.Maps[mapId] ~= nil
end

local function validTeamCount(count)
    return type(count) == "number" and count % 1 == 0 and count >= 2 and count <= 4
end

local function applyMode(data)
    data = type(data) == "table" and data or {}

    local mapId = validMap(data.MapId) and data.MapId or DEFAULT_MAP
    local teamCount = validTeamCount(data.TeamCount) and data.TeamCount or DEFAULT_TEAMS
    local matchId = type(data.MatchId) == "string" and string.sub(data.MatchId, 1, 80) or ""
    local seasonId = type(data.SeasonId) == "string" and string.sub(data.SeasonId, 1, 80) or ""

    Config.Game.MapId = mapId
    Config.Game.TeamCount = teamCount

    workspace:SetAttribute("KC_MapId", mapId)
    workspace:SetAttribute("KC_TeamCount", teamCount)
    workspace:SetAttribute("KC_MatchId", matchId)
    workspace:SetAttribute("KC_SeasonId", seasonId)
    workspace:SetAttribute("KC_BootstrapSource", data.Source or (RunService:IsStudio() and "Studio" or "Default"))

    if matchId ~= "" then
        workspace:SetAttribute("MatchId", matchId)
        workspace:SetAttribute("MatchActive", true)
    else
        if workspace:GetAttribute("MatchActive") == nil then
            workspace:SetAttribute("MatchActive", false)
        end
    end
end

local firstPlayer = Players:GetPlayers()[1]
if not firstPlayer then
    firstPlayer = Players.PlayerAdded:Wait()
end

local joinData = firstPlayer:GetJoinData()
local teleportData = joinData and joinData.TeleportData
applyMode(teleportData)
workspace:SetAttribute("KC_BootstrapReady", true)

print(string.format(
    "[KingdomsConquest][Stage7] Bootstrap ready | map=%s teams=%d match=%s source=%s",
    tostring(Config.Game.MapId),
    Config.Game.TeamCount,
    tostring(workspace:GetAttribute("KC_MatchId") or ""),
    tostring(workspace:GetAttribute("KC_BootstrapSource"))
))
