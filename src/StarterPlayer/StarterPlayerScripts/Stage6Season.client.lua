local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local UITheme=require(game:GetService("ReplicatedStorage").Shared.UITheme)
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("Stage7SeasonRemotes")
local request=remotes:WaitForChild("RequestSeason")
local changed=remotes:WaitForChild("SeasonChanged")

local gui=Instance.new("ScreenGui")
gui.Name="KingdomsStage6Season"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=95
gui.Parent=player:WaitForChild("PlayerGui")
gui.Enabled = workspace:GetAttribute("MatchActive") == true
workspace:GetAttributeChangedSignal("MatchActive"):Connect(function()
	gui.Enabled = workspace:GetAttribute("MatchActive") == true
	if not gui.Enabled then panel.Visible = false end
end)

local badge=Instance.new("TextButton")
badge.AnchorPoint=Vector2.new(1,0)
badge.Position=UDim2.fromScale(.985,.025)
badge.Size=UDim2.fromScale(.22,.055)
badge.Text=UITheme.T("en","season")
badge.Font=Enum.Font.GothamBold
badge.TextScaled=true
badge.TextColor3=Color3.fromRGB(235,228,210)
badge.BackgroundColor3=Color3.fromRGB(38,43,42)
badge.BorderSizePixel=0
badge.Parent=gui
Instance.new("UICorner",badge).CornerRadius=UDim.new(0,8)

local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(1,0)
panel.Position=UDim2.fromScale(.985,.09)
panel.Size=UDim2.fromScale(.30,.25)
panel.BackgroundColor3=Color3.fromRGB(25,29,29)
panel.BorderSizePixel=0
panel.Visible=false
badge.Activated:Connect(function() panel.Visible=not panel.Visible end)
panel.Parent=gui
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,12)

local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Position=UDim2.fromScale(.07,.08)
title.Size=UDim2.fromScale(.86,.24)
title.Font=Enum.Font.GothamBold
title.TextScaled=true
title.TextColor3=Color3.fromRGB(238,228,205)
title.Parent=panel

local info=title:Clone()
info.Position=UDim2.fromScale(.07,.35)
info.Size=UDim2.fromScale(.86,.5)
info.Font=Enum.Font.Gotham
info.TextWrapped=true
info.Parent=panel

local function render(data)
 if not data then return end
 local s=data.Season or data
 title.Text=s.DisplayName or "SEASON"
 local ends=s.EndUnix and os.date("!%Y-%m-%d",s.EndUnix) or "-"
 info.Text=string.format("%s\nSeason XP: %d\nEnds: %s",s.Theme or "",data.XP or 0,ends)
 badge.Text="SEASON • "..tostring(data.XP or 0).." XP"
end
changed.OnClientEvent:Connect(render)
local ok,data=pcall(function() return request:InvokeServer() end)
if ok then render(data) end

