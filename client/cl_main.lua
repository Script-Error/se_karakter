local function CheckChar ()
    local Char = lib.callback.await('se_karakter:sv_callback:getChar')
end

CreateThread(function()
    while true do
        Wait(100)
        if NetworkIsSessionStarted() then
            pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
            Wait(250)
            CheckChar()
            break
        end
    end
end)