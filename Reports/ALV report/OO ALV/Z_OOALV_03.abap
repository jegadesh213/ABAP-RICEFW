*&---------------------------------------------------------------------*
*& Report Z_OOALV_03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_ooalv_03.

TABLES : zzempprac.

DATA : it_employee TYPE TABLE OF zzempprac,
       wa_employee TYPE zzempprac.

DATA : container TYPE REF TO cl_gui_custom_container,
       grid      TYPE REF TO cl_gui_alv_grid.

DATA : it_fldcat  TYPE lvc_t_fcat,
       wa_fldcat  LIKE lvc_s_fcat,
       it_layout  TYPE lvc_s_layo,
       wa_variant TYPE disvariant,
       it_toolbar TYPE STANDARD TABLE OF stb_button,
       wa_toolbar TYPE stb_button.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_num FOR zzempprac-emplnum.
SELECTION-SCREEN END OF BLOCK b1.

CLASS handle_event DEFINITION.
  PUBLIC SECTION.
    METHODS : handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid IMPORTING e_object e_interactive,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid IMPORTING e_ucomm.
ENDCLASS.

CLASS handle_event IMPLEMENTATION.
  METHOD handle_toolbar.

    LOOP AT e_object->mt_toolbar INTO wa_toolbar.
      APPEND wa_toolbar TO it_toolbar.
    ENDLOOP.

    wa_toolbar-butn_type = 1.
    wa_toolbar-function = 'CUSTOM'.
    wa_toolbar-icon = '@5Q@'.
    wa_toolbar-quickinfo = 'Custom'.
    wa_toolbar-disabled = ''.
    APPEND wa_toolbar TO it_toolbar.

    e_object->mt_toolbar = it_toolbar.


  ENDMETHOD.

  METHOD handle_user_command.

    CASE e_ucomm.
      WHEN 'CUSTOM'.
        MESSAGE 'Custom Button Triggered' TYPE 'I'.
    ENDCASE.

  ENDMETHOD.

ENDCLASS.

DATA : event_handler TYPE REF TO handle_event.

START-OF-SELECTION.
  PERFORM fetch_data.
  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data .
  SELECT * FROM zzempprac INTO CORRESPONDING FIELDS OF TABLE it_employee WHERE emplnum IN s_num.
ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF-01'.
  SET TITLEBAR 'T-01'.

  CREATE OBJECT container
    EXPORTING
      container_name = 'CONTAINER01'.

  CREATE OBJECT grid
    EXPORTING
      i_parent = container.

  CREATE OBJECT event_handler.
*
  SET HANDLER event_handler->handle_toolbar FOR grid.
  SET HANDLER event_handler->handle_user_command FOR grid.

  PERFORM display_data.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 0.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
*     I_BUFFER_ACTIVE        =
      i_structure_name       = 'zzempprac'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_BYPASSING_BUFFER     =
*     i_internal_tabname     = 'it_employee'
    CHANGING
      ct_fieldcat            = it_fldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT it_fldcat INTO wa_fldcat WHERE fieldname = 'EMPLNUM'.
    wa_fldcat-emphasize = 'A6'.
    MODIFY it_fldcat FROM wa_fldcat TRANSPORTING emphasize.
  ENDLOOP.

  LOOP AT it_fldcat INTO wa_fldcat.
    CASE wa_fldcat-fieldname.
      WHEN 'EMPLNUM'.
        wa_fldcat-scrtext_l = 'NUMBER'.
        wa_fldcat-scrtext_m = 'NUMBER'.
        wa_fldcat-scrtext_s = 'NUMBER'.
      WHEN 'EMPLNAME'.
        wa_fldcat-scrtext_l = 'NAME'.
        wa_fldcat-scrtext_m = 'NAME'.
        wa_fldcat-scrtext_s = 'NAME'.
      WHEN 'DEPT'.
        wa_fldcat-scrtext_l = 'DEPT'.
        wa_fldcat-scrtext_m = 'DEPT'.
        wa_fldcat-scrtext_s = 'DEPT'.
      WHEN 'SALARY'.
        wa_fldcat-scrtext_l = 'SALARY'.
        wa_fldcat-scrtext_m = 'SALARY'.
        wa_fldcat-scrtext_s = 'SALARY'.
      WHEN 'UNITS'.
        wa_fldcat-scrtext_l = 'UNITS'.
        wa_fldcat-scrtext_m = 'UNITS'.
        wa_fldcat-scrtext_s = 'UNITS'.
    ENDCASE.
    MODIFY it_fldcat FROM wa_fldcat.
  ENDLOOP.

  it_layout-col_opt  = 'X'.

  CALL METHOD grid->set_table_for_first_display
    EXPORTING
*     i_buffer_active =
*     i_bypassing_buffer            =
*     i_consistency_check           =
*     i_structure_name              =
      is_variant      = wa_variant
      i_save          = 'X'
      i_default       = 'X'
      is_layout       = it_layout
*     is_print        =
*     it_special_groups             =
*     it_toolbar_excluding          =
*     it_hyperlink    =
*     it_alv_graphics =
*     it_except_qinfo =
*     ir_salv_adapter =
    CHANGING
      it_outtab       = it_employee
      it_fieldcatalog = it_fldcat
*     it_sort         =
*     it_filter       =
*    EXCEPTIONS
*     invalid_parameter_combination = 1
*     program_error   = 2
*     too_many_lines  = 3
*     others          = 4
    .
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.


ENDFORM.