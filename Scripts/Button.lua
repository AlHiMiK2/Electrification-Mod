dofile("$CONTENT_DATA/Scripts/IComponent.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")
---@class Button : IComponent
Button = class(IComponent)

Button.colorNormal = sm.color.new("#F93380")
Button.colorHighlight = sm.color.new("#FF4B98")
Button.maxParentCount = 2
Button.maxChildCount = 999999
Button.connectionInput = sm.interactable.connectionType.logic + sm.interactable.connectionType.seated
Button.connectionOutput = sm.interactable.connectionType.logic
Button.poseWeightCount = 1

function Button:server_onCreate()
    IComponent.sv_init(self)
end

function Button:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IComponent.sv_register(self)
        return
    end
end

function Button:server_onDestroy()
    IComponent.sv_deregister(self)
end

function Button:sv_button(state)
    self.interactable.active = state
end

function Button:client_onInteract(character, state)
    if state then
        self.network:sendToServer("sv_button", true)
        local childrens = self.interactable:getChildren(sm.interactable.connectionType.logic)
        if #childrens == 0 then
            sm.gui.displayAlertText("No connections")
        end
    else
        self.network:sendToServer("sv_button", false)
    end
end

function Button:client_onUpdate()
    if self.prevState == self.interactable.active then return end
    if self.interactable.active == true then
        self.interactable:setPoseWeight(0, 1)
        if not sm.exists(self.effectOn) then
            self.effectOn = sm.effect.createEffect("Button - On", self.interactable)
        end
        self.effectOn:start()
    else
        self.interactable:setPoseWeight(0, 0)
        if not sm.exists(self.effectOff) then
            self.effectOff = sm.effect.createEffect("Button - Off", self.interactable)
        end
        self.effectOff:start()
    end
    self.prevState = self.interactable.active
end