-- MidasUI V1.5 single-file bundle
-- Generated from src modules by tools/build-dist.ps1. Edit src/ first.
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
	if not store then
		return
	end

	for _, connection in ipairs(store) do
		if connection and connection.Disconnect then
			connection:Disconnect()
		end
	end
	table.clear(store)
end

function Utility:BindCanvas(scrollingFrame, layout, padding)
	padding = padding or 0

	local function update()
		if not scrollingFrame.Parent then
			return
		end

		local height = layout.AbsoluteContentSize.Y + padding
		scrollingFrame.CanvasSize = UDim2.fromOffset(0, height)
	end

	update()
	return layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
end

function Utility:ClampToViewport(frame, margin)
	margin = margin or 12

	local camera = workspace.CurrentCamera
	if not camera or not frame or not frame.Parent then
		return
	end

	local viewport = camera.ViewportSize
	local size = frame.AbsoluteSize
	local position = frame.AbsolutePosition

	local x = position.X
	local y = position.Y

	if x < margin then
		x = margin
	elseif x + size.X > viewport.X - margin then
		x = math.max(margin, viewport.X - size.X - margin)
	end

	if y < margin then
		y = margin
	elseif y + size.Y > viewport.Y - margin then
		y = math.max(margin, viewport.Y - size.Y - margin)
	end

	frame.Position = UDim2.fromOffset(
		x + (size.X * frame.AnchorPoint.X),
		y + (size.Y * frame.AnchorPoint.Y)
	)
end

function Utility:ApplyStrokeTheme(root, color)
	if not root then
		return
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("UIStroke") then
			descendant.Color = color
		end
	end
end

function Utility:MakeDraggable(handle, target, connections, options)
	options = options or {}
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

		if options.ClampToViewport then
			self:ClampToViewport(target)
		end
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

Theme.RequiredKeys = {
	"Background",
	"Topbar",
	"Sidebar",
	"Card",
	"Accent",
	"Text",
	"MutedText",
	"Stroke",
	"Danger",
}

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

Theme.Fallback = table.clone(Theme.Registry.DarkGold)

function Theme:Get(name)
	if typeof(name) == "table" then
		return self:Normalize(name), "Custom"
	end

	local themeName = typeof(name) == "string" and name or "DarkGold"
	if self.Registry[themeName] then
		return self:Normalize(self.Registry[themeName], themeName), themeName
	end
	return self:Normalize(self.Registry.DarkGold), "DarkGold"
end

function Theme:Normalize(values, baseName)
	local base = self.Registry[baseName or "DarkGold"] or self.Registry.DarkGold
	local normalized = {}

	for _, key in ipairs(self.RequiredKeys) do
		if typeof(values[key]) == "Color3" then
			normalized[key] = values[key]
		elseif typeof(base[key]) == "Color3" then
			normalized[key] = base[key]
		else
			normalized[key] = self.Fallback[key]
		end
	end

	return normalized
end

function Theme:Register(name, values)
	if typeof(name) ~= "string" or name == "" then
		return false, "Theme name must be a non-empty string"
	end

	if typeof(values) ~= "table" then
		return false, "Theme values must be a table"
	end

	self.Registry[name] = self:Normalize(values)
	return true, self.Registry[name]
end

return Theme
end
ModuleSources["Core/Flags"] = function()
local Flags = {}

local function getControllers(library, flag)
	local controllers = library._flagObjects[flag]
	if not controllers then
		controllers = {}
		library._flagObjects[flag] = controllers
	end

	return controllers
end

function Flags:Register(library, flag, element)
	if flag == nil then
		return
	end

	if typeof(flag) ~= "string" or flag == "" then
		if library._Warn then
			library:_Warn("Flag", "Registration skipped: flag must be a non-empty string")
		end
		return
	end

	local controllers = getControllers(library, flag)
	for _, controller in ipairs(controllers) do
		if controller == element then
			return
		end
	end

	if #controllers > 0 and library._Warn then
		library:_Warn("Flag", "Multiple elements are bound to flag '" .. flag .. "'")
	end

	table.insert(controllers, element)

	if library.Flags[flag] ~= nil then
		element:SetValue(library.Flags[flag], false)
		if controllers[1].GetValue then
			library.Flags[flag] = controllers[1]:GetValue()
			if controllers[1] ~= element then
				element:SetValue(library.Flags[flag], false)
			end
		end
	elseif element.GetValue then
		library.Flags[flag] = element:GetValue()
	end

	if library._RefreshDependencies then
		library:_RefreshDependencies(flag)
	end
end

function Flags:Unregister(library, flag, element)
	if typeof(flag) ~= "string" or flag == "" then
		return
	end

	local controllers = library._flagObjects[flag]
	if not controllers then
		return
	end

	for index = #controllers, 1, -1 do
		if controllers[index] == element or controllers[index].Destroyed then
			table.remove(controllers, index)
		end
	end

	if #controllers == 0 then
		library._flagObjects[flag] = nil
	end
end

function Flags:Get(library, flag)
	return library.Flags[flag]
end

function Flags:Set(library, flag, value, fireCallback)
	local controllers = library._flagObjects[flag]
	local shouldFire = fireCallback ~= false
	local primary

	if controllers then
		for index = #controllers, 1, -1 do
			local controller = controllers[index]
			if not controller or controller.Destroyed or not controller.Instance or not controller.Instance.Parent then
				table.remove(controllers, index)
			end
		end

		if #controllers == 0 then
			library._flagObjects[flag] = nil
		else
			primary = controllers[1]
			if primary.SetValue then
				primary:SetValue(value, shouldFire)
				value = primary.GetValue and primary:GetValue() or value
			end

			for index = 2, #controllers do
				local controller = controllers[index]
				if controller.SetValue then
					controller:SetValue(value, shouldFire)
				end
			end
		end
	end

	library.Flags[flag] = value

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
	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
		return value.Name
	end

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

	local encodedOk, encoded = pcall(function()
		return HttpService:JSONEncode(payload)
	end)
	if not encodedOk then
		return false, "Config values could not be encoded"
	end

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
		local content = files.readfile(path)
		if typeof(content) ~= "string" then
			error("Config content is not a string")
		end
		return HttpService:JSONDecode(content)
	end)

	if not ok or typeof(decoded) ~= "table" then
		return false, "Config JSON could not be decoded"
	end

	if decoded.Flags ~= nil and typeof(decoded.Flags) ~= "table" then
		library:_Warn("Config", "Ignored invalid Flags object in config")
	elseif typeof(decoded.Flags) == "table" then
		for flag, value in pairs(decoded.Flags) do
			if typeof(flag) == "string" and flag ~= "" then
				library:SetFlag(flag, self:DeserializeValue(value), false)
			else
				library:_Warn("Config", "Ignored an invalid flag name in config")
			end
		end
	end

	if typeof(decoded.Theme) == "string" then
		library:SetTheme(decoded.Theme)
	elseif decoded.Theme ~= nil then
		library:_Warn("Config", "Ignored invalid saved theme value")
	end

	if typeof(decoded.Window) == "table" then
		library._windowSettings = decoded.Window
		local window = library._activeWindow

		if window and window.Main then
			local size = decoded.Window.Size
			if typeof(size) == "table" and tonumber(size.X) and tonumber(size.Y) then
				local width = math.clamp(tonumber(size.X), 420, 980)
				local height = math.clamp(tonumber(size.Y), 320, 720)
				window.Main.Size = UDim2.fromOffset(width, height)
				window._restoreSize = window.Main.Size
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
	library._notifications = library._notifications or {}
end

function Notify:Show(context, options)
	options = options or {}
	self:Init(context)

	local library = context.Library
	local utility = context.Utility
	local theme = library.Theme
	local duration = math.max(tonumber(options.Duration) or 5, 0.5)
	local titleText = tostring(options.Title or "MidasUI")
	local contentText = tostring(options.Content or "")

	local function removeFrame(target)
		if not library._notifications then
			return
		end

		for index = #library._notifications, 1, -1 do
			if library._notifications[index] == target then
				table.remove(library._notifications, index)
				break
			end
		end
	end

	if #library._notifications >= 6 then
		local oldest = table.remove(library._notifications, 1)
		if oldest and oldest.Parent then
			oldest:Destroy()
		end
	end

	local frame = utility:Create("Frame", {
		Name = "Notification",
		Size = UDim2.new(1, 0, 0, 86),
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
		Text = titleText,
		TextColor3 = theme.Text,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	local content = utility:Create("TextLabel", {
		Name = "Content",
		Position = UDim2.fromOffset(0, 28),
		Size = UDim2.new(1, 0, 0, contentText == "" and 0 or 34),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = contentText,
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
	content.TextTransparency = 1
	frame.BackgroundTransparency = 1
	utility:Tween(frame, 0.22, {
		Position = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 0.04,
	})
	utility:Tween(title, 0.22, { TextTransparency = 0 })
	utility:Tween(content, 0.22, { TextTransparency = 0 })

	table.insert(library._notifications, frame)

	local controller = {}
	function controller:Close()
		removeFrame(frame)
		if frame and frame.Parent then
			frame:Destroy()
		end
		return self
	end

	task.delay(duration, function()
		if not frame.Parent then
			return
		end

		local tween = utility:Tween(frame, 0.2, {
			Position = UDim2.fromOffset(320, 0),
			BackgroundTransparency = 1,
		})
		tween.Completed:Wait()
		removeFrame(frame)
		frame:Destroy()
	end)

	return controller
end

function Notify:SetTheme(context)
	local library = context.Library
	local holder = library._notifyHolder
	if not holder then
		return
	end

	local theme = library.Theme
	for _, frame in ipairs(holder:GetChildren()) do
		if frame:IsA("Frame") and frame.Name == "Notification" then
			frame.BackgroundColor3 = theme.Card
			context.Utility:ApplyStrokeTheme(frame, theme.Stroke)
			local title = frame:FindFirstChild("Title")
			local content = frame:FindFirstChild("Content")
			local accent = frame:FindFirstChild("Accent")
			if title then
				title.TextColor3 = theme.Text
			end
			if content then
				content.TextColor3 = theme.MutedText
			end
			if accent then
				accent.BackgroundColor3 = theme.Accent
			end
		end
	end
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

function Tooltip:SetTheme(context)
	local library = context.Library
	local frame = library._tooltipFrame
	local label = library._tooltipLabel
	if frame then
		frame.BackgroundColor3 = library.Theme.Card
		context.Utility:ApplyStrokeTheme(frame, library.Theme.Stroke)
	end
	if label then
		label.TextColor3 = library.Theme.Text
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

	table.insert(library._keybindConnections, UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		local listening = library._listeningKeybind
		if listening then
			listening:CaptureInput(input.KeyCode)
			return
		end

		if UserInputService:GetFocusedTextBox() then
			return
		end

		for _, bind in pairs(library.Keybinds) do
			if bind.Enabled ~= false and bind.KeyCode ~= nil and bind.KeyCode == input.KeyCode then
				if bind.Mode == "Hold" then
					if not bind.Holding then
						bind.Holding = true
						library:_InvokeCallback("Keybind", bind.Callback, true, bind.KeyCode)
					end
				elseif not bind.Holding then
					bind.Holding = true
					library:_InvokeCallback("Keybind", bind.Callback, bind.KeyCode)
				end
			end
		end
	end))

	table.insert(library._keybindConnections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		for _, bind in pairs(library.Keybinds) do
			if bind.KeyCode ~= nil and bind.KeyCode == input.KeyCode and bind.Holding then
				bind.Holding = false

				if bind.Mode == "Hold" and bind.Enabled ~= false then
					library:_InvokeCallback("Keybind", bind.Callback, false, bind.KeyCode)
				end
			end
		end
	end))
end

function Keybinds:Register(library, keybind)
	if not keybind.Flag then
		return nil
	end

	self:Init(library)

	local entry = library.Keybinds[keybind.Flag]
	if not entry then
		entry = {
			Flag = keybind.Flag,
			KeyCode = nil,
			Mode = keybind.Mode or "Toggle",
			Callback = keybind.Callback or function() end,
			Holding = false,
			Listening = false,
			Enabled = true,
			SetVisual = function() end,
			ClearVisual = function() end,
		}
		library.Keybinds[keybind.Flag] = entry
	end

	entry.Mode = keybind.Mode or entry.Mode or "Toggle"
	entry.Callback = keybind.Callback or entry.Callback or function() end
	entry.Element = keybind
	entry.SetVisual = function(newKeyCode)
		keybind:SetVisual(newKeyCode)
	end
	entry.ClearVisual = function()
		keybind:ClearVisual()
	end

	keybind.RegistryEntry = entry
	return entry
end

function Keybinds:Unregister(library, keybind)
	if not keybind.Flag then
		return
	end

	local entry = library.Keybinds[keybind.Flag]
	if entry and entry.Element == keybind then
		if entry.Holding and entry.Mode == "Hold" and entry.KeyCode ~= nil and entry.Enabled ~= false then
			library:_InvokeCallback("Keybind", entry.Callback, false, entry.KeyCode)
		end

		entry.Holding = false
		library.Keybinds[keybind.Flag] = nil
	end
end

function Keybinds:SetKeyCode(library, flag, keyCode)
	local entry = flag and library.Keybinds[flag]
	if not entry then
		return
	end

	if entry.Holding and entry.Mode == "Hold" and entry.KeyCode ~= keyCode and entry.Enabled ~= false then
		library:_InvokeCallback("Keybind", entry.Callback, false, entry.KeyCode)
	end

	entry.Holding = false
	entry.KeyCode = keyCode

	if keyCode then
		entry.SetVisual(keyCode)
	else
		entry.ClearVisual()
	end
end

function Keybinds:SetEnabled(library, flag, enabled)
	local entry = flag and library.Keybinds[flag]
	if not entry then
		return
	end

	if enabled == false and entry.Holding then
		if entry.Mode == "Hold" and entry.KeyCode ~= nil then
			library:_InvokeCallback("Keybind", entry.Callback, false, entry.KeyCode)
		end
		entry.Holding = false
	end

	entry.Enabled = enabled == true
end

return Keybinds
end
ModuleSources["Core/Dialog"] = function()
local Dialog = {}

function Dialog:Init(context)
	local library = context.Library
	local utility = context.Utility

	if library._dialogGui then
		return
	end

	local gui = utility:Create("ScreenGui", {
		Name = "MidasUI_Dialogs",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = utility:GetGuiParent(),
	})

	library._dialogGui = gui
end

function Dialog:Close(context, controller)
	local library = context.Library
	local dialog = library._activeDialog
	if controller and dialog and dialog.Controller ~= controller then
		return
	end

	if dialog and dialog.Gui then
		dialog.Gui:Destroy()
	end
	if not controller or not dialog or dialog.Controller == controller then
		library._activeDialog = nil
	end
end

function Dialog:SetTheme(context)
	local library = context.Library
	local dialog = library._activeDialog
	if not dialog then
		return
	end

	local theme = library.Theme
	if dialog.Card then
		dialog.Card.BackgroundColor3 = theme.Card
		context.Utility:ApplyStrokeTheme(dialog.Card, theme.Stroke)
	end
	if dialog.Title then
		dialog.Title.TextColor3 = theme.Text
	end
	if dialog.Content then
		dialog.Content.TextColor3 = theme.MutedText
	end
	if dialog.Input then
		dialog.Input.BackgroundColor3 = theme.Background
		dialog.Input.TextColor3 = theme.Text
		dialog.Input.PlaceholderColor3 = theme.MutedText
	end
	for _, button in ipairs(dialog.Buttons or {}) do
		button.BackgroundColor3 = button.Name == "Confirm" and theme.Accent or theme.Background
		button.TextColor3 = button.Name == "Confirm" and theme.Background or theme.Text
	end
end

function Dialog:Show(context, options)
	options = options or {}
	self:Init(context)
	self:Close(context)

	local library = context.Library
	local utility = context.Utility
	local theme = library.Theme
	local dialogType = options.Type or "Info"
	if dialogType ~= "Info" and dialogType ~= "Confirm" and dialogType ~= "Input" then
		library:_Warn("Dialog", "Unknown dialog type '" .. tostring(dialogType) .. "'; using Info")
		dialogType = "Info"
	end
	local callbacks = {
		Confirm = options.OnConfirm or options.ConfirmCallback or options.Callback,
		Cancel = options.OnCancel or options.CancelCallback,
	}

	local overlay = utility:Create("TextButton", {
		Name = "Overlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.42,
		Text = "",
		AutoButtonColor = false,
		Parent = library._dialogGui,
	})

	local card = utility:Create("Frame", {
		Name = "Dialog",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(380, dialogType == "Input" and 218 or 178),
		BackgroundColor3 = theme.Card,
		Parent = overlay,
	})
	utility:Corner(card, 12)
	utility:Stroke(card, theme.Stroke, 0.18)
	utility:Padding(card, { X = 18, Y = 16 })

	local title = utility:Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -4, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = tostring(options.Title or "MidasUI"),
		TextColor3 = theme.Text,
		TextSize = 16,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local content = utility:Create("TextLabel", {
		Name = "Content",
		Position = UDim2.fromOffset(0, 34),
		Size = UDim2.new(1, 0, 0, dialogType == "Input" and 44 or 62),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = tostring(options.Content or ""),
		TextColor3 = theme.MutedText,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = card,
	})

	local inputBox
	if dialogType == "Input" then
		inputBox = utility:Create("TextBox", {
			Name = "Input",
			Position = UDim2.fromOffset(0, 88),
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = theme.Background,
			ClearTextOnFocus = false,
			Font = Enum.Font.Gotham,
			PlaceholderText = tostring(options.Placeholder or ""),
			PlaceholderColor3 = theme.MutedText,
			Text = tostring(options.Default or ""),
			TextColor3 = theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card,
		})
		utility:Corner(inputBox, 8)
		utility:Stroke(inputBox, theme.Stroke, 0.5)
		utility:Padding(inputBox, { X = 10 })
	end

	local buttonRow = utility:Create("Frame", {
		Name = "Actions",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Parent = card,
	})
	utility:List(buttonRow, 8, true)

	local controller = {}
	local buttons = {}

	function controller:Close()
		Dialog:Close(context, self)
		return self
	end

	local function addButton(name, text, primary, callback)
		local button = utility:Create("TextButton", {
			Name = name,
			Size = UDim2.fromOffset(112, 34),
			BackgroundColor3 = primary and theme.Accent or theme.Background,
			Font = Enum.Font.GothamMedium,
			Text = tostring(text),
			TextColor3 = primary and theme.Background or theme.Text,
			TextSize = 13,
			AutoButtonColor = false,
			Parent = buttonRow,
		})
		utility:Corner(button, 8)
		utility:Stroke(button, primary and theme.Accent or theme.Stroke, primary and 0.2 or 0.5)
		table.insert(buttons, button)

		button.MouseButton1Click:Connect(function()
			if callback ~= nil then
				if dialogType == "Input" and name == "Confirm" then
					library:_InvokeCallback("Dialog", callback, inputBox and inputBox.Text or "")
				else
					library:_InvokeCallback("Dialog", callback)
				end
			end
			controller:Close()
		end)
	end

	if dialogType == "Confirm" or dialogType == "Input" then
		addButton("Cancel", options.CancelText or "Cancel", false, callbacks.Cancel)
	end
	addButton("Confirm", options.ConfirmText or (dialogType == "Info" and "OK" or "Confirm"), true, callbacks.Confirm)

	library._activeDialog = {
		Gui = overlay,
		Card = card,
		Title = title,
		Content = content,
		Input = inputBox,
		Buttons = buttons,
		Controller = controller,
	}

	overlay.BackgroundTransparency = 1
	card.Position = UDim2.fromScale(0.5, 0.48)
	utility:Tween(overlay, 0.14, { BackgroundTransparency = 0.42 })
	utility:Tween(card, 0.16, { Position = UDim2.fromScale(0.5, 0.5) })

	return controller
end

return Dialog
end
ModuleSources["Core/Window"] = function()
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
end
ModuleSources["Core/Tab"] = function()
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
	utility:Padding(page, { X = 14, Y = 14 })
	local pageList = utility:List(page, 10)

	self.Button = button
	self.IconLabel = icon
	self.Label = label
	self.Page = page
	self.PageList = pageList
	self.CanvasConnection = utility:BindCanvas(page, pageList, 28)
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
	if self.Destroyed then
		self.Library:_Warn("Lifecycle", "CreateSection ignored: tab is destroyed")
		return nil
	end

	local section = self.Context.Section.new(self.Context, self, name)
	table.insert(self.Sections, section)
	return section
end

function Tab:SetActive(active)
	if self.Destroyed then
		return self
	end

	self.Page.Visible = active
	self.Button.BackgroundTransparency = active and 0 or 1
	self.IconLabel.TextColor3 = active and self.Theme.Accent or self.Theme.MutedText
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
		self.Page.CanvasSize = UDim2.fromOffset(0, self.PageList.AbsoluteContentSize.Y + 28)
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
		Name = tostring(name or "Section"),
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
end
ModuleSources["Elements/Button"] = function()
local Button = {}
Button.__index = Button

function Button.new(context, section, options)
	options = options or {}
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or options.Text or "Button"),
		Callback = typeof(options.Callback or options.Func) == "function" and (options.Callback or options.Func) or function() end,
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
		TextTruncate = Enum.TextTruncate.AtEnd,
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
		self.Library:_InvokeCallback("Button", self.Callback)
	end)

	utility:Connect(self.Connections, button.MouseButton1Down, function()
		if self.Enabled == false then
			return
		end
		utility:Tween(button, 0.08, { BackgroundTransparency = 0.18 })
	end)

	utility:Connect(self.Connections, button.MouseButton1Up, function()
		if self.Enabled == false then
			return
		end
		utility:Tween(button, 0.1, { BackgroundTransparency = 0 })
	end)

	self.Library:_BindElement(self, options)

	return self
end

function Button:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Instance.TextTransparency = self.Enabled and 0 or 0.45
	self.Instance.BackgroundTransparency = self.Enabled and 0 or 0.35
	return self
end

function Button:Enable()
	return self:SetEnabled(true)
end

function Button:Disable()
	return self:SetEnabled(false)
end

function Button:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Library:_SetElementVisible(self, visible == true)
	return self
end

function Button:Show()
	return self:SetVisible(true)
end

function Button:Hide()
	return self:SetVisible(false)
end

function Button:SetText(text)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(text or "")
	self.Instance.Text = self.Name
	return self
end

function Button:SetCallback(callback)
	if self.Destroyed then
		return self
	end

	self.Callback = typeof(callback) == "function" and callback or function() end
	return self
end

function Button:Refresh()
	if not self.Destroyed then
		self:SetEnabled(self.Enabled)
	end
	return self
end

function Button:GetValue()
	return nil
end

function Button:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		object[property] = theme[key]
	end
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	self:SetEnabled(self.Enabled)
	return self
end

function Button:Destroy()
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

return Button
end
ModuleSources["Elements/Toggle"] = function()
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "Toggle ignored an invalid Flag value")
		flag = nil
	end

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or "Toggle"),
		Flag = flag,
		Value = options.Default == true,
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
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
		TextTruncate = Enum.TextTruncate.AtEnd,
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

	utility:Connect(self.Connections, row.MouseEnter, function()
		if self.Enabled == false then
			return
		end

		utility:Tween(label, 0.12, { TextColor3 = self.Theme.Accent })
	end)

	utility:Connect(self.Connections, row.MouseLeave, function()
		if self.Enabled == false then
			return
		end

		utility:Tween(label, 0.12, { TextColor3 = self.Theme.Text })
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
	if self.Destroyed then
		return self
	end

	if typeof(value) ~= "boolean" then
		self.Library:_Warn("Toggle", "'" .. self.Name .. "' ignored a non-boolean value")
		return self
	end

	local nextValue = value
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
		self.Library:_InvokeCallback("Toggle", self.Callback, self.Value)
	end

	return self
end

function Toggle:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.Label.TextColor3 = self.Enabled and self.Theme.Text or self.Theme.MutedText
	self.Track.BackgroundTransparency = self.Enabled and 0 or 0.35
	self.Knob.BackgroundTransparency = self.Enabled and 0 or 0.35
	return self
end

function Toggle:Enable()
	return self:SetEnabled(true)
end

function Toggle:Disable()
	return self:SetEnabled(false)
end

function Toggle:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Library:_SetElementVisible(self, visible == true)
	return self
end

function Toggle:Show()
	return self:SetVisible(true)
end

function Toggle:Hide()
	return self:SetVisible(false)
end

function Toggle:SetText(text)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function Toggle:SetCallback(callback)
	if self.Destroyed then
		return self
	end

	self.Callback = typeof(callback) == "function" and callback or function() end
	return self
end

function Toggle:Set(value, fireCallback)
	return self:SetValue(value, fireCallback)
end

function Toggle:Refresh()
	if not self.Destroyed then
		self:SetValue(self.Value, false)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function Toggle:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		object[property] = theme[key]
	end
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	self:SetValue(self.Value, false)
	self:SetEnabled(self.Enabled)
	return self
end

function Toggle:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Library:_UnregisterDependencies(self)
	self.Context.Flags:Unregister(self.Library, self.Flag, self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
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
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "Slider ignored an invalid Flag value")
		flag = nil
	end

	local min = tonumber(options.Min) or 0
	local max = tonumber(options.Max) or 100
	if max < min then
		min, max = max, min
		context.Library:_Warn("Slider", "'" .. tostring(options.Name or "Slider") .. "' had Max below Min; values were swapped")
	end

	local increment = math.abs(tonumber(options.Increment) or 1)
	if increment <= 0 then
		increment = 1
	end

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or "Slider"),
		Flag = flag,
		Min = min,
		Max = max,
		Increment = increment,
		Value = tonumber(options.Default) or min,
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
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
		TextTruncate = Enum.TextTruncate.AtEnd,
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
	utility:Stroke(bar, theme.Stroke, 0.55)

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
	utility:Stroke(knob, theme.Stroke, 0.1)

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

	utility:Connect(self.Connections, bar.MouseEnter, function()
		if self.Enabled == false then
			return
		end

		utility:Tween(knob, 0.12, { Size = UDim2.fromOffset(18, 18) })
	end)

	utility:Connect(self.Connections, bar.MouseLeave, function()
		if self.Enabled == false or self.Dragging then
			return
		end

		utility:Tween(knob, 0.12, { Size = UDim2.fromOffset(16, 16) })
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
			utility:Tween(knob, 0.12, { Size = UDim2.fromOffset(16, 16) })
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
	if self.Destroyed then
		return self
	end

	if tonumber(value) == nil then
		self.Library:_Warn("Slider", "'" .. self.Name .. "' ignored a non-numeric value")
		return self
	end

	local nextValue = snap(tonumber(value), self.Min, self.Max, self.Increment)
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
		self.Library:_InvokeCallback("Slider", self.Callback, self.Value)
	end

	return self
end

function Slider:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.ValueLabel.TextTransparency = self.Enabled and 0 or 0.45
	self.Bar.BackgroundTransparency = self.Enabled and 0 or 0.35
	self.Fill.BackgroundTransparency = self.Enabled and 0 or 0.35
	self.Knob.BackgroundTransparency = self.Enabled and 0 or 0.35

	if not self.Enabled then
		self.Dragging = false
		self.Utility:Tween(self.Knob, 0.12, { Size = UDim2.fromOffset(16, 16) })
	end
	return self
end

function Slider:Enable()
	return self:SetEnabled(true)
end

function Slider:Disable()
	return self:SetEnabled(false)
end

function Slider:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Library:_SetElementVisible(self, visible == true)
	return self
end

function Slider:Show()
	return self:SetVisible(true)
end

function Slider:Hide()
	return self:SetVisible(false)
end

function Slider:SetText(text)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function Slider:SetCallback(callback)
	if self.Destroyed then
		return self
	end

	self.Callback = typeof(callback) == "function" and callback or function() end
	return self
end

function Slider:Set(value, fireCallback)
	return self:SetValue(value, fireCallback)
end

function Slider:SetRange(min, max, increment)
	if self.Destroyed then
		return self
	end

	min = tonumber(min) or self.Min
	max = tonumber(max) or self.Max
	if max < min then
		min, max = max, min
	end

	self.Min = min
	self.Max = max
	self.Increment = math.max(math.abs(tonumber(increment) or self.Increment), 0.0001)
	self:SetValue(self.Value, false)
	return self
end

function Slider:Refresh()
	if not self.Destroyed then
		self:SetValue(self.Value, false)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function Slider:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Label.TextColor3 = theme.Text
	self.ValueLabel.TextColor3 = theme.Accent
	self.Bar.BackgroundColor3 = theme.Background
	self.Fill.BackgroundColor3 = theme.Accent
	self.Knob.BackgroundColor3 = theme.Text
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	self:SetEnabled(self.Enabled)
	return self
end

function Slider:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Library:_UnregisterDependencies(self)
	self.Context.Flags:Unregister(self.Library, self.Flag, self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return Slider
end
ModuleSources["Elements/Dropdown"] = function()
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "Dropdown ignored an invalid Flag value")
		flag = nil
	end

	local dropdownOptions = typeof(options.Options or options.Values) == "table" and (options.Options or options.Values) or {}
	if options.Options ~= nil and typeof(options.Options) ~= "table" then
		context.Library:_Warn("Dropdown", "Options must be a table; using an empty option list")
	end

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or "Dropdown"),
		Flag = flag,
		Options = dropdownOptions,
		Value = options.Default,
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
		Connections = {},
		Expanded = false,
		Enabled = true,
		MaxVisibleOptions = math.clamp(tonumber(options.MaxVisibleOptions) or 5, 1, 20),
	}, Dropdown)

	if self.Value == nil and self.Options[1] ~= nil then
		self.Value = self.Options[1]
	end
	if self.Value ~= nil and not table.find(self.Options, self.Value) then
		context.Library:_Warn("Dropdown", "'" .. tostring(self.Name) .. "' default was not in Options")
		self.Value = self.Options[1]
	end

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

	local scroll = utility:Create("ScrollingFrame", {
		Name = "Options",
		Size = UDim2.new(1, -8, 1, -8),
		Position = UDim2.fromOffset(4, 4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = 0.3,
		Parent = list,
	})
	local optionLayout = utility:List(scroll, 4)

	self.Instance = frame
	self.Label = label
	self.Button = button
	self.ValueLabel = valueLabel
	self.Arrow = arrow
	self.List = list
	self.Scroll = scroll
	self.OptionLayout = optionLayout
	self.CanvasConnection = utility:BindCanvas(scroll, optionLayout, 4)
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
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutoButtonColor = false,
		Parent = self.Scroll,
	})
	utility:Corner(button, 6)

	self.Utility:Connect(self.Connections, button.MouseEnter, function()
		if self.Enabled == false then
			return
		end

		self.Utility:Tween(button, 0.12, { BackgroundTransparency = 0.25 })
	end)

	self.Utility:Connect(self.Connections, button.MouseLeave, function()
		if self.Enabled == false then
			return
		end

		local active = self.Value == option
		self.Utility:Tween(button, 0.12, { BackgroundTransparency = active and 0 or 1 })
	end)

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
	if self.Destroyed then
		return self
	end

	self.Expanded = value == true
	local maxVisible = math.max(self.MaxVisibleOptions, 1)
	local height = self.Expanded and math.min(#self.Options, maxVisible) * 32 + 8 or 0
	local frameHeight = self.Expanded and (64 + height) or 58

	self.Arrow.Text = self.Expanded and "^" or "v"
	self.Scroll.CanvasPosition = Vector2.new(0, 0)

	if instant then
		self.List.Size = UDim2.new(1, 0, 0, height)
		self.Instance.Size = UDim2.new(1, 0, 0, frameHeight)
	else
		self.Utility:Tween(self.List, 0.16, { Size = UDim2.new(1, 0, 0, height) })
		self.Utility:Tween(self.Instance, 0.16, { Size = UDim2.new(1, 0, 0, frameHeight) })
	end
	return self
end

function Dropdown:SetValue(value, fireCallback)
	if self.Destroyed then
		return self
	end

	if value ~= nil and not table.find(self.Options, value) then
		self.Library:_Warn("Dropdown", "'" .. self.Name .. "' ignored invalid value '" .. tostring(value) .. "'")
		return self
	end

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
		self.Library:_InvokeCallback("Dropdown", self.Callback, self.Value)
	end
	return self
end

function Dropdown:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.ValueLabel.TextTransparency = self.Enabled and 0 or 0.45
	self.Button.BackgroundTransparency = self.Enabled and 0 or 0.35

	if not self.Enabled then
		self:SetExpanded(false)
	end
	return self
end

function Dropdown:Enable()
	return self:SetEnabled(true)
end

function Dropdown:Disable()
	return self:SetEnabled(false)
end

function Dropdown:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Library:_SetElementVisible(self, visible == true)
	return self
end

function Dropdown:Show()
	return self:SetVisible(true)
end

function Dropdown:Hide()
	return self:SetVisible(false)
end

function Dropdown:SetText(text)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function Dropdown:SetCallback(callback)
	if self.Destroyed then
		return self
	end

	self.Callback = typeof(callback) == "function" and callback or function() end
	return self
end

function Dropdown:Set(value, fireCallback)
	return self:SetValue(value, fireCallback)
end

function Dropdown:SetOptions(options, defaultValue)
	if self.Destroyed then
		return self
	end

	if typeof(options) ~= "table" then
		self.Library:_Warn("Dropdown", "'" .. self.Name .. "' SetOptions ignored: options must be a table")
		return self
	end

	for _, item in ipairs(self.OptionButtons) do
		if item.Button then
			item.Button:Destroy()
		end
	end

	table.clear(self.OptionButtons)
	self.Options = options

	for _, option in ipairs(self.Options) do
		self:_addOption(option)
	end

	local nextValue = defaultValue
	if nextValue == nil or not table.find(self.Options, nextValue) then
		nextValue = self.Options[1]
	end

	self:SetValue(nextValue, false)
	self:SetExpanded(false, true)
	return self
end

function Dropdown:Refresh()
	if not self.Destroyed then
		self:SetValue(self.Value, false)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function Dropdown:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Label.TextColor3 = theme.Text
	self.Button.BackgroundColor3 = theme.Background
	self.ValueLabel.TextColor3 = theme.MutedText
	self.Arrow.TextColor3 = theme.Accent
	self.List.BackgroundColor3 = theme.Background
	self.Scroll.ScrollBarImageColor3 = theme.Accent

	for _, item in ipairs(self.OptionButtons) do
		item.Button.BackgroundColor3 = theme.Card
	end

	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	self:SetValue(self.Value, false)
	self:SetEnabled(self.Enabled)
	return self
end

function Dropdown:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Library:_UnregisterDependencies(self)
	self.Context.Flags:Unregister(self.Library, self.Flag, self)

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

return Dropdown
end
ModuleSources["Elements/Input"] = function()
local Input = {}
Input.__index = Input

function Input.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "Input ignored an invalid Flag value")
		flag = nil
	end

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or "Input"),
		Flag = flag,
		Value = options.Default or "",
		Placeholder = tostring(options.Placeholder or ""),
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
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
		TextTruncate = Enum.TextTruncate.AtEnd,
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

	utility:Connect(self.Connections, box.Focused, function()
		if self.Enabled == false then
			return
		end

		utility:Tween(box, 0.12, { BackgroundColor3 = self.Theme.Topbar })
	end)

	utility:Connect(self.Connections, box.FocusLost, function()
		utility:Tween(box, 0.12, { BackgroundColor3 = self.Theme.Background })
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
	if self.Destroyed then
		return self
	end

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
		self.Library:_InvokeCallback("Input", self.Callback, self.Value)
	end
	return self
end

function Input:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Box.TextEditable = self.Enabled
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.Label.TextColor3 = self.Enabled and self.Theme.Text or self.Theme.MutedText
	self.Box.TextTransparency = self.Enabled and 0 or 0.45
	self.Box.BackgroundTransparency = self.Enabled and 0 or 0.35
	return self
end

function Input:Enable()
	return self:SetEnabled(true)
end

function Input:Disable()
	return self:SetEnabled(false)
end

function Input:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Library:_SetElementVisible(self, visible == true)
	return self
end

function Input:Show()
	return self:SetVisible(true)
end

function Input:Hide()
	return self:SetVisible(false)
end

function Input:SetText(text)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function Input:SetPlaceholder(placeholder)
	if self.Destroyed then
		return self
	end

	self.Placeholder = tostring(placeholder or "")
	self.Box.PlaceholderText = self.Placeholder
	return self
end

function Input:SetCallback(callback)
	if self.Destroyed then
		return self
	end

	self.Callback = typeof(callback) == "function" and callback or function() end
	return self
end

function Input:Set(value, fireCallback)
	return self:SetValue(value, fireCallback)
end

function Input:Refresh()
	if not self.Destroyed then
		self:SetValue(self.Value, false)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function Input:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Label.TextColor3 = theme.Text
	self.Box.BackgroundColor3 = theme.Background
	self.Box.TextColor3 = theme.Text
	self.Box.PlaceholderColor3 = theme.MutedText
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	self:SetEnabled(self.Enabled)
	return self
end

function Input:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Library:_UnregisterDependencies(self)
	self.Context.Flags:Unregister(self.Library, self.Flag, self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
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

		if ok and keyCode ~= Enum.KeyCode.Unknown then
			return keyCode
		end
	end

	return nil
end

local function keyName(value)
	local keyCode = normalizeKeyCode(value)
	return keyCode and keyCode.Name or "None"
end

function Keybind.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "Keybind ignored an invalid Flag value")
		flag = nil
	end

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or "Keybind"),
		Flag = flag,
		Value = normalizeKeyCode(options.Default),
		Mode = options.Mode == "Hold" and "Hold" or "Toggle",
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
		Connections = {},
		Listening = false,
		Enabled = true,
		RegistryEntry = nil,
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
		TextTruncate = Enum.TextTruncate.AtEnd,
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

function Keybind:SetVisual(keyCode)
	if self.Destroyed then
		return self
	end

	self.Button.Text = keyName(keyCode)
	self.Button.TextColor3 = self.Enabled == false and self.Theme.MutedText or self.Theme.Text
	return self
end

function Keybind:ClearVisual()
	if self.Destroyed then
		return self
	end

	self.Button.Text = "None"
	self.Button.TextColor3 = self.Theme.MutedText
	return self
end

function Keybind:Refresh()
	if self.Destroyed then
		return self
	end

	if self.Value then
		self:SetVisual(self.Value)
	else
		self:ClearVisual()
	end

	self.Button.BackgroundTransparency = self.Enabled == false and 0.35 or 0
	self.Label.TextColor3 = self.Enabled == false and self.Theme.MutedText or self.Theme.Text
	return self
end

function Keybind:StartListening()
	if self.Destroyed or self.Enabled == false then
		return self
	end

	if self.Library._listeningKeybind and self.Library._listeningKeybind ~= self then
		self.Library._listeningKeybind:StopListening()
	end

	self.Listening = true
	self.Library._listeningKeybind = self

	if self.RegistryEntry then
		self.RegistryEntry.Listening = true
	end

	self.Button.Text = "..."
	self.Button.TextColor3 = self.Theme.Accent
	return self
end

function Keybind:StopListening()
	if self.Destroyed then
		return self
	end

	self.Listening = false

	if self.RegistryEntry then
		self.RegistryEntry.Listening = false
	end

	if self.Library._listeningKeybind == self then
		self.Library._listeningKeybind = nil
	end

	self:Refresh()
	return self
end

function Keybind:CaptureInput(keyCode)
	if self.Destroyed then
		return self
	end

	if self.Library._listeningKeybind ~= self then
		return self
	end

	if keyCode == Enum.KeyCode.Escape then
		self:StopListening()
		return self
	end

	if keyCode == Enum.KeyCode.Backspace then
		if self.Flag then
			self.Library:SetFlag(self.Flag, nil, false)
		else
			self:SetValue(nil, false)
		end
		self:StopListening()
		return self
	end

	if keyCode == Enum.KeyCode.Unknown then
		return self
	end

	if self.Flag then
		self.Library:SetFlag(self.Flag, keyCode, false)
	else
		self:SetValue(keyCode, false)
	end

	self:StopListening()
	return self
end

function Keybind:SetValue(value)
	if self.Destroyed then
		return self
	end

	local keyCode = normalizeKeyCode(value)
	if value ~= nil and not keyCode then
		self.Library:_Warn("Keybind", "'" .. self.Name .. "' received an invalid key value")
		return self
	end
	self.Value = keyCode

	if self.Flag then
		self.Library.Flags[self.Flag] = keyCode
		self.Context.Keybinds:SetKeyCode(self.Library, self.Flag, keyCode)
	else
		self:Refresh()
	end
	return self
end

function Keybind:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Context.Keybinds:SetEnabled(self.Library, self.Flag, self.Enabled)

	if not self.Enabled and self.Listening then
		self:StopListening()
	end

	self:Refresh()
	return self
end

function Keybind:Enable()
	return self:SetEnabled(true)
end

function Keybind:Disable()
	return self:SetEnabled(false)
end

function Keybind:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Library:_SetElementVisible(self, visible == true)
	return self
end

function Keybind:Show()
	return self:SetVisible(true)
end

function Keybind:Hide()
	return self:SetVisible(false)
end

function Keybind:SetText(text)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function Keybind:SetCallback(callback)
	if self.Destroyed then
		return self
	end

	self.Callback = typeof(callback) == "function" and callback or function() end
	if self.RegistryEntry then
		self.RegistryEntry.Callback = self.Callback
	end
	return self
end

function Keybind:Set(value, fireCallback)
	return self:SetValue(value, fireCallback)
end

function Keybind:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Button.BackgroundColor3 = theme.Background
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	self:Refresh()
	return self
end

function Keybind:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Library:_UnregisterDependencies(self)
	self.Context.Keybinds:Unregister(self.Library, self)
	self.Context.Flags:Unregister(self.Library, self.Flag, self)

	if self.Library._listeningKeybind == self then
		self.Library._listeningKeybind = nil
	end

	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return Keybind
end
ModuleSources["Elements/Paragraph"] = function()
local Paragraph = {}
Paragraph.__index = Paragraph

function Paragraph.new(context, section, options)
	options = options or {}
	local text = tostring(options.Text or options.Content or options.Name or "Paragraph")
	local self = setmetatable({
		Context = context,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Text = text,
		Connections = {},
		Enabled = true,
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
	if self.Destroyed then
		return self
	end

	self.Text = tostring(text or "")
	self.Instance.Text = self.Text
	return self
end

function Paragraph:GetValue()
	return self.Text
end

function Paragraph:SetValue(text)
	return self:Set(text)
end

function Paragraph:SetText(text)
	return self:Set(text)
end

function Paragraph:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Context.Library:_SetElementVisible(self, visible == true)
	return self
end

function Paragraph:Show()
	return self:SetVisible(true)
end

function Paragraph:Hide()
	return self:SetVisible(false)
end

function Paragraph:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Instance.TextColor3 = theme.MutedText
	self:SetEnabled(self.Enabled)
	return self
end

function Paragraph:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Instance.TextTransparency = self.Enabled and 0 or 0.45
	return self
end

function Paragraph:Enable()
	return self:SetEnabled(true)
end

function Paragraph:Disable()
	return self:SetEnabled(false)
end

function Paragraph:Refresh()
	if not self.Destroyed then
		self:Set(self.Text)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function Paragraph:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Context.Library:_UnregisterDependencies(self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return Paragraph
end
ModuleSources["Elements/Divider"] = function()
local Divider = {}
Divider.__index = Divider

function Divider.new(context, section, options)
	options = options or {}
	local self = setmetatable({
		Context = context,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Connections = {},
		Enabled = true,
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
	return self:SetVisible(visible)
end

function Divider:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Context.Library:_SetElementVisible(self, visible == true)
	return self
end

function Divider:Show()
	return self:SetVisible(true)
end

function Divider:Hide()
	return self:SetVisible(false)
end

function Divider:GetValue()
	return nil
end

function Divider:SetValue(visible)
	return self:SetVisible(visible)
end

function Divider:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Line.BackgroundColor3 = theme.Stroke
	self:SetEnabled(self.Enabled)
	return self
end

function Divider:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Line.BackgroundTransparency = self.Enabled and 0.2 or 0.75
	return self
end

function Divider:Enable()
	return self:SetEnabled(true)
end

function Divider:Disable()
	return self:SetEnabled(false)
end

function Divider:Refresh()
	if not self.Destroyed then
		self:SetTheme(self.Theme)
	end
	return self
end

function Divider:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Context.Library:_UnregisterDependencies(self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return Divider
end
local function requireModule(name)
	local cached = ModuleCache[name]
	if cached then
		return cached
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
local Dialog = requireModule("Core/Dialog")
local Icons = requireModule("Assets/Icons")

if Icons and Icons.Map then
	Utility.IconGlyphs = Icons.Map
end

local MidasUI = {
	Version = "1.5.0",
	Flags = {},
	Keybinds = {},
	Themes = Theme.Registry,
	ThemeName = "DarkGold",
	Theme = Theme:Normalize(Theme.Registry.DarkGold),
	_windows = {},
	_flagObjects = {},
	_dependencies = {},
	_debug = false,
	_warnings = {},
	_warningCategories = {},
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
	Dialog = Dialog,
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

function MidasUI:_Warn(category, message)
	if not self._debug then
		return
	end

	if message == nil then
		message = category
		category = "General"
	end

	category = tostring(category or "General")
	local text = "[MidasUI][" .. category .. "] " .. tostring(message)
	table.insert(self._warnings, text)
	self._warningCategories[category] = (self._warningCategories[category] or 0) + 1
	warn(text)
end

function MidasUI:SetDebug(enabled)
	self._debug = enabled == true
	return self
end

function MidasUI:_InvokeCallback(category, callback, ...)
	if typeof(callback) ~= "function" then
		self:_Warn(category or "Callback", "Ignored a callback that is not a function")
		return
	end

	local arguments = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(callback, table.unpack(arguments, 1, arguments.n))
		if not ok then
			self:_Warn(category or "Callback", "Callback failed: " .. tostring(err))
		end
	end)
end

function MidasUI:GetDebugState()
	if not self._debug then
		return nil
	end

	local flagCount = 0
	for _ in pairs(self.Flags) do
		flagCount = flagCount + 1
	end

	local keybindCount = 0
	for _ in pairs(self.Keybinds) do
		keybindCount = keybindCount + 1
	end

	return {
		Version = self.Version,
		Theme = self.ThemeName,
		WindowCount = #self._windows,
		FlagCount = flagCount,
		KeybindCount = keybindCount,
		DependencyCount = #self._dependencies,
		Warnings = table.clone(self._warnings),
		WarningCategories = table.clone(self._warningCategories),
	}
end

function MidasUI:RegisterTheme(name, values)
	local ok, err = Theme:Register(name, values)
	if not ok then
		self:_Warn("Theme", err)
		return false, err
	end

	self.Themes = Theme.Registry
	return true, name
end

function MidasUI:SetTheme(nameOrTheme)
	local theme, themeName = Theme:Get(nameOrTheme)
	local valid = true
	if typeof(nameOrTheme) == "string" and not Theme.Registry[nameOrTheme] then
		valid = false
		self:_Warn("Theme", "Unknown theme '" .. nameOrTheme .. "', falling back to " .. themeName)
	elseif typeof(nameOrTheme) ~= "string" and typeof(nameOrTheme) ~= "table" and nameOrTheme ~= nil then
		valid = false
		self:_Warn("Theme", "Invalid theme value, falling back to " .. themeName)
	end

	self.Theme = theme
	self.ThemeName = themeName

	for _, window in ipairs(self._windows) do
		window:SetTheme(theme)
	end

	Notify:SetTheme(Context)
	Tooltip:SetTheme(Context)
	Dialog:SetTheme(Context)
	return valid, themeName
end

function MidasUI:CreateWindow(options)
	if options ~= nil and typeof(options) ~= "table" then
		self:_Warn("API", "CreateWindow expected an options table")
		options = {}
	end

	options = options or {}
	self:SetTheme(options.Theme or self.ThemeName)
	return Context.Window.new(Context, options)
end

function MidasUI:GetFlag(flag)
	return Flags:Get(self, flag)
end

function MidasUI:SetFlag(flag, value, fireCallback)
	if typeof(flag) ~= "string" or flag == "" then
		self:_Warn("Flag", "SetFlag ignored: flag must be a non-empty string")
		return false
	end

	Flags:Set(self, flag, value, fireCallback)
	return true
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
		self:_Warn("Dependency", "Ignored invalid DependsOn configuration")
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

function MidasUI:_UnregisterDependencies(element)
	for index = #self._dependencies, 1, -1 do
		if self._dependencies[index].Element == element then
			table.remove(self._dependencies, index)
		end
	end
end

function MidasUI:_ApplyDependency(record)
	local element = record.Element
	if not element or element.Destroyed or not element.Instance then
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
			self:_SetElementVisible(element, passes)
		end
	else
		self:_SetElementVisible(element, passes)
	end
end

function MidasUI:_SetElementVisible(element, visible)
	local instance = element.Instance
	if not instance then
		return
	end

	if visible then
		instance.Visible = true
		if element._midasOriginalSize then
			instance.Size = element._midasOriginalSize
		end
	else
		if element.SetExpanded then
			element:SetExpanded(false, true)
		end

		if instance.Visible then
			element._midasOriginalSize = instance.Size
		end
		instance.Visible = false
		if element._midasOriginalSize then
			instance.Size = UDim2.new(element._midasOriginalSize.X.Scale, element._midasOriginalSize.X.Offset, 0, 0)
		end
	end

	if not visible and self._tooltipFrame then
		Tooltip:Hide(Context)
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
	local ok, err = Config:Load(self, profile)
	self:_RefreshDependencies()
	return ok, err
end

function MidasUI:DeleteConfig(profile)
	return Config:Delete(self, profile)
end

function MidasUI:ListConfigs()
	return Config:List(self)
end

function MidasUI:Notify(options)
	if options ~= nil and typeof(options) ~= "table" then
		self:_Warn("Notification", "Notify expected an options table")
		options = {}
	end
	return Notify:Show(Context, options or {})
end

function MidasUI:Dialog(options)
	if options ~= nil and typeof(options) ~= "table" then
		self:_Warn("Dialog", "Dialog expected an options table")
		options = {}
	end
	return Dialog:Show(Context, options or {})
end

function MidasUI:Info(options)
	local values = typeof(options) == "table" and table.clone(options) or {}
	values.Type = "Info"
	return self:Dialog(values)
end

function MidasUI:Confirm(options)
	local values = typeof(options) == "table" and table.clone(options) or {}
	values.Type = "Confirm"
	return self:Dialog(values)
end

function MidasUI:Prompt(options)
	local values = typeof(options) == "table" and table.clone(options) or {}
	values.Type = "Input"
	return self:Dialog(values)
end

function MidasUI:_CleanupOverlays()
	if self._notifyGui then
		self._notifyGui:Destroy()
		self._notifyGui = nil
		self._notifyHolder = nil
		self._notifications = nil
	end

	if self._tooltipGui then
		Tooltip:Hide(Context)
		self._tooltipGui:Destroy()
		self._tooltipGui = nil
		self._tooltipFrame = nil
		self._tooltipLabel = nil
	end

	if self._tooltipConnections then
		Utility:DisconnectAll(self._tooltipConnections)
	end

	Dialog:Close(Context)
	if self._dialogGui then
		self._dialogGui:Destroy()
		self._dialogGui = nil
	end
end

function MidasUI:_CleanupWindowRuntime()
	self:_CleanupOverlays()

	if self._listeningKeybind then
		self._listeningKeybind = nil
	end

	table.clear(self.Keybinds)

	if self._keybindConnections then
		Utility:DisconnectAll(self._keybindConnections)
	end

	self._keybindsReady = false
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

	self:_CleanupWindowRuntime()

	self._keybindsReady = false
	return self
end

return MidasUI
