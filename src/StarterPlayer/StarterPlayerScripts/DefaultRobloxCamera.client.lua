-- Kingdoms Conquest — Roblox Default Camera
-- Do not implement a custom strategic camera. Leave camera control to Roblox.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local function restoreDefaultCamera(character)
	player.CameraMode = Enum.CameraMode.Classic

	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
	local camera = Workspace.CurrentCamera
	if camera then
		camera.CameraType = Enum.CameraType.Custom
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
