local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local zoom = 34
local targetZoom = zoom
local minZoom = 20
local maxZoom = 58
local yaw = math.rad(34)
local pitch = math.rad(-62)

local function clamp(v,a,b)
	return math.max(a, math.min(b,v))
end

local function getFocus()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return root and root.Position or Vector3.new(0,0,0)
end

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		targetZoom = clamp(targetZoom - input.Position.Z * 3, minZoom, maxZoom)
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.KeypadPlus then
		targetZoom = clamp(targetZoom - 5, minZoom, maxZoom)
	elseif input.KeyCode == Enum.KeyCode.Minus or input.KeyCode == Enum.KeyCode.KeypadMinus then
		targetZoom = clamp(targetZoom + 5, minZoom, maxZoom)
	end
end)

RunService:BindToRenderStep("KingdomsTacticalCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
	zoom += (targetZoom - zoom) * math.min(dt * 9, 1)
	local focus = getFocus()
	local offset = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.new(0,0,zoom)
	local target = CFrame.new(focus) * offset
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.lookAt(target.Position, focus + Vector3.new(0,4,0))
end)