! minimal.f90 - Minimal wxWidgets sample in Fortran
!
! Fortran port of wxWidgets sample src/minimal/minimal.cpp (kwxFortran).
!
! A frame titled "Minimal wxWidgets App" with a File menu (Exit) and a Help
! menu (About), a two-pane status bar showing "Welcome to wxWidgets!", and a
! message box that reports the wxWidgets version and the OS description.
!
! The C++ sample sets the frame icon from the compiled-in samples/sample.xpm
! resource (SetIcon(wxICON(sample))).  The artwork is reproduced pixel for
! pixel in sample.svg (32x32) and loaded through wxBitmapBundle::FromSVGFile.
!
! Run the executable with the current directory set to this folder so the
! relative "sample.svg" path resolves:
!     cd samples\minimal && ..\..\bin\Release\minimal.exe

module minimal_globals
    use kwx_types
    implicit none

    ! Main frame (the C++ MyFrame instance).
    type(wxFrame_t), save :: g_frame

end module minimal_globals


module minimal_icon
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxBitmapBundle_Delete
    use wx_bitmap_bundle, only: wx_bitmap_bundle_from_svg_file, &
        wx_bitmap_bundle_get_bitmap
    use wx_bitmap, only: wx_bitmap_delete
    use wx_icon, only: wx_icon_create_default, wx_icon_copy_from_bitmap, &
        wx_icon_delete, wx_icon_is_ok
    use wx_frame, only: wx_frame_set_icon
    implicit none
    private

    public :: set_sample_icon

contains

    !--------------------------------------------------------------------------
    ! SetIcon(wxICON(sample))
    !
    ! samples/sample.xpm is reproduced in sample.svg at its original 32x32
    ! size; wxICON(sample) on MSW copies the bitmap into an icon.
    !--------------------------------------------------------------------------
    subroutine set_sample_icon(frame)
        type(wxFrame_t), intent(in) :: frame
        type(wxBitmapBundle_t) :: bundle
        type(wxBitmap_t) :: bitmap
        type(wxIcon_t) :: icon

        bundle = wx_bitmap_bundle_from_svg_file("sample.svg", 32_c_int, 32_c_int)
        if (.not. bundle%is_valid()) return

        bitmap = wx_bitmap_bundle_get_bitmap(bundle, 32_c_int, 32_c_int)
        if (bitmap%is_valid()) then
            icon = wx_icon_create_default()
            if (icon%is_valid()) then
                ! wxIcon_CopyFromBitmap() is implemented only for __WIN32__; on
                ! other platforms the icon remains invalid and is not installed.
                call wx_icon_copy_from_bitmap(icon, bitmap)
                if (wx_icon_is_ok(icon)) call wx_frame_set_icon(frame, icon)
                call wx_icon_delete(icon)
            end if
            call wx_bitmap_delete(bitmap)
        end if

        ! wxBitmapBundle_FromSVGFile() returns a newly allocated bundle, but the
        ! generated wrapper marks the handle non-owned; release it explicitly.
        call wxBitmapBundle_Delete(bundle%ptr)
        bundle%ptr = c_null_ptr
    end subroutine set_sample_icon

end module minimal_icon


module minimal_handlers
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxVersionString, kwxMessageBox, wxOK, wxICON_INFORMATION
    use wx_app, only: wx_get_os_description
    use wx_string, only: from_wxstring, to_wxstring, wxString_Delete
    use wx_window, only: wx_window_close
    use minimal_globals
    implicit none

contains

    !--------------------------------------------------------------------------
    ! Minimal_Quit -- Close(true)
    !--------------------------------------------------------------------------
    subroutine on_quit(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: closed

        if (.not. c_associated(evt)) return

        closed = wx_window_close(g_frame, .true.)
    end subroutine on_quit

    !--------------------------------------------------------------------------
    ! Minimal_About -- wxMessageBox(wxString::Format(...), ...)
    !--------------------------------------------------------------------------
    subroutine on_about(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        type(c_ptr) :: version_ptr, message_ptr, caption_ptr
        character(len=:), allocatable :: version, os_description, message
        integer :: dummy

        if (.not. c_associated(evt)) return

        ! wxVERSION_STRING
        version_ptr = wxVersionString()
        version = from_wxstring(version_ptr)
        call wxString_Delete(version_ptr)

        ! wxGetOsDescription()
        os_description = wx_get_os_description()

        ! "Welcome to %s!\n\nThis is the minimal wxWidgets sample\nrunning under %s."
        message = "Welcome to " // trim(version) // "!" // achar(10) // &
            achar(10) // "This is the minimal wxWidgets sample" // achar(10) // &
            "running under " // trim(os_description) // "."

        ! wxMessageBox(message, "About ...", wxOK | wxICON_INFORMATION, this)
        message_ptr = to_wxstring(message)
        caption_ptr = to_wxstring("About wxWidgets minimal sample")
        dummy = int(kwxMessageBox(message_ptr, caption_ptr, &
            ior(wxOK(), wxICON_INFORMATION()), g_frame%ptr, -1_c_int, -1_c_int))
        call wxString_Delete(caption_ptr)
        call wxString_Delete(message_ptr)
    end subroutine on_about

end module minimal_handlers


program minimal
    use, intrinsic :: iso_c_binding
    use wx_app
    use wx_frame
    use wx_menu, only: wx_menu_create, wx_menu_append
    use wx_menu_bar, only: wx_menu_bar_create, wx_menu_bar_append
    use wx_window, only: wx_window_show
    use wx_events
    use kwx_types
    use kwxffi, only: wxID_ABOUT, wxID_EXIT, wxEVT_MENU, wxID_ANY, &
        wxDEFAULT_FRAME_STYLE, wxSTB_DEFAULT_STYLE
    use minimal_globals
    use minimal_icon
    use minimal_handlers
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxStatusBar_t) :: status_bar
    type(wxMenu_t) :: file_menu
    type(wxMenu_t) :: help_menu
    type(wxMenuBar_t) :: menu_bar
    integer :: exit_code, dummy
    logical :: shown

    ! wxIMPLEMENT_APP / MyApp::OnInit()
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    ! MyFrame *frame = new MyFrame("Minimal wxWidgets App");
    no_parent%ptr = c_null_ptr
    g_frame = wx_frame_create(no_parent, wxID_ANY(), "Minimal wxWidgets App", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, wxDEFAULT_FRAME_STYLE())
    if (.not. g_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    ! SetIcon(wxICON(sample));  (icon from samples/sample.xpm, now sample.svg)
    call set_sample_icon(g_frame)

    ! wxMenu *fileMenu = new wxMenu;
    ! wxMenu *helpMenu = new wxMenu;
    file_menu = wx_menu_create("", 0_c_long)
    help_menu = wx_menu_create("", 0_c_long)

    ! helpMenu->Append(Minimal_About, "&About\tF1", "Show about dialog");
    ! fileMenu->Append(Minimal_Quit, "E&xit\tAlt-X", "Quit this program");
    call wx_menu_append(help_menu, wxID_ABOUT(), "&About" // achar(9) // "F1", &
        "Show about dialog", .false.)
    call wx_menu_append(file_menu, wxID_EXIT(), "E&xit" // achar(9) // "Alt-X", &
        "Quit this program", .false.)

    ! menuBar->Append(fileMenu, "&File");
    ! menuBar->Append(helpMenu, "&Help");
    ! SetMenuBar(menuBar);
    menu_bar = wx_menu_bar_create(0_c_int)
    dummy = wx_menu_bar_append(menu_bar, file_menu, "&File")
    dummy = wx_menu_bar_append(menu_bar, help_menu, "&Help")
    call wx_frame_set_menu_bar(g_frame, menu_bar)

    ! Event table: EVT_MENU(Minimal_Quit, ...), EVT_MENU(Minimal_About, ...)
    call wx_connect(g_frame, wxEVT_MENU(), on_quit, id=wxID_EXIT())
    call wx_connect(g_frame, wxEVT_MENU(), on_about, id=wxID_ABOUT())

    ! CreateStatusBar(2); SetStatusText("Welcome to wxWidgets!");
    status_bar = wx_frame_create_status_bar(g_frame, 2_c_int, &
        wxSTB_DEFAULT_STYLE(), 0_c_int)
    call wx_frame_set_status_text(g_frame, "Welcome to wxWidgets!", 0_c_int)

    ! frame->Show(true);
    call wx_set_top_window(g_frame)
    shown = wx_window_show(g_frame)

    ! wxApp::OnRun()
    exit_code = wx_main_loop()

    call wx_shutdown()

end program minimal
