# ==============================================================================
# Aswani - Automated Firebase App Distribution Script (PowerShell)
# ==============================================================================
# Usage:
#   .\distribute.ps1
#   .\distribute.ps1 -Mode debug
#   .\distribute.ps1 -Mode release -ReleaseNotes "Sprint 2 full integration testing"
#   .\distribute.ps1 -BaseUrl "https://aswani-api.onrender.com/api"
# ==============================================================================

param(
    [ValidateSet("debug", "release")]
    [string]$Mode = "release",

    [string]$AppId = "1:297721741384:android:d1f45cd80aac04191c187d",

    [string]$Groups = "android-testers",

    [string]$ReleaseNotes = "Aswani build $(Get-Date -Format 'yyyy-MM-dd HH:mm')",

    [string]$BaseUrl = "https://criteria-kindness-unfasten.ngrok-free.dev/api",

    [bool]$UseMocks = $false
)

$ErrorActionPreference = "Stop"

# Ensure we are executing from the mobile directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($ScriptDir) {
    Set-Location $ScriptDir
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Aswani Mobile - Build & Firebase Distribution Pipeline" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Mode:          $Mode"
Write-Host "Firebase App:  $AppId"
Write-Host "Tester Groups: $Groups"
Write-Host "API Base URL:  $BaseUrl"
Write-Host "Use Mocks:     $UseMocks"
Write-Host "Release Notes: $ReleaseNotes"
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Build the Flutter APK
Write-Host "`n[1/3] Building Flutter APK ($Mode)..." -ForegroundColor Yellow

$BuildArgs = @(
    "build", "apk",
    "--$Mode",
    "--dart-define=USE_MOCKS=$($UseMocks.ToString().ToLower())",
    "--dart-define=BASE_URL=$BaseUrl"
)

& flutter @BuildArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERROR] Flutter build failed with exit code $LASTEXITCODE!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n[SUCCESS] Flutter APK built successfully." -ForegroundColor Green

# 2. Locate the generated APK
$ApkPath = "build/app/outputs/flutter-apk/app-$Mode.apk"
if (-not (Test-Path $ApkPath)) {
    Write-Host "`n[ERROR] Built APK not found at $ApkPath" -ForegroundColor Red
    exit 1
}

$ApkItem = Get-Item $ApkPath
$ApkSizeMb = [math]::Round($ApkItem.Length / 1MB, 2)
Write-Host "[INFO] APK located: $ApkPath ($ApkSizeMb MB)" -ForegroundColor Cyan

# 3. Distribute via Firebase CLI
Write-Host "`n[2/3] Distributing APK to Firebase App Distribution..." -ForegroundColor Yellow

$DistributeArgs = @(
    "appdistribution:distribute",
    $ApkPath,
    "--app", $AppId,
    "--groups", $Groups,
    "--release-notes", $ReleaseNotes
)

& firebase @DistributeArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERROR] Firebase distribution failed with exit code $LASTEXITCODE!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  [SUCCESS] Distribution to Firebase completed!" -ForegroundColor Green
Write-Host "  Testers in group '$Groups' will receive an update email." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
