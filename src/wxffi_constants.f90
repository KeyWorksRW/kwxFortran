! wxffi_constants.f90 - wxWidgets constants for Fortran
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides access to wxWidgets constants which are exported
! by kwxFFI as functions (e.g., expwxID_ANY() returns the value of wxID_ANY).
!
! Usage:
!   use wxffi_constants
!   integer :: my_style
!   my_style = wxDEFAULT_FRAME_STYLE()

module wxffi_constants
    use, intrinsic :: iso_c_binding
    implicit none
    private

    !---------------------------------------------------------------------------
    ! Common IDs
    !---------------------------------------------------------------------------
    public :: wxID_ANY, wxID_OK, wxID_CANCEL, wxID_YES, wxID_NO, wxID_APPLY
    public :: wxID_SAVE, wxID_SAVEAS, wxID_OPEN, wxID_CLOSE, wxID_NEW
    public :: wxID_EXIT, wxID_UNDO, wxID_REDO, wxID_HELP, wxID_ABOUT
    public :: wxID_PRINT, wxID_PREVIEW, wxID_CUT, wxID_COPY, wxID_PASTE
    public :: wxID_CLEAR, wxID_FIND, wxID_SELECTALL

    !---------------------------------------------------------------------------
    ! Frame styles
    !---------------------------------------------------------------------------
    public :: wxDEFAULT_FRAME_STYLE
    public :: wxCAPTION, wxMINIMIZE_BOX, wxMAXIMIZE_BOX, wxCLOSE_BOX
    public :: wxRESIZE_BORDER, wxSYSTEM_MENU
    public :: wxSTAY_ON_TOP, wxFRAME_TOOL_WINDOW, wxFRAME_NO_TASKBAR

    !---------------------------------------------------------------------------
    ! Alignment and stretch flags
    !---------------------------------------------------------------------------
    public :: wxALIGN_LEFT, wxALIGN_RIGHT, wxALIGN_TOP, wxALIGN_BOTTOM
    public :: wxALIGN_CENTER, wxALIGN_CENTER_HORIZONTAL, wxALIGN_CENTER_VERTICAL
    public :: wxEXPAND, wxGROW, wxSHRINK, wxSHAPED, wxFIXED_MINSIZE

    !---------------------------------------------------------------------------
    ! Direction/orientation
    !---------------------------------------------------------------------------
    public :: wxHORIZONTAL, wxVERTICAL, wxBOTH
    public :: wxLEFT, wxRIGHT, wxUP, wxDOWN, wxTOP, wxBOTTOM, wxALL

    !---------------------------------------------------------------------------
    ! Special values
    !---------------------------------------------------------------------------
    public :: wxDefaultCoord

    interface

        !-----------------------------------------------------------------------
        ! Common IDs
        !-----------------------------------------------------------------------
        function wxID_ANY() bind(C, name="expwxID_ANY")
            import :: c_int
            integer(c_int) :: wxID_ANY
        end function wxID_ANY

        function wxID_OK() bind(C, name="expwxID_OK")
            import :: c_int
            integer(c_int) :: wxID_OK
        end function wxID_OK

        function wxID_CANCEL() bind(C, name="expwxID_CANCEL")
            import :: c_int
            integer(c_int) :: wxID_CANCEL
        end function wxID_CANCEL

        function wxID_YES() bind(C, name="expwxID_YES")
            import :: c_int
            integer(c_int) :: wxID_YES
        end function wxID_YES

        function wxID_NO() bind(C, name="expwxID_NO")
            import :: c_int
            integer(c_int) :: wxID_NO
        end function wxID_NO

        function wxID_APPLY() bind(C, name="expwxID_APPLY")
            import :: c_int
            integer(c_int) :: wxID_APPLY
        end function wxID_APPLY

        function wxID_SAVE() bind(C, name="expwxID_SAVE")
            import :: c_int
            integer(c_int) :: wxID_SAVE
        end function wxID_SAVE

        function wxID_SAVEAS() bind(C, name="expwxID_SAVEAS")
            import :: c_int
            integer(c_int) :: wxID_SAVEAS
        end function wxID_SAVEAS

        function wxID_OPEN() bind(C, name="expwxID_OPEN")
            import :: c_int
            integer(c_int) :: wxID_OPEN
        end function wxID_OPEN

        function wxID_CLOSE() bind(C, name="expwxID_CLOSE")
            import :: c_int
            integer(c_int) :: wxID_CLOSE
        end function wxID_CLOSE

        function wxID_NEW() bind(C, name="expwxID_NEW")
            import :: c_int
            integer(c_int) :: wxID_NEW
        end function wxID_NEW

        function wxID_EXIT() bind(C, name="expwxID_EXIT")
            import :: c_int
            integer(c_int) :: wxID_EXIT
        end function wxID_EXIT

        function wxID_UNDO() bind(C, name="expwxID_UNDO")
            import :: c_int
            integer(c_int) :: wxID_UNDO
        end function wxID_UNDO

        function wxID_REDO() bind(C, name="expwxID_REDO")
            import :: c_int
            integer(c_int) :: wxID_REDO
        end function wxID_REDO

        function wxID_HELP() bind(C, name="expwxID_HELP")
            import :: c_int
            integer(c_int) :: wxID_HELP
        end function wxID_HELP

        function wxID_ABOUT() bind(C, name="expwxID_ABOUT")
            import :: c_int
            integer(c_int) :: wxID_ABOUT
        end function wxID_ABOUT

        function wxID_PRINT() bind(C, name="expwxID_PRINT")
            import :: c_int
            integer(c_int) :: wxID_PRINT
        end function wxID_PRINT

        function wxID_PREVIEW() bind(C, name="expwxID_PREVIEW")
            import :: c_int
            integer(c_int) :: wxID_PREVIEW
        end function wxID_PREVIEW

        function wxID_CUT() bind(C, name="expwxID_CUT")
            import :: c_int
            integer(c_int) :: wxID_CUT
        end function wxID_CUT

        function wxID_COPY() bind(C, name="expwxID_COPY")
            import :: c_int
            integer(c_int) :: wxID_COPY
        end function wxID_COPY

        function wxID_PASTE() bind(C, name="expwxID_PASTE")
            import :: c_int
            integer(c_int) :: wxID_PASTE
        end function wxID_PASTE

        function wxID_CLEAR() bind(C, name="expwxID_CLEAR")
            import :: c_int
            integer(c_int) :: wxID_CLEAR
        end function wxID_CLEAR

        function wxID_FIND() bind(C, name="expwxID_FIND")
            import :: c_int
            integer(c_int) :: wxID_FIND
        end function wxID_FIND

        function wxID_SELECTALL() bind(C, name="expwxID_SELECTALL")
            import :: c_int
            integer(c_int) :: wxID_SELECTALL
        end function wxID_SELECTALL

        !-----------------------------------------------------------------------
        ! Frame styles
        !-----------------------------------------------------------------------
        function wxDEFAULT_FRAME_STYLE() bind(C, name="expwxDEFAULT_FRAME_STYLE")
            import :: c_int
            integer(c_int) :: wxDEFAULT_FRAME_STYLE
        end function wxDEFAULT_FRAME_STYLE

        function wxCAPTION() bind(C, name="expwxCAPTION")
            import :: c_int
            integer(c_int) :: wxCAPTION
        end function wxCAPTION

        function wxMINIMIZE_BOX() bind(C, name="expwxMINIMIZE_BOX")
            import :: c_int
            integer(c_int) :: wxMINIMIZE_BOX
        end function wxMINIMIZE_BOX

        function wxMAXIMIZE_BOX() bind(C, name="expwxMAXIMIZE_BOX")
            import :: c_int
            integer(c_int) :: wxMAXIMIZE_BOX
        end function wxMAXIMIZE_BOX

        function wxCLOSE_BOX() bind(C, name="expwxCLOSE_BOX")
            import :: c_int
            integer(c_int) :: wxCLOSE_BOX
        end function wxCLOSE_BOX

        function wxRESIZE_BORDER() bind(C, name="expwxRESIZE_BORDER")
            import :: c_int
            integer(c_int) :: wxRESIZE_BORDER
        end function wxRESIZE_BORDER

        function wxSYSTEM_MENU() bind(C, name="expwxSYSTEM_MENU")
            import :: c_int
            integer(c_int) :: wxSYSTEM_MENU
        end function wxSYSTEM_MENU

        function wxSTAY_ON_TOP() bind(C, name="expwxSTAY_ON_TOP")
            import :: c_int
            integer(c_int) :: wxSTAY_ON_TOP
        end function wxSTAY_ON_TOP

        function wxFRAME_TOOL_WINDOW() bind(C, name="expwxFRAME_TOOL_WINDOW")
            import :: c_int
            integer(c_int) :: wxFRAME_TOOL_WINDOW
        end function wxFRAME_TOOL_WINDOW

        function wxFRAME_NO_TASKBAR() bind(C, name="expwxFRAME_NO_TASKBAR")
            import :: c_int
            integer(c_int) :: wxFRAME_NO_TASKBAR
        end function wxFRAME_NO_TASKBAR

        !-----------------------------------------------------------------------
        ! Alignment and stretch flags
        !-----------------------------------------------------------------------
        function wxALIGN_LEFT() bind(C, name="expwxALIGN_LEFT")
            import :: c_int
            integer(c_int) :: wxALIGN_LEFT
        end function wxALIGN_LEFT

        function wxALIGN_RIGHT() bind(C, name="expwxALIGN_RIGHT")
            import :: c_int
            integer(c_int) :: wxALIGN_RIGHT
        end function wxALIGN_RIGHT

        function wxALIGN_TOP() bind(C, name="expwxALIGN_TOP")
            import :: c_int
            integer(c_int) :: wxALIGN_TOP
        end function wxALIGN_TOP

        function wxALIGN_BOTTOM() bind(C, name="expwxALIGN_BOTTOM")
            import :: c_int
            integer(c_int) :: wxALIGN_BOTTOM
        end function wxALIGN_BOTTOM

        function wxALIGN_CENTER() bind(C, name="expwxALIGN_CENTER")
            import :: c_int
            integer(c_int) :: wxALIGN_CENTER
        end function wxALIGN_CENTER

        function wxALIGN_CENTER_HORIZONTAL() bind(C, name="expwxALIGN_CENTER_HORIZONTAL")
            import :: c_int
            integer(c_int) :: wxALIGN_CENTER_HORIZONTAL
        end function wxALIGN_CENTER_HORIZONTAL

        function wxALIGN_CENTER_VERTICAL() bind(C, name="expwxALIGN_CENTER_VERTICAL")
            import :: c_int
            integer(c_int) :: wxALIGN_CENTER_VERTICAL
        end function wxALIGN_CENTER_VERTICAL

        function wxEXPAND() bind(C, name="expwxEXPAND")
            import :: c_int
            integer(c_int) :: wxEXPAND
        end function wxEXPAND

        function wxGROW() bind(C, name="expwxGROW")
            import :: c_int
            integer(c_int) :: wxGROW
        end function wxGROW

        function wxSHRINK() bind(C, name="expwxSHRINK")
            import :: c_int
            integer(c_int) :: wxSHRINK
        end function wxSHRINK

        function wxSHAPED() bind(C, name="expwxSHAPED")
            import :: c_int
            integer(c_int) :: wxSHAPED
        end function wxSHAPED

        function wxFIXED_MINSIZE() bind(C, name="expwxFIXED_MINSIZE")
            import :: c_int
            integer(c_int) :: wxFIXED_MINSIZE
        end function wxFIXED_MINSIZE

        !-----------------------------------------------------------------------
        ! Direction/orientation
        !-----------------------------------------------------------------------
        function wxHORIZONTAL() bind(C, name="expwxHORIZONTAL")
            import :: c_int
            integer(c_int) :: wxHORIZONTAL
        end function wxHORIZONTAL

        function wxVERTICAL() bind(C, name="expwxVERTICAL")
            import :: c_int
            integer(c_int) :: wxVERTICAL
        end function wxVERTICAL

        function wxBOTH() bind(C, name="expwxBOTH")
            import :: c_int
            integer(c_int) :: wxBOTH
        end function wxBOTH

        function wxLEFT() bind(C, name="expwxLEFT")
            import :: c_int
            integer(c_int) :: wxLEFT
        end function wxLEFT

        function wxRIGHT() bind(C, name="expwxRIGHT")
            import :: c_int
            integer(c_int) :: wxRIGHT
        end function wxRIGHT

        function wxUP() bind(C, name="expwxUP")
            import :: c_int
            integer(c_int) :: wxUP
        end function wxUP

        function wxDOWN() bind(C, name="expwxDOWN")
            import :: c_int
            integer(c_int) :: wxDOWN
        end function wxDOWN

        function wxTOP() bind(C, name="expwxTOP")
            import :: c_int
            integer(c_int) :: wxTOP
        end function wxTOP

        function wxBOTTOM() bind(C, name="expwxBOTTOM")
            import :: c_int
            integer(c_int) :: wxBOTTOM
        end function wxBOTTOM

        function wxALL() bind(C, name="expwxALL")
            import :: c_int
            integer(c_int) :: wxALL
        end function wxALL

        !-----------------------------------------------------------------------
        ! Special values
        !-----------------------------------------------------------------------
        function wxDefaultCoord() bind(C, name="expwxDefaultCoord")
            import :: c_int
            integer(c_int) :: wxDefaultCoord
        end function wxDefaultCoord

    end interface

end module wxffi_constants
