*&---------------------------------------------------------------------*
*& Report Z_MATERIALS_BY_USER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_materials_by_user_.

TABLES : mara,usr02.

SELECT-OPTIONS : s_matnr FOR mara-matnr,
                 s_ersda FOR mara-ersda,
                 s_ernam FOR mara-ernam MODIF ID crb.

PARAMETERS :  p_crtd AS CHECKBOX.

TYPES : BEGIN OF ty_mara,
          matnr TYPE matnr,
          ernam TYPE ernam,
          ersda TYPE ersda,
        END OF ty_mara.

DATA : it_mara TYPE TABLE OF ty_mara,
       wa_mara TYPE ty_mara.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT  SCREEN.
    IF p_crtd IS NOT INITIAL.
      IF screen-group1 = 'CRB'.
        s_ernam-sign = 'I'.
        s_ernam-option = 'EQ'.
        s_ernam-low = sy-uname.

        APPEND s_ernam.

        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

  ENDLOOP.

AT SELECTION-SCREEN.

  if s_ernam is Not INITIAL.
    SELECT SINGLE * FROM usr02 WHERE bname IN s_ernam.
    if sy-subrc <> 0.
        MESSAGE 'USER NOT FOUND' TYPE 'E'.
    ENDIF.
  ENDIF.

START-OF-SELECTION.

SELECT matnr ernam ersda FROM mara INTO TABLE it_mara WHERE matnr IN s_matnr AND ernam IN s_ernam.

LOOP AT it_mara INTO wa_mara.
  Write :/ wa_mara-matnr , wa_mara-ernam, wa_mara-ersda.
ENDLOOP.