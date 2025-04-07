local DebounceHash = {}
DebounceHash.__index = DebounceHash


function DebounceHash.new()
    local self = {
        debounceTable = {}
    }

    return setmetatable(self, DebounceHash)
end

function DebounceHash.doDebounce(self, key: string, time: number)
    if self.debounceTable[key] then
        task.cancel(self.debounceTable[key])
    end
    self.debounceTable[key] = task.spawn(function()
        task.wait(time)
        self.debounceTable[key] = nil
    end)

end

function DebounceHash.isDebouncing(self, key): boolean
    return (self.debounceTable[key] ~= nil)
end


function DebounceHash.Destroy(self)
    self = nil    
end

local singleton = DebounceHash.new() -- Creating one debounce hash that can be shared among all scripts. Save on some memory along the way :) 

function DebounceHash.singleton(): typeof(DebounceHash)
    return singleton
end

return DebounceHash