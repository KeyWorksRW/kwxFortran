# kwxFortran

> **🚧 ALPHA — NOT READY FOR USE 🚧**
>
> This project is in early alpha. The API is unstable, breaking changes happen without warning, and large portions have not yet been runtime-tested. **Do not use this in any production or serious project.**

---

Fortran bindings to the [wxWidgets](https://www.wxwidgets.org/) GUI library, enabling native platform UI from Fortran on Windows, Linux, and macOS.

## How It Works

```
Fortran code  →  ISO_C_BINDING interfaces  →  kwxFFI (C functions)  →  wxWidgets (C++)
```

kwxFortran is a thin Fortran layer over [kwxFFI](https://github.com/KeyWorksRW/kwxFFI), a C-callable wrapper for wxWidgets. Fortran modules use `ISO_C_BINDING` to call kwxFFI's exported C functions, which in turn drive wxWidgets.

## Current Status

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Foundation — build system, types, string utilities | ✅ Complete |
| 2 | Core Windows — App, Frame, Window base class | 🔧 Demo Builds and runs |
| 3 | Controls, events, dialogs, sizers, … | ✅ Complete testing in progress |

Because kwxFFI itself is also under active development, **breaking changes in kwxFFI will propagate here**. Do not depend on any API being stable.

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

See [Apache 2.0 LICENSE](LICENSE).
