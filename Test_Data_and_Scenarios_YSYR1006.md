# Test Data and Test Scenarios for YSYR1006 - YWBS Report

## Overview
This document provides comprehensive test data and test scenarios for testing the YWBS report (YSYR1006) with the new Tare Weight and Packaging Weight calculation logic.

**Program**: YSYR1006  
**Transaction Code**: YWBS  
**Test Date**: [To be filled]  
**Tester**: [To be filled]

---

## Test Data Setup

### 1. Control Table Data (ZLOG_EXEC_VAR)

#### Test Data Set 1: Feature Activated
```abap
" Record 1: Feature Active for Area 'AREA01'
NAME        = 'YWBS_PACKAGE_WT'
NUMB        = '000'
ACTIVE      = 'X'
AREA        = 'AREA01'
REMARKS     = 'Test - Feature Active'

" Record 2: Feature Active for Area 'AREA02' (Alternative Parameter Name)
NAME        = 'Packaging_Weight'
NUMB        = '000'
ACTIVE      = 'X'
AREA        = 'AREA02'
REMARKS     = 'Test - Feature Active with alternative name'
```

#### Test Data Set 2: Feature Not Activated
```abap
" Record 3: Feature Inactive for Area 'AREA03'
NAME        = 'YWBS_PACKAGE_WT'
NUMB        = '000'
ACTIVE      = ' ' (blank)
AREA        = 'AREA03'
REMARKS     = 'Test - Feature Inactive'

" Record 4: No Record for Area 'AREA04'
" (No record exists - should use existing logic)
```

#### Test Data Set 3: Data Inconsistency Scenarios
```abap
" Record 5: Multiple Active Records (Data Inconsistency)
NAME        = 'YWBS_PACKAGE_WT'
NUMB        = '000'
ACTIVE      = 'X'
AREA        = 'AREA05'
REMARKS     = 'Test - Multiple Records 1'

" Record 6: Duplicate Active Record (Data Inconsistency)
NAME        = 'YWBS_PACKAGE_WT'
NUMB        = '001'
ACTIVE      = 'X'
AREA        = 'AREA05'
REMARKS     = 'Test - Multiple Records 2'
```

---

### 2. Master Data (YTTSTX0001 - Truck Transaction Header)

#### Test Data Set 1: Normal Scenario with TOTALQTY
```abap
" Record 1: Normal case - TOTALQTY exists
REPORT_NO   = 'RN001'
TRUCK_NO    = 'TRUCK001'
AREA        = 'AREA01'
WB1_TR_WT   = 1500.000  " Total weight including packaging
WB2_TR_WT   = 2000.000  " Gross weight
TOTALQTY    = 1200.000  " Original tare weight (before packaging)
CONTNO      = 'CONT001'
LOADED_TRUCK_NUMBER = 'TRUCK002'
FUNCTION    = 'WBX'
TRK_PURPOS  = 'D'       " Despatch
PP_ENTR_DT  = '20240115'
PP_ENTR_TM  = '100000'
```

#### Test Data Set 2: TOTALQTY Blank
```abap
" Record 2: TOTALQTY is blank
REPORT_NO   = 'RN002'
TRUCK_NO    = 'TRUCK002'
AREA        = 'AREA01'
WB1_TR_WT   = 1500.000
WB2_TR_WT   = 2000.000
TOTALQTY    = 0.000     " Blank/Zero
CONTNO      = 'CONT002'
LOADED_TRUCK_NUMBER = 'TRUCK003'
FUNCTION    = 'WBX'
TRK_PURPOS  = 'D'
PP_ENTR_DT  = '20240115'
PP_ENTR_TM  = '110000'
```

#### Test Data Set 3: Negative Packaging Weight (Data Inconsistency)
```abap
" Record 3: WB1_TR_WT < TOTALQTY (Data inconsistency)
REPORT_NO   = 'RN003'
TRUCK_NO    = 'TRUCK003'
AREA        = 'AREA01'
WB1_TR_WT   = 1000.000  " Less than TOTALQTY
WB2_TR_WT   = 2000.000
TOTALQTY    = 1200.000  " Greater than WB1_TR_WT
CONTNO      = 'CONT003'
LOADED_TRUCK_NUMBER = 'TRUCK004'
FUNCTION    = 'WBX'
TRK_PURPOS  = 'D'
PP_ENTR_DT  = '20240115'
PP_ENTR_TM  = '120000'
```

#### Test Data Set 4: Equal Weights (No Packaging)
```abap
" Record 4: WB1_TR_WT = TOTALQTY (No packaging weight)
REPORT_NO   = 'RN004'
TRUCK_NO    = 'TRUCK004'
AREA        = 'AREA01'
WB1_TR_WT   = 1500.000
WB2_TR_WT   = 2000.000
TOTALQTY    = 1500.000  " Equal to WB1_TR_WT
CONTNO      = 'CONT004'
LOADED_TRUCK_NUMBER = 'TRUCK005'
FUNCTION    = 'WBX'
TRK_PURPOS  = 'D'
PP_ENTR_DT  = '20240115'
PP_ENTR_TM  = '130000'
```

#### Test Data Set 5: Receipt Scenario
```abap
" Record 5: Receipt (TRK_PURPOS = 'R')
REPORT_NO   = 'RN005'
TRUCK_NO    = 'TRUCK005'
AREA        = 'AREA01'
WB1_TR_WT   = 1500.000
WB2_TR_WT   = 2000.000
TOTALQTY    = 1200.000
CONTNO      = 'CONT005'
LOADED_TRUCK_NUMBER = 'TRUCK006'
FUNCTION    = 'WBX'
TRK_PURPOS  = 'R'       " Receipt
PP_ENTR_DT  = '20240115'
PP_ENTR_TM  = '140000'
```

#### Test Data Set 6: Feature Not Activated Area
```abap
" Record 6: Area without feature activation
REPORT_NO   = 'RN006'
TRUCK_NO    = 'TRUCK006'
AREA        = 'AREA03'  " Feature not active
WB1_TR_WT   = 1500.000
WB2_TR_WT   = 2000.000
TOTALQTY    = 1200.000
CONTNO      = 'CONT006'
LOADED_TRUCK_NUMBER = 'TRUCK007'
FUNCTION    = 'WBX'
TRK_PURPOS  = 'D'
PP_ENTR_DT  = '20240115'
PP_ENTR_TM  = '150000'
```

---

### 3. Supporting Master Data

#### YTTSTX0002 (Truck Transaction Detail)
```abap
" For each REPORT_NO above, create detail records
REPORT_NO   = 'RN001'
DLIVRY_NO   = 'DL001'
POSNR       = '000010'
MAT_CODE    = 'MAT001'
DELIVERY    = 'DEL001'
DESP_UOM    = 'KG'
DLVRY_QTY1  = 500.000
INVOICE_NO  = 'INV001'
INVOICE_DT  = '20240115'
INVOICE_TM  = '100000'
EBELN       = 'PO001'
EBELP       = '00010'
WERKS       = '1000'
```

#### YTTSA (Truck Summary)
```abap
" For each REPORT_NO above
REPORT_NO   = 'RN001'
AREA        = 'AREA01'
FUNCTION    = 'WBX'
EDITDT      = '20240115'
EDITTM      = '100000'
```

#### YTTSAEXT (Truck Summary Extension - for PM weight)
```abap
" For records with PM weight
AREA        = 'AREA01'
REPORT_NO   = 'RN001'
FUNCTION    = 'PMN'
EDITDT      = '20240115'
EDITTM      = '100000'
IN_WB_NO    = 'WB001'
PM_WT       = 50.000

AREA        = 'AREA01'
REPORT_NO   = 'RN001'
FUNCTION    = 'PMX'
EDITDT      = '20240115'
EDITTM      = '100000'
IN_WB_NO    = 'WB002'
PM_WT       = 30.000
```

---

## Test Scenarios

### Test Scenario 1: Happy Path - Feature Activated with TOTALQTY

**Objective**: Verify new logic when feature is active and TOTALQTY exists

**Preconditions**:
- ZLOG_EXEC_VAR: Record exists with NAME='YWBS_PACKAGE_WT', AREA='AREA01', ACTIVE='X'
- YTTSTX0001: REPORT_NO='RN001', WB1_TR_WT=1500, TOTALQTY=1200

**Test Steps**:
1. Execute transaction YWBS
2. Enter selection criteria:
   - Area: AREA01
   - Truck Purpose: D (Despatch)
   - Date: 15.01.2024
   - Material Group: [Valid material group]
3. Execute report

**Expected Results**:
- **Tare Weight (WBN)**: 1200.000 (TOTALQTY value)
- **Packaging Weight**: 300.000 (WB1_TR_WT - TOTALQTY = 1500 - 1200)
- Report displays correctly
- No error messages

**Actual Results**: [To be filled during testing]

**Status**: [ ] Pass / [ ] Fail

---

### Test Scenario 2: Happy Path - Feature Activated with TOTALQTY Blank

**Objective**: Verify new logic when feature is active but TOTALQTY is blank

**Preconditions**:
- ZLOG_EXEC_VAR: Record exists with NAME='YWBS_PACKAGE_WT', AREA='AREA01', ACTIVE='X'
- YTTSTX0001: REPORT_NO='RN002', WB1_TR_WT=1500, TOTALQTY=0

**Test Steps**:
1. Execute transaction YWBS
2. Enter selection criteria:
   - Area: AREA01
   - Truck Purpose: D
   - Date: 15.01.2024
3. Execute report

**Expected Results**:
- **Tare Weight (WBN)**: 1500.000 (WB1_TR_WT value, since TOTALQTY is blank)
- **Packaging Weight**: 0.000 (No packaging weight when TOTALQTY is blank)
- Report displays correctly
- No error messages

**Actual Results**: [To be filled]

**Status**: [ ] Pass / [ ] Fail

---

### Test Scenario 3: Edge Case - Negative Packaging Weight

**Objective**: Verify handling of data inconsistency (WB1_TR_WT < TOTALQTY)

**Preconditions**:
- ZLOG_EXEC_VAR: Record exists with NAME='YWBS_PACKAGE_WT', AREA='AREA01', ACTIVE='X'
- YTTSTX0001: REPORT_NO='RN003', WB1_TR_WT=1000, TOTALQTY=1200

**Test Steps**:
1. Execute transaction YWBS
2. Enter selection criteria:
   - Area: AREA01
   - Truck Purpose: D
   - Date: 15.01.2024
3. Execute report

**Expected Results**:
- **Tare Weight (WBN)**: 1200.000 (TOTALQTY value)
- **Packaging Weight**: 0.000 (Negative value corrected to 0)
- Warning message displayed: "Negative packaging weight detected - set to 0"
- Report continues processing other records

**Actual Results**: [To be filled]

**Status**: [ ] Pass / [ ] Fail

---

### Test Scenario 4: Edge Case - Equal Weights (No Packaging)

**Objective**: Verify handling when WB1_TR_WT = TOTALQTY (no packaging weight)

**Preconditions**:
- ZLOG_EXEC_VAR: Record exists with NAME='YWBS_PACKAGE_WT', AREA='AREA01', ACTIVE='X'
- YTTSTX0001: REPORT_NO='RN004', WB1_TR_WT=1500, TOTALQTY=1500

**Test Steps**:
1. Execute transaction YWBS
2. Enter selection criteria:
   - Area: AREA01
   - Truck Purpose: D
   - Date: 15.01.2024
3. Execute report

**Expected Results**:
- **Tare Weight (WBN)**: 1500.000 (TOTALQTY value)
- **Packaging Weight**: 0.000 (WB1_TR_WT - TOTALQTY = 0)
- Report displays correctly
- No error messages

**Actual Results**: [To be filled]

**Status**: [ ] Pass / [ ] Fail

---

### Test Scenario 5: Backward Compatibility - Feature Not Activated

**Objective**: Verify existing logic when feature is not activated

**Preconditions**:
- ZLOG_EXEC_VAR: No record OR ACTIVE=' ' for AREA='AREA03'
- YTTSTX0001: REPORT_NO='RN006', WB1_TR_WT=1500, TOTALQTY=1200, AREA='AREA03'

**Test Steps**:
1. Execute transaction YWBS
2. Enter selection criteria:
   - Area: AREA03
   - Truck Purpose: D
   - Date: 15.01.2024
3. Execute report

**Expected Results**:
- **Tare Weight**: 
  - If TOTALQTY is blank → WB1_TR_WT (1500)
  - If TOTALQTY exists → TOTALQTY (1200)
- **Packaging Weight**: WB1_TR_WT - TOTALQTY (300)
- Existing logic applies (no new logic)
- Report displays correctly

**Actual Results**: [To be filled]

**Status**: [ ] Pass / [ ] Fail

---

### Test Scenario 6: Alternative Parameter Name

**Objective**: Verify feature activation with alternative parameter name 'Packaging_Weight'

**Preconditions**:
- ZLOG_EXEC_VAR: Record exists with NAME='Packaging_Weight', AREA='AREA02', ACTIVE='X'
- YTTSTX0001: REPORT_NO='RN007', WB1_TR_WT=1500, TOTALQTY=1200, AREA='AREA02'

**Test Steps**:
1. Execute transaction YWBS
2. Enter selection criteria:
   - Area: AREA02
   - Truck Purpose: D
   - Date: 15.01.2024
3. Execute report

**Expected Results**:
- Feature is activated (alternative parameter name recognized)
- **Tare Weight (WBN)**: 1200.000 (TOTALQTY)
- **Packaging Weight**: 300.000 (WB1_TR_WT - TOTALQTY)
- New logic applies
- Report displays correctly

**Actual Results**: [To be filled]

**Status**: [ ] Pass / [ ] Fail

---

### Test Scenario 7: Data Inconsistency - Multiple Active Records

**Objective**: Verify handling when multiple active records exist for same area

**Preconditions**:
- ZLOG_EXEC_VAR: Multiple records with NAME='YWBS_PACKAGE_WT', AREA='AREA05', ACTIVE='X'
- YTTSTX0001: REPORT_NO='RN008', WB1_TR_WT=1500, TOTALQTY=1200, AREA='AREA05'

**Test Steps**:
1. Execute transaction YWBS
2. Enter selection criteria:
   - Area: AREA05
   - Truck Purpose: D
   - Date: 15.01.2024
3. Execute report

**Expected Results**:
- Feature treated as NOT active (multiple records detected)
- Existing logic applies (fallback to prevent incorrect behavior)
- **Tare Weight**: As per existing logic
- **Packaging Weight**: As per existing logic
- No error message (graceful fallback)

**Actual Results**: [To be filled]

**Status**: [ ] Pass / [ ] Fail

---

### Test Scenario 8: Receipt Scenario (TRK_PURPOS = 'R')

**Objective**: Verify logic works for Receipt transactions

**Preconditions**:
- ZLOG_EXEC_VAR: Record exists with NAME='YWBS_PACKAGE_WT', AREA='AREA01', ACTIVE='X'
- YTTSTX0001: REPORT_NO='RN005', WB1_TR_WT=1500, TOTALQTY=1200, TRK_PURPOS='R'

**Test Steps**:
1. Execute transaction YWBS
2. Enter selection criteria:
   - Area: AREA01
   - Truck Purpose: R (Receipt)
   - Date: 15.01.2024
3. Execute report

**Expected Results**:
- **Tare Weight (WBN)**: 1200.000 (TOTALQTY)
- **Packaging Weight**: 300.000 (WB1_TR_WT - TOTALQTY)
- Receipt-specific calculations work correctly
- Report displays correctly

**Actual Results**: [To be filled]

**Status**: [ ] Pass / [ ] Fail

---

### Test Scenario 9: Performance Test - Large Dataset

**Objective**: Verify performance with large dataset

**Preconditions**:
- Create 1000+ records in YTTSTX0001 for AREA01
- ZLOG_EXEC_VAR: Record exists with NAME='YWBS_PACKAGE_WT', AREA='AREA01', ACTIVE='X'

**Test Steps**:
1. Execute transaction YWBS
2. Enter selection criteria:
   - Area: AREA01
   - Truck Purpose: D
   - Date Range: 01.01.2024 to 31.01.2024
3. Execute report
4. Measure execution time

**Expected Results**:
- Report completes in < 5 minutes
- All records processed correctly
- No performance degradation compared to existing report
- Memory usage within acceptable limits

**Actual Results**: [To be filled]

**Status**: [ ] Pass / [ ] Fail

---

### Test Scenario 10: Integration Test - Multiple Areas

**Objective**: Verify different areas use different logic based on activation

**Preconditions**:
- ZLOG_EXEC_VAR: 
  - AREA01: ACTIVE='X' (new logic)
  - AREA03: ACTIVE=' ' (existing logic)
- YTTSTX0001: Records for both areas

**Test Steps**:
1. Execute transaction YWBS
2. Enter selection criteria:
   - Area: [Select both AREA01 and AREA03]
   - Truck Purpose: D
   - Date: 15.01.2024
3. Execute report

**Expected Results**:
- AREA01 records use new logic
- AREA03 records use existing logic
- Both display correctly in same report output
- No conflicts or errors

**Actual Results**: [To be filled]

**Status**: [ ] Pass / [ ] Fail

---

## Test Data Creation Scripts

### SQL Script for Test Data Creation

```sql
-- ZLOG_EXEC_VAR Test Data
INSERT INTO zlog_exec_var VALUES ('YWBS_PACKAGE_WT', '000', 'X', 'AREA01', 'Test - Feature Active');
INSERT INTO zlog_exec_var VALUES ('Packaging_Weight', '000', 'X', 'AREA02', 'Test - Alternative Name');
INSERT INTO zlog_exec_var VALUES ('YWBS_PACKAGE_WT', '000', ' ', 'AREA03', 'Test - Feature Inactive');
INSERT INTO zlog_exec_var VALUES ('YWBS_PACKAGE_WT', '000', 'X', 'AREA05', 'Test - Multiple Records 1');
INSERT INTO zlog_exec_var VALUES ('YWBS_PACKAGE_WT', '001', 'X', 'AREA05', 'Test - Multiple Records 2');

-- YTTSTX0001 Test Data
INSERT INTO yttstx0001 VALUES (
  'RN001', 'TRUCK001', 'AREA01', '1500.000', '2000.000', 
  '1200.000', 'CONT001', 'TRUCK002', 'WBX', 'D', '20240115', '100000'
);
-- ... (Additional INSERT statements for other test records)
```

### ABAP Test Data Creation Program

```abap
*&---------------------------------------------------------------------*
*& Report  ZTEST_YWBS_DATA_CREATION
*&---------------------------------------------------------------------*
*& Purpose: Create test data for YWBS report testing
*&---------------------------------------------------------------------*
REPORT ztest_ywbs_data_creation.

DATA: lv_area TYPE yarea,
      lv_report_no TYPE yreport_no.

" Create ZLOG_EXEC_VAR test data
PERFORM create_zlog_exec_var_data.

" Create YTTSTX0001 test data
PERFORM create_yttstx0001_data.

" Create YTTSTX0002 test data
PERFORM create_yttstx0002_data.

" Create YTTSA test data
PERFORM create_yttsa_data.

FORM create_zlog_exec_var_data.
  DATA: lw_zlog_exec_var TYPE zlog_exec_var.
  
  " Test Data 1: Feature Active
  lw_zlog_exec_var-name = 'YWBS_PACKAGE_WT'.
  lw_zlog_exec_var-numb = '000'.
  lw_zlog_exec_var-active = 'X'.
  lw_zlog_exec_var-area = 'AREA01'.
  lw_zlog_exec_var-remarks = 'Test - Feature Active'.
  MODIFY zlog_exec_var FROM lw_zlog_exec_var.
  
  " Add more test records...
ENDFORM.

FORM create_yttstx0001_data.
  DATA: lw_yttstx0001 TYPE yttstx0001.
  
  " Test Record 1: Normal scenario
  lw_yttstx0001-report_no = 'RN001'.
  lw_yttstx0001-truck_no = 'TRUCK001'.
  lw_yttstx0001-area = 'AREA01'.
  lw_yttstx0001-wb1_tr_wt = '1500.000'.
  lw_yttstx0001-wb2_tr_wt = '2000.000'.
  lw_yttstx0001-totalqty = '1200.000'.
  lw_yttstx0001-contno = 'CONT001'.
  lw_yttstx0001-loaded_truck_number = 'TRUCK002'.
  lw_yttstx0001-function = 'WBX'.
  lw_yttstx0001-trk_purpos = 'D'.
  lw_yttstx0001-pp_entr_dt = '20240115'.
  lw_yttstx0001-pp_entr_tm = '100000'.
  MODIFY yttstx0001 FROM lw_yttstx0001.
  
  " Add more test records...
ENDFORM.

" Additional FORMs for other tables...
```

---

## Test Execution Checklist

### Pre-Test Setup
- [ ] Test data created in development/QA system
- [ ] ZLOG_EXEC_VAR records created
- [ ] YTTSTX0001 records created
- [ ] YTTSTX0002 records created
- [ ] YTTSA records created
- [ ] YTTSAEXT records created (if applicable)
- [ ] Authorization verified for transaction YWBS
- [ ] Test environment ready

### Test Execution
- [ ] Test Scenario 1 executed
- [ ] Test Scenario 2 executed
- [ ] Test Scenario 3 executed
- [ ] Test Scenario 4 executed
- [ ] Test Scenario 5 executed
- [ ] Test Scenario 6 executed
- [ ] Test Scenario 7 executed
- [ ] Test Scenario 8 executed
- [ ] Test Scenario 9 executed
- [ ] Test Scenario 10 executed

### Post-Test
- [ ] Test results documented
- [ ] Defects logged (if any)
- [ ] Test data cleaned up (if required)
- [ ] Test report generated

---

## Expected Calculation Results Summary

| Scenario | AREA | WB1_TR_WT | TOTALQTY | Feature Active | Expected Tare Weight | Expected Packaging Weight |
|----------|------|-----------|-----------|----------------|---------------------|-------------------------|
| 1 | AREA01 | 1500 | 1200 | Yes | 1200 | 300 |
| 2 | AREA01 | 1500 | 0 | Yes | 1500 | 0 |
| 3 | AREA01 | 1000 | 1200 | Yes | 1200 | 0 (corrected) |
| 4 | AREA01 | 1500 | 1500 | Yes | 1500 | 0 |
| 5 | AREA01 | 1500 | 1200 | Yes | 1200 | 300 |
| 6 | AREA03 | 1500 | 1200 | No | 1200* | 300* |
| 7 | AREA05 | 1500 | 1200 | No** | 1200* | 300* |
| 8 | AREA01 | 1500 | 1200 | Yes | 1200 | 300 |

*Existing logic applies  
**Multiple records - treated as not active

---

## Notes

1. **Test Data Cleanup**: After testing, ensure test data is either:
   - Deleted from system
   - Marked clearly as test data
   - Moved to test data repository

2. **Performance Testing**: For performance test (Scenario 9), use realistic data volumes based on production usage patterns.

3. **Authorization**: Ensure test user has proper authorization for:
   - Transaction YWBS
   - Tables: YTTSTX0001, YTTSTX0002, ZLOG_EXEC_VAR

4. **Data Consistency**: Verify that test data maintains referential integrity across related tables.

5. **Regression Testing**: After implementing new logic, verify that existing functionality (when feature is not active) remains unchanged.

---

**Document Version**: 1.0  
**Created Date**: [Current Date]  
**Author**: [Author Name]  
**Status**: Draft - Ready for Review

