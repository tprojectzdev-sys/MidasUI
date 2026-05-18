local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(context, section, options)
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = options.Name or "Toggle",
		Flag = options.Flag,
		Value = options.Default == true,
		Callback = options.Callback or function() end,
		Connections = {},
		Enabled = true,
	}, Toggle)

	local theme = self.Theme
	local utility = self.Utility

	local row = utility:Create("TextButton", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 38),
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
		TextSize = 13,
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

		utility:Tween(label, 0.12, { TextColor3 = self.Theme.Accent })
	end)

	utility:Connect(self.Connections, row.MouseLeave, function()
		if self.Enabled == false then
			return
		end

		utility:Tween(label, 0.12, { TextColor3 = self.Theme.Text })
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
	local nextValue = value == true
	local changed = self.Value ~= nextValue
	self.Value = nextValue

	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	local theme = self.Theme
	self.Utility:Tween(self.Track, 0.16, {
		BackgroundColor3 = self.Value and theme.Accent or theme.Background,
	})
	self.Utility:Tween(self.Knob, 0.16, {
		Position = self.Value and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
		BackgroundColor3 = self.Value and theme.Text or theme.MutedText,
	})

	if changed and fireCallback ~= false then
		task.spawn(self.Callback, self.Value)
	end
end

function Toggle:SetEnabled(enabled)
	self.Enabled = enabled == true
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.Label.TextColor3 = self.Enabled and self.Theme.Text or self.Theme.MutedText
	self.Track.BackgroundTransparency = self.Enabled and 0 or 0.35
	self.Knob.BackgroundTransparency = self.Enabled and 0 or 0.35
end

function Toggle:SetTheme(theme)
	self.Theme = theme
	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		object[property] = theme[key]
	end
	self:SetValue(self.Value, false)
end

function Toggle:Destroy()
	self.Utility:DisconnectAll(self.Connections)
	self.Instance:Destroy()
end

return Toggle
