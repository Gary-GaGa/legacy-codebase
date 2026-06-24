# SRS - EPROC00119 Financial Statement FI

## Metadata
| Field | Value |
|---|---|
| FuncId | EPROC00119 |
| Status | In Review / ready-for-owner-finalization; awaiting human approval |
| N-axis review | 2026-06-24 finalize pass applies owner decisions for RP40-RP54. Mechanical gate and A-F review are required before owner finalization; QA axis G remains paused. |
| Owner | SA / Credit decision domain / RD |
| Upstream PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00119-v1.0.md` |
| As-is source | Legacy `EPROC0_0119` + `EPROC0_0219`; current corporate code at commit `3dfebcf`; formal corporate refactor baseline UNFOUND and not invented |
| Bundle files | `spec.md`, `openapi.yaml`, `schema.sql`; `qa-cases.md` intentionally absent while QA generation is paused |

## Scope
- In scope: C0 Financial Statement FI option/info/reference-query/calc/save/export contract, FI main/Balance/Income/Cashflow persistence, checkpoint update, CS/CU checkpoint routing, DB/refactor reconcile, and legacy parity risk registration.
- Out of scope: GI financial statement, downstream FI financial evaluation calculations, report-template redesign, implementation code changes, and approval to close i0-mirror parity.
- Contract endpoints are current POST RPC paths: `epl-sele-c0-financial-statement-comments`, `epl-info-c0-financial-statement-cmts-fi`, `epl-quer-c0-financial-statement-cmts-fi`, `epl-calc-c0-financial-statement-cmts-fi`, `epl-save-c0-financial-statement-cmts-fi`, `epl-pxls-c0-financial-statement-cmts-fi`, and `epl-ppdf-c0-financial-statement-cmts-fi`. Legacy `inti/init`, `search`, `calculation`, `save`, `print`, and `printPDF` are evidence, not public API paths.

## Assumptions And Dependencies
- This page is T1 corporate because FI financial statement data feeds financial evaluation and checkpoint completion.
- Formal corporate refactor-spec module `docs/refactor-spec/02_modules/EPROC00119.md` is UNFOUND. Owner policy 1 closes this SRS baseline gap by using old corporate legacy plus current corporate code at commit `3dfebcf` as code-as-baseline, with the disclaimer that no formal corporate artifact is being fabricated.
- Existing `docs/feature-inventory.md:106` records the F-8 select-options fix and calls out export-template verification. That is carried as evidence, not as implementation approval.
- Corporate c0 parity reopen remains open at `docs/pending-register.md:26`; this bundle closes only the page-specific EPROC00119 RP40-RP54 items for SRS finalization.
- Current implementation gaps called out below are RD/DBA conformance work after SRS finalization; they are not open SRS decisions.

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD | Scope and old systems at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00119-v1.0.md:9-23`, `:39-45`; prior open issues at `:52-61`; APIs at `:194-284`; data model at `:288-326`; quality requirements at `:406-412`. | Behavior becomes R1-R10; prior open PRD issues are closed by DEC-RP41 through DEC-RP50. |
| Refactor spec | `docs/refactor-spec/02_modules/EPROC00119.md` is missing; search only found individual `EPROI00119` artifacts and generic 00116 c0 GI artifacts. | DEC-RP40 applies owner policy 1: code-as-baseline with explicit disclaimer and commit SHA. |
| Current backend | Corporate FI controller exposes query at `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementCmtsFiController.java:40`, info `:53`, calc `:66`, pxls `:79`, ppdf `:92`, save `:105`; service info at `CsuFinancialStatementCmtsFiServiceImpl.java:147-174`, calc/checkpoint side effect at `:285-331`, export validation at `:338-476`, transactional save and `EPROC00120` seed at `:494-556`, checkpoint routing at `:3170-3180`. | Current implementation anchors real RPC paths and is used as code-as-baseline where formal baseline is missing. Known mismatches are recorded as RD conformance gaps. |
| Current frontend | FI service calls info/query/save/calc at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-statement/financial-statement-fi/services/api.service.ts:40`, `:72`, `:85`, `:94`; report service calls pxls/ppdf at `frontend/src/app/core/services/report/report.service.ts:81`, `:91`. | Confirms current FE route usage and export paths. |
| Legacy parity task | 00119 maps to `EPROC0_0119` plus `0219`, and F-8 needs old-system confirmation at `docs/build-tasks/c0-legacy-parity-recheck.md:28`; c0 parity SOP says compare to old corporate, not i0, at `:12`, `:48-55`. | Code-as-baseline uses old corporate plus current corporate code; individual i0 artifacts remain non-authoritative for corporate as-is. |
| DB snapshot | `TB_FIN_STATEMENT_MAIN` active/exact with main fields at `docs/db-diff/02_tables/TB_FIN_STATEMENT_MAIN.md:13-37`; `TB_FIN_STATEMENT_BALANCE_FI` active/exact with 79 columns at `TB_FIN_STATEMENT_BALANCE_FI.md:13-33`; `TB_FIN_STATEMENT_INCOME_FI` active/exact at `TB_FIN_STATEMENT_INCOME_FI.md:13-37`; `TB_FIN_STATEMENT_CASHFLOW_FI` active/exact but column-name extraction is malformed at `TB_FIN_STATEMENT_CASHFLOW_FI.md:13-37`; checkpoint columns `EPROC00119` and `EPROC00120` exist in CS/CU at `TB_CHECK_POINTS_CS.md:48-50`, `TB_CHECK_POINTS_CU.md:46-48`. | `schema.sql` uses snapshot plus current entity column names for malformed cashflow fields, and explicitly records current entity/schema identity and narrative-column mismatches. |

## Endpoints
| Endpoint | Method | Purpose | Source |
|---|---|---|---|
| `/epl-sele-c0-financial-statement-comments` | POST | Load c0 statement option lists used by FI page. | Feature inventory `docs/feature-inventory.md:106`; frontend F-8 fix. |
| `/epl-info-c0-financial-statement-cmts-fi` | POST | Query current FI main, Balance, Income, Cashflow, and checkpoint state. | Controller `:53`; service `:147-174`, `:246-267`. |
| `/epl-quer-c0-financial-statement-cmts-fi` | POST | Query copyable previous application FI data. | Controller `:40`; service `:76-82`. |
| `/epl-calc-c0-financial-statement-cmts-fi` | POST | Calculate derived FI statement fields and validation messages. | Controller `:66`; service `:285-331`. |
| `/epl-save-c0-financial-statement-cmts-fi` | POST | Save draft or Finished FI statement data and update checkpoint. | Controller `:105`; service `:494-553`. |
| `/epl-pxls-c0-financial-statement-cmts-fi` | POST | Export FI Excel from persisted data. | Controller `:79`; service `:338-357`; report service `:81`. |
| `/epl-ppdf-c0-financial-statement-cmts-fi` | POST | Export FI PDF from persisted data. | Controller `:92`; service `:443-476`; report service `:91`. |

## Rules

### R1 Load options and current FI data - 強制點: both - covers-prd: PRD 5/6.1
When the EPROC00119 page is opened, the client shall load statement option lists and then query current FI data by `applicationNo` and `isQuery`. The backend shall return flat current DTO fields (`haveData`, `companyName`, `currency`, `currencyUnit`, Balance FI rows, Income FI rows, Cashflow FI rows, narrative fields, and checkpoint state) in an EPRO envelope, or controlled errors such as `E102`, `FAILED_E116`, `FAILED_E126`, `COMMON_MSG_ERROR_LON`, `MSG_DATA_NOT_FOUND`, `MSG_OVER_COUNT_LIMIT`, or `MSG_QUERY_FAIL`.

As-is: 0119 legacy used `inti` while 0219 used `init`. To-be uses only `epl-info-c0-financial-statement-cmts-fi` and the shared c0 select endpoint; legacy spelling aliases are not public API paths.

### R2 Import previous-case FI data without mutation - 強制點: BE - covers-prd: PRD 6.2
When the user searches a reference application, the client shall call the current query endpoint with the reference application's `applicationNo` plus `isQuery`; the backend shall validate reference eligibility, query FI main and all three FI detail lists, and return copyable data without writing current-case tables or checkpoint. Success shall map to `MSG_QUERY_SUCCESS`; missing or ineligible reference data shall return controlled no-data/application errors such as `MSG_ERROR_APPLICATION_NO`, `MSG_OVER_COUNT_LIMIT`, `MSG_QUERY_FAIL`, `COMMOM_MSG_NO_DATA`, or `COMMON_MSG_NO_DATA`.

Reference eligibility defaults to the legacy AND policy: `APP_CON_TYPE` is blank AND `CASE_PROGRESS` is not one of `08`, `09`, or `14`. PM may revise this later through a separate change request; this SRS does not leave the eligibility rule undecided.

### R3 Calculate Balance FI rows deterministically - 強制點: BE - covers-prd: PRD 6.3/7
When Balance FI rows are submitted for calculation, the backend shall compute total assets, total liabilities/equity, difference, and FI-specific component totals from `TB_FIN_STATEMENT_BALANCE_FI` fields. If all Balance/Income/Cashflow input lists are empty or contain no calculable data, the client shall show `COMMON_MSG_FIELD_CALCULATED`, and the backend shall return the same controlled message if the calculation endpoint is called. The calculation shall not persist detail rows, but current code updates checkpoint to unfinished during calc; that side effect is accepted as current behavior until RD changes the implementation with explicit approval. Calculation failure shall return `COMMON_MSG_TOTAL_FAIL` or a controlled validation error.

The legacy End Balance versus Cash and Cash Equivalent JavaScript inversion is treated as a suspected bug under owner policy 2. To-be shall validate the true financial comparison consistently for the same period and must not preserve the inverted legacy condition.

### R4 Calculate Income FI rows deterministically - 強制點: BE - covers-prd: PRD 6.3/7
When Income FI rows are submitted for calculation, the backend shall derive net revenues, continuing operating income before tax, continuing operating income after tax, consolidated net income, and minority-interest outputs from `TB_FIN_STATEMENT_INCOME_FI` inputs. Numeric parsing failures shall return controlled validation errors rather than defaulting silently.

Physical DB names such as `FIAN_ASSETS_BONDS_FVTPL`, `HOLDING_MATURIRY_FIN_ASSETS_RI`, and `DISCOUNTINUED_UNITS` are preserved until DBA/SA approve any rename.

### R5 Calculate Cashflow FI rows and opening balance - 強制點: BE - covers-prd: PRD 6.3/7
When Cashflow FI rows are submitted for calculation, the backend shall derive ending balance from operating/investing/financing cashflow, net increase/decrease, and opening balance. Opening balance shall be deterministic by ordered cashflow rows: row `n` opening balance equals row `n-1` ending balance when a previous row exists; the first row uses the submitted/stored opening balance value under the current DTO contract. The backend shall not depend on the legacy jQuery object/string comparison bug.

Financial amount fields in Balance/Income/Cashflow request, response, and calculation contracts are decimal strings, not JSON floating-point numbers. Balance total fields (`totalAssets`, `totalLiabEquity`, `totalLiabilities`, `totalStockholderEquity`, `totalEquityAttrOwnerPa`) follow 17 integer digits plus 2 fractional digits; all other FI amount fields follow 15 integer digits plus 2 fractional digits. Cashflow `periods` follows the DB `NUMBER(10,2)` contract; Balance/Income `periods` remain the current string `maxLength=3` contract unless DBA/SA revise the source schema. The backend shall reject numeric parse failures, over-precision, and over-scale values with controlled validation errors; it shall not silently round, truncate, or coerce input amounts.

### R6 Save draft or Finished as full replacement in one transaction - 強制點: BE - covers-prd: PRD 6.4
When the user saves EPROC00119, the backend shall validate `applicationNo`, `currency`, and `isFinish`, accept the current flat request fields (`companyName`, `currency`, `currencyUnit`, `balanceList`, `incomeList`, `cashflowList`, `loanRepayment`, `finSituation`, `businessRisk`, `borrowerRisk`, and `summary`), normalize omitted detail lists to empty lists, save main data, delete existing Balance/Income/Cashflow FI rows for the case, insert submitted rows in request order with server-assigned `DATA_SEQ`, and update checkpoint in one transaction. Success shall map to `COMMON_MSG_SAVE_SUCCESS`; any failure after delete shall roll back all main/detail/checkpoint writes and map to `COMMON_MSG_SAVE_FAIL`, `COMMON_MSG_ERROR_LON`, or the currency required message such as `EPROI0_0160_MSG_ERRO_CURRENCY`.

Server-side `applicationNo` and generated `DATA_SEQ` are authoritative. Save detail rows must not accept client-provided `APPLICATION_NO` or `DATA_SEQ`; if either appears, the backend must reject or ignore it before persistence. Narrative fields remain API-limited to 6000 characters. The borrower risk narrative must be persisted from `request.borrowerRisk`; current code at `CsuFinancialStatementCmtsFiServiceImpl.java:2915` derives it from `request.getBusinessRisk()` and is an RD conformance bug under DEC-RP52. DB snapshot identity for `TB_FIN_STATEMENT_MAIN` is `APPLICATION_NO`; current JPA/service identity also uses `CURRENCY` and is an RD/DBA conformance gap under DEC-RP53. Current narrative split-column persistence is an RD/DBA conformance gap under DEC-RP54 because the db-diff snapshot lacks those columns.

### R7 Separate Save and Finished validation - 強制點: both - covers-prd: PRD 8/9
When the request is draft save, the backend shall allow incomplete FI statement rows only within the approved draft policy. When the request is Finished, the backend shall require main currency/unit/company/audit/highlight fields plus required Balance/Income/Cashflow fields and list alignment. Backend validation is authoritative; FE validation is only UX.

Finished validation must verify Balance/Income/Cashflow list counts, period/date alignment, and server-assigned row-order consistency across the three FI detail lists. Generated `DATA_SEQ` must be derived from accepted row order, not client-provided values. Existing implementation evidence may satisfy only part of this rule; missing cases are RD conformance work, not an SRS decision gap.

Current FE/BE DTOs and Finished validation do not yet carry or enforce all target main/audit/highlight fields (`criteria1/2/3`, `doesNeedAuditedFs`, `haveProvidedAuditedFs`, `auditFirm`, `opinionMemo`, `highlight`). RD must add those request/response/form fields and server-side Finished validation during implementation; this is downstream conformance against the approved SRS contract, not an open SRS decision.

### R8 Route checkpoint writes by CS/CU case type - 強制點: BE - covers-prd: PRD 6.4
When calc or save marks the page unfinished or complete, the backend shall derive the checkpoint table from `LON_ATTRIBUTE + SECURE_ATTRIBUTE`: CS writes `TB_CHECK_POINTS_CS`; CU writes `TB_CHECK_POINTS_CU`. Calc shall mark `EPROC00119="Y"` only. Save shall mark `EPROC00119` as `"Y"` for draft and `"N"` for Finished, and shall also seed `EPROC00120="Y"` to expose/initialize the downstream Financial Evaluation FI page.

Legacy 0119 read a suspicious `EPROI0_0119` key while save/parent used `EPROC0_0119`; legacy save also seeded next-page keys `EPROC0_0120/0220`. To-be uses unified `EPROC00119` and `EPROC00120`. Any historical data repair is a DBA data-quality task only if DBA finds affected production data; it is not part of this SRS.

### R9 Export Excel and PDF from persisted FI data only - 強制點: both - covers-prd: PRD 6.5
When the user exports Excel or PDF, the backend shall require `applicationNo`, load persisted main, Balance, Income, and Cashflow FI data, validate completeness, and return a binary file response or controlled download error. Excel success shall map to `MSG_EXPORT_SUCCESS`; PDF success shall map to `COMMON_MSG_DOWNLOAD_SUCCESS`; errors shall map to `COMMON_MSG_PRINT_FAIL` or `COMMON_MSG_DOWNLOAD_FAIL`. Export shall not rely on unsaved UI state, shall not expose raw temp paths, and shall preserve audit logging.

Export ownership is corporate FI `EPROC00119`. Current PDF output name includes `EPROC00119_FI`, while the template path still references `EPROI00119` at `CsuFinancialStatementCmtsFiServiceImpl.java:476`; that is a report-asset conformance gap, not an open SRS question. Download routes require platform authentication, API authorization, case access, safe file creation, and audit logging.

### R10 Preserve corporate parity boundaries and security - 強制點: BE - covers-prd: PRD 2/10
When reviewing or implementing this page, teams shall use old corporate `EPROC0_0119` and `EPROC0_0219` plus current corporate code at commit `3dfebcf` as code-as-baseline. Individual `EPROI00119` refactor artifacts and mirror behavior are not corporate as-is. Every mutating/export endpoint shall enforce platform authentication, API authorization, case access, edit authority, and audit logging before DB or file side effects.

FE editor flags are UX hints only. Save and export authorization are two-layer controls: `TB_API_AUTH`/role-task authorization plus service-layer case-access/edit-ownership checks before mutation or file generation. Any missing implementation proof is RD conformance evidence required downstream, not a remaining SRS decision.

## NFR
| ID | Requirement | Rule |
|---|---|---|
| NF001 | Save must be transactional; any main/detail/checkpoint failure rolls back. | R6 |
| NF002 | Query, search, calculation, save, and export must preserve auditability. | R2/R3/R6/R9/R10 |
| NF003 | Detail list counts, generated `DATA_SEQ`, and dates must align across Balance/Income/Cashflow. | R6/R7 |
| NF004 | Detail `APPLICATION_NO` is backend-owned and must not trust client rows. | R6/R10 |
| NF005 | Download parameters and temp paths must not leak raw file paths. | R9 |
| NF006 | i0/ISU sources cannot close corporate parity. | R10 |
| NF007 | FI amount fields must preserve declared precision/scale and reject over-scale or over-precision without implicit rounding/truncation. | R3/R4/R5 |

## Trade-offs
| Topic | Decision | Rationale |
|---|---|---|
| Missing corporate refactor spec | Use old corporate legacy plus current corporate code at commit `3dfebcf` as code-as-baseline. | Owner policy 1 closes RP40 while preserving the disclaimer that no formal corporate artifact exists. |
| Shared select endpoint | Include `epl-sele-c0-financial-statement-comments` because F-8 fixed FI options to it. | Current FE uses the shared c0 select path; it is not an i0 path. |
| Cashflow DB snapshot defect | Use current entity names for `TB_FIN_STATEMENT_CASHFLOW_FI` while flagging db-diff column-name extraction as malformed. | Schema snapshot is active/exact, but its markdown column-name cells are unusable for this table. |
| Suspected legacy defects | Fix by default under owner policy 2. | RP43, RP50, and RP52 should not preserve suspected legacy/current defects as target behavior. |
| Authorization | Require DB authorization seed plus service-level case/edit/ownership guard. | Owner policy 3 applies to mutating and export routes. |

## New/Old DB Reconcile And Delta
| ID | Table / Field | Source | Three-way tag | SRS disposition |
|---|---|---|---|---|
| DB-D1 | `TB_FIN_STATEMENT_MAIN` active/exact; snapshot PK `APPLICATION_NO`, while current entity/service identity includes `APPLICATION_NO + CURRENCY`. | `docs/db-diff/02_tables/TB_FIN_STATEMENT_MAIN.md:27-32`; `TBFinStatementMainEntity.java:75-82`; `CsuFinancialStatementCmtsFiServiceImpl.java:2873-2876` | (c) DB structure as new + implementation drift | `schema.sql` keeps snapshot PK; current code/entity contract is RD/DBA conformance work under DEC-RP53. |
| DB-D2 | `TB_FIN_STATEMENT_BALANCE_FI` active/exact with FI-specific fields; PRD key is `APPLICATION_NO, DATA_SEQ`. | `TB_FIN_STATEMENT_BALANCE_FI.md:13-33`, `:34-114`; PRD `:305-309` | (c) DB structure as new | Use snapshot/current entity and carry composite PK in `schema.sql`. |
| DB-D3 | `TB_FIN_STATEMENT_INCOME_FI` active/exact with FI income fields and typo physical names; PRD key is `APPLICATION_NO, DATA_SEQ`. | `TB_FIN_STATEMENT_INCOME_FI.md:13-37`; PRD `:316-320` | (c) DB structure as new | Preserve physical names and carry composite PK until approved rename. |
| DB-D4 | `TB_FIN_STATEMENT_CASHFLOW_FI` active/exact metadata but column names are malformed in markdown. | `TB_FIN_STATEMENT_CASHFLOW_FI.md:13-37`; entity `TBFinStatementCashflowFiEntity.java:11-58` | (c) DB structure as new + snapshot extraction defect | `schema.sql` uses current entity names and marks the snapshot extraction defect. |
| DB-D5 | New checkpoint columns are `TB_CHECK_POINTS_CS/CU.EPROC00119` and `EPROC00120`; legacy read key defect used `EPROI0_0119`, while save seeded `EPROC0_0120/0220`. | `TB_CHECK_POINTS_CS.md:48-50`; `TB_CHECK_POINTS_CU.md:46-48`; `CsuFinancialStatementCmtsFiServiceImpl.java:553-556`; legacy `EPROC0_0119_mod.java:857-862`, `EPROC0_0219_mod.java:858-864` | (c) DB structure as new + legacy defect | To-be writes both unified columns on save; historical data repair is separate DBA work if affected data is found. |
| DB-D6 | `TB_FIN_STATEMENT_MAIN` snapshot lacks current narrative split columns `LOAN_REPAYMENT_1/2`, `FINANCIAL_SITUATION_1/2`, `BUSINESS_RISK_1/2`, `BORROWER_RISK_1/2`, and `SUMMARY_1/2`. | `docs/db-diff/02_tables/TB_FIN_STATEMENT_MAIN.md:35-48`; `TBFinStatementMainEntity.java:44-72`; `CsuFinancialStatementCmtsFiServiceImpl.java:2887-2927` | (c) DB structure as new + implementation drift | SRS keeps API narrative fields at 6000 characters and schema snapshot authority; split-column persistence requires RD/DBA conformance work under DEC-RP54. |
| REF-D1 | Corporate refactor baseline missing; individual `EPROI00119` artifacts exist but are not as-is. | `docs/refactor-spec/` search results; decisions `docs/decisions.md:58`, `:67` mention missing EPROC00119 baseline. | code-as-baseline by owner policy 1 | Closed by DEC-RP40 with commit `3dfebcf`; no formal corporate artifact is invented. |

## Decision Register
| ID | Status | Decision | Source / Delta |
|---|---|---|---|
| DEC-RP40 | closed | Missing formal corporate baseline is closed by code-as-baseline: legacy `EPROC0_0119`/`EPROC0_0219` plus current corporate code at commit `3dfebcf`. | Owner policy 1; REF-D1. |
| DEC-RP41 | closed | Legacy `inti/init` spellings are evidence only; public to-be API uses current `epl-info-c0-financial-statement-cmts-fi`. | R1. |
| DEC-RP42 | closed | To-be checkpoint keys are unified `EPROC00119` and `EPROC00120`; legacy `EPROI0_0119` read-key defect is not preserved. | R8; DB-D5. |
| DEC-RP43 | closed | End Balance versus Cash and Cash Equivalent inversion is treated as suspected legacy bug; implement true same-period financial comparison. | Owner policy 2; R3. |
| DEC-RP44 | closed | Reference eligibility defaults to legacy AND: blank `APP_CON_TYPE` AND `CASE_PROGRESS` not in `08/09/14`; later PM changes require a separate change request. | R2. |
| DEC-RP45 | closed | Finished validation requires Balance/Income/Cashflow count, date/period, and server-assigned row-order/`DATA_SEQ` alignment; implementation tests are RD conformance work. | R6/R7; NF003. |
| DEC-RP46 | closed | FE editor flags are not authority; backend service authorization and editability checks are authoritative. | R10. |
| DEC-RP47 | closed | Export ownership is corporate FI `EPROC00119`; current `EPROI00119` template path is a report-asset conformance gap. | R9. |
| DEC-RP48 | closed | Backend owns `applicationNo` and `DATA_SEQ`; save detail payload keys must be rejected or ignored before persistence. | R6/R10; NF004. |
| DEC-RP49 | closed | Draft save and Finished have separate validation tiers; Finished requires full main/list validation server-side. | R7. |
| DEC-RP50 | closed | Cashflow opening balance must use deterministic ordered-row logic and must not depend on the legacy object/string bug. | Owner policy 2; R5. |
| DEC-RP51 | closed | Mutating/export routes require DB authorization seed plus service-layer case access, edit/ownership guard, safe download, and audit logging. | Owner policy 3; R9/R10. |
| DEC-RP52 | closed | Borrower risk must persist from `request.borrowerRisk`; current write-back from `request.getBusinessRisk()` is a bug to fix. | Owner policy 2; `CsuFinancialStatementCmtsFiServiceImpl.java:2915`. |
| DEC-RP53 | closed | SRS follows DB snapshot PK `APPLICATION_NO`; current JPA/service `APPLICATION_NO + CURRENCY` identity is RD/DBA conformance work. | DB-D1. |
| DEC-RP54 | closed | API narrative fields remain 6000-character flat fields; DB snapshot remains authoritative, and current split-column persistence is RD/DBA conformance work. | DB-D6. |

## Traceability Matrix
| PRD area | Rules | QA disposition |
|---|---|---|
| Load/init/current query | R1 | QA generation deferred while axis G is paused. |
| Reference search/import | R2 | QA generation deferred while axis G is paused. |
| Calculation | R3, R4, R5 | QA generation deferred while axis G is paused. |
| Save/Finished/transaction | R6, R7, R8 | QA generation deferred while axis G is paused. |
| Export | R9 | QA generation deferred while axis G is paused. |
| Security/parity/refactor baseline | R10 | QA generation deferred while axis G is paused. |
| Closed PRD/RP issues | DEC-RP40 through DEC-RP54 | QA generation deferred while axis G is paused. |

## Hard Boundaries And As-Is/To-Be Summary
- As-is evidence must come from old corporate `EPROC0_0119` / `EPROC0_0219` plus current corporate code at commit `3dfebcf`. Individual `EPROI00119` is not corporate as-is.
- To-be uses POST RPC endpoints, new CS/CU checkpoint columns `EPROC00119` plus downstream seed `EPROC00120`, backend-owned application/key/checkpoint decisions, and active FI statement tables.
- This bundle is ready for owner finalization after mechanical gate and A-F no-Blocker review. The orchestrator does not self-mark `Status: Approved`.
