--[[
	setVerticalVelocity - A simple utility function to set only the Y component of a part's velocity, without modifying X and Z
--]]

local function setVerticalVelocity(part: BasePart, velocity: number)
    
	part.AssemblyLinearVelocity = (part.CFrame.UpVector.Unit * velocity)
end

return setVerticalVelocity
