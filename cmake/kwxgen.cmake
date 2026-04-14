# [Randalphwa - 04-14-2026] kwxgen is now a separate repository. Eventually, it will
# create tags with source code and binary versions, at which point this can be updated
# accordingly.

# ###################### kwxgen — Fortran binding generator #######################

add_subdirectory(${kwxFFI_SOURCE_DIR}/tools/kwxgen kwxgen-build)

set(KWXFFI_HEADERS
    ${kwxFFI_SOURCE_DIR}/include/kwx_classes.h
    ${kwxFFI_SOURCE_DIR}/include/kwx_events.h
    ${kwxFFI_SOURCE_DIR}/include/kwx_keys.h
    ${kwxFFI_SOURCE_DIR}/include/kwx_constants.h
)

add_custom_command(
    OUTPUT ${CMAKE_SOURCE_DIR}/wx/kwxffi_gen.f90
    COMMAND kwxgen generate
    DEPENDS ${KWXFFI_HEADERS}
    COMMENT "Generating Fortran bindings via kwxgen"
)

add_custom_target(generate_fortran_bindings ALL
    DEPENDS ${CMAKE_SOURCE_DIR}/wx/kwxffi_gen.f90
)
