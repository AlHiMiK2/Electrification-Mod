---@class IComponent : ShapeClass
IComponent = class()

function IComponent:sv_init()
    self.eCalculator = nil
    self.interactable.publicData = {E = 0, consumptionE = self.data.consumptionE}
end

function IComponent:sv_register()
    local players = sm.player.getAllPlayers()
    for k, v in pairs(players) do
        if v.publicData then
            self.eCalculator = v.publicData.tool
            sm.event.sendToTool(self.eCalculator, "sv_registerComponent", self.interactable)
            return
        end
    end
end

function IComponent:sv_deregister()
    sm.event.sendToTool(self.eCalculator, "sv_deregisterComponent", self.interactable)
end

function IComponent:sv_isComponent() end