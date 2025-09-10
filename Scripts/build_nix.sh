#!/usr/bin/env bash
# Build (Linux/macOS → Ninja) with verbose logging
set -euo pipefail
set -x

mkdir -p build
cd build
if command -v ninja >/dev/null 2>&1; then
  cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=ON -DAEGIS_WITH_QT=ON -DAEGIS_WITH_IMGUI=ON ..
  cmake --build . --config Release --verbose
else
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=ON -DAEGIS_WITH_QT=ON -DAEGIS_WITH_IMGUI=ON ..
  cmake --build . --config Release --verbose
fi

echo "Build OK."
