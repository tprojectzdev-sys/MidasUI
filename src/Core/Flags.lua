local Flags = {}

local function getControllers(library, flag)
	local controllers = library._flagObjects[flag]
	if not controllers then
		controllers = {}
		library._flagObjects[flag] = controllers
	end

	return controllers
end

function Flags:Register(library, flag, element)
	if typeof(flag) ~= "string" or flag == "" then
		if library._Warn then
			library:_Warn("Flag registration skipped: invalid flag")
		end
		return
	end

	local controllers = getControllers(library, flag)
	for _, controller in ipairs(controllers) do
		if controller == element then
			return
		end
	end

	if #controllers > 0 and library._Warn then
		library:_Warn("Multiple elements are bound to flag '" .. flag .. "'")
	end

	table.insert(controllers, element)

	if library.Flags[flag] ~= nil then
		element:SetValue(library.Flags[flag], false)
	elseif element.GetValue then
		library.Flags[flag] = element:GetValue()
	end

	if library._RefreshDependencies then
		library:_RefreshDependencies(flag)
	end
end

function Flags:Unregister(library, flag, element)
	if typeof(flag) ~= "string" or flag == "" then
		return
	end

	local controllers = library._flagObjects[flag]
	if not controllers then
		return
	end

	for index = #controllers, 1, -1 do
		if controllers[index] == element or controllers[index].Destroyed then
			table.remove(controllers, index)
		end
	end

	if #controllers == 0 then
		library._flagObjects[flag] = nil
	end
end

function Flags:Get(library, flag)
	return library.Flags[flag]
end

function Flags:Set(library, flag, value, fireCallback)
	local controllers = library._flagObjects[flag]
	local shouldFire = fireCallback ~= false

	library.Flags[flag] = value

	if controllers then
		for index = #controllers, 1, -1 do
			local controller = controllers[index]
			if not controller or controller.Destroyed or not controller.Instance or not controller.Instance.Parent then
				table.remove(controllers, index)
			elseif controller.SetValue then
				controller:SetValue(value, shouldFire)
			end
		end

		if #controllers == 0 then
			library._flagObjects[flag] = nil
		end
	end

	if library._RefreshDependencies then
		library:_RefreshDependencies(flag)
	end
end

return Flags
