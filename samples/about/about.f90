! about.f90 - wxHTML "about dialog" sample in Fortran
!
! Fortran port of wxWidgets sample src/html/about/about.cpp (kwxFortran).
!
! A frame titled "wxHtmlWindow testing application" with a one-item File menu
! (About / Exit).  The About command builds a modal dialog holding a
! wxHtmlWindow that displays data/about.htm over a tiled data/bg.svg
! background, a horizontal static line and the default OK button.
!
! Ported assets:
!   data/about.htm, data/bg.svg, data/logo.png  - copied unchanged from the
!       C++ sample; about.htm embeds logo.png through a relative <img>.
!   sample.svg                                  - the frame icon.  The C++
!       sample uses the 32x32 samples/sample.xpm compiled into a resource
!       (SetIcon(wxICON(sample))); the same artwork is loaded here through
!       wxBitmapBundle::FromSVGFile.
!
! Run the executable with the current directory set to this folder so that
! the relative "data/about.htm", "data/bg.svg" and "sample.svg" paths resolve:
!     cd samples\about && ..\..\bin\Debug\about.exe

module about_globals
    use kwx_types
    implicit none

    ! Main frame (the C++ MyFrame instance).
    type(wxFrame_t), save :: g_frame

end module about_globals


module about_icon
    use, intrinsic :: iso_c_binding
    use kwx_types
    use wx_bitmap_bundle, only: wx_bitmap_bundle_from_svg_file, &
        wx_bitmap_bundle_get_bitmap, wx_bitmap_bundle_delete
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

        call wx_bitmap_bundle_delete(bundle)
    end subroutine set_sample_icon

end module about_icon


module about_handlers
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_ANY, wxID_OK, wxALL, wxVERTICAL, &
        wxHW_SCROLLBAR_NEVER, wxDEFAULT_DIALOG_STYLE
    use wx_window, only: wx_window_close, wx_window_set_initial_size, &
        wx_window_set_sizer, wx_window_destroy
    use wx_dialog, only: wx_dialog_create, wx_dialog_show_modal
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add_window_flags, wx_sizer_fit
    use wx_sizer_flags, only: wx_sizer_flags_create, wx_sizer_flags_delete, &
        wx_sizer_flags_double_border, wx_sizer_flags_expand, &
        wx_sizer_flags_double_horz_border, wx_sizer_flags_right, &
        wx_sizer_flags_triple_border
    use wx_button, only: wx_button_create, wx_button_set_default
    use wx_static_line, only: wx_static_line_create
    use wx_html_window, only: wx_html_window_create, wx_html_window_set_borders, &
        wx_html_window_load_page, wx_html_window_set_html_background_image, &
        wx_html_window_get_internal_representation
    use wx_html_cell, only: wx_html_cell_get_width, wx_html_cell_get_height
    use wx_bitmap_bundle, only: wx_bitmap_bundle_from_svg_file, &
        wx_bitmap_bundle_delete
    use about_globals, only: g_frame
    implicit none

contains

    !--------------------------------------------------------------------------
    ! MyFrame::OnQuit -- Close(true)
    !--------------------------------------------------------------------------
    subroutine on_quit(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: closed

        if (.not. c_associated(evt)) return

        closed = wx_window_close(g_frame, .true.)
    end subroutine on_quit

    !--------------------------------------------------------------------------
    ! MyFrame::OnAbout -- build and show the "About" dialog
    !--------------------------------------------------------------------------
    subroutine on_about(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        type(wxdialog_t) :: dlg
        type(wxboxsizer_t) :: topsizer
        type(wxhtmlwindow_t) :: html
        type(wxhtmlcontainercell_t) :: rep
        type(wxstaticline_t) :: static_line
        type(wxbutton_t) :: ok_button
        type(wxsizerflags_t) :: flags
        type(wxbitmapbundle_t) :: background
        integer(c_int) :: modal_result
        logical :: loaded, sized, destroyed

        if (.not. c_associated(evt)) return

        ! wxDialog dlg(this, wxID_ANY, wxString(_("About")));
        dlg = wx_dialog_create(g_frame, wxID_ANY(), "About", -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, wxDEFAULT_DIALOG_STYLE())
        if (.not. dlg%is_valid()) return

        ! topsizer = new wxBoxSizer(wxVERTICAL);
        topsizer = wx_box_sizer_create(wxVERTICAL())

        ! html = new wxHtmlWindow(&dlg, wxID_ANY, wxDefaultPosition,
        !                          wxSize(380, 160), wxHW_SCROLLBAR_NEVER);
        html = wx_html_window_create(dlg, wxID_ANY(), -1_c_int, -1_c_int, &
            380_c_int, 160_c_int, int(wxHW_SCROLLBAR_NEVER(), c_long), &
            "htmlWindow")
        if (.not. html%is_valid()) then
            ! hand the (empty) sizer to the dialog so destroying it frees both
            call wx_window_set_sizer(dlg, topsizer, .false.)
            destroyed = wx_window_destroy(dlg)
            return
        end if

        ! html->SetBorders(0);
        call wx_html_window_set_borders(html, 0_c_int)

        ! html->LoadPage("data/about.htm");
        loaded = wx_html_window_load_page(html, "data/about.htm")

        ! html->SetHTMLBackgroundImage(
        !     wxBitmapBundle::FromSVGFile("data/bg.svg", wxSize(65, 45)));
        background = wx_bitmap_bundle_from_svg_file("data/bg.svg", 65_c_int, &
            45_c_int)
        if (background%is_valid()) then
            call wx_html_window_set_html_background_image(html, background)
        end if

        ! html->SetInitialSize(wxSize(html->GetInternalRepresentation()->GetWidth(),
        !                             html->GetInternalRepresentation()->GetHeight()));
        rep = wx_html_window_get_internal_representation(html)
        if (c_associated(rep%ptr)) then
            sized = wx_window_set_initial_size(html, &
                wx_html_cell_get_width(rep), wx_html_cell_get_height(rep))
        end if

        ! topsizer->Add(html, wxSizerFlags(1).DoubleBorder());
        flags = wx_sizer_flags_create(1_c_int)
        call wx_sizer_flags_double_border(flags, wxALL())
        call wx_sizer_add_window_flags(topsizer, html, flags)
        call wx_sizer_flags_delete(flags)

        ! topsizer->Add(new wxStaticLine(&dlg, wxID_ANY),
        !               wxSizerFlags().Expand().DoubleHorzBorder());
        static_line = wx_static_line_create(dlg, wxID_ANY(), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)
        if (static_line%is_valid()) then
            flags = wx_sizer_flags_create(0_c_int)
            call wx_sizer_flags_expand(flags)
            call wx_sizer_flags_double_horz_border(flags)
            call wx_sizer_add_window_flags(topsizer, static_line, flags)
            call wx_sizer_flags_delete(flags)
        end if

        ! wxButton *bu1 = new wxButton(&dlg, wxID_OK, _("OK"));
        ! bu1->SetDefault();
        ok_button = wx_button_create(dlg, wxID_OK(), "OK", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)
        if (ok_button%is_valid()) then
            call wx_button_set_default(ok_button)
            flags = wx_sizer_flags_create(0_c_int)
            call wx_sizer_flags_right(flags)
            call wx_sizer_flags_triple_border(flags, wxALL())
            call wx_sizer_add_window_flags(topsizer, ok_button, flags)
            call wx_sizer_flags_delete(flags)
        end if

        ! dlg.SetSizer(topsizer);
        ! topsizer->Fit(&dlg);
        call wx_window_set_sizer(dlg, topsizer, .false.)
        call wx_sizer_fit(topsizer, dlg)

        ! dlg.ShowModal();
        modal_result = wx_dialog_show_modal(dlg)

        ! stack-local wxDialog goes out of scope at the end of the handler
        destroyed = wx_window_destroy(dlg)
        call wx_bitmap_bundle_delete(background)
    end subroutine on_about

end module about_handlers


program about
    use, intrinsic :: iso_c_binding
    use wx_app
    use wx_frame
    use wx_menu, only: wx_menu_create, wx_menu_append
    use wx_menu_bar, only: wx_menu_bar_create, wx_menu_bar_append
    use wx_window, only: wx_window_show
    use wx_events
    use kwx_types
    use kwxffi, only: wxID_ABOUT, wxID_EXIT, wxEVT_MENU, wxID_ANY, &
        wxDEFAULT_FRAME_STYLE
    use about_globals
    use about_icon
    use about_handlers
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxMenu_t) :: file_menu
    type(wxMenuBar_t) :: menu_bar
    integer :: exit_code
    integer(c_int) :: dummy
    logical :: shown

    ! wxIMPLEMENT_APP(MyApp) / MyApp::OnInit()
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    ! we use a PNG image in our HTML page
    ! wxImage::AddHandler(new wxPNGHandler);
    call wx_init_all_image_handlers()

    call wx_set_app_name("wxHtmlWindow testing application")

    ! MyFrame *frame = new MyFrame("wxHtmlWindow testing application");
    no_parent%ptr = c_null_ptr
    g_frame = wx_frame_create(no_parent, wxID_ANY(), &
        "wxHtmlWindow testing application", -1_c_int, -1_c_int, -1_c_int, &
        -1_c_int, wxDEFAULT_FRAME_STYLE())
    if (.not. g_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    ! SetIcon(wxICON(sample));  (icon from samples/sample.xpm, now sample.svg)
    call set_sample_icon(g_frame)

    ! wxMenu *menuFile = new wxMenu;
    ! menuFile->Append(wxID_ABOUT);
    ! menuFile->Append(wxID_EXIT);
    ! The empty label makes wxMenuItemBase::SetItemLabel() substitute the stock
    ! label (wxSTOCK_WITH_ACCELERATOR | wxSTOCK_WITH_MNEMONIC), exactly as the
    ! C++ Append(wxID_...) calls without a label do.
    file_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(file_menu, wxID_ABOUT(), "", "", .false.)
    call wx_menu_append(file_menu, wxID_EXIT(), "", "", .false.)

    ! wxMenuBar *menuBar = new wxMenuBar;
    ! menuBar->Append(menuFile, "&File");
    ! SetMenuBar(menuBar);
    menu_bar = wx_menu_bar_create(0_c_int)
    dummy = wx_menu_bar_append(menu_bar, file_menu, "&File")
    call wx_frame_set_menu_bar(g_frame, menu_bar)

    ! wxBEGIN_EVENT_TABLE / EVT_MENU(wxID_ABOUT, ...) / EVT_MENU(wxID_EXIT, ...)
    call wx_connect(g_frame, wxEVT_MENU(), on_about, id=wxID_ABOUT())
    call wx_connect(g_frame, wxEVT_MENU(), on_quit, id=wxID_EXIT())

    ! frame->Show();
    call wx_set_top_window(g_frame)
    shown = wx_window_show(g_frame)

    ! wxApp::OnRun()
    exit_code = wx_main_loop()

    call wx_shutdown()

end program about
