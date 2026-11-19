# Aswani mobile app

Flutter app for exploring Aswan. Architecture, patterns, palette and sprint
plan: see [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md).

## First-time setup (after cloning)

Requires Flutter 3.50+ (Dart 3.14). Material widgets come from the
`material_ui` package: import `package:material_ui/material_ui.dart`,
never `package:flutter/material.dart`.

```sh
flutter upgrade
flutter pub get
flutter gen-l10n
```

## Before every pull request

```sh
dart format $(find lib test -name '*.dart' -not -path '*/generated/*')
flutter analyze
bash tool/check_design_tokens.sh
flutter test
```

## Run

```sh
# Mock data (default)
flutter run --dart-define=USE_MOCKS=true

# Real backend
flutter run --dart-define=USE_MOCKS=false --dart-define=BASE_URL=https://<backend>/api
```

## Rules that CI enforces

- Colours come only from the theme (`context.colors`, `context.palette`).
  `Color(0x...)`, `Colors.x` or `AppColors.x` outside `lib/core/theme/` fails CI.
- No hard-coded user-facing strings: add them to `lib/core/l10n/app_en.arb`
  and `app_ar.arb`.
- `flutter analyze` clean and all tests green.
