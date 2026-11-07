local Config = {}

Config.Game = {
	Name = "Kingdoms Conquest",
	Version = "MVP-1.0.0",
	TeamCount = 2,
	MatchLengthSeconds = 20 * 60,
	VictoryTerritories = 4,
	StateBroadcastSeconds = 0.25,
	EconomyTickSeconds = 10,
	CaptureSeconds = 10,
	CaptureDecayPerSecond = 1.25,
	CastleIncomePerMinute = 5,
	HomeIncomePerMinute = 8,
	StrategicIncomePerMinute = 8,
	CapitalIncomePerMinute = 12,
}

Config.ArmyTypes = {
	Spearmen = {
	Cost = 20,
	Health = 120,
	Damage = 14,
	MoveSpeed = 18,
	AttackRange = 16,
	AttackCooldown = 0.75,
	Color = Color3.fromRGB(196, 204, 214),
	Accent = Color3.fromRGB(125, 139, 153),
	Label = "SPEARMEN",
	Short = "S",
	},
	Archers = {
	Cost = 24,
	Health = 90,
	Damage = 19,
	MoveSpeed = 15,
	AttackRange = 34,
	AttackCooldown = 1.15,
	Color = Color3.fromRGB(204, 170, 100),
	Accent = Color3.fromRGB(119, 77, 34),
	Label = "ARCHERS",
	Short = "A",
	},
	Cavalry = {
	Cost = 30,
	Health = 150,
	Damage = 12,
	MoveSpeed = 26,
	AttackRange = 14,
	AttackCooldown = 0.65,
	Color = Color3.fromRGB(118, 118, 128),
	Accent = Color3.fromRGB(73, 84, 105),
	Label = "CAVALRY",
	Short = "C",
	},
}

Config.Formations = {
	Line = {Label = "LINE"},
	Wedge = {Label = "WEDGE"},
	Column = {Label = "COLUMN"},
	Spread = {Label = "SPREAD"},
}

Config.Team = {
	Red = {
	Name = "Crimson",
	Color = Color3.fromRGB(178, 61, 64),
	BrickColor = BrickColor.new("Bright red"),
	},
	Blue = {
	Name = "Azure",
	Color = Color3.fromRGB(70, 117, 193),
	BrickColor = BrickColor.new("Bright blue"),
	},
}

Config.ProvinceOrder = {
	"Northwatch",
	"Riverside",
	"Central Keep",
	"Highlands",
	"West March",
	"Southgate",
}

Config.Provinces = {
	["Northwatch"] = {Index = 1, Position = Vector3.new(0, 0, -95), Size = Vector3.new(72, 2, 56), Home = 1, Strategic = false, Income = 8},
	["Riverside"] = {Index = 2, Position = Vector3.new(-82, 0, -20), Size = Vector3.new(70, 2, 58), Home = 1, Strategic = true, Income = 8},
	["Central Keep"] = {Index = 3, Position = Vector3.new(0, 0, 0), Size = Vector3.new(74, 2, 64), Home = 0, Strategic = true, Income = 8},
	["Highlands"] = {Index = 4, Position = Vector3.new(82, 0, -20), Size = Vector3.new(70, 2, 58), Home = 2, Strategic = true, Income = 8},
	["West March"] = {Index = 5, Position = Vector3.new(-72, 0, 68), Size = Vector3.new(78, 2, 58), Home = 0, Strategic = false, Income = 5},
	["Southgate"] = {Index = 6, Position = Vector3.new(0, 0, 104), Size = Vector3.new(74, 2, 54), Home = 2, Strategic = false, Income = 8},
}

return Config