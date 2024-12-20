
fx_version 'cerulean'

author 'DRC Scripts'
description 'DRC TRUCKER JOB'
lua54 'yes'
version '1.0.0'

game 'gta5'

ui_page 'html/index.html'

files {
	'locales/*.json'
}

shared_scripts {
	'@ox_lib/init.lua',
	'shared/sh_config.lua'
}

client_script {
	'client/cl_utils.lua',
	'client/*.lua',

}

server_script {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}

escrow_ignore {
	'shared/sh_config.lua',
	'client/cl_utils',
	'client/cl_consumables.lua',
	'server/sv_consumables.lua',
	'locales/translations.json',
	'server/sv_utils'
}

data_file 'DLC_ITYP_REQUEST' 'stream/bzzz_xmas_gift_box_a.ytyp'

