local UserInputService = game:GetService("UserInputService")

local Keybinds = {}

function Keybinds:Init(library)
	if library._keybindsReady then
		return
	end

	library._keybindsReady = true
	library._keybindConnections = library._keybindConnections or {}

	table.insert(library._keybindConnections, UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		local listening = library._listeningKeybind
		if listening then
			listening:CaptureInput(input.KeyCode)
			return
		end

		if library._IsCommandPaletteHotkey and library:_IsCommandPaletteHotkey(input) then
			return
		end

		if UserInputService:GetFocusedTextBox() then
			return
		end

		for _, bind in pairs(library.Keybinds) do
			if bind.Enabled ~= false and bind.KeyCode ~= nil and bind.KeyCode == input.KeyCode then
				if bind.Mode == "Hold" then
					if not bind.Holding then
						bind.Holding = true
						library:_InvokeCallback("Keybind", bind.Callback, true, bind.KeyCode)
					end
				elseif not bind.Holding then
					bind.Holding = true
					library:_InvokeCallback("Keybind", bind.Callback, bind.KeyCode)
				end
			end
		end
	end))

	table.insert(library._keybindConnections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		for _, bind in pairs(library.Keybinds) do
			if bind.KeyCode ~= nil and bind.KeyCode == input.KeyCode and bind.Holding then
				bind.Holding = false

				if bind.Mode == "Hold" and bind.Enabled ~= false then
					library:_InvokeCallback("Keybind", bind.Callback, false, bind.KeyCode)
				end
			end
		end
	end))
end

function Keybinds:Register(library, keybind)
	if not keybind.Flag then
		return nil
	end

	self:Init(library)

	local entry = library.Keybinds[keybind.Flag]
	if not entry then
		entry = {
			Flag = keybind.Flag,
			KeyCode = nil,
			Mode = keybind.Mode or "Toggle",
			Callback = keybind.Callback or function() end,
			Holding = false,
			Listening = false,
			Enabled = true,
			SetVisual = function() end,
			ClearVisual = function() end,
		}
		library.Keybinds[keybind.Flag] = entry
	end

	entry.Mode = keybind.Mode or entry.Mode or "Toggle"
	entry.Callback = keybind.Callback or entry.Callback or function() end
	entry.Element = keybind
	entry.SetVisual = function(newKeyCode)
		keybind:SetVisual(newKeyCode)
	end
	entry.ClearVisual = function()
		keybind:ClearVisual()
	end

	keybind.RegistryEntry = entry
	return entry
end

function Keybinds:Unregister(library, keybind)
	if not keybind.Flag then
		return
	end

	local entry = library.Keybinds[keybind.Flag]
	if entry and entry.Element == keybind then
		if entry.Holding and entry.Mode == "Hold" and entry.KeyCode ~= nil and entry.Enabled ~= false then
			library:_InvokeCallback("Keybind", entry.Callback, false, entry.KeyCode)
		end

		entry.Holding = false
		library.Keybinds[keybind.Flag] = nil
	end
end

function Keybinds:SetKeyCode(library, flag, keyCode)
	local entry = flag and library.Keybinds[flag]
	if not entry then
		return
	end

	if entry.Holding and entry.Mode == "Hold" and entry.KeyCode ~= keyCode and entry.Enabled ~= false then
		library:_InvokeCallback("Keybind", entry.Callback, false, entry.KeyCode)
	end

	entry.Holding = false
	entry.KeyCode = keyCode

	if keyCode then
		entry.SetVisual(keyCode)
	else
		entry.ClearVisual()
	end
end

function Keybinds:SetEnabled(library, flag, enabled)
	local entry = flag and library.Keybinds[flag]
	if not entry then
		return
	end

	if enabled == false and entry.Holding then
		if entry.Mode == "Hold" and entry.KeyCode ~= nil then
			library:_InvokeCallback("Keybind", entry.Callback, false, entry.KeyCode)
		end
		entry.Holding = false
	end

	entry.Enabled = enabled == true
end

return Keybinds
