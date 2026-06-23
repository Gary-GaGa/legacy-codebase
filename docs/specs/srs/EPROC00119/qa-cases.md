# QA Cases - EPROC00119 Financial Statement FI

## Coverage Matrix
| Case ID | Covers | Type | Preconditions | Steps | Expected Result |
|---|---|---|---|---|---|
| QA-001 | R1 | Happy | User has C0 corporate page access; current FI data exists. | POST `/epl-sele-c0-financial-statement-comments`, then POST `/epl-info-c0-financial-statement-cmts-fi`. | Options and FI main/balance/income/cashflow lists return in EPRO envelope. |
| QA-002 | R1 | Error | Request misses `applicationNo` or `isQuery`. | POST info endpoint. | Controlled validation/query error such as `COMMON_MSG_ERROR_LON`, `MSG_DATA_NOT_FOUND`, `MSG_OVER_COUNT_LIMIT`, `MSG_QUERY_FAIL`, or platform `E102`; no DB mutation occurs. |
| QA-003 | R2 | Happy | Reference case is eligible and has complete FI main/detail rows. | POST `/epl-quer-c0-financial-statement-cmts-fi` with the reference `applicationNo` and `isQuery`. | Copyable FI data is returned with `MSG_QUERY_SUCCESS`; current case tables/checkpoint remain unchanged. |
| QA-004 | R2 | Error | Reference case is missing or ineligible. | POST query endpoint. | Controlled no-data or application error returns, including `MSG_ERROR_APPLICATION_NO`, `MSG_OVER_COUNT_LIMIT`, `MSG_QUERY_FAIL`, `COMMOM_MSG_NO_DATA`, or `COMMON_MSG_NO_DATA`; no current-case mutation occurs. |
| QA-005 | R3 | Happy | Balance FI payload has valid component fields. | POST `/epl-calc-c0-financial-statement-cmts-fi`. | Calculated balance totals and difference are returned with validation messages; calculation failure maps to `COMMON_MSG_TOTAL_FAIL`. |
| QA-005E | R3 | Edge | Balance, Income, and Cashflow input lists are all empty or have no calculable rows. | Attempt calculation from the page and, if the endpoint is called, POST calc endpoint with empty lists. | UI or backend returns `COMMON_MSG_FIELD_CALCULATED`; no detail rows are persisted. |
| QA-006 | R3 | Edge | End Balance and Cash/Cash Equivalent comparison boundary is exercised. | POST calc endpoint with equal and unequal values. | Behavior follows approved rule; until RP43 closes, discrepancy is recorded and not treated Approved. |
| QA-007 | R4 | Happy | Income FI payload has interest, fee, operating expense, tax, and net income fields. | POST calc endpoint. | Derived FI income values return; malformed numeric inputs are rejected or reported. |
| QA-008 | R5 | Edge | First-year cashflow opening balance and later-year rows are submitted. | POST calc endpoint. | Opening/end balance values follow server-side rule and do not depend on legacy jQuery comparison. |
| QA-009 | R6 | Happy | Existing FI rows exist for the current case. | POST `/epl-save-c0-financial-statement-cmts-fi` with flat fields and `isFinish=false`. | Main/detail rows are fully replaced; `EPROC00119` becomes `"Y"` and `EPROC00120` is seeded `"Y"` in the derived CS/CU checkpoint table; transaction commits once. |
| QA-010 | R6 | Error | Detail insert or checkpoint update fails after delete. | POST save while simulating DB failure. | All main/detail/checkpoint changes roll back; response maps to `COMMON_MSG_SAVE_FAIL`, `COMMON_MSG_ERROR_LON`, or currency-required error. |
| QA-011 | R7 | Happy | Finished payload has all required main/detail fields and aligned lists. | POST save with `isFinish=true`. | Save succeeds and checkpoint becomes complete `"N"`. |
| QA-012 | R7 | Error | Finished payload is missing required company/audit/highlight/detail fields. | POST save with `isFinish=true`. | Backend rejects with controlled validation; no partial DB writes occur. |
| QA-013 | R8 | Happy | One CS and one CU case exist. | Run calc, then save both cases as draft and Finished. | Calc writes only `EPROC00119="Y"`; save writes `EPROC00119` with `"Y"` draft/`"N"` Finished and also writes `EPROC00120="Y"` in the correct CS/CU checkpoint table. |
| QA-014 | R9 | Happy | Persisted main plus all three FI detail groups exist. | POST PDF and Excel endpoints. | Binary Excel returns with `MSG_EXPORT_SUCCESS`; binary PDF returns with `COMMON_MSG_DOWNLOAD_SUCCESS`; no unsaved UI state is used. |
| QA-015 | R9 | Error | Persisted FI data is incomplete or user lacks export authorization. | POST export endpoint. | Controlled `COMMON_MSG_PRINT_FAIL`, `COMMON_MSG_DOWNLOAD_FAIL`, or auth error returns; no raw temp file path leaks. |
| QA-016 | R10 | Review | Corporate refactor baseline is absent. | Review implementation and legacy evidence. | Bundle remains In Review; i0 artifacts are not used to close corporate parity. |

## Pending QA
| Case ID | Covers | Pending ID | Owner | Required Evidence |
|---|---|---|---|---|
| QA-P01 @PENDING | R10 | RP40 | SA/RD | Corporate 00119 refactor baseline or approved code-as-baseline evidence. |
| QA-P02 @PENDING | R1 | RP41 | SA/RD | `inti` alias or migration rewrite decision. |
| QA-P03 @PENDING | R8 | RP42 | PM/SA/RD/DBA | Legacy `EPROI0_0119` checkpoint read defect impact assessment. |
| QA-P04 @PENDING | R3 | RP43 | SA/QA/RD | End Balance versus Cash and Cash Equivalent rule approved. |
| QA-P05 @PENDING | R2 | RP44 | PM/SA | Reference-case eligibility AND/OR decision. |
| QA-P06 @PENDING | R6/R7 | RP45 | SA/RD/QA | List count/date/`DATA_SEQ` validation tests. |
| QA-P07 @PENDING | R10 | RP46 | PM/SA/RD | Editor flag parity decision. |
| QA-P08 @PENDING | R9 | RP47 | SA/RD/QA | FI export template/report/file naming proof. |
| QA-P09 @PENDING | R6/R10 | RP48 | Security/RD | Detail `APPLICATION_NO` tamper test. |
| QA-P10 @PENDING | R7 | RP49 | PM/SA/RD/QA | Save/Finished backend validation tiers implemented and tested. |
| QA-P11 @PENDING | R5 | RP50 | RD/QA | First-year cashflow opening balance behavior validated. |
| QA-P12 @PENDING | R9/R10 | RP51 | Security/RD/DBA | Service authorization, audit, and safe download proof. |
| QA-P13 @PENDING | R6/R10 | RP52 | RD/QA | Save request with distinct `businessRisk` and `borrowerRisk` persists borrower-risk columns from `borrowerRisk`, or documented disposition is approved. |
| QA-P14 @PENDING | R6/DB-D1 | RP53 | RD/DBA/SA | Evidence that `TB_FIN_STATEMENT_MAIN` persistence uses snapshot identity `APPLICATION_NO`, or approved DB/entity disposition for `APPLICATION_NO + CURRENCY`. |
| QA-P15 @PENDING | R6/DB-D6 | RP54 | RD/DBA/SA | Evidence that narrative fields persist to approved `TB_FIN_STATEMENT_MAIN` columns, or db-diff/entity discrepancy is formally dispositioned. |
