dofile( "$SURVIVAL_DATA/Scripts/game/survival_projectiles.lua" )
---@class ECalculator : ToolClass
ECalculator = class()
--interactables
Circuit = {
    generators = {},
    components = {}
}

function ECalculator:server_onCreate()
    local players = sm.player.getAllPlayers()
    for k, v in pairs(players) do
        if v:getId() == 1 then
            v.publicData = {tool = self.tool}
        end
    end
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
                    self:sv_destroyComponent(obj)
                    goto continue
                end
            end
            table.insert(visited, obj.id)

            if obj.id ~= v.id then
                if obj.active then
                    table.insert(inCircuit, obj)
                    sumE = sumE + obj.publicData.consumptionE
                else
                    goto continue
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
        if v.publicData.isSafe then
            v.publicData.outE = math.min(v.publicData.outE, sumE)
            sm.event.sendToInteractable(v, "sv_setOutE", sumE)
        end

        for k2, v2 in pairs(inCircuit) do
            v2.publicData.E = v2.publicData.E + v2.publicData.consumptionE * v.publicData.outE / sumE
            if v2.publicData.E > v2.publicData.consumptionE * 1.5 then
                self:sv_destroyComponent(v2)
            end
        end
    end
end

function ECalculator:sv_destroyComponent(component)
    local params = { lootUuid = component.shape.uuid, lootQuantity = 1, epic = false }
    sm.projectile.shapeCustomProjectileAttack( params, projectile_loot, 0, sm.vec3.new( 0, 0, 0 ), sm.vec3.new(1, 0, 0), component.shape, 0 )
    component.shape:destroyShape()
end