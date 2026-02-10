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
    use wx_app
    use wx_frame
    use wx_controls
    use wx_sizers
    use wx_window
    use wx_events
    use wxffi_types
    use wxffi_constants
    use hello_handlers
    implicit none

    type(wxFrame_t) :: frame
    type(wxPanel_t) :: panel
    type(wxBoxSizer_t) :: main_sizer
    type(wxStaticText_t) :: label
    type(wxButton_t) :: button
    type(wxTextCtrl_t) :: text_input
    integer :: exit_code

    ! Initialize wxWidgets
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    ! Set application name
    call wx_set_app_name("Hello Fortran")

    ! Create the main frame
    frame = wx_frame_create( &
        title = "Hello wxFortran", &
        width = 400, &
        height = 300 &
    )
    if (.not. frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    ! Create a panel inside the frame (required for proper tab traversal)
    panel = wx_panel_create(parent=frame)
    if (.not. panel%is_valid()) then
        print *, "Failed to create panel"
        stop 1
    end if

    ! Create a vertical sizer for the panel
    main_sizer = wx_box_sizer_create(wxVERTICAL())

    ! Add a "Hello World" label with a border
    label = wx_static_text_create("Hello, World from Fortran!", parent=panel)
    call wx_sizer_add_window(main_sizer, label, &
        proportion=0, flag=wxALL(), border=10)

    ! Add a text input field
    text_input = wx_text_ctrl_create(parent=panel, value="Type here...")
    call wx_sizer_add_window(main_sizer, text_input, &
        proportion=0, flag=ior(wxEXPAND(), wxALL()), border=10)

    ! Add a button
    button = wx_button_create("Click Me!", parent=panel)
    call wx_sizer_add_window(main_sizer, button, &
        proportion=0, flag=ior(wxALIGN_CENTER(), wxALL()), border=10)

    ! Connect button click event to handler
    call wx_connect(button, wxEVT_BUTTON(), on_button_click)

    ! Add a stretch spacer to push everything up
    call wx_sizer_add_stretch_spacer(main_sizer)

    ! Apply the sizer to the panel
    call wx_window_set_sizer(panel, main_sizer)

    ! Set minimum size hints so window can't shrink too small
    call wx_sizer_set_size_hints(main_sizer, frame)

    ! Center and show the frame
    call wx_frame_center(frame)

    ! Create a status bar
    call wx_frame_create_status_bar(frame)
    call wx_frame_set_status_text(frame, "Click the button!")

    ! Set as top window and show
    call wx_set_top_window(frame)
    call wx_frame_show(frame)

    ! Run the main event loop
    exit_code = wx_main_loop()

    ! Cleanup
    call wx_shutdown()

end program hello
