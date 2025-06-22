dofile("$CONTENT_DATA/Scripts/IGenerator.lua")
dofile("$CONTENT_DATA/Scripts/IComponent.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")
---@class Accumulator : IGenerator, IComponent
Accumulator = class(_wm_class(IGenerator, IComponent))

Accumulator.maxParentCount = 1
Accumulator.maxChildCount = -1
Accumulator.connectionInput = sm.interactable.connectionType.logic
Accumulator.connectionOutput = sm.interactable.connectionType.logic

function Accumulator:server_onCreate()
    IGenerator.sv_init(self)
    IComponent.sv_init(self)
    self.interactable.publicData = {E = 0, consumptionE = self.data.consumptionE, outE = 0, capacityE = self.data.capacityE, storedE = 0, isSafe = self.data.isSafe or false}
end

function Accumulator:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IGenerator.sv_register(self)
        IComponent.sv_register(self)
        return
    end
    self.interactable.publicData.storedE = math.min(self.interactable.publicData.storedE + self.interactable.publicData.E, self.interactable.publicData.capacityE)
    self.interactable.active = self.interactable.publicData.storedE <= self.interactable.publicData.capacityE
end

function Accumulator:sv_setOutE(sumE)
    local E = sumE
    local over = self.interactable.publicData.storedE - E
    if over < 0 then
        E = E + over
    end
    self.interactable.publicData.outE = E
    self.interactable.publicData.storedE = self.interactable.publicData.storedE - E
end

function Accumulator:server_onDestroy()
    IGenerator.sv_deregister(self)
    IComponent.sv_deregister(self)
end