# Run Claude Code Programmatically (Agent SDK / Headless Mode)

> Source: https://code.claude.com/docs/en/headless
> Captured: 2026-03-22

> **Note:** The CLI was previously called "headless mode." The `-p` flag and all CLI options work the same way.

## Overview

The [Agent SDK](https://platform.claude.com/docs/en/agent-sdk/overview) gives you the same tools, agent loop, and context management that power Claude Code. Available as:
- A **CLI** for scripts and CI/CD (`claude -p`)
- **Python** and **TypeScript** packages for full programmatic control

## Basic Usage

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

All [CLI options](/en/cli-reference) work with `-p`, including:
- `--continue` — continue conversations
- `--allowedTools` — auto-approve tools
- `--output-format` — structured output

```bash
# Simple question about codebase
claude -p "What does the auth module do?"
```

## Bare Mode (`--bare`)

Reduces startup time by skipping auto-discovery of hooks, skills, plugins, MCP servers, auto memory, and CLAUDE.md.

**Use for:** CI and scripts where you need the same result on every machine.

```bash
claude --bare -p "Summarize this file" --allowedTools "Read"
```

In bare mode, Claude has access to Bash, file read, and file edit tools. Pass context explicitly:

| To load                 | Use                                                     |
| ----------------------- | ------------------------------------------------------- |
| System prompt additions | `--append-system-prompt`, `--append-system-prompt-file` |
| Settings                | `--settings <file-or-json>`                             |
| MCP servers             | `--mcp-config <file-or-json>`                           |
| Custom agents           | `--agents <json>`                                       |
| A plugin directory      | `--plugin-dir <path>`                                   |

Bare mode skips OAuth and keychain reads. Auth must come from `ANTHROPIC_API_KEY` or `apiKeyHelper` in `--settings` JSON.

> `--bare` will become the default for `-p` in a future release.

## Structured Output

Use `--output-format`:
- `text` (default): plain text
- `json`: structured JSON with result, session ID, metadata
- `stream-json`: newline-delimited JSON for real-time streaming

```bash
# JSON output
claude -p "Summarize this project" --output-format json

# JSON with schema validation
claude -p "Extract the main function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'

# Extract specific fields with jq
claude -p "Summarize this project" --output-format json | jq -r '.result'
```

## Streaming Responses

```bash
claude -p "Explain recursion" --output-format stream-json --verbose --include-partial-messages

# Filter text deltas only
claude -p "Write a poem" --output-format stream-json --verbose --include-partial-messages | \
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text'
```

### API Retry Events

When an API request fails, Claude Code emits a `system/api_retry` event. Fields:

| Field            | Type            | Description                                                                         |
| ---------------- | --------------- | ----------------------------------------------------------------------------------- |
| `type`           | `"system"`      | message type                                                                        |
| `subtype`        | `"api_retry"`   | identifies retry event                                                              |
| `attempt`        | integer         | current attempt, starting at 1                                                      |
| `max_retries`    | integer         | total retries permitted                                                             |
| `retry_delay_ms` | integer         | milliseconds until next attempt                                                     |
| `error_status`   | integer or null | HTTP status code, or `null` for connection errors                                   |
| `error`          | string          | category: `authentication_failed`, `billing_error`, `rate_limit`, etc.              |
| `uuid`           | string          | unique event identifier                                                             |
| `session_id`     | string          | session the event belongs to                                                        |

## Auto-Approve Tools

```bash
claude -p "Run the test suite and fix any failures" \
  --allowedTools "Bash,Read,Edit"
```

### Create a Commit

```bash
claude -p "Look at my staged changes and create an appropriate commit" \
  --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"
```

The `Bash(git diff *)` syntax uses [permission rule syntax](/en/settings#permission-rule-syntax). The trailing ` *` enables prefix matching. The space before `*` is important: without it, `Bash(git diff*)` would also match `git diff-index`.

> User-invoked skills like `/commit` and built-in commands are **only available in interactive mode**. In `-p` mode, describe the task instead.

## Customize the System Prompt

```bash
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json
```

See [system prompt flags](/en/cli-reference#system-prompt-flags) for `--system-prompt` to fully replace the default.

## Continue Conversations

```bash
# First request
claude -p "Review this codebase for performance issues"

# Continue most recent
claude -p "Now focus on the database queries" --continue
claude -p "Generate a summary of all issues found" --continue

# Resume specific session
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

## Next Steps

- [Agent SDK quickstart](https://platform.claude.com/docs/en/agent-sdk/quickstart)
- [CLI reference](/en/cli-reference)
- [GitHub Actions](/en/github-actions)
- [GitLab CI/CD](/en/gitlab-ci-cd)
