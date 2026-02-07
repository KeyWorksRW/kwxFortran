! wx_frame.f90 - Fortran wrapper for wxFrame
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides a high-level Fortran interface to wxFrame.
! A wxFrame is a top-level window with title bar, optional menu bar,
! toolbar, and status bar.
!
! Usage:
!   use wx_frame
!   use wxffi_constants
!   type(wxFrame_t) :: frame
!   frame = wx_frame_create(title="My App", width=800, height=600)
!   call wx_frame_show(frame)

module wx_frame
    use, intrinsic :: iso_c_binding
    use wxffi_types
    use wxffi_bindings
    use wxffi_constants
    use wx_string
    implicit none
    private

    ! Frame creation and management
    public :: wx_frame_create
    public :: wx_frame_show, wx_frame_hide, wx_frame_close

    ! Status bar
    public :: wx_frame_create_status_bar
    public :: wx_frame_set_status_text

    ! Menu bar
    public :: wx_frame_set_menu_bar, wx_frame_get_menu_bar

    ! Toolbar
    public :: wx_frame_create_tool_bar, wx_frame_get_tool_bar

    ! Window operations (inherited from wxWindow)
    public :: wx_frame_center, wx_frame_set_size

contains

    !---------------------------------------------------------------------------
    ! Create a new frame window
    !
    ! Parameters:
    !   title  - Window title (required)
    !   parent - Parent window (optional, default: no parent)
    !   id     - Window ID (optional, default: wxID_ANY)
    !   x, y   - Position (optional, default: system default)
    !   width, height - Size (optional, default: system default)
    !   style  - Window style (optional, default: wxDEFAULT_FRAME_STYLE)
    !
    ! Returns: wxFrame_t with valid pointer on success
    !---------------------------------------------------------------------------
    function wx_frame_create(title, parent, id, x, y, width, height, style) result(frame)
        character(len=*), intent(in) :: title
        type(wxWindow_t), intent(in), optional :: parent
        integer, intent(in), optional :: id
        integer, intent(in), optional :: x, y
        integer, intent(in), optional :: width, height
        integer, intent(in), optional :: style
        type(wxFrame_t) :: frame

        type(c_ptr) :: parent_ptr, title_ptr
        integer(c_int) :: c_id, c_x, c_y, c_w, c_h, c_style

        ! Set defaults
        parent_ptr = c_null_ptr
        c_id = wxID_ANY()
        c_x = -1  ! wxDefaultCoord equivalent
        c_y = -1
        c_w = -1
        c_h = -1
        c_style = wxDEFAULT_FRAME_STYLE()

        ! Override with optional parameters
        if (present(parent)) parent_ptr = parent%ptr
        if (present(id)) c_id = int(id, c_int)
        if (present(x)) c_x = int(x, c_int)
        if (present(y)) c_y = int(y, c_int)
        if (present(width)) c_w = int(width, c_int)
        if (present(height)) c_h = int(height, c_int)
        if (present(style)) c_style = int(style, c_int)

        ! Convert title to wxString*
        title_ptr = to_wxstring(title)

        ! Create the frame
        frame%ptr = wxFrame_Create(parent_ptr, c_id, title_ptr, c_x, c_y, c_w, c_h, c_style)

        ! Clean up the wxString*
        call wxString_Delete(title_ptr)
    end function wx_frame_create

    !---------------------------------------------------------------------------
    ! Show the frame window
    !---------------------------------------------------------------------------
    subroutine wx_frame_show(frame)
        type(wxFrame_t), intent(in) :: frame
        integer(c_int) :: result

        result = wxWindow_Show(frame%ptr)
    end subroutine wx_frame_show

    !---------------------------------------------------------------------------
    ! Hide the frame window
    !---------------------------------------------------------------------------
    subroutine wx_frame_hide(frame)
        type(wxFrame_t), intent(in) :: frame
        integer(c_int) :: result

        result = wxWindow_Hide(frame%ptr)
    end subroutine wx_frame_hide

    !---------------------------------------------------------------------------
    ! Close the frame window
    ! force: if .true., force close even if user cancels
    !---------------------------------------------------------------------------
    function wx_frame_close(frame, force) result(closed)
        type(wxFrame_t), intent(in) :: frame
        logical, intent(in), optional :: force
        logical :: closed
        integer(c_int) :: c_force

        c_force = 0
        if (present(force)) then
            if (force) c_force = 1
        end if

        closed = (wxWindow_Close(frame%ptr, c_force) /= 0)
    end function wx_frame_close

    !---------------------------------------------------------------------------
    ! Create a status bar for the frame
    ! number: number of fields (default: 1)
    ! style: status bar style (default: 0)
    !---------------------------------------------------------------------------
    subroutine wx_frame_create_status_bar(frame, number, style)
        type(wxFrame_t), intent(in) :: frame
        integer, intent(in), optional :: number
        integer, intent(in), optional :: style
        type(c_ptr) :: statusbar
        integer(c_int) :: c_number, c_style

        c_number = 1
        c_style = 0
        if (present(number)) c_number = int(number, c_int)
        if (present(style)) c_style = int(style, c_int)

        statusbar = wxFrame_CreateStatusBar(frame%ptr, c_number, c_style)
    end subroutine wx_frame_create_status_bar

    !---------------------------------------------------------------------------
    ! Set status bar text
    ! text: text to display
    ! field: field number (0-based, default: 0)
    !---------------------------------------------------------------------------
    subroutine wx_frame_set_status_text(frame, text, field)
        type(wxFrame_t), intent(in) :: frame
        character(len=*), intent(in) :: text
        integer, intent(in), optional :: field
        type(c_ptr) :: text_ptr
        integer(c_int) :: c_field

        c_field = 0
        if (present(field)) c_field = int(field, c_int)

        text_ptr = to_wxstring(text)
        call wxFrame_SetStatusText(frame%ptr, text_ptr, c_field)
        call wxString_Delete(text_ptr)
    end subroutine wx_frame_set_status_text

    !---------------------------------------------------------------------------
    ! Set menu bar for the frame
    !---------------------------------------------------------------------------
    subroutine wx_frame_set_menu_bar(frame, menubar)
        type(wxFrame_t), intent(in) :: frame
        type(wxMenuBar_t), intent(in) :: menubar

        call wxFrame_SetMenuBar(frame%ptr, menubar%ptr)
    end subroutine wx_frame_set_menu_bar

    !---------------------------------------------------------------------------
    ! Get menu bar from the frame
    !---------------------------------------------------------------------------
    function wx_frame_get_menu_bar(frame) result(menubar)
        type(wxFrame_t), intent(in) :: frame
        type(wxMenuBar_t) :: menubar

        menubar%ptr = wxFrame_GetMenuBar(frame%ptr)
    end function wx_frame_get_menu_bar

    !---------------------------------------------------------------------------
    ! Create a toolbar for the frame
    ! style: toolbar style (default: 0)
    !---------------------------------------------------------------------------
    subroutine wx_frame_create_tool_bar(frame, style)
        type(wxFrame_t), intent(in) :: frame
        integer, intent(in), optional :: style
        type(c_ptr) :: toolbar
        integer(c_int) :: c_style

        c_style = 0
        if (present(style)) c_style = int(style, c_int)

        toolbar = wxFrame_CreateToolBar(frame%ptr, c_style)
    end subroutine wx_frame_create_tool_bar

    !---------------------------------------------------------------------------
    ! Get toolbar from the frame
    !---------------------------------------------------------------------------
    function wx_frame_get_tool_bar(frame) result(toolbar)
        type(wxFrame_t), intent(in) :: frame
        type(c_ptr) :: toolbar

        toolbar = wxFrame_GetToolBar(frame%ptr)
    end function wx_frame_get_tool_bar

    !---------------------------------------------------------------------------
    ! Center the frame on screen or parent
    ! direction: wxHORIZONTAL, wxVERTICAL, or wxBOTH (default: wxBOTH)
    !---------------------------------------------------------------------------
    subroutine wx_frame_center(frame, direction)
        type(wxFrame_t), intent(in) :: frame
        integer, intent(in), optional :: direction
        integer(c_int) :: c_direction

        c_direction = wxBOTH()
        if (present(direction)) c_direction = int(direction, c_int)

        call wxWindow_Center(frame%ptr, c_direction)
    end subroutine wx_frame_center

    !---------------------------------------------------------------------------
    ! Set frame size
    !---------------------------------------------------------------------------
    subroutine wx_frame_set_size(frame, width, height, x, y)
        type(wxFrame_t), intent(in) :: frame
        integer, intent(in) :: width, height
        integer, intent(in), optional :: x, y
        integer(c_int) :: c_x, c_y, c_w, c_h, c_flags

        c_x = -1
        c_y = -1
        if (present(x)) c_x = int(x, c_int)
        if (present(y)) c_y = int(y, c_int)
        c_w = int(width, c_int)
        c_h = int(height, c_int)
        c_flags = 0  ! wxSIZE_AUTO

        call wxWindow_SetSize(frame%ptr, c_x, c_y, c_w, c_h, c_flags)
    end subroutine wx_frame_set_size

end module wx_frame
