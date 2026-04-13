# Claude Advisor Strategy — Pesquisa Compilada

> **Fontes:**
> - Blog post: https://claude.com/blog/the-advisor-strategy (April 9, 2026)
> - Documentação oficial: https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool

---

## 1. O Conceito: Advisor Strategy

**TL;DR:** Par Opus como *advisor* com Sonnet ou Haiku como *executor*, obtendo inteligência próxima ao nível Opus em agentes a uma fração do custo.

Desenvolvedores que querem equilibrar inteligência e custo convergiram para o que a Anthropic chama de "advisor strategy": usar Opus como advisor e Sonnet ou Haiku como executor. Isso traz inteligência quase-Opus para agentes enquanto mantém custos próximos aos de Sonnet.

### Como funciona

- **Executor (Sonnet/Haiku):** Conduz a tarefa do início ao fim — chama ferramentas, lê resultados, itera em direção à solução.
- **Advisor (Opus):** Quando o executor topa com uma decisão que não consegue resolver razoavelmente, consulta o Opus. O Opus acessa o contexto compartilhado e retorna um **plano, uma correção, ou um sinal de parada**. O advisor nunca chama ferramentas nem produz output para o usuário.

> Isso **inverte** o padrão comum de sub-agentes, onde um orquestrador maior decompõe e delega para modelos menores. Na advisor strategy, o modelo menor *dirige* e *escala* sem decomposição, pool de workers ou lógica de orquestração. Raciocínio frontier é aplicado apenas quando o executor precisa.

### Resultados de Benchmark (Anthropic)

| Configuração | Métrica | Resultado |
|---|---|---|
| Sonnet + Opus Advisor vs. Sonnet solo | SWE-bench Multilingual | +2.7 pp de score, -11.9% de custo por tarefa |
| Haiku + Opus Advisor vs. Haiku solo | BrowseComp | 41.2% vs. 19.7% (>2x) |
| Haiku + Opus Advisor vs. Sonnet solo | Custo | 85% mais barato, -29% de score |

---

## 2. O Advisor Tool (API)

A Anthropic disponibilizou a advisor strategy como uma **ferramenta server-side nativa** na Messages API.

### Status
- **Beta** — requer header: `anthropic-beta: advisor-tool-2026-03-01`
- Disponível apenas na Claude API (Anthropic)
- Elegível para Zero Data Retention (ZDR)

### Quick Start (cURL)

```bash
curl https://api.anthropic.com/v1/messages \
  --header "x-api-key: $ANTHROPIC_API_KEY" \
  --header "anthropic-version: 2023-06-01" \
  --header "anthropic-beta: advisor-tool-2026-03-01" \
  --header "content-type: application/json" \
  --data '{
    "model": "claude-sonnet-4-6",
    "max_tokens": 4096,
    "tools": [
      {
        "type": "advisor_20260301",
        "name": "advisor",
        "model": "claude-opus-4-6"
      }
    ],
    "messages": [{"role": "user", "content": "Build a concurrent worker pool in Go with graceful shutdown."}]
  }'
```

### Quick Start (Python)

```python
response = client.messages.create(
    model="claude-sonnet-4-6",  # executor
    tools=[
        {
            "type": "advisor_20260301",
            "name": "advisor",
            "model": "claude-opus-4-6",
            "max_uses": 3,
        },
        # ... suas outras ferramentas
    ],
    messages=[...]
)
# Tokens do advisor são reportados separadamente no bloco de usage
```

### Parâmetros do Tool

| Parâmetro | Descrição |
|---|---|
| `type` | `"advisor_20260301"` (obrigatório) |
| `name` | `"advisor"` (obrigatório) |
| `model` | ex: `"claude-opus-4-6"` — deve ser >= capaz que o executor |
| `max_uses` | Cap de chamadas por request. Exceder retorna `error_code: "max_uses_exceeded"` |
| `caching` | `{"type": "ephemeral", "ttl": "5m" | "1h"}` — habilita prompt caching do lado do advisor |

### Compatibilidade de Modelos

| Executor | Advisor suportado |
|---|---|
| `claude-haiku-4-5-20251001` | `claude-opus-4-6` |
| `claude-sonnet-4-6` | `claude-opus-4-6` |
| `claude-opus-4-6` | `claude-opus-4-6` |

> O advisor deve ser **ao menos tão capaz** quanto o executor. Pares inválidos retornam `400 invalid_request_error`.

---

## 3. Como o Mecanismo Funciona Internamente

1. O executor emite um bloco `server_tool_use` com `name: "advisor"` e `input` vazio. O executor sinaliza o momento; o servidor monta o contexto.
2. Anthropic executa uma inference pass separada no advisor server-side, passando o transcript completo do executor (system prompt, todas as tool definitions, todos os turns anteriores e tool results).
3. A resposta do advisor retorna ao executor como um bloco `advisor_tool_result`.
4. O executor continua gerando, informado pela orientação.

**Tudo isso acontece dentro de um único request `/v1/messages` — sem round-trips extras.**

O advisor roda **sem ferramentas** e sem context management. Seus blocos de thinking são descartados antes do resultado chegar; apenas o texto de conselho alcança o executor.

### Estrutura de Resposta (Exemplo)

```json
{
  "role": "assistant",
  "content": [
    {"type": "text", "text": "Let me consult the advisor on this."},
    {"type": "server_tool_use", "id": "srvtoolu_abc123", "name": "advisor", "input": {}},
    {
      "type": "advisor_tool_result",
      "tool_use_id": "srvtoolu_abc123",
      "content": {
        "type": "advisor_result",
        "text": "Use a channel-based coordination pattern. The tricky part is draining in-flight work during shutdown: close the input channel first, then wait on a WaitGroup..."
      }
    },
    {"type": "text", "text": "Here's the implementation..."}
  ]
}
```

### Variantes do Resultado

| Tipo | Campo relevante | Descrição |
|---|---|---|
| `advisor_result` | `text` | Conselho em texto legível |
| `advisor_redacted_result` | `encrypted_content` | Blob opaco (você não pode ler); na próxima turn o servidor descriptografa e injeta no prompt |

**Em ambos os casos, repassar o conteúdo verbatim nas turns seguintes.**

### Erros possíveis no `error_code`

- `max_uses_exceeded` — limite de `max_uses` atingido
- `too_many_requests` — rate limit do advisor
- `overloaded` — advisor sobrecarregado
- `prompt_too_long` — contexto muito grande
- `execution_time_exceeded` — timeout
- `unavailable` — serviço indisponível

---

## 4. Preços e Billing

- **Advisor tokens** são cobrados à taxa do **modelo advisor**.
- **Executor tokens** são cobrados à taxa do **modelo executor**.
- O advisor gera tipicamente **400–700 tokens de texto** (1.400–1.800 totais incluindo thinking).
- O `max_tokens` do request se aplica **apenas ao output do executor**. Não limita tokens do advisor.
- Tokens do advisor são reportados **separadamente** em `usage.iterations[]`.

### Exemplo de `usage`

```json
{
  "usage": {
    "input_tokens": 412,
    "output_tokens": 531,
    "iterations": [
      {"type": "message", "input_tokens": 412, "output_tokens": 89},
      {"type": "advisor_message", "model": "claude-opus-4-6", "input_tokens": 823, "output_tokens": 1612},
      {"type": "message", "input_tokens": 1348, "cache_read_input_tokens": 412, "output_tokens": 442}
    ]
  }
}
```

> `top-level input_tokens` reflete apenas a primeira iteração do executor. Use `usage.iterations` para breakdown completo ao construir lógica de tracking de custo.

---

## 5. Prompt Caching

### Executor-side Caching
O bloco `advisor_tool_result` é cacheável como qualquer outro content block.

### Advisor-side Caching
Habilitar com o parâmetro `caching` na definição do tool:

```python
tools = [
    {
        "type": "advisor_20260301",
        "name": "advisor",
        "model": "claude-opus-4-6",
        "caching": {"type": "ephemeral", "ttl": "5m"},
    }
]
```

**Quando vale habilitar:** O caching começa a compensar a partir de ~3 chamadas ao advisor por conversa. Para tarefas curtas (≤2 chamadas), não compensa.

> ⚠️ **Gotcha:** Usar `clear_thinking` com `keep` diferente de `"all"` desloca o transcript do advisor, causando cache misses. Se `extended thinking` estiver habilitado sem configuração explícita, o padrão é `keep: {type: "thinking_turns", value: 1}` — isso quebra o cache do advisor. Fixar com `keep: "all"`.

---

## 6. Multi-turn Conversations

Passar o content completo do assistant (incluindo blocos `advisor_tool_result`) de volta à API nas turns seguintes:

```python
# Append the full response content, including any advisor_tool_result blocks
messages.append({"role": "assistant", "content": response.content})
# Continue the conversation
messages.append({"role": "user", "content": "Now add a max-in-flight limit of 10."})
```

**Regras importantes:**
- Se remover o advisor de `tools` em uma turn seguinte enquanto o histórico ainda contém blocos `advisor_tool_result`, a API retorna `400 invalid_request_error`.
- Não há cap de chamadas por conversa built-in. Para limitar: contar client-side. Ao atingir o limite, remover o tool de `tools` **e** remover todos os blocos `advisor_tool_result` do histórico.

---

## 7. Streaming

O advisor **não faz streaming**. O stream do executor pausa enquanto o advisor roda, e o resultado chega como um único evento.

- O bloco `server_tool_use` com `name: "advisor"` sinaliza início.
- Durante a pausa, o stream fica silencioso exceto por SSE ping keepalives (~30 segundos).
- O resultado `advisor_tool_result` chega completo num único evento `content_block_start` (sem deltas).

---

## 8. Composição com Outras Ferramentas

O advisor tool é apenas mais uma entrada no array `tools`. Pode ser combinado com web search, code execution e tools customizados:

```python
tools = [
    {"type": "web_search_20250305", "name": "web_search", "max_uses": 5},
    {"type": "advisor_20260301", "name": "advisor", "model": "claude-opus-4-6"},
    {
        "name": "run_bash",
        "description": "Run a bash command",
        "input_schema": {"type": "object", "properties": {"command": {"type": "string"}}},
    },
]
```

---

## 9. Melhores Práticas

### Quando usar

✅ Bom fit:
- Workloads de longo horizonte (coding agents, computer use, pesquisa multi-step)
- Você usa Sonnet em tarefas complexas → adicionar Opus como advisor dá lift de qualidade em custo similar ou menor
- Você usa Haiku e quer step up de inteligência sem pagar por Sonnet full

❌ Fraco fit:
- Q&A single-turn (nada para planejar)
- Workloads onde cada turn genuinamente requer capacidade total do advisor
- Model pickers onde o usuário já escolhe seu tradeoff de custo/qualidade

### Timing ideal para chamadas do advisor (tarefas de coding)

1. **Chamada inicial cedo** — após algumas leituras exploratórias estarem no transcript (não antes de qualquer orientação).
2. **Chamada final** — em tarefas difíceis, após writes de arquivo e outputs de teste estarem no transcript.

> Se seu agente expõe outras ferramentas tipo planner (ex: todo list), chamar o advisor *antes* dessas ferramentas para que o plano do advisor alimente-as.

---

## 10. System Prompt Sugerido para Tarefas de Coding

Para tarefas de coding onde você quer timing consistente do advisor e ~2–3 chamadas por tarefa, **prepend os seguintes blocos ao system prompt do executor** antes de qualquer outra sentença que mencione o advisor.

### Bloco 1 — Timing

```
You have access to an `advisor` tool backed by a stronger reviewer model. It takes NO parameters — when you call advisor(), your entire conversation history is automatically forwarded. They see the task, every tool call you've made, every result you've seen.

Call advisor BEFORE substantive work — before writing, before committing to an interpretation, before building on an assumption. If the task requires orientation first (finding files, fetching a source, seeing what's there), do that, then call advisor. Orientation is not substantive work. Writing, editing, and declaring an answer are.

Also call advisor:
- When you believe the task is complete. BEFORE this call, make your deliverable durable: write the file, save the result, commit the change. The advisor call takes time; if the session ends during it, a durable result persists and an unwritten one doesn't.
- When stuck — errors recurring, approach not converging, results that don't fit.
- When considering a change of approach.

On tasks longer than a few steps, call advisor at least once before committing to an approach and once before declaring done. On short reactive tasks where the next action is dictated by tool output you just read, you don't need to keep calling — the advisor adds most of its value on the first call, before the approach crystallizes.
```

### Bloco 2 — Como tratar o conselho (colocar logo after o bloco de timing)

```
Give the advice serious weight. If you follow a step and it fails empirically, or you have primary-source evidence that contradicts a specific claim (the file says X, the paper states Y), adapt. A passing self-test is not evidence the advice is wrong — it's evidence your test doesn't check what the advice is checking.

If you've already retrieved data pointing one way and the advisor points another: don't silently switch. Surface the conflict in one more advisor call — "I found X, you suggest Y, which constraint breaks the tie?" The advisor saw your evidence but may have underweighted it; a reconcile call is cheaper than committing to the wrong branch.
```

### Dica de custo — Trimming de output

Para reduzir custo do advisor em ~35–45% sem mudar frequência de chamadas, prepend **antes de qualquer outra sentença** que mencione o advisor:

```
The advisor should respond in under 100 words and use enumerated steps, not explanations.
```

---

## 11. Esforço (Effort Settings)

Para tarefas de coding, parear um executor Sonnet em **medium effort** com um advisor Opus atinge inteligência comparável a Sonnet em effort default, a custo menor.

Para máxima inteligência: manter executor em effort default.

---

## 12. Limitações

- Output do advisor não faz streaming — pausa no stream enquanto sub-inference roda.
- Sem cap de chamadas por conversa built-in — trackear e cappar client-side.
- `max_tokens` se aplica apenas ao output do executor, não ao advisor.
- Anthropic Priority Tier é honrado por modelo. Priority Tier no executor não se estende ao advisor — você precisa de Priority Tier especificamente no adviser model.

---

*Compilado em: 2026-04-11*
