fx_version 'cerulean'
game 'gta5'

author 'Ronin Base'
description 'Gelişmiş Namaz Sistemi - kendi animasyonları ile'
version '1.1.0'

icon 'icon.png'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
