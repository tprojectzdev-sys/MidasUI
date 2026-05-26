# V1.9 Motion, Icons, And Visual Identity

MidasUI V1.9 keeps a dark gold identity: deep charcoal surfaces, warm controlled accents, high-contrast text, and subtle depth. Motion is intentionally restrained. Windows reveal smoothly, dropdowns and modal surfaces settle without loud bounce, and notifications enter and leave from the side with a timed progress rail.

## Custom Icons

Built-in icon names such as `"home"`, `"settings"`, `"crown"`, `"info"`, and `"check"` continue to work. Register project icons before creating controls:

```lua
MidasUI:RegisterIcons({
	Gem = { Text = "G" },
	Star = {
		Image = "rbxassetid://3926305904",
		ImageRectOffset = Vector2.new(4, 4),
		ImageRectSize = Vector2.new(36, 36),
	},
})

local Tab = Window:CreateTab({ Name = "Premium", Icon = "Star" })
local Section = Tab:CreateSection("Actions")
Section:CreateButton({ Name = "Apply", Icon = "Gem", Callback = function() end })
```

`RegisterIcon(name, definition)` also accepts a numeric asset id or an `rbxassetid://` string. Missing names fall back safely to a small text mark; invalid registrations return `false` instead of breaking UI construction.

Icons are supported on tabs, buttons, dropdown controls, status cards, callouts, notifications, dialogs, and custom window badge marks.

## Notifications And Dialogs

```lua
local notice = MidasUI:Notify({
	Title = "Saved",
	Content = "Profile applied.",
	Icon = "check",
	Duration = 3,
})

MidasUI:Confirm({
	Title = "Delete profile?",
	Content = "This action cannot be undone.",
	Icon = "warning",
	Danger = true,
	OnConfirm = function() end,
})
```

`notice:Close()` is safe before or after timeout. Dialogs remain above windows, dropdowns, and the command palette; input prompts use the same focused accent treatment as standard inputs.

## Dropdowns And Command Palette

Searchable dropdowns animate in an overlay layer and choose an above/below placement that remains inside the viewport. Long lists scroll without resizing their section.

The command palette opens with `Ctrl+K` by default, groups results, records recent commands, scrolls dense results, and remains theme-aware while open. Use `SetCommandPaletteShortcut("Shift+K")` when an application already owns `Ctrl+K`.

## Theme Switching

New gradients, icons, focus states, overlay surfaces, and notification rails are rethemed by `MidasUI:SetTheme(...)`. Partial custom themes are filled from `DarkGold`, so a beginner can override only the colors they need.

## Testing

Run [Showcase.lua](../src/Showcase.lua), then follow [SHOWCASE.md](SHOWCASE.md). Pay particular attention to icon registration, notification stacking/close behavior, modal layering, long dropdown placement, command palette theme switching, and hide/minimize/launcher recovery.
