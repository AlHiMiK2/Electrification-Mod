dofile("$CONTENT_DATA/Scripts/IComponent.lua")
dofile("$CONTENT_DATA/Scripts/ILogic.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")
---@class Logic2EConverter : IComponent, ILogic
Logic2EConverter = class(_wm_class(IComponent, ILogic))

Logic2EConverter.maxChildCount = -1
Logic2EConverter.maxParentCount = 1
Logic2EConverter.connectionInput = sm.interactable.connectionType.logic
Logic2EConverter.connectionOutput = sm.interactable.connectionType.logic
Logic2EConverter.colorNormal = sm.color.new("#2770bf")
Logic2EConverter.colorHighlight = sm.color.new("#4188d6")

function Logic2EConverter:server_onCreate()
    IComponent.sv_init(self)
    ILogic.sv_init(self)
    self.interactable.active = true
end

function Logic2EConverter:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IComponent.sv_register(self)
        return
    end
    local parent = self.interactable:getSingleParent()

    if parent then
        if sm.event.sendToInteractable(parent, "sv_isLogic") then
            self.interactable.active = parent.publicData.logic
        else
            local params = { lootUuid = self.shape.uuid, lootQuantity = 1, epic = false }
            sm.projectile.shapeCustomProjectileAttack( params, projectile_loot, 0, sm.vec3.new( 0, 0, 0 ), sm.vec3.new(1, 0, 0), self.shape, 0 )
            self.shape:destroyShape(0)
        end
    end
end

function Logic2EConverter:server_onDestroy()
    IComponent.sv_deregister(self)
end