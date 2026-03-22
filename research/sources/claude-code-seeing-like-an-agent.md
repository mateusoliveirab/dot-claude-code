---
url: https://x.com/trq212/status/2027463795355095314
crawled_at: 2026-03-22
tags: [claude-code, agents, tools, tool-design, elicitation, progressive-disclosure, anthropic]
---

# Lessons from Building Claude Code: Seeing like an Agent

One of the hardest parts of building an agent harness is constructing its action space.

Claude acts through Tool Calling, but there are a number of ways tools can be constructed in the Claude API — with primitives like bash, skills, and code execution.

A useful mental model: imagine being given a difficult math problem. What tools would you want in order to solve it?
- Paper: minimum, but limited by manual calculations
- Calculator: better, but you need to know how to operate advanced options
- Computer: fastest and most powerful, but you need to know how to write and execute code

**You want to give the agent tools that are shaped to its own abilities.** But how do you know what those abilities are? You pay attention, read its outputs, experiment. You learn to see like an agent.

---

## Improving Elicitation & the AskUserQuestion Tool

The goal was to improve Claude's ability to ask questions (elicitation). While Claude could ask questions in plain text, answering them felt like unnecessary friction.

### Attempt #1 — Editing the ExitPlanTool

Added an array of questions parameter alongside the plan. Easiest to implement, but it confused Claude: if the user's answers conflicted with the plan, would Claude need to call `ExitPlanTool` twice? Needed another approach.

### Attempt #2 — Changing Output Format

Modified Claude's output instructions to produce a slightly modified markdown format for questions (e.g., bullet points with alternatives in brackets, parsed into UI).

Problem: not guaranteed. Claude would append extra sentences, omit options, or use a different format altogether.

### Attempt #3 — The AskUserQuestion Tool

Created a dedicated tool that Claude could call at any point (particularly prompted during plan mode). When triggered, it shows a modal to display questions and blocks the agent's loop until the user answers.

Benefits:
- Prompts Claude for structured output
- Ensures Claude gives the user multiple options
- Composable — callable in the Agent SDK or referenced in skills
- Claude seemed to naturally understand how to call it

> Even the best designed tool doesn't work if Claude doesn't understand how to call it.

---

## Updating with Capabilities — Tasks & Todos

### Original: TodoWrite Tool

When Claude Code first launched, Claude needed a Todo list to stay on track. `TodoWrite` would write/update Todos and display them to the user. Even then, Claude often forgot what it had to do — so system reminders were inserted every 5 turns.

### Problem as Models Improved

As models improved, they no longer needed reminders — and reminders made Claude think it had to rigidly stick to the list instead of modifying it. Opus 4.5 also got much better at using subagents, but subagents couldn't coordinate on a shared Todo list.

### Solution: The Task Tool

Replaced `TodoWrite` with the `Task Tool`. Whereas Todos were about keeping the model on track, Tasks are about helping agents communicate with each other. Tasks can include dependencies, share updates across subagents, and the model can alter and delete them.

> As model capabilities increase, the tools that your models once needed might now be constraining them. It's important to constantly revisit previous assumptions on what tools are needed.

---

## Designing a Search Interface

### Original: RAG Vector Database

Claude Code first used a RAG vector database to find context. While powerful and fast, it required indexing and setup, was fragile across different environments, and — most importantly — **Claude was given this context instead of finding the context itself**.

### Evolution: Grep Tool

By giving Claude a `Grep` tool, it could search the codebase and build context itself. As Claude gets smarter, it becomes increasingly good at building its own context if given the right tools.

### Progressive Disclosure

When Agent Skills were introduced, progressive disclosure was formalized: agents incrementally discover relevant context through exploration. Claude could read skill files, which could reference other files, which the model could read recursively.

A common use of skills: add more search capabilities to Claude — giving it instructions on how to use an API or query a database.

> Over the course of a year, Claude went from not really being able to build its own context, to being able to do nested search across several layers of files to find the exact context it needed.

---

## Progressive Disclosure — The Claude Code Guide Agent

Claude Code has ~20 tools. The bar to add a new tool is high — each new tool gives the model one more option to think about.

**Problem:** Claude didn't know enough about how to use Claude Code itself (e.g., how to add an MCP, what a slash command does).

**Option A — Add to system prompt:** Would cause context rot and interfere with Claude's main job (writing code), since users rarely ask these questions.

**Option B — Link to docs:** Claude would load too many results into context to find the right answer.

**Solution: Claude Code Guide subagent.** Claude is prompted to call this subagent when asked about itself. The subagent has extensive instructions on how to search docs well and what to return.

This added capability to Claude's action space **without adding a tool**.

---

## An Art, Not a Science

Designing tools for your models depends heavily on:
- The model you're using
- The goal of the agent
- The environment it's operating in

Experiment often, read your outputs, try new things. **See like an agent.**
