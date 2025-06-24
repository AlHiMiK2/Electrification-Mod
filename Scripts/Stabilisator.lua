dofile("$CONTENT_DATA/Scripts/IGenerator.lua")
dofile("$CONTENT_DATA/Scripts/IComponent.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")
---@class Stab : IGenerator, IComponent
Stab = class(_wm_class(IGenerator, IComponent))

Stab.maxParentCount = -1
Stab.maxChildCount = -1
Stab.connectionInput = sm.interactable.connectionType.logic
Stab.connectionOutput = sm.interactable.connectionType.logic

function Stab:server_onCreate()
    IGenerator.sv_init(self)
    IComponent.sv_init(self)
    self.interactable.publicData = {E = 0, consumptionE = self.data.consumptionE, outE = 0, capacityE = 1, storedE = 0}
end

function Stab:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IGenerator.sv_register(self)
        IComponent.sv_register(self)
        return
    end
    self.interactable.publicData.storedE = math.min(self.interactable.publicData.storedE + self.interactable.publicData.E, self.interactable.publicData.capacityE)
    self.interactable.active = self.interactable.publicData.storedE <= self.interactable.publicData.capacityE
end

function Stab:server_onDestroy()
    IGenerator.sv_deregister(self)
    IComponent.sv_deregister(self)
end

function Stab:sv_isStab() end