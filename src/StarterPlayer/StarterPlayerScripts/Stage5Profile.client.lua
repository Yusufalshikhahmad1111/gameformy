local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("Stage5Remotes")
local requestProfile=remotes:WaitForChild("RequestProfile")
local profileChanged=remotes:WaitForChild("ProfileChanged")
local profileAction=remotes:WaitForChild("ProfileAction")
local gui=Instance.new("ScreenGui"); gui.Name="KingdomsStage5Profile"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.DisplayOrder=100; gui.Parent=player:WaitForChild("PlayerGui")
local panel=Instance.new("Frame"); panel.AnchorPoint=Vector2.new(1,0); panel.Position=UDim2.fromScale(.985,.12); panel.Size=UDim2.fromScale(.25,.68); panel.BackgroundColor3=Color3.fromRGB(25,29,29); panel.BorderSizePixel=0; panel.Visible=false; panel.Parent=gui; Instance.new("UICorner",panel).CornerRadius=UDim.new(0,14)
local function label(text,pos,size,font) local x=Instance.new("TextLabel"); x.BackgroundTransparency=1; x.Position=pos; x.Size=size; x.Font=font; x.Text=text; x.TextColor3=Color3.fromRGB(232,226,210); x.TextScaled=true; x.Parent=panel; return x end
label("COMMANDER PROFILE",UDim2.fromScale(.08,.05),UDim2.fromScale(.84,.08),Enum.Font.GothamBold)
local level=label("LEVEL 1",UDim2.fromScale(.08,.15),UDim2.fromScale(.42,.08),Enum.Font.GothamBold)
local coins=label("0 COINS",UDim2.fromScale(.50,.15),UDim2.fromScale(.42,.08),Enum.Font.GothamBold)
local xp=label("XP 0 / 500",UDim2.fromScale(.08,.25),UDim2.fromScale(.84,.07),Enum.Font.GothamMedium)
local stats=label("",UDim2.fromScale(.08,.35),UDim2.fromScale(.84,.28),Enum.Font.Gotham); stats.TextXAlignment=Enum.TextXAlignment.Left; stats.TextYAlignment=Enum.TextYAlignment.Top
local daily=Instance.new("TextButton"); daily.Position=UDim2.fromScale(.08,.68); daily.Size=UDim2.fromScale(.84,.10); daily.Text="CLAIM DAILY REWARD"; daily.Font=Enum.Font.GothamBold; daily.TextScaled=true; daily.TextColor3=Color3.fromRGB(238,230,211); daily.BackgroundColor3=Color3.fromRGB(91,69,38); daily.BorderSizePixel=0; daily.Parent=panel; Instance.new("UICorner",daily).CornerRadius=UDim.new(0,8)
local achievements=label("",UDim2.fromScale(.08,.81),UDim2.fromScale(.84,.13),Enum.Font.GothamMedium); achievements.TextXAlignment=Enum.TextXAlignment.Left
local profile
local function render(d) if not d then return end; profile=d; level.Text="LEVEL "..d.Level; coins.Text=tostring(d.Coins).." COINS"; xp.Text="XP "..d.XPIntoLevel.." / "..d.XPToNext; stats.Text=string.format("MATCHES  %d\nWINS  %d    LOSSES  %d\nCAPTURES  %d    KILLS  %d\nSTREAK  %d    BEST  %d",d.Matches,d.Wins,d.Losses,d.Captures,d.Kills,d.CurrentStreak,d.BestStreak); achievements.Text="ACHIEVEMENTS  "..tostring(#(d.Achievements or {})); daily.Text=d.CanClaimDaily and "CLAIM DAILY • +100 COINS / +50 XP" or "DAILY REWARD CLAIMED"; daily.Active=d.CanClaimDaily end
daily.MouseButton1Click:Connect(function() if profile and profile.CanClaimDaily then profileAction:FireServer("ClaimDaily") end end)
profileChanged.OnClientEvent:Connect(render)
local ok,data=pcall(function() return requestProfile:InvokeServer() end); if ok then render(data) end
local open=false
gui.Enabled = workspace:GetAttribute("MatchActive") == true
workspace:GetAttributeChangedSignal("MatchActive"):Connect(function()
	gui.Enabled = workspace:GetAttribute("MatchActive") == true
	if not gui.Enabled then
		panel.Visible = false
		open = false
	end
end)
local UIS=game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input,processed) if processed then return end; if input.KeyCode==Enum.KeyCode.P then open=not open; panel.Visible=open end end)
local badge=Instance.new("TextButton"); badge.AnchorPoint=Vector2.new(0,1); badge.Position=UDim2.fromScale(.025,.965); badge.Size=UDim2.fromScale(.14,.065); badge.Text="COMMANDER • LV 1"; badge.Font=Enum.Font.GothamBold; badge.TextScaled=true; badge.TextColor3=Color3.fromRGB(232,226,210); badge.BackgroundColor3=Color3.fromRGB(28,33,33); badge.BorderSizePixel=0; badge.Parent=gui; Instance.new("UICorner",badge).CornerRadius=UDim.new(0,9)
badge.MouseButton1Click:Connect(function() open=not open; panel.Visible=open end)
profileChanged.OnClientEvent:Connect(function(d) if d then badge.Text="COMMANDER • LV "..tostring(d.Level) end end)