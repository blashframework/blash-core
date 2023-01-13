Blash.Functions = {}
Blash.Player_Buckets = {}
Blash.Entity_Buckets = {}

function Blash.Functions.ConductVersionCheck(githubUsername, githubRepository)
    CreateThread(function()
        local updatePath = string.format('/%s/%s', githubUsername, githubRepository)

        local function checkVersion(_, responseText, _)
            local curVersion = LoadResourceFile(GetCurrentResourceName(), "version")
            local message = nil

            if curVersion ~= responseText and tonumber(curVersion) < tonumber(responseText) then
                message = string.format('Outdated; an update should be made.\nCurrent: %s | Github: %s', curVersion,
                    responseText)
            elseif tonumber(curVersion) > tonumber(responseText) then
                message = string.format('You either edited your local version or Github is offline.')
            end

            if message then
                exports['boppe-logging']:Info(githubRepository, 'NULL', message)
            else
                exports['boppe-logging']:Error(githubRepository, 'NULL',
                    'There was an error while the version check was being conducted.')
            end
        end

        PerformHttpRequest("https://raw.githubusercontent.com" .. updatePath .. "/master/version", checkVersion, "GET")
    end)
end

function Blash.Functions.DiscordLog(name, title, color, message)
    local webHook = Blash.Config.Webhooks[name] or Blash.Config.Webhooks['default']
    local embedData = {
        {
            ['title'] = title,
            ['color'] = Blash.Config.Colors[color] or Blash.Config.Colors['default'],
            ['footer'] = {
                ['text'] = os.date('%c'),
            },
            ['description'] = message,
            ['author'] = {
                ['name'] = 'Blash Logs',
            },
        }
    }
    PerformHttpRequest(webHook, function() end, 'POST', json.encode({ username = 'Blash Logs', embeds = embedData }),
        { ['Content-Type'] = 'application/json' })
end

function Blash.Functions.GetCoords(entity)
    local coords = GetEntityCoords(entity, false)
    local heading = GetEntityHeading(entity)
    return vector4(coords.x, coords.y, coords.z, heading)
end

function Blash.Functions.GetIdentifier(source, idtype)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in pairs(identifiers) do
        if string.find(identifier, idtype) then
            return identifier
        end
    end
    return nil
end

function Blash.Functions.GetSource(identifier)
    for src, _ in pairs(Blash.Players) do
        local idens = GetPlayerIdentifiers(src)
        for _, id in pairs(idens) do
            if identifier == id then
                return src
            end
        end
    end
    return 0
end

function Blash.Functions.GetPlayer(source)
    if type(source) == 'number' then
        return Blash.Players[source]
    else
        return Blash.Players[Blash.Functions.GetSource(source)]
    end
end

function Blash.Functions.GetPlayers()
    local sources = {}
    for k in pairs(Blash.Players) do
        sources[#sources + 1] = k
    end
    return sources
end

function Blash.Functions.GetQBPlayers()
    return Blash.Players
end

function Blash.Functions.GetBucketObjects()
    return Blash.Player_Buckets, Blash.Entity_Buckets
end

function Blash.Functions.SetPlayerBucket(source, bucket)
    if source and bucket then
        local plicense = Blash.Functions.GetIdentifier(source, 'license')
        SetPlayerRoutingBucket(source, bucket)
        Blash.Player_Buckets[plicense] = { id = source, bucket = bucket }
        return true
    else
        return false
    end
end

function Blash.Functions.SetEntityBucket(entity, bucket)
    if entity and bucket then
        SetEntityRoutingBucket(entity, bucket)
        Blash.Entity_Buckets[entity] = { id = entity, bucket = bucket }
        return true
    else
        return false
    end
end

function Blash.Functions.GetPlayersInBucket(bucket)
    local curr_bucket_pool = {}
    if Blash.Player_Buckets and next(Blash.Player_Buckets) then
        for _, v in pairs(Blash.Player_Buckets) do
            if v.bucket == bucket then
                curr_bucket_pool[#curr_bucket_pool + 1] = v.id
            end
        end
        return curr_bucket_pool
    else
        return false
    end
end

function Blash.Functions.GetEntitiesInBucket(bucket)
    local curr_bucket_pool = {}
    if Blash.Entity_Buckets and next(Blash.Entity_Buckets) then
        for _, v in pairs(Blash.Entity_Buckets) do
            if v.bucket == bucket then
                curr_bucket_pool[#curr_bucket_pool + 1] = v.id
            end
        end
        return curr_bucket_pool
    else
        return false
    end
end

function Blash.Functions.TriggerClientCallback(name, source, cb, ...)
    Blash.ClientCallbacks[name] = cb
    TriggerClientEvent('Blash:Client:TriggerClientCallback', source, name, ...)
end

function Blash.Functions.CreateCallback(name, cb)
    Blash.ServerCallbacks[name] = cb
end

function Blash.Functions.TriggerCallback(name, source, cb, ...)
    if not Blash.ServerCallbacks[name] then return end
    Blash.ServerCallbacks[name](source, cb, ...)
end

function Blash.Functions.Kick(source, reason, setKickReason, deferrals)
    reason = '\n' .. reason .. '\n🔸 Check our Discord for further information: ' .. Blash.Config.Server.Discord
    if setKickReason then
        setKickReason(reason)
    end
    CreateThread(function()
        if deferrals then
            deferrals.update(reason)
            Wait(2500)
        end
        if source then
            DropPlayer(source, reason)
        end
        for _ = 0, 4 do
            while true do
                if source then
                    if GetPlayerPing(source) >= 0 then
                        break
                    end
                    Wait(100)
                    CreateThread(function()
                        DropPlayer(source, reason)
                    end)
                end
            end
            Wait(5000)
        end
    end)
end

function Blash.Functions.HasPermission(source, permission)
    if type(permission) == "string" then
        if IsPlayerAceAllowed(source, permission) then return true end
    elseif type(permission) == "table" then
        for _, permLevel in pairs(permission) do
            if IsPlayerAceAllowed(source, permLevel) then return true end
        end
    end

    return false
end

function Blash.Functions.GetPermission(source)
    local src = source
    local perms = {}
    for _, v in pairs(Blash.Config.Server.Permissions) do
        if IsPlayerAceAllowed(src, v) then
            perms[v] = true
        end
    end
    return perms
end

function Blash.Functions.IsPlayerBanned(source)
    local plicense = Blash.Functions.GetIdentifier(source, 'license')
    local result = MySQL.single.await('SELECT * FROM bans WHERE license = ?', { plicense })
    if not result then return false end
    if os.time() < result.expire then
        local timeTable = os.date('*t', tonumber(result.expire))
        return true,
            'You have been banned from the server:\n' ..
            result.reason ..
            '\nYour ban expires ' ..
            timeTable.day ..
            '/' .. timeTable.month .. '/' .. timeTable.year .. ' ' .. timeTable.hour .. ':' .. timeTable.min .. '\n'
    else
        MySQL.query('DELETE FROM bans WHERE id = ?', { result.id })
    end
    return false
end

-- Check for duplicate license

function Blash.Functions.IsLicenseInUse(license)
    local players = GetPlayers()
    for _, player in pairs(players) do
        local identifiers = GetPlayerIdentifiers(player)
        for _, id in pairs(identifiers) do
            if string.find(id, 'license') then
                if id == license then
                    return true
                end
            end
        end
    end
    return false
end

function Blash.Functions.Notify(source, text, type)
    TriggerClientEvent('Blash:Notify', source, text, type)
end
