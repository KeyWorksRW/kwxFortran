! minimal.f90 - Minimal wxWidgets application in Fortran
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This example creates a simple empty window to demonstrate the basic
! structure of a wxWidgets application in Fortran.
!
! Build with:
!   gfortran -o minimal minimal.f90 -lkwxFortran -lkwxFFI -lwxXXX...
!
! Or build via CMake with the kwxFortran project.

program minimal
    use wx_app
    use wx_frame
    use kwx_types
    use kwx_constants
    implicit none

    type(wxFrame_t) :: main_frame
    integer :: exit_code

    ! Initialize wxWidgets
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    ! Set application name
    call wx_set_app_name("Minimal Fortran App")

    ! Create the main window
    main_frame = wx_frame_create( &
        title = "Minimal wxFortran Example", &
        width = 400, &
        height = 300 &
    )

    ! Check if frame was created successfully
    if (.not. main_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    ! Center the frame on screen
    ! TODO: restore once kwxFFI exports wxWindow_CentreOnParent or wxWindow_Centre
    ! call wx_frame_center(main_frame)

    ! Create a status bar with 1 field
    call wx_frame_create_status_bar(main_frame)
    call wx_frame_set_status_text(main_frame, "Welcome to wxFortran!")

    ! Set this as the top window (so app exits when it closes)
    call wx_set_top_window(main_frame)

    ! Show the frame
    call wx_frame_show(main_frame)

    ! Run the main event loop
    exit_code = wx_main_loop()

    ! Cleanup (optional, happens automatically)
    call wx_shutdown()

end program minimal
