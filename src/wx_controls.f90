! wx_controls.f90 - Fortran wrappers for basic wxWidgets controls
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides high-level Fortran interfaces to:
!   - wxButton     (push button)
!   - wxTextCtrl   (text input/editor)
!   - wxStaticText (label)
!   - wxPanel      (container window)
!
! Usage:
!   use wx_controls
!   use wxffi_constants
!   type(wxButton_t) :: btn
!   btn = wx_button_create("Click Me", parent=panel)

module wx_controls
    use, intrinsic :: iso_c_binding
    use wxffi_types
    use wxffi_bindings
    use wxffi_constants
    use wx_string
    implicit none
    private

    ! wxButton
    public :: wx_button_create, wx_button_set_default

    ! wxTextCtrl
    public :: wx_text_ctrl_create
    public :: wx_text_ctrl_get_value, wx_text_ctrl_set_value
    public :: wx_text_ctrl_change_value
    public :: wx_text_ctrl_clear
    public :: wx_text_ctrl_write_text, wx_text_ctrl_append_text
    public :: wx_text_ctrl_is_modified, wx_text_ctrl_is_editable
    public :: wx_text_ctrl_get_number_of_lines

    ! wxStaticText
    public :: wx_static_text_create

    ! wxPanel
    public :: wx_panel_create

    ! wxCheckBox
    public :: wx_checkbox_create
    public :: wx_checkbox_set_value, wx_checkbox_get_value

    ! wxRadioButton
    public :: wx_radiobutton_create
    public :: wx_radiobutton_set_value, wx_radiobutton_get_value

    ! wxChoice
    public :: wx_choice_create, wx_choice_append, wx_choice_delete
    public :: wx_choice_clear, wx_choice_get_count
    public :: wx_choice_get_selection, wx_choice_set_selection
    public :: wx_choice_find_string, wx_choice_get_string, wx_choice_set_string

    ! wxListBox
    public :: wx_listbox_create, wx_listbox_append, wx_listbox_delete
    public :: wx_listbox_clear, wx_listbox_get_count
    public :: wx_listbox_get_selection, wx_listbox_set_selection
    public :: wx_listbox_find_string, wx_listbox_get_string, wx_listbox_set_string
    public :: wx_listbox_is_selected

    ! wxComboBox
    public :: wx_combobox_create, wx_combobox_append, wx_combobox_delete
    public :: wx_combobox_clear, wx_combobox_get_count
    public :: wx_combobox_get_selection, wx_combobox_set_selection
    public :: wx_combobox_find_string, wx_combobox_get_string, wx_combobox_set_string
    public :: wx_combobox_get_value, wx_combobox_set_value

contains

    !===========================================================================
    ! wxButton
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a push button
    !
    ! Parameters:
    !   label  - Button text (required)
    !   parent - Parent window (required)
    !   id     - Window ID (optional, default: wxID_ANY)
    !   x, y   - Position (optional, default: system default)
    !   width, height - Size (optional, default: system default)
    !   style  - Button style (optional, default: 0)
    !
    ! Returns: wxButton_t with valid pointer on success
    !---------------------------------------------------------------------------
    function wx_button_create(label, parent, id, x, y, width, height, style) &
        result(button)
        character(len=*), intent(in) :: label
        class(wxWindow_t), intent(in) :: parent
        integer, intent(in), optional :: id
        integer, intent(in), optional :: x, y
        integer, intent(in), optional :: width, height
        integer, intent(in), optional :: style
        type(wxButton_t) :: button

        type(c_ptr) :: label_ptr
        integer(c_int) :: c_id, c_x, c_y, c_w, c_h, c_style

        ! Set defaults
        c_id = wxID_ANY()
        c_x = -1
        c_y = -1
        c_w = -1
        c_h = -1
        c_style = 0

        ! Override with optional parameters
        if (present(id)) c_id = int(id, c_int)
        if (present(x)) c_x = int(x, c_int)
        if (present(y)) c_y = int(y, c_int)
        if (present(width)) c_w = int(width, c_int)
        if (present(height)) c_h = int(height, c_int)
        if (present(style)) c_style = int(style, c_int)

        ! Convert label to wxString*
        label_ptr = to_wxstring(label)

        ! Create the button
        button%ptr = wxButton_Create(parent%ptr, c_id, label_ptr, &
            c_x, c_y, c_w, c_h, c_style)

        ! Clean up the wxString*
        call wxString_Delete(label_ptr)
    end function wx_button_create

    !---------------------------------------------------------------------------
    ! Set button as the default button in its parent
    !---------------------------------------------------------------------------
    subroutine wx_button_set_default(button)
        type(wxButton_t), intent(in) :: button

        call wxButton_SetDefault(button%ptr)
    end subroutine wx_button_set_default

    !===========================================================================
    ! wxTextCtrl
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a text control
    !
    ! Parameters:
    !   parent - Parent window (required)
    !   value  - Initial text (optional, default: empty)
    !   id     - Window ID (optional, default: wxID_ANY)
    !   x, y   - Position (optional, default: system default)
    !   width, height - Size (optional, default: system default)
    !   style  - TextCtrl style (optional, default: 0)
    !            Common styles: wxTE_MULTILINE, wxTE_READONLY, wxTE_PASSWORD
    !
    ! Returns: wxTextCtrl_t with valid pointer on success
    !---------------------------------------------------------------------------
    function wx_text_ctrl_create(parent, value, id, x, y, width, height, &
        style) result(ctrl)
        class(wxWindow_t), intent(in) :: parent
        character(len=*), intent(in), optional :: value
        integer, intent(in), optional :: id
        integer, intent(in), optional :: x, y
        integer, intent(in), optional :: width, height
        integer, intent(in), optional :: style
        type(wxTextCtrl_t) :: ctrl

        type(c_ptr) :: value_ptr
        integer(c_int) :: c_id, c_x, c_y, c_w, c_h
        integer(c_long) :: c_style

        ! Set defaults
        c_id = wxID_ANY()
        c_x = -1
        c_y = -1
        c_w = -1
        c_h = -1
        c_style = 0_c_long

        ! Override with optional parameters
        if (present(id)) c_id = int(id, c_int)
        if (present(x)) c_x = int(x, c_int)
        if (present(y)) c_y = int(y, c_int)
        if (present(width)) c_w = int(width, c_int)
        if (present(height)) c_h = int(height, c_int)
        if (present(style)) c_style = int(style, c_long)

        ! Convert initial value to wxString*
        if (present(value)) then
            value_ptr = to_wxstring(value)
        else
            value_ptr = to_wxstring("")
        end if

        ! Create the text control
        ctrl%ptr = wxTextCtrl_Create(parent%ptr, c_id, value_ptr, &
            c_x, c_y, c_w, c_h, c_style)

        ! Clean up the wxString*
        call wxString_Delete(value_ptr)
    end function wx_text_ctrl_create

    !---------------------------------------------------------------------------
    ! Get the text content of a text control
    !
    ! Returns: allocatable character string with the text content
    !---------------------------------------------------------------------------
    function wx_text_ctrl_get_value(ctrl) result(value)
        type(wxTextCtrl_t), intent(in) :: ctrl
        character(len=:), allocatable :: value

        type(c_ptr) :: ws_ptr

        ws_ptr = wxTextCtrl_GetValue(ctrl%ptr)
        value = from_wxstring(ws_ptr)
        call wxString_Delete(ws_ptr)
    end function wx_text_ctrl_get_value

    !---------------------------------------------------------------------------
    ! Set the text content (triggers change event)
    !---------------------------------------------------------------------------
    subroutine wx_text_ctrl_set_value(ctrl, value)
        type(wxTextCtrl_t), intent(in) :: ctrl
        character(len=*), intent(in) :: value

        type(c_ptr) :: value_ptr

        value_ptr = to_wxstring(value)
        call wxTextCtrl_SetValue(ctrl%ptr, value_ptr)
        call wxString_Delete(value_ptr)
    end subroutine wx_text_ctrl_set_value

    !---------------------------------------------------------------------------
    ! Change the text content (does NOT trigger change event)
    !---------------------------------------------------------------------------
    subroutine wx_text_ctrl_change_value(ctrl, value)
        type(wxTextCtrl_t), intent(in) :: ctrl
        character(len=*), intent(in) :: value

        type(c_ptr) :: value_ptr

        value_ptr = to_wxstring(value)
        call wxTextCtrl_ChangeValue(ctrl%ptr, value_ptr)
        call wxString_Delete(value_ptr)
    end subroutine wx_text_ctrl_change_value

    !---------------------------------------------------------------------------
    ! Clear the text content
    !---------------------------------------------------------------------------
    subroutine wx_text_ctrl_clear(ctrl)
        type(wxTextCtrl_t), intent(in) :: ctrl

        call wxTextCtrl_Clear(ctrl%ptr)
    end subroutine wx_text_ctrl_clear

    !---------------------------------------------------------------------------
    ! Write text at the current insertion point
    !---------------------------------------------------------------------------
    subroutine wx_text_ctrl_write_text(ctrl, text)
        type(wxTextCtrl_t), intent(in) :: ctrl
        character(len=*), intent(in) :: text

        type(c_ptr) :: text_ptr

        text_ptr = to_wxstring(text)
        call wxTextCtrl_WriteText(ctrl%ptr, text_ptr)
        call wxString_Delete(text_ptr)
    end subroutine wx_text_ctrl_write_text

    !---------------------------------------------------------------------------
    ! Append text to the end of the text control
    !---------------------------------------------------------------------------
    subroutine wx_text_ctrl_append_text(ctrl, text)
        type(wxTextCtrl_t), intent(in) :: ctrl
        character(len=*), intent(in) :: text

        type(c_ptr) :: text_ptr

        text_ptr = to_wxstring(text)
        call wxTextCtrl_AppendText(ctrl%ptr, text_ptr)
        call wxString_Delete(text_ptr)
    end subroutine wx_text_ctrl_append_text

    !---------------------------------------------------------------------------
    ! Check if text has been modified since last save point
    !---------------------------------------------------------------------------
    function wx_text_ctrl_is_modified(ctrl) result(modified)
        type(wxTextCtrl_t), intent(in) :: ctrl
        logical :: modified

        modified = (wxTextCtrl_IsModified(ctrl%ptr) /= 0)
    end function wx_text_ctrl_is_modified

    !---------------------------------------------------------------------------
    ! Check if text control is editable
    !---------------------------------------------------------------------------
    function wx_text_ctrl_is_editable(ctrl) result(editable)
        type(wxTextCtrl_t), intent(in) :: ctrl
        logical :: editable

        editable = (wxTextCtrl_IsEditable(ctrl%ptr) /= 0)
    end function wx_text_ctrl_is_editable

    !---------------------------------------------------------------------------
    ! Get the number of lines in the text control
    !---------------------------------------------------------------------------
    function wx_text_ctrl_get_number_of_lines(ctrl) result(n)
        type(wxTextCtrl_t), intent(in) :: ctrl
        integer :: n

        n = int(wxTextCtrl_GetNumberOfLines(ctrl%ptr))
    end function wx_text_ctrl_get_number_of_lines

    !===========================================================================
    ! wxStaticText
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a static text label
    !
    ! Parameters:
    !   label  - Label text (required)
    !   parent - Parent window (required)
    !   id     - Window ID (optional, default: wxID_ANY)
    !   x, y   - Position (optional, default: system default)
    !   width, height - Size (optional, default: system default)
    !   style  - StaticText style (optional, default: 0)
    !
    ! Returns: wxStaticText_t with valid pointer on success
    !---------------------------------------------------------------------------
    function wx_static_text_create(label, parent, id, x, y, width, height, &
        style) result(text)
        character(len=*), intent(in) :: label
        class(wxWindow_t), intent(in) :: parent
        integer, intent(in), optional :: id
        integer, intent(in), optional :: x, y
        integer, intent(in), optional :: width, height
        integer, intent(in), optional :: style
        type(wxStaticText_t) :: text

        type(c_ptr) :: label_ptr
        integer(c_int) :: c_id, c_x, c_y, c_w, c_h, c_style

        ! Set defaults
        c_id = wxID_ANY()
        c_x = -1
        c_y = -1
        c_w = -1
        c_h = -1
        c_style = 0

        ! Override with optional parameters
        if (present(id)) c_id = int(id, c_int)
        if (present(x)) c_x = int(x, c_int)
        if (present(y)) c_y = int(y, c_int)
        if (present(width)) c_w = int(width, c_int)
        if (present(height)) c_h = int(height, c_int)
        if (present(style)) c_style = int(style, c_int)

        ! Convert label to wxString*
        label_ptr = to_wxstring(label)

        ! Create the static text
        text%ptr = wxStaticText_Create(parent%ptr, c_id, label_ptr, &
            c_x, c_y, c_w, c_h, c_style)

        ! Clean up the wxString*
        call wxString_Delete(label_ptr)
    end function wx_static_text_create

    !===========================================================================
    ! wxPanel
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a panel (container window for controls)
    !
    ! Parameters:
    !   parent - Parent window (required)
    !   id     - Window ID (optional, default: wxID_ANY)
    !   x, y   - Position (optional, default: system default)
    !   width, height - Size (optional, default: system default)
    !   style  - Panel style (optional, default: wxTAB_TRAVERSAL)
    !
    ! Returns: wxPanel_t with valid pointer on success
    !---------------------------------------------------------------------------
    function wx_panel_create(parent, id, x, y, width, height, style) &
        result(panel)
        class(wxWindow_t), intent(in) :: parent
        integer, intent(in), optional :: id
        integer, intent(in), optional :: x, y
        integer, intent(in), optional :: width, height
        integer, intent(in), optional :: style
        type(wxPanel_t) :: panel

        integer(c_int) :: c_id, c_x, c_y, c_w, c_h, c_style

        ! Set defaults
        c_id = wxID_ANY()
        c_x = -1
        c_y = -1
        c_w = -1
        c_h = -1
        c_style = wxTAB_TRAVERSAL()

        ! Override with optional parameters
        if (present(id)) c_id = int(id, c_int)
        if (present(x)) c_x = int(x, c_int)
        if (present(y)) c_y = int(y, c_int)
        if (present(width)) c_w = int(width, c_int)
        if (present(height)) c_h = int(height, c_int)
        if (present(style)) c_style = int(style, c_int)

        ! Create the panel
        panel%ptr = wxPanel_Create(parent%ptr, c_id, c_x, c_y, c_w, c_h, &
            c_style)
    end function wx_panel_create

    !===========================================================================
    ! wxCheckBox
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a checkbox
    !---------------------------------------------------------------------------
    function wx_checkbox_create(label, parent, id, x, y, width, height, &
        style) result(cb)
        character(len=*), intent(in) :: label
        class(wxWindow_t), intent(in) :: parent
        integer, intent(in), optional :: id
        integer, intent(in), optional :: x, y
        integer, intent(in), optional :: width, height
        integer, intent(in), optional :: style
        type(wxCheckBox_t) :: cb

        type(c_ptr) :: label_ptr
        integer(c_int) :: c_id, c_x, c_y, c_w, c_h, c_style

        c_id = wxID_ANY()
        c_x = -1; c_y = -1; c_w = -1; c_h = -1
        c_style = 0

        if (present(id)) c_id = int(id, c_int)
        if (present(x)) c_x = int(x, c_int)
        if (present(y)) c_y = int(y, c_int)
        if (present(width)) c_w = int(width, c_int)
        if (present(height)) c_h = int(height, c_int)
        if (present(style)) c_style = int(style, c_int)

        label_ptr = to_wxstring(label)
        cb%ptr = wxCheckBox_Create(parent%ptr, c_id, label_ptr, &
            c_x, c_y, c_w, c_h, c_style)
        call wxString_Delete(label_ptr)
    end function wx_checkbox_create

    !---------------------------------------------------------------------------
    ! Set checkbox checked state
    !---------------------------------------------------------------------------
    subroutine wx_checkbox_set_value(cb, checked)
        type(wxCheckBox_t), intent(in) :: cb
        logical, intent(in) :: checked

        integer(c_int) :: val
        val = 0
        if (checked) val = 1
        call wxCheckBox_SetValue(cb%ptr, val)
    end subroutine wx_checkbox_set_value

    !---------------------------------------------------------------------------
    ! Get checkbox checked state
    !---------------------------------------------------------------------------
    function wx_checkbox_get_value(cb) result(checked)
        type(wxCheckBox_t), intent(in) :: cb
        logical :: checked

        checked = (wxCheckBox_GetValue(cb%ptr) /= 0)
    end function wx_checkbox_get_value

    !===========================================================================
    ! wxRadioButton
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a radio button
    !---------------------------------------------------------------------------
    function wx_radiobutton_create(label, parent, id, x, y, width, height, &
        style) result(rb)
        character(len=*), intent(in) :: label
        class(wxWindow_t), intent(in) :: parent
        integer, intent(in), optional :: id
        integer, intent(in), optional :: x, y
        integer, intent(in), optional :: width, height
        integer, intent(in), optional :: style
        type(wxRadioButton_t) :: rb

        type(c_ptr) :: label_ptr
        integer(c_int) :: c_id, c_x, c_y, c_w, c_h, c_style

        c_id = wxID_ANY()
        c_x = -1; c_y = -1; c_w = -1; c_h = -1
        c_style = 0

        if (present(id)) c_id = int(id, c_int)
        if (present(x)) c_x = int(x, c_int)
        if (present(y)) c_y = int(y, c_int)
        if (present(width)) c_w = int(width, c_int)
        if (present(height)) c_h = int(height, c_int)
        if (present(style)) c_style = int(style, c_int)

        label_ptr = to_wxstring(label)
        rb%ptr = wxRadioButton_Create(parent%ptr, c_id, label_ptr, &
            c_x, c_y, c_w, c_h, c_style)
        call wxString_Delete(label_ptr)
    end function wx_radiobutton_create

    !---------------------------------------------------------------------------
    ! Set radio button selected state
    !---------------------------------------------------------------------------
    subroutine wx_radiobutton_set_value(rb, selected)
        type(wxRadioButton_t), intent(in) :: rb
        logical, intent(in) :: selected

        integer(c_int) :: val
        val = 0
        if (selected) val = 1
        call wxRadioButton_SetValue(rb%ptr, val)
    end subroutine wx_radiobutton_set_value

    !---------------------------------------------------------------------------
    ! Get radio button selected state
    !---------------------------------------------------------------------------
    function wx_radiobutton_get_value(rb) result(selected)
        type(wxRadioButton_t), intent(in) :: rb
        logical :: selected

        selected = (wxRadioButton_GetValue(rb%ptr) /= 0)
    end function wx_radiobutton_get_value

    !===========================================================================
    ! wxChoice
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a choice (dropdown) control
    ! Creates empty, use wx_choice_append to add items
    !---------------------------------------------------------------------------
    function wx_choice_create(parent, id, x, y, width, height, style) &
        result(choice)
        class(wxWindow_t), intent(in) :: parent
        integer, intent(in), optional :: id
        integer, intent(in), optional :: x, y
        integer, intent(in), optional :: width, height
        integer, intent(in), optional :: style
        type(wxChoice_t) :: choice

        integer(c_int) :: c_id, c_x, c_y, c_w, c_h, c_style

        c_id = wxID_ANY()
        c_x = -1; c_y = -1; c_w = -1; c_h = -1
        c_style = 0

        if (present(id)) c_id = int(id, c_int)
        if (present(x)) c_x = int(x, c_int)
        if (present(y)) c_y = int(y, c_int)
        if (present(width)) c_w = int(width, c_int)
        if (present(height)) c_h = int(height, c_int)
        if (present(style)) c_style = int(style, c_int)

        choice%ptr = wxChoice_Create(parent%ptr, c_id, c_x, c_y, c_w, c_h, &
            0, c_null_ptr, c_style)
    end function wx_choice_create

    !---------------------------------------------------------------------------
    ! Append an item to the choice control
    !---------------------------------------------------------------------------
    subroutine wx_choice_append(choice, item)
        type(wxChoice_t), intent(in) :: choice
        character(len=*), intent(in) :: item

        type(c_ptr) :: item_ptr

        item_ptr = to_wxstring(item)
        call wxChoice_Append(choice%ptr, item_ptr)
        call wxString_Delete(item_ptr)
    end subroutine wx_choice_append

    !---------------------------------------------------------------------------
    ! Delete an item by index
    !---------------------------------------------------------------------------
    subroutine wx_choice_delete(choice, index)
        type(wxChoice_t), intent(in) :: choice
        integer, intent(in) :: index

        call wxChoice_Delete(choice%ptr, int(index, c_int))
    end subroutine wx_choice_delete

    !---------------------------------------------------------------------------
    ! Remove all items
    !---------------------------------------------------------------------------
    subroutine wx_choice_clear(choice)
        type(wxChoice_t), intent(in) :: choice

        call wxChoice_Clear(choice%ptr)
    end subroutine wx_choice_clear

    !---------------------------------------------------------------------------
    ! Get the number of items
    !---------------------------------------------------------------------------
    function wx_choice_get_count(choice) result(n)
        type(wxChoice_t), intent(in) :: choice
        integer :: n

        n = int(wxChoice_GetCount(choice%ptr))
    end function wx_choice_get_count

    !---------------------------------------------------------------------------
    ! Get the currently selected index (-1 if none)
    !---------------------------------------------------------------------------
    function wx_choice_get_selection(choice) result(index)
        type(wxChoice_t), intent(in) :: choice
        integer :: index

        index = int(wxChoice_GetSelection(choice%ptr))
    end function wx_choice_get_selection

    !---------------------------------------------------------------------------
    ! Set the selected index
    !---------------------------------------------------------------------------
    subroutine wx_choice_set_selection(choice, index)
        type(wxChoice_t), intent(in) :: choice
        integer, intent(in) :: index

        call wxChoice_SetSelection(choice%ptr, int(index, c_int))
    end subroutine wx_choice_set_selection

    !---------------------------------------------------------------------------
    ! Find an item by string, returns index or -1
    !---------------------------------------------------------------------------
    function wx_choice_find_string(choice, str) result(index)
        type(wxChoice_t), intent(in) :: choice
        character(len=*), intent(in) :: str
        integer :: index

        type(c_ptr) :: str_ptr

        str_ptr = to_wxstring(str)
        index = int(wxChoice_FindString(choice%ptr, str_ptr))
        call wxString_Delete(str_ptr)
    end function wx_choice_find_string

    !---------------------------------------------------------------------------
    ! Get item string by index
    !---------------------------------------------------------------------------
    function wx_choice_get_string(choice, index) result(str)
        type(wxChoice_t), intent(in) :: choice
        integer, intent(in) :: index
        character(len=:), allocatable :: str

        type(c_ptr) :: ws_ptr

        ws_ptr = wxChoice_GetString(choice%ptr, int(index, c_int))
        str = from_wxstring(ws_ptr)
        call wxString_Delete(ws_ptr)
    end function wx_choice_get_string

    !---------------------------------------------------------------------------
    ! Set item string by index
    !---------------------------------------------------------------------------
    subroutine wx_choice_set_string(choice, index, str)
        type(wxChoice_t), intent(in) :: choice
        integer, intent(in) :: index
        character(len=*), intent(in) :: str

        type(c_ptr) :: str_ptr

        str_ptr = to_wxstring(str)
        call wxChoice_SetString(choice%ptr, int(index, c_int), str_ptr)
        call wxString_Delete(str_ptr)
    end subroutine wx_choice_set_string

    !===========================================================================
    ! wxListBox
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a list box control
    ! Creates empty, use wx_listbox_append to add items
    !---------------------------------------------------------------------------
    function wx_listbox_create(parent, id, x, y, width, height, style) &
        result(lb)
        class(wxWindow_t), intent(in) :: parent
        integer, intent(in), optional :: id
        integer, intent(in), optional :: x, y
        integer, intent(in), optional :: width, height
        integer, intent(in), optional :: style
        type(wxListBox_t) :: lb

        integer(c_int) :: c_id, c_x, c_y, c_w, c_h, c_style

        c_id = wxID_ANY()
        c_x = -1; c_y = -1; c_w = -1; c_h = -1
        c_style = 0

        if (present(id)) c_id = int(id, c_int)
        if (present(x)) c_x = int(x, c_int)
        if (present(y)) c_y = int(y, c_int)
        if (present(width)) c_w = int(width, c_int)
        if (present(height)) c_h = int(height, c_int)
        if (present(style)) c_style = int(style, c_int)

        lb%ptr = wxListBox_Create(parent%ptr, c_id, c_x, c_y, c_w, c_h, &
            0, c_null_ptr, c_style)
    end function wx_listbox_create

    !---------------------------------------------------------------------------
    ! Append an item to the list box
    !---------------------------------------------------------------------------
    subroutine wx_listbox_append(lb, item)
        type(wxListBox_t), intent(in) :: lb
        character(len=*), intent(in) :: item

        type(c_ptr) :: item_ptr

        item_ptr = to_wxstring(item)
        call wxListBox_Append(lb%ptr, item_ptr)
        call wxString_Delete(item_ptr)
    end subroutine wx_listbox_append

    !---------------------------------------------------------------------------
    ! Delete an item by index
    !---------------------------------------------------------------------------
    subroutine wx_listbox_delete(lb, index)
        type(wxListBox_t), intent(in) :: lb
        integer, intent(in) :: index

        call wxListBox_Delete(lb%ptr, int(index, c_int))
    end subroutine wx_listbox_delete

    !---------------------------------------------------------------------------
    ! Remove all items
    !---------------------------------------------------------------------------
    subroutine wx_listbox_clear(lb)
        type(wxListBox_t), intent(in) :: lb

        call wxListBox_Clear(lb%ptr)
    end subroutine wx_listbox_clear

    !---------------------------------------------------------------------------
    ! Get the number of items
    !---------------------------------------------------------------------------
    function wx_listbox_get_count(lb) result(n)
        type(wxListBox_t), intent(in) :: lb
        integer :: n

        n = int(wxListBox_GetCount(lb%ptr))
    end function wx_listbox_get_count

    !---------------------------------------------------------------------------
    ! Get the currently selected index (-1 if none)
    !---------------------------------------------------------------------------
    function wx_listbox_get_selection(lb) result(index)
        type(wxListBox_t), intent(in) :: lb
        integer :: index

        index = int(wxListBox_GetSelection(lb%ptr))
    end function wx_listbox_get_selection

    !---------------------------------------------------------------------------
    ! Set selection (sel=.true. to select, .false. to deselect)
    !---------------------------------------------------------------------------
    subroutine wx_listbox_set_selection(lb, index, sel)
        type(wxListBox_t), intent(in) :: lb
        integer, intent(in) :: index
        logical, intent(in), optional :: sel

        integer(c_int) :: c_sel
        c_sel = 1
        if (present(sel)) then
            if (.not. sel) c_sel = 0
        end if
        call wxListBox_SetSelection(lb%ptr, int(index, c_int), c_sel)
    end subroutine wx_listbox_set_selection

    !---------------------------------------------------------------------------
    ! Check if an item is selected
    !---------------------------------------------------------------------------
    function wx_listbox_is_selected(lb, index) result(selected)
        type(wxListBox_t), intent(in) :: lb
        integer, intent(in) :: index
        logical :: selected

        selected = (wxListBox_IsSelected(lb%ptr, int(index, c_int)) /= 0)
    end function wx_listbox_is_selected

    !---------------------------------------------------------------------------
    ! Find an item by string, returns index or -1
    !---------------------------------------------------------------------------
    function wx_listbox_find_string(lb, str) result(index)
        type(wxListBox_t), intent(in) :: lb
        character(len=*), intent(in) :: str
        integer :: index

        type(c_ptr) :: str_ptr

        str_ptr = to_wxstring(str)
        index = int(wxListBox_FindString(lb%ptr, str_ptr))
        call wxString_Delete(str_ptr)
    end function wx_listbox_find_string

    !---------------------------------------------------------------------------
    ! Get item string by index
    !---------------------------------------------------------------------------
    function wx_listbox_get_string(lb, index) result(str)
        type(wxListBox_t), intent(in) :: lb
        integer, intent(in) :: index
        character(len=:), allocatable :: str

        type(c_ptr) :: ws_ptr

        ws_ptr = wxListBox_GetString(lb%ptr, int(index, c_int))
        str = from_wxstring(ws_ptr)
        call wxString_Delete(ws_ptr)
    end function wx_listbox_get_string

    !---------------------------------------------------------------------------
    ! Set item string by index
    !---------------------------------------------------------------------------
    subroutine wx_listbox_set_string(lb, index, str)
        type(wxListBox_t), intent(in) :: lb
        integer, intent(in) :: index
        character(len=*), intent(in) :: str

        type(c_ptr) :: str_ptr

        str_ptr = to_wxstring(str)
        call wxListBox_SetString(lb%ptr, int(index, c_int), str_ptr)
        call wxString_Delete(str_ptr)
    end subroutine wx_listbox_set_string

    !===========================================================================
    ! wxComboBox
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Create a combo box control
    ! Creates empty, use wx_combobox_append to add items
    !---------------------------------------------------------------------------
    function wx_combobox_create(parent, value, id, x, y, width, height, &
        style) result(combo)
        class(wxWindow_t), intent(in) :: parent
        character(len=*), intent(in), optional :: value
        integer, intent(in), optional :: id
        integer, intent(in), optional :: x, y
        integer, intent(in), optional :: width, height
        integer, intent(in), optional :: style
        type(wxComboBox_t) :: combo

        type(c_ptr) :: value_ptr
        integer(c_int) :: c_id, c_x, c_y, c_w, c_h, c_style

        c_id = wxID_ANY()
        c_x = -1; c_y = -1; c_w = -1; c_h = -1
        c_style = 0

        if (present(id)) c_id = int(id, c_int)
        if (present(x)) c_x = int(x, c_int)
        if (present(y)) c_y = int(y, c_int)
        if (present(width)) c_w = int(width, c_int)
        if (present(height)) c_h = int(height, c_int)
        if (present(style)) c_style = int(style, c_int)

        if (present(value)) then
            value_ptr = to_wxstring(value)
        else
            value_ptr = to_wxstring("")
        end if

        combo%ptr = wxComboBox_Create(parent%ptr, c_id, value_ptr, &
            c_x, c_y, c_w, c_h, 0, c_null_ptr, c_style)
        call wxString_Delete(value_ptr)
    end function wx_combobox_create

    !---------------------------------------------------------------------------
    ! Append an item to the combo box
    !---------------------------------------------------------------------------
    subroutine wx_combobox_append(combo, item)
        type(wxComboBox_t), intent(in) :: combo
        character(len=*), intent(in) :: item

        type(c_ptr) :: item_ptr

        item_ptr = to_wxstring(item)
        call wxComboBox_Append(combo%ptr, item_ptr)
        call wxString_Delete(item_ptr)
    end subroutine wx_combobox_append

    !---------------------------------------------------------------------------
    ! Delete an item by index
    !---------------------------------------------------------------------------
    subroutine wx_combobox_delete(combo, index)
        type(wxComboBox_t), intent(in) :: combo
        integer, intent(in) :: index

        call wxComboBox_Delete(combo%ptr, int(index, c_int))
    end subroutine wx_combobox_delete

    !---------------------------------------------------------------------------
    ! Remove all items
    !---------------------------------------------------------------------------
    subroutine wx_combobox_clear(combo)
        type(wxComboBox_t), intent(in) :: combo

        call wxComboBox_Clear(combo%ptr)
    end subroutine wx_combobox_clear

    !---------------------------------------------------------------------------
    ! Get the number of items
    !---------------------------------------------------------------------------
    function wx_combobox_get_count(combo) result(n)
        type(wxComboBox_t), intent(in) :: combo
        integer :: n

        n = int(wxComboBox_GetCount(combo%ptr))
    end function wx_combobox_get_count

    !---------------------------------------------------------------------------
    ! Get the currently selected index (-1 if none)
    !---------------------------------------------------------------------------
    function wx_combobox_get_selection(combo) result(index)
        type(wxComboBox_t), intent(in) :: combo
        integer :: index

        index = int(wxComboBox_GetSelection(combo%ptr))
    end function wx_combobox_get_selection

    !---------------------------------------------------------------------------
    ! Set the selected index
    !---------------------------------------------------------------------------
    subroutine wx_combobox_set_selection(combo, index)
        type(wxComboBox_t), intent(in) :: combo
        integer, intent(in) :: index

        call wxComboBox_SetSelection(combo%ptr, int(index, c_int))
    end subroutine wx_combobox_set_selection

    !---------------------------------------------------------------------------
    ! Find an item by string, returns index or -1
    !---------------------------------------------------------------------------
    function wx_combobox_find_string(combo, str) result(index)
        type(wxComboBox_t), intent(in) :: combo
        character(len=*), intent(in) :: str
        integer :: index

        type(c_ptr) :: str_ptr

        str_ptr = to_wxstring(str)
        index = int(wxComboBox_FindString(combo%ptr, str_ptr))
        call wxString_Delete(str_ptr)
    end function wx_combobox_find_string

    !---------------------------------------------------------------------------
    ! Get item string by index
    !---------------------------------------------------------------------------
    function wx_combobox_get_string(combo, index) result(str)
        type(wxComboBox_t), intent(in) :: combo
        integer, intent(in) :: index
        character(len=:), allocatable :: str

        type(c_ptr) :: ws_ptr

        ws_ptr = wxComboBox_GetString(combo%ptr, int(index, c_int))
        str = from_wxstring(ws_ptr)
        call wxString_Delete(ws_ptr)
    end function wx_combobox_get_string

    !---------------------------------------------------------------------------
    ! Set item string by index
    !---------------------------------------------------------------------------
    subroutine wx_combobox_set_string(combo, index, str)
        type(wxComboBox_t), intent(in) :: combo
        integer, intent(in) :: index
        character(len=*), intent(in) :: str

        type(c_ptr) :: str_ptr

        str_ptr = to_wxstring(str)
        call wxComboBox_SetString(combo%ptr, int(index, c_int), str_ptr)
        call wxString_Delete(str_ptr)
    end subroutine wx_combobox_set_string

    !---------------------------------------------------------------------------
    ! Get the text content of the combo box edit field
    !---------------------------------------------------------------------------
    function wx_combobox_get_value(combo) result(value)
        type(wxComboBox_t), intent(in) :: combo
        character(len=:), allocatable :: value

        type(c_ptr) :: ws_ptr

        ws_ptr = wxComboBox_GetValue(combo%ptr)
        value = from_wxstring(ws_ptr)
        call wxString_Delete(ws_ptr)
    end function wx_combobox_get_value

    !---------------------------------------------------------------------------
    ! Set the text content of the combo box edit field
    !---------------------------------------------------------------------------
    subroutine wx_combobox_set_value(combo, value)
        type(wxComboBox_t), intent(in) :: combo
        character(len=*), intent(in) :: value

        type(c_ptr) :: value_ptr

        value_ptr = to_wxstring(value)
        call wxComboBox_SetValue(combo%ptr, value_ptr)
        call wxString_Delete(value_ptr)
    end subroutine wx_combobox_set_value

end module wx_controls
