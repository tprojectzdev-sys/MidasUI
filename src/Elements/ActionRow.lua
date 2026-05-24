local ActionRow = {}
ActionRow.__index = ActionRow

local function styleColor(theme, style)
	style = string.lower(tostring(style or "Default"))
	if style == "primary" then
		return theme.Accent, theme.Background
	elseif style == "danger" then
		return theme.Danger, theme.Text
	elseif style == "success" then
		return theme.Success, theme.Background
	end
	return theme.Background, theme.Text
end

function ActionRow.new(context, section, options)
	options = options or {}
	local actions = typeof(options.Actions) == "table" and options.Actions or {}
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Actions = {},
		Connections = {},
		Enabled = true,
	}, ActionRow)

	local compact = section.Compact == true
	local frame = self.Utility:Create("Frame", {
		Name = "ActionRow",
		Size = UDim2.new(1, 0, 0, compact and 30 or 36),
		BackgroundTransparency = 1,
		Parent = section.Frame,
	})
	self.Utility:List(frame, compact and 6 or 8, true)
	self.Instance = frame

	for index, action in ipairs(actions) do
		if typeof(action) ~= "table" then
			action = { Name = tostring(action) }
		end
		local name = tostring(action.Name or action.Text or ("Action " .. index))
		local background, textColor = styleColor(self.Theme, action.Style)
		local button = self.Utility:Create("TextButton", {
			Name = name,
			Size = UDim2.new(0, tonumber(action.Width) or (compact and 90 or 104), 1, 0),
			BackgroundColor3 = background,
			Font = Enum.Font.GothamMedium,
			Text = name,
			TextColor3 = textColor,
			TextSize = compact and 12 or 13,
			AutoButtonColor = false,
			Parent = frame,
		})
		self.Utility:Corner(button, 8)
		self.Utility:Stroke(button, self.Theme.Stroke, 0.45)
		local item = {
			Name = name,
			Style = action.Style,
			Callback = typeof(action.Callback) == "function" and action.Callback or function() end,
			Enabled = action.Enabled ~= false,
			Button = button,
		}
		table.insert(self.Actions, item)
		self.Utility:Connect(self.Connections, button.MouseButton1Click, function()
			if self.Enabled and item.Enabled then
				self.Library:_InvokeCallback("ActionRow", item.Callback)
			end
		end)
	end

	self:SetEnabled(true)
	self.Library:_BindElement(self, options)
	return self
end

function ActionRow:_find(name)
	for _, action in ipairs(self.Actions) do
		if action.Name == name or action.Button == name then
			return action
		end
	end
end

function ActionRow:SetActionEnabled(name, enabled)
	if self.Destroyed then
		return self
	end
	local action = self:_find(name)
	if action then
		action.Enabled = enabled == true
		action.Button.TextTransparency = self.Enabled and action.Enabled and 0 or 0.45
		action.Button.BackgroundTransparency = self.Enabled and action.Enabled and 0 or 0.35
	end
	return self
end

function ActionRow:SetActionText(name, text)
	if self.Destroyed then
		return self
	end
	local action = self:_find(name)
	if action then
		action.Name = tostring(text or "")
		action.Button.Text = action.Name
	end
	return self
end

function ActionRow:GetValue()
	return nil
end

function ActionRow:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end
	self.Enabled = enabled == true
	for _, action in ipairs(self.Actions) do
		local active = self.Enabled and action.Enabled
		action.Button.TextTransparency = active and 0 or 0.45
		action.Button.BackgroundTransparency = active and 0 or 0.35
	end
	return self
end

function ActionRow:Enable()
	return self:SetEnabled(true)
end

function ActionRow:Disable()
	return self:SetEnabled(false)
end

function ActionRow:SetVisible(visible)
	if not self.Destroyed then
		self.Library:_SetElementVisible(self, visible == true)
	end
	return self
end

function ActionRow:Show()
	return self:SetVisible(true)
end

function ActionRow:Hide()
	return self:SetVisible(false)
end

function ActionRow:Refresh()
	if not self.Destroyed then
		self:SetTheme(self.Theme)
	end
	return self
end

function ActionRow:SetTheme(theme)
	if self.Destroyed then
		return self
	end
	self.Theme = theme
	for _, action in ipairs(self.Actions) do
		local background, textColor = styleColor(theme, action.Style)
		action.Button.BackgroundColor3 = background
		action.Button.TextColor3 = textColor
	end
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	return self:SetEnabled(self.Enabled)
end

function ActionRow:Destroy()
	if self.Destroyed then
		return self
	end
	self.Destroyed = true
	self.Library:_UnregisterDependencies(self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return ActionRow
