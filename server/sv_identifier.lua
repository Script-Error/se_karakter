---@class Identifier
---@field steam? string
---@field license? string
---@field license2? string
---@field discord? string
---@field ip? string
---@field live? string
---@field fivem? string

IDENTIFIER = {} ---@type table<string, Identifier>

---@return Identifier
local function getIdentifier(source)
    local src = source
    if not IDENTIFIER[src] then
        local results = {}
        local allIdentifier = GetPlayerIdentifiers(src)
        for i=1, #allIdentifier do
            local identifier = allIdentifier[i]
            local pos = identifier:find(':')
            local name = identifier:sub(1, pos - 1)
            results[name] = allIdentifier[i]
        end
        IDENTIFIER[src] = results
    end
    return IDENTIFIER[src]
end

exports('getIdentifier', getIdentifier)