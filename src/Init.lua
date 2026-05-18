local root = script:FindFirstChild("Core") and script or script.Parent
local core = root:WaitForChild("Core")
local elementsFolder = root:WaitForChild("Elements")

local Utility = require(core:WaitForChild("Utility"))
local Theme = require(core:WaitForChild("Theme"))
local Flags = require(core:WaitForChild("Flags"))
local Config = require(core:WaitForChild("Config"))
local Notify = require(core:WaitForChild("Notify"))

local MidasUI = {
	Version = "1.1.0",
	Flags = {},
	Themes = Theme.Registry,
	ThemeName = "DarkGold",
	Theme = Theme.Registry.DarkGold,
	_windows = {},
	_flagObjects = {},
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
	Elements = {},
}

Context.Window = require(core:WaitForChild("Window"))
Context.Tab = require(core:WaitForChild("Tab"))
Context.Section = require(core:WaitForChild("Section"))

Context.Elements.Button = require(elementsFolder:WaitForChild("Button"))
Context.Elements.Toggle = require(elementsFolder:WaitForChild("Toggle"))
Context.Elements.Slider = require(elementsFolder:WaitForChild("Slider"))
Context.Elements.Dropdown = require(elementsFolder:WaitForChild("Dropdown"))
Context.Elements.Input = require(elementsFolder:WaitForChild("Input"))
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

function MidasUI:SaveConfig()
	return Config:Save(self)
end

function MidasUI:LoadConfig()
	return Config:Load(self)
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

	if self._notifyGui then
		self._notifyGui:Destroy()
		self._notifyGui = nil
		self._notifyHolder = nil
	end
end

return MidasUI
