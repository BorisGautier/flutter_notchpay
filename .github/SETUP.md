# Repository setup (maintainers only)

This project's code, CI workflows, dependabot config, issue/PR templates,
and labels are all defined declaratively in this repository. A handful of
things, however, require **repository admin access on GitHub** and can't be
done from a pull request — this is the one-time checklist for whoever has
that access.

## 1. Create the `main` and `dev` branches

The repository ships with a single working branch. Once the initial PR is
merged:

```sh
git checkout -b main <initial-branch>
git push -u origin main

git checkout -b dev main
git push -u origin dev
```

Set **`main`** as the repository's default branch in
**Settings → General → Default branch**.

## 2. Protect `main`

**Settings → Branches → Add branch protection rule**, pattern `main`:

- ✅ Require a pull request before merging
  - ✅ Require approvals (1+)
- ✅ Require status checks to pass before merging
  - Select: `Analyze & test (package)`, `Analyze & test (example app)`,
    `Secret scan` (from `ci.yml`)
- ✅ Require branches to be up to date before merging
- ✅ Require conversation resolution before merging
- ✅ Do not allow bypassing the above settings (include administrators)
- ⬜ Do **not** allow force pushes or branch deletion

`dev` can stay unprotected (or with a lighter rule) since it's the
integration branch Dependabot and contributors push to directly.

## 3. Enable labels

The first push to `main` that includes `.github/labels.yml` triggers
[`labels.yml`](workflows/labels.yml) automatically. To run it immediately
without waiting for that push, go to **Actions → Sync labels → Run
workflow**.

## 4. Enable pub.dev automated publishing

[`release.yml`](workflows/release.yml) publishes using pub.dev's OIDC
"automated publishing" — no long-lived credentials are stored in this repo.
One-time setup:

1. Publish the package manually once from a trusted machine
   (`dart pub publish`) so it exists on pub.dev, if it doesn't already.
2. Go to https://pub.dev/packages/flutter_notchpay/admin (requires being
   listed as a package uploader).
3. Under **Automated publishing**, enable GitHub Actions publishing and set:
   - Repository: `BorisGautier/flutter_notchpay`
   - Tag pattern: `v{{version}}`
   - Workflow filename: `release.yml`
4. From then on, pushing a tag matching `v[0-9]+.[0-9]+.[0-9]+*` (e.g.
   `v0.2.0`) runs the tests and, if they pass, publishes automatically.

## 5. (Optional) Codecov

`ci.yml` uploads coverage via `codecov/codecov-action` and degrades
gracefully (`continue-on-error: true`) if unconfigured. To get the badge and
PR coverage comments working:

1. Add the repository at https://app.codecov.io.
2. Add its upload token as a repository secret named `CODECOV_TOKEN`
   (**Settings → Secrets and variables → Actions**).

## 6. (Optional) Branding assets

If/when official NotchPay logo files are added under `doc/branding/`,
update the README's header image and this repo's social preview image
(**Settings → General → Social preview**) accordingly. Confirm usage rights
with NotchPay before distributing their mark in a third-party repository.
