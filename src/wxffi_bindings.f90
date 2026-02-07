! wxffi_bindings.f90 - Raw C bindings for wxFFI functions
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

module wxffi_bindings
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

    !---------------------------------------------------------------------------
    ! wxFrame functions
    !---------------------------------------------------------------------------
    public :: wxFrame_Create
    public :: wxFrame_CreateStatusBar, wxFrame_GetStatusBar, wxFrame_SetStatusBar
    public :: wxFrame_SetStatusText, wxFrame_SetStatusWidths
    public :: wxFrame_CreateToolBar, wxFrame_GetToolBar, wxFrame_SetToolBar
    public :: wxFrame_GetMenuBar, wxFrame_SetMenuBar
    public :: wxFrame_Restore
    public :: wxFrame_GetClientAreaOrigin_left, wxFrame_GetClientAreaOrigin_top

    !---------------------------------------------------------------------------
    ! wxWindow functions (base class for all UI elements)
    !---------------------------------------------------------------------------
    public :: wxWindow_Create, wxWindow_Destroy, wxWindow_DestroyChildren
    public :: wxWindow_Close, wxWindow_Show, wxWindow_Hide
    public :: wxWindow_Enable, wxWindow_Disable, wxWindow_IsEnabled, wxWindow_IsShown
    public :: wxWindow_SetSize, wxWindow_GetSize, wxWindow_GetPosition
    public :: wxWindow_SetPosition, wxWindow_Move
    public :: wxWindow_GetClientSize, wxWindow_SetClientSize
    public :: wxWindow_GetBestSize, wxWindow_GetEffectiveMinSize
    public :: wxWindow_GetId, wxWindow_SetId
    public :: wxWindow_GetLabel, wxWindow_SetLabel
    public :: wxWindow_GetName, wxWindow_SetName
    public :: wxWindow_GetParent, wxWindow_GetTopLevelParent
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

        subroutine wxWindow_SetPosition(window, point) bind(C, name="wxWindow_SetPosition")
            import :: c_ptr
            type(c_ptr), value :: window, point
        end subroutine wxWindow_SetPosition

        subroutine wxWindow_Move(window, x, y) bind(C, name="wxWindow_Move")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int), value :: x, y
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

        function wxWindow_GetTopLevelParent(window) &
            bind(C, name="wxWindow_GetTopLevelParent")
            import :: c_ptr
            type(c_ptr), value :: window
            type(c_ptr) :: wxWindow_GetTopLevelParent
        end function wxWindow_GetTopLevelParent

        subroutine wxWindow_SetFocus(window) bind(C, name="wxWindow_SetFocus")
            import :: c_ptr
            type(c_ptr), value :: window
        end subroutine wxWindow_SetFocus

        function wxWindow_HasFocus(window) bind(C, name="wxWindow_HasFocus")
            import :: c_ptr, c_int
            type(c_ptr), value :: window
            integer(c_int) :: wxWindow_HasFocus
        end function wxWindow_HasFocus

        subroutine wxWindow_Refresh(window, eraseBackground, rect) &
            bind(C, name="wxWindow_Refresh")
            import :: c_ptr, c_int
            type(c_ptr), value :: window, rect
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

    end interface

end module wxffi_bindings
