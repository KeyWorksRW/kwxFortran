! wxffi_types.f90 - Opaque pointer types for wxWidgets objects
! Part of kwxFortran - Fortran bindings for wxWidgets via wxFFI
!
! This module defines type-safe wrappers around C pointers for wxWidgets objects.
! All wxWidgets objects are represented as opaque pointers (type(c_ptr)) internally,
! but wrapped in Fortran derived types for type safety and inheritance hierarchy.

module wxffi_types
    use, intrinsic :: iso_c_binding
    implicit none
    private

    ! Base window type - all UI elements inherit from this
    type, public :: wxWindow_t
        type(c_ptr) :: ptr = c_null_ptr
    contains
        procedure :: is_valid => wxWindow_is_valid
    end type wxWindow_t

    ! Top-level window types
    type, extends(wxWindow_t), public :: wxFrame_t
    end type wxFrame_t

    type, extends(wxWindow_t), public :: wxDialog_t
    end type wxDialog_t

    ! Container types
    type, extends(wxWindow_t), public :: wxPanel_t
    end type wxPanel_t

    ! Control types
    type, extends(wxWindow_t), public :: wxButton_t
    end type wxButton_t

    type, extends(wxWindow_t), public :: wxTextCtrl_t
    end type wxTextCtrl_t

    type, extends(wxWindow_t), public :: wxStaticText_t
    end type wxStaticText_t

    type, extends(wxWindow_t), public :: wxCheckBox_t
    end type wxCheckBox_t

    type, extends(wxWindow_t), public :: wxRadioButton_t
    end type wxRadioButton_t

    type, extends(wxWindow_t), public :: wxChoice_t
    end type wxChoice_t

    type, extends(wxWindow_t), public :: wxListBox_t
    end type wxListBox_t

    type, extends(wxWindow_t), public :: wxComboBox_t
    end type wxComboBox_t

    type, extends(wxWindow_t), public :: wxStatusBar_t
    end type wxStatusBar_t

    type, extends(wxWindow_t), public :: wxToolBar_t
    end type wxToolBar_t

    ! Layout types (sizers)
    type, public :: wxSizer_t
        type(c_ptr) :: ptr = c_null_ptr
    contains
        procedure :: is_valid => wxSizer_is_valid
    end type wxSizer_t

    type, extends(wxSizer_t), public :: wxBoxSizer_t
    end type wxBoxSizer_t

    type, extends(wxSizer_t), public :: wxFlexGridSizer_t
    end type wxFlexGridSizer_t

    type, extends(wxSizer_t), public :: wxGridSizer_t
    end type wxGridSizer_t

    ! Event types
    type, public :: wxEvent_t
        type(c_ptr) :: ptr = c_null_ptr
    contains
        procedure :: is_valid => wxEvent_is_valid
    end type wxEvent_t

    type, extends(wxEvent_t), public :: wxCommandEvent_t
    end type wxCommandEvent_t

    ! Application type
    type, public :: wxApp_t
        type(c_ptr) :: ptr = c_null_ptr
    contains
        procedure :: is_valid => wxApp_is_valid
    end type wxApp_t

    ! Menu types
    type, public :: wxMenu_t
        type(c_ptr) :: ptr = c_null_ptr
    contains
        procedure :: is_valid => wxMenu_is_valid
    end type wxMenu_t

    type, public :: wxMenuBar_t
        type(c_ptr) :: ptr = c_null_ptr
    contains
        procedure :: is_valid => wxMenuBar_is_valid
    end type wxMenuBar_t

    type, public :: wxMenuItem_t
        type(c_ptr) :: ptr = c_null_ptr
    contains
        procedure :: is_valid => wxMenuItem_is_valid
    end type wxMenuItem_t

    ! String type (for wxString* handling)
    type, public :: wxString_t
        type(c_ptr) :: ptr = c_null_ptr
    contains
        procedure :: is_valid => wxString_is_valid
    end type wxString_t

contains

    ! Validity checkers - test if pointer is non-null
    pure logical function wxWindow_is_valid(self) result(valid)
        class(wxWindow_t), intent(in) :: self
        valid = c_associated(self%ptr)
    end function wxWindow_is_valid

    pure logical function wxSizer_is_valid(self) result(valid)
        class(wxSizer_t), intent(in) :: self
        valid = c_associated(self%ptr)
    end function wxSizer_is_valid

    pure logical function wxEvent_is_valid(self) result(valid)
        class(wxEvent_t), intent(in) :: self
        valid = c_associated(self%ptr)
    end function wxEvent_is_valid

    pure logical function wxApp_is_valid(self) result(valid)
        class(wxApp_t), intent(in) :: self
        valid = c_associated(self%ptr)
    end function wxApp_is_valid

    pure logical function wxMenu_is_valid(self) result(valid)
        class(wxMenu_t), intent(in) :: self
        valid = c_associated(self%ptr)
    end function wxMenu_is_valid

    pure logical function wxMenuBar_is_valid(self) result(valid)
        class(wxMenuBar_t), intent(in) :: self
        valid = c_associated(self%ptr)
    end function wxMenuBar_is_valid

    pure logical function wxMenuItem_is_valid(self) result(valid)
        class(wxMenuItem_t), intent(in) :: self
        valid = c_associated(self%ptr)
    end function wxMenuItem_is_valid

    pure logical function wxString_is_valid(self) result(valid)
        class(wxString_t), intent(in) :: self
        valid = c_associated(self%ptr)
    end function wxString_is_valid

end module wxffi_types
