local Button = {}
Button.__index = Button

function Button.new(context, section, options)
	options = options or {}
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or options.Text or "Button"),
		Callback = typeof(options.Callback or options.Func) == "function" and (options.Callback or options.Func) or function() end,
		Connections = {},
		Tweens = {},
		Icon = options.Icon,
		Enabled = true,
	}, Button)

	local theme = self.Theme
	local utility = self.Utility
	local compact = section.Compact == true

	local button = utility:Create("TextButton", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 32 or 38),
		BackgroundColor3 = theme.Background,
		Font = Enum.Font.GothamMedium,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutoButtonColor = false,
		Parent = section.Frame,
	})
	utility:Corner(button, 8)
	local stroke = utility:Stroke(button, theme.Stroke, 0.55)
	local icon
	if self.Icon ~= nil then
		icon = utility:CreateIcon(button, self.Icon, {
			Position = UDim2.fromOffset(12, compact and 8 or 11),
			Size = UDim2.fromOffset(16, 16),
			Color = theme.Accent,
			TextSize = 12,
		})
		button.TextXAlignment = Enum.TextXAlignment.Left
		utility:Padding(button, { Left = 38, Right = 12 })
	end

	self.Instance = button
	self.Stroke = stroke
	self.IconLabel = icon
	self._themeObjects = {
		{ button, "BackgroundColor3", "Background" },
		{ button, "TextColor3", "Text" },
	}

	utility:Connect(self.Connections, button.MouseEnter, function()
		if self.Enabled == false then
			return
		end
		utility:TweenTracked(self.Tweens, "Surface", button, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Topbar })
	end)

	utility:Connect(self.Connections, button.MouseLeave, function()
		if self.Enabled == false then
			return
		end
		utility:TweenTracked(self.Tweens, "Surface", button, utility.Motion.Hover, { BackgroundColor3 = self.Theme.Background })
	end)

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		if self.Enabled == false then
			return
		end
		self.Library:_InvokeCallback("Button", self.Callback)
	end)

	utility:Connect(self.Connections, button.MouseButton1Down, function()
		if self.Enabled == false then
			return
		end
		utility:TweenTracked(self.Tweens, "Press", button, utility.Motion.Press, { BackgroundTransparency = 0.18 })
	end)

	utility:Connect(self.Connections, button.MouseButton1Up, function()
		if self.Enabled == false then
			return
		end
		utility:TweenTracked(self.Tweens, "Press", button, utility.Motion.Press, { BackgroundTransparency = 0 })
	end)
	utility:Connect(self.Connections, button.SelectionGained, function()
		if self.Enabled ~= false then
			stroke.Color = self.Theme.Accent
			stroke.Transparency = 0.08
		end
	end)
	utility:Connect(self.Connections, button.SelectionLost, function()
		stroke.Color = self.Theme.Stroke
		stroke.Transparency = 0.55
	end)

	self.Library:_BindElement(self, options)

	return self
end

function Button:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Instance.TextTransparency = self.Enabled and 0 or 0.45
	self.Instance.BackgroundTransparency = self.Enabled and 0 or 0.35
	return self
end

function Button:Enable()
	return self:SetEnabled(true)
end

function Button:Disable()
	return self:SetEnabled(false)
end

function Button:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Library:_SetElementVisible(self, visible == true)
	return self
end

function Button:Show()
	return self:SetVisible(true)
end

function Button:Hide()
	return self:SetVisible(false)
end

function Button:SetText(text)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(text or "")
	self.Instance.Text = self.Name
	return self
end

function Button:SetCallback(callback)
	if self.Destroyed then
		return self
	end

	self.Callback = typeof(callback) == "function" and callback or function() end
	return self
end

function Button:Refresh()
	if not self.Destroyed then
		self:SetEnabled(self.Enabled)
	end
	return self
end

function Button:GetValue()
	return nil
end

function Button:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		object[property] = theme[key]
	end
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	self.Utility:SetIconColor(self.IconLabel, theme.Accent)
	if game:GetService("GuiService").SelectedObject == self.Instance then
		self.Stroke.Color = theme.Accent
		self.Stroke.Transparency = 0.08
	end
	self:SetEnabled(self.Enabled)
	return self
end

function Button:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Utility:CancelTweens(self.Tweens)
	self.Library:_UnregisterDependencies(self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return Button
