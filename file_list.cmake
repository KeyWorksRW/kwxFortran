# Fortran and C++ source file lists for kwxFortran

# C++ source files (wxApp implementation)
set( CXX_SOURCES
    src/kwxApp.cpp
)

# Fortran source files - order matters for module dependencies
# Base modules must be listed before modules that depend on them
set( FORTRAN_SOURCES
    src/kwx_types.f90       # Base types (no dependencies)
    src/wx_string.f90         # String utilities (depends on kwx_types)
    src/kwx_bindings.f90    # Raw C bindings (depends on iso_c_binding only)
    src/kwx_constants.f90   # Constants (depends on iso_c_binding only)
    src/wx_app.f90            # App wrapper (depends on kwx_types, kwx_bindings)
    src/wx_window.f90         # Window wrapper (depends on types, bindings, constants, string)
    src/wx_frame.f90          # Frame wrapper (depends on types, bindings, constants, string)
    src/wx_controls.f90       # Control wrappers (depends on types, bindings, constants, string)
    src/wx_menus.f90          # Menu wrappers (depends on types, bindings, constants, string)
    src/wx_sizers.f90         # Sizer wrappers (depends on types, bindings, constants)
    src/wx_events.f90         # Event wrappers (depends on types, bindings, constants, string)
    src/wx_dialogs.f90        # Dialog wrappers (depends on types, bindings, constants, string)
)
