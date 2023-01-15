fx_version 'cerulean'
game 'gta5'

name 'blash-core'
description 'blash-core'
author 'boppe'
version '1.0.0'

dependency 'oxmysql'
lua54 'yes'

ui_page 'html/ui.html'
files { 'html/app.js', 'html/ui.html', 'html/app.css' }

client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/threads.lua',
    'client/events.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/functions.lua',
    'server/player.lua',
    'server/events.lua',
    'server/commands.lua',
    'server/threads.lua'
}
shared_scripts { 'shared/*.lua', 'locales/en.lua', 'locales/*.lua' }