Add-Type -AssemblyName System.Drawing

function Resize-Image {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [int]$Width,
        [int]$Height
    )
    $srcImage = [System.Drawing.Image]::FromFile($SourcePath)
    $destBitmap = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($destBitmap)
    
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.DrawImage($srcImage, 0, 0, $Width, $Height)
    
    $destDir = Split-Path $DestinationPath -Parent
    if (!(Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    $destBitmap.Save($DestinationPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $graphics.Dispose()
    $destBitmap.Dispose()
    $srcImage.Dispose()
    Write-Host "Generated: $DestinationPath ($Width x $Height)"
}

$workspaceRoot = $PSScriptRoot | Split-Path -Parent
$sourcePng = Join-Path $workspaceRoot "landing\public\branding\icon.png"

Write-Host "Using base branding icon: $sourcePng"

# Android Launcher Icons
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-mdpi\ic_launcher.png") -Width 48 -Height 48
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-hdpi\ic_launcher.png") -Width 72 -Height 72
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png") -Width 96 -Height 96
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png") -Width 144 -Height 144
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png") -Width 192 -Height 192

# Android Round Icons
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-mdpi\ic_launcher_round.png") -Width 48 -Height 48
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-hdpi\ic_launcher_round.png") -Width 72 -Height 72
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xhdpi\ic_launcher_round.png") -Width 96 -Height 96
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xxhdpi\ic_launcher_round.png") -Width 144 -Height 144
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher_round.png") -Width 192 -Height 192

# Android Adaptive Icon Foregrounds (centered 72dp icon in 108dp viewport)
function Create-Adaptive-Foreground {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [int]$TotalSize,
        [int]$IconSize
    )
    $srcImage = [System.Drawing.Image]::FromFile($SourcePath)
    $destBitmap = New-Object System.Drawing.Bitmap($TotalSize, $TotalSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($destBitmap)
    
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $offset = [int](($TotalSize - $IconSize) / 2)
    $graphics.DrawImage($srcImage, $offset, $offset, $IconSize, $IconSize)
    
    $destDir = Split-Path $DestinationPath -Parent
    if (!(Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    $destBitmap.Save($DestinationPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $graphics.Dispose()
    $destBitmap.Dispose()
    $srcImage.Dispose()
    Write-Host "Generated Adaptive Foreground: $DestinationPath ($TotalSize x $TotalSize with inner $IconSize)"
}

Create-Adaptive-Foreground -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-mdpi\ic_launcher_foreground.png") -TotalSize 108 -IconSize 72
Create-Adaptive-Foreground -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-hdpi\ic_launcher_foreground.png") -TotalSize 162 -IconSize 108
Create-Adaptive-Foreground -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xhdpi\ic_launcher_foreground.png") -TotalSize 216 -IconSize 144
Create-Adaptive-Foreground -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xxhdpi\ic_launcher_foreground.png") -TotalSize 324 -IconSize 216
Create-Adaptive-Foreground -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher_foreground.png") -TotalSize 432 -IconSize 288

# Flutter Web Icons
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "web\favicon.png") -Width 64 -Height 64
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "web\icons\Icon-192.png") -Width 192 -Height 192
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "web\icons\Icon-512.png") -Width 512 -Height 512
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "web\icons\Icon-maskable-192.png") -Width 192 -Height 192
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "web\icons\Icon-maskable-512.png") -Width 512 -Height 512

# Copy Favicon SVG to Web
Copy-Item -Force (Join-Path $workspaceRoot "landing\public\branding\favicon.svg") (Join-Path $workspaceRoot "web\favicon.svg")

# Copy ICO to Windows resources
Copy-Item -Force (Join-Path $workspaceRoot "landing\public\branding\icon.ico") (Join-Path $workspaceRoot "windows\runner\resources\app_icon.ico")

# App In-app asset
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "assets\branding\icon.png") -Width 256 -Height 256

Write-Host "All icons generated successfully!"
