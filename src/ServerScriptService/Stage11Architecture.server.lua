-- Kingdoms Conquest — Stage 11 runtime health gate
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NetworkContract = require(ReplicatedStorage.Shared.NetworkContract)
local StateSchemas = require(ReplicatedStorage.Shared.StateSchemas)
local WorldBuilder = require(script.Parent.Services.WorldBuilder)

if workspace:GetAttribute("KC_BootstrapReady") ~= true then
	workspace:GetAttributeChangedSignal("KC_BootstrapReady"):Wait()
end

local remotes, remoteSet = NetworkContract.Ensure()
local mapId = workspace:GetAttribute("KC_MapId") or "Heartland"
local mapOk, mapReason = WorldBuilder.ValidateStaticMap(workspace, mapId)

workspace:SetAttribute("KC_Stage11Ready", true)
workspace:SetAttribute("KC_Stage11NetworkReady", remotes ~= nil)
workspace:SetAttribute("KC_Stage11MapReady", mapOk)
workspace:SetAttribute("KC_Stage11MapReason", mapReason or "ok")
workspace:SetAttribute("KC_Stage11Studio", RunService:IsStudio())
workspace:SetAttribute("KC_Stage11StateSchemaVersion", StateSchemas.Version)

print(string.format(
	"[KingdomsConquest][Stage11] architecture ready | network=v%d | map=%s | mapReady=%s | studio=%s",
	NetworkContract.Version,
	tostring(mapId),
	tostring(mapOk),
	tostring(RunService:IsStudio())
))

if not mapOk then
	warn("[KingdomsConquest][Stage11] static map validation: " .. tostring(mapReason))
end
