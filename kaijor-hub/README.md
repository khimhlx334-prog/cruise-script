# KaiJor Hub

A standalone Roblox client interface with a charcoal and violet theme. All interface text is English.

## Version 0.1.0

- Home, Controls, and Settings tabs.
- Mouse and touch dragging, with the window kept inside the safe area.
- Responsive window dimensions and scrolling content for small displays.
- Minimize button and a floating **K** button to reopen.
- **Right Shift** toggles visibility on desktop when no text field has focus.
- Reduced motion and center-window settings.
- Close destroys the interface and disconnects its event handlers.
- Re-running the script replaces the previous instance.

This release contains the UI only. The Controls page is intentionally empty.

## Run

The complete interface is in `KaiJorHub.lua`; it does not download any UI libraries.

For Roblox Studio, paste the file into a **LocalScript** in **StarterPlayer > StarterPlayerScripts** and start a play test.

For a client script runner, paste the complete Lua file. It uses standard Roblox client APIs and parents its ScreenGui to LocalPlayer.PlayerGui. Compatibility with a specific Delta release has not been tested.

Settings are session-only. Closing the interface removes its floating button as well; run the script again to reopen it.

## Validation

Lua 5.4 syntax and mock-runtime checks cover tab switching, minimize/reopen, dragging, viewport resizing, keyboard visibility, centering, cleanup, and replacement on re-run. These checks do not substitute for a visual and input test in Roblox or Delta.
