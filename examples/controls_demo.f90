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
    use wx_app
    use wx_frame
    use wx_controls
    use wx_menus
    use wx_sizers
    use wx_window
    use wx_events
    use wxffi_types
    use wxffi_constants
    use controls_demo_handlers
    implicit none

    type(wxFrame_t) :: frame
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

    integer :: exit_code
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
    frame = wx_frame_create( &
        title = "kwxFortran Controls Demo", &
        width = 600, &
        height = 500 &
    )
    if (.not. frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    !===================================================================
    ! Create menu bar
    !===================================================================

    ! File menu
    file_menu = wx_menu_create()
    call wx_menu_append(file_menu, wxID_NEW(), "&New", "Create new")
    call wx_menu_append(file_menu, wxID_OPEN(), "&Open", "Open file")
    call wx_menu_append(file_menu, wxID_SAVE(), "&Save", "Save file")
    call wx_menu_append_separator(file_menu)
    call wx_menu_append(file_menu, wxID_EXIT(), "E&xit", "Exit application")

    ! Edit menu
    edit_menu = wx_menu_create()
    call wx_menu_append(edit_menu, wxID_UNDO(), "&Undo")
    call wx_menu_append(edit_menu, wxID_REDO(), "&Redo")
    call wx_menu_append_separator(edit_menu)
    call wx_menu_append(edit_menu, wxID_CUT(), "Cu&t")
    call wx_menu_append(edit_menu, wxID_COPY(), "&Copy")
    call wx_menu_append(edit_menu, wxID_PASTE(), "&Paste")

    ! Help menu
    help_menu = wx_menu_create()
    call wx_menu_append(help_menu, wxID_ABOUT(), "&About", "About this demo")

    ! Create and populate menu bar
    menubar = wx_menubar_create()
    call wx_menubar_append(menubar, file_menu, "&File")
    call wx_menubar_append(menubar, edit_menu, "&Edit")
    call wx_menubar_append(menubar, help_menu, "&Help")
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

    panel = wx_panel_create(parent=frame)

    ! Horizontal sizer to split left and right columns
    h_sizer = wx_box_sizer_create(wxHORIZONTAL())

    ! Left column: checkbox and radio buttons
    left_sizer = wx_box_sizer_create(wxVERTICAL())

    checkbox = wx_checkbox_create("Enable feature", parent=panel)
    call wx_sizer_add_window(left_sizer, checkbox, &
        proportion=0, flag=wxALL(), border=5)

    radio1 = wx_radiobutton_create("Option A", parent=panel, &
        id=ID_RADIO1, style=wxRB_GROUP())
    call wx_sizer_add_window(left_sizer, radio1, &
        proportion=0, flag=wxALL(), border=5)

    radio2 = wx_radiobutton_create("Option B", parent=panel, &
        id=ID_RADIO2)
    call wx_sizer_add_window(left_sizer, radio2, &
        proportion=0, flag=wxALL(), border=5)

    radio3 = wx_radiobutton_create("Option C", parent=panel, &
        id=ID_RADIO3)
    call wx_sizer_add_window(left_sizer, radio3, &
        proportion=0, flag=wxALL(), border=5)

    ! Right column: choice, listbox, combobox
    right_sizer = wx_box_sizer_create(wxVERTICAL())

    ! Choice (dropdown)
    lbl_choice = wx_static_text_create("Choice:", parent=panel)
    call wx_sizer_add_window(right_sizer, lbl_choice, &
        proportion=0, flag=wxLEFT()+wxTOP(), border=5)

    choice = wx_choice_create(parent=panel)
    call wx_choice_append(choice, "Red")
    call wx_choice_append(choice, "Green")
    call wx_choice_append(choice, "Blue")
    call wx_choice_append(choice, "Yellow")
    call wx_choice_set_selection(choice, 0)
    call wx_sizer_add_window(right_sizer, choice, &
        proportion=0, flag=ior(wxEXPAND(), wxALL()), border=5)

    ! ListBox
    lbl_listbox = wx_static_text_create("ListBox:", parent=panel)
    call wx_sizer_add_window(right_sizer, lbl_listbox, &
        proportion=0, flag=wxLEFT()+wxTOP(), border=5)

    listbox = wx_listbox_create(parent=panel, style=wxLB_SINGLE())
    call wx_listbox_append(listbox, "Mercury")
    call wx_listbox_append(listbox, "Venus")
    call wx_listbox_append(listbox, "Earth")
    call wx_listbox_append(listbox, "Mars")
    call wx_listbox_append(listbox, "Jupiter")
    call wx_sizer_add_window(right_sizer, listbox, &
        proportion=1, flag=ior(wxEXPAND(), wxALL()), border=5)

    ! ComboBox
    lbl_combo = wx_static_text_create("ComboBox:", parent=panel)
    call wx_sizer_add_window(right_sizer, lbl_combo, &
        proportion=0, flag=wxLEFT()+wxTOP(), border=5)

    combobox = wx_combobox_create(parent=panel, style=wxCB_DROPDOWN())
    call wx_combobox_append(combobox, "Fortran")
    call wx_combobox_append(combobox, "C++")
    call wx_combobox_append(combobox, "Python")
    call wx_combobox_append(combobox, "Rust")
    call wx_sizer_add_window(right_sizer, combobox, &
        proportion=0, flag=ior(wxEXPAND(), wxALL()), border=5)

    ! Assemble layout
    call wx_sizer_add_sizer(h_sizer, left_sizer, &
        proportion=1, flag=wxEXPAND())
    call wx_sizer_add_sizer(h_sizer, right_sizer, &
        proportion=2, flag=wxEXPAND())

    ! Main vertical sizer wraps the horizontal one
    main_sizer = wx_box_sizer_create(wxVERTICAL())
    call wx_sizer_add_sizer(main_sizer, h_sizer, &
        proportion=1, flag=ior(wxEXPAND(), wxALL()), border=5)

    call wx_window_set_sizer(panel, main_sizer)

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

    call wx_frame_create_status_bar(frame)
    call wx_frame_set_status_text(frame, "kwxFortran Controls Demo - Phase 5")

    call wx_frame_center(frame)
    call wx_set_top_window(frame)
    call wx_frame_show(frame)

    ! Run the main event loop
    exit_code = wx_main_loop()

    ! Cleanup
    call wx_shutdown()

end program controls_demo
