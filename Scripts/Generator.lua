dofile("$CONTENT_DATA/Scripts/Sender.lua")
---@class Generator : Sender
Generator = class(Sender)

Generator.maxParentCount = 0
Generator.maxChildCount = -1
Generator.connectionInput = sm.interactable.connectionType.none
Generator.connectionOutput = sm.interactable.connectionType.logic

function Generator:server_onCreate()
    self.genE = self.data.genE
end

function Generator:server_onFixedUpdate(timeStep)
    Sender.sv_send(self, self.genE)
end