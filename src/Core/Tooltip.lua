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
