*&---------------------------------------------------------------------*
*& Report Z_SF_ALV_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_sf_alv_01.

TABLES : zzempprac, zzempracdep.

TYPES : BEGIN OF ty_employee,
          emplnum   TYPE zzempprac-emplnum,
          emplname  TYPE zzempprac-emplname,
          empdept   TYPE zzempprac-empdept,
          empsalary TYPE zzempprac-empsalary,
          units     TYPE zzempprac-units,

          doj       TYPE zzempracdep-doj,
          role      TYPE zzempracdep-role,
        END OF ty_employee.

DATA : it_employee TYPE TABLE OF ty_employee,
       wa_employee TYPE ty_employee.

DATA : it_fldcat  TYPE slis_t_fieldcat_alv,
       wa_fldcat  LIKE LINE OF it_fldcat,
       wa_layout  TYPE slis_layout_alv,
       wa_variant TYPE disvariant,
       v_cnt      TYPE i.

DATA : fm_name            TYPE  rs38l_fnam,
       control_parameters TYPE  ssfctrlop,
       output_options     TYPE  ssfcompop.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS : p_name TYPE zzempprac-emplname.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM display_data.


*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  SELECT a~emplnum a~emplname a~empdept a~empsalary a~units b~doj b~role FROM zzempprac AS a INNER JOIN zzempracdep AS b
    ON a~emplnum = b~emplnum INTO CORRESPONDING FIELDS OF TABLE it_employee WHERE a~emplname = p_name.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

  wa_layout-colwidth_optimize  = 'X'.
  wa_layout-box_fieldname      = 'SEL'.

  wa_variant-report    = sy-repid.

  v_cnt = v_cnt + 1.
  wa_fldcat-col_pos     = v_cnt.
  wa_fldcat-fieldname   = 'EMPLNUM'.
  wa_fldcat-seltext_m   = 'NUMBER'.
  wa_fldcat-hotspot     = 'X'.
  APPEND wa_fldcat TO it_fldcat.
  CLEAR : wa_fldcat.

  v_cnt = v_cnt + 1.
  wa_fldcat-col_pos     = v_cnt.
  wa_fldcat-fieldname   = 'EMPLNAME'.
  wa_fldcat-seltext_m   = 'NUMBER'.
  wa_fldcat-hotspot     = 'X'.
  APPEND wa_fldcat TO it_fldcat.
  CLEAR : wa_fldcat.

  v_cnt = v_cnt + 1.
  wa_fldcat-col_pos     = v_cnt.
  wa_fldcat-fieldname   = 'EMPDEPT'.
  wa_fldcat-seltext_m   = 'DEPARTMENT'.
  wa_fldcat-hotspot     = 'X'.
  APPEND wa_fldcat TO it_fldcat.
  CLEAR : wa_fldcat.

  v_cnt = v_cnt + 1.
  wa_fldcat-col_pos     = v_cnt.
  wa_fldcat-fieldname   = 'EMPSALARY'.
  wa_fldcat-seltext_m   = 'SALARY'.
  wa_fldcat-hotspot     = 'X'.
  APPEND wa_fldcat TO it_fldcat.
  CLEAR : wa_fldcat.

  v_cnt = v_cnt + 1.
  wa_fldcat-col_pos     = v_cnt.
  wa_fldcat-fieldname   = 'UNITS'.
  wa_fldcat-seltext_m   = 'UNITS'.
  wa_fldcat-hotspot     = 'X'.
  APPEND wa_fldcat TO it_fldcat.
  CLEAR : wa_fldcat.

  v_cnt = v_cnt + 1.
  wa_fldcat-col_pos     = v_cnt.
  wa_fldcat-fieldname   = 'DOJ'.
  wa_fldcat-seltext_m   = 'DOJ'.
  wa_fldcat-hotspot     = 'X'.
  APPEND wa_fldcat TO it_fldcat.
  CLEAR : wa_fldcat.

  v_cnt = v_cnt + 1.
  wa_fldcat-col_pos     = v_cnt.
  wa_fldcat-fieldname   = 'ROLE'.
  wa_fldcat-seltext_m   = 'ROLE'.
  wa_fldcat-hotspot     = 'X'.
  APPEND wa_fldcat TO it_fldcat.
  CLEAR : wa_fldcat.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK       = ' '
*     I_BYPASSING_BUFFER      = ' '
*     I_BUFFER_ACTIVE         = ' '
      i_callback_program      = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
      i_callback_user_command = 'USER_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE  = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME        =
*     I_BACKGROUND_ID         = ' '
*     I_GRID_TITLE            =
*     I_GRID_SETTINGS         =
      is_layout               = wa_layout
      it_fieldcat             = it_fldcat
*     IT_EXCLUDING            =
*     IT_SPECIAL_GROUPS       =
*     IT_SORT                 =
*     IT_FILTER               =
*     IS_SEL_HIDE             =
*     I_DEFAULT               = 'X'
      i_save                  = 'X'
      is_variant              = wa_variant
*     IT_EVENTS               =
*     IT_EVENT_EXIT           =
*     IS_PRINT                =
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
*     I_HTML_HEIGHT_TOP       = 0
*     I_HTML_HEIGHT_END       = 0
*     IT_ALV_GRAPHICS         =
*     IT_HYPERLINK            =
*     IT_ADD_FIELDCAT         =
*     IT_EXCEPT_QINFO         =
*     IR_SALV_FULLSCREEN_ADAPTER        =
*     O_PREVIOUS_SRAL_HANDLER =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      t_outtab                = it_employee
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN '&IC1'.
      CLEAR : wa_employee.
      READ TABLE it_employee INTO wa_employee INDEX rs_selfield-tabindex.
      IF wa_employee-emplnum IS NOT INITIAL.
        PERFORM call_sf.
      ENDIF.

  ENDCASE.

  CLEAR : wa_employee, sy-ucomm.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form call_sf
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_sf .

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'Z_EMPLISTFORM_02'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      fm_name            = fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  control_parameters-preview    = 'X'.
  control_parameters-no_dialog  = 'X'.

  output_options-tddest = 'LP01'.

  CALL FUNCTION fm_name      "/1BCDWB/SF00000094'
    EXPORTING
*     ARCHIVE_INDEX      =
*     ARCHIVE_INDEX_TAB  =
*     ARCHIVE_PARAMETERS =
      control_parameters = control_parameters
*     MAIL_APPL_OBJ      =
*     MAIL_RECIPIENT     =
*     MAIL_SENDER        =
      output_options     = output_options
      user_settings      = 'X'
      p_ename            = wa_employee-emplname
*   IMPORTING
*     DOCUMENT_OUTPUT_INFO       =
*     JOB_OUTPUT_INFO    =
*     JOB_OUTPUT_OPTIONS =
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.