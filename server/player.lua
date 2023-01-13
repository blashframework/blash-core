Blash.Players = {}
Blash.Player = {}

function Blash.Player.Login(source, newData)
    if source and source ~= '' then
        Blash.Player.CheckPlayerData(source, newData)
        return true
    else
        Blash.ShowError(GetCurrentResourceName(), 'ERROR BLASH.PLAYER.LOGIN - NO SOURCE GIVEN!')
        return false
    end
end

function Blash.Player.GetOfflinePlayer(license)
    if license then
        local PlayerData = MySQL.Sync.prepare('SELECT * FROM players where license = ?', {license})
        if PlayerData then
            PlayerData.metadata = json.decode(PlayerData.metadata)
            return Blash.Player.CheckPlayerData(nil, PlayerData)
        end
    end
    return nil
end

function Blash.Player.CheckPlayerData(source, PlayerData)
    PlayerData = PlayerData or {}
    local Offline = true
    if source then
        PlayerData.source = source
        PlayerData.license = PlayerData.license or Blash.Functions.GetIdentifier(source, 'license')
        PlayerData.name = GetPlayerName(source)
        Offline = false
    end
    -- Metadata
    PlayerData.metadata = PlayerData.metadata or {}
    PlayerData.metadata['kills'] = PlayerData.metadata['kills'] or 0
    PlayerData.metadata['deaths'] = PlayerData.metadata['deaths'] or 0
    PlayerData.metadata['games'] = PlayerData.metadata['games'] or 0
    return Blash.Player.CreatePlayer(PlayerData, Offline)
end

function Blash.Player.CreatePlayer(PlayerData, Offline)
    local self = {}
    self.Functions = {}
    self.PlayerData = PlayerData
    self.Offline = Offline

    function self.Functions.UpdatePlayerData()
        if self.Offline then return end -- Unsupported for Offline Players
        TriggerEvent('Blash:Player:SetPlayerData', self.PlayerData)
        TriggerClientEvent('Blash:Player:SetPlayerData', self.PlayerData.source, self.PlayerData)
    end

    function self.Functions.SetPlayerData(key, val)
        if not key or type(key) ~= 'string' then return end
        self.PlayerData[key] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetMetaData(meta, val)
        if not meta or type(meta) ~= 'string' then return end
        if meta == 'hunger' or meta == 'thirst' then
            val = val > 100 and 100 or val
        end
        self.PlayerData.metadata[meta] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.GetMetaData(meta)
        if not meta or type(meta) ~= 'string' then return end
        return self.PlayerData.metadata[meta]
    end

    function self.Functions.AddKill()
        local curKills = self.PlayerData.metadata['kills']
        self.Functions.SetMetaData('kills', curKills + 1)
    end

    function self.Functions.AddDeath()
        local curDeaths = self.PlayerData.metadata['kills']
        self.Functions.SetMetaData('deaths', curDeaths + 1)
    end

    function self.Functions.AddGame()
        local curGames = self.PlayerData.metadata['games']
        self.Functions.SetMetaData('games', curGames + 1)
    end

    function self.Functions.Save()
        if self.Offline then
            Blash.Player.SaveOffline(self.PlayerData)
        else
            Blash.Player.Save(self.PlayerData.source)
        end
    end

    if self.Offline then
        return self
    else
        Blash.Players[self.PlayerData.source] = self
        Blash.Player.Save(self.PlayerData.source)

        -- At this point we are safe to emit new instance to third party resource for load handling
        TriggerEvent('Blash:Server:PlayerLoaded', self)
        self.Functions.UpdatePlayerData()
    end
end

function Blash.Player.Save(source)
    local ped = GetPlayerPed(source)
    local PlayerData = Blash.Players[source].PlayerData
    if PlayerData then
        MySQL.insert('INSERT INTO players (license, name, metadata) VALUES (:license, :name, :metadata) ON DUPLICATE KEY UPDATE name = :name, metadata = :metadata', {
            license = PlayerData.license,
            name = PlayerData.name,
            metadata = json.encode(PlayerData.metadata)
        })
        Blash.ShowSuccess(GetCurrentResourceName(), PlayerData.name .. ' PLAYER SAVED!')
    else
        Blash.ShowError(GetCurrentResourceName(), 'ERROR Blash.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
    end
end

function Blash.Player.SaveOffline(PlayerData)
    if PlayerData then
        MySQL.insert('INSERT INTO players (license, name, metadata) VALUES (:license, :name, :metadata) ON DUPLICATE KEY UPDATE name = :name, metadata = :metadata', {
            license = PlayerData.license,
            name = PlayerData.name,
            metadata = json.encode(PlayerData.metadata)
        })
        Blash.ShowSuccess(GetCurrentResourceName(), PlayerData.name .. ' PLAYER SAVED!')
    else
        Blash.ShowError(GetCurrentResourceName(), 'ERROR Blash.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
    end
end