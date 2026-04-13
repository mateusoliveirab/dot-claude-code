---
url: https://x.com/bcherny/status/2017742741636321619
author: bcherny (Boris Cherny)
crawled_at: 2026-03-22
tags: [claude-code, tips, subagents, prompting, analytics, learning, terminal, bugs]
note: some threads were truncated ("Show more") — content is partial
---

# Claude Code Tips — Boris Cherny (Anthropic)

## 5. Claude Fixes Most Bugs by Itself

- Enable the **Slack MCP**, then paste a Slack bug thread into Claude and say "fix." Zero context switching required.
- Say "Go fix the failing CI tests." Don't micromanage how.
- Point Claude at docker logs to diagnose issues. *(thread truncated)*

## 6. Level Up Your Prompting

**a. Challenge Claude:**
- Say "Grill me on these changes and don't make a PR until I pass your test." Make Claude be your reviewer.
- Say "Prove to me this works" and have Claude diff behavior between main and your feature branch.

**b.** After a mediocre response *(thread truncated)*

## 7. Terminal & Environment Setup

- The team loves **Ghostty** — synchronized rendering, 24-bit color, proper unicode support.
- Use `/statusline` to customize your status bar to always show context usage and current git branch.
- *(thread truncated)*

## 8. Use Subagents

**a.** Append "use subagents" to any request where you want Claude to throw more compute at the problem.

**b.** Offload individual tasks to subagents to keep your main agent's context window clean and focused.

**c.** Route permission requests to Opus 4.5 via a hook — let it *(thread truncated)*

## 9. Use Claude for Data & Analytics

- Ask Claude Code to use the `bq` CLI to pull and analyze metrics on the fly.
- Keep a **BigQuery skill** checked into the codebase — everyone on the team uses it for analytics queries directly in Claude Code.
- "Personally, I haven't written a line [of SQL manually]" *(thread truncated)*

## 10. Learning with Claude

**a.** Enable the "Explanatory" or "Learning" output style in `/config` to have Claude explain the *why* behind its changes.

**b.** Have Claude generate a visual HTML presentation explaining unfamiliar concepts. *(thread truncated)*

## 11. Fork your session (Thread 8/)
- Run `/branch` from your session.
- From the CLI, run `claude --resume <session-id> --fork-session`.

## 12. Use /btw for side queries (Thread 9/)
- Use it to answer quick questions while the agent works.

## 13. Use git worktrees (Thread 10/)
- Claude Code ships with deep support for git worktrees. Worktrees are essential for doing lots of parallel work in the same repository.
- Use `claude -w` to start a new session in a *(thread truncated)*.

## 14. Use /batch to fan out massive changesets (Thread 11/)
- `/batch` interviews you, then has Claude fan out the work to as many worktree agents as it takes (dozens, hundreds, even thousands) to get it done.
- Use it for large code migrations and other kinds of parallelizable work. *(thread truncated)*.

## 15. Use --bare to speed up SDK startup by up to 10x (Thread 12/)
- By default, when you run `claude -p` (or the TypeScript or Python SDKs) we search for local `CLAUDE.md`s, settings, and MCPs.
- But for non-interactive usage, most of the time you want to explicitly specify what to load via *(thread truncated)*.

## 16. Use --add-dir to give Claude access to more folders (Thread 13/)
- When working across multiple repositories, start Claude in one repo and use `--add-dir` (or `/add-dir`) to let Claude see the other repo. This not only tells Claude about the repo, but also gives it permissions to *(thread truncated)*.

## 17. Use --agent for custom system prompts & tools (Thread 14/)
- Custom agents are a powerful primitive that often gets overlooked.
- To use it, just define a new agent in `.claude/agents`, then run `claude --agent=<your agent's name>`.
- Docs: https://code.claude.com/docs/en/sub-agents

## 18. Use /voice to enable voice input (Thread 15/)
- Run `/voice` in CLI then hold the space bar, press the voice button on Desktop, or enable dictation in your iOS settings.
