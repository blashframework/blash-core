BlashConfig = {}

BlashConfig.General = {}
BlashConfig.General.MaxPlayers = GetConvarInt('sv_maxclients', 48)
BlashConfig.General.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)
BlashConfig.General.UpdateInterval = 5 -- in minutes

BlashConfig.Server = {}
BlashConfig.Server.Name = 'Server Name'
BlashConfig.Server.Closed = false
BlashConfig.Server.ClosedReason = 'Server is currently closed.'
BlashConfig.Server.Discord = ''
BlashConfig.Server.CheckDuplicateLicense = true
BlashConfig.Server.Permissions = { 'admin', 'moderator', 'trialmod' }

BlashConfig.Announcements = {}
BlashConfig.Announcements.List = {

}
BlashConfig.Announcements.Interval = 5 -- in minutes
BlashConfig.Announcements.Random = false

BlashConfig.Webhooks = {
    ['default'] = '',
    ['joinleave'] = '',
}

BlashConfig.DiscordColors = {
    ['default'] = 14423100,
    ['blue'] = 255,
    ['red'] = 16711680,
    ['green'] = 65280,
    ['white'] = 16777215,
    ['black'] = 0,
    ['orange'] = 16744192,
    ['yellow'] = 16776960,
    ['pink'] = 16761035,
    ["lightgreen"] = 65309,
}
