local UserInputService = game:GetService("UserInputService")

local CommandPalette = {}

local function applyRowState(palette, index)
	for itemIndex, item in ipairs(palette.Rows or {}) do
		local active = itemIndex == index
		item.Button.BackgroundTransparency = active and 0.15 or 1
		item.Title.TextColor3 = active and palette.Library.Theme.Text or palette.Library.Theme.MutedText
		item.Hint.TextColor3 = active and palette.Library.Theme.Accent or palette.Library.Theme.MutedText
	end
end

function CommandPalette:Init(context)
	local library = context.Library
	if library._paletteReady then
		return
	end

	library._paletteReady = true
	library._paletteGlobalConnections = library._paletteGlobalConnections or {}
	context.Utility:Connect(library._paletteGlobalConnections, UserInputService.InputBegan, function(input, processed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if library:_IsCommandPaletteHotkey(input) then
			if processed and not library._activePalette then
				return
			end
			local focused = UserInputService:GetFocusedTextBox()
			if focused and (not library._activePalette or focused ~= library._activePalette.SearchBox) then
				return
			end
			library:ToggleCommandPalette()
		end
	end)
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

function CommandPalette:Close(context)
	local library = context.Library
	local palette = library._activePalette
	if not palette then
		return false
	end

	if palette.SearchBox and palette.SearchBox:IsFocused() then
		palette.SearchBox:ReleaseFocus()
	end
	context.Utility:DisconnectAll(palette.Connections)
	if palette.Overlay then
		palette.Overlay:Destroy()
	end
	library._activePalette = nil
	return true
end

function CommandPalette:SetTheme(context)
	local palette = context.Library._activePalette
	if not palette then
		return
	end

	local theme = context.Library.Theme
	palette.Card.BackgroundColor3 = theme.Card
	palette.Header.TextColor3 = theme.Text
	palette.SearchBox.BackgroundColor3 = theme.Background
	palette.SearchBox.TextColor3 = theme.Text
	palette.SearchBox.PlaceholderColor3 = theme.MutedText
	palette.Footer.TextColor3 = theme.MutedText
	context.Utility:ApplyStrokeTheme(palette.Card, theme.Stroke)
	context.Utility:ApplyStrokeTheme(palette.SearchBox, theme.Stroke)
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
	self:Close(context)
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
		Size = UDim2.fromOffset(520, 410),
		BackgroundColor3 = theme.Card,
		ZIndex = 101,
		Parent = overlay,
	})
	utility:Corner(card, 14)
	utility:Stroke(card, theme.Stroke, 0.15)
	utility:Padding(card, { X = 14, Y = 14 })

	local header = utility:Create("TextLabel", {
		Name = "Header",
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
	utility:Stroke(searchBox, theme.Stroke, 0.35)
	utility:Padding(searchBox, { X = 12 })

	local list = utility:Create("Frame", {
		Name = "Results",
		Position = UDim2.fromOffset(0, 82),
		Size = UDim2.new(1, 0, 1, -112),
		BackgroundTransparency = 1,
		ZIndex = 102,
		Parent = card,
	})
	utility:List(list, 4)
	local footer = utility:Create("TextLabel", {
		Name = "Footer",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "Up/Down navigate   Enter run   Esc close   Ctrl+K toggle",
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
		Header = header,
		SearchBox = searchBox,
		List = list,
		Footer = footer,
		Connections = {},
		Rows = {},
		Results = {},
		SelectedIndex = 1,
	}
	library._activePalette = palette

	local function runSelected()
		local result = palette.Results[palette.SelectedIndex]
		if not result then
			return
		end
		local ok, closeOnRun = context.Commands:Execute(library, result._Record)
		if ok and closeOnRun then
			CommandPalette:Close(context)
		end
	end

	local function refresh()
		for _, row in ipairs(palette.Rows) do
			row.Button:Destroy()
		end
		table.clear(palette.Rows)
		palette.Results = context.Commands:Search(library, searchBox.Text, { IncludeItems = false })
		while #palette.Results > 7 do
			table.remove(palette.Results)
		end
		palette.SelectedIndex = math.clamp(palette.SelectedIndex, 1, math.max(#palette.Results, 1))

		for index, result in ipairs(palette.Results) do
			local activeTheme = library.Theme
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
				Text = result.Title,
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
			utility:Connect(palette.Connections, button.MouseButton1Click, function()
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
	searchBox:CaptureFocus()
	return true
end

function CommandPalette:Destroy(context)
	self:Close(context)
	local library = context.Library
	if library._paletteGui then
		library._paletteGui:Destroy()
		library._paletteGui = nil
	end
	context.Utility:DisconnectAll(library._paletteGlobalConnections)
	library._paletteReady = false
end

return CommandPalette
