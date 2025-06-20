---@class Receiver : ShapeClass
Receiver = class()

function Receiver:sv_init(active)
    self.sv = {
        E = 0,
        maxE = self.data.maxE,
        minE = self.data.minE,
        lossE = self.data.lossE,
        isPowered = false
    }
    self.needSync = true
    self.interactable.active = active
    self.interactable.publicData = self.sv
end

function Receiver:sv_receiveE(E)
    self.sv.E = math.max(E, 0)

    if self.sv.E >= self.sv.minE then
        self.sv.isPowered = true
    else
        self.sv.isPowered = false
    end
    self.interactable.publicData = self.sv
    self.needSync = true
end

function Receiver:sv_calculateMaxE()
    local childs = self.interactable:getChildren(sm.interactable.connectionType.logic)
    if #childs == 0 then return 0 end
    local maxE = 0
    for i, v in pairs(childs) do
        if v.type == "scripted" and sm.event.sendToInteractable(v, "sv_isReceiver") then
            if v.active then
                maxE = maxE + v.publicData.maxE
            end
        end
    end
    self.sv.maxE = maxE
    self.needSync = true
end

function Receiver:sv_checkSender()
    local parents = self.interactable:getParents(sm.interactable.connectionType.logic)
    for i, v in pairs(parents) do
        if sm.event.sendToInteractable(v, "sv_isSender") then
            return true
        end
    end
    return false
end

function Receiver:sv_isReceiver() end

function Receiver:cl_init()
    self.cl = {
        E = 0,
        maxE = self.data.maxE,
        minE = self.data.minE,
        lossE = self.data.lossE,
        isPowered = false
    }
end