local Paragraph = {}
Paragraph.__index = Paragraph

function Paragraph.new(context, section, options)
	options = options or {}
	local text = options.Text or options.Content or options.Name or "Paragraph"
	local self = setmetatable({
		Context = context,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Text = text,
		Connections = {},
	}, Paragraph)

	local label = self.Utility:Create("TextLabel", {
		Name = "Paragraph",
		Size = UDim2.new(1, 0, 0, options.Height or 28),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = text,
		TextColor3 = self.Theme.MutedText,
		TextSize = options.TextSize or 13,
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

	self.Text = text
	self.Instance.Text = text
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
	return self
end

function Paragraph:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Instance.TextTransparency = enabled == true and 0 or 0.45
	return self
end

function Paragraph:Refresh()
	return self:Set(self.Text)
end

function Paragraph:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
end

return Paragraph
