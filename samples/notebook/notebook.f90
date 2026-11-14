! notebook.f90 - wxWidgets book controls sample
!
! Fortran port of wxWidgets sample src/notebook/notebook.cpp (kwxFortran).
!
! The frame hosts a panel with a read-only log text control and a book
! control below it.  The book control can be recreated as a wxNotebook,
! wxListbook, wxChoicebook, wxTreebook, wxToolbook, wxAuiNotebook or
! wxSimplebook, with orientation and style flags taken from the menus.
! Page operations (add/insert/delete/select/size/hit-test) and book page
! change events are logged to the text control, exactly like the original
! wxLogTextCtrl target.
!
! Notes on the port:
!  * wxBookCtrlBase::Images (a vector of wxBitmapBundle) has no FFI binding.
!    The four wxArtProvider 32x32 bitmaps are added to a wxImageList that is
!    assigned to each freshly created book control instead.
!  * wxNB_NOPAGETHEME is applied through the exported wxNB_NOPAGETHEME()
!    accessor, like the other style flags.
!  * wxBK_TOP/BOTTOM/LEFT/RIGHT are exported and used for the orientation
!    flags; the C++ sample's wxNB_* equivalents have the same values.
!  * SetIcon(wxICON(sample)) uses the 32x32 samples/sample.xpm artwork,
!    reproduced pixel for pixel in sample.svg and loaded through
!    wxBitmapBundle::FromSVGFile.  Run the executable from this folder so the
!    relative "sample.svg" path resolves.

module notebook_globals
    use, intrinsic :: iso_c_binding
    use kwx_types
    implicit none

    ! MyFrame::BookType
    integer, parameter :: TYPE_NOTEBOOK = 0
    integer, parameter :: TYPE_LISTBOOK = 1
    integer, parameter :: TYPE_CHOICEBOOK = 2
    integer, parameter :: TYPE_TREEBOOK = 3
    integer, parameter :: TYPE_TOOLBOOK = 4
    integer, parameter :: TYPE_AUINOTEBOOK = 5
    integer, parameter :: TYPE_SIMPLEBOOK = 6

    ! ID_COMMANDS offsets, relative to ID_BOOK_NOTEBOOK == wxID_HIGHEST.
    integer, parameter :: IDOFF_BOOK_NOTEBOOK = 0
    integer, parameter :: IDOFF_BOOK_LISTBOOK = 1
    integer, parameter :: IDOFF_BOOK_CHOICEBOOK = 2
    integer, parameter :: IDOFF_BOOK_TREEBOOK = 3
    integer, parameter :: IDOFF_BOOK_TOOLBOOK = 4
    integer, parameter :: IDOFF_BOOK_AUINOTEBOOK = 5
    integer, parameter :: IDOFF_BOOK_SIMPLEBOOK = 6
    integer, parameter :: IDOFF_BOOK_MAX = 7

    integer, parameter :: IDOFF_ORIENT_DEFAULT = 8
    integer, parameter :: IDOFF_ORIENT_TOP = 9
    integer, parameter :: IDOFF_ORIENT_BOTTOM = 10
    integer, parameter :: IDOFF_ORIENT_LEFT = 11
    integer, parameter :: IDOFF_ORIENT_RIGHT = 12
    integer, parameter :: IDOFF_ORIENT_MAX = 13

    integer, parameter :: IDOFF_SHOW_IMAGES = 14
    integer, parameter :: IDOFF_FIXEDWIDTH = 15
    integer, parameter :: IDOFF_MULTI = 16
    integer, parameter :: IDOFF_NOPAGETHEME = 17
    integer, parameter :: IDOFF_BUTTONBAR = 18
    integer, parameter :: IDOFF_HORZ_LAYOUT = 19

    integer, parameter :: IDOFF_ADD_PAGE = 20
    integer, parameter :: IDOFF_ADD_PAGE_NO_SELECT = 21
    integer, parameter :: IDOFF_INSERT_PAGE = 22
    integer, parameter :: IDOFF_DELETE_CUR_PAGE = 23
    integer, parameter :: IDOFF_DELETE_LAST_PAGE = 24
    integer, parameter :: IDOFF_NEXT_PAGE = 25
    integer, parameter :: IDOFF_ADD_PAGE_BEFORE = 26
    integer, parameter :: IDOFF_ADD_SUB_PAGE = 27
    integer, parameter :: IDOFF_CHANGE_SELECTION = 28
    integer, parameter :: IDOFF_SET_SELECTION = 29
    integer, parameter :: IDOFF_GET_PAGE_SIZE = 30
    integer, parameter :: IDOFF_SET_PAGE_SIZE = 31
    integer, parameter :: IDOFF_CONTEXT_HELP = 32
    integer, parameter :: IDOFF_HITTEST = 33

    ! Main frame, panel, book, log text and frame sizer (MyFrame members).
    type(wxFrame_t), save :: g_frame
    type(wxPanel_t), save :: g_panel
    type(wxWindow_t), save :: g_book
    type(wxTextCtrl_t), save :: g_text
    type(wxBoxSizer_t), save :: g_sizerFrame

    ! MyFrame::m_type et al.
    integer, save :: g_base_id = 0
    integer, save :: g_type = TYPE_NOTEBOOK
    integer, save :: g_old_book_type = -1
    integer, save :: g_orient = 0
    logical, save :: g_chkShowImages = .true.
    logical, save :: g_fixedWidth = .false.
    logical, save :: g_multi = .false.
    logical, save :: g_noPageTheme = .false.
    logical, save :: g_buttonBar = .false.
    logical, save :: g_horzLayout = .false.

    ! wxSizerFlags::Border() / DoubleBorder() in pixels at current DPI.
    integer, save :: g_border1 = 5
    integer, save :: g_border2 = 10

    ! Function-local statics of the C++ handlers.
    integer, save :: g_page_added = 0
    integer, save :: g_page_added_nosel = 0
    integer, save :: g_subpage_added = 0
    integer, save :: g_page_before_added = 0
    integer, save :: g_page_ins = 0
    integer, save :: g_event_num = 0
    integer, save :: g_idle_pages = -1
    integer, save :: g_idle_sel = -1
    type(c_ptr), save :: g_idle_book = c_null_ptr

    ! Log target bookkeeping (USE_LOG).
    type(c_ptr), save :: g_old_log_target = c_null_ptr

    ! Number of images in the list currently assigned to the book.
    integer, save :: g_image_count = 0

contains

    integer function idv(offset) result(value)
        integer, intent(in) :: offset
        value = g_base_id + offset
    end function idv

    logical function book_has_images() result(has)
        has = g_chkShowImages .or. (g_type == TYPE_TOOLBOOK)
    end function book_has_images

    function int_to_str(value) result(text)
        integer, intent(in) :: value
        character(len=:), allocatable :: text
        character(len=32) :: buffer
        write(buffer, '(I0)') value
        text = trim(buffer)
    end function int_to_str

end module notebook_globals


module notebook_icon
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxBitmapBundle_Delete
    use wx_bitmap_bundle, only: wx_bitmap_bundle_from_svg_file, &
        wx_bitmap_bundle_get_bitmap
    use wx_bitmap, only: wx_bitmap_delete
    use wx_icon, only: wx_icon_create_default, wx_icon_copy_from_bitmap, &
        wx_icon_delete, wx_icon_is_ok
    use wx_frame, only: wx_frame_set_icon
    implicit none
    private

    public :: set_sample_icon

contains

    ! SetIcon(wxICON(sample))
    !
    ! samples/sample.xpm is reproduced in sample.svg at its original 32x32
    ! size; wxICON(sample) on MSW copies the bitmap into an icon.
    subroutine set_sample_icon(frame)
        type(wxFrame_t), intent(in) :: frame
        type(wxBitmapBundle_t) :: bundle
        type(wxBitmap_t) :: bitmap
        type(wxIcon_t) :: icon

        bundle = wx_bitmap_bundle_from_svg_file("sample.svg", 32_c_int, 32_c_int)
        if (.not. bundle%is_valid()) return

        bitmap = wx_bitmap_bundle_get_bitmap(bundle, 32_c_int, 32_c_int)
        if (bitmap%is_valid()) then
            icon = wx_icon_create_default()
            if (icon%is_valid()) then
                ! wxIcon_CopyFromBitmap() is implemented only for __WIN32__; on
                ! other platforms the icon remains invalid and is not installed.
                call wx_icon_copy_from_bitmap(icon, bitmap)
                if (wx_icon_is_ok(icon)) call wx_frame_set_icon(frame, icon)
                call wx_icon_delete(icon)
            end if
            call wx_bitmap_delete(bitmap)
        end if

        ! wxBitmapBundle_FromSVGFile() returns a newly allocated bundle, but the
        ! generated wrapper marks the handle non-owned; release it explicitly.
        call wxBitmapBundle_Delete(bundle%ptr)
        bundle%ptr = c_null_ptr
    end subroutine set_sample_icon

end module notebook_icon


module notebook_pages
    use, intrinsic :: iso_c_binding
    use kwxffi
    use kwx_types
    use wx_string, only: to_wxstring
    use wx_panel, only: wx_panel_create
    use wx_button, only: wx_button_create
    use wx_text_ctrl, only: wx_text_ctrl_create
    use wx_static_text, only: wx_static_text_create
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add_window
    use wx_window, only: wx_window_set_sizer
    use wx_colour, only: wx_colour_create_by_name, wx_colour_delete
    use notebook_globals, only: g_border1, g_border2
    implicit none
    private

    public :: create_user_created_page, create_radio_buttons_page
    public :: create_veto_page, create_insert_page, create_full_page_text
    public :: create_new_page, create_page

contains

    subroutine set_help_text(win, text)
        type(wxWindow_t), intent(in) :: win
        character(len=*), intent(in) :: text
        type(c_ptr) :: text_ptr
        text_ptr = to_wxstring(text)
        call wxWindow_SetHelpText(win%ptr, text_ptr)
        call wxString_Delete(text_ptr)
    end subroutine set_help_text

    ! Copies a Fortran string into a NUL-terminated c_char buffer.
    subroutine c_copy(text, buffer)
        character(len=*), intent(in) :: text
        character(kind=c_char, len=*), intent(out) :: buffer
        integer :: i, n

        do i = 1, len(buffer)
            buffer(i:i) = c_null_char
        end do
        n = min(len_trim(text), len(buffer) - 1)
        do i = 1, n
            buffer(i:i) = text(i:i)
        end do
    end subroutine c_copy

    ! CreateUserCreatedPage(): a panel with a Button at (10, 10).
    function create_user_created_page(parent) result(page)
        class(wxWindow_t), intent(in) :: parent
        type(wxWindow_t) :: page
        type(wxPanel_t) :: panel
        type(wxButton_t) :: button

        panel = wx_panel_create(parent, wxID_ANY(), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)
        page%ptr = panel%ptr
        call set_help_text(page, "Panel with a Button")

        button = wx_button_create(panel, wxID_ANY(), "Button", 10_c_int, 10_c_int, &
            -1_c_int, -1_c_int, 0_c_int)
    end function create_user_created_page

    ! CreateRadioButtonsPage(): two radio boxes in a vertical sizer.
    function create_radio_buttons_page(parent) result(page)
        class(wxWindow_t), intent(in) :: parent
        type(wxWindow_t) :: page
        type(wxPanel_t) :: panel
        type(wxBoxSizer_t) :: sizer
        type(wxWindow_t) :: radio1, radio2
        type(c_ptr) :: title_ptr
        character(kind=c_char, len=24), dimension(5), target :: animals
        character(kind=c_char, len=24), dimension(4), target :: computers
        type(c_ptr), dimension(5), target :: animal_ptrs
        type(c_ptr), dimension(4), target :: computer_ptrs
        integer :: i

        panel = wx_panel_create(parent, wxID_ANY(), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)
        page%ptr = panel%ptr
        call set_help_text(page, "Panel with some Radio Buttons")

        call c_copy("Fox", animals(1))
        call c_copy("Hare", animals(2))
        call c_copy("Rabbit", animals(3))
        call c_copy("Sabre-toothed tiger", animals(4))
        call c_copy("T Rex", animals(5))
        do i = 1, 5
            animal_ptrs(i) = c_loc(animals(i)(1:1))
        end do

        title_ptr = to_wxstring("Choose one")
        radio1%ptr = wxRadioBox_Create(panel%ptr, wxID_ANY(), title_ptr, &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 5_c_int, &
            c_loc(animal_ptrs), 2_c_int, wxRA_SPECIFY_ROWS())
        call wxString_Delete(title_ptr)

        call c_copy("Amiga", computers(1))
        call c_copy("Commodore 64", computers(2))
        call c_copy("PET", computers(3))
        call c_copy("Another", computers(4))
        do i = 1, 4
            computer_ptrs(i) = c_loc(computers(i)(1:1))
        end do

        title_ptr = to_wxstring("Choose your favourite")
        radio2%ptr = wxRadioBox_Create(panel%ptr, wxID_ANY(), title_ptr, &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 4_c_int, &
            c_loc(computer_ptrs), 0_c_int, wxRA_SPECIFY_COLS())
        call wxString_Delete(title_ptr)

        sizer = wx_box_sizer_create(wxVERTICAL())
        call wx_sizer_add_window(sizer, radio1, 2_c_int, &
            wxEXPAND(), 0_c_int, c_null_ptr)
        call wx_sizer_add_window(sizer, radio2, 1_c_int, &
            wxEXPAND(), 0_c_int, c_null_ptr)
        call wx_window_set_sizer(panel, sizer, .false.)
    end function create_radio_buttons_page

    ! CreateVetoPage(): an empty panel with a centred label.
    function create_veto_page(parent) result(page)
        class(wxWindow_t), intent(in) :: parent
        type(wxWindow_t) :: page
        type(wxPanel_t) :: panel
        type(wxBoxSizer_t) :: sizer
        type(wxStaticText_t) :: label
        type(wxWindow_t) :: label_win

        panel = wx_panel_create(parent, wxID_ANY(), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)
        page%ptr = panel%ptr
        call set_help_text(page, "An empty panel")

        sizer = wx_box_sizer_create(wxVERTICAL())
        label = wx_static_text_create(panel, wxID_ANY(), &
            "This page intentionally left blank", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)
        label_win%ptr = label%ptr
        call wx_sizer_add_window(sizer, label_win, 0_c_int, &
            wxEXPAND(), int(g_border2, c_int), c_null_ptr)
        call wx_window_set_sizer(panel, sizer, .false.)
    end function create_veto_page

    ! CreateInsertPage(): a maroon panel with a label.
    function create_insert_page(parent) result(page)
        class(wxWindow_t), intent(in) :: parent
        type(wxWindow_t) :: page
        type(wxPanel_t) :: panel
        type(wxBoxSizer_t) :: sizer
        type(wxStaticText_t) :: label
        type(wxWindow_t) :: label_win
        type(wxcolour_t) :: colour
        integer(c_int) :: dummy

        panel = wx_panel_create(parent, wxID_ANY(), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)
        page%ptr = panel%ptr
        call set_help_text(page, "Maroon panel")

        ! C++: SetBackgroundColour("MAROON")
        colour = wx_colour_create_by_name("MAROON")
        dummy = wxWindow_SetBackgroundColour(panel%ptr, colour%ptr)
        call wx_colour_delete(colour)

        sizer = wx_box_sizer_create(wxVERTICAL())
        label = wx_static_text_create(panel, wxID_ANY(), &
            "This page has been inserted, not added.", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)
        label_win%ptr = label%ptr
        call wx_sizer_add_window(sizer, label_win, 0_c_int, &
            wxEXPAND(), int(g_border2, c_int), c_null_ptr)
        call wx_window_set_sizer(panel, sizer, .false.)
    end function create_insert_page

    ! CreateFullPageText(): a multiline text control with fixed contents.
    function create_full_page_text(parent) result(page)
        class(wxWindow_t), intent(in) :: parent
        type(wxWindow_t) :: page
        type(wxTextCtrl_t) :: text

        text = wx_text_ctrl_create(parent, wxID_ANY(), "Full page text", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, int(wxTE_MULTILINE(), c_long))
        page%ptr = text%ptr
        call set_help_text(page, "Page consisting of just a text control")
    end function create_full_page_text

    ! MyFrame::CreateNewPage(): a panel with two buttons side by side.
    function create_new_page(parent) result(page)
        class(wxWindow_t), intent(in) :: parent
        type(wxWindow_t) :: page
        type(wxPanel_t) :: panel
        type(wxBoxSizer_t) :: sizer
        type(wxButton_t) :: first_button, second_button
        type(wxWindow_t) :: button_win

        panel = wx_panel_create(parent, wxID_ANY(), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)
        page%ptr = panel%ptr
        call set_help_text(page, 'Panel with "First" and "Second" buttons')

        sizer = wx_box_sizer_create(wxHORIZONTAL())
        call wx_window_set_sizer(panel, sizer, .false.)

        first_button = wx_button_create(panel, wxID_ANY(), "First button", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        button_win%ptr = first_button%ptr
        call wx_sizer_add_window(sizer, button_win, 0_c_int, wxALL(), &
            int(g_border1, c_int), c_null_ptr)

        second_button = wx_button_create(panel, wxID_ANY(), "Second button", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        button_win%ptr = second_button%ptr
        call wx_sizer_add_window(sizer, button_win, 0_c_int, wxALL(), &
            int(g_border1, c_int), c_null_ptr)
    end function create_new_page

    ! CreatePage(): recreates the page of the given name when a book control
    ! is cloned.
    function create_page(parent, page_name) result(page)
        class(wxWindow_t), intent(in) :: parent
        character(len=*), intent(in) :: page_name
        type(wxWindow_t) :: page

        page%ptr = c_null_ptr

        if (index(page_name, "Inserted ") > 0 .or. &
                index(page_name, "Added ") > 0 .or. &
                index(page_name, " Inserted sub-page ") > 0 .or. &
                index(page_name, " Inserted before ") > 0) then
            page = create_user_created_page(parent)
        else if (trim(page_name) == "Inserted") then
            page = create_insert_page(parent)
        else if (trim(page_name) == "Veto") then
            page = create_veto_page(parent)
        else if (trim(page_name) == "Radio buttons") then
            page = create_radio_buttons_page(parent)
        else if (trim(page_name) == "Text") then
            page = create_full_page_text(parent)
        end if
    end function create_page

end module notebook_pages


module notebook_core
    use, intrinsic :: iso_c_binding
    use kwxffi
    use kwx_types
    use wx_string, only: to_wxstring, from_wxstring
    use notebook_globals
    use notebook_pages
    implicit none
    private

    public :: recreate_book, create_initial_pages, get_icon_index
    public :: book_page_text, book_add_page, book_insert_page
    public :: book_insert_subpage, log_message, log_error
    public :: append_radio_item, append_sub_menu

contains

    subroutine log_message(message)
        character(len=*), intent(in) :: message
        type(c_ptr) :: text_ptr
        text_ptr = to_wxstring(message)
        call LogMessage(text_ptr)
        call wxString_Delete(text_ptr)
    end subroutine log_message

    subroutine log_error(message)
        character(len=*), intent(in) :: message
        type(c_ptr) :: text_ptr
        text_ptr = to_wxstring(message)
        call LogError(text_ptr)
        call wxString_Delete(text_ptr)
    end subroutine log_error

    function book_page_text(book_ptr, page) result(text)
        type(c_ptr), intent(in) :: book_ptr
        integer, intent(in) :: page
        character(len=:), allocatable :: text
        type(c_ptr) :: str_ptr

        str_ptr = wxBookCtrlBase_GetPageText(book_ptr, int(page, c_int))
        text = from_wxstring(str_ptr)
        call wxString_Delete(str_ptr)
    end function book_page_text

    subroutine book_add_page(book, page, label, select_, image)
        type(wxWindow_t), intent(in) :: book, page
        character(len=*), intent(in) :: label
        logical, intent(in) :: select_
        integer, intent(in) :: image
        type(c_ptr) :: text_ptr
        integer(c_int) :: c_select, dummy

        if (.not. page%is_valid()) return
        c_select = 0_c_int
        if (select_) c_select = 1_c_int
        text_ptr = to_wxstring(label)
        dummy = wxBookCtrlBase_AddPage(book%ptr, page%ptr, text_ptr, &
            c_select, int(image, c_int))
        call wxString_Delete(text_ptr)
    end subroutine book_add_page

    subroutine book_insert_page(book, index, page, label, select_, image)
        type(wxWindow_t), intent(in) :: book, page
        integer, intent(in) :: index
        character(len=*), intent(in) :: label
        logical, intent(in) :: select_
        integer, intent(in) :: image
        type(c_ptr) :: text_ptr
        integer(c_int) :: c_select, dummy

        if (.not. page%is_valid()) return
        c_select = 0_c_int
        if (select_) c_select = 1_c_int
        text_ptr = to_wxstring(label)
        dummy = wxBookCtrlBase_InsertPage(book%ptr, int(index, c_int), &
            page%ptr, text_ptr, c_select, int(image, c_int))
        call wxString_Delete(text_ptr)
    end subroutine book_insert_page

    subroutine book_insert_subpage(book, parent, page, label, select_, image)
        type(wxWindow_t), intent(in) :: book, page
        integer, intent(in) :: parent
        character(len=*), intent(in) :: label
        logical, intent(in) :: select_
        integer, intent(in) :: image
        type(c_ptr) :: text_ptr
        integer(c_int) :: c_select, dummy

        if (.not. page%is_valid()) return
        c_select = 0_c_int
        if (select_) c_select = 1_c_int
        text_ptr = to_wxstring(label)
        dummy = wxTreebook_InsertSubPage(book%ptr, int(parent, c_int), &
            page%ptr, text_ptr, c_select, int(image, c_int))
        call wxString_Delete(text_ptr)
    end subroutine book_insert_subpage

    integer function get_icon_index(book) result(idx)
        type(wxWindow_t), intent(in) :: book
        integer :: n_pages

        idx = -1
        if (.not. book%is_valid()) return
        if (g_image_count > 0) then
            n_pages = int(wxBookCtrlBase_GetPageCount(book%ptr))
            idx = mod(n_pages, g_image_count)
        end if
    end function get_icon_index

    ! CreateInitialPages()
    subroutine create_initial_pages(book)
        type(wxWindow_t), intent(in) :: book
        type(wxWindow_t) :: page
        integer :: dummy

        page = create_radio_buttons_page(book)
        call book_add_page(book, page, "Radio buttons", .false., &
            get_icon_index(book))

        page = create_veto_page(book)
        call book_add_page(book, page, "Veto", .false., get_icon_index(book))

        page = create_full_page_text(book)
        call book_add_page(book, page, "Text", .false., get_icon_index(book))

        page = create_insert_page(book)
        call book_insert_page(book, 0, page, "Inserted", .false., &
            get_icon_index(book))

        dummy = wxBookCtrlBase_SetSelection(book%ptr, 1_c_int)
    end subroutine create_initial_pages

    ! MyFrame::RecreateBook()
    subroutine recreate_book()
        type(wxWindow_t) :: new_book, page
        type(c_ptr) :: old_ptr, text_ptr
        integer(c_int) :: flags
        integer :: n, count, image, parent, sel, dummy
        character(len=:), allocatable :: page_name
        logical :: old_is_tree

        flags = 0_c_int
        if (g_orient == idv(IDOFF_ORIENT_TOP)) then
            flags = wxBK_TOP()
        else if (g_orient == idv(IDOFF_ORIENT_BOTTOM)) then
            flags = wxBK_BOTTOM()
        else if (g_orient == idv(IDOFF_ORIENT_LEFT)) then
            flags = wxBK_LEFT()
        else if (g_orient == idv(IDOFF_ORIENT_RIGHT)) then
            flags = wxBK_RIGHT()
        end if

        if (g_fixedWidth .and. g_type == TYPE_NOTEBOOK) &
            flags = ior(flags, wxNB_FIXEDWIDTH())
        if (g_multi .and. g_type == TYPE_NOTEBOOK) &
            flags = ior(flags, wxNB_MULTILINE())
        if (g_noPageTheme .and. g_type == TYPE_NOTEBOOK) &
            flags = ior(flags, wxNB_NOPAGETHEME())
        if (g_buttonBar .and. g_type == TYPE_TOOLBOOK) &
            flags = ior(flags, wxTBK_BUTTONBAR())
        if (g_horzLayout .and. g_type == TYPE_TOOLBOOK) &
            flags = ior(flags, wxTBK_HORZ_LAYOUT())

        select case (g_type)
        case (TYPE_NOTEBOOK)
            new_book%ptr = wxNotebook_Create(g_panel%ptr, wxID_ANY(), &
                -1_c_int, -1_c_int, -1_c_int, -1_c_int, flags)
        case (TYPE_LISTBOOK)
            new_book%ptr = wxListbook_Create(g_panel%ptr, wxID_ANY(), &
                -1_c_int, -1_c_int, -1_c_int, -1_c_int, flags)
        case (TYPE_CHOICEBOOK)
            new_book%ptr = wxChoicebook_Create(g_panel%ptr, wxID_ANY(), &
                -1_c_int, -1_c_int, -1_c_int, -1_c_int, flags)
        case (TYPE_TREEBOOK)
            new_book%ptr = wxTreebook_Create(g_panel%ptr, wxID_ANY(), &
                -1_c_int, -1_c_int, -1_c_int, -1_c_int, flags)
        case (TYPE_TOOLBOOK)
            new_book%ptr = wxToolbook_Create(g_panel%ptr, wxID_ANY(), &
                -1_c_int, -1_c_int, -1_c_int, -1_c_int, flags)
        case (TYPE_AUINOTEBOOK)
            new_book%ptr = wxAuiNotebook_Create(g_panel%ptr, wxID_ANY(), &
                -1_c_int, -1_c_int, -1_c_int, -1_c_int, flags)
        case (TYPE_SIMPLEBOOK)
            new_book%ptr = wxSimplebook_Create(g_panel%ptr, wxID_ANY(), &
                -1_c_int, -1_c_int, -1_c_int, -1_c_int, flags)
        end select

        if (.not. new_book%is_valid()) return

        dummy = wxWindow_Hide(new_book%ptr)

        g_image_count = 0
        if (book_has_images()) call install_images(new_book, g_image_count)

        old_ptr = g_book%ptr
        old_is_tree = (g_old_book_type == TYPE_TREEBOOK)

        if (c_associated(old_ptr)) then
            count = int(wxBookCtrlBase_GetPageCount(old_ptr))
            do n = 0, count - 1
                image = get_icon_index(new_book)
                page_name = book_page_text(old_ptr, n)
                page = create_page(new_book, page_name)
                text_ptr = to_wxstring(page_name)

                if (g_type == TYPE_TREEBOOK .and. old_is_tree .and. &
                        page%is_valid()) then
                    parent = int(wxTreebook_GetPageParent(old_ptr, &
                        int(n, c_int)))
                    if (parent /= wxNOT_FOUND()) then
                        dummy = wxTreebook_InsertSubPage(new_book%ptr, &
                            int(parent, c_int), page%ptr, text_ptr, 0_c_int, &
                            int(image, c_int))
                        call wxString_Delete(text_ptr)
                        cycle
                    end if
                end if

                if (page%is_valid()) then
                    dummy = wxBookCtrlBase_AddPage(new_book%ptr, page%ptr, &
                        text_ptr, 0_c_int, int(image, c_int))
                end if
                call wxString_Delete(text_ptr)
            end do

            sel = int(wxBookCtrlBase_GetSelection(old_ptr))
            if (sel /= wxNOT_FOUND()) then
                dummy = wxBookCtrlBase_SetSelection(new_book%ptr, &
                    int(sel, c_int))
            end if

            dummy = wxSizer_DetachWindow(g_sizerFrame%ptr, old_ptr)
            dummy = wxWindow_Destroy(old_ptr)
        else
            call create_initial_pages(new_book)
        end if

        call wxSizer_InsertWindow(g_sizerFrame%ptr, 0_c_int, new_book%ptr, &
            5_c_int, ior(wxEXPAND(), wxALL()), int(g_border1, c_int), &
            c_null_ptr)
        dummy = wxSizer_ShowWindow(g_sizerFrame%ptr, new_book%ptr, 1_c_int, &
            0_c_int)
        call wxSizer_Layout(g_sizerFrame%ptr)

        g_book = new_book
        g_old_book_type = g_type
    end subroutine recreate_book

    ! Builds a 32x32 image list from the four art provider bitmaps and hands
    ! it to the book control (which owns it afterwards).
    subroutine install_images(book, count_out)
        type(wxWindow_t), intent(in) :: book
        integer, intent(out) :: count_out
        type(c_ptr) :: list, bitmap, mask

        count_out = 0
        list = wxImageList_Create(32_c_int, 32_c_int, 1_c_int, 4_c_int)
        if (.not. c_associated(list)) return
        mask = wxBitmap_CreateDefault()

        bitmap = wxArtProvider_GetBitmap(wxART_INFORMATION(), wxART_OTHER(), &
            32_c_int, 32_c_int)
        call add_art(list, bitmap, mask, count_out)

        bitmap = wxArtProvider_GetBitmap(wxART_QUESTION(), wxART_OTHER(), &
            32_c_int, 32_c_int)
        call add_art(list, bitmap, mask, count_out)

        bitmap = wxArtProvider_GetBitmap(wxART_WARNING(), wxART_OTHER(), &
            32_c_int, 32_c_int)
        call add_art(list, bitmap, mask, count_out)

        bitmap = wxArtProvider_GetBitmap(wxART_ERROR(), wxART_OTHER(), &
            32_c_int, 32_c_int)
        call add_art(list, bitmap, mask, count_out)

        if (count_out > 0) then
            call wxBookCtrlBase_AssignImageList(book%ptr, list)
        else
            call wxImageList_Delete(list)
        end if

        if (c_associated(mask)) call wxBitmap_Delete(mask)
    end subroutine install_images

    subroutine add_art(list, bitmap, mask, count_)
        type(c_ptr), intent(in) :: list, bitmap, mask
        integer, intent(inout) :: count_
        integer(c_int) :: index

        if (.not. c_associated(bitmap)) return
        if (wxBitmap_IsOk(bitmap) == 0) then
            call wxBitmap_Delete(bitmap)
            return
        end if

        index = wxImageList_AddBitmap(list, bitmap, mask)
        if (index >= 0) count_ = count_ + 1
        call wxBitmap_Delete(bitmap)
    end subroutine add_art

    ! wxMenu::AppendRadioItem()
    subroutine append_radio_item(menu, id, text)
        type(wxMenu_t), intent(in) :: menu
        integer, intent(in) :: id
        character(len=*), intent(in) :: text
        type(c_ptr) :: text_ptr, help_ptr

        text_ptr = to_wxstring(text)
        help_ptr = to_wxstring("")
        call wxMenu_AppendRadioItem(menu%ptr, int(id, c_int), text_ptr, &
            help_ptr)
        call wxString_Delete(text_ptr)
        call wxString_Delete(help_ptr)
    end subroutine append_radio_item

    ! wxMenu::Append(wxID_ANY, text, subMenu, help)
    subroutine append_sub_menu(menu, submenu, text, help)
        type(wxMenu_t), intent(in) :: menu, submenu
        character(len=*), intent(in) :: text, help
        type(c_ptr) :: text_ptr, help_ptr, item

        text_ptr = to_wxstring(text)
        help_ptr = to_wxstring(help)
        item = wxMenu_AppendSubMenu(menu%ptr, submenu%ptr, text_ptr, help_ptr)
        call wxString_Delete(text_ptr)
        call wxString_Delete(help_ptr)
    end subroutine append_sub_menu

end module notebook_core


module notebook_handlers
    use, intrinsic :: iso_c_binding
    use kwxffi
    use kwx_types
    use wx_events, only: wx_event_get_id, wx_event_get_type, &
        wx_command_event_is_checked
    use wx_frame, only: wx_frame_set_title
    use wx_window, only: wx_window_close
    use wx_string, only: to_wxstring
    use notebook_globals
    use notebook_core
    use notebook_pages, only: create_new_page, create_user_created_page
    implicit none

contains

    ! wxMessageBox() on the main frame, returning the button code.
    function message_box(message, caption, style) result(res)
        character(len=*), intent(in) :: message, caption
        integer, intent(in) :: style
        integer :: res
        type(c_ptr) :: message_ptr, caption_ptr

        message_ptr = to_wxstring(message)
        caption_ptr = to_wxstring(caption)
        res = int(kwxMessageBox(message_ptr, caption_ptr, int(style, c_int), &
            g_frame%ptr, -1_c_int, -1_c_int))
        call wxString_Delete(caption_ptr)
        call wxString_Delete(message_ptr)
    end function message_box

    ! File > Type
    subroutine on_type(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: dummy

        if (.not. c_associated(evt)) return

        g_type = wx_event_get_id(evt) - g_base_id

        if (g_book%is_valid()) then
            dummy = wxSizer_HideWindow(g_sizerFrame%ptr, g_book%ptr)
        end if

        call recreate_book()
    end subroutine on_type

    ! File > Orientation
    subroutine on_orient(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return

        g_orient = wx_event_get_id(evt)
        call recreate_book()
        call wxSizer_Layout(g_sizerFrame%ptr)
    end subroutine on_orient

    ! File > Show images
    subroutine on_show_images(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return

        g_chkShowImages = wx_command_event_is_checked(evt)
        call recreate_book()
        call wxSizer_Layout(g_sizerFrame%ptr)
    end subroutine on_show_images

    ! File > Style submenu
    subroutine on_style(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id
        logical :: checked

        if (.not. c_associated(evt)) return

        checked = wx_command_event_is_checked(evt)
        id = wx_event_get_id(evt)

        if (id == idv(IDOFF_FIXEDWIDTH)) then
            g_fixedWidth = checked
        else if (id == idv(IDOFF_MULTI)) then
            g_multi = checked
        else if (id == idv(IDOFF_NOPAGETHEME)) then
            g_noPageTheme = checked
        else if (id == idv(IDOFF_BUTTONBAR)) then
            g_buttonBar = checked
        else if (id == idv(IDOFF_HORZ_LAYOUT)) then
            g_horzLayout = checked
        end if

        call recreate_book()
        call wxSizer_Layout(g_sizerFrame%ptr)
    end subroutine on_style

    ! File > Exit
    subroutine on_exit(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: closed

        if (.not. c_associated(evt)) return

        closed = wx_window_close(g_frame, .true.)
    end subroutine on_exit

    ! Pages > Add page
    subroutine on_add_page(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxWindow_t) :: page
        character(len=:), allocatable :: label

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return

        g_page_added = g_page_added + 1
        page = create_new_page(g_book)
        label = "Added " // int_to_str(g_page_added)
        call book_add_page(g_book, page, label, .true., get_icon_index(g_book))
    end subroutine on_add_page

    ! Pages > Add page (don't select)
    subroutine on_add_page_no_select(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxWindow_t) :: page
        character(len=:), allocatable :: label

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return

        g_page_added_nosel = g_page_added_nosel + 1
        page = create_new_page(g_book)
        label = "Added " // int_to_str(g_page_added_nosel)
        call book_add_page(g_book, page, label, .false., &
            get_icon_index(g_book))
    end subroutine on_add_page_no_select

    ! Pages > Insert page
    subroutine on_insert_page(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxWindow_t) :: page
        character(len=:), allocatable :: label
        integer :: dummy

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return

        g_page_ins = g_page_ins + 1
        page = create_user_created_page(g_book)
        label = "Inserted " // int_to_str(g_page_ins)
        call book_insert_page(g_book, 0, page, label, .false., &
            get_icon_index(g_book))

        dummy = wxBookCtrlBase_SetSelection(g_book%ptr, 0_c_int)
    end subroutine on_insert_page

    ! Pages > Delete current page
    subroutine on_delete_cur_page(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: sel, dummy

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return

        sel = int(wxBookCtrlBase_GetSelection(g_book%ptr))
        if (sel /= wxNOT_FOUND()) then
            dummy = wxBookCtrlBase_DeletePage(g_book%ptr, int(sel, c_int))
        end if
    end subroutine on_delete_cur_page

    ! Pages > Delete last page
    subroutine on_delete_last_page(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: count, dummy

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return

        count = int(wxBookCtrlBase_GetPageCount(g_book%ptr))
        if (count /= 0) then
            dummy = wxBookCtrlBase_DeletePage(g_book%ptr, &
                int(count - 1, c_int))
        end if
    end subroutine on_delete_last_page

    ! Pages > Next page
    subroutine on_next_page(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return

        call wxBookCtrlBase_AdvanceSelection(g_book%ptr, 1_c_int)
    end subroutine on_next_page

    ! Pages > Change selection to 0
    subroutine on_change_selection(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: dummy

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return

        dummy = wxBookCtrlBase_ChangeSelection(g_book%ptr, 0_c_int)
    end subroutine on_change_selection

    ! Pages > Set selection to 0
    subroutine on_set_selection(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: dummy

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return

        dummy = wxBookCtrlBase_SetSelection(g_book%ptr, 0_c_int)
    end subroutine on_set_selection

    ! Pages > Show page size
    subroutine on_get_page_size(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(c_ptr) :: page_ptr, size_ptr
        integer :: pw, ph, bw, bh

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return

        page_ptr = wxBookCtrlBase_GetPage(g_book%ptr, 0_c_int)
        if (.not. c_associated(page_ptr)) return

        size_ptr = wxWindow_GetSize(page_ptr)
        pw = int(wxSize_GetWidth(size_ptr))
        ph = int(wxSize_GetHeight(size_ptr))
        call wxSize_Delete(size_ptr)

        size_ptr = wxWindow_GetSize(g_book%ptr)
        bw = int(wxSize_GetWidth(size_ptr))
        bh = int(wxSize_GetHeight(size_ptr))
        call wxSize_Delete(size_ptr)

        call log_message("Page size is (" // int_to_str(pw) // ", " // &
            int_to_str(ph) // "), book size (" // int_to_str(bw) // ", " // &
            int_to_str(bh) // ")")
    end subroutine on_get_page_size

    ! Pages > Set page size
    subroutine on_set_page_size(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return

        call wxBookCtrlBase_SetPageSize(g_book%ptr, 300_c_int, 300_c_int)
        call log_message("Page size set to (300, 300)")
    end subroutine on_set_page_size

    ! Pages > Add sub page (treebook only)
    subroutine on_add_sub_page(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxWindow_t) :: page
        character(len=:), allocatable :: label
        integer :: sel

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return
        if (g_type /= TYPE_TREEBOOK) return

        sel = int(wxBookCtrlBase_GetSelection(g_book%ptr))
        if (sel == wxNOT_FOUND()) then
            call log_error("Select the parent page first!")
            return
        end if

        g_subpage_added = g_subpage_added + 1
        page = create_new_page(g_book)
        label = " Inserted sub-page " // int_to_str(g_subpage_added)
        call book_insert_subpage(g_book, sel, page, label, .true., &
            get_icon_index(g_book))
    end subroutine on_add_sub_page

    ! Pages > Insert page before
    subroutine on_add_page_before(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxWindow_t) :: page
        character(len=:), allocatable :: label
        integer :: sel

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return

        sel = int(wxBookCtrlBase_GetSelection(g_book%ptr))
        if (sel == wxNOT_FOUND()) then
            call log_error("Select the parent page first!")
            return
        end if

        g_page_before_added = g_page_before_added + 1
        page = create_new_page(g_book)
        label = " Inserted before " // int_to_str(g_page_before_added)
        call book_insert_page(g_book, sel, page, label, .true., &
            get_icon_index(g_book))
    end subroutine on_add_page_before

    ! Pages > update UI for the treebook-only items
    subroutine on_update_tree_menu(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer(c_int) :: enable

        if (.not. c_associated(evt)) return

        enable = 0_c_int
        if (g_type == TYPE_TREEBOOK) enable = 1_c_int
        call wxUpdateUIEvent_Enable(evt, enable)
    end subroutine on_update_tree_menu

    ! EVT_IDLE: update the frame title when pages/selection change
    subroutine on_idle(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: n_pages, n_sel
        character(len=:), allocatable :: selection, title

        if (.not. c_associated(evt)) return

        n_pages = 0
        n_sel = wxNOT_FOUND()
        if (g_book%is_valid()) then
            n_pages = int(wxBookCtrlBase_GetPageCount(g_book%ptr))
            n_sel = int(wxBookCtrlBase_GetSelection(g_book%ptr))
        end if

        if (n_pages /= g_idle_pages .or. n_sel /= g_idle_sel .or. &
                transfer(g_book%ptr, 0_c_intptr_t) /= &
                transfer(g_idle_book, 0_c_intptr_t)) then
            g_idle_pages = n_pages
            g_idle_sel = n_sel
            g_idle_book = g_book%ptr

            if (n_sel == wxNOT_FOUND()) then
                selection = "not found"
            else
                selection = int_to_str(n_sel)
            end if

            title = "Notebook and friends (" // int_to_str(n_pages) // &
                " pages, selection: " // selection // ")"
            call wx_frame_set_title(g_frame, title)
        end if
    end subroutine on_idle

    ! Operations > Context help
    subroutine on_context_help(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(c_ptr) :: context_help

        if (.not. c_associated(evt)) return

        context_help = wxContextHelp_Create(g_frame%ptr, 1_c_int)
        if (c_associated(context_help)) call wxContextHelp_Delete(context_help)
    end subroutine on_context_help

    ! Operations > Hit test
    subroutine on_hit_test(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(c_ptr) :: mouse_pos, client_pos
        integer(c_long), target :: flags
        integer :: mx, my, cx, cy, page_pos
        character(len=:), allocatable :: flag_str

        if (.not. c_associated(evt)) return
        if (.not. g_book%is_valid()) return

        mouse_pos = kwxGetMousePosition()
        if (.not. c_associated(mouse_pos)) return
        mx = int(wxPoint_GetX(mouse_pos))
        my = int(wxPoint_GetY(mouse_pos))

        client_pos = wxWindow_ScreenToClient2(g_book%ptr, int(mx, c_int), &
            int(my, c_int))
        if (.not. c_associated(client_pos)) then
            call wxPoint_Delete(mouse_pos)
            return
        end if
        cx = int(wxPoint_GetX(client_pos))
        cy = int(wxPoint_GetY(client_pos))
        call wxPoint_Delete(client_pos)
        call wxPoint_Delete(mouse_pos)

        flags = 0_c_long
        page_pos = int(wxBookCtrlBase_HitTest(g_book%ptr, int(cx, c_int), &
            int(cy, c_int), c_loc(flags)))

        flag_str = ""
        call add_flag_str(flag_str, flags, wxBK_HITTEST_NOWHERE(), &
            "wxBK_HITTEST_NOWHERE")
        call add_flag_str(flag_str, flags, wxBK_HITTEST_ONICON(), &
            "wxBK_HITTEST_ONICON")
        call add_flag_str(flag_str, flags, wxBK_HITTEST_ONLABEL(), &
            "wxBK_HITTEST_ONLABEL")
        call add_flag_str(flag_str, flags, wxBK_HITTEST_ONITEM(), &
            "wxBK_HITTEST_ONITEM")
        call add_flag_str(flag_str, flags, wxBK_HITTEST_ONPAGE(), &
            "wxBK_HITTEST_ONPAGE")

        call log_message("HitTest at (" // int_to_str(mx) // "," // &
            int_to_str(my) // "): " // int_to_str(page_pos) // ": " // &
            flag_str)
    end subroutine on_hit_test

    subroutine add_flag_str(flag_str, flags, flag, flag_name)
        character(len=:), allocatable, intent(inout) :: flag_str
        integer(c_long), intent(in) :: flags
        integer, intent(in) :: flag
        character(len=*), intent(in) :: flag_name
        integer(c_long) :: value

        value = int(flag, c_long)
        if (iand(flags, value) == value) then
            if (len(flag_str) > 0) flag_str = flag_str // " | "
            flag_str = flag_str // flag_name
        end if
    end subroutine add_flag_str

    ! MyFrame::OnBookCtrl()
    subroutine on_book_ctrl(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(c_ptr) :: book_ptr
        integer :: event_type, new_sel, old_sel, cur_sel
        character(len=:), allocatable :: name_event, name_control
        character(len=:), allocatable :: veto, page_name, message
        logical :: changing

        if (.not. c_associated(evt)) return

        event_type = int(wx_event_get_type(evt))
        book_ptr = wxEvent_GetEventObject(evt)
        if (.not. c_associated(book_ptr)) book_ptr = g_book%ptr

        name_event = ""
        name_control = ""
        veto = ""
        changing = .false.

        if (event_type == int(wxEVT_NOTEBOOK_PAGE_CHANGED())) then
            name_event = "Changed"
            name_control = "wxNotebook"
        else if (event_type == int(wxEVT_NOTEBOOK_PAGE_CHANGING())) then
            name_event = "Changing"
            name_control = "wxNotebook"
            changing = .true.
        else if (event_type == int(wxEVT_LISTBOOK_PAGE_CHANGED())) then
            name_event = "Changed"
            name_control = "wxListbook"
        else if (event_type == int(wxEVT_LISTBOOK_PAGE_CHANGING())) then
            name_event = "Changing"
            name_control = "wxListbook"
            changing = .true.
        else if (event_type == int(wxEVT_CHOICEBOOK_PAGE_CHANGED())) then
            name_event = "Changed"
            name_control = "wxChoicebook"
        else if (event_type == int(wxEVT_CHOICEBOOK_PAGE_CHANGING())) then
            name_event = "Changing"
            name_control = "wxChoicebook"
            changing = .true.
        else if (event_type == int(wxEVT_TREEBOOK_PAGE_CHANGED())) then
            name_event = "Changed"
            name_control = "wxTreebook"
        else if (event_type == int(wxEVT_TREEBOOK_PAGE_CHANGING())) then
            name_event = "Changing"
            name_control = "wxTreebook"
            changing = .true.
        else if (event_type == int(wxEVT_TOOLBOOK_PAGE_CHANGED())) then
            name_event = "Changed"
            name_control = "wxToolbook"
        else if (event_type == int(wxEVT_TOOLBOOK_PAGE_CHANGING())) then
            name_event = "Changing"
            name_control = "wxToolbook"
            changing = .true.
        else if (event_type == int(wxEVT_AUINOTEBOOK_PAGE_CHANGED())) then
            name_event = "Changed"
            name_control = "wxAuiNotebook"
        else if (event_type == int(wxEVT_AUINOTEBOOK_PAGE_CHANGING())) then
            name_event = "Changing"
            name_control = "wxAuiNotebook"
            changing = .true.
        end if

        if (changing .and. c_associated(book_ptr)) then
            old_sel = int(wxBookCtrlEvent_GetOldSelection(evt))
            if (old_sel /= wxNOT_FOUND()) then
                page_name = book_page_text(book_ptr, old_sel)
                if (page_name == "Veto") then
                    if (message_box("Are you sure you want to leave this " // &
                            "page?" // achar(10) // &
                            "(This demonstrates veto-ing)", &
                            "Notebook sample", &
                            ior(wxICON_QUESTION(), wxYES_NO())) /= int(wxYES())) then
                        call wxNotifyEvent_Veto(evt)
                        veto = " (vetoed)"
                    end if
                end if
            end if
        end if

        new_sel = int(wxBookCtrlEvent_GetSelection(evt))
        old_sel = int(wxBookCtrlEvent_GetOldSelection(evt))
        cur_sel = -1
        if (c_associated(book_ptr)) &
            cur_sel = int(wxBookCtrlBase_GetSelection(book_ptr))

        g_event_num = g_event_num + 1
        message = "Event #" // int_to_str(g_event_num) // ": " // &
            name_control // ": " // name_event // " (" // &
            int_to_str(event_type) // ") new sel " // int_to_str(new_sel) // &
            ", old " // int_to_str(old_sel) // ", current " // &
            int_to_str(cur_sel) // veto
        call log_message(message)

        if (g_text%is_valid()) call wxTextCtrl_SetInsertionPointEnd(g_text%ptr)
    end subroutine on_book_ctrl

end module notebook_handlers


program notebook
    use, intrinsic :: iso_c_binding
    use wx_app
    use wx_frame
    use wx_menu, only: wx_menu_create, wx_menu_append, &
        wx_menu_append_separator, wx_menu_append_check_item, wx_menu_check
    use wx_menu_bar, only: wx_menu_bar_create, wx_menu_bar_append
    use wx_events
    use wx_text_ctrl, only: wx_text_ctrl_create
    use wx_panel, only: wx_panel_create
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add_window
    use wx_window, only: wx_window_layout, wx_window_set_sizer, wx_window_show, &
        wx_window_get_dpi_scale_factor
    use kwx_types
    use kwxffi
    use notebook_globals
    use notebook_core
    use notebook_handlers
    use notebook_icon
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxMenu_t) :: menu_type, menu_orient, menu_style
    type(wxMenu_t) :: menu_pages, menu_operations, menu_file
    type(wxMenuBar_t) :: menu_bar
    type(wxBoxSizer_t) :: sizer
    type(c_ptr) :: previous_provider, log_target, restored_target
    integer :: exit_code, dummy
    logical :: laid_out, shown
    real(c_double) :: dpi_scale

    ! MyApp::OnInit()
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    call wx_set_app_name("Notebook sample")
    call wx_init_all_image_handlers()

    ! wxHelpProvider::Set(new wxSimpleHelpProvider)
    previous_provider = wxHelpProvider_Set(wxSimpleHelpProvider_Create())

    g_base_id = int(wxID_HIGHEST())
    g_orient = idv(IDOFF_ORIENT_DEFAULT)

    ! MyFrame::MyFrame()
    no_parent%ptr = c_null_ptr
    g_frame = wx_frame_create(no_parent, wxID_ANY(), &
        "wxWidgets book controls sample", -1_c_int, -1_c_int, &
        -1_c_int, -1_c_int, wxDEFAULT_FRAME_STYLE())
    if (.not. g_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    call wxWindow_SetExtraStyle(g_frame%ptr, &
        int(wxFRAME_EX_CONTEXTHELP(), c_long))
    call set_sample_icon(g_frame)

    ! Menu of the sample
    menu_type = wx_menu_create("", 0_c_long)
    call append_radio_item(menu_type, idv(IDOFF_BOOK_NOTEBOOK), &
        "&Notebook" // achar(9) // "Ctrl-1")
    call append_radio_item(menu_type, idv(IDOFF_BOOK_LISTBOOK), &
        "&Listbook" // achar(9) // "Ctrl-2")
    call append_radio_item(menu_type, idv(IDOFF_BOOK_CHOICEBOOK), &
        "&Choicebook" // achar(9) // "Ctrl-3")
    call append_radio_item(menu_type, idv(IDOFF_BOOK_TREEBOOK), &
        "&Treebook" // achar(9) // "Ctrl-4")
    call append_radio_item(menu_type, idv(IDOFF_BOOK_TOOLBOOK), &
        "T&oolbook" // achar(9) // "Ctrl-5")
    call append_radio_item(menu_type, idv(IDOFF_BOOK_AUINOTEBOOK), &
        "&AuiNotebook" // achar(9) // "Ctrl-6")
    call append_radio_item(menu_type, idv(IDOFF_BOOK_SIMPLEBOOK), &
        "&Simple book" // achar(9) // "Ctrl-7")
    call wx_menu_check(menu_type, idv(IDOFF_BOOK_NOTEBOOK) + g_type, .true.)

    menu_orient = wx_menu_create("", 0_c_long)
    call append_radio_item(menu_orient, idv(IDOFF_ORIENT_DEFAULT), &
        "&Default" // achar(9) // "Alt-0")
    call append_radio_item(menu_orient, idv(IDOFF_ORIENT_TOP), &
        "&Top" // achar(9) // "Alt-1")
    call append_radio_item(menu_orient, idv(IDOFF_ORIENT_BOTTOM), &
        "&Bottom" // achar(9) // "Alt-2")
    call append_radio_item(menu_orient, idv(IDOFF_ORIENT_LEFT), &
        "&Left" // achar(9) // "Alt-3")
    call append_radio_item(menu_orient, idv(IDOFF_ORIENT_RIGHT), &
        "&Right" // achar(9) // "Alt-4")

    menu_style = wx_menu_create("", 0_c_long)
    call wx_menu_append_check_item(menu_style, idv(IDOFF_FIXEDWIDTH), &
        "&Fixed Width (wxNotebook)", "")
    call wx_menu_append_check_item(menu_style, idv(IDOFF_MULTI), &
        "&Multiple lines (wxNotebook)", "")
    call wx_menu_append_check_item(menu_style, idv(IDOFF_NOPAGETHEME), &
        "&No Page Theme (wxNotebook)", "")
    call wx_menu_append_check_item(menu_style, idv(IDOFF_BUTTONBAR), &
        "&Button Bar (wxToolbook)", "")
    call wx_menu_append_check_item(menu_style, idv(IDOFF_HORZ_LAYOUT), &
        "&Horizontal layout (wxToolbook)", "")

    menu_pages = wx_menu_create("", 0_c_long)
    call wx_menu_append(menu_pages, idv(IDOFF_ADD_PAGE), &
        "&Add page" // achar(9) // "Alt-A", "", .false.)
    call wx_menu_append(menu_pages, idv(IDOFF_ADD_PAGE_NO_SELECT), &
        "&Add page (don't select)" // achar(9) // "Alt-B", "", .false.)
    call wx_menu_append(menu_pages, idv(IDOFF_INSERT_PAGE), &
        "&Insert page" // achar(9) // "Alt-I", "", .false.)
    call wx_menu_append(menu_pages, idv(IDOFF_DELETE_CUR_PAGE), &
        "&Delete current page" // achar(9) // "Alt-D", "", .false.)
    call wx_menu_append(menu_pages, idv(IDOFF_DELETE_LAST_PAGE), &
        "D&elete last page" // achar(9) // "Alt-L", "", .false.)
    call wx_menu_append(menu_pages, idv(IDOFF_NEXT_PAGE), &
        "&Next page" // achar(9) // "Alt-N", "", .false.)
    call wx_menu_append_separator(menu_pages)
    call wx_menu_append(menu_pages, idv(IDOFF_ADD_PAGE_BEFORE), &
        "Insert page &before" // achar(9) // "Alt-B", "", .false.)
    call wx_menu_append(menu_pages, idv(IDOFF_ADD_SUB_PAGE), &
        "Add s&ub page" // achar(9) // "Alt-U", "", .false.)
    call wx_menu_append_separator(menu_pages)
    call wx_menu_append(menu_pages, idv(IDOFF_CHANGE_SELECTION), &
        "&Change selection to 0" // achar(9) // "Ctrl-0", "", .false.)
    call wx_menu_append(menu_pages, idv(IDOFF_SET_SELECTION), &
        "&Set selection to 0" // achar(9) // "Shift-Ctrl-0", "", .false.)
    call wx_menu_append_separator(menu_pages)
    call wx_menu_append(menu_pages, idv(IDOFF_GET_PAGE_SIZE), &
        "Sho&w page size", "", .false.)
    call wx_menu_append(menu_pages, idv(IDOFF_SET_PAGE_SIZE), &
        "Set &page size", "", .false.)

    menu_operations = wx_menu_create("", 0_c_long)
    call wx_menu_append(menu_operations, idv(IDOFF_CONTEXT_HELP), &
        "&Context help" // achar(9) // "Ctrl-F1", "", .false.)
    call wx_menu_append(menu_operations, idv(IDOFF_HITTEST), &
        "&Hit test" // achar(9) // "Ctrl-H", "", .false.)

    menu_file = wx_menu_create("", 0_c_long)
    call append_sub_menu(menu_file, menu_type, "&Type", "Type of control")
    call append_sub_menu(menu_file, menu_orient, "&Orientation", &
        "Orientation of control")
    call wx_menu_append_check_item(menu_file, idv(IDOFF_SHOW_IMAGES), &
        "&Show images" // achar(9) // "Alt-S", "")
    call append_sub_menu(menu_file, menu_style, "&Style", "Style of control")
    call wx_menu_append_separator(menu_file)
    call wx_menu_append(menu_file, wxID_EXIT(), "E&xit", &
        "Quits the application", .false.)
    call wx_menu_check(menu_file, idv(IDOFF_SHOW_IMAGES), g_chkShowImages)

    menu_bar = wx_menu_bar_create(0_c_int)
    dummy = wx_menu_bar_append(menu_bar, menu_file, "&File")
    dummy = wx_menu_bar_append(menu_bar, menu_pages, "&Pages")
    dummy = wx_menu_bar_append(menu_bar, menu_operations, "&Operations")
    call wx_frame_set_menu_bar(g_frame, menu_bar)

    ! m_panel = new wxPanel(this)
    g_panel = wx_panel_create(g_frame, wxID_ANY(), -1_c_int, -1_c_int, &
        -1_c_int, -1_c_int, 0_c_int)

    ! m_text = new wxTextCtrl(m_panel, ..., wxTE_MULTILINE | wxTE_READONLY)
    g_text = wx_text_ctrl_create(g_panel, wxID_ANY(), "", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
        int(ior(wxTE_MULTILINE(), wxTE_READONLY()), c_long))

    ! wxLog::SetActiveTarget(new wxLogTextCtrl(m_text))
    log_target = wxLogTextCtrl_Create(g_text%ptr)
    g_old_log_target = wxLog_SetActiveTarget(log_target)

    ! wxSizerFlags border sizes at the frame's DPI.
    dpi_scale = wx_window_get_dpi_scale_factor(g_frame)
    g_border1 = nint(5.0_c_double * dpi_scale)
    g_border2 = nint(10.0_c_double * dpi_scale)

    ! m_sizerFrame = new wxBoxSizer(wxVERTICAL)
    g_sizerFrame = wx_box_sizer_create(wxVERTICAL())
    call wx_sizer_add_window(g_sizerFrame, g_text, 1_c_int, &
        wxEXPAND(), 0_c_int, c_null_ptr)

    call recreate_book()

    call wx_window_set_sizer(g_panel, g_sizerFrame, .false.)
    laid_out = (wx_window_layout(g_panel) /= 0)

    sizer = wx_box_sizer_create(wxVERTICAL())
    call wx_sizer_add_window(sizer, g_panel, 1_c_int, &
        wxEXPAND(), 0_c_int, c_null_ptr)
    call wxWindow_SetSizerAndFit(g_frame%ptr, sizer%ptr, 1_c_int)

    ! Event table
    call wx_connect(g_frame, wxEVT_MENU(), on_type, &
        id=idv(IDOFF_BOOK_NOTEBOOK), last_id=idv(IDOFF_BOOK_MAX))
    call wx_connect(g_frame, wxEVT_MENU(), on_orient, &
        id=idv(IDOFF_ORIENT_DEFAULT), last_id=idv(IDOFF_ORIENT_MAX))
    call wx_connect(g_frame, wxEVT_MENU(), on_show_images, &
        id=idv(IDOFF_SHOW_IMAGES))
    call wx_connect(g_frame, wxEVT_MENU(), on_style, &
        id=idv(IDOFF_FIXEDWIDTH), last_id=idv(IDOFF_HORZ_LAYOUT))
    call wx_connect(g_frame, wxEVT_MENU(), on_exit, id=wxID_EXIT())

    call wx_connect(g_frame, wxEVT_MENU(), on_add_page, &
        id=idv(IDOFF_ADD_PAGE))
    call wx_connect(g_frame, wxEVT_MENU(), on_add_page_no_select, &
        id=idv(IDOFF_ADD_PAGE_NO_SELECT))
    call wx_connect(g_frame, wxEVT_MENU(), on_insert_page, &
        id=idv(IDOFF_INSERT_PAGE))
    call wx_connect(g_frame, wxEVT_MENU(), on_delete_cur_page, &
        id=idv(IDOFF_DELETE_CUR_PAGE))
    call wx_connect(g_frame, wxEVT_MENU(), on_delete_last_page, &
        id=idv(IDOFF_DELETE_LAST_PAGE))
    call wx_connect(g_frame, wxEVT_MENU(), on_next_page, &
        id=idv(IDOFF_NEXT_PAGE))
    call wx_connect(g_frame, wxEVT_MENU(), on_change_selection, &
        id=idv(IDOFF_CHANGE_SELECTION))
    call wx_connect(g_frame, wxEVT_MENU(), on_set_selection, &
        id=idv(IDOFF_SET_SELECTION))
    call wx_connect(g_frame, wxEVT_MENU(), on_get_page_size, &
        id=idv(IDOFF_GET_PAGE_SIZE))
    call wx_connect(g_frame, wxEVT_MENU(), on_set_page_size, &
        id=idv(IDOFF_SET_PAGE_SIZE))
    call wx_connect(g_frame, wxEVT_MENU(), on_context_help, &
        id=idv(IDOFF_CONTEXT_HELP))
    call wx_connect(g_frame, wxEVT_MENU(), on_hit_test, &
        id=idv(IDOFF_HITTEST))

    call wx_connect(g_frame, wxEVT_NOTEBOOK_PAGE_CHANGED(), on_book_ctrl)
    call wx_connect(g_frame, wxEVT_NOTEBOOK_PAGE_CHANGING(), on_book_ctrl)
    call wx_connect(g_frame, wxEVT_LISTBOOK_PAGE_CHANGED(), on_book_ctrl)
    call wx_connect(g_frame, wxEVT_LISTBOOK_PAGE_CHANGING(), on_book_ctrl)
    call wx_connect(g_frame, wxEVT_CHOICEBOOK_PAGE_CHANGED(), on_book_ctrl)
    call wx_connect(g_frame, wxEVT_CHOICEBOOK_PAGE_CHANGING(), on_book_ctrl)
    call wx_connect(g_frame, wxEVT_TREEBOOK_PAGE_CHANGED(), on_book_ctrl)
    call wx_connect(g_frame, wxEVT_TREEBOOK_PAGE_CHANGING(), on_book_ctrl)
    call wx_connect(g_frame, wxEVT_TOOLBOOK_PAGE_CHANGED(), on_book_ctrl)
    call wx_connect(g_frame, wxEVT_TOOLBOOK_PAGE_CHANGING(), on_book_ctrl)
    call wx_connect(g_frame, wxEVT_AUINOTEBOOK_PAGE_CHANGED(), on_book_ctrl)
    call wx_connect(g_frame, wxEVT_AUINOTEBOOK_PAGE_CHANGING(), on_book_ctrl)

    call wx_connect(g_frame, wxEVT_MENU(), on_add_sub_page, &
        id=idv(IDOFF_ADD_SUB_PAGE))
    call wx_connect(g_frame, wxEVT_MENU(), on_add_page_before, &
        id=idv(IDOFF_ADD_PAGE_BEFORE))
    call wx_connect(g_frame, wxEVT_UPDATE_UI(), on_update_tree_menu, &
        id=idv(IDOFF_ADD_PAGE_BEFORE), last_id=idv(IDOFF_ADD_SUB_PAGE))

    call wx_connect(g_frame, wxEVT_IDLE(), on_idle)

    ! frame->Show()
    call wx_set_top_window(g_frame)
    shown = wx_window_show(g_frame)

    ! wxApp::OnRun()
    exit_code = wx_main_loop()

    ! MyFrame::~MyFrame(): restore the previous log target and delete the
    ! text control logger.
    if (c_associated(g_old_log_target)) then
        restored_target = wxLog_SetActiveTarget(g_old_log_target)
        if (c_associated(restored_target)) call wxLogTextCtrl_Delete(restored_target)
    end if

    call wx_shutdown()

end program notebook
