dofile("$CONTENT_DATA/Scripts/IComponent.lua")
dofile("$CONTENT_DATA/Scripts/ILogic.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")
---@class E2LogicConverter : IComponent, ILogic
E2LogicConverter = class(_wm_class(IComponent, ILogic))

E2LogicConverter.maxChildCount = -1
E2LogicConverter.maxParentCount = -1
E2LogicConverter.connectionInput = sm.interactable.connectionType.logic
E2LogicConverter.connectionOutput = sm.interactable.connectionType.logic
E2LogicConverter.colorNormal = sm.color.new("#2770bf")
E2LogicConverter.colorHighlight = sm.color.new("#4188d6")

function E2LogicConverter:server_onCreate()
    IComponent.sv_init(self)
    ILogic.sv_init(self)
    self.interactable.active = true
end

function E2LogicConverter:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IComponent.sv_register(self)
        return
    end
    self.interactable.publicData.logic = self.interactable.publicData.E >= self.interactable.publicData.consumptionE * 0.5
end

function E2LogicConverter:server_onDestroy()
    IComponent.sv_deregister(self)
end