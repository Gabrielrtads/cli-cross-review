---
name: sta
description: Adversarial multi-model cross-review court (2 rounds: Defense vs Prosecution -> Magistrate). Eliminates AI sycophancy, stress-tests architecture, and delivers decisive verdicts on code, business, or PRs. / STA: Supremo Tribunal dos Agentes. A Corte Suprema de revisão adversarial no terminal. Use when you need a second opinion, stress testing, adversarial review, or invoke with '/sta', 'julgar caso'.
category: devops
tags: [sta, ai-court, supreme-tribunal, cross-review, adversarial, multi-model, second-opinion, code-review, sycophancy, decision-making, ultra-think]
---

# 🏛️ STA: Supremo Tribunal dos Agentes (`/sta`)
> **A Corte Suprema de Inteligência Artificial no seu Terminal.**  
> *(Supreme Tribunal of Agents)*  
> Elimine o vício das IAs que dizem "sim" para tudo. Submeta qualquer código, ideia de negócio, roteiro ou decisão crítica a 3 modelos concorrentes em julgamento dialético real em 2 rodadas.

---

## ⚡ Como Invocar (100% Vibe Coding)

Sem menus chatos nem flags obrigatórias. O STA detecta o ambiente e a matéria automaticamente:

```text
/sta <caso, pergunta, código ou decisão>
```

### Exemplos do Dia a Dia:

1. **Julgamento de Código ou Arquitetura:**
   ```text
   /sta "Criei este webhook de pagamento com retry no Redis. O que vai quebrar sob pico?"
   /sta --diff                       # Julga automaticamente as alterações do git diff
   /sta --staged                     # Julga o que está staged para commit
   /sta --file src/auth.ts           # Julga um arquivo específico
   ```

2. **Julgamento de Negócio, Pricing & SaaS:**
   ```text
   /sta "Devo cobrar R$ 97 fixo ou 3% por agendamento no Barber.fi?"
   ```

3. **Julgamento Criativo, Roteiro & Vídeo:**
   ```text
   /sta "Esse gancho dos 3 segundos para Reels tem retenção ou vai flopar?"
   ```

4. **Modo "Corte Marcial" (Auditoria Implacável):**
   ```text
   /sta --fogo "Revise a migração do banco de dados de produção antes do deploy"
   ```
   *(Sinônimos: `--fogo`, `--hard`, `--corte-marcial`). Convocação dos modelos de fronteira máxima (Opus, Astra, Gemini Argon).*

5. **Modo Piada / Sessão Plenária da TV Justiça (`--zoeira`, `--brasil`, `--meme`, `--plenario`):**
   ```text
   /sta --zoeira "Dá uma olhada nesse webhook de cobrança que fiz correndo"
   /sta --brasil "Esse refactor passa no STA ou vai tomar multa de 50 mil tokens?"
   ```
   *(Emite a ata de julgamento com a bancada dos ministros, pedidos de vista e debates inflamados, entregando no final o Patch Git sério e corrigido).*

6. **Override Manual de CLI (Opcional):**
   ```text
   /sta agy "Meu plano de contingência para a VPS"
   /sta claude "Refatoração do motor de busca FTS5"
   /sta codex "Otimização de queries SQL"
   ```

---

## 🏛️ A Dinâmica da Corte: 3 Poderes em 2 Rodadas

Diferente de ferramentas que apenas colam três respostas no vácuo, o STA opera em **2 rodadas causais com barreira de sincronização**:

```
                       [O CASO SUBMETIDO AO STA]
                                     │
           ┌─────────────────────────┴─────────────────────────┐
           ▼                                                   ▼
 🛡️ 1. A DEFESA (Builder)                           🔥 2. A ACUSAÇÃO (Promotor / Red Team)
 Formula a melhor tese e o Trio                     Ataca impiedosamente: caça o bug, o churn,
 de Soluções (Minimalista, Padrão, Robusta).        a falha de caixa ou o ponto cego.
           │                                                   │
           └─────────────────────────┬─────────────────────────┘
                                     │  (Barreira de Sincronização & Fail-Fast)
                                     ▼
                      👑 3. O MAGISTRADO (Juiz Supremo)
                      Recebe os autos da Defesa E da Acusação,
                      confronta as evidências e emite a Sentença.
                                     │
                                     ▼
                 [LAUDO JUDICIAL COM VEREDITO EM DESTAQUE]
```

1. **Rodada 1 (Duelo Concorrente em Paralelo):** A Defesa e a Acusação sustentam seus pontos ao mesmo tempo no processador sem bloquear o fluxo.
2. **Barreira de Sincronização & Fail-Fast:** Se uma das partes falhar, a corte suspende a sessão imediatamente, economizando 100% dos tokens do Juiz.
3. **Rodada 2 (O Julgamento Informado):** O Magistrado recebe a íntegra da sustentação da Defesa e o ataque da Acusação, pondera as regras do projeto e bate o martelo.

---

## 🧭 As 4 Varas Judiciais (Auto-Detecção de Matéria)

O STA identifica a matéria do caso automaticamente:
- **1ª Vara de Crimes e Arquitetura de Código:** Foco em bugs, memory leaks, concorrência, OWASP e entrega de **Patch Git**.
- **2ª Vara Cível de Negócios & SaaS:** Foco em unit economics, churn, riscos de caixa e **Plano de Ação em 3 etapas**.
- **3ª Vara Especial de Conteúdo & Retenção:** Foco no gancho dos 3s, mecânica neurológica de retenção e **Cópias A/B reescritas**.
- **Plenário Estratégico de Tomada de Decisão:** Dilemas gerais, custo de oportunidade e veredito ponderado.

---

## 🎛️ Régua de Esforço

| Esforço | Gatilho | Motores Acionados (na CLI `agy`) | Tipo de Julgamento |
|---|---|---|---|
| **`--low`** | `--low`, `--rapido`, `--leve` | `flash-low` (3x) | Bate-pronto em ~2 segundos. |
| **`--medium`** | Padrão / `--medium` | `flash-high` (2x) + `flash-medium` | Julgamento aprofundado com caça a premissas. |
| **`--high`** | `--high`, `--fogo`, `--corte-marcial` | `gemini-4-argon` + `claude-opus` + `flash-high` | Batalha de fronteira máxima para decisões críticas. |
| **`--auto`** | Padrão inteligente | Triagem automática por palavras-chave | 100% Vibe Coding sem intervenção do usuário. |

---

## 📜 Formato da Sentença Judicial

```markdown
# 🏛️ STA: SENTENÇA JUDICIAL
> **Jurisdição:** 1ª Vara de Crimes e Arquitetura de Código
> **Corte:** agy | **Nível de Esforço:** auto -> high | **Duração:** 3.8s | **Regime:** 100% Read-Only

---

## ⚖️ AUTOS DO JULGAMENTO (SENTENÇA DO MAGISTRADO)

# 🟢 [APROVADO PELO STA]
GRAU DE CERTEZA DA CORTE: [ ████████░░ ] 85%

> **A Sentença em Uma Frase:**
> *"A migração para locks transacionais resolve as duplicidades de agendamento, mas exige timeout estrito de 2s para evitar travamento da tabela em horários de pico."*

### DETERMINAÇÕES FINAIS DO JUIZ:
1. Aplique a cláusula 'NOWAIT' ou 'TIMEOUT 2000' na query de seleção.
2. Mantenha o webhook idempotente gravando o hash no Redis.
```
