---@class Fungsi
local fungsi = {}

---@class dataPemain
---@field source string
---@field identifier string
---@field nama_steam string
---@field nama_karakter string
---@field informasi table
---@field metadata table
---@field duit table
---@field pekerjaan table
---@field lokasi_terakhir vector3

SE.semuaPemain = {} ---@type table<string, table>

---@param steam string
---@return boolean|dataPemain
function fungsi.cekdataPemain(steam)
    local player = MySQL.prepare.await('SELECT * FROM karakter where identifier = ?', { steam })
    return player and {
        identifier = player.identifier,
        nama_steam = player.nama_steam,
        nama_karakter = player.nama_karakter,
        informasi = json.decode(player.informasi),
        metadata = json.decode(player.metadata),
        duit = json.decode(player.duit),
        pekerjaan = player.pekerjaan and json.decode(player.pekerjaan),
        lokasi_terakhir = json.decode(player.lokasi_terakhir),
    } or false
end

---@param source string
---@param dataPemain dataPemain
function fungsi.login(source, dataPemain)
    local KarakterData = dataPemain or {}

    local identifier = KarakterData.identifier or GetPlayerIdentifierByType(source, SEConfig.identifier)
    if not identifier then return DropPlayer(source, "Identifier Missing !") end

    KarakterData.source = source
    KarakterData.identifier = identifier
    KarakterData.nama_steam = GetPlayerName(KarakterData.source)
    KarakterData.informasi = KarakterData.informasi or {}
    KarakterData.nama_karakter = ("%s %s"):format(KarakterData.informasi.nama_depan, KarakterData.informasi.nama_belakang)
    KarakterData.metadata = KarakterData.metadata or {}

    KarakterData.duit = KarakterData.duit or {
        cash = 0,
        bank = 0,
    }

    KarakterData.pekerjaan = KarakterData.pekerjaan or {
        nama = 'pengangguran',
        label = 'Pengangguran',
        grade = {
            level = 0,
            label = 'Wes Mbuh',
            gajih = 0
        }
    }

    KarakterData.metadata.laper = KarakterData.metadata.laper or 100
    KarakterData.metadata.haus = KarakterData.metadata.haus or 100
    KarakterData.metadata.stress = KarakterData.metadata.stress or 0
    KarakterData.lokasi_terakhir = KarakterData.lokasi_terakhir or SEConfig.defaultSpawn

    return fungsi.buatData (KarakterData)
end

---@param Data dataPemain
function fungsi.buatData(Data)
    local self = {}
    self.fungsi = {}
    self.dataPemain = Data

    ---@param event string
    function self.triggerEvent(event, ...)
        return TriggerClientEvent(event, self.dataPemain.source, ...)
    end

    ---@param tipe string
    ---@param jumlah number
    function self.addMoney(tipe, jumlah)
        print(tipe, jumlah)
    end

    function self.simpenData()
        fungsi.simpanData(self.dataPemain.source)
    end

    SE.semuaPemain[self.dataPemain.source] = self

    fungsi.simpanData(self.dataPemain.source)
    return self
end

---@param source string
function fungsi.simpanData(source)
    local src = source
    local ped = GetPlayerPed(src)
    local pcoords = GetEntityCoords(ped)
    local dataPemain = SE.semuaPemain[src]?.dataPemain ---@class dataPemain

    if not dataPemain then
        return lib.print.error('Table dataPemain kosong!')
    end
    
    MySQL.insert.await('INSERT INTO karakter (identifier, nama_steam, nama_karakter, informasi, metadata, duit, pekerjaan, lokasi_terakhir) VALUES (:identifier, :nama_steam, :nama_karakter, :informasi, :metadata, :duit, :pekerjaan, :lokasi_terakhir) ON DUPLICATE KEY UPDATE identifier = :identifier, nama_steam = :nama_steam, nama_karakter = :nama_karakter, informasi = :informasi, metadata = :metadata, duit = :duit, pekerjaan = :pekerjaan, lokasi_terakhir = :lokasi_terakhir', {
        identifier = dataPemain.identifier,
        nama_steam = dataPemain.nama_steam,
        nama_karakter = dataPemain.nama_karakter,
        informasi = json.encode(dataPemain.informasi),
        metadata = json.encode(dataPemain.metadata),
        duit = json.encode(dataPemain.duit),
        pekerjaan = json.encode(dataPemain.pekerjaan),
        lokasi_terakhir = json.encode(pcoords)
    })
    lib.print.verbose('Data pemain telah disimpan!')
end

RegisterNetEvent('se_karakter:server:BuatKarakter', function (dataBaru)
    if GetInvokingResource() then return
        print("error")
    end
    
    local newData = {}
    newData.informasi = {}
    newData.informasi.nama_depan = dataBaru.nama_depan
    newData.informasi.nama_belakang = dataBaru.nama_belakang
    newData.informasi.tanggal_lahir = os.date('%d/%m/%Y', dataBaru.tanggal_lahir)
    
    fungsi.login(source --[[@as string]], newData)
end)

lib.callback.register('se_karakter:sv_callback:getChar', function(source)
    local steam = GetPlayerIdentifierByType(source, SEConfig.identifier)
    local DataPemain = fungsi.cekdataPemain(steam)
    local karakter

    if DataPemain then
        karakter = fungsi.login(source, DataPemain --[[@as dataPemain]])
    end

    return karakter
end)