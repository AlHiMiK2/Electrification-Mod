dofile("$CONTENT_DATA/Scripts/ECalculator.lua")
---@class IComponent : ShapeClass
IComponent = class()

function IComponent:sv_init()
    self.interactable.publicData = {E = 0, consumptionE = self.data.consumptionE}
end

function IComponent:sv_register()
    self.eCalculator = ECalculator.instance
    sm.event.sendToTool(self.eCalculator, "sv_registerComponent", self.interactable)
end

function IComponent:sv_deregister()
    sm.event.sendToTool(self.eCalculator, "sv_deregisterComponent", self.interactable)
end

function IComponent:sv_isComponent() end