<#
.SYNOPSIS
    Script de despliegue para Cloudflare Worker (configuración remota).

.DESCRIPTION
    1. Valida la estructura del JSON en assets/config/default_config.json.
    2. Ejecuta tsc (typecheck) para asegurar coherencia tipada.
    3. Ejecuta wrangler deploy para publicar a Cloudflare Workers.

.EXAMPLE
    .\scripts\deploy-worker.ps1
#>

[CmdletBinding()]
param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectDir = Split-Path -Parent $ScriptDir
$WorkerDir = Join-Path $ProjectDir "cloudflare-worker"
$ConfigFile = Join-Path $ProjectDir "assets\config\default_config.json"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       DoBre - Despliegue de Cloudflare Worker             " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Validar JSON
Write-Host "[1/3] Validando assets/config/default_config.json..." -ForegroundColor Cyan
try {
    $rawJson = Get-Content -Path $ConfigFile -Raw
    $parsed = $rawJson | ConvertFrom-Json
    Write-Host "  -> JSON válido. Versión de tarifas: $($parsed.version)" -ForegroundColor Green
} catch {
    Write-Error "Error de sintaxis en default_config.json: $_"
    exit 1
}

# 2. Typecheck del Worker
Write-Host "`n[2/3] Verificando tipos TypeScript en cloudflare-worker..." -ForegroundColor Cyan
Push-Location $WorkerDir
try {
    & npm.cmd run check
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Typecheck falló con código $LASTEXITCODE"
        exit $LASTEXITCODE
    }
    Write-Host "  -> Typecheck exitoso (0 errores)." -ForegroundColor Green
} finally {
    Pop-Location
}

# 3. Despliegue con Wrangler
if ($DryRun) {
    Write-Host "`n[3/3] Modo DryRun activo. Despliegue omitido." -ForegroundColor Yellow
} else {
    Write-Host "`n[3/3] Desplegando Worker con Wrangler..." -ForegroundColor Cyan
    Push-Location $WorkerDir
    try {
        & npm.cmd run deploy
        if ($LASTEXITCODE -ne 0) {
            Write-Error "wrangler deploy falló. Verificá que estés autenticado con 'npx wrangler login' o mediante CLOUDFLARE_API_TOKEN."
            exit $LASTEXITCODE
        }
        Write-Host "  -> ¡Worker desplegado exitosamente!" -ForegroundColor Green
    } finally {
        Pop-Location
    }
}
