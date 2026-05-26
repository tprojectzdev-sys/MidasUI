-- MidasUI V1.9 single-file bundle
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
	sparkle = "*",
	palette = "P",
	command = ">",
	notification = "!",
	dropdown = "v",
	dialog = "D",
}

return Icons
end
ModuleSources["Core/Utility"] = function()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Utility = {}

Utility.Motion = {
	Press = 0.08,
	Fast = 0.12,
	Hover = 0.14,
	Standard = 0.18,
	Toggle = 0.2,
	Overlay = 0.22,
	Reveal = 0.28,
	Window = 0.3,
	Exit = 0.2,
	IntroDrop = 0.34,
}

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
Utility.CustomIcons = {}

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

function Utility:TweenTracked(store, key, instance, duration, properties, style, direction)
	store = store or {}
	local existing = store[key]
	if existing then
		existing:Cancel()
	end

	local tween = self:Tween(instance, duration, properties, style, direction)
	store[key] = tween
	tween.Completed:Connect(function()
		if store[key] == tween then
			store[key] = nil
		end
	end)
	return tween
end

function Utility:CancelTweens(store)
	for key, tween in pairs(store or {}) do
		if tween then
			tween:Cancel()
		end
		store[key] = nil
	end
end

function Utility:RegisterIcon(name, definition)
	if typeof(name) ~= "string" or name == "" then
		return false, "Icon name must be a non-empty string"
	end

	local key = string.lower(name)
	if typeof(definition) == "number" then
		self.CustomIcons[key] = { Image = "rbxassetid://" .. tostring(definition) }
	elseif typeof(definition) == "string" and string.find(definition, "^rbxassetid://") then
		self.CustomIcons[key] = { Image = definition }
	elseif typeof(definition) == "string" and definition ~= "" then
		self.CustomIcons[key] = { Text = definition }
	elseif typeof(definition) == "table" then
		local image = definition.Image or definition.AssetId
		if typeof(image) == "number" then
			image = "rbxassetid://" .. tostring(image)
		end
		if typeof(image) == "string" and image ~= "" then
			local rectOffset = definition.ImageRectOffset or definition.RectOffset
			local rectSize = definition.ImageRectSize or definition.RectSize
			self.CustomIcons[key] = {
				Image = image,
				ImageRectOffset = typeof(rectOffset) == "Vector2" and rectOffset or nil,
				ImageRectSize = typeof(rectSize) == "Vector2" and rectSize or nil,
			}
		elseif typeof(definition.Text) == "string" and definition.Text ~= "" then
			self.CustomIcons[key] = { Text = definition.Text }
		else
			return false, "Icon definition must contain Image, AssetId, or Text"
		end
	else
		return false, "Icon definition must be text, asset id, or a definition table"
	end
	return true, key
end

function Utility:ResolveIcon(icon)
	if typeof(icon) == "number" then
		return { Image = "rbxassetid://" .. tostring(icon) }
	end
	if typeof(icon) == "table" then
		local temporaryName = "__direct"
		local previous = self.CustomIcons[temporaryName]
		local ok = self:RegisterIcon(temporaryName, icon)
		local resolved = ok and self.CustomIcons[temporaryName] or nil
		self.CustomIcons[temporaryName] = previous
		return resolved
	end
	if typeof(icon) ~= "string" or icon == "" then
		return nil
	end
	if string.find(icon, "^rbxassetid://") then
		return { Image = icon }
	end
	local lower = string.lower(icon)
	if self.CustomIcons[lower] then
		return self.CustomIcons[lower]
	end
	if self.IconGlyphs[lower] then
		return { Text = self.IconGlyphs[lower] }
	end
	return { Text = string.upper(string.sub(icon, 1, 1)) }
end

function Utility:IconText(icon)
	local resolved = self:ResolveIcon(icon)
	return resolved and resolved.Text or ""
end

function Utility:CreateIcon(parent, icon, properties)
	properties = properties or {}
	local color = properties.Color or Color3.new(1, 1, 1)
	local root = self:Create("Frame", {
		Name = properties.Name or "Icon",
		Position = properties.Position or UDim2.fromOffset(0, 0),
		Size = properties.Size or UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1,
		ZIndex = properties.ZIndex or (parent and parent.ZIndex or 1),
		Parent = parent,
	})
	local glyph = self:Create("TextLabel", {
		Name = "Glyph",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = properties.Font or Enum.Font.GothamBold,
		Text = "",
		TextColor3 = color,
		TextSize = properties.TextSize or 13,
		ZIndex = root.ZIndex,
		Parent = root,
	})
	local image = self:Create("ImageLabel", {
		Name = "Image",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = "",
		ImageColor3 = color,
		ScaleType = Enum.ScaleType.Fit,
		Visible = false,
		ZIndex = root.ZIndex,
		Parent = root,
	})
	self:SetIcon(root, icon, color)
	return root
end

function Utility:SetIcon(root, icon, color)
	if not root then
		return
	end
	local resolved = self:ResolveIcon(icon)
	local glyph = root:FindFirstChild("Glyph")
	local image = root:FindFirstChild("Image")
	if glyph then
		glyph.Text = resolved and resolved.Text or ""
		glyph.TextColor3 = color or glyph.TextColor3
		glyph.Visible = resolved ~= nil and resolved.Text ~= nil
	end
	if image then
		image.Image = resolved and resolved.Image or ""
		image.ImageColor3 = color or image.ImageColor3
		image.ImageRectOffset = resolved and resolved.ImageRectOffset or Vector2.new(0, 0)
		image.ImageRectSize = resolved and resolved.ImageRectSize or Vector2.new(0, 0)
		image.Visible = resolved ~= nil and resolved.Image ~= nil
	end
end

function Utility:SetIconColor(root, color)
	if not root then
		return
	end
	local glyph = root:FindFirstChild("Glyph")
	local image = root:FindFirstChild("Image")
	if glyph then
		glyph.TextColor3 = color
	end
	if image then
		image.ImageColor3 = color
	end
end

function Utility:SetIconTransparency(root, transparency)
	if not root then
		return
	end
	local glyph = root:FindFirstChild("Glyph")
	local image = root:FindFirstChild("Image")
	if glyph then
		glyph.TextTransparency = transparency
	end
	if image then
		image.ImageTransparency = transparency
	end
end

function Utility:CreateCrownMark(parent, theme, size)
	size = size or 30
	local root = self:Create("Frame", {
		Name = "CrownMark",
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = theme.AccentSoft,
		BackgroundTransparency = 0.18,
		Parent = parent,
	})
	self:Corner(root, math.floor(size * 0.25))
	self:Stroke(root, theme.Stroke, 0.12, 1)

	local scale = size / 30
	local function piece(name, position, pieceSize, rotation, color)
		local item = self:Create("Frame", {
			Name = name,
			Position = UDim2.fromOffset(position[1] * scale, position[2] * scale),
			Size = UDim2.fromOffset(pieceSize[1] * scale, pieceSize[2] * scale),
			Rotation = rotation or 0,
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Parent = root,
		})
		self:Corner(item, math.max(1, math.floor(scale)))
		return item
	end

	piece("Accent", { 6, 19 }, { 18, 4 }, 0, theme.Accent)
	piece("Accent", { 7, 12 }, { 3, 10 }, -25, theme.Accent)
	piece("Accent", { 20, 12 }, { 3, 10 }, 25, theme.Accent)
	piece("Highlight", { 13, 7 }, { 4, 15 }, 0, theme.Highlight)
	piece("Accent", { 11, 17 }, { 8, 7 }, 0, theme.Accent)
	piece("Highlight", { 14, 20 }, { 2, 2 }, 0, theme.Highlight)
	return root
end

function Utility:ApplyCrownTheme(mark, theme)
	if not mark then
		return
	end

	mark.BackgroundColor3 = theme.AccentSoft
	self:ApplyStrokeTheme(mark, theme.Stroke)
	for _, item in ipairs(mark:GetChildren()) do
		if item:IsA("Frame") and item.Name == "Accent" then
			item.BackgroundColor3 = theme.Accent
		elseif item:IsA("Frame") and item.Name == "Highlight" then
			item.BackgroundColor3 = theme.Highlight
		end
	end
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
		if options.OnDragStart then
			options.OnDragStart()
		end
	end)

	self:Connect(connections, UserInputService.InputChanged, function(input)
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - dragStart
		if options.OnDragMove then
			options.OnDragMove(delta)
		end
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
			if options.OnDragEnd then
				options.OnDragEnd()
			end
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
	"AccentSoft",
	"Highlight",
	"Text",
	"MutedText",
	"Stroke",
	"Shadow",
	"Danger",
	"Success",
}

Theme.Registry = {
	DarkGold = {
		Background = Color3.fromRGB(10, 10, 11),
		Topbar = Color3.fromRGB(30, 25, 17),
		Sidebar = Color3.fromRGB(16, 15, 14),
		Card = Color3.fromRGB(28, 24, 18),
		Accent = Color3.fromRGB(231, 183, 68),
		AccentSoft = Color3.fromRGB(72, 52, 19),
		Highlight = Color3.fromRGB(255, 222, 134),
		Text = Color3.fromRGB(252, 248, 239),
		MutedText = Color3.fromRGB(188, 171, 139),
		Stroke = Color3.fromRGB(112, 81, 35),
		Shadow = Color3.fromRGB(3, 3, 4),
		Danger = Color3.fromRGB(226, 82, 82),
		Success = Color3.fromRGB(78, 188, 121),
	},

	Midnight = {
		Background = Color3.fromRGB(7, 10, 18),
		Topbar = Color3.fromRGB(13, 20, 36),
		Sidebar = Color3.fromRGB(9, 14, 26),
		Card = Color3.fromRGB(17, 25, 42),
		Accent = Color3.fromRGB(94, 152, 255),
		AccentSoft = Color3.fromRGB(25, 48, 90),
		Highlight = Color3.fromRGB(169, 204, 255),
		Text = Color3.fromRGB(239, 245, 255),
		MutedText = Color3.fromRGB(146, 163, 194),
		Stroke = Color3.fromRGB(46, 68, 108),
		Shadow = Color3.fromRGB(3, 5, 11),
		Danger = Color3.fromRGB(235, 91, 105),
		Success = Color3.fromRGB(72, 191, 143),
	},

	BlackWhite = {
		Background = Color3.fromRGB(7, 7, 8),
		Topbar = Color3.fromRGB(21, 21, 23),
		Sidebar = Color3.fromRGB(13, 13, 15),
		Card = Color3.fromRGB(27, 27, 30),
		Accent = Color3.fromRGB(235, 235, 238),
		AccentSoft = Color3.fromRGB(55, 55, 59),
		Highlight = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(247, 247, 247),
		MutedText = Color3.fromRGB(164, 164, 169),
		Stroke = Color3.fromRGB(74, 74, 80),
		Shadow = Color3.fromRGB(2, 2, 3),
		Danger = Color3.fromRGB(232, 78, 78),
		Success = Color3.fromRGB(108, 198, 133),
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
ModuleSources["Core/Templates"] = function()
local Templates = {}

Templates.Registry = {
	Default = {
		Name = "Default",
		Compact = false,
		Dashboard = false,
		Dense = false,
		PagePadding = 14,
		PageSpacing = 10,
		CanvasPadding = 28,
		SectionPadding = 12,
		SectionSpacing = 8,
		SectionTitleSize = 13,
		SectionTransparency = 0,
		DefaultSize = UDim2.fromOffset(620, 460),
	},

	FarmingDashboard = {
		Name = "FarmingDashboard",
		Compact = false,
		Dashboard = true,
		Dense = false,
		PagePadding = 12,
		PageSpacing = 10,
		CanvasPadding = 24,
		SectionPadding = 14,
		SectionSpacing = 10,
		SectionTitleSize = 13,
		SectionTransparency = 0,
		DefaultSize = UDim2.fromOffset(760, 560),
	},

	PowerPanel = {
		Name = "PowerPanel",
		Compact = true,
		Dashboard = false,
		Dense = true,
		PagePadding = 10,
		PageSpacing = 7,
		CanvasPadding = 20,
		SectionPadding = 9,
		SectionSpacing = 5,
		SectionTitleSize = 12,
		SectionTransparency = 0.03,
		DefaultSize = UDim2.fromOffset(760, 540),
	},
}

local numericKeys = {
	"PagePadding",
	"PageSpacing",
	"CanvasPadding",
	"SectionPadding",
	"SectionSpacing",
	"SectionTitleSize",
	"SectionTransparency",
}

function Templates:Normalize(values, name)
	values = typeof(values) == "table" and values or self.Registry.Default
	local base = self.Registry.Default
	local normalized = {
		Name = tostring(name or values.Name or "Custom"),
		Compact = values.Compact == true,
		Dashboard = values.Dashboard == true,
		Dense = values.Dense == true,
		DefaultSize = typeof(values.DefaultSize) == "UDim2" and values.DefaultSize or base.DefaultSize,
	}

	for _, key in ipairs(numericKeys) do
		normalized[key] = tonumber(values[key]) or base[key]
	end

	return normalized
end

function Templates:Get(nameOrTemplate)
	if typeof(nameOrTemplate) == "table" then
		return self:Normalize(nameOrTemplate, "Custom"), "Custom", true
	end

	local name = typeof(nameOrTemplate) == "string" and nameOrTemplate or "Default"
	local preset = self.Registry[name]
	if preset then
		return self:Normalize(preset, name), name, true
	end

	return self:Normalize(self.Registry.Default, "Default"), "Default", false
end

return Templates
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

function Flags:Set(library, flag, value, fireCallback, instant)
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
				primary:SetValue(value, shouldFire, instant)
				value = primary.GetValue and primary:GetValue() or value
			end

			for index = 2, #controllers do
				local controller = controllers[index]
				if controller.SetValue then
					controller:SetValue(value, shouldFire, instant)
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
		DisplayOrder = 220,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = utility:GetGuiParent(),
	})
	local holder = utility:Create("Frame", {
		Name = "Holder",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 18),
		Size = UDim2.fromOffset(322, 0),
		BackgroundTransparency = 1,
		Parent = gui,
	})
	utility:List(holder, 9)
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
	local tweens = {}
	local connections = {}
	local record = { Tweens = tweens, Connections = connections, Closing = false }

	while #library._notifications >= 6 do
		local oldest = table.remove(library._notifications, 1)
		if oldest and oldest.Close then
			oldest:Close(true)
		end
	end

	local frame = utility:Create("Frame", {
		Name = "Notification",
		Size = UDim2.new(1, 0, 0, contentText == "" and 70 or 88),
		BackgroundColor3 = theme.Card,
		BackgroundTransparency = 0.02,
		Position = UDim2.fromOffset(342, 0),
		Parent = library._notifyHolder,
	})
	utility:Corner(frame, 11)
	utility:Stroke(frame, theme.Stroke, 0.16)
	utility:Padding(frame, { X = 14, Y = 11 })
	record.Frame = frame

	local icon
	local left = 0
	if options.Icon ~= nil then
		icon = utility:CreateIcon(frame, options.Icon, {
			Position = UDim2.fromOffset(0, 2),
			Size = UDim2.fromOffset(20, 20),
			Color = theme.Accent,
			TextSize = 13,
		})
		left = 29
	end
	local title = utility:Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(left, 0),
		Size = UDim2.new(1, -(left + 28), 0, 22),
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
		Position = UDim2.fromOffset(left, 27),
		Size = UDim2.new(1, -(left + 4), 0, contentText == "" and 0 or 34),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = contentText,
		TextColor3 = theme.MutedText,
		TextSize = 12,
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
	local close = utility:Create("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 1),
		Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "x",
		TextColor3 = theme.MutedText,
		TextSize = 11,
		AutoButtonColor = false,
		Parent = frame,
	})
	local progress = utility:Create("Frame", {
		Name = "Progress",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0.28,
		BorderSizePixel = 0,
		Parent = frame,
	})
	utility:Corner(progress, 2)

	function record:Close(instant)
		if self.Closing then
			return
		end
		self.Closing = true
		for index = #library._notifications, 1, -1 do
			if library._notifications[index] == self then
				table.remove(library._notifications, index)
				break
			end
		end
		utility:DisconnectAll(self.Connections)
		if instant or not frame.Parent then
			utility:CancelTweens(tweens)
			if frame.Parent then
				frame:Destroy()
			end
			return
		end
		utility:TweenTracked(tweens, "Title", title, utility.Motion.Fast, { TextTransparency = 1 })
		utility:TweenTracked(tweens, "Content", content, utility.Motion.Fast, { TextTransparency = 1 })
		if icon then
			utility:TweenTracked(tweens, "Icon", icon, utility.Motion.Fast, { BackgroundTransparency = 1 })
		end
		local exit = utility:TweenTracked(tweens, "Frame", frame, utility.Motion.Exit, {
			Position = UDim2.fromOffset(344, 0),
			BackgroundTransparency = 1,
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		exit.Completed:Connect(function()
			utility:CancelTweens(tweens)
			if frame.Parent then
				frame:Destroy()
			end
		end)
	end

	local controller = {}
	function controller:Close()
		record:Close(false)
		return self
	end

	utility:Connect(connections, close.MouseEnter, function()
		utility:TweenTracked(tweens, "Close", close, utility.Motion.Hover, { TextColor3 = library.Theme.Text })
	end)
	utility:Connect(connections, close.MouseLeave, function()
		utility:TweenTracked(tweens, "Close", close, utility.Motion.Hover, { TextColor3 = library.Theme.MutedText })
	end)
	utility:Connect(connections, close.MouseButton1Click, function()
		record:Close(false)
	end)

	title.TextTransparency = 1
	content.TextTransparency = 1
	frame.BackgroundTransparency = 1
	table.insert(library._notifications, record)
	utility:TweenTracked(tweens, "Frame", frame, utility.Motion.Reveal, {
		Position = UDim2.fromOffset(-7, 0),
		BackgroundTransparency = 0.02,
	}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	utility:TweenTracked(tweens, "Title", title, utility.Motion.Standard, { TextTransparency = 0 })
	utility:TweenTracked(tweens, "Content", content, utility.Motion.Standard, { TextTransparency = 0 })
	task.delay(utility.Motion.Standard, function()
		if frame.Parent and not record.Closing then
			utility:TweenTracked(tweens, "Frame", frame, utility.Motion.Hover, {
				Position = UDim2.fromOffset(0, 0),
			}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end)
	utility:TweenTracked(tweens, "Progress", progress, duration, {
		Size = UDim2.new(0, 0, 0, 2),
	}, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	task.delay(duration, function()
		if frame.Parent then
			record:Close(false)
		end
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
			for _, item in ipairs(frame:GetChildren()) do
				if item.Name == "Title" then
					item.TextColor3 = theme.Text
				elseif item.Name == "Content" or item.Name == "Close" then
					item.TextColor3 = theme.MutedText
				elseif item.Name == "Accent" or item.Name == "Progress" then
					item.BackgroundColor3 = theme.Accent
				elseif item.Name == "Icon" then
					context.Utility:SetIconColor(item, theme.Accent)
				end
			end
		end
	end
end

function Notify:Destroy(context)
	local library = context.Library
	for _, record in ipairs(table.clone(library._notifications or {})) do
		if record and record.Close then
			record:Close(true)
		end
	end
	if library._notifyGui then
		library._notifyGui:Destroy()
		library._notifyGui = nil
	end
	library._notifyHolder = nil
	library._notifications = nil
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
		DisplayOrder = 300,
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
	library._tooltipTweens = library._tooltipTweens or {}

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

	local library = context.Library
	if library._activeDialog or library._activePalette
		or (library._expandedDropdown and library._expandedDropdown.Expanded) then
		self:Hide(context)
		return
	end

	self:Init(context)

	local frame = library._tooltipFrame
	local label = library._tooltipLabel

	frame.BackgroundColor3 = library.Theme.Card
	label.TextColor3 = library.Theme.Text
	label.Text = tostring(text)
	frame.Visible = true
	frame.BackgroundTransparency = 1
	context.Utility:TweenTracked(library._tooltipTweens, "Frame", frame, context.Utility.Motion.Fast, { BackgroundTransparency = 0.02 })
	self:Position(context, UserInputService:GetMouseLocation())
end

function Tooltip:Hide(context)
	local library = context.Library
	local frame = library._tooltipFrame
	if frame then
		context.Utility:CancelTweens(library._tooltipTweens)
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
local Keybinds = {}

function Keybinds:Init(library)
	if library._EnsureShortcuts then
		library:_EnsureShortcuts()
	end
	library._keybindsReady = true
end

function Keybinds:HandleInputBegan(library, input, processed)
	if library._activeDialog or library._activePalette
		or (library._expandedDropdown and library._expandedDropdown.Expanded) then
		return false
	end

	local listening = library._listeningKeybind
	if listening then
		listening:CaptureInput(input.KeyCode)
		return true
	end

	if processed or game:GetService("UserInputService"):GetFocusedTextBox() then
		return false
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
	return false
end

function Keybinds:HandleInputEnded(library, input)
	for _, bind in pairs(library.Keybinds) do
		if bind.KeyCode ~= nil and bind.KeyCode == input.KeyCode and bind.Holding then
			bind.Holding = false

			if bind.Mode == "Hold" and bind.Enabled ~= false then
				library:_InvokeCallback("Keybind", bind.Callback, false, bind.KeyCode)
			end
		end
	end
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
ModuleSources["Core/Shortcuts"] = function()
local UserInputService = game:GetService("UserInputService")

local Shortcuts = {}

local MODIFIER_KEYS = {
	[Enum.KeyCode.LeftControl] = "Ctrl",
	[Enum.KeyCode.RightControl] = "Ctrl",
	[Enum.KeyCode.LeftShift] = "Shift",
	[Enum.KeyCode.RightShift] = "Shift",
	[Enum.KeyCode.LeftAlt] = "Alt",
	[Enum.KeyCode.RightAlt] = "Alt",
}

local function keyCodeFromString(value)
	for _, keyCode in ipairs(Enum.KeyCode:GetEnumItems()) do
		if string.lower(keyCode.Name) == string.lower(value) then
			return keyCode
		end
	end
	return nil
end

function Shortcuts:Normalize(value)
	if value == nil or value == false then
		return nil, nil
	end

	local descriptor = {
		Ctrl = false,
		Shift = false,
		Alt = false,
	}

	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
		descriptor.KeyCode = value
	elseif typeof(value) == "string" then
		for token in string.gmatch(value, "[^+%s]+") do
			local lowerToken = string.lower(token)
			if lowerToken == "ctrl" or lowerToken == "control" then
				descriptor.Ctrl = true
			elseif lowerToken == "shift" then
				descriptor.Shift = true
			elseif lowerToken == "alt" then
				descriptor.Alt = true
			else
				descriptor.KeyCode = keyCodeFromString(token)
				if not descriptor.KeyCode then
					return nil, "Unknown shortcut key '" .. tostring(token) .. "'"
				end
			end
		end
	elseif typeof(value) == "table" then
		descriptor.KeyCode = value.KeyCode or value.Key
		descriptor.Ctrl = value.Ctrl == true or value.Control == true
		descriptor.Shift = value.Shift == true
		descriptor.Alt = value.Alt == true
	else
		return nil, "Shortcut must be a KeyCode, string, table, false, or nil"
	end

	if typeof(descriptor.KeyCode) ~= "EnumItem" or descriptor.KeyCode.EnumType ~= Enum.KeyCode
		or descriptor.KeyCode == Enum.KeyCode.Unknown then
		return nil, "Shortcut must include a valid KeyCode"
	end

	return descriptor, nil
end

function Shortcuts:Format(descriptor)
	if not descriptor then
		return "Disabled"
	end

	local parts = {}
	if descriptor.Ctrl then
		table.insert(parts, "Ctrl")
	end
	if descriptor.Shift then
		table.insert(parts, "Shift")
	end
	if descriptor.Alt then
		table.insert(parts, "Alt")
	end
	table.insert(parts, descriptor.KeyCode.Name)
	return table.concat(parts, "+")
end

function Shortcuts:Matches(descriptor, input)
	if not descriptor or not input or descriptor.KeyCode ~= input.KeyCode then
		return false
	end

	local ownModifier = MODIFIER_KEYS[descriptor.KeyCode]
	local ctrlDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
	local shiftDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	local altDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)

	return (ownModifier == "Ctrl" or ctrlDown == descriptor.Ctrl)
		and (ownModifier == "Shift" or shiftDown == descriptor.Shift)
		and (ownModifier == "Alt" or altDown == descriptor.Alt)
end

function Shortcuts:Set(library, id, value, callback, options)
	library._shortcuts = library._shortcuts or {}
	options = options or {}

	if value == nil or value == false then
		library._shortcuts[id] = nil
		return true, "Disabled"
	end

	local descriptor, err = self:Normalize(value)
	if not descriptor then
		library:_Warn("Shortcut", "Ignored shortcut '" .. tostring(id) .. "': " .. tostring(err))
		return false, err
	end
	if typeof(callback) ~= "function" then
		library:_Warn("Shortcut", "Ignored shortcut '" .. tostring(id) .. "': callback must be a function")
		return false, "Shortcut callback must be a function"
	end

	library._shortcutSequence = (library._shortcutSequence or 0) + 1
	library._shortcuts[id] = {
		Id = id,
		Shortcut = descriptor,
		Display = self:Format(descriptor),
		Callback = callback,
		Owner = options.Owner,
		Priority = tonumber(options.Priority) or 0,
		Sequence = library._shortcutSequence,
	}
	return true, library._shortcuts[id].Display
end

function Shortcuts:RemoveOwner(library, owner)
	for id, record in pairs(library._shortcuts or {}) do
		if record.Owner == owner then
			library._shortcuts[id] = nil
		end
	end
end

function Shortcuts:GetState(library)
	local items = {}
	for id, record in pairs(library._shortcuts or {}) do
		if not record.Owner or (not record.Owner.Destroyed and not record.Owner.Closed) then
			table.insert(items, {
				Id = id,
				Display = record.Display,
				Owner = record.Owner,
			})
		end
	end
	table.sort(items, function(left, right)
		return left.Id < right.Id
	end)
	return items
end

function Shortcuts:_DispatchFramework(context, input, processed)
	local library = context.Library
	local activePalette = library._activePalette
	local focused = UserInputService:GetFocusedTextBox()
	local paletteFocus = activePalette and focused == activePalette.SearchBox

	if library._activeDialog or (library._expandedDropdown and library._expandedDropdown.Expanded) then
		return false
	end
	if focused and not paletteFocus then
		return false
	end
	if processed and not activePalette then
		return false
	end

	local matches = {}
	for id, record in pairs(library._shortcuts or {}) do
		if record.Owner and (record.Owner.Destroyed or record.Owner.Closed) then
			library._shortcuts[id] = nil
		elseif (not activePalette or id == "command_palette") and self:Matches(record.Shortcut, input) then
			table.insert(matches, record)
		end
	end
	table.sort(matches, function(left, right)
		if left.Priority == right.Priority then
			return left.Sequence > right.Sequence
		end
		return left.Priority > right.Priority
	end)

	local record = matches[1]
	if not record then
		return false
	end

	local ok, err = pcall(record.Callback)
	if not ok then
		library:_Warn("Shortcut", "Callback failed: " .. tostring(err))
	end
	return true
end

function Shortcuts:Init(context)
	local library = context.Library
	if library._shortcutsReady then
		return
	end

	library._shortcutsReady = true
	library._shortcutConnections = library._shortcutConnections or {}
	context.Utility:Connect(library._shortcutConnections, UserInputService.InputBegan, function(input, processed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard or library._destroyed then
			return
		end

		if library._listeningKeybind then
			context.Keybinds:HandleInputBegan(library, input, processed)
			return
		end

		if not Shortcuts:_DispatchFramework(context, input, processed) then
			context.Keybinds:HandleInputBegan(library, input, processed)
		end
	end)
	context.Utility:Connect(library._shortcutConnections, UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			context.Keybinds:HandleInputEnded(library, input)
		end
	end)
end

function Shortcuts:Destroy(context)
	local library = context.Library
	context.Utility:DisconnectAll(library._shortcutConnections)
	table.clear(library._shortcuts or {})
	library._shortcutsReady = false
end

return Shortcuts
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
		DisplayOrder = 400,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = utility:GetGuiParent(),
	})

	library._dialogGui = gui
end

function Dialog:Close(context, controller, instant)
	local library = context.Library
	local dialog = library._activeDialog
	if controller and dialog and dialog.Controller ~= controller then
		return
	end
	if not dialog then
		return
	end
	library._activeDialog = nil
	context.Utility:DisconnectAll(dialog.Connections)
	if instant or not dialog.Gui or not dialog.Gui.Parent then
		context.Utility:CancelTweens(dialog.Tweens)
		if dialog.Gui and dialog.Gui.Parent then
			dialog.Gui:Destroy()
		end
		return
	end
	library._closingDialog = dialog
	context.Utility:TweenTracked(dialog.Tweens, "Overlay", dialog.Gui, context.Utility.Motion.Exit, {
		BackgroundTransparency = 1,
	}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	context.Utility:TweenTracked(dialog.Tweens, "Scale", dialog.Scale, context.Utility.Motion.Exit, {
		Scale = 0.975,
	}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local exit = context.Utility:TweenTracked(dialog.Tweens, "Card", dialog.Card, context.Utility.Motion.Exit, {
		Position = UDim2.fromScale(0.5, 0.48),
	}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	exit.Completed:Connect(function()
		context.Utility:CancelTweens(dialog.Tweens)
		if dialog.Gui and dialog.Gui.Parent then
			dialog.Gui:Destroy()
		end
		if library._closingDialog == dialog then
			library._closingDialog = nil
		end
	end)
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
	if dialog.Gradient then
		dialog.Gradient.Color = ColorSequence.new(theme.Card, theme.Background)
	end
	if dialog.Title then
		dialog.Title.TextColor3 = theme.Text
	end
	if dialog.Content then
		dialog.Content.TextColor3 = theme.MutedText
	end
	if dialog.Signal then
		dialog.Signal.BackgroundColor3 = dialog.Danger and theme.Danger or theme.Accent
	end
	if dialog.Icon then
		context.Utility:SetIconColor(dialog.Icon, dialog.Danger and theme.Danger or theme.Accent)
	end
	if dialog.Input then
		dialog.Input.BackgroundColor3 = theme.Background
		dialog.Input.TextColor3 = theme.Text
		dialog.Input.PlaceholderColor3 = theme.MutedText
		context.Utility:ApplyStrokeTheme(dialog.Input, dialog.Input:IsFocused() and theme.Accent or theme.Stroke)
	end
	for _, button in ipairs(dialog.Buttons or {}) do
		local primaryColor = dialog.Danger and theme.Danger or theme.Accent
		button.BackgroundColor3 = button.Name == "Confirm" and primaryColor or theme.Background
		button.TextColor3 = button.Name == "Confirm" and theme.Background or theme.Text
		context.Utility:ApplyStrokeTheme(button, button.Name == "Confirm" and primaryColor or theme.Stroke)
	end
end

function Dialog:Show(context, options)
	options = options or {}
	self:Init(context)
	self:Close(context, nil, true)
	if context.Library._closingDialog then
		context.Utility:CancelTweens(context.Library._closingDialog.Tweens)
		if context.Library._closingDialog.Gui and context.Library._closingDialog.Gui.Parent then
			context.Library._closingDialog.Gui:Destroy()
		end
		context.Library._closingDialog = nil
	end

	local library = context.Library
	local utility = context.Utility
	local theme = library.Theme
	local dialogType = options.Type or "Info"
	if dialogType ~= "Info" and dialogType ~= "Confirm" and dialogType ~= "Input" then
		library:_Warn("Dialog", "Unknown dialog type '" .. tostring(dialogType) .. "'; using Info")
		dialogType = "Info"
	end
	local danger = options.Danger == true or options.Variant == "Danger" or options.Style == "Danger"
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
		ZIndex = 100,
		Parent = library._dialogGui,
	})

	local card = utility:Create("Frame", {
		Name = "Dialog",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(380, dialogType == "Input" and 218 or 178),
		BackgroundColor3 = theme.Card,
		ZIndex = 101,
		Parent = overlay,
	})
	utility:Corner(card, 12)
	utility:Stroke(card, theme.Stroke, 0.18)
	utility:Padding(card, { X = 18, Y = 16 })
	local cardGradient = utility:Create("UIGradient", {
		Color = ColorSequence.new(theme.Card, theme.Background),
		Rotation = 90,
		Parent = card,
	})

	local headingLeft = options.Icon ~= nil and 31 or 0
	local icon = options.Icon ~= nil and utility:CreateIcon(card, options.Icon, {
		Position = UDim2.fromOffset(0, 2),
		Size = UDim2.fromOffset(20, 20),
		Color = danger and theme.Danger or theme.Accent,
		TextSize = 13,
		ZIndex = 102,
	}) or nil
	local title = utility:Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(headingLeft, 0),
		Size = UDim2.new(1, -(headingLeft + 4), 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = tostring(options.Title or "MidasUI"),
		TextColor3 = theme.Text,
		TextSize = 16,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 102,
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
		ZIndex = 102,
		Parent = card,
	})
	local signal = utility:Create("Frame", {
		Name = "Signal",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(danger and 3 or 0, dialogType == "Input" and 186 or 146),
		BackgroundColor3 = danger and theme.Danger or theme.Accent,
		ZIndex = 102,
		Parent = card,
	})
	utility:Corner(signal, 2)

	local inputBox
	local inputStroke
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
			ZIndex = 102,
			Parent = card,
		})
		utility:Corner(inputBox, 8)
		inputStroke = utility:Stroke(inputBox, theme.Stroke, 0.5)
		utility:Padding(inputBox, { X = 10 })
	end

	local buttonRow = utility:Create("Frame", {
		Name = "Actions",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		ZIndex = 102,
		Parent = card,
	})
	utility:List(buttonRow, 8, true)

	local controller = {}
	local buttons = {}
	local connections = {}
	local buttonActions = {}
	local tweens = {}
	local scale = utility:Create("UIScale", {
		Scale = 0.97,
		Parent = card,
	})

	function controller:Close()
		Dialog:Close(context, self)
		return self
	end

	local function addButton(name, text, primary, callback)
		local primaryColor = danger and theme.Danger or theme.Accent
		local button = utility:Create("TextButton", {
			Name = name,
			Size = UDim2.fromOffset(112, 34),
			BackgroundColor3 = primary and primaryColor or theme.Background,
			Font = Enum.Font.GothamMedium,
			Text = tostring(text),
			TextColor3 = primary and theme.Background or theme.Text,
			TextSize = 13,
			AutoButtonColor = false,
			ZIndex = 103,
			Parent = buttonRow,
		})
		utility:Corner(button, 8)
		utility:Stroke(button, primary and primaryColor or theme.Stroke, primary and 0.2 or 0.5)
		table.insert(buttons, button)
		utility:Connect(connections, button.MouseEnter, function()
			local activeTheme = library.Theme
			local color = primary and (danger and activeTheme.Danger or activeTheme.Accent) or activeTheme.Topbar
			utility:TweenTracked(tweens, name .. "Hover", button, utility.Motion.Hover, { BackgroundColor3 = color })
		end)
		utility:Connect(connections, button.MouseLeave, function()
			local color = primary and primaryColor or library.Theme.Background
			utility:TweenTracked(tweens, name .. "Hover", button, utility.Motion.Hover, { BackgroundColor3 = color })
		end)

		buttonActions[name] = function()
			if callback ~= nil then
				if dialogType == "Input" and name == "Confirm" then
					library:_InvokeCallback("Dialog", callback, inputBox and inputBox.Text or "")
				else
					library:_InvokeCallback("Dialog", callback)
				end
			end
			controller:Close()
		end
		utility:Connect(connections, button.MouseButton1Click, buttonActions[name])
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
		Danger = danger,
		Signal = signal,
		Icon = icon,
		Gradient = cardGradient,
		Scale = scale,
		Connections = connections,
		Tweens = tweens,
		Controller = controller,
	}

	utility:Connect(connections, game:GetService("UserInputService").InputBegan, function(input)
		if library._activeDialog == nil or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if input.KeyCode == Enum.KeyCode.Escape then
			if buttonActions.Cancel then
				buttonActions.Cancel()
			else
				controller:Close()
			end
		elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
			if buttonActions.Confirm then
				buttonActions.Confirm()
			end
		end
	end)
	if inputBox and inputStroke then
		utility:Connect(connections, inputBox.Focused, function()
			inputStroke.Color = library.Theme.Accent
			inputStroke.Transparency = 0.1
		end)
		utility:Connect(connections, inputBox.FocusLost, function()
			inputStroke.Color = library.Theme.Stroke
			inputStroke.Transparency = 0.5
		end)
	end
	utility:Connect(connections, overlay.MouseButton1Click, function()
		controller:Close()
	end)

	overlay.BackgroundTransparency = 1
	card.Position = UDim2.fromScale(0.5, 0.48)
	utility:TweenTracked(tweens, "Overlay", overlay, utility.Motion.Overlay, { BackgroundTransparency = 0.42 })
	utility:TweenTracked(tweens, "Card", card, utility.Motion.Reveal, { Position = UDim2.fromScale(0.5, 0.5) }, Enum.EasingStyle.Quart)
	utility:TweenTracked(tweens, "Scale", scale, utility.Motion.Reveal, { Scale = 1 }, Enum.EasingStyle.Quart)
	if inputBox then
		inputBox:CaptureFocus()
	end

	return controller
end

function Dialog:Destroy(context)
	local library = context.Library
	self:Close(context, nil, true)
	if library._closingDialog then
		context.Utility:CancelTweens(library._closingDialog.Tweens)
		if library._closingDialog.Gui and library._closingDialog.Gui.Parent then
			library._closingDialog.Gui:Destroy()
		end
		library._closingDialog = nil
	end
	if library._dialogGui then
		library._dialogGui:Destroy()
		library._dialogGui = nil
	end
end

return Dialog
end
ModuleSources["Core/Commands"] = function()
local Commands = {}

local function lower(value)
	return string.lower(tostring(value or ""))
end

local function objectExists(object, kind)
	if not object or object.Destroyed or object.Closed then
		return false
	end

	if kind == "Window" then
		return object.Gui ~= nil and object.Gui.Parent ~= nil
	elseif kind == "Tab" then
		return object.Button ~= nil and object.Button.Parent ~= nil
	elseif kind == "Section" then
		return object.Frame ~= nil and object.Frame.Parent ~= nil
	end

	return object.Instance ~= nil and object.Instance.Parent ~= nil
end

local function isLiveObject(object, kind)
	if not objectExists(object, kind) then
		return false
	end
	if kind == "Tab" then
		return object.Button.Visible
	elseif kind == "Section" then
		return object.Frame.Visible and (not object.Tab.Button or object.Tab.Button.Visible)
	elseif kind ~= "Window" then
		local section = object.Section
		local tab = section and section.Tab
		return object.Instance.Visible
			and (not section or section.Frame.Visible)
			and (not tab or not tab.Button or tab.Button.Visible)
	end
	return true
end

local function getTitle(object, kind)
	if kind == "Window" then
		return object.Title or "Window"
	end
	return object.Name or kind
end

local function getDescription(object, kind)
	if kind == "Window" then
		return object.Subtitle or "Open window"
	elseif kind == "Tab" then
		return "Open tab in " .. tostring(object.Window and object.Window.Title or "window")
	elseif kind == "Section" then
		return "Open section in " .. tostring(object.Tab and object.Tab.Name or "tab")
	end

	local section = object.Section
	return "Find control in " .. tostring(section and section.Name or "section")
end

local function searchableText(result)
	local keywords = result.Keywords
	if typeof(keywords) == "table" then
		keywords = table.concat(keywords, " ")
	end

	return lower(result.Title)
		.. " "
		.. lower(result.Description)
		.. " "
		.. lower(result.Category)
		.. " "
		.. lower(keywords)
end

local function fuzzyContains(text, token)
	local index = 1
	for character in string.gmatch(token, ".") do
		local found = string.find(text, character, index, true)
		if not found then
			return false
		end
		index = found + 1
	end
	return true
end

local function rank(result, query)
	if query == "" then
		return result.Type == "Command" and 20 or 1
	end

	local title = lower(result.Title)
	local text = searchableText(result)
	local total = 0
	for token in string.gmatch(query, "%S+") do
		local found = string.find(text, token, 1, true)
		if found then
			total = total + 24
			if string.find(title, token, 1, true) == 1 then
				total = total + 20
			elseif string.find(title, token, 1, true) then
				total = total + 8
			end
		elseif fuzzyContains(text, token) then
			total = total + 4
		else
			return nil
		end
	end

	if result.Type == "Command" then
		total = total + 3
	end
	return total
end

function Commands:Init(library)
	library._commands = library._commands or {}
	library._searchItems = library._searchItems or {}
	library._recentCommands = library._recentCommands or {}
	library._commandSequence = library._commandSequence or 0
	library._searchSequence = library._searchSequence or 0
end

function Commands:RecordRecent(library, id)
	self:Init(library)
	for index = #library._recentCommands, 1, -1 do
		if library._recentCommands[index] == id then
			table.remove(library._recentCommands, index)
		end
	end
	table.insert(library._recentCommands, 1, id)
	while #library._recentCommands > 6 do
		table.remove(library._recentCommands)
	end
end

function Commands:RemoveRecent(library, id)
	for index = #(library._recentCommands or {}), 1, -1 do
		if library._recentCommands[index] == id then
			table.remove(library._recentCommands, index)
		end
	end
end

function Commands:Register(library, options)
	self:Init(library)
	if typeof(options) ~= "table" then
		library:_Warn("Command", "RegisterCommand expected an options table")
		return nil
	end

	local title = options.Title or options.Name
	local action = options.Callback or options.Action
	if typeof(title) ~= "string" or title == "" then
		library:_Warn("Command", "RegisterCommand ignored: Title or Name must be a non-empty string")
		return nil
	end
	if typeof(action) ~= "function" then
		library:_Warn("Command", "RegisterCommand ignored '" .. title .. "': callback/action must be a function")
		return nil
	end

	local id = options.Id
	if id ~= nil and (typeof(id) ~= "string" or id == "") then
		library:_Warn("Command", "RegisterCommand ignored '" .. title .. "': Id must be a non-empty string")
		return nil
	end
	if id == nil then
		library._commandSequence = library._commandSequence + 1
		id = "command_" .. library._commandSequence
	end
	local existing = library._commands[id]
	if existing and existing.Owner and (existing.Owner.Destroyed or existing.Owner.Closed) then
		library._commands[id] = nil
		existing = nil
	end
	if existing then
		library:_Warn("Command", "RegisterCommand ignored duplicate Id '" .. id .. "'")
		return nil
	end

	local keywords = options.Keywords
	if typeof(keywords) == "table" then
		local normalized = {}
		for _, keyword in ipairs(keywords) do
			table.insert(normalized, tostring(keyword))
		end
		keywords = normalized
	elseif keywords ~= nil and typeof(keywords) ~= "string" then
		library:_Warn("Command", "RegisterCommand ignored invalid Keywords on '" .. title .. "'")
		keywords = nil
	end

	local controller = { Id = id }
	local record = {
		Id = id,
		Type = "Command",
		Title = title,
		Description = tostring(options.Description or ""),
		Category = tostring(options.Category or "Actions"),
		Keywords = keywords,
		Action = action,
		CloseOnRun = options.CloseOnRun ~= false,
		Owner = options.Owner,
		Controller = controller,
	}

	function controller:Unregister()
		library:UnregisterCommand(self)
		return self
	end

	function controller:Run()
		library:RunCommand(self)
		return self
	end

	library._commands[id] = record
	return controller
end

function Commands:Unregister(library, idOrController)
	self:Init(library)
	local id = typeof(idOrController) == "table" and idOrController.Id or idOrController
	if typeof(id) ~= "string" or library._commands[id] == nil then
		return false
	end
	if typeof(idOrController) == "table" and library._commands[id].Controller ~= idOrController then
		return false
	end
	library._commands[id] = nil
	self:RemoveRecent(library, id)
	return true
end

function Commands:RemoveOwner(library, owner)
	self:Init(library)
	for id, command in pairs(library._commands) do
		if command.Owner == owner then
			library._commands[id] = nil
			self:RemoveRecent(library, id)
		end
	end
end

function Commands:Execute(library, idOrResult)
	self:Init(library)
	local result = idOrResult
	if typeof(idOrResult) == "string" then
		result = library._commands[idOrResult]
	elseif typeof(idOrResult) == "table" and idOrResult.Type == nil and idOrResult.Id ~= nil then
		result = library._commands[idOrResult.Id]
		if result and result.Controller ~= idOrResult then
			result = nil
		end
	end
	if not result then
		library:_Warn("Command", "Attempted to execute a missing command")
		return false, true
	end

	if result.Type == "Command" then
		if result.Owner and (result.Owner.Destroyed or result.Owner.Closed) then
			self:Unregister(library, result.Id)
			library:_Warn("Command", "Ignored command whose owner was destroyed: " .. result.Title)
			return false, true
		end
		self:RecordRecent(library, result.Id)
		library:_InvokeCallback("Command", result.Action, result.Controller)
		return true, result.CloseOnRun
	end

	return self:Navigate(library, result), true
end

function Commands:IndexObject(library, object, kind)
	self:Init(library)
	if not object or object._midasSearchId then
		return
	end

	library._searchSequence = library._searchSequence + 1
	local id = "item_" .. library._searchSequence
	object._midasSearchId = id
	library._searchItems[id] = {
		Id = id,
		Type = kind,
		Object = object,
	}

	if typeof(object.Destroy) == "function" and not object._midasSearchWrapped then
		object._midasSearchWrapped = true
		local originalDestroy = object.Destroy
		object.Destroy = function(target, ...)
			local result = originalDestroy(target, ...)
			Commands:RemoveObject(library, target)
			return result
		end
	end
end

function Commands:RemoveObject(library, object)
	self:Init(library)
	if object and object._midasSearchId then
		library._searchItems[object._midasSearchId] = nil
		object._midasSearchId = nil
	end
	self:RemoveOwner(library, object)
end

function Commands:Navigate(library, result)
	local object = result and result.Object
	local kind = result and result.Type
	if not isLiveObject(object, kind) then
		library:_Warn("Search", "Navigation target is no longer available")
		return false
	end

	local window
	local tab
	if kind == "Window" then
		window = object
	elseif kind == "Tab" then
		window = object.Window
		tab = object
	elseif kind == "Section" then
		tab = object.Tab
		window = tab and tab.Window
	else
		local section = object.Section
		tab = section and section.Tab
		window = tab and tab.Window
	end

	if window then
		window:Show()
		window:Restore()
	end
	if tab and window then
		window:SelectTab(tab)
	end

	if kind == "Dropdown" and object.Enabled ~= false and object.SetExpanded then
		object:SetExpanded(true)
	end

	if tab and object ~= tab then
		local guiObject = kind == "Section" and object.Frame or object.Instance
		if guiObject and tab.Page then
			task.defer(function()
				if guiObject.Parent and tab.Page.Parent then
					local targetY = tab.Page.CanvasPosition.Y + guiObject.AbsolutePosition.Y - tab.Page.AbsolutePosition.Y - 12
					local maximum = math.max(0, tab.Page.AbsoluteCanvasSize.Y - tab.Page.AbsoluteSize.Y)
					tab.Page.CanvasPosition = Vector2.new(0, math.clamp(targetY, 0, maximum))
				end
			end)
		end
	end

	return true
end

function Commands:Search(library, query, options)
	self:Init(library)
	options = typeof(options) == "table" and options or {}
	query = lower(query)
	local results = {}
	local recentIndex = {}
	for index, id in ipairs(library._recentCommands or {}) do
		recentIndex[id] = index
	end

	for id, command in pairs(library._commands) do
		if command.Owner and (command.Owner.Destroyed or command.Owner.Closed) then
			library._commands[id] = nil
			self:RemoveRecent(library, id)
		else
			local score = rank(command, query)
			if score then
				local recent = query == "" and recentIndex[command.Id] ~= nil
				if recent then
					score = score + 100 - recentIndex[command.Id]
				end
				table.insert(results, {
					Id = command.Id,
					Type = command.Type,
					Title = command.Title,
					Description = command.Description,
					Category = command.Category,
					Group = query == "" and (recent and "Recent" or "Commands") or command.Category,
					Recent = recent,
					Keywords = command.Keywords,
					Score = score,
					_Record = command,
				})
			end
		end
	end

	if not options.CommandsOnly and (query ~= "" or options.IncludeItems == true) then
		for id, item in pairs(library._searchItems) do
			if not objectExists(item.Object, item.Type) then
				library._searchItems[id] = nil
			elseif isLiveObject(item.Object, item.Type) then
				local result = {
					Id = item.Id,
					Type = item.Type,
					Title = tostring(getTitle(item.Object, item.Type)),
					Description = getDescription(item.Object, item.Type),
					Category = "Navigate",
					Keywords = item.Type,
					_Record = item,
				}
				local score = rank(result, query)
				if score then
					result.Score = score
					table.insert(results, result)
				end
			end
		end
	end

	table.sort(results, function(left, right)
		if left.Score == right.Score then
			return left.Title < right.Title
		end
		return left.Score > right.Score
	end)
	return results
end

return Commands
end
ModuleSources["Core/CommandPalette"] = function()
local UserInputService = game:GetService("UserInputService")

local CommandPalette = {}

local function applyRowState(palette, index)
	local theme = palette.Library.Theme
	for itemIndex, item in ipairs(palette.Rows or {}) do
		local active = itemIndex == index
		item.Button.BackgroundColor3 = active and theme.AccentSoft or theme.Background
		item.Button.BackgroundTransparency = active and 0.12 or 1
		item.Title.TextColor3 = theme.Text
		item.Title.TextTransparency = active and 0 or 0.08
		item.Description.TextColor3 = theme.MutedText
		item.Hint.TextColor3 = active and theme.Accent or theme.MutedText
	end
end

function CommandPalette:Init(context)
	local library = context.Library
	if library._paletteReady then
		return
	end

	library._paletteReady = true
end

function CommandPalette:CreateGui(context)
	local library = context.Library
	if library._paletteGui then
		return library._paletteGui
	end

	local gui = context.Utility:Create("ScreenGui", {
		Name = "MidasUI_CommandPalette",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 350,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = context.Utility:GetGuiParent(),
	})
	library._paletteGui = gui
	return gui
end

function CommandPalette:Close(context, instant)
	local library = context.Library
	local palette = library._activePalette
	if not palette then
		return false
	end

	if palette.SearchBox and palette.SearchBox:IsFocused() then
		palette.SearchBox:ReleaseFocus()
	end
	context.Utility:DisconnectAll(palette.RowConnections)
	context.Utility:DisconnectAll(palette.Connections)
	library._activePalette = nil
	local function destroyPalette()
		context.Utility:CancelTweens(palette.Tweens)
		if palette.Overlay and palette.Overlay.Parent then
			palette.Overlay:Destroy()
		end
		if library._closingPalette == palette then
			library._closingPalette = nil
		end
	end
	if instant or not palette.Overlay or not palette.Overlay.Parent then
		destroyPalette()
		return true
	end
	library._closingPalette = palette
	context.Utility:TweenTracked(palette.Tweens, "Overlay", palette.Overlay, context.Utility.Motion.Exit, {
		BackgroundTransparency = 1,
	}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	context.Utility:TweenTracked(palette.Tweens, "Scale", palette.Scale, context.Utility.Motion.Exit, {
		Scale = 0.98,
	}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local exit = context.Utility:TweenTracked(palette.Tweens, "Card", palette.Card, context.Utility.Motion.Exit, {
		Position = UDim2.new(0.5, 0, 0.145, 0),
	}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	exit.Completed:Connect(destroyPalette)
	return true
end

function CommandPalette:SetTheme(context)
	local palette = context.Library._activePalette
	if not palette then
		return
	end

	local theme = context.Library.Theme
	palette.Card.BackgroundColor3 = theme.Card
	palette.Gradient.Color = ColorSequence.new(theme.Card, theme.Background)
	palette.Header.TextColor3 = theme.Text
	context.Utility:SetIconColor(palette.Icon, theme.Accent)
	palette.SearchBox.BackgroundColor3 = theme.Background
	palette.SearchBox.TextColor3 = theme.Text
	palette.SearchBox.PlaceholderColor3 = theme.MutedText
	palette.ShortcutHint.TextColor3 = theme.Accent
	palette.Footer.TextColor3 = theme.MutedText
	palette.EmptyLabel.TextColor3 = theme.MutedText
	palette.List.ScrollBarImageColor3 = theme.Accent
	context.Utility:ApplyStrokeTheme(palette.Card, theme.Stroke)
	palette.SearchStroke.Color = palette.SearchBox:IsFocused() and theme.Accent or theme.Stroke
	for _, label in ipairs(palette.GroupLabels or {}) do
		label.TextColor3 = theme.Accent
	end
	for _, row in ipairs(palette.Rows or {}) do
		row.Button.BackgroundColor3 = theme.Background
		row.Description.TextColor3 = theme.MutedText
	end
	applyRowState(palette, palette.SelectedIndex)
end

function CommandPalette:Open(context, options)
	local library = context.Library
	options = typeof(options) == "table" and options or {}
	if library._activeDialog then
		library:_Warn("Palette", "Command palette cannot open while a dialog is active")
		return false
	end

	self:Init(context)
	self:Close(context, true)
	if library._closingPalette then
		context.Utility:CancelTweens(library._closingPalette.Tweens)
		if library._closingPalette.Overlay and library._closingPalette.Overlay.Parent then
			library._closingPalette.Overlay:Destroy()
		end
		library._closingPalette = nil
	end
	library:_CloseExpandedDropdown()
	context.Tooltip:Hide(context)

	local utility = context.Utility
	local theme = library.Theme
	local gui = self:CreateGui(context)
	local overlay = utility:Create("TextButton", {
		Name = "Overlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.52,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 100,
		Parent = gui,
	})
	local card = utility:Create("Frame", {
		Name = "CommandPalette",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.16, 0),
		Size = UDim2.fromOffset(540, 430),
		BackgroundColor3 = theme.Card,
		Active = true,
		ZIndex = 101,
		Parent = overlay,
	})
	utility:Corner(card, 14)
	utility:Stroke(card, theme.Stroke, 0.15)
	utility:Padding(card, { X = 14, Y = 14 })
	local gradient = utility:Create("UIGradient", {
		Color = ColorSequence.new(theme.Card, theme.Background),
		Rotation = 90,
		Parent = card,
	})
	local scale = utility:Create("UIScale", {
		Scale = 0.98,
		Parent = card,
	})

	local icon = utility:CreateIcon(card, "command", {
		Position = UDim2.fromOffset(0, 2),
		Size = UDim2.fromOffset(19, 19),
		Color = theme.Accent,
		TextSize = 13,
		ZIndex = 102,
	})
	local header = utility:Create("TextLabel", {
		Name = "Header",
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(1, 0, 0, 23),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = "Command Palette",
		TextColor3 = theme.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 102,
		Parent = card,
	})
	local shortcutHint = utility:Create("TextLabel", {
		Name = "Shortcut",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 2),
		Size = UDim2.fromOffset(124, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = library.CommandPaletteShortcut,
		TextColor3 = theme.Accent,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 102,
		Parent = card,
	})
	local searchBox = utility:Create("TextBox", {
		Name = "Search",
		Position = UDim2.fromOffset(0, 34),
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = theme.Background,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = "Search commands, tabs, sections, or controls...",
		PlaceholderColor3 = theme.MutedText,
		Text = tostring(options.Query or ""),
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 102,
		Parent = card,
	})
	utility:Corner(searchBox, 9)
	local searchStroke = utility:Stroke(searchBox, theme.Stroke, 0.35)
	utility:Padding(searchBox, { X = 12 })

	local list = utility:Create("ScrollingFrame", {
		Name = "Results",
		Position = UDim2.fromOffset(0, 84),
		Size = UDim2.new(1, 0, 1, -112),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = 0.3,
		ZIndex = 102,
		Parent = card,
	})
	utility:List(list, 4)
	local emptyLabel = utility:Create("TextLabel", {
		Name = "Empty",
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "No matching commands or controls",
		TextColor3 = theme.MutedText,
		TextSize = 12,
		Visible = false,
		ZIndex = 103,
		Parent = list,
	})
	local shortcutFooter = library.CommandPaletteShortcut == "Disabled"
		and "Shortcut disabled"
		or (library.CommandPaletteShortcut .. " toggle")
	local footer = utility:Create("TextLabel", {
		Name = "Footer",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "Up/Down navigate   Enter run   Esc close   " .. shortcutFooter,
		TextColor3 = theme.MutedText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 102,
		Parent = card,
	})

	local palette = {
		Library = library,
		Overlay = overlay,
		Card = card,
		Gradient = gradient,
		Scale = scale,
		Icon = icon,
		Header = header,
		ShortcutHint = shortcutHint,
		SearchBox = searchBox,
		SearchStroke = searchStroke,
		List = list,
		EmptyLabel = emptyLabel,
		Footer = footer,
		Connections = {},
		RowConnections = {},
		Rows = {},
		GroupLabels = {},
		Results = {},
		SelectedIndex = 1,
		Tweens = {},
	}
	library._activePalette = palette

	local refresh
	local function runSelected()
		local result = palette.Results[palette.SelectedIndex]
		if not result then
			return
		end
		local ok, closeOnRun = context.Commands:Execute(library, result._Record)
		if ok and closeOnRun then
			CommandPalette:Close(context)
		elseif ok and refresh then
			task.defer(function()
				if library._activePalette == palette then
					refresh()
				end
			end)
		end
	end

	refresh = function()
		utility:DisconnectAll(palette.RowConnections)
		for _, row in ipairs(palette.Rows) do
			row.Button:Destroy()
		end
		for _, label in ipairs(palette.GroupLabels) do
			label:Destroy()
		end
		table.clear(palette.Rows)
		table.clear(palette.GroupLabels)
		palette.Results = context.Commands:Search(library, searchBox.Text, { IncludeItems = false })
		while #palette.Results > 6 do
			table.remove(palette.Results)
		end
		emptyLabel.Visible = #palette.Results == 0
		emptyLabel.Text = searchBox.Text == "" and "No commands registered yet" or ("No results for '" .. searchBox.Text .. "'")
		palette.SelectedIndex = math.clamp(palette.SelectedIndex, 1, math.max(#palette.Results, 1))

		local previousGroup
		for index, result in ipairs(palette.Results) do
			local activeTheme = library.Theme
			local group = result.Group or result.Category
			if group ~= previousGroup then
				local groupLabel = utility:Create("TextLabel", {
					Name = "Group",
					Size = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Text = string.upper(group),
					TextColor3 = activeTheme.Accent,
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 103,
					Parent = list,
				})
				table.insert(palette.GroupLabels, groupLabel)
				previousGroup = group
			end
			local button = utility:Create("TextButton", {
				Name = result.Type .. "Result",
				Size = UDim2.new(1, 0, 0, 39),
				BackgroundColor3 = activeTheme.Background,
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 103,
				Parent = list,
			})
			utility:Corner(button, 8)
			local title = utility:Create("TextLabel", {
				Name = "Title",
				Position = UDim2.fromOffset(10, 4),
				Size = UDim2.new(1, -106, 0, 17),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamMedium,
				Text = result.Recent and ("Recently used  " .. result.Title) or result.Title,
				TextColor3 = activeTheme.MutedText,
				TextSize = 12,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 104,
				Parent = button,
			})
			local description = utility:Create("TextLabel", {
				Name = "Description",
				Position = UDim2.fromOffset(10, 21),
				Size = UDim2.new(1, -106, 0, 14),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = result.Description,
				TextColor3 = activeTheme.MutedText,
				TextSize = 10,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 104,
				Parent = button,
			})
			local hint = utility:Create("TextLabel", {
				Name = "Category",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(90, 18),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = result.Category,
				TextColor3 = activeTheme.MutedText,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 104,
				Parent = button,
			})
			utility:Connect(palette.RowConnections, button.MouseEnter, function()
				palette.SelectedIndex = index
				applyRowState(palette, palette.SelectedIndex)
			end)
			utility:Connect(palette.RowConnections, button.MouseButton1Click, function()
				palette.SelectedIndex = index
				runSelected()
			end)
			table.insert(palette.Rows, { Button = button, Title = title, Description = description, Hint = hint })
		end
		applyRowState(palette, palette.SelectedIndex)
	end

	utility:Connect(palette.Connections, overlay.MouseButton1Click, function()
		CommandPalette:Close(context)
	end)
	utility:Connect(palette.Connections, card.InputBegan, function() end)
	utility:Connect(palette.Connections, searchBox:GetPropertyChangedSignal("Text"), refresh)
	utility:Connect(palette.Connections, searchBox.Focused, function()
		searchStroke.Color = library.Theme.Accent
		searchStroke.Transparency = 0.08
	end)
	utility:Connect(palette.Connections, searchBox.FocusLost, function()
		searchStroke.Color = library.Theme.Stroke
		searchStroke.Transparency = 0.35
	end)
	utility:Connect(palette.Connections, UserInputService.InputBegan, function(input)
		if library._activePalette ~= palette or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if input.KeyCode == Enum.KeyCode.Escape then
			CommandPalette:Close(context)
		elseif input.KeyCode == Enum.KeyCode.Down then
			palette.SelectedIndex = math.min(palette.SelectedIndex + 1, math.max(#palette.Results, 1))
			applyRowState(palette, palette.SelectedIndex)
		elseif input.KeyCode == Enum.KeyCode.Up then
			palette.SelectedIndex = math.max(palette.SelectedIndex - 1, 1)
			applyRowState(palette, palette.SelectedIndex)
		elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
			runSelected()
		end
	end)

	refresh()
	overlay.BackgroundTransparency = 1
	card.Position = UDim2.new(0.5, 0, 0.145, 0)
	utility:TweenTracked(palette.Tweens, "Overlay", overlay, utility.Motion.Overlay, { BackgroundTransparency = 0.52 })
	utility:TweenTracked(palette.Tweens, "Card", card, utility.Motion.Reveal, {
		Position = UDim2.new(0.5, 0, 0.16, 0),
	}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	utility:TweenTracked(palette.Tweens, "Scale", scale, utility.Motion.Reveal, { Scale = 1 }, Enum.EasingStyle.Quart)
	searchBox:CaptureFocus()
	return true
end

function CommandPalette:Destroy(context)
	self:Close(context, true)
	local library = context.Library
	if library._closingPalette then
		context.Utility:CancelTweens(library._closingPalette.Tweens)
		if library._closingPalette.Overlay and library._closingPalette.Overlay.Parent then
			library._closingPalette.Overlay:Destroy()
		end
		library._closingPalette = nil
	end
	if library._paletteGui then
		library._paletteGui:Destroy()
		library._paletteGui = nil
	end
	library._paletteReady = false
end

return CommandPalette
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
end
ModuleSources["Core/Section"] = function()
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
		Tweens = {},
		Icon = options.Icon,
		Enabled = true,
	}, Button)

	local theme = self.Theme
	local utility = self.Utility
	local compact = section.Compact == true

	local button = utility:Create("TextButton", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 32 or 38),
		BackgroundColor3 = theme.Background,
		Font = Enum.Font.GothamMedium,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutoButtonColor = false,
		Parent = section.Frame,
	})
	utility:Corner(button, 8)
	local stroke = utility:Stroke(button, theme.Stroke, 0.55)
	local icon
	if self.Icon ~= nil then
		icon = utility:CreateIcon(button, self.Icon, {
			Position = UDim2.fromOffset(12, compact and 8 or 11),
			Size = UDim2.fromOffset(16, 16),
			Color = theme.Accent,
			TextSize = 12,
		})
		button.TextXAlignment = Enum.TextXAlignment.Left
		utility:Padding(button, { Left = 38, Right = 12 })
	end

	self.Instance = button
	self.Stroke = stroke
	self.IconLabel = icon
	self._themeObjects = {
		{ button, "BackgroundColor3", "Background" },
		{ button, "TextColor3", "Text" },
	}

	utility:Connect(self.Connections, button.MouseEnter, function()
		if self.Enabled == false then
			return
		end
		utility:TweenTracked(self.Tweens, "Surface", button, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Topbar })
	end)

	utility:Connect(self.Connections, button.MouseLeave, function()
		if self.Enabled == false then
			return
		end
		utility:TweenTracked(self.Tweens, "Surface", button, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Background })
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
		utility:TweenTracked(self.Tweens, "Press", button, utility.Motion.Press, { BackgroundTransparency = 0.18 })
	end)

	utility:Connect(self.Connections, button.MouseButton1Up, function()
		if self.Enabled == false then
			return
		end
		utility:TweenTracked(self.Tweens, "Press", button, utility.Motion.Press, { BackgroundTransparency = 0 })
	end)
	utility:Connect(self.Connections, button.SelectionGained, function()
		if self.Enabled ~= false then
			stroke.Color = self.Theme.Accent
			stroke.Transparency = 0.08
		end
	end)
	utility:Connect(self.Connections, button.SelectionLost, function()
		stroke.Color = self.Theme.Stroke
		stroke.Transparency = 0.55
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
	self.Utility:SetIconColor(self.IconLabel, theme.Accent)
	if game:GetService("GuiService").SelectedObject == self.Instance then
		self.Stroke.Color = theme.Accent
		self.Stroke.Transparency = 0.08
	end
	self:SetEnabled(self.Enabled)
	return self
end

function Button:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Utility:CancelTweens(self.Tweens)
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
		Tweens = {},
		Enabled = true,
	}, Toggle)

	local theme = self.Theme
	local utility = self.Utility
	local compact = section.Compact == true

	local row = utility:Create("TextButton", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 32 or 38),
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
		TextSize = compact and 12 or 13,
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

		utility:TweenTracked(self.Tweens, "Label", label, utility.Motion.Hover, { TextColor3 = self.Theme.Accent })
	end)

	utility:Connect(self.Connections, row.MouseLeave, function()
		if self.Enabled == false then
			return
		end

		utility:TweenTracked(self.Tweens, "Label", label, utility.Motion.Hover, { TextColor3 = self.Theme.Text })
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
	self.Utility:TweenTracked(self.Tweens, "Track", self.Track, self.Utility.Motion.Toggle, {
		BackgroundColor3 = self.Value and theme.Accent or theme.Background,
	})
	self.Utility:TweenTracked(self.Tweens, "Knob", self.Knob, self.Utility.Motion.Toggle, {
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
	self.Utility:CancelTweens(self.Tweens)
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

local function decimalPlaces(value)
	local text = string.format("%.6f", math.abs(value))
	text = string.gsub(text, "0+$", "")
	local decimal = string.match(text, "%.(%d+)$")
	return decimal and #decimal or 0
end

local function round(value, precision)
	local factor = 10 ^ precision
	local scaled = value * factor
	local rounded = scaled >= 0 and math.floor(scaled + 0.5) or math.ceil(scaled - 0.5)
	return rounded / factor
end

local function snap(value, min, max, increment, precision)
	increment = increment or 1
	local clamped = math.clamp(value, min, max)
	if max == min or clamped <= min then
		return round(min, precision)
	end
	if clamped >= max then
		return round(max, precision)
	end

	local steps = math.floor(((clamped - min) / increment) + 0.5)
	return math.clamp(round(min + (steps * increment), precision), min, max)
end

local function formatValue(value, precision)
	if precision <= 0 then
		return string.format("%.0f", value)
	end
	return string.format("%." .. tostring(precision) .. "f", value)
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

	local increment = math.max(math.abs(tonumber(options.Increment) or 1), 0.000001)

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
		Precision = math.max(decimalPlaces(min), decimalPlaces(max), decimalPlaces(increment)),
		Value = tonumber(options.Default) or min,
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
		Connections = {},
		Tweens = {},
		Dragging = false,
		DragInput = nil,
		Enabled = true,
	}, Slider)

	local theme = self.Theme
	local utility = self.Utility
	local compact = section.Compact == true

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 48 or 58),
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
		TextSize = compact and 12 or 13,
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
		TextSize = compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = frame,
	})

	local bar = utility:Create("TextButton", {
		Name = "Bar",
		Position = UDim2.fromOffset(0, compact and 29 or 34),
		Size = UDim2.new(1, 0, 0, compact and 8 or 10),
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
		local value = snap(self.Min + ((self.Max - self.Min) * ratio), self.Min, self.Max, self.Increment, self.Precision)
		if self.Flag then
			self.Library:SetFlag(self.Flag, value, true, true)
		else
			self:SetValue(value, true, true)
		end
	end

	utility:Connect(self.Connections, bar.InputBegan, function(input)
		if self.Enabled == false then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.Dragging = true
			self.DragInput = input
			updateFromPosition(input.Position.X)
		end
	end)

	utility:Connect(self.Connections, bar.MouseEnter, function()
		if self.Enabled == false then
			return
		end

		utility:TweenTracked(self.Tweens, "KnobSize", knob, utility.Motion.Hover, { Size = UDim2.fromOffset(18, 18) })
	end)

	utility:Connect(self.Connections, bar.MouseLeave, function()
		if self.Enabled == false or self.Dragging then
			return
		end

		utility:TweenTracked(self.Tweens, "KnobSize", knob, utility.Motion.Hover, { Size = UDim2.fromOffset(16, 16) })
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
		local isMouseRelease = self.DragInput
			and self.DragInput.UserInputType == Enum.UserInputType.MouseButton1
			and input.UserInputType == Enum.UserInputType.MouseButton1
		if self.Dragging and (isMouseRelease or input == self.DragInput) then
			self.Dragging = false
			self.DragInput = nil
			utility:TweenTracked(self.Tweens, "KnobSize", knob, utility.Motion.Hover, { Size = UDim2.fromOffset(16, 16) })
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

function Slider:SetValue(value, fireCallback, instant)
	if self.Destroyed then
		return self
	end

	if tonumber(value) == nil then
		self.Library:_Warn("Slider", "'" .. self.Name .. "' ignored a non-numeric value")
		return self
	end

	local nextValue = snap(tonumber(value), self.Min, self.Max, self.Increment, self.Precision)
	local changed = self.Value ~= nextValue
	self.Value = nextValue

	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	local range = self.Max - self.Min
	local ratio = range > 0 and (self.Value - self.Min) / range or 0
	self.ValueLabel.Text = formatValue(self.Value, self.Precision)
	if instant then
		for _, key in ipairs({ "Fill", "Knob" }) do
			local tween = self.Tweens[key]
			if tween then
				tween:Cancel()
				self.Tweens[key] = nil
			end
		end
		self.Fill.Size = UDim2.fromScale(ratio, 1)
		self.Knob.Position = UDim2.fromScale(ratio, 0.5)
	else
		self.Utility:TweenTracked(self.Tweens, "Fill", self.Fill, self.Utility.Motion.Fast, { Size = UDim2.fromScale(ratio, 1) })
		self.Utility:TweenTracked(self.Tweens, "Knob", self.Knob, self.Utility.Motion.Fast, { Position = UDim2.fromScale(ratio, 0.5) })
	end

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
		self.DragInput = nil
		self.Utility:TweenTracked(self.Tweens, "KnobSize", self.Knob, self.Utility.Motion.Hover, { Size = UDim2.fromOffset(16, 16) })
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
	self.Increment = math.max(math.abs(tonumber(increment) or self.Increment), 0.000001)
	self.Precision = math.max(decimalPlaces(self.Min), decimalPlaces(self.Max), decimalPlaces(self.Increment))
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
	self.Utility:CancelTweens(self.Tweens)
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

	local searchSetting = options.Searchable
	if searchSetting == nil then
		searchSetting = options.Search
	end
	local searchThreshold = math.max(tonumber(options.SearchThreshold) or 8, 1)
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
		OptionConnections = {},
		InteractionConnections = {},
		Tweens = {},
		Icon = options.Icon,
		Expanded = false,
		Enabled = true,
		MaxVisibleOptions = math.clamp(tonumber(options.MaxVisibleOptions) or 5, 1, 20),
		SearchAutomatic = searchSetting == nil,
		SearchEnabled = searchSetting == true or (searchSetting == nil and #dropdownOptions >= searchThreshold),
		SearchThreshold = searchThreshold,
		FilteredOptions = {},
		SelectedIndex = 1,
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
	local compact = section.Compact == true
	self.BaseHeight = compact and 50 or 58
	self.ListTop = compact and 56 or 64
	self.OptionHeight = compact and 24 or 28
	self.OptionStep = compact and 28 or 32
	self.SearchHeight = compact and 28 or 32

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, self.BaseHeight),
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
		TextSize = compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	local button = utility:Create("TextButton", {
		Name = "Button",
		Position = UDim2.fromOffset(0, compact and 21 or 24),
		Size = UDim2.new(1, 0, 0, compact and 29 or 34),
		BackgroundColor3 = theme.Background,
		Font = Enum.Font.Gotham,
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	})
	utility:Corner(button, 8)
	local buttonStroke = utility:Stroke(button, theme.Stroke, 0.5)
	local buttonIcon
	local valueLeft = 10
	if self.Icon ~= nil then
		buttonIcon = utility:CreateIcon(button, self.Icon, {
			Position = UDim2.fromOffset(10, compact and 7 or 9),
			Size = UDim2.fromOffset(16, 16),
			Color = theme.Accent,
			TextSize = 12,
		})
		valueLeft = 34
	end

	local valueLabel = utility:Create("TextLabel", {
		Name = "Value",
		Position = UDim2.fromOffset(valueLeft, 0),
		Size = UDim2.new(1, -(valueLeft + 32), 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextColor3 = theme.MutedText,
		TextSize = compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = button,
	})

	local arrow = utility:Create("TextLabel", {
		Name = "Arrow",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 0),
		Size = UDim2.fromOffset(20, compact and 29 or 34),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "v",
		TextColor3 = theme.Accent,
		TextSize = 12,
		Parent = button,
	})

	local list = utility:Create("Frame", {
		Name = "List",
		Position = UDim2.fromOffset(0, self.ListTop),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = theme.Background,
		ClipsDescendants = true,
		Active = true,
		Visible = false,
		ZIndex = 21,
		Parent = frame,
	})
	utility:Corner(list, 8)
	utility:Stroke(list, theme.Stroke, 0.5)
	utility:Padding(list, { All = 4 })

	local searchBox = utility:Create("TextBox", {
		Name = "Search",
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, -8, 0, self.SearchHeight),
		BackgroundColor3 = theme.Card,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = "Filter options...",
		PlaceholderColor3 = theme.MutedText,
		Text = "",
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = self.SearchEnabled,
		ZIndex = 22,
		Parent = list,
	})
	utility:Corner(searchBox, 6)
	local searchStroke = utility:Stroke(searchBox, theme.Stroke, 0.5)
	utility:Padding(searchBox, { X = 9 })

	local scroll = utility:Create("ScrollingFrame", {
		Name = "Options",
		Size = UDim2.new(1, -8, 1, self.SearchEnabled and -(self.SearchHeight + 12) or -8),
		Position = UDim2.fromOffset(4, self.SearchEnabled and (self.SearchHeight + 8) or 4),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = 0.3,
		ZIndex = 22,
		Parent = list,
	})
	local optionLayout = utility:List(scroll, 4)
	local emptyLabel = utility:Create("TextLabel", {
		Name = "Empty",
		Size = UDim2.new(1, 0, 0, self.OptionHeight),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "No options found",
		TextColor3 = theme.MutedText,
		TextSize = compact and 12 or 13,
		Visible = false,
		ZIndex = 23,
		Parent = scroll,
	})

	self.Instance = frame
	self.Label = label
	self.Button = button
	self.ButtonStroke = buttonStroke
	self.IconLabel = buttonIcon
	self.ValueLabel = valueLabel
	self.Arrow = arrow
	self.List = list
	self.SearchBox = searchBox
	self.SearchStroke = searchStroke
	self.Scroll = scroll
	self.OptionLayout = optionLayout
	self.EmptyLabel = emptyLabel
	self.CanvasConnection = utility:BindCanvas(scroll, optionLayout, 4)
	self.OptionButtons = {}

	for _, option in ipairs(self.Options) do
		self:_addOption(option)
	end

	utility:Connect(self.Connections, searchBox:GetPropertyChangedSignal("Text"), function()
		self:_FilterOptions(searchBox.Text)
	end)
	utility:Connect(self.Connections, searchBox.Focused, function()
		searchStroke.Color = self.Theme.Accent
		searchStroke.Transparency = 0.1
	end)
	utility:Connect(self.Connections, searchBox.FocusLost, function()
		searchStroke.Color = self.Theme.Stroke
		searchStroke.Transparency = 0.5
	end)

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		if self.Enabled == false then
			return
		end

		self:SetExpanded(not self.Expanded)
	end)
	utility:Connect(self.Connections, button.MouseEnter, function()
		if self.Enabled then
			utility:TweenTracked(self.Tweens, "Button", button, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Card })
			buttonStroke.Color = self.Theme.Accent
		end
	end)
	utility:Connect(self.Connections, button.MouseLeave, function()
		if self.Enabled and not self.Expanded then
			utility:TweenTracked(self.Tweens, "Button", button, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Background })
			buttonStroke.Color = self.Theme.Stroke
		end
	end)

	utility:Connect(self.Connections, button:GetPropertyChangedSignal("AbsolutePosition"), function()
		if self.Expanded then
			self:_PositionOverlay()
		end
	end)

	utility:Connect(self.Connections, button:GetPropertyChangedSignal("AbsoluteSize"), function()
		if self.Expanded then
			self:_ResizeExpanded(true)
		end
	end)

	local camera = workspace.CurrentCamera
	if camera then
		utility:Connect(self.Connections, camera:GetPropertyChangedSignal("ViewportSize"), function()
			if self.Expanded then
				self:_PositionOverlay()
			end
		end)
	end

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)
	self:SetExpanded(false, true)
	self.Library:_BindElement(self, options)

	return self
end

function Dropdown:_GetOverlayGui()
	local gui = self.Library._dropdownGui
	if gui and gui.Parent then
		return gui
	end

	gui = self.Utility:Create("ScreenGui", {
		Name = "MidasUI_Dropdowns",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 250,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = self.Utility:GetGuiParent(),
	})
	self.Library._dropdownGui = gui
	return gui
end

function Dropdown:_PositionOverlay(heightOverride)
	if not self.Expanded or not self.List or not self.List.Parent then
		return
	end

	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local width = math.max(self.Button.AbsoluteSize.X, 1)
	local height = heightOverride or self.List.Size.Y.Offset
	local margin = 8
	local x = math.clamp(self.Button.AbsolutePosition.X, margin, math.max(margin, viewport.X - width - margin))
	local below = self.Button.AbsolutePosition.Y + self.Button.AbsoluteSize.Y + 6
	local above = self.Button.AbsolutePosition.Y - height - 6
	local maximumY = math.max(margin, viewport.Y - height - margin)
	local y = below

	if below + height > viewport.Y - margin and above >= margin then
		y = above
	else
		y = math.clamp(below, margin, maximumY)
	end

	self.List.Position = UDim2.fromOffset(x, y)
end

function Dropdown:_ResizeExpanded(instant)
	local maxVisible = math.max(self.MaxVisibleOptions, 1)
	local displayedOptions = math.max(#self.FilteredOptions, 1)
	local optionHeight = math.min(displayedOptions, maxVisible) * self.OptionStep
	local searchHeight = self.SearchEnabled and (self.SearchHeight + 8) or 0
	local height = self.Expanded and optionHeight + searchHeight + 8 or 0
	local width = math.max(self.Button.AbsoluteSize.X, self.Instance.AbsoluteSize.X, 1)
	local targetSize = UDim2.fromOffset(width, height)

	self.Instance.Size = UDim2.new(1, 0, 0, self.BaseHeight)

	local tween
	if instant then
		local current = self.Tweens.Expand
		if current then
			current:Cancel()
			self.Tweens.Expand = nil
		end
		self.List.Size = targetSize
	else
		self.List.Size = UDim2.fromOffset(width, self.List.Size.Y.Offset)
		tween = self.Utility:TweenTracked(
			self.Tweens,
			"Expand",
			self.List,
			self.Utility.Motion.Overlay,
			{ Size = targetSize },
			self.Expanded and Enum.EasingStyle.Quart or Enum.EasingStyle.Quad,
			self.Expanded and Enum.EasingDirection.Out or Enum.EasingDirection.In
		)
	end

	if self.Expanded then
		self:_PositionOverlay(height)
	end
	return tween
end

function Dropdown:_SetKeyboardSelection(index)
	if #self.FilteredOptions == 0 then
		self.SelectedIndex = 0
	else
		self.SelectedIndex = math.clamp(index or 1, 1, #self.FilteredOptions)
	end

	for _, item in ipairs(self.OptionButtons) do
		local active = item.Value == self.Value
		local highlighted = self.FilteredOptions[self.SelectedIndex] == item
		item.Button.BackgroundTransparency = active and 0 or (highlighted and 0.25 or 1)
		item.Button.TextColor3 = (active or highlighted) and self.Theme.Text or self.Theme.MutedText
	end
end

function Dropdown:_FilterOptions(query)
	if self.Destroyed then
		return
	end

	query = string.lower(tostring(query or ""))
	table.clear(self.FilteredOptions)
	for _, item in ipairs(self.OptionButtons) do
		local visible = query == "" or string.find(string.lower(tostring(item.Value)), query, 1, true) ~= nil
		item.Button.Visible = visible
		if visible then
			table.insert(self.FilteredOptions, item)
		end
	end
	self.EmptyLabel.Visible = #self.FilteredOptions == 0
	local selectedIndex = 1
	for index, item in ipairs(self.FilteredOptions) do
		if item.Value == self.Value then
			selectedIndex = index
			break
		end
	end
	self:_SetKeyboardSelection(selectedIndex)
	if self.Expanded then
		self:_ResizeExpanded(true)
	end
end

function Dropdown:_EndInteraction()
	self.Utility:DisconnectAll(self.InteractionConnections)
	if self.DismissOverlay then
		self.DismissOverlay:Destroy()
		self.DismissOverlay = nil
	end
end

function Dropdown:_BeginInteraction()
	self:_EndInteraction()
	self.DismissOverlay = self.Utility:Create("TextButton", {
		Name = "Dismiss",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 20,
		Parent = self:_GetOverlayGui(),
	})
	self.Utility:Connect(self.InteractionConnections, self.DismissOverlay.MouseButton1Click, function()
		self:SetExpanded(false)
	end)

	self.Utility:Connect(self.InteractionConnections, game:GetService("UserInputService").InputBegan, function(input)
		if not self.Expanded or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if input.KeyCode == Enum.KeyCode.Escape then
			self:SetExpanded(false)
		elseif input.KeyCode == Enum.KeyCode.Down then
			self:_SetKeyboardSelection(math.min(self.SelectedIndex + 1, #self.FilteredOptions))
		elseif input.KeyCode == Enum.KeyCode.Up then
			self:_SetKeyboardSelection(math.max(self.SelectedIndex - 1, 1))
		elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
			local item = self.FilteredOptions[self.SelectedIndex]
			if item then
				if self.Flag then
					self.Library:SetFlag(self.Flag, item.Value, true)
				else
					self:SetValue(item.Value, true)
				end
				self:SetExpanded(false)
			end
		end
	end)
end

function Dropdown:_addOption(option)
	local text = tostring(option)
	local utility = self.Utility
	local theme = self.Theme

	local button = utility:Create("TextButton", {
		Name = text,
		Size = UDim2.new(1, 0, 0, self.OptionHeight),
		BackgroundColor3 = theme.Card,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = text,
		TextColor3 = theme.MutedText,
		TextSize = self.Section.Compact and 12 or 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutoButtonColor = false,
		ZIndex = 23,
		Parent = self.Scroll,
	})
	utility:Corner(button, 6)

	local item = { Button = button, Value = option }
	table.insert(self.OptionButtons, item)

	self.Utility:Connect(self.OptionConnections, button.MouseEnter, function()
		if self.Enabled == false then
			return
		end

		local index = table.find(self.FilteredOptions, item)
		if index then
			self:_SetKeyboardSelection(index)
		end
	end)

	self.Utility:Connect(self.OptionConnections, button.MouseLeave, function()
		if self.Enabled == false then
			return
		end

		self:_SetKeyboardSelection(self.SelectedIndex)
	end)

	utility:Connect(self.OptionConnections, button.MouseButton1Click, function()
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
end

function Dropdown:GetValue()
	return self.Value
end

function Dropdown:SetExpanded(value, instant)
	if self.Destroyed then
		return self
	end

	local expanded = value == true and self.Enabled ~= false
	if expanded and self.Library._expandedDropdown and self.Library._expandedDropdown ~= self then
		self.Library._expandedDropdown:SetExpanded(false, true)
	end
	self._expansionToken = (self._expansionToken or 0) + 1
	local token = self._expansionToken
	self.Expanded = expanded
	if self.Expanded then
		self.Library._expandedDropdown = self
		self.Context.Tooltip:Hide(self.Context)
		self.List.Parent = self:_GetOverlayGui()
		self.List.Visible = true
		self.SearchBox.Text = ""
		self:_FilterOptions("")
		self:_BeginInteraction()
		if self.SearchEnabled then
			task.defer(function()
				if self.Expanded and self.SearchBox and self.SearchBox.Parent then
					self.SearchBox:CaptureFocus()
				end
			end)
		end
	else
		if self.Library._expandedDropdown == self then
			self.Library._expandedDropdown = nil
		end
		self:_EndInteraction()
		if self.SearchBox:IsFocused() then
			self.SearchBox:ReleaseFocus()
		end
		self.SearchBox.Text = ""
		self:_FilterOptions("")
	end

	self.Arrow.Text = "v"
	if instant then
		self.Arrow.Rotation = self.Expanded and 180 or 0
	else
		self.Utility:TweenTracked(self.Tweens, "Arrow", self.Arrow, self.Utility.Motion.Standard, {
			Rotation = self.Expanded and 180 or 0,
		})
	end
	self.ButtonStroke.Color = self.Expanded and self.Theme.Accent or self.Theme.Stroke
	if not self.Expanded then
		self.Utility:TweenTracked(self.Tweens, "Button", self.Button, self.Utility.Motion.Hover, {
			BackgroundColor3 = self.Theme.Background,
		})
	end
	self.Scroll.CanvasPosition = Vector2.new(0, 0)
	if self.Expanded and not instant then
		self.List.Size = UDim2.fromOffset(math.max(self.Button.AbsoluteSize.X, self.Instance.AbsoluteSize.X, 1), 0)
	end
	self:_ResizeExpanded(instant)
	if not self.Expanded then
		local function finalizeClose()
			if self._expansionToken ~= token or self.Expanded or not self.List then
				return
			end
			self.List.Visible = false
			self.List.Parent = self.Instance
			self.List.Position = UDim2.fromOffset(0, self.ListTop)
		end
		if instant then
			finalizeClose()
		else
			task.delay(self.Utility.Motion.Overlay, finalizeClose)
		end
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
	self:_SetKeyboardSelection(self.SelectedIndex)

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

	self.Utility:DisconnectAll(self.OptionConnections)
	table.clear(self.OptionButtons)
	self.Options = options
	if self.SearchAutomatic then
		self.SearchEnabled = #options >= self.SearchThreshold
	end
	self.SearchBox.Visible = self.SearchEnabled
	self.Scroll.Position = UDim2.fromOffset(4, self.SearchEnabled and (self.SearchHeight + 8) or 4)
	self.Scroll.Size = UDim2.new(1, -8, 1, self.SearchEnabled and -(self.SearchHeight + 12) or -8)

	for _, option in ipairs(self.Options) do
		self:_addOption(option)
	end
	self:_FilterOptions("")

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
	self.Utility:SetIconColor(self.IconLabel, theme.Accent)
	self.List.BackgroundColor3 = theme.Background
	self.SearchBox.BackgroundColor3 = theme.Card
	self.SearchBox.TextColor3 = theme.Text
	self.SearchBox.PlaceholderColor3 = theme.MutedText
	self.Scroll.ScrollBarImageColor3 = theme.Accent
	self.EmptyLabel.TextColor3 = theme.MutedText

	for _, item in ipairs(self.OptionButtons) do
		item.Button.BackgroundColor3 = theme.Card
	end

	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	self.Utility:ApplyStrokeTheme(self.List, theme.Stroke)
	self.ButtonStroke.Color = self.Expanded and theme.Accent or theme.Stroke
	if self.SearchBox:IsFocused() then
		self.SearchStroke.Color = theme.Accent
	end
	self:SetValue(self.Value, false)
	self:SetEnabled(self.Enabled)
	return self
end

function Dropdown:Destroy()
	if self.Destroyed then
		return self
	end

	self:SetExpanded(false, true)
	self.Destroyed = true
	self.Utility:CancelTweens(self.Tweens)
	self.Library:_UnregisterDependencies(self)
	self.Context.Flags:Unregister(self.Library, self.Flag, self)
	self:_EndInteraction()

	if self.CanvasConnection then
		self.CanvasConnection:Disconnect()
		self.CanvasConnection = nil
	end

	self.Utility:DisconnectAll(self.OptionConnections)
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
		Tweens = {},
		Enabled = true,
	}, Input)

	local theme = self.Theme
	local utility = self.Utility
	local compact = section.Compact == true

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 52 or 62),
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
		TextSize = compact and 12 or 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	local box = utility:Create("TextBox", {
		Name = "Box",
		Position = UDim2.fromOffset(0, compact and 21 or 26),
		Size = UDim2.new(1, 0, 0, compact and 30 or 34),
		BackgroundColor3 = theme.Background,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = self.Placeholder,
		PlaceholderColor3 = theme.MutedText,
		Text = tostring(self.Value),
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	utility:Corner(box, 8)
	local boxStroke = utility:Stroke(box, theme.Stroke, 0.5)
	utility:Padding(box, { X = 10 })

	self.Instance = frame
	self.Label = label
	self.Box = box
	self.BoxStroke = boxStroke

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

		utility:TweenTracked(self.Tweens, "Focus", box, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Topbar })
		boxStroke.Color = self.Theme.Accent
		boxStroke.Transparency = 0.1
	end)

	utility:Connect(self.Connections, box.FocusLost, function()
		utility:TweenTracked(self.Tweens, "Focus", box, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Background })
		boxStroke.Color = self.Theme.Stroke
		boxStroke.Transparency = 0.5
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
	if self.Box:IsFocused() then
		self.BoxStroke.Color = theme.Accent
	end
	self:SetEnabled(self.Enabled)
	return self
end

function Input:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Utility:CancelTweens(self.Tweens)
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
	local compact = section.Compact == true

	local row = utility:Create("TextButton", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 34 or 42),
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
		TextSize = compact and 12 or 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local button = utility:Create("TextButton", {
		Name = "Bind",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(compact and 108 or 118, compact and 28 or 32),
		BackgroundColor3 = theme.Background,
		Font = Enum.Font.GothamMedium,
		Text = keyName(self.Value),
		TextColor3 = theme.MutedText,
		TextSize = 12,
		AutoButtonColor = false,
		Parent = row,
	})
	utility:Corner(button, 8)
	local buttonStroke = utility:Stroke(button, theme.Stroke, 0.45)

	self.Instance = row
	self.Label = label
	self.Button = button
	self.ButtonStroke = buttonStroke

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
	self.ButtonStroke.Color = self.Theme.Accent
	self.ButtonStroke.Transparency = 0.08
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
	self.ButtonStroke.Color = self.Theme.Stroke
	self.ButtonStroke.Transparency = 0.45
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
	if self.Listening then
		self.ButtonStroke.Color = theme.Accent
	end
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
		Size = UDim2.new(1, 0, 0, options.Height or (section.Compact and 24 or 28)),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = text,
		TextColor3 = self.Theme.MutedText,
		TextSize = options.TextSize or (section.Compact and 12 or 13),
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
		Size = UDim2.new(1, 0, 0, section.Compact and 7 or 9),
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
ModuleSources["Elements/ProgressBar"] = function()
local ProgressBar = {}
ProgressBar.__index = ProgressBar

local function clampValue(value, min, max)
	return math.clamp(tonumber(value) or min, min, max)
end

local function formatPercent(value)
	local rounded = math.floor(value + 0.5)
	return tostring(rounded) .. "%"
end

function ProgressBar.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "ProgressBar ignored an invalid Flag value")
		flag = nil
	end

	local min = tonumber(options.Min) or 0
	local max = tonumber(options.Max) or 100
	if max < min then
		min, max = max, min
	end

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or options.Title or "Progress"),
		Status = tostring(options.Status or ""),
		Flag = flag,
		Min = min,
		Max = max,
		Value = clampValue(options.Default or options.Value, min, max),
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
		Connections = {},
		Tweens = {},
		Enabled = true,
	}, ProgressBar)

	local compact = section.Compact == true
	local theme = self.Theme
	local utility = self.Utility
	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 45 or 50),
		BackgroundTransparency = 1,
		Parent = section.Frame,
	})
	local label = utility:Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(0.55, 0, 0, 19),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local status = utility:Create("TextLabel", {
		Name = "Status",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0.45, 0, 0, 19),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextColor3 = theme.MutedText,
		TextSize = compact and 11 or 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = frame,
	})
	local track = utility:Create("Frame", {
		Name = "Track",
		Position = UDim2.fromOffset(0, compact and 27 or 30),
		Size = UDim2.new(1, 0, 0, compact and 8 or 10),
		BackgroundColor3 = theme.Background,
		Parent = frame,
	})
	utility:Corner(track, 6)
	utility:Stroke(track, theme.Stroke, 0.55)
	local fill = utility:Create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = theme.Accent,
		Parent = track,
	})
	utility:Corner(fill, 6)

	self.Instance = frame
	self.Label = label
	self.StatusLabel = status
	self.Track = track
	self.Fill = fill

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false, true)
	self.Library:_BindElement(self, options)
	return self
end

function ProgressBar:GetValue()
	return self.Value
end

function ProgressBar:SetValue(value, fireCallback, instant)
	if self.Destroyed then
		return self
	end
	if tonumber(value) == nil then
		self.Library:_Warn("ProgressBar", "'" .. self.Name .. "' ignored a non-numeric value")
		return self
	end

	local nextValue = clampValue(value, self.Min, self.Max)
	local changed = self.Value ~= nextValue
	self.Value = nextValue
	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	local range = self.Max - self.Min
	local ratio = range > 0 and (self.Value - self.Min) / range or 0
	local percent = formatPercent(ratio * 100)
	self.StatusLabel.Text = self.Status ~= "" and (self.Status .. "  " .. percent) or percent
	if instant then
		self.Utility:CancelTweens(self.Tweens)
		self.Fill.Size = UDim2.fromScale(ratio, 1)
	else
		self.Utility:TweenTracked(self.Tweens, "Fill", self.Fill, self.Utility.Motion.Standard, { Size = UDim2.fromScale(ratio, 1) })
	end

	if changed and fireCallback ~= false then
		self.Library:_InvokeCallback("ProgressBar", self.Callback, self.Value)
	end
	return self
end

function ProgressBar:Set(value, fireCallback)
	return self:SetValue(value, fireCallback)
end

function ProgressBar:SetStatus(text)
	if self.Destroyed then
		return self
	end
	self.Status = tostring(text or "")
	return self:SetValue(self.Value, false, true)
end

function ProgressBar:SetText(text)
	if self.Destroyed then
		return self
	end
	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function ProgressBar:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end
	self.Enabled = enabled == true
	local transparency = self.Enabled and 0 or 0.45
	self.Label.TextTransparency = transparency
	self.StatusLabel.TextTransparency = transparency
	self.Track.BackgroundTransparency = self.Enabled and 0 or 0.35
	self.Fill.BackgroundTransparency = self.Enabled and 0 or 0.35
	return self
end

function ProgressBar:Enable()
	return self:SetEnabled(true)
end

function ProgressBar:Disable()
	return self:SetEnabled(false)
end

function ProgressBar:SetVisible(visible)
	if not self.Destroyed then
		self.Library:_SetElementVisible(self, visible == true)
	end
	return self
end

function ProgressBar:Show()
	return self:SetVisible(true)
end

function ProgressBar:Hide()
	return self:SetVisible(false)
end

function ProgressBar:Refresh()
	if not self.Destroyed then
		self:SetValue(self.Value, false, true)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function ProgressBar:SetTheme(theme)
	if self.Destroyed then
		return self
	end
	self.Theme = theme
	self.Label.TextColor3 = theme.Text
	self.StatusLabel.TextColor3 = theme.MutedText
	self.Track.BackgroundColor3 = theme.Background
	self.Fill.BackgroundColor3 = theme.Accent
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	return self:SetEnabled(self.Enabled)
end

function ProgressBar:Destroy()
	if self.Destroyed then
		return self
	end
	self.Destroyed = true
	self.Utility:CancelTweens(self.Tweens)
	self.Library:_UnregisterDependencies(self)
	self.Context.Flags:Unregister(self.Library, self.Flag, self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return ProgressBar
end
ModuleSources["Elements/StatCard"] = function()
local StatCard = {}
StatCard.__index = StatCard

function StatCard.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "StatCard ignored an invalid Flag value")
		flag = nil
	end

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or options.Title or "Status"),
		Value = tostring(options.Default ~= nil and options.Default or (options.Value ~= nil and options.Value or "Idle")),
		Icon = options.Icon,
		Flag = flag,
		Connections = {},
		Enabled = true,
	}, StatCard)

	local compact = section.Compact == true
	local dashboard = section.Template and section.Template.Dashboard
	local height = compact and 42 or (dashboard and 54 or 48)
	local theme = self.Theme
	local utility = self.Utility
	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = theme.Background,
		Parent = section.Frame,
	})
	utility:Corner(frame, 9)
	utility:Stroke(frame, theme.Stroke, 0.55)
	local icon = utility:CreateIcon(frame, options.Icon, {
		Name = "Icon",
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.fromOffset(options.Icon and 24 or 0, height),
		Color = theme.Accent,
		TextSize = 14,
	})
	local left = options.Icon and 43 or 12
	local label = utility:Create("TextLabel", {
		Name = "Label",
		Position = UDim2.fromOffset(left, compact and 4 or 6),
		Size = UDim2.new(0.52, -left, 0, 17),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Name,
		TextColor3 = theme.MutedText,
		TextSize = compact and 11 or 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local value = utility:Create("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0.48, -12, 0, 24),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = self.Value,
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = frame,
	})

	self.Instance = frame
	self.IconLabel = icon
	self.Label = label
	self.ValueLabel = value

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value)
	self.Library:_BindElement(self, options)
	return self
end

function StatCard:GetValue()
	return self.Value
end

function StatCard:SetValue(value)
	if self.Destroyed then
		return self
	end
	self.Value = tostring(value or "")
	self.ValueLabel.Text = self.Value
	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end
	return self
end

function StatCard:Set(value)
	return self:SetValue(value)
end

function StatCard:SetText(text)
	if self.Destroyed then
		return self
	end
	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function StatCard:SetIcon(icon)
	if self.Destroyed then
		return self
	end
	self.Icon = icon
	self.Utility:SetIcon(self.IconLabel, icon, self.Theme.Accent)
	return self
end

function StatCard:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end
	self.Enabled = enabled == true
	local transparency = self.Enabled and 0 or 0.45
	self.Label.TextTransparency = transparency
	self.ValueLabel.TextTransparency = transparency
	self.Utility:SetIconTransparency(self.IconLabel, transparency)
	self.Instance.BackgroundTransparency = self.Enabled and 0 or 0.32
	return self
end

function StatCard:Enable()
	return self:SetEnabled(true)
end

function StatCard:Disable()
	return self:SetEnabled(false)
end

function StatCard:SetVisible(visible)
	if not self.Destroyed then
		self.Library:_SetElementVisible(self, visible == true)
	end
	return self
end

function StatCard:Show()
	return self:SetVisible(true)
end

function StatCard:Hide()
	return self:SetVisible(false)
end

function StatCard:Refresh()
	if not self.Destroyed then
		self:SetValue(self.Value)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function StatCard:SetTheme(theme)
	if self.Destroyed then
		return self
	end
	self.Theme = theme
	self.Instance.BackgroundColor3 = theme.Background
	self.Utility:SetIconColor(self.IconLabel, theme.Accent)
	self.Label.TextColor3 = theme.MutedText
	self.ValueLabel.TextColor3 = theme.Text
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	return self:SetEnabled(self.Enabled)
end

function StatCard:Destroy()
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

return StatCard
end
ModuleSources["Elements/LogPanel"] = function()
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
end
ModuleSources["Elements/Callout"] = function()
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
	local icon
	local left = self.Icon and 39 or 13
	if self.Icon then
		icon = utility:CreateIcon(frame, self.Icon, {
			Position = UDim2.fromOffset(13, compact and 10 or 13),
			Size = UDim2.fromOffset(18, 18),
			Color = theme.Accent,
			TextSize = 13,
		})
	end
	local title = utility:Create("TextLabel", {
		Name = "Title",
		Position = UDim2.fromOffset(left, compact and 7 or 9),
		Size = UDim2.new(1, -(left + 11), 0, 18),
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
		Position = UDim2.fromOffset(left, compact and 29 or 33),
		Size = UDim2.new(1, -(left + 11), 1, compact and -32 or -38),
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
	self.IconLabel = icon
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
	self.Utility:SetIconColor(self.IconLabel, self:_color())
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
	self.Utility:SetIconTransparency(self.IconLabel, transparency)
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
	self.Utility:SetIconColor(self.IconLabel, self:_color())
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
end
ModuleSources["Elements/ActionRow"] = function()
local ActionRow = {}
ActionRow.__index = ActionRow

local function styleColor(theme, style)
	style = string.lower(tostring(style or "Default"))
	if style == "primary" then
		return theme.Accent, theme.Background
	elseif style == "danger" then
		return theme.Danger, theme.Text
	elseif style == "success" then
		return theme.Success, theme.Background
	end
	return theme.Background, theme.Text
end

function ActionRow.new(context, section, options)
	options = options or {}
	local actions = typeof(options.Actions) == "table" and options.Actions or {}
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Actions = {},
		Connections = {},
		Enabled = true,
	}, ActionRow)

	local compact = section.Compact == true
	local frame = self.Utility:Create("Frame", {
		Name = "ActionRow",
		Size = UDim2.new(1, 0, 0, compact and 30 or 36),
		BackgroundTransparency = 1,
		Parent = section.Frame,
	})
	self.Utility:List(frame, compact and 6 or 8, true)
	self.Instance = frame

	for index, action in ipairs(actions) do
		if typeof(action) ~= "table" then
			action = { Name = tostring(action) }
		end
		local name = tostring(action.Name or action.Text or ("Action " .. index))
		local background, textColor = styleColor(self.Theme, action.Style)
		local button = self.Utility:Create("TextButton", {
			Name = name,
			Size = UDim2.new(0, tonumber(action.Width) or (compact and 90 or 104), 1, 0),
			BackgroundColor3 = background,
			Font = Enum.Font.GothamMedium,
			Text = name,
			TextColor3 = textColor,
			TextSize = compact and 12 or 13,
			AutoButtonColor = false,
			Parent = frame,
		})
		self.Utility:Corner(button, 8)
		self.Utility:Stroke(button, self.Theme.Stroke, 0.45)
		local item = {
			Name = name,
			Style = action.Style,
			Callback = typeof(action.Callback) == "function" and action.Callback or function() end,
			Enabled = action.Enabled ~= false,
			Button = button,
		}
		table.insert(self.Actions, item)
		self.Utility:Connect(self.Connections, button.MouseButton1Click, function()
			if self.Enabled and item.Enabled then
				self.Library:_InvokeCallback("ActionRow", item.Callback)
			end
		end)
	end

	self:SetEnabled(true)
	self.Library:_BindElement(self, options)
	return self
end

function ActionRow:_find(name)
	for _, action in ipairs(self.Actions) do
		if action.Name == name or action.Button == name then
			return action
		end
	end
end

function ActionRow:SetActionEnabled(name, enabled)
	if self.Destroyed then
		return self
	end
	local action = self:_find(name)
	if action then
		action.Enabled = enabled == true
		action.Button.TextTransparency = self.Enabled and action.Enabled and 0 or 0.45
		action.Button.BackgroundTransparency = self.Enabled and action.Enabled and 0 or 0.35
	end
	return self
end

function ActionRow:SetActionText(name, text)
	if self.Destroyed then
		return self
	end
	local action = self:_find(name)
	if action then
		action.Name = tostring(text or "")
		action.Button.Text = action.Name
	end
	return self
end

function ActionRow:GetValue()
	return nil
end

function ActionRow:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end
	self.Enabled = enabled == true
	for _, action in ipairs(self.Actions) do
		local active = self.Enabled and action.Enabled
		action.Button.TextTransparency = active and 0 or 0.45
		action.Button.BackgroundTransparency = active and 0 or 0.35
	end
	return self
end

function ActionRow:Enable()
	return self:SetEnabled(true)
end

function ActionRow:Disable()
	return self:SetEnabled(false)
end

function ActionRow:SetVisible(visible)
	if not self.Destroyed then
		self.Library:_SetElementVisible(self, visible == true)
	end
	return self
end

function ActionRow:Show()
	return self:SetVisible(true)
end

function ActionRow:Hide()
	return self:SetVisible(false)
end

function ActionRow:Refresh()
	if not self.Destroyed then
		self:SetTheme(self.Theme)
	end
	return self
end

function ActionRow:SetTheme(theme)
	if self.Destroyed then
		return self
	end
	self.Theme = theme
	for _, action in ipairs(self.Actions) do
		local background, textColor = styleColor(theme, action.Style)
		action.Button.BackgroundColor3 = background
		action.Button.TextColor3 = textColor
	end
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	return self:SetEnabled(self.Enabled)
end

function ActionRow:Destroy()
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

return ActionRow
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
local Shortcuts = requireModule("Core/Shortcuts")
local Dialog = requireModule("Core/Dialog")
local Templates = requireModule("Core/Templates")
local Commands = requireModule("Core/Commands")
local CommandPalette = requireModule("Core/CommandPalette")
local Icons = requireModule("Assets/Icons")

if Icons and Icons.Map then
	Utility.IconGlyphs = Icons.Map
end

local MidasUI = {
	Version = "1.9.0",
	Flags = {},
	Keybinds = {},
	Themes = Theme.Registry,
	Templates = Templates.Registry,
	ThemeName = "DarkGold",
	Theme = Theme:Normalize(Theme.Registry.DarkGold),
	_windows = {},
	_flagObjects = {},
	_dependencies = {},
	_themeCallbacks = {},
	_themeCallbackSequence = 0,
	_shortcuts = {},
	_shortcutSequence = 0,
	_recentCommands = {},
	_debug = false,
	_warnings = {},
	_warningCategories = {},
	_configFolder = "Midas",
	_configFile = "config.json",
	_windowSettings = {},
	_destroyed = false,
	_paletteShortcutValue = "Ctrl+K",
	_paletteShortcutDisabled = false,
	_menuToggleValue = nil,
	CommandPaletteShortcut = "Ctrl+K",
	MenuToggleShortcut = "Disabled",
	CommandPaletteKeyCode = Enum.KeyCode.K,
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
	Shortcuts = Shortcuts,
	Dialog = Dialog,
	Templates = Templates,
	Commands = Commands,
	CommandPalette = CommandPalette,
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
Context.Elements.ProgressBar = requireModule("Elements/ProgressBar")
Context.Elements.StatCard = requireModule("Elements/StatCard")
Context.Elements.LogPanel = requireModule("Elements/LogPanel")
Context.Elements.Callout = requireModule("Elements/Callout")
Context.Elements.ActionRow = requireModule("Elements/ActionRow")

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

function MidasUI:GetRuntimeReport()
	local flagCount = 0
	for _ in pairs(self.Flags) do
		flagCount = flagCount + 1
	end

	local keybindCount = 0
	for _ in pairs(self.Keybinds) do
		keybindCount = keybindCount + 1
	end

	local commandCount = 0
	for _, command in pairs(self._commands or {}) do
		if not command.Owner or (not command.Owner.Destroyed and not command.Owner.Closed) then
			commandCount = commandCount + 1
		end
	end

	local searchItemCount = 0
	for _ in pairs(self._searchItems or {}) do
		searchItemCount = searchItemCount + 1
	end

	local expandedDropdown = self._expandedDropdown
	local hasExpandedDropdown = expandedDropdown ~= nil
		and not expandedDropdown.Destroyed
		and expandedDropdown.Expanded == true
	local publicAPIs = {}
	for _, method in ipairs({
		"RegisterCommand",
		"UnregisterCommand",
		"RunCommand",
		"Search",
		"SearchCommands",
		"NavigateTo",
		"OpenCommandPalette",
		"CloseCommandPalette",
		"ToggleCommandPalette",
		"SetCommandPaletteShortcut",
		"ClearCommandPaletteShortcut",
		"SetMenuToggleKey",
		"ClearMenuToggleKey",
		"RegisterIcon",
		"RegisterIcons",
		"GetRuntimeReport",
		"RunSelfTest",
		"PrintRuntimeReport",
		"DestroyAllWindows",
		"IsLoaded",
		"Unload",
		"OnThemeChanged",
	}) do
		publicAPIs[method] = typeof(self[method]) == "function"
	end
	local shortcuts = Shortcuts:GetState(self)

	return {
		Version = self.Version,
		Theme = self.ThemeName,
		WindowCount = #self._windows,
		FlagCount = flagCount,
		KeybindCount = keybindCount,
		CommandCount = commandCount,
		SearchItemCount = searchItemCount,
		ShortcutCount = #shortcuts,
		Shortcuts = shortcuts,
		ShortcutListenerReady = self._shortcutsReady == true,
		RecentCommandCount = #(self._recentCommands or {}),
		CommandPaletteShortcut = self.CommandPaletteShortcut,
		MenuToggleShortcut = self.MenuToggleShortcut,
		DependencyCount = #self._dependencies,
		NotificationCount = self._notifications and #self._notifications or 0,
		HasActiveDialog = self._activeDialog ~= nil,
		HasOpenCommandPalette = self._activePalette ~= nil,
		HasExpandedDropdown = hasExpandedDropdown,
		ActiveOverlay = self._activeDialog and "Dialog"
			or (self._activePalette and "CommandPalette")
			or (hasExpandedDropdown and "Dropdown")
			or nil,
		PublicAPIs = publicAPIs,
		Destroyed = self._destroyed == true,
		Warnings = table.clone(self._warnings),
		WarningCategories = table.clone(self._warningCategories),
	}
end

function MidasUI:GetDebugState()
	if not self._debug then
		return nil
	end
	return self:GetRuntimeReport()
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

function MidasUI:RegisterIcon(name, definition)
	local ok, result = Utility:RegisterIcon(name, definition)
	if not ok then
		self:_Warn("Icon", result)
	end
	return ok, result
end

function MidasUI:RegisterIcons(definitions)
	if typeof(definitions) ~= "table" then
		self:_Warn("Icon", "RegisterIcons expected a table")
		return false, "Icon definitions must be a table"
	end
	for name, definition in pairs(definitions) do
		local ok, err = self:RegisterIcon(name, definition)
		if not ok then
			return false, err
		end
	end
	return true
end

function MidasUI:GetTemplate(nameOrTemplate)
	return Templates:Get(nameOrTemplate)
end

function MidasUI:OnThemeChanged(callback)
	if typeof(callback) ~= "function" then
		self:_Warn("Theme", "OnThemeChanged expected a callback function")
		return nil
	end

	self._themeCallbackSequence = self._themeCallbackSequence + 1
	local id = self._themeCallbackSequence
	self._themeCallbacks[id] = callback

	local controller = {}
	function controller:Disconnect()
		if MidasUI._themeCallbacks[id] == callback then
			MidasUI._themeCallbacks[id] = nil
		end
		return self
	end
	return controller
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
	CommandPalette:SetTheme(Context)
	for _, callback in pairs(self._themeCallbacks) do
		self:_InvokeCallback("Theme", callback, themeName, theme, valid)
	end
	return valid, themeName
end

function MidasUI:_EnsureShortcuts()
	Shortcuts:Init(Context)
	if not self._paletteShortcutDisabled and not self._shortcuts.command_palette then
		Shortcuts:Set(self, "command_palette", self._paletteShortcutValue, function()
			self:ToggleCommandPalette()
		end, { Priority = 100 })
	end
	if self._menuToggleValue and not self._shortcuts.menu_toggle then
		Shortcuts:Set(self, "menu_toggle", self._menuToggleValue, function()
			local window = self._menuToggleOwner or self._activeWindow
			if window and not window.Closed then
				window:ToggleVisibility()
			end
		end, { Priority = 80, Owner = self._menuToggleOwner })
	end
end

function MidasUI:_RefreshPaletteShortcutHint()
	local palette = self._activePalette
	if not palette then
		return
	end
	if palette.ShortcutHint then
		palette.ShortcutHint.Text = self.CommandPaletteShortcut
	end
	if palette.Footer then
		local hint = self.CommandPaletteShortcut == "Disabled"
			and "Shortcut disabled"
			or (self.CommandPaletteShortcut .. " toggle")
		palette.Footer.Text = "Up/Down navigate   Enter run   Esc close   " .. hint
	end
end

function MidasUI:SetCommandPaletteShortcut(value)
	if value == nil or value == false then
		self._paletteShortcutDisabled = true
		self._paletteShortcutValue = nil
		self.CommandPaletteShortcut = "Disabled"
		Shortcuts:Set(self, "command_palette", false)
		self:_RefreshPaletteShortcutHint()
		return true, self.CommandPaletteShortcut
	end

	local descriptor, err = Shortcuts:Normalize(value)
	if not descriptor then
		self:_Warn("Shortcut", "Command palette shortcut was not changed: " .. tostring(err))
		return false, err
	end
	if self.MenuToggleShortcut ~= "Disabled"
		and self.MenuToggleShortcut == Shortcuts:Format(descriptor) then
		local message = "Command palette shortcut conflicts with the menu toggle shortcut"
		self:_Warn("Shortcut", message)
		return false, message
	end
	self._paletteShortcutDisabled = false
	self._paletteShortcutValue = descriptor
	local ok, display = Shortcuts:Set(self, "command_palette", descriptor, function()
		self:ToggleCommandPalette()
	end, { Priority = 100 })
	if ok then
		self.CommandPaletteShortcut = display
		self.CommandPaletteKeyCode = descriptor.KeyCode
		self:_RefreshPaletteShortcutHint()
	end
	return ok, display
end

function MidasUI:ClearCommandPaletteShortcut()
	return self:SetCommandPaletteShortcut(false)
end

function MidasUI:_SetMenuToggleKey(value, owner)
	if value == nil or value == false then
		self._menuToggleValue = nil
		self._menuToggleOwner = nil
		self.MenuToggleShortcut = "Disabled"
		Shortcuts:Set(self, "menu_toggle", false)
		return true, self.MenuToggleShortcut
	end

	local descriptor, err = Shortcuts:Normalize(value)
	if not descriptor then
		self:_Warn("Shortcut", "Menu toggle shortcut was not changed: " .. tostring(err))
		return false, err
	end
	if not self._paletteShortcutDisabled
		and self.CommandPaletteShortcut == Shortcuts:Format(descriptor) then
		local message = "Menu toggle shortcut conflicts with the command palette shortcut"
		self:_Warn("Shortcut", message)
		return false, message
	end
	self._menuToggleValue = descriptor
	self._menuToggleOwner = owner
	local ok, display = Shortcuts:Set(self, "menu_toggle", descriptor, function()
		local window = owner or self._activeWindow
		if window and not window.Closed then
			window:ToggleVisibility()
		end
	end, { Priority = 80, Owner = owner })
	if ok then
		self.MenuToggleShortcut = display
	end
	return ok, display
end

function MidasUI:SetMenuToggleKey(value)
	return self:_SetMenuToggleKey(value, nil)
end

function MidasUI:ClearMenuToggleKey()
	return self:_SetMenuToggleKey(false)
end

function MidasUI:CreateWindow(options)
	if options ~= nil and typeof(options) ~= "table" then
		self:_Warn("API", "CreateWindow expected an options table")
		options = {}
	end

	options = options or {}
	self._destroyed = false
	self:_EnsureShortcuts()
	self:SetTheme(options.Theme or self.ThemeName)
	CommandPalette:Init(Context)
	local window = Context.Window.new(Context, options)
	Commands:IndexObject(self, window, "Window")
	return window
end

function MidasUI:_IsCommandPaletteHotkey(input)
	local shortcut = self._shortcuts and self._shortcuts.command_palette
	return shortcut ~= nil and Shortcuts:Matches(shortcut.Shortcut, input)
end

function MidasUI:RegisterCommand(options)
	return Commands:Register(self, options)
end

function MidasUI:UnregisterCommand(idOrController)
	return Commands:Unregister(self, idOrController)
end

function MidasUI:RunCommand(idOrController)
	local ok = Commands:Execute(self, idOrController)
	return ok
end

function MidasUI:Search(query, options)
	local results = Commands:Search(self, query, options)
	local publicResults = {}
	for _, result in ipairs(results) do
		local record = result._Record
		local entry = {
			Id = result.Id,
			Type = result.Type,
			Title = result.Title,
			Description = result.Description,
			Category = result.Category,
		}
		function entry:Run()
			Commands:Execute(MidasUI, record)
			return self
		end
		table.insert(publicResults, entry)
	end
	return publicResults
end

function MidasUI:SearchCommands(query)
	return self:Search(query, { CommandsOnly = true })
end

function MidasUI:NavigateTo(object)
	if typeof(object) ~= "table" or not object._midasSearchId then
		self:_Warn("Search", "NavigateTo expected a live indexed UI controller")
		return false
	end
	local record = self._searchItems and self._searchItems[object._midasSearchId]
	return Commands:Navigate(self, record)
end

function MidasUI:OpenCommandPalette(options)
	if self._destroyed then
		self:_Warn("Lifecycle", "OpenCommandPalette ignored: library was destroyed")
		return false
	end
	return CommandPalette:Open(Context, options)
end

function MidasUI:CloseCommandPalette()
	return CommandPalette:Close(Context)
end

function MidasUI:_CloseExpandedDropdown()
	if self._expandedDropdown and self._expandedDropdown.SetExpanded then
		self._expandedDropdown:SetExpanded(false, true)
	end
end

function MidasUI:ToggleCommandPalette(options)
	if self._activePalette then
		return CommandPalette:Close(Context)
	end
	return CommandPalette:Open(Context, options)
end

function MidasUI:GetFlag(flag)
	return Flags:Get(self, flag)
end

function MidasUI:SetFlag(flag, value, fireCallback, instant)
	if typeof(flag) ~= "string" or flag == "" then
		self:_Warn("Flag", "SetFlag ignored: flag must be a non-empty string")
		return false
	end

	Flags:Set(self, flag, value, fireCallback, instant)
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
	if self._destroyed then
		self:_Warn("Lifecycle", "Notify ignored: library was destroyed")
		return nil
	end
	if options ~= nil and typeof(options) ~= "table" then
		self:_Warn("Notification", "Notify expected an options table")
		options = {}
	end
	return Notify:Show(Context, options or {})
end

function MidasUI:Dialog(options)
	if self._destroyed then
		self:_Warn("Lifecycle", "Dialog ignored: library was destroyed")
		return nil
	end
	if options ~= nil and typeof(options) ~= "table" then
		self:_Warn("Dialog", "Dialog expected an options table")
		options = {}
	end
	self:CloseCommandPalette()
	self:_CloseExpandedDropdown()
	Tooltip:Hide(Context)
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

function MidasUI:RunSelfTest()
	local report = self:GetRuntimeReport()
	local checks = {}
	local function check(name, passed)
		checks[name] = passed == true
	end

	for name, available in pairs(report.PublicAPIs) do
		check("API." .. name, available)
	end
	for _, name in ipairs({ "CreateProgressBar", "CreateStatCard", "CreateStatusCard", "CreateLogPanel", "CreateCallout" }) do
		check("Section." .. name, typeof(Context.Section[name]) == "function")
	end
	check("Commands.Module", typeof(Context.Commands.Search) == "function" and typeof(Context.Commands.Execute) == "function")
	check("Shortcuts.Module", typeof(Context.Shortcuts.Set) == "function" and typeof(Context.Shortcuts.Normalize) == "function")
	check("Icons.Custom", typeof(self.RegisterIcon) == "function" and typeof(self.RegisterIcons) == "function")
	check("Version.1.9", self.Version == "1.9.0")

	local passed = true
	for _, value in pairs(checks) do
		if not value then
			passed = false
			break
		end
	end
	report.Checks = checks
	report.Passed = passed
	return report
end

function MidasUI:PrintRuntimeReport()
	local report = self:RunSelfTest()
	if self._debug then
		print("[MidasUI] Version", report.Version, "Passed", report.Passed)
		print("[MidasUI] Counts", report.WindowCount, report.CommandCount, report.SearchItemCount, report.KeybindCount, report.ShortcutCount)
		print("[MidasUI] Shortcuts", report.CommandPaletteShortcut, report.MenuToggleShortcut, report.ActiveOverlay)
	end
	return report
end

function MidasUI:_CleanupOverlays()
	self:_CloseExpandedDropdown()
	if self._dropdownGui then
		self._dropdownGui:Destroy()
		self._dropdownGui = nil
	end
	Notify:Destroy(Context)

	if self._tooltipGui then
		Tooltip:Hide(Context)
		self._tooltipGui:Destroy()
		self._tooltipGui = nil
		self._tooltipFrame = nil
		self._tooltipLabel = nil
		self._tooltipTweens = nil
	end

	if self._tooltipConnections then
		Utility:DisconnectAll(self._tooltipConnections)
	end

	CommandPalette:Destroy(Context)
	Dialog:Destroy(Context)
end

function MidasUI:_CleanupWindowRuntime()
	self:_CleanupOverlays()

	if self._listeningKeybind then
		self._listeningKeybind = nil
	end

	table.clear(self.Keybinds)

	Shortcuts:Destroy(Context)
	self._keybindsReady = false
end

function MidasUI:DestroyAllWindows()
	for _, window in ipairs(table.clone(self._windows)) do
		window:Destroy()
	end
	return self
end

function MidasUI:IsLoaded()
	return self._destroyed ~= true and #self._windows > 0
end

function MidasUI:Destroy()
	self._destroyed = true
	self:DestroyAllWindows()

	table.clear(self._windows)
	table.clear(self._flagObjects)
	table.clear(self._dependencies)
	table.clear(self.Keybinds)
	table.clear(self._commands or {})
	table.clear(self._searchItems or {})
	table.clear(self._themeCallbacks)
	table.clear(self._recentCommands)

	if self._listeningKeybind then
		self._listeningKeybind = nil
	end

	self:_CleanupWindowRuntime()

	self._keybindsReady = false
	return self
end

function MidasUI:Unload()
	return self:Destroy()
end

return MidasUI
