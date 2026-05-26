# Templates And Workflow Layouts

V1.9 continues the optional layout presets through the existing window and section API. A template adjusts spacing, density, and preferred starting size; it does not add application behavior or replace the element API. Commands and optional shortcuts make larger template-based interfaces faster to operate.

```lua
local Window = MidasUI:CreateWindow({
	Title = "Operations",
	Template = "FarmingDashboard",
})
```

## Included Templates

| Template | Use It For | Behavior |
| --- | --- | --- |
| `Default` | Standard settings interfaces | Preserves the existing MidasUI layout. |
| `FarmingDashboard` | Status and long-running workflow views | More generous dashboard composition and starting size. |
| `PowerPanel` | Dense advanced configuration pages | Compact tabs, sections, and controls with tighter scrolling. |

`Preset = "PowerPanel"` is supported as an alias for `Template`. Individual sections may override density with `CreateSection({ Name = "Advanced", Compact = true })`.

## Dashboard Pattern

Use the generic display controls for workflow state without embedding application logic in the UI:

```lua
local Summary = Tab:CreateSection("Status")
local Task = Summary:CreateStatusCard({ Name = "Current Task", Value = "Idle" })
local Progress = Summary:CreateProgressBar({ Name = "Progress", Value = 0, Status = "Waiting" })
local Events = Summary:CreateLogPanel({ MaxLines = 12 })

Task:Set("Running")
Progress:SetStatus("Working"):Set(40)
Events:AddLine("Workflow started", "Success")

Window:RegisterCommand({
	Title = "Dashboard: Clear Recent Events",
	Category = "Dashboard",
	Callback = function()
		Events:Clear()
	end,
})
```

`ActionRow` gives Start/Pause/Stop-style arrangements without defining what those actions do. Use a danger confirm dialog before an irreversible action.

## Power Panel Pattern

`PowerPanel` is intended for many generic toggles, sliders, dropdowns, and keybinds grouped in readable sections. It currently supplies compact single-column sections; it does not implement a two-column grid. Keep groups small enough to scan, use searchable dropdowns for long lists, and register explicit palette commands for frequent actions.

```lua
local Mode = Advanced:CreateDropdown({
	Name = "Processing Mode",
	Options = modes,
	Searchable = true,
})

Window:RegisterCommand({
	Title = "Power Panel: Search Processing Mode",
	Category = "Power Panel",
	Callback = function()
		MidasUI:NavigateTo(Mode)
	end,
})
```
