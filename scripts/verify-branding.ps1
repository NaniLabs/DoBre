Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

$workspaceRoot = $PSScriptRoot | Split-Path -Parent

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "        Verificación de Branding e Iconos Oficiales       " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$pubspecContent = Get-Content -Path (Join-Path $workspaceRoot "pubspec.yaml") -Raw
if ($pubspecContent -match 'version:\s*([^\s+]+)') {
    $Version = $matches[1]
} else {
    $Version = "1.0.1"
}

# 1. Windows Executable & Installer
$exePath = Join-Path $workspaceRoot "build\windows\x64\runner\Release\dobre.exe"
$setupPath = Join-Path $workspaceRoot "dist\releases\DoBreSetup-v$Version.exe"

if (Test-Path $exePath) {
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($exePath)
    Write-Host "[Windows EXE] Icono extraído correctamente de $exePath ($($icon.Width)x$($icon.Height))" -ForegroundColor Green
    $icon.Dispose()
} else {
    Write-Host "[Windows EXE] No se encontró $exePath" -ForegroundColor Red
}

if (Test-Path $setupPath) {
    $setupIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($setupPath)
    Write-Host "[Windows Setup] Icono extraído correctamente de $setupPath ($($setupIcon.Width)x$($setupIcon.Height))" -ForegroundColor Green
    $setupIcon.Dispose()
} else {
    Write-Host "[Windows Setup] No se encontró $setupPath" -ForegroundColor Red
}

# 2. Android APK Package Contents
$apkPath = Join-Path $workspaceRoot "dist\releases\DoBre-v$Version.apk"
if (Test-Path $apkPath) {
    $zip = [System.IO.Compression.ZipFile]::OpenRead($apkPath)
    $resEntries = $zip.Entries | Where-Object { $_.FullName -like "res/*" -or $_.FullName -like "*icon*" }
    Write-Host "`n[Android APK] Recursos empaquetados en $apkPath :" -ForegroundColor Cyan
    foreach ($entry in $resEntries) {
        Write-Host "  - $($entry.FullName) ($($entry.Length) bytes)" -ForegroundColor Green
    }
    $zip.Dispose()
} else {
    Write-Host "[Android APK] No se encontró $apkPath" -ForegroundColor Red
}

# 3. Web Build
$webDir = Join-Path $workspaceRoot "build\web"
if (Test-Path $webDir) {
    Write-Host "`n[Flutter Web] Assets verificados en $webDir :" -ForegroundColor Cyan
    $webFiles = @("favicon.png", "favicon.svg", "icons\Icon-192.png", "icons\Icon-512.png", "icons\Icon-maskable-192.png", "icons\Icon-maskable-512.png")
    foreach ($f in $webFiles) {
        $p = Join-Path $webDir $f
        if (Test-Path $p) {
            $len = (Get-Item $p).Length
            Write-Host "  - $f ($len bytes)" -ForegroundColor Green
        } else {
            Write-Host "  - Faltante: $f" -ForegroundColor Red
        }
    }
} else {
    Write-Host "[Flutter Web] No se encontró $webDir" -ForegroundColor Red
}

Write-Host "`nVerificación completa." -ForegroundColor Cyan
