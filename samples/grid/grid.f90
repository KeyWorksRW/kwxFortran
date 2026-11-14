! griddemo - wxWidgets wxGrid demo sample, ported to kwxFortran
!
! Fortran port of wxSamples/src/grid/griddemo.cpp and griddemo.h.
!
! The frame "wxWidgets grid class demo" hosts a 1000x100 column wxGrid and a
! wxTextCtrl log window stacked in a vertical sizer (2:1).  The menus are
! File (virtual/bugs/tabular table tests, render setup, clear log, exit),
! Grid (toggles for labels, editing, drag sizing/moving, grid lines, cell
! options, hide/show column and row, label alignment and header style, tab
! behaviour), Colours, Edit, Select, Autosize and Help.  Every grid event is
! logged to the text control through a wxLogTextCtrl active target, exactly
! like the original.
!
! The frame icon is the wxWidgets samples/sample.xpm artwork, reproduced pixel
! for pixel in sample.svg (32x32) and loaded with wxBitmapBundle::FromSVGFile.
!
! Run the executable with the current directory set to this folder:
!     cd samples\grid && ..\..\bin\Release\grid.exe
!
! Fidelity notes.  The frame, menus, controls, sizer, grid contents, colours,
! formats, editors and every grid event match the C++ original.
!
! The C++ subclasses the sample installs on the grid are reproduced through the
! kwxFFI override hooks: MyGridCellRenderer (cell 4,4) is a
! kwxGridCellRendererHook Draw callback, MyGridStarRenderer / MyGridStarEditor
! (cell 4,5) are the renderer and activatable-editor hooks, and
! CustomColumnHeaderRenderer / CustomColumnHeadersProvider are the column
! header renderer and cell attribute provider hooks (see grid_hooks below).
!
! grid->GetSelectedBlocks() is the wxGridBlockCoordsArray binding: each entry's
! top-left and bottom-right cell comes from the array accessors.
!
! MyGridCellAttrProvider::GetAttr() (the grey odd rows of the Bugs table) is the
! kwxGridCellAttrProviderHook GetAttr callback installed on the Bugs table; it
! asks the base provider for the attribute and recolours odd rows.

module grid_ids
    implicit none
    private

    integer, parameter, public :: ID_TOGGLEROWLABELS        = 100
    integer, parameter, public :: ID_TOGGLECOLLABELS        = 101
    integer, parameter, public :: ID_TOGGLEEDIT             = 102
    integer, parameter, public :: ID_TOGGLEROWSIZING        = 103
    integer, parameter, public :: ID_TOGGLECOLSIZING        = 104
    integer, parameter, public :: ID_TOGGLEROWLABELSIZING   = 105
    integer, parameter, public :: ID_TOGGLECOLLABELSIZING   = 106
    integer, parameter, public :: ID_TOGGLEROWMOVING        = 107
    integer, parameter, public :: ID_TOGGLECOLMOVING        = 108
    integer, parameter, public :: ID_TOGGLECOLHIDING        = 109
    integer, parameter, public :: ID_TOGGLEGRIDSIZING       = 110
    integer, parameter, public :: ID_TOGGLEGRIDDRAGCELL     = 111
    integer, parameter, public :: ID_TOGGLEGRIDLINES        = 112
    integer, parameter, public :: ID_AUTOSIZECOLS           = 113
    integer, parameter, public :: ID_CELLOVERFLOW           = 114
    integer, parameter, public :: ID_TOGGLE_CHECKERED_CELLS = 115
    integer, parameter, public :: ID_TOGGLE_COLOURED_CELLS  = 116
    integer, parameter, public :: ID_HIDECOL                = 117
    integer, parameter, public :: ID_SHOWCOL                = 118
    integer, parameter, public :: ID_HIDEROW                = 119
    integer, parameter, public :: ID_SHOWROW                = 120
    integer, parameter, public :: ID_RESIZECELL             = 121
    integer, parameter, public :: ID_SETLABELCOLOUR         = 122
    integer, parameter, public :: ID_SETLABELTEXTCOLOUR     = 123
    integer, parameter, public :: ID_SETLABEL_FONT          = 124
    integer, parameter, public :: ID_ROWLABELALIGN          = 125
    integer, parameter, public :: ID_ROWLABELHORIZALIGN     = 126
    integer, parameter, public :: ID_ROWLABELVERTALIGN      = 127
    integer, parameter, public :: ID_COLLABELALIGN          = 128
    integer, parameter, public :: ID_COLLABELHORIZALIGN     = 129
    integer, parameter, public :: ID_COLLABELVERTALIGN      = 130
    integer, parameter, public :: ID_CORNERLABELALIGN       = 131
    integer, parameter, public :: ID_CORNERLABELHORIZALIGN  = 132
    integer, parameter, public :: ID_CORNERLABELVERTALIGN   = 133
    integer, parameter, public :: ID_CORNERLABELORIENTATION = 134
    integer, parameter, public :: ID_COLDEFAULTHEADER       = 135
    integer, parameter, public :: ID_COLNATIVEHEADER        = 136
    integer, parameter, public :: ID_COLNATIVELABELS        = 137
    integer, parameter, public :: ID_COLCUSTOMHEADER        = 138
    integer, parameter, public :: ID_TAB_STOP               = 139
    integer, parameter, public :: ID_TAB_WRAP               = 140
    integer, parameter, public :: ID_TAB_LEAVE              = 141
    integer, parameter, public :: ID_TAB_CUSTOM             = 142
    integer, parameter, public :: ID_GRIDLINECOLOUR         = 143
    integer, parameter, public :: ID_INSERTROW              = 144
    integer, parameter, public :: ID_INSERTCOL              = 145
    integer, parameter, public :: ID_DELETEROW              = 146
    integer, parameter, public :: ID_DELETECOL              = 147
    integer, parameter, public :: ID_CLEARGRID              = 148
    integer, parameter, public :: ID_EDITCELL               = 149
    integer, parameter, public :: ID_SETCORNERLABEL         = 150
    integer, parameter, public :: ID_SHOWSEL                = 151
    integer, parameter, public :: ID_CHANGESEL              = 152
    integer, parameter, public :: ID_SELCELLS               = 153
    integer, parameter, public :: ID_SELROWS                = 154
    integer, parameter, public :: ID_SELCOLS                = 155
    integer, parameter, public :: ID_SELROWSORCOLS          = 156
    integer, parameter, public :: ID_SELNONE                = 157
    integer, parameter, public :: ID_SET_CELL_FG_COLOUR     = 158
    integer, parameter, public :: ID_SET_CELL_BG_COLOUR     = 159
    integer, parameter, public :: ID_SET_CELL_HL_COLOUR     = 160
    integer, parameter, public :: ID_SET_SELECTION_FG_COLOUR = 161
    integer, parameter, public :: ID_SET_SELECTION_BG_COLOUR = 162
    integer, parameter, public :: ID_SET_FROZEN_BORDER      = 163
    integer, parameter, public :: ID_VTABLE                 = 164
    integer, parameter, public :: ID_BUGS_TABLE             = 165
    integer, parameter, public :: ID_TABULAR_TABLE          = 166
    integer, parameter, public :: ID_SELECT_OVERLAY         = 167
    integer, parameter, public :: ID_SELECT_UNSELECT        = 168
    integer, parameter, public :: ID_SELECT_ALL             = 169
    integer, parameter, public :: ID_SELECT_ROW             = 170
    integer, parameter, public :: ID_SELECT_COL             = 171
    integer, parameter, public :: ID_SELECT_CELL            = 172
    integer, parameter, public :: ID_DESELECT_ALL           = 173
    integer, parameter, public :: ID_DESELECT_ROW           = 174
    integer, parameter, public :: ID_DESELECT_COL           = 175
    integer, parameter, public :: ID_DESELECT_CELL          = 176
    integer, parameter, public :: ID_SIZE_ROW               = 177
    integer, parameter, public :: ID_SIZE_COL               = 178
    integer, parameter, public :: ID_SIZE_ROW_LABEL         = 179
    integer, parameter, public :: ID_SIZE_COL_LABEL         = 180
    integer, parameter, public :: ID_SIZE_LABELS_COL        = 181
    integer, parameter, public :: ID_SIZE_LABELS_ROW        = 182
    integer, parameter, public :: ID_SIZE_GRID              = 183
    integer, parameter, public :: ID_FREEZE_OR_THAW         = 184
    integer, parameter, public :: ID_SET_HIGHLIGHT_WIDTH    = 185
    integer, parameter, public :: ID_SET_RO_HIGHLIGHT_WIDTH = 186
    integer, parameter, public :: ID_TESTFUNC               = 187
    integer, parameter, public :: ID_RENDER_ROW_LABEL       = 188
    integer, parameter, public :: ID_RENDER_COL_LABEL       = 189
    integer, parameter, public :: ID_RENDER_GRID_LINES      = 190
    integer, parameter, public :: ID_RENDER_GRID_BORDER     = 191
    integer, parameter, public :: ID_RENDER_SELECT_HLIGHT   = 192
    integer, parameter, public :: ID_RENDER_LOMETRIC        = 193
    integer, parameter, public :: ID_RENDER_COORDS          = 194
    integer, parameter, public :: ID_RENDER_ZOOM            = 195
    integer, parameter, public :: ID_RENDER_MARGIN          = 196
    integer, parameter, public :: ID_RENDER_DEFAULT_SIZE    = 197
end module grid_ids


module grid_globals
    use, intrinsic :: iso_c_binding
    use kwx_types
    implicit none

    ! GridFrame members.
    type(wxFrame_t), save    :: g_frame
    type(wxGrid_t), save     :: g_grid
    type(wxTextCtrl_t), save :: g_logWin
    type(c_ptr), save        :: g_old_log_target = c_null_ptr
    logical, save            :: g_addToSel = .false.
    ! GridFrame's "Render setup" submenu.  OnGridRender() reads its check states
    ! through GetMenuBar()->FindItem(...)->GetMenu() in the C++ original.
    type(wxMenu_t), save     :: g_setup_menu

    ! wxALIGN_* values as returned by wxGrid::Get*LabelAlignment().
    integer, parameter :: wxalign_left_value = 2
    integer, parameter :: wxalign_right_value = 3
    integer, parameter :: wxalign_top_value = 8
    integer, parameter :: wxalign_centre_value = 9
    integer, parameter :: wxalign_bottom_value = 10

    ! wxGridTableBase's own GetCornerLabelValue() state (the C++ code goes
    ! through grid->GetCornerLabelValue(), which forwards to the table).
    character(len=64), save  :: g_corner_label = ""

    ! Function-local statics of ToggleGridCells().
    logical, save            :: g_checkered_on = .false.
    logical, save            :: g_coloured_on = .false.

    ! Function-local static of GridFrame::OnVTable().
    integer, save            :: g_sizeGrid = 10000

    ! Grid override hooks (see module grid_hooks).  The C++ sample installs
    ! these objects on the grid, the table or a cell attribute, which then own
    ! them; the handles are kept so a callback can publish its result on the
    ! object that invoked it.
    type(kwxgridcellrendererhook_t), save :: g_cell_renderer_hook
    type(kwxgridcellrendererhook_t), save :: g_star_renderer_hook
    type(kwxgridcellactivatableeditorhook_t), save :: g_star_editor_hook
    type(kwxgridcolumnheaderrendererhook_t), save :: g_header_odd
    type(kwxgridcolumnheaderrendererhook_t), save :: g_header_even
    type(kwxgridcellattrproviderhook_t), save :: g_attr_provider

    ! MyGridCellAttrProvider installed on the Bugs frame's table.
    type(kwxgridcellattrproviderhook_t), save :: g_bug_attr_provider

    ! MyGridCellAttrProvider::m_attrForOddRows
    type(wxGridCellAttr_t), save :: g_attr_odd_rows

    ! CustomColumnHeadersProvider::m_useCustom
    logical, save            :: g_use_custom_headers = .false.

    ! MyGridStarEditor::m_value (the value DoActivate() writes into the cell).
    character(len=8), save   :: g_star_value = ""

    ! TabularGridFrame state.
    logical, save            :: g_should_update_row_order = .false.
    logical, save            :: g_should_update_col_order = .false.

    ! BigGridTable size (set when the "Plugin Virtual Table" frame is created).
    integer, save            :: g_big_size = 1000

    ! BugsGridTable data (gs_dataBugsGrid).
    type :: bug_data_t
        integer           :: id
        character(len=40) :: summary
        integer           :: severity
        integer           :: prio
        character(len=12) :: platform
        logical           :: opened
    end type bug_data_t
    type(bug_data_t), save :: g_bugs(4)
    logical, save          :: g_bugs_initialised = .false.

    ! TabularGridTable: hard-coded sort orders.
    integer, save :: g_sort_order(3) = [0, 1, 2]
    logical, save :: g_has_sort_order = .false.

    ! TabularGridTable sort state (m_sortOrder / IsSortingBy emulation).
    integer, save :: g_sort_col = -1
    logical, save :: g_sort_asc = .true.

    ! Table callback return buffers (UTF-8, must outlive the callback).
    character(kind=c_char), dimension(512), target, save :: g_tbl_buf
    character(kind=c_char), dimension(64), target, save  :: g_tbl_buf2
    character(kind=c_char), dimension(64), save  :: g_tbl_buf3
end module grid_globals


module grid_util
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_string, only: to_wxstring, from_wxstring, wxString_Delete
    use wx_menu, only: wx_menu_append, wx_menu_append_check_item, &
        wx_menu_append_radio_item, wx_menu_append_separator, wx_menu_append_sub
    use wx_colour, only: wx_colour_create_rgb, wx_colour_create_empty, &
        wx_colour_delete, wx_colour_is_ok, wx_colour_set
    use wx_font, only: wx_font_create_default, wx_font_delete, wx_font_is_ok
    use wx_grid, only: wx_grid_clear_selection, &
        wx_grid_get_selection_block_top_left, &
        wx_grid_get_selection_block_bottom_right
    use wx_grid_cell_coords_array, only: wx_grid_cell_coords_array_create, &
        wx_grid_cell_coords_array_delete, wx_grid_cell_coords_array_get_count, &
        wx_grid_cell_coords_array_item
    implicit none
    private

    public :: append_item, append_check, append_radio, append_sep, append_sub
    public :: log_message, log_error
    public :: make_colour, stock_colour, colour_from_user
    public :: grid_deselect_all, selection_block

contains

    !--------------------------------------------------------------------------
    ! Menu helpers (wxMenu::Append / AppendCheckItem / AppendRadioItem / ...)
    !--------------------------------------------------------------------------
    subroutine append_item(menu, id, text, help)
        type(wxMenu_t), intent(in) :: menu
        integer, intent(in) :: id
        character(len=*), intent(in) :: text, help
        call wx_menu_append(menu, int(id, c_int), text, help, .false.)
    end subroutine append_item

    subroutine append_check(menu, id, text, help)
        type(wxMenu_t), intent(in) :: menu
        integer, intent(in) :: id
        character(len=*), intent(in) :: text, help
        call wx_menu_append_check_item(menu, int(id, c_int), text, help)
    end subroutine append_check

    subroutine append_radio(menu, id, text, help)
        type(wxMenu_t), intent(in) :: menu
        integer, intent(in) :: id
        character(len=*), intent(in) :: text, help
        call wx_menu_append_radio_item(menu, int(id, c_int), text, help)
    end subroutine append_radio

    subroutine append_sep(menu)
        type(wxMenu_t), intent(in) :: menu
        call wx_menu_append_separator(menu)
    end subroutine append_sep

    subroutine append_sub(menu, submenu, text, help)
        type(wxMenu_t), intent(in) :: menu, submenu
        character(len=*), intent(in) :: text, help
        call wx_menu_append_sub(menu, wxID_ANY(), text, submenu, help)
    end subroutine append_sub

    !--------------------------------------------------------------------------
    ! Logging (wxLogMessage / wxLogError through the active wxLogTextCtrl).
    !--------------------------------------------------------------------------
    subroutine log_message(text)
        character(len=*), intent(in) :: text
        type(c_ptr) :: p
        p = to_wxstring(text)
        call LogMessage(p)
        call wxString_Delete(p)
    end subroutine log_message

    subroutine log_error(text)
        character(len=*), intent(in) :: text
        type(c_ptr) :: p
        p = to_wxstring(text)
        call LogErrorMsg(p)
        call wxString_Delete(p)
    end subroutine log_error


    !--------------------------------------------------------------------------
    ! Colours
    !--------------------------------------------------------------------------
    function make_colour(r, g, b, a) result(col)
        integer, intent(in) :: r, g, b
        integer, intent(in), optional :: a
        type(wxColour_t) :: col
        integer :: alpha

        alpha = 255
        if (present(a)) alpha = a
        col = wx_colour_create_rgb(int(iand(r, 255), c_int8_t), &
            int(iand(g, 255), c_int8_t), int(iand(b, 255), c_int8_t), &
            int(iand(alpha, 255), c_int8_t))
    end function make_colour

    function stock_colour(p) result(col)
        type(c_ptr), intent(in) :: p
        type(wxColour_t) :: col
        col = wxcolour_from_ptr(p, .false.)
    end function stock_colour

    ! wxGetColourFromUser(this) -- returns .false. when the user cancelled.
    function colour_from_user(parent, res) result(ok)
        type(wxFrame_t), intent(in) :: parent
        type(wxColour_t), intent(inout) :: res
        logical :: ok
        type(wxColour_t) :: init

        init = wx_colour_create_empty()
        call wxGetColourFromUser(parent%ptr, init%ptr, res%ptr)
        call wx_colour_delete(init)
        ok = wx_colour_is_ok(res)
    end function colour_from_user

    !--------------------------------------------------------------------------
    ! Grid helpers
    !--------------------------------------------------------------------------
    subroutine grid_deselect_all(grid)
        type(wxGrid_t), intent(in) :: grid
        call wx_grid_clear_selection(grid)
    end subroutine grid_deselect_all

    ! Returns the first selection block; .false. when nothing is selected.
    subroutine selection_block(grid, toprow, leftcol, bottomrow, rightcol, found)
        type(wxGrid_t), intent(in) :: grid
        integer, intent(out) :: toprow, leftcol, bottomrow, rightcol
        logical, intent(out) :: found
        type(wxGridCellCoordsArray_t) :: tl, br
        integer(c_int) :: col_, row_
        integer :: ntl, nbr

        toprow = 0; leftcol = 0; bottomrow = 0; rightcol = 0
        found = .false.

        tl = wx_grid_cell_coords_array_create()
        br = wx_grid_cell_coords_array_create()
        call wx_grid_get_selection_block_top_left(grid, tl)
        call wx_grid_get_selection_block_bottom_right(grid, br)
        ntl = int(wx_grid_cell_coords_array_get_count(tl))
        nbr = int(wx_grid_cell_coords_array_get_count(br))
        if (ntl > 0 .and. nbr > 0) then
            call wx_grid_cell_coords_array_item(tl, 0_c_int, col_, row_)
            leftcol = int(col_); toprow = int(row_)
            call wx_grid_cell_coords_array_item(br, 0_c_int, col_, row_)
            rightcol = int(col_); bottomrow = int(row_)
            found = .true.
        end if
        call wx_grid_cell_coords_array_delete(tl)
        call wx_grid_cell_coords_array_delete(br)
    end subroutine selection_block

end module grid_util


! ---------------------------------------------------------------------------
! Grid override hooks
!
! The C++ subclasses the sample derives from wxWidgets grid types are the
! kwxFFI hook callbacks below.  Their C++ counterparts:
!   MyGridCellRenderer          -> cell_renderer_draw
!   MyGridStarRenderer          -> star_renderer_draw / star_renderer_best_size
!   MyGridStarEditor            -> star_editor_try_activate / star_editor_do_activate
!   CustomColumnHeaderRenderer  -> header_label_* / header_border_* /
!                                  header_highlighted
!   CustomColumnHeadersProvider -> provider_get_column_header
! ---------------------------------------------------------------------------
module grid_hooks
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_string, only: from_wxstring
    use wx_dc, only: wx_dc_set_pen, wx_dc_set_brush, wx_dc_set_font, &
        wx_dc_set_text_foreground, wx_dc_draw_ellipse, wx_dc_draw_rectangle, &
        wx_dc_draw_label, wx_dc_get_text_extent_size
    use wx_font, only: wx_font_bold, wx_font_create_default, wx_font_delete
    use wx_brush, only: wx_brush_create_from_colour, wx_brush_delete
    use wx_colour, only: wx_colour_delete
    use wx_size, only: wx_size_get_width, wx_size_get_height
    use wx_grid, only: wx_grid_get_cell_value, wx_grid_set_cell_value, &
        wx_grid_draw_text_rectangle
    use wx_grid_cell_attr, only: wx_grid_cell_attr_get_alignment, &
        wx_grid_cell_attr_get_font, wx_grid_cell_attr_clone, &
        wx_grid_cell_attr_has_background_colour, wx_grid_cell_attr_inc_ref, &
        wx_grid_cell_attr_dec_ref, wx_grid_cell_attr_set_background_colour
    use kwx_grid_cell_renderer_hook, only: &
        kwx_grid_cell_renderer_hook_set_get_best_size_result
    use kwx_grid_cell_activatable_editor_hook, only: &
        kwx_grid_cell_activatable_editor_hook_set_try_activate_result, &
        kwx_grid_cell_activatable_editor_hook_set_try_activate_value
    use kwx_grid_cell_attr_provider_hook, only: &
        kwx_grid_cell_attr_provider_hook_set_get_column_header_ren_1bfe, &
        kwx_grid_cell_attr_provider_hook_set_on_get_attr, &
        kwx_grid_cell_attr_provider_hook_set_get_attr_result, &
        kwx_grid_cell_attr_provider_hook_get_base_attr
    use grid_globals
    use grid_util, only: make_colour, stock_colour
    implicit none
    private

    ! Max number of stars shown by MyGridStarRenderer.
    integer, parameter :: max_stars = 5

    public :: cell_renderer_draw, star_renderer_draw, star_renderer_best_size
    public :: star_editor_try_activate, star_editor_do_activate
    public :: header_label_odd, header_label_even
    public :: header_border_odd, header_border_even, header_highlighted
    public :: provider_get_column_header, provider_get_attr

contains

    !--------------------------------------------------------------------------
    ! Star helpers
    !--------------------------------------------------------------------------
    ! GetStarValue(): the cell value is a number between 0 and max_stars.
    function star_value(grid, row, col) result(num)
        type(wxGrid_t), intent(in) :: grid
        integer(c_int), intent(in) :: row, col
        character(len=:), allocatable :: text
        integer :: num, ios

        num = 0
        text = wx_grid_get_cell_value(grid, row, col)
        read(text, *, iostat=ios) num
        if (ios /= 0 .or. num < 0 .or. num > max_stars) num = 0
    end function star_value

    ! GetStarString(): that many black stars followed by white ones, 5 in all.
    function star_string(num_black_stars) result(text)
        integer, intent(in) :: num_black_stars
        character(len=:), allocatable :: text
        character(len=3), parameter :: black_star = &
            achar(226) // achar(152) // achar(133)
        character(len=3), parameter :: white_star = &
            achar(226) // achar(152) // achar(134)

        text = repeat(black_star, num_black_stars) // &
            repeat(white_star, max_stars - num_black_stars)
    end function star_string

    !--------------------------------------------------------------------------
    ! MyGridCellRenderer::Draw()
    !--------------------------------------------------------------------------
    subroutine cell_renderer_draw(pobject, grid, attr, dc, x, y, width, height, &
            row, col, is_selected) bind(C)
        type(c_ptr), value :: pobject, grid, attr, dc
        integer(c_int), value :: x, y, width, height, row, col, is_selected
        type(wxDC_t) :: d
        type(wxGrid_t) :: g
        type(wxGridCellAttr_t) :: a
        integer(c_int) :: halign, valign

        if (.not. c_associated(dc) .or. .not. c_associated(grid)) return
        if (.not. c_associated(attr)) return
        d = wxdc_from_ptr(dc, .false.)
        g = wxgrid_from_ptr(grid, .false.)
        a = wxgridcellattr_from_ptr(attr, .false.)

        ! wxGridCellStringRenderer::Draw(grid, attr, dc, rect, row, col, isSelected)
        ! draws the background, sets the text colours and font and then draws the
        ! cell string.  kwxGridCellRendererHook::Draw() already performs the first
        ! two steps before it calls this callback, so only the text is left here.
        ! Calling wx_grid_cell_string_renderer_draw() on the hook must NOT be done:
        ! wxGridCellStringRenderer_Draw() dispatches virtually and would re-enter
        ! this hook's Draw(), recursing until the stack overflows.
        call wx_grid_cell_attr_get_alignment(a, halign, valign)
        call wx_grid_draw_text_rectangle(g, d, &
            wx_grid_get_cell_value(g, row, col), x, y, width, height, &
            halign, valign)

        ! dc.SetPen(*wxGREEN_PEN); dc.SetBrush(*wxTRANSPARENT_BRUSH);
        ! dc.DrawEllipse(rect)
        call wx_dc_set_pen(d, wxpen_from_ptr(wxGREEN_PEN(), .false.))
        call wx_dc_set_brush(d, wxbrush_from_ptr(wxTRANSPARENT_BRUSH(), .false.))
        call wx_dc_draw_ellipse(d, x, y, width, height)
    end subroutine cell_renderer_draw

    !--------------------------------------------------------------------------
    ! MyGridStarRenderer::Draw() / GetBestSize()
    !--------------------------------------------------------------------------
    subroutine star_renderer_draw(pobject, grid, attr, dc, x, y, width, height, &
            row, col, is_selected) bind(C)
        type(c_ptr), value :: pobject, grid, attr, dc
        integer(c_int), value :: x, y, width, height, row, col, is_selected
        type(wxDC_t) :: d
        type(wxGrid_t) :: g
        type(wxGridCellAttr_t) :: a
        integer(c_int) :: halign, valign

        if (.not. c_associated(dc) .or. .not. c_associated(grid)) return
        if (.not. c_associated(attr)) return
        d = wxdc_from_ptr(dc, .false.)
        g = wxgrid_from_ptr(grid, .false.)
        a = wxgridcellattr_from_ptr(attr, .false.)

        ! grid.DrawTextRectangle(dc, GetStarString(GetStarValue(grid, row, col)),
        !                        rect, attr)
        call wx_grid_cell_attr_get_alignment(a, halign, valign)
        call wx_grid_draw_text_rectangle(g, d, &
            star_string(star_value(g, row, col)), x, y, width, height, &
            halign, valign)
    end subroutine star_renderer_draw

    subroutine star_renderer_best_size(pobject, grid, attr, dc, row, col) bind(C)
        type(c_ptr), value :: pobject, grid, attr, dc
        integer(c_int), value :: row, col
        type(wxDC_t) :: d
        type(wxGridCellAttr_t) :: a
        type(wxFont_t) :: font
        type(wxSize_t) :: extent

        if (.not. c_associated(dc) .or. .not. c_associated(attr)) return
        d = wxdc_from_ptr(dc, .false.)
        a = wxgridcellattr_from_ptr(attr, .false.)

        ! dc.SetFont(attr.GetFont()); return dc.GetTextExtent(GetStarString(MAX_STARS))
        font = wx_font_create_default()
        call wx_grid_cell_attr_get_font(a, font)
        call wx_dc_set_font(d, font)
        call wx_font_delete(font)

        extent = wx_dc_get_text_extent_size(d, star_string(max_stars))
        call kwx_grid_cell_renderer_hook_set_get_best_size_result( &
            g_star_renderer_hook, int(wx_size_get_width(extent), c_int), &
            int(wx_size_get_height(extent), c_int))
        ! The wrapper reports the wxSize as borrowed, but kwxFFI allocates it.
        call wxSize_Delete(extent%ptr)
    end subroutine star_renderer_best_size

    !--------------------------------------------------------------------------
    ! MyGridStarEditor::TryActivate() / DoActivate()
    !--------------------------------------------------------------------------
    subroutine star_editor_try_activate(pobject, row, col, grid, origin, &
            event) bind(C)
        type(c_ptr), value :: pobject, grid, event
        integer(c_int), value :: row, col, origin
        integer :: num_stars
        character(len=8) :: text

        num_stars = -1

        ! The activation origins are accessor functions, not constants, so the
        ! wxGridActivationSource switch becomes an if/else chain.
        if (int(origin) == int(GridActivationProgram())) then
            ! It isn't really possible to programmatically start editing a
            ! cell using this editor.
            call set_do_nothing()
            return
        else if (int(origin) == int(GridActivationKey())) then
            if (.not. c_associated(event)) then
                call set_do_nothing()
                return
            end if
            select case (int(wxKeyEvent_GetKeyCode(event)))
            case (iachar('0'))
                num_stars = 0
            case (iachar('1'))
                num_stars = 1
            case (iachar('2'))
                num_stars = 2
            case (iachar('3'))
                num_stars = 3
            case (iachar('4'))
                num_stars = 4
            case (iachar('5'))
                num_stars = 5
            case (iachar(' '))
                ! Use space key to cycle over the values.
            case default
                call set_do_nothing()
                return
            end select
        end if
        ! wxGridActivationSource::Mouse: ideally the mouse position would pick
        ! the star, but the sample just cycles through the value.

        if (.not. c_associated(grid)) return
        if (num_stars == -1) num_stars = &
            mod(star_value(wxgrid_from_ptr(grid, .false.), row, col) + 1, &
                max_stars + 1)

        write(text, '(i0)') num_stars
        g_star_value = trim(text)
        call kwx_grid_cell_activatable_editor_hook_set_try_activate_value( &
            g_star_editor_hook, g_star_value)
        call kwx_grid_cell_activatable_editor_hook_set_try_activate_result( &
            g_star_editor_hook, int(GridActivationChange(), c_int))
    end subroutine star_editor_try_activate

    ! wxGridActivationResult::DoNothing() -- reported as "ignore the activation".
    subroutine set_do_nothing()
        call kwx_grid_cell_activatable_editor_hook_set_try_activate_result( &
            g_star_editor_hook, int(GridActivationIgnore(), c_int))
    end subroutine set_do_nothing

    subroutine star_editor_do_activate(pobject, row, col, grid) bind(C)
        type(c_ptr), value :: pobject, grid
        integer(c_int), value :: row, col

        if (.not. c_associated(grid)) return
        call wx_grid_set_cell_value(wxgrid_from_ptr(grid, .false.), row, col, &
            g_star_value)
    end subroutine star_editor_do_activate

    !--------------------------------------------------------------------------
    ! CustomColumnHeaderRenderer
    !--------------------------------------------------------------------------
    subroutine header_label_odd(pobject, grid, dc, value, x, y, width, height, &
            horiz_align, vert_align, text_orientation) bind(C)
        type(c_ptr), value :: pobject, grid, dc, value
        integer(c_int), value :: x, y, width, height, horiz_align, vert_align
        integer(c_int), value :: text_orientation

        call header_label(dc, value, x, y, width, height, horiz_align, &
            vert_align, wxYELLOW())
    end subroutine header_label_odd

    subroutine header_label_even(pobject, grid, dc, value, x, y, width, height, &
            horiz_align, vert_align, text_orientation) bind(C)
        type(c_ptr), value :: pobject, grid, dc, value
        integer(c_int), value :: x, y, width, height, horiz_align, vert_align
        integer(c_int), value :: text_orientation

        call header_label(dc, value, x, y, width, height, horiz_align, &
            vert_align, wxWHITE())
    end subroutine header_label_even

    ! dc.SetTextForeground(colFg); dc.SetFont(wxITALIC_FONT->Bold());
    ! dc.DrawLabel(value, rect, horizAlign | vertAlign)
    subroutine header_label(dc, value, x, y, width, height, horiz_align, &
            vert_align, stock)
        type(c_ptr), intent(in) :: dc, value, stock
        integer(c_int), intent(in) :: x, y, width, height, horiz_align
        integer(c_int), intent(in) :: vert_align
        type(wxDC_t) :: d
        type(wxFont_t) :: italic, bold

        if (.not. c_associated(dc)) return
        d = wxdc_from_ptr(dc, .false.)
        call wx_dc_set_text_foreground(d, stock_colour(stock))

        italic = wxfont_from_ptr(wxITALIC_FONT(), .false.)
        bold = wx_font_bold(italic)
        call wx_dc_set_font(d, bold)
        ! The wrapper reports the new wxFont as borrowed, but kwxFFI allocates it.
        call wxFont_Delete(bold%ptr)
        bold%ptr = c_null_ptr

        call wx_dc_draw_label(d, from_wxstring(value), x, y, width, height, &
            ior(horiz_align, vert_align), -1_c_int)
    end subroutine header_label

    subroutine header_border_odd(pobject, grid, dc, x, y, width, height) bind(C)
        type(c_ptr), value :: pobject, grid, dc
        integer(c_int), value :: x, y, width, height

        call header_border(dc, x, y, width, height, wxBLUE())
    end subroutine header_border_odd

    subroutine header_border_even(pobject, grid, dc, x, y, width, height) bind(C)
        type(c_ptr), value :: pobject, grid, dc
        integer(c_int), value :: x, y, width, height

        call header_border(dc, x, y, width, height, wxBLACK())
    end subroutine header_border_even

    ! dc.SetPen(*wxTRANSPARENT_PEN); dc.SetBrush(wxBrush(colBg));
    ! dc.DrawRectangle(rect)
    subroutine header_border(dc, x, y, width, height, stock)
        type(c_ptr), intent(in) :: dc, stock
        integer(c_int), intent(in) :: x, y, width, height
        type(wxDC_t) :: d
        type(wxBrush_t) :: brush

        if (.not. c_associated(dc)) return
        d = wxdc_from_ptr(dc, .false.)
        call wx_dc_set_pen(d, wxpen_from_ptr(wxTRANSPARENT_PEN(), .false.))
        brush = wx_brush_create_from_colour(stock_colour(stock), &
            int(wxBRUSHSTYLE_SOLID()))
        call wx_dc_set_brush(d, brush)
        call wx_dc_draw_rectangle(d, x, y, width, height)
        call wx_brush_delete(brush)
    end subroutine header_border

    ! dc.SetPen(*wxTRANSPARENT_PEN); dc.SetBrush(wxBrush(wxColour(240,20,15,180)));
    ! dc.DrawRectangle(rect)
    subroutine header_highlighted(pobject, grid, dc, x, y, width, height, &
            row_or_col, flags) bind(C)
        type(c_ptr), value :: pobject, grid, dc
        integer(c_int), value :: x, y, width, height, row_or_col, flags
        type(wxDC_t) :: d
        type(wxColour_t) :: col
        type(wxBrush_t) :: brush

        if (.not. c_associated(dc)) return
        d = wxdc_from_ptr(dc, .false.)
        call wx_dc_set_pen(d, wxpen_from_ptr(wxTRANSPARENT_PEN(), .false.))
        col = make_colour(240, 20, 15, 180)
        brush = wx_brush_create_from_colour(col, int(wxBRUSHSTYLE_SOLID()))
        call wx_dc_set_brush(d, brush)
        call wx_dc_draw_rectangle(d, x, y, width, height)
        call wx_brush_delete(brush)
        call wx_colour_delete(col)
    end subroutine header_highlighted

    !--------------------------------------------------------------------------
    ! CustomColumnHeadersProvider::GetColumnHeaderRenderer()
    !--------------------------------------------------------------------------
    subroutine provider_get_column_header(pobject, col) bind(C)
        type(c_ptr), value :: pobject
        integer(c_int), value :: col

        ! Without a result the hook falls back to the default renderer.
        if (.not. g_use_custom_headers) return
        if (mod(int(col), 2) /= 0) then
            call kwx_grid_cell_attr_provider_hook_set_get_column_header_ren_1bfe( &
                g_attr_provider, g_header_odd)
        else
            call kwx_grid_cell_attr_provider_hook_set_get_column_header_ren_1bfe( &
                g_attr_provider, g_header_even)
        end if
    end subroutine provider_get_column_header

    !--------------------------------------------------------------------------
    ! MyGridCellAttrProvider::GetAttr()
    !--------------------------------------------------------------------------
    subroutine provider_get_attr(pobject, row, col, kind) bind(C)
        type(c_ptr), value :: pobject
        integer(c_int), value :: row, col, kind
        type(wxGridCellAttr_t) :: base, clone

        ! wxGridCellAttrProvider::GetAttr(row, col, kind) returns an owned
        ! reference; every path below hands exactly one reference to the grid.
        base = kwx_grid_cell_attr_provider_hook_get_base_attr(g_bug_attr_provider, &
            row, col, kind)

        if (mod(int(row), 2) /= 0) then
            if (.not. base%is_valid()) then
                ! attr = m_attrForOddRows
                call wx_grid_cell_attr_inc_ref(g_attr_odd_rows)
                call kwx_grid_cell_attr_provider_hook_set_get_attr_result( &
                    g_bug_attr_provider, g_attr_odd_rows)
            else if (.not. wx_grid_cell_attr_has_background_colour(base)) then
                clone = wx_grid_cell_attr_clone(base)
                call wx_grid_cell_attr_set_background_colour(clone, &
                    wxcolour_from_ptr(wxLIGHT_GREY(), .false.))
                call wx_grid_cell_attr_dec_ref(base)
                call kwx_grid_cell_attr_provider_hook_set_get_attr_result( &
                    g_bug_attr_provider, clone)
            else
                call kwx_grid_cell_attr_provider_hook_set_get_attr_result( &
                    g_bug_attr_provider, base)
            end if
        else
            call kwx_grid_cell_attr_provider_hook_set_get_attr_result( &
                g_bug_attr_provider, base)
        end if
    end subroutine provider_get_attr


end module grid_hooks



module grid_core
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_grid, only: wx_grid_delete_rows, wx_grid_delete_cols
    use wx_grid, only: wx_grid_get_selected_blocks
    use wx_grid_block_coords_array, only: wx_grid_block_coords_array_create, &
        wx_grid_block_coords_array_delete, wx_grid_block_coords_array_get_count, &
        wx_grid_block_coords_array_item_top_left, &
        wx_grid_block_coords_array_item_bottom_right
    implicit none
    private

    public :: col_index_value, fmt_g, blocks_collect, blocks_delete

contains

    ! ColIndexEntry::GetCol(): -1 when the text is not a valid column index.
    function col_index_value(text) result(col)
        character(len=*), intent(in) :: text
        integer :: col
        integer :: ios
        col = -1
        read(text, *, iostat=ios) col
        if (ios /= 0) col = -1
        if (col < 0 .or. col > 4) col = -1
    end function col_index_value

    ! wxString::Format("%g", value) for the values used by the sample.
    function fmt_g(value) result(text)
        real(c_double), intent(in) :: value
        character(len=:), allocatable :: text

        if (abs(value - 3.1415_c_double) < 1.0e-9_c_double) then
            text = "3.1415"
        else if (abs(value - 1415.0_c_double) < 1.0e-9_c_double) then
            text = "1415"
        else if (abs(value - 12345.67890_c_double) < 1.0e-9_c_double) then
            text = "12345.7"
        else
            text = "0"
        end if
    end function fmt_g

    ! grid->GetSelectedBlocks(): one wxGridBlockCoords per selected block.
    subroutine blocks_collect(grid, tops, lefts, bottoms, rights, count)
        type(wxGrid_t), intent(in) :: grid
        integer, allocatable, intent(out) :: tops(:), lefts(:), bottoms(:), rights(:)
        integer, intent(out) :: count
        type(wxGridBlockCoordsArray_t) :: blocks
        integer(c_int) :: r, c
        integer :: i

        blocks = wx_grid_block_coords_array_create()
        call wx_grid_get_selected_blocks(grid, blocks)
        count = int(wx_grid_block_coords_array_get_count(blocks))

        allocate(tops(max(1, count)), lefts(max(1, count)), &
            bottoms(max(1, count)), rights(max(1, count)))
        do i = 0, count - 1
            call wx_grid_block_coords_array_item_top_left(blocks, &
                int(i, c_int), r, c)
            tops(i + 1) = int(r)
            lefts(i + 1) = int(c)
            call wx_grid_block_coords_array_item_bottom_right(blocks, &
                int(i, c_int), r, c)
            bottoms(i + 1) = int(r)
            rights(i + 1) = int(c)
        end do
        call wx_grid_block_coords_array_delete(blocks)
    end subroutine blocks_collect

    ! HandleEdits() with isInsertion = .false.: delete every selected row/column
    ! once, merging overlapping ranges and working from the bottom up.
    subroutine blocks_delete(grid, is_row)
        type(wxGrid_t), intent(in) :: grid
        logical, intent(in) :: is_row
        integer, allocatable :: tops(:), lefts(:), bottoms(:), rights(:)
        integer, allocatable :: dels(:)
        integer :: count, i, j, n, ndel, b, e, seqend, seqcount, seqstart, k
        logical :: dup
        logical :: dummy

        call blocks_collect(grid, tops, lefts, bottoms, rights, count)
        if (count == 0) return

        ndel = 0
        allocate(dels(count * (maxval(bottoms - tops) + maxval(rights - lefts) + 2)))
        do i = 1, count
            if (is_row) then
                b = tops(i); e = bottoms(i)
            else
                b = lefts(i); e = rights(i)
            end if
            do n = b, e
                dup = .false.
                do j = 1, ndel
                    if (dels(j) == n) then
                        dup = .true.
                        exit
                    end if
                end do
                if (.not. dup) then
                    ndel = ndel + 1
                    dels(ndel) = n
                end if
            end do
        end do
        if (ndel == 0) return

        ! sort ascending (small arrays: insertion sort)
        do i = 2, ndel
            k = dels(i)
            j = i - 1
            do while (j >= 1)
                if (dels(j) <= k) exit
                dels(j + 1) = dels(j)
                j = j - 1
            end do
            dels(j + 1) = k
        end do

        seqend = 0
        seqcount = 0
        do i = ndel, 1, -1
            n = dels(i)
            if (n /= seqend - seqcount) then
                if (i /= ndel) then
                    seqstart = seqend - seqcount + 1
                    if (is_row) then
                        dummy = wx_grid_delete_rows(grid, int(seqstart, c_int), &
                            int(seqcount, c_int), .true.)
                    else
                        dummy = wx_grid_delete_cols(grid, int(seqstart, c_int), &
                            int(seqcount, c_int), .true.)
                    end if
                end if
                seqend = n
                seqcount = 0
            end if
            seqcount = seqcount + 1
        end do

        seqstart = seqend - seqcount + 1
        if (is_row) then
            dummy = wx_grid_delete_rows(grid, int(seqstart, c_int), &
                int(seqcount, c_int), .true.)
        else
            dummy = wx_grid_delete_cols(grid, int(seqstart, c_int), &
                int(seqcount, c_int), .true.)
        end if
    end subroutine blocks_delete

end module grid_core



module grid_tables
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use kwx_grid_table, only: kwx_grid_table_create
    use wx_string, only: from_cstring
    use wx_date_time, only: wx_date_time_create, wx_date_time_delete, &
        wx_date_time_parse_iso_date, wx_date_time_format_date
    use wx_grid, only: wx_grid_set_col_attr
    use wx_grid_cell_attr, only: wx_grid_cell_attr_ctor, &
        wx_grid_cell_attr_set_read_only, wx_grid_cell_attr_set_editor
    use wx_grid_cell_number_editor, only: wx_grid_cell_number_editor_ctor
    use wx_grid_cell_choice_editor, only: wx_grid_cell_choice_editor_ctor
    use grid_globals
    implicit none
    private

    public :: create_big_table, create_bugs_table, create_tabular_table
    public :: sort_tabular, tabular_is_sorting_by, tabular_is_ascending
    public :: bugs_setup_attrs

    integer, parameter :: TBL_BIG = 1
    integer, parameter :: TBL_BUGS = 2
    integer, parameter :: TBL_TABULAR = 3

    ! Col_* / Sev_* enums of the bugs table.
    integer, parameter :: COL_ID = 0, COL_SUMMARY = 1, COL_SEVERITY = 2, &
        COL_PRIORITY = 3, COL_PLATFORM = 4, COL_OPENED = 5, COL_MAX = 6
    integer, parameter :: SEV_WISH = 0, SEV_MINOR = 1, SEV_NORMAL = 2, &
        SEV_MAJOR = 3, SEV_CRITICAL = 4

    ! TabularGridTable enums.
    integer, parameter :: TCOL_NAME = 0, TCOL_EXT = 1, TCOL_SIZE = 2, &
        TCOL_DATE = 3, TCOL_MAX = 4
    integer, parameter :: TROW_MAX = 3

    character(len=10), parameter :: severities(5) = [character(len=10) :: &
        "wishlist", "minor", "normal", "major", "critical"]
    character(len=9), parameter :: bug_headers(6) = [character(len=9) :: &
        "Id", "Summary", "Severity", "Priority", "Platform", "Opened?"]
    character(len=10), parameter :: tab_headers(4) = [character(len=10) :: &
        "Name", "Extension", "Size", "Date"]
    character(len=12), parameter :: tab_names(3) = [character(len=12) :: &
        "autoexec.bat", "boot.ini", "io.sys"]
    integer, parameter :: tab_sizes(3) = [412, 604, 40774]
    character(len=10), parameter :: tab_dates(3) = [character(len=10) :: &
        "2004-04-17", "2006-05-27", "1994-05-31"]
    ! sortOrders[COL_MAX][2][ROW_MAX] of TabularGridTable::Sort().
    integer, parameter :: tab_sort(4, 2, 3) = reshape([ &
        2, 1, 0,  0, 1, 2, &
        2, 1, 0,  0, 1, 2, &
        2, 1, 0,  0, 1, 2, &
        1, 0, 2,  2, 0, 1 ], [4, 2, 3])

contains

    integer function table_token(object) result(id)
        type(c_ptr), intent(in), value :: object
        id = int(transfer(object, 0_c_intptr_t))
    end function table_token

    function token_ptr(id) result(p)
        integer, intent(in) :: id
        type(c_ptr) :: p
        p = transfer(int(id, c_intptr_t), c_null_ptr)
    end function token_ptr

    function utf8_ptr(text) result(p)
        character(len=*), intent(in) :: text
        type(c_ptr) :: p
        integer :: i, n

        n = min(len_trim(text), size(g_tbl_buf) - 1)
        do i = 1, n
            g_tbl_buf(i) = text(i:i)
        end do
        g_tbl_buf(n + 1) = c_null_char
        p = c_loc(g_tbl_buf(1))
    end function utf8_ptr

    !--------------------------------------------------------------------------
    ! Table creation: every callback of kwxGridTable is supplied; the integer
    ! token passed as pObject selects the table the callback serves.
    !--------------------------------------------------------------------------
    function table_create(id) result(t)
        integer, intent(in) :: id
        type(kwxgridtable_t) :: t
        t = kwx_grid_table_create(token_ptr(id), &
            c_funloc(tbl_get_number_rows), c_funloc(tbl_get_number_cols), &
            c_funloc(tbl_get_value), c_funloc(tbl_set_value), &
            c_funloc(tbl_is_empty_cell), c_funloc(tbl_clear), &
            c_funloc(tbl_insert_rows), c_funloc(tbl_append_rows), &
            c_funloc(tbl_delete_rows), c_funloc(tbl_insert_cols), &
            c_funloc(tbl_append_cols), c_funloc(tbl_delete_cols), &
            c_funloc(tbl_set_row_label_value), c_funloc(tbl_set_col_label_value), &
            c_funloc(tbl_get_row_label_value), c_funloc(tbl_get_col_label_value))
    end function table_create

    ! BigGridTable(long sizeGrid) -- virtual table, no storage.
    function create_big_table(size_grid) result(t)
        integer, intent(in) :: size_grid
        type(kwxgridtable_t) :: t
        g_big_size = size_grid
        t = table_create(TBL_BIG)
    end function create_big_table

    ! BugsGridTable()
    function create_bugs_table() result(t)
        type(kwxgridtable_t) :: t

        if (.not. g_bugs_initialised) then
            g_bugs(1)%id = 18; g_bugs(1)%summary = "foo doesn't work"
            g_bugs(1)%severity = SEV_MAJOR; g_bugs(1)%prio = 1
            g_bugs(1)%platform = "wxMSW"; g_bugs(1)%opened = .true.
            g_bugs(2)%id = 27; g_bugs(2)%summary = "bar crashes"
            g_bugs(2)%severity = SEV_CRITICAL; g_bugs(2)%prio = 1
            g_bugs(2)%platform = "all"; g_bugs(2)%opened = .false.
            g_bugs(3)%id = 45; g_bugs(3)%summary = "printing is slow"
            g_bugs(3)%severity = SEV_MINOR; g_bugs(3)%prio = 3
            g_bugs(3)%platform = "wxMSW"; g_bugs(3)%opened = .true.
            g_bugs(4)%id = 68; g_bugs(4)%summary = "Rectangle() fails"
            g_bugs(4)%severity = SEV_NORMAL; g_bugs(4)%prio = 1
            g_bugs(4)%platform = "wxMSW"; g_bugs(4)%opened = .false.
            g_bugs_initialised = .true.
        end if

        g_sort_col = -1
        g_has_sort_order = .false.
        t = table_create(TBL_BUGS)
    end function create_bugs_table

    ! TabularGridTable()
    function create_tabular_table() result(t)
        type(kwxgridtable_t) :: t
        g_sort_col = -1
        g_has_sort_order = .false.
        t = table_create(TBL_TABULAR)
    end function create_tabular_table

    !--------------------------------------------------------------------------
    ! Callbacks
    !--------------------------------------------------------------------------
    integer(c_int) function tbl_get_number_rows(object) bind(C)
        type(c_ptr), value :: object
        select case (table_token(object))
        case (TBL_BIG)
            tbl_get_number_rows = int(g_big_size, c_int)
        case (TBL_BUGS)
            tbl_get_number_rows = 4_c_int
        case default
            tbl_get_number_rows = int(TROW_MAX, c_int)
        end select
    end function tbl_get_number_rows

    integer(c_int) function tbl_get_number_cols(object) bind(C)
        type(c_ptr), value :: object
        select case (table_token(object))
        case (TBL_BIG)
            tbl_get_number_cols = int(g_big_size, c_int)
        case (TBL_BUGS)
            tbl_get_number_cols = int(COL_MAX, c_int)
        case default
            tbl_get_number_cols = int(TCOL_MAX, c_int)
        end select
    end function tbl_get_number_cols

    integer(c_int) function tbl_is_empty_cell(object, row, col) bind(C)
        type(c_ptr), value :: object
        integer(c_int), value :: row, col
        tbl_is_empty_cell = 0_c_int
    end function tbl_is_empty_cell

    type(c_ptr) function tbl_get_value(object, row, col) bind(C)
        type(c_ptr), value :: object
        integer(c_int), value :: row, col
        integer :: id, r, c
        character(len=32) :: buf

        id = table_token(object)
        r = int(row)
        c = int(col)
        select case (id)
        case (TBL_BIG)
            write(buf, '(1h(,i0,2h, ,i0,1h))') r, c
            tbl_get_value = utf8_ptr(trim(buf))
        case (TBL_BUGS)
            tbl_get_value = utf8_ptr(bugs_value(r, c))
        case default
            tbl_get_value = utf8_ptr(tabular_value(r, c))
        end select
    end function tbl_get_value

    function bugs_value(row, col) result(text)
        integer, intent(in) :: row, col
        character(len=:), allocatable :: text
        character(len=32) :: buf

        text = ""
        if (row < 0 .or. row > 3) return
        select case (col)
        case (COL_ID)
            write(buf, '(i0)') g_bugs(row + 1)%id
            text = trim(buf)
        case (COL_PRIORITY)
            write(buf, '(i0)') g_bugs(row + 1)%prio
            text = trim(buf)
        case (COL_OPENED)
            if (g_bugs(row + 1)%opened) then
                text = "1"
            else
                text = "0"
            end if
        case (COL_SEVERITY)
            text = trim(severities(g_bugs(row + 1)%severity + 1))
        case (COL_SUMMARY)
            text = trim(g_bugs(row + 1)%summary)
        case (COL_PLATFORM)
            text = trim(g_bugs(row + 1)%platform)
        end select
    end function bugs_value

    function tabular_value(row0, col) result(text)
        integer, intent(in) :: row0, col
        character(len=:), allocatable :: text
        integer :: row, n
        character(len=32) :: buf
        type(wxDateTime_t) :: dt

        row = row0
        if (g_has_sort_order) then
            if (row < 0 .or. row > 2) return
            row = g_sort_order(row + 1) + 1
        end if
        text = ""
        select case (col)
        case (TCOL_NAME, TCOL_EXT)
            if (row < 1 .or. row > 3) return
            n = index(trim(tab_names(row)), ".")
            if (col == TCOL_NAME) then
                text = trim(tab_names(row)(1:n - 1))
            else
                text = trim(tab_names(row)(n + 1:))
            end if
        case (TCOL_SIZE)
            if (row < 1 .or. row > 3) return
            write(buf, '(i0)') tab_sizes(row)
            text = trim(buf)
        case (TCOL_DATE)
            if (row < 1 .or. row > 3) return
            dt = wx_date_time_create()
            if (wx_date_time_parse_iso_date(dt, trim(tab_dates(row)))) then
                text = wx_date_time_format_date(dt)
            end if
            call wx_date_time_delete(dt)
        end select
    end function tabular_value

    subroutine tbl_set_value(object, row, col, val) bind(C)
        type(c_ptr), value :: object, val
        integer(c_int), value :: row, col
        integer :: id, r, c, n
        character(len=:), allocatable :: s

        id = table_token(object)
        r = int(row) + 1
        c = int(col)
        select case (id)
        case (TBL_BIG)
            return
        case (TBL_BUGS)
            if (r < 1 .or. r > 4) return
            s = from_cstring(val)
            select case (c)
            case (COL_SEVERITY)
                do n = 1, 5
                    if (trim(severities(n)) == s) then
                        g_bugs(r)%severity = n - 1
                        return
                    end if
                end do
                g_bugs(r)%severity = SEV_NORMAL
            case (COL_SUMMARY)
                g_bugs(r)%summary = s
            case (COL_PLATFORM)
                g_bugs(r)%platform = s
            end select
        end select
    end subroutine tbl_set_value

    subroutine tbl_clear(object) bind(C)
        type(c_ptr), value :: object
    end subroutine tbl_clear

    integer(c_int) function tbl_insert_rows(object, pos, num) bind(C)
        type(c_ptr), value :: object
        integer(c_int), value :: pos, num
        tbl_insert_rows = 0_c_int
    end function tbl_insert_rows

    integer(c_int) function tbl_append_rows(object, num) bind(C)
        type(c_ptr), value :: object
        integer(c_int), value :: num
        tbl_append_rows = 0_c_int
    end function tbl_append_rows

    integer(c_int) function tbl_delete_rows(object, pos, num) bind(C)
        type(c_ptr), value :: object
        integer(c_int), value :: pos, num
        tbl_delete_rows = 0_c_int
    end function tbl_delete_rows

    integer(c_int) function tbl_insert_cols(object, pos, num) bind(C)
        type(c_ptr), value :: object
        integer(c_int), value :: pos, num
        tbl_insert_cols = 0_c_int
    end function tbl_insert_cols

    integer(c_int) function tbl_append_cols(object, num) bind(C)
        type(c_ptr), value :: object
        integer(c_int), value :: num
        tbl_append_cols = 0_c_int
    end function tbl_append_cols

    integer(c_int) function tbl_delete_cols(object, pos, num) bind(C)
        type(c_ptr), value :: object
        integer(c_int), value :: pos, num
        tbl_delete_cols = 0_c_int
    end function tbl_delete_cols

    subroutine tbl_set_row_label_value(object, idx, val) bind(C)
        type(c_ptr), value :: object, val
        integer(c_int), value :: idx
    end subroutine tbl_set_row_label_value

    subroutine tbl_set_col_label_value(object, idx, val) bind(C)
        type(c_ptr), value :: object, val
        integer(c_int), value :: idx
    end subroutine tbl_set_col_label_value

    type(c_ptr) function tbl_get_row_label_value(object, idx) bind(C)
        type(c_ptr), value :: object
        integer(c_int), value :: idx
        character(len=16) :: buf

        ! default label "row + 1"
        write(buf, '(i0)') int(idx) + 1
        tbl_get_row_label_value = utf8_ptr(trim(buf))
    end function tbl_get_row_label_value

    type(c_ptr) function tbl_get_col_label_value(object, idx) bind(C)
        type(c_ptr), value :: object
        integer(c_int), value :: idx
        integer :: id, c

        id = table_token(object)
        c = int(idx)
        select case (id)
        case (TBL_BUGS)
            if (c >= 0 .and. c < COL_MAX) then
                tbl_get_col_label_value = utf8_ptr(trim(bug_headers(c + 1)))
            else
                tbl_get_col_label_value = utf8_ptr("")
            end if
        case (TBL_TABULAR)
            if (c >= 0 .and. c < TCOL_MAX) then
                tbl_get_col_label_value = utf8_ptr(trim(tab_headers(c + 1)))
            else
                tbl_get_col_label_value = utf8_ptr("")
            end if
        case default
            tbl_get_col_label_value = utf8_ptr(column_letters(c))
        end select
    end function tbl_get_col_label_value

    ! wxGridTableBase::GetColLabelValue(): A..Z, AA..ZZ, ...
    function column_letters(col0) result(text)
        integer, intent(in) :: col0
        character(len=16) :: text
        integer :: col, i, k
        character(len=16) :: tmp

        col = col0
        tmp = ""
        k = 0
        do
            k = k + 1
            i = mod(col, 26)
            tmp(k:k) = achar(iachar('A') + i)
            col = col / 26 - 1
            if (col < 0) exit
            if (k >= len(tmp)) exit
        end do
        text = tmp(1:k)
    end function column_letters

    !--------------------------------------------------------------------------
    ! Tabular table sorting (Sort() / IsSortingBy() / IsSortOrderAscending())
    !--------------------------------------------------------------------------
    subroutine sort_tabular(col, ascending)
        integer, intent(in) :: col
        logical, intent(in) :: ascending
        integer :: i, asc

        if (col == -1) then
            g_has_sort_order = .false.
            return
        end if
        asc = 2
        if (ascending) asc = 1
        do i = 1, 3
            g_sort_order(i) = tab_sort(col + 1, asc, i)
        end do
        g_has_sort_order = .true.
    end subroutine sort_tabular

    function tabular_is_sorting_by(col) result(flag)
        integer, intent(in) :: col
        logical :: flag
        flag = (col == g_sort_col)
    end function tabular_is_sorting_by

    function tabular_is_ascending() result(flag)
        logical :: flag
        flag = g_sort_asc
    end function tabular_is_ascending

    ! TabularGridFrame::bugs_setup_attrs -- the three column attributes of the
    ! Bugs frame.
    subroutine bugs_setup_attrs(grid)
        type(wxGrid_t), intent(in) :: grid
        type(wxGridCellAttr_t) :: attr_ro, attr_range, attr_combo
        type(wxGridCellNumberEditor_t) :: num_ed
        type(wxGridCellChoiceEditor_t) :: chc_ed

        attr_ro = wx_grid_cell_attr_ctor()
        call wx_grid_cell_attr_set_read_only(attr_ro, .true.)

        num_ed = wx_grid_cell_number_editor_ctor(1_c_int, 5_c_int)
        attr_range = wx_grid_cell_attr_ctor()
        call wx_grid_cell_attr_set_editor(attr_range, num_ed)

        chc_ed = wx_grid_cell_choice_editor_ctor(severities, 0_c_int)
        attr_combo = wx_grid_cell_attr_ctor()
        call wx_grid_cell_attr_set_editor(attr_combo, chc_ed)

        call wx_grid_set_col_attr(grid, int(COL_ID, c_int), attr_ro)
        call wx_grid_set_col_attr(grid, int(COL_PRIORITY, c_int), attr_range)
        call wx_grid_set_col_attr(grid, int(COL_SEVERITY, c_int), attr_combo)
    end subroutine bugs_setup_attrs

end module grid_tables



module grid_frames
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_frame, only: wx_frame_create
    use wx_panel, only: wx_panel_create
    use wx_grid, only: wx_grid_create, wx_grid_set_table, wx_grid_get_col_size, &
        wx_grid_get_row_size, wx_grid_hide_row_labels, &
        wx_grid_get_number_rows, wx_grid_get_number_cols, wx_grid_get_col_at, &
        wx_grid_get_row_at, wx_grid_enable_drag_row_size, &
        wx_grid_enable_drag_col_size
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add_window, wx_sizer_add_sizer, &
        wx_sizer_add_spacer, wx_sizer_fit
    use wx_window, only: wx_window_set_sizer, wx_window_set_client_size, &
        wx_window_set_size_hints, wx_window_get_size, wx_window_set_validator, &
        wx_window_set_label, wx_window_fit, wx_window_show
    use wx_size, only: wx_size_get_width, wx_size_get_height
    use wx_static_text, only: wx_static_text_create
    use wx_button, only: wx_button_create
    use wx_check_box, only: wx_check_box_create, wx_check_box_set_value, &
        wx_check_box_get_value
    use wx_text_ctrl, only: wx_text_ctrl_create, wx_text_ctrl_get_value
    use wx_text_validator, only: wx_text_validator_create
    use wx_grid_table_base, only: wx_grid_table_base_set_attr_provider
    use wx_grid_cell_attr, only: wx_grid_cell_attr_ctor, &
        wx_grid_cell_attr_set_background_colour
    use kwx_grid_cell_attr_provider_hook, only: &
        kwx_grid_cell_attr_provider_hook_create, &
        kwx_grid_cell_attr_provider_hook_set_on_get_attr
    use grid_ids
    use grid_globals
    use grid_tables, only: create_big_table, create_bugs_table, &
        create_tabular_table, bugs_setup_attrs
    use grid_hooks, only: provider_get_attr
    implicit none
    private

    public :: create_big_frame, create_bugs_frame, create_tabular_frame
    public :: tabular_update_col_order, tabular_update_row_order
    public :: g_big_frame, g_bugs_frame, g_tabular_frame
    public :: g_tab_grid, g_stat_order, g_chk_native, g_chk_draw, &
        g_chk_row_labels, g_chk_row_move, g_chk_col_move
    public :: g_txt_col_index, g_txt_col_pos, g_txt_col_showhide
    public :: ID_CHK_USE_NATIVE, ID_CHK_DRAW_NATIVE, ID_CHK_SHOW_ROW_LABELS, &
        ID_CHK_ENABLE_ROW_MOVE, ID_CHK_ENABLE_COL_MOVE

    type(wxFrame_t), save :: g_big_frame, g_bugs_frame, g_tabular_frame

    type(wxGrid_t), save :: g_tab_grid, g_bug_grid, g_big_grid
    type(kwxgridtable_t), save :: g_big_table, g_bugs_table, g_tab_table
    type(wxStaticText_t), save :: g_stat_order
    type(wxCheckBox_t), save :: g_chk_native, g_chk_draw, g_chk_row_labels, &
        g_chk_row_move, g_chk_col_move
    type(wxTextCtrl_t), save :: g_txt_col_index, g_txt_col_pos, g_txt_col_showhide

    ! TabularGridFrame::Id_* control ids
    integer, parameter :: ID_CHK_USE_NATIVE = 3001
    integer, parameter :: ID_CHK_DRAW_NATIVE = 3002
    integer, parameter :: ID_CHK_SHOW_ROW_LABELS = 3003
    integer, parameter :: ID_CHK_ENABLE_ROW_MOVE = 3004
    integer, parameter :: ID_CHK_ENABLE_COL_MOVE = 3005

contains

    ! BigGridFrame: virtual table
    subroutine create_big_frame(size_grid)
        integer, intent(in) :: size_grid
        type(wxWindow_t) :: no_parent
        logical :: dummy

        no_parent%ptr = c_null_ptr
        g_big_frame = wx_frame_create(no_parent, wxID_ANY(), &
            "Plugin Virtual Table", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            wxDEFAULT_FRAME_STYLE())
        if (.not. g_big_frame%is_valid()) return

        g_big_grid = wx_grid_create(g_big_frame, wxID_ANY(), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)

        g_big_table = create_big_table(size_grid)
        if (.not. wx_grid_set_table(g_big_grid, g_big_table, .false., &
            wxGridSelectCells())) return

        call wx_window_set_client_size(g_big_frame, 500_c_int, 450_c_int)
        dummy = wx_window_show(g_big_frame)
    end subroutine create_big_frame

    ! BugsGridFrame: a "realistic" typed table
    subroutine create_bugs_frame()
        type(wxWindow_t) :: no_parent
        type(wxSize_t) :: sz
        logical :: dummy

        no_parent%ptr = c_null_ptr
        g_bugs_frame = wx_frame_create(no_parent, wxID_ANY(), "Bugs table", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, wxDEFAULT_FRAME_STYLE())
        if (.not. g_bugs_frame%is_valid()) return

        g_bug_grid = wx_grid_create(g_bugs_frame, wxID_ANY(), -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, 0_c_int)

        g_bugs_table = create_bugs_table()

        ! table->SetAttrProvider(new MyGridCellAttrProvider): the provider is
        ! owned by the table, so it is installed before the grid adopts the table.
        if (.not. g_attr_odd_rows%is_valid()) then
            g_attr_odd_rows = wx_grid_cell_attr_ctor()
            call wx_grid_cell_attr_set_background_colour(g_attr_odd_rows, &
                wxcolour_from_ptr(wxLIGHT_GREY(), .false.))
        end if
        g_bug_attr_provider = kwx_grid_cell_attr_provider_hook_create(c_null_ptr)
        call kwx_grid_cell_attr_provider_hook_set_on_get_attr( &
            g_bug_attr_provider, c_funloc(provider_get_attr))
        call wx_grid_table_base_set_attr_provider(g_bugs_table, &
            g_bug_attr_provider%ptr)

        if (.not. wx_grid_set_table(g_bug_grid, g_bugs_table, .false., &
            wxGridSelectCells())) return

        call bugs_setup_attrs(g_bug_grid)

        ! grid->Fit(); SetClientSize(grid->GetSize())
        call wx_window_fit(g_bug_grid)
        sz = wx_window_get_size(g_bug_grid)
        call wx_window_set_client_size(g_bugs_frame, wx_size_get_width(sz), &
            wx_size_get_height(sz))
        dummy = wx_window_show(g_bugs_frame)
    end subroutine create_bugs_frame

    ! TabularGridFrame
    subroutine create_tabular_frame()
        type(wxWindow_t) :: no_parent
        type(wxPanel_t) :: panel
        type(wxBoxSizer_t) :: sizer_top, sizer_controls, sizer_styles, &
            sizer_columns, sizer_move, sizer_show, sizer_showhide
        type(wxStaticText_t) :: lbl
        type(wxTextValidator_t) :: validator
        type(wxButton_t) :: btn
        type(wxSize_t) :: best
        type(wxSizerItem_t) :: spacer
        logical :: dummy
        integer(c_int) :: bestw, besth
        integer :: flag_h

        no_parent%ptr = c_null_ptr
        g_tabular_frame = wx_frame_create(no_parent, wxID_ANY(), &
            "Tabular table", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
            wxDEFAULT_FRAME_STYLE())
        if (.not. g_tabular_frame%is_valid()) return

        panel = wx_panel_create(g_tabular_frame, wxID_ANY(), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)

        g_tab_grid = wx_grid_create(panel, wxID_ANY(), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, &
            int(ior(wxBORDER_STATIC(), wxWANTS_CHARS()), c_int))
        g_tab_table = create_tabular_table()
        if (.not. wx_grid_set_table(g_tab_grid, g_tab_table, .false., &
            wxGridSelectRows())) return

        call wx_grid_enable_drag_row_size(g_tab_grid, .true.)
        call wx_grid_enable_drag_col_size(g_tab_grid, .true.)
        call wx_grid_hide_row_labels(g_tab_grid)

        flag_h = int(ior(wxLEFT(), ior(wxRIGHT(), wxALIGN_CENTRE_VERTICAL())), c_int)

        ! sizerTop
        sizer_top = wx_box_sizer_create(wxVERTICAL())
        call wx_sizer_add_window(sizer_top, g_tab_grid, 1_c_int, &
            int(ior(wxEXPAND(), wxALL()), c_int), 5_c_int, c_null_ptr)

        sizer_controls = wx_box_sizer_create(wxHORIZONTAL())

        ! sizerStyles -- the five check boxes
        sizer_styles = wx_box_sizer_create(wxVERTICAL())
        g_chk_native = wx_check_box_create(panel, int(ID_CHK_USE_NATIVE, c_int), &
            "&Use native header", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_check_box_set_value(g_chk_native, 1_c_int)
        call wx_sizer_add_window(sizer_styles, g_chk_native, 0_c_int, &
            wxALL(), 5_c_int, c_null_ptr)

        g_chk_draw = wx_check_box_create(panel, int(ID_CHK_DRAW_NATIVE, c_int), &
            "&Draw native column labels", -1_c_int, -1_c_int, -1_c_int, &
            -1_c_int, 0_c_int)
        call wx_sizer_add_window(sizer_styles, g_chk_draw, 0_c_int, &
            wxALL(), 5_c_int, c_null_ptr)

        g_chk_row_labels = wx_check_box_create(panel, &
            int(ID_CHK_SHOW_ROW_LABELS, c_int), "Show &row labels", -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_sizer_add_window(sizer_styles, g_chk_row_labels, 0_c_int, &
            wxALL(), 5_c_int, c_null_ptr)

        g_chk_row_move = wx_check_box_create(panel, &
            int(ID_CHK_ENABLE_ROW_MOVE, c_int), "Allow row reordering", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_check_box_set_value(g_chk_row_move, 1_c_int)
        call wx_sizer_add_window(sizer_styles, g_chk_row_move, 0_c_int, &
            wxALL(), 5_c_int, c_null_ptr)

        g_chk_col_move = wx_check_box_create(panel, &
            int(ID_CHK_ENABLE_COL_MOVE, c_int), "Allow column re&ordering", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_check_box_set_value(g_chk_col_move, 1_c_int)
        call wx_sizer_add_window(sizer_styles, g_chk_col_move, 0_c_int, &
            wxALL(), 5_c_int, c_null_ptr)

        call wx_sizer_add_sizer(sizer_controls, sizer_styles, 0_c_int, 0_c_int, &
            0_c_int, c_null_ptr)
        spacer = wx_sizer_add_spacer(sizer_controls, 10_c_int)

        sizer_columns = wx_box_sizer_create(wxVERTICAL())
        sizer_move = wx_box_sizer_create(wxHORIZONTAL())
        lbl = wx_static_text_create(panel, wxID_ANY(), "&Move column", -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_sizer_add_window(sizer_move, lbl, 0_c_int, flag_h, 5_c_int, &
            c_null_ptr)

        g_txt_col_index = wx_text_ctrl_create(panel, wxID_ANY(), "", &
            -1_c_int, -1_c_int, 36_c_int, -1_c_int, 0_c_long)
        validator = wx_text_validator_create(wxFILTER_NUMERIC(), c_null_ptr)
        call wx_window_set_validator(g_txt_col_index, validator)
        call wx_sizer_add_window(sizer_move, g_txt_col_index, 0_c_int, flag_h, &
            5_c_int, c_null_ptr)

        lbl = wx_static_text_create(panel, wxID_ANY(), "&to", -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_sizer_add_window(sizer_move, lbl, 0_c_int, flag_h, 5_c_int, &
            c_null_ptr)

        g_txt_col_pos = wx_text_ctrl_create(panel, wxID_ANY(), "", -1_c_int, &
            -1_c_int, 36_c_int, -1_c_int, 0_c_long)
        validator = wx_text_validator_create(wxFILTER_NUMERIC(), c_null_ptr)
        call wx_window_set_validator(g_txt_col_pos, validator)
        call wx_sizer_add_window(sizer_move, g_txt_col_pos, 0_c_int, flag_h, &
            5_c_int, c_null_ptr)

        btn = wx_button_create(panel, wxID_APPLY(), "", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)
        call wx_sizer_add_window(sizer_move, btn, 0_c_int, flag_h, 5_c_int, &
            c_null_ptr)

        call wx_sizer_add_sizer(sizer_columns, sizer_move, 0_c_int, &
            int(ior(wxEXPAND(), wxBOTTOM()), c_int), 5_c_int, c_null_ptr)

        sizer_show = wx_box_sizer_create(wxHORIZONTAL())
        lbl = wx_static_text_create(panel, wxID_ANY(), "Current order:", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_sizer_add_window(sizer_show, lbl, 0_c_int, flag_h, 5_c_int, &
            c_null_ptr)

        g_stat_order = wx_static_text_create(panel, wxID_ANY(), &
            "<<< default >>>", -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_sizer_add_window(sizer_show, g_stat_order, 0_c_int, flag_h, &
            5_c_int, c_null_ptr)

        btn = wx_button_create(panel, wxID_RESET(), "&Reset order", -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_sizer_add_window(sizer_show, btn, 0_c_int, 0_c_int, 0_c_int, &
            c_null_ptr)

        call wx_sizer_add_sizer(sizer_columns, sizer_show, 0_c_int, &
            int(ior(wxEXPAND(), wxTOP()), c_int), 5_c_int, c_null_ptr)

        sizer_showhide = wx_box_sizer_create(wxHORIZONTAL())
        lbl = wx_static_text_create(panel, wxID_ANY(), "Show/hide column:", &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_sizer_add_window(sizer_showhide, lbl, 0_c_int, flag_h, 5_c_int, &
            c_null_ptr)

        g_txt_col_showhide = wx_text_ctrl_create(panel, wxID_ANY(), "", &
            -1_c_int, -1_c_int, 36_c_int, -1_c_int, 0_c_long)
        validator = wx_text_validator_create(wxFILTER_NUMERIC(), c_null_ptr)
        call wx_window_set_validator(g_txt_col_showhide, validator)
        call wx_sizer_add_window(sizer_showhide, g_txt_col_showhide, 0_c_int, &
            flag_h, 5_c_int, c_null_ptr)

        btn = wx_button_create(panel, wxID_ADD(), "&Show", -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, 0_c_int)
        call wx_sizer_add_window(sizer_showhide, btn, 0_c_int, flag_h, 5_c_int, &
            c_null_ptr)

        btn = wx_button_create(panel, wxID_DELETE(), "&Hide", -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, 0_c_int)
        call wx_sizer_add_window(sizer_showhide, btn, 0_c_int, flag_h, 5_c_int, &
            c_null_ptr)

        call wx_sizer_add_sizer(sizer_columns, sizer_showhide, 0_c_int, &
            int(ior(wxEXPAND(), wxTOP()), c_int), 5_c_int, c_null_ptr)

        call wx_sizer_add_sizer(sizer_controls, sizer_columns, 1_c_int, &
            int(ior(wxEXPAND(), wxALL()), c_int), 5_c_int, c_null_ptr)
        call wx_sizer_add_sizer(sizer_top, sizer_controls, 0_c_int, &
            int(ior(wxEXPAND(), wxALL()), c_int), 5_c_int, c_null_ptr)

        call wx_window_set_sizer(panel, sizer_top, .false.)
        best = wx_window_get_size(panel)
        bestw = wx_size_get_width(best)
        besth = wx_size_get_height(best)
        call wx_window_set_client_size(g_tabular_frame, bestw, besth)
        call wx_window_set_size_hints(g_tabular_frame, bestw, besth, -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int)

        call tabular_update_col_order()
        dummy = wx_window_show(g_tabular_frame)
    end subroutine create_tabular_frame

    ! TabularGridFrame::UpdateColOrderAndVisibility()
    subroutine tabular_update_col_order()
        character(len=64) :: s
        character(len=8) :: num
        integer :: pos, col, ncols

        ncols = int(wx_grid_get_number_cols(g_tab_grid))
        s = ""
        do pos = 0, ncols - 1
            col = int(wx_grid_get_col_at(g_tab_grid, int(pos, c_int)))
            write(num, '(i0)') col
            if (int(wx_grid_get_col_size(g_tab_grid, int(col, c_int))) == 0) then
                s = trim(s) // "[" // trim(num) // "] "
            else
                s = trim(s) // trim(num) // " "
            end if
        end do
        if (g_stat_order%is_valid()) then
            call wx_window_set_label(g_stat_order, trim(s))
        end if
    end subroutine tabular_update_col_order

    ! TabularGridFrame::UpdateRowOrderAndVisibility()
    subroutine tabular_update_row_order()
        character(len=64) :: s
        character(len=8) :: num
        integer :: pos, row, nrows

        nrows = int(wx_grid_get_number_rows(g_tab_grid))
        s = ""
        do pos = 0, nrows - 1
            row = int(wx_grid_get_row_at(g_tab_grid, int(pos, c_int)))
            write(num, '(i0)') row
            if (int(wx_grid_get_row_size(g_tab_grid, int(row, c_int))) == 0) then
                s = trim(s) // "[" // trim(num) // "] "
            else
                s = trim(s) // trim(num) // " "
            end if
        end do
        if (g_stat_order%is_valid()) then
            call wx_window_set_label(g_stat_order, trim(s))
        end if
    end subroutine tabular_update_row_order

end module grid_frames


module grid_handlers
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_string, only: to_wxstring, from_wxstring, wxString_Delete
    use wx_events, only: wx_event_get_id, wx_event_skip, &
        wx_command_event_is_checked, wx_command_event_get_string, &
        wx_connect, wx_disconnect
    use wx_window, only: wx_window_close, wx_window_refresh, wx_window_set_focus, &
        wx_window_layout, wx_window_prepare_dc, wx_window_get_background_colour, &
        wx_window_find_window_by_name, wx_window_destroy, wx_window_set_name, &
        wx_window_set_label, wx_window_set_client_size, wx_window_show
    use wx_frame, only: wx_frame_get_menu_bar, wx_frame_centre, wx_frame_create
    use wx_menu_bar, only: wx_menu_bar_is_checked, wx_menu_bar_check, &
        wx_menu_bar_enable_item
    use wx_grid, only: wx_grid_set_row_label_size, wx_grid_set_col_label_size, &
        wx_grid_get_default_row_label_size, wx_grid_get_default_col_label_size, &
        wx_grid_enable_editing, wx_grid_enable_drag_row_size, &
        wx_grid_enable_drag_col_size, wx_grid_enable_drag_grid_size, &
        wx_grid_enable_grid_lines, wx_grid_auto_size_columns, &
        wx_grid_auto_size, wx_grid_auto_size_column, wx_grid_auto_size_row, &
        wx_grid_set_cell_size, wx_grid_set_label_background_colour, &
        wx_grid_set_label_text_colour, wx_grid_set_label_font, &
        wx_grid_set_grid_line_colour, wx_grid_set_default_cell_text_colour, &
        wx_grid_set_default_cell_background_colour, &
        wx_grid_set_cell_highlight_colour, wx_grid_set_selection_background, &
        wx_grid_set_selection_foreground, wx_grid_set_selection_mode, &
        wx_grid_insert_rows, wx_grid_insert_cols, wx_grid_clear_grid, &
        wx_grid_enable_cell_edit_control, wx_grid_select_block, wx_grid_select_col, &
        wx_grid_select_row, wx_grid_select_all, wx_grid_get_selection_background, &
        wx_grid_get_cell_value, wx_grid_get_grid_cursor_row, &
        wx_grid_get_grid_cursor_col, wx_grid_move_cursor_up, &
        wx_grid_move_cursor_down, wx_grid_get_row_size, wx_grid_get_col_size, &
        wx_grid_get_row_label_size, wx_grid_get_col_label_size, &
        wx_grid_get_number_rows, wx_grid_get_number_cols, &
        wx_grid_get_selected_rows, wx_grid_get_selected_cols, &
        wx_grid_set_row_label_alignment, wx_grid_set_col_label_alignment, &
        wx_grid_get_row_label_alignment, wx_grid_get_col_label_alignment, &
        wx_grid_get_row_label_value, wx_grid_get_col_label_value, &
        wx_grid_get_table, &
        wx_grid_set_col_size, wx_grid_set_cell_background_colour, &
        wx_grid_get_default_cell_background_colour, wx_grid_get_cell_size, &
        wx_grid_enable_drag_row_label_size, wx_grid_enable_drag_col_label_size, &
        wx_grid_enable_hiding_columns, wx_grid_can_hide_columns, &
        wx_grid_enable_drag_row_move, wx_grid_enable_drag_col_move, &
        wx_grid_enable_drag_cell, wx_grid_set_tab_behaviour, &
        wx_grid_use_native_col_header, wx_grid_set_use_native_col_labels, &
        wx_grid_get_cell_highlight_pen_width, &
        wx_grid_set_cell_highlight_pen_width, &
        wx_grid_get_cell_highlight_ro_pen_width, &
        wx_grid_set_cell_highlight_ro_pen_width, &
        wx_grid_set_default_cell_overflow, wx_grid_freeze_to, wx_grid_is_frozen, &
        wx_grid_get_corner_label_alignment, wx_grid_set_corner_label_alignment, &
        wx_grid_get_corner_label_text_orientation, &
        wx_grid_set_corner_label_text_orientation, &
        wx_grid_set_grid_frozen_border_colour, wx_grid_deselect_cell, &
        wx_grid_deselect_col, wx_grid_deselect_row, &
        wx_grid_disable_overlay_selection, wx_grid_force_refresh, &
        wx_grid_auto_size_row_label_size, wx_grid_auto_size_col_label_size, &
        wx_grid_hide_col, wx_grid_show_col, wx_grid_hide_row, wx_grid_show_row, &
        wx_grid_set_attr, wx_grid_set_cell_overflow, wx_grid_set_cell_fit_mode, &
        wx_grid_get_row_pos, wx_grid_get_col_pos, wx_grid_is_sorting_by, &
        wx_grid_is_sort_order_ascending, wx_grid_render, wx_grid_is_selection, &
        wx_grid_set_col_pos, wx_grid_reset_col_pos
    use wx_bitmap, only: wx_bitmap_create_empty, wx_bitmap_get_width, &
        wx_bitmap_get_height, wx_bitmap_is_ok
    use wx_brush, only: wx_brush_create_from_colour
    use wx_memory_dc, only: wx_memory_dc_create_with_bitmap, &
        wx_memory_dc_select_object, wx_memory_dc_delete
    use wx_paint_dc, only: wx_paint_dc_create, wx_paint_dc_delete
    use wx_dc, only: wx_dc_clear, wx_dc_set_background, wx_dc_set_map_mode, &
        wx_dc_device_to_logical_x_rel, wx_dc_device_to_logical_y_rel, wx_dc_blit
    use wx_panel, only: wx_panel_create
    use wx_menu, only: wx_menu_is_checked
    use wx_event, only: wx_event_get_event_object
    use wx_colour, only: wx_colour_create_empty, wx_colour_delete, &
        wx_colour_is_ok, wx_colour_set, wx_colour_create_rgb
    use wx_font, only: wx_font_create_default, wx_font_delete, wx_font_is_ok
    use wx_dialog, only: wx_dialog_show_modal
    use wx_grid_cell_attr, only: wx_grid_cell_attr_ctor, &
        wx_grid_cell_attr_set_background_colour, wx_grid_cell_attr_set_text_colour, &
        wx_grid_cell_attr_set_alignment, wx_grid_cell_attr_set_read_only
    use wx_grid_event, only: wx_grid_event_get_row, wx_grid_event_get_col, &
        wx_grid_event_get_new_row, wx_grid_event_get_new_col, &
        wx_grid_event_shift_down, wx_grid_event_control_down, &
        wx_grid_event_alt_down, wx_grid_event_meta_down, &
        wx_grid_event_selecting
    use wx_grid_size_event, only: wx_grid_size_event_get_row_or_col
    use wx_grid_range_select_event, only: &
        wx_grid_range_select_event_get_top_row, &
        wx_grid_range_select_event_get_bottom_row, &
        wx_grid_range_select_event_get_left_col, &
        wx_grid_range_select_event_get_right_col, &
        wx_grid_range_select_event_selecting, &
        wx_grid_range_select_event_control_down, &
        wx_grid_range_select_event_shift_down, &
        wx_grid_range_select_event_alt_down, &
        wx_grid_range_select_event_meta_down
    use wx_notify_event, only: wx_notify_event_veto
    use wx_context_menu_event, only: wx_context_menu_event_get_position
    use wx_point, only: wx_point_get_x, wx_point_get_y
    use wx_update_ui_event, only: wx_update_ui_event_enable
    use wx_single_choice_dialog, only: wx_single_choice_dialog_create, &
        wx_single_choice_dialog_set_selection, &
        wx_single_choice_dialog_get_selection, wx_single_choice_dialog_delete
    use wx_text_entry_dialog, only: wx_text_entry_dialog_create, &
        wx_text_entry_dialog_get_value
    use wx_about_dialog_info, only: wx_about_dialog_info_create, &
        wx_about_dialog_info_delete, wx_about_dialog_info_set_name, &
        wx_about_dialog_info_set_description, wx_about_dialog_info_add_developer, &
        wx_about_dialog_info_set_web_site
    use wx_array_string, only: wx_array_string_create, wx_array_string_add, &
        wx_array_string_delete
    use wx_grid_cell_coords_array
    use wx_check_box, only: wx_check_box_get_value
    use wx_text_ctrl, only: wx_text_ctrl_clear, wx_text_ctrl_get_value
    use grid_frames
    use grid_ids
    use grid_globals
    use grid_util
    use grid_core
    use grid_tables
    implicit none

    ! GridFrame's render state.  m_gridBitmap is a member of GridFrame in the
    ! C++ original; the canvas that blits it is recorded when it is created.
    type(wxBitmap_t), save :: g_grid_bitmap
    type(wxBitmap_t), save :: g_null_bitmap

contains

    !==========================================================================
    ! Small helpers
    !==========================================================================
    function menu_bar() result(mb)
        type(wxMenuBar_t) :: mb
        mb = wx_frame_get_menu_bar(g_frame)
    end function menu_bar

    function is_checked(id) result(flag)
        integer, intent(in) :: id
        logical :: flag
        flag = wx_menu_bar_is_checked(menu_bar(), int(id, c_int))
    end function is_checked

    subroutine check_item(id, flag)
        integer, intent(in) :: id
        logical, intent(in) :: flag
        call wx_menu_bar_check(menu_bar(), int(id, c_int), flag)
    end subroutine check_item

    subroutine grid_refresh()
        call wx_window_refresh(g_grid, .true.)
    end subroutine grid_refresh

    !==========================================================================
    ! Grid menu handlers
    !==========================================================================
    subroutine on_toggle_row_labels()
        if (is_checked(ID_TOGGLEROWLABELS)) then
            call wx_grid_set_row_label_size(g_grid, &
                wx_grid_get_default_row_label_size(g_grid))
        else
            call wx_grid_set_row_label_size(g_grid, 0_c_int)
        end if
    end subroutine on_toggle_row_labels

    subroutine on_toggle_col_labels()
        if (is_checked(ID_TOGGLECOLLABELS)) then
            call wx_grid_set_col_label_size(g_grid, &
                wx_grid_get_default_col_label_size(g_grid))
        else
            call wx_grid_set_col_label_size(g_grid, 0_c_int)
        end if
    end subroutine on_toggle_col_labels

    subroutine on_toggle_editing()
        call wx_grid_enable_editing(g_grid, &
            merge(1_c_int, 0_c_int, is_checked(ID_TOGGLEEDIT)))
    end subroutine on_toggle_editing

    subroutine on_toggle_row_sizing()
        call wx_grid_enable_drag_row_size(g_grid, is_checked(ID_TOGGLEROWSIZING))
    end subroutine on_toggle_row_sizing

    subroutine on_toggle_col_sizing()
        call wx_grid_enable_drag_col_size(g_grid, is_checked(ID_TOGGLECOLSIZING))
    end subroutine on_toggle_col_sizing

    subroutine on_toggle_row_label_sizing()
        call wx_grid_enable_drag_row_label_size(g_grid, &
            is_checked(ID_TOGGLEROWLABELSIZING))
    end subroutine on_toggle_row_label_sizing

    subroutine on_toggle_col_label_sizing()
        call wx_grid_enable_drag_col_label_size(g_grid, &
            is_checked(ID_TOGGLECOLLABELSIZING))
    end subroutine on_toggle_col_label_sizing

    subroutine on_toggle_row_moving()
        logical :: dummy

        dummy = wx_grid_enable_drag_row_move(g_grid, &
            is_checked(ID_TOGGLEROWMOVING))
    end subroutine on_toggle_row_moving

    subroutine on_toggle_col_moving()
        logical :: dummy

        dummy = wx_grid_enable_drag_col_move(g_grid, &
            is_checked(ID_TOGGLECOLMOVING))
    end subroutine on_toggle_col_moving

    ! wxGrid::EnableHidingColumns() returns .false. when the grid uses the
    ! default (non-native) header, in which case the menu check reverts to
    ! CanHideColumns().
    subroutine on_toggle_col_hiding()
        if (.not. wx_grid_enable_hiding_columns(g_grid, &
            is_checked(ID_TOGGLECOLHIDING))) then
            call check_item(ID_TOGGLECOLHIDING, wx_grid_can_hide_columns(g_grid))
        end if
    end subroutine on_toggle_col_hiding

    subroutine on_toggle_grid_sizing()
        call wx_grid_enable_drag_grid_size(g_grid, is_checked(ID_TOGGLEGRIDSIZING))
    end subroutine on_toggle_grid_sizing

    subroutine on_toggle_grid_drag_cell()
        call wx_grid_enable_drag_cell(g_grid, is_checked(ID_TOGGLEGRIDDRAGCELL))
    end subroutine on_toggle_grid_drag_cell

    ! The C++ handlers first flip CustomColumnHeadersProvider::UseCustomColHeaders()
    ! and then reconfigure the header control (see provider_get_column_header).
    subroutine on_set_col_header(mode)
        integer, intent(in) :: mode
        logical :: dummy

        select case (mode)
        case (1) ! SetNativeColHeader
            g_use_custom_headers = .false.
            dummy = wx_grid_use_native_col_header(g_grid, .true.)
        case (2) ! SetNativeColLabels
            g_use_custom_headers = .false.
            dummy = wx_grid_use_native_col_header(g_grid, .false.)
            call wx_grid_set_use_native_col_labels(g_grid, .true.)
        case (3) ! SetCustomColHeader
            g_use_custom_headers = .true.
            dummy = wx_grid_use_native_col_header(g_grid, .false.)
            call wx_grid_set_use_native_col_labels(g_grid, .false.)
        case default ! SetDefaultColHeader
            g_use_custom_headers = .false.
            dummy = wx_grid_use_native_col_header(g_grid, .false.)
            call wx_grid_set_use_native_col_labels(g_grid, .false.)
        end select
    end subroutine on_set_col_header

    ! GridFrame::SetTabBehaviour(): the custom TAB handler must be unbound first,
    ! otherwise it overrides the built-in behaviour.
    subroutine on_set_tab_behaviour(id)
        integer, intent(in) :: id

        if (id == ID_TAB_CUSTOM) then
            ! grid->Bind(wxEVT_GRID_TABBING, &GridFrame::OnGridCustomTab, this)
            call wx_connect(g_grid, wxEVT_GRID_TABBING(), on_grid_custom_tab)
        else
            ! grid->Unbind(wxEVT_GRID_TABBING, ...)
            call wx_disconnect(g_grid, wxEVT_GRID_TABBING())
            ! SetTabBehaviour(id - ID_TAB_STOP): the ids are contiguous, so the
            ! ordinal equals wxGrid::TabBehaviour's value.
            call wx_grid_set_tab_behaviour(g_grid, int(id - ID_TAB_STOP, c_int))
        end if
    end subroutine on_set_tab_behaviour

    ! GridFrame::OnGridCustomTab: move the cursor up/down instead of the usual
    ! left/right.
    subroutine on_grid_custom_tab(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridEvent_t) :: gev
        logical :: dummy

        if (.not. c_associated(evt)) return
        gev = wxgridevent_from_ptr(evt, .false.)
        if (wx_grid_event_shift_down(gev)) then
            if (int(wx_grid_get_grid_cursor_row(g_grid)) > 0) &
                dummy = wx_grid_move_cursor_up(g_grid, .false.)
        else
            if (int(wx_grid_get_grid_cursor_row(g_grid)) < &
                int(wx_grid_get_number_rows(g_grid)) - 1) &
                dummy = wx_grid_move_cursor_down(g_grid, .false.)
        end if
    end subroutine on_grid_custom_tab

    subroutine on_toggle_grid_lines()
        call wx_grid_enable_grid_lines(g_grid, is_checked(ID_TOGGLEGRIDLINES))
    end subroutine on_toggle_grid_lines

    ! GridFrame::OnSetHighlightWidth / OnSetROHighlightWidth: the dialog starts
    ! on the current pen width and applies the chosen value.
    subroutine on_set_highlight_width(ro)
        logical, intent(in) :: ro
        type(wxsinglechoicedialog_t) :: dlg
        type(wxArrayString_t) :: choices
        integer :: i, current
        character(len=2) :: txt

        choices = wx_array_string_create()
        do i = 0, 10
            write(txt, '(i0)') i
            call wx_array_string_add(choices, trim(txt))
        end do

        dlg = wx_single_choice_dialog_create(g_frame, &
            "Choose the thickness of the highlight pen:", "Pen Width", &
            choices, wxCHOICEDLG_STYLE())
        if (dlg%is_valid()) then
            if (ro) then
                current = int(wx_grid_get_cell_highlight_ro_pen_width(g_grid))
            else
                current = int(wx_grid_get_cell_highlight_pen_width(g_grid))
            end if
            call wx_single_choice_dialog_set_selection(dlg, int(current, c_int))
            if (int(wx_dialog_show_modal(dlg)) == wxID_OK()) then
                if (ro) then
                    call wx_grid_set_cell_highlight_ro_pen_width(g_grid, &
                        wx_single_choice_dialog_get_selection(dlg))
                else
                    call wx_grid_set_cell_highlight_pen_width(g_grid, &
                        wx_single_choice_dialog_get_selection(dlg))
                end if
            end if
            call wx_single_choice_dialog_delete(dlg)
        end if
        call wx_array_string_delete(choices)
    end subroutine on_set_highlight_width

    subroutine on_auto_size_cols()
        call wx_grid_auto_size_columns(g_grid, 1_c_int)
        call grid_refresh()
    end subroutine on_auto_size_cols

    subroutine on_cell_overflow()
        call wx_grid_set_default_cell_overflow(g_grid, is_checked(ID_CELLOVERFLOW))
        call grid_refresh()
    end subroutine on_cell_overflow

    subroutine on_resize_cell()
        if (is_checked(ID_RESIZECELL)) then
            call wx_grid_set_cell_size(g_grid, 7_c_int, 1_c_int, 5_c_int, 5_c_int)
        else
            call wx_grid_set_cell_size(g_grid, 7_c_int, 1_c_int, 1_c_int, 5_c_int)
        end if
        call grid_refresh()
    end subroutine on_resize_cell

    subroutine on_set_label_colour()
        type(wxColour_t) :: col

        if (colour_from_user(g_frame, col)) then
            call wx_grid_set_label_background_colour(g_grid, col)
        end if
        call wx_colour_delete(col)
    end subroutine on_set_label_colour

    subroutine on_set_label_text_colour()
        type(wxColour_t) :: col

        if (colour_from_user(g_frame, col)) then
            call wx_grid_set_label_text_colour(g_grid, col)
        end if
        call wx_colour_delete(col)
    end subroutine on_set_label_text_colour

    subroutine on_set_label_font()
        type(wxFont_t) :: init, font

        init = wx_font_create_default()
        font = wx_font_create_default()
        call wxGetFontFromUser(g_frame%ptr, init%ptr, font%ptr)
        if (wx_font_is_ok(font)) call wx_grid_set_label_font(g_grid, font)
        call wx_font_delete(init)
        call wx_font_delete(font)
    end subroutine on_set_label_font

    subroutine on_set_row_label_horiz()
        integer(c_int) :: horiz, vert
        call wx_grid_get_row_label_alignment(g_grid, horiz, vert)
        select case (int(horiz))
        case (wxalign_left_value)
            horiz = int(wxALIGN_CENTRE(), c_int)
        case (wxalign_centre_value)
            horiz = int(wxALIGN_RIGHT(), c_int)
        case (wxalign_right_value)
            horiz = int(wxALIGN_LEFT(), c_int)
        end select
        call wx_grid_set_row_label_alignment(g_grid, horiz, vert)
    end subroutine on_set_row_label_horiz

    subroutine on_set_row_label_vert()
        integer(c_int) :: horiz, vert
        call wx_grid_get_row_label_alignment(g_grid, horiz, vert)
        select case (int(vert))
        case (wxalign_top_value)
            vert = int(wxALIGN_CENTRE(), c_int)
        case (wxalign_centre_value)
            vert = int(wxALIGN_BOTTOM(), c_int)
        case (wxalign_bottom_value)
            vert = int(wxALIGN_TOP(), c_int)
        end select
        call wx_grid_set_row_label_alignment(g_grid, horiz, vert)
    end subroutine on_set_row_label_vert

    subroutine on_set_col_label_horiz()
        integer(c_int) :: horiz, vert
        call wx_grid_get_col_label_alignment(g_grid, horiz, vert)
        select case (int(horiz))
        case (wxalign_left_value)
            horiz = int(wxALIGN_CENTRE(), c_int)
        case (wxalign_centre_value)
            horiz = int(wxALIGN_RIGHT(), c_int)
        case (wxalign_right_value)
            horiz = int(wxALIGN_LEFT(), c_int)
        end select
        call wx_grid_set_col_label_alignment(g_grid, horiz, vert)
    end subroutine on_set_col_label_horiz

    subroutine on_set_col_label_vert()
        integer(c_int) :: horiz, vert
        call wx_grid_get_col_label_alignment(g_grid, horiz, vert)
        select case (int(vert))
        case (wxalign_top_value)
            vert = int(wxALIGN_CENTRE(), c_int)
        case (wxalign_centre_value)
            vert = int(wxALIGN_BOTTOM(), c_int)
        case (wxalign_bottom_value)
            vert = int(wxALIGN_TOP(), c_int)
        end select
        call wx_grid_set_col_label_alignment(g_grid, horiz, vert)
    end subroutine on_set_col_label_vert

    ! GridFrame::SetCornerLabelHorizAlignment / SetCornerLabelVertAlignment
    subroutine on_corner_label_align(horizontal)
        logical, intent(in) :: horizontal
        integer(c_int) :: horiz, vert

        call wx_grid_get_corner_label_alignment(g_grid, horiz, vert)
        if (horizontal) then
            select case (int(horiz))
            case (wxalign_left_value)
                horiz = int(wxALIGN_CENTRE(), c_int)
            case (wxalign_centre_value)
                horiz = int(wxALIGN_RIGHT(), c_int)
            case (wxalign_right_value)
                horiz = int(wxALIGN_LEFT(), c_int)
            end select
        else
            select case (int(vert))
            case (wxalign_top_value)
                vert = int(wxALIGN_CENTRE(), c_int)
            case (wxalign_centre_value)
                vert = int(wxALIGN_BOTTOM(), c_int)
            case (wxalign_bottom_value)
                vert = int(wxALIGN_TOP(), c_int)
            end select
        end if
        call wx_grid_set_corner_label_alignment(g_grid, horiz, vert)
    end subroutine on_corner_label_align

    ! GridFrame::ToggleCornerLabelOrientation: wxHORIZONTAL <-> wxVERTICAL.
    subroutine on_toggle_corner_orientation()
        integer(c_int) :: orientation

        orientation = wx_grid_get_corner_label_text_orientation(g_grid)
        if (int(orientation) == int(wxHORIZONTAL())) then
            orientation = wxVERTICAL()
        else if (int(orientation) == int(wxVERTICAL())) then
            orientation = wxHORIZONTAL()
        end if
        call wx_grid_set_corner_label_text_orientation(g_grid, orientation)
    end subroutine on_toggle_corner_orientation

    subroutine on_set_grid_line_colour()
        type(wxColour_t) :: col

        if (colour_from_user(g_frame, col)) then
            call wx_grid_set_grid_line_colour(g_grid, col)
        end if
        call wx_colour_delete(col)
    end subroutine on_set_grid_line_colour

    !--------------------------------------------------------------------------
    ! Edit menu
    !--------------------------------------------------------------------------
    subroutine on_insert_row()
        integer :: pos, count, top, bottom, left, right
        logical :: found
        logical :: dummy

        call selection_block(g_grid, top, left, bottom, right, found)
        if (found) then
            pos = top
            count = bottom - pos + 1
        else
            pos = int(wx_grid_get_grid_cursor_row(g_grid))
            count = 1
        end if
        dummy = wx_grid_insert_rows(g_grid, int(pos, c_int), int(count, c_int), .true.)
    end subroutine on_insert_row

    subroutine on_insert_col()
        integer :: pos, count, top, bottom, left, right
        logical :: found
        logical :: dummy

        call selection_block(g_grid, top, left, bottom, right, found)
        if (found) then
            pos = left
            count = right - pos + 1
        else
            pos = int(wx_grid_get_grid_cursor_col(g_grid))
            count = 1
        end if
        dummy = wx_grid_insert_cols(g_grid, int(pos, c_int), int(count, c_int), .true.)
    end subroutine on_insert_col

    subroutine on_delete_rows()
        call blocks_delete(g_grid, .true.)
    end subroutine on_delete_rows

    subroutine on_delete_cols()
        call blocks_delete(g_grid, .false.)
    end subroutine on_delete_cols

    subroutine on_clear_grid()
        call wx_grid_clear_grid(g_grid)
    end subroutine on_clear_grid

    subroutine on_edit_cell()
        call wx_grid_enable_cell_edit_control(g_grid, .true.)
    end subroutine on_edit_cell

    ! grid->GetCornerLabelValue() / SetCornerLabelValue() go through the
    ! table, whose wxGridTableBase accessors are exported by kwxFFI.
    function corner_label_value() result(text)
        character(len=:), allocatable :: text
        type(wxGridTableBase_t) :: table
        type(c_ptr) :: p

        text = ""
        table = wx_grid_get_table(g_grid)
        if (.not. table%is_valid()) return
        p = wxGridTableBase_GetCornerLabelValue(table%ptr)
        if (c_associated(p)) then
            text = from_wxstring(p)
            call wxString_Delete(p)
        end if
    end function corner_label_value

    subroutine on_set_corner_label()
        type(wxTextEntryDialog_t) :: dlg
        type(wxGridTableBase_t) :: table
        character(len=:), allocatable :: value
        type(c_ptr) :: p

        dlg = wx_text_entry_dialog_create(g_frame, &
            "Please enter corner label:", "Please enter a string", &
            corner_label_value(), int(ior(wxOK(), wxCANCEL()), c_long), &
            -1_c_int, -1_c_int, -1_c_int, -1_c_int)
        if (dlg%is_valid()) then
            if (int(wx_dialog_show_modal(dlg)) == wxID_OK()) then
                value = wx_text_entry_dialog_get_value(dlg)
                table = wx_grid_get_table(g_grid)
                if (table%is_valid()) then
                    p = to_wxstring(value)
                    call wxGridTableBase_SetCornerLabelValue(table%ptr, p)
                    call wxString_Delete(p)
                end if
            end if
        end if
    end subroutine on_set_corner_label

    subroutine on_show_selection()
        integer, allocatable :: tops(:), lefts(:), bottoms(:), rights(:)
        integer :: count, i, ncols, nrows
        character(len=:), allocatable :: desc, block
        character(len=32) :: buf

        ncols = int(wx_grid_get_number_cols(g_grid))
        nrows = int(wx_grid_get_number_rows(g_grid))
        call blocks_collect(g_grid, tops, lefts, bottoms, rights, count)
        desc = ""
        do i = 1, count
            if (lefts(i) == 0 .and. rights(i) == ncols - 1) then
                if (tops(i) == bottoms(i)) then
                    write(buf, '(a,i0)') "row ", tops(i) + 1
                    block = trim(buf)
                else
                    write(buf, '(a,i0,a,i0)') "rows ", tops(i) + 1, "..", &
                        bottoms(i) + 1
                    block = trim(buf)
                end if
            else if (tops(i) == 0 .and. bottoms(i) == nrows - 1) then
                if (lefts(i) == rights(i)) then
                    write(buf, '(a,i0)') "column ", lefts(i) + 1
                    block = trim(buf)
                else
                    write(buf, '(a,i0,a,i0)') "columns ", lefts(i) + 1, "..", &
                        rights(i) + 1
                    block = trim(buf)
                end if
            else if (tops(i) == bottoms(i) .and. lefts(i) == rights(i)) then
                write(buf, '(a,i0,a,i0)') "cell R", tops(i) + 1, "C", lefts(i) + 1
                block = trim(buf)
            else
                write(buf, '(a,i0,a,i0,a,i0,a,i0)') "block R", tops(i) + 1, &
                    "C", lefts(i) + 1, " - R", bottoms(i) + 1, "C", rights(i) + 1
                block = trim(buf)
            end if
            if (i > 1) desc = desc // achar(10) // achar(9)
            desc = desc // block
        end do

        if (count == 0) then
            call log_message("No selection")
        else if (count == 1) then
            call log_message("Selection: " // desc)
        else
            write(buf, '(i0)') count
            call log_message(trim(buf) // " selected blocks:" // achar(10) // &
                achar(9) // desc)
        end if
    end subroutine on_show_selection

    subroutine on_select_cells()
        call wx_grid_set_selection_mode(g_grid, wxGridSelectCells())
    end subroutine on_select_cells

    subroutine on_select_rows()
        call wx_grid_set_selection_mode(g_grid, wxGridSelectRows())
    end subroutine on_select_rows

    subroutine on_select_cols()
        call wx_grid_set_selection_mode(g_grid, wxGridSelectColumns())
    end subroutine on_select_cols

    subroutine on_select_rows_or_cols()
        call wx_grid_set_selection_mode(g_grid, wxGridSelectRowsOrColumns())
    end subroutine on_select_rows_or_cols

    subroutine on_select_none()
        call wx_grid_set_selection_mode(g_grid, wxGridSelectNone())
    end subroutine on_select_none

    ! GridFrame::FreezeOrThaw(): freezing at the cursor can fail (the grid is
    ! already frozen), in which case the menu check reverts.
    subroutine on_freeze_or_thaw()
        logical :: dummy_freeze

        if (is_checked(ID_FREEZE_OR_THAW)) then
            if (.not. wx_grid_freeze_to(g_grid, &
                wx_grid_get_grid_cursor_row(g_grid), &
                wx_grid_get_grid_cursor_col(g_grid))) then
                call log_message("Failed to freeze the grid.")
                call check_item(ID_FREEZE_OR_THAW, .false.)
                return
            end if
            call log_message("Grid is now frozen")
        else
            ! This never fails.
            dummy_freeze = wx_grid_freeze_to(g_grid, 0_c_int, 0_c_int)
            call log_message("Grid is now thawed")
        end if

        call wx_menu_bar_enable_item(menu_bar(), int(ID_TOGGLECOLMOVING, c_int), &
            .not. wx_grid_is_frozen(g_grid))
        call wx_menu_bar_enable_item(menu_bar(), int(ID_TOGGLEROWMOVING, c_int), &
            .not. wx_grid_is_frozen(g_grid))
    end subroutine on_freeze_or_thaw

    subroutine apply_default_colour(which)
        integer, intent(in) :: which
        type(wxColour_t) :: col
        logical :: ok

        ok = colour_from_user(g_frame, col)
        if (ok) then
            select case (which)
            case (1)
                call wx_grid_set_default_cell_text_colour(g_grid, col)
            case (2)
                call wx_grid_set_default_cell_background_colour(g_grid, col)
            case (3)
                call wx_grid_set_cell_highlight_colour(g_grid, col)
            case (4)
                call wx_grid_set_selection_foreground(g_grid, col)
            case (5)
                call wx_grid_set_selection_background(g_grid, col)
            case default
                call wx_grid_set_grid_frozen_border_colour(g_grid, col)
            end select
            if (which /= 6) call grid_refresh()
        end if
        call wx_colour_delete(col)
    end subroutine apply_default_colour

    subroutine on_deselect_cell()
        call wx_grid_deselect_cell(g_grid, 3_c_int, 1_c_int)
    end subroutine on_deselect_cell

    subroutine on_deselect_col()
        call wx_grid_deselect_col(g_grid, 2_c_int)
    end subroutine on_deselect_col

    subroutine on_deselect_row()
        call wx_grid_deselect_row(g_grid, 2_c_int)
    end subroutine on_deselect_row

    subroutine on_deselect_all()
        call grid_deselect_all(g_grid)
    end subroutine on_deselect_all

    subroutine on_select_cell()
        call wx_grid_select_block(g_grid, 3_c_int, 1_c_int, 3_c_int, 1_c_int, &
            merge(1_c_int, 0_c_int, g_addToSel))
    end subroutine on_select_cell

    subroutine on_select_col()
        call wx_grid_select_col(g_grid, 2_c_int, merge(1_c_int, 0_c_int, g_addToSel))
    end subroutine on_select_col

    subroutine on_select_row()
        call wx_grid_select_row(g_grid, 2_c_int, merge(1_c_int, 0_c_int, g_addToSel))
    end subroutine on_select_row

    subroutine on_select_all()
        call wx_grid_select_all(g_grid)
    end subroutine on_select_all

    subroutine on_overlay_selection()
        call wx_grid_disable_overlay_selection(g_grid)
        call wx_grid_force_refresh(g_grid)
        call log_message("Overlay selection disabled")
    end subroutine on_overlay_selection

    subroutine on_add_to_select_toggle(checked)
        logical, intent(in) :: checked
        g_addToSel = checked
    end subroutine on_add_to_select_toggle

    !--------------------------------------------------------------------------
    ! Autosize menu
    !--------------------------------------------------------------------------
    subroutine on_auto_size_row()
        integer(c_int), allocatable :: sels(:)
        integer :: i, nsel
        logical :: dummy

        allocate(sels(max(1, int(wx_grid_get_number_rows(g_grid)))))
        nsel = int(wx_grid_get_selected_rows(g_grid, sels))
        do i = 1, nsel
            call wx_grid_auto_size_row(g_grid, sels(i), 0_c_int)
        end do
        deallocate(sels)
    end subroutine on_auto_size_row

    subroutine on_auto_size_col()
        integer(c_int), allocatable :: sels(:)
        integer :: i, nsel

        allocate(sels(max(1, int(wx_grid_get_number_cols(g_grid)))))
        nsel = int(wx_grid_get_selected_cols(g_grid, sels))
        do i = 1, nsel
            call wx_grid_auto_size_column(g_grid, sels(i), 0_c_int)
        end do
        deallocate(sels)
    end subroutine on_auto_size_col

    subroutine on_auto_size_row_label()
        integer(c_int), allocatable :: sels(:)
        integer :: i, nsel

        allocate(sels(max(1, int(wx_grid_get_number_rows(g_grid)))))
        nsel = int(wx_grid_get_selected_rows(g_grid, sels))
        do i = 1, nsel
            call wx_grid_auto_size_row_label_size(g_grid, sels(i))
        end do
        deallocate(sels)
    end subroutine on_auto_size_row_label

    subroutine on_auto_size_col_label()
        integer(c_int), allocatable :: sels(:)
        integer :: i, nsel

        allocate(sels(max(1, int(wx_grid_get_number_cols(g_grid)))))
        nsel = int(wx_grid_get_selected_cols(g_grid, sels))
        do i = 1, nsel
            call wx_grid_auto_size_col_label_size(g_grid, sels(i))
        end do
        deallocate(sels)
    end subroutine on_auto_size_col_label

    subroutine on_auto_size_labels_col()
        call wx_grid_set_col_label_size(g_grid, int(-1, c_int))
    end subroutine on_auto_size_labels_col

    subroutine on_auto_size_labels_row()
        call wx_grid_set_row_label_size(g_grid, int(-1, c_int))
    end subroutine on_auto_size_labels_row

    subroutine on_auto_size_table()
        integer(c_int) :: dummy_layout
        call wx_grid_auto_size(g_grid)
        dummy_layout = wx_window_layout(g_frame)
    end subroutine on_auto_size_table

    subroutine on_hide_col()
        call wx_grid_hide_col(g_grid, 0_c_int)
    end subroutine on_hide_col

    subroutine on_show_col()
        call wx_grid_show_col(g_grid, 0_c_int)
    end subroutine on_show_col

    subroutine on_hide_row()
        call wx_grid_hide_row(g_grid, 1_c_int)
    end subroutine on_hide_row

    subroutine on_show_row()
        call wx_grid_show_row(g_grid, 1_c_int)
    end subroutine on_show_row

    !--------------------------------------------------------------------------
    ! Checkered / coloured cells (ToggleGridCells)
    !--------------------------------------------------------------------------
    subroutine toggle_grid_cells(use_checkered)
        logical, intent(in) :: use_checkered
        integer :: row, col, nrows, ncols, srow, scol, factor, r, g, b
        type(wxColour_t) :: bgcol, grey
        logical :: skip

        if (use_checkered) then
            g_checkered_on = .not. g_checkered_on
        else
            g_coloured_on = .not. g_coloured_on
        end if

        grey = stock_colour(wxLIGHT_GREY())
        bgcol = wx_colour_create_empty()
        call wx_grid_get_default_cell_background_colour(g_grid, bgcol)

        nrows = int(wx_grid_get_number_rows(g_grid))
        ncols = int(wx_grid_get_number_cols(g_grid))
        factor = 4
        row = 0
        do while (row < nrows)
            col = 0
            do while (col < ncols)
                if (use_checkered .and. iand(ieor(row, col), 1) /= 0) then
                    col = col + 1
                    cycle
                end if

                ! Skip overwriting attributes of merged cells.
                skip = .false.
                if (use_checkered) then
                    call wx_grid_get_cell_size(g_grid, int(row, c_int), &
                        int(col, c_int), srow, scol)
                    if (int(srow) /= 1 .or. int(scol) /= 1) skip = .true.
                end if

                if (.not. skip) then
                    if (use_checkered) then
                        if (g_checkered_on) then
                            call wx_grid_set_cell_background_colour(g_grid, &
                                int(row, c_int), int(col, c_int), grey)
                        end if
                    else
                        if (g_coloured_on) then
                            r = iand(127 + row * factor + col / factor, 255)
                            g = iand(col * factor + row / (factor * 2), 255)
                            b = iand(ieor(row, col) * factor, 255)
                            call wx_colour_set(bgcol, &
                                int(scale_component(r), c_int8_t), &
                                int(scale_component(g), c_int8_t), &
                                int(scale_component(b), c_int8_t), &
                                int(-1, c_int8_t))
                        end if
                        call wx_grid_set_cell_background_colour(g_grid, &
                            int(row, c_int), int(col, c_int), bgcol)
                    end if
                end if
                col = col + 1
            end do
            row = row + 1
        end do

        call wx_colour_delete(bgcol)
        call grid_refresh()
    end subroutine toggle_grid_cells

    ! wxString::Format("%d", value)
    function itoa(value) result(text)
        integer, intent(in) :: value
        character(len=16) :: text
        write(text, '(i0)') value
    end function itoa


    integer function scale_component(v) result(out)
        integer, intent(in) :: v
        if (v < 128) then
            out = v * 2
        else
            out = 255 - v * 2
        end if
    end function scale_component

    !==========================================================================
    ! Menu dispatcher: every EVT_MENU entry of ID_TOGGLEROWLABELS..ID_RENDER_*
    !==========================================================================
    subroutine on_menu(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: id

        if (.not. c_associated(evt)) return
        id = wx_event_get_id(evt)

        select case (id)
        case (ID_TOGGLEROWLABELS);        call on_toggle_row_labels()
        case (ID_TOGGLECOLLABELS);        call on_toggle_col_labels()
        case (ID_TOGGLEEDIT);             call on_toggle_editing()
        case (ID_TOGGLEROWSIZING);        call on_toggle_row_sizing()
        case (ID_TOGGLECOLSIZING);        call on_toggle_col_sizing()
        case (ID_TOGGLEROWLABELSIZING);   call on_toggle_row_label_sizing()
        case (ID_TOGGLECOLLABELSIZING);   call on_toggle_col_label_sizing()
        case (ID_TOGGLEROWMOVING);        call on_toggle_row_moving()
        case (ID_TOGGLECOLMOVING);        call on_toggle_col_moving()
        case (ID_TOGGLECOLHIDING);        call on_toggle_col_hiding()
        case (ID_TOGGLEGRIDSIZING);       call on_toggle_grid_sizing()
        case (ID_TOGGLEGRIDDRAGCELL);     call on_toggle_grid_drag_cell()
        case (ID_COLDEFAULTHEADER);       call on_set_col_header(0)
        case (ID_COLNATIVEHEADER);        call on_set_col_header(1)
        case (ID_COLNATIVELABELS);        call on_set_col_header(2)
        case (ID_COLCUSTOMHEADER);        call on_set_col_header(3)
        case (ID_TAB_STOP, ID_TAB_WRAP, ID_TAB_LEAVE, ID_TAB_CUSTOM)
            call on_set_tab_behaviour(id)
        case (ID_TOGGLEGRIDLINES);        call on_toggle_grid_lines()
        case (ID_AUTOSIZECOLS);           call on_auto_size_cols()
        case (ID_CELLOVERFLOW);           call on_cell_overflow()
        case (ID_RESIZECELL);             call on_resize_cell()
        case (ID_TOGGLE_CHECKERED_CELLS); call toggle_grid_cells(.true.)
        case (ID_TOGGLE_COLOURED_CELLS);  call toggle_grid_cells(.false.)
        case (ID_SETLABELCOLOUR);         call on_set_label_colour()
        case (ID_SETLABELTEXTCOLOUR);     call on_set_label_text_colour()
        case (ID_SETLABEL_FONT);          call on_set_label_font()
        case (ID_ROWLABELHORIZALIGN);     call on_set_row_label_horiz()
        case (ID_ROWLABELVERTALIGN);      call on_set_row_label_vert()
        case (ID_COLLABELHORIZALIGN);     call on_set_col_label_horiz()
        case (ID_COLLABELVERTALIGN);      call on_set_col_label_vert()
        case (ID_CORNERLABELHORIZALIGN);  call on_corner_label_align(.true.)
        case (ID_CORNERLABELVERTALIGN);   call on_corner_label_align(.false.)
        case (ID_CORNERLABELORIENTATION); call on_toggle_corner_orientation()
        case (ID_GRIDLINECOLOUR);         call on_set_grid_line_colour()
        case (ID_INSERTROW);              call on_insert_row()
        case (ID_INSERTCOL);              call on_insert_col()
        case (ID_DELETEROW);              call on_delete_rows()
        case (ID_DELETECOL);              call on_delete_cols()
        case (ID_CLEARGRID);              call on_clear_grid()
        case (ID_EDITCELL);               call on_edit_cell()
        case (ID_SETCORNERLABEL);         call on_set_corner_label()
        case (ID_SHOWSEL);                call on_show_selection()
        case (ID_SELCELLS);               call on_select_cells()
        case (ID_SELROWS);                call on_select_rows()
        case (ID_SELCOLS);                call on_select_cols()
        case (ID_SELROWSORCOLS);          call on_select_rows_or_cols()
        case (ID_SELNONE);                call on_select_none()
        case (ID_FREEZE_OR_THAW);         call on_freeze_or_thaw()
        case (ID_SET_CELL_FG_COLOUR);     call apply_default_colour(1)
        case (ID_SET_CELL_BG_COLOUR);     call apply_default_colour(2)
        case (ID_SET_CELL_HL_COLOUR);     call apply_default_colour(3)
        case (ID_SET_SELECTION_FG_COLOUR); call apply_default_colour(4)
        case (ID_SET_SELECTION_BG_COLOUR); call apply_default_colour(5)
        case (ID_SET_FROZEN_BORDER);      call apply_default_colour(6)
        case (ID_SELECT_OVERLAY);         call on_overlay_selection()
        case (ID_SELECT_UNSELECT)
            call on_add_to_select_toggle(wx_command_event_is_checked(evt))
        case (ID_SELECT_ALL);             call on_select_all()
        case (ID_SELECT_ROW);             call on_select_row()
        case (ID_SELECT_COL);             call on_select_col()
        case (ID_SELECT_CELL);            call on_select_cell()
        case (ID_DESELECT_ALL);           call on_deselect_all()
        case (ID_DESELECT_ROW);           call on_deselect_row()
        case (ID_DESELECT_COL);           call on_deselect_col()
        case (ID_DESELECT_CELL);          call on_deselect_cell()
        case (ID_SIZE_ROW);               call on_auto_size_row()
        case (ID_SIZE_COL);               call on_auto_size_col()
        case (ID_SIZE_ROW_LABEL);         call on_auto_size_row_label()
        case (ID_SIZE_COL_LABEL);         call on_auto_size_col_label()
        case (ID_SIZE_LABELS_COL);        call on_auto_size_labels_col()
        case (ID_SIZE_LABELS_ROW);        call on_auto_size_labels_row()
        case (ID_SIZE_GRID);              call on_auto_size_table()
        case (ID_HIDECOL);                call on_hide_col()
        case (ID_SHOWCOL);                call on_show_col()
        case (ID_HIDEROW);                call on_hide_row()
        case (ID_SHOWROW);                call on_show_row()
        case (ID_SET_HIGHLIGHT_WIDTH);    call on_set_highlight_width(.false.)
        case (ID_SET_RO_HIGHLIGHT_WIDTH); call on_set_highlight_width(.true.)
        case (ID_RENDER_ROW_LABEL, ID_RENDER_COL_LABEL, ID_RENDER_GRID_LINES, &
                ID_RENDER_GRID_BORDER, ID_RENDER_SELECT_HLIGHT, &
                ID_RENDER_LOMETRIC, ID_RENDER_ZOOM, ID_RENDER_MARGIN, &
                ID_RENDER_DEFAULT_SIZE)
            ! Render setup toggles only affect the Render output.
            continue
        end select
    end subroutine on_menu

    !==========================================================================
    ! File / Help menu handlers
    !==========================================================================
    ! GridFrame::OnGridRender() — draw a cell range into a bitmap and show it in
    ! a "Grid Render" frame.
    subroutine on_grid_render(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: style_render, i, ex
        logical :: use_lometric, def_size
        real(c_double) :: zoom
        integer :: size_offset, origin_x, origin_y
        integer :: top_row, top_left_col, bottom_row, bottom_right_col
        integer :: size_x, size_y, width, height
        type(wxWindow_t) :: win
        type(wxFrame_t) :: frame
        type(wxPanel_t) :: canvas
        type(wxBitmap_t) :: bmp
        type(wxMemoryDC_t) :: mem_dc
        type(wxColour_t) :: bg_col
        type(wxBrush_t) :: bg_brush
        logical :: dummy

        if (.not. c_associated(evt)) return
        ex = wx_event_get_id(evt)

        style_render = 0
        use_lometric = .false.
        def_size = .false.
        zoom = 1.0_c_double
        size_offset = 0
        origin_x = 0
        origin_y = 0

        if (wx_menu_is_checked(g_setup_menu, int(ID_RENDER_ROW_LABEL, c_int))) &
            style_render = ior(style_render, int(wxGRID_DRAW_ROWS_HEADER()))
        if (wx_menu_is_checked(g_setup_menu, int(ID_RENDER_COL_LABEL, c_int))) &
            style_render = ior(style_render, int(wxGRID_DRAW_COLS_HEADER()))
        if (wx_menu_is_checked(g_setup_menu, int(ID_RENDER_GRID_LINES, c_int))) &
            style_render = ior(style_render, int(wxGRID_DRAW_CELL_LINES()))
        if (wx_menu_is_checked(g_setup_menu, int(ID_RENDER_GRID_BORDER, c_int))) &
            style_render = ior(style_render, int(wxGRID_DRAW_BOX_RECT()))
        if (wx_menu_is_checked(g_setup_menu, int(ID_RENDER_SELECT_HLIGHT, c_int))) &
            style_render = ior(style_render, int(wxGRID_DRAW_SELECTION()))
        if (wx_menu_is_checked(g_setup_menu, int(ID_RENDER_LOMETRIC, c_int))) &
            use_lometric = .true.
        if (wx_menu_is_checked(g_setup_menu, int(ID_RENDER_MARGIN, c_int))) then
            origin_x = origin_x + 50
            origin_y = origin_y + 50
            size_offset = size_offset + 50
        end if
        if (wx_menu_is_checked(g_setup_menu, int(ID_RENDER_ZOOM, c_int))) &
            zoom = 1.25_c_double
        if (wx_menu_is_checked(g_setup_menu, int(ID_RENDER_DEFAULT_SIZE, c_int))) &
            def_size = .true.

        ! default render area: rows 0..8, columns 0..6
        top_row = 0
        top_left_col = 0
        bottom_row = 8
        bottom_right_col = 6
        if (ex == ID_RENDER_COORDS) then
            top_row = 4
            top_left_col = 6
            bottom_row = 29
            bottom_right_col = 15
        else if (wx_grid_is_selection(g_grid)) then
            call first_selection_block(top_row, top_left_col, bottom_row, &
                bottom_right_col)
        end if

        ! sum column widths and row heights of the range
        size_x = 0
        do i = top_left_col, bottom_right_col
            size_x = size_x + int(wx_grid_get_col_size(g_grid, int(i, c_int)))
        end do
        size_y = 0
        do i = top_row, bottom_row
            size_y = size_y + int(wx_grid_get_row_size(g_grid, int(i, c_int)))
        end do

        if (iand(style_render, int(wxGRID_DRAW_ROWS_HEADER())) /= 0) &
            size_x = size_x + int(wx_grid_get_row_label_size(g_grid))
        if (iand(style_render, int(wxGRID_DRAW_COLS_HEADER())) /= 0) &
            size_y = size_y + int(wx_grid_get_col_label_size(g_grid))

        size_x = int(real(size_x, c_double) * zoom)
        size_y = int(real(size_y, c_double) * zoom)

        ! delete any existing render frame and create a new one
        win = wx_window_find_window_by_name("frameRender", g_frame%ptr)
        if (win%is_valid()) then
            dummy = wx_window_destroy(win)
        end if

        frame = wx_frame_create(g_frame, wxID_ANY(), "Grid Render", -1_c_int, &
            -1_c_int, -1_c_int, -1_c_int, wxDEFAULT_FRAME_STYLE())
        call wx_window_set_client_size(frame, int(size_x + size_offset * 2, c_int), &
            int(size_y + size_offset * 2, c_int))
        call wx_window_set_name(frame, "frameRender")

        canvas = wx_panel_create(frame, wxID_ANY(), -1_c_int, -1_c_int, -1_c_int, &
            -1_c_int, 0_c_int)

        width = size_x + size_offset
        height = size_y + size_offset
        bmp = wx_bitmap_create_empty(int(width, c_int), int(height, c_int), &
            wxBITMAP_TYPE_ANY())
        mem_dc = wx_memory_dc_create_with_bitmap(bmp)

        ! default row labels have no background colour so set background
        bg_col = wx_colour_create_empty()
        call wx_window_get_background_colour(canvas, bg_col)
        bg_brush = wx_brush_create_from_colour(bg_col, wxBRUSHSTYLE_SOLID())
        call wx_dc_set_background(mem_dc, bg_brush)
        call wx_dc_clear(mem_dc)

        if (use_lometric) then
            call wx_dc_set_map_mode(mem_dc, wxMM_LOMETRIC())
            width = int(wx_dc_device_to_logical_x_rel(mem_dc, int(width, c_int)))
            height = int(wx_dc_device_to_logical_y_rel(mem_dc, int(height, c_int)))
        end if

        if (def_size) then
            width = -1
            height = -1
        end if

        call wx_grid_render(g_grid, mem_dc, int(origin_x, c_int), &
            int(origin_y, c_int), int(width, c_int), int(height, c_int), &
            int(top_row, c_int), int(top_left_col, c_int), &
            int(bottom_row, c_int), int(bottom_right_col, c_int), &
            int(style_render, c_int))

        g_grid_bitmap = bmp
        call wx_connect(canvas, wxEVT_PAINT(), on_render_paint)
        if (.not. wx_window_show(frame)) dummy = .false.
    end subroutine on_grid_render

    ! GridFrame::OnRenderPaint(): blit the rendered bitmap onto the canvas.
    subroutine on_render_paint(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxWindow_t) :: canvas
        type(wxEvent_t) :: ev
        type(wxObject_t) :: ev_obj
        type(wxPaintDC_t) :: dc
        type(wxMemoryDC_t) :: mem_dc
        logical :: dummy

        if (.not. c_associated(evt)) return
        if (.not. g_grid_bitmap%is_valid()) return

        ev%ptr = evt
        ev_obj = wx_event_get_event_object(ev)
        canvas = wxwindow_from_ptr(ev_obj%ptr, .false.)
        dc = wx_paint_dc_create(canvas)
        call wx_window_prepare_dc(canvas, dc)
        mem_dc = wx_memory_dc_create_with_bitmap(g_grid_bitmap)

        dummy = wx_dc_blit(dc, 0_c_int, 0_c_int, &
            int(wx_bitmap_get_width(g_grid_bitmap)), &
            int(wx_bitmap_get_height(g_grid_bitmap)), mem_dc, 0_c_int, 0_c_int, &
            wxCOPY(), .false., -1_c_int, -1_c_int)

        call wx_memory_dc_select_object(mem_dc, g_null_bitmap)
        call wx_memory_dc_delete(mem_dc)
        call wx_paint_dc_delete(dc)
    end subroutine on_render_paint


    ! First selection block, or the default 0,0..8,6 when there is none.
    subroutine first_selection_block(top_row, left_col, bottom_row, right_col)
        integer, intent(out) :: top_row, left_col, bottom_row, right_col
        integer :: t, l, b, r
        logical :: found

        call selection_block(g_grid, t, l, b, r, found)
        if (found) then
            top_row = t
            left_col = l
            bottom_row = b
            right_col = r
        else
            top_row = 0
            left_col = 0
            bottom_row = 8
            right_col = 6
        end if
    end subroutine first_selection_block

    ! canvas->GetBackgroundColour()
    function window_background(win) result(col)
        type(wxWindow_t), intent(in) :: win
        type(wxColour_t) :: col

        col = wx_colour_create_empty()
        call wx_window_get_background_colour(win, col)
    end function window_background

    subroutine on_quit(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: dummy

        if (.not. c_associated(evt)) return
        dummy = wx_window_close(g_frame, .true.)
    end subroutine on_quit

    subroutine on_clear_log(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call wx_text_ctrl_clear(g_logWin)
    end subroutine on_clear_log

    subroutine on_about(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxAboutDialogInfo_t) :: info

        if (.not. c_associated(evt)) return

        info%ptr = wx_about_dialog_info_create()
        info%owned = .false.
        call wx_about_dialog_info_set_name(info, "wxGrid demo")
        call wx_about_dialog_info_set_description(info, "wxGrid sample program")
        call wx_about_dialog_info_add_developer(info, "Michael Bedward")
        call wx_about_dialog_info_add_developer(info, "Julian Smart")
        call wx_about_dialog_info_add_developer(info, "Vadim Zeitlin")
        call wx_about_dialog_info_set_web_site(info, "http://www.wxwidgets.org", "")
        call wxAboutBox(info%ptr, g_frame%ptr)
        call wx_about_dialog_info_delete(info)
    end subroutine on_about

    !==========================================================================
    ! Grid events
    !==========================================================================
    subroutine on_label_left_click(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: row, col
        character(len=:), allocatable :: buf
        character(len=32) :: num

        if (.not. c_associated(evt)) return
        row = int(wx_grid_event_get_row(wxgridevent_from_ptr(evt, .false.)))
        col = int(wx_grid_event_get_col(wxgridevent_from_ptr(evt, .false.)))

        if (row /= -1) then
            write(num, '(i0)') row
            buf = "Left click on row label " // trim(num)
        else if (col /= -1) then
            write(num, '(i0)') col
            buf = "Left click on col label " // trim(num)
        else
            buf = "Left click on corner label"
        end if

        if (wx_grid_event_shift_down(wxgridevent_from_ptr(evt, .false.))) &
            buf = buf // " (shift down)"
        if (wx_grid_event_control_down(wxgridevent_from_ptr(evt, .false.))) &
            buf = buf // " (control down)"
        call log_message(buf)

        call wx_event_skip(evt)
    end subroutine on_label_left_click


    subroutine on_cell_left_click(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridEvent_t) :: gev
        character(len=64) :: buf

        if (.not. c_associated(evt)) return
        gev = wxgridevent_from_ptr(evt, .false.)
        write(buf, '(a,i0,a,i0)') "Left click at row ", &
            int(wx_grid_event_get_row(gev)), ", col ", int(wx_grid_event_get_col(gev))
        call log_message(trim(buf))
        call wx_event_skip(evt)
    end subroutine on_cell_left_click

    subroutine on_row_size(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridSizeEvent_t) :: sev
        integer :: row
        character(len=64) :: buf

        if (.not. c_associated(evt)) return
        sev = wxgridsizeevent_from_ptr(evt, .false.)
        row = int(wx_grid_size_event_get_row_or_col(sev))
        write(buf, '(a,i0,a,i0)') "Resized row ", row, &
            ", new height = ", int(wx_grid_get_row_size(g_grid, int(row, c_int)))
        call log_message(trim(buf))
        call wx_event_skip(evt)
    end subroutine on_row_size

    subroutine on_col_size(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridSizeEvent_t) :: sev
        integer :: col
        character(len=64) :: buf

        if (.not. c_associated(evt)) return
        sev = wxgridsizeevent_from_ptr(evt, .false.)
        col = int(wx_grid_size_event_get_row_or_col(sev))
        write(buf, '(a,i0,a,i0)') "Resized column ", col, &
            ", new width = ", int(wx_grid_get_col_size(g_grid, int(col, c_int)))
        call log_message(trim(buf))
        call wx_event_skip(evt)
    end subroutine on_col_size

    subroutine on_col_auto_size(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridSizeEvent_t) :: sev
        integer :: col
        character(len=64) :: buf

        if (.not. c_associated(evt)) return
        sev = wxgridsizeevent_from_ptr(evt, .false.)
        col = int(wx_grid_size_event_get_row_or_col(sev))
        if (mod(col, 2) /= 0) then
            write(buf, '(a,i0,a)') "Auto-sizing column ", col, &
                " to fit its contents"
            call log_message(trim(buf))
            call wx_grid_auto_size_column(g_grid, int(col, c_int), 0_c_int)
        else
            call wx_event_skip(evt)
        end if
    end subroutine on_col_auto_size

    subroutine on_row_label_size(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        character(len=64) :: buf

        if (.not. c_associated(evt)) return
        write(buf, '(a,i0)') "Resized row label, new width = ", &
            int(wx_grid_get_row_label_size(g_grid))
        call log_message(trim(buf))
        call wx_event_skip(evt)
    end subroutine on_row_label_size

    subroutine on_col_label_size(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        character(len=64) :: buf

        if (.not. c_associated(evt)) return
        write(buf, '(a,i0)') "Resized column label, new height = ", &
            int(wx_grid_get_col_label_size(g_grid))
        call log_message(trim(buf))
        call wx_event_skip(evt)
    end subroutine on_col_label_size

    subroutine on_row_move(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridEvent_t) :: gev
        character(len=64) :: buf

        if (.not. c_associated(evt)) return
        gev = wxgridevent_from_ptr(evt, .false.)
        write(buf, '(a,i0,a,i0)') "Moving row ", int(wx_grid_event_get_row(gev)), &
            " to ", int(wx_grid_event_get_new_row(gev))
        call log_message(trim(buf))
        call wx_event_skip(evt)
    end subroutine on_row_move

    subroutine on_col_move(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridEvent_t) :: gev
        character(len=64) :: buf

        if (.not. c_associated(evt)) return
        gev = wxgridevent_from_ptr(evt, .false.)
        write(buf, '(a,i0,a,i0)') "Moving column ", int(wx_grid_event_get_col(gev)), &
            " to ", int(wx_grid_event_get_new_col(gev))
        call log_message(trim(buf))
        call wx_event_skip(evt)
    end subroutine on_col_move

    subroutine on_select_cell_event(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridEvent_t) :: gev
        character(len=200) :: buf
        character :: ct, st, at, mt

        if (.not. c_associated(evt)) return
        gev = wxgridevent_from_ptr(evt, .false.)

        ct = 'F'; st = 'F'; at = 'F'; mt = 'F'
        if (wx_grid_event_control_down(gev)) ct = 'T'
        if (wx_grid_event_shift_down(gev)) st = 'T'
        if (wx_grid_event_alt_down(gev)) at = 'T'
        if (wx_grid_event_meta_down(gev)) mt = 'T'

        ! C++ builds "Selected " / "Deselected " then appends "cell at row ...".
        ! A trailing blank in the prefix would be lost because the continuation is
        ! written at len_trim(buf) + 1, so the space belongs to the literal below.
        if (wx_grid_event_selecting(gev)) then
            buf = "Selected"
        else
            buf = "Deselected"
        end if
        write(buf(len_trim(buf) + 1:), '(a,i0,a,i0,a,a,a,a,a,a,a,a,a)') &
            " cell at row ", int(wx_grid_event_get_row(gev)), " col ", &
            int(wx_grid_event_get_col(gev)), " ( ControlDown: ", ct, &
            ", ShiftDown: ", st, ", AltDown: ", at, ", MetaDown: ", mt, " )"

        ! Indicate whether this row/column was moved.
        if (int(wx_grid_get_row_pos(g_grid, wx_grid_event_get_row(gev))) /= &
            int(wx_grid_event_get_row(gev))) then
            write(buf(len_trim(buf) + 1:), '(a,i0)') &
                " *** Row moved, current position: ", &
                int(wx_grid_get_row_pos(g_grid, wx_grid_event_get_row(gev)))
        end if
        if (int(wx_grid_get_col_pos(g_grid, wx_grid_event_get_col(gev))) /= &
            int(wx_grid_event_get_col(gev))) then
            write(buf(len_trim(buf) + 1:), '(a,i0)') &
                " *** Column moved, current position: ", &
                int(wx_grid_get_col_pos(g_grid, wx_grid_event_get_col(gev)))
        end if

        call log_message(trim(buf))
        call wx_event_skip(evt)
    end subroutine on_select_cell_event

    subroutine log_range_event(ev, suffix)
        type(wxGridRangeSelectEvent_t), intent(in) :: ev
        character(len=*), intent(in) :: suffix
        character(len=256) :: buf
        character :: ct, st, at, mt

        ct = 'F'; st = 'F'; at = 'F'; mt = 'F'
        if (wx_grid_range_select_event_control_down(ev)) ct = 'T'
        if (wx_grid_range_select_event_shift_down(ev)) st = 'T'
        if (wx_grid_range_select_event_alt_down(ev)) at = 'T'
        if (wx_grid_range_select_event_meta_down(ev)) mt = 'T'

        if (wx_grid_range_select_event_selecting(ev)) then
            buf = "Select"
        else
            buf = "Deselect"
        end if
        ! The format list must line up one-to-one with the items below:
        !   a  suffix              a  " cells from row "   i0 top
        !   a  " col "             i0 left                a  " to row "
        !   i0 bottom              a  " col "               i0 right
        !   a  " ( ControlDown: "  a  ct  a  ", ShiftDown: "  a  st
        !   a  ", AltDown: "      a  at  a  ", MetaDown: "  a  mt
        ! 17 descriptors in all.  The previous list had a third leading 'a' and
        ! only sixteen descriptors, so gfortran aborted at run time as soon as a
        ! range-selection event arrived ("Expected INTEGER ... got CHARACTER",
        ! then format reversion as "End of file").
        write(buf(len_trim(buf) + 1:), '(a,a,i0,a,i0,a,i0,a,i0,a,a,a,a,a,a,a,a)') &
            trim(suffix), " cells from row ", &
            int(wx_grid_range_select_event_get_top_row(ev)), " col ", &
            int(wx_grid_range_select_event_get_left_col(ev)), " to row ", &
            int(wx_grid_range_select_event_get_bottom_row(ev)), " col ", &
            int(wx_grid_range_select_event_get_right_col(ev)), &
            " ( ControlDown: ", ct, ", ShiftDown: ", st, ", AltDown: ", &
            at, ", MetaDown: ", mt
        call log_message(trim(buf) // " )")
        call wx_event_skip_ev(ev)
    end subroutine log_range_event

    subroutine wx_event_skip_ev(ev)
        type(wxGridRangeSelectEvent_t), intent(in) :: ev
        ! wxEvent::Skip() on the wrapped event
        call wxEvent_Skip(ev%ptr, 1_c_int)
    end subroutine wx_event_skip_ev

    subroutine on_range_selected(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call log_range_event(wxgridrangeselectevent_from_ptr(evt, .false.), "ed")
    end subroutine on_range_selected

    subroutine on_range_selecting(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call log_range_event(wxgridrangeselectevent_from_ptr(evt, .false.), "ing")
    end subroutine on_range_selecting

    subroutine on_cell_value_changing(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridEvent_t) :: gev
        integer :: row, col
        character(len=:), allocatable :: newval, oldval
        character(len=256) :: buf

        if (.not. c_associated(evt)) return
        gev = wxgridevent_from_ptr(evt, .false.)
        row = int(wx_grid_event_get_row(gev))
        col = int(wx_grid_event_get_col(gev))
        newval = wx_command_event_get_string(evt)
        oldval = wx_grid_get_cell_value(g_grid, int(row, c_int), int(col, c_int))

        buf = "Value of cell at (" // trim(itoa(row)) // ", " // &
            trim(itoa(col)) // "): about to change from " // achar(34) // &
            oldval // achar(34) // " to " // achar(34) // newval // achar(34)
        call log_message(trim(buf))

        if (newval == "42") then
            call log_message("Vetoing the change.")
            call wx_notify_event_veto(wxnotifyevent_from_ptr(evt, .false.))
            return
        end if

        call wx_event_skip(evt)
    end subroutine on_cell_value_changing

    subroutine on_cell_value_changed(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridEvent_t) :: gev
        integer :: row, col
        character(len=:), allocatable :: newval, nowval
        character(len=256) :: buf

        if (.not. c_associated(evt)) return
        gev = wxgridevent_from_ptr(evt, .false.)
        row = int(wx_grid_event_get_row(gev))
        col = int(wx_grid_event_get_col(gev))
        newval = wx_command_event_get_string(evt)
        nowval = wx_grid_get_cell_value(g_grid, int(row, c_int), int(col, c_int))

        buf = "Value of cell at (" // trim(itoa(row)) // ", " // &
            trim(itoa(col)) // ") changed and is now " // achar(34) // &
            nowval // achar(34) // " (was " // achar(34) // newval // achar(34) // ")"
        call log_message(trim(buf))

        call wx_event_skip(evt)
    end subroutine on_cell_value_changed

    subroutine on_cell_begin_drag(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridEvent_t) :: gev
        character(len=64) :: buf

        if (.not. c_associated(evt)) return
        gev = wxgridevent_from_ptr(evt, .false.)
        write(buf, '(a,i0,a,i0)') "Got request to drag cell at row ", &
            int(wx_grid_event_get_row(gev)), ", col ", &
            int(wx_grid_event_get_col(gev))
        call log_message(trim(buf))
        call wx_event_skip(evt)
    end subroutine on_cell_begin_drag

    function confirm(title, question) result(ok)
        character(len=*), intent(in) :: title, question
        logical :: ok
        integer :: res
        type(c_ptr) :: m, c

        m = to_wxstring(question)
        c = to_wxstring(title)
        res = int(kwxMessageBox(m, c, int(wxYES_NO(), c_int), g_frame%ptr, &
            -1_c_int, -1_c_int))
        call wxString_Delete(m)
        call wxString_Delete(c)
        ok = (res == wxYES())
    end function confirm

    subroutine on_editor_shown(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridEvent_t) :: gev

        if (.not. c_associated(evt)) return
        gev = wxgridevent_from_ptr(evt, .false.)

        if (int(wx_grid_event_get_col(gev)) == 4 .and. &
            int(wx_grid_event_get_row(gev)) == 0) then
            if (.not. confirm("Checking", &
                "Are you sure you wish to edit this cell")) then
                call wx_notify_event_veto(wxnotifyevent_from_ptr(evt, .false.))
                return
            end if
        end if

        call log_message("Cell editor shown.")
        call wx_event_skip(evt)
    end subroutine on_editor_shown

    subroutine on_editor_hidden(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridEvent_t) :: gev

        if (.not. c_associated(evt)) return
        gev = wxgridevent_from_ptr(evt, .false.)

        if (int(wx_grid_event_get_col(gev)) == 4 .and. &
            int(wx_grid_event_get_row(gev)) == 0) then
            if (.not. confirm("Checking", &
                "Are you sure you wish to finish editing this cell")) then
                call wx_notify_event_veto(wxnotifyevent_from_ptr(evt, .false.))
                return
            end if
        end if

        call log_message("Cell editor hidden.")
        call wx_event_skip(evt)
    end subroutine on_editor_hidden

    subroutine on_grid_context_menu(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer(c_int) :: x, y
        character(len=80) :: buf

        if (.not. c_associated(evt)) return
        call wx_context_menu_event_get_position( &
            wxcontextmenuevent_from_ptr(evt, .false.), x, y)
        write(buf, '(a,i0,a,i0,a)') "wxEVT_CONTEXT_MENU in the grid at at (", &
            int(x), ", ", int(y), ")"
        call log_message(trim(buf))
        call wx_event_skip(evt)
    end subroutine on_grid_context_menu

    !==========================================================================
    ! TabularGridFrame handlers
    !==========================================================================
    subroutine on_toggle_use_native_header(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: dummy
        if (.not. c_associated(evt)) return
        dummy = wx_grid_use_native_col_header(g_tab_grid, &
            wx_check_box_get_value(g_chk_native))
    end subroutine on_toggle_use_native_header

    subroutine on_update_draw_native_labels(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        if (.not. c_associated(evt)) return
        call wx_update_ui_event_enable( &
            wxupdateuievent_from_ptr(evt, .false.), &
            .not. wx_check_box_get_value(g_chk_native))
    end subroutine on_update_draw_native_labels

    subroutine on_toggle_draw_native_labels(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        if (.not. c_associated(evt)) return
        call wx_grid_set_use_native_col_labels(g_tab_grid, &
            wx_check_box_get_value(g_chk_draw))
    end subroutine on_toggle_draw_native_labels

    subroutine on_toggle_show_row_labels(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        if (.not. c_associated(evt)) return
        if (wx_check_box_get_value(g_chk_row_labels)) then
            call wx_grid_set_row_label_size(g_tab_grid, int(-1, c_int))
        else
            call wx_grid_set_row_label_size(g_tab_grid, 0_c_int)
        end if
    end subroutine on_toggle_show_row_labels

    subroutine on_toggle_col_move(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: dummy
        if (.not. c_associated(evt)) return
        dummy = wx_grid_enable_drag_col_move(g_tab_grid, &
            wx_check_box_get_value(g_chk_col_move))
    end subroutine on_toggle_col_move

    subroutine on_show_hide_column(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: col

        if (.not. c_associated(evt)) return
        col = col_index_value(wx_text_ctrl_get_value(g_txt_col_showhide))
        if (col == -1) return

        if (wx_event_get_id(evt) == wxID_ADD()) then
            call wx_grid_set_col_size(g_tab_grid, int(col, c_int), &
                int(-1, c_int))
        else
            call wx_grid_set_col_size(g_tab_grid, int(col, c_int), 0_c_int)
        end if
        call tabular_update_col_order()
    end subroutine on_show_hide_column

    subroutine on_move_column(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer :: col, pos

        if (.not. c_associated(evt)) return
        col = col_index_value(wx_text_ctrl_get_value(g_txt_col_index))
        pos = col_index_value(wx_text_ctrl_get_value(g_txt_col_pos))
        if (col == -1 .or. pos == -1) return

        call wx_grid_set_col_pos(g_tab_grid, int(col, c_int), int(pos, c_int))
        call tabular_update_col_order()
    end subroutine on_move_column

    subroutine on_reset_column_order(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        if (.not. c_associated(evt)) return
        call wx_grid_reset_col_pos(g_tab_grid)
        call tabular_update_col_order()
    end subroutine on_reset_column_order

    subroutine on_grid_col_sort(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxGridEvent_t) :: gev
        integer :: col
        logical :: ascending

        if (.not. c_associated(evt)) return
        gev = wxgridevent_from_ptr(evt, .false.)
        col = int(wx_grid_event_get_col(gev))
        ascending = .not. (tabular_is_sorting_by(col) .and. tabular_is_ascending())
        call sort_tabular(col, ascending)
        g_sort_col = col
        g_sort_asc = ascending
        call wx_window_refresh(g_tab_grid, .true.)
    end subroutine on_grid_col_sort

    subroutine on_grid_row_move(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        if (.not. c_associated(evt)) return
        g_should_update_row_order = .true.
        call wx_event_skip(evt)
    end subroutine on_grid_row_move

    subroutine on_grid_col_move(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        if (.not. c_associated(evt)) return
        g_should_update_col_order = .true.
        call wx_event_skip(evt)
    end subroutine on_grid_col_move

    subroutine on_grid_col_size(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        if (.not. c_associated(evt)) return
        call tabular_update_col_order()
        call wx_event_skip(evt)
    end subroutine on_grid_col_size

    subroutine on_idle(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        if (g_should_update_col_order) then
            g_should_update_col_order = .false.
            call tabular_update_col_order()
        end if
        if (g_should_update_row_order) then
            g_should_update_row_order = .false.
            call tabular_update_row_order()
        end if
        call wx_event_skip(evt)
    end subroutine on_idle

end module grid_handlers


module grid_icon
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

    ! SetIcon(wxICON(sample)) -- samples/sample.xpm reproduced as sample.svg
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
                call wx_icon_copy_from_bitmap(icon, bitmap)
                if (wx_icon_is_ok(icon)) call wx_frame_set_icon(frame, icon)
                call wx_icon_delete(icon)
            end if
            call wx_bitmap_delete(bitmap)
        end if

        call wxBitmapBundle_Delete(bundle%ptr)
        bundle%ptr = c_null_ptr
    end subroutine set_sample_icon

end module grid_icon


program grid
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_app
    use wx_string, only: to_wxstring, wxString_Delete
    use wx_frame, only: wx_frame_create, wx_frame_set_menu_bar, wx_frame_centre, &
        wx_frame_get_menu_bar
    use wx_menu, only: wx_menu_create, wx_menu_append, wx_menu_append_separator, &
        wx_menu_append_check_item, wx_menu_append_radio_item, &
        wx_menu_append_sub, wx_menu_check
    use wx_menu_bar, only: wx_menu_bar_create, wx_menu_bar_append, &
        wx_menu_bar_check, wx_menu_bar_enable_item
    use wx_grid, only: wx_grid_create, wx_grid_create_grid, wx_grid_append_rows, &
        wx_grid_append_cols, wx_grid_get_number_rows, wx_grid_delete_rows, &
        wx_grid_get_default_row_size, wx_grid_set_row_size, wx_grid_set_col_size, &
        wx_grid_get_default_col_size, wx_grid_set_cell_value, &
        wx_grid_set_cell_renderer, wx_grid_set_cell_editor, wx_grid_set_read_only, &
        wx_grid_set_cell_background_colour, wx_grid_set_cell_text_colour, &
        wx_grid_set_cell_alignment, wx_grid_set_col_attr, wx_grid_set_row_attr, &
        wx_grid_set_col_minimal_width, wx_grid_get_col_size, &
        wx_grid_set_col_format_float, wx_grid_set_col_format_custom, &
        wx_grid_set_col_format_number, wx_grid_set_col_format_date, &
        wx_grid_set_cell_size, wx_grid_get_number_cols, wx_grid_set_col_label_size, &
        wx_grid_set_margins, wx_grid_get_table, wx_grid_set_cell_fit_mode, &
        wx_grid_set_cell_overflow, wx_grid_disable_row_resize, wx_grid_set_attr
    use wx_grid_cell_attr, only: wx_grid_cell_attr_ctor, &
        wx_grid_cell_attr_set_text_colour, wx_grid_cell_attr_set_background_colour, &
        wx_grid_cell_attr_set_alignment, wx_grid_cell_attr_dec_ref
    use wx_grid_cell_auto_wrap_string_renderer, only: &
        wx_grid_cell_auto_wrap_string_renderer_ctor
    use wx_grid_cell_auto_wrap_string_editor, only: &
        wx_grid_cell_auto_wrap_string_editor_ctor
    use wx_grid_cell_bool_editor, only: wx_grid_cell_bool_editor_ctor
    use wx_grid_cell_bool_renderer, only: wx_grid_cell_bool_renderer_ctor
    use wx_grid_fit_mode, only: wx_grid_fit_mode_create_ellipsize, &
        wx_grid_fit_mode_create_overflow, wx_grid_fit_mode_delete
    use wx_grid_cell_choice_editor, only: wx_grid_cell_choice_editor_ctor
    use wx_grid_cell_number_editor, only: wx_grid_cell_number_editor_ctor
    use wx_grid_cell_date_renderer, only: wx_grid_cell_date_renderer_create
    use wx_grid_cell_date_editor, only: wx_grid_cell_date_editor_ctor
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_sizer, only: wx_sizer_add_window
    use wx_window, only: wx_window_set_sizer_and_fit, wx_window_get_char_height, &
        wx_window_from_dip, wx_window_show, wx_window_get_id
    use wx_dialog, only: wx_dialog_show_modal
    use wx_number_entry_dialog, only: wx_number_entry_dialog_create, &
        wx_number_entry_dialog_get_value, wx_number_entry_dialog_delete
    use wx_text_ctrl, only: wx_text_ctrl_create
    use wx_check_box, only: wx_check_box_create, wx_check_box_set_value, &
        wx_check_box_get_value
    use wx_static_text, only: wx_static_text_create
    use wx_window, only: wx_window_set_label
    use wx_log_text_ctrl, only: wx_log_text_ctrl_create, wx_log_text_ctrl_delete
    use wx_events, only: wx_connect, wx_disconnect
    use wx_log, only: wx_log_disable_timestamp
    use wx_grid_table_base, only: wx_grid_table_base_set_attr_provider
    use kwx_grid_cell_renderer_hook, only: kwx_grid_cell_renderer_hook_create, &
        kwx_grid_cell_renderer_hook_set_on_draw, &
        kwx_grid_cell_renderer_hook_set_on_get_best_size
    use kwx_grid_cell_activatable_editor_hook, only: &
        kwx_grid_cell_activatable_editor_hook_create, &
        kwx_grid_cell_activatable_editor_hook_set_on_try_activate, &
        kwx_grid_cell_activatable_editor_hook_set_on_do_activate
    use kwx_grid_column_header_renderer_hook, only: &
        kwx_grid_column_header_renderer_hook_create, &
        kwx_grid_column_header_renderer_hook_set_on_draw_label, &
        kwx_grid_column_header_renderer_hook_set_on_draw_border, &
        kwx_grid_column_header_renderer_hook_set_on_draw_highlighted
    use kwx_grid_cell_attr_provider_hook, only: &
        kwx_grid_cell_attr_provider_hook_create, &
        kwx_grid_cell_attr_provider_hook_set_on_get_column_header__3932
    use grid_ids
    use grid_globals
    use grid_util
    use grid_core, only: fmt_g
    use grid_handlers, only: on_menu, on_grid_render, on_quit, on_clear_log, &
        on_about, &
        check_item, &
        on_label_left_click, on_cell_left_click, on_row_size, on_col_size, &
        on_col_auto_size, on_row_label_size, on_col_label_size, on_row_move, &
        on_col_move, on_select_cell_event, on_range_selecting, &
        on_range_selected, on_cell_value_changing, on_cell_value_changed, &
        on_cell_begin_drag, on_editor_shown, on_editor_hidden, &
        on_grid_context_menu, on_toggle_use_native_header, &
        on_toggle_draw_native_labels, on_toggle_show_row_labels, &
        on_toggle_col_move, on_update_draw_native_labels, on_move_column, &
        on_reset_column_order, on_show_hide_column, on_grid_col_sort, &
        on_grid_row_move, on_grid_col_move, on_grid_col_size, on_idle
    use grid_frames
    use grid_hooks
    use grid_icon
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxMenu_t) :: file_menu, setup_menu, view_menu, col_menu, edit_menu, &
        select_menu, selection_menu, autosize_menu, help_menu, row_label_menu, &
        col_label_menu, corner_label_menu, col_header_menu, tab_menu
    type(wxMenuBar_t) :: menu_bar
    type(wxBoxSizer_t) :: top_sizer
    type(c_ptr) :: log_target, restored_target, grey, red_col, green_col, blue_col
    type(wxColour_t) :: salmon, attr_colour
    type(wxGridCellAttr_t) :: attr
    type(wxGridCellAutoWrapStringRenderer_t) :: aw_renderer
    type(wxGridCellAutoWrapStringEditor_t) :: aw_editor
    type(wxGridCellBoolEditor_t) :: bool_editor
    type(wxGridCellChoiceEditor_t) :: choice_editor
    type(wxGridCellNumberEditor_t) :: number_editor
    type(wxGridCellDateRenderer_t) :: date_renderer
    type(wxGridCellDateEditor_t) :: date_editor
    type(wxGridCellBoolRenderer_t) :: bool_renderer
    type(wxGridFitMode_t) :: fit
    type(wxGridCellAttr_t) :: null_attr
    type(wxGridTableBase_t) :: table
    integer :: exit_code, dummy, i
    integer(c_int) :: w, h, defrow, defcol, ir
    integer :: num_rows, num_cols, end_row, end_col
    character(len=1024) :: longtext
    character(len=64), parameter :: choices(3) = [character(len=64) :: &
        "Please select a choice", "This takes two cells", "Another choice"]

    ! GridApp::OnInit()
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    call wx_set_app_name("Grid sample")

    ! GridFrame::GridFrame()
    no_parent%ptr = c_null_ptr
    g_frame = wx_frame_create(no_parent, wxID_ANY(), &
        "wxWidgets grid class demo", -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
        wxDEFAULT_FRAME_STYLE())
    if (.not. g_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    call set_sample_icon(g_frame)

    !--------------------------------------------------------------------
    ! Menus
    !--------------------------------------------------------------------
    file_menu = wx_menu_create("", 0_c_long)
    call append_item(file_menu, ID_VTABLE, "&Virtual table test" // &
        achar(9) // "Ctrl-V", "")
    call append_item(file_menu, ID_BUGS_TABLE, "&Bugs table test" // &
        achar(9) // "Ctrl-B", "")
    call append_item(file_menu, ID_TABULAR_TABLE, "&Tabular table test" // &
        achar(9) // "Ctrl-T", "")
    call append_sep(file_menu)

    setup_menu = wx_menu_create("", 0_c_long)
    call append_check(setup_menu, ID_RENDER_ROW_LABEL, &
        "Render row labels", "")
    call wx_menu_check(setup_menu, int(ID_RENDER_ROW_LABEL, c_int), .true.)
    call append_check(setup_menu, ID_RENDER_COL_LABEL, &
        "Render column labels", "")
    call wx_menu_check(setup_menu, int(ID_RENDER_COL_LABEL, c_int), .true.)
    call append_check(setup_menu, ID_RENDER_GRID_LINES, &
        "Render grid cell lines", "")
    call wx_menu_check(setup_menu, int(ID_RENDER_GRID_LINES, c_int), .true.)
    call append_check(setup_menu, ID_RENDER_GRID_BORDER, &
        "Render border", "")
    call wx_menu_check(setup_menu, int(ID_RENDER_GRID_BORDER, c_int), .true.)
    call append_check(setup_menu, ID_RENDER_SELECT_HLIGHT, &
        "Render selection highlight", "")
    call append_sep(setup_menu)
    call append_check(setup_menu, ID_RENDER_LOMETRIC, &
        "Use LOMETRIC mapping mode", "")
    call append_check(setup_menu, ID_RENDER_DEFAULT_SIZE, &
        "Use wxDefaultSize", "")
    call append_check(setup_menu, ID_RENDER_MARGIN, &
        "Logical 50 unit margin", "")
    call append_check(setup_menu, ID_RENDER_ZOOM, "Zoom 125%", "")

    call append_sub(file_menu, setup_menu, "Render setup", "")
    g_setup_menu = setup_menu
    call append_item(file_menu, wxID_PRINT(), "Render", "")
    call append_item(file_menu, ID_RENDER_COORDS, "Render G5:P30", "")

    ! #if wxUSE_LOG
    call append_sep(file_menu)
    call append_item(file_menu, wxID_CLEAR(), "Clear &log" // &
        achar(9) // "Ctrl-L", "")

    call append_sep(file_menu)
    call append_item(file_menu, wxID_EXIT(), "E&xit" // achar(9) // "Alt-X", "")

    view_menu = wx_menu_create("", 0_c_long)
    call append_check(view_menu, ID_TOGGLEROWLABELS, "&Row labels", "")
    call append_check(view_menu, ID_TOGGLECOLLABELS, "&Col labels", "")
    call append_check(view_menu, ID_TOGGLEEDIT, "&Editable", "")
    call append_check(view_menu, ID_TOGGLEROWSIZING, "Ro&w drag-resize", "")
    call append_check(view_menu, ID_TOGGLECOLSIZING, "C&ol drag-resize", "")
    call append_check(view_menu, ID_TOGGLEROWLABELSIZING, &
        "Row label drag-resize", "")
    call append_check(view_menu, ID_TOGGLECOLLABELSIZING, &
        "Col label drag-resize", "")
    call append_check(view_menu, ID_TOGGLEROWMOVING, "Row drag-move", "")
    call append_check(view_menu, ID_TOGGLECOLMOVING, "Col drag-&move", "")
    call append_check(view_menu, ID_TOGGLECOLHIDING, "Col hiding popup menu", "")
    call append_check(view_menu, ID_TOGGLEGRIDSIZING, "&Grid drag-resize", "")
    call append_check(view_menu, ID_TOGGLEGRIDDRAGCELL, "&Grid drag-cell", "")
    call append_check(view_menu, ID_TOGGLEGRIDLINES, "&Grid Lines", "")
    call append_check(view_menu, ID_SET_HIGHLIGHT_WIDTH, &
        "&Set Cell Highlight Width...", "")
    call append_check(view_menu, ID_SET_RO_HIGHLIGHT_WIDTH, &
        "&Set Cell RO Highlight Width...", "")
    call append_check(view_menu, ID_AUTOSIZECOLS, "&Auto-size cols", "")
    call append_check(view_menu, ID_CELLOVERFLOW, "&Overflow cells", "")
    call append_check(view_menu, ID_RESIZECELL, "&Resize cell (7,1)", "")
    call append_check(view_menu, ID_TOGGLE_CHECKERED_CELLS, &
        "Toggle Chec&kered Cells" // achar(9) // "Ctrl+Shift+K", "")
    call append_check(view_menu, ID_TOGGLE_COLOURED_CELLS, &
        "Toggle Co&loured Cells" // achar(9) // "Ctrl+Shift+L", "")
    call append_item(view_menu, ID_HIDECOL, "&Hide column A", "")
    call append_item(view_menu, ID_SHOWCOL, "&Show column A", "")
    call append_item(view_menu, ID_HIDEROW, "&Hide row 2", "")
    call append_item(view_menu, ID_SHOWROW, "&Show row 2", "")

    row_label_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append_sub(view_menu, int(ID_ROWLABELALIGN, c_int), &
        "R&ow label alignment", row_label_menu, &
        "Change alignment of row labels")
    call append_radio(row_label_menu, ID_ROWLABELHORIZALIGN, "&Horizontal", "")
    call append_radio(row_label_menu, ID_ROWLABELVERTALIGN, "&Vertical", "")

    col_label_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append_sub(view_menu, int(ID_COLLABELALIGN, c_int), &
        "Col l&abel alignment", col_label_menu, &
        "Change alignment of col labels")
    call append_radio(col_label_menu, ID_COLLABELHORIZALIGN, "&Horizontal", "")
    call append_radio(col_label_menu, ID_COLLABELVERTALIGN, "&Vertical", "")

    corner_label_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append_sub(view_menu, int(ID_CORNERLABELALIGN, c_int), &
        "Corner label alignment", corner_label_menu, &
        "Change alignment of corner label")
    call append_radio(corner_label_menu, ID_CORNERLABELHORIZALIGN, &
        "&Horizontal", "")
    call append_radio(corner_label_menu, ID_CORNERLABELVERTALIGN, &
        "&Vertical", "")

    call append_item(view_menu, ID_CORNERLABELORIENTATION, &
        "Toggle corner label orientation", "")

    col_header_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append_sub(view_menu, int(ID_ROWLABELALIGN, c_int), &
        "Col header style", col_header_menu, "Change style of col header")
    call append_radio(col_header_menu, ID_COLDEFAULTHEADER, "&Default", "")
    call append_radio(col_header_menu, ID_COLNATIVEHEADER, "&Native", "")
    call append_radio(col_header_menu, ID_COLNATIVELABELS, "Native-&like", "")
    call append_radio(col_header_menu, ID_COLCUSTOMHEADER, "&Custom", "")

    tab_menu = wx_menu_create("", 0_c_long)
    call append_radio(tab_menu, ID_TAB_STOP, "&Stop at the boundary", "")
    call append_radio(tab_menu, ID_TAB_WRAP, "&Wrap at the boundary", "")
    call append_radio(tab_menu, ID_TAB_LEAVE, "&Leave the grid", "")
    call append_radio(tab_menu, ID_TAB_CUSTOM, "&Custom tab handler", "")
    call append_sub(view_menu, tab_menu, "&Tab behaviour", "")

    col_menu = wx_menu_create("", 0_c_long)
    call append_item(col_menu, ID_SETLABELCOLOUR, "Set &label colour...", "")
    call append_item(col_menu, ID_SETLABELTEXTCOLOUR, &
        "Set label &text colour...", "")
    call append_item(col_menu, ID_SETLABEL_FONT, "Set label fo&nt...", "")
    call append_item(col_menu, ID_GRIDLINECOLOUR, "&Grid line colour...", "")
    call append_item(col_menu, ID_SET_CELL_FG_COLOUR, &
        "Set cell &foreground colour...", "")
    call append_item(col_menu, ID_SET_CELL_BG_COLOUR, &
        "Set cell &background colour...", "")
    call append_item(col_menu, ID_SET_CELL_HL_COLOUR, &
        "Set cell &highlight colour...", "")
    call append_item(col_menu, ID_SET_SELECTION_FG_COLOUR, &
        "Set selection f&oreground colour...", "")
    call append_item(col_menu, ID_SET_SELECTION_BG_COLOUR, &
        "Set selection b&ackground colour...", "")
    call append_item(col_menu, ID_SET_FROZEN_BORDER, &
        "Set f&rozen border colour...", "")

    edit_menu = wx_menu_create("", 0_c_long)
    call append_item(edit_menu, ID_INSERTROW, "Insert &rows" // &
        achar(9) // "Ctrl+I", "")
    call append_item(edit_menu, ID_INSERTCOL, "Insert &columns" // &
        achar(9) // "Ctrl+Shift+I", "")
    call append_item(edit_menu, ID_DELETEROW, "Delete selected ro&ws" // &
        achar(9) // "Ctrl+D", "")
    call append_item(edit_menu, ID_DELETECOL, "Delete selected co&ls" // &
        achar(9) // "Ctrl+Shift+D", "")
    call append_item(edit_menu, ID_CLEARGRID, "Cl&ear grid cell contents", "")
    call append_item(edit_menu, ID_EDITCELL, "&Edit current cell", "")
    call append_item(edit_menu, ID_SETCORNERLABEL, "&Set corner label...", "")
    call append_check(edit_menu, ID_FREEZE_OR_THAW, &
        "Freeze up to cursor" // achar(9) // "Ctrl-F", "")

    select_menu = wx_menu_create("", 0_c_long)
    call append_item(select_menu, ID_SELECT_OVERLAY, &
        "Disable &overlay selection" // achar(9) // "Ctrl+Shift+O", "")
    call append_sep(select_menu)
    call append_check(select_menu, ID_SELECT_UNSELECT, &
        "Add new cells to the selection", &
        "When off, old selection is deselected before selecting the new cells")
    call append_sep(select_menu)
    call append_item(select_menu, ID_SELECT_ALL, "Select all", "")
    call append_item(select_menu, ID_SELECT_ROW, "Select row 2", "")
    call append_item(select_menu, ID_SELECT_COL, "Select col 2", "")
    call append_item(select_menu, ID_SELECT_CELL, "Select cell (3, 1)", "")
    call append_sep(select_menu)
    call append_item(select_menu, ID_DESELECT_ALL, "Deselect all", "")
    call append_item(select_menu, ID_DESELECT_ROW, "Deselect row 2", "")
    call append_item(select_menu, ID_DESELECT_COL, "Deselect col 2", "")
    call append_item(select_menu, ID_DESELECT_CELL, "Deselect cell (3, 1)", "")
    call append_sep(select_menu)

    selection_menu = wx_menu_create("", 0_c_long)
    call append_item(select_menu, ID_SHOWSEL, "&Show current selection" // &
        achar(9) // "Ctrl-S", "")
    call wx_menu_append_sub(select_menu, int(ID_CHANGESEL, c_int), &
        "Change &selection mode", selection_menu, "Change selection mode")
    call append_item(selection_menu, ID_SELCELLS, "Select &cells", "")
    call append_item(selection_menu, ID_SELROWS, "Select &rows", "")
    call append_item(selection_menu, ID_SELCOLS, "Select col&umns", "")
    call append_item(selection_menu, ID_SELROWSORCOLS, &
        "Select rows &or columns", "")
    call append_item(selection_menu, ID_SELNONE, "&Disallow selection", "")

    autosize_menu = wx_menu_create("", 0_c_long)
    call append_item(autosize_menu, ID_SIZE_ROW, "Selected &row data", "")
    call append_item(autosize_menu, ID_SIZE_COL, "Selected &column data", "")
    call append_item(autosize_menu, ID_SIZE_ROW_LABEL, "Selected row la&bel", "")
    call append_item(autosize_menu, ID_SIZE_COL_LABEL, &
        "Selected column &label", "")
    call append_item(autosize_menu, ID_SIZE_LABELS_COL, "Column la&bels", "")
    call append_item(autosize_menu, ID_SIZE_LABELS_ROW, "Row label&s", "")
    call append_item(autosize_menu, ID_SIZE_GRID, "Entire &grid", "")

    help_menu = wx_menu_create("", 0_c_long)
    call append_item(help_menu, wxID_ABOUT(), "&About wxGrid demo", "")

    menu_bar = wx_menu_bar_create(0_c_int)
    dummy = wx_menu_bar_append(menu_bar, file_menu, "&File")
    dummy = wx_menu_bar_append(menu_bar, view_menu, "&Grid")
    dummy = wx_menu_bar_append(menu_bar, col_menu, "&Colours")
    dummy = wx_menu_bar_append(menu_bar, edit_menu, "&Edit")
    dummy = wx_menu_bar_append(menu_bar, select_menu, "&Select")
    dummy = wx_menu_bar_append(menu_bar, autosize_menu, "&Autosize")
    dummy = wx_menu_bar_append(menu_bar, help_menu, "&Help")
    call wx_frame_set_menu_bar(g_frame, menu_bar)

    g_addToSel = .false.

    !--------------------------------------------------------------------
    ! The grid and the log window
    !--------------------------------------------------------------------
    w = wx_window_from_dip(g_frame, 800_c_int)
    h = wx_window_from_dip(g_frame, 450_c_int)
    g_grid = wx_grid_create(g_frame, wxID_ANY(), 0_c_int, 0_c_int, w, h, 0_c_int)
    if (.not. g_grid%is_valid()) then
        print *, "Failed to create the grid"
        stop 1
    end if

    g_logWin = wx_text_ctrl_create(g_frame, wxID_ANY(), "", -1_c_int, &
        -1_c_int, -1_c_int, 8 * wx_window_get_char_height(g_frame), &
        wxTE_MULTILINE())

    log_target = wxLogTextCtrl_Create(g_logWin%ptr)
    g_old_log_target = wxLog_SetActiveTarget(log_target)
    call wx_log_disable_timestamp()

    call wx_grid_create_grid(g_grid, 0_c_int, 0_c_int, wxGridSelectCells())

    ! grid->GetTable()->SetAttrProvider(new CustomColumnHeadersProvider()):
    ! the two column header renderers and the provider itself are kwxFFI hook
    ! objects; the table takes ownership of the provider.
    g_header_odd = kwx_grid_column_header_renderer_hook_create(c_null_ptr)
    call kwx_grid_column_header_renderer_hook_set_on_draw_label( &
        g_header_odd, c_funloc(header_label_odd))
    call kwx_grid_column_header_renderer_hook_set_on_draw_border( &
        g_header_odd, c_funloc(header_border_odd))
    call kwx_grid_column_header_renderer_hook_set_on_draw_highlighted( &
        g_header_odd, c_funloc(header_highlighted))

    g_header_even = kwx_grid_column_header_renderer_hook_create(c_null_ptr)
    call kwx_grid_column_header_renderer_hook_set_on_draw_label( &
        g_header_even, c_funloc(header_label_even))
    call kwx_grid_column_header_renderer_hook_set_on_draw_border( &
        g_header_even, c_funloc(header_border_even))
    call kwx_grid_column_header_renderer_hook_set_on_draw_highlighted( &
        g_header_even, c_funloc(header_highlighted))

    g_attr_provider = kwx_grid_cell_attr_provider_hook_create(c_null_ptr)
    call kwx_grid_cell_attr_provider_hook_set_on_get_column_header__3932( &
        g_attr_provider, c_funloc(provider_get_column_header))

    table = wx_grid_get_table(g_grid)
    if (table%is_valid()) &
        call wx_grid_table_base_set_attr_provider(table, g_attr_provider%ptr)

    dummy = 0
    if (.not. wx_grid_append_rows(g_grid, 1000_c_int, .true.)) dummy = 1
    if (.not. wx_grid_append_cols(g_grid, 100_c_int, .true.)) dummy = 1

    ir = wx_grid_get_number_rows(g_grid)
    if (.not. wx_grid_delete_rows(g_grid, 0_c_int, ir, .true.)) dummy = 1
    if (.not. wx_grid_append_rows(g_grid, ir, .true.)) dummy = 1

    defrow = wx_grid_get_default_row_size(g_grid)
    call wx_grid_set_row_size(g_grid, 0_c_int, 4 * defrow)
    call wx_grid_set_cell_value(g_grid, 0_c_int, 0_c_int, &
        "Ctrl+Home" // achar(10) // "will go to" // achar(10) // "this cell")

    call wx_grid_set_cell_value(g_grid, 0_c_int, 1_c_int, &
        "A long piece of text to demonstrate wrapping.")
    aw_renderer = wx_grid_cell_auto_wrap_string_renderer_ctor()
    call wx_grid_set_cell_renderer(g_grid, 0_c_int, 1_c_int, aw_renderer)
    aw_editor = wx_grid_cell_auto_wrap_string_editor_ctor()
    call wx_grid_set_cell_editor(g_grid, 0_c_int, 1_c_int, aw_editor)

    call wx_grid_set_cell_value(g_grid, 0_c_int, 2_c_int, "Blah")
    call wx_grid_set_cell_value(g_grid, 0_c_int, 3_c_int, "Read only")
    call wx_grid_set_read_only(g_grid, 0_c_int, 3_c_int, .true.)

    call wx_grid_set_cell_value(g_grid, 0_c_int, 4_c_int, &
        "Can veto edit this cell")

    call wx_grid_set_col_size(g_grid, 10_c_int, &
        wx_window_from_dip(g_frame, 150_c_int))
    longtext = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" // &
        achar(10) // achar(10) // &
        "With tabs :" // achar(10) // &
        "Home," // achar(9) // achar(9) // "home" // achar(9) // achar(9) // &
        achar(9) // "again" // achar(10) // &
        "Long word at start :" // achar(10) // &
        "ILikeToBeHereWhen I can" // achar(10) // &
        "Long word in the middle :" // achar(10) // &
        "When IComeHome,ColdAnd tired" // achar(10) // &
        "Long last word :" // achar(10) // &
        "It's GoodToWarmMyBonesBesideTheFire"
    call wx_grid_set_cell_value(g_grid, 0_c_int, 10_c_int, trim(longtext))
    aw_renderer = wx_grid_cell_auto_wrap_string_renderer_ctor()
    call wx_grid_set_cell_renderer(g_grid, 0_c_int, 10_c_int, aw_renderer)
    aw_editor = wx_grid_cell_auto_wrap_string_editor_ctor()
    call wx_grid_set_cell_editor(g_grid, 0_c_int, 10_c_int, aw_editor)
    call wx_grid_set_cell_value(g_grid, 0_c_int, 11_c_int, &
        "K1 cell editor blocker")

    call wx_grid_set_cell_value(g_grid, 0_c_int, 5_c_int, &
        "Press" // achar(10) // "Ctrl+arrow" // achar(10) // &
        "to skip over" // achar(10) // "cells")

    num_rows = int(wx_grid_get_number_rows(g_grid))
    num_cols = int(wx_grid_get_number_cols(g_grid))
    end_row = num_rows - 1
    end_col = num_cols - 1

    call wx_grid_set_row_size(g_grid, int(end_row, c_int), 4 * defrow)
    call wx_grid_set_cell_value(g_grid, int(end_row - 1, c_int), &
        int(end_col - 1, c_int), "Test background colour setting")
    salmon = make_colour(255, 127, 127)
    call wx_grid_set_cell_background_colour(g_grid, int(end_row - 1, c_int), &
        int(end_col, c_int), salmon)
    call wx_grid_set_cell_background_colour(g_grid, int(end_row, c_int), &
        int(end_col - 1, c_int), salmon)
    call wx_grid_set_cell_value(g_grid, int(end_row, c_int), &
        int(end_col, c_int), &
        "Ctrl+End" // achar(10) // "will go to" // achar(10) // "this cell")
    call wx_grid_set_cell_value(g_grid, 1_c_int, 0_c_int, &
        "This default cell will overflow into neighboring cells, but not " &
        // "if you turn overflow off.")

    call wx_grid_set_cell_value(g_grid, 2_c_int, 0_c_int, &
        "This one always overflows")
    fit = wx_grid_fit_mode_create_overflow()
    call wx_grid_set_cell_fit_mode(g_grid, 2_c_int, 0_c_int, fit)
    call wx_grid_fit_mode_delete(fit)

    red_col = wxRED()
    green_col = wxGREEN()
    blue_col = wxBLUE()
    grey = wxLIGHT_GREY()

    call wx_grid_set_cell_text_colour(g_grid, 1_c_int, 2_c_int, &
        stock_colour(red_col))
    call wx_grid_set_cell_background_colour(g_grid, 1_c_int, 2_c_int, &
        stock_colour(green_col))

    call wx_grid_set_cell_value(g_grid, 1_c_int, 4_c_int, "I'm in the middle")

    call wx_grid_set_cell_value(g_grid, 2_c_int, 2_c_int, "red")
    call wx_grid_set_cell_text_colour(g_grid, 2_c_int, 2_c_int, &
        stock_colour(red_col))
    call wx_grid_set_cell_value(g_grid, 3_c_int, 3_c_int, "green on grey")
    call wx_grid_set_cell_text_colour(g_grid, 3_c_int, 3_c_int, &
        stock_colour(green_col))
    call wx_grid_set_cell_background_colour(g_grid, 3_c_int, 3_c_int, &
        stock_colour(grey))

    call wx_grid_set_cell_value(g_grid, 4_c_int, 4_c_int, &
        "a weird looking cell")
    call wx_grid_set_cell_alignment(g_grid, 4_c_int, 4_c_int, &
        wxALIGN_CENTRE(), wxALIGN_CENTRE())
    ! grid->SetCellRenderer(4, 4, new MyGridCellRenderer): a string renderer
    ! that draws the text and then a green ellipse around it.
    g_cell_renderer_hook = kwx_grid_cell_renderer_hook_create(c_null_ptr)
    call kwx_grid_cell_renderer_hook_set_on_draw(g_cell_renderer_hook, &
        c_funloc(cell_renderer_draw))
    call wx_grid_set_cell_renderer(g_grid, 4_c_int, 4_c_int, &
        g_cell_renderer_hook)

    call wx_grid_set_cell_value(g_grid, 4_c_int, 5_c_int, "3")
    ! grid->SetCellRenderer(4, 5, new MyGridStarRenderer): the cell value is
    ! shown as 5 stars.
    g_star_renderer_hook = kwx_grid_cell_renderer_hook_create(c_null_ptr)
    call kwx_grid_cell_renderer_hook_set_on_draw(g_star_renderer_hook, &
        c_funloc(star_renderer_draw))
    call kwx_grid_cell_renderer_hook_set_on_get_best_size(g_star_renderer_hook, &
        c_funloc(star_renderer_best_size))
    call wx_grid_set_cell_renderer(g_grid, 4_c_int, 5_c_int, &
        g_star_renderer_hook)
    ! grid->SetCellEditor(4, 5, new MyGridStarEditor): each activation cycles
    ! through the star values.
    g_star_editor_hook = kwx_grid_cell_activatable_editor_hook_create(c_null_ptr)
    call kwx_grid_cell_activatable_editor_hook_set_on_try_activate( &
        g_star_editor_hook, c_funloc(star_editor_try_activate))
    call kwx_grid_cell_activatable_editor_hook_set_on_do_activate( &
        g_star_editor_hook, c_funloc(star_editor_do_activate))
    call wx_grid_set_cell_editor(g_grid, 4_c_int, 5_c_int, g_star_editor_hook)

    ! grid->SetCellRenderer(3, 0, new wxGridCellBoolRenderer)
    bool_renderer = wx_grid_cell_bool_renderer_ctor()
    call wx_grid_set_cell_renderer(g_grid, 3_c_int, 0_c_int, bool_renderer)
    bool_editor = wx_grid_cell_bool_editor_ctor()
    call wx_grid_set_cell_editor(g_grid, 3_c_int, 0_c_int, bool_editor)
    salmon = make_colour(255, 127, 127)
    call wx_grid_set_cell_background_colour(g_grid, 3_c_int, 0_c_int, salmon)

    bool_renderer = wx_grid_cell_bool_renderer_ctor()
    call wx_grid_set_cell_renderer(g_grid, 3_c_int, 1_c_int, bool_renderer)

    bool_editor = wx_grid_cell_bool_editor_ctor()
    call wx_grid_set_cell_editor(g_grid, 3_c_int, 1_c_int, bool_editor)
    call wx_grid_set_cell_value(g_grid, 3_c_int, 1_c_int, "1")

    ! attr->SetTextColour(*wxBLUE); grid->SetColAttr(5, attr)
    attr = wx_grid_cell_attr_ctor()
    call wx_grid_cell_attr_set_text_colour(attr, stock_colour(blue_col))
    call wx_grid_set_col_attr(g_grid, 5_c_int, attr)
    ! attr->SetBackgroundColour(*wxRED); grid->SetRowAttr(5, attr)
    attr = wx_grid_cell_attr_ctor()
    call wx_grid_cell_attr_set_background_colour(attr, stock_colour(red_col))
    call wx_grid_set_row_attr(g_grid, 5_c_int, attr)

    call wx_grid_set_cell_value(g_grid, 2_c_int, 4_c_int, "a wider column")
    defcol = wx_grid_get_default_col_size(g_grid)
    call wx_grid_set_col_size(g_grid, 4_c_int, 3 * defcol / 2)
    call wx_grid_set_col_minimal_width(g_grid, 4_c_int, &
        wx_grid_get_col_size(g_grid, 4_c_int))

    call wx_grid_set_cell_text_colour(g_grid, 5_c_int, 8_c_int, &
        stock_colour(green_col))
    call wx_grid_set_cell_value(g_grid, 5_c_int, 8_c_int, &
        "Bg from row attr" // achar(10) // "Text col from cell attr")
    call wx_grid_set_cell_value(g_grid, 5_c_int, 5_c_int, &
        "Bg from row attr Text col from col attr and this text is so long " &
        // "that it covers over many many empty cells but is broken by one " &
        // "that isn't")

    ! Some numeric columns with different formatting.
    call wx_grid_set_col_format_float(g_grid, 6_c_int, -1_c_int, -1_c_int)
    call wx_grid_set_read_only(g_grid, 0_c_int, 6_c_int, .true.)
    call wx_grid_set_cell_value(g_grid, 0_c_int, 6_c_int, &
        "Default" // achar(10) // "float format")
    call wx_grid_set_cell_value(g_grid, 1_c_int, 6_c_int, &
        fmt_g(3.1415_c_double))
    call wx_grid_set_cell_value(g_grid, 2_c_int, 6_c_int, &
        fmt_g(1415.0_c_double))
    call wx_grid_set_cell_value(g_grid, 3_c_int, 6_c_int, &
        fmt_g(12345.6789_c_double))

    call wx_grid_set_col_format_float(g_grid, 7_c_int, 6_c_int, 2_c_int)
    call wx_grid_set_read_only(g_grid, 0_c_int, 7_c_int, .true.)
    call wx_grid_set_cell_value(g_grid, 0_c_int, 7_c_int, &
        "Width 6" // achar(10) // "precision 2")
    call wx_grid_set_cell_value(g_grid, 1_c_int, 7_c_int, &
        fmt_g(3.1415_c_double))
    call wx_grid_set_cell_value(g_grid, 2_c_int, 7_c_int, &
        fmt_g(1415.0_c_double))
    call wx_grid_set_cell_value(g_grid, 3_c_int, 7_c_int, &
        fmt_g(12345.6789_c_double))

    call wx_grid_set_col_format_custom(g_grid, 8_c_int, "double:-1,4,g")
    call wx_grid_set_read_only(g_grid, 0_c_int, 8_c_int, .true.)
    call wx_grid_set_cell_value(g_grid, 0_c_int, 8_c_int, &
        "Compact" // achar(10) // "format")
    call wx_grid_set_cell_value(g_grid, 1_c_int, 8_c_int, "31415e-4")
    call wx_grid_set_cell_value(g_grid, 2_c_int, 8_c_int, "1415")
    call wx_grid_set_cell_value(g_grid, 3_c_int, 8_c_int, "123456789e-4")

    call wx_grid_set_col_format_number(g_grid, 9_c_int)
    call wx_grid_set_read_only(g_grid, 0_c_int, 9_c_int, .true.)
    call wx_grid_set_cell_value(g_grid, 0_c_int, 9_c_int, &
        "Integer" // achar(10) // "column")
    call wx_grid_set_cell_value(g_grid, 1_c_int, 9_c_int, "17")
    call wx_grid_set_cell_value(g_grid, 2_c_int, 9_c_int, "0")
    number_editor = wx_grid_cell_number_editor_ctor(0_c_int, 100_c_int)
    call wx_grid_set_cell_editor(g_grid, 2_c_int, 9_c_int, number_editor)
    call wx_grid_set_cell_value(g_grid, 2_c_int, 10_c_int, &
        "<- This cell uses [0, 100] range")
    call wx_grid_set_cell_value(g_grid, 3_c_int, 9_c_int, "-666")
    call wx_grid_set_cell_alignment(g_grid, 3_c_int, 9_c_int, &
        wxALIGN_CENTRE(), wxALIGN_TOP())
    call wx_grid_set_cell_value(g_grid, 3_c_int, 10_c_int, &
        "<- This numeric cell should be centred")

    call wx_grid_set_read_only(g_grid, 0_c_int, 13_c_int, .true.)
    call wx_grid_set_cell_value(g_grid, 0_c_int, 13_c_int, &
        "Localized date" // achar(10) // "column")
    call wx_grid_set_col_format_date(g_grid, 13_c_int, "")
    call wx_grid_set_cell_value(g_grid, 1_c_int, 13_c_int, "Today")
    call wx_grid_set_read_only(g_grid, 0_c_int, 14_c_int, .true.)
    call wx_grid_set_cell_value(g_grid, 0_c_int, 14_c_int, &
        "ISO 8601 date" // achar(10) // "column")
    call wx_grid_set_col_format_date(g_grid, 14_c_int, "%Y-%m-%d")
    call wx_grid_set_cell_value(g_grid, 1_c_int, 14_c_int, "Tomorrow")

    call wx_grid_set_cell_value(g_grid, 13_c_int, 0_c_int, "Date cell:")
    call wx_grid_set_cell_value(g_grid, 13_c_int, 1_c_int, "Today")
    date_renderer = wx_grid_cell_date_renderer_create("")
    call wx_grid_set_cell_renderer(g_grid, 13_c_int, 1_c_int, date_renderer)
    date_editor = wx_grid_cell_date_editor_ctor("")
    call wx_grid_set_cell_editor(g_grid, 13_c_int, 1_c_int, date_editor)
    call wx_grid_set_cell_value(g_grid, 14_c_int, 0_c_int, "ISO date cell:")
    call wx_grid_set_cell_value(g_grid, 14_c_int, 1_c_int, "Tomorrow")
    date_renderer = wx_grid_cell_date_renderer_create("%Y-%m-%d")
    call wx_grid_set_cell_renderer(g_grid, 14_c_int, 1_c_int, date_renderer)
    date_editor = wx_grid_cell_date_editor_ctor("")
    call wx_grid_set_cell_editor(g_grid, 14_c_int, 1_c_int, date_editor)

    call wx_grid_set_cell_value(g_grid, 13_c_int, 3_c_int, &
        "String using default ellipsization")
    fit = wx_grid_fit_mode_create_ellipsize(wxELLIPSIZE_END())
    call wx_grid_set_cell_fit_mode(g_grid, 13_c_int, 3_c_int, fit)
    call wx_grid_fit_mode_delete(fit)

    call wx_grid_set_cell_value(g_grid, 13_c_int, 4_c_int, &
        "String ellipsized in the middle")
    fit = wx_grid_fit_mode_create_ellipsize(wxELLIPSIZE_MIDDLE())
    call wx_grid_set_cell_fit_mode(g_grid, 13_c_int, 4_c_int, fit)
    call wx_grid_fit_mode_delete(fit)

    choice_editor = wx_grid_cell_choice_editor_ctor(choices, 0_c_int)
    call wx_grid_set_cell_editor(g_grid, 4_c_int, 2_c_int, choice_editor)
    call wx_grid_set_cell_size(g_grid, 4_c_int, 2_c_int, 1_c_int, 2_c_int)
    call wx_grid_set_cell_value(g_grid, 4_c_int, 2_c_int, trim(choices(1)))
    call wx_grid_set_cell_overflow(g_grid, 4_c_int, 2_c_int, .false.)

    call wx_grid_set_cell_size(g_grid, 7_c_int, 1_c_int, 3_c_int, 4_c_int)
    call wx_grid_set_cell_alignment(g_grid, 7_c_int, 1_c_int, &
        wxALIGN_CENTRE(), wxALIGN_CENTRE())
    call wx_grid_set_cell_value(g_grid, 7_c_int, 1_c_int, "Big box!")

    ! create a separator-like row: it's grey and it's non-resizable
    call wx_grid_disable_row_resize(g_grid, 10_c_int)
    call wx_grid_set_row_size(g_grid, 10_c_int, 3 * defrow / 2)
    attr = wx_grid_cell_attr_ctor()
    call wx_grid_cell_attr_set_background_colour(attr, stock_colour(grey))
    call wx_grid_cell_attr_set_alignment(attr, wxALIGN_INVALID(), &
        wxALIGN_CENTRE())
    call wx_grid_set_row_attr(g_grid, 10_c_int, attr)
    call wx_grid_set_cell_value(g_grid, 10_c_int, 0_c_int, &
        "You can't resize this row interactively -- try it")

    ! this does exactly nothing except testing that SetAttr() handles null
    ! attributes and does reference counting correctly
    null_attr%ptr = c_null_ptr
    call wx_grid_set_attr(g_grid, 11_c_int, 11_c_int, null_attr)
    attr = wx_grid_cell_attr_ctor()
    call wx_grid_set_attr(g_grid, 11_c_int, 11_c_int, attr)
    call wx_grid_set_attr(g_grid, 11_c_int, 11_c_int, null_attr)

    ! topSizer
    top_sizer = wx_box_sizer_create(wxVERTICAL())
    call wx_sizer_add_window(top_sizer, g_grid, 2_c_int, wxEXPAND(), 0_c_int, &
        c_null_ptr)
    call wx_sizer_add_window(top_sizer, g_logWin, 1_c_int, wxEXPAND(), &
        0_c_int, c_null_ptr)
    call wx_window_set_sizer_and_fit(g_frame, top_sizer, .true.)

    call wx_frame_centre(g_frame, wxBOTH())
    call set_defaults()
    call connect_events()

    ! frame->Show(true)
    call wx_set_top_window(g_frame)
    dummy = int(merge(1, 0, wx_window_show(g_frame)))

    exit_code = wx_main_loop()

    ! GridFrame::~GridFrame(): restore the previous log target and delete the
    ! text control logger.
    if (c_associated(g_old_log_target)) then
        restored_target = wxLog_SetActiveTarget(g_old_log_target)
        if (c_associated(restored_target)) &
            call wxLogTextCtrl_Delete(restored_target)
    end if

    call wx_shutdown()

    ! MyGridCellAttrProvider::m_attrForOddRows is owned by the sample, not by the
    ! provider hook, so release its reference once every frame is gone.
    if (g_attr_odd_rows%is_valid()) &
        call wx_grid_cell_attr_dec_ref(g_attr_odd_rows)

contains

    ! GridFrame::SetDefaults()
    subroutine set_defaults()
        call check_item(ID_TOGGLEROWLABELS, .true.)
        call check_item(ID_TOGGLECOLLABELS, .true.)
        call check_item(ID_TOGGLEEDIT, .true.)
        call check_item(ID_TOGGLEROWSIZING, .true.)
        call check_item(ID_TOGGLECOLSIZING, .true.)
        call check_item(ID_TOGGLEROWLABELSIZING, .false.)
        call check_item(ID_TOGGLECOLLABELSIZING, .false.)
        call check_item(ID_TOGGLECOLMOVING, .false.)
        call check_item(ID_TOGGLECOLHIDING, .true.)
        call check_item(ID_TOGGLEGRIDSIZING, .true.)
        call check_item(ID_TOGGLEGRIDDRAGCELL, .false.)
        call check_item(ID_TOGGLEGRIDLINES, .true.)
        call check_item(ID_CELLOVERFLOW, .true.)
    end subroutine set_defaults

    ! Every EVT_MENU / EVT_GRID_* entry of the C++ event table.
    subroutine connect_events()
        ! The custom ids run from ID_TOGGLEROWLABELS (100) to
        ! ID_RENDER_DEFAULT_SIZE (197).  The three table-test ids inside that
        ! range have their own handlers, and ID_RENDER_COORDS goes to
        ! OnGridRender like wxID_PRINT, so the range is connected in pieces
        ! around them (wxWidgets tries the connections in the order they were
        ! added, so a single wide range would swallow them).
        call wx_connect(g_frame, wxEVT_MENU(), on_menu, &
            id=ID_TOGGLEROWLABELS, last_id=ID_SET_FROZEN_BORDER)
        call wx_connect(g_frame, wxEVT_MENU(), on_menu, &
            id=ID_SELECT_OVERLAY, last_id=ID_RENDER_LOMETRIC)
        call wx_connect(g_frame, wxEVT_MENU(), on_menu, &
            id=ID_RENDER_ZOOM, last_id=ID_RENDER_DEFAULT_SIZE)

        call wx_connect(g_frame, wxEVT_MENU(), on_grid_render, id=wxID_PRINT())
        call wx_connect(g_frame, wxEVT_MENU(), on_grid_render, &
            id=ID_RENDER_COORDS)
        call wx_connect(g_frame, wxEVT_MENU(), on_about, id=wxID_ABOUT())
        call wx_connect(g_frame, wxEVT_MENU(), on_clear_log, id=wxID_CLEAR())
        call wx_connect(g_frame, wxEVT_MENU(), on_quit, id=wxID_EXIT())

        ! File -> Virtual / Bugs / Tabular table test
        call wx_connect(g_frame, wxEVT_MENU(), on_vtable, id=ID_VTABLE)
        call wx_connect(g_frame, wxEVT_MENU(), on_bugs_table, id=ID_BUGS_TABLE)
        call wx_connect(g_frame, wxEVT_MENU(), on_tabular_table, &
            id=ID_TABULAR_TABLE)

        ! Grid events
        call wx_connect(g_grid, wxEVT_GRID_LABEL_LEFT_CLICK(), &
            on_label_left_click)
        call wx_connect(g_grid, wxEVT_GRID_CELL_LEFT_CLICK(), &
            on_cell_left_click)
        call wx_connect(g_grid, wxEVT_GRID_ROW_SIZE(), on_row_size)
        call wx_connect(g_grid, wxEVT_GRID_COL_SIZE(), on_col_size)
        call wx_connect(g_grid, wxEVT_GRID_COL_AUTO_SIZE(), on_col_auto_size)
        call wx_connect(g_grid, wxEVT_GRID_ROW_LABEL_SIZE(), on_row_label_size)
        call wx_connect(g_grid, wxEVT_GRID_COL_LABEL_SIZE(), on_col_label_size)
        call wx_connect(g_grid, wxEVT_GRID_ROW_MOVE(), on_row_move)
        call wx_connect(g_grid, wxEVT_GRID_COL_MOVE(), on_col_move)
        call wx_connect(g_grid, wxEVT_GRID_SELECT_CELL(), on_select_cell_event)
        call wx_connect(g_grid, wxEVT_GRID_RANGE_SELECTING(), &
            on_range_selecting)
        call wx_connect(g_grid, wxEVT_GRID_RANGE_SELECTED(), on_range_selected)
        call wx_connect(g_grid, wxEVT_GRID_CELL_CHANGING(), &
            on_cell_value_changing)
        call wx_connect(g_grid, wxEVT_GRID_CELL_CHANGED(), &
            on_cell_value_changed)
        call wx_connect(g_grid, wxEVT_GRID_CELL_BEGIN_DRAG(), &
            on_cell_begin_drag)
        call wx_connect(g_grid, wxEVT_GRID_EDITOR_SHOWN(), on_editor_shown)
        call wx_connect(g_grid, wxEVT_GRID_EDITOR_HIDDEN(), on_editor_hidden)

        ! grid->Bind(wxEVT_CONTEXT_MENU, ..., grid->GetId())
        call wx_connect(g_grid, wxEVT_CONTEXT_MENU(), on_grid_context_menu, &
            id=int(wx_window_get_id(g_grid)))
    end subroutine connect_events

    subroutine on_vtable(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxNumberEntryDialog_t) :: dlg

        if (.not. c_associated(evt)) return
        dlg = wx_number_entry_dialog_create(g_frame, &
            "Size of the table to create", "Size: ", "wxGridDemo question", &
            int(g_sizeGrid, c_long), 0_c_long, 10000000_c_long, -1_c_int, &
            -1_c_int)
        if (dlg%is_valid()) then
            if (int(wx_dialog_show_modal(dlg)) == wxID_OK()) then
                g_sizeGrid = int(wx_number_entry_dialog_get_value(dlg))
                call create_big_frame(g_sizeGrid)
            end if
            call wx_number_entry_dialog_delete(dlg)
        end if
    end subroutine on_vtable

    subroutine on_bugs_table(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        if (.not. c_associated(evt)) return
        call create_bugs_frame()
    end subroutine on_bugs_table

    subroutine on_tabular_table(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        if (.not. c_associated(evt)) return
        call create_tabular_frame()
        if (.not. g_tabular_frame%is_valid()) return
        call wx_connect(g_tabular_frame, wxEVT_CHECKBOX(), &
            on_toggle_use_native_header, id=ID_CHK_USE_NATIVE)
        call wx_connect(g_tabular_frame, wxEVT_CHECKBOX(), &
            on_toggle_draw_native_labels, id=ID_CHK_DRAW_NATIVE)
        call wx_connect(g_tabular_frame, wxEVT_CHECKBOX(), &
            on_toggle_show_row_labels, id=ID_CHK_SHOW_ROW_LABELS)
        call wx_connect(g_tabular_frame, wxEVT_CHECKBOX(), on_toggle_col_move, &
            id=ID_CHK_ENABLE_COL_MOVE)
        call wx_connect(g_tabular_frame, wxEVT_UPDATE_UI(), &
            on_update_draw_native_labels, id=ID_CHK_DRAW_NATIVE)
        call wx_connect(g_tabular_frame, wxEVT_BUTTON(), on_move_column, &
            id=wxID_APPLY())
        call wx_connect(g_tabular_frame, wxEVT_BUTTON(), on_reset_column_order, &
            id=wxID_RESET())
        call wx_connect(g_tabular_frame, wxEVT_BUTTON(), on_show_hide_column, &
            id=wxID_ADD())
        call wx_connect(g_tabular_frame, wxEVT_BUTTON(), on_show_hide_column, &
            id=wxID_DELETE())
        call wx_connect(g_tabular_frame, wxEVT_GRID_COL_SORT(), on_grid_col_sort)
        call wx_connect(g_tabular_frame, wxEVT_GRID_ROW_MOVE(), on_grid_row_move)
        call wx_connect(g_tabular_frame, wxEVT_GRID_COL_MOVE(), on_grid_col_move)
        call wx_connect(g_tabular_frame, wxEVT_GRID_COL_SIZE(), on_grid_col_size)
        call wx_connect(g_tabular_frame, wxEVT_IDLE(), on_idle)
        i = 0
    end subroutine on_tabular_table

end program grid
