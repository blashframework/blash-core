local Translations = {
    error = {
        missing_args = 'All arguments must be filled out.',
        no_valid_license = 'No Valid Rockstar License Found.',
        duplicate_license = 'Duplicate Rockstar License Found.',
        connecting_database_error = 'A database error occurred while connecting to the server. (Is the SQL server on?)',
        connecting_database_timeout = 'Connection to database timed out. (Is the SQL server on?)',
        no_waypoint = 'No Waypoint Set.',
        tp_error = 'Error While Teleporting.',
        not_online = 'Player not online.',
        wrong_format = 'Incorrect format.'
    },
    success = {
        teleported_waypoint = 'Teleported To Waypoint.'
    },
    info = {
        checking_ban = 'Hello %s. We are checking if you are banned.',
        join_server = 'Welcome %s to ' .. BlashConfig.Server.Name .. '.'
    },
    command = {
        tp = {
            help = 'TP To Player or Coords (Admin Only)',
            params = {
                x = { name = 'id/x', help = 'ID of player or X position' },
                y = { name = 'y', help = 'Y position' },
                z = { name = 'z', help = 'Z position' },
            },
        },
        tpm = { help = 'TP To Marker (Admin Only)' },
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
