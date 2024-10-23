*&---------------------------------------------------------------------*
*& Report Z_ALVPRAC_05
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_alvprac_05.

TABLES: sflight.

TYPES: BEGIN OF ty_sflight,
         carrid TYPE sflight-carrid,
         connid TYPE sflight-connid,
         fldate TYPE sflight-fldate,
         price  TYPE sflight-price,
       END OF ty_sflight.

DATA: gt_sflight TYPE TABLE OF ty_sflight,
      gs_sflight TYPE ty_sflight.

DATA: gt_fcat TYPE lvc_t_fcat,
      gs_fcat LIKE LINE OF gt_fcat.

DATA: gs_layout  TYPE lvc_s_layo,
      gv_save_ok TYPE c LENGTH 1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_carrid TYPE sflight-carrid.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.

START-OF-SELECTION.
  SELECT carrid connid fldate price
    INTO TABLE gt_sflight
    FROM sflight
    WHERE carrid = p_carrid.

  IF sy-subrc = 0.
    PERFORM build_fieldcat.
    PERFORM display_alv.
  ELSE.
    WRITE: / 'No data found for the given carrier ID'.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  build_fieldcat
*&---------------------------------------------------------------------*
FORM build_fieldcat.
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'CARRID'.
  gs_fcat-coltext = 'Carrier ID'.
  gs_fcat-edit = ' '.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'CONNID'.
  gs_fcat-coltext = 'Connection ID'.
  gs_fcat-edit = ' '.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'FLDATE'.
  gs_fcat-coltext = 'Flight Date'.
  gs_fcat-edit = ' '.
  APPEND gs_fcat TO gt_fcat.

  CLEAR gs_fcat.
  gs_fcat-fieldname = 'PRICE'.
  gs_fcat-coltext = 'Price'.
  gs_fcat-edit = 'X'.  " Make Price field editable
  APPEND gs_fcat TO gt_fcat.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  display_alv
*&---------------------------------------------------------------------*
FORM display_alv.
  gs_layout-edit = 'X'.  " Enable editing in ALV

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program      = sy-repid
      is_layout_lvc           = gs_layout
      it_fieldcat_lvc         = gt_fcat
      i_save                  = 'A'   " Enable save functionality
      i_callback_user_command = 'USER_COMMAND'
    TABLES
      t_outtab                = gt_sflight
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN 'SAVE'.
      " Logic to update the database
      LOOP AT gt_sflight INTO gs_sflight.
        UPDATE sflight SET price = gs_sflight-price
          WHERE carrid = gs_sflight-carrid
          AND connid = gs_sflight-connid
          AND fldate = gs_sflight-fldate.
        IF sy-subrc = 0.
          WRITE: / 'Data updated successfully for ', gs_sflight-carrid, gs_sflight-connid.
        ELSE.
          WRITE: / 'Error updating data for ', gs_sflight-carrid, gs_sflight-connid.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDFORM.