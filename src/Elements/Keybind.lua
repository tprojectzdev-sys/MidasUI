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

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = options.Name or "Keybind",
		Flag = options.Flag,
		Value = normalizeKeyCode(options.Default),
		Mode = options.Mode == "Hold" and "Hold" or "Toggle",
		Callback = options.Callback or function() end,
		Connections = {},
		Listening = false,
		Enabled = true,
		RegistryEntry = nil,
	}, Keybind)

	local theme = self.Theme
	local utility = self.Utility

	local row = utility:Create("TextButton", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 42),
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
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local button = utility:Create("TextButton", {
		Name = "Bind",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(118, 32),
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
	self.Button.Text = keyName(keyCode)
	self.Button.TextColor3 = self.Enabled == false and self.Theme.MutedText or self.Theme.Text
end

function Keybind:ClearVisual()
	self.Button.Text = "None"
	self.Button.TextColor3 = self.Theme.MutedText
end

function Keybind:Refresh()
	if self.Value then
		self:SetVisual(self.Value)
	else
		self:ClearVisual()
	end

	self.Button.BackgroundTransparency = self.Enabled == false and 0.35 or 0
	self.Label.TextColor3 = self.Enabled == false and self.Theme.MutedText or self.Theme.Text
end

function Keybind:StartListening()
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
end

function Keybind:StopListening()
	self.Listening = false

	if self.RegistryEntry then
		self.RegistryEntry.Listening = false
	end

	if self.Library._listeningKeybind == self then
		self.Library._listeningKeybind = nil
	end

	self:Refresh()
end

function Keybind:CaptureInput(keyCode)
	if self.Library._listeningKeybind ~= self then
		return
	end

	if keyCode == Enum.KeyCode.Escape then
		self:StopListening()
		return
	end

	if keyCode == Enum.KeyCode.Backspace then
		if self.Flag then
			self.Library:SetFlag(self.Flag, nil, false)
		else
			self:SetValue(nil, false)
		end
		self:StopListening()
		return
	end

	if keyCode == Enum.KeyCode.Unknown then
		return
	end

	if self.Flag then
		self.Library:SetFlag(self.Flag, keyCode, false)
	else
		self:SetValue(keyCode, false)
	end

	self:StopListening()
end

function Keybind:SetValue(value)
	local keyCode = normalizeKeyCode(value)
	self.Value = keyCode

	if self.Flag then
		self.Library.Flags[self.Flag] = keyCode
		self.Context.Keybinds:SetKeyCode(self.Library, self.Flag, keyCode)
	else
		self:Refresh()
	end
end

function Keybind:SetEnabled(enabled)
	self.Enabled = enabled == true
	self.Context.Keybinds:SetEnabled(self.Library, self.Flag, self.Enabled)

	if not self.Enabled and self.Listening then
		self:StopListening()
	end

	self:Refresh()
end

function Keybind:SetTheme(theme)
	self.Theme = theme
	self.Button.BackgroundColor3 = theme.Background
	self:Refresh()
end

function Keybind:Destroy()
	self.Context.Keybinds:Unregister(self.Library, self)

	if self.Library._listeningKeybind == self then
		self.Library._listeningKeybind = nil
	end

	self.Utility:DisconnectAll(self.Connections)
	self.Instance:Destroy()
end

return Keybind
