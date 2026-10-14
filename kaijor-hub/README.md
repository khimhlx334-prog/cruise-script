# KaiJor Hub

A standalone Roblox client interface with a charcoal and violet theme. All interface text is English.

## Version 0.2.0

- Home, Controls, and Settings tabs.
- Mouse and touch dragging, with the window kept inside the safe area.
- Responsive window dimensions and scrolling content for small displays.
- Minimize button and a floating **K** button to reopen.
- **Right Shift** toggles visibility on desktop when no text field has focus.
- Reduced motion and center-window settings.
- Close destroys the interface and disconnects its event handlers.
- Re-running the script replaces the previous instance.
- A background session monitor starts once and reuses the same controller on re-run.
- Controls displays active time, sample count, place ID, character presence, and Start/Stop.
- The monitor samples every two seconds while the client runs, including after closing the UI.

The monitor reports local session state. It does not prevent Roblox account bans, detect Roblox anti-cheat, suppress reports, or change platform enforcement. It sends no network requests and changes no character behavior.

## Run

The complete interface is in `KaiJorHub.lua`; it does not download any UI libraries.

For Roblox Studio, paste the file into a **LocalScript** in **StarterPlayer > StarterPlayerScripts** and start a play test.

For a client script runner, paste the complete Lua file. It uses standard Roblox client APIs and parents its ScreenGui to LocalPlayer.PlayerGui. Compatibility with a specific Delta release has not been tested.

Settings are session-only. Closing the interface removes its floating button as well; run the script again to reopen it. The background monitor keeps running. Use **Controls > Stop monitor** before closing to stop it, or re-run the UI and stop it there. Leaving the game ends the session. A stopped monitor remains stopped when the UI is re-run; use **Start monitor** to resume.

## Validation

Lua 5.4 syntax and mock-runtime checks cover tab switching, minimize/reopen, dragging, viewport resizing, keyboard visibility, centering, UI cleanup, replacement on re-run, background sampling after UI closure, monitor stop/resume, and controller cleanup. These checks do not substitute for a visual and input test in Roblox or Delta.
