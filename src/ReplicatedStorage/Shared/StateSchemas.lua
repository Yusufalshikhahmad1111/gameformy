-- Kingdoms Conquest — state contracts shared by server and clients
local StateSchemas = {}

StateSchemas.Version = 4

StateSchemas.Forms = {
    Match = {
        "MatchActive", "MatchId", "MapId", "TeamCount", "Winner", "Reason", "Duration",
    },
    Army = {
        "Id", "Team", "OwnerUserId", "Type", "Position", "TargetPosition",
        "Formation", "Order", "CombatState", "AttackTarget", "FollowTargetArmyId", "Health", "MaxHealth",
        "SoldierCount", "Power", "Defense", "Morale", "Fatigue", "Experience",
    },
    Soldier = {
        "Id", "ArmyId", "Role", "Level", "Health", "MaxHealth",
        "Power", "Defense", "Range", "Accuracy", "Speed",
        "Morale", "Courage", "Aggression", "Discipline", "Loyalty", "Fatigue", "Experience", "PersonalitySeed",
    },
    Province = {
        "Owner", "CaptureTeam", "CaptureProgress", "Income", "Strategic",
    },
    Economy = {
        "Supplies", "Gold", "Upkeep", "IncomePerMinute",
    },
    Castle = {
        "Province", "Tier", "Owner", "State", "Garrison", "MaxGarrison",
        "CaptureTeam", "CaptureProgress", "StabilizationRemaining",
    },
    Bot = {
        "Team", "Name", "Difficulty", "State", "LastAction", "ObjectiveId",
    },
}

local function finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

function StateSchemas.IsArmyType(value, config)
    return type(value) == "string" and config and config.ArmyTypes and config.ArmyTypes[value] ~= nil
end

function StateSchemas.IsFormation(value, config)
    return type(value) == "string" and config and config.Formations and config.Formations[value] ~= nil
end

function StateSchemas.IsVector3(value)
    return typeof(value) == "Vector3"
        and finite(value.X)
        and finite(value.Y)
        and finite(value.Z)
end

function StateSchemas.ValidateArmyCommand(action, payload, config)
    if type(action) ~= "string" or type(payload) ~= "table" then
        return false, "invalid-command-shape"
    end

    if action == "RequestArmy" then
        return StateSchemas.IsArmyType(payload.ArmyType, config), "invalid-army-type"
    elseif action == "SelectArmy" then
        return tonumber(payload.ArmyId) ~= nil, "invalid-army-id"
    elseif action == "Move" then
        return StateSchemas.IsVector3(payload.Position), "invalid-move-position"
    elseif action == "Attack" then
        return tonumber(payload.TargetArmyId) ~= nil, "invalid-target-army-id"
    elseif action == "Follow" then
        return tonumber(payload.TargetArmyId) ~= nil, "invalid-follow-target-id"
    elseif action == "Retreat" then
        return true
    elseif action == "Formation" then
        return StateSchemas.IsFormation(payload.Formation, config), "invalid-formation"
    elseif action == "RecruitSoldier" then
        return tonumber(payload.ArmyId) ~= nil, "invalid-army-id"
    elseif action == "Hold" or action == "Ping" then
        return true
    elseif action == "Rematch" then
        return true
    end

    return false, "unknown-command"
end

function StateSchemas.ValidateProvinceState(state)
    if type(state) ~= "table" then return false end
    if type(state.Owner) ~= "number" then return false end
    if type(state.CaptureTeam) ~= "number" then return false end
    if not finite(state.CaptureProgress or 0) then return false end
    return true
end

return StateSchemas
