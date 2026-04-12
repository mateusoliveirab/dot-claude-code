#!/usr/bin/env bash
# bash-fail-guard.sh
# PostToolUse hook — detects consecutive Bash failures and injects diagnostic hints.
#
# Combines two strategies:
#   1. Consecutive failure counter: after N failures, inject an intervention message
#   2. Error class detector: categorize the failure type to guide diagnosis
#
# Output: JSON with "hookSpecificOutput.feedback" when threshold is reached.
# State: /tmp/.claude_fail_guard_<SESSION_ID> (reset on any success)

set -euo pipefail

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)

# ── Extract fields ────────────────────────────────────────────────────────────

EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_response.exit_code // empty')
OUTPUT=$(echo "$INPUT"   | jq -r '.tool_response.output // empty')

# Reset counter on success
if [[ "$EXIT_CODE" == "0" || -z "$EXIT_CODE" ]]; then
  SESSION="${CLAUDE_SESSION_ID:-default}"
  rm -f "/tmp/.claude_fail_guard_${SESSION}"
  exit 0
fi

# ── State: consecutive failure count ─────────────────────────────────────────

SESSION="${CLAUDE_SESSION_ID:-default}"
STATE_FILE="/tmp/.claude_fail_guard_${SESSION}"

COUNT=0
if [[ -f "$STATE_FILE" ]]; then
  COUNT=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
fi
COUNT=$((COUNT + 1))
echo "$COUNT" > "$STATE_FILE"

THRESHOLD=3

if [[ "$COUNT" -lt "$THRESHOLD" ]]; then
  exit 0
fi

# ── Error class detector ──────────────────────────────────────────────────────
# Each block maps a broad error class to a diagnostic direction — not a specific fix.

HINTS=""

# Class: missing dependency (any package manager / language)
if echo "$OUTPUT" | grep -qiE "no module named|cannot find module|module not found|package .* not found|command not found|no such file or directory.*bin|is not installed"; then
  MISSING=$(echo "$OUTPUT" | grep -oiE "no module named '[^']+'|cannot find module '[^']+'|'[^']+' is not installed" | head -1)
  HINTS+="- Missing dependency${MISSING:+: $MISSING}. Check if the package is declared and installed in the current environment (venv, node_modules, PATH).\n"
fi

# Class: wrong environment / runtime mismatch
if echo "$OUTPUT" | grep -qiE "wrong python|no such interpreter|version .* required|engine.*node.*required|requires python|incompatible"; then
  HINTS+="- Environment mismatch. Verify the runtime version and that you are running inside the correct virtual environment or container.\n"
fi

# Class: configuration missing or invalid
if echo "$OUTPUT" | grep -qiE "config.*not found|missing.*config|invalid.*config|no.*configuration|settings.*not found|\.env.*not found"; then
  HINTS+="- Configuration issue. Check that required config files or environment variables are present and valid.\n"
fi

# Class: syntax / compilation error
if echo "$OUTPUT" | grep -qiE "syntaxerror|syntax error|parse error|unexpected token|compilation failed|error TS[0-9]+|build failed"; then
  HINTS+="- Syntax or compilation error. Fix the reported issue in source before re-running — retrying without a change will produce the same result.\n"
fi

# Class: test framework / runner setup
if echo "$OUTPUT" | grep -qiE "no tests ran|collected 0 items|plugin.*not found|async.*not natively supported|suitable plugin|fixture.*not found"; then
  HINTS+="- Test runner setup issue. Check framework plugins, fixtures, and configuration (e.g. asyncio mode, test discovery paths).\n"
fi

# Class: permission / filesystem
if echo "$OUTPUT" | grep -qiE "permission denied|access denied|operation not permitted|read-only file system"; then
  HINTS+="- Permission or filesystem error. Check file ownership, execute bits, and whether the target path is writable.\n"
fi

# Class: network / service unavailable
if echo "$OUTPUT" | grep -qiE "connection refused|could not connect|network unreachable|timeout|ECONNREFUSED|name or service not known"; then
  HINTS+="- Network or service error. Check that the target service is running and reachable before retrying.\n"
fi

# Class: authentication / credentials
if echo "$OUTPUT" | grep -qiE "unauthorized|403|401|invalid.*token|authentication failed|credentials.*invalid|api key"; then
  HINTS+="- Authentication failure. Verify credentials, API keys, or tokens are correctly set and not expired.\n"
fi

# ── Compose feedback message ──────────────────────────────────────────────────

HINT_BLOCK=""
if [[ -n "$HINTS" ]]; then
  HINT_BLOCK=$(printf "\n\nDetected error class(es):\n%b" "$HINTS")
fi

MESSAGE="[bash-fail-guard] ${COUNT} consecutive Bash failures in this session. Stop and diagnose before retrying the same command.${HINT_BLOCK}
Consider: /codex:rescue if the problem persists."

# ── Output JSON feedback ──────────────────────────────────────────────────────

jq -n --arg msg "$MESSAGE" '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "feedback": $msg
  }
}'
