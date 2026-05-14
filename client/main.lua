local isUIOpen = false
local currentPrayer = nil
local currentRakah = 0
local currentStep = 0
local totalRakah = 0
local currentType = "fard" -- fard, sunnah, vitr
local prayerSequence = {}
local isPraying = false
local autoProgress = false
local currentStepId = 0
local stopProgress = false
local currentEmoteName = nil

-- Debug
local function Debug(msg)
    if Config.Debug then
        print("[RoninNamaz] " .. msg)
    end
end

-- Oyun saatini al ve namaz vaktini tespit et
local function GetCurrentPrayerTime()
    local hour = GetClockHours()
    local minute = GetClockMinutes()
    local currentMinutes = hour * 60 + minute

    for _, prayer in ipairs(Config.PrayerTimes) do
        local startMinutes = prayer.startHour * 60 + prayer.startMinute
        local endMinutes = prayer.endHour * 60 + prayer.endMinute

        -- Gece yarısı geçişi kontrolü (örn: Yatsı 20:00 - 04:00)
        if endMinutes < startMinutes then
            if currentMinutes >= startMinutes or currentMinutes <= endMinutes then
                return prayer
            end
        else
            if currentMinutes >= startMinutes and currentMinutes <= endMinutes then
                return prayer
            end
        end
    end

    -- Varsayılan olarak en yakın vakti bul
    local closest = nil
    local closestDiff = 9999
    for _, prayer in ipairs(Config.PrayerTimes) do
        local startMinutes = prayer.startHour * 60 + prayer.startMinute
        local diff = math.abs(currentMinutes - startMinutes)
        if diff < closestDiff then
            closestDiff = diff
            closest = prayer
        end
    end
    return closest
end

-- Namaz sıralamasını oluştur
local function BuildPrayerSequence(prayer, type)
    local sequence = {}
    local rakahCount = 0

    if type == "sunnah" then
        rakahCount = prayer.sunnah or 0
    elseif type == "fard" then
        rakahCount = prayer.fard or 0
    elseif type == "extraSunnah" then
        rakahCount = prayer.extraSunnah or 0
    elseif type == "vitr" then
        rakahCount = prayer.vitr or 0
    end

    if rakahCount == 0 then return {} end

    -- Namazın başlangıcı: İftitah Tekbiri (elleri kaldırma)
    table.insert(sequence, {
        emote = Config.Emotes.takbir,
        stepName = "Takbir",
        rakah = 1,
        duration = Config.EmoteDurations.takbir,
        type = type
    })

    for i = 1, rakahCount do
        local isLastRakah = (i == rakahCount)

        -- Her rekâtın başlangıcı: Kıyam
        table.insert(sequence, {
            emote = Config.Emotes.qiyam,
            stepName = "Kıyam",
            rakah = i,
            duration = Config.EmoteDurations.qiyam,
            type = type
        })

        -- Rükû
        table.insert(sequence, {
            emote = Config.Emotes.ruku,
            stepName = "Rükû",
            rakah = i,
            duration = Config.EmoteDurations.ruku,
            type = type
        })

        -- Secde 1
        table.insert(sequence, {
            emote = Config.Emotes.sujud,
            stepName = "Secde",
            rakah = i,
            duration = Config.EmoteDurations.sujud,
            type = type
        })

        -- Cülûs (Oturma)
        table.insert(sequence, {
            emote = Config.Emotes.julus,
            stepName = "Cülûs",
            rakah = i,
            duration = Config.EmoteDurations.julus,
            type = type
        })

        -- Secde 2
        table.insert(sequence, {
            emote = Config.Emotes.sujudAlt,
            stepName = "Secde",
            rakah = i,
            duration = Config.EmoteDurations.sujud,
            type = type
        })

        -- Son rekât değilse tekrar kıyama geç
        if not isLastRakah then
            table.insert(sequence, {
                emote = Config.Emotes.qiyamAlt,
                stepName = "Kıyam",
                rakah = i,
                duration = Config.EmoteDurations.qiyam,
                type = type
            })
        else
            -- Son rekât: Teşehhüd
            table.insert(sequence, {
                emote = Config.Emotes.tashahhud,
                stepName = "Teşehhüd",
                rakah = i,
                duration = Config.EmoteDurations.tashahhud,
                type = type
            })

            -- Selam (Sağa)
            table.insert(sequence, {
                emote = Config.Emotes.tasleem,
                stepName = "Selam (Sağ)",
                rakah = i,
                duration = Config.EmoteDurations.tasleem,
                type = type
            })

            -- Selam (Sola)
            table.insert(sequence, {
                emote = Config.Emotes.tasleemAlt,
                stepName = "Selam (Sol)",
                rakah = i,
                duration = Config.EmoteDurations.tasleem,
                type = type,
                isLast = true
            })
        end
    end

    return sequence
end

-- Emote oynat (doğrudan TaskPlayAnim ile, animasyonlar arası kesintisiz geçiş)
local function PlayEmote(emoteData)
    if not emoteData or not emoteData.emote then return end
    
    currentEmoteName = emoteData.emote.emote
    Debug("Oynatılıyor: " .. currentEmoteName)

    local ped = PlayerPedId()
    local dict = emoteData.emote.dict
    
    -- Animasyon dictionary'sini yükle
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
    
    -- Doğrudan animasyon oynat, blend ile yumuşak geçiş (ClearPedTasks yok!)
    TaskPlayAnim(ped, dict, emoteData.emote.anim, 8.0, -8.0, -1, emoteData.emote.flag, 0, false, false, false)
end

-- Emote'u durdur (namaz bittiğinde / iptal edildiğinde)
local function StopEmote()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    currentEmoteName = nil
end

-- Namazı bitir
local function FinishPrayer()
    isPraying = false
    isUIOpen = false
    autoProgress = false
    StopEmote()

    SendNUIMessage({
        action = "finishPrayer",
        data = {
            prayerName = currentPrayer and currentPrayer.name or "",
            prayerType = currentType
        }
    })

    -- Bildirim
    TriggerEvent('QBCore:Notify', currentPrayer.name .. " namazı tamamlandı. Allah kabul etsin.", "success")
end

-- Namazı iptal et
local function CancelPrayer()
    isPraying = false
    isUIOpen = false
    autoProgress = false
    StopEmote()

    SendNUIMessage({
        action = "cancelPrayer"
    })
end

-- Sonraki adıma geç
local function NextStep()
    if not isPraying then return end
    if currentStep >= #prayerSequence then
        FinishPrayer()
        return
    end

    currentStep = currentStep + 1
    local step = prayerSequence[currentStep]
    currentRakah = step.rakah

    -- Emote'u oynat
    PlayEmote(step)

    -- NUI'yi güncelle
    SendNUIMessage({
        action = "updateStep",
        data = {
            currentStep = currentStep,
            totalSteps = #prayerSequence,
            currentRakah = currentRakah,
            totalRakah = totalRakah,
            stepName = step.stepName,
            stepIcon = step.emote.icon,
            isLast = step.isLast or false,
            duration = step.duration,
            prayerName = currentPrayer.name,
            prayerType = currentType,
            sequence = prayerSequence
        }
    })

    -- Otomatik ilerleme
    if autoProgress then
        stopProgress = false
        currentStepId = currentStepId + 1
        local myStepId = currentStepId
        
        CreateThread(function()
            local waited = 0
            while waited < (step.duration * 1000) do
                Wait(100)
                waited = waited + 100
                if stopProgress or not isPraying or currentStepId ~= myStepId then
                    return
                end
            end
            if isPraying and not stopProgress and currentStepId == myStepId then
                NextStep()
            end
        end)
    end
end

-- Önceki adıma dön
local function PrevStep()
    if not isPraying then return end
    if currentStep <= 1 then return end

    stopProgress = true
    currentStep = currentStep - 1
    local step = prayerSequence[currentStep]
    currentRakah = step.rakah

    PlayEmote(step)

    SendNUIMessage({
        action = "updateStep",
        data = {
            currentStep = currentStep,
            totalSteps = #prayerSequence,
            currentRakah = currentRakah,
            totalRakah = totalRakah,
            stepName = step.stepName,
            stepIcon = step.emote.icon,
            isLast = step.isLast or false,
            duration = step.duration,
            prayerName = currentPrayer.name,
            prayerType = currentType,
            sequence = prayerSequence
        }
    })
end

-- Belirli bir adıma git (manuel seçim)
local function GoToStep(index)
    if not isPraying then return end
    if index < 1 or index > #prayerSequence then return end

    stopProgress = true
    currentStep = index
    local step = prayerSequence[currentStep]
    currentRakah = step.rakah

    PlayEmote(step)

    SendNUIMessage({
        action = "updateStep",
        data = {
            currentStep = currentStep,
            totalSteps = #prayerSequence,
            currentRakah = currentRakah,
            totalRakah = totalRakah,
            stepName = step.stepName,
            stepIcon = step.emote.icon,
            isLast = step.isLast or false,
            duration = step.duration,
            prayerName = currentPrayer.name,
            prayerType = currentType,
            sequence = prayerSequence
        }
    })
end

-- Namazı başlat
local function StartPrayer(prayer, type)
    currentPrayer = prayer
    currentType = type
    currentStep = 0
    currentRakah = 0
    isPraying = true
    autoProgress = true

    if type == "sunnah" then
        totalRakah = prayer.sunnah or 0
    elseif type == "fard" then
        totalRakah = prayer.fard or 0
    elseif type == "extraSunnah" then
        totalRakah = prayer.extraSunnah or 0
    elseif type == "vitr" then
        totalRakah = prayer.vitr or 0
    end

    prayerSequence = BuildPrayerSequence(prayer, type)

    Debug("Namaz başlatıldı: " .. prayer.name .. " " .. type .. " - " .. totalRakah .. " rekât")

    SendNUIMessage({
        action = "startPrayer",
        data = {
            prayerName = prayer.name,
            prayerType = type,
            totalRakah = totalRakah,
            totalSteps = #prayerSequence,
            sequence = prayerSequence
        }
    })

    -- NUI'yi gizle, namaz devam etsin
    SetNuiFocus(false, false)
    isUIOpen = false
    SendNUIMessage({ action = "hideApp" })

    NextStep()
end

-- NUI'yi aç
local function OpenUI()
    if isUIOpen then return end
    isUIOpen = true

    -- Namaz devam ediyorsa direkt akış ekranını göster, focus verme
    if isPraying and currentPrayer then
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = "showFlow",
            data = {
                currentStep = currentStep,
                totalSteps = #prayerSequence,
                currentRakah = currentRakah,
                totalRakah = totalRakah,
                stepName = prayerSequence[currentStep] and prayerSequence[currentStep].stepName or "",
                stepIcon = prayerSequence[currentStep] and prayerSequence[currentStep].emote.icon or "🤲",
                isLast = prayerSequence[currentStep] and (prayerSequence[currentStep].isLast or false) or false,
                duration = prayerSequence[currentStep] and prayerSequence[currentStep].duration or 0,
                prayerName = currentPrayer.name,
                prayerType = currentType,
                sequence = prayerSequence,
                autoEnabled = autoProgress
            }
        })
        return
    end

    local currentPrayerTime = GetCurrentPrayerTime()

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        data = {
            prayerTimes = Config.PrayerTimes,
            currentPrayer = currentPrayerTime,
            currentHour = GetClockHours(),
            currentMinute = GetClockMinutes()
        }
    })
end

-- NUI'yi kapat
local function CloseUI()
    if not isUIOpen then return end
    isUIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

-- NUI Callbackleri
RegisterNUICallback('close', function(data, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('startPrayer', function(data, cb)
    local prayerId = data.prayerId
    local prayerType = data.type or "fard"

    local selectedPrayer = nil
    for _, p in ipairs(Config.PrayerTimes) do
        if p.id == prayerId then
            selectedPrayer = p
            break
        end
    end

    if selectedPrayer then
        StartPrayer(selectedPrayer, prayerType)
    end

    cb('ok')
end)

RegisterNUICallback('nextStep', function(data, cb)
    NextStep()
    cb('ok')
end)

RegisterNUICallback('prevStep', function(data, cb)
    PrevStep()
    cb('ok')
end)

RegisterNUICallback('goToStep', function(data, cb)
    local index = tonumber(data.index)
    if index then
        GoToStep(index)
    end
    cb('ok')
end)

RegisterNUICallback('toggleAuto', function(data, cb)
    autoProgress = data.enabled or false
    if autoProgress and isPraying and currentStep > 0 then
        -- Mevcut adımın süresi kadar bekle ve sonraki adıma geç
        local step = prayerSequence[currentStep]
        if step then
            stopProgress = false
            currentStepId = currentStepId + 1
            local myStepId = currentStepId
            
            CreateThread(function()
                local waited = 0
                while waited < (step.duration * 1000) do
                    Wait(100)
                    waited = waited + 100
                    if stopProgress or not isPraying or currentStepId ~= myStepId then
                        return
                    end
                end
                if isPraying and not stopProgress and currentStepId == myStepId then
                    NextStep()
                end
            end)
        end
    elseif not autoProgress then
        -- Otomatik ilerlemeyi durdur
        stopProgress = true
        currentStepId = currentStepId + 1
    end
    cb('ok')
end)

RegisterNUICallback('cancelPrayer', function(data, cb)
    CancelPrayer()
    cb('ok')
end)

RegisterNUICallback('finishPrayer', function(data, cb)
    FinishPrayer()
    cb('ok')
end)

-- ========== HATIRLATICI SİSTEMİ ==========
local lastReminders = {}

local function CheckPrayerReminders()
    if not Config.Reminders.enabled then return end

    local hour = GetClockHours()
    local minute = GetClockMinutes()
    local currentMinutes = hour * 60 + minute

    for _, prayer in ipairs(Config.PrayerTimes) do
        local startMinutes = prayer.startHour * 60 + prayer.startMinute
        local endMinutes = prayer.endHour * 60 + prayer.endMinute

        -- Gece yarısı geçiş kontrolü
        if endMinutes < startMinutes then
            endMinutes = endMinutes + 1440
            if currentMinutes < startMinutes then
                currentMinutes = currentMinutes + 1440
            end
        end

        local diffToStart = startMinutes - currentMinutes
        local diffToEnd = endMinutes - currentMinutes

        -- Vakit başlamasına yaklaşıyor
        if Config.Reminders.beforeStart > 0 and diffToStart > 0 and diffToStart <= Config.Reminders.beforeStart then
            local key = prayer.id .. "_start"
            if not lastReminders[key] then
                lastReminders[key] = true
                SendNUIMessage({
                    action = "reminder",
                    data = {
                        prayerId = prayer.id,
                        prayerName = prayer.name,
                        prayerIcon = prayer.icon,
                        type = "before",
                        minutesLeft = diffToStart,
                        currentHour = hour,
                        currentMinute = minute
                    }
                })
            end
        else
            lastReminders[prayer.id .. "_start"] = false
        end

        -- Vakit bitimine yaklaşıyor
        if Config.Reminders.beforeEnd > 0 and diffToEnd > 0 and diffToEnd <= Config.Reminders.beforeEnd then
            local key = prayer.id .. "_end"
            if not lastReminders[key] then
                lastReminders[key] = true
                SendNUIMessage({
                    action = "reminder",
                    data = {
                        prayerId = prayer.id,
                        prayerName = prayer.name,
                        prayerIcon = prayer.icon,
                        type = "ending",
                        minutesLeft = diffToEnd,
                        currentHour = hour,
                        currentMinute = minute
                    }
                })
            end
        else
            lastReminders[prayer.id .. "_end"] = false
        end
    end
end

-- Hatırlatma kontrol thread'i
CreateThread(function()
    while true do
        Wait(Config.Reminders.checkInterval * 1000)
        CheckPrayerReminders()
    end
end)

-- Komut
RegisterCommand(Config.Command, function(source, args, rawCommand)
    if isUIOpen then
        CloseUI()
    else
        OpenUI()
    end
end, false)

-- Klavye kontrolü (ESC ile kapatma, X ile namaz iptali)
CreateThread(function()
    while true do
        Wait(0)
        -- ESC ile NUI'yi kapat
        if isUIOpen and IsControlJustPressed(0, 177) then -- ESC/Backspace
            CloseUI()
        end
        
        -- X ile namazı iptal et (sadece namazdayken)
        if isPraying and IsControlJustPressed(0, 73) then -- INPUT_VEH_DUCK (X tuşu)
            CancelPrayer()
            TriggerEvent('QBCore:Notify', "Namaz iptal edildi.", "error")
        end
    end
end)

-- Oyuncu hareket ederse veya araç binerse namazı iptal et
CreateThread(function()
    while true do
        Wait(500)
        if isPraying then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, true) then
                CancelPrayer()
                TriggerEvent('QBCore:Notify', "Araçta namaz kılınamaz!", "error")
            elseif IsPedRunning(ped) or IsPedSprinting(ped) or IsPedJumping(ped) then
                CancelPrayer()
                TriggerEvent('QBCore:Notify', "Koşarken namaz kılınamaz!", "error")
            end
        end
    end
end)

-- Resource durdurulursa temizlik
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if isPraying then
        CancelPrayer()
    end
    if isUIOpen then
        CloseUI()
    end
end)
