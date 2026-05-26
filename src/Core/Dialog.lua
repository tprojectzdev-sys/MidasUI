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
