local runtime = type(getgenv) == "function" and getgenv() or _G
local previousShowcase = runtime.__MidasUIShowcaseRuntime
if previousShowcase and type(previousShowcase.Destroy) == "function" then
	pcall(function()
		previousShowcase:Destroy()
	end)
end

local distUrl = "https://raw.githubusercontent.com/tprojectzdev-sys/MidasUI/refs/heads/master/dist/MidasUI.lua"
local cacheBust = tostring(os.time()) .. "-" .. tostring(math.floor(os.clock() * 1000000))
local MidasUI = loadstring(game:HttpGet(distUrl .. "?midas_qa=" .. cacheBust))()
runtime.__MidasUIShowcaseRuntime = MidasUI

local function destroyShowcase()
	if runtime.__MidasUIShowcaseRuntime == MidasUI then
		runtime.__MidasUIShowcaseRuntime = nil
	end
	MidasUI:Unload()
end

print("MidasUI:", MidasUI)
print("Version:", MidasUI.Version)
for _, method in ipairs({
	"CreateWindow",
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
	print(method .. ":", typeof(MidasUI[method]) == "function")
end

MidasUI:SetDebug(true)
if typeof(MidasUI.OnThemeChanged) == "function" then
	MidasUI:OnThemeChanged(function(name, _, valid)
		print("Theme callback:", name, valid)
	end)
end

MidasUI:RegisterTheme("ObsidianGold", {
	Background = Color3.fromRGB(8, 8, 10),
	Topbar = Color3.fromRGB(18, 17, 16),
	Sidebar = Color3.fromRGB(13, 13, 15),
	Card = Color3.fromRGB(22, 21, 20),
	Accent = Color3.fromRGB(232, 192, 104),
	Text = Color3.fromRGB(250, 245, 234),
	MutedText = Color3.fromRGB(156, 149, 135),
	Stroke = Color3.fromRGB(80, 66, 38),
	Danger = Color3.fromRGB(230, 88, 88),
	Success = Color3.fromRGB(80, 190, 124),
})
MidasUI:RegisterTheme("PartialGold", {
	Accent = Color3.fromRGB(244, 205, 112),
})

MidasUI:RegisterIcons({
	gem = { Text = "G" },
	goldStar = {
		Image = "rbxassetid://3926305904",
		ImageRectOffset = Vector2.new(4, 4),
		ImageRectSize = Vector2.new(36, 36),
	},
})

local Window = MidasUI:CreateWindow({
	Title = "MidasUI V1.9 Shortcut Showcase",
	Subtitle = "Launcher, shortcut ownership, palette recents, accessibility, and runtime checks",
	Icon = "crown",
	Theme = "DarkGold",
	Size = UDim2.fromOffset(740, 550),
	Intro = true,
	ToggleKey = Enum.KeyCode.RightControl,
	Launcher = true,
	SaveConfig = true,
	ConfigFolder = "MidasShowcase",
})

local DashboardWindow
local PowerWindow

local function openDashboard()
	if DashboardWindow and not DashboardWindow.Closed then
		DashboardWindow:Show()
		return
	end

	DashboardWindow = MidasUI:CreateWindow({
		Title = "Workflow Dashboard",
		Subtitle = "FarmingDashboard template - generic UI status sample",
		Template = "FarmingDashboard",
		Theme = MidasUI.ThemeName,
		Intro = false,
	})
	local DashboardTab = DashboardWindow:CreateTab({ Name = "Status", Icon = "home" })
	local Summary = DashboardTab:CreateSection("Current Activity")
	local CurrentTask = Summary:CreateStatusCard({ Name = "Current Task", Value = "Idle", Icon = "info" })
	local RuntimeCard = Summary:CreateStatCard({ Name = "Runtime", Value = "00:00:00" })
	local Progress = Summary:CreateProgressBar({
		Name = "Cycle Progress",
		Flag = "dashboard_progress",
		Default = 18,
		Status = "Preparing",
	})
	local Notice = Summary:CreateCallout({
		Title = "Workflow Note",
		Content = "This dashboard displays status only; application logic remains external.",
		Type = "Info",
	})
	local ActivityLog
	Summary:CreateActionRow({
		Actions = {
			{
				Name = "Start",
				Style = "Success",
				Callback = function()
					CurrentTask:Set("Running")
					RuntimeCard:Set("00:00:12")
					Progress:SetStatus("Running"):Set(42)
					Notice:SetType("Success"):SetContent("Workflow running. Progress and status are controller-driven.")
					ActivityLog:AddLine("Workflow started", "Success")
				end,
			},
			{
				Name = "Pause",
				Style = "Primary",
				Callback = function()
					CurrentTask:Set("Paused")
					Progress:SetStatus("Paused")
					ActivityLog:AddLine("Workflow paused", "Warning")
				end,
			},
			{
				Name = "Stop",
				Style = "Danger",
				Callback = function()
					MidasUI:Confirm({
						Title = "Stop Workflow",
						Content = "Stop this sample workflow and reset progress?",
						Danger = true,
						ConfirmText = "Stop",
						CancelText = "Keep Running",
						OnConfirm = function()
							CurrentTask:Set("Idle")
							Progress:SetStatus("Stopped"):Set(0)
							ActivityLog:AddLine("Workflow stopped", "Error")
						end,
					})
				end,
			},
		},
	})
	local Activity = DashboardTab:CreateSection("Recent Events")
	ActivityLog = Activity:CreateLogPanel({
		MaxLines = 8,
		Lines = {
			{ Text = "Dashboard initialized", Type = "Info" },
			{ Text = "Awaiting user action", Type = "Warning" },
		},
	})
	Activity:CreateButton({
		Name = "Controller Update Test",
		Callback = function()
			MidasUI:SetFlag("dashboard_progress", 76)
			RuntimeCard:Set("00:13:42")
			Notice:SetType("Warning"):SetContent("Check recent events before completing the workflow.")
			ActivityLog:Log("SetFlag moved progress to 76%", "Info")
		end,
	})

	DashboardWindow:RegisterCommand({
		Id = "dashboard_start",
		Title = "Dashboard: Start Demo Workflow",
		Description = "Start the generic dashboard status sample.",
		Category = "Dashboard",
		Keywords = { "workflow", "progress", "run" },
		Callback = function()
			CurrentTask:Set("Running")
			Progress:SetStatus("Running"):Set(42)
			ActivityLog:AddLine("Started from command palette", "Success")
		end,
	})
	DashboardWindow:RegisterCommand({
		Id = "dashboard_pause",
		Title = "Dashboard: Pause Demo Workflow",
		Description = "Pause the generic dashboard status sample.",
		Category = "Dashboard",
		Callback = function()
			CurrentTask:Set("Paused")
			Progress:SetStatus("Paused")
			ActivityLog:AddLine("Paused from command palette", "Warning")
		end,
	})
	DashboardWindow:RegisterCommand({
		Id = "dashboard_clear_log",
		Title = "Dashboard: Clear Recent Events",
		Description = "Clear the demo log panel.",
		Category = "Dashboard",
		Keywords = { "log", "reset" },
		Callback = function()
			ActivityLog:Clear():AddLine("Log cleared from command palette", "Info")
		end,
	})
	DashboardWindow:RegisterCommand({
		Id = "dashboard_status",
		Title = "Dashboard: Jump To Status",
		Description = "Reveal the Current Activity section.",
		Category = "Navigate",
		Callback = function()
			MidasUI:NavigateTo(Summary)
		end,
	})
	DashboardWindow:RegisterCommand({
		Id = "dashboard_reset",
		Title = "Dashboard: Reset Progress",
		Description = "Reset the display-only progress sample.",
		Category = "Dashboard",
		Callback = function()
			CurrentTask:Set("Idle")
			Progress:SetStatus("Ready"):Set(0)
			ActivityLog:AddLine("Progress reset", "Info")
		end,
	})
end

local function openPowerPanel()
	if PowerWindow and not PowerWindow.Closed then
		PowerWindow:Show()
		return
	end

	PowerWindow = MidasUI:CreateWindow({
		Title = "Advanced Configuration",
		Subtitle = "PowerPanel template - compact generic settings",
		Template = "PowerPanel",
		Theme = MidasUI.ThemeName,
		Intro = false,
	})
	local ControlsTab = PowerWindow:CreateTab({ Name = "Controls", Icon = "settings" })
	local Behavior = ControlsTab:CreateSection({ Name = "Feature Controls", Compact = true })
	local Processing = Behavior:CreateToggle({ Name = "Enable Processing", Flag = "power_enabled", Default = true })
	Behavior:CreateSlider({ Name = "Update Rate", Flag = "power_rate", Min = 0.1, Max = 3, Increment = 0.05, Default = 1 })
	local ExecutionMode = Behavior:CreateDropdown({
		Name = "Execution Mode",
		Flag = "power_mode",
		Options = { "Balanced", "Responsive", "Efficient", "Low Latency", "Scheduled", "Validated", "Batch", "Interactive" },
		Default = "Balanced",
		Searchable = true,
	})
	Behavior:CreateKeybind({ Name = "Panel Toggle", Flag = "power_bind", Default = Enum.KeyCode.P, Mode = "Toggle" })
	local Advanced = ControlsTab:CreateSection({ Name = "Grouped Settings", Compact = true })
	Advanced:CreateCallout({ Title = "Dense Layout", Content = "Compact spacing keeps larger settings sets readable.", Type = "Info" })
	for index = 1, 7 do
		Advanced:CreateToggle({ Name = "Optional Setting " .. index, Flag = "power_optional_" .. index, Default = index % 2 == 0 })
	end
	Advanced:CreateProgressBar({ Name = "Configuration Coverage", Value = 68, Status = "7 groups" })
	PowerWindow:RegisterCommand({
		Id = "power_advanced",
		Title = "Power Panel: Jump To Grouped Settings",
		Description = "Navigate to the compact advanced group.",
		Category = "Navigate",
		Callback = function()
			MidasUI:NavigateTo(Advanced)
		end,
	})
	PowerWindow:RegisterCommand({
		Id = "power_processing",
		Title = "Power Panel: Toggle Processing",
		Description = "Explicitly toggle the sample advanced flag.",
		Category = "Power Panel",
		Callback = function()
			Processing:Set(not Processing:GetValue())
		end,
	})
	PowerWindow:RegisterCommand({
		Id = "power_mode",
		Title = "Power Panel: Search Execution Mode",
		Description = "Navigate to and expand the searchable option list.",
		Category = "Power Panel",
		Keywords = { "dropdown", "filter", "compact" },
		Callback = function()
			MidasUI:NavigateTo(ExecutionMode)
		end,
	})
end

local Main = Window:CreateTab({ Name = "Main", Icon = "home" })
local Controllers = Main:CreateSection("Controller API")

local Status = Controllers:CreateParagraph({
	Text = "Controller status: ready.",
	Tooltip = "This paragraph is stored and updated through its controller.",
})
Controllers:CreateDivider()

local MasterToggle = Controllers:CreateToggle({
	Name = "Master Toggle",
	Flag = "master_dependency",
	Default = false,
	Tooltip = "Drives dependency examples and SetFlag tests.",
})

local ControlledSlider = Controllers:CreateSlider({
	Name = "Controlled Slider",
	Flag = "controlled_slider",
	Min = 0,
	Max = 100,
	Default = 45,
	Increment = 1,
	Tooltip = "Normal QA slider: verifies one-unit drag, SetFlag, and controller updates.",
})

local PrecisionSlider = Controllers:CreateSlider({
	Name = "Precision Slider (0.01)",
	Flag = "precision_slider",
	Min = -1,
	Max = 1,
	Default = 0.25,
	Increment = 0.01,
	Tooltip = "Drag slowly and verify clean two-decimal display and smooth motion.",
})

local DynamicDropdown = Controllers:CreateDropdown({
	Name = "Dynamic Dropdown",
	Flag = "dynamic_dropdown",
	Options = { "Alpha", "Bravo", "Charlie" },
	Default = "Alpha",
	MaxVisibleOptions = 5,
})

Controllers:CreateButton({
	Name = "Update Controllers",
	Tooltip = "Updates text, slider value, dropdown options, and toggle state.",
	Callback = function()
		Status:SetText("Controller status: updated through public methods.")
		ControlledSlider:Set(75)
		PrecisionSlider:Set(0.37)
		DynamicDropdown:SetOptions({ "One", "Two", "Three", "Four", "Five", "Six" }, "Three")
		MasterToggle:Set(true)
	end,
})

Controllers:CreateButton({
	Name = "Disable Then Enable Controls",
	Callback = function()
		MasterToggle:Disable()
		ControlledSlider:Disable()
		PrecisionSlider:Disable()
		task.delay(1, function()
			MasterToggle:Enable():Refresh()
			ControlledSlider:Enable():Refresh()
			PrecisionSlider:Enable():Refresh()
		end)
	end,
})

Controllers:CreateButton({
	Name = "Hide Then Show Status",
	Callback = function()
		Status:Hide()
		task.delay(1, function()
			Status:Show()
		end)
	end,
})

local Temporary = Controllers:CreateButton({
	Name = "Temporary Destroy Target",
	Callback = function()
		print("Temporary button clicked")
	end,
})

Controllers:CreateButton({
	Name = "Destroy Temporary Button",
	Tooltip = "Destroyed controllers should stop responding safely.",
	Callback = function()
		Temporary:Destroy()
		Temporary:SetText("Should not error after destroy")
	end,
})

local Runtime = Main:CreateSection("Runtime Flags and Dependencies")

Runtime:CreateSlider({
	Name = "Visible When Master Is On",
	Flag = "dependent_visible_slider",
	Min = 0,
	Max = 100,
	Default = 50,
	Increment = 1,
	DependsOn = {
		Flag = "master_dependency",
		Value = true,
		Mode = "Visible",
	},
})

Runtime:CreateButton({
	Name = "Enabled When Master Is On",
	DependsOn = {
		Flag = "master_dependency",
		Value = true,
		Mode = "Enabled",
	},
	Callback = function()
		MidasUI:Notify({ Title = "Dependency", Content = "Enabled dependency clicked.", Duration = 2 })
	end,
})

local Presets = Main:CreateSection("V1.8 Workflow Templates Retained")
Presets:CreateParagraph({
	Text = "Existing workflow templates remain covered; use the current palette shortcut to find their scoped actions.",
})

local DiscoveryTab = Window:CreateTab({ Name = "Discovery", Icon = "search" })
local Discovery = DiscoveryTab:CreateSection("Command Palette and Search")

Discovery:CreateParagraph({
	Text = "Ctrl+K is the default palette shortcut. Use Up/Down and Enter; executed commands appear in Recent the next time the palette opens.",
})
Discovery:CreateButton({
	Name = "Open Command Palette",
	Callback = function()
		MidasUI:OpenCommandPalette()
	end,
})
Discovery:CreateButton({
	Name = "Open Palette Searching Slider",
	Callback = function()
		MidasUI:OpenCommandPalette({ Query = "precision slider" })
	end,
})
Discovery:CreateButton({
	Name = "Toggle Command Palette",
	Callback = function()
		MidasUI:ToggleCommandPalette()
	end,
})
Discovery:CreateButton({
	Name = "Set Palette Shortcut: Shift+K",
	Callback = function()
		local ok, shortcut = MidasUI:SetCommandPaletteShortcut("Shift+K")
		MidasUI:Notify({ Title = "Shortcut", Content = ok and ("Palette: " .. shortcut) or "Rejected shortcut", Duration = 2 })
	end,
})
Discovery:CreateButton({
	Name = "Restore Palette Shortcut: Ctrl+K",
	Callback = function()
		MidasUI:SetCommandPaletteShortcut("Ctrl+K")
	end,
})
Discovery:CreateButton({
	Name = "Disable / Restore Palette Shortcut",
	Callback = function()
		MidasUI:ClearCommandPaletteShortcut()
		MidasUI:Notify({ Title = "Shortcut", Content = "Palette shortcut disabled for two seconds.", Duration = 2 })
		task.delay(2, function()
			if MidasUI:IsLoaded() then
				MidasUI:SetCommandPaletteShortcut("Ctrl+K")
			end
		end)
	end,
})
Discovery:CreateButton({
	Name = "Invalid Shortcut Warning",
	Callback = function()
		MidasUI:SetCommandPaletteShortcut("Ctrl+NotAKey")
	end,
})
Discovery:CreateButton({
	Name = "Open Recent Commands",
	Tooltip = "Run palette commands first, then reopen with an empty query to see recent ordering.",
	Callback = function()
		MidasUI:OpenCommandPalette()
	end,
})
Discovery:CreateButton({
	Name = "Print Search: Dropdown",
	Callback = function()
		for _, result in ipairs(MidasUI:Search("dropdown")) do
			print("Search result:", result.Type, result.Title, result.Category)
		end
	end,
})
Discovery:CreateButton({
	Name = "Print Command Search: Theme",
	Callback = function()
		for _, result in ipairs(MidasUI:SearchCommands("theme")) do
			print("Command result:", result.Title)
		end
	end,
})
local RemovableCommand
Discovery:CreateButton({
	Name = "Register Temporary Command",
	Callback = function()
		if RemovableCommand then
			RemovableCommand:Unregister()
		end
		RemovableCommand = MidasUI:RegisterCommand({
			Title = "Temporary: Notify Once",
			Description = "Removable command registry test.",
			Category = "QA",
			Owner = Discovery,
			Callback = function()
				MidasUI:Notify({ Title = "Command", Content = "Temporary action executed.", Duration = 2 })
			end,
		})
	end,
})
Discovery:CreateButton({
	Name = "Unregister Temporary Command",
	Callback = function()
		if RemovableCommand then
			RemovableCommand:Unregister()
			RemovableCommand = nil
		end
	end,
})
Discovery:CreateButton({
	Name = "Invalid Command Warning",
	Callback = function()
		MidasUI:RegisterCommand({ Title = "Missing Callback" })
	end,
})
Presets:CreateButton({
	Name = "Open Farming Dashboard Demo",
	Tooltip = "Shows StatCard, ProgressBar, LogPanel, Callout, and ActionRow.",
	Callback = openDashboard,
})
Presets:CreateButton({
	Name = "Open Advanced Power Panel Demo",
	Tooltip = "Shows opt-in compact spacing for a dense generic configuration page.",
	Callback = openPowerPanel,
})

Runtime:CreateButton({
	Name = "SetFlag: Precision To -0.37",
	Callback = function()
		MidasUI:SetFlag("precision_slider", -0.37)
	end,
})

Runtime:CreateButton({
	Name = "Bad Values Stay Safe",
	Tooltip = "Debug mode reports rejected values without damaging controller state.",
	Callback = function()
		MidasUI:SetFlag("controlled_slider", "not a number")
		MidasUI:SetFlag("precision_slider", "not a number")
		MidasUI:SetFlag("dynamic_dropdown", "Missing option")
		MidasUI:SetFlag("master_dependency", "not a boolean")
	end,
})

Runtime:CreateButton({
	Name = "SetFlag: Master On",
	Callback = function()
		MidasUI:SetFlag("master_dependency", true)
	end,
})

Runtime:CreateButton({
	Name = "SetFlag: Slider To 20",
	Callback = function()
		MidasUI:SetFlag("controlled_slider", 20)
	end,
})

local DialogTab = Window:CreateTab({ Name = "Dialogs", Icon = "info" })
local Dialogs = DialogTab:CreateSection("Dialogs and Window Methods")

Dialogs:CreateParagraph({
	Text = "Dialogs should remain in front after minimize/restore and animated hide/show tests.",
})

Dialogs:CreateButton({
	Name = "Info Dialog",
	Callback = function()
		Window:Dialog({
			Type = "Info",
			Title = "Information",
			Content = "This V1.9 dialog must render above the restored window.",
			Icon = "info",
		})
	end,
})

Dialogs:CreateButton({
	Name = "Palette Then Dialog Layer Test",
	Tooltip = "The dialog takes modal priority and closes the command palette.",
	Callback = function()
		MidasUI:OpenCommandPalette({ Query = "dialog" })
		task.delay(0.5, function()
			MidasUI:Confirm({
				Title = "Modal Priority",
				Content = "The palette should be gone and this dialog should be above the window.",
				Icon = "dialog",
			})
		end)
	end,
})

Dialogs:CreateButton({
	Name = "Confirm Dialog",
	Callback = function()
		MidasUI:Confirm({
			Title = "Confirm Action",
			Content = "Run the confirm callback?",
			Icon = "check",
			OnConfirm = function()
				MidasUI:Notify({ Title = "Confirmed", Content = "Confirm callback ran.", Duration = 2 })
			end,
			OnCancel = function()
				print("Confirm canceled")
			end,
		})
	end,
})

Dialogs:CreateButton({
	Name = "Text Input Dialog",
	Callback = function()
		MidasUI:Prompt({
			Title = "Rename Window",
			Content = "Enter a new window title.",
			Icon = "gem",
			Placeholder = "Window title",
			Default = "MidasUI V1.9",
			OnConfirm = function(text)
				Window:SetTitle(text)
			end,
		})
	end,
})

Dialogs:CreateButton({
	Name = "Animated Hide / Show",
	Callback = function()
		Window:Hide()
		task.delay(1, function()
			Window:Show()
		end)
	end,
})

Dialogs:CreateButton({
	Name = "Minimize / Restore Regression",
	Callback = function()
		Window:Minimize()
		task.delay(0.8, function()
			Window:Restore()
		end)
	end,
})

Dialogs:CreateButton({
	Name = "Palette Minimize / Restore Cleanup",
	Callback = function()
		MidasUI:OpenCommandPalette({ Query = "navigate" })
		task.delay(0.4, function()
			Window:Minimize()
			task.delay(0.6, function()
				Window:Restore()
			end)
		end)
	end,
})

Dialogs:CreateButton({
	Name = "Palette Hide / Show Cleanup",
	Callback = function()
		MidasUI:OpenCommandPalette({ Query = "theme" })
		task.delay(0.4, function()
			Window:Hide()
			task.delay(0.6, function()
				Window:Show()
			end)
		end)
	end,
})

Dialogs:CreateButton({
	Name = "Restore Then Confirm Layer Test",
	Tooltip = "Minimizes, restores, then opens a confirm dialog above the full window.",
	Callback = function()
		Window:Minimize()
		task.delay(0.55, function()
			Window:Restore()
			task.delay(0.4, function()
				MidasUI:Confirm({
					Title = "Layering Check",
					Content = "This overlay should be fully above the restored window.",
				})
			end)
		end)
	end,
})

local Settings = Window:CreateTab({ Name = "Settings", Icon = "settings" })
local Themes = Settings:CreateSection("Theme Richness and Crown Branding")

Themes:CreateParagraph({
	Text = "Compare the stronger built-in surfaces and the compact crown crest in the topbar.",
	Tooltip = "The crown mark is code-native and follows the active accent colors.",
})

Themes:CreateDropdown({
	Name = "Runtime Theme",
	Icon = "palette",
	Flag = "theme",
	Options = { "DarkGold", "Midnight", "BlackWhite", "ObsidianGold", "PartialGold" },
	Default = "DarkGold",
	Callback = function(themeName)
		MidasUI:SetTheme(themeName)
	end,
})

local Icons = Settings:CreateSection("Icon Registry and Surface Depth")
Icons:CreateStatusCard({
	Name = "Custom Glyph",
	Value = "Registered",
	Icon = "gem",
})
Icons:CreateCallout({
	Name = "Asset Icon",
	Content = "A registered sprite definition follows the active accent token.",
	Icon = "goldStar",
	Type = "Success",
})
Icons:CreateDropdown({
	Name = "Icon Dropdown",
	Icon = "goldStar",
	Options = { "Premium", "Compact", "Minimal" },
	Default = "Premium",
})
Icons:CreateButton({
	Name = "Icon Notification and Dialog Test",
	Icon = "goldStar",
	Callback = function()
		MidasUI:Notify({
			Title = "Custom Icon",
			Content = "Notification styling and registered image rendering are active.",
			Icon = "goldStar",
			Duration = 3,
		})
		Window:Dialog({
			Type = "Info",
			Title = "Icon Dialog",
			Content = "This modal tests icon color binding and depth.",
			Icon = "gem",
		})
	end,
})

Themes:CreateButton({
	Name = "Invalid Theme Warning",
	Tooltip = "Only logs when debug mode is enabled.",
	Callback = function()
		MidasUI:SetTheme("MissingTheme")
	end,
})

Themes:CreateButton({
	Name = "Theme Switch With Palette Open",
	Callback = function()
		MidasUI:OpenCommandPalette({ Query = "theme" })
		MidasUI:SetTheme(MidasUI.ThemeName == "Midnight" and "DarkGold" or "Midnight")
	end,
})

local Profiles = Settings:CreateSection("Profiles and Diagnostics")

Profiles:CreateInput({
	Name = "Profile Name",
	Flag = "profile_name",
	Placeholder = "default",
	Default = "default",
})

Profiles:CreateButton({
	Name = "Save Profile",
	Callback = function()
		local profile = MidasUI:GetFlag("profile_name") or "default"
		local ok, err = MidasUI:SaveConfig(profile)
		MidasUI:Notify({ Title = "Config", Content = ok and ("Saved " .. profile) or tostring(err), Duration = 3 })
	end,
})

Profiles:CreateButton({
	Name = "Load Profile",
	Callback = function()
		local profile = MidasUI:GetFlag("profile_name") or "default"
		local ok, err = MidasUI:LoadConfig(profile)
		MidasUI:Notify({ Title = "Config", Content = ok and ("Loaded " .. profile) or tostring(err), Duration = 3 })
	end,
})

Profiles:CreateButton({
	Name = "Save / Load Default Profile",
	Callback = function()
		local saved, saveError = MidasUI:SaveConfig()
		local loaded, loadError = MidasUI:LoadConfig()
		local message = saved and loaded and "Default profile round-trip passed."
			or tostring(saveError or loadError)
		MidasUI:Notify({ Title = "Default Config", Content = message, Duration = 3 })
	end,
})

Profiles:CreateButton({
	Name = "Print Debug State",
	Callback = function()
		local state = MidasUI:GetDebugState()
		if state then
			print("MidasUI Debug:", state.Version, state.Theme, state.WindowCount, state.FlagCount, state.KeybindCount, state.ShortcutCount, state.CommandCount, state.SearchItemCount, state.CommandPaletteShortcut, state.MenuToggleShortcut, state.ActiveOverlay)
			local publicAPIs = state.PublicAPIs or {}
			local function hasAPI(name)
				if publicAPIs[name] ~= nil then
					return publicAPIs[name]
				end
				return typeof(MidasUI[name]) == "function"
			end
			print("V1.9 API:", hasAPI("RegisterCommand"), hasAPI("Search"), hasAPI("SetCommandPaletteShortcut"), hasAPI("SetMenuToggleKey"), hasAPI("GetRuntimeReport"), hasAPI("RunSelfTest"), hasAPI("DestroyAllWindows"), hasAPI("Unload"), hasAPI("OnThemeChanged"))
		end
	end,
})

Profiles:CreateButton({
	Name = "Run Runtime Self-Test",
	Callback = function()
		local report = MidasUI:PrintRuntimeReport()
		MidasUI:Notify({
			Title = "Self-Test",
			Content = report.Passed and "V1.9 API and component checks passed." or "Self-test reported missing surface.",
			Duration = 3,
		})
	end,
})

Profiles:CreateButton({
	Name = "Unload Showcase Runtime",
	Tooltip = "Removes all showcase windows, overlays, commands, and global listeners before a fresh run.",
	Callback = destroyShowcase,
})

Profiles:CreateButton({
	Name = "Animated Notification Exit",
	Callback = function()
		local notification = MidasUI:Notify({
			Title = "Controller",
			Content = "This notification closes after one second.",
			Icon = "notification",
			Duration = 10,
		})
		task.delay(1, function()
			notification:Close()
		end)
	end,
})

Profiles:CreateButton({
	Name = "Notification Stack Motion Test",
	Callback = function()
		for index = 1, 3 do
			task.delay((index - 1) * 0.12, function()
				MidasUI:Notify({
					Title = "Motion " .. index,
					Content = "Slide-in, settle, and clean exit.",
					Icon = index == 2 and "goldStar" or "bell",
					Duration = 2 + index,
				})
			end)
		end
	end,
})

local Stress = Main:CreateSection("Scrolling Stress")

local longOptions = {
	"Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot",
	"Golf", "Hotel", "India", "Juliet", "Kilo", "Lima",
	"Mike", "November", "Oscar", "Papa", "Quebec", "Romeo",
}

Stress:CreateDropdown({
	Name = "Long Dropdown",
	Icon = "dropdown",
	Flag = "long_dropdown",
	Options = longOptions,
	Default = "Alpha",
	MaxVisibleOptions = 6,
	Searchable = true,
})

for index = 1, 10 do
	Stress:CreateSlider({
		Name = index == 1 and "Coarse Step Slider (5)" or ("Stress Slider " .. index),
		Flag = "stress_slider_" .. index,
		Min = 0,
		Max = 100,
		Default = index * 5,
		Increment = index == 1 and 5 or 1,
	})
end

local Inputs = Window:CreateTab({ Name = "Input", Icon = "user" })
local Keybinds = Inputs:CreateSection("Keybinds")

Keybinds:CreateInput({
	Name = "Typing Test",
	Flag = "typing_test",
	Placeholder = "Type here; keybinds should not fire while focused.",
})

Keybinds:CreateParagraph({
	Text = "While this input is focused, palette/menu shortcuts and existing keybinds should not interrupt ordinary typing. RightControl toggles this showcase window outside text entry.",
})

Keybinds:CreateKeybind({
	Name = "Toggle Key",
	Flag = "toggle_key",
	Default = Enum.KeyCode.F,
	Mode = "Toggle",
	Callback = function(keyCode)
		print("Toggle key fired:", keyCode)
	end,
})

Window:RegisterCommand({
	Id = "navigate_main",
	Title = "Navigate: Main Tab",
	Description = "Jump to controllers and workflow launchers.",
	Category = "Navigate",
	Keywords = { "home", "controllers" },
	Callback = function()
		MidasUI:NavigateTo(Main)
	end,
})
Window:RegisterCommand({
	Id = "navigate_discovery",
	Title = "Navigate: Discovery Tab",
	Description = "Jump to V1.9 command, shortcut, and recent-command tests.",
	Category = "Navigate",
	Keywords = { "palette", "search" },
	Callback = function()
		MidasUI:NavigateTo(DiscoveryTab)
	end,
})
Window:RegisterCommand({
	Id = "navigate_dialogs",
	Title = "Navigate: Dialog Tests",
	Description = "Jump to overlay layering regression tests.",
	Category = "Navigate",
	Callback = function()
		MidasUI:NavigateTo(Dialogs)
	end,
})
Window:RegisterCommand({
	Id = "theme_midnight",
	Title = "Theme: Apply Midnight",
	Description = "Switch the runtime theme through a command.",
	Category = "Theme",
	Callback = function()
		MidasUI:SetTheme("Midnight")
	end,
})
Window:RegisterCommand({
	Id = "theme_gold",
	Title = "Theme: Apply DarkGold",
	Description = "Restore the gold runtime theme through a command.",
	Category = "Theme",
	Callback = function()
		MidasUI:SetTheme("DarkGold")
	end,
})
Window:RegisterCommand({
	Id = "palette_keep_open",
	Title = "Palette: Keep Open Notification",
	Description = "Show a notice while leaving results available.",
	Category = "QA",
	CloseOnRun = false,
	Callback = function()
		MidasUI:Notify({ Title = "Palette", Content = "This command leaves the palette open.", Duration = 2 })
	end,
})
Window:RegisterCommand({
	Id = "profile_save",
	Title = "Profile: Save Current",
	Description = "Save the named demonstration profile.",
	Category = "Profiles",
	Callback = function()
		local profile = MidasUI:GetFlag("profile_name") or "default"
		MidasUI:SaveConfig(profile)
	end,
})
Window:RegisterCommand({
	Id = "profile_load",
	Title = "Profile: Load Current",
	Description = "Load the named demonstration profile.",
	Category = "Profiles",
	Callback = function()
		local profile = MidasUI:GetFlag("profile_name") or "default"
		MidasUI:LoadConfig(profile)
	end,
})
Window:RegisterCommand({
	Id = "open_dashboard",
	Title = "Open: Farming Dashboard Demo",
	Description = "Open the generic dashboard workflow window.",
	Category = "Templates",
	Keywords = { "status", "progress", "log" },
	Callback = openDashboard,
})
Window:RegisterCommand({
	Id = "open_power_panel",
	Title = "Open: Advanced Power Panel Demo",
	Description = "Open the compact settings window.",
	Category = "Templates",
	Keywords = { "dense", "advanced", "dropdown" },
	Callback = openPowerPanel,
})
Window:RegisterCommand({
	Id = "runtime_destroy",
	Title = "Runtime: Unload Showcase",
	Description = "Release all V1.9 QA windows, commands, overlays, shortcuts, and listeners.",
	Category = "QA",
	Keywords = { "cleanup", "reload", "duplicate keybind" },
	Callback = destroyShowcase,
})

Keybinds:CreateKeybind({
	Name = "Hold Key",
	Flag = "hold_key",
	Default = Enum.KeyCode.LeftShift,
	Mode = "Hold",
	Callback = function(isHolding, keyCode)
		print("Hold key:", isHolding, keyCode)
	end,
})

task.delay(0.75, function()
	if runtime.__MidasUIShowcaseRuntime ~= MidasUI then
		return
	end
	MidasUI:Notify({
		Title = "MidasUI V1.9",
		Content = "Press Ctrl+K for commands or RightControl to hide/show; the crown launcher restores hidden UI.",
		Duration = 4,
	})
end)
