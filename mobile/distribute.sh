#!/usr/bin/env bash
# ==============================================================================
# Aswani - Automated Firebase App Distribution Script (Bash)
# ==============================================================================
# Usage:
#   ./distribute.sh
#   ./distribute.sh debug
#   ./distribute.sh release "Sprint 2 build" "https://aswani-api.onrender.com/api"
# ==============================================================================

set -euo pipefail

MODE="${1:-release}"
APP_ID="1:297721741384:android:d1f45cd80aac04191c187d"
TESTERS="fatmanazieh0@gmail.com,haddert102@gmail.com,mariamhussien3110@gmail.com,minasamoil205@gmail.com,noorahmed2703@gmail.com,nourhankhal3d@gmail.com,realitymawada9@gmail.com"
RELEASE_NOTES="${2:-Aswani build $(date '+%Y-%m-%d %H:%M')}"
BASE_URL="${3:-https://criteria-kindness-unfasten.ngrok-free.dev/api}"
USE_MOCKS="false"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo "  Aswani Mobile - Build & Firebase Distribution Pipeline"
echo "=========================================================="
echo "Mode:          $MODE"
echo "Firebase App:  $APP_ID"
echo "Tester Groups: $GROUPS"
echo "API Base URL:  $BASE_URL"
echo "Use Mocks:     $USE_MOCKS"
echo "Release Notes: $RELEASE_NOTES"
echo "=========================================================="

echo -e "\n[1/3] Building Flutter APK ($MODE)..."
flutter build apk \
    --"$MODE" \
    --dart-define=USE_MOCKS="$USE_MOCKS" \
    --dart-define=BASE_URL="$BASE_URL"

APK_PATH="build/app/outputs/flutter-apk/app-$MODE.apk"
if [ ! -f "$APK_PATH" ]; then
    echo -e "\n[ERROR] Built APK not found at $APK_PATH"
    exit 1
fi

echo -e "\n[2/3] Distributing APK to Firebase App Distribution..."
firebase appdistribution:distribute "$APK_PATH" \
    --app "$APP_ID" \
    --testers "$TESTERS" \
    --release-notes "$RELEASE_NOTES"

echo -e "\n=========================================================="
echo "  [SUCCESS] Distribution to Firebase completed!"
echo "  Testers in group '$GROUPS' will receive an update email."
echo "=========================================================="
