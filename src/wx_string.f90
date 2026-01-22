!> @file wx_string.f90
!> @brief String conversion utilities for Fortran ↔ wxString interoperability
!>
!> This module provides C interop bindings to wxFFI string functions and
!> helper functions for converting between Fortran strings and wxString pointers.
!>
!> @note Memory management: wxString pointers returned from wxFFI functions must
!> be explicitly deleted using wxString_Delete to avoid memory leaks.

module wx_string
    use, intrinsic :: iso_c_binding
    implicit none

    private
    public :: wxString_CreateUTF8, wxString_Delete, wxString_GetUTF8, wxString_Length
    public :: to_wxstring, from_wxstring

    !> @brief C interface bindings for wxFFI string functions
    interface
        !> @brief Create a wxString from a UTF-8 encoded C string
        !> @param str Null-terminated UTF-8 C string
        !> @return Pointer to newly allocated wxString (caller must delete)
        function wxString_CreateUTF8(str) bind(C, name="wxString_CreateUTF8")
            import :: c_ptr, c_char
            character(kind=c_char), intent(in) :: str(*)
            type(c_ptr) :: wxString_CreateUTF8
        end function wxString_CreateUTF8

        !> @brief Delete a wxString allocated by wxFFI
        !> @param str Pointer to wxString to delete
        subroutine wxString_Delete(str) bind(C, name="wxString_Delete")
            import :: c_ptr
            type(c_ptr), value :: str
        end subroutine wxString_Delete

        !> @brief Get UTF-8 string data from a wxString
        !> @param str Pointer to wxString
        !> @return Pointer to null-terminated UTF-8 C string (do not free)
        function wxString_GetUTF8(str) bind(C, name="wxString_GetUTF8")
            import :: c_ptr
            type(c_ptr), value :: str
            type(c_ptr) :: wxString_GetUTF8
        end function wxString_GetUTF8

        !> @brief Get the length of a wxString in bytes (UTF-8)
        !> @param str Pointer to wxString
        !> @return Length in bytes
        function wxString_Length(str) bind(C, name="wxString_Length")
            import :: c_ptr, c_size_t
            type(c_ptr), value :: str
            integer(c_size_t) :: wxString_Length
        end function wxString_Length
    end interface

contains

    !> @brief Convert a Fortran string to a wxString pointer
    !>
    !> Creates a new wxString from the given Fortran string. The string is
    !> trimmed of trailing spaces and converted to UTF-8.
    !>
    !> @param fstring Fortran character string
    !> @return Pointer to newly allocated wxString (caller must delete with wxString_Delete)
    !>
    !> @code
    !> type(c_ptr) :: title
    !> title = to_wxstring("Hello World")
    !> ! ... use title ...
    !> call wxString_Delete(title)
    !> @endcode
    function to_wxstring(fstring) result(ptr)
        character(len=*), intent(in) :: fstring
        type(c_ptr) :: ptr

        ! Trim trailing spaces and append null terminator for C
        ptr = wxString_CreateUTF8(trim(fstring) // c_null_char)
    end function to_wxstring

    !> @brief Convert a wxString pointer to a Fortran allocatable string
    !>
    !> Extracts the UTF-8 content from a wxString and returns it as an
    !> allocatable Fortran string. Does NOT delete the wxString.
    !>
    !> @param ptr Pointer to wxString
    !> @return Allocatable Fortran string containing the wxString content
    !>
    !> @code
    !> type(c_ptr) :: wx_str
    !> character(len=:), allocatable :: fstr
    !> fstr = from_wxstring(wx_str)
    !> @endcode
    function from_wxstring(ptr) result(fstring)
        type(c_ptr), intent(in) :: ptr
        character(len=:), allocatable :: fstring

        type(c_ptr) :: c_str
        integer(c_size_t) :: length
        character(len=1, kind=c_char), dimension(:), pointer :: char_array
        integer :: i, len_int

        ! Handle null pointer
        if (.not. c_associated(ptr)) then
            fstring = ""
            return
        end if

        ! Get the UTF-8 string data and length
        c_str = wxString_GetUTF8(ptr)
        length = wxString_Length(ptr)

        ! Handle empty string
        if (length == 0 .or. .not. c_associated(c_str)) then
            fstring = ""
            return
        end if

        ! Associate Fortran pointer with C array
        call c_f_pointer(c_str, char_array, [length])

        ! Allocate and copy characters (convert length once for efficiency)
        len_int = int(length, kind=kind(len_int))
        allocate(character(len=len_int) :: fstring)
        do i = 1, len_int
            fstring(i:i) = char_array(i)
        end do
    end function from_wxstring

end module wx_string
