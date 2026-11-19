@echo off
setlocal

rem Build the kwxFortran QuickPort app. This is a build-only path: nothing is launched and
rem no window is created. Derived from build_quick.cmd: the same standalone CMake project
rem shape, only the folder and the target name differ.
rem
rem   build_quick_port.cmd        build tests\quick_port (the port lane)
rem   build_quick_port.cmd help   this text
rem
rem tests\quick_port is a standalone CMake project (see tests\quick_port\CMakeLists.txt).
rem The first run configures it with its own presets; later runs only build.

cd /D "%~dp0"

if /I "%~1"=="help" goto :usage
if /I "%~1"=="-h" goto :usage
if /I "%~1"=="/?" goto :usage

where ninja >nul 2>&1
if errorlevel 1 goto :no_ninja
where cmake >nul 2>&1
if errorlevel 1 goto :no_cmake

if not exist "tests\quick_port\build\build-Debug.ninja" (
    echo Configuring tests\quick_port ...
    pushd tests\quick_port
    cmake --fresh --preset ninja-gfortran
    if errorlevel 1 (
        popd
        echo ERROR: cmake configure failed.
        exit /b 1
    )
    popd
)

ninja -C tests\quick_port\build -f build-Debug.ninja
if errorlevel 1 (
    echo ERROR: ninja build failed.
    exit /b 1
)

exit /b 0

:usage
echo Usage: build_quick_port.cmd
echo.
echo   build_quick_port.cmd        build tests\quick_port and exit with the build status
echo   build_quick_port.cmd help   this text
exit /b 0

:no_ninja
echo ERROR: ninja not found on PATH.
exit /b 1

:no_cmake
echo ERROR: cmake not found on PATH.
exit /b 1
