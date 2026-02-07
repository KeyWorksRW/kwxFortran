# Fortran and C++ source file lists for kwxFortran

# C++ source files (wxApp implementation)
set( CXX_SOURCES
    src/kwxApp.cpp
)

# Fortran source files - order matters for module dependencies
# Base modules must be listed before modules that depend on them
set( FORTRAN_SOURCES
    src/wxffi_types.f90       # Base types (no dependencies)
    src/wx_string.f90         # String utilities (depends on wxffi_types)
    src/wxffi_bindings.f90    # Raw C bindings (depends on iso_c_binding only)
    src/wxffi_constants.f90   # Constants (depends on iso_c_binding only)
    src/wx_app.f90            # App wrapper (depends on wxffi_types, wxffi_bindings)
    src/wx_window.f90         # Window wrapper (depends on types, bindings, constants, string)
    src/wx_frame.f90          # Frame wrapper (depends on types, bindings, constants, string)
)
