# Hooks Guide — Automate Workflows with Hooks

> Source: https://code.claude.com/docs/en/hooks-guide
> Captured: 2026-03-22

> See also: `hooks.md` for the full reference (event schemas, JSON formats, advanced features).

## Overview

Hooks are user-defined shell commands that execute at specific points in Claude Code's lifecycle. They provide **deterministic control** — certain actions always happen rather than relying on the LLM to choose to run them.

**Hook types:**
- `command` — shell command (most common)
- `http` — POST event data to a URL
- `prompt` — single-turn LLM evaluation for judgment-based decisions
- `agent` — multi-turn verification with tool access

## Hook Events

| Event                | When it fires                                                                             |
| -------------------- | ----------------------------------------------------------------------------------------- |
| `SessionStart`       | When a session begins or resumes                                                          |
| `UserPromptSubmit`   | When you submit a prompt, before Claude processes it                                      |
| `PreToolUse`         | Before a tool call executes. Can block it                                                 |
| `PermissionRequest`  | When a permission dialog appears                                                          |
| `PostToolUse`        | After a tool call succeeds                                                                |
| `PostToolUseFailure` | After a tool call fails                                                                   |
| `Notification`       | When Claude Code sends a notification                                                     |
| `SubagentStart`      | When a subagent is spawned                                                                |
| `SubagentStop`       | When a subagent finishes                                                                  |
| `Stop`               | When Claude finishes responding                                                            |
| `StopFailure`        | When the turn ends due to an API error. Output and exit code are ignored                  |
| `TeammateIdle`       | When an agent team teammate is about to go idle                                           |
| `TaskCompleted`      | When a task is being marked as completed                                                  |
| `InstructionsLoaded` | When a CLAUDE.md or `.claude/rules/*.md` file is loaded into context                     |
| `ConfigChange`       | When a configuration file changes during a session                                        |
| `WorktreeCreate`     | When a worktree is being created via `--worktree` or `isolation: "worktree"`              |
| `WorktreeRemove`     | When a worktree is being removed                                                          |
| `PreCompact`         | Before context compaction                                                                 |
| `PostCompact`        | After context compaction completes                                                        |
| `Elicitation`        | When an MCP server requests user input during a tool call                                 |
| `ElicitationResult`  | After a user responds to an MCP elicitation, before response is sent back                |
| `SessionEnd`         | When a session terminates                                                                 |

## Common Use Cases

### 1. Desktop Notification (Notification event)

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

Linux: `notify-send 'Claude Code' 'Claude Code needs your attention'`
Windows: `powershell.exe -Command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('Claude Code needs your attention', 'Claude Code')"`

### 2. Auto-Format Code After Edits (PostToolUse)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

### 3. Block Edits to Protected Files (PreToolUse, exit code 2)

Script `.claude/hooks/protect-files.sh`:
```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
PROTECTED_PATTERNS=(".env" "package-lock.json" ".git/")
for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: $FILE_PATH matches protected pattern '$pattern'" >&2
    exit 2
  fi
done
exit 0
```

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh" }]
      }
    ]
  }
}
```

### 4. Re-inject Context After Compaction (SessionStart, compact matcher)

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: use Bun, not npm. Run bun test before committing. Current sprint: auth refactor.'"
          }
        ]
      }
    ]
  }
}
```

> For injecting context on every session start, use CLAUDE.md instead.

### 5. Audit Configuration Changes (ConfigChange)

```json
{
  "hooks": {
    "ConfigChange": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "jq -c '{timestamp: now | todate, source: .source, file: .file_path}' >> ~/claude-config-audit.log"
          }
        ]
      }
    ]
  }
}
```

### 6. Auto-Approve Specific Permission Prompts (PermissionRequest)

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "ExitPlanMode",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"hookSpecificOutput\": {\"hookEventName\": \"PermissionRequest\", \"decision\": {\"behavior\": \"allow\"}}}'"
          }
        ]
      }
    ]
  }
}
```

To set a specific permission mode via hook:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedPermissions": [
        { "type": "setMode", "mode": "acceptEdits", "destination": "session" }
      ]
    }
  }
}
```

## Exit Codes

| Code | Behavior |
| ---- | -------- |
| 0    | Action proceeds. For `UserPromptSubmit`/`SessionStart`: stdout added to Claude's context |
| 2    | Action blocked. Stderr sent to Claude as feedback |
| Any other | Action proceeds. Stderr logged but not shown to Claude |

## Structured JSON Output (exit 0)

For `PreToolUse`:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use rg instead of grep for better performance"
  }
}
```

`permissionDecision` options: `"allow"`, `"deny"`, `"ask"`

> `"allow"` skips the interactive prompt but does NOT override permission rules. Deny rules from managed settings always take precedence.

## Matchers

| Event | Matcher filters | Example values |
| ----- | --------------- | -------------- |
| `PreToolUse`, `PostToolUse`, `PermissionRequest` | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | how session started | `startup`, `resume`, `clear`, `compact` |
| `SessionEnd` | why session ended | `clear`, `resume`, `logout`, `prompt_input_exit`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success` |
| `SubagentStart/Stop` | agent type | `Bash`, `Explore`, `Plan`, custom names |
| `PreCompact`, `PostCompact` | trigger | `manual`, `auto` |
| `ConfigChange` | config source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `billing_error`, etc. |
| `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCompleted`, `WorktreeCreate/Remove` | no matcher support | always fires |

MCP tool naming: `mcp__<server>__<tool>` (e.g., `mcp__github__search_repositories`).

## Hook Scope / Location

| Location | Scope | Shareable |
| -------- | ----- | --------- |
| `~/.claude/settings.json` | All projects | No (local machine) |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes (bundled) |
| Skill or agent frontmatter | While active | Yes (in component file) |

## Prompt-Based Hooks (`type: "prompt"`)

For judgment-based decisions. Model (Haiku by default) returns yes/no:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if all tasks are complete. If not, respond with {\"ok\": false, \"reason\": \"what remains to be done\"}."
          }
        ]
      }
    ]
  }
}
```

Response format:
- `"ok": true` → action proceeds
- `"ok": false` → blocked; `reason` fed back to Claude

## Agent-Based Hooks (`type: "agent"`)

When verification requires inspecting files or running commands. Spawns a subagent with tool access.

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Verify that all unit tests pass. Run the test suite and check the results.",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

- Default timeout: 60s
- Up to 50 tool-use turns
- Same `"ok"` / `"reason"` format as prompt hooks

## HTTP Hooks (`type: "http"`)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "http",
            "url": "http://localhost:8080/hooks/tool-use",
            "headers": {
              "Authorization": "Bearer $MY_TOKEN"
            },
            "allowedEnvVars": ["MY_TOKEN"]
          }
        ]
      }
    ]
  }
}
```

- Endpoint receives same JSON as command hook would receive on stdin
- Returns results through HTTP response body (same JSON format)
- HTTP status codes alone **cannot block** actions — use response body
- Header values support `$VAR_NAME` interpolation (only vars in `allowedEnvVars` are resolved)

## Limitations

- Command hooks communicate through stdout/stderr/exit codes only — cannot trigger tool calls directly
- Default timeout: 10 minutes (configurable per hook with `timeout` field in seconds)
- `PostToolUse` hooks cannot undo actions (tool already executed)
- `PermissionRequest` hooks do NOT fire in non-interactive mode (`-p`) — use `PreToolUse` instead
- `Stop` hooks fire whenever Claude finishes responding (not only at task completion); don't fire on user interrupts

## Troubleshooting

### Hook Not Firing
- Run `/hooks` to confirm hook appears under the correct event
- Check matcher is case-sensitive and matches the tool name exactly
- `PermissionRequest` hooks don't work in `-p` mode — use `PreToolUse`

### Infinite Loop (Stop Hook)
Parse `stop_hook_active` from input and exit early if `true`:
```bash
#!/bin/bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi
```

### JSON Validation Failed
Shell profile `echo` statements contaminate hook stdout. Wrap in interactive check:
```bash
# In ~/.zshrc or ~/.bashrc
if [[ $- == *i* ]]; then
  echo "Shell ready"
fi
```

### Debug
- Toggle verbose mode: `Ctrl+O`
- Full execution details: `claude --debug`
