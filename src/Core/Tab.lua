local Tab = {}
Tab.__index = Tab

function Tab.new(context, window, options)
	options = typeof(options) == "table" and options or {}
	local self = setmetatable({
		Context = context,
		Window = window,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or "Tab"),
		Icon = options.Icon or "",
		Sections = {},
		Connections = {},
		Tweens = {},
	}, Tab)

	local theme = self.Theme
	local utility = self.Utility
	local template = window.Template or context.Templates.Registry.Default

	local button = utility:Create("TextButton", {
		Name = self.Name .. "Tab",
		Size = UDim2.new(1, 0, 0, template.Compact and 33 or 38),
		BackgroundColor3 = theme.Card,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "",
		AutoButtonColor = false,
		Parent = window.TabList,
	})
	utility:Corner(button, 8)

	local icon = utility:CreateIcon(button, self.Icon, {
		Name = "Icon",
		Position = UDim2.fromOffset(10, template.Compact and 6 or 8),
		Size = UDim2.fromOffset(22, template.Compact and 21 or 22),
		Color = theme.MutedText,
		TextSize = template.Compact and 12 or 13,
	})

	local label = utility:Create("TextLabel", {
		Name = "Label",
		Position = UDim2.fromOffset(38, 0),
		Size = UDim2.new(1, -44, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = self.Name,
		TextColor3 = theme.MutedText,
		TextSize = template.Compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = button,
	})

	local page = utility:Create("ScrollingFrame", {
		Name = self.Name .. "Page",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = 0.25,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = false,
		Parent = window.Content,
	})
	utility:Padding(page, { X = template.PagePadding, Y = template.PagePadding })
	local pageList = utility:List(page, template.PageSpacing)

	self.Button = button
	self.IconLabel = icon
	self.Label = label
	self.Page = page
	self.PageList = pageList
	self.CanvasPadding = template.CanvasPadding
	self.CanvasConnection = utility:BindCanvas(page, pageList, self.CanvasPadding)
	self._themeObjects = {
		{ button, "BackgroundColor3", "Card" },
		{ label, "TextColor3", "MutedText" },
	}

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		window:SelectTab(self)
	end)
	utility:Connect(self.Connections, button.MouseEnter, function()
		if window.ActiveTab ~= self then
			utility:TweenTracked(self.Tweens, "Surface", button, utility.Motion.Hover, { BackgroundTransparency = 0.55 })
		end
	end)
	utility:Connect(self.Connections, button.MouseLeave, function()
		if window.ActiveTab ~= self then
			utility:TweenTracked(self.Tweens, "Surface", button, utility.Motion.Hover, { BackgroundTransparency = 1 })
		end
	end)

	return self
end

function Tab:CreateSection(options)
	if self.Destroyed then
		self.Library:_Warn("Lifecycle", "CreateSection ignored: tab is destroyed")
		return nil
	end

	local section = self.Context.Section.new(self.Context, self, options)
	table.insert(self.Sections, section)
	self.Context.Commands:IndexObject(self.Library, section, "Section")
	return section
end

function Tab:SetActive(active)
	if self.Destroyed then
		return self
	end

	self.Page.Visible = active
	self.Utility:TweenTracked(self.Tweens, "Surface", self.Button, self.Utility.Motion.Standard, {
		BackgroundTransparency = active and 0 or 1,
	})
	self.Utility:SetIconColor(self.IconLabel, active and self.Theme.Accent or self.Theme.MutedText)
	self.Label.TextColor3 = active and self.Theme.Text or self.Theme.MutedText
	return self
end

function Tab:Show()
	if self.Destroyed then
		return self
	end

	if self.Button then
		self.Button.Visible = true
	end
	return self
end

function Tab:Hide()
	if self.Destroyed then
		return self
	end

	local dropdown = self.Library._expandedDropdown
	if dropdown and dropdown.Section and dropdown.Section.Tab == self then
		dropdown:SetExpanded(false, true)
	end

	if self.Button then
		self.Button.Visible = false
	end
	if self.Window.ActiveTab == self then
		self.Page.Visible = false
	end
	return self
end

function Tab:Rename(name)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(name or self.Name)
	if self.Label then
		self.Label.Text = self.Name
	end
	return self
end

function Tab:RefreshLayout()
	if self.Destroyed then
		return self
	end

	if self.CanvasConnection and self.PageList then
		self.Page.CanvasSize = UDim2.fromOffset(0, self.PageList.AbsoluteContentSize.Y + self.CanvasPadding)
	end
	return self
end

function Tab:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Page.ScrollBarImageColor3 = theme.Accent

	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		if object and object.Parent then
			object[property] = theme[key]
		end
	end

	self:SetActive(self.Window.ActiveTab == self)

	for _, section in ipairs(self.Sections) do
		section:SetTheme(theme)
	end

	return self
end

function Tab:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Utility:CancelTweens(self.Tweens)
	self.Utility:DisconnectAll(self.Connections)

	if self.CanvasConnection then
		self.CanvasConnection:Disconnect()
		self.CanvasConnection = nil
	end

	for _, section in ipairs(table.clone(self.Sections)) do
		if section.Destroy then
			section:Destroy()
		end
	end

	if self.Page then
		self.Page:Destroy()
	end

	if self.Button then
		self.Button:Destroy()
	end

	for index = #self.Window.Tabs, 1, -1 do
		if self.Window.Tabs[index] == self then
			table.remove(self.Window.Tabs, index)
		end
	end
	if self.Window.ActiveTab == self then
		self.Window.ActiveTab = nil
		for _, tab in ipairs(self.Window.Tabs) do
			if not tab.Destroyed and tab.Button.Visible then
				self.Window:SelectTab(tab)
				break
			end
		end
	end
	return self
end

return Tab
