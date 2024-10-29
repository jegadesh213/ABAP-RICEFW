*&---------------------------------------------------------------------*
*& Report Z_EVENTSPRAC_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_eventsprac_01.

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

*Block Screen declaration
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS : p_num TYPE zzempprac-emplnum.
SELECTION-SCREEN END OF BLOCK b1.

*Initializing the default values on selection screen
INITIALIZATION.

  p_num = '1'.

*used triggered before the selection screen is displayed on the screen and after the INITIALIZATION
*AT SELECTION-SCREEN OUTPUT.

*  LOOP AT SCREEN.
*    IF p_num IS NOT INITIAL.
*      screen-input = 0.
*      MODIFY SCREEN.
*    ENDIF.
*  ENDLOOP.

* It is triggered when the value in the specific field is said to be executed
AT SELECTION-SCREEN ON p_num.

  IF p_num > 10.
    MESSAGE 'Employee Number Higher than 10 is not contain in the zzempprac Table ' TYPE 'E'.
  ENDIF.

*It is used to set the condition before the user executes the selection they had made in selection screen
AT SELECTION-SCREEN.

  IF p_num = '0'.
    MESSAGE 'Please Enter the Valid number from 1 to 10' TYPE 'S'.
  ENDIF.

*Start of selection used for main processing units
START-OF-SELECTION.

  SELECT a~emplnum a~emplname a~empdept a~empsalary a~units b~doj b~role FROM zzempprac AS a INNER JOIN zzempracdep AS b
    ON a~emplnum = b~emplnum
    INTO CORRESPONDING FIELDS OF TABLE it_employee WHERE a~emplnum = p_num.

*End of selection used for display the process in the output windows of the report
END-OF-SELECTION.

  LOOP AT it_employee INTO wa_employee.
    WRITE : / 'Number : ' , wa_employee-emplnum ,
          / 'Name : ' , wa_employee-emplname ,
          / 'Dept : ' , wa_employee-empdept ,
          / 'Salary : ' , wa_employee-empsalary ,
          / 'Units : ' , wa_employee-units ,
          / 'DOJ : ' , wa_employee-doj ,
          / 'Role : ' , wa_employee-role .
  ENDLOOP.

AT LINE-SELECTION.

  WRITE : 'You are selected the line ', sy-lisel.

TOP-OF-PAGE.

  WRITE : 'Employee Details - ZZEMPPRAC Table'.
  ULINE.