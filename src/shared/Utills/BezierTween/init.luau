--!strict
-- Laserluzer 
-- September 17, 2021
-- Sean was in my code
local Bezier = {}
Bezier.__index = Bezier

--// Constants \\--

Bezier.Waypoints = require(script.Waypoints)
local Signal = require(script.Signal)
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--// Types \\--

export type BezierTweenInfo = {
	Waypoints : Waypoints,
	EasingStyle : Enum.EasingStyle,
	EasingDirection : Enum.EasingStyle,
	Time : number,
}

export type Waypoints = {
	[number] : Vector3
}

--// Math functions \\--

--@recursive
local function factorial(n : number) : number
	if n == 0 then return 1 end
	return n * factorial(n - 1)
end

local function binomial(n : number, i : number) : number
	local x : number = nil
	x = (factorial(n)) / 
		(factorial(n - i) * factorial(i))
	return x
end

--// Graphing functions \\--

local function graphPoint(t : number, ... : Vector3) : Vector3
	assert(t >= 0 and t <= 1, t .. "t is not between 0 and 1.")
	local points = {...}
	local n : number = #points - 1
	local p : Vector3 = nil
	for i = 0, n do
		local x = binomial(n,i)*(1 - t)^(n-i) * t^i * points[i+1] 
		p = p and p + x or x
	end
	return p
end

--// Main \\--

function Bezier.Create(instance : Instance, Info : BezierTweenInfo) -- Creates a new bezier curve tween
	local self = setmetatable({}, Bezier)
	
	assert(#Info.Waypoints > 1, "Bezier curve must have atleast 2 waypoints.")
	assert(Info.EasingStyle ~= Enum.EasingStyle.Elastic, "Elastic easing style not supported.")
	assert(Info.EasingStyle ~= Enum.EasingStyle.Back, "Back easing style not supported.")

	-- User variables
	self.Instance = instance
	self.PlaybackState = Enum.PlaybackState.Begin
	self.TweenInfo = Info

	-- Events
	self.Played = Signal.new()
	self.Completed = Signal.new()
	self.Cancelled = Signal.new()
	self.Ended = Signal.new()
	self.Paused = Signal.new()
	self.Resumed = Signal.new()

	-- Private variables
	self._time = 0
	self._style = Info.EasingStyle or Enum.EasingStyle.Linear
	self._direction = Info.EasingDirection or Enum.EasingDirection.In

	return self
end

function Bezier:Play() -- Plays bezier curve tween
	assert(not (self.PlaybackState == Enum.PlaybackState.Playing), "Tween is already playing.")
	assert(not (self.PlaybackState == Enum.PlaybackState.Cancelled), "Tween is cancelled.")

	self.Played:Fire()
	self.PlaybackState = Enum.PlaybackState.Playing
	task.spawn(function()
		local x : number = self.TweenInfo.Time
		
		while self._time < 1 do
			if not (self.PlaybackState == Enum.PlaybackState.Playing) then return end
			local alpha = TweenService:GetValue(self._time, self._style, self._direction)

			self.Instance.Position = graphPoint(alpha, unpack(self.TweenInfo.Waypoints))
			
			self._time += 1 / (60 * self.TweenInfo.Time)
			RunService.Heartbeat:Wait()
		end

		self.PlaybackState = Enum.PlaybackState.Completed
		self.Completed:Fire()
		self.Ended:Fire()
		return "Completed"
	end)
end

function Bezier:Pause() -- Paused running tween
	if not (self.PlaybackState == Enum.PlaybackState.Paused) then
		self.PlaybackState = Enum.PlaybackState.Paused
		self.Paused:Fire()
	end
end

function Bezier:Resume() -- Resumes paused tween
	if self.PlaybackState == Enum.PlaybackState.Paused then
		self:Play()
		self.Resumed:Fire()
	end
end

function Bezier:Cancel() -- Destroys tween
	if not (self.PlaybackState == Enum.PlaybackState.Cancelled) then
		self.PlaybackState = Enum.PlaybackState.Cancelled
		self.Cancelled:Fire()
		self.Ended:Fire()
	end
end

return Bezier