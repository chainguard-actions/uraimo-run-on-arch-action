<!-- markdownlint-disable -->

# Hardening Report: uraimo--run-on-arch-action/v3.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **uraimo--run-on-arch-action/v3.3** was hardened automatically. 0 finding(s) were identified and resolved across 1 iteration(s).

## Iteration Notes

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

test.sh:15-16: replaced the bash array `good=("${@:2}")` / `"${good[@]}"` with `shift` followed by `printf '<%s>\n' "$@"`. It still drops the first positional argument and prints the rest with their argument boundaries intact, and it works under the #!/bin/sh shebang. test.sh is a standalone demo script that action.yml and the other scripts never reference. As the gate asked, nothing else in it was changed.

