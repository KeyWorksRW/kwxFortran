# Implementation Plan: kwxFortran — Fortran Bindings for wxWidgets via wxFFI

## Problem Statement

Create a Fortran language binding to the wxWidgets GUI library by leveraging the existing wxFFI C-callable interface layer. This enables Fortran applications to create native cross-platform GUIs using wxWidgets.

---

## Prerequisites

### Required Tools

| Tool | Version | Installation |
|------|---------|--------------|
| **gfortran** | 8.0+ | Required — Fortran compiler with ISO_C_BINDING support |
| CMake | 3.16+ | Build system |
| Ninja | 1.10+ | Build tool (recommended) |

### Optional Compilers

| Tool | Version | Notes |
|------|---------|-------|
| Intel ifort | 19.0+ | Alternative Fortran compiler (Windows/Linux) |
| Intel ifx | 2021+ | Modern Intel LLVM-based compiler |
| LLVM flang | 15+ | Future support, currently experimental |

### Installation by Platform

#### Windows
```powershell
# Option 1: MSYS2 (recommended)
pacman -S mingw-w64-x86_64-gcc-fortran mingw-w64-x86_64-cmake mingw-w64-x86_64-ninja

# Option 2: Chocolatey
choco install mingw cmake ninja

# Option 3: Intel oneAPI (for ifort/ifx)
# Download from https://www.intel.com/content/www/us/en/developer/tools/oneapi/fortran-compiler.html
```

#### Ubuntu/Debian
```bash
# gfortran is typically pre-installed, but to ensure:
sudo apt-get update
sudo apt-get install -y gfortran cmake ninja-build
```

#### macOS
```bash
brew install gcc cmake ninja
# Note: 'gcc' formula includes gfortran
```

### GitHub Actions / Copilot Agent Runner Notes

> **Important for CI/CD**: GitHub-hosted runners have different pre-installed tools:
>
> | Runner OS | gfortran | Action Required |
> |-----------|----------|-----------------|
> | `ubuntu-latest` | ✅ Pre-installed | None — available via `build-essential` |
> | `windows-latest` | ❌ Not installed | Must install via MSYS2 or Chocolatey |
> | `macos-latest` | ❌ Not installed | Must install via `brew install gcc` |

**Example GitHub Actions step for Windows:**
```yaml
- name: Install gfortran (Windows)
  if: runner.os == 'Windows'
  run: |
    choco install mingw -y
    echo "C:\ProgramData\chocolatey\lib\mingw\tools\install\mingw64\bin" >> $env:GITHUB_PATH
```

**Example GitHub Actions step for macOS:**
```yaml
- name: Install gfortran (macOS)
  if: runner.os == 'macOS'
  run: brew install gcc
```

---

## Project Context

### Reference Projects
- `kwxLuaJit-dev` — LuaJIT binding using LuaJIT FFI
- `kwxRust-dev` — Rust binding
- `kwxGO-dev`, `kwxJulia-dev`, `kwxPerl-dev`, `kwxPascal-dev` — Other language bindings

### kwxFFI Integration
- **Dependency management**: kwxFFI is fetched via CMake FetchContent (not a submodule)
- **Build location**: `build/_deps/kwxffi-src` (source), `build/_deps/kwxffi-build` (build artifacts)
- **wxWidgets**: Also fetched via FetchContent to `build/_deps/wxwidgets-src`

### wxFFI Architecture (from `.github/wxffi-architecture.md`)
- **Function naming**: `wx<ClassName>_<MethodName>` (e.g., `wxButton_Create`)
- **Application lifecycle**: `kwxApp_*` functions (e.g., `kwxApp_Initialize`, `kwxApp_MainLoop`)
- **Type macros**: `TClass(tp)` → `void*`, `TBool` → `int`, `TString` → `char*`
- **String handling**: Uses `wxString*` pointers with UTF-8 conversion helpers
- **Memory management**: Parent-owned UI objects, explicit deletion for some types
- **Constants**: Exported as functions: `exp<CONSTANT_NAME>()` (e.g., `expwxDEFAULT_FRAME_STYLE()`)
- **Events**: Closure-based callback system with `wxClosure`

---

## Proposed Solution

### Architecture Overview

```
kwxFortran/
├── src/
│   ├── kwxApp.cpp            # C++ implementation of wxApp (compiled into library)
│   ├── kwx_bindings.f90    # ISO_C_BINDING interfaces to wxFFI functions
│   ├── kwx_types.f90       # Fortran type definitions (opaque pointers, etc.)
│   ├── kwx_constants.f90   # Constant values from wxWidgets
│   ├── wx_string.f90         # String conversion utilities
│   ├── wx_app.f90            # Fortran wrapper for kwxApp_* functions
│   ├── wx_frame.f90          # Frame class wrapper
│   ├── wx_window.f90         # Window base class wrapper
│   ├── wx_controls.f90       # Button, TextCtrl, etc.
│   ├── wx_sizers.f90         # Sizer layout classes
│   ├── wx_events.f90         # Event handling and callbacks
│   └── wx.f90                # Main module (use wx)
├── examples/
│   ├── minimal.f90           # Minimal window example
│   └── hello.f90             # Hello World with button
├── tests/
│   └── test_bindings.f90     # Unit tests
├── CMakeLists.txt            # Build configuration
└── README.md                 # Documentation
```

### Key Fortran FFI Patterns

#### 1. ISO_C_BINDING for C Interoperability
```fortran
module kwx_bindings
    use, intrinsic :: iso_c_binding
    implicit none

    interface
        function wxFrame_Create(parent, id, title, x, y, w, h, style) &
            bind(C, name="wxFrame_Create")
            import :: c_ptr, c_int
            type(c_ptr), value :: parent
            integer(c_int), value :: id
            type(c_ptr), value :: title    ! wxString*
            integer(c_int), value :: x, y, w, h, style
            type(c_ptr) :: wxFrame_Create
        end function
    end interface
end module
```

#### 2. Opaque Pointer Types
```fortran
module kwx_types
    use, intrinsic :: iso_c_binding
    implicit none

    type :: wxWindow_t
        type(c_ptr) :: ptr = c_null_ptr
    end type

    type, extends(wxWindow_t) :: wxFrame_t
    end type

    type, extends(wxWindow_t) :: wxButton_t
    end type
end module
```

#### 3. String Conversion
```fortran
module wx_string
    use, intrinsic :: iso_c_binding
    implicit none

    interface
        function wxString_CreateUTF8(str) bind(C, name="wxString_CreateUTF8")
            import :: c_ptr, c_char
            character(c_char), intent(in) :: str(*)
            type(c_ptr) :: wxString_CreateUTF8
        end function

        subroutine wxString_Delete(str) bind(C, name="wxString_Delete")
            import :: c_ptr
            type(c_ptr), value :: str
        end subroutine
    end interface

contains
    function to_wxstring(fstring) result(ptr)
        character(len=*), intent(in) :: fstring
        type(c_ptr) :: ptr
        ptr = wxString_CreateUTF8(trim(fstring) // c_null_char)
    end function
end module
```

#### 4. Event Callbacks via C_FUNPTR
```fortran
module wx_events
    use, intrinsic :: iso_c_binding
    implicit none

    abstract interface
        subroutine event_handler(fun, data, evt) bind(C)
            import :: c_ptr
            type(c_ptr), value :: fun, data, evt
        end subroutine
    end interface

contains
    subroutine connect_event(window, event_type, handler, user_data)
        type(c_ptr), intent(in) :: window
        integer(c_int), intent(in) :: event_type
        procedure(event_handler) :: handler
        type(c_ptr), intent(in) :: user_data

        type(c_funptr) :: fptr
        fptr = c_funloc(handler)
        ! Call wxEvtHandler_Connect via FFI
    end subroutine
end module
```

---

## Implementation Phases

### ✅ Phase 1: Foundation -- Completed
**Objective:** Establish build system and basic FFI infrastructure

**Files to create:**
1. `CMakeLists.txt` — CMake build with FetchContent for wxFFI
2. `src/kwx_types.f90` — Opaque pointer types
3. `src/wx_string.f90` — String conversion helpers

**Verification:**
- Build compiles with gfortran/ifort
- Can link against wxFFI library
- String conversion round-trip test passes

### Phase ✅ 2: Core Window Classes (Complexity: Moderate) -- Completed
**Objective:** Implement minimal windowing capability

**Files to create:**
1. `src/kwxApp.cpp` — C++ implementation of wxApp subclass (copy/adapt from `build/_deps/kwxffi-src/examples/CApp/kwxApp.cpp`)
2. `src/kwx_bindings.f90` — Raw C bindings for:
   - `kwxApp_*` functions (application lifecycle from kwxApp.h)
   - `wxFrame_*` functions
   - `wxWindow_*` functions
3. `src/kwx_constants.f90` — Essential constants:
   - `wxID_ANY`, `wxDEFAULT_FRAME_STYLE`, etc.
4. `src/wx_app.f90` — Fortran wrapper for kwxApp_* C functions
5. `src/wx_frame.f90` — Frame wrapper
6. `src/wx_window.f90` — Window base wrapper
7. `examples/minimal.f90` — Empty window example

**kwxApp Integration:**
The kwxApp interface (defined in `build/_deps/kwxffi-src/examples/CApp/kwxApp.h`) provides:
```c
int kwxApp_Initialize(int argc, char** argv);  // Initialize wxWidgets
int kwxApp_MainLoop(void);                     // Run event loop
void kwxApp_ExitMainLoop(void);                // Exit from event handler
void kwxApp_SetTopWindow(void* window);        // Set main frame
void kwxApp_SetAppName(const char* name);      // Set app name
void kwxApp_InitAllImageHandlers(void);        // Enable image support
```

**Build: ✅ PASS** - kwxFFI issues resolved, build structure reorganized

**Output directories:**
- `bin/Debug/` and `bin/Release/` — Executables and runtime DLLs (kwxFFI.dll, minimal.exe)
- `lib/Debug/` and `lib/Release/` — Static libraries (kwxFortran.lib)

**Verification:**
- ✅ `minimal.f90` builds and links
- ⏳ Window appearance and interaction (manual test required)
  - Launch via: Press F5 in VS Code (Debug minimal) or run `bin/Debug/minimal.exe`
  - Verify: Window appears with title and status bar
  - Verify: Window can be closed cleanly

**Next Steps:**
Complete manual verification, then proceed to Phase 3

**Verification:**
- `minimal.f90` builds and runs
- Window appears on screen
- Window can be closed

### Phase ✅ 3: Basic Controls (Complexity: Moderate) -- Completed
**Objective:** Add common UI controls

**Files to create/modify:**
1. Add to `src/kwx_bindings.f90`:
   - `wxButton_*`, `wxTextCtrl_*`, `wxStaticText_*`
   - `wxPanel_*`, `wxBoxSizer_*`
2. `src/wx_controls.f90` — Control wrappers
3. `src/wx_sizers.f90` — Sizer wrappers
4. `examples/hello.f90` — Hello World with button

**Verification:**
- Can create buttons, text controls
- Sizers layout controls correctly
- Example displays "Hello World" with working button

### Phase ✅ 4: Event Handling ✅ Completed (Complexity: Complex)
**Objective:** Enable event-driven programming

**Implementation:**
1. Modified `src/kwxApp.cpp`:
   - Added `HandleEvent` method to `kwxAppImpl` (routes events through closures)
   - Added `kwxApp_Connect` / `kwxApp_Disconnect` C functions
   - Forward-declared wxClosure/wxCallback from kwxFFI
2. Modified `src/kwx_bindings.f90`:
   - Added `kwxApp_Connect`, `kwxApp_Disconnect` bindings
   - Added `wxClosure_Create`, `wxClosure_GetData` bindings
   - Added `wxEvent_*` accessor bindings (GetEventType, GetId, Skip, etc.)
   - Added `wxCommandEvent_*` accessor bindings (GetString, GetSelection, etc.)
3. Modified `src/kwx_constants.f90`:
   - Added event type constants: `wxEVT_COMMAND_BUTTON_CLICKED`,
     `wxEVT_COMMAND_CHECKBOX_CLICKED`, `wxEVT_COMMAND_CHOICE_SELECTED`,
     `wxEVT_COMMAND_TEXT_UPDATED`, `wxEVT_COMMAND_TEXT_ENTER`,
     `wxEVT_COMMAND_MENU_SELECTED`
4. Created `src/wx_events.f90`:
   - `event_callback` abstract interface for handler procedures
   - `wx_connect` / `wx_disconnect` with optional ID range parameters
   - All `wx_event_*` and `wx_command_event_*` accessor wrappers
5. Updated `examples/hello.f90`:
   - Added `hello_handlers` module with `on_button_click` callback
   - Connected button click event to handler via `wx_connect`

**Key design decisions:**
- Used `kwxApp_Connect`/`kwxApp_Disconnect` (not `wxEvtHandler_Connect` which
  is declared but not exported in kwxFFI) following the SampleApp pattern
- HandleEvent routes through `evt.m_callbackUserData` → wxCallback → wxClosure
- Closure system is reference-counted by kwxFFI

**Verification:**
- ✅ Build succeeds (all 8 targets including hello.exe)
- Button click triggers Fortran callback (prints count and event ID)
- Event data accessible via accessor functions
- Runtime testing needed (F5 → "Debug minimal" launch config)

### Phase 5: Extended Controls (Complexity: Moderate) ✅
**Objective:** Add more UI controls for practical applications

**Files to create/modify:**
1. Add bindings for:
   - `wxCheckBox`, `wxRadioButton`, `wxChoice`
   - `wxListBox`, `wxComboBox`
   - `wxMenu`, `wxMenuBar`, `wxMenuItem`
   - `wxStatusBar`, `wxToolBar`
2. Create corresponding wrapper modules
3. `examples/controls_demo.f90` — Comprehensive controls example

**Verification:**
- All controls render correctly
- Events work for all control types
- Menu system functional

### Phase 6: Dialogs and Advanced Features (Complexity: Moderate)
**Objective:** Add dialog support and polish

**Files to create/modify:**
1. Add bindings for:
   - `wxMessageDialog`, `wxFileDialog`, `wxDirDialog`
   - `wxColourDialog`, `wxFontDialog`
   - Custom dialog support
2. Wrapper modules for dialogs
3. Documentation improvements

**Verification:**
- Standard dialogs work
- File/directory selection returns paths
- Modal behavior correct

---

## Technical Considerations

### Fortran Compiler Compatibility
| Compiler | ISO_C_BINDING | C_FUNLOC | Notes |
|----------|---------------|----------|-------|
| gfortran 8+ | ✓ | ✓ | Primary target (all platforms), required for CI |
| Intel ifort 19+ | ✓ | ✓ | Windows (legacy), requires MSVC |
| Intel ifx | ✓ | ✓ | Windows development compiler, requires MSVC |
| LLVM flang | ✓ | ✓ | Future target |

**Windows Dual Compiler Strategy:**
- **Development**: Use Intel ifx (free from oneAPI) with MSVC for best optimization
- **CI/CD**: Build **two** Windows binaries:
  - `kwxFortran-ifx-windows.dll` (ifx + `.mod` files for Intel Fortran users)
  - `kwxFortran-gfortran-windows.dll` (gfortran + `.mod` files for gfortran users)
- **Distribution**: Users download the version matching their compiler
- **Rationale**: Fortran `.mod` files are compiler-specific; shipping both ensures compatibility

**Important:** CMake requires a **consistent toolchain**:
- **MinGW**: Use `g++` + `gfortran` together
- **MSVC**: Use `cl.exe` + Intel Fortran (`ifort`/`ifx`) together
- **Do not mix** MSVC C++ with gfortran - linker flags are incompatible

### Memory Management Strategy
1. **UI objects**: Let wxWidgets manage via parent hierarchy
2. **wxString**: Create/delete wrapper functions, RAII-like pattern
3. **Closures**: Prevent garbage collection of Fortran procedures

### Callback Implementation
Fortran 2003+ supports `C_FUNPTR` and `C_FUNLOC` for passing procedure addresses to C. The wxFFI closure system expects:
```c
typedef void(_cdecl *ClosureFun)(void* _fun, void* _data, void* _evt);
```

Fortran equivalent:
```fortran
subroutine my_handler(fun, data, evt) bind(C)
    type(c_ptr), value :: fun, data, evt
    ! Extract event info, call user's Fortran procedure
end subroutine
```

---

## Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Callback complexity with closures | High | Start with simple pattern, test extensively |
| String encoding issues | Medium | Stick to UTF-8, test with non-ASCII |
| Memory leaks | Medium | Document ownership, provide cleanup |
| Compiler incompatibilities | Medium | Focus on gfortran first, test others later |
| wxFFI API changes | Low | Pin wxFFI version, track changes |

---

## Success Criteria

1. **Minimal example** compiles and runs showing a window
2. **Hello World** demonstrates controls, sizers, and events
3. **Build system** works on Windows (MSVC/gfortran) and Linux (gfortran)
4. **Documentation** enables users to create basic GUIs
5. **No memory leaks** in normal usage patterns

---

## Next Steps

1. **Review this plan** — Confirm approach and priorities
2. **Phase 1 implementation** — Set up CMake and basic types
3. **Iterate** — Build incrementally with verification at each phase

---

## References

- [wxFFI Architecture](.github/wxffi-architecture.md) — C API documentation
- [Fortran ISO_C_BINDING](https://gcc.gnu.org/onlinedocs/gfortran/ISO_005fC_005fBINDING.html) — Interoperability standard
- [Modern Fortran Best Practices](https://fortran-lang.org/learn/best_practices) — Style guide
