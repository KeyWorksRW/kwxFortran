! wx_dialogs.f90 - Dialog wrappers for kwxFortran
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides idiomatic Fortran wrappers for wxWidgets
! dialog functions such as wxMessageBox.

module wx_dialogs
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwx_bindings, only: kwxMessageBox
    use kwx_constants
    use wx_string, only: to_wxstring, wxString_Delete
    implicit none
    private

    public :: wx_message_box

contains

    !---------------------------------------------------------------------------
    ! Show a message box dialog
    !
    ! Arguments:
    !   message  - The message text to display
    !   caption  - Optional window caption (default: "Message")
    !   style    - Optional style flags, e.g. wxOK() + wxICON_INFORMATION()
    !              (default: wxOK + wxICON_INFORMATION)
    !   parent   - Optional parent window
    !
    ! Returns: integer result (wxID_OK, wxID_YES, wxID_NO, wxID_CANCEL)
    !---------------------------------------------------------------------------
    function wx_message_box(message, caption, style, parent) result(res)
        character(len=*), intent(in) :: message
        character(len=*), intent(in), optional :: caption
        integer, intent(in), optional :: style
        class(wxWindow_t), intent(in), optional :: parent

        integer :: res
        type(c_ptr) :: ws_msg, ws_cap, parent_ptr
        integer(c_int) :: c_style

        ! Convert message string
        ws_msg = to_wxstring(message)

        ! Convert caption string
        if (present(caption)) then
            ws_cap = to_wxstring(caption)
        else
            ws_cap = to_wxstring("Message")
        end if

        ! Style
        if (present(style)) then
            c_style = int(style, c_int)
        else
            c_style = int(ior(wxOK(), wxICON_INFORMATION()), c_int)
        end if

        ! Parent
        if (present(parent)) then
            parent_ptr = parent%ptr
        else
            parent_ptr = c_null_ptr
        end if

        res = int(kwxMessageBox(ws_msg, ws_cap, c_style, parent_ptr, &
                                -1_c_int, -1_c_int))

        ! Clean up wxString allocations
        call wxString_Delete(ws_msg)
        call wxString_Delete(ws_cap)
    end function wx_message_box

end module wx_dialogs
