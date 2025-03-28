fx_version 'cerulean'
game 'gta5'

author 'OGReaper'
description 'Simple leo phone hack for lb-phone'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'ox_inventory',
    'qbx_core',
}

lua54 'yes'