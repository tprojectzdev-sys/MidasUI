local MidasUI = loadstring(game:HttpGet("URL_HERE"))()

local Window = MidasUI:CreateWindow({
	Title = "Midas",
	Subtitle = "Minimal Example",
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

General:CreateParagraph("A small MidasUI setup with the core V1.2 controls.")

General:CreateButton({
	Name = "Say Hello",
	Tooltip = "Runs a simple callback and shows a notification.",
	Callback = function()
		print("Hello from MidasUI")
		MidasUI:Notify({
			Title = "Midas",
			Content = "Hello from MidasUI.",
			Duration = 3,
		})
	end,
})

General:CreateToggle({
	Name = "Enabled",
	Flag = "enabled",
	Default = false,
	Tooltip = "This value is stored in MidasUI.Flags.enabled.",
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

General:CreateKeybind({
	Name = "Toggle UI Key",
	Flag = "toggle_ui_key",
	Default = Enum.KeyCode.RightControl,
	Callback = function(keyCode)
		print("Keybind pressed:", keyCode)
	end,
})

MidasUI:Notify({
	Title = "Midas",
	Content = "Loaded successfully.",
	Duration = 5,
})
