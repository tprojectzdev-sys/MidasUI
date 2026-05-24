local Templates = {}

Templates.Registry = {
	Default = {
		Name = "Default",
		Compact = false,
		Dashboard = false,
		Dense = false,
		PagePadding = 14,
		PageSpacing = 10,
		CanvasPadding = 28,
		SectionPadding = 12,
		SectionSpacing = 8,
		SectionTitleSize = 13,
		SectionTransparency = 0,
		DefaultSize = UDim2.fromOffset(620, 460),
	},

	FarmingDashboard = {
		Name = "FarmingDashboard",
		Compact = false,
		Dashboard = true,
		Dense = false,
		PagePadding = 12,
		PageSpacing = 10,
		CanvasPadding = 24,
		SectionPadding = 14,
		SectionSpacing = 10,
		SectionTitleSize = 13,
		SectionTransparency = 0,
		DefaultSize = UDim2.fromOffset(760, 560),
	},

	PowerPanel = {
		Name = "PowerPanel",
		Compact = true,
		Dashboard = false,
		Dense = true,
		PagePadding = 10,
		PageSpacing = 7,
		CanvasPadding = 20,
		SectionPadding = 9,
		SectionSpacing = 5,
		SectionTitleSize = 12,
		SectionTransparency = 0.03,
		DefaultSize = UDim2.fromOffset(760, 540),
	},
}

local numericKeys = {
	"PagePadding",
	"PageSpacing",
	"CanvasPadding",
	"SectionPadding",
	"SectionSpacing",
	"SectionTitleSize",
	"SectionTransparency",
}

function Templates:Normalize(values, name)
	values = typeof(values) == "table" and values or self.Registry.Default
	local base = self.Registry.Default
	local normalized = {
		Name = tostring(name or values.Name or "Custom"),
		Compact = values.Compact == true,
		Dashboard = values.Dashboard == true,
		Dense = values.Dense == true,
		DefaultSize = typeof(values.DefaultSize) == "UDim2" and values.DefaultSize or base.DefaultSize,
	}

	for _, key in ipairs(numericKeys) do
		normalized[key] = tonumber(values[key]) or base[key]
	end

	return normalized
end

function Templates:Get(nameOrTemplate)
	if typeof(nameOrTemplate) == "table" then
		return self:Normalize(nameOrTemplate, "Custom"), "Custom", true
	end

	local name = typeof(nameOrTemplate) == "string" and nameOrTemplate or "Default"
	local preset = self.Registry[name]
	if preset then
		return self:Normalize(preset, name), name, true
	end

	return self:Normalize(self.Registry.Default, "Default"), "Default", false
end

return Templates
