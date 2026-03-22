---
url: https://code.claude.com/docs/en/interactive-mode
crawled_at: 2026-03-15T04:29:57Z
---

[Skip to main content](#content-area)

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/interactive-mode/docs/en/overview)

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

Interactive mode

[Getting started](https://code.claude.com/docs/en/interactive-mode/docs/en/overview)[Build with Claude Code](https://code.claude.com/docs/en/interactive-mode/docs/en/sub-agents)[Deployment](https://code.claude.com/docs/en/interactive-mode/docs/en/third-party-integrations)[Administration](https://code.claude.com/docs/en/interactive-mode/docs/en/setup)[Configuration](https://code.claude.com/docs/en/interactive-mode/docs/en/settings)[Reference](https://code.claude.com/docs/en/interactive-mode/docs/en/cli-reference)[Resources](https://code.claude.com/docs/en/interactive-mode/docs/en/legal-and-compliance)

##### Reference

* [CLI reference](https://code.claude.com/docs/en/interactive-mode/docs/en/cli-reference)
* [Built-in commands](https://code.claude.com/docs/en/interactive-mode/docs/en/commands)
* [Environment variables](https://code.claude.com/docs/en/interactive-mode/docs/en/env-vars)
* [Tools reference](https://code.claude.com/docs/en/interactive-mode/docs/en/tools-reference)
* [Interactive mode](https://code.claude.com/docs/en/interactive-mode/docs/en/interactive-mode)
* [Checkpointing](https://code.claude.com/docs/en/interactive-mode/docs/en/checkpointing)
* [Hooks reference](https://code.claude.com/docs/en/interactive-mode/docs/en/hooks)
* [Plugins reference](https://code.claude.com/docs/en/interactive-mode/docs/en/plugins-reference)

On this page

* [Keyboard shortcuts](#keyboard-shortcuts)
* [General controls](#general-controls)
* [Text editing](#text-editing)
* [Theme and display](#theme-and-display)
* [Multiline input](#multiline-input)
* [Quick commands](#quick-commands)
* [Built-in commands](#built-in-commands)
* [Vim editor mode](#vim-editor-mode)
* [Mode switching](#mode-switching)
* [Navigation (NORMAL mode)](#navigation-normal-mode)
* [Editing (NORMAL mode)](#editing-normal-mode)
* [Text objects (NORMAL mode)](#text-objects-normal-mode)
* [Command history](#command-history)
* [Reverse search with Ctrl+R](#reverse-search-with-ctrl%2Br)
* [Background bash commands](#background-bash-commands)
* [How backgrounding works](#how-backgrounding-works)
* [Bash mode with ! prefix](#bash-mode-with-prefix)
* [Prompt suggestions](#prompt-suggestions)
* [Side questions with /btw](#side-questions-with-%2Fbtw)
* [Task list](#task-list)
* [PR review status](#pr-review-status)
* [See also](#see-also)

Reference

# Interactive mode

Copy page

Complete reference for keyboard shortcuts, input modes, and interactive features in Claude Code sessions.

Copy page

## 

[​](#keyboard-shortcuts)

Keyboard shortcuts

Keyboard shortcuts may vary by platform and terminal. Press `?` to see available shortcuts for your environment.**macOS users**: Option/Alt key shortcuts (`Alt+B`, `Alt+F`, `Alt+Y`, `Alt+M`, `Alt+P`) require configuring Option as Meta in your terminal:
* **iTerm2**: settings → Profiles → Keys → set Left/Right Option key to “Esc+”
* **Terminal.app**: settings → Profiles → Keyboard → check “Use Option as Meta Key”
* **VS Code**: settings → Profiles → Keys → set Left/Right Option key to “Esc+”
See [Terminal configuration](https://code.claude.com/docs/en/interactive-mode/docs/en/terminal-config) for details.

### 

[​](#general-controls)

General controls

| Shortcut                                    | Description                                                         | Context                                                                                     |
| ------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Ctrl+C                                      | Cancel current input or generation                                  | Standard interrupt                                                                          |
| Ctrl+F                                      | Kill all background agents. Press twice within 3 seconds to confirm | Background agent control                                                                    |
| Ctrl+D                                      | Exit Claude Code session                                            | EOF signal                                                                                  |
| Ctrl+G                                      | Open in default text editor                                         | Edit your prompt or custom response in your default text editor                             |
| Ctrl+L                                      | Clear terminal screen                                               | Keeps conversation history                                                                  |
| Ctrl+O                                      | Toggle verbose output                                               | Shows detailed tool usage and execution                                                     |
| Ctrl+R                                      | Reverse search command history                                      | Search through previous commands interactively                                              |
| Ctrl+V or Cmd+V (iTerm2) or Alt+V (Windows) | Paste image from clipboard                                          | Pastes an image or path to an image file                                                    |
| Ctrl+B                                      | Background running tasks                                            | Backgrounds bash commands and agents. Tmux users press twice                                |
| Ctrl+T                                      | Toggle task list                                                    | Show or hide the [task list](#task-list) in the terminal status area                        |
| Left/Right arrows                           | Cycle through dialog tabs                                           | Navigate between tabs in permission dialogs and menus                                       |
| Up/Down arrows                              | Navigate command history                                            | Recall previous inputs                                                                      |
| Esc \+ Esc                                  | Rewind or summarize                                                 | Restore code and/or conversation to a previous point, or summarize from a selected message  |
| Shift+Tab or Alt+M (some configurations)    | Toggle permission modes                                             | Switch between Auto-Accept Mode, Plan Mode, and normal mode.                                |
| Option+P (macOS) or Alt+P (Windows/Linux)   | Switch model                                                        | Switch models without clearing your prompt                                                  |
| Option+T (macOS) or Alt+T (Windows/Linux)   | Toggle extended thinking                                            | Enable or disable extended thinking mode. Run /terminal-setup first to enable this shortcut |

### 

[​](#text-editing)

Text editing

| Shortcut             | Description                  | Context                                                                                                       |
| -------------------- | ---------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Ctrl+K               | Delete to end of line        | Stores deleted text for pasting                                                                               |
| Ctrl+U               | Delete entire line           | Stores deleted text for pasting                                                                               |
| Ctrl+Y               | Paste deleted text           | Paste text deleted with Ctrl+K or Ctrl+U                                                                      |
| Alt+Y (after Ctrl+Y) | Cycle paste history          | After pasting, cycle through previously deleted text. Requires [Option as Meta](#keyboard-shortcuts) on macOS |
| Alt+B                | Move cursor back one word    | Word navigation. Requires [Option as Meta](#keyboard-shortcuts) on macOS                                      |
| Alt+F                | Move cursor forward one word | Word navigation. Requires [Option as Meta](#keyboard-shortcuts) on macOS                                      |

### 

[​](#theme-and-display)

Theme and display

| Shortcut | Description                                | Context                                                                                                    |
| -------- | ------------------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| Ctrl+T   | Toggle syntax highlighting for code blocks | Only works inside the /theme picker menu. Controls whether code in Claude’s responses uses syntax coloring |

Syntax highlighting is only available in the native build of Claude Code.

### 

[​](#multiline-input)

Multiline input

| Method           | Shortcut       | Context                                                 |
| ---------------- | -------------- | ------------------------------------------------------- |
| Quick escape     | \\ \+ Enter    | Works in all terminals                                  |
| macOS default    | Option+Enter   | Default on macOS                                        |
| Shift+Enter      | Shift+Enter    | Works out of the box in iTerm2, WezTerm, Ghostty, Kitty |
| Control sequence | Ctrl+J         | Line feed character for multiline                       |
| Paste mode       | Paste directly | For code blocks, logs                                   |

Shift+Enter works without configuration in iTerm2, WezTerm, Ghostty, and Kitty. For other terminals (VS Code, Alacritty, Zed, Warp), run `/terminal-setup` to install the binding.

### 

[​](#quick-commands)

Quick commands

| Shortcut   | Description       | Notes                                                                     |
| ---------- | ----------------- | ------------------------------------------------------------------------- |
| / at start | Command or skill  | See [built-in commands](#built-in-commands) and [skills](https://code.claude.com/docs/en/interactive-mode/docs/en/skills) |
| ! at start | Bash mode         | Run commands directly and add execution output to the session             |
| @          | File path mention | Trigger file path autocomplete                                            |

## 

[​](#built-in-commands)

Built-in commands

Type `/` in Claude Code to see all available commands, or type `/` followed by any letters to filter. The `/` menu shows both built-in commands and [bundled skills](https://code.claude.com/docs/en/interactive-mode/docs/en/skills#bundled-skills) like `/simplify`. Not all commands are visible to every user since some depend on your platform or plan. See the [commands reference](https://code.claude.com/docs/en/interactive-mode/docs/en/commands) for the full list of built-in commands. To create your own commands, see [skills](https://code.claude.com/docs/en/interactive-mode/docs/en/skills). 

## 

[​](#vim-editor-mode)

Vim editor mode

Enable vim-style editing with `/vim` command or configure permanently via `/config`. 

### 

[​](#mode-switching)

Mode switching

| Command | Action                      | From mode |
| ------- | --------------------------- | --------- |
| Esc     | Enter NORMAL mode           | INSERT    |
| i       | Insert before cursor        | NORMAL    |
| I       | Insert at beginning of line | NORMAL    |
| a       | Insert after cursor         | NORMAL    |
| A       | Insert at end of line       | NORMAL    |
| o       | Open line below             | NORMAL    |
| O       | Open line above             | NORMAL    |

### 

[​](#navigation-normal-mode)

Navigation (NORMAL mode)

| Command | Action                                              |
| ------- | --------------------------------------------------- |
| h/j/k/l | Move left/down/up/right                             |
| w       | Next word                                           |
| e       | End of word                                         |
| b       | Previous word                                       |
| 0       | Beginning of line                                   |
| $       | End of line                                         |
| ^       | First non-blank character                           |
| gg      | Beginning of input                                  |
| G       | End of input                                        |
| f{char} | Jump to next occurrence of character                |
| F{char} | Jump to previous occurrence of character            |
| t{char} | Jump to just before next occurrence of character    |
| T{char} | Jump to just after previous occurrence of character |
| ;       | Repeat last f/F/t/T motion                          |
| ,       | Repeat last f/F/t/T motion in reverse               |

In vim normal mode, if the cursor is at the beginning or end of input and cannot move further, the arrow keys navigate command history instead.

### 

[​](#editing-normal-mode)

Editing (NORMAL mode)

| Command  | Action                  |
| -------- | ----------------------- |
| x        | Delete character        |
| dd       | Delete line             |
| D        | Delete to end of line   |
| dw/de/db | Delete word/to end/back |
| cc       | Change line             |
| C        | Change to end of line   |
| cw/ce/cb | Change word/to end/back |
| yy/Y     | Yank (copy) line        |
| yw/ye/yb | Yank word/to end/back   |
| p        | Paste after cursor      |
| P        | Paste before cursor     |
| \>>      | Indent line             |
| <<       | Dedent line             |
| J        | Join lines              |
| .        | Repeat last change      |

### 

[​](#text-objects-normal-mode)

Text objects (NORMAL mode)

Text objects work with operators like `d`, `c`, and `y`: 

| Command | Action                                   |
| ------- | ---------------------------------------- |
| iw/aw   | Inner/around word                        |
| iW/aW   | Inner/around WORD (whitespace-delimited) |
| i"/a"   | Inner/around double quotes               |
| i'/a'   | Inner/around single quotes               |
| i(/a(   | Inner/around parentheses                 |
| i\[/a\[ | Inner/around brackets                    |
| i{/a{   | Inner/around braces                      |

## 

[​](#command-history)

Command history

Claude Code maintains command history for the current session: 
* Input history is stored per working directory
* Input history resets when you run `/clear` to start a new session. The previous session’s conversation is preserved and can be resumed.
* Use Up/Down arrows to navigate (see keyboard shortcuts above)
* **Note**: history expansion (`!`) is disabled by default

### 

[​](#reverse-search-with-ctrl+r)

Reverse search with Ctrl+R

Press `Ctrl+R` to interactively search through your command history: 
1. **Start search**: press `Ctrl+R` to activate reverse history search
2. **Type query**: enter text to search for in previous commands. The search term is highlighted in matching results
3. **Navigate matches**: press `Ctrl+R` again to cycle through older matches
4. **Accept match**:  
   * Press `Tab` or `Esc` to accept the current match and continue editing  
   * Press `Enter` to accept and execute the command immediately
5. **Cancel search**:  
   * Press `Ctrl+C` to cancel and restore your original input  
   * Press `Backspace` on empty search to cancel
The search displays matching commands with the search term highlighted, so you can find and reuse previous inputs. 

## 

[​](#background-bash-commands)

Background bash commands

Claude Code supports running bash commands in the background, allowing you to continue working while long-running processes execute. 

### 

[​](#how-backgrounding-works)

How backgrounding works

When Claude Code runs a command in the background, it runs the command asynchronously and immediately returns a background task ID. Claude Code can respond to new prompts while the command continues executing in the background. To run commands in the background, you can either: 
* Prompt Claude Code to run a command in the background
* Press Ctrl+B to move a regular Bash tool invocation to the background. (Tmux users must press Ctrl+B twice due to tmux’s prefix key.)
**Key features:** 
* Output is buffered and Claude can retrieve it using the TaskOutput tool
* Background tasks have unique IDs for tracking and output retrieval
* Background tasks are automatically cleaned up when Claude Code exits
To disable all background task functionality, set the `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` environment variable to `1`. See [Environment variables](https://code.claude.com/docs/en/interactive-mode/docs/en/env-vars) for details. **Common backgrounded commands:** 
* Build tools (webpack, vite, make)
* Package managers (npm, yarn, pnpm)
* Test runners (jest, pytest)
* Development servers
* Long-running processes (docker, terraform)

### 

[​](#bash-mode-with-prefix)

Bash mode with `!` prefix

Run bash commands directly without going through Claude by prefixing your input with `!`: 

Report incorrect code

Copy

Ask AI

```
! npm test
! git status
! ls -la

```

Bash mode: 
* Adds the command and its output to the conversation context
* Shows real-time progress and output
* Supports the same `Ctrl+B` backgrounding for long-running commands
* Does not require Claude to interpret or approve the command
* Supports history-based autocomplete: type a partial command and press **Tab** to complete from previous `!` commands in the current project
* Exit with `Escape`, `Backspace`, or `Ctrl+U` on an empty prompt
This is useful for quick shell operations while maintaining conversation context. 

## 

[​](#prompt-suggestions)

Prompt suggestions

When you first open a session, a grayed-out example command appears in the prompt input to help you get started. Claude Code picks this from your project’s git history, so it reflects files you’ve been working on recently. After Claude responds, suggestions continue to appear based on your conversation history, such as a follow-up step from a multi-part request or a natural continuation of your workflow. 
* Press **Tab** to accept the suggestion, or press **Enter** to accept and submit
* Start typing to dismiss it
The suggestion runs as a background request that reuses the parent conversation’s prompt cache, so the additional cost is minimal. Claude Code skips suggestion generation when the cache is cold to avoid unnecessary cost. Suggestions are automatically skipped after the first turn of a conversation, in non-interactive mode, and in plan mode. To disable prompt suggestions entirely, set the environment variable or toggle the setting in `/config`: 

Report incorrect code

Copy

Ask AI

```
export CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=false

```

## 

[​](#side-questions-with-/btw)

Side questions with /btw

Use `/btw` to ask a quick question about your current work without adding to the conversation history. This is useful when you want a fast answer but don’t want to clutter the main context or derail Claude from a long-running task. 

Report incorrect code

Copy

Ask AI

```
/btw what was the name of that config file again?

```

Side questions have full visibility into the current conversation, so you can ask about code Claude has already read, decisions it made earlier, or anything else from the session. The question and answer are ephemeral: they appear in a dismissible overlay and never enter the conversation history. 
* **Available while Claude is working**: you can run `/btw` even while Claude is processing a response. The side question runs independently and does not interrupt the main turn.
* **No tool access**: side questions answer only from what is already in context. Claude cannot read files, run commands, or search when answering a side question.
* **Single response**: there are no follow-up turns. If you need a back-and-forth, use a normal prompt instead.
* **Low cost**: the side question reuses the parent conversation’s prompt cache, so the additional cost is minimal.
Press **Space**, **Enter**, or **Escape** to dismiss the answer and return to the prompt. `/btw` is the inverse of a [subagent](https://code.claude.com/docs/en/interactive-mode/docs/en/sub-agents): it sees your full conversation but has no tools, while a subagent has full tools but starts with an empty context. Use `/btw` to ask about what Claude already knows from this session; use a subagent to go find out something new. 

## 

[​](#task-list)

Task list

When working on complex, multi-step work, Claude creates a task list to track progress. Tasks appear in the status area of your terminal with indicators showing what’s pending, in progress, or complete. 
* Press `Ctrl+T` to toggle the task list view. The display shows up to 10 tasks at a time
* To see all tasks or clear them, ask Claude directly: “show me all tasks” or “clear all tasks”
* Tasks persist across context compactions, helping Claude stay organized on larger projects
* To share a task list across sessions, set `CLAUDE_CODE_TASK_LIST_ID` to use a named directory in `~/.claude/tasks/`: `CLAUDE_CODE_TASK_LIST_ID=my-project claude`

## 

[​](#pr-review-status)

PR review status

When working on a branch with an open pull request, Claude Code displays a clickable PR link in the footer (for example, “PR #446”). The link has a colored underline indicating the review state: 
* Green: approved
* Yellow: pending review
* Red: changes requested
* Gray: draft
* Purple: merged
`Cmd+click` (Mac) or `Ctrl+click` (Windows/Linux) the link to open the pull request in your browser. The status updates automatically every 60 seconds. 

PR status requires the `gh` CLI to be installed and authenticated (`gh auth login`).

## 

[​](#see-also)

See also

* [Skills](https://code.claude.com/docs/en/interactive-mode/docs/en/skills) \- Custom prompts and workflows
* [Checkpointing](https://code.claude.com/docs/en/interactive-mode/docs/en/checkpointing) \- Rewind Claude’s edits and restore previous states
* [CLI reference](https://code.claude.com/docs/en/interactive-mode/docs/en/cli-reference) \- Command-line flags and options
* [Settings](https://code.claude.com/docs/en/interactive-mode/docs/en/settings) \- Configuration options
* [Memory management](https://code.claude.com/docs/en/interactive-mode/docs/en/memory) \- Managing CLAUDE.md files

Was this page helpful?

YesNo

[Tools reference](https://code.claude.com/docs/en/interactive-mode/docs/en/tools-reference)[Checkpointing](https://code.claude.com/docs/en/interactive-mode/docs/en/checkpointing)

⌘I

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/interactive-mode/docs/en/overview)

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