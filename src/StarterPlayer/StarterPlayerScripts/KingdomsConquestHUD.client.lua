-- Kingdoms Conquest — Stage 17 UX/UI 2.0 + Mobile Command Center
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage.Shared.Config)
local UITheme = require(ReplicatedStorage.Shared.UITheme)

if Workspace:GetAttribute("KC_RuntimeReady") ~= true then
    Workspace:GetAttributeChangedSignal("KC_RuntimeReady"):Wait()
end

local remotes = ReplicatedStorage:WaitForChild("KingdomsRemotes", 15)
if not remotes then return end

local command = remotes:WaitForChild("Command")
local stateRemote = remotes:WaitForChild("State")
local requestState = remotes:WaitForChild("RequestState")
local feedbackRemote = remotes:WaitForChild("Feedback")

local stage4Remotes = ReplicatedStorage:WaitForChild("Stage4Remotes", 15)
if not stage4Remotes then return end
local stage4StateRemote = stage4Remotes:WaitForChild("State", 15)
if not stage4StateRemote then return end

local lang = "en"
local state = {}
local selectedArmy = 0
local selectedCastle = nil
local mode = "Move"
local formation = "Line"
local mobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local reducedMotion = false
local briefingClosed = false
local lastToastId = 0
local refreshStaticText
local mapZoom = 1
local mapPan = Vector2.zero
local mapScene
local mapViewport
local mapNodes = {}
local mapEdges = {}
local armyDots = {}

local root = Instance.new("ScreenGui")
root.Name = "KingdomsStage17HUD"
root.ResetOnSpawn = false
root.IgnoreGuiInset = true
root.DisplayOrder = 120
root.Enabled = false
root.Parent = player:WaitForChild("PlayerGui")

local function color(name)
    return UITheme.Colors[name] or UITheme.Colors.White
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color("Parchment")
    s.Transparency = transparency or 0.88
    s.Thickness = 1
    s.Parent = parent
    return s
end

local function panel(parent, pos, size, transparency)
    local f = Instance.new("Frame")
    f.Position = pos
    f.Size = size
    f.BackgroundColor3 = color("Surface")
    f.BackgroundTransparency = transparency or 0.04
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 12)
    stroke(f)
    return f
end

local function label(parent, textValue, pos, size, font, textColor, xAlign)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = pos
    l.Size = size
    l.Font = font or Enum.Font.Gotham
    l.Text = textValue or ""
    l.TextColor3 = textColor or color("White")
    l.TextScaled = true
    l.TextWrapped = true
    l.TextXAlignment = xAlign or (lang == "ar" and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left)
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function button(parent, textValue, pos, size, callback, accent, icon)
    local b = Instance.new("TextButton")
    b.Position = pos
    b.Size = size
    b.Text = ""
    b.BackgroundColor3 = accent or color("Surface3")
    b.BorderSizePixel = 0
    b.AutoButtonColor = true
    b.Active = true
    b.Parent = parent
    corner(b, 10)
    stroke(b, 0.9)

    if icon then
        local i = label(b, icon, UDim2.fromScale(0.05, 0.08), UDim2.fromScale(0.22, 0.84), Enum.Font.GothamBold, color("Brass"), Enum.TextXAlignment.Center)
        i.TextWrapped = false
    end

    local title = label(
        b,
        textValue,
        icon and UDim2.fromScale(0.27, 0.04) or UDim2.fromScale(0.05, 0.04),
        icon and UDim2.fromScale(0.68, 0.92) or UDim2.fromScale(0.90, 0.92),
        Enum.Font.GothamBold,
        color("White")
    )
    title.TextXAlignment = Enum.TextXAlignment.Center
    b.Activated:Connect(callback)
    return b
end

local function toggleButton(parent, textValue, pos, size, callback)
    return button(parent, textValue, pos, size, callback, color("Surface2"))
end

local function setVisible(obj, visible)
    if obj then obj.Visible = visible end
end

local function teamColor(team)
    return UITheme.TeamColors[tonumber(team) or 0] or color("Neutral")
end

local function t(key)
    return UITheme.T(lang, key)
end

local top = panel(root, UDim2.fromScale(0.02, 0.018), UDim2.fromScale(0.96, 0.075), 0.02)

local scoreLabel = label(top, "", UDim2.fromScale(0.018, 0.10), UDim2.fromScale(0.24, 0.80), Enum.Font.GothamBold, color("Parchment"))
local timerLabel = label(top, "", UDim2.fromScale(0.28, 0.10), UDim2.fromScale(0.15, 0.80), Enum.Font.GothamBlack, color("Brass"), Enum.TextXAlignment.Center)
local objectiveLabel = label(top, "", UDim2.fromScale(0.45, 0.10), UDim2.fromScale(0.27, 0.80), Enum.Font.GothamMedium, color("Muted"), Enum.TextXAlignment.Center)
local resourcesLabel = label(top, "", UDim2.fromScale(0.69, 0.10), UDim2.fromScale(0.23, 0.80), Enum.Font.GothamBold, color("White"), Enum.TextXAlignment.Right)
local languageButton = button(top, "EN", UDim2.fromScale(0.925, 0.12), UDim2.fromScale(0.055, 0.76), function()
    lang = lang == "en" and "ar" or "en"
    languageButton:FindFirstChild("TextLabel").Text = UITheme.T(lang, "languageShort")
    refreshStaticText()
    render(state)
end, color("Surface2"))

local briefing
local leftPanel = panel(root, UDim2.fromScale(0.02, 0.105), UDim2.fromScale(0.265, 0.27), 0.035)
local leftTitle
local leftBody
local formationLabel
local formationButtons = {}
local recruitFrame
local commandPanel
local commandButtons = {}
local castlePanel
local castleTitle
local castleBody
local toastPanel
local toastLabel
local mapPanel
local mapTitle
local mapZoomOut
local mapZoomIn
local mapReset
local mobileDock
local mobileRecruit
local mobileFormation
local mobileFormationButtons = {}
local bottomEconomy

refreshStaticText = function()
    if leftTitle then leftTitle.Text = t("army") end
    if formationLabel then formationLabel.Text = t("formation") end
    if mapTitle then mapTitle.Text = t("map") end
    if commandPanel and commandPanel:FindFirstChild("Header") then commandPanel.Header.Text = t("command") end
    if castleTitle and selectedCastle then castleTitle.Text = string.upper(t("castleAction")) end

    local english = UITheme.Text.en
    local arabic = UITheme.Text.ar
    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:IsA("TextLabel") and descendant ~= timerLabel and descendant ~= scoreLabel and descendant ~= objectiveLabel and descendant ~= resourcesLabel then
            local currentText = descendant.Text
            for key, englishText in pairs(english) do
                if currentText == englishText or currentText == arabic[key] then
                    descendant.Text = t(key)
                    break
                end
            end
        end
    end
end

local function toast(message)
    if not toastPanel or not toastLabel then return end
    lastToastId += 1
    local id = lastToastId
    toastLabel.Text = message
    toastPanel.Visible = true
    task.delay(reducedMotion and 1.4 or 2.3, function()
        if lastToastId == id and toastPanel then
            toastPanel.Visible = false
        end
    end)
end

local function ensureBriefing()
    if briefing then return end
    briefing = panel(root, UDim2.fromScale(0.33, 0.18), UDim2.fromScale(0.34, 0.22), 0.02)

    local title = label(briefing, t("briefing"), UDim2.fromScale(0.07, 0.07), UDim2.fromScale(0.86, 0.18), Enum.Font.GothamBold, color("Brass"), Enum.TextXAlignment.Center)
    title.Name = "Title"

    local body = label(briefing, "", UDim2.fromScale(0.08, 0.28), UDim2.fromScale(0.84, 0.50), Enum.Font.Gotham, color("Parchment"), Enum.TextXAlignment.Center)
    body.Name = "Body"

    local close = button(briefing, "×", UDim2.fromScale(0.90, 0.05), UDim2.fromScale(0.07, 0.18), function()
        briefingClosed = true
        briefing.Visible = false
    end, color("Surface2"))
    close.Name = "Close"

    briefing.Visible = false
end

local function onboardingStep()
    if briefingClosed or not state or Workspace:GetAttribute("MatchActive") ~= true then
        return nil
    end

    local armies = state.Armies or {}
    local ownedCount = tonumber(state.Owned) or 0
    local selected = selectedArmy ~= 0 and armies[tostring(selectedArmy)] or nil
    local elapsed = 0
    local started = Workspace:GetAttribute("MatchStartedAt")
    if type(started) == "number" then
        elapsed = math.max(0, os.time() - started)
    end
    if elapsed > 90 then
        return nil
    end

    if not selected then
        return t("step1")
    end

    if selected and (selected.Order == "Move" or selected.Order == "Attack" or selected.Order == "Follow") then
        if ownedCount > 1 then
            return t("step4")
        end
        return t("step3")
    end

    if ownedCount > 1 then
        return t("step4")
    end

    if selected and selected.Formation ~= "Line" then
        return t("step5")
    end

    return t("step2")
end

local function updateBriefing()
    ensureBriefing()
    local step = onboardingStep()
    if step then
        briefing.Visible = true
        briefing.Body.Text = step
    else
        briefing.Visible = false
    end
end

local function createFormationButtons(parent, baseY)
    formationLabel = label(parent, t("formation"), UDim2.fromScale(0.04, baseY), UDim2.fromScale(0.20, 0.20), Enum.Font.GothamBold, color("Parchment"))
    local entries = {
        {id="Line", key="line", icon="═"},
        {id="Wedge", key="wedge", icon="◇"},
        {id="Spread", key="spread", icon="✦"},
        {id="Column", key="column", icon="║"},
    }
    for i, entry in ipairs(entries) do
        local b = button(
            parent,
            t(entry.key),
            UDim2.fromScale(0.24 + (i - 1) * 0.185, baseY),
            UDim2.fromScale(0.17, 0.20),
            function()
                if selectedArmy == 0 then
                    toast(t("selectArmy"))
                    return
                end
                formation = entry.id
                command:FireServer("Formation", {ArmyId = selectedArmy, Formation = entry.id})
                toast(t(entry.key) .. " • " .. t("formation"))
            end,
            entry.id == formation and color("Brass") or color("Surface3"),
            entry.icon
        )
        formationButtons[entry.id] = b
    end
end

local function refreshFormationButtons()
    for id, b in pairs(formationButtons) do
        b.BackgroundColor3 = id == formation and color("Brass") or color("Surface3")
    end
end

local function buildLeftPanel()
    leftTitle = label(leftPanel, t("army"), UDim2.fromScale(0.05, 0.06), UDim2.fromScale(0.46, 0.16), Enum.Font.GothamBold, color("Parchment"))
    leftTitle.Name = "Header"

    leftBody = label(leftPanel, t("noArmy"), UDim2.fromScale(0.05, 0.24), UDim2.fromScale(0.90, 0.46), Enum.Font.Gotham, color("Muted"))
    leftBody.Name = "Body"

    createFormationButtons(leftPanel, 0.76)
end

local function buildRecruitFrame()
    recruitFrame = panel(root, UDim2.fromScale(0.02, 0.39), UDim2.fromScale(0.265, 0.19), 0.035)
    local title = label(recruitFrame, t("recruit"), UDim2.fromScale(0.05, 0.05), UDim2.fromScale(0.90, 0.15), Enum.Font.GothamBold, color("Brass"), Enum.TextXAlignment.Center)

    local armyDefs = {
        {id="Spearmen", key="spearmen", icon="⚔", gold=Config.ArmyTypes.Spearmen.GoldCostPerSoldier, sup=Config.ArmyTypes.Spearmen.SupplyCostPerSoldier},
        {id="Archers", key="archers", icon="➶", gold=Config.ArmyTypes.Archers.GoldCostPerSoldier, sup=Config.ArmyTypes.Archers.SupplyCostPerSoldier},
        {id="Cavalry", key="cavalry", icon="♞", gold=Config.ArmyTypes.Cavalry.GoldCostPerSoldier, sup=Config.ArmyTypes.Cavalry.SupplyCostPerSoldier},
    }

    for i, data in ipairs(armyDefs) do
        local b = button(
            recruitFrame,
            string.format("%s\n%dG + %dS", data.id:upper(), data.gold, data.sup),
            UDim2.fromScale(0.035 + (i - 1) * 0.32, 0.25),
            UDim2.fromScale(0.29, 0.63),
            function()
                local selected = state.Armies and state.Armies[tostring(selectedArmy)]
                if selected and selected.Type == data.id then
                    command:FireServer("RecruitSoldier", {ArmyId = selectedArmy})
                else
                    command:FireServer("RequestArmy", {ArmyType = data.id})
                end
            end,
            color("Surface3"),
            data.icon
        )
        b.Name = "Recruit_" .. data.id
    end
end

local function buildCommandPanel()
    commandPanel = panel(root, UDim2.fromScale(0.30, 0.78), UDim2.fromScale(0.49, 0.18), 0.015)
    local header = label(commandPanel, t("command"), UDim2.fromScale(0.03, 0.03), UDim2.fromScale(0.94, 0.16), Enum.Font.GothamBold, color("Brass"), Enum.TextXAlignment.Center)
    header.Name = "Header"

    local entries = {
        {id="Move", key="move", icon="➜", hint="moveHint"},
        {id="Attack", key="attack", icon="⚔", hint="attackHint"},
        {id="Hold", key="hold", icon="■", hint="holdHint"},
        {id="Follow", key="follow", icon="↗", hint="followHint"},
        {id="Retreat", key="retreat", icon="↶", hint="retreatHint"},
    }

    for i, entry in ipairs(entries) do
        local b = button(
            commandPanel,
            t(entry.key),
            UDim2.fromScale(0.025 + (i - 1) * 0.195, 0.24),
            UDim2.fromScale(0.18, 0.34),
            function()
                mode = entry.id
                refreshCommandButtons()
                if selectedArmy == 0 then
                    toast(t("selectArmy"))
                else
                    toast(t(entry.hint))
                    if mode == "Retreat" then
                        command:FireServer("Retreat", {ArmyId = selectedArmy})
                    end
                end
            end,
            entry.id == mode and color("Brass") or color("Surface3"),
            entry.icon
        )
        commandButtons[entry.id] = b
    end

    createFormationButtons(commandPanel, 0.66)
end

local function refreshCommandButtons()
    for id, b in pairs(commandButtons) do
        b.BackgroundColor3 = id == mode and color("Brass") or color("Surface3")
    end
end

local function buildCastlePanel()
    castlePanel = panel(root, UDim2.fromScale(0.735, 0.105), UDim2.fromScale(0.245, 0.28), 0.02)
    castleTitle = label(castlePanel, t("castleAction"), UDim2.fromScale(0.06, 0.05), UDim2.fromScale(0.88, 0.16), Enum.Font.GothamBold, color("Brass"), Enum.TextXAlignment.Center)
    castleBody = label(castlePanel, t("selectCastle"), UDim2.fromScale(0.06, 0.23), UDim2.fromScale(0.88, 0.32), Enum.Font.Gotham, color("Muted"))
    castleBody.TextWrapped = true

    button(castlePanel, t("inspect"), UDim2.fromScale(0.04, 0.60), UDim2.fromScale(0.22, 0.23), function()
        if selectedCastle then
            toast(string.upper(selectedCastle))
        end
    end, color("Surface3"), "◉")

    button(castlePanel, t("focus"), UDim2.fromScale(0.28, 0.60), UDim2.fromScale(0.22, 0.23), function()
        if not selectedCastle then
            toast(t("selectCastle"))
            return
        end
        local node = state.MapNodes and state.MapNodes[selectedCastle]
        if node and node.Position and mapViewport then
            local nx, nz = mapPoint(node.Position)
            mapZoom = 1.25
            mapPan = Vector2.new(
                (0.5 - nx) * mapViewport.AbsoluteSize.X,
                (0.5 - (1 - nz)) * mapViewport.AbsoluteSize.Y
            )
            applyMapTransform()
            toast(t("focus") .. " • " .. string.upper(selectedCastle))
        end
    end, color("Surface3"), "◎")

    button(castlePanel, t("route"), UDim2.fromScale(0.52, 0.60), UDim2.fromScale(0.22, 0.23), function()
        if not selectedCastle then
            toast(t("selectCastle"))
            return
        end
        local node = state.MapNodes and state.MapNodes[selectedCastle]
        if selectedArmy ~= 0 and node and node.Position then
            mode = "Move"
            refreshCommandButtons()
            command:FireServer("Move", {ArmyId = selectedArmy, Position = node.Position})
            toast(t("route") .. " • " .. string.upper(selectedCastle))
        else
            toast(t("selectArmy"))
        end
    end, color("Surface3"), "↗")

    button(castlePanel, t("objectiveAction"), UDim2.fromScale(0.76, 0.60), UDim2.fromScale(0.20, 0.23), function()
        if selectedCastle then
            toast(t("objectiveAction") .. " • " .. string.upper(selectedCastle))
        end
    end, color("Surface3"), "★")
end

local function worldBounds(nodes)
    local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
    for _, node in pairs(nodes or {}) do
        local p = node.Position
        if typeof(p) == "Vector3" then
            minX = math.min(minX, p.X)
            maxX = math.max(maxX, p.X)
            minZ = math.min(minZ, p.Z)
            maxZ = math.max(maxZ, p.Z)
        end
    end
    if minX == math.huge then
        return 0, 1, 0, 1
    end
    return minX, maxX, minZ, maxZ
end

local mapMinX, mapMaxX, mapMinZ, mapMaxZ = 0, 1, 0, 1

local function mapPoint(position)
    local nx = (position.X - mapMinX) / math.max(1, mapMaxX - mapMinX)
    local nz = (position.Z - mapMinZ) / math.max(1, mapMaxZ - mapMinZ)
    return nx, nz
end

local function applyMapTransform()
    if not mapScene then return end
    local baseSize = 1.0
    local scale = math.clamp(mapZoom, 0.85, 1.8)
    mapScene.Size = UDim2.fromScale(baseSize * scale, baseSize * scale)
    mapScene.Position = UDim2.new(0.5, mapPan.X, 0.5, mapPan.Y)
end

local function clearMapVisuals()
    for _, nodeButton in pairs(mapNodes) do
        nodeButton:Destroy()
    end
    for _, edge in pairs(mapEdges) do
        edge:Destroy()
    end
    for _, dot in pairs(armyDots) do
        dot:Destroy()
    end
    mapNodes = {}
    mapEdges = {}
    armyDots = {}
end

local function makeMapLine(parent, a, b)
    local ax, az = mapPoint(a.Position)
    local bx, bz = mapPoint(b.Position)
    local x1, y1 = ax, 1 - az
    local x2, y2 = bx, 1 - bz
    local dx, dy = x2 - x1, y2 - y1
    local distance = math.sqrt(dx * dx + dy * dy)
    local line = Instance.new("Frame")
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Position = UDim2.fromScale((x1 + x2) * 0.5, (y1 + y2) * 0.5)
    line.Size = UDim2.fromScale(distance, 0.012)
    line.BackgroundColor3 = Color3.fromRGB(132, 116, 84)
    line.BackgroundTransparency = 0.30
    line.BorderSizePixel = 0
    line.Rotation = math.deg(math.atan2(dy, dx))
    line.ZIndex = 1
    line.Parent = parent
    return line
end

local function buildMap()
    mapPanel = panel(root, UDim2.fromScale(0.735, 0.405), UDim2.fromScale(0.245, 0.355), 0.02)
    mapTitle = label(mapPanel, t("map"), UDim2.fromScale(0.06, 0.03), UDim2.fromScale(0.52, 0.12), Enum.Font.GothamBold, color("Parchment"))
    mapTitle.TextXAlignment = Enum.TextXAlignment.Left

    mapZoomOut = button(mapPanel, "−", UDim2.fromScale(0.64, 0.025), UDim2.fromScale(0.09, 0.13), function()
        mapZoom = math.max(0.85, mapZoom - 0.12)
        applyMapTransform()
    end, color("Surface2"))

    mapZoomIn = button(mapPanel, "+", UDim2.fromScale(0.74, 0.025), UDim2.fromScale(0.09, 0.13), function()
        mapZoom = math.min(1.8, mapZoom + 0.12)
        applyMapTransform()
    end, color("Surface2"))

    mapReset = button(mapPanel, "•", UDim2.fromScale(0.84, 0.025), UDim2.fromScale(0.09, 0.13), function()
        mapZoom = 1
        mapPan = Vector2.zero
        applyMapTransform()
    end, color("Surface2"))

    mapViewport = Instance.new("Frame")
    mapViewport.Position = UDim2.fromScale(0.04, 0.18)
    mapViewport.Size = UDim2.fromScale(0.92, 0.77)
    mapViewport.BackgroundColor3 = color("Ink")
    mapViewport.BackgroundTransparency = 0.12
    mapViewport.BorderSizePixel = 0
    mapViewport.ClipsDescendants = true
    mapViewport.Active = true
    mapViewport.Parent = mapPanel
    corner(mapViewport, 10)

    mapScene = Instance.new("Frame")
    mapScene.AnchorPoint = Vector2.new(0.5, 0.5)
    mapScene.Position = UDim2.fromScale(0.5, 0.5)
    mapScene.Size = UDim2.fromScale(1, 1)
    mapScene.BackgroundTransparency = 1
    mapScene.Parent = mapViewport

    local dragStart
    local dragPanStart
    local touchPositions = {}
    local lastTouchCenter
    local lastTouchDistance

    local function updateTouchGesture()
        local points = {}
        for _, p in pairs(touchPositions) do
            table.insert(points, p)
        end
        if #points == 1 then
            local current = points[1]
            if lastTouchCenter then
                local delta = current - lastTouchCenter
                mapPan += Vector2.new(delta.X, delta.Y)
            end
            lastTouchCenter = current
        elseif #points >= 2 then
            local a = points[1]
            local b = points[2]
            local center = (a + b) * 0.5
            local distance = (a - b).Magnitude
            if lastTouchCenter then
                mapPan += Vector2.new(center.X - lastTouchCenter.X, center.Y - lastTouchCenter.Y)
            end
            if lastTouchDistance and lastTouchDistance > 1 then
                mapZoom = math.clamp(mapZoom * (distance / lastTouchDistance), 0.85, 1.8)
            end
            lastTouchCenter = center
            lastTouchDistance = distance
        end
        applyMapTransform()
    end

    mapViewport.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            dragPanStart = mapPan
        elseif input.UserInputType == Enum.UserInputType.Touch then
            touchPositions[input] = input.Position
            lastTouchCenter = nil
            lastTouchDistance = nil
        end
    end)

    mapViewport.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local delta = input.Position - dragStart
            mapPan = dragPanStart + Vector2.new(delta.X, delta.Y)
            applyMapTransform()
        elseif input.UserInputType == Enum.UserInputType.Touch then
            touchPositions[input] = input.Position
            updateTouchGesture()
        end
    end)

    mapViewport.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = nil
        elseif input.UserInputType == Enum.UserInputType.Touch then
            touchPositions[input] = nil
            if next(touchPositions) == nil then
                lastTouchCenter = nil
                lastTouchDistance = nil
            end
        end
    end)
end

local function refreshMap()
    if not mapScene or not state.MapNodes then return end
    clearMapVisuals()
    mapMinX, mapMaxX, mapMinZ, mapMaxZ = worldBounds(state.MapNodes)

    local nodes = state.MapNodes
    for _, edge in ipairs(state.MapEdges or {}) do
        local a = nodes[edge[1]]
        local b = nodes[edge[2]]
        if a and b then
            table.insert(mapEdges, makeMapLine(mapScene, a, b))
        end
    end

    for id, node in pairs(nodes) do
        local nx, nz = mapPoint(node.Position)
        local b = Instance.new("TextButton")
        b.Name = "Node_" .. tostring(id)
        b.AnchorPoint = Vector2.new(0.5, 0.5)
        b.Position = UDim2.fromScale(nx, 1 - nz)
        b.Size = UDim2.fromOffset(node.Capital and 28 or 21, node.Capital and 28 or 21)
        b.BackgroundColor3 = teamColor(state.Provinces and state.Provinces[id] and state.Provinces[id].Owner or 0)
        b.BorderSizePixel = 0
        b.Text = node.Capital and "★" or "•"
        b.TextColor3 = color("Parchment")
        b.Font = Enum.Font.GothamBold
        b.TextScaled = true
        b.ZIndex = 3
        b.Parent = mapScene
        corner(b, 8)

        b.Activated:Connect(function()
            selectedCastle = id
            toast(string.upper(t("selectCastle")) .. " • " .. tostring(node.Name or id))
            renderCastle()
        end)

        mapNodes[id] = b
    end

    applyMapTransform()
    refreshArmyDots()
end

function refreshArmyDots()
    if not mapScene or not state.Armies then return end
    for _, dot in pairs(armyDots) do dot:Destroy() end
    armyDots = {}
    for id, army in pairs(state.Armies) do
        if typeof(army.Position) == "Vector3" then
            local nx, nz = mapPoint(army.Position)
            local dot = Instance.new("TextButton")
            dot.Name = "Army_" .. tostring(id)
            dot.AnchorPoint = Vector2.new(0.5, 0.5)
            dot.Position = UDim2.fromScale(nx, 1 - nz)
            dot.Size = UDim2.fromOffset(selectedArmy == tonumber(id) and 17 or 12, selectedArmy == tonumber(id) and 17 or 12)
            dot.BackgroundColor3 = teamColor(army.Team)
            dot.BorderSizePixel = 0
            dot.Text = ""
            dot.ZIndex = 5
            dot.Parent = mapScene
            corner(dot, 8)
            dot.Activated:Connect(function()
                local armyId = tonumber(id)
                if armyId and army.Team == state.Team then
                    selectedArmy = armyId
                    command:FireServer("SelectArmy", {ArmyId = selectedArmy})
                    render(state)
                end
            end)
            armyDots[id] = dot
        end
    end
end

local function renderCastle()
    if not castlePanel then return end
    if not selectedCastle then
        castleBody.Text = t("selectCastle")
        return
    end

    local castle = state.Castles and state.Castles[selectedCastle]
    local node = state.MapNodes and state.MapNodes[selectedCastle]
    castleTitle.Text = tostring(node and node.Name or selectedCastle)
    if not castle then
        castleBody.Text = t("selectCastle")
        return
    end

    local capture = tonumber(castle.CaptureProgress) or 0
    local captureSeconds = math.max(1, tonumber(state.MatchCaptureSeconds) or Config.Game.CaptureSeconds or 10)
    local capturePercent = math.clamp(capture / captureSeconds * 100, 0, 100)
    castleBody.Text = string.format(
        "%s • %s\n%s: %d\n%s: %s\n%s: %s\n%s: %d/%d\n%s: %d%%",
        tostring(node and node.Name or selectedCastle),
        localizedTier(castle.Tier),
        t("owned"),
        tonumber(castle.Owner) or 0,
        t("state"),
        string.upper(localizedState(castle.State or "Safe")),
        t("garrison"),
        tonumber(castle.Garrison) or 0,
        tonumber(castle.MaxGarrison) or 0,
        t("capture"),
        math.floor(capturePercent)
    )
end

local function localizedTier(value)
    local key = ({Capital="capital", Major="major", Regional="regional"})[tostring(value)]
    return key and t(key) or tostring(value or t("regional"))
end

local function localizedArmyType(value)
    local key = ({Spearmen="spearmen", Archers="archers", Cavalry="cavalry"})[value]
    return key and t(key) or tostring(value or t("army"))
end

local function localizedState(value)
    local key = ({
        Safe="safe", Assaulted="assaulted", Stabilizing="stabilizing",
        Searching="searching", Approaching="approaching", Engaging="engaging",
        Ranged="ranged", Retreating="retreating", Recovering="recovering",
        Following="following", Move="moving", Hold="holding", Retreat="retreating",
    })[tostring(value)]
    return key and t(key) or tostring(value or "")
end

local function renderArmy()
    local army = selectedArmy ~= 0 and state.Armies and state.Armies[tostring(selectedArmy)] or nil
    if not army then
        leftBody.Text = t("noArmy") .. "\n" .. t("recruitHint")
        return
    end

    local destination = army.TargetPosition
    local destinationText = destination and string.format("%.0f, %.0f", destination.X, destination.Z) or "—"
    local economy = state.Economy or {}
    local economyTag = economy.EconomyStrain and t("strain") or (economy.Comeback and t("comeback") or t("stable"))

    leftBody.Text = string.format(
        "%s • %d/%d\n%s %d  •  %s %d\n%s %.0f  •  %s %s\n%s %s\n%s: %s\n%s: %s",
        string.upper(localizedArmyType(army.Type)),
        tonumber(army.SoldierCount) or 0,
        math.max(0, math.floor((army.SoldierCount or 0))),
        t("health"),
        math.floor(army.Health or 0),
        t("morale"),
        math.floor(army.Morale or 0),
        t("fatigue"),
        tonumber(army.Fatigue) or 0,
        t("power"),
        tonumber(army.Power) or 0,
        t("order"),
        string.upper(localizedState(army.Order or "Hold")),
        t("destination"),
        destinationText,
        t("state"),
        string.upper(localizedState(army.CombatState or "Searching"))
    )
    refreshFormationButtons()
end

function render(s)
    state = s or state
    selectedArmy = tonumber(state.SelectedArmy) or selectedArmy

    local team = tonumber(state.Team) or 0
    local owned = tonumber(state.Owned) or 0
    local total = tonumber(state.TotalProvinces) or 0
    scoreLabel.Text = string.format("%s  •  %s %d/%d", UITheme.TeamName(team, lang), t("territory"), owned, total)

    local started = Workspace:GetAttribute("MatchStartedAt")
    local remaining = Config.Game.MatchLengthSeconds or 1200
    if type(started) == "number" and started > 0 then
        remaining = math.max(0, (Config.Game.MatchLengthSeconds or 1200) - (os.time() - started))
    end
    timerLabel.Text = string.format("%02d:%02d", math.floor(remaining / 60), remaining % 60)
    objectiveLabel.Text = string.format("%s  •  %s  •  %d %s", t("objective"), tostring(state.MapId or t("world")), tonumber(state.TeamCount) or 2, t("armies"))

    local eco = state.Economy or {}
    resourcesLabel.Text = string.format(
        "%s %d  •  %s %d  •  %s %.1f/m  •  %s %.1f/m",
        t("gold"),
        math.floor(state.Gold or 0),
        t("supplies"),
        math.floor(state.Supplies or 0),
        t("income"),
        tonumber(eco.GoldIncomePerMinute) or 0,
        t("upkeep"),
        tonumber(eco.UpkeepGoldPerMinute) or 0
    )

    renderArmy()
    renderCastle()
    updateBriefing()
    refreshCommandButtons()
    refreshFormationButtons()

    if state.MapNodes and next(mapNodes) == nil then
        refreshMap()
    else
        for id, nodeButton in pairs(mapNodes) do
            local owner = state.Provinces and state.Provinces[id] and state.Provinces[id].Owner or 0
            nodeButton.BackgroundColor3 = teamColor(owner)
            nodeButton.Text = state.Castles and state.Castles[id] and ((state.Castles[id].State == "Contested" or state.Castles[id].State == "Assaulted") and "!" or (state.MapNodes[id].Capital and "★" or "•")) or "•"
        end
        refreshArmyDots()
    end
end

local function setMode(entry)
    mode = entry
    refreshCommandButtons()
    local army = selectedArmy ~= 0 and state.Armies and state.Armies[tostring(selectedArmy)]
    if selectedArmy == 0 then
        toast(t("selectArmy"))
        return
    end
    if mode == "Retreat" then
        command:FireServer("Retreat", {ArmyId = selectedArmy})
        toast(t("retreat"))
    elseif mode == "Follow" then
        toast(t("followHint"))
    elseif mode == "Attack" then
        toast(t("attackHint"))
    else
        toast(t(entry == "Move" and "moveHint" or "holdHint"))
    end
end

function clickWorld()
    local mouse = UserInputService:GetMouseLocation()
    local camera = Workspace.CurrentCamera
    if not camera then return end

    local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = player.Character and {player.Character} or {}

    local hit = Workspace:Raycast(ray.Origin, ray.Direction * 700, params)
    if not hit then return end

    local function attributeUp(instance, name)
        local cursor = instance
        while cursor and cursor ~= Workspace do
            local value = cursor:GetAttribute(name)
            if value ~= nil then return value end
            cursor = cursor.Parent
        end
        return nil
    end

    local armyId = tonumber(attributeUp(hit.Instance, "ArmyId") or 0)
    local provinceId = attributeUp(hit.Instance, "Province")

    if armyId > 0 then
        local army = state.Armies and state.Armies[tostring(armyId)]
        if mode == "Attack" and selectedArmy ~= 0 and army and army.Team ~= state.Team then
            command:FireServer("Attack", {ArmyId = selectedArmy, TargetArmyId = armyId})
            toast(t("attack") .. " • #" .. tostring(armyId))
        elseif mode == "Follow" and selectedArmy ~= 0 and army and army.Team == state.Team and armyId ~= selectedArmy then
            command:FireServer("Follow", {ArmyId = selectedArmy, TargetArmyId = armyId})
            toast(t("follow") .. " • #" .. tostring(armyId))
        else
            selectedArmy = armyId
            command:FireServer("SelectArmy", {ArmyId = selectedArmy})
            toast(t("selected") .. " • " .. tostring(army and army.Type or t("army")))
            render(state)
        end
        return
    end

    if provinceId then
        selectedCastle = tostring(provinceId)
        renderCastle()

        local node = state.MapNodes and state.MapNodes[selectedCastle]
        if selectedArmy ~= 0 and node and node.Position then
            if mode == "Move" then
                command:FireServer("Move", {ArmyId = selectedArmy, Position = node.Position})
                toast(t("move") .. " • " .. tostring(node.Name or selectedCastle))
            elseif mode == "Hold" then
                command:FireServer("Hold", {ArmyId = selectedArmy})
                toast(t("hold"))
            else
                toast(t("selectCastle") .. " • " .. tostring(node.Name or selectedCastle))
            end
        else
            toast(t("selectCastle") .. " • " .. tostring(node and node.Name or selectedCastle))
        end
        return
    end

    if selectedArmy ~= 0 and mode == "Move" then
        command:FireServer("Move", {ArmyId = selectedArmy, Position = hit.Position})
        toast(t("move"))
    end
end

local function buildMobileDock()
    mobileDock = panel(root, UDim2.fromScale(0.02, 0.77), UDim2.fromScale(0.96, 0.205), 0.01)

    local entries = {
        {id="Move", key="move", icon="➜"},
        {id="Attack", key="attack", icon="⚔"},
        {id="Hold", key="hold", icon="■"},
        {id="Follow", key="follow", icon="↗"},
        {id="Retreat", key="retreat", icon="↶"},
    }

    for i, entry in ipairs(entries) do
        button(
            mobileDock,
            t(entry.key),
            UDim2.fromScale(0.02 + (i - 1) * 0.194, 0.09),
            UDim2.fromScale(0.182, 0.34),
            function()
                setMode(entry.id)
            end,
            entry.id == mode and color("Brass") or color("Surface3"),
            entry.icon
        )
    end

    mobileFormation = panel(mobileDock, UDim2.fromScale(0.02, 0.49), UDim2.fromScale(0.58, 0.43), 0.04)
    local entriesFormation = {
        {id="Line", key="line"},
        {id="Wedge", key="wedge"},
        {id="Spread", key="spread"},
        {id="Column", key="column"},
    }
    for i, entry in ipairs(entriesFormation) do
        local mobileButton = button(
            mobileFormation,
            t(entry.key),
            UDim2.fromScale(0.02 + (i - 1) * 0.245, 0.12),
            UDim2.fromScale(0.225, 0.76),
            function()
                if selectedArmy == 0 then
                    toast(t("selectArmy"))
                    return
                end
                formation = entry.id
                command:FireServer("Formation", {ArmyId = selectedArmy, Formation = formation})
                refreshFormationButtons()
                for id, otherButton in pairs(mobileFormationButtons) do
                    otherButton.BackgroundColor3 = id == formation and color("Brass") or color("Surface3")
                end
                toast(t(entry.key))
            end,
            entry.id == formation and color("Brass") or color("Surface3")
        )
        mobileFormationButtons[entry.id] = mobileButton
    end

    mobileRecruit = button(mobileDock, t("recruit"), UDim2.fromScale(0.63, 0.49), UDim2.fromScale(0.35, 0.43), function()
        if mobileRecruit then
            recruitFrame.Visible = not recruitFrame.Visible
        end
    end, color("Brass"), "＋")
end

local function buildToast()
    toastPanel = panel(root, UDim2.fromScale(0.32, 0.105), UDim2.fromScale(0.36, 0.075), 0.02)
    toastLabel = label(toastPanel, "", UDim2.fromScale(0.06, 0.05), UDim2.fromScale(0.88, 0.90), Enum.Font.GothamBold, color("Parchment"), Enum.TextXAlignment.Center)
    toastPanel.Visible = false
end

buildLeftPanel()
buildRecruitFrame()
buildCommandPanel()
buildCastlePanel()
buildMap()
buildToast()

if mobile then
    leftPanel.Position = UDim2.fromScale(0.02, 0.105)
    leftPanel.Size = UDim2.fromScale(0.58, 0.20)
    recruitFrame.Position = UDim2.fromScale(0.61, 0.105)
    recruitFrame.Size = UDim2.fromScale(0.37, 0.20)
    castlePanel.Position = UDim2.fromScale(0.02, 0.395)
    castlePanel.Size = UDim2.fromScale(0.96, 0.18)
    mapPanel.Position = UDim2.fromScale(0.02, 0.59)
    mapPanel.Size = UDim2.fromScale(0.96, 0.16)
    commandPanel.Visible = false
    recruitFrame.Visible = false
    bottomEconomy = panel(root, UDim2.fromScale(0.02, 0.315), UDim2.fromScale(0.96, 0.065), 0.02)
    local economyText = label(bottomEconomy, "", UDim2.fromScale(0.04, 0.08), UDim2.fromScale(0.92, 0.84), Enum.Font.GothamBold, color("Brass"), Enum.TextXAlignment.Center)
    bottomEconomy.Name = "MobileEconomy"
    mobileDock = nil
    buildMobileDock()
else
    mobileDock = nil
    bottomEconomy = panel(root, UDim2.fromScale(0.02, 0.78), UDim2.fromScale(0.265, 0.17), 0.035)
    local economyText = label(bottomEconomy, "", UDim2.fromScale(0.05, 0.08), UDim2.fromScale(0.90, 0.84), Enum.Font.GothamBold, color("Brass"), Enum.TextXAlignment.Center)
    bottomEconomy.Name = "DesktopEconomy"
end

local function renderEconomyStrip()
    if not bottomEconomy then return end
    local economyText = bottomEconomy:FindFirstChildWhichIsA("TextLabel")
    if not economyText then return end
    local eco = state.Economy or {}
    economyText.Text = string.format(
        "%s %d   •   %s %d   •   %s %.1f/m   •   %s %.1f/m   •   %s",
        t("gold"),
        math.floor(state.Gold or 0),
        t("supplies"),
        math.floor(state.Supplies or 0),
        t("income"),
        tonumber(eco.GoldIncomePerMinute) or 0,
        t("upkeep"),
        tonumber(eco.UpkeepGoldPerMinute) or 0,
        eco.EconomyStrain and t("strain") or (eco.Comeback and t("comeback") or t("stable"))
    )
end

local oldRender = render
render = function(s)
    oldRender(s)
    renderEconomyStrip()
    refreshStaticText()
end

stateRemote.OnClientEvent:Connect(function(s)
    if type(s) ~= "table" then return end
    render(s)
end)

stage4StateRemote.OnClientEvent:Connect(function(s)
    if type(s) ~= "table" then return end
    root.Enabled = s.MatchActive == true
    if not root.Enabled then
        if briefing then briefing.Visible = false end
    end
end)

feedbackRemote.OnClientEvent:Connect(function(kind, payload)
    payload = payload or {}
    if kind == "ARMY_CREATED" then
        selectedArmy = tonumber(payload.ArmyId) or selectedArmy
        toast(string.format("%s • %d", t("ready"), tonumber(payload.SoldierCount) or 0))
    elseif kind == "SOLDIER_RECRUITED" then
        toast(string.format("+1 • %s • %d", tostring(payload.ArmyType or t("army")), tonumber(payload.SoldierCount) or 0))
    elseif kind == "ARMY_FAILED" then
        toast(t("invalid") .. " • " .. tostring(payload.Reason or ""))
    elseif kind == "COMMAND_REJECTED" then
        toast(t("invalid"))
    end
    render(state)
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not root.Enabled then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        clickWorld()
        return
    end

    if input.KeyCode == Enum.KeyCode.M then setMode("Move") end
    if input.KeyCode == Enum.KeyCode.A then setMode("Attack") end
    if input.KeyCode == Enum.KeyCode.H then setMode("Hold") end
    if input.KeyCode == Enum.KeyCode.F then setMode("Follow") end
    if input.KeyCode == Enum.KeyCode.R then setMode("Retreat") end
    if input.KeyCode == Enum.KeyCode.One then formation = "Line"; command:FireServer("Formation", {ArmyId = selectedArmy, Formation = formation}) end
    if input.KeyCode == Enum.KeyCode.Two then formation = "Wedge"; command:FireServer("Formation", {ArmyId = selectedArmy, Formation = formation}) end
    if input.KeyCode == Enum.KeyCode.Three then formation = "Spread"; command:FireServer("Formation", {ArmyId = selectedArmy, Formation = formation}) end
    if input.KeyCode == Enum.KeyCode.Four then formation = "Column"; command:FireServer("Formation", {ArmyId = selectedArmy, Formation = formation}) end
end)

local ok, initialState = pcall(function()
    return requestState:InvokeServer()
end)

if ok and type(initialState) == "table" then
    render(initialState)
    root.Enabled = Workspace:GetAttribute("MatchActive") == true
end

Workspace:GetAttributeChangedSignal("MatchActive"):Connect(function()
    root.Enabled = Workspace:GetAttribute("MatchActive") == true
    if root.Enabled then
        briefingClosed = false
        updateBriefing()
    end
end)

task.spawn(function()
    while root.Parent do
        task.wait(reducedMotion and 1 or 0.35)
        if root.Enabled then
            render(state)
        end
    end
end)
