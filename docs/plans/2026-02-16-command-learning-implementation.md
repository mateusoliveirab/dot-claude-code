# Command Learning System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a passive learning system that captures CLI command help documentation for global use across all Claude Code projects.

**Architecture:** Simple skill-based system with JSON storage and auto-generated rule. User manually invokes `/learn-command <cmd>` to capture help text, which gets stored in `~/.claude/expertise/commands.json` and regenerated into `~/.claude/rules/command-expertise.md`.

**Tech Stack:** Bash scripts, JSON (jq), Markdown, Claude Code skills

---

## Task 1: Create Directory Structure

**Files:**
- Create: `~/.claude/expertise/`
- Create: `~/.claude/skills/learn-command/`

**Step 1: Create expertise directory**

Run: `mkdir -p ~/.claude/expertise`
Expected: Directory created

**Step 2: Create skill directory**

Run: `mkdir -p ~/.claude/skills/learn-command`
Expected: Directory created

**Step 3: Verify structure**

Run: `ls -la ~/.claude/ | grep -E "expertise|skills"`
Expected: Both directories listed

**Step 4: Commit**

```bash
# Will commit after validation
```

---

## Task 2: Create Initial JSON Database

**Files:**
- Create: `~/.claude/expertise/commands.json`

**Step 1: Create empty JSON file**

Create file with content:
```json
{}
```

**Step 2: Verify JSON is valid**

Run: `cat ~/.claude/expertise/commands.json | jq .`
Expected: `{}`

**Step 3: Test adding an entry manually**

Run: `jq '. + {"test": "test help output"}' ~/.claude/expertise/commands.json`
Expected: JSON with test entry

---

## Task 3: Create Helper Script - Capture Function

**Files:**
- Create: `~/.claude/skills/learn-command/helpers.sh`

**Step 1: Create helpers script with capture_help function**

```bash
#!/bin/bash

# Capture help output for a command
# Args: $1 = command name
# Returns: Help text (first 50 lines) or error
capture_help() {
    local cmd="$1"
    local help_output=""

    # Check if command exists
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: Command '$cmd' not found"
        return 1
    fi

    # Try --help
    if help_output=$($cmd --help 2>&1 | head -50); then
        echo "$help_output"
        return 0
    fi

    # Try -h
    if help_output=$($cmd -h 2>&1 | head -50); then
        echo "$help_output"
        return 0
    fi

    # Try help command
    if help_output=$(help "$cmd" 2>&1 | head -50); then
        echo "$help_output"
        return 0
    fi

    echo "Error: Could not get help for '$cmd'"
    return 1
}
```

**Step 2: Make script executable**

Run: `chmod +x ~/.claude/skills/learn-command/helpers.sh`
Expected: Script is executable

**Step 3: Test capture_help function**

Run: `source ~/.claude/skills/learn-command/helpers.sh && capture_help git | head -5`
Expected: First 5 lines of git help

**Step 4: Test with invalid command**

Run: `source ~/.claude/skills/learn-command/helpers.sh && capture_help nonexistentcmd123`
Expected: "Error: Command 'nonexistentcmd123' not found"

---

## Task 4: Create Helper Script - Add to JSON Function

**Files:**
- Modify: `~/.claude/skills/learn-command/helpers.sh`

**Step 1: Add add_to_json function**

Add after capture_help:
```bash

# Add command help to JSON database
# Args: $1 = command name, $2 = help text
# Returns: 0 on success, 1 on failure
add_to_json() {
    local cmd="$1"
    local help_text="$2"
    local json_file="$HOME/.claude/expertise/commands.json"

    # Backup JSON
    cp "$json_file" "${json_file}.backup"

    # Escape help text for JSON
    local escaped_help=$(echo "$help_text" | jq -Rs .)

    # Add to JSON
    if jq --arg cmd "$cmd" --argjson help "$escaped_help" \
        '. + {($cmd): $help}' "$json_file" > "${json_file}.tmp"; then
        mv "${json_file}.tmp" "$json_file"
        echo "Added '$cmd' to database"
        return 0
    else
        echo "Error: Failed to update JSON"
        mv "${json_file}.backup" "$json_file"
        return 1
    fi
}
```

**Step 2: Test add_to_json function**

Run:
```bash
source ~/.claude/skills/learn-command/helpers.sh
help_text=$(capture_help git)
add_to_json "git" "$help_text"
```
Expected: "Added 'git' to database"

**Step 3: Verify JSON contains git**

Run: `jq '.git' ~/.claude/expertise/commands.json | head -3`
Expected: First 3 lines of git help

**Step 4: Test backup on failure**

Manually corrupt JSON, try adding, verify backup restored

---

## Task 5: Create Helper Script - Regenerate Rule Function

**Files:**
- Modify: `~/.claude/skills/learn-command/helpers.sh`

**Step 1: Add regenerate_rule function**

Add after add_to_json:
```bash

# Regenerate command-expertise.md from JSON
# Returns: 0 on success, 1 on failure
regenerate_rule() {
    local json_file="$HOME/.claude/expertise/commands.json"
    local rule_file="$HOME/.claude/rules/command-expertise.md"

    # Create rules directory if needed
    mkdir -p "$HOME/.claude/rules"

    # Start rule file
    echo "# Command Expertise" > "$rule_file"
    echo "" >> "$rule_file"
    echo "CLI command help documentation captured for reference." >> "$rule_file"
    echo "" >> "$rule_file"

    # Add each command
    jq -r 'to_entries[] | "## \(.key)\n\n```\n\(.value)\n```\n"' "$json_file" >> "$rule_file"

    # Check line count
    local line_count=$(wc -l < "$rule_file")
    if [ "$line_count" -gt 200 ]; then
        echo "Warning: Rule file has $line_count lines (>200). Consider removing unused commands."
    fi

    echo "Regenerated rule: $rule_file ($line_count lines)"
    return 0
}
```

**Step 2: Test regenerate_rule function**

Run: `source ~/.claude/skills/learn-command/helpers.sh && regenerate_rule`
Expected: "Regenerated rule: ~/.claude/rules/command-expertise.md (N lines)"

**Step 3: Verify rule file exists and has correct format**

Run: `head -20 ~/.claude/rules/command-expertise.md`
Expected: Header + git section with help text

**Step 4: Test line count warning**

Add multiple commands to trigger >200 line warning (if needed for validation)

---

## Task 6: Create Skill Interface

**Files:**
- Create: `~/.claude/skills/learn-command/skill.md`

**Step 1: Create skill.md**

```markdown
---
name: learn-command
description: Capture CLI command help documentation for global reference
invocation: /learn-command
---

# Learn Command

Capture and store CLI command help documentation for improved accuracy across all projects.

## Usage

**Capture a command:**
```
/learn-command <command>
```

**List captured commands:**
```
/learn-command --list
```

**Refresh rule from database:**
```
/learn-command --refresh
```

## Process

When you invoke this skill:

1. **Parse arguments** - Get command name or flag
2. **Execute appropriate action:**
   - `<command>`: Capture help and add to database
   - `--list`: Show all captured commands
   - `--refresh`: Regenerate rule from JSON

3. **For capture:**
   - Run `capture_help <command>`
   - Add to `~/.claude/expertise/commands.json`
   - Regenerate `~/.claude/rules/command-expertise.md`

4. **Report results** to user

## Implementation

Source the helpers script and call appropriate functions:

```bash
source ~/.claude/skills/learn-command/helpers.sh

if [ "$1" = "--list" ]; then
    jq -r 'keys[]' ~/.claude/expertise/commands.json
elif [ "$1" = "--refresh" ]; then
    regenerate_rule
else
    cmd="$1"
    help_text=$(capture_help "$cmd")
    if [ $? -eq 0 ]; then
        add_to_json "$cmd" "$help_text"
        regenerate_rule
    fi
fi
```

## Files Modified

- `~/.claude/expertise/commands.json` - Command database
- `~/.claude/rules/command-expertise.md` - Auto-generated rule

## Success Criteria

- Command help captured accurately
- JSON remains valid after updates
- Rule regenerated with proper markdown format
- Error handling for invalid commands
```

**Step 2: Verify skill can be loaded**

Run: `cat ~/.claude/skills/learn-command/skill.md | grep "^name:"`
Expected: "name: learn-command"

---

## Task 7: Test End-to-End - Capture Command

**Step 1: Test capturing git**

Invoke: `/learn-command git`
Expected:
- "Added 'git' to database"
- "Regenerated rule: ..."

**Step 2: Verify JSON has git entry**

Run: `jq 'has("git")' ~/.claude/expertise/commands.json`
Expected: `true`

**Step 3: Verify rule has git section**

Run: `grep "^## git" ~/.claude/rules/command-expertise.md`
Expected: "## git"

**Step 4: Test capturing docker**

Invoke: `/learn-command docker`
Expected: Both git and docker in JSON and rule

---

## Task 8: Test End-to-End - List Commands

**Step 1: Invoke list**

Invoke: `/learn-command --list`
Expected: List showing "git" and "docker"

**Step 2: Verify list output format**

Output should be one command per line, sorted alphabetically

---

## Task 9: Test End-to-End - Refresh Rule

**Step 1: Manually add entry to JSON**

Run: `jq '. + {"curl": "curl - transfer a URL"}' ~/.claude/expertise/commands.json | sponge ~/.claude/expertise/commands.json`

**Step 2: Invoke refresh**

Invoke: `/learn-command --refresh`
Expected: "Regenerated rule: ..."

**Step 3: Verify rule has curl section**

Run: `grep "^## curl" ~/.claude/rules/command-expertise.md`
Expected: "## curl"

---

## Task 10: Test Error Handling

**Step 1: Test invalid command**

Invoke: `/learn-command invalidcmd999`
Expected: "Error: Command 'invalidcmd999' not found"

**Step 2: Verify JSON unchanged**

Run: `jq 'has("invalidcmd999")' ~/.claude/expertise/commands.json`
Expected: `false`

**Step 3: Test with no arguments**

Invoke: `/learn-command`
Expected: Clear error message explaining usage

---

## Task 11: Validate Rule Loads in Claude Code

**Step 1: Start new Claude Code conversation**

Run: `claude` (new session)

**Step 2: Check if rule is loaded**

Ask Claude: "What commands do you have help documentation for?"
Expected: Claude should reference command-expertise.md

**Step 3: Test using captured command**

Ask Claude: "Show me the git command syntax"
Expected: Claude references captured help

---

## Task 12: Final Validation & Commit

**Step 1: Run all tests again**

- Capture new command
- List commands
- Refresh rule
- Verify invalid command handling

**Step 2: Check file sizes**

Run: `du -h ~/.claude/expertise/commands.json ~/.claude/rules/command-expertise.md`
Expected: Reasonable sizes

**Step 3: Commit design and implementation**

```bash
git add docs/plans/2026-02-16-command-learning-design.md
git add docs/plans/2026-02-16-command-learning-implementation.md
git commit -m "docs: add command learning system design and implementation plan

Passive learning system for capturing CLI help documentation.

Features:
- /learn-command skill for manual capture
- JSON storage + auto-generated rule
- Simple, no scoring or tracking

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**Step 4: Document in README**

Add section about command learning system to main README.md

---

## Notes

- **jq required:** Install with `sudo apt install jq` or `brew install jq`
- **sponge required for some operations:** Install with `sudo apt install moreutils`
- **Rule size:** Monitor and warn if >200 lines
- **Backups:** JSON backed up before each modification
- **Testing:** Each function tested independently before integration

## Future Enhancements

(Only if needed based on usage)
- Command aliases/shortcuts
- Export/import commands
- Compress help output if rules get large
- Integration with project-specific CLAUDE.md
