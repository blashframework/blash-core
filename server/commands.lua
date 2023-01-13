Blash.Commands = {}
Blash.Commands.List = {}

CreateThread(function()
    local permissions = BlashConfig.Server.Permissions
    for i = 1, #permissions do
        local permission = permissions[i]
        ExecuteCommand(('add_ace blash.%s %s allow'):format(permission, permission))
    end
end)

function Blash.Commands.Register(name, help, arguments, argsrequired, callback, permission, ...)
    local restricted = true
    if not permission then permission = 'user' end
    if permission == 'user' then restricted = false end

    RegisterCommand(name, function(source, args, rawCommand)
        if argsrequired and #args < #arguments then
            return TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0 },
                multiline = true,
                args = { "System", Lang:t("error.missing_args") }
            })
        end
        callback(source, args, rawCommand)
    end, restricted)

    local extraPerms = ... and table.pack(...) or nil
    if extraPerms then
        extraPerms[extraPerms.n + 1] = permission
        extraPerms.n += 1
        permission = extraPerms
        for i = 1, permission.n do
            if not Blash.Commands.IgnoreList[permission[i]] then
                ExecuteCommand(('add_ace blash.%s command.%s allow'):format(permission[i], name))
            end
        end
        permission.n = nil
    else
        permission = tostring(permission:lower())
        if not Blash.Commands.IgnoreList[permission] then
            ExecuteCommand(('add_ace blash.%s command.%s allow'):format(permission, name))
        end
    end

    Blash.Commands.List[name:lower()] = {
        name = name:lower(),
        permission = permission,
        help = help,
        arguments = arguments,
        argsrequired = argsrequired,
        callback = callback
    }
end

Blash.Commands.Add('tp', Lang:t("command.tp.help"),
    { { name = Lang:t("command.tp.params.x.name"), help = Lang:t("command.tp.params.x.help") },
        { name = Lang:t("command.tp.params.y.name"), help = Lang:t("command.tp.params.y.help") },
        { name = Lang:t("command.tp.params.z.name"), help = Lang:t("command.tp.params.z.help") } }, false,
    function(source, args)
        if args[1] and not args[2] and not args[3] then
            if tonumber(args[1]) then
                local target = GetPlayerPed(tonumber(args[1]))
                if target ~= 0 then
                    local coords = GetEntityCoords(target)
                    TriggerClientEvent('Blash:Command:TeleportToPlayer', source, coords)
                else
                    TriggerClientEvent('Blash:Notify', source, Lang:t('error.not_online'), 'error')
                end
            end
        else
            if args[1] and args[2] and args[3] then
                local x = tonumber((args[1]:gsub(",", ""))) + .0
                local y = tonumber((args[2]:gsub(",", ""))) + .0
                local z = tonumber((args[3]:gsub(",", ""))) + .0
                if x ~= 0 and y ~= 0 and z ~= 0 then
                    TriggerClientEvent('Blash:Command:TeleportToCoords', source, x, y, z)
                else
                    TriggerClientEvent('Blash:Notify', source, Lang:t('error.wrong_format'), 'error')
                end
            else
                TriggerClientEvent('Blash:Notify', source, Lang:t('error.missing_args'), 'error')
            end
        end
    end, 'admin')

Blash.Commands.Add('tpm', Lang:t("command.tpm.help"), {}, false, function(source)
    TriggerClientEvent('Blash:Command:GoToMarker', source)
end, 'admin')
