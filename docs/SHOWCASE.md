# Showcase And Manual QA

[src/Showcase.lua](../src/Showcase.lua) is the V1.5 interactive runtime QA surface. Replace `URL_HERE` with the raw URL for [dist/MidasUI.lua](../dist/MidasUI.lua), run it in the target runtime, and keep the F9 console visible. Debug mode is intentionally enabled in this file so invalid-input tests are visible.

## Checklist

- Load `dist/MidasUI.lua` through its raw URL and verify it returns `MidasUI` and creates the window.
- Check the F9 console: startup should not emit failures; debug warnings should occur only when triggering deliberate invalid-value tests.
- Create or inspect every element: Button, Toggle, Slider, Dropdown, Input, Keybind, Paragraph, and Divider.
- Exercise controller updates: text update, slider update, dropdown option replacement, toggle update, `Disable`/`Enable`/`Refresh`, `Hide`/`Show`, and destroyed-controller calls.
- Use `SetFlag` buttons and confirm toggle/slider/dependency visuals immediately agree with stored state.
- Save and load named config profiles; run the default profile round trip; where possible test a missing and corrupt profile file.
- Confirm slider out-of-range saved values clamp, invalid dropdown values do not replace the displayed option, and invalid keybind values do not clear a valid binding.
- Rebind and trigger Toggle keybind mode once per press.
- Trigger Hold keybind mode and confirm `true` on press and `false` on release; disable or destroy during hold where practical.
- Focus the typing input and verify keybind callbacks do not fire while typing.
- Toggle the master dependency and inspect both hidden/restored and enabled/disabled dependent controls.
- Switch through built-in, full custom, and partial custom themes while a dropdown, notification, tooltip, and dialog are visible.
- Trigger an invalid theme and confirm safe fallback plus one debug-only categorized warning.
- Show stacked notifications and run the notification cleanup test.
- Open Info, Confirm, and Input dialogs; verify actions close the overlay and callbacks do not leave the UI unusable.
- Hover tooltip-bearing elements, then hide/destroy the related item or close the window and verify the tooltip disappears.
- Close/destroy the window and verify no dialog/tooltip overlay remains; reopen or execute the bundle repeatedly where the runtime permits.

## Intentional Diagnostic Tests

The `Bad Values Stay Safe` action sends invalid values to a slider, dropdown, and toggle. Their displayed values should remain unchanged and debug mode should report categorized warnings. `Invalid Theme Warning` verifies fallback behavior.

## Manual Coverage Boundary

The showcase provides runtime interaction coverage; it is not an automated Roblox test harness. File-system config tests depend on the executing environment providing compatible file APIs.
