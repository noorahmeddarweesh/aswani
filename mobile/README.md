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

With `USE_MOCKS=false` every feature uses its `*_remote_datasource.dart`, built
from `docs/api-contract/openapi.yaml`. The shared HTTP code is in
`lib/core/network/`: the client, the Bearer token with automatic refresh, and
error mapping to the contract's codes. Debug builds may use plain `http` to a
local backend (`http://10.0.2.2:3000/api` from the Android emulator).

## Working in parallel (Sprint 2)

- **Routes:** each feature registers its routes in its own
  `lib/features/<feature>/<feature>_routes.dart` (`*TabRoutes` inside a tab,
  `*RootRoutes` full screen). `app_router.dart` only puts the lists together.
- **Strings:** start new keys with the feature (`community…`, `culture…`,
  `guides…`, `report…`) and run `dart run tool/sort_arb.dart` before a pull
  request; sorted files rarely conflict.
- **Error codes:** one registry, `lib/core/errors/error_messages.dart`; a new
  contract code gets its message there first.
- **Photo uploads:** `buildFormData()` in `lib/core/network/upload.dart` and the
  shared `PhotoPickerField` (max 6 photos, 5 MB, jpg/png/webp).
- Shared files (router, error codes, Home) change in a small separate PR.

## Rules that CI enforces

- Colours come only from the theme (`context.colors`, `context.palette`).
  `Color(0x...)`, `Colors.x` or `AppColors.x` outside `lib/core/theme/` fails CI.
- No hard-coded user-facing strings: add them to `lib/core/l10n/app_en.arb`
  and `app_ar.arb`.
- `flutter analyze` clean and all tests green.
