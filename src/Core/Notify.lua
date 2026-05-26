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
