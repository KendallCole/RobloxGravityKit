--!strict
-- Laserluzer 
-- September 17, 2021

local RunService = game:GetService("RunService")

export type Waypoints = {
	[number] : Vector3
}

-- Waypoints

local Waypoints = {}


-- Value specific waypoint methods

do
	function Waypoints.fromVector3(... : Vector3) : Waypoints
		local args = {...}
		local waypoints = {}
		for i = 1, #args do
			assert(typeof(args[i]) == "Vector3", tostring(args[i]) .. "is not a Vector3 value.")
			table.insert(waypoints, args[i])
		end
		return waypoints
	end

	function Waypoints.fromCFrame(...) : Waypoints
		local args = {...}
		local waypoints = {}
		for i = 1, #args do
			assert(typeof(args[i]) == "CFrame", args[i] .. "is not a CFrame value.")
			table.insert(waypoints, args[i].Position)
		end
		return waypoints
	end

	function Waypoints.fromInstance(...) : Waypoints
		local args = {...}
		local waypoints = {}
		for i = 1, #args do
			assert(typeof(args[i]) == "Instance", args[i].Name .. "is not an Instance.")
			assert(args[i]:IsA("BasePart"), args[i].Name .. "is not a BasePart.")
			table.insert(waypoints, args[i].Position)
		end
		return waypoints
	end
end


local waypointTypes = {
	Vector3 = Waypoints.fromVector3,
	CFrame = Waypoints.fromCFrame,
	Instance = Waypoints.fromInstance
}

function Waypoints.new(... : Vector3 | CFrame | Instance) : Waypoints -- Creates waypoints
	assert(waypointTypes[typeof(...)], 
		"Parameters are not correct value types, try using value specific functions.")
	return waypointTypes[typeof(...)](...)
end



return Waypoints