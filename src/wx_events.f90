! wx_events.f90 - Event handling wrappers for wxWidgets
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides an idiomatic Fortran interface for wxWidgets event
! handling. Events are connected using closures that route wxWidgets callbacks
! to Fortran procedures.
!
! Usage:
!   use wx_events
!   use kwx_constants
!
!   ! Define a handler with bind(C)
!   subroutine on_click(fun, data, evt) bind(C)
!       use, intrinsic :: iso_c_binding
!       type(c_ptr), value :: fun, data, evt
!       ! ... handle event ...
!   end subroutine
!
!   ! Connect it to a button
!   call wx_connect(button, wxEVT_BUTTON(), on_click)
!
! Event Handler Signature:
!   The callback procedure must match the ClosureFun C signature:
!     subroutine handler(fun, data, evt) bind(C)
!       type(c_ptr), value :: fun, data, evt
!     end subroutine
!   Where:
!     fun  - pointer to the function itself (can be ignored)
!     data - user data pointer passed to wx_connect (c_null_ptr if none)
!     evt  - pointer to the wxEvent object (use wx_event_* accessors)

module wx_events
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, wxClosure_C_ptr => wxClosure_Create  ! rename to keep our c_funptr version below
    use wx_string, only: to_wxstring, from_wxstring
    implicit none
    private

    ! Connection
    public :: wx_connect, wx_disconnect

    ! Event accessors (base wxEvent)
    public :: wx_event_get_id, wx_event_get_type, wx_event_skip
    public :: wx_event_get_timestamp, wx_event_get_skipped
    public :: wx_event_is_command_event

    ! Command event accessors
    public :: wx_command_event_get_string
    public :: wx_command_event_get_selection
    public :: wx_command_event_get_int
    public :: wx_command_event_get_extra_long
    public :: wx_command_event_is_checked
    public :: wx_command_event_is_selection

    ! Abstract callback interface
    abstract interface
        subroutine event_callback(fun, data, evt) bind(C)
            import :: c_ptr
            type(c_ptr), value :: fun, data, evt
        end subroutine event_callback
    end interface

    ! Make the abstract interface public so users can declare handler procedures
    public :: event_callback

    !---------------------------------------------------------------------------
    ! Private C bindings for wxClosure (not in generated kwxffi module)
    !---------------------------------------------------------------------------
    interface
        ! Create a closure that wraps a foreign function pointer and user data
        function wxClosure_Create(fun, data) bind(C, name="wxClosure_Create")
            import :: c_ptr, c_funptr
            type(c_funptr), value :: fun
            type(c_ptr), value :: data
            type(c_ptr) :: wxClosure_Create
        end function wxClosure_Create
    end interface

contains

    !===========================================================================
    ! Event Connection
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Connect an event handler to a window/control
    !
    ! Parameters:
    !   window     - The window/control to connect to (required)
    !   event_type - Event type constant, e.g. wxEVT_BUTTON()
    !   handler    - Fortran procedure matching event_callback interface
    !   user_data  - Optional user data pointer (default: c_null_ptr)
    !   id         - Optional window ID to match (default: wxID_ANY)
    !   last_id    - Optional last ID for range (default: same as id)
    !
    ! Example:
    !   call wx_connect(button, wxEVT_BUTTON(), on_click)
    !   call wx_connect(frame, wxEVT_MENU(), on_menu, id=101)
    !---------------------------------------------------------------------------
    subroutine wx_connect(window, event_type, handler, user_data, id, last_id)
        class(wxWindow_t), intent(in) :: window
        integer, intent(in) :: event_type
        procedure(event_callback) :: handler
        type(c_ptr), intent(in), optional :: user_data
        integer, intent(in), optional :: id
        integer, intent(in), optional :: last_id

        type(c_funptr) :: fptr
        type(c_ptr) :: data_ptr
        integer(c_int) :: c_first, c_last, c_type, dummy

        ! Get function pointer from Fortran procedure
        fptr = c_funloc(handler)

        ! Set user data
        if (present(user_data)) then
            data_ptr = user_data
        else
            data_ptr = c_null_ptr
        end if

        ! Set ID range
        if (present(id)) then
            c_first = int(id, c_int)
        else
            c_first = -1_c_int
        end if

        if (present(last_id)) then
            c_last = int(last_id, c_int)
        else
            c_last = c_first
        end if

        c_type = int(event_type, c_int)

        ! Connect — create a wxClosure wrapping fun+data, then connect it
        ! wxClosure_Create(fun, data) returns wxClosure* owned by wxCallback
        dummy = wxEvtHandler_Connect(window%ptr, c_first, c_last, c_type, &
            wxClosure_Create(fptr, data_ptr))
    end subroutine wx_connect

    !---------------------------------------------------------------------------
    ! Disconnect an event handler from a window/control
    !
    ! Parameters:
    !   window     - The window/control to disconnect from
    !   event_type - Event type constant
    !   id         - Optional window ID (default: wxID_ANY)
    !   last_id    - Optional last ID for range (default: same as id)
    !---------------------------------------------------------------------------
    subroutine wx_disconnect(window, event_type, id, last_id)
        class(wxWindow_t), intent(in) :: window
        integer, intent(in) :: event_type
        integer, intent(in), optional :: id
        integer, intent(in), optional :: last_id

        integer(c_int) :: c_first, c_last, c_type, dummy

        if (present(id)) then
            c_first = int(id, c_int)
        else
            c_first = -1_c_int
        end if

        if (present(last_id)) then
            c_last = int(last_id, c_int)
        else
            c_last = c_first
        end if

        c_type = int(event_type, c_int)

        ! Disconnect — 5th arg is id filter, 0 matches any
        dummy = wxEvtHandler_Disconnect(window%ptr, c_first, c_last, c_type, 0_c_int)
    end subroutine wx_disconnect

    !===========================================================================
    ! wxEvent Accessors (base class)
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Get the window ID associated with the event
    !---------------------------------------------------------------------------
    function wx_event_get_id(evt) result(id)
        type(c_ptr), intent(in) :: evt
        integer :: id

        if (.not. c_associated(evt)) then
            id = 0
            return
        end if
        id = int(wxEvent_GetId(evt))
    end function wx_event_get_id

    !---------------------------------------------------------------------------
    ! Get the event type
    !---------------------------------------------------------------------------
    function wx_event_get_type(evt) result(event_type)
        type(c_ptr), intent(in) :: evt
        integer :: event_type

        if (.not. c_associated(evt)) then
            event_type = 0
            return
        end if
        event_type = int(wxEvent_GetEventType(evt))
    end function wx_event_get_type

    !---------------------------------------------------------------------------
    ! Mark event as skipped (allow parent handlers to process it)
    !---------------------------------------------------------------------------
    subroutine wx_event_skip(evt, skip)
        type(c_ptr), intent(in) :: evt
        logical, intent(in), optional :: skip
        integer(c_int) :: c_skip

        if (.not. c_associated(evt)) return
        c_skip = 1_c_int  ! Default: skip = true
        if (present(skip)) then
            if (.not. skip) c_skip = 0_c_int
        end if
        call wxEvent_Skip(evt, c_skip)
    end subroutine wx_event_skip

    !---------------------------------------------------------------------------
    ! Get event timestamp
    !---------------------------------------------------------------------------
    function wx_event_get_timestamp(evt) result(ts)
        type(c_ptr), intent(in) :: evt
        integer :: ts

        if (.not. c_associated(evt)) then
            ts = 0
            return
        end if
        ts = int(wxEvent_GetTimestamp(evt))
    end function wx_event_get_timestamp

    !---------------------------------------------------------------------------
    ! Check if event was skipped
    !---------------------------------------------------------------------------
    function wx_event_get_skipped(evt) result(skipped)
        type(c_ptr), intent(in) :: evt
        logical :: skipped

        if (.not. c_associated(evt)) then
            skipped = .false.
            return
        end if
        skipped = (wxEvent_GetSkipped(evt) /= 0)
    end function wx_event_get_skipped

    !---------------------------------------------------------------------------
    ! Check if event is a command event
    !---------------------------------------------------------------------------
    function wx_event_is_command_event(evt) result(is_cmd)
        type(c_ptr), intent(in) :: evt
        logical :: is_cmd

        if (.not. c_associated(evt)) then
            is_cmd = .false.
            return
        end if
        is_cmd = (wxEvent_IsCommandEvent(evt) /= 0)
    end function wx_event_is_command_event

    !===========================================================================
    ! wxCommandEvent Accessors
    !===========================================================================

    !---------------------------------------------------------------------------
    ! Get the string associated with a command event (e.g., text from a
    ! text control change event)
    !
    ! Returns: allocatable character string
    !---------------------------------------------------------------------------
    function wx_command_event_get_string(evt) result(str)
        type(c_ptr), intent(in) :: evt
        character(len=:), allocatable :: str

        type(c_ptr) :: ws_ptr

        if (.not. c_associated(evt)) then
            str = ''
            return
        end if
        ws_ptr = wxCommandEvent_GetString(evt)
        str = from_wxstring(ws_ptr)
        call wxString_Delete(ws_ptr)
    end function wx_command_event_get_string

    !---------------------------------------------------------------------------
    ! Get the selection index from a command event
    !---------------------------------------------------------------------------
    function wx_command_event_get_selection(evt) result(sel)
        type(c_ptr), intent(in) :: evt
        integer :: sel

        if (.not. c_associated(evt)) then
            sel = -1
            return
        end if
        sel = int(wxCommandEvent_GetSelection(evt))
    end function wx_command_event_get_selection

    !---------------------------------------------------------------------------
    ! Get the integer value from a command event
    !---------------------------------------------------------------------------
    function wx_command_event_get_int(evt) result(val)
        type(c_ptr), intent(in) :: evt
        integer :: val

        if (.not. c_associated(evt)) then
            val = 0
            return
        end if
        val = int(wxCommandEvent_GetInt(evt))
    end function wx_command_event_get_int

    !---------------------------------------------------------------------------
    ! Get the extra long value from a command event
    !---------------------------------------------------------------------------
    function wx_command_event_get_extra_long(evt) result(val)
        type(c_ptr), intent(in) :: evt
        integer :: val

        if (.not. c_associated(evt)) then
            val = 0
            return
        end if
        val = int(wxCommandEvent_GetExtraLong(evt))
    end function wx_command_event_get_extra_long

    !---------------------------------------------------------------------------
    ! Check if a checkbox/toggle event is checked
    !---------------------------------------------------------------------------
    function wx_command_event_is_checked(evt) result(checked)
        type(c_ptr), intent(in) :: evt
        logical :: checked

        if (.not. c_associated(evt)) then
            checked = .false.
            return
        end if
        checked = (wxCommandEvent_IsChecked(evt) /= 0)
    end function wx_command_event_is_checked

    !---------------------------------------------------------------------------
    ! Check if this is a selection event (vs deselection)
    !---------------------------------------------------------------------------
    function wx_command_event_is_selection(evt) result(is_sel)
        type(c_ptr), intent(in) :: evt
        logical :: is_sel

        if (.not. c_associated(evt)) then
            is_sel = .false.
            return
        end if
        is_sel = (wxCommandEvent_IsSelection(evt) /= 0)
    end function wx_command_event_is_selection

end module wx_events
