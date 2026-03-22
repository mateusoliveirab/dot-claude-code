---
url: https://code.claude.com/docs/en/terminal-config
crawled_at: 2026-03-15T04:29:57Z
---

[Skip to main content](#content-area)

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/terminal-config/docs/en/overview)

![US](https://d3gk2c5xim1je2.cloudfront.net/flags/US.svg)

English

Search...

⌘KAsk AI

* [Claude Developer Platform](https://platform.claude.com/)
* [Claude Code on the Web](https://claude.ai/code)
* [Claude Code on the Web](https://claude.ai/code)

Search...

Navigation

Configuration

Optimize your terminal setup

[Getting started](https://code.claude.com/docs/en/terminal-config/docs/en/overview)[Build with Claude Code](https://code.claude.com/docs/en/terminal-config/docs/en/sub-agents)[Deployment](https://code.claude.com/docs/en/terminal-config/docs/en/third-party-integrations)[Administration](https://code.claude.com/docs/en/terminal-config/docs/en/setup)[Configuration](https://code.claude.com/docs/en/terminal-config/docs/en/settings)[Reference](https://code.claude.com/docs/en/terminal-config/docs/en/cli-reference)[Resources](https://code.claude.com/docs/en/terminal-config/docs/en/legal-and-compliance)

##### Configuration

* [Settings](https://code.claude.com/docs/en/terminal-config/docs/en/settings)
* [Permissions](https://code.claude.com/docs/en/terminal-config/docs/en/permissions)
* [Sandboxing](https://code.claude.com/docs/en/terminal-config/docs/en/sandboxing)
* [Terminal configuration](https://code.claude.com/docs/en/terminal-config/docs/en/terminal-config)
* [Model configuration](https://code.claude.com/docs/en/terminal-config/docs/en/model-config)
* [Speed up responses with fast mode](https://code.claude.com/docs/en/terminal-config/docs/en/fast-mode)
* [Customize status line](https://code.claude.com/docs/en/terminal-config/docs/en/statusline)
* [Customize keyboard shortcuts](https://code.claude.com/docs/en/terminal-config/docs/en/keybindings)

On this page

* [Themes and appearance](#themes-and-appearance)
* [Line breaks](#line-breaks)
* [Notification setup](#notification-setup)
* [Terminal notifications](#terminal-notifications)
* [Notification hooks](#notification-hooks)
* [Handling large inputs](#handling-large-inputs)
* [Vim Mode](#vim-mode)

Configuration

# Optimize your terminal setup

Copy page

Claude Code works best when your terminal is properly configured. Follow these guidelines to optimize your experience.

Copy page

### 

[​](#themes-and-appearance)

Themes and appearance

Claude cannot control the theme of your terminal. That’s handled by your terminal application. You can match Claude Code’s theme to your terminal any time via the `/config` command. For additional customization of the Claude Code interface itself, you can configure a [custom status line](https://code.claude.com/docs/en/terminal-config/docs/en/statusline) to display contextual information like the current model, working directory, or git branch at the bottom of your terminal. 

### 

[​](#line-breaks)

Line breaks

You have several options for entering line breaks into Claude Code: 
* **Quick escape**: Type `\` followed by Enter to create a newline
* **Shift+Enter**: Works out of the box in iTerm2, WezTerm, Ghostty, and Kitty
* **Keyboard shortcut**: Set up a keybinding to insert a newline in other terminals
**Set up Shift+Enter for other terminals** Run `/terminal-setup` within Claude Code to automatically configure Shift+Enter for VS Code, Alacritty, Zed, and Warp. 

The `/terminal-setup` command is only visible in terminals that require manual configuration. If you’re using iTerm2, WezTerm, Ghostty, or Kitty, you won’t see this command because Shift+Enter already works natively.

**Set up Option+Enter (VS Code, iTerm2 or macOS Terminal.app)** **For Mac Terminal.app:** 
1. Open Settings → Profiles → Keyboard
2. Check “Use Option as Meta Key”
**For iTerm2 and VS Code terminal:** 
1. Open Settings → Profiles → Keys
2. Under General, set Left/Right Option key to “Esc+“

### 

[​](#notification-setup)

Notification setup

When Claude finishes working and is waiting for your input, it fires a notification event. You can surface this event as a desktop notification through your terminal or run custom logic with [notification hooks](https://code.claude.com/docs/en/terminal-config/docs/en/hooks#notification). 

#### 

[​](#terminal-notifications)

Terminal notifications

Kitty and Ghostty support desktop notifications without additional configuration. iTerm 2 requires setup: 
1. Open iTerm 2 Settings → Profiles → Terminal
2. Enable “Notification Center Alerts”
3. Click “Filter Alerts” and check “Send escape sequence-generated alerts”
If notifications aren’t appearing, verify that your terminal app has notification permissions in your OS settings. Other terminals, including the default macOS Terminal, do not support native notifications. Use [notification hooks](https://code.claude.com/docs/en/terminal-config/docs/en/hooks#notification) instead. 

#### 

[​](#notification-hooks)

Notification hooks

To add custom behavior when notifications fire, such as playing a sound or sending a message, configure a [notification hook](https://code.claude.com/docs/en/terminal-config/docs/en/hooks#notification). Hooks run alongside terminal notifications, not as a replacement. 

### 

[​](#handling-large-inputs)

Handling large inputs

When working with extensive code or long instructions: 
* **Avoid direct pasting**: Claude Code may struggle with very long pasted content
* **Use file-based workflows**: Write content to a file and ask Claude to read it
* **Be aware of VS Code limitations**: The VS Code terminal is particularly prone to truncating long pastes

### 

[​](#vim-mode)

Vim Mode

Claude Code supports a subset of Vim keybindings that can be enabled with `/vim` or configured via `/config`. The supported subset includes: 
* Mode switching: `Esc` (to NORMAL), `i`/`I`, `a`/`A`, `o`/`O` (to INSERT)
* Navigation: `h`/`j`/`k`/`l`, `w`/`e`/`b`, `0`/`$`/`^`, `gg`/`G`, `f`/`F`/`t`/`T` with `;`/`,` repeat
* Editing: `x`, `dw`/`de`/`db`/`dd`/`D`, `cw`/`ce`/`cb`/`cc`/`C`, `.` (repeat)
* Yank/paste: `yy`/`Y`, `yw`/`ye`/`yb`, `p`/`P`
* Text objects: `iw`/`aw`, `iW`/`aW`, `i"`/`a"`, `i'`/`a'`, `i(`/`a(`, `i[`/`a[`, `i{`/`a{`
* Indentation: `>>`/`<<`
* Line operations: `J` (join lines)
See [Interactive mode](https://code.claude.com/docs/en/terminal-config/docs/en/interactive-mode#vim-editor-mode) for the complete reference.

Was this page helpful?

YesNo

[Sandboxing](https://code.claude.com/docs/en/terminal-config/docs/en/sandboxing)[Model configuration](https://code.claude.com/docs/en/terminal-config/docs/en/model-config)

⌘I

[Claude Code Docs home page![light logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/light.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=78fd01ff4f4340295a4f66e2ea54903c)![dark logo](https://mintcdn.com/claude-code/c5r9_6tjPMzFdDDT/logo/dark.svg?fit=max&auto=format&n=c5r9_6tjPMzFdDDT&q=85&s=1298a0c3b3a1da603b190d0de0e31712)](https://code.claude.com/docs/en/terminal-config/docs/en/overview)

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