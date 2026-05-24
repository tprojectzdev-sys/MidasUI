local Window = {}
Window.__index = Window

function Window.new(context, options)
	if options ~= nil and typeof(options) ~= "table" then
		context.Library:_Warn("API", "Window.new expected an options table")
		options = {}
	end

	options = options or {}

	local self = setmetatable({
		Context = context,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Tabs = {},
		Connections = {},
		ActiveTab = nil,
		Minimized = false,
		Closed = false,
		Title = tostring(options.Title or options.Name or "MidasUI"),
		Subtitle = tostring(options.Subtitle or ""),
		Icon = options.Icon or "crown",
		SaveConfig = options.SaveConfig == true,
		Resizeable = options.Resizeable ~= false and options.Resizable ~= false,
	}, Window)

	local library = self.Library
	local utility = self.Utility
	local theme = self.Theme
	local size = options.Size
	if size ~= nil and typeof(size) ~= "UDim2" then
		library:_Warn("API", "Window Size must be a UDim2; using the default size")
		size = nil
	end
	size = size or UDim2.fromOffset(620, 460)

	if options.ConfigFolder ~= nil and typeof(options.ConfigFolder) ~= "string" then
		library:_Warn("Config", "ConfigFolder must be a string; using the current folder")
	elseif options.ConfigFolder ~= nil and options.ConfigFolder ~= "" then
		library._configFolder = options.ConfigFolder
	end
	if options.ConfigFile ~= nil and typeof(options.ConfigFile) ~= "string" then
		library:_Warn("Config", "ConfigFile must be a string; using the current legacy filename")
	elseif options.ConfigFile ~= nil and options.ConfigFile ~= "" then
		library._configFile = options.ConfigFile
	end
	library._configFolder = library._configFolder or "Midas"
	library._configFile = library._configFile or "config.json"
	library._activeWindow = self
	library._windowSettings = library._windowSettings or {}

	local gui = utility:Create("ScreenGui", {
		Name = "MidasUI",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = utility:GetGuiParent(),
	})

	local main = utility:Create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size,
		BackgroundColor3 = theme.Background,
		ClipsDescendants = true,
		Parent = gui,
	})
	utility:Corner(main, 12)
	utility:Stroke(main, theme.Stroke, 0.15)
	utility:Create("UISizeConstraint", {
		MinSize = Vector2.new(420, 320),
		MaxSize = Vector2.new(980, 720),
		Parent = main,
	})

	local topbar = utility:Create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = theme.Topbar,
		Parent = main,
	})

	local icon = utility:Create("TextLabel", {
		Name = "Icon",
		Position = UDim2.fromOffset(16, 14),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = theme.Accent,
		Font = Enum.Font.GothamBold,
		Text = utility:IconText(self.Icon),
		TextColor3 = Color3.fromRGB(20, 18, 15),
		TextSize = 15,
		Parent = topbar,
	})
	utility:Corner(icon, 8)

	local title = utility:Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(54, 9),
		Size = UDim2.new(1, -150, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = self.Title,
		TextColor3 = theme.Text,
		TextSize = 16,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topbar,
	})

	local subtitle = utility:Create("TextLabel", {
		Name = "Subtitle",
		Position = UDim2.fromOffset(54, 31),
		Size = UDim2.new(1, -150, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Subtitle,
		TextColor3 = theme.MutedText,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topbar,
	})

	local minimize = utility:Create("TextButton", {
		Name = "Minimize",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -52, 0, 14),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = theme.Card,
		Font = Enum.Font.GothamBold,
		Text = "-",
		TextColor3 = theme.MutedText,
		TextSize = 16,
		AutoButtonColor = false,
		Parent = topbar,
	})
	utility:Corner(minimize, 8)

	local close = utility:Create("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 14),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = theme.Card,
		Font = Enum.Font.GothamBold,
		Text = "x",
		TextColor3 = theme.Danger,
		TextSize = 14,
		AutoButtonColor = false,
		Parent = topbar,
	})
	utility:Corner(close, 8)

	local sidebar = utility:Create("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(0, 56),
		Size = UDim2.new(0, 152, 1, -56),
		BackgroundColor3 = theme.Sidebar,
		Parent = main,
	})

	local tabList = utility:Create("Frame", {
		Name = "TabList",
		Position = UDim2.fromOffset(10, 12),
		Size = UDim2.new(1, -20, 1, -24),
		BackgroundTransparency = 1,
		Parent = sidebar,
	})
	utility:List(tabList, 6)

	local content = utility:Create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(152, 56),
		Size = UDim2.new(1, -152, 1, -56),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = main,
	})

	local resize = utility:Create("TextButton", {
		Name = "Resize",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -6, 1, -6),
		Size = UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "+",
		TextColor3 = theme.MutedText,
		TextSize = 12,
		AutoButtonColor = false,
		Visible = self.Resizeable,
		Parent = main,
	})

	self.Gui = gui
	self.Main = main
	self.Topbar = topbar
	self.TitleLabel = title
	self.SubtitleLabel = subtitle
	self.IconLabel = icon
	self.Sidebar = sidebar
	self.TabList = tabList
	self.Content = content
	self.ResizeButton = resize
	self._restoreSize = size
	self._themeObjects = {
		{ main, "BackgroundColor3", "Background" },
		{ topbar, "BackgroundColor3", "Topbar" },
		{ sidebar, "BackgroundColor3", "Sidebar" },
		{ icon, "BackgroundColor3", "Accent" },
		{ title, "TextColor3", "Text" },
		{ subtitle, "TextColor3", "MutedText" },
		{ minimize, "BackgroundColor3", "Card" },
		{ minimize, "TextColor3", "MutedText" },
		{ close, "BackgroundColor3", "Card" },
		{ close, "TextColor3", "Danger" },
		{ resize, "TextColor3", "MutedText" },
	}

	utility:MakeDraggable(topbar, main, self.Connections, { ClampToViewport = true })

	local resizing = false
	local resizeStart
	local startSize

	utility:Connect(self.Connections, resize.InputBegan, function(input)
		if not self.Resizeable or self.Minimized then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			resizeStart = input.Position
			startSize = main.AbsoluteSize
		end
	end)

	utility:Connect(self.Connections, game:GetService("UserInputService").InputChanged, function(input)
		if not resizing then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - resizeStart
		local width = math.clamp(startSize.X + delta.X, 420, 980)
		local height = math.clamp(startSize.Y + delta.Y, 320, 720)
		main.Size = UDim2.fromOffset(width, height)
		self._restoreSize = main.Size
		library._windowSettings.Size = { X = width, Y = height }
	end)

	utility:Connect(self.Connections, game:GetService("UserInputService").InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = false
		end
	end)

	local camera = workspace.CurrentCamera
	if camera then
		utility:Connect(self.Connections, camera:GetPropertyChangedSignal("ViewportSize"), function()
			utility:ClampToViewport(main)
		end)
	end

	utility:Connect(self.Connections, minimize.MouseButton1Click, function()
		self:SetMinimized(not self.Minimized)
	end)

	utility:Connect(self.Connections, close.MouseButton1Click, function()
		self:Destroy()
	end)

	for _, button in ipairs({ minimize, close }) do
		utility:Connect(self.Connections, button.MouseEnter, function()
			utility:Tween(button, 0.12, { BackgroundColor3 = self.Theme.Background })
		end)

		utility:Connect(self.Connections, button.MouseLeave, function()
			utility:Tween(button, 0.12, { BackgroundColor3 = self.Theme.Card })
		end)
	end

	table.insert(library._windows, self)

	if self.SaveConfig then
		library:LoadConfig()
	end

	return self
end

function Window:CreateTab(options)
	if self.Closed then
		self.Library:_Warn("Lifecycle", "CreateTab ignored: window is destroyed")
		return nil
	end

	if options == nil then
		options = {}
	elseif typeof(options) ~= "table" then
		options = { Name = tostring(options) }
	end
	local tab = self.Context.Tab.new(self.Context, self, options)
	table.insert(self.Tabs, tab)

	if not self.ActiveTab then
		self:SelectTab(tab)
	end

	return tab
end

function Window:SelectTab(tab)
	if self.Closed then
		return self
	end

	if typeof(tab) == "string" then
		for _, item in ipairs(self.Tabs) do
			if item.Name == tab then
				tab = item
				break
			end
		end
	end

	if typeof(tab) ~= "table" or tab.Destroyed then
		self.Library:_Warn("API", "SelectTab ignored: invalid tab")
		return self
	end

	self.ActiveTab = tab

	for _, item in ipairs(self.Tabs) do
		item:SetActive(item == tab)
	end
	return self
end

function Window:SetMinimized(value)
	if self.Closed then
		return self
	end

	self.Minimized = value == true
	self.Library._windowSettings.Minimized = self.Minimized

	local targetSize = self.Minimized and UDim2.fromOffset(self.Main.AbsoluteSize.X, 56) or self.Main.Size
	if not self.Minimized then
		targetSize = self._restoreSize or targetSize
	else
		self._restoreSize = self.Main.Size
	end

	self.Utility:Tween(self.Main, 0.22, { Size = targetSize })
	self.Sidebar.Visible = not self.Minimized
	self.Content.Visible = not self.Minimized
	self.ResizeButton.Visible = self.Resizeable and not self.Minimized
	return self
end

function Window:SetTheme(theme)
	if self.Closed then
		return self
	end

	if typeof(theme) == "string" then
		self.Library:SetTheme(theme)
		return self
	end

	if typeof(theme) ~= "table" then
		self.Library:_Warn("Theme", "Window:SetTheme ignored an invalid theme value")
		return self
	end
	theme = self.Context.Theme:Normalize(theme)
	self.Theme = theme

	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		if object and object.Parent then
			object[property] = theme[key]
		end
	end

	self.Utility:ApplyStrokeTheme(self.Main, theme.Stroke)

	for _, tab in ipairs(self.Tabs) do
		tab:SetTheme(theme)
	end

	return self
end

function Window:Show()
	if not self.Closed and self.Gui then
		self.Gui.Enabled = true
	end
	return self
end

function Window:Hide()
	if not self.Closed and self.Gui then
		self.Gui.Enabled = false
		self.Context.Tooltip:Hide(self.Context)
	end
	return self
end

function Window:Minimize()
	self:SetMinimized(true)
	return self
end

function Window:Restore()
	self:SetMinimized(false)
	return self
end

function Window:Close()
	self:Destroy()
	return self
end

function Window:SetTitle(titleText)
	if self.Closed then
		return self
	end

	self.Title = tostring(titleText or "")
	if self.TitleLabel then
		self.TitleLabel.Text = self.Title
	end
	return self
end

function Window:SetSubtitle(subtitleText)
	if self.Closed then
		return self
	end

	self.Subtitle = tostring(subtitleText or "")
	if self.SubtitleLabel then
		self.SubtitleLabel.Text = self.Subtitle
	end
	return self
end

function Window:Notify(options)
	if self.Closed then
		return self
	end

	self.Library:Notify(options)
	return self
end

function Window:Dialog(options)
	if self.Closed then
		return nil
	end

	return self.Library:Dialog(options)
end

function Window:Destroy()
	if self.Closed then
		return self
	end

	self.Closed = true
	self.Destroyed = true

	if self.SaveConfig then
		self.Library:SaveConfig()
	end

	if self.Context.Tooltip then
		self.Context.Tooltip:Hide(self.Context)
	end
	if self.Context.Dialog then
		self.Context.Dialog:Close(self.Context)
	end

	for _, tab in ipairs(table.clone(self.Tabs)) do
		if tab.Destroy then
			tab:Destroy()
		end
	end
	table.clear(self.Tabs)

	self.Utility:DisconnectAll(self.Connections)

	for index = #self.Library._windows, 1, -1 do
		if self.Library._windows[index] == self then
			table.remove(self.Library._windows, index)
		end
	end
	if self.Library._activeWindow == self then
		self.Library._activeWindow = self.Library._windows[#self.Library._windows]
	end

	if #self.Library._windows == 0 and self.Library._CleanupWindowRuntime then
		self.Library:_CleanupWindowRuntime()
	end

	if self.Gui then
		self.Gui:Destroy()
	end
	return self
end

return Window
