! wizard.f90 - wxWizard sample in Fortran
!
! Fortran port of wxWidgets sample src/wizard/wizard.cpp (kwxFortran).
!
! The frame has File/Options/Help menus, a one-pane status bar and runs a
! four-page modal or modeless wizard:
!
!   1. an introductory wxWizardPageSimple,
!   2. a custom page whose GetNext() skips page 3 when its checkbox is set,
!   3. a page with a radio box that vetoes forbidden navigation directions and
!      asks before cancelling,
!   4. a page that refuses to leave until its checkbox is checked.
!
! The wizard artwork is loaded from wiztest.svg / wiztest2.svg; the wizard icon
! is samples/sample.xpm reproduced pixel-for-pixel in sample.svg (32x32).
!
! Run the executable with the current directory set to this folder so the
! relative SVG paths resolve:
!     cd samples\wizard && ..\..\bin\Debug\wizard.exe

module wizard_globals
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_HIGHEST
    implicit none
    private

    public :: g_frame, g_menu_bar
    public :: g_id_run_modal, g_id_run_no_sizer, g_id_run_modeless
    public :: g_id_large_wizard, g_id_expand_bitmap
    public :: init_menu_ids
    public :: page2_context, page3_context, page4_context, wizard_ui

    ! Main frame (the C++ MyFrame instance).
    type(wxFrame_t), save :: g_frame

    ! Menu bar used for the Options check marks while a wizard is built.
    type(wxMenuBar_t), save :: g_menu_bar

    ! Wizard_* ids from the C++ enum.
    integer, save :: g_id_run_modal = 0
    integer, save :: g_id_run_no_sizer = 0
    integer, save :: g_id_run_modeless = 0
    integer, save :: g_id_large_wizard = 0
    integer, save :: g_id_expand_bitmap = 0

    ! State shared with the custom wxCheckboxPage callbacks.  pObject is the
    ! address of one of these records, so several modeless wizards can coexist.
    type, bind(C) :: page2_context
        type(c_ptr) :: prev_page
        type(c_ptr) :: next_page
        type(c_ptr) :: next_if_skipped
        type(c_ptr) :: checkbox
    end type page2_context

    type, bind(C) :: page3_context
        type(c_ptr) :: radio
        type(c_ptr) :: self_page
    end type page3_context

    type, bind(C) :: page4_context
        type(c_ptr) :: prev_page
        type(c_ptr) :: checkbox
        type(c_ptr) :: dialog_parent
    end type page4_context

    ! Handles for one MyWizard instance and its pages.
    type :: wizard_ui
        type(wxwizard_t) :: wizard
        type(wxwizardpagesimple_t) :: page1
        type(kwxwizardpage_t) :: page2
        type(wxwizardpagesimple_t) :: page3
        type(kwxwizardpage_t) :: page4
        type(wxcheckbox_t) :: page2_checkbox
        type(wxcheckbox_t) :: page4_checkbox
        type(wxchecklistbox_t) :: checklist
        type(wxradiobox_t) :: radio
        type(wxtextctrl_t) :: text_ctrl
        type(page2_context), pointer :: p2ctx => null()
        type(page3_context), pointer :: p3ctx => null()
        type(page4_context), pointer :: p4ctx => null()
    end type wizard_ui

contains

    !----------------------------------------------------------------------
    ! Wizard_RunModal = wxID_HIGHEST, then +1, +2, +3, +4.
    !----------------------------------------------------------------------
    subroutine init_menu_ids()
        g_id_run_modal = int(wxID_HIGHEST())
        g_id_run_no_sizer = g_id_run_modal + 1
        g_id_run_modeless = g_id_run_modal + 2
        g_id_large_wizard = g_id_run_modal + 3
        g_id_expand_bitmap = g_id_run_modal + 4
    end subroutine init_menu_ids

end module wizard_globals


module wizard_util
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: kwxMessageBox, wxBitmapBundle_Delete
    use wx_string, only: to_wxstring, wxString_Delete
    use wx_bitmap_bundle, only: wx_bitmap_bundle_from_svg_file, &
        wx_bitmap_bundle_get_bitmap
    use wx_bitmap, only: wx_bitmap_delete
    use wx_icon, only: wx_icon_create_default, wx_icon_copy_from_bitmap, &
        wx_icon_is_ok, wx_icon_delete
    use wx_top_level_window, only: wx_top_level_window_set_icon
    implicit none
    private

    public :: show_message, set_wizard_icon

contains

    !----------------------------------------------------------------------
    ! wxMessageBox(message, caption, style, parent)
    !----------------------------------------------------------------------
    subroutine show_message(message, caption, style, parent, answer)
        character(len=*), intent(in) :: message
        character(len=*), intent(in) :: caption
        integer(c_int), intent(in) :: style
        type(c_ptr), intent(in), optional :: parent
        integer(c_int), intent(out), optional :: answer

        type(c_ptr) :: message_ptr, caption_ptr, parent_ptr
        integer(c_int) :: result

        message_ptr = to_wxstring(message)
        caption_ptr = to_wxstring(caption)
        parent_ptr = c_null_ptr
        if (present(parent)) parent_ptr = parent

        result = kwxMessageBox(message_ptr, caption_ptr, style, parent_ptr, &
            -1_c_int, -1_c_int)

        if (present(answer)) answer = result
        call wxString_Delete(caption_ptr)
        call wxString_Delete(message_ptr)
    end subroutine show_message

    !----------------------------------------------------------------------
    ! SetIcon(wxICON(sample))
    !----------------------------------------------------------------------
    subroutine set_wizard_icon(wizard)
        type(wxwizard_t), intent(in) :: wizard
        type(wxBitmapBundle_t) :: bundle
        type(wxBitmap_t) :: bitmap
        type(wxIcon_t) :: icon

        bundle = wx_bitmap_bundle_from_svg_file("sample.svg", 32_c_int, 32_c_int)
        if (.not. bundle%is_valid()) return

        bitmap = wx_bitmap_bundle_get_bitmap(bundle, 32_c_int, 32_c_int)
        if (bitmap%is_valid()) then
            icon = wx_icon_create_default()
            if (icon%is_valid()) then
                call wx_icon_copy_from_bitmap(icon, bitmap)
                if (wx_icon_is_ok(icon)) &
                    call wx_top_level_window_set_icon(wizard, icon)
                call wx_icon_delete(icon)
            end if
            call wx_bitmap_delete(bitmap)
        end if

        ! wxBitmapBundle_FromSVGFile() returns a new bundle that the wrapper
        ! marks non-owned; release it explicitly.
        call wxBitmapBundle_Delete(bundle%ptr)
        bundle%ptr = c_null_ptr
    end subroutine set_wizard_icon

end module wizard_util


module wizard_builder
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_wizard, only: wx_wizard_create_default, wx_wizard_create2, &
        wx_wizard_set_bitmap_placement, wx_wizard_get_page_area_sizer
    use wx_wizard_page_simple, only: wx_wizard_page_simple_create_with_bundle
    use kwx_wizard_page, only: kwx_wizard_page_create, kwx_wizard_page_create2, &
        kwx_wizard_page_set_on_get_next_out, kwx_wizard_page_set_on_get_prev_out, &
        kwx_wizard_page_set_on_transfer_data_from_window_out
    use wx_static_text, only: wx_static_text_create
    use wx_check_box, only: wx_check_box_create
    use wx_check_list_box, only: wx_check_list_box_create
    use wx_radio_box, only: wx_radio_box_create, wx_radio_box_set_selection
    use wx_text_ctrl, only: wx_text_ctrl_create
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add_window
    use wx_window, only: wx_window_set_extra_style, wx_window_set_sizer_and_fit
    use wx_bitmap_bundle, only: wx_bitmap_bundle_from_svg_file
    use wx_rect, only: wx_rect_get_height, wx_rect_delete
    use wx_dialog, only: wx_dialog_set_layout_adaptation_mode
    use wx_menu_bar, only: wx_menu_bar_is_checked
    use wizard_globals
    use wizard_util
    implicit none
    private

    public :: build_wizard

contains

    !----------------------------------------------------------------------
    ! MyWizard::MyWizard(wxFrame *frame, bool useSizer)
    !----------------------------------------------------------------------
    logical function build_wizard(ui, use_sizer)
        type(wizard_ui), intent(inout) :: ui
        logical, intent(in) :: use_sizer

        type(wxwizardpage_t) :: no_page
        type(wxbitmapbundle_t) :: main_bundle, empty_bundle, validation_bundle
        type(wxstatictext_t) :: text_control
        type(wxboxsizer_t) :: page_sizer
        type(wxsizer_t) :: page_area_sizer
        type(wxrect_t) :: client_rect
        type(c_ptr) :: rect_ptr
        integer(c_int) :: client_height, text_height
        character(len=8), dimension(4) :: radio_choices
        character(len=7), dimension(10) :: list_items

        build_wizard = .false.

        allocate(ui%p2ctx)
        allocate(ui%p3ctx)
        allocate(ui%p4ctx)

        ! Initialise every context field (a callback may read any of them).
        ui%p2ctx%prev_page = c_null_ptr
        ui%p2ctx%next_page = c_null_ptr
        ui%p2ctx%next_if_skipped = c_null_ptr
        ui%p2ctx%checkbox = c_null_ptr
        ui%p3ctx%radio = c_null_ptr
        ui%p3ctx%self_page = c_null_ptr
        ui%p4ctx%prev_page = c_null_ptr
        ui%p4ctx%checkbox = c_null_ptr
        ui%p4ctx%dialog_parent = c_null_ptr

        radio_choices = [ character(len=8) :: "forward", "backward", "both", "neither" ]
        list_items = [ character(len=7) :: "Zeroth", "First", "Second", "Third", &
            "Fourth", "Fifth", "Sixth", "Seventh", "Eighth", "Nineth" ]

        main_bundle = wx_bitmap_bundle_from_svg_file("wiztest.svg", &
            116_c_int, 260_c_int)
        if (.not. main_bundle%is_valid()) return

        ! SetExtraStyle(wxWIZARD_EX_HELPBUTTON) then Create(...).
        ui%wizard = wx_wizard_create_default()
        if (.not. ui%wizard%is_valid()) then
            call wxBitmapBundle_Delete(main_bundle%ptr)
            return
        end if

        call wx_window_set_extra_style(ui%wizard, &
            int(wxWIZARD_EX_HELPBUTTON(), c_long))

        if (.not. wx_wizard_create2(ui%wizard, g_frame, wxID_ANY(), &
            "Absolutely Useless Wizard", main_bundle, -1_c_int, -1_c_int, &
            int(ior(wxDEFAULT_DIALOG_STYLE(), wxRESIZE_BORDER()), c_long))) then
            call wxBitmapBundle_Delete(main_bundle%ptr)
            return
        end if
        call wxBitmapBundle_Delete(main_bundle%ptr)

        call set_wizard_icon(ui%wizard)

        ! Allow the bitmap to be expanded to fit the page height.
        if (wx_menu_bar_is_checked(g_menu_bar, int(g_id_expand_bitmap, c_int))) &
            call wx_wizard_set_bitmap_placement(ui%wizard, wxWIZARD_VALIGN_CENTRE())

        ! Enable scrolling adaptation.
        if (wx_menu_bar_is_checked(g_menu_bar, int(g_id_large_wizard, c_int))) &
            call wx_dialog_set_layout_adaptation_mode(ui%wizard, &
                wxDIALOG_ADAPTATION_MODE_ENABLED())

        ! A custom wxWizardPage (the C++ wxCheckboxPage).
        ui%page2%ptr = kwx_wizard_page_create(c_loc(ui%p2ctx))
        ui%page2%owned = .true.
        if (.not. kwx_wizard_page_create2(ui%page2, ui%wizard, empty_bundle)) return
        call kwx_wizard_page_set_on_get_next_out(ui%page2, &
            transfer(c_funloc(page2_get_next_out), c_null_ptr))
        call kwx_wizard_page_set_on_get_prev_out(ui%page2, &
            transfer(c_funloc(page2_get_prev_out), c_null_ptr))

        ! m_page1 = new wxWizardPageSimple(this);
        no_page%ptr = c_null_ptr
        ui%page1 = wx_wizard_page_simple_create_with_bundle(ui%wizard, &
            no_page, ui%page2, empty_bundle)

        ! wxValidationPage is a wxWizardPageSimple with a custom bitmap and an
        ! overridden TransferDataFromWindow(); implement both with kwxWizardPage.
        validation_bundle = wx_bitmap_bundle_from_svg_file("wiztest2.svg", &
            116_c_int, 260_c_int)
        if (.not. validation_bundle%is_valid()) return
        ui%page4%ptr = kwx_wizard_page_create(c_loc(ui%p4ctx))
        ui%page4%owned = .true.
        if (.not. kwx_wizard_page_create2(ui%page4, ui%wizard, validation_bundle)) then
            call wxBitmapBundle_Delete(validation_bundle%ptr)
            return
        end if
        call wxBitmapBundle_Delete(validation_bundle%ptr)
        call kwx_wizard_page_set_on_get_next_out(ui%page4, &
            transfer(c_funloc(page4_no_next_out), c_null_ptr))
        call kwx_wizard_page_set_on_get_prev_out(ui%page4, &
            transfer(c_funloc(page4_get_prev_out), c_null_ptr))
        call kwx_wizard_page_set_on_transfer_data_from_window_out(ui%page4, &
            transfer(c_funloc(page4_transfer_out), c_null_ptr))

        ! page3->Chain(page4), page3->SetPrev(page2) and page1->SetNext(page2).
        ui%page3 = wx_wizard_page_simple_create_with_bundle(ui%wizard, &
            ui%page2, ui%page4, empty_bundle)

        ui%p2ctx%prev_page = ui%page1%ptr
        ui%p2ctx%next_page = ui%page3%ptr
        ui%p2ctx%next_if_skipped = ui%page4%ptr
        ui%p4ctx%prev_page = ui%page3%ptr
        ui%p4ctx%dialog_parent = ui%page4%ptr
        ui%p3ctx%self_page = ui%page3%ptr

        ! page1 content: absolute position, no sizer.
        text_control = wx_static_text_create(ui%page1, wxID_ANY(), &
            "This wizard doesn't help you" // achar(10) // &
            "to do anything at all." // achar(10) // &
            achar(10) // &
            "The next pages will present you" // achar(10) // &
            "with more useless controls.", &
            5_c_int, 5_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (.not. text_control%is_valid()) return

        ! page2 content: the C++ wxCheckboxPage.
        page_sizer = wx_box_sizer_create(wxVERTICAL())
        text_control = wx_static_text_create(ui%page2, wxID_ANY(), &
            "Try checking the box below and" // achar(10) // &
            "then going back and clearing it", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (.not. text_control%is_valid()) return
        call wx_sizer_add_window(page_sizer, text_control, 0_c_int, wxALL(), &
            5_c_int, c_null_ptr)

        ui%page2_checkbox = wx_check_box_create(ui%page2, wxID_ANY(), &
            "&Skip the next page", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (.not. ui%page2_checkbox%is_valid()) return
        ui%p2ctx%checkbox = ui%page2_checkbox%ptr
        call wx_sizer_add_window(page_sizer, ui%page2_checkbox, 0_c_int, &
            wxALL(), 5_c_int, c_null_ptr)

        ui%checklist = wx_check_list_box_create(ui%page2, wxID_ANY(), &
            -1_c_int, -1_c_int, 100_c_int, 100_c_int, list_items, 0_c_int)
        if (.not. ui%checklist%is_valid()) return
        call wx_sizer_add_window(page_sizer, ui%checklist, 0_c_int, wxALL(), &
            5_c_int, c_null_ptr)

        ! wxSize textSize = wxSize(150, 200); enlarge when scrolling is on.
        text_height = 200_c_int
        if (wx_menu_bar_is_checked(g_menu_bar, int(g_id_large_wizard, c_int))) then
            rect_ptr = wxGetClientDisplayRect()
            if (c_associated(rect_ptr)) then
                client_rect = wxrect_from_ptr(rect_ptr, .true.)
                client_height = wx_rect_get_height(client_rect)
                text_height = client_height - 200_c_int
                call wx_rect_delete(rect_ptr)
            end if
        end if

        ui%text_ctrl = wx_text_ctrl_create(ui%page2, wxID_ANY(), "", &
            -1_c_int, -1_c_int, 150_c_int, text_height, &
            int(wxTE_MULTILINE(), c_long))
        if (.not. ui%text_ctrl%is_valid()) return
        call wx_sizer_add_window(page_sizer, ui%text_ctrl, 0_c_int, &
            ior(wxEXPAND(), wxALL()), 5_c_int, c_null_ptr)

        call wx_window_set_sizer_and_fit(ui%page2, page_sizer, .true.)

        ! page3 content: the C++ wxRadioboxPage.
        ui%radio = wx_radio_box_create(ui%page3, wxID_ANY(), &
            "Allow to proceed:", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            radio_choices, 1_c_int, wxRA_SPECIFY_COLS())
        if (.not. ui%radio%is_valid()) return
        call wx_radio_box_set_selection(ui%radio, 2_c_int) ! Both
        ui%p3ctx%radio = ui%radio%ptr

        page_sizer = wx_box_sizer_create(wxVERTICAL())
        call wx_sizer_add_window(page_sizer, ui%radio, 0_c_int, wxALL(), &
            5_c_int, c_null_ptr)
        call wx_window_set_sizer_and_fit(ui%page3, page_sizer, .true.)

        ! page4 content: the C++ wxValidationPage.
        page_sizer = wx_box_sizer_create(wxVERTICAL())
        text_control = wx_static_text_create(ui%page4, wxID_ANY(), &
            "You need to check the checkbox" // achar(10) // &
            "below before going to the next page" // achar(10), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (.not. text_control%is_valid()) return
        call wx_sizer_add_window(page_sizer, text_control, 0_c_int, wxALL(), &
            5_c_int, c_null_ptr)

        ui%page4_checkbox = wx_check_box_create(ui%page4, wxID_ANY(), &
            "&Check me", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        if (.not. ui%page4_checkbox%is_valid()) return
        ui%p4ctx%checkbox = ui%page4_checkbox%ptr
        call wx_sizer_add_window(page_sizer, ui%page4_checkbox, 0_c_int, &
            wxALL(), 5_c_int, c_null_ptr)
        call wx_window_set_sizer_and_fit(ui%page4, page_sizer, .true.)

        ! if ( useSizer ) GetPageAreaSizer()->Add(m_page1);
        if (use_sizer) then
            page_area_sizer = wx_wizard_get_page_area_sizer(ui%wizard)
            call wx_sizer_add_window(page_area_sizer, ui%page1, 0_c_int, &
                0_c_int, 0_c_int, c_null_ptr)
        end if

        build_wizard = .true.
    end function build_wizard

    !----------------------------------------------------------------------
    ! wxCheckboxPage::GetNext() -> m_checkbox->GetValue() ? m_next->GetNext()
    !                                                      : m_next
    !----------------------------------------------------------------------
    subroutine page2_get_next_out(object, page) bind(C)
        type(c_ptr), value :: object
        type(c_ptr), intent(out) :: page
        type(page2_context), pointer :: ctx

        page = c_null_ptr
        if (.not. c_associated(object)) return
        call c_f_pointer(object, ctx)

        if (c_associated(ctx%checkbox)) then
            if (wxCheckBox_GetValue(ctx%checkbox) /= 0) then
                page = ctx%next_if_skipped
                return
            end if
        end if
        page = ctx%next_page
    end subroutine page2_get_next_out

    subroutine page2_get_prev_out(object, page) bind(C)
        type(c_ptr), value :: object
        type(c_ptr), intent(out) :: page
        type(page2_context), pointer :: ctx

        page = c_null_ptr
        if (.not. c_associated(object)) return
        call c_f_pointer(object, ctx)
        page = ctx%prev_page
    end subroutine page2_get_prev_out

    subroutine page4_no_next_out(object, page) bind(C)
        type(c_ptr), value :: object
        type(c_ptr), intent(out) :: page

        page = c_null_ptr
    end subroutine page4_no_next_out

    subroutine page4_get_prev_out(object, page) bind(C)
        type(c_ptr), value :: object
        type(c_ptr), intent(out) :: page
        type(page4_context), pointer :: ctx

        page = c_null_ptr
        if (.not. c_associated(object)) return
        call c_f_pointer(object, ctx)
        page = ctx%prev_page
    end subroutine page4_get_prev_out

    !----------------------------------------------------------------------
    ! wxValidationPage::TransferDataFromWindow()
    !----------------------------------------------------------------------
    subroutine page4_transfer_out(object, result) bind(C)
        type(c_ptr), value :: object
        integer(c_int), intent(out) :: result
        type(page4_context), pointer :: ctx

        result = 1_c_int
        if (.not. c_associated(object)) return
        call c_f_pointer(object, ctx)

        if (c_associated(ctx%checkbox)) then
            if (wxCheckBox_GetValue(ctx%checkbox) == 0) then
                call show_message("Check the checkbox first!", "No way", &
                    ior(wxICON_WARNING(), wxOK()), ctx%dialog_parent)
                result = 0_c_int
            end if
        end if
    end subroutine page4_transfer_out

end module wizard_builder


module wizard_handlers
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_events
    use wx_notify_event, only: wx_notify_event_veto
    use wx_wizard_event, only: wx_wizard_event_get_direction
    use wx_window, only: wx_window_close, wx_window_show, wx_window_destroy
    use wx_wizard, only: wx_wizard_run_wizard, wx_wizard_show_page
    use wizard_globals
    use wizard_util
    use wizard_builder, only: build_wizard
    implicit none
    private

    public :: on_quit, on_about
    public :: on_run_modal, on_run_no_sizer, on_run_modeless
    public :: on_wizard_cancel, on_wizard_finished
    public :: on_radio_page_changing, on_radio_page_cancel
    public :: run_modal_wizard, run_modeless_wizard

    integer, parameter :: RADIO_FORWARD = 0
    integer, parameter :: RADIO_BACKWARD = 1
    integer, parameter :: RADIO_BOTH = 2

contains

    !----------------------------------------------------------------------
    ! MyFrame::OnQuit -- Close(true)
    !----------------------------------------------------------------------
    subroutine on_quit(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: closed

        if (.not. c_associated(evt)) return
        closed = wx_window_close(g_frame, .true.)
    end subroutine on_quit

    !----------------------------------------------------------------------
    ! MyFrame::OnAbout
    !----------------------------------------------------------------------
    subroutine on_about(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call show_message("Demo of wxWizard class" // achar(10) // &
            "(c) 1999, 2000 Vadim Zeitlin", "About wxWizard sample", &
            ior(wxOK(), wxICON_INFORMATION()), g_frame%ptr)
    end subroutine on_about

    !----------------------------------------------------------------------
    ! MyFrame::OnRunWizard
    !----------------------------------------------------------------------
    subroutine on_run_modal(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call run_modal_wizard(.true.)
    end subroutine on_run_modal

    !----------------------------------------------------------------------
    ! MyFrame::OnRunWizardNoSizer
    !----------------------------------------------------------------------
    subroutine on_run_no_sizer(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call run_modal_wizard(.false.)
    end subroutine on_run_no_sizer

    !----------------------------------------------------------------------
    ! MyFrame::OnRunWizardModeless
    !----------------------------------------------------------------------
    subroutine on_run_modeless(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call run_modeless_wizard()
    end subroutine on_run_modeless

    !----------------------------------------------------------------------
    ! MyFrame::OnWizardCancel
    !----------------------------------------------------------------------
    subroutine on_wizard_cancel(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call show_message("The wizard was cancelled.", "Wizard notification", &
            wxOK())
    end subroutine on_wizard_cancel

    !----------------------------------------------------------------------
    ! MyFrame::OnWizardFinished
    !----------------------------------------------------------------------
    subroutine on_wizard_finished(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call show_message("The wizard finished successfully.", &
            "Wizard notification", wxOK())
    end subroutine on_wizard_finished

    !----------------------------------------------------------------------
    ! wxRadioboxPage::OnWizardPageChanging
    !----------------------------------------------------------------------
    subroutine on_radio_page_changing(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(page3_context), pointer :: ctx
        type(wxwizardevent_t) :: wizard_event
        integer(c_int) :: selection, direction

        if (.not. c_associated(evt)) return
        if (.not. c_associated(data)) return
        call c_f_pointer(data, ctx)

        selection = wxRadioBox_GetSelection(ctx%radio)
        if (selection == RADIO_BOTH) return

        wizard_event = wxwizardevent_from_ptr(evt, .false.)
        direction = wx_wizard_event_get_direction(wizard_event)

        if (direction /= 0 .and. selection == RADIO_FORWARD) return
        if (direction == 0 .and. selection == RADIO_BACKWARD) return

        call show_message("You can't go there", "Not allowed", &
            ior(wxICON_WARNING(), wxOK()), ctx%self_page)
        call wx_notify_event_veto(wxnotifyevent_from_ptr(evt, .false.))
    end subroutine on_radio_page_changing

    !----------------------------------------------------------------------
    ! wxRadioboxPage::OnWizardCancel
    !----------------------------------------------------------------------
    subroutine on_radio_page_cancel(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(page3_context), pointer :: ctx
        integer(c_int) :: answer

        if (.not. c_associated(evt)) return
        if (.not. c_associated(data)) return
        call c_f_pointer(data, ctx)

        call show_message("Do you really want to cancel?", "Question", &
            ior(wxICON_QUESTION(), wxYES_NO()), ctx%self_page, answer)
        if (answer /= wxYES()) &
            call wx_notify_event_veto(wxnotifyevent_from_ptr(evt, .false.))
    end subroutine on_radio_page_cancel

    !----------------------------------------------------------------------
    ! MyWizard wizard(this); wizard.RunWizard(wizard.GetFirstPage());
    !----------------------------------------------------------------------
    subroutine run_modal_wizard(use_sizer)
        logical, intent(in) :: use_sizer
        type(wizard_ui), pointer :: ui
        integer(c_int) :: result

        allocate(ui)
        if (.not. build_wizard(ui, use_sizer)) then
            call release_ui(ui)
            return
        end if

        ! wxRadioboxPage's event table: page changing and cancel.
        call wx_connect(ui%page3, wxEVT_WIZARD_PAGE_CHANGING(), &
            on_radio_page_changing, user_data=c_loc(ui%p3ctx))
        call wx_connect(ui%page3, wxEVT_WIZARD_CANCEL(), &
            on_radio_page_cancel, user_data=c_loc(ui%p3ctx))

        result = wx_wizard_run_wizard(ui%wizard, ui%page1)

        ! MyWizard is a stack object in the C++ sample, so it is destroyed when
        ! OnRunWizard() returns.
        call release_ui(ui)
    end subroutine run_modal_wizard

    !----------------------------------------------------------------------
    ! MyWizard *wizard = new MyWizard(this);
    ! wizard->ShowPage(wizard->GetFirstPage());
    ! wizard->Show(true);
    !----------------------------------------------------------------------
    subroutine run_modeless_wizard()
        type(wizard_ui), pointer :: ui
        logical :: shown

        allocate(ui)
        if (.not. build_wizard(ui, .true.)) then
            call release_ui(ui)
            return
        end if

        call wx_connect(ui%page3, wxEVT_WIZARD_PAGE_CHANGING(), &
            on_radio_page_changing, user_data=c_loc(ui%p3ctx))
        call wx_connect(ui%page3, wxEVT_WIZARD_CANCEL(), &
            on_radio_page_cancel, user_data=c_loc(ui%p3ctx))

        shown = wx_wizard_show_page(ui%wizard, ui%page1%ptr, .true.)
        shown = wx_window_show(ui%wizard)

        ! The C++ sample deliberately leaks the heap-allocated wizard; the same
        ! applies to its Fortran state so the closures above stay valid.
    end subroutine run_modeless_wizard

    !----------------------------------------------------------------------
    ! Destroy a wizard that finished or failed to build and free its state.
    !----------------------------------------------------------------------
    subroutine release_ui(ui)
        type(wizard_ui), pointer :: ui
        logical :: destroyed

        if (.not. associated(ui)) return
        if (ui%wizard%is_valid()) destroyed = wx_window_destroy(ui%wizard)
        if (associated(ui%p2ctx)) deallocate(ui%p2ctx)
        if (associated(ui%p3ctx)) deallocate(ui%p3ctx)
        if (associated(ui%p4ctx)) deallocate(ui%p4ctx)
        deallocate(ui)
    end subroutine release_ui

end module wizard_handlers


program wizard
    use, intrinsic :: iso_c_binding
    use wx_app
    use wx_frame
    use wx_menu, only: wx_menu_create, wx_menu_append, &
        wx_menu_append_separator, wx_menu_append_check_item
    use wx_menu_bar, only: wx_menu_bar_create, wx_menu_bar_append
    use wx_window, only: wx_window_show
    use wx_events, only: wx_connect
    use kwx_types
    use kwxffi, only: wxID_ANY, wxID_ABOUT, wxID_EXIT, wxEVT_MENU, &
        wxEVT_WIZARD_CANCEL, wxEVT_WIZARD_FINISHED, wxDEFAULT_FRAME_STYLE, &
        wxSTB_DEFAULT_STYLE
    use wizard_globals
    use wizard_handlers
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxMenu_t) :: file_menu, options_menu, help_menu
    type(wxMenuBar_t) :: menu_bar
    type(wxStatusBar_t) :: status_bar
    integer :: exit_code, dummy
    logical :: shown

    ! wxIMPLEMENT_APP / MyApp::OnInit()
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    call wx_set_app_name("wxWizard Sample")

    ! MyFrame *frame = new MyFrame("wxWizard Sample");
    no_parent%ptr = c_null_ptr
    g_frame = wx_frame_create(no_parent, wxID_ANY(), "wxWizard Sample", &
        -1_c_int, -1_c_int, 250_c_int, 150_c_int, wxDEFAULT_FRAME_STYLE())
    if (.not. g_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    call init_menu_ids()

    file_menu = wx_menu_create("", 0_c_long)
    options_menu = wx_menu_create("", 0_c_long)
    help_menu = wx_menu_create("", 0_c_long)

    ! menuFile->Append(Wizard_RunModal, "&Run wizard modal...\tCtrl-R");
    call wx_menu_append(file_menu, int(g_id_run_modal, c_int), &
        "&Run wizard modal..." // achar(9) // "Ctrl-R", "", .false.)
    call wx_menu_append(file_menu, int(g_id_run_no_sizer, c_int), &
        "Run wizard &without sizer...", "", .false.)
    call wx_menu_append(file_menu, int(g_id_run_modeless, c_int), &
        "Run wizard &modeless...", "", .false.)
    call wx_menu_append_separator(file_menu)
    call wx_menu_append(file_menu, wxID_EXIT(), &
        "E&xit" // achar(9) // "Alt-X", "Quit this program", .false.)

    ! menuOptions->AppendCheckItem(...);
    call wx_menu_append_check_item(options_menu, &
        int(g_id_large_wizard, c_int), "&Scroll Wizard Pages", "")
    call wx_menu_append_check_item(options_menu, &
        int(g_id_expand_bitmap, c_int), "Si&ze Bitmap To Page", "")

    ! helpMenu->Append(Wizard_About, "&About\tF1", "Show about dialog");
    call wx_menu_append(help_menu, wxID_ABOUT(), &
        "&About" // achar(9) // "F1", "Show about dialog", .false.)

    menu_bar = wx_menu_bar_create(0_c_int)
    dummy = wx_menu_bar_append(menu_bar, file_menu, "&File")
    dummy = wx_menu_bar_append(menu_bar, options_menu, "&Options")
    dummy = wx_menu_bar_append(menu_bar, help_menu, "&Help")
    call wx_frame_set_menu_bar(g_frame, menu_bar)
    g_menu_bar = menu_bar

    ! CreateStatusBar();
    status_bar = wx_frame_create_status_bar(g_frame, 1_c_int, &
        wxSTB_DEFAULT_STYLE(), 0_c_int)

    ! Event table: EVT_MENU(...) and EVT_WIZARD_CANCEL/FINISHED(wxID_ANY).
    call wx_connect(g_frame, wxEVT_MENU(), on_quit, id=wxID_EXIT())
    call wx_connect(g_frame, wxEVT_MENU(), on_about, id=wxID_ABOUT())
    call wx_connect(g_frame, wxEVT_MENU(), on_run_modal, id=g_id_run_modal)
    call wx_connect(g_frame, wxEVT_MENU(), on_run_no_sizer, &
        id=g_id_run_no_sizer)
    call wx_connect(g_frame, wxEVT_MENU(), on_run_modeless, &
        id=g_id_run_modeless)
    call wx_connect(g_frame, wxEVT_WIZARD_CANCEL(), on_wizard_cancel)
    call wx_connect(g_frame, wxEVT_WIZARD_FINISHED(), on_wizard_finished)

    ! frame->Show(true);
    call wx_set_top_window(g_frame)
    shown = wx_window_show(g_frame)

    ! wxApp::OnRun()
    exit_code = wx_main_loop()

    call wx_shutdown()

end program wizard
