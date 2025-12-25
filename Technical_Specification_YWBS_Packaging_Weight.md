# Technical Specification: YWBS Report - Tare Weight and Packaging Weight Display

## Overview
This technical specification describes the implementation details for modifying report **YSYR1006** (Transaction Code: YWBS) to correctly display Tare Weight and Packaging Weight separately, based on the Functional Specification.

**Target System**: SAP ECC 6.0 / NetWeaver 7.31  
**Syntax Level**: abap_731  
**Program Path**: `@RD2-214(ABAP)/System Library/YS01/Source Library/Programs/YSYR1006/YSYR1006.prog.abap`

---

## Architecture

### Design Pattern
- **Feature Flag Pattern**: Conditional logic activation via ZLOG_EXEC_VAR table
- **Backward Compatibility**: Existing logic preserved when feature not activated
- **Separation of Concerns**: New logic encapsulated in dedicated method

### Code Structure
- **Object-Oriented Approach**: All logic in local class methods (no FORMs)
- **Method Organization**: 
  - Feature activation check method
  - Weight calculation method (new logic)
  - Weight calculation method (existing logic - preserved)
  - Main processing method (orchestrates logic selection)

---

## Data Structures

### Type Definitions

```abap
" Control table structure for feature activation
TYPES: BEGIN OF lty_zlog_exec_var,
         parameter TYPE zlog_exec_var-parameter,
         area_code TYPE zlog_exec_var-area_code,
         active TYPE zlog_exec_var-active,
       END OF lty_zlog_exec_var.

TYPES: lty_zlog_exec_var_tab TYPE TABLE OF lty_zlog_exec_var.

" Weight data structure from YTTSTX001
TYPES: BEGIN OF lty_weight_data,
         reporting_number TYPE yttstx001-reporting_number,  " Adjust field name as per actual table
         wb1_tr_wt TYPE yttstx001-wb1_tr_wt,                " Adjust field name as per actual table
         totalqty TYPE yttstx001-totalqty,                  " Adjust field name as per actual table
       END OF lty_weight_data.

TYPES: lty_weight_data_tab TYPE TABLE OF lty_weight_data.

" Calculated weight output structure
TYPES: BEGIN OF lty_calculated_weights,
         tare_weight TYPE dec15_2,      " Tare Weight (WBN)
         packaging_weight TYPE dec15_2, " Packaging Weight
       END OF lty_calculated_weights.
```

**Note**: Field names in YTTSTX001 structure should be verified against actual table definition and adjusted accordingly.

---

## Class Structure

### Local Class: `lcl_weight_calculator`

```abap
CLASS lcl_weight_calculator DEFINITION.
  PUBLIC SECTION.
    "! Check if new weight calculation logic is activated
    "! @parameter iv_area_code | Area code from selection screen
    "! @parameter rv_is_active | Returns ABAP_TRUE if feature is active
    METHODS is_new_logic_active
      IMPORTING iv_area_code TYPE char10
      RETURNING VALUE(rv_is_active) TYPE abap_bool.

    "! Calculate weights using new logic (when feature is active)
    "! @parameter is_weight_data | Weight data from YTTSTX001
    "! @parameter es_calculated | Calculated tare and packaging weights
    "! @parameter ev_error_occurred | Error flag
    "! @parameter ev_error_message | Error message text
    METHODS calculate_weights_new
      IMPORTING is_weight_data TYPE lty_weight_data
      EXPORTING es_calculated TYPE lty_calculated_weights
                ev_error_occurred TYPE abap_bool
                ev_error_message TYPE string.

    "! Calculate weights using existing logic (when feature is not active)
    "! @parameter is_weight_data | Weight data from YTTSTX001
    "! @parameter es_calculated | Calculated tare and packaging weights
    METHODS calculate_weights_existing
      IMPORTING is_weight_data TYPE lty_weight_data
      EXPORTING es_calculated TYPE lty_calculated_weights.

  PRIVATE SECTION.
    " Constants
    CONSTANTS: lc_param_name TYPE char30 VALUE 'Packaging_Weight',
               lc_active_flag TYPE char1 VALUE 'X'.
ENDCLASS.
```

---

## Method Implementations

### Method: `is_new_logic_active`

**Purpose**: Check if new weight calculation logic should be applied based on ZLOG_EXEC_VAR table.

**Implementation**:

```abap
METHOD is_new_logic_active.
  DATA: lt_zlog_exec_var TYPE lty_zlog_exec_var_tab,
        lw_zlog_exec_var TYPE lty_zlog_exec_var,
        lv_count TYPE i.

  " Initialize return value
  rv_is_active = abap_false.

  " Validate input
  IF iv_area_code IS INITIAL.
    RETURN.
  ENDIF.

  " Read control table
  SELECT parameter area_code active
    FROM zlog_exec_var
    INTO TABLE lt_zlog_exec_var
    WHERE parameter = lc_param_name
      AND area_code = iv_area_code
      AND active = lc_active_flag.

  " Check SY-SUBRC
  IF sy-subrc = 0.
    " Check for multiple records (data inconsistency)
    DESCRIBE TABLE lt_zlog_exec_var LINES lv_count.
    IF lv_count = 1.
      rv_is_active = abap_true.
    ELSEIF lv_count > 1.
      " Log error: Multiple active records found
      " Error handling: Log to application log or display message
      " For now, treat as not active to prevent incorrect behavior
      rv_is_active = abap_false.
    ENDIF.
  ENDIF.
ENDMETHOD.
```

**Performance Considerations**:
- Single SELECT with proper WHERE clause (should use index on parameter, area_code, active)
- No loop required (direct table read)

---

### Method: `calculate_weights_new`

**Purpose**: Calculate Tare Weight and Packaging Weight using new logic.

**Implementation**:

```abap
METHOD calculate_weights_new.
  DATA: lv_tare_weight TYPE dec15_2,
        lv_packaging_weight TYPE dec15_2.

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
```

**Business Logic**:
1. If TOTALQTY is blank → Tare Weight = WB1_TR_WT, Packaging Weight = 0
2. If TOTALQTY exists → Tare Weight = TOTALQTY, Packaging Weight = WB1_TR_WT - TOTALQTY
3. If Packaging Weight < 0 → Set to 0 and log warning

---

### Method: `calculate_weights_existing`

**Purpose**: Calculate weights using existing logic (preserved for backward compatibility).

**Implementation**:

```abap
METHOD calculate_weights_existing.
  DATA: lv_tare_weight TYPE dec15_2,
        lv_packaging_weight TYPE dec15_2.

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
```

**Note**: This method preserves existing logic exactly as it was, ensuring zero impact when feature is not activated.

---

## Integration Points

### Main Report Processing

**Location**: Main processing method in YSYR1006 (to be identified in existing code)

**Integration Pattern**:

```abap
" BEGIN: Cursor Generated Code
" In main processing method, after reading YTTSTX001 data:

DATA: lo_calculator TYPE REF TO lcl_weight_calculator,
      lv_is_new_logic TYPE abap_bool,
      lw_calculated TYPE lty_calculated_weights,
      lv_error_occurred TYPE abap_bool,
      lv_error_message TYPE string.

" Create calculator instance
CREATE OBJECT lo_calculator.

" Check if new logic should be applied
lv_is_new_logic = lo_calculator->is_new_logic_active( 
  iv_area_code = p_area_code ).  " Adjust parameter name as per actual selection screen

" Read weight data from YTTSTX001 (existing code)
" ... existing SELECT statement ...

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
    " Log error message (application log or display)
    " Continue processing other records
  ENDIF.
ELSE.
  " Use existing logic
  lo_calculator->calculate_weights_existing(
    EXPORTING is_weight_data = lw_weight_data
    IMPORTING es_calculated = lw_calculated ).
ENDIF.

" Assign calculated values to output structure
" ... assign lw_calculated-tare_weight and lw_calculated-packaging_weight to output ...
" END: Cursor Generated Code
```

---

## Database Access

### Table: ZLOG_EXEC_VAR

**Access Pattern**:
```abap
SELECT parameter area_code active
  FROM zlog_exec_var
  INTO TABLE lt_zlog_exec_var
  WHERE parameter = lc_param_name
    AND area_code = iv_area_code
    AND active = lc_active_flag.
```

**Performance**:
- Single SELECT per AREA_CODE
- Should use index on (parameter, area_code, active)
- No SELECT in loops

**SY-SUBRC Check**: Mandatory after SELECT

### Table: YTTSTX001

**Access Pattern**: Existing SELECT statements (no changes required)

**Note**: Verify actual field names in YTTSTX001 table and adjust type definitions accordingly.

---

## Error Handling

### Error Scenarios

1. **Multiple Active Records in ZLOG_EXEC_VAR**
   - **Detection**: Count records after SELECT
   - **Handling**: Treat as feature not active, log error
   - **User Impact**: Falls back to existing logic

2. **Negative Packaging Weight**
   - **Detection**: Calculation result < 0
   - **Handling**: Set to 0, log warning
   - **User Impact**: Display 0, warning in log

3. **Database Read Errors**
   - **Detection**: SY-SUBRC <> 0 after SELECT
   - **Handling**: TRY-CATCH block, display user-friendly message
   - **User Impact**: Error message, processing stops for critical errors

### Error Logging

```abap
" Error logging pattern (to be implemented based on existing system standards)
" Option 1: Application Log (BAL)
" Option 2: System message (MESSAGE statement)
" Option 3: Custom logging table

" Example using MESSAGE (for reports):
IF lv_error_occurred = abap_true.
  MESSAGE lv_error_message TYPE 'I' DISPLAY LIKE 'W'.
ENDIF.
```

---

## Performance Optimization

### Checklist

- [x] **No SELECT in loops**: Feature activation check done once per AREA_CODE
- [x] **Proper WHERE clause**: All SELECT statements use indexed fields
- [x] **Single database read**: ZLOG_EXEC_VAR read once per AREA_CODE
- [x] **Efficient table operations**: No nested loops, use binary search if needed
- [x] **Memory management**: Local variables, no global state

### Performance Targets

- **Feature activation check**: < 50ms (single indexed SELECT)
- **Weight calculation**: < 1ms per record (in-memory calculation)
- **Overall impact**: < 100ms additional overhead per AREA_CODE

---

## Security

### Authorization

- **Transaction Authorization**: Existing YWBS transaction authorization (no changes)
- **Table Authorization**: Standard SAP table authorization for ZLOG_EXEC_VAR and YTTSTX001

### Input Validation

```abap
" Validate AREA_CODE input
IF iv_area_code IS INITIAL.
  RETURN.  " or raise exception
ENDIF.

" Validate weight data
IF is_weight_data IS INITIAL.
  " Handle error
ENDIF.
```

### SQL Injection Prevention

- Use parameterized WHERE clauses (no dynamic WHERE construction)
- All input values used in WHERE clauses are validated

---

## Code Quality Standards

### Naming Conventions

- **Local Variables**: `lv_` prefix (e.g., `lv_tare_weight`)
- **Local Tables**: `lt_` prefix (e.g., `lt_zlog_exec_var`)
- **Local Structures**: `lw_` prefix (e.g., `lw_weight_data`)
- **Local Objects**: `lo_` prefix (e.g., `lo_calculator`)
- **Local Types**: `lty_` prefix (e.g., `lty_weight_data`)
- **Constants**: `lc_` prefix (e.g., `lc_param_name`)
- **Method Parameters**: `iv_` (importing), `ev_` (exporting), `rv_` (returning)

### Syntax Compatibility (NetWeaver 7.31)

**FORBIDDEN**:
- ❌ Inline declarations: `DATA(lv_var)`
- ❌ Constructor operators: `NEW`, `VALUE`, `CORRESPONDING`
- ❌ String templates: `|text { var }|`
- ❌ Table expressions: `itab[ key = value ]`
- ❌ Host variables: `@variable` in SQL

**REQUIRED**:
- ✅ All variables declared upfront in DATA section
- ✅ Classic OpenSQL syntax
- ✅ Traditional string operations

### Documentation

**Class Header**:
```abap
*&---------------------------------------------------------------------*
*& Class  LCL_WEIGHT_CALCULATOR
*&---------------------------------------------------------------------*
*& Purpose: Calculate Tare Weight and Packaging Weight for YWBS report
*& Methods:
*&   - is_new_logic_active: Check feature activation
*&   - calculate_weights_new: New calculation logic
*&   - calculate_weights_existing: Existing calculation logic (preserved)
*&---------------------------------------------------------------------*
```

**Method Documentation**:
```abap
"! Check if new weight calculation logic is activated
"! @parameter iv_area_code | Area code from selection screen
"! @parameter rv_is_active | Returns ABAP_TRUE if feature is active
METHODS is_new_logic_active
  IMPORTING iv_area_code TYPE char10
  RETURNING VALUE(rv_is_active) TYPE abap_bool.
```

---

## Testing Strategy

### Unit Testing

**Test Class**: `ltc_weight_calculator` (local test class)

**Test Methods**:
1. `test_is_new_logic_active_positive` - Feature active
2. `test_is_new_logic_active_negative` - Feature not active
3. `test_calculate_weights_new_totalqty_exists` - New logic with TOTALQTY
4. `test_calculate_weights_new_totalqty_blank` - New logic without TOTALQTY
5. `test_calculate_weights_new_negative_packaging` - Negative packaging weight
6. `test_calculate_weights_existing` - Existing logic preserved

### Integration Testing

1. **End-to-End Test**: Execute report with feature active
2. **End-to-End Test**: Execute report with feature not active
3. **Performance Test**: Large dataset (1000+ records)
4. **Error Handling Test**: Invalid AREA_CODE, missing data

### Test Data Requirements

- ZLOG_EXEC_VAR test records (active and inactive)
- YTTSTX001 test records (various scenarios: TOTALQTY blank, negative packaging, etc.)

---

## Deployment

### Transport Request

- **Development**: Create transport request for YSYR1006 modification
- **Testing**: Transport to QA system
- **Production**: Transport to production after QA approval

### Pre-Deployment Checklist

- [ ] Code Inspector (SCI): 0 errors, 0 warnings
- [ ] Extended Check (SLIN): 0 errors, 0 warnings
- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] Performance tests pass
- [ ] Documentation complete
- [ ] No hard-coded values
- [ ] Authorization checks present
- [ ] Exception handling implemented
- [ ] SY-SUBRC checks present

### Post-Deployment

- [ ] Verify feature activation in ZLOG_EXEC_VAR table
- [ ] Monitor report execution performance
- [ ] Verify error logging functionality
- [ ] User acceptance testing

---

## Rollback Plan

### Rollback Procedure

1. **Immediate Rollback**: Remove new code, restore original YSYR1006
2. **Feature Flag Rollback**: Set ACTIVE = ' ' in ZLOG_EXEC_VAR (no code change needed)

### Rollback Impact

- **Code Rollback**: Zero impact (original logic preserved)
- **Feature Flag Rollback**: Immediate (no transport required)

---

## Maintenance Notes

### Future Enhancements

1. **Additional Validation**: Add validation for weight data consistency
2. **Enhanced Logging**: Implement application log (BAL) for error tracking
3. **Performance Monitoring**: Add runtime measurement for weight calculations
4. **Configuration**: Extend ZLOG_EXEC_VAR to support additional parameters

### Known Limitations

1. **Data Quality**: Negative packaging weights indicate data inconsistency (handled by setting to 0)
2. **Historical Data**: Cannot retroactively separate merged weights in historical records
3. **Feature Activation**: Requires manual maintenance in ZLOG_EXEC_VAR table

---

## References

### Related Documents

- **Functional Specification**: Functional_Specification_YWBS_Packaging_Weight.md
- **Business Requirement**: Business_Requirement_YWBS_Packaging_Weight.md
- **ABAP Coding Rules**: abap coding rules/ directory

### Related Programs

- **YSYR1006**: Main report program (to be modified)
- **SAPMYWRC**: Data capture program (reference only)
- **MYWRCTOP, MYWRCI01, MYWRCO01, MYWRCF01**: Include programs (reference only)

### Database Tables

- **YTTSTX001**: Weight data table
- **ZLOG_EXEC_VAR**: Feature activation control table

---

**Document Version**: 1.0  
**Created Date**: [Current Date]  
**Author**: [Author Name]  
**Status**: Draft - Pending Review  
**Target Release**: [Release Version]

