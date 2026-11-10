# Contract: CI and deployment

**Spec**: FR-027 – FR-029, User Story 5 | **Research**: R10, R11

## `ci.yml` — pull requests into `develop` and `main`

| Step | Fails when |
| --- | --- |
| Checkout, set up Flutter (pinned exact version), cache pub | version not available |
| `flutter pub get` | resolution fails |
| `dart run build_runner build --delete-conflicting-outputs` then `git diff --exit-code` | generated Riverpod/Freezed/l10n files are stale |
| `dart run tool/gen_tokens.dart` then `git diff --exit-code` | tokens drifted from `tokens.json` |
| `flutter analyze --fatal-infos` | any analyzer or lint finding |
| `flutter test` | any unit, widget or guard test fails |
| `flutter build web --release --base-href /sprint-app/` | web build fails |

Permissions: `contents: read` only.

## `deploy.yml` — push to `develop`

1. Same steps as `ci.yml` (one job, `build`).
2. If `build` succeeds, a second job `deploy` uploads `build/web` with
   `actions/upload-pages-artifact` and publishes with `actions/deploy-pages`
   (environment `github-pages`; permissions `pages: write`, `id-token: write`).
3. If `build` fails, `deploy` does not run and the previous site stays live (SC-010).

## One-time repository settings (need Osman's approval, outward-facing)

- Pages source set to "GitHub Actions" (`gh api` on the Pages endpoint).
- After the first green run: add the `build` check as a required status check on `develop`
  and `main`, keeping the existing "pull request required, no force push" rules.

## Not in CI (decided in clarify, 2026-11-10)

Android and iOS builds, store signing, release publishing. They are checked by hand.

## Pins and hygiene

- Actions pinned to a major version tag at minimum (full commit SHA preferred for third-party).
- No secrets are needed for these workflows; none are to be added.
