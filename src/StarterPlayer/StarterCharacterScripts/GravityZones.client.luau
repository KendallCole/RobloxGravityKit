-- Thanks to EmilyBendsSpace for the new get normal function!
-- https://devforum.roblox.com/t/example-source-smooth-wall-walking-gravity-controller-from-club-raven/440229?u=egomoose

local Players = game:GetService("Players")
local myPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage") 
local Utills = ReplicatedStorage.Utills
local ClientService = require(myPlayer.PlayerScripts.ClientServices)
local GravityControllers = require(ReplicatedStorage.GravityController)
local gravityController = GravityControllers.new(myPlayer)
local PartUtills = require(Utills.PartUtills)

local DEFAULT_VECTOR = Vector3.new(0, 1, 0)
local DEFAULT_GRAVITY_POWER = 192.2
local PROCESS_DIST = 512

local gravityVector = DEFAULT_VECTOR

ClientService:SetGravityController(gravityController)

local Octree = require(ReplicatedStorage.Utills.Octree)
local octree = Octree.new()


local GravityZones = workspace:WaitForChild("GravityZones")

for _, zone in GravityZones:GetChildren() do
	octree:CreateNode(zone.Position, zone)
end
GravityZones.ChildAdded:Connect(function(part)
	octree:CreateNode(part.Position, part)
end)


RunService.PreSimulation:Connect(function()
	
	local intersectingZones = {}
	local character = myPlayer.Character
	local root = character:FindFirstChild("HumanoidRootPart")
	
	if not root then
		return
	end

	for _, zone: Part in GravityZones:GetChildren() do
		if zone.Shape == Enum.PartType.Ball and PartUtills:isSphereIntersectingOBB(root, zone) then
			
			local distance = (root.Position - zone.Position).Magnitude
			-- gravityVector = (Vector3.new((root.Position.X - zone.Position.X) / distance, (root.Position.Y - zone.Position.Y) / distance, (root.Position.Z - zone.Position.Z) / distance))
			local v = (root.Position - zone.Position) / distance
			
			if zone:GetAttribute("REVERSE") then
				v = v * -1
			end
			
			local entry = {Vector = v, 
				Priority = zone:GetAttribute("Priority") or 0,
				Gravity = zone:GetAttribute("Gravity") or DEFAULT_GRAVITY_POWER, 	
			}
			table.insert(intersectingZones, entry)

		elseif zone.Shape == Enum.PartType.Block and PartUtills:partIntersectsBoundingBox(root, zone) then
			local v = zone.CFrame.UpVector.Unit
			local entry = {Vector = v, 
				Priority = zone:GetAttribute("Priority") or 0,
				Gravity = zone:GetAttribute("Gravity") or DEFAULT_GRAVITY_POWER, 	
			}
			table.insert(intersectingZones, entry)
		elseif zone.Shape == Enum.PartType.Cylinder and PartUtills:pointInCylinder(root.Position, zone) then

			
			local top = (zone.CFrame * CFrame.new(zone.Size.Y/2, 0,0))
			local bottom = (zone.CFrame * CFrame.new(-zone.Size.Y/2, 0,0))
			local relativeCenter = PartUtills:closestToSegment(top.Position, bottom.Position, root.Position)


			local distance = (root.Position - relativeCenter).Magnitude
			local v = (root.Position - relativeCenter) / distance
			
			if zone:GetAttribute("REVERSE") then
				v = v * -1
			end
			
			local entry = {Vector = v, 
				Priority = zone:GetAttribute("Priority") or 0,
				Gravity = zone:GetAttribute("Gravity") or DEFAULT_GRAVITY_POWER, 	
			}
			table.insert(intersectingZones, entry)



		end
	end
	table.sort(intersectingZones, function(a, b) return a.Priority > b.Priority end)
	if #intersectingZones == 0 then
		gravityVector = DEFAULT_VECTOR
		workspace.Gravity = DEFAULT_GRAVITY_POWER
	else
		gravityVector = intersectingZones[1].Vector
		workspace.Gravity = intersectingZones[1].Gravity
	end
end)


RunService.Heartbeat:Connect(function(dt)
	-- gravityController:ResetGravity(gravityVector)
	ClientService:SetGravityVector(gravityVector)
	-- local distance = (PLAYERS.LocalPlayer.Character.HumanoidRootPart.Position - game.Workspace.Bodies.Earth.Position).Magnitude
	--Controller:ResetGravity(Vector3.new((PLAYERS.LocalPlayer.Character.HumanoidRootPart.Position.X - game.Workspace.Bodies.Earth.Position.X) / distance, (PLAYERS.LocalPlayer.Character.HumanoidRootPart.Position.Y - game.Workspace.Bodies.Earth.Position.Y) / distance, (PLAYERS.LocalPlayer.Character.HumanoidRootPart.Position.Z - game.Workspace.Bodies.Earth.Position.Z) / distance))
end)

