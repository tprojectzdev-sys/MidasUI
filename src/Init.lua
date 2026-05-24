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
local Dialog = require(core:WaitForChild("Dialog"))
local Templates = require(core:WaitForChild("Templates"))
local Commands = require(core:WaitForChild("Commands"))
local CommandPalette = require(core:WaitForChild("CommandPalette"))
local Icons = assetsFolder and require(assetsFolder:WaitForChild("Icons")) or nil

if Icons and Icons.Map then
	Utility.IconGlyphs = Icons.Map
end

local MidasUI = {
	Version = "1.8.0",
	Flags = {},
	Keybinds = {},
	Themes = Theme.Registry,
	Templates = Templates.Registry,
	ThemeName = "DarkGold",
	Theme = Theme:Normalize(Theme.Registry.DarkGold),
	_windows = {},
	_flagObjects = {},
	_dependencies = {},
	_debug = false,
	_warnings = {},
	_warningCategories = {},
	_configFolder = "Midas",
	_configFile = "config.json",
	_windowSettings = {},
	CommandPaletteKeyCode = Enum.KeyCode.K,
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
	Dialog = Dialog,
	Templates = Templates,
	Commands = Commands,
	CommandPalette = CommandPalette,
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
Context.Elements.ProgressBar = require(elementsFolder:WaitForChild("ProgressBar"))
Context.Elements.StatCard = require(elementsFolder:WaitForChild("StatCard"))
Context.Elements.LogPanel = require(elementsFolder:WaitForChild("LogPanel"))
Context.Elements.Callout = require(elementsFolder:WaitForChild("Callout"))
Context.Elements.ActionRow = require(elementsFolder:WaitForChild("ActionRow"))

function MidasUI:_Warn(category, message)
	if not self._debug then
		return
	end

	if message == nil then
		message = category
		category = "General"
	end

	category = tostring(category or "General")
	local text = "[MidasUI][" .. category .. "] " .. tostring(message)
	table.insert(self._warnings, text)
	self._warningCategories[category] = (self._warningCategories[category] or 0) + 1
	warn(text)
end

function MidasUI:SetDebug(enabled)
	self._debug = enabled == true
	return self
end

function MidasUI:_InvokeCallback(category, callback, ...)
	if typeof(callback) ~= "function" then
		self:_Warn(category or "Callback", "Ignored a callback that is not a function")
		return
	end

	local arguments = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(callback, table.unpack(arguments, 1, arguments.n))
		if not ok then
			self:_Warn(category or "Callback", "Callback failed: " .. tostring(err))
		end
	end)
end

function MidasUI:GetDebugState()
	if not self._debug then
		return nil
	end

	local flagCount = 0
	for _ in pairs(self.Flags) do
		flagCount = flagCount + 1
	end

	local keybindCount = 0
	for _ in pairs(self.Keybinds) do
		keybindCount = keybindCount + 1
	end

	local commandCount = 0
	for _, command in pairs(self._commands or {}) do
		if not command.Owner or (not command.Owner.Destroyed and not command.Owner.Closed) then
			commandCount = commandCount + 1
		end
	end

	local searchItemCount = 0
	for _ in pairs(self._searchItems or {}) do
		searchItemCount = searchItemCount + 1
	end

	return {
		Version = self.Version,
		Theme = self.ThemeName,
		WindowCount = #self._windows,
		FlagCount = flagCount,
		KeybindCount = keybindCount,
		CommandCount = commandCount,
		SearchItemCount = searchItemCount,
		DependencyCount = #self._dependencies,
		NotificationCount = self._notifications and #self._notifications or 0,
		HasActiveDialog = self._activeDialog ~= nil,
		HasOpenCommandPalette = self._activePalette ~= nil,
		Warnings = table.clone(self._warnings),
		WarningCategories = table.clone(self._warningCategories),
	}
end

function MidasUI:RegisterTheme(name, values)
	local ok, err = Theme:Register(name, values)
	if not ok then
		self:_Warn("Theme", err)
		return false, err
	end

	self.Themes = Theme.Registry
	return true, name
end

function MidasUI:GetTemplate(nameOrTemplate)
	return Templates:Get(nameOrTemplate)
end

function MidasUI:SetTheme(nameOrTheme)
	local theme, themeName = Theme:Get(nameOrTheme)
	local valid = true
	if typeof(nameOrTheme) == "string" and not Theme.Registry[nameOrTheme] then
		valid = false
		self:_Warn("Theme", "Unknown theme '" .. nameOrTheme .. "', falling back to " .. themeName)
	elseif typeof(nameOrTheme) ~= "string" and typeof(nameOrTheme) ~= "table" and nameOrTheme ~= nil then
		valid = false
		self:_Warn("Theme", "Invalid theme value, falling back to " .. themeName)
	end

	self.Theme = theme
	self.ThemeName = themeName

	for _, window in ipairs(self._windows) do
		window:SetTheme(theme)
	end

	Notify:SetTheme(Context)
	Tooltip:SetTheme(Context)
	Dialog:SetTheme(Context)
	CommandPalette:SetTheme(Context)
	return valid, themeName
end

function MidasUI:CreateWindow(options)
	if options ~= nil and typeof(options) ~= "table" then
		self:_Warn("API", "CreateWindow expected an options table")
		options = {}
	end

	options = options or {}
	self:SetTheme(options.Theme or self.ThemeName)
	CommandPalette:Init(Context)
	local window = Context.Window.new(Context, options)
	Commands:IndexObject(self, window, "Window")
	return window
end

function MidasUI:_IsCommandPaletteHotkey(input)
	if not input or input.KeyCode ~= self.CommandPaletteKeyCode then
		return false
	end

	local userInputService = game:GetService("UserInputService")
	return userInputService:IsKeyDown(Enum.KeyCode.LeftControl)
		or userInputService:IsKeyDown(Enum.KeyCode.RightControl)
end

function MidasUI:RegisterCommand(options)
	return Commands:Register(self, options)
end

function MidasUI:UnregisterCommand(idOrController)
	return Commands:Unregister(self, idOrController)
end

function MidasUI:RunCommand(idOrController)
	local id = typeof(idOrController) == "table" and idOrController.Id or idOrController
	local ok = Commands:Execute(self, id)
	return ok
end

function MidasUI:Search(query, options)
	local results = Commands:Search(self, query, options)
	local publicResults = {}
	for _, result in ipairs(results) do
		local record = result._Record
		local entry = {
			Id = result.Id,
			Type = result.Type,
			Title = result.Title,
			Description = result.Description,
			Category = result.Category,
		}
		function entry:Run()
			Commands:Execute(MidasUI, record)
			return self
		end
		table.insert(publicResults, entry)
	end
	return publicResults
end

function MidasUI:SearchCommands(query)
	return self:Search(query, { CommandsOnly = true })
end

function MidasUI:NavigateTo(object)
	if typeof(object) ~= "table" or not object._midasSearchId then
		self:_Warn("Search", "NavigateTo expected a live indexed UI controller")
		return false
	end
	local record = self._searchItems and self._searchItems[object._midasSearchId]
	return Commands:Navigate(self, record)
end

function MidasUI:OpenCommandPalette(options)
	return CommandPalette:Open(Context, options)
end

function MidasUI:CloseCommandPalette()
	return CommandPalette:Close(Context)
end

function MidasUI:_CloseExpandedDropdown()
	if self._expandedDropdown and self._expandedDropdown.SetExpanded then
		self._expandedDropdown:SetExpanded(false, true)
	end
end

function MidasUI:ToggleCommandPalette(options)
	if self._activePalette then
		return CommandPalette:Close(Context)
	end
	return CommandPalette:Open(Context, options)
end

function MidasUI:GetFlag(flag)
	return Flags:Get(self, flag)
end

function MidasUI:SetFlag(flag, value, fireCallback, instant)
	if typeof(flag) ~= "string" or flag == "" then
		self:_Warn("Flag", "SetFlag ignored: flag must be a non-empty string")
		return false
	end

	Flags:Set(self, flag, value, fireCallback, instant)
	return true
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
		self:_Warn("Dependency", "Ignored invalid DependsOn configuration")
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

function MidasUI:_UnregisterDependencies(element)
	for index = #self._dependencies, 1, -1 do
		if self._dependencies[index].Element == element then
			table.remove(self._dependencies, index)
		end
	end
end

function MidasUI:_ApplyDependency(record)
	local element = record.Element
	if not element or element.Destroyed or not element.Instance then
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
			self:_SetElementVisible(element, passes)
		end
	else
		self:_SetElementVisible(element, passes)
	end
end

function MidasUI:_SetElementVisible(element, visible)
	local instance = element.Instance
	if not instance then
		return
	end

	if visible then
		instance.Visible = true
		if element._midasOriginalSize then
			instance.Size = element._midasOriginalSize
		end
	else
		if element.SetExpanded then
			element:SetExpanded(false, true)
		end

		if instance.Visible then
			element._midasOriginalSize = instance.Size
		end
		instance.Visible = false
		if element._midasOriginalSize then
			instance.Size = UDim2.new(element._midasOriginalSize.X.Scale, element._midasOriginalSize.X.Offset, 0, 0)
		end
	end

	if not visible and self._tooltipFrame then
		Tooltip:Hide(Context)
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
	local ok, err = Config:Load(self, profile)
	self:_RefreshDependencies()
	return ok, err
end

function MidasUI:DeleteConfig(profile)
	return Config:Delete(self, profile)
end

function MidasUI:ListConfigs()
	return Config:List(self)
end

function MidasUI:Notify(options)
	if options ~= nil and typeof(options) ~= "table" then
		self:_Warn("Notification", "Notify expected an options table")
		options = {}
	end
	return Notify:Show(Context, options or {})
end

function MidasUI:Dialog(options)
	if options ~= nil and typeof(options) ~= "table" then
		self:_Warn("Dialog", "Dialog expected an options table")
		options = {}
	end
	self:CloseCommandPalette()
	self:_CloseExpandedDropdown()
	return Dialog:Show(Context, options or {})
end

function MidasUI:Info(options)
	local values = typeof(options) == "table" and table.clone(options) or {}
	values.Type = "Info"
	return self:Dialog(values)
end

function MidasUI:Confirm(options)
	local values = typeof(options) == "table" and table.clone(options) or {}
	values.Type = "Confirm"
	return self:Dialog(values)
end

function MidasUI:Prompt(options)
	local values = typeof(options) == "table" and table.clone(options) or {}
	values.Type = "Input"
	return self:Dialog(values)
end

function MidasUI:_CleanupOverlays()
	self:_CloseExpandedDropdown()
	if self._notifyGui then
		self._notifyGui:Destroy()
		self._notifyGui = nil
		self._notifyHolder = nil
		self._notifications = nil
	end

	if self._tooltipGui then
		Tooltip:Hide(Context)
		self._tooltipGui:Destroy()
		self._tooltipGui = nil
		self._tooltipFrame = nil
		self._tooltipLabel = nil
	end

	if self._tooltipConnections then
		Utility:DisconnectAll(self._tooltipConnections)
	end

	CommandPalette:Destroy(Context)
	Dialog:Close(Context)
	if self._dialogGui then
		self._dialogGui:Destroy()
		self._dialogGui = nil
	end
end

function MidasUI:_CleanupWindowRuntime()
	self:_CleanupOverlays()

	if self._listeningKeybind then
		self._listeningKeybind = nil
	end

	table.clear(self.Keybinds)

	if self._keybindConnections then
		Utility:DisconnectAll(self._keybindConnections)
	end

	self._keybindsReady = false
end

function MidasUI:Destroy()
	for _, window in ipairs(table.clone(self._windows)) do
		window:Destroy()
	end

	table.clear(self._windows)
	table.clear(self._flagObjects)
	table.clear(self._dependencies)
	table.clear(self.Keybinds)
	table.clear(self._commands or {})
	table.clear(self._searchItems or {})

	if self._listeningKeybind then
		self._listeningKeybind = nil
	end

	self:_CleanupWindowRuntime()

	self._keybindsReady = false
	return self
end

return MidasUI
