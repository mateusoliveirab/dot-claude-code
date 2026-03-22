# Ollama Cloud Reference

Ollama cloud models run on Ollama's infrastructure — no local GPU needed, billed per token.
Authentication is required; local models work without it.

## Authentication

```bash
ollama signin     # one-time setup, opens browser
ollama signout    # revoke session
```

## Running cloud models

```bash
# Non-interactive (one shot — exits after response)
ollama run nemotron-3-super:cloud "Your prompt here"

# Pipe input
echo "Summarize this code: $(cat src/auth.js)" | ollama run glm-5:cloud

# With parameters
ollama run qwen3-coder:cloud -p num_ctx=32768 -p temperature=0.3 "Write tests for..."

# JSON output
ollama run minimax-m2.7:cloud --format json "Extract all function signatures from..."

# Verbose (shows tokens/s, load time)
ollama run devstral-small-2:cloud --verbose "..."
```

## Available cloud models (March 2026)

Listed by use case for task routing:

### Coding & agentic workflows
| Model | Tag | Strengths |
|---|---|---|
| qwen3-coder-next | `:cloud` | Agentic coding, optimized for tool use |
| devstral-small-2 | `:cloud` | Codebase exploration, file editing (24B) |
| devstral-2 | `:cloud` | Software engineering agents (123B) |
| nemotron-3-super | `:cloud` | Multi-agent, 120B MoE (12B active), 256K ctx |
| rnj-1 | `:cloud` | Code and STEM, 8B dense |

### Reasoning & complex tasks
| Model | Tag | Strengths |
|---|---|---|
| minimax-m2.7 | `:cloud` | Agentic workflows, professional productivity |
| minimax-m2.5 | `:cloud` | Real-world productivity and coding |
| glm-5 | `:cloud` | 744B total / 40B active, complex systems |
| cogito-2.1 | `:cloud` | 671B instruction-tuned, MIT licensed |
| deepseek-v3.2 | `:cloud` | High efficiency + superior reasoning |

### Fast / cost-effective
| Model | Tag | Strengths |
|---|---|---|
| glm-4.6 | `:cloud` | Reasoning, agentic (fast) |
| glm-4.7 | `:cloud` | Advanced coding |
| minimax-m2 | `:cloud` | Coding, high efficiency |
| nemotron-3-nano | `:cloud` | 4B/30B variants, lightweight |
| kimi-k2.5 | `:cloud` | Native multimodal agentic |
| gemini-3-flash-preview | `:cloud` | Frontier speed |

### Multimodal
| Model | Tag | Strengths |
|---|---|---|
| qwen3-vl | `:cloud` | Vision-language, 2b–235b variants |
| kimi-k2.5 | `:cloud` | Vision + language integration |

## Routing recommendations for task-splitter

| Subtask type | Recommended model |
|---|---|
| Docs, summaries, changelogs | `glm-4.6:cloud` or `minimax-m2:cloud` |
| Test generation | `qwen3-coder:cloud` or `rnj-1:cloud` |
| Codebase exploration | `devstral-small-2:cloud` |
| Complex refactoring | `nemotron-3-super:cloud` or `minimax-m2.7:cloud` |
| Large analysis (long context) | `nemotron-3-super:cloud` (256K ctx) |

## Key flags

| Flag | Description |
|---|---|
| `--format json` | Force JSON output |
| `--verbose` | Show timing stats |
| `--nowordwrap` | Disable word wrap (useful when piping) |
| `-p num_ctx=N` | Set context window size |
| `-p temperature=N` | Adjust randomness (0-1) |

## Notes

- Cloud models behave like regular Ollama models: `ollama ls`, `ollama pull`, `ollama cp` all work
- Cloud inference is on Ollama's servers — data leaves your machine
- `ollama launch claude --model model-name` launches Claude Code using that Ollama model as backend (different use case — not for task dispatch)
