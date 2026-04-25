# Alarm Clock

A simple alarm clock plugin for Noctalia Shell.

## Features

- **Multiple Alarms** — add as many alarms as you need, each with a custom label
- **Repeat** — optionally repeat alarms on selected days of the week
- **Bar Widget** — shows a bell icon and your next alarm time; pulses and shakes when ringing
- **Dismiss & Snooze** — dismiss or snooze a ringing alarm from the panel or via IPC
- **Toast Notifications** — get a toast notification when an alarm fires
- **IPC Control** — control alarms from keybindings or scripts

## Installation

Copy the `alarm-clock/` folder to:

```
~/.config/noctalia/plugins/alarm-clock/
```

Then register it in `~/.config/noctalia/plugins.json`:

```json
{
  "alarm-clock": {}
}
```

Restart Noctalia and enable the plugin in Settings → Plugins.

## IPC Commands

```
qs -c noctalia-shell ipc call plugin:alarm-clock <command>
```

| Command | Description |
|---------|-------------|
| `toggle` | Open or close the panel |
| `dismiss` | Stop the ringing alarm |
| `snooze` | Snooze the current alarm |
| `add <label> <hour> <minute>` | Add a one-time alarm |

### Keybind examples

**Hyprland** (`~/.config/hypr/hyprland.conf`):
```
bind = $mainMod, F9, exec, qs -c noctalia-shell ipc call plugin:alarm-clock toggle
bind = $mainMod, F10, exec, qs -c noctalia-shell ipc call plugin:alarm-clock dismiss
bind = $mainMod SHIFT, F10, exec, qs -c noctalia-shell ipc call plugin:alarm-clock snooze
```

**Niri** (`~/.config/niri/config.kdl`):
```kdl
binds {
  Mod+F9 { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "plugin:alarm-clock" "toggle"; }
  Mod+F10 { spawn "qs" "-c" "noctalia-shell" "ipc" "call" "plugin:alarm-clock" "dismiss"; }
}
```

## Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `snoozeMinutes` | `5` | Snooze duration in minutes |
| `soundEnabled` | `true` | Play sound when alarm rings |
| `notificationEnabled` | `true` | Show toast notification |

## Plugin Structure

```
alarm-clock/
├── manifest.json       ← plugin metadata
├── Main.qml            ← background logic, timer, IPC handler
├── BarWidget.qml       ← bar bell icon + next alarm time
├── Panel.qml           ← alarm list, add form, ringing banner
├── Settings.qml        ← settings UI
└── i18n/
    └── en.json         ← English strings
```

## Notes

- The alarm check runs every 10 seconds. Alarms are matched by hour:minute so they will trigger within a 10-second window.
- Active timer state is **not** persisted across Noctalia restarts (alarm schedules are saved, but the running clock state resets).
- Sound support requires the shell to expose a sound playback API; for now the plugin uses toast notifications only. Custom sound can be added by hooking a `Quickshell.Process` call in `Main.qml`.
