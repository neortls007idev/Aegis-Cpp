#!/usr/bin/env bash
# Convenience runner: Lint → Preflight → Static Analysis → Build → Package
set -euo pipefail
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

"${DIR}/lint.sh"
"${DIR}/preflight.sh"
"${DIR}/staticanalysis.sh"

# Build per-OS
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     "${DIR}/build_nix.sh";;
    Darwin*)    "${DIR}/build_nix.sh";;
    *)          echo "On Windows, run build_win.bat";;
esac

"${DIR}/package.sh"
