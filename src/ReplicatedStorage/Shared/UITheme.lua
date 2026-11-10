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
        move="MOVE", attack="ATTACK", hold="HOLD", follow="FOLLOW", retreat="RETREAT",
        line="LINE", wedge="WEDGE", spread="SPREAD", column="COLUMN",
        army="ARMY", map="MAP", profile="PROFILE", season="SEASON", settings="SETTINGS",
        supplies="SUPPLIES", gold="GOLD", territory="TERRITORY", objective="OBJECTIVE", neutral="NEUTRAL",
        contested="CONTESTED", capture="CAPTURE", defend="DEFEND", selectArmy="Select an army",
        selectCastle="Select a castle", moveHint="Choose a destination", attackHint="Select an enemy army",
        holdHint="Hold position", followHint="Follow a friendly army", retreatHint="Fall back to your rally point",
        invalid="That action is not available.", castle="CASTLE", capital="CAPITAL", major="MAJOR CITY",
        regional="CASTLE", victory="VICTORY", defeat="DEFEAT", draw="DRAW", rematch="REMATCH",
        returnLobby="RETURN TO LOBBY", language="LANGUAGE", reducedMotion="REDUCED MOTION", on="ON", off="OFF",
        command="COMMAND", formation="FORMATION", recruit="RECRUIT", reinforce="REINFORCE",
        income="INCOME", upkeep="UPKEEP", net="NET", stable="STABLE", strain="UPKEEP STRAIN",
        comeback="COMEBACK BONUS", destination="DESTINATION", health="HEALTH", morale="MORALE",
        fatigue="FATIGUE", power="POWER", order="ORDER", state="STATE", garrison="GARRISON",
        focus="FOCUS", route="ROUTE", inspect="INSPECT", objectiveAction="SET OBJECTIVE",
        briefing="COMMAND BRIEF", step1="Select your army", step2="Send it to a castle",
        step3="Hold the gate to capture", step4="Watch your income", step5="Choose a formation",
        ready="READY", selected="SELECTED", noArmy="NO ARMY SELECTED", touchHint="Tap an army, then choose a command",
        world="WORLD", timer="TIME", owned="OWNED", armies="ARMIES", castleAction="CASTLE ACTIONS",
        economy="ECONOMY", recruitHint="Create a new army or reinforce the selected one",
        languageShort="EN", languageAlt="AR",
    },
    ar = {
        move="تحريك", attack="هجوم", hold="ثبات", follow="تَـبِـع", retreat="انسحاب",
        line="خط", wedge="وتد", spread="انتشار", column="عمود",
        army="الجيش", map="الخريطة", profile="الملف", season="الموسم", settings="الإعدادات",
        supplies="المؤن", gold="الذهب", territory="الأراضي", objective="الهدف", neutral="محايد",
        contested="متنازع عليه", capture="احتلال", defend="دفاع", selectArmy="اختر جيشاً",
        selectCastle="اختر قلعة", moveHint="اختر نقطة التحرك", attackHint="اختر جيشاً عدواً",
        holdHint="تثبيت الموقع", followHint="اتبع جيشاً حليفاً", retreatHint="ارجع إلى نقطة التجمع",
        invalid="هذا الإجراء غير متاح.", castle="القلعة", capital="العاصمة", major="مدينة رئيسية",
        regional="قلعة", victory="انتصار", defeat="هزيمة", draw="تعادل", rematch="إعادة المباراة",
        returnLobby="العودة للّوبي", language="اللغة", reducedMotion="تقليل الحركة", on="تشغيل", off="إيقاف",
        command="الأوامر", formation="التشكيل", recruit="تجنيد", reinforce="تعزيز",
        income="الدخل", upkeep="الإعالة", net="الصافي", stable="مستقر", strain="ضغط الإعالة",
        comeback="مكافأة العودة", destination="الوجهة", health="الصحة", morale="المعنويات",
        fatigue="الإرهاق", power="القوة", order="الأمر", state="الحالة", garrison="الحامية",
        focus="تركيز", route="مسار", inspect="تفقد", objectiveAction="تحديد هدف",
        briefing="موجز القيادة", step1="اختر جيشك", step2="أرسله إلى قلعة",
        step3="ثبت عند البوابة لاحتلالها", step4="راقب دخلك", step5="اختر تشكيلاً",
        ready="جاهز", selected="محدد", noArmy="لم يتم اختيار جيش", touchHint="اضغط على جيش ثم اختر أمراً",
        world="العالم", timer="الوقت", owned="مملوك", armies="الجيوش", castleAction="أوامر القلعة",
        economy="الاقتصاد", recruitHint="أنشئ جيشاً جديداً أو عزّز الجيش المحدد",
        languageShort="AR", languageAlt="EN",
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
