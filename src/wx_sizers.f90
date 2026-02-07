! wx_sizers.f90 - Fortran wrappers for wxWidgets sizer classes
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides high-level Fortran interfaces to:
!   - wxBoxSizer (linear vertical or horizontal layout)
!   - wxSizer    (base sizer operations: add, fit, layout)
!
! Usage:
!   use wx_sizers
!   use wxffi_constants
!   type(wxBoxSizer_t) :: sizer
!   sizer = wx_box_sizer_create(wxVERTICAL())
!   call wx_sizer_add_window(sizer, my_button, proportion=0, flag=wxALL(), border=5)
!   call wx_window_set_sizer(panel, sizer)

module wx_sizers
    use, intrinsic :: iso_c_binding
    use wxffi_types
    use wxffi_bindings
    use wxffi_constants
    implicit none
    private

    ! wxBoxSizer
    public :: wx_box_sizer_create
    public :: wx_box_sizer_get_orientation

    ! wxSizer operations (work on any sizer type)
    public :: wx_sizer_add_window
    public :: wx_sizer_add_sizer
    public :: wx_sizer_add_spacer
    public :: wx_sizer_add_stretch_spacer
    public :: wx_sizer_layout
    public :: wx_sizer_fit
    public :: wx_sizer_set_size_hints

    ! Convenience: set sizer on a window
    public :: wx_window_set_sizer

contains

    !===========================================================================
    ! wxBoxSizer
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a box sizer with the given orientation
    !
    ! Parameters:
    !   orient - wxHORIZONTAL() or wxVERTICAL()
    !
    ! Returns: wxBoxSizer_t with valid pointer on success
    !---------------------------------------------------------------------------
    function wx_box_sizer_create(orient) result(sizer)
        integer, intent(in) :: orient
        type(wxBoxSizer_t) :: sizer

        sizer%ptr = wxBoxSizer_Create(int(orient, c_int))
    end function wx_box_sizer_create

    !---------------------------------------------------------------------------
    ! Get the orientation of a box sizer
    !
    ! Returns: wxHORIZONTAL or wxVERTICAL
    !---------------------------------------------------------------------------
    function wx_box_sizer_get_orientation(sizer) result(orient)
        type(wxBoxSizer_t), intent(in) :: sizer
        integer :: orient

        orient = int(wxBoxSizer_GetOrientation(sizer%ptr))
    end function wx_box_sizer_get_orientation

    !===========================================================================
    ! wxSizer operations
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Add a window (control) to a sizer
    !
    ! Parameters:
    !   sizer      - The sizer to add to (any sizer type)
    !   window     - The window/control to add
    !   proportion - How much space this item gets relative to others (default: 0)
    !   flag       - Alignment and border flags, e.g. wxALL+wxEXPAND (default: 0)
    !   border     - Border size in pixels (default: 0)
    !---------------------------------------------------------------------------
    subroutine wx_sizer_add_window(sizer, window, proportion, flag, border)
        class(wxSizer_t), intent(in) :: sizer
        class(wxWindow_t), intent(in) :: window
        integer, intent(in), optional :: proportion
        integer, intent(in), optional :: flag
        integer, intent(in), optional :: border

        integer(c_int) :: c_prop, c_flag, c_border

        c_prop = 0
        c_flag = 0
        c_border = 0
        if (present(proportion)) c_prop = int(proportion, c_int)
        if (present(flag)) c_flag = int(flag, c_int)
        if (present(border)) c_border = int(border, c_int)

        call wxSizer_AddWindow(sizer%ptr, window%ptr, c_prop, c_flag, &
            c_border, c_null_ptr)
    end subroutine wx_sizer_add_window

    !---------------------------------------------------------------------------
    ! Add a child sizer to a parent sizer
    !
    ! Parameters:
    !   sizer       - The parent sizer
    !   child_sizer - The child sizer to add
    !   proportion  - How much space this item gets (default: 0)
    !   flag        - Alignment and border flags (default: 0)
    !   border      - Border size in pixels (default: 0)
    !---------------------------------------------------------------------------
    subroutine wx_sizer_add_sizer(sizer, child_sizer, proportion, flag, border)
        class(wxSizer_t), intent(in) :: sizer
        class(wxSizer_t), intent(in) :: child_sizer
        integer, intent(in), optional :: proportion
        integer, intent(in), optional :: flag
        integer, intent(in), optional :: border

        integer(c_int) :: c_prop, c_flag, c_border

        c_prop = 0
        c_flag = 0
        c_border = 0
        if (present(proportion)) c_prop = int(proportion, c_int)
        if (present(flag)) c_flag = int(flag, c_int)
        if (present(border)) c_border = int(border, c_int)

        call wxSizer_AddSizer(sizer%ptr, child_sizer%ptr, c_prop, c_flag, &
            c_border, c_null_ptr)
    end subroutine wx_sizer_add_sizer

    !---------------------------------------------------------------------------
    ! Add a fixed-size spacer to a sizer
    !
    ! Parameters:
    !   sizer - The sizer
    !   size  - Size of the spacer in pixels
    !---------------------------------------------------------------------------
    subroutine wx_sizer_add_spacer(sizer, size)
        class(wxSizer_t), intent(in) :: sizer
        integer, intent(in) :: size

        call wxSizer_AddSpacer(sizer%ptr, int(size, c_int))
    end subroutine wx_sizer_add_spacer

    !---------------------------------------------------------------------------
    ! Add a stretchable spacer to a sizer
    !
    ! Parameters:
    !   sizer      - The sizer
    !   proportion - Stretch proportion (default: 1)
    !---------------------------------------------------------------------------
    subroutine wx_sizer_add_stretch_spacer(sizer, proportion)
        class(wxSizer_t), intent(in) :: sizer
        integer, intent(in), optional :: proportion

        integer(c_int) :: c_prop

        c_prop = 1
        if (present(proportion)) c_prop = int(proportion, c_int)

        call wxSizer_AddStretchSpacer(sizer%ptr, c_prop)
    end subroutine wx_sizer_add_stretch_spacer

    !---------------------------------------------------------------------------
    ! Force the sizer to recalculate layout
    !---------------------------------------------------------------------------
    subroutine wx_sizer_layout(sizer)
        class(wxSizer_t), intent(in) :: sizer

        call wxSizer_Layout(sizer%ptr)
    end subroutine wx_sizer_layout

    !---------------------------------------------------------------------------
    ! Resize the window to fit the sizer's minimum size
    !---------------------------------------------------------------------------
    subroutine wx_sizer_fit(sizer, window)
        class(wxSizer_t), intent(in) :: sizer
        class(wxWindow_t), intent(in) :: window

        call wxSizer_Fit(sizer%ptr, window%ptr)
    end subroutine wx_sizer_fit

    !---------------------------------------------------------------------------
    ! Set the minimum size hints on a window from the sizer
    ! This prevents the user from resizing the window smaller than the
    ! sizer's minimum size.
    !---------------------------------------------------------------------------
    subroutine wx_sizer_set_size_hints(sizer, window)
        class(wxSizer_t), intent(in) :: sizer
        class(wxWindow_t), intent(in) :: window

        call wxSizer_SetSizeHints(sizer%ptr, window%ptr)
    end subroutine wx_sizer_set_size_hints

    !===========================================================================
    ! Convenience wrappers
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Set a sizer on a window (the window will use this sizer for layout)
    !
    ! Parameters:
    !   window - The window to set the sizer on
    !   sizer  - The sizer to use for layout
    !---------------------------------------------------------------------------
    subroutine wx_window_set_sizer(window, sizer)
        class(wxWindow_t), intent(in) :: window
        class(wxSizer_t), intent(in) :: sizer

        call wxWindow_SetSizer(window%ptr, sizer%ptr, 1_c_int)
    end subroutine wx_window_set_sizer

end module wx_sizers
