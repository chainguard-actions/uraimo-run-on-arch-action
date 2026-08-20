<!-- markdownlint-disable -->

# Hardening Report: uraimo--run-on-arch-action/v3.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **uraimo--run-on-arch-action/v3.1.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks directly interpolate GitHub Actions expressions (`${{ steps.build.outputs.* }}` and `${{ matrix.* }}`) inside shell commands. This violates rule (a): any `${{ ... }}` expression inside a `run:` block is a script-injection risk because the value is substituted by the YAML template engine before the shell ever sees it, allowing an attacker to inject shell metacharacters. Examples include: `arch="${{ steps.build.outputs.host_arch }}"`, `case "${{ matrix.distro }}" in`, `test "$arch" == "${{ matrix.arch }}"`.

Locations:

- `.github/workflows/test.yml:72`
- `.github/workflows/test.yml:80`
- `.github/workflows/test.yml:87`
- `.github/workflows/test.yml:95`
- `.github/workflows/test.yml:103`
- `.github/workflows/test.yml:113`
- `.github/workflows/test.yml:122`
- `.github/workflows/test.yml:131`
- `.github/workflows/test.yml:143`
- `.github/workflows/test.yml:152`
- `.github/workflows/test.yml:163`
- `.github/workflows/test.yml:175`
- `.github/workflows/test.yml:196`
- `.github/workflows/test.yml:210`
- `.github/workflows/simple.yml:57`
- `.github/workflows/simple.yml:62`
- `.github/workflows/simple.yml:65`
- `.github/workflows/simple.yml:68`

### unpinned-uses (severity: high)

Multiple workflow files reference external actions using mutable tags or branch names instead of full 40-character commit SHAs. This exposes the workflow to supply-chain attacks if the referenced tag or branch is moved or overwritten. Failing references: `actions/checkout@v4` (tag), `fregante/setup-git-user@v2` (tag), `uraimo/run-on-arch-action@master` (branch).

Locations:

- `.github/workflows/test.yml:28`
- `.github/workflows/simple.yml:16`
- `.github/workflows/advanced-example.yml:22`
- `.github/workflows/floating-tag.yml:14`
- `.github/workflows/floating-tag.yml:15`
- `.github/workflows/issue160.yml:13`
- `.github/workflows/issue160.yml:14`

### missing-permissions (severity: medium)

Four workflow files have no top-level `permissions:` key and no job-level `permissions:` key on any job. Without explicit permissions, workflows run with the default token permissions (which may be `write-all` depending on repository settings), granting unnecessary access. The affected files are: test.yml, simple.yml, advanced-example.yml, and floating-tag.yml. (issue160.yml correctly declares `permissions: contents: read`.)

Locations:

- `.github/workflows/test.yml:1`
- `.github/workflows/simple.yml:1`
- `.github/workflows/advanced-example.yml:1`
- `.github/workflows/floating-tag.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all three findings across 5 workflow files:

1. script-injection: Moved all ${{ steps.build.outputs.* }} and ${{ matrix.* }} expressions from run: blocks into step-level env: blocks in test.yml and simple.yml. Shell scripts now reference plain $ENV_VAR names. The install: action input that used ${{ matrix.distro }} was changed to use $env_distro (already available via the action's env: input).

2. unpinned-uses: Pinned all action references to full 40-char SHAs: actions/checkout@v4 → @11d5960a326750d5838078e36cf38b85af677262, fregante/setup-git-user@v2 → @024bc0b8e177d7e77203b48dab6fb45666854b35, uraimo/run-on-arch-action@master → @460cb8e6d9f726a588fc9b5e681c8a6cab09ae41. Applied to test.yml, simple.yml, advanced-example.yml, floating-tag.yml, and issue160.yml.

3. missing-permissions: Added permissions: contents: read to test.yml, simple.yml, and advanced-example.yml. Added permissions: contents: write to floating-tag.yml (required for git push/tag operations). issue160.yml already had correct permissions.

