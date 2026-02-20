# kwxFFI Architecture Reference (AI Agent Guide)

> **Purpose**: This document explains how kwxFFI works for AI agents assisting with language port development. Read this before analyzing or modifying any language binding code.

## Overview

kwxFFI (wxWidgets Foreign Function Interface) is a C-callable interface layer that wraps wxWidgets C++ classes. It enables any language with a Foreign Function Interface (FFI) to call wxWidgets functionality without needing C++ interop.

**Key insight**: kwxFFI is the shared foundation for all language ports (kwxLuaJIT, kwxRust, kwxFortran, kwxGO, kwxJulia, kwxPerl). All language bindings call the same C functions exposed by kwxFFI.

## Directory Structure

```
kwxFFI/
├── include/
│   ├── wrapper.h        # Precompiled header with all wxWidgets includes and helper classes
│   ├── wxffi_def.h      # Export macros (EXPORT, WXFFI_FUNC, WXFFI_EXPORT, etc.)
│   ├── wxffi_types.h    # Type macros (TClass, TString, TBool, TPoint, etc.)
│   ├── wxffi_glue.h     # All C wrapper function declarations (7500+ lines)
│   ├── wxffi_grid.h     # Callback types and helper class for custom grid data sources
│   └── wxc_types.h      # Additional type definitions
├── src/
│   ├── wrapper.cpp      # Closures, callbacks, and event handling
│   ├── wx_*.cpp         # Per-control implementation files
│   ├── defs.cpp         # wxWidgets constants exported as functions
│   └── std.cpp          # C++ to C type conversion helpers
├── examples/
│   └── CApp/            # Reference implementation for application startup
│       ├── kwxApp.h     # Pure C interface for wxWidgets app lifecycle
│       ├── kwxApp.cpp   # Implementation (hidden from C callers)
│       └── example_main.c  # Example usage from pure C
└── CMakeLists.txt
```

## Build Requirements

- **wxWidgets 3.3.1 or later** (enforced via `#if !wxCHECK_VERSION(3, 3, 1)`)
- **UTF-8 mode enabled**: `wxUSE_UNICODE_UTF8 = 1` in wxWidgets setup.h
- Compiles to: `kwxffi.dll` (Windows), `libkwxffi.so` (Linux), `libkwxffi.dylib` (macOS)

## Core Concepts

### 1. Function Naming Convention

All exported functions follow the pattern:
```
wx<ClassName>_<MethodName>
```

Examples:
- `wxButton_Create` - Constructor for wxButton
- `wxButton_SetDefault` - wxButton::SetDefault() method
- `wxTextCtrl_GetValue` - wxTextCtrl::GetValue() method
- `wxWindow_Show` - wxWindow::Show() method

### 2. The `extern "C"` Pattern

Every function is wrapped in `extern "C"` to provide C linkage:

```cpp
extern "C"
{
    EXPORT wxButton* wxButton_Create(wxWindow* _prt, int _id, wxString* _txt,
                                     int _lft, int _top, int _wdt, int _hgt, int _stl)
    {
        return new wxButton(_prt, _id, *_txt, wxPoint(_lft, _top),
                           wxSize(_wdt, _hgt), _stl, wxDefaultValidator);
    }
}
```

### 3. Type Macros (wxffi_types.h)

kwxFFI uses macros to abstract types for portability:

| Macro | Default Expansion | Purpose |
|-------|-------------------|---------|
| `TClass(tp)` | `void*` or `tp*` | Pointer to wxWidgets class |
| `TSelf(tp)` | Same as TClass | `this` pointer in methods |
| `TClassRef(tp)` | Same as TClass | Reference parameter |
| `TBool` | `int` or `bool` | Boolean values |
| `TString` | `TChar*` | String input parameter |
| `TStringOut` | `TChar*` | String output parameter |
| `TPoint(x,y)` | `int x, int y` | Point as two ints |
| `TSize(w,h)` | `int w, int h` | Size as two ints |
| `TRect(x,y,w,h)` | `int x, int y, int w, int h` | Rectangle as four ints |

When `WXC_USE_TYPED_INTERFACE` is defined, `TClass(tp)` expands to the actual type pointer for better type safety during development.

### 4. String Handling

**Critical**: kwxFFI uses `wxString*` (pointer to wxString) for string parameters:

```cpp
// Input: caller passes wxString*, function dereferences
EXPORT void wxTextCtrl_SetValue(wxTextCtrl* self, wxString* value)
{
    self->SetValue(*value);  // Note: dereference
}

// Output: function allocates new wxString, caller must delete
EXPORT wxString* wxTextCtrl_GetValue(void* self)
{
    wxString* result = new wxString();
    *result = ((wxTextCtrl*) self)->GetValue();
    return result;  // Caller owns this memory
}
```

**Language bindings must**:
1. Create wxString objects from native strings before calling input functions
2. Delete wxString objects returned from output functions after extracting the content
3. Use `wxString_CreateUTF8` and `wxString_GetUTF8` helper functions for conversion

### 5. Object Lifetime Management

kwxFFI provides two patterns for memory management:

#### Pattern A: wxWidgets owns the object
Most UI elements (windows, controls) are owned by their parent and deleted automatically:
```cpp
wxButton* btn = wxButton_Create(parent, id, ...);  // parent owns btn
```

#### Pattern B: Caller owns the object
Some objects must be explicitly deleted:
```cpp
wxString* str = wxTextCtrl_GetValue(ctrl);
// ... use str ...
wxString_Delete(str);  // Must call to avoid leak
```

### 6. Constants and Enums

wxWidgets constants are exposed as functions returning int:

```cpp
// In kwx_defs.cpp
EXPORT int expwxDEFAULT_FRAME_STYLE() { return (int) wxDEFAULT_FRAME_STYLE; }
EXPORT int expwxTE_MULTILINE() { return (int) wxTE_MULTILINE; }
EXPORT int expwxALIGN_CENTER() { return (int) wxALIGN_CENTER; }
```

Naming: `exp<CONSTANT_NAME>()` - prefix "exp" for "export"

### 7. Event Handling

Events use a closure-based callback system:

```cpp
// Closure types (kwx_wrapper.h)
typedef void (*ClosureFun)(void* closureFun, void* data, void* event);

// wxClosure class wraps callback + user data
class wxClosure {
    ClosureFun m_fun;
    void* m_data;
    void Invoke(wxEvent* evt);  // Calls m_fun with evt
};
```

Event type constants are exposed similarly to other constants:
```cpp
EXPORT int expEVT_COMMAND_BUTTON_CLICKED() { return (int) wxEVT_BUTTON; }
```

#### wxClosure Destructor Cleanup Call

**Critical**: When a `wxClosure` is destroyed (e.g., at app shutdown), its destructor calls the registered callback **one final time with `event = nullptr`**:

```cpp
wxClosure::~wxClosure()
{
    // call for the last time with a nullptr event. Give opportunity to clean up resources
    if (m_fun)
    {
        m_fun((void*) m_fun, m_data, nullptr);
    }
}
```

This is intentional — it gives language bindings an opportunity to release any resources tied to the closure. By the time this fires, the wxWidgets window hierarchy has already been torn down.

**All language binding event handlers MUST guard against the null event.** Accessing any widget from a null-event call will crash because the controls are already destroyed.

Required pattern in every callback:
```c
void my_handler(void* fun, void* data, void* event) {
    if (event == NULL) return;   // cleanup call — widgets already destroyed
    // ... normal event handling ...
}
```

### 8. Common Parameter Patterns

#### Point and Size decomposition
wxPoint and wxSize are passed as separate int parameters:
```cpp
// Instead of wxPoint(100, 200), pass: int _lft=100, int _top=200
// Instead of wxSize(300, 400), pass: int _wdt=300, int _hgt=400
wxButton_Create(parent, id, text, 100, 200, 300, 400, style);
```

#### Output parameters
Functions returning multiple values use pointer parameters:
```cpp
EXPORT void wxWindow_GetSize(wxWindow* self, int* w, int* h)
{
    wxSize sz = self->GetSize();
    *w = sz.GetWidth();
    *h = sz.GetHeight();
}
```

## Application Lifecycle

kwxFFI provides a pure C interface for application startup via `kwxApp` (see `examples/CApp/`):

```c
// From kwxApp.h - the C interface foreign languages use
int kwxApp_Initialize(int argc, char** argv);  // Call once before any wx functions
int kwxApp_MainLoop(void);                     // Run event loop, blocks until exit
void kwxApp_ExitMainLoop(void);                // Call from event handler to quit
void kwxApp_Shutdown(void);                    // Optional cleanup

// Application properties
void kwxApp_SetAppName(const char* name);
void kwxApp_SetTopWindow(void* window);
void kwxApp_SetExitOnFrameDelete(int flag);

// Idle timer for periodic background tasks
typedef void (*kwxApp_IdleCallback)(void* data);
void kwxApp_SetIdleCallback(int interval_ms, kwxApp_IdleCallback callback, void* data);
```

The implementation (`kwxApp.cpp`) contains a hidden `kwxAppImpl : wxApp` subclass. Foreign languages never see the C++ code—they only use the C interface.

## File Organization by Category

| File Pattern | Contents |
|--------------|----------|
| `wx_<control>.cpp` | Single control implementation (wx_button, wx_textctrl, etc.) |
| `kwx_wrapper.cpp` | Closures, callbacks, helper classes |
| `kwx_defs.cpp` | Constant exports |
| `kwx_std.cpp` | C++/C type conversions |
| `wx_event.cpp` | Event classes and event type exports |
| `examples/CApp/` | Reference implementation for app startup |

## Helper Classes (kwx* prefix)

Several classes in `kwx_wrapper.h` derive from wxWidgets classes to support callbacks:

| Class | Purpose |
|-------|--------|
| `wxClosure` | Reference-counted wrapper for foreign function pointer + data |
| `wxCallback` | Connects to wxWidgets event system, invokes closures |
| `kwxDropTarget` | Drag-and-drop target with foreign callbacks |
| `kwxTextDropTarget` | Text-specific drop target |
| `kwxFileDropTarget` | File-specific drop target |
| `kwxDragDataObject` | Custom data object with foreign callbacks |

Note: Older "ELJ" prefix classes from wxHaskell origins have been renamed to "kwx" prefix.

## How Language Bindings Use kwxFFI

Each language binding:

1. **Loads the shared library**: `kwxffi.dll` / `libkwxffi.so`
2. **Declares function signatures**: Maps C signatures to language types
3. **Wraps in OO classes**: Creates idiomatic class wrappers
4. **Manages memory**: Handles wxString creation/deletion, cleanup

Example (conceptual Rust):
```rust
extern "C" {
    fn wxButton_Create(parent: *mut c_void, id: c_int, txt: *mut c_void,
                       left: c_int, top: c_int, width: c_int, height: c_int,
                       style: c_int) -> *mut c_void;
}
```

Example (conceptual LuaJIT):
```lua
ffi.cdef[[
    void* wxButton_Create(void* parent, int id, void* txt,
                          int left, int top, int width, int height, int style);
]]
```

## Key Differences from wxHaskell/wxc Origins

- Fixed C++ files (not generated)
- Most macros expanded for readability
- Deprecated API removed
- Pre-3.0 compatibility code removed
- UTF-8 strings only (wxUSE_UNICODE_UTF8)
- Targets wxWidgets 3.3.1+ exclusively
- ELJ* classes renamed to kwx* prefix
- Pure C application startup via kwxApp (no IMPLEMENT_APP_NO_MAIN needed)

## Common Patterns for AI Analysis

When analyzing language binding code, look for:

1. **FFI loading**: How the binding loads kwxffi library
2. **App initialization**: Uses kwxApp_Initialize() / kwxApp_MainLoop() pattern
3. **Type mapping**: How C types map to language types (especially `void*` → object)
4. **String conversion**: How UTF-8 strings convert to/from wxString*
5. **Event binding**: How callbacks/closures are implemented
6. **Memory management**: Who owns allocated objects, when cleanup happens

## Debugging Tips

- Exported symbols start with `wx` (functions), `exp` (constants), or `kwxApp_` (app lifecycle)
- Check if wxWidgets was built with `wxUSE_UNICODE_UTF8=1`
- String issues often come from missing wxString creation/deletion
- Event issues often come from incorrect closure setup

## Credits

This project is based on the FFI layer from [wxHaskell](https://codeberg.org/wxHaskell/wxHaskell).
