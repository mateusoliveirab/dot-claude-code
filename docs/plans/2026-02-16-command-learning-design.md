# Command Learning System - Design Document

## Overview

A passive learning system that allows Claude Code to capture and reference command-line help documentation, improving accuracy when using CLI tools across all projects.

## Goals

- Capture `--help` documentation for CLI commands on-demand
- Store concisely in global Claude Code installation
- Provide context automatically via rules
- Keep it simple - no scoring, tracking, or complex automation

## Approach

**Passive Learning** - Claude suggests capturing when it encounters errors or complex commands. User has full control over what gets documented.

## Architecture

### File Structure

```
~/.claude/
├── expertise/
│   └── commands.json              # Command help database
├── rules/
│   └── command-expertise.md       # Auto-generated rule
└── skills/
    └── learn-command/
        ├── skill.md               # Main skill interface
        └── helpers.sh             # Capture & regenerate scripts
```

### Components

| Component | Responsibility |
|-----------|----------------|
| `/learn-command` skill | CLI interface - capture, list, refresh |
| `commands.json` | Storage of all captured command helps |
| `command-expertise.md` | Auto-loaded rule with all commands |
| `helpers.sh` | Capture --help + regenerate rule |

### Data Model

**commands.json:**
```json
{
  "git": "usage: git [--version] [...]\nThese are common Git commands...",
  "docker": "Usage: docker [OPTIONS] COMMAND\nA self-sufficient runtime..."
}
```

**command-expertise.md (generated):**
```markdown
# Command Expertise

## git
usage: git [--version] [...]
These are common Git commands...

## docker
Usage: docker [OPTIONS] COMMAND
A self-sufficient runtime...
```

## Data Flow

```
User/Claude identifies useful command
         ↓
   /learn-command docker
         ↓
   Execute: docker --help | head -50
         ↓
   Add to ~/.claude/expertise/commands.json
         ↓
   Regenerate ~/.claude/rules/command-expertise.md
         ↓
   Rule auto-loaded in future conversations
```

## Skill Interface

**Commands:**
- `/learn-command <command>` - Capture help for a command
- `/learn-command --list` - List all captured commands
- `/learn-command --refresh` - Manually regenerate rule from JSON

## Implementation Details

### Capturing Help

Try in order:
1. `<command> --help | head -50`
2. `<command> -h | head -50`
3. `help <command> | head -50`

### Rule Generation

- Read all entries from `commands.json`
- Generate markdown with `## <command>` sections
- Write to `~/.claude/rules/command-expertise.md`
- If > 200 lines, warn user but keep JSON intact

### Error Handling

| Error | Solution |
|-------|----------|
| Command doesn't exist | Return clear error, don't add to JSON |
| `--help` not available | Try `-h`, then `help <command>` |
| JSON corrupted | Auto-backup before modifying |
| Rule too large | Warn user, suggest removing unused commands |

## Testing Checklist

- [ ] Capture help for valid command
- [ ] Add to JSON correctly
- [ ] Regenerate rule without breaking format
- [ ] List existing commands
- [ ] Handle invalid commands gracefully
- [ ] Backup JSON before modifications
- [ ] Fallback to `-h` if `--help` fails

## Success Criteria

1. `/learn-command git` captures and stores git help
2. `commands.json` contains valid JSON
3. `command-expertise.md` is generated and loadable as rule
4. `/learn-command --list` shows all captured commands
5. Rule provides accurate command syntax in future conversations
6. Invalid commands handled without breaking system

## Out of Scope

- Automatic capture via hooks
- Usage tracking/scoring
- Error detection and auto-learning
- Command categorization/tagging
- Version tracking for commands

## Future Enhancements

(Only if proven necessary)
- Compress help output further if rules get too large
- Command aliases/shortcuts
- Export/import for sharing across machines
