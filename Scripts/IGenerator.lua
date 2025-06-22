---@class IGenerator : ShapeClass
IGenerator = class()

function IGenerator:sv_init()
    self.eCalculator = nil
    self.interactable.publicData = {outE = self.data.outE}
end

function IGenerator:sv_register()
    local players = sm.player.getAllPlayers()
    for k, v in pairs(players) do
        if v.publicData then
            self.eCalculator = v.publicData.tool
            sm.event.sendToTool(self.eCalculator, "sv_registerGenerator", self.interactable)
            return
        end
    end
end

function IGenerator:sv_deregister()
    sm.event.sendToTool(self.eCalculator, "sv_deregisterGenerator", self.interactable)
end

function IGenerator:sv_isGenerator() end