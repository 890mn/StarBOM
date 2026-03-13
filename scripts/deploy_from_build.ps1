param(
    [string]$BuildDir = "../build",
    [string]$AppName = "Link2BOM",
    [string]$QtBin = "C:/Qt/6.10.1/mingw_64/bin",
    [switch]$NoQml
)

$ErrorActionPreference = "Stop"

try {

Write-Host ""
Write-Host "===================================="
Write-Host "        Link2BOM Deploy Tool"
Write-Host "===================================="
Write-Host ""

# ------------------------------------------------
# 1 检查 EXE
# ------------------------------------------------
Write-Host "[1/7] Checking executable..."

$exePath = Join-Path $BuildDir "$AppName.exe"

if (-not (Test-Path $exePath)) {
    throw "Executable not found: $exePath`nPlease build Release/MinSizeRel first."
}

Write-Host "  OK -> $exePath"
Write-Host ""


# ------------------------------------------------
# 2 创建 dist
# ------------------------------------------------
Write-Host "[2/7] Preparing dist directory..."

$distDir = Join-Path $BuildDir "dist"

if (Test-Path $distDir) {
    Write-Host "  Cleaning old dist..."
    Remove-Item -Recurse -Force $distDir
}

New-Item -ItemType Directory -Force $distDir | Out-Null

$distExe = Join-Path $distDir "$AppName.exe"
Copy-Item -Force $exePath $distExe

Write-Host "  EXE copied."
Write-Host ""


# ------------------------------------------------
# 3 运行 windeployqt
# ------------------------------------------------
Write-Host "[3/7] Running windeployqt..."

$deployTool = Join-Path $QtBin "windeployqt.exe"

if (-not (Test-Path $deployTool)) {
    throw "windeployqt not found: $deployTool"
}

$args = @("--release", "--no-translations")

if ($NoQml) {
    $args += "--no-quick-import"
} else {
    $args += @("--qmldir", "../src/qml")
}

$args += $distExe

Write-Host "  $deployTool $($args -join ' ')"
& $deployTool @args

Write-Host "  Deploy finished."
Write-Host ""


# ------------------------------------------------
# 4 删除 FluentWinUI3
# ------------------------------------------------
Write-Host "[4/7] Removing FluentWinUI3 theme..."

$fluentTheme = Join-Path $distDir "qml/QtQuick/Controls/FluentWinUI3"

if (Test-Path $fluentTheme) {
    Remove-Item -Recurse -Force $fluentTheme
    Write-Host "  FluentWinUI3 removed."
}
else {
    Write-Host "  Theme not found."
}

Write-Host ""


# ------------------------------------------------
# 5 检查 Qt 关键文件
# ------------------------------------------------
Write-Host "[5/7] Checking runtime dependencies..."

$required = @(
"Qt6Core.dll",
"Qt6Gui.dll",
"Qt6Qml.dll",
"Qt6Quick.dll",
"platforms/qwindows.dll"
)

foreach ($r in $required) {
    $p = Join-Path $distDir $r
    if (-not (Test-Path $p)) {
        throw "Missing runtime file: $r"
    }
}

Write-Host "  All required Qt files found."
Write-Host ""


# ------------------------------------------------
# 6 UPX 压缩
# ------------------------------------------------
Write-Host "[6/7] Compressing binaries with UPX..."

$upx = "upx"

Get-ChildItem $distDir -Filter *.dll | ForEach-Object {
    Write-Host "  compress -> $($_.Name)"
    & $upx --best $_.FullName | Out-Null
}

Write-Host "  compress -> $AppName.exe"
& $upx --best $distExe | Out-Null

Write-Host "  Compression finished."
Write-Host ""


# ------------------------------------------------
# 7 打包 zip
# ------------------------------------------------
Write-Host "[7/7] Creating portable zip..."

$zipPath = Join-Path $BuildDir "$AppName-windows-portable.zip"

if (Test-Path $zipPath) {
    Remove-Item -Force $zipPath
}

Compress-Archive -Path (Join-Path $distDir "*") `
    -DestinationPath $zipPath `
    -CompressionLevel Optimal

Write-Host "  Zip created."
Write-Host ""


# ------------------------------------------------
# 完成
# ------------------------------------------------
Write-Host "===================================="
Write-Host " Build Complete"
Write-Host "===================================="
Write-Host ""
Write-Host "Release dir : $distDir"
Write-Host "Zip package : $zipPath"
Write-Host ""

}
catch {
    Write-Host ""
    Write-Host "===================================="
    Write-Host " BUILD FAILED"
    Write-Host "===================================="
    Write-Host $_
    Write-Host ""
    pause
    exit 1
}