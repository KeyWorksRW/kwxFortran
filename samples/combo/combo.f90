! combo.f90 - wxComboCtrl and wxOwnerDrawnComboBox sample
!
! Fortran port of wxWidgets samples/src/combo/combo.cpp (kwxFortran).
!
! The frame shows owner-drawn combo boxes, a list-view wxComboCtrl with a custom
! popup animation, a tree-ctrl wxComboCtrl, custom drop-button bitmaps, and a
! wxComboCtrl with a custom button (file dialog) plus one with a check box as
! the main control.  The right column is a log text control that receives the
! EVT_TEXT / EVT_TEXT_ENTER / EVT_COMBOBOX notifications of every combo.
!
! Run the executable with the current directory set to this folder so the
! relative SVG paths resolve exactly like the C++ sample.

module combo_globals
    use, intrinsic :: iso_c_binding
    use kwx_types
    implicit none

    ! The common item list shared by every owner-drawn combo (m_arrItems).
    integer, parameter :: ITEM_COUNT = 12
    character(len=24), parameter :: item_texts(ITEM_COUNT) = [ character(len=24) :: &
        "Solid", &
        "Transparent", &
        "Dot", &
        "Long Dash", &
        "Short Dash", &
        "Dot Dash", &
        "Backward Diagonal Hatch", &
        "Cross-diagonal Hatch", &
        "Forward Diagonal Hatch", &
        "Cross Hatch", &
        "Horizontal Hatch", &
        "Vertical Hatch" ]

    ! Main frame and the log window of MyFrame.
    type(wxFrame_t), save :: g_frame
    type(wxTextCtrl_t), save :: g_logwin

    ! Controls whose callbacks refer back to the instance.
    type(kwxOwnerDrawnComboBox_t), save :: g_odc_left
    type(kwxOwnerDrawnComboBox_t), save :: g_odc_leftbutton
    type(kwxComboCtrl_t), save :: g_cc_list
    type(kwxComboCtrl_t), save :: g_cc_file
    type(kwxComboCtrl_t), save :: g_cc_check
    type(wxGenericComboCtrl_t), save :: g_gcc_tree
    type(wxOwnerDrawnComboBox_t), save :: g_odc_plain1
    type(wxOwnerDrawnComboBox_t), save :: g_odc_plain2

    ! Popups own their control and must outlive the event loop.
    type(kwxListViewComboPopup_t), save :: g_list_popup
    type(kwxListViewComboPopup_t), save :: g_list_popup_check
    type(kwxTreeCtrlComboPopup_t), save :: g_tree_popup

    ! Identity tags handed to kwxOwnerDrawnComboBox callbacks (m_object).
    integer(c_int), target, save :: g_tag_left = 1_c_int
    integer(c_int), target, save :: g_tag_leftbutton = 2_c_int

    ! Frame icon bundle; kept alive for the lifetime of the event loop.
    type(wxBitmapBundle_t), save :: g_icon_bundle

end module combo_globals


module combo_util
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_ANY
    use wx_text_ctrl, only: wx_text_ctrl_append_text
    use wx_static_text, only: wx_static_text_create
    use wx_sizer, only: wx_sizer_add_window, wx_sizer_add_sizer
    use wx_owner_drawn_combo_box, only: wx_owner_drawn_combo_box_append
    use wx_bitmap_bundle, only: wx_bitmap_bundle_is_ok
    use combo_globals, only: g_logwin, item_texts, ITEM_COUNT
    implicit none
    private

    public :: log_message, itoa, new_label, add_window, add_sizer
    public :: append_owner_items, bundle_is_ok

contains

    !--------------------------------------------------------------------------
    ! The C++ sample routes these through wxLogMessage()/wxLogTextCtrl.
    ! kwxFFI does not export wxLogMessage(), so the identical text is appended
    ! directly to the log text control (timestamps were disabled anyway).
    !--------------------------------------------------------------------------
    subroutine log_message(msg)
        character(len=*), intent(in) :: msg

        if (.not. g_logwin%is_valid()) return
        call wx_text_ctrl_append_text(g_logwin, msg // achar(10))
    end subroutine log_message

    function itoa(value) result(text)
        integer, intent(in) :: value
        character(len=:), allocatable :: text
        character(len=24) :: buffer

        write(buffer, '(I0)') value
        text = trim(buffer)
    end function itoa

    function new_label(parent, text) result(label)
        class(wxwindow_t), intent(in) :: parent
        character(len=*), intent(in) :: text
        type(wxStaticText_t) :: label

        label = wx_static_text_create(parent, wxID_ANY(), text, &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    end function new_label

    subroutine add_window(sizer, window, option, flags, border)
        class(wxSizer_t), intent(in) :: sizer
        class(wxWindow_t), intent(in) :: window
        integer(c_int), intent(in) :: option
        integer(c_int), intent(in) :: flags
        integer(c_int), intent(in) :: border

        call wx_sizer_add_window(sizer, window, option, flags, border, c_null_ptr)
    end subroutine add_window

    subroutine add_sizer(parent, child, option, flags, border)
        class(wxSizer_t), intent(in) :: parent
        class(wxSizer_t), intent(in) :: child
        integer(c_int), intent(in) :: option
        integer(c_int), intent(in) :: flags
        integer(c_int), intent(in) :: border

        call wx_sizer_add_sizer(parent, child, option, flags, border, c_null_ptr)
    end subroutine add_sizer

    ! Fill an owner-drawn combo with the shared item list (m_arrItems).
    subroutine append_owner_items(odc)
        class(wxOwnerDrawnComboBox_t), intent(in) :: odc
        integer :: i, rc

        if (.not. odc%is_valid()) return
        do i = 1, ITEM_COUNT
            rc = wx_owner_drawn_combo_box_append(odc, trim(item_texts(i)))
        end do
    end subroutine append_owner_items

    ! wxBitmapBundle_IsOk() does not accept a null pointer, and
    ! wxBitmapBundle::FromSVGFile() returns one for a missing file.
    function bundle_is_ok(bundle) result(ok)
        type(wxBitmapBundle_t), intent(in) :: bundle
        logical :: ok

        ok = .false.
        if (.not. c_associated(bundle%ptr)) return
        ok = wx_bitmap_bundle_is_ok(bundle)
    end function bundle_is_ok

end module combo_util


module combo_handlers
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_string, only: to_wxstring, from_wxstring
    use wx_events, only: wx_event_get_id, wx_event_get_type, wx_event_skip, &
        wx_command_event_get_selection, wx_command_event_get_string
    use wx_window, only: wx_window_close, wx_window_destroy, wx_window_set_size, &
        wx_window_raise, wx_window_show_with_effect, wx_window_get_font, &
        wx_window_set_font, wx_window_centre, wx_window_enable, &
        wx_window_from_dip, wx_window_set_sizer, wx_window_has_flag
    use wx_dialog, only: wx_dialog_create, wx_dialog_show_modal
    use wx_file_dialog, only: wx_file_dialog_create, wx_file_dialog_get_path
    use wx_dc, only: wx_dc_set_pen, wx_dc_set_brush, wx_dc_draw_text, &
        wx_dc_draw_line, wx_dc_draw_rectangle, wx_dc_get_char_height
    use wx_rect, only: wx_rect_get_x, wx_rect_get_y, wx_rect_get_width, &
        wx_rect_get_height
    use wx_pen, only: wx_pen_create_from_colour, wx_pen_delete
    use wx_brush, only: wx_brush_create_from_colour, wx_brush_delete
    use wx_colour, only: wx_colour_create_from_int, wx_colour_delete
    use wx_system_settings, only: wx_system_settings_select_light_dark
    use wx_object, only: wx_object_is_kind_of
    use wx_class_info, only: wx_class_info_find_class
    use wx_combo_ctrl, only: wx_combo_ctrl_get_value, wx_combo_ctrl_set_value, &
        wx_combo_ctrl_set_text, wx_combo_ctrl_set_margins, &
        wx_combo_ctrl_prepare_background, wx_combo_ctrl_get_popup_window
    use wx_owner_drawn_combo_box, only: wx_owner_drawn_combo_box_create, &
        wx_owner_drawn_combo_box_append
    use wx_combo_box, only: wx_combo_box_create, wx_combo_box_set_value, &
        wx_combo_box_append, wx_combo_box_set_margins
    use wx_static_box, only: wx_static_box_create
    use wx_static_box_sizer, only: wx_static_box_sizer_create
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add_stretch_spacer, wx_sizer_set_size_hints
    use wx_font, only: wx_font_create_default, wx_font_scaled, wx_font_delete
    use wx_free_functions, only: kwx_system_settings_get_colour
    use wx_app, only: wx_get_os_description
    use combo_globals
    use combo_util
    implicit none
    private

    public :: on_combo_event, on_compare, on_quit, on_about, on_idle
    public :: on_draw_item, on_draw_background, on_measure_item
    public :: on_measure_item_width, on_anim_show
    public :: on_file_button_click, on_file_popup_control

contains

    !--------------------------------------------------------------------------
    ! wxPenStyleComboBox::OnDrawItem
    !--------------------------------------------------------------------------
    subroutine on_draw_item(pobject, dcptr, rectptr, item, flags) bind(C)
        type(c_ptr), value :: pobject, dcptr, rectptr
        integer(c_int), value :: item, flags

        type(wxDC_t) :: dc
        type(wxRect_t) :: rect
        type(wxColour_t) :: colour
        type(wxPen_t) :: pen
        integer(c_int) :: penstyle, x, y, width, height, charheight
        character(len=:), allocatable :: text

        if (.not. c_associated(dcptr)) return
        if (.not. c_associated(rectptr)) return
        if (item == wxNOT_FOUND()) return
        if (item < 0 .or. item >= ITEM_COUNT) return

        rect%ptr = rectptr
        rect%owned = .false.

        ! wxRect r(rect); r.Deflate(3); r.height -= 2;
        x = wx_rect_get_x(rect) + 3_c_int
        y = wx_rect_get_y(rect) + 3_c_int
        width = wx_rect_get_width(rect) - 6_c_int
        height = wx_rect_get_height(rect) - 6_c_int - 2_c_int

        select case (item)
        case (1_c_int)
            penstyle = wxPENSTYLE_TRANSPARENT()
        case (2_c_int)
            penstyle = wxPENSTYLE_DOT()
        case (3_c_int)
            penstyle = wxPENSTYLE_LONG_DASH()
        case (4_c_int)
            penstyle = wxPENSTYLE_SHORT_DASH()
        case (5_c_int)
            penstyle = wxPENSTYLE_DOT_DASH()
        case (6_c_int)
            penstyle = wxPENSTYLE_BDIAGONAL_HATCH()
        case (7_c_int)
            penstyle = wxPENSTYLE_CROSSDIAG_HATCH()
        case (8_c_int)
            penstyle = wxPENSTYLE_FDIAGONAL_HATCH()
        case (9_c_int)
            penstyle = wxPENSTYLE_CROSS_HATCH()
        case (10_c_int)
            penstyle = wxPENSTYLE_HORIZONTAL_HATCH()
        case (11_c_int)
            penstyle = wxPENSTYLE_VERTICAL_HATCH()
        case default
            penstyle = wxPENSTYLE_SOLID()
        end select

        colour = kwx_system_settings_get_colour(wxSYS_COLOUR_WINDOWTEXT())
        colour%owned = .true.   ! kwxFFI returns a new wxColour
        pen = wx_pen_create_from_colour(colour, 3_c_int, penstyle)

        dc%ptr = dcptr
        dc%owned = .false.
        call wx_dc_set_pen(dc, pen)

        if (iand(flags, wxODCB_PAINTING_CONTROL()) == 0) then
            text = trim(item_texts(item + 1))
            charheight = wx_dc_get_char_height(dc)
            call wx_dc_draw_text(dc, text, x + 3_c_int, &
                y + (height / 2_c_int - charheight) / 2_c_int)
            call wx_dc_draw_line(dc, x + 5_c_int, y + (height / 4_c_int) * 3_c_int, &
                x + width - 5_c_int, y + (height / 4_c_int) * 3_c_int)
        else
            call wx_dc_draw_line(dc, x + 5_c_int, y + height / 2_c_int, &
                x + width - 5_c_int, y + height / 2_c_int)
        end if

        call wx_pen_delete(pen)
        call wx_colour_delete(colour)
    end subroutine on_draw_item

    !--------------------------------------------------------------------------
    ! wxPenStyleComboBox::OnDrawBackground
    !--------------------------------------------------------------------------
    subroutine on_draw_background(pobject, dcptr, rectptr, item, flags) bind(C)
        type(c_ptr), value :: pobject, dcptr, rectptr
        integer(c_int), value :: item, flags

        type(wxDC_t) :: dc
        type(wxRect_t) :: rect
        type(wxColour_t) :: light, dark, background
        type(wxBrush_t) :: brush
        type(wxPen_t) :: pen
        integer(c_int) :: bgflags

        if (.not. c_associated(dcptr)) return
        if (.not. c_associated(rectptr)) return

        ! wxOwnerDrawnComboBox::OnDrawBackground: a selected popup item and the
        ! read-only control itself paint PrepareBackground(); every other item
        ! uses the alternating row colour drawn below.
        if (iand(flags, wxODCB_PAINTING_SELECTED()) /= 0 .or. &
            (iand(flags, wxODCB_PAINTING_CONTROL()) /= 0 .and. &
             read_only_combo(pobject))) then
            bgflags = wxCONTROL_SELECTED()
            if (iand(flags, wxODCB_PAINTING_CONTROL()) == 0) then
                bgflags = ior(bgflags, wxCONTROL_ISSUBMENU())
            end if
            rect%ptr = rectptr
            rect%owned = .false.
            dc%ptr = dcptr
            dc%owned = .false.
            if (c_associated(pobject, c_loc(g_tag_leftbutton))) then
                call wx_combo_ctrl_prepare_background(g_odc_leftbutton, dc, &
                    wx_rect_get_x(rect), wx_rect_get_y(rect), &
                    wx_rect_get_width(rect), wx_rect_get_height(rect), bgflags)
            else
                call wx_combo_ctrl_prepare_background(g_odc_left, dc, &
                    wx_rect_get_x(rect), wx_rect_get_y(rect), &
                    wx_rect_get_width(rect), wx_rect_get_height(rect), bgflags)
            end if
            return
        end if

        ! Even rows keep the default rendering.
        if (iand(item, 1_c_int) == 0) return

        ! Draw every other background with a different colour.
        light = wx_colour_create_from_int(int(z'F0F0FA', c_int))
        dark = wx_colour_create_from_int(int(z'303040', c_int))
        background = wx_system_settings_select_light_dark(light, dark)
        background%owned = .true.   ! kwxFFI returns a new wxColour

        brush = wx_brush_create_from_colour(background, wxBRUSHSTYLE_SOLID())
        pen = wx_pen_create_from_colour(background, 1_c_int, wxPENSTYLE_SOLID())

        rect%ptr = rectptr
        rect%owned = .false.
        dc%ptr = dcptr
        dc%owned = .false.

        call wx_dc_set_brush(dc, brush)
        call wx_dc_set_pen(dc, pen)
        call wx_dc_draw_rectangle(dc, wx_rect_get_x(rect), wx_rect_get_y(rect), &
            wx_rect_get_width(rect), wx_rect_get_height(rect))

        call wx_pen_delete(pen)
        call wx_brush_delete(brush)
        call wx_colour_delete(background)
        call wx_colour_delete(light)
        call wx_colour_delete(dark)
    end subroutine on_draw_background

    !--------------------------------------------------------------------------
    ! HasFlag(wxCB_READONLY) for the combo the callback belongs to.
    !--------------------------------------------------------------------------
    function read_only_combo(pobject) result(ok)
        type(c_ptr), intent(in) :: pobject
        logical :: ok

        if (c_associated(pobject, c_loc(g_tag_leftbutton))) then
            ok = wx_window_has_flag(g_odc_leftbutton, wxCB_READONLY())
        else
            ok = wx_window_has_flag(g_odc_left, wxCB_READONLY())
        end if
    end function read_only_combo

    !--------------------------------------------------------------------------
    ! wxPenStyleComboBox::OnMeasureItem / OnMeasureItemWidth
    !--------------------------------------------------------------------------
    function on_measure_item(pobject, item) result(measured) bind(C)
        type(c_ptr), value :: pobject
        integer(c_size_t), value :: item
        integer(c_int) :: measured

        if (iand(item, 1_c_size_t) /= 0_c_size_t) then
            measured = wx_window_from_dip(g_odc_left, 36_c_int)
        else
            measured = wx_window_from_dip(g_odc_left, 24_c_int)
        end if
    end function on_measure_item

    function on_measure_item_width(pobject, item) result(measured) bind(C)
        type(c_ptr), value :: pobject
        integer(c_size_t), value :: item
        integer(c_int) :: measured

        measured = -1_c_int
    end function on_measure_item_width

    !--------------------------------------------------------------------------
    ! wxComboCtrlWithCustomPopupAnim::AnimateShow
    !--------------------------------------------------------------------------
    function on_anim_show(pobject, x, y, width, height, flags) result(finished) bind(C)
        type(c_ptr), value :: pobject
        integer(c_int), value :: x, y, width, height, flags
        integer(c_int) :: finished

        type(c_ptr) :: popup_window
        type(wxWindow_t) :: window
        logical :: shown

        finished = 0_c_int
        popup_window = wx_combo_ctrl_get_popup_window(g_cc_list)
        if (.not. c_associated(popup_window)) return

        window = wxwindow_from_ptr(popup_window, .false.)
        call wx_window_set_size(window, x, y, width, height, wxSIZE_AUTO())
        call wx_window_raise(window)
        shown = wx_window_show_with_effect(window, wxSHOW_EFFECT_BLEND(), 0_c_int)
        finished = 1_c_int
    end function on_anim_show

    !--------------------------------------------------------------------------
    ! wxFileSelectorCombo::OnButtonClick
    !--------------------------------------------------------------------------
    subroutine on_file_button_click(pobject) bind(C)
        type(c_ptr), value :: pobject

        type(wxFileDialog_t) :: dialog
        character(len=:), allocatable :: value, path
        integer(c_int) :: result
        logical :: destroyed

        value = wx_combo_ctrl_get_value(g_cc_file)
        dialog = wx_file_dialog_create(g_cc_file, "Choose File", "", value, &
            "All files (*.*)|*.*", -1_c_int, -1_c_int, wxFD_OPEN(), &
            -1_c_int, -1_c_int)
        if (.not. dialog%is_valid()) return

        result = wx_dialog_show_modal(dialog)
        if (result == wxID_OK()) then
            path = wx_file_dialog_get_path(dialog)
            call wx_combo_ctrl_set_value(g_cc_file, path)
        end if
        destroyed = wx_window_destroy(dialog)
    end subroutine on_file_button_click

    !--------------------------------------------------------------------------
    ! wxFileSelectorCombo::DoSetPopupControl (deliberately empty)
    !--------------------------------------------------------------------------
    subroutine on_file_popup_control(pobject, popup) bind(C)
        type(c_ptr), value :: pobject, popup
    end subroutine on_file_popup_control

    !--------------------------------------------------------------------------
    ! MyFrame::OnComboBoxUpdate (EVT_TEXT / EVT_TEXT_ENTER / EVT_COMBOBOX)
    !--------------------------------------------------------------------------
    subroutine on_combo_event(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        type(c_ptr) :: event_object
        type(wxObject_t) :: event_obj
        type(wxClassInfo_t) :: combo_class
        integer :: etype, id, selection
        character(len=:), allocatable :: text

        if (.not. c_associated(evt)) return

        ! Don't show messages for the log output window (it'll crash): only
        ! wxComboCtrl events are logged, exactly as in the C++ handler.
        event_object = wxEvent_GetEventObject(evt)
        if (.not. c_associated(event_object)) return
        event_obj = wxobject_from_ptr(event_object, .false.)
        combo_class = wx_class_info_find_class("wxComboCtrl")
        if (.not. c_associated(combo_class%ptr)) return
        if (.not. wx_object_is_kind_of(event_obj, combo_class)) return

        etype = wx_event_get_type(evt)
        id = wx_event_get_id(evt)

        if (etype == wxEVT_COMBOBOX()) then
            selection = wx_command_event_get_selection(evt)
            call log_message("EVT_COMBOBOX(id=" // itoa(id) // &
                ",selection=" // itoa(selection) // ")")
        else if (etype == wxEVT_TEXT()) then
            text = wx_command_event_get_string(evt)
            call log_message('EVT_TEXT(id=' // itoa(id) // ',string="' // text // '")')
        else if (etype == wxEVT_TEXT_ENTER()) then
            text = wx_command_event_get_string(evt)
            call log_message('EVT_TEXT_ENTER(id=' // itoa(id) // ',string="' // &
                text // '")')
        end if
    end subroutine on_combo_event

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
    ! MyFrame::OnAbout
    !--------------------------------------------------------------------------
    subroutine on_about(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        type(c_ptr) :: version_ptr, message_ptr, caption_ptr
        character(len=:), allocatable :: version, osdesc, message
        integer(c_int) :: result

        if (.not. c_associated(evt)) return

        version_ptr = wxVersionString()
        if (c_associated(version_ptr)) then
            version = from_wxstring(version_ptr)
            call wxString_Delete(version_ptr)
        else
            version = ""
        end if
        osdesc = wx_get_os_description()

        message = "Welcome to " // version // "!" // achar(10) // &
            achar(10) // &
            "This is the wxWidgets wxComboCtrl and wxOwnerDrawnComboBox sample" // &
            achar(10) // &
            "running under " // osdesc // "."

        message_ptr = to_wxstring(message)
        caption_ptr = to_wxstring("About wxComboCtrl sample")
        result = kwxMessageBox(message_ptr, caption_ptr, &
            ior(wxOK(), wxICON_INFORMATION()), g_frame%ptr, -1_c_int, -1_c_int)
        call wxString_Delete(message_ptr)
        call wxString_Delete(caption_ptr)
    end subroutine on_about

    !--------------------------------------------------------------------------
    ! MyFrame::OnIdle -- event.Skip()
    !--------------------------------------------------------------------------
    subroutine on_idle(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call wx_event_skip(evt)
    end subroutine on_idle

    !--------------------------------------------------------------------------
    ! MyFrame::OnShowComparison -- modal comparison dialog
    !--------------------------------------------------------------------------
    subroutine on_compare(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        type(wxDialog_t) :: dialog
        type(wxBoxSizer_t) :: colsizer, rowsizer
        type(wxStaticBox_t) :: box
        type(wxStaticBoxSizer_t) :: group
        type(wxOwnerDrawnComboBox_t) :: odc
        type(wxComboBox_t) :: cb
        type(wxFont_t) :: font, bigfont
        integer(c_int) :: bdef, rc
        logical :: ok

        if (.not. c_associated(evt)) return

        bdef = wx_window_from_dip(g_frame, 5_c_int)

        dialog = wx_dialog_create(g_frame, wxID_ANY(), "Compare against wxComboBox", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            ior(wxDEFAULT_DIALOG_STYLE(), wxRESIZE_BORDER()))
        if (.not. dialog%is_valid()) return

        colsizer = wx_box_sizer_create(wxVERTICAL())
        rowsizer = wx_box_sizer_create(wxHORIZONTAL())

        !----------------------------------------------------------------------
        ! " wxOwnerDrawnComboBox " group
        !----------------------------------------------------------------------
        box = wx_static_box_create(dialog, wxID_ANY(), " wxOwnerDrawnComboBox ", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        group = wx_static_box_sizer_create(box, wxVERTICAL())

        call add_window(group, new_label(box, "Writable, with margins, sorted:"), &
            0_c_int, ior(wxEXPAND(), wxRIGHT()), bdef)
        odc = new_odc(box, int(wxCB_SORT(), c_long))
        rc = wx_owner_drawn_combo_box_append(odc, "H - Appended Item")
        call wx_combo_ctrl_set_value(odc, "Dot Dash")
        call wx_combo_ctrl_set_margins(odc, 15_c_int, 10_c_int)
        call add_window(group, odc, 0_c_int, wxALL(), bdef)
        call wx_sizer_add_stretch_spacer(group, 1_c_int)

        call add_window(group, new_label(box, "Read-only, big font:"), &
            0_c_int, wxRIGHT(), bdef)
        odc = new_odc(box, int(ior(wxCB_SORT(), wxCB_READONLY()), c_long))
        font = wx_font_create_default()
        call wx_window_get_font(odc, font)
        bigfont = wx_font_scaled(font, 1.5_c_float)
        bigfont%owned = .true.   ! kwxFFI returns a new wxFont
        ok = wx_window_set_font(odc, bigfont)
        call wx_font_delete(bigfont)
        call wx_font_delete(font)
        call wx_combo_ctrl_set_value(odc, "Dot Dash")
        call wx_combo_ctrl_set_text(odc, "Dot Dash (Testing SetText)")
        call add_window(group, odc, 0_c_int, wxALL(), bdef)
        call wx_sizer_add_stretch_spacer(group, 1_c_int)

        call add_window(group, new_label(box, "Read-only disabled:"), &
            0_c_int, wxRIGHT(), bdef)
        odc = new_odc(box, int(wxCB_READONLY(), c_long))
        call wx_combo_ctrl_set_value(odc, "Dot Dash")
        ok = wx_window_enable(odc, .false.)
        call add_window(group, odc, 3_c_int, ior(wxEXPAND(), wxALL()), bdef)

        call add_window(group, new_label(box, "Disabled:"), &
            0_c_int, wxRIGHT(), bdef)
        odc = new_odc(box, 0_c_long)
        call wx_combo_ctrl_set_value(odc, "Dot Dash")
        ok = wx_window_enable(odc, .false.)
        call add_window(group, odc, 3_c_int, ior(wxEXPAND(), wxALL()), bdef)

        call add_sizer(rowsizer, group, 1_c_int, ior(wxEXPAND(), wxALL()), bdef)

        !----------------------------------------------------------------------
        ! " wxComboBox " group
        !----------------------------------------------------------------------
        box = wx_static_box_create(dialog, wxID_ANY(), " wxComboBox ", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        group = wx_static_box_sizer_create(box, wxVERTICAL())

        call add_window(group, new_label(box, "Writable, with margins, sorted:"), &
            0_c_int, ior(wxEXPAND(), wxRIGHT()), bdef)
        cb = wx_combo_box_create(box, wxID_ANY(), "", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, item_texts, wxCB_SORT())
        call wx_combo_box_append(cb, "H - Appended Item")
        call wx_combo_box_set_value(cb, "Dot Dash")
        ok = wx_combo_box_set_margins(cb, 15_c_int, 10_c_int)
        call add_window(group, cb, 0_c_int, wxALL(), bdef)
        call wx_sizer_add_stretch_spacer(group, 1_c_int)

        call add_window(group, new_label(box, "Read-only, big font:"), &
            0_c_int, wxRIGHT(), bdef)
        cb = wx_combo_box_create(box, wxID_ANY(), "", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, item_texts, ior(wxCB_SORT(), wxCB_READONLY()))
        font = wx_font_create_default()
        call wx_window_get_font(cb, font)
        bigfont = wx_font_scaled(font, 1.5_c_float)
        bigfont%owned = .true.   ! kwxFFI returns a new wxFont
        ok = wx_window_set_font(cb, bigfont)
        call wx_font_delete(bigfont)
        call wx_font_delete(font)
        call wx_combo_box_set_value(cb, "Dot Dash")
        call add_window(group, cb, 0_c_int, wxALL(), bdef)
        call wx_sizer_add_stretch_spacer(group, 1_c_int)

        call add_window(group, new_label(box, "Read-only disabled:"), &
            0_c_int, wxRIGHT(), bdef)
        cb = wx_combo_box_create(box, wxID_ANY(), "", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, item_texts, wxCB_READONLY())
        call wx_combo_box_set_value(cb, "Dot Dash")
        ok = wx_window_enable(cb, .false.)
        call add_window(group, cb, 3_c_int, ior(wxEXPAND(), wxALL()), bdef)

        call add_window(group, new_label(box, "Disabled:"), &
            0_c_int, wxRIGHT(), bdef)
        cb = wx_combo_box_create(box, wxID_ANY(), "", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, item_texts, 0_c_int)
        call wx_combo_box_set_value(cb, "Dot Dash")
        ok = wx_window_enable(cb, .false.)
        call add_window(group, cb, 3_c_int, ior(wxEXPAND(), wxALL()), bdef)

        call add_sizer(rowsizer, group, 1_c_int, ior(wxEXPAND(), wxALL()), bdef)

        !----------------------------------------------------------------------
        call add_sizer(colsizer, rowsizer, 1_c_int, ior(wxEXPAND(), wxALL()), bdef)
        call wx_window_set_sizer(dialog, colsizer, .false.)
        call wx_sizer_set_size_hints(colsizer, dialog)
        call wx_window_set_size(dialog, -1_c_int, -1_c_int, 60_c_int, 240_c_int, &
            wxSIZE_AUTO())
        call wx_window_centre(dialog, wxBOTH())
        rc = wx_dialog_show_modal(dialog)
        ! The C++ sample never deletes this dialog.
    end subroutine on_compare

    ! Plain wxOwnerDrawnComboBox created with the shared item list.
    function new_odc(parent, style) result(odc)
        class(wxWindow_t), intent(in) :: parent
        integer(c_long), intent(in) :: style
        type(wxOwnerDrawnComboBox_t) :: odc
        type(c_ptr) :: raw

        raw = wx_owner_drawn_combo_box_create(parent, wxID_ANY(), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, style)
        odc = wxownerdrawncombobox_from_ptr(raw, .true.)
        if (odc%is_valid()) call append_owner_items(odc)
    end function new_odc

end module combo_handlers


module combo_ui
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_panel, only: wx_panel_create
    use wx_text_ctrl, only: wx_text_ctrl_create
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add_spacer, wx_sizer_add_stretch_spacer, &
        wx_sizer_set_size_hints
    use wx_combo_ctrl, only: wx_combo_ctrl_set_text_ctrl_style, &
        wx_combo_ctrl_use_alt_popup_window, wx_combo_ctrl_set_popup_min_width, &
        wx_combo_ctrl_set_popup_control, wx_combo_ctrl_set_button_position, &
        wx_combo_ctrl_set_value, wx_combo_ctrl_set_button_bitmaps, &
        wx_combo_ctrl_get_button_size, wx_combo_ctrl_get_features, &
        wx_combo_ctrl_set_main_control
    use kwx_combo_ctrl, only: kwx_combo_ctrl_create_default, kwx_combo_ctrl_create, &
        kwx_combo_ctrl_create_with, kwx_combo_ctrl_set_on_animate_show, &
        kwx_combo_ctrl_set_on_button_click, kwx_combo_ctrl_set_on_do_set_popup_control
    use kwx_owner_drawn_combo_box, only: kwx_owner_drawn_combo_box_create_with, &
        kwx_owner_drawn_combo_box_set_on_draw_item, &
        kwx_owner_drawn_combo_box_set_on_draw_background, &
        kwx_owner_drawn_combo_box_set_on_measure_item, &
        kwx_owner_drawn_combo_box_set_on_measure_item_width
    use wx_owner_drawn_combo_box, only: wx_owner_drawn_combo_box_create, &
        wx_owner_drawn_combo_box_set_selection
    use wx_generic_combo_ctrl, only: wx_generic_combo_ctrl_create
    use kwx_list_view_combo_popup, only: kwx_list_view_combo_popup_create, &
        kwx_list_view_combo_popup_add_string
    use kwx_tree_ctrl_combo_popup, only: kwx_tree_ctrl_combo_popup_create, &
        kwx_tree_ctrl_combo_popup_add_root, kwx_tree_ctrl_combo_popup_append_item
    use wx_tree_item_id, only: wx_tree_item_id_create, wx_tree_item_id_delete
    use wx_bitmap_bundle, only: wx_bitmap_bundle_from_svg_file, &
        wx_bitmap_bundle_delete
    use wx_size, only: wx_size_get_width, wx_size_get_height, wx_size_delete
    use wx_check_box, only: wx_check_box_create_default, wx_check_box_create2
    use wx_window, only: wx_window_set_sizer, wx_window_fit, wx_window_centre, &
        wx_window_from_dip, wx_window_set_background_colour
    use wx_free_functions, only: kwx_system_settings_get_colour
    use wx_colour, only: wx_colour_delete
    use combo_globals
    use combo_util
    use combo_handlers, only: on_draw_item, on_draw_background, on_measure_item, &
        on_measure_item_width, on_anim_show, on_file_button_click, &
        on_file_popup_control
    implicit none
    private

    public :: build_main_ui

contains

    subroutine build_main_ui()
        type(wxPanel_t) :: panel
        type(wxBoxSizer_t) :: topsizer, toprow, col, col2, row
        type(wxStaticText_t) :: label
        type(wxSizerItem_t) :: spacer
        type(wxBitmapBundle_t) :: bmp_normal, bmp_pressed, bmp_hover
        type(wxBitmapBundle_t) :: bmp_none, bmp_dots
        type(wxSize_t) :: buttonsize
        type(wxColour_t) :: syscolour
        type(wxCheckBox_t) :: check
        type(wxTreeItemId_t) :: root, branch, subitem
        type(c_ptr) :: raw
        integer(c_int) :: bdef, b2, b3, buttonwidth, buttonheight
        integer(c_int) :: rc, dummy
        integer :: i, n
        character(len=32) :: item
        logical :: ok

        ! wxPanel* panel = new wxPanel(this);
        panel = wx_panel_create(g_frame, wxID_ANY(), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)

        ! m_logWin = new wxTextCtrl(panel, 105, ... wxTE_MULTILINE) and the
        ! wxLogTextCtrl target are created before the sizers.
        g_logwin = wx_text_ctrl_create(panel, 105_c_int, "", -1_c_int, -1_c_int, &
            -1_c_int, 125_c_int, int(wxTE_MULTILINE(), c_long))

        bdef = wx_window_from_dip(g_frame, 5_c_int)
        b2 = wx_window_from_dip(g_frame, 2_c_int)
        b3 = wx_window_from_dip(g_frame, 3_c_int)

        topsizer = wx_box_sizer_create(wxVERTICAL())
        toprow = wx_box_sizer_create(wxHORIZONTAL())
        col = wx_box_sizer_create(wxVERTICAL())

        !----------------------------------------------------------------------
        ! OwnerDrawnComboBox with owner-drawn items
        !----------------------------------------------------------------------
        row = wx_box_sizer_create(wxHORIZONTAL())
        call add_window(row, new_label(panel, &
            "OwnerDrawnComboBox with owner-drawn items:"), 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxRIGHT()), bdef)
        call add_sizer(col, row, 0_c_int, ior(wxEXPAND(), wxALL()), bdef)

        row = wx_box_sizer_create(wxHORIZONTAL())
        g_odc_left = kwx_owner_drawn_combo_box_create_with(c_loc(g_tag_left), &
            panel, wxID_ANY(), "", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            int(wxCB_READONLY(), c_long))
        call kwx_owner_drawn_combo_box_set_on_draw_item(g_odc_left, &
            transfer(c_funloc(on_draw_item), c_null_ptr))
        call kwx_owner_drawn_combo_box_set_on_draw_background(g_odc_left, &
            transfer(c_funloc(on_draw_background), c_null_ptr))
        call kwx_owner_drawn_combo_box_set_on_measure_item(g_odc_left, &
            transfer(c_funloc(on_measure_item), c_null_ptr))
        call kwx_owner_drawn_combo_box_set_on_measure_item_width(g_odc_left, &
            transfer(c_funloc(on_measure_item_width), c_null_ptr))
        call append_owner_items(g_odc_left)
        call wx_owner_drawn_combo_box_set_selection(g_odc_left, 0_c_int)
        call add_window(row, g_odc_left, 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxALL()), bdef)
        call wx_sizer_add_stretch_spacer(row, 1_c_int)
        call add_sizer(col, row, 0_c_int, ior(wxEXPAND(), wxALL()), bdef)

        !----------------------------------------------------------------------
        ! Same with the button on the left
        !----------------------------------------------------------------------
        row = wx_box_sizer_create(wxHORIZONTAL())
        call add_window(row, new_label(panel, &
            "OwnerDrawnComboBox with owner-drawn items and button on the left:"),&
            1_c_int, ior(wxALIGN_CENTER_VERTICAL(), wxRIGHT()), bdef)
        call add_sizer(col, row, 0_c_int, ior(wxEXPAND(), wxALL()), bdef)

        row = wx_box_sizer_create(wxHORIZONTAL())
        g_odc_leftbutton = kwx_owner_drawn_combo_box_create_with( &
            c_loc(g_tag_leftbutton), panel, wxID_ANY(), "", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, int(wxCB_READONLY(), c_long))
        call kwx_owner_drawn_combo_box_set_on_draw_item(g_odc_leftbutton, &
            transfer(c_funloc(on_draw_item), c_null_ptr))
        call kwx_owner_drawn_combo_box_set_on_draw_background(g_odc_leftbutton, &
            transfer(c_funloc(on_draw_background), c_null_ptr))
        call kwx_owner_drawn_combo_box_set_on_measure_item(g_odc_leftbutton, &
            transfer(c_funloc(on_measure_item), c_null_ptr))
        call kwx_owner_drawn_combo_box_set_on_measure_item_width(g_odc_leftbutton, &
            transfer(c_funloc(on_measure_item_width), c_null_ptr))
        call append_owner_items(g_odc_leftbutton)
        call wx_owner_drawn_combo_box_set_selection(g_odc_leftbutton, 0_c_int)

        ! Use a button size that is slightly smaller than the default.
        buttonsize = wx_combo_ctrl_get_button_size(g_odc_leftbutton)
        buttonwidth = wx_size_get_width(buttonsize)
        buttonheight = wx_size_get_height(buttonsize)
        buttonsize%owned = .true.   ! kwxFFI returns a new wxSize
        call wx_size_delete(buttonsize)
        call wx_combo_ctrl_set_button_position(g_odc_leftbutton, &
            buttonwidth - 2_c_int, buttonheight - 6_c_int, wxLEFT(), 2_c_int)

        call add_window(row, g_odc_leftbutton, 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxALL()), bdef)
        call wx_sizer_add_stretch_spacer(row, 1_c_int)
        call add_sizer(col, row, 0_c_int, ior(wxEXPAND(), wxALL()), bdef)

        !----------------------------------------------------------------------
        ! List view / tree ctrl wxComboCtrl labels
        !----------------------------------------------------------------------
        row = wx_box_sizer_create(wxHORIZONTAL())
        call add_window(row, new_label(panel, &
            "List View wxComboCtrl (custom animation):"), 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxRIGHT()), bdef)
        call add_window(row, new_label(panel, "Tree Ctrl wxComboCtrl:"), 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxRIGHT()), bdef)
        call add_sizer(col, row, 0_c_int, ior(wxEXPAND(), wxALL()), bdef)

        row = wx_box_sizer_create(wxHORIZONTAL())

        !----------------------------------------------------------------------
        ! List View wxComboCtrl (custom animation)
        !----------------------------------------------------------------------
        g_cc_list = kwx_combo_ctrl_create_default(c_null_ptr)
        call wx_combo_ctrl_set_text_ctrl_style(g_cc_list, wxTE_RIGHT())
        ok = kwx_combo_ctrl_create(g_cc_list, panel, wxID_ANY(), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call wx_combo_ctrl_use_alt_popup_window(g_cc_list, .true.)
        call wx_combo_ctrl_set_popup_min_width(g_cc_list, 300_c_int)

        g_list_popup = kwx_list_view_combo_popup_create()
        call attach_popup(g_cc_list, g_list_popup%ptr)
        do i = 0, 99
            write(item, '("Item ",I2.2)') i
            call kwx_list_view_combo_popup_add_string(g_list_popup, trim(item))
        end do
        call kwx_combo_ctrl_set_on_animate_show(g_cc_list, &
            transfer(c_funloc(on_anim_show), c_null_ptr))

        call add_window(row, g_cc_list, 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxALL()), bdef)

        !----------------------------------------------------------------------
        ! Tree Ctrl wxComboCtrl
        !----------------------------------------------------------------------
        g_gcc_tree = wx_generic_combo_ctrl_create(panel, wxID_ANY(), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        call wx_combo_ctrl_use_alt_popup_window(g_gcc_tree, .true.)

        g_tree_popup = kwx_tree_ctrl_combo_popup_create()
        call attach_popup(g_gcc_tree, g_tree_popup%ptr)

        root = wx_tree_item_id_create()
        branch = wx_tree_item_id_create()
        subitem = wx_tree_item_id_create()

        call kwx_tree_ctrl_combo_popup_add_root(g_tree_popup, "<hidden_root>", root)
        do i = 0, 3
            write(item, '("Branch ",I2.2)') i
            call kwx_tree_ctrl_combo_popup_append_item(g_tree_popup, root, &
                trim(item), branch)
            do n = 0, 24
                write(item, '("Subitem ",I2.2)') i * 25 + n
                call kwx_tree_ctrl_combo_popup_append_item(g_tree_popup, branch, &
                    trim(item), subitem)
            end do
        end do

        call wx_combo_ctrl_set_value(g_gcc_tree, "Subitem 05")
        call wx_combo_ctrl_set_button_position(g_gcc_tree, -1_c_int, -1_c_int, &
            wxLEFT(), 0_c_int)

        call add_window(row, g_gcc_tree, 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxALL()), bdef)
        call add_sizer(col, row, 0_c_int, ior(wxEXPAND(), wxALL()), bdef)

        call wx_tree_item_id_delete(root)
        call wx_tree_item_id_delete(branch)
        call wx_tree_item_id_delete(subitem)

        !----------------------------------------------------------------------
        ! Custom dropbutton bitmaps
        !----------------------------------------------------------------------
        row = wx_box_sizer_create(wxHORIZONTAL())
        call add_window(row, new_label(panel, &
            "OwnerDrawnComboBox with simple dropbutton graphics:"), 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxRIGHT()), bdef)
        call add_sizer(col, row, 0_c_int, ior(wxEXPAND(), wxALL()), bdef)

        row = wx_box_sizer_create(wxHORIZONTAL())

        raw = wx_owner_drawn_combo_box_create(panel, wxID_ANY(), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        g_odc_plain1 = wxownerdrawncombobox_from_ptr(raw, .true.)
        call append_owner_items(g_odc_plain1)

        raw = wx_owner_drawn_combo_box_create(panel, wxID_ANY(), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        g_odc_plain2 = wxownerdrawncombobox_from_ptr(raw, .true.)
        call append_owner_items(g_odc_plain2)

        bmp_normal = wx_bitmap_bundle_from_svg_file("dropbutn.svg", 16_c_int, 16_c_int)
        bmp_pressed = wx_bitmap_bundle_from_svg_file("dropbutp.svg", 16_c_int, 16_c_int)
        bmp_hover = wx_bitmap_bundle_from_svg_file("dropbuth.svg", 16_c_int, 16_c_int)

        if (bundle_is_ok(bmp_normal) .and. bundle_is_ok(bmp_pressed) .and. &
            bundle_is_ok(bmp_hover)) then
            call wx_combo_ctrl_set_button_bitmaps(g_odc_plain1, bmp_normal, &
                .false., bmp_pressed, bmp_hover, bmp_none)
            call wx_combo_ctrl_set_button_bitmaps(g_odc_plain2, bmp_normal, &
                .true., bmp_pressed, bmp_hover, bmp_none)
        else
            call log_message("Dropbutton images not found")
        end if

        call wx_bitmap_bundle_delete(bmp_normal)
        call wx_bitmap_bundle_delete(bmp_pressed)
        call wx_bitmap_bundle_delete(bmp_hover)

        call add_window(row, g_odc_plain1, 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxALL()), bdef)
        call add_window(row, g_odc_plain2, 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxALL()), bdef)
        call add_sizer(col, row, 0_c_int, ior(wxEXPAND(), wxALL()), bdef)

        !----------------------------------------------------------------------
        ! Custom button and custom main control
        !----------------------------------------------------------------------
        row = wx_box_sizer_create(wxHORIZONTAL())
        call add_window(row, new_label(panel, &
            "wxComboCtrl with custom button and custom main control:"), 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxRIGHT()), bdef)
        call add_sizer(col, row, 0_c_int, ior(wxEXPAND(), wxALL()), bdef)

        row = wx_box_sizer_create(wxHORIZONTAL())

        g_cc_file = kwx_combo_ctrl_create_with(c_null_ptr, panel, wxID_ANY(), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, int(wxCC_STD_BUTTON(), c_long))
        call kwx_combo_ctrl_set_on_button_click(g_cc_file, &
            transfer(c_funloc(on_file_button_click), c_null_ptr))
        call kwx_combo_ctrl_set_on_do_set_popup_control(g_cc_file, &
            transfer(c_funloc(on_file_popup_control), c_null_ptr))
        bmp_dots = wx_bitmap_bundle_from_svg_file("three-dots.svg", 16_c_int, 16_c_int)
        if (bundle_is_ok(bmp_dots)) then
            call wx_combo_ctrl_set_button_bitmaps(g_cc_file, bmp_dots, .true., &
                bmp_none, bmp_none, bmp_none)
        end if
        call wx_bitmap_bundle_delete(bmp_dots)

        ! wxCheckBox as main control: two-stage creation, exactly as in C++.
        g_cc_check = kwx_combo_ctrl_create_default(c_null_ptr)
        check = wx_check_box_create_default()
        call wx_combo_ctrl_set_main_control(g_cc_check, check)
        ok = kwx_combo_ctrl_create(g_cc_check, panel, wxID_ANY(), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_long)
        ok = wx_check_box_create2(check, g_cc_check, wxID_ANY(), &
            "Checkbox as main control", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            0_c_int)
        syscolour = kwx_system_settings_get_colour(wxSYS_COLOUR_WINDOW())
        syscolour%owned = .true.   ! kwxFFI returns a new wxColour
        ok = wx_window_set_background_colour(check, syscolour)
        call wx_colour_delete(syscolour)

        g_list_popup_check = kwx_list_view_combo_popup_create()
        call attach_popup(g_cc_check, g_list_popup_check%ptr)

        call add_window(row, g_cc_file, 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxALL()), bdef)
        call add_window(row, g_cc_check, 1_c_int, &
            ior(wxALIGN_CENTER_VERTICAL(), wxALL()), bdef)
        call add_sizer(col, row, 0_c_int, ior(wxEXPAND(), wxALL()), bdef)

        ! Make sure GetFeatures is implemented.
        dummy = wx_combo_ctrl_get_features()

        call add_sizer(toprow, col, 1_c_int, wxALL(), b2)

        !----------------------------------------------------------------------
        ! Log messages column
        !----------------------------------------------------------------------
        col2 = wx_box_sizer_create(wxVERTICAL())
        spacer = wx_sizer_add_spacer(col2, 8_c_int)
        call add_window(col2, new_label(panel, "Log Messages:"), 0_c_int, &
            ior(wxTOP(), wxLEFT()), b3)
        call add_window(col2, g_logwin, 1_c_int, ior(wxEXPAND(), wxALL()), b3)
        call add_sizer(toprow, col2, 1_c_int, ior(wxEXPAND(), wxALL()), b2)

        call add_sizer(topsizer, toprow, 1_c_int, wxEXPAND(), 0_c_int)

        ! panel->SetSizer(topSizer); topSizer->SetSizeHints(panel);
        call wx_window_set_sizer(panel, topsizer, .false.)
        call wx_sizer_set_size_hints(topsizer, panel)

        ! Fit(); Centre();
        call wx_window_fit(g_frame)
        call wx_window_centre(g_frame, wxBOTH())
    end subroutine build_main_ui

    ! Message handlers live in combo_handlers; popup objects are
    ! kwxListViewComboPopup/kwxTreeCtrlComboPopup (wxobject_t based), so their
    ! pointer is re-wrapped in the base wxComboPopup_t handle.
    subroutine attach_popup(combo, popup_ptr)
        class(wxComboCtrl_t), intent(in) :: combo
        type(c_ptr), intent(in) :: popup_ptr
        type(wxComboPopup_t) :: popup

        popup%ptr = popup_ptr
        popup%owned = .false.
        call wx_combo_ctrl_set_popup_control(combo, popup)
    end subroutine attach_popup

end module combo_ui


program combo
    use, intrinsic :: iso_c_binding
    use wx_app
    use wx_frame
    use wx_bitmap_bundle, only: wx_bitmap_bundle_from_svg_file, &
        wx_bitmap_bundle_get_icon, wx_bitmap_bundle_delete
    use wx_icon, only: wx_icon_delete
    use wx_menu, only: wx_menu_create, wx_menu_append, wx_menu_append_separator
    use wx_menu_bar, only: wx_menu_bar_create, wx_menu_bar_append
    use wx_window, only: wx_window_show
    use wx_events, only: wx_connect
    use kwx_types
    use kwxffi, only: wxID_ANY, wxID_ABOUT, wxID_EXIT, wxID_HIGHEST, wxEVT_MENU, &
        wxEVT_TEXT, wxEVT_TEXT_ENTER, wxEVT_COMBOBOX, wxEVT_IDLE, &
        wxDEFAULT_FRAME_STYLE
    use combo_globals
    use combo_util, only: bundle_is_ok
    use combo_handlers, only: on_combo_event, on_compare, on_quit, on_about, on_idle
    use combo_ui, only: build_main_ui
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxMenu_t) :: file_menu, help_menu
    type(wxMenuBar_t) :: menu_bar
    type(wxIcon_t) :: frame_icon
    integer :: exit_code, dummy
    logical :: shown

    ! MyApp::OnInit()
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    call wx_set_app_name("wxComboCtrl Sample")
    call wx_init_all_image_handlers()

    ! MyFrame *frame = new MyFrame("wxComboCtrl and wxOwnerDrawnComboBox Sample");
    no_parent%ptr = c_null_ptr
    g_frame = wx_frame_create(no_parent, wxID_ANY(), &
        "wxComboCtrl and wxOwnerDrawnComboBox Sample", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, wxDEFAULT_FRAME_STYLE())
    if (.not. g_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    ! SetIcon(wxICON(sample)): the "sample" icon resource is not present in
    ! this tree's .rc, so the XPM artwork is loaded from its SVG conversion.
    g_icon_bundle = wx_bitmap_bundle_from_svg_file("sample.svg", 32_c_int, 32_c_int)
    if (bundle_is_ok(g_icon_bundle)) then
        frame_icon = wx_bitmap_bundle_get_icon(g_icon_bundle, 32_c_int, 32_c_int)
        if (frame_icon%is_valid()) call wx_frame_set_icon(g_frame, frame_icon)
        call wx_icon_delete(frame_icon)
    end if

    ! File menu: Compare, separator, Exit.  Help menu: About.
    file_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(file_menu, wxID_HIGHEST(), &
        "&Compare against wxComboBox...", &
        "Show some wxOwnerDrawnComboBoxes side-by-side with native wxComboBoxes.", &
        .false.)
    call wx_menu_append_separator(file_menu)
    call wx_menu_append(file_menu, wxID_EXIT(), "E&xit" // achar(9) // "Alt-X", &
        "Quit this program", .false.)

    help_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(help_menu, wxID_ABOUT(), "&About" // achar(9) // "F1", &
        "Show about dialog", .false.)

    menu_bar = wx_menu_bar_create(0_c_int)
    dummy = wx_menu_bar_append(menu_bar, file_menu, "&File")
    dummy = wx_menu_bar_append(menu_bar, help_menu, "&Help")
    call wx_frame_set_menu_bar(g_frame, menu_bar)

    call build_main_ui()

    ! Event table: EVT_TEXT / EVT_TEXT_ENTER / EVT_COMBOBOX (wxID_ANY),
    ! EVT_MENU (Compare, Quit, About) and EVT_IDLE.
    call wx_connect(g_frame, wxEVT_TEXT(), on_combo_event)
    call wx_connect(g_frame, wxEVT_TEXT_ENTER(), on_combo_event)
    call wx_connect(g_frame, wxEVT_COMBOBOX(), on_combo_event)
    call wx_connect(g_frame, wxEVT_MENU(), on_compare, id=wxID_HIGHEST())
    call wx_connect(g_frame, wxEVT_MENU(), on_quit, id=wxID_EXIT())
    call wx_connect(g_frame, wxEVT_MENU(), on_about, id=wxID_ABOUT())
    call wx_connect(g_frame, wxEVT_IDLE(), on_idle)

    call wx_set_top_window(g_frame)
    shown = wx_window_show(g_frame)

    exit_code = wx_main_loop()

    call wx_bitmap_bundle_delete(g_icon_bundle)

    call wx_shutdown()

end program combo
