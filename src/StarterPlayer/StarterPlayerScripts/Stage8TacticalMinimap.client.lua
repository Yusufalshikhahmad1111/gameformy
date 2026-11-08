-- Kingdoms Conquest — Stage 9 Tactical Map Presentation
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("KingdomsRemotes")
local stateRemote=remotes:WaitForChild("State")
local requestState=remotes:WaitForChild("RequestState")

local gui=Instance.new("ScreenGui")
gui.Name="KingdomsStage9Minimap"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=88
gui.Parent=player:WaitForChild("PlayerGui")

local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(1,0)
panel.Position=UDim2.fromScale(.975,.155)
panel.Size=UDim2.fromScale(.25,.34)
panel.BackgroundColor3=Color3.fromRGB(22,27,28)
panel.BackgroundTransparency=.06
panel.BorderSizePixel=0
panel.Parent=gui
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,12)
local stroke=Instance.new("UIStroke",panel)
stroke.Color=Color3.fromRGB(111,101,82)
stroke.Transparency=.3

local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Position=UDim2.fromScale(.06,.035)
title.Size=UDim2.fromScale(.88,.09)
title.Font=Enum.Font.GothamBold
title.TextScaled=true
title.TextColor3=Color3.fromRGB(238,228,205)
title.TextXAlignment=Enum.TextXAlignment.Left
title.Text="TACTICAL MAP"
title.Parent=panel

local subtitle=Instance.new("TextLabel")
subtitle.BackgroundTransparency=1
subtitle.Position=UDim2.fromScale(.06,.115)
subtitle.Size=UDim2.fromScale(.88,.055)
subtitle.Font=Enum.Font.GothamMedium
subtitle.TextScaled=true
subtitle.TextColor3=Color3.fromRGB(181,176,163)
subtitle.TextXAlignment=Enum.TextXAlignment.Left
subtitle.Parent=panel

local map=Instance.new("Frame")
map.Position=UDim2.fromScale(.055,.185)
map.Size=UDim2.fromScale(.89,.67)
map.BackgroundColor3=Color3.fromRGB(48,65,55)
map.BackgroundTransparency=.08
map.BorderSizePixel=0
map.ClipsDescendants=true
map.Parent=panel
Instance.new("UICorner",map).CornerRadius=UDim.new(0,8)

local footer=Instance.new("TextLabel")
footer.BackgroundTransparency=1
footer.Position=UDim2.fromScale(.06,.88)
footer.Size=UDim2.fromScale(.88,.08)
footer.Font=Enum.Font.Gotham
footer.TextScaled=true
footer.TextColor3=Color3.fromRGB(188,185,176)
footer.TextXAlignment=Enum.TextXAlignment.Left
footer.Parent=panel

local teamColors={
 [1]=Color3.fromRGB(178,61,64),[2]=Color3.fromRGB(70,117,193),
 [3]=Color3.fromRGB(65,142,99),[4]=Color3.fromRGB(204,151,58),
 [0]=Color3.fromRGB(120,118,108),
}

local function clear()
 for _,child in ipairs(map:GetChildren()) do child:Destroy() end
end

local function point(pos,minX,maxX,minZ,maxZ)
 local nx=(pos.X-minX)/math.max(1,maxX-minX)
 local nz=(pos.Z-minZ)/math.max(1,maxZ-minZ)
 return math.clamp(nx,.04,.96),math.clamp(nz,.04,.96)
end

local function drawEdge(a,b,minX,maxX,minZ,maxZ)
 local ax,az=point(a,minX,maxX,minZ,maxZ)
 local bx,bz=point(b,minX,maxX,minZ,maxZ)
 local dx,dy=bx-ax,bz-az
 local length=math.sqrt(dx*dx+dy*dy)
 local line=Instance.new("Frame")
 line.AnchorPoint=Vector2.new(.5,.5)
 line.Position=UDim2.fromScale((ax+bx)/2,(az+bz)/2)
 line.Size=UDim2.fromScale(length,.012)
 line.Rotation=math.deg(math.atan2(dy,dx))
 line.BackgroundColor3=Color3.fromRGB(159,151,132)
 line.BackgroundTransparency=.34
 line.BorderSizePixel=0
 line.ZIndex=1
 line.Parent=map
end

local function marker(x,z,size,color,zindex)
 local dot=Instance.new("Frame")
 dot.AnchorPoint=Vector2.new(.5,.5)
 dot.Position=UDim2.fromScale(x,z)
 dot.Size=UDim2.fromScale(size,size)
 dot.BackgroundColor3=color
 dot.BorderSizePixel=0
 dot.ZIndex=zindex or 3
 dot.Parent=map
 Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
 return dot
end

local function render(s)
 if not s or not s.MapNodes then return end
 clear()
 title.Text="TACTICAL MAP"
 subtitle.Text=string.upper(tostring(s.MapId or "WORLD")).."  •  "..tostring(s.TeamCount or 2).." TEAMS"
 footer.Text=string.format("%d / %d CASTLES CONTROLLED",s.Owned or 0,s.TotalProvinces or 0)

 local minX,maxX,minZ,maxZ=math.huge,-math.huge,math.huge,-math.huge
 for _,node in pairs(s.MapNodes) do
  minX=math.min(minX,node.Position.X); maxX=math.max(maxX,node.Position.X)
  minZ=math.min(minZ,node.Position.Z); maxZ=math.max(maxZ,node.Position.Z)
 end
 local byId=s.MapNodes
 for _,edge in ipairs(s.MapEdges or {}) do
  local a=byId[edge[1]]; local b=byId[edge[2]]
  if a and b then drawEdge(a.Position,b.Position,minX,maxX,minZ,maxZ) end
 end

 for id,node in pairs(s.MapNodes) do
  local data=s.Provinces and s.Provinces[id] or {}
  local x,z=point(node.Position,minX,maxX,minZ,maxZ)
  local owner=tonumber(data.Owner) or 0
  local size=node.Capital and .075 or .052
  local dot=marker(x,z,size,teamColors[owner] or teamColors[0],3)
  dot:SetAttribute("CastleId",id)

  if node.Capital then
   local crown=Instance.new("TextLabel")
   crown.BackgroundTransparency=1
   crown.AnchorPoint=Vector2.new(.5,.5)
   crown.Position=UDim2.fromScale(.5,.5)
   crown.Size=UDim2.fromScale(1.5,1.5)
   crown.Font=Enum.Font.GothamBold
   crown.Text="◆"
   crown.TextScaled=true
   crown.TextColor3=Color3.fromRGB(247,224,163)
   crown.ZIndex=4
   crown.Parent=dot
  end

  if owner==s.Team then
   local ring=Instance.new("UIStroke",dot)
   ring.Color=Color3.fromRGB(245,235,210)
   ring.Thickness=2
  end

  if (tonumber(data.CaptureTeam) or 0) ~= 0 then
   local contested=Instance.new("UIStroke",dot)
   contested.Color=teamColors[data.CaptureTeam] or Color3.fromRGB(240,205,118)
   contested.Thickness=3
   contested.Transparency=.1
  end

  local name=Instance.new("TextLabel")
  name.BackgroundTransparency=1
  name.AnchorPoint=Vector2.new(.5,0)
  name.Position=UDim2.fromScale(.5,1.0)
  name.Size=UDim2.fromScale(3.0,1.45)
  name.Font=Enum.Font.GothamMedium
  name.Text=node.Name
  name.TextScaled=true
  name.TextColor3=Color3.fromRGB(232,228,214)
  name.TextStrokeTransparency=.45
  name.ZIndex=4
  name.Parent=dot
 end

 -- Army markers are deliberately lightweight and not rebuilt as world objects.
 for id,army in pairs(s.Armies or {}) do
  local x,z=point(army.Position,minX,maxX,minZ,maxZ)
  local dot=marker(x,z,.035,teamColors[army.Team] or teamColors[0],5)
  dot:SetAttribute("ArmyId",id)
 end
end

stateRemote.OnClientEvent:Connect(render)
local ok,s=pcall(function() return requestState:InvokeServer() end)
if ok then render(s) end
