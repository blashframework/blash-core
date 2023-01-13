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

client_scripts { 'client/main.lua', 'client/*.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua', 'server/*.lua' }
shared_scripts { 'shared/*.lua', 'locales/en.lua', 'locales/*.lua' }