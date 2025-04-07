--[[
	calculateVelocityForHeight - A simple utility function to calculate the vertical velocity required
	to reach a specific height, based on the current Workspace.Gravity.
--]]

local Workspace = game:GetService("Workspace")

local function calculateVelocityForHeight(height: number): number
	-- Equation to find the Y velocity required to reach a specific height derived from basic kinematic equations
	return math.sqrt(2 * Workspace.Gravity * height)
end

return calculateVelocityForHeight
