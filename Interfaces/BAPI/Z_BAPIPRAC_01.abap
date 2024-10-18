*&---------------------------------------------------------------------*
*& Report Z_BAPIPRAC_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_bapiprac_01.


TYPES : BEGIN OF tp_itab,
          order_type(4),
          sorg(4),
          dch(2),
          div(2),
          kunnr         TYPE kunnr,
          matnr         TYPE matnr,
          qty(15),
          uom(4),
          wbs(24),
          plant(4),
          stloc(4),
          price(15),
        END OF tp_itab.

DATA : gt_itab  TYPE STANDARD TABLE OF tp_itab,
       gs_itab  TYPE tp_itab,
       gs_itab1 TYPE tp_itab.


DATA : order_header_in      LIKE bapisdhd1,
       order_header_inx	    LIKE bapisdhd1x,
       salesdocument        LIKE  bapivbeln-vbeln,
       return               LIKE  bapiret2  OCCURS 0 WITH HEADER LINE,
       order_items_in       LIKE  bapisditm OCCURS 0 WITH HEADER LINE,
       order_items_inx      LIKE  bapisditmx OCCURS 0 WITH HEADER LINE,
       order_partners       LIKE  bapiparnr OCCURS 0 WITH HEADER LINE,
       order_schedules_in   LIKE  bapischdl OCCURS 0 WITH HEADER LINE,
       order_schedules_inx  LIKE  bapischdlx OCCURS 0 WITH HEADER LINE,
       order_conditions_in  LIKE  bapicond OCCURS 0 WITH HEADER LINE,
       order_conditions_inx LIKE  bapicondx OCCURS 0 WITH HEADER LINE.

"for bapi extension
DATA : gs_bape_vbak   TYPE bape_vbak,
       gs_bape_vbakx  TYPE bape_vbakx,
       gs_EXTENSIONIN TYPE bapiparex,
       extensionin    LIKE  bapiparex OCCURS 0 WITH HEADER LINE.


DATA : gv_file TYPE string,
       gv_item TYPE vbap-posnr.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS : p_file TYPE ibipparms-path OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
*     FIELD_NAME    = ' '
    IMPORTING
      file_name     = p_file.

START-OF-SELECTION.
  IF p_file IS NOT INITIAL.
    PERFORM upload_file.
    IF gt_itab[] IS NOT INITIAL.
      PERFORM create_order.
    ENDIF.

  ENDIF.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_file .

  gv_file = p_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = gv_file
      filetype                = 'ASC'
      has_field_separator     = 'X'
*     HEADER_LENGTH           = 0
*     READ_BY_LINE            = 'X'
*     DAT_MODE                = ' '
*     CODEPAGE                = ' '
*     IGNORE_CERR             = ABAP_TRUE
*     REPLACEMENT             = '#'
*     CHECK_BOM               = ' '
*     VIRUS_SCAN_PROFILE      =
*     NO_AUTH_CHECK           = ' '
*    IMPORTING
*     FILELENGTH              =
*     HEADER                  =
    TABLES
      data_tab                = gt_itab
*    CHANGING
*     ISSCANPERFORMED         = ' '
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_ORDER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_order .

  CLEAR : gs_itab, gs_itab1.
  READ TABLE gt_itab INTO gs_itab1 INDEX 1.

  CLEAR : order_header_in, order_header_inx, order_partners[], order_partners.

  "HEADER infomration
  order_header_in-doc_type   = gs_itab1-order_type.
  order_header_in-sales_org  = gs_itab1-sorg.
  order_header_in-distr_chan = gs_itab1-dch.
  order_header_in-division   = gs_itab1-div.

  order_header_inx-updateflag = 'I'.
  order_header_inx-doc_type   = 'X'.
  order_header_inx-sales_org  = 'X'.
  order_header_inx-distr_chan = 'X'.
  order_header_inx-division   = 'X'.

  "partner details.
  order_partners-partn_role   = 'AG'.
  order_partners-partn_numb   = gs_itab1-kunnr.
  APPEND order_partners.
  CLEAR : order_partners.

  order_partners-partn_role   = 'WE'.
  order_partners-partn_numb   = gs_itab1-kunnr.
  APPEND order_partners.
  CLEAR : order_partners.

  order_partners-partn_role   = 'RE'.
  order_partners-partn_numb   = gs_itab1-kunnr.
  APPEND order_partners.
  CLEAR : order_partners.

  order_partners-partn_role   = 'RG'.
  order_partners-partn_numb   = gs_itab1-kunnr.
  APPEND order_partners.
  CLEAR : order_partners.

  "lien items
  LOOP AT gt_itab INTO gs_itab.

    gv_item   = gv_item + 10.

    order_items_in-itm_number    = gv_item.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gs_itab-matnr
      IMPORTING
        output = gs_itab-matnr.
    order_items_in-material      = gs_itab-matnr.

    CONDENSE gs_itab-qty.
    order_items_in-target_qty    = gs_itab-qty.
    order_items_in-target_qu     = gs_itab-uom.
    order_items_in-wbs_elem      = gs_itab-wbs.
    order_items_in-plant         = gs_itab-plant.
    order_items_in-store_loc     = gs_itab-stloc.
    APPEND order_items_in.
    CLEAR : order_items_in.

    order_items_inx-itm_number    = gv_item.
    order_items_inx-material      = 'X'.
    order_items_inx-target_qty    = 'X'.
    order_items_inx-target_qu     = 'X'.
    order_items_inx-wbs_elem      = 'X'.
    order_items_inx-plant         = 'X'.
    order_items_inx-store_loc     = 'X'.
    APPEND order_items_inx.
    CLEAR : order_items_inx.

    "schedul el lines
    order_schedules_in-itm_number = gv_item.
    order_schedules_in-req_qty    = gs_itab-qty.
    APPEND order_schedules_in.
    CLEAR : order_schedules_in.

    order_schedules_inx-itm_number = gv_item.
    order_schedules_inx-req_qty    = 'X'.
    APPEND order_schedules_inx.
    CLEAR : order_schedules_inx.

    "condiotn values
    order_conditions_in-itm_number  = gv_item.
    order_conditions_in-cond_type   = 'ZBAS'.

    CONDENSE gs_itab-price.
    order_conditions_in-cond_value = ( gs_itab-price / 10 ).
    APPEND order_conditions_in.
    CLEAR : order_conditions_in.

    order_conditions_inx-itm_number  = gv_item.
    order_conditions_inx-cond_type    = 'ZBAS'.
    order_conditions_inx-cond_value   = 'X'.
    APPEND order_conditions_inx.
    CLEAR : order_conditions_inx.


    CLEAR : gs_itab.
  ENDLOOP.

*"for exttenstion fields
*   GS_BAPE_VBAK-ZZREGDT      = '20200504'.
*   gs_bape_vbak-ZZREGNUM     = '123456'.
*   gs_bape_vbak-ZZREGOFFICE  = 'PUNE CITY'.
*
*   GS_EXTENSIONIN-STRUCTURE  = 'BAPE_VBAK'.
*   GS_EXTENSIONIN-VALUEPART1 = GS_BAPE_VBAK.
*   append GS_EXTENSIONIN to EXTENSIONIN.
*
*
*   GS_BAPE_VBAKX-ZZREGDT      = 'X'.
*   gs_bape_vbakX-ZZREGNUM     = 'X'.
*   gs_bape_vbakX-ZZREGOFFICE  = 'X'.
*
*   GS_EXTENSIONIN-STRUCTURE  = 'BAPE_VBAKX'.
*   GS_EXTENSIONIN-VALUEPART1 = GS_BAPE_VBAKX.
*   append GS_EXTENSIONIN to EXTENSIONIN.


  "call bapi
  CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
    EXPORTING
*     SALESDOCUMENTIN      =
      order_header_in      = order_header_in
      order_header_inx     = order_header_inx
*     SENDER               =
*     BINARY_RELATIONSHIPTYPE       =
*     INT_NUMBER_ASSIGNMENT         =
*     BEHAVE_WHEN_ERROR    =
*     LOGIC_SWITCH         =
*     TESTRUN              =
*     CONVERT              = ' '
    IMPORTING
      salesdocument        = salesdocument
    TABLES
      return               = return
      order_items_in       = order_items_in
      order_items_inx      = order_items_inx
      order_partners       = order_partners
      order_schedules_in   = order_schedules_in
      order_schedules_inx  = order_schedules_inx
      order_conditions_in  = order_conditions_in
      order_conditions_inx = order_conditions_inx
*     ORDER_CFGS_REF       =
*     ORDER_CFGS_INST      =
*     ORDER_CFGS_PART_OF   =
*     ORDER_CFGS_VALUE     =
*     ORDER_CFGS_BLOB      =
*     ORDER_CFGS_VK        =
*     ORDER_CFGS_REFINST   =
*     ORDER_CCARD          =
*     ORDER_TEXT           =
*     ORDER_KEYS           =
      extensionin          = extensionin
*     PARTNERADDRESSES     =
*     EXTENSIONEX          =
*     NFMETALLITMS         =
    .

  IF salesdocument IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'
*         IMPORTING
*       RETURN        =
      .

    WRITE : salesdocument.

  ELSE.
    WRITE : 'error while creating order'.
  ENDIF.

ENDFORM.