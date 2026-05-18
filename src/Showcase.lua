local MidasUI = loadstring(game:HttpGet("URL_HERE"))()

local Window = MidasUI:CreateWindow({
	Title = "MidasUI",
	Subtitle = "V1.2 Showcase",
	Icon = "crown",
	Theme = "DarkGold",
	Size = UDim2.fromOffset(680, 500),
	SaveConfig = true,
	ConfigFolder = "MidasShowcase",
})

local MainTab = Window:CreateTab({
	Name = "Main",
	Icon = "home",
})

local Controls = MainTab:CreateSection("Controls")

Controls:CreateParagraph({
	Text = "This showcase exercises the V1.2 foundation: flags, keybinds, tooltips, profiles, dependencies, and themes.",
	Tooltip = "Paragraphs can have simple hover tooltips too.",
})

Controls:CreateButton({
	Name = "Show Notification",
	Tooltip = "Shows a simple tweened notification.",
	Callback = function()
		MidasUI:Notify({
			Title = "MidasUI",
			Content = "Notifications are available from anywhere through MidasUI:Notify().",
			Duration = 4,
		})
	end,
})

Controls:CreateDivider({
	Tooltip = "Dividers can participate in dependencies and tooltips when useful.",
})

Controls:CreateToggle({
	Name = "Master Toggle",
	Flag = "master_toggle",
	Default = false,
	Tooltip = "Controls the dependent slider and button below.",
	Callback = function(value)
		print("Master toggle:", value)
	end,
})

Controls:CreateSlider({
	Name = "Dependent Slider",
	Flag = "dependent_slider",
	Min = 0,
	Max = 100,
	Default = 50,
	Increment = 5,
	Tooltip = "Visible only when Master Toggle is enabled.",
	DependsOn = {
		Flag = "master_toggle",
		Value = true,
		Mode = "Visible",
	},
	Callback = function(value)
		print("Dependent slider:", value)
	end,
})

Controls:CreateButton({
	Name = "Enabled By Master",
	Tooltip = "Disabled until Master Toggle is enabled.",
	DependsOn = {
		Flag = "master_toggle",
		Value = true,
		Mode = "Enabled",
	},
	Callback = function()
		print("Master-dependent button clicked")
	end,
})

local Inputs = MainTab:CreateSection("Inputs")

Inputs:CreateDropdown({
	Name = "Mode",
	Flag = "mode",
	Options = { "Safe", "Normal", "Aggressive" },
	Default = "Normal",
	Tooltip = "Dropdown values are saved to the active profile.",
	Callback = function(value)
		print("Mode:", value)
	end,
})

Inputs:CreateInput({
	Name = "Username",
	Flag = "username",
	Placeholder = "Enter name...",
	Default = "",
	Tooltip = "Keybinds will not fire while this TextBox is focused.",
	Callback = function(value)
		print("Username:", value)
	end,
})

Inputs:CreateKeybind({
	Name = "Toggle UI",
	Flag = "toggle_ui_key",
	Default = Enum.KeyCode.RightControl,
	Mode = "Toggle",
	Tooltip = "Click the bind box, then press a key. Escape cancels; Backspace clears.",
	Callback = function(keyCode)
		print("Toggle key pressed:", keyCode)
		MidasUI:Notify({
			Title = "Keybind",
			Content = "Pressed " .. tostring(keyCode),
			Duration = 2,
		})
	end,
})

Inputs:CreateKeybind({
	Name = "Hold Action",
	Flag = "hold_action_key",
	Default = Enum.KeyCode.LeftShift,
	Mode = "Hold",
	Tooltip = "Hold mode sends true on press and false on release.",
	Callback = function(isHeld)
		print("Hold action:", isHeld)
	end,
})

local SettingsTab = Window:CreateTab({
	Name = "Settings",
	Icon = "settings",
})

local Themes = SettingsTab:CreateSection("Themes")

Themes:CreateDropdown({
	Name = "Theme",
	Flag = "theme_name",
	Options = { "DarkGold", "Midnight", "BlackWhite" },
	Default = "DarkGold",
	Tooltip = "Themes update the window and controls without rebuilding the UI.",
	Callback = function(themeName)
		MidasUI:SetTheme(themeName)
	end,
})

Themes:CreateButton({
	Name = "Set Midnight",
	Tooltip = "Uses MidasUI:SetTheme directly.",
	Callback = function()
		MidasUI:SetTheme("Midnight")
		MidasUI:SetFlag("theme_name", "Midnight", false)
	end,
})

Themes:CreateButton({
	Name = "Set DarkGold",
	Callback = function()
		MidasUI:SetTheme("DarkGold")
		MidasUI:SetFlag("theme_name", "DarkGold", false)
	end,
})

local Profiles = SettingsTab:CreateSection("Config Profiles")

Profiles:CreateInput({
	Name = "Profile Name",
	Flag = "profile_name",
	Placeholder = "default",
	Default = "default",
	Tooltip = "Profile names are sanitized before becoming JSON file names.",
})

Profiles:CreateButton({
	Name = "Save Profile",
	Tooltip = "Calls MidasUI:SaveConfig(profile).",
	Callback = function()
		local profile = MidasUI:GetFlag("profile_name") or "default"
		local ok, err = MidasUI:SaveConfig(profile)
		MidasUI:Notify({
			Title = "Config",
			Content = ok and ("Saved profile: " .. profile) or ("Save failed: " .. tostring(err)),
			Duration = 4,
		})
	end,
})

Profiles:CreateButton({
	Name = "Load Profile",
	Tooltip = "Calls MidasUI:LoadConfig(profile).",
	Callback = function()
		local profile = MidasUI:GetFlag("profile_name") or "default"
		local ok, err = MidasUI:LoadConfig(profile)
		MidasUI:Notify({
			Title = "Config",
			Content = ok and ("Loaded profile: " .. profile) or ("Load failed: " .. tostring(err)),
			Duration = 4,
		})
	end,
})

Profiles:CreateButton({
	Name = "Delete Profile",
	Tooltip = "Calls MidasUI:DeleteConfig(profile).",
	Callback = function()
		local profile = MidasUI:GetFlag("profile_name") or "default"
		local ok, err = MidasUI:DeleteConfig(profile)
		MidasUI:Notify({
			Title = "Config",
			Content = ok and ("Deleted profile: " .. profile) or ("Delete failed: " .. tostring(err)),
			Duration = 4,
		})
	end,
})

Profiles:CreateButton({
	Name = "Print Profiles",
	Tooltip = "Uses MidasUI:ListConfigs(). Returns an empty table if listfiles is unavailable.",
	Callback = function()
		print("Profiles:", table.concat(MidasUI:ListConfigs(), ", "))
	end,
})

local DebugTab = Window:CreateTab({
	Name = "Debug",
	Icon = "info",
})

local Flags = DebugTab:CreateSection("Flags")

Flags:CreateButton({
	Name = "Set Master On",
	Tooltip = "Tests visual updates through MidasUI:SetFlag.",
	Callback = function()
		MidasUI:SetFlag("master_toggle", true)
	end,
})

Flags:CreateButton({
	Name = "Set Master Off",
	Callback = function()
		MidasUI:SetFlag("master_toggle", false)
	end,
})

Flags:CreateButton({
	Name = "Set Speed To 75",
	Callback = function()
		MidasUI:SetFlag("dependent_slider", 75)
	end,
})

Flags:CreateButton({
	Name = "Read Flags",
	Callback = function()
		print("master_toggle:", MidasUI:GetFlag("master_toggle"))
		print("mode:", MidasUI:GetFlag("mode"))
		print("username:", MidasUI:GetFlag("username"))
		print("toggle_ui_key:", MidasUI:GetFlag("toggle_ui_key"))
	end,
})

MidasUI:Notify({
	Title = "MidasUI",
	Content = "V1.2 showcase loaded.",
	Duration = 5,
})
