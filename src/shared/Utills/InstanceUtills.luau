local InstanceUtills = {}

function InstanceUtills:WaitForFindFirstChild(parentInstance: Instance, childName: string, recursive: boolean?): Instance
    local recursive = recursive or false
    
    local iterations = 0
    while 1 do
        local foundInstance = parentInstance:FindFirstChild(childName, recursive)
        if foundInstance then 
            return foundInstance
        end
        iterations += 1
        if iterations % 25 then
            warn(`x{iterations} looking for instance '{childName}' under parent {parentInstance} [Recursive search: {recursive}]`)
        end
        task.wait()
    end
end

return InstanceUtills