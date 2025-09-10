# Aegis-Cpp Coding Standards (Hardline)

These standards are **strict** to ensure determinism, portability, and auditability.

> Scope
> - Cross‑platform C/C++ toolbelt around Unreal Engine CLIs
> - Build: CMake + NMake on Windows (multi‑project solutions allowed)
> - UI backends: Qt **or** Dear ImGui via a thin wrapper
> - Targets: static lib, dynamic lib, CLI apps
> - Tests: live in `/Tests` with per‑feature subfolders (Unit + Functional)

---

## 1) Repository Layout (authoritative)

```
/Bin
/ Distro
/ Source
  / Code
    / Core
      / Private
      / Public
    / DataStructures
      / Private
      / Public
    / Memory
      / Private
      / Public
    / Threading
      / Private
      / Public
    / UI
      / Private
      / Public
  / Thirdparty
    / QtBase
    / imgui
    / tinyxml2
/ Tests
  / Unit
  / Functional
```

_Changes to layout require maintainer approval._

---

## 2) Naming, Files, and Formatting

- **Filenames:** `PascalCase` with `.hpp` / `.cpp`. One class per header.
- **Classes:** `PascalCase` (e.g., `TaskRunner`, `EnvDoctor`).
- **Functions/Methods:** `PascalCase` (e.g., `StartProcess`, `ResolveToolPath`).
- **Local Variables:** `camelCase` (e.g., `rowCount`, `tracePath`).
- **Data Members:** prefix `m_` + `CamelCase` (e.g., `m_ExitCode`, `m_DeviceList`).  
- **Global Singletons:** prefix `g_` + `PascalCase` (rare; must be approved).
- **Constants:** `ALL_CAPS` with underscores (e.g., `MAX_LOG_BYTES`, `DEFAULT_PORT`).
- **Braces & Conditionals:** **Allman** style (opening braces on their own line).  
  `if (condition)` → brace on the next line. Always use braces, even for single statements.
- **Pointers:** Always initialize with `nullptr`. Every `new` must have a corresponding `delete` in the same ownership scope (unless delegated to an approved owner). Prefer avoiding raw pointers; if used, document ownership explicitly in comments.
- **Headers:** Use `#pragma once`. Follow the **sectioned comment blocks** and **Doxygen‑style** comment conventions below.

---

## 3) Doxygen & Sectioned Comment Blocks (Authoritative Pattern)

**Header file sections** must be grouped with banner comments and Doxygen annotations. Example for a math class:

```cpp
#pragma once
#include <stdio.h>  /* Only standard header allowed by default */

/**
 * @brief 2D vector with basic arithmetic.
 * @note  No STL or exceptions; follows project hardline rules.
 */
class Vec2
{
public:
    //--------------------------------------------------------------------------------------------------------------------------------------------
    // CONSTRUCTION/DESTRUCTION
    //--------------------------------------------------------------------------------------------------------------------------------------------

    Vec2();                                              ///< DEFAULT CONSTRUCTOR (does nothing)
    ~Vec2();                                             ///< DESTRUCTOR (does nothing)
    Vec2( const Vec2& copyFrom );                        ///< COPY CONSTRUCTOR (from another Vec2)
    explicit Vec2( float initialX, float initialY );     ///< EXPLICIT CONSTRUCTOR (float X,Y)
    explicit Vec2( int initialX, int initialY );         ///< EXPLICIT CONSTRUCTOR (int X,Y)

    //--------------------------------------------------------------------------------------------------------------------------------------------
    // OPERATORS (CONST)
    //--------------------------------------------------------------------------------------------------------------------------------------------

    bool        operator==( const Vec2& compare ) const;         ///< vec2 == vec2
    bool        operator!=( const Vec2& compare ) const;         ///< vec2 != vec2
    const Vec2  operator+( const Vec2& vecToAdd ) const;         ///< vec2 + vec2
    const Vec2  operator-( const Vec2& vecToSubtract ) const;    ///< vec2 - vec2
    const Vec2  operator-() const;                               ///< unary negation
    const Vec2  operator*( float uniformScale ) const;           ///< vec2 * float
    const Vec2  operator*( const Vec2& vecToMultiply ) const;    ///< vec2 * vec2
    const Vec2  operator/( float inverseScale ) const;           ///< vec2 / float

    //--------------------------------------------------------------------------------------------------------------------------------------------
    // OPERATORS (SELF-MUTATING / NON-CONST)
    //--------------------------------------------------------------------------------------------------------------------------------------------

    void        operator+=( const Vec2& vecToAdd );              ///< vec2 += vec2
    void        operator-=( const Vec2& vecToSubtract );         ///< vec2 -= vec2
    void        operator*=( const float uniformScale );          ///< vec2 *= float
    void        operator/=( const float uniformDivisor );        ///< vec2 /= float
    void        operator=( const Vec2& copyFrom );               ///< vec2 = vec2

    //--------------------------------------------------------------------------------------------------------------------------------------------
    // DATA
    //--------------------------------------------------------------------------------------------------------------------------------------------

    float m_X = 0.0f;
    float m_Y = 0.0f;
};
```

**Implementation file banners** must wrap each method, like:

```cpp
//--------------------------------------------------------------------------------------------------------------------------------------------
Vec2::Vec2()
{
    // does nothing
}
//--------------------------------------------------------------------------------------------------------------------------------------------
Vec2::~Vec2()
{
    // does nothing
}
//--------------------------------------------------------------------------------------------------------------------------------------------
const Vec2 Vec2::operator+( const Vec2& vecToAdd ) const
{
    return Vec2( m_X + vecToAdd.m_X, m_Y + vecToAdd.m_Y );
}
//--------------------------------------------------------------------------------------------------------------------------------------------
const Vec2 Vec2::operator-( const Vec2& vecToSubtract ) const
{
    return Vec2( m_X - vecToSubtract.m_X, m_Y - vecToSubtract.m_Y );
}
//--------------------------------------------------------------------------------------------------------------------------------------------
const Vec2 Vec2::operator-() const
{
    return Vec2( -m_X, -m_Y );
}
//--------------------------------------------------------------------------------------------------------------------------------------------
const Vec2 Vec2::operator*( float uniformScale ) const
{
    return Vec2( m_X * uniformScale, m_Y * uniformScale );
}
//--------------------------------------------------------------------------------------------------------------------------------------------
const Vec2 Vec2::operator*( const Vec2& vecToMultiply ) const
{
    return Vec2( m_X * vecToMultiply.m_X, m_Y * vecToMultiply.m_Y );
}
//--------------------------------------------------------------------------------------------------------------------------------------------
```

---

## 4) Language & Library Rules (Critical)

1. **Standard/third‑party headers are forbidden** unless explicitly approved.  
   - Allowed by default: **`<stdio.h>` only**.  
   - If a third‑party library (Qt, ImGui, tinyxml2) internally uses the STL, that’s their concern; your code must **not** include STL headers directly.
2. **Exceptions:** Do **not** use `try/catch` without explicit maintainer approval for the file and reason. Prefer explicit error codes.
3. **No `using namespace` or `using` aliases** anywhere. Always write fully qualified names if needed.
4. **Memory & Ownership:** Every `new` must pair with a corresponding `delete`. Prefer stack objects. Document ownership.
5. **Error Handling Pattern:** Functions return `int` (0 = success) or a small POD with an `int Error`. Diagnostics go to the logging layer (text + JSONL).

---

## 5) Architecture Contracts (UI‑Agnostic)

- UI must be isolated behind a `UIBackend` interface. Implementations: `QtUiBackend`, `ImGuiUiBackend`.
- Feature pages depend **only** on `UIBackend` and core modules—never on Qt/ImGui directly.
- Long‑running tasks route through `TaskRunner`; **never block** the UI thread.
- Every action must expose the exact **Preview Command** string before execution (parity with Python app).

---

## 6) Public vs Private

- API headers live in `Public/`; implementations in `Private/`.
- External targets link only against `Public/` headers.

---

## 7) Build & Artifacts

- CMake generates NMake builds on Windows. Treat warnings as errors for project sources.
- `/Bin` and `/Distro` are outputs only (git‑ignored).

---

## 8) Testing

- `/Tests/Unit`: deterministic unit tests.  
- `/Tests/Functional`: end‑to‑end flows (prefer UE CLI dry‑runs).  
- Every PR must add/extend tests and pass CI.

---

## 9) Licensing & Third‑Party

- Project: **Apache‑2.0** (`LICENSE`).  
- Submodules: QtBase (LGPLv3/GPLv3/commercial), Dear ImGui (MIT), tinyxml2 (zlib).  
- Keep `THIRD_PARTY_NOTICES.md` updated.
