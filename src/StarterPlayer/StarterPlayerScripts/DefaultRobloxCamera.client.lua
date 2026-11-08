-- Kingdoms Conquest — Roblox Default Camera
-- Keep the experience on Roblox's standard third-person camera behavior.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local function restoreDefaultCamera(character)
	player.CameraMode = Enum.CameraMode.Classic
	player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom

	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
	local camera = Workspace.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Custom
		camera.FieldOfView = 70
		if humanoid then
			camera.CameraSubject = humanoid
		end
	end

	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
end

player.CharacterAdded:Connect(function(character)
	task.defer(restoreDefaultCamera, character)
end)

if player.Character then
	task.defer(restoreDefaultCamera, player.Character)
end

RunService:BindToRenderStep("KingdomsConquestDefaultCameraGuard", Enum.RenderPriority.Camera.Value - 1, function()
	local camera = Workspace.CurrentCamera
	if not camera then return end
	if camera.CameraType ~= Enum.CameraType.Custom then
		camera.CameraType = Enum.CameraType.Custom
	end
	if player.CameraMode ~= Enum.CameraMode.Classic then
		player.CameraMode = Enum.CameraMode.Classic
	end
end)
