local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(context, section, options)
	options = options or {}
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = options.Name or "Dropdown",
		Flag = options.Flag,
		Options = options.Options or options.Values or {},
		Value = options.Default,
		Callback = options.Callback or function() end,
		Connections = {},
		Expanded = false,
		Enabled = true,
		MaxVisibleOptions = tonumber(options.MaxVisibleOptions) or 5,
	}, Dropdown)

	if self.Value == nil and self.Options[1] ~= nil then
		self.Value = self.Options[1]
	end
	if self.Value ~= nil and not table.find(self.Options, self.Value) then
		context.Library:_Warn("Dropdown '" .. tostring(self.Name) .. "' default was not in Options")
		self.Value = self.Options[1]
	end

	local theme = self.Theme
	local utility = self.Utility

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundTransparency = 1,
		Parent = section.Frame,
	})

	local label = utility:Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	local button = utility:Create("TextButton", {
		Name = "Button",
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = theme.Background,
		Font = Enum.Font.Gotham,
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	})
	utility:Corner(button, 8)
	utility:Stroke(button, theme.Stroke, 0.5)

	local valueLabel = utility:Create("TextLabel", {
		Name = "Value",
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -42, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextColor3 = theme.MutedText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = button,
	})

	local arrow = utility:Create("TextLabel", {
		Name = "Arrow",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		Size = UDim2.fromOffset(20, 34),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "v",
		TextColor3 = theme.Accent,
		TextSize = 12,
		Parent = button,
	})

	local list = utility:Create("Frame", {
		Name = "List",
		Position = UDim2.fromOffset(0, 64),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = theme.Background,
		ClipsDescendants = true,
		Parent = frame,
	})
	utility:Corner(list, 8)
	utility:Stroke(list, theme.Stroke, 0.5)
	utility:Padding(list, { All = 4 })

	local scroll = utility:Create("ScrollingFrame", {
		Name = "Options",
		Size = UDim2.new(1, -8, 1, -8),
		Position = UDim2.fromOffset(4, 4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = 0.3,
		Parent = list,
	})
	local optionLayout = utility:List(scroll, 4)

	self.Instance = frame
	self.Label = label
	self.Button = button
	self.ValueLabel = valueLabel
	self.Arrow = arrow
	self.List = list
	self.Scroll = scroll
	self.OptionLayout = optionLayout
	self.CanvasConnection = utility:BindCanvas(scroll, optionLayout, 4)
	self.OptionButtons = {}

	for _, option in ipairs(self.Options) do
		self:_addOption(option)
	end

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		if self.Enabled == false then
			return
		end

		self:SetExpanded(not self.Expanded)
	end)

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)
	self:SetExpanded(false, true)
	self.Library:_BindElement(self, options)

	return self
end

function Dropdown:_addOption(option)
	local text = tostring(option)
	local utility = self.Utility
	local theme = self.Theme

	local button = utility:Create("TextButton", {
		Name = text,
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = theme.Card,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = text,
		TextColor3 = theme.MutedText,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutoButtonColor = false,
		Parent = self.Scroll,
	})
	utility:Corner(button, 6)

	self.Utility:Connect(self.Connections, button.MouseEnter, function()
		if self.Enabled == false then
			return
		end

		self.Utility:Tween(button, 0.12, { BackgroundTransparency = 0.25 })
	end)

	self.Utility:Connect(self.Connections, button.MouseLeave, function()
		if self.Enabled == false then
			return
		end

		local active = self.Value == option
		self.Utility:Tween(button, 0.12, { BackgroundTransparency = active and 0 or 1 })
	end)

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		if self.Enabled == false then
			return
		end

		if self.Flag then
			self.Library:SetFlag(self.Flag, option, true)
		else
			self:SetValue(option, true)
		end
		self:SetExpanded(false)
	end)

	table.insert(self.OptionButtons, { Button = button, Value = option })
end

function Dropdown:GetValue()
	return self.Value
end

function Dropdown:SetExpanded(value, instant)
	if self.Destroyed then
		return self
	end

	self.Expanded = value == true
	local maxVisible = math.max(self.MaxVisibleOptions, 1)
	local height = self.Expanded and math.min(#self.Options, maxVisible) * 32 + 8 or 0
	local frameHeight = self.Expanded and (64 + height) or 58

	self.Arrow.Text = self.Expanded and "^" or "v"
	self.Scroll.CanvasPosition = Vector2.new(0, 0)

	if instant then
		self.List.Size = UDim2.new(1, 0, 0, height)
		self.Instance.Size = UDim2.new(1, 0, 0, frameHeight)
	else
		self.Utility:Tween(self.List, 0.16, { Size = UDim2.new(1, 0, 0, height) })
		self.Utility:Tween(self.Instance, 0.16, { Size = UDim2.new(1, 0, 0, frameHeight) })
	end
	return self
end

function Dropdown:SetValue(value, fireCallback)
	if self.Destroyed then
		return self
	end

	if value ~= nil and not table.find(self.Options, value) then
		self.Library:_Warn("Dropdown '" .. self.Name .. "' ignored invalid value '" .. tostring(value) .. "'")
		return self
	end

	local changed = self.Value ~= value
	self.Value = value

	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	self.ValueLabel.Text = tostring(value or "")

	for _, item in ipairs(self.OptionButtons) do
		local active = item.Value == self.Value
		item.Button.BackgroundTransparency = active and 0 or 1
		item.Button.TextColor3 = active and self.Theme.Text or self.Theme.MutedText
	end

	if changed and fireCallback ~= false then
		task.spawn(self.Callback, self.Value)
	end
	return self
end

function Dropdown:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.ValueLabel.TextTransparency = self.Enabled and 0 or 0.45
	self.Button.BackgroundTransparency = self.Enabled and 0 or 0.35

	if not self.Enabled then
		self:SetExpanded(false)
	end
	return self
end

function Dropdown:Enable()
	return self:SetEnabled(true)
end

function Dropdown:Disable()
	return self:SetEnabled(false)
end

function Dropdown:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Library:_SetElementVisible(self, visible == true)
	return self
end

function Dropdown:Show()
	return self:SetVisible(true)
end

function Dropdown:Hide()
	return self:SetVisible(false)
end

function Dropdown:SetText(text)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function Dropdown:SetCallback(callback)
	self.Callback = typeof(callback) == "function" and callback or function() end
	return self
end

function Dropdown:Set(value, fireCallback)
	return self:SetValue(value, fireCallback)
end

function Dropdown:SetOptions(options, defaultValue)
	if self.Destroyed then
		return self
	end

	if typeof(options) ~= "table" then
		self.Library:_Warn("Dropdown '" .. self.Name .. "' SetOptions ignored: options must be a table")
		return self
	end

	for _, item in ipairs(self.OptionButtons) do
		if item.Button then
			item.Button:Destroy()
		end
	end

	table.clear(self.OptionButtons)
	self.Options = options

	for _, option in ipairs(self.Options) do
		self:_addOption(option)
	end

	local nextValue = defaultValue
	if nextValue == nil or not table.find(self.Options, nextValue) then
		nextValue = self.Options[1]
	end

	self:SetValue(nextValue, false)
	self:SetExpanded(false, true)
	return self
end

function Dropdown:Refresh()
	if not self.Destroyed then
		self:SetValue(self.Value, false)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function Dropdown:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Label.TextColor3 = theme.Text
	self.Button.BackgroundColor3 = theme.Background
	self.ValueLabel.TextColor3 = theme.MutedText
	self.Arrow.TextColor3 = theme.Accent
	self.List.BackgroundColor3 = theme.Background
	self.Scroll.ScrollBarImageColor3 = theme.Accent

	for _, item in ipairs(self.OptionButtons) do
		item.Button.BackgroundColor3 = theme.Card
	end

	self:SetValue(self.Value, false)
	return self
end

function Dropdown:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	self.Context.Flags:Unregister(self.Library, self.Flag, self)

	if self.CanvasConnection then
		self.CanvasConnection:Disconnect()
		self.CanvasConnection = nil
	end

	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
end

return Dropdown
