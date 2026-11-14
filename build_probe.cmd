@echo off
setlocal
rem Build the kwxFortran probe test app. This is a build-only path: nothing is
rem launched and no window is created.
rem
rem   build_probe.cmd        build tests\quick_probe (the probe gate)
rem   build_probe.cmd help   this text
rem
rem probe.wxui generates gen\probe_mainframe.f90 and gen\probe_dlg.f90;
rem probe_main.f90 is hand-written. Probe output never goes to tests\quick.
rem tests\quick_probe is a standalone CMake project (see its CMakeLists.txt);
rem it is configured on first use with the same presets as tests\quick.

cd /D "%~dp0"

if /I "%~1"=="help" goto :usage
if /I "%~1"=="-h" goto :usage
if /I "%~1"=="/?" goto :usage

if not exist "tests\quick_probe\gen\probe_mainframe.f90" goto :no_gen
if not exist "tests\quick_probe\gen\probe_dlg.f90" goto :no_gen
if not exist "tests\quick_probe\probe_main.f90" goto :no_main

where ninja >nul 2>&1
if errorlevel 1 goto :no_ninja

if not exist "tests\quick_probe\build\build-Debug.ninja" (
    where cmake >nul 2>&1
    if errorlevel 1 goto :no_cmake
    pushd "tests\quick_probe"
    cmake --fresh --preset ninja-gfortran
    if errorlevel 1 (
        popd
        echo ERROR: cmake could not configure tests\quick_probe.
        exit /b 1
    )
    popd
)

ninja -C tests\quick_probe\build -f build-Debug.ninja
if errorlevel 1 (
    echo ERROR: ninja build failed.
    exit /b 1
)

exit /b 0

:usage
echo Usage: build_probe.cmd
echo.
echo   build_probe.cmd        build tests\quick_probe and exit with the build status
echo   build_probe.cmd help   this text
exit /b 0

:no_gen
echo ERROR: tests\quick_probe\gen\probe_mainframe.f90 does not exist.
echo        Generate it from ..\quick\tests\quick_probe\probe.wxui first.
exit /b 1

:no_main
echo ERROR: tests\quick_probe\probe_main.f90 does not exist.
exit /b 1

:no_ninja
echo ERROR: ninja not found on PATH.
exit /b 1

:no_cmake
echo ERROR: cmake not found on PATH (needed to configure tests\quick_probe).
exit /b 1
