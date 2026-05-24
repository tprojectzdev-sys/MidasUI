local StatCard = {}
StatCard.__index = StatCard

function StatCard.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "StatCard ignored an invalid Flag value")
		flag = nil
	end

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or options.Title or "Status"),
		Value = tostring(options.Default ~= nil and options.Default or (options.Value ~= nil and options.Value or "Idle")),
		Icon = options.Icon,
		Flag = flag,
		Connections = {},
		Enabled = true,
	}, StatCard)

	local compact = section.Compact == true
	local dashboard = section.Template and section.Template.Dashboard
	local height = compact and 42 or (dashboard and 54 or 48)
	local theme = self.Theme
	local utility = self.Utility
	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = theme.Background,
		Parent = section.Frame,
	})
	utility:Corner(frame, 9)
	utility:Stroke(frame, theme.Stroke, 0.55)
	local icon = utility:Create("TextLabel", {
		Name = "Icon",
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.fromOffset(options.Icon and 24 or 0, height),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = options.Icon and utility:IconText(options.Icon) or "",
		TextColor3 = theme.Accent,
		TextSize = 14,
		Parent = frame,
	})
	local left = options.Icon and 43 or 12
	local label = utility:Create("TextLabel", {
		Name = "Label",
		Position = UDim2.fromOffset(left, compact and 4 or 6),
		Size = UDim2.new(0.52, -left, 0, 17),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Name,
		TextColor3 = theme.MutedText,
		TextSize = compact and 11 or 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local value = utility:Create("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0.48, -12, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = self.Value,
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = frame,
	})

	self.Instance = frame
	self.IconLabel = icon
	self.Label = label
	self.ValueLabel = value

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value)
	self.Library:_BindElement(self, options)
	return self
end

function StatCard:GetValue()
	return self.Value
end

function StatCard:SetValue(value)
	if self.Destroyed then
		return self
	end
	self.Value = tostring(value or "")
	self.ValueLabel.Text = self.Value
	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end
	return self
end

function StatCard:Set(value)
	return self:SetValue(value)
end

function StatCard:SetText(text)
	if self.Destroyed then
		return self
	end
	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function StatCard:SetIcon(icon)
	if self.Destroyed then
		return self
	end
	self.Icon = icon
	self.IconLabel.Text = icon and self.Utility:IconText(icon) or ""
	return self
end

function StatCard:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end
	self.Enabled = enabled == true
	local transparency = self.Enabled and 0 or 0.45
	self.Label.TextTransparency = transparency
	self.ValueLabel.TextTransparency = transparency
	self.IconLabel.TextTransparency = transparency
	self.Instance.BackgroundTransparency = self.Enabled and 0 or 0.32
	return self
end

function StatCard:Enable()
	return self:SetEnabled(true)
end

function StatCard:Disable()
	return self:SetEnabled(false)
end

function StatCard:SetVisible(visible)
	if not self.Destroyed then
		self.Library:_SetElementVisible(self, visible == true)
	end
	return self
end

function StatCard:Show()
	return self:SetVisible(true)
end

function StatCard:Hide()
	return self:SetVisible(false)
end

function StatCard:Refresh()
	if not self.Destroyed then
		self:SetValue(self.Value)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function StatCard:SetTheme(theme)
	if self.Destroyed then
		return self
	end
	self.Theme = theme
	self.Instance.BackgroundColor3 = theme.Background
	self.IconLabel.TextColor3 = theme.Accent
	self.Label.TextColor3 = theme.MutedText
	self.ValueLabel.TextColor3 = theme.Text
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	return self:SetEnabled(self.Enabled)
end

function StatCard:Destroy()
	if self.Destroyed then
		return self
	end
	self.Destroyed = true
	self.Library:_UnregisterDependencies(self)
	self.Context.Flags:Unregister(self.Library, self.Flag, self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return StatCard
