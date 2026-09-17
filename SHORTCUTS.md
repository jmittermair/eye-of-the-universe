# Keyboard shortcuts

These are the bindings configured for `thestranger`, not a claim that every Mango
installation uses the same defaults. **Super** is the Windows/logo key. Letters
are shown uppercase for readability; only hold Shift where explicitly listed.
Mango calls workspaces **tags**. Open this reference with **Super+F1**; press `q`
to close the terminal pager.

## Applications and desktop

| Shortcut | Action |
| --- | --- |
| Super+Enter | Open Ghostty |
| Super+Space or Alt+Space | Toggle Noctalia's application launcher |
| Super+E | Open Files (Nautilus) |
| Super+B | Open Firefox |
| Super+F1 | Open this reference in Ghostty |
| Super+V | Pick an item from Cliphist and copy it to the clipboard |
| Print or Super+Shift+S | Select a screenshot region and annotate it in Satty |

In Noctalia's launcher, type to search, use Up/Down to select, Enter to activate, and Escape to
close. The clipboard picker uses Noctalia's dmenu interface to select a Cliphist
entry and copy it; paste it into your app
normally. Escape cancels screenshot region selection. Saved screenshots go to
`~/Pictures/Screenshots/`.

## Windows and layouts

| Shortcut | Action |
| --- | --- |
| Super+H / J / K / L | Focus left / down / up / right |
| Super+Tab | Focus the next window in the stack |
| Super+Shift+Tab | Focus the previous window in the stack |
| Super+Shift+Arrow | Swap the focused window with its neighbour in that direction |
| Super+Ctrl+Left / Right | Shrink / grow window width by 50 pixels |
| Super+Ctrl+Up / Down | Shrink / grow window height by 50 pixels |
| Super+F | Toggle fullscreen |
| Super+Shift+Space | Toggle floating |
| Super+Backslash (`\`) | Cycle Mango layouts |
| Super+O | Toggle Mango's window overview |
| Super+M | Minimise the focused window |
| Super+Shift+M | Restore a minimised window |
| Super+Q | Close the focused window |

Keyboard resizing is intended for floating windows; tiled geometry is controlled
by the active layout. Workspaces start in the tile layout. Window swapping uses
arrow keys so that **Super+Shift+L** remains the lock shortcut.

## Workspaces and monitors

| Shortcut | Action |
| --- | --- |
| Super+1…9 | Switch to workspace 1…9 |
| Super+Shift+1…9 | Move the focused window to workspace 1…9 and follow it |
| Super+Ctrl+Shift+1…9 | Move the window to workspace 1…9 without following it |
| Super+Left / Right | Switch to the previous / next workspace |
| Super+Alt+Left / Right | Focus the monitor to the left / right |
| Super+Alt+Shift+Left / Right | Send the focused window to the monitor to the left / right |

Monitor shortcuts follow the monitor arrangement configured in Mango; they need
another connected display in that direction.

## Noctalia, focus and session

| Shortcut | Action |
| --- | --- |
| Super+Comma (`,`) | Toggle Noctalia's control centre |
| Super+N | Toggle the control centre's notifications page |
| Super+A | Toggle the control centre's audio page |
| Super+Ctrl+N | Dismiss currently active notification popups |
| Super+Shift+D | Toggle notification do-not-disturb (focus mode) |
| Super+Escape | Toggle Noctalia's session menu |
| Super+Shift+L | Lock immediately with Swaylock |
| Super+Shift+R | Reload Mango's configuration |
| Super+Shift+E | **Log out immediately** by quitting Mango |

Use the session menu when you want to choose an action interactively. Save work
before logging out. Dismissing active notifications does not clear their stored
history. Focus mode suppresses notification interruptions; it does not change
gammastep's scheduled colour temperature.

Waybar provides the bar, Cliphist the clipboard history, awww the wallpaper and
gammastep the night colour adjustment. Noctalia shortcuts deliberately target its
active desktop services rather than enabling duplicate ones.

## Laptop keys

| Key | Action |
| --- | --- |
| Volume up / down | Adjust output volume by 5%, capped at 100% |
| Speaker mute | Toggle output mute |
| Microphone mute | Toggle microphone mute |
| Brightness up / down | Adjust backlight by 5% |
| Play/pause | Toggle media playback |
| Next / previous track | Skip forward / back |

Depending on Fn-lock, hold **Fn** to send these media keys. `wev` can identify
the key symbols emitted by your keyboard.

## Mouse and bar controls

| Gesture | Action |
| --- | --- |
| Super+left-button drag | Move a window |
| Super+right-button drag | Resize a window |
| Click a Waybar task icon | Activate that window |
| Middle-click a Waybar task icon | Close that window |
| Click Waybar's idle-inhibitor icon | Toggle inhibition of idle locking |
| Click Waybar's volume indicator | Open audio controls (Pavucontrol) |
| Click Waybar's launcher / control icon | Open Noctalia launcher / control centre |

Idle inhibition does not replace the explicit lock shortcut or the lock before
sleep. Swayidle normally locks after ten minutes.

## Changing bindings

Edit `wayland.windowManager.mango.settings.bind` in
[`modules/features/desktop.nix`](modules/features/desktop.nix) and update this file
together. Apply with `nh os switch`, then press **Super+Shift+R**. The Super+F1
reference is a Nix-store copy of this file and updates with the rebuild.

The choices use familiar tiling-compositor conventions and commands verified
against the pinned [Mango sources](https://github.com/mangowm/mango/tree/d4b1e49fcbfd14e62acec4e9a0d895230f25da8f/src)
and [Noctalia v5 IPC schema](https://github.com/noctalia-dev/noctalia/blob/e4eb0ff97743c1d07d0f5a0d5770b277b6485b03/src/cli/schema_msg.h).
