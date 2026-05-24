local Divider = {}
Divider.__index = Divider

function Divider.new(context, section, options)
	options = options or {}
	local self = setmetatable({
		Context = context,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Connections = {},
		Enabled = true,
	}, Divider)

	local frame = self.Utility:Create("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, 9),
		BackgroundTransparency = 1,
		Visible = options.Visible ~= false,
		Parent = section.Frame,
	})

	local line = self.Utility:Create("Frame", {
		Name = "Line",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = self.Theme.Stroke,
		BackgroundTransparency = 0.2,
		Parent = frame,
	})

	self.Instance = frame
	self.Line = line
	context.Library:_BindElement(self, options)
	return self
end

function Divider:Set(visible)
	return self:SetVisible(visible)
end

function Divider:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Context.Library:_SetElementVisible(self, visible == true)
	return self
end

function Divider:Show()
	return self:SetVisible(true)
end

function Divider:Hide()
	return self:SetVisible(false)
end

function Divider:GetValue()
	return nil
end

function Divider:SetValue(visible)
	return self:SetVisible(visible)
end

function Divider:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Line.BackgroundColor3 = theme.Stroke
	self:SetEnabled(self.Enabled)
	return self
end

function Divider:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Line.BackgroundTransparency = self.Enabled and 0.2 or 0.75
	return self
end

function Divider:Enable()
	return self:SetEnabled(true)
end

function Divider:Disable()
	return self:SetEnabled(false)
end

function Divider:Refresh()
	if not self.Destroyed then
		self:SetTheme(self.Theme)
	end
	return self
end

function Divider:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Context.Library:_UnregisterDependencies(self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return Divider
