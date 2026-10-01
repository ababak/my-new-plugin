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
They assume a project layout like `my-new-project`: `docs/plans/_template.md`, `docs/adr/`, and `make lint` / `make test`.
- **plan** — creates `docs/plans/<slug>.md` from the template (goal, acceptance criteria, assumptions, ordered steps) and waits for confirmation before any code is written.
- **scaffold** — builds the next unchecked plan step layer by layer (domain, application, infrastructure, presentation) with tests, and ticks the step only when `make lint` and `make test` pass.
- **ship** — runs lint and tests, checks the plan against the code, sets `Status: done`, and commits only after explicit approval; on `feature-*` branches it also appends a line to `LOG.md`.

## Hooks
Logs are written to the plugin root (`$CLAUDE_PLUGIN_ROOT`, i.e. the cloned folder); `*.log` is git-ignored.
- **UserPromptSubmit** — `log-prompt.sh` appends a timestamp and the submitted prompt to `log-prompt.log`.
- **PreToolUse** — `log-tool.sh` appends the event, tool name and raw hook input to `log-tool.log`.
- **PreToolUse** (`Edit|Write|MultiEdit`) — `importlinter.py` applies the pending edit to a temp copy of the project layers (`domain`, `application`, `infrastructure`, `presentation`) and runs `lint-imports` via `uv`. The edit is blocked (exit 2) if it would add import-linter violations; edits that don't add new violations are allowed. Requires `uv` and import-linter contracts in the project's `pyproject.toml`. Results go to `importlinter.log`; the hook fails open on internal errors.

## License
MIT — see [LICENSE.md](LICENSE.md).
