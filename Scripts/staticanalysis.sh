#!/usr/bin/env bash
# Static Analysis — clang-tidy + cppcheck (best-effort)
set -euo pipefail
set -x

# Prepare compile_commands.json (Ninja preferred)
builddir="build-sa"
mkdir -p "$builddir"
if command -v ninja >/dev/null 2>&1; then
  cmake -S . -B "$builddir" -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
else
  # Fallback to Makefiles (compile_commands may not be available)
  cmake -S . -B "$builddir" -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON || true
fi

# clang-tidy (best-effort; do not fail if absent)
if command -v clang-tidy >/dev/null 2>&1; then
  if [ -f "$builddir/compile_commands.json" ]; then
    mapfile -t tufs < <(ls -1 **/*.cpp 2>/dev/null | grep -v "/Thirdparty/" || true)
    for tu in "${tufs[@]}"; do
      echo "Analyzing $tu"
      clang-tidy "$tu" --quiet --warnings-as-errors="*" -p "$builddir" || true
    done
  else
    echo "No compile_commands.json; skipping clang-tidy analysis."
  fi
else
  echo "clang-tidy not installed; skipping."
fi

# cppcheck (best-effort; install hint)
if command -v cppcheck >/dev/null 2>&1; then
  cppcheck --enable=all --inconclusive --quiet --error-exitcode=0 --suppress=missingIncludeSystem \
    --template=gcc -I Source/Code --exclude=Source/Thirdparty . || true
else
  echo "cppcheck not installed; skipping (install via: apt-get install cppcheck or brew install cppcheck)."
fi
