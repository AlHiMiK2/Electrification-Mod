dofile("$CONTENT_DATA/Scripts/IGenerator.lua")
dofile("$CONTENT_DATA/Scripts/IComponent.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")
---@class Stabilizer : IGenerator, IComponent
Stabilizer = class(_wm_class(IGenerator, IComponent))

Stabilizer.maxParentCount = -1
Stabilizer.maxChildCount = -1
Stabilizer.connectionInput = sm.interactable.connectionType.logic
Stabilizer.connectionOutput = sm.interactable.connectionType.logic

function Stabilizer:server_onCreate()
    IGenerator.sv_init(self)
    IComponent.sv_init(self)
    self.interactable.publicData = {E = 0, consumptionE = self.data.consumptionE, outE = 0}
end

function Stabilizer:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IGenerator.sv_register(self)
        IComponent.sv_register(self)
        return
    end
    self.interactable.active = true
end

function Stabilizer:server_onDestroy()
    IGenerator.sv_deregister(self)
    IComponent.sv_deregister(self)
end

function Stabilizer:sv_isStabilizer() end