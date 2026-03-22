---
url: https://code.claude.com/docs/en/cli-reference
crawled_at: 2026-03-15T04:29:57Z
---

[Skip to main content](#content-area)

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/cli-reference/docs/en/overview)

![US](https://d3gk2c5xim1je2.cloudfront.net/flags/US.svg)

English

Search...

⌘KAsk AI

* [Claude Developer Platform](https://platform.claude.com/)
* [Claude Code on the Web](https://claude.ai/code)
* [Claude Code on the Web](https://claude.ai/code)

Search...

Navigation

Reference

CLI reference

[Getting started](https://code.claude.com/docs/en/cli-reference/docs/en/overview)[Build with Claude Code](https://code.claude.com/docs/en/cli-reference/docs/en/sub-agents)[Deployment](https://code.claude.com/docs/en/cli-reference/docs/en/third-party-integrations)[Administration](https://code.claude.com/docs/en/cli-reference/docs/en/setup)[Configuration](https://code.claude.com/docs/en/cli-reference/docs/en/settings)[Reference](https://code.claude.com/docs/en/cli-reference/docs/en/cli-reference)[Resources](https://code.claude.com/docs/en/cli-reference/docs/en/legal-and-compliance)

##### Reference

* [CLI reference](https://code.claude.com/docs/en/cli-reference/docs/en/cli-reference)
* [Built-in commands](https://code.claude.com/docs/en/cli-reference/docs/en/commands)
* [Environment variables](https://code.claude.com/docs/en/cli-reference/docs/en/env-vars)
* [Tools reference](https://code.claude.com/docs/en/cli-reference/docs/en/tools-reference)
* [Interactive mode](https://code.claude.com/docs/en/cli-reference/docs/en/interactive-mode)
* [Checkpointing](https://code.claude.com/docs/en/cli-reference/docs/en/checkpointing)
* [Hooks reference](https://code.claude.com/docs/en/cli-reference/docs/en/hooks)
* [Plugins reference](https://code.claude.com/docs/en/cli-reference/docs/en/plugins-reference)

On this page

* [CLI commands](#cli-commands)
* [CLI flags](#cli-flags)
* [System prompt flags](#system-prompt-flags)
* [See also](#see-also)

Reference

# CLI reference

Copy page

Complete reference for Claude Code command-line interface, including commands and flags.

Copy page

## 

[​](#cli-commands)

CLI commands

You can start sessions, pipe content, resume conversations, and manage updates with these commands: 

| Command                       | Description                                                                                                                                                                                                                        | Example                                                |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| claude                        | Start interactive session                                                                                                                                                                                                          | claude                                                 |
| claude "query"                | Start interactive session with initial prompt                                                                                                                                                                                      | claude "explain this project"                          |
| claude -p "query"             | Query via SDK, then exit                                                                                                                                                                                                           | claude -p "explain this function"                      |
| cat file \| claude -p "query" | Process piped content                                                                                                                                                                                                              | cat logs.txt \| claude -p "explain"                    |
| claude -c                     | Continue most recent conversation in current directory                                                                                                                                                                             | claude -c                                              |
| claude -c -p "query"          | Continue via SDK                                                                                                                                                                                                                   | claude -c -p "Check for type errors"                   |
| claude -r "<session>" "query" | Resume session by ID or name                                                                                                                                                                                                       | claude -r "auth-refactor" "Finish this PR"             |
| claude update                 | Update to latest version                                                                                                                                                                                                           | claude update                                          |
| claude auth login             | Sign in to your Anthropic account. Use \--email to pre-fill your email address and \--sso to force SSO authentication                                                                                                              | claude auth login --email user@example.com --sso       |
| claude auth logout            | Log out from your Anthropic account                                                                                                                                                                                                | claude auth logout                                     |
| claude auth status            | Show authentication status as JSON. Use \--text for human-readable output. Exits with code 0 if logged in, 1 if not                                                                                                                | claude auth status                                     |
| claude agents                 | List all configured [subagents](https://code.claude.com/docs/en/cli-reference/docs/en/sub-agents), grouped by source                                                                                                                                                            | claude agents                                          |
| claude mcp                    | Configure Model Context Protocol (MCP) servers                                                                                                                                                                                     | See the [Claude Code MCP documentation](https://code.claude.com/docs/en/cli-reference/docs/en/mcp). |
| claude remote-control         | Start a [Remote Control](https://code.claude.com/docs/en/cli-reference/docs/en/remote-control) server to control Claude Code from Claude.ai or the Claude app. Runs in server mode (no local interactive session). See [Server mode flags](https://code.claude.com/docs/en/cli-reference/docs/en/remote-control#server-mode) | claude remote-control --name "My Project"              |

## 

[​](#cli-flags)

CLI flags

Customize Claude Code’s behavior with these command-line flags: 

| Flag                                  | Description                                                                                                                                                                                                                            | Example                                                                                          |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| \--add-dir                            | Add additional working directories for Claude to access (validates each path exists as a directory)                                                                                                                                    | claude --add-dir ../apps ../lib                                                                  |
| \--agent                              | Specify an agent for the current session (overrides the agent setting)                                                                                                                                                                 | claude --agent my-custom-agent                                                                   |
| \--agents                             | Define custom subagents dynamically via JSON. Uses the same field names as subagent [frontmatter](https://code.claude.com/docs/en/cli-reference/docs/en/sub-agents#supported-frontmatter-fields), plus a prompt field for the agent’s instructions                                  | claude --agents '{"reviewer":{"description":"Reviews code","prompt":"You are a code reviewer"}}' |
| \--allow-dangerously-skip-permissions | Enable permission bypassing as an option without immediately activating it. Allows composing with \--permission-mode (use with caution)                                                                                                | claude --permission-mode plan --allow-dangerously-skip-permissions                               |
| \--allowedTools                       | Tools that execute without prompting for permission. See [permission rule syntax](https://code.claude.com/docs/en/cli-reference/docs/en/settings#permission-rule-syntax) for pattern matching. To restrict which tools are available, use \--tools instead                          | "Bash(git log \*)" "Bash(git diff \*)" "Read"                                                    |
| \--append-system-prompt               | Append custom text to the end of the default system prompt                                                                                                                                                                             | claude --append-system-prompt "Always use TypeScript"                                            |
| \--append-system-prompt-file          | Load additional system prompt text from a file and append to the default prompt                                                                                                                                                        | claude --append-system-prompt-file ./extra-rules.txt                                             |
| \--betas                              | Beta headers to include in API requests (API key users only)                                                                                                                                                                           | claude --betas interleaved-thinking                                                              |
| \--chrome                             | Enable [Chrome browser integration](https://code.claude.com/docs/en/cli-reference/docs/en/chrome) for web automation and testing                                                                                                                                                    | claude --chrome                                                                                  |
| \--continue, \-c                      | Load the most recent conversation in the current directory                                                                                                                                                                             | claude --continue                                                                                |
| \--dangerously-skip-permissions       | Skip all permission prompts (use with caution)                                                                                                                                                                                         | claude --dangerously-skip-permissions                                                            |
| \--debug                              | Enable debug mode with optional category filtering (for example, "api,hooks" or "!statsig,!file")                                                                                                                                      | claude --debug "api,mcp"                                                                         |
| \--disable-slash-commands             | Disable all skills and commands for this session                                                                                                                                                                                       | claude --disable-slash-commands                                                                  |
| \--disallowedTools                    | Tools that are removed from the model’s context and cannot be used                                                                                                                                                                     | "Bash(git log \*)" "Bash(git diff \*)" "Edit"                                                    |
| \--effort                             | Set the [effort level](https://code.claude.com/docs/en/cli-reference/docs/en/model-config#adjust-effort-level) for the current session. Options: low, medium, high, max (Opus 4.6 only). Session-scoped and does not persist to settings                                            | claude --effort high                                                                             |
| \--fallback-model                     | Enable automatic fallback to specified model when default model is overloaded (print mode only)                                                                                                                                        | claude -p --fallback-model sonnet "query"                                                        |
| \--fork-session                       | When resuming, create a new session ID instead of reusing the original (use with \--resume or \--continue)                                                                                                                             | claude --resume abc123 --fork-session                                                            |
| \--from-pr                            | Resume sessions linked to a specific GitHub PR. Accepts a PR number or URL. Sessions are automatically linked when created via gh pr create                                                                                            | claude --from-pr 123                                                                             |
| \--ide                                | Automatically connect to IDE on startup if exactly one valid IDE is available                                                                                                                                                          | claude --ide                                                                                     |
| \--init                               | Run initialization hooks and start interactive mode                                                                                                                                                                                    | claude --init                                                                                    |
| \--init-only                          | Run initialization hooks and exit (no interactive session)                                                                                                                                                                             | claude --init-only                                                                               |
| \--include-partial-messages           | Include partial streaming events in output (requires \--print and \--output-format=stream-json)                                                                                                                                        | claude -p --output-format stream-json --include-partial-messages "query"                         |
| \--input-format                       | Specify input format for print mode (options: text, stream-json)                                                                                                                                                                       | claude -p --output-format json --input-format stream-json                                        |
| \--json-schema                        | Get validated JSON output matching a JSON Schema after agent completes its workflow (print mode only, see [structured outputs](https://platform.claude.com/docs/en/agent-sdk/structured-outputs))                                      | claude -p --json-schema '{"type":"object","properties":{...}}' "query"                           |
| \--maintenance                        | Run maintenance hooks and exit                                                                                                                                                                                                         | claude --maintenance                                                                             |
| \--max-budget-usd                     | Maximum dollar amount to spend on API calls before stopping (print mode only)                                                                                                                                                          | claude -p --max-budget-usd 5.00 "query"                                                          |
| \--max-turns                          | Limit the number of agentic turns (print mode only). Exits with an error when the limit is reached. No limit by default                                                                                                                | claude -p --max-turns 3 "query"                                                                  |
| \--mcp-config                         | Load MCP servers from JSON files or strings (space-separated)                                                                                                                                                                          | claude --mcp-config ./mcp.json                                                                   |
| \--model                              | Sets the model for the current session with an alias for the latest model (sonnet or opus) or a model’s full name                                                                                                                      | claude --model claude-sonnet-4-6                                                                 |
| \--name, \-n                          | Set a display name for the session, shown in /resume and the terminal title. You can resume a named session with claude --resume <name>. [/rename](https://code.claude.com/docs/en/cli-reference/docs/en/commands) changes the name mid-session and also shows it on the prompt bar | claude -n "my-feature-work"                                                                      |
| \--no-chrome                          | Disable [Chrome browser integration](https://code.claude.com/docs/en/cli-reference/docs/en/chrome) for this session                                                                                                                                                                 | claude --no-chrome                                                                               |
| \--no-session-persistence             | Disable session persistence so sessions are not saved to disk and cannot be resumed (print mode only)                                                                                                                                  | claude -p --no-session-persistence "query"                                                       |
| \--output-format                      | Specify output format for print mode (options: text, json, stream-json)                                                                                                                                                                | claude -p "query" --output-format json                                                           |
| \--permission-mode                    | Begin in a specified [permission mode](https://code.claude.com/docs/en/cli-reference/docs/en/permissions#permission-modes)                                                                                                                                                          | claude --permission-mode plan                                                                    |
| \--permission-prompt-tool             | Specify an MCP tool to handle permission prompts in non-interactive mode                                                                                                                                                               | claude -p --permission-prompt-tool mcp\_auth\_tool "query"                                       |
| \--plugin-dir                         | Load plugins from a directory for this session only. Each flag takes one path. Repeat the flag for multiple directories: \--plugin-dir A --plugin-dir B                                                                                | claude --plugin-dir ./my-plugins                                                                 |
| \--print, \-p                         | Print response without interactive mode (see [Agent SDK documentation](https://platform.claude.com/docs/en/agent-sdk/overview) for programmatic usage details)                                                                         | claude -p "query"                                                                                |
| \--remote                             | Create a new [web session](https://code.claude.com/docs/en/cli-reference/docs/en/claude-code-on-the-web) on claude.ai with the provided task description                                                                                                                            | claude --remote "Fix the login bug"                                                              |
| \--remote-control, \--rc              | Start an interactive session with [Remote Control](https://code.claude.com/docs/en/cli-reference/docs/en/remote-control#interactive-session) enabled so you can also control it from claude.ai or the Claude app. Optionally pass a name for the session                            | claude --remote-control "My Project"                                                             |
| \--resume, \-r                        | Resume a specific session by ID or name, or show an interactive picker to choose a session                                                                                                                                             | claude --resume auth-refactor                                                                    |
| \--session-id                         | Use a specific session ID for the conversation (must be a valid UUID)                                                                                                                                                                  | claude --session-id "550e8400-e29b-41d4-a716-446655440000"                                       |
| \--setting-sources                    | Comma-separated list of setting sources to load (user, project, local)                                                                                                                                                                 | claude --setting-sources user,project                                                            |
| \--settings                           | Path to a settings JSON file or a JSON string to load additional settings from                                                                                                                                                         | claude --settings ./settings.json                                                                |
| \--strict-mcp-config                  | Only use MCP servers from \--mcp-config, ignoring all other MCP configurations                                                                                                                                                         | claude --strict-mcp-config --mcp-config ./mcp.json                                               |
| \--system-prompt                      | Replace the entire system prompt with custom text                                                                                                                                                                                      | claude --system-prompt "You are a Python expert"                                                 |
| \--system-prompt-file                 | Load system prompt from a file, replacing the default prompt                                                                                                                                                                           | claude --system-prompt-file ./custom-prompt.txt                                                  |
| \--teleport                           | Resume a [web session](https://code.claude.com/docs/en/cli-reference/docs/en/claude-code-on-the-web) in your local terminal                                                                                                                                                         | claude --teleport                                                                                |
| \--teammate-mode                      | Set how [agent team](https://code.claude.com/docs/en/cli-reference/docs/en/agent-teams) teammates display: auto (default), in-process, or tmux. See [set up agent teams](https://code.claude.com/docs/en/cli-reference/docs/en/agent-teams#set-up-agent-teams)                                                                   | claude --teammate-mode in-process                                                                |
| \--tools                              | Restrict which built-in tools Claude can use. Use "" to disable all, "default" for all, or tool names like "Bash,Edit,Read"                                                                                                            | claude --tools "Bash,Edit,Read"                                                                  |
| \--verbose                            | Enable verbose logging, shows full turn-by-turn output                                                                                                                                                                                 | claude --verbose                                                                                 |
| \--version, \-v                       | Output the version number                                                                                                                                                                                                              | claude -v                                                                                        |
| \--worktree, \-w                      | Start Claude in an isolated [git worktree](https://code.claude.com/docs/en/cli-reference/docs/en/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees) at <repo>/.claude/worktrees/<name>. If no name is given, one is auto-generated                              | claude -w feature-auth                                                                           |

### 

[​](#system-prompt-flags)

System prompt flags

Claude Code provides four flags for customizing the system prompt. All four work in both interactive and non-interactive modes. 

| Flag                         | Behavior                                    | Example                                               |
| ---------------------------- | ------------------------------------------- | ----------------------------------------------------- |
| \--system-prompt             | Replaces the entire default prompt          | claude --system-prompt "You are a Python expert"      |
| \--system-prompt-file        | Replaces with file contents                 | claude --system-prompt-file ./prompts/review.txt      |
| \--append-system-prompt      | Appends to the default prompt               | claude --append-system-prompt "Always use TypeScript" |
| \--append-system-prompt-file | Appends file contents to the default prompt | claude --append-system-prompt-file ./style-rules.txt  |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. The append flags can be combined with either replacement flag. For most use cases, use an append flag. Appending preserves Claude Code’s built-in capabilities while adding your requirements. Use a replacement flag only when you need complete control over the system prompt. 

## 

[​](#see-also)

See also

* [Chrome extension](https://code.claude.com/docs/en/cli-reference/docs/en/chrome) \- Browser automation and web testing
* [Interactive mode](https://code.claude.com/docs/en/cli-reference/docs/en/interactive-mode) \- Shortcuts, input modes, and interactive features
* [Quickstart guide](https://code.claude.com/docs/en/cli-reference/docs/en/quickstart) \- Getting started with Claude Code
* [Common workflows](https://code.claude.com/docs/en/cli-reference/docs/en/common-workflows) \- Advanced workflows and patterns
* [Settings](https://code.claude.com/docs/en/cli-reference/docs/en/settings) \- Configuration options
* [Agent SDK documentation](https://platform.claude.com/docs/en/agent-sdk/overview) \- Programmatic usage and integrations

Was this page helpful?

YesNo

[Built-in commands](https://code.claude.com/docs/en/cli-reference/docs/en/commands)

⌘I

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/cli-reference/docs/en/overview)

[x](https://x.com/AnthropicAI)[linkedin](https://www.linkedin.com/company/anthropicresearch)

Company

[Anthropic](https://www.anthropic.com/company)[Careers](https://www.anthropic.com/careers)[Economic Futures](https://www.anthropic.com/economic-futures)[Research](https://www.anthropic.com/research)[News](https://www.anthropic.com/news)[Trust center](https://trust.anthropic.com/)[Transparency](https://www.anthropic.com/transparency)

Help and security

[Availability](https://www.anthropic.com/supported-countries)[Status](https://status.anthropic.com/)[Support center](https://support.claude.com/)

Learn

[Courses](https://www.anthropic.com/learn)[MCP connectors](https://claude.com/partners/mcp)[Customer stories](https://www.claude.com/customers)[Engineering blog](https://www.anthropic.com/engineering)[Events](https://www.anthropic.com/events)[Powered by Claude](https://claude.com/partners/powered-by-claude)[Service partners](https://claude.com/partners/services)[Startups program](https://claude.com/programs/startups)

Terms and policies

[Privacy policy](https://www.anthropic.com/legal/privacy)[Disclosure policy](https://www.anthropic.com/responsible-disclosure-policy)[Usage policy](https://www.anthropic.com/legal/aup)[Commercial terms](https://www.anthropic.com/legal/commercial-terms)[Consumer terms](https://www.anthropic.com/legal/consumer-terms)

Assistant

Responses are generated using AI and may contain mistakes.