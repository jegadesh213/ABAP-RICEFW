*&---------------------------------------------------------------------*
*& Report Z_ALVPROJECT_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_alvproject_01.

TYPE-POOLS : slis .

TABLES : zzempprac, zzempracdep, zemp_struct.

TYPES: BEGIN OF ty_emp,
         emplname  TYPE zzempprac-emplname,
         emplnum   TYPE zzempprac-emplnum,
         empdept   TYPE zzempprac-empdept,
         empsalary TYPE zzempprac-empsalary,
         units     TYPE zzempprac-units,
         doj       TYPE zzempracdep-doj,
         role      TYPE zzempracdep-role,
         box       TYPE c,
       END OF ty_emp.

DATA  : it_emp TYPE TABLE OF ty_emp,
        wa_emp TYPE ty_emp.

DATA  : it_fldcat TYPE slis_t_fieldcat_alv,
        wa_fldcat TYPE slis_fieldcat_alv.

DATA  : it_events TYPE slis_t_event,
        wa_events TYPE slis_alv_event.

DATA  : wa_layout TYPE slis_layout_alv.

SELECT-OPTIONS :
        s_num FOR zzempprac-emplnum,
        s_edept  FOR zzempprac-empdept.

START-OF-SELECTION.

  PERFORM fetch_data.
  PERFORM prepare_fldcat.
  PERFORM prepare_layout.
  PERFORM fill_events.
  PERFORM call_alv.
*&---------------------------------------------------------------------*
*&      Form  FETCH_DATA
*&---------------------------------------------------------------------*
FORM fetch_data .
  SELECT a~emplnum a~emplname a~empdept a~empsalary a~units b~doj b~role
  INTO CORRESPONDING FIELDS OF TABLE it_emp
  FROM zzempprac AS a
  LEFT JOIN zzempracdep AS b
  ON a~emplnum = b~emplnum
  WHERE a~emplnum IN s_num
  AND   a~empdept IN s_edept.

  IF sy-subrc NE 0.
    MESSAGE 'No data found' TYPE 'I'.
  ENDIF.

ENDFORM.                    " FETCH_DATA
*&---------------------------------------------------------------------*
*&      Form  PREPARE_FLDCAT
*&---------------------------------------------------------------------*
FORM prepare_fldcat .
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZEMP_STRUCT'
    CHANGING
      ct_fieldcat      = it_fldcat.

  IF sy-subrc = 0.
    wa_fldcat-edit = 'X'.
    MODIFY it_fldcat FROM wa_fldcat TRANSPORTING edit WHERE fieldname = 'ROLE'.
    MODIFY it_fldcat FROM wa_fldcat TRANSPORTING edit WHERE fieldname = 'EMPDEPT'.
  ENDIF.
ENDFORM.                    
*&---------------------------------------------------------------------*
*&      Form  CALL_ALV
*&---------------------------------------------------------------------*
FORM call_alv .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = wa_layout
      it_fieldcat        = it_fldcat
      it_events          = it_events
    TABLES
      t_outtab           = it_emp
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    " Implement suitable error handling here
  ENDIF.
ENDFORM.                
*&---------------------------------------------------------------------*
*&      Form  FILL_EVENTS
*&---------------------------------------------------------------------*
FORM fill_events .
  wa_events-name = 'PF_STATUS_SET'.
  wa_events-form = 'F_PF_STATUS_SET'.
  APPEND wa_events TO it_events.
  CLEAR wa_events.

  wa_events-name = 'USER_COMMAND'.
  wa_events-form = 'F_USER_COMMAND'.
  APPEND wa_events TO it_events.
ENDFORM.                    

FORM f_pf_status_set USING rt_extab TYPE slis_t_extab.

  SET PF-STATUS 'STANDARD' EXCLUDING rt_extab.
ENDFORM.                 


*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command USING r_ucomm TYPE sy-ucomm
                          rs_selfield TYPE slis_selfield.

  DATA : it_emp_buffer TYPE TABLE OF ty_emp,
         wa_emp_buffer TYPE ty_emp.

  CASE r_ucomm.
    WHEN 'SAVE'.
      LOOP AT it_emp INTO wa_emp.
        MOVE-CORRESPONDING wa_emp TO zemp_struct.
        
        INSERT zemp_struct.
      ENDLOOP.
      rs_selfield-refresh = 'X'.

    WHEN 'ADD'.
      " Example for adding new records
      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          popup_title = 'Enter Employee Details'
        TABLES
          fields      = it_emp_buffer.

      LOOP AT it_emp_buffer INTO wa_emp_buffer.
        
        MOVE-CORRESPONDING wa_emp_buffer TO zemp_struct.
        INSERT zemp_struct.
      ENDLOOP.

    WHEN 'DELETE'.
      LOOP AT it_emp INTO wa_emp WHERE box = 'X'.
        DELETE FROM zemp_struct WHERE emplnum = wa_emp-emplnum.
      ENDLOOP.
      DELETE it_emp WHERE box = 'X'.
      rs_selfield-refresh = 'X'.

  ENDCASE.
ENDFORM.                    "F_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  PREPARE_LAYOUT
*&---------------------------------------------------------------------*
FORM prepare_layout .
  wa_layout-box_fieldname = 'BOX'.
ENDFORM.                    " PREPARE_LAYOUT