-- Kingdoms Conquest — Stage 8 Tactical Minimap
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("KingdomsRemotes")
local stateRemote=remotes:WaitForChild("State")
local requestState=remotes:WaitForChild("RequestState")

local gui=Instance.new("ScreenGui")
gui.Name="KingdomsStage8Minimap"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=88
gui.Parent=player:WaitForChild("PlayerGui")

local panel=Instance.new("Frame")
panel.AnchorPoint=Vector2.new(1,0)
panel.Position=UDim2.fromScale(.975,.155)
panel.Size=UDim2.fromScale(.23,.30)
panel.BackgroundColor3=Color3.fromRGB(22,27,28)
panel.BackgroundTransparency=.08
panel.BorderSizePixel=0
panel.Parent=gui
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,12)
local stroke=Instance.new("UIStroke",panel)
stroke.Color=Color3.fromRGB(111,101,82)
stroke.Transparency=.35

local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Position=UDim2.fromScale(.06,.04)
title.Size=UDim2.fromScale(.88,.12)
title.Font=Enum.Font.GothamBold
title.TextScaled=true
title.TextColor3=Color3.fromRGB(238,228,205)
title.Text="TACTICAL MAP"
title.Parent=panel

local map=Instance.new("Frame")
map.Position=UDim2.fromScale(.06,.18)
map.Size=UDim2.fromScale(.88,.68)
map.BackgroundColor3=Color3.fromRGB(48,65,55)
map.BackgroundTransparency=.12
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
 line.BackgroundColor3=Color3.fromRGB(145,143,128)
 line.BackgroundTransparency=.45
 line.BorderSizePixel=0
 line.ZIndex=1
 line.Parent=map
end

local function render(s)
 if not s or not s.MapNodes then return end
 clear()
 title.Text="TACTICAL MAP  •  "..string.upper(tostring(s.MapId or "WORLD"))
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
  local dot=Instance.new("Frame")
  dot.AnchorPoint=Vector2.new(.5,.5)
  dot.Position=UDim2.fromScale(x,z)
  dot.Size=UDim2.fromScale(node.Capital and .075 or .055,node.Capital and .075 or .055)
  dot.BackgroundColor3=teamColors[owner] or teamColors[0]
  dot.BorderSizePixel=0
  dot.ZIndex=3
  dot.Parent=map
  Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
  if owner==s.Team then
   local ring=Instance.new("UIStroke",dot)
   ring.Color=Color3.fromRGB(245,235,210)
   ring.Thickness=2
  end
  local name=Instance.new("TextLabel")
  name.BackgroundTransparency=1
  name.AnchorPoint=Vector2.new(.5,0)
  name.Position=UDim2.fromScale(.5,1)
  name.Size=UDim2.fromScale(2.8,1.5)
  name.Font=Enum.Font.GothamMedium
  name.Text=string.upper(node.Name)
  name.TextScaled=true
  name.TextColor3=Color3.fromRGB(232,228,214)
  name.TextStrokeTransparency=.5
  name.ZIndex=4
  name.Parent=dot
 end
end

stateRemote.OnClientEvent:Connect(render)
local ok,s=pcall(function() return requestState:InvokeServer() end)
if ok then render(s) end
