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

	local tweens = {}
	local closing = false
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
	utility:TweenTracked(tweens, "Frame", frame, utility.Motion.Reveal, {
		Position = UDim2.fromOffset(-8, 0),
		BackgroundTransparency = 0.04,
	}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	utility:Tween(title, utility.Motion.Standard, { TextTransparency = 0 })
	utility:Tween(content, utility.Motion.Standard, { TextTransparency = 0 })
	task.delay(utility.Motion.Standard, function()
		if frame.Parent and not closing then
			utility:TweenTracked(tweens, "Frame", frame, utility.Motion.Fast, {
				Position = UDim2.fromOffset(0, 0),
			}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	end)

	table.insert(library._notifications, frame)

	local function animateOut()
		if closing or not frame or not frame.Parent then
			return
		end

		closing = true
		local tween = utility:TweenTracked(tweens, "Frame", frame, utility.Motion.Exit, {
			Position = UDim2.fromOffset(330, 0),
			BackgroundTransparency = 1,
		}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		utility:Tween(title, utility.Motion.Fast, { TextTransparency = 1 })
		utility:Tween(content, utility.Motion.Fast, { TextTransparency = 1 })
		tween.Completed:Connect(function()
			removeFrame(frame)
			utility:CancelTweens(tweens)
			if frame.Parent then
				frame:Destroy()
			end
		end)
	end

	local controller = {}
	function controller:Close()
		animateOut()
		return self
	end

	task.delay(duration, function()
		if not frame.Parent or closing then
			return
		end
		animateOut()
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
