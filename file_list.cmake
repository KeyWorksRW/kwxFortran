# Fortran and C++ source file lists for kwxFortran.
#
# kwxgen now emits one wrapper module per wxWidgets class in wx/, so the
# generated sources are collected by glob instead of naming the old aggregate
# modules (wx_controls.f90, wx_menus.f90, wx_sizers.f90, wx_dialogs.f90) that
# no longer exist.
set( CXX_SOURCES
    src/kwxApp.cpp
)

file(GLOB _kwxf_generated_sources "${CMAKE_CURRENT_SOURCE_DIR}/wx/*.f90")
# The generated wxApp wrapper also declares module wx_app; the lifecycle module
# in src/wx_app.f90 is the one samples use, so keep only the latter.
list(REMOVE_ITEM _kwxf_generated_sources
    "${CMAKE_CURRENT_SOURCE_DIR}/wx/wx_app.f90")
set( FORTRAN_SOURCES
    ${_kwxf_generated_sources}
    src/wx_app.f90
)
