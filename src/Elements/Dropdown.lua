local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "Dropdown ignored an invalid Flag value")
		flag = nil
	end

	local dropdownOptions = typeof(options.Options or options.Values) == "table" and (options.Options or options.Values) or {}
	if options.Options ~= nil and typeof(options.Options) ~= "table" then
		context.Library:_Warn("Dropdown", "Options must be a table; using an empty option list")
	end

	local searchSetting = options.Searchable
	if searchSetting == nil then
		searchSetting = options.Search
	end
	local searchThreshold = math.max(tonumber(options.SearchThreshold) or 8, 1)
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or "Dropdown"),
		Flag = flag,
		Options = dropdownOptions,
		Value = options.Default,
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
		Connections = {},
		InteractionConnections = {},
		Expanded = false,
		Enabled = true,
		MaxVisibleOptions = math.clamp(tonumber(options.MaxVisibleOptions) or 5, 1, 20),
		SearchAutomatic = searchSetting == nil,
		SearchEnabled = searchSetting == true or (searchSetting == nil and #dropdownOptions >= searchThreshold),
		SearchThreshold = searchThreshold,
		FilteredOptions = {},
		SelectedIndex = 1,
	}, Dropdown)

	if self.Value == nil and self.Options[1] ~= nil then
		self.Value = self.Options[1]
	end
	if self.Value ~= nil and not table.find(self.Options, self.Value) then
		context.Library:_Warn("Dropdown", "'" .. tostring(self.Name) .. "' default was not in Options")
		self.Value = self.Options[1]
	end

	local theme = self.Theme
	local utility = self.Utility
	local compact = section.Compact == true
	self.BaseHeight = compact and 50 or 58
	self.ListTop = compact and 56 or 64
	self.OptionHeight = compact and 24 or 28
	self.OptionStep = compact and 28 or 32
	self.SearchHeight = compact and 28 or 32

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, self.BaseHeight),
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
		TextSize = compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	local button = utility:Create("TextButton", {
		Name = "Button",
		Position = UDim2.fromOffset(0, compact and 21 or 24),
		Size = UDim2.new(1, 0, 0, compact and 29 or 34),
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
		TextSize = compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = button,
	})

	local arrow = utility:Create("TextLabel", {
		Name = "Arrow",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		Size = UDim2.fromOffset(20, compact and 29 or 34),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "v",
		TextColor3 = theme.Accent,
		TextSize = 12,
		Parent = button,
	})

	local list = utility:Create("Frame", {
		Name = "List",
		Position = UDim2.fromOffset(0, self.ListTop),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = theme.Background,
		ClipsDescendants = true,
		Parent = frame,
	})
	utility:Corner(list, 8)
	utility:Stroke(list, theme.Stroke, 0.5)
	utility:Padding(list, { All = 4 })

	local searchBox = utility:Create("TextBox", {
		Name = "Search",
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, -8, 0, self.SearchHeight),
		BackgroundColor3 = theme.Card,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = "Filter options...",
		PlaceholderColor3 = theme.MutedText,
		Text = "",
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = self.SearchEnabled,
		Parent = list,
	})
	utility:Corner(searchBox, 6)
	utility:Stroke(searchBox, theme.Stroke, 0.5)
	utility:Padding(searchBox, { X = 9 })

	local scroll = utility:Create("ScrollingFrame", {
		Name = "Options",
		Size = UDim2.new(1, -8, 1, self.SearchEnabled and -(self.SearchHeight + 12) or -8),
		Position = UDim2.fromOffset(4, self.SearchEnabled and (self.SearchHeight + 8) or 4),
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
	self.SearchBox = searchBox
	self.Scroll = scroll
	self.OptionLayout = optionLayout
	self.CanvasConnection = utility:BindCanvas(scroll, optionLayout, 4)
	self.OptionButtons = {}

	for _, option in ipairs(self.Options) do
		self:_addOption(option)
	end

	utility:Connect(self.Connections, searchBox:GetPropertyChangedSignal("Text"), function()
		self:_FilterOptions(searchBox.Text)
	end)

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

function Dropdown:_ResizeExpanded(instant)
	local maxVisible = math.max(self.MaxVisibleOptions, 1)
	local optionHeight = math.min(#self.FilteredOptions, maxVisible) * self.OptionStep
	local searchHeight = self.SearchEnabled and (self.SearchHeight + 8) or 0
	local height = self.Expanded and optionHeight + searchHeight + 8 or 0
	local frameHeight = self.Expanded and (self.ListTop + height) or self.BaseHeight

	if instant then
		self.List.Size = UDim2.new(1, 0, 0, height)
		self.Instance.Size = UDim2.new(1, 0, 0, frameHeight)
	else
		local style = self.Expanded and Enum.EasingStyle.Back or Enum.EasingStyle.Quad
		self.Utility:Tween(self.List, self.Utility.Motion.Standard, { Size = UDim2.new(1, 0, 0, height) }, style)
		self.Utility:Tween(self.Instance, self.Utility.Motion.Standard, { Size = UDim2.new(1, 0, 0, frameHeight) }, style)
	end
end

function Dropdown:_SetKeyboardSelection(index)
	if #self.FilteredOptions == 0 then
		self.SelectedIndex = 0
	else
		self.SelectedIndex = math.clamp(index or 1, 1, #self.FilteredOptions)
	end

	for _, item in ipairs(self.OptionButtons) do
		local active = item.Value == self.Value
		local highlighted = self.FilteredOptions[self.SelectedIndex] == item
		item.Button.BackgroundTransparency = active and 0 or (highlighted and 0.25 or 1)
		item.Button.TextColor3 = (active or highlighted) and self.Theme.Text or self.Theme.MutedText
	end
end

function Dropdown:_FilterOptions(query)
	if self.Destroyed then
		return
	end

	query = string.lower(tostring(query or ""))
	table.clear(self.FilteredOptions)
	for _, item in ipairs(self.OptionButtons) do
		local visible = query == "" or string.find(string.lower(tostring(item.Value)), query, 1, true) ~= nil
		item.Button.Visible = visible
		if visible then
			table.insert(self.FilteredOptions, item)
		end
	end
	self:_SetKeyboardSelection(1)
	if self.Expanded then
		self:_ResizeExpanded(true)
	end
end

function Dropdown:_EndInteraction()
	self.Utility:DisconnectAll(self.InteractionConnections)
end

function Dropdown:_BeginInteraction()
	self:_EndInteraction()
	self.Utility:Connect(self.InteractionConnections, game:GetService("UserInputService").InputBegan, function(input)
		if not self.Expanded or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if input.KeyCode == Enum.KeyCode.Escape then
			self:SetExpanded(false)
		elseif input.KeyCode == Enum.KeyCode.Down then
			self:_SetKeyboardSelection(math.min(self.SelectedIndex + 1, #self.FilteredOptions))
		elseif input.KeyCode == Enum.KeyCode.Up then
			self:_SetKeyboardSelection(math.max(self.SelectedIndex - 1, 1))
		elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
			local item = self.FilteredOptions[self.SelectedIndex]
			if item then
				if self.Flag then
					self.Library:SetFlag(self.Flag, item.Value, true)
				else
					self:SetValue(item.Value, true)
				end
				self:SetExpanded(false)
			end
		end
	end)
end

function Dropdown:_addOption(option)
	local text = tostring(option)
	local utility = self.Utility
	local theme = self.Theme

	local button = utility:Create("TextButton", {
		Name = text,
		Size = UDim2.new(1, 0, 0, self.OptionHeight),
		BackgroundColor3 = theme.Card,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = text,
		TextColor3 = theme.MutedText,
		TextSize = self.Section.Compact and 12 or 13,
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

	local expanded = value == true and self.Enabled ~= false
	if expanded and self.Library._expandedDropdown and self.Library._expandedDropdown ~= self then
		self.Library._expandedDropdown:SetExpanded(false, true)
	end
	self.Expanded = expanded
	if self.Expanded then
		self.Library._expandedDropdown = self
		self.SearchBox.Text = ""
		self:_FilterOptions("")
		self:_BeginInteraction()
		if self.SearchEnabled then
			task.defer(function()
				if self.Expanded and self.SearchBox and self.SearchBox.Parent then
					self.SearchBox:CaptureFocus()
				end
			end)
		end
	else
		if self.Library._expandedDropdown == self then
			self.Library._expandedDropdown = nil
		end
		self:_EndInteraction()
		if self.SearchBox:IsFocused() then
			self.SearchBox:ReleaseFocus()
		end
		self.SearchBox.Text = ""
		self:_FilterOptions("")
	end

	self.Arrow.Text = self.Expanded and "^" or "v"
	self.Scroll.CanvasPosition = Vector2.new(0, 0)
	self:_ResizeExpanded(instant)
	return self
end

function Dropdown:SetValue(value, fireCallback)
	if self.Destroyed then
		return self
	end

	if value ~= nil and not table.find(self.Options, value) then
		self.Library:_Warn("Dropdown", "'" .. self.Name .. "' ignored invalid value '" .. tostring(value) .. "'")
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
	self:_SetKeyboardSelection(self.SelectedIndex)

	if changed and fireCallback ~= false then
		self.Library:_InvokeCallback("Dropdown", self.Callback, self.Value)
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
	if self.Destroyed then
		return self
	end

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
		self.Library:_Warn("Dropdown", "'" .. self.Name .. "' SetOptions ignored: options must be a table")
		return self
	end

	for _, item in ipairs(self.OptionButtons) do
		if item.Button then
			item.Button:Destroy()
		end
	end

	table.clear(self.OptionButtons)
	self.Options = options
	if self.SearchAutomatic then
		self.SearchEnabled = #options >= self.SearchThreshold
	end
	self.SearchBox.Visible = self.SearchEnabled
	self.Scroll.Position = UDim2.fromOffset(4, self.SearchEnabled and (self.SearchHeight + 8) or 4)
	self.Scroll.Size = UDim2.new(1, -8, 1, self.SearchEnabled and -(self.SearchHeight + 12) or -8)

	for _, option in ipairs(self.Options) do
		self:_addOption(option)
	end
	self:_FilterOptions("")

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
	self.SearchBox.BackgroundColor3 = theme.Card
	self.SearchBox.TextColor3 = theme.Text
	self.SearchBox.PlaceholderColor3 = theme.MutedText
	self.Scroll.ScrollBarImageColor3 = theme.Accent

	for _, item in ipairs(self.OptionButtons) do
		item.Button.BackgroundColor3 = theme.Card
	end

	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	self:SetValue(self.Value, false)
	self:SetEnabled(self.Enabled)
	return self
end

function Dropdown:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Library:_UnregisterDependencies(self)
	self.Context.Flags:Unregister(self.Library, self.Flag, self)
	self:_EndInteraction()
	if self.Library._expandedDropdown == self then
		self.Library._expandedDropdown = nil
	end

	if self.CanvasConnection then
		self.CanvasConnection:Disconnect()
		self.CanvasConnection = nil
	end

	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return Dropdown
