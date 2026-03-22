# Agentic Calendar

Ecosystem of autonomous agents for platform engineering. Split into two blocks: morning (00h–12h) and evening (12h–00h).

## Morning Block (00h–12h)

| Horário | Seg | Ter | Qua | Qui | Sex | Sáb | Dom |
|---------|-----|-----|-----|-----|-----|-----|-----|
| **00h** | — | — | — | — | — | — | — |
| **01h** | dependency-watchdog | — | — | — | — | — | — |
| **02h** | infra-drift-detector | infra-drift-detector | infra-drift-detector | infra-drift-detector | infra-drift-detector | — | — |
| **03h** | docs-updater | docs-updater | docs-updater | docs-updater | docs-updater | — | — |
| **04h** | pipeline-health | pipeline-health | pipeline-health | pipeline-health | pipeline-health | — | — |
| **05h** | security-scanner | security-scanner | security-scanner | security-scanner | security-scanner | — | — |
| **06h** | daily-briefing | daily-briefing | daily-briefing | daily-briefing | daily-briefing | — | — |
| **07h** | — | — | — | — | — | — | — |
| **08h** | — | — | — | — | — | — | — |
| **09h** | — | — | — | — | — | — | — |
| **10h** | — | — | — | — | — | — | — |
| **11h** | — | — | — | — | — | — | — |
| **12h** | — | — | — | — | — | — | — |

## Evening Block (12h–00h)

_To be defined._

## Out-of-schedule

| Agente | Trigger |
|--------|---------|
| security-scanner | A cada PR aberto (adicional ao schedule) |
| cost-optimizer | Dia 1 de cada mês |

---

## Agent Index

### dependency-watchdog
- **Schedule:** Segunda, 01h
- **Purpose:** Audita dependências de todos os subprojetos (npm, pip, cargo, go mod). Prioriza CVEs críticos. Abre PRs com updates.
- **Output:** PRs de atualização de dependências por subprojeto

### infra-drift-detector
- **Schedule:** Seg–Sex, 02h
- **Purpose:** Roda `terraform plan` em todos os módulos. Detecta recursos criados fora do IaC. Abre issue com detalhes do drift.
- **Output:** Issues com label `infra:drift`

### docs-updater
- **Schedule:** Seg–Sex, 03h
- **Purpose:** Audita README.md e CLAUDE.md em todos os subprojetos. Corrige gaps contra checklist. Abre PR com commits atômicos por subprojeto.
- **Output:** PRs de documentação na branch `docs/update-YYYY-MM-DD`

### pipeline-health
- **Schedule:** Seg–Sex, 04h
- **Purpose:** Analisa workflows do GitHub Actions das últimas 24h. Identifica jobs falhando, pipelines lentos, testes flaky. Abre issue com diagnóstico.
- **Output:** Issues com label `ci:health`

### security-scanner
- **Schedule:** Seg–Sex, 05h + todo PR aberto
- **Purpose:** Varre o repositório em busca de secrets expostos, credenciais hardcoded, padrões de vulnerabilidade. Nunca bloqueia o PR — cria issue para revisão humana.
- **Output:** Issues com label `security:finding`

### daily-briefing
- **Schedule:** Seg–Sex, 06h
- **Purpose:** Agente final do bloco da manhã. Lê PRs e issues abertas pelos outros agentes nas últimas 6h. Gera resumo do que aconteceu durante a noite. Cria uma issue diária de briefing.
- **Output:** Issue diária com label `briefing:morning`

### cost-optimizer
- **Schedule:** Dia 1 de cada mês
- **Purpose:** Analisa custos de cloud (AWS/GCP/Cloudflare). Identifica recursos ociosos, sugere rightsizing. Abre issue com recomendações.
- **Output:** Issue mensal com label `cost:review`
