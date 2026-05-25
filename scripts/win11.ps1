# win11.ps1 — idempotent dev-box bootstrap for Windows 11.
#
# Usage (from elevated PowerShell):
#   irm https://raw.githubusercontent.com/fingerskier/bootstrap/main/scripts/win11.ps1 | iex
#
# Read before piping curl into shell. Always.

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Have-Winget {
    return [bool](Get-Command winget -ErrorAction SilentlyContinue)
}

function Install-WingetPkg {
    param([Parameter(Mandatory)][string]$Id)
    Write-Host ">> winget: $Id" -ForegroundColor Cyan
    $listed = winget list --id $Id -e 2>$null | Select-String -SimpleMatch $Id
    if ($listed) {
        Write-Host "   already installed, skipping." -ForegroundColor DarkGray
        return
    }
    winget install --id $Id -e --accept-package-agreements --accept-source-agreements
}

function Install-NpmGlobal {
    param([Parameter(Mandatory)][string]$Pkg)
    Write-Host ">> npm -g: $Pkg" -ForegroundColor Cyan
    npm ls -g --depth=0 $Pkg *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   already installed, skipping." -ForegroundColor DarkGray
        return
    }
    npm install -g $Pkg
}

if (-not (Have-Winget)) {
    Write-Error "winget not found. Install App Installer from the Microsoft Store, then re-run."
}

# --- core CLIs / apps ---
$wingetPkgs = @(
    'Git.Git',
    'GitHub.cli',
    'Microsoft.PowerShell',
    'Microsoft.WindowsTerminal',
    'Microsoft.VisualStudioCode',
    'Neovim.Neovim',
    'Starship.Starship',
    'junegunn.fzf',
    'BurntSushi.ripgrep.MSVC',
    'sharkdp.fd',
    'sharkdp.bat',
    'eza-community.eza',
    'jqlang.jq',
    'MikeFarah.yq',
    'ajeetdsouza.zoxide',
    'dandavison.delta',
    'astral-sh.uv',
    'CoreyButler.NVMforWindows',
    'Docker.DockerDesktop'
)
foreach ($id in $wingetPkgs) { Install-WingetPkg -Id $id }

# Refresh PATH for this session so subsequent commands work.
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path','User')

# --- Python via uv ---
if (Get-Command uv -ErrorAction SilentlyContinue) {
    Write-Host ">> uv python install 3.12" -ForegroundColor Cyan
    uv python install 3.12
}

# --- Node via nvm-windows ---
if (Get-Command nvm -ErrorAction SilentlyContinue) {
    Write-Host ">> nvm install lts" -ForegroundColor Cyan
    nvm install lts
    nvm use lts
}

# --- npm globals ---
if (Get-Command npm -ErrorAction SilentlyContinue) {
    $npmPkgs = @(
        '@anthropic-ai/claude-code',
        '@openai/codex',
        '@google/gemini-cli',
        'xlii',
        'wrangler',
        'underrow'
    )
    foreach ($p in $npmPkgs) { Install-NpmGlobal -Pkg $p }
} else {
    Write-Warning "npm not on PATH yet — reopen terminal and re-run for the npm portion."
}

Write-Host "`nDone. Open a new terminal and run scripts\smoke.ps1 (or follow win11.md §10)." -ForegroundColor Green
