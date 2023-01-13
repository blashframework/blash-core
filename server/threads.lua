local currentAnnouncement = 0
local announcementList = Blash.Config.Announcements.List

CreateThread(function()
    while true do
        local sleep = (1000 * 60) * Blash.Config.Announcements.Interval
        
        if announcementList >= 1 then
            local announcementMessage = nil

            if Blash.Config.Announcements.Random then
                announcementMessage = announcementList[math.random(1, #announcementList)]
            else
                if currentAnnouncement > #announcementList then currentAnnouncement = 1 end
                currentAnnouncement = currentAnnouncement + 1
                announcementMessage = announcementList[currentAnnouncement]
            end

            TriggerClientEvent('chat:addMessage', -1, {
                color = { 0, 255, 0 },
                multiline = false,
                args = { announcementMessage }
            })
        end

        Wait(sleep)
    end
end)