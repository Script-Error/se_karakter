local config = require "config"

lib.callback.register('se_karakter:sv_callback:getChar', function(source)
    local steam = GetPlayerIdentifierByType(source, config.shared.identifierUsed)
    local DataPemain = Fungsi.fetchDataPemain(steam)
    
    if DataPemain then
        Fungsi.Login(DataPemain)
    end

    return DataPemain
end)