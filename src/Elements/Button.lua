local Button = {}
Button.__index = Button

function Button.new(context, section, options)
	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = options.Name or options.Text or "Button",
		Callback = options.Callback or options.Func or function() end,
		Connections = {},
		Enabled = true,
	}, Button)

	local theme = self.Theme
	local utility = self.Utility

	local button = utility:Create("TextButton", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = theme.Background,
		Font = Enum.Font.GothamMedium,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutoButtonColor = false,
		Parent = section.Frame,
	})
	utility:Corner(button, 8)
	utility:Stroke(button, theme.Stroke, 0.55)

	self.Instance = button
	self._themeObjects = {
		{ button, "BackgroundColor3", "Background" },
		{ button, "TextColor3", "Text" },
	}

	utility:Connect(self.Connections, button.MouseEnter, function()
		if self.Enabled == false then
			return
		end
		utility:Tween(button, 0.14, { BackgroundColor3 = self.Theme.Topbar })
	end)

	utility:Connect(self.Connections, button.MouseLeave, function()
		if self.Enabled == false then
			return
		end
		utility:Tween(button, 0.14, { BackgroundColor3 = self.Theme.Background })
	end)

	utility:Connect(self.Connections, button.MouseButton1Click, function()
		if self.Enabled == false then
			return
		end
		task.spawn(self.Callback)
	end)

	utility:Connect(self.Connections, button.MouseButton1Down, function()
		if self.Enabled == false then
			return
		end
		utility:Tween(button, 0.08, { BackgroundTransparency = 0.18 })
	end)

	utility:Connect(self.Connections, button.MouseButton1Up, function()
		if self.Enabled == false then
			return
		end
		utility:Tween(button, 0.1, { BackgroundTransparency = 0 })
	end)

	self.Library:_BindElement(self, options)

	return self
end

function Button:SetEnabled(enabled)
	self.Enabled = enabled == true
	self.Instance.TextTransparency = self.Enabled and 0 or 0.45
	self.Instance.BackgroundTransparency = self.Enabled and 0 or 0.35
end

function Button:SetTheme(theme)
	self.Theme = theme
	for _, binding in ipairs(self._themeObjects) do
		local object, property, key = binding[1], binding[2], binding[3]
		object[property] = theme[key]
	end
end

function Button:Destroy()
	self.Utility:DisconnectAll(self.Connections)
	self.Instance:Destroy()
end

return Button
