*3.1h Truck tracking System Report on despatch weight                           *
*-------------------------------------------------------------------------------*
*  Program ID: YSYR1006.
*  Program Name: Truck tracking System Report on despatch weight.
*  Purpose: Report for SD.
*  Report-ID. SD-RR-****.
*  Requester. P S Dave.
*  Author: Atit M Upadhyay.
*  Primary Tables used: yttstx0001, yttstx0002, ymrrdetl.
*  Legacy File Used: N/A.
*  Change Request Number: D01K904072.
*  Start Date:  March 13, 1999.
*  End Date:
*
*---------------------Revision Details------------------------------------------*
*  Revised By:
*{   INSERT         RD2K907443                                        2
*          Praveen Upadhyay
*}   INSERT
*  Change Request Number:
*{   INSERT         RD2K907443                                        3
*            RD2K907443
*}   INSERT
*  Purpose:
*{   INSERT         RD2K907443                                        4
*         Copy Original report.
*}   INSERT
*
*--------------------------------------------------------------------------------*
* * CHANGE HISTORY                                                               *
*--------------------------------------------------------------------------------*
* 30.08.2018 | brilo_005 | CD.8025958| Including pallet weight difference
*--------------------------------------------------------------------------------*
* 24.09.2018 | brilo_005 | CD.8025958| Including pallet weight difference logic change
*-------------------------------------------------------------------------

REPORT ysyr1006 LINE-SIZE 200 LINE-COUNT 58(2)
                                      NO STANDARD PAGE HEADING.

TABLES : yttstx0001,   " Truck Transaction/Extension Table - Header
         yttstx0002, "#EC NEEDED                       " Truck Transaction/Extension Table - Detail
         ttds,                                              "#EC NEEDED
         zdelint,                                           "#EC NEEDED
         ytts,
         yttsa,                                             "#EC NEEDED
         yttsr,                                             "#EC NEEDED
         lips,                                              "#EC NEEDED
         mara.
*{   INSERT         RD2K907443                                        1
*data: lv_matnr type matnr.
*}   INSERT

INCLUDE ysyr1006top.

DATA : BEGIN OF iyttsa OCCURS 0.                            "#EC NEEDED
        INCLUDE STRUCTURE yttsa.                            "#EC NEEDED
DATA : END OF iyttsa.                                       "#EC NEEDED


DATA : BEGIN OF itab_det OCCURS 0,                          "#EC NEEDED
       report_no  LIKE yttstx0001-report_no,                "#EC NEEDED
       truck_no   LIKE yttstx0001-truck_no,                 "#EC NEEDED
       area       LIKE yttstx0001-area,                     "#EC NEEDED
       transplpt  LIKE yttstx0001-transplpt,                "#EC NEEDED
       vstel      LIKE yttstx0001-vstel,                    "#EC NEEDED
       pp_entr_dt LIKE yttstx0001-pp_entr_dt,               "#EC NEEDED
       pp_entr_tm LIKE yttstx0001-pp_entr_tm,               "#EC NEEDED
       function   LIKE yttstx0001-function,                 "#EC NEEDED
       vbeln      LIKE yttstx0002-dlivry_no,                "#EC NEEDED
       posnr      LIKE yttstx0002-posnr,                    "#EC NEEDED
       delivery   LIKE yttstx0002-delivery,                 "#EC NEEDED
       dlvry_qty1 LIKE yttstx0002-dlvry_qty1,               "#EC NEEDED
       invoice_no LIKE yttstx0002-invoice_no,               "#EC NEEDED
       invoice_dt LIKE yttstx0002-invoice_dt,               "#EC NEEDED
       invoice_tm LIKE yttstx0002-invoice_tm,               "#EC NEEDED
       trk_purpos(15),                                      "#EC NEEDED
       ebeln LIKE yttstx0002-ebeln,                         "#EC NEEDED
       invoice_qty LIKE lips-brgew,                         "#EC NEEDED
       wb1_tr_wt   LIKE yttstx0001-wb1_tr_wt,               "#EC NEEDED
       wb2_tr_wt   LIKE yttstx0001-wb2_tr_wt,               "#EC NEEDED
       net_wght    LIKE yttstx0001-wb2_tr_wt,               "#EC NEEDED
       diff        LIKE yttstx0001-wb2_tr_wt,               "#EC NEEDED
       remarks     LIKE yttsr-text,                         "#EC NEEDED
       wbnremarks  LIKE yttsr-text,                         "#EC NEEDED
      trns_name LIKE yttstx0001-trns_name,                  "#EC NEEDED
      in_wb_no   LIKE yttstx0001-in_wb_no,                  "#EC NEEDED
      out_wb_no   LIKE yttstx0001-in_wb_no,
      permit      LIKE yttstx0001-permit, "brilo_005 30.08.2018
      packing_mat_wt TYPE yig_cmpqua,
      pm_wt_wbn      TYPE ywb_tr_wt,
      pm_wt_wbx      TYPE ywb_tr_wt,
      pm_wbn         TYPE ycontno,
      pm_wbx         TYPE zloaded_truck_number,
      wbnumber_pmn   TYPE ywghbridge,       "Vankudoth Rajkumar
      wbnumber_pmx   TYPE ywghbridge.       "Vankudoth Rajkumar
DATA : END OF itab_det.

*** Detail Records 11/01/01
DATA : BEGIN OF itab_inv OCCURS 0,                          "#EC NEEDED
       report_no  LIKE yttstx0001-report_no,                "#EC NEEDED
       invoice_no TYPE xblnr_v1,"yttstx0002-invoice_no,               "#EC NEEDED
       invoice_qty LIKE lips-brgew.
DATA : END OF itab_inv.
*** End Detail Records

DATA : BEGIN OF itab_det2  OCCURS 0,                        "#EC NEEDED
       function LIKE yttstx0001-function,                   "#EC NEEDED
       report_no LIKE yttstx0001-report_no,                 "#EC NEEDED
       quantity LIKE yttstx0002-dlvry_qty1.                 "#EC NEEDED
DATA : END OF itab_det2.

DATA : BEGIN OF iyttstx0001 OCCURS 0,                       "#EC NEEDED
       report_no  LIKE yttstx0001-report_no,                "#EC NEEDED
       truck_no   LIKE yttstx0001-truck_no,                 "#EC NEEDED
       permit     LIKE yttstx0001-permit,                   "#EC NEEDED
       spart      LIKE yttstx0001-spart,  "brilo_005
       pp_entr_dt LIKE yttstx0001-pp_entr_dt,               "#EC NEEDED
       pp_entr_tm LIKE yttstx0001-pp_entr_tm,               "#EC NEEDED
       area       LIKE yttstx0001-area,                     "#EC NEEDED
       transplpt  LIKE yttstx0001-transplpt,                "#EC NEEDED
       vstel      LIKE yttstx0001-vstel,                    "#EC NEEDED
       matgr      LIKE yttstx0001-matgr,                    "#EC NEEDED
       trk_purpos LIKE yttstx0001-trk_purpos,               "#EC NEEDED
       function   LIKE yttstx0001-function,                 "#EC NEEDED
       wb1_tr_wt  LIKE yttstx0001-wb1_tr_wt,                "#EC NEEDED
       wb2_tr_wt  LIKE yttstx0001-wb2_tr_wt,                "#EC NEEDED
       in_wb_no   LIKE yttstx0001-in_wb_no,                 "#EC NEEDED
       trns_name LIKE yttstx0001-trns_name,                 "#EC NEEDED
       out_wb_no  LIKE yttstx0001-out_wb_no,
       loaded_truck_number LIKE  yttstx0001-loaded_truck_number,
       totalqty TYPE yig_cmpqua,
       contno   TYPE ytruck_no." ycontno.
DATA : END OF iyttstx0001.

DATA : BEGIN OF iyttstx0002 OCCURS 0,                       "#EC NEEDED
       report_no  LIKE yttstx0001-report_no,                "#EC NEEDED
       dlivry_no  LIKE yttstx0002-dlivry_no,                "#EC NEEDED
       posnr      LIKE yttstx0002-posnr,                    "#EC NEEDED
       mat_code   LIKE yttstx0002-mat_code,                 "#EC NEEDED
       delivery   LIKE yttstx0002-delivery,                 "#EC NEEDED
       desp_uom   LIKE yttstx0002-desp_uom,                 "#EC NEEDED
       dlvry_qty1 LIKE yttstx0002-dlvry_qty1,               "#EC NEEDED
       invoice_no LIKE yttstx0002-invoice_no,               "#EC NEEDED
       invoice_dt LIKE yttstx0002-invoice_dt,               "#EC NEEDED
       invoice_tm LIKE yttstx0002-invoice_tm,               "#EC NEEDED
       ebeln      LIKE yttstx0002-ebeln,                    "#EC NEEDED
       ebelp      LIKE yttstx0002-ebelp,                    "#EC NEEDED
       werks      LIKE yttstx0002-werks,                    "#EC NEEDED
       billno	    TYPE vbeln_vf  .                          "#EC NEEDED
DATA : END OF iyttstx0002.

DATA : BEGIN OF ilipsd OCCURS 0,                            "#EC NEEDED
       vbeln LIKE lips-vbeln,                               "#EC NEEDED
       posnr LIKE lips-posnr,                               "#EC NEEDED
       vgbel LIKE lips-vgbel,                               "#EC NEEDED
       vgpos LIKE lips-vgpos,                               "#EC NEEDED
       gewei LIKE lips-gewei,                               "#EC NEEDED
       vrkme LIKE lips-vrkme,                               "#EC NEEDED
       ntgew LIKE lips-ntgew,                               "#EC NEEDED
       brgew LIKE lips-brgew,                               "#EC NEEDED
       lfimg LIKE lips-lfimg,                               "#EC NEEDED
       spart LIKE lips-spart.   "brilo_005 30.08.2018       "#EC NEEDED
DATA : END OF ilipsd.                                       "#EC NEEDED
                                                            "#EC NEEDED
DATA : BEGIN OF ilips OCCURS 0,                             "#EC NEEDED
       vbeln LIKE lips-vbeln,                               "#EC NEEDED
       vgbel LIKE lips-vgbel,                               "#EC NEEDED
       vgpos LIKE lips-vgpos,                               "#EC NEEDED
       gewei LIKE lips-gewei,                               "#EC NEEDED
       vrkme LIKE lips-vrkme,                               "#EC NEEDED
       lfimg LIKE lips-lfimg,                               "#EC NEEDED
       ntgew LIKE lips-ntgew,                               "#EC NEEDED
       brgew LIKE lips-brgew.                               "#EC NEEDED
DATA : END OF ilips.                                        "#EC NEEDED
                                                            "#EC NEEDED
DATA : BEGIN OF iyttsr OCCURS 0.                            "#EC NEEDED
        INCLUDE STRUCTURE yttsr.
DATA : END OF iyttsr.

TYPES: BEGIN OF ty_yttstm0001,
        truck_no TYPE ytruck_no,
        ulw      TYPE aslvt9,
        rulw_uom TYPE meins,
       END OF ty_yttstm0001.

DATA: lt_yttstm0001 TYPE TABLE OF ty_yttstm0001,
      lt_yttstm0001_1 TYPE TABLE OF ty_yttstm0001,
      iyttstx0001_t LIKE TABLE OF iyttstx0001,
      lw_yttstm0001 TYPE ty_yttstm0001,
      lw_yttstm0001_1 TYPE ty_yttstm0001.

DATA : w_sr_no TYPE i VALUE 0,                              "#EC NEEDED
       lw_tabix TYPE sy-tabix,                              "#EC NEEDED
       w_n_date LIKE sy-datum,                              "#EC NEEDED
       w_t_trucks TYPE i VALUE 0,                           "#EC NEEDED
       w_t_gross TYPE i VALUE 0,                            "#EC NEEDED
       w_t_tare TYPE i VALUE 0,                             "#EC NEEDED
       w_t_net TYPE i VALUE 0,                              "#EC NEEDED
       w_t_inv TYPE  p DECIMALS 3 VALUE 0,                  "#EC NEEDED
       w_p_brgew LIKE zdelint-brgew,                        "#EC NEEDED
       w_t_diff TYPE i VALUE 0,                             "#EC NEEDED
       wlincnt TYPE i VALUE 0,                              "#EC NEEDED
       w_dt_tm(11),                                         "#EC NEEDED
       tot(5).                                              "#EC NEEDED

*ALV DECLARATION
TYPE-POOLS : slis.

DATA : alv_fldcat_t TYPE slis_t_fieldcat_alv,               "#EC NEEDED
       alv_fldcat_s TYPE slis_fieldcat_alv.                 "#EC NEEDED

FIELD-SYMBOLS: <iyttstx0002> LIKE LINE OF iyttstx0002.
                                                            "#EC NEEDED
*DATA : ALVTITLE TYPE LVC_TITLE.                          "#EC NEEDED
                                                            "#EC NEEDED
DATA : alv_slis_alv_event  TYPE slis_alv_event,             "#EC NEEDED
       alv_slis_t_event    TYPE slis_t_event.               "#EC NEEDED
                                                            "#EC NEEDED
DATA : v_repid TYPE sy-repid.                               "#EC NEEDED
DATA:gw_repid TYPE sy-repid,
     gw_layout TYPE disvariant,
     gw_exit TYPE c,
     gw_speclayout TYPE disvariant.
DATA:lt_excluding TYPE slis_t_extab,
     lw_excluding TYPE slis_extab.
DATA: lw_mtart TYPE mtart.
DATA : BEGIN OF iyttstx0002_t OCCURS 0,                     "#EC NEEDED
       report_no  LIKE yttstx0001-report_no,                "#EC NEEDED
       dlivry_no  LIKE yttstx0002-dlivry_no,                "#EC NEEDED
       posnr      LIKE yttstx0002-posnr,                    "#EC NEEDED
       mat_code   LIKE yttstx0002-mat_code,                 "#EC NEEDED
       delivery   LIKE yttstx0002-delivery,                 "#EC NEEDED
       desp_uom   LIKE yttstx0002-desp_uom,                 "#EC NEEDED
       dlvry_qty1 LIKE yttstx0002-dlvry_qty1,               "#EC NEEDED
       invoice_no LIKE yttstx0002-invoice_no,               "#EC NEEDED
       invoice_dt LIKE yttstx0002-invoice_dt,               "#EC NEEDED
       invoice_tm LIKE yttstx0002-invoice_tm,               "#EC NEEDED
       ebeln      LIKE yttstx0002-ebeln,                    "#EC NEEDED
       ebelp      LIKE yttstx0002-ebelp,                    "#EC NEEDED
       werks      TYPE yttstx0002-werks , " eswara
       billno	    TYPE vbeln_vf  .                          "#EC NEEDED
DATA : END OF iyttstx0002_t.

TYPES : BEGIN OF ty_vbrk,
        vbeln TYPE vbeln_vf,
        xblnr	TYPE xblnr_v1,
       END OF ty_vbrk.
DATA : git_vbrk TYPE TABLE OF ty_vbrk,
       gwa_vbrk TYPE          ty_vbrk,
       lw_stx   LIKE LINE OF  iyttstx0002_t.
****BOC - brilo_005 : 30.08.2018
TYPES: BEGIN OF lty_param,
        name    TYPE rvari_vnam,
        numb    TYPE tvarv_numb,
        active  TYPE zactive_flag,
        area    TYPE yarea,
        spart   TYPE spart,
       END OF lty_param.

TYPES: BEGIN OF lty_param1,
        name    TYPE rvari_vnam,
        numb    TYPE tvarv_numb,
        werks    TYPE werks_d,
       END OF lty_param1.

DATA: lt_lips   LIKE TABLE OF ilipsd,
      lt_lips1  LIKE TABLE OF ilipsd,
      lt_lips_t LIKE TABLE OF ilipsd,
      lw_lips   LIKE ilipsd,
      lt_temp   LIKE TABLE OF iyttstx0001,
      lt_param  TYPE TABLE OF lty_param,
      lt_param1  TYPE TABLE OF lty_param,
      lt_param2 TYPE TABLE OF lty_param1,
      lw_param2 TYPE lty_param1,
      lw_param  TYPE lty_param.
CONSTANTS: lc_pallet TYPE rvari_vnam VALUE 'PALLET_WEIGHT',
           lc_ywbs TYPE rvari_vnam VALUE 'ZSCE_REC_YWBS_AREA',
           lc_ywbs1 TYPE rvari_vnam VALUE 'ZSCE_REC_YWBS_EWM_PLANT'.

****BOA - brilo_005 24.09.2018
DATA:    lt_delv TYPE zdel_tt,
         lw_delv TYPE vbeln_vl,
         lt_pallet TYPE zpalletwt_tt,
         lw_pallet TYPE zpalletwt_s,
         lw_totpal TYPE ywb_tr_wt.
****EOC*********************************************************

* Added by Sailasuta Das CD : 8076028(Start)
TYPES : BEGIN OF gty_log_exec_var,
        name TYPE zlog_exec_var-name,
        numb TYPE zlog_exec_var-numb,
        active TYPE zlog_exec_var-active,
        remarks TYPE zlog_exec_var-remarks,
        area TYPE zlog_exec_var-area,
        END OF gty_log_exec_var.

TYPES : BEGIN OF gty_ttsaext,
        area TYPE yttsaext-area,
        report_no TYPE yttsaext-report_no,
        function TYPE yttsaext-function,
        editdt TYPE yttsaext-editdt,
        edittm TYPE yttsaext-edittm,
        in_wb_no TYPE yttsaext-in_wb_no,   "Vankudoth Rajkumar
        pm_wt TYPE yttsaext-pm_wt,
        END OF gty_ttsaext.

DATA : gw_log_exec_var TYPE gty_log_exec_var,
       gw_ttsaext_wbn TYPE gty_ttsaext,
       gt_ttsaext TYPE TABLE OF gty_ttsaext,
       gt_iyttstx0001 LIKE TABLE OF iyttstx0001,
       gt_yttstm0001 TYPE TABLE OF ty_yttstm0001,
       gw_yttstm0001 TYPE ty_yttstm0001,
       gw_ttsaext_wbx TYPE gty_ttsaext,
       gw_pm_wt_wbx TYPE  yttsaext-pm_wt,
       gw_pm_wt_wbn TYPE  yttsaext-pm_wt,
       lp_ulw TYPE ntgew_15,
       lp_uom TYPE oig_meabm,
       lp_cuom TYPE /rwhm/inv_qty,
       gw_in_wb_no_wbn TYPE ywghbridge,
       gw_in_wb_no_wbx TYPE ywghbridge,
       gt_iyttstx0001_c LIKE TABLE OF iyttstx0001,
       gw_iyttstx0001 LIKE iyttstx0001.

CONSTANTS : gc_kg_msehi TYPE msehi VALUE 'KG'.

FIELD-SYMBOLS: <gfs_iyttstx0001> LIKE iyttstx0001.

* Added by Sailasuta Das CD : 8076028(End)

*&---------------------------------------------------------------------*
*& BEGIN: Cursor Generated Code
*& Class: LCL_WEIGHT_CALCULATOR
*& Purpose: Calculate Tare Weight and Packaging Weight for YWBS report
*& Based on Technical Specification: YWBS_Packaging_Weight
*&---------------------------------------------------------------------*

* Type definitions for weight calculator
TYPES: BEGIN OF lty_zlog_exec_var,
         name TYPE zlog_exec_var-name,
         area TYPE zlog_exec_var-area,
         active TYPE zlog_exec_var-active,
       END OF lty_zlog_exec_var.

TYPES: lty_zlog_exec_var_tab TYPE TABLE OF lty_zlog_exec_var.

TYPES: BEGIN OF lty_weight_data,
         report_no TYPE yttstx0001-report_no,
         wb1_tr_wt TYPE yttstx0001-wb1_tr_wt,
         totalqty TYPE yttstx0001-totalqty,
       END OF lty_weight_data.

TYPES: BEGIN OF lty_calculated_weights,
         tare_weight TYPE ywb_tr_wt,
         packaging_weight TYPE yig_cmpqua,
       END OF lty_calculated_weights.

*&---------------------------------------------------------------------*
*& Class  LCL_WEIGHT_CALCULATOR
*&---------------------------------------------------------------------*
*& Purpose: Calculate Tare Weight and Packaging Weight for YWBS report
*& Methods:
*&   - is_new_logic_active: Check feature activation
*&   - calculate_weights_new: New calculation logic
*&   - calculate_weights_existing: Existing calculation logic (preserved)
*&---------------------------------------------------------------------*
CLASS lcl_weight_calculator DEFINITION.
  PUBLIC SECTION.
    "! Check if new weight calculation logic is activated
    "! @parameter iv_area_code | Area code from selection screen
    "! @parameter rv_is_active | Returns ABAP_TRUE if feature is active
    METHODS is_new_logic_active
      IMPORTING iv_area_code TYPE yarea
      RETURNING VALUE(rv_is_active) TYPE abap_bool.

    "! Calculate weights using new logic (when feature is active)
    "! @parameter is_weight_data | Weight data from YTTSTX0001
    "! @parameter es_calculated | Calculated tare and packaging weights
    "! @parameter ev_error_occurred | Error flag
    "! @parameter ev_error_message | Error message text
    METHODS calculate_weights_new
      IMPORTING is_weight_data TYPE lty_weight_data
      EXPORTING es_calculated TYPE lty_calculated_weights
                ev_error_occurred TYPE abap_bool
                ev_error_message TYPE string.

    "! Calculate weights using existing logic (when feature is not active)
    "! @parameter is_weight_data | Weight data from YTTSTX0001
    "! @parameter es_calculated | Calculated tare and packaging weights
    METHODS calculate_weights_existing
      IMPORTING is_weight_data TYPE lty_weight_data
      EXPORTING es_calculated TYPE lty_calculated_weights.

  PRIVATE SECTION.
    " Constants
    CONSTANTS: lc_param_name TYPE char30 VALUE 'YWBS_PACKAGE_WT',
               lc_param_name_alt TYPE char30 VALUE 'Packaging_Weight',
               lc_active_flag TYPE char1 VALUE 'X'.
ENDCLASS.

CLASS lcl_weight_calculator IMPLEMENTATION.

  METHOD is_new_logic_active.
    DATA: lt_zlog_exec_var TYPE lty_zlog_exec_var_tab,
          lv_count TYPE i.

    " Initialize return value
    rv_is_active = abap_false.

    " Validate input
    IF iv_area_code IS INITIAL.
      RETURN.
    ENDIF.

    " Read control table - check both parameter names for backward compatibility
    SELECT name area active
      FROM zlog_exec_var
      INTO TABLE lt_zlog_exec_var
      WHERE ( name = lc_param_name OR name = lc_param_name_alt )
        AND area = iv_area_code
        AND active = lc_active_flag.

    " Check SY-SUBRC
    IF sy-subrc = 0.
      " Check for multiple records (data inconsistency)
      DESCRIBE TABLE lt_zlog_exec_var LINES lv_count.
      IF lv_count = 1.
        rv_is_active = abap_true.
      ELSEIF lv_count > 1.
        " Log error: Multiple active records found
        " Treat as not active to prevent incorrect behavior
        rv_is_active = abap_false.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_weights_new.
    DATA: lv_tare_weight TYPE ywb_tr_wt,
          lv_packaging_weight TYPE yig_cmpqua.

    " Initialize
    CLEAR: es_calculated, ev_error_occurred, ev_error_message.
    lv_tare_weight = 0.
    lv_packaging_weight = 0.

    " Validate input
    IF is_weight_data IS INITIAL.
      ev_error_occurred = abap_true.
      ev_error_message = 'Weight data is empty'(001).
      RETURN.
    ENDIF.

    " Calculate Tare Weight (WBN)
    IF is_weight_data-totalqty IS INITIAL OR is_weight_data-totalqty = 0.
      " TOTALQTY is blank - use WB1_TR_WT as tare weight
      lv_tare_weight = is_weight_data-wb1_tr_wt.
      lv_packaging_weight = 0.
    ELSE.
      " TOTALQTY exists - use it as original tare weight
      lv_tare_weight = is_weight_data-totalqty.

      " Calculate Packaging Weight
      lv_packaging_weight = is_weight_data-wb1_tr_wt - is_weight_data-totalqty.

      " Handle negative packaging weight (data inconsistency)
      IF lv_packaging_weight < 0.
        " Log warning: Negative packaging weight detected
        " Set to 0 for display
        lv_packaging_weight = 0.
        " Error flag set for logging purposes
        ev_error_occurred = abap_true.
        ev_error_message = 'Negative packaging weight detected - set to 0'(002).
      ENDIF.
    ENDIF.

    " Assign results
    es_calculated-tare_weight = lv_tare_weight.
    es_calculated-packaging_weight = lv_packaging_weight.
  ENDMETHOD.

  METHOD calculate_weights_existing.
    DATA: lv_tare_weight TYPE ywb_tr_wt,
          lv_packaging_weight TYPE yig_cmpqua.

    " Initialize
    CLEAR: es_calculated.
    lv_tare_weight = 0.
    lv_packaging_weight = 0.

    " Existing logic: Tare Weight
    IF is_weight_data-totalqty IS INITIAL OR is_weight_data-totalqty = 0.
      " If TOTALQTY is blank → use WB1_TR_WT
      lv_tare_weight = is_weight_data-wb1_tr_wt.
    ELSE.
      " Else → use TOTALQTY
      lv_tare_weight = is_weight_data-totalqty.
    ENDIF.

    " Existing logic: Packaging Weight
    lv_packaging_weight = is_weight_data-wb1_tr_wt - is_weight_data-totalqty.

    " Handle negative values
    IF lv_packaging_weight < 0.
      lv_packaging_weight = 0.
    ENDIF.

    " Assign results
    es_calculated-tare_weight = lv_tare_weight.
    es_calculated-packaging_weight = lv_packaging_weight.
  ENDMETHOD.

ENDCLASS.

*&---------------------------------------------------------------------*
*& END: Cursor Generated Code
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-012.
PARAMETER :
 p_area  LIKE yttstx0001-area OBLIGATORY MEMORY ID ytr,
 p_purp  LIKE ytts-trk_purpos OBLIGATORY,
 p_func  LIKE yttstx0001-function OBLIGATORY DEFAULT 'WBX'.
SELECT-OPTIONS :
 s_date  FOR sy-datum OBLIGATORY DEFAULT sy-datum NO-EXTENSION,
 p_matgr FOR yttstx0001-matgr OBLIGATORY,
 p_tplst FOR yttstx0001-transplpt,
 p_vstel FOR yttstx0001-vstel.
SELECTION-SCREEN END OF BLOCK b2.

*>>>>>>>>SELECTION SCREEN
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-013.
PARAMETERS : s_opt1  RADIOBUTTON GROUP radi USER-COMMAND act DEFAULT 'X',
             s_opt2  RADIOBUTTON GROUP radi .
PARAMETER i_invno AS CHECKBOX.                        "Added by AYN_007 as per UI Guidelines
SELECTION-SCREEN END OF BLOCK b1.

*Added by AYN_007 as per UI Guidelines.
SELECTION-SCREEN : BEGIN OF BLOCK b3 WITH FRAME TITLE text-015.
PARAMETER p_var LIKE  disvariant-variant MODIF ID bb.
SELECTION-SCREEN END OF BLOCK b3.


*SELECTION-SCREEN SKIP 1."Commented as per UI Guide lines by AYN_007
*PARAMETER I_INVNO AS CHECKBOX."Commented as per UI Guide lines by AYN_007
SET PF-STATUS 'YSYRWBSS'.
SET TITLEBAR 'TWB'.

INITIALIZATION.                             " Authorization added by PWC_076
***Authorization***
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD' FIELD 'YWBS'.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE w088(zrpmg) WITH 'YWBS' DISPLAY LIKE 'E'.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  IF s_opt2 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = 'BB'.
        screen-active = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-group1 = 'BB'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_var.
* popup F4 help to select a layout
  gw_repid = sy-repid.
  CLEAR gw_layout.
  MOVE gw_repid TO gw_layout-report.

  CALL FUNCTION 'LVC_VARIANT_F4'
    EXPORTING
      is_variant = gw_layout
      i_save     = 'A'
    IMPORTING
      e_exit     = gw_exit
      es_variant = gw_speclayout
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF gw_exit NE 'X'.
* set name of layout on selection screen
      p_var    = gw_speclayout-variant.
    ENDIF.
  ENDIF.

*AT SELECTION-SCREEN.
*  PERFORM auth.                              " Authorization added by PWC_076




START-OF-SELECTION.

  IF s_date-high IS INITIAL.
    s_date-high = s_date-low.
  ENDIF.

  w_n_date = s_date-high + 1.

  PERFORM fetch_data_using_area.

**********Aneesh *********22-07-08***
  IF s_opt1 = 'X'.
    PERFORM write_to_list.
  ELSEIF  s_opt2 = 'X'.
    PERFORM print_data.
  ENDIF.
**********Aneesh *********22-07-08***

TOP-OF-PAGE.

  WRITE : /22  'W E I G H - B R I D G E   S U M M A R Y'.
  WRITE : /.
  WRITE : /  'Area           :'(003), p_area.
  WRITE : /  'Truck Purpos   :'(004).
  IF p_purp EQ 'D'.
    WRITE 'Despatch'(001).
  ELSEIF p_purp EQ 'R'.
    WRITE 'Receipt'(002).
  ENDIF.

  WRITE : /  'Trans Pl Point :'(005), p_tplst-low, '-', p_tplst-high.
  WRITE : /  'Shipping Point :'(006), p_vstel-low, '-', p_vstel-high.
  IF s_date-high IS INITIAL.
    WRITE : /  'Date           :'(007), s_date-low.
  ELSE.
    WRITE : /  'Period         :'(008), s_date-low, ' To ', s_date-high.
  ENDIF.
  WRITE : 110  'Page : '(009), (4) sy-pagno.             "#EC TEXT_DIFF
  WRITE : / sy-uline(200).


  IF p_purp EQ 'D'.
    WRITE : /  sy-vline.
    WRITE : text-016 NO-GAP. "#EC NOTEXT "'SrNo|Trk Rep No|Truck No    |GrossWt|'

    WRITE :  text-017 NO-GAP.         "#EC NOTEXT "'Tare Wt |Net Wt  |'
    WRITE : text-018 NO-GAP. "#EC NOTEXT "InvGross|Wt Diff  |  Weighment Exit Remarks

    IF i_invno EQ ''.
      WRITE : 116 text-019 NO-GAP.        "#EC NOTEXT "| PP Entry  |Fun
    ELSE.
      WRITE : 105 text-020 NO-GAP. "#EC NOTEXT "|Fun| Exinv    |Inv Qty
    ENDIF.
    WRITE : 132 sy-vline NO-GAP.
    WRITE : 133 'WB IN |',                                  "#EC NOTEXT
            140 'WB OUT |'.                                 "#EC NOTEXT

  ENDIF.



  IF p_purp EQ 'R'.
    WRITE : / sy-vline.
    WRITE : text-021 NO-GAP. "#EC NOTEXT "SrNo|Trk Rep No|Truck No       |Tare  Wt|
    WRITE : text-022 NO-GAP.            "#EC NOTEXT "Gross Wt|Net Wt  |
    WRITE : text-023  NO-GAP.  "'Chl Qty |Wt Diff  |       Weighment Exit Remarks '
    WRITE : 116 text-024 NO-GAP.                "| PP Entry  |Fun
    WRITE : 132 sy-vline NO-GAP.
    WRITE : 133 'WB IN |',                                  "#EC NOTEXT
            140 'WB OUT |'.                                 "#EC NOTEXT
  ENDIF.
  WRITE : 150 '     TRANSP NAME              |' .
  WRITE : 180 text-025 .  "|     Order Number  |

  WRITE : / sy-uline(200).


END-OF-PAGE.
  WRITE : / sy-uline(200).
  WRITE : / text-026 ,' ', sy-datum, ' ', text-027, ' ',sy-uzeit. "Printed on  At



END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  FETCH_DATA_USING_AREA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_data_using_area.

*"""BOC By kalpesh/biswa 01.04.2025 RD2K9A55BR
    TYPES : BEGIN OF lty_ymrrdetl,
            mandt     TYPE mandt,
            area      TYPE yarea,
            report_no TYPE yreport_no,
            ebeln     TYPE zz_ebeln,
            matnr     TYPE matnr,
            recd_qty  TYPE mczugang,
            recd_uom  TYPE co_gmein,
            lfsnr     TYPE lfsnr,
            END OF lty_ymrrdetl,

            BEGIN OF lty_vbrp,
            mandt     TYPE mandt,
            vbeln     TYPE vbeln_vf,
            vgbel     TYPE vgbel,
            werks     TYPE werks_d,
            END OF lty_vbrp,

            BEGIN OF lty_vbrk,
            mandt     TYPE mandt,
            vbeln     TYPE vbeln_vf,
            erzet     TYPE erzet,
            erdat     TYPE erdat,
            END OF lty_vbrk.
    DATA : lt_ymrrdetl   TYPE TABLE OF lty_ymrrdetl,
           lw_ymrrdetl   TYPE lty_ymrrdetl,
           lt_vbrp       TYPE TABLE OF lty_vbrp,
           lt_vbrp_t     TYPE TABLE OF lty_vbrp,
           lw_vbrp       TYPE lty_vbrp,
           lr_vgbel      TYPE RANGE OF vgbel,
           lrw_vgbel     LIKE LINE OF lr_vgbel,
           lt_vbrk       TYPE TABLE OF lty_vbrk,
           lw_vbrk       TYPE lty_vbrk.

  DATA : lr_report  TYPE RANGE OF yreport_no,
         lrw_report LIKE LINE OF lr_report,
         lw_yttstx0002 LIKE LINE OF iyttstx0002,
         lt_yttstx0001_temp LIKE TABLE OF iyttstx0001,
         lw_yttstx0001_temp LIKE LINE OF lt_yttstx0001_temp.
*"""EOC By kalpesh/biswa 01.04.2025 RD2K9A55BR
  CLEAR   : w_t_trucks,w_t_gross,w_t_tare,w_t_net,w_t_inv,w_t_diff.

  SELECT DISTINCT *
  FROM   yttsa
  INTO   CORRESPONDING FIELDS OF TABLE iyttsa
  WHERE  editdt GE s_date-low
  AND    editdt LE w_n_date
  AND    function EQ p_func
  AND    area EQ p_area.
* and    report_no in s_rep.

  DELETE iyttsa WHERE editdt EQ s_date-low AND edittm+0(2) LT '06'.
  DELETE iyttsa WHERE editdt EQ w_n_date AND edittm+0(2) GE '06'.

  IF iyttsa[] IS INITIAL.
    STOP.
  ENDIF.

  IF iyttsa[] IS NOT INITIAL.
    SELECT report_no truck_no
           permit "brilo_005 on 30.08.2018
           spart  "brilo_005 on 30.08.2018
           pp_entr_dt pp_entr_tm area
           transplpt vstel matgr trk_purpos function wb1_tr_wt wb2_tr_wt
           in_wb_no out_wb_no trns_name area trk_purpos vstel loaded_truck_number
           totalqty
           contno
    FROM   yttstx0001
    INTO   CORRESPONDING FIELDS OF TABLE iyttstx0001
    FOR    ALL ENTRIES IN iyttsa
    WHERE  area EQ p_area
    AND    report_no EQ iyttsa-report_no
    AND    matgr IN p_matgr
    AND    trk_purpos EQ p_purp
    AND    vstel IN p_vstel
    AND    transplpt IN p_tplst.
* Added by Sailasuta Das CD : 8076028(Start)
    IF sy-subrc = 0.
      LOOP AT iyttstx0001 ASSIGNING <gfs_iyttstx0001>.
        IF <gfs_iyttstx0001> IS ASSIGNED.
          TRANSLATE <gfs_iyttstx0001>-loaded_truck_number TO UPPER CASE.
          TRANSLATE <gfs_iyttstx0001>-contno TO UPPER CASE.
        ENDIF.
      ENDLOOP.
      IF <gfs_iyttstx0001> IS ASSIGNED.
        UNASSIGN <gfs_iyttstx0001>.
      ENDIF.
      gt_iyttstx0001[] = iyttstx0001[].
      SORT gt_iyttstx0001 BY area report_no.
      DELETE ADJACENT DUPLICATES FROM gt_iyttstx0001 COMPARING area report_no.
      IF NOT gt_iyttstx0001[] IS INITIAL.
        SELECT area
               report_no
               function
               editdt
               edittm
               in_wb_no
               pm_wt
          FROM yttsaext INTO TABLE gt_ttsaext
          FOR ALL ENTRIES IN gt_iyttstx0001
          WHERE area = gt_iyttstx0001-area AND
                report_no = gt_iyttstx0001-report_no AND
                ( function = 'PMN' OR function = 'PMX' ).
        IF sy-subrc = 0.
          SORT gt_ttsaext BY area report_no function editdt DESCENDING edittm DESCENDING.
        ENDIF.
      ENDIF.
    ENDIF.
    SELECT SINGLE name
                  numb
                  active
                  remarks
                  area
      FROM zlog_exec_var INTO gw_log_exec_var
      WHERE name = 'YWBS_PACKAGE_WT' AND
            area = p_area.
    IF sy-subrc NE 0.
      CLEAR : gw_log_exec_var.
    ENDIF.

    gt_iyttstx0001[] = iyttstx0001[].
    SORT gt_iyttstx0001 BY contno.
    DELETE ADJACENT DUPLICATES FROM gt_iyttstx0001 COMPARING contno.
    CLEAR : gt_yttstm0001[].
    IF NOT gt_iyttstx0001[] IS INITIAL.
      SELECT truck_no
             ulw
             rulw_uom
      FROM yttstm0001 INTO TABLE gt_yttstm0001
      FOR ALL ENTRIES IN gt_iyttstx0001
      WHERE truck_no = gt_iyttstx0001-contno."WBN
    ENDIF.
* Added by Sailasuta Das CD : 8076028(End)
  ENDIF.

  IF iyttstx0001[] IS INITIAL.
    STOP.
  ENDIF.
******************Aneesh*******21-07-08****
  IF iyttstx0001[] IS NOT INITIAL.
****BOC - brilo_005 : 30.08.2018
    lt_temp[] = iyttstx0001[].
    SORT lt_temp BY spart.
    DELETE lt_temp WHERE spart IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING spart.
    IF lt_temp IS NOT INITIAL.
      SELECT name numb active area spart
        FROM zlog_exec_var
        INTO TABLE lt_param
        FOR ALL ENTRIES IN lt_temp
        WHERE name = lc_pallet "PALLET_WEIGHT
        AND   active = abap_true
        AND   area = p_area
        AND   spart = lt_temp-spart.
      IF sy-subrc <> 0.
        CLEAR lt_param.
      ENDIF.
    ENDIF.

    SELECT name numb active area spart
       FROM zlog_exec_var
       INTO TABLE lt_param1
       WHERE name = lc_ywbs
       AND   active = abap_true
       AND   area = p_area.
    IF sy-subrc <> 0.
      CLEAR lt_param1.
    ENDIF.

    CLEAR lt_temp.
****EOC*************************
    SELECT report_no dlivry_no posnr mat_code delivery desp_uom dlvry_qty1
           invoice_no invoice_dt invoice_tm ebeln ebelp werks billno
           FROM yttstx0002
           INTO CORRESPONDING FIELDS OF TABLE iyttstx0002
           FOR ALL ENTRIES IN iyttstx0001
           WHERE area EQ p_area
           AND report_no EQ iyttstx0001-report_no.
  ENDIF.
******************Aneesh*******21-07-08****
*"""BOC By kalpesh/biswa 01.04.2025 RD2K9A55BR
  IF iyttstx0002[] IS NOT INITIAL.
    CLEAR : lr_report[].
    LOOP AT iyttstx0002[] INTO lw_yttstx0002.
      lrw_report-sign   = 'I'.
      lrw_report-option = 'EQ'.
      lrw_report-low    = lw_yttstx0002-report_no.
      APPEND lrw_report TO lr_report.
      CLEAR : lrw_report , lw_yttstx0002.
    ENDLOOP.
    sort lr_report by low.
    DELETE ADJACENT DUPLICATES FROM  lr_report COMPARING low.
    DELETE  lr_report where low is INITIAL.
  ENDIF.
  IF iyttstx0001[] IS NOT INITIAL.
    CLEAR : lt_yttstx0001_temp[].
    lt_yttstx0001_temp[] = iyttstx0001[].
    SORT : lt_yttstx0001_temp BY area report_no.
    DELETE ADJACENT DUPLICATES FROM  lt_yttstx0001_temp COMPARING area report_no.
    IF lr_report IS NOT INITIAL.
      DELETE lt_yttstx0001_temp WHERE report_no IN lr_report.
    ENDIF.
  ENDIF.
  IF lt_yttstx0001_temp[] IS NOT INITIAL.
    CLEAR : lt_ymrrdetl[].
    SELECT mandt
           AREA
           report_no
           ebeln
           matnr
           recd_qty
           recd_uom
           lfsnr
          FROM ymrrdetl CLIENT SPECIFIED
          INTO TABLE lt_ymrrdetl
          FOR ALL ENTRIES IN lt_yttstx0001_temp
          WHERE mandt = sy-mandt
          and  area   = lt_yttstx0001_temp-area
          AND  report_no = lt_yttstx0001_temp-report_no
         %_HINTS ORACLE 'INDEX("YMRRDETL""YMRRDETL~Y01")'.
    IF sy-subrc = 0.
      SORT : lt_ymrrdetl BY area report_no.
      LOOP AT lt_ymrrdetl INTO lw_ymrrdetl.
        lrw_vgbel-sign   = 'I'.
        lrw_vgbel-option = 'EQ'.
        lrw_vgbel-low    = lw_ymrrdetl-lfsnr.
        APPEND lrw_vgbel TO lr_vgbel.
        CLEAR : lrw_vgbel , lw_ymrrdetl.
      ENDLOOP.
      SORT : lr_vgbel BY low.
      DELETE ADJACENT DUPLICATES FROM  lr_vgbel COMPARING low.
      DELETE lr_vgbel WHERE low IS INITIAL.
    ENDIF.
    IF lr_vgbel[] IS NOT INITIAL.
      CLEAR : lt_vbrp[].
      SELECT mandt
             vbeln
             vgbel
             werks
        FROM vbrp CLIENT SPECIFIED
        INTO TABLE lt_vbrp
        WHERE mandt = sy-mandt
        AND   vgbel IN lr_vgbel
        %_HINTS ORACLE 'INDEX("VBRP""VBRP~Y01")'.
      IF sy-subrc = 0.
        SORT : lt_vbrp BY vgbel.
        CLEAR : lt_vbrp_t[].
        lt_vbrp_t[] = lt_vbrp[].
        SORT : lt_vbrp_t BY vbeln.
        DELETE ADJACENT DUPLICATES FROM lt_vbrp_t COMPARING vbeln.
        DELETE lt_vbrp_t WHERE vbeln IS INITIAL.
      ENDIF.
    ENDIF.
    IF lt_vbrp_t[] IS NOT INITIAL.
      CLEAR : lt_vbrk[].
      SELECT mandt
             vbeln
             erzet
             erdat
        FROM vbrk CLIENT SPECIFIED
        INTO TABLE lt_vbrk
        FOR ALL ENTRIES IN lt_vbrp_t
        WHERE mandt = sy-mandt
        AND   vbeln = lt_vbrp_t-vbeln.
      IF sy-subrc = 0.
        SORT : lt_vbrk BY vbeln.
      ENDIF.
    ENDIF.
    LOOP AT lt_yttstx0001_temp[] INTO lw_yttstx0001_temp.
      CLEAR : lw_ymrrdetl.
      READ TABLE lt_ymrrdetl[] INTO lw_ymrrdetl with key   area = lw_yttstx0001_temp-area
                                                           report_no = lw_yttstx0001_temp-report_no BINARY SEARCH.
      IF sy-subrc = 0.
        lw_yttstx0002-report_no = lw_ymrrdetl-report_no.
        lw_yttstx0002-dlivry_no = lw_ymrrdetl-ebeln.
        lw_yttstx0002-mat_code  = lw_ymrrdetl-matnr.
        lw_yttstx0002-delivery  = lw_ymrrdetl-lfsnr.
        lw_yttstx0002-desp_uom  = lw_ymrrdetl-recd_uom.
        lw_yttstx0002-dlvry_qty1 = lw_ymrrdetl-recd_qty.
        lw_yttstx0002-ebeln      = lw_ymrrdetl-ebeln.
        CLEAR : lw_vbrp.
        READ TABLE lt_vbrp[] INTO lw_vbrp with key vgbel = lw_ymrrdetl-lfsnr BINARY SEARCH.
        IF sy-subrc = 0.
          lw_yttstx0002-invoice_no = lw_vbrp-vbeln.
          lw_yttstx0002-werks      = lw_vbrp-werks.
          CLEAR : lw_vbrk.
          READ TABLE lt_vbrk[] INTO lw_vbrk with key vbeln = lw_vbrp-vbeln BINARY SEARCH.
          IF sy-subrc = 0.
            lw_yttstx0002-invoice_dt = lw_vbrk-erdat.
            lw_yttstx0002-invoice_tm = lw_vbrk-erzet.
          ENDIF.
        ENDIF.
        APPEND : lw_yttstx0002 to iyttstx0002[].
        CLEAR : lw_yttstx0002.
      ENDIF.
      CLEAR : lw_yttstx0001_temp.
    ENDLOOP.
  ENDIF.
*"""EOC By kalpesh/biswa 01.04.2025 RD2K9A55BR
  IF iyttstx0002[] IS INITIAL.
    STOP.
  ELSE.
    SELECT name numb werks
      FROM zlog_exec_var
      INTO TABLE lt_param2
      WHERE name = lc_ywbs1
      AND   active = abap_true.
    IF sy-subrc <> 0.
      CLEAR lt_param2.
    ELSE.
      SORT lt_param2 BY werks.
    ENDIF.
    " Changed on Dtd : 22.02.2018 BY COL_045
    iyttstx0002_t[] = iyttstx0002[].
    SORT iyttstx0002_t BY billno.
    DELETE ADJACENT DUPLICATES FROM iyttstx0002_t COMPARING billno.
    IF iyttstx0002_t[] IS NOT INITIAL.
      SELECT vbeln  xblnr FROM vbrk
             INTO TABLE git_vbrk
             FOR ALL ENTRIES IN iyttstx0002_t
             WHERE vbeln = iyttstx0002_t-billno.
      IF sy-subrc = 0.
        SORT git_vbrk BY vbeln.
      ENDIF.
    ENDIF.
    " End of Changed on Dtd : 22.02.2018 BY COL_045
  ENDIF.

*  lt_lips_t =
  REFRESH: lt_lips, lt_lips1.
  IF p_purp EQ 'D'.
    UNASSIGN <iyttstx0002>.
    LOOP AT iyttstx0002 ASSIGNING <iyttstx0002>.
      READ TABLE lt_param2 INTO lw_param2 WITH KEY werks = <iyttstx0002>-werks BINARY SEARCH.
      IF <iyttstx0002>-dlivry_no IS INITIAL AND <iyttstx0002>-posnr IS INITIAL AND sy-subrc IS INITIAL.
        <iyttstx0002>-posnr = <iyttstx0002>-ebelp.
        <iyttstx0002>-dlivry_no = <iyttstx0002>-ebeln.
      ENDIF.
      CLEAR lw_param2.
    ENDLOOP.
    LOOP AT iyttstx0002.
      SELECT vbeln posnr vgbel vgpos gewei vrkme ntgew brgew lfimg spart "#EC CI_SEL_NESTED
       FROM   lips
       INTO   CORRESPONDING FIELDS OF ilipsd " select quarry is required within loop.
       WHERE  vbeln EQ iyttstx0002-delivery
*       AND    vgbel EQ iyttstx0002-dlivry_no
*       AND    vgpos EQ iyttstx0002-posnr
       AND    lfimg GT 0.
        COLLECT ilipsd.
      ENDSELECT.
*BOA - brilo_005 24.09.2018
      lw_delv = iyttstx0002-delivery.
      APPEND lw_delv TO lt_delv.
      CLEAR: lw_delv.
*EOA - brilo_005
    ENDLOOP.
  ENDIF.

****BOA - brilo_005 24.09.2018
  REFRESH: lt_pallet.
  IF lt_delv IS NOT INITIAL.
    CALL FUNCTION 'Z_LOG_PALLET_WGHT'
      EXPORTING
        it_delv   = lt_delv
      IMPORTING
        et_pallet = lt_pallet.
  ENDIF.
****EOA - brilo_005

  LOOP AT ilipsd.
    MOVE-CORRESPONDING ilipsd TO ilips.
    COLLECT ilips.
  ENDLOOP.

  IF iyttstx0001[] IS NOT INITIAL.
    REFRESH: iyttstx0001_t, lt_yttstm0001.
    iyttstx0001_t = iyttstx0001[].
    SORT iyttstx0001_t BY truck_no.
    DELETE iyttstx0001_t WHERE truck_no IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM iyttstx0001_t COMPARING truck_no.
    IF NOT iyttstx0001_t IS INITIAL.
      SELECT truck_no ulw rulw_uom
        FROM yttstm0001
        INTO TABLE lt_yttstm0001
        FOR ALL ENTRIES IN iyttstx0001_t
        WHERE truck_no EQ iyttstx0001_t-truck_no.
      IF sy-subrc IS INITIAL.
        SORT lt_yttstm0001 BY truck_no.
      ENDIF.
    ENDIF.

    REFRESH: iyttstx0001_t, lt_yttstm0001_1.
    iyttstx0001_t = iyttstx0001[].
    SORT iyttstx0001_t BY loaded_truck_number.
    DELETE iyttstx0001_t WHERE loaded_truck_number IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM iyttstx0001_t COMPARING loaded_truck_number.
    IF NOT iyttstx0001_t IS INITIAL.
      SELECT truck_no ulw rulw_uom
        FROM yttstm0001
        INTO TABLE lt_yttstm0001_1
        FOR ALL ENTRIES IN iyttstx0001_t
        WHERE truck_no EQ iyttstx0001_t-loaded_truck_number."WBX
      IF sy-subrc IS INITIAL.
        SORT lt_yttstm0001_1 BY truck_no.
      ENDIF.
    ENDIF.

    SELECT *
    FROM   yttsr
    INTO   CORRESPONDING FIELDS OF TABLE iyttsr
    FOR    ALL ENTRIES IN iyttstx0001
    WHERE  area EQ p_area
    AND    report_no EQ iyttstx0001-report_no
    AND   ( function EQ 'WBX' OR function EQ 'WBN' ).
  ENDIF.

  REFRESH : itab_inv.
  CLEAR   : itab_inv.
*  SORT ilips BY vbeln vgbel vgpos.         " sorted for binary search  according to review standards
  SORT ilips BY vbeln .         " sorted for binary search  according to review standards
  SORT iyttsr BY  area report_no function. " sorted for binary search  according to review standards
  LOOP AT iyttstx0001.
    CLEAR itab_det.
    itab_det-area  = iyttstx0001-area.
    itab_det-transplpt = iyttstx0001-transplpt.

    IF p_purp EQ 'D'.
      itab_det-trk_purpos = text-001.
    ELSEIF p_purp EQ 'R'.
      itab_det-trk_purpos = text-002.
    ENDIF.
    itab_det-permit = iyttstx0001-permit. "brilo_005
    itab_det-vstel = iyttstx0001-vstel.
    itab_det-report_no  = iyttstx0001-report_no.
    itab_det-truck_no   = iyttstx0001-truck_no.
    itab_det-function   = iyttstx0001-function.
    itab_det-pp_entr_dt = iyttstx0001-pp_entr_dt.
    itab_det-pp_entr_tm = iyttstx0001-pp_entr_tm.
    itab_det-wb1_tr_wt  = iyttstx0001-wb1_tr_wt.
    itab_det-wb2_tr_wt  = iyttstx0001-wb2_tr_wt.
    itab_det-in_wb_no   = iyttstx0001-in_wb_no.
    itab_det-out_wb_no  = iyttstx0001-out_wb_no.
    itab_det-trns_name = iyttstx0001-trns_name.
    CLEAR: lw_totpal,lw_pallet.
    LOOP AT iyttstx0002 WHERE report_no EQ iyttstx0001-report_no. "#EC CI_NESTED
      itab_det-ebeln = iyttstx0002-ebeln.
****BOA - brilo_005 24.09.2018
      READ TABLE lt_pallet INTO lw_pallet WITH KEY vbeln = iyttstx0002-delivery.
      IF sy-subrc EQ 0.
        lw_totpal = lw_totpal + lw_pallet-pallet_wt.
        CLEAR:lw_pallet.
      ENDIF.
****EOA***********************
      IF p_purp EQ 'R'.
        CASE iyttstx0002-desp_uom.
          WHEN 'MT' OR 'MTS' OR 'TON' OR 'TO' OR 'TO.' OR 'T'.
            iyttstx0002-dlvry_qty1 = iyttstx0002-dlvry_qty1 * 1000.
            itab_det-invoice_qty =
            itab_det-invoice_qty + iyttstx0002-dlvry_qty1.
          WHEN 'KG' OR 'KGS' OR 'KG.'.
            itab_det-invoice_qty =
            itab_det-invoice_qty + iyttstx0002-dlvry_qty1.
        ENDCASE.
      ENDIF.
      IF p_purp EQ 'D' AND iyttstx0002-delivery NE space AND
         iyttstx0001-wb2_tr_wt GT 0.
        CLEAR mara-brgew.
        SELECT SINGLE mtart spart meins brgew ntgew  "#EC CI_SEL_NESTED
        FROM   mara
        INTO   (mara-mtart,mara-spart,mara-meins,mara-brgew,mara-ntgew)
        WHERE  matnr EQ iyttstx0002-mat_code.
        IF sy-subrc EQ 0.
          lw_mtart = mara-mtart.
        ENDIF.
        READ TABLE ilips WITH KEY vbeln = iyttstx0002-delivery
*                                  vgbel = iyttstx0002-dlivry_no
*                                  vgpos = iyttstx0002-posnr
                                   BINARY SEARCH.
        IF sy-subrc EQ 0.              "reak ajay201.
          IF  mara-meins EQ 'LOT' OR mara-meins EQ 'NOS' OR mara-meins EQ 'EA'.
            IF mara-mtart EQ 'ZSCR' AND ( mara-spart EQ '60' OR mara-spart EQ '63' ) AND p_purp EQ 'D' .
              itab_det-invoice_qty =  itab_det-net_wght = itab_det-wb2_tr_wt - itab_det-wb1_tr_wt.
            ENDIF.
          ELSE.
            IF ilips-gewei EQ 'MT'
            OR ilips-gewei EQ 'KM'.

              itab_det-invoice_qty =
              itab_det-invoice_qty +
*               ( ( ilips-lfimg  * mara-brgew ) * 1000 / mara-ntgew )."Commented by PWC_001 CD 326932
                 ( ilips-brgew  * 1000 ) ."Added by PWC_001 CD 326932
            ELSE.
              itab_det-invoice_qty =
*            itab_det-invoice_qty + ( ilips-lfimg  * mara-brgew / mara-ntgew ). "Commented by PWC_001 CD 326932
              itab_det-invoice_qty +  ilips-brgew. "Added by PWC_001 CD 326932
            ENDIF.
          ENDIF.
          itab_inv-report_no   = iyttstx0001-report_no.
          " Start changed on Dtd : 23.02.2018
          READ TABLE git_vbrk INTO gwa_vbrk WITH KEY vbeln = iyttstx0002-billno
          BINARY SEARCH.
          IF sy-subrc = 0.
            itab_inv-invoice_no = gwa_vbrk-xblnr.
          ENDIF.
*          itab_inv-invoice_no  = iyttstx0002-invoice_no.
          IF ilips-vrkme EQ 'MT'
          OR ilips-vrkme EQ 'KM'.
            itab_inv-invoice_qty = ilips-lfimg * 1000.
          ELSE.
            itab_inv-invoice_qty = ilips-lfimg.
          ENDIF.
          APPEND itab_inv.
          CLEAR  itab_inv.
        ENDIF.
      ENDIF.
    ENDLOOP.
    SELECT SUM( brgew ) FROM zdelint INTO w_p_brgew        " #EC NEEDED "#EC CI_SEL_NESTED  "#EC CI_EMPTY_SELECT
    WHERE area EQ p_area
    AND   report_no EQ iyttstx0001-report_no
    GROUP BY area report_no.
    ENDSELECT.                                              "#EC NEEDED
    IF sy-subrc EQ 0.
      itab_det-invoice_qty  = w_p_brgew.
    ENDIF.

*****BOC - brilo_005 30.08.2018
    "Binary searh not used, param table entries
    IF p_purp EQ 'D' AND itab_det-wb2_tr_wt GT 0.
      itab_det-net_wght = itab_det-wb2_tr_wt - itab_det-wb1_tr_wt.
    ENDIF.

    READ TABLE lt_param INTO lw_param WITH KEY area = p_area
                                              spart = iyttstx0001-spart.
    IF sy-subrc = 0.
*      itab_det-net_wght = itab_det-net_wght - itab_det-permit.
      itab_det-net_wght = itab_det-net_wght - lw_totpal.
    ENDIF.

*****EOC - brilo_005 30.08.2018

    IF p_purp EQ 'D'.
      CLEAR: lw_yttstm0001, lw_yttstm0001_1.
      READ TABLE lt_yttstm0001 INTO lw_yttstm0001 WITH KEY truck_no = iyttstx0001-truck_no BINARY SEARCH.
      IF NOT sy-subrc IS INITIAL.
        CLEAR lw_yttstm0001.
      ENDIF.

      READ TABLE lt_yttstm0001_1 INTO lw_yttstm0001_1
      WITH KEY truck_no = iyttstx0001-loaded_truck_number BINARY SEARCH.
      IF NOT sy-subrc IS INITIAL.
        CLEAR lw_yttstm0001_1.
      ENDIF.

      CLEAR: lw_param,gw_pm_wt_wbx,gw_pm_wt_wbn.
      READ TABLE lt_param1 INTO lw_param WITH KEY area = p_area.
      IF ( sy-subrc = 0 AND NOT lw_yttstm0001-ulw IS INITIAL AND
           NOT lw_yttstm0001_1-ulw IS INITIAL AND itab_det-wb2_tr_wt GT 0 AND
           gw_log_exec_var-active NE 'X' ).
        itab_det-net_wght = itab_det-wb2_tr_wt - ( itab_det-wb1_tr_wt - ( lw_yttstm0001-ulw - lw_yttstm0001_1-ulw ) ).
      ELSEIF ( sy-subrc = 0 AND gw_log_exec_var-active = 'X' ).
        READ TABLE gt_ttsaext INTO gw_ttsaext_wbn
        WITH KEY report_no = iyttstx0001-report_no
                 function = 'PMN'.
        IF ( sy-subrc NE 0 OR gw_ttsaext_wbn-pm_wt = '0.000' )."Old Case
          READ TABLE gt_yttstm0001 INTO gw_yttstm0001"Master Records
          WITH KEY truck_no = iyttstx0001-contno.
          IF sy-subrc = 0.
            IF gw_yttstm0001-rulw_uom NE gc_kg_msehi."'KG'.
              CLEAR : lp_cuom.
              lp_ulw = gw_yttstm0001-ulw.lp_uom = gw_yttstm0001-rulw_uom.
              CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
                EXPORTING
                  input                = lp_ulw
                  unit_in              = lp_uom
                  unit_out             = gc_kg_msehi "'KG'
                IMPORTING
                  output               = lp_cuom"Weight in KG
                EXCEPTIONS
                  conversion_not_found = 1
                  division_by_zero     = 2
                  input_invalid        = 3
                  output_invalid       = 4
                  overflow             = 5
                  type_invalid         = 6
                  units_missing        = 7
                  unit_in_not_found    = 8
                  unit_out_not_found   = 9
                  OTHERS               = 10.
              IF sy-subrc = 0.
                gw_pm_wt_wbn = lp_cuom.
              ENDIF.
            ELSE.
              gw_pm_wt_wbn = gw_yttstm0001-ulw.
            ENDIF.
          ENDIF.
          CLEAR gw_in_wb_no_wbn.
          gw_in_wb_no_wbn = gw_ttsaext_wbn-in_wb_no.
        ELSEIF ( sy-subrc = 0 AND gw_ttsaext_wbn-pm_wt NE '0.000' ).
          gw_pm_wt_wbn = gw_ttsaext_wbn-pm_wt.
          CLEAR gw_in_wb_no_wbn.
          gw_in_wb_no_wbn = gw_ttsaext_wbn-in_wb_no.
        ENDIF.

        READ TABLE gt_ttsaext INTO gw_ttsaext_wbx
        WITH KEY report_no = iyttstx0001-report_no
                 function = 'PMX'.
        IF ( sy-subrc NE 0 OR gw_ttsaext_wbx-pm_wt = '0.000' )."Old Case
          READ TABLE lt_yttstm0001_1 INTO lw_yttstm0001_1
          WITH KEY truck_no = iyttstx0001-loaded_truck_number BINARY SEARCH.
          IF sy-subrc = 0.
            IF lw_yttstm0001_1-rulw_uom NE gc_kg_msehi."'KG'.
              CLEAR : lp_cuom.
              lp_ulw = lw_yttstm0001_1-ulw.lp_uom = lw_yttstm0001_1-rulw_uom.
              CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
                EXPORTING
                  input                = lp_ulw
                  unit_in              = lp_uom
                  unit_out             = gc_kg_msehi "'KG'
                IMPORTING
                  output               = lp_cuom"Weight in KG
                EXCEPTIONS
                  conversion_not_found = 1
                  division_by_zero     = 2
                  input_invalid        = 3
                  output_invalid       = 4
                  overflow             = 5
                  type_invalid         = 6
                  units_missing        = 7
                  unit_in_not_found    = 8
                  unit_out_not_found   = 9
                  OTHERS               = 10.
              IF sy-subrc = 0.
                gw_pm_wt_wbx = lp_cuom.
              ENDIF.
            ELSE.
              gw_pm_wt_wbx = lw_yttstm0001_1-ulw.
            ENDIF.
          ENDIF.
          CLEAR gw_in_wb_no_wbx.
          gw_in_wb_no_wbx = gw_ttsaext_wbx-in_wb_no.
        ELSEIF ( sy-subrc = 0 AND gw_ttsaext_wbn-pm_wt NE '0.000' ).
          gw_pm_wt_wbx = gw_ttsaext_wbx-pm_wt.
          CLEAR gw_in_wb_no_wbx.
          gw_in_wb_no_wbx = gw_ttsaext_wbx-in_wb_no.
        ENDIF.
        IF ( gw_pm_wt_wbn GT '0.000' AND gw_pm_wt_wbx GT '0.000' ).
          itab_det-net_wght = itab_det-wb2_tr_wt -
           ( itab_det-wb1_tr_wt - ( gw_pm_wt_wbn - gw_pm_wt_wbx ) ).
        ELSE.
          itab_det-net_wght = ( itab_det-wb2_tr_wt - itab_det-wb1_tr_wt ).
        ENDIF.

* BEGIN: Cursor Generated Code
* Calculate Tare Weight and Packaging Weight using new class-based logic
        DATA: lo_calculator TYPE REF TO lcl_weight_calculator,
              lv_is_new_logic TYPE abap_bool,
              lw_weight_data TYPE lty_weight_data,
              lw_calculated TYPE lty_calculated_weights,
              lv_error_occurred TYPE abap_bool,
              lv_error_message TYPE string.

        " Create calculator instance
        CREATE OBJECT lo_calculator.

        " Prepare weight data structure
        lw_weight_data-report_no = iyttstx0001-report_no.
        lw_weight_data-wb1_tr_wt = iyttstx0001-wb1_tr_wt.
        lw_weight_data-totalqty = iyttstx0001-totalqty.

        " Check if new logic should be applied
        lv_is_new_logic = lo_calculator->is_new_logic_active( 
          iv_area_code = p_area ).

        " Calculate weights based on activation status
        IF lv_is_new_logic = abap_true.
          " Use new logic
          lo_calculator->calculate_weights_new(
            EXPORTING is_weight_data = lw_weight_data
            IMPORTING es_calculated = lw_calculated
                      ev_error_occurred = lv_error_occurred
                      ev_error_message = lv_error_message ).

          " Handle errors if any
          IF lv_error_occurred = abap_true.
            " Log error message (display as warning)
            MESSAGE lv_error_message TYPE 'I' DISPLAY LIKE 'W'.
          ENDIF.

          " Assign calculated packaging weight
          itab_det-packing_mat_wt = lw_calculated-packaging_weight.
        ELSE.
          " Use existing logic
          lo_calculator->calculate_weights_existing(
            EXPORTING is_weight_data = lw_weight_data
            IMPORTING es_calculated = lw_calculated ).

          " Assign calculated packaging weight (existing logic)
          itab_det-packing_mat_wt = lw_calculated-packaging_weight.
        ENDIF.
* END: Cursor Generated Code
        itab_det-pm_wt_wbn = gw_pm_wt_wbn.
        itab_det-pm_wt_wbx = gw_pm_wt_wbx.
        itab_det-pm_wbn = iyttstx0001-contno.
        itab_det-pm_wbx = iyttstx0001-loaded_truck_number.
        itab_det-wbnumber_pmn = gw_in_wb_no_wbn.
        itab_det-wbnumber_pmx = gw_in_wb_no_wbx.

      ENDIF.

    ENDIF.

    IF p_purp EQ 'R' AND itab_det-wb2_tr_wt GT 0.
      itab_det-net_wght = itab_det-wb1_tr_wt - itab_det-wb2_tr_wt.
    ENDIF.

    itab_det-diff = itab_det-net_wght - itab_det-invoice_qty.

    READ TABLE iyttsr WITH KEY area = p_area
                              report_no = iyttstx0001-report_no
                              function = 'WBX' BINARY SEARCH.
    IF sy-subrc EQ 0.
      itab_det-remarks = iyttsr-text.
    ENDIF.

    READ TABLE iyttsr WITH KEY area = p_area
                              report_no = iyttstx0001-report_no
                              function = 'WBN' BINARY SEARCH.
    IF sy-subrc EQ 0.
      itab_det-wbnremarks = iyttsr-text.
    ENDIF.

    APPEND itab_det.

    w_t_trucks = w_t_trucks + 1.
    w_t_gross  = w_t_gross  + itab_det-wb2_tr_wt.
    w_t_tare   = w_t_tare   + itab_det-wb1_tr_wt.
    w_t_net    = w_t_net    + itab_det-net_wght.
    w_t_inv    = w_t_inv    + itab_det-invoice_qty.
    w_t_diff   = w_t_diff   + itab_det-diff.

  ENDLOOP.

ENDFORM.                               " FETCH_DATA_USING_AREA
*&---------------------------------------------------------------------*
*&      Form  WRITE_TO_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_to_list.

  SORT itab_det BY report_no truck_no.

  CLEAR : w_sr_no.

  LOOP AT itab_det.
    w_sr_no = w_sr_no + 1.
    CLEAR w_dt_tm.
    CONCATENATE itab_det-pp_entr_dt+6(2) '/' itab_det-pp_entr_dt+4(2)
     '-' itab_det-pp_entr_tm+0(2) ':' itab_det-pp_entr_tm+2(2) INTO
     w_dt_tm.
    WRITE :  / sy-vline.
    WRITE : (04) w_sr_no NO-SIGN RIGHT-JUSTIFIED NO-GAP,
                sy-vline NO-GAP,
            (10) itab_det-report_no NO-SIGN RIGHT-JUSTIFIED NO-GAP,
                sy-vline NO-GAP,
            (15) itab_det-truck_no NO-GAP,
                sy-vline NO-GAP,
            (08) itab_det-wb2_tr_wt NO-SIGN DECIMALS 0 NO-GAP,
                sy-vline NO-GAP,
            (08) itab_det-wb1_tr_wt NO-SIGN DECIMALS 0 NO-GAP,
                sy-vline NO-GAP,
            (08) itab_det-net_wght NO-SIGN DECIMALS 0 NO-GAP,
                sy-vline NO-GAP,
            (08) itab_det-invoice_qty NO-SIGN DECIMALS 0 NO-GAP,
                sy-vline NO-GAP,
            (09) itab_det-diff DECIMALS 0 NO-GAP,
                sy-vline NO-GAP.
    IF i_invno EQ 'X' AND  p_purp EQ 'D'.
      WRITE : (24) itab_det-remarks NO-GAP,
                  sy-vline NO-GAP,
              (03) itab_det-function NO-GAP,
                  sy-vline NO-GAP.
      wlincnt = 0.
      LOOP AT itab_inv WHERE report_no EQ itab_det-report_no. "#EC CI_NESTED
        wlincnt = wlincnt + 1.
        IF wlincnt GT 1.
          WRITE : 132 sy-vline.
          WRITE : / sy-vline,
                  7 sy-vline,
                 18 sy-vline,
                 34 sy-vline,
                 43 sy-vline,
                 52 sy-vline,
                 61 sy-vline,
                 70 sy-vline,
                 80 sy-vline,
                105 sy-vline,
                109 sy-vline.
        ENDIF.
        WRITE : 110 itab_inv-invoice_no(14) NO-SIGN  NO-GAP,
                    sy-vline NO-GAP,
                 (10) itab_inv-invoice_qty NO-SIGN DECIMALS 0 NO-GAP.
      ENDLOOP.
      IF wlincnt EQ 0.
        WRITE : 124 sy-vline.
      ENDIF.
    ELSE.
      WRITE : (35) itab_det-remarks NO-GAP,
                   sy-vline NO-GAP,
              (11) w_dt_tm NO-GAP,
                   sy-vline NO-GAP,
              (03) itab_det-function NO-GAP.

    ENDIF.
    WRITE : 132 sy-vline,
            134 itab_det-in_wb_no,
            139 sy-vline,
            141 itab_det-out_wb_no,
            147 sy-vline,
            150 itab_det-trns_name,
            180 sy-vline,
            190 itab_det-ebeln,
            200 sy-vline.
  ENDLOOP.

  WRITE : / sy-uline(200).

  WRITE : / sy-vline.
  IF i_invno EQ 'X' AND  p_purp EQ 'D'.
  ELSE.
    WRITE :     'Total Trucks :'(010), w_t_trucks NO-SIGN NO-GAP,
                '    ', sy-vline NO-GAP,
            (8) w_t_gross NO-SIGN DECIMALS 0 NO-GAP,
                sy-vline NO-GAP,
            (8) w_t_tare NO-SIGN DECIMALS 0 NO-GAP,
                sy-vline NO-GAP,
            (8) w_t_net NO-SIGN DECIMALS 0 NO-GAP,
                sy-vline NO-GAP,
            (8) w_t_inv NO-SIGN DECIMALS 0 NO-GAP,
                sy-vline NO-GAP,
            (9) w_t_diff DECIMALS 0 NO-GAP,
                sy-vline NO-GAP.

  ENDIF.
  WRITE : 147 sy-vline.
  WRITE : 180 sy-vline.
  WRITE : 200 sy-vline.

  WRITE :  / sy-uline(200).
  WRITE : / '* All weights are in KGS only'(011).
ENDFORM.                               " WRITE_TO_LIST

*&---------------------------------------------------------------------*
*&      Form  PRINT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_data.
  PERFORM field_to_itab.
  PERFORM set_field-cat.
  PERFORM create_layout.
  PERFORM call_alv.
ENDFORM.                    " PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  SET_FIELD-CAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_field-cat.                                      "#EC FD_HYPHEN
  CLEAR alv_fldcat_t.
  REFRESH alv_fldcat_t.
  v_repid = sy-repid.

  PERFORM create_catalog  USING '' 'ITAB_FINAL'.

ENDFORM.                    " SET_FIELD-CAT





*&---------------------------------------------------------------------*
*&      Form  CALL_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_alv.
  lw_excluding-fcode = '&ABC'.
  APPEND lw_excluding TO lt_excluding.
  CLEAR lw_excluding.
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = 'YSYR1006'
      it_fieldcat        = alv_fldcat_t
      it_events          = alv_slis_t_event
      i_save             = 'A'
      is_variant         = gw_speclayout "Added as per UI Guidelines by AYN_007
      it_excluding       = lt_excluding
    TABLES
      t_outtab           = itab_final
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



ENDFORM.                    " CALL_ALV

*&---------------------------------------------------------------------*
*&      Form  FIELD_TO_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CREATE_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_layout.

**** top of page

  alv_slis_alv_event-name = 'TOP_OF_PAGE'.
  alv_slis_alv_event-form = 'PAGE_HEADER'.
  APPEND alv_slis_alv_event TO alv_slis_t_event.
  CLEAR : alv_slis_alv_event.

  alv_slis_alv_event-name = 'END_OF_LIST'.
  alv_slis_alv_event-form = 'ENDOFLIST'.
  APPEND alv_slis_alv_event TO alv_slis_t_event.
  CLEAR : alv_slis_alv_event.

ENDFORM.                    " CREATE_LAYOUT



*---------------------------------------------------------------------*
*       FORM PAGE_HEADER                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*

*************Aneesh*****22-07-08********
FORM page_header.                                           "#EC CALLED
  WRITE : /29  'W E I G H - B R I D G E   S U M M A R Y'.
  SKIP 2.
  WRITE : /  'Area           :'(003), p_area.
  WRITE : /  'Truck Purpos   :'(004).
  IF p_purp EQ 'D'.
    WRITE 'Despatch'(001).
  ELSEIF p_purp EQ 'R'.
    WRITE 'Receipt'(002).
  ENDIF.

  WRITE : /  'Trans Pl Point :'(005), p_tplst-low, '-', p_tplst-high.
  WRITE : /  'Shipping Point :'(006), p_vstel-low, '-', p_vstel-high.
  DESCRIBE TABLE itab_final LINES tot.

  WRITE : / 'Total Trucks :'(010) , tot.


  IF s_date-high IS INITIAL.
    WRITE : /  'Date           :'(007), s_date-low.
  ELSE.
    WRITE : /  'Period         :'(008), s_date-low, ' To ', s_date-high.
  ENDIF.

  WRITE : 110  'Page : '(009), (4) sy-pagno.             "#EC TEXT_DIFF

ENDFORM.                    " ALV_TOP_OF_PAGE

*************Aneesh*****22-07-08********

*---------------------------------------------------------------------*
*       FORM ENDOFLIST                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*

*************Aneesh*****22-07-08********

FORM endoflist.                                             "#EC CALLED
  WRITE : / '* All weights are in KGS only'(011).
ENDFORM.                    "endoflist
*************Aneesh*****22-07-08********


*&---------------------------------------------------------------------*
*&      Form  CREATE_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1750   text
*      -->P_1751   text
*----------------------------------------------------------------------*
FORM create_catalog USING    value(p_1750)                  "#EC NEEDED
                             value(p_1751).             "#EC PF_NO_TYPE
*  BREAK-POINT.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = v_repid
      i_internal_tabname     = p_1751
      i_inclname             = 'YSYR1006TOP'
    CHANGING
      ct_fieldcat            = alv_fldcat_t
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
* Added by Sailasuta Das CD : 8076028(Start)
*  BREAK-POINT.
  alv_fldcat_s-col_pos = '17'.
  alv_fldcat_s-ddictxt = 'L'.
  alv_fldcat_s-seltext_s = 'Packing Mat. Wt'.
  alv_fldcat_s-seltext_m = 'Packing Mat. Wt'.
  alv_fldcat_s-seltext_l = 'Packing Mat. Wt'.
  alv_fldcat_s-fieldname = 'PACKING_MAT_WT'.
  alv_fldcat_s-ref_fieldname = 'WB1_TR_WT'.
  alv_fldcat_s-tabname   = 'ITAB_FINAL'.
  alv_fldcat_s-outputlen = '20'.
  alv_fldcat_s-datatype = 'QUAN'.
  alv_fldcat_s-inttype = 'P'.
  APPEND alv_fldcat_s TO alv_fldcat_t.

  alv_fldcat_s-col_pos = '18'.
  alv_fldcat_s-ddictxt = 'L'.
  alv_fldcat_s-seltext_s = 'PM Wt. WBN'.
  alv_fldcat_s-seltext_m = 'PM Wt. WBN'.
  alv_fldcat_s-seltext_l = 'PM Wt. WBN'.
  alv_fldcat_s-fieldname = 'PM_WT_WBN'.
  alv_fldcat_s-ref_fieldname = 'WB1_TR_WT'.
  alv_fldcat_s-tabname   = 'ITAB_FINAL'.
  alv_fldcat_s-outputlen = '20'.
  alv_fldcat_s-datatype = 'QUAN'.
  alv_fldcat_s-inttype = 'P'.
  APPEND alv_fldcat_s TO alv_fldcat_t.

  alv_fldcat_s-col_pos = '19'.
  alv_fldcat_s-ddictxt = 'L'.
  alv_fldcat_s-seltext_s = 'PM Wt. WBX'.
  alv_fldcat_s-seltext_m = 'PM Wt. WBX'.
  alv_fldcat_s-seltext_l = 'PM Wt. WBX'.
  alv_fldcat_s-fieldname = 'PM_WT_WBX'.
  alv_fldcat_s-ref_fieldname = 'WB1_TR_WT'.
  alv_fldcat_s-tabname   = 'ITAB_FINAL'.
  alv_fldcat_s-outputlen = '20'.
  alv_fldcat_s-datatype = 'QUAN'.
  alv_fldcat_s-inttype = 'P'.
  APPEND alv_fldcat_s TO alv_fldcat_t.

  alv_fldcat_s-col_pos = '20'.
  alv_fldcat_s-ddictxt = 'L'.
  alv_fldcat_s-seltext_s = 'WBN-Prime Mover'.
  alv_fldcat_s-seltext_m = 'WBN-Prime Mover'.
  alv_fldcat_s-seltext_l = 'WBN-Prime Mover'.
  alv_fldcat_s-fieldname = 'PM_WBN'.
  alv_fldcat_s-tabname   = 'ITAB_FINAL'.
  alv_fldcat_s-outputlen = '15'.
  APPEND alv_fldcat_s TO alv_fldcat_t.

  alv_fldcat_s-col_pos = '21'.
  alv_fldcat_s-ddictxt = 'L'.
  alv_fldcat_s-seltext_s = 'WBX-Prime Mover'.
  alv_fldcat_s-seltext_m = 'WBX-Prime Mover'.
  alv_fldcat_s-seltext_l = 'WBX-Prime Mover'.
  alv_fldcat_s-fieldname = 'PM_WBX'.
  alv_fldcat_s-tabname   = 'ITAB_FINAL'.
  alv_fldcat_s-outputlen = '15'.
  APPEND alv_fldcat_s TO alv_fldcat_t.
* Added by Sailasuta Das CD : 8076028(End)

  alv_fldcat_s-col_pos = '22'.
  alv_fldcat_s-ddictxt = 'L'.
  alv_fldcat_s-seltext_s = 'PM In'.
  alv_fldcat_s-seltext_m = 'PM In'.
  alv_fldcat_s-seltext_l = 'PM In'.
  alv_fldcat_s-fieldname = 'WBNUMBER_PMN'.
  alv_fldcat_s-tabname   = 'ITAB_FINAL'.
  alv_fldcat_s-outputlen = '1'.
  APPEND alv_fldcat_s TO alv_fldcat_t.

  alv_fldcat_s-col_pos = '23'.
  alv_fldcat_s-ddictxt = 'L'.
  alv_fldcat_s-seltext_s = 'PM Out'.
  alv_fldcat_s-seltext_m = 'PM Out'.
  alv_fldcat_s-seltext_l = 'PM Out'.
  alv_fldcat_s-fieldname = 'WBNUMBER_PMX'.
  alv_fldcat_s-tabname   = 'ITAB_FINAL'.
  alv_fldcat_s-outputlen = '1'.
  APPEND alv_fldcat_s TO alv_fldcat_t.



  LOOP AT alv_fldcat_t INTO alv_fldcat_s.

    PERFORM hdr_change USING :
                   'SR_NO' text-028,"'Truck Sr.No.',                  "#EC NOTEXT
                   'TRK_REPORT_NO' text-029,"'Trk Report No',         "#EC NOTEXT
                   'TRUCK_NO' text-030,"'Truck No',                   "#EC NOTEXT
**                   'TARE_WT' 'Gross Weight',                "#EC NOTEXT "Commented by Anuja dtd.29-04-2013
**                   'GROSS_WT' 'Tare Weight',                "#EC NOTEXT "Commented by Anuja dtd.29-04-2013
                   'TARE_WT' text-031,"'Tare Weight', "#EC NOTEXT "Added by Anuja dtd.29-04-2013
                   'GROSS_WT' text-032,"'Gross Weight', "#EC NOTEXT "Added by Anuja dtd.29-04-2013
                    'NET_WT' text-033,"'Net Weight',                  "#EC NOTEXT
                    'CHL_QTY' text-034,"'Chl Qty',                    "#EC NOTEXT
                    'WT_DIFF' text-035,"'Wt Difference',              "#EC NOTEXT
                    'WBNREMARKS' text-036,"'WBN Remarks',             "#EC NOTEXT
                    'WEIGHMENT_EXIT_REMARKS' text-037,"'Weighment Exit Remarks', "#EC NOTEXT
                    'PP_ENTRY' text-038,"'PP Entry',                  "#EC NOTEXT
                    'FUNCTION' text-039,"'Function',                  "#EC NOTEXT
                    'WB_IN' 'WB IN',                        "#EC NOTEXT
                    'WB_OUT' 'WB OUT',                      "#EC NOTEXT
                    'ORDER_NO' 'ORDER NO'.                  "#EC NOTEXT
  ENDLOOP.
*  BREAK-POINT.
ENDFORM.                    " CREATE_CATALOG

*&---------------------------------------------------------------------*
*&      Form  HDR_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2127   text
*      -->P_2128   text
*----------------------------------------------------------------------*
FORM hdr_change USING    value(p_2127)
                         value(p_2128).                 "#EC PF_NO_TYPE
  PERFORM clear_fld.                                    "#EC PF_NO_TYPE
  IF alv_fldcat_s-fieldname = p_2127.
    alv_fldcat_s-ddictxt = 'L'.
    alv_fldcat_s-seltext_s =
    alv_fldcat_s-seltext_m =
    alv_fldcat_s-seltext_l = p_2128.
    MODIFY alv_fldcat_t FROM alv_fldcat_s.              "#EC LOOP_INDEX
  ENDIF.


ENDFORM.                    " HDR_CHANGE

*&---------------------------------------------------------------------*
*&      Form  FIELD_TO_ITAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM field_to_itab.
*************Aneesh*****23-07-08********
  SORT itab_det BY report_no truck_no.
  CLEAR : w_sr_no.

  LOOP AT itab_det.

    w_sr_no = w_sr_no + 1.

    itab_final-sr_no = w_sr_no.
    itab_final-trk_report_no = itab_det-report_no.
    itab_final-truck_no  = itab_det-truck_no.
    IF p_purp EQ 'D'.                            " changed by pwc_016 27.10.2015
      itab_final-tare_wt = itab_det-wb1_tr_wt.
      itab_final-gross_wt = itab_det-wb2_tr_wt.
    ELSE.
      itab_final-tare_wt = itab_det-wb2_tr_wt.
      itab_final-gross_wt = itab_det-wb1_tr_wt.
    ENDIF.
    itab_final-net_wt = itab_det-net_wght.
    itab_final-chl_qty = itab_det-invoice_qty.
    itab_final-wt_diff = itab_det-diff.
    itab_final-weighment_exit_remarks = itab_det-remarks.
    itab_final-wbnremarks = itab_det-wbnremarks.
    itab_final-pp_entry = itab_det-pp_entr_dt.
    itab_final-function = itab_det-function .
    itab_final-wb_in = itab_det-in_wb_no.
    itab_final-wb_out = itab_det-out_wb_no.
    itab_final-trnsp_name = itab_det-trns_name.
    itab_final-order_no = itab_det-ebeln.
* Added by Sailasuta Das CD : 8076028(Start)
    itab_final-packing_mat_wt = itab_det-packing_mat_wt.
    itab_final-pm_wt_wbn = itab_det-pm_wt_wbn.
    itab_final-pm_wt_wbx = itab_det-pm_wt_wbx.
* Added by Sailasuta Das CD : 8076028(End)

* Added by Sailasuta Das CD : 8076029(Start)
    itab_final-pm_wbn = itab_det-pm_wbn.
    itab_final-pm_wbx = itab_det-pm_wbx.
    itab_final-wbnumber_pmn = itab_det-wbnumber_pmn.
    itab_final-wbnumber_pmx = itab_det-wbnumber_pmx.
* Added by Sailasuta Das CD : 8076029(End)
    APPEND itab_final.

  ENDLOOP.

*************Aneesh*****23-07-08********

ENDFORM.                    " FIELD_TO_ITAB

*&---------------------------------------------------------------------*
*&      Form  CLEAR_FLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_fld.
  CLEAR: alv_fldcat_s-seltext_m,alv_fldcat_s-seltext_s,
  alv_fldcat_s-reptext_ddic.
  CLEAR: alv_fldcat_s-ref_fieldname,alv_fldcat_s-ref_tabname.

ENDFORM.                    " CLEAR_FLD
*&---------------------------------------------------------------------*
*&      Form  AUTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM auth .
*  DATA: lw_werks  TYPE werks.
*
*  SELECT SINGLE werks FROM yarpl CLIENT SPECIFIED INTO lw_werks
*                                  WHERE mandt =  sy-mandt AND
*                                         area =  p_area.    "#EC WARNOK
*
*  AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
*           ID 'ACTVT' FIELD '03'
*           ID 'WERKS' FIELD lw_werks.
*  IF sy-subrc NE 0.
*    MESSAGE e044(/rgcs/vatmsg01).
*  ENDIF.
*ENDFORM.                    " AUTH