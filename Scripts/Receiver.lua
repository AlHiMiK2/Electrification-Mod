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
    self.interactable.active = active
    self.interactable.publicData = self.sv
end

function Receiver:sv_calculateMaxE()
    local childs = self.interactable:getChildren(sm.interactable.connectionType.logic)
    local maxE = 0
    for i, v in pairs(childs) do
        if v.type == "scripted" and sm.event.sendToInteractable(v, "sv_isReceiver") then
            if v.active then
                maxE = maxE + v.publicData.maxE
            end
        end
    end
    self.sv.maxE = math.max(maxE, 0)
    self.interactable.publicData.maxE = self.sv.maxE
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

function Receiver:sv_resetRecieve()
    self.interactable.publicData.E = 0
    self.interactable.publicData.isPowered = false
    if sm.event.sendToInteractable(self.interactable, "sv_isSender") then
        self:sv_resetSend()
    end
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