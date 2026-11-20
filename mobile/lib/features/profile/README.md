# Profile and settings

**Status:** Sprint 2, built (mock and remote).
**Owner:** Person B (Culture & Community).
**Contract:** API Contract v0.2, section "Person B — Profile & Settings".

**Screens:** Profile (photo with edit badge, stats, saved content, contributions), My saved content (View all, with Places / Stories filters), Settings (language, notifications, location, interests), Log out and Delete account sheets.

**Routes:** /profile, /profile/saved, /profile/settings, /profile/settings/interests, /profile/soon/:page (registered in `profile_routes.dart`).

**Endpoints:** GET /users/me/profile, PUT /users/me/avatar, GET /saved, GET and PATCH /users/settings, POST /users/me/deletion-request; GET /users/preferences (in personalization); POST /auth/logout (in auth).

**Not built yet (no design):** Edit profile, Change password, Email & contact, Privacy settings, Account security, Help center, Terms & privacy open a "Coming soon" page. A saved place opens nothing until Place details (Person A) exists.
