# 🏛️ STA: Supremo Tribunal dos Agentes (`/sta`)
> **A Corte Suprema de Inteligência Artificial no seu Terminal.**  
> *(Supreme Tribunal of Agents)*  
> Elimine a bajulação das IAs. Submeta qualquer código, ideia de negócio, precificação ou roteiro a 3 modelos concorrentes em julgamento dialético real em 2 rodadas.

[![skills.sh compatible](https://img.shields.io/badge/skills.sh-sta-6366f1?style=for-the-badge)](https://skills.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Zero Mutation](https://img.shields.io/badge/Modo-100%25_Read--Only-emerald?style=for-the-badge)](#)
[![Vibe Coding Ready](https://img.shields.io/badge/Vibe_Coding-Zero_Config-ff0055?style=for-the-badge)](#)
[![CI & Test Suite](https://github.com/Gabrielrtads/sta/actions/workflows/ci.yml/badge.svg)](https://github.com/Gabrielrtads/sta/actions)
[![GitHub stars](https://img.shields.io/github/stars/Gabrielrtads/sta?style=social)](https://github.com/Gabrielrtads/sta/stargazers)

---

## 🛑 O Problema: Toda IA é Puxa-Saco (Sycophancy)

Quando você pergunta para o ChatGPT, Claude ou Gemini:  
*"O que achou dessa minha ideia?"* ou *"Revise esse meu código"*, a resposta padrão é quase sempre:  
> *"Excelente ideia! Muito bem estruturado, parabéns!"*

**Elas mentem para agradar você.** Um modelo sozinho tem pontos cegos cognitivos e é treinado para ser complacente. No dia seguinte, seu código quebra em produção ou sua campanha zera em vendas.

---

## 🏛️ A Solução: Uma Corte Implacável em 2 Rodadas

O **STA (Supremo Tribunal dos Agentes)** não faz elogios vazios. Ele pega o seu caso e instancia **3 modelos em 2 rodadas reais com barreira de sincronização**:

```mermaid
flowchart TD
    CASO["📜 O CASO SUBMETIDO AO STA<br/>(/sta <caso | codigo | decisao>)"] --> RECONHECIMENTO["🧭 Detector Automático de Jurisdição"]

    RECONHECIMENTO --> R_CODIGO["💻 Vara de Código & Arquitetura"]
    RECONHECIMENTO --> R_BUSINESS["💼 Vara de Negócios & SaaS"]
    RECONHECIMENTO --> R_CREATIVE["🎨 Vara de Conteúdo & Retenção"]
    RECONHECIMENTO --> R_GENERAL["⚖️ Plenário Estratégico"]

    R_CODIGO --> STA
    R_BUSINESS --> STA
    R_CREATIVE --> STA
    R_GENERAL --> STA

    subgraph STA ["🏛️ A SESSÃO DO STA (3 PODERES EM 2 RODADAS)"]
        subgraph RODADA_1 ["Rodada 1: Duelo Concorrente (Paralelo)"]
            DEFESA["🛡️ 1. O Advogado de Defesa (Builder)<br/>Apresenta a tese e formula o Trio de Soluções"]
            ACUSACAO["🔥 2. O Promotor de Justiça (Red Team)<br/>Ataca impiedosamente caçando falhas e pontos cegos"]
        end

        RODADA_1 --> BARREIRA{"Barreira de Sincronização<br/>(Fail-Fast & Entrega dos Autos)"}

        subgraph RODADA_2 ["Rodada 2: O Julgamento Informado"]
            BARREIRA --> JUIZ["👑 3. O Magistrado da Corte (Referee)<br/>Confronta a Defesa com a Acusação e emite a Sentença"]
        end
    end

    JUIZ --> ACORDAO["🏆 SENTENÇA JUDICIAL:<br/>• Veredito Claro com Barra de Certeza [ ████████░░ ] 85%<br/>• A Sentença em Uma Frase de Impacto<br/>• Determinações Finais (Plano de Ação / Patch Git)"]
```

---

## 🌐 3 Modos de Julgamento: Da Mesma Empresa ou Cross-Big Techs

O **STA** é a primeira corte agêntica agnóstica de fornecedor. Você escolhe se o julgamento corre dentro de um único ecossistema ou se coloca as Big Techs para duelarem entre si:

### 1. Julgamento Cross-Big Techs (Duelo Multi-Empresas) ⚔️
Elimine o viés de família! Modelos da mesma empresa compartilham os mesmos dados de treino e pontos cegos. No modo cross, IAs concorrentes se fiscalizam:
- 🛡️ **Defesa:** Anthropic (Claude Sonnet / Opus)
- 🔥 **Acusação (Red Team):** OpenAI (GPT-6 Sol / Astra)
- 👑 **Magistrado (Juiz):** Google (Gemini Argon / Pro)

### 2. Julgamento Intra-Empresa (Econômico e Homogêneo) 🏢
Se você ou sua empresa possuem créditos de apenas um provedor, o STA convoca a corte escalando pesos diferentes da mesma casa:
- **Só Google:** Defesa (Flash-High) vs Acusação (Argon-High) ➔ Juiz (Flash)
- **Só Anthropic:** Defesa (Sonnet-5) vs Acusação (Opus-5) ➔ Juiz (Haiku)
- **Só OpenAI:** Defesa (GPT-6.1 Sol) vs Acusação (GPT-6 Astra) ➔ Juiz (Luna)

### 3. Em Equipes e CI/CD Corporativo 🤝
O STA pode ser instalado como portão de qualidade (`quality gate`) em times de desenvolvimento:
- **No Terminal dos Devs:** O Dev A (no Cursor) e o Dev B (no Claude Code) usam `/sta` com as mesmas réguas de auditoria.
- **No GitHub Actions (CI/CD):** Bloqueia automaticamente o merge de Pull Requests se o Magistrado emitir `[DECISÃO MONOCRÁTICA]`.

---

## 🎚️ Escala de Gravidade dos Laudos (Tiers de Severidade)

O **STA** prioriza a **utilidade técnica imediata**. A análise é limpa, cirúrgica e sem rodeios para não atrapalhar seu fluxo de desenvolvimento:

| Nível | Status Técnico | Carimbo Oficial | Entrega do Laudo |
|:---:|---|---|---|
| 🟢 | **Sólido & Seguro** | `🟢 [APROVADO PELO STA]` | Validação de estabilidade e boas práticas recomendadas. |
| 🟡 | **Débito Técnico Leve** | `🟡 [HABEAS CORPUS CONCEDIDO]` | Liberação provisória com lista pontual de melhorias antes do merge. |
| 🟠 | **Risco de Concorrência/Deadlock** | `🟠 [PEDIDO DE VISTA / RETENÇÃO]` | Plano de ação em 3 etapas para blindar transações e filas. |
| 🔴 | **Crítico / Sem Lastro** | `🔴 [DECISÃO MONOCRÁTICA]` | Bloqueio imediato + **Patch Git** pronto para aplicar. |

---

## 🚀 Instalação em 1 Clique (Zero Dependências)

Instale direto no seu agente via [skills.sh](https://skills.sh):

```bash
npx skills add Gabrielrtads/sta
```

Compatível nativamente com:
- **Google Antigravity** (`agy`)
- **Claude Code** (`claude`)
- **OpenAI Codex** (`codex`)
- **Cursor / Windsurf / Terminal Linux e Windows**

---

## 💬 Como Usar (100% Vibe Coding)

Sem menus de configuração nem flags obrigatórias. Basta invocar no chat do seu agente usando `/sta`:

### 1. Julgar um Código ou Arquitetura
```text
/sta "Criei este webhook de pagamento com retry no Redis. O que vai quebrar?"
/sta --diff                       # Julga as alterações recentes do git diff
/sta --file src/auth.ts           # Julga um arquivo cirúrgico
```

### 2. Julgar uma Ideia de Negócio / SaaS
```text
/sta "Devo cobrar R$ 97/mês no modelo ilimitado ou cobrar por uso no Barber.fi?"
```

### 3. Julgar um Gancho de Conteúdo / Vídeo
```text
/sta "Esse título de vídeo no YouTube tá apelativo ou tá genérico?"
```

### 4. Modo "Corte Marcial" (Auditoria Implacável / Hardcore)
Para quando você precisa que o modelo use 100% da sua força bruta de raciocínio (Opus, Astra, Argon):
```text
/sta --fogo "Revise a migração do banco de dados de produção antes do deploy"
# Sinônimos aceitos: --fogo, --hard, --corte-marcial
```

### 5. Modo "Plenário / TV Justiça" (Modo Zoeira Opcional)
Para ver a ata completa com a bancada dos ministros, sustentação oral e debates inflamados:
```text
/sta --zoeira "Webhook de cobrança sem idempotência rodando em loop"
# Sinônimos aceitos: --zoeira, --brasil, --meme, --plenario
```
*(Entrega o debate descontraído da corte sem perder a seriedade técnica: o Patch Git corrigido vem anexado no final).*

### 6. Modo "Cross-Empresas" (Duelo Google vs Anthropic vs OpenAI)
Para convocar um tribunal misto confrontando modelos concorrentes:
```text
/sta --cross-cli "Auditoria crítica de arquitetura antes de ir para produção"
```

---

## 🛡️ Segurança Absoluta (Zero Write Mutation)

- **100% Read-Only:** O STA roda estritamente em modo `plan`. Ele **não altera nenhum arquivo** do seu projeto sem a sua autorização expressa.
- **Isolamento Concorrente:** Os agentes rodam em paralelo no seu processador, sem conflito de escrita.
- **Fail-Fast:** Se a Defesa ou a Acusação falharem na Rodada 1, a sessão é abortada imediatamente, economizando 100% dos tokens do Magistrado.

---

## 📄 Licença

MIT © [Gabriel Toledo](https://github.com/Gabrielrtads)
