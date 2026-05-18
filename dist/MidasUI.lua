-- MidasUI V1.2 single-file bundle
-- Generated from src modules. Edit src/ first, then rebuild the bundle.
local ModuleCache = {}
local ModuleSources = {}
ModuleSources["Assets/Icons"] = function()
local Icons = {}

Icons.Map = {
	home = "H",
	settings = "S",
	user = "U",
	shield = "D",
	sword = "W",
	crown = "C",
	search = "?",
	warning = "!",
	info = "i",
	x = "x",
	close = "x",
	minus = "-",
	plus = "+",
	check = "Y",
	bell = "B",
	menu = "M",
}

return Icons

end
ModuleSources["Core/Utility"] = function()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Utility = {}

Utility.IconGlyphs = {
	crown = "C",
	home = "H",
	settings = "S",
	user = "U",
	shield = "D",
	sword = "W",
	search = "?",
	warning = "!",
	info = "i",
	bell = "B",
	menu = "M",
	x = "x",
	close = "X",
	minus = "-",
	plus = "+",
	check = "Y",
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

	if library._RefreshDependencies then
		library:_RefreshDependencies(flag)
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

	if library._RefreshDependencies then
		library:_RefreshDependencies(flag)
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
		listfiles = callable("listfiles"),
		delfile = callable("delfile"),
		deletefile = callable("deletefile"),
	}
end

function Config:SanitizeProfile(profile)
	local name = tostring(profile or "default")
	name = string.gsub(name, "[^%w_%-]", "_")
	name = string.gsub(name, "_+", "_")

	if name == "" or name == "_" then
		name = "default"
	end

	return name
end

function Config:Path(library, profile)
	local folder = library._configFolder or "MidasUI"
	local profileName = self:SanitizeProfile(profile)
	local fileName = profileName .. ".json"
	return folder, folder .. "/" .. fileName
end

function Config:IsAvailable()
	local files = fileFunctions()
	return files.writefile ~= nil and files.readfile ~= nil and files.isfile ~= nil
end

function Config:SerializeValue(value)
	if typeof(value) == "EnumItem" then
		return {
			__MidasType = "EnumItem",
			EnumType = tostring(value.EnumType),
			Name = value.Name,
		}
	end

	if typeof(value) == "table" then
		local serialized = {}
		for key, child in pairs(value) do
			serialized[key] = self:SerializeValue(child)
		end
		return serialized
	end

	return value
end

function Config:DeserializeValue(value)
	if typeof(value) == "table" then
		if value.__MidasType == "EnumItem" and value.EnumType == "Enum.KeyCode" and typeof(value.Name) == "string" then
			local ok, keyCode = pcall(function()
				return Enum.KeyCode[value.Name]
			end)
			return ok and keyCode or nil
		end

		local decoded = {}
		for key, child in pairs(value) do
			decoded[key] = self:DeserializeValue(child)
		end
		return decoded
	end

	return value
end

function Config:SerializeFlags(flags)
	local serialized = {}
	for flag, value in pairs(flags or {}) do
		serialized[flag] = self:SerializeValue(value)
	end
	return serialized
end

function Config:Save(library, profile)
	local files = fileFunctions()
	if not files.writefile then
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

	local folder, path = self:Path(library, profile)
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
		Flags = self:SerializeFlags(library.Flags),
		Window = library._windowSettings or {},
	}

	local encoded = HttpService:JSONEncode(payload)
	local ok, err = pcall(function()
		files.writefile(path, encoded)
	end)

	return ok, err
end

function Config:Load(library, profile)
	local files = fileFunctions()
	if not (files.readfile and files.isfile) then
		return false, "File functions are not available"
	end

	local folder, path = self:Path(library, profile)
	local exists = false
	pcall(function()
		exists = files.isfile(path)
	end)

	if not exists and profile == nil then
		local legacyPath = folder .. "/" .. (library._configFile or "config.json")
		pcall(function()
			exists = files.isfile(legacyPath)
		end)

		if exists then
			path = legacyPath
		end
	end

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
			library:SetFlag(flag, self:DeserializeValue(value), false)
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

function Config:Delete(library, profile)
	local files = fileFunctions()
	local delete = files.delfile or files.deletefile
	if not (files.isfile and delete) then
		return false, "Delete file function is not available"
	end

	local _, path = self:Path(library, profile)
	local exists = false
	pcall(function()
		exists = files.isfile(path)
	end)

	if not exists then
		return false, "Config file does not exist"
	end

	local ok, err = pcall(function()
		delete(path)
	end)

	return ok, err
end

function Config:List(library)
	local files = fileFunctions()
	if not files.listfiles then
		return {}
	end

	local folder = library._configFolder or "MidasUI"
	local ok, results = pcall(function()
		return files.listfiles(folder)
	end)

	if not ok or typeof(results) ~= "table" then
		return {}
	end

	local profiles = {}
	for _, path in ipairs(results) do
		local name = tostring(path):match("([^/\\]+)%.json$")
		if name then
			table.insert(profiles, name)
		end
	end

	table.sort(profiles)
	return profiles
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
ModuleSources["Core/Tooltip"] = function()
local UserInputService = game:GetService("UserInputService")

local Tooltip = {}

function Tooltip:Init(context)
	local library = context.Library
	local utility = context.Utility

	if library._tooltipGui then
		return
	end

	local gui = utility:Create("ScreenGui", {
		Name = "MidasUI_Tooltip",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = utility:GetGuiParent(),
	})

	local frame = utility:Create("Frame", {
		Name = "Tooltip",
		Size = UDim2.fromOffset(220, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = library.Theme.Card,
		BackgroundTransparency = 0.02,
		Visible = false,
		ZIndex = 1000,
		Parent = gui,
	})
	utility:Corner(frame, 8)
	utility:Stroke(frame, library.Theme.Stroke, 0.25)
	utility:Padding(frame, { X = 10, Y = 8 })

	local label = utility:Create("TextLabel", {
		Name = "Text",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = library.Theme.Text,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = 1001,
		Parent = frame,
	})

	library._tooltipGui = gui
	library._tooltipFrame = frame
	library._tooltipLabel = label
	library._tooltipConnections = library._tooltipConnections or {}

	utility:Connect(library._tooltipConnections, UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and frame.Visible then
			self:Position(context, input.Position)
		end
	end)
end

function Tooltip:Position(context, position)
	local library = context.Library
	local frame = library._tooltipFrame
	if not frame then
		return
	end

	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local width = frame.AbsoluteSize.X > 0 and frame.AbsoluteSize.X or 220
	local height = frame.AbsoluteSize.Y > 0 and frame.AbsoluteSize.Y or 42
	local maxX = math.max(8, viewport.X - width - 8)
	local maxY = math.max(8, viewport.Y - height - 8)
	local x = math.clamp(position.X + 14, 8, maxX)
	local y = math.clamp(position.Y + 18, 8, maxY)

	frame.Position = UDim2.fromOffset(x, y)
end

function Tooltip:Show(context, text)
	if not text or text == "" then
		return
	end

	self:Init(context)

	local library = context.Library
	local frame = library._tooltipFrame
	local label = library._tooltipLabel

	frame.BackgroundColor3 = library.Theme.Card
	label.TextColor3 = library.Theme.Text
	label.Text = tostring(text)
	frame.Visible = true
	frame.BackgroundTransparency = 1
	context.Utility:Tween(frame, 0.12, { BackgroundTransparency = 0.02 })
	self:Position(context, UserInputService:GetMouseLocation())
end

function Tooltip:Hide(context)
	local library = context.Library
	local frame = library._tooltipFrame
	if frame then
		frame.Visible = false
	end
end

function Tooltip:Bind(context, element, target, text)
	if not text or text == "" or not target then
		return
	end

	self:Init(context)

	element.Connections = element.Connections or {}
	context.Utility:Connect(element.Connections, target.MouseEnter, function()
		self:Show(context, text)
	end)

	context.Utility:Connect(element.Connections, target.MouseLeave, function()
		self:Hide(context)
	end)

	context.Utility:Connect(element.Connections, target.AncestryChanged, function(_, parent)
		if not parent then
			self:Hide(context)
		end
	end)
end

return Tooltip

end
ModuleSources["Core/Keybinds"] = function()
local UserInputService = game:GetService("UserInputService")

local Keybinds = {}

function Keybinds:Init(library)
	if library._keybindsReady then
		return
	end

	library._keybindsReady = true
	library._keybindConnections = library._keybindConnections or {}

	table.insert(library._keybindConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		local listening = library._listeningKeybind
		if listening then
			listening:CaptureInput(input.KeyCode)
			return
		end

		if gameProcessed or UserInputService:GetFocusedTextBox() then
			return
		end

		for _, keybind in pairs(library.Keybinds) do
			if keybind and keybind.Enabled ~= false and keybind.Value == input.KeyCode then
				if keybind.Mode == "Hold" then
					if not keybind._held then
						keybind._held = true
						keybind:Fire(true)
					end
				else
					keybind:Fire(input.KeyCode)
				end
			end
		end
	end))

	table.insert(library._keybindConnections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if UserInputService:GetFocusedTextBox() then
			return
		end

		for _, keybind in pairs(library.Keybinds) do
			if keybind and keybind.Enabled ~= false and keybind.Mode == "Hold" and keybind.Value == input.KeyCode and keybind._held then
				keybind._held = false
				keybind:Fire(false)
			end
		end
	end))
end

function Keybinds:Register(library, keybind)
	if not keybind.Flag then
		return
	end

	self:Init(library)
	library.Keybinds[keybind.Flag] = keybind
end

function Keybinds:Unregister(library, keybind)
	if keybind.Flag and library.Keybinds[keybind.Flag] == keybind then
		library.Keybinds[keybind.Flag] = nil
	end
end

return Keybinds

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

	if self.SaveConfig then
		self.Library:SaveConfig()
	end

	if self.Context.Tooltip then
		self.Context.Tooltip:Hide(self.Context)
	end

	for _, tab in ipairs(self.Tabs) do
		for _, section in ipairs(tab.Sections) do
			for _, element in ipairs(section.Elements) do
				if element.Destroy then
					element:Destroy()
				end
			end
		end
	end

	self.Utility:DisconnectAll(self.Connections)

	for index = #self.Library._windows, 1, -1 do
		if self.Library._windows[index] == self then
			table.remove(self.Library._windows, index)
		end
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
		Enabled = true,
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
		if self.Enabled == false then
			return
		end
		utility:Tween(button, 0.14, { BackgroundColor3 = self.Theme.Topbar })
	end)

	utility:Connect(self.Connections, button.MouseLeave, function()
		if self.Enabled == false then
			return
		end
		utility:Tween(button, 0.14, { BackgroundColor3 = self.Theme.Background })
	end)

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		if self.Enabled == false then
			return
		end
		task.spawn(self.Callback)
	end)

	self.Library:_BindElement(self, options)

	return self
end

function Button:SetEnabled(enabled)
	self.Enabled = enabled == true
	self.Instance.TextTransparency = self.Enabled and 0 or 0.45
	self.Instance.BackgroundTransparency = self.Enabled and 0 or 0.35
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
		Enabled = true,
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
		if self.Enabled == false then
			return
		end

		if self.Flag then
			self.Library:SetFlag(self.Flag, not self.Value, true)
		else
			self:SetValue(not self.Value, true)
		end
	end)

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)
	self.Library:_BindElement(self, options)

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

function Toggle:SetEnabled(enabled)
	self.Enabled = enabled == true
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.Track.BackgroundTransparency = self.Enabled and 0 or 0.35
	self.Knob.BackgroundTransparency = self.Enabled and 0 or 0.35
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
		Enabled = true,
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
		if self.Enabled == false then
			return
		end

		local ratio = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		local value = snap(self.Min + ((self.Max - self.Min) * ratio), self.Min, self.Max, self.Increment)
		if self.Flag then
			self.Library:SetFlag(self.Flag, value, true)
		else
			self:SetValue(value, true)
		end
	end

	utility:Connect(self.Connections, bar.InputBegan, function(input)
		if self.Enabled == false then
			return
		end

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
	self.Library:_BindElement(self, options)

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

function Slider:SetEnabled(enabled)
	self.Enabled = enabled == true
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.ValueLabel.TextTransparency = self.Enabled and 0 or 0.45
	self.Bar.BackgroundTransparency = self.Enabled and 0 or 0.35
	self.Fill.BackgroundTransparency = self.Enabled and 0 or 0.35
	self.Knob.BackgroundTransparency = self.Enabled and 0 or 0.35

	if not self.Enabled then
		self.Dragging = false
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
		Enabled = true,
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
		if self.Enabled == false then
			return
		end

		self:SetExpanded(not self.Expanded)
	end)

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)
	self:SetExpanded(false, true)
	self.Library:_BindElement(self, options)

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
		if self.Enabled == false then
			return
		end

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

function Dropdown:SetEnabled(enabled)
	self.Enabled = enabled == true
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.ValueLabel.TextTransparency = self.Enabled and 0 or 0.45
	self.Button.BackgroundTransparency = self.Enabled and 0 or 0.35

	if not self.Enabled then
		self:SetExpanded(false)
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
		Enabled = true,
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
		if self.Enabled == false then
			return
		end

		if self.Flag then
			self.Library:SetFlag(self.Flag, box.Text, true)
		else
			self:SetValue(box.Text, true)
		end
	end)

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)
	self.Library:_BindElement(self, options)

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

function Input:SetEnabled(enabled)
	self.Enabled = enabled == true
	self.Box.TextEditable = self.Enabled
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.Box.TextTransparency = self.Enabled and 0 or 0.45
	self.Box.BackgroundTransparency = self.Enabled and 0 or 0.35
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
ModuleSources["Elements/Keybind"] = function()
local Keybind = {}
Keybind.__index = Keybind

local function normalizeKeyCode(value)
	if value == nil then
		return nil
	end

	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
		return value
	end

	if typeof(value) == "string" then
		local name = string.gsub(value, "^Enum%.KeyCode%.", "")
		local ok, keyCode = pcall(function()
			return Enum.KeyCode[name]
		end)
		return ok and keyCode or nil
	end

	return nil
end

local function keyName(value)
	local keyCode = normalizeKeyCode(value)
	return keyCode and keyCode.Name or "None"
end

function Keybind.new(context, section, options)
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = options.Name or "Keybind",
		Flag = options.Flag,
		Value = normalizeKeyCode(options.Default),
		Mode = options.Mode == "Hold" and "Hold" or "Toggle",
		Callback = options.Callback or function() end,
		Connections = {},
		Listening = false,
		Enabled = true,
	}, Keybind)

	local theme = self.Theme
	local utility = self.Utility

	local row = utility:Create("TextButton", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = section.Frame,
	})

	local label = utility:Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, -130, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local button = utility:Create("TextButton", {
		Name = "Bind",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(118, 32),
		BackgroundColor3 = theme.Background,
		Font = Enum.Font.GothamMedium,
		Text = keyName(self.Value),
		TextColor3 = theme.MutedText,
		TextSize = 12,
		AutoButtonColor = false,
		Parent = row,
	})
	utility:Corner(button, 8)
	utility:Stroke(button, theme.Stroke, 0.45)

	self.Instance = row
	self.Label = label
	self.Button = button

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		if self.Enabled == false then
			return
		end

		self:StartListening()
	end)

	context.Keybinds:Register(self.Library, self)
	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)
	self.Library:_BindElement(self, options)

	return self
end

function Keybind:GetValue()
	return self.Value
end

function Keybind:StartListening()
	self.Listening = true
	self.Library._listeningKeybind = self
	self.Button.Text = "..."
	self.Button.TextColor3 = self.Theme.Accent
end

function Keybind:StopListening()
	self.Listening = false
	if self.Library._listeningKeybind == self then
		self.Library._listeningKeybind = nil
	end
	self:Refresh()
end

function Keybind:CaptureInput(keyCode)
	if self.Library._listeningKeybind ~= self then
		return
	end

	if keyCode == Enum.KeyCode.Escape then
		self:StopListening()
		return
	end

	if keyCode == Enum.KeyCode.Backspace then
		if self.Flag then
			self.Library:SetFlag(self.Flag, nil, false)
		else
			self:SetValue(nil, false)
		end
		self:StopListening()
		return
	end

	if keyCode == Enum.KeyCode.Unknown then
		return
	end

	if self.Flag then
		self.Library:SetFlag(self.Flag, keyCode, false)
	else
		self:SetValue(keyCode, false)
	end

	self:StopListening()
end

function Keybind:Fire(value)
	task.spawn(self.Callback, value)
end

function Keybind:Refresh()
	self.Button.Text = keyName(self.Value)
	self.Button.TextColor3 = self.Enabled == false and self.Theme.MutedText or self.Theme.Text
	self.Button.BackgroundTransparency = self.Enabled == false and 0.35 or 0
	self.Label.TextColor3 = self.Enabled == false and self.Theme.MutedText or self.Theme.Text
end

function Keybind:SetValue(value)
	self.Value = normalizeKeyCode(value)
	self._held = false

	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	self:Refresh()
end

function Keybind:SetEnabled(enabled)
	self.Enabled = enabled == true
	if not self.Enabled and self.Listening then
		self:StopListening()
	end
	self:Refresh()
end

function Keybind:SetTheme(theme)
	self.Theme = theme
	self.Button.BackgroundColor3 = theme.Background
	self:Refresh()
end

function Keybind:Destroy()
	self.Context.Keybinds:Unregister(self.Library, self)
	if self.Library._listeningKeybind == self then
		self.Library._listeningKeybind = nil
	end
	self.Utility:DisconnectAll(self.Connections)
	self.Instance:Destroy()
end

return Keybind

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

end
ModuleSources["Elements/Divider"] = function()
local Divider = {}
Divider.__index = Divider

function Divider.new(context, section, options)
	local self = setmetatable({
		Context = context,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Connections = {},
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
	context.Library:_BindElement(self, options)
	return self
end

function Divider:Set(visible)
	self.Instance.Visible = visible == true
end

function Divider:SetTheme(theme)
	self.Theme = theme
	self.Line.BackgroundColor3 = theme.Stroke
end

function Divider:SetEnabled(enabled)
	self.Line.BackgroundTransparency = enabled == true and 0.2 or 0.75
end

function Divider:Destroy()
	self.Utility:DisconnectAll(self.Connections)
	self.Instance:Destroy()
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
local Tooltip = requireModule("Core/Tooltip")
local Keybinds = requireModule("Core/Keybinds")
local Icons = requireModule("Assets/Icons")

if Icons and Icons.Map then
    Utility.IconGlyphs = Icons.Map
end

local MidasUI = {
    Version = "1.2.0",
    Flags = {},
    Keybinds = {},
    Themes = Theme.Registry,
    ThemeName = "DarkGold",
    Theme = Theme.Registry.DarkGold,
    _windows = {},
    _flagObjects = {},
    _dependencies = {},
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
    Tooltip = Tooltip,
    Keybinds = Keybinds,
    Elements = {},
}

MidasUI._context = Context

Context.Window = requireModule("Core/Window")
Context.Tab = requireModule("Core/Tab")
Context.Section = requireModule("Core/Section")
Context.Elements.Button = requireModule("Elements/Button")
Context.Elements.Toggle = requireModule("Elements/Toggle")
Context.Elements.Slider = requireModule("Elements/Slider")
Context.Elements.Dropdown = requireModule("Elements/Dropdown")
Context.Elements.Input = requireModule("Elements/Input")
Context.Elements.Keybind = requireModule("Elements/Keybind")
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

function MidasUI:_BindElement(element, options)
    options = options or {}

    if options.Tooltip then
        Tooltip:Bind(Context, element, element.Instance, options.Tooltip)
    end

    if options.DependsOn then
        self:_RegisterDependency(element, options.DependsOn)
    end
end

function MidasUI:_RegisterDependency(element, dependency)
    if typeof(dependency) ~= "table" or typeof(dependency.Flag) ~= "string" then
        return
    end

    local record = {
        Element = element,
        Flag = dependency.Flag,
        Value = dependency.Value,
        Mode = dependency.Mode or "Visible",
    }

    table.insert(self._dependencies, record)
    self:_ApplyDependency(record)
end

function MidasUI:_ApplyDependency(record)
    local element = record.Element
    if not element or not element.Instance then
        return
    end

    local expected = record.Value
    local actual = self.Flags[record.Flag]
    local passes = false

    if expected == nil then
        passes = actual == true
    else
        passes = actual == expected
    end

    if record.Mode == "Enabled" then
        if element.SetEnabled then
            element:SetEnabled(passes)
        else
            element.Instance.Visible = passes
        end
    else
        element.Instance.Visible = passes
    end
end

function MidasUI:_RefreshDependencies(flag)
    for index = #self._dependencies, 1, -1 do
        local record = self._dependencies[index]
        local element = record.Element

        if not element or not element.Instance or not element.Instance.Parent then
            table.remove(self._dependencies, index)
        elseif not flag or record.Flag == flag then
            self:_ApplyDependency(record)
        end
    end
end

function MidasUI:SaveConfig(profile)
    return Config:Save(self, profile)
end

function MidasUI:LoadConfig(profile)
    return Config:Load(self, profile)
end

function MidasUI:DeleteConfig(profile)
    return Config:Delete(self, profile)
end

function MidasUI:ListConfigs()
    return Config:List(self)
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
    table.clear(self._dependencies)
    table.clear(self.Keybinds)

    if self._listeningKeybind then
        self._listeningKeybind = nil
    end

    if self._notifyGui then
        self._notifyGui:Destroy()
        self._notifyGui = nil
        self._notifyHolder = nil
    end

    if self._tooltipGui then
        Tooltip:Hide(Context)
        self._tooltipGui:Destroy()
        self._tooltipGui = nil
        self._tooltipFrame = nil
        self._tooltipLabel = nil
    end

    if self._keybindConnections then
        Utility:DisconnectAll(self._keybindConnections)
    end

    if self._tooltipConnections then
        Utility:DisconnectAll(self._tooltipConnections)
    end

    self._keybindsReady = false
end

return MidasUI
