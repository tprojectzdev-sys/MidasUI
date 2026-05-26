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
local Shortcuts = require(core:WaitForChild("Shortcuts"))
local Dialog = require(core:WaitForChild("Dialog"))
local Templates = require(core:WaitForChild("Templates"))
local Commands = require(core:WaitForChild("Commands"))
local CommandPalette = require(core:WaitForChild("CommandPalette"))
local Icons = assetsFolder and require(assetsFolder:WaitForChild("Icons")) or nil

if Icons and Icons.Map then
	Utility.IconGlyphs = Icons.Map
end

local MidasUI = {
	Version = "1.9.0",
	Flags = {},
	Keybinds = {},
	Themes = Theme.Registry,
	Templates = Templates.Registry,
	ThemeName = "DarkGold",
	Theme = Theme:Normalize(Theme.Registry.DarkGold),
	_windows = {},
	_flagObjects = {},
	_dependencies = {},
	_themeCallbacks = {},
	_themeCallbackSequence = 0,
	_shortcuts = {},
	_shortcutSequence = 0,
	_recentCommands = {},
	_debug = false,
	_warnings = {},
	_warningCategories = {},
	_configFolder = "Midas",
	_configFile = "config.json",
	_windowSettings = {},
	_destroyed = false,
	_paletteShortcutValue = "Ctrl+K",
	_paletteShortcutDisabled = false,
	_menuToggleValue = nil,
	CommandPaletteShortcut = "Ctrl+K",
	MenuToggleShortcut = "Disabled",
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
	Shortcuts = Shortcuts,
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

function MidasUI:GetRuntimeReport()
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

	local expandedDropdown = self._expandedDropdown
	local hasExpandedDropdown = expandedDropdown ~= nil
		and not expandedDropdown.Destroyed
		and expandedDropdown.Expanded == true
	local publicAPIs = {}
	for _, method in ipairs({
		"RegisterCommand",
		"UnregisterCommand",
		"RunCommand",
		"Search",
		"SearchCommands",
		"NavigateTo",
		"OpenCommandPalette",
		"CloseCommandPalette",
		"ToggleCommandPalette",
		"SetCommandPaletteShortcut",
		"ClearCommandPaletteShortcut",
		"SetMenuToggleKey",
		"ClearMenuToggleKey",
		"RegisterIcon",
		"RegisterIcons",
		"GetRuntimeReport",
		"RunSelfTest",
		"PrintRuntimeReport",
		"DestroyAllWindows",
		"IsLoaded",
		"Unload",
		"OnThemeChanged",
	}) do
		publicAPIs[method] = typeof(self[method]) == "function"
	end
	local shortcuts = Shortcuts:GetState(self)

	return {
		Version = self.Version,
		Theme = self.ThemeName,
		WindowCount = #self._windows,
		FlagCount = flagCount,
		KeybindCount = keybindCount,
		CommandCount = commandCount,
		SearchItemCount = searchItemCount,
		ShortcutCount = #shortcuts,
		Shortcuts = shortcuts,
		ShortcutListenerReady = self._shortcutsReady == true,
		RecentCommandCount = #(self._recentCommands or {}),
		CommandPaletteShortcut = self.CommandPaletteShortcut,
		MenuToggleShortcut = self.MenuToggleShortcut,
		DependencyCount = #self._dependencies,
		NotificationCount = self._notifications and #self._notifications or 0,
		HasActiveDialog = self._activeDialog ~= nil,
		HasOpenCommandPalette = self._activePalette ~= nil,
		HasExpandedDropdown = hasExpandedDropdown,
		ActiveOverlay = self._activeDialog and "Dialog"
			or (self._activePalette and "CommandPalette")
			or (hasExpandedDropdown and "Dropdown")
			or nil,
		PublicAPIs = publicAPIs,
		Destroyed = self._destroyed == true,
		Warnings = table.clone(self._warnings),
		WarningCategories = table.clone(self._warningCategories),
	}
end

function MidasUI:GetDebugState()
	if not self._debug then
		return nil
	end
	return self:GetRuntimeReport()
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

function MidasUI:RegisterIcon(name, definition)
	local ok, result = Utility:RegisterIcon(name, definition)
	if not ok then
		self:_Warn("Icon", result)
	end
	return ok, result
end

function MidasUI:RegisterIcons(definitions)
	if typeof(definitions) ~= "table" then
		self:_Warn("Icon", "RegisterIcons expected a table")
		return false, "Icon definitions must be a table"
	end
	for name, definition in pairs(definitions) do
		local ok, err = self:RegisterIcon(name, definition)
		if not ok then
			return false, err
		end
	end
	return true
end

function MidasUI:GetTemplate(nameOrTemplate)
	return Templates:Get(nameOrTemplate)
end

function MidasUI:OnThemeChanged(callback)
	if typeof(callback) ~= "function" then
		self:_Warn("Theme", "OnThemeChanged expected a callback function")
		return nil
	end

	self._themeCallbackSequence = self._themeCallbackSequence + 1
	local id = self._themeCallbackSequence
	self._themeCallbacks[id] = callback

	local controller = {}
	function controller:Disconnect()
		if MidasUI._themeCallbacks[id] == callback then
			MidasUI._themeCallbacks[id] = nil
		end
		return self
	end
	return controller
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
	for _, callback in pairs(self._themeCallbacks) do
		self:_InvokeCallback("Theme", callback, themeName, theme, valid)
	end
	return valid, themeName
end

function MidasUI:_EnsureShortcuts()
	Shortcuts:Init(Context)
	if not self._paletteShortcutDisabled and not self._shortcuts.command_palette then
		Shortcuts:Set(self, "command_palette", self._paletteShortcutValue, function()
			self:ToggleCommandPalette()
		end, { Priority = 100 })
	end
	if self._menuToggleValue and not self._shortcuts.menu_toggle then
		Shortcuts:Set(self, "menu_toggle", self._menuToggleValue, function()
			local window = self._menuToggleOwner or self._activeWindow
			if window and not window.Closed then
				window:ToggleVisibility()
			end
		end, { Priority = 80, Owner = self._menuToggleOwner })
	end
end

function MidasUI:_RefreshPaletteShortcutHint()
	local palette = self._activePalette
	if not palette then
		return
	end
	if palette.ShortcutHint then
		palette.ShortcutHint.Text = self.CommandPaletteShortcut
	end
	if palette.Footer then
		local hint = self.CommandPaletteShortcut == "Disabled"
			and "Shortcut disabled"
			or (self.CommandPaletteShortcut .. " toggle")
		palette.Footer.Text = "Up/Down navigate   Enter run   Esc close   " .. hint
	end
end

function MidasUI:SetCommandPaletteShortcut(value)
	if value == nil or value == false then
		self._paletteShortcutDisabled = true
		self._paletteShortcutValue = nil
		self.CommandPaletteShortcut = "Disabled"
		Shortcuts:Set(self, "command_palette", false)
		self:_RefreshPaletteShortcutHint()
		return true, self.CommandPaletteShortcut
	end

	local descriptor, err = Shortcuts:Normalize(value)
	if not descriptor then
		self:_Warn("Shortcut", "Command palette shortcut was not changed: " .. tostring(err))
		return false, err
	end
	if self.MenuToggleShortcut ~= "Disabled"
		and self.MenuToggleShortcut == Shortcuts:Format(descriptor) then
		local message = "Command palette shortcut conflicts with the menu toggle shortcut"
		self:_Warn("Shortcut", message)
		return false, message
	end
	self._paletteShortcutDisabled = false
	self._paletteShortcutValue = descriptor
	local ok, display = Shortcuts:Set(self, "command_palette", descriptor, function()
		self:ToggleCommandPalette()
	end, { Priority = 100 })
	if ok then
		self.CommandPaletteShortcut = display
		self.CommandPaletteKeyCode = descriptor.KeyCode
		self:_RefreshPaletteShortcutHint()
	end
	return ok, display
end

function MidasUI:ClearCommandPaletteShortcut()
	return self:SetCommandPaletteShortcut(false)
end

function MidasUI:_SetMenuToggleKey(value, owner)
	if value == nil or value == false then
		self._menuToggleValue = nil
		self._menuToggleOwner = nil
		self.MenuToggleShortcut = "Disabled"
		Shortcuts:Set(self, "menu_toggle", false)
		return true, self.MenuToggleShortcut
	end

	local descriptor, err = Shortcuts:Normalize(value)
	if not descriptor then
		self:_Warn("Shortcut", "Menu toggle shortcut was not changed: " .. tostring(err))
		return false, err
	end
	if not self._paletteShortcutDisabled
		and self.CommandPaletteShortcut == Shortcuts:Format(descriptor) then
		local message = "Menu toggle shortcut conflicts with the command palette shortcut"
		self:_Warn("Shortcut", message)
		return false, message
	end
	self._menuToggleValue = descriptor
	self._menuToggleOwner = owner
	local ok, display = Shortcuts:Set(self, "menu_toggle", descriptor, function()
		local window = owner or self._activeWindow
		if window and not window.Closed then
			window:ToggleVisibility()
		end
	end, { Priority = 80, Owner = owner })
	if ok then
		self.MenuToggleShortcut = display
	end
	return ok, display
end

function MidasUI:SetMenuToggleKey(value)
	return self:_SetMenuToggleKey(value, nil)
end

function MidasUI:ClearMenuToggleKey()
	return self:_SetMenuToggleKey(false)
end

function MidasUI:CreateWindow(options)
	if options ~= nil and typeof(options) ~= "table" then
		self:_Warn("API", "CreateWindow expected an options table")
		options = {}
	end

	options = options or {}
	self._destroyed = false
	self:_EnsureShortcuts()
	self:SetTheme(options.Theme or self.ThemeName)
	CommandPalette:Init(Context)
	local window = Context.Window.new(Context, options)
	Commands:IndexObject(self, window, "Window")
	return window
end

function MidasUI:_IsCommandPaletteHotkey(input)
	local shortcut = self._shortcuts and self._shortcuts.command_palette
	return shortcut ~= nil and Shortcuts:Matches(shortcut.Shortcut, input)
end

function MidasUI:RegisterCommand(options)
	return Commands:Register(self, options)
end

function MidasUI:UnregisterCommand(idOrController)
	return Commands:Unregister(self, idOrController)
end

function MidasUI:RunCommand(idOrController)
	local ok = Commands:Execute(self, idOrController)
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
	if self._destroyed then
		self:_Warn("Lifecycle", "OpenCommandPalette ignored: library was destroyed")
		return false
	end
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
	if self._destroyed then
		self:_Warn("Lifecycle", "Notify ignored: library was destroyed")
		return nil
	end
	if options ~= nil and typeof(options) ~= "table" then
		self:_Warn("Notification", "Notify expected an options table")
		options = {}
	end
	return Notify:Show(Context, options or {})
end

function MidasUI:Dialog(options)
	if self._destroyed then
		self:_Warn("Lifecycle", "Dialog ignored: library was destroyed")
		return nil
	end
	if options ~= nil and typeof(options) ~= "table" then
		self:_Warn("Dialog", "Dialog expected an options table")
		options = {}
	end
	self:CloseCommandPalette()
	self:_CloseExpandedDropdown()
	Tooltip:Hide(Context)
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

function MidasUI:RunSelfTest()
	local report = self:GetRuntimeReport()
	local checks = {}
	local function check(name, passed)
		checks[name] = passed == true
	end

	for name, available in pairs(report.PublicAPIs) do
		check("API." .. name, available)
	end
	for _, name in ipairs({ "CreateProgressBar", "CreateStatCard", "CreateStatusCard", "CreateLogPanel", "CreateCallout" }) do
		check("Section." .. name, typeof(Context.Section[name]) == "function")
	end
	check("Commands.Module", typeof(Context.Commands.Search) == "function" and typeof(Context.Commands.Execute) == "function")
	check("Shortcuts.Module", typeof(Context.Shortcuts.Set) == "function" and typeof(Context.Shortcuts.Normalize) == "function")
	check("Icons.Custom", typeof(self.RegisterIcon) == "function" and typeof(self.RegisterIcons) == "function")
	check("Version.1.9", self.Version == "1.9.0")

	local passed = true
	for _, value in pairs(checks) do
		if not value then
			passed = false
			break
		end
	end
	report.Checks = checks
	report.Passed = passed
	return report
end

function MidasUI:PrintRuntimeReport()
	local report = self:RunSelfTest()
	if self._debug then
		print("[MidasUI] Version", report.Version, "Passed", report.Passed)
		print("[MidasUI] Counts", report.WindowCount, report.CommandCount, report.SearchItemCount, report.KeybindCount, report.ShortcutCount)
		print("[MidasUI] Shortcuts", report.CommandPaletteShortcut, report.MenuToggleShortcut, report.ActiveOverlay)
	end
	return report
end

function MidasUI:_CleanupOverlays()
	self:_CloseExpandedDropdown()
	if self._dropdownGui then
		self._dropdownGui:Destroy()
		self._dropdownGui = nil
	end
	Notify:Destroy(Context)

	if self._tooltipGui then
		Tooltip:Hide(Context)
		self._tooltipGui:Destroy()
		self._tooltipGui = nil
		self._tooltipFrame = nil
		self._tooltipLabel = nil
		self._tooltipTweens = nil
	end

	if self._tooltipConnections then
		Utility:DisconnectAll(self._tooltipConnections)
	end

	CommandPalette:Destroy(Context)
	Dialog:Destroy(Context)
end

function MidasUI:_CleanupWindowRuntime()
	self:_CleanupOverlays()

	if self._listeningKeybind then
		self._listeningKeybind = nil
	end

	table.clear(self.Keybinds)

	Shortcuts:Destroy(Context)
	self._keybindsReady = false
end

function MidasUI:DestroyAllWindows()
	for _, window in ipairs(table.clone(self._windows)) do
		window:Destroy()
	end
	return self
end

function MidasUI:IsLoaded()
	return self._destroyed ~= true and #self._windows > 0
end

function MidasUI:Destroy()
	self._destroyed = true
	self:DestroyAllWindows()

	table.clear(self._windows)
	table.clear(self._flagObjects)
	table.clear(self._dependencies)
	table.clear(self.Keybinds)
	table.clear(self._commands or {})
	table.clear(self._searchItems or {})
	table.clear(self._themeCallbacks)
	table.clear(self._recentCommands)

	if self._listeningKeybind then
		self._listeningKeybind = nil
	end

	self:_CleanupWindowRuntime()

	self._keybindsReady = false
	return self
end

function MidasUI:Unload()
	return self:Destroy()
end

return MidasUI
