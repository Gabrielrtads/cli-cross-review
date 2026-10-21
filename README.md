# 🏛️ CLI Cross Review (`cli-cross-review`)

[![skills.sh compatible](https://img.shields.io/badge/skills.sh-compatible-6366f1?style=for-the-badge)](https://skills.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Zero-Dependency](https://img.shields.io/badge/Dependencies-Zero-emerald?style=for-the-badge)](#)
[![Mode](https://img.shields.io/badge/Mode-Strictly_Read--Only_Plan-purple?style=for-the-badge)](#)
[![Cost-Smart](https://img.shields.io/badge/Architecture-Cost--Smart_Tiers-10b981?style=for-the-badge)](#)

> **Eliminate AI Confirmation Bias (Sycophancy) in your terminal.**  
> Turn your **Claude Code**, **OpenAI Codex**, or **Antigravity CLI (Gemini)** into a concurrent, 3-model adversarial court before writing code.

---

## ⚡ The Problem: AI Sycophancy (*"Looks good to me!"*)

When you ask an AI coding agent to review the code or architecture it just produced, it almost always responds:  
*"Everything looks great and follows best practices!"*

A single model **cannot break its own cognitive blind spots**. Asking an AI to review itself is like asking an author to proofread their own typo — their brain already knows what was intended, so they read past the flaw.

Traditional multi-agent frameworks (CrewAI, AutoGen) attempt to solve this, but they are heavy, slow, require external Python servers, and burn through random API keys.

---

## 💡 The Solution: Intra-CLI Cognitive Triad

`cli-cross-review` runs **three specialized AI instances of the SAME CLI simultaneously** in isolated, strictly **Read-Only (`plan`) mode**. No write collisions, no extra subscriptions, zero external dependencies:

```
                            ┌──> [Model A: Builder] ──────> 3 Competing Solutions (Minimal, Standard, Robust)
[Task / PR Architecture] ───┼──> [Model B: Red Team] ─────> Adversarial Attack (Catastrophic Failures & Locks)
                            └──> [Model C: Referee] ──────> Governance Compliance + Confidence Score (0-100%)
                                          │
                                          ▼
                            [Calibrated Consensus Verdict]
```

1. **Model A — Builder (`Solution Generator`):** Formulates 3 competing architectural approaches.
2. **Model B — Red Team (`Adversarial Stress-Tester`):** Receives an isolated, hostile system prompt. Hunts for race conditions, deadlocks, hidden quota limits, and memory leaks.
3. **Model C — Referee (`Consensus & Rules Auditor`):** Compares the proposal with the attacks, verifies rule adherence, and issues a final recommendation with a **Confidence Score (0-100%)**. *(If < 85%, flags a Critical Failure).*

---

## 💰 Cost-Smart Review Strategy (Save 85%+ on AI Token Consumption)

Why burn expensive frontier models like Claude Opus or Codex Astra on everyday layout tweaks or simple refactorings?

`cli-cross-review` allows you to calibrate reviews based on the actual financial or systemic risk of the code:

1. **Daily High-Volume Audits (Ultra-Low Cost / Free Tier):**
   - Use **`agy` (Antigravity / Gemini Flash)** or `--low`: Runs 3 concurrent instances with massive quotas at sub-2s speed. Ideal for PR sanity checks, doc reviews, and CSS audits without burning paid token balances.
2. **Standard Product Logic (Smart Balanced Default):**
   - Use **`codex`** or **`claude`** with default `--auto`: Two mirrored senior instances duel against each other (one proposes, one attacks) before consulting a referee, giving you elite code quality without burning your highest-tier subscription limits.
3. **Mission-Critical & High-Stakes (Frontier Escalate):**
   - For payment webhooks, database migrations, and authentication flows, pass `--high` to unleash top-tier frontier red-teaming (**Claude Opus** or **Codex Astra**).

---

## 🎚️ Model & Effort Matrix (`--auto`, `low`, `medium`, `high`)

Never burn expensive frontier tokens on simple cosmetic tweaks. The skill features an **automated risk-based router (`--auto` by default)**:

| Engine | `--low` (Ultra-Fast & Free) | `--medium` (Smart Default) | `--high` (Critical Security & DB) |
|---|---|---|---|
| **`claude`** *(Claude Code)* | `haiku-4.5` (3x)<br>*(Instant response, ~2s)* | `sonnet-5` (1) + `sonnet-5` (2) + `haiku-4.5`<br>*(Mirrored Sonnet: senior review without burning Opus)* | `sonnet-5` + **`opus-5`** + `haiku-4.5`<br>*(Frontier Red Team for critical architecture)* |
| **`codex`** *(OpenAI Codex)* | `gpt-6-luna` (3x)<br>*(Minimal token consumption)* | `gpt-6.1-sol` (1) + `gpt-6.1-sol` (2) + `gpt-6-luna`<br>*(Mirrored Sol instances for logic & backend)* | `gpt-6.1-sol` + **`gpt-6-astra`** + `gpt-6-luna`<br>*(Heavy mathematical & formal logic stress-testing)* |
| **`agy`** *(Antigravity)* | `gemini-3.8-flash-low` (3x)<br>*(Massive quota, sub-2s)* | `gemini-3.8-flash-high` (2x) + `gemini-3.8-flash-medium`<br>*(Extended reasoning with infinite quota)* | `gemini-4-argon-high` + **`claude-opus-5-5-high`** + `flash`<br>*(Combined partner frontier engines)* |

---

## 🚀 Quick Start (1-Click Install via `skills.sh`)

Install directly into your agent environment using the open Skills CLI:

```bash
npx skills add Gabrielrtads/cli-cross-review
```

Or install for specific agents:
```bash
# For Claude Code
npx skills add Gabrielrtads/cli-cross-review --agent claude-code

# For OpenAI Codex
npx skills add Gabrielrtads/cli-cross-review --agent codex

# For Google Antigravity
npx skills add Gabrielrtads/cli-cross-review --agent antigravity
```

---

## 💻 How to Use in Chat

Simply declare the CLI you want to use and your task. The **`--auto`** router classifies the risk automatically:

```text
/cli-cross-review claude "Refactor booking state drawer to use modern React 19 transitions"
```

### Manual Effort Overrides

You can explicitly force an effort tier whenever needed:

* **Econômico / Fast (`--low`):**
  ```text
  /cli-cross-review agy --low "Review Tailwind CSS layout for mobile screens below 380px"
  ```
* **Engenharia Padrão (`--medium`):**
  ```text
  /cli-cross-review codex --medium "Implement webhook retry queue with idempotency keys"
  ```
* **Segurança Máxima (`--high`):**
  ```text
  /cli-cross-review claude --high "Review Supabase RLS multitenant isolation and atomic refund transaction"
  ```

---

## 🛡️ Inviolable Guardrails

1. **Strictly Read-Only (`plan` mode):** All 3 tasks run in plan mode without workspace mutation or write permissions. Zero risk of corrupting Git history or file collisions.
2. **Mandatory CLI Declaration:** The user is always in control of which CLI engine is called. The agent never silently assumes an engine.
3. **Closed Stdin & No Bypass:** No `--dangerously-skip-permissions`. Stdin is immediately closed, preventing hanging interactive prompts.

---

## 🇧🇷 Documentação em Português

### O que é o `cli-cross-review`?
É uma skill de terminal que executa uma **revisão cruzada adversarial entre 3 modelos da mesma CLI** (`claude`, `codex` ou `agy`). Ela elimina o viés de auto-confirmação (*sycophancy*) sem quebrar o isolamento do seu repositório e sem gastar cotas de múltiplos provedores ao mesmo tempo.

### 💰 Estratégia Custo-Inteligente (Economize 85%+ em Tokens):
- **Varredura em Massa Custo Zero:** Usar `agy` (Antigravity / Gemini Flash) ou a flag `--low` roda 3 processos concorrentes com resposta em sub-2s e cotas gratuitas/baratas, ideal para checar formatação, layout e sanidade de commits.
- **Modelos Espelhados no Dia a Dia:** No modo padrão (`medium`), dois processos do modelo sênior duelam entre si (um propõe, o outro ataca com prompt agressivo), poupando suas cotas nobres de Opus e Astra.
- **Escalada de Fronteira no Risco:** Deixe os modelos mais caros e inteligentes (Opus no Claude, Astra no Codex) exclusivamente para quando passar `--high` ou quando o código envolver pagamentos, RLS e segurança crítica.

---

## 📄 License

MIT © [Gabriel Toledo](https://github.com/Gabrielrtads)
