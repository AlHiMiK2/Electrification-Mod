---@class LogicSender : ShapeClass
LogicSender = class()

function LogicSender:sv_send(E, logic)
    local childs = self.interactable:getChildren(sm.interactable.connectionType.logic)
    if #childs == 0 then return 0 end
    local sortedChilds = {}
    local sumE = 0
    for i, v in pairs(childs) do
        if v.type == "scripted" and sm.event.sendToInteractable(v, "sv_isLogicReceiver") then
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
            sm.event.sendToInteractable(v, "sv_receiveE", {E = v.publicData.maxE * ratio, logic = logic})
        end
        return E
    else
        for i, v in pairs(sortedChilds) do
            sm.event.sendToInteractable(v, "sv_receiveE", {E = v.publicData.maxE, logic = logic})
        end
        return sumE
    end
end

function LogicSender:sv_isLogicSender()
end