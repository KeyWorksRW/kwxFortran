! archive.f90 - wxWidgets archive sample ported to kwxFortran
!
! Fortran port of wxSamples/src/archive/archive.cpp.
!
! The C++ sample is a wxAppConsole command line utility:
!
!   c <archive> [file...]   create  (zip/tar, or a single-file filter)
!   l <archive>             list    (zip/tar, or the filter name)
!   x <archive>             extract (zip/tar, or the filter name)
!
!   --force-zip64           force ZIP64 when creating zip archives
!   -h, --help              show the usage text
!   --verbose               enable verbose wxWidgets logging
!
! The port runs the same wxAppConsole lifecycle through kwxConsoleInitialize(),
! kwxConsoleRun() and kwxConsoleShutdown().  A kwxAppConsole object supplies the
! OnInitCmdLine/OnCmdLineParsed/OnRun callbacks that the C++ subclass overrides,
! wxCmdLineParser parses the real process command line, and the console
! application traits route diagnostics and usage text to stderr.  The target is
! built as a console-subsystem executable.
!
! Everything the C++ sample prints with wxPrintf() goes through wxPrintf() here
! too, so it travels the process-wide wxMessageOutput (stderr for a console
! application) instead of Fortran's stdout.  The process exit code is handed to
! the C runtime with exit(), which is what returning a value from main() does in
! the original, so no Fortran "STOP n" banner is ever printed.

module archive_globals
    use kwx_types
    implicit none

    integer, parameter :: CMD_CREATE = 0
    integer, parameter :: CMD_LIST = 1
    integer, parameter :: CMD_EXTRACT = 2
    integer, parameter :: CMD_NONE = 3

    integer, parameter :: COPY_BUFFER_SIZE = 128 * 1024
    integer, parameter :: MAX_ARG_LEN = 32767

    ! ArchiveApp state.
    type(wxarchiveclassfactory_t), save :: g_archive_factory
    type(wxfilterclassfactory_t), save :: g_filter_factory
    character(len=:), allocatable, save :: g_archive_file_name
    character(len=MAX_ARG_LEN), allocatable, save :: g_file_names(:)
    integer, save :: g_command = CMD_NONE
    logical, save :: g_force_zip64 = .false.

end module archive_globals


module archive_util
    use, intrinsic :: iso_c_binding
    use kwx_types
    use kwxffi
    use wx_string, only: to_wxstring, wxString_Delete
    use wx_archive_class_factory
    use wx_filter_class_factory
    use wx_filter_class_factory_base
    use wx_file_input_stream
    use wx_filter_input_stream
    use wx_filter_output_stream
    use wx_temp_file_output_stream
    use wx_archive_input_stream
    use wx_archive_output_stream
    use wx_input_stream
    use wx_output_stream
    use wx_archive_entry
    use wx_file_name
    use wx_date_time
    use wx_zip_output_stream
    use wx_cmd_line_parser
    use wx_log, only: wx_log_get_active_target, wx_log_set_verbose
    use archive_globals
    implicit none
    private

    public :: copy_stream_data
    public :: get_all_supported
    public :: file_name_full_name
    public :: file_name_name
    public :: file_name_path_of
    public :: log_error
    public :: log_warning
    public :: print_text
    public :: configure_cmd_line
    public :: parse_command_line_params
    public :: run_command

contains

    ! ArchiveApp's wxLogError calls.  A wxAppConsole installs wxLogOutputBest,
    ! so the record is formatted and written to stderr like the C++ sample.
    subroutine log_error(message)
        character(len=*), intent(in) :: message
        type(c_ptr) :: message_ptr

        message_ptr = to_wxstring(message)
        call LogError(message_ptr)
        call wxString_Delete(message_ptr)
    end subroutine log_error

    ! ArchiveApp's wxLogWarning call, used for entries with unsafe names.
    subroutine log_warning(message)
        character(len=*), intent(in) :: message
        type(c_ptr) :: message_ptr

        message_ptr = to_wxstring(message)
        call LogWarning(message_ptr)
        call wxString_Delete(message_ptr)
    end subroutine log_warning

    ! ArchiveApp's wxPrintf calls.  The FFI primitive takes an already formatted
    ! string and still routes it through wxMessageOutput, exactly like the
    ! variadic wxPrintf("%s", text) the C++ sample uses.
    subroutine print_text(message)
        character(len=*), intent(in) :: message
        type(c_ptr) :: message_ptr
        integer(c_int) :: written

        message_ptr = to_wxstring(message)
        written = wxPrintf(message_ptr)
        call wxString_Delete(message_ptr)
    end subroutine print_text

    function append_joined(all, joined) result(result_text)
        character(len=*), intent(in) :: all
        character(len=*), intent(in) :: joined
        character(len=:), allocatable :: result_text

        if (len(joined) == 0) then
            result_text = all
        else if (len(all) == 0) then
            result_text = joined
        else
            result_text = all // ", " // joined
        end if
    end function append_joined

    ! Returns all supported protocols or extensions, archive factories first
    ! and filter factories second, matching GetAllSupported() in the sample.
    function get_all_supported(protocol_type) result(result_text)
        integer(c_int), intent(in) :: protocol_type
        character(len=:), allocatable :: result_text
        character(len=:), allocatable :: joined
        type(wxarchiveclassfactory_t) :: archive_factory
        type(wxfilterclassfactory_t) :: filter_factory

        result_text = ""

        archive_factory = wx_archive_class_factory_get_first()
        do while (archive_factory%is_valid())
            joined = wx_filter_class_factory_base_get_protocols( &
                archive_factory, protocol_type)
            result_text = append_joined(result_text, joined)
            archive_factory = wx_archive_class_factory_get_next(archive_factory)
        end do

        filter_factory = wx_filter_class_factory_get_first()
        do while (filter_factory%is_valid())
            joined = wx_filter_class_factory_base_get_protocols( &
                filter_factory, protocol_type)
            result_text = append_joined(result_text, joined)
            filter_factory = wx_filter_class_factory_get_next(filter_factory)
        end do
    end function get_all_supported

    function file_name_full_name(path) result(result_text)
        character(len=*), intent(in) :: path
        character(len=:), allocatable :: result_text
        type(wxfilename_t) :: file_name

        file_name = wx_file_name_create_from_path(path, wxPATH_NATIVE())
        if (file_name%is_valid()) then
            result_text = wx_file_name_get_full_name(file_name)
        else
            result_text = ""
        end if
        call wx_file_name_delete(file_name)
    end function file_name_full_name

    function file_name_name(path) result(result_text)
        character(len=*), intent(in) :: path
        character(len=:), allocatable :: result_text
        type(wxfilename_t) :: file_name

        file_name = wx_file_name_create_from_path(path, wxPATH_NATIVE())
        if (file_name%is_valid()) then
            result_text = wx_file_name_get_name(file_name)
        else
            result_text = ""
        end if
        call wx_file_name_delete(file_name)
    end function file_name_name

    function file_name_path_of(path) result(result_text)
        character(len=*), intent(in) :: path
        character(len=:), allocatable :: result_text
        type(wxfilename_t) :: file_name

        file_name = wx_file_name_create_from_path(path, wxPATH_NATIVE())
        if (file_name%is_valid()) then
            result_text = wx_file_name_get_path(file_name, &
                wxPATH_GET_VOLUME(), wxPATH_NATIVE())
        else
            result_text = ""
        end if
        call wx_file_name_delete(file_name)
    end function file_name_path_of

    ! ArchiveApp::CopyStreamData
    function copy_stream_data(input, output, size) result(ok)
        class(wxinputstream_t), intent(in) :: input
        class(wxoutputstream_t), intent(in) :: output
        integer(c_int64_t), intent(in) :: size
        logical :: ok
        character(kind=c_char), allocatable, target :: buffer(:)
        integer(c_int) :: read_size
        integer(c_int) :: actually_read
        integer(c_int64_t) :: copied_data

        ok = .true.
        allocate(buffer(COPY_BUFFER_SIZE))
        read_size = int(COPY_BUFFER_SIZE, c_int)
        copied_data = 0_c_int64_t

        do
            if (size /= -1_c_int64_t) then
                if (copied_data + int(read_size, c_int64_t) > size) then
                    read_size = int(size - copied_data, c_int)
                end if
            end if

            call wx_input_stream_read(input, c_loc(buffer(1)), read_size)
            actually_read = wx_input_stream_last_read(input)
            call wx_output_stream_write(output, c_loc(buffer(1)), actually_read)

            if (wx_output_stream_last_write(output) /= actually_read) then
                call log_error("Failed to output data")
                ok = .false.
                exit
            end if

            if (size == -1_c_int64_t) then
                if (wx_input_stream_eof(input)) exit
            else
                copied_data = copied_data + int(actually_read, c_int64_t)
                if (copied_data >= size) exit
            end if
        end do

        deallocate(buffer)
    end function copy_stream_data

    function padded_size(value) result(result_text)
        integer(c_int64_t), intent(in) :: value
        character(len=:), allocatable :: result_text
        character(len=64) :: buffer
        integer :: length

        write(buffer, '(I0)') value
        buffer = adjustl(buffer)
        length = len_trim(buffer)
        if (length < 10) then
            result_text = repeat(" ", 10 - length) // buffer(1:length)
        else
            result_text = buffer(1:length)
        end if
    end function padded_size

    function int_to_string(value) result(result_text)
        integer, intent(in) :: value
        character(len=:), allocatable :: result_text
        character(len=32) :: buffer

        write(buffer, '(I0)') value
        buffer = adjustl(buffer)
        result_text = buffer(1:len_trim(buffer))
    end function int_to_string

    function lowercase(text) result(result_text)
        character(len=*), intent(in) :: text
        character(len=:), allocatable :: result_text
        integer :: i, code

        result_text = text
        do i = 1, len(result_text)
            code = iachar(result_text(i:i))
            if (code >= iachar('A') .and. code <= iachar('Z')) then
                result_text(i:i) = achar(code + 32)
            end if
        end do
    end function lowercase

    ! ArchiveApp::OnInitCmdLine.  The h/help and verbose switches reproduce
    ! wxAppConsoleBase::OnInitCmdLine(), which the C++ override calls first.
    subroutine configure_cmd_line(parser)
        type(wxcmdlineparser_t), intent(in) :: parser
        character(len=:), allocatable :: supported
        integer(c_int) :: param_flags

        call wx_cmd_line_parser_add_switch(parser, "h", "help", &
            "show this help message", wxCMD_LINE_OPTION_HELP())
        call wx_cmd_line_parser_add_switch(parser, "", "verbose", &
            "generate verbose log messages", 0_c_int)
        call wx_cmd_line_parser_add_param(parser, "command", &
            wxCMD_LINE_VAL_STRING(), 0_c_int)
        call wx_cmd_line_parser_add_param(parser, "archive_name", &
            wxCMD_LINE_VAL_STRING(), 0_c_int)

        param_flags = ior(wxCMD_LINE_PARAM_MULTIPLE(), &
            wxCMD_LINE_PARAM_OPTIONAL())
        call wx_cmd_line_parser_add_param(parser, "file_names", &
            wxCMD_LINE_VAL_STRING(), param_flags)

        call wx_cmd_line_parser_add_switch(parser, "", "force-zip64", &
            "Force ZIP64 format when creating ZIP archives", 0_c_int)

        call wx_cmd_line_parser_add_usage_text(parser, achar(10) // "command:")
        call wx_cmd_line_parser_add_usage_text(parser, "  c: create")
        call wx_cmd_line_parser_add_usage_text(parser, "  l: list")
        call wx_cmd_line_parser_add_usage_text(parser, "  x: extract")

        supported = get_all_supported(wxSTREAM_PROTOCOL())
        call wx_cmd_line_parser_add_usage_text(parser, &
            achar(10) // "supported formats: " // supported)
    end subroutine configure_cmd_line

    ! ArchiveApp::OnCmdLineParsed.  Returning .false. makes wxAppConsole::OnInit
    ! fail exactly where the C++ override does.
    function parse_command_line_params(parser) result(ok)
        type(wxcmdlineparser_t), intent(in) :: parser
        logical :: ok
        character(len=:), allocatable :: command
        integer :: i, param_count

        ok = .false.
        g_command = CMD_NONE

        command = wx_cmd_line_parser_get_param(parser, 0_c_int)
        select case (command)
        case ("c")
            g_command = CMD_CREATE
        case ("l")
            g_command = CMD_LIST
        case ("x")
            g_command = CMD_EXTRACT
        end select

        if (g_command == CMD_NONE) then
            call log_error("Invalid command: " // command)
            return
        end if

        g_archive_file_name = wx_cmd_line_parser_get_param(parser, 1_c_int)

        param_count = int(wx_cmd_line_parser_get_param_count(parser))
        if (allocated(g_file_names)) deallocate(g_file_names)
        allocate(g_file_names(max(0, param_count - 2)))
        do i = 2, param_count - 1
            g_file_names(i - 1) = wx_cmd_line_parser_get_param( &
                parser, int(i, c_int))
        end do

        g_force_zip64 = (wx_cmd_line_parser_found_switch(parser, &
            "force-zip64") == wxCMD_SWITCH_ON())

        ! wxAppConsoleBase::OnCmdLineParsed() enables verbose logging.
        if (wx_cmd_line_parser_found(parser, "verbose")) call set_verbose_log()

        ok = .true.
    end function parse_command_line_params

    subroutine set_verbose_log()
        type(wxlog_t) :: log

        log%ptr = wx_log_get_active_target()
        call wx_log_set_verbose(log, .true.)
    end subroutine set_verbose_log

    ! ArchiveApp::OnRun
    function run_command() result(code)
        integer :: code
        character(len=:), allocatable :: supported

        code = -1

        g_archive_factory = wx_archive_class_factory_find( &
            g_archive_file_name, wxSTREAM_FILEEXT())
        if (.not. g_archive_factory%is_valid()) then
            g_filter_factory = wx_filter_class_factory_find( &
                g_archive_file_name, wxSTREAM_FILEEXT())
            if (.not. g_filter_factory%is_valid()) then
                supported = get_all_supported(wxSTREAM_FILEEXT())
                call log_error('File "' // g_archive_file_name // &
                    '" has unsupported extension, supported ones are: ' // &
                    supported)
                return
            end if
        end if

        select case (g_command)
        case (CMD_CREATE)
            code = do_create()
        case (CMD_LIST)
            code = do_list()
        case (CMD_EXTRACT)
            code = do_extract()
        end select
    end function run_command

    ! ArchiveApp::DoCreate
    function do_create() result(code)
        integer :: code
        type(wxtempfileoutputstream_t) :: file_output
        type(wxarchiveoutputstream_t) :: archive_output
        type(wxzipoutputstream_t) :: zip_output
        type(wxfilteroutputstream_t) :: filter_output
        type(wxfileinputstream_t) :: input
        type(wxdatetime_t) :: date_time
        character(len=:), allocatable :: full_name, protocol
        integer(c_int64_t) :: length
        integer :: i
        logical :: entry_started

        code = -1

        if (size(g_file_names) == 0) then
            call log_error("Need at least one file to add to archive")
            return
        end if

        file_output = wx_temp_file_output_stream_create(g_archive_file_name)
        if (.not. file_output%is_valid()) then
            code = 1
            return
        end if

        if (g_archive_factory%is_valid()) then
            archive_output = wx_archive_class_factory_new_stream_output( &
                g_archive_factory, file_output)
            if (.not. archive_output%is_valid()) then
                code = 1
                goto 900
            end if

            if (g_force_zip64) then
                protocol = lowercase( &
                    wx_filter_class_factory_base_get_protocol(g_archive_factory))
                if (trim(protocol) == "zip") then
                    zip_output = wxzipoutputstream_from_ptr( &
                        archive_output%ptr, .false.)
                    call wx_zip_output_stream_set_format(zip_output, &
                        wxZIP_FORMAT_ZIP64())
                end if
            end if

            do i = 1, size(g_file_names)
                full_name = file_name_full_name(trim(g_file_names(i)))
                call print_text("Adding " // full_name // "..." // achar(10))

                input = wx_file_input_stream_create(trim(g_file_names(i)))
                if (.not. input%is_valid()) then
                    code = 1
                    goto 900
                end if
                if (.not. wx_file_input_stream_is_ok(input)) then
                    call log_error("Could not open file")
                    code = 1
                    goto 900
                end if

                length = int(wx_file_input_stream_get_length(input), c_int64_t)
                date_time = wx_date_time_create()
                if (.not. date_time%is_valid()) then
                    code = 1
                    goto 900
                end if
                call wx_date_time_now(date_time)

                entry_started = wx_archive_output_stream_put_next_entry_date( &
                    archive_output, full_name, date_time, length)
                call wx_date_time_delete(date_time)
                if (.not. entry_started) exit

                if (.not. copy_stream_data(input, archive_output, length)) then
                    code = 1
                    goto 900
                end if

                call wx_file_input_stream_delete(input)
            end do

            if (.not. wx_filter_output_stream_close(archive_output)) then
                code = 1
                goto 900
            end if
            call wx_archive_output_stream_delete(archive_output)
            code = 0
        else
            if (size(g_file_names) /= 1) then
                call log_error( &
                    "Filter-based formats only support archives consisting of a single file")
                code = -1
                goto 900
            end if

            filter_output = wx_filter_class_factory_new_stream_output( &
                g_filter_factory, file_output)
            if (.not. filter_output%is_valid()) then
                code = 1
                goto 900
            end if

            input = wx_file_input_stream_create(trim(g_file_names(1)))
            if (.not. input%is_valid()) then
                code = 1
                goto 900
            end if
            if (.not. wx_file_input_stream_is_ok(input)) then
                call log_error("Could not open file")
                code = 1
                goto 900
            end if

            length = int(wx_file_input_stream_get_length(input), c_int64_t)
            if (.not. copy_stream_data(input, filter_output, length)) then
                code = 1
                goto 900
            end if

            call wx_file_input_stream_delete(input)
            call wx_filter_output_stream_delete(filter_output)
            code = 0
        end if

        if (.not. wx_temp_file_output_stream_commit(file_output)) then
            ! The C++ sample ignores the Commit() result.
        end if
        call print_text("Created archive" // achar(10))
        code = 0

900     continue
        call wx_file_input_stream_delete(input)
        call wx_date_time_delete(date_time)
        call wx_archive_output_stream_delete(archive_output)
        call wx_filter_output_stream_delete(filter_output)
        call wx_temp_file_output_stream_delete(file_output)
    end function do_create

    ! ArchiveApp::DoList
    function do_list() result(code)
        integer :: code
        type(wxfileinputstream_t) :: input
        type(wxarchiveinputstream_t) :: archive_stream
        type(wxarchiveentry_t) :: entry
        type(wxdatetime_t) :: date_time
        character(len=:), allocatable :: iso_date, iso_time, entry_name
        integer(c_int64_t) :: entry_size, combined_size
        integer :: entry_count

        code = 1

        input = wx_file_input_stream_create(g_archive_file_name)
        if (.not. input%is_valid()) goto 900
        if (.not. wx_file_input_stream_is_ok(input)) goto 900

        if (g_archive_factory%is_valid()) then
            archive_stream = wx_archive_class_factory_new_stream_input( &
                g_archive_factory, input)
            if (.not. archive_stream%is_valid()) goto 900

            call print_text("Archive: " // g_archive_file_name // achar(10))
            call print_text("Length     Date       Time     Name" // achar(10))
            call print_text("---------- ---------- -------- ----" // achar(10))

            combined_size = 0_c_int64_t
            entry_count = 0

            do
                entry = wx_archive_input_stream_get_next_entry(archive_stream)
                if (.not. entry%is_valid()) exit

                entry_size = wx_archive_entry_get_size(entry)
                combined_size = combined_size + entry_size
                entry_count = entry_count + 1

                date_time = wx_archive_entry_get_date_time(entry)
                if (date_time%is_valid()) then
                    iso_date = wx_date_time_format_iso_date(date_time)
                    iso_time = wx_date_time_format_iso_time(date_time)
                else
                    iso_date = ""
                    iso_time = ""
                end if
                call wx_date_time_delete(date_time)

                entry_name = wx_archive_entry_get_name(entry, wxPATH_NATIVE())
                call print_text(padded_size(entry_size) // " " // iso_date // &
                    " " // iso_time // " " // entry_name // achar(10))

                call wx_archive_entry_delete(entry)
            end do

            call print_text("----------" // repeat(" ", 21) // "-------" // &
                achar(10))
            call print_text(padded_size(combined_size) // repeat(" ", 21) // &
                int_to_string(entry_count) // " files" // achar(10))

            code = 0
        else
            call print_text('Archive "' // g_archive_file_name // &
                '" contains a single file named "' // &
                file_name_name(g_archive_file_name) // '"' // achar(10))
            code = 0
        end if

900     continue
        call wx_archive_entry_delete(entry)
        call wx_date_time_delete(date_time)
        call wx_archive_input_stream_delete(archive_stream)
        call wx_file_input_stream_delete(input)
    end function do_list

    ! ArchiveApp::DoExtract
    function do_extract() result(code)
        integer :: code
        type(wxfileinputstream_t) :: input
        type(wxarchiveinputstream_t) :: archive_stream
        type(wxfilterinputstream_t) :: filter_stream
        type(wxarchiveentry_t) :: entry
        type(wxtempfileoutputstream_t) :: output
        character(len=:), allocatable :: entry_name, path, dir, output_name
        integer(c_int64_t) :: entry_size

        code = 1

        input = wx_file_input_stream_create(g_archive_file_name)
        if (.not. input%is_valid()) goto 900
        if (.not. wx_file_input_stream_is_ok(input)) goto 900

        if (g_archive_factory%is_valid()) then
            archive_stream = wx_archive_class_factory_new_stream_input( &
                g_archive_factory, input)
            if (.not. archive_stream%is_valid()) goto 900

            call print_text("Extracting from: " // g_archive_file_name // &
                achar(10))

            do
                entry = wx_archive_input_stream_get_next_entry(archive_stream)
                if (.not. entry%is_valid()) exit

                entry_name = wx_archive_entry_get_name(entry, wxPATH_NATIVE())
                path = wx_file_name_make_safe_relative_path(entry_name, &
                    wxPATH_NATIVE())
                if (len(path) == 0) then
                    call log_warning( &
                        'Skipping entry with unsafe name "' // entry_name // '".')
                    call wx_archive_entry_delete(entry)
                    cycle
                end if

                if (wx_archive_entry_is_dir(entry)) then
                    if (.not. wx_file_name_mkdir_for_path(path, &
                        wxS_DIR_DEFAULT(), wxPATH_MKDIR_FULL())) then
                        call wx_archive_entry_delete(entry)
                        goto 900
                    end if
                    call wx_archive_entry_delete(entry)
                    cycle
                end if

                dir = file_name_path_of(path)
                if (len(dir) > 0) then
                    if (.not. wx_file_name_mkdir_for_path(dir, &
                        wxS_DIR_DEFAULT(), wxPATH_MKDIR_FULL())) then
                        call wx_archive_entry_delete(entry)
                        goto 900
                    end if
                end if

                call print_text("Extracting: " // path // "..." // achar(10))
                output = wx_temp_file_output_stream_create(path)
                if (.not. output%is_valid()) then
                    call wx_archive_entry_delete(entry)
                    goto 900
                end if

                entry_size = wx_archive_entry_get_size(entry)
                if (.not. copy_stream_data(archive_stream, output, entry_size)) then
                    call wx_temp_file_output_stream_delete(output)
                    call wx_archive_entry_delete(entry)
                    goto 900
                end if

                if (.not. wx_temp_file_output_stream_commit(output)) then
                    ! The C++ sample ignores the Commit() result.
                end if
                call wx_temp_file_output_stream_delete(output)
                call wx_archive_entry_delete(entry)
            end do

            call print_text("Extracted all files" // achar(10))
            code = 0
        else
            filter_stream = wx_filter_class_factory_new_stream_input( &
                g_filter_factory, input)
            if (.not. filter_stream%is_valid()) goto 900

            call print_text("Extracting single file from: " // &
                g_archive_file_name // achar(10))

            output_name = file_name_name(g_archive_file_name)
            output = wx_temp_file_output_stream_create(output_name)
            if (.not. output%is_valid()) goto 900

            if (.not. copy_stream_data(filter_stream, output, -1_c_int64_t)) then
                call wx_temp_file_output_stream_delete(output)
                goto 900
            end if

            if (.not. wx_temp_file_output_stream_commit(output)) then
                ! The C++ sample ignores the Commit() result.
            end if
            call wx_temp_file_output_stream_delete(output)
            call print_text("Extracted successfully" // achar(10))
            code = 0
        end if

900     continue
        call wx_archive_entry_delete(entry)
        call wx_temp_file_output_stream_delete(output)
        call wx_archive_input_stream_delete(archive_stream)
        call wx_filter_input_stream_delete(filter_stream)
        call wx_file_input_stream_delete(input)
    end function do_extract

end module archive_util


module archive_handlers
    use, intrinsic :: iso_c_binding
    use kwx_types
    use wx_cmd_line_parser
    use archive_util
    implicit none
    private

    public :: on_init_cmd_line, on_cmd_line_parsed, on_run

contains

    ! ArchiveApp::OnInitCmdLine(void* appObject, wxCmdLineParser* parser)
    function on_init_cmd_line(app_object, parser_ptr) bind(C) result(rc)
        type(c_ptr), value :: app_object, parser_ptr
        integer(c_int) :: rc
        type(wxcmdlineparser_t) :: parser

        rc = 1
        if (.not. c_associated(parser_ptr)) return

        parser%ptr = parser_ptr
        parser%owned = .false.
        call configure_cmd_line(parser)
    end function on_init_cmd_line

    ! ArchiveApp::OnCmdLineParsed(void* appObject, wxCmdLineParser* parser)
    function on_cmd_line_parsed(app_object, parser_ptr) bind(C) result(rc)
        type(c_ptr), value :: app_object, parser_ptr
        integer(c_int) :: rc
        type(wxcmdlineparser_t) :: parser

        rc = 0
        if (.not. c_associated(parser_ptr)) return

        parser%ptr = parser_ptr
        parser%owned = .false.
        if (parse_command_line_params(parser)) rc = 1
    end function on_cmd_line_parsed

    ! ArchiveApp::OnRun(void* appObject)
    function on_run(app_object) bind(C) result(rc)
        type(c_ptr), value :: app_object
        integer(c_int) :: rc

        rc = int(run_command(), c_int)
    end function on_run

end module archive_handlers


program archive
    use, intrinsic :: iso_c_binding
    use, intrinsic :: iso_fortran_env, only: error_unit
    use kwx_types
    use kwxffi, only: kwxConsoleInitialize, kwxConsoleRun, kwxConsoleShutdown
    use kwx_app_console, only: kwx_app_console_create, &
        kwx_app_console_set_on_on_init_cmd_line, &
        kwx_app_console_set_on_on_cmd_line_parsed, &
        kwx_app_console_set_on_on_run
    use archive_globals
    use archive_handlers, only: on_init_cmd_line, on_cmd_line_parsed, on_run
    implicit none

    type(kwxappconsole_t) :: app
    character(kind=c_char), allocatable, target :: argv_storage(:)
    type(c_ptr), allocatable, target :: argv_ptrs(:)
    character(len=MAX_ARG_LEN) :: arg
    character(len=:), allocatable :: text
    integer(c_int) :: argc
    integer :: arg_count, i, j, max_len, stride, text_len, exit_code

    ! Build a C argv from the process command line so wxCmdLineParser sees the
    ! same arguments the C++ executable is started with.
    arg_count = command_argument_count() + 1
    max_len = 1
    do i = 0, arg_count - 1
        arg = ""
        call get_command_argument(i, arg)
        max_len = max(max_len, len_trim(arg))
    end do

    stride = max_len + 1
    allocate(argv_storage(arg_count * stride))
    allocate(argv_ptrs(arg_count + 1))
    argv_storage = c_null_char

    do i = 0, arg_count - 1
        arg = ""
        call get_command_argument(i, arg)
        text = trim(arg)
        text_len = len(text)
        do j = 1, text_len
            argv_storage(i * stride + j) = text(j:j)
        end do
        argv_storage(i * stride + text_len + 1) = c_null_char
        argv_ptrs(i + 1) = c_loc(argv_storage(i * stride + 1))
    end do
    argv_ptrs(arg_count + 1) = c_null_ptr
    argc = int(arg_count, c_int)

    ! Create the console application before initialization so the callbacks are
    ! installed; wxWidgets takes ownership of it in kwxConsoleInitialize().
    app%ptr = kwx_app_console_create(c_null_ptr)
    if (.not. app%is_valid()) then
        write(error_unit, '(A)') "Failed to create the console application"
        call exit(1)
    end if

    call kwx_app_console_set_on_on_init_cmd_line(app, &
        transfer(c_funloc(on_init_cmd_line), c_null_ptr))
    call kwx_app_console_set_on_on_cmd_line_parsed(app, &
        transfer(c_funloc(on_cmd_line_parsed), c_null_ptr))
    call kwx_app_console_set_on_on_run(app, &
        transfer(c_funloc(on_run), c_null_ptr))

    if (kwxConsoleInitialize(argc, c_loc(argv_ptrs(1))) == 0) then
        ! wxEntry() returns -1 when CallOnInit() fails: -h/--help, a command
        ! line error, or a library startup failure.  kwxConsoleInitialize()
        ! already ran wxEntryCleanup() in that path, so only the exit code is
        ! left to report.
        call exit(-1)
    end if

    exit_code = int(kwxConsoleRun())

    call kwxConsoleShutdown()

    ! main() in the C++ sample returns OnRun()'s value; exit() propagates the
    ! same code without printing the Fortran runtime's "STOP n" banner.
    if (exit_code /= 0) call exit(exit_code)

end program archive
