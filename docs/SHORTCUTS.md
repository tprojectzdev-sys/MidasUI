# Shortcuts And Launcher

V1.9 routes MidasUI framework shortcuts and Keybind elements through one owned keyboard dispatcher. Normal shortcuts do not fire while the user is typing in a `TextBox`, selecting a dropdown result, or responding to a dialog.

## Menu Toggle

Configure a window-owned hide/show shortcut:

```lua
local Window = MidasUI:CreateWindow({
	Title = "Settings",
	ToggleKey = Enum.KeyCode.RightControl,
	Launcher = true,
})
```

`RightControl` hides the window through its normal animation and shows it again. If the window is minimized, the toggle restores it.

```lua
Window:SetToggleKey("Shift+K")
Window:ClearToggleKey()

MidasUI:SetMenuToggleKey(Enum.KeyCode.RightControl) -- active-window toggle
MidasUI:ClearMenuToggleKey()
```

## Command Palette Shortcut

`Ctrl+K` remains the default. It can be replaced or disabled:

```lua
MidasUI:SetCommandPaletteShortcut("Shift+K")
MidasUI:ClearCommandPaletteShortcut()
MidasUI:SetCommandPaletteShortcut("Ctrl+K")
```

Accepted values are an `Enum.KeyCode`, a string such as `"Ctrl+K"` or `"Shift+K"`, or a table such as `{ KeyCode = Enum.KeyCode.K, Ctrl = true }`. Invalid values fail safely. Palette and menu shortcuts cannot use the same chord.

An official framework shortcut takes priority when a Keybind element is assigned the same chord. Keep action keybinds distinct from framework navigation shortcuts.

## Floating Launcher

`Launcher = true` enables a small draggable crown button only while its owning window is hidden or minimized. It restores the window on click and is placed below palettes and dialogs. The launcher is theme-aware and removed when its window is destroyed.

An optional starting position is supported:

```lua
local Window = MidasUI:CreateWindow({
	Launcher = { Position = UDim2.new(0, 20, 1, -20) },
})
```

The controller can change availability at runtime:

```lua
Window:SetLauncherEnabled(true)
Window:SetLauncherEnabled(false)
```

## Cleanup

`MidasUI:DestroyAllWindows()` destroys windows owned by the current library instance while leaving the object reusable. `MidasUI:Unload()` fully releases windows, overlays, keybind state, commands, and shortcut listeners.
