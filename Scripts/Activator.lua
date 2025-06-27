dofile("$CONTENT_DATA/Scripts/IComponent.lua")
---@class Activator : IComponent
Activator = class(IComponent)

Activator.maxParentCount = -1
Activator.maxChildCount = 1
Activator.connectionInput = sm.interactable.connectionType.logic
Activator.connectionOutput = sm.interactable.connectionType.logic + sm.interactable.connectionType.power
Activator.poseWeightCount = 1

function Activator:server_onCreate()
    IComponent.sv_init(self)
    self.state = 1
end

function Activator:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IComponent.sv_register(self)
        return
    end
    local children = self.interactable:getChildren()
    local sumE = self.data.consumptionE
    for k, v in pairs(children) do
        if v.type == "survivalSequence" then
            sumE = sumE + 100
        end
    end
    self.interactable.publicData.consumptionE = sumE

    self.interactable.active = true
    if self.interactable.publicData.E < self.interactable.publicData.consumptionE * 0.5 then
        self.interactable.power = 0
    end
end

function Activator:server_onDestroy()
    IComponent.sv_deregister(self)
end

function Activator:sv_nextState()
    self.state = self.state + 1
    if self.state > 2 then
        self.state = 0
    end
    self.interactable.power = self.state - 1
end

function Activator:sv_prevState()
    self.state = self.state - 1
    if self.state < 0 then
        self.state = 2
    end
    self.interactable.power = self.state - 1
end

function Activator:sv_isActivator() end

function Activator:client_onInteract(character, state)
    if state then
        self.network:sendToServer("sv_nextState")
    end
end

function Activator:client_onTinker(character, state)
    if state then
        self.network:sendToServer("sv_prevState")
    end
end

function Activator:client_onUpdate(dt)
    if self.interactable.power ~= self.prevPower then
        self.interactable:setPoseWeight(0, (self.interactable.power + 1) * 0.5)
        print(self.interactable.power)
        self.prevPower = self.interactable.power
    end
end