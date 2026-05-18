local Input = {}
Input.__index = Input

function Input.new(context, section, options)
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = options.Name or "Input",
		Flag = options.Flag,
		Value = options.Default or "",
		Placeholder = options.Placeholder or "",
		Callback = options.Callback or function() end,
		Connections = {},
	}, Input)

	local theme = self.Theme
	local utility = self.Utility

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 62),
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

	local box = utility:Create("TextBox", {
		Name = "Box",
		Position = UDim2.fromOffset(0, 26),
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = theme.Background,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = self.Placeholder,
		PlaceholderColor3 = theme.MutedText,
		Text = tostring(self.Value),
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	utility:Corner(box, 8)
	utility:Stroke(box, theme.Stroke, 0.5)
	utility:Padding(box, { X = 10 })

	self.Instance = frame
	self.Label = label
	self.Box = box

	utility:Connect(self.Connections, box.FocusLost, function()
		if self.Flag then
			self.Library:SetFlag(self.Flag, box.Text, true)
		else
			self:SetValue(box.Text, true)
		end
	end)

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)

	return self
end

function Input:GetValue()
	return self.Value
end

function Input:SetValue(value, fireCallback)
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
		task.spawn(self.Callback, self.Value)
	end
end

function Input:SetTheme(theme)
	self.Theme = theme
	self.Label.TextColor3 = theme.Text
	self.Box.BackgroundColor3 = theme.Background
	self.Box.TextColor3 = theme.Text
	self.Box.PlaceholderColor3 = theme.MutedText
end

function Input:Destroy()
	self.Utility:DisconnectAll(self.Connections)
	self.Instance:Destroy()
end

return Input
