!> @file wxffi_types.f90
!> @brief Opaque pointer types for wxWidgets objects
!>
!> This module defines Fortran derived types that wrap C pointers to wxWidgets
!> objects. These provide type-safety when working with the wxFFI C interface.

module wxffi_types
    use, intrinsic :: iso_c_binding
    implicit none

    private
    public :: wxApp_t, wxWindow_t, wxFrame_t, wxButton_t, wxPanel_t, wxTextCtrl_t

    !> @brief Application class pointer wrapper
    !>
    !> Wraps a pointer to the wxApp (ELJApp in wxFFI) application object.
    !> There should only be one application object per program.
    type :: wxApp_t
        type(c_ptr) :: ptr = c_null_ptr
    end type wxApp_t

    !> @brief Base window class pointer wrapper
    !>
    !> Wraps a pointer to wxWindow, the base class for all window types.
    !> Most window-related operations work on this base type.
    type :: wxWindow_t
        type(c_ptr) :: ptr = c_null_ptr
    end type wxWindow_t

    !> @brief Frame window pointer wrapper
    !>
    !> Wraps a pointer to wxFrame, a top-level window with title bar and borders.
    !> Extends wxWindow_t for type safety while maintaining compatibility.
    type, extends(wxWindow_t) :: wxFrame_t
    end type wxFrame_t

    !> @brief Button control pointer wrapper
    !>
    !> Wraps a pointer to wxButton, a clickable button control.
    type, extends(wxWindow_t) :: wxButton_t
    end type wxButton_t

    !> @brief Panel container pointer wrapper
    !>
    !> Wraps a pointer to wxPanel, a container window for other controls.
    type, extends(wxWindow_t) :: wxPanel_t
    end type wxPanel_t

    !> @brief Text control pointer wrapper
    !>
    !> Wraps a pointer to wxTextCtrl, a text input/display control.
    type, extends(wxWindow_t) :: wxTextCtrl_t
    end type wxTextCtrl_t

end module wxffi_types
