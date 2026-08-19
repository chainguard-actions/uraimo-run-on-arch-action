<!-- markdownlint-disable -->

# Hardening Report: uraimo--run-on-arch-action/v3.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **uraimo--run-on-arch-action/v3.2.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple workflow files reference GitHub Actions using mutable tags or branch names instead of pinned 40-character commit SHAs, making them vulnerable to supply-chain attacks.

- advanced-example.yml: `uses: actions/checkout@v6`
- floating-tag.yml: `uses: actions/checkout@v6`, `uses: fregante/setup-git-user@v2`
- issue160.yml: `uses: actions/checkout@v6`, `uses: uraimo/run-on-arch-action@master`
- simple.yml: `uses: actions/checkout@v6`
- test.yml: `uses: actions/checkout@v6`

Locations:

- `.github/workflows/advanced-example.yml:19`
- `.github/workflows/floating-tag.yml:13`
- `.github/workflows/floating-tag.yml:14`
- `.github/workflows/issue160.yml:10`
- `.github/workflows/issue160.yml:11`
- `.github/workflows/simple.yml:16`
- `.github/workflows/test.yml:29`

### missing-permissions (severity: medium)

The following workflow files have no top-level `permissions:` key and no job-level `permissions:` keys on any job. Without explicit permissions, the GITHUB_TOKEN is granted broad default permissions (read/write on most scopes), violating the principle of least privilege.

- test.yml: no permissions block at top-level or job-level
- simple.yml: no permissions block at top-level or job-level
- advanced-example.yml: no permissions block at top-level or job-level
- floating-tag.yml: no permissions block at top-level or job-level

Locations:

- `.github/workflows/test.yml:1`
- `.github/workflows/simple.yml:1`
- `.github/workflows/advanced-example.yml:1`
- `.github/workflows/floating-tag.yml:1`

### script-injection (severity: high)

Multiple `run:` blocks in workflow files directly interpolate `${{ ... }}` expressions (rule a), including `steps.*.outputs.*` and `matrix.*` values. These values flow through YAML template substitution before the shell processes them, allowing an attacker who controls the output values or matrix inputs to inject arbitrary shell commands.

Examples in test.yml:
- `arch="${{ steps.build.outputs.host_arch }}"` — step output interpolated directly in shell
- `distro_info="${{ steps.build.outputs.host_distro_info }}"` — step output interpolated directly
- `case "${{ matrix.arch }}" in` — matrix value interpolated directly in case statement
- `case "${{ matrix.distro }}" in` — matrix value interpolated directly in case statement
- `*) expected_arch="${{ matrix.arch }}" ;;` — matrix value in case branch
- `*) distro_key="${{ matrix.distro }}" ;;` — matrix value in case branch
- `install: | case "${{ matrix.distro }}" in` — matrix value in install script case statement

Examples in simple.yml:
- `arch="${{ steps.build.outputs.env_arch }}"` — step output interpolated directly
- `distro="${{ steps.build.outputs.env_distro }}"` — step output interpolated directly
- `test "$arch" == "${{ matrix.arch }}"` — matrix value interpolated directly
- `test "$distro" == "${{ matrix.distro }}"` — matrix value interpolated directly

All these should be routed through env: variables and double-quoted in the shell script.

Locations:

- `.github/workflows/test.yml:97`
- `.github/workflows/test.yml:102`
- `.github/workflows/test.yml:107`
- `.github/workflows/test.yml:108`
- `.github/workflows/test.yml:116`
- `.github/workflows/test.yml:122`
- `.github/workflows/test.yml:127`
- `.github/workflows/test.yml:133`
- `.github/workflows/test.yml:140`
- `.github/workflows/test.yml:148`
- `.github/workflows/test.yml:155`
- `.github/workflows/test.yml:163`
- `.github/workflows/test.yml:170`
- `.github/workflows/test.yml:178`
- `.github/workflows/test.yml:185`
- `.github/workflows/simple.yml:57`
- `.github/workflows/simple.yml:62`
- `.github/workflows/simple.yml:64`
- `.github/workflows/simple.yml:67`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, missing-permissions, script-injection

**Notes:**

Fixed all three findings across 5 workflow files:

1. unpinned-uses: Pinned actions/checkout@v6 to SHA d23441a48e516b6c34aea4fa41551a30e30af803, fregante/setup-git-user@v2 to SHA 024bc0b8e177d7e77203b48dab6fb45666854b35, and uraimo/run-on-arch-action@master to SHA 460cb8e6d9f726a588fc9b5e681c8a6cab09ae41.

2. missing-permissions: Added 'permissions: contents: read' to test.yml, simple.yml, and advanced-example.yml. Added 'permissions: contents: write' to floating-tag.yml (which needs write access to push tags).

3. script-injection: In test.yml and simple.yml, moved all ${{ steps.*.outputs.* }} and ${{ matrix.* }} expressions from run: blocks into env: blocks, with shell scripts referencing the environment variables. The install: block in test.yml was updated to use $env_distro (available via the action's env: input) instead of the interpolated matrix value.

