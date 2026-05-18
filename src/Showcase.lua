local MidasUI = loadstring(game:HttpGet("URL_HERE"))()

local Window = MidasUI:CreateWindow({
	Title = "MidasUI Professional Framework Showcase",
	Subtitle = "V1.3 layout, scrolling, lifecycle, dependencies, and controls",
	Icon = "crown",
	Theme = "DarkGold",
	Size = UDim2.fromOffset(720, 540),
	SaveConfig = true,
	ConfigFolder = "MidasShowcase",
})

local Main = Window:CreateTab({ Name = "Main", Icon = "home" })
local Stress = Main:CreateSection("Dense Controls")

Stress:CreateParagraph({
	Text = "This tab intentionally contains many controls to validate scrolling, spacing, text wrapping, dropdown behavior, and bottom-element access.",
	Tooltip = "Scroll to the bottom and open dropdowns while the page is scrolled.",
})

Stress:CreateButton({
	Name = "Burst Notifications",
	Tooltip = "Creates several stacked notifications with auto cleanup.",
	Callback = function()
		for index = 1, 4 do
			MidasUI:Notify({
				Title = "Notification " .. index,
				Content = "Stacking check with clean auto-removal.",
				Duration = 2 + index,
			})
		end
	end,
})

Stress:CreateToggle({
	Name = "Master Dependency",
	Flag = "master_dependency",
	Default = false,
	Tooltip = "Controls the visible and enabled dependency examples below.",
})

Stress:CreateSlider({
	Name = "Visible When Master Is On",
	Flag = "dependent_visible_slider",
	Min = 0,
	Max = 100,
	Default = 50,
	Increment = 1,
	Tooltip = "This should not consume layout space while hidden.",
	DependsOn = {
		Flag = "master_dependency",
		Value = true,
		Mode = "Visible",
	},
})

Stress:CreateButton({
	Name = "Enabled When Master Is On",
	Tooltip = "Disabled state should block interaction and look muted.",
	DependsOn = {
		Flag = "master_dependency",
		Value = true,
		Mode = "Enabled",
	},
	Callback = function()
		print("Dependent button clicked")
	end,
})

Stress:CreateDivider()

local longOptions = {
	"Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot",
	"Golf", "Hotel", "India", "Juliet", "Kilo", "Lima",
	"Mike", "November", "Oscar", "Papa", "Quebec", "Romeo",
}

Stress:CreateDropdown({
	Name = "Long Dropdown",
	Flag = "long_dropdown",
	Options = longOptions,
	Default = "Alpha",
	MaxVisibleOptions = 6,
	Tooltip = "The dropdown has its own scrollbar and should not destroy page layout.",
	Callback = function(value)
		print("Long dropdown:", value)
	end,
})

for index = 1, 12 do
	Stress:CreateSlider({
		Name = "Stress Slider " .. index,
		Flag = "stress_slider_" .. index,
		Min = 0,
		Max = 100,
		Default = index * 5,
		Increment = 5,
		Tooltip = "Dense scrolling slider #" .. index,
	})
end

local InputTab = Window:CreateTab({ Name = "Input", Icon = "user" })
local Inputs = InputTab:CreateSection("Inputs and Keybinds")

Inputs:CreateInput({
	Name = "Typing Test",
	Flag = "typing_test",
	Placeholder = "Type here; keybinds should not fire while focused.",
	Tooltip = "Use this to confirm focused TextBoxes suppress keybind callbacks.",
})

Inputs:CreateKeybind({
	Name = "Toggle Key",
	Flag = "toggle_key",
	Default = Enum.KeyCode.F,
	Mode = "Toggle",
	Tooltip = "Click, press a key to assign. Escape cancels, Backspace clears.",
	Callback = function(keyCode)
		print("Toggle key fired:", keyCode)
		MidasUI:Notify({
			Title = "Toggle Key",
			Content = "Pressed " .. tostring(keyCode),
			Duration = 2,
		})
	end,
})

Inputs:CreateKeybind({
	Name = "Hold Key",
	Flag = "hold_key",
	Default = Enum.KeyCode.LeftShift,
	Mode = "Hold",
	Tooltip = "Hold mode sends true on press and false on release.",
	Callback = function(isHolding, keyCode)
		print("Hold key:", isHolding, keyCode)
	end,
})

Inputs:CreateButton({
	Name = "Set Toggle Key To X",
	Callback = function()
		MidasUI:SetFlag("toggle_key", Enum.KeyCode.X)
	end,
})

Inputs:CreateButton({
	Name = "Clear Toggle Key",
	Callback = function()
		MidasUI:SetFlag("toggle_key", nil)
	end,
})

local Settings = Window:CreateTab({ Name = "Settings", Icon = "settings" })
local ThemeSection = Settings:CreateSection("Theme")

ThemeSection:CreateDropdown({
	Name = "Theme",
	Flag = "theme",
	Options = { "DarkGold", "Midnight", "BlackWhite" },
	Default = "DarkGold",
	Callback = function(themeName)
		MidasUI:SetTheme(themeName)
	end,
})

ThemeSection:CreateButton({
	Name = "Set Master On",
	Tooltip = "Tests dependency refresh through SetFlag.",
	Callback = function()
		MidasUI:SetFlag("master_dependency", true)
	end,
})

ThemeSection:CreateButton({
	Name = "Set Master Off",
	Callback = function()
		MidasUI:SetFlag("master_dependency", false)
	end,
})

local Profiles = Settings:CreateSection("Profiles")

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
		MidasUI:Notify({
			Title = "Config",
			Content = ok and ("Saved " .. profile) or tostring(err),
			Duration = 3,
		})
	end,
})

Profiles:CreateButton({
	Name = "Load Profile",
	Callback = function()
		local profile = MidasUI:GetFlag("profile_name") or "default"
		local ok, err = MidasUI:LoadConfig(profile)
		MidasUI:Notify({
			Title = "Config",
			Content = ok and ("Loaded " .. profile) or tostring(err),
			Duration = 3,
		})
	end,
})

Profiles:CreateButton({
	Name = "Print Profiles",
	Callback = function()
		print("Profiles:", table.concat(MidasUI:ListConfigs(), ", "))
	end,
})

local Bottom = Main:CreateSection("Bottom Reachability")

Bottom:CreateParagraph({
	Text = "If you can read this and interact with the button below after opening long dropdowns above, the page canvas is updating correctly.",
})

Bottom:CreateButton({
	Name = "Bottom Button",
	Callback = function()
		MidasUI:Notify({
			Title = "Bottom",
			Content = "Bottom element is reachable.",
			Duration = 2,
		})
	end,
})

MidasUI:Notify({
	Title = "MidasUI",
	Content = "V1.3 showcase loaded.",
	Duration = 4,
})
