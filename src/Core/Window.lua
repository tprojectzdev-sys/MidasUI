local Window = {}
Window.__index = Window

function Window.new(context, options)
	if options ~= nil and typeof(options) ~= "table" then
		context.Library:_Warn("API", "Window.new expected an options table")
		options = {}
	end

	options = options or {}
	local template, templateName, validTemplate = context.Templates:Get(options.Template or options.Preset)
	if not validTemplate then
		context.Library:_Warn("Template", "Unknown template '" .. tostring(options.Template or options.Preset) .. "'; using Default")
	end

	local self = setmetatable({
		Context = context,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Tabs = {},
		Connections = {},
		ActiveTab = nil,
		Minimized = false,
		Hidden = false,
		Closed = false,
		Title = tostring(options.Title or options.Name or "MidasUI"),
		Subtitle = tostring(options.Subtitle or ""),
		Icon = options.Icon or "crown",
		SaveConfig = options.SaveConfig == true,
		Resizeable = options.Resizeable ~= false and options.Resizable ~= false,
		Animations = options.Animations ~= false,
		IntroEnabled = options.Intro ~= false and options.StartupAnimation ~= false and options.Animations ~= false,
		Tweens = {},
		LauncherConnections = {},
		LauncherEnabled = false,
		LauncherOptions = typeof(options.Launcher) == "table" and table.clone(options.Launcher) or {},
		ToggleKey = nil,
		Template = template,
		TemplateName = templateName,
	}, Window)

	local library = self.Library
	local utility = self.Utility
	local theme = self.Theme
	local size = options.Size
	if size ~= nil and typeof(size) ~= "UDim2" then
		library:_Warn("API", "Window Size must be a UDim2; using the default size")
		size = nil
	end
	size = size or template.DefaultSize

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
		DisplayOrder = 100,
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
		Visible = not self.IntroEnabled,
		Parent = gui,
	})
	utility:Corner(main, 12)
	local mainStroke = utility:Stroke(main, theme.Stroke, 0.08, 1)
	local mainGradient = utility:Create("UIGradient", {
		Color = ColorSequence.new(theme.Background, theme.Card),
		Rotation = 45,
		Parent = main,
	})
	local mainScale = utility:Create("UIScale", {
		Scale = self.IntroEnabled and 0.965 or 1,
		Parent = main,
	})
	local sizeConstraint = utility:Create("UISizeConstraint", {
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
	local topbarGradient = utility:Create("UIGradient", {
		Color = ColorSequence.new(theme.Topbar, theme.Background),
		Rotation = 90,
		Parent = topbar,
	})
	local accentLine = utility:Create("Frame", {
		Name = "AccentLine",
		Position = UDim2.new(0, 14, 1, -1),
		Size = UDim2.new(1, -28, 0, 1),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0.32,
		BorderSizePixel = 0,
		Parent = topbar,
	})

	local icon = utility:CreateCrownMark(topbar, theme, 30)
	icon.Position = UDim2.fromOffset(15, 13)
	local customIcon
	if not (typeof(self.Icon) == "string" and string.lower(self.Icon) == "crown") then
		customIcon = utility:CreateIcon(icon, self.Icon, {
			Name = "CustomIcon",
			Position = UDim2.fromOffset(9, 9),
			Size = UDim2.fromOffset(12, 12),
			Color = theme.Highlight,
			TextSize = 9,
		})
	end

	local title = utility:Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(56, 9),
		Size = UDim2.new(1, -154, 0, 24),
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
		Position = UDim2.fromOffset(56, 31),
		Size = UDim2.new(1, -154, 0, 16),
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
	local minimizeStroke = utility:Stroke(minimize, theme.Stroke, 0.58)

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
	local closeStroke = utility:Stroke(close, theme.Stroke, 0.58)

	local sidebar = utility:Create("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(0, 56),
		Size = UDim2.new(0, 152, 1, -56),
		BackgroundColor3 = theme.Sidebar,
		Parent = main,
	})
	local sidebarDivider = utility:Create("Frame", {
		Name = "SidebarDivider",
		Position = UDim2.new(1, -1, 0, 10),
		Size = UDim2.new(0, 1, 1, -20),
		BackgroundColor3 = theme.Stroke,
		BackgroundTransparency = 0.48,
		BorderSizePixel = 0,
		Parent = sidebar,
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
		BackgroundColor3 = theme.Background,
		BackgroundTransparency = 0.18,
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
	self.MainStroke = mainStroke
	self.MainGradient = mainGradient
	self.MainScale = mainScale
	self.SizeConstraint = sizeConstraint
	self.Topbar = topbar
	self.TopbarGradient = topbarGradient
	self.AccentLine = accentLine
	self.TitleLabel = title
	self.SubtitleLabel = subtitle
	self.IconLabel = icon
	self.CustomIconLabel = customIcon
	self.Sidebar = sidebar
	self.SidebarDivider = sidebarDivider
	self.TabList = tabList
	self.Content = content
	self.ResizeButton = resize
	self.MinimizeButton = minimize
	self._restoreSize = size
	self._themeObjects = {
		{ main, "BackgroundColor3", "Background" },
		{ topbar, "BackgroundColor3", "Topbar" },
		{ sidebar, "BackgroundColor3", "Sidebar" },
		{ sidebarDivider, "BackgroundColor3", "Stroke" },
		{ content, "BackgroundColor3", "Background" },
		{ accentLine, "BackgroundColor3", "Accent" },
		{ title, "TextColor3", "Text" },
		{ subtitle, "TextColor3", "MutedText" },
		{ minimize, "BackgroundColor3", "Card" },
		{ minimize, "TextColor3", "MutedText" },
		{ close, "BackgroundColor3", "Card" },
		{ close, "TextColor3", "Danger" },
		{ resize, "TextColor3", "MutedText" },
	}

	utility:MakeDraggable(topbar, main, self.Connections, { ClampToViewport = true })
	utility:Connect(self.Connections, main.InputBegan, function()
		if not self.Closed then
			library._activeWindow = self
		end
	end)

	local resizing = false
	local resizeStart
	local startSize

	utility:Connect(self.Connections, resize.InputBegan, function(input)
		if not self.Resizeable or self.Minimized or self.Transitioning then
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
			utility:TweenTracked(self.Tweens, button.Name .. "Hover", button, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Background })
		end)

		utility:Connect(self.Connections, button.MouseLeave, function()
			utility:TweenTracked(self.Tweens, button.Name .. "Hover", button, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Card })
		end)
		utility:Connect(self.Connections, button.MouseButton1Down, function()
			utility:TweenTracked(self.Tweens, button.Name .. "Press", button, utility.Motion.Press, { BackgroundTransparency = 0.2 })
		end)
		utility:Connect(self.Connections, button.MouseButton1Up, function()
			utility:TweenTracked(self.Tweens, button.Name .. "Press", button, utility.Motion.Press, { BackgroundTransparency = 0 })
		end)
	end

	table.insert(library._windows, self)

	if options.ToggleKey ~= nil then
		self:SetToggleKey(options.ToggleKey)
	end
	if options.Launcher == true or typeof(options.Launcher) == "table" then
		self:SetLauncherEnabled(true)
	elseif options.Launcher ~= nil and options.Launcher ~= false then
		library:_Warn("Launcher", "Launcher must be true, false, or an options table")
	end

	if self.SaveConfig then
		library:LoadConfig()
	end
	if self.IntroEnabled then
		task.defer(function()
			self:_PlayIntro()
		end)
	end

	return self
end

function Window:_PlayIntro()
	if self.Closed or not self.IntroEnabled or not self.Gui or not self.Main then
		return self
	end

	self._introToken = (self._introToken or 0) + 1
	local token = self._introToken
	local height = self.Main.AbsoluteSize.Y > 0 and self.Main.AbsoluteSize.Y or self._restoreSize.Y.Offset
	local landing = UDim2.new(0.5, 0, 0.5, (-height / 2) + 29)
	local crest = self.Utility:CreateCrownMark(self.Gui, self.Theme, 46)
	crest.AnchorPoint = Vector2.new(0.5, 0.5)
	crest.Position = UDim2.new(landing.X.Scale, landing.X.Offset, landing.Y.Scale, landing.Y.Offset - 76)
	crest.Rotation = -18
	crest.ZIndex = 50
	for _, item in ipairs(crest:GetDescendants()) do
		if item:IsA("GuiObject") then
			item.ZIndex = 51
		end
	end
	self.IntroCrest = crest
	self.Main.Visible = false
	self.MainScale.Scale = 0.965

	local drop = self.Utility:TweenTracked(
		self.Tweens,
		"Intro",
		crest,
		self.Utility.Motion.IntroDrop,
		{ Position = landing, Rotation = 0 },
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out
	)
	drop.Completed:Connect(function()
		if self.Closed or self._introToken ~= token or not crest.Parent then
			return
		end

		self.Main.Visible = true
		local targetPosition = self.Main.Position
		self._introTargetPosition = targetPosition
		self.Main.Position = UDim2.new(targetPosition.X.Scale, targetPosition.X.Offset, targetPosition.Y.Scale, targetPosition.Y.Offset + 10)
		self.Utility:TweenTracked(
			self.Tweens,
			"IntroScale",
			self.MainScale,
			self.Utility.Motion.Reveal,
			{ Scale = 1 },
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		)
		self.Utility:TweenTracked(
			self.Tweens,
			"IntroWindow",
			self.Main,
			self.Utility.Motion.Reveal,
			{ Position = targetPosition },
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.Out
		)
		self.Utility:TweenTracked(self.Tweens, "IntroCrestFade", crest, self.Utility.Motion.Fast, { BackgroundTransparency = 1 })
		task.delay(self.Utility.Motion.Reveal, function()
			if self._introToken == token then
				self._introTargetPosition = nil
			end
			if crest.Parent then
				crest:Destroy()
			end
			if self.IntroCrest == crest then
				self.IntroCrest = nil
			end
		end)
	end)
	return self
end

function Window:_CancelIntro()
	self._introToken = (self._introToken or 0) + 1
	for _, key in ipairs({ "Intro", "IntroScale", "IntroWindow", "IntroCrestFade" }) do
		local tween = self.Tweens[key]
		if tween then
			tween:Cancel()
			self.Tweens[key] = nil
		end
	end
	if self._introTargetPosition then
		self.Main.Position = self._introTargetPosition
		self._introTargetPosition = nil
	end
	if self.IntroCrest then
		self.IntroCrest:Destroy()
		self.IntroCrest = nil
	end
	if self.Main then
		self.Main.Visible = true
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
	self.Context.Commands:IndexObject(self.Library, tab, "Tab")

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

	if self.ActiveTab ~= tab then
		self.Library:_CloseExpandedDropdown()
	end
	self.ActiveTab = tab

	for _, item in ipairs(self.Tabs) do
		item:SetActive(item == tab)
	end
	return self
end

function Window:_CreateLauncher()
	if self.Closed or self.LauncherGui then
		return self
	end

	local options = self.LauncherOptions or {}
	local utility = self.Utility
	local theme = self.Theme
	local gui = utility:Create("ScreenGui", {
		Name = "MidasUI_Launcher",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 180,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = false,
		Parent = utility:GetGuiParent(),
	})
	local position = typeof(options.Position) == "UDim2" and options.Position or UDim2.new(0, 18, 1, -18)
	local button = utility:Create("TextButton", {
		Name = "Launcher",
		AnchorPoint = Vector2.new(0, 1),
		Position = position,
		Size = UDim2.fromOffset(50, 50),
		BackgroundColor3 = theme.Card,
		Text = "",
		AutoButtonColor = false,
		Parent = gui,
	})
	utility:Corner(button, 15)
	local buttonStroke = utility:Stroke(button, theme.Stroke, 0.12, 1)
	local mark = utility:CreateCrownMark(button, theme, 34)
	mark.Position = UDim2.fromOffset(8, 8)

	self.LauncherGui = gui
	self.LauncherButton = button
	self.LauncherMark = mark
	self.LauncherStroke = buttonStroke

	local dragged = false
	utility:MakeDraggable(button, button, self.LauncherConnections, {
		ClampToViewport = true,
		OnDragStart = function()
			dragged = false
		end,
		OnDragMove = function(delta)
			dragged = dragged or delta.Magnitude > 5
		end,
	})
	utility:Connect(self.LauncherConnections, button.MouseButton1Click, function()
		if dragged then
			dragged = false
			return
		end
		if self.Closed or self.Library._activeDialog then
			return
		end
		self.Library._activeWindow = self
		if self.Minimized then
			self:Restore()
		end
		self:Show()
	end)
	utility:Connect(self.LauncherConnections, button.MouseEnter, function()
		utility:TweenTracked(self.Tweens, "LauncherHover", button, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Topbar })
	end)
	utility:Connect(self.LauncherConnections, button.MouseLeave, function()
		utility:TweenTracked(self.Tweens, "LauncherHover", button, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Card })
	end)
	utility:Connect(self.LauncherConnections, button.SelectionGained, function()
		buttonStroke.Color = self.Theme.Accent
		buttonStroke.Transparency = 0.05
	end)
	utility:Connect(self.LauncherConnections, button.SelectionLost, function()
		buttonStroke.Color = self.Theme.Stroke
		buttonStroke.Transparency = 0.12
	end)
	return self
end

function Window:_UpdateLauncherVisibility()
	if self.LauncherGui then
		self.LauncherGui.Enabled = self.LauncherEnabled and not self.Closed and (self.Hidden or self.Minimized)
	end
	return self
end

function Window:SetLauncherEnabled(enabled, options)
	if self.Closed then
		return self
	end
	if typeof(options) == "table" then
		self.LauncherOptions = table.clone(options)
		if self.LauncherButton and typeof(options.Position) == "UDim2" then
			self.LauncherButton.Position = options.Position
		end
	end

	self.LauncherEnabled = enabled == true
	if self.LauncherEnabled then
		self:_CreateLauncher()
	end
	self:_UpdateLauncherVisibility()
	return self
end

function Window:SetToggleKey(value)
	if self.Closed then
		return self
	end
	local ok, display = self.Library:_SetMenuToggleKey(value, self)
	if ok then
		self.ToggleKey = value == false and nil or value
		self.ToggleKeyDisplay = display
	end
	return self
end

function Window:ClearToggleKey()
	if not self.Closed and self.Library._menuToggleOwner == self then
		self.Library:_SetMenuToggleKey(false)
	end
	self.ToggleKey = nil
	self.ToggleKeyDisplay = "Disabled"
	return self
end

function Window:ToggleVisibility()
	if self.Closed then
		return self
	end
	if self.Hidden then
		return self:Show()
	elseif self.Minimized then
		return self:Restore()
	end
	return self:Hide()
end

function Window:SetMinimized(value)
	if self.Closed then
		return self
	end

	local minimized = value == true
	if self.Minimized == minimized then
		return self
	end

	self.Library:CloseCommandPalette()
	self.Library:_CloseExpandedDropdown()
	self:_CancelIntro()
	self.Minimized = minimized
	self.Library._windowSettings.Minimized = self.Minimized
	self._minimizeToken = (self._minimizeToken or 0) + 1
	local token = self._minimizeToken
	local wasTransitioning = self.Transitioning == true
	self.Transitioning = true

	local targetSize
	if self.Minimized then
		if not wasTransitioning then
			self._restoreSize = self.Main.Size
		end
		self.SizeConstraint.MinSize = Vector2.new(420, 56)
		local width = self._restoreSize.X.Offset > 0 and self._restoreSize.X.Offset or self.Main.AbsoluteSize.X
		targetSize = UDim2.fromOffset(width, 56)
		self.Sidebar.Visible = false
		self.Content.Visible = false
		self.ResizeButton.Visible = false
		self.MinimizeButton.Text = "+"
		self.Context.Tooltip:Hide(self.Context)
		self.Context.Dialog:Close(self.Context, nil, true)
	else
		targetSize = self._restoreSize or UDim2.fromOffset(self.Main.AbsoluteSize.X, 460)
		self.Sidebar.Visible = true
		self.Content.Visible = true
		self.MinimizeButton.Text = "-"
	end

	if self.Animations then
		local tween = self.Utility:TweenTracked(
			self.Tweens,
			"Minimize",
			self.Main,
			self.Utility.Motion.Reveal,
			{ Size = targetSize },
			self.Minimized and Enum.EasingStyle.Quart or Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		)
		tween.Completed:Connect(function()
			if self.Closed or self._minimizeToken ~= token then
				return
			end
			self.Transitioning = false
			if not self.Minimized then
				self.SizeConstraint.MinSize = Vector2.new(420, 320)
				self.ResizeButton.Visible = self.Resizeable
			end
		end)
	else
		self.Main.Size = targetSize
		self.Transitioning = false
		if not self.Minimized then
			self.SizeConstraint.MinSize = Vector2.new(420, 320)
			self.ResizeButton.Visible = self.Resizeable
		end
	end
	self:_UpdateLauncherVisibility()
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
	self.MainGradient.Color = ColorSequence.new(theme.Background, theme.Card)
	self.MainStroke.Color = theme.Stroke
	self.MainStroke.Transparency = 0.08
	self.Utility:ApplyCrownTheme(self.IconLabel, theme)
	self.Utility:SetIconColor(self.CustomIconLabel, theme.Highlight)
	self.TopbarGradient.Color = ColorSequence.new(theme.Topbar, theme.Background)
	if self.IntroCrest then
		self.Utility:ApplyCrownTheme(self.IntroCrest, theme)
	end
	if self.LauncherButton then
		self.LauncherButton.BackgroundColor3 = theme.Card
		self.Utility:ApplyStrokeTheme(self.LauncherButton, theme.Stroke)
		self.Utility:ApplyCrownTheme(self.LauncherMark, theme)
		if game:GetService("GuiService").SelectedObject == self.LauncherButton then
			self.LauncherStroke.Color = theme.Accent
			self.LauncherStroke.Transparency = 0.05
		end
	end

	for _, tab in ipairs(self.Tabs) do
		tab:SetTheme(theme)
	end

	return self
end

function Window:Show()
	if self.Closed or not self.Gui or not self.Hidden then
		return self
	end

	self.Hidden = false
	self.Library._activeWindow = self
	self._visibilityToken = (self._visibilityToken or 0) + 1
	self.Gui.Enabled = true
	self.Main.Visible = true
	local targetPosition = self._shownPosition or self.Main.Position
	if self.Animations then
		self.Main.Position = UDim2.new(targetPosition.X.Scale, targetPosition.X.Offset, targetPosition.Y.Scale, targetPosition.Y.Offset + 9)
		self.MainScale.Scale = 0.975
		self.Utility:TweenTracked(
			self.Tweens,
			"VisibilityPosition",
			self.Main,
			self.Utility.Motion.Reveal,
			{ Position = targetPosition },
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.Out
		)
		self.Utility:TweenTracked(
			self.Tweens,
			"VisibilityScale",
			self.MainScale,
			self.Utility.Motion.Reveal,
			{ Scale = 1 },
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		)
	else
		self.Main.Position = targetPosition
		self.MainScale.Scale = 1
	end
	self:_UpdateLauncherVisibility()
	return self
end

function Window:Hide()
	if self.Closed or not self.Gui or self.Hidden then
		return self
	end

	self:_CancelIntro()
	self.Library:CloseCommandPalette()
	self.Library:_CloseExpandedDropdown()
	self.Hidden = true
	self._visibilityToken = (self._visibilityToken or 0) + 1
	local token = self._visibilityToken
	self._shownPosition = self.Main.Position
	self.Context.Tooltip:Hide(self.Context)
	self.Context.Dialog:Close(self.Context)
	if self.Animations then
		local targetPosition = UDim2.new(self.Main.Position.X.Scale, self.Main.Position.X.Offset, self.Main.Position.Y.Scale, self.Main.Position.Y.Offset + 8)
		self.Utility:TweenTracked(
			self.Tweens,
			"VisibilityScale",
			self.MainScale,
			self.Utility.Motion.Standard,
			{ Scale = 0.975 },
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		)
		local tween = self.Utility:TweenTracked(
			self.Tweens,
			"VisibilityPosition",
			self.Main,
			self.Utility.Motion.Standard,
			{ Position = targetPosition },
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		)
		tween.Completed:Connect(function()
			if not self.Closed and self.Hidden and self._visibilityToken == token then
				self.Gui.Enabled = false
			end
		end)
	else
		self.Gui.Enabled = false
	end
	self:_UpdateLauncherVisibility()
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

function Window:RegisterCommand(options)
	if self.Closed then
		self.Library:_Warn("Lifecycle", "RegisterCommand ignored: window is destroyed")
		return nil
	end
	if typeof(options) ~= "table" then
		self.Library:_Warn("Command", "Window:RegisterCommand expected an options table")
		return nil
	end

	local values = table.clone(options)
	values.Owner = values.Owner or self
	return self.Library:RegisterCommand(values)
end

function Window:OpenCommandPalette(options)
	if self.Closed then
		return false
	end
	return self.Library:OpenCommandPalette(options)
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
	if self.Library._menuToggleOwner == self then
		self.Library:_SetMenuToggleKey(false)
	end
	if self.Context.Shortcuts then
		self.Context.Shortcuts:RemoveOwner(self.Library, self)
	end
	self.Library:CloseCommandPalette()
	self.Library:_CloseExpandedDropdown()
	self:_CancelIntro()
	self.Utility:CancelTweens(self.Tweens)

	if self.SaveConfig then
		self.Library:SaveConfig()
	end

	if self.Context.Tooltip then
		self.Context.Tooltip:Hide(self.Context)
	end
	if self.Context.Dialog then
		self.Context.Dialog:Close(self.Context, nil, true)
	end

	for _, tab in ipairs(table.clone(self.Tabs)) do
		if tab.Destroy then
			tab:Destroy()
		end
	end
	table.clear(self.Tabs)

	self.Utility:DisconnectAll(self.Connections)
	self.Utility:DisconnectAll(self.LauncherConnections)
	if self.LauncherGui then
		self.LauncherGui:Destroy()
		self.LauncherGui = nil
	end

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
