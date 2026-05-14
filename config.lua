Config = Config or {}

-- Namaz vakitleri (oyun saatine göre)
Config.PrayerTimes = {
    {
        id = "fajr",
        name = "Sabah",
        startHour = 4,
        startMinute = 0,
        endHour = 7,
        endMinute = 0,
        icon = "🌅",
        sunnah = 2,
        fard = 2,
        description = "2 Sünnet + 2 Farz"
    },
    {
        id = "dhuhr",
        name = "Öğle",
        startHour = 12,
        startMinute = 0,
        endHour = 15,
        endMinute = 0,
        icon = "☀️",
        sunnah = 4,
        fard = 4,
        extraSunnah = 2,
        description = "4 Sünnet + 4 Farz + 2 Sünnet"
    },
    {
        id = "asr",
        name = "İkindi",
        startHour = 15,
        startMinute = 0,
        endHour = 18,
        endMinute = 0,
        icon = "🌤️",
        sunnah = 4,
        fard = 4,
        description = "4 Sünnet + 4 Farz"
    },
    {
        id = "maghrib",
        name = "Akşam",
        startHour = 18,
        startMinute = 0,
        endHour = 20,
        endMinute = 0,
        icon = "🌇",
        fard = 3,
        sunnah = 2,
        description = "3 Farz + 2 Sünnet"
    },
    {
        id = "isha",
        name = "Yatsı",
        startHour = 20,
        startMinute = 0,
        endHour = 4,
        endMinute = 0,
        icon = "🌙",
        sunnah = 4,
        fard = 4,
        extraSunnah = 2,
        vitr = 3,
        description = "4 Sünnet + 4 Farz + 2 Sünnet + 3 Vitir"
    }
}

-- Özel Namazlar (vakit bağımsız)
Config.SpecialPrayers = {
    {
        id = "cuma",
        name = "Cuma",
        icon = "🕌",
        fard = 4,
        description = "4 Farz (Hutbe sonrası)"
    },
    {
        id = "teravih",
        name = "Teravih",
        icon = "🌙",
        sunnah = 20,
        description = "20 Rekât Sünnet"
    },
    {
        id = "cenaze",
        name = "Cenaze",
        icon = "⚰️",
        type = "cenaze",
        tekbirCount = 4,
        description = "4 Tekbir + Dua + Selam"
    }
}

-- Emote süreleri (saniye)
Config.EmoteDurations = {
    qiyam = 6,
    takbir = 3,
    ruku = 4,
    sujud = 4,
    julus = 3,
    tashahhud = 5,
    tasleem = 4,
}

-- Emote haritalaması (dict & anim rpemotes AnimationList.lua'ndan alınmıştır)
Config.Emotes = {
    qiyam = { emote = "islampray1", label = "Kıyam", icon = "🧍", dict = "smo@prayer_posepack_01", anim = "prayer_posepack_01_clip", flag = 1 },
    qiyamAlt = { emote = "islampray3", label = "Kıyam Kabd", icon = "🧍", dict = "smo@prayer_posepack_03", anim = "prayer_posepack_03_clip", flag = 1 },
    takbir = { emote = "islampray2", label = "Takbir", icon = "🤲", dict = "smo@prayer_posepack_02", anim = "prayer_posepack_02_clip", flag = 1 },
    ruku = { emote = "islampray4", label = "Rükû", icon = "🙇", dict = "smo@prayer_posepack_04", anim = "prayer_posepack_04_clip", flag = 1 },
    sujud = { emote = "islampray5", label = "Secde", icon = "🙏", dict = "smo@prayer_posepack_05", anim = "prayer_posepack_05_clip", flag = 1 },
    sujudAlt = { emote = "islampray13", label = "Secde 2", icon = "🙏", dict = "smo@prayer_posepack_13", anim = "prayer_posepack_13_clip", flag = 1 },
    julus = { emote = "islampray6", label = "Cülûs", icon = "🧎", dict = "smo@prayer_posepack_06", anim = "prayer_posepack_06_clip", flag = 1 },
    julusAlt = { emote = "islampray11", label = "Cülûs 2", icon = "🧎", dict = "smo@prayer_posepack_11", anim = "prayer_posepack_11_clip", flag = 1 },
    tashahhud = { emote = "islampray9", label = "Teşehhüd", icon = "🤲", dict = "smo@prayer_posepack_09", anim = "prayer_posepack_09_clip", flag = 1 },
    tasleem = { emote = "islampray7", label = "Selam", icon = "👋", dict = "smo@prayer_posepack_07", anim = "prayer_posepack_07_clip", flag = 1 },
    tasleemAlt = { emote = "islampray8", label = "Selam 2", icon = "👋", dict = "smo@prayer_posepack_08", anim = "prayer_posepack_08_clip", flag = 1 },
}

-- Komut ayarları
Config.Command = "namaz"
Config.KeyCancel = "BACK" -- Kapatmak için tuş (ESC zaten NUI kapatır)

-- Hatırlatıcı ayarları
Config.Reminders = {
    enabled = true,
    beforeStart = 15,  -- Vakit başlamasına kaç dakika kala hatırlat (0 = kapalı)
    beforeEnd = 10,    -- Vakit bitimine kaç dakika kala hatırlat (0 = kapalı)
    checkInterval = 30 -- Kontrol aralığı (saniye)
}

-- Debug
Config.Debug = false
