---
name: cli-cross-review
description: Concurrent adversarial cross-model review for Claude Code, OpenAI Codex, and Antigravity. Eliminates AI confirmation bias (sycophancy) via a 3-agent cognitive triad (Builder, Red Team, Referee) with automated risk-based effort tiering.
category: devops
---

# Skill: Revisão Cruzada Multi-Modelo da Mesma CLI (`cli-revisao-cruzada`)

Esta skill orquestra a **revisão cruzada adversarial e multi-perspectiva entre diferentes modelos de inteligência artificial disponíveis na MESMA CLI** (`agy`, `codex` ou `claude`). 

Inspirada no paralelismo concorrente da skill `/swarmv2` e no rigor metodológico de stress-testing da skill `/ultra_think`, ela elimina o viés de auto-confirmação (quando um único modelo audita o próprio raciocínio) sem violar o princípio de homogeneidade de motor e sem misturar quotas entre diferentes provedores.

---

## 1. Como Invocar no Chat

A invocação segue o padrão estrito onde **o usuário obrigatoriamente declara qual CLI deve rodar**. O nível de esforço é **`--auto` por padrão** (o orquestrador analisa o risco e escolhe sozinho entre `low`, `medium` e `high`), ou você pode forçar manualmente:

```text
/cli-revisao-cruzada <cli> [--auto | --low | --medium | --high] <tema, código ou pergunta>
```

> [!IMPORTANT]
> **REGRA DE OURO: A CLI É OBRIGATORIAMENTE FORNECIDA PELO USUÁRIO!**
> O agente NUNCA deve presumir, escolher ou usar uma CLI por conta própria.
> O usuário é quem decide em qual motor o debate vai acontecer:
> - `/cli-revisao-cruzada agy <tema>`: Executa no **Antigravity** (modo `--auto` padrão).
> - `/cli-revisao-cruzada codex <tema>`: Executa no **OpenAI Codex** (modo `--auto` padrão).
> - `/cli-revisao-cruzada claude <tema>`: Executa no **Claude Code** (modo `--auto` padrão).
> 
> **Se o usuário invocar apenas `/cli-revisao-cruzada` sem especificar a CLI**, o agente **DEVE PARAR IMEDIATAMENTE** e perguntar ao usuário:
> *"Em qual CLI você deseja rodar a revisão cruzada? (`agy`, `codex` ou `claude`)"*. É estritamente proibido iniciar a execução sem essa resposta.

---

## 2. A Tríade de Papéis Cognitivos (Metodologia Ultra Think)

Em vez de três instâncias rodando prompts genéricos, a revisão cruzada aloca cada modelo da mesma CLI para um papel cognitivo especializado:

```
                            ┌──> [Modelo A: Propositor / Builder] ──────> As 3 Soluções (Minimalista, Convencional, Robusta)
[Demanda Arquitetural / PR] ┼──> [Modelo B: Red Team / Adversarial] ────> Ataque a Premissas, Falhas Críticas & Edge Cases
                            └──> [Modelo C: Auditor de Regras & Consenso] > Conformidade com Guardrails + Confidence Score
                                          │
                                          ▼
                            [Veredito Consolidado Calibrado (0-100%)]
```

1. **Modelo A — Propositor / Arquiteto (`Builder / Solution Generator`):**
   - Gera o leque de 3 soluções competidoras para a demanda (A Minimalista, A Convencional e A Robusta/Escalável), mapeando custos, código e dependências.
2. **Modelo B — Red Team / Adversarial (`Attacker / Stress-Tester`):**
   - Ataca implacavelmente as premissas ocultas e as três soluções. Identifica race conditions, vazamento de memória, gargalos de cota, pontos únicos de falha e comportamento em caso de queda de rede ou banco bloqueado.
3. **Modelo C — Auditor de Regras & Sintetizador (`Referee / Consensus & QA`):**
   - Cruza a proposta do Modelo A com os ataques do Modelo B. Audita a aderência às Regras Globais do repositório (`AGENTS.md`, ADRs e governança), pondera os trade-offs e emite a recomendação final acompanhada do **Confidence Score (0-100%)**.

---

## 3. Balanceamento de Custo e Esforço (Tiers: `auto`, `low`, `medium`, `high`)

### 3.1. O Modo `--auto` (Triagem Inteligente de Risco — 100% Vibe Coding)
Você não precisa adivinhar qual tier usar. Se você não passar flag nenhuma (ou passar `--auto`), o orquestrador analisa as palavras-chave do tema:
- **Auto -> `high`:** Se detectar termos de risco crítico (ex: `supabase`, `postgres`, `banco`, `migration`, `drop`, `transacao`, `atomic`, `estorno`, `asaas`, `stripe`, `pix`, `auth`, `token`, `seguranca`, `rls`).
- **Auto -> `low`:** Se detectar termos cosméticos/leves (ex: `css`, `tailwind`, `cor`, `padding`, `margin`, `spacing`, `layout`, `responsiv`, `typo`, `copy`, `readme`, `docs`, `icone`, `badge`, `lint`).
- **Auto -> `medium`:** Todo o resto (lógicas de negócio, refatorações, rotas, hooks, filas e concorrência).

### 3.2. Matriz Canônica de Modelos por Nível de Esforço

| CLI | `--low` (Econômico & Rápido) | `--medium` (Padrão de Engenharia) | `--high` (Segurança Máxima / Crítico) |
|---|---|---|---|
| **`codex` (OpenAI)** | `gpt-6-luna` (3x)<br>*(Latência mínima, cota insignificante)* | `gpt-6.1-sol` (1) + `gpt-6.1-sol` (2) + `gpt-6-luna`<br>*(Instâncias espelhadas do Sol: sênior sem queimar Astra)* | `gpt-6.1-sol` + **`gpt-6-astra`** + `gpt-6-luna`<br>*(Artilharia pesada da OpenAI para stress-test crítico)* |
| **`claude` (Anthropic)** | `haiku-4.5` (3x)<br>*(Ultra-leve, resposta instantânea)* | `sonnet-5` (1) + `sonnet-5` (2) + `haiku-4.5`<br>*(Melhor custo/qualidade: Sonnet no ataque sem gastar Opus)* | `sonnet-5` + **`opus-5`** + `haiku-4.5`<br>*(Fronteira pura: Opus destruindo premissas no Red Team)* |
| **`agy` (Antigravity)** | `gemini-3.8-flash-low` (3x)<br>*(Cota massiva, resposta em ~2s)* | `gemini-3.8-flash-high` (2x) + `gemini-3.8-flash-medium`<br>*(Tríade Flash Max: esforço estendido com cota infinita)* | `gemini-4-argon-high` + **`claude-opus-5-5-high`** + `flash`<br>*(Fronteira parceira máxima combinada)* |

> [!TIP]
> **Por que `--medium` é o padrão inteligente?**
> No modo padrão (`medium`), a skill utiliza **instâncias espelhadas do modelo sênior de trabalho** (ex: `sonnet-5` contra `sonnet-5` ou `gpt-6.1-sol` contra `gpt-6.1-sol`). 
> Como o Red Team recebe uma instrução de sistema adversarial agressiva isolada, ele quebra o viés de auto-confirmação com extrema competência técnica, **sem gastar as cotas preciosas de modelos ultra-pesados como Opus ou Astra**!
> 
> Deixe o `--high` exclusivamente para:
> - Alterações de schema no Supabase/PostgreSQL de produção.
> - Migrações de contratos financeiros (Asaas, Stripe).
> - Riscos de segurança e autenticação multi-tenant.

---

## 4. Estrutura do Manifesto Concorrente

A execução ocorre preferencialmente em modo **`plan` (estritamente Read-Only)**, o que garante:
- **Zero risco de colisão de escrita** (todos os 3 modelos leem os arquivos originais sem alterar o disco).
- **Execução verdadeiramente paralela** (as 3 instâncias rodam ao mesmo tempo no processador).
- **Isolamento e Segurança** (stdin fechado, sem flags perigosas como `--dangerously-*`).

Exemplo de manifesto gerado internamente para `claude`:

```json
[
  {
    "id": "claude_builder",
    "engine": "claude",
    "mode": "plan",
    "model": "sonnet-5",
    "effort": "high",
    "prompt": "[PAPEL: BUILDER / ULTRA THINK FASE 1 & 2]\nAnalise a demanda: <TEMA>\n1. Mapeie todas as premissas ocultas.\n2. Formule O TRIO DE SOLUCOES (1. Minimalista, 2. Convencional, 3. Robusta/Escalavel)."
  },
  {
    "id": "claude_redteam",
    "engine": "claude",
    "mode": "plan",
    "model": "opus-5",
    "effort": "high",
    "prompt": "[PAPEL: RED TEAM / ULTRA THINK FASE 3]\nAnalise a demanda: <TEMA>\nExecute um stress-test adversarial impiedoso: identifique o maior ponto de falha de cada abordagem, race conditions, custos ocultos e quebra de regras."
  },
  {
    "id": "claude_referee",
    "engine": "claude",
    "mode": "plan",
    "model": "haiku-4.5",
    "effort": "medium",
    "prompt": "[PAPEL: REFEREE & CONSENSO / ULTRA THINK FASE 4]\nAnalise a demanda: <TEMA>\nPondere os trade-offs entre simplicidade e robustez com base no AGENTS.md e forneca um CONFIDENCE SCORE (0-100%). Se < 85%, declare FALHA CRITICA."
  }
]
```

---

## 5. Invocação via Script Automatizado

Para disparar a revisão cruzada diretamente via PowerShell local:

```powershell
powershell -NoProfile -File .agents/skills/cli-revisao-cruzada/scripts/invoke-cross-model-review.ps1 `
  -Engine "agy" `
  -Prompt "Proposta de migracao do agendamento para WebSocket em vez de polling" `
  -Json
```

Ou especificando os modelos manualmente caso deseje uma combinação customizada:

```powershell
powershell -NoProfile -File .agents/skills/cli-revisao-cruzada/scripts/invoke-cross-model-review.ps1 `
  -Engine "claude" `
  -BuilderModel "sonnet-5" `
  -RedTeamModel "opus-5" `
  -RefereeModel "haiku-4.5" `
  -Prompt "Refatoracao do isolamento de tenant no Supabase RLS"
```

---

## 6. Formato do Relatório de Saída Consolidado

O resultado apresentado ao usuário consolida as 4 fases do `/ultra_think` enriquecidas pelo cruzamento multi-modelo:

```markdown
# 🏛️ Laudo de Revisão Cruzada Multi-Modelo (`<engine>`)

> **Motor Unificado:** `<engine>` | **Tempo Total:** `<N>s` | **Modo:** Read-Only Plan

---

### 1. 🔍 Premissas Ocultas Mapeadas
- [x] Premissa 1: ... (Validada/Contestada)
- [x] Premissa 2: ... (Restrição de Cota/Latência mapeada)

---

### 2. 💡 O Trio de Soluções (Proposto por `<Modelo-Builder>`)
1. **Minimalista (Regra 4):** ...
2. **Convencional (Padrão de Mercado):** ...
3. **Robusta / Escalável (Alta Tolerância):** ...

---

### 3. ⚔️ Stress-Test Adversarial (Ataque por `<Modelo-RedTeam>`)
- 💥 **Vulnerabilidade da Opção 1:** ...
- 💥 **Ponto Crítico da Opção 2:** ...
- 💥 **Ponto de Quebra da Opção 3:** ...

---

### 4. ⚖️ Ponderação & Consenso (Arbitrado por `<Modelo-Referee>`)
- Avaliação de conformidade com `AGENTS.md` e ADRs locais.
- Comparação de trade-offs de manutenção vs complexidade.

---

### 5. 🎯 Veredito & Confidence Score
- **Solução Recomendada:** [Opção Selecionada]
- **Confidence Score:** **XX%**
*(Se < 85%: ⚠️ FALHA CRÍTICA: Risco Arquitetural Alto. Solicito intervenção humana).*
*(Se >= 85%: Plano de execução aprovado).*
```

---

## 7. Guardrails Invioláveis

1. **Homogeneidade Estrita de CLI:**
   - Nunca misture binários diferentes na mesma revisão cruzada (ex: chamar `claude` e `codex` no mesmo manifesto é proibido nesta skill; use `/swarm-cli` para isso). Esta skill opera **exclusivamente com modelos diferentes da mesma CLI**.
2. **Modo Estritamente Read-Only (`plan`):**
   - Toda revisão cruzada roda sem mutação de arquivos no disco, garantindo zero colisão e sem poluir o repositório.
3. **Fechamento Imediato de Stdin & Sem Bypass:**
   - Nada de flags inseguras como `--dangerously-*` ou `bypassPermissions`. Stdin fechado impede travamentos por prompts interativos.
