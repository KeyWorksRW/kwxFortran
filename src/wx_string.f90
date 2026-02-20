! wx_string.f90 - String conversion utilities for wxWidgets FFI
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides utilities for converting between Fortran character strings
! and wxString* pointers used by wxFFI. All wxFFI string functions expect UTF-8
! encoded C strings passed through wxString* pointers.
!
! IMPORTANT: Memory management for wxString*:
! - to_wxstring() creates a new wxString* that must be deleted by calling wxString_Delete
! - from_wxstring() extracts content but does NOT delete the wxString*
! - Always call wxString_Delete after extracting string content from return values

module wx_string
    use, intrinsic :: iso_c_binding
    use kwx_types
    implicit none
    private

    public :: to_wxstring, from_wxstring
    public :: wxString_Delete

    ! C interface to wxFFI string functions
    interface
        ! Create wxString* from UTF-8 C string
        function wxString_CreateUTF8(str) bind(C, name="wxString_CreateUTF8")
            import :: c_ptr, c_char
            character(kind=c_char), dimension(*), intent(in) :: str
            type(c_ptr) :: wxString_CreateUTF8
        end function wxString_CreateUTF8

        ! Copy UTF-8 string into buffer; if buffer is C_NULL_PTR, returns length only
        function wxString_GetString(wx_str, buffer) bind(C, name="wxString_GetString")
            import :: c_ptr, c_int
            type(c_ptr), value :: wx_str
            type(c_ptr), value :: buffer
            integer(c_int) :: wxString_GetString
        end function wxString_GetString

        ! Delete wxString*
        subroutine wxString_Delete_C(wx_str) bind(C, name="wxString_Delete")
            import :: c_ptr
            type(c_ptr), value :: wx_str
        end subroutine wxString_Delete_C

        ! Get length of string
        function wxString_Length(wx_str) bind(C, name="wxString_Length")
            import :: c_ptr, c_int
            type(c_ptr), value :: wx_str
            integer(c_int) :: wxString_Length
        end function wxString_Length
    end interface

contains

    !---------------------------------------------------------------------------
    ! Convert Fortran string to wxString*
    ! Returns: type(c_ptr) pointing to newly allocated wxString
    ! NOTE: Caller must delete returned pointer using wxString_Delete
    !---------------------------------------------------------------------------
    function to_wxstring(fstring) result(wx_str_ptr)
        character(len=*), intent(in) :: fstring
        type(c_ptr) :: wx_str_ptr
        character(len=:, kind=c_char), allocatable :: c_string

        ! Convert Fortran string to null-terminated C string
        ! Trim trailing spaces and add null terminator
        c_string = trim(fstring) // c_null_char
        wx_str_ptr = wxString_CreateUTF8(c_string)
    end function to_wxstring

    !---------------------------------------------------------------------------
    ! Convert wxString* to Fortran string
    ! Parameters:
    !   wx_str_ptr - pointer to wxString (type(c_ptr))
    ! Returns: Fortran allocatable string
    ! NOTE: Does NOT delete the wxString* - caller must call wxString_Delete
    !---------------------------------------------------------------------------
    function from_wxstring(wx_str_ptr) result(fstring)
        type(c_ptr), intent(in) :: wx_str_ptr
        character(len=:), allocatable :: fstring
        integer(c_int) :: str_len
        character(kind=c_char), allocatable, target :: buffer(:)
        integer :: i

        if (.not. c_associated(wx_str_ptr)) then
            allocate(character(len=0) :: fstring)
            return
        end if

        ! Get string length (pass C_NULL_PTR to query length only)
        str_len = wxString_GetString(wx_str_ptr, c_null_ptr)

        if (str_len == 0) then
            allocate(character(len=0) :: fstring)
            return
        end if

        ! Allocate buffer and copy UTF-8 content
        allocate(buffer(str_len))
        str_len = wxString_GetString(wx_str_ptr, c_loc(buffer))

        ! Convert C buffer to Fortran string
        allocate(character(len=str_len) :: fstring)
        do i = 1, str_len
            fstring(i:i) = buffer(i)
        end do
    end function from_wxstring

    !---------------------------------------------------------------------------
    ! Delete wxString* pointer
    ! This must be called for every wxString* returned from wxFFI functions
    ! after extracting the string content with from_wxstring()
    !---------------------------------------------------------------------------
    subroutine wxString_Delete(wx_str_ptr)
        type(c_ptr), intent(in) :: wx_str_ptr
        if (c_associated(wx_str_ptr)) then
            call wxString_Delete_C(wx_str_ptr)
        end if
    end subroutine wxString_Delete

end module wx_string
