---@class Sender : ShapeClass
Sender = class()

function Sender:sv_isSender()
end

function Sender:sv_resetSend()
    local childs = self.interactable:getChildren(sm.interactable.connectionType.logic)

    for i, v in pairs(childs) do
        if v.type == "scripted" and sm.event.sendToInteractable(v, "sv_isReceiver") then
            sm.event.sendToInteractable(v, "sv_resetReceive")
        end
    end
end