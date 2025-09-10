cmake_minimum_required(VERSION 3.21)

# ======================================================================
# SUPERBUILD: builds QtBase from the submodule, then configures Aegis
# ======================================================================
# Folder layout (assumed):
#   Source/Thirdparty/QtBase  <- your Qt submodule root (as shown in screenshot)
#   Source/                    <- your actual Aegis project (the CMake you had before)
#
# This superbuild will:
#   1) Configure + build + install QtBase into _qt_install/
#   2) Configure + build your aegis/ project with CMAKE_PREFIX_PATH set
# ======================================================================

project(AegisSuperbuild LANGUAGES C CXX)

include(ExternalProject)

# --------- Locations you can tweak ----------
set(QTBASE_SRC_DIR      "${CMAKE_SOURCE_DIR}/Source/Thirdparty/QtBase")
set(QTBASE_BUILD_DIR    "${CMAKE_BINARY_DIR}/build/_qt_build")
set(QTBASE_INSTALL_DIR  "${CMAKE_BINARY_DIR}/build/_qt_install")   # contains lib/cmake/Qt6 after install

# Pass-through options for your inner project
option(AEGIS_WITH_QT    "Build Qt UI backend" ON)
option(AEGIS_WITH_IMGUI "Build ImGui UI backend" ON)
option(AEGIS_BUILD_APP  "Build thin AegisApp runner" ON)

# Build type for subprojects
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
endif()

# -------------------- 1) Build QtBase from submodule -------------------
# NOTES:
#  • We disable tests/examples to speed up.
#  • Widgets are inside qtbase; ensure the features you need are enabled.
#  • You may need extra system deps (e.g., OpenGL, zlib) already on the machine.
#  • On Windows with MSVC, this will produce .lib/.dll; on Linux .so; on macOS .dylib.
ExternalProject_Add(qtbase_ep
  SOURCE_DIR        "${QTBASE_SRC_DIR}"
  BINARY_DIR        "${QTBASE_BUILD_DIR}"
  INSTALL_DIR       "${QTBASE_INSTALL_DIR}"
  # Configure QtBase
  CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX:PATH=${QTBASE_INSTALL_DIR}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DQT_BUILD_TESTS:BOOL=OFF
    -DQT_BUILD_EXAMPLES:BOOL=OFF
    # Enable features you need (Qt 6 uses FEATURE_* flags)
    -DFEATURE_gui=ON
    -DFEATURE_widgets=ON
  # Build & Install
  BUILD_COMMAND     ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE}
  INSTALL_COMMAND   ${CMAKE_COMMAND} --build . --target install --config ${CMAKE_BUILD_TYPE}
)

# -------------- 2) Configure + Build the Aegis project -----------------
# We point the inner project at the Qt install via CMAKE_PREFIX_PATH so
# its 'find_package(Qt6 ...)' succeeds on the first configure.
set(AEGIS_BINARY_DIR "${CMAKE_BINARY_DIR}/_aegis_build")

ExternalProject_Add(aegis_ep
  SOURCE_DIR        "${CMAKE_SOURCE_DIR}/Source"
  BINARY_DIR        "${AEGIS_BINARY_DIR}"
  # IMPORTANT: make Aegis wait for Qt to finish installing
  DEPENDS           qtbase_ep
  CMAKE_ARGS
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    -DCMAKE_PREFIX_PATH:PATH=${QTBASE_INSTALL_DIR}
    -DAEGIS_WITH_QT:BOOL=${AEGIS_WITH_QT}
    -DAEGIS_WITH_IMGUI:BOOL=${AEGIS_WITH_IMGUI}
    -DAEGIS_BUILD_APP:BOOL=${AEGIS_BUILD_APP}
  BUILD_COMMAND     ${CMAKE_COMMAND} --build . --config ${CMAKE_BUILD_TYPE}
  INSTALL_COMMAND   ""
)

# Convenience target so `cmake --build <superbuild> --target package_aegis`
# can re-package your inner project's Distro if you add a packaging step there.
add_custom_target(package_aegis
  COMMAND ${CMAKE_COMMAND} --build ${AEGIS_BINARY_DIR} --target package --config ${CMAKE_BUILD_TYPE}
  COMMENT "Packaging Aegis (inner project)"
)
