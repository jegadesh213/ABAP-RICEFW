*&---------------------------------------------------------------------*
*& Report Z_BAPIPRAC_02
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_bapiprac_02.

TYPES : BEGIN OF tp_itab,
          "HEADDATA
          ind_sector    TYPE mbrsh,
          matl_type     TYPE mtart,
          material      TYPE matnr18,
          matl_desc     TYPE maktx,
          "CLIENTDATA
          matl_group    TYPE matkl,
          base_uom      TYPE meins,
          "PLANTDATA
          plant         TYPE werks_d,
          "STORAGELOCATIONDATA
          stge_loc      TYPE lgort_d,
          "VALUATIONDATA
          val_area      TYPE bwkey,
          price_ctrl    TYPE vprsv,
          moving_pr(15),                          "VERPR_BAPI
          price_unit    TYPE peinh,
          val_class     TYPE bklas,
          "bapi retrun
          msg_type(1),
          msg(100),
        END OF tp_itab.

DATA : gs_itab TYPE tp_itab,
       gt_itab TYPE STANDARD TABLE OF tp_itab.

"for bapi str.
DATA : gs_headdata             LIKE bapimathead,
       gs_clientdata           LIKE bapi_mara,
       gs_clientdatax          LIKE bapi_marax,
       gs_plantdata            LIKE bapi_marc,
       gs_plantdatax           LIKE bapi_marcx,
       gs_storagelocationdata  LIKE bapi_mard,
       gs_storagelocationdatax LIKE bapi_mardx,
       gs_valuationdata        LIKE bapi_mbew,
       gs_valuationdatax       LIKE bapi_mbewx,
       gs_RETURN               LIKE bapiret2,
       gt_RETURNMESSAGES       LIKE STANDARD TABLE OF bapi_matreturn2 WITH HEADER LINE,
       gt_MATERIALDESCRIPTION  LIKE STANDARD TABLE OF bapi_makt WITH HEADER LINE,
       gt_MATERIAL_NUMBER      LIKE STANDARD TABLE OF bapimatinr WITH HEADER LINE.

DATA : gv_file TYPE string.



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS :   p_file TYPE localfile OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'F4_FILENAME'
*   EXPORTING
*     PROGRAM_NAME        = SYST-CPROG
*     DYNPRO_NUMBER       = SYST-DYNNR
*     FIELD_NAME          = ' '
    IMPORTING
      file_name = p_file.



START-OF-SELECTION.


  PERFORM upload_file_to_itab.
  PERFORM create_material.


END-OF-SELECTION.
*&---------------------------------------------------------------------*
*& Form upload_file_to_itab
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_file_to_itab .

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
*  IMPORTING
*     FILELENGTH              =
*     HEADER                  =
    TABLES
      data_tab                = gt_itab
*  CHANGING
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


  IF gt_itab[] IS NOT INITIAL.

  ELSE.
    MESSAGE 'No record in the file' TYPE 'I'.
    LEAVE PROGRAM.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_material
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_material .


  LOOP AT gt_itab INTO gs_itab.

    CLEAR : gt_material_number[].


    CALL FUNCTION 'BAPI_MATERIAL_GETINTNUMBER'
      EXPORTING
        material_type    = gs_itab-matl_type
*       INDUSTRY_SECTOR  = ' '
        required_numbers = 1
*    IMPORTING
*       RETURN           =
      TABLES
        material_number  = gt_material_number.

    IF gt_MATERIAL_NUMBER[] IS NOT INITIAL.
      READ TABLE gt_MATERIAL_NUMBER INDEX 1.

      gs_itab-material   = gt_MATERIAL_NUMBER-material.

    ELSE.
      gs_itab-msg_type = 'E'.
      gs_itab-msg      = 'Error while generating internal number'.
      CONTINUE.
    ENDIF.

    CLEAR : gs_headdata.

    gs_headdata-material         = gs_itab-material.
    gs_headdata-ind_sector       = gs_itab-ind_sector.
    gs_headdata-matl_type        = gs_itab-matl_type.

    gs_headdata-basic_view       = abap_true.
    gs_headdata-purchase_view    = abap_true.
    gs_headdata-storage_view     = abap_true.
    gs_headdata-account_view     = abap_true.

    CLEAR : gs_clientdata, gs_clientdatax.

    gs_clientdata-matl_group    = gs_itab-matl_group.
    gs_clientdatax-matl_group    = abap_true.

    gs_clientdata-base_uom      = gs_itab-base_uom.
    gs_clientdatax-base_uom      = abap_true.

    CLEAR : gs_plantdata, gs_plantdatax.

    gs_plantdata-plant        = gs_itab-plant.
    gs_plantdatax-plant        = gs_itab-plant.


    CLEAR : gs_storagelocationdata, gs_storagelocationdatax.

    gs_storagelocationdata-plant   = gs_itab-plant.
    gs_storagelocationdatax-plant  = gs_itab-plant.

    gs_storagelocationdata-stge_loc   = gs_itab-stge_loc.
    gs_storagelocationdatax-stge_loc   = gs_itab-stge_loc.

    CLEAR : gs_valuationdata, gs_valuationdatax.

    gs_valuationdata-val_area   = gs_itab-val_area.
    gs_valuationdatax-val_area  = gs_itab-val_area.

    gs_valuationdata-price_ctrl    = gs_itab-price_ctrl.
    gs_valuationdatax-price_ctrl   = abap_true.


    CONDENSE gs_itab-moving_pr.
    gs_valuationdata-moving_pr   = gs_itab-moving_pr.
    gs_valuationdatax-moving_pr  = abap_true.

    gs_valuationdata-price_unit  = gs_itab-price_unit.
    gs_valuationdatax-price_unit   = abap_true.

    gs_valuationdata-val_class   = gs_itab-val_class.
    gs_valuationdatax-val_class   = abap_true.

    CLEAR : gt_materialdescription[].

    gt_materialdescription-langu     = sy-langu.
    gt_materialdescription-langu_iso = sy-langu.
    gt_materialdescription-matl_desc = gs_itab-matl_desc.
    APPEND gt_materialdescription.

    CLEAR : gs_RETURN, gt_returnmessages[].

    "call BAPI
    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        headdata             = gs_headdata
        clientdata           = gs_clientdata
        clientdatax          = gs_clientdatax
        plantdata            = gs_plantdata
        plantdatax           = gs_plantdatax
*       FORECASTPARAMETERS   =
*       FORECASTPARAMETERSX  =
*       PLANNINGDATA         =
*       PLANNINGDATAX        =
        storagelocationdata  = gs_storagelocationdata
        storagelocationdatax = gs_storagelocationdatax
        valuationdata        = gs_valuationdata
        valuationdatax       = gs_valuationdatax
*       WAREHOUSENUMBERDATA  =
*       WAREHOUSENUMBERDATAX =
*       SALESDATA            =
*       SALESDATAX           =
*       STORAGETYPEDATA      =
*       STORAGETYPEDATAX     =
*       FLAG_ONLINE          = ' '
*       FLAG_CAD_CALL        = ' '
*       NO_DEQUEUE           = ' '
*       NO_ROLLBACK_WORK     = ' '
*       CLIENTDATACWM        =
*       CLIENTDATACWMX       =
*       VALUATIONDATACWM     =
*       VALUATIONDATACWMX    =
*       MATPLSTADATA         =
*       MATPLSTADATAX        =
*       MARC_APS_EXTDATA     =
*       MARC_APS_EXTDATAX    =
      IMPORTING
        return               = gs_RETURN
      TABLES
        materialdescription  = gt_materialdescription
*       UNITSOFMEASURE       =
*       UNITSOFMEASUREX      =
*       INTERNATIONALARTNOS  =
*       MATERIALLONGTEXT     =
*       TAXCLASSIFICATIONS   =
        returnmessages       = gt_RETURNMESSAGES
*       PRTDATA              =
*       PRTDATAX             =
*       EXTENSIONIN          =
*       EXTENSIONINX         =
*       UNITSOFMEASURECWM    =
*       UNITSOFMEASURECWMX   =
*       SEGMRPGENERALDATA    =
*       SEGMRPGENERALDATAX   =
*       SEGMRPQUANTITYDATA   =
*       SEGMRPQUANTITYDATAX  =
*       SEGVALUATIONTYPE     =
*       SEGVALUATIONTYPEX    =
*       SEGSALESSTATUS       =
*       SEGSALESSTATUSX      =
*       SEGWEIGHTVOLUME      =
*       SEGWEIGHTVOLUMEX     =
*       DEMAND_PENALTYDATA   =
*       DEMAND_PENALTYDATAX  =
*       NFMCHARGEWEIGHTS     =
*       NFMCHARGEWEIGHTSX    =
*       NFMSTRUCTURALWEIGHTS =
*       NFMSTRUCTURALWEIGHTSX       =
      .

    IF gs_RETURN-type = 'S'.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'
*              IMPORTING
*         RETURN        =
        .

    ELSE.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*             IMPORTING
*               RETURN        =
        .


    ENDIF.



    gs_itab-msg_type    = gs_return-type.
    gs_itab-msg         = gs_return-message.


    MODIFY gt_itab FROM gs_itab TRANSPORTING material msg_type msg.

    CLEAR : gs_itab.
  ENDLOOP.


  cl_demo_output=>display( gt_itab ).


ENDFORM.