local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

if workspace:GetAttribute("KC_RuntimeReady") ~= true then
	workspace:GetAttributeChangedSignal("KC_RuntimeReady"):Wait()
end
local remotes = ReplicatedStorage:WaitForChild("KingdomsRemotes", 15)
if not remotes then return end
local vfx = remotes:WaitForChild("VFX")

local function pulse(position, color, size, duration)
	local p = Instance.new("Part")
	p.Name = "TacticalVFX"
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.new(1, 1, 1)
	p.Position = position + Vector3.new(0, 1.5, 0)
	p.Anchored = true
	p.CanCollide = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Transparency = 0.25
	p.Parent = workspace

	local tween = TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(size, size, size),
		Transparency = 1,
	})
	tween:Play()
	Debris:AddItem(p, duration + 0.1)
end

local function ring(position, color)
	local p = Instance.new("Part")
	p.Name = "PingRing"
	p.Shape = Enum.PartType.Cylinder
	p.Size = Vector3.new(0.18, 1, 1)
	p.CFrame = CFrame.new(position + Vector3.new(0, 0.25, 0)) * CFrame.Angles(0, 0, math.rad(90))
	p.Anchored = true
	p.CanCollide = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Transparency = 0.15
	p.Parent = workspace

	local tween = TweenService:Create(p, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.18, 14, 14),
		Transparency = 1,
	})
	tween:Play()
	Debris:AddItem(p, 1)
end

vfx.OnClientEvent:Connect(function(kind, position, teamOrType, defeated)
	if kind == "Hit" then
		local color = teamOrType == "Archers" and Color3.fromRGB(219, 181, 104)
			or teamOrType == "Cavalry" and Color3.fromRGB(120, 134, 157)
			or Color3.fromRGB(205, 205, 205)
		pulse(position, color, defeated and 8 or 4, defeated and 0.5 or 0.25)
	elseif kind == "Ping" then
		local color = teamOrType == 1 and Color3.fromRGB(190, 65, 68) or Color3.fromRGB(75, 121, 192)
		ring(position, color)
	end
end)