#!/usr/bin/env bash
# Package distro artifacts
set -euo pipefail
set -x

mkdir -p Distro
if [ -d "Bin" ]; then cp -r Bin Distro/Bin || true; fi
if [ -f "LICENSE" ]; then cp LICENSE Distro/ || true; fi
if [ -f "THIRD_PARTY_NOTICES.md" ]; then cp THIRD_PARTY_NOTICES.md Distro/ || true; fi

osname="$(uname -s)"
if [[ "$osname" == "MINGW"* || "$osname" == "MSYS"* || "$osname" == "CYGWIN"* ]]; then
  # On Git Bash for Windows, prefer 7z if available
  if command -v 7z >/dev/null 2>&1; then
    7z a Aegis-Cpp-local-win64.zip ./Distro/*
  else
    tar -czf Aegis-Cpp-local-windows.tar.gz Distro
  fi
elif [[ "$osname" == "Darwin" ]]; then
  tar -czf Aegis-Cpp-local-macos.tar.gz Distro
else
  tar -czf Aegis-Cpp-local-linux.tar.gz Distro
fi

echo "Package OK."
