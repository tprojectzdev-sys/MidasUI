-- MidasUI V1.1 single-file bundle
-- Generated from src modules. Edit src/ first, then rebuild the bundle.
local ModuleCache = {}
local ModuleSources = {}
ModuleSources["Core/Utility"] = function()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Utility = {}

Utility.IconGlyphs = {
	crown = "C",
	home = "H",
	settings = "S",
	user = "U",
	bell = "B",
	menu = "M",
	close = "X",
	minus = "-",
}

function Utility:Create(className, properties, children)
	local object = Instance.new(className)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	for _, child in ipairs(children or {}) do
		child.Parent = object
	end

	return object
end

function Utility:Corner(parent, radius)
	return self:Create("UICorner", {
		CornerRadius = UDim.new(0, radius or 8),
		Parent = parent,
	})
end

function Utility:Stroke(parent, color, transparency, thickness)
	return self:Create("UIStroke", {
		Color = color,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

function Utility:Padding(parent, padding)
	return self:Create("UIPadding", {
		PaddingTop = UDim.new(0, padding.Top or padding.Y or padding.All or 0),
		PaddingBottom = UDim.new(0, padding.Bottom or padding.Y or padding.All or 0),
		PaddingLeft = UDim.new(0, padding.Left or padding.X or padding.All or 0),
		PaddingRight = UDim.new(0, padding.Right or padding.X or padding.All or 0),
		Parent = parent,
	})
end

function Utility:List(parent, padding, horizontal)
	return self:Create("UIListLayout", {
		FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
		HorizontalAlignment = horizontal and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Center,
		VerticalAlignment = horizontal and Enum.VerticalAlignment.Center or Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, padding or 6),
		Parent = parent,
	})
end

function Utility:Tween(instance, duration, properties, style, direction)
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration or 0.18, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
		properties
	)
	tween:Play()
	return tween
end

function Utility:IconText(icon)
	if typeof(icon) == "number" then
		return ""
	end

	if typeof(icon) == "string" and icon ~= "" then
		local lower = string.lower(icon)
		return self.IconGlyphs[lower] or string.upper(string.sub(icon, 1, 1))
	end

	return ""
end

function Utility:Connect(store, signal, callback)
	local connection = signal:Connect(callback)
	table.insert(store, connection)
	return connection
end

function Utility:DisconnectAll(store)
	for _, connection in ipairs(store) do
		if connection and connection.Disconnect then
			connection:Disconnect()
		end
	end
	table.clear(store)
end

function Utility:MakeDraggable(handle, target, connections)
	local dragging = false
	local dragStart
	local startPosition

	self:Connect(connections, handle.InputBegan, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		dragStart = input.Position
		startPosition = target.Position
	end)

	self:Connect(connections, UserInputService.InputChanged, function(input)
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - dragStart
		target.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)

	self:Connect(connections, UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

function Utility:GetGuiParent()
	local ok, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)

	if ok and coreGui then
		return coreGui
	end

	local players = game:GetService("Players")
	local localPlayer = players.LocalPlayer
	return localPlayer:WaitForChild("PlayerGui")
end

return Utility

end
ModuleSources["Core/Theme"] = function()
local Theme = {}

Theme.Registry = {
	DarkGold = {
		Background = Color3.fromRGB(13, 13, 15),
		Topbar = Color3.fromRGB(22, 21, 20),
		Sidebar = Color3.fromRGB(17, 17, 19),
		Card = Color3.fromRGB(25, 24, 22),
		Accent = Color3.fromRGB(214, 174, 86),
		Text = Color3.fromRGB(246, 241, 229),
		MutedText = Color3.fromRGB(156, 149, 135),
		Stroke = Color3.fromRGB(74, 62, 38),
		Danger = Color3.fromRGB(224, 87, 87),
	},

	Midnight = {
		Background = Color3.fromRGB(11, 14, 23),
		Topbar = Color3.fromRGB(16, 20, 31),
		Sidebar = Color3.fromRGB(13, 17, 28),
		Card = Color3.fromRGB(20, 25, 38),
		Accent = Color3.fromRGB(106, 151, 255),
		Text = Color3.fromRGB(235, 240, 255),
		MutedText = Color3.fromRGB(139, 150, 176),
		Stroke = Color3.fromRGB(45, 58, 83),
		Danger = Color3.fromRGB(235, 91, 105),
	},

	BlackWhite = {
		Background = Color3.fromRGB(10, 10, 10),
		Topbar = Color3.fromRGB(20, 20, 20),
		Sidebar = Color3.fromRGB(15, 15, 15),
		Card = Color3.fromRGB(27, 27, 27),
		Accent = Color3.fromRGB(238, 238, 238),
		Text = Color3.fromRGB(247, 247, 247),
		MutedText = Color3.fromRGB(154, 154, 154),
		Stroke = Color3.fromRGB(62, 62, 62),
		Danger = Color3.fromRGB(232, 78, 78),
	},
}

function Theme:Get(name)
	if typeof(name) == "table" then
		return name, "Custom"
	end

	local themeName = name or "DarkGold"
	return self.Registry[themeName] or self.Registry.DarkGold, self.Registry[themeName] and themeName or "DarkGold"
end

function Theme:Register(name, values)
	assert(typeof(name) == "string", "Theme name must be a string")
	assert(typeof(values) == "table", "Theme values must be a table")
	self.Registry[name] = values
end

return Theme

end
ModuleSources["Core/Flags"] = function()
local Flags = {}

function Flags:Register(library, flag, element)
	if not flag then
		return
	end

	library._flagObjects[flag] = element

	if library.Flags[flag] ~= nil then
		element:SetValue(library.Flags[flag], false)
	else
		library.Flags[flag] = element:GetValue()
	end
end

function Flags:Get(library, flag)
	return library.Flags[flag]
end

function Flags:Set(library, flag, value, fireCallback)
	local element = library._flagObjects[flag]

	if element and element.SetValue then
		element:SetValue(value, fireCallback ~= false)
	else
		library.Flags[flag] = value
	end
end

return Flags

end
ModuleSources["Core/Config"] = function()
local HttpService = game:GetService("HttpService")

local Config = {}

local function callable(name)
	local env = type(getgenv) == "function" and getgenv() or getfenv()
	local value = env[name]
	return type(value) == "function" and value or nil
end

local function fileFunctions()
	return {
		writefile = callable("writefile"),
		readfile = callable("readfile"),
		isfile = callable("isfile"),
		makefolder = callable("makefolder"),
		isfolder = callable("isfolder"),
	}
end

function Config:Path(library)
	local folder = library._configFolder or "MidasUI"
	local fileName = library._configFile or "config.json"
	return folder, folder .. "/" .. fileName
end

function Config:IsAvailable()
	local files = fileFunctions()
	return files.writefile ~= nil and files.readfile ~= nil and files.isfile ~= nil
end

function Config:Save(library)
	local files = fileFunctions()
	if not (files.writefile and files.readfile and files.isfile) then
		return false, "File functions are not available"
	end

	local window = library._activeWindow
	if window and window.Main then
		local size = window._restoreSize or window.Main.Size
		library._windowSettings = {
			Minimized = window.Minimized == true,
			Size = {
				X = size.X.Offset,
				Y = size.Y.Offset,
			},
		}
	end

	local folder, path = self:Path(library)
	if files.makefolder then
		local ok = true
		if files.isfolder then
			ok = pcall(function()
				return files.isfolder(folder)
			end)
		end

		if ok then
			pcall(function()
				files.makefolder(folder)
			end)
		end
	end

	local payload = {
		Version = library.Version,
		Theme = library.ThemeName,
		Flags = library.Flags,
		Window = library._windowSettings or {},
	}

	local encoded = HttpService:JSONEncode(payload)
	local ok, err = pcall(function()
		files.writefile(path, encoded)
	end)

	return ok, err
end

function Config:Load(library)
	local files = fileFunctions()
	if not (files.readfile and files.isfile) then
		return false, "File functions are not available"
	end

	local _, path = self:Path(library)
	local exists = false
	pcall(function()
		exists = files.isfile(path)
	end)

	if not exists then
		return false, "Config file does not exist"
	end

	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(files.readfile(path))
	end)

	if not ok or typeof(decoded) ~= "table" then
		return false, "Config JSON could not be decoded"
	end

	if typeof(decoded.Flags) == "table" then
		for flag, value in pairs(decoded.Flags) do
			library:SetFlag(flag, value, false)
		end
	end

	if typeof(decoded.Theme) == "string" then
		library:SetTheme(decoded.Theme)
	end

	if typeof(decoded.Window) == "table" then
		library._windowSettings = decoded.Window
		local window = library._activeWindow

		if window and window.Main then
			local size = decoded.Window.Size
			if typeof(size) == "table" and tonumber(size.X) and tonumber(size.Y) then
				window.Main.Size = UDim2.fromOffset(size.X, size.Y)
			end

			if decoded.Window.Minimized == true then
				task.defer(function()
					if window.Main and window.Main.Parent then
						window:SetMinimized(true)
					end
				end)
			end
		end
	end

	return true
end

return Config

end
ModuleSources["Core/Notify"] = function()
local Notify = {}

function Notify:Init(context)
	local library = context.Library
	local utility = context.Utility

	if library._notifyGui then
		return
	end

	local gui = utility:Create("ScreenGui", {
		Name = "MidasUI_Notifications",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = utility:GetGuiParent(),
	})

	local holder = utility:Create("Frame", {
		Name = "Holder",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 18),
		Size = UDim2.fromOffset(300, 0),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	utility:List(holder, 8)

	library._notifyGui = gui
	library._notifyHolder = holder
end

function Notify:Show(context, options)
	self:Init(context)

	local library = context.Library
	local utility = context.Utility
	local theme = library.Theme
	local duration = tonumber(options.Duration) or 5

	local frame = utility:Create("Frame", {
		Name = "Notification",
		Size = UDim2.new(1, 0, 0, 84),
		BackgroundColor3 = theme.Card,
		BackgroundTransparency = 0.04,
		Position = UDim2.fromOffset(320, 0),
		Parent = library._notifyHolder,
	})
	utility:Corner(frame, 8)
	utility:Stroke(frame, theme.Stroke, 0.25)
	utility:Padding(frame, { X = 14, Y = 12 })

	local title = utility:Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = tostring(options.Title or "MidasUI"),
		TextColor3 = theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	utility:Create("TextLabel", {
		Name = "Content",
		Position = UDim2.fromOffset(0, 28),
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = tostring(options.Content or ""),
		TextColor3 = theme.MutedText,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = frame,
	})

	local accent = utility:Create("Frame", {
		Name = "Accent",
		Size = UDim2.new(0, 3, 1, -18),
		Position = UDim2.fromOffset(-8, 9),
		BackgroundColor3 = theme.Accent,
		Parent = frame,
	})
	utility:Corner(accent, 4)

	title.TextTransparency = 1
	frame.BackgroundTransparency = 1
	utility:Tween(frame, 0.22, {
		Position = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 0.04,
	})
	utility:Tween(title, 0.22, { TextTransparency = 0 })

	task.delay(duration, function()
		if not frame.Parent then
			return
		end

		local tween = utility:Tween(frame, 0.2, {
			Position = UDim2.fromOffset(320, 0),
			BackgroundTransparency = 1,
		})
		tween.Completed:Wait()
		frame:Destroy()
	end)
end

return Notify

end
ModuleSources["Core/Window"] = function()
local Window = {}
Window.__index = Window

function Window.new(context, options)
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
		Title = options.Title or options.Name or "MidasUI",
		Subtitle = options.Subtitle or "",
		Icon = options.Icon or "crown",
		SaveConfig = options.SaveConfig == true,
	}, Window)

	local library = self.Library
	local utility = self.Utility
	local theme = self.Theme
	local size = options.Size or UDim2.fromOffset(620, 460)

	library._configFolder = options.ConfigFolder or library._configFolder or "Midas"
	library._configFile = options.ConfigFile or library._configFile or "config.json"
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
		Parent = main,
	})

	self.Gui = gui
	self.Main = main
	self.Topbar = topbar
	self.Sidebar = sidebar
	self.TabList = tabList
	self.Content = content
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
	}

	utility:MakeDraggable(topbar, main, self.Connections)

	utility:Connect(self.Connections, minimize.MouseButton1Click, function()
		self:SetMinimized(not self.Minimized)
	end)

	utility:Connect(self.Connections, close.MouseButton1Click, function()
		self:Destroy()
	end)

	table.insert(library._windows, self)

	if self.SaveConfig then
		library:LoadConfig()
	end

	return self
end

function Window:CreateTab(options)
	options = typeof(options) == "table" and options or { Name = tostring(options) }
	local tab = self.Context.Tab.new(self.Context, self, options)
	table.insert(self.Tabs, tab)

	if not self.ActiveTab then
		self:SelectTab(tab)
	end

	return tab
end

function Window:SelectTab(tab)
	self.ActiveTab = tab

	for _, item in ipairs(self.Tabs) do
		item:SetActive(item == tab)
	end
end

function Window:SetMinimized(value)
	self.Minimized = value == true
	self.Library._windowSettings.Minimized = self.Minimized

	local targetSize = self.Minimized and UDim2.fromOffset(self.Main.AbsoluteSize.X, 56) or (self.Library._windowSettings.Size or self.Main.Size)
	if not self.Minimized then
		targetSize = self._restoreSize or targetSize
	else
		self._restoreSize = self.Main.Size
	end

	self.Utility:Tween(self.Main, 0.22, { Size = targetSize })
	self.Sidebar.Visible = not self.Minimized
	self.Content.Visible = not self.Minimized
end

function Window:SetTheme(theme)
	self.Theme = theme

	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		if object and object.Parent then
			object[property] = theme[key]
		end
	end

	for _, tab in ipairs(self.Tabs) do
		tab:SetTheme(theme)
	end
end

function Window:Destroy()
	if self.Closed then
		return
	end

	self.Closed = true
	self.Utility:DisconnectAll(self.Connections)

	if self.SaveConfig then
		self.Library:SaveConfig()
	end

	if self.Gui then
		self.Gui:Destroy()
	end
end

return Window

end
ModuleSources["Core/Tab"] = function()
local Tab = {}
Tab.__index = Tab

function Tab.new(context, window, options)
	local self = setmetatable({
		Context = context,
		Window = window,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = options.Name or "Tab",
		Icon = options.Icon or "",
		Sections = {},
		Connections = {},
	}, Tab)

	local theme = self.Theme
	local utility = self.Utility

	local button = utility:Create("TextButton", {
		Name = self.Name .. "Tab",
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = theme.Card,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "",
		AutoButtonColor = false,
		Parent = window.TabList,
	})
	utility:Corner(button, 8)

	local icon = utility:Create("TextLabel", {
		Name = "Icon",
		Position = UDim2.fromOffset(10, 8),
		Size = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = utility:IconText(self.Icon),
		TextColor3 = theme.MutedText,
		TextSize = 13,
		Parent = button,
	})

	local label = utility:Create("TextLabel", {
		Name = "Label",
		Position = UDim2.fromOffset(38, 0),
		Size = UDim2.new(1, -44, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = self.Name,
		TextColor3 = theme.MutedText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = button,
	})

	local page = utility:Create("ScrollingFrame", {
		Name = self.Name .. "Page",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Accent,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = window.Content,
	})
	utility:Padding(page, { X = 14, Y = 14 })
	utility:List(page, 10)

	self.Button = button
	self.IconLabel = icon
	self.Label = label
	self.Page = page
	self._themeObjects = {
		{ button, "BackgroundColor3", "Card" },
		{ icon, "TextColor3", "MutedText" },
		{ label, "TextColor3", "MutedText" },
	}

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		window:SelectTab(self)
	end)

	return self
end

function Tab:CreateSection(name)
	local section = self.Context.Section.new(self.Context, self, name)
	table.insert(self.Sections, section)
	return section
end

function Tab:SetActive(active)
	self.Page.Visible = active
	self.Button.BackgroundTransparency = active and 0 or 1
	self.IconLabel.TextColor3 = active and self.Theme.Accent or self.Theme.MutedText
	self.Label.TextColor3 = active and self.Theme.Text or self.Theme.MutedText
end

function Tab:SetTheme(theme)
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
end

return Tab

end
ModuleSources["Core/Section"] = function()
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
		Parent = tab.Page,
	})
	utility:Corner(frame, 10)
	utility:Stroke(frame, theme.Stroke, 0.3)
	utility:Padding(frame, { X = 12, Y = 12 })
	utility:List(frame, 8)

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

return Section

end
ModuleSources["Elements/Button"] = function()
local Button = {}
Button.__index = Button

function Button.new(context, section, options)
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = options.Name or options.Text or "Button",
		Callback = options.Callback or options.Func or function() end,
		Connections = {},
	}, Button)

	local theme = self.Theme
	local utility = self.Utility

	local button = utility:Create("TextButton", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = theme.Background,
		Font = Enum.Font.GothamMedium,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = 13,
		AutoButtonColor = false,
		Parent = section.Frame,
	})
	utility:Corner(button, 8)
	utility:Stroke(button, theme.Stroke, 0.55)

	self.Instance = button
	self._themeObjects = {
		{ button, "BackgroundColor3", "Background" },
		{ button, "TextColor3", "Text" },
	}

	utility:Connect(self.Connections, button.MouseEnter, function()
		utility:Tween(button, 0.14, { BackgroundColor3 = self.Theme.Topbar })
	end)

	utility:Connect(self.Connections, button.MouseLeave, function()
		utility:Tween(button, 0.14, { BackgroundColor3 = self.Theme.Background })
	end)

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		task.spawn(self.Callback)
	end)

	return self
end

function Button:SetTheme(theme)
	self.Theme = theme
	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		object[property] = theme[key]
	end
end

function Button:Destroy()
	self.Utility:DisconnectAll(self.Connections)
	self.Instance:Destroy()
end

return Button

end
ModuleSources["Elements/Toggle"] = function()
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(context, section, options)
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = options.Name or "Toggle",
		Flag = options.Flag,
		Value = options.Default == true,
		Callback = options.Callback or function() end,
		Connections = {},
	}, Toggle)

	local theme = self.Theme
	local utility = self.Utility

	local row = utility:Create("TextButton", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = section.Frame,
	})

	local label = utility:Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, -58, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local track = utility:Create("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(42, 22),
		BackgroundColor3 = theme.Background,
		Parent = row,
	})
	utility:Corner(track, 12)
	utility:Stroke(track, theme.Stroke, 0.4)

	local knob = utility:Create("Frame", {
		Name = "Knob",
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = theme.MutedText,
		Parent = track,
	})
	utility:Corner(knob, 10)

	self.Instance = row
	self.Label = label
	self.Track = track
	self.Knob = knob
	self._themeObjects = {
		{ label, "TextColor3", "Text" },
	}

	utility:Connect(self.Connections, row.MouseButton1Click, function()
		if self.Flag then
			self.Library:SetFlag(self.Flag, not self.Value, true)
		else
			self:SetValue(not self.Value, true)
		end
	end)

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)

	return self
end

function Toggle:GetValue()
	return self.Value
end

function Toggle:SetValue(value, fireCallback)
	local nextValue = value == true
	local changed = self.Value ~= nextValue
	self.Value = nextValue

	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	local theme = self.Theme
	self.Utility:Tween(self.Track, 0.16, {
		BackgroundColor3 = self.Value and theme.Accent or theme.Background,
	})
	self.Utility:Tween(self.Knob, 0.16, {
		Position = self.Value and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
		BackgroundColor3 = self.Value and theme.Text or theme.MutedText,
	})

	if changed and fireCallback ~= false then
		task.spawn(self.Callback, self.Value)
	end
end

function Toggle:SetTheme(theme)
	self.Theme = theme
	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		object[property] = theme[key]
	end
	self:SetValue(self.Value, false)
end

function Toggle:Destroy()
	self.Utility:DisconnectAll(self.Connections)
	self.Instance:Destroy()
end

return Toggle

end
ModuleSources["Elements/Slider"] = function()
local UserInputService = game:GetService("UserInputService")

local Slider = {}
Slider.__index = Slider

local function snap(value, min, max, increment)
	increment = increment or 1
	local rounded = math.floor(((value - min) / increment) + 0.5) * increment + min
	return math.clamp(rounded, min, max)
end

function Slider.new(context, section, options)
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = options.Name or "Slider",
		Flag = options.Flag,
		Min = tonumber(options.Min) or 0,
		Max = tonumber(options.Max) or 100,
		Increment = tonumber(options.Increment) or 1,
		Value = tonumber(options.Default) or tonumber(options.Min) or 0,
		Callback = options.Callback or function() end,
		Connections = {},
		Dragging = false,
	}, Slider)

	local theme = self.Theme
	local utility = self.Utility

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundTransparency = 1,
		Parent = section.Frame,
	})

	local label = utility:Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, -82, 0, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	local valueLabel = utility:Create("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(76, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextColor3 = theme.Accent,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = frame,
	})

	local bar = utility:Create("TextButton", {
		Name = "Bar",
		Position = UDim2.fromOffset(0, 34),
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundColor3 = theme.Background,
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	})
	utility:Corner(bar, 6)

	local fill = utility:Create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = theme.Accent,
		Parent = bar,
	})
	utility:Corner(fill, 6)

	local knob = utility:Create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = theme.Text,
		Parent = bar,
	})
	utility:Corner(knob, 8)

	self.Instance = frame
	self.Label = label
	self.ValueLabel = valueLabel
	self.Bar = bar
	self.Fill = fill
	self.Knob = knob

	local function updateFromPosition(x)
		local ratio = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		local value = snap(self.Min + ((self.Max - self.Min) * ratio), self.Min, self.Max, self.Increment)
		if self.Flag then
			self.Library:SetFlag(self.Flag, value, true)
		else
			self:SetValue(value, true)
		end
	end

	utility:Connect(self.Connections, bar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.Dragging = true
			updateFromPosition(input.Position.X)
		end
	end)

	utility:Connect(self.Connections, UserInputService.InputChanged, function(input)
		if not self.Dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			updateFromPosition(input.Position.X)
		end
	end)

	utility:Connect(self.Connections, UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.Dragging = false
		end
	end)

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)

	return self
end

function Slider:GetValue()
	return self.Value
end

function Slider:SetValue(value, fireCallback)
	local nextValue = snap(tonumber(value) or self.Min, self.Min, self.Max, self.Increment)
	local changed = self.Value ~= nextValue
	self.Value = nextValue

	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	local ratio = (self.Value - self.Min) / math.max(self.Max - self.Min, 1)
	self.ValueLabel.Text = tostring(self.Value)
	self.Utility:Tween(self.Fill, 0.12, { Size = UDim2.fromScale(ratio, 1) })
	self.Utility:Tween(self.Knob, 0.12, { Position = UDim2.fromScale(ratio, 0.5) })

	if changed and fireCallback ~= false then
		task.spawn(self.Callback, self.Value)
	end
end

function Slider:SetTheme(theme)
	self.Theme = theme
	self.Label.TextColor3 = theme.Text
	self.ValueLabel.TextColor3 = theme.Accent
	self.Bar.BackgroundColor3 = theme.Background
	self.Fill.BackgroundColor3 = theme.Accent
	self.Knob.BackgroundColor3 = theme.Text
end

function Slider:Destroy()
	self.Utility:DisconnectAll(self.Connections)
	self.Instance:Destroy()
end

return Slider

end
ModuleSources["Elements/Dropdown"] = function()
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(context, section, options)
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = options.Name or "Dropdown",
		Flag = options.Flag,
		Options = options.Options or options.Values or {},
		Value = options.Default,
		Callback = options.Callback or function() end,
		Connections = {},
		Expanded = false,
	}, Dropdown)

	if self.Value == nil and self.Options[1] ~= nil then
		self.Value = self.Options[1]
	end

	local theme = self.Theme
	local utility = self.Utility

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 40),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = section.Frame,
	})

	local label = utility:Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	local button = utility:Create("TextButton", {
		Name = "Button",
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = theme.Background,
		Font = Enum.Font.Gotham,
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	})
	utility:Corner(button, 8)
	utility:Stroke(button, theme.Stroke, 0.5)

	local valueLabel = utility:Create("TextLabel", {
		Name = "Value",
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -42, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextColor3 = theme.MutedText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = button,
	})

	local arrow = utility:Create("TextLabel", {
		Name = "Arrow",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		Size = UDim2.fromOffset(20, 34),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "v",
		TextColor3 = theme.Accent,
		TextSize = 12,
		Parent = button,
	})

	local list = utility:Create("Frame", {
		Name = "List",
		Position = UDim2.fromOffset(0, 64),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = theme.Background,
		ClipsDescendants = true,
		Parent = frame,
	})
	utility:Corner(list, 8)
	utility:Stroke(list, theme.Stroke, 0.5)
	utility:Padding(list, { All = 4 })
	utility:List(list, 4)

	self.Instance = frame
	self.Label = label
	self.Button = button
	self.ValueLabel = valueLabel
	self.Arrow = arrow
	self.List = list
	self.OptionButtons = {}

	for _, option in ipairs(self.Options) do
		self:_addOption(option)
	end

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		self:SetExpanded(not self.Expanded)
	end)

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)
	self:SetExpanded(false, true)

	return self
end

function Dropdown:_addOption(option)
	local text = tostring(option)
	local utility = self.Utility
	local theme = self.Theme

	local button = utility:Create("TextButton", {
		Name = text,
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = theme.Card,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = text,
		TextColor3 = theme.MutedText,
		TextSize = 13,
		AutoButtonColor = false,
		Parent = self.List,
	})
	utility:Corner(button, 6)

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		if self.Flag then
			self.Library:SetFlag(self.Flag, option, true)
		else
			self:SetValue(option, true)
		end
		self:SetExpanded(false)
	end)

	table.insert(self.OptionButtons, { Button = button, Value = option })
end

function Dropdown:GetValue()
	return self.Value
end

function Dropdown:SetExpanded(value, instant)
	self.Expanded = value == true
	local height = self.Expanded and math.min(#self.Options * 32 + 8, 136) or 0
	local frameHeight = self.Expanded and (64 + height) or 58

	self.Arrow.Text = self.Expanded and "^" or "v"
	if instant then
		self.List.Size = UDim2.new(1, 0, 0, height)
		self.Instance.Size = UDim2.new(1, 0, 0, frameHeight)
	else
		self.Utility:Tween(self.List, 0.16, { Size = UDim2.new(1, 0, 0, height) })
		self.Utility:Tween(self.Instance, 0.16, { Size = UDim2.new(1, 0, 0, frameHeight) })
	end
end

function Dropdown:SetValue(value, fireCallback)
	local changed = self.Value ~= value
	self.Value = value

	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	self.ValueLabel.Text = tostring(value or "")

	for _, item in ipairs(self.OptionButtons) do
		local active = item.Value == self.Value
		item.Button.BackgroundTransparency = active and 0 or 1
		item.Button.TextColor3 = active and self.Theme.Text or self.Theme.MutedText
	end

	if changed and fireCallback ~= false then
		task.spawn(self.Callback, self.Value)
	end
end

function Dropdown:SetTheme(theme)
	self.Theme = theme
	self.Label.TextColor3 = theme.Text
	self.Button.BackgroundColor3 = theme.Background
	self.ValueLabel.TextColor3 = theme.MutedText
	self.Arrow.TextColor3 = theme.Accent
	self.List.BackgroundColor3 = theme.Background

	for _, item in ipairs(self.OptionButtons) do
		item.Button.BackgroundColor3 = theme.Card
	end

	self:SetValue(self.Value, false)
end

function Dropdown:Destroy()
	self.Utility:DisconnectAll(self.Connections)
	self.Instance:Destroy()
end

return Dropdown

end
ModuleSources["Elements/Input"] = function()
local Input = {}
Input.__index = Input

function Input.new(context, section, options)
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = options.Name or "Input",
		Flag = options.Flag,
		Value = options.Default or "",
		Placeholder = options.Placeholder or "",
		Callback = options.Callback or function() end,
		Connections = {},
	}, Input)

	local theme = self.Theme
	local utility = self.Utility

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundTransparency = 1,
		Parent = section.Frame,
	})

	local label = utility:Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	local box = utility:Create("TextBox", {
		Name = "Box",
		Position = UDim2.fromOffset(0, 26),
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = theme.Background,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = self.Placeholder,
		PlaceholderColor3 = theme.MutedText,
		Text = tostring(self.Value),
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	utility:Corner(box, 8)
	utility:Stroke(box, theme.Stroke, 0.5)
	utility:Padding(box, { X = 10 })

	self.Instance = frame
	self.Label = label
	self.Box = box

	utility:Connect(self.Connections, box.FocusLost, function()
		if self.Flag then
			self.Library:SetFlag(self.Flag, box.Text, true)
		else
			self:SetValue(box.Text, true)
		end
	end)

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)

	return self
end

function Input:GetValue()
	return self.Value
end

function Input:SetValue(value, fireCallback)
	local nextValue = tostring(value or "")
	local changed = self.Value ~= nextValue
	self.Value = nextValue

	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	if self.Box.Text ~= self.Value then
		self.Box.Text = self.Value
	end

	if changed and fireCallback ~= false then
		task.spawn(self.Callback, self.Value)
	end
end

function Input:SetTheme(theme)
	self.Theme = theme
	self.Label.TextColor3 = theme.Text
	self.Box.BackgroundColor3 = theme.Background
	self.Box.TextColor3 = theme.Text
	self.Box.PlaceholderColor3 = theme.MutedText
end

function Input:Destroy()
	self.Utility:DisconnectAll(self.Connections)
	self.Instance:Destroy()
end

return Input

end
ModuleSources["Elements/Paragraph"] = function()
local Paragraph = {}
Paragraph.__index = Paragraph

function Paragraph.new(context, section, options)
	local text = options.Text or options.Content or options.Name or "Paragraph"
	local self = setmetatable({
		Context = context,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Text = text,
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

return Paragraph

end
ModuleSources["Elements/Divider"] = function()
local Divider = {}
Divider.__index = Divider

function Divider.new(context, section, options)
	local self = setmetatable({
		Context = context,
		Utility = context.Utility,
		Theme = context.Library.Theme,
	}, Divider)

	local frame = self.Utility:Create("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, 9),
		BackgroundTransparency = 1,
		Visible = options.Visible ~= false,
		Parent = section.Frame,
	})

	local line = self.Utility:Create("Frame", {
		Name = "Line",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = self.Theme.Stroke,
		BackgroundTransparency = 0.2,
		Parent = frame,
	})

	self.Instance = frame
	self.Line = line
	return self
end

function Divider:Set(visible)
	self.Instance.Visible = visible == true
end

function Divider:SetTheme(theme)
	self.Theme = theme
	self.Line.BackgroundColor3 = theme.Stroke
end

return Divider

end
local function requireModule(name)
    if ModuleCache[name] then
        return ModuleCache[name]
    end

    local source = ModuleSources[name]
    assert(source, "MidasUI bundle missing module: " .. tostring(name))
    local result = source()
    ModuleCache[name] = result
    return result
end

local Utility = requireModule("Core/Utility")
local Theme = requireModule("Core/Theme")
local Flags = requireModule("Core/Flags")
local Config = requireModule("Core/Config")
local Notify = requireModule("Core/Notify")

local MidasUI = {
    Version = "1.1.0",
    Flags = {},
    Themes = Theme.Registry,
    ThemeName = "DarkGold",
    Theme = Theme.Registry.DarkGold,
    _windows = {},
    _flagObjects = {},
    _configFolder = "Midas",
    _configFile = "config.json",
    _windowSettings = {},
}

local Context = {
    Library = MidasUI,
    Utility = Utility,
    Theme = Theme,
    Flags = Flags,
    Config = Config,
    Notify = Notify,
    Elements = {},
}

Context.Window = requireModule("Core/Window")
Context.Tab = requireModule("Core/Tab")
Context.Section = requireModule("Core/Section")
Context.Elements.Button = requireModule("Elements/Button")
Context.Elements.Toggle = requireModule("Elements/Toggle")
Context.Elements.Slider = requireModule("Elements/Slider")
Context.Elements.Dropdown = requireModule("Elements/Dropdown")
Context.Elements.Input = requireModule("Elements/Input")
Context.Elements.Paragraph = requireModule("Elements/Paragraph")
Context.Elements.Divider = requireModule("Elements/Divider")

function MidasUI:RegisterTheme(name, values)
    Theme:Register(name, values)
    self.Themes = Theme.Registry
end

function MidasUI:SetTheme(nameOrTheme)
    local theme, themeName = Theme:Get(nameOrTheme)
    self.Theme = theme
    self.ThemeName = themeName

    for _, window in ipairs(self._windows) do
        window:SetTheme(theme)
    end
end

function MidasUI:CreateWindow(options)
    options = options or {}
    self:SetTheme(options.Theme or self.ThemeName)
    return Context.Window.new(Context, options)
end

function MidasUI:GetFlag(flag)
    return Flags:Get(self, flag)
end

function MidasUI:SetFlag(flag, value, fireCallback)
    if typeof(flag) ~= "string" or flag == "" then
        return
    end

    Flags:Set(self, flag, value, fireCallback)
end

function MidasUI:SaveConfig()
    return Config:Save(self)
end

function MidasUI:LoadConfig()
    return Config:Load(self)
end

function MidasUI:Notify(options)
    Notify:Show(Context, options or {})
end

function MidasUI:Destroy()
    for _, window in ipairs(table.clone(self._windows)) do
        window:Destroy()
    end

    table.clear(self._windows)
    table.clear(self._flagObjects)

    if self._notifyGui then
        self._notifyGui:Destroy()
        self._notifyGui = nil
        self._notifyHolder = nil
    end
end

return MidasUI
