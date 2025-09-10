# Contributing to Aegis-Cpp

Thank you for contributing to **Aegis-A-UE-GUI-Toolbelt-for-UE-CLI**. This guide is copy‑pasteable and authoritative.

---

## Repository Structure

The repository includes (authoritative high‑level view):

```
/Bin
/ Distro
/ Source
  / Code
    / Core (Public, Private)
    / DataStructures (Public, Private)
    / Memory (Public, Private)
    / Threading (Public, Private)
    / UI (Public, Private)
  / Thirdparty
    / QtBase
    / imgui
    / tinyxml2
/ Tests
  / Unit
  / Functional
```

A `Tests` directory exists at the root to hold **unit** and **functional** tests in subdirectories by feature.

---

## Hardline Rules (must follow)

- **File Naming:** All files in **PascalCase** (e.g., `TaskRunner.h`, `TaskRunner.cpp`).
- **Functions:** **PascalCase** (e.g., `StartProcess`, `ResolveToolPath`).  
- **Data Members:** `m_` + `CamelCase` (e.g., `m_ExitCode`).  
- **Global Singletons:** `g_` + `PascalCase` (rare; require approval).  
- **Constants:** `ALL_CAPS` with underscores.
- **Bracing & Conditionals:** **Allman** style; braces required for all blocks.
- **Pointers:** Initialize with `nullptr`; every `new` must have a corresponding `delete` in the same ownership scope.
- **Headers Included:** Only `<stdio.h>` by default. No other standard or third‑party headers without prior maintainer approval (or those included internally by approved third‑party code).
- **No Exceptions:** Do **not** use `try/catch` without explicit, file‑scoped approval.
- **No `using namespace` or `using` aliases** anywhere.
- **UI Isolation:** Do not call Qt/ImGui directly from features; use the `UIBackend` interface.
- **Long‑running tasks:** Use `TaskRunner`; never block the UI.
- **Preview Command:** Every action must provide an exact, copyable CLI preview before execution.
- **Doxygen + Banner Blocks:** Wrap header sections and each implementation method with the standard banners shown in `CODING_STANDARDS.md` §3.

---

## Branching

Create topic branches from `main` (or the relevant feature branch):

```
feat/<Area>-<ShortDesc>
fix/<Area>-<ShortDesc>
chore/<Area>-<ShortDesc>
docs/<Area>-<ShortDesc>
test/<Area>-<ShortDesc>
```

---

## Commits

Use clear, atomic messages. Examples:

```
feat(Core): Add TaskRunner::Cancel()
fix(UI): Prevent blocking on long trace import
test(Functional): Dry-run tests for UAT BuildCookRun
docs(Standards): Add pointer ownership examples
```

---

## Tests

- Add **Unit** tests for functions/classes in `/Tests/Unit/<Area>`.
- Add **Functional** tests in `/Tests/Functional/<Feature>` for end‑to‑end flows (prefer UE CLI dry‑runs).
- PRs without tests will not be merged unless documentation‑only or maintainer‑approved hotfix.

---

## Build Locally

Windows (NMake example):

```bat
:: configure
cmake -S . -B build -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release
:: build
cmake --build build --config Release
```

Artifacts should go to `/Bin` or `/Distro` (git‑ignored).

---

## Pull Request Checklist

- [ ] Matches **CODING_STANDARDS.md** (names, layout, bracing, ownership)
- [ ] No disallowed headers; only `<stdio.h>` used by default
- [ ] No exceptions; no `using namespace` / `using` aliases
- [ ] Pointers use `nullptr`; `new` paired with `delete`
- [ ] Tests added/updated and passing locally
- [ ] Docs updated (README, AGENTS.md, CODING_STANDARDS.md if conventions changed)
- [ ] No secrets; licenses preserved; `THIRD_PARTY_NOTICES.md` updated if needed
- [ ] Screenshots/CLI logs for feature behavior and **Preview Command**

---

## Third‑Party Submodules

- **imgui** — MIT
- **qtbase** — LGPLv3/GPLv3/commercial (ensure compliance for chosen mode)
- **tinyxml2** — zlib

Do not modify submodule sources directly. If patching is required, add a patch under `/Source/Thirdparty/patches` with a README.

---

## Code of Conduct

By contributing, you agree to abide by `CODE_OF_CONDUCT.md`.

---

## Maintainer Contact

Security or license concerns: please contact the maintainer directly instead of filing a public issue.
