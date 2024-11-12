*&---------------------------------------------------------------------*
*& Report Z_OOALV_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_ooalv_02.

TABLES : zzempprac , zzempracdep.

DATA : it_employee TYPE TABLE OF zzempprac,
       wa_employee TYPE zzempprac.

DATA : it_fldcat  TYPE lvc_t_fcat,
       wa_fldcat  LIKE LINE OF it_fldcat,
       it_layout  TYPE lvc_s_layo,
       wa_variant TYPE disvariant.

DATA : custom TYPE REF TO cl_gui_custom_container,
       grid   TYPE REF TO cl_gui_alv_grid.

SELECT-OPTIONS : s_num FOR zzempprac-emplnum.

CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS: on_user_command FOR EVENT user_command OF cl_gui_alv_grid IMPORTING e_ucomm,
      on_double_click FOR EVENT double_click OF cl_gui_alv_grid.
ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD on_user_command.
    CASE e_ucomm.
      WHEN 'EXIT' OR 'CANCEL' OR 'BACK'.
        LEAVE PROGRAM.
    ENDCASE.
  ENDMETHOD.

  METHOD on_double_click.
    MESSAGE 'Double Click Detected!' TYPE 'I'.
  ENDMETHOD.
ENDCLASS.

DATA : event_reciever TYPE REF TO lcl_event_receiver.

START-OF-SELECTION.

  PERFORM fetch_data.

  CALL SCREEN 0100.

*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        texta
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data .

  SELECT * FROM zzempprac INTO CORRESPONDING FIELDS OF TABLE it_employee WHERE emplnum IN s_num.
  SORT it_employee BY emplnum.

ENDFORM.


*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF1'.
  SET TITLEBAR 'T1'.

  IF custom IS INITIAL.

    CREATE OBJECT custom
      EXPORTING
        container_name = 'ZCONTAINER'.

    CREATE OBJECT grid
      EXPORTING
        i_parent = custom.

    PERFORM display_data.


    CREATE OBJECT event_reciever.
    SET HANDLER event_reciever->on_user_command FOR grid.
    SET HANDLER event_reciever->on_double_click FOR grid.


  ENDIF.
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
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.

  SET SCREEN 0.

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
      i_internal_tabname     = 'it_employee'
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
    wa_fldcat-emphasize = 'C5'.
    MODIFY it_fldcat FROM wa_fldcat TRANSPORTING emphasize.
  ENDLOOP.

  it_layout-col_opt  = 'X'.

  CALL METHOD grid->set_table_for_first_display
    EXPORTING
*     i_buffer_active               =
*     i_bypassing_buffer            =
*     i_consistency_check           =
*     i_structure_name              =
      is_variant                    = wa_variant
      i_save                        = 'A'
      i_default                     = 'X'
      is_layout                     = it_layout
*     is_print                      =
*     it_special_groups             =
*     it_toolbar_excluding          =
*     it_hyperlink                  =
*     it_alv_graphics               =
*     it_except_qinfo               =
*     ir_salv_adapter               =
    CHANGING
      it_outtab                     = it_employee
      it_fieldcatalog               = it_fldcat
*     it_sort                       =
*     it_filter                     =
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.



ENDFORM.