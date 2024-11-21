*&---------------------------------------------------------------------*
*& Report Z_OOALV_04
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_ooalv_04.

TABLES : zzempprac.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_num FOR zzempprac-emplnum.
SELECTION-SCREEN END OF BLOCK b1.

DATA : it_employee TYPE TABLE OF zzempprac,
       wa_employee TYPE zzempprac.

DATA : container TYPE REF TO cl_gui_custom_container,
       grid      TYPE REF TO cl_gui_alv_grid.

DATA : it_fldcat  TYPE lvc_t_fcat,
       wa_fldcat  TYPE lvc_s_fcat,
       it_toolbar TYPE TABLE OF stb_button,
       wa_toolbar TYPE stb_button.

DATA : P_num    TYPE char3,
       P_name   TYPE char30,
       P_dept   TYPE char3,
       P_salary TYPE char21,
       p_units  TYPE char5.


CLASS handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS : handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid IMPORTING e_object e_interactive,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid IMPORTING e_ucomm.
ENDCLASS.

CLASS handle_events IMPLEMENTATION.
  METHOD handle_toolbar.

    CLEAR wa_toolbar.
    wa_toolbar-function  = 'INSERT'.
    wa_toolbar-butn_type = 0.
    wa_toolbar-icon      = '@17@'.
    wa_toolbar-quickinfo = 'Insert'.
    APPEND wa_toolbar TO it_toolbar.

    CLEAR wa_toolbar.
    wa_toolbar-function  = 'DELETE'.
    wa_toolbar-butn_type = 0.
    wa_toolbar-icon      = '@18@'.
    wa_toolbar-quickinfo = 'Delete'.
    APPEND wa_toolbar TO it_toolbar.

    CLEAR wa_toolbar.
    wa_toolbar-function  = 'REFRESH'.
    wa_toolbar-butn_type = 0.
    wa_toolbar-icon      = '@42@'.
    wa_toolbar-quickinfo = 'Refresh'.
    APPEND wa_toolbar TO it_toolbar.

    APPEND LINES OF it_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.

  METHOD handle_user_command.

    CASE e_ucomm.
      WHEN 'INSERT'.
        CALL SCREEN 0300.
      WHEN 'DELETE'.
        PERFORM delete_data.
      WHEN 'REFRESH'.
        CALL METHOD grid->refresh_table_display.
    ENDCASE.

  ENDMETHOD.
ENDCLASS.

DATA : event_handler TYPE REF TO handle_events.

START-OF-SELECTION.
  PERFORM fetch_data.
  CALL SCREEN 0200.

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
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'PF-01'.
  SET TITLEBAR 'T-01'.

  CREATE OBJECT container
    EXPORTING
      container_name = 'CUSTOMCONTAINER'.

  CREATE OBJECT grid
    EXPORTING
      i_parent = container.

  CREATE OBJECT event_handler.

  SET HANDLER event_handler->handle_toolbar FOR grid.
  SET HANDLER event_handler->handle_user_command FOR grid.

  PERFORM display_data.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

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
*     I_BUFFER_ACTIVE  =
      i_structure_name = 'zzempprac'
*     I_CLIENT_NEVER_DISPLAY       = 'X'
*     I_BYPASSING_BUFFER =
*     i_internal_tabname = 'it_employee'
    CHANGING
      ct_fieldcat      = it_fldcat
*   EXCEPTIONS
*     INCONSISTENT_INTERFACE       = 1
*     PROGRAM_ERROR    = 2
*     OTHERS           = 3
    .

  CALL METHOD grid->set_table_for_first_display
*    EXPORTING
*      i_buffer_active               =
*      i_bypassing_buffer            =
*      i_consistency_check           =
*      i_structure_name              =
*      is_variant                    =
*      i_save                        =
*      i_default                     = 'X'
*      is_layout                     =
*      is_print                      =
*      it_special_groups             =
*      it_toolbar_excluding          =
*      it_hyperlink                  =
*      it_alv_graphics               =
*      it_except_qinfo               =
*      ir_salv_adapter               =
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
ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS 'PF-02'.
  SET TITLEBAR 'xxx'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      SET SCREEN 0.
    WHEN 'SAVE'.
      DATA : wa_employee02 TYPE zzempprac.

      wa_employee02-emplnum = P_num .
      wa_employee02-emplname = P_name.
      wa_employee02-empdept = P_dept.
      wa_employee02-empsalary = P_salary.
      wa_employee02-units = P_units.

      INSERT INTO zzempprac VALUES wa_employee02.

      IF sy-subrc = 0.
        MESSAGE 'Record added successfully' TYPE 'S'.
      ELSE.
        MESSAGE 'Failed to add record' TYPE 'E'.
      ENDIF.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Form delete_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_data .
  DATA: lt_rows     TYPE lvc_t_row,
        ls_row      TYPE lvc_s_row,
        lv_index    TYPE sy-tabix,
        wa_employee TYPE zzempprac.

  CALL METHOD grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_rows.

  IF lt_rows IS INITIAL.
    MESSAGE 'No row selected for deletion' TYPE 'E'.
    EXIT.
  ENDIF.

  READ TABLE lt_rows INTO ls_row INDEX 1.
  lv_index = ls_row-index.

  READ TABLE it_employee INTO wa_employee INDEX lv_index.

  IF sy-subrc = 0.
    DELETE FROM zzempprac WHERE emplnum = wa_employee-emplnum.

    IF sy-subrc = 0.
      MESSAGE 'Record deleted successfully' TYPE 'S'.
    ELSE.
      MESSAGE 'Failed to delete record' TYPE 'E'.
    ENDIF.

    DELETE it_employee INDEX lv_index.

  ELSE.
    MESSAGE 'Error reading selected row data' TYPE 'E'.
  ENDIF.

ENDFORM.