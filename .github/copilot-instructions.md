# kwxFortran — Fortran Bindings for wxWidgets via kwxFFI

## Project Overview

kwxFortran provides Fortran language bindings to the wxWidgets GUI library through the kwxFFI C-callable interface. Fortran code uses `ISO_C_BINDING` to call C functions exported by kwxFFI, which in turn calls wxWidgets C++.

```
Fortran code  →  ISO_C_BINDING interfaces  →  kwxFFI (C functions)  →  wxWidgets (C++)
```

For the complete kwxFFI C API reference, see `.github/wxffi-architecture.md`.

## Current Status

- **Phase 1 (Foundation)**: ✅ Complete — build system, types, string utilities
- **Phase 2 (Core Windows)**: 🔧 In progress — builds successfully, runtime testing needed
- See `plan.md` for full implementation roadmap

## Build System

- **Compiler**: Intel Fortran `ifx` (LLVM-based) with MSVC C++ toolchain
- **Build tool**: CMake + Ninja
- **kwxFFI**: Fetched via CMake `FetchContent` (not a submodule)
- **wxWidgets**: Fetched transitively through kwxFFI's own FetchContent

### Build commands
```
# Debug (default)
cd build && ninja

# Release
cd build && ninja -f build-Release.ninja
```

### Output directories
| Artifact | Location |
|----------|----------|
| Executables + DLLs | `bin/Debug/` or `bin/Release/` |
| Static libraries | `lib/Debug/` or `lib/Release/` |
| Fortran `.mod` files | `build/modules/` |

## Source Layout

```
src/
  kwxApp.cpp            # C++ wxApp subclass (compiled into kwxFortran.lib)
  wxffi_types.f90       # Opaque pointer types (wxFrame_t, wxButton_t, etc.)
  wx_string.f90         # Fortran ↔ wxString* conversion utilities
  wxffi_bindings.f90    # Raw ISO_C_BINDING interfaces to kwxFFI C functions
  wxffi_constants.f90   # wxWidgets constants (wxID_ANY, wxDEFAULT_FRAME_STYLE, etc.)
  wx_app.f90            # High-level Fortran wrapper for application lifecycle
  wx_window.f90         # Window base class wrapper
  wx_frame.f90          # Frame (top-level window) wrapper
examples/
  minimal.f90           # Minimal window example
file_list.cmake         # Source file lists (included by CMakeLists.txt)
```

## Architecture Rules

### Module dependency order (enforced by compile order in file_list.cmake)
```
wxffi_types         ← no project dependencies
wx_string           ← depends on wxffi_types
wxffi_bindings      ← depends on iso_c_binding only
wxffi_constants     ← depends on iso_c_binding only
wx_app              ← depends on wxffi_types, wxffi_bindings
wx_window           ← depends on wxffi_types, wxffi_bindings, wxffi_constants, wx_string
wx_frame            ← depends on wxffi_types, wxffi_bindings, wxffi_constants, wx_string
```

When adding new modules, place them in `file_list.cmake` *after* their dependencies.

### Two-layer binding pattern

Every wxFFI function is bound at two levels:

1. **`wxffi_bindings.f90`** — Raw `bind(C)` interface declarations matching the C function signatures exactly. These use `c_ptr`, `c_int`, etc.

2. **`wx_*.f90` wrapper modules** — Idiomatic Fortran API with optional parameters, string conversion, type-safe wrappers, and default values.

Example: Creating a frame

```fortran
! Layer 1 (wxffi_bindings.f90) — raw C binding
function wxFrame_Create(parent, id, title, x, y, w, h, style) &
    bind(C, name="wxFrame_Create")
    import :: c_ptr, c_int
    type(c_ptr), value :: parent
    integer(c_int), value :: id
    type(c_ptr), value :: title    ! wxString*
    integer(c_int), value :: x, y, w, h, style
    type(c_ptr) :: wxFrame_Create
end function

! Layer 2 (wx_frame.f90) — idiomatic Fortran
function wx_frame_create(title, parent, id, x, y, width, height, style) result(frame)
    character(len=*), intent(in) :: title
    ! ... optional params with defaults ...
    type(wxFrame_t) :: frame
    ! handles string conversion, applies defaults, calls Layer 1
end function
```

### Type system

All wxWidgets objects are opaque `c_ptr` values wrapped in Fortran derived types defined in `wxffi_types.f90`:

```fortran
type :: wxWindow_t
    type(c_ptr) :: ptr = c_null_ptr
contains
    procedure :: is_valid => wxWindow_is_valid
end type

type, extends(wxWindow_t) :: wxFrame_t
end type
```

The inheritance chain mirrors wxWidgets: `wxFrame_t` extends `wxWindow_t`. Always check `%is_valid()` after creation.

### String handling

kwxFFI uses `wxString*` (heap-allocated pointer). Fortran strings must be converted:

```fortran
use wx_string
type(c_ptr) :: ws

ws = to_wxstring("Hello")       ! Creates wxString* (caller owns)
! ... use ws in kwxFFI calls ...
call wxString_Delete(ws)        ! MUST delete to avoid leak
```

For return values, use `from_wxstring()` to extract content, then `wxString_Delete` the pointer.

### Constants

wxWidgets constants are exposed by kwxFFI as C functions prefixed with `exp`:

```fortran
! In wxffi_constants.f90
function wxID_ANY() bind(C, name="expwxID_ANY")
    import :: c_int
    integer(c_int) :: wxID_ANY
end function
```

These are callable as regular Fortran functions: `id = wxID_ANY()`.

### Application lifecycle

The app lifecycle is managed through `kwxApp_*` functions (C++) wrapped by `wx_app.f90`:

```fortran
use wx_app
call wx_initialize()          ! kwxApp_Initialize — creates wxApp
! ... create windows ...
exit_code = wx_main_loop()    ! kwxApp_MainLoop — blocks until quit
call wx_shutdown()            ! kwxApp_Shutdown — cleanup
```

The C++ side (`src/kwxApp.cpp`) contains the hidden `kwxAppImpl : wxApp` subclass. Fortran never touches C++ directly.

## Coding Conventions

### Fortran style
- **Free-form source** (`.f90` extension)
- `implicit none` in every module and program
- `private` by default in modules, explicit `public` for API
- `intent(in/out/inout)` on all procedure arguments
- Use `integer(c_int)`, `type(c_ptr)` etc. for FFI boundaries; plain Fortran types in wrapper APIs
- Comments: `!` prefix, descriptive headers for each procedure

### Naming
| Entity | Convention | Example |
|--------|-----------|---------|
| Modules | `snake_case` | `wx_frame`, `wxffi_bindings` |
| Types | `PascalCase_t` suffix | `wxFrame_t`, `wxButton_t` |
| Wrapper functions | `wx_<class>_<action>` | `wx_frame_create`, `wx_frame_show` |
| Raw bindings | Match C name exactly | `wxFrame_Create`, `kwxApp_Initialize` |
| Constants | Match wxWidgets name | `wxID_ANY`, `wxDEFAULT_FRAME_STYLE` |

### Adding a new wxWidgets class binding

1. Add the type to `wxffi_types.f90` (with `is_valid` method)
2. Add raw `bind(C)` interfaces to `wxffi_bindings.f90`
3. Add any needed constants to `wxffi_constants.f90`
4. Create `wx_<class>.f90` with idiomatic Fortran wrappers
5. Add the new `.f90` file to `file_list.cmake` in dependency order
6. Update `examples/` to exercise the new class

## Running Programs

**Do not run programs from `key_term` or `run_in_terminal`.** GUI apps will hang the terminal.

- **Preferred**: Use the `Debug minimal` launch configuration (F5 in VS Code)
- **Alternative**: Provide command-line instructions for manual execution

To add new examples, create a launch.json configuration similar to the existing `Debug minimal`.

## kwxFFI Issues

**Do NOT create workarounds for missing features or bugs in kwxFFI.** The user owns kwxFFI and wants issues fixed at the source.

When you encounter a missing export, missing function, bug, or limitation in kwxFFI:
1. **Stop** — do not implement a workaround
2. **Explain** the problem clearly (what's missing, what you tried, expected behavior)
3. **Ask** if the user wants to create an issue in kwxFFI
4. If yes, use `gh issue create --repo KeyWorksRW/kwxFFI --assignee Randalphwa --title "..." --body "..."` to create the issue
5. **Wait** for the issue to be fixed before continuing with that feature

## Toolchain Note

**Windows**: Intel `ifx` requires MSVC toolchain (`cl.exe` for C++). Do **not** mix MSVC C++ with gfortran — linker flags are incompatible. The valid pairings are:
- `cl.exe` + `ifx` (current setup)
- `g++` + `gfortran` (MinGW alternative)
