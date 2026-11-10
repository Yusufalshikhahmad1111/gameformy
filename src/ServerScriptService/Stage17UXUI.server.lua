-- Kingdoms Conquest — Stage 17 UX/UI runtime gate
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NetworkContract = require(ReplicatedStorage.Shared.NetworkContract)
local StateSchemas = require(ReplicatedStorage.Shared.StateSchemas)

if workspace:GetAttribute("KC_BootstrapReady") ~= true then
    workspace:GetAttributeChangedSignal("KC_BootstrapReady"):Wait()
end

if workspace:GetAttribute("KC_RuntimeReady") ~= true then
    workspace:GetAttributeChangedSignal("KC_RuntimeReady"):Wait()
end

local remotes, remoteSet = NetworkContract.Get()
local valid = remotes ~= nil
valid = valid and remoteSet.Command ~= nil
valid = valid and remoteSet.State ~= nil
valid = valid and remoteSet.Feedback ~= nil
valid = valid and remoteSet.RequestState ~= nil
valid = valid and StateSchemas.Version >= 3

local stage16Ready = workspace:GetAttribute("KC_Stage16Ready")
if stage16Ready == nil then
    workspace:GetAttributeChangedSignal("KC_Stage16Ready"):Wait()
    stage16Ready = workspace:GetAttribute("KC_Stage16Ready")
end

valid = valid and stage16Ready == true

workspace:SetAttribute("KC_Stage17Ready", valid)
workspace:SetAttribute("KC_Stage17Studio", RunService:IsStudio())
workspace:SetAttribute("KC_Stage17StateSchemaVersion", StateSchemas.Version)
workspace:SetAttribute("KC_Stage17NetworkReady", remotes ~= nil)
workspace:SetAttribute("KC_Stage17MobileReady", true)

print(string.format(
    "[KingdomsConquest][Stage17] UX/UI command center %s | network=v%d | stage16=%s | studio=%s",
    valid and "ready" or "FAILED",
    StateSchemas.Version,
    tostring(stage16Ready),
    tostring(RunService:IsStudio())
))

if not valid then
    warn("[KingdomsConquest][Stage17] runtime gate failed")
end
