! kwx_bindings.f90 - Raw C bindings for wxFFI functions
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides ISO_C_BINDING interfaces to the raw C functions
! exported by kwxFFI and kwxApp. Higher-level Fortran wrappers should
! use these bindings rather than calling the C functions directly.
!
! Naming convention from wxFFI:
!   - wx<ClassName>_<MethodName> for wxWidgets methods
!   - kwxApp_<FunctionName> for application lifecycle functions
!   - expwx<ConstantName> for constant value functions

module kwx_bindings
    use, intrinsic :: iso_c_binding
    implicit none
    private

    !---------------------------------------------------------------------------
    ! kwxApp functions - Application lifecycle (from kwxApp.cpp)
    !---------------------------------------------------------------------------
    public :: kwxApp_Initialize, kwxApp_MainLoop, kwxApp_ExitMainLoop
    public :: kwxApp_Shutdown, kwxApp_IsTerminating
    public :: kwxApp_GetAppName, kwxApp_SetAppName
    public :: kwxApp_GetVendorName, kwxApp_SetVendorName
    public :: kwxApp_GetTopWindow, kwxApp_SetTopWindow
    public :: kwxApp_SetExitOnFrameDelete, kwxApp_GetExitOnFrameDelete
    public :: kwxApp_GetDisplaySize, kwxApp_GetMousePosition
    public :: kwxApp_Pending, kwxApp_Dispatch, kwxApp_Yield, kwxApp_SafeYield
    public :: kwxApp_InitAllImageHandlers, kwxApp_Bell
    public :: kwxApp_FreeString
    public :: kwxApp_GetOsVersion
    public :: kwxApp_GetOsDescription, kwxApp_GetUserId, kwxApp_GetUserName
    public :: kwxApp_EnableTooltips, kwxApp_SetTooltipDelay
    public :: kwxApp_Sleep, kwxApp_MilliSleep
    public :: kwxApp_FindWindowById, kwxApp_FindWindowByLabel, kwxApp_FindWindowByName
    public :: kwxApp_SetIdleCallback, kwxApp_GetIdleInterval

    !---------------------------------------------------------------------------
    ! wxFrame functions
    !---------------------------------------------------------------------------
    public :: wxFrame_Create
    public :: wxFrame_CreateStatusBar, wxFrame_GetStatusBar, wxFrame_SetStatusBar
    public :: wxFrame_SetStatusText, wxFrame_SetStatusWidths
    public :: wxFrame_CreateToolBar, wxFrame_GetToolBar, wxFrame_SetToolBar
    public :: wxFrame_GetMenuBar, wxFrame_SetMenuBar
    public :: wxFrame_Restore, wxFrame_Maximize, wxFrame_Iconize
    public :: wxFrame_IsMaximized, wxFrame_IsIconized
    public :: wxFrame_GetIcon, wxFrame_SetIcon
    public :: wxFrame_GetClientAreaOrigin_left, wxFrame_GetClientAreaOrigin_top
    public :: wxFrame_FindItemInMenuBar, wxFrame_ProcessCommand
    public :: wxFrame_SetStatusBarPane, wxFrame_GetStatusBarPane
    public :: wxFrame_PushStatusText, wxFrame_PopStatusText

    !---------------------------------------------------------------------------
    ! wxTopLevelWindow functions (inherited by wxFrame and wxDialog)
    !---------------------------------------------------------------------------
    public :: wxTopLevelWindow_EnableCloseButton
    public :: wxTopLevelWindow_GetTitle, wxTopLevelWindow_SetTitle
    public :: wxTopLevelWindow_IsActive
    public :: wxTopLevelWindow_Iconize, wxTopLevelWindow_IsIconized
    public :: wxTopLevelWindow_Maximize, wxTopLevelWindow_IsMaximized
    public :: wxTopLevelWindow_Restore
    public :: wxTopLevelWindow_CenterOnScreen
    public :: wxTopLevelWindow_ShowFullScreen, wxTopLevelWindow_IsFullScreen
    public :: wxTopLevelWindow_EnableMaximizeButton, wxTopLevelWindow_EnableMinimizeButton
    public :: wxTopLevelWindow_SetMinSize, wxTopLevelWindow_SetMaxSize
    public :: wxTopLevelWindow_RequestUserAttention

    !---------------------------------------------------------------------------
    ! wxButton functions
    !---------------------------------------------------------------------------
    public :: wxButton_Create, wxButton_SetDefault

    !---------------------------------------------------------------------------
    ! wxTextCtrl functions
    !---------------------------------------------------------------------------
    public :: wxTextCtrl_Create, wxTextCtrl_GetValue
    public :: wxTextCtrl_SetValue, wxTextCtrl_ChangeValue
    public :: wxTextCtrl_Clear, wxTextCtrl_WriteText, wxTextCtrl_AppendText
    public :: wxTextCtrl_IsModified, wxTextCtrl_IsEditable
    public :: wxTextCtrl_GetNumberOfLines
    public :: wxTextEntry_SetHint

    !---------------------------------------------------------------------------
    ! wxStaticText functions
    !---------------------------------------------------------------------------
    public :: wxStaticText_Create

    !---------------------------------------------------------------------------
    ! wxPanel functions
    !---------------------------------------------------------------------------
    public :: wxPanel_Create, wxPanel_SetFocus

    !---------------------------------------------------------------------------
    ! wxBoxSizer functions
    !---------------------------------------------------------------------------
    public :: wxBoxSizer_Create, wxBoxSizer_GetOrientation

    !---------------------------------------------------------------------------
    ! wxSizer functions (base class for all sizers)
    !---------------------------------------------------------------------------
    public :: wxSizer_AddWindow, wxSizer_AddSizer, wxSizer_Add
    public :: wxSizer_AddSpacer, wxSizer_AddStretchSpacer
    public :: wxSizer_Layout, wxSizer_Fit, wxSizer_SetSizeHints
    public :: wxSizer_SetMinSize

    !---------------------------------------------------------------------------
    ! wxWindow functions (base class for all UI elements)
    !---------------------------------------------------------------------------
    public :: wxWindow_Create, wxWindow_Destroy, wxWindow_DestroyChildren
    public :: wxWindow_Close, wxWindow_Show, wxWindow_Hide
    public :: wxWindow_Enable, wxWindow_Disable, wxWindow_IsEnabled, wxWindow_IsShown
    public :: wxWindow_SetSize, wxWindow_GetSize, wxWindow_GetPosition
    public :: wxWindow_Move
    public :: wxWindow_GetClientSize, wxWindow_SetClientSize
    public :: wxWindow_GetBestSize, wxWindow_GetEffectiveMinSize
    public :: wxWindow_GetId, wxWindow_SetId
    public :: wxWindow_GetLabel, wxWindow_SetLabel
    public :: wxWindow_GetName, wxWindow_SetName
    public :: wxWindow_GetParent
    public :: wxWindow_SetFocus, wxWindow_HasFocus
    public :: wxWindow_Refresh, wxWindow_Update
    public :: wxWindow_SetBackgroundColour, wxWindow_GetBackgroundColour
    public :: wxWindow_SetForegroundColour, wxWindow_GetForegroundColour
    public :: wxWindow_SetFont, wxWindow_GetFont
    public :: wxWindow_Center, wxWindow_CenterOnParent
    public :: wxWindow_Fit, wxWindow_FitInside, wxWindow_Layout
    public :: wxWindow_SetSizer, wxWindow_GetSizer
    public :: wxWindow_SetToolTip, wxWindow_GetToolTip
    public :: wxWindow_IsTopLevel
    public :: wxWindow_Freeze, wxWindow_Thaw
    public :: wxWindow_Lower, wxWindow_Raise

    !---------------------------------------------------------------------------
    ! Event connection functions (wxEvtHandler)
    !---------------------------------------------------------------------------
    public :: wxEvtHandler_Connect, wxEvtHandler_Disconnect

    !---------------------------------------------------------------------------
    ! wxClosure functions (from kwxFFI wrapper.cpp)
    !---------------------------------------------------------------------------
    public :: wxClosure_Create, wxClosure_GetData

    !---------------------------------------------------------------------------
    ! wxEvent functions (base event class)
    !---------------------------------------------------------------------------
    public :: wxEvent_GetEventType, wxEvent_GetId, wxEvent_Skip
    public :: wxEvent_GetTimestamp, wxEvent_GetSkipped
    public :: wxEvent_GetEventObject, wxEvent_IsCommandEvent

    !---------------------------------------------------------------------------
    ! wxCommandEvent functions
    !---------------------------------------------------------------------------
    public :: wxCommandEvent_GetString, wxCommandEvent_GetSelection
    public :: wxCommandEvent_GetInt, wxCommandEvent_GetExtraLong
    public :: wxCommandEvent_IsChecked, wxCommandEvent_IsSelection

    !---------------------------------------------------------------------------
    ! wxCheckBox functions
    !---------------------------------------------------------------------------
    public :: wxCheckBox_Create, wxCheckBox_SetValue, wxCheckBox_GetValue

    !---------------------------------------------------------------------------
    ! wxRadioButton functions
    !---------------------------------------------------------------------------
    public :: wxRadioButton_Create
    public :: wxRadioButton_SetValue, wxRadioButton_GetValue

    !---------------------------------------------------------------------------
    ! wxChoice functions
    !---------------------------------------------------------------------------
    public :: wxChoice_Create, wxChoice_Append, wxChoice_Delete, wxChoice_Clear
    public :: wxChoice_GetCount, wxChoice_GetSelection, wxChoice_SetSelection
    public :: wxChoice_FindString, wxChoice_GetString, wxChoice_SetString

    !---------------------------------------------------------------------------
    ! wxListBox functions
    !---------------------------------------------------------------------------
    public :: wxListBox_Create, wxListBox_Clear, wxListBox_Delete
    public :: wxListBox_GetCount, wxListBox_GetString, wxListBox_SetString
    public :: wxListBox_FindString, wxListBox_IsSelected
    public :: wxListBox_SetSelection, wxListBox_GetSelection
    public :: wxListBox_Append

    !---------------------------------------------------------------------------
    ! wxComboBox functions
    !---------------------------------------------------------------------------
    public :: wxComboBox_Create, wxComboBox_GetValue, wxComboBox_SetValue
    public :: wxComboBox_Append, wxComboBox_Delete, wxComboBox_Clear
    public :: wxComboBox_GetCount, wxComboBox_GetSelection, wxComboBox_SetSelection
    public :: wxComboBox_FindString, wxComboBox_GetString, wxComboBox_SetString
    public :: wxComboBox_Copy, wxComboBox_Cut, wxComboBox_Paste

    !---------------------------------------------------------------------------
    ! wxMenu functions
    !---------------------------------------------------------------------------
    public :: wxMenu_Create, wxMenu_DeletePointer
    public :: wxMenu_Append, wxMenu_AppendSeparator, wxMenu_AppendRadioItem
    public :: wxMenu_Enable, wxMenu_Check
    public :: wxMenu_IsEnabled, wxMenu_IsChecked
    public :: wxMenu_GetMenuItemCount
    public :: wxMenu_SetTitle, wxMenu_GetTitle

    !---------------------------------------------------------------------------
    ! wxMenuBar functions
    !---------------------------------------------------------------------------
    public :: wxMenuBar_Create, wxMenuBar_Append
    public :: wxMenuBar_GetMenuCount, wxMenuBar_GetMenu
    public :: wxMenuBar_EnableTop

    !---------------------------------------------------------------------------
    ! wxMenuItem functions
    !---------------------------------------------------------------------------
    public :: wxMenuItem_Create, wxMenuItem_CreateEx, wxMenuItem_Delete
    public :: wxMenuItem_GetId, wxMenuItem_IsSeparator
    public :: wxMenuItem_SetItemLabel, wxMenuItem_GetItemLabel
    public :: wxMenuItem_SetCheckable, wxMenuItem_IsChecked
    public :: wxMenuItem_Check, wxMenuItem_Enable, wxMenuItem_IsEnabled

    !---------------------------------------------------------------------------
    ! wxStatusBar functions
    !---------------------------------------------------------------------------
    public :: wxStatusBar_Create
    public :: wxStatusBar_SetFieldsCount, wxStatusBar_GetFieldsCount
    public :: wxStatusBar_SetStatusText, wxStatusBar_GetStatusText
    public :: wxStatusBar_SetMinHeight

    !---------------------------------------------------------------------------
    ! wxMessageBox (standalone dialog function)
    !---------------------------------------------------------------------------
    public :: kwxMessageBox

    interface

        !-----------------------------------------------------------------------
        ! kwxApp - Application lifecycle
        !-----------------------------------------------------------------------
        function kwxApp_Initialize(argc, argv) bind(C, name="kwxApp_Initialize")
            import :: c_int, c_ptr
            integer(c_int), value :: argc
            type(c_ptr), value :: argv
            integer(c_int) :: kwxApp_Initialize
        end function kwxApp_Initialize

        function kwxApp_MainLoop() bind(C, name="kwxApp_MainLoop")
            import :: c_int
            integer(c_int) :: kwxApp_MainLoop
        end function kwxApp_MainLoop

        subroutine kwxApp_ExitMainLoop() bind(C, name="kwxApp_ExitMainLoop")
        end subroutine kwxApp_ExitMainLoop

        subroutine kwxApp_Shutdown() bind(C, name="kwxApp_Shutdown")
        end subroutine kwxApp_Shutdown

        function kwxApp_IsTerminating() bind(C, name="kwxApp_IsTerminating")
            import :: c_int
            integer(c_int) :: kwxApp_IsTerminating
        end function kwxApp_IsTerminating

        function kwxApp_GetAppName() bind(C, name="kwxApp_GetAppName")
            import :: c_ptr
            type(c_ptr) :: kwxApp_GetAppName
        end function kwxApp_GetAppName

        subroutine kwxApp_SetAppName(name) bind(C, name="kwxApp_SetAppName")
            import :: c_char
            character(kind=c_char), dimension(*), intent(in) :: name
        end subroutine kwxApp_SetAppName

        function kwxApp_GetVendorName() bind(C, name="kwxApp_GetVendorName")
            import :: c_ptr
            type(c_ptr) :: kwxApp_GetVendorName
        end function kwxApp_GetVendorName

        subroutine kwxApp_SetVendorName(name) bind(C, name="kwxApp_SetVendorName")
            import :: c_char
            character(kind=c_char), dimension(*), intent(in) :: name
        end subroutine kwxApp_SetVendorName

        function kwxApp_GetTopWindow() bind(C, name="kwxApp_GetTopWindow")
            import :: c_ptr
            type(c_ptr) :: kwxApp_GetTopWindow
        end function kwxApp_GetTopWindow

        subroutine kwxApp_SetTopWindow(window) bind(C, name="kwxApp_SetTopWindow")
            import :: c_ptr
            type(c_ptr), value :: window
        end subroutine kwxApp_SetTopWindow

        subroutine kwxApp_SetExitOnFrameDelete(flag) bind(C, name="kwxApp_SetExitOnFrameDelete")
            import :: c_int
            integer(c_int), value :: flag
        end subroutine kwxApp_SetExitOnFrameDelete

        function kwxApp_GetExitOnFrameDelete() bind(C, name="kwxApp_GetExitOnFrameDelete")
            import :: c_int
            integer(c_int) :: kwxApp_GetExitOnFrameDelete
        end function kwxApp_GetExitOnFrameDelete

        subroutine kwxApp_GetDisplaySize(width, height) bind(C, name="kwxApp_GetDisplaySize")
            import :: c_int
            integer(c_int), intent(out) :: width, height
        end subroutine kwxApp_GetDisplaySize

        subroutine kwxApp_GetMousePosition(x, y) bind(C, name="kwxApp_GetMousePosition")
            import :: c_int
            integer(c_int), intent(out) :: x, y
        end subroutine kwxApp_GetMousePosition

        function kwxApp_Pending() bind(C, name="kwxApp_Pending")
            import :: c_int
            integer(c_int) :: kwxApp_Pending
        end function kwxApp_Pending

        subroutine kwxApp_Dispatch() bind(C, name="kwxApp_Dispatch")
        end subroutine kwxApp_Dispatch

        function kwxApp_Yield() bind(C, name="kwxApp_Yield")
            import :: c_int
            integer(c_int) :: kwxApp_Yield
        end function kwxApp_Yield

        function kwxApp_SafeYield(window) bind(C, name="kwxApp_SafeYield")
            import :: c_int, c_ptr
            type(c_ptr), value :: window
            integer(c_int) :: kwxApp_SafeYield
        end function kwxApp_SafeYield

        subroutine kwxApp_InitAllImageHandlers() bind(C, name="kwxApp_InitAllImageHandlers")
        end subroutine kwxApp_InitAllImageHandlers

        subroutine kwxApp_Bell() bind(C, name="kwxApp_Bell")
        end subroutine kwxApp_Bell

        subroutine kwxApp_FreeString(str) bind(C, name="kwxApp_FreeString")
            import :: c_ptr
            type(c_ptr), value :: str
        end subroutine kwxApp_FreeString

        !-----------------------------------------------------------------------
        ! kwxApp - New functions added in kwxFFI refactor (#23)
        !-----------------------------------------------------------------------

        function kwxApp_GetOsVersion(major, minor) bind(C, name="kwxApp_GetOsVersion")
            import :: c_ptr, c_int
            type(c_ptr), value :: major, minor
            integer(c_int) :: kwxApp_GetOsVersion
        end function kwxApp_GetOsVersion

        ! Returns char* that caller must free with kwxApp_FreeString
        function kwxApp_GetOsDescription() bind(C, name="kwxApp_GetOsDescription")
            import :: c_ptr
            type(c_ptr) :: kwxApp_GetOsDescription
        end function kwxApp_GetOsDescription

        ! Returns char* that caller must free with kwxApp_FreeString
        function kwxApp_GetUserId() bind(C, name="kwxApp_GetUserId")
            import :: c_ptr
            type(c_ptr) :: kwxApp_GetUserId
        end function kwxApp_GetUserId

        ! Returns char* that caller must free with kwxApp_FreeString
        function kwxApp_GetUserName() bind(C, name="kwxApp_GetUserName")
            import :: c_ptr
            type(c_ptr) :: kwxApp_GetUserName
        end function kwxApp_GetUserName

        subroutine kwxApp_EnableTooltips(enable) bind(C, name="kwxApp_EnableTooltips")
            import :: c_int
            integer(c_int), value :: enable
        end subroutine kwxApp_EnableTooltips

        subroutine kwxApp_SetTooltipDelay(milliseconds) bind(C, name="kwxApp_SetTooltipDelay")
            import :: c_int
            integer(c_int), value :: milliseconds
        end subroutine kwxApp_SetTooltipDelay

        subroutine kwxApp_Sleep(seconds) bind(C, name="kwxApp_Sleep")
            import :: c_int
            integer(c_int), value :: seconds
        end subroutine kwxApp_Sleep

        subroutine kwxApp_MilliSleep(milliseconds) bind(C, name="kwxApp_MilliSleep")
            import :: c_int
            integer(c_int), value :: milliseconds
        end subroutine kwxApp_MilliSleep

        ! Find window by integer ID; parent can be c_null_ptr for top-level search
        function kwxApp_FindWindowById(id, parent) bind(C, name="kwxApp_FindWindowById")
            import :: c_ptr, c_int
            integer(c_int), value :: id
            type(c_ptr), value :: parent
            type(c_ptr) :: kwxApp_FindWindowById
        end function kwxApp_FindWindowById

        ! Find window by label (user-visible text); label is null-terminated UTF-8
        function kwxApp_FindWindowByLabel(label, parent) &
            bind(C, name="kwxApp_FindWindowByLabel")
            import :: c_ptr
            type(c_ptr), value :: label, parent
            type(c_ptr) :: kwxApp_FindWindowByLabel
        end function kwxApp_FindWindowByLabel

        ! Find window by name (programmatic, set via SetName)
        function kwxApp_FindWindowByName(name, parent) &
            bind(C, name="kwxApp_FindWindowByName")
            import :: c_ptr
            type(c_ptr), value :: name, parent
            type(c_ptr) :: kwxApp_FindWindowByName
        end function kwxApp_FindWindowByName

        ! Set periodic idle callback; interval_ms=0 disables;
        ! callback_func is void (*)(void* data) — NOT ClosureFun
        subroutine kwxApp_SetIdleCallback(interval_ms, callback_func, callback_data) &
            bind(C, name="kwxApp_SetIdleCallback")
            import :: c_ptr, c_int, c_funptr
            integer(c_int), value :: interval_ms
            type(c_funptr), value :: callback_func
            type(c_ptr), value :: callback_data
        end subroutine kwxApp_SetIdleCallback

        function kwxApp_GetIdleInterval() bind(C, name="kwxApp_GetIdleInterval")
            import :: c_int
            integer(c_int) :: kwxApp_GetIdleInterval
        end function kwxApp_GetIdleInterval

        !-----------------------------------------------------------------------
        ! wxFrame - Top-level window with optional menu, toolbar, status bar
        !-----------------------------------------------------------------------

        ! Creates a frame window
        ! parent: parent window (c_null_ptr for no parent)
        ! id: window identifier (use wxID_ANY for automatic)
        ! title: wxString* for window title
        ! x, y: position (use -1 for default)
        ! w, h: size (use -1 for default)
        ! style: window style flags (use wxDEFAULT_FRAME_STYLE)
        function wxFrame_Create(parent, id, title, x, y, w, h, style) &
            bind(C, name="wxFrame_Create")
            import :: c_ptr, c_int
            type(c_ptr), value :: parent
            integer(c_int), value :: id
            type(c_ptr), value :: title
            integer(c_int), value :: x, y, w, h, style
            type(c_ptr) :: wxFrame_Create
        end function wxFrame_Create

        function wxFrame_CreateStatusBar(frame, number, style) &
            bind(C, name="wxFrame_CreateStatusBar")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame
            integer(c_int), value :: number, style
            type(c_ptr) :: wxFrame_CreateStatusBar
        end function wxFrame_CreateStatusBar

        function wxFrame_GetStatusBar(frame) bind(C, name="wxFrame_GetStatusBar")
            import :: c_ptr
            type(c_ptr), value :: frame
            type(c_ptr) :: wxFrame_GetStatusBar
        end function wxFrame_GetStatusBar

        subroutine wxFrame_SetStatusBar(frame, statusbar) bind(C, name="wxFrame_SetStatusBar")
            import :: c_ptr
            type(c_ptr), value :: frame, statusbar
        end subroutine wxFrame_SetStatusBar

        subroutine wxFrame_SetStatusText(frame, text, number) &
            bind(C, name="wxFrame_SetStatusText")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame, text
            integer(c_int), value :: number
        end subroutine wxFrame_SetStatusText

        subroutine wxFrame_SetStatusWidths(frame, n, widths) &
            bind(C, name="wxFrame_SetStatusWidths")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame, widths
            integer(c_int), value :: n
        end subroutine wxFrame_SetStatusWidths

        function wxFrame_CreateToolBar(frame, style) bind(C, name="wxFrame_CreateToolBar")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame
            integer(c_int), value :: style
            type(c_ptr) :: wxFrame_CreateToolBar
        end function wxFrame_CreateToolBar

        function wxFrame_GetToolBar(frame) bind(C, name="wxFrame_GetToolBar")
            import :: c_ptr
            type(c_ptr), value :: frame
            type(c_ptr) :: wxFrame_GetToolBar
        end function wxFrame_GetToolBar

        subroutine wxFrame_SetToolBar(frame, toolbar) bind(C, name="wxFrame_SetToolBar")
            import :: c_ptr
            type(c_ptr), value :: frame, toolbar
        end subroutine wxFrame_SetToolBar

        function wxFrame_GetMenuBar(frame) bind(C, name="wxFrame_GetMenuBar")
            import :: c_ptr
            type(c_ptr), value :: frame
            type(c_ptr) :: wxFrame_GetMenuBar
        end function wxFrame_GetMenuBar

        subroutine wxFrame_SetMenuBar(frame, menubar) bind(C, name="wxFrame_SetMenuBar")
            import :: c_ptr
            type(c_ptr), value :: frame, menubar
        end subroutine wxFrame_SetMenuBar

        subroutine wxFrame_Restore(frame) bind(C, name="wxFrame_Restore")
            import :: c_ptr
            type(c_ptr), value :: frame
        end subroutine wxFrame_Restore

        function wxFrame_GetClientAreaOrigin_left(frame) &
            bind(C, name="wxFrame_GetClientAreaOrigin_left")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame
            integer(c_int) :: wxFrame_GetClientAreaOrigin_left
        end function wxFrame_GetClientAreaOrigin_left

        function wxFrame_GetClientAreaOrigin_top(frame) &
            bind(C, name="wxFrame_GetClientAreaOrigin_top")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame
            integer(c_int) :: wxFrame_GetClientAreaOrigin_top
        end function wxFrame_GetClientAreaOrigin_top

        !-----------------------------------------------------------------------
        ! wxFrame - New functions added in kwxFFI refactor (#23)
        !-----------------------------------------------------------------------

        subroutine wxFrame_Maximize(frame) bind(C, name="wxFrame_Maximize")
            import :: c_ptr
            type(c_ptr), value :: frame
        end subroutine wxFrame_Maximize

        subroutine wxFrame_Iconize(frame) bind(C, name="wxFrame_Iconize")
            import :: c_ptr
            type(c_ptr), value :: frame
        end subroutine wxFrame_Iconize

        function wxFrame_IsMaximized(frame) bind(C, name="wxFrame_IsMaximized")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame
            integer(c_int) :: wxFrame_IsMaximized
        end function wxFrame_IsMaximized

        function wxFrame_IsIconized(frame) bind(C, name="wxFrame_IsIconized")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame
            integer(c_int) :: wxFrame_IsIconized
        end function wxFrame_IsIconized

        function wxFrame_GetIcon(frame) bind(C, name="wxFrame_GetIcon")
            import :: c_ptr
            type(c_ptr), value :: frame
            type(c_ptr) :: wxFrame_GetIcon
        end function wxFrame_GetIcon

        subroutine wxFrame_SetIcon(frame, icon) bind(C, name="wxFrame_SetIcon")
            import :: c_ptr
            type(c_ptr), value :: frame, icon
        end subroutine wxFrame_SetIcon

        function wxFrame_FindItemInMenuBar(frame, menu_id) &
            bind(C, name="wxFrame_FindItemInMenuBar")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame
            integer(c_int), value :: menu_id
            type(c_ptr) :: wxFrame_FindItemInMenuBar
        end function wxFrame_FindItemInMenuBar

        subroutine wxFrame_ProcessCommand(frame, id) bind(C, name="wxFrame_ProcessCommand")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame
            integer(c_int), value :: id
        end subroutine wxFrame_ProcessCommand

        subroutine wxFrame_SetStatusBarPane(frame, n) bind(C, name="wxFrame_SetStatusBarPane")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame
            integer(c_int), value :: n
        end subroutine wxFrame_SetStatusBarPane

        function wxFrame_GetStatusBarPane(frame) bind(C, name="wxFrame_GetStatusBarPane")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame
            integer(c_int) :: wxFrame_GetStatusBarPane
        end function wxFrame_GetStatusBarPane

        subroutine wxFrame_PushStatusText(frame, text, field) &
            bind(C, name="wxFrame_PushStatusText")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame, text
            integer(c_int), value :: field
        end subroutine wxFrame_PushStatusText

        subroutine wxFrame_PopStatusText(frame, field) bind(C, name="wxFrame_PopStatusText")
            import :: c_ptr, c_int
            type(c_ptr), value :: frame
            integer(c_int), value :: field
        end subroutine wxFrame_PopStatusText

        !-----------------------------------------------------------------------
        ! wxTopLevelWindow - Base class for wxFrame, wxDialog
        ! Any wxFrame* or wxDialog* can be passed as the first argument.
        !-----------------------------------------------------------------------

        function wxTopLevelWindow_EnableCloseButton(window, enable) &
            bind(C, name="wxTopLevelWindow_EnableCloseButton")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: enable
            integer(c_int) :: wxTopLevelWindow_EnableCloseButton
        end function wxTopLevelWindow_EnableCloseButton

        ! GetTitle returns wxString* — caller must delete with wxString_Delete
        function wxTopLevelWindow_GetTitle(window) bind(C, name="wxTopLevelWindow_GetTitle")
            import :: c_ptr
            type(c_ptr), value :: window
            type(c_ptr) :: wxTopLevelWindow_GetTitle
        end function wxTopLevelWindow_GetTitle

        subroutine wxTopLevelWindow_SetTitle(window, title) &
            bind(C, name="wxTopLevelWindow_SetTitle")
            import :: c_ptr
            type(c_ptr), value :: window, title
        end subroutine wxTopLevelWindow_SetTitle

        function wxTopLevelWindow_IsActive(window) bind(C, name="wxTopLevelWindow_IsActive")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxTopLevelWindow_IsActive
        end function wxTopLevelWindow_IsActive

        subroutine wxTopLevelWindow_Iconize(window, iconize) &
            bind(C, name="wxTopLevelWindow_Iconize")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: iconize
        end subroutine wxTopLevelWindow_Iconize

        function wxTopLevelWindow_IsIconized(window) bind(C, name="wxTopLevelWindow_IsIconized")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxTopLevelWindow_IsIconized
        end function wxTopLevelWindow_IsIconized

        subroutine wxTopLevelWindow_Maximize(window, maximize) &
            bind(C, name="wxTopLevelWindow_Maximize")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: maximize
        end subroutine wxTopLevelWindow_Maximize

        function wxTopLevelWindow_IsMaximized(window) bind(C, name="wxTopLevelWindow_IsMaximized")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxTopLevelWindow_IsMaximized
        end function wxTopLevelWindow_IsMaximized

        subroutine wxTopLevelWindow_Restore(window) bind(C, name="wxTopLevelWindow_Restore")
            import :: c_ptr
            type(c_ptr), value :: window
        end subroutine wxTopLevelWindow_Restore

        ! direction: wxBOTH (default), wxHORIZONTAL, wxVERTICAL
        subroutine wxTopLevelWindow_CenterOnScreen(window, direction) &
            bind(C, name="wxTopLevelWindow_CenterOnScreen")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: direction
        end subroutine wxTopLevelWindow_CenterOnScreen

        function wxTopLevelWindow_ShowFullScreen(window, show, style) &
            bind(C, name="wxTopLevelWindow_ShowFullScreen")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: show, style
            integer(c_int) :: wxTopLevelWindow_ShowFullScreen
        end function wxTopLevelWindow_ShowFullScreen

        function wxTopLevelWindow_IsFullScreen(window) &
            bind(C, name="wxTopLevelWindow_IsFullScreen")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxTopLevelWindow_IsFullScreen
        end function wxTopLevelWindow_IsFullScreen

        function wxTopLevelWindow_EnableMaximizeButton(window, enable) &
            bind(C, name="wxTopLevelWindow_EnableMaximizeButton")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: enable
            integer(c_int) :: wxTopLevelWindow_EnableMaximizeButton
        end function wxTopLevelWindow_EnableMaximizeButton

        function wxTopLevelWindow_EnableMinimizeButton(window, enable) &
            bind(C, name="wxTopLevelWindow_EnableMinimizeButton")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: enable
            integer(c_int) :: wxTopLevelWindow_EnableMinimizeButton
        end function wxTopLevelWindow_EnableMinimizeButton

        subroutine wxTopLevelWindow_SetMinSize(window, width, height) &
            bind(C, name="wxTopLevelWindow_SetMinSize")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: width, height
        end subroutine wxTopLevelWindow_SetMinSize

        subroutine wxTopLevelWindow_SetMaxSize(window, width, height) &
            bind(C, name="wxTopLevelWindow_SetMaxSize")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: width, height
        end subroutine wxTopLevelWindow_SetMaxSize

        ! flags: wxUSER_ATTENTION_INFO (default) or wxUSER_ATTENTION_ERROR
        subroutine wxTopLevelWindow_RequestUserAttention(window, flags) &
            bind(C, name="wxTopLevelWindow_RequestUserAttention")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: flags
        end subroutine wxTopLevelWindow_RequestUserAttention

        !-----------------------------------------------------------------------
        ! wxWindow - Base class for all UI elements
        !-----------------------------------------------------------------------

        function wxWindow_Create(parent, id, x, y, w, h, style) &
            bind(C, name="wxWindow_Create")
            import :: c_ptr, c_int
            type(c_ptr), value :: parent
            integer(c_int), value :: id, x, y, w, h, style
            type(c_ptr) :: wxWindow_Create
        end function wxWindow_Create

        function wxWindow_Destroy(window) bind(C, name="wxWindow_Destroy")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_Destroy
        end function wxWindow_Destroy

        function wxWindow_DestroyChildren(window) bind(C, name="wxWindow_DestroyChildren")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_DestroyChildren
        end function wxWindow_DestroyChildren

        function wxWindow_Close(window, force) bind(C, name="wxWindow_Close")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: force
            integer(c_int) :: wxWindow_Close
        end function wxWindow_Close

        function wxWindow_Show(window) bind(C, name="wxWindow_Show")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_Show
        end function wxWindow_Show

        function wxWindow_Hide(window) bind(C, name="wxWindow_Hide")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_Hide
        end function wxWindow_Hide

        function wxWindow_Enable(window) bind(C, name="wxWindow_Enable")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_Enable
        end function wxWindow_Enable

        function wxWindow_Disable(window) bind(C, name="wxWindow_Disable")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_Disable
        end function wxWindow_Disable

        function wxWindow_IsEnabled(window) bind(C, name="wxWindow_IsEnabled")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_IsEnabled
        end function wxWindow_IsEnabled

        function wxWindow_IsShown(window) bind(C, name="wxWindow_IsShown")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_IsShown
        end function wxWindow_IsShown

        subroutine wxWindow_SetSize(window, x, y, w, h, flags) &
            bind(C, name="wxWindow_SetSize")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: x, y, w, h, flags
        end subroutine wxWindow_SetSize

        function wxWindow_GetSize(window) bind(C, name="wxWindow_GetSize")
            import :: c_ptr
            type(c_ptr), value :: window
            type(c_ptr) :: wxWindow_GetSize
        end function wxWindow_GetSize

        function wxWindow_GetPosition(window) bind(C, name="wxWindow_GetPosition")
            import :: c_ptr
            type(c_ptr), value :: window
            type(c_ptr) :: wxWindow_GetPosition
        end function wxWindow_GetPosition

        subroutine wxWindow_Move(window, x, y, flags) bind(C, name="wxWindow_Move")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: x, y, flags
        end subroutine wxWindow_Move

        function wxWindow_GetClientSize(window) bind(C, name="wxWindow_GetClientSize")
            import :: c_ptr
            type(c_ptr), value :: window
            type(c_ptr) :: wxWindow_GetClientSize
        end function wxWindow_GetClientSize

        subroutine wxWindow_SetClientSize(window, w, h) &
            bind(C, name="wxWindow_SetClientSize")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: w, h
        end subroutine wxWindow_SetClientSize

        function wxWindow_GetBestSize(window) bind(C, name="wxWindow_GetBestSize")
            import :: c_ptr
            type(c_ptr), value :: window
            type(c_ptr) :: wxWindow_GetBestSize
        end function wxWindow_GetBestSize

        function wxWindow_GetEffectiveMinSize(window) &
            bind(C, name="wxWindow_GetEffectiveMinSize")
            import :: c_ptr
            type(c_ptr), value :: window
            type(c_ptr) :: wxWindow_GetEffectiveMinSize
        end function wxWindow_GetEffectiveMinSize

        function wxWindow_GetId(window) bind(C, name="wxWindow_GetId")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_GetId
        end function wxWindow_GetId

        subroutine wxWindow_SetId(window, id) bind(C, name="wxWindow_SetId")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: id
        end subroutine wxWindow_SetId

        function wxWindow_GetLabel(window) bind(C, name="wxWindow_GetLabel")
            import :: c_ptr
            type(c_ptr), value :: window
            type(c_ptr) :: wxWindow_GetLabel
        end function wxWindow_GetLabel

        subroutine wxWindow_SetLabel(window, label) bind(C, name="wxWindow_SetLabel")
            import :: c_ptr
            type(c_ptr), value :: window, label
        end subroutine wxWindow_SetLabel

        function wxWindow_GetName(window) bind(C, name="wxWindow_GetName")
            import :: c_ptr
            type(c_ptr), value :: window
            type(c_ptr) :: wxWindow_GetName
        end function wxWindow_GetName

        subroutine wxWindow_SetName(window, name) bind(C, name="wxWindow_SetName")
            import :: c_ptr
            type(c_ptr), value :: window, name
        end subroutine wxWindow_SetName

        function wxWindow_GetParent(window) bind(C, name="wxWindow_GetParent")
            import :: c_ptr
            type(c_ptr), value :: window
            type(c_ptr) :: wxWindow_GetParent
        end function wxWindow_GetParent

        subroutine wxWindow_SetFocus(window) bind(C, name="wxWindow_SetFocus")
            import :: c_ptr
            type(c_ptr), value :: window
        end subroutine wxWindow_SetFocus

        function wxWindow_HasFocus(window) bind(C, name="wxWindow_HasFocus")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_HasFocus
        end function wxWindow_HasFocus

        subroutine wxWindow_Refresh(window, eraseBackground) &
            bind(C, name="wxWindow_Refresh")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: eraseBackground
        end subroutine wxWindow_Refresh

        subroutine wxWindow_Update(window) bind(C, name="wxWindow_Update")
            import :: c_ptr
            type(c_ptr), value :: window
        end subroutine wxWindow_Update

        function wxWindow_SetBackgroundColour(window, colour) &
            bind(C, name="wxWindow_SetBackgroundColour")
            import :: c_ptr, c_int
            type(c_ptr), value :: window, colour
            integer(c_int) :: wxWindow_SetBackgroundColour
        end function wxWindow_SetBackgroundColour

        subroutine wxWindow_GetBackgroundColour(window, colour_ref) &
            bind(C, name="wxWindow_GetBackgroundColour")
            import :: c_ptr
            type(c_ptr), value :: window, colour_ref
        end subroutine wxWindow_GetBackgroundColour

        function wxWindow_SetForegroundColour(window, colour) &
            bind(C, name="wxWindow_SetForegroundColour")
            import :: c_ptr, c_int
            type(c_ptr), value :: window, colour
            integer(c_int) :: wxWindow_SetForegroundColour
        end function wxWindow_SetForegroundColour

        subroutine wxWindow_GetForegroundColour(window, colour_ref) &
            bind(C, name="wxWindow_GetForegroundColour")
            import :: c_ptr
            type(c_ptr), value :: window, colour_ref
        end subroutine wxWindow_GetForegroundColour

        subroutine wxWindow_SetFont(window, font) bind(C, name="wxWindow_SetFont")
            import :: c_ptr
            type(c_ptr), value :: window, font
        end subroutine wxWindow_SetFont

        subroutine wxWindow_GetFont(window, font_ref) bind(C, name="wxWindow_GetFont")
            import :: c_ptr
            type(c_ptr), value :: window, font_ref
        end subroutine wxWindow_GetFont

        subroutine wxWindow_Center(window, direction) bind(C, name="wxWindow_Center")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: direction
        end subroutine wxWindow_Center

        subroutine wxWindow_CenterOnParent(window, direction) &
            bind(C, name="wxWindow_CenterOnParent")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: direction
        end subroutine wxWindow_CenterOnParent

        subroutine wxWindow_Fit(window) bind(C, name="wxWindow_Fit")
            import :: c_ptr
            type(c_ptr), value :: window
        end subroutine wxWindow_Fit

        subroutine wxWindow_FitInside(window) bind(C, name="wxWindow_FitInside")
            import :: c_ptr
            type(c_ptr), value :: window
        end subroutine wxWindow_FitInside

        function wxWindow_Layout(window) bind(C, name="wxWindow_Layout")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_Layout
        end function wxWindow_Layout

        subroutine wxWindow_SetSizer(window, sizer, deleteOld) &
            bind(C, name="wxWindow_SetSizer")
            import :: c_ptr, c_int
            type(c_ptr), value :: window, sizer
            integer(c_int), value :: deleteOld
        end subroutine wxWindow_SetSizer

        function wxWindow_GetSizer(window) bind(C, name="wxWindow_GetSizer")
            import :: c_ptr
            type(c_ptr), value :: window
            type(c_ptr) :: wxWindow_GetSizer
        end function wxWindow_GetSizer

        subroutine wxWindow_SetToolTip(window, tip) bind(C, name="wxWindow_SetToolTip")
            import :: c_ptr
            type(c_ptr), value :: window, tip
        end subroutine wxWindow_SetToolTip

        function wxWindow_GetToolTip(window) bind(C, name="wxWindow_GetToolTip")
            import :: c_ptr
            type(c_ptr), value :: window
            type(c_ptr) :: wxWindow_GetToolTip
        end function wxWindow_GetToolTip

        function wxWindow_IsTopLevel(window) bind(C, name="wxWindow_IsTopLevel")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_IsTopLevel
        end function wxWindow_IsTopLevel

        subroutine wxWindow_Freeze(window) bind(C, name="wxWindow_Freeze")
            import :: c_ptr
            type(c_ptr), value :: window
        end subroutine wxWindow_Freeze

        subroutine wxWindow_Thaw(window) bind(C, name="wxWindow_Thaw")
            import :: c_ptr
            type(c_ptr), value :: window
        end subroutine wxWindow_Thaw

        subroutine wxWindow_Lower(window) bind(C, name="wxWindow_Lower")
            import :: c_ptr
            type(c_ptr), value :: window
        end subroutine wxWindow_Lower

        subroutine wxWindow_Raise(window) bind(C, name="wxWindow_Raise")
            import :: c_ptr
            type(c_ptr), value :: window
        end subroutine wxWindow_Raise

        !-----------------------------------------------------------------------
        ! wxButton
        !-----------------------------------------------------------------------
        function wxButton_Create(parent, id, text, x, y, w, h, style) &
            bind(C, name="wxButton_Create")
            import :: c_ptr, c_int
            type(c_ptr), value :: parent
            integer(c_int), value :: id
            type(c_ptr), value :: text    ! wxString*
            integer(c_int), value :: x, y, w, h, style
            type(c_ptr) :: wxButton_Create
        end function wxButton_Create

        subroutine wxButton_SetDefault(self) bind(C, name="wxButton_SetDefault")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxButton_SetDefault

        !-----------------------------------------------------------------------
        ! wxTextCtrl
        !-----------------------------------------------------------------------
        function wxTextCtrl_Create(parent, id, text, x, y, w, h, style) &
            bind(C, name="wxTextCtrl_Create")
            import :: c_ptr, c_int, c_long
            type(c_ptr), value :: parent
            integer(c_int), value :: id
            type(c_ptr), value :: text    ! wxString*
            integer(c_int), value :: x, y, w, h
            integer(c_long), value :: style
            type(c_ptr) :: wxTextCtrl_Create
        end function wxTextCtrl_Create

        function wxTextCtrl_GetValue(self) bind(C, name="wxTextCtrl_GetValue")
            import :: c_ptr
            type(c_ptr), value :: self
            type(c_ptr) :: wxTextCtrl_GetValue  ! wxString* (caller must delete)
        end function wxTextCtrl_GetValue

        subroutine wxTextCtrl_SetValue(self, value) &
            bind(C, name="wxTextCtrl_SetValue")
            import :: c_ptr
            type(c_ptr), value :: self, value  ! value is wxString*
        end subroutine wxTextCtrl_SetValue

        subroutine wxTextCtrl_ChangeValue(self, value) &
            bind(C, name="wxTextCtrl_ChangeValue")
            import :: c_ptr
            type(c_ptr), value :: self, value  ! value is wxString*
        end subroutine wxTextCtrl_ChangeValue

        subroutine wxTextCtrl_Clear(self) bind(C, name="wxTextCtrl_Clear")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxTextCtrl_Clear

        subroutine wxTextCtrl_WriteText(self, text) &
            bind(C, name="wxTextCtrl_WriteText")
            import :: c_ptr
            type(c_ptr), value :: self, text  ! text is wxString*
        end subroutine wxTextCtrl_WriteText

        subroutine wxTextCtrl_AppendText(self, text) &
            bind(C, name="wxTextCtrl_AppendText")
            import :: c_ptr
            type(c_ptr), value :: self, text  ! text is wxString*
        end subroutine wxTextCtrl_AppendText

        function wxTextCtrl_IsModified(self) bind(C, name="wxTextCtrl_IsModified")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxTextCtrl_IsModified
        end function wxTextCtrl_IsModified

        function wxTextCtrl_IsEditable(self) bind(C, name="wxTextCtrl_IsEditable")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxTextCtrl_IsEditable
        end function wxTextCtrl_IsEditable

        function wxTextCtrl_GetNumberOfLines(self) &
            bind(C, name="wxTextCtrl_GetNumberOfLines")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxTextCtrl_GetNumberOfLines
        end function wxTextCtrl_GetNumberOfLines

        function wxTextEntry_SetHint(self, hint) &
            bind(C, name="wxTextEntry_SetHint")
            import :: c_ptr, c_int
            type(c_ptr), value :: self   ! wxTextEntry* (wxTextCtrl* is compatible)
            type(c_ptr), value :: hint   ! wxString*
            integer(c_int) :: wxTextEntry_SetHint
        end function wxTextEntry_SetHint

        !-----------------------------------------------------------------------
        ! wxStaticText
        !-----------------------------------------------------------------------
        function wxStaticText_Create(parent, id, text, x, y, w, h, style) &
            bind(C, name="wxStaticText_Create")
            import :: c_ptr, c_int
            type(c_ptr), value :: parent
            integer(c_int), value :: id
            type(c_ptr), value :: text    ! wxString*
            integer(c_int), value :: x, y, w, h, style
            type(c_ptr) :: wxStaticText_Create
        end function wxStaticText_Create

        !-----------------------------------------------------------------------
        ! wxPanel
        !-----------------------------------------------------------------------
        function wxPanel_Create(parent, id, x, y, w, h, style) &
            bind(C, name="wxPanel_Create")
            import :: c_ptr, c_int
            type(c_ptr), value :: parent
            integer(c_int), value :: id, x, y, w, h, style
            type(c_ptr) :: wxPanel_Create
        end function wxPanel_Create

        subroutine wxPanel_SetFocus(self) bind(C, name="wxPanel_SetFocus")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxPanel_SetFocus

        !-----------------------------------------------------------------------
        ! wxBoxSizer
        !-----------------------------------------------------------------------
        function wxBoxSizer_Create(orient) bind(C, name="wxBoxSizer_Create")
            import :: c_ptr, c_int
            integer(c_int), value :: orient
            type(c_ptr) :: wxBoxSizer_Create
        end function wxBoxSizer_Create

        function wxBoxSizer_GetOrientation(self) &
            bind(C, name="wxBoxSizer_GetOrientation")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxBoxSizer_GetOrientation
        end function wxBoxSizer_GetOrientation

        !-----------------------------------------------------------------------
        ! wxSizer (base class)
        !-----------------------------------------------------------------------
        subroutine wxSizer_AddWindow(self, window, option, flag, border, &
            userData) bind(C, name="wxSizer_AddWindow")
            import :: c_ptr, c_int
            type(c_ptr), value :: self, window
            integer(c_int), value :: option, flag, border
            type(c_ptr), value :: userData
        end subroutine wxSizer_AddWindow

        subroutine wxSizer_AddSizer(self, sizer, option, flag, border, &
            userData) bind(C, name="wxSizer_AddSizer")
            import :: c_ptr, c_int
            type(c_ptr), value :: self, sizer
            integer(c_int), value :: option, flag, border
            type(c_ptr), value :: userData
        end subroutine wxSizer_AddSizer

        subroutine wxSizer_Add(self, width, height, option, flag, border, &
            userData) bind(C, name="wxSizer_Add")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: width, height, option, flag, border
            type(c_ptr), value :: userData
        end subroutine wxSizer_Add

        subroutine wxSizer_AddSpacer(self, size) &
            bind(C, name="wxSizer_AddSpacer")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: size
        end subroutine wxSizer_AddSpacer

        subroutine wxSizer_AddStretchSpacer(self, prop) &
            bind(C, name="wxSizer_AddStretchSpacer")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: prop
        end subroutine wxSizer_AddStretchSpacer

        subroutine wxSizer_Layout(self) bind(C, name="wxSizer_Layout")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxSizer_Layout

        subroutine wxSizer_Fit(self, window) bind(C, name="wxSizer_Fit")
            import :: c_ptr
            type(c_ptr), value :: self, window
        end subroutine wxSizer_Fit

        subroutine wxSizer_SetSizeHints(self, window) &
            bind(C, name="wxSizer_SetSizeHints")
            import :: c_ptr
            type(c_ptr), value :: self, window
        end subroutine wxSizer_SetSizeHints

        subroutine wxSizer_SetMinSize(self, width, height) &
            bind(C, name="wxSizer_SetMinSize")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: width, height
        end subroutine wxSizer_SetMinSize

        !-----------------------------------------------------------------------
        ! wxEvtHandler Event Connection
        ! wxEvtHandler_Connect wraps a wxClosure* into a wxCallback and connects
        ! it to the wxEvtHandler (window/control). Create closure first with
        ! wxClosure_Create(fun, data).
        !-----------------------------------------------------------------------

        ! Connect an event handler
        ! obj   : wxEvtHandler* (window/control to connect to)
        ! first : first window ID to match (-1 for any)
        ! last  : last window ID to match (-1 for same as first)
        ! type  : event type (from expEVT_COMMAND_* constants)
        ! closure: wxClosure* from wxClosure_Create(fun, data)
        function wxEvtHandler_Connect(obj, first, last, type, closure) &
            bind(C, name="wxEvtHandler_Connect")
            import :: c_ptr, c_int
            type(c_ptr), value :: obj
            integer(c_int), value :: first, last, type
            type(c_ptr), value :: closure
            integer(c_int) :: wxEvtHandler_Connect
        end function wxEvtHandler_Connect

        ! Disconnect an event handler
        ! data: wxObject* user data to match (c_null_ptr to match any)
        function wxEvtHandler_Disconnect(self, first, last, type, data) &
            bind(C, name="wxEvtHandler_Disconnect")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: first, last, type
            type(c_ptr), value :: data
            integer(c_int) :: wxEvtHandler_Disconnect
        end function wxEvtHandler_Disconnect

        !-----------------------------------------------------------------------
        ! wxClosure - Reference-counted callback wrapper
        !-----------------------------------------------------------------------

        ! Create a closure that wraps a foreign function pointer and user data
        ! fun: procedure pointer matching ClosureFun signature
        !      void (*)(void* fun, void* data, void* evt)
        ! data: user data pointer passed to callback
        function wxClosure_Create(fun, data) bind(C, name="wxClosure_Create")
            import :: c_ptr, c_funptr
            type(c_funptr), value :: fun
            type(c_ptr), value :: data
            type(c_ptr) :: wxClosure_Create
        end function wxClosure_Create

        ! Get the user data pointer from a closure
        function wxClosure_GetData(closure) bind(C, name="wxClosure_GetData")
            import :: c_ptr
            type(c_ptr), value :: closure
            type(c_ptr) :: wxClosure_GetData
        end function wxClosure_GetData

        !-----------------------------------------------------------------------
        ! wxEvent - Base event class accessors
        !-----------------------------------------------------------------------

        function wxEvent_GetEventType(self) bind(C, name="wxEvent_GetEventType")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxEvent_GetEventType
        end function wxEvent_GetEventType

        function wxEvent_GetId(self) bind(C, name="wxEvent_GetId")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxEvent_GetId
        end function wxEvent_GetId

        subroutine wxEvent_Skip(self, skip) bind(C, name="wxEvent_Skip")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: skip
        end subroutine wxEvent_Skip

        function wxEvent_GetTimestamp(self) bind(C, name="wxEvent_GetTimestamp")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxEvent_GetTimestamp
        end function wxEvent_GetTimestamp

        function wxEvent_GetSkipped(self) bind(C, name="wxEvent_GetSkipped")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxEvent_GetSkipped
        end function wxEvent_GetSkipped

        function wxEvent_GetEventObject(self) bind(C, name="wxEvent_GetEventObject")
            import :: c_ptr
            type(c_ptr), value :: self
            type(c_ptr) :: wxEvent_GetEventObject
        end function wxEvent_GetEventObject

        function wxEvent_IsCommandEvent(self) bind(C, name="wxEvent_IsCommandEvent")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxEvent_IsCommandEvent
        end function wxEvent_IsCommandEvent

        !-----------------------------------------------------------------------
        ! wxCommandEvent - Command event accessors
        !-----------------------------------------------------------------------

        ! Returns wxString* (caller must delete)
        function wxCommandEvent_GetString(self) &
            bind(C, name="wxCommandEvent_GetString")
            import :: c_ptr
            type(c_ptr), value :: self
            type(c_ptr) :: wxCommandEvent_GetString
        end function wxCommandEvent_GetString

        function wxCommandEvent_GetSelection(self) &
            bind(C, name="wxCommandEvent_GetSelection")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxCommandEvent_GetSelection
        end function wxCommandEvent_GetSelection

        function wxCommandEvent_GetInt(self) &
            bind(C, name="wxCommandEvent_GetInt")
            import :: c_ptr, c_long
            type(c_ptr), value :: self
            integer(c_long) :: wxCommandEvent_GetInt
        end function wxCommandEvent_GetInt

        function wxCommandEvent_GetExtraLong(self) &
            bind(C, name="wxCommandEvent_GetExtraLong")
            import :: c_ptr, c_long
            type(c_ptr), value :: self
            integer(c_long) :: wxCommandEvent_GetExtraLong
        end function wxCommandEvent_GetExtraLong

        function wxCommandEvent_IsChecked(self) &
            bind(C, name="wxCommandEvent_IsChecked")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxCommandEvent_IsChecked
        end function wxCommandEvent_IsChecked

        function wxCommandEvent_IsSelection(self) &
            bind(C, name="wxCommandEvent_IsSelection")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxCommandEvent_IsSelection
        end function wxCommandEvent_IsSelection

        !-----------------------------------------------------------------------
        ! wxCheckBox
        !-----------------------------------------------------------------------

        function wxCheckBox_Create(parent, id, text, x, y, w, h, style) &
            bind(C, name="wxCheckBox_Create")
            import :: c_ptr, c_int
            type(c_ptr), value :: parent
            integer(c_int), value :: id
            type(c_ptr), value :: text
            integer(c_int), value :: x, y, w, h, style
            type(c_ptr) :: wxCheckBox_Create
        end function wxCheckBox_Create

        subroutine wxCheckBox_SetValue(self, val) &
            bind(C, name="wxCheckBox_SetValue")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: val
        end subroutine wxCheckBox_SetValue

        function wxCheckBox_GetValue(self) &
            bind(C, name="wxCheckBox_GetValue")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxCheckBox_GetValue
        end function wxCheckBox_GetValue

        !-----------------------------------------------------------------------
        ! wxRadioButton
        !-----------------------------------------------------------------------

        function wxRadioButton_Create(parent, id, label, x, y, w, h, style) &
            bind(C, name="wxRadioButton_Create")
            import :: c_ptr, c_int
            type(c_ptr), value :: parent
            integer(c_int), value :: id
            type(c_ptr), value :: label
            integer(c_int), value :: x, y, w, h, style
            type(c_ptr) :: wxRadioButton_Create
        end function wxRadioButton_Create

        subroutine wxRadioButton_SetValue(self, val) &
            bind(C, name="wxRadioButton_SetValue")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: val
        end subroutine wxRadioButton_SetValue

        function wxRadioButton_GetValue(self) &
            bind(C, name="wxRadioButton_GetValue")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxRadioButton_GetValue
        end function wxRadioButton_GetValue

        !-----------------------------------------------------------------------
        ! wxChoice
        !-----------------------------------------------------------------------

        function wxChoice_Create(parent, id, x, y, w, h, count, items, &
            style) bind(C, name="wxChoice_Create")
            import :: c_ptr, c_int
            type(c_ptr), value :: parent
            integer(c_int), value :: id, x, y, w, h, count, style
            type(c_ptr), value :: items
            type(c_ptr) :: wxChoice_Create
        end function wxChoice_Create

        subroutine wxChoice_Append(self, item) &
            bind(C, name="wxChoice_Append")
            import :: c_ptr
            type(c_ptr), value :: self
            type(c_ptr), value :: item
        end subroutine wxChoice_Append

        subroutine wxChoice_Delete(self, index) &
            bind(C, name="wxChoice_Delete")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index
        end subroutine wxChoice_Delete

        subroutine wxChoice_Clear(self) bind(C, name="wxChoice_Clear")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxChoice_Clear

        function wxChoice_GetCount(self) &
            bind(C, name="wxChoice_GetCount")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxChoice_GetCount
        end function wxChoice_GetCount

        function wxChoice_GetSelection(self) &
            bind(C, name="wxChoice_GetSelection")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxChoice_GetSelection
        end function wxChoice_GetSelection

        subroutine wxChoice_SetSelection(self, index) &
            bind(C, name="wxChoice_SetSelection")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index
        end subroutine wxChoice_SetSelection

        function wxChoice_FindString(self, str) &
            bind(C, name="wxChoice_FindString")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            type(c_ptr), value :: str
            integer(c_int) :: wxChoice_FindString
        end function wxChoice_FindString

        function wxChoice_GetString(self, index) &
            bind(C, name="wxChoice_GetString")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index
            type(c_ptr) :: wxChoice_GetString
        end function wxChoice_GetString

        subroutine wxChoice_SetString(self, index, str) &
            bind(C, name="wxChoice_SetString")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index
            type(c_ptr), value :: str
        end subroutine wxChoice_SetString

        !-----------------------------------------------------------------------
        ! wxListBox
        !-----------------------------------------------------------------------

        function wxListBox_Create(parent, id, x, y, w, h, count, items, &
            style) bind(C, name="wxListBox_Create")
            import :: c_ptr, c_int
            type(c_ptr), value :: parent
            integer(c_int), value :: id, x, y, w, h, count, style
            type(c_ptr), value :: items
            type(c_ptr) :: wxListBox_Create
        end function wxListBox_Create

        subroutine wxListBox_Clear(self) bind(C, name="wxListBox_Clear")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxListBox_Clear

        subroutine wxListBox_Delete(self, index) &
            bind(C, name="wxListBox_Delete")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index
        end subroutine wxListBox_Delete

        function wxListBox_GetCount(self) &
            bind(C, name="wxListBox_GetCount")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxListBox_GetCount
        end function wxListBox_GetCount

        function wxListBox_GetString(self, index) &
            bind(C, name="wxListBox_GetString")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index
            type(c_ptr) :: wxListBox_GetString
        end function wxListBox_GetString

        subroutine wxListBox_SetString(self, index, str) &
            bind(C, name="wxListBox_SetString")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index
            type(c_ptr), value :: str
        end subroutine wxListBox_SetString

        function wxListBox_FindString(self, str) &
            bind(C, name="wxListBox_FindString")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            type(c_ptr), value :: str
            integer(c_int) :: wxListBox_FindString
        end function wxListBox_FindString

        function wxListBox_IsSelected(self, index) &
            bind(C, name="wxListBox_IsSelected")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index
            integer(c_int) :: wxListBox_IsSelected
        end function wxListBox_IsSelected

        subroutine wxListBox_SetSelection(self, index, sel) &
            bind(C, name="wxListBox_SetSelection")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index, sel
        end subroutine wxListBox_SetSelection

        function wxListBox_GetSelection(self) &
            bind(C, name="wxListBox_GetSelection")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxListBox_GetSelection
        end function wxListBox_GetSelection

        subroutine wxListBox_Append(self, item) &
            bind(C, name="wxListBox_Append")
            import :: c_ptr
            type(c_ptr), value :: self
            type(c_ptr), value :: item
        end subroutine wxListBox_Append

        !-----------------------------------------------------------------------
        ! wxComboBox
        !-----------------------------------------------------------------------

        function wxComboBox_Create(parent, id, text, x, y, w, h, count, &
            items, style) bind(C, name="wxComboBox_Create")
            import :: c_ptr, c_int
            type(c_ptr), value :: parent
            integer(c_int), value :: id
            type(c_ptr), value :: text
            integer(c_int), value :: x, y, w, h, count, style
            type(c_ptr), value :: items
            type(c_ptr) :: wxComboBox_Create
        end function wxComboBox_Create

        function wxComboBox_GetValue(self) &
            bind(C, name="wxComboBox_GetValue")
            import :: c_ptr
            type(c_ptr), value :: self
            type(c_ptr) :: wxComboBox_GetValue
        end function wxComboBox_GetValue

        subroutine wxComboBox_SetValue(self, value) &
            bind(C, name="wxComboBox_SetValue")
            import :: c_ptr
            type(c_ptr), value :: self
            type(c_ptr), value :: value
        end subroutine wxComboBox_SetValue

        subroutine wxComboBox_Append(self, item) &
            bind(C, name="wxComboBox_Append")
            import :: c_ptr
            type(c_ptr), value :: self
            type(c_ptr), value :: item
        end subroutine wxComboBox_Append

        subroutine wxComboBox_Delete(self, index) &
            bind(C, name="wxComboBox_Delete")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index
        end subroutine wxComboBox_Delete

        subroutine wxComboBox_Clear(self) bind(C, name="wxComboBox_Clear")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxComboBox_Clear

        function wxComboBox_GetCount(self) &
            bind(C, name="wxComboBox_GetCount")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxComboBox_GetCount
        end function wxComboBox_GetCount

        function wxComboBox_GetSelection(self) &
            bind(C, name="wxComboBox_GetSelection")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxComboBox_GetSelection
        end function wxComboBox_GetSelection

        subroutine wxComboBox_SetSelection(self, index) &
            bind(C, name="wxComboBox_SetSelection")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index
        end subroutine wxComboBox_SetSelection

        function wxComboBox_FindString(self, s) &
            bind(C, name="wxComboBox_FindString")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            type(c_ptr), value :: s
            integer(c_int) :: wxComboBox_FindString
        end function wxComboBox_FindString

        function wxComboBox_GetString(self, index) &
            bind(C, name="wxComboBox_GetString")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index
            type(c_ptr) :: wxComboBox_GetString
        end function wxComboBox_GetString

        subroutine wxComboBox_SetString(self, index, s) &
            bind(C, name="wxComboBox_SetString")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: index
            type(c_ptr), value :: s
        end subroutine wxComboBox_SetString

        subroutine wxComboBox_Copy(self) bind(C, name="wxComboBox_Copy")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxComboBox_Copy

        subroutine wxComboBox_Cut(self) bind(C, name="wxComboBox_Cut")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxComboBox_Cut

        subroutine wxComboBox_Paste(self) bind(C, name="wxComboBox_Paste")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxComboBox_Paste

        !-----------------------------------------------------------------------
        ! wxMenu
        !-----------------------------------------------------------------------

        function wxMenu_Create(title, style) &
            bind(C, name="wxMenu_Create")
            import :: c_ptr, c_long
            type(c_ptr), value :: title
            integer(c_long), value :: style
            type(c_ptr) :: wxMenu_Create
        end function wxMenu_Create

        subroutine wxMenu_DeletePointer(self) &
            bind(C, name="wxMenu_DeletePointer")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxMenu_DeletePointer

        function wxMenu_Append(self, id, text, help, isCheckable) &
            bind(C, name="wxMenu_Append")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: id
            type(c_ptr), value :: text
            type(c_ptr), value :: help
            integer(c_int), value :: isCheckable
            type(c_ptr) :: wxMenu_Append
        end function wxMenu_Append

        subroutine wxMenu_AppendSeparator(self) &
            bind(C, name="wxMenu_AppendSeparator")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxMenu_AppendSeparator

        subroutine wxMenu_AppendRadioItem(self, id, text, help) &
            bind(C, name="wxMenu_AppendRadioItem")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: id
            type(c_ptr), value :: text
            type(c_ptr), value :: help
        end subroutine wxMenu_AppendRadioItem

        subroutine wxMenu_Enable(self, id, enable) &
            bind(C, name="wxMenu_Enable")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: id, enable
        end subroutine wxMenu_Enable

        subroutine wxMenu_Check(self, id, check) &
            bind(C, name="wxMenu_Check")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: id, check
        end subroutine wxMenu_Check

        function wxMenu_IsEnabled(self, id) &
            bind(C, name="wxMenu_IsEnabled")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: id
            integer(c_int) :: wxMenu_IsEnabled
        end function wxMenu_IsEnabled

        function wxMenu_IsChecked(self, id) &
            bind(C, name="wxMenu_IsChecked")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: id
            integer(c_int) :: wxMenu_IsChecked
        end function wxMenu_IsChecked

        function wxMenu_GetMenuItemCount(self) &
            bind(C, name="wxMenu_GetMenuItemCount")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxMenu_GetMenuItemCount
        end function wxMenu_GetMenuItemCount

        subroutine wxMenu_SetTitle(self, title) &
            bind(C, name="wxMenu_SetTitle")
            import :: c_ptr
            type(c_ptr), value :: self
            type(c_ptr), value :: title
        end subroutine wxMenu_SetTitle

        function wxMenu_GetTitle(self) &
            bind(C, name="wxMenu_GetTitle")
            import :: c_ptr
            type(c_ptr), value :: self
            type(c_ptr) :: wxMenu_GetTitle
        end function wxMenu_GetTitle

        !-----------------------------------------------------------------------
        ! wxMenuBar
        !-----------------------------------------------------------------------

        function wxMenuBar_Create(style) &
            bind(C, name="wxMenuBar_Create")
            import :: c_ptr, c_int
            integer(c_int), value :: style
            type(c_ptr) :: wxMenuBar_Create
        end function wxMenuBar_Create

        function wxMenuBar_Append(self, menu, title) &
            bind(C, name="wxMenuBar_Append")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            type(c_ptr), value :: menu
            type(c_ptr), value :: title
            integer(c_int) :: wxMenuBar_Append
        end function wxMenuBar_Append

        function wxMenuBar_GetMenuCount(self) &
            bind(C, name="wxMenuBar_GetMenuCount")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxMenuBar_GetMenuCount
        end function wxMenuBar_GetMenuCount

        function wxMenuBar_GetMenu(self, pos) &
            bind(C, name="wxMenuBar_GetMenu")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: pos
            type(c_ptr) :: wxMenuBar_GetMenu
        end function wxMenuBar_GetMenu

        subroutine wxMenuBar_EnableTop(self, pos, enable) &
            bind(C, name="wxMenuBar_EnableTop")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: pos, enable
        end subroutine wxMenuBar_EnableTop

        !-----------------------------------------------------------------------
        ! wxMenuItem
        !-----------------------------------------------------------------------

        function wxMenuItem_Create() &
            bind(C, name="wxMenuItem_Create")
            import :: c_ptr
            type(c_ptr) :: wxMenuItem_Create
        end function wxMenuItem_Create

        function wxMenuItem_CreateEx(id, text, helpstr, itemkind, submenu) &
            bind(C, name="wxMenuItem_CreateEx")
            import :: c_ptr, c_int
            integer(c_int), value :: id, itemkind
            type(c_ptr), value :: text, helpstr, submenu
            type(c_ptr) :: wxMenuItem_CreateEx
        end function wxMenuItem_CreateEx

        subroutine wxMenuItem_Delete(self) &
            bind(C, name="wxMenuItem_Delete")
            import :: c_ptr
            type(c_ptr), value :: self
        end subroutine wxMenuItem_Delete

        function wxMenuItem_GetId(self) &
            bind(C, name="wxMenuItem_GetId")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxMenuItem_GetId
        end function wxMenuItem_GetId

        function wxMenuItem_IsSeparator(self) &
            bind(C, name="wxMenuItem_IsSeparator")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxMenuItem_IsSeparator
        end function wxMenuItem_IsSeparator

        subroutine wxMenuItem_SetItemLabel(self, str) &
            bind(C, name="wxMenuItem_SetItemLabel")
            import :: c_ptr
            type(c_ptr), value :: self
            type(c_ptr), value :: str
        end subroutine wxMenuItem_SetItemLabel

        function wxMenuItem_GetItemLabel(self) &
            bind(C, name="wxMenuItem_GetItemLabel")
            import :: c_ptr
            type(c_ptr), value :: self
            type(c_ptr) :: wxMenuItem_GetItemLabel
        end function wxMenuItem_GetItemLabel

        subroutine wxMenuItem_SetCheckable(self, checkable) &
            bind(C, name="wxMenuItem_SetCheckable")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: checkable
        end subroutine wxMenuItem_SetCheckable

        function wxMenuItem_IsChecked(self) &
            bind(C, name="wxMenuItem_IsChecked")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxMenuItem_IsChecked
        end function wxMenuItem_IsChecked

        subroutine wxMenuItem_Check(self, check) &
            bind(C, name="wxMenuItem_Check")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: check
        end subroutine wxMenuItem_Check

        subroutine wxMenuItem_Enable(self, enable) &
            bind(C, name="wxMenuItem_Enable")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: enable
        end subroutine wxMenuItem_Enable

        function wxMenuItem_IsEnabled(self) &
            bind(C, name="wxMenuItem_IsEnabled")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxMenuItem_IsEnabled
        end function wxMenuItem_IsEnabled

        !-----------------------------------------------------------------------
        ! wxStatusBar
        !-----------------------------------------------------------------------

        function wxStatusBar_Create(parent, id, x, y, w, h, style) &
            bind(C, name="wxStatusBar_Create")
            import :: c_ptr, c_int
            type(c_ptr), value :: parent
            integer(c_int), value :: id, x, y, w, h, style
            type(c_ptr) :: wxStatusBar_Create
        end function wxStatusBar_Create

        subroutine wxStatusBar_SetFieldsCount(self, number, widths) &
            bind(C, name="wxStatusBar_SetFieldsCount")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: number
            type(c_ptr), value :: widths
        end subroutine wxStatusBar_SetFieldsCount

        function wxStatusBar_GetFieldsCount(self) &
            bind(C, name="wxStatusBar_GetFieldsCount")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int) :: wxStatusBar_GetFieldsCount
        end function wxStatusBar_GetFieldsCount

        subroutine wxStatusBar_SetStatusText(self, text, number) &
            bind(C, name="wxStatusBar_SetStatusText")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            type(c_ptr), value :: text
            integer(c_int), value :: number
        end subroutine wxStatusBar_SetStatusText

        function wxStatusBar_GetStatusText(self, number) &
            bind(C, name="wxStatusBar_GetStatusText")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: number
            type(c_ptr) :: wxStatusBar_GetStatusText
        end function wxStatusBar_GetStatusText

        subroutine wxStatusBar_SetMinHeight(self, height) &
            bind(C, name="wxStatusBar_SetMinHeight")
            import :: c_ptr, c_int
            type(c_ptr), value :: self
            integer(c_int), value :: height
        end subroutine wxStatusBar_SetMinHeight

        !-----------------------------------------------------------------------
        ! wxMessageBox - standalone message box dialog
        !-----------------------------------------------------------------------
        function kwxMessageBox(message, caption, style, parent, x, y) &
            bind(C, name="kwxMessageBox")
            import :: c_ptr, c_int
            type(c_ptr), value :: message    ! wxString*
            type(c_ptr), value :: caption    ! wxString*
            integer(c_int), value :: style
            type(c_ptr), value :: parent     ! wxWindow* (can be null)
            integer(c_int), value :: x
            integer(c_int), value :: y
            integer(c_int) :: kwxMessageBox
        end function kwxMessageBox

    end interface

end module kwx_bindings
