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
