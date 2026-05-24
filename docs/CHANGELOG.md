# Changelog

## V1.5.0

Theme: API stabilization, documentation, QA hardening, and developer experience.

### Added

- Repository documentation for public APIs, controllers, configs, themes, and manual QA.
- Notification return controller with `Close()` for deterministic cleanup.
- Debug warning categories and protected callback diagnostics.
- `Resizable` window option spelling while retaining `Resizeable` compatibility.
- `Enable()` and `Disable()` on Paragraph and Divider controllers; `Divider:SetValue()` visibility alias.

### Improved

- Controller calls after destruction are inert across elements and containers.
- Element destruction now immediately unregisters dependency records.
- Flag updates normalize through live controllers so rejected dropdown, toggle, slider, and keybind values do not corrupt their controlled state.
- Config loading protects corrupt JSON, invalid saved fields, missing file APIs, and saved window dimensions.
- Theme registration and runtime switching return clear status values; invalid or partial themes fall back safely.
- Theme changes refresh transient UI and disabled controller visuals consistently.
- Dialog and element/keybind callbacks execute without breaking UI flow; failures are debug diagnostics.
- Window destruction closes active dialog state and hides tooltip state.

### Examples And QA

- Reduced `src/Example.lua` to a beginner-focused normal flow.
- Expanded `src/Showcase.lua` with default config, invalid input, partial custom theme, transient cleanup, and controller lifecycle tests.

## V1.4

Added controller APIs, runtime theme switching, dialogs/modals, diagnostics/debug mode, stronger flag/controller binding, and safer public APIs.

## V1.3

Hardened layout, scrolling, lifecycle cleanup, visual consistency, notifications, dependencies, and showcase stress testing.

## V1.2

Added keybinds, tooltips, config profiles, dependencies, icons, and showcase; a follow-up corrected keybind Toggle/Hold behavior.
