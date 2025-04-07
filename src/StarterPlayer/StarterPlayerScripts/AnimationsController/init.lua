local Players = game:GetService("Players")
local Player = Players.LocalPlayer
-- General animation controller for project
local AnimationController = {}
AnimationController.animationTracks = {}

local animations = {
    ["Punch1"] = 'rbxassetid://122280010768780', -- Punch 1
    ["Punch2"] = 'rbxassetid://121174351215792', -- Punch 2
    ["Slam"] = 'rbxassetid://101651605268141', 
    ["Block"] = 'rbxassetid://73686672383765', 
    ["Windmill"] = 'rbxassetid://128501770653273', 
    ["Crouching"] = 'rbxassetid://105868817702036', 
    ["LeftSideDash"] = 'rbxassetid://81677313484987', 
    ["RightSideDash"] = 'rbxassetid://78020550727894', 
    ["FrontRoll"] = 'rbxassetid://80146913618890', 
    ["BackRoll"] = 'rbxassetid://131357151762654', 
    ["AirDash"] = 'rbxassetid://76828738625498', 
    ["SpinAttack"] = 'rbxassetid://80669371520273', 
    ["LongJump"] = 'rbxassetid://14181783061', 
    ["WallJump"] = 'rbxassetid://75461696121028', 
    ["Fly"] = 'rbxassetid://84100190753635', 
    ["CollectKey"] = 'rbxassetid://117416846698134', 
}

function AnimationController:initializeAnimations()
	-- Characters are not replicated atomically so we need to wait for children to replicate
	local humanoid = Player.Character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")

	-- Load animations
	for name, animation in animations do

        local toAnimationObj = Instance.new("Animation")
        toAnimationObj.AnimationId = animation
		local animationTrack = animator:LoadAnimation(toAnimationObj)
        animationTrack.Priority = Enum.AnimationPriority.Action4
		self.animationTracks[name] = animationTrack
	end
end

--Currently not looping. Just pauses on that frame
function AnimationController:playAnimationAndLoop(animationName: string, Priority)
    local animation: AnimationTrack = self.animationTracks[animationName]
    local connectionSignal
    if animation then
        if Priority then
            animation.Priority = Priority
        end
        animation:Play()
        connectionSignal = animation:GetMarkerReachedSignal("LoopEnd"):Once(function()
            animation:AdjustSpeed(0)
            animation.TimePosition = 0
        end)
        animation.Ended:Once(function()
            animation:AdjustSpeed(1)
        end)
    end
    return connectionSignal
end

function AnimationController:forceStopAll()
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid") or model:FindFirstChildOfClass("AnimationController")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    for i,v in ipairs(animator:GetPlayingAnimationTracks()) do
        print("Stopping animation", v)
        v:Stop()
    end
end

function AnimationController:forceStop(animationName, fadeTime)
    local fadeTime = fadeTime or 0
    local animation: AnimationTrack = self.animationTracks[animationName]
    if animation then
        animation:Stop(fadeTime)
    end
end

function AnimationController:playAnimation(animationName: string, Priority, fadeTime: number?): AnimationTrack
    local animation: AnimationTrack = self.animationTracks[animationName]
    if animation then
        if Priority then
            animation.Priority = Priority
        end
        animation:Play(fadeTime)
    end
    return animation
end

if Player.Character then
    AnimationController:initializeAnimations()
end

Player.CharacterAdded:Connect(function()
    AnimationController:initializeAnimations()
end)

return AnimationController