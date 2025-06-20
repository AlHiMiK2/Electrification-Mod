---@class Sender : ShapeClass
Sender = class()

function Sender:sv_send(E)
    local childs = self.interactable:getChildren(sm.interactable.connectionType.logic)
    if #childs == 0 then return 0 end
    local sortedChilds = {}
    local sumE = 0
    for i, v in pairs(childs) do
        if v.type == "scripted" and sm.event.sendToInteractable(v, "sv_isReceiver") then
            if v.active then
                sumE = sumE + v.publicData.maxE + v.publicData.lossE
                table.insert(sortedChilds, v)
            else
                sm.event.sendToInteractable(v, "sv_receiveE", 0)
            end
        end
    end
    if #sortedChilds == 0 then return 0 end
    if sumE > E then
        local ratio = E / sumE
        for i, v in pairs(sortedChilds) do
            sm.event.sendToInteractable(v, "sv_receiveE", v.publicData.maxE * ratio)
        end
        return E
    else
        for i, v in pairs(sortedChilds) do
            sm.event.sendToInteractable(v, "sv_receiveE", v.publicData.maxE)
        end
        return sumE
    end
end

function Sender:sv_isSender()
end