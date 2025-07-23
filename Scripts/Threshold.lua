dofile("$CONTENT_DATA/Scripts/IComponent.lua")
dofile("$CONTENT_DATA/Scripts/IGenerator.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")

---@class Threshold : IComponent, IGenerator
Threshold = class(_wm_class(IGenerator, IComponent))
Threshold.colorNormal = sm.color.new("#FEEA6D")
Threshold.colorHighlight = sm.color.new("#FFF19C")
Threshold.maxParentCount = -1
Threshold.maxChildCount = -1
Threshold.connectionInput = sm.interactable.connectionType.logic
Threshold.connectionOutput = sm.interactable.connectionType.logic
Threshold.poseWeightCount = 1
Threshold.steps = 10

function Threshold:server_onCreate()
    IComponent.sv_init(self)
    IGenerator.sv_init(self)
    self.interactable.publicData = {E = 0, consumptionE = 0, outE = 0}
    local saved = self.storage:load() or {}
    self.sv_intensity = saved.intensity or 4
    self:sv_updateStorage()
end

function Threshold:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IComponent.sv_register(self)
        IGenerator.sv_register(self)
        return
    end
    self.interactable.active = true
    self.network:setClientData(self.interactable.publicData, 2)
end

function Threshold:server_onDestroy()
    IComponent.sv_deregister(self)
    IGenerator.sv_deregister(self)
end

function Threshold:sv_updateStorage()
    local saved = {
        intensity = self.sv_intensity,
    }
    self.storage:save(saved)
    self.interactable.publicData.consumptionE = self.data.outE * self.sv_intensity * 0.1
    self.network:setClientData(saved, 1)
end

function Threshold:sv_outEChanged(value)
    self.sv_intensity = value
    self:sv_updateStorage()
end

function Threshold:sv_isThreshold() end

function Threshold:client_onCreate()
    self.intensity = 4
    self.cl = {E = 0, consumptionE = self.data.consumptionE}
end

function Threshold:client_onUpdate()
    if sm.exists(self.gui) and self.gui:isActive() then
        self:cl_updateUI()
    end
end

function Threshold:client_onFixedUpdate()
    if self.outEChanged then
        self.outEChanged = self.outEChanged - 1
        if self.outEChanged <= 0 then
            self.network:sendToServer("sv_outEChanged", self.intensity)
            self.outEChanged = nil
        end
    end
end

function Threshold:client_onClientDataUpdate(data, channel)
    if channel == 1 then
        self.intensity = data.intensity
    else
        for k, v in pairs(data) do
            self.cl[k] = v
        end
    end
end

function Threshold:client_onInteract(char, state)
    if not state then return end

    if not self.gui then
        local gui

        gui = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Threshold.layout")
        gui:createHorizontalSlider("Slider", Threshold.steps, 4, "cl_outEChanged", true)

        self.gui = gui
        self:cl_updateUI()
    end

    self.gui:open()
end

function Threshold:cl_updateUI()
    self.gui:setSliderPosition("Slider", self.intensity - 1)
end

function Threshold:cl_outEChanged(value)
    self.outEChanged = 10
    self.intensity = value + 1
    self:cl_updateUI()
end