local Flags = {}

function Flags:Register(library, flag, element)
	if not flag then
		return
	end

	library._flagObjects[flag] = element

	if library.Flags[flag] ~= nil then
		element:SetValue(library.Flags[flag], false)
	else
		library.Flags[flag] = element:GetValue()
	end

	if library._RefreshDependencies then
		library:_RefreshDependencies(flag)
	end
end

function Flags:Get(library, flag)
	return library.Flags[flag]
end

function Flags:Set(library, flag, value, fireCallback)
	local element = library._flagObjects[flag]

	if element and element.SetValue then
		element:SetValue(value, fireCallback ~= false)
	else
		library.Flags[flag] = value
	end

	if library._RefreshDependencies then
		library:_RefreshDependencies(flag)
	end
end

return Flags
