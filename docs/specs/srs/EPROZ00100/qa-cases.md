# QA Cases - EPROZ00100 TO DO LIST

> Cases are test-ready. Each non-pending Rn has at least one case. Pending cases keep the skeleton but are not acceptance gates until the owner decision lands.

| ID | covers | Type | Given | When | Then | DB / log assertion |
|---|---|---|---|---|---|---|
| QA-001 | R1 | happy | User with role `001` has stale current application context. | POST `epl-comm-todolist-prompt`. | Response has `isAO=true`, `role=001`, and other flags consistent with role. | Previous session `APPLICATION_NO`/`action` is absent after prompt. |
| QA-002 `@PENDING TBD-002` | R2 | pending | CA/CR redistribution candidate rows exist. | POST `epl-comm-todolist-prompt`. | Behavior follows TBD-002 verdict. | If kept, `TB_LON_SUMMARY_INFO` and `TB_APP_HISTORY` commit/rollback atomically. |
| QA-003 | R3 | happy | Seed current user has cases with `CASE_PROGRESS=01` and excluded statuses. | POST `epl-list-todolist` with `page=1,size=20,langType=en_US`. | Response contains only current-user allowed statuses. | Query result excludes `03,D1,R0305,R0313,R0397`. |
| QA-004 | R4 | edge | Same user/cases support `zh_TW` and `en_US`. | POST `epl-list-todolist` twice, changing only `langType`. | `totalCount` is identical. | SQL/log shows `langType` is not used as data WHERE filter. |
| QA-005 | R5 | happy | One case has corporate borrower name and application date equal to `01/01/1900`. | POST `epl-list-todolist`. | Row uses corporate borrower display and blank application date. | Source row from `TB_LON_SUMMARY_INFO`; display transformation only. |
| QA-006 | R5 | happy | Case has USD and KHR rows in `TB_LOAN_CONDITION_DETAIL.LOAN_AMOUNT NUMBER(17,2)`. | POST `epl-list-todolist`. | Response has expected `usdSumLoanAmount` and `khrSumLoanAmount` preserving two-decimal DB scale without truncation. | Sum by `LOAN_AMOUNT_CURRENCY` matches response exactly at `NUMBER(17,2)` scale. |
| QA-007 | R6 | happy | CAD role `404` has active proxy rows in `TB_EMP_PROXY`. | POST `epl-list-todolist` with CAD filter. | Results include current user and active proxied employees only. | Effective user set equals current employee plus active `EMP_ID` rows where `PROXY_ID=current`. |
| QA-008 | R6 | edge | Corporate and individual CAD rows exist with decision date, approval level, document/register number, borrower name, sales channel, and routable page data. | POST `epl-list-todolist` with `docNo` filter. | Each CAD row returns `decisionDateDisplay`, `approvalLevelDisplay`, `docNo1`, borrower display, `salesChannel`, and `page`; corporate `docNo1` comes from register no and individual uses document conversion. | No invented `DOC_NO` column dependency; mapping follows TBD-004 after verdict and response fields match seeded DB/refactor mapping. |
| QA-009 | R7 | error | CAD role sends no `applicationNo`, `docNo`, `mainBorrowerName`, or full date range. | POST `epl-list-todolist`. | HTTP 400 `INVALID_CAD_QUERY_CONDITION`. | No full-list SQL is executed. |
| QA-010 | R8 | happy | CAD Maker case has `CASE_PROGRESS=21`. | POST `epl-list-todolist`. | Row `page=EPROIS_0910`. | Routing matches legacy matrix. |
| QA-011 | R9 | error | Role `003` attempts delete. | POST `epl-case-insert-delreason`. | HTTP 403 `FORBIDDEN_ACTION`. | No rows inserted into `TB_DEL_REASON` or `TB_APP_HISTORY`; summary unchanged. |
| QA-012 | R9 | happy | Role `001` selects `D01;D99;` and provides `othReason`. | POST `epl-case-insert-delreason`. | HTTP 200 `0000`. | `TB_DEL_REASON` inserted, `TB_APP_HISTORY` inserted, `TB_LON_SUMMARY_INFO.CASE_PROGRESS='D1'`. |
| QA-013 `@PENDING TBD-008` | R12 | pending | User selects an application. | POST `epl-comm-todolist-setsession`. | Behavior follows session migration verdict. | Current application context observable by downstream page if session retained. |
| QA-014 | R9 | error | Delete request has no reason. | POST `epl-case-insert-delreason`. | HTTP 400 `MISSING_REASON` or `E102`. | All three write targets remain unchanged. |
| QA-015 | R10 | happy | CAD close case has `IS_AUTODIS=Y`; user selects `C01;C99;` and `othReason`. | POST `epl-case-insert-cloreason`. | HTTP 200 `0000`. | `TB_CLO_REASON` inserted, `TB_APP_HISTORY` inserted, summary `CASE_PROGRESS='C1'`, `CURRENT_USER_ID` blank, `IS_AUTODIS='YC'`. |
| QA-016 | R13 | happy | Reason code table has `DEL_REASON` values. | POST `epl-comm-field-options` with `msgCode=DEL_REASON`. | Response returns options, not hard-coded client values. | Response source can be traced to common options; no UI hard-coded override. |
| QA-017 `@PENDING TBD-006` | R11 | pending | CA user requests `TYPE=IS` download. | POST `epl-file-todolist-download`. | Return shape follows TBD-006 verdict. | No business table mutation; audit/log entry exists. |
| QA-018 | R14 | error | Unauthorized role calls close directly. | POST `epl-case-insert-cloreason`. | HTTP 403 `FORBIDDEN_ACTION` or `E998`. | No `TB_CLO_REASON`/`TB_APP_HISTORY` insert. |
| QA-019 | R14 | happy | Authorized delete succeeds. | POST `epl-case-insert-delreason`. | Response success and audit is complete. | `TB_APP_HISTORY.PROCESS_EMP_CODE`, `PROCESS_EMP_NAME`, `PROCESS_BRANCH_CODE`, `PROCESS_BRANCH_NAME`, `PROCESS_DATE` are populated. |
| QA-020 | R9 | edge | Acting user is a proxy/sub employee path. | POST `epl-case-insert-delreason`. | Delete succeeds only if authorized. | Per new DB schema baseline, `TB_APP_HISTORY` uses `PROCESS_EMP_CODE`, `PROCESS_EMP_NAME`, `PROCESS_BRANCH_CODE`, `PROCESS_BRANCH_NAME`, and `PROCESS_DATE`; legacy-only `PROCESS_AGENT_CODE/NAME` columns are not required. |
| QA-021 | R7 | error | CAD query provides only start date. | POST `epl-list-todolist`. | HTTP 400 `INVALID_CAD_QUERY_CONDITION`. | No query with half-open decision date range. |
| QA-022 | R10 | error | Close selects `C99` but omits `othReason`. | POST `epl-case-insert-cloreason`. | HTTP 400 `MISSING_OTHER_REASON` or `E102`. | No close reason/history/summary update. |
| QA-023 | R11 | error | Download request has invalid `type`. | POST `epl-file-todolist-download`. | HTTP 400 `INVALID_TYPE`; not 500. | No report dispatch occurs. |
| QA-024 | R8 | edge | Seed routing rows for CAD Maker `21`, CAD Maker `24`, CAD Checker `23`, CAD Checker `25`, CAD otherwise, and a non-CAD role with `getCheckPage` output. | POST `epl-list-todolist`. | Pages resolve respectively to `EPROIS_0910`, `EPROIS_0920`, `EPROIS_0910`, `EPROIS_0920`, `MANUALAPP`, and first page from `EPRO_Z0Z006.getCheckPage`. | Route field is derived from role/status matrix, not client input. |
| QA-025 | R9 | error | Authorized delete selects `D99` but omits `othReason`. | POST `epl-case-insert-delreason`. | HTTP 400 `MISSING_OTHER_REASON` or `E102`. | No `TB_DEL_REASON`, `TB_APP_HISTORY`, or summary update occurs. |
| QA-026 | R10 | edge | CAD close case has `IS_AUTODIS=M`; user selects valid close reason without C99. | POST `epl-case-insert-cloreason`. | HTTP 200 `0000`. | Summary `CASE_PROGRESS='C1'`, `CURRENT_USER_ID` blank, and `IS_AUTODIS='MC'`; close reason/history rows inserted. |
| QA-027 | R8 | edge | CA role has four seeded cases with attributes `IS`, `IU`, `CS`, and `CU`. | POST `epl-list-todolist`. | Pages resolve respectively to `EPROIS_0171`, `EPROIU_0171`, `EPROCS_0171`, and `EPROCU_0171`. | CA routing uses server-side case attribute, not client-supplied target page. |

## Coverage
- Happy: QA-001, QA-003, QA-005, QA-006, QA-007, QA-010, QA-012, QA-015, QA-016, QA-019, QA-026.
- Error: QA-009, QA-011, QA-014, QA-018, QA-021, QA-022, QA-023, QA-025.
- Edge: QA-004, QA-008, QA-020, QA-024, QA-027.
- Pending skeletons: QA-002, QA-013, QA-017.
