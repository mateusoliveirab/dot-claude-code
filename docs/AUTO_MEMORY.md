# Auto Memory

Auto memory is a relatively new feature in Claude Code (introduced in v2.1.32 on February 5, 2025) that lets Claude remember project-specific learnings across conversations. As Claude works with you, it automatically records mistakes, discovers patterns, and finds better approaches in `~/.claude/projects/<project-path>/memory/MEMORY.md`.

**The key insight:** This is local AI memory (volatile, not versioned) — not project documentation. Think of it as Claude's personal notebook. Important learnings should be promoted to versioned files like `CLAUDE.md`, `CONTRIBUTING.md`, or `ARCHITECTURE.md` that your whole team can benefit from.

**Where it lives:** `~/.claude/projects/-home-ubuntu-vscode-repositories-<project>/memory/MEMORY.md`

**What you need to know:** Local only, automatic, per-project, max 200 lines, doesn't (and shouldn't) go to git

## How It Works

1. **Claude learns** — identifies non-obvious solutions, mistakes, workflow patterns
2. **Writes to MEMORY.md** — proactively updates using Write/Edit tools
3. **Consults automatically** — loads in future conversations to avoid mistakes and work efficiently

## What Goes In It

| ✅ Should write | ❌ Should not write |
|----------------|---------------------|
| Non-obvious solutions | General programming knowledge |
| Mistakes and lessons learned | Project details (use `CLAUDE.md`) |
| Workflow patterns | Temporary workarounds |
| Tool/MCP discoveries | Well-documented information |

**Examples of good entries:**
- "User has dev server running, don't start `npm run dev`"
- "Use Edit tool instead of sed for file changes"
- "User reviews PRs manually, don't auto-push"

## MEMORY.md vs Project Files

**The fundamental difference:**

| | MEMORY.md | Project Files |
|---|---|---|
| **Purpose** | AI memory | Official documentation |
| **Location** | `~/.claude/projects/...` | Inside repository |
| **Versioning** | ❌ No | ✅ Yes |
| **Sharing** | ❌ Local only | ✅ Via git |
| **Durability** | Volatile | Permanent |

**Use MEMORY.md for:** Learning drafts, trial/error, personal workflow preferences

**Use versioned files for:** Permanent docs, team knowledge, architectural decisions

### Files Worth Versioning

Instead of relying only on MEMORY.md, create official files in your repository:

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project-specific instructions for Claude |
| `CONTRIBUTING.md` | Contributor guide (humans and AI) |
| `ARCHITECTURE.md` | Technical decisions, context |
| `docs/` | Feature/module documentation |

**Golden rule:** If a MEMORY.md learning proves permanent and useful, promote it to official project documentation.

## Example

**Situation:** Claude tries `npm run dev`, server already running → port conflict

**What happens:**
1. Claude learns it caused a problem
2. Writes to MEMORY.md:
   ```markdown
   ## Dev Server
   - User has dev server running
   - Don't start npm run dev automatically
   - Test on localhost:3000
   ```
3. Next conversation: Claude won't try to start server

**Promote to docs:** If important for the team, add to `CONTRIBUTING.md`:
```markdown
## Development
Server usually runs already. Check first: `lsof -ti:3000`
```

## Best Practices

**For everyone:**
- Don't version in git (already ignored implicitly)
- Let Claude manage content automatically
- Promote important learnings to official docs
- Reset if cluttered: `rm ~/.claude/projects/.../memory/MEMORY.md`
- Keep concise (200 line limit)
- Focus on actionable insights
- Remove obsolete content

**Check your memory:**
```bash
cat ~/.claude/projects/-home-ubuntu-vscode-repositories-<project>/memory/MEMORY.md
```

## FAQ

**Does Claude always write to it?**
No. Only for non-obvious learnings and useful patterns.

**Can I have MEMORY.md AND CLAUDE.md?**
Yes, expected:
- MEMORY.md → volatile AI memory (local)
- CLAUDE.md → permanent instructions (versioned)

**What if it gets too large?**
Truncates after 200 lines. Claude should keep concise.

**Can I reset it?**
Yes: `rm ~/.claude/projects/.../memory/MEMORY.md`
Claude starts fresh next time.

**Is it shared across projects?**
No. Each project has independent memory.

**Can I edit it manually?**
Yes, but Claude manages it automatically.

## References

- [Manage Claude's memory - Claude Code Docs](https://code.claude.com/docs/en/memory)
- [Claude Code CHANGELOG.md](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- [Claude Code Releases](https://github.com/anthropics/claude-code/releases)
- [Claude Code Changelog | ClaudeLog](https://claudelog.com/claude-code-changelog/)
