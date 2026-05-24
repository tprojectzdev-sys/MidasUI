local MidasUI = loadstring(game:HttpGet("URL_HERE"))()

local Window = MidasUI:CreateWindow({
	Title = "MidasUI",
	Subtitle = "V1.5 Example",
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
		MidasUI:Notify({
			Title = "MidasUI",
			Content = "Settings applied.",
			Duration = 3,
		})
	end,
})
