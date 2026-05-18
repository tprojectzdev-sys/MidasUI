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
