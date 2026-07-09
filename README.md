# windows-notification (Claude Code plugin)

A [Claude Code](https://claude.com/claude-code) **plugin** that pops a native Windows 10/11
desktop notification on key events — no manual setup, the hook activates automatically once the
plugin is enabled.

| Event | Fires when | Message |
|-------|-----------|---------|
| `Stop` | Claude finishes a response (task done) | 任务已完成 (Task completed) |
| `Notification` / `permission_prompt` | A permission prompt appears | 需要权限审批 (Permission needed) |
| `Notification` / `idle_prompt` | Claude is waiting and you've been idle | 等待你的输入 (Waiting for input) |

The bundled `windows-notification.ps1` tries a Toast notification first and falls back to a tray
balloon, so it works across Windows 10/11 with no extra dependencies. The hook references the
script via `${CLAUDE_PLUGIN_ROOT}`, so there are no hard-coded user paths.

## Install (one-click)

In any Claude Code session:

```
/plugin marketplace add hakimi117/windows-notification-hook
/plugin install windows-notification@hakimi-plugins
```

Then restart the session (or run `/hooks`) for the hook to take effect. You do **not** need to
edit `settings.json` yourself.

Manage it later with:

```
/plugin disable windows-notification@hakimi-plugins
/plugin enable  windows-notification@hakimi-plugins
```

## Repository layout (marketplace monorepo)

```
.
├── .claude-plugin/
│   └── marketplace.json                 # marketplace catalog
└── plugins/
    └── windows-notification/
        ├── .claude-plugin/
        │   └── plugin.json              # plugin manifest
        ├── hooks/
        │   └── hooks.json               # auto-activating hook definition
        └── windows-notification.ps1     # the notification script
```

## Customize

Edit the `-Message` text in `plugins/windows-notification/hooks/hooks.json` to change wording, or
remove events you don't want. Bump `version` in `marketplace.json` and `plugin.json`, commit, and
push; users update with `/plugin marketplace update hakimi-plugins`.

## Platform

Windows 10/11 only (PowerShell + WinRT toast APIs).

## License

MIT — see [LICENSE](LICENSE).
