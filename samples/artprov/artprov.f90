! artprov.f90 - wxArtProvider sample in Fortran
!
! Fortran port of the wxWidgets sample src/artprov (arttest.cpp + artbrows.cpp).
!
! A frame titled "wxArtProvider sample" with a File menu (Plug-in art provider
! check item, Logging test, Resources browser, Exit) and a Help menu (About).
! "Resources browser" opens the modal "Art resources browser" dialog: a client
! wxChoice, a wxListCtrl in report mode listing every art id with its 16x16
! icon from a wxImageList, a size wxChoice (Default/16/32/64/128/256), a label
! showing the selected bitmap size and a wxStaticBitmap preview.
!
! Ported assets (all converted from the sample's XPMs to SVG):
!   sample.svg   32x32  frame icon          (SetIcon(wxICON(sample)))
!   null.svg     16x16  m_canvas initial bitmap + image list index 0
!   info/error/warning/question.svg 48x48   back the custom art provider, which
!       is NOT ported: kwxFFI exposes kwx_art_prov_create() but not the C ABI
!       of its callback, so wxArtProvider::Push(new MyArtProvider) cannot be
!       reproduced.  See "Known gaps" in the port report.
!
! Run the executable with the current directory set to this folder so that the
! relative "sample.svg" and "null.svg" paths resolve:
!     cd samples\artprov && ..\..\bin\Debug\artprov.exe

module artprov_globals
    use, intrinsic :: iso_c_binding
    use kwx_types
    implicit none

    ! Number of art ids filled by FillBitmaps(), in source order.
    integer, parameter :: ART_COUNT = 57
    ! Number of art clients filled by FillClients(), in source order.
    integer, parameter :: CLIENT_COUNT = 8
    ! Number of entries of bitmapSizes[] before its 0 terminator.
    integer, parameter :: SIZE_COUNT = 6

    ! Main frame (the C++ MyFrame instance).
    type(wxFrame_t), save :: g_frame

    ! wxArtBrowserDialog members.
    type(wxDialog_t), save :: g_dialog
    type(wxListCtrl_t), save :: g_list
    type(wxStaticBitmap_t), save :: g_canvas
    type(wxStaticText_t), save :: g_text
    type(wxChoice_t), save :: g_sizes
    type(wxChoice_t), save :: g_choice
    type(wxImageList_t), save :: g_images

    ! m_client / m_currentArtId
    character(len=32), save :: g_client = ""
    character(len=32), save :: g_current_art_id = "wxART_ERROR"

    ! Mirrored state of the "Plug-in art provider" check item.
    logical, save :: g_provider_checked = .false.

    ! Menu command ids (ID_Logs = wxID_HIGHEST, ID_Browser, ID_PlugProvider).
    integer(c_int), save :: g_id_logs = 0
    integer(c_int), save :: g_id_browser = 0
    integer(c_int), save :: g_id_plug = 0
    ! ::wxNewId() result used for the size wxChoice (SIZE_CHOICE_ID).
    integer(c_int), save :: g_size_choice_id = 0

    ! static const int bitmapSizes[] = { -1, 16, 32, 64, 128, 256, 0 };
    integer(c_int), save :: g_size_table(SIZE_COUNT) = [-1, 16, 32, 64, 128, 256]

    ! Art id / client id strings.  The C++ ART_ICON/ART_CLIENT macros stringify
    ! the wxART_* macro name, and wxART_* is defined as exactly that literal,
    ! so the table below is the value of each id.  Art clients are different:
    ! wx/artprov.h defines wxART_MAKE_CLIENT_ID_FROM_STR(id) as (id + "_C"), so
    ! the client *value* carries a trailing "_C" ("wxART_OTHER_C") while the
    ! name displayed by the C++ ART_CLIENT macro does not.
    character(len=32), save :: g_art_ids(ART_COUNT)
    character(len=32), save :: g_client_labels(CLIENT_COUNT)
    character(len=32), save :: g_client_ids(CLIENT_COUNT)

    ! Asset bundles, kept alive for the whole run.
    type(wxBitmapBundle_t), save :: g_bundle_sample
    type(wxBitmapBundle_t), save :: g_bundle_null

end module artprov_globals


module artprov_core
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxSIZE_USE_EXISTING, wxLIST_STATE_FOCUSED, &
        wxLIST_NEXT_ALL, wxLIST_AUTOSIZE, wxIMAGE_LIST_SMALL
    use wx_window, only: wx_window_set_size, wx_window_layout
    use wx_control, only: wx_control_set_label
    use wx_list_ctrl, only: wx_list_ctrl_get_next_item, wx_list_ctrl_delete_all_items, &
        wx_list_ctrl_assign_image_list, wx_list_ctrl_set_column_width, &
        wx_list_ctrl_set_item_state, wx_list_ctrl_insert_item_with_label
    use wx_static_bitmap, only: wx_static_bitmap_set_bitmap
    use wx_image_list, only: wx_image_list_create, wx_image_list_add_icon
    use wx_art_provider, only: wx_art_provider_get_bitmap, wx_art_provider_get_icon
    use wx_icon, only: wx_icon_create_default, wx_icon_copy_from_bitmap, &
        wx_icon_is_ok, wx_icon_delete
    use wx_bitmap, only: wx_bitmap_get_width, wx_bitmap_get_height, wx_bitmap_delete
    use wx_bitmap_bundle, only: wx_bitmap_bundle_from_svg_file, &
        wx_bitmap_bundle_get_bitmap, wx_bitmap_bundle_delete
    use wx_frame, only: wx_frame_set_icon
    use wx_busy_cursor, only: wx_busy_cursor_create, wx_busy_cursor_delete
    use artprov_globals
    implicit none
    private

    public :: init_art_ids, load_assets, release_assets, set_sample_icon
    public :: set_art_client, set_art_bitmap, clear_dialog_handles

contains

    !--------------------------------------------------------------------------
    ! FillClients() / FillBitmaps() id tables, in source order.
    !--------------------------------------------------------------------------
    subroutine init_art_ids()
        integer :: i

        g_client_labels(1) = "wxART_OTHER"
        g_client_labels(2) = "wxART_BUTTON"
        g_client_labels(3) = "wxART_TOOLBAR"
        g_client_labels(4) = "wxART_MENU"
        g_client_labels(5) = "wxART_FRAME_ICON"
        g_client_labels(6) = "wxART_CMN_DIALOG"
        g_client_labels(7) = "wxART_HELP_BROWSER"
        g_client_labels(8) = "wxART_MESSAGE_BOX"

        do i = 1, CLIENT_COUNT
            g_client_ids(i) = trim(g_client_labels(i)) // "_C"
        end do

        g_art_ids(1) = "wxART_ERROR"
        g_art_ids(2) = "wxART_QUESTION"
        g_art_ids(3) = "wxART_WARNING"
        g_art_ids(4) = "wxART_INFORMATION"
        g_art_ids(5) = "wxART_ADD_BOOKMARK"
        g_art_ids(6) = "wxART_DEL_BOOKMARK"
        g_art_ids(7) = "wxART_HELP_SIDE_PANEL"
        g_art_ids(8) = "wxART_HELP_SETTINGS"
        g_art_ids(9) = "wxART_HELP_BOOK"
        g_art_ids(10) = "wxART_HELP_FOLDER"
        g_art_ids(11) = "wxART_HELP_PAGE"
        g_art_ids(12) = "wxART_GO_BACK"
        g_art_ids(13) = "wxART_GO_FORWARD"
        g_art_ids(14) = "wxART_GO_UP"
        g_art_ids(15) = "wxART_GO_DOWN"
        g_art_ids(16) = "wxART_GO_TO_PARENT"
        g_art_ids(17) = "wxART_GO_HOME"
        g_art_ids(18) = "wxART_GOTO_FIRST"
        g_art_ids(19) = "wxART_GOTO_LAST"
        g_art_ids(20) = "wxART_PRINT"
        g_art_ids(21) = "wxART_HELP"
        g_art_ids(22) = "wxART_TIP"
        g_art_ids(23) = "wxART_REPORT_VIEW"
        g_art_ids(24) = "wxART_LIST_VIEW"
        g_art_ids(25) = "wxART_NEW_DIR"
        g_art_ids(26) = "wxART_FOLDER"
        g_art_ids(27) = "wxART_FOLDER_OPEN"
        g_art_ids(28) = "wxART_GO_DIR_UP"
        g_art_ids(29) = "wxART_EXECUTABLE_FILE"
        g_art_ids(30) = "wxART_NORMAL_FILE"
        g_art_ids(31) = "wxART_TICK_MARK"
        g_art_ids(32) = "wxART_CROSS_MARK"
        g_art_ids(33) = "wxART_MISSING_IMAGE"
        g_art_ids(34) = "wxART_NEW"
        g_art_ids(35) = "wxART_FILE_OPEN"
        g_art_ids(36) = "wxART_FILE_SAVE"
        g_art_ids(37) = "wxART_FILE_SAVE_AS"
        g_art_ids(38) = "wxART_DELETE"
        g_art_ids(39) = "wxART_COPY"
        g_art_ids(40) = "wxART_CUT"
        g_art_ids(41) = "wxART_PASTE"
        g_art_ids(42) = "wxART_UNDO"
        g_art_ids(43) = "wxART_REDO"
        g_art_ids(44) = "wxART_PLUS"
        g_art_ids(45) = "wxART_MINUS"
        g_art_ids(46) = "wxART_CLOSE"
        g_art_ids(47) = "wxART_QUIT"
        g_art_ids(48) = "wxART_FIND"
        g_art_ids(49) = "wxART_FIND_AND_REPLACE"
        g_art_ids(50) = "wxART_EDIT"
        g_art_ids(51) = "wxART_FULL_SCREEN"
        g_art_ids(52) = "wxART_HARDDISK"
        g_art_ids(53) = "wxART_FLOPPY"
        g_art_ids(54) = "wxART_CDROM"
        g_art_ids(55) = "wxART_REMOVABLE"
        g_art_ids(56) = "wxART_REFRESH"
        g_art_ids(57) = "wxART_STOP"
    end subroutine init_art_ids

    !--------------------------------------------------------------------------
    ! Load the two SVG assets the port actually draws with.
    !--------------------------------------------------------------------------
    subroutine load_assets()
        g_bundle_sample = wx_bitmap_bundle_from_svg_file("sample.svg", 32_c_int, 32_c_int)
        g_bundle_null = wx_bitmap_bundle_from_svg_file("null.svg", 16_c_int, 16_c_int)
    end subroutine load_assets

    !--------------------------------------------------------------------------
    ! Release the two asset bundles once the event loop has returned.
    !--------------------------------------------------------------------------
    subroutine release_assets()
        if (g_bundle_sample%is_valid()) call wx_bitmap_bundle_delete(g_bundle_sample)
        if (g_bundle_null%is_valid()) call wx_bitmap_bundle_delete(g_bundle_null)
    end subroutine release_assets

    !--------------------------------------------------------------------------
    ! SetIcon(wxICON(sample))
    !--------------------------------------------------------------------------
    subroutine set_sample_icon()
        type(wxBitmap_t) :: bitmap
        type(wxIcon_t) :: icon

        if (.not. g_bundle_sample%is_valid()) return

        bitmap = wx_bitmap_bundle_get_bitmap(g_bundle_sample, 32_c_int, 32_c_int)
        if (bitmap%is_valid()) then
            icon = wx_icon_create_default()
            if (icon%is_valid()) then
                call wx_icon_copy_from_bitmap(icon, bitmap)
                if (wx_icon_is_ok(icon)) call wx_frame_set_icon(g_frame, icon)
                call wx_icon_delete(icon)
            end if
            call wx_bitmap_delete(bitmap)
        end if
    end subroutine set_sample_icon

    !--------------------------------------------------------------------------
    ! wxArtBrowserDialog::SetArtClient()
    !--------------------------------------------------------------------------
    subroutine set_art_client(client)
        character(len=*), intent(in) :: client
        type(wxBusyCursor_t) :: cursor
        type(wxBitmap_t) :: bitmap
        type(wxIcon_t) :: icon
        integer(c_int) :: sel, rc
        logical :: ok

        cursor = wx_busy_cursor_create()

        g_images = wx_image_list_create(16_c_int, 16_c_int, 1_c_int, 0_c_int)
        bitmap = wx_bitmap_bundle_get_bitmap(g_bundle_null, 16_c_int, 16_c_int)
        icon = wx_icon_create_default()
        if (bitmap%is_valid()) call wx_icon_copy_from_bitmap(icon, bitmap)
        rc = wx_image_list_add_icon(g_images, icon)      ! index 0
        call wx_icon_delete(icon)
        call wx_bitmap_delete(bitmap)

        sel = wx_list_ctrl_get_next_item(g_list, -1_c_int, wxLIST_NEXT_ALL(), &
            wxLIST_STATE_FOCUSED())
        if (sel < 0) sel = 0

        ok = wx_list_ctrl_delete_all_items(g_list)
        call fill_bitmaps(g_images, client)
        call wx_list_ctrl_assign_image_list(g_list, g_images, wxIMAGE_LIST_SMALL())
        ! The list control took ownership of the image list; never release it.
        g_images%owned = .false.
        ok = wx_list_ctrl_set_column_width(g_list, 0_c_int, wxLIST_AUTOSIZE())
        ok = wx_list_ctrl_set_item_state(g_list, sel, wxLIST_STATE_FOCUSED(), &
            wxLIST_STATE_FOCUSED())

        g_client = client

        call set_art_bitmap(g_art_ids(sel + 1), g_client, -1_c_int, -1_c_int)

        call wx_busy_cursor_delete(cursor)
    end subroutine set_art_client

    !--------------------------------------------------------------------------
    ! FillBitmaps(): one row per art id, image index from the client's icon.
    !--------------------------------------------------------------------------
    subroutine fill_bitmaps(images, client)
        type(wxImageList_t), intent(in) :: images
        character(len=*), intent(in) :: client
        type(wxIcon_t) :: icon
        integer(c_int) :: i, ind, index, rc

        index = 0
        do i = 1, ART_COUNT
            icon = wx_art_provider_get_icon(g_art_ids(i), client, 16_c_int, 16_c_int)
            if (wx_icon_is_ok(icon)) then
                ind = wx_image_list_add_icon(images, icon)
            else
                ind = 0
            end if
            rc = wx_list_ctrl_insert_item_with_label(g_list, index, g_art_ids(i), ind)
            index = index + 1
            call wx_icon_delete(icon)
        end do
    end subroutine fill_bitmaps

    !--------------------------------------------------------------------------
    ! wxArtBrowserDialog::SetArtBitmap()
    !--------------------------------------------------------------------------
    subroutine set_art_bitmap(id, client, width, height)
        character(len=*), intent(in) :: id
        character(len=*), intent(in) :: client
        integer(c_int), intent(in) :: width
        integer(c_int), intent(in) :: height
        type(wxBitmap_t) :: bitmap
        character(len=32) :: label
        integer(c_int) :: bw, bh, rc

        bitmap = wx_art_provider_get_bitmap(id, client, width, height)
        bw = wx_bitmap_get_width(bitmap)
        bh = wx_bitmap_get_height(bitmap)

        call wx_window_set_size(g_canvas, -1_c_int, -1_c_int, bw, bh, wxSIZE_USE_EXISTING())
        call wx_static_bitmap_set_bitmap(g_canvas, bitmap)

        write(label, '(a,i0,a,i0)') "Size: ", bw, " x ", bh
        call wx_control_set_label(g_text, trim(label))

        rc = wx_window_layout(g_dialog)

        call wx_bitmap_delete(bitmap)
    end subroutine set_art_bitmap

    !--------------------------------------------------------------------------
    ! Forget the dialog handles once the modal dialog has been destroyed.
    !--------------------------------------------------------------------------
    subroutine clear_dialog_handles()
        g_dialog%ptr = c_null_ptr
        g_dialog%owned = .false.
        g_list%ptr = c_null_ptr
        g_list%owned = .false.
        g_canvas%ptr = c_null_ptr
        g_canvas%owned = .false.
        g_text%ptr = c_null_ptr
        g_text%owned = .false.
        g_sizes%ptr = c_null_ptr
        g_sizes%owned = .false.
        g_choice%ptr = c_null_ptr
        g_choice%owned = .false.
        g_images%ptr = c_null_ptr
        g_images%owned = .false.
    end subroutine clear_dialog_handles

end module artprov_core


module artprov_dialog
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_ANY, wxID_OK, wxVERTICAL, wxHORIZONTAL, wxLEFT, wxRIGHT, &
        wxALL, wxLC_REPORT, wxBORDER_SUNKEN, wxLIST_FORMAT_LEFT, &
        wxDEFAULT_DIALOG_STYLE, wxRESIZE_BORDER
    use wx_dialog, only: wx_dialog_create
    use wx_window, only: wx_window_set_sizer_and_fit
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add, wx_sizer_add_window_flags, wx_sizer_add_sizer_flags
    use wx_sizer_flags, only: wx_sizer_flags_create, wx_sizer_flags_delete, &
        wx_sizer_flags_expand, wx_sizer_flags_border, wx_sizer_flags_double_border, &
        wx_sizer_flags_double_horz_border, wx_sizer_flags_center_vertical, &
        wx_sizer_flags_right
    use wx_static_text, only: wx_static_text_create
    use wx_choice, only: wx_choice_create, wx_choice_set_selection, wx_choice_get_count
    use wx_list_ctrl, only: wx_list_ctrl_create, wx_list_ctrl_append_column
    use wx_static_bitmap, only: wx_static_bitmap_create
    use wx_button, only: wx_button_create, wx_button_set_default
    use wx_bitmap, only: wx_bitmap_delete
    use wx_bitmap_bundle, only: wx_bitmap_bundle_get_bitmap
    use artprov_globals
    use artprov_core, only: set_art_client
    implicit none
    private

    public :: build_dialog, initialize_browser

contains

    !--------------------------------------------------------------------------
    ! wxArtBrowserDialog constructor body.
    !--------------------------------------------------------------------------
    subroutine build_dialog(parent)
        class(wxWindow_t), intent(in) :: parent
        type(wxBoxSizer_t) :: sizer, subsizer, subsub
        type(wxsizerflags_t) :: flags
        type(wxStaticText_t) :: label
        type(wxButton_t) :: ok
        type(wxBitmap_t) :: bitmap
        character(len=32) :: client_items(CLIENT_COUNT)
        character(len=32) :: size_items(SIZE_COUNT)
        integer :: i
        integer(c_int) :: rc

        g_dialog = wx_dialog_create(parent, wxID_ANY(), "Art resources browser", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(wxDEFAULT_DIALOG_STYLE(), wxRESIZE_BORDER()))

        sizer = wx_box_sizer_create(wxVERTICAL())

        ! wxChoice *choice = new wxChoice(this, wxID_ANY); FillClients(choice);
        do i = 1, CLIENT_COUNT
            client_items(i) = g_client_labels(i)
        end do
        g_choice = wx_choice_create(g_dialog, wxID_ANY(), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, client_items, 0_c_int)

        subsizer = wx_box_sizer_create(wxHORIZONTAL())

        label = wx_static_text_create(g_dialog, wxID_ANY(), "Client:", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)

        flags = wx_sizer_flags_create(0_c_int)
        call wx_sizer_flags_center_vertical(flags)
        call wx_sizer_add_window_flags(subsizer, label, flags)
        call wx_sizer_flags_delete(flags)

        flags = wx_sizer_flags_create(1_c_int)
        call wx_sizer_flags_border(flags, wxLEFT())
        call wx_sizer_add_window_flags(subsizer, g_choice, flags)
        call wx_sizer_flags_delete(flags)

        flags = wx_sizer_flags_create(0_c_int)
        call wx_sizer_flags_expand(flags)
        call wx_sizer_flags_double_border(flags, wxALL())
        call wx_sizer_add_sizer_flags(sizer, subsizer, flags)
        call wx_sizer_flags_delete(flags)

        subsizer = wx_box_sizer_create(wxHORIZONTAL())

        g_list = wx_list_ctrl_create(g_dialog, wxID_ANY(), -1_c_int, -1_c_int, &
            250_c_int, 300_c_int, ior(wxLC_REPORT(), wxBORDER_SUNKEN()))
        rc = wx_list_ctrl_append_column(g_list, "wxArtID", wxLIST_FORMAT_LEFT(), -1_c_int)

        flags = wx_sizer_flags_create(0_c_int)
        call wx_sizer_flags_expand(flags)
        call wx_sizer_flags_double_border(flags, wxRIGHT())
        call wx_sizer_add_window_flags(subsizer, g_list, flags)
        call wx_sizer_flags_delete(flags)

        subsub = wx_box_sizer_create(wxVERTICAL())

        ! m_sizes: "Default", then "%d x %d" for each bitmapSizes[] entry.
        size_items(1) = "Default"
        do i = 2, SIZE_COUNT
            write(size_items(i), '(i0,a,i0)') g_size_table(i), " x ", g_size_table(i)
        end do
        g_sizes = wx_choice_create(g_dialog, g_size_choice_id, -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, size_items, 0_c_int)
        call wx_choice_set_selection(g_sizes, 0_c_int)

        flags = wx_sizer_flags_create(0_c_int)
        call wx_sizer_flags_border(flags, wxALL())
        call wx_sizer_add_window_flags(subsub, g_sizes, flags)
        call wx_sizer_flags_delete(flags)

        g_text = wx_static_text_create(g_dialog, wxID_ANY(), "Size: 333x333", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)

        flags = wx_sizer_flags_create(0_c_int)
        call wx_sizer_flags_border(flags, wxALL())
        call wx_sizer_add_window_flags(subsub, g_text, flags)
        call wx_sizer_flags_delete(flags)

        ! new wxStaticBitmap(this, wxID_ANY, wxBitmap(null_xpm))
        bitmap = wx_bitmap_bundle_get_bitmap(g_bundle_null, 16_c_int, 16_c_int)
        g_canvas = wx_static_bitmap_create(g_dialog, wxID_ANY(), bitmap, &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_bitmap_delete(bitmap)

        flags = wx_sizer_flags_create(0_c_int)
        call wx_sizer_add_window_flags(subsub, g_canvas, flags)
        call wx_sizer_flags_delete(flags)

        ! subsub->Add(256, 256)
        call wx_sizer_add(subsub, 256_c_int, 256_c_int, 0_c_int, 0_c_int, 0_c_int, c_null_ptr)

        flags = wx_sizer_flags_create(1_c_int)
        call wx_sizer_flags_border(flags, wxLEFT())
        call wx_sizer_add_sizer_flags(subsizer, subsub, flags)
        call wx_sizer_flags_delete(flags)

        flags = wx_sizer_flags_create(1_c_int)
        call wx_sizer_flags_expand(flags)
        call wx_sizer_flags_double_horz_border(flags)
        call wx_sizer_add_sizer_flags(sizer, subsizer, flags)
        call wx_sizer_flags_delete(flags)

        ok = wx_button_create(g_dialog, wxID_OK(), "Close", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_button_set_default(ok)

        flags = wx_sizer_flags_create(0_c_int)
        call wx_sizer_flags_right(flags)
        call wx_sizer_flags_double_border(flags, wxALL())
        call wx_sizer_add_window_flags(sizer, ok, flags)
        call wx_sizer_flags_delete(flags)

        ! SetSizerAndFit(sizer)
        call wx_window_set_sizer_and_fit(g_dialog, sizer, .true.)
    end subroutine build_dialog

    !--------------------------------------------------------------------------
    ! The two statements following SetSizerAndFit() in the constructor.
    !--------------------------------------------------------------------------
    subroutine initialize_browser()
        call wx_choice_set_selection(g_choice, wx_choice_get_count(g_choice) - 1_c_int)
        call set_art_client(g_client_ids(CLIENT_COUNT))
    end subroutine initialize_browser

end module artprov_dialog


module artprov_handlers
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_ABOUT, wxOK, wxICON_INFORMATION, &
        wxEVT_MENU, wxEVT_CHOICE, wxEVT_LIST_ITEM_SELECTED
    use wx_events, only: wx_connect, wx_command_event_is_checked, &
        wx_command_event_get_selection
    use wx_list_event, only: wx_list_event_get_index
    use wx_window, only: wx_window_close, wx_window_destroy
    use wx_dialog, only: wx_dialog_show_modal
    use wx_choice, only: wx_choice_get_selection
    use wx_free_functions, only: log_message, log_error, log_warning, &
        kwx_message_box, wx_version_string
    use wx_log, only: wx_log_get_active_target, wx_log_flush_active
    use artprov_globals
    use artprov_core, only: set_art_bitmap, set_art_client, clear_dialog_handles
    use artprov_dialog, only: build_dialog, initialize_browser
    implicit none
    private

    public :: on_quit, on_logs, on_about, on_browser, on_plug_provider
    public :: connect_dialog_events

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
    ! MyFrame::OnLogs
    !--------------------------------------------------------------------------
    subroutine on_logs(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(kwxLog_t) :: target

        if (.not. c_associated(evt)) return

        call log_message("Some information.")
        call log_error("This is an error.")
        call log_warning("A warning.")
        call log_error("Yet another error.")

        ! wxLog::GetActiveTarget()->Flush()
        target = kwxlog_from_ptr(wx_log_get_active_target(), .false.)
        if (c_associated(target%ptr)) call wx_log_flush_active(target)

        call log_message("Check/uncheck 'File/Plug-in art provider' and try again.")
    end subroutine on_logs

    !--------------------------------------------------------------------------
    ! MyFrame::OnAbout -- wxMessageBox(msg, ..., wxOK | wxICON_INFORMATION, this)
    !--------------------------------------------------------------------------
    subroutine on_about(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        character(len=:), allocatable :: message
        integer(c_int) :: rc

        if (.not. c_associated(evt)) return

        message = "This is the about dialog of wxArtProvider sample." // achar(10) // &
            "Welcome to " // wx_version_string()

        rc = kwx_message_box(message, "About wxArtProvider sample", &
            ior(wxOK(), wxICON_INFORMATION()), g_frame, -1_c_int, -1_c_int)
    end subroutine on_about

    !--------------------------------------------------------------------------
    ! MyFrame::OnBrowser -- wxArtBrowserDialog dlg(this); dlg.ShowModal();
    !--------------------------------------------------------------------------
    subroutine on_browser(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer(c_int) :: result
        logical :: destroyed

        if (.not. c_associated(evt)) return

        call build_dialog(g_frame)
        if (.not. g_dialog%is_valid()) return

        call connect_dialog_events()
        call initialize_browser()

        result = wx_dialog_show_modal(g_dialog)
        destroyed = wx_window_destroy(g_dialog)
        call clear_dialog_handles()
    end subroutine on_browser

    !--------------------------------------------------------------------------
    ! MyFrame::OnPlugProvider -- wxArtProvider::Push/Pop
    !
    ! GAP: kwxFFI has no way to supply a wxArtProvider subclass without the C
    ! ABI of kwxArtProv_Create()'s callback, so the custom MyArtProvider cannot
    ! be pushed.  The check item still toggles (wx owns its state); the art
    ! provider stack is left untouched.
    !--------------------------------------------------------------------------
    subroutine on_plug_provider(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: checked

        if (.not. c_associated(evt)) return

        checked = wx_command_event_is_checked(evt)
        g_provider_checked = checked
    end subroutine on_plug_provider

    !--------------------------------------------------------------------------
    ! wxArtBrowserDialog::OnSelectItem
    !--------------------------------------------------------------------------
    subroutine on_select_item(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxListEvent_t) :: list_event
        integer(c_int) :: index, width, height

        if (.not. c_associated(evt)) return

        list_event = wxlistevent_from_ptr(evt, .false.)
        index = wx_list_event_get_index(list_event)
        if (index < 0 .or. index >= ART_COUNT) return

        g_current_art_id = g_art_ids(index + 1)
        call selected_bitmap_size(width, height)
        call set_art_bitmap(g_current_art_id, g_client, width, height)
    end subroutine on_select_item

    !--------------------------------------------------------------------------
    ! wxArtBrowserDialog::OnChangeSize
    !--------------------------------------------------------------------------
    subroutine on_change_size(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer(c_int) :: width, height

        if (.not. c_associated(evt)) return

        call selected_bitmap_size(width, height)
        call set_art_bitmap(g_current_art_id, g_client, width, height)
    end subroutine on_change_size

    !--------------------------------------------------------------------------
    ! wxArtBrowserDialog::OnChooseClient
    !--------------------------------------------------------------------------
    subroutine on_choose_client(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: selection

        if (.not. c_associated(evt)) return

        selection = wx_command_event_get_selection(evt)
        if (selection < 0 .or. selection >= CLIENT_COUNT) return

        call set_art_client(g_client_ids(selection + 1))
    end subroutine on_choose_client

    !--------------------------------------------------------------------------
    ! Event table of wxArtBrowserDialog, in source order.
    !--------------------------------------------------------------------------
    subroutine connect_dialog_events()
        call wx_connect(g_list, wxEVT_LIST_ITEM_SELECTED(), on_select_item)
        call wx_connect(g_sizes, wxEVT_CHOICE(), on_change_size, id=g_size_choice_id)
        call wx_connect(g_choice, wxEVT_CHOICE(), on_choose_client)
    end subroutine connect_dialog_events

    !--------------------------------------------------------------------------
    ! wxArtBrowserDialog::GetSelectedBitmapSize()
    !--------------------------------------------------------------------------
    subroutine selected_bitmap_size(width, height)
        integer(c_int), intent(out) :: width, height
        integer(c_int) :: selection

        selection = wx_choice_get_selection(g_sizes)
        if (selection < 0 .or. selection >= SIZE_COUNT) selection = 0

        width = g_size_table(selection + 1)
        height = width
    end subroutine selected_bitmap_size

end module artprov_handlers


program artprov
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_ANY, wxID_EXIT, wxID_ABOUT, wxID_HIGHEST, &
        wxDEFAULT_FRAME_STYLE, wxEVT_MENU
    use wx_app, only: wx_initialize, wx_main_loop, wx_shutdown, &
        wx_set_top_window, wx_set_app_name
    use wx_frame, only: wx_frame_create, wx_frame_set_menu_bar
    use wx_window, only: wx_window_show
    use wx_menu, only: wx_menu_create, wx_menu_append, wx_menu_append_separator, &
        wx_menu_append_check_item
    use wx_menu_bar, only: wx_menu_bar_create, wx_menu_bar_append
    use wx_events, only: wx_connect
    use wx_free_functions, only: wx_new_id
    use artprov_globals
    use artprov_core, only: init_art_ids, load_assets, release_assets, set_sample_icon
    use artprov_handlers, only: on_quit, on_logs, on_about, on_browser, on_plug_provider
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxMenu_t) :: file_menu, help_menu
    type(wxMenuBar_t) :: menu_bar
    integer :: exit_code, position
    logical :: shown

    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    call wx_set_app_name("artprov")

    no_parent%ptr = c_null_ptr
    g_frame = wx_frame_create(no_parent, wxID_ANY(), "wxArtProvider sample", &
        50_c_int, 50_c_int, 450_c_int, 340_c_int, wxDEFAULT_FRAME_STYLE())
    if (.not. g_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    call init_art_ids()
    call load_assets()
    if (.not. g_bundle_sample%is_valid() .or. .not. g_bundle_null%is_valid()) then
        print *, "Failed to load sample.svg / null.svg; run from the samples/artprov folder"
        stop 1
    end if
    call set_sample_icon()

    ! enum { ID_Quit = wxID_EXIT, ID_Logs = wxID_HIGHEST, ID_Browser, ID_PlugProvider }
    g_id_logs = wxID_HIGHEST()
    g_id_browser = wxID_HIGHEST() + 1_c_int
    g_id_plug = wxID_HIGHEST() + 2_c_int
    g_size_choice_id = wx_new_id()

    ! ------------------------------------------------------------------
    ! Menu bar
    ! ------------------------------------------------------------------
    file_menu = wx_menu_create("", 0_c_long)
    help_menu = wx_menu_create("", 0_c_long)

    call wx_menu_append_check_item(file_menu, g_id_plug, &
        "&Plug-in art provider" // achar(9) // "Ctrl-P", "Enable custom art provider")
    call wx_menu_append_separator(file_menu)
    call wx_menu_append(file_menu, g_id_logs, &
        "&Logging test" // achar(9) // "Ctrl-L", "Show some logging output", .false.)
    call wx_menu_append(file_menu, g_id_browser, &
        "&Resources browser" // achar(9) // "Ctrl-R", "Browse all available icons", .false.)
    call wx_menu_append_separator(file_menu)
    call wx_menu_append(file_menu, wxID_EXIT(), &
        "E&xit" // achar(9) // "Alt-X", "Quit this program", .false.)

    call wx_menu_append(help_menu, wxID_ABOUT(), &
        "&About" // achar(9) // "F1", "Show about dialog", .false.)

    menu_bar = wx_menu_bar_create(0_c_int)
    position = wx_menu_bar_append(menu_bar, file_menu, "&File")
    position = wx_menu_bar_append(menu_bar, help_menu, "&Help")
    if (position < 0) print *, "Failed to build the menu bar"
    call wx_frame_set_menu_bar(g_frame, menu_bar)

    ! ------------------------------------------------------------------
    ! MyFrame event table
    ! ------------------------------------------------------------------
    call wx_connect(g_frame, wxEVT_MENU(), on_quit, id=wxID_EXIT())
    call wx_connect(g_frame, wxEVT_MENU(), on_logs, id=g_id_logs)
    call wx_connect(g_frame, wxEVT_MENU(), on_about, id=wxID_ABOUT())
    call wx_connect(g_frame, wxEVT_MENU(), on_browser, id=g_id_browser)
    call wx_connect(g_frame, wxEVT_MENU(), on_plug_provider, id=g_id_plug)

    call wx_set_top_window(g_frame)
    shown = wx_window_show(g_frame)

    exit_code = wx_main_loop()

    call release_assets()
    call wx_shutdown()

    if (exit_code /= 0) print *, "Exit code:", exit_code
end program artprov
