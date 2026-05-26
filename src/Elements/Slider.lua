local UserInputService = game:GetService("UserInputService")

local Slider = {}
Slider.__index = Slider

local function decimalPlaces(value)
	local text = string.format("%.6f", math.abs(value))
	text = string.gsub(text, "0+$", "")
	local decimal = string.match(text, "%.(%d+)$")
	return decimal and #decimal or 0
end

local function round(value, precision)
	local factor = 10 ^ precision
	local scaled = value * factor
	local rounded = scaled >= 0 and math.floor(scaled + 0.5) or math.ceil(scaled - 0.5)
	return rounded / factor
end

local function snap(value, min, max, increment, precision)
	increment = increment or 1
	local clamped = math.clamp(value, min, max)
	if max == min or clamped <= min then
		return round(min, precision)
	end
	if clamped >= max then
		return round(max, precision)
	end

	local steps = math.floor(((clamped - min) / increment) + 0.5)
	return math.clamp(round(min + (steps * increment), precision), min, max)
end

local function formatValue(value, precision)
	if precision <= 0 then
		return string.format("%.0f", value)
	end
	return string.format("%." .. tostring(precision) .. "f", value)
end

function Slider.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "Slider ignored an invalid Flag value")
		flag = nil
	end

	local min = tonumber(options.Min) or 0
	local max = tonumber(options.Max) or 100
	if max < min then
		min, max = max, min
		context.Library:_Warn("Slider", "'" .. tostring(options.Name or "Slider") .. "' had Max below Min; values were swapped")
	end

	local increment = math.max(math.abs(tonumber(options.Increment) or 1), 0.000001)

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or "Slider"),
		Flag = flag,
		Min = min,
		Max = max,
		Increment = increment,
		Precision = math.max(decimalPlaces(min), decimalPlaces(max), decimalPlaces(increment)),
		Value = tonumber(options.Default) or min,
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
		Connections = {},
		Tweens = {},
		Dragging = false,
		DragInput = nil,
		Enabled = true,
	}, Slider)

	local theme = self.Theme
	local utility = self.Utility
	local compact = section.Compact == true

	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 48 or 58),
		BackgroundTransparency = 1,
		Parent = section.Frame,
	})

	local label = utility:Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(1, -82, 0, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})

	local valueLabel = utility:Create("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(76, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextColor3 = theme.Accent,
		TextSize = compact and 12 or 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = frame,
	})

	local bar = utility:Create("TextButton", {
		Name = "Bar",
		Position = UDim2.fromOffset(0, compact and 29 or 34),
		Size = UDim2.new(1, 0, 0, compact and 8 or 10),
		BackgroundColor3 = theme.Background,
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
	})
	utility:Corner(bar, 6)
	utility:Stroke(bar, theme.Stroke, 0.55)

	local fill = utility:Create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = theme.Accent,
		Parent = bar,
	})
	utility:Corner(fill, 6)

	local knob = utility:Create("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = theme.Text,
		Parent = bar,
	})
	utility:Corner(knob, 8)
	utility:Stroke(knob, theme.Stroke, 0.1)

	self.Instance = frame
	self.Label = label
	self.ValueLabel = valueLabel
	self.Bar = bar
	self.Fill = fill
	self.Knob = knob

	local function updateFromPosition(x)
		if self.Enabled == false then
			return
		end

		local ratio = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		local value = snap(self.Min + ((self.Max - self.Min) * ratio), self.Min, self.Max, self.Increment, self.Precision)
		if self.Flag then
			self.Library:SetFlag(self.Flag, value, true, true)
		else
			self:SetValue(value, true, true)
		end
	end

	utility:Connect(self.Connections, bar.InputBegan, function(input)
		if self.Enabled == false then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.Dragging = true
			self.DragInput = input
			updateFromPosition(input.Position.X)
		end
	end)

	utility:Connect(self.Connections, bar.MouseEnter, function()
		if self.Enabled == false then
			return
		end

		utility:Tween(knob, utility.Motion.Fast, { Size = UDim2.fromOffset(18, 18) })
	end)

	utility:Connect(self.Connections, bar.MouseLeave, function()
		if self.Enabled == false or self.Dragging then
			return
		end

		utility:Tween(knob, utility.Motion.Fast, { Size = UDim2.fromOffset(16, 16) })
	end)

	utility:Connect(self.Connections, UserInputService.InputChanged, function(input)
		if not self.Dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			updateFromPosition(input.Position.X)
		end
	end)

	utility:Connect(self.Connections, UserInputService.InputEnded, function(input)
		local isMouseRelease = self.DragInput
			and self.DragInput.UserInputType == Enum.UserInputType.MouseButton1
			and input.UserInputType == Enum.UserInputType.MouseButton1
		if self.Dragging and (isMouseRelease or input == self.DragInput) then
			self.Dragging = false
			self.DragInput = nil
			utility:Tween(knob, utility.Motion.Fast, { Size = UDim2.fromOffset(16, 16) })
		end
	end)

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false)
	self.Library:_BindElement(self, options)

	return self
end

function Slider:GetValue()
	return self.Value
end

function Slider:SetValue(value, fireCallback, instant)
	if self.Destroyed then
		return self
	end

	if tonumber(value) == nil then
		self.Library:_Warn("Slider", "'" .. self.Name .. "' ignored a non-numeric value")
		return self
	end

	local nextValue = snap(tonumber(value), self.Min, self.Max, self.Increment, self.Precision)
	local changed = self.Value ~= nextValue
	self.Value = nextValue

	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	local range = self.Max - self.Min
	local ratio = range > 0 and (self.Value - self.Min) / range or 0
	self.ValueLabel.Text = formatValue(self.Value, self.Precision)
	if instant then
		for _, key in ipairs({ "Fill", "Knob" }) do
			local tween = self.Tweens[key]
			if tween then
				tween:Cancel()
				self.Tweens[key] = nil
			end
		end
		self.Fill.Size = UDim2.fromScale(ratio, 1)
		self.Knob.Position = UDim2.fromScale(ratio, 0.5)
	else
		self.Utility:TweenTracked(self.Tweens, "Fill", self.Fill, self.Utility.Motion.Fast, { Size = UDim2.fromScale(ratio, 1) })
		self.Utility:TweenTracked(self.Tweens, "Knob", self.Knob, self.Utility.Motion.Fast, { Position = UDim2.fromScale(ratio, 0.5) })
	end

	if changed and fireCallback ~= false then
		self.Library:_InvokeCallback("Slider", self.Callback, self.Value)
	end

	return self
end

function Slider:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end

	self.Enabled = enabled == true
	self.Label.TextTransparency = self.Enabled and 0 or 0.45
	self.ValueLabel.TextTransparency = self.Enabled and 0 or 0.45
	self.Bar.BackgroundTransparency = self.Enabled and 0 or 0.35
	self.Fill.BackgroundTransparency = self.Enabled and 0 or 0.35
	self.Knob.BackgroundTransparency = self.Enabled and 0 or 0.35

	if not self.Enabled then
		self.Dragging = false
		self.DragInput = nil
		self.Utility:Tween(self.Knob, self.Utility.Motion.Fast, { Size = UDim2.fromOffset(16, 16) })
	end
	return self
end

function Slider:Enable()
	return self:SetEnabled(true)
end

function Slider:Disable()
	return self:SetEnabled(false)
end

function Slider:SetVisible(visible)
	if self.Destroyed then
		return self
	end

	self.Library:_SetElementVisible(self, visible == true)
	return self
end

function Slider:Show()
	return self:SetVisible(true)
end

function Slider:Hide()
	return self:SetVisible(false)
end

function Slider:SetText(text)
	if self.Destroyed then
		return self
	end

	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function Slider:SetCallback(callback)
	if self.Destroyed then
		return self
	end

	self.Callback = typeof(callback) == "function" and callback or function() end
	return self
end

function Slider:Set(value, fireCallback)
	return self:SetValue(value, fireCallback)
end

function Slider:SetRange(min, max, increment)
	if self.Destroyed then
		return self
	end

	min = tonumber(min) or self.Min
	max = tonumber(max) or self.Max
	if max < min then
		min, max = max, min
	end

	self.Min = min
	self.Max = max
	self.Increment = math.max(math.abs(tonumber(increment) or self.Increment), 0.000001)
	self.Precision = math.max(decimalPlaces(self.Min), decimalPlaces(self.Max), decimalPlaces(self.Increment))
	self:SetValue(self.Value, false)
	return self
end

function Slider:Refresh()
	if not self.Destroyed then
		self:SetValue(self.Value, false)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function Slider:SetTheme(theme)
	if self.Destroyed then
		return self
	end

	self.Theme = theme
	self.Label.TextColor3 = theme.Text
	self.ValueLabel.TextColor3 = theme.Accent
	self.Bar.BackgroundColor3 = theme.Background
	self.Fill.BackgroundColor3 = theme.Accent
	self.Knob.BackgroundColor3 = theme.Text
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	self:SetEnabled(self.Enabled)
	return self
end

function Slider:Destroy()
	if self.Destroyed then
		return self
	end

	self.Destroyed = true
	self.Utility:CancelTweens(self.Tweens)
	self.Library:_UnregisterDependencies(self)
	self.Context.Flags:Unregister(self.Library, self.Flag, self)
	self.Utility:DisconnectAll(self.Connections)
	if self.Instance then
		self.Instance:Destroy()
	end
	return self
end

return Slider
