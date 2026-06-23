# QA Cases - EPROC00117 Financial Evaluation GI

## Coverage Matrix
| Case ID | Covers | Type | Preconditions | Steps | Expected Result |
|---|---|---|---|---|---|
| QA-001 | R1 | Happy | User has C0 corporate page access; case exists. | POST `/epl-sele-c0-financial-list`, then POST `/epl-info-c0-financial-business` with `applicationNo` and `isQuery=false`. | Option endpoint returns currency/options; info returns EPRO envelope with `financialList` and `ratios`. |
| QA-002 | R1 | Error | Request body omits `applicationNo` or `isQuery`. | POST info endpoint. | Backend returns controlled validation error such as `E102`; no DB mutation occurs. |
| QA-003 | R2 | Happy | Persisted `TB_FINANCIAL_EVALUATION_GI` rows exist and GI source statement rows are unavailable for the case. | POST info endpoint with `isQuery=true`. | `ratios` comes from persisted ratio rows ordered by `DATA_SEQ`; no partial recompute write occurs. |
| QA-004 | R2 | Edge | GI Balance, Income, or Cashflow source list is missing and no persisted fallback is applicable. | POST info endpoint. | Response returns an empty `ratios` array or controlled no-data error; it never returns null, partially written ratio rows, or an unhandled exception. |
| QA-005 | R3 | Happy | GI source rows have valid yearly data. | POST info endpoint with `isQuery=true`, then with `isQuery=false`. | Complete source rows take precedence in both calls; ratios include expected suffixes (`%`, `x`, `N/A`, `-`), fit 12-character DB fields, and generated rows are written to `TB_FINANCIAL_EVALUATION_GI`. |
| QA-006 | R3 | Edge | AP turnover, inventory turnover, or previous-period denominator is zero. | POST info endpoint with source rows causing zero denominators. | Result uses documented `N/A` behavior and does not divide by zero; exact AP-days disposition remains in RP29. |
| QA-007 | R4 | Happy | Case has borrower/business financial source data. | POST info endpoint. | `financialList` includes borrower identifiers, main-borrower flag, sequence, income/expense/debt fields, and DSR-related fields. |
| QA-008 | R4 | Edge | Payload attempts to change DSR currency against policy. | POST save endpoint with altered currency data. | Backend policy result is deterministic and auditable; unresolved currency policy is tracked in RP32. |
| QA-009 | R5 | Happy | Existing financial list exists; ratio rows may also exist from the info branch. | POST `/epl-save-c0-financial-business` with `isFinish=false`, current DTO aggregate DSR fields, and no client-submitted ratio-row array. | Business financial rows for the case are deleted and replaced; GI ratio rows are not accepted from the payload; checkpoint becomes unfinished `"Y"`; transaction commits once. |
| QA-010 | R5 | Error | Insert of one detail row or checkpoint update fails after deletes. | POST save endpoint while simulating DB failure. | Business financial/checkpoint changes roll back; response maps to `COMMON_MSG_SAVE_FAIL` or platform equivalent. |
| QA-011 | R6 | Happy | Case has CS attributes, then another case has CU attributes. | Save both cases as Finished. | CS case updates `TB_CHECK_POINTS_CS.EPROC00117="N"`; CU case updates `TB_CHECK_POINTS_CU.EPROC00117="N"`. |
| QA-012 | R7 | Error | User lacks page/API authorization. | POST info and save endpoints. | HTTP 401 or platform authorization envelope is returned; save performs no mutation. |
| QA-013 | R7 | Edge | Save payload contains mismatched detail `applicationNo` or manipulated sequence. | POST save endpoint. | Backend overwrites/rejects untrusted keys and preserves server-authoritative application scope. |
| QA-014 | R8 | Review | Old corporate c0 source evidence is not attached. | Review this bundle against `EPROC0_0117` and `EPROC0_0217`. | Any unverified behavior stays "待 parity 碼驗 / 待 RD 核對"; bundle remains In Review, not Approved. |
| QA-015 | R4 | Edge | Only one DSR/business financial item remains. | Attempt to delete the final item, then attempt to save an empty `financialList`. | FE shows `COMMON_MSG_ONE_DATA` and does not delete; backend rejects empty `financialList` if submitted. |
| QA-016 | R5/R7 | Error | Save request has blank or missing `applicationNo`. | POST `/epl-save-c0-financial-business`. | Backend returns `COMMON_MSG_ERROR_LON` or platform validation equivalent before mutation; no business financial, GI ratio, or checkpoint rows are written. |
| QA-017 | R1 | Error | A query/data-access failure is simulated during option or info retrieval. | POST `/epl-sele-c0-financial-list`, then `/epl-info-c0-financial-business`, each while simulating a query/data-access failure. | Each endpoint returns `MSG_QUERY_FAIL` in the EPRO envelope; no partial ratio write or mutation occurs. |

## Pending QA
| Case ID | Covers | Pending ID | Owner | Required Evidence |
|---|---|---|---|---|
| QA-P01 @PENDING | R1/R8 | RP26 | SA/RD | Compatibility decision for `getTotal`/`getRate` naming and migration inventory. |
| QA-P02 @PENDING | R2 | RP27 | PM/SA/RD | Query-vs-edit mode target behavior approved. |
| QA-P03 @PENDING | R2/R3 | RP28 | SA/RD/QA | Implemented and tested list count plus `DATA_SEQ` alignment validation. |
| QA-P04 @PENDING | R3 | RP29 | SA/RD | AP turnover zero defect disposition. |
| QA-P05 @PENDING | R2 | RP30 | SA/RD | Null-list exposure removed or compatibility documented. |
| QA-P06 @PENDING | R5/R7 | RP31 | Security/RD | Payload key tampering test and service-level guard proof. |
| QA-P07 @PENDING | R4 | RP32 | PM/SA | DSR currency policy approved. |
| QA-P08 @PENDING | R4/R5 | RP33 | SA/RD | Item limit source and value documented. |
| QA-P09 @PENDING | R1/R8 | RP34 | SA/RD | `getExist` compatibility decision. |
| QA-P10 @PENDING | R5 | RP35 | SA/RD/DBA | Table alias reconciliation for `TB_FINANCIAL_EVALUATION_INFO_CORP`. |
| QA-P11 @PENDING | R3 | RP36 | SA/Finance/RD | Growth annualization and rounding mode approved. |
| QA-P12 @PENDING | R7 | RP37 | Security/RD/DBA | Service authorization/audit proof for info/save. |
| QA-P13 @PENDING | R5/R6/R8 | RP38 | PM/SA/RD | 0217 RC old-case save/Finished operability, parent done update, and checkpoint/status behavior approved. |
