local Section = {}
Section.__index = Section

function Section.new(context, tab, options)
	if typeof(options) ~= "table" then
		options = { Name = options }
	end
	local template = tab.Window.Template or context.Templates.Registry.Default
	local compact = template.Compact
	if options.Compact ~= nil then
		compact = options.Compact == true
	end
	local self = setmetatable({
		Context = context,
		Tab = tab,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or "Section"),
		Template = template,
		Compact = compact,
		Elements = {},
	}, Section)

	local theme = self.Theme
	local utility = self.Utility

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Card,
		BackgroundTransparency = template.SectionTransparency,
		ClipsDescendants = false,
		Parent = tab.Page,
	})
	utility:Corner(frame, 10)
	utility:Stroke(frame, theme.Stroke, 0.3)
	local gradient = utility:Create("UIGradient", {
		Color = ColorSequence.new(theme.Card, theme.Background),
		Rotation = 90,
		Parent = frame,
	})
	utility:Padding(frame, { X = template.SectionPadding, Y = template.SectionPadding })
	local layout = utility:List(frame, template.SectionSpacing)
	local title = utility:Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, 0, 0, compact and 18 or 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = template.SectionTitleSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local signal = utility:Create("Frame", {
		Name = "Accent",
		Position = UDim2.fromOffset(0, 3),
		Size = UDim2.fromOffset(2, compact and 12 or 14),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Parent = title,
	})
	utility:Corner(signal, 2)
	utility:Padding(title, { Left = 9 })

	self.Frame = frame
	self.TitleLabel = title
	self.Layout = layout
	self.Gradient = gradient
	self.Signal = signal
	self._themeObjects = {
		{ frame, "BackgroundColor3", "Card" },
		{ title, "TextColor3", "Text" },
		{ signal, "BackgroundColor3", "Accent" },
	}

	return self
end

function Section:Set(name)
	return self:Rename(name)
end

function Section:Rename(name)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(name or self.Name)
	self.TitleLabel.Text = self.Name
	return self
end

function Section:_createElement(moduleName, options)
	if self.Destroyed then
		self.Library:_Warn("Lifecycle", "Create" .. moduleName .. " ignored: section is destroyed")
		return nil
	end

	if options ~= nil and typeof(options) ~= "table" then
		self.Library:_Warn("API", "Create" .. moduleName .. " expected an options table")
		options = {}
	end

	local element = self.Context.Elements[moduleName].new(self.Context, self, options or {})
	table.insert(self.Elements, element)
	self.Context.Commands:IndexObject(self.Library, element, moduleName)
	return element
end

function Section:CreateButton(options)
	return self:_createElement("Button", options)
end

function Section:CreateToggle(options)
	return self:_createElement("Toggle", options)
end

function Section:CreateSlider(options)
	return self:_createElement("Slider", options)
end

function Section:CreateDropdown(options)
	return self:_createElement("Dropdown", options)
end

function Section:CreateInput(options)
	return self:_createElement("Input", options)
end

function Section:CreateKeybind(options)
	return self:_createElement("Keybind", options)
end

function Section:CreateParagraph(options)
	if typeof(options) == "string" then
		options = { Text = options }
	end

	return self:_createElement("Paragraph", options)
end

function Section:CreateLabel(text)
	return self:CreateParagraph({ Text = text })
end

function Section:CreateDivider(options)
	return self:_createElement("Divider", options)
end

function Section:CreateProgressBar(options)
	return self:_createElement("ProgressBar", options)
end

function Section:CreateStatCard(options)
	return self:_createElement("StatCard", options)
end

function Section:CreateStatusCard(options)
	return self:CreateStatCard(options)
end

function Section:CreateLogPanel(options)
	return self:_createElement("LogPanel", options)
end

function Section:CreateCallout(options)
	return self:_createElement("Callout", options)
end

function Section:CreateActionRow(options)
	return self:_createElement("ActionRow", options)
end

function Section:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme

	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		if object and object.Parent then
			object[property] = theme[key]
		end
	end
	self.Utility:ApplyStrokeTheme(self.Frame, theme.Stroke)
	self.Gradient.Color = ColorSequence.new(theme.Card, theme.Background)

	for _, element in ipairs(self.Elements) do
		if element.SetTheme then
			element:SetTheme(theme)
		end
	end

	return self
end

function Section:Show()
	if self.Destroyed then
		return self
	end

	if self.Frame then
		self.Frame.Visible = true
	end
	return self
end

function Section:Hide()
	if self.Destroyed then
		return self
	end

	local dropdown = self.Library._expandedDropdown
	if dropdown and dropdown.Section == self then
		dropdown:SetExpanded(false, true)
	end

	if self.Frame then
		self.Frame.Visible = false
	end
	return self
end

function Section:RefreshLayout()
	if self.Destroyed then
		return self
	end

	if self.Tab and self.Tab.RefreshLayout then
		self.Tab:RefreshLayout()
	end
	return self
end

function Section:RemoveElement(element)
	if self.Destroyed then
		return self
	end

	if element and element.Destroy then
		element:Destroy()
	end
	return self
end

function Section:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	for _, element in ipairs(table.clone(self.Elements)) do
		if element.Destroy then
			element:Destroy()
		end
	end

	table.clear(self.Elements)

	if self.Frame then
		self.Frame:Destroy()
	end

	if self.Tab then
		for index = #self.Tab.Sections, 1, -1 do
			if self.Tab.Sections[index] == self then
				table.remove(self.Tab.Sections, index)
			end
		end
	end
	return self
end

return Section
