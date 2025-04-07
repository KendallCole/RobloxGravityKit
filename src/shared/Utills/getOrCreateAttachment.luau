--[[
	getOrCreateAttachment - A utility function that either returns an existing attachment or
	creates it if it doesn't exist, with optionally specified axis properties.
--]]

local function getOrCreateAttachment(part: BasePart, name: string, axis: Vector3?, secondaryAxis: Vector3?): Attachment
	local attachment = part:FindFirstChild(name)
	if attachment then
		-- If the attachment already exists, return it
		return attachment
	end

	-- No attachment exists, so we'll create a new one
	local newAttachment = Instance.new("Attachment")
	newAttachment.Name = name
	if axis then
		newAttachment.Axis = axis
	end
	if secondaryAxis then
		newAttachment.SecondaryAxis = secondaryAxis
	end
	newAttachment.Parent = part

	return newAttachment
end

return getOrCreateAttachment
