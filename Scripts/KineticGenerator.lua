dofile("$CONTENT_DATA/Scripts/IGenerator.lua")
dofile("$CONTENT_DATA/Scripts/Utils/utils.lua")
---@class KineticGenerator : IGenerator
KineticGenerator = class(IGenerator)

KineticGenerator.maxParentCount = 0
KineticGenerator.maxChildCount = -1
KineticGenerator.connectionInput = sm.interactable.connectionType.logic
KineticGenerator.connectionOutput = sm.interactable.connectionType.null
KineticGenerator.CollisionDamage = 1000
KineticGenerator.ExpolisonDamage = 25

function KineticGenerator:server_onCreate()
    IGenerator.sv_init(self)
    self.interactable.publicData = {outE = 0, storedE = 0}
end

function KineticGenerator:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IGenerator.sv_register(self)
        return
    end
    self.interactable.active = self.interactable.publicData.storedE > 0
end

function KineticGenerator:sv_storeE(E)
    self.interactable.publicData.storedE = self.interactable.publicData.storedE + E
end

function KineticGenerator:server_onProjectile(position, airTime, velocity, projectileName, shooter, damage, customData, normal, uuid)
    self:sv_storeE(damage)
end

function KineticGenerator:server_onMelee(position, attacker, damage, power, direction, normal)
    self:sv_storeE(damage)
end

function KineticGenerator:server_onExplosion(center, destructionLevel)
    local damageMultiply = (self.shape.worldPosition - center):length()
    self:sv_storeE(self.ExpolisonDamage / damageMultiply * destructionLevel)
end

function KineticGenerator:server_onCollision(other, position, selfPointVelocity, otherPointVelocity, normal)
    local damage
    if type(other) == "nil" then
        damage = (selfPointVelocity * self.shape.body.mass):length() / self.CollisionDamage
    else
        damage = (selfPointVelocity * self.shape.body.mass + otherPointVelocity * other.body.mass):length() / self.CollisionDamage
    end
    self:sv_storeE(damage)
end

function KineticGenerator:server_onDestroy()
    IGenerator.sv_deregister(self)
end

function KineticGenerator:sv_isAccumulator() end