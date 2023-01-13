AddEventHandler('chatMessage', function(_, _, message)
    if string.sub(message, 1, 1) == '/' then
        CancelEvent()
        return
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if not Blash.Players[src] then return end
    local Player = Blash.Players[src]
    Blash.Functions.DiscordLog('joinleave', 'Left', 'red',
        '**' .. GetPlayerName(src) .. '** (' .. Player.PlayerData.license .. ') left..' .. '\n **Reason:** ' .. reason)
    Player.Functions.Save()
    Blash.Player_Buckets[Player.PlayerData.license] = nil
    Blash.Players[src] = nil
end)

local function onPlayerConnecting(name, _, deferrals)
    local src = source
    local license
    local identifiers = GetPlayerIdentifiers(src)
    deferrals.defer()

    Wait(0)

    if Blash.Config.Server.Closed then
        if not IsPlayerAceAllowed(src, 'blash.join') then
            deferrals.done(Blash.Config.Server.ClosedReason)
        end
    end

    for _, v in pairs(identifiers) do
        if string.find(v, 'license') then
            license = v
            break
        end
    end

    if GetConvarInt("sv_fxdkMode", false) then license = 'license:AAAAAAAAAAAAAAAA' end

    if not license then
        deferrals.done(Lang:t('error.no_valid_license'))
    elseif Blash.Config.Server.CheckDuplicateLicense and Blash.Functions.IsLicenseInUse(license) then
        deferrals.done(Lang:t('error.duplicate_license'))
    end

    local databaseTime = os.clock()
    local databasePromise = promise.new()

    CreateThread(function()
        deferrals.update(string.format(Lang:t('info.checking_ban'), name))
        local databaseSuccess, databaseError = pcall(function()
            local isBanned, Reason = Blash.Functions.IsPlayerBanned(src)
            if isBanned then
                deferrals.done(Reason)
            end
        end)

        if not databaseSuccess then
            databasePromise:reject(databaseError)
        end
        databasePromise:resolve()
    end)

    databasePromise:next(function()
        deferrals.update(string.format(Lang:t('info.join_server'), name))
        deferrals.done()
    end, function (databaseError)
        deferrals.done(Lang:t('error.connecting_database_error'))
        print('^1' .. databaseError)
    end)

    while databasePromise.state == 0 do
        if os.clock() - databaseTime > 30 then
            deferrals.done(Lang:t('error.connecting_database_timeout'))
            error(Lang:t('error.connecting_database_timeout'))
            break
        end
        Wait(1000)
    end
end
AddEventHandler('playerConnecting', onPlayerConnecting)

RegisterNetEvent('Blash:Server:TriggerClientCallback', function(name, ...)
    if Blash.ClientCallbacks[name] then
        Blash.ClientCallbacks[name](...)
        Blash.ClientCallbacks[name] = nil
    end
end)

RegisterNetEvent('Blash:Server:TriggerCallback', function(name, ...)
    local src = source
    Blash.Functions.TriggerCallback(name, src, function(...)
        TriggerClientEvent('Blash:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

RegisterNetEvent('Blash:UpdatePlayer', function()
    local src = source
    local Player = Blash.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.Save()
end)