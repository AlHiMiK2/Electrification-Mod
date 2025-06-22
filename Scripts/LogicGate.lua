dofile("$CONTENT_DATA/Scripts/IComponent.lua")
dofile( "$SURVIVAL_DATA/Scripts/game/survival_projectiles.lua" )
---@class LogicGate : IComponent
LogicGate = class(IComponent)
LogicGate.maxChildCount = -1
LogicGate.maxParentCount = -1
LogicGate.connectionInput = sm.interactable.connectionType.logic
LogicGate.connectionOutput = sm.interactable.connectionType.logic
LogicGate.colorNormal = sm.color.new("#2770bf")
LogicGate.colorHighlight = sm.color.new("#4188d6")

function LogicGate:server_onCreate()
    IComponent.sv_init(self)
    self.interactable.active = true
    self.mode = 0
    if self.storage:load() ~= nil then
        self.mode = self.storage:load().mode
    else
        self.mode = 0
    end
    self.network:setClientData({mode = self.mode})
end

function LogicGate:server_onFixedUpdate()
    if self.eCalculator == nil then
        IComponent.sv_register(self)
        return
    end
    local parents = self.interactable:getParents(sm.interactable.connectionType.logic)
    if #parents == 0 then
        self.interactable.active = false
        return
    end
    local activeCount = 0
    for k, v in pairs(parents) do
        if v.active then
            activeCount = activeCount + 1
        end
    end
    if self.mode == 0 then
        self.interactable.active = activeCount == #parents
    elseif self.mode == 1 then
        self.interactable.active = activeCount > 0
    elseif self.mode == 2 then
        self.interactable.active = activeCount % 2 == 1
    elseif self.mode == 3 then
        self.interactable.active = activeCount ~= #parents
    elseif self.mode == 4 then
        self.interactable.active = activeCount <= 0
    else
        self.interactable.active = activeCount % 2 == 0
    end
    self.network:setClientData({mode = self.mode})
end

function LogicGate:sv_saveMode(mode)
    self.mode = mode
    self.network:setClientData({mode = self.mode})
    self.storage:save({mode = self.mode})
end

function LogicGate:server_onDestroy()
    IComponent.sv_deregister(self)
end

function LogicGate:sv_isLogic() end

function LogicGate:client_onCreate()
    self.cl_mode = 0
end

function LogicGate:client_onDestroy()
    if self.gui then
        self.gui:destroy()
    end
end

function LogicGate:gui_init()
    if self.gui == nil then
        self.gui = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Interactable_LogicGate.layout")
        self.guimodes = {
            { name = "And", description = "Active if all of the linked triggers are active", lamps = {false, false, true}},
            { name = "Or", description = "Active if any of the linked triggers are active", lamps = {false, true, true} },
            { name = "Xor", description = "Active if an odd number of linked triggers are active", lamps = {false, true, false} },
            { name = "Nand", description = "Active if any of the linked triggers are inactive", lamps = {true, true, false} },
            { name = "Nor", description = "Active if all of the linked triggers are inactive", lamps = {true, false, false} },
            { name = "Xnor", description = "Active if an even number of linked triggers are active", lamps = {true, false, true} }
        }
        local btnNames = {"And", "Or", "Xor", "Nand", "Nor", "Xnor"}
        for _, btnName in pairs(btnNames) do
            self.gui:setButtonCallback(btnName, "gui_buttonCallback")
        end
    end
end

function LogicGate:gui_buttonCallback(btnName)
    local function stateToString(state)
        if state then
            return "on"
        else
            return "off"
        end
    end

    for i = 1, #self.guimodes do
        local name = self.guimodes[i].name
        self.gui:setButtonState(name, name == btnName)
        if name == btnName then
            local str = "LogicGateDescriptionLamps"
            self.cl_mode = i - 1
            self.gui:setText("DescriptionText", self.guimodes[i].description)
            self.gui:setItemIcon("Lamp00", str, str, stateToString(self.guimodes[i].lamps[1]))
            self.gui:setItemIcon("Lamp01", str, str, stateToString(self.guimodes[i].lamps[2]))
            self.gui:setItemIcon("Lamp11", str, str, stateToString(self.guimodes[i].lamps[3]))
        end
    end
    self.network:sendToServer("sv_saveMode", self.cl_mode)
end

function LogicGate:client_onInteract(character, state )
    if state then
        self:gui_init()
        local btnNames = {"And", "Or", "Xor", "Nand", "Nor", "Xnor"}
        self:gui_buttonCallback(btnNames[self.cl_mode + 1])
        self.gui:open()
    end
end

function LogicGate:client_onFixedUpdate(deltaTime)
    if self.interactable.active then
        self.interactable:setUvFrameIndex(6 + self.cl_mode)
    else
        self.interactable:setUvFrameIndex(0 + self.cl_mode)
    end
end

function LogicGate:client_onClientDataUpdate(data)
    self.cl_mode = data.mode
end