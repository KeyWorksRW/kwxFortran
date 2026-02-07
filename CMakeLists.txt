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
    LANGUAGES CXX Fortran
    VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}.${PROJECT_VERSION_BUILD}
    DESCRIPTION "kwxFortran - Fortran bindings for wxWidgets via kwxFFI"
    HOMEPAGE_URL "https://github.com/KeyWorksRW/wxUiEditor" )

# ###################### General Settings #######################
set( CMAKE_CXX_STANDARD 23 )
set( CMAKE_CXX_STANDARD_REQUIRED True )
set( CMAKE_CXX_EXTENSIONS OFF )

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
    ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/bin/$<CONFIG>"
    LIBRARY_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/bin/$<CONFIG>"
    RUNTIME_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/bin/$<CONFIG>"
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
    target_include_directories( kwxFortran PRIVATE
        ${WX_BUILD_DIR}/lib/vc_x64_lib/mswu
    )
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
    ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib/$<CONFIG>
)

# Make Fortran modules available to dependents
target_include_directories( kwxFortran PUBLIC
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/modules>
)

# ###################### Examples #######################

add_executable( minimal examples/minimal.f90 )
target_link_libraries( minimal PRIVATE kwxFortran kwxFFI )

set_target_properties( minimal PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin/$<CONFIG>
)

# Use Windows GUI subsystem (no console window) but keep main() entry point
# Fortran's "program" statement generates main(), not WinMain()
if( WIN32 )
    target_link_options( minimal PRIVATE "/SUBSYSTEM:WINDOWS" "/ENTRY:mainCRTStartup" )
endif()
