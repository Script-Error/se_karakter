DataPemain = {}
Fungsi = {}

local config = require "config"

function Fungsi.fetchDataPemain(steam)
    local player = MySQL.prepare.await('SELECT * FROM karakter where identifier = ?', { steam })
    return player and {
        identifier = player.identifier,
        nama_steam = player.nama_steam,
        nama_karakter = player.nama_karakter,
        informasi = json.decode(player.informasi),
        metadata = json.decode(player.metadata),
        duit = json.decode(player.duit),
        pekerjaan = player.pekerjaan and json.decode(player.pekerjaan),
        loaksi_terakhir = json.decode(player.loaksi_terakhir),
    } or false
end

function Fungsi.Login(dataPemain)
    local KarakterData = dataPemain or {}

    local identifier = KarakterData.identifier or GetPlayerIdentifierByType(source, config.shared.identifierUsed)
    if not identifier then return DropPlayer(source, "Identifier Missing !") end

    KarakterData.source = source
    KarakterData.identifier = identifier
    KarakterData.nama_steam = GetPlayerName(KarakterData.source)
    KarakterData.nama_karakter = ("%s %s"):format(KarakterData.informasi.nama_depan, KarakterData.informasi.nama_belakang)
    
    KarakterData.informasi = KarakterData.informasi or {}
    KarakterData.metadata = KarakterData.metadata or {}
    KarakterData.duit = KarakterData.duit or {
        cash = 0,
        bank = 0,
    }
    KarakterData.metadata.laper = KarakterData.metadata.laper or 100
    KarakterData.metadata.haus = KarakterData.metadata.haus or 100
    KarakterData.metadata.stress = KarakterData.metadata.stress or 0
    KarakterData.loaksi_terakhir = KarakterData.loaksi_terakhir or config.client.defaultSpawn

    return Fungsi.BuatData (KarakterData)
end


function Fungsi.BuatData( Data )
    local self = {}
    self.Fungsi = {}
    self.DataPemain = Data

    
    function self.Fungsi.UpdatePlayerData()
        TriggerEvent('se_karakter:server:updatePlayerData', self.DataPemain)
        TriggerClientEvent('se_karakter:client:updatePlayerData', self.DataPemain.source, self.DataPemain)
    end

    -- ---@param job string name
    -- ---@param grade integer
    -- ---@return boolean success if job was set
    -- function self.Fungsi.SetJob(job, grade)
    --     job = job or ''
    --     grade = tonumber(grade) or 0
    --     if not QBX.Shared.Jobs[job] then return false end
    --     self.DataPemain.job.name = job
    --     self.DataPemain.job.label = QBX.Shared.Jobs[job].label
    --     self.DataPemain.job.onduty = QBX.Shared.Jobs[job].defaultDuty
    --     self.DataPemain.job.type = QBX.Shared.Jobs[job].type or 'none'
    --     if QBX.Shared.Jobs[job].grades[grade] then
    --         local jobgrade = QBX.Shared.Jobs[job].grades[grade]
    --         self.DataPemain.job.grade = {}
    --         self.DataPemain.job.grade.name = jobgrade.name
    --         self.DataPemain.job.grade.level = grade
    --         self.DataPemain.job.payment = jobgrade.payment or 30
    --         self.DataPemain.job.isboss = jobgrade.isboss or false
    --     else
    --         self.DataPemain.job.grade = {}
    --         self.DataPemain.job.grade.name = 'No Grades'
    --         self.DataPemain.job.grade.level = 0
    --         self.DataPemain.job.payment = 30
    --         self.DataPemain.job.isboss = false
    --     end

    --     if not self.Offline then
    --         self.Fungsi.UpdatePlayerData()
    --         TriggerEvent('QBCore:Server:OnJobUpdate', self.DataPemain.source, self.DataPemain.job)
    --         TriggerClientEvent('QBCore:Client:OnJobUpdate', self.DataPemain.source, self.DataPemain.job)
    --     end

    --     return true
    -- end

    -- ---@param gang string name
    -- ---@param grade integer
    -- ---@return boolean success if gang was set
    -- function self.Fungsi.SetGang(gang, grade)
    --     gang = gang or ''
    --     grade = tonumber(grade) or 0
    --     if not QBX.Shared.Gangs[gang] then return false end
    --     self.DataPemain.gang.name = gang
    --     self.DataPemain.gang.label = QBX.Shared.Gangs[gang].label
    --     if QBX.Shared.Gangs[gang].grades[grade] then
    --         local ganggrade = QBX.Shared.Gangs[gang].grades[grade]
    --         self.DataPemain.gang.grade = {}
    --         self.DataPemain.gang.grade.name = ganggrade.name
    --         self.DataPemain.gang.grade.level = grade
    --         self.DataPemain.gang.isboss = ganggrade.isboss or false
    --     else
    --         self.DataPemain.gang.grade = {}
    --         self.DataPemain.gang.grade.name = 'No Grades'
    --         self.DataPemain.gang.grade.level = 0
    --         self.DataPemain.gang.isboss = false
    --     end

    --     if not self.Offline then
    --         self.Fungsi.UpdatePlayerData()
    --         TriggerEvent('QBCore:Server:OnGangUpdate', self.DataPemain.source, self.DataPemain.gang)
    --         TriggerClientEvent('QBCore:Client:OnGangUpdate', self.DataPemain.source, self.DataPemain.gang)
    --     end

    --     return true
    -- end

    -- ---@param onDuty boolean
    -- function self.Fungsi.SetJobDuty(onDuty)
    --     self.DataPemain.job.onduty = not not onDuty -- Make sure the value is a boolean if nil is sent
    --     TriggerEvent('QBCore:Server:SetDuty', self.DataPemain.source, self.DataPemain.job.onduty)
    --     TriggerClientEvent('QBCore:Client:SetDuty', self.DataPemain.source, self.DataPemain.job.onduty)
    --     self.Fungsi.UpdatePlayerData()
    -- end

    ---@param key string
    ---@param val any
    function self.Fungsi.SetPlayerData(key, val)
        if not key or type(key) ~= 'string' then return end
        self.DataPemain[key] = val
        self.Fungsi.UpdatePlayerData()
    end

    ---@param meta string
    ---@param val any
    function self.Fungsi.SetMetaData(meta, val)
        if not meta or type(meta) ~= 'string' then return end
        if meta == 'hunger' or meta == 'thirst' then
            val = val > 100 and 100 or val
        end
        self.DataPemain.metadata[meta] = val
        self.Fungsi.UpdatePlayerData()
        if meta == 'inlaststand' or meta == 'isdead' then
            self.Fungsi.Save()
        end
    end

    ---@param meta string
    ---@return any
    function self.Fungsi.GetMetaData(meta)
        if not meta or type(meta) ~= 'string' then return end
        return self.DataPemain.metadata[meta]
    end

    -- ---@param amount number
    -- function self.Fungsi.AddJobReputation(amount)
    --     if not amount then return end
    --     amount = tonumber(amount) --[[@as number]]
    --     self.DataPemain.metadata.jobrep[self.DataPemain.job.name] = self.DataPemain.metadata.jobrep[self.DataPemain.job.name] + amount
    --     self.Fungsi.UpdatePlayerData()
    -- end

    ---@param moneytype MoneyType
    ---@param amount number
    ---@param reason? string
    ---@return boolean success if money was added
    function self.Fungsi.AddMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        amount = tonumber(amount) --[[@as number]]
        if amount < 0 then return false end
        if not self.DataPemain.money[moneytype] then return false end
        self.DataPemain.money[moneytype] = self.DataPemain.money[moneytype] + amount

        if not self.Offline then
            self.Fungsi.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.DataPemain.source) .. ' (citizenid: ' .. self.DataPemain.citizenid .. ' | id: ' .. self.DataPemain.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.DataPemain.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.DataPemain.source) .. ' (citizenid: ' .. self.DataPemain.citizenid .. ' | id: ' .. self.DataPemain.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.DataPemain.money[moneytype] .. ' reason: ' .. reason)
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.DataPemain.source, moneytype, amount, false)
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.DataPemain.source, moneytype, amount, "add", reason)
            TriggerEvent('QBCore:Server:OnMoneyChange', self.DataPemain.source, moneytype, amount, "add", reason)
        end

        return true
    end

    ---@param moneytype MoneyType
    ---@param amount number
    ---@param reason? string
    ---@return boolean success if money was removed
    function self.Fungsi.RemoveMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        amount = tonumber(amount) --[[@as number]]
        if amount < 0 then return false end
        if not self.DataPemain.money[moneytype] then return false end
        for _, mtype in pairs(Config.Money.DontAllowMinus) do
            if mtype == moneytype then
                if (self.DataPemain.money[moneytype] - amount) < 0 then
                    return false
                end
            end
        end
        self.DataPemain.money[moneytype] = self.DataPemain.money[moneytype] - amount

        if not self.Offline then
            self.Fungsi.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.DataPemain.source) .. ' (citizenid: ' .. self.DataPemain.citizenid .. ' | id: ' .. self.DataPemain.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.DataPemain.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.DataPemain.source) .. ' (citizenid: ' .. self.DataPemain.citizenid .. ' | id: ' .. self.DataPemain.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.DataPemain.money[moneytype] .. ' reason: ' .. reason)
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.DataPemain.source, moneytype, amount, true)
            if moneytype == 'bank' then
                TriggerClientEvent('qb-phone:client:RemoveBankMoney', self.DataPemain.source, amount)
            end
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.DataPemain.source, moneytype, amount, "remove", reason)
            TriggerEvent('QBCore:Server:OnMoneyChange', self.DataPemain.source, moneytype, amount, "remove", reason)
        end

        return true
    end

    ---@param moneytype MoneyType
    ---@param amount number
    ---@param reason? string
    ---@return boolean success if money was set
    function self.Fungsi.SetMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        amount = tonumber(amount) --[[@as number]]
        if amount < 0 then return false end
        if not self.DataPemain.money[moneytype] then return false end
        local difference = amount - self.DataPemain.money[moneytype]
        self.DataPemain.money[moneytype] = amount

        if not self.Offline then
            self.Fungsi.UpdatePlayerData()
            TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'SetMoney', 'green', '**' .. GetPlayerName(self.DataPemain.source) .. ' (citizenid: ' .. self.DataPemain.citizenid .. ' | id: ' .. self.DataPemain.source .. ')** $' .. amount .. ' (' .. moneytype .. ') set, new ' .. moneytype .. ' balance: ' .. self.DataPemain.money[moneytype] .. ' reason: ' .. reason)
            TriggerClientEvent('hud:client:OnMoneyChange', self.DataPemain.source, moneytype, math.abs(difference), difference < 0)
            TriggerClientEvent('QBCore:Client:OnMoneyChange', self.DataPemain.source, moneytype, amount, "set", reason)
            TriggerEvent('QBCore:Server:OnMoneyChange', self.DataPemain.source, moneytype, amount, "set", reason)
        end

        return true
    end

    ---@param moneytype MoneyType
    ---@return boolean | number amount or false if moneytype does not exist
    function self.Fungsi.GetMoney(moneytype)
        if not moneytype then return false end
        return self.DataPemain.money[moneytype]
    end

    ---@param cardNumber number
    function self.Fungsi.SetCreditCard(cardNumber)
        self.DataPemain.charinfo.card = cardNumber
        self.Fungsi.UpdatePlayerData()
    end

    function self.Fungsi.Save()
        if self.Offline then
            SaveOffline(self.DataPemain)
        else
            Save(self.DataPemain.source)
        end
    end

    ---@deprecated call exports.qbx_core:Logout(source)
    function self.Fungsi.Logout()
        if self.Offline then return end -- Unsupported for Offline Players
        Logout(self.DataPemain.source)
    end

    if not self.Offline then
        QBX.Players[self.DataPemain.source] = self
        local ped = GetPlayerPed(self.DataPemain.source)
        lib.callback.await('qbx_core:client:setHealth', self.DataPemain.source, self.DataPemain.metadata.health)
        SetPedArmour(ped, self.DataPemain.metadata.armor)
        -- At this point we are safe to emit new instance to third party resource for load handling
        GlobalState.PlayerCount += 1
        self.Fungsi.UpdatePlayerData()
        TriggerEvent('QBCore:Server:PlayerLoaded', self)
    end

    return self
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
    
    Fungsi.Login(newData)
end)