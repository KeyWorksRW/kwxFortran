! controls_demo.f90 - Demonstration of extended wxWidgets controls in Fortran
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This example demonstrates:
!   - wxCheckBox, wxRadioButton
!   - wxChoice, wxListBox, wxComboBox
!   - wxMenu, wxMenuBar, wxMenuItem
!   - Event handling for all control types
!
! Build via CMake with the kwxFortran project.

module controls_demo_handlers
    use, intrinsic :: iso_c_binding
    use wx_events
    use wx_app, only: wx_exit_main_loop
    implicit none

contains

    !---------------------------------------------------------------------------
    ! Checkbox toggle handler
    !---------------------------------------------------------------------------
    subroutine on_checkbox_toggle(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: checked

        checked = wx_command_event_is_checked(evt)
        if (checked) then
            print *, "Checkbox checked"
        else
            print *, "Checkbox unchecked"
        end if
    end subroutine on_checkbox_toggle

    !---------------------------------------------------------------------------
    ! Radio button selection handler
    !---------------------------------------------------------------------------
    subroutine on_radio_selected(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id

        id = wx_event_get_id(evt)
        print '(A,I0)', 'Radio button selected, ID: ', id
    end subroutine on_radio_selected

    !---------------------------------------------------------------------------
    ! Choice selection handler
    !---------------------------------------------------------------------------
    subroutine on_choice_selected(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        character(len=:), allocatable :: str
        integer :: sel

        sel = wx_command_event_get_selection(evt)
        str = wx_command_event_get_string(evt)
        print '(A,I0,A,A)', 'Choice selected index: ', sel, ', text: ', str
    end subroutine on_choice_selected

    !---------------------------------------------------------------------------
    ! ListBox selection handler
    !---------------------------------------------------------------------------
    subroutine on_listbox_selected(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        character(len=:), allocatable :: str
        integer :: sel

        sel = wx_command_event_get_selection(evt)
        str = wx_command_event_get_string(evt)
        print '(A,I0,A,A)', 'ListBox selected index: ', sel, ', text: ', str
    end subroutine on_listbox_selected

    !---------------------------------------------------------------------------
    ! ComboBox selection handler
    !---------------------------------------------------------------------------
    subroutine on_combobox_selected(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        character(len=:), allocatable :: str
        integer :: sel

        sel = wx_command_event_get_selection(evt)
        str = wx_command_event_get_string(evt)
        print '(A,I0,A,A)', 'ComboBox selected index: ', sel, ', text: ', str
    end subroutine on_combobox_selected

    !---------------------------------------------------------------------------
    ! Menu item handler
    !---------------------------------------------------------------------------
    subroutine on_menu_item(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id

        id = wx_event_get_id(evt)
        print '(A,I0)', 'Menu item selected, ID: ', id
    end subroutine on_menu_item

    !---------------------------------------------------------------------------
    ! About menu handler
    !---------------------------------------------------------------------------
    subroutine on_about(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        print *, "kwxFortran Controls Demo - Phase 5"
    end subroutine on_about

    !---------------------------------------------------------------------------
    ! Exit menu handler
    !---------------------------------------------------------------------------
    subroutine on_exit(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        call wx_exit_main_loop()
    end subroutine on_exit

end module controls_demo_handlers

program controls_demo
    use, intrinsic :: iso_c_binding
    use wx_app
    use wx_frame
    use wx_panel, only: wx_panel_create
    use wx_check_box, only: wx_check_box_create
    use wx_radio_button, only: wx_radio_button_create
    use wx_choice, only: wx_choice_create, wx_choice_append, &
        wx_choice_set_selection
    use wx_list_box, only: wx_list_box_create, wx_list_box_append
    use wx_combo_box, only: wx_combo_box_create, wx_combo_box_append
    use wx_static_text, only: wx_static_text_create
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add_window, wx_sizer_add_sizer
    use wx_menu, only: wx_menu_create, wx_menu_append, wx_menu_append_separator
    use wx_menu_bar, only: wx_menu_bar_create, wx_menu_bar_append
    use wx_window, only: wx_window_set_sizer, wx_window_center, wx_window_show
    use wx_events
    use kwx_types
    use kwxffi, only: wxID_NEW, wxID_OPEN, wxID_SAVE, wxID_EXIT, wxID_ABOUT, &
        wxID_UNDO, wxID_REDO, wxID_CUT, wxID_COPY, wxID_PASTE, wxID_ANY, &
        wxEVT_MENU, wxEVT_CHECKBOX, wxEVT_RADIOBUTTON, wxEVT_CHOICE, &
        wxEVT_LISTBOX, wxEVT_COMBOBOX, &
        wxHORIZONTAL, wxVERTICAL, wxALL, wxLEFT, wxTOP, wxEXPAND, &
        wxRB_GROUP, wxLB_SINGLE, wxCB_DROPDOWN, wxDEFAULT_FRAME_STYLE, &
        wxSTB_DEFAULT_STYLE, wxBOTH
    use controls_demo_handlers
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxFrame_t) :: frame
    type(wxStatusBar_t) :: status_bar
    type(wxPanel_t) :: panel
    type(wxBoxSizer_t) :: main_sizer, left_sizer, right_sizer
    type(wxBoxSizer_t) :: h_sizer

    ! Controls
    type(wxCheckBox_t) :: checkbox
    type(wxRadioButton_t) :: radio1, radio2, radio3
    type(wxChoice_t) :: choice
    type(wxListBox_t) :: listbox
    type(wxComboBox_t) :: combobox
    type(wxStaticText_t) :: lbl_choice, lbl_listbox, lbl_combo

    ! Menus
    type(wxMenu_t) :: file_menu, edit_menu, help_menu
    type(wxMenuBar_t) :: menubar

    integer :: exit_code, dummy
    logical :: shown
    character(len=1) :: no_choices(0)
    integer, parameter :: ID_RADIO1 = 1001
    integer, parameter :: ID_RADIO2 = 1002
    integer, parameter :: ID_RADIO3 = 1003

    ! Initialize wxWidgets
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    call wx_set_app_name("Controls Demo")

    ! Create the main frame
    no_parent%ptr = c_null_ptr
    frame = wx_frame_create(no_parent, wxID_ANY(), "kwxFortran Controls Demo", &
        -1_c_int, -1_c_int, 600_c_int, 500_c_int, wxDEFAULT_FRAME_STYLE())
    if (.not. frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    !===================================================================
    ! Create menu bar
    !===================================================================

    ! File menu
    file_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(file_menu, wxID_NEW(), "&New", "Create new", .false.)
    call wx_menu_append(file_menu, wxID_OPEN(), "&Open", "Open file", .false.)
    call wx_menu_append(file_menu, wxID_SAVE(), "&Save", "Save file", .false.)
    call wx_menu_append_separator(file_menu)
    call wx_menu_append(file_menu, wxID_EXIT(), "E&xit", &
        "Exit application", .false.)

    ! Edit menu
    edit_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(edit_menu, wxID_UNDO(), "&Undo", "", .false.)
    call wx_menu_append(edit_menu, wxID_REDO(), "&Redo", "", .false.)
    call wx_menu_append_separator(edit_menu)
    call wx_menu_append(edit_menu, wxID_CUT(), "Cu&t", "", .false.)
    call wx_menu_append(edit_menu, wxID_COPY(), "&Copy", "", .false.)
    call wx_menu_append(edit_menu, wxID_PASTE(), "&Paste", "", .false.)

    ! Help menu
    help_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(help_menu, wxID_ABOUT(), "&About", &
        "About this demo", .false.)

    ! Create and populate menu bar
    menubar = wx_menu_bar_create(0_c_int)
    dummy = wx_menu_bar_append(menubar, file_menu, "&File")
    dummy = wx_menu_bar_append(menubar, edit_menu, "&Edit")
    dummy = wx_menu_bar_append(menubar, help_menu, "&Help")
    call wx_frame_set_menu_bar(frame, menubar)

    ! Connect menu events
    call wx_connect(frame, wxEVT_MENU(), on_exit, &
        id=wxID_EXIT())
    call wx_connect(frame, wxEVT_MENU(), on_about, &
        id=wxID_ABOUT())
    call wx_connect(frame, wxEVT_MENU(), on_menu_item, &
        id=wxID_NEW())
    call wx_connect(frame, wxEVT_MENU(), on_menu_item, &
        id=wxID_OPEN())
    call wx_connect(frame, wxEVT_MENU(), on_menu_item, &
        id=wxID_SAVE())

    !===================================================================
    ! Create controls
    !===================================================================

    panel = wx_panel_create(frame, wxID_ANY(), -1_c_int, -1_c_int, &
        -1_c_int, -1_c_int, 0_c_int)

    ! Horizontal sizer to split left and right columns
    h_sizer = wx_box_sizer_create(wxHORIZONTAL())

    ! Left column: checkbox and radio buttons
    left_sizer = wx_box_sizer_create(wxVERTICAL())

    checkbox = wx_check_box_create(panel, wxID_ANY(), "Enable feature", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call wx_sizer_add_window(left_sizer, checkbox, &
        0_c_int, wxALL(), 5_c_int, c_null_ptr)

    radio1 = wx_radio_button_create(panel, int(ID_RADIO1, c_int), "Option A", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, wxRB_GROUP())
    call wx_sizer_add_window(left_sizer, radio1, &
        0_c_int, wxALL(), 5_c_int, c_null_ptr)

    radio2 = wx_radio_button_create(panel, int(ID_RADIO2, c_int), "Option B", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call wx_sizer_add_window(left_sizer, radio2, &
        0_c_int, wxALL(), 5_c_int, c_null_ptr)

    radio3 = wx_radio_button_create(panel, int(ID_RADIO3, c_int), "Option C", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call wx_sizer_add_window(left_sizer, radio3, &
        0_c_int, wxALL(), 5_c_int, c_null_ptr)

    ! Right column: choice, listbox, combobox
    right_sizer = wx_box_sizer_create(wxVERTICAL())

    ! Choice (dropdown)
    lbl_choice = wx_static_text_create(panel, wxID_ANY(), "Choice:", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call wx_sizer_add_window(right_sizer, lbl_choice, &
        0_c_int, ior(wxLEFT(), wxTOP()), 5_c_int, c_null_ptr)

    choice = wx_choice_create(panel, wxID_ANY(), -1_c_int, -1_c_int, &
        -1_c_int, -1_c_int, no_choices, 0_c_int)
    call wx_choice_append(choice, "Red")
    call wx_choice_append(choice, "Green")
    call wx_choice_append(choice, "Blue")
    call wx_choice_append(choice, "Yellow")
    call wx_choice_set_selection(choice, 0_c_int)
    call wx_sizer_add_window(right_sizer, choice, &
        0_c_int, ior(wxEXPAND(), wxALL()), 5_c_int, c_null_ptr)

    ! ListBox
    lbl_listbox = wx_static_text_create(panel, wxID_ANY(), "ListBox:", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call wx_sizer_add_window(right_sizer, lbl_listbox, &
        0_c_int, ior(wxLEFT(), wxTOP()), 5_c_int, c_null_ptr)

    listbox = wx_list_box_create(panel, wxID_ANY(), -1_c_int, -1_c_int, &
        -1_c_int, -1_c_int, no_choices, wxLB_SINGLE())
    call wx_list_box_append(listbox, "Mercury")
    call wx_list_box_append(listbox, "Venus")
    call wx_list_box_append(listbox, "Earth")
    call wx_list_box_append(listbox, "Mars")
    call wx_list_box_append(listbox, "Jupiter")
    call wx_sizer_add_window(right_sizer, listbox, &
        1_c_int, ior(wxEXPAND(), wxALL()), 5_c_int, c_null_ptr)

    ! ComboBox
    lbl_combo = wx_static_text_create(panel, wxID_ANY(), "ComboBox:", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call wx_sizer_add_window(right_sizer, lbl_combo, &
        0_c_int, ior(wxLEFT(), wxTOP()), 5_c_int, c_null_ptr)

    combobox = wx_combo_box_create(panel, wxID_ANY(), "", -1_c_int, -1_c_int, &
        -1_c_int, -1_c_int, no_choices, wxCB_DROPDOWN())
    call wx_combo_box_append(combobox, "Fortran")
    call wx_combo_box_append(combobox, "C++")
    call wx_combo_box_append(combobox, "Python")
    call wx_combo_box_append(combobox, "Rust")
    call wx_sizer_add_window(right_sizer, combobox, &
        0_c_int, ior(wxEXPAND(), wxALL()), 5_c_int, c_null_ptr)

    ! Assemble layout
    call wx_sizer_add_sizer(h_sizer, left_sizer, &
        1_c_int, wxEXPAND(), 0_c_int, c_null_ptr)
    call wx_sizer_add_sizer(h_sizer, right_sizer, &
        2_c_int, wxEXPAND(), 0_c_int, c_null_ptr)

    ! Main vertical sizer wraps the horizontal one
    main_sizer = wx_box_sizer_create(wxVERTICAL())
    call wx_sizer_add_sizer(main_sizer, h_sizer, &
        1_c_int, ior(wxEXPAND(), wxALL()), 5_c_int, c_null_ptr)

    call wx_window_set_sizer(panel, main_sizer, .false.)

    !===================================================================
    ! Connect control events
    !===================================================================

    call wx_connect(checkbox, wxEVT_CHECKBOX(), &
        on_checkbox_toggle)
    call wx_connect(radio1, wxEVT_RADIOBUTTON(), &
        on_radio_selected)
    call wx_connect(radio2, wxEVT_RADIOBUTTON(), &
        on_radio_selected)
    call wx_connect(radio3, wxEVT_RADIOBUTTON(), &
        on_radio_selected)
    call wx_connect(choice, wxEVT_CHOICE(), &
        on_choice_selected)
    call wx_connect(listbox, wxEVT_LISTBOX(), &
        on_listbox_selected)
    call wx_connect(combobox, wxEVT_COMBOBOX(), &
        on_combobox_selected)

    !===================================================================
    ! Status bar and show
    !===================================================================

    status_bar = wx_frame_create_status_bar(frame, 1_c_int, &
        wxSTB_DEFAULT_STYLE(), 0_c_int)
    call wx_frame_set_status_text(frame, "kwxFortran Controls Demo - Phase 5", &
        0_c_int)

    call wx_window_center(frame, wxBOTH())
    call wx_set_top_window(frame)
    shown = wx_window_show(frame)

    ! Run the main event loop
    exit_code = wx_main_loop()

    ! Cleanup
    call wx_shutdown()

end program controls_demo
