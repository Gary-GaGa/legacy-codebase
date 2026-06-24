# SRS - EPROC00115 Borrower Group Exposure

## Metadata
| Field | Value |
|---|---|
| FuncId | EPROC00115 |
| Status | In Review / ready-for-owner-finalization; awaiting human approval |
| N-axis review | Earlier axis-A blocker fixed 2026-06-23. Owner decisions on 2026-06-24 closed the remaining rule-level pending items: orphan platform codes are retained only as platform/business envelope codes where carried by current code, and save authorization is fixed as a two-layer contract (`TB_API_AUTH` plus backend case/edit guard). Final A-F review is still required before owner stamp. |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md` |
| Legacy source | `EPROC0_0115`, `EPROC0_0215`, `EPROC00115.jsp`, `EPROC00215.jsp`, `EPRO_TB_GROUP_EXPOSURE` |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`; `qa-cases.md` is intentionally absent while QA generation/acceptance is paused on 2026-06-24. |

## Scope
- In scope: C0 Borrower Group Exposure initialization, option lookup, detail query, Save/Finished save, full replacement of `TB_GROUP_EXPOSURE`, checkpoint update, totals behavior, cross-module read compatibility, and DB/schema reconcile for the current EPROC00115 page.
- Out of scope: changing implementation code or self-promoting this SRS to Approved.
- Current contract uses the real RPC endpoints `epl-sele-c0-borrower-group-exposure`, `epl-info-c0-borrower-group-exposure`, and `epl-save-c0-borrower-group-exposure`; the PRD `/api/epro/eproc00115/*` draft is not used.

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD | PRD old codes and scope at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:15`, `:40`; formerly pending items at `:49-57`; requirements at `:113-122`. | Owner decisions on 2026-06-24 close the formerly pending business items; requirements map to R1-R21. |
| Dispatch | Real endpoint and SRS bundle rules at `docs/build-tasks/prd-to-srs-codex-dispatch.md:53`, `:102-110`, `:115-117`. | Use only `epl-*`; produce exactly four files. |
| Legacy 0115/0215 | Legacy loads four code tables at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0115_mod.java:49-52` and `EPROC0_0215_mod.java:49-52`; full replacement and rollback at `EPROC0_0115_mod.java:168-182` and `EPROC0_0215_mod.java:168-182`; RC checkpoint at `EPROC0_0215_mod.java:98-100`, `:175-177`. | Preserve shared data behavior. Per owner decision 2026-06-24 and new-schema evidence, RC 0215 checkpoint behavior is unified into CS/CU `EPROC00115`. |
| Current backend | Controller exposes POST endpoints at `backend/src/main/java/khd/svc/epro/controller/corporate/CsuBorrowerGroupExposureController.java:23`, `:30`, `:37`, `:44`. Service reads, saves, and checkpoints at `CsuBorrowerGroupExposureServiceImpl.java:65-73`, `:113-160`, `:195-208`, `:211-227`. | Current backend is the API grounding. |
| Current frontend | API service calls the same endpoints at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/borrower-group-exposure/services/api.service.ts:27`, `:36`, `:45`; totals display only USD/KHR at `borrower-group-exposure.component.ts:306-350`. | FE totals are carried for USD/KHR only; other currencies must be rejected or normalized before save/query use. |
| Refactor spec | Endpoint metadata and payload rules at `docs/refactor-spec/03_artifacts/be-corporate/EPROC00115/epl-info-c0-borrower-group-exposure.md:109-111`, `:183-192`; save rules at `epl-save-c0-borrower-group-exposure.md:96-128`, `:153-179`; select rules at `epl-sele-c0-borrower-group-exposure.md:114-167`. | Refactor spec quantifies DTO lengths, required fields, and table writes. |
| DB diff and reverify | `TB_GROUP_EXPOSURE` active/exact at `docs/db-diff/02_tables/TB_GROUP_EXPOSURE.md:13-16`, columns at `:38-53`; `TB_COMMON_FIELD_OPTIONS` active/exact at `docs/db-diff/02_tables/TB_COMMON_FIELD_OPTIONS.md:13-16`, columns at `:38-48`; latest reverify confirms group exposure columns at `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:1398-1413` and PK at `..._pk.tsv:161-162`. | `schema.sql` follows latest reverify, with stale-source divergences called out. |
| Auth | `TB_API_AUTH` shape at `docs/db-diff/02_tables/TB_API_AUTH.md:13-16`, `:32`, `:38-40`; EPROC00115 endpoint rows at `docs/build-tasks/c0-authz-sql-findings.md:48-50`. | Endpoint seed evidence exists; mutating calls must also enforce backend case/edit authorization per owner policy 2026-06-24. |
| Inventory | Feature inventory marks EPROC00115 BE/FE present with these endpoints at `docs/feature-inventory.md:102`; matrix marks SRS generation at `docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md:138`. | This bundle fills that page-level SRS output. |

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
The UI must support adding and deleting exposure rows while preventing deletion of the final row. It must not call save with an unintended empty list caused by deleting all visible rows. `COMMON_MSG_ONE_DATA` is a UI-only prompt for this guard, not an API error response. The maximum row count must follow the legacy injected `top.groupSize` configuration for `com.cathaybk.epro.i0.module.EPROI0_0115.size`; neither FE nor BE may hard-code a different limit without a later change request.

Evidence: legacy parent JSP injects `groupSize` from `com.cathaybk.epro.i0.module.EPROI0_0115.size` at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp:37` and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp:35`; legacy delete/add guards raise `COMMON_MSG_ONE_DATA` and check `top.groupSize` at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00115_JS.jsp:267`, `:287-288` and `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00215_JS.jsp:267`, `:287-288`; current frontend maps the form array to `facilitiesList` at `borrower-group-exposure.component.ts:277-293`.

### R5 Calculate and display USD/KHR totals without a separate API - 強制點: FE - covers-prd: REQ-005
There is no current/refactor standalone calculate endpoint for EPROC00115. The UI must calculate visible totals client-side from the same form rows that are sent to save. Owner decision 2026-06-24 fixes the to-be display contract to USD and KHR totals for LCC and Outstanding only. `CCY` values outside USD/KHR must not be treated as supported total currencies for this page. LCC totals must bucket by `lccAmountCur`; Outstanding totals must bucket by `outstandAmountCur`. Current FE evidence that buckets LCC by `outstandAmountCur` is treated as a suspected bug to fix under policy 2, not as the target contract.

Evidence: legacy query totals cover LCC by `LCC_AMOUNT_CUR` and Outstanding by `OUTSTAND_AMOUNT_CUR` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0115_mod.java:61-81`, `:94-97`, and calculation sends non-USD to KHR at `:112-126`; current FE accumulates using `outstandAmountCur` for the current LCC bucket at `borrower-group-exposure.component.ts:306-314` and patches only `CA_USD`, `CA_KHR`, `OB_USD`, and `OB_KHR` at `borrower-group-exposure.component.ts:306-350`.

### R6 Save draft vs Finished validation and checkpoint polarity - 強制點: BE - covers-prd: REQ-006
Save and Finished use the same save endpoint. `isFinish=false` is draft Save and updates `EPROC00115` checkpoint to `Y`; `isFinish=true` is Finished and updates checkpoint to `N`. Save draft still validates request shape and numeric/date formats, but Finished adds row-level required-field checks. The conditional Outstanding/Maturity branch follows current/refactor behavior: Outstanding Amount and Maturity Date are required when `loanLimitType != "2"`. This retains the current contract with an explicit assumption that code `"2"` is the only non-outstanding loan-limit type.

Evidence: current save request requires `isFinish` at `SaveCsuBorrowerGroupExposureRequest.java:20-22`; current service validates full row fields only when `isFinish` is true at `CsuBorrowerGroupExposureServiceImpl.java:113-119`; checkpoint polarity is implemented at `:158`. Legacy save passes `check=Y` and Finished passes `check=N` in `EPROC00115_JS.jsp:335-390`.

### R7 Save by full replacement in one transaction - 強制點: BE - covers-prd: REQ-007
Saving must delete existing `TB_GROUP_EXPOSURE` rows for the request `applicationNo`, insert the submitted list with `DATA_SEQ` assigned from 1 in request order, and update the checkpoint in the same transaction. Any failure after delete, including insert or checkpoint update failure, must roll back the delete and all inserts.

The backend must set `APPLICATION_NO` from request `applicationNo`, not from row content. This closes PRD pending-009 as an implementation requirement because current/refactor evidence already uses the request-level value.

Evidence: current save is `@Transactional(rollbackFor = Exception.class)` and deletes then inserts at `CsuBorrowerGroupExposureServiceImpl.java:109-160`; request-level `applicationNo` is assigned to each row at `:113`, `:133`; legacy transaction rolls back on exception at `EPROC0_0115_mod.java:168-182` and `EPROC0_0215_mod.java:168-182`.

### R8 Route checkpoint by CS/CU in the new schema - 強制點: BE - covers-prd: REQ-008
For the current new schema, corporate secured cases write `TB_CHECK_POINTS_CS.EPROC00115` and corporate unsecured cases write `TB_CHECK_POINTS_CU.EPROC00115`, using `TBLonSummaryInfo.LON_ATTRIBUTE + SECURE_ATTRIBUTE` as the branch key. Unsupported or missing summary attributes must fail with `E126` and must not write exposure rows.

Legacy `EPROC0_0215` RC-specific checkpoint tables are marked removed/unused in db-diff with a note that they moved to CS/CU. Owner decision 2026-06-24 confirms RC 0215 is intentionally unified into the new CS/CU `EPROC00115` checkpoint columns; no separate RC checkpoint table is part of this SRS.

Evidence: current branch logic chooses CS/CU tables at `CsuBorrowerGroupExposureServiceImpl.java:195-208`; new DB columns exist at `TB_CHECK_POINTS_CS.md:45` and `TB_CHECK_POINTS_CU.md:43`; latest reverify confirms `EPROC00115` in CS/CU at `legacy_schema_reverify_new02_columns.tsv:126`, `:142`.

### R9 Enforce auth, editability, safe errors, and cross-module consumers - 強制點: both - covers-prd: REQ-010
All three endpoints require platform API authorization using their exact `TB_API_AUTH.API_ID` rows. Mutating calls must also enforce backend-owned case/edit authorization before DB writes; UI hidden/disabled controls are not sufficient. Error handling must carry PRD/current platform codes where applicable: `E102`, `E126`, `E130`, `E201`, `E405`/access denied, `E498`, `E999`, `MSG_DATA_NOT_FOUND`, `MSG_OVER_COUNT_LIMIT`, `MSG_QUERY_FAIL`, `COMMON_MSG_ERROR_LON`, and `COMMON_MSG_SAVE_FAIL`. Current successful API responses use the EPRO envelope `code=0000`, `message=Success`, and endpoint-specific `data`; save currently returns an empty `data` object. Current `ReturnEnum` business errors use the normal EPRO response envelope; HTTP 401 is reserved for authorization or auth-context failures: `E405` means authorization denied, and `E498` means the auth/session context is invalid or unusable for the request. `COMMON_MSG_SAVE_SUCCESS` and `COMMON_MSG_TOTAL_FAIL` are legacy/UI message references and must not be modeled as raw API response bodies for these three endpoints. Safe logs must not include full sensitive payloads.

`TB_GROUP_EXPOSURE` is a shared data source for report and score modules; SRS changes must not alter columns, `DATA_SEQ` ordering, or LCC/Outstanding/Collateral field meaning without explicit cross-module decision.

Evidence: auth rows are listed at `docs/build-tasks/c0-authz-sql-findings.md:48-50`; API auth table shape is at `docs/db-diff/02_tables/TB_API_AUTH.md:38-40`; score modules read `LCC_AMOUNT_CUR`/`LCC_AMOUNT` at `EPROCS_0170_mod.java:1295-1300`, `EPROCS_0270_mod.java:1393-1398`, `EPROCU_0170_mod.java:1155-1160`, `EPROCU_0270_mod.java:1241-1246`; reports read rows ordered by `DATA_SEQ` and amount columns at `EPRO_CS0180.java:452-486`, `EPRO_CU0180.java:389-423`.

### R10 Final loan-limit-type semantics - 強制點: both - covers-prd: REQ-006
Decision: owner 2026-06-24.

Outstanding Amount, Outstanding Currency, Tenor, Maturity Date, Collateral Currency, and Collateral Amount are required on Finished when `loanLimitType != "2"`. This deliberately follows current backend/current frontend/refactor behavior. The assumption is that code `"2"` is the only loan-limit type that does not require the Outstanding/Maturity branch; changing that domain meaning requires a later owner change.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:51`; legacy checks at `EPROC00115_JS.jsp:359-379` and `EPROC00215_JS.jsp:360-380`; current backend at `CsuBorrowerGroupExposureServiceImpl.java:223-227`; current FE at `validate-rule.ts:39-41`, `:96-100`; refactor at `epl-save-c0-borrower-group-exposure.md:121-128`.

### R11 Final third-currency totaling rule - 強制點: FE - covers-prd: REQ-005
Decision: owner 2026-06-24.

The to-be contract supports only USD and KHR visible totals. Rows with `CCY` values outside USD/KHR must not be counted into a hidden third bucket for this page. If such a value is accepted by the option source, the page must either reject it before save/query totals are committed or display it as unsupported; it must not silently fold into KHR.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:52`, `:117`, `:342`; legacy calculation at `EPROC0_0115_mod.java:112-126`; current FE display at `borrower-group-exposure.component.ts:306-350`.

### R12 Final row-limit source - 強制點: FE - covers-prd: REQ-004
Decision: owner 2026-06-24.

The row limit source is the legacy injected `top.groupSize` value, configured from `com.cathaybk.epro.i0.module.EPROI0_0115.size` in the parent JSP. The SRS intentionally does not invent a literal number. New UI and backend validation must bind to the same platform/config value or an explicitly migrated equivalent.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:53`; legacy parent JSP injects `groupSize` from `com.cathaybk.epro.i0.module.EPROI0_0115.size` at `EPROC00110.jsp:37` and `EPROC00210.jsp:35`; legacy checks `top.groupSize` at `EPROC00115_JS.jsp:287-288` and `EPROC00215_JS.jsp:287-288`.

### R13 Final blank loan-limit remediation - 強制點: both - covers-prd: REQ-009
Decision: owner 2026-06-24.

If persisted exposure rows contain blank `LOAN_LIMIT_TYPE`, the info endpoint must reject the query with a controlled business error that forces data remediation before the page can be treated as complete. The new contract does not carry a silent `queryGroupExposure` flag and does not mark the parent tab complete while blank legacy data remains.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:55`, `:121`, `:296`, `:348`; legacy module at `EPROC0_0115_mod.java:188-201` and `EPROC0_0215_mod.java:188-201`; legacy UI at `EPROC00115_JS.jsp:435-437` and `EPROC00215_JS.jsp:434-437`; current response DTO at `GetCsuBorrowerGroupExposureResponse.java:12-16`.

### R14 Final RC 0215 checkpoint mapping - 強制點: BE - covers-prd: REQ-008
Decision: owner 2026-06-24.

RC 0215 is intentionally unified into the new CS/CU checkpoint columns. Finished and draft saves for the modern EPROC00115 page write `TB_CHECK_POINTS_CS.EPROC00115` or `TB_CHECK_POINTS_CU.EPROC00115` according to the same branch logic as R8. No `EPRO_TB_CHECK_POINT_RC_CORP/CU` target is recreated by this SRS.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:66`, `:76`, `:239-240`, `:267-270`, `:343-346`; legacy RC update at `EPROC0_0215_mod.java:98-100`, `:175-177`; current branch at `CsuBorrowerGroupExposureServiceImpl.java:195-208`; db-diff notes at `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:10`, `:13`, `:44` and `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:10`, `:13`, `:43`; DB reverify has CS/CU checkpoint rows at `legacy_schema_reverify_new02_columns.tsv:120-151`.

### R15 Final RC old-case Finished behavior - 強制點: both - covers-prd: REQ-006, REQ-008
Decision: owner 2026-06-24.

The modern EPROC00115 page does not preserve a separate RC old-case mode. Finished remains available under the normal editability and validation rules, and checkpoint update follows R8/R14. Any upstream old-case restriction must be enforced by the frame/workflow layer before this page is entered.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:54`, `:347`; legacy JSP hides Finished at `EPROC00215.jsp:38`; legacy JS gates parent update at `EPROC00215_JS.jsp:320-323`, `:434-437`.

### R16 Final report collateral currency rule - 強制點: BE - covers-prd: REQ-010
Decision: owner 2026-06-24.

Suspected report paths that display collateral currency using `OUTSTAND_AMOUNT_CUR` are treated as legacy bugs. To-be report/read consumers must use `COLLATERAL_CUR` for collateral currency and must not copy the wrong outstanding-currency source.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:56`; CS0180/CU0180 use `COLLATERAL_CUR` at `EPRO_CS0180.java:482-486` and `EPRO_CU0180.java:419-423`; CS0181/CU0181 use `OUTSTAND_AMOUNT_CUR` for collateral at `EPRO_CS0181.java:873-877` and `EPRO_CU0181.java:880-884`.

### R17 Final facility label - 強制點: FE - covers-prd: REQ-003
Decision: owner 2026-06-24.

The UI label for `facility` / `FACILITY_VALUE` is `Group/Exposure` for this page. The API and DB names stay unchanged, and the select source remains `FACILITY_TYPE`.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:50`; DB label at `docs/db-diff/02_tables/TB_GROUP_EXPOSURE.md:39`; refactor select code source at `epl-sele-c0-borrower-group-exposure.md:75-76`, `:134`.

### R18 Final route/menu naming - 強制點: both - covers-prd: REQ-001
Decision: owner 2026-06-24.

The modern page identity is `EPROC00115`. Current feature inventory and page mapping use `EPROC00115`, and `TB_PAGE_MENU` is the route/menu data source. No separate c0 borrower-group-exposure page code is introduced by this SRS.

Evidence: PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md:49`; current inventory at `docs/feature-inventory.md:102`; page mapping at `docs/legacy/page-mapping.md:87`; `TB_PAGE_MENU` table and route-key shape at `docs/db-diff/02_tables/TB_PAGE_MENU.md:13-16` and `docs/legacy/db-schema-catalog.md:68-69`.

### R19 Final facilities-list backend validation - 強制點: BE - covers-prd: REQ-006, REQ-007
Decision: owner 2026-06-24 / agent code check.

The to-be OpenAPI contract requires `facilitiesList` on save. Backend validation must reject a missing or null list before service iteration and return a controlled EPRO validation response. Current DTO has `@Valid` but not `@NotNull`, so implementation must add the missing guard; the SRS contract remains strict rather than weakening the request schema.

Evidence: `SaveCsuBorrowerGroupExposureRequest.java:29-31`; current save loop starts from `request.getFacilitiesList()` at `CsuBorrowerGroupExposureServiceImpl.java:128`.

### R20 Final save service authorization - 強制點: BE/security - covers-prd: REQ-010
Decision: owner policy 2026-06-24.

Save/Finished authorization is two-layer: platform `TB_API_AUTH` must allow the exact save API, and the service layer must independently enforce case ownership/editability before delete/insert/checkpoint mutation. FE-disabled controls and API seed rows alone are insufficient. Current implementation evidence does not prove the second-layer guard, so RD must close that conformance gap before implementation Done; the SRS decision itself is closed by owner policy.

Evidence: platform auth rows at `docs/build-tasks/c0-authz-sql-findings.md:48-50`; owner policy in `docs/build-tasks/srs-finalize-c0-115-119-120.md:23-25`; save mutation sequence at `CsuBorrowerGroupExposureServiceImpl.java:109-160`.

### R21 Final FE numeric integer limit alignment - 強制點: FE - covers-prd: REQ-005, REQ-006, REQ-010
Decision: agent code/schema reconciliation under owner finalize card.

The to-be contract follows backend/DB/refactor precision: `LCC_AMOUNT`, `OUTSTAND_AMOUNT`, `COLLATERAL_AMOUNT`, `INTEREST_RATE`, and `LTV` allow 15 integer digits plus 2 decimals. Current FE `integerMaxlength: 12` is an implementation conformance gap; FE must align to the 15+2 contract before implementation Done, unless a later approved change narrows both API and DB-facing validation. This is not an open SRS decision.

Evidence: DB `NUMBER(17,2)` columns in `docs/db-diff/02_tables/TB_GROUP_EXPOSURE.md:41`, `:43`, `:45`, `:47`, `:50`; DTO `@CustomDigits(integer=15, fraction=2)` in `FacilitiesListRequest.java:23-25`, `:31-33`, `:39-41`, `:47-49`, `:59-61`; current FE limit at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/borrower-group-exposure/config/formarray-config.ts:102`, `:127`, `:149`, `:172`, `:203`.

## New-vs-Old DB Delta / Reconcile
| Source fact | Disposition | Rule impact | Evidence |
|---|---|---|---|
| `TB_GROUP_EXPOSURE` is active/exact with PK `APPLICATION_NO, DATA_SEQ` and 16 columns. Latest reverify matches db-diff for the listed columns and PK. | carried | R2, R3, R7, R9 | db-diff `TB_GROUP_EXPOSURE.md:13-16`, `:32`, `:38-53`; reverify columns `legacy_schema_reverify_new02_columns.tsv:1398-1413`; reverify PK `legacy_schema_reverify_new02_pk.tsv:161-162`. |
| `TB_CHECK_POINTS_CS.EPROC00115` and `TB_CHECK_POINTS_CU.EPROC00115` exist in new schema. Latest reverify matches db-diff column presence/type/nullability; db-diff carries default `'N'` while reverify column TSV does not include default text. The SRS keeps the db-diff default because the latest column TSV has no default field; this is a default-source exception, not a column-shape conflict. | carried with stale-source note | R8, R14 | db-diff `TB_CHECK_POINTS_CS.md:45`, `TB_CHECK_POINTS_CU.md:43`; reverify `legacy_schema_reverify_new02_columns.tsv:126`, `:142`; PK `..._pk.tsv:35-36`; defaults file has no `TB_CHECK_POINTS_CS/CU` default row. |
| Legacy `EPRO_TB_CHECK_POINT_RC_CORP/CU.EPROC0_0215` exists in legacy source/PRD; db-diff marks the RC tables removed/unused and moved to CS/CU, while latest active new-schema evidence shows only CS/CU `EPROC00115`. | owner-closed divergence: RC unified into CS/CU | R14 | PRD `:239-240`, `:267-270`; legacy `EPROC0_0215_mod.java:98-100`, `:175-177`; db-diff RC notes `TB_CHECK_POINT_RC_CORP.md:10`, `:13`, `:44` and `TB_CHECK_POINT_RC_CU.md:10`, `:13`, `:43`; new DB reverify CS/CU evidence `legacy_schema_reverify_new02_columns.tsv:120-151`; owner card `docs/build-tasks/srs-finalize-c0-115-119-120.md:29`. |
| `TB_LON_SUMMARY_INFO.APPLICATION_NO`, `LON_ATTRIBUTE`, `SECURE_ATTRIBUTE`, and `REF_APPLICATION_NO` are active/exact in db-diff and latest reverify; PK ownership follows db-diff/current entity because latest PK TSV has no row for this table. | carried with stale-source note | R2, R8 | db-diff `TB_LON_SUMMARY_INFO.md:13-16`, `:32`, `:38`, `:50-51`, `:56`; reverify `legacy_schema_reverify_new02_columns.tsv:1798`, `:1810-1811`, `:1816`. |
| `TB_COMMON_FIELD_OPTIONS` is active/exact and backs the four select option lists. Latest column TSV widens `MSG_CODE` to `VARCHAR2(50)` compared with db-diff `VARCHAR2(30)`, so the SRS DDL follows latest reverify for that column. | carried with stale-source note | R1 | db-diff `TB_COMMON_FIELD_OPTIONS.md:13-16`, `:32`, `:38-48`; reverify `legacy_schema_reverify_new02_columns.tsv:402-412`; reverify PK `legacy_schema_reverify_new02_pk.tsv:66-70`. |
| `TB_API_AUTH` is active/exact and EPROC00115 endpoint rows already exist in current c0 auth findings. Route/API seed rows do not replace service-level edit authorization. | carried with two-layer security guard | R9, R20 | db-diff `TB_API_AUTH.md:13-16`, `:32`, `:38-40`; c0 auth findings `docs/build-tasks/c0-authz-sql-findings.md:48-50`, `:150-152`; owner policy `docs/build-tasks/srs-finalize-c0-115-119-120.md:23-25`. |

## Decision Register
| ID | Owner | Impact | Evidence | Status |
|---|---|---|---|---|
| DEC-EPROC00115-LOAN-LIMIT-TYPE-SEMANTICS | SA / RD | Finished validation follows current/refactor `!= "2"` rule. | PRD pending-003; legacy `== "1" or blank`; current/refactor `!= "2"`. | Closed by owner decision 2026-06-24. |
| DEC-EPROC00115-THIRD-CURRENCY-TOTALING | PM / SA / RD | Only USD/KHR totals are supported. | PRD pending-004; legacy/current totals evidence. | Closed by owner decision 2026-06-24. |
| DEC-EPROC00115-ROW-LIMIT | PM / SA | Maximum row count binds to legacy `top.groupSize` config source. | PRD pending-005; `top.groupSize` usage. | Closed by owner decision 2026-06-24. |
| DEC-EPROC00115-BLANK-LOAN-LIMIT-FLAG | SA / RD | Blank `LOAN_LIMIT_TYPE` must block query completion and force remediation. | PRD pending-007; legacy `queryGroupExposure`; current response gap. | Closed by owner decision 2026-06-24. |
| DEC-EPROC00115-RC-0215-CHECKPOINT | SA / RD / DBA | 0215/RC checkpoint parity is unified into CS/CU `EPROC00115`. | PRD REQ-008 and latest new schema evidence. | Closed by owner decision 2026-06-24. |
| DEC-EPROC00115-RC-OLD-CASE-FINISH | PM / SA | Modern page does not preserve separate old-case finish hiding. | PRD pending-006; legacy `attrMap.isOld`. | Closed by owner decision 2026-06-24. |
| DEC-EPROC00115-REPORT-COLLATERAL-CURRENCY | SA / RD | Reports use `COLLATERAL_CUR`; wrong outstanding-currency source is a bug. | PRD pending-008; CS/CU report source mismatch. | Closed by owner decision 2026-06-24. |
| DEC-EPROC00115-FACILITY-LABEL | PM / SA | UI label is `Group/Exposure`. | PRD pending-002; DB/refactor code source. | Closed by owner decision 2026-06-24. |
| DEC-EPROC00115-ROUTE-MENU-NAMING | PM / SA | Modern page identity remains `EPROC00115`. | PRD pending-001; feature inventory/page mapping/TB_PAGE_MENU schema. | Closed by owner decision 2026-06-24. |
| DEC-EPROC00115-FACILITIES-LIST-BE-VALIDATION | RD | Save must reject missing/null `facilitiesList` with controlled validation. | DTO has `@Valid` but no `@NotNull`; service iterates list. | Closed as to-be implementation requirement. |
| DEC-EPROC00115-SAVE-SERVICE-AUTHZ | RD / Security | Save/Finished requires `TB_API_AUTH` plus service-level case/edit guard. | Save sequence has delete/insert/checkpoint writes; owner policy 2026-06-24. | SRS decision closed by owner policy 2026-06-24; RD conformance evidence pending. |
| DEC-EPROC00115-FE-NUMERIC-INTEGER-LIMIT | RD / SA | FE must align to BE/DB 15+2 numeric precision. | DB/DTO allow 15 integer digits; FE input config clamps to 12. | SRS decision closed as to-be requirement; RD conformance evidence pending. |

## Traceability
| PRD requirement | SRS rules | Verification status |
|---|---|---|
| REQ-001 | R1, R2, R18 | SRS A-F review; QA generation deferred while QA flow is paused. |
| REQ-002 | R2 | SRS A-F review; QA generation deferred while QA flow is paused. |
| REQ-003 | R3, R17 | SRS A-F review; QA generation deferred while QA flow is paused. |
| REQ-004 | R4, R12 | SRS A-F review; QA generation deferred while QA flow is paused. |
| REQ-005 | R5, R11, R21 | SRS A-F review; QA generation deferred while QA flow is paused. |
| REQ-006 | R6, R10, R15, R19, R21 | SRS A-F review; QA generation deferred while QA flow is paused. |
| REQ-007 | R7, R19 | SRS A-F review; QA generation deferred while QA flow is paused. |
| REQ-008 | R8, R14, R15 | SRS A-F review; QA generation deferred while QA flow is paused. |
| REQ-009 | R13 | SRS A-F review; QA generation deferred while QA flow is paused. |
| REQ-010 | R9, R16, R20, R21 | SRS A-F review; QA generation deferred while QA flow is paused. |

## Source Gaps
- `docs/specs/prd/trace-CDC-EPRO-0001-EPROC00115.md` was not present, so Bible-to-PRD sidecar trace could not be verified by this worker.
- Final `TB_PAGE_MENU` row data was not present in this repo; route/menu identity is closed from owner decision plus inventory/page-mapping/schema evidence, not from row-data proof.
- Latest reverify TSV search found CS/CU checkpoint tables but no active RC checkpoint table; owner decision 2026-06-24 closes the modern mapping as CS/CU `EPROC00115`.
