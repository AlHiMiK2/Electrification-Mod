---@class LogicReceiver : ShapeClass
LogicReceiver = class()

function LogicReceiver:sv_init(active)
    self.sv = {
        E = 0,
        maxE = self.data.maxE,
        minE = self.data.minE,
        lossE = self.data.lossE,
        logic = false,
        isPowered = false
    }
    self.needSync = true
    self.interactable.active = active
    self.interactable.publicData = self.sv
end

function LogicReceiver:sv_receiveE(data)
    self.sv.E = math.max(data.E, 0)
    self.sv.logic = data.logic

    if self.sv.E >= self.sv.minE then
        self.sv.isPowered = true
    else
        self.sv.isPowered = false
        self.sv.logic = false
    end
    self.interactable.publicData = self.sv
    self.needSync = true
end

function LogicReceiver:sv_checkSender()
    local parents = self.interactable:getParents(sm.interactable.connectionType.logic)
    for i, v in pairs(parents) do
        if sm.event.sendToInteractable(v, "sv_isLogicSender") then
            return true
        end
    end
    return false
end

function LogicReceiver:sv_isLogicReceiver() end

function LogicReceiver:cl_init()
    self.cl = {
        E = 0,
        maxE = self.data.maxE,
        minE = self.data.minE,
        lossE = self.data.lossE,
        logic = false,
        isPowered = false
    }
end