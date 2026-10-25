[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Engine,

    [Parameter(Position = 1)]
    [string]$Prompt,

    [ValidateSet('auto', 'low', 'medium', 'high', 'extreme')]
    [string]$Effort = 'auto',

    [string]$BuilderModel,
    [string]$RedTeamModel,
    [string]$RefereeModel,

    [string]$WorkingDirectory = (Get-Location).Path,

    [ValidateRange(1, 86400)]
    [int]$TimeoutSeconds = 900,

    [switch]$Diff,
    [switch]$Staged,
    [string]$File,
    [switch]$CrossCli,
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ─────────────────────────────────────────────────────────────────────────────
# 1. RESOLUÇÃO ERGONÔMICA DE ARGUMENTOS & DETECÇÃO DE CLI (100% VIBE CODING)
# ─────────────────────────────────────────────────────────────────────────────

# Se o primeiro argumento não for uma das CLIs conhecidas, ele é o próprio Prompt!
if ($Engine -and ($Engine -notmatch '^(agy|claude|codex)$')) {
    if ($Prompt) {
        $Prompt = "$Engine $Prompt"
    } else {
        $Prompt = $Engine
    }
    $Engine = $null
}

# Se a CLI não foi declarada, detecta automaticamente o ambiente ativo
if (-not $Engine -or $Engine -eq 'auto') {
    if ($env:ANTIGRAVITY_AGENT -or (Get-Command agy -ErrorAction SilentlyContinue)) {
        $Engine = 'agy'
    } elseif ($env:CLAUDE_CODE -or (Get-Command claude -ErrorAction SilentlyContinue)) {
        $Engine = 'claude'
    } elseif (Get-Command codex -ErrorAction SilentlyContinue) {
        $Engine = 'codex'
    } else {
        $Engine = 'agy' # Default seguro
    }
}

if (-not $Prompt) {
    throw "Uso: /tribunal [agy|claude|codex] [--fogo|--low|--medium|--high] <caso, código ou dúvida>"
}

# Suporte a sinônimos de esforço inline: --fogo, --corte-marcial, --hard, --extreme, --low, --high, --medium
if ($Prompt -match '(?i)(?:^|\s)--(fogo|corte-marcial|hard|extreme)(?:\s|$)') {
    $Effort = 'high'
    $Prompt = ($Prompt -replace '(?i)(?:^|\s)--(fogo|corte-marcial|hard|extreme)(?:\s|$)', ' ').Trim()
} elseif ($Prompt -match '(?i)(?:^|\s)--(auto|low|medium|high)(?:\s|$)') {
    $Effort = $Matches[1].ToLower()
    $Prompt = ($Prompt -replace '(?i)(?:^|\s)--(auto|low|medium|high)(?:\s|$)', ' ').Trim()
}

# Ingestão de Contexto de Código Real se solicitado (--diff, --staged, --file)
$evidenceContext = ""
if ($Diff) {
    try {
        $gitDiff = & git diff 2>$null
        if ($gitDiff) {
            $evidenceContext += "`n`n=== PROVA MATERIAL: GIT DIFF (ALTERAÇÕES RECENTES) ===`n$gitDiff"
        }
    } catch {}
}
if ($Staged) {
    try {
        $gitStaged = & git diff --cached 2>$null
        if ($gitStaged) {
            $evidenceContext += "`n`n=== PROVA MATERIAL: GIT STAGED (STAGING AREA) ===`n$gitStaged"
        }
    } catch {}
}
if ($File -and (Test-Path -LiteralPath $File)) {
    try {
        $fileContent = Get-Content -LiteralPath $File -Raw -Encoding UTF8
        $evidenceContext += "`n`n=== PROVA MATERIAL: CONTEÚDO DE $File ===`n$fileContent"
    } catch {}
}

$fullCaseText = ($Prompt + $evidenceContext).Trim()

# ─────────────────────────────────────────────────────────────────────────────
# 2. AUTO-DETECÇÃO DE MATÉRIA DO CASO (VARA JUDICIAL)
# ─────────────────────────────────────────────────────────────────────────────

$materia = "GERAL"
$varaNome = "Plenário de Tomada de Decisão Estratégica"
$criticalPatterns = '(?i)\b(supabase|postgres|banco|migration|migracao|drop|delete|transacao|transaction|atomic|estorno|split|asaas|stripe|pix|pagamento|payment|billing|auth|token|seguranca|security|vulnerabilidade|leak|secret|rls|permissao)\b'
$lowPatterns = '(?i)\b(css|tailwind|style|estilo|cor|color|padding|margin|spacing|layout|responsiv|typo|tipografia|texto|readme|docs|comentario|icon|icone|badge|formatar|formatacao|lint)\b'
$codePatterns = '(?i)\b(git|diff|patch|branch|commit|function|funcao|classe|interface|typescript|python|react|hook|css|tailwind|api|endpoint|sql|bug|memory leak|async|await|test|unit|e2e)\b'
$businessPatterns = '(?i)\b(preco|pricing|monetizacao|assinatura|saas|churn|mrr|arr|cac|ltv|vender|venda|comissao|plano free|lucro|faturamento)\b'
$creativePatterns = '(?i)\b(roteiro|script|video|reels|tiktok|youtube|thumbnail|hook|gancho|retencao|copy|copywriting|carrossel|headline|titulo)\b'

if ($fullCaseText -match $codePatterns -or $fullCaseText -match $criticalPatterns) {
    $materia = "CODIGO"
    $varaNome = "1ª Vara de Crimes e Arquitetura de Código"
} elseif ($fullCaseText -match $businessPatterns) {
    $materia = "NEGOCIO"
    $varaNome = "2ª Vara Cível de Negócios, Pricing & SaaS"
} elseif ($fullCaseText -match $creativePatterns) {
    $materia = "CRIATIVO"
    $varaNome = "3ª Vara Especial de Conteúdo, Viralidade & Retenção"
}

# Calibração do Modo Auto
$effectiveEffort = $Effort
$effortDisplay = $Effort
if ($Effort -eq 'auto') {
    if ($fullCaseText -match $criticalPatterns) {
        $effectiveEffort = 'high'
        $effortDisplay = "auto -> high (risco crítico detectado em banco/pagamento/segurança)"
    } elseif ($fullCaseText -match $lowPatterns) {
        $effectiveEffort = 'low'
        $effortDisplay = "auto -> low (tema cosmético/estilização/documentação)"
    } else {
        $effectiveEffort = 'medium'
        $effortDisplay = "auto -> medium (padrão de engenharia e regras de negócio)"
    }
}

# ─────────────────────────────────────────────────────────────────────────────
# 3. MATRIZ CANÔNICA DE MODELOS POR CLI
# ─────────────────────────────────────────────────────────────────────────────

$modelMatrix = @{
    'agy' = @{
        'low'    = @{ 'builder' = 'gemini-3.8-flash-low';  'redteam' = 'gemini-3.8-flash-low';  'referee' = 'gemini-3.8-flash-low';    'taskEffort' = 'low' };
        'medium' = @{ 'builder' = 'gemini-3.8-flash-high'; 'redteam' = 'gemini-3.8-flash-high'; 'referee' = 'gemini-3.8-flash-medium'; 'taskEffort' = 'medium' };
        'high'   = @{ 'builder' = 'gemini-4-argon-high';   'redteam' = 'claude-opus-5-5-high';  'referee' = 'gemini-3.8-flash-high';   'taskEffort' = 'high' }
    };
    'codex' = @{
        'low'    = @{ 'builder' = 'gpt-6-luna';  'redteam' = 'gpt-6-luna';  'referee' = 'gpt-6-luna';  'taskEffort' = 'low' };
        'medium' = @{ 'builder' = 'gpt-6.1-sol'; 'redteam' = 'gpt-6.1-sol'; 'referee' = 'gpt-6-luna';  'taskEffort' = 'medium' };
        'high'   = @{ 'builder' = 'gpt-6.1-sol'; 'redteam' = 'gpt-6-astra'; 'referee' = 'gpt-6-luna';  'taskEffort' = 'high' }
    };
    'claude' = @{
        'low'    = @{ 'builder' = 'haiku-4.5'; 'redteam' = 'haiku-4.5'; 'referee' = 'haiku-4.5'; 'taskEffort' = 'low' };
        'medium' = @{ 'builder' = 'sonnet-5';  'redteam' = 'sonnet-5';  'referee' = 'haiku-4.5'; 'taskEffort' = 'medium' };
        'high'   = @{ 'builder' = 'sonnet-5';  'redteam' = 'opus-5';    'referee' = 'haiku-4.5'; 'taskEffort' = 'high' }
    }
}

$selectedConfig = $modelMatrix[$Engine][$effectiveEffort]
$modelBuilder = if ($BuilderModel) { $BuilderModel } else { $selectedConfig['builder'] }
$modelRedTeam = if ($RedTeamModel) { $RedTeamModel } else { $selectedConfig['redteam'] }
$modelReferee = if ($RefereeModel) { $RefereeModel } else { $selectedConfig['referee'] }
$taskEffort = $selectedConfig['taskEffort']

# Localizar o executor paralelo oficial
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$parallelRunner = Join-Path $scriptDir "invoke-parallel-runner.ps1"
if (-not (Test-Path -LiteralPath $parallelRunner)) {
    $parallelRunner = Join-Path $scriptDir "..\..\swarmv2\scripts\invoke-swarmv2-parallel.ps1"
}
if (-not (Test-Path -LiteralPath $parallelRunner)) {
    $parallelRunner = Resolve-Path (Join-Path (Get-Location).Path ".agents\skills\kage-bunshin\scripts\invoke-parallel-runner.ps1") -ErrorAction Stop
}

$pwshCmd = Get-Command pwsh -CommandType Application -ErrorAction SilentlyContinue
$shellExe = if ($pwshCmd) { 'pwsh' } else { 'powershell' }

# Função para extrair texto de resposta limpo
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

# ─────────────────────────────────────────────────────────────────────────────
# 4. RODADA 1: O DUELO CONCORRENTE (DEFESA vs ACUSAÇÃO EM PARALELO)
# ─────────────────────────────────────────────────────────────────────────────

$promptDefesa = @"
[PAPEL: O ADVOGADO DE DEFESA / BUILDER]
JURISDIÇÃO: $varaNome
CASO SUBMETIDO A JULGAMENTO:
$fullCaseText

SUA MISSÃO NA CORTE:
1. Mapeie todas as premissas ocultas a favor da tese/código.
2. Formule O TRIO DE SOLUÇÕES (1. Minimalista, 2. Convencional, 3. Robusta/Escalável).
3. Apresente os ganhos tangíveis, código/estratégia clara e viabilidade imediata.
"@

$promptAcusacao = @"
[PAPEL: O PROMOTOR DE JUSTIÇA / RED TEAM ADVERSARIAL]
JURISDIÇÃO: $varaNome
CASO SUBMETIDO A JULGAMENTO:
$fullCaseText

SUA MISSÃO NA CORTE:
1. Conduza um ataque implacável e impiedoso contra as premissas deste caso.
2. Identifique os pontos de quebra catastróficos, armadilhas ocultas, custos invisíveis e furos de lógica.
3. Se for código, aponte a falha fatal ou o teste que quebraria a solução. Se for negócio, aponte o risco de quebra/churn. Se for copy, aponte o tédio e a rejeição.
"@

$promptDefesaSafe = ($promptDefesa -replace "[\r\n]+", " ").Trim()
$promptAcusacaoSafe = ($promptAcusacao -replace "[\r\n]+", " ").Trim()

$manifestRound1 = @(
    @{
        "id"     = "${Engine}_defesa";
        "engine" = $Engine;
        "mode"   = "plan";
        "model"  = $modelBuilder;
        "effort" = $taskEffort;
        "prompt" = $promptDefesaSafe
    },
    @{
        "id"     = "${Engine}_acusacao";
        "engine" = $Engine;
        "mode"   = "plan";
        "model"  = $modelRedTeam;
        "effort" = $taskEffort;
        "prompt" = $promptAcusacaoSafe
    }
)

$jsonRound1 = $manifestRound1 | ConvertTo-Json -Depth 5 -Compress

$rawResultRound1 = & $shellExe -NoProfile -NonInteractive -File $parallelRunner `
    -ManifestJson $jsonRound1 `
    -WorkingDirectory $WorkingDirectory `
    -TimeoutSeconds $TimeoutSeconds `
    -Json

$parsedRound1 = $null
try { $parsedRound1 = $rawResultRound1 | ConvertFrom-Json } catch {}

if ($LASTEXITCODE -ne 0 -or ($parsedRound1 -and $parsedRound1.summary.failed -gt 0)) {
    throw "Falha na 1ª Rodada do Tribunal (Duelo Defesa vs Acusação). Julgamento suspenso."
}

$defesaTask = $parsedRound1.tasks | Where-Object { $_.id -like "*_defesa" } | Select-Object -First 1
$acusacaoTask = $parsedRound1.tasks | Where-Object { $_.id -like "*_acusacao" } | Select-Object -First 1

$defesaOutput = Get-TaskResponseText $defesaTask.output
$acusacaoOutput = Get-TaskResponseText $acusacaoTask.output

# ─────────────────────────────────────────────────────────────────────────────
# 5. RODADA 2: O JULGAMENTO INFORMADO (O MAGISTRADO ARBITRA O EMBATE REAL)
# ─────────────────────────────────────────────────────────────────────────────

$promptMagistrado = @"
[PAPEL: O MAGISTRADO SUPREMO DA CORTE / REFEREE SÊNIOR]
JURISDIÇÃO: $varaNome
CASO ORIGINAL:
$fullCaseText

================================================================================
AUTOS DO PROCESSO - SUSTENTAÇÃO DA DEFESA (BUILDER):
================================================================================
$defesaOutput

================================================================================
AUTOS DO PROCESSO - DENÚNCIA DA ACUSAÇÃO (RED TEAM):
================================================================================
$acusacaoOutput

================================================================================
DIRETRIZES DA SENTENÇA JUDICIAL:
================================================================================
1. Pondere o confronto entre a Defesa e a Acusação. Determine quais argumentos da acusação procedem e quais soluções da defesa resistem.
2. Emita o VEREDITO CLARO: [APROVADO] (com louvor ou ressalvas) OU [CONDENADO / REPROVADO].
3. Atribua o GRAU DE CERTEZA DA CORTE (Confidence Score de 0 a 100%). Se < 85%, declare FALHA CRÍTICA com retenção cautelar.
4. Entregue A SENTENÇA EM UMA FRASE marcante.
5. Emita as DETERMINAÇÕES FINAIS DO JUIZ (Plano acionável, código ou patch pronto, ou os 3 passos imediatos).
"@

$promptMagistradoSafe = ($promptMagistrado -replace "[\r\n]+", " ").Trim()

$manifestRound2 = @(
    @{
        "id"     = "${Engine}_magistrado";
        "engine" = $Engine;
        "mode"   = "plan";
        "model"  = $modelReferee;
        "effort" = $taskEffort;
        "prompt" = $promptMagistradoSafe
    }
)

$jsonRound2 = $manifestRound2 | ConvertTo-Json -Depth 5 -Compress

$rawResultRound2 = & $shellExe -NoProfile -NonInteractive -File $parallelRunner `
    -ManifestJson $jsonRound2 `
    -WorkingDirectory $WorkingDirectory `
    -TimeoutSeconds $TimeoutSeconds `
    -Json

$parsedRound2 = $null
try { $parsedRound2 = $rawResultRound2 | ConvertFrom-Json } catch {}

if ($LASTEXITCODE -ne 0 -or ($parsedRound2 -and $parsedRound2.summary.failed -gt 0)) {
    throw "Falha na 2ª Rodada do Tribunal (Sentença do Magistrado)."
}

$magistradoTask = $parsedRound2.tasks | Where-Object { $_.id -like "*_magistrado" } | Select-Object -First 1
$magistradoOutput = Get-TaskResponseText $magistradoTask.output

if ($Json) {
    @{
        tribunal = @{
            jurisdicao = $varaNome;
            materia = $materia;
            engine = $Engine;
            esforco = $effortDisplay;
            duracao_segundos = ($parsedRound1.summary.duration_seconds + $parsedRound2.summary.duration_seconds);
            defesa = $defesaOutput;
            acusacao = $acusacaoOutput;
            sentenca = $magistradoOutput;
        }
    } | ConvertTo-Json -Depth 10
    exit 0
}

# ─────────────────────────────────────────────────────────────────────────────
# 6. EXIBIÇÃO DA SENTENÇA JUDICIAL EM FORMATO DE ALTO IMPACTO
# ─────────────────────────────────────────────────────────────────────────────

$totalTime = [math]::Round($parsedRound1.summary.duration_seconds + $parsedRound2.summary.duration_seconds, 1)

Write-Output "# 🏛️ TRIBUNAL DA IA: SENTENÇA JUDICIAL"
Write-Output "> **Jurisdição:** $varaNome"
Write-Output "> **Corte:** $Engine | **Nível de Esforço:** $effortDisplay | **Duração do Julgamento:** ${totalTime}s | **Regime:** 100% Read-Only"
Write-Output "> **Composição da Corte:** Defesa ($modelBuilder) · Acusação ($modelRedTeam) · Magistrado ($modelReferee)"
Write-Output ""
Write-Output "---"
Write-Output "## ⚖️ AUTOS DO JULGAMENTO (SENTENÇA DO MAGISTRADO)"
Write-Output ""
Write-Output $magistradoOutput
Write-Output ""
Write-Output "---"
Write-Output "## ⚔️ O EMBATE DA CORTE (DEBATE PRELIMINAR)"
Write-Output ""
Write-Output "### 🛡️ Sustentação Oral da Defesa ($modelBuilder)"
Write-Output $defesaOutput
Write-Output ""
Write-Output "### 🔥 Denúncia da Acusação ($modelRedTeam)"
Write-Output $acusacaoOutput
Write-Output ""
Write-Output "---"
Write-Output "⚖️ *Sessão encerrada pelo Tribunal. Nenhum arquivo foi modificado no disco sem sua ordem expressa.*"
