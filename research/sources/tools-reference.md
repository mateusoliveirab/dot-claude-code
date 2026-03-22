---
url: https://code.claude.com/docs/en/tools-reference
crawled_at: 2026-03-15T04:29:57Z
---

[Skip to main content](#content-area)

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/tools-reference/docs/en/overview)

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

Tools reference

[Getting started](https://code.claude.com/docs/en/tools-reference/docs/en/overview)[Build with Claude Code](https://code.claude.com/docs/en/tools-reference/docs/en/sub-agents)[Deployment](https://code.claude.com/docs/en/tools-reference/docs/en/third-party-integrations)[Administration](https://code.claude.com/docs/en/tools-reference/docs/en/setup)[Configuration](https://code.claude.com/docs/en/tools-reference/docs/en/settings)[Reference](https://code.claude.com/docs/en/tools-reference/docs/en/cli-reference)[Resources](https://code.claude.com/docs/en/tools-reference/docs/en/legal-and-compliance)

##### Reference

* [CLI reference](https://code.claude.com/docs/en/tools-reference/docs/en/cli-reference)
* [Built-in commands](https://code.claude.com/docs/en/tools-reference/docs/en/commands)
* [Environment variables](https://code.claude.com/docs/en/tools-reference/docs/en/env-vars)
* [Tools reference](https://code.claude.com/docs/en/tools-reference/docs/en/tools-reference)
* [Interactive mode](https://code.claude.com/docs/en/tools-reference/docs/en/interactive-mode)
* [Checkpointing](https://code.claude.com/docs/en/tools-reference/docs/en/checkpointing)
* [Hooks reference](https://code.claude.com/docs/en/tools-reference/docs/en/hooks)
* [Plugins reference](https://code.claude.com/docs/en/tools-reference/docs/en/plugins-reference)

On this page

* [Bash tool behavior](#bash-tool-behavior)
* [See also](#see-also)

Reference

# Tools reference

Copy page

Complete reference for the tools Claude Code can use, including permission requirements.

Copy page

Claude Code has access to a set of tools that help it understand and modify your codebase. The tool names below are the exact strings you use in [permission rules](https://code.claude.com/docs/en/tools-reference/docs/en/permissions#tool-specific-permission-rules), [subagent tool lists](https://code.claude.com/docs/en/tools-reference/docs/en/sub-agents), and [hook matchers](https://code.claude.com/docs/en/tools-reference/docs/en/hooks). 

| Tool                 | Description                                                                                                                                                                                                                                                                                                                                                                      | Permission Required |
| -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| Agent                | Spawns a [subagent](https://code.claude.com/docs/en/tools-reference/docs/en/sub-agents) with its own context window to handle a task                                                                                                                                                                                                                                                                                            | No                  |
| AskUserQuestion      | Asks multiple-choice questions to gather requirements or clarify ambiguity                                                                                                                                                                                                                                                                                                       | No                  |
| Bash                 | Executes shell commands in your environment. See [Bash tool behavior](#bash-tool-behavior)                                                                                                                                                                                                                                                                                       | Yes                 |
| CronCreate           | Schedules a recurring or one-shot prompt within the current session (gone when Claude exits). See [scheduled tasks](https://code.claude.com/docs/en/tools-reference/docs/en/scheduled-tasks)                                                                                                                                                                                                                                    | No                  |
| CronDelete           | Cancels a scheduled task by ID                                                                                                                                                                                                                                                                                                                                                   | No                  |
| CronList             | Lists all scheduled tasks in the session                                                                                                                                                                                                                                                                                                                                         | No                  |
| Edit                 | Makes targeted edits to specific files                                                                                                                                                                                                                                                                                                                                           | Yes                 |
| EnterPlanMode        | Switches to plan mode to design an approach before coding                                                                                                                                                                                                                                                                                                                        | No                  |
| EnterWorktree        | Creates an isolated [git worktree](https://code.claude.com/docs/en/tools-reference/docs/en/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees) and switches into it                                                                                                                                                                                                                                          | No                  |
| ExitPlanMode         | Presents a plan for approval and exits plan mode                                                                                                                                                                                                                                                                                                                                 | Yes                 |
| ExitWorktree         | Exits a worktree session and returns to the original directory                                                                                                                                                                                                                                                                                                                   | No                  |
| Glob                 | Finds files based on pattern matching                                                                                                                                                                                                                                                                                                                                            | No                  |
| Grep                 | Searches for patterns in file contents                                                                                                                                                                                                                                                                                                                                           | No                  |
| ListMcpResourcesTool | Lists resources exposed by connected [MCP servers](https://code.claude.com/docs/en/tools-reference/docs/en/mcp)                                                                                                                                                                                                                                                                                                                 | No                  |
| LSP                  | Code intelligence via language servers. Reports type errors and warnings automatically after file edits. Also supports navigation operations: jump to definitions, find references, get type info, list symbols, find implementations, trace call hierarchies. Requires a [code intelligence plugin](https://code.claude.com/docs/en/tools-reference/docs/en/discover-plugins#code-intelligence) and its language server binary | No                  |
| NotebookEdit         | Modifies Jupyter notebook cells                                                                                                                                                                                                                                                                                                                                                  | Yes                 |
| Read                 | Reads the contents of files                                                                                                                                                                                                                                                                                                                                                      | No                  |
| ReadMcpResourceTool  | Reads a specific MCP resource by URI                                                                                                                                                                                                                                                                                                                                             | No                  |
| Skill                | Executes a [skill](https://code.claude.com/docs/en/tools-reference/docs/en/skills#control-who-invokes-a-skill) within the main conversation                                                                                                                                                                                                                                                                                     | Yes                 |
| TaskCreate           | Creates a new task in the task list                                                                                                                                                                                                                                                                                                                                              | No                  |
| TaskGet              | Retrieves full details for a specific task                                                                                                                                                                                                                                                                                                                                       | No                  |
| TaskList             | Lists all tasks with their current status                                                                                                                                                                                                                                                                                                                                        | No                  |
| TaskOutput           | Retrieves output from a background task                                                                                                                                                                                                                                                                                                                                          | No                  |
| TaskStop             | Kills a running background task by ID                                                                                                                                                                                                                                                                                                                                            | No                  |
| TaskUpdate           | Updates task status, dependencies, details, or deletes tasks                                                                                                                                                                                                                                                                                                                     | No                  |
| TodoWrite            | Manages the session task checklist. Available in non-interactive mode and the [Agent SDK](https://code.claude.com/docs/en/tools-reference/docs/en/headless); interactive sessions use TaskCreate, TaskGet, TaskList, and TaskUpdate instead                                                                                                                                                                                     | No                  |
| ToolSearch           | Searches for and loads deferred tools when [tool search](https://code.claude.com/docs/en/tools-reference/docs/en/mcp#scale-with-mcp-tool-search) is enabled                                                                                                                                                                                                                                                                     | No                  |
| WebFetch             | Fetches content from a specified URL                                                                                                                                                                                                                                                                                                                                             | Yes                 |
| WebSearch            | Performs web searches                                                                                                                                                                                                                                                                                                                                                            | Yes                 |
| Write                | Creates or overwrites files                                                                                                                                                                                                                                                                                                                                                      | Yes                 |

Permission rules can be configured using `/permissions` or in [permission settings](https://code.claude.com/docs/en/tools-reference/docs/en/settings#available-settings). Also see [Tool-specific permission rules](https://code.claude.com/docs/en/tools-reference/docs/en/permissions#tool-specific-permission-rules). 

## 

[​](#bash-tool-behavior)

Bash tool behavior

The Bash tool runs each command in a separate process with the following persistence behavior: 
* Working directory persists across commands. Set `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR=1` to reset to the project directory after each command.
* Environment variables do not persist. An `export` in one command will not be available in the next.
Activate your virtualenv or conda environment before launching Claude Code. To make environment variables persist across Bash commands, set [CLAUDE\_ENV\_FILE](https://code.claude.com/docs/en/tools-reference/docs/en/env-vars) to a shell script before launching Claude Code, or use a [SessionStart hook](https://code.claude.com/docs/en/tools-reference/docs/en/hooks#persist-environment-variables) to populate it dynamically. 

## 

[​](#see-also)

See also

* [Permissions](https://code.claude.com/docs/en/tools-reference/docs/en/permissions): permission system, rule syntax, and tool-specific patterns
* [Subagents](https://code.claude.com/docs/en/tools-reference/docs/en/sub-agents): configure tool access for subagents
* [Hooks](https://code.claude.com/docs/en/tools-reference/docs/en/hooks-guide): run custom commands before or after tool execution

Was this page helpful?

YesNo

[Environment variables](https://code.claude.com/docs/en/tools-reference/docs/en/env-vars)[Interactive mode](https://code.claude.com/docs/en/tools-reference/docs/en/interactive-mode)

⌘I

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/tools-reference/docs/en/overview)

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