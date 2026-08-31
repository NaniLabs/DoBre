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

function Create-Round-Image {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [int]$Size
    )
    $srcImage = [System.Drawing.Image]::FromFile($SourcePath)
    $destBitmap = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($destBitmap)
    
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    
    $graphics.Clear([System.Drawing.Color]::Transparent)
    
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse(0, 0, $Size, $Size)
    $graphics.SetClip($path)
    $graphics.DrawImage($srcImage, 0, 0, $Size, $Size)
    
    $destDir = Split-Path $DestinationPath -Parent
    if (!(Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    $destBitmap.Save($DestinationPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $path.Dispose()
    $graphics.Dispose()
    $destBitmap.Dispose()
    $srcImage.Dispose()
    Write-Host "Generated Round Icon: $DestinationPath ($Size x $Size)"
}

$workspaceRoot = $PSScriptRoot | Split-Path -Parent
$sourcePng = Join-Path $workspaceRoot "landing\public\branding\icon.png"

Write-Host "Using base branding icon: $sourcePng"

# 1. Android Standard Mipmap Icons
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-mdpi\ic_launcher.png") -Width 48 -Height 48
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-hdpi\ic_launcher.png") -Width 72 -Height 72
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png") -Width 96 -Height 96
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png") -Width 144 -Height 144
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png") -Width 192 -Height 192

# 2. Android Round Mipmap Icons
Create-Round-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-mdpi\ic_launcher_round.png") -Size 48
Create-Round-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-hdpi\ic_launcher_round.png") -Size 72
Create-Round-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xhdpi\ic_launcher_round.png") -Size 96
Create-Round-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xxhdpi\ic_launcher_round.png") -Size 144
Create-Round-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher_round.png") -Size 192

# 3. Android Adaptive Foregrounds
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-mdpi\ic_launcher_foreground.png") -Width 108 -Height 108
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-hdpi\ic_launcher_foreground.png") -Width 162 -Height 162
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xhdpi\ic_launcher_foreground.png") -Width 216 -Height 216
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xxhdpi\ic_launcher_foreground.png") -Width 324 -Height 324
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher_foreground.png") -Width 432 -Height 432

# 4. Flutter Web Icons
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "web\favicon.png") -Width 64 -Height 64
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "web\icons\Icon-192.png") -Width 192 -Height 192
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "web\icons\Icon-512.png") -Width 512 -Height 512
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "web\icons\Icon-maskable-192.png") -Width 192 -Height 192
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "web\icons\Icon-maskable-512.png") -Width 512 -Height 512

# 5. Copy Favicon SVG to Web
Copy-Item -Force (Join-Path $workspaceRoot "landing\public\branding\favicon.svg") (Join-Path $workspaceRoot "web\favicon.svg")

# 6. Copy ICO to Windows resources
Copy-Item -Force (Join-Path $workspaceRoot "landing\public\branding\icon.ico") (Join-Path $workspaceRoot "windows\runner\resources\app_icon.ico")

# 7. App In-app asset
Resize-Image -SourcePath $sourcePng -DestinationPath (Join-Path $workspaceRoot "assets\branding\icon.png") -Width 256 -Height 256

Write-Host "All icons generated successfully!"
