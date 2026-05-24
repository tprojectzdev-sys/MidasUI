local Keybind = {}
Keybind.__index = Keybind

local function normalizeKeyCode(value)
	if value == nil then
		return nil
	end

	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
		return value
	end

	if typeof(value) == "string" then
		local name = string.gsub(value, "^Enum%.KeyCode%.", "")
		local ok, keyCode = pcall(function()
			return Enum.KeyCode[name]
		end)

		if ok and keyCode ~= Enum.KeyCode.Unknown then
			return keyCode
		end
	end

	return nil
end

local function keyName(value)
	local keyCode = normalizeKeyCode(value)
	return keyCode and keyCode.Name or "None"
end

function Keybind.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "Keybind ignored an invalid Flag value")
		flag = nil
	end

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or "Keybind"),
		Flag = flag,
		Value = normalizeKeyCode(options.Default),
		Mode = options.Mode == "Hold" and "Hold" or "Toggle",
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
		Connections = {},
		Listening = false,
		Enabled = true,
		RegistryEntry = nil,
	}, Keybind)

	local theme = self.Theme
	local utility = self.Utility
	local compact = section.Compact == true

	local row = utility:Create("TextButton", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 34 or 42),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = section.Frame,
	})

	local label = utility:Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, -130, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local button = utility:Create("TextButton", {
		Name = "Bind",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(compact and 108 or 118, compact and 28 or 32),
		BackgroundColor3 = theme.Background,
		Font = Enum.Font.GothamMedium,
		Text = keyName(self.Value),
		TextColor3 = theme.MutedText,
		TextSize = 12,
		AutoButtonColor = false,
		Parent = row,
	})
	utility:Corner(button, 8)
	utility:Stroke(button, theme.Stroke, 0.45)

	self.Instance = row
	self.Label = label
	self.Button = button

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		if self.Enabled == false then
			return
		end

		self:StartListening()
	end)

	context.Keybinds:Register(self.Library, self)
	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)
	self.Library:_BindElement(self, options)

	return self
end

function Keybind:GetValue()
	return self.Value
end

function Keybind:SetVisual(keyCode)
	if self.Destroyed then
		return self
	end

	self.Button.Text = keyName(keyCode)
	self.Button.TextColor3 = self.Enabled == false and self.Theme.MutedText or self.Theme.Text
	return self
end

function Keybind:ClearVisual()
	if self.Destroyed then
		return self
	end

	self.Button.Text = "None"
	self.Button.TextColor3 = self.Theme.MutedText
	return self
end

function Keybind:Refresh()
	if self.Destroyed then
		return self
	end

	if self.Value then
		self:SetVisual(self.Value)
	else
		self:ClearVisual()
	end

	self.Button.BackgroundTransparency = self.Enabled == false and 0.35 or 0
	self.Label.TextColor3 = self.Enabled == false and self.Theme.MutedText or self.Theme.Text
	return self
end

function Keybind:StartListening()
	if self.Destroyed or self.Enabled == false then
		return self
	end

	if self.Library._listeningKeybind and self.Library._listeningKeybind ~= self then
		self.Library._listeningKeybind:StopListening()
	end

	self.Listening = true
	self.Library._listeningKeybind = self

	if self.RegistryEntry then
		self.RegistryEntry.Listening = true
	end

	self.Button.Text = "..."
	self.Button.TextColor3 = self.Theme.Accent
	return self
end

function Keybind:StopListening()
	if self.Destroyed then
		return self
	end

	self.Listening = false

	if self.RegistryEntry then
		self.RegistryEntry.Listening = false
	end

	if self.Library._listeningKeybind == self then
		self.Library._listeningKeybind = nil
	end

	self:Refresh()
	return self
end

function Keybind:CaptureInput(keyCode)
	if self.Destroyed then
		return self
	end

	if self.Library._listeningKeybind ~= self then
		return self
	end

	if keyCode == Enum.KeyCode.Escape then
		self:StopListening()
		return self
	end

	if keyCode == Enum.KeyCode.Backspace then
		if self.Flag then
			self.Library:SetFlag(self.Flag, nil, false)
		else
			self:SetValue(nil, false)
		end
		self:StopListening()
		return self
	end

	if keyCode == Enum.KeyCode.Unknown then
		return self
	end

	if self.Flag then
		self.Library:SetFlag(self.Flag, keyCode, false)
	else
		self:SetValue(keyCode, false)
	end

	self:StopListening()
	return self
end

function Keybind:SetValue(value)
	if self.Destroyed then
		return self
	end

	local keyCode = normalizeKeyCode(value)
	if value ~= nil and not keyCode then
		self.Library:_Warn("Keybind", "'" .. self.Name .. "' received an invalid key value")
		return self
	end
	self.Value = keyCode

	if self.Flag then
		self.Library.Flags[self.Flag] = keyCode
		self.Context.Keybinds:SetKeyCode(self.Library, self.Flag, keyCode)
	else
		self:Refresh()
	end
	return self
end

function Keybind:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Context.Keybinds:SetEnabled(self.Library, self.Flag, self.Enabled)

	if not self.Enabled and self.Listening then
		self:StopListening()
	end

	self:Refresh()
	return self
end

function Keybind:Enable()
	return self:SetEnabled(true)
end

function Keybind:Disable()
	return self:SetEnabled(false)
end

function Keybind:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Library:_SetElementVisible(self, visible == true)
	return self
end

function Keybind:Show()
	return self:SetVisible(true)
end

function Keybind:Hide()
	return self:SetVisible(false)
end

function Keybind:SetText(text)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function Keybind:SetCallback(callback)
	if self.Destroyed then
		return self
	end

	self.Callback = typeof(callback) == "function" and callback or function() end
	if self.RegistryEntry then
		self.RegistryEntry.Callback = self.Callback
	end
	return self
end

function Keybind:Set(value, fireCallback)
	return self:SetValue(value, fireCallback)
end

function Keybind:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Button.BackgroundColor3 = theme.Background
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	self:Refresh()
	return self
end

function Keybind:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Library:_UnregisterDependencies(self)
	self.Context.Keybinds:Unregister(self.Library, self)
	self.Context.Flags:Unregister(self.Library, self.Flag, self)

	if self.Library._listeningKeybind == self then
		self.Library._listeningKeybind = nil
	end

	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return Keybind
