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


Config.MapPacks = {
    Syria = {
        Id="Syria", DisplayName="SYRIA", Region="Levant", DefaultTeamCount=3,
        VictoryRatio=0.58,
        Spawns={[1]=Vector3.new(-105,3,-92),[2]=Vector3.new(105,3,-92),[3]=Vector3.new(0,3,108),[4]=Vector3.new(0,3,0)},
        Cities={
            {Id="Damascus",Name="Damascus",Province="Damascus",X=0,Z=92,Capital=true,Income=12},
            {Id="Aleppo",Name="Aleppo",Province="Aleppo",X=58,Z=-92,Capital=false,Income=10},
            {Id="Homs",Name="Homs",Province="Homs",X=-8,Z=-12,Income=9},
            {Id="Hama",Name="Hama",Province="Hama",X=-48,Z=-48,Income=8},
            {Id="Latakia",Name="Latakia",Province="Latakia",X=-112,Z=-82,Income=8},
            {Id="Tartus",Name="Tartus",Province="Tartus",X=-92,Z=-30,Income=7},
            {Id="Idlib",Name="Idlib",Province="Idlib",X=-72,Z=-92,Income=8},
            {Id="Raqqa",Name="Raqqa",Province="Raqqa",X=76,Z=-10,Income=8},
            {Id="DeirEzZor",Name="Deir ez-Zor",Province="Deir ez-Zor",X=110,Z=34,Income=8},
            {Id="Hasakah",Name="Al-Hasakah",Province="Al-Hasakah",X=108,Z=-92,Income=8},
            {Id="Daraa",Name="Daraa",Province="Daraa",X=-22,Z=118,Income=7},
            {Id="Sweida",Name="As-Suwayda",Province="As-Suwayda",X=28,Z=112,Income=7},
        },
        Edges={
            {"Damascus","Daraa"},{"Damascus","Sweida"},{"Damascus","Homs"},{"Daraa","Sweida"},
            {"Homs","Hama"},{"Homs","Tartus"},{"Hama","Idlib"},{"Hama","Raqqa"},
            {"Idlib","Aleppo"},{"Idlib","Latakia"},{"Latakia","Tartus"},{"Aleppo","Raqqa"},
            {"Aleppo","Hasakah"},{"Raqqa","DeirEzZor"},{"DeirEzZor","Hasakah"},{"Homs","Damascus"}
        },
    },
    SaudiArabia = {
        Id="SaudiArabia", DisplayName="SAUDI ARABIA", Region="Arabian Peninsula", DefaultTeamCount=4,
        VictoryRatio=0.56,
        Spawns={[1]=Vector3.new(-118,3,-88),[2]=Vector3.new(118,3,-88),[3]=Vector3.new(-118,3,94),[4]=Vector3.new(118,3,94)},
        Cities={
            {Id="Riyadh",Name="Riyadh",Province="Riyadh",X=0,Z=0,Capital=true,Income=14},
            {Id="Jeddah",Name="Jeddah",Province="Makkah",X=-100,Z=35,Income=10},
            {Id="Makkah",Name="Makkah",Province="Makkah",X=-82,Z=10,Income=11},
            {Id="Medina",Name="Medina",Province="Madinah",X=-55,Z=-38,Income=10},
            {Id="Dammam",Name="Dammam",Province="Eastern",X=108,Z=8,Income=11},
            {Id="Abha",Name="Abha",Province="Asir",X=-45,Z=92,Income=9},
            {Id="Tabuk",Name="Tabuk",Province="Tabuk",X=-100,Z=-88,Income=9},
            {Id="Hail",Name="Hail",Province="Hail",X=-20,Z=-70,Income=8},
            {Id="Jizan",Name="Jizan",Province="Jizan",X=-105,Z=112,Income=8},
            {Id="Najran",Name="Najran",Province="Najran",X=22,Z=108,Income=8},
            {Id="Sakaka",Name="Sakaka",Province="Al-Jawf",X=55,Z=-105,Income=8},
            {Id="Arar",Name="Arar",Province="Northern Borders",X=112,Z=-108,Income=8},
        },
        Edges={
            {"Riyadh","Jeddah"},{"Riyadh","Makkah"},{"Riyadh","Medina"},{"Riyadh","Dammam"},
            {"Riyadh","Hail"},{"Riyadh","Najran"},{"Jeddah","Makkah"},{"Jeddah","Medina"},
            {"Jeddah","Abha"},{"Makkah","Medina"},{"Makkah","Abha"},{"Medina","Tabuk"},
            {"Medina","Hail"},{"Dammam","Arar"},{"Dammam","Najran"},{"Hail","Sakaka"},
            {"Sakaka","Arar"},{"Abha","Jizan"},{"Abha","Najran"}
        },
    },
    Palestine = {
        Id="Palestine", DisplayName="PALESTINE", Region="Levant", DefaultTeamCount=3,
        VictoryRatio=0.58,
        Spawns={[1]=Vector3.new(-80,3,-100),[2]=Vector3.new(80,3,-100),[3]=Vector3.new(0,3,105),[4]=Vector3.new(0,3,0)},
        Cities={
            {Id="Jerusalem",Name="Jerusalem",Province="Jerusalem",X=0,Z=0,Capital=true,Income=13},
            {Id="Gaza",Name="Gaza",Province="Gaza",X=76,Z=70,Income=10},
            {Id="Hebron",Name="Hebron",Province="Hebron",X=38,Z=55,Income=9},
            {Id="Nablus",Name="Nablus",Province="Nablus",X=20,Z=-35,Income=9},
            {Id="Ramallah",Name="Ramallah",Province="Ramallah & Al-Bireh",X=-5,Z=-25,Income=9},
            {Id="Jenin",Name="Jenin",Province="Jenin",X=0,Z=-82,Income=8},
            {Id="Bethlehem",Name="Bethlehem",Province="Bethlehem",X=10,Z=28,Income=8},
            {Id="Jericho",Name="Jericho",Province="Jericho",X=48,Z=-12,Income=7},
            {Id="Tulkarm",Name="Tulkarm",Province="Tulkarm",X=-45,Z=-58,Income=7},
            {Id="Qalqilya",Name="Qalqilya",Province="Qalqilya",X=-30,Z=-35,Income=7},
            {Id="Salfit",Name="Salfit",Province="Salfit",X=-18,Z=-2,Income=7},
            {Id="Rafah",Name="Rafah",Province="Rafah",X=95,Z=108,Income=7},
        },
        Edges={
            {"Jerusalem","Ramallah"},{"Jerusalem","Bethlehem"},{"Jerusalem","Jericho"},{"Jerusalem","Hebron"},
            {"Ramallah","Nablus"},{"Ramallah","Salfit"},{"Ramallah","Jericho"},{"Nablus","Jenin"},
            {"Nablus","Tulkarm"},{"Nablus","Qalqilya"},{"Tulkarm","Jenin"},{"Tulkarm","Qalqilya"},
            {"Hebron","Bethlehem"},{"Hebron","Gaza"},{"Gaza","Rafah"},{"Jericho","Nablus"}
        },
    },
    Europe = {
        Id="Europe", DisplayName="EUROPE", Region="Europe", DefaultTeamCount=4,
        VictoryRatio=0.50,
        Spawns={[1]=Vector3.new(-120,3,-105),[2]=Vector3.new(120,3,-105),[3]=Vector3.new(-120,3,105),[4]=Vector3.new(120,3,105)},
        Cities={
            {Id="London",Name="London",Province="United Kingdom",X=-100,Z=-70,Capital=true,Income=12},
            {Id="Paris",Name="Paris",Province="France",X=-60,Z=-18,Capital=true,Income=12},
            {Id="Madrid",Name="Madrid",Province="Spain",X=-82,Z=78,Capital=true,Income=11},
            {Id="Rome",Name="Rome",Province="Italy",X=18,Z=72,Capital=true,Income=11},
            {Id="Berlin",Name="Berlin",Province="Germany",X=28,Z=-48,Capital=true,Income=12},
            {Id="Warsaw",Name="Warsaw",Province="Poland",X=76,Z=-36,Capital=true,Income=10},
            {Id="Vienna",Name="Vienna",Province="Austria",X=46,Z=18,Capital=true,Income=10},
            {Id="Prague",Name="Prague",Province="Czechia",X=20,Z=-8,Income=9},
            {Id="Amsterdam",Name="Amsterdam",Province="Netherlands",X=-44,Z=-68,Income=9},
            {Id="Brussels",Name="Brussels",Province="Belgium",X=-52,Z=-42,Income=9},
            {Id="Lisbon",Name="Lisbon",Province="Portugal",X=-118,Z=80,Income=9},
            {Id="Athens",Name="Athens",Province="Greece",X=58,Z=104,Income=9},
            {Id="Budapest",Name="Budapest",Province="Hungary",X=64,Z=2,Income=9},
            {Id="Bucharest",Name="Bucharest",Province="Romania",X=98,Z=28,Income=9},
            {Id="Stockholm",Name="Stockholm",Province="Sweden",X=20,Z=-112,Income=9},
            {Id="Oslo",Name="Oslo",Province="Norway",X=-12,Z=-116,Income=9},
        },
        Edges={
            {"London","Amsterdam"},{"London","Brussels"},{"London","Paris"},{"Paris","Brussels"},{"Paris","Madrid"},
            {"Paris","Rome"},{"Madrid","Lisbon"},{"Madrid","Rome"},{"Brussels","Amsterdam"},{"Brussels","Berlin"},
            {"Amsterdam","Berlin"},{"Berlin","Prague"},{"Berlin","Warsaw"},{"Berlin","Vienna"},{"Prague","Vienna"},
            {"Vienna","Rome"},{"Vienna","Budapest"},{"Budapest","Bucharest"},{"Rome","Athens"},{"Warsaw","Bucharest"},
            {"Stockholm","Oslo"},{"Stockholm","Berlin"},{"Oslo","London"}
        },
    },
}

return Config
