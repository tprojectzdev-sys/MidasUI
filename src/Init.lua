local root = script:FindFirstChild("Core") and script or script.Parent
local core = root:WaitForChild("Core")
local elementsFolder = root:WaitForChild("Elements")
local assetsFolder = root:FindFirstChild("Assets")

local Utility = require(core:WaitForChild("Utility"))
local Theme = require(core:WaitForChild("Theme"))
local Flags = require(core:WaitForChild("Flags"))
local Config = require(core:WaitForChild("Config"))
local Notify = require(core:WaitForChild("Notify"))
local Tooltip = require(core:WaitForChild("Tooltip"))
local Keybinds = require(core:WaitForChild("Keybinds"))
local Icons = assetsFolder and require(assetsFolder:WaitForChild("Icons")) or nil

if Icons and Icons.Map then
	Utility.IconGlyphs = Icons.Map
end

local MidasUI = {
	Version = "1.2.0",
	Flags = {},
	Keybinds = {},
	Themes = Theme.Registry,
	ThemeName = "DarkGold",
	Theme = Theme.Registry.DarkGold,
	_windows = {},
	_flagObjects = {},
	_dependencies = {},
	_configFolder = "Midas",
	_configFile = "config.json",
	_windowSettings = {},
}

local Context = {
	Library = MidasUI,
	Utility = Utility,
	Theme = Theme,
	Flags = Flags,
	Config = Config,
	Notify = Notify,
	Tooltip = Tooltip,
	Keybinds = Keybinds,
	Elements = {},
}

MidasUI._context = Context

Context.Window = require(core:WaitForChild("Window"))
Context.Tab = require(core:WaitForChild("Tab"))
Context.Section = require(core:WaitForChild("Section"))

Context.Elements.Button = require(elementsFolder:WaitForChild("Button"))
Context.Elements.Toggle = require(elementsFolder:WaitForChild("Toggle"))
Context.Elements.Slider = require(elementsFolder:WaitForChild("Slider"))
Context.Elements.Dropdown = require(elementsFolder:WaitForChild("Dropdown"))
Context.Elements.Input = require(elementsFolder:WaitForChild("Input"))
Context.Elements.Keybind = require(elementsFolder:WaitForChild("Keybind"))
Context.Elements.Paragraph = require(elementsFolder:WaitForChild("Paragraph"))
Context.Elements.Divider = require(elementsFolder:WaitForChild("Divider"))

function MidasUI:RegisterTheme(name, values)
	Theme:Register(name, values)
	self.Themes = Theme.Registry
end

function MidasUI:SetTheme(nameOrTheme)
	local theme, themeName = Theme:Get(nameOrTheme)
	self.Theme = theme
	self.ThemeName = themeName

	for _, window in ipairs(self._windows) do
		window:SetTheme(theme)
	end
end

function MidasUI:CreateWindow(options)
	options = options or {}
	self:SetTheme(options.Theme or self.ThemeName)
	return Context.Window.new(Context, options)
end

function MidasUI:GetFlag(flag)
	return Flags:Get(self, flag)
end

function MidasUI:SetFlag(flag, value, fireCallback)
	if typeof(flag) ~= "string" or flag == "" then
		return
	end

	Flags:Set(self, flag, value, fireCallback)
end

function MidasUI:_BindElement(element, options)
	options = options or {}

	if options.Tooltip then
		Tooltip:Bind(Context, element, element.Instance, options.Tooltip)
	end

	if options.DependsOn then
		self:_RegisterDependency(element, options.DependsOn)
	end
end

function MidasUI:_RegisterDependency(element, dependency)
	if typeof(dependency) ~= "table" or typeof(dependency.Flag) ~= "string" then
		return
	end

	local record = {
		Element = element,
		Flag = dependency.Flag,
		Value = dependency.Value,
		Mode = dependency.Mode or "Visible",
	}

	table.insert(self._dependencies, record)
	self:_ApplyDependency(record)
end

function MidasUI:_ApplyDependency(record)
	local element = record.Element
	if not element or not element.Instance then
		return
	end

	local expected = record.Value
	local actual = self.Flags[record.Flag]
	local passes = false

	if expected == nil then
		passes = actual == true
	else
		passes = actual == expected
	end

	if record.Mode == "Enabled" then
		if element.SetEnabled then
			element:SetEnabled(passes)
		else
			element.Instance.Visible = passes
		end
	else
		element.Instance.Visible = passes
	end
end

function MidasUI:_RefreshDependencies(flag)
	for index = #self._dependencies, 1, -1 do
		local record = self._dependencies[index]
		local element = record.Element

		if not element or not element.Instance or not element.Instance.Parent then
			table.remove(self._dependencies, index)
		elseif not flag or record.Flag == flag then
			self:_ApplyDependency(record)
		end
	end
end

function MidasUI:SaveConfig(profile)
	return Config:Save(self, profile)
end

function MidasUI:LoadConfig(profile)
	return Config:Load(self, profile)
end

function MidasUI:DeleteConfig(profile)
	return Config:Delete(self, profile)
end

function MidasUI:ListConfigs()
	return Config:List(self)
end

function MidasUI:Notify(options)
	Notify:Show(Context, options or {})
end

function MidasUI:Destroy()
	for _, window in ipairs(table.clone(self._windows)) do
		window:Destroy()
	end

	table.clear(self._windows)
	table.clear(self._flagObjects)
	table.clear(self._dependencies)
	table.clear(self.Keybinds)

	if self._listeningKeybind then
		self._listeningKeybind = nil
	end

	if self._notifyGui then
		self._notifyGui:Destroy()
		self._notifyGui = nil
		self._notifyHolder = nil
	end

	if self._tooltipGui then
		Tooltip:Hide(Context)
		self._tooltipGui:Destroy()
		self._tooltipGui = nil
		self._tooltipFrame = nil
		self._tooltipLabel = nil
	end

	if self._keybindConnections then
		Utility:DisconnectAll(self._keybindConnections)
	end

	if self._tooltipConnections then
		Utility:DisconnectAll(self._tooltipConnections)
	end

	self._keybindsReady = false
end

return MidasUI
