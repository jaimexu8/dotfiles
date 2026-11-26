$ErrorActionPreference = 'Stop'

$Src = Join-Path $PSScriptRoot 'AGENTS.md'
$Marker = '<!-- managed by ~/dotfiles/agents/AGENTS.md'
$Stamp = Get-Date -Format 'yyyyMMddHHmmss'

function Link-AgentFile([string]$Target) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
    $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue

    if ($item) {
        if ($item.LinkType -eq 'SymbolicLink') {
            if (@($item.Target)[0] -eq $Src) { Write-Host "ok      $Target"; return }
            Remove-Item -LiteralPath $Target -Force
        } elseif ((Get-Content -LiteralPath $Target -TotalCount 1) -like "$Marker*") {
            Remove-Item -LiteralPath $Target -Force
        } else {
            $backup = "$Target.bak.$Stamp"
            Move-Item -LiteralPath $Target -Destination $backup
            Write-Host "backup  $Target -> $backup"
        }
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Src | Out-Null
        Write-Host "linked  $Target -> $Src"
    } catch {
        Copy-Item -LiteralPath $Src -Destination $Target
        Write-Warning "copied  $Target (symlink not permitted; enable Developer Mode, or re-run after every pull)"
    }
}

$claudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
$codexDir  = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }

Link-AgentFile (Join-Path $claudeDir 'CLAUDE.md')
Link-AgentFile (Join-Path $HOME '.gemini\AGENTS.md')
Link-AgentFile (Join-Path $codexDir 'AGENTS.md')

$settings = Join-Path $claudeDir 'settings.json'
$json = if ((Test-Path -LiteralPath $settings) -and (Get-Content -Raw -LiteralPath $settings).Trim()) {
    Get-Content -Raw -LiteralPath $settings | ConvertFrom-Json
} else { [pscustomobject]@{} }
$json | Add-Member -Force -NotePropertyName includeCoAuthoredBy -NotePropertyValue $false
$json | Add-Member -Force -NotePropertyName attribution -NotePropertyValue ([pscustomobject]@{ commit = ''; pr = '' })
$json | ConvertTo-Json -Depth 32 | Set-Content -LiteralPath $settings -Encoding utf8
Write-Host "set     ${settings}: attribution disabled"

$geminiMd =Join-Path $HOME '.gemini\GEMINI.md'
if (Test-Path -LiteralPath $geminiMd) {
    Write-Warning "$geminiMd also exists; agy loads both. Merge it into AGENTS.md and remove it."
}
