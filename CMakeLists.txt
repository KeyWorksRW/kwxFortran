cmake_minimum_required(VERSION 3.16)
project(kwxFortran
    VERSION 0.1.0
    LANGUAGES Fortran C CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable Fortran
enable_language(Fortran)

# Set Fortran compiler flags
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -Wall -Wextra")
    set(CMAKE_Fortran_FLAGS_DEBUG "-g -O0 -fcheck=all")
    set(CMAKE_Fortran_FLAGS_RELEASE "-O3")
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -warn all")
    set(CMAKE_Fortran_FLAGS_DEBUG "-g -O0 -check all")
    set(CMAKE_Fortran_FLAGS_RELEASE "-O3")
elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -warn all")
    set(CMAKE_Fortran_FLAGS_DEBUG "-g -O0 -check all")
    set(CMAKE_Fortran_FLAGS_RELEASE "-O3")
endif()

# Option for shared or static library
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)

# wxFFI integration
# Check if wxFFI submodule exists and is populated
set(WXFFI_AVAILABLE OFF)
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/external/wxFFI/CMakeLists.txt")
    message(STATUS "Using local wxFFI submodule")
    add_subdirectory(external/wxFFI)
    set(WXFFI_AVAILABLE ON)
else()
    # Try FetchContent if submodule is not available
    include(FetchContent)

    FetchContent_Declare(
        wxFFI
        GIT_REPOSITORY https://github.com/Randalphwa/wxFFI.git
        GIT_TAG main
    )

    # Only fetch if running in an environment with access
    # (e.g., user has configured git credentials)
    if(DEFINED ENV{WXFFI_FETCH} OR WXFFI_FETCH)
        message(STATUS "Fetching wxFFI from GitHub")
        FetchContent_MakeAvailable(wxFFI)
        set(WXFFI_AVAILABLE ON)
    else()
        message(STATUS "wxFFI submodule not populated. Initialize with:")
        message(STATUS "  git submodule update --init --recursive")
        message(STATUS "Or set -DWXFFI_FETCH=ON to fetch from GitHub")
    endif()
endif()

# Find wxWidgets (required by wxFFI)
find_package(wxWidgets 3.3 COMPONENTS core base QUIET)

# Set module output directory before creating targets
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/modules)

# Source files
set(KWXFORTRAN_SOURCES
    src/wxffi_types.f90
    src/wx_string.f90
)

# Create the library
add_library(kwxFortran ${KWXFORTRAN_SOURCES})

# Set module output directory for this target
set_target_properties(kwxFortran PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/modules
)
target_include_directories(kwxFortran PUBLIC
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/modules>
    $<INSTALL_INTERFACE:include>
)

# Link against wxffi if available
if(WXFFI_AVAILABLE AND TARGET wxffi)
    target_link_libraries(kwxFortran PUBLIC wxffi)
endif()

# Link against wxWidgets if found
if(wxWidgets_FOUND)
    target_link_libraries(kwxFortran PUBLIC ${wxWidgets_LIBRARIES})
    target_include_directories(kwxFortran PUBLIC ${wxWidgets_INCLUDE_DIRS})
endif()

# Install targets
install(TARGETS kwxFortran
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

# Install Fortran module files
install(DIRECTORY ${CMAKE_BINARY_DIR}/modules/
    DESTINATION include
    FILES_MATCHING PATTERN "*.mod"
)

# Print configuration summary
message(STATUS "")
message(STATUS "kwxFortran Configuration Summary:")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  Fortran Compiler: ${CMAKE_Fortran_COMPILER_ID} ${CMAKE_Fortran_COMPILER_VERSION}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Shared Libs: ${BUILD_SHARED_LIBS}")
if(WXFFI_AVAILABLE)
    message(STATUS "  wxFFI: Available")
else()
    message(STATUS "  wxFFI: Not available (run: git submodule update --init --recursive)")
endif()
if(wxWidgets_FOUND)
    message(STATUS "  wxWidgets: Found (${wxWidgets_VERSION_STRING})")
else()
    message(STATUS "  wxWidgets: Not found (will build without)")
endif()
message(STATUS "")
