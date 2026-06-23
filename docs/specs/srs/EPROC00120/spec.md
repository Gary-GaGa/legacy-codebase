# SRS - EPROC00120 Corporate Financial Evaluation FI

## Metadata
| Field | Value |
|---|---|
| Status | In Review / draft-for-review; no owner stamp |
| funcId | EPROC00120 |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md` |
| Bundle | `docs/specs/srs/EPROC00120/` |
| Source baseline | PRD v1.0 + Bible v1.1 + local db-diff + bounded legacy/current source read |
| Risk tier | T1 c0 corporate money page; full A-G SRS review required before owner approval |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`, `qa-cases.md` |

## Scope
- This SRS covers the corporate C0 FI financial-evaluation page migrated from legacy main-chain `EPROC0_0120` and RC chain `EPROC0_0220` into funcId `EPROC00120`. PRD names those legacy chains and page purpose at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:15-19`.
- In scope: query page data, compute FI ratios from financial statement source rows, retain manual ratio fields, save incomplete draft rows, finish with checkpoint update, handle query mode, and preserve RC old-case restrictions. PRD flow and mode matrix are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:120-156`.
- Out of scope: I0 FI behavior and staff-loan endpoints. Dispatch explicitly forbids treating I0 as corporate as-is; c0 findings state old corporate `00120` is BusinessOwner-only and no staff split is required at `docs/build-tasks/done/phase-f-step3-00120-financial-evaluation-fi.md:1-4`.
- No independent `docs/refactor-spec/02_modules/EPROC00120.md` baseline was found. Dispatch says `EPROC00120`/`EPROC00119` lack independent module/artifact and must use parity verification instead of mixing with `EPROI00120` at `docs/build-tasks/prd-to-srs-codex-dispatch.md:79-80`.

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD functional scope | FR-001 through FR-008 are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:162-169`. | Carried by R1-R9; open TBDs are carried by R10-R18. |
| PRD TBD list | TBD-001 through TBD-008 are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:38-50`. | Open as `@PENDING`; not decided in this SRS. |
| Bible guard | Bible says C0/I0 financial evaluation must stay in the correct page family and PRD/SRS/API/DB/tests must preserve source-confirmed legacy IDs at `docs/specs/bible/bible-eproposal.md:737-741`. | This SRS uses C0 legacy IDs only as c0 evidence. |
| Dispatch rule | Corporate pages compare against old corporate sources, not I0/ISU, and absent parity must be marked pending at `docs/build-tasks/prd-to-srs-codex-dispatch.md:47-50`. | Corporate direct parity remains pending until code verification. |
| T1 review rule | T1/c0 rating pages require per-page checkpoint and cannot be drained as low risk at `docs/process/orchestration-playbook.md:83-86`. | Status remains In Review; no approval claim. |
| Existing inventory | `EPROC00120` is business-only FE built with endpoints and no staff cleanup at `docs/feature-inventory.md:104-107`. | Confirms c0 business page scope, not full parity. |
| Current backend API | Controller exposes POST `epl-info-c0-financial-evaluation-table-fi` and POST `epl-save-c0-financial-evaluation-table-fi` at `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialEvaluationTableFiController.java:25-36`. | Endpoints use real RPC `epl-*`/POST. |
| Current FE API | Angular service calls the same two endpoints at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/sub-pages/financial-evaluation-fi/services/api.service.ts:21-45`. | Endpoint names are grounded in current source. |
| Legacy query/save | Legacy 0120 transaction handles query and save at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:47-99`; legacy 0220 handles the RC counterpart at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0220.java:46-98`. | Baseline for query/save/error behavior. |
| Legacy formulas | Legacy 0120 computes cost/income, loans/deposits, GGL, ROA, ROE and formats values at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:113-165`; legacy 0220 has the same formula block at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0220_mod.java:113-165`. | Formula baseline, with PRD TBDs retained. |
| New DB snapshot | Target table columns and lengths for `TB_FINANCIAL_EVALUATION_FI` are listed at `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:38-56`. | Schema and maxlength are fixed to DB snapshot. |
| Auth boundary | Backend project convention requires Spring Security JWT plus APIAuthorizationFilter and `TB_API_AUTH` at `backend/AGENTS.md:25-35`. Endpoint naming convention is `epl-{verb}-c0-{feature}` at `backend/AGENTS.md:47-48`. | Mutating endpoint must be BE-authorized and role-guarded. |

## Endpoints
| Endpoint | Method | Purpose | Rules |
|---|---|---|---|
| `epl-info-c0-financial-evaluation-table-fi` | POST | Query current FI ratio rows and source-derived/manual fields; PRD/legacy main-borrower/checkpoint response gap is tracked by R19/P-012. | R1-R3, R6-R9, R19 |
| `epl-save-c0-financial-evaluation-table-fi` | POST | Save or finish FI ratio rows, update the C0 FI checkpoint, and carry parent progress contract gaps. | R3-R9, R19 |

## BR/SC Coverage
| PRD rule | Evidence | SRS rule |
|---|---|---|
| BR-001 source rows by `DATA_SEQ` | PRD business rules at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:545-547`; legacy orders source rows at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:90-95`. | R1, R2, R10 |
| BR-002 through BR-008 formulas | PRD formula list at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:548-554`. | R2, R11, R12 |
| BR-009 manual fields | PRD manual-field list at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:555`; legacy preserves manual fields by ratio date at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:97-113`. | R3, R13 |
| BR-010 through BR-012 save/finish/checkpoint | PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:556-558`. | R4, R5 |
| BR-013 through BR-015 query mode, error, old case | PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:559-560`. | R6, R7, R15 |
| SC source matrix | PRD mode matrix at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:152-156`. | R1, R4-R6 |
| FR-006 parent progress and cross-page reset | PRD save contract lists `pageCheckMap` and `isAllTabsCheck` at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:453-464`; cross-page tests are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:619-621`. | R19, QA-024, QA-025 |

## Security/Auth Coverage
| Source condition | Evidence | SRS disposition |
|---|---|---|
| Role responsibility and auth boundary must not be conflated. | `docs/specs/bible/bible-eproposal.md:77-82` | Carried by R8 and P-011: API seed, page/menu permission, and service-level edit guard are separate checks. |
| `SECURE_ATTRIBUTE` controls CS/CU branch and checkpoint table. | `docs/specs/bible/bible-eproposal.md:793-796`; current backend branches by `LON_ATTRIBUTE + SECURE_ATTRIBUTE` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:255-274`. | Carried by R5, R19, QA-013, QA-014. |
| `TB_API_AUTH` must be verified per actual API path. | `backend/src/main/java/khd/svc/epro/config/security/APIAuthorizationFilter.java:38-43`; c0 auth findings show missing EPROC00120 rows at `docs/build-tasks/c0-authz-sql-findings.md:71-72`. | Carried as P-011; not treated as closed by this SRS. |
| Mutating endpoint must reject direct wrong-role/non-editor calls. | Save currently deletes/reinserts and updates checkpoint at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:202-214`, `255-260`; no service-level guard evidence is present. | Carried as R8/P-011 and QA-012/018/019. |
| Disaster/security failure must not partially mutate data. | PRD rollback principle at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:576-583`; current save is transactional at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:195-216`. | Carried by R4, R7, QA-011. |

## Rules

### R1 Load C0 FI financial-evaluation context - 強制點: both
covers-prd: FR-001, FR-008

Given a valid `applicationNo`, `epl-info-c0-financial-evaluation-table-fi` must return a `financialList` of FI ratio rows. The PRD query flow requires audit, main-borrower/checkpoint lookup, and query action at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:198-203`. Legacy 0120 does `auditLog`, `getOther`, and `query` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:47-57`.

The current backend request requires `applicationNo` and `isQuery` at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/InfoCsuFinancialEvaluationTableFiRequest.java:12-18`; current service loads summary/main borrower internally, saved rows, balance rows, and income rows at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:55-83`, but current response DTO exposes only `financialList` at `backend/src/main/java/khd/svc/epro/dto/response/corporate/csuFinancialEvaluationTableFi/InfoCsuFinancialEvaluationTableFiResponse.java:12-75`. PRD/legacy response fields for borrower/checkpoint remain an implementation gap tracked by R19/P-012.

### R2 Compute editable FI ratios from source rows - 強制點: BE
covers-prd: FR-002

When `isQuery=false`, the backend must compute automatic ratio fields from `TB_FIN_STATEMENT_BALANCE_FI` and `TB_FIN_STATEMENT_INCOME_FI`, ordered and aligned by `DATA_SEQ`, then format displayed ratio values consistently. PRD requires ordered source rows and formula calculation at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:218-233`; legacy 0120 orders balance/income rows and loops through balance rows at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:90-113`.

Automatic fields are the current DTO keys `growthOfGrossLoans` (`GGL`), `cost` (`COST_INCOME`), `roa` (`ROA`), `roe` (`ROE`), and `loans` (`LOANS_DEPOSITS`). PRD formulas are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:548-554`. Current backend computes these fields at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:152-181` and maps them to entity columns at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:236-245`.

### R3 Preserve manual fields and enforce field length/precision - 強制點: both
covers-prd: FR-002, FR-003

Manual fields must be accepted, saved, and returned without silent truncation: `nplRatios` (`NPL`), `loanLossReserves` (`LLR`), `loanLossReserveOverNpl` (`LLR_OVER_NPL`), `aggregateLargeExposureRatio` (`AGREE_LARGE_EXPOSURE`), `creditExposureToSingleBeneficiary` (`CREDIT_EXPOSURE_TO_SB`), `relatedPartyExposure`, `unhedgedForeignCurrencyRatio` (`UNHEDGED_FOREIGN_CURR`), `netInterestMargin`, `liquidityCoverageRatio` (`LIQUIDITY_COVERAGE`), `solvencyRatio` (`SOLVENCY`), and `tier1CapitalRatio` (`TIER_ONE_CAPITAL`). PRD field mapping is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:489-509`; DB snapshot columns are at `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:38-56`; current DTO JSON keys are at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/SaveCsuFinancialEvaluationTableFiRequest.java:38-112`.

Contract maxlength is DB-driven: `APPLICATION_NO` is `VARCHAR2(30)`, `DATA_SEQ` is `VARCHAR2(2)`, `RATIOS_DATE` is `VARCHAR2(10)`, and all stored ratio fields are `VARCHAR2(12)` at `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:38-56`. Current backend DTO uses `@Size(max=12)` for ratio fields at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/SaveCsuFinancialEvaluationTableFiRequest.java:31-113`; current FE input config uses integer maxlength 9 for numeric widgets at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-evaluation-fi/config/table-config.ts:73-90`, which is stricter than DB storage and must not be widened without RD review.

### R4 Save draft rows transactionally - 強制點: BE
covers-prd: FR-004

When `isFinish=false`, `epl-save-c0-financial-evaluation-table-fi` must save all submitted rows for one application in a single transaction, replacing existing rows for that `applicationNo`, and mark the page checkpoint as draft/incomplete. PRD Save behavior requires full replacement, `check=Y`, and success response at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:293-299`. Legacy 0120 save deletes by application and inserts rows in a transaction at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:196-224`.

The current backend `save` is transactional, deletes existing rows, inserts all request rows, updates checkpoint, and returns an empty map at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:195-216`. The save endpoint response must still carry the platform success code `COMMON_MSG_SAVE_SUCCESS` per PRD error/success mapping at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:466-475`.

### R5 Finish only after BE-required fields pass and update C0 checkpoint - 強制點: BE
covers-prd: FR-005, FR-006

When `isFinish=true`, the backend must enforce required FI fields before mutation is committed, then update `TB_CHECK_POINTS_CS.EPROC00120` or `TB_CHECK_POINTS_CU.EPROC00120` to complete/incomplete using the CS/CU case branch derived from summary attributes. PRD states Finished must block missing required fields and set checkpoint N on completion at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:353-359`; parent/checkpoint mapping is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:361-380`.

Current backend chooses CS/CU by `LON_ATTRIBUTE + SECURE_ATTRIBUTE` and updates `EPROC00120` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:255-274`. Current `FinancialEvaluationWhenFinishValidator` only checks `dataSeq` when `isFinish=true` at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/FinancialEvaluationWhenFinishValidator.java:20-36`; this is a to-be implementation gap because PRD required fields exceed `dataSeq`.

### R6 Query mode reads saved data without recalculation - 強制點: both
covers-prd: FR-007

When `isQuery=true`, the endpoint must return saved `TB_FINANCIAL_EVALUATION_FI` rows as historical data and must not recalculate from financial statement source tables. PRD historical query behavior is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:389-408`; legacy query mode reads saved table rows first at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:67-88`.

Current backend returns saved evaluation rows whenever rows exist, before checking edit/query mode at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:85-112`. That behavior is acceptable for query mode, but edit-mode recalculation remains governed by R2 and R13.

### R7 Carry legacy error codes and rollback behavior - 強制點: BE
covers-prd: FR-001, FR-004, FR-005

The SRS carries PRD error and success keys: `MSG_DATA_NOT_FOUND`, `MSG_OVER_COUNT_LIMIT`, `MSG_QUERY_FAIL`, `COMMON_MSG_ERROR_LON`, `ErrorInputException`, `COMMON_MSG_SAVE_FAIL`, and `COMMON_MSG_SAVE_SUCCESS`. PRD error response mapping is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:466-475` and includes `ErrorInputException` at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:572`. Legacy 0120 maps query failures at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:58-77` and save failures at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:100-116`.

Current backend platform errors such as `FAILED_E102`, `FAILED_E116`, and `FAILED_E201` use HTTP 200 envelopes at `backend/src/main/java/khd/svc/epro/enums/ReturnEnum.java:14`, `backend/src/main/java/khd/svc/epro/enums/ReturnEnum.java:39`, and `backend/src/main/java/khd/svc/epro/enums/ReturnEnum.java:60`; `CommonErrorHandler` returns those enum statuses at `backend/src/main/java/khd/svc/epro/advice/CommonErrorHandler.java:47-50`, `205-208`, and `223-226`. Authorization failures use `ACCESS_DENIED` HTTP 401 at `backend/src/main/java/khd/svc/epro/enums/ReturnEnum.java:99` and `backend/src/main/java/khd/svc/epro/config/security/APIAuthorizationFilter.java:51-52`. OpenAPI must therefore model business errors as platform envelopes unless backend status handling is explicitly changed.

Failed save or checkpoint update must roll back row replacement and checkpoint mutation. PRD rollback principle is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:576-583`; current backend wraps save in `@Transactional` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:195-216`.

### R8 Enforce backend authorization and role restrictions on mutation - 強制點: BE
covers-prd: FR-004, FR-005

`epl-save-c0-financial-evaluation-table-fi` is a mutating endpoint. The backend must require platform authentication, API authorization seed coverage, and service-level edit/role checks before delete/insert/checkpoint mutation. Backend AGENTS requires Spring Security + JWT and APIAuthorizationFilter based on `TB_API_AUTH` at `backend/AGENTS.md:25-35`; c0 auth findings warn endpoint authorization rows must be based on actual controllers and not guessed at `docs/build-tasks/done/c0-authz-sql.md:11-23`.

`TB_API_AUTH` seed presence alone is not sufficient proof. QA must verify both missing seed/access-denied behavior and direct service-level rejection of non-edit or wrong-role mutation attempts.

Auth seed and service guard closeout is still open: c0 auth findings show missing EPROC00120 auth rows at `docs/build-tasks/c0-authz-sql-findings.md:71-72`, while page/menu role rows are a distinct layer at `docs/build-tasks/c0-authz-sql-findings.md:85`. The current save service directly performs delete/save/checkpoint work at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:202-214`, `255-260` without source evidence of service-level edit-role rejection. This is P-011.

### R9 Reconcile current DTO extras and DB snapshot before release - 強制點: both
covers-prd: FR-003, FR-004

PRD and `docs/db-diff` target table snapshot list stored FI fields through `tierOneCapital` only at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:489-509` and `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:38-56`. Current backend request/response DTOs also expose `cetOneCapitalRatio` and `totalCapitalRatio` at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/SaveCsuFinancialEvaluationTableFiRequest.java:102-108` and `backend/src/main/java/khd/svc/epro/dto/response/corporate/csuFinancialEvaluationTableFi/InfoCsuFinancialEvaluationTableFiResponse.java:67-71`; current entity maps them to `CET_ONE_CAPITAL` and `TOTAL_CAPITAL` at `backend/src/main/java/khd/svc/epro/entity/TBFinancialEvaluationFiEntity.java:61-65`.

Until RD/DB confirms whether the db-diff snapshot is stale or the current implementation drifted, the SRS treats those two current DTO/entity fields as optional transitional API fields. They must not be treated as PRD/db-diff-confirmed columns, silently dropped without UI confirmation, or used as c0 corporate parity evidence.

### R10 @PENDING TBD-001 source DATA_SEQ/count alignment - 強制點: BE
covers-prd: FR-002

PRD TBD-001 says legacy aligns balance and income by index/DATA_SEQ and does not check count mismatch at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:38-41`. Exact to-be behavior for mismatch rejection, partial calculation, and error key is pending RD/SA decision. Minimum non-negotiable constraint: backend must not throw an unhandled exception or silently calculate with mismatched source periods.

### R11 @PENDING TBD-002 PERIODS denominator behavior - 強制點: BE
covers-prd: FR-002

PRD TBD-002 says ROA/ROE denominator behavior for `PERIODS=0` is not source-checked at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:41`. Exact display/error behavior remains pending. Current backend returns blank for zero average/period cases in helper methods at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:344-357`.

### R12 @PENDING TBD-003 COST_INCOME formula confirmation - 強制點: BE
covers-prd: FR-002

PRD TBD-003 flags the cost/income formula as legacy/nonstandard at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:42`. Until domain owner decides otherwise, as-is evidence remains the legacy formula at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:113-119`; SRS does not redefine the business formula.

### R13 @PENDING TBD-004 edit-mode existing values/date-change behavior - 強制點: both
covers-prd: FR-002, FR-003

PRD TBD-004 leaves edit-mode existing values, manual fields, and ratio-date change behavior open at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:43`. Legacy preserves manual fields only when saved rows match `RATIOS_DATE` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:97-113`. Current backend returns saved rows before recomputation when saved rows exist at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:85-112`, so edit-mode recalculation parity requires RD verification.

### R14 @PENDING TBD-005 Save vs Finished validation breadth - 強制點: BE
covers-prd: FR-004, FR-005

PRD TBD-005 states Save has no required validation and Finished checks required fields, but legacy backend only checks application number at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:44`. Exact required-field set for BE Finished validation is pending. Current frontend validates on Finish at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-evaluation-fi/financial-evaluation-fi.component.ts:128-152`, but BE validation must be authoritative for mutation.

### R15 @PENDING TBD-006 RC old-case save/finish/callback behavior - 強制點: both
covers-prd: FR-006, FR-008

PRD TBD-006 says `EPROC0_0219/0220` old cases have no Finished button and callbacks do not update done state at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:45`. Legacy RC JSP shows Finished only when `!attrMap.isOld` at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00220.jsp:165-170`, and JS updates parent check/done only when not old at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00220_JS.jsp:122-125`. Current c0 page needs parity verification for old-case mode.

### R16 @PENDING TBD-007 function-name/i18n key mismatch - 強制點: FE
covers-prd: FR-008

PRD TBD-007 flags that `EPROC00220` JS uses `EPROC0_0120_FUNC_NAME` while the parent uses `EPROC00120_FUNC_NAME` at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:46-48`. FE label/i18n behavior is pending RD/UX confirmation and must not affect backend data mutation.

### R17 @PENDING TBD-008 shared FI table ownership with I0 - 強制點: BE
covers-prd: FR-003, FR-004

PRD TBD-008 notes `TB_FINANCIAL_EVALUATION_FI` is shared by C0 and I0, while this PRD only covers C0 at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:49-50`. Any I0/c0 shared-table migration or cleanup decision is pending; this SRS does not import I0 rules.

### R18 @PENDING corporate direct parity/refactor baseline gap - 強制點: both
covers-prd: FR-001, FR-002, FR-003, FR-004, FR-005, FR-006, FR-007, FR-008

Per-page inventory marks `EPROC00120` as T1, business-only money, and needing SRS/parity input at `docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md:31-43`; the queue row says `prd-ready` and "待 parity 碼驗餵入(i0-mirror·無 refactor baseline)" at `docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md:133`. Corporate direct parity code verification remains pending and blocks owner approval.

### R19 Parent progress and cross-page reset contract - 強制點: both
covers-prd: FR-006, FR-008

The SRS must carry the PRD/legacy parent-progress target contract even though current DTO/service evidence is incomplete. Save requests need `pageCheckMap` and save responses need `isAllTabsCheck` for parent tab progress at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:453-464`; legacy 0120 reads `pageCheckMap` and returns `isAllTabsCheck` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:94-99`, and legacy JS updates parent done style at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00120_JS.jsp:116-130`. Because current DTO/service exposes only `applicationNo`/`isFinish`/`financialList` and returns an empty map, OpenAPI keeps the current-confirmed API shape and P-012 blocks approval until RD/FE either implements the target contract or assigns it to an explicit parent endpoint with traceable evidence.

Cross-page side effects are also in scope for traceability: 0119/0219 save must reset 0120/0220 checkpoint, and 0110/0210 Business Type change must delete FI evaluation / statement data per PRD tests at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:619-621`. Current backend/request gaps for `pageCheckMap`, `isAllTabsCheck`, and cross-page trigger ownership are tracked by P-012; they are not silently excluded.

### R20 @PENDING rounding mode and intermediate scale - 強制點: BE
covers-prd: FR-002

Automatic ratio fields must use one explicitly approved rounding policy for final two-decimal display and intermediate division scale. Legacy 0120 uses `ROUND_HALF_DOWN` plus `formatTwo` in formula branches at `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:117`, `124`, `138`, `148`, `158`, `164`; current backend helper paths use `RoundingMode.HALF_UP` at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:329`, `339`, `352`, `355`, and shared `NumberUtil` also rounds HALF_UP to two decimals at `backend/src/main/java/khd/svc/epro/util/NumberUtil.java:425-437`. The SRS does not choose between these without RD/domain confirmation; P-013 blocks approval until the to-be rounding mode and intermediate scale are decided and covered by boundary QA.

## DB Reconcile / Delta
| Delta | Source | Impact | Disposition |
|---|---|---|---|
| Target FI table is active/exact and string-stores ratio values. | `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:6-16`, `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:38-56` | R3-R5, schema.sql | Carried. |
| Source statement tables use numeric money fields and `PERIODS`. | `docs/db-diff/02_tables/TB_FIN_STATEMENT_BALANCE_FI.md:38-42`, `docs/db-diff/02_tables/TB_FIN_STATEMENT_INCOME_FI.md:38-41` | R2, R10-R11 | Carried with pending edge decisions. |
| New checkpoint tables use `EPROC00120` columns for CS/CU. | `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:38-53`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:38-49` | R5 | Carried. |
| Current DTO/entity contains two capital ratio fields absent from PRD/db-diff snapshot. | DTO evidence at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/SaveCsuFinancialEvaluationTableFiRequest.java:102-108`; entity evidence at `backend/src/main/java/khd/svc/epro/entity/TBFinancialEvaluationFiEntity.java:61-65`; DB snapshot at `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:38-56` | R9 | `@PENDING` RD/DB reconcile: stale snapshot vs implementation drift. |
| `EPROC00120` has no independent refactor-spec module. | Dispatch at `docs/build-tasks/prd-to-srs-codex-dispatch.md:79-80` | R18 | `@PENDING` parity code verification. |
| PRD/legacy parent-progress fields exceed current DTO/service evidence. | PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:453-464`; current DTO only has `applicationNo/isFinish/financialList` at `backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/SaveCsuFinancialEvaluationTableFiRequest.java:17-29`; current save returns empty map at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:214-215` | R19 | `@PENDING` implementation closeout. |

## Money, Precision, Maxlength, and Truncation
Rounding policy for automatic ratio fields is intentionally not defaulted: `growthOfGrossLoans`, `cost`, `roa`, `roe`, and `loans` are governed by R20/P-013 until RD/domain closes HALF_DOWN vs HALF_UP and intermediate-scale behavior. All VARCHAR2(12) stored ratio fields must reject overlength before DB write; no silent truncation is allowed.

| API field | DB/source column | Max/precision | Rule |
|---|---|---|---|
| `applicationNo` | `APPLICATION_NO` | 30 chars | Reject blank/overlength; no truncation. |
| `dataSeq` | `DATA_SEQ` | 2 chars in target table | Preserve source order/key; no truncation. |
| `ratiosDate` | `RATIOS_DATE` | 10 chars | Store/display date string per page contract; date-change parity pending R13. |
| `nplRatios` | `NPL` | 12 chars | Manual field; reject overlength before DB write. |
| `loanLossReserves` | `LLR` | 12 chars | Manual field; reject overlength before DB write. |
| `loanLossReserveOverNpl` | `LLR_OVER_NPL` | 12 chars | Manual field; reject overlength before DB write. |
| `growthOfGrossLoans` | `GGL` | 12 chars | First period `N/A`; rounding mode and intermediate scale pending R20. |
| `aggregateLargeExposureRatio` | `AGREE_LARGE_EXPOSURE` | 12 chars | Required on Finished pending final R14 list; reject overlength. |
| `creditExposureToSingleBeneficiary` | `CREDIT_EXPOSURE_TO_SB` | 12 chars | Required on Finished pending final R14 list; reject overlength. |
| `relatedPartyExposure` | `RELATED_PARTY_EXPOSURE` | 12 chars | Required on Finished pending final R14 list; reject overlength. |
| `unhedgedForeignCurrencyRatio` | `UNHEDGED_FOREIGN_CURR` | 12 chars | Required on Finished pending final R14 list; reject overlength. |
| `netInterestMargin` | `NET_INTEREST_MARGIN` | 12 chars | Manual field; reject overlength. |
| `cost` | `COST_INCOME` | 12 chars | Derived text; `N/A` allowed when denominator is zero; formula pending R12 and rounding pending R20. |
| `roa` | `ROA` | 12 chars | First period `N/A`; `PERIODS=0` behavior pending R11 and rounding pending R20. |
| `roe` | `ROE` | 12 chars | First period `N/A`; `PERIODS=0` behavior pending R11 and rounding pending R20. |
| `loans` | `LOANS_DEPOSITS` | 12 chars | Derived text; `N/A` allowed when denominator is zero; rounding pending R20. |
| `liquidityCoverageRatio` | `LIQUIDITY_COVERAGE` | 12 chars | Required on Finished pending final R14 list; reject overlength. |
| `solvencyRatio` | `SOLVENCY` | 12 chars | Required on Finished pending final R14 list; reject overlength. |
| `tier1CapitalRatio` | `TIER_ONE_CAPITAL` | 12 chars | Manual field; reject overlength. |
| `cetOneCapitalRatio`, `totalCapitalRatio` | current entity maps `CET_ONE_CAPITAL` / `TOTAL_CAPITAL`, absent from PRD/db-diff | 12 chars in current DTO/entity; PRD/db-diff TBD | Transitional runtime fields tested by QA-009 only; not part of main OpenAPI contract until R9/P-010 is closed. |

## NFR
- Transaction: save/finish replacement and checkpoint update must commit or roll back together, per PRD transaction principle at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:589-595`.
- Security: mutating endpoint requires platform auth, API authorization row, and service-level edit/role guard; `TB_API_AUTH` alone is not sufficient proof.
- Audit: query/save actions must preserve safe audit trail behavior; legacy 0120 calls audit for query/save at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:47-53` and `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:87-92`.
- Observability: logs must not print full request payloads with customer financial ratios; use bounded error context.

## @PENDING
| ID | Pending | Owner | Blocks |
|---|---|---|---|
| P-001 | TBD-001 source DATA_SEQ/count mismatch handling. | RD/SA | Approval and R2 edge QA. |
| P-002 | TBD-002 `PERIODS=0` denominator behavior for ROA/ROE. | Domain/RD | Approval and R2 edge QA. |
| P-003 | TBD-003 nonstandard `COST_INCOME` formula confirmation. | Domain | Approval if formula changes. |
| P-004 | TBD-004 edit-mode existing saved values/date-change behavior. | RD/SA | Approval and edit-mode regression QA. |
| P-005 | TBD-005 exact Save vs Finished BE required-field set. | RD/SA | Approval and R5/R14 QA. |
| P-006 | TBD-006 RC old-case Finished/callback behavior in new c0 implementation. | RD/SA | Approval and R15 QA. |
| P-007 | TBD-007 function-name/i18n key mismatch. | FE/RD | Label/i18n parity only. |
| P-008 | TBD-008 shared c0/i0 FI table ownership. | RD/DBA | Data ownership approval. |
| P-009 | Missing independent c0 `EPROC00120` refactor baseline and direct parity code verification. | RD/SA | T1 owner approval. |
| P-010 | Current DTO/entity `cetOneCapitalRatio`/`totalCapitalRatio` maps to backend `CET_ONE_CAPITAL`/`TOTAL_CAPITAL`, but PRD/db-diff snapshot lacks those columns. | RD/DBA | API/DB closeout: stale snapshot vs implementation drift. |
| P-011 | EPROC00120 auth closeout: apply/recheck `TB_API_AUTH` seed rows and add/verify service-level edit-role guard for direct save/finish calls. | RD/Security/DBA | Approval and R8 auth QA/regression. |
| P-012 | PRD/legacy parent-progress contract gap: current DTO/service lacks `mainBorrowerName`/`checkpointStatus` response, `pageCheckMap` request, `isAllTabsCheck` response, and confirmed ownership for 0119/0219 reset plus 0110/0210 deletion triggers. | RD/SA/FE | Approval and FR-006/FR-008 regression QA. |
| P-013 | Rounding mode/intermediate scale for automatic ratio fields: legacy HALF_DOWN/formatTwo vs current HALF_UP helpers. | RD/Domain | Approval and R20 rounding boundary QA. |

## Traceability Matrix
| PRD | Rules | QA |
|---|---|---|
| FR-001 | R1, R7, R18, R19 | QA-001, QA-002, QA-003, QA-017, QA-023, QA-024 |
| FR-002 | R2, R3, R10, R11, R12, R13, R18, R20 | QA-004, QA-005, QA-006, QA-022, QA-023, QA-026, QA-029, QA-030, QA-032 |
| FR-003 | R3, R9, R13, R17, R18 | QA-007, QA-008, QA-009, QA-021, QA-023, QA-026, QA-028 |
| FR-004 | R4, R7, R8, R9, R14, R17, R18 | QA-010, QA-011, QA-012, QA-015, QA-016, QA-018, QA-023, QA-028, QA-031 |
| FR-005 | R5, R7, R8, R14, R18 | QA-013, QA-014, QA-015, QA-019, QA-023, QA-031 |
| FR-006 | R5, R15, R18, R19 | QA-014, QA-015, QA-020, QA-023, QA-024, QA-025 |
| FR-007 | R6, R18 | QA-001, QA-003, QA-023 |
| FR-008 | R1, R15, R16, R18, R19 | QA-020, QA-023, QA-024, QA-025, QA-027 |

## Hard Boundaries
- Do not use `EPROI00120` as c0 as-is evidence. It may only inform risk comparison because dispatch marks it as a nearby mirror, not a corporate baseline.
- Do not self-promote to Approved. This bundle is a draft-for-review until mechanical gate plus N-axis review plus human/owner checkpoint close the pending rows.
- Do not weaken PRD TBD/C-class items. They remain `@PENDING` until owner/RD decision.
