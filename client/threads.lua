CreateThread(function()
    while true do
        local sleep = 0
        if LocalPlayer.state.isLoggedIn then
            sleep = (1000 * 60) * Blash.Config.General.UpdateInterval
            TriggerServerEvent('Blash:UpdatePlayer')
        end
        Wait(sleep)
    end
end)