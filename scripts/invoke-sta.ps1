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
    [switch]$Json,
    [switch]$Zoeira,
    [switch]$Plenario,
    [switch]$Brasil
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mainScript = Join-Path $scriptDir "invoke-cross-model-review.ps1"

& $mainScript @PSBoundParameters
