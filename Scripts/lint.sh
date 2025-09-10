#!/usr/bin/env bash
# Lint — policy checks for Aegis-Cpp
set -euo pipefail
set -x

shopt -s globstar || true
files=$(ls -1 **/*.hpp **/*.cpp 2>/dev/null || true)
if [ -z "${files}" ]; then
  echo "No .hpp/.cpp files found; skipping lint."
  exit 0
fi

# Disallow 'using namespace' and using-aliases
if grep -RInE "^[[:space:]]*using[[:space:]]+namespace[[:space:]]+" $files; then
  echo "Found 'using namespace' (forbidden)."
  exit 1
fi

# Disallow try/catch unless explicitly whitelisted with AEGIS_EXCEPTION_APPROVED
if grep -RInE "^[[:space:]]*try[[:space:]]*\{|catch[[:space:]]*\(" $files | grep -v "AEGIS_EXCEPTION_APPROVED"; then
  echo "Found try/catch without AEGIS_EXCEPTION_APPROVED."
  exit 1
fi

# Forbid project local .h includes; enforce .hpp (ignore Thirdparty path)
if grep -RInE "#[[:space:]]*include[[:space:]]*\".*\.h\"" -- **/*.cpp **/*.hpp 2>/dev/null | grep -v "/Thirdparty/"; then
  echo "Found local includes of .h; use .hpp instead."
  exit 1
fi

# Forbid common C++ std headers (allow only <stdio.h>); ignore Thirdparty
if grep -RInE "#[[:space:]]*include[[:space:]]*<((string|vector|memory|thread|mutex|chrono|filesystem|map|unordered_map|set|iostream|sstream|iomanip|future|optional|variant|any|type_traits|limits|array|algorithm|functional|utility|bitset|random|regex|tuple|list|deque|queue|stack)\b.*)>" -- **/*.hpp **/*.cpp 2>/dev/null | grep -v "/Thirdparty/"; then
  echo "Found forbidden C++ std headers; only <stdio.h> is allowed by default."
  exit 1
fi

echo "Lint checks passed."
