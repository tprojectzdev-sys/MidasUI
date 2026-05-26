# Changelog

## V1.9.0

Theme: premium motion and depth, custom icons, shortcut ownership, overlay polish, and runtime verification.

### Added

- Internal `Shortcuts` manager with one owned persistent keyboard dispatcher for framework shortcuts and Keybind element triggering.
- Configurable command-palette shortcut APIs with `Ctrl+K` retained as the default.
- Window/menu toggle shortcut APIs and optional draggable theme-aware floating crown launcher.
- Command palette Recent group and category-oriented result presentation.
- `GetRuntimeReport`, `RunSelfTest`, `PrintRuntimeReport`, `DestroyAllWindows`, `IsLoaded`, and `Unload` lifecycle/QA APIs.
- Custom icon registry APIs supporting glyphs, image assets, and sprites for branded surfaces.

### Improved

- Palette, standard input, searchable dropdown, keybind capture, and prompt input focus visibility.
- Richer DarkGold surfaces, section/window depth, icon-capable controls, notification progress rails, and animated modal/palette/dropdown exits.
- Tracked/cancelled transition ownership across controls and transient overlays to prevent competing motion after cleanup.
- Shortcut parsing supports `KeyCode`, `"Ctrl+K"`/`"Shift+K"` text chords, and descriptor tables with safe invalid-value warnings.
- Showcase now covers shortcut replacement, launcher recovery, recent actions, self-test reporting, and unload behavior while retaining V1.8 tests.

### Compatibility

- Existing command, search, component, slider, dropdown, dialog, theme, config, and bundled loadstring APIs remain supported.
- Framework shortcuts are suppressed during owned text/modal interactions and take priority over an element keybind intentionally assigned the same chord.

## V1.8.0

Theme: command discovery, navigation speed, and keyboard-first large-interface workflows.

### Added

- Owner-scoped command/action registry with protected execution and debug diagnostics.
- `Ctrl+K` command palette with query seeding, keyboard result navigation, and explicit modal coordination.
- Automatic search indexing for windows, tabs, sections, and elements with navigation results.
- Public command, palette, search, and `NavigateTo` APIs plus command/search debug counts.
- Optional and automatic long-dropdown filtering with keyboard result selection.
- Command/search documentation at `docs/COMMANDS.md`.

### Improved

- Dialogs handle `Enter` confirmation and `Escape` cancellation/close while remaining above the palette.
- Existing keybind dispatch ignores the command-palette chord and remains suppressed during text entry, palette/dialog interaction, and expanded-dropdown keyboard selection.
- Dashboard and power-panel showcase windows demonstrate scoped generic workflow commands and searchable dense settings.
- Overlay cleanup closes palette/dropdown state during modal, hide, minimize, and destruction flows.
- Palette and searchable-dropdown rows provide clearer selection/no-result feedback and clean transient row listeners during refresh.
- Expanded dropdowns now use a viewport-aware overlay with outside-click dismissal, avoiding section reflow and clipping while retaining the existing dropdown/controller API.
- `OnThemeChanged(callback)` provides a small protected, disconnectable observer for application-owned theme-following visuals.
- The Showcase performs cache-busted bundle loading, previous-runtime teardown, and explicit cleanup/debug checks for repeated-session QA.

### Fixed

- Normal Showcase sliders now use one-unit increments; the only five-unit slider is explicitly labeled as a coarse-step test.
- Destroyed library instances no longer recreate transient overlays from delayed callbacks before explicit reuse.
- Stale command controllers cannot unregister or execute a later command reusing the same ID.
- Tooltips no longer remain visible beneath an active dropdown, palette, or dialog during overlay transitions.

### Compatibility

- Discovery results navigate only; state-changing behavior requires an explicitly registered command.
- Existing APIs, config/controller behavior, templates, Toggle/Hold keybind semantics, and bundled loadstring entry point remain supported.

## V1.7.0

Theme: workflow templates, generic dashboard components, and compact advanced settings organization.

### Added

- Optional `Default`, `FarmingDashboard`, and `PowerPanel` templates on `CreateWindow`; `Preset` is a compatible alias.
- Section-level `Compact = true` density override and `MidasUI:GetTemplate(...)` inspection API.
- Generic `ProgressBar`, `StatCard` / `StatusCard`, `LogPanel`, `Callout`, and `ActionRow` elements with lifecycle-safe controllers.
- Theme `Success` semantic color token, normalized safely for partial custom themes.
- Workflow layout guidance in `docs/TEMPLATES.md`.

### Improved

- `PowerPanel` reduces navigation, section, and core-control spacing without altering default layout behavior.
- Confirm dialogs accept optional danger styling for important workflow actions while retaining custom button labels and protected callbacks.
- Showcase provides separate optional dashboard and dense settings windows with controller/theme/dialog QA paths.

### Compatibility

- Existing window, tab, section, element, config, theme, and bundle entry points remain supported.
- Templates are presentation-only; no automation or game-specific behavior is built into MidasUI.

## V1.6.0

Theme: visual identity, animation polish, interaction polish, and documentation discovery.

### Added

- Compact code-native crown crest in the window topbar and a short branded startup reveal.
- `Intro = false`, `StartupAnimation = false`, and `Animations = false` window options for immediate/reduced-motion presentation.
- Documentation landing page at `docs/README.md`.
- Additional theme tokens: `AccentSoft`, `Highlight`, and `Shadow`, normalized safely for custom themes.

### Improved

- Sliders now apply decimal-aware snap precision, formatted values, correct sub-unit ratios, immediate drag feedback, and safer input release tracking.
- Notifications enter from the side with a restrained settle motion and use animated side exits for timeout and controller closing.
- Window `Show()`/`Hide()` and minimize/restore follow a consistent motion vocabulary.
- Dialogs, tooltips, notifications, and windows use explicit display ordering for reliable layering.
- Built-in themes use stronger contrast, richer surfaces, and more intentional accent treatment.
- Showcase includes targeted V1.6 slider, motion, branding, minimize, and dialog-layer regression tests.

### Fixed

- Window minimization could be stopped at the full-size `UISizeConstraint`, leaving content visibly present.
- Dialog screens could appear beneath the restored window because transient screen ordering was not explicit.
- Slider display and fill position were unreliable for ranges below `1` and small increments.

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
