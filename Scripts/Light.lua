dofile("$CONTENT_DATA/Scripts/IComponent.lua")

---@class Light : IComponent
Light = class(IComponent)
Light.colorNormal = sm.color.new("#FEEA6D")
Light.colorHighlight = sm.color.new("#FFF19C")
Light.maxParentCount = 1
Light.maxChildCount = 0
Light.connectionInput = sm.interactable.connectionType.logic
Light.connectionOutput = sm.interactable.connectionType.logic
Light.poseWeightCount = 1
Light.steps = 10

function Light:server_onCreate()
    IComponent.sv_init(self)
    self.interactable.active = true
    local saved = self.storage:load() or {}
    self.sv_intensity = saved.intensity or 4
    self:sv_updateStorage()
end

function Light:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IComponent.sv_register(self)
        return
    end
    self.network:setClientData(self.interactable.publicData, 2)
end

function Light:server_onDestroy()
    IComponent.sv_deregister(self)
end

function Light:sv_updateStorage()
    local saved = {
        intensity = self.sv_intensity,
    }
    self.storage:save(saved)
    self.network:setClientData(saved, 1)
end

function Light:sv_lightStrengthChanged(value)
    self.sv_intensity = value
    self:sv_updateStorage()
end

function Light:client_onCreate()
    self.intensity = 4
    self.cl = {E = 0, consumptionE = self.data.consumptionE}
end

function Light:client_onUpdate()
    self:cl_updateLightEffect()

    if sm.exists(self.gui) and self.gui:isActive() then
        self:cl_updateUI()
    end
end

function Light:client_onFixedUpdate()
    if self.lightIntensityChanged then
        self.lightIntensityChanged = self.lightIntensityChanged - 1
        if self.lightIntensityChanged <= 0 then
            self.network:sendToServer("sv_lightStrengthChanged", self.intensity)
            self.lightIntensityChanged = nil
        end
    end
end

function Light:client_onClientDataUpdate(data, channel)
    if channel == 1 then
        self.intensity = data.intensity
    else
        for k, v in pairs(data) do
            self.cl[k] = v
        end
    end
    self:cl_updateLightEffect()
end

function Light:client_onInteract(char, state)
    if not state then return end

    if not self.gui then
        local gui

        gui = sm.gui.createGuiFromLayout("$CONTENT_DATA/Gui/Layouts/Light.layout")
        gui:createHorizontalSlider("Slider", Light.steps, 4, "cl_lightIntensityChanged", true)

        self.gui = gui
        self:cl_updateUI()
    end

    self.gui:open()
end

function Light:cl_updateLightEffect()
    if not sm.exists(self.light) then
        self.light = sm.effect.createEffect(self.data.effect, self.interactable)
    end
    local parent = self.interactable:getSingleParent()
    if parent and parent.active then
        local multiply = self.cl.E / self.cl.consumptionE
        self.light:setParameter("color", self.shape.color)
        self.light:setParameter("intensity", self.data.maxIntensity / Light.steps * self.intensity * multiply)
        self.interactable:setPoseWeight(0, multiply)
        if not self.light:isPlaying() then
            self.light:start()
        end
    else
        if self.light:isPlaying() then
            self.interactable:setPoseWeight(0, 0)
            self.light:stop()
        end
    end
end

function Light:cl_updateUI()
    self.gui:setSliderPosition("Slider", self.intensity - 1)
    self.gui:setItemIcon("Value", "IconsLampSpritesheet", "IconsLampSpritesheet", tostring(math.min(self.intensity - 1, 9)))
end

function Light:cl_lightIntensityChanged(value)
    self.lightIntensityChanged = 10
    self.intensity = value + 1
    self:cl_updateUI()
    self:cl_updateLightEffect()
end