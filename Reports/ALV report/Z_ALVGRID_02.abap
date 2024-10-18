*&---------------------------------------------------------------------*
*& Report Z_ALVGRID_02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_alvgrid_02.

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
       wa_empalv   TYPE slis_fieldcat_alv,
       it_sortalv  TYPE slis_t_sortinfo_alv,
       wa_sortalv  TYPE slis_sortinfo_alv,
       it_events   TYPE slis_t_event,
       wa_events   TYPE slis_alv_event.

START-OF-SELECTION.

  PERFORM fetchdata.
  PERFORM field_declaration.
  PERFORM fill_events.
  PERFORM showdata.


FORM fetchdata.
  SELECT * FROM zzempprac INTO TABLE it_employee.
ENDFORM.

FORM showdata.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     i_interface_check                 = ' '
*     i_bypassing_buffer                = ' '
*     i_buffer_active                   = ' '
     i_callback_program                = sy-repid
*     i_callback_pf_status_set          = ' '
*     i_callback_user_command           = ' '
     i_callback_top_of_page            = 'F_TOP_OF_PAGE'
*     i_callback_html_top_of_page       = 'F_TOP_OF_PAGE'
*     i_callback_html_end_of_list       = ' '
*     i_structure_name                  =
*     i_background_id                   = ' '
*     i_grid_title                      =
*     i_grid_settings                   =
*     is_layout                         =
     it_fieldcat                       = it_empalv
*     it_excluding                      =
*     it_special_groups                 =
     it_sort                           = it_sortalv
*     it_filter                         =
*     is_sel_hide                       =
*     i_default                         = 'X'
*     i_save                            = ' '
*     is_variant                        =
*     it_events                         =
*     it_event_exit                     =
*     is_print                          =
*     is_reprep_id                      =
*     i_screen_start_column             = 0
*     i_screen_start_line               = 0
*     i_screen_end_column               = 0
*     i_screen_end_line                 = 0
*     i_html_height_top                 = 0
*     i_html_height_end                 = 0
*     it_alv_graphics                   =
*     it_hyperlink                      =
*     it_add_fieldcat                   =
*     it_except_qinfo                   =
*     ir_salv_fullscreen_adapter        =
*     o_previous_sral_handler           =
*   IMPORTING
*     e_exit_caused_by_caller           =
*     es_exit_caused_by_user            =
    TABLES
      t_outtab                          = it_employee
   EXCEPTIONS
     program_error                     = 1
     OTHERS                            = 2
            .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
**  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
**    EXPORTING
**      it_fieldcat        = it_empalv
**      i_callback_program = sy-repid
**      it_sort            = it_sortalv
**    TABLES
**      t_outtab           = it_employee.

ENDFORM.

FORM field_declaration.
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

ENDFORM.

FORM fill_events.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    IMPORTING
      et_events = it_events.
  IF sy-subrc = 0.
    READ TABLE it_events INTO wa_events WITH KEY name = 'TOP_OF_PAGE'.
    IF sy-subrc = 0.
      wa_events-form = 'f_top_of_page'.
      MODIFY it_events FROM wa_events INDEX sy-tabix.
    ENDIF.
  ENDIF.
ENDFORM.

FORM F_TOP_OF_PAGE.

  DATA : it_lheader TYPE slis_t_listheader,
         wa_lheader TYPE slis_listheader.

  wa_lheader-typ  = 'H'.
  wa_lheader-info = 'EMPLOYEE TABLE ALV GRID VIEW'.
  APPEND wa_lheader TO it_lheader.

  wa_lheader-typ  = 'A'.
  wa_lheader-info = sy-datum.
  APPEND wa_lheader TO it_lheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_lheader
      i_logo             = 'AALOGO'.

ENDFORM.