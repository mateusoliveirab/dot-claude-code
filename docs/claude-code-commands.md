# Claude Code — Built-in Commands Reference

Complete reference for all built-in commands available in Claude Code.

> **Version:** Based on Claude Code **v2.1.76** (crawled 2026-03-15). Run `claude --version` to check your installed version.
> Some commands depend on platform, plan, or environment — noted where applicable.

Type `/` in any session to see all commands, or `/` followed by letras para filtrar.

---

## Session & Context Management

**1. `/clear`** *(aliases: /reset, /new)*
Clears conversation history and frees up context.
> **Insight:** Use when a session drifted too far from the original goal or the context is getting heavy. Faster than restarting the terminal.

**2. `/compact [instructions]`**
Summarizes the conversation so far and continues with a fresh context window.
> **Insight:** Pass focus instructions to control what survives the summary — e.g., `/compact focus on the auth refactor, ignore the sidebar discussion`. Don't wait until the context explodes: compact proactively before long tasks.

**3. `/context`**
Renders a colored grid showing current context usage with optimization suggestions. Flags memory bloat, context-heavy tools, and capacity warnings.
> **Insight:** Run this before any long session. Knowing your headroom upfront avoids surprises mid-task when Claude slows down or starts forgetting earlier instructions.

**4. `/fork [name]`**
Creates a fork of the current conversation at this exact point.
> **Insight:** Use when you want to explore two different approaches without losing either. Think of it as `git branch` for conversations.

**5. `/rewind`** *(alias: /checkpoint)*
Rewinds the conversation and code to a previous point, or summarizes from a selected message.
> **Insight:** Your undo button. Run it before letting Claude execute something risky. If the result is bad, rewind to before it happened — including changes to files.

**6. `/resume [session]`** *(alias: /continue)*
Resumes a conversation by ID or name, or opens an interactive session picker.
> **Insight:** Combined with `/rename`, this is how you maintain long-running work across days without losing context. From the CLI: `claude -r "auth-refactor" "continue from where we left off"`.

**7. `/rename [name]`**
Renames the current session and shows the name on the prompt bar. Without a name, auto-generates one from conversation history.
> **Insight:** Name sessions immediately when starting something meaningful. Makes `/resume` actually useful — you can find the session later without guessing an ID.

**8. `/export [filename]`**
Exports the current conversation as plain text. With a filename, writes directly to that file. Without, opens a dialog to copy to clipboard or save.
> **Insight:** Use to create documentation from a design session, or to share a conversation with someone who doesn't have Claude Code.

---

## Planning & Execution Control

**9. `/plan`**
Enters plan mode directly. Claude explores the codebase and proposes a plan without editing files. Calls `ExitPlanMode` when done.
> **Insight:** Use before any non-trivial task. Reviewing the plan before execution is the single highest-leverage habit for avoiding wasted work and unintended changes.

**10. `/effort [low|medium|high|max|auto]`**
Sets the model effort level. `low`, `medium`, `high` persist across sessions. `max` applies to the current session only (requires Opus 4.6). `auto` resets to model default.
> **Insight:** Use `low` for quick questions and `max` for hard architectural problems. Without arguments, shows the current level. The change takes effect immediately — mid-response.

**11. `/fast [on|off]`**
Toggles fast mode on or off. Optimizes for speed using the same model.
> **Insight:** Good for rapid iteration cycles where you need quick feedback, not deep reasoning. Toggle off when tackling complex problems.

**12. `/model [model]`**
Selects or changes the AI model mid-session. Takes effect immediately.
> **Insight:** Switching models breaks the prompt cache — if you're deep into a long session, switching to a cheaper model may actually cost more (you pay to rebuild the cache). Prefer subagents for model routing instead of changing mid-session.

---

## Memory & Instructions

**13. `/init`**
Initializes the project with a `CLAUDE.md` by analyzing the codebase. Discovers build commands, test instructions, and conventions automatically. If `CLAUDE.md` exists, suggests improvements instead of overwriting.
> **Insight:** Always run this first in a new project. The generated file isn't perfect, but it saves 30 minutes of manual setup and gives Claude the context it needs to avoid constant clarification questions.

**14. `/memory`**
The control center for Claude's memory. Lists all `CLAUDE.md` and rules files loaded in the current session, lets you toggle auto memory, and opens the auto memory folder.
> **Insight:** This is the most underused command. If Claude is ignoring an instruction, run `/memory` first — the file may not be loading. Also use it to audit what Claude has learned about you automatically via auto memory.

---

## Permissions & Security

**15. `/permissions`** *(alias: /allowed-tools)*
Views or updates what Claude is allowed to do without asking for confirmation. Shows the current allow/deny lists and lets you add rules on the fly.
> **Insight:** Most users never open this. But it's how you configure Claude to run your test suite without asking every time — or block destructive commands permanently. Changes here persist to `settings.json`.

**16. `/hooks`**
Views all hook configurations for tool events. Shows which scripts run at which lifecycle points.
> **Insight:** If a hook is blocking a command or running unexpectedly, this is where you debug it. Also useful to verify that safety hooks you configured are actually active.

**17. `/sandbox`** — supported platforms only
Toggles sandbox mode, restricting Claude to a sandboxed OS environment.
> **Insight:** Use for high-risk sessions where you want OS-level isolation. Not available everywhere — `/doctor` will tell you if it's supported on your setup.

**18. `/security-review`**
Analyzes pending changes on the current branch for security vulnerabilities. Reviews the git diff for injection flaws, auth issues, and data exposure.
> **Insight:** A quick pre-PR safety check. Easier than a manual audit and catches common patterns your linter won't. Best run after a feature is complete but before opening the PR.

---

## Configuration & Preferences

**19. `/config`** *(alias: /settings)*
Opens the Settings interface. Adjust theme, model, output style, and other preferences.
> **Insight:** The **output style** setting changes everything. "Explanatory" makes Claude justify its decisions, great for learning. "Concise" cuts the noise for experienced users. Worth exploring before settling into a workflow.

**20. `/theme`**
Changes the color theme. Includes light/dark variants, colorblind-accessible (daltonized) themes, and ANSI themes that use your terminal's color palette.
> **Insight:** The ANSI themes integrate with your terminal's own palette — useful if you've already customized it heavily and want Claude Code to match.

**21. `/color [color|default]`**
Sets the prompt bar color for the current session. Available: red, blue, green, yellow, purple, orange, pink, cyan.
> **Insight:** Underrated feature for power users running multiple Claude windows in parallel. Color-code by project or risk level — red for production, blue for experiments.

**22. `/vim`**
Toggles between Vim and Normal editing modes for the prompt input.
> **Insight:** Full Vim keybindings including navigation, text objects, and command history. If you live in Vim, this makes composing long prompts much faster.

**23. `/keybindings`**
Opens or creates your keybindings configuration file (`~/.claude/keybindings.json`).
> **Insight:** Every repetitive action you take in Claude Code can be bound to a key. Worth investing 15 minutes here after you know your workflow.

**24. `/terminal-setup`** — only in terminals that need it
Configures terminal keybindings for Shift+Enter and other shortcuts. Hidden when your terminal already handles these natively.
> **Insight:** If Shift+Enter isn't working in VS Code, Alacritty, or Warp, this command fixes it automatically. Don't manually edit terminal configs — let this handle it.

**25. `/statusline`**
Configures Claude Code's status line. Describe what you want in natural language, or run without arguments to auto-configure from your shell prompt.
> **Insight:** Show context usage, git branch, model, and cost in your shell's status bar. Knowing context usage at a glance prevents being caught off-guard mid-task.

---

## Extensions & Integrations

**26. `/skills`**
Lists all available skills — bundled and installed.
> **Insight:** Browse this before composing a complex prompt. If a skill exists for your task, Claude will likely trigger it automatically — but knowing what's available helps you phrase requests that activate the right skill.

**27. `/agents`**
Manages agent configurations. View, edit, and create specialized subagent personas from within a session.
> **Insight:** Use to inspect what agents are configured and their tool restrictions. If a subagent is behaving unexpectedly, check its configuration here.

**28. `/plugin`**
Manages Claude Code plugins — install, update, remove from the marketplace.
> **Insight:** The official marketplace (`claude-plugins-official`) has growing community plugins. The playground plugin is particularly useful for visual interaction:
> ```
> /plugin marketplace update claude-plugins-official
> /plugin install playground@claude-plugins-official
> ```

**29. `/reload-plugins`**
Reloads all active plugins to apply pending changes without restarting.
> **Insight:** When developing or modifying a plugin, use this instead of restarting the session. It reports what was loaded and flags any changes that require a full restart.

**30. `/mcp`**
Manages MCP server connections and OAuth authentication.
> **Insight:** If an MCP tool isn't available, this is the first place to check. Shows connection status, lets you reconnect, and handles auth flows for services like Slack, GitHub, or Supabase.

---

## Workflow & Collaboration

**31. `/btw <question>`**
Asks a quick side question without adding it to the main conversation history.
> **Insight:** Use for "wait, how does X work?" moments during a long session without polluting the context. The question and answer are ephemeral — they don't count against context and don't affect the ongoing task.

**32. `/pr-comments [PR]`**
Fetches and displays comments from a GitHub pull request. Auto-detects the PR for the current branch, or accepts a PR URL or number. Requires `gh` CLI.
> **Insight:** The fastest way to start addressing review feedback. Paste the PR comments directly into context and say "fix these" — no copy-paste from the browser.

**33. `/diff`**
Opens an interactive diff viewer showing uncommitted changes and per-turn diffs. Left/right to switch between git diff and individual Claude turns, up/down to browse files.
> **Insight:** Gives you a turn-by-turn view of what Claude changed and when. Useful for reviewing a long session before committing — you can spot when a change was introduced and rewind to before it if needed.

**34. `/add-dir <path>`**
Adds a new working directory to the current session.
> **Insight:** Essential in monorepos or when Claude needs access to a sibling directory. Without this, Claude can't read files outside the working directory it was started in.

**35. `/tasks`**
Lists and manages background tasks. Shows running subagents and async operations.
> **Insight:** When you've dispatched multiple subagents in parallel, this shows what's running and what's done. Think of it as `ps` for Claude's work.

---

## Remote & Cross-Platform

**36. `/desktop`** *(alias: /app)* — macOS/Windows only
Continues the current session in the Claude Code Desktop app.
> **Insight:** If you started a session in the terminal and want to move it to the desktop app (or vice versa), this preserves the full context.

**37. `/remote-control`** *(alias: /rc)*
Makes the current session available for remote control from claude.ai.
> **Insight:** Useful for pair-programming or handoff scenarios where someone else needs to take over a Claude Code session without starting fresh.

**38. `/remote-env`**
Configures the default remote environment for web sessions started with `--remote`.
> **Insight:** Set this once and `claude --remote` will always spin up in your preferred environment — right node version, right working directory, right credentials.

**39. `/install-github-app`**
Sets up the Claude GitHub Actions app for a repository.
> **Insight:** After this, Claude can comment on PRs, fix issues, and run in CI automatically. One-time setup per repo that unlocks automated workflows without manual Claude Code sessions.

**40. `/install-slack-app`**
Installs the Claude Slack app. Opens a browser to complete the OAuth flow.
> **Insight:** Once installed, you can paste a Slack bug thread directly into Claude Code and say "fix" — zero context switching from where the bug was reported.

**41. `/mobile`** *(aliases: /ios, /android)*
Displays a QR code to download the Claude mobile app.
> **Insight:** Handy if you want to review Claude's work or give quick feedback from your phone while away from the keyboard.

---

## Account & Usage

**42. `/login`** / **`/logout`**
Signs in or out of your Anthropic account.
> **Insight:** If you're switching between personal and work accounts, use these instead of touching env vars or config files.

**43. `/cost`**
Shows token usage statistics for the current session.
> **Insight:** Run after a long session to understand what it cost. If a session is unexpectedly expensive, this is how you diagnose it — combine with `/context` to see where the tokens are going.

**44. `/usage`**
Shows plan usage limits and current rate limit status.
> **Insight:** Check this when you're getting throttled. It shows exactly how much of your limit is used and when it resets — so you know whether to wait or use `/extra-usage`.

**45. `/stats`**
Visualizes daily usage, session history, streaks, and model preferences over time.
> **Insight:** A personal analytics dashboard. Useful for understanding your Claude Code habits and for making the case to your team that it's worth the subscription cost.

**46. `/insights`**
Generates a report analyzing your Claude Code sessions — project areas, interaction patterns, and friction points.
> **Insight:** Run this periodically, not just when something feels wrong. It surfaces patterns you won't notice session-by-session — like which parts of the codebase generate the most back-and-forth, which is often a signal of missing documentation or skills.

**47. `/extra-usage`**
Configures extra usage to keep working when rate limits are hit (paid overage).
> **Insight:** Configure this before you need it. Hitting a rate limit mid-task and having to wait is more disruptive than the cost of overage.

**48. `/upgrade`** — Pro/Max only
Opens the upgrade page to switch to a higher plan tier.
> **Insight:** If you're consistently hitting rate limits, this is the fastest path to more capacity.

**49. `/privacy-settings`** — Pro/Max only
Views and updates your privacy settings.
> **Insight:** Controls whether your sessions are used for model training. Worth checking if you work with proprietary code.

**50. `/passes`**
Shares a free week of Claude Code with friends. Only visible if your account is eligible.
> **Insight:** If you're sold on Claude Code, this is the easiest way to bring teammates along without waiting for budget approval.

---

## Help & Diagnostics

**51. `/help`**
Shows help and all available commands.
> **Insight:** Your first stop when you forget a command name. Also shows bundled skills alongside built-in commands.

**52. `/doctor`**
Diagnoses and verifies your Claude Code installation, settings, and connectivity.
> **Insight:** Run this before reporting a bug or when something seems off. It checks the things most people debug manually — wrong model, missing MCP connections, broken keybindings, outdated version.

**53. `/status`**
Opens the Settings interface (Status tab) with version, model, account, and connectivity info.
> **Insight:** Quick health check. If Claude is behaving strangely, confirming the active model and account here takes 5 seconds and rules out the most common causes.

**54. `/release-notes`**
Views the full changelog, with the most recent version at the top.
> **Insight:** After an update, check what changed before assuming a behavior is a bug. Claude Code ships frequently — what looked like a bug yesterday may be a feature today.

**55. `/feedback [report]`** *(alias: /bug)*
Submits feedback or bug reports directly to Anthropic.
> **Insight:** Use this instead of Twitter. Bug reports submitted here include session context that helps the team reproduce the issue.

**56. `/ide`**
Manages IDE integrations and shows connection status.
> **Insight:** If Claude Code and VS Code or JetBrains aren't syncing properly, check here first. It shows the connection state and lets you reconnect without restarting either app.

---

## MCP Prompts

MCP servers can expose prompts that appear as commands using the format `/mcp__<server>__<prompt>`. These are dynamically discovered from connected servers and vary based on your MCP configuration.

---

## Top 10 Commands to Know First

| # | Command | Why |
|---|---|---|
| 1 | `/init` | Always the first step in a new project |
| 2 | `/memory` | Understand what Claude actually knows about your project |
| 3 | `/plan` | Review before Claude touches anything non-trivial |
| 4 | `/context` | Know your headroom before long tasks |
| 5 | `/compact` | Manage context before it runs out |
| 6 | `/permissions` | Control what Claude can do without asking |
| 7 | `/hooks` | Debug and verify your automation rules |
| 8 | `/config` | Tune output style, model, and preferences |
| 9 | `/rewind` | Undo when something goes wrong |
| 10 | `/insights` | Understand your usage patterns over time |

> **Sources:** [commands.md](../research/sources/commands.md) · [interactive-mode.md](../research/sources/interactive-mode.md) · [changelog.md](../research/sources/changelog.md)
