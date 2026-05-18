local MidasUI = loadstring(game:HttpGet("URL_HERE"))()

local Window = MidasUI:CreateWindow({
	Title = "Midas",
	Subtitle = "V1.3 Basic Example",
	Icon = "crown",
	Theme = "DarkGold",
	Size = UDim2.fromOffset(620, 460),
	SaveConfig = true,
	ConfigFolder = "MidasExample",
})

local Main = Window:CreateTab({
	Name = "Main",
	Icon = "home",
})

local General = Main:CreateSection("General")

General:CreateParagraph("MidasUI V1.3 keeps the beginner flow small while the framework handles layout, scrolling, config, and cleanup.")

General:CreateButton({
	Name = "Notify",
	Tooltip = "Shows a small themed notification.",
	Callback = function()
		MidasUI:Notify({
			Title = "Midas",
			Content = "Hello from MidasUI V1.3.",
			Duration = 3,
		})
	end,
})

General:CreateToggle({
	Name = "Enabled",
	Flag = "enabled",
	Default = false,
	Tooltip = "Saved in MidasUI.Flags.enabled.",
	Callback = function(value)
		print("Enabled:", value)
	end,
})

General:CreateSlider({
	Name = "Volume",
	Flag = "volume",
	Min = 0,
	Max = 100,
	Default = 35,
	Increment = 5,
	Callback = function(value)
		print("Volume:", value)
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
	Name = "Name",
	Flag = "player_name",
	Placeholder = "Type a name...",
})

General:CreateKeybind({
	Name = "Action Key",
	Flag = "action_key",
	Default = Enum.KeyCode.F,
	Mode = "Toggle",
	Callback = function(keyCode)
		print("Action key:", keyCode)
	end,
})
