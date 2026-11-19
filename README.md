# Aswani

Aswani is a smart mobile guide to Aswan, Egypt: place discovery and
recommendations, smart navigation, an AI assistant, Nubian cultural stories,
a community hub, city services and complaints.

B.Sc. graduation project, College of Computing and Information Technology,
South Valley University, 2026.

## Repository structure

```
aswani/
├── mobile/    Flutter app (Android + iOS)
├── backend/   Backend API
├── docs/      Architecture and API contract shared by both teams
└── .github/   CI workflows
```

## Working on this repository

- `main` is protected. Each sprint has an integration branch: `Sprint-2`, `Sprint-3`, ...
- Create your branch from the sprint branch: `feature/<name>-<feature>`,
  e.g. `feature/mawada-onboarding`.
- Open a pull request into the sprint branch; it is reviewed before merging.
- Only change files in your own part (`mobile/` or `backend/`) unless the team agrees.
- Commit messages: `feat(auth): add sign-in screen`, `fix(places): ...`.
- This repository is **public**: never commit `.env` files, API keys or passwords.

## Mobile app

See [mobile/README.md](mobile/README.md). Quick start:

```sh
cd mobile
flutter pub get
flutter gen-l10n
flutter run
```

## Backend

See [backend/README.md](backend/README.md).
