! probe_main.f90 - hand-written probe entry for the kwxFortran probe lane
!
! probe.wxui (..\..\quick\tests\quick_probe\probe.wxui) generates
! gen\probe_mainframe.f90 and gen\probe_dlg.f90. Probe output never goes to
! tests\quick.

program probe_main
    use, intrinsic :: iso_c_binding
    use kwx_types
    use wx_app
    use wx_window, only: wx_window_show
    use wx_dialog, only: wx_dialog_show_modal
    use probe_mainframe_mod
    use probe_dlg_mod
    implicit none

    type(c_ptr) :: frame_ptr
    type(c_ptr) :: dialog_ptr
    type(wxframe_t) :: frame
    type(wxdialog_t) :: dialog
    integer :: exit_code
    integer :: modal_code

    ! The probe form embeds PNG data, so the raster image handlers must be registered
    ! before any wxBitmap is decoded.
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if
    call wx_init_all_image_handlers()

    call wx_set_app_name("Probe")

    call create_probe_main_frame(c_null_ptr, frame_ptr)
    if (.not. c_associated(frame_ptr)) then
        print *, "Failed to create probe frame"
        call wx_shutdown()
        stop 1
    end if
    frame = wxframe_from_ptr(frame_ptr, .false.)

    call wx_set_top_window(frame)
    modal_code = 0
    if (.not. wx_window_show(frame)) then
        print *, "Failed to show probe frame"
    end if

    call create_probe_dialog(frame_ptr, dialog_ptr)
    if (c_associated(dialog_ptr)) then
        dialog = wxdialog_from_ptr(dialog_ptr, .false.)
        modal_code = wx_dialog_show_modal(dialog)
    end if

    exit_code = wx_main_loop()
    call wx_shutdown()
    stop exit_code

end program probe_main
