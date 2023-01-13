RegisterNetEvent('Blash:Client:OnPlayerLoaded', function()
    ShutdownLoadingScreenNui()
    LocalPlayer.state:set('isLoggedIn', true, false)
    SetCanAttackFriendly(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(true)
end)

RegisterNetEvent('Blash:Command:TeleportToPlayer', function(coords)
    local ped = PlayerPedId()
    SetPedCoordsKeepVehicle(ped, coords.x, coords.y, coords.z)
end)

RegisterNetEvent('Blash:Command:TeleportToCoords', function(x, y, z, h)
    local ped = PlayerPedId()
    SetPedCoordsKeepVehicle(ped, x, y, z)
    SetEntityHeading(ped, h or GetEntityHeading(ped))
end)

RegisterNetEvent('Blash:Command:GoToMarker', function()
    local PlayerPedId = PlayerPedId
    local GetEntityCoords = GetEntityCoords
    local GetGroundZFor_3dCoord = GetGroundZFor_3dCoord

    local blipMarker <const> = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blipMarker) then
        Blash.Functions.Notify(Lang:t("error.no_waypoint"), "error")
        return 'marker'
    end

    -- Fade screen to hide how clients get teleported.
    DoScreenFadeOut(650)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    local ped, coords <const> = PlayerPedId(), GetBlipInfoIdCoord(blipMarker)
    local vehicle = GetVehiclePedIsIn(ped, false)
    local oldCoords <const> = GetEntityCoords(ped)

    -- Unpack coords instead of having to unpack them while iterating.
    -- 825.0 seems to be the max a player can reach while 0.0 being the lowest.
    local x, y, groundZ, Z_START = coords['x'], coords['y'], 850.0, 950.0
    local found = false
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, true)
    else
        FreezeEntityPosition(ped, true)
    end

    for i = Z_START, 0, -25.0 do
        local z = i
        if (i % 2) ~= 0 then
            z = Z_START - i
        end

        NewLoadSceneStart(x, y, z, x, y, z, 50.0, 0)
        local curTime = GetGameTimer()
        while IsNetworkLoadingScene() do
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end
        NewLoadSceneStop()
        SetPedCoordsKeepVehicle(ped, x, y, z)

        while not HasCollisionLoadedAroundEntity(ped) do
            RequestCollisionAtCoord(x, y, z)
            if GetGameTimer() - curTime > 1000 then
                break
            end
            Wait(0)
        end

        -- Get ground coord. As mentioned in the natives, this only works if the client is in render distance.
        found, groundZ = GetGroundZFor_3dCoord(x, y, z, false);
        if found then
            Wait(0)
            SetPedCoordsKeepVehicle(ped, x, y, groundZ)
            break
        end
        Wait(0)
    end

    -- Remove black screen once the loop has ended.
    DoScreenFadeIn(650)
    if vehicle > 0 then
        FreezeEntityPosition(vehicle, false)
    else
        FreezeEntityPosition(ped, false)
    end

    if not found then
        -- If we can't find the coords, set the coords to the old ones.
        -- We don't unpack them before since they aren't in a loop and only called once.
        SetPedCoordsKeepVehicle(ped, oldCoords['x'], oldCoords['y'], oldCoords['z'] - 1.0)
        Blash.Functions.Notify(Lang:t("error.tp_error"), "error")
    end

    -- If Z coord was found, set coords in found coords.
    SetPedCoordsKeepVehicle(ped, x, y, groundZ)
    Blash.Functions.Notify(Lang:t("success.teleported_waypoint"), "success")
end)

RegisterNetEvent('Blash:Player:SetPlayerData', function(val)
    Blash.PlayerData = val
end)

RegisterNetEvent('Blash:Player:UpdatePlayerData', function()
    TriggerServerEvent('Blash:UpdatePlayer')
end)

RegisterNetEvent('Blash:Notify', function(text, type)
    Blash.Functions.Notify(text, type)
end)

RegisterNetEvent('Blash:Client:TriggerClientCallback', function(name, ...)
    Blash.Functions.TriggerClientCallback(name, function(...)
        TriggerServerEvent('Blash:Server:TriggerClientCallback', name, ...)
    end, ...)
end)

RegisterNetEvent('Blash:Client:TriggerCallback', function(name, ...)
    if Blash.ServerCallbacks[name] then
        Blash.ServerCallbacks[name](...)
        Blash.ServerCallbacks[name] = nil
    end
end)
