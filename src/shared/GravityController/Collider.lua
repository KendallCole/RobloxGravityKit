local Maid = require(script.Parent.Utility.Maid)
wait(1)
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include

local params2 = RaycastParams.new()
params2.FilterType = Enum.RaycastFilterType.Exclude
params2.RespectCanCollide = true
-- CONSTANTS

local CUSTOM_PHYSICAL = PhysicalProperties.new (0.7, 0, 0, 1, 100)

-- Class

local ColliderClass = {}
ColliderClass.__index = ColliderClass
ColliderClass.ClassName = "Collider"

-- Public Constructors

function ColliderClass.new(controller)
	local self = setmetatable({}, ColliderClass)
	params.FilterDescendantsInstances = controller.Character:GetChildren()

	self.Model = Instance.new("Model")

	local sphere, vForce, floor, floor2, gryo = create(self, controller)

	self._maid = Maid.new()
	
	self.Controller = controller

	self.Sphere = sphere
	self.VForce = vForce
	self.FloorDetector = floor
	self.JumpDetector = floor2
	self.Gyro = gryo
	self.Grounded = true -- Cached version of isGrounded()
	self.OnWall = false -- Cached version of isTouchingWall()
	init(self)

	return self
end

-- Private Methods

local function getHipHeight(controller)
	if controller.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		return controller.Humanoid.HipHeight + 0.05
	end
	return 2
end

local function getAttachement(controller)
	if controller.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		return controller.HRP:WaitForChild("RootRigAttachment")
	end
	return controller.HRP:WaitForChild("RootAttachment")
end

function create(self, controller)
	local hipHeight = getHipHeight(controller)
	local attach = getAttachement(controller)

	local sphere = Instance.new("Part")
	sphere.Name = "Sphere"
	sphere.Massless = true
	sphere.Size = Vector3.new(2, 2, 2)
	sphere.Shape = Enum.PartType.Ball
	sphere.Transparency = 1
	sphere.CustomPhysicalProperties = CUSTOM_PHYSICAL

	local floor = Instance.new("Part")
	floor.Name = "FloorDectector"
	floor.CanCollide = false
	floor.Massless = true
	floor.Size = Vector3.new(2, 1, 1)
	floor.Transparency = 1

	local floor2 = Instance.new("Part")
	floor2.Name = "JumpDectector"
	floor2.CanCollide = false
	floor2.Massless = true
	floor2.Size = Vector3.new(2, 0.2, 1)
	floor2.Transparency = 1

	local weld = Instance.new("Weld")
	weld.C0 = CFrame.new(0, -hipHeight, 0.1)
	weld.Part0 = controller.HRP
	weld.Part1 = sphere
	weld.Parent = sphere

	local weld = Instance.new("Weld")
	weld.C0 = CFrame.new(0, -hipHeight - 1.5, 0)
	weld.Part0 = controller.HRP
	weld.Part1 = floor
	weld.Parent = floor

	local weld = Instance.new("Weld")
	weld.C0 = CFrame.new(0, -hipHeight - 1.1, 0)
	weld.Part0 = controller.HRP
	weld.Part1 = floor2
	weld.Parent = floor2

	local vForce = Instance.new("VectorForce")
	vForce.Force = Vector3.new(0, 0, 0)
	vForce.ApplyAtCenterOfMass = true
	vForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vForce.Attachment0 = attach
	vForce.Parent = controller.HRP

	local gyro = Instance.new("BodyGyro")
	gyro.P = 25000
	gyro.MaxTorque = Vector3.new(100000, 100000, 100000)
	gyro.CFrame = controller.HRP.CFrame
	gyro.Parent = controller.HRP


	
	
	floor.Touched:Connect(function() end)
	floor2.Touched:Connect(function() end)

	sphere.Parent = self.Model
	floor.Parent = self.Model
	floor2.Parent = self.Model

	return sphere, vForce, floor, floor2, gyro
end

function init(self)
	self._maid:Mark(self.Model)
	self._maid:Mark(self.VForce)
	self._maid:Mark(self.FloorDetector)
	self._maid:Mark(self.Gyro)
	self.Model.Name = "Collider"
	self.Model.Parent = self.Controller.Character

	self.Controller.Character.HumanoidRootPart:GetPropertyChangedSignal("Size"):Connect(function()
		print("HEARD FROM CONTROLLER")
		local scale = math.max(1, self.Controller.Character:GetScale())
		self.Gyro.P = 25000 * scale
		self.Gyro.D = 500 * scale
		-- self.Gyro.MaxTorque = Vector3.new(100000 * scale, 100000 * scale, 100000 * scale)
	end)
end

-- Public Methods

function ColliderClass:Update(force, cframe)
	
	self.VForce.Force = force
	self.Gyro.CFrame = cframe
end

--@MODIFICATION muh dude is getting stuck on walls, help!
function ColliderClass:SetAirFriction()

	local model: Model = self.Controller.Character
	if model:GetAttribute("_GroundFrictionOn") == false then
		return
	end
	model:SetAttribute("_GroundFrictionOn", false)
	
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") and part.CanCollide then
			if not part:GetAttribute("BaseFriction") then
				part:SetAttribute("BaseFriction", part.CurrentPhysicalProperties.Friction)
			end

			local props = part.CurrentPhysicalProperties
			local density = props.Density
			local elasticity = props.Elasticity
			local frictionWeight = props.FrictionWeight
			local elasticityWeight = props.ElasticityWeight
			part.CustomPhysicalProperties = PhysicalProperties.new(density, 0, elasticity, frictionWeight, elasticityWeight)
		end
	end
end

function ColliderClass:SetGroundFriction()
	local model: Model = self.Controller.Character
	if model:GetAttribute("_GroundFrictionOn") == true then
		return
	end
	model:SetAttribute("_GroundFrictionOn", true)

	for _, part in model:GetChildren() do
		if part:IsA("BasePart") and part.CanCollide then
			if not part:GetAttribute("BaseFriction") then
				part:SetAttribute("BaseFriction", part.CurrentPhysicalProperties.Friction)
			end

			local props = part.CurrentPhysicalProperties
			local density = props.Density
			local elasticity = props.Elasticity
			local frictionWeight = props.FrictionWeight
			local elasticityWeight = props.ElasticityWeight
			part.CustomPhysicalProperties = PhysicalProperties.new(density, part:GetAttribute("BaseFriction"), elasticity, frictionWeight, elasticityWeight)
		end
	end
end

local loop = nil
function ColliderClass:IsGrounded(isJumpCheck)
	
	local char = self.Controller.Character
	if char:FindFirstChild("HumanoidRootPart") == nil then
		return false
	end
	
	local e = char.HumanoidRootPart.Size.Y / 4
	local cast = workspace:Raycast(char.HumanoidRootPart.Position, 
		char.HumanoidRootPart.CFrame.UpVector.Unit * -(char.Humanoid.HipHeight+(char.HumanoidRootPart.Size.Y/2) + e ), 
		params2
	)
	
	return not not (cast and cast.Instance)

	-- local parts = (isJumpCheck and self.JumpDetector or self.FloorDetector):GetTouchingParts()
	-- for _, part in pairs(parts) do
	-- 	if not part:IsDescendantOf(self.Controller.Character) and part.CanCollide
	-- 		and part.Position.Y + (part.Size.Y / 2) >= self.FloorDetector.Position.Y
	-- 		then
	-- 		self.Grounded = true
	-- 		return true
	-- 	end
	-- end
	-- self.Grounded = false 
	-- return false

end


function ColliderClass:HasWallInFront()
	local sphere = self.Model.Sphere
	local raycast = workspace:Raycast(sphere.Position, 
		sphere.CFrame.LookVector.Unit * sphere.Size.X * 1.25,
		params2
	)
	if raycast and raycast.Instance then
		--Perhaps add some other logic here at some point 
		if raycast.Instance:HasTag("NO_WJ") then
			print("CANNOT WJ ON ITEM")
		else
			self.OnWall = true
			return true, raycast.Instance
	
		end
	end
	self.OnWall = false
	return false, nil
end

function ColliderClass:GetStandingPart()
	params2.FilterDescendantsInstances = {self.Controller.Character}

	local gravityUp = self.Controller._gravityUp
	local result = workspace:Raycast(self.Sphere.Position, -1.1*gravityUp, params2)

	return result and result.Instance
end

function ColliderClass:Destroy()
	self._maid:Sweep()
end

--

return ColliderClass
