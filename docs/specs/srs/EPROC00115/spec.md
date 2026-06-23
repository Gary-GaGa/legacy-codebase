# SRS - EPROC00115 Borrower Group Exposure

## Metadata
| Field | Value |
|---|---|
| FuncId | EPROC00115 |
| Status | In Review / draft-for-controller-gate; awaiting human approval |
| N-axis review | spec-reviewer (axis A) 2026-06-23: mechanical gate PASS; 1🔴 + 6🟡. 🔴 = `COMMON_MSG_TOTAL_FAIL` listed in openapi error enum but R9 forbids modeling it for these endpoints (contract ⊥ rule). Top 🟡 = orphan error codes E130/E201/E999/E498; save authz (pilot core) deferred to RP20. Not Approvable until 🔴 resolved. |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md` |
| Legacy source | `EPROC0_0115`, `EPROC0_0215`, `EPROC00115.jsp`, `EPROC00215.jsp`, `EPRO_TB_GROUP_EXPOSURE` |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`, `qa-cases.md` |

## Scope
- In scope: C0 Borrower Group Exposure initialization, option lookup, detail query, Save/Finished save, full replacement of `TB_GROUP_EXPOSURE`, checkpoint update, totals behavior, cross-module read compatibility, and DB/schema reconcile for the current EPROC00115 page.
- Out of scope: changing ledger/status/register files, changing implementation code, or deciding PRD pending business items without owner input.
- Current contract uses the real RPC endpoints `epl-sele-c0-borrower-group-exposure`, `epl-info-c0-borrower-group-exposure`, and `epl-save-c0-borrower-group-exposure`; the PRD `/api/epro/eproc00115/*` draft is not used.

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD | PRD old codes and scope at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:15`, `:40`; pending items at `:49-57`; requirements at `:113-122`. | PRD pending items stay open as `@PENDING`; non-pending requirements map to R1-R9. |
| Dispatch | Real endpoint and SRS bundle rules at `docs/build-tasks/prd-to-srs-codex-dispatch.md:53`, `:102-110`, `:115-117`. | Use only `epl-*`; produce exactly four files. |
| Legacy 0115/0215 | Legacy loads four code tables at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0115_mod.java:49-52` and `EPROC0_0215_mod.java:49-52`; full replacement and rollback at `EPROC0_0115_mod.java:168-182` and `EPROC0_0215_mod.java:168-182`; RC checkpoint at `EPROC0_0215_mod.java:98-100`, `:175-177`. | Preserve shared data behavior; db-diff marks RC checkpoint tables removed/unused and moved to CS/CU, but the exact 0215 mapping remains pending. |
| Current backend | Controller exposes POST endpoints at `backend/src/main/java/khd/svc/epro/controller/corporate/CsuBorrowerGroupExposureController.java:23`, `:30`, `:37`, `:44`. Service reads, saves, and checkpoints at `CsuBorrowerGroupExposureServiceImpl.java:65-73`, `:113-160`, `:195-208`, `:211-227`. | Current backend is the API grounding. |
| Current frontend | API service calls the same endpoints at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/borrower-group-exposure/services/api.service.ts:27`, `:36`, `:45`; totals display only USD/KHR at `borrower-group-exposure.component.ts:306-350`. | FE totals are carried for USD/KHR; third currency remains pending. |
| Refactor spec | Endpoint metadata and payload rules at `docs/refactor-spec/03_artifacts/be-corporate/EPROC00115/epl-info-c0-borrower-group-exposure.md:109-111`, `:183-192`; save rules at `epl-save-c0-borrower-group-exposure.md:96-128`, `:153-179`; select rules at `epl-sele-c0-borrower-group-exposure.md:114-167`. | Refactor spec quantifies DTO lengths, required fields, and table writes. |
| DB diff and reverify | `TB_GROUP_EXPOSURE` active/exact at `docs/db-diff/02_tables/TB_GROUP_EXPOSURE.md:13-16`, columns at `:38-53`; `TB_COMMON_FIELD_OPTIONS` active/exact at `docs/db-diff/02_tables/TB_COMMON_FIELD_OPTIONS.md:13-16`, columns at `:38-48`; latest reverify confirms group exposure columns at `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:1398-1413` and PK at `..._pk.tsv:161-162`. | `schema.sql` follows latest reverify, with stale-source divergences called out. |
| Auth | `TB_API_AUTH` shape at `docs/db-diff/02_tables/TB_API_AUTH.md:13-16`, `:32`, `:38-40`; EPROC00115 endpoint rows at `docs/build-tasks/c0-authz-sql-findings.md:48-50`. | Endpoint seed evidence exists; service-level edit/query guard remains required by R9/QA. |
| Inventory | Feature inventory marks EPROC00115 BE/FE present with these endpoints at `docs/feature-inventory.md:102`; matrix marks SRS pending generation at `docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md:138`. | This bundle fills that page-level SRS output. |

## Endpoints
| Endpoint | Method | Purpose | Evidence |
|---|---|---|---|
| `/epl-sele-c0-borrower-group-exposure` | POST | Return `FACILITY_TYPE`, `LOAN_LIMIT_TYPE`, `CCY`, and `TITLE_DEED_TYPE` option lists. | Controller `:44`; refactor `epl-sele...md:114-167`. |
| `/epl-info-c0-borrower-group-exposure` | POST | Query case summary eligibility and return `facility` plus ordered `facilitiesList`. | Controller `:30`; service `:65-103`; refactor `epl-info...md:109-192`. |
| `/epl-save-c0-borrower-group-exposure` | POST | Save draft or Finished state, replace rows, update checkpoint in one transaction. | Controller `:37`; service `:109-160`; refactor `epl-save...md:96-179`. |

## Rules

### R1 Load option lists - 強制點: BE - covers-prd: REQ-001
The select endpoint must require `langType` and return an EPRO envelope whose `data` contains `facilityList`, `loanLimitTypeList`, `ccyList`, and `titleDeedTypeList` from `TB_COMMON_FIELD_OPTIONS` option codes `FACILITY_TYPE`, `LOAN_LIMIT_TYPE`, `CCY`, and `TITLE_DEED_TYPE`. Blank `langType` is a validation error carrying `E102`.

Evidence: legacy source loads the same four option groups at `EPROC0_0115_mod.java:49-52`; current service calls `commonService.getCommonFieldOptions` for all four lists at `CsuBorrowerGroupExposureServiceImpl.java:176-189`; refactor documents the request/response fields at `epl-sele-c0-borrower-group-exposure.md:159-167`; option table structure is at `docs/db-diff/02_tables/TB_COMMON_FIELD_OPTIONS.md:32`, `:38-48`.

### R2 Query exposure rows by application number - 強制點: BE - covers-prd: REQ-001, REQ-002
The info endpoint must require `applicationNo` and `isQuery`. It must validate the loan summary with the same query-mode semantics as current backend, then return an EPRO envelope whose `data.facilitiesList` has all `TB_GROUP_EXPOSURE` rows for the request `applicationNo` ordered by `DATA_SEQ`. If no exposure rows exist, return `data.facility=""` and `data.facilitiesList=[]`; the UI may create an empty visual row, but the API does not synthesize a row.

Evidence: current repository orders by `DATA_SEQ` at `TBGroupExposureRepository.java:19`; service maps no-row results to empty response at `CsuBorrowerGroupExposureServiceImpl.java:73-103`; refactor documents no-row output at `epl-info-c0-borrower-group-exposure.md:131-134`, `:186-187`.

### R3 Preserve facility value as header-level field - 強制點: BE - covers-prd: REQ-003
`facility` is required on save, max length 2, and represents one page-level `FACILITY_VALUE`. On save the backend writes the same request `facility` value to every inserted `TB_GROUP_EXPOSURE` row. The API response row object does not carry per-row `facilityValue`.

Evidence: current save request requires `facility` at `SaveCsuBorrowerGroupExposureRequest.java:24-27`; service sets each entity `facilityValue` from request at `CsuBorrowerGroupExposureServiceImpl.java:113-138`; refactor insert mapping uses request `facility` for `FACILITY_VALUE` at `epl-save-c0-borrower-group-exposure.md:157-159`.

### R4 Manage row add/delete and minimum one-row UI behavior - 強制點: FE - covers-prd: REQ-004
The UI must support adding and deleting exposure rows while preventing deletion of the final row. It must not call save with an unintended empty list caused by deleting all visible rows. `COMMON_MSG_ONE_DATA` is a UI-only prompt for this guard, not an API error response. The exact maximum row count is pending under R12, so this non-pending rule covers only minimum one-row behavior and payload consistency.

Evidence: legacy delete guard raises `COMMON_MSG_ONE_DATA` at `EPROC00115_JS.jsp:267` and `EPROC00215_JS.jsp:267`; current frontend maps the form array to `facilitiesList` at `borrower-group-exposure.component.ts:277-293`.

### R5 Calculate and display USD/KHR totals without a separate API - 強制點: FE - covers-prd: REQ-005
There is no current/refactor standalone calculate endpoint for EPROC00115. The UI must calculate visible totals client-side from the same form rows that are sent to save. Current display contract is USD and KHR totals for LCC and Outstanding; behavior for any third currency is pending under R11.

Evidence: legacy query totals cover USD/KHR at `EPROC0_0115_mod.java:61-81`, `:94-97`, and calculation sends non-USD to KHR at `:112-126`; current FE accumulates by currency then patches only `CA_USD`, `CA_KHR`, `OB_USD`, and `OB_KHR` at `borrower-group-exposure.component.ts:306-350`.

### R6 Save draft vs Finished validation and checkpoint polarity - 強制點: BE - covers-prd: REQ-006
Save and Finished use the same save endpoint. `isFinish=false` is draft Save and updates `EPROC00115` checkpoint to `Y`; `isFinish=true` is Finished and updates checkpoint to `N`. Save draft still validates request shape and numeric/date formats, but Finished adds row-level required-field checks. The conditional Outstanding/Maturity branch is pending under R10.

Evidence: current save request requires `isFinish` at `SaveCsuBorrowerGroupExposureRequest.java:20-22`; current service validates full row fields only when `isFinish` is true at `CsuBorrowerGroupExposureServiceImpl.java:113-119`; checkpoint polarity is implemented at `:158`. Legacy save passes `check=Y` and Finished passes `check=N` in `EPROC00115_JS.jsp:335-390`.

### R7 Save by full replacement in one transaction - 強制點: BE - covers-prd: REQ-007
Saving must delete existing `TB_GROUP_EXPOSURE` rows for the request `applicationNo`, insert the submitted list with `DATA_SEQ` assigned from 1 in request order, and update the checkpoint in the same transaction. Any failure after delete, including insert or checkpoint update failure, must roll back the delete and all inserts.

The backend must set `APPLICATION_NO` from request `applicationNo`, not from row content. This closes PRD pending-009 as an implementation requirement because current/refactor evidence already uses the request-level value.

Evidence: current save is `@Transactional(rollbackFor = Exception.class)` and deletes then inserts at `CsuBorrowerGroupExposureServiceImpl.java:109-160`; request-level `applicationNo` is assigned to each row at `:113`, `:133`; legacy transaction rolls back on exception at `EPROC0_0115_mod.java:168-182` and `EPROC0_0215_mod.java:168-182`.

### R8 Route checkpoint by CS/CU in the new schema - 強制點: BE - covers-prd: REQ-008
For the current new schema, corporate secured cases write `TB_CHECK_POINTS_CS.EPROC00115` and corporate unsecured cases write `TB_CHECK_POINTS_CU.EPROC00115`, using `TBLonSummaryInfo.LON_ATTRIBUTE + SECURE_ATTRIBUTE` as the branch key. Unsupported or missing summary attributes must fail with `E126` and must not write exposure rows.

Legacy `EPROC0_0215` RC-specific checkpoint tables are marked removed/unused in db-diff with a note that they moved to CS/CU; the exact 0215-to-EPROC00115 mapping remains pending under R14.

Evidence: current branch logic chooses CS/CU tables at `CsuBorrowerGroupExposureServiceImpl.java:195-208`; new DB columns exist at `TB_CHECK_POINTS_CS.md:45` and `TB_CHECK_POINTS_CU.md:43`; latest reverify confirms `EPROC00115` in CS/CU at `legacy_schema_reverify_new02_columns.tsv:126`, `:142`.

### R9 Enforce auth, editability, safe errors, and cross-module consumers - 強制點: both - covers-prd: REQ-010
All three endpoints require platform API authorization using their exact `TB_API_AUTH.API_ID` rows. Mutating calls must also enforce backend-owned case/edit authorization before DB writes; UI hidden/disabled controls are not sufficient, and the current service-level gap is tracked under R20. Error handling must carry PRD/current codes: `E102`, `E126`, `E130`, `E405`/access denied, `MSG_DATA_NOT_FOUND`, `MSG_OVER_COUNT_LIMIT`, `MSG_QUERY_FAIL`, `COMMON_MSG_ERROR_LON`, and `COMMON_MSG_SAVE_FAIL` where applicable. Current successful API responses use the EPRO envelope `code=0000`, `message=Success`, and endpoint-specific `data`; save currently returns an empty `data` object. Current `ReturnEnum` business errors use the normal EPRO response envelope; HTTP 401 is reserved for authorization failures such as `E405`. `COMMON_MSG_SAVE_SUCCESS` and `COMMON_MSG_TOTAL_FAIL` are legacy/UI message references and must not be modeled as raw API response bodies for these three endpoints. Safe logs must not include full sensitive payloads.

`TB_GROUP_EXPOSURE` is a shared data source for report and score modules; SRS changes must not alter columns, `DATA_SEQ` ordering, or LCC/Outstanding/Collateral field meaning without explicit cross-module decision.

Evidence: auth rows are listed at `docs/build-tasks/c0-authz-sql-findings.md:48-50`; API auth table shape is at `docs/db-diff/02_tables/TB_API_AUTH.md:38-40`; score modules read `LCC_AMOUNT_CUR`/`LCC_AMOUNT` at `EPROCS_0170_mod.java:1295-1300`, `EPROCS_0270_mod.java:1393-1398`, `EPROCU_0170_mod.java:1155-1160`, `EPROCU_0270_mod.java:1241-1246`; reports read rows ordered by `DATA_SEQ` and amount columns at `EPRO_CS0180.java:452-486`, `EPRO_CU0180.java:389-423`.

### R10 @PENDING PENDING-EPROC00115-LOAN-LIMIT-TYPE-SEMANTICS - 強制點: both - covers-prd: REQ-006
Owner: SA / RD.

PRD pending-003 states legacy requires Outstanding Amount and Maturity Date only when `LOAN_LIMIT_TYPE == "1"` or blank. Current backend, current frontend, and refactor require those fields when `loanLimitType != "2"`. The label/domain meaning of `LOAN_LIMIT_TYPE` is not proven by source. This is a C-class semantic risk and must be decided before Approved.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:51`; legacy checks at `EPROC00115_JS.jsp:359-379` and `EPROC00215_JS.jsp:360-380`; current backend at `CsuBorrowerGroupExposureServiceImpl.java:223-227`; current FE at `validate-rule.ts:39-41`, `:96-100`; refactor at `epl-save-c0-borrower-group-exposure.md:121-128`.

### R11 @PENDING PENDING-EPROC00115-THIRD-CURRENCY-TOTALING - 強制點: FE - covers-prd: REQ-005
Owner: PM / SA / RD.

PRD pending-004 states legacy calculation sends all non-USD currencies to KHR while query totals only explicitly total USD/KHR. Current FE internally groups arbitrary currencies but only displays USD/KHR. The to-be rule for `CCY` values other than USD/KHR must be approved; until then, third-currency acceptance must not be treated as parity.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:52`, `:117`, `:342`; legacy calculation at `EPROC0_0115_mod.java:112-126`; current FE display at `borrower-group-exposure.component.ts:306-350`.

### R12 @PENDING PENDING-EPROC00115-ROW-LIMIT - 強制點: FE - covers-prd: REQ-004
Owner: PM / SA.

PRD pending-005 says legacy uses `top.groupSize` but source does not prove the numeric value. New UI must confirm the maximum row limit or explicitly bind to a shared platform value before Approved.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:53`; legacy checks `top.groupSize` at `EPROC00115_JS.jsp:287-288` and `EPROC00215_JS.jsp:287-288`.

### R13 @PENDING PENDING-EPROC00115-BLANK-LOAN-LIMIT-FLAG - 強制點: both - covers-prd: REQ-009
Owner: SA / RD.

PRD pending-007 requires a decision on legacy `LOAN_LIMIT_TYPE is null` remediation. Legacy query returns a `queryGroupExposure` flag and forces parent tab incomplete; current info response contains only `facility` and `facilitiesList`, with no equivalent flag found. New behavior must be approved as either carry, replacement warning, or intentional removal.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:55`, `:121`, `:296`, `:348`; legacy module at `EPROC0_0115_mod.java:188-201` and `EPROC0_0215_mod.java:188-201`; legacy UI at `EPROC00115_JS.jsp:435-437` and `EPROC00215_JS.jsp:434-437`; current response DTO at `GetCsuBorrowerGroupExposureResponse.java:12-16`.

### R14 @PENDING PENDING-EPROC00115-RC-0215-CHECKPOINT - 強制點: BE - covers-prd: REQ-008
Owner: SA / RD / DBA.

PRD requires 0215/RC flow to write legacy `EPRO_TB_CHECK_POINT_RC_CORP/CU.EPROC0_0215`. Current backend and latest DB evidence expose only `TB_CHECK_POINTS_CS/CU.EPROC00115`; db-diff marks `TB_CHECK_POINT_RC_CORP/CU` removed/unused and notes migration to CS/CU. No `legacyFunctionId` discriminator was found. The owner must decide whether RC is intentionally unified into CS/CU `EPROC00115`, still missing, or handled by an upstream frame.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:66`, `:76`, `:239-240`, `:267-270`, `:343-346`; legacy RC update at `EPROC0_0215_mod.java:98-100`, `:175-177`; current branch at `CsuBorrowerGroupExposureServiceImpl.java:195-208`; db-diff notes at `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:10`, `:13`, `:44` and `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:10`, `:13`, `:43`; DB reverify has CS/CU checkpoint rows at `legacy_schema_reverify_new02_columns.tsv:120-151`.

### R15 @PENDING PENDING-EPROC00115-RC-OLD-CASE-FINISH - 強制點: both - covers-prd: REQ-006, REQ-008
Owner: PM / SA.

PRD pending-006 says legacy 0215 old case hides Finished and does not update parent done state. Current EPROC00115 frontend/backend evidence does not expose an equivalent old-case mode for this page. The to-be rule must be approved before RC old-case behavior is considered covered.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:54`, `:347`; legacy JSP hides Finished at `EPROC00215.jsp:38`; legacy JS gates parent update at `EPROC00215_JS.jsp:320-323`, `:434-437`.

### R16 @PENDING PENDING-EPROC00115-REPORT-COLLATERAL-CURRENCY - 強制點: BE - covers-prd: REQ-010
Owner: SA / RD.

PRD pending-008 flags a suspected legacy defect: some report paths display collateral currency using `OUTSTAND_AMOUNT_CUR` instead of `COLLATERAL_CUR`. This SRS does not decide whether to preserve the report defect or fix it; the decision must be made before report regression closure.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:56`; CS0180/CU0180 use `COLLATERAL_CUR` at `EPRO_CS0180.java:482-486` and `EPRO_CU0180.java:419-423`; CS0181/CU0181 use `OUTSTAND_AMOUNT_CUR` for collateral at `EPRO_CS0181.java:873-877` and `EPRO_CU0181.java:880-884`.

### R17 @PENDING PENDING-EPROC00115-FACILITY-LABEL - 強制點: FE - covers-prd: REQ-003
Owner: PM / SA.

PRD pending-002 says `FACILITY_VALUE` is displayed as Exposure of Borrower Group but uses code table `FACILITY_TYPE`. The API keeps `facility`/`FACILITY_VALUE`; the final UI label and help text must be approved to avoid confusion with other Facility Type pages.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:50`; DB label at `docs/db-diff/02_tables/TB_GROUP_EXPOSURE.md:39`; refactor select code source at `epl-sele-c0-borrower-group-exposure.md:75-76`, `:134`.

### R18 @PENDING PENDING-EPROC00115-ROUTE-MENU-NAMING - 強制點: both - covers-prd: REQ-001
Owner: PM / SA.

PRD pending-001 asks whether modern route/menu/document naming is exactly `EPROC00115`. Current page code and inventory support `EPROC00115`, but decisive menu-route source such as a final `TB_PAGE_MENU` row was not found in this worker scope.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:49`; current inventory at `docs/feature-inventory.md:102`; current frontend page code evidence was found in `frontend/src/app/core/models/pages/.../page-code.model.ts` in prior source scan but final menu DB row remains UNFOUND.

### R19 @PENDING PENDING-EPROC00115-FACILITIES-LIST-BE-VALIDATION - 強制點: BE - covers-prd: REQ-006, REQ-007
Owner: RD.

The to-be OpenAPI contract requires `facilitiesList` on save. Current DTO applies `@Valid` but not `@NotNull`, so a missing list can bypass bean validation and fail later in service iteration instead of returning a controlled EPRO validation response. RD must add backend validation or revise the contract before this error path is test-ready.

Evidence: `SaveCsuBorrowerGroupExposureRequest.java:29-31`; current save loop starts from `request.getFacilitiesList()` at `CsuBorrowerGroupExposureServiceImpl.java:128`.

### R20 @PENDING PENDING-EPROC00115-SAVE-SERVICE-AUTHZ - 強制點: BE/security - covers-prd: REQ-010
Owner: RD / Security.

Current save relies on platform API authorization and then performs delete/insert/checkpoint updates without a proven service-level case/edit guard. Before approval, backend must enforce the same case ownership/editability policy used by the surrounding corporate C0 pages, or SA/Security must explicitly approve the existing control boundary.

Evidence: platform auth rows at `docs/build-tasks/c0-authz-sql-findings.md:48-50`; save mutation sequence at `CsuBorrowerGroupExposureServiceImpl.java:109-160`.

### R21 @PENDING PENDING-EPROC00115-FE-NUMERIC-INTEGER-LIMIT - 強制點: FE - covers-prd: REQ-005, REQ-006, REQ-010
Owner: RD / SA.

The backend, DB, and refactor contract allow `LCC_AMOUNT`, `OUTSTAND_AMOUNT`, `COLLATERAL_AMOUNT`, `INTEREST_RATE`, and `LTV` at 15 integer digits plus 2 decimals. Current FE input configuration clamps those fields to `integerMaxlength: 12`, so valid backend values above 12 integer digits can be blocked in the UI and cannot be treated as end-to-end supported. RD/SA must either align FE to the 15-digit contract or approve a narrower UI/business limit before Approved.

Evidence: DB `NUMBER(17,2)` columns in `docs/db-diff/02_tables/TB_GROUP_EXPOSURE.md:41`, `:43`, `:45`, `:47`, `:50`; DTO `@CustomDigits(integer=15, fraction=2)` in `FacilitiesListRequest.java:23-25`, `:31-33`, `:39-41`, `:47-49`, `:59-61`; current FE limit at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/borrower-group-exposure/config/formarray-config.ts:102`, `:127`, `:149`, `:172`, `:203`.

## New-vs-Old DB Delta / Reconcile
| Source fact | Disposition | Rule impact | Evidence |
|---|---|---|---|
| `TB_GROUP_EXPOSURE` is active/exact with PK `APPLICATION_NO, DATA_SEQ` and 16 columns. Latest reverify matches db-diff for the listed columns and PK. | carried | R2, R3, R7, R9 | db-diff `TB_GROUP_EXPOSURE.md:13-16`, `:32`, `:38-53`; reverify columns `legacy_schema_reverify_new02_columns.tsv:1398-1413`; reverify PK `legacy_schema_reverify_new02_pk.tsv:161-162`. |
| `TB_CHECK_POINTS_CS.EPROC00115` and `TB_CHECK_POINTS_CU.EPROC00115` exist in new schema. Latest reverify matches db-diff column presence/type/nullability; db-diff carries default `'N'` while reverify column TSV does not include default text. | carried with stale-source note | R8 | db-diff `TB_CHECK_POINTS_CS.md:45`, `TB_CHECK_POINTS_CU.md:43`; reverify `legacy_schema_reverify_new02_columns.tsv:126`, `:142`; PK `..._pk.tsv:35-36`. |
| Legacy `EPRO_TB_CHECK_POINT_RC_CORP/CU.EPROC0_0215` exists in legacy source/PRD; db-diff marks the RC tables removed/unused and moved to CS/CU, while latest active new-schema evidence shows only CS/CU `EPROC00115`. | stale-source divergence / pending | R14 | PRD `:239-240`, `:267-270`; legacy `EPROC0_0215_mod.java:98-100`, `:175-177`; db-diff RC notes `TB_CHECK_POINT_RC_CORP.md:10`, `:13`, `:44` and `TB_CHECK_POINT_RC_CU.md:10`, `:13`, `:43`; new DB reverify CS/CU evidence `legacy_schema_reverify_new02_columns.tsv:120-151`. |
| `TB_LON_SUMMARY_INFO.APPLICATION_NO`, `LON_ATTRIBUTE`, `SECURE_ATTRIBUTE`, and `REF_APPLICATION_NO` are active/exact in db-diff and latest reverify; PK ownership follows db-diff/current entity because latest PK TSV has no row for this table. | carried with stale-source note | R2, R8 | db-diff `TB_LON_SUMMARY_INFO.md:13-16`, `:32`, `:38`, `:50-51`, `:56`; reverify `legacy_schema_reverify_new02_columns.tsv:1798`, `:1810-1811`, `:1816`. |
| `TB_COMMON_FIELD_OPTIONS` is active/exact and backs the four select option lists. Latest column TSV widens `MSG_CODE` to `VARCHAR2(50)` compared with db-diff `VARCHAR2(30)`, so the SRS DDL follows latest reverify for that column. | carried with stale-source note | R1 | db-diff `TB_COMMON_FIELD_OPTIONS.md:13-16`, `:32`, `:38-48`; reverify `legacy_schema_reverify_new02_columns.tsv:402-412`; reverify PK `legacy_schema_reverify_new02_pk.tsv:66-70`. |
| `TB_API_AUTH` is active/exact and EPROC00115 endpoint rows already exist in current c0 auth findings. Route/API seed rows do not prove service-level edit authorization. | carried with security guard / pending | R9, R20 | db-diff `TB_API_AUTH.md:13-16`, `:32`, `:38-40`; c0 auth findings `docs/build-tasks/c0-authz-sql-findings.md:48-50`, `:150-152`. |

## @PENDING Register
| ID | Owner | Impact | Evidence | Status |
|---|---|---|---|---|
| PENDING-EPROC00115-LOAN-LIMIT-TYPE-SEMANTICS @PENDING | SA / RD | Finished validation can reject or allow the wrong rows. | PRD pending-003; legacy `== "1" or blank`; current/refactor `!= "2"`. | Open |
| PENDING-EPROC00115-THIRD-CURRENCY-TOTALING @PENDING | PM / SA / RD | Query and live totals can diverge for non-USD/KHR currencies. | PRD pending-004; legacy/current totals evidence. | Open |
| PENDING-EPROC00115-ROW-LIMIT @PENDING | PM / SA | Maximum row count cannot be tested until global value is known. | PRD pending-005; `top.groupSize` usage. | Open |
| PENDING-EPROC00115-BLANK-LOAN-LIMIT-FLAG @PENDING | SA / RD | Old-data remediation may be lost. | PRD pending-007; legacy `queryGroupExposure`; current response gap. | Open |
| PENDING-EPROC00115-RC-0215-CHECKPOINT @PENDING | SA / RD / DBA | 0215/RC checkpoint parity cannot be closed. | PRD REQ-008 and latest new schema gap. | Open |
| PENDING-EPROC00115-RC-OLD-CASE-FINISH @PENDING | PM / SA | Old renewal/change case may incorrectly allow Finished. | PRD pending-006; legacy `attrMap.isOld`. | Open |
| PENDING-EPROC00115-REPORT-COLLATERAL-CURRENCY @PENDING | SA / RD | Report regression decision needed for suspected legacy defect. | PRD pending-008; CS/CU report source mismatch. | Open |
| PENDING-EPROC00115-FACILITY-LABEL @PENDING | PM / SA | UI naming can confuse `FACILITY_VALUE` with other Facility Type usage. | PRD pending-002; DB/refactor code source. | Open |
| PENDING-EPROC00115-ROUTE-MENU-NAMING @PENDING | PM / SA | Final route/menu/doc references may need adjustment. | PRD pending-001; menu row proof UNFOUND. | Open |
| PENDING-EPROC00115-FACILITIES-LIST-BE-VALIDATION @PENDING | RD | Missing save list can produce an uncontrolled server error instead of validation response. | DTO has `@Valid` but no `@NotNull`; service iterates list. | Open |
| PENDING-EPROC00115-SAVE-SERVICE-AUTHZ @PENDING | RD / Security | Direct save may mutate rows after API auth without proven case/edit guard. | Save sequence has delete/insert/checkpoint writes; guard proof UNFOUND. | Open |
| PENDING-EPROC00115-FE-NUMERIC-INTEGER-LIMIT @PENDING | RD / SA | FE can reject DB/BE-valid 15-integer-digit money/rate/LTV values. | DB/DTO allow 15 integer digits; FE input config clamps to 12. | Open |

## Traceability
| PRD requirement | SRS rules | QA |
|---|---|---|
| REQ-001 | R1, R2, R18 | QA-001, QA-002, QA-003, QA-P09 |
| REQ-002 | R2 | QA-002, QA-003, QA-004 |
| REQ-003 | R3, R17 | QA-005, QA-P08 |
| REQ-004 | R4, R12 | QA-006, QA-P03 |
| REQ-005 | R5, R11, R21 | QA-007, QA-P02, QA-P12 |
| REQ-006 | R6, R10, R15, R19, R21 | QA-008, QA-009, QA-P01, QA-P06, QA-P10, QA-P12 |
| REQ-007 | R7, R19 | QA-010, QA-011, QA-012, QA-P10 |
| REQ-008 | R8, R14, R15 | QA-013, QA-014, QA-P05, QA-P06 |
| REQ-009 | R13 | QA-P04 |
| REQ-010 | R9, R16, R20, R21 | QA-015, QA-016, QA-P07, QA-P11, QA-P12 |

## Source Gaps
- `docs/specs/prd/trace-CDC-EPRO-0001-EPROC00115.md` was not present, so Bible-to-PRD sidecar trace could not be verified by this worker.
- Final menu route row proof for EPROC00115 was UNFOUND in this worker scope.
- Latest reverify TSV search found CS/CU checkpoint tables but no active RC checkpoint table; db-diff marks RC checkpoint tables removed/unused and moved to CS/CU, so final 0215 mapping remains an owner decision.
