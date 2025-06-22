---@class ILogic : ShapeClass
ILogic = class()

function ILogic:sv_init()
    self.interactable.publicData.logic = false
end

function ILogic:sv_isLogic() end