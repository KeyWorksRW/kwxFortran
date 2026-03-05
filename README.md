# kwxFortran

Fortran language bindings for [wxWidgets](https://www.wxwidgets.org/) via [kwxFFI](https://github.com/KeyWorksRW/kwxFFI), enabling cross-platform GUI applications that render with native controls on Windows, macOS, and Linux.

## ⚠️ Warning: Not Production Ready

**Do not use this Fortran/wxWidgets interface in production.**

- The kwxFFI ABI interface is **not stable** and can change without warning.
- Very little testing has been done, and won't be until late Q2 of 2026.
- API surface may change as idioms are refined.

## Overview

kwxFortran provides a two-layer binding architecture:

1. **FFI Layer** (`wx/kwx_bindings.f90`) — Raw `ISO_C_BINDING` interface declarations mapping directly to the kwxFFI C function exports. All pointers are `c_ptr`.
2. **Wrapper Layer** (`wx/wx_*.f90`) — Idiomatic Fortran wrappers with optional parameters, automatic string conversion, type safety, and sensible defaults.

Users should work with the wrapper layer. The FFI layer is available for direct access when needed.

```
Fortran code  →  ISO_C_BINDING interfaces  →  kwxFFI (C functions)  →  wxWidgets (C++)
```

## Quick Example

```fortran
! examples/hello.f90 - Hello World wxWidgets application in Fortran

module hello_handlers
    use, intrinsic :: iso_c_binding
    use wx_events
    implicit none
    integer, save :: click_count = 0
contains
    subroutine on_button_click(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        click_count = click_count + 1
        print '(A,I0)', 'Button clicked! Count: ', click_count
    end subroutine on_button_click
end module hello_handlers

program hello
    use wx_app
    use wx_frame
    use wx_controls
    use wx_sizers
    use wx_window
    use wx_events
    use kwx_types
    use kwx_constants
    use hello_handlers
    implicit none

    type(wxFrame_t)      :: frame
    type(wxPanel_t)      :: panel
    type(wxBoxSizer_t)   :: main_sizer
    type(wxStaticText_t) :: label
    type(wxButton_t)     :: button
    type(wxTextCtrl_t)   :: text_input
    integer :: exit_code

    if (.not. wx_initialize()) stop 1
    call wx_set_app_name("Hello Fortran")

    frame = wx_frame_create(title="Hello wxFortran", width=400, height=300)
    panel = wx_panel_create(parent=frame)

    main_sizer = wx_box_sizer_create(wxVERTICAL())

    label = wx_static_text_create("Hello, World from Fortran!", parent=panel)
    call wx_sizer_add_window(main_sizer, label, proportion=0, flag=wxALL(), border=10)

    text_input = wx_text_ctrl_create(parent=panel, value="Type here...")
    call wx_sizer_add_window(main_sizer, text_input, &
        proportion=0, flag=ior(wxEXPAND(), wxALL()), border=10)

    button = wx_button_create("Click Me!", parent=panel)
    call wx_sizer_add_window(main_sizer, button, &
        proportion=0, flag=ior(wxALIGN_CENTER(), wxALL()), border=10)

    call wx_connect(button, wxEVT_BUTTON(), on_button_click)
    call wx_sizer_add_stretch_spacer(main_sizer)
    call wx_window_set_sizer(panel, main_sizer)

    call wx_frame_center(frame)
    call wx_frame_create_status_bar(frame)
    call wx_frame_set_status_text(frame, "Click the button!")

    call wx_set_top_window(frame)
    call wx_frame_show(frame)

    exit_code = wx_main_loop()
    call wx_shutdown()
end program hello
```

More examples are in the [`examples/`](examples/) directory.

## Type Hierarchy

Types mirror the wxWidgets C++ class hierarchy using Fortran derived type extension:

```
wxWindow_t
├── wxFrame_t
├── wxDialog_t
├── wxPanel_t
├── wxButton_t
├── wxStaticText_t
├── wxTextCtrl_t
├── wxCheckBox_t
├── wxRadioButton_t
├── wxChoice_t
├── wxListBox_t
├── wxComboBox_t
├── wxStatusBar_t
└── wxToolBar_t

wxSizer_t
├── wxBoxSizer_t
├── wxFlexGridSizer_t
└── wxGridSizer_t

wxEvent_t
└── wxCommandEvent_t
```

All types wrap an opaque `c_ptr` with an `is_valid()` method. Always check after creation.

## Naming Conventions

| Entity | Convention | Example |
| --- | --- | --- |
| Modules | `snake_case` | `wx_frame`, `kwx_bindings` |
| Types | `PascalCase_t` | `wxFrame_t`, `wxButton_t` |
| Wrapper functions | `wx_<class>_<action>` | `wx_frame_create`, `wx_frame_show` |
| Raw bindings | Match C name | `wxFrame_Create`, `kwxApp_Initialize` |
| Constants | Match wxWidgets | `wxID_ANY()`, `wxDEFAULT_FRAME_STYLE()` |

## Why Fortran + wxWidgets?

Modern Fortran is widely used in scientific and engineering domains, but GUI options are scarce. kwxFortran aims to fill that gap with a zero-dependency, statically-linked approach: one executable, native look on every supported platform.

## Compilers & Toolchain

| Toolchain | Status |
|-----------|--------|
| Intel `ifx` + MSVC `cl.exe` (Windows) | ✅ Primary |
| `gfortran` + MinGW (Windows) | ✅ Supported |
| `gfortran` (Linux / macOS) | 🔧 Planned |

## Building

Prerequisites:
- CMake 3.30+
- A supported Fortran compiler (see above)
- Internet access for FetchContent (kwxFFI and wxWidgets are fetched automatically)

## License

Apache License 2.0 — see [LICENSE](LICENSE) for details.
