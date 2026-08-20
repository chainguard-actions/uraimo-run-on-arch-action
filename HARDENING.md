<!-- markdownlint-disable -->

# Hardening Report: uraimo--run-on-arch-action/v3.0.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **uraimo--run-on-arch-action/v3.0.1** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple workflow run: blocks directly interpolate ${{ }} expressions, allowing script injection. Sub-rule (a): expressions from steps.*.outputs.* and matrix.* are interpolated directly into shell commands before the shell ever sees them.

basic-example.yml: `echo "The uname output was ${{ steps.runcmd.outputs.uname }}"`

simple.yml: `arch="${{ steps.build.outputs.env_arch }}"`, `distro="${{ steps.build.outputs.env_distro }}"`, `${{ matrix.arch }}`, `${{ matrix.distro }}` in run blocks.

test.yml: Numerous run: blocks interpolate ${{ steps.build.outputs.host_distro_info }}, ${{ steps.build.outputs.host_env_arch }}, ${{ steps.build.outputs.host_env_distro }}, ${{ matrix.arch }}, ${{ matrix.distro }}, ${{ steps.build.outputs.git_path }}, ${{ steps.build.outputs.host_shell_options }}, ${{ steps.build.outputs.arch }}, ${{ steps.build.outputs.distro_info }}, ${{ steps.build.outputs.env_arch }}, ${{ steps.build.outputs.env_distro }}, ${{ steps.build.outputs.shell_options }}, ${{ steps.build.outputs.volume_*_ls }}, ${{ steps.build.outputs.shebang }}, ${{ steps.build_custom_shell.outputs.shebang }} directly into shell commands.

Locations:

- `.github/workflows/basic-example.yml:24`
- `.github/workflows/simple.yml:55`
- `.github/workflows/test.yml:107`
- `.github/workflows/test.yml:117`
- `.github/workflows/test.yml:126`
- `.github/workflows/test.yml:136`
- `.github/workflows/test.yml:145`
- `.github/workflows/test.yml:155`
- `.github/workflows/test.yml:165`
- `.github/workflows/test.yml:175`
- `.github/workflows/test.yml:195`
- `.github/workflows/test.yml:225`
- `.github/workflows/test.yml:245`

### unpinned-uses (severity: high)

Multiple workflow files reference actions using mutable tags or branch names instead of full 40-character commit SHAs, making them vulnerable to supply-chain attacks.

Failing references:
- advanced-example.yml: `actions/checkout@v3`
- basic-example.yml: `actions/checkout@v3`, `uraimo/run-on-arch-action@master`
- floating-tag.yml: `actions/checkout@v3`, `fregante/setup-git-user@v1`
- issue160.yml: `uraimo/run-on-arch-action@master`
- simple.yml: `actions/checkout@v3`
- test.yml: `actions/checkout@v3`

Locations:

- `.github/workflows/advanced-example.yml:29`
- `.github/workflows/basic-example.yml:9`
- `.github/workflows/basic-example.yml:10`
- `.github/workflows/floating-tag.yml:12`
- `.github/workflows/floating-tag.yml:13`
- `.github/workflows/issue160.yml:13`
- `.github/workflows/simple.yml:16`
- `.github/workflows/test.yml:34`

### missing-permissions (severity: medium)

Five workflow files have no top-level `permissions:` key and no job-level `permissions:` keys on any job. Without explicit permissions, workflows run with the default token permissions (which may be read/write depending on repository settings), violating the principle of least privilege.

Locations:

- `.github/workflows/advanced-example.yml:1`
- `.github/workflows/basic-example.yml:1`
- `.github/workflows/floating-tag.yml:1`
- `.github/workflows/simple.yml:1`
- `.github/workflows/test.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all three finding types across the affected workflow files:

1. script-injection: Moved all ${{ steps.*.outputs.* }} and ${{ matrix.* }} expressions from run: shell blocks into env: blocks in basic-example.yml, simple.yml, and test.yml. All 13 affected locations now use plain environment variable references ($VAR_NAME) in shell scripts.

2. unpinned-uses: Pinned all mutable action references to full 40-char SHAs:
   - actions/checkout@v3 → @a37ce9120846195fa4ece8f58b268e6043cb2f26 (advanced-example.yml, basic-example.yml, floating-tag.yml, simple.yml, test.yml)
   - uraimo/run-on-arch-action@master → @460cb8e6d9f726a588fc9b5e681c8a6cab09ae41 (basic-example.yml, issue160.yml)
   - fregante/setup-git-user@v1 → @2e28d51939d2a84005a917d2f844090637f435f8 (floating-tag.yml)

3. missing-permissions: Added top-level permissions blocks to all five affected files:
   - advanced-example.yml, basic-example.yml, simple.yml, test.yml: contents: read
   - floating-tag.yml: contents: write (required to push tags)

Note: issue160.yml already had permissions: contents: read and actions/checkout was already pinned; only the uraimo/run-on-arch-action needed pinning.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in both .github/workflows/advanced-example.yml (line 71) and .github/workflows/test.yml (line 85). In each file, the `${{ matrix.distro }}` expression was directly interpolated inside the `install:` shell script block passed as an action input. Fixed by adding `DISTRO: ${{ matrix.distro }}` to the `env:` input block (which makes it available as an environment variable inside the container) and replacing `case "${{ matrix.distro }}" in` with `case "$DISTRO" in` in the install script.

