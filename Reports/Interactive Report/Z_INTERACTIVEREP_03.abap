*&---------------------------------------------------------------------*
*& Report Z_INTERACTIVEREP_03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_interactiverep_03.

TABLES : zzempprac.

SELECT-OPTIONS : s_dept FOR zzempprac-empdept.

TYPES : BEGIN OF ty_employee,
          emplnum   TYPE zzempprac-emplnum,
          emplname  TYPE zzempprac-emplname,
          empdept   TYPE zzempprac-empdept,
          empsalary TYPE zzempprac-empsalary,
          units     TYPE zzempprac-units,
        END OF ty_employee.

DATA : it_employee TYPE TABLE OF ty_employee,
       wa_employee TYPE ty_employee.

data : fld(20) TYPE C,
       val(10) TYPE C.

SELECT * FROM zzempprac INTO TABLE it_employee WHERE empdept IN s_dept.

LOOP AT it_employee INTO wa_employee.
  WRITE : / wa_employee-emplnum , wa_employee-emplname , wa_employee-empdept , wa_employee-empsalary , wa_employee-units.
  HIDE : wa_employee-emplnum , wa_employee-emplname , wa_employee-empdept , wa_employee-empsalary , wa_employee-units.
ENDLOOP.

AT LINE-SELECTION.

  IF sy-lsind = 1.

    GET CURSOR FIELD fld VALUE val.

    IF fld = 'WA_EMPLOYEE-EMPLNUM'.

      SELECT * FROM zzempprac INTO TABLE it_employee WHERE empdept = wa_employee-empdept.

      LOOP AT it_employee INTO wa_employee.
        WRITE : / wa_employee-emplnum , wa_employee-emplname .
        HIDE : wa_employee-emplnum , wa_employee-emplname.
      ENDLOOP.

    ELSE.

      SELECT * FROM zzempprac INTO TABLE it_employee WHERE empdept = wa_employee-empdept.

      LOOP AT it_employee INTO wa_employee.
        WRITE : / wa_employee-emplnum , wa_employee-emplname , wa_employee-empdept , wa_employee-empsalary , wa_employee-units.
        HIDE : wa_employee-emplnum , wa_employee-emplname , wa_employee-empdept , wa_employee-empsalary , wa_employee-units.
      ENDLOOP.

    ENDIF.

  ENDIF.

  IF sy-lsind = 2.
    SELECT * FROM zzempprac INTO TABLE it_employee WHERE emplnum = wa_employee-emplnum.

    LOOP AT it_employee INTO wa_employee.
      WRITE : / wa_employee-emplnum , wa_employee-emplname , wa_employee-empdept , wa_employee-empsalary , wa_employee-units.
    ENDLOOP.

  ENDIF.

TOP-OF-PAGE DURING LINE-SELECTION.

  CASE sy-lsind.
    WHEN 1.
      WRITE : / 'LEVEL 1' COLOR 5.
    WHEN 2.
      WRITE : / 'LEVEL 2' COLOR 6.
    WHEN OTHERS.

  ENDCASE.