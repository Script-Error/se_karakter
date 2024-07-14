local function Login ()

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() and cache.ped ~= PlayerPedId()  do
        Wait(0)
    end

    local freemode = joaat('mp_m_freemode_01')
    lib.requestModel(freemode, 1500)
    SetPlayerModel(cache.playerId, freemode)
    SetPedDefaultComponentVariation(cache.ped)
    SetModelAsNoLongerNeeded(freemode)

    FreezeEntityPosition(cache.ped, true)
    Wait(2500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    DoScreenFadeIn(500)

    local DataSaya = lib.callback.await('se_karakter:sv_callback:getChar')
    if not DataSaya then
        
        local input = lib.inputDialog('Pembuatan Karakter', {
            {
                type = "input",
                label = "Nama Depan",
                required = true,
                min = 1,
            },
            {
                type = "input",
                label = "Nama Belakang",
                required = true,
                min = 1,
            },
            {
                type = 'date',
                label = 'Tanggal Lahir',
                icon = {'far', 'calendar'},
                default = true,
                ormat = "DD/MM/YYYY"
            },
        }, {
            allowCancel = false
        })
        
        if input then
            local DataBaru = {
                nama_depan = input[1],
                nama_belakang = input[2],
                tanggal_lahir = math.floor(input[3] / 1000)
            }

            FreezeEntityPosition(cache.ped, false)
            TriggerServerEvent("se_karakter:server:BuatKarakter", DataBaru)
        end
    else
        print(json.encode(DataSaya))
        FreezeEntityPosition(cache.ped, false)
    end
end

CreateThread(function()
    while true do
        Wait(100)
        if NetworkIsSessionStarted() then
            pcall(function() exports.spawnmanager:setAutoSpawn(false) end)
            Wait(250)
            Login()
            break
        end
    end
end)