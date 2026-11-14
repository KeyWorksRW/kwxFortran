# tests/quick_probe — scratch GUI probe app (probe_main).
#
# Probe output never goes to tests/quick: probe.wxui writes gen/probe_mainframe.f90 and
# gen/probe_dlg.f90 here, and probe_main.f90 is the hand-written entry point.
#
# Configured and built the same way as tests/quick:
#   cmake --fresh --preset ninja-gfortran      (from tests\quick_probe)
#   ninja -f build-Debug.ninja

cmake_minimum_required(VERSION 3.30)

project(probe_main LANGUAGES Fortran CXX RC)

set(KWXF_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../..")

# Same ABI split as the root CMakeLists. Mixing ABIs (a gfortran archive in an
# ifx link, or the reverse) only surfaces as confusing linker errors.
if(WIN32 AND (MSVC OR CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC"))
    set(KWXF_MSVC_ABI TRUE)
    set(KWXF_BUILD   "${KWXF_ROOT}/build-ifx")
    set(KWXF_LIB_DIR "${KWXF_ROOT}/lib-ifx")
    set(KWXF_BIN_DIR "${KWXF_ROOT}/bin-ifx")
    set(KWXF_FORTRAN_LIB_NAME kwxFortran.lib)
    set(KWXF_FFI_LIB_NAME     kwxFFI.lib)
    set(_wx_lib_ext lib)
else()
    set(KWXF_MSVC_ABI FALSE)
    set(KWXF_BUILD   "${KWXF_ROOT}/build")
    set(KWXF_LIB_DIR "${KWXF_ROOT}/lib")
    set(KWXF_BIN_DIR "${KWXF_ROOT}/bin")
    set(KWXF_FORTRAN_LIB_NAME libkwxFortran.a)
    set(KWXF_FFI_LIB_NAME     libkwxFFI.a)
    set(_wx_lib_ext a)
endif()

if(WIN32)
    if(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel" AND NOT KWXF_MSVC_ABI)
        message(FATAL_ERROR
            "ifx on Windows requires cl.exe or clang-cl as the C++ compiler.\n"
            "Configure with the ninja-ifx or ninja-ifx-clangcl preset.")
    elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU" AND KWXF_MSVC_ABI)
        message(FATAL_ERROR
            "gfortran on Windows requires g++ or clang++ (GNU mode, not clang-cl).\n"
            "Configure with the ninja-gfortran preset.")
    endif()
endif()

if(NOT EXISTS "${KWXF_BUILD}/modules")
    message(FATAL_ERROR
        "kwxFortran modules not found in ${KWXF_BUILD}/modules — "
        "build the library first (\"build debug\" task).")
endif()

file(GLOB _wx_lib_dirs "${KWXF_BUILD}/_deps/wxwidgets-build/lib/*_x64_lib")
if(NOT _wx_lib_dirs)
    message(FATAL_ERROR
        "wxWidgets libraries not found under "
        "${KWXF_BUILD}/_deps/wxwidgets-build/lib — build the library first.")
endif()
list(GET _wx_lib_dirs 0 WX_LIB_DIR)

file(GLOB _wx_all_libs "${WX_LIB_DIR}/*.${_wx_lib_ext}")
set(WX_LIBS "")
foreach(_lib ${_wx_all_libs})
    get_filename_component(_stem "${_lib}" NAME_WE)
    set(_twin "")
    if(_stem MATCHES "d_")
        string(REGEX REPLACE "d_" "_" _twin "${_stem}")
    elseif(_stem MATCHES "d$")
        string(REGEX REPLACE "d$" "" _twin "${_stem}")
    endif()
    if(_twin AND EXISTS "${WX_LIB_DIR}/${_twin}.${_wx_lib_ext}")
        list(APPEND WX_LIBS "$<$<CONFIG:Debug>:${_lib}>")
    else()
        list(APPEND WX_LIBS "$<$<CONFIG:Release,RelWithDebInfo,MinSizeRel>:${_lib}>")
    endif()
endforeach()

add_executable(probe_main
    probe_main.f90
    gen/probe_mainframe.f90
    gen/probe_dlg.f90
    $<$<BOOL:${WIN32}>:${KWXF_ROOT}/src/kwxFortran.rc>
)

target_include_directories(probe_main PRIVATE "${KWXF_BUILD}/modules")

if(NOT KWXF_MSVC_ABI)
    target_compile_options(probe_main PRIVATE
        $<$<CONFIG:Debug,RelWithDebInfo>:-gdwarf-4>)
    # Generated FFI statements are emitted on one line; free-form Fortran's 132-column limit
    # would truncate them.
    target_compile_options(probe_main PRIVATE
        $<$<COMPILE_LANGUAGE:Fortran>:-ffree-line-length-none>)
endif()

set(_kwx_link_libs
    "${KWXF_LIB_DIR}/$<CONFIG>/${KWXF_FORTRAN_LIB_NAME}"
    "${KWXF_BIN_DIR}/$<CONFIG>/${KWXF_FFI_LIB_NAME}"
    ${WX_LIBS}
)

if(WIN32)
    list(APPEND _kwx_link_libs
        winhttp opengl32 glu32 windowscodecs
        kernel32 user32 gdi32 gdiplus msimg32 comdlg32 winspool winmm shell32
        shlwapi comctl32 ole32 oleaut32 uuid rpcrt4 advapi32 version ws2_32
        wininet oleacc uxtheme
    )
endif()

if(NOT KWXF_MSVC_ABI)
    list(INSERT _kwx_link_libs 0 "-Wl,--start-group")
    list(APPEND _kwx_link_libs "-Wl,--end-group")
    list(APPEND _kwx_link_libs gfortran quadmath m pthread)
endif()

target_link_libraries(probe_main PRIVATE ${_kwx_link_libs})

if(WIN32)
    if(KWXF_MSVC_ABI)
        target_link_options(probe_main PRIVATE "/SUBSYSTEM:WINDOWS" "/ENTRY:mainCRTStartup")
    else()
        target_link_options(probe_main PRIVATE "-mwindows")
    endif()
endif()

set_target_properties(probe_main PROPERTIES
    LINKER_LANGUAGE CXX
    Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/modules"
    RUNTIME_OUTPUT_DIRECTORY "${KWXF_BIN_DIR}/$<CONFIG>"
)
