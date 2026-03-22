# Channels — Push Events Into a Running Session

> Source: https://code.claude.com/docs/en/channels
> Captured: 2026-03-22

> **Research preview** — requires Claude Code v2.1.80+. Requires claude.ai login (not Console/API key). Team/Enterprise orgs must explicitly enable.

## Overview

A **channel** is an MCP server that pushes events into your running Claude Code session, so Claude can react to things that happen while you're not at the terminal.

- Events only arrive while the session is open
- Channels can be two-way (Claude reads event and replies back through the same channel)
- Install as a plugin, configure with your credentials
- Supported: **Telegram** and **Discord** (research preview)

When Claude replies through a channel:
- Inbound message visible in terminal
- Reply text appears on the other platform (not in terminal)
- Terminal shows the tool call and confirmation (e.g., "sent")

## Quickstart with Fakechat (localhost demo)

No auth, no external service. Tests the plugin flow before connecting a real platform.

**Prerequisites:** Claude Code + claude.ai login, [Bun](https://bun.sh) installed.

```text
/plugin install fakechat@claude-plugins-official
```

```bash
# Restart with channel enabled
claude --channels plugin:fakechat@claude-plugins-official
```

Open [http://localhost:8787](http://localhost:8787) and type a message. It arrives in your Claude Code session as a `<channel source="fakechat">` event. Claude replies; reply shows in the browser.

## Supported Channels

### Telegram

```text
/plugin install telegram@claude-plugins-official
/telegram:configure <token>
```

```bash
claude --channels plugin:telegram@claude-plugins-official
```

Then pair your account:
1. Send any message to your bot in Telegram → bot replies with pairing code
2. In Claude Code: `/telegram:access pair <code>`
3. Lock down: `/telegram:access policy allowlist`

### Discord

```text
/plugin install discord@claude-plugins-official
/discord:configure <token>
```

```bash
claude --channels plugin:discord@claude-plugins-official
```

Then pair:
1. DM your bot on Discord → bot replies with pairing code
2. In Claude Code: `/discord:access pair <code>`
3. Lock down: `/discord:access policy allowlist`

Required bot permissions: View Channels, Send Messages, Send Messages in Threads, Read Message History, Attach Files, Add Reactions. Also enable **Message Content Intent** in Discord Developer Portal.

## Security

- Each approved channel plugin maintains a **sender allowlist**: only IDs you've added can push messages
- Everyone else is silently dropped
- Bootstrap via pairing (send message → get code → approve in Claude Code → ID added to allowlist)
- `--channels` flag controls which servers are enabled each session
- Being in `.mcp.json` isn't enough — server must also be named in `--channels`

## Plugin Marketplace

If plugin is not found:
```text
/plugin marketplace update claude-plugins-official
# or add if missing:
/plugin marketplace add anthropics/claude-plugins-official
```

After installing: `/reload-plugins` to activate plugin's configure command.

## Enterprise Controls

Controlled by `channelsEnabled` in managed settings.

| Plan type                  | Default                                               |
| -------------------------- | ----------------------------------------------------- |
| Pro / Max, no organization | Available; users opt in per session with `--channels` |
| Team / Enterprise          | Disabled until admin explicitly enables               |

Enable at: **claude.ai → Admin settings → Claude Code → Channels**

## How Channels Compare

| Feature                  | What it does                                               | Good for                                              |
| ------------------------ | ---------------------------------------------------------- | ----------------------------------------------------- |
| Claude Code on the web   | Runs tasks in fresh cloud sandbox, cloned from GitHub      | Delegating async work you check on later              |
| Claude in Slack          | Spawns web session from `@Claude` mention                  | Starting tasks from team conversation context         |
| Standard MCP server      | Claude queries it during a task; nothing pushed to session | On-demand access to read or query a system            |
| Remote Control           | Drive local session from claude.ai or mobile app          | Steering in-progress session while away from desk     |
| **Channels**             | Push events from non-Claude sources into running session   | Chat bridge, webhook receiver, CI results, monitoring |

## Use Cases

- **Chat bridge**: ask Claude from your phone via Telegram/Discord; answer comes back in chat while work runs on your machine against real files
- **Webhook receiver**: CI failure, error tracker, deploy pipeline event arrives where Claude already has your files open

## Research Preview Notes

- `--channels` only accepts plugins from Anthropic-maintained allowlist
- Approved plugins: [claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins)
- To test a custom channel you're building: `--dangerously-load-development-channels`
- Syntax and protocol contract may change based on feedback

## Permission Handling

If Claude hits a permission prompt while you're away, the session pauses until you respond. Channel servers that declare the [permission relay capability](/en/channels-reference#relay-permission-prompts) can forward prompts to you remotely.

For unattended use: `--dangerously-skip-permissions` (only in environments you trust).

## Multiple Channels

```bash
# Pass several plugins space-separated
claude --channels plugin:fakechat@claude-plugins-official plugin:telegram@claude-plugins-official
```
