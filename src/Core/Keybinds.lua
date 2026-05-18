local UserInputService = game:GetService("UserInputService")

local Keybinds = {}

function Keybinds:Init(library)
	if library._keybindsReady then
		return
	end

	library._keybindsReady = true
	library._keybindConnections = library._keybindConnections or {}

	table.insert(library._keybindConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		local listening = library._listeningKeybind
		if listening then
			listening:CaptureInput(input.KeyCode)
			return
		end

		if gameProcessed or UserInputService:GetFocusedTextBox() then
			return
		end

		for _, keybind in pairs(library.Keybinds) do
			if keybind and keybind.Enabled ~= false and keybind.Value == input.KeyCode then
				if keybind.Mode == "Hold" then
					if not keybind._held then
						keybind._held = true
						keybind:Fire(true)
					end
				else
					keybind:Fire(input.KeyCode)
				end
			end
		end
	end))

	table.insert(library._keybindConnections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if UserInputService:GetFocusedTextBox() then
			return
		end

		for _, keybind in pairs(library.Keybinds) do
			if keybind and keybind.Enabled ~= false and keybind.Mode == "Hold" and keybind.Value == input.KeyCode and keybind._held then
				keybind._held = false
				keybind:Fire(false)
			end
		end
	end))
end

function Keybinds:Register(library, keybind)
	if not keybind.Flag then
		return
	end

	self:Init(library)
	library.Keybinds[keybind.Flag] = keybind
end

function Keybinds:Unregister(library, keybind)
	if keybind.Flag and library.Keybinds[keybind.Flag] == keybind then
		library.Keybinds[keybind.Flag] = nil
	end
end

return Keybinds
