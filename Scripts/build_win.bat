@echo off
REM Build (Windows → NMake) with verbose logging
setlocal ENABLEDELAYEDEXPANSION
set AEGIS_DEBUG_LOG=1

if not exist build mkdir build
cd build
cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=ON -DAEGIS_WITH_QT=ON -DAEGIS_WITH_IMGUI=ON ..
if errorlevel 1 goto :err

nmake /NOLOGO
if errorlevel 1 goto :err

echo Build OK.
goto :eof

:err
echo Build failed.
exit /b 1
