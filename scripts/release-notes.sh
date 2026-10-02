#!/usr/bin/env bash
# release-notes.sh — generate release notes for the current git project with
# the claude CLI (headless) and write them into CHANGELOG.md in the project root.
#
# Usage: run from the project root (the /release-notes command does this),
#        e.g. my-new-project/.
#
# Requirements: git, jq, claude CLI, and either an OAuth session
# (`claude auth login`) or ANTHROPIC_API_KEY.
#
# Trust model: the agent edits CHANGELOG.md in the working tree as a
# suggestion. It never commits or pushes; review `git diff` afterwards.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$SCRIPT_DIR/../prompts/release-notes.md"
CHANGELOG="CHANGELOG.md"

# Pre-flight

for cmd in git jq claude; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: $cmd not found in PATH." >&2
    exit 1
  fi
done

if [[ -z "${ANTHROPIC_API_KEY:-}" ]] \
  && ! claude auth status --json 2>/dev/null | grep -q '"loggedIn": true'; then
  echo "ERROR: not authenticated to Claude." >&2
  echo "       Run 'claude auth login' or export ANTHROPIC_API_KEY." >&2
  exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "ERROR: prompt file missing: $PROMPT_FILE" >&2
  exit 1
fi

if [[ ! -d ".git" ]]; then
  echo "ERROR: run from the project root (a directory containing .git)." >&2
  exit 1
fi

if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "ERROR: repository has no commits." >&2
  exit 1
fi

# Commit range: since the latest tag, or the whole history if there are no tags yet.
if LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null)"; then
  RANGE="${LAST_TAG}..HEAD"
else
  LAST_TAG=""
  RANGE="HEAD"
fi

if [[ -z "$(git log "$RANGE" --no-merges --oneline)" ]]; then
  echo "Nothing to release: no commits in range '$RANGE'." >&2
  exit 0
fi

PROMPT="$(cat "$PROMPT_FILE")

## Run context

- Changelog file: \`$CHANGELOG\` ($([[ -f "$CHANGELOG" ]] && echo "exists" || echo "does not exist yet — create it"))
- Latest tag: ${LAST_TAG:-none (first release)}
- Commit range: \`$RANGE\`
- Today: $(date +%Y-%m-%d)"

# JSON schema — validated against Claude's final response

SCHEMA='{
  "type": "object",
  "properties": {
    "version":      {"type": "string"},
    "release_date": {"type": "string"},
    "sections": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "title": {"type": "string", "enum": ["Added", "Changed", "Fixed", "Removed"]},
          "items": {"type": "array", "items": {"type": "string"}}
        },
        "required": ["title", "items"]
      }
    }
  },
  "required": ["version", "release_date", "sections"]
}'

# Invoke Claude: it may run `git log`, and read/edit/create only CHANGELOG.md.
# --max-turns caps the loop: git log → Read → Edit/Write → optional re-Read.

RESPONSE="$(claude -p "$PROMPT" \
  --allowed-tools "Bash(git log *)" "Read($CHANGELOG)" "Edit($CHANGELOG)" "Write($CHANGELOG)" \
  --model claude-haiku-4-5 \
  --output-format json \
  --json-schema "$SCHEMA" \
  --max-turns 6)"

# Older CLI versions return one object, newer ones an array of messages; take the result entry.
RESULT_OBJ="$(echo "$RESPONSE" | jq -c '
  if type == "array"
  then (map(select(.type == "result")) | last // {})
  else .
  end
')"

COST="$(echo "$RESULT_OBJ" | jq -r '.total_cost_usd // "n/a"')"
DURATION="$(echo "$RESULT_OBJ" | jq -r '.duration_ms // "n/a"')"
TURNS="$(echo "$RESULT_OBJ" | jq -r '.num_turns // "n/a"')"
IS_ERROR="$(echo "$RESULT_OBJ" | jq -r '.is_error // false')"

echo "[claude] cost=\$${COST} duration=${DURATION}ms turns=${TURNS} is_error=${IS_ERROR}" >&2

if [[ "$IS_ERROR" == "true" ]]; then
  echo "[claude] agent reported an error — raw response below" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

# Schema-validated payload → stdout. `.structured_output` on 2.x+, JSON string in `.result` before.
echo "$RESULT_OBJ" | jq '
  if (.structured_output // null) != null
  then .structured_output
  else (.result as $r | try ($r | fromjson) catch $r)
  end
'

# Show what actually changed, independent of the JSON the agent returned.
echo >&2
echo "--- $CHANGELOG changes ---" >&2
if git ls-files --error-unmatch "$CHANGELOG" >/dev/null 2>&1; then
  git diff -- "$CHANGELOG" >&2 || true
  echo "[hint] reject: git restore $CHANGELOG" >&2
else
  cat "$CHANGELOG" >&2
  echo "[hint] reject: rm $CHANGELOG (new file)" >&2
fi
echo "[hint] accept: review, then commit manually." >&2
