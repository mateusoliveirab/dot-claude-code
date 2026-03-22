# OpenLink LLMs - Design Document

## Overview

A minimalist TUI (Terminal User Interface) built with Go + Bubbletea for selecting LLM providers and models to launch Claude Code.

## App Name

**openlink-llms**

## Goals

- Elegant, minimalist UI with neutral colors
- Support multiple LLM providers (Ollama, OpenCode)
- Dynamic model discovery via provider APIs
- Launch Claude Code with selected configuration

## UI/UX Design

### Color Palette

| Element | Color | Hex |
|---------|-------|-----|
| Background | Dark charcoal | `#1a1a1a` |
| Surface | Slightly lighter | `#252525` |
| Border | Subtle gray | `#3a3a3a` |
| Text primary | Off-white | `#e0e0e0` |
| Text secondary | Muted gray | `#808080` |
| Accent | Soft blue | `#5c9ce6` |
| Accent hover | Lighter blue | `#7ab3f0` |
| Success | Soft green | `#6bbf7a` |
| Error | Soft red | `#e05c5c` |

### Typography

- Font: System monospace (terminal default)
- Title: Bold, larger size
- Body: Regular size
- Selected item: Accent color background

### Layout

Single screen with two views:
1. **Provider Selection** - List of available providers
2. **Model Selection** - Models from selected provider

### Components

1. **Header** - App title with subtle styling
2. **Provider List** - Vertical list with selection indicator
3. **Model List** - Vertical list with model info
4. **Footer** - Navigation hints (arrow keys, enter, esc)

### Interactions

- `↑/↓` - Navigate items
- `Enter` - Select item
- `Esc` - Go back
- `Ctrl+C` - Exit

## Architecture

### Project Structure

```
openlink-llms/
├── main.go           # Entry point
├── go.mod            # Dependencies
├── providers/
│   ├── provider.go   # Provider interface
│   ├── ollama.go     # Ollama implementation
│   └── opencode.go   # OpenCode implementation
├── ui/
│   ├── model.go      # TUI model
│   ├── views.go      # View rendering
│   └── styles.go     # Styled components
└── config/
    └── launcher.go    # Claude Code launcher
```

### Provider Interface

```go
type Provider interface {
    ID() string
    Name() string
    Description() string
    Icon() string
    Available() bool
    FetchModels() ([]Model, error)
    Configure() (map[string]string, error)
}

type Model struct {
    Name        string
    Description string
}
```

### State Machine

```
┌─────────────────┐
│ Provider List   │ ← Initial view
└────────┬────────┘
         │ Select provider
         ▼
┌─────────────────┐
│ Model List      │ ← Loading models...
└────────┬────────┘
         │ Select model
         ▼
┌─────────────────┐
│ Confirm & Launch│ ← Show config, launch
└─────────────────┘
```

## Providers

### Ollama

- **Local**: `http://localhost:11434`
- **Cloud**: `https://ollama.com` (requires API key)
- Fetch models via `/api/tags` endpoint

### OpenCode

- Read configuration from `~/.opencode/config.json`
- Extract API endpoint and key
- Support models from OpenCode

## Configuration

Output environment variables:
```bash
export ANTHROPIC_AUTH_TOKEN=...
export ANTHROPIC_API_KEY=...
export ANTHROPIC_BASE_URL=...
```

Launch Claude Code:
```bash
claude --model <selected-model>
```

## Error Handling

- Connection failures: Show error message with retry option
- Empty model list: Display "No models available" with refresh hint
- Invalid API key: Prompt for re-entry

## Acceptance Criteria

1. App launches with provider selection screen
2. Providers are listed with availability status
3. Selecting a provider fetches its models
4. Model selection shows loading state
5. Confirmation screen shows full configuration
6. Launching Claude Code applies the configuration
7. Back navigation works at all levels
8. Keyboard navigation is smooth and responsive
