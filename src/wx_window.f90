! wx_window.f90 - Fortran wrapper for wxWindow base class
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides common window operations that apply to all
! wxWindow-derived types (frames, panels, buttons, etc.).
!
! Usage:
!   use wx_window
!   call wx_window_show(my_control)
!   call wx_window_set_focus(my_textctrl)

module wx_window
    use, intrinsic :: iso_c_binding
    use wxffi_types
    use wxffi_bindings
    use wxffi_constants
    use wx_string
    implicit none
    private

    ! Visibility and state
    public :: wx_window_show, wx_window_hide
    public :: wx_window_enable, wx_window_disable
    public :: wx_window_is_enabled, wx_window_is_shown

    ! Size and position
    public :: wx_window_set_size, wx_window_move
    public :: wx_window_get_id

    ! Focus
    public :: wx_window_set_focus, wx_window_has_focus

    ! Refresh and update
    public :: wx_window_refresh, wx_window_update

    ! Layout
    public :: wx_window_center, wx_window_fit, wx_window_layout

    ! Destruction
    public :: wx_window_destroy, wx_window_close

    ! Hierarchy
    public :: wx_window_get_parent, wx_window_is_top_level

    ! Freeze/thaw for batch updates
    public :: wx_window_freeze, wx_window_thaw

    ! Z-order
    public :: wx_window_raise, wx_window_lower

contains

    !---------------------------------------------------------------------------
    ! Show a window
    !---------------------------------------------------------------------------
    subroutine wx_window_show(window)
        class(wxWindow_t), intent(in) :: window
        integer(c_int) :: result

        result = wxWindow_Show(window%ptr)
    end subroutine wx_window_show

    !---------------------------------------------------------------------------
    ! Hide a window
    !---------------------------------------------------------------------------
    subroutine wx_window_hide(window)
        class(wxWindow_t), intent(in) :: window
        integer(c_int) :: result

        result = wxWindow_Hide(window%ptr)
    end subroutine wx_window_hide

    !---------------------------------------------------------------------------
    ! Enable a window
    !---------------------------------------------------------------------------
    subroutine wx_window_enable(window)
        class(wxWindow_t), intent(in) :: window
        integer(c_int) :: result

        result = wxWindow_Enable(window%ptr)
    end subroutine wx_window_enable

    !---------------------------------------------------------------------------
    ! Disable a window
    !---------------------------------------------------------------------------
    subroutine wx_window_disable(window)
        class(wxWindow_t), intent(in) :: window
        integer(c_int) :: result

        result = wxWindow_Disable(window%ptr)
    end subroutine wx_window_disable

    !---------------------------------------------------------------------------
    ! Check if window is enabled
    !---------------------------------------------------------------------------
    function wx_window_is_enabled(window) result(enabled)
        class(wxWindow_t), intent(in) :: window
        logical :: enabled

        enabled = (wxWindow_IsEnabled(window%ptr) /= 0)
    end function wx_window_is_enabled

    !---------------------------------------------------------------------------
    ! Check if window is shown
    !---------------------------------------------------------------------------
    function wx_window_is_shown(window) result(shown)
        class(wxWindow_t), intent(in) :: window
        logical :: shown

        shown = (wxWindow_IsShown(window%ptr) /= 0)
    end function wx_window_is_shown

    !---------------------------------------------------------------------------
    ! Set window size (and optionally position)
    !---------------------------------------------------------------------------
    subroutine wx_window_set_size(window, width, height, x, y)
        class(wxWindow_t), intent(in) :: window
        integer, intent(in) :: width, height
        integer, intent(in), optional :: x, y
        integer(c_int) :: c_x, c_y, c_w, c_h, c_flags

        c_x = -1
        c_y = -1
        if (present(x)) c_x = int(x, c_int)
        if (present(y)) c_y = int(y, c_int)
        c_w = int(width, c_int)
        c_h = int(height, c_int)
        c_flags = 0

        call wxWindow_SetSize(window%ptr, c_x, c_y, c_w, c_h, c_flags)
    end subroutine wx_window_set_size

    !---------------------------------------------------------------------------
    ! Move window to a new position
    !---------------------------------------------------------------------------
    subroutine wx_window_move(window, x, y)
        class(wxWindow_t), intent(in) :: window
        integer, intent(in) :: x, y

        call wxWindow_Move(window%ptr, int(x, c_int), int(y, c_int))
    end subroutine wx_window_move

    !---------------------------------------------------------------------------
    ! Get window ID
    !---------------------------------------------------------------------------
    function wx_window_get_id(window) result(id)
        class(wxWindow_t), intent(in) :: window
        integer :: id

        id = int(wxWindow_GetId(window%ptr))
    end function wx_window_get_id

    !---------------------------------------------------------------------------
    ! Set focus to this window
    !---------------------------------------------------------------------------
    subroutine wx_window_set_focus(window)
        class(wxWindow_t), intent(in) :: window

        call wxWindow_SetFocus(window%ptr)
    end subroutine wx_window_set_focus

    !---------------------------------------------------------------------------
    ! Check if window has focus
    !---------------------------------------------------------------------------
    function wx_window_has_focus(window) result(has_focus)
        class(wxWindow_t), intent(in) :: window
        logical :: has_focus

        has_focus = (wxWindow_HasFocus(window%ptr) /= 0)
    end function wx_window_has_focus

    !---------------------------------------------------------------------------
    ! Refresh window (mark for repaint)
    !---------------------------------------------------------------------------
    subroutine wx_window_refresh(window, erase_background)
        class(wxWindow_t), intent(in) :: window
        logical, intent(in), optional :: erase_background
        integer(c_int) :: c_erase

        c_erase = 1  ! Default to erasing background
        if (present(erase_background)) then
            if (.not. erase_background) c_erase = 0
        end if

        call wxWindow_Refresh(window%ptr, c_erase, c_null_ptr)
    end subroutine wx_window_refresh

    !---------------------------------------------------------------------------
    ! Update window (process pending paint events)
    !---------------------------------------------------------------------------
    subroutine wx_window_update(window)
        class(wxWindow_t), intent(in) :: window

        call wxWindow_Update(window%ptr)
    end subroutine wx_window_update

    !---------------------------------------------------------------------------
    ! Center window on screen or parent
    !---------------------------------------------------------------------------
    subroutine wx_window_center(window, direction)
        class(wxWindow_t), intent(in) :: window
        integer, intent(in), optional :: direction
        integer(c_int) :: c_direction

        c_direction = wxBOTH()
        if (present(direction)) c_direction = int(direction, c_int)

        call wxWindow_Center(window%ptr, c_direction)
    end subroutine wx_window_center

    !---------------------------------------------------------------------------
    ! Fit window to its contents
    !---------------------------------------------------------------------------
    subroutine wx_window_fit(window)
        class(wxWindow_t), intent(in) :: window

        call wxWindow_Fit(window%ptr)
    end subroutine wx_window_fit

    !---------------------------------------------------------------------------
    ! Layout child windows
    !---------------------------------------------------------------------------
    subroutine wx_window_layout(window)
        class(wxWindow_t), intent(in) :: window
        integer(c_int) :: result

        result = wxWindow_Layout(window%ptr)
    end subroutine wx_window_layout

    !---------------------------------------------------------------------------
    ! Destroy window and its children
    !---------------------------------------------------------------------------
    function wx_window_destroy(window) result(destroyed)
        class(wxWindow_t), intent(inout) :: window
        logical :: destroyed

        destroyed = (wxWindow_Destroy(window%ptr) /= 0)
        if (destroyed) window%ptr = c_null_ptr
    end function wx_window_destroy

    !---------------------------------------------------------------------------
    ! Close window (sends close event, may be vetoed)
    !---------------------------------------------------------------------------
    function wx_window_close(window, force) result(closed)
        class(wxWindow_t), intent(in) :: window
        logical, intent(in), optional :: force
        logical :: closed
        integer(c_int) :: c_force

        c_force = 0
        if (present(force)) then
            if (force) c_force = 1
        end if

        closed = (wxWindow_Close(window%ptr, c_force) /= 0)
    end function wx_window_close

    !---------------------------------------------------------------------------
    ! Get parent window
    !---------------------------------------------------------------------------
    function wx_window_get_parent(window) result(parent)
        class(wxWindow_t), intent(in) :: window
        type(wxWindow_t) :: parent

        parent%ptr = wxWindow_GetParent(window%ptr)
    end function wx_window_get_parent

    !---------------------------------------------------------------------------
    ! Check if window is a top-level window
    !---------------------------------------------------------------------------
    function wx_window_is_top_level(window) result(is_top)
        class(wxWindow_t), intent(in) :: window
        logical :: is_top

        is_top = (wxWindow_IsTopLevel(window%ptr) /= 0)
    end function wx_window_is_top_level

    !---------------------------------------------------------------------------
    ! Freeze window to prevent repaints during batch updates
    !---------------------------------------------------------------------------
    subroutine wx_window_freeze(window)
        class(wxWindow_t), intent(in) :: window

        call wxWindow_Freeze(window%ptr)
    end subroutine wx_window_freeze

    !---------------------------------------------------------------------------
    ! Thaw window to resume repaints
    !---------------------------------------------------------------------------
    subroutine wx_window_thaw(window)
        class(wxWindow_t), intent(in) :: window

        call wxWindow_Thaw(window%ptr)
    end subroutine wx_window_thaw

    !---------------------------------------------------------------------------
    ! Raise window to top of Z-order
    !---------------------------------------------------------------------------
    subroutine wx_window_raise(window)
        class(wxWindow_t), intent(in) :: window

        call wxWindow_Raise(window%ptr)
    end subroutine wx_window_raise

    !---------------------------------------------------------------------------
    ! Lower window to bottom of Z-order
    !---------------------------------------------------------------------------
    subroutine wx_window_lower(window)
        class(wxWindow_t), intent(in) :: window

        call wxWindow_Lower(window%ptr)
    end subroutine wx_window_lower

end module wx_window
