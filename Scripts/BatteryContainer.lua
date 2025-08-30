dofile( "$SURVIVAL_DATA/Scripts/game/survival_items.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/survival_projectiles.lua" )
dofile("$CONTENT_DATA/Scripts/IGenerator.lua")

---@class BatteryContainer : IGenerator
BatteryContainer = class( nil )
BatteryContainer.maxChildCount = 255
BatteryContainer.connectionOutput = sm.interactable.connectionType.electricity + sm.interactable.connectionType.logic
BatteryContainer.colorNormal = sm.color.new( 0x84ff32ff )
BatteryContainer.colorHighlight = sm.color.new( 0xa7ff4fff )

local ContainerSize = 5

function BatteryContainer.server_onCreate( self )
    IGenerator.sv_init(self)
	local container = self.shape.interactable:getContainer( 0 )
	if not container then
		container = self.shape:getInteractable():addContainer( 0, ContainerSize, self.data.stackSize )
	end
	if self.data.filterUid then
		local filters = { sm.uuid.new( self.data.filterUid ) }
		container:setFilters( filters )
	end
end

function BatteryContainer:server_onFixedUpdate(timeStep)
    if self.eCalculator == nil then
        IGenerator.sv_register(self)
        return
    end

    local container = self.shape.interactable:getContainer( 0 )
    self.interactable.active = not container:isEmpty()
    if container:isEmpty() then
        self.interactable.publicData.outE = 0
    else
        self.interactable.publicData.outE = self.data.outE
    end
end

function BatteryContainer:server_onDestroy()
    IGenerator.sv_deregister(self)
end

function BatteryContainer.client_canCarry( self )
	local container = self.shape.interactable:getContainer( 0 )
	if container and sm.exists( container ) then
		return not container:isEmpty()
	end
	return false
end

function BatteryContainer.client_onInteract( self, character, state )
	if state == true then
		local container = self.shape.interactable:getContainer( 0 )
		if container then
			local gui = nil

			local shapeUuid = self.shape:getShapeUuid()

			if shapeUuid == obj_container_ammo then
				gui = sm.gui.createAmmunitionContainerGui( true )

			elseif shapeUuid == obj_container_battery then
				gui = sm.gui.createBatteryContainerGui( true )

			elseif shapeUuid == obj_container_chemical then
				gui = sm.gui.createChemicalContainerGui( true )

			elseif shapeUuid == obj_container_fertilizer then
				gui = sm.gui.createFertilizerContainerGui( true )

			elseif shapeUuid == obj_container_gas then
				gui = sm.gui.createGasContainerGui( true )

			elseif shapeUuid == obj_container_seed then
				gui = sm.gui.createSeedContainerGui( true )

			elseif shapeUuid == obj_container_water then
				gui = sm.gui.createWaterContainerGui( true )
			end

			if gui == nil then
				gui = sm.gui.createContainerGui( true )
				gui:setText( "UpperName", "#{CONTAINER_TITLE_GENERIC}" )
			end

			gui:setContainer( "UpperGrid", container )
			gui:setText( "LowerName", "#{INVENTORY_TITLE}" )
			gui:setContainer( "LowerGrid", sm.localPlayer.getInventory() )
			gui:open()
		end
	end
end

function BatteryContainer.client_onUpdate( self, dt )

	local container = self.shape.interactable:getContainer( 0 )
	if container and self.data.stackSize then
		local quantities = sm.container.quantity( container )

		local quantity = 0
		for _,q in ipairs( quantities ) do
			quantity = quantity + q
		end

		local frame = ContainerSize - math.ceil( quantity / self.data.stackSize )
		self.interactable:setUvFrameIndex( frame )
	end
end