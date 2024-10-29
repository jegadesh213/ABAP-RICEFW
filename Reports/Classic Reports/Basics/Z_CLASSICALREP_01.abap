*&---------------------------------------------------------------------*
*& Report Z_CLASSICALREP_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_classicalrep_01.

TABLES : marc, mbew.

"type declaration
TYPES : BEGIN OF tp_marc,
          matnr TYPE matnr,
          werks TYPE marc-werks,
        END OF tp_marc,

        BEGIN OF tp_makt,
          matnr TYPE matnr,
          spras TYPE spras,
          maktx TYPE maktx,
        END OF tp_makt,

        BEGIN OF tp_mbew,
          matnr TYPE matnr,
          bwkey TYPE bwkey,
          lbkum TYPE lbkum,
          salk3 TYPE salk3,
        END OF tp_mbew,

        BEGIN OF tp_list,
          "from marc
          matnr TYPE matnr,
          werks TYPE marc-werks,
          "makt
          spras TYPE spras,
          maktx TYPE maktx,
          "mbew
          bwkey TYPE bwkey,
          lbkum TYPE lbkum,
          salk3 TYPE salk3,
        END OF tp_list.


"internal table and work area
DATA : gt_marc TYPE STANDARD TABLE OF tp_marc,
       gs_marc TYPE tp_marc,
       gt_makt TYPE STANDARD TABLE OF tp_makt,
       gs_makt TYPE tp_makt,
       gt_mbew TYPE STANDARD TABLE OF tp_mbew,
       gs_mbew TYPE tp_mbew,
       gt_list TYPE STANDARD TABLE OF tp_list,
       gs_list TYPE tp_list.



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_matnr FOR marc-matnr,
                   s_bwkey FOR mbew-bwkey OBLIGATORY.
  PARAMETERS : r_r1 RADIOBUTTON GROUP grp,  "different select quey
               r_r2 RADIOBUTTON GROUP grp.  "join

SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.
  PERFORM get_data.
  PERFORM display_data.


END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data.

  IF r_r1 IS NOT INITIAL.

    "select plant specific material
    SELECT matnr werks FROM marc INTO TABLE gt_marc
    WHERE matnr IN s_matnr
      AND werks IN s_bwkey.

    IF gt_marc[] IS NOT INITIAL.

      SELECT matnr spras maktx FROM makt INTO TABLE gt_makt
      FOR ALL ENTRIES IN gt_marc WHERE matnr = gt_marc-matnr.

      SELECT matnr bwkey lbkum salk3 FROM mbew INTO TABLE gt_mbew
      FOR ALL ENTRIES IN gt_marc WHERE matnr = gt_marc-matnr
                                   AND bwkey = gt_marc-werks.

    ENDIF.

  ELSE.

    SELECT marc~matnr marc~werks
           makt~spras makt~maktx
           mbew~bwkey mbew~lbkum mbew~salk3
           FROM marc AS marc INNER JOIN makt AS makt ON marc~matnr = makt~matnr
           INNER JOIN mbew AS mbew ON  marc~matnr = mbew~matnr
           INTO CORRESPONDING FIELDS OF TABLE gt_list
           WHERE marc~matnr IN s_matnr
             AND marc~werks IN s_bwkey
             AND mbew~bwkey IN s_bwkey.


  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_data .

  IF r_r1 IS NOT INITIAL.

    LOOP AT gt_marc INTO gs_marc.

      AT FIRST.
        WRITE:/2 'Material Code', 20 'Materal Description', 50 'Valuation Area', 70 'Total Stock', 90 'Value of the stock'.
        ULINE.
      ENDAT.

      CLEAR : gs_makt.
      READ TABLE gt_makt INTO gs_makt WITH KEY matnr = gs_marc-matnr.

      CLEAR : gs_mbew.
      READ TABLE gt_mbew INTO gs_mbew WITH KEY matnr = gs_marc-matnr
                                               bwkey = gs_marc-werks.

      WRITE:/2 gs_marc-matnr, 20 gs_makt-maktx, 50 gs_mbew-bwkey, 70 gs_mbew-lbkum, 90 gs_mbew-salk3.



      CLEAR : gs_marc, gs_makt, gs_mbew.
    ENDLOOP.

  ELSE.

    LOOP AT gt_list INTO gs_list.

      AT FIRST.
        WRITE:/2 'Material Code', 20 'Materal Description', 50 'Valuation Area', 70 'Total Stock', 90 'Value of the stock'.
        ULINE.
      ENDAT.

      WRITE:/2 gs_list-matnr, 20 gs_list-maktx, 50 gs_list-bwkey, 70 gs_list-lbkum, 90 gs_list-salk3.



      CLEAR : gs_list.
    ENDLOOP.


  ENDIF.


ENDFORM.