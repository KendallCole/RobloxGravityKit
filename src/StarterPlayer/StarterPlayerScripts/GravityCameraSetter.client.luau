--!strict

local PlayerModule = script.Parent:WaitForChild("PlayerModule")

local playerModuleObject = require(PlayerModule) :: any
local cameraModuleObject = playerModuleObject:GetCameras()
local ClientServices = require(script.Parent.ClientServices)

ClientServices.GravityChanged:Connect(function(newAxis)

end)
-- game:GetService("RunService").Heartbeat:Connect(function(_dt)


ClientServices.GravityChanged:Connect(function(newAxis)
	cameraModuleObject:SetTargetUpVector(newAxis)
end)
