local Callout = {}
Callout.__index = Callout

local function normalizeType(value)
	local kind = string.lower(tostring(value or "Info"))
	if kind == "warning" or kind == "success" or kind == "danger" then
		return kind
	end
	return "info"
end

function Callout.new(context, section, options)
	options = options or {}
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or options.Title or "Information"),
		Content = tostring(options.Content or options.Text or ""),
		Type = normalizeType(options.Type or options.Variant),
		Icon = options.Icon,
		Connections = {},
		Enabled = true,
	}, Callout)

	local compact = section.Compact == true
	local theme = self.Theme
	local utility = self.Utility
	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 58 or 68),
		BackgroundColor3 = theme.Background,
		Parent = section.Frame,
	})
	utility:Corner(frame, 9)
	utility:Stroke(frame, theme.Stroke, 0.55)
	local accent = utility:Create("Frame", {
		Name = "Variant",
		Position = UDim2.fromOffset(0, 7),
		Size = UDim2.new(0, 3, 1, -14),
		Parent = frame,
	})
	utility:Corner(accent, 3)
	local title = utility:Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(13, compact and 7 or 9),
		Size = UDim2.new(1, -24, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local content = utility:Create("TextLabel", {
		Name = "Content",
		Position = UDim2.fromOffset(13, compact and 29 or 33),
		Size = UDim2.new(1, -24, 1, compact and -32 or -38),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Content,
		TextColor3 = theme.MutedText,
		TextSize = compact and 11 or 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = frame,
	})

	self.Instance = frame
	self.Accent = accent
	self.TitleLabel = title
	self.ContentLabel = content
	self:SetType(self.Type)
	self.Library:_BindElement(self, options)
	return self
end

function Callout:_color()
	if self.Type == "warning" then
		return self.Theme.Highlight
	elseif self.Type == "danger" then
		return self.Theme.Danger
	elseif self.Type == "success" then
		return self.Theme.Success
	end
	return self.Theme.Accent
end

function Callout:SetType(value)
	if self.Destroyed then
		return self
	end
	self.Type = normalizeType(value)
	self.Accent.BackgroundColor3 = self:_color()
	return self
end

function Callout:SetContent(text)
	if self.Destroyed then
		return self
	end
	self.Content = tostring(text or "")
	self.ContentLabel.Text = self.Content
	return self
end

function Callout:Set(value)
	return self:SetContent(value)
end

function Callout:SetValue(value)
	return self:SetContent(value)
end

function Callout:GetValue()
	return self.Content
end

function Callout:SetText(text)
	if self.Destroyed then
		return self
	end
	self.Name = tostring(text or "")
	self.TitleLabel.Text = self.Name
	return self
end

function Callout:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end
	self.Enabled = enabled == true
	local transparency = self.Enabled and 0 or 0.45
	self.TitleLabel.TextTransparency = transparency
	self.ContentLabel.TextTransparency = transparency
	self.Accent.BackgroundTransparency = self.Enabled and 0 or 0.5
	self.Instance.BackgroundTransparency = self.Enabled and 0 or 0.35
	return self
end

function Callout:Enable()
	return self:SetEnabled(true)
end

function Callout:Disable()
	return self:SetEnabled(false)
end

function Callout:SetVisible(visible)
	if not self.Destroyed then
		self.Library:_SetElementVisible(self, visible == true)
	end
	return self
end

function Callout:Show()
	return self:SetVisible(true)
end

function Callout:Hide()
	return self:SetVisible(false)
end

function Callout:Refresh()
	if not self.Destroyed then
		self:SetTheme(self.Theme)
	end
	return self
end

function Callout:SetTheme(theme)
	if self.Destroyed then
		return self
	end
	self.Theme = theme
	self.Instance.BackgroundColor3 = theme.Background
	self.TitleLabel.TextColor3 = theme.Text
	self.ContentLabel.TextColor3 = theme.MutedText
	self.Accent.BackgroundColor3 = self:_color()
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	return self:SetEnabled(self.Enabled)
end

function Callout:Destroy()
	if self.Destroyed then
		return self
	end
	self.Destroyed = true
	self.Library:_UnregisterDependencies(self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return Callout
