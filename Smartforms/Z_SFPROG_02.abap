*&---------------------------------------------------------------------*
*& Report Z_SFPROG_02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_SFPROG_02.

data:ssf_fm_name type rs38l_fnam.

data: device_type type rspoptype.

data: gv_output_options  type ssfcompop.
data: gv_control_parameters type ssfctrlop.
data:gv_job_output_info   type ssfcrescl.
data: gv_bin_filesize  type i.
data: gt_lines type table of tline.

data: gv_filename type string,
gv_path type string,
gv_fullpath type string.

call function 'SSF_FUNCTION_MODULE_NAME'
  exporting
    formname                 = 'Z_SFORM_10'
*   VARIANT                  = ' '
*   DIRECT_CALL              = ' '
 importing
   fm_name                  = ssf_fm_name
 exceptions
   no_form                  = 1
   no_function_module       = 2
   others                   = 3
          .
if sy-subrc <> 0.
 message id sy-msgid type sy-msgty number sy-msgno
         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
endif.


call function 'SSF_GET_DEVICE_TYPE'
  exporting
    i_language                   = sy-langu
*   I_APPLICATION                = 'SAPDEFAULT'
 importing
   e_devtype                    = device_type
 exceptions
   no_language                  = 1
   language_not_installed       = 2
   no_devtype_found             = 3
   system_error                 = 4
   others                       = 5
          .
if sy-subrc <> 0.
 message id sy-msgid type sy-msgty number sy-msgno
         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
endif.


gv_output_options-tdprinter = device_type.
gv_control_parameters-no_dialog = 'X'.
gv_control_parameters-getotf = 'X'.

call function ssf_fm_name
 exporting
*   ARCHIVE_INDEX              =
*   ARCHIVE_INDEX_TAB          =
*   ARCHIVE_PARAMETERS         =
   control_parameters         = gv_control_parameters
*   MAIL_APPL_OBJ              =
*   MAIL_RECIPIENT             =
*   MAIL_SENDER                =
   output_options             = gv_output_options
*   USER_SETTINGS              = 'X'
 importing
*   DOCUMENT_OUTPUT_INFO       =
   job_output_info            =  gv_job_output_info
*   JOB_OUTPUT_OPTIONS         =
 exceptions
   formatting_error           = 1
   internal_error             = 2
   send_error                 = 3
   user_canceled              = 4
   others                     = 5
          .
if sy-subrc <> 0.
 message id sy-msgid type sy-msgty number sy-msgno
         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
endif.


call function 'CONVERT_OTF'
 exporting
   format                      = 'PDF'
*   MAX_LINEWIDTH               = 132
*   ARCHIVE_INDEX               = ' '
*   COPYNUMBER                  = 0
*   ASCII_BIDI_VIS2LOG          = ' '
*   PDF_DELETE_OTFTAB           = ' '
 importing
   bin_filesize                =  gv_bin_filesize
*   BIN_FILE                    =
  tables
    otf                         = gv_job_output_info-otfdata
    lines                       =  gt_lines
 exceptions
   err_max_linewidth           = 1
   err_format                  = 2
   err_conv_not_possible       = 3
   err_bad_otf                 = 4
   others                      = 5
          .
if sy-subrc <> 0.
 message id sy-msgid type sy-msgty number sy-msgno
         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
endif.


call method cl_gui_frontend_services=>file_save_dialog
*  EXPORTING
*    WINDOW_TITLE         =
*    DEFAULT_EXTENSION    =
*    DEFAULT_FILE_NAME    =
*    WITH_ENCODING        =
*    FILE_FILTER          =
*    INITIAL_DIRECTORY    =
*    PROMPT_ON_OVERWRITE  = 'X'
  changing
    filename             = gv_filename
    path                 = gv_path
    fullpath             =  gv_fullpath
*    USER_ACTION          =
*    FILE_ENCODING        =
  exceptions
    cntl_error           = 1
    error_no_gui         = 2
    not_supported_by_gui = 3
    others               = 4
        .
if sy-subrc <> 0.
 message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
endif.




call function 'GUI_DOWNLOAD'
  exporting
   bin_filesize                    = gv_bin_filesize
    filename                        = gv_fullpath
   filetype                        = 'BIN'
*   APPEND                          = ' '
*   WRITE_FIELD_SEPARATOR           = ' '
*   HEADER                          = '00'
*   TRUNC_TRAILING_BLANKS           = ' '
*   WRITE_LF                        = 'X'
*   COL_SELECT                      = ' '
*   COL_SELECT_MASK                 = ' '
*   DAT_MODE                        = ' '
*   CONFIRM_OVERWRITE               = ' '
*   NO_AUTH_CHECK                   = ' '
*   CODEPAGE                        = ' '
*   IGNORE_CERR                     = ABAP_TRUE
*   REPLACEMENT                     = '#'
*   WRITE_BOM                       = ' '
*   TRUNC_TRAILING_BLANKS_EOL       = 'X'
*   WK1_N_FORMAT                    = ' '
*   WK1_N_SIZE                      = ' '
*   WK1_T_FORMAT                    = ' '
*   WK1_T_SIZE                      = ' '
* IMPORTING
*   FILELENGTH                      =
  tables
    data_tab                        =  gt_lines
*   FIELDNAMES                      =
 exceptions
   file_write_error                = 1
   no_batch                        = 2
   gui_refuse_filetransfer         = 3
   invalid_type                    = 4
   no_authority                    = 5
   unknown_error                   = 6
   header_not_allowed              = 7
   separator_not_allowed           = 8
   filesize_not_allowed            = 9
   header_too_long                 = 10
   dp_error_create                 = 11
   dp_error_send                   = 12
   dp_error_write                  = 13
   unknown_dp_error                = 14
   access_denied                   = 15
   dp_out_of_memory                = 16
   disk_full                       = 17
   dp_timeout                      = 18
   file_not_found                  = 19
   dataprovider_exception          = 20
   control_flush_error             = 21
   others                          = 22
          .
if sy-subrc <> 0.
 message id sy-msgid type sy-msgty number sy-msgno
         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
endif.