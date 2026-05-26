local UserInputService = game:GetService("UserInputService")

local Shortcuts = {}

local MODIFIER_KEYS = {
	[Enum.KeyCode.LeftControl] = "Ctrl",
	[Enum.KeyCode.RightControl] = "Ctrl",
	[Enum.KeyCode.LeftShift] = "Shift",
	[Enum.KeyCode.RightShift] = "Shift",
	[Enum.KeyCode.LeftAlt] = "Alt",
	[Enum.KeyCode.RightAlt] = "Alt",
}

local function keyCodeFromString(value)
	for _, keyCode in ipairs(Enum.KeyCode:GetEnumItems()) do
		if string.lower(keyCode.Name) == string.lower(value) then
			return keyCode
		end
	end
	return nil
end

function Shortcuts:Normalize(value)
	if value == nil or value == false then
		return nil, nil
	end

	local descriptor = {
		Ctrl = false,
		Shift = false,
		Alt = false,
	}

	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
		descriptor.KeyCode = value
	elseif typeof(value) == "string" then
		for token in string.gmatch(value, "[^+%s]+") do
			local lowerToken = string.lower(token)
			if lowerToken == "ctrl" or lowerToken == "control" then
				descriptor.Ctrl = true
			elseif lowerToken == "shift" then
				descriptor.Shift = true
			elseif lowerToken == "alt" then
				descriptor.Alt = true
			else
				descriptor.KeyCode = keyCodeFromString(token)
				if not descriptor.KeyCode then
					return nil, "Unknown shortcut key '" .. tostring(token) .. "'"
				end
			end
		end
	elseif typeof(value) == "table" then
		descriptor.KeyCode = value.KeyCode or value.Key
		descriptor.Ctrl = value.Ctrl == true or value.Control == true
		descriptor.Shift = value.Shift == true
		descriptor.Alt = value.Alt == true
	else
		return nil, "Shortcut must be a KeyCode, string, table, false, or nil"
	end

	if typeof(descriptor.KeyCode) ~= "EnumItem" or descriptor.KeyCode.EnumType ~= Enum.KeyCode
		or descriptor.KeyCode == Enum.KeyCode.Unknown then
		return nil, "Shortcut must include a valid KeyCode"
	end

	return descriptor, nil
end

function Shortcuts:Format(descriptor)
	if not descriptor then
		return "Disabled"
	end

	local parts = {}
	if descriptor.Ctrl then
		table.insert(parts, "Ctrl")
	end
	if descriptor.Shift then
		table.insert(parts, "Shift")
	end
	if descriptor.Alt then
		table.insert(parts, "Alt")
	end
	table.insert(parts, descriptor.KeyCode.Name)
	return table.concat(parts, "+")
end

function Shortcuts:Matches(descriptor, input)
	if not descriptor or not input or descriptor.KeyCode ~= input.KeyCode then
		return false
	end

	local ownModifier = MODIFIER_KEYS[descriptor.KeyCode]
	local ctrlDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
	local shiftDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	local altDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)

	return (ownModifier == "Ctrl" or ctrlDown == descriptor.Ctrl)
		and (ownModifier == "Shift" or shiftDown == descriptor.Shift)
		and (ownModifier == "Alt" or altDown == descriptor.Alt)
end

function Shortcuts:Set(library, id, value, callback, options)
	library._shortcuts = library._shortcuts or {}
	options = options or {}

	if value == nil or value == false then
		library._shortcuts[id] = nil
		return true, "Disabled"
	end

	local descriptor, err = self:Normalize(value)
	if not descriptor then
		library:_Warn("Shortcut", "Ignored shortcut '" .. tostring(id) .. "': " .. tostring(err))
		return false, err
	end
	if typeof(callback) ~= "function" then
		library:_Warn("Shortcut", "Ignored shortcut '" .. tostring(id) .. "': callback must be a function")
		return false, "Shortcut callback must be a function"
	end

	library._shortcutSequence = (library._shortcutSequence or 0) + 1
	library._shortcuts[id] = {
		Id = id,
		Shortcut = descriptor,
		Display = self:Format(descriptor),
		Callback = callback,
		Owner = options.Owner,
		Priority = tonumber(options.Priority) or 0,
		Sequence = library._shortcutSequence,
	}
	return true, library._shortcuts[id].Display
end

function Shortcuts:RemoveOwner(library, owner)
	for id, record in pairs(library._shortcuts or {}) do
		if record.Owner == owner then
			library._shortcuts[id] = nil
		end
	end
end

function Shortcuts:GetState(library)
	local items = {}
	for id, record in pairs(library._shortcuts or {}) do
		if not record.Owner or (not record.Owner.Destroyed and not record.Owner.Closed) then
			table.insert(items, {
				Id = id,
				Display = record.Display,
				Owner = record.Owner,
			})
		end
	end
	table.sort(items, function(left, right)
		return left.Id < right.Id
	end)
	return items
end

function Shortcuts:_DispatchFramework(context, input, processed)
	local library = context.Library
	local activePalette = library._activePalette
	local focused = UserInputService:GetFocusedTextBox()
	local paletteFocus = activePalette and focused == activePalette.SearchBox

	if library._activeDialog or (library._expandedDropdown and library._expandedDropdown.Expanded) then
		return false
	end
	if focused and not paletteFocus then
		return false
	end
	if processed and not activePalette then
		return false
	end

	local matches = {}
	for id, record in pairs(library._shortcuts or {}) do
		if record.Owner and (record.Owner.Destroyed or record.Owner.Closed) then
			library._shortcuts[id] = nil
		elseif (not activePalette or id == "command_palette") and self:Matches(record.Shortcut, input) then
			table.insert(matches, record)
		end
	end
	table.sort(matches, function(left, right)
		if left.Priority == right.Priority then
			return left.Sequence > right.Sequence
		end
		return left.Priority > right.Priority
	end)

	local record = matches[1]
	if not record then
		return false
	end

	local ok, err = pcall(record.Callback)
	if not ok then
		library:_Warn("Shortcut", "Callback failed: " .. tostring(err))
	end
	return true
end

function Shortcuts:Init(context)
	local library = context.Library
	if library._shortcutsReady then
		return
	end

	library._shortcutsReady = true
	library._shortcutConnections = library._shortcutConnections or {}
	context.Utility:Connect(library._shortcutConnections, UserInputService.InputBegan, function(input, processed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard or library._destroyed then
			return
		end

		if library._listeningKeybind then
			context.Keybinds:HandleInputBegan(library, input, processed)
			return
		end

		if not Shortcuts:_DispatchFramework(context, input, processed) then
			context.Keybinds:HandleInputBegan(library, input, processed)
		end
	end)
	context.Utility:Connect(library._shortcutConnections, UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			context.Keybinds:HandleInputEnded(library, input)
		end
	end)
end

function Shortcuts:Destroy(context)
	local library = context.Library
	context.Utility:DisconnectAll(library._shortcutConnections)
	table.clear(library._shortcuts or {})
	library._shortcutsReady = false
end

return Shortcuts
