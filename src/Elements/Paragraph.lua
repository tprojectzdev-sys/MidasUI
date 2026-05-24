local Paragraph = {}
Paragraph.__index = Paragraph

function Paragraph.new(context, section, options)
	options = options or {}
	local text = tostring(options.Text or options.Content or options.Name or "Paragraph")
	local self = setmetatable({
		Context = context,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Text = text,
		Connections = {},
		Enabled = true,
	}, Paragraph)

	local label = self.Utility:Create("TextLabel", {
		Name = "Paragraph",
		Size = UDim2.new(1, 0, 0, options.Height or (section.Compact and 24 or 28)),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = text,
		TextColor3 = self.Theme.MutedText,
		TextSize = options.TextSize or (section.Compact and 12 or 13),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = section.Frame,
	})

	self.Instance = label
	context.Library:_BindElement(self, options)
	return self
end

function Paragraph:Set(text)
	if self.Destroyed then
		return self
	end

	self.Text = tostring(text or "")
	self.Instance.Text = self.Text
	return self
end

function Paragraph:GetValue()
	return self.Text
end

function Paragraph:SetValue(text)
	return self:Set(text)
end

function Paragraph:SetText(text)
	return self:Set(text)
end

function Paragraph:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Context.Library:_SetElementVisible(self, visible == true)
	return self
end

function Paragraph:Show()
	return self:SetVisible(true)
end

function Paragraph:Hide()
	return self:SetVisible(false)
end

function Paragraph:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Instance.TextColor3 = theme.MutedText
	self:SetEnabled(self.Enabled)
	return self
end

function Paragraph:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Instance.TextTransparency = self.Enabled and 0 or 0.45
	return self
end

function Paragraph:Enable()
	return self:SetEnabled(true)
end

function Paragraph:Disable()
	return self:SetEnabled(false)
end

function Paragraph:Refresh()
	if not self.Destroyed then
		self:Set(self.Text)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function Paragraph:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Context.Library:_UnregisterDependencies(self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return Paragraph
