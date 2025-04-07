local CollectablesUtills = {}
local CollectionService = game:GetService("CollectionService")

function CollectablesUtills:GetGemsOfId(id: string)
    local gems = CollectionService:GetTagged("LEVEL_GEM")
    local res = {}
    
    for _, gem in gems do
        if string.find(gem:GetAttribute("ID"), id) then
            table.insert(res, gem)
        end
    end
    return res
end

function CollectablesUtills:GetKeysOfId(id: string)
    assert(id ~= "", "No id passed")
    local keys = CollectionService:GetTagged("KEY_OBJ")
    local res = {}
    for _, key in keys do
        assert(key:GetAttribute("ID") ~= "", {"Key {key} found with blank ID!"})
        if string.find(key:GetAttribute("ID"), id) then
            table.insert(res, key)
        end
    end
    return res
end


return CollectablesUtills