#!/usr/bin/env bash
# Fails when colours are defined outside lib/core/theme/.
# Feature code must read colours from the theme:
#   context.colors.primary, context.palette.textSecondary
set -euo pipefail

pattern='Color\(0x|Color\.fromARGB|Color\.fromRGBO|Colors\.(?!transparent\b)[a-zA-Z]+|AppColors\.'

violations=$(grep -rnP "$pattern" lib --include='*.dart' \
  | grep -v '^lib/core/theme/' \
  | grep -v '^lib/core/l10n/generated/' || true)

if [[ -n "$violations" ]]; then
  echo "Design-token check failed: colours must come from the theme."
  echo "Use context.colors.* or context.palette.* instead of:"
  echo "$violations"
  exit 1
fi

echo "Design-token check passed."
