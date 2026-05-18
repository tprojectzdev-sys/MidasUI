local MidasUI = loadstring(game:HttpGet("URL_HERE"))()

local Window = MidasUI:CreateWindow({
	Title = "Midas",
	Subtitle = "Private Hub",
	Icon = "crown",
	Theme = "DarkGold",
	Size = UDim2.fromOffset(620, 460),
	SaveConfig = true,
	ConfigFolder = "Midas",
})

local MainTab = Window:CreateTab({
	Name = "Main",
	Icon = "home",
})

local General = MainTab:CreateSection("General")

General:CreateParagraph({
	Text = "MidasUI V1.1 foundation: flags, configs, themes, tabs, sections, and core controls.",
})

General:CreateButton({
	Name = "Test Button",
	Callback = function()
		print("Clicked")
		MidasUI:Notify({
			Title = "Midas",
			Content = "Button clicked successfully.",
			Duration = 3,
		})
	end,
})

General:CreateToggle({
	Name = "Enabled",
	Flag = "enabled",
	Default = false,
	Callback = function(value)
		print("Enabled:", value)
	end,
})

General:CreateSlider({
	Name = "Speed",
	Flag = "speed",
	Min = 0,
	Max = 100,
	Default = 16,
	Increment = 1,
	Callback = function(value)
		print("Speed:", value)
	end,
})

General:CreateDropdown({
	Name = "Mode",
	Flag = "mode",
	Options = { "Safe", "Normal", "Aggressive" },
	Default = "Normal",
	Callback = function(value)
		print("Mode:", value)
	end,
})

General:CreateInput({
	Name = "Username",
	Flag = "username",
	Placeholder = "Enter name...",
	Default = "",
	Callback = function(value)
		print("Username:", value)
	end,
})

General:CreateDivider()

General:CreateParagraph({
	Text = "Try MidasUI:SetFlag(\"enabled\", true) or MidasUI:SetTheme(\"Midnight\") from your script.",
})

local SettingsTab = Window:CreateTab({
	Name = "Settings",
	Icon = "settings",
})

local ThemeSection = SettingsTab:CreateSection("Theme")

ThemeSection:CreateDropdown({
	Name = "Theme",
	Flag = "theme_choice",
	Options = { "DarkGold", "Midnight", "BlackWhite" },
	Default = "DarkGold",
	Callback = function(value)
		MidasUI:SetTheme(value)
	end,
})

ThemeSection:CreateButton({
	Name = "Save Config",
	Callback = function()
		local ok, err = MidasUI:SaveConfig()
		MidasUI:Notify({
			Title = "Midas",
			Content = ok and "Config saved." or ("Config not saved: " .. tostring(err)),
			Duration = 4,
		})
	end,
})

MidasUI:Notify({
	Title = "Midas",
	Content = "Loaded successfully",
	Duration = 5,
})
