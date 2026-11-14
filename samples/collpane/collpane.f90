! collpane.f90 - wxCollapsiblePane sample
!
! Fortran port of wxWidgets sample src/collpane/collpane.cpp (kwxFortran).
!
! The frame owns a wxCollapsiblePane (label "This is a wxCollapsiblePane")
! whose pane holds a horizontal sizer with a 20 pixel spacer followed by a
! vertical sizer of static texts, a text control, a button and a nested
! collapsible pane, plus a wxCollapsibleHeaderCtrl below it.  The "Pane" menu
! collapses/expands the pane, renames its label through wxGetTextFromUser and
! opens the "Test dialog".  A two field status bar and the sample icon are also
! reproduced.
!
! Run the executable with the current directory set to this folder so the
! relative "data/sample.svg" path resolves.

module collpane_globals
    use kwx_types
    implicit none

    ! Control ids of the C++ sample (enum PANE_*).
    integer, parameter :: PANE_COLLAPSE = 100
    integer, parameter :: PANE_EXPAND = 101
    integer, parameter :: PANE_SETLABEL = 102
    integer, parameter :: PANE_SHOWDLG = 103
    integer, parameter :: PANE_BUTTON = 104
    integer, parameter :: PANE_TEXTCTRL = 105

    ! Main frame and its two collapsible controls (MyFrame members).
    type(wxFrame_t), save :: g_frame
    type(wxCollapsiblePane_t), save :: g_coll_pane
    type(wxCollapsibleHeaderCtrl_t), save :: g_coll_header

    ! MyDialog members, valid only while the modal dialog is shown.
    type(wxDialog_t), save :: g_dlg
    type(wxCollapsiblePane_t), save :: g_dlg_coll_pane
    type(wxGridSizer_t), save :: g_dlg_pane_sizer
    type(wxTextCtrl_t), save :: g_dlg_text_ctrl

end module collpane_globals


module collpane_icon
    use, intrinsic :: iso_c_binding
    use kwx_types
    use wx_bitmap_bundle, only: wx_bitmap_bundle_from_svg_file, &
        wx_bitmap_bundle_get_bitmap, wx_bitmap_bundle_is_ok, &
        wx_bitmap_bundle_delete
    use wx_bitmap, only: wx_bitmap_delete
    use wx_icon, only: wx_icon_create_default, wx_icon_copy_from_bitmap, &
        wx_icon_is_ok, wx_icon_delete
    use wx_frame, only: wx_frame_set_icon
    implicit none
    private

    public :: set_sample_icon, release_sample_icon

    ! SetIcon(wxICON(sample))
    !
    ! The icon artwork of samples/sample.xpm is shipped as data/sample.svg with
    ! the original 32x32 dimensions.  The bundle is an owned handle that must
    ! outlive the frame's icon, so it is kept until release_sample_icon runs
    ! after the event loop; the bitmap is converted into a wxIcon and released
    ! immediately.
    type(wxBitmapBundle_t), save :: icon_bundle

contains

    subroutine set_sample_icon(frame)
        type(wxFrame_t), intent(in) :: frame
        type(wxBitmap_t) :: bitmap
        type(wxIcon_t) :: icon

        icon_bundle = wx_bitmap_bundle_from_svg_file("data/sample.svg", &
            32_c_int, 32_c_int)
        if (.not. wx_bitmap_bundle_is_ok(icon_bundle)) return

        bitmap = wx_bitmap_bundle_get_bitmap(icon_bundle, 32_c_int, 32_c_int)
        if (.not. bitmap%is_valid()) return

        ! wxIcon_CopyFromBitmap() is implemented only for __WIN32__; on other
        ! platforms the icon stays invalid and is not installed.
        icon = wx_icon_create_default()
        if (icon%is_valid()) then
            call wx_icon_copy_from_bitmap(icon, bitmap)
            if (wx_icon_is_ok(icon)) call wx_frame_set_icon(frame, icon)
            call wx_icon_delete(icon)
        end if

        call wx_bitmap_delete(bitmap)
    end subroutine set_sample_icon

    subroutine release_sample_icon()
        call wx_bitmap_bundle_delete(icon_bundle)
    end subroutine release_sample_icon

end module collpane_icon


module collpane_handlers
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_ANY, wxID_OK, wxID_HIGHEST, wxOK, wxCANCEL, &
        wxCENTRE, wxRESIZE_BORDER, wxDEFAULT_DIALOG_STYLE, wxVERTICAL, &
        wxALL, wxEXPAND, wxALIGN_LEFT, wxALIGN_RIGHT, &
        wxTAB_TRAVERSAL, wxBORDER_NONE, wxEVT_BUTTON, &
        wxEVT_COLLAPSIBLEPANE_CHANGED
    use wx_free_functions, only: log_message, wx_about_box
    use wx_events
    use wx_window, only: wx_window_close, wx_window_destroy, wx_window_set_sizer, &
        wx_window_layout, wx_window_set_label, wx_window_find_window_by_id_self
    use wx_sizer, only: wx_sizer_add_window, wx_sizer_add_sizer, &
        wx_sizer_add_spacer, wx_sizer_set_size_hints, wx_sizer_get_default_border, &
        wx_sizer_get_item_window
    use wx_sizer_item, only: wx_sizer_item_set_flag
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_grid_sizer, only: wx_grid_sizer_create
    use wx_static_text, only: wx_static_text_create
    use wx_text_ctrl, only: wx_text_ctrl_create
    use wx_button, only: wx_button_create
    use wx_collapsible_pane, only: wx_collapsible_pane_create, &
        wx_collapsible_pane_collapse, wx_collapsible_pane_expand, &
        wx_collapsible_pane_is_collapsed, wx_collapsible_pane_get_pane, &
        wx_collapsible_pane_get_label, wx_collapsible_pane_set_label
    use wx_collapsible_header_ctrl, only: wx_collapsible_header_ctrl_is_collapsed
    use wx_collapsible_pane_event, only: wx_collapsible_pane_event_get_collapsed
    use wx_update_ui_event, only: wx_update_ui_event_enable
    use wx_dialog, only: wx_dialog_create, wx_dialog_show_modal
    use wx_text_entry_dialog, only: wx_text_entry_dialog_create, &
        wx_text_entry_dialog_get_value
    use wx_about_dialog_info, only: wx_about_dialog_info_create, &
        wx_about_dialog_info_delete, wx_about_dialog_info_set_name, &
        wx_about_dialog_info_set_description, wx_about_dialog_info_set_copyright
    use collpane_globals
    implicit none

contains

    !--------------------------------------------------------------------------
    ! wxGetTextFromUser("Enter new label", wxGetTextFromUserPromptStr, ...)
    !--------------------------------------------------------------------------
    function get_text_from_user(message, caption, default_text) result(text)
        character(len=*), intent(in) :: message
        character(len=*), intent(in) :: caption
        character(len=*), intent(in) :: default_text
        character(len=:), allocatable :: text
        type(wxWindow_t) :: no_parent
        type(wxTextEntryDialog_t) :: dlg
        integer :: rc
        logical :: destroyed

        text = ""
        no_parent%ptr = c_null_ptr
        dlg = wx_text_entry_dialog_create(no_parent, message, caption, default_text, &
            int(ior(ior(wxOK(), wxCANCEL()), wxCENTRE()), c_long), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int)
        if (.not. dlg%is_valid()) return

        rc = int(wx_dialog_show_modal(dlg))
        if (rc == int(wxID_OK())) text = wx_text_entry_dialog_get_value(dlg)
        destroyed = wx_window_destroy(dlg)
    end function get_text_from_user

    !--------------------------------------------------------------------------
    ! Pane > Collapse  --  m_collPane->Collapse()
    !--------------------------------------------------------------------------
    subroutine on_collapse(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call wx_collapsible_pane_collapse(g_coll_pane, .true.)
    end subroutine on_collapse

    !--------------------------------------------------------------------------
    ! Pane > Expand  --  m_collPane->Expand()
    !--------------------------------------------------------------------------
    subroutine on_expand(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call wx_collapsible_pane_expand(g_coll_pane)
    end subroutine on_expand

    !--------------------------------------------------------------------------
    ! Pane > Set label...
    !--------------------------------------------------------------------------
    subroutine on_set_label(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        character(len=:), allocatable :: text

        if (.not. c_associated(evt)) return

        text = get_text_from_user("Enter new label", "Enter text", &
            wx_collapsible_pane_get_label(g_coll_pane))
        call wx_collapsible_pane_set_label(g_coll_pane, text)
    end subroutine on_set_label

    !--------------------------------------------------------------------------
    ! Pane > Quit  --  Close(true)
    !--------------------------------------------------------------------------
    subroutine on_quit(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: closed

        if (.not. c_associated(evt)) return
        closed = wx_window_close(g_frame, .true.)
    end subroutine on_quit

    !--------------------------------------------------------------------------
    ! Help > About
    !--------------------------------------------------------------------------
    subroutine on_about(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxAboutDialogInfo_t) :: info

        if (.not. c_associated(evt)) return

        info%ptr = wx_about_dialog_info_create()
        info%owned = .true.
        if (.not. info%is_valid()) return

        call wx_about_dialog_info_set_name(info, "wxCollapsiblePane sample")
        call wx_about_dialog_info_set_description(info, &
            "This sample program demonstrates usage of wxCollapsiblePane")
        call wx_about_dialog_info_set_copyright(info, &
            "(C) 2006 Francesco Montorsi <frm@users.sourceforge.net>")

        ! wxAboutBox(info, this)
        call wx_about_box(info, g_frame)
        call wx_about_dialog_info_delete(info)
    end subroutine on_about

    !--------------------------------------------------------------------------
    ! EVT_UPDATE_UI(PANE_COLLAPSE):  event.Enable(!m_collPane->IsCollapsed())
    !--------------------------------------------------------------------------
    subroutine on_collapse_update_ui(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxUpdateUIEvent_t) :: ui

        if (.not. c_associated(evt)) return
        ui = wxupdateuievent_from_ptr(evt, .false.)
        call wx_update_ui_event_enable(ui, .not. wx_collapsible_pane_is_collapsed(g_coll_pane))
    end subroutine on_collapse_update_ui

    !--------------------------------------------------------------------------
    ! EVT_UPDATE_UI(PANE_EXPAND):  event.Enable(m_collPane->IsCollapsed())
    !--------------------------------------------------------------------------
    subroutine on_expand_update_ui(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxUpdateUIEvent_t) :: ui

        if (.not. c_associated(evt)) return
        ui = wxupdateuievent_from_ptr(evt, .false.)
        call wx_update_ui_event_enable(ui, wx_collapsible_pane_is_collapsed(g_coll_pane))
    end subroutine on_expand_update_ui

    !--------------------------------------------------------------------------
    ! EVT_COLLAPSIBLEHEADER_CHANGED
    !--------------------------------------------------------------------------
    subroutine on_collapsible_header_changed(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return

        if (wx_collapsible_header_ctrl_is_collapsed(g_coll_header)) then
            call wx_window_set_label(g_coll_header, "Collapsed wxCollapsibleHeaderCtrl")
        else
            call wx_window_set_label(g_coll_header, "Expanded wxCollapsibleHeaderCtrl")
        end if
    end subroutine on_collapsible_header_changed

    !--------------------------------------------------------------------------
    ! Pane > Show dialog...  --  MyDialog dlg(this); dlg.ShowModal();
    !--------------------------------------------------------------------------
    subroutine on_show_dialog(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call show_test_dialog()
    end subroutine on_show_dialog

    subroutine show_test_dialog()
        type(wxBoxSizer_t) :: sz
        type(wxStaticText_t) :: label1
        type(wxButton_t) :: toggle_button
        type(wxTextCtrl_t) :: plain_text
        type(wxButton_t) :: ok_button
        type(wxWindow_t) :: pane_win
        type(wxSizerItem_t) :: spacer_item
        integer :: border, rc, dummy
        logical :: destroyed

        ! wxDialog(parent, wxID_ANY, "Test dialog", wxDefaultPosition,
        !          wxDefaultSize, wxRESIZE_BORDER|wxDEFAULT_DIALOG_STYLE)
        g_dlg = wx_dialog_create(g_frame, wxID_ANY(), "Test dialog", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(wxRESIZE_BORDER(), wxDEFAULT_DIALOG_STYLE()))
        if (.not. g_dlg%is_valid()) return

        ! wxSizerFlags().Border() border width, as computed by wxWidgets.
        border = wx_sizer_get_default_border()

        sz = wx_box_sizer_create(wxVERTICAL())

        label1 = wx_static_text_create(g_dlg, wxID_ANY(), &
            "This dialog allows you to test the wxCollapsiblePane control", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (label1%is_valid()) &
            call wx_sizer_add_window(sz, label1, 0_c_int, wxALL(), &
                int(border, c_int), c_null_ptr)

        ! wxButton(this, PANEDLG_TOGGLESTATUS_BTN, "Change status"),
        !     wxSizerFlags(1).Expand().Border()
        toggle_button = wx_button_create(g_dlg, wxID_HIGHEST(), "Change status", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (toggle_button%is_valid()) &
            call wx_sizer_add_window(sz, toggle_button, 1_c_int, &
                ior(wxEXPAND(), wxALL()), int(border, c_int), c_null_ptr)

        ! m_collPane = new wxCollapsiblePane(this, -1, "Click here for a surprise");
        g_dlg_coll_pane = wx_collapsible_pane_create(g_dlg, wxID_ANY(), &
            "Click here for a surprise", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(wxTAB_TRAVERSAL(), wxBORDER_NONE()))
        if (g_dlg_coll_pane%is_valid()) &
            call wx_sizer_add_window(sz, g_dlg_coll_pane, 0_c_int, &
                ior(wxEXPAND(), wxALL()), int(border, c_int), c_null_ptr)

        plain_text = wx_text_ctrl_create(g_dlg, wxID_ANY(), "just a test", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (plain_text%is_valid()) &
            call wx_sizer_add_window(sz, plain_text, 0_c_int, &
                ior(wxEXPAND(), wxALL()), int(border, c_int), c_null_ptr)

        ! sz->AddSpacer(10);
        spacer_item = wx_sizer_add_spacer(sz, 10_c_int)

        ! sz->Add(new wxButton(this, wxID_OK), wxSizerFlags().Right().Border());
        ok_button = wx_button_create(g_dlg, wxID_OK(), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (ok_button%is_valid()) &
            call wx_sizer_add_window(sz, ok_button, 0_c_int, &
                ior(wxALIGN_RIGHT(), wxALL()), int(border, c_int), c_null_ptr)

        ! Controls inside the collapsible pane: wxGridSizer(4, 1, 5, 5).
        pane_win = wx_collapsible_pane_get_pane(g_dlg_coll_pane)
        g_dlg_pane_sizer = wx_grid_sizer_create(4_c_int, 1_c_int, 5_c_int, 5_c_int)

        label1 = wx_static_text_create(pane_win, wxID_ANY(), "Static text", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (label1%is_valid()) &
            call wx_sizer_add_window(g_dlg_pane_sizer, label1, 0_c_int, &
                wxALIGN_LEFT(), 0_c_int, c_null_ptr)

        label1 = wx_static_text_create(pane_win, wxID_ANY(), "Yet another one!", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (label1%is_valid()) &
            call wx_sizer_add_window(g_dlg_pane_sizer, label1, 0_c_int, &
                wxALIGN_LEFT(), 0_c_int, c_null_ptr)

        g_dlg_text_ctrl = wx_text_ctrl_create(pane_win, PANE_TEXTCTRL, &
            "Text control", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (g_dlg_text_ctrl%is_valid()) &
            call wx_sizer_add_window(g_dlg_pane_sizer, g_dlg_text_ctrl, 0_c_int, &
                wxALIGN_LEFT(), 0_c_int, c_null_ptr)

        toggle_button = wx_button_create(pane_win, PANE_BUTTON, &
            "Press to align right", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (toggle_button%is_valid()) &
            call wx_sizer_add_window(g_dlg_pane_sizer, toggle_button, 0_c_int, &
                wxALIGN_LEFT(), 0_c_int, c_null_ptr)

        call wx_window_set_sizer(pane_win, g_dlg_pane_sizer, .false.)
        call wx_sizer_set_size_hints(g_dlg_pane_sizer, pane_win)

        call wx_window_set_sizer(g_dlg, sz, .false.)
        call wx_sizer_set_size_hints(sz, g_dlg)

        ! Event table of MyDialog.
        call wx_connect(g_dlg, wxEVT_BUTTON(), on_toggle_status, id=wxID_HIGHEST())
        call wx_connect(g_dlg, wxEVT_COLLAPSIBLEPANE_CHANGED(), on_pane_changed)
        call wx_connect(g_dlg, wxEVT_BUTTON(), on_align_button, id=PANE_BUTTON)

        rc = int(wx_dialog_show_modal(g_dlg))
        destroyed = wx_window_destroy(g_dlg)

        ! The controls of the destroyed dialog are gone.
        g_dlg%ptr = c_null_ptr
        g_dlg_coll_pane%ptr = c_null_ptr
        g_dlg_pane_sizer%ptr = c_null_ptr
        g_dlg_text_ctrl%ptr = c_null_ptr
    end subroutine show_test_dialog

    !--------------------------------------------------------------------------
    ! MyDialog: EVT_BUTTON(PANEDLG_TOGGLESTATUS_BTN)
    !--------------------------------------------------------------------------
    subroutine on_toggle_status(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call wx_collapsible_pane_collapse(g_dlg_coll_pane, &
            .not. wx_collapsible_pane_is_collapsed(g_dlg_coll_pane))
    end subroutine on_toggle_status

    !--------------------------------------------------------------------------
    ! MyDialog: EVT_BUTTON(PANE_BUTTON) -- right-align the text control
    !--------------------------------------------------------------------------
    subroutine on_align_button(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxWindow_t) :: text_window
        type(wxSizerItem_t) :: item
        integer :: laid_out

        if (.not. c_associated(evt)) return

        ! m_paneSizer->GetItem(FindWindow(PANE_TEXTCTRL), true)
        text_window = wx_window_find_window_by_id_self(g_dlg, int(PANE_TEXTCTRL, c_int))
        if (.not. text_window%is_valid()) return

        item = wx_sizer_get_item_window(g_dlg_pane_sizer, text_window, .true.)
        if (.not. item%is_valid()) return

        call wx_sizer_item_set_flag(item, wxALIGN_RIGHT())
        laid_out = int(wx_window_layout(g_dlg))
    end subroutine on_align_button

    !--------------------------------------------------------------------------
    ! MyDialog: EVT_COLLAPSIBLEPANE_CHANGED -- wxLogMessage(...)
    !--------------------------------------------------------------------------
    subroutine on_pane_changed(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxCollapsiblePaneEvent_t) :: pane_event

        if (.not. c_associated(evt)) return

        pane_event = wxcollapsiblepaneevent_from_ptr(evt, .false.)
        if (wx_collapsible_pane_event_get_collapsed(pane_event)) then
            call log_message("The pane has just been collapsed by the user")
        else
            call log_message("The pane has just been expanded by the user")
        end if
    end subroutine on_pane_changed

end module collpane_handlers


program collpane
    use, intrinsic :: iso_c_binding
    use wx_app
    use wx_frame
    use wx_menu, only: wx_menu_create, wx_menu_append, wx_menu_append_separator
    use wx_menu_bar, only: wx_menu_bar_create, wx_menu_bar_append
    use wx_window, only: wx_window_show, wx_window_set_sizer
    use wx_sizer, only: wx_sizer_add_window, wx_sizer_add_sizer, &
        wx_sizer_add_spacer, wx_sizer_get_default_border
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_static_text, only: wx_static_text_create
    use wx_text_ctrl, only: wx_text_ctrl_create
    use wx_button, only: wx_button_create
    use wx_collapsible_pane, only: wx_collapsible_pane_create, &
        wx_collapsible_pane_get_pane
    use wx_collapsible_header_ctrl, only: wx_collapsible_header_ctrl_create
    use wx_events
    use kwx_types
    use kwxffi, only: wxID_ANY, wxID_ABOUT, wxID_EXIT, wxDEFAULT_FRAME_STYLE, &
        wxSTB_DEFAULT_STYLE, wxEVT_MENU, wxEVT_UPDATE_UI, &
        wxEVT_COLLAPSIBLEHEADER_CHANGED, wxVERTICAL, wxHORIZONTAL, wxEXPAND, &
        wxALL, wxALIGN_LEFT, wxTAB_TRAVERSAL, wxBORDER_NONE
    use collpane_globals
    use collpane_handlers
    use collpane_icon
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxStatusBar_t) :: status_bar
    type(wxMenu_t) :: pane_menu, help_menu
    type(wxMenuBar_t) :: menu_bar
    type(wxWindow_t) :: pane_win
    type(wxBoxSizer_t) :: pane_sizer, pane_sub_sizer, sizer_top
    type(wxStaticText_t) :: static_text
    type(wxTextCtrl_t) :: text_ctrl
    type(wxButton_t) :: button
    type(wxCollapsiblePane_t) :: nested_pane
    type(wxSizerItem_t) :: spacer_item
    integer :: exit_code, dummy, border
    logical :: shown

    ! wxIMPLEMENT_APP(MyApp) / MyApp::OnInit()
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    call wx_set_app_name("wxCollapsiblePane sample")

    ! MyFrame::MyFrame():
    !   wxFrame(nullptr, wxID_ANY, "wxCollapsiblePane sample",
    !           wxDefaultPosition, wxSize(420, 300))
    no_parent%ptr = c_null_ptr
    g_frame = wx_frame_create(no_parent, wxID_ANY(), "wxCollapsiblePane sample", &
        -1_c_int, -1_c_int, 420_c_int, 300_c_int, wxDEFAULT_FRAME_STYLE())
    if (.not. g_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    call set_sample_icon(g_frame)

    ! CreateStatusBar(2);
    status_bar = wx_frame_create_status_bar(g_frame, 2_c_int, &
        wxSTB_DEFAULT_STYLE(), wxID_ANY())

    ! --- menu bar ---------------------------------------------------------
    pane_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(pane_menu, PANE_COLLAPSE, &
        "Collapse" // achar(9) // "Ctrl-C", "", .false.)
    call wx_menu_append(pane_menu, PANE_EXPAND, &
        "Expand" // achar(9) // "Ctrl-E", "", .false.)
    call wx_menu_append_separator(pane_menu)
    call wx_menu_append(pane_menu, PANE_SETLABEL, &
        "Set label..." // achar(9) // "Ctrl-L", "", .false.)
    call wx_menu_append_separator(pane_menu)
    call wx_menu_append(pane_menu, PANE_SHOWDLG, &
        "Show dialog..." // achar(9) // "Ctrl-S", "", .false.)
    call wx_menu_append_separator(pane_menu)
    call wx_menu_append(pane_menu, wxID_EXIT(), "&Quit", "", .false.)

    help_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(help_menu, wxID_ABOUT(), "&About", "", .false.)

    menu_bar = wx_menu_bar_create(0_c_int)
    dummy = wx_menu_bar_append(menu_bar, pane_menu, "&Pane")
    dummy = wx_menu_bar_append(menu_bar, help_menu, "&Help")
    call wx_frame_set_menu_bar(g_frame, menu_bar)

    ! --- the collapsible pane --------------------------------------------
    ! m_collPane = new wxCollapsiblePane(this, -1, "This is a wxCollapsiblePane");
    g_coll_pane = wx_collapsible_pane_create(g_frame, wxID_ANY(), &
        "This is a wxCollapsiblePane", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
        ior(wxTAB_TRAVERSAL(), wxBORDER_NONE()))
    if (.not. g_coll_pane%is_valid()) then
        print *, "Failed to create the collapsible pane"
        stop 1
    end if

    pane_win = wx_collapsible_pane_get_pane(g_coll_pane)

    ! wxSizerFlags().Border() border width, as computed by wxWidgets.
    border = wx_sizer_get_default_border()

    pane_sizer = wx_box_sizer_create(wxHORIZONTAL())
    pane_sub_sizer = wx_box_sizer_create(wxVERTICAL())
    spacer_item = wx_sizer_add_spacer(pane_sizer, 20_c_int)
    call wx_sizer_add_sizer(pane_sizer, pane_sub_sizer, 1_c_int, 0_c_int, &
        0_c_int, c_null_ptr)

    static_text = wx_static_text_create(pane_win, wxID_ANY(), "Static text", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    if (static_text%is_valid()) &
        call wx_sizer_add_window(pane_sub_sizer, static_text, 0_c_int, &
            ior(wxALIGN_LEFT(), wxALL()), int(border, c_int), c_null_ptr)

    static_text = wx_static_text_create(pane_win, wxID_ANY(), "Yet another one!", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    if (static_text%is_valid()) &
        call wx_sizer_add_window(pane_sub_sizer, static_text, 0_c_int, &
            ior(wxALIGN_LEFT(), wxALL()), int(border, c_int), c_null_ptr)

    text_ctrl = wx_text_ctrl_create(pane_win, PANE_TEXTCTRL, "Text control", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    if (text_ctrl%is_valid()) &
        call wx_sizer_add_window(pane_sub_sizer, text_ctrl, 0_c_int, &
            ior(wxALIGN_LEFT(), wxALL()), int(border, c_int), c_null_ptr)

    button = wx_button_create(pane_win, PANE_BUTTON, "Press to align right", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    if (button%is_valid()) &
        call wx_sizer_add_window(pane_sub_sizer, button, 0_c_int, &
            ior(wxALIGN_LEFT(), wxALL()), int(border, c_int), c_null_ptr)

    ! new wxCollapsiblePane(win, -1, "Nested empty wxCollapsiblePane"),
    !     wxSizerFlags().Expand().Border()
    nested_pane = wx_collapsible_pane_create(pane_win, wxID_ANY(), &
        "Nested empty wxCollapsiblePane", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
        ior(wxTAB_TRAVERSAL(), wxBORDER_NONE()))
    if (nested_pane%is_valid()) &
        call wx_sizer_add_window(pane_sub_sizer, nested_pane, 0_c_int, &
            ior(wxEXPAND(), wxALL()), int(border, c_int), c_null_ptr)

    ! win->SetSizer(m_paneSizer);
    call wx_window_set_sizer(pane_win, pane_sizer, .false.)

    ! m_collHeaderCtrl = new wxCollapsibleHeaderCtrl(this, wxID_ANY,
    !                       "Collapsed wxCollapsibleHeaderCtrl");
    g_coll_header = wx_collapsible_header_ctrl_create(g_frame, wxID_ANY(), &
        "Collapsed wxCollapsibleHeaderCtrl", -1_c_int, -1_c_int, -1_c_int, &
        -1_c_int, wxBORDER_NONE())
    if (.not. g_coll_header%is_valid()) then
        print *, "Failed to create the collapsible header control"
        stop 1
    end if

    ! wxSizer* const sizerTop = new wxBoxSizer(wxVERTICAL);
    ! sizerTop->Add(m_collPane, wxSizerFlags(1).Expand());
    ! sizerTop->Add(m_collHeaderCtrl);
    sizer_top = wx_box_sizer_create(wxVERTICAL())
    call wx_sizer_add_window(sizer_top, g_coll_pane, 1_c_int, wxEXPAND(), &
        0_c_int, c_null_ptr)
    call wx_sizer_add_window(sizer_top, g_coll_header, 0_c_int, 0_c_int, &
        0_c_int, c_null_ptr)
    call wx_window_set_sizer(g_frame, sizer_top, .false.)

    ! --- event table of MyFrame ------------------------------------------
    call wx_connect(g_frame, wxEVT_MENU(), on_collapse, id=PANE_COLLAPSE)
    call wx_connect(g_frame, wxEVT_MENU(), on_expand, id=PANE_EXPAND)
    call wx_connect(g_frame, wxEVT_MENU(), on_set_label, id=PANE_SETLABEL)
    call wx_connect(g_frame, wxEVT_MENU(), on_show_dialog, id=PANE_SHOWDLG)
    call wx_connect(g_frame, wxEVT_MENU(), on_about, id=wxID_ABOUT())
    call wx_connect(g_frame, wxEVT_MENU(), on_quit, id=wxID_EXIT())

    call wx_connect(g_frame, wxEVT_UPDATE_UI(), on_collapse_update_ui, &
        id=PANE_COLLAPSE)
    call wx_connect(g_frame, wxEVT_UPDATE_UI(), on_expand_update_ui, &
        id=PANE_EXPAND)

    call wx_connect(g_frame, wxEVT_COLLAPSIBLEHEADER_CHANGED(), &
        on_collapsible_header_changed)

    ! frame->Show(true);
    call wx_set_top_window(g_frame)
    shown = wx_window_show(g_frame)

    ! wxApp::OnRun()
    exit_code = wx_main_loop()

    call release_sample_icon()
    call wx_shutdown()

end program collpane
