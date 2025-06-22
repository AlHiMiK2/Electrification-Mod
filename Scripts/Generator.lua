dofile("$CONTENT_DATA/Scripts/ECalculator.lua")
dofile("$CONTENT_DATA/Scripts/IGenerator.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")
---@class Generator : IGenerator
Generator = class(IGenerator)

Generator.maxParentCount = 0
Generator.maxChildCount = -1
Generator.connectionInput = sm.interactable.connectionType.none
Generator.connectionOutput = sm.interactable.connectionType.logic

function Generator:server_onCreate()
    IGenerator.sv_init(self)
end

function Generator:server_onDestroy()
    IGenerator.sv_deregister(self)
end

function Generator:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IGenerator.sv_register(self)
        return
    end
end