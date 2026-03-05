# Fortran and C++ source file lists for kwxFortran

# C++ source files (wxApp implementation)
set( CXX_SOURCES
    src/kwxApp.cpp
)

# Fortran source files - order matters for module dependencies
# Base modules must be listed before modules that depend on them
set( FORTRAN_SOURCES
    # Generated raw C bindings (kwxffi module — all class methods, events, keys, constants)
    wx/kwxffi_gen.f90

    # Generated wrapper modules (kwxgen output)
    wx/kwx_types.f90          # Base types (no dependencies)
    wx/wx_string.f90          # String utilities (depends on kwx_types)
    wx/kwx_constants.f90      # Constants with clean Fortran names (depends on iso_c_binding only)

    # Manual module (maintained in src/)
    src/wx_app.f90            # App wrapper (depends on kwx_types; private kwxApp_* bindings)

    # Generated wrapper modules (kwxgen output, continued)
    wx/wx_window.f90          # Window wrapper (depends on types, kwxffi, constants, string)
    wx/wx_frame.f90           # Frame wrapper (depends on types, kwxffi, constants, string)
    wx/wx_controls.f90        # Control wrappers (depends on types, kwxffi, constants, string)
    wx/wx_menus.f90           # Menu wrappers (depends on types, kwxffi, constants, string)
    wx/wx_sizers.f90          # Sizer wrappers (depends on types, kwxffi, constants)
    wx/wx_events.f90          # Event wrappers (depends on types, kwxffi, string; private wxClosure)
    wx/wx_dialogs.f90         # Dialog wrappers (depends on types, constants, string; private kwxMessageBox)
)
