# Gemini CLI Reference

## Non-interactive execution

```bash
# Basic prompt
gemini -p "Your prompt here"

# With model selection
gemini -p "Analyze this codebase" -m gemini-2.5-flash

# Auto-approve all tool calls (agentic mode)
gemini -p "Refactor auth module" --yolo

# Sandboxed execution
gemini -p "Edit these files" --sandbox

# JSON output
gemini -p "List all functions in @src/" --output-format json > output.json

# Streaming JSON (for monitoring long runs)
gemini -p "..." --output-format stream-json
```

## File and directory context

Gemini's biggest strength: native `@file` and `@dir` references in the prompt itself.

```bash
# Reference a file
gemini -p "Summarize @src/auth.js"

# Reference a directory (recursive)
gemini -p "Find security issues in @src/auth/"

# Multiple directories
gemini -p "Compare patterns in @src/ and @tests/" \
  --include-directories ../lib,../docs

# Large codebase (git-aware — excludes node_modules, .env automatically)
gemini -p "Document all public APIs in @./"
```

## Models

| Model | Use case |
|---|---|
| `gemini-2.5-flash` | Fast, cost-effective, good for analysis |
| `gemini-2.5-pro` | Complex reasoning, architecture decisions |
| `gemini-2.0-flash` | Balanced speed/quality |

## Key flags

| Flag | Description |
|---|---|
| `-p "prompt"` | Non-interactive prompt (required for scripting) |
| `-m model` | Model selection |
| `--yolo` | Auto-approve all tool calls |
| `--sandbox` | Run in secure sandbox |
| `--output-format json` | Single JSON object with response + usage |
| `--output-format stream-json` | Newline-delimited JSON events |
| `--include-directories paths` | Add extra directories to context |
| `--checkpointing` | Save snapshots before modifications |
| `-d` / `--debug` | Debug output |

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | General / API error |
| 42 | Input error |
| 53 | Turn limit exceeded |

## Best for in task-splitter

- Analyzing large codebases (1M token context)
- Security audits across directories
- Architecture review with file references
- Generating summaries from multiple files
