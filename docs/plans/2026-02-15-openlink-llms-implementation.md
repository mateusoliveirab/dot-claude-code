# OpenLink LLMs Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a minimalist TUI in Go + Bubbletea for selecting LLM providers and models to launch Claude Code.

**Architecture:** Provider abstraction with dynamic model discovery. Single-screen app with two views: provider selection and model selection. Clean state machine pattern.

**Tech Stack:** Go 1.21+, Bubbletea, Bubble Tea Contrib (for components), Lip Gloss (for styling)

---

## Task 1: Project Scaffolding

**Files:**
- Create: `openlink-llms/go.mod`
- Create: `openlink-llms/main.go`

**Step 1: Create project directory and go.mod**

```bash
mkdir -p openlink-llms
cd openlink-llms
go mod init github.com/dotclaude/openlink-llms
```

**Step 2: Add dependencies**

```bash
go get github.com/charmbracelet/bubbletea@latest
go get github.com/charmbracelet/lipgloss@latest
go get github.com/charmbracelet/bubbles@latest
```

**Step 3: Create minimal main.go**

```go
package main

import (
	"os"

	"github.com/charmbracelet/bubbletea"
)

func main() {
	p := tea.NewProgram(nil)
	if _, err := p.Run(); err != nil {
		os.Exit(1)
	}
}
```

**Step 4: Test build**

```bash
go build -o openlink-llms .
echo "Build successful"
```

**Step 5: Commit**

```bash
git add openlink-llms/
git commit -m "feat: scaffold openlink-llms project"
```

---

## Task 2: Provider Interface

**Files:**
- Create: `openlink-llms/providers/provider.go`
- Create: `openlink-llms/providers/types.go`

**Step 1: Create types.go**

```go
package providers

// Model represents an LLM model
type Model struct {
	Name        string
	Description string
	Size        string // e.g., "4.7GB"
}

// Config holds environment configuration
type Config struct {
	AuthToken string
	APIKey    string
	BaseURL   string
}
```

**Step 2: Create provider.go interface**

```go
package providers

// Provider defines the interface for LLM providers
type Provider interface {
	ID() string
	Name() string
	Description() string
	Icon() string
	Available() bool
	FetchModels() ([]Model, error)
	Configure() (Config, error)
}
```

**Step 3: Commit**

```bash
git add openlink-llms/providers/
git commit -m "feat: add provider interface and types"
```

---

## Task 3: Ollama Provider Implementation

**Files:**
- Create: `openlink-llms/providers/ollama.go`

**Step 1: Create ollama.go**

```go
package providers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

// Ollama represents the Ollama provider
type Ollama struct {
	baseURL string
	client  *http.Client
}

// NewOllama creates a new Ollama provider
func NewOllama(baseURL string) *Ollama {
	return &Ollama{
		baseURL: baseURL,
		client: &http.Client{Timeout: 10 * time.Second},
	}
}

func (o *Ollama) ID() string          { return "ollama-local" }
func (o *Ollama) Name() string        { return "Ollama" }
func (o *Ollama) Description() string { return "Local models via Ollama" }
func (o *Ollama) Icon() string        { return "⬡" }

func (o *Ollama) Available() bool {
	resp, err := o.client.Get(o.baseURL + "/api/tags")
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	return resp.StatusCode == http.StatusOK
}

func (o *Ollama) FetchModels() ([]Model, error) {
	resp, err := o.client.Get(o.baseURL + "/api/tags")
	if err != nil {
		return nil, fmt.Errorf("failed to fetch models: %w", err)
	}
	defer resp.Body.Close()

	var result struct {
		Models []struct {
			Name        string `json:"name"`
			Size        int64  `json:"size"`
			Description string `json:"details,omitempty"`
		} `json:"models"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	models := make([]Model, len(result.Models))
	for i, m := range result.Models {
		models[i] = Model{
			Name:        m.Name,
			Description: m.Description,
			Size:        formatSize(m.Size),
		}
	}
	return models, nil
}

func (o *Ollama) Configure() (Config, error) {
	return Config{
		AuthToken: "ollama",
		APIKey:    "",
		BaseURL:   o.baseURL,
	}, nil
}

func formatSize(bytes int64) string {
	const unit = 1024
	if bytes < unit {
		return fmt.Sprintf("%d B", bytes)
	}
	div, exp := int64(unit), 0
	for n := bytes / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(bytes)/float64(div), "KMGTPE"[exp])
}
```

**Step 2: Test compilation**

```bash
cd openlink-llms && go build ./...
```

**Step 3: Commit**

```bash
git add openlink-llms/providers/ollama.go
git commit -m "feat: implement Ollama provider"
```

---

## Task 4: OpenCode Provider Implementation

**Files:**
- Create: `openlink-llms/providers/opencode.go`

**Step 1: Create opencode.go**

```go
package providers

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

// OpenCode represents the OpenCode provider
type OpenCode struct{}

func NewOpenCode() *OpenCode {
	return &OpenCode{}
}

func (o *OpenCode) ID() string          { return "opencode" }
func (o *OpenCode) Name() string        { return "OpenCode" }
func (o *OpenCode) Description() string { return "OpenCode AI models" }
func (o *OpenCode) Icon() string        { return "◈" }

func (o *OpenCode) Available() bool {
	home, err := os.UserHomeDir()
	if err != nil {
		return false
	}
	configPath := filepath.Join(home, ".opencode", "config.json")
	_, err = os.ReadFile(configPath)
	return err == nil
}

func (o *OpenCode) FetchModels() ([]Model, error) {
	// OpenCode models are predefined
	return []Model{
		{Name: "claude-sonnet-4-20250514", Description: "Claude Sonnet 4"},
		{Name: "claude-haiku-3-20250514", Description: "Claude Haiku 3"},
		{Name: "gpt-4o", Description: "GPT-4o"},
		{Name: "gpt-4o-mini", Description: "GPT-4o Mini"},
		{Name: "gemini-2-flash", Description: "Gemini 2 Flash"},
	}, nil
}

func (o *OpenCode) Configure() (Config, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return Config{}, err
	}

	configPath := filepath.Join(home, ".opencode", "config.json")
	data, err := os.ReadFile(configPath)
	if err != nil {
		return Config{}, fmt.Errorf("failed to read config: %w", err)
	}

	var config struct {
		API struct {
			BaseURL string `json:"base_url"`
			Key     string `json:"key"`
		} `json:"api"`
	}

	if err := json.Unmarshal(data, &config); err != nil {
		return Config{}, fmt.Errorf("failed to parse config: %w", err)
	}

	return Config{
		AuthToken: config.API.Key,
		APIKey:    config.API.Key,
		BaseURL:   config.API.BaseURL,
	}, nil
}
```

**Step 2: Test compilation**

```bash
cd openlink-llms && go build ./...
```

**Step 3: Commit**

```bash
git add openlink-llms/providers/opencode.go
git commit -m "feat: implement OpenCode provider"
```

---

## Task 5: UI Styles

**Files:**
- Create: `openlink-llms/ui/styles.go`

**Step 1: Create styles.go**

```go
package ui

import (
	"github.com/charmbracelet/lipgloss"
)

// Color palette - minimalist neutral
var (
	bgPrimary    = lipgloss.Color("#1a1a1a")
	bgSecondary  = lipgloss.Color("#252525")
	borderColor  = lipgloss.Color("#3a3a3a")
	textPrimary  = lipgloss.Color("#e0e0e0")
	textMuted    = lipgloss.Color("#808080")
	accentColor  = lipgloss.Color("#5c9ce6")
	accentHover  = lipgloss.Color("#7ab3f0")
	successColor = lipgloss.Color("#6bbf7a")
	errorColor   = lipgloss.Color("#e05c5c")
)

// Styles
var (
	ContainerStyle = lipgloss.NewStyle().
			Background(bgPrimary).
			Foreground(textPrimary).
			Width(60).
			Height(20).
			Border(lipgloss.RoundedBorder).
			BorderForeground(borderColor).
			Padding(1, 2)

	TitleStyle = lipgloss.NewStyle().
			Bold(true).
			Foreground(accentColor).
			Width(56)

	SubtitleStyle = lipgloss.NewStyle().
			Foreground(textMuted).
			Width(56)

	ListItemStyle = lipgloss.NewStyle().
			Foreground(textPrimary).
			Padding(0, 1)

	ListItemSelectedStyle = lipgloss.NewStyle().
				Background(bgSecondary).
				Foreground(accentColor).
				Padding(0, 1).
				Bold(true)

	IconStyle = lipgloss.NewStyle().
			Foreground(accentColor).
			Width(2)

	DescriptionStyle = lipgloss.NewStyle().
			Foreground(textMuted)

	FooterStyle = lipgloss.NewStyle().
			Foreground(textMuted).
			Width(56).
			Align(lipgloss.Right)

	StatusStyle = lipgloss.NewStyle().
			Foreground(successColor)

	ErrorStyle = lipgloss.NewStyle().
			Foreground(errorColor)

	LoadingStyle = lipgloss.NewStyle().
			Foreground(textMuted).
			Width(56).
			Align(lipgloss.Center)
)
```

**Step 2: Test compilation**

```bash
cd openlink-llms && go build ./...
```

**Step 3: Commit**

```bash
git add openlink-llms/ui/styles.go
git commit -m "feat: add UI styles"
```

---

## Task 6: TUI Model

**Files:**
- Create: `openlink-llms/ui/model.go`

**Step 1: Create model.go**

```go
package ui

import (
	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"openlink-llms/providers"
)

// View state
const (
	ViewProviderList = "provider"
	ViewModelList   = "model"
	ViewConfirm     = "confirm"
)

// Model represents the TUI state
type Model struct {
	view          string
	providers     []providers.Provider
	selectedProv  int
	models        []providers.Model
	selectedModel int
	loading       bool
	err           error
	list          list.Model
	keys          *keyMap
}

// Key map for navigation
type keyMap struct {
	up     key.Binding
	down   key.Binding
	enter  key.Binding
	back   key.Binding
	quit   key.Binding
}

var keys = &keyMap{
	up:   key.NewBinding(key.WithKeys("up", "k"), key.WithHelp("↑/k", "up")),
	down: key.NewBinding(key.WithKeys("down", "j"), key.WithHelp("↓/j", "down")),
	enter: key.NewBinding(key.WithKeys("enter"), key.WithHelp("enter", "select")),
	back:  key.NewBinding(key.WithKeys("esc"), key.WithHelp("esc", "back")),
	quit:  key.NewBinding(key.WithKeys("ctrl+c"), key.WithHelp("ctrl+c", "quit")),
}

// NewModel creates the initial model
func NewModel() Model {
	// Initialize providers
	provs := []providers.Provider{
		providers.NewOllama("http://localhost:11434"),
		providers.NewOpenCode(),
	}

	return Model{
		view:         ViewProviderList,
		providers:    provs,
		selectedProv: 0,
		models:       []providers.Model{},
		selectedModel: 0,
		loading:      false,
		err:          nil,
		keys:         keys,
	}
}

// Init initializes the model
func (m Model) Init() tea.Cmd {
	return nil
}

// Update handles messages
func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		return m.handleKey(msg)
	case tea.WindowSizeMsg:
		// Handle window resize if needed
	}
	return m, nil
}

// View renders the UI
func (m Model) View() string {
	switch m.view {
	case ViewProviderList:
		return m.renderProviderList()
	case ViewModelList:
		return m.renderModelList()
	case ViewConfirm:
		return m.renderConfirm()
	default:
		return m.renderProviderList()
	}
}
```

**Step 2: Implement key handling (add to model.go)**

```go
func (m Model) handleKey(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch m.view {
	case ViewProviderList:
		return m.handleProviderKey(msg)
	case ViewModelList:
		return m.handleModelKey(msg)
	case ViewConfirm:
		return m.handleConfirmKey(msg)
	}
	return m, nil
}

func (m Model) handleProviderKey(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch {
	case key.Matches(msg, m.keys.up):
		if m.selectedProv > 0 {
			m.selectedProv--
		}
	case key.Matches(msg, m.keys.down):
		if m.selectedProv < len(m.providers)-1 {
			m.selectedProv++
		}
	case key.Matches(msg, m.keys.enter):
		m.view = ViewModelList
		m.loading = true
		// Fetch models in background
		go func() {
			models, err := m.providers[m.selectedProv].FetchModels()
			m.models = models
			m.err = err
			m.loading = false
		}()
	case key.Matches(msg, m.keys.quit):
		return m, tea.Quit
	}
	return m, nil
}

func (m Model) handleModelKey(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch {
	case key.Matches(msg, m.keys.up):
		if m.selectedModel > 0 {
			m.selectedModel--
		}
	case key.Matches(msg, m.keys.down):
		if m.selectedModel < len(m.models)-1 {
			m.selectedModel++
		}
	case key.Matches(msg, m.keys.enter):
		m.view = ViewConfirm
	case key.Matches(msg, m.keys.back):
		m.view = ViewProviderList
	case key.Matches(msg, m.keys.quit):
		return m, tea.Quit
	}
	return m, nil
}

func (m Model) handleConfirmKey(msg tea.KeyMsg) (tea.Model, tea.Cmd) {
	switch {
	case key.Matches(msg, m.keys.enter):
		// Launch Claude Code
		return m, launchClaude
	case key.Matches(msg, m.keys.back):
		m.view = ViewModelList
	case key.Matches(msg, m.keys.quit):
		return m, tea.Quit
	}
	return m, nil
}
```

**Step 3: Add render functions (add to model.go)**

```go
func (m Model) renderProviderList() string {
	var s string
	s += TitleStyle.Render("OpenLink LLMs") + "\n"
	s += SubtitleStyle.Render("Select a provider") + "\n\n"

	for i, p := range m.providers {
		icon := " "
		style := ListItemStyle
		available := "○"

		if i == m.selectedProv {
			icon = "▶"
			style = ListItemSelectedStyle
			available = "●"
		}

		status := textMuted.Render(available)
		if p.Available() {
			status = success.Render(available)
		}

		s += style.Render(icon+" "+p.Name()) + " " + status + "\n"
		s += DescriptionStyle.Render("  "+p.Description()) + "\n"
	}

	s += "\n" + FooterStyle.Render("↑↓ navigate · enter select · ctrl+c quit")
	return ContainerStyle.Render(s)
}

func (m Model) renderModelList() string {
	var s string
	s += TitleStyle.Render("Select Model") + "\n"
	s += SubtitleStyle.Render(m.providers[m.selectedProv].Name()) + "\n\n"

	if m.loading {
		s += LoadingStyle.Render("Loading models...")
		return ContainerStyle.Render(s)
	}

	if m.err != nil {
		s += ErrorStyle.Render("Error: "+m.err.Error()) + "\n\n"
	}

	if len(m.models) == 0 {
		s += DescriptionStyle.Render("No models available") + "\n\n"
	} else {
		for i, model := range m.models {
			icon := " "
			style := ListItemStyle

			if i == m.selectedModel {
				icon = "▶"
				style = ListItemSelectedStyle
			}

			s += style.Render(icon+" "+model.Name) + "\n"
			s += DescriptionStyle.Render("  "+model.Description+" · "+model.Size) + "\n"
		}
	}

	s += "\n" + FooterStyle.Render("↑↓ navigate · enter select · esc back")
	return ContainerStyle.Render(s)
}

func (m Model) renderConfirm() string {
	model := m.models[m.selectedModel]
	prov := m.providers[m.selectedProv]

	var s string
	s += TitleStyle.Render("Launch Claude Code") + "\n\n"
	s += ListItemStyle.Render("Provider: " + prov.Name()) + "\n"
	s += ListItemStyle.Render("Model: " + model.Name) + "\n"
	s += DescriptionStyle.Render("  "+model.Description) + "\n"

	s += "\n" + FooterStyle.Render("enter launch · esc back")
	return ContainerStyle.Render(s)
}
```

**Step 4: Test compilation**

```bash
cd openlink-llms && go build ./...
```

**Step 5: Commit**

```bash
git add openlink-llms/ui/model.go
git commit -m "feat: add TUI model with views"
```

---

## Task 7: Launcher Integration

**Files:**
- Create: `openlink-llms/config/launcher.go`

**Step 1: Create launcher.go**

```go
package config

import (
	"fmt"
	"os"
	"os/exec"
)

// LaunchClaude launches Claude Code with the selected configuration
func LaunchClaude(model string, config map[string]string) error {
	// Set environment variables
	for k, v := range config {
		os.Setenv(k, v)
	}

	// Launch Claude Code
	cmd := exec.Command("claude", "--model", model)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	return cmd.Run()
}

// ExportConfig prints export commands for the configuration
func ExportConfig(config map[string]string) {
	for k, v := range config {
		fmt.Printf("export %s=%s\n", k, v)
	}
}
```

**Step 2: Update main.go to use the model**

```go
package main

import (
	"fmt"
	"os"

	"github.com/charmbracelet/bubbletea"
	"openlink-llms/ui"
)

func main() {
	p := tea.NewProgram(ui.NewModel(), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
```

**Step 3: Test compilation**

```bash
cd openlink-llms && go build ./...
```

**Step 4: Commit**

```bash
git add openlink-llms/config/launcher.go openlink-llms/main.go
git commit -m "feat: add launcher integration"
```

---

## Task 8: Final Integration and Build

**Files:**
- Modify: `openlink-llms/main.go`

**Step 1: Complete main.go with proper initialization**

```go
package main

import (
	"os"

	"github.com/charmbracelet/bubbletea"
	"openlink-llms/ui"
)

func main() {
	p := tea.NewProgram(
		ui.NewModel(),
		tea.WithAltScreen(),
		tea.WithMouseCellFocus(),
	)

	if _, err := p.Run(); err != nil {
		os.Exit(1)
	}
}
```

**Step 2: Build the application**

```bash
cd openlink-llms
go build -o openlink-llms .
ls -la openlink-llms
```

**Step 3: Run basic test**

```bash
./openlink-llms
# Should show provider selection UI
```

**Step 4: Commit**

```bash
git add -A
git commit -m "feat: complete openlink-llms TUI"
```

---

## Summary

This plan creates a complete TUI application with:
- 8 tasks for incremental development
- Provider abstraction for extensibility
- Clean UI with minimalist neutral styling
- Full keyboard navigation

The app will launch, show provider selection, allow model selection, and launch Claude Code with the selected configuration.
