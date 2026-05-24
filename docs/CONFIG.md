# Config Profiles

Config profiles save current flags, registered theme name, and active window size/minimized state.

```lua
local ok, err = MidasUI:SaveConfig()          -- default.json
local ok, err = MidasUI:LoadConfig()
local ok, err = MidasUI:SaveConfig("combat")
local ok, err = MidasUI:LoadConfig("combat")
local profiles = MidasUI:ListConfigs()
local ok, err = MidasUI:DeleteConfig("combat")
```

Set a folder when constructing a window:

```lua
local Window = MidasUI:CreateWindow({
	Title = "Settings",
	ConfigFolder = "MidasSettings",
	SaveConfig = true,
})
```

`SaveConfig = true` loads the default profile as the window is created and saves it when the window closes. For predictable initialization, create flag-bearing controls with sensible defaults because controls may be created after the initial automatic load.

## Storage Requirements

Profile storage uses runtime-provided file functions. Saving requires `writefile`; loading requires `readfile` and `isfile`. Listing and deleting require their corresponding functions. When capabilities are missing, methods return failure values or an empty list rather than throwing.

Profile names are sanitized into safe filenames: unsupported characters become underscores and an empty result becomes `default`. The default save target is `<ConfigFolder>/default.json`. Loading without a profile also accepts the earlier legacy `ConfigFile` path when present.

## Validation On Load

- Corrupt JSON returns `false, "Config JSON could not be decoded"` without applying data.
- Invalid flag collections, flag names, and theme fields are ignored safely with debug-only diagnostics.
- Bound slider values are clamped and snapped to their current range.
- Bound dropdown values not present in the current option list are rejected.
- Bound toggles and keybinds reject invalid value types.
- Dependencies refresh after loading.
- A saved unknown theme falls back to `DarkGold`; warnings appear only with debug enabled.

Keycodes are stored as key names and accepted back by keybind controllers on load.

## Limitations

An unregistered custom theme has no durable name to restore. Call `RegisterTheme("MyTheme", values)` and set that name before saving when theme persistence is required. Flags that have no live controller cannot be type-validated until a compatible controller is created.
