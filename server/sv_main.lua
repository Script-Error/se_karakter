local config = require "config"

lib.callback.register('se_karakter:sv_callback:getChar', function(source)
    local identifier = GetPlayerIdentifierByType(source, config.shared.identifierUsed)
    if not identifier then return DropPlayer(source, "Identifier Missing !") end

    local result = MySQL.query.await("SELECT * FROM karakter WHERE steam = ?", {identifier})

    if not result[1] then
        return {
            status = "baru"
        }
    end
end)