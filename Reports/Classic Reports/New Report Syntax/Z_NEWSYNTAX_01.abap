*&---------------------------------------------------------------------*
*& Report Z_NEWSYNTAX_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_newsyntax_01.

TABLES : zzempprac , zzempracdep.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_num FOR zzempprac-emplnum.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM get_data.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  SELECT a~emplnum, a~emplname, a~empdept, a~empsalary, a~units, b~doj, b~role FROM zzempprac AS a INNER JOIN zzempracdep AS b
    ON a~emplnum = b~emplnum INTO TABLE @DATA(it_employee) WHERE a~emplnum IN @s_num.

  SORT it_employee BY emplnum.

  cl_demo_output=>display( it_employee ).

ENDFORM.