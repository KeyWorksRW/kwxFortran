! hello.f90 - Hello World wxWidgets application in Fortran
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This example creates a window with a panel, sizer-managed layout,
! a "Hello World" label, a text input, and a button with a click handler.
! Demonstrates basic controls, sizer layout, and event handling.
!
! Build via CMake with the kwxFortran project.

module hello_handlers
    use, intrinsic :: iso_c_binding
    use wx_events
    implicit none

    ! Module-level variable to track click count
    integer, save :: click_count = 0

contains

    !---------------------------------------------------------------------------
    ! Button click handler
    ! Called when the "Click Me!" button is pressed.
    !---------------------------------------------------------------------------
    subroutine on_button_click(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: event_id

        click_count = click_count + 1
        event_id = wx_event_get_id(evt)

        print '(A,I0,A,I0)', 'Button clicked! Count: ', click_count, &
            ', Event ID: ', event_id
    end subroutine on_button_click

end module hello_handlers

program hello
    use, intrinsic :: iso_c_binding
    use wx_app
    use wx_frame
    use wx_panel, only: wx_panel_create
    use wx_button, only: wx_button_create
    use wx_static_text, only: wx_static_text_create
    use wx_text_ctrl, only: wx_text_ctrl_create
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add_window, wx_sizer_add_stretch_spacer, &
        wx_sizer_set_size_hints
    use wx_window, only: wx_window_set_sizer, wx_window_center, wx_window_show
    use wx_events
    use kwx_types
    use kwxffi, only: wxVERTICAL, wxALL, wxEXPAND, wxALIGN_CENTER, wxEVT_BUTTON, &
        wxID_ANY, wxDEFAULT_FRAME_STYLE, wxSTB_DEFAULT_STYLE, wxBOTH
    use hello_handlers
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxFrame_t) :: frame
    type(wxStatusBar_t) :: status_bar
    type(wxPanel_t) :: panel
    type(wxBoxSizer_t) :: main_sizer
    type(wxStaticText_t) :: label
    type(wxButton_t) :: button
    type(wxTextCtrl_t) :: text_input
    integer :: exit_code
    logical :: shown

    ! Initialize wxWidgets
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    ! Set application name
    call wx_set_app_name("Hello Fortran")

    ! Create the main frame
    no_parent%ptr = c_null_ptr
    frame = wx_frame_create(no_parent, wxID_ANY(), "Hello wxFortran", &
        -1_c_int, -1_c_int, 400_c_int, 300_c_int, wxDEFAULT_FRAME_STYLE())
    if (.not. frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    ! Create a panel inside the frame (required for proper tab traversal)
    panel = wx_panel_create(frame, wxID_ANY(), -1_c_int, -1_c_int, &
        -1_c_int, -1_c_int, 0_c_int)
    if (.not. panel%is_valid()) then
        print *, "Failed to create panel"
        stop 1
    end if

    ! Create a vertical sizer for the panel
    main_sizer = wx_box_sizer_create(wxVERTICAL())

    ! Add a "Hello World" label with a border
    label = wx_static_text_create(panel, wxID_ANY(), &
        "Hello, World from Fortran!", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
        0_c_int)
    call wx_sizer_add_window(main_sizer, label, 0_c_int, wxALL(), 10_c_int, &
        c_null_ptr)

    ! Add a text input field
    text_input = wx_text_ctrl_create(panel, wxID_ANY(), "Type here...", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
    call wx_sizer_add_window(main_sizer, text_input, 0_c_int, &
        ior(wxEXPAND(), wxALL()), 10_c_int, c_null_ptr)

    ! Add a button
    button = wx_button_create(panel, wxID_ANY(), "Click Me!", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call wx_sizer_add_window(main_sizer, button, 0_c_int, &
        ior(wxALIGN_CENTER(), wxALL()), 10_c_int, c_null_ptr)

    ! Connect button click event to handler
    call wx_connect(button, wxEVT_BUTTON(), on_button_click)

    ! Add a stretch spacer to push everything up
    call wx_sizer_add_stretch_spacer(main_sizer, 1_c_int)

    ! Apply the sizer to the panel
    call wx_window_set_sizer(panel, main_sizer, .false.)

    ! Set minimum size hints so window can't shrink too small
    call wx_sizer_set_size_hints(main_sizer, frame)

    ! Center and show the frame
    call wx_window_center(frame, wxBOTH())

    ! Create a status bar
    status_bar = wx_frame_create_status_bar(frame, 1_c_int, &
        wxSTB_DEFAULT_STYLE(), 0_c_int)
    call wx_frame_set_status_text(frame, "Click the button!", 0_c_int)

    ! Set as top window and show
    call wx_set_top_window(frame)
    shown = wx_window_show(frame)

    ! Run the main event loop
    exit_code = wx_main_loop()

    ! Cleanup
    call wx_shutdown()

end program hello
