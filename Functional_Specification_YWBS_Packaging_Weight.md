# Function Specification: YWBS Report - Tare Weight and Packaging Weight Display

## Description
This function specification describes the modification to report **YWBS (Program: YSYR1006)** to correctly display **Tare Weight (WBN)** and **Packaging Material Weight** separately. The change implements conditional logic that activates only when a specific parameter is maintained in the control table **ZLOG_EXEC_VAR**, ensuring backward compatibility with existing functionality.

The modification addresses the business requirement for clear separation of tare weight and packaging weight in reporting, which is critical for audit and compliance purposes. The new logic does not alter historical data storage but changes how the data is calculated and displayed in the report.

---

## Inputs

| Field Name | Type | Required | Constraints | Validation Rules |
|------------|------|----------|-------------|------------------|
| AREA_CODE | CHAR | Yes | Maximum 10 characters | Must exist in ZLOG_EXEC_VAR table |
| Packaging_Weight | CHAR | Conditional | Parameter name in ZLOG_EXEC_VAR | Must be maintained with ACTIVE = 'X' |
| Reporting Number | CHAR | Yes | As per existing report logic | Must exist in YTTSTX001 table |
| Selection Screen Parameters | Various | As per existing report | As per existing report validation | As per existing report validation |

### Input Sources
- **Selection Screen**: User input parameters (existing YWBS selection screen)
- **Database Table YTTSTX001**: Contains weight data fields (WB1_TR_WT, TOTALQTY)
- **Database Table ZLOG_EXEC_VAR**: Control table for feature activation

---

## Output

| Field Name | Type | Description |
|------------|------|-------------|
| Tare Weight (WBN) | DEC | Original vehicle tare weight, displayed separately from packaging weight |
| Packaging Weight | DEC | Packaging material weight, calculated and displayed separately |
| Other Report Fields | Various | All existing report output fields remain unchanged |

### Output Format
- **Report Display**: ALV Grid or List (as per existing YWBS report format)
- **Field Labels**: 
  - Tare Weight (WBN) - displays original tare weight
  - Packaging Weight - displays packaging material weight only

---

## Behavior

### Activation Logic
1. **Check Feature Activation**:
   - Read table **ZLOG_EXEC_VAR** with:
     - Parameter name = **'Packaging_Weight'**
     - AREA_CODE = Input **AREA_CODE** from selection screen
     - ACTIVE = **'X'**
   - If record found → **New logic applies**
   - If record not found → **Existing logic applies** (backward compatibility)

### New Logic (When Activated)
2. **Read Data from YTTSTX001**:
   - Select record for the reporting number
   - Retrieve fields: **WB1_TR_WT**, **TOTALQTY**

3. **Calculate Tare Weight (WBN)**:
   - If **TOTALQTY** is blank or initial:
     - Tare Weight = **WB1_TR_WT** (assume no packaging weight was added)
   - Else:
     - Tare Weight = **TOTALQTY** (original tare weight before packaging addition)

4. **Calculate Packaging Weight**:
   - Packaging Weight = **WB1_TR_WT - TOTALQTY**
   - If result is negative or zero, set Packaging Weight = 0
   - If TOTALQTY is blank, Packaging Weight = 0

5. **Display Results**:
   - Display Tare Weight in designated column
   - Display Packaging Weight in designated column
   - All other report fields display as per existing logic

### Existing Logic (When Not Activated)
6. **Fallback to Current Behavior**:
   - If feature not activated, execute existing report logic:
     - Tare Weight: If TOTALQTY is blank → use WB1_TR_WT, Else → use TOTALQTY
     - Packaging Weight: WB1_TR_WT – TOTALQTY
   - This ensures zero impact on existing functionality

---

## Errors

| Error Code | Error Message | Trigger Condition |
|------------|---------------|-------------------|
| ERR-001 | Area code not found in control table | AREA_CODE does not exist in ZLOG_EXEC_VAR |
| ERR-002 | Multiple active records found for Packaging_Weight parameter | Duplicate active records in ZLOG_EXEC_VAR for same AREA_CODE |
| ERR-003 | Invalid weight calculation - negative packaging weight detected | WB1_TR_WT < TOTALQTY (data inconsistency) |
| ERR-004 | Reporting number not found | Reporting number does not exist in YTTSTX001 |
| ERR-005 | Database read error | SQL error during table read operations |

### Error Handling
- All errors must be logged for audit purposes
- User-friendly error messages displayed in report output
- Processing continues for other records when individual record errors occur
- Critical errors (database failures) stop report execution

---

## Success

- **Success Condition 1**: Report executes successfully with new logic when feature is activated
- **Success Condition 2**: Report executes successfully with existing logic when feature is not activated
- **Success Condition 3**: Tare Weight and Packaging Weight display correctly separated
- **Success Condition 4**: All existing report functionality remains intact
- **Success Condition 5**: Performance remains within acceptable limits (< 3 seconds for online execution)

### Response Structure
- Report output displays data in ALV format
- Tare Weight column shows original vehicle tare weight
- Packaging Weight column shows only packaging material weight
- All existing columns and calculations remain unchanged

---

## Edge Cases

| Edge Case | Handling Approach |
|-----------|-------------------|
| TOTALQTY is blank and WB1_TR_WT contains packaging weight | Tare Weight = WB1_TR_WT, Packaging Weight = 0 (assume no separation possible) |
| WB1_TR_WT < TOTALQTY (negative packaging weight) | Set Packaging Weight = 0, log warning, display Tare Weight = TOTALQTY |
| WB1_TR_WT = TOTALQTY (no packaging weight) | Tare Weight = TOTALQTY, Packaging Weight = 0 |
| Multiple AREA_CODEs in same report execution | Process each AREA_CODE independently based on its ZLOG_EXEC_VAR setting |
| ZLOG_EXEC_VAR record exists but ACTIVE ≠ 'X' | Treat as feature not activated, use existing logic |
| NULL values in database fields | Treat as blank/initial, apply logic for blank TOTALQTY |
| Historical data with merged weights | Display as-is when feature not activated, attempt separation when activated |

---

## Dependencies

### External Services
- None (pure ABAP report, no external API calls)

### Databases
- **YTTSTX001**: Source table for weight data (WB1_TR_WT, TOTALQTY fields)
- **ZLOG_EXEC_VAR**: Control table for feature activation
  - Fields: Parameter name, AREA_CODE, ACTIVE flag
  - Index: Should have index on (Parameter, AREA_CODE, ACTIVE) for performance

### Events
- None (report execution is user-triggered via transaction code YWBS)

### Other
- **Program YSYR1006**: Main report program to be modified
- **Program SAPMYWRC**: Reference program (for understanding existing data capture logic)
- **Include Programs**: MYWRCTOP, MYWRCI01, MYWRCO01, MYWRCF01 (reference only)

---

## Performance

- **Max Latency**: < 3 seconds for online report execution (single AREA_CODE, typical data volume)
- **Throughput**: Support concurrent execution by multiple users
- **Resource Constraints**: 
  - Database queries must use proper indexes
  - Avoid SELECT in loops (use FOR ALL ENTRIES where applicable)
  - Batch processing: < 5 minutes for large datasets (1000+ records)

### Performance Requirements
- Single database read for ZLOG_EXEC_VAR per AREA_CODE
- Efficient SELECT from YTTSTX001 using proper WHERE conditions
- No performance degradation compared to existing report

---

## Security

- **Authentication**: Standard SAP user authentication (existing)
- **Authorization**: 
  - Transaction code authorization check (existing YWBS authorization)
  - No additional authorization required for new logic
- **PII Masking**: Not applicable (weight data is not PII)
- **Data Encryption**: Standard SAP database encryption (existing)
- **Input Validation**: 
  - Validate AREA_CODE format
  - Validate parameter name format
  - SQL injection prevention (use parameterized queries)

---

## Tests

### Test Case AT-001: Happy Path - Feature Activated
**Description**: Report execution with Packaging_Weight parameter active in ZLOG_EXEC_VAR
**Preconditions**: 
- ZLOG_EXEC_VAR record exists: Parameter='Packaging_Weight', AREA_CODE='TEST01', ACTIVE='X'
- YTTSTX001 record exists: Reporting Number='RN001', WB1_TR_WT=1500, TOTALQTY=1200
**Steps**: Execute report YWBS with AREA_CODE='TEST01', Reporting Number='RN001'
**Expected Result**: 
- Tare Weight = 1200 (TOTALQTY)
- Packaging Weight = 300 (WB1_TR_WT - TOTALQTY)

### Test Case AT-002: Happy Path - Feature Not Activated
**Description**: Report execution without Packaging_Weight parameter in ZLOG_EXEC_VAR
**Preconditions**: 
- No ZLOG_EXEC_VAR record for Packaging_Weight with AREA_CODE='TEST02'
- YTTSTX001 record exists: Reporting Number='RN002', WB1_TR_WT=1500, TOTALQTY=1200
**Steps**: Execute report YWBS with AREA_CODE='TEST02', Reporting Number='RN002'
**Expected Result**: 
- Existing logic applies
- Tare Weight = 1200 (TOTALQTY, as per existing logic)
- Packaging Weight = 300 (WB1_TR_WT - TOTALQTY, as per existing logic)

### Test Case AT-003: Edge Case - TOTALQTY Blank
**Description**: Report execution when TOTALQTY is blank
**Preconditions**: 
- ZLOG_EXEC_VAR record exists: Parameter='Packaging_Weight', AREA_CODE='TEST03', ACTIVE='X'
- YTTSTX001 record exists: Reporting Number='RN003', WB1_TR_WT=1500, TOTALQTY=blank
**Steps**: Execute report YWBS with AREA_CODE='TEST03', Reporting Number='RN003'
**Expected Result**: 
- Tare Weight = 1500 (WB1_TR_WT)
- Packaging Weight = 0

### Test Case AT-004: Edge Case - Negative Packaging Weight
**Description**: Report execution when WB1_TR_WT < TOTALQTY (data inconsistency)
**Preconditions**: 
- ZLOG_EXEC_VAR record exists: Parameter='Packaging_Weight', AREA_CODE='TEST04', ACTIVE='X'
- YTTSTX001 record exists: Reporting Number='RN004', WB1_TR_WT=1000, TOTALQTY=1200
**Steps**: Execute report YWBS with AREA_CODE='TEST04', Reporting Number='RN004'
**Expected Result**: 
- Tare Weight = 1200 (TOTALQTY)
- Packaging Weight = 0 (negative value corrected)
- Warning message logged

### Test Case AT-005: Error Path - AREA_CODE Not Found
**Description**: Report execution with AREA_CODE not in ZLOG_EXEC_VAR
**Preconditions**: 
- No ZLOG_EXEC_VAR record for AREA_CODE='INVALID'
**Steps**: Execute report YWBS with AREA_CODE='INVALID'
**Expected Result**: 
- Feature treated as not activated
- Existing logic applies
- No error (graceful fallback)

### Test Case AT-006: Error Path - Reporting Number Not Found
**Description**: Report execution with non-existent reporting number
**Preconditions**: 
- ZLOG_EXEC_VAR record exists: Parameter='Packaging_Weight', AREA_CODE='TEST06', ACTIVE='X'
- YTTSTX001 record does not exist for Reporting Number='INVALID'
**Steps**: Execute report YWBS with AREA_CODE='TEST06', Reporting Number='INVALID'
**Expected Result**: 
- Error message displayed: "Reporting number not found"
- Report continues processing other records

### Test Case AT-007: Edge Case - Multiple AREA_CODEs
**Description**: Report execution with multiple AREA_CODEs, some with feature active, some without
**Preconditions**: 
- ZLOG_EXEC_VAR: AREA_CODE='AREA1' has Packaging_Weight active, AREA_CODE='AREA2' does not
- YTTSTX001 records exist for both areas
**Steps**: Execute report YWBS with selection including both AREA_CODEs
**Expected Result**: 
- AREA1 records use new logic
- AREA2 records use existing logic
- Both display correctly in same report output

### Test Case AT-008: Performance Test - Large Dataset
**Description**: Report execution with 1000+ records
**Preconditions**: 
- 1000+ records in YTTSTX001 for selected AREA_CODE
- ZLOG_EXEC_VAR record exists with feature active
**Steps**: Execute report YWBS with large dataset
**Expected Result**: 
- Report completes in < 5 minutes
- All records processed correctly
- No performance degradation

---

## Change Impact Summary

### Programs Modified
- **YSYR1006**: Main report program (conditional logic addition)

### Programs Referenced (No Changes)
- **SAPMYWRC**: Reference only (data capture program)
- **MYWRCTOP, MYWRCI01, MYWRCO01, MYWRCF01**: Reference only (include programs)

### Database Tables Used
- **YTTSTX001**: Read-only (no data modification)
- **ZLOG_EXEC_VAR**: Read-only (control table)

### Backward Compatibility
- ✅ **Fully backward compatible**: Existing functionality preserved when feature not activated
- ✅ **No data changes**: Historical data remains unchanged
- ✅ **No impact on data capture**: SAPMYWRC program unchanged

---

## Implementation Notes

1. **Feature Flag Pattern**: Implementation uses feature flag pattern via ZLOG_EXEC_VAR table
2. **Conditional Logic**: New logic only executes when explicitly activated per AREA_CODE
3. **Data Integrity**: Negative packaging weight values are corrected to 0 with logging
4. **Error Handling**: All errors are logged and reported without stopping entire report execution
5. **Performance**: Single database read per AREA_CODE for feature activation check

---

**Document Version**: 1.0  
**Created Date**: [Current Date]  
**Author**: [Author Name]  
**Status**: Draft - Pending Review

