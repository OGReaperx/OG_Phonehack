fx_version 'cerulean'
game 'gta5'

author 'OGReaper'
description 'Simple leo phone hack for lb-phone and yseries phone'
version '1.0.3'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

client_scripts {
    'client/*.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'ox_inventory',
    'community_bridge'
}

lua54 'yes'