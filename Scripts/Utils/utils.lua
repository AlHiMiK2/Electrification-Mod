dofile("table.lua")

--[[
---@param ... table classes to inherit
---@return table
function _wm_class(...)
    local nc = {}
    local p = {...}
    for _, c in pairs(p) do
        for k, v in pairs(c) do
            nc[k] = v
        end
    end
    return nc
end
]]