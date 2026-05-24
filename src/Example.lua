local MidasUI = loadstring(game:HttpGet("URL_HERE"))()

local Window = MidasUI:CreateWindow({
	Title = "MidasUI",
	Subtitle = "V1.8 Example",
	Theme = "DarkGold",
	ConfigFolder = "MidasExample",
})

local Main = Window:CreateTab({ Name = "Main", Icon = "home" })
local General = Main:CreateSection("General")

local Enabled = General:CreateToggle({
	Name = "Enabled",
	Flag = "enabled",
	Default = false,
})

local Status = General:CreateParagraph("Status: ready")
local Progress = General:CreateProgressBar({
	Name = "Setup Progress",
	Value = 20,
	Status = "Ready",
})

General:CreateSlider({
	Name = "Volume",
	Flag = "volume",
	Min = 0,
	Max = 100,
	Default = 35,
	Increment = 5,
})

General:CreateButton({
	Name = "Apply",
	Tooltip = "Updates two stored controllers.",
	Callback = function()
		Enabled:Set(true)
		Status:SetText("Status: enabled")
		Progress:SetStatus("Applied"):Set(100)
		MidasUI:Notify({
			Title = "MidasUI",
			Content = "Settings applied.",
			Duration = 3,
		})
	end,
})

Window:RegisterCommand({
	Title = "Apply Settings",
	Description = "Run the same beginner example action.",
	Callback = function()
		Enabled:Set(true)
		Status:SetText("Status: enabled from command palette")
	end,
})

General:CreateButton({
	Name = "Open Command Palette",
	Callback = function()
		MidasUI:OpenCommandPalette()
	end,
})
