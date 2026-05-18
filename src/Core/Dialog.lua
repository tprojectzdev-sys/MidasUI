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

function Dialog:Close(context)
	local library = context.Library
	if library._activeDialog and library._activeDialog.Gui then
		library._activeDialog.Gui:Destroy()
	end
	library._activeDialog = nil
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
		Dialog:Close(context)
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
			if callback then
				if dialogType == "Input" and name == "Confirm" then
					task.spawn(callback, inputBox and inputBox.Text or "")
				else
					task.spawn(callback)
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
