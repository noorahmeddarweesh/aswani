# Features

Every feature has the same three layers (Clean Architecture + MVVM, feature-first):

```
<feature>/
  data/          models (DTOs), datasources (remote + mock), mappers, repositories (impl)
  domain/        entities, repositories (abstract interfaces)
  presentation/  screens, widgets, viewmodels
```

Rules:
- Screen -> ViewModel -> Repository -> DataSource. The UI never calls dio.
- A feature never imports another feature's `data/` or `presentation/`;
  it may use another feature's `domain/` and its `<feature>_providers.dart`
  (the feature's public entry point). Shared code goes to `lib/shared/` or `lib/core/`.
- Each implemented feature has a `<feature>_providers.dart`: the only place
  that chooses the mock or the remote data source.
- Colours, text styles and spacing come only from the theme (`context.colors`,
  `context.palette`, `context.text`, `AppSpacing`).
- No hard-coded strings: add them to `lib/core/l10n/app_en.arb` and `app_ar.arb`.

Each folder's README says what the feature does and in which sprint it is planned.
`dev_gallery/` is an internal screen that previews the design system.
