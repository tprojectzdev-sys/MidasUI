local Section = {}
Section.__index = Section

function Section.new(context, tab, name)
	local self = setmetatable({
		Context = context,
		Tab = tab,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = name or "Section",
		Elements = {},
	}, Section)

	local theme = self.Theme
	local utility = self.Utility

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Card,
		ClipsDescendants = false,
		Parent = tab.Page,
	})
	utility:Corner(frame, 10)
	utility:Stroke(frame, theme.Stroke, 0.3)
	utility:Padding(frame, { X = 12, Y = 12 })
	local layout = utility:List(frame, 8)

	local title = utility:Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	self.Frame = frame
	self.TitleLabel = title
	self.Layout = layout
	self._themeObjects = {
		{ frame, "BackgroundColor3", "Card" },
		{ title, "TextColor3", "Text" },
	}

	return self
end

function Section:Set(name)
	self.Name = name
	self.TitleLabel.Text = name
end

function Section:_createElement(moduleName, options)
	local element = self.Context.Elements[moduleName].new(self.Context, self, options or {})
	table.insert(self.Elements, element)
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

function Section:SetTheme(theme)
	self.Theme = theme

	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		if object and object.Parent then
			object[property] = theme[key]
		end
	end

	for _, element in ipairs(self.Elements) do
		if element.SetTheme then
			element:SetTheme(theme)
		end
	end
end

function Section:Destroy()
	for _, element in ipairs(self.Elements) do
		if element.Destroy then
			element:Destroy()
		end
	end

	table.clear(self.Elements)

	if self.Frame then
		self.Frame:Destroy()
	end
end

return Section
