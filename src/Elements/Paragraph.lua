local Paragraph = {}
Paragraph.__index = Paragraph

function Paragraph.new(context, section, options)
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
	self.Text = text
	self.Instance.Text = text
end

function Paragraph:SetTheme(theme)
	self.Theme = theme
	self.Instance.TextColor3 = theme.MutedText
end

function Paragraph:SetEnabled(enabled)
	self.Instance.TextTransparency = enabled == true and 0 or 0.45
end

function Paragraph:Destroy()
	self.Utility:DisconnectAll(self.Connections)
	self.Instance:Destroy()
end

return Paragraph
