# SRS - EPROC00119 Financial Statement FI

## Metadata
| Field | Value |
|---|---|
| FuncId | EPROC00119 |
| Status | In Review / draft-for-controller-gate; awaiting corporate refactor baseline, parity, and human review |
| Owner | SA / Credit decision domain / RD |
| Upstream PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00119-v1.0.md` |
| As-is source | Legacy `EPROC0_0119` + `EPROC0_0219`; current corporate implementation anchors below; formal corporate refactor baseline UNFOUND |
| Bundle files | `spec.md`, `openapi.yaml`, `schema.sql`, `qa-cases.md` |

## Scope
- In scope: C0 Financial Statement FI option/info/reference-query/calc/save/export contract, FI main/Balance/Income/Cashflow persistence, checkpoint update, CS/CU checkpoint routing, DB/refactor reconcile, and legacy parity risk registration.
- Out of scope: GI financial statement, downstream FI financial evaluation calculations, report-template redesign, implementation code changes, and approval to close i0-mirror parity.
- Contract endpoints are current POST RPC paths: `epl-sele-c0-financial-statement-comments`, `epl-info-c0-financial-statement-cmts-fi`, `epl-quer-c0-financial-statement-cmts-fi`, `epl-calc-c0-financial-statement-cmts-fi`, `epl-save-c0-financial-statement-cmts-fi`, `epl-pxls-c0-financial-statement-cmts-fi`, and `epl-ppdf-c0-financial-statement-cmts-fi`. Legacy `inti/init`, `search`, `calculation`, `save`, `print`, and `printPDF` are evidence, not public API paths.

## Assumptions And Dependencies
- This page is T1 corporate because FI financial statement data feeds financial evaluation and checkpoint completion. It may reach `In Review`; it must not be Approved until `RP40` and parity/security items close.
- Formal corporate refactor-spec module `docs/refactor-spec/02_modules/EPROC00119.md` is UNFOUND. Existing individual `EPROI00119` artifacts are not corporate as-is.
- Existing `docs/feature-inventory.md:106` records the F-8 select-options fix and calls out export-template verification. That is carried as evidence, not as approval.
- Corporate c0 parity reopen remains open at `docs/pending-register.md:26`; this bundle adds page-specific RP items and does not close the group row.

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD | Scope and old systems at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00119-v1.0.md:9-23`, `:39-45`; open issues at `:52-61`; APIs at `:194-284`; data model at `:288-326`; quality requirements at `:406-412`. | Behavior becomes R1-R10; open PRD issues become RP41-RP50. |
| Refactor spec | `docs/refactor-spec/02_modules/EPROC00119.md` is missing; search only found individual `EPROI00119` artifacts and generic 00116 c0 GI artifacts. | Register `RP40`; do not use i0 FI as corporate as-is. |
| Current backend | Corporate FI controller exposes query at `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStatementCmtsFiController.java:40`, info `:53`, calc `:66`, pxls `:79`, ppdf `:92`, save `:105`; service info at `CsuFinancialStatementCmtsFiServiceImpl.java:147-174`, calc/checkpoint side effect at `:285-331`, export validation at `:338-476`, transactional save and `EPROC00120` seed at `:494-556`, checkpoint routing at `:3170-3180`. | Current implementation anchors real RPC paths but is not a closed baseline. |
| Current frontend | FI service calls info/query/save/calc at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-statement/financial-statement-fi/services/api.service.ts:40`, `:72`, `:85`, `:94`; report service calls pxls/ppdf at `frontend/src/app/core/services/report/report.service.ts:81`, `:91`. | Confirms current FE route usage and export paths. |
| Legacy parity task | 00119 maps to `EPROC0_0119` plus `0219`, and F-8 needs old-system confirmation at `docs/build-tasks/c0-legacy-parity-recheck.md:28`; c0 parity SOP says compare to old corporate, not i0, at `:12`, `:48-55`. | All old behavior not directly rechecked remains "待 parity 碼驗 / 待 RD 核對". |
| DB snapshot | `TB_FIN_STATEMENT_MAIN` active/exact with main fields at `docs/db-diff/02_tables/TB_FIN_STATEMENT_MAIN.md:13-37`; `TB_FIN_STATEMENT_BALANCE_FI` active/exact with 79 columns at `TB_FIN_STATEMENT_BALANCE_FI.md:13-33`; `TB_FIN_STATEMENT_INCOME_FI` active/exact at `TB_FIN_STATEMENT_INCOME_FI.md:13-37`; `TB_FIN_STATEMENT_CASHFLOW_FI` active/exact but column-name extraction is malformed at `TB_FIN_STATEMENT_CASHFLOW_FI.md:13-37`; checkpoint columns `EPROC00119` and `EPROC00120` exist in CS/CU at `TB_CHECK_POINTS_CS.md:48-50`, `TB_CHECK_POINTS_CU.md:46-48`. | `schema.sql` uses snapshot plus current entity column names for malformed cashflow fields, and flags current entity/schema identity discrepancies. |

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

### R1 Load options and current FI data - 強制點: both - covers-prd: PRD §5/§6.1
When the EPROC00119 page is opened, the client shall load statement option lists and then query current FI data by `applicationNo` and `isQuery`. The backend shall return flat current DTO fields (`haveData`, `companyName`, `currency`, `currencyUnit`, Balance FI rows, Income FI rows, Cashflow FI rows, narrative fields, and checkpoint state) in an EPRO envelope, or controlled errors such as `E102`, `FAILED_E116`, `FAILED_E126`, `COMMON_MSG_ERROR_LON`, `MSG_DATA_NOT_FOUND`, `MSG_OVER_COUNT_LIMIT`, or `MSG_QUERY_FAIL`.

As-is: 0119 legacy used `inti` while 0219 used `init`; to-be uses `epl-info-c0-financial-statement-cmts-fi` and the shared c0 select endpoint. Any alias for legacy `inti` is pending under `RP41`.

### R2 Import previous-case FI data without mutation - 強制點: BE - covers-prd: PRD §6.2
When the user searches a reference application, the client shall call the current query endpoint with the reference application's `applicationNo` plus `isQuery`; the backend shall validate reference eligibility, query FI main and all three FI detail lists, and return copyable data without writing current-case tables or checkpoint. Success shall map to `MSG_QUERY_SUCCESS`; missing or ineligible reference data shall return controlled no-data/application errors such as `MSG_ERROR_APPLICATION_NO`, `MSG_OVER_COUNT_LIMIT`, `MSG_QUERY_FAIL`, `COMMOM_MSG_NO_DATA`, or `COMMON_MSG_NO_DATA`.

The legacy eligibility rule combines `APP_CON_TYPE` blank and `CASE_PROGRESS not in 08,09,14` in a way that needs product confirmation; the PRD's legacy `reApplication` naming is not represented by the current DTO and remains part of `RP44`.

### R3 Calculate Balance FI rows deterministically - 強制點: BE - covers-prd: PRD §6.3/§7
When Balance FI rows are submitted for calculation, the backend shall compute total assets, total liabilities/equity, difference, and FI-specific component totals from `TB_FIN_STATEMENT_BALANCE_FI` fields. If all Balance/Income/Cashflow input lists are empty or contain no calculable data, the client shall show `COMMON_MSG_FIELD_CALCULATED`, and the backend shall return the same controlled message if the calculation endpoint is called. The calculation shall not persist detail rows, but current code updates checkpoint to unfinished during calc; that side effect must be reviewed before approval. Calculation failure shall return `COMMON_MSG_TOTAL_FAIL` or a controlled validation error.

As-is: PRD notes End Balance versus Cash and Cash Equivalent validation may be inverted in legacy JavaScript. To-be must define the correct comparison before treating this rule as Approved; see `RP43`.

### R4 Calculate Income FI rows deterministically - 強制點: BE - covers-prd: PRD §6.3/§7
When Income FI rows are submitted for calculation, the backend shall derive net revenues, continuing operating income before tax, continuing operating income after tax, consolidated net income, and minority-interest outputs from `TB_FIN_STATEMENT_INCOME_FI` inputs. Numeric parsing failures shall return controlled validation errors rather than defaulting silently.

Physical DB names such as `FIAN_ASSETS_BONDS_FVTPL`, `HOLDING_MATURIRY_FIN_ASSETS_RI`, and `DISCOUNTINUED_UNITS` are preserved until DBA/SA approve any rename.

### R5 Calculate Cashflow FI rows and opening balance - 強制點: BE - covers-prd: PRD §6.3/§7
When Cashflow FI rows are submitted for calculation, the backend shall derive ending balance from operating/investing/financing cashflow, net increase/decrease, and opening balance. For first-year opening balance, it shall follow an explicit server-side rule and not depend on the legacy jQuery object/string comparison bug.

The first-year opening balance behavior remains `RP50` until RD validates old and new behavior.

### R6 Save draft or Finished as full replacement in one transaction - 強制點: BE - covers-prd: PRD §6.4
When the user saves EPROC00119, the backend shall validate `applicationNo`, `currency`, and `isFinish`, accept the current flat request fields (`companyName`, `currency`, `currencyUnit`, `balanceList`, `incomeList`, `cashflowList`, `loanRepayment`, `finSituation`, `businessRisk`, `borrowerRisk`, and `summary`), normalize omitted detail lists to empty lists, save main data, delete existing Balance/Income/Cashflow FI rows for the case, insert submitted rows in request order, and update checkpoint in one transaction. Success shall map to `COMMON_MSG_SAVE_SUCCESS`; any failure after delete shall roll back all main/detail/checkpoint writes and map to `COMMON_MSG_SAVE_FAIL`, `COMMON_MSG_ERROR_LON`, or the currency required message such as `EPROI0_0160_MSG_ERRO_CURRENCY`.

To-be: server-side `applicationNo` and generated `DATA_SEQ` are authoritative. Client-provided `APPLICATION_NO` in detail payload is not authoritative and must be overwritten or rejected; see `RP48`. Narrative fields are DTO-limited to 6000 characters. Current implementation splits those fields into `*_1/*_2` columns, but the db-diff snapshot for `TB_FIN_STATEMENT_MAIN` does not carry those columns; this persistence/schema drift remains `RP54`. DB snapshot defines `TB_FIN_STATEMENT_MAIN` identity as `APPLICATION_NO`, but current JPA/service uses `APPLICATION_NO + CURRENCY`; this discrepancy remains `RP53`. Current implementation also appears to write `borrowerRisk` from `businessRisk`; this is not approved behavior and remains `RP52`.

### R7 Separate Save and Finished validation - 強制點: both - covers-prd: PRD §8/§9
When the request is draft save, the backend shall allow incomplete FI statement rows only within the approved draft policy. When the request is Finished, the backend shall require main currency/unit/company/audit/highlight fields plus required Balance/Income/Cashflow fields and list alignment. Backend validation is authoritative; FE validation is only UX.

As-is: PRD notes legacy Save and Finished validations differ. Current backend requires `applicationNo`, `isFinish`, and `currency`, but omitted detail lists are normalized to empty lists; stricter Finished list/content validation remains `RP49` until implemented and tested.

### R8 Route checkpoint writes by CS/CU case type - 強制點: BE - covers-prd: PRD §6.4
When calc or save marks the page unfinished or complete, the backend shall derive the checkpoint table from `LON_ATTRIBUTE + SECURE_ATTRIBUTE`: CS writes `TB_CHECK_POINTS_CS`; CU writes `TB_CHECK_POINTS_CU`. Calc shall mark `EPROC00119="Y"` only. Save shall mark `EPROC00119` as `"Y"` for draft and `"N"` for Finished, and shall also seed `EPROC00120="Y"` to expose/initialize the downstream Financial Evaluation FI page.

Legacy 0119 read a suspicious `EPROI0_0119` key while save/parent used `EPROC0_0119`; legacy save also seeded next-page keys `EPROC0_0120/0220`. New schema uses unified `EPROC00119` and `EPROC00120`, but the legacy read-key defect and any data repair need are tracked by `RP42`.

### R9 Export Excel and PDF from persisted FI data only - 強制點: both - covers-prd: PRD §6.5
When the user exports Excel or PDF, the backend shall require `applicationNo`, load persisted main, Balance, Income, and Cashflow FI data, validate completeness, and return a binary file response or controlled download error. Excel success shall map to `MSG_EXPORT_SUCCESS`; PDF success shall map to `COMMON_MSG_DOWNLOAD_SUCCESS`; errors shall map to `COMMON_MSG_PRINT_FAIL` or `COMMON_MSG_DOWNLOAD_FAIL`. Export shall not rely on unsaved UI state, shall not expose raw temp paths, and shall preserve audit logging.

Current implementation uses file names/templates that require verification against FI ownership. Mixed GI/i0 report IDs and file naming remain `RP47`.

### R10 Preserve corporate parity boundaries and security - 強制點: BE - covers-prd: PRD §2/§10
When reviewing or implementing this page, teams shall use old corporate `EPROC0_0119` and `EPROC0_0219` as parity targets. Individual `EPROI00119` refactor artifacts and mirror behavior are not corporate as-is. Every mutating/export endpoint shall enforce platform authentication, API authorization, case access, edit authority, and audit logging before DB or file side effects.

Formal corporate refactor baseline is missing (`RP40`), editor flag parity is unresolved (`RP46`), service authorization/export security proof is unresolved (`RP51`), borrower-risk write-back correctness is unresolved (`RP52`), main-table identity reconciliation is unresolved (`RP53`), and narrative split-column persistence is unresolved (`RP54`).

## NFR
| ID | Requirement | Rule |
|---|---|---|
| NF001 | Save must be transactional; any main/detail/checkpoint failure rolls back. | R6 |
| NF002 | Query, search, calculation, save, and export must preserve auditability. | R2/R3/R6/R9/R10 |
| NF003 | Detail list counts, `DATA_SEQ`, and dates must align across Balance/Income/Cashflow. | R6/R7 |
| NF004 | Detail `APPLICATION_NO` is backend-owned and must not trust client rows. | R6/R10 |
| NF005 | Download parameters and temp paths must not leak raw file paths. | R9 |
| NF006 | i0/ISU sources cannot close corporate parity. | R10 |

## Trade-offs
| Topic | Decision | Rationale |
|---|---|---|
| Missing corporate refactor spec | Use current corporate code as route evidence but keep RP40 open. | Existing endpoints are real, but no formal 00119 artifact map exists. |
| Shared select endpoint | Include `epl-sele-c0-financial-statement-comments` because F-8 fixed FI options to it. | Current FE uses the shared c0 select path; it is not an i0 path. |
| Cashflow DB snapshot defect | Use current entity names for `TB_FIN_STATEMENT_CASHFLOW_FI` while flagging db-diff column-name extraction as malformed. | Schema snapshot is active/exact, but its markdown column-name cells are unusable for this table without mother-folder recheck. |

## New/Old DB Reconcile And Delta
| ID | Table / Field | Source | Three-way tag | SRS disposition |
|---|---|---|---|---|
| DB-D1 | `TB_FIN_STATEMENT_MAIN` active/exact; snapshot PK `APPLICATION_NO`, while current entity/service identity includes `APPLICATION_NO + CURRENCY`. | `docs/db-diff/02_tables/TB_FIN_STATEMENT_MAIN.md:27-32`; `TBFinStatementMainEntity.java:75-82`; `CsuFinancialStatementCmtsFiServiceImpl.java:2873-2876` | (c) DB structure as new + implementation drift | `schema.sql` keeps snapshot PK; current code/entity contract must be reconciled under `RP53`. |
| DB-D2 | `TB_FIN_STATEMENT_BALANCE_FI` active/exact with FI-specific fields; PRD key is `APPLICATION_NO, DATA_SEQ`. | `TB_FIN_STATEMENT_BALANCE_FI.md:13-33`, `:34-114`; PRD `:305-309` | (c) DB structure as new | Use snapshot/current entity and carry composite PK in `schema.sql`. |
| DB-D3 | `TB_FIN_STATEMENT_INCOME_FI` active/exact with FI income fields and typo physical names; PRD key is `APPLICATION_NO, DATA_SEQ`. | `TB_FIN_STATEMENT_INCOME_FI.md:13-37`; PRD `:316-320` | (c) DB structure as new | Preserve physical names and carry composite PK until approved rename. |
| DB-D4 | `TB_FIN_STATEMENT_CASHFLOW_FI` active/exact metadata but column names are malformed in markdown. | `TB_FIN_STATEMENT_CASHFLOW_FI.md:13-37`; entity `TBFinStatementCashflowFiEntity.java:11-58` | pending mother-folder recheck | `schema.sql` uses current entity names and marks snapshot defect. |
| DB-D5 | New checkpoint columns are `TB_CHECK_POINTS_CS/CU.EPROC00119` and `EPROC00120`; legacy read key defect used `EPROI0_0119`, while save seeded `EPROC0_0120/0220`. | `TB_CHECK_POINTS_CS.md:48-50`; `TB_CHECK_POINTS_CU.md:46-48`; `CsuFinancialStatementCmtsFiServiceImpl.java:553-556`; legacy `EPROC0_0119_mod.java:857-862`, `EPROC0_0219_mod.java:858-864` | (c) DB structure as new + legacy defect | To-be writes both unified columns on save; legacy read-key defect tracked by `RP42`. |
| DB-D6 | `TB_FIN_STATEMENT_MAIN` snapshot lacks current narrative split columns `LOAN_REPAYMENT_1/2`, `FINANCIAL_SITUATION_1/2`, `BUSINESS_RISK_1/2`, `BORROWER_RISK_1/2`, and `SUMMARY_1/2`. | `docs/db-diff/02_tables/TB_FIN_STATEMENT_MAIN.md:35-48`; `TBFinStatementMainEntity.java:44-72`; `CsuFinancialStatementCmtsFiServiceImpl.java:2887-2927` | pending schema/entity reconcile | Keep `schema.sql` on snapshot DDL and register `RP54`; do not silently approve current split-column persistence. |
| REF-D1 | Corporate refactor baseline missing; individual `EPROI00119` artifacts exist but are not as-is. | `docs/refactor-spec/` search results; decisions `docs/decisions.md:58`, `:67` mention missing EPROC00119 baseline. | pending baseline | Register `RP40`; do not mark Approved. |

## @PENDING
| ID | Status | Owner | Blocking For | Required closure |
|---|---|---|---|---|
| RP40 | open | SA/RD | R10/REF-D1 | Provide formal corporate EPROC00119 refactor artifact map or approve code-as-baseline with parity evidence. |
| RP41 | open | SA/RD | R1 | Decide legacy `inti` alias / migration rewrite for 0119 init naming. |
| RP42 | open | PM/SA/RD/DBA | R8/DB-D5 | Confirm legacy `EPROI0_0119` checkpoint read defect impact and any data repair need. |
| RP43 | open | SA/QA/RD | R3 | Confirm End Balance versus Cash and Cash Equivalent comparison rule. |
| RP44 | open | PM/SA | R2 | Decide reference-case eligibility AND/OR rule for `APP_CON_TYPE` and `CASE_PROGRESS`. |
| RP45 | open | SA/RD/QA | R6/R7 | Implement and test Balance/Income/Cashflow count, date, and `DATA_SEQ` alignment validation. |
| RP46 | open | PM/SA/RD | R10 | Confirm Save/Finished editor flag parity for `isEditor116/216` versus `119/219`. |
| RP47 | open | SA/RD/QA | R9 | Confirm FI export template/report IDs/file names; remove or document GI/i0 naming mix. |
| RP48 | open | Security/RD | R6/R10 | Prove backend overwrites/rejects detail `APPLICATION_NO` from payload rows. |
| RP49 | open | PM/SA/RD/QA | R7 | Define and implement Save versus Finished validation tiers server-side. |
| RP50 | open | RD/QA | R5 | Validate first-year cashflow opening balance behavior and fix legacy object/string bug if still present. |
| RP51 | open | Security/RD/DBA | R9/R10 | Provide service-level authorization, audit, and safe download proof for mutating/export routes. |
| RP52 | open | RD/QA | R6/R10 | Fix or formally disposition current save write-back that derives `BORROWER_RISK_*` from `businessRisk` instead of `borrowerRisk`. |
| RP53 | open | RD/DBA/SA | R6/DB-D1 | Reconcile `TB_FIN_STATEMENT_MAIN` snapshot PK `APPLICATION_NO` with current JPA/service identity `APPLICATION_NO + CURRENCY`; schema remains new unless DBA changes snapshot. |
| RP54 | open | RD/DBA/SA | R6/DB-D6 | Reconcile current narrative split-column persistence with db-diff snapshot `TB_FIN_STATEMENT_MAIN`, which lacks the `*_1/*_2` narrative columns. |

## Traceability Matrix
| PRD area | Rules | QA |
|---|---|---|
| Load/init/current query | R1 | QA-001, QA-002 |
| Reference search/import | R2 | QA-003, QA-004 |
| Calculation | R3, R4, R5 | QA-005, QA-006, QA-007, QA-008 |
| Save/Finished/transaction | R6, R7, R8 | QA-009, QA-010, QA-011, QA-012 |
| Export | R9 | QA-013, QA-014 |
| Security/parity/refactor baseline | R10 | QA-015, QA-016 |
| Open PRD issues | R1-R10, RP40-RP54 | QA-P01 through QA-P15 |

## Hard Boundaries And As-Is/To-Be Summary
- As-is evidence must come from old corporate `EPROC0_0119` / `EPROC0_0219` plus current corporate code. Individual `EPROI00119` is not corporate as-is.
- To-be uses POST RPC endpoints, new CS/CU checkpoint columns `EPROC00119` plus downstream seed `EPROC00120`, backend-owned application/key/checkpoint decisions, and active FI statement tables.
- Because corporate refactor baseline is missing and multiple legacy defect suspects are open, this bundle stops at `In Review`.
