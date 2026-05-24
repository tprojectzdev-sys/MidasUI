local Theme = {}

Theme.RequiredKeys = {
	"Background",
	"Topbar",
	"Sidebar",
	"Card",
	"Accent",
	"AccentSoft",
	"Highlight",
	"Text",
	"MutedText",
	"Stroke",
	"Shadow",
	"Danger",
	"Success",
}

Theme.Registry = {
	DarkGold = {
		Background = Color3.fromRGB(10, 10, 12),
		Topbar = Color3.fromRGB(28, 23, 17),
		Sidebar = Color3.fromRGB(15, 14, 15),
		Card = Color3.fromRGB(26, 23, 19),
		Accent = Color3.fromRGB(226, 181, 72),
		AccentSoft = Color3.fromRGB(65, 49, 22),
		Highlight = Color3.fromRGB(255, 220, 132),
		Text = Color3.fromRGB(250, 246, 235),
		MutedText = Color3.fromRGB(174, 160, 133),
		Stroke = Color3.fromRGB(98, 72, 33),
		Shadow = Color3.fromRGB(4, 4, 6),
		Danger = Color3.fromRGB(226, 82, 82),
		Success = Color3.fromRGB(78, 188, 121),
	},

	Midnight = {
		Background = Color3.fromRGB(7, 10, 18),
		Topbar = Color3.fromRGB(13, 20, 36),
		Sidebar = Color3.fromRGB(9, 14, 26),
		Card = Color3.fromRGB(17, 25, 42),
		Accent = Color3.fromRGB(94, 152, 255),
		AccentSoft = Color3.fromRGB(25, 48, 90),
		Highlight = Color3.fromRGB(169, 204, 255),
		Text = Color3.fromRGB(239, 245, 255),
		MutedText = Color3.fromRGB(146, 163, 194),
		Stroke = Color3.fromRGB(46, 68, 108),
		Shadow = Color3.fromRGB(3, 5, 11),
		Danger = Color3.fromRGB(235, 91, 105),
		Success = Color3.fromRGB(72, 191, 143),
	},

	BlackWhite = {
		Background = Color3.fromRGB(7, 7, 8),
		Topbar = Color3.fromRGB(21, 21, 23),
		Sidebar = Color3.fromRGB(13, 13, 15),
		Card = Color3.fromRGB(27, 27, 30),
		Accent = Color3.fromRGB(235, 235, 238),
		AccentSoft = Color3.fromRGB(55, 55, 59),
		Highlight = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(247, 247, 247),
		MutedText = Color3.fromRGB(164, 164, 169),
		Stroke = Color3.fromRGB(74, 74, 80),
		Shadow = Color3.fromRGB(2, 2, 3),
		Danger = Color3.fromRGB(232, 78, 78),
		Success = Color3.fromRGB(108, 198, 133),
	},
}

Theme.Fallback = table.clone(Theme.Registry.DarkGold)

function Theme:Get(name)
	if typeof(name) == "table" then
		return self:Normalize(name), "Custom"
	end

	local themeName = typeof(name) == "string" and name or "DarkGold"
	if self.Registry[themeName] then
		return self:Normalize(self.Registry[themeName], themeName), themeName
	end
	return self:Normalize(self.Registry.DarkGold), "DarkGold"
end

function Theme:Normalize(values, baseName)
	local base = self.Registry[baseName or "DarkGold"] or self.Registry.DarkGold
	local normalized = {}

	for _, key in ipairs(self.RequiredKeys) do
		if typeof(values[key]) == "Color3" then
			normalized[key] = values[key]
		elseif typeof(base[key]) == "Color3" then
			normalized[key] = base[key]
		else
			normalized[key] = self.Fallback[key]
		end
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
	return true, self.Registry[name]
end

return Theme
