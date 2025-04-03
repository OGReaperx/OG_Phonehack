fx_version 'cerulean'
game 'gta5'

author 'OGReaper'
description 'Simple leo phone hack for lb-phone and yseries phone'
version '1.0.3'

shared_scripts {
    '@ox_lib/init.lua',
    'bridge/shared.lua',
    'shared/*.lua'
}

client_scripts {
    'bridge/init/client.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/init/server.lua',
    'server/*.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'ox_inventory',
}

lua54 'yes'