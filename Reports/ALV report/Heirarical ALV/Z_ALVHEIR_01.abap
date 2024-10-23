*&---------------------------------------------------------------------*
*& Report Z_ALVHEIR_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_alvheir_01.

TABLES : zzempprac , zzempracdep.

TYPES : BEGIN OF ty_employee,
          sel,
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

DATA : it_node TYPE TABLE OF snodetext,
       wa_node TYPE snodetext.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_enum FOR zzempprac-emplnum.

  PARAMETERS : p_role TYPE zzempracdep-role.
SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.

  PERFORM build_data.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*& Form display_tree
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_data .
  SELECT a~emplnum a~emplname a~empdept a~empsalary a~units
         b~doj b~role FROM zzempprac AS a INNER JOIN zzempracdep AS b
         ON a~emplnum = b~emplnum INTO CORRESPONDING FIELDS OF TABLE it_employee WHERE
         a~emplnum IN s_enum OR
         b~role = p_role.

  IF it_employee IS NOT INITIAL.

    SORT it_employee BY empdept emplnum.

    CLEAR wa_node.
    wa_node-tlevel  = 1.
    wa_node-name    = 'Department Employee Details'.
    wa_node-nlength = 40.
    wa_node-color   = 'C5'.
    APPEND wa_node TO it_node.

    LOOP AT it_employee INTO wa_employee.

      CLEAR wa_node.
      wa_node-tlevel = 2.
      wa_node-name = wa_employee-empdept.
      wa_node-nlength = 20.
      wa_node-color = 'C3'.
      wa_node-text1 = wa_employee-emplname.
      wa_node-tlength1 = 40.
      APPEND wa_node TO it_node.

      CLEAR wa_node.
      wa_node-tlevel = 3.
      wa_node-name = wa_employee-emplnum.
      wa_node-nlength = 10.
      wa_node-text1 = wa_employee-doj.
      wa_node-tlength1 = 10.
      wa_node-text2 = wa_employee-role.
      wa_node-tlength2 = 10.
      wa_node-text3 = wa_employee-empsalary.
      wa_node-tlength3 = 15.
      APPEND wa_node TO it_node.
    ENDLOOP.

    IF it_node IS NOT INITIAL.
      PERFORM display_tree.
    ENDIF.

  ENDIF.
ENDFORM.

FORM display_tree.

  CALL FUNCTION 'RS_TREE_CONSTRUCT'
* EXPORTING
*   INSERT_ID                = '000000'
*   RELATIONSHIP             = ' '
*   LOG                      =
    TABLES
      nodetab            = it_node
    EXCEPTIONS
      tree_failure       = 1
      id_not_found       = 2
      wrong_relationship = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'RS_TREE_LIST_DISPLAY'
    EXPORTING
      callback_program = sy-repid
    IMPORTING
      f15              = it_node.


ENDFORM.