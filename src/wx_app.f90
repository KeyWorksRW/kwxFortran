! wx_app.f90 - Fortran wrapper for wxWidgets application lifecycle
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides a high-level Fortran interface to the kwxApp functions.
! It handles string conversions and provides idiomatic Fortran function signatures.
!
! Usage:
!   use wx_app
!   call wx_initialize()
!   ! ... create windows ...
!   call wx_main_loop()

module wx_app
    use, intrinsic :: iso_c_binding
    use kwx_types
    implicit none
    private

    ! Initialization and main loop
    public :: wx_initialize, wx_main_loop, wx_exit_main_loop
    public :: wx_shutdown, wx_is_terminating

    ! Application properties
    public :: wx_set_app_name, wx_get_app_name
    public :: wx_set_vendor_name, wx_get_vendor_name
    public :: wx_set_top_window, wx_get_top_window
    public :: wx_set_exit_on_frame_delete, wx_get_exit_on_frame_delete

    ! System information
    public :: wx_get_display_size, wx_get_mouse_position

    ! Event processing
    public :: wx_pending, wx_dispatch, wx_yield, wx_safe_yield

    ! Utilities
    public :: wx_init_all_image_handlers, wx_bell
    public :: wx_sleep, wx_milli_sleep
    public :: wx_enable_tooltips, wx_set_tooltip_delay
    public :: wx_get_os_version
    public :: wx_get_os_description, wx_get_user_id, wx_get_user_name
    public :: wx_find_window_by_id, wx_find_window_by_label, wx_find_window_by_name
    public :: wx_set_idle_callback, wx_get_idle_interval

    !---------------------------------------------------------------------------
    ! Private C bindings for kwxApp_* functions (from kwxApp.cpp, not in kwxFFI)
    !---------------------------------------------------------------------------
    interface
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

        function kwxApp_GetOsVersion(major, minor) bind(C, name="kwxApp_GetOsVersion")
            import :: c_ptr, c_int
            type(c_ptr), value :: major, minor
            integer(c_int) :: kwxApp_GetOsVersion
        end function kwxApp_GetOsVersion

        function kwxApp_GetOsDescription() bind(C, name="kwxApp_GetOsDescription")
            import :: c_ptr
            type(c_ptr) :: kwxApp_GetOsDescription
        end function kwxApp_GetOsDescription

        function kwxApp_GetUserId() bind(C, name="kwxApp_GetUserId")
            import :: c_ptr
            type(c_ptr) :: kwxApp_GetUserId
        end function kwxApp_GetUserId

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

        function kwxApp_FindWindowById(id, parent) bind(C, name="kwxApp_FindWindowById")
            import :: c_ptr, c_int
            integer(c_int), value :: id
            type(c_ptr), value :: parent
            type(c_ptr) :: kwxApp_FindWindowById
        end function kwxApp_FindWindowById

        function kwxApp_FindWindowByLabel(label, parent) &
            bind(C, name="kwxApp_FindWindowByLabel")
            import :: c_ptr
            type(c_ptr), value :: label, parent
            type(c_ptr) :: kwxApp_FindWindowByLabel
        end function kwxApp_FindWindowByLabel

        function kwxApp_FindWindowByName(name, parent) &
            bind(C, name="kwxApp_FindWindowByName")
            import :: c_ptr
            type(c_ptr), value :: name, parent
            type(c_ptr) :: kwxApp_FindWindowByName
        end function kwxApp_FindWindowByName

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
    end interface

contains

    !---------------------------------------------------------------------------
    ! Initialize wxWidgets application
    ! Returns .true. on success, .false. on failure
    !---------------------------------------------------------------------------
    function wx_initialize() result(success)
        logical :: success
        integer(c_int) :: result

        ! Call with no command line args (0, NULL)
        result = kwxApp_Initialize(0_c_int, c_null_ptr)
        success = (result /= 0)
    end function wx_initialize

    !---------------------------------------------------------------------------
    ! Run the main event loop
    ! Returns the application exit code
    !---------------------------------------------------------------------------
    function wx_main_loop() result(exit_code)
        integer :: exit_code

        exit_code = int(kwxApp_MainLoop())
    end function wx_main_loop

    !---------------------------------------------------------------------------
    ! Exit the main event loop (call from an event handler)
    !---------------------------------------------------------------------------
    subroutine wx_exit_main_loop()
        call kwxApp_ExitMainLoop()
    end subroutine wx_exit_main_loop

    !---------------------------------------------------------------------------
    ! Shutdown wxWidgets and clean up
    !---------------------------------------------------------------------------
    subroutine wx_shutdown()
        call kwxApp_Shutdown()
    end subroutine wx_shutdown

    !---------------------------------------------------------------------------
    ! Check if the application is terminating
    !---------------------------------------------------------------------------
    function wx_is_terminating() result(terminating)
        logical :: terminating

        terminating = (kwxApp_IsTerminating() /= 0)
    end function wx_is_terminating

    !---------------------------------------------------------------------------
    ! Set application name (shown in dialogs, config files, etc.)
    !---------------------------------------------------------------------------
    subroutine wx_set_app_name(name)
        character(len=*), intent(in) :: name
        character(len=:, kind=c_char), allocatable :: c_name

        c_name = trim(name) // c_null_char
        call kwxApp_SetAppName(c_name)
    end subroutine wx_set_app_name

    !---------------------------------------------------------------------------
    ! Get application name
    !---------------------------------------------------------------------------
    function wx_get_app_name() result(name)
        character(len=:), allocatable :: name
        type(c_ptr) :: c_str_ptr
        character(kind=c_char), pointer :: c_str_array(:)
        integer :: i, len

        c_str_ptr = kwxApp_GetAppName()
        if (.not. c_associated(c_str_ptr)) then
            name = ""
            return
        end if

        ! Find string length by searching for null terminator
        len = 0
        call c_f_pointer(c_str_ptr, c_str_array, [1024])  ! Max reasonable length
        do i = 1, 1024
            if (c_str_array(i) == c_null_char) exit
            len = len + 1
        end do

        allocate(character(len=len) :: name)
        do i = 1, len
            name(i:i) = c_str_array(i)
        end do
    end function wx_get_app_name

    !---------------------------------------------------------------------------
    ! Set vendor name
    !---------------------------------------------------------------------------
    subroutine wx_set_vendor_name(name)
        character(len=*), intent(in) :: name
        character(len=:, kind=c_char), allocatable :: c_name

        c_name = trim(name) // c_null_char
        call kwxApp_SetVendorName(c_name)
    end subroutine wx_set_vendor_name

    !---------------------------------------------------------------------------
    ! Get vendor name
    !---------------------------------------------------------------------------
    function wx_get_vendor_name() result(name)
        character(len=:), allocatable :: name
        type(c_ptr) :: c_str_ptr
        character(kind=c_char), pointer :: c_str_array(:)
        integer :: i, len

        c_str_ptr = kwxApp_GetVendorName()
        if (.not. c_associated(c_str_ptr)) then
            name = ""
            return
        end if

        ! Find string length by searching for null terminator
        len = 0
        call c_f_pointer(c_str_ptr, c_str_array, [1024])
        do i = 1, 1024
            if (c_str_array(i) == c_null_char) exit
            len = len + 1
        end do

        allocate(character(len=len) :: name)
        do i = 1, len
            name(i:i) = c_str_array(i)
        end do
    end function wx_get_vendor_name

    !---------------------------------------------------------------------------
    ! Set top-level window
    !---------------------------------------------------------------------------
    subroutine wx_set_top_window(window)
        class(wxWindow_t), intent(in) :: window

        call kwxApp_SetTopWindow(window%ptr)
    end subroutine wx_set_top_window

    !---------------------------------------------------------------------------
    ! Get top-level window
    !---------------------------------------------------------------------------
    function wx_get_top_window() result(window)
        type(wxWindow_t) :: window

        window%ptr = kwxApp_GetTopWindow()
    end function wx_get_top_window

    !---------------------------------------------------------------------------
    ! Set whether app exits when last frame is deleted
    !---------------------------------------------------------------------------
    subroutine wx_set_exit_on_frame_delete(flag)
        logical, intent(in) :: flag
        integer(c_int) :: c_flag

        if (flag) then
            c_flag = 1
        else
            c_flag = 0
        end if
        call kwxApp_SetExitOnFrameDelete(c_flag)
    end subroutine wx_set_exit_on_frame_delete

    !---------------------------------------------------------------------------
    ! Get whether app exits when last frame is deleted
    !---------------------------------------------------------------------------
    function wx_get_exit_on_frame_delete() result(flag)
        logical :: flag

        flag = (kwxApp_GetExitOnFrameDelete() /= 0)
    end function wx_get_exit_on_frame_delete

    !---------------------------------------------------------------------------
    ! Get display size in pixels
    !---------------------------------------------------------------------------
    subroutine wx_get_display_size(width, height)
        integer, intent(out) :: width, height
        integer(c_int) :: c_width, c_height

        call kwxApp_GetDisplaySize(c_width, c_height)
        width = int(c_width)
        height = int(c_height)
    end subroutine wx_get_display_size

    !---------------------------------------------------------------------------
    ! Get current mouse position
    !---------------------------------------------------------------------------
    subroutine wx_get_mouse_position(x, y)
        integer, intent(out) :: x, y
        integer(c_int) :: c_x, c_y

        call kwxApp_GetMousePosition(c_x, c_y)
        x = int(c_x)
        y = int(c_y)
    end subroutine wx_get_mouse_position

    !---------------------------------------------------------------------------
    ! Check if there are pending events
    !---------------------------------------------------------------------------
    function wx_pending() result(has_pending)
        logical :: has_pending

        has_pending = (kwxApp_Pending() /= 0)
    end function wx_pending

    !---------------------------------------------------------------------------
    ! Dispatch the next event
    !---------------------------------------------------------------------------
    subroutine wx_dispatch()
        call kwxApp_Dispatch()
    end subroutine wx_dispatch

    !---------------------------------------------------------------------------
    ! Yield to allow pending events to be processed
    !---------------------------------------------------------------------------
    function wx_yield() result(yielded)
        logical :: yielded

        yielded = (kwxApp_Yield() /= 0)
    end function wx_yield

    !---------------------------------------------------------------------------
    ! Safe yield (for use from event handlers)
    !---------------------------------------------------------------------------
    function wx_safe_yield(window) result(yielded)
        type(wxWindow_t), intent(in), optional :: window
        logical :: yielded
        type(c_ptr) :: win_ptr

        if (present(window)) then
            win_ptr = window%ptr
        else
            win_ptr = c_null_ptr
        end if
        yielded = (kwxApp_SafeYield(win_ptr) /= 0)
    end function wx_safe_yield

    !---------------------------------------------------------------------------
    ! Initialize all image handlers (PNG, JPEG, etc.)
    !---------------------------------------------------------------------------
    subroutine wx_init_all_image_handlers()
        call kwxApp_InitAllImageHandlers()
    end subroutine wx_init_all_image_handlers

    !---------------------------------------------------------------------------
    ! System bell
    !---------------------------------------------------------------------------
    subroutine wx_bell()
        call kwxApp_Bell()
    end subroutine wx_bell

    !---------------------------------------------------------------------------
    ! Sleep for a given number of seconds
    !---------------------------------------------------------------------------
    subroutine wx_sleep(seconds)
        integer, intent(in) :: seconds
        call kwxApp_Sleep(int(seconds, c_int))
    end subroutine wx_sleep

    !---------------------------------------------------------------------------
    ! Sleep for a given number of milliseconds
    !---------------------------------------------------------------------------
    subroutine wx_milli_sleep(milliseconds)
        integer, intent(in) :: milliseconds
        call kwxApp_MilliSleep(int(milliseconds, c_int))
    end subroutine wx_milli_sleep

    !---------------------------------------------------------------------------
    ! Enable or disable tooltips globally
    !---------------------------------------------------------------------------
    subroutine wx_enable_tooltips(enable)
        logical, intent(in) :: enable
        integer(c_int) :: c_enable

        c_enable = 0
        if (enable) c_enable = 1
        call kwxApp_EnableTooltips(c_enable)
    end subroutine wx_enable_tooltips

    !---------------------------------------------------------------------------
    ! Set tooltip delay in milliseconds
    !---------------------------------------------------------------------------
    subroutine wx_set_tooltip_delay(milliseconds)
        integer, intent(in) :: milliseconds
        call kwxApp_SetTooltipDelay(int(milliseconds, c_int))
    end subroutine wx_set_tooltip_delay

    !---------------------------------------------------------------------------
    ! Get OS version
    ! Returns OS type integer; major/minor are optional output integers
    !---------------------------------------------------------------------------
    function wx_get_os_version(major, minor) result(os_type)
        integer, intent(out), optional :: major, minor
        integer :: os_type
        integer(c_int), target :: c_major, c_minor
        type(c_ptr) :: p_major, p_minor

        ! Pass pointers if caller wants the values
        if (present(major)) then
            p_major = c_loc(c_major)
        else
            p_major = c_null_ptr
        end if
        if (present(minor)) then
            p_minor = c_loc(c_minor)
        else
            p_minor = c_null_ptr
        end if

        os_type = int(kwxApp_GetOsVersion(p_major, p_minor))
        if (present(major)) major = int(c_major)
        if (present(minor)) minor = int(c_minor)
    end function wx_get_os_version

    !---------------------------------------------------------------------------
    ! Get OS description string
    !---------------------------------------------------------------------------
    function wx_get_os_description() result(desc)
        use, intrinsic :: iso_c_binding, only: c_ptr, c_f_pointer, c_null_char
        character(len=:), allocatable :: desc
        type(c_ptr) :: c_str
        character(kind=c_char, len=512), pointer :: f_str
        integer :: n

        c_str = kwxApp_GetOsDescription()
        if (.not. c_associated(c_str)) then
            desc = ""
            return
        end if
        call c_f_pointer(c_str, f_str)
        n = index(f_str, c_null_char) - 1
        if (n <= 0) n = len(f_str)
        desc = f_str(1:n)
        call kwxApp_FreeString(c_str)
    end function wx_get_os_description

    !---------------------------------------------------------------------------
    ! Get user login ID
    !---------------------------------------------------------------------------
    function wx_get_user_id() result(uid)
        use, intrinsic :: iso_c_binding, only: c_ptr, c_f_pointer, c_null_char
        character(len=:), allocatable :: uid
        type(c_ptr) :: c_str
        character(kind=c_char, len=256), pointer :: f_str
        integer :: n

        c_str = kwxApp_GetUserId()
        if (.not. c_associated(c_str)) then
            uid = ""
            return
        end if
        call c_f_pointer(c_str, f_str)
        n = index(f_str, c_null_char) - 1
        if (n <= 0) n = len(f_str)
        uid = f_str(1:n)
        call kwxApp_FreeString(c_str)
    end function wx_get_user_id

    !---------------------------------------------------------------------------
    ! Get user display name
    !---------------------------------------------------------------------------
    function wx_get_user_name() result(uname)
        use, intrinsic :: iso_c_binding, only: c_ptr, c_f_pointer, c_null_char
        character(len=:), allocatable :: uname
        type(c_ptr) :: c_str
        character(kind=c_char, len=256), pointer :: f_str
        integer :: n

        c_str = kwxApp_GetUserName()
        if (.not. c_associated(c_str)) then
            uname = ""
            return
        end if
        call c_f_pointer(c_str, f_str)
        n = index(f_str, c_null_char) - 1
        if (n <= 0) n = len(f_str)
        uname = f_str(1:n)
        call kwxApp_FreeString(c_str)
    end function wx_get_user_name

    !---------------------------------------------------------------------------
    ! Find a window by its integer ID
    ! parent: search only children of this window (optional, default: all windows)
    ! Returns wxWindow_t (check %is_valid() before use)
    !---------------------------------------------------------------------------
    function wx_find_window_by_id(id, parent) result(window)
        integer, intent(in) :: id
        type(wxWindow_t), intent(in), optional :: parent
        type(wxWindow_t) :: window
        type(c_ptr) :: parent_ptr

        if (present(parent)) then
            parent_ptr = parent%ptr
        else
            parent_ptr = c_null_ptr
        end if
        window%ptr = kwxApp_FindWindowById(int(id, c_int), parent_ptr)
    end function wx_find_window_by_id

    !---------------------------------------------------------------------------
    ! Find a window by its user-visible label
    !---------------------------------------------------------------------------
    function wx_find_window_by_label(label, parent) result(window)
        character(len=*), intent(in) :: label
        type(wxWindow_t), intent(in), optional :: parent
        type(wxWindow_t) :: window
        type(c_ptr) :: parent_ptr
        ! Convert to null-terminated C string
        character(kind=c_char, len=len(label)+1), target :: c_label

        c_label = label // c_null_char
        if (present(parent)) then
            parent_ptr = parent%ptr
        else
            parent_ptr = c_null_ptr
        end if
        window%ptr = kwxApp_FindWindowByLabel(c_loc(c_label), parent_ptr)
    end function wx_find_window_by_label

    !---------------------------------------------------------------------------
    ! Find a window by its programmatic name (set with SetName)
    !---------------------------------------------------------------------------
    function wx_find_window_by_name(name, parent) result(window)
        character(len=*), intent(in) :: name
        type(wxWindow_t), intent(in), optional :: parent
        type(wxWindow_t) :: window
        type(c_ptr) :: parent_ptr
        character(kind=c_char, len=len(name)+1), target :: c_name

        c_name = name // c_null_char
        if (present(parent)) then
            parent_ptr = parent%ptr
        else
            parent_ptr = c_null_ptr
        end if
        window%ptr = kwxApp_FindWindowByName(c_loc(c_name), parent_ptr)
    end function wx_find_window_by_name

    !---------------------------------------------------------------------------
    ! Set idle callback
    ! interval_ms: polling interval in ms (0 = disabled)
    ! callback:    c_funptr to a subroutine(data) bind(C) — one-arg idle callback
    ! data:        optional opaque data pointer passed to callback
    !---------------------------------------------------------------------------
    subroutine wx_set_idle_callback(interval_ms, callback, data)
        integer, intent(in) :: interval_ms
        type(c_funptr), intent(in), value :: callback
        type(c_ptr), intent(in), optional :: data
        type(c_ptr) :: data_ptr

        data_ptr = c_null_ptr
        if (present(data)) data_ptr = data
        call kwxApp_SetIdleCallback(int(interval_ms, c_int), callback, data_ptr)
    end subroutine wx_set_idle_callback

    !---------------------------------------------------------------------------
    ! Get current idle callback interval (0 if disabled)
    !---------------------------------------------------------------------------
    function wx_get_idle_interval() result(interval_ms)
        integer :: interval_ms
        interval_ms = int(kwxApp_GetIdleInterval())
    end function wx_get_idle_interval

end module wx_app
