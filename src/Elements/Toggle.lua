local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "Toggle ignored an invalid Flag value")
		flag = nil
	end

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or "Toggle"),
		Flag = flag,
		Value = options.Default == true,
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
		Connections = {},
		Tweens = {},
		Enabled = true,
	}, Toggle)

	local theme = self.Theme
	local utility = self.Utility
	local compact = section.Compact == true

	local row = utility:Create("TextButton", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 32 or 38),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = section.Frame,
	})

	local label = utility:Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, -58, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local track = utility:Create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(42, 22),
		BackgroundColor3 = theme.Background,
		Parent = row,
	})
	utility:Corner(track, 12)
	utility:Stroke(track, theme.Stroke, 0.4)

	local knob = utility:Create("Frame", {
		Name = "Knob",
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = theme.MutedText,
		Parent = track,
	})
	utility:Corner(knob, 10)

	self.Instance = row
	self.Label = label
	self.Track = track
	self.Knob = knob
	self._themeObjects = {
		{ label, "TextColor3", "Text" },
	}

	utility:Connect(self.Connections, row.MouseButton1Click, function()
		if self.Enabled == false then
			return
		end

		if self.Flag then
			self.Library:SetFlag(self.Flag, not self.Value, true)
		else
			self:SetValue(not self.Value, true)
		end
	end)

	utility:Connect(self.Connections, row.MouseEnter, function()
		if self.Enabled == false then
			return
		end

		utility:TweenTracked(self.Tweens, "Label", label, utility.Motion.Hover, { TextColor3 = self.Theme.Accent })
	end)

	utility:Connect(self.Connections, row.MouseLeave, function()
		if self.Enabled == false then
			return
		end

		utility:TweenTracked(self.Tweens, "Label", label, utility.Motion.Hover, { TextColor3 = self.Theme.Text })
	end)

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)
	self.Library:_BindElement(self, options)

	return self
end

function Toggle:GetValue()
	return self.Value
end

function Toggle:SetValue(value, fireCallback)
	if self.Destroyed then
		return self
	end

	if typeof(value) ~= "boolean" then
		self.Library:_Warn("Toggle", "'" .. self.Name .. "' ignored a non-boolean value")
		return self
	end

	local nextValue = value
	local changed = self.Value ~= nextValue
	self.Value = nextValue

	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	local theme = self.Theme
	self.Utility:TweenTracked(self.Tweens, "Track", self.Track, self.Utility.Motion.Toggle, {
		BackgroundColor3 = self.Value and theme.Accent or theme.Background,
	})
	self.Utility:TweenTracked(self.Tweens, "Knob", self.Knob, self.Utility.Motion.Toggle, {
		Position = self.Value and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
		BackgroundColor3 = self.Value and theme.Text or theme.MutedText,
	})

	if changed and fireCallback ~= false then
		self.Library:_InvokeCallback("Toggle", self.Callback, self.Value)
	end

	return self
end

function Toggle:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.Label.TextColor3 = self.Enabled and self.Theme.Text or self.Theme.MutedText
	self.Track.BackgroundTransparency = self.Enabled and 0 or 0.35
	self.Knob.BackgroundTransparency = self.Enabled and 0 or 0.35
	return self
end

function Toggle:Enable()
	return self:SetEnabled(true)
end

function Toggle:Disable()
	return self:SetEnabled(false)
end

function Toggle:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Library:_SetElementVisible(self, visible == true)
	return self
end

function Toggle:Show()
	return self:SetVisible(true)
end

function Toggle:Hide()
	return self:SetVisible(false)
end

function Toggle:SetText(text)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function Toggle:SetCallback(callback)
	if self.Destroyed then
		return self
	end

	self.Callback = typeof(callback) == "function" and callback or function() end
	return self
end

function Toggle:Set(value, fireCallback)
	return self:SetValue(value, fireCallback)
end

function Toggle:Refresh()
	if not self.Destroyed then
		self:SetValue(self.Value, false)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function Toggle:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		object[property] = theme[key]
	end
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	self:SetValue(self.Value, false)
	self:SetEnabled(self.Enabled)
	return self
end

function Toggle:Destroy()
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

return Toggle
