# RTK - Rust Token Killer

> Sources: https://www.rtk-ai.app/#install · https://github.com/rtk-ai/rtk/blob/master/README.md
> Captured: 2026-03-22

## Overview

RTK is an open-source CLI proxy written in Rust that compresses command outputs before they reach AI agents' context windows. Achieves **60–90% token reduction** on typical CLI outputs by filtering noise and verbose formatting.

- **License**: MIT
- **Language**: Rust (single compiled binary, zero dependencies)
- **Platforms**: macOS, Linux, Windows

## Problem It Solves

Verbose CLI outputs pollute the context window with data that isn't useful for code reasoning — progress bars, ANSI codes, redundant paths, passing test lines, etc. This causes:
- Shorter sessions on token-limited AI platforms
- Higher costs on pay-per-token APIs
- Less context available for actual reasoning

## Real-World Impact

- ~89% average noise removal from command outputs
- 3x longer sessions on AI coding platforms
- 15,720 commands processed → 138M tokens saved (reported user stat)
- ~70% cost reduction on pay-per-token APIs
- 30-minute Claude Code session: ~80% overall token savings

### Compression by Operation Type

| Operation | Reduction |
|-----------|-----------|
| `ls` / `tree` | 80% |
| `cat` (file read) | 70% |
| `grep` / search | 80% |
| Test execution | 90% |
| Build operations | 80–90% |

## Installation

**Quick install (Linux/macOS):**
```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```

**Homebrew:**
```bash
brew install rtk
```

**Cargo:**
```bash
cargo install rtk
```

**Activate globally (installs Claude Code hook):**
```bash
rtk init --global
```

**Verify:**
```bash
rtk --version
rtk gain
```

## How It Works

RTK installs a **Claude Code Bash hook** via `rtk init --global`. The hook transparently rewrites Bash tool calls to route through RTK before the output reaches the LLM context.

- Hook operates only on **Bash tool calls**
- Built-in tools (Read, Grep, Glob) are **not** intercepted — use explicit `rtk` commands for those
- `rtk proxy <cmd>` executes a command without filtering (for debugging)

## Command Categories

### File Operations
```bash
rtk ls [dir]          # Compressed directory listing
rtk cat <file>        # Filtered file read
rtk grep <pattern>    # Search with noise removed
rtk diff <a> <b>      # Focused diff output
```

### Version Control
```bash
rtk git status
rtk git log
rtk git diff
rtk git commit
```

### Testing (failure-only output)
```bash
rtk cargo test
rtk npm test
rtk pytest
rtk go test
```

### Build Tools
```bash
rtk tsc               # TypeScript
rtk eslint
rtk prettier
rtk next build
```

### Containers
```bash
rtk docker <cmd>
rtk kubectl <cmd>
```

### Analytics
```bash
rtk gain              # Show token savings summary
rtk gain --history    # Command usage history with savings
rtk discover          # Analyze Claude Code history for missed RTK opportunities
```

## Advanced Features

### Tee Mode
When a command fails, RTK preserves the full unfiltered output so the LLM has complete information without needing to re-run the command.

### Configuration
Supports config files for:
- Command exclusions (opt certain commands out of filtering)
- Storage path customization
- Per-project overrides

## Integrations

Works natively with:
- Claude Code (hook-based)
- Cursor
- Gemini CLI
- Aider
- OpenCode
- Codex
- Windsurf
- Cline

## Meta Commands (always invoke rtk directly, not via hook)

```bash
rtk gain              # Savings analytics
rtk gain --history    # Usage history
rtk discover          # Find missed optimization opportunities
rtk proxy <cmd>       # Raw passthrough (debugging)
```

## Notes

- The hook rewrites commands transparently — no change to developer workflow
- `rtk discover` is useful for finding commands that aren't yet being routed through RTK
- Savings compound over long sessions where context window pressure is highest
