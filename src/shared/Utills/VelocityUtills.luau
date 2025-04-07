local VelocityUtills = {}


function VelocityUtills:setVerticalVelocity(part: BasePart, velocity: number)
	part.AssemblyLinearVelocity = (part.CFrame.UpVector.Unit * velocity)
end
function VelocityUtills:setHorizontalVelocity(part: BasePart, velocity: number)
	part.AssemblyLinearVelocity = (part.CFrame.LookVector.Unit * velocity)
end

function VelocityUtills:addHorizontalVelocity(part: BasePart, velocity: number)
	part.AssemblyLinearVelocity += (part.CFrame.LookVector.Unit * velocity)
end


return VelocityUtills