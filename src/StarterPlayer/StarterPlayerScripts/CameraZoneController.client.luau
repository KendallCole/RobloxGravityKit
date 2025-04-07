local Players = game:GetService("Players")
local myPlayer = Players.LocalPlayer
local CameraStackController = require(script.Parent.CameraStackController)
local ReplicatedStorage = game:GetService("ReplicatedStorage") 
local RunService = game:GetService("RunService")
local Network = require(ReplicatedStorage.Network)
local Octree = require(ReplicatedStorage.Utills.Octree)
local Utills = ReplicatedStorage.Utills
local PartUtills = require(Utills.PartUtills)
local CameraChanged = Network.Signal("CameraChanged")

local PROCESS_DIST = 512


local octree = Octree.new()
local camera = workspace.CurrentCamera
local cameraZones = workspace:WaitForChild("CameraZones")

for _, camera in cameraZones:GetChildren() do
    octree:CreateNode(camera.Position, camera)
end
cameraZones.ChildAdded:Connect(function(part)
    octree:CreateNode(part.Position, part)
end)

local lastProcessedCam = nil
local returnToPos = CameraStackController:Snapshot()

local cameraCon
local tween: Tween
CameraChanged:Connect(function(newCam)
    if cameraCon then
        cameraCon:Disconnect()
    end
    if tween then
        tween:Cancel()
    end
    if newCam then
        if camera.CameraType == Enum.CameraType.Custom then
            returnToPos =  CameraStackController:Snapshot()
        end
        camera.CameraType = Enum.CameraType.Scriptable

        if newCam:GetAttribute("Tween") then
            -- tween = CameraStackController:TweenTo(newCam.Camera.CFrame, .5)
        else
            camera.CFrame = newCam.Camera.CFrame    
        end

        if newCam:GetAttribute("Track") then

            cameraCon = RunService.RenderStepped:Connect(function()
                if tween and tween.PlaybackState == Enum.PlaybackState.Playing then
                    return
                end
                local character = myPlayer.Character
                local root = (character and character:FindFirstChild("HumanoidRootPart"))
	
                if not root then
                    return
                end
                if newCam:GetAttribute("Tween") then
                    camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(newCam.Camera.Position, root.Position), .05)

                else
                    camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(newCam.Camera.Position, root.Position), .05)
                end
            end)
        else
            tween = CameraStackController:TweenTo(newCam.Camera.CFrame, newCam:GetAttribute("TweenToSpeed") or .5 )
        end
    else
        CameraStackController:GotoPlayer(returnToPos, 2)
        camera.CameraType = Enum.CameraType.Custom
    end
end)

RunService.RenderStepped:Connect(function()
    local character = myPlayer.Character
	local root = (character and character:FindFirstChild("HumanoidRootPart"))
	
	if not root then
		return
	end
    
    local elegibleZones = octree:RadiusSearch(root.Position, PROCESS_DIST)
    local touchingZones = {}
    for _, zone in elegibleZones do
        if PartUtills:partIntersectsBoundingBox(root, zone) then
            if zone:GetAttribute("Enabled") then
                table.insert(touchingZones, zone)
            end
        end
    end
    
	table.sort(touchingZones, function(a, b) return a.Priority > b.Priority end)
    local selected = touchingZones[1] or nil
    if lastProcessedCam ~= selected then
        if selected then
            CameraChanged:Fire(selected, selected:GetAttribute("Follow"))
        else
            CameraChanged:Fire()
        end
    end
    lastProcessedCam = selected
end)