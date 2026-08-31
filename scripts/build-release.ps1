<#
.SYNOPSIS
    Script automatizado de Release y Distribución para DoBre v1.0.0+.

.DESCRIPTION
    1. Lee la versión desde pubspec.yaml.
    2. Ejecuta pruebas unitarias y análisis estático de Flutter.
    3. Valida el Cloudflare Worker y compila la Landing Page.
    4. Genera el APK de Android (DoBre-v<version>.apk).
    5. Genera la versión portable de Windows en .zip (DoBre-Windows-v<version>.zip).
    6. Genera el instalador ejecutable de Windows con Inno Setup (DoBreSetup-v<version>.exe).
    7. Genera sumas de verificación SHA256 (SHA256SUMS.txt).

.EXAMPLE
    .\scripts\build-release.ps1
    .\scripts\build-release.ps1 -Platforms @("android", "windows", "installer")
    .\scripts\build-release.ps1 -SkipTests
#>

[CmdletBinding()]
param(
    [string[]]$Platforms = @("all"),
    [switch]$SkipTests,
    [switch]$SkipAnalyze,
    [switch]$SkipWorkerCheck,
    [switch]$SkipLandingBuild,
    [switch]$Clean
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectDir = Split-Path -Parent $ScriptDir
Set-Location $ProjectDir

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "             DoBre - Pipeline de Release                  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Leer versión desde pubspec.yaml
$pubspecContent = Get-Content -Path (Join-Path $ProjectDir "pubspec.yaml") -Raw
if ($pubspecContent -match 'version:\s*([^\s+]+)') {
    $Version = $matches[1]
} else {
    Write-Error "No se pudo extraer la versión de pubspec.yaml"
    exit 1
}

Write-Host "[1/7] Versión detectada: v$Version" -ForegroundColor Green

# Directorio de salida de releases
$OutputDir = Join-Path $ProjectDir "dist\releases"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

if ($Clean) {
    Write-Host "Limpiando artefactos previos de release..." -ForegroundColor Yellow
    Get-ChildItem -Path $OutputDir -File | Remove-Item -Force
}

# 2. Análisis y Tests de Flutter
if (-not $SkipAnalyze) {
    Write-Host "`n[2/7] Ejecutando análisis estático (flutter analyze)..." -ForegroundColor Cyan
    & flutter analyze
    if ($LASTEXITCODE -ne 0) {
        Write-Error "flutter analyze falló con código $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}

if (-not $SkipTests) {
    Write-Host "`n[3/7] Ejecutando tests unitarios (flutter test)..." -ForegroundColor Cyan
    & flutter test
    if ($LASTEXITCODE -ne 0) {
        Write-Error "flutter test falló con código $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}

# 3. Validar Cloudflare Worker y Landing
if (-not $SkipWorkerCheck) {
    Write-Host "`n[4/7] Validando Cloudflare Worker..." -ForegroundColor Cyan
    $WorkerDir = Join-Path $ProjectDir "cloudflare-worker"
    if (Test-Path $WorkerDir) {
        Push-Location $WorkerDir
        & npm.cmd run check
        $workerCheckExit = $LASTEXITCODE
        Pop-Location
        if ($workerCheckExit -ne 0) {
            Write-Error "Cloudflare Worker typecheck falló"
            exit $workerCheckExit
        }
    }
}

if (-not $SkipLandingBuild) {
    Write-Host "`n[5/7] Verificando compilación de Landing Page..." -ForegroundColor Cyan
    $LandingDir = Join-Path $ProjectDir "landing"
    if (Test-Path $LandingDir) {
        Push-Location $LandingDir
        & npm.cmd run build
        $landingExit = $LASTEXITCODE
        Pop-Location
        if ($landingExit -ne 0) {
            Write-Error "Landing Page build falló"
            exit $landingExit
        }
    }
}

$BuildAll = $Platforms -contains "all"

# 4. Android APK Release
if ($BuildAll -or ($Platforms -contains "android") -or ($Platforms -contains "apk")) {
    Write-Host "`n[6/7 - Android] Compilando APK Release..." -ForegroundColor Cyan
    & flutter build apk --release
    if ($LASTEXITCODE -ne 0) {
        Write-Error "flutter build apk falló"
        exit $LASTEXITCODE
    }

    $SourceApk = Join-Path $ProjectDir "build\app\outputs\flutter-apk\app-release.apk"
    if (Test-Path $SourceApk) {
        $DestApk1 = Join-Path $OutputDir "DoBre-v$Version.apk"
        $DestApk2 = Join-Path $OutputDir "DoBre-Android-v$Version.apk"
        Copy-Item -Path $SourceApk -Destination $DestApk1 -Force
        Copy-Item -Path $SourceApk -Destination $DestApk2 -Force
        Write-Host "  -> Generado: $DestApk1" -ForegroundColor Green
    } else {
        Write-Warning "No se encontró el APK en $SourceApk"
    }
}

# 5. Windows Release & Portable ZIP
if ($BuildAll -or ($Platforms -contains "windows") -or ($Platforms -contains "installer")) {
    Write-Host "`n[6/7 - Windows] Compilando Windows Release..." -ForegroundColor Cyan
    & flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        Write-Error "flutter build windows falló"
        exit $LASTEXITCODE
    }

    $WinReleaseDir = Join-Path $ProjectDir "build\windows\x64\runner\Release"
    if (Test-Path $WinReleaseDir) {
        $DestZip = Join-Path $OutputDir "DoBre-Windows-v$Version.zip"
        if (Test-Path $DestZip) { Remove-Item $DestZip -Force }
        Compress-Archive -Path "$WinReleaseDir\*" -DestinationPath $DestZip -Force
        Write-Host "  -> Generado Portable ZIP: $DestZip" -ForegroundColor Green
    }
}

# 6. Windows Inno Setup Installer
if ($BuildAll -or ($Platforms -contains "installer") -or ($Platforms -contains "inno")) {
    Write-Host "`n[6/7 - Inno Setup] Generando Instalador de Windows..." -ForegroundColor Cyan
    
    # Buscar compilador ISCC
    $IsccPath = $null
    $possiblePaths = @(
        "iscc",
        "D:\Aplicaciones\Inno Setup 6\ISCC.exe",
        "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
        "C:\Program Files\Inno Setup 6\ISCC.exe",
        (Get-Command iscc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
    )

    foreach ($p in $possiblePaths) {
        if ($p -and (Test-Path $p)) {
            $IsccPath = $p
            break
        }
    }

    if (-not $IsccPath) {
        # Intentar consultar registro
        $reg = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object { $_.DisplayName -match 'Inno Setup' } | Select-Object -First 1
        if ($reg -and $reg.InstallLocation) {
            $testIscc = Join-Path $reg.InstallLocation "ISCC.exe"
            if (Test-Path $testIscc) {
                $IsccPath = $testIscc
            }
        }
    }

    if ($IsccPath) {
        $IssScript = Join-Path $ProjectDir "installer\dobre_installer.iss"
        Write-Host "  Compilando con: $IsccPath" -ForegroundColor DarkGray
        & $IsccPath "/DMyAppVersion=$Version" $IssScript
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  -> Generado Instalador: $OutputDir\DoBreSetup-v$Version.exe" -ForegroundColor Green
        } else {
            Write-Warning "Inno Setup falló con código $LASTEXITCODE"
        }
    } else {
        Write-Warning "ISCC.exe no fue encontrado. El instalador .exe no pudo compilarse."
    }
}

# 7. Resumen y Checksums
Write-Host "`n[7/7] Generando sumas de verificación SHA256..." -ForegroundColor Cyan
$releaseFiles = Get-ChildItem -Path $OutputDir -File | Where-Object { $_.Name -ne "SHA256SUMS.txt" }

$shaSums = @()
foreach ($file in $releaseFiles) {
    $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash.ToLower()
    $shaSums += "$hash  $($file.Name)"
}

$shaFile = Join-Path $OutputDir "SHA256SUMS.txt"
$shaSums | Set-Content -Path $shaFile -Encoding utf8

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "         ¡Release v$Version Generada Exitosamente!        " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Artefactos listos en: $OutputDir`n"

foreach ($file in $releaseFiles) {
    $sizeMB = ($file.Length / 1MB).ToString("0.00")
    Write-Host ("  {0,-35} ({1,6} MB)" -f $file.Name, $sizeMB) -ForegroundColor Cyan
}

Write-Host "`nChecksums guardados en: SHA256SUMS.txt" -ForegroundColor DarkGray
Write-Host "Listo para publicar en GitHub Releases o distribuir.`n" -ForegroundColor Green
