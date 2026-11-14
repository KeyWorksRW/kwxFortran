! preferences.f90 - wxPreferencesEditor sample
!
! Fortran port of wxWidgets sample src/preferences/preferences.cpp (kwxFortran).
!
! A frame titled "Preferences sample" displays the current values of two
! application settings ("Markdown syntax: yes/no", "Spell checking: on/off")
! and has a File menu with "Preferences" and "Exit".  Preferences opens the
! platform-native preferences editor built from a stock "General" page (two
! check boxes) and a custom "Topics" page (a topic list box, a fulltext check
! box and the wxART_HELP toolbar icon).
!
! Conversion notes
! ---------------
! * MySettings is kept in module preferences_globals as two LOGICALs, with the
!   same hardcoded initial values as MySettings::MySettings().
! * PrefsPageGeneralPanel / PrefsPageTopicsPanel are kwxPanel helpers, so their
!   TransferDataToWindow()/TransferDataFromWindow() overrides run through the
!   same wxDialog machinery the C++ relies on (the panel hooks return int).
! * PrefsPageGeneral derives from wxStockPreferencesPage(Kind_General) and gets
!   CreateWindow() from the SetOnCreateWindow hook (the stock helper always
!   passes a null object pointer, so the page is identified by module state).
! * PrefsPageTopics uses kwxPreferencesPage; GetName()/GetIcon()/CreateWindow()
!   are supplied through the matching SetOn* hooks.  The FFI callback ABI is
!   void-returning, so each hook publishes its result with SetOn*Result().
! * MyApp's std::unique_ptr<wxPreferencesEditor> is g_pref_editor.  The editor
!   owns both pages, so the page handles are marked as borrowed.
! * GTKAllowDiagnosticsControl() (#ifdef __WXGTK__) has no kwxFFI binding; it
!   only silences wxGTK notebook teardown diagnostics and does not exist here.

module preferences_globals
    use kwx_types
    implicit none

    ! MySettings -- values edited in the preferences dialog.
    logical, save :: g_use_markdown = .true.
    logical, save :: g_spellcheck = .false.

    ! Values corresponding to the current contents of the dialog
    ! (MySettings m_settingsCurrent).
    logical, save :: g_current_use_markdown = .true.
    logical, save :: g_current_spellcheck = .false.

    ! MyFrame.
    type(wxFrame_t), save :: g_frame
    type(wxStaticText_t), save :: g_text_markdown
    type(wxStaticText_t), save :: g_text_spellcheck

    ! MyApp::m_prefEditor (std::unique_ptr<wxPreferencesEditor>).
    type(wxPreferencesEditor_t), save :: g_pref_editor
    logical, save :: g_editor_created = .false.

    ! PrefsPageGeneral : wxStockPreferencesPage(Kind_General).
    type(wxStockPreferencesPage_t), save :: g_general_page

    ! PrefsPageGeneralPanel.
    type(kwxPanel_t), save :: g_general_panel
    type(wxCheckBox_t), save :: g_general_use_markdown
    type(wxCheckBox_t), save :: g_general_spellcheck

    ! PrefsPageTopics : wxPreferencesPage.
    type(kwxPreferencesPage_t), save :: g_topics_page

    ! PrefsPageTopicsPanel.
    type(kwxPanel_t), save :: g_topics_panel
    type(wxCheckBox_t), save :: g_topics_fulltext

end module preferences_globals


module preferences_settings
    use wx_window, only: wx_window_set_label
    use preferences_globals
    implicit none
    private

    public :: update_settings_display, app_update_settings

contains

    !--------------------------------------------------------------------------
    ! MyFrame::UpdateSettings() -- refresh the values shown on screen.
    !--------------------------------------------------------------------------
    subroutine update_settings_display()
        if (g_use_markdown) then
            call wx_window_set_label(g_text_markdown, "yes")
        else
            call wx_window_set_label(g_text_markdown, "no")
        end if

        if (g_spellcheck) then
            call wx_window_set_label(g_text_spellcheck, "on")
        else
            call wx_window_set_label(g_text_spellcheck, "off")
        end if
    end subroutine update_settings_display

    !--------------------------------------------------------------------------
    ! MyApp::UpdateSettings() -- store the values and refresh the frame.
    !--------------------------------------------------------------------------
    subroutine app_update_settings(use_markdown, spellcheck)
        logical, intent(in) :: use_markdown, spellcheck

        g_use_markdown = use_markdown
        g_spellcheck = spellcheck
        call update_settings_display()
    end subroutine app_update_settings

end module preferences_settings


module preferences_ui
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_ANY, wxALL, wxVERTICAL, wxEVT_CHECKBOX, &
        wxTAB_TRAVERSAL, wxBORDER_NONE, wxART_HELP, wxART_TOOLBAR, &
        wxApp_SetAppDisplayName, wxGetApp, wxPreferencesEditor_AddPage
    use wx_string, only: to_wxstring, from_wxstring, wxString_Delete
    use wx_events, only: wx_connect, wx_event_skip, wx_command_event_is_checked
    use kwx_panel, only: kwx_panel_create, &
        kwx_panel_set_on_transfer_data_to_window, &
        kwx_panel_set_on_transfer_data_from_window
    use wx_window, only: wx_window_set_min_size, wx_window_set_sizer_and_fit, &
        wx_window_close
    use wx_static_text, only: wx_static_text_create
    use wx_check_box, only: wx_check_box_create, wx_check_box_set_value
    use wx_list_box, only: wx_list_box_create
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add_window_flags
    use wx_sizer_flags, only: wx_sizer_flags_create, wx_sizer_flags_delete, &
        wx_sizer_flags_border, wx_sizer_flags_expand
    use wx_art_provider, only: wx_art_provider_get_bitmap_bundle
    use wx_preferences_editor, only: wx_preferences_editor_create, &
        wx_preferences_editor_delete, wx_preferences_editor_add_page, &
        wx_preferences_editor_show, wx_preferences_editor_dismiss, &
        wx_preferences_editor_should_apply_changes_immediately
    use kwx_preferences_page, only: kwx_preferences_page_create
    use wx_preferences_page, only: wx_preferences_page_set_on_get_name, &
        wx_preferences_page_set_on_create_window, &
        wx_preferences_page_set_on_get_icon, &
        wx_preferences_page_set_on_get_name_result, &
        wx_preferences_page_set_on_create_window_result, &
        wx_preferences_page_set_on_get_icon_result
    use wx_stock_preferences_page, only: wx_stock_preferences_page_create, &
        wx_stock_preferences_page_set_on_create_window, &
        wx_stock_preferences_page_set_on_create_window_result
    use preferences_globals
    use preferences_settings
    implicit none
    private

    public :: on_pref, on_exit, on_close
    public :: set_app_display_name, destroy_preferences_editor

contains

    !--------------------------------------------------------------------------
    ! SetAppDisplayName("wxWidgets Sample")
    !
    ! Used in the title of the preferences dialog; the generated wx_app wrapper
    ! module is not part of the build, so the raw wxApp export is used here.
    !--------------------------------------------------------------------------
    subroutine set_app_display_name(name)
        character(len=*), intent(in) :: name
        type(c_ptr) :: name_ptr

        name_ptr = to_wxstring(name)
        call wxApp_SetAppDisplayName(wxGetApp(), name_ptr)
        call wxString_Delete(name_ptr)
    end subroutine set_app_display_name

    !--------------------------------------------------------------------------
    ! MyApp::ShowPreferencesEditor(parent)
    !--------------------------------------------------------------------------
    subroutine show_preferences_editor(parent)
        class(wxWindow_t), intent(in) :: parent

        if (.not. g_editor_created) then
            ! new wxPreferencesEditor -- the empty title lets the platform use
            ! "<display name> Preferences".
            g_pref_editor = wx_preferences_editor_create("")
            if (.not. g_pref_editor%is_valid()) return
            g_editor_created = .true.

            call create_general_page()
            call create_topics_page()

            ! AddPage(new PrefsPageGeneral());
            if (g_general_page%is_valid()) then
                call wxPreferencesEditor_AddPage(g_pref_editor%ptr, &
                    g_general_page%ptr)
            end if

            ! AddPage(new PrefsPageTopics());
            if (g_topics_page%is_valid()) then
                call wx_preferences_editor_add_page(g_pref_editor, g_topics_page)
            end if
        end if

        call wx_preferences_editor_show(g_pref_editor, parent)
    end subroutine show_preferences_editor

    !--------------------------------------------------------------------------
    ! MyApp::DismissPreferencesEditor()
    !--------------------------------------------------------------------------
    subroutine dismiss_preferences_editor()
        if (g_editor_created) call wx_preferences_editor_dismiss(g_pref_editor)
    end subroutine dismiss_preferences_editor

    !--------------------------------------------------------------------------
    ! MyApp destructor: the editor owns the two pages it was given.
    !--------------------------------------------------------------------------
    subroutine destroy_preferences_editor()
        if (g_editor_created) then
            call wx_preferences_editor_delete(g_pref_editor)
            g_editor_created = .false.
        end if
        g_general_page%ptr = c_null_ptr
        g_topics_page%ptr = c_null_ptr
    end subroutine destroy_preferences_editor

    !--------------------------------------------------------------------------
    ! File > Preferences -- wxGetApp().ShowPreferencesEditor(this)
    !--------------------------------------------------------------------------
    subroutine on_pref(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return

        call show_preferences_editor(g_frame)
    end subroutine on_pref

    !--------------------------------------------------------------------------
    ! File > Exit -- Close()
    !--------------------------------------------------------------------------
    subroutine on_exit(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: closed

        if (.not. c_associated(evt)) return

        closed = wx_window_close(g_frame, .false.)
    end subroutine on_exit

    !--------------------------------------------------------------------------
    ! MyFrame::OnClose -- DismissPreferencesEditor(); e.Skip();
    !--------------------------------------------------------------------------
    subroutine on_close(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return

        call dismiss_preferences_editor()
        call wx_event_skip(evt)
    end subroutine on_close

    !==========================================================================
    ! PrefsPageGeneral : wxStockPreferencesPage(Kind_General)
    !==========================================================================

    subroutine create_general_page()
        type(c_ptr) :: hook

        ! wxStockPreferencesPage::Kind_General == 0.
        g_general_page = wx_stock_preferences_page_create(0_c_int)
        if (.not. g_general_page%is_valid()) return

        ! wxPreferencesEditor takes ownership of every page added to it.
        g_general_page%owned = .false.

        hook = transfer(c_funloc(on_general_page_create_window), c_null_ptr)
        call wx_stock_preferences_page_set_on_create_window(g_general_page, hook)
    end subroutine create_general_page

    !--------------------------------------------------------------------------
    ! PrefsPageGeneral::CreateWindow(parent)
    !--------------------------------------------------------------------------
    subroutine on_general_page_create_window(pobject, parent) bind(C)
        type(c_ptr), value :: pobject, parent

        if (.not. c_associated(parent)) return

        call create_general_panel(parent)
        if (.not. g_general_panel%is_valid()) return

        call wx_stock_preferences_page_set_on_create_window_result( &
            g_general_page, g_general_panel)
    end subroutine on_general_page_create_window

    !--------------------------------------------------------------------------
    ! PrefsPageGeneralPanel constructor.
    !--------------------------------------------------------------------------
    subroutine create_general_panel(parent_ptr)
        type(c_ptr), intent(in) :: parent_ptr
        type(wxWindow_t) :: parent
        type(wxBoxSizer_t) :: sizer
        type(wxSizerFlags_t) :: flags

        parent%ptr = parent_ptr

        ! wxPanel(parent) -- wxTAB_TRAVERSAL | wxNO_BORDER.
        g_general_panel = kwx_panel_create(c_null_ptr, parent, wxID_ANY(), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            int(ior(wxTAB_TRAVERSAL(), wxBORDER_NONE()), c_long))
        if (.not. g_general_panel%is_valid()) return

        ! The preferences dialog owns the page window.
        g_general_panel%owned = .false.

        ! TransferDataToWindow()/TransferDataFromWindow() overrides.
        call kwx_panel_set_on_transfer_data_to_window(g_general_panel, &
            transfer(c_funloc(on_general_transfer_to), c_null_ptr))
        call kwx_panel_set_on_transfer_data_from_window(g_general_panel, &
            transfer(c_funloc(on_general_transfer_from), c_null_ptr))

        ! m_useMarkdown = new wxCheckBox(this, wxID_ANY, "Use Markdown syntax");
        g_general_use_markdown = wx_check_box_create(g_general_panel, &
            wxID_ANY(), "Use Markdown syntax", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)

        ! m_spellcheck = new wxCheckBox(this, wxID_ANY, "Check spelling");
        g_general_spellcheck = wx_check_box_create(g_general_panel, &
            wxID_ANY(), "Check spelling", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)

        ! wxSizer *sizer = new wxBoxSizer(wxVERTICAL);
        sizer = wx_box_sizer_create(wxVERTICAL())

        ! sizer->Add(m_useMarkdown, wxSizerFlags().Border());
        flags = wx_sizer_flags_create(0_c_int)
        call wx_sizer_flags_border(flags, wxALL())
        call wx_sizer_add_window_flags(sizer, g_general_use_markdown, flags)
        call wx_sizer_flags_delete(flags)

        ! sizer->Add(m_spellcheck, wxSizerFlags().Border());
        flags = wx_sizer_flags_create(0_c_int)
        call wx_sizer_flags_border(flags, wxALL())
        call wx_sizer_add_window_flags(sizer, g_general_spellcheck, flags)
        call wx_sizer_flags_delete(flags)

        call wx_window_set_sizer_and_fit(g_general_panel, sizer, .true.)

        call wx_connect(g_general_use_markdown, wxEVT_CHECKBOX(), &
            on_changed_use_markdown)
        call wx_connect(g_general_spellcheck, wxEVT_CHECKBOX(), &
            on_changed_spellcheck)
    end subroutine create_general_panel

    !--------------------------------------------------------------------------
    ! PrefsPageGeneralPanel::TransferDataToWindow()
    !--------------------------------------------------------------------------
    function on_general_transfer_to(pobject) bind(C) result(res)
        type(c_ptr), value :: pobject
        integer(c_int) :: res

        g_current_use_markdown = g_use_markdown
        g_current_spellcheck = g_spellcheck
        call wx_check_box_set_value(g_general_use_markdown, &
            merge(1_c_int, 0_c_int, g_current_use_markdown))
        call wx_check_box_set_value(g_general_spellcheck, &
            merge(1_c_int, 0_c_int, g_current_spellcheck))

        res = 1_c_int
    end function on_general_transfer_to

    !--------------------------------------------------------------------------
    ! PrefsPageGeneralPanel::TransferDataFromWindow()
    !--------------------------------------------------------------------------
    function on_general_transfer_from(pobject) bind(C) result(res)
        type(c_ptr), value :: pobject
        integer(c_int) :: res

        call app_update_settings(g_current_use_markdown, g_current_spellcheck)

        res = 1_c_int
    end function on_general_transfer_from

    !--------------------------------------------------------------------------
    ! PrefsPageGeneralPanel::UpdateSettingsIfNecessary()
    !
    ! Changes are applied immediately only on platforms whose preferences
    ! dialog works that way (macOS, GTK+); elsewhere they wait for OK.
    !--------------------------------------------------------------------------
    subroutine update_settings_if_necessary()
        if (wx_preferences_editor_should_apply_changes_immediately()) then
            call app_update_settings(g_current_use_markdown, &
                g_current_spellcheck)
        end if
    end subroutine update_settings_if_necessary

    !--------------------------------------------------------------------------
    ! PrefsPageGeneralPanel::ChangedUseMarkdown()
    !--------------------------------------------------------------------------
    subroutine on_changed_use_markdown(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return

        g_current_use_markdown = wx_command_event_is_checked(evt)
        call update_settings_if_necessary()
    end subroutine on_changed_use_markdown

    !--------------------------------------------------------------------------
    ! PrefsPageGeneralPanel::ChangedSpellcheck()
    !--------------------------------------------------------------------------
    subroutine on_changed_spellcheck(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return

        g_current_spellcheck = wx_command_event_is_checked(evt)
        call update_settings_if_necessary()
    end subroutine on_changed_spellcheck

    !==========================================================================
    ! PrefsPageTopics : wxPreferencesPage
    !==========================================================================

    subroutine create_topics_page()
        type(c_ptr) :: hook

        ! kwxPreferencesPage helper: GetName() is pure virtual, so the callback
        ! must be installed before the page is handed to the editor.
        g_topics_page%ptr = kwx_preferences_page_create(c_null_ptr)
        if (.not. c_associated(g_topics_page%ptr)) return

        ! wxPreferencesEditor takes ownership of every page added to it.
        g_topics_page%owned = .false.

        hook = transfer(c_funloc(on_topics_get_name), c_null_ptr)
        call wx_preferences_page_set_on_get_name(g_topics_page, hook)

        hook = transfer(c_funloc(on_topics_get_icon), c_null_ptr)
        call wx_preferences_page_set_on_get_icon(g_topics_page, hook)

        hook = transfer(c_funloc(on_topics_create_window), c_null_ptr)
        call wx_preferences_page_set_on_create_window(g_topics_page, hook)
    end subroutine create_topics_page

    !--------------------------------------------------------------------------
    ! PrefsPageTopics::GetName()
    !--------------------------------------------------------------------------
    subroutine on_topics_get_name(pobject) bind(C)
        type(c_ptr), value :: pobject

        call wx_preferences_page_set_on_get_name_result(g_topics_page, "Topics")
    end subroutine on_topics_get_name

    !--------------------------------------------------------------------------
    ! PrefsPageTopics::GetIcon()
    !
    ! wxArtProvider::GetBitmapBundle(wxART_HELP, wxART_TOOLBAR).  The page
    ! copies the bundle and deletes the original, so ownership passes over.
    !--------------------------------------------------------------------------
    subroutine on_topics_get_icon(pobject) bind(C)
        type(c_ptr), value :: pobject
        type(c_ptr) :: art_ptr
        character(len=:), allocatable :: art_id, art_client
        type(wxBitmapBundle_t) :: bundle

        art_ptr = wxART_HELP()
        art_id = from_wxstring(art_ptr)
        call wxString_Delete(art_ptr)

        art_ptr = wxART_TOOLBAR()
        art_client = from_wxstring(art_ptr)
        call wxString_Delete(art_ptr)

        bundle = wx_art_provider_get_bitmap_bundle(art_id, art_client, &
            -1_c_int, -1_c_int)
        if (.not. bundle%is_valid()) return

        call wx_preferences_page_set_on_get_icon_result(g_topics_page, bundle)

        ! GetIcon() copied the bundle; the page deletes the original.
        bundle%owned = .false.
        bundle%ptr = c_null_ptr
    end subroutine on_topics_get_icon

    !--------------------------------------------------------------------------
    ! PrefsPageTopics::CreateWindow(parent)
    !--------------------------------------------------------------------------
    subroutine on_topics_create_window(pobject, parent) bind(C)
        type(c_ptr), value :: pobject, parent

        if (.not. c_associated(parent)) return

        call create_topics_panel(parent)
        if (.not. g_topics_panel%is_valid()) return

        call wx_preferences_page_set_on_create_window_result(g_topics_page, &
            g_topics_panel)
    end subroutine on_topics_create_window

    !--------------------------------------------------------------------------
    ! PrefsPageTopicsPanel constructor.
    !--------------------------------------------------------------------------
    subroutine create_topics_panel(parent_ptr)
        type(c_ptr), intent(in) :: parent_ptr
        type(wxWindow_t) :: parent
        type(wxBoxSizer_t) :: sizer
        type(wxSizerFlags_t) :: flags
        type(wxStaticText_t) :: label
        type(wxListBox_t) :: box
        character(len=1) :: no_choices(0)

        parent%ptr = parent_ptr

        ! wxPanel(parent) -- wxTAB_TRAVERSAL | wxNO_BORDER.
        g_topics_panel = kwx_panel_create(c_null_ptr, parent, wxID_ANY(), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            int(ior(wxTAB_TRAVERSAL(), wxBORDER_NONE()), c_long))
        if (.not. g_topics_panel%is_valid()) return

        ! The preferences dialog owns the page window.
        g_topics_panel%owned = .false.

        call kwx_panel_set_on_transfer_data_to_window(g_topics_panel, &
            transfer(c_funloc(on_topics_transfer_to), c_null_ptr))
        call kwx_panel_set_on_transfer_data_from_window(g_topics_panel, &
            transfer(c_funloc(on_topics_transfer_from), c_null_ptr))

        sizer = wx_box_sizer_create(wxVERTICAL())

        ! sizer->Add(new wxStaticText(this, wxID_ANY, "Search in these topics:"),
        !            wxSizerFlags().Border());
        label = wx_static_text_create(g_topics_panel, wxID_ANY(), &
            "Search in these topics:", -1_c_int, -1_c_int, -1_c_int, &
            -1_c_int, 0_c_int)
        flags = wx_sizer_flags_create(0_c_int)
        call wx_sizer_flags_border(flags, wxALL())
        call wx_sizer_add_window_flags(sizer, label, flags)
        call wx_sizer_flags_delete(flags)

        ! wxListBox *box = new wxListBox(this, wxID_ANY);
        ! box->SetMinSize(wxSize(400, 300));
        ! sizer->Add(box, wxSizerFlags(1).Border().Expand());
        box = wx_list_box_create(g_topics_panel, wxID_ANY(), -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, no_choices, 0_c_int)
        call wx_window_set_min_size(box, 400_c_int, 300_c_int)

        flags = wx_sizer_flags_create(1_c_int)
        call wx_sizer_flags_border(flags, wxALL())
        call wx_sizer_flags_expand(flags)
        call wx_sizer_add_window_flags(sizer, box, flags)
        call wx_sizer_flags_delete(flags)

        ! m_fulltext = new wxCheckBox(this, wxID_ANY,
        !                            "Automatically build fulltext index");
        g_topics_fulltext = wx_check_box_create(g_topics_panel, wxID_ANY(), &
            "Automatically build fulltext index", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)

        flags = wx_sizer_flags_create(0_c_int)
        call wx_sizer_flags_border(flags, wxALL())
        call wx_sizer_add_window_flags(sizer, g_topics_fulltext, flags)
        call wx_sizer_flags_delete(flags)

        call wx_window_set_sizer_and_fit(g_topics_panel, sizer, .true.)

        if (wx_preferences_editor_should_apply_changes_immediately()) then
            call wx_connect(g_topics_fulltext, wxEVT_CHECKBOX(), &
                on_changed_fulltext)
        end if
    end subroutine create_topics_panel

    !--------------------------------------------------------------------------
    ! PrefsPageTopicsPanel::TransferDataToWindow() -- hardcoded true.
    !--------------------------------------------------------------------------
    function on_topics_transfer_to(pobject) bind(C) result(res)
        type(c_ptr), value :: pobject
        integer(c_int) :: res

        call wx_check_box_set_value(g_topics_fulltext, 1_c_int)

        res = 1_c_int
    end function on_topics_transfer_to

    !--------------------------------------------------------------------------
    ! PrefsPageTopicsPanel::TransferDataFromWindow()
    !
    ! Only the modal-dialog platforms call it, and ChangedFulltext(dummy) has an
    ! empty body there, so nothing is transferred back.
    !--------------------------------------------------------------------------
    function on_topics_transfer_from(pobject) bind(C) result(res)
        type(c_ptr), value :: pobject
        integer(c_int) :: res

        res = 1_c_int
    end function on_topics_transfer_from

    !--------------------------------------------------------------------------
    ! PrefsPageTopicsPanel::ChangedFulltext()
    !
    ! The C++ body only holds a comment, so the event is consumed and ignored.
    !--------------------------------------------------------------------------
    subroutine on_changed_fulltext(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
    end subroutine on_changed_fulltext

end module preferences_ui


program preferences
    use, intrinsic :: iso_c_binding
    use wx_app
    use wx_frame
    use wx_panel, only: wx_panel_create
    use wx_static_text, only: wx_static_text_create
    use wx_flex_grid_sizer, only: wx_flex_grid_sizer_create
    use wx_sizer, only: wx_sizer_add_window_flags
    use wx_sizer_flags, only: wx_sizer_flags_create, wx_sizer_flags_delete, &
        wx_sizer_flags_center, wx_sizer_flags_right
    use wx_menu, only: wx_menu_create, wx_menu_append
    use wx_menu_bar, only: wx_menu_bar_create, wx_menu_bar_append
    use wx_window, only: wx_window_set_sizer, wx_window_show
    use wx_events, only: wx_connect
    use kwx_types
    use kwxffi, only: wxID_ANY, wxID_PREFERENCES, wxID_EXIT, wxEVT_MENU, &
        wxEVT_CLOSE_WINDOW, wxDEFAULT_FRAME_STYLE, wxTAB_TRAVERSAL, &
        wxBORDER_NONE
    use preferences_globals
    use preferences_settings, only: update_settings_display
    use preferences_ui
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxPanel_t) :: panel
    type(wxStaticText_t) :: label_markdown, label_spellcheck
    type(wxFlexGridSizer_t) :: sizer
    type(wxSizerFlags_t) :: flags
    type(wxMenu_t) :: file_menu
    type(wxMenuBar_t) :: menu_bar
    integer :: exit_code, dummy
    logical :: shown

    ! wxIMPLEMENT_APP / MyApp::OnInit()
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    ! SetAppDisplayName("wxWidgets Sample")
    call set_app_display_name("wxWidgets Sample")

    ! m_frame = new MyFrame();
    no_parent%ptr = c_null_ptr
    g_frame = wx_frame_create(no_parent, wxID_ANY(), "Preferences sample", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, wxDEFAULT_FRAME_STYLE())
    if (.not. g_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    ! wxMenu *fileMenu = new wxMenu;
    file_menu = wx_menu_create("", 0_c_long)

    ! fileMenu->Append(wxID_PREFERENCES); fileMenu->Append(wxID_EXIT);
    ! The empty label/help make wxMenuItemBase substitute the stock text.
    call wx_menu_append(file_menu, wxID_PREFERENCES(), "", "", .false.)
    call wx_menu_append(file_menu, wxID_EXIT(), "", "", .false.)

    ! menuBar->Append(fileMenu, "&File"); SetMenuBar(menuBar);
    menu_bar = wx_menu_bar_create(0_c_int)
    dummy = wx_menu_bar_append(menu_bar, file_menu, "&File")
    call wx_frame_set_menu_bar(g_frame, menu_bar)

    ! Bind(wxEVT_MENU, OnPref, wxID_PREFERENCES);
    ! Bind(wxEVT_MENU, OnExit, wxID_EXIT);
    ! Bind(wxEVT_CLOSE_WINDOW, OnClose);
    call wx_connect(g_frame, wxEVT_MENU(), on_pref, id=wxID_PREFERENCES())
    call wx_connect(g_frame, wxEVT_MENU(), on_exit, id=wxID_EXIT())
    call wx_connect(g_frame, wxEVT_CLOSE_WINDOW(), on_close)

    ! wxPanel* const panel = new wxPanel(this);
    panel = wx_panel_create(g_frame, wxID_ANY(), -1_c_int, -1_c_int, &
        -1_c_int, -1_c_int, ior(wxTAB_TRAVERSAL(), wxBORDER_NONE()))

    ! m_textMarkdownSyntax = new wxStaticText(panel, wxID_ANY, "");
    ! m_textSpellcheck = new wxStaticText(panel, wxID_ANY, "");
    g_text_markdown = wx_static_text_create(panel, wxID_ANY(), "", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    g_text_spellcheck = wx_static_text_create(panel, wxID_ANY(), "", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)

    ! wxSizer* const sizer = new wxFlexGridSizer(2, wxSize(5, 5));
    sizer = wx_flex_grid_sizer_create(0_c_int, 2_c_int, 5_c_int, 5_c_int)

    ! sizer->Add(new wxStaticText(panel, wxID_ANY, "Markdown syntax:"),
    !            wxSizerFlags().Center().Right());
    label_markdown = wx_static_text_create(panel, wxID_ANY(), &
        "Markdown syntax:", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    flags = wx_sizer_flags_create(0_c_int)
    call wx_sizer_flags_center(flags)
    call wx_sizer_flags_right(flags)
    call wx_sizer_add_window_flags(sizer, label_markdown, flags)
    call wx_sizer_flags_delete(flags)

    ! sizer->Add(m_textMarkdownSyntax, wxSizerFlags().Center());
    flags = wx_sizer_flags_create(0_c_int)
    call wx_sizer_flags_center(flags)
    call wx_sizer_add_window_flags(sizer, g_text_markdown, flags)
    call wx_sizer_flags_delete(flags)

    ! sizer->Add(new wxStaticText(panel, wxID_ANY, "Spell checking:"),
    !            wxSizerFlags().Center().Right());
    label_spellcheck = wx_static_text_create(panel, wxID_ANY(), &
        "Spell checking:", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    flags = wx_sizer_flags_create(0_c_int)
    call wx_sizer_flags_center(flags)
    call wx_sizer_flags_right(flags)
    call wx_sizer_add_window_flags(sizer, label_spellcheck, flags)
    call wx_sizer_flags_delete(flags)

    ! sizer->Add(m_textSpellcheck, wxSizerFlags().Center());
    flags = wx_sizer_flags_create(0_c_int)
    call wx_sizer_flags_center(flags)
    call wx_sizer_add_window_flags(sizer, g_text_spellcheck, flags)
    call wx_sizer_flags_delete(flags)

    ! panel->SetSizer(sizer);
    call wx_window_set_sizer(panel, sizer, .true.)

    ! Show the initial values.
    call update_settings_display()

    ! m_frame->Show(true);
    call wx_set_top_window(g_frame)
    shown = wx_window_show(g_frame)

    ! wxApp::OnRun()
    exit_code = wx_main_loop()

    ! Destroying the editor deletes the two pages it owns.
    call destroy_preferences_editor()
    call wx_shutdown()

end program preferences
