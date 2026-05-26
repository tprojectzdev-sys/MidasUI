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
