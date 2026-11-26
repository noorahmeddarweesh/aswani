# Branding (placeholder)

These are **placeholder** images made from the official palette
(Deep Blue `#173B63`, Heritage Gold `#D6AE55`, Playfair "A").
Replace them with the designer's logo, keeping the same file names and sizes,
then run:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

| File | Size | Notes |
|---|---|---|
| `app_icon.png` | 1024×1024, no transparency | iOS + legacy Android icon |
| `app_icon_foreground.png` | 1024×1024, transparent | Android adaptive icon; the generator adds a 16% inset, so the logo can fill ~80% of the image |
| `splash_logo.png` | 1152×1152, transparent | Splash logo; Android 12+ crops it to a circle of 2/3 the size |
