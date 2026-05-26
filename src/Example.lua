local MidasUI = loadstring(game:HttpGet("URL_HERE"))()

local Window = MidasUI:CreateWindow({
	Title = "MidasUI",
	Subtitle = "V1.9 Example",
	Theme = "DarkGold",
	ConfigFolder = "MidasExample",
	ToggleKey = Enum.KeyCode.RightControl,
})

local Main = Window:CreateTab({ Name = "Main", Icon = "home" })
local General = Main:CreateSection("General")

local Enabled = General:CreateToggle({
	Name = "Enabled",
	Flag = "enabled",
	Default = false,
})

General:CreateSlider({
	Name = "Volume",
	Flag = "volume",
	Min = 0,
	Max = 100,
	Default = 35,
	Increment = 1,
})

General:CreateButton({
	Name = "Apply",
	Icon = "check",
	Callback = function()
		Enabled:Set(true)
		MidasUI:Notify({
			Title = "MidasUI",
			Content = "Settings applied.",
			Icon = "check",
			Duration = 3,
		})
	end,
})
