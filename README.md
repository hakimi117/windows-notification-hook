# windows-notification-hook

A [Claude Code](https://claude.com/claude-code) **skill** that installs a Windows desktop-notification hook.

Once installed, Claude Code pops a native Windows 10/11 notification when:

| Event | Message |
|-------|---------|
| A task finishes | 任务已完成 (Task completed) |
| A permission prompt appears | 需要权限审批 (Permission needed) |
| Claude is waiting for your input | 等待你的输入 (Waiting for input) |

The bundled `windows-notification.ps1` tries a Toast notification first and falls back to a
tray balloon, so it works across Windows 10/11 with no extra dependencies.

> **Note:** The skill is an *installer*. The notification itself is fired by a Claude Code
> **hook** (executed by the Claude Code runtime), which this skill sets up in your
> `~/.claude/settings.json`.

## Install

Clone this repo into your Claude Code skills directory:

```bash
git clone https://github.com/<your-username>/windows-notification-hook.git \
  "$HOME/.claude/skills/windows-notification-hook"
```

Then, in any Claude Code session, ask:

> 帮我安装 Windows 通知 hook

Claude will read the skill, copy the script to `~/.claude/hooks/`, and merge the hook into
`~/.claude/settings.json` (preserving your existing settings). Restart the session for the
hook to take effect.

## Customize

Edit the `-Message` text in the hook commands to change wording, or remove events you don't
want. See `SKILL.md` for details.

## Platform

Windows 10/11 only (PowerShell + WinRT toast APIs).

## License

MIT — see [LICENSE](LICENSE).
