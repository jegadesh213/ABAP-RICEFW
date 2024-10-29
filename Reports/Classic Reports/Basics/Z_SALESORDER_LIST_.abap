*&---------------------------------------------------------------------*
*& Report Z_SALESORDER_LIST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_SALESORDER_LIST_.

Tables : vbak , vbap.

PARAMETERS : p_vbeln TYPE vbeln_va,
             p_erdat TYPE erdat,
             p_ernam TYPE ernam,
             p_matnr TYPE matnr.

TYPES : BEGIN OF ty_order,
          vbeln TYPE vbeln_va,
          ernam TYPE ernam,
          erdat TYPE erdat,
          posnr TYPE posnr,
          matnr TYPE matnr,
          kwmeng TYPE kwmeng,
          netwr TYPE netwr,
       END OF ty_order.

DATA : it_order TYPE TABLE OF ty_order,
       wa_order TYPE ty_order.

SELECT vbak~vbeln vbak~ernam vbak~erdat vbap~posnr vbap~matnr vbap~kwmeng vbap~netwr FROM vbak as vbak INNER JOIN vbap as vbap ON vbak~vbeln = vbap~vbeln
  INTO TABLE it_order WHERE vbak~vbeln = p_vbeln
                      AND vbak~erdat = p_erdat
                      AND vbak~ernam = p_ernam
                      AND vbap~matnr = p_matnr.

FORMAT COLOR 5.
WRITE :/ 'Order Num | ' , 'Created By | ' , 'Created on | ', 'Item | ', 'Material | ' , 'Quantity | ', 'Value |'.
FORMAT COLOR OFF.

Uline.

LOOP AT it_order INTO wa_order.
  WRITE :/ wa_order-vbeln , wa_order-ernam , wa_order-erdat, wa_order-posnr, wa_order-matnr, wa_order-kwmeng, wa_order-netwr.
ENDLOOP.