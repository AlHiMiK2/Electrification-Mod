---@class Logic2EConverter : LogicReceiver, Sender
Logic2EConverter = class(_wm_class(LogicReceiver, Sender))

Logic2EConverter.maxChildCount = -1
Logic2EConverter.maxParentCount = 1
Logic2EConverter.connectionInput = sm.interactable.connectionType.logic
Logic2EConverter.connectionOutput = sm.interactable.connectionType.logic
Logic2EConverter.colorNormal = sm.color.new("#2770bf")
Logic2EConverter.colorHighlight = sm.color.new("#4188d6")

function Logic2EConverter:server_onCreate()
    LogicReceiver.sv_init(self, false)
end

function Logic2EConverter:server_onFixedUpdate()
    if not LogicReceiver.sv_checkSender(self) then
        LogicReceiver.sv_receiveE(self, 0)
    end
    if self.sv.isPowered then
        if self.sv.logic then
            Sender.sv_send(self, self.sv.E)
        else
            Sender.sv_send(self, 0)
        end
    else
        Sender.sv_send(self, 0)
    end
end