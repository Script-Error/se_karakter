fx_version "cerulean"
game "gta5"
author "Script Error Team"
lua54 "yes"

shared_scripts {
    "@ox_lib/init.lua",
    "shared/*.lua"
}

client_scripts {
    "client/cl_*.lua",
    "_cb/client.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/sv_*.lua",
    "_cb/server.lua"
}
