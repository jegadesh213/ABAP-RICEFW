*&---------------------------------------------------------------------*
*& Report Z_ALVGRID_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_alvgrid_01.

TABLES : zzempprac.

TYPE-POOLS : slis.

TYPES : BEGIN OF ty_employee,
          emplnum   TYPE zzempprac-emplnum,
          emplname  TYPE zzempprac-emplname,
          empdept   TYPE zzempprac-empdept,
          empsalary TYPE zzempprac-empsalary,
          units     TYPE zzempprac-units,
        END OF ty_employee.

DATA : it_employee TYPE TABLE OF ty_employee,
       wa_employee TYPE ty_employee,
       it_empalv   TYPE slis_t_fieldcat_alv,
       wa_empalv   TYPE slis_fieldcat_alv.

START-OF-SELECTION.

  PERFORM fetchdata.
  PERFORM showdata.

FORM fetchdata.
  SELECT * FROM zzempprac INTO TABLE it_employee.
ENDFORM.

FORM showdata.
  wa_empalv-fieldname = 'EMPLNUM'.
  wa_empalv-tabname = 'IT_EMPLOYEE'.
  wa_empalv-seltext_m = 'EMPLOYEE NUMBER'.
  APPEND wa_empalv TO it_empalv.

  wa_empalv-fieldname = 'EMPLNAME'.
  wa_empalv-tabname = 'IT_EMPLOYEE'.
  wa_empalv-seltext_m = 'EMPLOYEE NAME'.
  APPEND wa_empalv TO it_empalv.

  wa_empalv-fieldname = 'EMPDEPT'.
  wa_empalv-tabname = 'IT_EMPLOYEE'.
  wa_empalv-seltext_m = 'DEPARTMENT'.
  APPEND wa_empalv TO it_empalv.

  wa_empalv-fieldname = 'EMPSALARY'.
  wa_empalv-tabname = 'IT_EMPLOYEE'.
  wa_empalv-seltext_m = 'SALARY'.
  APPEND wa_empalv TO it_empalv.

  wa_empalv-fieldname = 'UNITS'.
  wa_empalv-tabname = 'IT_EMPLOYEE'.
  wa_empalv-seltext_m = 'UNITS'.
  APPEND wa_empalv TO it_empalv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat        = it_empalv
      i_callback_program = sy-repid
    TABLES
      t_outtab           = it_employee.

ENDFORM.