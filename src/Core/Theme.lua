local Theme = {}

Theme.RequiredKeys = {
	"Background",
	"Topbar",
	"Sidebar",
	"Card",
	"Accent",
	"Text",
	"MutedText",
	"Stroke",
	"Danger",
}

Theme.Registry = {
	DarkGold = {
		Background = Color3.fromRGB(13, 13, 15),
		Topbar = Color3.fromRGB(22, 21, 20),
		Sidebar = Color3.fromRGB(17, 17, 19),
		Card = Color3.fromRGB(25, 24, 22),
		Accent = Color3.fromRGB(214, 174, 86),
		Text = Color3.fromRGB(246, 241, 229),
		MutedText = Color3.fromRGB(156, 149, 135),
		Stroke = Color3.fromRGB(74, 62, 38),
		Danger = Color3.fromRGB(224, 87, 87),
	},

	Midnight = {
		Background = Color3.fromRGB(11, 14, 23),
		Topbar = Color3.fromRGB(16, 20, 31),
		Sidebar = Color3.fromRGB(13, 17, 28),
		Card = Color3.fromRGB(20, 25, 38),
		Accent = Color3.fromRGB(106, 151, 255),
		Text = Color3.fromRGB(235, 240, 255),
		MutedText = Color3.fromRGB(139, 150, 176),
		Stroke = Color3.fromRGB(45, 58, 83),
		Danger = Color3.fromRGB(235, 91, 105),
	},

	BlackWhite = {
		Background = Color3.fromRGB(10, 10, 10),
		Topbar = Color3.fromRGB(20, 20, 20),
		Sidebar = Color3.fromRGB(15, 15, 15),
		Card = Color3.fromRGB(27, 27, 27),
		Accent = Color3.fromRGB(238, 238, 238),
		Text = Color3.fromRGB(247, 247, 247),
		MutedText = Color3.fromRGB(154, 154, 154),
		Stroke = Color3.fromRGB(62, 62, 62),
		Danger = Color3.fromRGB(232, 78, 78),
	},
}

function Theme:Get(name)
	if typeof(name) == "table" then
		return self:Normalize(name), "Custom"
	end

	local themeName = name or "DarkGold"
	return self.Registry[themeName] or self.Registry.DarkGold, self.Registry[themeName] and themeName or "DarkGold"
end

function Theme:Normalize(values, baseName)
	local base = self.Registry[baseName or "DarkGold"] or self.Registry.DarkGold
	local normalized = {}

	for _, key in ipairs(self.RequiredKeys) do
		normalized[key] = values[key] or base[key]
	end

	return normalized
end

function Theme:Register(name, values)
	if typeof(name) ~= "string" or name == "" then
		return false, "Theme name must be a non-empty string"
	end

	if typeof(values) ~= "table" then
		return false, "Theme values must be a table"
	end

	self.Registry[name] = self:Normalize(values)
	return true
end

return Theme
