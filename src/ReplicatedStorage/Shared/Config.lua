local Config = {}

Config.Game = {
    Name = "Kingdoms Conquest",
    Version = "MVP-2.0.0",
    TeamCount = 2,
    MapId = "Heartland",
    MatchLengthSeconds = 20 * 60,
    VictoryRatio = 0.67,
    StateBroadcastSeconds = 0.25,
    EconomyTickSeconds = 10,
    CaptureSeconds = 10,
    CaptureDecayPerSecond = 1.25,
    CastleIncomePerMinute = 5,
    HomeIncomePerMinute = 8,
    StrategicIncomePerMinute = 8,
    CapitalIncomePerMinute = 12,
}

Config.Teams = {
    [1] = {Name="Crimson", Color=Color3.fromRGB(178,61,64), BrickColor=BrickColor.new("Bright red")},
    [2] = {Name="Azure", Color=Color3.fromRGB(70,117,193), BrickColor=BrickColor.new("Bright blue")},
    [3] = {Name="Emerald", Color=Color3.fromRGB(65,142,99), BrickColor=BrickColor.new("Earth green")},
    [4] = {Name="Amber", Color=Color3.fromRGB(204,151,58), BrickColor=BrickColor.new("Bright yellow")},
}

-- Backward-compatible aliases used by earlier Stage 1/2 code.
Config.Team = {Red=Config.Teams[1], Blue=Config.Teams[2]}

Config.ArmyTypes = {
    Spearmen = {Cost=20, Health=120, Damage=14, MoveSpeed=18, AttackRange=16, AttackCooldown=0.75, Color=Color3.fromRGB(196,204,214), Accent=Color3.fromRGB(125,139,153), Label="SPEARMEN", Short="S"},
    Archers = {Cost=24, Health=90, Damage=19, MoveSpeed=15, AttackRange=34, AttackCooldown=1.15, Color=Color3.fromRGB(204,170,100), Accent=Color3.fromRGB(119,77,34), Label="ARCHERS", Short="A"},
    Cavalry = {Cost=30, Health=150, Damage=12, MoveSpeed=26, AttackRange=14, AttackCooldown=0.65, Color=Color3.fromRGB(118,118,128), Accent=Color3.fromRGB(73,84,105), Label="CAVALRY", Short="C"},
}

Config.Formations = {
    Line={Label="LINE"},
    Wedge={Label="WEDGE"},
    Column={Label="COLUMN"},
    Spread={Label="SPREAD"},
}

local Heartland = {
    Name = "Heartland",
    DisplayName = "The Heartland",
    VictoryRatio = 0.67,
    River = {Center=Vector3.new(35,0,0), HalfX=12, HalfZ=150, Speed=0.55, Size=Vector3.new(24,0.3,300)},
    Spawns = {
        [1]=Vector3.new(-34,3,-125),
        [2]=Vector3.new(34,3,125),
        [3]=Vector3.new(-125,3,45),
        [4]=Vector3.new(125,3,-45),
    },
    ProvinceOrder = {"Northwatch","Riverside","Central Keep","Highlands","West March","Southgate"},
    Provinces = {
        ["Northwatch"] = {Index=1, Position=Vector3.new(0,0,-95), Size=Vector3.new(72,2,56), Strategic=false, Income=8, StartingOwners={[2]=1,[3]=1,[4]=1}},
        ["Riverside"] = {Index=2, Position=Vector3.new(-82,0,-20), Size=Vector3.new(70,2,58), Strategic=true, Income=8, StartingOwners={[2]=1,[3]=0,[4]=2}},
        ["Central Keep"] = {Index=3, Position=Vector3.new(0,0,0), Size=Vector3.new(74,2,64), Strategic=true, Income=8, StartingOwners={[2]=0,[3]=0,[4]=0}},
        ["Highlands"] = {Index=4, Position=Vector3.new(82,0,-20), Size=Vector3.new(70,2,58), Strategic=true, Income=8, StartingOwners={[2]=2,[3]=2,[4]=2}},
        ["West March"] = {Index=5, Position=Vector3.new(-72,0,68), Size=Vector3.new(78,2,58), Strategic=false, Income=5, StartingOwners={[2]=0,[3]=3,[4]=3}},
        ["Southgate"] = {Index=6, Position=Vector3.new(0,0,104), Size=Vector3.new(74,2,54), Strategic=false, Income=8, StartingOwners={[2]=2,[3]=0,[4]=4}},
    },
}

local Riverlands = {
    Name = "Riverlands",
    DisplayName = "The Riverlands",
    VictoryRatio = 0.625,
    River = {Center=Vector3.new(0,0,18), HalfX=14, HalfZ=140, Speed=0.50, Size=Vector3.new(28,0.3,300)},
    Spawns = {
        [1]=Vector3.new(-100,3,-105),
        [2]=Vector3.new(100,3,-105),
        [3]=Vector3.new(-100,3,105),
        [4]=Vector3.new(100,3,105),
    },
    ProvinceOrder={"North Bastion","West Crossing","East Reach","Central Vale","Westwood","Eastfield","Southwatch","Southeast Gate"},
    Provinces={
        ["North Bastion"]={Index=1,Position=Vector3.new(0,0,-112),Size=Vector3.new(80,2,42),Strategic=true,Income=9,StartingOwners={[2]=1,[3]=1,[4]=1}},
        ["West Crossing"]={Index=2,Position=Vector3.new(-98,0,-52),Size=Vector3.new(55,2,52),Strategic=true,Income=8,StartingOwners={[2]=1,[3]=0,[4]=3}},
        ["East Reach"]={Index=3,Position=Vector3.new(98,0,-52),Size=Vector3.new(55,2,52),Strategic=true,Income=8,StartingOwners={[2]=2,[3]=2,[4]=2}},
        ["Central Vale"]={Index=4,Position=Vector3.new(0,0,0),Size=Vector3.new(82,2,62),Strategic=true,Income=10,StartingOwners={[2]=0,[3]=0,[4]=0}},
        ["Westwood"]={Index=5,Position=Vector3.new(-100,0,45),Size=Vector3.new(55,2,44),Strategic=false,Income=6,StartingOwners={[2]=0,[3]=3,[4]=3}},
        ["Eastfield"]={Index=6,Position=Vector3.new(100,0,45),Size=Vector3.new(55,2,44),Strategic=false,Income=6,StartingOwners={[2]=0,[3]=2,[4]=4}},
        ["Southwatch"]={Index=7,Position=Vector3.new(-55,0,108),Size=Vector3.new(70,2,38),Strategic=true,Income=8,StartingOwners={[2]=2,[3]=0,[4]=4}},
        ["Southeast Gate"]={Index=8,Position=Vector3.new(55,0,108),Size=Vector3.new(70,2,38),Strategic=false,Income=6,StartingOwners={[2]=2,[3]=3,[4]=0}},
    },
}

Config.Maps = {Heartland=Heartland, Riverlands=Riverlands}

-- Legacy aliases keep early documentation/tools compatible.
Config.ProvinceOrder = Heartland.ProvinceOrder
Config.Provinces = Heartland.Provinces

Config.Seasons = {
    {
        Id="S1_FOUNDING_WARS",
        DisplayName="Season 1 • Founding Wars",
        StartUnix=1793491200,
        DurationSeconds=28*24*60*60,
        Theme="Banners, Borders & First Crowns",
        XPPerCapture=35,
        XPPerWin=100,
        Rewards={
            {XP=500,Cosmetic="Banner_Founding_Crimson"},
            {XP=1500,Cosmetic="Banner_Founding_Azure"},
            {XP=3000,Cosmetic="Banner_Founding_Royal"},
        },
    },
}

return Config
