---
name: windows-notification-hook
description: Use when the user wants desktop/toast notifications from Claude Code on Windows — pop a Windows notification when a task finishes, when a permission prompt appears, or when Claude is waiting for input — or wants to install/port this notification hook to another Windows machine.
---

# Windows Notification Hook

## Overview

Claude Code cannot pop OS notifications on its own — that is done by **hooks**, which the
Claude Code runtime (not the model) executes on lifecycle events. This skill installs a hook
that runs a bundled PowerShell script to show a native Windows 10/11 notification on three events:

| Event | Matcher | Message |
|-------|---------|---------|
| `Stop` | (none) | 任务已完成 (Task completed) |
| `Notification` | `permission_prompt` | 需要权限审批 (Permission needed) |
| `Notification` | `idle_prompt` | 等待你的输入 (Waiting for input) |

The script (`windows-notification.ps1`) tries a Toast notification first and falls back to a
tray balloon, so it works across Windows 10/11 without extra dependencies.

## When to Use

- User asks for desktop / toast / popup notifications from Claude Code on Windows
- User wants to be pinged when a long task finishes or when a permission prompt is waiting
- User wants to install or port this notification behavior to another Windows machine

Not for macOS/Linux — this is Windows-specific (PowerShell + WinRT toast APIs).

## Installation Steps

Perform these steps for the user. Paths use `~` = the user's home (e.g. `C:/Users/<name>`).

### 1. Copy the script into the hooks directory

Copy `windows-notification.ps1` (bundled next to this SKILL.md) to `~/.claude/hooks/windows-notification.ps1`.

```powershell
New-Item -ItemType Directory -Force "$HOME/.claude/hooks" | Out-Null
Copy-Item "<skill-dir>/windows-notification.ps1" "$HOME/.claude/hooks/windows-notification.ps1" -Force
```

Replace `<skill-dir>` with this skill's actual directory.

### 2. Merge the hooks into settings.json

Open `~/.claude/settings.json` (create it as `{}` if missing). **Preserve all existing keys** —
only add/replace the `Stop` and `Notification` entries under `hooks`. If the user already has
`hooks`, merge rather than overwrite; back the file up first (`settings.json.bak`).

The block to merge (adjust the absolute path to the user's actual home directory — the `-File`
path must be absolute, forward slashes are fine):

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -ExecutionPolicy Bypass -File 'C:/Users/<name>/.claude/hooks/windows-notification.ps1' -Title 'Claude Code' -Message '任务已完成'",
            "timeout": 10
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -ExecutionPolicy Bypass -File 'C:/Users/<name>/.claude/hooks/windows-notification.ps1' -Title 'Claude Code' -Message '需要权限审批'",
            "timeout": 10
          }
        ]
      },
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -ExecutionPolicy Bypass -File 'C:/Users/<name>/.claude/hooks/windows-notification.ps1' -Title 'Claude Code' -Message '等待你的输入'",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

Write `settings.json` back as **UTF-8** so the Chinese messages are not corrupted. Verify the
result is valid JSON.

### 3. Test the script directly

Confirm the notification fires before relying on the hook:

```powershell
powershell.exe -ExecutionPolicy Bypass -File "$HOME/.claude/hooks/windows-notification.ps1" -Title "Claude Code" -Message "测试通知"
```

A Windows notification should appear. Hooks reload on the next Claude Code session (or `/hooks`),
so tell the user to restart the session for the hook to take effect.

## Customizing

- **Change the wording:** edit the `-Message` text in each `command`.
- **Fewer events:** remove the `Stop` array or a `Notification` matcher you don't want.
- **English messages:** replace the Chinese strings (e.g. `Task completed`, `Permission needed`, `Waiting for input`).

## Common Mistakes

- **Overwriting existing hooks.** The user may already have other hooks — merge, don't clobber. Back up first.
- **Relative script path.** Hook `command` must use an **absolute** `-File` path; `~` is not expanded there.
- **Wrong home directory.** Do not hardcode another machine's username — resolve the current user's home.
- **Non-UTF-8 save.** Saving `settings.json` as UTF-16/ANSI corrupts the Chinese text and can break parsing.
- **Expecting an immediate effect.** Hook changes apply to new sessions; restart or re-run `/hooks`.
