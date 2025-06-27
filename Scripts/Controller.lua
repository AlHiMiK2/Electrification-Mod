dofile("$CONTENT_DATA/Scripts/IComponent.lua")
---@class Controller : IComponent
Controller = class(survivalSequence)

--Controller.maxParentCount = -1
--Controller.maxChildCount = 1
--Controller.connectionInput = sm.interactable.connectionType.logic
--Controller.connectionOutput = sm.interactable.connectionType.logic
--
--function Controller:server_onCreate()
--    IComponent.sv_init(self)
--end
--
--function Controller:server_onFixedUpdate(timeStep)
--    if self.eCalculator == nil then
--        IComponent.sv_register(self)
--        return
--    end
--    self.interactable.active = self.interactable.publicData.E >= self.interactable.publicData.consumptionE
--end
--
--function Controller:server_onDestroy()
--    IComponent.sv_deregister(self)
--end