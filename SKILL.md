---
name: tribunal
description: O Tribunal da IA. Corte suprema de julgamento e decisão adversarial multi-modelo (2 rodadas: Defesa vs Acusação -> Magistrado). Julga código, arquitetura, estratégias de negócios, precificação, copywriting e decisões críticas sem complacência.
category: devops
tags: [tribunal, cross-review, ultra-think, adversarial, multi-model, multi-cli, decision-making]
---

# 🏛️ Tribunal da IA (`/tribunal`)
> **A Primeira Corte Suprema de Inteligência Artificial no seu Terminal.**  
> Elimine o vício das IAs que dizem "sim" para tudo. Submeta qualquer código, ideia de negócio, roteiro ou decisão crítica a 3 modelos concorrentes em julgamento dialético real em 2 rodadas.

---

## ⚡ Como Invocar (100% Vibe Coding)

Sem menus chatos nem flags obrigatórias. O Tribunal detecta o ambiente e a matéria automaticamente:

```text
/tribunal <caso, pergunta, código ou decisão>
```

### Exemplos do Dia a Dia:

1. **Julgamento de Código ou Arquitetura:**
   ```text
   /tribunal "Criei este webhook de pagamento com retry no Redis. O que vai quebrar sob pico?"
   /tribunal --diff                       # Julga automaticamente as alterações do git diff
   /tribunal --staged                     # Julga o que está staged para commit
   /tribunal --file src/auth.ts           # Julga um arquivo específico
   ```

2. **Julgamento de Negócio, Pricing & SaaS:**
   ```text
   /tribunal "Devo cobrar R$ 97 fixo ou 3% por agendamento no Barber.fi?"
   ```

3. **Julgamento Criativo, Roteiro & Vídeo:**
   ```text
   /tribunal "Esse gancho dos 3 segundos para Reels tem retenção ou vai flopar?"
   ```

4. **Modo "Corte Marcial" (Auditoria Implacável):**
   ```text
   /tribunal --fogo "Revise a migração do banco de dados de produção antes do deploy"
   ```
   *(Sinônimos: `--fogo`, `--hard`, `--corte-marcial`). Convocação dos modelos de fronteira máxima (Opus, Astra, Gemini Argon).*

5. **Override Manual de CLI (Opcional):**
   ```text
   /tribunal agy "Meu plano de contingência para a VPS"
   /tribunal claude "Refatoração do motor de busca FTS5"
   /tribunal codex "Otimização de queries SQL"
   ```

---

## 🏛️ A Dinâmica da Corte: 3 Poderes em 2 Rodadas

Diferente de ferramentas que apenas colam três respostas no vácuo, o Tribunal opera em **2 rodadas causais com barreira de sincronização**:

```
                       [O CASO SUBMETIDO AO TRIBUNAL]
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

O Tribunal identifica a matéria do caso automaticamente:
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
# 🏛️ TRIBUNAL DA IA: SENTENÇA JUDICIAL
> **Jurisdição:** 1ª Vara de Crimes e Arquitetura de Código
> **Corte:** agy | **Nível de Esforço:** auto -> high | **Duração:** 3.8s | **Regime:** 100% Read-Only

---

## ⚖️ AUTOS DO JULGAMENTO (SENTENÇA DO MAGISTRADO)

# 🟢 [APROVADO COM RESSALVAS]
GRAU DE CERTEZA DA CORTE: [ ████████░░ ] 85%

> **A Sentença em Uma Frase:**
> *"A migração para locks transacionais resolve as duplicidades de agendamento, mas exige timeout estrito de 2s para evitar travamento da tabela em horários de pico."*

### DETERMINAÇÕES FINAIS DO JUIZ:
1. Aplique a cláusula 'NOWAIT' ou 'TIMEOUT 2000' na query de seleção.
2. Mantenha o webhook idempotente gravando o hash no Redis.
```

---

## 🔄 Retrocompatibilidade
Invocadores legados continuam funcionando normalmente através de aliases:
- `/cli-cross-review` $\rightarrow$ redirecionado para `/tribunal`
- `/cli-revisao-cruzada` $\rightarrow$ redirecionado para `/tribunal`
