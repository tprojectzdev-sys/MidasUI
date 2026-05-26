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
