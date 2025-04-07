local animate = script.Parent:WaitForChild("Animate")
local loaded = Instance.new("BoolValue")
loaded.Name = "Loaded"
loaded.Parent = animate --:WaitForChild("Loaded")

local replicatedHumanoid = Instance.new("ObjectValue")
replicatedHumanoid.Name = "ReplicatedHumanoid"
replicatedHumanoid.Parent = animate


local emote = Instance.new("BindableFunction")
emote.Name = "PlayEmote"
emote.Parent = animate