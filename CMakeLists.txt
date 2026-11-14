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
set(CMAKE_CXX_STANDARD 23)
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
    # TEMPORARY: use the local sibling checkout so source changes show up immediately.
    # Restore the GIT_REPOSITORY line below to fetch from GitHub again.
    # GIT_REPOSITORY https://github.com/KeyWorksRW/kwxFFI.git
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../kwxFFI
    GIT_TAG origin/main
    GIT_SHALLOW TRUE
    UPDATE_DISCONNECTED FALSE  # Explicitly enable updates
)

message(NOTICE "Configuring kwxFFI...")

# kwxFFI is always built as a static library (never a DLL) so that wxWidgets
# exists in exactly one copy inside the final executable. Force both options
# before kwxFFI's CMakeLists defines its targets, overriding any cached value.
set(KWXFFI_BUILD_SHARED OFF CACHE BOOL "Build kwxFFI as shared library" FORCE)
set(KWXFFI_BUILD_BOTH   OFF CACHE BOOL "Build both static and shared kwxFFI" FORCE)

FetchContent_MakeAvailable(kwxFFI)

if(KWXFFI_BUILD_SHARED OR KWXFFI_BUILD_BOTH)
    message(FATAL_ERROR
        "kwxFortran requires a static kwxFFI. Shared (DLL) builds are not supported "
        "because kwxApp.cpp and wxWidgets must resolve to a single copy per process.")
endif()

# Override kwxFFI output directories to place the static library in root bin/ directory
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

# disabled — kwxFFI's own CMakeLists.txt adds kwxgen as a subdirectory
# include (cmake/kwxgen.cmake)

# ###################### Fortran Library Target #######################

include(file_list.cmake)

add_library(kwxFortran STATIC ${CXX_SOURCES} ${FORTRAN_SOURCES})

# Generated bindings must exist before compiling Fortran sources
if(TARGET generate_fortran_bindings)
    add_dependencies(kwxFortran generate_fortran_bindings)
endif()

# Link against kwxFFI for FFI symbols AND wxWidgets for kwxApp.cpp
# Both kwxFFI and wxWidgets are static libraries
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

set(EXAMPLE_TARGETS hello controls_demo demo)

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

# ###################### Samples #######################

# Samples live in samples/<name>/<name>.f90. Only names whose entry file exists
# are built, so a sample that has not been ported yet never breaks configure.
set(SAMPLE_TARGETS about animate archive artprov calendar collpane combo font grid minimal notebook preferences widgets wizard)

# Samples that use the wxAppConsole lifecycle (kwxConsoleInitialize /
# kwxConsoleRun / kwxConsoleShutdown) are console-subsystem executables: they
# must keep stdout/stderr attached, so the GUI-subsystem linker flags below are
# not applied to them.
set(SAMPLE_CONSOLE_TARGETS archive)

# Samples are EXCLUDE_FROM_ALL: a plain build of the default target builds the
# library and the examples but no sample. Build one sample with
#     cmake --build build --config Debug --target <name>
# (only that executable is relinked), or every sample on demand with
#     cmake --build build --config Debug --target all_samples
add_custom_target(all_samples)

foreach(sample ${SAMPLE_TARGETS})
    set(SAMPLE_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/samples/${sample}/${sample}.f90")
    if(EXISTS "${SAMPLE_SOURCE}")
        # A sample name can collide with another target name; such a sample
        # builds as "<name>_sample" so both targets can coexist.
        set(SAMPLE_TARGET ${sample})
        if(TARGET ${sample})
            set(SAMPLE_TARGET ${sample}_sample)
        endif()
        add_executable(${SAMPLE_TARGET} EXCLUDE_FROM_ALL ${SAMPLE_SOURCE} $<$<BOOL:${WIN32}>:${KWXF_RC_FILE}>)
        add_dependencies(all_samples ${SAMPLE_TARGET})
        target_link_libraries(${SAMPLE_TARGET} PRIVATE kwxFortran kwxFFI)
        set_target_properties(${SAMPLE_TARGET} PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${KWXF_BIN_DIR}/$<CONFIG>
        )
        # Suppress console window for GUI apps (no WinMain — Fortran generates main())
        # Console samples keep the default console subsystem so stdout/stderr work.
        if(WIN32 AND NOT sample IN_LIST SAMPLE_CONSOLE_TARGETS)
            if(KWXF_MSVC_ABI)
                target_link_options(${SAMPLE_TARGET} PRIVATE "/SUBSYSTEM:WINDOWS" "/ENTRY:mainCRTStartup")
            else()
                target_link_options(${SAMPLE_TARGET} PRIVATE "-mwindows")
            endif()
        endif()
    endif()
endforeach()

# ###################### Tests #######################

# tests/quick is an untracked scratch area with its own standalone CMake project.
# It is not part of this build — the Configure tasks configure it with its own
# CMakePresets.json, and the "build quick debug" task builds it with ninja.
