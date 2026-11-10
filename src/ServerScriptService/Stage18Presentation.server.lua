-- Kingdoms Conquest — Stage 18 presentation/personality runtime gate
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local NetworkContract = require(ReplicatedStorage.Shared.NetworkContract)
local StateSchemas = require(ReplicatedStorage.Shared.StateSchemas)
local SoldierService = require(script.Parent.Services.SoldierService)
local CombatService = require(script.Parent.Services.CombatService)

local function waitReady(name)
	if workspace:GetAttribute(name) ~= true then
		workspace:GetAttributeChangedSignal(name):Wait()
	end
end

waitReady("KC_BootstrapReady")
waitReady("KC_RuntimeReady")
waitReady("KC_Stage16Ready")
waitReady("KC_Stage17Ready")

local remotes, remoteSet = NetworkContract.Ensure()
local networkReady = remotes ~= nil
	and remoteSet.Command ~= nil
	and remoteSet.State ~= nil
	and remoteSet.Feedback ~= nil
	and remoteSet.VFX ~= nil

local sample = SoldierService.Create(Config, {
	Id = "STAGE18-PROBE",
	ArmyId = 18,
	Role = "Spearmen",
	PersonalitySeed = 1800001,
})

local personalityReady =
	sample.Courage >= 0 and sample.Courage <= 100
	and sample.Aggression >= 0 and sample.Aggression <= 100
	and sample.Discipline >= 0 and sample.Discipline <= 100
	and sample.Loyalty >= 0 and sample.Loyalty <= 100
	and CombatService.GetTerrainModifiers ~= nil
	and CombatService.CanDisengage ~= nil
	and type(StateSchemas.Version) == "number"
	and StateSchemas.Version >= 4

local presentationReady = Config.Stage18 ~= nil
	and Config.Stage18.BannerSwayDegrees ~= nil
	and Config.Stage18.CapturePulseSeconds ~= nil
	and Config.Stage18.OptionalAudioAttributes ~= nil

local valid = networkReady and personalityReady and presentationReady

workspace:SetAttribute("KC_Stage18Ready", valid)
workspace:SetAttribute("KC_Stage18Studio", RunService:IsStudio())
workspace:SetAttribute("KC_Stage18StateSchemaVersion", StateSchemas.Version)
workspace:SetAttribute("KC_Stage18NetworkReady", networkReady)
workspace:SetAttribute("KC_Stage18PersonalityReady", personalityReady)
workspace:SetAttribute("KC_Stage18PresentationReady", presentationReady)

print(string.format(
	"[KingdomsConquest][Stage18] presentation/personality/audio %s | studio=%s | schema=v%d | network=%s | personality=%s | presentation=%s",
	valid and "ready" or "FAILED",
	tostring(RunService:IsStudio()),
	StateSchemas.Version,
	tostring(networkReady),
	tostring(personalityReady),
	tostring(presentationReady)
))
