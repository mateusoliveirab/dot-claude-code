# Context Engineering — Guia Operacional para Claude Code

> "Context engineering is the delicate art and science of filling the context window with just the right information for the next step." — Andrej Karpathy

Este documento define como operar com Claude Code de forma eficaz. Siga as fases, respeite os modos e mantenha os artefatos atualizados.

---

## Regras Gerais

- **Nunca misture fases.** Research, Plan e Build são sessões separadas.
- **Nunca improvise durante a implementação.** Se o plano estiver errado, volte para `/fase-plan`.
- **Contexto baixo é melhor.** Inicie uma nova task para cada passo relevante.
- **`/clear` entre fases.** Resete o contexto ao mudar de fase para evitar context drift.
- **Commits são memória.** Pequenos e frequentes — mecanismo de rollback e continuidade.
- **Explicitude supera inteligência.** Um plano claro vence um modelo capaz com contexto ambíguo.

---

## Arquitetura: Harness = 3 Camadas

O modelo só é tão bom quanto o harness ao redor dele. O harness opera em **3 camadas com garantias diferentes**:

| Camada | Features | Garantia |
|---|---|---|
| **Instruções** | `CLAUDE.md`, Skills, Slash Commands | O modelo *tende* a seguir, mas pode ignorar |
| **Enforcement** | Hooks (`PreToolUse`, `PostToolUse`, `Stop`) | **Determinístico** — executa sempre |
| **Isolamento** | Subagents, `/clear`, `/compact` | **Estrutural** — separa contextos |

> Um bom harness usa as três. Instruções sozinhas são frágeis. Hooks sem instruções são cegos.

### Guides — o que entra (feedforward)

| Mecanismo | Propósito | Carregamento |
|---|---|---|
| `CLAUDE.md` (root) | Regras globais, convenções, estrutura | **Sempre** — início de cada sessão |
| `CLAUDE.md` (subdir) | Regras específicas do módulo | **Quando** o agente navega para aquele dir |
| Slash Command | Procedimento reutilizável (ex: `/fase-research`) | **Manual** — invocado pelo usuário |
| Subagent | Especialista isolado (contexto limpo) | **Automático** — delegação pelo agente |
| Skill | Workflow complexo com scripts auxiliares | **Lazy** — só metadata carregada inicialmente |

**Quando usar qual:**

| Cenário | Mecanismo |
|---|---|
| Regra que vale para TODA sessão | `CLAUDE.md` |
| Regra que vale só num subprojeto | `CLAUDE.md` do subdiretório |
| Procedimento que o humano aciona | Slash Command |
| Workflow complexo que raramente é usado | Skill |
| Ação que DEVE acontecer sempre (lint, syntax check) | Hook |

### Memória — continuidade entre sessões

| Mecanismo | Propósito | Tipo |
|---|---|---|
| `CLAUDE.md` | Briefing persistente | Automático |
| `/compact` | Comprimir contexto quando ficou grande | Manual |
| git log | Histórico como memória estruturada | Passivo |

### Sensors — feedback automático (Hooks ativos)

**Global** (`~/.claude/settings.json`):
- `PreToolUse` → Bash: rtk-rewrite (token savings)
- `PostToolUse` → Write|Edit: shell syntax check (`bash -n`) + JSON validation (`jq empty`)

**Repo** (`.claude/settings.local.json`):
- `PostToolUse` → Write|Edit: ESLint em arquivos TS/TSX dos subprojetos

---

## Workflow: As 3 Fases

### Phase 1 — Research
**Comando:** `/fase-research`

Entender antes de agir. Zero implementação.

Produzir: arquivos envolvidos, funções-chave, fluxo de dados, edge cases.

**Critério de saída:** Você consegue explicar o sistema sem consultar o código?

---

### Phase 2 — Plan
**Comando:** `/fase-plan`

Transformar o research em um plano inequívoco de execução.

Produzir: passos numerados com arquivo + função + mudança + validação.

**Critério de saída:** O plano é claro o suficiente para que qualquer modelo execute sem ambiguidade?

---

### Phase 3 — Build
**Comando:** `/fase-build`

Executar o plano. Sem desvios, sem improvisos. Se o plano estiver errado, voltar para `/fase-plan`.

---

### Review
**Comando:** `/pre-commit-review`

Revisar o diff antes de commitar. Retorna veredicto: APROVADO, AJUSTAR ou BLOQUEAR.

---

## Gestão de Contexto

| Comando | Quando usar |
|---|---|
| `/clear` | Entre fases, entre tasks distintas, quando acumulou contexto irrelevante |
| `/compact` | Quando o contexto está grande mas ainda relevante — comprimir sem perder |

---

## Onde o Tempo Humano Tem Mais Alavancagem

```
Research ← revisar aqui é barato e de alto impacto
Plan     ← revisar aqui ainda é barato
Build    → corrigir aqui é caro
```

Revise o research e o plan antes de autorizar a implementação.

---

## Princípios de Código que Potencializam a IA

### Craftsmanship reduz ruído no contexto

Código bem modularizado, com nomes semânticos e fronteiras claras de domínio, torna o contexto mais denso em informação útil.

- Nomes que descrevem o domínio, não a implementação
- Funções pequenas e com responsabilidade única
- Fronteiras de módulo claras = contexto mais legível

### TDD como mecanismo de verificação

- O teste é a especificação executável
- O agente recebe feedback imediato ao rodar os testes
- Hooks `PostToolUse` fazem lint automático após cada edição — TDD + Hooks = loop de verificação estrutural

> Escreva os testes antes. Deixe o agente fazê-los passar.

---

## Advisor Strategy (API)

Para agentes programáticos (não Claude Code IDE), a **Advisor Strategy** complementa este workflow: um modelo menor (Sonnet) executa, e escala consultas para um modelo maior (Opus) em momentos de decisão.

Ver: [claude-advisor-strategy.md](./claude-advisor-strategy.md)

---

## Inventário

### Slash Commands (`.claude/commands/`)

| Comando | Fase |
|---|---|
| `/fase-research` | Research — somente-leitura |
| `/fase-plan` | Plan — planejamento sem edição |
| `/fase-build` | Build — execução do plano |
| `/pre-commit-review` | Review de diff |

### Hooks (`.claude/settings.local.json`)

| Evento | Matcher | Ação |
|---|---|---|
| `PostToolUse` | `Write\|Edit` | ESLint em TS/TSX editados |

---

*— documento vivo, atualizar conforme novos findings forem validados —*