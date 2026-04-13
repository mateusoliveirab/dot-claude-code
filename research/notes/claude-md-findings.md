# CLAUDE.md — Research Findings
> Pesquisa compilada a partir de documentação oficial, comunidade e experimentos práticos (2025–2026)

---

## Seções Essenciais

---

### 1. Project Overview é obrigatório (WHY + WHAT)
O CLAUDE.md deve começar explicando o propósito do projeto e o que existe no repositório. Sem isso, Claude não tem base de contexto alguma a cada nova sessão.  
**Main insight:** Claude não sabe nada sobre seu projeto ao início de cada sessão — esse é o ponto de partida.  
**Source:** https://www.humanlayer.dev/blog/writing-a-good-claude-md

---

### 2. Build, test & run commands são não-negociáveis
Qualquer dev deve abrir o Claude, dizer "run the tests" e funcionar na primeira tentativa. Se não funcionar, o CLAUDE.md está incompleto.  
**Main insight:** Commandos ausentes = sessão inútil desde o início.  
**Source:** https://github.com/shanraisshan/claude-code-best-practice

---

### 3. Tech stack e arquitetura são obrigatórios
Stack, padrões arquiteturais e onde encontrar as coisas no repositório — especialmente crítico em monorepos onde Claude não sabe onde olhar.  
**Main insight:** Em monorepos, sem mapa explícito Claude adivinha e erra.  
**Source:** https://www.turbodocx.com/blog/how-to-write-claude-md-best-practices

---

### 4. Code conventions só se as regras seriam violadas por padrão
Inclua apenas convenções que Claude violaria sem saber — não replique o que o linter já impõe automaticamente.  
**Main insight:** Claude não é um linter. Use linters para lint; use CLAUDE.md para o que eles não cobrem.  
**Source:** https://www.humanlayer.dev/blog/writing-a-good-claude-md

---

### 5. Critical rules & gotchas têm alto valor
Regras absolutas (nunca commitar secrets, restrições de export, padrões que Claude erraria) e gotchas documentados ao longo do tempo são o conteúdo de maior sinal do arquivo.  
**Main insight:** A seção Gotchas — onde Claude falha repetidamente no seu projeto — é a de maior valor.  
**Source:** https://github.com/shanraisshan/claude-code-best-practice

---

### 6. Progressive Disclosure com @imports é padrão validado
Aponte para arquivos adicionais em vez de embutir tudo. Use `@path/to/file` para carregar contexto sob demanda sem inflar o contexto base de toda sessão.  
**Main insight:** Pointers > copies. Arquivos apontados só consomem tokens quando necessários.  
**Source:** https://www.humanlayer.dev/blog/writing-a-good-claude-md

---

### 7. Workflow preferences ajudam com comportamento de sessão
Como Claude deve se comportar durante o trabalho: preferir testes unitários, criar branch por task, pedir confirmação antes de deletar arquivos.  
**Main insight:** Preferências de workflow evitam correções repetidas de comportamento padrão.  
**Source:** https://www.eesel.ai/blog/claude-code-best-practices

---

### 8. O padrão WHY / WHAT / HOW é o consenso da comunidade
Estruturar em três camadas: WHY (propósito), WHAT (stack e estrutura), HOW (como trabalhar). Espelha o onboarding de um dev sênior entrando no time.  
**Main insight:** Trate CLAUDE.md como briefing para um dev experiente — não como documentação completa.  
**Source:** https://www.turbodocx.com/blog/how-to-write-claude-md-best-practices

---

### 9. Seção "Active Task Context" rotada a cada sessão
Incluir sprint atual, blockers e próximos passos — mas com nota para remover itens completos ao final de cada sessão para não acumular contexto obsoleto.  
**Main insight:** Contexto de tarefa ativo reduz re-explicações; mas precisa de manutenção constante.  
**Source:** https://www.sitepoint.com/claude-code-context-management/

---

### 10. Compact instructions customizadas dentro do CLAUDE.md
Você pode adicionar instruções para guiar o comportamento do `/compact` diretamente no arquivo, dizendo o que preservar durante sumarização automática.  
**Main insight:** `# Compact instructions: focus on test output and code changes` → sumarização mais útil.  
**Source:** https://code.claude.com/docs/en/costs

---

## Regras de Ouro e Anti-padrões

---

### 11. O teste de cada linha: "se eu remover, Claude erra?"
Antes de incluir qualquer linha, pergunte: remover isso causaria um erro? Se não, corte. Linhas decorativas ou aspiracionais prejudicam o arquivo.  
**Main insight:** Cada linha que não muda comportamento é barulho que dilui as que mudam.  
**Source:** https://code.claude.com/docs/en/best-practices

---

### 12. CLAUDE.md bloated faz Claude ignorar tudo uniformemente
Arquivos longos demais fazem Claude ignorar instruções não por descaso, mas porque a qualidade de instruction-following cai de forma uniforme — não seletiva.  
**Main insight:** Claude não ignora as novas instruções — ele começa a ignorar todas igualmente.  
**Source:** https://www.humanlayer.dev/blog/writing-a-good-claude-md

---

### 13. Não use /init para gerar CLAUDE.md automaticamente
CLAUDE.md é o ponto de maior alavancagem do harness — afeta cada fase do workflow. Auto-geração produz arquivos genéricos e inflados que prejudicam mais do que ajudam.  
**Main insight:** Uma linha ruim no CLAUDE.md cria muito mais dano do que uma linha ruim de código.  
**Source:** https://www.humanlayer.dev/blog/writing-a-good-claude-md

---

### 14. Claude não é um linter — nunca mande LLM fazer trabalho de linter
Diretrizes de estilo de código no CLAUDE.md adicionam instruções e snippets irrelevantes que degradam performance. Use Biome, ESLint, Prettier para isso.  
**Main insight:** LLMs são ordens de magnitude mais lentos e caros que linters para a mesma tarefa.  
**Source:** https://www.humanlayer.dev/blog/writing-a-good-claude-md

---

### 15. Não inclua snippets de código — ficam desatualizados
Em vez de exemplos de código inline, use referências `file:line` que apontam para o código real e autoritativo no repositório.  
**Main insight:** Snippets no CLAUDE.md são técnica dívida que cresce com o projeto.  
**Source:** https://rosmur.github.io/claudecode-best-practices/

---

### 16. Use IMPORTANT / YOU MUST para regras críticas
Para regras que não podem ser ignoradas, adicionar ênfase explícita melhora aderência — especialmente no início da sessão quando o contexto ainda está limpo.  
**Main insight:** Ênfase ajuda no início; perde eficácia em sessões longas (ver Context Rot).  
**Source:** https://code.claude.com/docs/en/best-practices

---

### 17. Versione CLAUDE.md no git — o arquivo se valoriza com o tempo
A equipe toda contribui; histórico mostra evolução das regras; o arquivo compounding em valor conforme erros são documentados como gotchas.  
**Main insight:** CLAUDE.md como código: tem dono, tem review, tem história.  
**Source:** https://code.claude.com/docs/en/best-practices

---

### 18. Trate CLAUDE.md como código — revise quando algo der errado
Se Claude pergunta algo respondido no CLAUDE.md, a frase é ambígua. Se ignora uma regra, o arquivo está longo demais. Prune regularmente.  
**Main insight:** CLAUDE.md é código de configuração — merece o mesmo rigor editorial.  
**Source:** https://code.claude.com/docs/en/best-practices

---

### 19. Use Hooks para comportamento determinístico, não CLAUDE.md
CLAUDE.md é advisory — Claude pode ignorar. Hooks são determinísticos — sempre executam. Para "nunca faça X", prefira um hook que bloqueia X.  
**Main insight:** Regras críticas pertencem a Hooks (settings.json), não a instruções de texto.  
**Source:** https://code.claude.com/docs/en/best-practices

---

### 20. Coloque regras críticas no início do CLAUDE.md
Attention mechanisms de LLMs privilegiam início e fim do contexto. Regras no meio têm menor chance de serem seguidas — especialmente em sessões longas.  
**Main insight:** Ordem importa: o que vem primeiro tem maior probabilidade de ser seguido.  
**Source:** https://liquidmetal.ai/casesAndBlogs/context-engineering-claude-code/

---

## Token Usage e Context Bloat

---

### 21. O contexto é o recurso mais importante a gerenciar
Quase todas as boas práticas derivam de uma única restrição: a context window enche rápido e performance degrada conforme enche. É o princípio unificador.  
**Main insight:** Gerenciar contexto é a skill #1 — mais impactante que qualquer outra otimização.  
**Source:** https://code.claude.com/docs/en/best-practices

---

### 22. ~50 instruções já estão no system prompt antes do seu CLAUDE.md
O Claude Code injeta ~50 instruções próprias antes de qualquer coisa sua. Frontier models seguem ~150–200 instruções consistentemente — você já gastou 1/3 do orçamento.  
**Main insight:** Seu CLAUDE.md disputa atenção com 50 instruções que já existem no sistema.  
**Source:** https://www.humanlayer.dev/blog/writing-a-good-claude-md

---

### 23. CLAUDE.md com 2.100 tokens entrega 14-28% de contexto relevante
Experimento empírico: CLAUDE.md bloated carregava 2.100 tokens, mas apenas 300–600 eram relevantes para a tarefa. 62% dos tokens eram desperdício puro.  
**Main insight:** Mais contexto ≠ melhor contexto. Relevância > volume.  
**Source:** https://medium.com/@jpranav97/stop-wasting-tokens-how-to-optimize-claude-code-context-by-60-bfad6fd477e5

---

### 24. Sistema de 3 camadas reduz tokens iniciais em 62%
Camada 1 (CLAUDE.md lean) + Camada 2 (agent_docs/ sob demanda) + Camada 3 (Skills semânticas) → 85% de relevância vs 14-28% no modelo monolítico.  
**Main insight:** Arquitetura de contexto em camadas é o maior alavancador de eficiência.  
**Source:** https://medium.com/@jpranav97/stop-wasting-tokens-how-to-optimize-claude-code-context-by-60-bfad6fd477e5

---

### 25. Skills com Progressive Disclosure recuperam ~15.000 tokens por sessão
Um time com 20+ skills carregadas sob demanda vs tudo no CLAUDE.md recupera 82% dos tokens iniciais por sessão — equivalente a 15.000 tokens livres para código real.  
**Main insight:** Skills são a solução definitiva para context bloat em projetos maduros.  
**Source:** https://claudefa.st/blog/guide/development/usage-optimization

---

### 26. Refatoração de CLAUDE.md de 7.584 para 3.434 tokens (54% menos)
Caso documentado: desenvolvedor moveu tudo para Skills, manteve apenas hard rules + trigger table no CLAUDE.md. 30+ skills carregadas sob demanda.  
**Main insight:** CLAUDE.md mínimo + Skills é arquitetura superior ao CLAUDE.md completo.  
**Source:** https://gist.github.com/johnlindquist/849b813e76039a908d962b2f0923dc9a

---

### 27. Cada linha do CLAUDE.md custa tokens em cada API call da sessão
O arquivo é injetado no system prompt e permanece lá durante toda a sessão. Uma linha irrelevante não é inofensiva — é um custo recorrente em cada mensagem.  
**Main insight:** Custo de uma linha no CLAUDE.md = custo da linha × número de mensagens na sessão.  
**Source:** https://www.sitepoint.com/claude-code-context-management/

---

### 28. Prompt caching recompensa estabilidade do CLAUDE.md
Claude Code usa prompt caching por padrão para conteúdo repetido. CLAUDE.md estável = cache hit frequente = custo ~90% menor para aqueles tokens.  
**Main insight:** Mudar CLAUDE.md frequentemente invalida o cache e aumenta custo real.  
**Source:** https://code.claude.com/docs/en/costs

---

### 29. Buffer de 33K tokens reservado para auto-compaction (não disponível)
Claude Code reserva ~33K tokens do contexto para o processo de sumarização do auto-compact. Esse buffer não está disponível para sua conversa ou código.  
**Main insight:** Janela efetiva de 200K = ~167K utilizáveis antes do auto-compact disparar.  
**Source:** https://claudefa.st/blog/guide/mechanics/context-buffer-management

---

### 30. Auto-compact dispara em 83.5% — mas performance já degradou antes
O threshold padrão é 83.5% da janela, mas degradação de qualidade começa muito antes. Compactação manual proativa é mais eficaz que deixar o auto-compact agir.  
**Main insight:** Esperar o auto-compact é como consertar o pneu depois de furar — funciona, mas a viagem já foi ruim.  
**Source:** https://claudefa.st/blog/guide/mechanics/context-buffer-management

---

### 31. CLAUDE_AUTOCOMPACT_PCT_OVERRIDE — controle manual do threshold
Variável de ambiente que permite ajustar quando auto-compact dispara. Valor 70 = mais conservador e seguro; valor 90 = mais contexto antes de compactar.  
**Main insight:** `export CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70` é a configuração mais segura para projetos críticos.  
**Source:** https://claudefa.st/blog/guide/mechanics/context-buffer-management

---

### 32. Custo médio enterprise: ~$13/dev/dia ativo, $150–250/mês
Referência oficial da Anthropic para deployments enterprise. 90% dos usuários ficam abaixo de $30/dia ativo. Base para calcular ROI de otimizações de contexto.  
**Main insight:** Otimização de 62% em tokens = ~$90/mês economizados por developer ativo.  
**Source:** https://code.claude.com/docs/en/costs

---

## Context Rot — O Fenômeno Central

---

### 33. Context Rot: degradação de qualidade antes do limite de tokens
Context rot é a degradação gradual de qualidade conforme o contexto enche com histórico, tentativas falhas, debug loops e instruções obsoletas — bem antes do hard limit.  
**Main insight:** Não é bug. É a mecânica de LLMs: noise acumula, signal se dilui.  
**Source:** https://www.mindstudio.ai/blog/context-rot-ai-coding-agents-explained

---

### 34. O problema "Lost in the Middle" — recall cai no centro do contexto
Pesquisa consistente mostra que modelos lembram informações no início e no fim do contexto de forma mais confiável. O meio é where things get lost — exatamente onde CLAUDE.md acaba em sessões longas.  
**Main insight:** CLAUDE.md injetado no início migra para o "meio" conforme a conversa cresce.  
**Source:** https://www.mindstudio.ai/blog/context-rot-claude-code-skills-bloated-files

---

### 35. Degradação estimada: ~2% de efetividade a cada 100K tokens adicionados
Extrapolação da pesquisa Chroma e Context Arena: degradação é aproximadamente linear. A 200K tokens, você já perdeu ~4% vs contexto limpo — e cresce a partir daí.  
**Main insight:** 1M de context window ≠ 1M de qualidade uniforme. A curva existe.  
**Source:** https://marketingagent.blog/2026/03/14/tutorial-claude-1m-context-window-context-rot/

---

### 36. Quando context window < 50% cheia: perde tokens do meio
Pesquisa documenta dois modos de degradação: abaixo de 50% de uso, o modelo perde tokens do meio; acima de 50%, perde os mais antigos (onde CLAUDE.md está).  
**Main insight:** Em ambos os casos, o CLAUDE.md fica vulnerável à medida que a sessão avança.  
**Source:** https://www.producttalk.org/context-rot/

---

### 37. Janela de 1M tokens não entrega qualidade uniforme em projetos reais
Caso documentado com 25+ sessões reais e 20K+ registros: degradação mensurável ocorre antes do limite anunciado. "Reliable context" é menor que o número do marketing.  
**Main insight:** Comunidade convergiu: limpar agressivamente a partir de 200K tokens é defensável.  
**Source:** https://github.com/anthropics/claude-code/issues/35296

---

### 38. Janela maior atrasa o hard limit, mas não elimina a degradação
Mesmo dentro do limite, performance cai porque o problema é noise accumulation e attention dilution — não capacidade. Mais espaço = mais espaço para ruído, não para qualidade.  
**Main insight:** Context rot é sobre relação sinal/ruído, não sobre bytes disponíveis.  
**Source:** https://www.mindstudio.ai/blog/context-rot-ai-coding-agents-explained

---

### 39. Sinais de context rot: Claude sugere o que você proibiu
Os sintomas mais confiáveis: sugerir biblioteca explicitamente descartada, contradizer decisões arquiteturais da mesma sessão, respostas hedgeadas sem objetividade.  
**Main insight:** Se uma tarefa simples exige 3+ rounds, o contexto está ruidoso — não a tarefa.  
**Source:** https://www.mindstudio.ai/blog/what-is-context-rot-claude-code

---

### 40. O "Smile Problem" — por que IMPORTANT em caps perde eficácia em sessões longas
Attention concentra no início e no fim do contexto (curva em "smile"). Regras do CLAUDE.md com IMPORTANT ajudam no começo, mas perdem eficácia conforme o contexto cresce.  
**Main insight:** IMPORTANT ≠ garantia em sessões longas. Sessões curtas e focadas são a solução real.  
**Source:** https://liquidmetal.ai/casesAndBlogs/context-engineering-claude-code/

---

## Gestão Proativa de Sessão

---

### 41. /compact proativo em checkpoints naturais — não espere o auto
Rode /compact manualmente após completar uma feature ou milestone. Com contexto ainda limpo, o modelo produz sumários muito melhores que o auto-compact em estado degradado.  
**Main insight:** Compactação preventiva em contexto saudável > compactação reativa em contexto saturado.  
**Source:** https://www.mindstudio.ai/blog/claude-code-token-management-hacks-3

---

### 42. /compact aceita instrução customizada — subutilizado pela maioria
`/compact Focus on architectural decisions, API contracts, and TODOs` — isso transforma compressão genérica em curadoria cirúrgica do que sobrevive.  
**Main insight:** Instrução customizada no /compact é o maior lever subutilizado de gestão de contexto.  
**Source:** https://www.sitepoint.com/claude-code-context-management/

---

### 43. Sessões curtas por tarefa superam maratonas longas
Uma sessão por fase (schema → API → frontend) com handoff explícito entre elas produz melhor resultado do que uma sessão longa cobrindo tudo com contexto acumulado.  
**Main insight:** Trate sessões como Git commits: escopo claro, estado final definido.  
**Source:** https://www.mindstudio.ai/blog/claude-code-token-management-hacks-3

---

### 44. Handoff notes antes de /clear: resumo estruturado do estado atual
Antes de limpar, gere um sumário estruturado: o que foi decidido, o que foi escrito, o que ainda precisa acontecer. Cole no início da próxima sessão.  
**Main insight:** /clear + handoff note = novo começo sem perda de decisões críticas.  
**Source:** https://www.mindstudio.ai/blog/context-rot-ai-coding-agents-explained

---

### 45. /clear quando contexto está corrompido é mais rápido que lutar
Para sessões de 60+ minutos ou quando os sintomas de context rot aparecem, recomeçar com handoff note é mais eficiente do que tentar recuperar um contexto degradado.  
**Main insight:** Sunk cost fallacy se aplica a contextos: às vezes é melhor começar do zero.  
**Source:** https://claudefa.st/blog/guide/mechanics/context-management

---

### 46. Context refresh a cada 30 minutos em sessões longas
Prompt periódico para Claude revisar mudanças recentes e confirmar padrões atuais evita context drift gradual — quando Claude perde alinhamento com os requisitos específicos.  
**Main insight:** `"Review recent changes and confirm current patterns"` a cada ~30min em sessões críticas.  
**Source:** https://claudefa.st/blog/guide/mechanics/context-management

---

### 47. .claudeignore — alta alavancagem, subutilizado
Arquivo análogo ao .gitignore que exclui o que Claude nunca deve explorar. Se Claude não pode ver, não pode ler por acidente e desperdiçar tokens.  
**Main insight:** node_modules, dist, *.log, coverage/ nunca devem entrar no contexto.  
**Source:** https://www.mindstudio.ai/blog/claude-code-token-management-hacks-3

---

### 48. Instruções específicas por arquivo, não busca exploratória
Em vez de "olha o codebase e descobre X", diga exatamente qual arquivo e linha olhar. Evita que Claude leia múltiplos arquivos em sequência, cada um adicionando tokens ao contexto.  
**Main insight:** Contexto cirúrgico > exploração aberta. Você paga por cada arquivo que Claude lê.  
**Source:** https://www.mindstudio.ai/blog/claude-code-token-management-hacks-3

---

## Roteamento de Modelo e Custo

---

### 49. Roteamento por complexidade: Haiku → Sonnet → Opus
Haiku para lookups e formatação; Sonnet para 80% do trabalho diário; Opus para arquitetura complexa e debugging difícil. Não use Ferrari para ir ao mercado.  
**Main insight:** Modelo errado para a tarefa errada é o segundo maior desperdício depois de context bloat.  
**Source:** https://www.sabrina.dev/p/6-ways-i-cut-my-claude-token-usage

---

### 50. opusplan — híbrido Opus para planejar + Sonnet para executar
Alias de modelo que usa Opus durante o planning mode (raciocínio complexo) e muda automaticamente para Sonnet na implementação. Qualidade de Opus, custo parcial de Opus.  
**Main insight:** Planejamento exige raciocínio profundo; implementação não — separe os dois.  
**Source:** https://claudefa.st/blog/guide/development/usage-optimization

---

### 51. Extended thinking consome dezenas de milhares de tokens por request
Thinking tokens são cobrados como output tokens. O budget padrão pode ser dezenas de milhares por request em tasks simples. Reduza com `MAX_THINKING_TOKENS=8000`.  
**Main insight:** `export MAX_THINKING_TOKENS=8000` para tasks que não precisam de raciocínio profundo.  
**Source:** https://code.claude.com/docs/en/costs

---

### 52. DISABLE_NON_ESSENTIAL_MODEL_CALLS=1 — reduz chamadas de background
Desabilita chamadas de modelo usadas para sugestões e tips não críticos. Não afeta o workflow core mas reduz consumo de tokens de background invisível.  
**Main insight:** Tokens invisíveis (sugestões, tips) somam ao longo do dia — vale desabilitar em produção.  
**Source:** https://claudefa.st/blog/guide/development/usage-optimization

---

## O que os Profissionais Validaram

---

### 53. HumanLayer: CLAUDE.md de 60 linhas funciona melhor que 300
A equipe mantém CLAUDE.md raiz com menos de 60 linhas usando Progressive Disclosure com pasta agent_docs/. O argumento: cada linha não-universal dilui as que são.  
**Main insight:** Menos linhas, mais universalmente aplicáveis = melhor instruction-following.  
**Source:** https://www.humanlayer.dev/blog/writing-a-good-claude-md

---

### 54. Vercel: deletar 80% das ferramentas melhorou o agente
Time construiu agente com 15 ferramentas especializadas. Simplificou para 1 (bash). Resultado: 100% de sucesso vs 80%, menos tokens, respostas mais rápidas. Subtração funciona.  
**Main insight:** Complexidade de ferramentas fragiliza agentes. Simplicidade radical pode ser superior.  
**Source:** https://medium.com/@gbx1220max/agent-skills-for-context-engineering-are-here-ready-for-claude-code-codex-garnering-2-3k-00d720ec55bd

---

### 55. shanraisshan/claude-code-best-practice — 84 práticas validadas, 20K+ stars
Repositório que compilou 84 boas práticas de usuários reais, atingiu o topo do GitHub Trending. Inclui práticas de prompting, CLAUDE.md, skills, debugging e git.  
**Main insight:** O repositório mais referenciado pela comunidade para práticas validadas em campo.  
**Source:** https://github.com/shanraisshan/claude-code-best-practice

---

### 56. Instrução-following cai de forma linear com frontier models, exponencial com menores
Pesquisa (arxiv 2507.11538): modelos frontier degradam linearmente; modelos menores degradam exponencialmente com mais instruções. CLAUDE.md longo penaliza muito mais modelos pequenos.  
**Main insight:** Quanto menor o modelo que você usa, mais crítico é manter CLAUDE.md enxuto.  
**Source:** https://www.humanlayer.dev/blog/writing-a-good-claude-md

---

### 57. Skills com routing semântico — o sistema operacional de paging para IA
Progressive Disclosure semântica: agent lê apenas nome e descrição de todas as skills; carrega o SKILL.md completo apenas quando a task é relevante. Como paging de SO.  
**Main insight:** Skills bem descritas = routing automático sem você precisar invocar manualmente.  
**Source:** https://medium.com/@gbx1220max/agent-skills-for-context-engineering-are-here-ready-for-claude-code-codex-garnering-2-3k-00d720ec55bd

---

### 58. Documentar features específicas (FEATURE.md) é mais eficiente que documentar o codebase todo
Workflow validado: explique uma feature específica para Claude, peça para ele documentar no FEATURE.md, use /clear, referencie o arquivo na próxima sessão.  
**Main insight:** Contexto cirúrgico de feature > contexto genérico de todo o projeto.  
**Source:** https://alabeduarte.com/context-engineering-with-claude-code-my-evolving-workflow/

---

### 59. Alucinações em knowledge documents são catastróficas — efeito compounding
Um padrão de API errado em um arquivo de conhecimento significa que toda implementação futura será errada. Valide knowledge docs com especialistas de domínio antes de usar.  
**Main insight:** Erros em contexto persistente se multiplicam — cada sessão os replica.  
**Source:** https://thomaslandgraf.substack.com/p/context-engineering-for-claude-code

---

### 60. Anthropic: "inteligência não é o gargalo — contexto é"
Citação direta de talks da equipe da Anthropic no AWS re:Invent 2025. Cada organização tem workflows e conhecimentos únicos que Claude não sabe — o contexto é o diferencial.  
**Main insight:** O valor do CLAUDE.md bem feito não é corrigir limitações do modelo; é trazer o que só você sabe.  
**Source:** https://01.me/en/2025/12/context-engineering-from-claude/

---

*Compilado por pesquisa em abril de 2026 | 60 findings | Fontes: documentação oficial Anthropic, comunidade GitHub, Medium, blogs de engenharia*
