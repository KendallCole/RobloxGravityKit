local ClientServices = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Network)
local GravityChanged = Network.Signal("GravityChanged")

ClientServices.Axis = Vector3.new(0, 1, 0)
ClientServices.GravityChanged = GravityChanged
function ClientServices:SetGravityVector(newVector: Vector3)
    if newVector ~= self.Axis then
        self.GravityController:ResetGravity(newVector)
        ClientServices.GravityChanged:Fire(newVector)
        self.Axis = newVector
    end

end
function ClientServices:SetGravityController(newController)
    ClientServices.GravityController = newController
end

return ClientServices