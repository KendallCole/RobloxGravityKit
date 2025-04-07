local CameraStackController = {}
local Players = game:GetService("Players")
local myPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local stack = {}

function getPlayerCFrame(): CFrame
	local playerCFrame = CFrame.new()
	if myPlayer.Character and myPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local HumanoidRootPart = myPlayer.Character.HumanoidRootPart
		playerCFrame = HumanoidRootPart.CFrame
	end    

	return playerCFrame
end

local lerpTask = nil
local animationTask: Tween? = nil 

function CameraStackController:TweenTo(CFrame, speed)
    if lerpTask then
        task.cancel(lerpTask)
    end
    if animationTask then

    end
    local ani = TweenService:Create(camera, TweenInfo.new(speed), {CFrame = CFrame})
    ani:Play()
    
    return ani
end
 
function CameraStackController:GotoPlayer(last, easingDistance)
    if lerpTask then
        task.cancel(lerpTask)
    end
    if animationTask then
        animationTask:Cancel()
    end

    lerpTask = task.spawn(function()
        local easingDistance = easingDistance or 1
    
        local timeToLerp = .5 --Times distance?
    
        local start = tick()
        local startCF = camera.CFrame
        while tick() - start <= timeToLerp do 
            -- print(tick()-start)
            RunService.RenderStepped:Wait()
            local goal = getPlayerCFrame()  * last
            local dis = (camera.CFrame.Position - goal.Position).Magnitude
            if goal == CFrame.new() then
                continue
            end
            camera.CFrame = startCF:Lerp(goal, math.min(((tick()-start)/timeToLerp), 1) )
        end
    
    end)
end

function CameraStackController:Snapshot()
    local offset = getPlayerCFrame()
    local relativeCameraPos = offset:ToObjectSpace(camera.CFrame)
    -- table.insert(stack, relativeCameraPos)
    return relativeCameraPos
end

return CameraStackController