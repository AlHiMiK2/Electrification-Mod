---@class E2LogicConverter : Receiver, LogicSender
E2LogicConverter = class(_wm_class(Receiver, LogicSender))

E2LogicConverter.maxChildCount = -1
E2LogicConverter.maxParentCount = 1
E2LogicConverter.connectionInput = sm.interactable.connectionType.logic
E2LogicConverter.connectionOutput = sm.interactable.connectionType.logic
E2LogicConverter.colorNormal = sm.color.new("#2770bf")
E2LogicConverter.colorHighlight = sm.color.new("#4188d6")

function E2LogicConverter:server_onCreate()
    Receiver.sv_init(self, false)
end

function E2LogicConverter:server_onFixedUpdate()
    if not Receiver.sv_checkSender(self) then
        Receiver.sv_receiveE(self, 0)
    end
    if self.sv.isPowered then
        LogicSender.sv_send(self, self.sv.E, true)
    else
        LogicSender.sv_send(self, 0, false)
    end
end