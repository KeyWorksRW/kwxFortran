! font.f90 - wxWidgets font sample port to kwxFortran
!
! Fortran port of wxWidgets samples src/font/font.cpp.
!
! The frame owns a splitter window: the upper pane is a FontWindow holding the
! FontPanel (face name, family, point size, style, weight, underline,
! strikethrough and fixed-width controls plus an Apply button and an info
! label) and a FontCanvas which paints characters 32..255 in a 7x32 grid.
! The lower pane is a multi-line text control.  The menu bar offers font
! manipulation, stock/system fonts, face name enumeration, encoding
! enumeration, a font selection dialog and an email-message viewer.
!
! Run the executable with the current directory set to this folder so the
! relative "wxprivate.ttf" and "sample.svg" paths resolve.

module font_globals
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_HIGHEST
    implicit none

    type(wxFrame_t), save :: g_frame
    type(wxMenuBar_t), save :: g_menu_bar
    type(wxMenu_t), save :: g_file_menu
    type(wxMenu_t), save :: g_font_menu
    type(wxMenu_t), save :: g_select_menu
    type(wxMenu_t), save :: g_std_fonts_menu
    type(wxMenu_t), save :: g_sys_fonts_menu

    type(wxSplitterWindow_t), save :: g_splitter
    type(wxWindow_t), save :: g_font_window
    type(wxPanel_t), save :: g_panel
    type(wxWindow_t), save :: g_canvas
    type(wxTextCtrl_t), save :: g_textctrl

    type(wxTextCtrl_t), save :: g_face_name
    type(wxChoice_t), save :: g_choice_family
    type(wxSpinCtrlDouble_t), save :: g_spin_point_size
    type(wxChoice_t), save :: g_choice_style
    type(wxChoice_t), save :: g_choice_weight
    type(wxSpinCtrl_t), save :: g_spin_weight
    type(wxCheckBox_t), save :: g_check_underlined
    type(wxCheckBox_t), save :: g_check_strikethrough
    type(wxCheckBox_t), save :: g_check_fixed_width
    type(wxStaticText_t), save :: g_label_info
    type(wxButton_t), save :: g_apply_button
    type(wxStaticLine_t), save :: g_static_line

    ! FontPanel::m_font and FontCanvas::m_font hold the same value:
    ! FontWindow::UpdateFont() copies the new font into both.
    type(wxFont_t), save :: g_font
    type(wxColour_t), save :: g_colour

    type(wxBitmapBundle_t), save :: g_icon_bundle
    type(wxIcon_t), save :: g_icon

    logical, save :: g_use_family = .false.
    logical, save :: g_use_numeric_weight = .false.
    logical, save :: g_has_private_font = .false.

    integer, save :: g_border = 5

    character(len=:), allocatable, save :: g_msg_dir
    character(len=:), allocatable, save :: g_msg_file

    integer, save :: id_view_msg = 0
    integer, save :: id_test_text_value = 1
    integer, save :: id_inc_size = 2
    integer, save :: id_dec_size = 3
    integer, save :: id_get_base_font = 4
    integer, save :: id_bold = 5
    integer, save :: id_light = 6
    integer, save :: id_italic = 7
    integer, save :: id_slant = 8
    integer, save :: id_underlined = 9
    integer, save :: id_strikethrough = 10
    integer, save :: id_normal_font = 11
    integer, save :: id_small_font = 12
    integer, save :: id_italic_font = 13
    integer, save :: id_swiss_font = 14
    integer, save :: id_font_default = 15
    integer, save :: id_standard = 16
    integer, save :: id_sys_oem_fixed = 17
    integer, save :: id_sys_ansi_fixed = 18
    integer, save :: id_sys_ansi_var = 19
    integer, save :: id_sys_system = 20
    integer, save :: id_sys_device_default = 21
    integer, save :: id_sys_default_gui = 22
    integer, save :: id_system_settings = 23
    integer, save :: id_choose = 100
    integer, save :: id_enum_families_for_encoding = 101
    integer, save :: id_enum_families = 102
    integer, save :: id_enum_fixed_families = 103
    integer, save :: id_enum_encodings = 104
    integer, save :: id_set_native_desc = 105
    integer, save :: id_set_native_user_desc = 106
    integer, save :: id_set_family = 107
    integer, save :: id_set_face_name = 108
    integer, save :: id_set_encoding = 109
    integer, save :: id_private = 110

contains

    ! C++ enum: Font_ViewMsg = wxID_HIGHEST followed by consecutive values.
    subroutine init_font_ids()
        integer :: base

        base = int(wxID_HIGHEST())
        id_view_msg = base
        id_test_text_value = base + 1
        id_inc_size = base + 2
        id_dec_size = base + 3
        id_get_base_font = base + 4
        id_bold = base + 5
        id_light = base + 6
        id_italic = base + 7
        id_slant = base + 8
        id_underlined = base + 9
        id_strikethrough = base + 10
        id_normal_font = base + 11
        id_small_font = base + 12
        id_italic_font = base + 13
        id_swiss_font = base + 14
        id_font_default = base + 15
        id_standard = base + 16
        id_sys_oem_fixed = base + 17
        id_sys_ansi_fixed = base + 18
        id_sys_ansi_var = base + 19
        id_sys_system = base + 20
        id_sys_device_default = base + 21
        id_sys_default_gui = base + 22
        id_system_settings = base + 23
    end subroutine init_font_ids

end module font_globals


module font_util
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_string, only: to_wxstring, from_wxstring
    use wx_sizer
    use wx_text_entry_dialog
    use wx_single_choice_dialog
    use wx_dialog
    use wx_window
    use wx_font
    use font_globals
    implicit none

contains

    pure function nl() result(s)
        character(len=1) :: s
        s = achar(10)
    end function nl

    pure function itoa(value) result(s)
        integer, intent(in) :: value
        character(len=:), allocatable :: s
        character(len=32) :: buf
        write(buf, '(I0)') value
        s = trim(buf)
    end function itoa

    ! UTF-8 encoding of a single character code point used by FontCanvas.
    pure function utf8_char(code) result(s)
        integer, intent(in) :: code
        character(len=:), allocatable :: s
        if (code < 128) then
            if (code == 32) then
                s = ""
            else
                s = achar(code)
            end if
        else
            s = achar(192 + code / 64) // achar(128 + mod(code, 64))
        end if
    end function utf8_char

    function normal_font() result(f)
        type(wxFont_t) :: f
        f = wxfont_from_ptr(wxNORMAL_FONT(), .false.)
    end function normal_font

    ! wxFont copy construction: wxFont other(font); the FFI allocates a new object.
    function copy_font(src) result(dst)
        type(wxFont_t), intent(in) :: src
        type(wxFont_t) :: dst
        dst = wx_font_create_from_font(src)
        dst%owned = .true.
    end function copy_font

    subroutine add_window(sz, win, proportion, flag, border)
        class(wxSizer_t), intent(in) :: sz
        class(wxWindow_t), intent(in) :: win
        integer, intent(in) :: proportion
        integer, intent(in) :: flag
        integer, intent(in) :: border

        call wx_sizer_add_window(sz, win, int(proportion, c_int), &
            int(flag, c_int), int(border, c_int), c_null_ptr)
    end subroutine add_window

    subroutine add_sizer(sz, child, proportion, flag, border)
        class(wxSizer_t), intent(in) :: sz
        class(wxSizer_t), intent(in) :: child
        integer, intent(in) :: proportion
        integer, intent(in) :: flag
        integer, intent(in) :: border

        call wx_sizer_add_sizer(sz, child, int(proportion, c_int), &
            int(flag, c_int), int(border, c_int), c_null_ptr)
    end subroutine add_sizer

    subroutine add_spacer(sz, size)
        class(wxSizer_t), intent(in) :: sz
        integer, intent(in) :: size
        type(wxSizerItem_t) :: item

        item = wx_sizer_add_spacer(sz, int(size, c_int))
    end subroutine add_spacer

    ! wxLogError / wxLogWarning / wxLogMessage.
    subroutine show_error(text)
        character(len=*), intent(in) :: text
        type(c_ptr) :: msg

        msg = to_wxstring(text)
        call LogErrorMsg(msg)
        call wxString_Delete(msg)
    end subroutine show_error

    subroutine show_warning(text)
        character(len=*), intent(in) :: text
        type(c_ptr) :: msg

        msg = to_wxstring(text)
        call LogWarningMsg(msg)
        call wxString_Delete(msg)
    end subroutine show_warning

    subroutine show_info(text)
        character(len=*), intent(in) :: text
        type(c_ptr) :: msg

        msg = to_wxstring(text)
        call LogMessageMsg(msg)
        call wxString_Delete(msg)
    end subroutine show_info

    subroutine show_message(text, caption, style)
        character(len=*), intent(in) :: text
        character(len=*), intent(in) :: caption
        integer, intent(in) :: style
        type(c_ptr) :: msg_ptr, cap_ptr, parent_ptr
        integer(c_int) :: rc

        parent_ptr = c_null_ptr
        if (g_frame%is_valid()) parent_ptr = g_frame%ptr
        msg_ptr = to_wxstring(text)
        cap_ptr = to_wxstring(caption)
        rc = kwxMessageBox(msg_ptr, cap_ptr, int(style, c_int), parent_ptr, &
            -1_c_int, -1_c_int)
        call wxString_Delete(msg_ptr)
        call wxString_Delete(cap_ptr)
    end subroutine show_message

    ! wxGetTextFromUser()
    function get_text_from_user(message, caption, default_text) result(text)
        character(len=*), intent(in) :: message
        character(len=*), intent(in) :: caption
        character(len=*), intent(in) :: default_text
        character(len=:), allocatable :: text
        type(wxTextEntryDialog_t) :: dlg
        integer :: rc
        logical :: destroyed

        text = ""
        dlg = wx_text_entry_dialog_create(g_frame, message, caption, &
            default_text, int(ior(ior(wxOK(), wxCANCEL()), wxCENTRE()), c_long), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int)
        rc = wx_dialog_show_modal(dlg)
        if (rc == int(wxID_OK())) then
            text = wx_text_entry_dialog_get_value(dlg)
        end if
        destroyed = wx_window_destroy(dlg)
    end function get_text_from_user

    ! wxGetSingleChoiceIndex()
    function choose_facename(names) result(sel)
        type(wxArrayString_t), intent(in) :: names
        integer :: sel
        type(wxSingleChoiceDialog_t) :: dlg
        integer :: rc
        logical :: destroyed

        sel = -1
        dlg = wx_single_choice_dialog_create(g_frame, "Choose a facename", &
            "wxWidgets Font Sample", names, int(wxCHOICEDLG_STYLE(), c_int))
        rc = wx_dialog_show_modal(dlg)
        if (rc == int(wxID_OK())) then
            sel = int(wx_single_choice_dialog_get_selection(dlg))
        end if
        destroyed = wx_window_destroy(dlg)
    end function choose_facename

end module font_util


module font_handlers
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_string, only: to_wxstring, from_wxstring, from_cstring
    use wx_encoding_converter
    use wx_events
    use wx_window
    use wx_frame
    use wx_font
    use wx_font_info
    use wx_font_data
    use wx_font_dialog
    use wx_font_enumerator
    use wx_font_mapper
    use wx_system_settings
    use wx_array_string
    use wx_choice
    use wx_spin_ctrl
    use wx_spin_ctrl_double
    use wx_check_box
    use wx_text_ctrl
    use wx_static_text
    use wx_menu_bar
    use wx_dialog
    use wx_single_choice_dialog
    use wx_file_dialog
    use wx_text_file
    use wx_dc
    use wx_client_dc
    use wx_paint_dc
    use wx_colour
    use wx_brush
    use wx_pen
    use wx_size
    use font_globals
    use font_util
    implicit none

    ! State for MyEncodingEnumerator (wxFontEnumerator::OnFontEncoding callback).
    character(len=:), allocatable, save :: g_enc_text
    integer, save :: g_enc_count = 0

contains

    ! ------------------------------------------------------------------
    ! FontPanel / FontWindow helpers
    ! ------------------------------------------------------------------

    function family_from_index(index) result(fam)
        integer, intent(in) :: index
        integer :: fam

        fam = int(wxFONTFAMILY_DEFAULT())
        if (index == 1) fam = int(wxFONTFAMILY_DECORATIVE())
        if (index == 2) fam = int(wxFONTFAMILY_ROMAN())
        if (index == 3) fam = int(wxFONTFAMILY_SCRIPT())
        if (index == 4) fam = int(wxFONTFAMILY_SWISS())
        if (index == 5) fam = int(wxFONTFAMILY_MODERN())
        if (index == 6) fam = int(wxFONTFAMILY_TELETYPE())
    end function family_from_index

    ! FontPanel::GetFontInfo()
    function make_new_font() result(f)
        type(wxFont_t) :: f
        type(wxFontInfo_t) :: info
        real(c_double) :: pointsize
        character(len=:), allocatable :: face
        integer :: sel

        pointsize = wx_spin_ctrl_double_get_value(g_spin_point_size)
        info = wx_font_info_create(pointsize)

        if (g_use_family) then
            sel = int(wx_choice_get_selection(g_choice_family))
            call wx_font_info_set_family(info, int(family_from_index(sel), c_int))
        else
            face = wx_text_ctrl_get_value(g_face_name)
            call wx_font_info_set_face_name(info, face)
        end if

        sel = int(wx_choice_get_selection(g_choice_style))
        if (sel == 1) call wx_font_info_set_italic(info, .true.)
        if (sel == 2) call wx_font_info_set_slant(info, .true.)

        if (g_use_numeric_weight) then
            call wx_font_info_set_weight(info, wx_spin_ctrl_get_value(g_spin_weight))
        else
            sel = int(wx_choice_get_selection(g_choice_weight))
            call wx_font_info_set_weight(info, int((sel + 1) * 100, c_int))
        end if

        if (wx_check_box_get_value(g_check_underlined)) then
            call wx_font_info_set_underlined(info, .true.)
        end if
        if (wx_check_box_get_value(g_check_strikethrough)) then
            call wx_font_info_set_strikethrough(info, .true.)
        end if

        f = wx_font_create_from_info(info)
        call wx_font_info_delete(info)
    end function make_new_font

    ! FontPanel::DoUpdate()
    subroutine panel_update()
        character(len=:), allocatable :: face, native, text
        type(wxClientDC_t) :: dc
        type(wxSize_t) :: pixels
        integer :: fam, sty, wt, sel

        face = wx_font_get_face_name(g_font)
        call wx_text_ctrl_change_value(g_face_name, face)

        fam = int(wx_font_get_family(g_font))
        sel = 0
        if (fam == int(wxFONTFAMILY_DECORATIVE())) sel = 1
        if (fam == int(wxFONTFAMILY_ROMAN())) sel = 2
        if (fam == int(wxFONTFAMILY_SCRIPT())) sel = 3
        if (fam == int(wxFONTFAMILY_SWISS())) sel = 4
        if (fam == int(wxFONTFAMILY_MODERN())) sel = 5
        if (fam == int(wxFONTFAMILY_TELETYPE())) sel = 6
        call wx_choice_set_selection(g_choice_family, int(sel, c_int))

        call wx_spin_ctrl_double_set_value(g_spin_point_size, &
            wx_font_get_fractional_point_size(g_font))

        sty = int(wx_font_get_style(g_font))
        sel = 0
        if (sty == int(wxFONTSTYLE_ITALIC())) sel = 1
        if (sty == int(wxFONTSTYLE_SLANT())) sel = 2
        call wx_choice_set_selection(g_choice_style, int(sel, c_int))

        wt = int(wx_font_get_weight(g_font))
        sel = 3
        if (wt == int(wxFONTWEIGHT_THIN())) sel = 0
        if (wt == int(wxFONTWEIGHT_EXTRALIGHT())) sel = 1
        if (wt == int(wxFONTWEIGHT_LIGHT())) sel = 2
        if (wt == int(wxFONTWEIGHT_MEDIUM())) sel = 4
        if (wt == int(wxFONTWEIGHT_SEMIBOLD())) sel = 5
        if (wt == int(wxFONTWEIGHT_BOLD())) sel = 6
        if (wt == int(wxFONTWEIGHT_EXTRABOLD())) sel = 7
        if (wt == int(wxFONTWEIGHT_HEAVY())) sel = 8
        if (wt == int(wxFONTWEIGHT_EXTRAHEAVY())) sel = 9
        call wx_choice_set_selection(g_choice_weight, int(sel, c_int))
        call wx_spin_ctrl_set_value(g_spin_weight, &
            int(wx_font_get_numeric_weight(g_font), c_int))

        call wx_check_box_set_value(g_check_underlined, &
            merge(1_c_int, 0_c_int, wx_font_get_underlined(g_font)))
        call wx_check_box_set_value(g_check_strikethrough, &
            merge(1_c_int, 0_c_int, wx_font_get_strikethrough(g_font)))
        call wx_check_box_set_value(g_check_fixed_width, &
            merge(1_c_int, 0_c_int, wx_font_is_fixed_width(g_font)))

        pixels = wx_font_get_pixel_size(g_font)
        dc = wx_client_dc_create(g_panel)
        call wx_dc_set_font(dc, g_font)

        native = wx_font_get_native_font_info_desc(g_font)
        text = "Font info string: " // native // nl() // &
            "Size in pixels: " // itoa(int(wx_size_get_width(pixels))) // "*" // &
            itoa(int(wx_size_get_height(pixels))) // ", average char size: " // &
            itoa(int(wx_dc_get_char_width(dc))) // "*" // &
            itoa(int(wx_dc_get_char_height(dc)))
        call wx_window_set_label(g_label_info, text)

        call wx_client_dc_delete(dc)
    end subroutine panel_update

    subroutine update_menu_checks()
        if (.not. g_menu_bar%is_valid()) return

        call wx_menu_bar_check(g_menu_bar, int(id_light, c_int), &
            wx_font_get_weight(g_font) == wxFONTWEIGHT_LIGHT())
        call wx_menu_bar_check(g_menu_bar, int(id_bold, c_int), &
            wx_font_get_weight(g_font) == wxFONTWEIGHT_BOLD())
        call wx_menu_bar_check(g_menu_bar, int(id_italic, c_int), &
            wx_font_get_style(g_font) == wxFONTSTYLE_ITALIC())
        call wx_menu_bar_check(g_menu_bar, int(id_underlined, c_int), &
            wx_font_get_underlined(g_font))
        call wx_menu_bar_check(g_menu_bar, int(id_strikethrough, c_int), &
            wx_font_get_strikethrough(g_font))
    end subroutine update_menu_checks

    ! FontWindow::UpdateFont() followed by MyFrame::DoChangeFont().
    subroutine do_change_font(f, col)
        type(wxFont_t), intent(in) :: f
        type(wxColour_t), intent(in), optional :: col
        logical :: ok
        integer :: rc

        call wx_font_assign(g_font, f)
        call panel_update()

        ok = wx_window_set_font(g_textctrl, g_font)
        if (present(col)) then
            call wx_colour_assign(g_colour, col%ptr)
            rc = int(wx_window_set_foreground_colour(g_textctrl, g_colour))
        end if
        call wx_window_refresh(g_textctrl, .true.)
        call wx_window_refresh(g_canvas, .true.)

        call update_menu_checks()
    end subroutine do_change_font

    subroutine do_resize_font(diff)
        integer, intent(in) :: diff
        type(wxFont_t) :: f

        f = copy_font(g_font)
        call wx_font_set_point_size(f, int(wx_font_get_point_size(g_font) + diff, c_int))
        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine do_resize_font

    ! MyFrame::DoEnumerateFamilies()
    function do_enumerate_families(fixed_only, encoding, silent) result(found)
        logical, intent(in) :: fixed_only
        integer, intent(in) :: encoding
        logical, intent(in) :: silent
        logical :: found
        type(wxFontEnumerator_t) :: enumerator
        type(wxArrayString_t) :: names
        type(wxFontInfo_t) :: info
        type(wxFont_t) :: f
        character(len=:), allocatable :: facename, status
        integer(c_int) :: count
        integer :: sel

        found = .false.
        enumerator = wx_font_enumerator_create_default()
        names = wx_array_string_create()
        count = wx_font_enumerator_enumerate_facenames_to_array(enumerator, &
            int(encoding, c_int), fixed_only, names)

        if (count > 0) then
            if (.not. silent) then
                status = "Found " // itoa(int(count))
                if (fixed_only) then
                    status = status // " fixed width "
                else
                    status = status // " "
                end if
                status = status // "fonts"
                call wx_frame_set_status_text(g_frame, status, 0_c_int)

                call wx_array_string_sort(names, .false.)
                sel = choose_facename(names)
                if (sel /= -1) facename = wx_array_string_item(names, int(sel, c_int))
            else
                facename = wx_array_string_item(names, 0_c_int)
            end if

            if (len(facename) > 0) then
                info = wx_font_info_create_default()
                call wx_font_info_set_face_name(info, facename)
                call wx_font_info_set_encoding(info, int(encoding, c_int))
                f = wx_font_create_from_info(info)
                call do_change_font(f)
                call wx_font_delete(f)
                call wx_font_info_delete(info)
            end if

            found = .true.
        else if (.not. silent) then
            call show_warning("No such fonts found.")
        end if

        call wx_array_string_delete(names)
        call wx_font_enumerator_delete(enumerator)
    end function do_enumerate_families

    ! MyFrame::GetEncodingFromUser()
    function get_encoding_from_user() result(enc)
        integer :: enc
        type(wxArrayString_t) :: names
        type(wxSingleChoiceDialog_t) :: dlg
        integer(c_size_t) :: count
        integer, allocatable :: encodings(:)
        integer :: n, rc, sel
        logical :: destroyed

        enc = int(wxFONTENCODING_SYSTEM())
        count = wx_font_mapper_get_supported_encodings_count()
        allocate(encodings(max(1, int(count))))
        names = wx_array_string_create()

        do n = 0, int(count) - 1
            encodings(n + 1) = int(wx_font_mapper_get_encoding(int(n, c_size_t)))
            call wx_array_string_add(names, &
                wx_font_mapper_get_encoding_name(int(encodings(n + 1), c_int)))
        end do

        dlg = wx_single_choice_dialog_create(g_frame, "Choose the encoding", &
            "wxWidgets Font Sample", names, int(wxCHOICEDLG_STYLE(), c_int))
        rc = wx_dialog_show_modal(dlg)
        if (rc == int(wxID_OK())) then
            sel = int(wx_single_choice_dialog_get_selection(dlg))
            if (sel >= 0 .and. sel < int(count)) enc = encodings(sel + 1)
        end if
        destroyed = wx_window_destroy(dlg)
        call wx_array_string_delete(names)
        deallocate(encodings)
    end function get_encoding_from_user

    ! MyFrame::GetFamilyFromUser()
    function get_family_from_user() result(fam)
        integer :: fam
        type(wxArrayString_t) :: names
        type(wxSingleChoiceDialog_t) :: dlg
        integer :: families(6)
        integer :: rc, sel
        logical :: destroyed

        fam = int(wxFONTFAMILY_DEFAULT())
        families = [int(wxFONTFAMILY_DECORATIVE()), int(wxFONTFAMILY_ROMAN()), &
            int(wxFONTFAMILY_SCRIPT()), int(wxFONTFAMILY_SWISS()), &
            int(wxFONTFAMILY_MODERN()), int(wxFONTFAMILY_TELETYPE())]
        names = wx_array_string_create()
        call wx_array_string_add(names, "DECORATIVE")
        call wx_array_string_add(names, "ROMAN")
        call wx_array_string_add(names, "SCRIPT")
        call wx_array_string_add(names, "SWISS")
        call wx_array_string_add(names, "MODERN")
        call wx_array_string_add(names, "TELETYPE")

        dlg = wx_single_choice_dialog_create(g_frame, "Choose the family", &
            "wxWidgets Font Sample", names, int(wxCHOICEDLG_STYLE(), c_int))
        rc = wx_dialog_show_modal(dlg)
        if (rc == int(wxID_OK())) then
            sel = int(wx_single_choice_dialog_get_selection(dlg))
            if (sel >= 0 .and. sel < 6) fam = families(sel + 1)
        end if
        destroyed = wx_window_destroy(dlg)
        call wx_array_string_delete(names)
    end function get_family_from_user

    ! ------------------------------------------------------------------
    ! MyFrame menu handlers
    ! ------------------------------------------------------------------

    subroutine on_quit(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: ok

        if (.not. c_associated(evt)) return
        ok = wx_window_close(g_frame, .true.)
    end subroutine on_quit

    subroutine on_test_text_value(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        character(len=:), allocatable :: value

        if (.not. c_associated(evt)) return
        value = wx_text_ctrl_get_value(g_textctrl)
        call wx_text_ctrl_set_value(g_textctrl, value)
        if (wx_text_ctrl_get_value(g_textctrl) /= value) then
            call show_error("Text value changed after getting and setting it")
        end if
    end subroutine on_test_text_value

    subroutine on_view_msg(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFileDialog_t) :: dlg
        type(wxTextFile_t) :: file
        character(len=:), allocatable :: filename, line, charset, prefix, wildcard
        character(len=1) :: ch
        type(c_ptr) :: wildcard_ptr
        integer :: rc, n, count, pos
        integer :: fontenc
        logical :: opened, destroyed

        if (.not. c_associated(evt)) return

        wildcard_ptr = wxFileSelectorDefaultWildcardStr()
        wildcard = from_wxstring(wildcard_ptr)
        call wxString_Delete(wildcard_ptr)

        dlg = wx_file_dialog_create(g_frame, "Open an email message file", &
            g_msg_dir, g_msg_file, wildcard, -1_c_int, -1_c_int, &
            int(wxFD_OPEN(), c_int), -1_c_int, -1_c_int)
        rc = wx_dialog_show_modal(dlg)
        if (rc /= int(wxID_OK())) then
            destroyed = wx_window_destroy(dlg)
            return
        end if

        g_msg_dir = wx_file_dialog_get_directory(dlg)
        g_msg_file = wx_file_dialog_get_filename(dlg)
        filename = wx_file_dialog_get_path(dlg)
        destroyed = wx_window_destroy(dlg)

        file = wx_text_file_create_from_file(filename)
        opened = wx_text_file_open(file)
        if (.not. opened) then
            call wx_text_file_delete(file)
            return
        end if

        charset = ""
        prefix = "Content-Type: text/plain; charset="
        count = int(wx_text_file_get_line_count(file))

        do n = 0, count - 1
            line = wx_text_file_get_line(file, int(n, c_int))
            if (len(line) == 0) exit

            if (len(line) >= len(prefix)) then
                if (line(1:len(prefix)) == prefix) then
                    pos = len(prefix) + 1
                    if (pos <= len(line)) then
                        if (line(pos:pos) == '"') pos = pos + 1
                    end if
                    do while (pos <= len(line))
                        ch = line(pos:pos)
                        if (ch == '"') exit
                        charset = charset // ch
                        pos = pos + 1
                    end do
                    exit
                end if
            end if
        end do

        if (len(charset) == 0) then
            call show_error("The file '" // filename // &
                "' doesn't contain charset information.")
            call wx_text_file_delete(file)
            return
        end if

        fontenc = int(wx_font_mapper_charset_to_encoding( &
            wx_font_mapper_get(), charset, .true.))
        if (fontenc == int(wxFONTENCODING_SYSTEM())) then
            call show_error("Charset '" // charset // "' is unsupported.")
            call wx_text_file_delete(file)
            return
        end if

        if (.not. wx_text_ctrl_load_file(g_textctrl, filename, &
            int(wxTEXT_TYPE_ANY(), c_int))) rc = 1

        ! C++: when the encoding is UTF-8 or unavailable, try an equivalent encoding
        ! and transcode the text with wxEncodingConverter.
        if (fontenc == int(wxFONTENCODING_UTF8()) .or. &
            .not. wx_font_mapper_is_encoding_available(wx_font_mapper_get(), &
                int(fontenc, c_int), "")) then
            block
                integer(c_int), target :: enc_alt
                integer(c_int) :: init_rc
                type(wxEncodingConverter_t) :: conv
                character(len=:), allocatable :: value

                enc_alt = int(wxFONTENCODING_SYSTEM(), c_int)
                if (wx_font_mapper_get_alt_for_encoding(wx_font_mapper_get(), &
                        int(fontenc, c_int), c_loc(enc_alt), "")) then
                    conv = wx_encoding_converter_create()
                    init_rc = wx_encoding_converter_init(conv, int(fontenc, c_int), &
                        enc_alt, 0_c_int)
                    if (init_rc /= 0) then
                        fontenc = int(enc_alt)
                        value = wx_text_ctrl_get_value(g_textctrl)
                        call wx_text_ctrl_set_value(g_textctrl, &
                            wx_encoding_converter_convert_string(conv, value))
                    else
                        call show_warning("Cannot convert from '" // &
                            wx_font_mapper_get_encoding_description(int(fontenc, c_int)) // &
                            "' to '" // &
                            wx_font_mapper_get_encoding_description(enc_alt) // "'.")
                    end if
                    call wx_encoding_converter_delete(conv)
                else
                    call show_warning("No fonts for encoding '" // &
                        wx_font_mapper_get_encoding_description(int(fontenc, c_int)) // &
                        "' on this system.")
                end if
            end block
        end if

        if (.not. do_enumerate_families(.false., fontenc, .true.)) then
            block
                type(wxFontInfo_t) :: info
                type(wxFont_t) :: f
                integer :: pts

                pts = int(wx_font_get_point_size(normal_font()))
                info = wx_font_info_create(real(pts, c_double))
                call wx_font_info_set_encoding(info, int(fontenc, c_int))
                f = wx_font_create_from_info(info)
                if (wx_font_is_ok(f)) then
                    call do_change_font(f)
                else
                    call show_warning("No fonts for encoding '" // &
                        wx_font_mapper_get_encoding_description(int(fontenc, c_int)) // &
                        "' on this system.")
                end if
                call wx_font_delete(f)
                call wx_font_info_delete(info)
            end block
        end if

        call wx_text_file_delete(file)
    end subroutine on_view_msg

    subroutine on_about(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call show_message("wxWidgets font sample" // nl() // &
            "(c) 1999-2006 Vadim Zeitlin", "About wxWidgets Font Sample", &
            ior(wxOK(), wxICON_INFORMATION()))
    end subroutine on_about

    subroutine on_get_base_font(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f

        if (.not. c_associated(evt)) return
        ! wxFont_GetBaseFont() allocates a new wxFont in the FFI.
        f = wx_font_get_base_font(g_font)
        f%owned = .true.
        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine on_get_base_font

    subroutine on_inc_font(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call do_resize_font(2)
    end subroutine on_inc_font

    subroutine on_dec_font(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call do_resize_font(-2)
    end subroutine on_dec_font

    subroutine on_bold(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f

        if (.not. c_associated(evt)) return
        f = copy_font(g_font)
        if (wx_command_event_is_checked(evt)) then
            call wx_font_set_weight(f, int(wxFONTWEIGHT_BOLD(), c_int))
        else
            call wx_font_set_weight(f, int(wxFONTWEIGHT_NORMAL(), c_int))
        end if
        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine on_bold

    subroutine on_light(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f

        if (.not. c_associated(evt)) return
        f = copy_font(g_font)
        if (wx_command_event_is_checked(evt)) then
            call wx_font_set_weight(f, int(wxFONTWEIGHT_LIGHT(), c_int))
        else
            call wx_font_set_weight(f, int(wxFONTWEIGHT_NORMAL(), c_int))
        end if
        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine on_light

    subroutine on_italic(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f

        if (.not. c_associated(evt)) return
        f = copy_font(g_font)
        if (wx_command_event_is_checked(evt)) then
            call wx_font_set_style(f, int(wxFONTSTYLE_ITALIC(), c_int))
        else
            call wx_font_set_style(f, int(wxFONTSTYLE_NORMAL(), c_int))
        end if
        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine on_italic

    subroutine on_slant(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f

        if (.not. c_associated(evt)) return
        f = copy_font(g_font)
        if (wx_command_event_is_checked(evt)) then
            call wx_font_set_style(f, int(wxFONTSTYLE_SLANT(), c_int))
        else
            call wx_font_set_style(f, int(wxFONTSTYLE_NORMAL(), c_int))
        end if
        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine on_slant

    subroutine on_underline(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f
        logical :: checked

        if (.not. c_associated(evt)) return
        f = copy_font(g_font)
        checked = wx_command_event_is_checked(evt)
        call wx_font_set_underlined(f, merge(1_c_int, 0_c_int, checked))
        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine on_underline

    subroutine on_strikethrough(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f

        if (.not. c_associated(evt)) return
        f = copy_font(g_font)
        call wx_font_set_strikethrough(f, wx_command_event_is_checked(evt))
        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine on_strikethrough

    subroutine on_pointer_font(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f
        integer :: id

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)
        if (id == id_normal_font) then
            f = wxfont_from_ptr(wxNORMAL_FONT(), .false.)
        else if (id == id_small_font) then
            f = wxfont_from_ptr(wxSMALL_FONT(), .false.)
        else if (id == id_italic_font) then
            f = wxfont_from_ptr(wxITALIC_FONT(), .false.)
        else if (id == id_swiss_font) then
            f = wxfont_from_ptr(wxSWISS_FONT(), .false.)
        else
            return
        end if
        call do_change_font(f)
    end subroutine on_pointer_font

    subroutine on_font_default(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFontInfo_t) :: info
        type(wxFont_t) :: f

        if (.not. c_associated(evt)) return
        info = wx_font_info_create_default()
        f = wx_font_create_from_info(info)
        call do_change_font(f)
        call wx_font_delete(f)
        call wx_font_info_delete(info)
    end subroutine on_font_default

    subroutine on_system_font(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f
        integer :: id

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)
        f = wx_font_create_default()

        if (id == id_sys_oem_fixed) then
            call wx_system_settings_get_font(int(wxSYS_OEM_FIXED_FONT(), c_int), f)
        else if (id == id_sys_ansi_fixed) then
            call wx_system_settings_get_font(int(wxSYS_ANSI_FIXED_FONT(), c_int), f)
        else if (id == id_sys_ansi_var) then
            call wx_system_settings_get_font(int(wxSYS_ANSI_VAR_FONT(), c_int), f)
        else if (id == id_sys_system) then
            call wx_system_settings_get_font(int(wxSYS_SYSTEM_FONT(), c_int), f)
        else if (id == id_sys_device_default) then
            call wx_system_settings_get_font(int(wxSYS_DEVICE_DEFAULT_FONT(), c_int), f)
        else if (id == id_sys_default_gui) then
            call wx_system_settings_get_font(int(wxSYS_DEFAULT_GUI_FONT(), c_int), f)
        else
            call wx_font_delete(f)
            return
        end if

        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine on_system_font

    subroutine on_set_native_desc(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f
        character(len=:), allocatable :: default_info, font_info
        logical :: ok

        if (.not. c_associated(evt)) return
        default_info = wx_font_get_native_font_info_desc(g_font)
        font_info = get_text_from_user("Enter native font string", &
            "Input font description", default_info)
        if (len(font_info) == 0) return

        f = wx_font_create_default()
        ok = wx_font_set_native_font_info(f, font_info)
        if (.not. ok .or. .not. wx_font_is_ok(f)) then
            call show_error('Font info string "' // font_info // '" is invalid.')
            call wx_font_delete(f)
            return
        end if
        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine on_set_native_desc

    subroutine on_set_native_user_desc(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f
        character(len=:), allocatable :: desc, user_info
        logical :: ok

        if (.not. c_associated(evt)) return
        desc = wx_font_get_native_font_info_user_desc(g_font)
        user_info = get_text_from_user("Here you can edit current font description", &
            "Input font description", desc)
        if (len(user_info) == 0) return

        f = wx_font_create_default()
        ok = wx_font_set_native_font_info_user_desc(f, user_info)
        if (ok) then
            call do_change_font(f)
        else
            call show_message("Error trying to create a font with such description...", &
                "", ior(wxOK(), wxICON_ERROR()))
        end if
        call wx_font_delete(f)
    end subroutine on_set_native_user_desc

    subroutine on_set_family(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f
        integer :: fam

        if (.not. c_associated(evt)) return
        fam = get_family_from_user()
        f = copy_font(g_font)
        call wx_font_set_family(f, int(fam, c_int))
        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine on_set_family

    subroutine on_set_face_name(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f
        character(len=:), allocatable :: face, new_face

        if (.not. c_associated(evt)) return
        face = wx_font_get_face_name(g_font)
        new_face = get_text_from_user("Here you can edit current font face name.", &
            "Input font facename", face)
        if (len(new_face) == 0) return

        f = copy_font(g_font)
        call wx_font_set_face_name(f, new_face)
        if (wx_font_is_ok(f)) then
            call do_change_font(f)
        else
            call show_message("There is no font with such face name...", &
                "Invalid face name", ior(wxOK(), wxICON_ERROR()))
        end if
        call wx_font_delete(f)
    end subroutine on_set_face_name

    subroutine on_set_encoding(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f
        integer :: enc

        if (.not. c_associated(evt)) return
        enc = get_encoding_from_user()
        if (enc == int(wxFONTENCODING_SYSTEM())) return

        f = copy_font(g_font)
        call wx_font_set_encoding(f, int(enc, c_int))
        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine on_set_encoding

    subroutine on_select_font(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFontData_t) :: data_in, data_out
        type(wxFontDialog_t) :: dlg
        type(wxFont_t) :: f
        type(wxColour_t) :: c
        integer :: rc

        if (.not. c_associated(evt)) return

        data_in = wx_font_data_create()
        call wx_font_data_set_initial_font(data_in, g_font)
        call wx_font_data_set_colour(data_in, g_colour)

        dlg = wx_font_dialog_create(g_frame, data_in)
        rc = wx_dialog_show_modal(dlg)
        if (rc == int(wxID_OK())) then
            data_out = wx_font_data_create()
            call wx_font_dialog_get_font_data(dlg, data_out)
            f = wx_font_create_default()
            call wx_font_data_get_chosen_font(data_out, f)
            c = wx_colour_create_empty()
            call wx_font_data_get_colour(data_out, c)
            call do_change_font(f, c)
            call wx_colour_delete(c)
            call wx_font_delete(f)
            call wx_font_data_delete(data_out)
        end if
        call wx_font_dialog_delete(dlg)
        call wx_font_data_delete(data_in)
    end subroutine on_select_font

    subroutine on_private_font(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f

        if (.not. c_associated(evt)) return
        f = copy_font(g_font)
        call wx_font_set_face_name(f, "wxprivate")
        if (wx_font_is_ok(f)) then
            call do_change_font(f)
        else
            call show_error("Failed to use private font.")
        end if
        call wx_font_delete(f)
    end subroutine on_private_font

    subroutine on_enum_families_for_encoding(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: enc
        logical :: found

        if (.not. c_associated(evt)) return
        enc = get_encoding_from_user()
        if (enc /= int(wxFONTENCODING_SYSTEM())) then
            found = do_enumerate_families(.false., enc, .false.)
        end if
    end subroutine on_enum_families_for_encoding

    subroutine on_enum_families(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: found

        if (.not. c_associated(evt)) return
        found = do_enumerate_families(.false., int(wxFONTENCODING_SYSTEM()), .false.)
    end subroutine on_enum_families

    subroutine on_enum_fixed_families(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: found

        if (.not. c_associated(evt)) return
        found = do_enumerate_families(.true., int(wxFONTENCODING_SYSTEM()), .false.)
    end subroutine on_enum_fixed_families

    ! MyEncodingEnumerator::OnFontEncoding. The FFI passes "facename|encoding" as a
    ! NUL-terminated UTF-8 C string; return non-zero to keep enumerating.
    function on_font_encoding(pobject, ptext) bind(C) result(keep)
        type(c_ptr), value :: pobject, ptext
        integer(c_int) :: keep
        character(len=:), allocatable :: combined, facename, encoding
        integer :: bar

        combined = from_cstring(ptext)
        bar = index(combined, "|")
        if (bar > 0) then
            facename = combined(1:bar - 1)
            encoding = combined(bar + 1:)
        else
            facename = ""
            encoding = combined
        end if
        g_enc_count = g_enc_count + 1
        g_enc_text = g_enc_text // "Encoding " // itoa(g_enc_count) // ": " // &
            encoding // " (available in facename '" // facename // "')" // nl()
        keep = 1_c_int
    end function on_font_encoding

    subroutine on_enum_encodings(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFontEnumerator_t) :: enumerator
        logical :: ok

        if (.not. c_associated(evt)) return

        g_enc_text = ""
        g_enc_count = 0
        enumerator = wx_font_enumerator_create(c_null_ptr, &
            transfer(c_funloc(on_font_encoding), c_null_ptr))
        ok = wx_font_enumerator_enumerate_encodings(enumerator, "")
        call show_info("Enumerating all available encodings:" // nl() // g_enc_text)
        call wx_font_enumerator_delete(enumerator)
    end subroutine on_enum_encodings

    ! MyFrame::OnFontPanelApply (bound on the FontWindow)
    subroutine on_font_panel_apply(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFont_t) :: f

        if (.not. c_associated(evt)) return
        f = make_new_font()
        call do_change_font(f)
        call wx_font_delete(f)
    end subroutine on_font_panel_apply

    ! ------------------------------------------------------------------
    ! FontPanel control handlers
    ! ------------------------------------------------------------------

    subroutine on_facename(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        g_use_family = .false.
        call wx_event_skip(evt, .true.)
    end subroutine on_facename

    subroutine on_family(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        g_use_family = .true.
        call wx_event_skip(evt, .true.)
    end subroutine on_family

    subroutine on_weight_choice(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        g_use_numeric_weight = .false.
        call wx_event_skip(evt, .true.)
    end subroutine on_weight_choice

    subroutine on_weight_spin(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        g_use_numeric_weight = .true.
        call wx_event_skip(evt, .true.)
    end subroutine on_weight_spin

    ! ------------------------------------------------------------------
    ! FontCanvas::OnPaint
    ! ------------------------------------------------------------------

    subroutine on_paint(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxPaintDC_t) :: dc
        type(wxBrush_t) :: white
        type(wxPen_t) :: blue
        type(wxSize_t) :: extent
        type(wxSize_t) :: char_extent
        character(len=:), allocatable :: text
        integer :: i, j, code, l
        integer :: max_w, max_h, cell_w, cell_h
        integer :: char_w, char_h, xpos, ypos
        integer :: x0, y0

        if (.not. c_associated(evt)) return

        dc = wx_paint_dc_create(g_canvas)
        call wx_window_prepare_dc(g_canvas, dc)

        white = wxbrush_from_ptr(wxWHITE_BRUSH(), .false.)
        call wx_dc_set_background(dc, white)
        call wx_dc_clear(dc)
        call wx_dc_set_font(dc, g_font)

        x0 = 5
        y0 = 5

        call wx_dc_set_text_foreground(dc, g_colour)

        extent = wx_dc_get_text_extent_size(dc, "W")
        max_w = int(wx_size_get_width(extent))
        max_h = int(wx_size_get_height(extent))
        cell_w = max_w + 5
        cell_h = max_h + 4

        do i = 0, 6
            do j = 0, 31
                code = 32 * (i + 1) + j
                text = utf8_char(code)
                char_extent = wx_dc_get_text_extent_size(dc, text)
                char_w = int(wx_size_get_width(char_extent))
                char_h = int(wx_size_get_height(char_extent))
                xpos = x0 + cell_w * j + (max_w - char_w) / 2 + 1
                ypos = y0 + cell_h * i + (max_h - char_h) / 2
                call wx_dc_draw_text(dc, text, int(xpos, c_int), int(ypos, c_int))
            end do
        end do

        blue = wxpen_from_ptr(wxBLUE_PEN(), .false.)
        call wx_dc_set_pen(dc, blue)

        do l = 0, 7
            ypos = y0 + cell_h * l - 2
            call wx_dc_draw_line(dc, int(x0 - 2, c_int), int(ypos, c_int), &
                int(x0 + 32 * cell_w - 1, c_int), int(ypos, c_int))
        end do

        do l = 0, 32
            xpos = x0 + cell_w * l - 2
            call wx_dc_draw_line(dc, int(xpos, c_int), int(y0 - 2, c_int), &
                int(xpos, c_int), int(y0 + 7 * cell_h - 1, c_int))
        end do

        call wx_paint_dc_delete(dc)
    end subroutine on_paint

end module font_handlers


program font
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_app
    use wx_frame
    use wx_window
    use wx_panel
    use wx_splitter_window
    use wx_menu
    use wx_menu_bar
    use wx_events
    use wx_sizer
    use wx_box_sizer
    use wx_flex_grid_sizer
    use wx_static_text
    use wx_static_line
    use wx_text_ctrl
    use wx_choice
    use wx_spin_ctrl
    use wx_spin_ctrl_double
    use wx_check_box
    use wx_button
    use wx_control
    use wx_font
    use wx_colour
    use wx_bitmap_bundle
    use wx_icon
    use wx_size
    use font_globals
    use font_util
    use font_handlers
    implicit none

    type(wxBoxSizer_t) :: sizer, sizer_top
    type(wxFlexGridSizer_t) :: grid
    type(wxSize_t) :: size
    type(wxBitmap_t) :: bitmap
    type(wxSize_t) :: icon_size
    type(wxFont_t) :: initial_font
    character(len=:), allocatable :: status
    integer(c_int) :: tw, th, descent, ext, cw, ch
    integer(c_int) :: ww, hh
    integer :: n, exit_code, rc
    logical :: ok
    integer :: styles(3)
    integer :: families(7)
    integer :: weights(10)

    ! ================================================================
    ! Bootstrap
    ! ================================================================

    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    call wx_set_app_name("wxWidgets Font Sample")

    call init_font_ids()
    g_border = int(wx_sizer_get_default_border())
    g_msg_dir = ""
    g_msg_file = ""

    initial_font = normal_font()
    g_font = copy_font(initial_font)
    ! wxUint8 255 is represented by the signed c_int8_t value -1.
    g_colour = wx_colour_create_rgb(int(-1, c_int8_t), int(0, c_int8_t), &
        int(0, c_int8_t), int(-1, c_int8_t))

    ! C++: wxFont::AddPrivateFont("wxprivate.ttf") inside the frame ctor.
    g_has_private_font = wx_font_add_private_font("wxprivate.ttf")
    if (.not. g_has_private_font) then
        call show_warning('Failed to add private font from "wxprivate.ttf"')
    end if

    ! ================================================================
    ! Main frame
    ! ================================================================

    block
        type(wxWindow_t) :: no_parent

        g_frame = wx_frame_create(no_parent, int(wxID_ANY(), c_int), &
            "wxWidgets font sample", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            int(wxDEFAULT_FRAME_STYLE(), c_int))
    end block
    if (.not. g_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    call build_menu()
    call build_left_parts()
    call set_icon()
    call connect_events()

    ! CreateStatusBar(); SetStatusText("Welcome to wxWidgets font demo!")
    block
        type(wxStatusBar_t) :: sb
        sb = wx_frame_create_status_bar(g_frame, 1_c_int, &
            int(wxSTB_DEFAULT_STYLE(), c_int), int(wxID_ANY(), c_int))
    end block
    call wx_frame_set_status_text(g_frame, "Welcome to wxWidgets font demo!", 0_c_int)

    ! SetClientSize(splitter->GetBestSize())
    size = wx_window_get_best_size(g_splitter)
    call wx_window_set_client_size(g_frame, wx_size_get_width(size), &
        wx_size_get_height(size))

    ! splitter->SetSashPosition(m_fontWindow->GetBestSize().y)
    size = wx_window_get_best_size(g_font_window)
    call wx_splitter_window_set_sash_position(g_splitter, &
        wx_size_get_height(size), .true.)

    call wx_set_top_window(g_frame)
    ok = wx_window_show(g_frame)

    exit_code = wx_main_loop()

    call wx_font_delete(g_font)
    call wx_colour_delete(g_colour)

    call wx_shutdown()

contains

    subroutine build_menu()
        integer :: dummy

        g_file_menu = wx_menu_create("", 0_c_long)

        call wx_menu_append(g_file_menu, int(id_test_text_value, c_int), &
            "&Test text value", &
            "Verify that getting and setting text value doesn't change it", .false.)
        call wx_menu_append(g_file_menu, int(id_view_msg, c_int), &
            "&View..." // achar(9) // "Ctrl-V", "View an email message file", .false.)
        call wx_menu_append_separator(g_file_menu)
        call wx_menu_append(g_file_menu, int(wxID_ABOUT(), c_int), &
            "&About" // achar(9) // "Ctrl-A", "Show about dialog", .false.)
        call wx_menu_append_separator(g_file_menu)
        call wx_menu_append(g_file_menu, int(wxID_EXIT(), c_int), &
            "E&xit" // achar(9) // "Alt-X", "Quit this program", .false.)

        g_font_menu = wx_menu_create("", 0_c_long)

        call wx_menu_append(g_font_menu, int(id_inc_size, c_int), &
            "&Increase font size by 2 points" // achar(9) // "Ctrl-I", "", .false.)
        call wx_menu_append(g_font_menu, int(id_dec_size, c_int), &
            "&Decrease font size by 2 points" // achar(9) // "Ctrl-D", "", .false.)
        call wx_menu_append(g_font_menu, int(id_get_base_font, c_int), &
            "Use &base version of the font" // achar(9) // "Ctrl-0", "", .false.)
        call wx_menu_append_separator(g_font_menu)
        call wx_menu_append(g_font_menu, int(id_bold, c_int), &
            "&Bold" // achar(9) // "Ctrl-B", "Toggle bold state", .true.)
        call wx_menu_append(g_font_menu, int(id_light, c_int), &
            "&Light" // achar(9) // "Ctrl-L", "Toggle light state", .true.)
        call wx_menu_append_separator(g_font_menu)
        call wx_menu_append(g_font_menu, int(id_italic, c_int), &
            "&Oblique" // achar(9) // "Ctrl-O", "Toggle italic state", .true.)
        ! wxMSW: slant == italic, so the C++ sample does not add Font_Slant.
        call wx_menu_append_separator(g_font_menu)
        call wx_menu_append(g_font_menu, int(id_underlined, c_int), &
            "&Underlined" // achar(9) // "Ctrl-U", "Toggle underlined state", .true.)
        call wx_menu_append(g_font_menu, int(id_strikethrough, c_int), &
            "&Strikethrough", "Toggle strikethrough state", .true.)
        call wx_menu_append_separator(g_font_menu)
        call wx_menu_append(g_font_menu, int(id_set_native_desc, c_int), &
            "Set native font &description" // achar(9) // "Shift-Ctrl-D", "", .false.)
        call wx_menu_append(g_font_menu, int(id_set_native_user_desc, c_int), &
            "Set &user font description" // achar(9) // "Shift-Ctrl-U", "", .false.)
        call wx_menu_append_separator(g_font_menu)
        call wx_menu_append(g_font_menu, int(id_set_family, c_int), &
            "Set font family", "", .false.)
        call wx_menu_append(g_font_menu, int(id_set_face_name, c_int), &
            "Set font face name", "", .false.)
        call wx_menu_append(g_font_menu, int(id_set_encoding, c_int), &
            "Set font &encoding" // achar(9) // "Shift-Ctrl-E", "", .false.)

        g_select_menu = wx_menu_create("", 0_c_long)

        call wx_menu_append(g_select_menu, int(id_choose, c_int), &
            "&Select font..." // achar(9) // "Ctrl-S", "Select a standard font", .false.)

        g_std_fonts_menu = wx_menu_create("", 0_c_long)
        call wx_menu_append(g_std_fonts_menu, int(id_normal_font, c_int), &
            "wxNORMAL_FONT", "Normal font used by wxWidgets", .false.)
        call wx_menu_append(g_std_fonts_menu, int(id_small_font, c_int), &
            "wxSMALL_FONT", "Small font used by wxWidgets", .false.)
        call wx_menu_append(g_std_fonts_menu, int(id_italic_font, c_int), &
            "wxITALIC_FONT", "Italic font used by wxWidgets", .false.)
        call wx_menu_append(g_std_fonts_menu, int(id_swiss_font, c_int), &
            "wxSWISS_FONT", "Swiss font used by wxWidgets", .false.)
        call wx_menu_append(g_std_fonts_menu, int(id_font_default, c_int), &
            "wxFont()", "wxFont constructed from default wxFontInfo", .false.)
        call wx_menu_append_sub(g_select_menu, int(id_standard, c_int), &
            "Standar&d fonts", g_std_fonts_menu, "")

        g_sys_fonts_menu = wx_menu_create("", 0_c_long)
        call wx_menu_append(g_sys_fonts_menu, int(id_sys_oem_fixed, c_int), &
            "wxSYS_OEM_FIXED_FONT", &
            "Original equipment manufacturer dependent fixed-pitch font.", .false.)
        call wx_menu_append(g_sys_fonts_menu, int(id_sys_ansi_fixed, c_int), &
            "wxSYS_ANSI_FIXED_FONT", "Windows fixed-pitch (monospaced) font. ", .false.)
        call wx_menu_append(g_sys_fonts_menu, int(id_sys_ansi_var, c_int), &
            "wxSYS_ANSI_VAR_FONT", "Windows variable-pitch (proportional) font.", .false.)
        call wx_menu_append(g_sys_fonts_menu, int(id_sys_system, c_int), &
            "wxSYS_SYSTEM_FONT", "System font.", .false.)
        call wx_menu_append(g_sys_fonts_menu, int(id_sys_device_default, c_int), &
            "wxSYS_DEVICE_DEFAULT_FONT", "Device-dependent font.", .false.)
        call wx_menu_append(g_sys_fonts_menu, int(id_sys_default_gui, c_int), &
            "wxSYS_DEFAULT_GUI_FONT", &
            "Default font for user interface objects such as menus and dialog boxes. ", &
            .false.)
        call wx_menu_append_sub(g_select_menu, int(id_system_settings, c_int), &
            "System fonts", g_sys_fonts_menu, "")

        call wx_menu_append_separator(g_select_menu)
        call wx_menu_append(g_select_menu, int(id_enum_families, c_int), &
            "Enumerate font &families" // achar(9) // "Ctrl-F", "", .false.)
        call wx_menu_append(g_select_menu, int(id_enum_fixed_families, c_int), &
            "Enumerate fi&xed font families" // achar(9) // "Ctrl-X", "", .false.)
        call wx_menu_append(g_select_menu, int(id_enum_encodings, c_int), &
            "Enumerate &encodings" // achar(9) // "Ctrl-E", "", .false.)
        call wx_menu_append(g_select_menu, int(id_enum_families_for_encoding, c_int), &
            "Find font for en&coding..." // achar(9) // "Ctrl-C", &
            "Find font families for given encoding", .false.)

        if (g_has_private_font) then
            call wx_menu_append_separator(g_select_menu)
            call wx_menu_append(g_select_menu, int(id_private, c_int), &
                "Select private font", &
                "Select a font available only in this application", .false.)
        end if

        g_menu_bar = wx_menu_bar_create(0_c_int)
        dummy = wx_menu_bar_append(g_menu_bar, g_file_menu, "&File")
        dummy = wx_menu_bar_append(g_menu_bar, g_font_menu, "F&ont")
        dummy = wx_menu_bar_append(g_menu_bar, g_select_menu, "&Select")
        call wx_frame_set_menu_bar(g_frame, g_menu_bar)
    end subroutine build_menu

    subroutine build_left_parts()
        integer :: i

        ! wxSplitterWindow(this)
        g_splitter = wx_splitter_window_create(g_frame, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, int(wxSP_3D(), c_int))

        ! FontWindow(splitter)
        g_font_window = wx_window_create(g_splitter, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)

        call build_font_panel()
        call build_font_canvas()
        call build_font_window_sizer()

        ! m_textctrl = new wxTextCtrl(splitter, wxID_ANY,
        !     "Paste text here to see how it looks\nlike in the given font",
        !     wxDefaultPosition, wxSize(-1, 6*GetCharHeight()), wxTE_MULTILINE)
        ch = wx_window_get_char_height(g_frame)
        g_textctrl = wx_text_ctrl_create(g_splitter, int(wxID_ANY(), c_int), &
            "Paste text here to see how it looks" // achar(10) // &
            "like in the given font", -1_c_int, -1_c_int, -1_c_int, &
            int(6 * ch, c_int), int(wxTE_MULTILINE(), c_long))

        ok = wx_splitter_window_split_horizontally(g_splitter, g_font_window, &
            g_textctrl, 0_c_int)
    end subroutine build_left_parts

    subroutine build_font_panel()
        type(wxBoxSizer_t) :: top
        character(len=10) :: family_names(7)
        character(len=6) :: style_names(3)
        character(len=12) :: weight_names(10)
        integer :: flag_label, flag_value

        g_panel = wx_panel_create(g_font_window, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)

        g_face_name = wx_text_ctrl_create(g_panel, int(wxID_ANY(), c_int), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            int(wxTE_PROCESS_ENTER(), c_long))

        family_names = [character(len=10) :: "Default", "Decorative", "Roman", &
            "Script", "Swiss", "Modern", "Teletype"]
        g_choice_family = wx_choice_create(g_panel, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, family_names, 0_c_int)

        g_spin_point_size = wx_spin_ctrl_double_create(g_panel, &
            int(wxID_ANY(), c_int), "", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            int(wxSP_ARROW_KEYS(), c_int), 1.0_c_double, 100.0_c_double, &
            10.0_c_double, 0.1_c_double)

        ! SetInitialSize(GetSizeFromTextSize(GetTextExtent("999.9").x))
        call wx_window_get_text_extent(g_panel, "999.9", tw, th, descent, ext, &
            normal_font())
        call wx_control_get_size_from_text_size(g_spin_point_size, tw, &
            int(-1, c_int), ww, hh)
        ok = wx_window_set_initial_size(g_spin_point_size, ww, hh)

        style_names = [character(len=6) :: "Normal", "Italic", "Slant"]
        g_choice_style = wx_choice_create(g_panel, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, style_names, 0_c_int)

        weight_names = [character(len=12) :: "Thin", "Extra light", "Light", &
            "Normal", "Medium", "Semi-bold", "Bold", "Extra bold", "Heavy", &
            "Extra heavy"]
        g_choice_weight = wx_choice_create(g_panel, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, weight_names, 0_c_int)

        g_spin_weight = wx_spin_ctrl_create(g_panel, int(wxID_ANY(), c_int), "", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            int(wxSP_ARROW_KEYS(), c_long), 1_c_int, &
            int(wxFONTWEIGHT_MAX(), c_int), 1_c_int)

        ! SetInitialSize(GetSizeFromTextSize(GetTextExtent("9999").x))
        call wx_window_get_text_extent(g_panel, "9999", tw, th, descent, ext, &
            normal_font())
        call wx_control_get_size_from_text_size(g_spin_weight, tw, &
            int(-1, c_int), ww, hh)
        ok = wx_window_set_initial_size(g_spin_weight, ww, hh)

        g_check_underlined = wx_check_box_create(g_panel, int(wxID_ANY(), c_int), &
            "", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        g_check_strikethrough = wx_check_box_create(g_panel, &
            int(wxID_ANY(), c_int), "", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        g_check_fixed_width = wx_check_box_create(g_panel, &
            int(wxID_ANY(), c_int), "", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        ok = wx_window_disable(g_check_fixed_width)

        g_label_info = wx_static_text_create(g_panel, int(wxID_ANY(), c_int), &
            achar(10) // achar(10) // achar(10), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)

        flag_label = int(wxALIGN_CENTER_VERTICAL())
        flag_value = ior(int(wxEXPAND()), int(wxALIGN_CENTER_VERTICAL()))

        ! wxFlexGridSizer(7, wxSize(border, border))
        grid = wx_flex_grid_sizer_create(0_c_int, 7_c_int, &
            int(g_border, c_int), int(g_border, c_int))

        call add_window(grid, wx_static_text_create(g_panel, int(wxID_ANY(), c_int), &
            "Face &name:", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int), &
            0, flag_label, 0)
        call add_window(grid, g_face_name, 0, flag_value, 0)
        call add_spacer(grid, 2 * g_border)
        call add_window(grid, wx_static_text_create(g_panel, int(wxID_ANY(), c_int), &
            "&Family:", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int), &
            0, flag_label, 0)
        call add_window(grid, g_choice_family, 0, flag_value, 0)
        call add_window(grid, wx_static_text_create(g_panel, int(wxID_ANY(), c_int), &
            "&Point size:", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int), &
            0, ior(int(wxALIGN_CENTER_VERTICAL()), int(wxLEFT())), 2 * g_border)
        call add_window(grid, g_spin_point_size, 0, flag_value, 0)

        call add_window(grid, wx_static_text_create(g_panel, int(wxID_ANY(), c_int), &
            "&Style:", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int), &
            0, flag_label, 0)
        call add_window(grid, g_choice_style, 0, flag_value, 0)
        call add_spacer(grid, 0)
        call add_window(grid, wx_static_text_create(g_panel, int(wxID_ANY(), c_int), &
            "&Weight:", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int), &
            0, flag_label, 0)
        call add_window(grid, g_choice_weight, 0, flag_value, 0)
        call add_window(grid, wx_static_text_create(g_panel, int(wxID_ANY(), c_int), &
            "or &raw value:", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int), &
            0, flag_label, 0)
        call add_window(grid, g_spin_weight, 0, flag_value, 0)

        call add_window(grid, wx_static_text_create(g_panel, int(wxID_ANY(), c_int), &
            "&Underlined:", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int), &
            0, flag_label, 0)
        call add_window(grid, g_check_underlined, 0, flag_value, 0)
        call add_spacer(grid, 0)
        call add_window(grid, wx_static_text_create(g_panel, int(wxID_ANY(), c_int), &
            "&Strike through:", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int), &
            0, flag_label, 0)
        call add_window(grid, g_check_strikethrough, 0, flag_value, 0)
        call add_window(grid, wx_static_text_create(g_panel, int(wxID_ANY(), c_int), &
            "Fixed width:", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int), &
            0, flag_label, 0)
        call add_window(grid, g_check_fixed_width, 0, flag_value, 0)

        top = wx_box_sizer_create(int(wxVERTICAL(), c_int))
        call add_sizer(top, grid, 0, ior(int(wxEXPAND()), int(wxBOTTOM())), g_border)

        g_apply_button = wx_button_create(g_panel, int(wxID_APPLY(), c_int), &
            "&Apply changes", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_window(top, g_apply_button, 0, &
            ior(ior(int(wxBOTTOM()), int(wxALIGN_CENTER_HORIZONTAL())), &
                int(wxALIGN_CENTER_VERTICAL())), g_border)
        call add_window(top, g_label_info, 0, &
            ior(int(wxEXPAND()), int(wxTOP())), g_border)

        call wx_window_set_sizer(g_panel, top, .false.)

        ! ShowFont(*wxNORMAL_FONT) at the end of the FontPanel constructor.
        call panel_update()
    end subroutine build_font_panel

    subroutine build_font_canvas()
        g_canvas = wx_window_create(g_font_window, int(wxID_ANY(), c_int), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)

        ! DoGetBestClientSize(): wxSize(80*GetCharWidth(), 15*GetCharHeight()).
        ! A plain wxWindow cannot override the virtual, so cache the same best size.
        cw = wx_window_get_char_width(g_canvas)
        ch = wx_window_get_char_height(g_canvas)
        call wx_window_cache_best_size(g_canvas, int(80 * cw, c_int), int(15 * ch, c_int))
        ok = wx_window_set_initial_size(g_canvas, int(80 * cw, c_int), int(15 * ch, c_int))
    end subroutine build_font_canvas

    subroutine build_font_window_sizer()
        sizer = wx_box_sizer_create(int(wxVERTICAL(), c_int))

        call add_window(sizer, g_panel, 0, &
            ior(int(wxEXPAND()), int(wxALL())), g_border)
        g_static_line = wx_static_line_create(g_font_window, &
            int(wxID_ANY(), c_int), -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call add_window(sizer, g_static_line, 0, int(wxEXPAND()), 0)
        call add_window(sizer, g_canvas, 1, int(wxEXPAND()), 0)

        call wx_window_set_sizer(g_font_window, sizer, .false.)
    end subroutine build_font_window_sizer

    subroutine set_icon()
        icon_size = wx_size_create(32_c_int, 32_c_int)
        g_icon_bundle = wx_bitmap_bundle_from_svg_file("sample.svg", 32_c_int, 32_c_int)
        if (.not. wx_bitmap_bundle_is_ok(g_icon_bundle)) return

        ! wxBitmapBundle::GetBitmap(wxSize) is bound as (width, height).
        bitmap = wx_bitmap_bundle_get_bitmap(g_icon_bundle, &
            wx_size_get_width(icon_size), wx_size_get_height(icon_size))
        g_icon = wx_icon_create_default()
        call wx_icon_copy_from_bitmap(g_icon, bitmap)
        call wx_frame_set_icon(g_frame, g_icon)
        call wx_icon_delete(g_icon)
    end subroutine set_icon

    subroutine connect_events()
        ! Menu items on the frame.
        call wx_connect(g_frame, int(wxEVT_MENU()), on_quit, id=int(wxID_EXIT()))
        call wx_connect(g_frame, int(wxEVT_MENU()), on_test_text_value, &
            id=id_test_text_value)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_view_msg, id=id_view_msg)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_about, id=int(wxID_ABOUT()))

        call wx_connect(g_frame, int(wxEVT_MENU()), on_get_base_font, &
            id=id_get_base_font)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_inc_font, id=id_inc_size)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_dec_font, id=id_dec_size)

        call wx_connect(g_frame, int(wxEVT_MENU()), on_bold, id=id_bold)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_light, id=id_light)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_italic, id=id_italic)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_slant, id=id_slant)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_underline, id=id_underlined)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_strikethrough, &
            id=id_strikethrough)

        call wx_connect(g_frame, int(wxEVT_MENU()), on_pointer_font, &
            id=id_normal_font)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_pointer_font, &
            id=id_small_font)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_pointer_font, &
            id=id_italic_font)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_pointer_font, &
            id=id_swiss_font)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_font_default, &
            id=id_font_default)

        call wx_connect(g_frame, int(wxEVT_MENU()), on_system_font, &
            id=id_sys_oem_fixed)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_system_font, &
            id=id_sys_ansi_fixed)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_system_font, &
            id=id_sys_ansi_var)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_system_font, &
            id=id_sys_system)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_system_font, &
            id=id_sys_device_default)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_system_font, &
            id=id_sys_default_gui)

        call wx_connect(g_frame, int(wxEVT_MENU()), on_set_native_desc, &
            id=id_set_native_desc)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_set_native_user_desc, &
            id=id_set_native_user_desc)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_set_family, id=id_set_family)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_set_face_name, &
            id=id_set_face_name)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_set_encoding, &
            id=id_set_encoding)

        call wx_connect(g_frame, int(wxEVT_MENU()), on_select_font, id=id_choose)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_enum_families_for_encoding, &
            id=id_enum_families_for_encoding)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_enum_families, &
            id=id_enum_families)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_enum_fixed_families, &
            id=id_enum_fixed_families)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_enum_encodings, &
            id=id_enum_encodings)
        call wx_connect(g_frame, int(wxEVT_MENU()), on_private_font, id=id_private)

        ! FontWindow::Bind(wxEVT_BUTTON, OnFontPanelApply)
        call wx_bind(g_font_window, int(wxEVT_BUTTON()), on_font_panel_apply)

        ! FontPanel control events.
        call wx_connect(g_face_name, int(wxEVT_TEXT()), on_facename)
        call wx_connect(g_choice_family, int(wxEVT_CHOICE()), on_family)
        call wx_connect(g_choice_weight, int(wxEVT_CHOICE()), on_weight_choice)
        call wx_connect(g_spin_weight, int(wxEVT_SPINCTRL()), on_weight_spin)

        ! FontCanvas paint event.
        call wx_connect(g_canvas, int(wxEVT_PAINT()), on_paint)
    end subroutine connect_events

end program font
