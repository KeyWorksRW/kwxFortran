
## What wxUiEditor generates

Assuming wxUiEditor generates a `.f90` UI file plus a hand-written main program, the consumer layout would be:

```
quick/fortran/
  CMakeLists.txt        ← as above
  CMakePresets.json     ← inherits kwxFortran presets or defines its own
  src/
    main.f90            ← hand-written
    mainframe.f90       ← wxUiEditor generated
```

The presets would mirror kwxFortran's (same compiler pairing constraints apply), so it may be worth putting a shared CMakePresets.json template in a common location or documenting the required preset structure.
