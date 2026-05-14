local QBCore = exports['qb-core']:GetCoreObject()

-- Namaz loglama
RegisterNetEvent('ronin-namaz:server:logPrayer', function(prayerName, prayerType, rakahCount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        print(string.format("[RoninNamaz] %s (%s) %s namazını %s olarak %d rekât kıldı.",
            Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
            Player.PlayerData.citizenid,
            prayerName,
            prayerType,
            rakahCount
        ))
    end
end)

-- Version check (opsiyonel)
print("[^2Ronin-Namaz^7] Gelişmiş Namaz Sistemi başlatıldı.")
