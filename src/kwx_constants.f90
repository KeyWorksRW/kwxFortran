! kwx_constants.f90 - wxWidgets constants for Fortran
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module provides access to wxWidgets constants which are exported
! by kwxFFI as functions (e.g., expwxID_ANY() returns the value of wxID_ANY).
!
! Usage:
!   use kwx_constants
!   integer :: my_style
!   my_style = wxDEFAULT_FRAME_STYLE()

module kwx_constants
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
    public :: wxEXPAND, wxGROW, wxSHRINK, wxSHAPED

    !---------------------------------------------------------------------------
    ! Direction/orientation
    !---------------------------------------------------------------------------
    public :: wxHORIZONTAL, wxVERTICAL, wxBOTH
    public :: wxLEFT, wxRIGHT, wxUP, wxDOWN, wxTOP, wxBOTTOM, wxALL

    !---------------------------------------------------------------------------
    ! TextCtrl styles
    !---------------------------------------------------------------------------
    public :: wxTE_READONLY, wxTE_MULTILINE, wxTE_PASSWORD, wxTE_PROCESS_ENTER

    !---------------------------------------------------------------------------
    ! Button styles
    !---------------------------------------------------------------------------
    public :: wxBU_EXACTFIT, wxBU_LEFT, wxBU_TOP, wxBU_RIGHT, wxBU_BOTTOM

    !---------------------------------------------------------------------------
    ! StaticText styles
    !---------------------------------------------------------------------------
    public :: wxST_NO_AUTORESIZE

    !---------------------------------------------------------------------------
    ! Window styles
    !---------------------------------------------------------------------------
    public :: wxTAB_TRAVERSAL

    !---------------------------------------------------------------------------
    ! Event types (command events)
    !---------------------------------------------------------------------------
    public :: wxEVT_BUTTON
    public :: wxEVT_CHECKBOX
    public :: wxEVT_CHOICE
    public :: wxEVT_TEXT
    public :: wxEVT_TEXT_ENTER
    public :: wxEVT_MENU

    !---------------------------------------------------------------------------
    ! Phase 5: Additional event types
    !---------------------------------------------------------------------------
    public :: wxEVT_LISTBOX
    public :: wxEVT_LISTBOX_DCLICK
    public :: wxEVT_RADIOBUTTON
    public :: wxEVT_COMBOBOX
    public :: wxEVT_TOOL
    public :: wxEVT_CLOSE_WINDOW

    !---------------------------------------------------------------------------
    ! ListBox styles
    !---------------------------------------------------------------------------
    public :: wxLB_SINGLE, wxLB_MULTIPLE, wxLB_EXTENDED, wxLB_SORT
    public :: wxLB_NEEDED_SB, wxLB_ALWAYS_SB

    !---------------------------------------------------------------------------
    ! ComboBox styles
    !---------------------------------------------------------------------------
    public :: wxCB_SIMPLE, wxCB_SORT, wxCB_READONLY, wxCB_DROPDOWN

    !---------------------------------------------------------------------------
    ! RadioButton styles
    !---------------------------------------------------------------------------
    public :: wxRB_GROUP

    !---------------------------------------------------------------------------
    ! Menu item kinds
    !---------------------------------------------------------------------------
    public :: wxITEM_SEPARATOR, wxITEM_NORMAL, wxITEM_CHECK, wxITEM_RADIO

    !---------------------------------------------------------------------------
    ! Toolbar styles
    !---------------------------------------------------------------------------
    public :: wxTB_HORIZONTAL, wxTB_VERTICAL, wxTB_FLAT
    public :: wxTB_TEXT, wxTB_NODIVIDER

    !---------------------------------------------------------------------------
    ! StatusBar styles
    !---------------------------------------------------------------------------
    public :: wxST_SIZEGRIP

    !---------------------------------------------------------------------------
    ! MessageBox / dialog button flags
    !---------------------------------------------------------------------------
    public :: wxOK, wxCANCEL, wxYES, wxNO, wxYES_NO
    public :: wxICON_INFORMATION, wxICON_WARNING, wxICON_ERROR, wxICON_QUESTION

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

        !-----------------------------------------------------------------------
        ! TextCtrl styles
        !-----------------------------------------------------------------------
        function wxTE_READONLY() bind(C, name="expwxTE_READONLY")
            import :: c_int
            integer(c_int) :: wxTE_READONLY
        end function wxTE_READONLY

        function wxTE_MULTILINE() bind(C, name="expwxTE_MULTILINE")
            import :: c_int
            integer(c_int) :: wxTE_MULTILINE
        end function wxTE_MULTILINE

        function wxTE_PASSWORD() bind(C, name="expwxTE_PASSWORD")
            import :: c_int
            integer(c_int) :: wxTE_PASSWORD
        end function wxTE_PASSWORD

        function wxTE_PROCESS_ENTER() bind(C, name="expwxTE_PROCESS_ENTER")
            import :: c_int
            integer(c_int) :: wxTE_PROCESS_ENTER
        end function wxTE_PROCESS_ENTER

        !-----------------------------------------------------------------------
        ! Button styles
        !-----------------------------------------------------------------------
        function wxBU_EXACTFIT() bind(C, name="expwxBU_EXACTFIT")
            import :: c_int
            integer(c_int) :: wxBU_EXACTFIT
        end function wxBU_EXACTFIT

        function wxBU_LEFT() bind(C, name="expwxBU_LEFT")
            import :: c_int
            integer(c_int) :: wxBU_LEFT
        end function wxBU_LEFT

        function wxBU_TOP() bind(C, name="expwxBU_TOP")
            import :: c_int
            integer(c_int) :: wxBU_TOP
        end function wxBU_TOP

        function wxBU_RIGHT() bind(C, name="expwxBU_RIGHT")
            import :: c_int
            integer(c_int) :: wxBU_RIGHT
        end function wxBU_RIGHT

        function wxBU_BOTTOM() bind(C, name="expwxBU_BOTTOM")
            import :: c_int
            integer(c_int) :: wxBU_BOTTOM
        end function wxBU_BOTTOM

        !-----------------------------------------------------------------------
        ! StaticText styles
        !-----------------------------------------------------------------------
        function wxST_NO_AUTORESIZE() bind(C, name="expwxST_NO_AUTORESIZE")
            import :: c_int
            integer(c_int) :: wxST_NO_AUTORESIZE
        end function wxST_NO_AUTORESIZE

        !-----------------------------------------------------------------------
        ! Window styles
        !-----------------------------------------------------------------------
        function wxTAB_TRAVERSAL() bind(C, name="expwxTAB_TRAVERSAL")
            import :: c_int
            integer(c_int) :: wxTAB_TRAVERSAL
        end function wxTAB_TRAVERSAL

        !-----------------------------------------------------------------------
        ! Event types
        !-----------------------------------------------------------------------
        function wxEVT_BUTTON() &
            bind(C, name="expwxEVT_BUTTON")
            import :: c_int
            integer(c_int) :: wxEVT_BUTTON
        end function wxEVT_BUTTON

        function wxEVT_CHECKBOX() &
            bind(C, name="expwxEVT_CHECKBOX")
            import :: c_int
            integer(c_int) :: wxEVT_CHECKBOX
        end function wxEVT_CHECKBOX

        function wxEVT_CHOICE() &
            bind(C, name="expwxEVT_CHOICE")
            import :: c_int
            integer(c_int) :: wxEVT_CHOICE
        end function wxEVT_CHOICE

        function wxEVT_TEXT() &
            bind(C, name="expwxEVT_TEXT")
            import :: c_int
            integer(c_int) :: wxEVT_TEXT
        end function wxEVT_TEXT

        function wxEVT_TEXT_ENTER() &
            bind(C, name="expwxEVT_TEXT_ENTER")
            import :: c_int
            integer(c_int) :: wxEVT_TEXT_ENTER
        end function wxEVT_TEXT_ENTER

        function wxEVT_MENU() &
            bind(C, name="expwxEVT_MENU")
            import :: c_int
            integer(c_int) :: wxEVT_MENU
        end function wxEVT_MENU

        !-----------------------------------------------------------------------
        ! Additional event types (Phase 5)
        !-----------------------------------------------------------------------

        function wxEVT_LISTBOX() &
            bind(C, name="expwxEVT_LISTBOX")
            import :: c_int
            integer(c_int) :: wxEVT_LISTBOX
        end function wxEVT_LISTBOX

        function wxEVT_LISTBOX_DCLICK() &
            bind(C, name="expwxEVT_LISTBOX_DCLICK")
            import :: c_int
            integer(c_int) :: wxEVT_LISTBOX_DCLICK
        end function wxEVT_LISTBOX_DCLICK

        function wxEVT_RADIOBUTTON() &
            bind(C, name="expwxEVT_RADIOBUTTON")
            import :: c_int
            integer(c_int) :: wxEVT_RADIOBUTTON
        end function wxEVT_RADIOBUTTON

        function wxEVT_COMBOBOX() &
            bind(C, name="expwxEVT_COMBOBOX")
            import :: c_int
            integer(c_int) :: wxEVT_COMBOBOX
        end function wxEVT_COMBOBOX

        function wxEVT_TOOL() &
            bind(C, name="expwxEVT_TOOL")
            import :: c_int
            integer(c_int) :: wxEVT_TOOL
        end function wxEVT_TOOL

        ! Note: exported as expEVT_CLOSE_WINDOW (no 'wx' prefix) in kwxFFI
        function wxEVT_CLOSE_WINDOW() &
            bind(C, name="expEVT_CLOSE_WINDOW")
            import :: c_int
            integer(c_int) :: wxEVT_CLOSE_WINDOW
        end function wxEVT_CLOSE_WINDOW

        !-----------------------------------------------------------------------
        ! ListBox styles
        !-----------------------------------------------------------------------

        function wxLB_SINGLE() bind(C, name="expwxLB_SINGLE")
            import :: c_int
            integer(c_int) :: wxLB_SINGLE
        end function wxLB_SINGLE

        function wxLB_MULTIPLE() bind(C, name="expwxLB_MULTIPLE")
            import :: c_int
            integer(c_int) :: wxLB_MULTIPLE
        end function wxLB_MULTIPLE

        function wxLB_EXTENDED() bind(C, name="expwxLB_EXTENDED")
            import :: c_int
            integer(c_int) :: wxLB_EXTENDED
        end function wxLB_EXTENDED

        function wxLB_SORT() bind(C, name="expwxLB_SORT")
            import :: c_int
            integer(c_int) :: wxLB_SORT
        end function wxLB_SORT

        function wxLB_NEEDED_SB() bind(C, name="expwxLB_NEEDED_SB")
            import :: c_int
            integer(c_int) :: wxLB_NEEDED_SB
        end function wxLB_NEEDED_SB

        function wxLB_ALWAYS_SB() bind(C, name="expwxLB_ALWAYS_SB")
            import :: c_int
            integer(c_int) :: wxLB_ALWAYS_SB
        end function wxLB_ALWAYS_SB

        !-----------------------------------------------------------------------
        ! ComboBox styles
        !-----------------------------------------------------------------------

        function wxCB_SIMPLE() bind(C, name="expwxCB_SIMPLE")
            import :: c_int
            integer(c_int) :: wxCB_SIMPLE
        end function wxCB_SIMPLE

        function wxCB_SORT() bind(C, name="expwxCB_SORT")
            import :: c_int
            integer(c_int) :: wxCB_SORT
        end function wxCB_SORT

        function wxCB_READONLY() bind(C, name="expwxCB_READONLY")
            import :: c_int
            integer(c_int) :: wxCB_READONLY
        end function wxCB_READONLY

        function wxCB_DROPDOWN() bind(C, name="expwxCB_DROPDOWN")
            import :: c_int
            integer(c_int) :: wxCB_DROPDOWN
        end function wxCB_DROPDOWN

        !-----------------------------------------------------------------------
        ! RadioButton styles
        !-----------------------------------------------------------------------

        function wxRB_GROUP() bind(C, name="expwxRB_GROUP")
            import :: c_int
            integer(c_int) :: wxRB_GROUP
        end function wxRB_GROUP

        !-----------------------------------------------------------------------
        ! Menu item kinds
        !-----------------------------------------------------------------------

        function wxITEM_SEPARATOR() bind(C, name="expwxITEM_SEPARATOR")
            import :: c_int
            integer(c_int) :: wxITEM_SEPARATOR
        end function wxITEM_SEPARATOR

        function wxITEM_NORMAL() bind(C, name="expwxITEM_NORMAL")
            import :: c_int
            integer(c_int) :: wxITEM_NORMAL
        end function wxITEM_NORMAL

        function wxITEM_CHECK() bind(C, name="expwxITEM_CHECK")
            import :: c_int
            integer(c_int) :: wxITEM_CHECK
        end function wxITEM_CHECK

        function wxITEM_RADIO() bind(C, name="expwxITEM_RADIO")
            import :: c_int
            integer(c_int) :: wxITEM_RADIO
        end function wxITEM_RADIO

        !-----------------------------------------------------------------------
        ! Toolbar styles
        !-----------------------------------------------------------------------

        function wxTB_HORIZONTAL() bind(C, name="expwxTB_HORIZONTAL")
            import :: c_int
            integer(c_int) :: wxTB_HORIZONTAL
        end function wxTB_HORIZONTAL

        function wxTB_VERTICAL() bind(C, name="expwxTB_VERTICAL")
            import :: c_int
            integer(c_int) :: wxTB_VERTICAL
        end function wxTB_VERTICAL

        function wxTB_FLAT() bind(C, name="expwxTB_FLAT")
            import :: c_int
            integer(c_int) :: wxTB_FLAT
        end function wxTB_FLAT

        function wxTB_TEXT() bind(C, name="expwxTB_TEXT")
            import :: c_int
            integer(c_int) :: wxTB_TEXT
        end function wxTB_TEXT

        function wxTB_NODIVIDER() bind(C, name="expwxTB_NODIVIDER")
            import :: c_int
            integer(c_int) :: wxTB_NODIVIDER
        end function wxTB_NODIVIDER

        !-----------------------------------------------------------------------
        ! StatusBar styles
        !-----------------------------------------------------------------------

        function wxST_SIZEGRIP() bind(C, name="expwxST_SIZEGRIP")
            import :: c_int
            integer(c_int) :: wxST_SIZEGRIP
        end function wxST_SIZEGRIP

        !-----------------------------------------------------------------------
        ! MessageBox / dialog button flags
        !-----------------------------------------------------------------------

        function wxOK() bind(C, name="expwxOK")
            import :: c_int
            integer(c_int) :: wxOK
        end function wxOK

        function wxCANCEL() bind(C, name="expwxCANCEL")
            import :: c_int
            integer(c_int) :: wxCANCEL
        end function wxCANCEL

        function wxYES() bind(C, name="expwxYES")
            import :: c_int
            integer(c_int) :: wxYES
        end function wxYES

        function wxNO() bind(C, name="expwxNO")
            import :: c_int
            integer(c_int) :: wxNO
        end function wxNO

        function wxYES_NO() bind(C, name="expwxYES_NO")
            import :: c_int
            integer(c_int) :: wxYES_NO
        end function wxYES_NO

        function wxICON_INFORMATION() bind(C, name="expwxICON_INFORMATION")
            import :: c_int
            integer(c_int) :: wxICON_INFORMATION
        end function wxICON_INFORMATION

        function wxICON_WARNING() bind(C, name="expwxICON_WARNING")
            import :: c_int
            integer(c_int) :: wxICON_WARNING
        end function wxICON_WARNING

        function wxICON_ERROR() bind(C, name="expwxICON_ERROR")
            import :: c_int
            integer(c_int) :: wxICON_ERROR
        end function wxICON_ERROR

        function wxICON_QUESTION() bind(C, name="expwxICON_QUESTION")
            import :: c_int
            integer(c_int) :: wxICON_QUESTION
        end function wxICON_QUESTION

    end interface

end module kwx_constants
