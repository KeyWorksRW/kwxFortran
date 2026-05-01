# Toolchain file for gfortran + clang/clang++ (MSYS2 ucrt64 or similar)
#
# On Windows, when multiple MSYS2 subsystems are on PATH (e.g. clang64 and
# ucrt64), the GCC sub-tools (f951.exe, cc1plus.exe) may load incompatible
# DLLs from the wrong subsystem, causing silent crashes (0xC0000139).
# Environment variables like LIBRARY_PATH may also point to the wrong
# subsystem's libraries, causing linker failures.
#
# This toolchain file:
#   1. Finds gfortran on PATH and derives its bin directory
#   2. Prepends that directory to PATH so sub-tools load correct DLLs
#   3. Clears environment variables that may point to a conflicting subsystem

set(CMAKE_Fortran_COMPILER gfortran)
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)

if(WIN32)
    # Find gfortran's actual location via PATH
    find_program(_GFORTRAN_REAL gfortran)
    if(_GFORTRAN_REAL)
        get_filename_component(_GFORTRAN_DIR "${_GFORTRAN_REAL}" DIRECTORY)
        # Prepend the compiler's bin directory to PATH so GCC sub-tools
        # (f951.exe, cc1plus.exe, as.exe, ld.exe) load the correct DLLs
        set(ENV{PATH} "${_GFORTRAN_DIR};$ENV{PATH}")
    endif()
    unset(_GFORTRAN_REAL CACHE)
    unset(_GFORTRAN_DIR)

    # Clear environment variables that may point to a conflicting subsystem
    # (e.g. MSYS2 clang64 sets these for its own toolchain)
    set(ENV{LIBRARY_PATH} "")
    set(ENV{CPLUS_INCLUDE_PATH} "")
    set(ENV{C_INCLUDE_PATH} "")
endif()
