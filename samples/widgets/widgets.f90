! widgets.f90 - wxWidgets "widgets" sample, Fortran port (kwxFortran)
!
! Port of wxWidgets samples/widgets (widgets.cpp + one .cpp per page).
!
! The frame owns a wxTreebook with one category node per WidgetsCategories
! entry (Native, Generic, Pickers, Comboboxes, With items, Editable, Books,
! All controls) plus the widget demonstration pages, and a "Log window"
! static box holding a listbox and the Clear log / Exit buttons.
!
! Pages ported (one instance each, placed in their primary category):
!   ActivityIndicator, Button, CheckBox, Choice, Gauge, Hyperlink, Listbox,
!   Slider, Spin, ToggleButton.
! The remaining pages of the C++ sample (pickers, comboboxes, books, static,
! text, dir/file controls, header, ...) are documented as gaps in the port
! report; their category nodes exist but have no children.
!
! Run the executable with the current directory set to this folder so that the
! relative "sample.svg" path resolves:
!     cd samples\widgets && ..\..\bin\Debug\widgets.exe

module widgets_globals
    use, intrinsic :: iso_c_binding
    use kwx_types
    implicit none

    ! ------------------------------------------------------------------
    ! Frame / book / log window (WidgetsFrame members)
    ! ------------------------------------------------------------------
    type(wxFrame_t), save :: g_frame
    type(wxPanel_t), save :: g_panel
    type(wxTreebook_t), save :: g_book
    type(wxListBox_t), save :: g_log
    type(wxStaticBox_t), save :: g_log_box
    type(wxMenu_t), save :: g_page_menu
    type(wxMenuBar_t), save :: g_menu_bar
    type(wxImageList_t), save :: g_images

    ! wxLog target that redirects framework and application messages to the
    ! log listbox.
    type(kwxlog_t), save :: g_log_target
    type(wxlog_t), save :: g_log_old

    ! ------------------------------------------------------------------
    ! WidgetAttributes (WidgetsPage::GetAttrs(), shared by every page)
    ! ------------------------------------------------------------------
    character(len=:), allocatable, save :: g_attr_tooltip
    logical, save :: g_attr_enabled = .true.
    logical, save :: g_attr_show = .true.
    logical, save :: g_has_fg = .false.
    logical, save :: g_has_bg = .false.
    logical, save :: g_has_page_bg = .false.
    logical, save :: g_has_font = .false.
    type(wxColour_t), save :: g_col_fg
    type(wxColour_t), save :: g_col_bg
    type(wxColour_t), save :: g_col_page_bg
    type(wxFont_t), save :: g_attr_font
    type(wxCursor_t), save :: g_attr_cursor
    integer, save :: g_attr_dir = 0
    integer, save :: g_attr_default_flags = 0

    ! Current page widget (WidgetsPage::GetWidget()); the Widget menu applies
    ! attributes to it.
    type(wxWindow_t), save :: g_current_widget
    type(wxScrolledWindow_t), save :: g_current_page

    ! ------------------------------------------------------------------
    ! Widget id blocks.  Every C++ page enum starts at wxID_HIGHEST, so all
    ! pages share the same numeric range; events are routed per page window.
    ! ID_PAGE_BASE is set from wxID_HIGHEST() at start-up.
    ! ------------------------------------------------------------------
    integer, save :: ID_PAGE_BASE = 0

    ! Tree index -> page kind (0 = category node without a page).
    integer, parameter :: MAX_TREE_PAGES = 64
    integer, save :: g_tree_last = -1
    integer, save :: g_tree_kind(0:MAX_TREE_PAGES - 1) = 0

    ! WidgetsFrame ids (widgets.cpp enum)
    integer, parameter :: ID_CLEAR_LOG = 100
    integer, parameter :: ID_QUIT = 101
    integer, parameter :: ID_BOOK = 102
    integer, parameter :: ID_SET_TOOLTIP = 103
    integer, parameter :: ID_SET_FG = 104
    integer, parameter :: ID_SET_BG = 105
    integer, parameter :: ID_SET_PAGE_BG = 106
    integer, parameter :: ID_SET_FONT = 107
    integer, parameter :: ID_ENABLE = 108
    integer, parameter :: ID_SHOW = 109
    integer, parameter :: ID_BORDER_NONE = 110
    integer, parameter :: ID_BORDER_STATIC = 111
    integer, parameter :: ID_BORDER_SIMPLE = 112
    integer, parameter :: ID_BORDER_RAISED = 113
    integer, parameter :: ID_BORDER_SUNKEN = 114
    integer, parameter :: ID_BORDER_DOUBLE = 115
    integer, parameter :: ID_BORDER_DEFAULT = 116
    integer, parameter :: ID_VARIANT_NORMAL = 117
    integer, parameter :: ID_VARIANT_SMALL = 118
    integer, parameter :: ID_VARIANT_MINI = 119
    integer, parameter :: ID_VARIANT_LARGE = 120
    integer, parameter :: ID_LAYOUT_DIRECTION = 121
    integer, parameter :: ID_GLOBAL_BUSY = 122
    integer, parameter :: ID_BUSY = 123
    integer, parameter :: ID_GOTO_PAGE = 124
    integer, parameter :: ID_GOTO_LAST = 224
    integer, parameter :: ID_TEXT_BEGIN = 225
    integer, parameter :: ID_TEXT_DISABLE_AC = 225
    integer, parameter :: ID_TEXT_AC_FIXED = 226
    integer, parameter :: ID_TEXT_AC_FILES = 227
    integer, parameter :: ID_TEXT_AC_DIRS = 228
    integer, parameter :: ID_TEXT_AC_CUSTOM = 229
    integer, parameter :: ID_TEXT_AC_KEYLEN = 230
    integer, parameter :: ID_TEXT_SET_HINT = 231
    integer, parameter :: ID_TEXT_END = 232
    integer, parameter :: ID_THEME_LIGHT = 233
    integer, parameter :: ID_THEME_DARK = 234
    integer, parameter :: ID_THEME_SYSTEM = 235

    ! ------------------------------------------------------------------
    ! ActivityIndicator page (activityindicator.cpp)
    ! ------------------------------------------------------------------
    integer, parameter :: AI_START = 0, AI_STOP = 1, AI_ISRUNNING = 2
    type(wxScrolledWindow_t), save :: g_ai_page
    type(wxActivityIndicator_t), save :: g_ai_indicator
    type(wxButton_t), save :: g_ai_start, g_ai_stop
    type(wxStaticText_t), save :: g_ai_label

    ! ------------------------------------------------------------------
    ! Button page (button.cpp)
    ! ------------------------------------------------------------------
    integer, parameter :: BTN_RESET = 0, BTN_CHANGE_LABEL = 1, &
        BTN_CHANGE_NOTE = 2, BTN_CHANGE_MARGINS = 3, BTN_BUTTON = 4
    integer, parameter :: BTN_BITMAP_ONLY = 20, BTN_TEXT_AND_BITMAP = 21, &
        BTN_FIT_EXACTLY = 22, BTN_REQUIRE_AUTH = 23, BTN_CMD_LINK = 24, &
        BTN_MARKUP = 25, BTN_DEFAULT = 26, BTN_USE_BITMAP = 27, &
        BTN_USE_PRESSED = 28, BTN_USE_FOCUSED = 29, BTN_USE_CURRENT = 30, &
        BTN_USE_DISABLED = 31, BTN_IMAGEPOS = 32, BTN_MARGINS_OK = 33, &
        BTN_MARGIN_H = 34, BTN_MARGIN_V = 35, BTN_HALIGN = 36, &
        BTN_VALIGN = 37, BTN_LABELTEXT = 38, BTN_NOTETEXT = 39
    type(wxScrolledWindow_t), save :: g_btn_page
    type(wxButton_t), save :: g_btn_button
    type(wxTextCtrl_t), save :: g_btn_label_text, g_btn_note_text
    type(wxCheckBox_t), save :: g_btn_chk_fit, g_btn_chk_default, &
        g_btn_chk_bitmap, g_btn_chk_text_bitmap

    ! ------------------------------------------------------------------
    ! CheckBox page (checkbox.cpp)
    ! ------------------------------------------------------------------
    integer, parameter :: CB_RESET = 0, CB_CHANGE_LABEL = 1, CB_CHECK = 2, &
        CB_UNCHECK = 3, CB_PARTCHECK = 4, CB_CHKRIGHT = 5, CB_CHECKBOX = 6
    integer, parameter :: CB_KIND = 20, CB_LABELTEXT = 21
    type(wxScrolledWindow_t), save :: g_cb_page
    type(wxCheckBox_t), save :: g_cb_checkbox, g_cb_chk_right
    type(wxRadioBox_t), save :: g_cb_kind
    type(wxTextCtrl_t), save :: g_cb_label_text

    ! ------------------------------------------------------------------
    ! Choice page (choice.cpp)
    ! ------------------------------------------------------------------
    integer, parameter :: CH_RESET = 0, CH_ADD = 1, CH_ADDTEXT = 2, &
        CH_ADDSEVERAL = 3, CH_ADDMANY = 4, CH_CLEAR = 5, CH_CHANGE = 6, &
        CH_CHANGETEXT = 7, CH_DELETE = 8, CH_DELETETEXT = 9, &
        CH_DELETESEL = 10, CH_CHOICE = 11, CH_CONTAINERTESTS = 12
    integer, parameter :: CH_SORT = 20
    type(wxScrolledWindow_t), save :: g_ch_page
    type(wxChoice_t), save :: g_ch_choice
    type(wxTextCtrl_t), save :: g_ch_add_text, g_ch_change_text, g_ch_delete_text
    type(wxCheckBox_t), save :: g_ch_sort

    ! ------------------------------------------------------------------
    ! Gauge page (gauge.cpp)
    ! ------------------------------------------------------------------
    integer, parameter :: GA_RESET = 0, GA_PROGRESS = 1, GA_INDET = 2, &
        GA_CLEAR = 3, GA_SETVALUE = 4, GA_SETRANGE = 5, GA_CURVALUE = 6, &
        GA_VALUETEXT = 7, GA_RANGETEXT = 8, GA_TIMER = 9, GA_INDET_TIMER = 10, &
        GA_GAUGE = 11
    integer, parameter :: GA_VERT = 20, GA_SMOOTH = 21, GA_PROGRESSCHK = 22
    type(wxScrolledWindow_t), save :: g_ga_page
    type(wxGauge_t), save :: g_ga_gauge
    type(wxTextCtrl_t), save :: g_ga_cur, g_ga_value_text, g_ga_range_text
    type(wxButton_t), save :: g_ga_progress_btn, g_ga_indet_btn
    type(wxTimer_t), save :: g_ga_timer, g_ga_indet_timer
    integer, save :: g_ga_range = 100
    logical, save :: g_ga_running = .false.
    logical, save :: g_ga_indet_running = .false.

    ! ------------------------------------------------------------------
    ! Hyperlink page (hyperlnk.cpp)
    ! ------------------------------------------------------------------
    integer, parameter :: HL_RESET = 0, HL_SETLABEL = 1, HL_SETURL = 2, &
        HL_CTRL = 3
    integer, parameter :: HL_LABELTEXT = 20, HL_URLTEXT = 21, HL_ALIGN = 22, &
        HL_GENERIC = 23, HL_CTRLLONG = 24
    type(wxScrolledWindow_t), save :: g_hl_page
    type(wxHyperlinkCtrl_t), save :: g_hl_ctrl, g_hl_ctrl_long
    type(wxTextCtrl_t), save :: g_hl_label_text, g_hl_url_text
    type(wxRadioBox_t), save :: g_hl_align

    ! ------------------------------------------------------------------
    ! Listbox page (listbox.cpp)
    ! ------------------------------------------------------------------
    integer, parameter :: LB_RESET = 0, LB_ADD = 1, LB_ADDTEXT = 2, &
        LB_ADDSEVERAL = 3, LB_ADDMANY = 4, LB_CLEAR = 5, LB_CHANGE = 6, &
        LB_CHANGETEXT = 7, LB_DELETE = 8, LB_DELETETEXT = 9, &
        LB_DELETESEL = 10, LB_LISTBOX = 11, LB_ENSUREVISIBLE = 12, &
        LB_ENSUREVISIBLETEXT = 13, LB_CONTAINERTESTS = 14, &
        LB_GETTOPITEM = 15, LB_GETCOUNTPERPAGE = 16, LB_MOVEUP = 17, &
        LB_MOVEDOWN = 18
    integer, parameter :: LB_VSCROLL = 20, LB_HSCROLL = 21, LB_SORT = 22, &
        LB_OWNERDRAW = 23, LB_SELMODE = 24, LB_LISTTYPE = 25
    type(wxScrolledWindow_t), save :: g_lb_page
    type(wxListBox_t), save :: g_lb_listbox
    type(wxCheckBox_t), save :: g_lb_vscroll, g_lb_hscroll, g_lb_sort, &
        g_lb_ownerdraw
    type(wxRadioBox_t), save :: g_lb_selmode, g_lb_listtype
    type(wxTextCtrl_t), save :: g_lb_add_text, g_lb_change_text, &
        g_lb_delete_text, g_lb_ensure_text
    integer, save :: g_lb_item_counter = 0

    ! ------------------------------------------------------------------
    ! Slider page (slider.cpp)
    ! ------------------------------------------------------------------
    integer, parameter :: SL_RESET = 0, SL_CLEAR = 1, SL_SETVALUE = 2, &
        SL_SETMINMAX = 3, SL_SETRANGE = 4, SL_SETLINESIZE = 5, &
        SL_SETPAGESIZE = 6, SL_SETTICKFREQ = 7, SL_SETTHUMBLEN = 8, &
        SL_CURVALUE = 9, SL_VALUETEXT = 10, SL_MINTEXT = 11, SL_MAXTEXT = 12, &
        SL_RANGEMINTEXT = 13, SL_RANGEMAXTEXT = 14, SL_LINESIZETEXT = 15, &
        SL_PAGESIZETEXT = 16, SL_TICKFREQTEXT = 17, SL_THUMBLENTEXT = 18, &
        SL_RADIOSIDES = 19, SL_BOTHSIDES = 20, SL_SELECTRANGE = 21, &
        SL_SLIDER = 22
    integer, parameter :: SL_INVERSE = 30, SL_TICKS = 31, SL_VALUELABEL = 32, &
        SL_MINMAXLABELS = 33
    type(wxScrolledWindow_t), save :: g_sl_page
    type(wxSlider_t), save :: g_sl_slider
    type(wxTextCtrl_t), save :: g_sl_cur, g_sl_value_text, g_sl_min_text, &
        g_sl_max_text, g_sl_rangemin_text, g_sl_rangemax_text, &
        g_sl_linesize_text, g_sl_pagesize_text, g_sl_tickfreq_text, &
        g_sl_thumblen_text
    type(wxRadioBox_t), save :: g_sl_radio_sides
    integer, save :: g_sl_min = 0, g_sl_max = 100
    integer, save :: g_sl_rangemin = 20, g_sl_rangemax = 80

    ! ------------------------------------------------------------------
    ! Spin page (spinbtn.cpp)
    ! ------------------------------------------------------------------
    integer, parameter :: SP_RESET = 0, SP_CLEAR = 1, SP_SETVALUE = 2, &
        SP_SETMINMAX = 3, SP_SETBASE = 4, SP_SETINCREMENT = 5, &
        SP_CURVALUE = 6, SP_VALUETEXT = 7, SP_MINTEXT = 8, SP_MAXTEXT = 9, &
        SP_BASETEXT = 10, SP_INCREMENTTEXT = 11, SP_SPINBTN = 12, &
        SP_SPINCTRL = 13, SP_SPINCTRLDOUBLE = 14
    integer, parameter :: SP_VERT = 20, SP_ARROWKEYS = 21, SP_WRAP = 22, &
        SP_PROCESSENTER = 23, SP_ALIGN = 24
    type(wxScrolledWindow_t), save :: g_sp_page
    type(wxSpinButton_t), save :: g_sp_spinbtn
    type(wxSpinCtrl_t), save :: g_sp_spinctrl
    type(wxSpinCtrlDouble_t), save :: g_sp_spinctrldbl
    type(wxTextCtrl_t), save :: g_sp_cur, g_sp_value_text, g_sp_min_text, &
        g_sp_max_text, g_sp_base_text, g_sp_increment_text
    integer, save :: g_sp_min = 0, g_sp_max = 10

    ! ------------------------------------------------------------------
    ! ToggleButton page (toggle.cpp)
    ! ------------------------------------------------------------------
    integer, parameter :: TG_RESET = 0, TG_CHANGELABEL = 1, TG_PICKER = 2
    integer, parameter :: TG_LABELTEXT = 20, TG_BITMAP_ONLY = 21, &
        TG_TEXT_AND_BITMAP = 22, TG_MARKUP = 23, TG_FIT = 24, TG_DISABLE = 25, &
        TG_USE_BITMAP = 26, TG_USE_PRESSED = 27, TG_USE_FOCUSED = 28, &
        TG_USE_CURRENT = 29, TG_USE_DISABLED = 30, TG_IMAGEPOS = 31, &
        TG_HALIGN = 32, TG_VALIGN = 33
    type(wxScrolledWindow_t), save :: g_tg_page
    type(wxToggleButton_t), save :: g_tg_toggle
    type(wxTextCtrl_t), save :: g_tg_label_text

end module widgets_globals


module widgets_util
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_ANY, wxLayout_Default
    use wx_sizer, only: wx_sizer_add_window, wx_sizer_add_sizer, &
        wx_sizer_add_spacer, wx_sizer_add_stretch_spacer
    use wx_window, only: wx_window_show, wx_window_hide, wx_window_enable, &
        wx_window_set_tool_tip, wx_window_set_foreground_colour, &
        wx_window_set_background_colour, wx_window_set_font, &
        wx_window_set_cursor, wx_window_set_layout_direction
    use wx_static_box, only: wx_static_box_create
    use wx_static_box_sizer, only: wx_static_box_sizer_create
    use widgets_globals
    implicit none

contains

    pure function itoa(value) result(s)
        integer, intent(in) :: value
        character(len=:), allocatable :: s
        character(len=32) :: buf
        write (buf, '(I0)') value
        s = trim(buf)
    end function itoa

    subroutine add_win(sz, win, prop, flag, border)
        class(wxSizer_t), intent(in) :: sz
        class(wxWindow_t), intent(in) :: win
        integer, intent(in), optional :: prop, flag, border
        integer :: p, f, b

        p = 0; f = 0; b = 0
        if (present(prop)) p = prop
        if (present(flag)) f = flag
        if (present(border)) b = border
        call wx_sizer_add_window(sz, win, int(p, c_int), int(f, c_int), &
            int(b, c_int), c_null_ptr)
    end subroutine add_win

    subroutine add_sz(sz, child, prop, flag, border)
        class(wxSizer_t), intent(in) :: sz
        class(wxSizer_t), intent(in) :: child
        integer, intent(in), optional :: prop, flag, border
        integer :: p, f, b

        p = 0; f = 0; b = 0
        if (present(prop)) p = prop
        if (present(flag)) f = flag
        if (present(border)) b = border
        call wx_sizer_add_sizer(sz, child, int(p, c_int), int(f, c_int), &
            int(b, c_int), c_null_ptr)
    end subroutine add_sz

    subroutine add_space(sz, size)
        class(wxSizer_t), intent(in) :: sz
        integer, intent(in) :: size
        type(wxSizerItem_t) :: item

        item = wx_sizer_add_spacer(sz, int(size, c_int))
    end subroutine add_space

    subroutine add_stretch(sz, size)
        class(wxSizer_t), intent(in) :: sz
        integer, intent(in) :: size

        call wx_sizer_add_stretch_spacer(sz, int(size, c_int))
    end subroutine add_stretch

    ! Create a wxStaticBox and its wxStaticBoxSizer (the C++ sample uses
    ! wxStaticBoxSizer(wxVERTICAL, parent, label)).
    subroutine make_static_box(parent, label, box, sbs, orient)
        class(wxWindow_t), intent(in) :: parent
        character(len=*), intent(in) :: label
        type(wxStaticBox_t), intent(out) :: box
        type(wxStaticBoxSizer_t), intent(out) :: sbs
        integer, intent(in) :: orient

        box = wx_static_box_create(parent, int(wxID_ANY(), c_int), label, &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        sbs = wx_static_box_sizer_create(box, int(orient, c_int))
    end subroutine make_static_box

    ! WidgetsPage::SetUpWidget() for a single widget.
    subroutine apply_attrs(win)
        class(wxWindow_t), intent(in) :: win
        logical :: l

        if (.not. win%is_valid()) return

        if (allocated(g_attr_tooltip)) then
            if (len_trim(g_attr_tooltip) > 0) &
                call wx_window_set_tool_tip(win, trim(g_attr_tooltip))
        end if

        l = wx_window_enable(win, g_attr_enabled)
        if (g_attr_show) then
            l = wx_window_show(win)
        else
            l = wx_window_hide(win)
        end if

        if (g_has_fg) l = (wx_window_set_foreground_colour(win, g_col_fg) /= 0)
        if (g_has_bg) l = wx_window_set_background_colour(win, g_col_bg)
        if (g_has_font) l = wx_window_set_font(win, g_attr_font)
        if (g_attr_dir /= int(wxLayout_Default(), c_int)) &
            call wx_window_set_layout_direction(win, int(g_attr_dir, c_int))
        l = (wx_window_set_cursor(win, g_attr_cursor) /= 0)
    end subroutine apply_attrs

end module widgets_util


module widgets_handlers
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_EXIT, wxID_OK, wxOK, wxCHK_UNDETERMINED, &
        wxApp_Appearance_System, wxApp_Appearance_Light, wxApp_Appearance_Dark, &
        wxApp_AppearanceResult_Failure, wxLB_SINGLE, wxLB_EXTENDED, &
        wxLB_MULTIPLE, wxLB_ALWAYS_SB, wxLB_HSCROLL, wxLB_SORT, &
        wxLB_OWNERDRAW, wxLayout_Default, wxLayout_LeftToRight, &
        wxLayout_RightToLeft, wxCURSOR_WAIT
    use wx_events, only: wx_event_get_id, wx_event_skip, &
        wx_command_event_get_selection, wx_command_event_is_checked, &
        wx_command_event_get_string
    use wx_window, only: wx_window_close, wx_window_destroy, &
        wx_window_set_background_colour, wx_window_enable, wx_window_show, &
        wx_window_hide, wx_window_set_tool_tip, wx_window_set_cursor, &
        wx_window_set_layout_direction, wx_window_get_layout_direction, &
        wx_window_get_font, wx_window_layout, wx_window_get_sizer
    use wx_control, only: wx_control_set_label
    use wx_button, only: wx_button_set_default
    use wx_treebook, only: wx_treebook_get_selection, wx_treebook_set_selection, &
        wx_treebook_get_page
    use wx_list_box, only: wx_list_box_append, wx_list_box_clear, &
        wx_list_box_delete, wx_list_box_get_count, wx_list_box_get_selection, &
        wx_list_box_set_selection, wx_list_box_set_string, &
        wx_list_box_get_top_item, wx_list_box_get_count_per_page, &
        wx_list_box_create, wx_list_box_get_string, wx_list_box_insert, &
        wx_list_box_is_sorted, wx_list_box_set_first_item
    use wx_choice, only: wx_choice_append, wx_choice_clear, wx_choice_delete, &
        wx_choice_get_count, wx_choice_get_selection, wx_choice_set_string, &
        wx_choice_set_selection, wx_choice_get_string, wx_choice_is_sorted
    use wx_radio_box, only: wx_radio_box_get_selection, wx_radio_box_set_selection
    use wx_cursor, only: wx_cursor_create_from_stock, wx_cursor_delete
    use wx_font, only: wx_font_create_default, wx_font_is_ok, wx_font_delete
    use wx_sizer, only: wx_sizer_replace_window
    use wx_app_methods, only: wx_app_get_app, wx_app_set_appearance
    use wx_notify_event, only: wx_notify_event_veto
    use wx_book_ctrl_event, only: wx_book_ctrl_event_get_selection
    use wx_check_box, only: wx_check_box_get_value, wx_check_box_set_value, &
        wx_check_box_set3state_value
    use wx_gauge, only: wx_gauge_set_value, wx_gauge_get_value, &
        wx_gauge_get_range, wx_gauge_set_range, wx_gauge_pulse
    use wx_activity_indicator, only: wx_activity_indicator_start, &
        wx_activity_indicator_stop
    use wx_hyperlink_ctrl, only: wx_hyperlink_ctrl_set_url
    use wx_slider, only: wx_slider_get_value, wx_slider_set_value, &
        wx_slider_set_range, wx_slider_set_line_size, wx_slider_set_page_size, &
        wx_slider_set_tick_freq, wx_slider_set_thumb_length, wx_slider_set_selection
    use wx_spin_button, only: wx_spin_button_get_value, wx_spin_button_set_value, &
        wx_spin_button_set_range, wx_spin_button_set_increment
    use wx_spin_ctrl, only: wx_spin_ctrl_get_value, wx_spin_ctrl_set_value, &
        wx_spin_ctrl_set_range, wx_spin_ctrl_set_base
    use wx_spin_ctrl_double, only: wx_spin_ctrl_double_get_value, &
        wx_spin_ctrl_double_set_value, wx_spin_ctrl_double_set_range
    use wx_toggle_button, only: wx_toggle_button_get_value, &
        wx_toggle_button_set_value, wx_toggle_button_set_label
    use wx_text_ctrl, only: wx_text_ctrl_get_value, wx_text_ctrl_set_value, &
        wx_text_ctrl_auto_complete, wx_text_ctrl_auto_complete_file_names, &
        wx_text_ctrl_auto_complete_directories
    use wx_timer, only: wx_timer_start, wx_timer_stop
    use wx_menu, only: wx_menu_check
    use wx_colour, only: wx_colour_is_ok, wx_colour_create_rgb, wx_colour_delete
    use wx_free_functions, only: kwx_message_box, wx_get_colour_from_user, &
        log_message, wx_get_font_from_user, wx_begin_busy_cursor, &
        wx_end_busy_cursor, null_cursor_2
    use wx_string, only: from_wxstring
    use kwx_log, only: kwx_log_set_on_do_log_text_at_level
    use wx_text_entry_dialog, only: wx_text_entry_dialog_create, &
        wx_text_entry_dialog_get_value
    use wx_dialog, only: wx_dialog_show_modal
    use widgets_globals
    use widgets_util, only: apply_attrs
    implicit none

    character(len=*), parameter :: LOG_STYLE = &
        " (widget recreation on style change is not supported by this port)"

contains

    pure function atoi(s, default_value) result(v)
        character(len=*), intent(in) :: s
        integer, intent(in) :: default_value
        integer :: v
        integer :: ios

        read (s, *, iostat=ios) v
        if (ios /= 0) v = default_value
    end function atoi

    subroutine show_info(text)
        character(len=*), intent(in) :: text
        integer(c_int) :: rc

        rc = kwx_message_box(text, "Widgets sample", int(wxOK(), c_int), &
            g_frame, -1_c_int, -1_c_int)
    end subroutine show_info

    ! ------------------------------------------------------------------
    ! WidgetsFrame menu dispatcher (all menu commands and the two log
    ! window buttons).
    ! ------------------------------------------------------------------
    subroutine on_menu(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id, sel, iw
        logical :: l
        integer(c_int) :: appearance
        type(wxtextentrydialog_t) :: dlg
        type(wxcolour_t) :: col
        type(wxfont_t) :: font_new
        type(wxTextCtrl_t) :: entry
        character(len=16) :: buf

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)

        if (id == ID_CLEAR_LOG) then
            call wx_list_box_clear(g_log)

        else if (id == ID_QUIT .or. id == wxID_EXIT()) then
            l = wx_window_close(g_frame, .true.)

        else if (id == ID_SET_TOOLTIP) then
            dlg = wx_text_entry_dialog_create(g_frame, &
                "Tooltip text (may use \n, leave empty to remove): ", &
                "Widgets sample", g_attr_tooltip, 0_c_long, &
                -1_c_int, -1_c_int, -1_c_int, -1_c_int)
            if (dlg%is_valid()) then
                if (wx_dialog_show_modal(dlg) == wxID_OK()) then
                    deallocate (g_attr_tooltip)
                    g_attr_tooltip = wx_text_entry_dialog_get_value(dlg)
                    call replace_all(g_attr_tooltip, "\n", achar(10))
                end if
                l = wx_window_destroy(dlg)
            end if
            call apply_attrs(g_current_widget)

        else if (id == ID_SET_FG .or. id == ID_SET_BG .or. id == ID_SET_PAGE_BG) then
            col = wx_colour_create_rgb(0_1, 0_1, 0_1, -1_1)
            if (id == ID_SET_FG) then
                call wx_get_colour_from_user(g_frame, g_col_fg, col)
                if (wx_colour_is_ok(col)) then
                    call wx_colour_delete(g_col_fg)
                    g_col_fg = col
                    g_has_fg = .true.
                else
                    call wx_colour_delete(col)
                end if
            else if (id == ID_SET_BG) then
                call wx_get_colour_from_user(g_frame, g_col_bg, col)
                if (wx_colour_is_ok(col)) then
                    call wx_colour_delete(g_col_bg)
                    g_col_bg = col
                    g_has_bg = .true.
                else
                    call wx_colour_delete(col)
                end if
            else
                call wx_get_colour_from_user(g_frame, g_col_page_bg, col)
                if (wx_colour_is_ok(col)) then
                    call wx_colour_delete(g_col_page_bg)
                    g_col_page_bg = col
                    g_has_page_bg = .true.
                    if (g_current_page%is_valid()) l = &
                        wx_window_set_background_colour(g_current_page, g_col_page_bg)
                else
                    call wx_colour_delete(col)
                end if
            end if
            call apply_attrs(g_current_widget)

        else if (id == ID_SET_FONT) then
            ! Seed the dialog with the current page font (m_font = page->GetFont()
            ! when no font has been chosen yet).
            if (.not. g_has_font .and. g_current_page%is_valid()) then
                g_attr_font = wx_font_create_default()
                call wx_window_get_font(g_current_page, g_attr_font)
                g_has_font = wx_font_is_ok(g_attr_font)
                if (.not. g_has_font) then
                    call wx_font_delete(g_attr_font)
                    g_attr_font = wx_font_create_default()
                end if
            end if
            font_new = wx_font_create_default()
            call wx_get_font_from_user(g_frame, g_attr_font, font_new)
            if (wx_font_is_ok(font_new)) then
                if (g_attr_font%owned) call wx_font_delete(g_attr_font)
                g_attr_font = font_new
                g_has_font = .true.
                call apply_attrs(g_current_widget)
                iw = wx_window_layout(g_current_page)
            else
                call wx_font_delete(font_new)
            end if

        else if (id == ID_ENABLE) then
            g_attr_enabled = wx_command_event_is_checked(evt)
            call apply_attrs(g_current_widget)

        else if (id == ID_SHOW) then
            g_attr_show = wx_command_event_is_checked(evt)
            call apply_attrs(g_current_widget)

        else if (id >= ID_BORDER_NONE .and. id <= ID_BORDER_DEFAULT) then
            write (buf, '(A,I0)') "Border id ", id
            call log_message(trim(buf) // LOG_STYLE)

        else if (id >= ID_VARIANT_NORMAL .and. id <= ID_VARIANT_LARGE) then
            write (buf, '(A,I0)') "Variant id ", id
            call log_message(trim(buf) // LOG_STYLE)

        else if (id == ID_LAYOUT_DIRECTION) then
            if (g_attr_dir == int(wxLayout_Default(), c_int)) &
                g_attr_dir = wx_window_get_layout_direction(g_frame)
            if (g_attr_dir == int(wxLayout_LeftToRight(), c_int)) then
                g_attr_dir = int(wxLayout_RightToLeft(), c_int)
            else
                g_attr_dir = int(wxLayout_LeftToRight(), c_int)
            end if
            call apply_attrs(g_current_widget)

        else if (id == ID_GLOBAL_BUSY) then
            if (wx_command_event_is_checked(evt)) then
                call wx_begin_busy_cursor()
            else
                call wx_end_busy_cursor()
            end if

        else if (id == ID_BUSY) then
            if (g_attr_cursor%owned) call wx_cursor_delete(g_attr_cursor)
            if (wx_command_event_is_checked(evt)) then
                g_attr_cursor = wx_cursor_create_from_stock( &
                    int(wxCURSOR_WAIT(), c_int))
            else
                g_attr_cursor = null_cursor_2()
            end if
            call apply_attrs(g_current_widget)

        else if (id >= ID_TEXT_BEGIN .and. id < ID_TEXT_END) then
            ! The C++ sample disables these items when the current page has no
            ! text entry; none of the pages ported here expose one.
            entry = current_text_entry()
            if (entry%is_valid()) call do_text_entry_menu(entry, id)

        else if (id == ID_THEME_LIGHT .or. id == ID_THEME_DARK .or. &
                 id == ID_THEME_SYSTEM) then
            select case (id)
            case (ID_THEME_LIGHT)
                appearance = int(wxApp_Appearance_Light(), c_int)
            case (ID_THEME_DARK)
                appearance = int(wxApp_Appearance_Dark(), c_int)
            case default
                appearance = int(wxApp_Appearance_System(), c_int)
            end select
            if (wx_app_set_appearance(wx_app_get_app(), appearance) == &
                int(wxApp_AppearanceResult_Failure(), c_int)) &
                call log_message("SetAppearance: failure")

        else if (id >= ID_GOTO_PAGE .and. id < ID_GOTO_PAGE + 100) then
            sel = wx_treebook_set_selection(g_book, int(id - ID_GOTO_PAGE, c_int))
        end if
    end subroutine on_menu

    ! Replace every occurrence of old by new (in place).
    subroutine replace_all(s, old, new)
        character(len=:), allocatable, intent(inout) :: s
        character(len=*), intent(in) :: old, new
        character(len=:), allocatable :: out
        integer :: pos

        out = ""
        do
            pos = index(s, old)
            if (pos == 0) exit
            out = out // s(:pos - 1) // new
            s = s(pos + len(old):)
        end do
        s = out // s
    end subroutine replace_all

    ! ------------------------------------------------------------------
    ! WidgetsPage::GetTextEntry(): only the TextCtrl, ComboBox, ODComboBox
    ! and SearchCtrl pages provide one, and none of them is ported here.
    ! ------------------------------------------------------------------
    function current_text_entry() result(entry)
        type(wxTextCtrl_t) :: entry

        entry%ptr = c_null_ptr
    end function current_text_entry

    ! The &Text menu commands (WidgetsFrame::On*AutoComplete).
    subroutine do_text_entry_menu(entry, id)
        type(wxTextCtrl_t), intent(in) :: entry
        integer, intent(in) :: id

        select case (id)
        case (ID_TEXT_DISABLE_AC)
            if (wx_text_ctrl_auto_complete(entry, 0_c_int, c_null_ptr)) then
                call log_message("Disabled auto completion.")
            else
                call log_message("AutoComplete() failed.")
            end if
        case (ID_TEXT_AC_FIXED)
            if (enable_fixed_autocomplete(entry)) then
                call log_message(&
                    "Enabled auto completion of a set of fixed strings.")
            else
                call log_message("AutoComplete() failed.")
            end if
        case (ID_TEXT_AC_FILES)
            if (wx_text_ctrl_auto_complete_file_names(entry)) then
                call log_message("Enabled auto completion of file names.")
            else
                call log_message("AutoCompleteFileNames() failed.")
            end if
        case (ID_TEXT_AC_DIRS)
            if (wx_text_ctrl_auto_complete_directories(entry)) then
                call log_message("Enabled auto completion of directories.")
            else
                call log_message("AutoCompleteDirectories() failed.")
            end if
        case default
            call log_message(&
                "Custom auto completion is unavailable in this port.")
        end select
    end subroutine do_text_entry_menu

    ! wxTextEntryBase::AutoComplete(wxArrayString) for the fixed list of
    ! widgets.cpp:1110-1117 ("aa".."zz" plus four strings).
    function enable_fixed_autocomplete(entry) result(ok)
        type(wxTextCtrl_t), intent(in) :: entry
        logical :: ok
        character(kind=c_char, len=27), parameter :: extra(4) = &
            [character(kind=c_char, len=27) :: &
             "is this string for test?", "this is a test string", &
             "this is another test string", "this string is for test"]
        character(kind=c_char), allocatable, target :: buf(:)
        type(c_ptr), allocatable, target :: ptrs(:)
        integer :: i, j, pos, total

        total = 26 * 3
        do i = 1, 4
            total = total + len_trim(extra(i)) + 1
        end do
        allocate (buf(total), ptrs(30))

        pos = 1
        do i = 1, 26
            buf(pos) = achar(96 + i, c_char)
            buf(pos + 1) = buf(pos)
            buf(pos + 2) = c_null_char
            ptrs(i) = c_loc(buf(pos))
            pos = pos + 3
        end do
        do i = 1, 4
            ptrs(26 + i) = c_loc(buf(pos))
            do j = 1, len_trim(extra(i))
                buf(pos) = extra(i) (j:j)
                pos = pos + 1
            end do
            buf(pos) = c_null_char
            pos = pos + 1
        end do

        ok = wx_text_ctrl_auto_complete(entry, int(size(ptrs), c_int), &
            c_loc(ptrs))
        deallocate (buf, ptrs)
    end function enable_fixed_autocomplete

    ! ------------------------------------------------------------------
    ! ListboxWidgetsPage::CreateLbox() - rebuild the listbox with the style
    ! selected by the checkboxes and the selection-mode radio box.
    ! ------------------------------------------------------------------
    subroutine recreate_listbox()
        type(wxListBox_t) :: newbox
        type(wxSizer_t) :: page_sizer
        character(len=:), allocatable :: items(:)
        integer(c_long) :: style
        integer :: i, n
        logical :: ok

        n = wx_list_box_get_count(g_lb_listbox)
        if (n > 0) then
            allocate (character(len=256) :: items(n))
            do i = 1, n
                items(i) = wx_list_box_get_string(g_lb_listbox, &
                    int(i - 1, c_int))
            end do
        else
            allocate (character(len=1) :: items(0))
        end if

        style = int(g_attr_default_flags, c_long)
        select case (wx_radio_box_get_selection(g_lb_selmode))
        case (0)
            style = ior(style, int(wxLB_SINGLE(), c_long))
        case (1)
            style = ior(style, int(wxLB_EXTENDED(), c_long))
        case (2)
            style = ior(style, int(wxLB_MULTIPLE(), c_long))
        end select
        if (wx_check_box_get_value(g_lb_vscroll)) &
            style = ior(style, int(wxLB_ALWAYS_SB(), c_long))
        if (wx_check_box_get_value(g_lb_hscroll)) &
            style = ior(style, int(wxLB_HSCROLL(), c_long))
        if (wx_check_box_get_value(g_lb_sort)) &
            style = ior(style, int(wxLB_SORT(), c_long))
        if (wx_check_box_get_value(g_lb_ownerdraw)) &
            style = ior(style, int(wxLB_OWNERDRAW(), c_long))

        newbox = wx_list_box_create(g_lb_page, &
            int(ID_PAGE_BASE + LB_LISTBOX, c_int), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, items, int(style, c_int))
        if (.not. newbox%is_valid()) return

        page_sizer = wx_window_get_sizer(g_lb_page)
        ok = wx_sizer_replace_window(page_sizer, g_lb_listbox, newbox, .false.)
        ok = wx_window_destroy(g_lb_listbox)
        g_lb_listbox = newbox
        i = wx_window_layout(g_lb_page)
    end subroutine recreate_listbox

    ! ItemContainerWidgetsPage::OnButtonTestItemContainer() for this port's
    ! two item-container pages.
    subroutine run_container_tests()
        character(len=*), parameter :: items(6) = [character(len=8) :: &
            "This", "is", "a", "List", "of", "strings"]
        integer :: i
        logical :: ok

        if (c_associated(g_current_page%ptr, g_lb_page%ptr)) then
            if (wx_list_box_is_sorted(g_lb_listbox)) then
                call log_message("wxItemContainer test for wxListBox, Sorted:")
            else
                call log_message(&
                    "wxItemContainer test for wxListBox, Unsorted:")
            end if

            call log_message("Test - Append one item:")
            call wx_list_box_clear(g_lb_listbox)
            call wx_list_box_append(g_lb_listbox, items(1))
            ok = wx_list_box_get_count(g_lb_listbox) == 1
            if (ok) ok = wx_list_box_get_string(g_lb_listbox, 0_c_int) == items(1)
            call report_test(ok)

            call log_message("Test - Append some items:")
            call wx_list_box_clear(g_lb_listbox)
            do i = 1, 6
                call wx_list_box_append(g_lb_listbox, items(i))
            end do
            ok = wx_list_box_get_count(g_lb_listbox) == 6
            if (ok) then
                do i = 1, 6
                    if (wx_list_box_get_string(g_lb_listbox, &
                        int(i - 1, c_int)) /= items(i)) then
                        ok = .false.
                        exit
                    end if
                end do
            end if
            call report_test(ok)
            call wx_list_box_clear(g_lb_listbox)

        else if (c_associated(g_current_page%ptr, g_ch_page%ptr)) then
            if (wx_choice_is_sorted(g_ch_choice)) then
                call log_message("wxItemContainer test for wxChoice, Sorted:")
            else
                call log_message("wxItemContainer test for wxChoice, Unsorted:")
            end if

            call log_message("Test - Append one item:")
            call wx_choice_clear(g_ch_choice)
            call wx_choice_append(g_ch_choice, items(1))
            ok = wx_choice_get_count(g_ch_choice) == 1
            if (ok) ok = wx_choice_get_string(g_ch_choice, 0_c_int) == items(1)
            call report_test(ok)

            call log_message("Test - Append some items:")
            call wx_choice_clear(g_ch_choice)
            do i = 1, 6
                call wx_choice_append(g_ch_choice, items(i))
            end do
            ok = wx_choice_get_count(g_ch_choice) == 6
            if (ok) then
                do i = 1, 6
                    if (wx_choice_get_string(g_ch_choice, &
                        int(i - 1, c_int)) /= items(i)) then
                        ok = .false.
                        exit
                    end if
                end do
            end if
            call report_test(ok)
            call wx_choice_clear(g_ch_choice)
        end if
    end subroutine run_container_tests

    subroutine report_test(passed)
        logical, intent(in) :: passed

        if (passed) then
            call log_message("...passed")
        else
            call log_message("...failed")
        end if
    end subroutine report_test

    ! ------------------------------------------------------------------
    ! Treebook page change: re-apply attributes to the new page's widget.
    ! ------------------------------------------------------------------
    subroutine on_page_changed(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: sel, kind

        if (.not. c_associated(evt)) return
        sel = wx_treebook_get_selection(g_book)
        if (sel < 0) return
        call wx_menu_check(g_page_menu, int(ID_GOTO_PAGE + sel, c_int), .true.)

        kind = 0
        if (sel <= g_tree_last) kind = g_tree_kind(sel)
        call select_page(kind)
    end subroutine on_page_changed

    ! WidgetsFrame::OnPageChanging(): category nodes have no page, so
    ! selecting one is vetoed.
    subroutine on_page_changing(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxbookctrlevent_t) :: bevt
        type(wxwindow_t) :: page

        if (.not. c_associated(evt)) return
        bevt = wxbookctrlevent_from_ptr(evt, .false.)
        page = wx_treebook_get_page(g_book, &
            wx_book_ctrl_event_get_selection(bevt))
        if (.not. page%is_valid()) call wx_notify_event_veto(bevt)
    end subroutine on_page_changing

    ! Map the tree selection to the page's main widget.
    subroutine select_page(kind)
        integer, intent(in) :: kind
        logical :: ok

        g_current_widget%ptr = c_null_ptr
        g_current_page%ptr = c_null_ptr

        select case (kind)
        case (1)
            g_current_page = g_ai_page
            g_current_widget%ptr = g_ai_indicator%ptr
        case (2)
            g_current_page = g_btn_page
            g_current_widget%ptr = g_btn_button%ptr
        case (3)
            g_current_page = g_cb_page
            g_current_widget%ptr = g_cb_checkbox%ptr
        case (4)
            g_current_page = g_ch_page
            g_current_widget%ptr = g_ch_choice%ptr
        case (5)
            g_current_page = g_ga_page
            g_current_widget%ptr = g_ga_gauge%ptr
        case (6)
            g_current_page = g_hl_page
            g_current_widget%ptr = g_hl_ctrl%ptr
        case (7)
            g_current_page = g_lb_page
            g_current_widget%ptr = g_lb_listbox%ptr
        case (8)
            g_current_page = g_sl_page
            g_current_widget%ptr = g_sl_slider%ptr
        case (9)
            g_current_page = g_sp_page
            g_current_widget%ptr = g_sp_spinctrl%ptr
        case (10)
            g_current_page = g_tg_page
            g_current_widget%ptr = g_tg_toggle%ptr
        end select

        if (g_current_page%is_valid() .and. g_has_page_bg) then
            ok = wx_window_set_background_colour(g_current_page, g_col_page_bg)
        end if
        call apply_attrs(g_current_widget)
    end subroutine select_page

    ! ------------------------------------------------------------------
    ! ActivityIndicator page
    ! ------------------------------------------------------------------
    subroutine on_ai(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)

        if (id == ID_PAGE_BASE + AI_START) then
            call wx_activity_indicator_start(g_ai_indicator)
            call wx_control_set_label(g_ai_label, "Indicator is running")
        else if (id == ID_PAGE_BASE + AI_STOP) then
            call wx_activity_indicator_stop(g_ai_indicator)
            call wx_control_set_label(g_ai_label, "Indicator is stopped")
        end if
    end subroutine on_ai

    ! ------------------------------------------------------------------
    ! Button page
    ! ------------------------------------------------------------------
    subroutine on_button(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)

        if (id == ID_PAGE_BASE + BTN_BUTTON) then
            call log_message("Button clicked.")
        else if (id == ID_PAGE_BASE + BTN_RESET) then
            call wx_text_ctrl_set_value(g_btn_label_text, "&Press me!")
            call wx_text_ctrl_set_value(g_btn_note_text, &
                "Writes down button clicks in the log.")
            call wx_control_set_label(g_btn_button, "&Press me!")
            call apply_attrs(g_current_widget)
        else if (id == ID_PAGE_BASE + BTN_CHANGE_LABEL) then
            call wx_control_set_label(g_btn_button, &
                wx_text_ctrl_get_value(g_btn_label_text))
        else if (id == ID_PAGE_BASE + BTN_CHANGE_NOTE) then
            call log_message("Change note: command link buttons are unavailable in this port")
        else if (id == ID_PAGE_BASE + BTN_CHANGE_MARGINS) then
            call log_message(&
                "Change image margins: bitmap button art is unavailable in this port")
        else if (id == ID_PAGE_BASE + BTN_DEFAULT) then
            call wx_button_set_default(g_btn_button)
        else if (id >= ID_PAGE_BASE + BTN_BITMAP_ONLY .and. &
                 id <= ID_PAGE_BASE + BTN_VALIGN) then
            call log_message("Button style change" // LOG_STYLE)
        end if
    end subroutine on_button

    ! ------------------------------------------------------------------
    ! CheckBox page
    ! ------------------------------------------------------------------
    subroutine on_checkbox(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)

        if (id == ID_PAGE_BASE + CB_CHECKBOX) then
            if (wx_check_box_get_value(g_cb_checkbox)) then
                call log_message("Checkbox checked")
            else
                call log_message("Checkbox unchecked")
            end if
        else if (id == ID_PAGE_BASE + CB_CHECK) then
            call wx_check_box_set_value(g_cb_checkbox, 1_c_int)
        else if (id == ID_PAGE_BASE + CB_UNCHECK) then
            call wx_check_box_set_value(g_cb_checkbox, 0_c_int)
        else if (id == ID_PAGE_BASE + CB_PARTCHECK) then
            call wx_check_box_set3state_value(g_cb_checkbox, &
                int(wxCHK_UNDETERMINED(), c_int))
        else if (id == ID_PAGE_BASE + CB_CHANGE_LABEL) then
            call wx_control_set_label(g_cb_checkbox, &
                wx_text_ctrl_get_value(g_cb_label_text))
        else if (id == ID_PAGE_BASE + CB_RESET) then
            call wx_text_ctrl_set_value(g_cb_label_text, "&Check me!")
            call wx_control_set_label(g_cb_checkbox, "&Check me!")
            call wx_check_box_set_value(g_cb_checkbox, 0_c_int)
        else if (id == ID_PAGE_BASE + CB_KIND .or. &
                 id == ID_PAGE_BASE + CB_CHKRIGHT) then
            call log_message("Checkbox style change" // LOG_STYLE)
        end if
    end subroutine on_checkbox

    ! ------------------------------------------------------------------
    ! Choice page
    ! ------------------------------------------------------------------
    subroutine on_choice(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id, sel, n
        character(len=:), allocatable :: s

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)

        if (id == ID_PAGE_BASE + CH_CHOICE) then
            sel = wx_choice_get_selection(g_ch_choice)
            call log_message("Choice selection changed: " // itoa(sel))
            return
        end if

        if (id == ID_PAGE_BASE + CH_ADD) then
            call wx_choice_append(g_ch_choice, &
                wx_text_ctrl_get_value(g_ch_add_text))
        else if (id == ID_PAGE_BASE + CH_ADDSEVERAL) then
            do n = 1, 5
                call wx_choice_append(g_ch_choice, "inserted item #" // itoa(n))
            end do
        else if (id == ID_PAGE_BASE + CH_ADDMANY) then
            do n = 1, 100
                call wx_choice_append(g_ch_choice, "item #" // itoa(n))
            end do
        else if (id == ID_PAGE_BASE + CH_CLEAR) then
            call wx_choice_clear(g_ch_choice)
        else if (id == ID_PAGE_BASE + CH_CHANGE) then
            sel = wx_choice_get_selection(g_ch_choice)
            if (sel >= 0) call wx_choice_set_string(g_ch_choice, int(sel, c_int), &
                wx_text_ctrl_get_value(g_ch_change_text))
        else if (id == ID_PAGE_BASE + CH_DELETE) then
            sel = atoi(wx_text_ctrl_get_value(g_ch_delete_text), -1)
            if (sel >= 0 .and. sel < wx_choice_get_count(g_ch_choice)) &
                call wx_choice_delete(g_ch_choice, int(sel, c_int))
        else if (id == ID_PAGE_BASE + CH_DELETESEL) then
            sel = wx_choice_get_selection(g_ch_choice)
            if (sel >= 0) call wx_choice_delete(g_ch_choice, int(sel, c_int))
        else if (id == ID_PAGE_BASE + CH_RESET) then
            call wx_choice_clear(g_ch_choice)
            call wx_choice_append(g_ch_choice, "initial item")
            call wx_choice_set_selection(g_ch_choice, 0_c_int)
        else if (id == ID_PAGE_BASE + CH_CONTAINERTESTS) then
            call run_container_tests()
        else if (id == ID_PAGE_BASE + CH_SORT) then
            call log_message("Choice style change" // LOG_STYLE)
        end if
        s = ""
    end subroutine on_choice

    ! ------------------------------------------------------------------
    ! Gauge page
    ! ------------------------------------------------------------------
    subroutine on_gauge(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id, v
        logical :: ok

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)

        if (id == ID_PAGE_BASE + GA_TIMER) then
            v = wx_gauge_get_value(g_ga_gauge)
            if (v < g_ga_range) then
                call wx_gauge_set_value(g_ga_gauge, int(v + 1, c_int))
            else
                call wx_timer_stop(g_ga_timer)
                g_ga_running = .false.
                call wx_control_set_label(g_ga_progress_btn, "Simulate &progress")
            end if
            call wx_text_ctrl_set_value(g_ga_cur, itoa(wx_gauge_get_value(g_ga_gauge)))
            return
        else if (id == ID_PAGE_BASE + GA_INDET_TIMER) then
            call wx_gauge_pulse(g_ga_gauge)
            return
        end if

        if (id == ID_PAGE_BASE + GA_SETVALUE) then
            v = atoi(wx_text_ctrl_get_value(g_ga_value_text), 0)
            call wx_gauge_set_value(g_ga_gauge, int(v, c_int))
            call wx_text_ctrl_set_value(g_ga_cur, itoa(wx_gauge_get_value(g_ga_gauge)))
        else if (id == ID_PAGE_BASE + GA_SETRANGE) then
            g_ga_range = atoi(wx_text_ctrl_get_value(g_ga_range_text), 100)
            call wx_gauge_set_range(g_ga_gauge, int(g_ga_range, c_int))
        else if (id == ID_PAGE_BASE + GA_CLEAR) then
            call wx_gauge_set_value(g_ga_gauge, 0_c_int)
            call wx_text_ctrl_set_value(g_ga_cur, "0")
        else if (id == ID_PAGE_BASE + GA_PROGRESS) then
            if (.not. g_ga_running) then
                ok = wx_timer_start(g_ga_timer, 300_c_int, .false.)
                g_ga_running = .true.
                call wx_control_set_label(g_ga_progress_btn, "&Stop timer")
            else
                call wx_timer_stop(g_ga_timer)
                g_ga_running = .false.
                call wx_control_set_label(g_ga_progress_btn, "Simulate &progress")
            end if
        else if (id == ID_PAGE_BASE + GA_INDET) then
            if (.not. g_ga_indet_running) then
                ok = wx_timer_start(g_ga_indet_timer, 300_c_int, .false.)
                g_ga_indet_running = .true.
                call wx_control_set_label(g_ga_indet_btn, "&Stop timer")
            else
                call wx_timer_stop(g_ga_indet_timer)
                g_ga_indet_running = .false.
                call wx_control_set_label(g_ga_indet_btn, "Simulate &indeterminate job")
            end if
        else if (id == ID_PAGE_BASE + GA_RESET) then
            call wx_timer_stop(g_ga_timer)
            call wx_timer_stop(g_ga_indet_timer)
            g_ga_running = .false.
            g_ga_indet_running = .false.
            g_ga_range = 100
            call wx_gauge_set_range(g_ga_gauge, int(g_ga_range, c_int))
            call wx_gauge_set_value(g_ga_gauge, 0_c_int)
            call wx_text_ctrl_set_value(g_ga_range_text, itoa(g_ga_range))
            call wx_text_ctrl_set_value(g_ga_cur, "0")
            call wx_control_set_label(g_ga_progress_btn, "Simulate &progress")
            call wx_control_set_label(g_ga_indet_btn, "Simulate &indeterminate job")
        else if (id == ID_PAGE_BASE + GA_VERT .or. &
                 id == ID_PAGE_BASE + GA_SMOOTH .or. &
                 id == ID_PAGE_BASE + GA_PROGRESSCHK) then
            call log_message("Gauge style change" // LOG_STYLE)
        end if
    end subroutine on_gauge

    ! ------------------------------------------------------------------
    ! Hyperlink page
    ! ------------------------------------------------------------------
    subroutine on_hyperlink(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)

        if (id == ID_PAGE_BASE + HL_SETLABEL) then
            call wx_control_set_label(g_hl_ctrl, &
                wx_text_ctrl_get_value(g_hl_label_text))
        else if (id == ID_PAGE_BASE + HL_SETURL) then
            call wx_hyperlink_ctrl_set_url(g_hl_ctrl, &
                wx_text_ctrl_get_value(g_hl_url_text))
        else if (id == ID_PAGE_BASE + HL_RESET) then
            call wx_text_ctrl_set_value(g_hl_label_text, "wxWidgets website")
            call wx_text_ctrl_set_value(g_hl_url_text, "www.wxwidgets.org")
            call wx_control_set_label(g_hl_ctrl, "wxWidgets website")
            call wx_hyperlink_ctrl_set_url(g_hl_ctrl, "www.wxwidgets.org")
        else if (id == ID_PAGE_BASE + HL_ALIGN .or. &
                 id == ID_PAGE_BASE + HL_GENERIC) then
            call log_message("Hyperlink style change" // LOG_STYLE)
        end if
    end subroutine on_hyperlink

    ! ------------------------------------------------------------------
    ! Listbox page
    ! ------------------------------------------------------------------
    subroutine on_listbox(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id, sel, n
        character(len=:), allocatable :: s

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)

        if (id == ID_PAGE_BASE + LB_LISTBOX) then
            sel = wx_list_box_get_selection(g_lb_listbox)
            call log_message("Listbox selection changed: " // itoa(sel))
            return
        end if

        if (id == ID_PAGE_BASE + LB_ADD) then
            s = wx_text_ctrl_get_value(g_lb_add_text)
            if (len_trim(s) == 0) then
                g_lb_item_counter = g_lb_item_counter + 1
                s = "test item " // achar(9) // itoa(g_lb_item_counter)
            end if
            call wx_list_box_append(g_lb_listbox, s)
        else if (id == ID_PAGE_BASE + LB_ADDSEVERAL) then
            do n = 1, 5
                call wx_list_box_append(g_lb_listbox, "inserted item #" // itoa(n))
            end do
        else if (id == ID_PAGE_BASE + LB_ADDMANY) then
            do n = 1, 100
                call wx_list_box_append(g_lb_listbox, "item #" // itoa(n))
            end do
        else if (id == ID_PAGE_BASE + LB_CLEAR) then
            call wx_list_box_clear(g_lb_listbox)
        else if (id == ID_PAGE_BASE + LB_CHANGE) then
            sel = wx_list_box_get_selection(g_lb_listbox)
            if (sel >= 0) call wx_list_box_set_string(g_lb_listbox, int(sel, c_int), &
                wx_text_ctrl_get_value(g_lb_change_text))
        else if (id == ID_PAGE_BASE + LB_DELETE) then
            sel = atoi(wx_text_ctrl_get_value(g_lb_delete_text), -1)
            if (sel >= 0 .and. sel < wx_list_box_get_count(g_lb_listbox)) &
                call wx_list_box_delete(g_lb_listbox, int(sel, c_int))
        else if (id == ID_PAGE_BASE + LB_DELETESEL) then
            sel = wx_list_box_get_selection(g_lb_listbox)
            if (sel >= 0) call wx_list_box_delete(g_lb_listbox, int(sel, c_int))
        else if (id == ID_PAGE_BASE + LB_ENSUREVISIBLE) then
            sel = atoi(wx_text_ctrl_get_value(g_lb_ensure_text), 0)
            call wx_list_box_set_selection(g_lb_listbox, int(sel, c_int), 1_c_int)
        else if (id == ID_PAGE_BASE + LB_GETTOPITEM) then
            call log_message("First visible item: " // &
                itoa(wx_list_box_get_top_item(g_lb_listbox)))
        else if (id == ID_PAGE_BASE + LB_GETCOUNTPERPAGE) then
            call log_message("Items per page: " // &
                itoa(wx_list_box_get_count_per_page(g_lb_listbox)))
        else if (id == ID_PAGE_BASE + LB_MOVEUP .or. &
                 id == ID_PAGE_BASE + LB_MOVEDOWN) then
            call log_message(&
                "Move item: wxRearrangeList is unavailable in this port")
        else if (id == ID_PAGE_BASE + LB_CONTAINERTESTS) then
            call run_container_tests()
        else if (id == ID_PAGE_BASE + LB_RESET) then
            call wx_radio_box_set_selection(g_lb_selmode, 0_c_int)
            call wx_radio_box_set_selection(g_lb_listtype, 0_c_int)
            call wx_check_box_set_value(g_lb_vscroll, 0_c_int)
            call wx_check_box_set_value(g_lb_hscroll, 1_c_int)
            call wx_check_box_set_value(g_lb_sort, 0_c_int)
            call wx_check_box_set_value(g_lb_ownerdraw, 0_c_int)
            call recreate_listbox()
        else if (id >= ID_PAGE_BASE + LB_VSCROLL .and. &
                 id <= ID_PAGE_BASE + LB_LISTTYPE) then
            call recreate_listbox()
        end if
    end subroutine on_listbox

    ! ------------------------------------------------------------------
    ! Slider page
    ! ------------------------------------------------------------------
    subroutine on_slider(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id, v, lo, hi

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)

        if (id == ID_PAGE_BASE + SL_SLIDER) then
            v = wx_slider_get_value(g_sl_slider)
            call wx_text_ctrl_set_value(g_sl_cur, itoa(v))
            call log_message("Slider value changed: " // itoa(v))
            return
        end if

        if (id == ID_PAGE_BASE + SL_SETVALUE) then
            v = atoi(wx_text_ctrl_get_value(g_sl_value_text), 0)
            call wx_slider_set_value(g_sl_slider, int(v, c_int))
            call wx_text_ctrl_set_value(g_sl_cur, itoa(wx_slider_get_value(g_sl_slider)))
        else if (id == ID_PAGE_BASE + SL_SETMINMAX) then
            lo = atoi(wx_text_ctrl_get_value(g_sl_min_text), 0)
            hi = atoi(wx_text_ctrl_get_value(g_sl_max_text), 100)
            if (hi > lo) then
                g_sl_min = lo
                g_sl_max = hi
                call wx_slider_set_range(g_sl_slider, int(lo, c_int), int(hi, c_int))
            end if
        else if (id == ID_PAGE_BASE + SL_SETRANGE) then
            lo = atoi(wx_text_ctrl_get_value(g_sl_rangemin_text), 20)
            hi = atoi(wx_text_ctrl_get_value(g_sl_rangemax_text), 80)
            if (hi > lo) then
                g_sl_rangemin = lo
                g_sl_rangemax = hi
                call wx_slider_set_selection(g_sl_slider, int(lo, c_int), int(hi, c_int))
            end if
        else if (id == ID_PAGE_BASE + SL_SETLINESIZE) then
            call wx_slider_set_line_size(g_sl_slider, &
                int(atoi(wx_text_ctrl_get_value(g_sl_linesize_text), 1), c_int))
        else if (id == ID_PAGE_BASE + SL_SETPAGESIZE) then
            call wx_slider_set_page_size(g_sl_slider, &
                int(atoi(wx_text_ctrl_get_value(g_sl_pagesize_text), 1), c_int))
        else if (id == ID_PAGE_BASE + SL_SETTICKFREQ) then
            call wx_slider_set_tick_freq(g_sl_slider, &
                int(atoi(wx_text_ctrl_get_value(g_sl_tickfreq_text), 10), c_int))
        else if (id == ID_PAGE_BASE + SL_SETTHUMBLEN) then
            call wx_slider_set_thumb_length(g_sl_slider, &
                int(atoi(wx_text_ctrl_get_value(g_sl_thumblen_text), 10), c_int))
        else if (id == ID_PAGE_BASE + SL_RESET) then
            g_sl_min = 0; g_sl_max = 100
            g_sl_rangemin = 20; g_sl_rangemax = 80
            call wx_slider_set_range(g_sl_slider, 0_c_int, 100_c_int)
            call wx_slider_set_value(g_sl_slider, 0_c_int)
            call wx_slider_set_tick_freq(g_sl_slider, 10_c_int)
            call wx_text_ctrl_set_value(g_sl_min_text, "0")
            call wx_text_ctrl_set_value(g_sl_max_text, "100")
            call wx_text_ctrl_set_value(g_sl_rangemin_text, "20")
            call wx_text_ctrl_set_value(g_sl_rangemax_text, "80")
            call wx_text_ctrl_set_value(g_sl_tickfreq_text, "10")
            call wx_text_ctrl_set_value(g_sl_cur, "0")
        else if (id == ID_PAGE_BASE + SL_CLEAR) then
            call wx_slider_set_value(g_sl_slider, int(g_sl_min, c_int))
            call wx_text_ctrl_set_value(g_sl_cur, itoa(g_sl_min))
        else if (id == ID_PAGE_BASE + SL_RADIOSIDES .or. &
                 id == ID_PAGE_BASE + SL_BOTHSIDES .or. &
                 id == ID_PAGE_BASE + SL_SELECTRANGE .or. &
                 id == ID_PAGE_BASE + SL_INVERSE .or. &
                 id == ID_PAGE_BASE + SL_TICKS .or. &
                 id == ID_PAGE_BASE + SL_VALUELABEL .or. &
                 id == ID_PAGE_BASE + SL_MINMAXLABELS) then
            call log_message("Slider style change" // LOG_STYLE)
        end if
    end subroutine on_slider

    ! ------------------------------------------------------------------
    ! Spin page
    ! ------------------------------------------------------------------
    subroutine on_spin(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id, v
        real(c_double) :: d

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)

        if (id == ID_PAGE_BASE + SP_SPINBTN) then
            v = wx_spin_button_get_value(g_sp_spinbtn)
            call wx_text_ctrl_set_value(g_sp_cur, itoa(v))
            call log_message("SpinButton value changed: " // itoa(v))
            return
        else if (id == ID_PAGE_BASE + SP_SPINCTRL) then
            v = wx_spin_ctrl_get_value(g_sp_spinctrl)
            call wx_text_ctrl_set_value(g_sp_cur, itoa(v))
            call log_message("SpinCtrl value changed: " // itoa(v))
            return
        else if (id == ID_PAGE_BASE + SP_SPINCTRLDOUBLE) then
            d = wx_spin_ctrl_double_get_value(g_sp_spinctrldbl)
            call log_message("SpinCtrlDouble value changed")
            return
        end if

        if (id == ID_PAGE_BASE + SP_SETVALUE) then
            v = atoi(wx_text_ctrl_get_value(g_sp_value_text), 0)
            call wx_spin_button_set_value(g_sp_spinbtn, int(v, c_int))
            call wx_spin_ctrl_set_value(g_sp_spinctrl, int(v, c_int))
            call wx_spin_ctrl_double_set_value(g_sp_spinctrldbl, real(v, c_double))
            call wx_text_ctrl_set_value(g_sp_cur, itoa(v))
        else if (id == ID_PAGE_BASE + SP_SETMINMAX) then
            g_sp_min = atoi(wx_text_ctrl_get_value(g_sp_min_text), 0)
            g_sp_max = atoi(wx_text_ctrl_get_value(g_sp_max_text), 10)
            if (g_sp_max > g_sp_min) then
                call wx_spin_button_set_range(g_sp_spinbtn, int(g_sp_min, c_int), &
                    int(g_sp_max, c_int))
                call wx_spin_ctrl_set_range(g_sp_spinctrl, int(g_sp_min, c_int), &
                    int(g_sp_max, c_int))
                call wx_spin_ctrl_double_set_range(g_sp_spinctrldbl, &
                    real(g_sp_min, c_double), real(g_sp_max, c_double))
            end if
        else if (id == ID_PAGE_BASE + SP_SETBASE) then
            v = atoi(wx_text_ctrl_get_value(g_sp_base_text), 10)
            if (wx_spin_ctrl_set_base(g_sp_spinctrl, int(v, c_int))) &
                call log_message("SpinCtrl base changed")
        else if (id == ID_PAGE_BASE + SP_SETINCREMENT) then
            v = atoi(wx_text_ctrl_get_value(g_sp_increment_text), 1)
            call wx_spin_button_set_increment(g_sp_spinbtn, int(v, c_int))
        else if (id == ID_PAGE_BASE + SP_CLEAR) then
            call wx_spin_button_set_value(g_sp_spinbtn, 0_c_int)
            call wx_spin_ctrl_set_value(g_sp_spinctrl, 0_c_int)
            call wx_spin_ctrl_double_set_value(g_sp_spinctrldbl, 0.0_c_double)
            call wx_text_ctrl_set_value(g_sp_cur, "0")
        else if (id == ID_PAGE_BASE + SP_RESET) then
            g_sp_min = 0; g_sp_max = 10
            call wx_spin_button_set_range(g_sp_spinbtn, 0_c_int, 10_c_int)
            call wx_spin_ctrl_set_range(g_sp_spinctrl, 0_c_int, 10_c_int)
            call wx_spin_ctrl_double_set_range(g_sp_spinctrldbl, 0.0_c_double, &
                10.0_c_double)
            call wx_text_ctrl_set_value(g_sp_min_text, "0")
            call wx_text_ctrl_set_value(g_sp_max_text, "10")
            call wx_text_ctrl_set_value(g_sp_cur, "0")
        else if (id >= ID_PAGE_BASE + SP_VERT .and. &
                 id <= ID_PAGE_BASE + SP_ALIGN) then
            call log_message("Spin style change" // LOG_STYLE)
        end if
    end subroutine on_spin

    ! ------------------------------------------------------------------
    ! ToggleButton page
    ! ------------------------------------------------------------------
    subroutine on_toggle(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)

        if (id == ID_PAGE_BASE + TG_PICKER) then
            if (wx_toggle_button_get_value(g_tg_toggle)) then
                call log_message("ToggleButton toggled on")
            else
                call log_message("ToggleButton toggled off")
            end if
        else if (id == ID_PAGE_BASE + TG_CHANGELABEL) then
            call wx_toggle_button_set_label(g_tg_toggle, &
                wx_text_ctrl_get_value(g_tg_label_text))
        else if (id == ID_PAGE_BASE + TG_RESET) then
            call wx_text_ctrl_set_value(g_tg_label_text, "&Toggle me!")
            call wx_toggle_button_set_label(g_tg_toggle, "&Toggle me!")
            call wx_toggle_button_set_value(g_tg_toggle, .false.)
        else if (id >= ID_PAGE_BASE + TG_BITMAP_ONLY .and. &
                 id <= ID_PAGE_BASE + TG_VALIGN) then
            call log_message("ToggleButton style change" // LOG_STYLE)
        end if
    end subroutine on_toggle

    pure function itoa(value) result(s)
        integer, intent(in) :: value
        character(len=:), allocatable :: s
        character(len=32) :: buf
        write (buf, '(I0)') value
        s = trim(buf)
    end function itoa

    ! ------------------------------------------------------------------
    ! wxLog text hook: redirect messages to the log listbox.
    ! ------------------------------------------------------------------
    subroutine on_log_text(pself, level, msg) bind(C)
        type(c_ptr), value :: pself, msg
        integer(c_int), value :: level
        character(len=:), allocatable :: text
        integer(c_int) :: count

        if (.not. c_associated(msg)) return
        text = from_wxstring(msg)
        if (.not. g_log%is_valid()) return
        call wx_list_box_append(g_log, text)
        count = wx_list_box_get_count(g_log)
        if (count > 0) call wx_list_box_set_first_item(g_log, count - 1)
    end subroutine on_log_text

    ! Legacy DoLog(level, const char*, time_t) sink required by
    ! kwx_log_create(); every message is delivered through on_log_text.
    subroutine on_log_legacy(pself, level, szstring, timestamp) bind(C)
        type(c_ptr), value :: pself, szstring
        integer(c_int), value :: level, timestamp

        if (level < 0 .or. timestamp < 0) return
        if (c_associated(pself) .and. c_associated(szstring)) return
    end subroutine on_log_legacy

end module widgets_handlers


program widgets
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_ANY, wxID_HIGHEST, wxID_EXIT, wxOK, &
        wxBORDER_DEFAULT, wxDEFAULT_FRAME_STYLE, wxTAB_TRAVERSAL, wxBK_DEFAULT, &
        wxVERTICAL, wxHORIZONTAL, wxEXPAND, wxLEFT, wxRIGHT, wxBOTTOM, wxALL, &
        wxALIGN_CENTER_VERTICAL, wxALIGN_RIGHT, wxCLIP_CHILDREN, &
        wxRA_SPECIFY_COLS, wxSL_AUTOTICKS, wxSL_MIN_MAX_LABELS, &
        wxSL_VALUE_LABEL, wxSL_HORIZONTAL, wxSP_ARROW_KEYS, wxSP_VERTICAL, &
        wxLB_HSCROLL, wxTE_READONLY, wxHL_ALIGN_CENTRE, wxGA_HORIZONTAL, &
        wxCHK_2STATE, wxLayout_Default, &
        wxEVT_MENU, wxEVT_BUTTON, wxEVT_CHECKBOX, wxEVT_RADIOBOX, &
        wxEVT_TEXT_ENTER, wxEVT_CHOICE, wxEVT_TIMER, wxEVT_SPIN, &
        wxEVT_SPINCTRL, wxEVT_SPINCTRLDOUBLE, wxEVT_TEXT, wxEVT_TOGGLEBUTTON, &
        wxEVT_LISTBOX, wxEVT_LISTBOX_DCLICK, wxEVT_SLIDER, &
        wxEVT_TREEBOOK_PAGE_CHANGED, wxEVT_TREEBOOK_PAGE_CHANGING
    use wx_app
    use wx_frame
    use wx_window
    use wx_panel
    use wx_menu
    use wx_menu_bar
    use wx_events
    use wx_sizer
    use wx_box_sizer
    use wx_static_box
    use wx_static_box_sizer
    use wx_scrolled_window
    use wx_button
    use wx_check_box
    use wx_choice
    use wx_gauge
    use wx_hyperlink_ctrl
    use wx_list_box
    use wx_slider
    use wx_spin_button
    use wx_spin_ctrl
    use wx_spin_ctrl_double
    use wx_toggle_button
    use wx_activity_indicator
    use wx_static_text
    use wx_text_ctrl
    use wx_radio_box
    use wx_timer
    use wx_control
    use wx_treebook
    use wx_colour
    use wx_size
    use wx_bitmap_bundle
    use wx_bitmap_bundle_array
    use wx_bitmap
    use wx_icon
    use wx_book_ctrl_base
    use wx_free_functions, only: null_cursor_2
    use kwx_log
    use wx_log
    use widgets_globals
    use widgets_util
    use widgets_handlers
    implicit none

    type(wxWindow_t) :: no_parent, nullwin
    type(wxBoxSizer_t) :: top_sizer, sizer_down, sizer_btns, sizer_top_row
    type(wxStaticBoxSizer_t) :: sbs_down
    type(wxStaticBox_t) :: down_box
    type(wxButton_t) :: btn, btn2
    type(wxSize_t) :: best
    type(wxBitmapBundle_t) :: icon_bundle
    type(wxBitmap_t) :: icon_bitmap
    type(wxIcon_t) :: frame_icon
    character(len=1) :: no_items(0)
    integer :: exit_code, db, i, cat, pas, nsub
    integer :: cat_first(0:7), cat_n(0:7), cat_kinds(0:7, 10)
    integer :: order_cat(64), order_kind(64), norder
    integer :: st
    logical :: ok
    character(len=*), parameter :: cat_label(0:7) = [character(len=16) :: &
        "Native", "Generic", "Pickers", "Comboboxes", "With items", &
        "Editable", "Books", "All controls"]

    ! ================================================================
    ! Bootstrap
    ! ================================================================

    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    call wx_set_app_name("Widgets sample")
    ID_PAGE_BASE = int(wxID_HIGHEST())
    db = int(wx_sizer_get_default_border())
    g_attr_tooltip = "This is a tooltip"
    g_attr_default_flags = int(wxBORDER_DEFAULT())
    g_attr_dir = int(wxLayout_Default(), c_int)
    g_attr_cursor = null_cursor_2()
    g_col_fg = wx_colour_create_rgb(0_1, 0_1, 0_1, -1_1)
    g_col_bg = wx_colour_create_rgb(0_1, 0_1, 0_1, -1_1)
    g_col_page_bg = wx_colour_create_rgb(0_1, 0_1, 0_1, -1_1)

    no_parent%ptr = c_null_ptr
    nullwin%ptr = c_null_ptr

    ! ================================================================
    ! Main frame
    ! ================================================================

    g_frame = wx_frame_create(no_parent, int(wxID_ANY(), c_int), &
        "wxMSW widgets demo", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
        int(wxDEFAULT_FRAME_STYLE(), c_int))
    if (.not. g_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if
    call set_frame_icon()
    call build_menus()

    g_panel = wx_panel_create(g_frame, int(wxID_ANY(), c_int), -1_c_int, &
        -1_c_int, -1_c_int, -1_c_int, int(wxTAB_TRAVERSAL(), c_int))

    ! ================================================================
    ! Book with the widget pages
    ! ================================================================

    g_book = wx_treebook_create(g_panel, int(ID_BOOK, c_int), -1_c_int, &
        -1_c_int, 900_c_int, 500_c_int, int(wxBK_DEFAULT(), c_int))
    if (.not. g_book%is_valid()) then
        print *, "Failed to create treebook"
        stop 1
    end if

    call build_all_pages()
    call set_book_images()

    ! Category order: pages are placed in their primary category only (see
    ! the port report: duplicate page instances are not created).
    do cat = 0, 7
        cat_n(cat) = 0
    end do
    cat_kinds(0, 1:8) = [1, 2, 3, 5, 7, 8, 9, 10]
    cat_n(0) = 8
    cat_kinds(1, 1) = 6
    cat_n(1) = 1
    cat_kinds(4, 1) = 4
    cat_n(4) = 1

    norder = 0
    st = 0
    do cat = 0, 7
        g_tree_kind(st) = 0
        st = st + 1
        do i = 1, cat_n(cat)
            norder = norder + 1
            order_cat(norder) = cat
            order_kind(norder) = cat_kinds(cat, i)
            g_tree_kind(st) = cat_kinds(cat, i)
            st = st + 1
        end do
    end do
    g_tree_last = st - 1

    ! Add the category nodes and their pages in tree order.
    st = 0
    nsub = 0
    do cat = 0, 7
        ok = wx_treebook_add_page(g_book, nullwin, trim(cat_label(cat)), &
            .false., 0_c_int)
        st = st + 1
        do i = 1, cat_n(cat)
            ok = wx_treebook_add_sub_page(g_book, &
                page_window(cat_kinds(cat, i)), &
                page_label(cat_kinds(cat, i)), .false., &
                int(nsub + 1, c_int))
            st = st + 1
            nsub = nsub + 1
        end do
    end do

    call build_page_menu()
    g_tree_kind(0) = 0

    ! ================================================================
    ! Log window: static box with listbox + Clear log / Exit buttons
    ! ================================================================

    call make_static_box(g_panel, "&Log window", down_box, sbs_down, &
        int(wxVERTICAL(), c_int))
    g_log_box = down_box
    g_log = wx_list_box_create(down_box, int(wxID_ANY(), c_int), -1_c_int, &
        -1_c_int, -1_c_int, -1_c_int, no_items, 0_c_int)
    call add_win(sbs_down, g_log, 1, int(wxEXPAND(), c_int), db)
    call wx_sizer_set_min_size(sbs_down, 100_c_int, 150_c_int)

    ! Redirect wxLog to the listbox, as the C++ sample's log target does.
    g_log_target = kwx_log_create(c_null_ptr, c_funloc(on_log_legacy))
    call kwx_log_set_on_do_log_text_at_level(g_log_target, &
        c_funloc(on_log_text))
    g_log_old = wx_log_set_active_target(g_log_target)

    sizer_btns = wx_box_sizer_create(int(wxHORIZONTAL(), c_int))
    btn = wx_button_create(down_box, int(ID_CLEAR_LOG, c_int), "Clear &log", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call add_win(sizer_btns, btn)
    call add_space(sizer_btns, 10)
    btn2 = wx_button_create(down_box, int(ID_QUIT, c_int), "E&xit", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call add_win(sizer_btns, btn2)
    call add_sz(sbs_down, sizer_btns, 0, &
        ior(int(wxALL(), c_int), int(wxRIGHT(), c_int)), db)

    ! ================================================================
    ! Panel sizer
    ! ================================================================

    top_sizer = wx_box_sizer_create(int(wxVERTICAL(), c_int))
    call add_win(top_sizer, g_book, 1, &
        ior(int(wxEXPAND(), c_int), ior(int(wxLEFT(), c_int), &
        int(wxRIGHT(), c_int))), 2 * db)
    call add_space(top_sizer, 5)
    call add_sz(top_sizer, sbs_down, 0, &
        ior(int(wxEXPAND(), c_int), ior(int(wxLEFT(), c_int), &
        ior(int(wxRIGHT(), c_int), int(wxBOTTOM(), c_int)))), 2 * db)
    call wx_window_set_sizer(g_panel, top_sizer, .false.)

    best = wx_window_get_best_size(g_panel)
    call wx_window_set_client_size(g_frame, wx_size_get_width(best), &
        wx_size_get_height(best))
    call wx_window_set_min_client_size(g_frame, wx_size_get_width(best), &
        wx_size_get_height(best))

    call connect_events()
    i = wx_window_layout(g_panel)

    ! Select the first real page (tree index 1) after the book is realised and
    ! bind the Widget menu target explicitly (a same-index SetSelection emits
    ! no PAGE_CHANGED event).
    st = wx_treebook_set_selection(g_book, 1_c_int)
    call select_page(g_tree_kind(1))

    call wx_set_top_window(g_frame)
    ok = wx_window_show(g_frame)

    exit_code = wx_main_loop()

    call wx_timer_stop(g_ga_timer)
    call wx_timer_stop(g_ga_indet_timer)
    call wx_timer_delete(g_ga_timer)
    call wx_timer_delete(g_ga_indet_timer)
    call wx_colour_delete(g_col_fg)
    call wx_colour_delete(g_col_bg)
    call wx_colour_delete(g_col_page_bg)

    ! Restore the previous log target, then delete ours (the C++ dtor does
    ! wxLog::SetActiveTarget(m_logOld)).
    block
        type(wxlog_t) :: displaced
        displaced = wx_log_set_active_target(g_log_old)
        displaced%owned = .false.
    end block
    call kwx_log_delete(g_log_target)

    call wx_shutdown()

contains

    ! ------------------------------------------------------------------
    ! Frame icon: sample.svg (the C++ sample uses wxICON(sample))
    ! ------------------------------------------------------------------
    subroutine set_book_images()
        type(wxBitmapBundleArray_t) :: images
        type(wxBitmapBundle_t) :: bundle, fallback
        ! One icon per ported page, in subpage (tree) order: the same order in
        ! which wx_treebook_add_sub_page() assigns image ids 1..10 below.
        character(len=32), parameter :: page_icon(10) = &
            [character(len=32) :: &
             "icons/activityindicator.svg", "icons/button.svg", &
             "icons/checkbox.svg", "icons/gauge.svg", &
             "icons/listbox.svg", "icons/slider.svg", &
             "icons/spinbtn.svg", "icons/toggle.svg", &
             "icons/hyperlnk.svg", "icons/choice.svg"]
        integer :: k

        images = wx_bitmap_bundle_array_create()

        ! Image 0 is shared by the category nodes.
        fallback = wx_bitmap_bundle_from_svg_file("sample.svg", 16_c_int, &
            16_c_int)
        if (.not. fallback%is_valid()) then
            call wx_bitmap_bundle_array_delete(images)
            return
        end if
        call wx_bitmap_bundle_array_add(images, fallback)

        do k = 1, 10
            bundle = wx_bitmap_bundle_from_svg_file(trim(page_icon(k)), &
                16_c_int, 16_c_int)
            if (bundle%is_valid()) then
                call wx_bitmap_bundle_array_add(images, bundle)
                call wx_bitmap_bundle_delete(bundle)
            else
                ! Keep the image index aligned with the subpage id.
                call wx_bitmap_bundle_array_add(images, fallback)
            end if
        end do

        call wx_book_ctrl_base_set_images(g_book, images)
        call wx_bitmap_bundle_array_delete(images)
        call wx_bitmap_bundle_delete(fallback)
    end subroutine set_book_images

    subroutine set_frame_icon()
        icon_bundle = wx_bitmap_bundle_from_svg_file("sample.svg", 32_c_int, 32_c_int)
        if (.not. icon_bundle%is_valid()) return
        icon_bitmap = wx_bitmap_bundle_get_bitmap(icon_bundle, 32_c_int, 32_c_int)
        if (icon_bitmap%is_valid()) then
            frame_icon = wx_icon_create_default()
            if (frame_icon%is_valid()) then
                call wx_icon_copy_from_bitmap(frame_icon, icon_bitmap)
                if (wx_icon_is_ok(frame_icon)) call wx_frame_set_icon(g_frame, frame_icon)
                call wx_icon_delete(frame_icon)
            end if
            call wx_bitmap_delete(icon_bitmap)
        end if
        call wx_bitmap_bundle_delete(icon_bundle)
    end subroutine set_frame_icon

    ! ------------------------------------------------------------------
    ! Menu bar (WidgetsFrame ctor)
    ! ------------------------------------------------------------------
    subroutine build_menus()
        type(wxMenu_t) :: widget_menu, text_menu, borders_menu, variants_menu
        type(wxMenuItem_t) :: mi

        g_menu_bar = wx_menu_bar_create(0_c_int)
        widget_menu = wx_menu_create("", 0_c_long)

        call wx_menu_append(widget_menu, int(ID_SET_TOOLTIP, c_int), &
            "Set &tooltip..." // achar(9) // "Ctrl-T", "", .false.)
        call wx_menu_append_separator(widget_menu)
        call wx_menu_append(widget_menu, int(ID_SET_FG, c_int), &
            "Set &foreground..." // achar(9) // "Ctrl-F", "", .false.)
        call wx_menu_append(widget_menu, int(ID_SET_BG, c_int), &
            "Set &background..." // achar(9) // "Ctrl-B", "", .false.)
        call wx_menu_append(widget_menu, int(ID_SET_PAGE_BG, c_int), &
            "Set &page background..." // achar(9) // "Shift-Ctrl-B", "", .false.)
        call wx_menu_append(widget_menu, int(ID_SET_FONT, c_int), &
            "Set f&ont..." // achar(9) // "Ctrl-O", "", .false.)
        call wx_menu_append_check_item(widget_menu, int(ID_ENABLE, c_int), &
            "&Enable/disable" // achar(9) // "Ctrl-E", "")
        call wx_menu_append_check_item(widget_menu, int(ID_SHOW, c_int), &
            "Show/Hide", "")

        borders_menu = wx_menu_create("", 0_c_long)
        call wx_menu_append_radio_item(borders_menu, int(ID_BORDER_DEFAULT, c_int), &
            "De&fault" // achar(9) // "Ctrl-Shift-9", "")
        call wx_menu_append_radio_item(borders_menu, int(ID_BORDER_NONE, c_int), &
            "&None" // achar(9) // "Ctrl-Shift-0", "")
        call wx_menu_append_radio_item(borders_menu, int(ID_BORDER_SIMPLE, c_int), &
            "&Simple" // achar(9) // "Ctrl-Shift-1", "")
        call wx_menu_append_radio_item(borders_menu, int(ID_BORDER_DOUBLE, c_int), &
            "&Double" // achar(9) // "Ctrl-Shift-2", "")
        call wx_menu_append_radio_item(borders_menu, int(ID_BORDER_STATIC, c_int), &
            "Stati&c" // achar(9) // "Ctrl-Shift-3", "")
        call wx_menu_append_radio_item(borders_menu, int(ID_BORDER_RAISED, c_int), &
            "&Raised" // achar(9) // "Ctrl-Shift-4", "")
        call wx_menu_append_radio_item(borders_menu, int(ID_BORDER_SUNKEN, c_int), &
            "S&unken" // achar(9) // "Ctrl-Shift-5", "")
        mi = wx_menu_append_sub_menu(widget_menu, borders_menu, "Set &border", "")

        variants_menu = wx_menu_create("", 0_c_long)
        call wx_menu_append_radio_item(variants_menu, int(ID_VARIANT_MINI, c_int), &
            "&Mini" // achar(9) // "Ctrl-Shift-6", "")
        call wx_menu_append_radio_item(variants_menu, int(ID_VARIANT_SMALL, c_int), &
            "&Small" // achar(9) // "Ctrl-Shift-7", "")
        call wx_menu_append_radio_item(variants_menu, int(ID_VARIANT_NORMAL, c_int), &
            "&Normal" // achar(9) // "Ctrl-Shift-8", "")
        call wx_menu_append_radio_item(variants_menu, int(ID_VARIANT_LARGE, c_int), &
            "&Large" // achar(9) // "Ctrl-Shift-9", "")
        mi = wx_menu_append_sub_menu(widget_menu, variants_menu, "Set &variant", "")

        call wx_menu_append_separator(widget_menu)
        call wx_menu_append_check_item(widget_menu, int(ID_LAYOUT_DIRECTION, c_int), &
            "Toggle &layout direction" // achar(9) // "Ctrl-L", "")
        call wx_menu_append_separator(widget_menu)
        call wx_menu_append_check_item(widget_menu, int(ID_GLOBAL_BUSY, c_int), &
            "Toggle &global busy cursor" // achar(9) // "Ctrl-Shift-U", "")
        call wx_menu_append_check_item(widget_menu, int(ID_BUSY, c_int), &
            "Toggle b&usy cursor" // achar(9) // "Ctrl-U", "")
        call wx_menu_append_separator(widget_menu)
        call wx_menu_append(widget_menu, int(wxID_EXIT(), c_int), &
            "&Quit" // achar(9) // "Ctrl-Q", "", .false.)
        i = wx_menu_bar_append(g_menu_bar, widget_menu, "&Widget")

        text_menu = wx_menu_create("", 0_c_long)
        call wx_menu_append_radio_item(text_menu, int(ID_TEXT_DISABLE_AC, c_int), &
            "&Disable auto-completion", "")
        call wx_menu_append_radio_item(text_menu, int(ID_TEXT_AC_FIXED, c_int), &
            "Fixed-&list auto-completion", "")
        call wx_menu_append_radio_item(text_menu, int(ID_TEXT_AC_FILES, c_int), &
            "&Files names auto-completion", "")
        call wx_menu_append_radio_item(text_menu, int(ID_TEXT_AC_DIRS, c_int), &
            "&Directories names auto-completion", "")
        call wx_menu_append_radio_item(text_menu, int(ID_TEXT_AC_CUSTOM, c_int), &
            "&Custom auto-completion", "")
        call wx_menu_append_radio_item(text_menu, int(ID_TEXT_AC_KEYLEN, c_int), &
            "Custom with &min length", "")
        call wx_menu_append_separator(text_menu)
        call wx_menu_append(text_menu, int(ID_TEXT_SET_HINT, c_int), &
            "Set help &hint", "", .false.)
        i = wx_menu_bar_append(g_menu_bar, text_menu, "&Text")

        call wx_frame_set_menu_bar(g_frame, g_menu_bar)
        call wx_menu_check(widget_menu, int(ID_ENABLE, c_int), .true.)
        call wx_menu_check(widget_menu, int(ID_SHOW, c_int), .true.)
        call wx_menu_check(variants_menu, int(ID_VARIANT_NORMAL, c_int), .true.)
    end subroutine build_menus

    ! ------------------------------------------------------------------
    ! Page menu, appended after InitBook() in the C++ sample.
    ! ------------------------------------------------------------------
    subroutine build_page_menu()
        integer :: k, idx, tree_index, dummy
        type(wxMenu_t) :: theme_menu

        if (norder == 0) return
        g_page_menu = wx_menu_create("", 0_c_long)
        tree_index = 0
        k = 0
        do cat = 0, 7
            tree_index = tree_index + 1 ! category node
            do i = 1, cat_n(cat)
                k = k + 1
                call wx_menu_append_radio_item(g_page_menu, &
                    int(ID_GOTO_PAGE + tree_index, c_int), &
                    page_label(cat_kinds(cat, i)), "")
                tree_index = tree_index + 1
            end do
        end do
        dummy = wx_menu_bar_append(g_menu_bar, g_page_menu, "&Page")

        theme_menu = wx_menu_create("", 0_c_long)
        call wx_menu_append_radio_item(theme_menu, int(ID_THEME_SYSTEM, c_int), &
            "&System", "")
        call wx_menu_append_radio_item(theme_menu, int(ID_THEME_LIGHT, c_int), &
            "&Light", "")
        call wx_menu_append_radio_item(theme_menu, int(ID_THEME_DARK, c_int), &
            "&Dark", "")
        dummy = wx_menu_bar_append(g_menu_bar, theme_menu, "T&heme")
        call wx_menu_check(theme_menu, int(ID_THEME_SYSTEM, c_int), .true.)
        call wx_frame_set_menu_bar(g_frame, g_menu_bar)
        call wx_menu_check(g_page_menu, int(ID_GOTO_PAGE + 1, c_int), .true.)
    end subroutine build_page_menu

    ! ------------------------------------------------------------------
    ! Page lookups
    ! ------------------------------------------------------------------
    function page_label(kind) result(s)
        integer, intent(in) :: kind
        character(len=:), allocatable :: s

        select case (kind)
        case (1); s = "ActivityIndicator"
        case (2); s = "Button"
        case (3); s = "CheckBox"
        case (4); s = "Choice"
        case (5); s = "Gauge"
        case (6); s = "Hyperlink"
        case (7); s = "Listbox"
        case (8); s = "Slider"
        case (9); s = "Spin"
        case (10); s = "ToggleButton"
        case default; s = ""
        end select
    end function page_label

    function page_window(kind) result(w)
        integer, intent(in) :: kind
        type(wxWindow_t) :: w

        w%ptr = c_null_ptr
        select case (kind)
        case (1); w%ptr = g_ai_page%ptr
        case (2); w%ptr = g_btn_page%ptr
        case (3); w%ptr = g_cb_page%ptr
        case (4); w%ptr = g_ch_page%ptr
        case (5); w%ptr = g_ga_page%ptr
        case (6); w%ptr = g_hl_page%ptr
        case (7); w%ptr = g_lb_page%ptr
        case (8); w%ptr = g_sl_page%ptr
        case (9); w%ptr = g_sp_page%ptr
        case (10); w%ptr = g_tg_page%ptr
        end select
    end function page_window

    subroutine build_all_pages()
        call build_ai_page()
        call build_button_page()
        call build_checkbox_page()
        call build_choice_page()
        call build_gauge_page()
        call build_hyperlink_page()
        call build_listbox_page()
        call build_slider_page()
        call build_spin_page()
        call build_toggle_page()
    end subroutine build_all_pages

    ! ------------------------------------------------------------------
    ! ActivityIndicator page
    ! ------------------------------------------------------------------
    subroutine build_ai_page()
        type(wxBoxSizer_t) :: top
        type(wxStaticBoxSizer_t) :: so, si
        type(wxStaticBox_t) :: bo, bi

        g_ai_page = wx_scrolled_window_create(g_book, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(int(wxCLIP_CHILDREN(), c_int), int(wxTAB_TRAVERSAL(), c_int)))
        top = wx_box_sizer_create(int(wxHORIZONTAL(), c_int))
        call wx_window_set_sizer(g_ai_page, top, .false.)
        call wx_scrolled_window_set_scroll_rate(g_ai_page, 10_c_int, 10_c_int)

        call make_static_box(g_ai_page, "&Operations", bo, so, &
            int(wxVERTICAL(), c_int))
        g_ai_start = wx_button_create(bo, int(ID_PAGE_BASE + AI_START, c_int), &
            "&Start", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(so, g_ai_start, 0, int(wxALL(), c_int), db)
        g_ai_stop = wx_button_create(bo, int(ID_PAGE_BASE + AI_STOP, c_int), &
            "&Stop", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(so, g_ai_stop, 0, int(wxALL(), c_int), db)
        g_ai_label = wx_static_text_create(bo, &
            int(ID_PAGE_BASE + AI_ISRUNNING, c_int), &
            "Indicator is initializing...", -1_c_int, -1_c_int, -1_c_int, &
            -1_c_int, 0_c_int)
        call add_win(so, g_ai_label, 0, int(wxALL(), c_int), db)
        call add_sz(top, so, 0, int(wxALL(), c_int), db)

        call make_static_box(g_ai_page, "Activity Indicator", bi, si, &
            int(wxHORIZONTAL(), c_int))
        call add_stretch(si, 1)
        g_ai_indicator = wx_activity_indicator_create(bi, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(si, g_ai_indicator, 0, int(wxALIGN_CENTER_VERTICAL(), c_int), 0)
        call add_stretch(si, 1)
        call add_sz(top, si, 1, ior(int(wxEXPAND(), c_int), int(wxALL(), c_int)), db)

        call wx_window_fit_inside(g_ai_page)
    end subroutine build_ai_page

    ! ------------------------------------------------------------------
    ! Button page
    ! ------------------------------------------------------------------
    subroutine build_button_page()
        type(wxBoxSizer_t) :: top, right
        type(wxStaticBoxSizer_t) :: sl, sm, sbmp, smarg
        type(wxStaticBox_t) :: bl, bm, bbmp, bmarg
        type(wxRadioBox_t) :: rpos, rhalign, rvalign
        character(len=4) :: ipos(4)
        character(len=6) :: halign(3), valign(3)
        type(wxTextCtrl_t) :: th, tv
        type(wxButton_t) :: bmargins

        g_btn_page = wx_scrolled_window_create(g_book, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(int(wxCLIP_CHILDREN(), c_int), int(wxTAB_TRAVERSAL(), c_int)))
        top = wx_box_sizer_create(int(wxHORIZONTAL(), c_int))
        call wx_window_set_sizer(g_btn_page, top, .false.)
        call wx_scrolled_window_set_scroll_rate(g_btn_page, 10_c_int, 10_c_int)

        call make_static_box(g_btn_page, "&Set style", bl, sl, &
            int(wxVERTICAL(), c_int))
        call add_check(sl, bl, int(ID_PAGE_BASE + BTN_BITMAP_ONLY, c_int), &
            "&Bitmap only", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + BTN_TEXT_AND_BITMAP, c_int), &
            "Text &and bitmap", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + BTN_FIT_EXACTLY, c_int), &
            "&Fit exactly", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + BTN_REQUIRE_AUTH, c_int), &
            "Require a&uth", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + BTN_CMD_LINK, c_int), &
            "Use command &link button", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + BTN_MARKUP, c_int), &
            "Interpret &markup", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + BTN_DEFAULT, c_int), &
            "&Default", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + BTN_USE_BITMAP, c_int), &
            "Use wxBitmapButton", 1)

        call make_static_box(g_btn_page, &
            "&Use the following bitmaps in addition to the normal one?", bbmp, sbmp, &
            int(wxVERTICAL(), c_int))
        call add_check(sbmp, bbmp, int(ID_PAGE_BASE + BTN_USE_PRESSED, c_int), &
            "&Pressed (small help icon)", 0)
        call add_check(sbmp, bbmp, int(ID_PAGE_BASE + BTN_USE_FOCUSED, c_int), &
            "&Focused (small error icon)", 0)
        call add_check(sbmp, bbmp, int(ID_PAGE_BASE + BTN_USE_CURRENT, c_int), &
            "&Current (small warning icon)", 0)
        call add_check(sbmp, bbmp, int(ID_PAGE_BASE + BTN_USE_DISABLED, c_int), &
            "&Disabled (broken image icon)", 0)
        call add_sz(sl, sbmp, 0, int(wxALL(), c_int), db)

        ipos = [character(len=4) :: "left", "right", "top", "bottom"]
        rpos = wx_radio_box_create(bl, &
            int(ID_PAGE_BASE + BTN_IMAGEPOS, c_int), "Image &position", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, ipos, 1_c_int, &
            int(wxRA_SPECIFY_COLS(), c_int))
        call add_win(sl, rpos, 0, int(wxALL(), c_int), db)

        call make_static_box(g_btn_page, "Image margins", bmarg, smarg, &
            int(wxVERTICAL(), c_int))
        bmargins = wx_button_create(bmarg, &
            int(ID_PAGE_BASE + BTN_CHANGE_MARGINS, c_int), &
            "Horizontal and vertical", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(smarg, bmargins, 0, int(wxALL(), c_int), db)
        th = wx_text_ctrl_create(bmarg, int(ID_PAGE_BASE + BTN_MARGIN_H, c_int), &
            "0", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(smarg, th, 0, int(wxALL(), c_int), db)
        tv = wx_text_ctrl_create(bmarg, int(ID_PAGE_BASE + BTN_MARGIN_V, c_int), &
            "0", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(smarg, tv, 0, int(wxALL(), c_int), db)
        call add_sz(sl, smarg, 0, int(wxALL(), c_int), db)

        halign = [character(len=6) :: "left", "centre", "right"]
        rhalign = wx_radio_box_create(bl, &
            int(ID_PAGE_BASE + BTN_HALIGN, c_int), "&Horz alignment", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, halign, 3_c_int, &
            int(wxRA_SPECIFY_COLS(), c_int))
        call add_win(sl, rhalign, 0, int(wxALL(), c_int), db)
        valign = [character(len=6) :: "top", "centre", "bottom"]
        rvalign = wx_radio_box_create(bl, &
            int(ID_PAGE_BASE + BTN_VALIGN, c_int), "&Vert alignment", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, valign, 3_c_int, &
            int(wxRA_SPECIFY_COLS(), c_int))
        call add_win(sl, rvalign, 0, int(wxALL(), c_int), db)

        btn = wx_button_create(bl, int(ID_PAGE_BASE + BTN_RESET, c_int), &
            "&Reset", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, btn, 0, int(wxALL(), c_int), db)
        call add_sz(top, sl, 0, int(wxALL(), c_int), db)

        call make_static_box(g_btn_page, "&Operations", bm, sm, &
            int(wxVERTICAL(), c_int))
        btn = wx_button_create(bm, int(ID_PAGE_BASE + BTN_CHANGE_LABEL, c_int), &
            "Change label", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_btn_label_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + BTN_LABELTEXT, c_int), "&Press me!", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_btn_label_text, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + BTN_CHANGE_NOTE, c_int), &
            "Change note", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_btn_note_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + BTN_NOTETEXT, c_int), &
            "Writes down button clicks in the log.", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_btn_note_text, 0, int(wxALL(), c_int), db)
        call add_sz(top, sm, 0, int(wxALL(), c_int), db)

        right = wx_box_sizer_create(int(wxVERTICAL(), c_int))
        g_btn_button = wx_button_create(g_btn_page, &
            int(ID_PAGE_BASE + BTN_BUTTON, c_int), "&Press me!", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_window_set_min_size(g_btn_button, 150_c_int, -1_c_int)
        call add_win(right, g_btn_button, 1, ior(int(wxEXPAND(), c_int), &
            int(wxALL(), c_int)), db)
        call add_sz(top, right, 1, ior(int(wxEXPAND(), c_int), &
            int(wxALL(), c_int)), db)

        call wx_window_fit_inside(g_btn_page)
    end subroutine build_button_page

    ! ------------------------------------------------------------------
    ! CheckBox page
    ! ------------------------------------------------------------------
    subroutine build_checkbox_page()
        type(wxBoxSizer_t) :: top
        type(wxStaticBoxSizer_t) :: sl, sm
        type(wxStaticBox_t) :: bl, bm
        type(wxRadioBox_t) :: rkind
        character(len=32) :: kinds(3)

        g_cb_page = wx_scrolled_window_create(g_book, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(int(wxCLIP_CHILDREN(), c_int), int(wxTAB_TRAVERSAL(), c_int)))
        top = wx_box_sizer_create(int(wxHORIZONTAL(), c_int))
        call wx_window_set_sizer(g_cb_page, top, .false.)
        call wx_scrolled_window_set_scroll_rate(g_cb_page, 10_c_int, 10_c_int)

        call make_static_box(g_cb_page, "&Set style", bl, sl, &
            int(wxVERTICAL(), c_int))
        g_cb_chk_right = wx_check_box_create(bl, &
            int(ID_PAGE_BASE + CB_CHKRIGHT, c_int), "&Right aligned", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, g_cb_chk_right, 0, int(wxALL(), c_int), db)
        kinds = [character(len=32) :: "usual &2-state checkbox", &
            "&3rd state settable by program", "&user-settable 3rd state"]
        rkind = wx_radio_box_create(bl, int(ID_PAGE_BASE + CB_KIND, c_int), &
            "&Kind", -1_c_int, -1_c_int, -1_c_int, -1_c_int, kinds, 1_c_int, &
            int(wxRA_SPECIFY_COLS(), c_int))
        call add_win(sl, rkind, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bl, int(ID_PAGE_BASE + CB_RESET, c_int), &
            "&Reset", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, btn, 0, int(wxALL(), c_int), db)
        call add_sz(top, sl, 0, int(wxALL(), c_int), db)

        call make_static_box(g_cb_page, "&Operations", bm, sm, &
            int(wxVERTICAL(), c_int))
        btn = wx_button_create(bm, int(ID_PAGE_BASE + CB_CHANGE_LABEL, c_int), &
            "Change label", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_cb_label_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + CB_LABELTEXT, c_int), "&Check me!", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_cb_label_text, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + CB_CHECK, c_int), &
            "&Check it", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + CB_UNCHECK, c_int), &
            "&Uncheck it", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + CB_PARTCHECK, c_int), &
            "Put in &3rd state", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        call add_sz(top, sm, 0, int(wxALL(), c_int), db)

        g_cb_checkbox = wx_check_box_create(g_cb_page, &
            int(ID_PAGE_BASE + CB_CHECKBOX, c_int), "&Check me!", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, int(wxCHK_2STATE(), c_int))
        call add_win(top, g_cb_checkbox, 0, int(wxALL(), c_int), db)

        call wx_window_fit_inside(g_cb_page)
    end subroutine build_checkbox_page

    ! ------------------------------------------------------------------
    ! Choice page
    ! ------------------------------------------------------------------
    subroutine build_choice_page()
        type(wxBoxSizer_t) :: top
        type(wxStaticBoxSizer_t) :: sl, sm
        type(wxStaticBox_t) :: bl, bm

        g_ch_page = wx_scrolled_window_create(g_book, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(int(wxCLIP_CHILDREN(), c_int), int(wxTAB_TRAVERSAL(), c_int)))
        top = wx_box_sizer_create(int(wxHORIZONTAL(), c_int))
        call wx_window_set_sizer(g_ch_page, top, .false.)
        call wx_scrolled_window_set_scroll_rate(g_ch_page, 10_c_int, 10_c_int)

        call make_static_box(g_ch_page, "&Set choice parameters", bl, sl, &
            int(wxVERTICAL(), c_int))
        g_ch_sort = wx_check_box_create(bl, int(ID_PAGE_BASE + CH_SORT, c_int), &
            "&Sort items", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, g_ch_sort, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bl, int(ID_PAGE_BASE + CH_RESET, c_int), &
            "&Reset", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, btn, 0, int(wxALL(), c_int), db)
        call add_sz(top, sl, 0, int(wxALL(), c_int), db)

        call make_static_box(g_ch_page, "&Change choice contents", bm, sm, &
            int(wxVERTICAL(), c_int))
        btn = wx_button_create(bm, int(ID_PAGE_BASE + CH_ADD, c_int), &
            "&Add this string", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_ch_add_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + CH_ADDTEXT, c_int), "test item 0", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_ch_add_text, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + CH_ADDSEVERAL, c_int), &
            "&Insert a few strings", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + CH_ADDMANY, c_int), &
            "Add &many strings", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + CH_CHANGE, c_int), &
            "C&hange current", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_ch_change_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + CH_CHANGETEXT, c_int), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_ch_change_text, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + CH_DELETE, c_int), &
            "&Delete this item", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_ch_delete_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + CH_DELETETEXT, c_int), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_ch_delete_text, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + CH_DELETESEL, c_int), &
            "Delete &selection", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + CH_CLEAR, c_int), &
            "&Clear", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + CH_CONTAINERTESTS, c_int), &
            "Run &tests", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        call add_sz(top, sm, 0, int(wxALL(), c_int), db)

        g_ch_choice = wx_choice_create(g_ch_page, &
            int(ID_PAGE_BASE + CH_CHOICE, c_int), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, no_items, 0_c_int)
        call add_win(top, g_ch_choice, 1, ior(int(wxEXPAND(), c_int), &
            int(wxALL(), c_int)), db)

        call wx_window_fit_inside(g_ch_page)
    end subroutine build_choice_page

    ! ------------------------------------------------------------------
    ! Gauge page
    ! ------------------------------------------------------------------
    subroutine build_gauge_page()
        type(wxBoxSizer_t) :: top
        type(wxStaticBoxSizer_t) :: sl, sm
        type(wxStaticBox_t) :: bl, bm
        type(wxStaticText_t) :: lab

        g_ga_page = wx_scrolled_window_create(g_book, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(int(wxCLIP_CHILDREN(), c_int), int(wxTAB_TRAVERSAL(), c_int)))
        top = wx_box_sizer_create(int(wxHORIZONTAL(), c_int))
        call wx_window_set_sizer(g_ga_page, top, .false.)
        call wx_scrolled_window_set_scroll_rate(g_ga_page, 10_c_int, 10_c_int)

        call make_static_box(g_ga_page, "&Set style", bl, sl, &
            int(wxVERTICAL(), c_int))
        call add_check(sl, bl, int(ID_PAGE_BASE + GA_VERT, c_int), &
            "&Vertical", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + GA_SMOOTH, c_int), &
            "&Smooth", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + GA_PROGRESSCHK, c_int), &
            "&Progress", 0)
        btn = wx_button_create(bl, int(ID_PAGE_BASE + GA_RESET, c_int), &
            "&Reset", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, btn, 0, int(wxALL(), c_int), db)
        call add_sz(top, sl, 0, int(wxALL(), c_int), db)

        call make_static_box(g_ga_page, "&Change gauge value", bm, sm, &
            int(wxVERTICAL(), c_int))
        lab = wx_static_text_create(bm, int(wxID_ANY(), c_int), &
            "Current value", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, lab, 0, int(wxALL(), c_int), db)
        g_ga_cur = wx_text_ctrl_create(bm, int(ID_PAGE_BASE + GA_CURVALUE, c_int), &
            "0", -1_c_int, -1_c_int, -1_c_int, -1_c_int, int(wxTE_READONLY(), c_long))
        call add_win(sm, g_ga_cur, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + GA_SETVALUE, c_int), &
            "Set &value", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_ga_value_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + GA_VALUETEXT, c_int), "0", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_ga_value_text, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + GA_SETRANGE, c_int), &
            "Set &range", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_ga_range_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + GA_RANGETEXT, c_int), "100", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_ga_range_text, 0, int(wxALL(), c_int), db)
        g_ga_progress_btn = wx_button_create(bm, &
            int(ID_PAGE_BASE + GA_PROGRESS, c_int), "Simulate &progress", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, g_ga_progress_btn, 0, int(wxALL(), c_int), db)
        g_ga_indet_btn = wx_button_create(bm, &
            int(ID_PAGE_BASE + GA_INDET, c_int), &
            "Simulate &indeterminate job", -1_c_int, -1_c_int, -1_c_int, &
            -1_c_int, 0_c_int)
        call add_win(sm, g_ga_indet_btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + GA_CLEAR, c_int), &
            "&Clear", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        call add_sz(top, sm, 0, int(wxALL(), c_int), db)

        g_ga_gauge = wx_gauge_create(g_ga_page, &
            int(ID_PAGE_BASE + GA_GAUGE, c_int), 100_c_int, -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, int(wxGA_HORIZONTAL(), c_int))
        call add_win(top, g_ga_gauge, 1, ior(int(wxEXPAND(), c_int), &
            int(wxALL(), c_int)), db)

        g_ga_timer = wx_timer_create(g_ga_page, int(ID_PAGE_BASE + GA_TIMER, c_int))
        g_ga_indet_timer = wx_timer_create(g_ga_page, &
            int(ID_PAGE_BASE + GA_INDET_TIMER, c_int))

        call wx_window_fit_inside(g_ga_page)
    end subroutine build_gauge_page

    ! ------------------------------------------------------------------
    ! Hyperlink page
    ! ------------------------------------------------------------------
    subroutine build_hyperlink_page()
        type(wxBoxSizer_t) :: top, right, row
        type(wxStaticBoxSizer_t) :: sl
        type(wxStaticBox_t) :: bl
        type(wxRadioBox_t) :: ralign
        type(wxStaticText_t) :: t1, t2
        character(len=7) :: aligns(3)

        g_hl_page = wx_scrolled_window_create(g_book, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(int(wxCLIP_CHILDREN(), c_int), int(wxTAB_TRAVERSAL(), c_int)))
        top = wx_box_sizer_create(int(wxHORIZONTAL(), c_int))
        call wx_window_set_sizer(g_hl_page, top, .false.)
        call wx_scrolled_window_set_scroll_rate(g_hl_page, 10_c_int, 10_c_int)

        call make_static_box(g_hl_page, "Hyperlink details", bl, sl, &
            int(wxVERTICAL(), c_int))
        btn = wx_button_create(bl, int(ID_PAGE_BASE + HL_SETLABEL, c_int), &
            "Set &Label", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, btn, 0, int(wxALL(), c_int), db)
        g_hl_label_text = wx_text_ctrl_create(bl, &
            int(ID_PAGE_BASE + HL_LABELTEXT, c_int), "wxWidgets website", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sl, g_hl_label_text, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bl, int(ID_PAGE_BASE + HL_SETURL, c_int), &
            "Set &URL", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, btn, 0, int(wxALL(), c_int), db)
        g_hl_url_text = wx_text_ctrl_create(bl, &
            int(ID_PAGE_BASE + HL_URLTEXT, c_int), "www.wxwidgets.org", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sl, g_hl_url_text, 0, int(wxALL(), c_int), db)
        aligns = [character(len=7) :: "&left", "&centre", "&right"]
        ralign = wx_radio_box_create(bl, int(ID_PAGE_BASE + HL_ALIGN, c_int), &
            "alignment", -1_c_int, -1_c_int, -1_c_int, -1_c_int, aligns, &
            1_c_int, int(wxRA_SPECIFY_COLS(), c_int))
        call wx_radio_box_set_selection(ralign, 1_c_int)
        call add_win(sl, ralign, 0, int(wxALL(), c_int), db)
        call add_check(sl, bl, int(ID_PAGE_BASE + HL_GENERIC, c_int), &
            "Use generic version", 0)
        call add_sz(top, sl, 0, int(wxALL(), c_int), db)

        right = wx_box_sizer_create(int(wxVERTICAL(), c_int))
        row = wx_box_sizer_create(int(wxHORIZONTAL(), c_int))
        t1 = wx_static_text_create(g_hl_page, int(wxID_ANY(), c_int), "Visit ", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(row, t1, 0, int(wxALIGN_CENTER_VERTICAL(), c_int), 0)
        g_hl_ctrl = wx_hyperlink_ctrl_create(g_hl_page, &
            int(ID_PAGE_BASE + HL_CTRL, c_int), "wxWidgets website", &
            "www.wxwidgets.org", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            int(wxHL_ALIGN_CENTRE(), c_int))
        call add_win(row, g_hl_ctrl, 0, int(wxALIGN_CENTER_VERTICAL(), c_int), 0)
        t2 = wx_static_text_create(g_hl_page, int(wxID_ANY(), c_int), &
            " for fun!", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(row, t2, 0, int(wxALIGN_CENTER_VERTICAL(), c_int), 0)
        call add_sz(right, row, 0, int(wxALL(), c_int), db)

        g_hl_ctrl_long = wx_hyperlink_ctrl_create(g_hl_page, &
            int(ID_PAGE_BASE + HL_CTRLLONG, c_int), "This is a long hyperlink", &
            "www.wxwidgets.org", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(right, g_hl_ctrl_long, 0, int(wxALL(), c_int), db)
        call add_sz(top, right, 1, ior(int(wxEXPAND(), c_int), &
            int(wxALL(), c_int)), db)

        call wx_window_fit_inside(g_hl_page)
    end subroutine build_hyperlink_page

    ! ------------------------------------------------------------------
    ! Listbox page
    ! ------------------------------------------------------------------
    subroutine build_listbox_page()
        type(wxBoxSizer_t) :: top
        type(wxStaticBoxSizer_t) :: sl, sm
        type(wxStaticBox_t) :: bl, bm
        type(wxRadioBox_t) :: rsel, rtype
        character(len=8) :: modes(3)
        character(len=8) :: types(1)

        g_lb_page = wx_scrolled_window_create(g_book, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(int(wxCLIP_CHILDREN(), c_int), int(wxTAB_TRAVERSAL(), c_int)))
        top = wx_box_sizer_create(int(wxHORIZONTAL(), c_int))
        call wx_window_set_sizer(g_lb_page, top, .false.)
        call wx_scrolled_window_set_scroll_rate(g_lb_page, 10_c_int, 10_c_int)

        call make_static_box(g_lb_page, "&Set listbox parameters", bl, sl, &
            int(wxVERTICAL(), c_int))
        g_lb_vscroll = wx_check_box_create(bl, &
            int(ID_PAGE_BASE + LB_VSCROLL, c_int), &
            "Always show &vertical scrollbar", -1_c_int, -1_c_int, -1_c_int, &
            -1_c_int, 0_c_int)
        call add_win(sl, g_lb_vscroll, 0, int(wxALL(), c_int), db)
        g_lb_hscroll = wx_check_box_create(bl, &
            int(ID_PAGE_BASE + LB_HSCROLL, c_int), &
            "Show &horizontal scrollbar", -1_c_int, -1_c_int, -1_c_int, &
            -1_c_int, 0_c_int)
        call wx_check_box_set_value(g_lb_hscroll, 1_c_int)
        call add_win(sl, g_lb_hscroll, 0, int(wxALL(), c_int), db)
        g_lb_sort = wx_check_box_create(bl, int(ID_PAGE_BASE + LB_SORT, c_int), &
            "&Sort items", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, g_lb_sort, 0, int(wxALL(), c_int), db)
        g_lb_ownerdraw = wx_check_box_create(bl, &
            int(ID_PAGE_BASE + LB_OWNERDRAW, c_int), "&Owner drawn", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, g_lb_ownerdraw, 0, int(wxALL(), c_int), db)
        modes = [character(len=8) :: "single", "extended", "multiple"]
        g_lb_selmode = wx_radio_box_create(bl, &
            int(ID_PAGE_BASE + LB_SELMODE, c_int), "Selection &mode:", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, modes, 1_c_int, &
            int(wxRA_SPECIFY_COLS(), c_int))
        call add_win(sl, g_lb_selmode, 0, int(wxALL(), c_int), db)
        types = [character(len=8) :: "list box"]
        g_lb_listtype = wx_radio_box_create(bl, &
            int(ID_PAGE_BASE + LB_LISTTYPE, c_int), "&List type:", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, types, 1_c_int, &
            int(wxRA_SPECIFY_COLS(), c_int))
        call add_win(sl, g_lb_listtype, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bl, int(ID_PAGE_BASE + LB_RESET, c_int), &
            "&Reset", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, btn, 0, int(wxALL(), c_int), db)
        call add_sz(top, sl, 0, int(wxALL(), c_int), db)

        call make_static_box(g_lb_page, "&Change listbox contents", bm, sm, &
            int(wxVERTICAL(), c_int))
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_ADD, c_int), &
            "&Add this string", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_lb_add_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + LB_ADDTEXT, c_int), "test item", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_lb_add_text, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_ADDSEVERAL, c_int), &
            "&Insert a few strings", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_ADDMANY, c_int), &
            "Add &many strings", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_CHANGE, c_int), &
            "C&hange current", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_lb_change_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + LB_CHANGETEXT, c_int), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_lb_change_text, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_ENSUREVISIBLE, c_int), &
            "Make item &visible", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_lb_ensure_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + LB_ENSUREVISIBLETEXT, c_int), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_lb_ensure_text, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_DELETE, c_int), &
            "&Delete this item", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_lb_delete_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + LB_DELETETEXT, c_int), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_lb_delete_text, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_DELETESEL, c_int), &
            "Delete &selection", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_CLEAR, c_int), &
            "&Clear", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_MOVEUP, c_int), &
            "Move item &up", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_MOVEDOWN, c_int), &
            "Move item &down", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_GETTOPITEM, c_int), &
            "Get top item", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_GETCOUNTPERPAGE, c_int), &
            "Get count per page", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bm, int(ID_PAGE_BASE + LB_CONTAINERTESTS, c_int), &
            "Run &tests", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        call add_sz(top, sm, 0, int(wxALL(), c_int), db)

        g_lb_listbox = wx_list_box_create(g_lb_page, &
            int(ID_PAGE_BASE + LB_LISTBOX, c_int), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, no_items, int(wxLB_HSCROLL(), c_int))
        call add_win(top, g_lb_listbox, 1, ior(int(wxEXPAND(), c_int), &
            int(wxALL(), c_int)), db)

        call wx_window_fit_inside(g_lb_page)
    end subroutine build_listbox_page

    ! ------------------------------------------------------------------
    ! Slider page
    ! ------------------------------------------------------------------
    subroutine build_slider_page()
        type(wxBoxSizer_t) :: top
        type(wxStaticBoxSizer_t) :: sl, sm
        type(wxStaticBox_t) :: bl, bm
        type(wxRadioBox_t) :: rsides
        character(len=7) :: sides(5)
        integer(c_long) :: slstyle

        g_sl_page = wx_scrolled_window_create(g_book, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(int(wxCLIP_CHILDREN(), c_int), int(wxTAB_TRAVERSAL(), c_int)))
        top = wx_box_sizer_create(int(wxHORIZONTAL(), c_int))
        call wx_window_set_sizer(g_sl_page, top, .false.)
        call wx_scrolled_window_set_scroll_rate(g_sl_page, 10_c_int, 10_c_int)

        call make_static_box(g_sl_page, "&Set style", bl, sl, &
            int(wxVERTICAL(), c_int))
        call add_check(sl, bl, int(ID_PAGE_BASE + SL_INVERSE, c_int), &
            "&Inverse", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + SL_TICKS, c_int), &
            "Show &ticks", 1)
        call add_check(sl, bl, int(ID_PAGE_BASE + SL_MINMAXLABELS, c_int), &
            "Show min/max &labels", 1)
        call add_check(sl, bl, int(ID_PAGE_BASE + SL_VALUELABEL, c_int), &
            "Show &value label", 1)
        sides = [character(len=7) :: "default", "top", "bottom", "left", "right"]
        rsides = wx_radio_box_create(bl, &
            int(ID_PAGE_BASE + SL_RADIOSIDES, c_int), "&Label position", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, sides, 1_c_int, &
            int(wxRA_SPECIFY_COLS(), c_int))
        call add_win(sl, rsides, 0, int(wxALL(), c_int), db)
        call add_check(sl, bl, int(ID_PAGE_BASE + SL_BOTHSIDES, c_int), &
            "&Both sides", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + SL_SELECTRANGE, c_int), &
            "&Selection range", 0)
        btn = wx_button_create(bl, int(ID_PAGE_BASE + SL_RESET, c_int), &
            "&Reset", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, btn, 0, int(wxALL(), c_int), db)
        call add_sz(top, sl, 0, int(wxALL(), c_int), db)

        call make_static_box(g_sl_page, "&Change slider value", bm, sm, &
            int(wxVERTICAL(), c_int))
        call add_text_row(sm, bm, "Current value", &
            int(ID_PAGE_BASE + SL_CURVALUE, c_int), "0", 1, g_sl_cur)
        call add_button_row(sm, bm, int(ID_PAGE_BASE + SL_SETVALUE, c_int), &
            "Set &value", int(ID_PAGE_BASE + SL_VALUETEXT, c_int), "0", &
            g_sl_value_text)
        call add_button_row2(sm, bm, int(ID_PAGE_BASE + SL_SETMINMAX, c_int), &
            "&Min and max", int(ID_PAGE_BASE + SL_MINTEXT, c_int), "0", &
            int(ID_PAGE_BASE + SL_MAXTEXT, c_int), "100", g_sl_min_text, &
            g_sl_max_text)
        call add_button_row2(sm, bm, int(ID_PAGE_BASE + SL_SETRANGE, c_int), &
            "&Selection", int(ID_PAGE_BASE + SL_RANGEMINTEXT, c_int), "20", &
            int(ID_PAGE_BASE + SL_RANGEMAXTEXT, c_int), "80", &
            g_sl_rangemin_text, g_sl_rangemax_text)
        call add_button_row(sm, bm, int(ID_PAGE_BASE + SL_SETLINESIZE, c_int), &
            "Li&ne size", int(ID_PAGE_BASE + SL_LINESIZETEXT, c_int), "", &
            g_sl_linesize_text)
        call add_button_row(sm, bm, int(ID_PAGE_BASE + SL_SETPAGESIZE, c_int), &
            "P&age size", int(ID_PAGE_BASE + SL_PAGESIZETEXT, c_int), "", &
            g_sl_pagesize_text)
        call add_button_row(sm, bm, int(ID_PAGE_BASE + SL_SETTICKFREQ, c_int), &
            "Tick &frequency", int(ID_PAGE_BASE + SL_TICKFREQTEXT, c_int), "10", &
            g_sl_tickfreq_text)
        call add_button_row(sm, bm, int(ID_PAGE_BASE + SL_SETTHUMBLEN, c_int), &
            "Thumb &length", int(ID_PAGE_BASE + SL_THUMBLENTEXT, c_int), "", &
            g_sl_thumblen_text)
        call add_sz(top, sm, 0, int(wxALL(), c_int), db)

        slstyle = int(wxSL_HORIZONTAL(), c_long)
        slstyle = ior(slstyle, int(wxSL_AUTOTICKS(), c_long))
        slstyle = ior(slstyle, int(wxSL_MIN_MAX_LABELS(), c_long))
        slstyle = ior(slstyle, int(wxSL_VALUE_LABEL(), c_long))
        g_sl_slider = wx_slider_create(g_sl_page, &
            int(ID_PAGE_BASE + SL_SLIDER, c_int), 0_c_int, 0_c_int, &
            100_c_int, -1_c_int, -1_c_int, -1_c_int, -1_c_int, slstyle)
        call add_win(top, g_sl_slider, 1, ior(int(wxEXPAND(), c_int), &
            int(wxALL(), c_int)), db)

        call wx_window_fit_inside(g_sl_page)
    end subroutine build_slider_page

    ! ------------------------------------------------------------------
    ! Spin page
    ! ------------------------------------------------------------------
    subroutine build_spin_page()
        type(wxBoxSizer_t) :: top, right
        type(wxStaticBoxSizer_t) :: sl, sm
        type(wxStaticBox_t) :: bl, bm
        type(wxRadioBox_t) :: ralign
        type(wxStaticText_t) :: lab
        character(len=6) :: aligns(3)
        integer(c_long) :: style

        g_sp_page = wx_scrolled_window_create(g_book, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(int(wxCLIP_CHILDREN(), c_int), int(wxTAB_TRAVERSAL(), c_int)))
        top = wx_box_sizer_create(int(wxHORIZONTAL(), c_int))
        call wx_window_set_sizer(g_sp_page, top, .false.)
        call wx_scrolled_window_set_scroll_rate(g_sp_page, 10_c_int, 10_c_int)

        call make_static_box(g_sp_page, "&Set style", bl, sl, &
            int(wxVERTICAL(), c_int))
        call add_check(sl, bl, int(ID_PAGE_BASE + SP_VERT, c_int), &
            "&Vertical", 1)
        call add_check(sl, bl, int(ID_PAGE_BASE + SP_ARROWKEYS, c_int), &
            "&Arrow Keys", 1)
        call add_check(sl, bl, int(ID_PAGE_BASE + SP_WRAP, c_int), &
            "&Wrap", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + SP_PROCESSENTER, c_int), &
            "Process &Enter", 0)
        aligns = [character(len=6) :: "left", "centre", "right"]
        ralign = wx_radio_box_create(bl, int(ID_PAGE_BASE + SP_ALIGN, c_int), &
            "&Text alignment", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            aligns, 1_c_int, int(wxRA_SPECIFY_COLS(), c_int))
        call wx_radio_box_set_selection(ralign, 2_c_int)
        call add_win(sl, ralign, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bl, int(ID_PAGE_BASE + SP_RESET, c_int), &
            "&Reset", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, btn, 0, int(wxALL(), c_int), db)
        call add_sz(top, sl, 0, int(wxALL(), c_int), db)

        call make_static_box(g_sp_page, "&Change spinbtn value", bm, sm, &
            int(wxVERTICAL(), c_int))
        call add_text_row(sm, bm, "Current value", &
            int(ID_PAGE_BASE + SP_CURVALUE, c_int), "0", 1, g_sp_cur)
        call add_button_row(sm, bm, int(ID_PAGE_BASE + SP_SETVALUE, c_int), &
            "Set &value", int(ID_PAGE_BASE + SP_VALUETEXT, c_int), "0", &
            g_sp_value_text)
        call add_button_row2(sm, bm, int(ID_PAGE_BASE + SP_SETMINMAX, c_int), &
            "&Min and max", int(ID_PAGE_BASE + SP_MINTEXT, c_int), "0", &
            int(ID_PAGE_BASE + SP_MAXTEXT, c_int), "10", g_sp_min_text, &
            g_sp_max_text)
        call add_button_row(sm, bm, int(ID_PAGE_BASE + SP_SETBASE, c_int), &
            "Set &base", int(ID_PAGE_BASE + SP_BASETEXT, c_int), "10", &
            g_sp_base_text)
        call add_button_row(sm, bm, int(ID_PAGE_BASE + SP_SETINCREMENT, c_int), &
            "Set Increment", int(ID_PAGE_BASE + SP_INCREMENTTEXT, c_int), "1", &
            g_sp_increment_text)
        call add_sz(top, sm, 0, int(wxALL(), c_int), db)

        right = wx_box_sizer_create(int(wxVERTICAL(), c_int))
        lab = wx_static_text_create(g_sp_page, int(wxID_ANY(), c_int), &
            "wxSpinButton", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(right, lab, 0, int(wxALL(), c_int), db)
        style = ior(int(wxSP_VERTICAL(), c_long), int(wxSP_ARROW_KEYS(), c_long))
        g_sp_spinbtn = wx_spin_button_create(g_sp_page, &
            int(ID_PAGE_BASE + SP_SPINBTN, c_int), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, style)
        call wx_spin_button_set_range(g_sp_spinbtn, 0_c_int, 10_c_int)
        call add_win(right, g_sp_spinbtn, 0, int(wxALL(), c_int), db)

        lab = wx_static_text_create(g_sp_page, int(wxID_ANY(), c_int), &
            "wxSpinCtrl", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(right, lab, 0, int(wxALL(), c_int), db)
        g_sp_spinctrl = wx_spin_ctrl_create(g_sp_page, &
            int(ID_PAGE_BASE + SP_SPINCTRL, c_int), "0", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, int(wxALIGN_RIGHT(), c_long), 0_c_int, &
            10_c_int, 0_c_int)
        call add_win(right, g_sp_spinctrl, 0, int(wxALL(), c_int), db)

        lab = wx_static_text_create(g_sp_page, int(wxID_ANY(), c_int), &
            "wxSpinCtrlDouble", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(right, lab, 0, int(wxALL(), c_int), db)
        g_sp_spinctrldbl = wx_spin_ctrl_double_create(g_sp_page, &
            int(ID_PAGE_BASE + SP_SPINCTRLDOUBLE, c_int), "0", -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, 0_c_int, 0.0_c_double, &
            10.0_c_double, 0.0_c_double, 0.1_c_double)
        call add_win(right, g_sp_spinctrldbl, 0, int(wxALL(), c_int), db)
        call add_sz(top, right, 1, ior(int(wxEXPAND(), c_int), &
            int(wxALL(), c_int)), db)

        call wx_window_fit_inside(g_sp_page)
    end subroutine build_spin_page

    ! ------------------------------------------------------------------
    ! ToggleButton page
    ! ------------------------------------------------------------------
    subroutine build_toggle_page()
        type(wxBoxSizer_t) :: top, right
        type(wxStaticBoxSizer_t) :: sl, sm, sbmp
        type(wxStaticBox_t) :: bl, bm, bbmp
        type(wxRadioBox_t) :: rpos, rhalign, rvalign
        character(len=4) :: ipos(4)
        character(len=6) :: halign(3), valign(3)

        g_tg_page = wx_scrolled_window_create(g_book, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(int(wxCLIP_CHILDREN(), c_int), int(wxTAB_TRAVERSAL(), c_int)))
        top = wx_box_sizer_create(int(wxHORIZONTAL(), c_int))
        call wx_window_set_sizer(g_tg_page, top, .false.)
        call wx_scrolled_window_set_scroll_rate(g_tg_page, 10_c_int, 10_c_int)

        call make_static_box(g_tg_page, "Styles", bl, sl, &
            int(wxVERTICAL(), c_int))
        call add_check(sl, bl, int(ID_PAGE_BASE + TG_BITMAP_ONLY, c_int), &
            "&Bitmap only", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + TG_TEXT_AND_BITMAP, c_int), &
            "Text &and bitmap", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + TG_MARKUP, c_int), &
            "Interpret &markup", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + TG_FIT, c_int), &
            "&Fit exactly", 1)
        call add_check(sl, bl, int(ID_PAGE_BASE + TG_DISABLE, c_int), &
            "Disable", 0)
        call add_check(sl, bl, int(ID_PAGE_BASE + TG_USE_BITMAP, c_int), &
            "Use wxBitmapToggleButton", 1)

        call make_static_box(g_tg_page, &
            "&Use the following bitmaps in addition to the normal one?", bbmp, sbmp, &
            int(wxVERTICAL(), c_int))
        call add_check(sbmp, bbmp, int(ID_PAGE_BASE + TG_USE_PRESSED, c_int), &
            "&Pressed (small help icon)", 1)
        call add_check(sbmp, bbmp, int(ID_PAGE_BASE + TG_USE_FOCUSED, c_int), &
            "&Focused (small error icon)", 1)
        call add_check(sbmp, bbmp, int(ID_PAGE_BASE + TG_USE_CURRENT, c_int), &
            "&Current (small warning icon)", 1)
        call add_check(sbmp, bbmp, int(ID_PAGE_BASE + TG_USE_DISABLED, c_int), &
            "&Disabled (broken image icon)", 1)
        call add_sz(sl, sbmp, 0, int(wxALL(), c_int), db)

        ipos = [character(len=4) :: "left", "right", "top", "bottom"]
        rpos = wx_radio_box_create(bl, int(ID_PAGE_BASE + TG_IMAGEPOS, c_int), &
            "Image &position", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ipos, 1_c_int, int(wxRA_SPECIFY_COLS(), c_int))
        call add_win(sl, rpos, 0, int(wxALL(), c_int), db)
        halign = [character(len=6) :: "left", "centre", "right"]
        rhalign = wx_radio_box_create(bl, int(ID_PAGE_BASE + TG_HALIGN, c_int), &
            "&Horz alignment", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            halign, 3_c_int, int(wxRA_SPECIFY_COLS(), c_int))
        call wx_radio_box_set_selection(rhalign, 1_c_int)
        call add_win(sl, rhalign, 0, int(wxALL(), c_int), db)
        valign = [character(len=6) :: "top", "centre", "bottom"]
        rvalign = wx_radio_box_create(bl, int(ID_PAGE_BASE + TG_VALIGN, c_int), &
            "&Vert alignment", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            valign, 3_c_int, int(wxRA_SPECIFY_COLS(), c_int))
        call wx_radio_box_set_selection(rvalign, 1_c_int)
        call add_win(sl, rvalign, 0, int(wxALL(), c_int), db)
        btn = wx_button_create(bl, int(ID_PAGE_BASE + TG_RESET, c_int), &
            "&Reset", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sl, btn, 0, int(wxALL(), c_int), db)
        call add_sz(top, sl, 0, int(wxALL(), c_int), db)

        call make_static_box(g_tg_page, "&Operations", bm, sm, &
            int(wxVERTICAL(), c_int))
        btn = wx_button_create(bm, int(ID_PAGE_BASE + TG_CHANGELABEL, c_int), &
            "Change label", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sm, btn, 0, int(wxALL(), c_int), db)
        g_tg_label_text = wx_text_ctrl_create(bm, &
            int(ID_PAGE_BASE + TG_LABELTEXT, c_int), "&Toggle me!", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sm, g_tg_label_text, 0, int(wxALL(), c_int), db)
        call add_sz(top, sm, 0, int(wxALL(), c_int), db)

        right = wx_box_sizer_create(int(wxVERTICAL(), c_int))
        g_tg_toggle = wx_toggle_button_create(g_tg_page, &
            int(ID_PAGE_BASE + TG_PICKER, c_int), "&Toggle me!", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(right, g_tg_toggle, 1, ior(int(wxEXPAND(), c_int), &
            int(wxALL(), c_int)), db)
        call add_sz(top, right, 1, ior(int(wxEXPAND(), c_int), &
            int(wxALL(), c_int)), db)

        call wx_window_fit_inside(g_tg_page)
    end subroutine build_toggle_page

    ! ------------------------------------------------------------------
    ! Small builders
    ! ------------------------------------------------------------------
    subroutine add_check(sz, parent, id, text, checked)
        class(wxSizer_t), intent(in) :: sz
        class(wxWindow_t), intent(in) :: parent
        integer, intent(in) :: id
        character(len=*), intent(in) :: text
        integer, intent(in) :: checked
        type(wxCheckBox_t) :: chk

        chk = wx_check_box_create(parent, int(id, c_int), text, -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (checked /= 0) call wx_check_box_set_value(chk, 1_c_int)
        call add_win(sz, chk, 0, int(wxALL(), c_int), db)
    end subroutine add_check

    subroutine add_text_row(sz, parent, label, id, value, readonly, txt_out)
        class(wxSizer_t), intent(in) :: sz
        class(wxWindow_t), intent(in) :: parent
        character(len=*), intent(in) :: label
        integer, intent(in) :: id
        character(len=*), intent(in) :: value
        integer, intent(in) :: readonly
        type(wxTextCtrl_t), intent(out) :: txt_out
        type(wxStaticText_t) :: lab
        integer(c_long) :: style

        lab = wx_static_text_create(parent, int(wxID_ANY(), c_int), label, &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sz, lab, 0, int(wxALL(), c_int), db)
        style = 0_c_long
        if (readonly /= 0) style = int(wxTE_READONLY(), c_long)
        txt_out = wx_text_ctrl_create(parent, int(id, c_int), value, -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, style)
        call add_win(sz, txt_out, 0, int(wxALL(), c_int), db)
    end subroutine add_text_row

    subroutine add_button_row(sz, parent, id, label, text_id, value, txt_out)
        class(wxSizer_t), intent(in) :: sz
        class(wxWindow_t), intent(in) :: parent
        integer, intent(in) :: id, text_id
        character(len=*), intent(in) :: label, value
        type(wxTextCtrl_t), intent(out) :: txt_out
        type(wxButton_t) :: b

        b = wx_button_create(parent, int(id, c_int), label, -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sz, b, 0, int(wxALL(), c_int), db)
        txt_out = wx_text_ctrl_create(parent, int(text_id, c_int), value, &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sz, txt_out, 0, int(wxALL(), c_int), db)
    end subroutine add_button_row

    subroutine add_button_row2(sz, parent, id, label, t1_id, v1, t2_id, v2, &
        t1_out, t2_out)
        class(wxSizer_t), intent(in) :: sz
        class(wxWindow_t), intent(in) :: parent
        integer, intent(in) :: id, t1_id, t2_id
        character(len=*), intent(in) :: label, v1, v2
        type(wxTextCtrl_t), intent(out) :: t1_out, t2_out
        type(wxButton_t) :: b

        b = wx_button_create(parent, int(id, c_int), label, -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_win(sz, b, 0, int(wxALL(), c_int), db)
        t1_out = wx_text_ctrl_create(parent, int(t1_id, c_int), v1, &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sz, t1_out, 0, int(wxALL(), c_int), db)
        t2_out = wx_text_ctrl_create(parent, int(t2_id, c_int), v2, &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call add_win(sz, t2_out, 0, int(wxALL(), c_int), db)
    end subroutine add_button_row2

    ! ------------------------------------------------------------------
    ! Event connections
    ! ------------------------------------------------------------------
    subroutine connect_events()
        integer :: palo, pahi

        palo = ID_PAGE_BASE
        pahi = ID_PAGE_BASE + 60

        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, id=ID_CLEAR_LOG)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, id=ID_QUIT)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, &
            id=ID_SET_TOOLTIP)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, id=ID_SET_FG)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, id=ID_SET_BG)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, id=ID_SET_PAGE_BG)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, id=ID_SET_FONT)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, id=ID_ENABLE)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, id=ID_SHOW)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, &
            id=ID_BORDER_NONE, last_id=ID_BORDER_DEFAULT)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, &
            id=ID_VARIANT_NORMAL, last_id=ID_VARIANT_LARGE)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, &
            id=ID_LAYOUT_DIRECTION)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, id=ID_GLOBAL_BUSY)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, id=ID_BUSY)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, &
            id=ID_TEXT_BEGIN, last_id=ID_TEXT_END - 1)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, &
            id=ID_THEME_LIGHT, last_id=ID_THEME_SYSTEM)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, &
            id=ID_GOTO_PAGE, last_id=ID_GOTO_PAGE + 99)
        call wx_connect(g_frame, int(wxEVT_MENU(), c_int), on_menu, &
            id=int(wxID_EXIT(), c_int))
        call wx_connect(g_frame, int(wxEVT_BUTTON(), c_int), on_menu, id=ID_CLEAR_LOG)
        call wx_connect(g_frame, int(wxEVT_BUTTON(), c_int), on_menu, id=ID_QUIT)

        call wx_connect(g_book, int(wxEVT_TREEBOOK_PAGE_CHANGED(), c_int), &
            on_page_changed)
        call wx_connect(g_book, int(wxEVT_TREEBOOK_PAGE_CHANGING(), c_int), &
            on_page_changing)

        call wx_connect(g_ai_page, int(wxEVT_BUTTON(), c_int), on_ai, &
            id=palo, last_id=pahi)

        call wx_connect(g_btn_page, int(wxEVT_BUTTON(), c_int), on_button, &
            id=palo, last_id=pahi)
        call wx_connect(g_btn_page, int(wxEVT_CHECKBOX(), c_int), on_button, &
            id=palo, last_id=pahi)
        call wx_connect(g_btn_page, int(wxEVT_RADIOBOX(), c_int), on_button, &
            id=palo, last_id=pahi)

        call wx_connect(g_cb_page, int(wxEVT_BUTTON(), c_int), on_checkbox, &
            id=palo, last_id=pahi)
        call wx_connect(g_cb_page, int(wxEVT_CHECKBOX(), c_int), on_checkbox, &
            id=palo, last_id=pahi)
        call wx_connect(g_cb_page, int(wxEVT_RADIOBOX(), c_int), on_checkbox, &
            id=palo, last_id=pahi)

        call wx_connect(g_ch_page, int(wxEVT_BUTTON(), c_int), on_choice, &
            id=palo, last_id=pahi)
        call wx_connect(g_ch_page, int(wxEVT_TEXT_ENTER(), c_int), on_choice, &
            id=palo, last_id=pahi)
        call wx_connect(g_ch_page, int(wxEVT_CHOICE(), c_int), on_choice, &
            id=palo, last_id=pahi)
        call wx_connect(g_ch_page, int(wxEVT_CHECKBOX(), c_int), on_choice, &
            id=palo, last_id=pahi)

        call wx_connect(g_ga_page, int(wxEVT_BUTTON(), c_int), on_gauge, &
            id=palo, last_id=pahi)
        call wx_connect(g_ga_page, int(wxEVT_TIMER(), c_int), on_gauge, &
            id=palo, last_id=pahi)
        call wx_connect(g_ga_page, int(wxEVT_CHECKBOX(), c_int), on_gauge, &
            id=palo, last_id=pahi)

        call wx_connect(g_hl_page, int(wxEVT_BUTTON(), c_int), on_hyperlink, &
            id=palo, last_id=pahi)
        call wx_connect(g_hl_page, int(wxEVT_RADIOBOX(), c_int), on_hyperlink, &
            id=palo, last_id=pahi)
        call wx_connect(g_hl_page, int(wxEVT_CHECKBOX(), c_int), on_hyperlink, &
            id=palo, last_id=pahi)

        call wx_connect(g_lb_page, int(wxEVT_BUTTON(), c_int), on_listbox, &
            id=palo, last_id=pahi)
        call wx_connect(g_lb_page, int(wxEVT_TEXT_ENTER(), c_int), on_listbox, &
            id=palo, last_id=pahi)
        call wx_connect(g_lb_page, int(wxEVT_LISTBOX(), c_int), on_listbox, &
            id=palo, last_id=pahi)
        call wx_connect(g_lb_page, int(wxEVT_LISTBOX_DCLICK(), c_int), on_listbox, &
            id=palo, last_id=pahi)
        call wx_connect(g_lb_page, int(wxEVT_CHECKBOX(), c_int), on_listbox, &
            id=palo, last_id=pahi)
        call wx_connect(g_lb_page, int(wxEVT_RADIOBOX(), c_int), on_listbox, &
            id=palo, last_id=pahi)

        call wx_connect(g_sl_page, int(wxEVT_BUTTON(), c_int), on_slider, &
            id=palo, last_id=pahi)
        call wx_connect(g_sl_page, int(wxEVT_SLIDER(), c_int), on_slider, &
            id=palo, last_id=pahi)
        call wx_connect(g_sl_page, int(wxEVT_CHECKBOX(), c_int), on_slider, &
            id=palo, last_id=pahi)
        call wx_connect(g_sl_page, int(wxEVT_RADIOBOX(), c_int), on_slider, &
            id=palo, last_id=pahi)

        call wx_connect(g_sp_page, int(wxEVT_BUTTON(), c_int), on_spin, &
            id=palo, last_id=pahi)
        call wx_connect(g_sp_page, int(wxEVT_SPIN(), c_int), on_spin, &
            id=palo, last_id=pahi)
        call wx_connect(g_sp_page, int(wxEVT_SPINCTRL(), c_int), on_spin, &
            id=palo, last_id=pahi)
        call wx_connect(g_sp_page, int(wxEVT_SPINCTRLDOUBLE(), c_int), on_spin, &
            id=palo, last_id=pahi)
        call wx_connect(g_sp_page, int(wxEVT_TEXT(), c_int), on_spin, &
            id=palo, last_id=pahi)
        call wx_connect(g_sp_page, int(wxEVT_TEXT_ENTER(), c_int), on_spin, &
            id=palo, last_id=pahi)
        call wx_connect(g_sp_page, int(wxEVT_CHECKBOX(), c_int), on_spin, &
            id=palo, last_id=pahi)
        call wx_connect(g_sp_page, int(wxEVT_RADIOBOX(), c_int), on_spin, &
            id=palo, last_id=pahi)

        call wx_connect(g_tg_page, int(wxEVT_BUTTON(), c_int), on_toggle, &
            id=palo, last_id=pahi)
        call wx_connect(g_tg_page, int(wxEVT_TOGGLEBUTTON(), c_int), on_toggle, &
            id=palo, last_id=pahi)
        call wx_connect(g_tg_page, int(wxEVT_CHECKBOX(), c_int), on_toggle, &
            id=palo, last_id=pahi)
        call wx_connect(g_tg_page, int(wxEVT_RADIOBOX(), c_int), on_toggle, &
            id=palo, last_id=pahi)
    end subroutine connect_events

end program widgets
