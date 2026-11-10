local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Stage 18 is the authoritative presentation layer. Keep this legacy VFX
-- client only as a fallback for boot failures.
local stage18Deadline = os.clock() + 15
while workspace:GetAttribute("KC_Stage18Ready") ~= true and os.clock() < stage18Deadline do
	task.wait(0.1)
end
if workspace:GetAttribute("KC_Stage18Ready") == true then
	return
end

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

local function traceProjectile(startPosition, endPosition, color, duration, thickness)
	local delta = endPosition - startPosition
	local distance = delta.Magnitude
	if distance <= 0.1 then return end

	local beam = Instance.new("Part")
	beam.Name = "CombatTrace"
	beam.Size = Vector3.new(thickness or 0.16, thickness or 0.16, distance)
	beam.CFrame = CFrame.lookAt(startPosition:Lerp(endPosition, 0.5), endPosition)
	beam.Anchored = true
	beam.CanCollide = false
	beam.Material = Enum.Material.Neon
	beam.Color = color
	beam.Transparency = 0.1
	beam.Parent = workspace

	TweenService:Create(beam, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Transparency = 1,
	}):Play()
	Debris:AddItem(beam, duration + 0.05)
end

vfx.OnClientEvent:Connect(function(kind, position, teamOrType, defeated, extra)
	if kind == "Hit" then
		local color = teamOrType == "Archers" and Color3.fromRGB(219, 181, 104)
			or teamOrType == "Cavalry" and Color3.fromRGB(120, 134, 157)
			or Color3.fromRGB(205, 205, 205)
		pulse(position, color, defeated and 8 or 4, defeated and 0.5 or 0.25)
	elseif kind == "Arrow" or kind == "ArrowMiss" then
		local endPosition = teamOrType
		local sourcePosition = position
		local attackerTeam = defeated
		local color = Color3.fromRGB(222, 190, 112)
		traceProjectile(sourcePosition + Vector3.new(0, 4, 0), endPosition + Vector3.new(0, 2, 0), color, kind == "Arrow" and 0.18 or 0.14, 0.12)
		if kind == "Arrow" then
			pulse(endPosition, color, defeated and 5 or 3, defeated and 0.35 or 0.22)
		end
	elseif kind == "Melee" then
		local color = teamOrType == "Cavalry" and Color3.fromRGB(126, 138, 156) or Color3.fromRGB(210, 210, 205)
		pulse(position, color, defeated and 6 or 3.5, defeated and 0.38 or 0.18)
	elseif kind == "CastleHit" then
		pulse(position, Color3.fromRGB(222, 188, 104), defeated and 8 or 4, defeated and 0.45 or 0.22)
	elseif kind == "CastleCaptured" then
		ring(position, Color3.fromRGB(224, 199, 142))
	elseif kind == "Ping" then
		local color = teamOrType == 1 and Color3.fromRGB(190, 65, 68) or Color3.fromRGB(75, 121, 192)
		ring(position, color)
	end
end)