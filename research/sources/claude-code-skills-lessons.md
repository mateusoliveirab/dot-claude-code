---
url: https://x.com/trq212/status/2033949937936085378
crawled_at: 2026-03-22
tags: [claude-code, skills, plugins, best-practices, anthropic]
---

# Lessons from Building Claude Code: How We Use Skills

Skills have become one of the most used extension points in Claude Code. They're flexible, easy to make, and simple to distribute.

But this flexibility also makes it hard to know what works best. What type of skills are worth making? What's the secret to writing a good skill? When do you share them with others?

We've been using skills in Claude Code extensively at Anthropic with hundreds of them in active use. These are the lessons we've learned about using skills to accelerate our development.

## What are Skills?

A common misconception we hear about skills is that they are "just markdown files", but the most interesting part of skills is that they're not just text files. They're **folders** that can include scripts, assets, data, etc. that the agent can discover, explore and manipulate.

In Claude Code, skills also have a wide variety of configuration options including registering dynamic hooks.

## Types of Skills

After cataloging all of our skills, we noticed they cluster into a few recurring categories. The best skills fit cleanly into one; the more confusing ones straddle several.

### 1. Library & API Reference
Skills that explain how to correctly use a library, CLI, or SDKs — both internal libraries or common ones Claude sometimes has trouble with. Often include a folder of reference code snippets and a list of gotchas.

Examples:
- `billing-lib` — internal billing library: edge cases, footguns, etc.
- `internal-platform-cli` — every subcommand with examples on when to use them
- `frontend-design` — make Claude better at your design system

### 2. Product Verification
Skills that describe how to test or verify that your code is working. Often paired with an external tool like playwright, tmux, etc.

> Verification skills are extremely useful for ensuring Claude's output is correct. It can be worth having an engineer spend a week just making your verification skills excellent.

Examples:
- `signup-flow-driver` — runs through signup → email verify → onboarding in a headless browser
- `checkout-verifier` — drives the checkout UI with Stripe test cards, verifies invoice state
- `tmux-cli-driver` — for interactive CLI testing where the thing needs a TTY

### 3. Data Fetching & Analysis
Skills that connect to your data and monitoring stacks, including credentials, dashboard IDs, and common workflows.

Examples:
- `funnel-query` — "which events do I join to see signup → activation → paid"
- `cohort-compare` — compare two cohorts' retention or conversion, flag statistically significant deltas
- `grafana` — datasource UIDs, cluster names, problem → dashboard lookup table

### 4. Business Process & Team Automation
Skills that automate repetitive workflows into one command. Saving previous results in log files helps the model stay consistent and reflect on previous executions.

Examples:
- `standup-post` — aggregates ticket tracker, GitHub activity, and prior Slack → formatted standup
- `create-<ticket-system>-ticket` — enforces schema plus post-creation workflow
- `weekly-recap` — merged PRs + closed tickets + deploys → formatted recap post

### 5. Code Scaffolding & Templates
Skills that generate framework boilerplate for a specific function in codebase. Especially useful when scaffolding has natural language requirements that can't be purely covered by code.

Examples:
- `new-<framework>-workflow` — scaffolds a new service/workflow/handler with your annotations
- `new-migration` — migration file template plus common gotchas
- `create-app` — new internal app with auth, logging, and deploy config pre-wired

### 6. Code Quality & Review
Skills that enforce code quality and help review code. Can include deterministic scripts or tools for maximum robustness. Can be run automatically as part of hooks or GitHub Actions.

Examples:
- `adversarial-review` — spawns a fresh-eyes subagent to critique, implements fixes, iterates until findings degrade to nitpicks
- `code-style` — enforces code style, especially styles Claude does not do well by default
- `testing-practices` — instructions on how to write tests and what to test

### 7. CI/CD & Deployment
Skills that help you fetch, push, and deploy code.

Examples:
- `babysit-pr` — monitors a PR → retries flaky CI → resolves merge conflicts → enables auto-merge
- `deploy-<service>` — build → smoke test → gradual traffic rollout with error-rate comparison → auto-rollback
- `cherry-pick-prod` — isolated worktree → cherry-pick → conflict resolution → PR with template

### 8. Runbooks
Skills that take a symptom (Slack thread, alert, error signature), walk through a multi-tool investigation, and produce a structured report.

Examples:
- `<service>-debugging` — maps symptoms → tools → query patterns for your highest-traffic services
- `oncall-runner` — fetches the alert → checks the usual suspects → formats a finding
- `log-correlator` — given a request ID, pulls matching logs from every system that might have touched it

### 9. Infrastructure Operations
Skills that perform routine maintenance and operational procedures — some involving destructive actions that benefit from guardrails.

Examples:
- `<resource>-orphans` — finds orphaned pods/volumes → posts to Slack → soak period → user confirms → cascading cleanup
- `dependency-management` — your org's dependency approval workflow
- `cost-investigation` — "why did our storage/egress bill spike" with the specific buckets and query patterns

## Tips for Making Skills

### Don't State the Obvious
Claude Code knows a lot about your codebase, and Claude knows a lot about coding. If you're publishing a skill that is primarily about knowledge, focus on information that **pushes Claude out of its normal way of thinking**.

### Build a Gotchas Section
The highest-signal content in any skill is the Gotchas section. These sections should be built up from common failure points. Ideally, update your skill over time to capture these gotchas.

### Use the File System & Progressive Disclosure
A skill is a folder, not just a markdown file. Think of the entire file system as a form of context engineering and progressive disclosure. Tell Claude what files are in your skill, and it will read them at appropriate times.

- Split detailed function signatures and usage examples into `references/api.md`
- Include template files in `assets/` to copy and use
- Have folders of references, scripts, examples, etc.

### Avoid Railroading Claude
Give Claude the information it needs, but give it the flexibility to adapt to the situation. Skills are reusable, so being too specific can backfire.

### Think Through the Setup
Some skills need to be set up with context from the user. A good pattern is to store setup information in a `config.json` file in the skill directory. If the config is not set up, the agent asks the user for information.

### The Description Field Is For the Model
When Claude Code starts a session, it builds a listing of every available skill with its description. This is what Claude scans to decide "is there a skill for this request?" The description field is not a summary — it's a description of **when to trigger** this skill.

### Memory & Storing Data
Skills can include a form of memory by storing data within them — anything from an append-only text log file to a JSON file or SQLite database.

> Data stored in the skill directory may be deleted when you upgrade the skill, so store persistent data in `${CLAUDE_PLUGIN_DATA}` — a stable folder per plugin.

### Store Scripts & Generate Code
Giving Claude scripts and libraries lets it spend its turns on composition — deciding what to do next rather than reconstructing boilerplate. Claude can then generate scripts on the fly to compose this functionality for more advanced analysis.

### On Demand Hooks
Skills can include hooks that are only activated when the skill is called, lasting for the duration of the session. Use this for opinionated hooks you don't want running all the time.

Examples:
- `/careful` — blocks `rm -rf`, `DROP TABLE`, force-push, `kubectl delete` via PreToolUse matcher on Bash
- `/freeze` — blocks any Edit/Write not in a specific directory (useful when debugging)

## Distributing Skills

Two ways to share skills with your team:
1. Check skills into your repo (under `./.claude/skills`)
2. Make a plugin and use a Claude Code Plugin marketplace

For smaller teams, checking skills into repos works well. As you scale, an internal plugin marketplace lets your team decide which ones to install.

### Managing a Marketplace
- No need for a centralized team — find useful skills organically
- Upload to a sandbox folder in GitHub and share the link in Slack/forums
- Once a skill has gotten traction, open a PR to move it into the marketplace
- Have some method of curation before release — bad or redundant skills accumulate quickly

### Composing Skills
You can have skills that depend on each other. Dependency management is not natively built into marketplaces yet, but you can reference other skills by name and the model will invoke them if installed.

### Measuring Skills
Use a PreToolUse hook to log skill usage. This lets you find skills that are popular or undertriggering compared to expectations.

## Conclusion

Skills are incredibly powerful, flexible tools for agents, but it's still early. Think of this more as a grab bag of useful tips than a definitive guide. Most skills began as a few lines and a single gotcha, and got better because people kept adding to them as Claude hit new edge cases.
