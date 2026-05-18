local MidasUI = loadstring(game:HttpGet("URL_HERE"))()

MidasUI:SetDebug(true)

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
})

local Window = MidasUI:CreateWindow({
	Title = "MidasUI V1.4 Developer API Showcase",
	Subtitle = "Controllers, dialogs, diagnostics, themes, runtime updates",
	Icon = "crown",
	Theme = "DarkGold",
	Size = UDim2.fromOffset(740, 550),
	SaveConfig = true,
	ConfigFolder = "MidasShowcase",
})

local Main = Window:CreateTab({ Name = "Main", Icon = "home" })
local Controllers = Main:CreateSection("Controller API")

local Status = Controllers:CreateParagraph({
	Text = "Controller status: ready.",
	Tooltip = "This paragraph is stored and updated through its controller.",
})

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
	Increment = 5,
	Tooltip = "Updated through SetFlag and the controller API.",
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
		DynamicDropdown:SetOptions({ "One", "Two", "Three", "Four", "Five", "Six" }, "Three")
		MasterToggle:Set(true)
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

Dialogs:CreateButton({
	Name = "Info Dialog",
	Callback = function()
		Window:Dialog({
			Type = "Info",
			Title = "Information",
			Content = "This is a themed V1.4 dialog.",
		})
	end,
})

Dialogs:CreateButton({
	Name = "Confirm Dialog",
	Callback = function()
		MidasUI:Confirm({
			Title = "Confirm Action",
			Content = "Run the confirm callback?",
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
			Placeholder = "Window title",
			Default = "MidasUI V1.4",
			OnConfirm = function(text)
				Window:SetTitle(text)
			end,
		})
	end,
})

Dialogs:CreateButton({
	Name = "Hide Window For One Second",
	Callback = function()
		Window:Hide()
		task.delay(1, function()
			Window:Show()
		end)
	end,
})

Dialogs:CreateButton({
	Name = "Minimize / Restore",
	Callback = function()
		Window:Minimize()
		task.delay(1, function()
			Window:Restore()
		end)
	end,
})

local Settings = Window:CreateTab({ Name = "Settings", Icon = "settings" })
local Themes = Settings:CreateSection("Themes")

Themes:CreateDropdown({
	Name = "Runtime Theme",
	Flag = "theme",
	Options = { "DarkGold", "Midnight", "BlackWhite", "ObsidianGold" },
	Default = "DarkGold",
	Callback = function(themeName)
		MidasUI:SetTheme(themeName)
	end,
})

Themes:CreateButton({
	Name = "Invalid Theme Warning",
	Tooltip = "Only logs when debug mode is enabled.",
	Callback = function()
		MidasUI:SetTheme("MissingTheme")
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
	Name = "Print Debug State",
	Callback = function()
		local state = MidasUI:GetDebugState()
		if state then
			print("MidasUI Debug:", state.Version, state.Theme, state.WindowCount, state.FlagCount, state.KeybindCount)
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
	Flag = "long_dropdown",
	Options = longOptions,
	Default = "Alpha",
	MaxVisibleOptions = 6,
})

for index = 1, 10 do
	Stress:CreateSlider({
		Name = "Stress Slider " .. index,
		Flag = "stress_slider_" .. index,
		Min = 0,
		Max = 100,
		Default = index * 5,
		Increment = 5,
	})
end

local Inputs = Window:CreateTab({ Name = "Input", Icon = "user" })
local Keybinds = Inputs:CreateSection("Keybinds")

Keybinds:CreateInput({
	Name = "Typing Test",
	Flag = "typing_test",
	Placeholder = "Type here; keybinds should not fire while focused.",
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

Keybinds:CreateKeybind({
	Name = "Hold Key",
	Flag = "hold_key",
	Default = Enum.KeyCode.LeftShift,
	Mode = "Hold",
	Callback = function(isHolding, keyCode)
		print("Hold key:", isHolding, keyCode)
	end,
})

MidasUI:Notify({
	Title = "MidasUI",
	Content = "V1.4 showcase loaded.",
	Duration = 4,
})
