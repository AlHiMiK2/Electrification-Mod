dofile("$CONTENT_DATA/Scripts/ECalculator.lua")
dofile("$CONTENT_DATA/Scripts/IGenerator.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")
---@class RotorGenerator : IGenerator
RotorGenerator = class(IGenerator)

RotorGenerator.maxParentCount = 0
RotorGenerator.maxChildCount = -1
RotorGenerator.connectionInput = sm.interactable.connectionType.none
RotorGenerator.connectionOutput = sm.interactable.connectionType.logic

function RotorGenerator:server_onCreate()
    IGenerator.sv_init(self)
    self.prevRight = self.shape.right
end

function RotorGenerator:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IGenerator.sv_register(self)
        return
    end

    self.interactable.publicData.outE = math.abs(Vector3SignedAngle(self.prevRight, self.shape.right, self.shape.up)) * self.data.outEMultiply
    self.prevRight = self.shape.right
end

function RotorGenerator:server_onDestroy()
    IGenerator.sv_deregister(self)
end