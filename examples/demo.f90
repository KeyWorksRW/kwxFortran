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
    use wx_controls, only: wx_text_ctrl_get_value
    use wx_dialogs, only: wx_message_box
    use wx_app, only: wx_exit_main_loop
    use wx_frame, only: wx_frame_close
    use kwx_constants, only: wxOK, wxICON_INFORMATION
    use demo_globals
    implicit none

contains

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
            res = wx_message_box("(no text entered)", "Demo", &
                ior(wxOK(), wxICON_INFORMATION()))
        else
            res = wx_message_box(text, "You typed", &
                ior(wxOK(), wxICON_INFORMATION()))
        end if
    end subroutine on_click_me

    !---------------------------------------------------------------------------
    ! File > Exit handler — close the frame (generates wxEVT_CLOSE_WINDOW)
    !---------------------------------------------------------------------------
    subroutine on_exit(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: dummy

        if (.not. c_associated(evt)) return
        dummy = wx_frame_close(g_frame, force=.true.)
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
        res = wx_message_box( &
            "kwxFortran Demo" // achar(10) // &
            "Fortran bindings for wxWidgets via kwxFFI", &
            "About Demo", &
            ior(wxOK(), wxICON_INFORMATION()))
    end subroutine on_about

end module demo_handlers

program demo
    use wx_app
    use wx_frame
    use wx_controls
    use wx_menus
    use wx_sizers
    use wx_window
    use wx_events
    use kwx_types
    use kwx_constants, only: wxEVT_MENU, wxEVT_BUTTON, wxEVT_CLOSE_WINDOW, &
        wxID_NEW, wxID_OPEN, wxID_SAVE, wxID_EXIT, wxID_ABOUT, &
        wxID_UNDO, wxID_REDO, wxID_CUT, wxID_COPY, wxID_PASTE, &
        wxVERTICAL, wxHORIZONTAL, wxALL, wxEXPAND, wxALIGN_CENTER_VERTICAL, &
        wxOK, wxICON_INFORMATION
    use demo_globals
    use demo_handlers
    implicit none

    type(wxFrame_t) :: frame
    type(wxPanel_t) :: panel

    ! Sizers
    type(wxBoxSizer_t) :: vbox, hbox

    ! Controls
    type(wxStaticText_t) :: label
    type(wxButton_t) :: button

    ! Menus
    type(wxMenu_t) :: file_menu, edit_menu, help_menu
    type(wxMenuBar_t) :: menubar

    integer :: exit_code

    ! Initialize wxWidgets
    if (.not. wx_initialize()) then
        stop 1
    end if

    call wx_set_app_name("kwxFortran Demo")

    !===================================================================
    ! Create the main frame
    !===================================================================

    frame = wx_frame_create( &
        title = "kwxFortran Demo", &
        width = 480, &
        height = 320 &
    )
    if (.not. frame%is_valid()) stop 1
    g_frame = frame

    !===================================================================
    ! Menu bar: File / Edit / Help
    !===================================================================

    ! File menu
    file_menu = wx_menu_create()
    call wx_menu_append(file_menu, wxID_NEW(), "&New", "Create new")
    call wx_menu_append(file_menu, wxID_OPEN(), "&Open", "Open file")
    call wx_menu_append(file_menu, wxID_SAVE(), "&Save", "Save file")
    call wx_menu_append_separator(file_menu)
    call wx_menu_append(file_menu, wxID_EXIT(), "E&xit", "Exit application")

    ! Edit menu
    edit_menu = wx_menu_create()
    call wx_menu_append(edit_menu, wxID_UNDO(), "&Undo")
    call wx_menu_append(edit_menu, wxID_REDO(), "&Redo")
    call wx_menu_append_separator(edit_menu)
    call wx_menu_append(edit_menu, wxID_CUT(), "Cu&t")
    call wx_menu_append(edit_menu, wxID_COPY(), "&Copy")
    call wx_menu_append(edit_menu, wxID_PASTE(), "&Paste")

    ! Help menu
    help_menu = wx_menu_create()
    call wx_menu_append(help_menu, wxID_ABOUT(), "&About", "About this demo")

    ! Assemble menu bar
    menubar = wx_menubar_create()
    call wx_menubar_append(menubar, file_menu, "&File")
    call wx_menubar_append(menubar, edit_menu, "&Edit")
    call wx_menubar_append(menubar, help_menu, "&Help")
    call wx_frame_set_menu_bar(frame, menubar)

    ! Connect menu events
    call wx_connect(frame, wxEVT_MENU(), on_exit, id=wxID_EXIT())
    call wx_connect(frame, wxEVT_MENU(), on_about, id=wxID_ABOUT())

    ! Handle window close (X button)
    call wx_connect(frame, wxEVT_CLOSE_WINDOW(), on_close_window)

    !===================================================================
    ! Status bar
    !===================================================================

    call wx_frame_create_status_bar(frame)
    call wx_frame_set_status_text(frame, "Ready")

    !===================================================================
    ! Panel + sizer layout
    !===================================================================

    panel = wx_panel_create(parent=frame)

    ! Vertical box sizer (main layout)
    vbox = wx_box_sizer_create(wxVERTICAL())

    ! Horizontal child sizer: "Text:" label + text control
    hbox = wx_box_sizer_create(wxHORIZONTAL())

    label = wx_static_text_create("Text:", parent=panel)
    call wx_sizer_add_window(hbox, label, &
        proportion=0, flag=ior(wxALL(), wxALIGN_CENTER_VERTICAL()), border=5)

    g_text_ctrl = wx_text_ctrl_create(parent=panel)
    if (.not. g_text_ctrl%is_valid()) then
        write(*, '(a)') "ERROR: wx_text_ctrl_create returned invalid pointer"
        stop 1
    end if
    call wx_text_ctrl_set_hint(g_text_ctrl, "hint text")
    call wx_sizer_add_window(hbox, g_text_ctrl, &
        proportion=1, flag=ior(wxALL(), wxEXPAND()), border=5)

    call wx_sizer_add_sizer(vbox, hbox, &
        proportion=0, flag=ior(wxEXPAND(), wxALL()), border=5)

    ! "Click Me" button
    button = wx_button_create("Click Me", parent=panel)
    call wx_sizer_add_window(vbox, button, &
        proportion=0, flag=wxALL(), border=10)

    call wx_window_set_sizer(panel, vbox)

    !===================================================================
    ! Connect button event
    !===================================================================

    call wx_connect(button, wxEVT_BUTTON(), on_click_me)

    !===================================================================
    ! Show and run
    !===================================================================

    call wx_frame_center(frame)
    call wx_set_top_window(frame)
    call wx_frame_show(frame)

    exit_code = wx_main_loop()
    call wx_shutdown()

end program demo
