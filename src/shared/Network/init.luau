-- Warp Library (@Eternity_Devs) https://devforum.roblox.com/t/warp-very-fast-powerful-networking-library/2779813
-- version 1.0.12
--!strict
--!native
--!optimize 2
local Index = require(script.Index)

return {
	Server = Index.Server,
	Client = Index.Client,
	fromServerArray = Index.fromServerArray,
	fromClientArray = Index.fromClientArray,
	
	Signal = Index.Signal,
	fromSignalArray = Index.fromSignalArray,

	buffer = Index.buffer,
}