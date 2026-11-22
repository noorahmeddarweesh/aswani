# ==============================================================================
# Aswani - One-Click Backend & Ngrok Tunnel Runner
# ==============================================================================
# Automatically manages the FastAPI backend and Ngrok tunnel together.
# Features:
#   - Automatically frees port 8000 if blocked (prevents WinError 10013)
#   - Reads configuration from backend/.env automatically
#   - Starts the FastAPI backend and verifies health
#   - Launches the permanent Ngrok tunnel
#   - Automatically stops the backend when you press Ctrl+C
# ==============================================================================

param(
    [string]$NgrokDomain = "https://criteria-kindness-unfasten.ngrok-free.dev",
    [int]$Port = 8000
)

$ErrorActionPreference = "Continue"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = Get-Location }

# Load configuration from backend/.env if present
$envFile = Join-Path $ScriptDir "backend\.env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $name, $val = $line -split "=", 2
            $name = $name.Trim()
            $val = $val.Trim().Trim('"').Trim("'")
            [Environment]::SetEnvironmentVariable($name, $val, "Process")
        }
    }
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Aswani - Full-Stack Local Server & Tunnel Launcher     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Backend Port: $Port"
Write-Host "Ngrok Domain: $NgrokDomain"
Write-Host "Config:       backend/.env"
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Free Port 8000 if already occupied
Write-Host "`n[1/4] Checking port $Port availability..." -ForegroundColor Yellow
$activeConnections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($activeConnections) {
    $pidsToKill = $activeConnections | Select-Object -ExpandProperty OwningProcess -Unique
    foreach ($p in $pidsToKill) {
        Write-Host "      Freeing port $Port occupied by PID $p..." -ForegroundColor Yellow
        Stop-Process -Id $p -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 1
}

# Stop any running ngrok
Get-Process ngrok -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Locate ngrok executable
$ngrokPath = "$ScriptDir\ngrok.exe"
if (-not (Test-Path $ngrokPath)) {
    $ngrokCmd = Get-Command ngrok -ErrorAction SilentlyContinue
    if ($ngrokCmd) {
        $ngrokPath = $ngrokCmd.Source
    } else {
        Write-Host "[ERROR] ngrok.exe not found! Please ensure ngrok.exe is in the project root." -ForegroundColor Red
        exit 1
    }
}

# 3. Start the FastAPI backend
Write-Host "`n[2/4] Starting FastAPI backend on http://0.0.0.0:$Port..." -ForegroundColor Yellow
$backendDir = Join-Path $ScriptDir "backend"
$backendProcess = Start-Process -FilePath "python" `
    -ArgumentList "-m uvicorn main:app --host 0.0.0.0 --port $Port" `
    -WorkingDirectory $backendDir `
    -PassThru

Start-Sleep -Seconds 2

# 4. Verify Backend Health
Write-Host "`n[3/4] Verifying backend health..." -ForegroundColor Yellow
$healthy = $false
for ($i = 1; $i -le 10; $i++) {
    try {
        $resp = Invoke-RestMethod -Uri "http://localhost:$Port/api/places" -Method Get -TimeoutSec 3 -ErrorAction Stop
        if ($resp) {
            $healthy = $true
            break
        }
    } catch {
        Start-Sleep -Seconds 1
    }
}

if (-not $healthy) {
    Write-Host "[ERROR] Backend server failed to respond on port $Port!" -ForegroundColor Red
    if ($backendProcess -and -not $backendProcess.HasExited) {
        Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
    }
    exit 1
}

Write-Host "      Backend is healthy and connected to Supabase!" -ForegroundColor Green

# 5. Launch Ngrok Tunnel
Write-Host "`n[4/4] Starting Ngrok Tunnel on $NgrokDomain..." -ForegroundColor Green
Write-Host "      (Press Ctrl+C at any time to shut down both Server and Tunnel safely)`n" -ForegroundColor Cyan

try {
    & $ngrokPath http $Port --url $NgrokDomain --pooling-enabled
} finally {
    Write-Host "`n[SHUTDOWN] Terminating backend process (PID: $($backendProcess.Id))..." -ForegroundColor Yellow
    if ($backendProcess -and -not $backendProcess.HasExited) {
        Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
    }
    # Double-check port 8000
    $rem = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($rem) {
        Stop-Process -Id ($rem | Select-Object -ExpandProperty OwningProcess -Unique) -Force -ErrorAction SilentlyContinue
    }
    Write-Host "[SHUTDOWN] Server and Tunnel stopped cleanly. Port $Port is free.`n" -ForegroundColor Green
}
