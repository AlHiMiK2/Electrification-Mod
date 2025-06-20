dofile("$CONTENT_DATA/Scripts/Receiver.lua")
dofile("$CONTENT_DATA/Scripts/Sender.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")
---@class Accumulator : Receiver, Sender
Accumulator = class(_wm_class(Receiver, Sender))

Accumulator.maxParentCount = 1
Accumulator.maxChildCount = -1
Accumulator.connectionInput = sm.interactable.connectionType.logic
Accumulator.connectionOutput = sm.interactable.connectionType.logic

function Accumulator:server_onCreate()
    self.genE = self.data.genE
    self.capacityE = self.data.capacityE
    self.currentE = 0
    Receiver.sv_init(self, true)
end

function Accumulator:server_onFixedUpdate(timeStep)
    self.interactable.active = self.currentE <= self.capacityE
    if not Receiver.sv_checkSender(self) then
        Receiver.sv_receiveE(self, 0)
    end
    if self.needSync then
        self.needSync = false
        self.currentE = self.currentE + self.sv.E
    end
    local sendE = self.genE
    local over = self.currentE - self.genE
    if over < 0 then
        sendE = sendE + over
    end

    self.currentE = self.currentE - Sender.sv_send(self, sendE)
end