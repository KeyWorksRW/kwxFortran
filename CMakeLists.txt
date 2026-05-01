# CMake 3.30 required for FetchContent performance improvements (CMP0168)
cmake_minimum_required(VERSION 3.30)

string(TIMESTAMP YEAR "%y") # e.g., "25"
string(TIMESTAMP DOY "%j") # e.g., "192"
string(TIMESTAMP PROJECT_YEAR "%Y")
math(EXPR BUILD_NUM "${YEAR}%100 * 1000 + ${DOY}")

set(PROJECT_VERSION_MAJOR 0)
set(PROJECT_VERSION_MINOR 1)
set(PROJECT_VERSION_PATCH 0)
set(PROJECT_VERSION_BUILD ${BUILD_NUM})
set(PROJECT_VERSION_YEAR ${PROJECT_YEAR})

project(kwxFortran
    LANGUAGES CXX C Fortran
    VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}.${PROJECT_VERSION_BUILD}
    DESCRIPTION "kwxFortran - Fortran bindings for wxWidgets via kwxFFI"
    HOMEPAGE_URL "https://github.com/KeyWorksRW/wxUiEditor")

# ###################### General Settings #######################
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_CXX_EXTENSIONS OFF)

# Global default: all Fortran targets write .mod files here (per-target property
# Fortran_MODULE_DIRECTORY on kwxFortran also sets this, but setting it globally
# ensures example executables and any future targets never fall back to src/).
set(CMAKE_Fortran_MODULE_DIRECTORY "${CMAKE_BINARY_DIR}/modules")

# Default to Release build if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# ###################### Compiler ABI Detection #######################
# On Windows, ifx uses MSVC ABI (cl/clang-cl) while gfortran uses GNU ABI (g++/clang++).
# Detect which ABI is in use to set correct output dirs and wxWidgets include paths.
# On Linux/macOS, both compilers use GNU ABI — no branching needed.
if(WIN32)
    if(MSVC OR CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC")
        set(KWXF_MSVC_ABI TRUE)
        set(KWXF_BIN_DIR "${PROJECT_SOURCE_DIR}/bin-ifx")
        set(KWXF_LIB_DIR "${PROJECT_SOURCE_DIR}/lib-ifx")
        message(STATUS "Compiler ABI: MSVC (ifx + cl/clang-cl)")
    else()
        set(KWXF_MSVC_ABI FALSE)
        set(KWXF_BIN_DIR "${PROJECT_SOURCE_DIR}/bin")
        set(KWXF_LIB_DIR "${PROJECT_SOURCE_DIR}/lib")
        message(STATUS "Compiler ABI: GNU (gfortran + clang/clang++)")
    endif()
else()
    set(KWXF_BIN_DIR "${PROJECT_SOURCE_DIR}/bin")
    set(KWXF_LIB_DIR "${PROJECT_SOURCE_DIR}/lib")
endif()

# Validate compiler pairing on Windows
if(WIN32)
    if(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel" AND NOT KWXF_MSVC_ABI)
        message(FATAL_ERROR
            "ifx on Windows requires cl.exe or clang-cl as the C++ compiler.\n"
            "Use the ninja-ifx or ninja-ifx-clangcl preset.")
    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU" AND KWXF_MSVC_ABI)
        message(FATAL_ERROR
            "gfortran on Windows requires g++ or clang++ (GNU mode, not clang-cl).\n"
            "Use the ninja-gfortran preset.")
    endif()
endif()

# ###################### DWARF version #######################
# GCC 15 defaults to DWARF-5, which stores line-table file/directory names in a
# separate .debug_line_str section.  LLDB on Windows (PE/COFF) may not read that
# section, causing breakpoints in Fortran (and gcc-compiled C++) to silently fail.
# Force DWARF-4 for all non-MSVC compilers so that file names stay inline in
# .debug_line — universally supported by every LLDB version.
if(NOT KWXF_MSVC_ABI)
    add_compile_options(
        $<$<AND:$<COMPILE_LANGUAGE:C,CXX,Fortran>,$<CONFIG:Debug,RelWithDebInfo>>:-gdwarf-4>
    )
endif()

# ###################### sccache #######################
find_program(SCCACHE_PROGRAM sccache)
if(SCCACHE_PROGRAM)
    message(STATUS "sccache found: ${SCCACHE_PROGRAM}")
    set(CMAKE_C_COMPILER_LAUNCHER "${SCCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${SCCACHE_PROGRAM}")

    # sccache cannot cache MSVC's /Zi (separate PDB files). Use /Z7 (embedded)
    # instead for Debug and RelWithDebInfo configs. CMake 3.25+ (CMP0141 NEW)
    # honours CMAKE_MSVC_DEBUG_INFORMATION_FORMAT; this is a no-op on non-MSVC.
    if(MSVC)
        set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT
            "$<$<CONFIG:Debug,RelWithDebInfo>:Embedded>")
    endif()
else()
    message(STATUS "sccache not found; building without a compiler cache")
endif()

# ###################### Options #######################

include(FetchContent)

# Suppress verbose FetchContent git output (CMake 3.30+)
set(FETCHCONTENT_QUIET ON)

message(STATUS "Fetching kwxFFI and wxWidgets (this may take awhile) ...")

FetchContent_Declare(
    kwxFFI
    GIT_REPOSITORY https://github.com/KeyWorksRW/kwxFFI.git
    GIT_TAG origin/main
    GIT_SHALLOW TRUE
    UPDATE_DISCONNECTED FALSE  # Explicitly enable updates
)

message(NOTICE "Configuring kwxFFI...")

FetchContent_MakeAvailable(kwxFFI)

# Override kwxFFI output directories to place DLLs in root bin/ directory
set_target_properties(kwxFFI PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${KWXF_BIN_DIR}/$<CONFIG>"
    LIBRARY_OUTPUT_DIRECTORY "${KWXF_BIN_DIR}/$<CONFIG>"
    RUNTIME_OUTPUT_DIRECTORY "${KWXF_BIN_DIR}/$<CONFIG>"
)

message(NOTICE "kwxFFI has been fetched and configured.")
message(STATUS "kwxFFI sources: " ${kwxFFI_SOURCE_DIR})

# Define wxWidgets paths (kwxFFI fetches wxWidgets as a subdependency)
# These match the FetchContent directory structure
set(WX_SRC_DIR ${CMAKE_BINARY_DIR}/_deps/wxwidgets-src)
set(WX_BUILD_DIR ${CMAKE_BINARY_DIR}/_deps/wxwidgets-build)
message(STATUS "wxWidgets sources: " ${WX_SRC_DIR})
message(STATUS "wxWidgets build: " ${WX_BUILD_DIR})

# ###################### kwxgen — Fortran binding generator #######################

# disabled until the new kwxgen repository is ready
# include (cmake/kwxgen.cmake)

# ###################### Fortran Library Target #######################

include(file_list.cmake)

add_library(kwxFortran STATIC ${CXX_SOURCES} ${FORTRAN_SOURCES})

# Generated bindings must exist before compiling Fortran sources
if(TARGET generate_fortran_bindings)
    add_dependencies(kwxFortran generate_fortran_bindings)
endif()

# Define export macro for kwxApp.cpp on Windows
target_compile_definitions(kwxFortran PRIVATE KWXFORTRAN_EXPORTS)

# Link against kwxFFI for FFI symbols AND wxWidgets for kwxApp.cpp
# kwxFFI is a shared library but wxWidgets are static
target_link_libraries(kwxFortran PRIVATE kwxFFI wxbase wxcore)

# Include wxWidgets headers for kwxApp.cpp (platform-specific setup.h location)
target_include_directories(kwxFortran PRIVATE
    ${WX_SRC_DIR}/include
)

if(WIN32)
    if(KWXF_MSVC_ABI)
        target_include_directories(kwxFortran PRIVATE
            ${WX_BUILD_DIR}/lib/vc_x64_lib/mswu
        )
    else()
        # wxWidgets names this directory based on the C++ compiler:
        # clang_x64_lib (clang++), gcc_x64_lib (g++), etc.
        file(GLOB _wx_lib_dirs "${WX_BUILD_DIR}/lib/*_x64_lib")
        list(GET _wx_lib_dirs 0 _wx_lib_dir)
        target_include_directories(kwxFortran PRIVATE
            ${_wx_lib_dir}/mswu
        )
        unset(_wx_lib_dirs)
        unset(_wx_lib_dir)
    endif()
elseif(APPLE)
    target_include_directories(kwxFortran PRIVATE
        ${WX_BUILD_DIR}/lib/osx_cocoa-unicode-static
    )
elseif(UNIX)
    target_include_directories(kwxFortran PRIVATE
        ${WX_BUILD_DIR}/lib/gtk3_unixu-3.3/include
    )
endif()

set_target_properties(kwxFortran PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
    ARCHIVE_OUTPUT_DIRECTORY ${KWXF_LIB_DIR}/$<CONFIG>
)

# Make Fortran modules available to dependents
target_include_directories(kwxFortran PUBLIC
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/modules>
)

# ###################### Examples #######################

set(EXAMPLE_TARGETS minimal hello controls_demo demo)

# Windows manifest for Common Controls v6 and DPI awareness
if(WIN32)
    set(KWXF_RC_FILE ${CMAKE_CURRENT_SOURCE_DIR}/src/kwxFortran.rc)
endif()

foreach(example ${EXAMPLE_TARGETS})
    add_executable(${example} examples/${example}.f90 $<$<BOOL:${WIN32}>:${KWXF_RC_FILE}>)
    target_link_libraries(${example} PRIVATE kwxFortran kwxFFI)
    set_target_properties(${example} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${KWXF_BIN_DIR}/$<CONFIG>
    )
endforeach()

# Suppress console window for GUI apps (no WinMain — Fortran generates main())
if(WIN32)
    if(KWXF_MSVC_ABI)
        # MSVC/clang-cl linker flags
        foreach(example ${EXAMPLE_TARGETS})
            target_link_options(${example} PRIVATE "/SUBSYSTEM:WINDOWS" "/ENTRY:mainCRTStartup")
        endforeach()
    else()
        # MinGW linker flag (-mwindows sets subsystem and suppresses console)
        foreach(example ${EXAMPLE_TARGETS})
            target_link_options(${example} PRIVATE "-mwindows")
        endforeach()
    endif()
endif()
