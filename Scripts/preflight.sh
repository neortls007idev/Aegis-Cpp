#!/usr/bin/env bash
# Preflight — verify toolchains & submodules
set -euo pipefail
set -x

cmake --version

if command -v ninja >/dev/null 2>&1; then
  ninja --version
else
  echo "Ninja not present (ok if CMake uses Make)."
fi

git submodule status
echo "Preflight OK."
