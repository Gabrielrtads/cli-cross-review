[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('agy', 'claude', 'codex')]
    [string]$Engine,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Prompt,

    [ValidateSet('auto', 'low', 'medium', 'high')]
    [string]$Effort = 'auto',

    [string]$BuilderModel,

    [string]$RedTeamModel,

    [string]$RefereeModel,

    [string]$WorkingDirectory = (Get-Location).Path,

    [ValidateRange(1, 86400)]
    [int]$TimeoutSeconds = 900,

    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Extrair esforco se passado inline no prompt (ex: "revisar rota --low" ou "--high analisar banco" ou "--auto")
if ($Prompt -match '(?i)(?:^|\s)--(auto|low|medium|high)(?:\s|$)') {
    $Effort = $Matches[1].ToLower()
    $Prompt = ($Prompt -replace '(?i)(?:^|\s)--(auto|low|medium|high)(?:\s|$)', ' ').Trim()
}

$effectiveEffort = $Effort
$effortDisplay = $Effort

if ($Effort -eq 'auto') {
    # Triagem Heurística de Risco / Complexidade do Modo Auto
    $criticalPatterns = '(?i)\b(supabase|postgres|banco|migration|migracao|drop|delete|transacao|transaction|atomic|estorno|split|asaas|stripe|pix|pagamento|payment|billing|auth|token|seguranca|security|vulnerabilidade|leak|secret|rls|permissao)\b'
    $lowPatterns = '(?i)\b(css|tailwind|style|estilo|cor|color|padding|margin|spacing|layout|responsiv|typo|tipografia|texto|copy|readme|docs|comentario|icon|icone|badge|formatar|formatacao|lint)\b'

    if ($Prompt -match $criticalPatterns) {
        $effectiveEffort = 'high'
        $effortDisplay = "auto -> high (risco crítico detectado em banco/pagamento/segurança)"
    } elseif ($Prompt -match $lowPatterns) {
        $effectiveEffort = 'low'
        $effortDisplay = "auto -> low (tema cosmético/estilização/documentação)"
    } else {
        $effectiveEffort = 'medium'
        $effortDisplay = "auto -> medium (padrão de engenharia e regras de negócio)"
    }
}

# Matriz Canônica de Modelos e Esforço por CLI (low, medium, high)
$modelMatrix = @{
    'agy' = @{
        'low' = @{
            'builder' = 'gemini-3.8-flash-low';
            'redteam' = 'gemini-3.8-flash-low';
            'referee' = 'gemini-3.8-flash-low';
            'taskEffort' = 'low'
        };
        'medium' = @{
            'builder' = 'gemini-3.8-flash-high';
            'redteam' = 'gemini-3.8-flash-high';
            'referee' = 'gemini-3.8-flash-medium';
            'taskEffort' = 'medium'
        };
        'high' = @{
            'builder' = 'gemini-4-argon-high';
            'redteam' = 'claude-opus-5-5-high';
            'referee' = 'gemini-3.8-flash-high';
            'taskEffort' = 'high'
        }
    };
    'codex' = @{
        'low' = @{
            'builder' = 'gpt-6-luna';
            'redteam' = 'gpt-6-luna';
            'referee' = 'gpt-6-luna';
            'taskEffort' = 'low'
        };
        'medium' = @{
            'builder' = 'gpt-6.1-sol';
            'redteam' = 'gpt-6.1-sol';
            'referee' = 'gpt-6-luna';
            'taskEffort' = 'medium'
        };
        'high' = @{
            'builder' = 'gpt-6.1-sol';
            'redteam' = 'gpt-6-astra';
            'referee' = 'gpt-6-luna';
            'taskEffort' = 'high'
        }
    };
    'claude' = @{
        'low' = @{
            'builder' = 'haiku-4.5';
            'redteam' = 'haiku-4.5';
            'referee' = 'haiku-4.5';
            'taskEffort' = 'low'
        };
        'medium' = @{
            'builder' = 'sonnet-5';
            'redteam' = 'sonnet-5';
            'referee' = 'haiku-4.5';
            'taskEffort' = 'medium'
        };
        'high' = @{
            'builder' = 'sonnet-5';
            'redteam' = 'opus-5';
            'referee' = 'haiku-4.5';
            'taskEffort' = 'high'
        }
    }
}

$selectedConfig = $modelMatrix[$Engine][$effectiveEffort]
$modelBuilder = if ($BuilderModel) { $BuilderModel } else { $selectedConfig['builder'] }
$modelRedTeam = if ($RedTeamModel) { $RedTeamModel } else { $selectedConfig['redteam'] }
$modelReferee = if ($RefereeModel) { $RefereeModel } else { $selectedConfig['referee'] }
$taskEffort = $selectedConfig['taskEffort']

# Sanitizar prompt para linha segura (evita quebra de argumentos em wrappers .cmd no Windows)
$sanitizedPrompt = ($Prompt -replace "[\r\n]+", " ").Trim()

# Montar Prompts Especializados alinhados ao Ultra Think
$promptBuilder = "[PAPEL: BUILDER / ULTRA THINK FASE 1 & 2] Tema: $sanitizedPrompt. 1. Mapeie todas as premissas ocultas e avalie sua validade. 2. Formule O TRIO DE SOLUCOES (Minimalista, Convencional, Robusta/Escalavel) com prós, contras e impacto tecnico."

$promptRedTeam = "[PAPEL: RED TEAM / ADVERSARIAL STRESS-TESTER / ULTRA THINK FASE 3] Tema: $sanitizedPrompt. Ataque as premissas e abordagens: identifique falhas catastroficas, race conditions, custos ocultos, limites de cota, locks e o maior ponto de quebra de cada abordagem."

$promptReferee = "[PAPEL: REFEREE & AUDITOR DE REGRAS / ULTRA THINK FASE 4] Tema: $sanitizedPrompt. Pondere trade-offs, avalie conformidade com AGENTS.md e regras do projeto, emita a recomendacao vencedora e atribua um CONFIDENCE SCORE (0-100%). Se < 85%, declare FALHA CRITICA."

# Montar o Manifesto Concorrente (100% Modo Plan / Read-Only para máxima segurança e velocidade)
$manifest = @(
    @{
        "id" = "${Engine}_builder";
        "engine" = $Engine;
        "mode" = "plan";
        "model" = $modelBuilder;
        "effort" = $taskEffort;
        "prompt" = $promptBuilder
    },
    @{
        "id" = "${Engine}_redteam";
        "engine" = $Engine;
        "mode" = "plan";
        "model" = $modelRedTeam;
        "effort" = $taskEffort;
        "prompt" = $promptRedTeam
    },
    @{
        "id" = "${Engine}_referee";
        "engine" = $Engine;
        "mode" = "plan";
        "model" = $modelReferee;
        "effort" = $taskEffort;
        "prompt" = $promptReferee
    }
)

$manifestJsonString = $manifest | ConvertTo-Json -Depth 5 -Compress

# Localizar o executor paralelo oficial (local na skill ou compartilhado no swarmv2)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$swarmv2Script = Join-Path $scriptDir "invoke-parallel-runner.ps1"
if (-not (Test-Path -LiteralPath $swarmv2Script)) {
    $swarmv2Script = Join-Path $scriptDir "..\..\swarmv2\scripts\invoke-swarmv2-parallel.ps1"
}
if (-not (Test-Path -LiteralPath $swarmv2Script)) {
    # Fallback procurando a partir da raiz do workspace
    $swarmv2Script = Resolve-Path (Join-Path (Get-Location).Path ".agents\skills\swarmv2\scripts\invoke-swarmv2-parallel.ps1") -ErrorAction Stop
}

# Invocar execucao paralela
$pwshCmd = Get-Command pwsh -CommandType Application -ErrorAction SilentlyContinue
$shellExe = if ($pwshCmd) { 'pwsh' } else { 'powershell' }

$rawResult = & $shellExe -NoProfile -NonInteractive -File $swarmv2Script `
    -ManifestJson $manifestJsonString `
    -WorkingDirectory $WorkingDirectory `
    -TimeoutSeconds $TimeoutSeconds `
    -Json

$parsedResult = $null
try {
    $parsedResult = $rawResult | ConvertFrom-Json
} catch {
    # falha de conversao json
}

if ($LASTEXITCODE -ne 0 -or ($parsedResult -and $parsedResult.summary.failed -gt 0)) {
    if ($parsedResult -and $parsedResult.tasks) {
        $failedTasks = $parsedResult.tasks | Where-Object { $_.status -ne 'success' }
        $errorMsg = foreach ($ft in $failedTasks) {
            $errDetail = if ($ft.error_output) { $ft.error_output.Trim() } elseif ($ft.output.error) { $ft.output.error } else { "Erro desconhecido" }
            "Tarefa '$($ft.id)' falhou: $errDetail"
        }
        throw "Falha ao executar tarefas na revisao cruzada:`n$($errorMsg -join "`n")"
    } else {
        throw "Falha ao executar a revisao cruzada via invoke-swarmv2-parallel.ps1 (exit code: $LASTEXITCODE). Saida: $rawResult"
    }
}

if ($Json) {
    $parsedResult | ConvertTo-Json -Depth 10
    exit 0
}

# Formatacao de Saida em Markdown Estruturado (Ultra Think Output)
function Get-TaskResponseText($taskOutput) {
    if ($null -eq $taskOutput) { return "Sem resposta" }
    if ($taskOutput -is [string]) { return $taskOutput }
    if ($taskOutput.PSObject) {
        $props = $taskOutput.PSObject.Properties
        if ($props['response'] -and $props['response'].Value) { return [string]$props['response'].Value }
        if ($props['content'] -and $props['content'].Value) { return [string]$props['content'].Value }
        if ($props['text'] -and $props['text'].Value) { return [string]$props['text'].Value }
        if ($props['message'] -and $props['message'].Value) { return [string]$props['message'].Value }
    }
    return ($taskOutput | ConvertTo-Json -Depth 5)
}

$builderTask = $parsedResult.tasks | Where-Object { $_.id -like "*_builder" } | Select-Object -First 1
$redTeamTask = $parsedResult.tasks | Where-Object { $_.id -like "*_redteam" } | Select-Object -First 1
$refereeTask = $parsedResult.tasks | Where-Object { $_.id -like "*_referee" } | Select-Object -First 1

$builderOutput = Get-TaskResponseText $builderTask.output
$redTeamOutput = Get-TaskResponseText $redTeamTask.output
$refereeOutput = Get-TaskResponseText $refereeTask.output

Write-Output "# 🏛️ Laudo de Revisão Cruzada Multi-Modelo ($Engine)"
Write-Output ""
Write-Output "> **Motor Unificado:** $Engine | **Nível de Esforço:** $effortDisplay | **Tempo de Execução:** $($parsedResult.summary.duration_seconds)s | **Status:** $($parsedResult.summary.success)/$($parsedResult.summary.total_tasks) Concluídos"
Write-Output "> **Tríade de Modelos:** Propositor ($modelBuilder) · Red Team ($modelRedTeam) · Árbitro ($modelReferee)"
Write-Output ""
Write-Output "---"
Write-Output "## 1. 💡 Proposta & O Trio de Soluções (Modelo: $modelBuilder)"
Write-Output ""
Write-Output $builderOutput
Write-Output ""
Write-Output "---"
Write-Output "## 2. ⚔️ Ataque Adversarial & Stress-Test (Modelo: $modelRedTeam)"
Write-Output ""
Write-Output $redTeamOutput
Write-Output ""
Write-Output "---"
Write-Output "## 3. ⚖️ Ponderação de Regras, Consenso & Veredito (Modelo: $modelReferee)"
Write-Output ""
Write-Output $refereeOutput
Write-Output ""
Write-Output "---"
Write-Output "*Laudo gerado via skill cli-revisao-cruzada com execução simultânea isolada.*"
