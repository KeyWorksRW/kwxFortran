@echo off
setlocal

rem Build the kwxFortran quick test app. This is a build-only path: nothing is
rem launched and no window is created.
rem
rem   build_quick.cmd        build tests\quick (the verification gate)
rem   build_quick.cmd help   this text
rem
rem tests\quick is a standalone CMake project (see tests\quick\CMakeLists.txt).
rem Configure it once with its own presets:
rem   cmake --fresh --preset ninja-gfortran      (from tests\quick)

cd /D "%~dp0"

if /I "%~1"=="help" goto :usage
if /I "%~1"=="-h" goto :usage
if /I "%~1"=="/?" goto :usage

if not exist "tests\quick\build\build-Debug.ninja" goto :no_build

where ninja >nul 2>&1
if errorlevel 1 goto :no_ninja

ninja -C tests\quick\build -f build-Debug.ninja
if errorlevel 1 (
    echo ERROR: ninja build failed.
    exit /b 1
)

exit /b 0

:usage
echo Usage: build_quick.cmd
echo.
echo   build_quick.cmd        build tests\quick and exit with the build status
echo   build_quick.cmd help   this text
exit /b 0

:no_build
echo ERROR: tests\quick\build\build-Debug.ninja does not exist.
echo        Configure tests\quick first: cmake --fresh --preset ninja-gfortran
exit /b 1

:no_ninja
echo ERROR: ninja not found on PATH.
exit /b 1
