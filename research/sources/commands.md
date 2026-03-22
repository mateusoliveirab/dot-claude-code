---
url: https://code.claude.com/docs/en/commands
crawled_at: 2026-03-15T04:29:57Z
---

[Skip to main content](#content-area)

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/commands/docs/en/overview)

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

Built-in commands

[Getting started](https://code.claude.com/docs/en/commands/docs/en/overview)[Build with Claude Code](https://code.claude.com/docs/en/commands/docs/en/sub-agents)[Deployment](https://code.claude.com/docs/en/commands/docs/en/third-party-integrations)[Administration](https://code.claude.com/docs/en/commands/docs/en/setup)[Configuration](https://code.claude.com/docs/en/commands/docs/en/settings)[Reference](https://code.claude.com/docs/en/commands/docs/en/cli-reference)[Resources](https://code.claude.com/docs/en/commands/docs/en/legal-and-compliance)

##### Reference

* [CLI reference](https://code.claude.com/docs/en/commands/docs/en/cli-reference)
* [Built-in commands](https://code.claude.com/docs/en/commands/docs/en/commands)
* [Environment variables](https://code.claude.com/docs/en/commands/docs/en/env-vars)
* [Tools reference](https://code.claude.com/docs/en/commands/docs/en/tools-reference)
* [Interactive mode](https://code.claude.com/docs/en/commands/docs/en/interactive-mode)
* [Checkpointing](https://code.claude.com/docs/en/commands/docs/en/checkpointing)
* [Hooks reference](https://code.claude.com/docs/en/commands/docs/en/hooks)
* [Plugins reference](https://code.claude.com/docs/en/commands/docs/en/plugins-reference)

On this page

* [MCP prompts](#mcp-prompts)
* [See also](#see-also)

Reference

# Built-in commands

Copy page

Complete reference for built-in commands available in Claude Code.

Copy page

Type `/` in Claude Code to see all available commands, or type `/` followed by any letters to filter. Not all commands are visible to every user. Some depend on your platform, plan, or environment. For example, `/desktop` only appears on macOS and Windows, `/upgrade` and `/privacy-settings` are only available on Pro and Max plans, and `/terminal-setup` is hidden when your terminal natively supports its keybindings. Claude Code also includes [bundled skills](https://code.claude.com/docs/en/commands/docs/en/skills#bundled-skills) like `/simplify`, `/batch`, and `/debug` that appear alongside built-in commands when you type `/`. To create your own commands, see [skills](https://code.claude.com/docs/en/commands/docs/en/skills). In the table below, `<arg>` indicates a required argument and `[arg]` indicates an optional one. 

| Command                               | Purpose                                                                                                                                                                                                                                                                                                                                             |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| /add-dir <path>                       | Add a new working directory to the current session                                                                                                                                                                                                                                                                                                  |
| /agents                               | Manage [agent](https://code.claude.com/docs/en/commands/docs/en/sub-agents) configurations                                                                                                                                                                                                                                                                                                  |
| /btw <question>                       | Ask a quick [side question](https://code.claude.com/docs/en/commands/docs/en/interactive-mode#side-questions-with-btw) without adding to the conversation                                                                                                                                                                                                                                   |
| /chrome                               | Configure [Claude in Chrome](https://code.claude.com/docs/en/commands/docs/en/chrome) settings                                                                                                                                                                                                                                                                                              |
| /clear                                | Clear conversation history and free up context. Aliases: /reset, /new                                                                                                                                                                                                                                                                               |
| /color \[color\|default\]             | Set the prompt bar color for the current session. Available colors: red, blue, green, yellow, purple, orange, pink, cyan. Use default to reset                                                                                                                                                                                                      |
| /compact \[instructions\]             | Compact conversation with optional focus instructions                                                                                                                                                                                                                                                                                               |
| /config                               | Open the [Settings](https://code.claude.com/docs/en/commands/docs/en/settings) interface to adjust theme, model, [output style](https://code.claude.com/docs/en/commands/docs/en/output-styles), and other preferences. Alias: /settings                                                                                                                                                                                            |
| /context                              | Visualize current context usage as a colored grid. Shows optimization suggestions for context-heavy tools, memory bloat, and capacity warnings                                                                                                                                                                                                      |
| /copy                                 | Copy the last assistant response to clipboard. When code blocks are present, shows an interactive picker to select individual blocks or the full response                                                                                                                                                                                           |
| /cost                                 | Show token usage statistics. See [cost tracking guide](https://code.claude.com/docs/en/commands/docs/en/costs#using-the-cost-command) for subscription-specific details                                                                                                                                                                                                                     |
| /desktop                              | Continue the current session in the Claude Code Desktop app. macOS and Windows only. Alias: /app                                                                                                                                                                                                                                                    |
| /diff                                 | Open an interactive diff viewer showing uncommitted changes and per-turn diffs. Use left/right arrows to switch between the current git diff and individual Claude turns, and up/down to browse files                                                                                                                                               |
| /doctor                               | Diagnose and verify your Claude Code installation and settings                                                                                                                                                                                                                                                                                      |
| /effort \[low\|medium|high|max|auto\] | Set the model [effort level](https://code.claude.com/docs/en/commands/docs/en/model-config#adjust-effort-level). low, medium, and high persist across sessions. max applies to the current session only and requires Opus 4.6\. auto resets to the model default. Without an argument, shows the current level. Takes effect immediately without waiting for the current response to finish |
| /exit                                 | Exit the CLI. Alias: /quit                                                                                                                                                                                                                                                                                                                          |
| /export \[filename\]                  | Export the current conversation as plain text. With a filename, writes directly to that file. Without, opens a dialog to copy to clipboard or save to a file                                                                                                                                                                                        |
| /extra-usage                          | Configure extra usage to keep working when rate limits are hit                                                                                                                                                                                                                                                                                      |
| /fast \[on\|off\]                     | Toggle [fast mode](https://code.claude.com/docs/en/commands/docs/en/fast-mode) on or off                                                                                                                                                                                                                                                                                                    |
| /feedback \[report\]                  | Submit feedback about Claude Code. Alias: /bug                                                                                                                                                                                                                                                                                                      |
| /fork \[name\]                        | Create a fork of the current conversation at this point                                                                                                                                                                                                                                                                                             |
| /help                                 | Show help and available commands                                                                                                                                                                                                                                                                                                                    |
| /hooks                                | View [hook](https://code.claude.com/docs/en/commands/docs/en/hooks) configurations for tool events                                                                                                                                                                                                                                                                                          |
| /ide                                  | Manage IDE integrations and show status                                                                                                                                                                                                                                                                                                             |
| /init                                 | Initialize project with CLAUDE.md guide                                                                                                                                                                                                                                                                                                             |
| /insights                             | Generate a report analyzing your Claude Code sessions, including project areas, interaction patterns, and friction points                                                                                                                                                                                                                           |
| /install-github-app                   | Set up the [Claude GitHub Actions](https://code.claude.com/docs/en/commands/docs/en/github-actions) app for a repository. Walks you through selecting a repo and configuring the integration                                                                                                                                                                                                |
| /install-slack-app                    | Install the Claude Slack app. Opens a browser to complete the OAuth flow                                                                                                                                                                                                                                                                            |
| /keybindings                          | Open or create your keybindings configuration file                                                                                                                                                                                                                                                                                                  |
| /login                                | Sign in to your Anthropic account                                                                                                                                                                                                                                                                                                                   |
| /logout                               | Sign out from your Anthropic account                                                                                                                                                                                                                                                                                                                |
| /mcp                                  | Manage MCP server connections and OAuth authentication                                                                                                                                                                                                                                                                                              |
| /memory                               | Edit CLAUDE.md memory files, enable or disable [auto-memory](https://code.claude.com/docs/en/commands/docs/en/memory#auto-memory), and view auto-memory entries                                                                                                                                                                                                                             |
| /mobile                               | Show QR code to download the Claude mobile app. Aliases: /ios, /android                                                                                                                                                                                                                                                                             |
| /model \[model\]                      | Select or change the AI model. For models that support it, use left/right arrows to [adjust effort level](https://code.claude.com/docs/en/commands/docs/en/model-config#adjust-effort-level). The change takes effect immediately without waiting for the current response to finish                                                                                                        |
| /passes                               | Share a free week of Claude Code with friends. Only visible if your account is eligible                                                                                                                                                                                                                                                             |
| /permissions                          | View or update [permissions](https://code.claude.com/docs/en/commands/docs/en/permissions#manage-permissions). Alias: /allowed-tools                                                                                                                                                                                                                                                        |
| /plan                                 | Enter plan mode directly from the prompt                                                                                                                                                                                                                                                                                                            |
| /plugin                               | Manage Claude Code [plugins](https://code.claude.com/docs/en/commands/docs/en/plugins)                                                                                                                                                                                                                                                                                                      |
| /pr-comments \[PR\]                   | Fetch and display comments from a GitHub pull request. Automatically detects the PR for the current branch, or pass a PR URL or number. Requires the gh CLI                                                                                                                                                                                         |
| /privacy-settings                     | View and update your privacy settings. Only available for Pro and Max plan subscribers                                                                                                                                                                                                                                                              |
| /release-notes                        | View the full changelog, with the most recent version closest to your prompt                                                                                                                                                                                                                                                                        |
| /reload-plugins                       | Reload all active [plugins](https://code.claude.com/docs/en/commands/docs/en/plugins) to apply pending changes without restarting. Reports what was loaded and notes any changes that require a restart                                                                                                                                                                                     |
| /remote-control                       | Make this session available for [remote control](https://code.claude.com/docs/en/commands/docs/en/remote-control) from claude.ai. Alias: /rc                                                                                                                                                                                                                                                |
| /remote-env                           | Configure the default remote environment for [web sessions started with \--remote](https://code.claude.com/docs/en/commands/docs/en/claude-code-on-the-web#environment-configuration)                                                                                                                                                                                                       |
| /rename \[name\]                      | Rename the current session and show the name on the prompt bar. Without a name, auto-generates one from conversation history                                                                                                                                                                                                                        |
| /resume \[session\]                   | Resume a conversation by ID or name, or open the session picker. Alias: /continue                                                                                                                                                                                                                                                                   |
| /review                               | Deprecated. Install the [code-review plugin](https://github.com/anthropics/claude-code-marketplace/blob/main/code-review/README.md) instead: claude plugin install code-review@claude-code-marketplace                                                                                                                                              |
| /rewind                               | Rewind the conversation and/or code to a previous point, or summarize from a selected message. See [checkpointing](https://code.claude.com/docs/en/commands/docs/en/checkpointing). Alias: /checkpoint                                                                                                                                                                                      |
| /sandbox                              | Toggle [sandbox mode](https://code.claude.com/docs/en/commands/docs/en/sandboxing). Available on supported platforms only                                                                                                                                                                                                                                                                   |
| /security-review                      | Analyze pending changes on the current branch for security vulnerabilities. Reviews the git diff and identifies risks like injection, auth issues, and data exposure                                                                                                                                                                                |
| /skills                               | List available [skills](https://code.claude.com/docs/en/commands/docs/en/skills)                                                                                                                                                                                                                                                                                                            |
| /stats                                | Visualize daily usage, session history, streaks, and model preferences                                                                                                                                                                                                                                                                              |
| /status                               | Open the Settings interface (Status tab) showing version, model, account, and connectivity                                                                                                                                                                                                                                                          |
| /statusline                           | Configure Claude Code’s [status line](https://code.claude.com/docs/en/commands/docs/en/statusline). Describe what you want, or run without arguments to auto-configure from your shell prompt                                                                                                                                                                                               |
| /stickers                             | Order Claude Code stickers                                                                                                                                                                                                                                                                                                                          |
| /tasks                                | List and manage background tasks                                                                                                                                                                                                                                                                                                                    |
| /terminal-setup                       | Configure terminal keybindings for Shift+Enter and other shortcuts. Only visible in terminals that need it, like VS Code, Alacritty, or Warp                                                                                                                                                                                                        |
| /theme                                | Change the color theme. Includes light and dark variants, colorblind-accessible (daltonized) themes, and ANSI themes that use your terminal’s color palette                                                                                                                                                                                         |
| /upgrade                              | Open the upgrade page to switch to a higher plan tier                                                                                                                                                                                                                                                                                               |
| /usage                                | Show plan usage limits and rate limit status                                                                                                                                                                                                                                                                                                        |
| /vim                                  | Toggle between Vim and Normal editing modes                                                                                                                                                                                                                                                                                                         |

## 

[​](#mcp-prompts)

MCP prompts

MCP servers can expose prompts that appear as commands. These use the format `/mcp__<server>__<prompt>` and are dynamically discovered from connected servers. See [MCP prompts](https://code.claude.com/docs/en/commands/docs/en/mcp#use-mcp-prompts-as-commands) for details. 

## 

[​](#see-also)

See also

* [Skills](https://code.claude.com/docs/en/commands/docs/en/skills): create your own commands
* [Interactive mode](https://code.claude.com/docs/en/commands/docs/en/interactive-mode): keyboard shortcuts, Vim mode, and command history
* [CLI reference](https://code.claude.com/docs/en/commands/docs/en/cli-reference): launch-time flags

Was this page helpful?

YesNo

[CLI reference](https://code.claude.com/docs/en/commands/docs/en/cli-reference)[Environment variables](https://code.claude.com/docs/en/commands/docs/en/env-vars)

⌘I

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/commands/docs/en/overview)

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