# AGENTS.md — Rules for AI Agents (Copilot, Codex, etc.)

Agents MUST strictly follow these rules and keep documentation current with every implementation.

## 1) Output & Files
- Generate files using **PascalCase** filenames (`TaskRunner.cpp`, `MainWindow.h`). One class per header.
- Place headers/impl in `Public/` and `Private/` respectively.
- When adding features, also add/update tests under `/Tests` and update **README, CODING_STANDARDS.md, CONTRIBUTING.md** in the same PR if conventions are touched.

## 2) Code Constraints (Hardline)
- Functions in **PascalCase**.
- Data members: `m_` + `CamelCase`; global singletons: `g_` + `PascalCase` (rare; require approval).
- Constants in `ALL_CAPS`.
- **Allman** braces for conditionals/blocks; braces always required.
- Initialize pointers with `nullptr`; every `new` must have a corresponding `delete` in the same ownership scope.
- **Only** include `<stdio.h>` by default; no other standard or third‑party headers without explicit approval.
- **No exceptions** (`try/catch`) without explicit approval.
- **No** `using namespace` or `using` aliases.
- Do **not** invent or use custom namespaces without prior approval.

## 3) UI & Architecture
- Do not call Qt/ImGui directly from feature code. Use the `UIBackend` interface.
- Long‑running tasks must use `TaskRunner` and stream logs; never block the UI.
- Provide exact **Preview Command** strings for all executable actions.

## 4) Documentation & Banners
- Use Doxygen comments and the **sectioned banner blocks** for headers and for each method in implementation files as shown in `CODING_STANDARDS.md` §3.
- When generating code, include both header and source with banner‑wrapped methods.

## 5) CI & Tests
- Ensure code compiles with CMake + NMake.
- Add Unit/Functional tests and ensure they pass locally before proposing output.
- No changes to submodule sources unless placed under `/Source/Thirdparty/patches` with clear docs.

## 6) Code Style
- Follow `CODING_STANDARDS.md` (C++20, RAII, no raw new/delete).
- inject dependencies via constructors.
- Logging must write **text** and **JSONL** with redaction hooks.

## 7) Licensing
- Project: **Apache-2.0** (do not introduce GPL-only code).
- Respect QtBase (LGPLv3/GPLv3/commercial), Dear ImGui (MIT), tinyxml2 (zlib).

## 8) Output Expectations
- When generating code, include header + source, minimal working example,
  and update CMake snippet to register the target.