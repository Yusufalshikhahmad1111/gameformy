local WorldMaps = {}

local function balancedOwners(index, total, neutral)
    local result={}
    for teamCount=2,4 do
        if neutral then
            result[teamCount]=0
        else
            result[teamCount]=((index-1)%teamCount)+1
            if result[teamCount]>total then result[teamCount]=((index-1)%teamCount)+1 end
        end
    end
    return result
end

local function makeMap(name,displayName,bounds,spawns,nodes,edges,river,ratio)
    local provinces={}
    local order={}
    for i,node in ipairs(nodes) do
        order[i]=node.Name
        provinces[node.Name]={
            Index=i,
            Position=node.Position,
            Size=node.Size or Vector3.new(44,2,40),
            Strategic=node.Strategic == true,
            Income=node.Income or 6,
            StartingOwners=balancedOwners(i,#nodes,node.Neutral==true),
            City=node.City or node.Name,
            Country=node.Country or "",
        }
    end
    return {
        Name=name,
        DisplayName=displayName,
        Bounds=bounds,
        Spawns=spawns,
        ProvinceOrder=order,
        Provinces=provinces,
        Edges=edges,
        River=river,
        VictoryRatio=ratio or 0.67,
    }
end

-- Syria: 14 governorate-centered castle nodes. The gameplay coordinates are stylized, normalized battlefield positions.
WorldMaps.Syria = makeMap(
    "Syria","Syria — Governorate Wars",
    {MinX=-150,MaxX=150,MinZ=-135,MaxZ=135},
    {[1]=Vector3.new(-125,3,-105),[2]=Vector3.new(125,3,105),[3]=Vector3.new(-120,3,80),[4]=Vector3.new(120,3,-80)},
    {
        {Name="Afrin",City="Afrin",Position=Vector3.new(-105,0,-100),Strategic=false,Income=6,Country="Syria"},
        {Name="Aleppo",City="Aleppo",Position=Vector3.new(-55,0,-85),Strategic=true,Income=10,Country="Syria"},
        {Name="Idlib",City="Idlib",Position=Vector3.new(-115,0,-40),Strategic=true,Income=8,Country="Syria"},
        {Name="Latakia",City="Latakia",Position=Vector3.new(-135,0,20),Strategic=true,Income=8,Country="Syria"},
        {Name="Tartus",City="Tartus",Position=Vector3.new(-105,0,68),Strategic=false,Income=7,Country="Syria"},
        {Name="Hama",City="Hama",Position=Vector3.new(-35,0,-15),Strategic=true,Income=8,Country="Syria"},
        {Name="Homs",City="Homs",Position=Vector3.new(-25,0,45),Strategic=true,Income=10,Country="Syria"},
        {Name="Rif Dimashq",City="Rif Dimashq",Position=Vector3.new(10,0,105),Strategic=true,Income=8,Country="Syria"},
        {Name="Damascus",City="Damascus",Position=Vector3.new(25,0,78),Strategic=true,Income=12,Country="Syria"},
        {Name="Daraa",City="Daraa",Position=Vector3.new(55,0,118),Strategic=false,Income=6,Country="Syria"},
        {Name="Quneitra",City="Quneitra",Position=Vector3.new(90,0,92),Strategic=false,Income=6,Country="Syria"},
        {Name="As-Suwayda",City="As-Suwayda",Position=Vector3.new(85,0,128),Strategic=false,Income=6,Country="Syria"},
        {Name="Raqqa",City="Raqqa",Position=Vector3.new(55,0,-45),Strategic=true,Income=8,Country="Syria"},
        {Name="Deir ez-Zor",City="Deir ez-Zor",Position=Vector3.new(105,0,5),Strategic=true,Income=9,Country="Syria"},
        {Name="Hasakah",City="Hasakah",Position=Vector3.new(110,0,-78),Strategic=true,Income=8,Country="Syria"},
    },
    {
        {"Afrin","Aleppo"},{"Aleppo","Idlib"},{"Aleppo","Hama"},{"Idlib","Latakia"},{"Hama","Homs"},{"Hama","Raqqa"},{"Homs","Tartus"},{"Homs","Damascus"},{"Homs","Rif Dimashq"},{"Rif Dimashq","Damascus"},{"Rif Dimashq","Daraa"},{"Daraa","Quneitra"},{"Daraa","As-Suwayda"},{"Raqqa","Deir ez-Zor"},{"Raqqa","Hasakah"},{"Deir ez-Zor","Hasakah"},{"Damascus","Quneitra"}
    },
    {Center=Vector3.new(48,0,-5),HalfX=8,HalfZ=135,Speed=0.58,Size=Vector3.new(16,0.3,270)},
    0.67
)

-- Saudi Arabia: major city/regional-center castle nodes.
WorldMaps.SaudiArabia = makeMap(
    "SaudiArabia","Saudi Arabia — Kingdoms War",
    {MinX=-165,MaxX=165,MinZ=-135,MaxZ=135},
    {[1]=Vector3.new(-140,3,-105),[2]=Vector3.new(140,3,-105),[3]=Vector3.new(-140,3,105),[4]=Vector3.new(140,3,105)},
    {
        {Name="Tabuk",City="Tabuk",Position=Vector3.new(-105,0,-112),Strategic=true,Income=8,Country="Saudi Arabia"},
        {Name="Sakaka",City="Sakaka",Position=Vector3.new(-20,0,-118),Strategic=false,Income=6,Country="Saudi Arabia"},
        {Name="Hail",City="Hail",Position=Vector3.new(-50,0,-55),Strategic=true,Income=8,Country="Saudi Arabia"},
        {Name="Madinah",City="Madinah",Position=Vector3.new(-110,0,12),Strategic=true,Income=9,Country="Saudi Arabia"},
        {Name="Makkah",City="Makkah",Position=Vector3.new(-125,0,65),Strategic=true,Income=12,Country="Saudi Arabia"},
        {Name="Jeddah",City="Jeddah",Position=Vector3.new(-145,0,42),Strategic=true,Income=10,Country="Saudi Arabia"},
        {Name="Taif",City="Taif",Position=Vector3.new(-88,0,78),Strategic=false,Income=7,Country="Saudi Arabia"},
        {Name="Riyadh",City="Riyadh",Position=Vector3.new(15,0,12),Strategic=true,Income=12,Country="Saudi Arabia"},
        {Name="Buraydah",City="Buraydah",Position=Vector3.new(-2,0,-38),Strategic=true,Income=8,Country="Saudi Arabia"},
        {Name="Dammam",City="Dammam",Position=Vector3.new(118,0,-6),Strategic=true,Income=10,Country="Saudi Arabia"},
        {Name="Al Ahsa",City="Al-Ahsa",Position=Vector3.new(92,0,28),Strategic=true,Income=8,Country="Saudi Arabia"},
        {Name="Abha",City="Abha",Position=Vector3.new(18,0,105),Strategic=true,Income=8,Country="Saudi Arabia"},
        {Name="Jizan",City="Jizan",Position=Vector3.new(-22,0,118),Strategic=false,Income=6,Country="Saudi Arabia"},
        {Name="Najran",City="Najran",Position=Vector3.new(70,0,112),Strategic=false,Income=7,Country="Saudi Arabia"},
        {Name="Hafar Al-Batin",City="Hafar Al-Batin",Position=Vector3.new(100,0,-78),Strategic=false,Income=6,Country="Saudi Arabia"},
        {Name="Arar",City="Arar",Position=Vector3.new(66,0,-122),Strategic=false,Income=6,Country="Saudi Arabia"},
        {Name="Al Baha",City="Al Baha",Position=Vector3.new(-52,0,90),Strategic=false,Income=6,Country="Saudi Arabia"},
        {Name="Khamis Mushait",City="Khamis Mushait",Position=Vector3.new(34,0,83),Strategic=false,Income=6,Country="Saudi Arabia"},
    },
    {
        {"Tabuk","Hail"},{"Tabuk","Sakaka"},{"Sakaka","Arar"},{"Sakaka","Hail"},{"Arar","Hafar Al-Batin"},{"Hail","Buraydah"},{"Hail","Riyadh"},{"Buraydah","Riyadh"},{"Madinah","Hail"},{"Madinah","Jeddah"},{"Madinah","Makkah"},{"Jeddah","Makkah"},{"Makkah","Taif"},{"Taif","Riyadh"},{"Makkah","Al Baha"},{"Al Baha","Abha"},{"Abha","Khamis Mushait"},{"Abha","Jizan"},{"Abha","Najran"},{"Riyadh","Dammam"},{"Riyadh","Al Ahsa"},{"Dammam","Al Ahsa"},{"Dammam","Hafar Al-Batin"},{"Najran","Al Ahsa"}
    },
    {Center=Vector3.new(-5,0,15),HalfX=8,HalfZ=135,Speed=0.62,Size=Vector3.new(16,0.3,270)},
    0.67
)

-- Palestine: 16 governorate/city-centered nodes following the PCBS 11 West Bank + 5 Gaza governorate structure.
WorldMaps.Palestine = makeMap(
    "Palestine","Palestine — Governorate Front",
    {MinX=-145,MaxX=145,MinZ=-135,MaxZ=135},
    {[1]=Vector3.new(-120,3,-110),[2]=Vector3.new(120,3,110),[3]=Vector3.new(-120,3,100),[4]=Vector3.new(120,3,-100)},
    {
        {Name="Jenin",City="Jenin",Position=Vector3.new(-80,0,-110),Strategic=true,Income=7,Country="Palestine"},
        {Name="Tubas",City="Tubas",Position=Vector3.new(-35,0,-112),Strategic=false,Income=5,Country="Palestine"},
        {Name="Tulkarm",City="Tulkarm",Position=Vector3.new(-118,0,-72),Strategic=false,Income=6,Country="Palestine"},
        {Name="Nablus",City="Nablus",Position=Vector3.new(-30,0,-60),Strategic=true,Income=9,Country="Palestine"},
        {Name="Qalqilya",City="Qalqilya",Position=Vector3.new(-103,0,-30),Strategic=false,Income=6,Country="Palestine"},
        {Name="Salfit",City="Salfit",Position=Vector3.new(-62,0,-18),Strategic=false,Income=5,Country="Palestine"},
        {Name="Ramallah",City="Ramallah",Position=Vector3.new(-5,0,-12),Strategic=true,Income=10,Country="Palestine"},
        {Name="Jericho",City="Jericho",Position=Vector3.new(42,0,-22),Strategic=true,Income=7,Country="Palestine"},
        {Name="Jerusalem",City="Jerusalem",Position=Vector3.new(10,0,25),Strategic=true,Income=12,Country="Palestine"},
        {Name="Bethlehem",City="Bethlehem",Position=Vector3.new(-25,0,55),Strategic=true,Income=8,Country="Palestine"},
        {Name="Hebron",City="Hebron",Position=Vector3.new(-20,0,95),Strategic=true,Income=9,Country="Palestine"},
        {Name="North Gaza",City="North Gaza",Position=Vector3.new(88,0,42),Strategic=false,Income=6,Country="Palestine"},
        {Name="Gaza",City="Gaza",Position=Vector3.new(112,0,70),Strategic=true,Income=9,Country="Palestine"},
        {Name="Deir Al-Balah",City="Deir Al-Balah",Position=Vector3.new(105,0,103),Strategic=false,Income=6,Country="Palestine"},
        {Name="Khan Yunis",City="Khan Yunis",Position=Vector3.new(78,0,125),Strategic=true,Income=8,Country="Palestine"},
        {Name="Rafah",City="Rafah",Position=Vector3.new(35,0,135),Strategic=false,Income=6,Country="Palestine"},
    },
    {
        {"Jenin","Tubas"},{"Jenin","Tulkarm"},{"Tubas","Nablus"},{"Tulkarm","Nablus"},{"Tulkarm","Qalqilya"},{"Nablus","Salfit"},{"Nablus","Ramallah"},{"Qalqilya","Salfit"},{"Salfit","Ramallah"},{"Ramallah","Jericho"},{"Ramallah","Jerusalem"},{"Jericho","Jerusalem"},{"Jerusalem","Bethlehem"},{"Bethlehem","Hebron"},{"Gaza","North Gaza"},{"Gaza","Deir Al-Balah"},{"Deir Al-Balah","Khan Yunis"},{"Khan Yunis","Rafah"}
    },
    {Center=Vector3.new(55,0,84),HalfX=0,HalfZ=0,Speed=1,Size=Vector3.new(1,0.1,1)},
    0.625
)

-- Europe: selected capitals as strategic nodes, intentionally compressed for playable traversal.
WorldMaps.Europe = makeMap(
    "Europe","Europe — Continental Conquest",
    {MinX=-175,MaxX=175,MinZ=-130,MaxZ=130},
    {[1]=Vector3.new(-155,3,-95),[2]=Vector3.new(155,3,-95),[3]=Vector3.new(-155,3,95),[4]=Vector3.new(155,3,95)},
    {
        {Name="Lisbon",City="Lisbon",Position=Vector3.new(-150,0,50),Strategic=true,Income=7,Country="Portugal"},
        {Name="Madrid",City="Madrid",Position=Vector3.new(-125,0,36),Strategic=true,Income=9,Country="Spain"},
        {Name="Paris",City="Paris",Position=Vector3.new(-70,0,5),Strategic=true,Income=12,Country="France"},
        {Name="London",City="London",Position=Vector3.new(-86,0,-42),Strategic=true,Income=11,Country="United Kingdom"},
        {Name="Brussels",City="Brussels",Position=Vector3.new(-47,0,-25),Strategic=false,Income=7,Country="Belgium"},
        {Name="Amsterdam",City="Amsterdam",Position=Vector3.new(-42,0,-43),Strategic=true,Income=8,Country="Netherlands"},
        {Name="Berlin",City="Berlin",Position=Vector3.new(20,0,-32),Strategic=true,Income=11,Country="Germany"},
        {Name="Copenhagen",City="Copenhagen",Position=Vector3.new(25,0,-68),Strategic=false,Income=7,Country="Denmark"},
        {Name="Oslo",City="Oslo",Position=Vector3.new(4,0,-92),Strategic=false,Income=6,Country="Norway"},
        {Name="Stockholm",City="Stockholm",Position=Vector3.new(48,0,-94),Strategic=false,Income=7,Country="Sweden"},
        {Name="Helsinki",City="Helsinki",Position=Vector3.new(84,0,-82),Strategic=false,Income=6,Country="Finland"},
        {Name="Warsaw",City="Warsaw",Position=Vector3.new(66,0,-25),Strategic=true,Income=9,Country="Poland"},
        {Name="Prague",City="Prague",Position=Vector3.new(28,0,8),Strategic=true,Income=8,Country="Czechia"},
        {Name="Vienna",City="Vienna",Position=Vector3.new(58,0,21),Strategic=true,Income=8,Country="Austria"},
        {Name="Rome",City="Rome",Position=Vector3.new(-2,0,80),Strategic=true,Income=11,Country="Italy"},
        {Name="Athens",City="Athens",Position=Vector3.new(62,0,93),Strategic=true,Income=9,Country="Greece"},
        {Name="Bucharest",City="Bucharest",Position=Vector3.new(112,0,45),Strategic=true,Income=8,Country="Romania"},
        {Name="Sofia",City="Sofia",Position=Vector3.new(87,0,70),Strategic=false,Income=7,Country="Bulgaria"},
        {Name="Budapest",City="Budapest",Position=Vector3.new(78,0,33),Strategic=true,Income=8,Country="Hungary"},
        {Name="Zagreb",City="Zagreb",Position=Vector3.new(48,0,48),Strategic=false,Income=7,Country="Croatia"},
        {Name="Ljubljana",City="Ljubljana",Position=Vector3.new(30,0,48),Strategic=false,Income=6,Country="Slovenia"},
        {Name="Bern",City="Bern",Position=Vector3.new(-34,0,38),Strategic=false,Income=6,Country="Switzerland"},
        {Name="Nicosia",City="Nicosia",Position=Vector3.new(145,0,118),Strategic=false,Income=6,Country="Cyprus"},
        {Name="Reykjavik",City="Reykjavik",Position=Vector3.new(-130,0,-105),Strategic=false,Income=6,Country="Iceland"},
    },
    {
        {"Lisbon","Madrid"},{"Madrid","Paris"},{"Paris","London"},{"Paris","Brussels"},{"Brussels","Amsterdam"},{"Amsterdam","Berlin"},{"London","Amsterdam"},{"Berlin","Copenhagen"},{"Copenhagen","Stockholm"},{"Oslo","Stockholm"},{"Stockholm","Helsinki"},{"Berlin","Warsaw"},{"Berlin","Prague"},{"Prague","Vienna"},{"Vienna","Budapest"},{"Budapest","Bucharest"},{"Vienna","Zagreb"},{"Zagreb","Ljubljana"},{"Ljubljana","Rome"},{"Bern","Paris"},{"Bern","Rome"},{"Rome","Athens"},{"Athens","Sofia"},{"Sofia","Bucharest"},{"Helsinki","Warsaw"},{"Warsaw","Bucharest"},{"Madrid","Bern"},{"Rome","Nicosia"},{"Reykjavik","London"}
    },
    {Center=Vector3.new(0,0,0),HalfX=0,HalfZ=0,Speed=1,Size=Vector3.new(1,0.1,1)},
    0.58
)

return WorldMaps
