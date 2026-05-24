local LogPanel = {}
LogPanel.__index = LogPanel

local function normalizeType(value)
	local kind = string.lower(tostring(value or "Info"))
	if kind == "warning" or kind == "error" or kind == "success" then
		return kind
	end
	return "info"
end

function LogPanel.new(context, section, options)
	options = options or {}
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or options.Title or "Recent Events"),
		MaxLines = math.clamp(tonumber(options.MaxLines) or 20, 1, 100),
		Lines = {},
		Connections = {},
		Enabled = true,
	}, LogPanel)

	local compact = section.Compact == true
	local utility = self.Utility
	local theme = self.Theme
	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, tonumber(options.Height) or (compact and 130 or 158)),
		BackgroundColor3 = theme.Background,
		Parent = section.Frame,
	})
	utility:Corner(frame, 9)
	utility:Stroke(frame, theme.Stroke, 0.55)
	local title = utility:Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -24, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local scroll = utility:Create("ScrollingFrame", {
		Name = "Entries",
		Position = UDim2.fromOffset(10, 32),
		Size = UDim2.new(1, -20, 1, -40),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = 0.25,
		Parent = frame,
	})
	local layout = utility:List(scroll, compact and 3 or 4)

	self.Instance = frame
	self.TitleLabel = title
	self.Scroll = scroll
	self.Layout = layout
	self.CanvasConnection = utility:BindCanvas(scroll, layout, 4)

	if typeof(options.Lines) == "table" then
		for _, line in ipairs(options.Lines) do
			if typeof(line) == "table" then
				self:AddLine(line.Text or line[1], line.Type or line[2])
			else
				self:AddLine(line)
			end
		end
	end

	self.Library:_BindElement(self, options)
	return self
end

function LogPanel:_color(kind)
	if kind == "warning" then
		return self.Theme.Highlight
	elseif kind == "error" then
		return self.Theme.Danger
	elseif kind == "success" then
		return self.Theme.Success
	end
	return self.Theme.MutedText
end

function LogPanel:AddLine(text, lineType)
	if self.Destroyed then
		return self
	end
	local kind = normalizeType(lineType)
	local label = self.Utility:Create("TextLabel", {
		Name = "Line",
		Size = UDim2.new(1, -8, 0, self.Section.Compact and 17 or 19),
		BackgroundTransparency = 1,
		Font = Enum.Font.Code,
		Text = tostring(text or ""),
		TextColor3 = self:_color(kind),
		TextSize = self.Section.Compact and 11 or 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Scroll,
	})
	table.insert(self.Lines, { Label = label, Type = kind })
	while #self.Lines > self.MaxLines do
		local first = table.remove(self.Lines, 1)
		if first.Label then
			first.Label:Destroy()
		end
	end
	task.defer(function()
		if not self.Destroyed and self.Scroll.Parent then
			local bottom = math.max(self.Scroll.CanvasSize.Y.Offset - self.Scroll.AbsoluteSize.Y, 0)
			self.Scroll.CanvasPosition = Vector2.new(0, bottom)
		end
	end)
	return self
end

function LogPanel:Log(text, lineType)
	return self:AddLine(text, lineType)
end

function LogPanel:Clear()
	if self.Destroyed then
		return self
	end
	for _, line in ipairs(self.Lines) do
		if line.Label then
			line.Label:Destroy()
		end
	end
	table.clear(self.Lines)
	self.Scroll.CanvasPosition = Vector2.new(0, 0)
	return self
end

function LogPanel:GetValue()
	return #self.Lines
end

function LogPanel:SetText(text)
	if self.Destroyed then
		return self
	end
	self.Name = tostring(text or "")
	self.TitleLabel.Text = self.Name
	return self
end

function LogPanel:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end
	self.Enabled = enabled == true
	self.TitleLabel.TextTransparency = self.Enabled and 0 or 0.45
	self.Instance.BackgroundTransparency = self.Enabled and 0 or 0.35
	for _, line in ipairs(self.Lines) do
		line.Label.TextTransparency = self.Enabled and 0 or 0.45
	end
	return self
end

function LogPanel:Enable()
	return self:SetEnabled(true)
end

function LogPanel:Disable()
	return self:SetEnabled(false)
end

function LogPanel:SetVisible(visible)
	if not self.Destroyed then
		self.Library:_SetElementVisible(self, visible == true)
	end
	return self
end

function LogPanel:Show()
	return self:SetVisible(true)
end

function LogPanel:Hide()
	return self:SetVisible(false)
end

function LogPanel:Refresh()
	if not self.Destroyed then
		self:SetTheme(self.Theme)
	end
	return self
end

function LogPanel:SetTheme(theme)
	if self.Destroyed then
		return self
	end
	self.Theme = theme
	self.Instance.BackgroundColor3 = theme.Background
	self.TitleLabel.TextColor3 = theme.Text
	self.Scroll.ScrollBarImageColor3 = theme.Accent
	for _, line in ipairs(self.Lines) do
		line.Label.TextColor3 = self:_color(line.Type)
	end
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	return self:SetEnabled(self.Enabled)
end

function LogPanel:Destroy()
	if self.Destroyed then
		return self
	end
	self.Destroyed = true
	self.Library:_UnregisterDependencies(self)
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

return LogPanel
