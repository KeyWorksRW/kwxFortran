! demo.f90 - Interactive demo of kwxFortran GUI features
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This example demonstrates:
!   - Main frame window with File/Edit/Help menus
!   - Status bar showing "Ready"
!   - wxPanel with vertical box sizer layout
!   - Horizontal child sizer with "Text:" label + text control
!   - "Click Me" button that shows the text in a message box
!
!
! Build via CMake with the kwxFortran project.

module demo_globals
    use kwx_types
    implicit none

    ! Module-level controls — accessible from event handlers
    type(wxTextCtrl_t) :: g_text_ctrl
    type(wxFrame_t)    :: g_frame

end module demo_globals

module demo_handlers
    use, intrinsic :: iso_c_binding
    use wx_events
    use wx_text_ctrl, only: wx_text_ctrl_get_value
    use wx_string, only: to_wxstring, wxString_Delete
    use wx_window, only: wx_window_close
    use wx_app, only: wx_exit_main_loop
    use kwxffi, only: kwxMessageBox, wxOK, wxICON_INFORMATION
    use demo_globals
    implicit none

contains

    !---------------------------------------------------------------------------
    ! wxMessageBox() with wxOK | wxICON_INFORMATION, no parent
    !---------------------------------------------------------------------------
    function show_message(message, caption) result(res)
        character(len=*), intent(in) :: message
        character(len=*), intent(in) :: caption
        integer :: res
        type(c_ptr) :: message_ptr, caption_ptr

        message_ptr = to_wxstring(message)
        caption_ptr = to_wxstring(caption)
        res = int(kwxMessageBox(message_ptr, caption_ptr, &
            ior(wxOK(), wxICON_INFORMATION()), c_null_ptr, -1_c_int, -1_c_int))
        call wxString_Delete(caption_ptr)
        call wxString_Delete(message_ptr)
    end function show_message

    !---------------------------------------------------------------------------
    ! "Click Me" button handler — show text control value in a message box
    !---------------------------------------------------------------------------
    subroutine on_click_me(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        character(len=:), allocatable :: text
        integer :: res

        ! evt is null when wxClosure destructor calls for cleanup — controls are already destroyed
        if (.not. c_associated(evt)) return

        text = wx_text_ctrl_get_value(g_text_ctrl)

        if (len(text) == 0) then
            res = show_message("(no text entered)", "Demo")
        else
            res = show_message(text, "You typed")
        end if
    end subroutine on_click_me

    !---------------------------------------------------------------------------
    ! File > Exit handler — close the frame (generates wxEVT_CLOSE_WINDOW)
    !---------------------------------------------------------------------------
    subroutine on_exit(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: closed

        if (.not. c_associated(evt)) return
        closed = wx_window_close(g_frame, .true.)
    end subroutine on_exit

    !---------------------------------------------------------------------------
    ! Close window handler (X button and programmatic close)
    !---------------------------------------------------------------------------
    subroutine on_close_window(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        call wx_exit_main_loop()
    end subroutine on_close_window

    !---------------------------------------------------------------------------
    ! Help > About handler
    !---------------------------------------------------------------------------
    subroutine on_about(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: res

        if (.not. c_associated(evt)) return
        res = show_message(&
            "kwxFortran Demo" // achar(10) // &
            "Fortran bindings for wxWidgets via kwxFFI", &
            "About Demo")
    end subroutine on_about

end module demo_handlers

program demo
    use, intrinsic :: iso_c_binding
    use wx_app
    use wx_frame
    use wx_panel, only: wx_panel_create
    use wx_button, only: wx_button_create
    use wx_static_text, only: wx_static_text_create
    use wx_text_ctrl, only: wx_text_ctrl_create, wx_text_ctrl_set_hint
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add_window, wx_sizer_add_sizer
    use wx_menu, only: wx_menu_create, wx_menu_append, wx_menu_append_separator
    use wx_menu_bar, only: wx_menu_bar_create, wx_menu_bar_append
    use wx_window, only: wx_window_set_sizer, wx_window_center, wx_window_show
    use wx_events
    use kwx_types
    use kwxffi, only: wxEVT_MENU, wxEVT_BUTTON, wxEVT_CLOSE_WINDOW, &
        wxID_NEW, wxID_OPEN, wxID_SAVE, wxID_EXIT, wxID_ABOUT, &
        wxID_UNDO, wxID_REDO, wxID_CUT, wxID_COPY, wxID_PASTE, &
        wxID_ANY, wxDEFAULT_FRAME_STYLE, wxSTB_DEFAULT_STYLE, wxBOTH, &
        wxVERTICAL, wxHORIZONTAL, wxALL, wxEXPAND, wxALIGN_CENTER_VERTICAL
    use demo_globals
    use demo_handlers
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxFrame_t) :: frame
    type(wxStatusBar_t) :: status_bar
    type(wxPanel_t) :: panel

    ! Sizers
    type(wxBoxSizer_t) :: vbox, hbox

    ! Controls
    type(wxStaticText_t) :: label
    type(wxButton_t) :: button

    ! Menus
    type(wxMenu_t) :: file_menu, edit_menu, help_menu
    type(wxMenuBar_t) :: menubar

    integer :: exit_code, dummy
    logical :: shown

    ! Initialize wxWidgets
    if (.not. wx_initialize()) then
        stop 1
    end if

    call wx_set_app_name("kwxFortran Demo")

    !===================================================================
    ! Create the main frame
    !===================================================================

    no_parent%ptr = c_null_ptr
    frame = wx_frame_create(no_parent, wxID_ANY(), "kwxFortran Demo", &
        -1_c_int, -1_c_int, 480_c_int, 320_c_int, wxDEFAULT_FRAME_STYLE())
    if (.not. frame%is_valid()) stop 1
    g_frame = frame

    !===================================================================
    ! Menu bar: File / Edit / Help
    !===================================================================

    ! File menu
    file_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(file_menu, wxID_NEW(), "&New", "Create new", .false.)
    call wx_menu_append(file_menu, wxID_OPEN(), "&Open", "Open file", .false.)
    call wx_menu_append(file_menu, wxID_SAVE(), "&Save", "Save file", .false.)
    call wx_menu_append_separator(file_menu)
    call wx_menu_append(file_menu, wxID_EXIT(), "E&xit", &
        "Exit application", .false.)

    ! Edit menu
    edit_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(edit_menu, wxID_UNDO(), "&Undo", "", .false.)
    call wx_menu_append(edit_menu, wxID_REDO(), "&Redo", "", .false.)
    call wx_menu_append_separator(edit_menu)
    call wx_menu_append(edit_menu, wxID_CUT(), "Cu&t", "", .false.)
    call wx_menu_append(edit_menu, wxID_COPY(), "&Copy", "", .false.)
    call wx_menu_append(edit_menu, wxID_PASTE(), "&Paste", "", .false.)

    ! Help menu
    help_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(help_menu, wxID_ABOUT(), "&About", &
        "About this demo", .false.)

    ! Assemble menu bar
    menubar = wx_menu_bar_create(0_c_int)
    dummy = wx_menu_bar_append(menubar, file_menu, "&File")
    dummy = wx_menu_bar_append(menubar, edit_menu, "&Edit")
    dummy = wx_menu_bar_append(menubar, help_menu, "&Help")
    call wx_frame_set_menu_bar(frame, menubar)

    ! Connect menu events
    call wx_connect(frame, wxEVT_MENU(), on_exit, id=wxID_EXIT())
    call wx_connect(frame, wxEVT_MENU(), on_about, id=wxID_ABOUT())

    ! Handle window close (X button)
    call wx_connect(frame, wxEVT_CLOSE_WINDOW(), on_close_window)

    !===================================================================
    ! Status bar
    !===================================================================

    status_bar = wx_frame_create_status_bar(frame, 1_c_int, &
        wxSTB_DEFAULT_STYLE(), 0_c_int)
    call wx_frame_set_status_text(frame, "Ready", 0_c_int)

    !===================================================================
    ! Panel + sizer layout
    !===================================================================

    panel = wx_panel_create(frame, wxID_ANY(), -1_c_int, -1_c_int, &
        -1_c_int, -1_c_int, 0_c_int)

    ! Vertical box sizer (main layout)
    vbox = wx_box_sizer_create(wxVERTICAL())

    ! Horizontal child sizer: "Text:" label + text control
    hbox = wx_box_sizer_create(wxHORIZONTAL())

    label = wx_static_text_create(panel, wxID_ANY(), "Text:", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call wx_sizer_add_window(hbox, label, 0_c_int, &
        ior(wxALL(), wxALIGN_CENTER_VERTICAL()), 5_c_int, c_null_ptr)

    g_text_ctrl = wx_text_ctrl_create(panel, wxID_ANY(), "", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
    if (.not. g_text_ctrl%is_valid()) then
        write(*, '(a)') "ERROR: wx_text_ctrl_create returned invalid pointer"
        stop 1
    end if
    shown = wx_text_ctrl_set_hint(g_text_ctrl, "hint text")
    call wx_sizer_add_window(hbox, g_text_ctrl, 1_c_int, &
        ior(wxALL(), wxEXPAND()), 5_c_int, c_null_ptr)

    call wx_sizer_add_sizer(vbox, hbox, 0_c_int, &
        ior(wxEXPAND(), wxALL()), 5_c_int, c_null_ptr)

    ! "Click Me" button
    button = wx_button_create(panel, wxID_ANY(), "Click Me", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call wx_sizer_add_window(vbox, button, 0_c_int, wxALL(), 10_c_int, &
        c_null_ptr)

    call wx_window_set_sizer(panel, vbox, .false.)

    !===================================================================
    ! Connect button event
    !===================================================================

    call wx_connect(button, wxEVT_BUTTON(), on_click_me)

    !===================================================================
    ! Show and run
    !===================================================================

    call wx_window_center(frame, wxBOTH())
    call wx_set_top_window(frame)
    shown = wx_window_show(frame)

    exit_code = wx_main_loop()
    call wx_shutdown()

end program demo
