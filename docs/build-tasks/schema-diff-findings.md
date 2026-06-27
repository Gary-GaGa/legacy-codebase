# Schema Diff Findings

> Status: Completed on 2026-06-12. This report is SELECT-only recon output; it reports differences and does not judge whether any difference is a defect.

## Extraction checkpoint

- Wrapper rule: used only `<epro-db>\old.cmd` and `<epro-db>\new.cmd`.
- SQL scope: `SELECT owner, COUNT(*) FROM all_tables WHERE table_name LIKE 'TB_%' GROUP BY owner;` and `all_tab_columns` projection only.
- Spool root: `<epro-db>\out\`.
- Spool files:
  - `owners_old.lst`
  - `owners_new.lst`
  - `columns_old_OVSLXLON01.psv`
  - `columns_new_OVSLXLON01.psv`
  - `columns_new_OVSLXLON02.psv`
- Batch checkpoint: all three column spools were parsed by sorted table batches of 20 common tables; no interruption. Completed pairs:
  - `old:OVSLXLON01` vs `new:OVSLXLON01`: 194 common tables.
  - `old:OVSLXLON01` vs `new:OVSLXLON02`: 140 common tables.
  - `new:OVSLXLON01` vs `new:OVSLXLON02`: 140 common tables.

## Owner and count summary

| Extract | Visible owner | TB_% tables | TB_% columns | Notes |
| --- | --- | ---: | ---: | --- |
| `old.cmd` | `OVSLXLON01` | 194 | 2946 | Old-side baseline for this recon. |
| `new.cmd` | `OVSLXLON01` | 194 | 2946 | Same requested owner in new wrapper. |
| `new.cmd` | `OVSLXLON02` | 142 | 2328 | Second new-side owner; differs from 01. |

## Diff counts

| Pair | Table diff left-only/right-only | Column diff | Added | Removed | Type | Precision | Nullable | 01vs02 diff count |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `old:OVSLXLON01` -> `new:OVSLXLON01` | 0 / 0 | 0 | 0 | 0 | 0 | 0 | 0 | n/a |
| `old:OVSLXLON01` -> `new:OVSLXLON02` | 54 / 2 | 71 | 44 | 12 | 2 | 13 | 0 | n/a |
| `new:OVSLXLON01` -> `new:OVSLXLON02` | 54 / 2 | 71 | 44 | 12 | 2 | 13 | 0 | 127 |

Notes:
- `old:OVSLXLON01` and `new:OVSLXLON01` are identical for the requested table/column categories.
- `01vs02 diff count` above counts table-level names plus requested column-level categories: `54 + 2 + 71 = 127`.
- Additional `column_id` order drift exists between `old/new01` and `new02`: 349 columns across 17 shared tables. This is listed separately because the task's requested column categories are add/remove/type/precision/nullable.

## Table-level diff

### `old:OVSLXLON01` -> `new:OVSLXLON02`

Old has, new02 does not have:

```text
TB_APP_LON_PURPOSE_TYPE
TB_CBC_BBL_INFO_TEST
TB_CBC_BBL_TEST
TB_CBC_BGL_INFO_TEST
TB_CBC_BGL_TEST
TB_CBC_GBGL_INFO_TEST
TB_CBC_GBGL_TEST
TB_CBC_SECURITY_TYPE
TB_CHECK_POINT
TB_CHECK_POINT_CORP
TB_CHECK_POINT_CU
TB_CHECK_POINT_IU
TB_CHECK_POINT_RC
TB_CHECK_POINT_RC_CORP
TB_CHECK_POINT_RC_CU
TB_CHECK_POINT_RC_IU
TB_CHECK_POINTS_CS_BK
TB_CHECK_POINTS_CU_BK
TB_CHECK_POINTS_IS_BK
TB_CHECK_POINTS_IU_BK
TB_CO_BORROWER_TEST
TB_COLL_DEMAND_SALE
TB_COLL_INC_VICINITY
TB_COLL_NEI_REPAIR
TB_COLL_REPAIR
TB_COLL_TYPE
TB_COLL_VALUE_TYPE
TB_EMP_INFO
TB_FIN_STATEMENT_MAIN_BK
TB_FUNCTION_BTN_AUTH
TB_GUARANTOR_INFO_TEST
TB_HIGH_EDUCATION
TB_LOAN_CONDITION_INFO_BK
TB_LOAN_CONDITION_LDTC_DATA_KH
TB_LON_PURPOSE_DETAIL
TB_LON_REVISED_ITEM_INFO
TB_LON_SUMMARY_INFO_202407301640
TB_LON_SUMMARY_INFO_20240730BK
TB_MENU_TREE
TB_MENU_TREE_LOG
TB_MESS_RECORD_TEMP
TB_OCCUPATION
TB_RC_CHECK_POINT
TB_REPAYMENT_MODE
TB_SCORE_CARD_PARAM_MAIN
TB_SCORE_CARD_PARAM_SUB
TB_TITLE_DEED
TB_TMP_COMMUNE
TB_TMP_DISTRICT
TB_TMP_PROVINCE
TB_TMP_VILLAGE
TB_TX_TABLE_JOB
TB_TX_TEST
TB_VILLAGE_BK
```

New02 has, old does not have:

```text
TB_PAGE_COLUMN_AUTH_CATEGORY
TB_PAGE_COLUMN_AUTH_DETAIL
```

Table-level notes:
- Checkpoint-related old-only tables include singular `TB_CHECK_POINT*`, RC checkpoint tables, and `_BK` checkpoint backups. New02 keeps only the active plural checkpoint families listed in the focus section.
- Names ending `_TEST`, `_BK`, `TMP`, or containing date suffixes look like test/backup/temp artifacts by naming pattern only; this report does not decide whether they are safe to drop.
- `TB_PAGE_COLUMN_AUTH_CATEGORY` and `TB_PAGE_COLUMN_AUTH_DETAIL` are new02-only authorization/config tables by name; business meaning needs human review.

## Column-level diff

### Added columns in new02

- `TB_CHECK_POINTS_CS.EPROCSU0171`: `-` -> `VARCHAR2`
- `TB_CHECK_POINTS_CU.EPROCSU0140`: `-` -> `VARCHAR2`
- `TB_CHECK_POINTS_IS.EPROISU0171`: `-` -> `VARCHAR2`
- `TB_CO_BORROWER_PERSONAL_INFO.MARITAL_STATUS`: `-` -> `VARCHAR2`
- `TB_COLL_PROVIDER_INFO.MARITAL_STATUS`: `-` -> `VARCHAR2`
- `TB_COMMON_FIELD_OPTIONS.MSG_VER`: `-` -> `VARCHAR2`
- `TB_DOC_LASSUBLST.DOC_SEC_TYPE`: `-` -> `VARCHAR2`
- `TB_DOC_LASSUBLST.LON_TYPE`: `-` -> `VARCHAR2`
- `TB_DOC_PRIMARYLST.DOC_SEC_TYPE`: `-` -> `NVARCHAR2`
- `TB_DOC_PRIMARYLST.LON_TYPE`: `-` -> `NVARCHAR2`
- `TB_DOC_SECONDLST.DOC_SEC_TYPE`: `-` -> `VARCHAR2`
- `TB_DOC_SECONDLST.LON_TYPE`: `-` -> `VARCHAR2`
- `TB_FIN_STATEMENT_MAIN.BORROWER_RISK_1`: `-` -> `VARCHAR2`
- `TB_FIN_STATEMENT_MAIN.BORROWER_RISK_2`: `-` -> `VARCHAR2`
- `TB_FIN_STATEMENT_MAIN.BUSINESS_RISK_1`: `-` -> `VARCHAR2`
- `TB_FIN_STATEMENT_MAIN.BUSINESS_RISK_2`: `-` -> `VARCHAR2`
- `TB_FIN_STATEMENT_MAIN.FINANCIAL_SITUATION_1`: `-` -> `VARCHAR2`
- `TB_FIN_STATEMENT_MAIN.FINANCIAL_SITUATION_2`: `-` -> `VARCHAR2`
- `TB_FIN_STATEMENT_MAIN.LOAN_REPAYMENT_1`: `-` -> `VARCHAR2`
- `TB_FIN_STATEMENT_MAIN.LOAN_REPAYMENT_2`: `-` -> `VARCHAR2`
- `TB_FIN_STATEMENT_MAIN.SUMMARY_1`: `-` -> `VARCHAR2`
- `TB_FIN_STATEMENT_MAIN.SUMMARY_2`: `-` -> `VARCHAR2`
- `TB_FINANCIAL_EVALUATION_FI.CET_ONE_CAPITAL`: `-` -> `VARCHAR2`
- `TB_FINANCIAL_EVALUATION_FI.TOTAL_CAPITAL`: `-` -> `VARCHAR2`
- `TB_GUARANTOR_INFO.MARITAL_STATUS`: `-` -> `VARCHAR2`
- `TB_IND_SCRCARD.AO_MARITAL_STATUS_CODE`: `-` -> `VARCHAR2`
- `TB_IND_SCRCARD.AO_MARITAL_STATUS_SCR`: `-` -> `NUMBER(3,0)`
- `TB_IND_SCRCARD.CR_MARITAL_STATUS_CODE`: `-` -> `VARCHAR2`
- `TB_IND_SCRCARD.CR_MARITAL_STATUS_SCR`: `-` -> `NUMBER(3,0)`
- `TB_LOAN_CONDITION_DETAIL.SOFR`: `-` -> `NUMBER(4,2)`
- `TB_LOAN_CONDITION_INFO.CON_TYPE`: `-` -> `VARCHAR2`
- `TB_LOAN_CONDITION_LDTC_DATA.CAN_EDIT`: `-` -> `VARCHAR2`
- `TB_LOAN_CONDITION_LDTC_DATA.LON_SECURE`: `-` -> `VARCHAR2`
- `TB_LOAN_CONDITION_LDTC_DATA.LON_TYPE_CODE`: `-` -> `VARCHAR2`
- `TB_LOAN_CONDITION_LDTC_DATA.MTG_PRODUCT_CODE`: `-` -> `VARCHAR2`
- `TB_LOAN_CONDITION_LDTC_DATA.PRODUCT_CODE`: `-` -> `VARCHAR2`
- `TB_LOAN_CONDITION_LDTC_INFO.CAN_EDIT`: `-` -> `VARCHAR2`
- `TB_LOAN_CONDITION_LDTC_INFO.LON_SECURE`: `-` -> `VARCHAR2`
- `TB_LOAN_CONDITION_LDTC_INFO.LON_TYPE_CODE`: `-` -> `VARCHAR2`
- `TB_LOAN_CONDITION_LDTC_INFO.MTG_PRODUCT_CODE`: `-` -> `VARCHAR2`
- `TB_LOAN_CONDITION_LDTC_INFO.PRODUCT_CODE`: `-` -> `VARCHAR2`
- `TB_LON_SUMMARY_INFO.PROJECT_CODE`: `-` -> `VARCHAR2`
- `TB_MAIN_BORROWER_PERSONAL_INFO.MARITAL_STATUS`: `-` -> `VARCHAR2`
- `TB_UPLOAD_FILE_PTH.FILE_SEQ`: `-` -> `VARCHAR2`

### Removed columns in new02

- `TB_CO_BORROWER_PERSONAL_INFO.MARIAL_STATUS`: `VARCHAR2` -> `-`
- `TB_COLL_LTV.DEVIATION_MEMO_CLOB`: `CLOB` -> `-`
- `TB_COLL_PROVIDER_INFO.MARIAL_STATUS`: `VARCHAR2` -> `-`
- `TB_DOC_LASSUBLST.IS_NEW`: `VARCHAR2` -> `-`
- `TB_FIN_STATEMENT_MAIN.HIGHLIGHT`: `LONG` -> `-`
- `TB_GUARANTOR_INFO.MARIAL_STATUS`: `VARCHAR2` -> `-`
- `TB_IND_SCRCARD.AO_MARIAL_STATUS_CODE`: `VARCHAR2` -> `-`
- `TB_IND_SCRCARD.AO_MARIAL_STATUS_SCR`: `NUMBER(3,0)` -> `-`
- `TB_IND_SCRCARD.CR_MARIAL_STATUS_CODE`: `VARCHAR2` -> `-`
- `TB_IND_SCRCARD.CR_MARIAL_STATUS_SCR`: `NUMBER(3,0)` -> `-`
- `TB_LOAN_CONDITION_INFO.DEVIATION_MEMO_CLOB`: `CLOB` -> `-`
- `TB_MAIN_BORROWER_PERSONAL_INFO.MARIAL_STATUS`: `VARCHAR2` -> `-`

### Type changes

- `TB_COLL_LTV.DEVIATION_MEMO`: `LONG` -> `VARCHAR2`
- `TB_LOAN_CONDITION_INFO.DEVIATION_MEMO`: `LONG` -> `VARCHAR2`

### Precision changes

- `TB_FINANCIAL_EVALUATION_INFO.DEBT_SERVICE_RATIO`: `NUMBER(11,2)` -> `NUMBER(38,2)`
- `TB_FINANCIAL_EVALUATION_INFO.DEBT_TO_NET_INCOME_RATIO`: `NUMBER(11,2)` -> `NUMBER(38,2)`
- 🔴 `TB_FINANCIAL_EVALUATION_INFO.EXPENSE_DEBT_M_AMT`: `NUMBER(28,2)` -> `NUMBER(20,2)`
- 🔴 `TB_FINANCIAL_EVALUATION_INFO.EXPENSE_M_AMT`: `NUMBER(28,2)` -> `NUMBER(20,2)`
- 🔴 `TB_FINANCIAL_EVALUATION_INFO.INCOME_FIX_AMT`: `NUMBER(28,2)` -> `NUMBER(20,2)`
- 🔴 `TB_FINANCIAL_EVALUATION_INFO.INCOME_NONFIX_AMT`: `NUMBER(28,2)` -> `NUMBER(20,2)`
- 🔴 `TB_FINANCIAL_EVALUATION_INFO.M_EST_INSTALLMENT_AMT`: `NUMBER(28,2)` -> `NUMBER(20,2)`
- 🔴 `TB_FINANCIAL_EVALUATION_INFO.M_EXIST_INSTALLMENT_AMT`: `NUMBER(28,2)` -> `NUMBER(20,2)`
- `TB_FINANCIAL_EVALUATION_INFO.MON_EXPENDITURE_RATIO`: `NUMBER(11,2)` -> `NUMBER(38,2)`
- 🔴 `TB_FINANCIAL_EVALUATION_INFO.TOTAL_DEBIT_BAL_AMT`: `NUMBER(19,2)` -> `NUMBER(20,2)`
- `TB_FINANCIAL_EVALUATION_INFO.TOTAL_DEBT_RATIO`: `NUMBER(11,2)` -> `NUMBER(38,2)`
- `TB_FINANCIAL_EVALUATION_INFO.TOTAL_REMAINING_CASH_RATIO`: `NUMBER(11,2)` -> `NUMBER(38,2)`
- `TB_LOAN_CONDITION_DETAIL.FIX_RATE`: `NUMBER(10,6)` -> `NUMBER(4,2)`

### Nullable changes

- None found in the requested comparison.

## New owner 01 vs 02

- `new:OVSLXLON01` is identical to `old:OVSLXLON01` for requested table/column categories.
- Therefore `new:OVSLXLON01` -> `new:OVSLXLON02` has the same requested diff set as `old:OVSLXLON01` -> `new:OVSLXLON02`.
- Requested-category 01vs02 count: 127.
- Supplemental column-order drift: 349 `column_id` changes across 17 shared tables.
- Largest column-order drift groups:
  - `TB_MAIN_BORROWER_PERSONAL_INFO`: 43 columns.
  - `TB_CO_BORROWER_PERSONAL_INFO`: 40 columns.
  - `TB_CO_BORROWER_FAMILY_INFO`: 39 columns.
  - `TB_MAIN_BORROWER_FAMILY_INFO`: 38 columns.
  - `TB_COLL_INFO`: 31 columns.
  - `TB_MAIN_BORROWER_INFO_CORP`: 29 columns.
  - `TB_CO_BORROWER_INFO_CORP`: 27 columns.
  - `TB_GUARANTOR_INFO_CORP`: 25 columns.
  - `TB_CO_BORROWER_WORK_INFO`: 22 columns.
  - `TB_MAIN_BORROWER_WORK_INFO`: 21 columns.

## Focus checklist

### Checkpoint tables

| Extract | Checkpoint tables |
| --- | --- |
| `old:OVSLXLON01` | `TB_CHECK_POINT`, `TB_CHECK_POINT_CORP`, `TB_CHECK_POINT_CU`, `TB_CHECK_POINT_IU`, `TB_CHECK_POINT_RC`, `TB_CHECK_POINT_RC_CORP`, `TB_CHECK_POINT_RC_CU`, `TB_CHECK_POINT_RC_IU`, `TB_CHECK_POINTS_CS`, `TB_CHECK_POINTS_CS_BK`, `TB_CHECK_POINTS_CU`, `TB_CHECK_POINTS_CU_BK`, `TB_CHECK_POINTS_IS`, `TB_CHECK_POINTS_IS_BK`, `TB_CHECK_POINTS_IU`, `TB_CHECK_POINTS_IU_BK`, `TB_RC_CHECK_POINT` |
| `new:OVSLXLON01` | Same as `old:OVSLXLON01`. |
| `new:OVSLXLON02` | `TB_CHECK_POINTS_CS`, `TB_CHECK_POINTS_CU`, `TB_CHECK_POINTS_IS`, `TB_CHECK_POINTS_IU` |

Column diff inside retained new02 checkpoint tables:
- `TB_CHECK_POINTS_CS.EPROCSU0171`: `-` -> `VARCHAR2`
- `TB_CHECK_POINTS_CU.EPROCSU0140`: `-` -> `VARCHAR2`
- `TB_CHECK_POINTS_IS.EPROISU0171`: `-` -> `VARCHAR2`

### `TB_LON_SUMMARY_INFO`

- `old/new01` contain `HOUSING_PROJECT_CODE`; `new02` also contains `HOUSING_PROJECT_CODE`.
- `new02` adds:
  - `TB_LON_SUMMARY_INFO.PROJECT_CODE`: `-` -> `VARCHAR2`
- No other requested-category diff was found in `TB_LON_SUMMARY_INFO`.

### `TB_BRANCH_PROFILE`

- `T24_COMPANY` exists in all three extracts.
- Requested-category diff: none.
- Supplemental column-order drift:
  - `TB_BRANCH_PROFILE.T24_DEPT_CODE`: `column_id 8` -> `9`
  - `TB_BRANCH_PROFILE.T24_BRANCH_CODE`: `column_id 9` -> `8`

### `TB_COMMON_FIELD_OPTIONS`

| Extract | Columns |
| --- | --- |
| `old:OVSLXLON01` | `SYS_CODE`, `MSG_CODE`, `MSG_OPTION`, `MSG_SER_NO`, `LANG_KEY`, `UPD_EMP_NO`, `UPD_EMP_ID`, `UPD_EMP_NAME`, `UPD_DATE`, `IS_SHOW` |
| `new:OVSLXLON01` | Same as `old:OVSLXLON01`. |
| `new:OVSLXLON02` | Same as `old:OVSLXLON01` plus `MSG_VER`. |

- Observed diff:
  - `TB_COMMON_FIELD_OPTIONS.MSG_VER`: `-` -> `VARCHAR2`
- The expected `SYSTEM/FIELD_NAME` shape was not observed in `all_tab_columns` for `TB_COMMON_FIELD_OPTIONS` in these three extracts; do not treat it as verified from this recon.

### `TB_DISBUR_*` and `TB_EXCHANGE_RATE`

- Present in all three extracts:
  - `TB_DISBUR_COLL`
  - `TB_DISBUR_DATE`
  - `TB_DISBUR_OTHER_COLL`
  - `TB_EXCHANGE_RATE`
- Requested-category diff: none.
- Numeric precision verified in `new:OVSLXLON02`:
  - `TB_DISBUR_COLL.COLL_DATA_SEQ`: `NUMBER(3,0)`
  - `TB_DISBUR_COLL.INSURANCE_AMOUNT`: `NUMBER(17,2)`
  - `TB_DISBUR_COLL.PRICE_PROPERTY`: `NUMBER(17,2)`
  - `TB_DISBUR_COLL.PRICE_LAND`: `NUMBER(17,2)`
  - `TB_DISBUR_COLL.SUG_VAL`: `NUMBER(17,2)`
  - `TB_DISBUR_COLL.BUILT_WIDTH`: `NUMBER(17,2)`
  - `TB_DISBUR_COLL.BUILD_AREA`: `NUMBER(17,2)`
  - `TB_DISBUR_COLL.LAND_AREA`: `NUMBER(17,2)`
  - `TB_DISBUR_DATE.DISBURSEMENT_AMOUNT`: `NUMBER(17,2)`
  - `TB_DISBUR_DATE.LAW_FIRM_AMOUNT`: `NUMBER(17,2)`
  - `TB_DISBUR_DATE.FACILITY_FEE`: `NUMBER(17,2)`
  - `TB_DISBUR_DATE.REFINANCING_FEE`: `NUMBER(17,2)`
  - `TB_DISBUR_DATE.EX_RATE_BUY`: `NUMBER(17,2)`
  - `TB_DISBUR_DATE.EX_RATE_SELL`: `NUMBER(17,2)`
  - `TB_DISBUR_DATE.DES_REP_DAY`: `NUMBER(2,0)`
  - `TB_DISBUR_DATE.LAW_FIRM_AMOUNT_01`: `NUMBER(17,2)`
  - `TB_DISBUR_DATE.LAW_FIRM_AMOUNT_02`: `NUMBER(17,2)`
  - `TB_DISBUR_DATE.LAW_FIRM_AMOUNT_03`: `NUMBER(17,2)`
  - `TB_DISBUR_DATE.LAW_FIRM_AMOUNT_90`: `NUMBER(17,2)`
  - `TB_DISBUR_OTHER_COLL.OTHER_COLL_DATA_SEQ`: `NUMBER(3,0)`
  - `TB_DISBUR_OTHER_COLL.OTHER_PRICE_PROPERTY`: `NUMBER(17,2)`
  - `TB_DISBUR_OTHER_COLL.OTHER_PRICE_LAND`: `NUMBER(17,2)`
  - `TB_DISBUR_OTHER_COLL.OTHER_SUG_VAL`: `NUMBER(17,2)`
  - `TB_DISBUR_OTHER_COLL.OTHER_BUILT_WIDTH`: `NUMBER(17,2)`
  - `TB_DISBUR_OTHER_COLL.OTHER_BUILD_AREA`: `NUMBER(17,2)`
  - `TB_DISBUR_OTHER_COLL.OTHER_LAND_AREA`: `NUMBER(17,2)`
  - `TB_EXCHANGE_RATE.EX_RATE_BUY`: `NUMBER(17,4)`
  - `TB_EXCHANGE_RATE.EX_RATE_SELL`: `NUMBER(17,4)`

## Minimal review queue

- Review 7 red-marked amount precision changes in `TB_FINANCIAL_EVALUATION_INFO`.
- Review whether `new02` should intentionally omit the 54 old/new01-only tables, especially non-obvious reference/config tables without `_BK`, `_TEST`, or `TMP` naming.
- Review `TB_PAGE_COLUMN_AUTH_CATEGORY` and `TB_PAGE_COLUMN_AUTH_DETAIL` as new02-only tables.
- Review checkpoint consolidation: old/new01 have singular, RC, active plural, and backup checkpoint tables; new02 has only active plural CS/CU/IS/IU tables.
- Review 349 supplemental column-order changes if any export, positional mapping, or `SELECT *` dependency still exists.
