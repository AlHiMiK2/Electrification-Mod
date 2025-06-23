dofile("$CONTENT_DATA/Scripts/IComponent.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")
---@class Switch : IComponent
Switch = class(IComponent)

Switch.colorNormal = sm.color.new("#F93380")
Switch.colorHighlight = sm.color.new("#FF4B98")
Switch.maxParentCount = 2
Switch.maxChildCount = 999999
Switch.connectionInput = sm.interactable.connectionType.logic + sm.interactable.connectionType.seated
Switch.connectionOutput = sm.interactable.connectionType.logic
Switch.poseWeightCount = 1

function Switch:server_onCreate()
    IComponent.sv_init(self)
end

function Switch:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IComponent.sv_register(self)
        return
    end
end

function Switch:server_onDestroy()
    IComponent.sv_deregister(self)
end

function Switch:sv_switch()
    self.interactable.active = not self.interactable.active
end

function Switch:client_onAction(action, state)
    if state then
        self.network:sendToServer("sv_switch")
        local childrens = self.interactable:getChildren(sm.interactable.connectionType.logic)
        if #childrens == 0 then
            sm.gui.displayAlertText("No connections")
        end
    end
end

function Switch:client_onInteract(character, state)
    if state then
        self.network:sendToServer("sv_switch")
        local childrens = self.interactable:getChildren(sm.interactable.connectionType.logic)
        if #childrens == 0 then
            sm.gui.displayAlertText("No connections")
        end
    end
end

function Switch:client_onUpdate()
    if self.prevState == self.interactable.active then return end
    if self.interactable.active == true then
        self.interactable:setPoseWeight(0, 1)
        if not sm.exists(self.effectOn) then
            self.effectOn = sm.effect.createEffect("Switch - On", self.interactable)
        end
        self.effectOn:start()
    else
        self.interactable:setPoseWeight(0, 0)
        if not sm.exists(self.effectOff) then
            self.effectOff = sm.effect.createEffect("Switch - Off", self.interactable)
        end
        self.effectOff:start()
    end
    self.prevState = self.interactable.active
end