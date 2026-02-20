# CMake 3.30 required for FetchContent performance improvements (CMP0168)
cmake_minimum_required(VERSION 3.30)

string( TIMESTAMP YEAR "%y" ) # e.g., "25"
string( TIMESTAMP DOY "%j" ) # e.g., "192"
string( TIMESTAMP PROJECT_YEAR "%Y" )
math( EXPR BUILD_NUM "${YEAR}%100 * 1000 + ${DOY}" )

set( PROJECT_VERSION_MAJOR 0 )
set( PROJECT_VERSION_MINOR 1 )
set( PROJECT_VERSION_PATCH 0 )
set( PROJECT_VERSION_BUILD ${BUILD_NUM} )
set( PROJECT_VERSION_YEAR ${PROJECT_YEAR} )

project( kwxFortran
    LANGUAGES CXX C Fortran
    VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}.${PROJECT_VERSION_BUILD}
    DESCRIPTION "kwxFortran - Fortran bindings for wxWidgets via kwxFFI"
    HOMEPAGE_URL "https://github.com/KeyWorksRW/wxUiEditor" )

# ###################### General Settings #######################
set( CMAKE_CXX_STANDARD 23 )
set( CMAKE_CXX_STANDARD_REQUIRED True )
set( CMAKE_CXX_EXTENSIONS OFF )

# Global default: all Fortran targets write .mod files here (per-target property
# Fortran_MODULE_DIRECTORY on kwxFortran also sets this, but setting it globally
# ensures example executables and any future targets never fall back to src/).
set( CMAKE_Fortran_MODULE_DIRECTORY "${CMAKE_BINARY_DIR}/modules" )

# Default to Release build if not specified
if( NOT CMAKE_BUILD_TYPE )
    set( CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE )
endif()

# ###################### Compiler ABI Detection #######################
# On Windows, ifx uses MSVC ABI (cl/clang-cl) while gfortran uses GNU ABI (g++/clang++).
# Detect which ABI is in use to set correct output dirs and wxWidgets include paths.
# On Linux/macOS, both compilers use GNU ABI — no branching needed.
if( WIN32 )
    if( MSVC OR CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC" )
        set( KWXF_MSVC_ABI TRUE )
        set( KWXF_BIN_DIR "${PROJECT_SOURCE_DIR}/bin" )
        set( KWXF_LIB_DIR "${PROJECT_SOURCE_DIR}/lib" )
        message( STATUS "Compiler ABI: MSVC (ifx + cl/clang-cl)" )
    else()
        set( KWXF_MSVC_ABI FALSE )
        set( KWXF_BIN_DIR "${PROJECT_SOURCE_DIR}/bin-mingw" )
        set( KWXF_LIB_DIR "${PROJECT_SOURCE_DIR}/lib-mingw" )
        message( STATUS "Compiler ABI: GNU (gfortran + g++/clang++)" )
    endif()
else()
    set( KWXF_BIN_DIR "${PROJECT_SOURCE_DIR}/bin" )
    set( KWXF_LIB_DIR "${PROJECT_SOURCE_DIR}/lib" )
endif()

# Validate compiler pairing on Windows
if( WIN32 )
    if( CMAKE_Fortran_COMPILER_ID STREQUAL "Intel" AND NOT KWXF_MSVC_ABI )
        message( FATAL_ERROR
            "ifx on Windows requires cl.exe or clang-cl as the C++ compiler.\n"
            "Use the ninja-ifx or ninja-ifx-clangcl preset." )
    elseif( CMAKE_Fortran_COMPILER_ID STREQUAL "GNU" AND KWXF_MSVC_ABI )
        message( FATAL_ERROR
            "gfortran on Windows requires g++ or clang++ (GNU mode, not clang-cl).\n"
            "Use the ninja-gfortran-mingw preset." )
    endif()
endif()

# ###################### Options #######################
# Only generate compile_commands.json for local development
if ( NOT DEFINED ENV{CI} )
    # creates a compile_commands.json file in the build directory, suitable for clangd
    set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
endif()

# ###################### ccache support #######################
find_program( CCACHE_PROGRAM ccache )

if( CCACHE_PROGRAM )
    message( STATUS "Using ccache: ${CCACHE_PROGRAM}" )
    set( CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}" )
    set( CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}" )

    message( NOTICE "ccache detected. Configure ccache globally for your development environment:" )
    message( NOTICE "  Recommended for all platforms:" )
    message( NOTICE "    ccache --set-config=compression=true" )
    message( NOTICE "    ccache --set-config=max_size=<appropriate for your projects>" )
    message( NOTICE "    ccache --set-config=sloppiness=pch_defines,time_macros,include_file_mtime,include_file_ctime" )

    if( MSVC )
        message( NOTICE "  Required for MSVC:" )

        message( NOTICE "    ccache --set-config=pch_external_checksum=true" )
        message( NOTICE "    ccache --set-config=depend_mode=true" )
        message( NOTICE "    ccache --set-config=\"ignore_options=/Zi /Z7 /ZI /FS /Fd*\"" )
    endif()

    message( NOTICE "  Run 'ccache --show-config' to verify current settings" )
    message( NOTICE "  Run 'ccache -s' to monitor cache usage" )
endif()

include( FetchContent )

# Suppress verbose FetchContent git output (CMake 3.30+)
set(FETCHCONTENT_QUIET ON)

message( STATUS "Fetching kwxFFI and wxWidgets (this may take awhile) ..." )

FetchContent_Declare(
    kwxFFI
    GIT_REPOSITORY https://github.com/KeyWorksRW/kwxFFI.git
    GIT_TAG origin/main
    GIT_SHALLOW TRUE
    UPDATE_DISCONNECTED FALSE  # Explicitly enable updates
)

message( NOTICE "Configuring kwxFFI..." )

FetchContent_MakeAvailable( kwxFFI )

# Override kwxFFI output directories to place DLLs in root bin/ directory
set_target_properties( kwxFFI PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${KWXF_BIN_DIR}/$<CONFIG>"
    LIBRARY_OUTPUT_DIRECTORY "${KWXF_BIN_DIR}/$<CONFIG>"
    RUNTIME_OUTPUT_DIRECTORY "${KWXF_BIN_DIR}/$<CONFIG>"
)

message( NOTICE "kwxFFI has been fetched and configured." )
message( STATUS "kwxFFI sources: " ${kwxFFI_SOURCE_DIR} )

# Define wxWidgets paths (kwxFFI fetches wxWidgets as a subdependency)
# These match the FetchContent directory structure
set( WX_SRC_DIR ${CMAKE_BINARY_DIR}/_deps/wxwidgets-src )
set( WX_BUILD_DIR ${CMAKE_BINARY_DIR}/_deps/wxwidgets-build )
message( STATUS "wxWidgets sources: " ${WX_SRC_DIR} )
message( STATUS "wxWidgets build: " ${WX_BUILD_DIR} )

# ###################### Fortran Library Target #######################

include(file_list.cmake)

add_library( kwxFortran STATIC ${CXX_SOURCES} ${FORTRAN_SOURCES} )

# Define export macro for kwxApp.cpp on Windows
target_compile_definitions( kwxFortran PRIVATE KWXFORTRAN_EXPORTS )

# Link against kwxFFI for FFI symbols AND wxWidgets for kwxApp.cpp
# kwxFFI is a shared library but wxWidgets are static
target_link_libraries( kwxFortran PRIVATE kwxFFI wxbase wxcore )

# Include wxWidgets headers for kwxApp.cpp (platform-specific setup.h location)
target_include_directories( kwxFortran PRIVATE
    ${WX_SRC_DIR}/include
)

if( WIN32 )
    if( KWXF_MSVC_ABI )
        target_include_directories( kwxFortran PRIVATE
            ${WX_BUILD_DIR}/lib/vc_x64_lib/mswu
        )
    else()
        # MinGW/gfortran: wxWidgets uses gcc_x64_lib for 64-bit MinGW builds
        target_include_directories( kwxFortran PRIVATE
            ${WX_BUILD_DIR}/lib/gcc_x64_lib/mswu
        )
    endif()
elseif( APPLE )
    target_include_directories( kwxFortran PRIVATE
        ${WX_BUILD_DIR}/lib/osx_cocoa-unicode-static
    )
elseif( UNIX )
    target_include_directories( kwxFortran PRIVATE
        ${WX_BUILD_DIR}/lib/gtk3_unixu-3.3/include
    )
endif()

set_target_properties( kwxFortran PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
    ARCHIVE_OUTPUT_DIRECTORY ${KWXF_LIB_DIR}/$<CONFIG>
)

# Make Fortran modules available to dependents
target_include_directories( kwxFortran PUBLIC
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/modules>
)

# ###################### Examples #######################

set( EXAMPLE_TARGETS minimal hello controls_demo demo )

foreach( example ${EXAMPLE_TARGETS} )
    add_executable( ${example} examples/${example}.f90 )
    target_link_libraries( ${example} PRIVATE kwxFortran kwxFFI )
    set_target_properties( ${example} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY ${KWXF_BIN_DIR}/$<CONFIG>
    )
endforeach()

# Suppress console window for GUI apps (no WinMain — Fortran generates main())
if( WIN32 )
    if( KWXF_MSVC_ABI )
        # MSVC/clang-cl linker flags
        foreach( example ${EXAMPLE_TARGETS} )
            target_link_options( ${example} PRIVATE "/SUBSYSTEM:WINDOWS" "/ENTRY:mainCRTStartup" )
        endforeach()
    else()
        # MinGW linker flag (-mwindows sets subsystem and suppresses console)
        foreach( example ${EXAMPLE_TARGETS} )
            target_link_options( ${example} PRIVATE "-mwindows" )
        endforeach()
    endif()
endif()
