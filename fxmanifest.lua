fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54        'yes'

client_scripts {
    '@bl_bridge/imports/client.lua',
    'client/**.lua'
}

server_scripts {
    '@bl_bridge/imports/server.lua',
    'server/**.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}
