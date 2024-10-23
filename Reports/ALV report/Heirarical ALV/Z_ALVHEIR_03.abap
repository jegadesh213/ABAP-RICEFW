*&---------------------------------------------------------------------*
*& Report Z_ALVHEIR_03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_alvheir_03.

TABLES: zzempprac, zzempracdep.

DATA: gt_fcat   TYPE slis_t_fieldcat_alv,
      gs_fcat   TYPE slis_fieldcat_alv,

      gt_fcat1  TYPE slis_t_fieldcat_alv,
      gs_fcat1  TYPE slis_fieldcat_alv,

      gt_fcat2  TYPE slis_t_fieldcat_alv,
      gs_fcat2  TYPE slis_fieldcat_alv,

      gt_events TYPE slis_t_event,
      gs_layout TYPE slis_layout_alv,
      hdr_cnt   TYPE i,
      itm_cnt   TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_empnum FOR zzempprac-emplnum,
                  s_empdep FOR zzempprac-empdept.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM get_employee_data.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form get_employee_data
*&---------------------------------------------------------------------*
FORM get_employee_data.

  " Employee master data
  SELECT emplnum, emplname, empdept, empsalary, units
    FROM zzempprac
    INTO TABLE @DATA(gt_empprac)
    WHERE emplnum IN @s_empnum
  AND empdept IN @s_empdep.

  IF gt_empprac[] IS NOT INITIAL.

    SORT gt_empprac BY emplnum.

    " Department details
    SELECT emplnum, doj, role
      FROM zzempracdep
      INTO TABLE @DATA(gt_emppracdep)
      FOR ALL ENTRIES IN @gt_empprac
    WHERE emplnum = @gt_empprac-emplnum.

    SORT gt_emppracdep BY emplnum.

    " Build field catalog for employee data
    CLEAR: gt_fcat[], gs_fcat, hdr_cnt.

    hdr_cnt = hdr_cnt + 1.
    gs_fcat-col_pos = hdr_cnt.
    gs_fcat-fieldname = 'EMPLNUM'.
    gs_fcat-tabname = 'GT_EMPPRAC'.
    gs_fcat-seltext_l = 'Employee Number'.
    APPEND gs_fcat TO gt_fcat.
    CLEAR gs_fcat.

    hdr_cnt = hdr_cnt + 1.
    gs_fcat-col_pos = hdr_cnt.
    gs_fcat-fieldname = 'EMPLNAME'.
    gs_fcat-tabname = 'GT_EMPPRAC'.
    gs_fcat-seltext_l = 'Employee Name'.
    APPEND gs_fcat TO gt_fcat.
    CLEAR gs_fcat.

    hdr_cnt = hdr_cnt + 1.
    gs_fcat-col_pos = hdr_cnt.
    gs_fcat-fieldname = 'EMPDEPT'.
    gs_fcat-tabname = 'GT_EMPPRAC'.
    gs_fcat-seltext_l = 'Department'.
    APPEND gs_fcat TO gt_fcat.
    CLEAR gs_fcat.

    hdr_cnt = hdr_cnt + 1.
    gs_fcat-col_pos = hdr_cnt.
    gs_fcat-fieldname = 'EMPSALARY'.
    gs_fcat-tabname = 'GT_EMPPRAC'.
    gs_fcat-seltext_l = 'Salary'.
    APPEND gs_fcat TO gt_fcat.
    CLEAR gs_fcat.

    hdr_cnt = hdr_cnt + 1.
    gs_fcat-col_pos = hdr_cnt.
    gs_fcat-fieldname = 'UNITS'.
    gs_fcat-tabname = 'GT_EMPPRAC'.
    gs_fcat-seltext_l = 'Units Worked'.
    APPEND gs_fcat TO gt_fcat.
    CLEAR gs_fcat.

    " Build field catalog for department data
    itm_cnt = itm_cnt + 1.
    gs_fcat1-col_pos = itm_cnt.
    gs_fcat1-fieldname = 'EMPLNUM'.
    gs_fcat1-tabname = 'GT_EMPPRACDEP'.
    gs_fcat1-seltext_l = 'Employee Number'.
    APPEND gs_fcat1 TO gt_fcat1.
    CLEAR gs_fcat1.

    itm_cnt = itm_cnt + 1.
    gs_fcat1-col_pos = itm_cnt.
    gs_fcat1-fieldname = 'DOJ'.
    gs_fcat1-tabname = 'GT_EMPPRACDEP'.
    gs_fcat1-seltext_l = 'Date of Joining'.
    APPEND gs_fcat1 TO gt_fcat1.
    CLEAR gs_fcat1.

    itm_cnt = itm_cnt + 1.
    gs_fcat1-col_pos = itm_cnt.
    gs_fcat1-fieldname = 'ROLE'.
    gs_fcat1-tabname = 'GT_EMPPRACDEP'.
    gs_fcat1-seltext_l = 'Role'.
    APPEND gs_fcat1 TO gt_fcat1.
    CLEAR gs_fcat1.

    " Display ALV for Employee Data
    CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_INIT'
      EXPORTING
        i_callback_program = sy-repid.

    CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
      EXPORTING
        is_layout   = gs_layout
        it_fieldcat = gt_fcat
        i_tabname   = 'GT_EMPPRAC'
      TABLES
        t_outtab    = gt_empprac.

    CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
      EXPORTING
        is_layout   = gs_layout
        it_fieldcat = gt_fcat1
        i_tabname   = 'GT_EMPPRACDEP'
      TABLES
        t_outtab    = gt_emppracdep.

    CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_DISPLAY'.

  ELSE.
    MESSAGE 'No record found' TYPE 'I'.
  ENDIF.

ENDFORM.