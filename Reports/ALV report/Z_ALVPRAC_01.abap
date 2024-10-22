*&---------------------------------------------------------------------*
*& Report Z_ALVPRAC_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_alvprac_01.

TABLES : zzempracdep , zzempprac .

TYPES : BEGIN OF ty_employee,
          sel,
          emplnum   TYPE zzempprac-emplnum,
          emplname  TYPE zzempprac-emplname,
          empdept   TYPE zzempprac-empdept,
          empsalary TYPE zzempprac-empsalary,
          units     TYPE zzempprac-units,

          doj       TYPE zzempracdep-doj,
          role      TYPE zzempracdep-role,
        END OF ty_employee.

DATA : it_employee TYPE TABLE OF ty_employee,
       wa_employe  TYPE ty_employee.

DATA : it_fcat TYPE lvc_t_fcat,
       wa_fcat LIKE LINE OF it_fcat.

DATA : gs_layout TYPE lvc_s_layo.

SELECTION-SCREEN BEGIN OF BLOCK 1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_enum FOR zzempprac-emplnum.

  PARAMETERS : p_role TYPE zzempracdep-role.
SELECTION-SCREEN END OF BLOCK 1.

AT SELECTION-SCREEN.
  PERFORM fetch_data.
  PERFORM build-data.
  PERFORM display-data.

*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data .

  SELECT a~emplnum a~emplname a~empdept a~empsalary a~units
         b~doj b~role FROM zzempprac AS a INNER JOIN zzempracdep AS b
         ON a~emplnum = b~emplnum INTO CORRESPONDING FIELDS OF TABLE it_employee WHERE
         a~emplnum IN s_enum OR
         b~role = p_role.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form build-data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build-data .

  gs_layout-col_opt    =  'X'.
  gs_layout-box_fname  =  'SEL'.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'EMPLNUM'.
  wa_fcat-coltext = 'Employee Number'.
  wa_fcat-ref_field = 'EMPLNUM'.
  wa_fcat-ref_table = 'ZZEMPPRAC'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'EMPLNAME'.
  wa_fcat-coltext = 'Employee Name'.
  wa_fcat-ref_field = 'EMPLNAME'.
  wa_fcat-ref_table = 'ZZEMPPRAC'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'EMPDEPT'.
  wa_fcat-coltext = 'Department'.
  wa_fcat-ref_field = 'EMPDEPT'.
  wa_fcat-ref_table = 'ZZEMPPRAC'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'EMPSALARY'.
  wa_fcat-coltext = 'Salary'.
  wa_fcat-ref_field = 'EMPSALARY'.
  wa_fcat-ref_table = 'ZZEMPPRAC'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'UNITS'.
  wa_fcat-coltext = 'Units'.
  wa_fcat-ref_field = 'UNITS'.
  wa_fcat-ref_table = 'ZZEMPPRAC'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'DOJ'.
  wa_fcat-coltext = 'Date of Joining'.
  wa_fcat-ref_field = 'DOJ'.
  wa_fcat-ref_table = 'ZZEMPRACDEP'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'ROLE'.
  wa_fcat-coltext = 'Role'.
  wa_fcat-ref_field = 'ROLE'.
  wa_fcat-ref_table = 'ZZEMPRACDEP'.
  APPEND wa_fcat TO it_fcat.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form display-data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display-data .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
*     I_INTERFACE_CHECK  = ' '
*     I_BYPASSING_BUFFER =
*     I_BUFFER_ACTIVE    =
      i_callback_program = 'sy_repid'
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME   =
*     I_BACKGROUND_ID    = ' '
*     I_GRID_TITLE       =
*     I_GRID_SETTINGS    =
      is_layout_lvc      = gs_layout
      it_fieldcat_lvc    = it_fcat
*     IT_EXCLUDING       =
*     IT_SPECIAL_GROUPS_LVC             =
*     IT_SORT_LVC        =
*     IT_FILTER_LVC      =
*     IT_HYPERLINK       =
*     IS_SEL_HIDE        =
*     I_DEFAULT          = 'X'
*     I_SAVE             = ' '
*     IS_VARIANT         =
*     IT_EVENTS          =
*     IT_EVENT_EXIT      =
*     IS_PRINT_LVC       =
*     IS_REPREP_ID_LVC   =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE  = 0
*     I_HTML_HEIGHT_TOP  =
*     I_HTML_HEIGHT_END  =
*     IT_ALV_GRAPHICS    =
*     IT_EXCEPT_QINFO_LVC               =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab           = it_employee
* EXCEPTIONS
*     PROGRAM_ERROR      = 1
*     OTHERS             = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.