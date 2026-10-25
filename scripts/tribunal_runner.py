"""
tribunal_runner.py - Módulo Python Oficial do Tribunal de IA
Implementado via Google Antigravity SDK (google-antigravity) com Subagentes e Structured Output.
"""

from __future__ import annotations
import asyncio
import json
import sys
from enum import Enum
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field

try:
    from google.antigravity import Agent, LocalAgentConfig, types
except ImportError:
    Agent = None
    LocalAgentConfig = None
    types = None


class DomainCategory(str, Enum):
    """Categoria da Vara Judicial do Tribunal."""
    CODIGO_ENGENHARIA = "codigo_engenharia"
    NEGOCIO_PRODUTO = "negocio_produto"
    CRIATIVO_CONTEUDO = "criativo_conteudo"
    DECISAO_GERAL = "decisao_geral"


class ReviewStatus(str, Enum):
    """Veredito da Corte."""
    APROVADO = "APROVADO"
    APROVADO_COM_RESSALVAS = "APROVADO_COM_RESSALVAS"
    CONDENADO_REPROVADO = "CONDENADO_REPROVADO"
    RETENCAO_CAUTELAR = "RETENCAO_CAUTELAR"


# ─────────────────────────────────────────────────────────────────────────────
# ESQUEMAS ESPECIALIZADOS POR MATÉRIA (ESTRUTURAÇÃO RICA)
# ─────────────────────────────────────────────────────────────────────────────

class CodeArtifacts(BaseModel):
    affected_files: List[str] = Field(default_factory=list, description="Arquivos afetados no repositório")
    root_cause: Optional[str] = Field(None, description="Causa raiz técnica da falha")
    git_patch_diff: Optional[str] = Field(None, description="Patch Git unificado pronto para aplicar")
    failing_regression_test: Optional[str] = Field(None, description="Código do teste automatizado de validação")


class BusinessArtifacts(BaseModel):
    thesis: Optional[str] = Field(None, description="Tese central de valor ou pricing")
    cash_risks: List[str] = Field(default_factory=list, description="Riscos de caixa, churn e custo de infra")
    metrics_kpis: List[str] = Field(default_factory=list, description="Métricas de sucesso esperadas")
    action_plan_steps: List[str] = Field(default_factory=list, description="Plano de ação em etapas práticas")


class CreativeArtifacts(BaseModel):
    hook_3s: Optional[str] = Field(None, description="Gancho verbal ou visual dos primeiros 3 segundos")
    retention_mechanics: Optional[str] = Field(None, description="Mecânica de retenção neurológica")
    rewritten_copies: List[str] = Field(default_factory=list, description="Opções de cópia/roteiro reescritas")
    call_to_action: Optional[str] = Field(None, description="Chamada de ação de alta conversão")


class SolutionOption(BaseModel):
    tier: str = Field(..., description="Minimalista, Convencional ou Robusta")
    summary: str = Field(..., description="Resumo da abordagem proposta pela Defesa")
    pros_cons: str = Field(..., description="Prós e contras imediatos")


class AdversarialPoint(BaseModel):
    target: str = Field(..., description="Ponto fraco atacado pela Acusação")
    vulnerability: str = Field(..., description="Falha fatal, ponto cego ou risco oculto")
    worst_case_scenario: str = Field(..., description="O pior cenário se der errado")


class UniversalTribunalVerdict(BaseModel):
    """Acórdão Judicial Definitivo emitido pelo Tribunal de IA."""
    case_summary: str = Field(..., description="Resumo do caso submetido")
    domain: DomainCategory = Field(..., description="Vara judicial atribuída automaticamente")
    verdict_status: ReviewStatus = Field(..., description="Veredito final do Magistrado")
    confidence_score: int = Field(..., ge=0, le=100, description="Nível de certeza da corte (0 a 100%)")
    one_line_sentence: str = Field(..., description="A sentença definitiva resumida em uma única frase")
    
    hidden_assumptions_exposed: List[str] = Field(default_factory=list, description="Premissas falsas ou ocultas desconstruídas")
    defense_options: List[SolutionOption] = Field(default_factory=list, description="Trio de soluções da Defesa")
    prosecution_attacks: List[AdversarialPoint] = Field(default_factory=list, description="Ataques da Acusação")
    
    # Verticais específicas ativadas sob demanda
    code_details: Optional[CodeArtifacts] = None
    business_details: Optional[BusinessArtifacts] = None
    creative_details: Optional[CreativeArtifacts] = None
    
    final_judge_determinations: List[str] = Field(default_factory=list, description="Determinações finais e plano de ação imediato")


# ─────────────────────────────────────────────────────────────────────────────
# RUNNER NATIVO ANTIGRAVITY SDK
# ─────────────────────────────────────────────────────────────────────────────

def create_tribunal_agent_config(domain_hint: str = "geral") -> LocalAgentConfig:
    if not LocalAgentConfig:
        raise RuntimeError("google-antigravity SDK não está disponível neste ambiente.")

    builder_subagent = types.SubagentConfig(
        name="defesa_builder",
        description="O Advogado de Defesa da corte. Apresenta o melhor caso a favor da tese/código e formula o Trio de Soluções.",
        capabilities=types.SubagentCapabilities(
            agent_behavior=types.AgentBehavior.AUTONOMOUS,
            enabled_tools=[types.BuiltinTools.VIEW_FILE, types.BuiltinTools.SEARCH_DIR],
            allowed_subagents=[],
        ),
    )

    redteam_subagent = types.SubagentConfig(
        name="acusacao_redteam",
        description="O Promotor de Justiça da corte. Ataca implacavelmente a tese, apontando riscos catastróficos, falhas e edge cases.",
        capabilities=types.SubagentCapabilities(
            agent_behavior=types.AgentBehavior.AUTONOMOUS,
            enabled_tools=[types.BuiltinTools.VIEW_FILE, types.BuiltinTools.SEARCH_DIR],
            allowed_subagents=[],
        ),
    )

    system_prompt = (
        "Você é o Magistrado Supremo do Tribunal de IA.\n"
        "Sua missão é julgar a demanda com total isenção e rigor técnico em 2 etapas:\n"
        "1. Convoque 'defesa_builder' para apresentar a sustentação oral e as 3 opções de solução.\n"
        "2. Convoque 'acusacao_redteam' para desferir a acusação adversarial contra as propostas.\n"
        "3. Arbitre o embate, determine quem tem razão e emita o acórdão no formato UniversalTribunalVerdict.\n"
        "Se a confiança for < 85%, aplique RETENCAO_CAUTELAR ou CONDENADO_REPROVADO."
    )

    return LocalAgentConfig(
        system_instructions=system_prompt,
        subagents=[builder_subagent, redteam_subagent],
        capabilities=types.CapabilitiesConfig(
            enable_subagents=True,
            max_subagent_depth=2,
            allowed_subagents=["defesa_builder", "acusacao_redteam"],
            agent_behavior=types.AgentBehavior.AUTONOMOUS,
        ),
        response_schema=UniversalTribunalVerdict,
    )


async def adjudicar_caso(caso_texto: str) -> UniversalTribunalVerdict:
    config = create_tribunal_agent_config()
    async with Agent(config) as agent:
        prompt = f"Abra a sessão do Tribunal para julgar o seguinte caso:\n\n\"{caso_texto}\""
        response = await agent.chat(prompt)
        structured = await response.structured_output()
        if structured:
            return UniversalTribunalVerdict.model_validate(structured)
        raw_text = await response.text()
        return UniversalTribunalVerdict.model_validate_json(raw_text)


if __name__ == "__main__":
    caso = "Devo migrar o banco de dados do Barber.fi de PostgreSQL para SQLite local no servidor?"
    print(f"Submetendo caso ao Tribunal de IA: {caso}")
    if Agent:
        veredicto = asyncio.run(adjudicar_caso(caso))
        print(json.dumps(veredicto.model_dump(), indent=2, ensure_ascii=False))
    else:
        print("SDK Antigravity em modo declarativo (classes e schemas prontos para importação).")
