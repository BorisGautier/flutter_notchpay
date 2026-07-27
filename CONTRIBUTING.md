# Contributing to flutter_notchpay

Thanks for taking the time to contribute! This document covers the project's
branching model and the checks your PR needs to pass.

## Branching model

- **`main`** is the stable, released branch. It only ever moves forward via
  a merge from `dev`, and every commit on it corresponds to a published (or
  about to be published) version.
- **`dev`** is the integration branch. All feature work, fixes, and
  dependency updates (including Dependabot) target `dev`.
- Work on a feature branch cut from `dev` (e.g. `feat/card-redirect`,
  `fix/phone-validation`), then open a PR **against `dev`**.
- Releases are cut by merging `dev` into `main` and pushing a `vX.Y.Z` tag,
  which triggers [`release.yml`](.github/workflows/release.yml).
- `main` is a protected branch (required reviews + passing CI). Labels are
  defined declaratively in [`.github/labels.yml`](.github/labels.yml) and
  synced automatically. If you have repository admin access, see
  [`.github/SETUP.md`](.github/SETUP.md) for the one-time setup
  (branch protection, pub.dev publishing, Codecov).

## Getting set up

```sh
git clone https://github.com/BorisGautier/flutter_notchpay.git
cd flutter_notchpay
flutter pub get

cd example
flutter pub get
dart run build_runner build -d   # generates the example's local database code
```

## Before opening a PR

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

All three run in CI ([`ci.yml`](.github/workflows/ci.yml)) and must pass.
`flutter analyze` includes `public_member_api_docs` — every public class,
method, and field needs a dartdoc comment (see existing code for the
expected style).

If you touched `example/`, also run its own `flutter analyze` / `flutter
test` (see the example's [README](example/README.md)).

To exercise the full checkout flow on a device/emulator:

```sh
flutter test integration_test
```

## Commit / PR conventions

- Keep PRs focused; unrelated cleanups belong in a separate PR.
- Update `CHANGELOG.md` under `## [Unreleased]` for any user-facing change.
- Update dartdoc comments and the README if you change public API.
- Add or update tests for the behavior you're changing — PRs without test
  coverage for new logic will be asked for it.
- Fill in the PR template's checklist.

## Reporting bugs / requesting features

Use the issue templates. For security vulnerabilities, see
[SECURITY.md](SECURITY.md) instead of opening a public issue.

## Code style

- Follow the lints enforced by `analysis_options.yaml` (`flutter_lints` plus
  a few stricter rules). `flutter analyze` is the source of truth.
- Prefer small, composable widgets/functions over large ones.
- Keep the public API surface (`lib/flutter_notchpay.dart`) intentional —
  new files under `lib/src/` should only be exported there if they're meant
  to be part of the public API.
