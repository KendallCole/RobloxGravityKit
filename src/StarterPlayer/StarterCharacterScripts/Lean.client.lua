--[[
	CharacterLeanScript - This script makes characters slightly lean in the direction they are moving.

	Each Step the character's Root joint Transform is updated based on the character's velocity.
--]]

local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Since this script has RunContext of Client, it will run anywhere regardless of its parent.
-- We only want it to run when it's parented to a character so we'll return immediately if it's in StarterCharacterScripts.
if script.Parent == StarterPlayer.StarterCharacterScripts then
	return
end

local character = script.Parent
-- Characters are not replicated atomically so we need to wait for children
local humanoid: Humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")
local rootJoint = character:WaitForChild("LowerTorso"):WaitForChild("Root")

local ROLL_ANGLE = math.rad(35)
local PITCH_ANGLE = math.rad(15)
local LEAN_SPEED = 10

local leanCFrame = CFrame.new()

local function onStepped(_: number, deltaTime: number)
	local moveVelocity = humanoid:GetMoveVelocity() 
	local relativeVelocity = root.CFrame:VectorToObjectSpace(moveVelocity)

	-- Calculate pitch and roll based on the character's relative velocity
	local pitch = 0
	local roll = 0
	if humanoid.WalkSpeed ~= 0 then
		pitch = math.clamp(relativeVelocity.Z / humanoid.WalkSpeed, -1, 1) * PITCH_ANGLE
		roll = -math.clamp(relativeVelocity.X / humanoid.WalkSpeed, -1, 1) * ROLL_ANGLE
	end

	leanCFrame = leanCFrame:Lerp(CFrame.Angles(pitch, 0, roll), math.min(deltaTime * LEAN_SPEED, 1))
	-- Apply the leaning to the rootJoint's Transform
	rootJoint.Transform = leanCFrame * rootJoint.Transform
end

--RunService.Stepped:Connect(onStepped)
