-- Kingdoms Conquest — Stage 10 UI Theme
local UITheme = {}

UITheme.Colors = {
    Ink = Color3.fromRGB(18,22,23),
    Surface = Color3.fromRGB(27,32,33),
    Surface2 = Color3.fromRGB(36,42,42),
    Surface3 = Color3.fromRGB(47,54,54),
    Parchment = Color3.fromRGB(235,226,204),
    Muted = Color3.fromRGB(174,171,162),
    Brass = Color3.fromRGB(222,191,117),
    White = Color3.fromRGB(245,242,233),
    Danger = Color3.fromRGB(202,76,79),
    Success = Color3.fromRGB(83,159,112),
    Neutral = Color3.fromRGB(121,119,109),
    Crimson = Color3.fromRGB(178,61,64),
    Azure = Color3.fromRGB(70,117,193),
    Emerald = Color3.fromRGB(65,142,99),
    Amber = Color3.fromRGB(204,151,58),
}

UITheme.TeamColors = {
    [0]=UITheme.Colors.Neutral,
    [1]=UITheme.Colors.Crimson,
    [2]=UITheme.Colors.Azure,
    [3]=UITheme.Colors.Emerald,
    [4]=UITheme.Colors.Amber,
}

UITheme.Text = {
    en = {
        move="MOVE", attack="ATTACK", hold="HOLD", line="LINE", wedge="WEDGE", spread="SPREAD",
        army="ARMY", map="MAP", profile="PROFILE", season="SEASON", settings="SETTINGS",
        supplies="SUPPLIES", territory="TERRITORY", objective="OBJECTIVE", neutral="NEUTRAL",
        contested="CONTESTED", capture="CAPTURE", defend="DEFEND", selectArmy="Select an army",
        moveHint="Choose a destination", attackHint="Select an enemy army", holdHint="Hold position",
        invalid="That action is not available.", castle="CASTLE", capital="CAPITAL", major="MAJOR CITY",
        victory="VICTORY", defeat="DEFEAT", draw="DRAW", rematch="REMATCH", returnLobby="RETURN TO LOBBY",
        language="LANGUAGE", reducedMotion="REDUCED MOTION", on="ON", off="OFF",
    },
    ar = {
        move="تحريك", attack="هجوم", hold="ثبات", line="خط", wedge="وتد", spread="انتشار",
        army="الجيش", map="الخريطة", profile="الملف", season="الموسم", settings="الإعدادات",
        supplies="المؤن", territory="الأراضي", objective="الهدف", neutral="محايد",
        contested="متنازع عليه", capture="احتلال", defend="دفاع", selectArmy="اختر جيشاً",
        moveHint="اختر نقطة التحرك", attackHint="اختر جيشاً عدواً", holdHint="تثبيت الموقع",
        invalid="هذا الإجراء غير متاح.", castle="قلعة", capital="عاصمة", major="مدينة رئيسية",
        victory="انتصار", defeat="هزيمة", draw="تعادل", rematch="إعادة المباراة", returnLobby="العودة للّوبي",
        language="اللغة", reducedMotion="تقليل الحركة", on="تشغيل", off="إيقاف",
    }
}

function UITheme.TeamName(id, lang)
    local names = {
        [1]={en="CRIMSON",ar="قرمزي"}, [2]={en="AZURE",ar="أزرق"},
        [3]={en="EMERALD",ar="زمردي"}, [4]={en="AMBER",ar="كهرماني"},
    }
    local data = names[id]
    if not data then return tostring(id or 0) end
    return data[lang or "en"] or data.en
end

function UITheme.T(lang, key)
    local pack = UITheme.Text[lang or "en"] or UITheme.Text.en
    return pack[key] or key
end

return UITheme
