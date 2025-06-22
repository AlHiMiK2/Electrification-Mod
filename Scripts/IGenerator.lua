dofile("$CONTENT_DATA/Scripts/ECalculator.lua")
---@class IGenerator : ShapeClass
IGenerator = class()

function IGenerator:sv_init()
    self.interactable.publicData = {outE = self.data.outE or 0}
end

function IGenerator:sv_register()
    self.eCalculator = ECalculator.instance
    sm.event.sendToTool(self.eCalculator, "sv_registerGenerator", self.interactable)
end

function IGenerator:sv_deregister()
    sm.event.sendToTool(self.eCalculator, "sv_deregisterGenerator", self.interactable)
end

function IGenerator:sv_isGenerator() end