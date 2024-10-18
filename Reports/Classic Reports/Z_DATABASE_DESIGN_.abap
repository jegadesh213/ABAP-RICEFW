*&---------------------------------------------------------------------*
*& Report Z_DATABASE_DESIGN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_DATABASE_DESIGN_.

TYPES : BEGIN OF ty_employee,
        custid TYPE zzcust-custid,
        custname TYPE zzcust-custname,
        END OF ty_employee.

TYPES : BEGIN OF ty_emplang,
        custid type zzcustlang-custid,
        custlang type zzcustlang-custlang,
        END OF ty_emplang.

DATA : it_employee TYPE TABLE OF ty_employee,
       wa_employee TYPE ty_employee,
       it_emplang TYPE TABLE OF ty_emplang,
       wa_emplang TYPE ty_emplang.

SELECT custid custname INTO TABLE it_employee FROM zzcust.

SELECT custid custlang INTO TABLE it_emplang FROM zzcustlang.

LOOP AT it_employee INTO wa_employee.
  WRITE : / 'CUSTOMER ID :',wa_employee-custid ,
            'CUSTOMER NAME :',wa_employee-custname.

  LOOP AT it_emplang INTO wa_emplang WHERE custid = wa_employee-custid.
    WRITE : / 'CUSTOMER LANGUAGE :',wa_emplang-custlang.
  ENDLOOP.

ENDLOOP.