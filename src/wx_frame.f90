! wx_frame.f90 - Fortran wrapper for wxFrame
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides a high-level Fortran interface to wxFrame.
! A wxFrame is a top-level window with title bar, optional menu bar,
! toolbar, and status bar.
!
! Usage:
!   use wx_frame
!   use kwx_constants
!   type(wxFrame_t) :: frame
!   frame = wx_frame_create(title="My App", width=800, height=600)
!   call wx_frame_show(frame)

module wx_frame
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwx_bindings
    use kwx_constants
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

    ! Top-level window operations (wxTopLevelWindow)
    public :: wx_frame_restore
    public :: wx_frame_maximize, wx_frame_iconize
    public :: wx_frame_is_maximized, wx_frame_is_iconized
    public :: wx_frame_show_full_screen, wx_frame_is_full_screen
    public :: wx_frame_get_title, wx_frame_set_title
    public :: wx_frame_is_active
    public :: wx_frame_enable_close_button
    public :: wx_frame_enable_maximize_button, wx_frame_enable_minimize_button
    public :: wx_frame_request_user_attention
    public :: wx_frame_push_status_text, wx_frame_pop_status_text

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

    !---------------------------------------------------------------------------
    ! Restore the frame from maximized or iconized state
    !---------------------------------------------------------------------------
    subroutine wx_frame_restore(frame)
        type(wxFrame_t), intent(in) :: frame
        call wxFrame_Restore(frame%ptr)
    end subroutine wx_frame_restore

    !---------------------------------------------------------------------------
    ! Maximize the frame
    !---------------------------------------------------------------------------
    subroutine wx_frame_maximize(frame)
        type(wxFrame_t), intent(in) :: frame
        call wxFrame_Maximize(frame%ptr)
    end subroutine wx_frame_maximize

    !---------------------------------------------------------------------------
    ! Iconize (minimize) the frame
    !---------------------------------------------------------------------------
    subroutine wx_frame_iconize(frame)
        type(wxFrame_t), intent(in) :: frame
        call wxFrame_Iconize(frame%ptr)
    end subroutine wx_frame_iconize

    !---------------------------------------------------------------------------
    ! Check if the frame is maximized
    !---------------------------------------------------------------------------
    logical function wx_frame_is_maximized(frame)
        type(wxFrame_t), intent(in) :: frame
        wx_frame_is_maximized = (wxFrame_IsMaximized(frame%ptr) /= 0)
    end function wx_frame_is_maximized

    !---------------------------------------------------------------------------
    ! Check if the frame is iconized (minimized)
    !---------------------------------------------------------------------------
    logical function wx_frame_is_iconized(frame)
        type(wxFrame_t), intent(in) :: frame
        wx_frame_is_iconized = (wxFrame_IsIconized(frame%ptr) /= 0)
    end function wx_frame_is_iconized

    !---------------------------------------------------------------------------
    ! Show or hide fullscreen mode
    ! style: fullscreen style flags (default: 0)
    !---------------------------------------------------------------------------
    logical function wx_frame_show_full_screen(frame, show, style)
        type(wxFrame_t), intent(in) :: frame
        logical, intent(in) :: show
        integer, intent(in), optional :: style
        integer(c_int) :: c_show, c_style

        c_show = 0
        if (show) c_show = 1
        c_style = 0
        if (present(style)) c_style = int(style, c_int)

        wx_frame_show_full_screen = &
            (wxTopLevelWindow_ShowFullScreen(frame%ptr, c_show, c_style) /= 0)
    end function wx_frame_show_full_screen

    !---------------------------------------------------------------------------
    ! Check if the frame is in fullscreen mode
    !---------------------------------------------------------------------------
    logical function wx_frame_is_full_screen(frame)
        type(wxFrame_t), intent(in) :: frame
        wx_frame_is_full_screen = (wxTopLevelWindow_IsFullScreen(frame%ptr) /= 0)
    end function wx_frame_is_full_screen

    !---------------------------------------------------------------------------
    ! Get the frame title
    !---------------------------------------------------------------------------
    function wx_frame_get_title(frame) result(title)
        type(wxFrame_t), intent(in) :: frame
        character(len=:), allocatable :: title
        type(c_ptr) :: ws

        ws = wxTopLevelWindow_GetTitle(frame%ptr)
        title = from_wxstring(ws)
        call wxString_Delete(ws)
    end function wx_frame_get_title

    !---------------------------------------------------------------------------
    ! Set the frame title
    !---------------------------------------------------------------------------
    subroutine wx_frame_set_title(frame, title)
        type(wxFrame_t), intent(in) :: frame
        character(len=*), intent(in) :: title
        type(c_ptr) :: ws

        ws = to_wxstring(title)
        call wxTopLevelWindow_SetTitle(frame%ptr, ws)
        call wxString_Delete(ws)
    end subroutine wx_frame_set_title

    !---------------------------------------------------------------------------
    ! Check if the frame is the active (focused) top-level window
    !---------------------------------------------------------------------------
    logical function wx_frame_is_active(frame)
        type(wxFrame_t), intent(in) :: frame
        wx_frame_is_active = (wxTopLevelWindow_IsActive(frame%ptr) /= 0)
    end function wx_frame_is_active

    !---------------------------------------------------------------------------
    ! Enable or disable the close button
    !---------------------------------------------------------------------------
    subroutine wx_frame_enable_close_button(frame, enable)
        type(wxFrame_t), intent(in) :: frame
        logical, intent(in) :: enable
        integer(c_int) :: c_enable, dummy

        c_enable = 0
        if (enable) c_enable = 1
        dummy = wxTopLevelWindow_EnableCloseButton(frame%ptr, c_enable)
    end subroutine wx_frame_enable_close_button

    !---------------------------------------------------------------------------
    ! Enable or disable the maximize button
    !---------------------------------------------------------------------------
    subroutine wx_frame_enable_maximize_button(frame, enable)
        type(wxFrame_t), intent(in) :: frame
        logical, intent(in) :: enable
        integer(c_int) :: c_enable, dummy

        c_enable = 0
        if (enable) c_enable = 1
        dummy = wxTopLevelWindow_EnableMaximizeButton(frame%ptr, c_enable)
    end subroutine wx_frame_enable_maximize_button

    !---------------------------------------------------------------------------
    ! Enable or disable the minimize button
    !---------------------------------------------------------------------------
    subroutine wx_frame_enable_minimize_button(frame, enable)
        type(wxFrame_t), intent(in) :: frame
        logical, intent(in) :: enable
        integer(c_int) :: c_enable, dummy

        c_enable = 0
        if (enable) c_enable = 1
        dummy = wxTopLevelWindow_EnableMinimizeButton(frame%ptr, c_enable)
    end subroutine wx_frame_enable_minimize_button

    !---------------------------------------------------------------------------
    ! Request user attention (flash taskbar button on Windows)
    ! flags: 0 for info, 1 for error
    !---------------------------------------------------------------------------
    subroutine wx_frame_request_user_attention(frame, flags)
        type(wxFrame_t), intent(in) :: frame
        integer, intent(in), optional :: flags
        integer(c_int) :: c_flags

        c_flags = 0
        if (present(flags)) c_flags = int(flags, c_int)
        call wxTopLevelWindow_RequestUserAttention(frame%ptr, c_flags)
    end subroutine wx_frame_request_user_attention

    !---------------------------------------------------------------------------
    ! Push status text (saves current text, sets new text in field)
    ! field: status bar field index (default: 0)
    !---------------------------------------------------------------------------
    subroutine wx_frame_push_status_text(frame, text, field)
        type(wxFrame_t), intent(in) :: frame
        character(len=*), intent(in) :: text
        integer, intent(in), optional :: field
        type(c_ptr) :: ws
        integer(c_int) :: c_field

        c_field = 0
        if (present(field)) c_field = int(field, c_int)
        ws = to_wxstring(text)
        call wxFrame_PushStatusText(frame%ptr, ws, c_field)
        call wxString_Delete(ws)
    end subroutine wx_frame_push_status_text

    !---------------------------------------------------------------------------
    ! Pop status text (restores text saved by push_status_text)
    ! field: status bar field index (default: 0)
    !---------------------------------------------------------------------------
    subroutine wx_frame_pop_status_text(frame, field)
        type(wxFrame_t), intent(in) :: frame
        integer, intent(in), optional :: field
        integer(c_int) :: c_field

        c_field = 0
        if (present(field)) c_field = int(field, c_int)
        call wxFrame_PopStatusText(frame%ptr, c_field)
    end subroutine wx_frame_pop_status_text

end module wx_frame
