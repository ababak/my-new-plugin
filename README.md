# ab plugin

## Purpose
To learn how to create Claude Code plugins from scratch.

## Requirements
- `jq` — used by `log-prompt.sh` and `log-tool.sh` (without it they log raw input / `unknown`).
- `uv` and `python3` — used by the `importlinter.py` hook.

## Install
The plugin runs directly from its cloned folder:
```bash
git clone https://github.com/ababak/my-new-plugin.git
```

### Claude Code
Plugin only lives for this session:
```bash
claude --plugin-dir /path/to/my-new-plugin
```

### VS Code (Copilot)
Add the cloned folder to the **user** `settings.json` (`chat.pluginLocations` is machine-scoped, so the workspace file ignores it; the workspace must be trusted):
```json
"chat.pluginLocations": {
    "/path/to/my-new-plugin": true
}
```
Then reload the window and check Extensions → `@agentPlugins` → Installed.

## Commands
—

## Skills
- **version-up** — triggered when you ask Claude to bump the version number. It opens `resource/version.yml` in the current project (not in the plugin), increments the minor version (skipping 13), and saves the file.

## Hooks
Logs are written to the plugin root (`$CLAUDE_PLUGIN_ROOT`, i.e. the cloned folder); `*.log` is git-ignored.
- **UserPromptSubmit** — `log-prompt.sh` appends a timestamp and the submitted prompt to `log-prompt.log`.
- **PreToolUse** — `log-tool.sh` appends the event, tool name and raw hook input to `log-tool.log`.
- **PreToolUse** (`Edit|Write|MultiEdit`) — `importlinter.py` applies the pending edit to a temp copy of the project layers (`domain`, `application`, `infrastructure`, `presentation`) and runs `lint-imports` via `uv`. The edit is blocked (exit 2) if it would add import-linter violations; edits that don't add new violations are allowed. Requires `uv` and import-linter contracts in the project's `pyproject.toml`. Results go to `importlinter.log`; the hook fails open on internal errors.
