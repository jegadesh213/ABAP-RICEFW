*&---------------------------------------------------------------------*
*& Report Z_ALVHEIR_02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_alvheir_02.

* Define Tables
TABLES : zzempprac, zzempracdep.

* Define Types for Header (Roles) and Item (Employees)
TYPES : BEGIN OF ty_header,           " Header structure (Role-based)
          role TYPE zzempracdep-role,
          doj  TYPE zzempracdep-doj,
        END OF ty_header.

TYPES : BEGIN OF ty_item,             " Item structure (Employee data)
          emplnum   TYPE zzempprac-emplnum,
          emplname  TYPE zzempprac-emplname,
          empdept   TYPE zzempprac-empdept,
          empsalary TYPE zzempprac-empsalary,
          units     TYPE zzempprac-units,
          role      TYPE zzempprac-empdept,  " Relating role to employee
        END OF ty_item.

* Internal tables for header and item
DATA : it_header TYPE TABLE OF ty_header,
       wa_header TYPE ty_header.

DATA : it_item TYPE TABLE OF ty_item,
       wa_item TYPE ty_item.

* Field catalog and ALV variables
DATA : it_fldcat  TYPE slis_t_fieldcat_alv,
       wa_fldcat  TYPE slis_fieldcat_alv,
       wa_keyinfo TYPE slis_keyinfo_alv,
       wa_layout  TYPE slis_layout_alv,
       hdr_cnt    TYPE i,
       item_cnt   TYPE i.

* Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_enum FOR zzempprac-emplnum.
  PARAMETERS : p_role TYPE zzempracdep-role.
SELECTION-SCREEN END OF BLOCK b1.

* Start of selection
START-OF-SELECTION.
  PERFORM build_data.

* End of selection
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form build_data
*&---------------------------------------------------------------------*
FORM build_data.

  " Step 1: Select data for the header (distinct roles)
  SELECT DISTINCT role, doj
    INTO TABLE @it_header
    FROM zzempracdep
    WHERE role = @p_role.

  " Step 2: Select data for the item (employee details)
  SELECT emplnum, emplname, empdept, empsalary, units, empdept
    INTO TABLE @it_item
    FROM zzempprac
    WHERE emplnum IN @s_enum.

  IF it_header IS NOT INITIAL AND it_item IS NOT INITIAL.

    " Sort item data by role
    SORT it_item BY empdept.

    " Initialize field catalog
    CLEAR : it_fldcat, wa_fldcat, wa_keyinfo, wa_layout, hdr_cnt, item_cnt.

    " Header Field Catalog (Role-based display)
    hdr_cnt = hdr_cnt + 1.
    wa_fldcat-col_pos = hdr_cnt.
    wa_fldcat-fieldname = 'ROLE'.
    wa_fldcat-tabname = 'TY_HEADER'.
    wa_fldcat-seltext_l = 'Role'.
    APPEND wa_fldcat TO it_fldcat.
    CLEAR wa_fldcat.

    hdr_cnt = hdr_cnt + 1.
    wa_fldcat-col_pos = hdr_cnt.
    wa_fldcat-fieldname = 'DOJ'.
    wa_fldcat-tabname = 'TY_HEADER'.
    wa_fldcat-seltext_l = 'Date of Joining'.
    APPEND wa_fldcat TO it_fldcat.
    CLEAR wa_fldcat.

    " Item Field Catalog (Employee-based display)
    item_cnt = item_cnt + 1.
    wa_fldcat-col_pos = item_cnt.
    wa_fldcat-fieldname = 'EMPLNUM'.
    wa_fldcat-tabname = 'TY_ITEM'.
    wa_fldcat-seltext_l = 'Employee Number'.
    APPEND wa_fldcat TO it_fldcat.
    CLEAR wa_fldcat.

    item_cnt = item_cnt + 1.
    wa_fldcat-col_pos = item_cnt.
    wa_fldcat-fieldname = 'EMPLNAME'.
    wa_fldcat-tabname = 'TY_ITEM'.
    wa_fldcat-seltext_l = 'Employee Name'.
    APPEND wa_fldcat TO it_fldcat.
    CLEAR wa_fldcat.

    item_cnt = item_cnt + 1.
    wa_fldcat-col_pos = item_cnt.
    wa_fldcat-fieldname = 'EMPDEPT'.
    wa_fldcat-tabname = 'TY_ITEM'.
    wa_fldcat-seltext_l = 'Department'.
    APPEND wa_fldcat TO it_fldcat.
    CLEAR wa_fldcat.

    item_cnt = item_cnt + 1.
    wa_fldcat-col_pos = item_cnt.
    wa_fldcat-fieldname = 'EMPSALARY'.
    wa_fldcat-tabname = 'TY_ITEM'.
    wa_fldcat-seltext_l = 'Salary'.
    APPEND wa_fldcat TO it_fldcat.
    CLEAR wa_fldcat.

    item_cnt = item_cnt + 1.
    wa_fldcat-col_pos = item_cnt.
    wa_fldcat-fieldname = 'UNITS'.
    wa_fldcat-tabname = 'TY_ITEM'.
    wa_fldcat-seltext_l = 'Units Worked'.
    APPEND wa_fldcat TO it_fldcat.
    CLEAR wa_fldcat.

    " Key information for hierarchical display
    wa_keyinfo-header01 = 'ROLE'.
    wa_keyinfo-item01 = 'ROLE'.  " Key field to link header to item

    " Layout settings
    wa_layout-colwidth_optimize = 'X'.
    wa_layout-expand_fieldname  = 'EXPAND'.
    wa_layout-expand_all        = 'X'.

    " ALV Hierarchical Display
    CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        is_layout          = wa_layout
        it_fieldcat        = it_fldcat
        i_default          = 'X'
        i_save             = 'A'
        i_tabname_header   = 'TY_HEADER'     " Structure name for header
        i_tabname_item     = 'TY_ITEM'       " Structure name for item
        is_keyinfo         = wa_keyinfo
      TABLES
        t_outtab_header    = it_header       " Header table with role data
        t_outtab_item      = it_item         " Item table with employee data
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.

  ELSE.
    MESSAGE 'No records found' TYPE 'I'.
    SET SCREEN 0.
  ENDIF.

ENDFORM.