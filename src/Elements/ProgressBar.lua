local ProgressBar = {}
ProgressBar.__index = ProgressBar

local function clampValue(value, min, max)
	return math.clamp(tonumber(value) or min, min, max)
end

local function formatPercent(value)
	local rounded = math.floor(value + 0.5)
	return tostring(rounded) .. "%"
end

function ProgressBar.new(context, section, options)
	options = options or {}
	local flag = options.Flag
	if flag ~= nil and (typeof(flag) ~= "string" or flag == "") then
		context.Library:_Warn("Flag", "ProgressBar ignored an invalid Flag value")
		flag = nil
	end

	local min = tonumber(options.Min) or 0
	local max = tonumber(options.Max) or 100
	if max < min then
		min, max = max, min
	end

	local self = setmetatable({
		Context = context,
		Section = section,
		Library = context.Library,
		Utility = context.Utility,
		Theme = context.Library.Theme,
		Name = tostring(options.Name or options.Title or "Progress"),
		Status = tostring(options.Status or ""),
		Flag = flag,
		Min = min,
		Max = max,
		Value = clampValue(options.Default or options.Value, min, max),
		Callback = typeof(options.Callback) == "function" and options.Callback or function() end,
		Connections = {},
		Tweens = {},
		Enabled = true,
	}, ProgressBar)

	local compact = section.Compact == true
	local theme = self.Theme
	local utility = self.Utility
	local frame = utility:Create("Frame", {
		Name = self.Name,
		Size = UDim2.new(1, 0, 0, compact and 45 or 50),
		BackgroundTransparency = 1,
		Parent = section.Frame,
	})
	local label = utility:Create("TextLabel", {
		Name = "Label",
		Size = UDim2.new(0.55, 0, 0, 19),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = self.Name,
		TextColor3 = theme.Text,
		TextSize = compact and 12 or 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local status = utility:Create("TextLabel", {
		Name = "Status",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0.45, 0, 0, 19),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextColor3 = theme.MutedText,
		TextSize = compact and 11 or 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = frame,
	})
	local track = utility:Create("Frame", {
		Name = "Track",
		Position = UDim2.fromOffset(0, compact and 27 or 30),
		Size = UDim2.new(1, 0, 0, compact and 8 or 10),
		BackgroundColor3 = theme.Background,
		Parent = frame,
	})
	utility:Corner(track, 6)
	utility:Stroke(track, theme.Stroke, 0.55)
	local fill = utility:Create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = theme.Accent,
		Parent = track,
	})
	utility:Corner(fill, 6)

	self.Instance = frame
	self.Label = label
	self.StatusLabel = status
	self.Track = track
	self.Fill = fill

	context.Flags:Register(self.Library, self.Flag, self)
	self:SetValue(self.Value, false, true)
	self.Library:_BindElement(self, options)
	return self
end

function ProgressBar:GetValue()
	return self.Value
end

function ProgressBar:SetValue(value, fireCallback, instant)
	if self.Destroyed then
		return self
	end
	if tonumber(value) == nil then
		self.Library:_Warn("ProgressBar", "'" .. self.Name .. "' ignored a non-numeric value")
		return self
	end

	local nextValue = clampValue(value, self.Min, self.Max)
	local changed = self.Value ~= nextValue
	self.Value = nextValue
	if self.Flag then
		self.Library.Flags[self.Flag] = self.Value
	end

	local range = self.Max - self.Min
	local ratio = range > 0 and (self.Value - self.Min) / range or 0
	local percent = formatPercent(ratio * 100)
	self.StatusLabel.Text = self.Status ~= "" and (self.Status .. "  " .. percent) or percent
	if instant then
		self.Utility:CancelTweens(self.Tweens)
		self.Fill.Size = UDim2.fromScale(ratio, 1)
	else
		self.Utility:TweenTracked(self.Tweens, "Fill", self.Fill, self.Utility.Motion.Standard, { Size = UDim2.fromScale(ratio, 1) })
	end

	if changed and fireCallback ~= false then
		self.Library:_InvokeCallback("ProgressBar", self.Callback, self.Value)
	end
	return self
end

function ProgressBar:Set(value, fireCallback)
	return self:SetValue(value, fireCallback)
end

function ProgressBar:SetStatus(text)
	if self.Destroyed then
		return self
	end
	self.Status = tostring(text or "")
	return self:SetValue(self.Value, false, true)
end

function ProgressBar:SetText(text)
	if self.Destroyed then
		return self
	end
	self.Name = tostring(text or "")
	self.Label.Text = self.Name
	return self
end

function ProgressBar:SetEnabled(enabled)
	if self.Destroyed then
		return self
	end
	self.Enabled = enabled == true
	local transparency = self.Enabled and 0 or 0.45
	self.Label.TextTransparency = transparency
	self.StatusLabel.TextTransparency = transparency
	self.Track.BackgroundTransparency = self.Enabled and 0 or 0.35
	self.Fill.BackgroundTransparency = self.Enabled and 0 or 0.35
	return self
end

function ProgressBar:Enable()
	return self:SetEnabled(true)
end

function ProgressBar:Disable()
	return self:SetEnabled(false)
end

function ProgressBar:SetVisible(visible)
	if not self.Destroyed then
		self.Library:_SetElementVisible(self, visible == true)
	end
	return self
end

function ProgressBar:Show()
	return self:SetVisible(true)
end

function ProgressBar:Hide()
	return self:SetVisible(false)
end

function ProgressBar:Refresh()
	if not self.Destroyed then
		self:SetValue(self.Value, false, true)
		self:SetEnabled(self.Enabled)
	end
	return self
end

function ProgressBar:SetTheme(theme)
	if self.Destroyed then
		return self
	end
	self.Theme = theme
	self.Label.TextColor3 = theme.Text
	self.StatusLabel.TextColor3 = theme.MutedText
	self.Track.BackgroundColor3 = theme.Background
	self.Fill.BackgroundColor3 = theme.Accent
	self.Utility:ApplyStrokeTheme(self.Instance, theme.Stroke)
	return self:SetEnabled(self.Enabled)
end

function ProgressBar:Destroy()
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

return ProgressBar
