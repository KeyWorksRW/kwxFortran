! wx_menus.f90 - Fortran wrappers for wxWidgets menu classes
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides high-level Fortran interfaces to:
!   - wxMenu     (popup/dropdown menu)
!   - wxMenuBar  (menu bar for frames)
!   - wxMenuItem (individual menu item)
!
! Usage:
!   use wx_menus
!   use kwx_constants
!   type(wxMenu_t)    :: file_menu
!   type(wxMenuBar_t) :: menubar
!
!   file_menu = wx_menu_create()
!   call wx_menu_append(file_menu, wxID_EXIT(), "&Quit", "Exit the application")
!   menubar = wx_menubar_create()
!   call wx_menubar_append(menubar, file_menu, "&File")
!   call wx_frame_set_menu_bar(frame, menubar)

module wx_menus
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_string, only: to_wxstring, from_wxstring
    implicit none
    private

    ! wxMenu
    public :: wx_menu_create, wx_menu_delete
    public :: wx_menu_append, wx_menu_append_separator
    public :: wx_menu_append_check_item
    ! wx_menu_append_radio_item — blocked on kwxFFI#32 (wxMenu_AppendRadioItem missing)
    public :: wx_menu_enable, wx_menu_check
    public :: wx_menu_is_enabled, wx_menu_is_checked
    public :: wx_menu_get_item_count

    ! wxMenuBar
    public :: wx_menubar_create, wx_menubar_append
    public :: wx_menubar_get_menu_count, wx_menubar_get_menu
    public :: wx_menubar_enable_top

    ! wxMenuItem
    public :: wx_menuitem_create, wx_menuitem_delete
    public :: wx_menuitem_get_id, wx_menuitem_is_separator
    public :: wx_menuitem_get_label, wx_menuitem_set_label
    public :: wx_menuitem_is_checked, wx_menuitem_check
    public :: wx_menuitem_is_enabled, wx_menuitem_enable

contains

    !===========================================================================
    ! wxMenu
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a menu
    !
    ! Parameters:
    !   title - Optional menu title (default: empty)
    !
    ! Returns: wxMenu_t with valid pointer on success
    !---------------------------------------------------------------------------
    function wx_menu_create(title) result(menu)
        character(len=*), intent(in), optional :: title
        type(wxMenu_t) :: menu

        type(c_ptr) :: title_ptr

        if (present(title)) then
            title_ptr = to_wxstring(title)
        else
            title_ptr = to_wxstring("")
        end if

        menu%ptr = wxMenu_Create(title_ptr, 0_c_long)
        call wxString_Delete(title_ptr)
    end function wx_menu_create

    !---------------------------------------------------------------------------
    ! Delete a menu (only if not owned by a menu bar)
    !---------------------------------------------------------------------------
    subroutine wx_menu_delete(menu)
        type(wxMenu_t), intent(in) :: menu

        call wxMenu_DeletePointer(menu%ptr)
    end subroutine wx_menu_delete

    !---------------------------------------------------------------------------
    ! Append a normal menu item
    !
    ! Parameters:
    !   menu - The menu to append to
    !   id   - Menu item ID (use wxID_* constants or custom IDs)
    !   text - Menu item text (use & for accelerator key)
    !   help - Optional status bar help string
    !---------------------------------------------------------------------------
    subroutine wx_menu_append(menu, id, text, help)
        type(wxMenu_t), intent(in) :: menu
        integer, intent(in) :: id
        character(len=*), intent(in) :: text
        character(len=*), intent(in), optional :: help

        type(c_ptr) :: text_ptr, help_ptr

        text_ptr = to_wxstring(text)
        if (present(help)) then
            help_ptr = to_wxstring(help)
        else
            help_ptr = to_wxstring("")
        end if

        call wxMenu_Append(menu%ptr, int(id, c_int), text_ptr, &
            help_ptr, 0_c_int)
        call wxString_Delete(text_ptr)
        call wxString_Delete(help_ptr)
    end subroutine wx_menu_append

    !---------------------------------------------------------------------------
    ! Append a separator
    !---------------------------------------------------------------------------
    subroutine wx_menu_append_separator(menu)
        type(wxMenu_t), intent(in) :: menu

        call wxMenu_AppendSeparator(menu%ptr)
    end subroutine wx_menu_append_separator

    !---------------------------------------------------------------------------
    ! Append a checkable menu item
    !---------------------------------------------------------------------------
    subroutine wx_menu_append_check_item(menu, id, text, help)
        type(wxMenu_t), intent(in) :: menu
        integer, intent(in) :: id
        character(len=*), intent(in) :: text
        character(len=*), intent(in), optional :: help

        type(c_ptr) :: text_ptr, help_ptr

        text_ptr = to_wxstring(text)
        if (present(help)) then
            help_ptr = to_wxstring(help)
        else
            help_ptr = to_wxstring("")
        end if

        call wxMenu_AppendCheckItem(menu%ptr, int(id, c_int), text_ptr, &
            help_ptr)
        call wxString_Delete(text_ptr)
        call wxString_Delete(help_ptr)
    end subroutine wx_menu_append_check_item

    !---------------------------------------------------------------------------
    ! Append a radio menu item
    !---------------------------------------------------------------------------
    ! TODO: Requires wxMenu_AppendRadioItem in kwxFFI (not yet available)
    ! subroutine wx_menu_append_radio_item(menu, id, text, help)
    !     ...
    ! end subroutine wx_menu_append_radio_item

    !---------------------------------------------------------------------------
    ! Enable or disable a menu item
    !---------------------------------------------------------------------------
    subroutine wx_menu_enable(menu, id, enable)
        type(wxMenu_t), intent(in) :: menu
        integer, intent(in) :: id
        logical, intent(in) :: enable

        integer(c_int) :: val
        val = 0
        if (enable) val = 1
        call wxMenu_Enable(menu%ptr, int(id, c_int), val)
    end subroutine wx_menu_enable

    !---------------------------------------------------------------------------
    ! Check or uncheck a menu item
    !---------------------------------------------------------------------------
    subroutine wx_menu_check(menu, id, check)
        type(wxMenu_t), intent(in) :: menu
        integer, intent(in) :: id
        logical, intent(in) :: check

        integer(c_int) :: val
        val = 0
        if (check) val = 1
        call wxMenu_Check(menu%ptr, int(id, c_int), val)
    end subroutine wx_menu_check

    !---------------------------------------------------------------------------
    ! Check if a menu item is enabled
    !---------------------------------------------------------------------------
    function wx_menu_is_enabled(menu, id) result(enabled)
        type(wxMenu_t), intent(in) :: menu
        integer, intent(in) :: id
        logical :: enabled

        enabled = (wxMenu_IsEnabled(menu%ptr, int(id, c_int)) /= 0)
    end function wx_menu_is_enabled

    !---------------------------------------------------------------------------
    ! Check if a menu item is checked
    !---------------------------------------------------------------------------
    function wx_menu_is_checked(menu, id) result(checked)
        type(wxMenu_t), intent(in) :: menu
        integer, intent(in) :: id
        logical :: checked

        checked = (wxMenu_IsChecked(menu%ptr, int(id, c_int)) /= 0)
    end function wx_menu_is_checked

    !---------------------------------------------------------------------------
    ! Get the number of menu items
    !---------------------------------------------------------------------------
    function wx_menu_get_item_count(menu) result(n)
        type(wxMenu_t), intent(in) :: menu
        integer :: n

        n = int(wxMenu_GetMenuItemCount(menu%ptr))
    end function wx_menu_get_item_count

    !===========================================================================
    ! wxMenuBar
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a menu bar
    !---------------------------------------------------------------------------
    function wx_menubar_create() result(menubar)
        type(wxMenuBar_t) :: menubar

        menubar%ptr = wxMenuBar_Create(0)
    end function wx_menubar_create

    !---------------------------------------------------------------------------
    ! Append a menu to the menu bar
    !---------------------------------------------------------------------------
    subroutine wx_menubar_append(menubar, menu, title)
        type(wxMenuBar_t), intent(in) :: menubar
        type(wxMenu_t), intent(in) :: menu
        character(len=*), intent(in) :: title

        type(c_ptr) :: title_ptr
        integer(c_int) :: rc

        title_ptr = to_wxstring(title)
        rc = wxMenuBar_Append(menubar%ptr, menu%ptr, title_ptr)
        call wxString_Delete(title_ptr)
    end subroutine wx_menubar_append

    !---------------------------------------------------------------------------
    ! Get the number of menus in the menu bar
    !---------------------------------------------------------------------------
    function wx_menubar_get_menu_count(menubar) result(n)
        type(wxMenuBar_t), intent(in) :: menubar
        integer :: n

        n = int(wxMenuBar_GetMenuCount(menubar%ptr))
    end function wx_menubar_get_menu_count

    !---------------------------------------------------------------------------
    ! Get a menu by position
    !---------------------------------------------------------------------------
    function wx_menubar_get_menu(menubar, pos) result(menu)
        type(wxMenuBar_t), intent(in) :: menubar
        integer, intent(in) :: pos
        type(wxMenu_t) :: menu

        menu%ptr = wxMenuBar_GetMenu(menubar%ptr, int(pos, c_int))
    end function wx_menubar_get_menu

    !---------------------------------------------------------------------------
    ! Enable or disable a top-level menu by position
    !---------------------------------------------------------------------------
    subroutine wx_menubar_enable_top(menubar, pos, enable)
        type(wxMenuBar_t), intent(in) :: menubar
        integer, intent(in) :: pos
        logical, intent(in) :: enable

        integer(c_int) :: val
        val = 0
        if (enable) val = 1
        call wxMenuBar_EnableTop(menubar%ptr, int(pos, c_int), val)
    end subroutine wx_menubar_enable_top

    !===========================================================================
    ! wxMenuItem
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a menu item
    !
    ! Parameters:
    !   id      - Menu item ID
    !   text    - Menu item text
    !   help    - Optional help string
    !   kind    - Optional item kind (wxITEM_NORMAL, wxITEM_CHECK, wxITEM_RADIO)
    !   submenu - Optional submenu
    !---------------------------------------------------------------------------
    function wx_menuitem_create(id, text, help, kind, submenu) result(item)
        integer, intent(in) :: id
        character(len=*), intent(in) :: text
        character(len=*), intent(in), optional :: help
        integer, intent(in), optional :: kind
        type(wxMenu_t), intent(in), optional :: submenu
        type(wxMenuItem_t) :: item

        type(c_ptr) :: text_ptr, help_ptr

        ! Create default menu item, then configure via setters
        item%ptr = wxMenuItem_Create()

        call wxMenuItem_SetId(item%ptr, int(id, c_int))

        text_ptr = to_wxstring(text)
        call wxMenuItem_SetItemLabel(item%ptr, text_ptr)
        call wxString_Delete(text_ptr)

        if (present(help)) then
            help_ptr = to_wxstring(help)
            call wxMenuItem_SetHelp(item%ptr, help_ptr)
            call wxString_Delete(help_ptr)
        end if

        if (present(kind)) then
            ! wxITEM_CHECK = 1 — use SetCheckable for check items
            if (kind == wxITEM_CHECK()) then
                call wxMenuItem_SetCheckable(item%ptr, 1_c_int)
            end if
            ! wxITEM_RADIO not settable via kwxFFI yet (issue #32)
        end if

        if (present(submenu)) then
            call wxMenuItem_SetSubMenu(item%ptr, submenu%ptr)
        end if
    end function wx_menuitem_create

    !---------------------------------------------------------------------------
    ! Delete a menu item
    !---------------------------------------------------------------------------
    subroutine wx_menuitem_delete(item)
        type(wxMenuItem_t), intent(in) :: item

        call wxMenuItem_Delete(item%ptr)
    end subroutine wx_menuitem_delete

    !---------------------------------------------------------------------------
    ! Get item ID
    !---------------------------------------------------------------------------
    function wx_menuitem_get_id(item) result(id)
        type(wxMenuItem_t), intent(in) :: item
        integer :: id

        id = int(wxMenuItem_GetId(item%ptr))
    end function wx_menuitem_get_id

    !---------------------------------------------------------------------------
    ! Check if item is a separator
    !---------------------------------------------------------------------------
    function wx_menuitem_is_separator(item) result(is_sep)
        type(wxMenuItem_t), intent(in) :: item
        logical :: is_sep

        is_sep = (wxMenuItem_IsSeparator(item%ptr) /= 0)
    end function wx_menuitem_is_separator

    !---------------------------------------------------------------------------
    ! Get item label text
    !---------------------------------------------------------------------------
    function wx_menuitem_get_label(item) result(label)
        type(wxMenuItem_t), intent(in) :: item
        character(len=:), allocatable :: label

        type(c_ptr) :: ws_ptr

        ws_ptr = wxMenuItem_GetItemLabel(item%ptr)
        label = from_wxstring(ws_ptr)
        call wxString_Delete(ws_ptr)
    end function wx_menuitem_get_label

    !---------------------------------------------------------------------------
    ! Set item label text
    !---------------------------------------------------------------------------
    subroutine wx_menuitem_set_label(item, label)
        type(wxMenuItem_t), intent(in) :: item
        character(len=*), intent(in) :: label

        type(c_ptr) :: label_ptr

        label_ptr = to_wxstring(label)
        call wxMenuItem_SetItemLabel(item%ptr, label_ptr)
        call wxString_Delete(label_ptr)
    end subroutine wx_menuitem_set_label

    !---------------------------------------------------------------------------
    ! Check if item is checked
    !---------------------------------------------------------------------------
    function wx_menuitem_is_checked(item) result(checked)
        type(wxMenuItem_t), intent(in) :: item
        logical :: checked

        checked = (wxMenuItem_IsChecked(item%ptr) /= 0)
    end function wx_menuitem_is_checked

    !---------------------------------------------------------------------------
    ! Check or uncheck item
    !---------------------------------------------------------------------------
    subroutine wx_menuitem_check(item, check)
        type(wxMenuItem_t), intent(in) :: item
        logical, intent(in) :: check

        integer(c_int) :: val
        val = 0
        if (check) val = 1
        call wxMenuItem_Check(item%ptr, val)
    end subroutine wx_menuitem_check

    !---------------------------------------------------------------------------
    ! Check if item is enabled
    !---------------------------------------------------------------------------
    function wx_menuitem_is_enabled(item) result(enabled)
        type(wxMenuItem_t), intent(in) :: item
        logical :: enabled

        enabled = (wxMenuItem_IsEnabled(item%ptr) /= 0)
    end function wx_menuitem_is_enabled

    !---------------------------------------------------------------------------
    ! Enable or disable item
    !---------------------------------------------------------------------------
    subroutine wx_menuitem_enable(item, enable)
        type(wxMenuItem_t), intent(in) :: item
        logical, intent(in) :: enable

        integer(c_int) :: val
        val = 0
        if (enable) val = 1
        call wxMenuItem_Enable(item%ptr, val)
    end subroutine wx_menuitem_enable

end module wx_menus
