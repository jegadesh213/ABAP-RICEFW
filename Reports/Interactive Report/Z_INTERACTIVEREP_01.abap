*&---------------------------------------------------------------------*
*& Report Z_INTERACTIVEREP_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_interactiverep_01.

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

SELECT * FROM zzempprac INTO TABLE it_employee WHERE empdept IN s_dept.

LOOP AT it_employee INTO wa_employee.
  WRITE : / wa_employee-emplnum , wa_employee-emplname , wa_employee-empdept , wa_employee-empsalary , wa_employee-units.
  HIDE : wa_employee-emplnum , wa_employee-emplname , wa_employee-empdept , wa_employee-empsalary , wa_employee-units.
ENDLOOP.

at LINE-SELECTION.

  SELECT * FROM zzempprac INTO TABLE it_employee WHERE emplnum = wa_employee-emplnum.

  LOOP AT it_employee INTO wa_employee.
    WRITE : / wa_employee-emplnum , wa_employee-emplname , wa_employee-empdept , wa_employee-empsalary , wa_employee-units.
  ENDLOOP.