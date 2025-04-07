local PartUtills = {}

function PartUtills:closestToSegment(a: Vector3, b: Vector3, p: Vector3): Vector3
	if a == b then return p end
	local v: Vector3 = b - a
	local u: Vector3 = a - p
	local t: number = - (v:Dot(u))/(v.X^2 + v.Y^2 + v.Z^2)
	return (1-t)*a + t*b
end

function PartUtills:pointInCylinder(point, cylinder)
    local radius = math.min(cylinder.Size.Z,cylinder.Size.Y) * 0.5;
    local height = cylinder.Size.X;
    local relative = (point - cylinder.Position)

    local sProj = cylinder.CFrame.RightVector:Dot(relative)
    local vProj = cylinder.CFrame.RightVector * sProj
    local len = (relative - vProj).Magnitude
    
    return len <= radius and math.abs(sProj) <= (height * 0.5)
end

function PartUtills:partIntersectsBoundingBox(part1: any, part2: any)
    -- Helper function to get the three axes of the bounding box
    local function getAxes(part)
        local right = part.CFrame.RightVector
        local up = part.CFrame.UpVector
        local back = part.CFrame.LookVector
        return {right, up, back}
    end

    -- Helper function to project a vector onto an axis
    local function project(vector: Vector3, axis)
        return vector:Dot(axis) / axis.Magnitude
    end

    -- Helper function to get the vertices of the bounding box
    local function getVertices(part: Part)
        local cframe = part.CFrame
        local size = part.Size / 2
        
        return {
            cframe * Vector3.new(-size.X, -size.Y, -size.Z),
            cframe * Vector3.new(size.X, -size.Y, -size.Z),
            cframe * Vector3.new(-size.X, size.Y, -size.Z),
            cframe * Vector3.new(size.X, size.Y, -size.Z),
            cframe * Vector3.new(-size.X, -size.Y, size.Z),
            cframe * Vector3.new(size.X, -size.Y, size.Z),
            cframe * Vector3.new(-size.X, size.Y, size.Z),
            cframe * Vector3.new(size.X, size.Y, size.Z)
        }
    end

    -- Helper function to get the projection range of a part on an axis
    local function getProjectionRange(vertices, axis)
        local minProj = math.huge
        local maxProj = -math.huge

        for _, vertex in ipairs(vertices) do
            local projection = project(vertex, axis)
            minProj = math.min(minProj, projection)
            maxProj = math.max(maxProj, projection)
        end

        return minProj, maxProj
    end

    -- Get the axes to test for separation
    local axesToTest = {}
    local axesPart1 = getAxes(part1)
    local axesPart2 = getAxes(part2)

    -- Add the three axes of each part
    for _, axis in ipairs(axesPart1) do
        table.insert(axesToTest, axis)
    end
    for _, axis in ipairs(axesPart2) do
        table.insert(axesToTest, axis)
    end

    -- Add the cross products of each pair of axes
    for _, axis1: Vector3 in ipairs(axesPart1) do
        for _, axis2: Vector3 in ipairs(axesPart2) do
            table.insert(axesToTest, axis1:Cross(axis2).Unit)
        end
    end

    -- Get the vertices of each part
    local verticesPart1 = getVertices(part1)
    local verticesPart2 = getVertices(part2)

    -- Test for separation on each axis
    for _, axis in ipairs(axesToTest) do
        if axis.Magnitude > 0 then
            local min1, max1 = getProjectionRange(verticesPart1, axis)
            local min2, max2 = getProjectionRange(verticesPart2, axis)

            -- If there is no overlap on this axis, the parts do not intersect
            if max1 < min2 or max2 < min1 then
                return false
            end
        end
    end

    -- If no separating axis was found, the parts intersect
    return true
end

function PartUtills:transformToLocalSpace(worldPoint, partCFrame)
    return partCFrame:pointToObjectSpace(worldPoint)
end

function PartUtills:isSphereIntersectingOBB(part: any, sphere)
    local sphereRadius = sphere.Size.Y / 2
    local sphereCenter = sphere.Position
    -- Transform the sphere's center to the part's local space
    local localSphereCenter = PartUtills:transformToLocalSpace(sphereCenter, part.CFrame)
    
    local partSize = part.Size / 2
    
    -- Calculate the minimum and maximum corners of the AABB in local space
    local partMin = -partSize
    local partMax = partSize
    
    -- Find the closest point on the AABB to the sphere's center in local space
    local closestPoint = Vector3.new(
        math.clamp(localSphereCenter.X, partMin.X, partMax.X),
        math.clamp(localSphereCenter.Y, partMin.Y, partMax.Y),
        math.clamp(localSphereCenter.Z, partMin.Z, partMax.Z)
    )
    
    -- Calculate the distance between the sphere's center and the closest point
    local distance = (closestPoint - localSphereCenter).Magnitude
    
    -- Check if the distance is less than or equal to the sphere's radius
    return distance <= sphereRadius
end

return PartUtills