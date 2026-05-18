local MidasUI = loadstring(game:HttpGet("URL_HERE"))()

local Window = MidasUI:CreateWindow({
	Title = "Midas",
	Subtitle = "V1.4 Basic Example",
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

local Status = General:CreateParagraph("Status: ready")

General:CreateButton({
	Name = "Update Status",
	Tooltip = "Uses the returned paragraph controller.",
	Callback = function()
		Status:SetText("Status: updated at " .. os.date("%X"))
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
	Name = "Volume",
	Flag = "volume",
	Min = 0,
	Max = 100,
	Default = 35,
	Increment = 5,
})

General:CreateDropdown({
	Name = "Mode",
	Flag = "mode",
	Options = { "Safe", "Normal", "Aggressive" },
	Default = "Normal",
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
