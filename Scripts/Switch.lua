dofile("$CONTENT_DATA/Scripts/Receiver.lua")
dofile("$CONTENT_DATA/Scripts/Sender.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")
---@class Switch : Receiver, Sender
Switch = class(_wm_class(Receiver, Sender))

Switch.colorNormal = sm.color.new("#F93380")
Switch.colorHighlight = sm.color.new("#FF4B98")
Switch.maxParentCount = 2
Switch.maxChildCount = 999999
Switch.connectionInput = sm.interactable.connectionType.logic + sm.interactable.connectionType.seated
Switch.connectionOutput = sm.interactable.connectionType.logic
Switch.poseWeightCount = 1

function Switch:server_onCreate()
    Receiver.sv_init(self, false)
end

function Switch:server_onFixedUpdate()
    Receiver.sv_calculateMaxE(self)
    if not Receiver.sv_checkSender(self) then
        Receiver.sv_receiveE(self, 0)
    end
    if self.needSync then
        self.needSync = false
    end
    if self.sv.isPowered and self.interactable.active then
        Sender.sv_send(self, self.sv.E)
    else
        Sender.sv_send(self, 0)
    end
end

function Switch:sv_switch()
    self.interactable.active = not self.interactable.active
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