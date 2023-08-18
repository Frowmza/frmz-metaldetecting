fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54        'yes'

client_script 'client/**.lua'
server_script 'server/**.lua'


shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}
