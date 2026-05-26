local Input = {}
Input.__index = Input

function Input.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "Input ignored an invalid Flag value")
		flag = nil
	end

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or "Input"),
		Flag = flag,
		Value = options.Default or "",
		Placeholder = tostring(options.Placeholder or ""),
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
		Connections = {},
		Tweens = {},
		Enabled = true,
	}, Input)

	local theme = self.Theme
	local utility = self.Utility
	local compact = section.Compact == true

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 52 or 62),
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
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	local box = utility:Create("TextBox", {
		Name = "Box",
		Position = UDim2.fromOffset(0, compact and 21 or 26),
		Size = UDim2.new(1, 0, 0, compact and 30 or 34),
		BackgroundColor3 = theme.Background,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = self.Placeholder,
		PlaceholderColor3 = theme.MutedText,
		Text = tostring(self.Value),
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	utility:Corner(box, 8)
	local boxStroke = utility:Stroke(box, theme.Stroke, 0.5)
	utility:Padding(box, { X = 10 })

	self.Instance = frame
	self.Label = label
	self.Box = box
	self.BoxStroke = boxStroke

	utility:Connect(self.Connections, box.FocusLost, function()
		if self.Enabled == false then
			return
		end

		if self.Flag then
			self.Library:SetFlag(self.Flag, box.Text, true)
		else
			self:SetValue(box.Text, true)
		end
	end)

	utility:Connect(self.Connections, box.Focused, function()
		if self.Enabled == false then
			return
		end

		utility:TweenTracked(self.Tweens, "Focus", box, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Topbar })
		boxStroke.Color = self.Theme.Accent
		boxStroke.Transparency = 0.1
	end)

	utility:Connect(self.Connections, box.FocusLost, function()
		utility:TweenTracked(self.Tweens, "Focus", box, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Background })
		boxStroke.Color = self.Theme.Stroke
		boxStroke.Transparency = 0.5
	end)

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)
	self.Library:_BindElement(self, options)

	return self
end

function Input:GetValue()
	return self.Value
end

function Input:SetValue(value, fireCallback)
	if self.Destroyed then
		return self
	end

	local nextValue = tostring(value or "")
	local changed = self.Value ~= nextValue
	self.Value = nextValue

	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	if self.Box.Text ~= self.Value then
		self.Box.Text = self.Value
	end

	if changed and fireCallback ~= false then
		self.Library:_InvokeCallback("Input", self.Callback, self.Value)
	end
	return self
end

function Input:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Box.TextEditable = self.Enabled
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.Label.TextColor3 = self.Enabled and self.Theme.Text or self.Theme.MutedText
	self.Box.TextTransparency = self.Enabled and 0 or 0.45
	self.Box.BackgroundTransparency = self.Enabled and 0 or 0.35
	return self
end

function Input:Enable()
	return self:SetEnabled(true)
end

function Input:Disable()
	return self:SetEnabled(false)
end

function Input:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Library:_SetElementVisible(self, visible == true)
	return self
end

function Input:Show()
	return self:SetVisible(true)
end

function Input:Hide()
	return self:SetVisible(false)
end

function Input:SetText(text)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function Input:SetPlaceholder(placeholder)
	if self.Destroyed then
		return self
	end

	self.Placeholder = tostring(placeholder or "")
	self.Box.PlaceholderText = self.Placeholder
	return self
end

function Input:SetCallback(callback)
	if self.Destroyed then
		return self
	end

	self.Callback = typeof(callback) == "function" and callback or function() end
	return self
end

function Input:Set(value, fireCallback)
	return self:SetValue(value, fireCallback)
end

function Input:Refresh()
	if not self.Destroyed then
		self:SetValue(self.Value, false)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function Input:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Label.TextColor3 = theme.Text
	self.Box.BackgroundColor3 = theme.Background
	self.Box.TextColor3 = theme.Text
	self.Box.PlaceholderColor3 = theme.MutedText
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	if self.Box:IsFocused() then
		self.BoxStroke.Color = theme.Accent
	end
	self:SetEnabled(self.Enabled)
	return self
end

function Input:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Utility:CancelTweens(self.Tweens)
	self.Library:_UnregisterDependencies(self)
	self.Context.Flags:Unregister(self.Library, self.Flag, self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return Input
