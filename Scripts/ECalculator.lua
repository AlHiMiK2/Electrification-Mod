dofile( "$SURVIVAL_DATA/Scripts/game/survival_projectiles.lua" )
---@class ECalculator : ToolClass
ECalculator = class()
ECalculator.instance = nil

Circuit = {
    generators = {},
    components = {}
}

function ECalculator:server_onCreate()
    ECalculator.instance = self.tool
end

function ECalculator:sv_registerComponent(component)
    table.insert(Circuit.components, component)
end

function ECalculator:sv_deregisterComponent(component)
    for i = 1, #Circuit.components, 1 do
        if Circuit.components[i].id == component.id then
            table.remove(Circuit.components, i)
            return
        end
    end
end

function ECalculator:sv_registerGenerator(generator)
    table.insert(Circuit.generators, generator)
end

function ECalculator:sv_deregisterGenerator(generator)
    for i = 1, #Circuit.generators, 1 do
        if Circuit.generators[i].id == generator.id then
            table.remove(Circuit.generators, i)
            return
        end
    end
end

function ECalculator:server_onFixedUpdate(timeStep)
    self:sv_calculate()
end

function ECalculator:sv_calculate()
    for k, v in pairs(Circuit.components) do
        v.publicData.E = 0
    end

    for k, v in pairs(Circuit.generators) do
        local inCircuit = {}
        local stack = { {obj = v} }
        local visited = {}
        local sumE = 0

        while #stack > 0 do
            local current = table.remove(stack)
            local obj = current.obj

            for i, v2 in ipairs(visited) do
                if v2 == obj.id then
                    goto continue
                end
            end
            table.insert(visited, obj.id)

            if obj.type ~= "scripted" then
                goto continue
            end
            if obj.id ~= v.id then
                if sm.event.sendToInteractable(obj, "sv_isLogic") then
                    table.insert(inCircuit, obj)
                    if obj.active then
                        sumE = sumE + obj.publicData.consumptionE
                    end
                else
                    if obj.active then
                        table.insert(inCircuit, obj)
                        sumE = sumE + obj.publicData.consumptionE
                    else
                        goto continue
                    end
                end
                if sm.event.sendToInteractable(obj, "sv_isGenerator") then
                    goto continue
                end
            end

            local children = obj:getChildren(sm.interactable.connectionType.logic)
            if children then
                for i = #children, 1, -1 do
                    table.insert(stack, {
                        obj = children[i]
                    })
                end
            end
            ::continue::
        end
        if sm.event.sendToInteractable(v, "sv_isAccumulator") then
            local E = sumE
            local over = v.publicData.storedE - E
            if over < 0 then
                E = E + over
            end
            v.publicData.outE = E
            v.publicData.storedE = v.publicData.storedE - v.publicData.outE
        end
		--Romytrix Shit Edit Start
		if sm.event.sendToInteractable(v, "sv_isStab") then
            local E = sumE
            local over = v.publicData.storedE - E
            if over < 0 then
                E = E + over
            end
            v.publicData.outE = E
			v.publicData.capacityE = sumE
            v.publicData.storedE = v.publicData.storedE - v.publicData.outE
        end
		--Romytrix Shit Edit End
        for k2, v2 in pairs(inCircuit) do
            if sm.event.sendToInteractable(v2, "sv_isLogic") then
                if v2.active then
                    v2.publicData.E = v2.publicData.E + v2.publicData.consumptionE * v.publicData.outE / sumE
                end
            else
                v2.publicData.E = v2.publicData.E + v2.publicData.consumptionE * v.publicData.outE / sumE
            end
            if v2.publicData.E > v2.publicData.consumptionE * 2.1 then
                self:sv_destroyComponent(v2)
            end
        end
    end
end

function ECalculator:sv_destroyComponent(component)
    local params = { lootUuid = component.shape.uuid, lootQuantity = 1, epic = false }
    sm.projectile.shapeCustomProjectileAttack( params, projectile_loot, 0, sm.vec3.new( 0, 0, 0 ), sm.vec3.new(1, 0, 0), component.shape, 0 )
    component.shape:destroyShape(0)
end