# V1.9 Showcase And Manual QA

[src/Showcase.lua](../src/Showcase.lua) is the V1.9 interactive runtime QA surface. It loads the raw [dist/MidasUI.lua](../dist/MidasUI.lua) URL with a per-run cache-busting query and keeps the F9 console visible through opt-in debug output.

## Clean Runtime Flow

1. Run the current `Showcase.lua`; it stores its MidasUI instance in the shared runtime environment.
2. Re-run the same script to test reload behavior. It calls `Unload()` on the preceding stored showcase instance before fetching the cache-busted bundle.
3. Confirm `WindowCount`, `KeybindCount`, `ShortcutCount`, and `CommandCount` describe only the current test UI by using `Print Debug State`.
4. Use `Runtime: Unload Showcase` from the palette or `Unload Showcase Runtime` in diagnostics for explicit cleanup before stopping testing.

An older showcase script already open before this cleanup behavior cannot be discovered reliably by a newly loaded library. Destroy that retained library instance when available, or start a clean runtime session before investigating duplicate UI/keybind behavior.

## Checklist

- Load `dist/MidasUI.lua` through the cache-busted raw URL and verify it returns `MidasUI` Version `1.9.0` and creates one window.
- On first open, inspect the short dropping crown/reveal intro; confirm it completes cleanly and the compact crown topbar crest remains crisp.
- In a minimal follow-up window, set `Intro = false` or `Animations = false` and verify immediate, usable creation without the reveal.
- Check the F9 console: startup should not emit failures; debug warnings should occur only when triggering deliberate invalid-value tests.
- Create or inspect every element: Button, Toggle, Slider, Dropdown, Input, Keybind, Paragraph, and Divider.
- Press `Ctrl+K`; verify the palette opens above the window, auto-focuses search, closes with `Escape`, and toggles closed with `Ctrl+K`.
- Run a command, reopen an empty palette, and verify it appears in the `RECENT` group with its category readable.
- Use `Set Palette Shortcut: Shift+K`, verify `Ctrl+K` stops opening and `Shift+K` works, then restore `Ctrl+K`.
- Use the disable/restore shortcut test and invalid shortcut test; verify disabled input is inert and invalid input gives only a debug warning.
- Press `RightControl` outside a text box to hide the showcase, confirm the floating crown launcher appears, drag it without opening the UI, then click it to restore.
- In the `Discovery` tab, run open/toggle/query actions; search for `slider`, `dropdown`, `dialogs`, and `theme`, then use `Up`, `Down`, and `Enter`.
- Run `Palette: Keep Open Notification`; verify `CloseOnRun = false` leaves the palette active until explicitly closed.
- Select an indexed tab, section, and element result; verify it navigates/scrolls without invoking a button or toggling a flag.
- Print both search result tests and debug state; verify command/index/shortcut counts, configured shortcut names, overlay state, and V1.9 API booleans appear.
- Run `Run Runtime Self-Test`; verify a returned/presented pass result and useful count output in debug mode.
- From `V1.8 Workflow Templates Retained`, open the `FarmingDashboard` demo and inspect StatusCard, ProgressBar, LogPanel, Callout, and ActionRow.
- In the dashboard, run Start, Pause, the controller update, and Stop flows; verify progress flag updates, semantic line/callout colors, capped logs, and danger confirmation styling.
- With the dashboard open, use commands `Dashboard: Start`, `Pause`, `Clear`, `Jump`, and `Reset`; close/destroy it and verify those commands disappear.
- Open the `PowerPanel` demo; confirm compact sections remain readable and the toggle/slider/dropdown/keybind groups scroll without clipping.
- Use the `Power Panel:` commands to jump to grouped settings, explicitly toggle the sample flag, and open its searchable mode dropdown.
- Drag `Precision Slider (0.01)` slowly across negative and positive values; verify two-decimal text, smooth fill/knob movement, correct endpoints, and no stuck drag.
- Exercise controller updates: text update, both slider updates, dropdown option replacement, toggle update, `Disable`/`Enable`/`Refresh`, `Hide`/`Show`, and destroyed-controller calls.
- Drag `Controlled Slider`; verify normal values move one unit at a time. `Coarse Step Slider (5)` is the intentional five-unit comparison case.
- Use `SetFlag` actions and config loading for normal and precision sliders; confirm snapped displayed/filled values agree immediately.
- Save and load named config profiles; run the default profile round trip; where possible test a missing and corrupt profile file.
- Confirm slider out-of-range saved values clamp, invalid dropdown values do not replace the displayed option, and invalid keybind values do not clear a valid binding.
- Rebind and trigger Toggle keybind mode once per physical press, then re-run Showcase and repeat to check listener cleanup.
- Trigger Hold keybind mode and confirm `true` on press and `false` on release; disable or destroy during hold where practical.
- Focus the typing input and verify keybind callbacks do not fire while typing.
- Keep the typing input focused and press `Ctrl+K` and `RightControl`; verify ordinary input focus blocks palette and menu activation.
- Toggle the master dependency and inspect both hidden/restored and enabled/disabled dependent controls.
- Switch through built-in, full custom, and partial custom themes while a dropdown, notification, tooltip, dialog, and topbar crest are visible; compare contrast and gold treatment.
- In `Icon Registry and Surface Depth`, verify the custom glyph and sprite icon render on a status card, callout, dropdown, button, notification, and dialog, then switch themes while they are visible.
- After publishing the regenerated dist, check the console theme callback line after each theme action; it should report one applied theme event per change.
- Repeat theme switching while the dashboard and power panel windows are open; new components must update their surface and semantic colors.
- Run `Theme Switch With Palette Open`; verify the open palette recolors without visual residue.
- Trigger an invalid theme and confirm safe fallback plus one debug-only categorized warning.
- Run notification stack and animated exit tests; verify side-entry settle, timed progress rails, side-exit, stable stacking, icon coloring, and `Close()` cleanup.
- Run `Animated Hide / Show`; confirm the window leaves and returns smoothly without broken hitboxes.
- Run `Minimize / Restore Regression`; confirm only the topbar remains while minimized and full content restores to the prior size.
- Run both palette cleanup transition tests; verify minimize and hide close palette interaction cleanly before restoring the window.
- Run `Restore Then Confirm Layer Test`; confirm the overlay and dialog card remain fully above the restored window.
- Run `Palette Then Dialog Layer Test`; verify the dialog closes/replaces palette interaction and remains topmost.
- Open Info, Confirm, and Input dialogs separately; verify actions close the overlay and callbacks do not leave the UI unusable.
- Press `Enter` and `Escape` in dialogs and verify confirm/cancel behavior; type in the prompt before confirming.
- Open `Long Dropdown`; confirm it overlays without pushing section content, type to filter, check the explicit no-match message, use arrows and `Enter`, click outside to dismiss, verify the selected flag remains valid, then reopen and confirm the filter reset.
- Trigger the dashboard Stop action and verify its danger confirm remains above every open window after minimize/restore or hide/show.
- Hover tooltip-bearing elements, then hide/destroy the related item or close the window and verify the tooltip disappears.
- Close/destroy the window and verify no dialog/tooltip overlay remains; reopen or execute the bundle repeatedly where the runtime permits.

## Intentional Diagnostic Tests

The `Bad Values Stay Safe` action sends invalid values to sliders, dropdown, and toggle. Their displayed values should remain unchanged and debug mode should report categorized warnings. `Invalid Shortcut Warning` checks shortcut validation. `Invalid Theme Warning` verifies fallback behavior. Dashboard commands cover owner-scoped cleanup and `SetFlag` propagation; discovery buttons cover command/index/recent search and overlay behavior.

## Manual Coverage Boundary

The showcase provides runtime interaction coverage; it is not an automated Roblox test harness. File-system config tests depend on the executing environment providing compatible file APIs.
