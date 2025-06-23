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

function Vector3SignedAngle(from, to, axis)
    local fromNorm = from:normalize()
    local toNorm = to:normalize()
    local axisNorm = axis:normalize()

    local cosTheta = fromNorm:dot(toNorm)
    cosTheta = math.max(-1, math.min(1, cosTheta))
    local unsignedAngle = math.deg(math.acos(cosTheta))

    local crossProduct = fromNorm:cross(toNorm)
    local sign = crossProduct:dot(axisNorm) >= 0 and 1 or -1

    if unsignedAngle > 179.9 and sign < 0 then
        unsignedAngle = -unsignedAngle
    end

    local signedAngle = unsignedAngle * sign
    return signedAngle
end