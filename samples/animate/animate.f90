! animate.f90 - wxWidgets animation sample
!
! Fortran port of wxSamples/src/animate/anitest.cpp (kwxFortran).
!
! The frame hosts a wxAnimationCtrl plus a "Animation frames" static box that
! shows the selected frame's delay and bitmap, and drives the animation from
! the Animation menu.
!
! Platform notes (same resolution as anitest.cpp):
!  * wxHAS_NATIVE_ANIMATIONCTRL is not defined for this wxMSW build, so the
!    ID_USE_GENERIC menu item and MyFrame::OnUseGeneric() are compiled out of
!    the C++ original and are not created here either.
!
! Assets:
!  * throbber.gif / throbber_2x.gif are loaded through wxAnimationBundle.
!  * The wxICON(sample) XPM from wxSamples/src/sample.xpm is shipped as
!    sample.svg (pixel-for-pixel conversion) and loaded through
!    wxBitmapBundle::FromSVGFile().
!
! Run the executable with the current directory set to this folder so relative
! asset paths (throbber.gif, throbber_2x.gif, sample.svg) resolve like the
! C++ sample.

module animate_globals
    use kwx_types
    implicit none

    ! MyFrame members.
    type(wxFrame_t), save :: g_frame
    type(wxAnimationCtrl_t), save :: g_anim_ctrl
    type(wxBoxSizer_t), save :: g_top_sizer
    type(wxStaticBox_t), save :: g_frame_box
    type(wxSpinCtrl_t), save :: g_frame_spin
    type(wxStaticText_t), save :: g_frame_count
    type(wxStaticText_t), save :: g_frame_delay
    type(wxStaticBitmap_t), save :: g_frame_bitmap

    ! enum { ID_PLAY = 1, ID_SET_NULL_ANIMATION, ... }
    integer, parameter :: ID_PLAY = 1
    integer, parameter :: ID_SET_NULL_ANIMATION = 2
    integer, parameter :: ID_SET_INACTIVE_BITMAP = 3
    integer, parameter :: ID_SET_NO_AUTO_RESIZE = 4
    integer, parameter :: ID_SET_BGCOLOR = 5
    ! ID_USE_GENERIC = 6 exists only under wxHAS_NATIVE_ANIMATIONCTRL.

end module animate_globals


module animate_icon
    use, intrinsic :: iso_c_binding
    use kwx_types
    use wx_bitmap_bundle, only: wx_bitmap_bundle_from_svg_file, &
        wx_bitmap_bundle_get_bitmap
    use wx_frame, only: wx_frame_set_icon
    use wx_icon, only: wx_icon_create_default, wx_icon_copy_from_bitmap, &
        wx_icon_is_ok, wx_icon_delete
    use wx_size, only: wx_size_create, wx_size_delete, wx_size_get_width, &
        wx_size_get_height
    implicit none
    private

    public :: set_sample_icon

contains

    !--------------------------------------------------------------------------
    ! SetIcon(wxICON(sample))
    !--------------------------------------------------------------------------
    subroutine set_sample_icon(frame)
        type(wxFrame_t), intent(in) :: frame
        type(wxBitmapBundle_t) :: bundle
        type(wxBitmap_t) :: bitmap
        type(wxSize_t) :: size
        type(wxIcon_t) :: icon

        ! 32x32 icon converted from wxSamples/src/sample.xpm.
        bundle = wx_bitmap_bundle_from_svg_file("sample.svg", 32_c_int, 32_c_int)
        if (.not. bundle%is_valid()) return

        size = wx_size_create(32_c_int, 32_c_int)
        ! wxBitmapBundle::GetBitmap(wxSize) is bound as (width, height).
        bitmap = wx_bitmap_bundle_get_bitmap(bundle, &
            wx_size_get_width(size), wx_size_get_height(size))
        call wx_size_delete(size)
        if (.not. bitmap%is_valid()) return

        icon = wx_icon_create_default()
        call wx_icon_copy_from_bitmap(icon, bitmap)
        if (wx_icon_is_ok(icon)) call wx_frame_set_icon(frame, icon)
        call wx_icon_delete(icon)
    end subroutine set_sample_icon

end module animate_icon


module animate_util
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxID_ANY, LogError
    use wx_animation
    use wx_animation_ctrl
    use wx_bitmap
    use wx_colour
    use wx_image
    use wx_sizer
    use wx_sizer_flags, only: wx_sizer_flags_get_default_border_fractional
    use wx_spin_ctrl
    use wx_static_bitmap
    use wx_string, only: to_wxstring, wxString_Delete
    use wx_window
    use animate_globals
    implicit none
    private

    public :: default_border
    public :: animation_window
    public :: add_window
    public :: add_sizer
    public :: show_error
    public :: update_frame_controls
    public :: update_frame_info
    public :: recreate_animation

contains

    ! wxSizerFlags default border, in pixels: GetDefaultBorderFractional().
    function default_border() result(border)
        integer :: border
        border = nint(wx_sizer_flags_get_default_border_fractional())
    end function default_border

    ! wxAnimationCtrl does not derive from wxWindow in the generated wrappers,
    ! so inherited wxWindow methods go through a borrowed wxWindow handle.
    function animation_window() result(window)
        type(wxWindow_t) :: window
        window%ptr = g_anim_ctrl%ptr
        window%owned = .false.
    end function animation_window

    subroutine add_window(sizer, window, option, flag, border)
        class(wxsizer_t), intent(in) :: sizer
        class(wxwindow_t), intent(in) :: window
        integer(c_int), intent(in) :: option
        integer(c_int), intent(in) :: flag
        integer(c_int), intent(in) :: border
        call wx_sizer_add_window(sizer, window, option, flag, border, c_null_ptr)
    end subroutine add_window

    subroutine add_sizer(sizer, child, option, flag, border)
        class(wxsizer_t), intent(in) :: sizer
        class(wxsizer_t), intent(in) :: child
        integer(c_int), intent(in) :: option
        integer(c_int), intent(in) :: flag
        integer(c_int), intent(in) :: border
        call wx_sizer_add_sizer(sizer, child, option, flag, border, c_null_ptr)
    end subroutine add_sizer

    ! wxLogError(): the default GUI log target shows a modal error dialog.
    subroutine show_error(message)
        character(len=*), intent(in) :: message
        type(c_ptr) :: message_ptr

        message_ptr = to_wxstring(message)
        call LogError(message_ptr)
        call wxString_Delete(message_ptr)
    end subroutine show_error

    ! MyFrame::UpdateFrameControls()
    subroutine update_frame_controls()
        type(wxAnimation_t) :: anim
        integer(c_int) :: count
        character(len=32) :: text
        logical :: dummy

        anim = wx_animation_create()
        call wx_animation_ctrl_get_animation(g_anim_ctrl, anim)

        count = 0_c_int
        if (wx_animation_is_ok(anim)) count = wx_animation_get_frame_count(anim)

        dummy = wx_window_enable(g_frame_box, count /= 0_c_int)

        if (count /= 0_c_int) then
            call wx_spin_ctrl_set_range(g_frame_spin, 0_c_int, count - 1_c_int)
            write(text, '("(of ", I0, ")")') count
            call wx_window_set_label(g_frame_count, trim(text))
        else
            call wx_spin_ctrl_set_range(g_frame_spin, 0_c_int, 0_c_int)
            call wx_window_set_label(g_frame_count, "(no frames)")
        end if

        call wx_spin_ctrl_set_value(g_frame_spin, 0_c_int)
        call wx_animation_delete(anim)

        call update_frame_info()
    end subroutine update_frame_controls

    ! MyFrame::UpdateFrameInfo()
    subroutine update_frame_info()
        type(wxAnimation_t) :: anim
        type(wxImage_t) :: image
        type(wxBitmap_t) :: bitmap
        type(wxBitmap_t) :: empty_bitmap
        integer(c_int) :: frame, delay, count
        character(len=64) :: text
        integer(c_int) :: dummy

        anim = wx_animation_create()
        call wx_animation_ctrl_get_animation(g_anim_ctrl, anim)

        count = 0_c_int
        if (wx_animation_is_ok(anim)) count = wx_animation_get_frame_count(anim)

        if (count /= 0_c_int) then
            frame = wx_spin_ctrl_get_value(g_frame_spin)

            delay = wx_animation_get_delay(anim, frame)
            if (delay == -1_c_int) then
                call wx_window_set_label(g_frame_delay, "Delay: forever")
            else
                write(text, '("Delay: ", I0, " ms")') delay
                call wx_window_set_label(g_frame_delay, trim(text))
            end if

            image = wx_image_create_default()
            call wx_animation_get_frame(anim, frame, image)
            if (wx_image_is_ok(image)) then
                bitmap = wx_bitmap_create_from_image(image, -1_c_int)
                call wx_static_bitmap_set_bitmap(g_frame_bitmap, bitmap)
                call wx_bitmap_delete(bitmap)
            else
                write(text, '("Failed to get animation frame ", I0, ".")') frame
                call show_error(trim(text))
                empty_bitmap = wx_bitmap_create_default()
                call wx_static_bitmap_set_bitmap(g_frame_bitmap, empty_bitmap)
                call wx_bitmap_delete(empty_bitmap)
            end if
            call wx_image_delete(image)
        else
            call wx_window_set_label(g_frame_delay, "Delay: N/A")
            empty_bitmap = wx_bitmap_create_default()
            call wx_static_bitmap_set_bitmap(g_frame_bitmap, empty_bitmap)
            call wx_bitmap_delete(empty_bitmap)
        end if

        call wx_animation_delete(anim)

        dummy = wx_window_layout(g_frame)
    end subroutine update_frame_info

    ! MyFrame::RecreateAnimation()
    !
    ! On wxMSW the native-animation branch of anitest.cpp is compiled out, so
    ! `curr` stays wxNullAnimation and the replacement control starts without
    ! an animation.  That is what is done here.
    subroutine recreate_animation(style)
        integer(c_int), intent(in) :: style
        type(wxBitmap_t) :: inactive
        type(wxColour_t) :: background
        type(wxWindow_t) :: old_window, new_window
        type(wxAnimationCtrl_t) :: new_ctrl
        logical :: dummy

        inactive = wx_bitmap_create_default()
        call wx_animation_ctrl_get_inactive_bitmap(g_anim_ctrl, inactive)

        background = wx_colour_create_empty()
        call wx_window_get_background_colour(animation_window(), background)

        old_window = animation_window()
        new_ctrl = wx_animation_ctrl_create(g_frame, wxID_ANY(), -1_c_int, -1_c_int, &
            -1_c_int, -1_c_int, style)
        if (.not. new_ctrl%is_valid()) then
            call wx_bitmap_delete(inactive)
            call wx_colour_delete(background)
            return
        end if
        new_window%ptr = new_ctrl%ptr
        new_window%owned = .false.

        dummy = wx_sizer_replace_window(g_top_sizer, old_window, new_window, .false.)
        ! `delete old` in the C++ code.
        dummy = wx_window_destroy(old_window)

        g_anim_ctrl = new_ctrl
        call wx_animation_ctrl_set_inactive_bitmap(g_anim_ctrl, inactive)
        dummy = wx_window_set_background_colour(animation_window(), background)

        call wx_sizer_layout(g_top_sizer)
        call update_frame_controls()

        call wx_bitmap_delete(inactive)
        call wx_colour_delete(background)
    end subroutine recreate_animation

end module animate_util


module animate_handlers
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi, only: wxAboutBox, wxGetColourFromUserEx, wxFD_OPEN, wxID_STOP, &
        wxID_ANY, wxID_OK, wxAC_DEFAULT_STYLE, wxAC_NO_AUTORESIZE, &
        wxANIMATION_TYPE_ANY
    use wx_about_dialog_info
    use wx_animation
    use wx_animation_ctrl
    use wx_art_provider, only: wx_art_provider_get_bitmap
    use wx_bitmap
    use wx_colour
    use wx_dialog, only: wx_dialog_show_modal
    use wx_events, only: wx_command_event_is_checked
    use wx_file_dialog
    use wx_frame, only: wx_frame_get_menu_bar
    use wx_menu_bar, only: wx_menu_bar_enable_item
    use wx_sizer, only: wx_sizer_layout
    use wx_string, only: to_wxstring, wxString_Delete
    use wx_window
    use animate_globals
    use animate_util
    implicit none

contains

    !--------------------------------------------------------------------------
    ! Animation > Play
    !--------------------------------------------------------------------------
    subroutine on_play(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        if (.not. wx_animation_ctrl_play(g_anim_ctrl)) &
            call show_error("Invalid animation")
    end subroutine on_play

    !--------------------------------------------------------------------------
    ! Animation > Stop
    !--------------------------------------------------------------------------
    subroutine on_stop(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call wx_animation_ctrl_stop(g_anim_ctrl)
    end subroutine on_stop

    !--------------------------------------------------------------------------
    ! Animation > Set null animation
    !--------------------------------------------------------------------------
    subroutine on_set_null_animation(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxAnimation_t) :: anim

        if (.not. c_associated(evt)) return

        anim = wx_animation_create()
        call wx_animation_ctrl_set_animation(g_anim_ctrl, anim)
        call wx_animation_delete(anim)

        call update_frame_controls()
    end subroutine on_set_null_animation

    !--------------------------------------------------------------------------
    ! Animation > Set inactive bitmap
    !--------------------------------------------------------------------------
    subroutine on_set_inactive_bitmap(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxBitmap_t) :: bitmap

        if (.not. c_associated(evt)) return

        if (wx_command_event_is_checked(evt)) then
            ! wxArtProvider::GetBitmap(wxART_MISSING_IMAGE)
            bitmap = wx_art_provider_get_bitmap("wxART_MISSING_IMAGE", &
                "wxART_OTHER", -1_c_int, -1_c_int)
            if (bitmap%is_valid()) then
                call wx_animation_ctrl_set_inactive_bitmap(g_anim_ctrl, bitmap)
                call wx_bitmap_delete(bitmap)
            end if
        else
            bitmap = wx_bitmap_create_default()
            call wx_animation_ctrl_set_inactive_bitmap(g_anim_ctrl, bitmap)
            call wx_bitmap_delete(bitmap)
        end if
    end subroutine on_set_inactive_bitmap

    !--------------------------------------------------------------------------
    ! Animation > Set no autoresize
    !--------------------------------------------------------------------------
    subroutine on_set_no_auto_resize(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer(c_int) :: style
        integer(c_long) :: current

        if (.not. c_associated(evt)) return

        style = wxAC_DEFAULT_STYLE()
        if (wx_command_event_is_checked(evt)) &
            style = ior(style, wxAC_NO_AUTORESIZE())

        current = wx_window_get_window_style(animation_window())
        if (int(style, c_long) /= current) call recreate_animation(style)
    end subroutine on_set_no_auto_resize

    !--------------------------------------------------------------------------
    ! Animation > Set background colour...
    !--------------------------------------------------------------------------
    subroutine on_set_bg_color(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxColour_t) :: initial, chosen
        type(c_ptr) :: caption_ptr
        logical :: dummy

        if (.not. c_associated(evt)) return

        initial = wx_colour_create_empty()
        call wx_window_get_background_colour(animation_window(), initial)

        chosen = wx_colour_create_empty()
        caption_ptr = to_wxstring("Choose the background colour")
        call wxGetColourFromUserEx(g_frame%ptr, initial%ptr, caption_ptr, chosen%ptr)
        call wxString_Delete(caption_ptr)

        if (wx_colour_is_ok(chosen)) &
            dummy = wx_window_set_background_colour(animation_window(), chosen)

        call wx_colour_delete(chosen)
        call wx_colour_delete(initial)
    end subroutine on_set_bg_color

    !--------------------------------------------------------------------------
    ! Animation frames > spin control
    !--------------------------------------------------------------------------
    subroutine on_frame_spin(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt

        if (.not. c_associated(evt)) return
        call update_frame_info()
    end subroutine on_frame_spin

    !--------------------------------------------------------------------------
    ! File > Quit (Close())
    !--------------------------------------------------------------------------
    subroutine on_quit(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        logical :: dummy

        if (.not. c_associated(evt)) return
        dummy = wx_window_close(g_frame, .true.)
    end subroutine on_quit

    !--------------------------------------------------------------------------
    ! Help > About
    !--------------------------------------------------------------------------
    subroutine on_about(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxAboutDialogInfo_t) :: info

        if (.not. c_associated(evt)) return

        info%ptr = wx_about_dialog_info_create()
        if (.not. c_associated(info%ptr)) return
        info%owned = .true.

        call wx_about_dialog_info_set_name(info, &
            "wxAnimationCtrl and wxAnimation sample")
        call wx_about_dialog_info_set_description(info, &
            "This sample program demonstrates the usage of wxAnimationCtrl")
        call wx_about_dialog_info_set_copyright(info, "(C) 2006 Julian Smart")

        call wx_about_dialog_info_add_developer(info, "Julian Smart")
        call wx_about_dialog_info_add_developer(info, &
            "Guillermo Rodriguez Garcia")
        call wx_about_dialog_info_add_developer(info, "Francesco Montorsi")

        call wxAboutBox(info%ptr, g_frame%ptr)

        call wx_about_dialog_info_delete(info)
    end subroutine on_about

    !--------------------------------------------------------------------------
    ! File > Open Animation...
    !--------------------------------------------------------------------------
    subroutine on_open(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxFileDialog_t) :: dialog
        type(wxAnimation_t) :: temp
        integer(c_int) :: result
        character(len=:), allocatable :: path
        logical :: dummy, played

        if (.not. c_associated(evt)) return

        ! wxFileDialog(this, "Please choose an animation", wxEmptyString,
        !              wxEmptyString, "*.gif;*.ani;*.webp", wxFD_OPEN)
        dialog = wx_file_dialog_create(g_frame, "Please choose an animation", &
            "", "", "*.gif;*.ani;*.webp", -1_c_int, -1_c_int, wxFD_OPEN(), &
            -1_c_int, -1_c_int)
        if (.not. dialog%is_valid()) return

        result = wx_dialog_show_modal(dialog)
        if (result == wxID_OK()) then
            path = wx_file_dialog_get_path(dialog)

            ! wxAnimation temp(m_animationCtrl->CreateAnimation());
            temp = wx_animation_create()
            call wx_animation_ctrl_create_animation(g_anim_ctrl, temp)
            if (.not. wx_animation_load_file(temp, path, wxANIMATION_TYPE_ANY())) then
                call show_error("Sorry, this animation is not a valid format for wxAnimation.")
                call wx_animation_delete(temp)
                dummy = wx_window_destroy(dialog)
                return
            end if

            call wx_animation_ctrl_set_animation(g_anim_ctrl, temp)
            played = wx_animation_ctrl_play(g_anim_ctrl)

            call wx_sizer_layout(g_top_sizer)

            call update_frame_controls()

            call wx_animation_delete(temp)
        end if

        dummy = wx_window_destroy(dialog)
    end subroutine on_open

    !--------------------------------------------------------------------------
    ! EVT_UPDATE_UI(wxID_ANY)
    !--------------------------------------------------------------------------
    subroutine on_update_ui(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        type(wxMenuBar_t) :: menu_bar
        logical :: playing

        if (.not. c_associated(evt)) return

        menu_bar = wx_frame_get_menu_bar(g_frame)
        if (.not. menu_bar%is_valid()) return

        playing = wx_animation_ctrl_is_playing(g_anim_ctrl)

        call wx_menu_bar_enable_item(menu_bar, wxID_STOP(), playing)
        call wx_menu_bar_enable_item(menu_bar, int(ID_PLAY, c_int), .not. playing)
        call wx_menu_bar_enable_item(menu_bar, int(ID_SET_NO_AUTO_RESIZE, c_int), &
            .not. playing)
    end subroutine on_update_ui

    !--------------------------------------------------------------------------
    ! EVT_SIZE -- MyFrame inherits wxTopLevelWindow::OnSize(), which is Layout()
    !--------------------------------------------------------------------------
    subroutine on_size(fun, data, evt) bind(C)
        type(c_ptr), value :: fun, data, evt
        integer(c_int) :: dummy

        if (.not. c_associated(evt)) return
        dummy = wx_window_layout(g_frame)
    end subroutine on_size

end module animate_handlers


program animate
    use, intrinsic :: iso_c_binding
    use wx_app
    use kwx_types
    use kwxffi, only: wxDEFAULT_FRAME_STYLE, wxSTB_DEFAULT_STYLE, wxID_ANY, &
        wxID_OPEN, wxID_EXIT, wxID_ABOUT, wxID_STOP, wxAC_DEFAULT_STYLE, &
        wxVERTICAL, wxHORIZONTAL, wxALIGN_CENTRE, wxALIGN_CENTRE_VERTICAL, &
        wxALL, wxEXPAND, wxLEFT, wxRIGHT, wxSP_ARROW_KEYS, wxSIZE_USE_EXISTING, &
        wxEVT_MENU, wxEVT_SIZE, wxEVT_UPDATE_UI, wxEVT_SPINCTRL, &
        wxANIMATION_TYPE_ANY
    use wx_animation, only: wx_animation_create_from_file, wx_animation_delete
    use wx_animation_bundle, only: wx_animation_bundle_create, &
        wx_animation_bundle_add, wx_animation_bundle_is_ok, &
        wx_animation_bundle_delete
    use wx_animation_ctrl, only: wx_animation_ctrl_create, &
        wx_animation_ctrl_set_animation_bundle, wx_animation_ctrl_play
    use wx_bitmap, only: wx_bitmap_create_default, wx_bitmap_delete
    use wx_box_sizer, only: wx_box_sizer_create
    use wx_events, only: wx_connect
    use wx_frame, only: wx_frame_create, wx_frame_create_status_bar, &
        wx_frame_set_menu_bar
    use wx_menu, only: wx_menu_create, wx_menu_append, wx_menu_append_check_item, &
        wx_menu_append_separator
    use wx_menu_bar, only: wx_menu_bar_create, wx_menu_bar_append
    use wx_spin_ctrl, only: wx_spin_ctrl_create
    use wx_static_bitmap, only: wx_static_bitmap_create
    use wx_static_box, only: wx_static_box_create
    use wx_static_box_sizer, only: wx_static_box_sizer_create
    use wx_static_text, only: wx_static_text_create
    use wx_window, only: wx_window_from_dip, wx_window_set_size, &
        wx_window_set_sizer, wx_window_show, wx_window_layout
    use animate_globals
    use animate_util
    use animate_handlers
    use animate_icon
    implicit none

    type(wxWindow_t) :: no_parent
    type(wxStatusBar_t) :: status_bar
    type(wxStaticText_t) :: title_label
    type(wxStaticText_t) :: frame_label
    type(wxStaticBoxSizer_t) :: frame_sizer
    type(wxBoxSizer_t) :: spin_sizer
    type(wxMenu_t) :: file_menu, play_menu, help_menu
    type(wxMenuBar_t) :: menu_bar
    type(wxBitmap_t) :: empty_bitmap
    type(wxAnimation_t) :: throbber, throbber2x
    type(wxAnimationBundle_t) :: animations
    integer(c_int) :: border, width_px, height_px, dummy
    logical :: shown, played
    integer :: exit_code

    ! MyApp::OnInit()
    if (.not. wx_initialize()) then
        print *, "Failed to initialize wxWidgets"
        stop 1
    end if

    call wx_set_app_name("Animation Demo")

    ! MyFrame *frame = new MyFrame(nullptr, wxID_ANY, "Animation Demo");
    no_parent%ptr = c_null_ptr
    g_frame = wx_frame_create(no_parent, wxID_ANY(), "Animation Demo", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, wxDEFAULT_FRAME_STYLE())
    if (.not. g_frame%is_valid()) then
        print *, "Failed to create main frame"
        stop 1
    end if

    ! SetIcon(wxICON(sample));
    call set_sample_icon(g_frame)

    border = int(default_border(), c_int)

    ! ---------------------------------------------------------------------
    ! wxMenu *file_menu = new wxMenu;
    ! ---------------------------------------------------------------------
    file_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(file_menu, wxID_OPEN(), &
        "&Open Animation..." // achar(9) // "Ctrl+O", "Loads an animation", &
        .false.)
    call wx_menu_append(file_menu, wxID_EXIT(), "&Quit", "", .false.)

    ! wxMenu *play_menu = new wxMenu;
    play_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(play_menu, int(ID_PLAY, c_int), &
        "Play" // achar(9) // "Ctrl+P", "Play the animation", .false.)
    call wx_menu_append(play_menu, wxID_STOP(), &
        "Stop" // achar(9) // "Ctrl+S", "Stop the animation", .false.)
    call wx_menu_append_separator(play_menu)
    call wx_menu_append(play_menu, int(ID_SET_NULL_ANIMATION, c_int), &
        "Set null animation", "Sets the empty animation in the control", .false.)
    call wx_menu_append_check_item(play_menu, int(ID_SET_INACTIVE_BITMAP, c_int), &
        "Set inactive bitmap", "Sets an inactive bitmap for the control")
    call wx_menu_append_check_item(play_menu, int(ID_SET_NO_AUTO_RESIZE, c_int), &
        "Set no autoresize", "Tells the control not to resize automatically")
    call wx_menu_append(play_menu, int(ID_SET_BGCOLOR, c_int), &
        "Set background colour...", &
        "Sets the background colour of the control", .false.)
    ! wxHAS_NATIVE_ANIMATIONCTRL is not defined here: no ID_USE_GENERIC item.

    ! wxMenu *help_menu = new wxMenu;
    help_menu = wx_menu_create("", 0_c_long)
    call wx_menu_append(help_menu, wxID_ABOUT(), "&About", "", .false.)

    ! wxMenuBar *menu_bar = new wxMenuBar;
    menu_bar = wx_menu_bar_create(0)
    dummy = wx_menu_bar_append(menu_bar, file_menu, "&File")
    dummy = wx_menu_bar_append(menu_bar, play_menu, "&Animation")
    dummy = wx_menu_bar_append(menu_bar, help_menu, "&Help")
    call wx_frame_set_menu_bar(g_frame, menu_bar)

    ! CreateStatusBar();
    status_bar = wx_frame_create_status_bar(g_frame, 1, wxSTB_DEFAULT_STYLE(), 0)

    ! ---------------------------------------------------------------------
    ! wxSizer *sz = new wxBoxSizer(wxVERTICAL);
    ! ---------------------------------------------------------------------
    g_top_sizer = wx_box_sizer_create(wxVERTICAL())

    title_label = wx_static_text_create(g_frame, wxID_ANY(), "wxAnimationCtrl:", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call add_window(g_top_sizer, title_label, 0_c_int, &
        ior(wxALIGN_CENTRE(), wxALL()), border)

    g_anim_ctrl = wx_animation_ctrl_create(g_frame, wxID_ANY(), -1_c_int, &
        -1_c_int, -1_c_int, -1_c_int, wxAC_DEFAULT_STYLE())

    ! wxAnimationBundle animations;
    ! wxAnimation throbber("throbber.gif");
    ! wxAnimation throbber2x("throbber_2x.gif");
    animations = wx_animation_bundle_create()

    throbber = wx_animation_create_from_file("throbber.gif", &
        wxANIMATION_TYPE_ANY())
    if (c_associated(throbber%ptr)) call wx_animation_bundle_add(animations, throbber)

    throbber2x = wx_animation_create_from_file("throbber_2x.gif", &
        wxANIMATION_TYPE_ANY())
    if (c_associated(throbber2x%ptr)) &
        call wx_animation_bundle_add(animations, throbber2x)

    if (wx_animation_bundle_is_ok(animations)) then
        call wx_animation_ctrl_set_animation_bundle(g_anim_ctrl, animations)
        played = wx_animation_ctrl_play(g_anim_ctrl)
    end if

    call wx_animation_delete(throbber)
    call wx_animation_delete(throbber2x)
    call wx_animation_bundle_delete(animations)

    call add_window(g_top_sizer, animation_window(), 0_c_int, &
        ior(wxALIGN_CENTRE(), wxALL()), border)

    ! wxStaticBoxSizer(wxVERTICAL, this, "Animation frames")
    g_frame_box = wx_static_box_create(g_frame, wxID_ANY(), "Animation frames", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    frame_sizer = wx_static_box_sizer_create(g_frame_box, wxVERTICAL())

    spin_sizer = wx_box_sizer_create(wxHORIZONTAL())
    frame_label = wx_static_text_create(g_frame_box, wxID_ANY(), "&Frame:", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call add_window(spin_sizer, frame_label, 0_c_int, &
        ior(wxALIGN_CENTRE_VERTICAL(), wxRIGHT()), border)

    g_frame_spin = wx_spin_ctrl_create(g_frame_box, wxID_ANY(), "", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, &
        int(wxSP_ARROW_KEYS(), c_long), 0_c_int, 100_c_int, 0_c_int)
    call add_window(spin_sizer, g_frame_spin, 0_c_int, &
        wxALIGN_CENTRE_VERTICAL(), 0_c_int)

    g_frame_count = wx_static_text_create(g_frame_box, wxID_ANY(), "", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call add_window(spin_sizer, g_frame_count, 0_c_int, &
        ior(wxALIGN_CENTRE_VERTICAL(), wxLEFT()), border)

    call add_sizer(frame_sizer, spin_sizer, 0_c_int, &
        ior(wxALIGN_CENTRE(), wxALL()), border)

    g_frame_delay = wx_static_text_create(g_frame_box, wxID_ANY(), "", &
        -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call add_window(frame_sizer, g_frame_delay, 0_c_int, &
        ior(wxALIGN_CENTRE(), wxALL()), border)

    empty_bitmap = wx_bitmap_create_default()
    g_frame_bitmap = wx_static_bitmap_create(g_frame_box, wxID_ANY(), &
        empty_bitmap, -1_c_int, -1_c_int, -1_c_int, -1_c_int, 0_c_int)
    call wx_bitmap_delete(empty_bitmap)
    call add_window(frame_sizer, g_frame_bitmap, 0_c_int, &
        ior(wxALIGN_CENTRE(), wxALL()), border)

    call add_sizer(g_top_sizer, frame_sizer, 0_c_int, &
        ior(wxEXPAND(), wxALL()), border)

    call wx_window_set_sizer(g_frame, g_top_sizer, .true.)

    call update_frame_controls()

    ! SetSize(FromDIP(wxSize(500, 400)));
    width_px = wx_window_from_dip(g_frame, 500_c_int)
    height_px = wx_window_from_dip(g_frame, 400_c_int)
    call wx_window_set_size(g_frame, -1_c_int, -1_c_int, width_px, height_px, &
        wxSIZE_USE_EXISTING())

    ! ---------------------------------------------------------------------
    ! Event table
    ! ---------------------------------------------------------------------
    call wx_connect(g_frame, int(wxEVT_MENU()), on_play, id=ID_PLAY)
    call wx_connect(g_frame, int(wxEVT_MENU()), on_set_null_animation, &
        id=ID_SET_NULL_ANIMATION)
    call wx_connect(g_frame, int(wxEVT_MENU()), on_set_inactive_bitmap, &
        id=ID_SET_INACTIVE_BITMAP)
    call wx_connect(g_frame, int(wxEVT_MENU()), on_set_no_auto_resize, &
        id=ID_SET_NO_AUTO_RESIZE)
    call wx_connect(g_frame, int(wxEVT_MENU()), on_set_bg_color, id=ID_SET_BGCOLOR)

    call wx_connect(g_frame, int(wxEVT_MENU()), on_stop, id=int(wxID_STOP()))
    call wx_connect(g_frame, int(wxEVT_MENU()), on_about, id=int(wxID_ABOUT()))
    call wx_connect(g_frame, int(wxEVT_MENU()), on_quit, id=int(wxID_EXIT()))
    call wx_connect(g_frame, int(wxEVT_MENU()), on_open, id=int(wxID_OPEN()))

    call wx_connect(g_frame, int(wxEVT_SIZE()), on_size)
    call wx_connect(g_frame, int(wxEVT_UPDATE_UI()), on_update_ui)
    call wx_connect(g_frame_spin, int(wxEVT_SPINCTRL()), on_frame_spin)

    ! frame->Show(true);
    call wx_set_top_window(g_frame)
    shown = wx_window_show(g_frame)

    ! wxApp::OnRun()
    exit_code = wx_main_loop()

    call wx_shutdown()

end program animate
