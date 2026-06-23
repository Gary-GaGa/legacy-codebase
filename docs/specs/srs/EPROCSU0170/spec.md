# EPROCSU0170 SRS - Credit Evaluation and Credit Decision

## 1. Metadata / Status

| Field | Value |
|---|---|
| FuncId | `EPROCSU0170` |
| Status | In Review - T1 approval hub checkpoint; mechanical gate PASS; N-axis review found open RP blockers |
| N-axis review | spec-reviewer (axis A) 2026-06-23: mechanical gate PASS; 0🔴 + 4🟡. Top 🟡 = Traceability QA-047 misplaced under REQ-007 (it covers R17, belongs REQ-006/008) + QA-021 missing named error code (`EPROIS0170_UI_MSG_ERROR_DEVIATION`). 🟡 fixed + re-review PASS 2026-06-23: QA-047 moved from REQ-007 to REQ-006/REQ-008 rows (dual-listing matches QA-046 precedent). Remains In Review; blocked on RP12–RP24 (+ open 🟡 QA-021 missing named error code). |
| Owner | SA / credit decision domain / RD |
| Upstream PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROCSU0170-v1.0.md` |
| Upstream PRD status | v1.0, 2026-06-15 |
| Source baseline | PRD + current refactor implementation + `docs/refactor-spec/` + `docs/db-diff/` + existing decisions and pending register |
| As-is source | Old corporate `EPROCS_0170`, `EPROCS_0270`, `EPROCU_0170`, `EPROCU_0270`; no `done/c0-legacy-parity-recheck-*-0170-findings.md` found, so old corporate parity remains `待 parity 碼驗 / 待 RD 核對` |
| Risk tier | T1: submit/return gate, checkpoint writes, CS/CU branching, money/auth/workflow side effects |
| Mechanical gate | PASS on 2026-06-23: `python scripts/check-srs-bundle.py docs/specs/srs/EPROCSU0170` |
| Semantic gate | Required: N-axis A-G read-only review, then human per-page checkpoint |

### Source Evidence

| ID | Evidence |
|---|---|
| PRD-E1 | PRD metadata maps target to old funcs `EPROCS_0170`, `EPROCS_0270`, `EPROCU_0170`, `EPROCU_0270`: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROCSU0170-v1.0.md:5`-`:10` |
| PRD-E2 | PRD scope covers credit evaluation, credit decision, return, cancel, upload, print, notification, and workflow action: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROCSU0170-v1.0.md:25`-`:28` |
| PRD-E3 | PRD open TBD list: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROCSU0170-v1.0.md:34`-`:40` |
| PRD-E4 | PRD REQ list: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROCSU0170-v1.0.md:173`-`:187` |
| PRD-E5 | PRD error behavior: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROCSU0170-v1.0.md:720`-`:729` |
| DEC-E1 | New work unit is the new page and old pages may merge: `docs/decisions.md:18` |
| DEC-E2 | Legacy parity SOP and corporate parity reopen: `docs/decisions.md:52`-`:54` |
| PEND-E1 | Existing corporate parity pending covers this page: `docs/pending-register.md:26` |
| MATRIX-E1 | EPROCSU0170 is listed as risk-tier first and parity feed required: `docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md:134` |
| PARITY-E1 | Required old mapping is `EPROCS_0170+0270` / `EPROCU_0170+0270`: `docs/build-tasks/c0-legacy-parity-recheck.md:22` |
| REF-E1 | Refactor-spec latest artifact map lists current EPROCSU0170 artifacts: `docs/refactor-spec/02_modules/EPROCSU0170.md:22`-`:39` |
| CUR-BE1 | Current controller exposes POST `epl-*` routes: `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCreditEvalAndCreditDecisionController.java:40`, `:56`, `:70`, `:85`, `:100`, `:115`, `:130`, `:144`, `:158`, `:172`, `:186` |
| CUR-BE2 | Current service validates and saves summary/detail/fee/comment on save/submit paths: `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditEvalAndCreditDecisionServiceImpl.java:489`, `:535`-`:543`, `:2497`, `:3306`-`:3319`, `:3325`, `:3528` |
| CUR-FE1 | Current FE uses corporate endpoints, but download still calls individual loan-condition download route: `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-evaluation-and-credit-decision/service/api.service.ts:34`, `:46`, `:59`, `:68`, `:77`, `:86`, `:93`, `:101` |
| LEG-E1 | Old CS/CU transactions expose prompt/init/save/action/email/cancel/return/upload/print/delete/reason actions: `legacy-epro/JavaSource/com/cathaybk/epro/cs/trx/EPROCS_0170.java:60`, `:143`, `:449`, `:493`, `:550`, `:623`, `:658`, `:702`, `:757`, `:779`, `:812`; `legacy-epro/JavaSource/com/cathaybk/epro/cu/trx/EPROCU_0170.java:60`, `:140`, `:444`, `:488`, `:545`, `:618`, `:653`, `:697`, `:752`, `:774`, `:807` |
| LEG-E2 | Old validation messages include related-party, LTV level/deviation, and return-item errors: `legacy-epro/JavaSource/com/cathaybk/epro/cs/module/EPROCS_0170_mod.java:724`, `:778`, `:795`, `:1021`; `legacy-epro/JavaSource/com/cathaybk/epro/cu/module/EPROCU_0170_mod.java:673`, `:885` |
| DB-E1 | DB snapshot marks new `TB_CHECK_POINTS_CS/CU` active and old checkpoint tables removed/unused: `docs/db-diff/00_HOME.md:115`-`:116`, `:216`-`:223` |
| DB-E2 | `TB_CHECK_POINTS_CS/CU` do not contain `EPROCSU0170` columns in the snapshot: `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:38`-`:53`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:38`-`:50` |
| DB-E3 | `TB_LOAN_EVAL_COMMENT` is marked `removed_or_unused` while PRD/current code still use comment/file data: `docs/db-diff/02_tables/TB_LOAN_EVAL_COMMENT.md:11`-`:17`, `:38`-`:54` |

## 2. Scope / Non-Goals

### Scope

- Convert PRD `EPROCSU0170` into implementable SRS rules for the current Spring Boot / Angular corporate credit evaluation and credit decision page.
- Cover four old corporate scenarios: CS 0170, CS 0270, CU 0170, CU 0270.
- Carry submit, return, cancel, upload/delete, print, notification, audit, DB writes, auth, and checkpoint obligations.
- Reconcile PRD, current refactor artifacts, DB snapshot, existing decisions, and known pending items.

### Non-Goals

- Do not approve the page. This bundle stops at `In Review`.
- Do not redesign the UI or invent visual behavior not present in PRD/current refactor artifacts.
- Do not change DB physical schema in this SRS. `schema.sql` is a contract slice and delta record.
- Do not treat ISU/i0 mirror behavior as corporate as-is.
- Do not close the existing corporate parity pending row.

## 3. Assumptions / Dependencies / Constraints

- A1: CS/CU into `EPROCSU0170` is an accepted page-level merge per `docs/decisions.md:18`; PRD `TBD-001` is closed as a page-unit decision in this SRS under `RP25`, while per-branch behavior still remains blocked by `RP12`.
- A2: Old behavior authority is old corporate CS/CU source, but line-by-line parity findings for this page are not present. Every old-corporate-as-is claim that requires parity is blocked by `RP12`.
- A3: Backend owns submit/return/cancel authorization, handler identity, case state transition, checkpoint mutation, audit, and irreversible side effects. The client must not send authoritative decision fields such as current handler, role, branch, checkpoint completion, or audit user.
- A4: Mutating routes are POST RPC routes using current `epl-*` names, not idealized REST `/api/...` names.
- A5: Oracle native-query aliases not quoted must be consumed as uppercase labels by backend mapping.
- A6: DB schema snapshot in `docs/db-diff/` is authoritative for new schema state; if old-vs-new semantic parity conflicts with schema, use three-judge disposition and keep new schema unless owner/DBA changes it.
- A7: Refactor-spec is a current implementation baseline, not a replacement for old corporate parity.

## 4. Endpoints

All listed endpoints are current RPC routes and use POST.

| Endpoint | Purpose | Request owner notes | Covers |
|---|---|---|---|
| `epl-sele-csu-cr-dec` | Bootstrap dropdown/options | `applicationNo`; server derives auth/context | R2 |
| `epl-info-csu-cr-dec` | Main page init | `applicationNo`; optional scenario hints are not authoritative | R3, R4 |
| `epl-save-csu-cr-dec` | Save draft credit evaluation / suggested terms | body carries editable draft fields; backend derives user/audit | R5 |
| `epl-case-csu-cr-dec-submit` | Submit/return/cancel/agreed/LLC/LC workflow action | `applicationNo`, `newCaseProgress`, editable evaluation fields; backend owns gate and transition | R6, R7, R16 |
| `epl-info-csu-cr-dec-retu` | Query return popup/info | `applicationNo` | R8 |
| `epl-save-csu-cr-dec-retu` | Save return item/memo | `applicationNo`, `retuStatus`, `retuCodeList`, memos | R8 |
| `epl-case-csu-cr-dec-del-retu` | Delete return info | `applicationNo`, return sequence | R8, R14 |
| `epl-info-csu-cr-dec-cancel` | Query cancel reason/options | `applicationNo` | R9 |
| `epl-save-csu-cr-dec-cancel` | Save cancel reason | `applicationNo`, `cancelCodeList`, `othReason` | R9 |
| `epl-case-csu-cr-dec-upload` | Upload LLC meeting file | multipart `applicationNo`, `uploadFile` | R10 |
| `epl-case-csu-cr-dec-del-file` | Delete LLC meeting file | `applicationNo`, `llcDataSeq` | R10, R14 |

Not yet a valid EPROCSU0170 contract endpoint:

- Proposal print: old corporate source has `printProposal`, but current corporate controller has no corporate print route. Current FE download calls an individual loan-condition download route; see `RP22`.
- Amount calculation and loan-sector cascade: PRD lists old actions, but current corporate controller/refactor artifact map does not expose a dedicated route in the verified set; see `RP23`.

## 5. Business Rules

### R1 - Merged scenario context and routing (強制點: both)

- covers-prd: REQ-001
- As-is: Old corporate has four functions: CS 0170, CS 0270, CU 0170, CU 0270. The target page merge is an existing decision, but old per-scenario parity remains blocked by `RP12`.
- To-be: When a user opens EPROCSU0170, the system shall resolve `caseDomain` as CS or CU and `caseScenario` as 0170 or 0270 from server-side case data, route/page context, and authorization state, so that the same new page can enforce scenario-specific rules.
- The client may pass navigation hints, but backend shall not trust client-supplied domain/scenario for authorization, state transition, checkpoint, or DB mutation.

### R2 @PENDING - Bootstrap options, permission, and code labels (強制點: both)

- covers-prd: REQ-002
- As-is: Old `doPrompt/getPrompt` loads page options, permissions, and labels. PRD records a CS 0270 permission function-id defect suspect and unresolved code-table labels.
- To-be: When bootstrap is requested, the system shall return options, action visibility, and editable capability for the resolved CS/CU and 0170/0270 scenario, while backend remains authoritative for any later mutation.
- Required output groups: `attrMap`, `ROLE_ID`, `empList`, `CASE_PROGRESS`, `approvalLevel`, `LEVEL`, `LEVEL_SUMBIT`, `loanPurposeMap`, `loanTypeMap`, `facilityTypeMap`, `repaymentModeMap`, `repaymentFrequencyMap`, `ccyMap`, `loanSectorMap`, CS/0170 flags (`isHousingLoan`, `isAfterOnlineDate`, `isAfterOnlineDate02`, `isAfterVer0200`, `isAfterVer0210`, `isAfterVer0211`), and 0270 flags (`REF_APPLICATION_NO`, `loanTypeMapRC`, `isCR`).
- Pending: `RP13` for CS 0270 permission function-id mapping; `RP18` for code labels.

### R3 - Main data initialization (強制點: BE)

- covers-prd: REQ-003
- As-is: Old `doInit/getInit` loads summary, guarantor, collateral, fee, suggested detail, comments, CP/file info, return/cancel-related info, and options. Current route `epl-info-csu-cr-dec` exists.
- To-be: When `applicationNo` is valid and authorized, backend shall return the main page aggregate for summary, parties, collateral/LTV, suggested fee/detail, current SG/LLC comments, return info, cancel state, file metadata, approval levels, and scenario flags.
- Error: If `applicationNo` is blank, backend shall reject without reading or mutating case data and surface `COMMON_MSG_ERROR_LON`-equivalent validation.

### R4 - 0270 revised before/after data (強制點: BE)

- covers-prd: REQ-004
- As-is: PRD states 0270 has `REF_APPLICATION_NO`, revised items, and before/after data; 0170 does not.
- To-be: When the scenario is 0270, backend shall return revised before/after fee, detail, guarantor, collateral, and revised item information; when the scenario is 0170, backend shall not require 0270-only revised data.
- DB: `TB_REVISED_ITEM` is active in the snapshot and remains the target revised-item table.

### R5 - Save draft transaction (強制點: BE)

- covers-prd: REQ-005
- As-is: Old `save` persists SG comment, suggested terms, fees, LTV, and approval levels. Current `epl-save-csu-cr-dec` saves summary, detail, condition info, fee, comment, and collateral LTV.
- To-be: When an authorized user saves a draft, backend shall validate required draft fields, save summary approval levels, suggested loan conditions, fees, SG/LLC comments, and SG coverage LTV in one transaction, so a later init returns the same values.
- Backend shall derive update user/proxy/audit fields from session context, not from client input.

### R6 @PENDING - Workflow action, state transition, checkpoint, and side effects (強制點: BE)

- covers-prd: REQ-006
- As-is: Old `action/getSInfoMap` moves case progress, writes history/checkpoints, triggers decision side effects, and branches by CS/CU and 0170/0270. Current `epl-case-csu-cr-dec-submit` exists, but old corporate parity findings are missing.
- To-be: When an authorized action is submitted, backend shall validate the requested `newCaseProgress`, current handler, current state, required upstream checkpoints, and action-specific data before writing summary/history/checkpoint/notification side effects transactionally.
- Backend shall derive final `CURRENT_USER_ID`, process employee, decision date, `APP_CON_TYPE`, and checkpoint mutation from the action result and server state.
- Action branch map:
  - `06`: submit to next handler; related-party and scorecard gates must pass; `CURRENT_USER_ID` must be server-derived, not client-authoritative.
  - `08`: agreed proposed condition; clear `CURRENT_USER_ID`, set `FIN_APPR_LEVEL`, set `DECISION_DATE=now`, set `APP_CON_TYPE=AO`.
  - `09`: agreed suggested condition; clear `CURRENT_USER_ID`, set `FIN_APPR_LEVEL`, set `DECISION_DATE=now`, set `APP_CON_TYPE=SG`.
  - `95`: route to LC; set `CURRENT_USER_ID=CA_CODE`, set `IS_LC=Y`.
  - `96`: reject; clear `CURRENT_USER_ID`, set `DECISION_DATE=now`.
  - `97`: route to LLC; set `CURRENT_USER_ID=CR_CODE`, set `IS_LLC=Y`.
  - `98`: return; CR return routes to AO/AO assistant, non-CR return routes to CR, and scenario cleanup follows `RP21`.
  - `99`: cancel; clear `CURRENT_USER_ID`, set `DECISION_DATE=now`, and persist cancel reason through R9.
- A blank `newCaseProgress` shall be rejected before any summary, history, checkpoint, notification, or file side effect.
- Pending: `RP12` old corporate parity; `RP19` checkpoint schema mismatch.

### R7 @PENDING - Submit validation gate (強制點: BE)

- covers-prd: REQ-007
- As-is: Old modules enforce related-party completion, scorecard/collateral/LTV checks, approval-level inputs, and action-dependent comments. PRD records CS `YY` versus CU `YN` scorecard-completion mismatch.
- To-be: When a submit/agreed/LLC/LC action is requested, backend shall enforce all mandatory field, related-party, scorecard, LTV, and approval-level gates before any DB write.
- Errors to carry: `COMMON_MSG_RELATED_YET`, `EPROI00113_MSG_ERROR_LEVEL`, `EPROIS0170_UI_MSG_ERROR_DEVIATION`, and validation errors for missing `applicationNo` / `newCaseProgress`.
- Pending: `RP14` scorecard completion semantics and old CS/CU submit gate parity.

### R8 - Return information maintenance and cleanup (強制點: BE)

- covers-prd: REQ-008
- As-is: Old return popup/save/delete actions maintain semicolon-joined return codes, memos, return status, and cleanup. Current routes `epl-info-csu-cr-dec-retu`, `epl-save-csu-cr-dec-retu`, and `epl-case-csu-cr-dec-del-retu` exist.
- To-be: When return info is saved, backend shall require at least one return item, persist return status/code/memos, and keep code lists as semicolon-joined DB values while exposing arrays in the API contract.
- When return/delete is executed, backend shall apply scenario-specific cleanup for 0170/0270 and CS/CU only after old corporate parity is verified; unresolved cleanup is blocked by `RP12`.
- Error: If no return item is selected, backend shall reject with `EPROCS0170_MSG_009`-equivalent validation.

### R9 - Cancel reason maintenance (強制點: BE)

- covers-prd: REQ-009
- As-is: Old CS and CU use different cancel reason code tables; current `epl-info-csu-cr-dec-cancel` and `epl-save-csu-cr-dec-cancel` exist.
- To-be: When a case is cancelled, backend shall require at least one cancel reason, persist `REASON_CODE` as semicolon-joined values, persist `OTH_REASON` when provided, write cancel date, and update workflow state transactionally.
- Error: If no cancel reason is selected, backend shall reject with `EPROZ00100_MSG_REASON`-equivalent validation.
- Pending labels remain under `RP18`.

### R10 @PENDING - LLC upload and delete file (強制點: BE)

- covers-prd: REQ-010
- As-is: Old `upload/delFile` writes file path/name and comment metadata; PRD records non-`DATA_SEQ=0` upload defect suspect and delete audit type issue. Current corporate upload/delete routes exist.
- To-be: When an LLC file is uploaded, backend shall store the physical file and DB metadata consistently; when deleted, backend shall remove or invalidate metadata and write the correct audit event.
- If physical write fails, backend shall not leave a DB path/name that cannot be downloaded.
- Pending: `RP15` upload non-zero data sequence behavior; `RP16` delete audit classification.

### R11 @PENDING - Proposal print contract (強制點: both)

- covers-prd: REQ-011
- As-is: Old CS uses CS print helper and old CU uses CU print helper. Current corporate controller has no verified corporate print route; current FE download calls an individual loan-condition download endpoint.
- To-be: When print is requested, the target shall use a corporate EPROCSU0170 print/download contract that derives CS/CU helper choice on the backend and returns a safe download token or response without exposing filesystem paths.
- Pending: `RP22`.

### R12 @PENDING - Amount calculation and loan-sector cascade (強制點: both)

- covers-prd: REQ-012
- As-is: Old action map includes amount calculation and loan section/sub-sector cascade. No dedicated current corporate route was verified in the EPROCSU0170 controller/refactor artifact map.
- To-be: When amount or loan-sector cascade is required for editable suggested terms, the target shall define whether it is local FE calculation, shared endpoint, or EPROCSU0170 backend route; calculation authority for persisted values shall be backend-verifiable.
- Pending: `RP23`.

### R13 @PENDING - Notification and AutoDisbursement side effect (強制點: BE)

- covers-prd: REQ-013
- As-is: Old `tosendEmail` sends notifications and PRD states AutoDisbursement side effect exists. PRD also records environment-specific fixed-recipient routing risk.
- To-be: After successful state transition, backend shall create notification records and trigger or enqueue downstream AutoDisbursement behavior according to environment-safe routing rules.
- Notification failure strategy shall be explicit: rollback, retry, compensating task, or action-success-with-warning.
- Pending: `RP17` email routing / AutoDisbursement integration.

### R14 @PENDING - Audit log and sensitive operation tracing (強制點: BE)

- covers-prd: REQ-014
- As-is: Old transactions set audit behavior, but PRD flags delete-return and delete-file using print-type audit as defect suspect.
- To-be: Backend shall audit query, save, submit/action, return, cancel, upload, delete, print, and unauthorized attempts with operation-specific event types and masked sensitive data.
- Pending: `RP16` delete audit classification and `RP24` service-level authorization/audit proof.

### R15 @PENDING - Legacy defect suspect handling (強制點: both)

- covers-prd: REQ-015
- As-is: PRD records seven open legacy defects/TBDs. Existing parity SOP says ungrounded intentional evolution is not allowed; unclear behavior is `UNFOUND`.
- To-be: Each legacy defect suspect shall be resolved by owner decision before Approved: keep legacy, fix as regression, or keep new as intentional evolution with source-backed reason.
- Pending: `RP13`, `RP14`, `RP15`, `RP16`, `RP17`, `RP18`, `RP22`, `RP23`.

### R16 @PENDING - Service-level authorization and integrity guard (強制點: BE)

- covers-prd: REQ-006, REQ-007, REQ-014
- As-is: `TB_API_AUTH` exists in new schema, but this page has money/workflow/security impact and DB seed alone is not sufficient proof of service-level authorization.
- To-be: For every mutating endpoint, backend shall verify API authorization, page/action permission, current handler ownership, current case state, and four-scenario business guard before mutating DB.
- Pending: `RP24`.

### R17 @PENDING - New DB checkpoint and removed-table reconcile (強制點: BE)

- covers-prd: REQ-006, REQ-008
- As-is: Old functions use old corporate checkpoint families; new DB snapshot has `TB_CHECK_POINTS_CS/CU`, but no `EPROCSU0170` column in the verified snapshot.
- To-be: Backend shall write the correct active checkpoint key for return/submit cleanup and page completion. If the new schema intentionally has no 0170 checkpoint, the SRS must state the replacement authoritative checkpoint field.
- Pending: `RP19`.

## 6. NFR

- NFR-1 Transactionality: Save/action/return/cancel/upload/delete side effects touching `TB_LON_SUMMARY_INFO`, `TB_APP_HISTORY`, `TB_RETURN_INFO`, `TB_CAN_REASON`, `TB_LOAN_CONDITION_DETAIL`, `TB_LOAN_CONDITION_FEE`, `TB_LOAN_EVAL_COMMENT`, `TB_COLL_LTV`, notification, and checkpoint data shall be transactionally consistent or explicitly compensated.
- NFR-2 Authorization: User ID, role, branch, current handler, and proxy shall be resolved server-side.
- NFR-3 File security: Upload/download/print shall never expose raw filesystem path; file metadata must be masked in logs.
- NFR-4 Audit: Sensitive query and mutation attempts, including denied attempts, shall be auditable.
- NFR-5 Performance: Main init shall not execute the same logical detail query more than once per request unless the duplicate query is justified by different bind variables; dropdown options may be cached only with a refresh/eviction path; print/email asynchronous handling shall return a traceable status or event id when `RP17`/`RP22` are closed.
- NFR-6 Compatibility: Source-confirmed message codes and old corporate behavior must be traceable through PRD/SRS/QA, unless an owner decision records intentional evolution.

## 7. Trade-offs

| Choice | Recommendation | Trade-off |
|---|---|---|
| Merge CS/CU into one page | Keep accepted page merge | Reduces page sprawl, but raises branching risk; R1/R6/R17 require explicit server-side scenario resolution |
| Old checkpoint tables vs new checkpoint tables | Keep new schema, reconcile behavior | Schema follows target DB, but exact 0170 checkpoint key is blocked by `RP19` |
| Current refactor baseline vs old corporate parity | Use refactor as current-state evidence only | Avoids losing implementation grounding, but Approved is blocked until old corporate parity is verified |
| Print/download route | Do not invent a corporate route in this SRS | OpenAPI stays truthful, but `RP22` blocks print completion |
| Email side effect | Require explicit retry/compensation design | Prevents hidden production-risk behavior, but `RP17` blocks final approval |

## 8. New/Old DB Reconcile and Delta List

| Delta ID | Source | Delta | Three-judge tag | SRS disposition |
|---|---|---|---|---|
| DB-D1 | `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:49`, `:62`-`:71`, `:80`; current service `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditEvalAndCreditDecisionServiceImpl.java:3306`-`:3319` | Summary remains active and holds case progress/current user/LLC/LC/scorecard/approval/application condition fields. | (c) schema new as authority, code aligns behavior | Carry into R5/R6/R7. |
| DB-D2 | `docs/db-diff/00_HOME.md:115`-`:116`, `:216`-`:223`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:38`-`:53`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:38`-`:50` | Old checkpoint tables are removed/unused; new active checkpoint tables lack verified `EPROCSU0170` column. | (c) DB structure diff, behavior unresolved | `RP19`; cannot mark checkpoint complete. |
| DB-D3 | `docs/db-diff/02_tables/TB_LOAN_EVAL_COMMENT.md:11`-`:17`, `:38`-`:54`; current service `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditEvalAndCreditDecisionServiceImpl.java:2374`, `:3211` | DB snapshot marks comment table removed/unused, but PRD/current code still use comments and LLC file metadata. | (c) DB structure diff, probable contract drift | `RP20`; RD/DBA must resolve before Approved. |
| DB-D4 | `docs/db-diff/02_tables/TB_LOAN_CONDITION_FEE.md:38`-`:59`; `docs/db-diff/02_tables/TB_LOAN_CONDITION_DETAIL.md:38`-`:75`; current service `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditEvalAndCreditDecisionServiceImpl.java:3325`, `:3528` | Suggested fee/detail remain active and save path updates them; numeric amount/rate/fee precision is defined by DB. | (c) schema new as authority, behavior carry | R5/R7; precision reflected in `schema.sql` and OpenAPI. |
| DB-D5 | `docs/db-diff/02_tables/TB_RETURN_INFO.md:38`-`:46`; `docs/db-diff/02_tables/TB_CAN_REASON.md:38`-`:41` | Return/cancel tables are active and use semicolon-joined code lists with aggregate DB limits. | (c) schema new as authority, behavior carry | R8/R9; OpenAPI carries joined-length constraints. |
| DB-D6 | `docs/db-diff/02_tables/TB_NOTIFICATION_INFO.md:38`-`:49` | Notification table is active; email routing/AutoDisbursement behavior still needs target strategy. | (c) schema active, behavior pending | `RP17`. |
| DB-D7 | `docs/db-diff/02_tables/TB_API_AUTH.md:38`-`:42` | API auth table exists, but service-level authorization proof is separate. | (c) schema active, behavior pending | `RP24`. |
| DB-D8 | `docs/db-diff/02_tables/TB_APP_HISTORY.md:38`-`:44`; `docs/db-diff/02_tables/TB_REVISED_ITEM.md:38`-`:54`; `docs/db-diff/02_tables/TB_COLL_LTV.md:38`-`:49` | History, revised item, and collateral LTV are active support tables for action history, 0270 revised view, and LTV validation. | (c) schema new as authority, behavior carry | R4/R6/R7. |
| DB-D9 | `docs/db-diff/02_tables/TB_UPLOAD_FILE_PTH.md:35`-`:44` | Generic upload path table is active, but current EPROCSU0170 LLC file metadata evidence points to `TB_LOAN_EVAL_COMMENT`; `TB_UPLOAD_FILE_PTH` is not the authoritative R10 target unless RD/DBA changes the design. | (c) schema active, behavior not selected | Excluded from `schema.sql` contract slice; see `RP20`. |
| REF-D1 | `docs/refactor-spec/02_modules/EPROCSU0170.md:22`-`:39` | Current artifact map has 15 BE + 3 FE artifacts. | (c) current-state evidence only | Use to ground endpoints; not old parity. |
| REF-D2 | `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-evaluation-and-credit-decision/service/api.service.ts:68` | FE download calls individual loan-condition route. | (a) probable regression unless owner approves reuse | `RP22`. |
| REF-D3 | `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuCreditEvalAndCreditDecision/CaseCsuCrDecSubmitRequest.java:74`-`:78`; current service `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCreditEvalAndCreditDecisionServiceImpl.java:2554`, `:2881` | Current submit DTO/service accepts client `curEmpId`, conflicting with server-owned current-handler requirement. | (a) regression / security blocker | `RP24`; to-be OpenAPI removes `curEmpId` from client contract. |
| DEC-D1 | `docs/decisions.md:18`, `:52`-`:54`; `docs/build-tasks/c0-legacy-parity-recheck.md:22` | New page merge accepted, but corporate parity reopen requires old CS/CU comparison. | (c) accepted merge plus pending parity | `RP12`; `RP25` records PRD `TBD-001` closure for merge decision only. |

## 9. @PENDING

| ID | Status | Pending decision | Blocks | Owner | Source |
|---|---|---|---|---|---|
| RP12 | open | Complete old corporate parity for `EPROCS_0170+0270` and `EPROCU_0170+0270`; do not use ISU/i0 mirror as as-is. | Approved, R1/R6/R7/R8/R17 | credit decision domain + RD/Codex | `docs/pending-register.md:26`; `docs/build-tasks/c0-legacy-parity-recheck.md:22` |
| RP13 | open | Decide CS 0270 permission function-id mapping defect suspect. | R2/R15 | PM/SA/RD | PRD TBD-002 |
| RP14 | open | Decide CU submit scorecard completion value `YN` versus CS `YY`. | R7/R15 | PM/SA/RD | PRD TBD-003 |
| RP15 | open | Decide upload non-`DATA_SEQ=0` legacy defect behavior. | R10/R15 | RD/SA | PRD TBD-004 |
| RP16 | open | Decide audit event type for delete return info and delete file. | R10/R14/R15 | Security/Audit/RD | PRD TBD-005 |
| RP17 | open | Define environment-safe email routing and AutoDisbursement integration strategy. | R13 | SA/Infra/Security/RD | PRD TBD-006, PRD REQ-013 |
| RP18 | open | Resolve code-table display labels for cancel/revised/approval options. | R2/R9/R15 | SA/BA | PRD TBD-007 |
| RP19 | open | Resolve active checkpoint key/table for EPROCSU0170 because DB snapshot lacks `EPROCSU0170` in `TB_CHECK_POINTS_CS/CU`. | R6/R17 | RD/DBA/SA | DB-D2 |
| RP20 | open | Resolve `TB_LOAN_EVAL_COMMENT` removed-or-unused marker versus current comment/file usage. | R5/R10 | RD/DBA/SA | DB-D3 |
| RP21 | open | Decide exact return cleanup differences for CS/CU and 0170/0270, including SG fee/detail and scorecard/collateral cleanup. | R8/R17 | credit decision domain + RD | PRD BR-012 and parity recheck |
| RP22 | open | Define corporate proposal print/download route; current FE uses individual loan-condition download route. | R11 | FE/RD/SA | CUR-FE1 |
| RP23 | open | Define amount calculation and loan-sector cascade ownership/contract. | R12 | FE/RD/SA | PRD REQ-012; endpoint verification |
| RP24 | open | Provide service-level authorization and audit proof for all mutating routes; `TB_API_AUTH` seed alone is insufficient. | R14/R16 | Security/RD/DBA | R16 |
| RP25 | ✅ closed by prior decision | PRD `TBD-001` target integration boundary: one new work unit may merge multiple old pages; SRS does not re-litigate page merge. Per-scenario CS/CU/0170/0270 behavior remains open under `RP12`. | R1 page-unit boundary only | SA | `docs/decisions.md:18`; PRD TBD-001 |

## 10. Traceability Matrix

| PRD | Rules | QA |
|---|---|---|
| REQ-001 | R1 | QA-001, QA-002, QA-003 |
| REQ-002 | R2 | QA-004, QA-005, QA-006 |
| REQ-003 | R3 | QA-007, QA-008, QA-009 |
| REQ-004 | R4 | QA-010, QA-011, QA-012 |
| REQ-005 | R5 | QA-013, QA-014, QA-015 |
| REQ-006 | R6, R16, R17 | QA-016, QA-017, QA-018, QA-046, QA-047, QA-048, QA-050, QA-051, QA-052, QA-053, QA-054, QA-055, QA-056 |
| REQ-007 | R7, R16 | QA-019, QA-020, QA-021, QA-049 |
| REQ-008 | R8, R17 | QA-022, QA-023, QA-024, QA-047 |
| REQ-009 | R9 | QA-025, QA-026, QA-027 |
| REQ-010 | R10 | QA-028, QA-029, QA-030 |
| REQ-011 | R11 | QA-031, QA-032, QA-033 |
| REQ-012 | R12 | QA-034, QA-035, QA-036 |
| REQ-013 | R13 | QA-037, QA-038, QA-039 |
| REQ-014 | R14, R16 | QA-040, QA-041, QA-042, QA-046 |
| REQ-015 | R15 | QA-043, QA-044, QA-045 |

## 11. Hard Boundaries and As-is / To-be Summary

- Hard boundary: this bundle is `In Review`; do not promote to Approved until mechanical gate exits 0, N-axis A-G have no unresolved Blocker after fix/adoption, and human per-page checkpoint accepts the result.
- Hard boundary: old corporate parity is not complete. Any claimed as-is that depends on per-branch CS/CU/0170/0270 behavior remains `待 parity 碼驗 / 待 RD 核對`.
- Hard boundary: current refactor-spec artifacts ground current endpoint names and request shape only; they do not prove old corporate behavior.
- Hard boundary: backend owns authorization, workflow gate, checkpoint, state transition, audit, and money/process side effects.
- As-is summary: old corporate has four legacy functions with prompt/init/save/action/return/cancel/upload/print/email behavior; line-by-line corporate parity findings are absent.
- To-be summary: one target page `EPROCSU0170` carries four scenarios through server-derived context, current `epl-*` endpoints, transactional save/action side effects, explicit pending blockers, and traceable QA coverage.
