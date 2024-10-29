*&---------------------------------------------------------------------*
*& Report Z_CLASSICALREPORT_02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_classicalreport_02.

TABLES : zzempprac , zzempracdep.

TYPES : BEGIN OF ty_employee,
          emplnum   TYPE zzempprac-emplnum,
          emplname  TYPE zzempprac-emplname,
          empdept   TYPE zzempprac-empdept,
          empsalary TYPE zzempprac-empsalary,
          units     TYPE zzempprac-units,
          doj       TYPE zzempracdep-doj,
          role      TYPE zzempracdep-role,
        END OF ty_employee.

DATA : it_employee TYPE TABLE OF ty_employee,
       wa_employee TYPE ty_employee.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_num FOR zzempprac-emplnum,
                    s_doj FOR zzempracdep-doj.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM display_data.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  SELECT a~emplnum a~emplname a~empdept a~empsalary a~units b~doj b~role
    FROM zzempprac AS a INNER JOIN zzempracdep AS b ON a~emplnum = b~emplnum INTO CORRESPONDING FIELDS OF TABLE it_employee
    WHERE a~emplnum IN s_num
    AND b~doj IN s_doj.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

  SORT it_employee BY emplnum.

  WRITE : 'NUMBER' , 10 'NAME', 30 'DEPT',60 'SALARY',90 'UNITS',120 'DOJ',160 'ROLE'.
  ULINE.

  LOOP AT it_employee INTO wa_employee.
    WRITE : / wa_employee-emplnum , 10 wa_employee-emplname , 30 wa_employee-empdept ,60 wa_employee-empsalary LEFT-JUSTIFIED ,90 wa_employee-units,
              120 wa_employee-doj,160 wa_employee-role.
  ENDLOOP.

ENDFORM.