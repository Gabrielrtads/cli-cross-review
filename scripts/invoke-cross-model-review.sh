#!/usr/bin/env bash
# ==============================================================================
# CLI Revisão Cruzada - Orquestrador Multi-Modelo (Linux / VPS Hetzner)
# Executa debate adversarial entre 3 modelos da mesma CLI (agy, codex, claude)
# ==============================================================================

set -euo pipefail

ENGINE=""
PROMPT=""
EFFORT="medium"
BUILDER_MODEL=""
REDTEAM_MODEL=""
REFEREE_MODEL=""
TIMEOUT_SECS=900
OUTPUT_JSON=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--engine)
      ENGINE="$2"
      shift 2
      ;;
    -p|--prompt)
      PROMPT="$2"
      shift 2
      ;;
    --effort)
      EFFORT="$2"
      shift 2
      ;;
    --low)
      EFFORT="low"
      shift
      ;;
    --medium)
      EFFORT="medium"
      shift
      ;;
    --high)
      EFFORT="high"
      shift
      ;;
    --builder-model)
      BUILDER_MODEL="$2"
      shift 2
      ;;
    --redteam-model)
      REDTEAM_MODEL="$2"
      shift 2
      ;;
    --referee-model)
      REFEREE_MODEL="$2"
      shift 2
      ;;
    -t|--timeout)
      TIMEOUT_SECS="$2"
      shift 2
      ;;
    --json)
      OUTPUT_JSON=1
      shift
      ;;
    *)
      if [[ -z "$ENGINE" ]]; then
        ENGINE="$1"
      elif [[ -z "$PROMPT" ]]; then
        PROMPT="$1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$ENGINE" ]]; then
  echo "Erro: CLI obrigatoria. Especifique a CLI: agy, codex ou claude. Uso: $0 -e <agy|claude|codex> -p '<tema>' [--effort low|medium|high] [--json]" >&2
  exit 1
fi

if [[ -z "$PROMPT" ]]; then
  echo "Erro: Prompt/tema obrigatorio. Uso: $0 -e <agy|claude|codex> -p '<tema>' [--effort auto|low|medium|high] [--json]" >&2
  exit 1
fi

# Detectar esforço inline no prompt (ex: "revisar rota --low" ou "--auto")
if [[ "$PROMPT" =~ (^|[[:space:]])--(auto|low|medium|high)($|[[:space:]]) ]]; then
  EFFORT="${BASH_REMATCH[2]}"
  PROMPT=$(echo "$PROMPT" | sed -E 's/(^|[[:space:]])--(auto|low|medium|high)($|[[:space:]])/ /g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
fi

# Modo Auto: Triagem heuristica por palavras-chave
if [[ "$EFFORT" == "auto" ]]; then
  if echo "$PROMPT" | grep -iqE '(supabase|postgres|banco|migration|migracao|drop|delete|transacao|transaction|atomic|estorno|split|asaas|stripe|pix|pagamento|payment|billing|auth|token|seguranca|security|vulnerabilidade|leak|secret|rls|permissao)'; then
    EFFORT="high"
  elif echo "$PROMPT" | grep -iqE '(css|tailwind|style|estilo|cor|color|padding|margin|spacing|layout|responsiv|typo|tipografia|texto|copy|readme|docs|comentario|icon|icone|badge|formatar|formatacao|lint)'; then
    EFFORT="low"
  else
    EFFORT="medium"
  fi
fi

TASK_EFFORT="$EFFORT"

case "$ENGINE" in
  agy)
    case "$EFFORT" in
      low)
        [[ -z "$BUILDER_MODEL" ]] && BUILDER_MODEL="gemini-3.8-flash-low"
        [[ -z "$REDTEAM_MODEL" ]] && REDTEAM_MODEL="gemini-3.8-flash-low"
        [[ -z "$REFEREE_MODEL" ]] && REFEREE_MODEL="gemini-3.8-flash-low"
        ;;
      high)
        [[ -z "$BUILDER_MODEL" ]] && BUILDER_MODEL="gemini-4-argon-high"
        [[ -z "$REDTEAM_MODEL" ]] && REDTEAM_MODEL="claude-opus-5-5-high"
        [[ -z "$REFEREE_MODEL" ]] && REFEREE_MODEL="gemini-3.8-flash-high"
        ;;
      *)
        [[ -z "$BUILDER_MODEL" ]] && BUILDER_MODEL="gemini-3.8-flash-high"
        [[ -z "$REDTEAM_MODEL" ]] && REDTEAM_MODEL="gemini-3.8-flash-high"
        [[ -z "$REFEREE_MODEL" ]] && REFEREE_MODEL="gemini-3.8-flash-medium"
        ;;
    esac
    ;;
  codex)
    case "$EFFORT" in
      low)
        [[ -z "$BUILDER_MODEL" ]] && BUILDER_MODEL="gpt-6-luna"
        [[ -z "$REDTEAM_MODEL" ]] && REDTEAM_MODEL="gpt-6-luna"
        [[ -z "$REFEREE_MODEL" ]] && REFEREE_MODEL="gpt-6-luna"
        ;;
      high)
        [[ -z "$BUILDER_MODEL" ]] && BUILDER_MODEL="gpt-6.1-sol"
        [[ -z "$REDTEAM_MODEL" ]] && REDTEAM_MODEL="gpt-6-astra"
        [[ -z "$REFEREE_MODEL" ]] && REFEREE_MODEL="gpt-6-luna"
        ;;
      *)
        [[ -z "$BUILDER_MODEL" ]] && BUILDER_MODEL="gpt-6.1-sol"
        [[ -z "$REDTEAM_MODEL" ]] && REDTEAM_MODEL="gpt-6.1-sol"
        [[ -z "$REFEREE_MODEL" ]] && REFEREE_MODEL="gpt-6-luna"
        ;;
    esac
    ;;
  claude)
    case "$EFFORT" in
      low)
        [[ -z "$BUILDER_MODEL" ]] && BUILDER_MODEL="haiku-4.5"
        [[ -z "$REDTEAM_MODEL" ]] && REDTEAM_MODEL="haiku-4.5"
        [[ -z "$REFEREE_MODEL" ]] && REFEREE_MODEL="haiku-4.5"
        ;;
      high)
        [[ -z "$BUILDER_MODEL" ]] && BUILDER_MODEL="sonnet-5"
        [[ -z "$REDTEAM_MODEL" ]] && REDTEAM_MODEL="opus-5"
        [[ -z "$REFEREE_MODEL" ]] && REFEREE_MODEL="haiku-4.5"
        ;;
      *)
        [[ -z "$BUILDER_MODEL" ]] && BUILDER_MODEL="sonnet-5"
        [[ -z "$REDTEAM_MODEL" ]] && REDTEAM_MODEL="sonnet-5"
        [[ -z "$REFEREE_MODEL" ]] && REFEREE_MODEL="haiku-4.5"
        ;;
    esac
    ;;
  *)
    echo "Erro: Motor desconhecido '$ENGINE'. Suportados: agy, codex, claude." >&2
    exit 1
    ;;
esac

# Sanitizar prompt para linha única segura
CLEAN_PROMPT=$(echo "$PROMPT" | tr '\r\n' ' ' | sed 's/  */ /g')

PROMPT_BUILDER="[PAPEL: BUILDER / ULTRA THINK FASE 1 & 2] Tema: $CLEAN_PROMPT. 1. Mapeie todas as premissas ocultas e avalie sua validade. 2. Formule O TRIO DE SOLUCOES (Minimalista, Convencional, Robusta/Escalavel) com prós, contras e impacto tecnico."
PROMPT_REDTEAM="[PAPEL: RED TEAM / ADVERSARIAL STRESS-TESTER / ULTRA THINK FASE 3] Tema: $CLEAN_PROMPT. Ataque as premissas e abordagens: identifique falhas catastroficas, race conditions, custos ocultos, limites de cota, locks e o maior ponto de quebra de cada abordagem."
PROMPT_REFEREE="[PAPEL: REFEREE & AUDITOR DE REGRAS / ULTRA THINK FASE 4] Tema: $CLEAN_PROMPT. Pondere trade-offs, avalie conformidade com AGENTS.md e regras do projeto, emita a recomendacao vencedora e atribua um CONFIDENCE SCORE (0-100%). Se < 85%, declare FALHA CRITICA."

TMP_DIR=$(mktemp -d /tmp/cross_review_XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

MANIFEST_FILE="$TMP_DIR/manifest.json"

cat <<EOF > "$MANIFEST_FILE"
[
  {
    "id": "${ENGINE}_builder",
    "engine": "${ENGINE}",
    "mode": "plan",
    "model": "${BUILDER_MODEL}",
    "effort": "${TASK_EFFORT}",
    "prompt": $(echo "$PROMPT_BUILDER" | jq -R .)
  },
  {
    "id": "${ENGINE}_redteam",
    "engine": "${ENGINE}",
    "mode": "plan",
    "model": "${REDTEAM_MODEL}",
    "effort": "${TASK_EFFORT}",
    "prompt": $(echo "$PROMPT_REDTEAM" | jq -R .)
  },
  {
    "id": "${ENGINE}_referee",
    "engine": "${ENGINE}",
    "mode": "plan",
    "model": "${REFEREE_MODEL}",
    "effort": "${TASK_EFFORT}",
    "prompt": $(echo "$PROMPT_REFEREE" | jq -R .)
  }
]
EOF

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWARM_SH="$SCRIPT_DIR/invoke-parallel-runner.sh"
if [[ ! -f "$SWARM_SH" ]]; then
  SWARM_SH="$SCRIPT_DIR/../../swarmv2/scripts/invoke-swarmv2-parallel.sh"
fi

if [[ ! -f "$SWARM_SH" ]]; then
  echo "Erro: invoke-swarmv2-parallel.sh não encontrado em $SWARM_SH" >&2
  exit 1
fi

chmod +x "$SWARM_SH"

if [[ "$OUTPUT_JSON" -eq 1 ]]; then
  exec "$SWARM_SH" -m "$MANIFEST_FILE" -t "$TIMEOUT_SECS" --json
else
  exec "$SWARM_SH" -m "$MANIFEST_FILE" -t "$TIMEOUT_SECS"
fi
