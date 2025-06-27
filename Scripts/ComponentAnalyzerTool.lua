dofile "$GAME_DATA/Scripts/game/AnimationUtil.lua"
dofile "$SURVIVAL_DATA/Scripts/util.lua"

---@class ComponentAnalyzerTool : ToolClass
---@field isLocal boolean
---@field animationsLoaded boolean
---@field equipped boolean
---@field swingCooldowns table
---@field fpAnimations table
---@field tpAnimations table
ComponentAnalyzerTool = class()

local renderables =   {"$CONTENT_DATA/Tools/Renderables/char_connecttool.rend" }
local renderablesTp = {"$GAME_DATA/Character/Char_Tools/Char_connecttool/char_connecttool_tp_animlist.rend"}
local renderablesFp = {"$GAME_DATA/Character/Char_Tools/Char_connecttool/char_connecttool_fp_animlist.rend"}

local currentRenderablesTp = {}
local currentRenderablesFp = {}

sm.tool.preloadRenderables( renderables )
sm.tool.preloadRenderables( renderablesTp )
sm.tool.preloadRenderables( renderablesFp )


function ComponentAnalyzerTool:client_onCreate()
	self:cl_init()
end

function ComponentAnalyzerTool:client_onRefresh()
	self:cl_init()
end

function ComponentAnalyzerTool:cl_init()
	self:cl_loadAnimations()
end

function ComponentAnalyzerTool:cl_loadAnimations()

	self.tpAnimations = createTpAnimations(
			self.tool,
			{
				idle = { "connecttool_idle_flip", { looping = true } },
			}
		)
		local movementAnimations = {

			idle = "connecttool_idle_flip",
		}

		for name, animation in pairs( movementAnimations ) do
			self.tool:setMovementAnimation( name, animation )
		end

		if self.tool:isLocal() then
			self.fpAnimations = createFpAnimations(
				self.tool,
				{
					idle = { "connecttool_idle", { looping = true } },
					sprintInto = { "connecttool_sprint_into", { nextAnimation = "sprintIdle",  blendNext = 0.2 } },
					sprintIdle = { "connecttool_sprint_idle", { looping = true } },
					sprintExit = { "connecttool_sprint_exit", { nextAnimation = "idle",  blendNext = 0 } },
					equip = { "connecttool_pickup", { nextAnimation = "idle" } },
					unequip = { "connecttool_putdown" }
				}
			)
		end
		setTpAnimation( self.tpAnimations, "idle", 5.0 )
		self.blendTime = 0.2
end

function ComponentAnalyzerTool:client_onUpdate(dt)
	local isSprinting =  self.tool:isSprinting()

	if self.tool:isLocal() then
		if self.equipped then
			if isSprinting and self.fpAnimations.currentAnimation ~= "sprintInto" and self.fpAnimations.currentAnimation ~= "sprintIdle" then
				swapFpAnimation( self.fpAnimations, "sprintExit", "sprintInto", 0.0 )
			elseif not self.tool:isSprinting() and ( self.fpAnimations.currentAnimation == "sprintIdle" or self.fpAnimations.currentAnimation == "sprintInto" ) then
				swapFpAnimation( self.fpAnimations, "sprintInto", "sprintExit", 0.0 )
			end
		end
		updateFpAnimations( self.fpAnimations, self.equipped, dt )
	end

	if not self.equipped then
		if self.wantEquipped then
			self.wantEquipped = false
			self.equipped = true
		end
		return
	end

	local crouchWeight = self.tool:isCrouching() and 1.0 or 0.0
	local normalWeight = 1.0 - crouchWeight
	local totalWeight = 0.0

	for name, animation in pairs( self.tpAnimations.animations ) do
		animation.time = animation.time + dt

		if name == self.tpAnimations.currentAnimation then
			animation.weight = math.min( animation.weight + ( self.tpAnimations.blendSpeed * dt ), 1.0 )

			if animation.looping == true then
				if animation.time >= animation.info.duration then
					animation.time = animation.time - animation.info.duration
				end
			end
			if animation.time >= animation.info.duration - self.blendTime and not animation.looping then
				if ( name == "use" ) then
					setTpAnimation( self.tpAnimations, "idle", 10.0 )
				elseif name == "pickup" then
					setTpAnimation( self.tpAnimations, "idle", 0.001 )
				elseif animation.nextAnimation ~= "" then
					setTpAnimation( self.tpAnimations, animation.nextAnimation, 0.001 )
				end

			end
		else
			animation.weight = math.max( animation.weight - ( self.tpAnimations.blendSpeed * dt ), 0.0 )
		end

		totalWeight = totalWeight + animation.weight
	end

	totalWeight = totalWeight == 0 and 1.0 or totalWeight
	for name, animation in pairs( self.tpAnimations.animations ) do

		local weight = animation.weight / totalWeight
		if name == "idle" then
			self.tool:updateMovementAnimation( animation.time, weight )
		elseif animation.crouch then
			self.tool:updateAnimation( animation.info.name, animation.time, weight * normalWeight )
			self.tool:updateAnimation( animation.crouch.name, animation.time, weight * crouchWeight )
		else
			self.tool:updateAnimation( animation.info.name, animation.time, weight )
		end
	end


	if self.tool:isLocal() then
		local hit, result = sm.localPlayer.getRaycast( 2000, sm.camera.getPosition(), sm.camera.getDirection() )
	end
end

function ComponentAnalyzerTool:client_onEquip()
	self.wantEquipped = true

	currentRenderablesTp = {}
	currentRenderablesFp = {}

	for k,v in pairs( renderablesTp ) do currentRenderablesTp[#currentRenderablesTp+1] = v end
	for k,v in pairs( renderablesFp ) do currentRenderablesFp[#currentRenderablesFp+1] = v end
	for k,v in pairs( renderables ) do currentRenderablesTp[#currentRenderablesTp+1] = v end
	for k,v in pairs( renderables ) do currentRenderablesFp[#currentRenderablesFp+1] = v end

	self.tool:setTpRenderables( currentRenderablesTp )
	if self.tool:isLocal() then
		self.tool:setFpRenderables( currentRenderablesFp )
	end

	self:cl_loadAnimations()

	setTpAnimation( self.tpAnimations, "pickup", 0.0001 )
	if self.tool:isLocal() then
		swapFpAnimation( self.fpAnimations, "unequip", "equip", 0.2 )
	end
end

function ComponentAnalyzerTool:client_onUnequip()
	self.wantEquipped = false
	self.equipped = false

	setTpAnimation( self.tpAnimations, "putdown" )
	if self.tool:isLocal() and self.fpAnimations.currentAnimation ~= "unequip" then
		swapFpAnimation( self.fpAnimations, "equip", "unequip", 0.2 )
	end
end

function ComponentAnalyzerTool:sv_getDataFromInteractable(data)
	if data.Interactable.type == "scripted" then
		self.network:sendToClient(data.Player, "cl_setInteractableData", {publicData = data.Interactable.publicData, interactable = data.Interactable})
	else
		self.network:sendToClient(data.Player, "cl_setInteractableData", {publicData = nil, interactable = data.Interactable})
	end
end

function ComponentAnalyzerTool:client_onEquippedUpdate( primaryState, secondaryState )
	if self.tool:isLocal() then
		local valid, result = sm.localPlayer.getRaycast( 7.5 )
		if valid then
			local shape = result:getShape()
			if shape and shape.interactable then
				self.network:sendToServer("sv_getDataFromInteractable", {Interactable = shape.interactable, Player = sm.localPlayer.getPlayer()})
				self:cl_showInteractableInfo()
				return true, true
			end
		end
		self.publicData = nil
	end
	return true, true
end

function ComponentAnalyzerTool:cl_setInteractableData(data)
	self.publicData = data.publicData
	self.target = data.interactable
end

function ComponentAnalyzerTool:cl_showInteractableInfo()
	if not sm.exists(self.target) then return end
	local text = ""
	if self.target.type == "survivalSequence" then
		text = "consumptionE = 100"
	elseif self.target.type == "scripted" and self.publicData then
		for k, v in pairs(self.publicData) do
			if type(v) == "number" then
				text = text.. tostring(k).. " = ".. tostring(math.floor(v * 10 + 0.5) / 10).. "	"
			end
		end
	end

	sm.gui.setInteractionText(text)
end