# SRS - EPROC00120 Corporate Financial Evaluation FI

## Metadata
| Field | Value |
|---|---|
| Status | 規格定版: Approved (2026-06-25, owner — axis A–F 獨立再審 0 Blocker、fix-card 🟡 全真修確認); 實作完成: done (owner 2026-06-25; rd-done+獨立驗+ratify) (QA 暫拔除); 殘留非阻擋 🟡 見 pending-register |
| N-axis review | Mechanical gate PASS and independent A-F SRS re-review PASS on 2026-06-24 after adopting findings. 2026-06-25 fix-round 獨立再審 (cross-model): R1/R19 本頁 `applicationName`/checkpoint 不被 P-012 誤排（FE 斷料封）、P-005 採 PRD 5.3.1 人工欄、db-diff disclaim 消不對稱、R2 改引 R10、行級 `@2ae96d0`、`EPROC00120_FUNC_NAME` literal 全真修，0 Blocker → owner-approved 規格定版 2026-06-25. 殘留非阻擋 🟡（Traceability 殘段 grandfathered、openapi 兩 row schema 重複可維護性）折翻新/下次 touch。Owner decisions dated 2026-06-24 plus owner-authorized self-resolution close P-001 through P-013. Axis G / QA generation remains paused by process. |
| funcId | EPROC00120 |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md` |
| Bundle | `docs/specs/srs/EPROC00120/` |
| Source baseline | PRD v1.0 + Bible v1.1 + local db-diff + legacy `EPROC0_0120`/`EPROC0_0220` + current corporate code at commit `2ae96d0` |
| Baseline disclaimer | No independent `docs/refactor-spec/02_modules/EPROC00120.md` or formal corporate refactor artifact was found. Per owner policy 1, this SRS uses legacy/current code-as-baseline plus parity verification and does not invent a formal artifact. db-diff snapshot 已於母資料夾 finalize 時覆核. |
| Code evidence format | Current-code line evidence is pinned to repository snapshot `2ae96d0` using the CODE tag format. |
| Risk tier | T1 c0 corporate money page; SRS N-axis A-F required; G is dormant while QA is paused |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`; `qa-cases.md` is intentionally absent while QA generation is paused |

## Scope
- This SRS covers the corporate C0 FI financial-evaluation page migrated from legacy main-chain `EPROC0_0120` and RC chain `EPROC0_0220` into funcId `EPROC00120`. PRD names those legacy chains and page purpose at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:15-19`.
- In scope: query page data, compute FI ratios from source statement rows, preserve manual ratio fields, save incomplete draft rows, finish with checkpoint update, enforce authorization, and keep RC old-case restrictions. PRD flow and mode matrix are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:120-156`.
- Out of scope: I0 FI behavior, staff-loan endpoints, and C0/I0 shared-table cleanup. Dispatch forbids treating I0 as corporate as-is and c0 findings state old corporate `00120` is BusinessOwner-only at `docs/build-tasks/done/phase-f-step3-00120-financial-evaluation-fi.md:1-4`.
- Parent tab progress is not added to this page DTO. Per owner decision P-012, EPROC00120 updates its own checkpoint; parent progress/checkpoint aggregation is handled by an independent parent/checkpoint endpoint.

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD functional scope | FR-001 through FR-008 are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:162-169`. | Carried by R1-R20. |
| PRD TBD list | TBD-001 through TBD-008 are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:38-50`. | Closed by owner decisions P-001 through P-008 in the Decision Register. |
| Bible guard | Bible says C0/I0 financial evaluation must stay in the correct page family and preserve source-confirmed IDs at `docs/specs/bible/bible-eproposal.md:737-741`. | This SRS uses C0 legacy IDs only as C0 evidence. |
| Dispatch rule | Corporate pages compare against old corporate sources, not I0/ISU, and absent parity must be explicitly marked at `docs/build-tasks/prd-to-srs-codex-dispatch.md:47-50`. | Closed by code-as-baseline policy P-009 with legacy/current corporate code evidence. |
| T1 review rule | T1/c0 rating pages require per-page checkpoint and cannot be drained as low risk at `docs/process/orchestration-playbook.md:83-86`. | A-F review is required before owner stamp. |
| Existing inventory | `EPROC00120` is business-only FE built with endpoints and no staff cleanup at `docs/feature-inventory.md:104-107`. | Confirms C0 business scope. |
| Current backend API | Controller exposes POST `epl-info-c0-financial-evaluation-table-fi` at `[CODE:backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialEvaluationTableFiController.java:25@2ae96d0]` and POST `epl-save-c0-financial-evaluation-table-fi` at `[CODE:backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialEvaluationTableFiController.java:36@2ae96d0]`. | Endpoints use real RPC `epl-*`/POST. |
| Current FE API | Angular service calls the info endpoint at `[CODE:frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-evaluation-fi/services/api.service.ts:26@2ae96d0]` and save endpoint at `[CODE:frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-evaluation-fi/services/api.service.ts:41@2ae96d0]`. | Endpoint names are grounded in current source. |
| Legacy query/save | Legacy 0120 query/save is at `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:47@2ae96d0]` and `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:116@2ae96d0]`; legacy 0220 RC counterpart is at `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0220.java:46@2ae96d0]` and `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0220.java:98@2ae96d0]`. | Baseline for query/save/error behavior. |
| Legacy formulas | Legacy 0120/0220 compute cost/income, loans/deposits, GGL, ROA, ROE and format values at `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:113@2ae96d0]`, `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:165@2ae96d0]`, `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0220_mod.java:113@2ae96d0]`, and `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0220_mod.java:165@2ae96d0]`. | Formula and rounding baseline. |
| Current backend formula path | Current service loads saved/source rows at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:55@2ae96d0]`, aligns by `dataSeq` at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:116@2ae96d0]`, computes ratios, saves rows, and updates checkpoint at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:214@2ae96d0]`. | Code-as-baseline plus RD conformance gaps. |
| New DB snapshot | Target table columns and lengths for `TB_FINANCIAL_EVALUATION_FI` are listed at `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:38-56`. | Schema and maxlength are DB-snapshot driven; db-diff snapshot 已於母資料夾 finalize 時覆核. |
| Auth boundary | Backend convention requires Spring Security JWT, `APIAuthorizationFilter`, and `TB_API_AUTH` at `backend/AGENTS.md:25-35`. Endpoint naming convention is `epl-{verb}-c0-{feature}` at `backend/AGENTS.md:47-48`. | Mutating endpoint requires both API seed and service guard. |

## Endpoints
| Endpoint | Method | Purpose | Rules |
|---|---|---|---|
| `epl-info-c0-financial-evaluation-table-fi` | POST | Query current FI ratio rows and source-derived/manual fields. | R1-R3, R6-R9, R19 |
| `epl-save-c0-financial-evaluation-table-fi` | POST | Save or finish FI ratio rows and update the C0 FI checkpoint. | R3-R9, R14-R20 |

## BR/SC Coverage
| PRD rule | Evidence | SRS rule |
|---|---|---|
| BR-001 source rows by `DATA_SEQ` | PRD business rules at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:545-547`; legacy orders source rows at `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:90@2ae96d0]` and `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:95@2ae96d0]`. | R1, R2, R10 |
| BR-002 through BR-008 formulas | PRD formula list at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:548-554`. | R2, R10-R13, R20 |
| BR-009 manual fields | PRD manual-field list at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:555`; legacy preserves manual fields by ratio date at `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:97@2ae96d0]` and `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:113@2ae96d0]`. | R3, R13 |
| BR-010 through BR-012 save/finish/checkpoint | PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:556-558`. | R4, R5, R14, R19 |
| BR-013 through BR-015 query mode, error, old case | PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:559-560`. | R6, R7, R15 |
| SC source matrix | PRD mode matrix at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:152-156`. | R1, R4-R6 |
| FR-006 parent progress and cross-page reset | PRD save contract lists parent progress at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:453-464`; cross-page tests are at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:619-621`. | R19 |

## Security/Auth Coverage
| Source condition | Evidence | SRS disposition |
|---|---|---|
| Role responsibility and auth boundary must not be conflated. | `docs/specs/bible/bible-eproposal.md:77-82` | R8 separates API seed, page/menu permission, and service-level edit guard. |
| `SECURE_ATTRIBUTE` controls CS/CU branch and checkpoint table. | `docs/specs/bible/bible-eproposal.md:793-796`; current backend branches by `LON_ATTRIBUTE + SECURE_ATTRIBUTE` at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:255@2ae96d0]` and `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:274@2ae96d0]`. | R5, R19. |
| `TB_API_AUTH` must be verified per actual API path. | `[CODE:backend/src/main/java/khd/svc/epro/config/security/APIAuthorizationFilter.java:38@2ae96d0]` and `[CODE:backend/src/main/java/khd/svc/epro/config/security/APIAuthorizationFilter.java:43@2ae96d0]`; c0 auth findings show missing EPROC00120 rows at `docs/build-tasks/c0-authz-sql-findings.md:71-72`. | R8 closes the SRS rule; seed absence is RD/DBA conformance work. |
| Mutating endpoint must reject direct wrong-role/non-editor calls. | Save currently deletes/reinserts and updates checkpoint at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:202@2ae96d0]`, `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:214@2ae96d0]`, `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:255@2ae96d0]`, and `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:260@2ae96d0]`; no service-level guard evidence is present. | R8 requires a service guard; current gap is downstream implementation conformance. |
| Disaster/security failure must not partially mutate data. | PRD rollback principle at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:576-583`; current save is transactional at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:195@2ae96d0]` and `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:216@2ae96d0]`. | R4, R7. |

## Rules

### R1 Load C0 FI financial-evaluation context - 強制點: both
covers-prd: FR-001, FR-008

Given a valid `applicationNo`, `epl-info-c0-financial-evaluation-table-fi` must return page-local initialization data: `applicationName`, this page's `checkpoint` value for `EPROC00120`, and a `financialList` of FI ratio rows. PRD query flow requires audit, main-borrower/checkpoint lookup, and query action at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:198-203`, with response fields `dataMap.APPLICATION_NAME`, `dataMap.check`, and `fiList` at `:449-451`. Legacy 0120 does `auditLog`, `getOther`, and `query` at `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:47@2ae96d0]` and `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:57@2ae96d0]`.

P-012 only excludes parent progress aggregation from this page DTO. It does not exclude this page's own display header or checkpoint state. Current response DTO exposes only `financialList` at `[CODE:backend/src/main/java/khd/svc/epro/dto/response/corporate/csuFinancialEvaluationTableFi/InfoCsuFinancialEvaluationTableFiResponse.java:12@2ae96d0]`, so RD must add `applicationName` and `checkpoint` to close the conformance gap. Parent all-tab/progress refresh remains delegated to the independent parent/checkpoint endpoint under R19 after save/finish.

### R2 Compute editable FI ratios from aligned source rows - 強制點: BE
covers-prd: FR-002

When `isQuery=false`, the backend must compute automatic ratio fields from `TB_FIN_STATEMENT_BALANCE_FI` and `TB_FIN_STATEMENT_INCOME_FI`, ordered by `DATA_SEQ`. Source row count/key mismatch handling is defined by R10; R2 must call that rule instead of carrying a duplicate rejection definition.

Automatic fields are `growthOfGrossLoans` (`GGL`), `cost` (`COST_INCOME`), `roa` (`ROA`), `roe` (`ROE`), and `loans` (`LOANS_DEPOSITS`). PRD formulas are listed at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:548-554`. Current backend aligns by `dataSeq` at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:116@2ae96d0]` and computes these fields from `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:152@2ae96d0]`; this is the code-as-baseline, with R10/R11/R13/R20 deltas applied as to-be rules.

### R3 Preserve manual fields and enforce field length/precision - 強制點: both
covers-prd: FR-002, FR-003

Manual fields must be accepted, saved, and returned without silent truncation: `nplRatios`, `loanLossReserves`, `loanLossReserveOverNpl`, `aggregateLargeExposureRatio`, `creditExposureToSingleBeneficiary`, `relatedPartyExposure`, `unhedgedForeignCurrencyRatio`, `netInterestMargin`, `liquidityCoverageRatio`, `solvencyRatio`, and `tier1CapitalRatio`. PRD field mapping is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:489-509`; DB snapshot columns are at `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:38-56`.

Contract maxlength is DB-driven: `APPLICATION_NO` is `VARCHAR2(30)`, `DATA_SEQ` is `VARCHAR2(2)`, `RATIOS_DATE` is `VARCHAR2(10)`, and stored ratio fields are `VARCHAR2(12)`. Current backend DTO uses `@Size(max=12)` for ratio fields such as `[CODE:backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/SaveCsuFinancialEvaluationTableFiRequest.java:55@2ae96d0]` and `[CODE:backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/SaveCsuFinancialEvaluationTableFiRequest.java:111@2ae96d0]`; FE numeric widget limits are UI constraints and must not override the backend contract.

### R4 Save draft rows transactionally - 強制點: BE
covers-prd: FR-004

When `isFinish=false`, `epl-save-c0-financial-evaluation-table-fi` must save all submitted rows for one application in a single transaction, replacing existing rows for that `applicationNo`, and mark the page checkpoint as draft/incomplete. PRD Save behavior requires full replacement, `check=Y`, and success response at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:293-299`. Legacy 0120 save deletes by application and inserts rows in a transaction at `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:196@2ae96d0]` and `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:224@2ae96d0]`.

The current backend save is transactional at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:195@2ae96d0]`, deletes existing rows, inserts all request rows, updates checkpoint at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:214@2ae96d0]`, and returns an empty map at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:215@2ae96d0]`. Save success uses platform code `COMMON_MSG_SAVE_SUCCESS` per PRD mapping at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:466-475`.

### R5 Finish only after BE-required fields pass and update C0 checkpoint - 強制點: BE
covers-prd: FR-005, FR-006

When `isFinish=true`, the backend must enforce required FI fields before mutation is committed, then update `TB_CHECK_POINTS_CS.EPROC00120` or `TB_CHECK_POINTS_CU.EPROC00120` to complete/incomplete using the CS/CU case branch derived from summary attributes. PRD states Finished must block missing required fields and set checkpoint N on completion at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:353-359`. Checkpoint update must affect exactly one row; zero-row or ambiguous update results must throw and roll back the row replacement transaction.

Finished requires each row to include `dataSeq`, `ratiosDate`, and these PRD-required manual fields: `aggregateLargeExposureRatio`, `creditExposureToSingleBeneficiary`, `relatedPartyExposure`, `unhedgedForeignCurrencyRatio`, `liquidityCoverageRatio`, and `solvencyRatio` (`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:267-270`). Owner correction 2026-06-24 confirms this set follows PRD 5.3.1: automatic formula fields are system-calculated and are not user-required input fields. `tier1CapitalRatio` remains a manual field but is not promoted to Finished-required without an owner/domain change. Current validator only checks `dataSeq` at `[CODE:backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/FinancialEvaluationWhenFinishValidator.java:33@2ae96d0]`; that is an RD conformance gap, not an open SRS decision.

### R6 Query mode reads saved data without recalculation - 強制點: both
covers-prd: FR-007

When `isQuery=true`, the endpoint must return saved `TB_FINANCIAL_EVALUATION_FI` rows as historical data and must not recalculate from financial statement source tables. PRD historical query behavior is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:389-408`; legacy query mode reads saved table rows first at `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:67@2ae96d0]` and `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:88@2ae96d0]`.

Current backend returns saved evaluation rows whenever rows exist before edit/query branching at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:85@2ae96d0]` and `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:112@2ae96d0]`. That behavior is acceptable for query mode; edit-mode date/change behavior is governed by R13.

### R7 Carry legacy error codes and rollback behavior - 強制點: BE
covers-prd: FR-001, FR-004, FR-005

The SRS carries PRD error and success keys: `MSG_DATA_NOT_FOUND`, `MSG_OVER_COUNT_LIMIT`, `MSG_QUERY_FAIL`, `COMMON_MSG_ERROR_LON`, `ErrorInputException`, `COMMON_MSG_SAVE_FAIL`, and `COMMON_MSG_SAVE_SUCCESS`. PRD error response mapping is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:466-475` and includes `ErrorInputException` at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:572`.

Current platform business errors use HTTP 200 envelopes; authorization failures use `ACCESS_DENIED` / `E405` over HTTP 401. Failed save or checkpoint update must roll back row replacement and checkpoint mutation. A checkpoint update returning zero affected rows is a failed checkpoint update and must throw. PRD rollback principle is at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:576-583`; current save is `@Transactional` at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:195@2ae96d0]`. Current `updateCheckpoint()` does not prove affected-row enforcement, so RD must close that conformance gap before release.

### R8 Enforce backend authorization and role restrictions on mutation - 強制點: BE
covers-prd: FR-004, FR-005

`epl-save-c0-financial-evaluation-table-fi` is a mutating endpoint. Per owner policy 3, the to-be contract requires two authorization layers before delete/insert/checkpoint mutation: `TB_API_AUTH` seed coverage for the real API path and a service-level guard that verifies case editability, ownership/role, RC old-case `isFinish=true` rejection, and direct-call authorization. `TB_API_AUTH` seed presence alone is not sufficient proof.

c0 auth findings show missing EPROC00120 auth rows at `docs/build-tasks/c0-authz-sql-findings.md:71-72`, and current save service performs mutation without source evidence of a service-level edit-role/old-case rejection at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:202@2ae96d0]` and `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:255@2ae96d0]`. Those are downstream RD/DBA conformance gaps; the SRS decision is closed as the two-layer authorization requirement. Before implementation release, RD/DBA must add the actual `TB_API_AUTH` rows for `epl-save-c0-financial-evaluation-table-fi` and service guard logic before any delete/insert/checkpoint update.

### R9 Reconcile current DTO extras and DB snapshot before release - 強制點: both
covers-prd: FR-003, FR-004

PRD and `docs/db-diff` target table snapshot list stored FI fields through `tierOneCapital` only at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:489-509` and `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:38-56`. Current backend request/response DTOs also expose `cetOneCapitalRatio` and `totalCapitalRatio` at `[CODE:backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/SaveCsuFinancialEvaluationTableFiRequest.java:102@2ae96d0]`; current entity maps them to `CET_ONE_CAPITAL` and `TOTAL_CAPITAL` at `[CODE:backend/src/main/java/khd/svc/epro/entity/TBFinancialEvaluationFiEntity.java:61@2ae96d0]`.

The to-be OpenAPI contract excludes those two fields because PRD and the db-diff snapshot are the higher-priority sources for this SRS. The current DTO/entity fields are recorded as an RD/DBA conformance drift: RD must either remove/ignore them from the page contract or provide a later owner-approved DB/schema delta. They are not Finished-required and must not be treated as EPROC00120 parity evidence in this bundle.

### R10 Reject source DATA_SEQ/count mismatch - 強制點: BE
covers-prd: FR-002

Owner decision P-001 closes PRD TBD-001: the to-be behavior is strict mismatch rejection. Balance and income source rows must have the same count and the same ordered `DATA_SEQ` set before ratio computation. Mismatch returns a controlled validation/business error (`ErrorInputException` or the platform equivalent); partial calculation and silent row dropping are forbidden.

### R11 Render PERIODS=0 annualized ratios as N/A - 強制點: BE
covers-prd: FR-002

Owner decision P-002 closes PRD TBD-002: when `PERIODS=0`, annualized ROA and ROE display/store as `N/A`. This follows the existing first-period/zero-denominator `N/A` pattern. Current backend helper returns blank for zero average/period cases at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:344@2ae96d0]` and `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:357@2ae96d0]`; that is an RD conformance gap.

### R12 Keep legacy COST_INCOME formula - 強制點: BE
covers-prd: FR-002

Owner decision P-003 closes PRD TBD-003: keep the legacy formula unless a later owner-approved business change says otherwise. `COST_INCOME = OPERATING_EXPENSES * 100 / CONTINUING_OP_INCOME_BT`; denominator zero renders `N/A`. Legacy 0120 formula evidence is at `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:113@2ae96d0]` and `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:119@2ae96d0]`.

### R13 Preserve saved manual values only for matching RATIOS_DATE - 強制點: both
covers-prd: FR-002, FR-003

Owner decision P-004 closes PRD TBD-004: edit-mode saved/manual values are preserved only when the saved row matches the same `RATIOS_DATE`. If the source period/date changes or a new source row appears, automatic fields must be recomputed and manual fields must start blank/re-entered for that row; hidden carryover across changed dates is forbidden.

Legacy preserves manual fields by ratio-date match at `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:97@2ae96d0]` and `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:113@2ae96d0]`. Current backend returns saved rows before recomputation whenever saved rows exist at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:85@2ae96d0]` and `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:112@2ae96d0]`; RD must align implementation to this rule.

### R14 Separate Save draft validation from Finished validation - 強制點: BE
covers-prd: FR-004, FR-005

Owner decision P-005 closes PRD TBD-005: Save draft allows incomplete ratio content but still requires the request envelope (`applicationNo`, `isFinish`, `financialList`) and per-row identity needed for persistence (`dataSeq`, `ratiosDate`). Finished validation is stricter and must enforce the R5 required-field list on the backend, regardless of FE validation. Owner correction 2026-06-24 adopts PRD 5.3.1 manual-required fields only; automatic formula fields are system-calculated and are not user-required.

### R15 Preserve RC old-case restriction - 強制點: both
covers-prd: FR-006, FR-008

Owner decision P-006 closes PRD TBD-006: RC old cases support Save only and must not expose or accept Finished. Legacy RC JSP shows Finished only when `!attrMap.isOld` at `[CODE:legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00220.jsp:165@2ae96d0]` and `[CODE:legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00220.jsp:170@2ae96d0]`, and JS updates parent done style only when not old at `[CODE:legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00220_JS.jsp:122@2ae96d0]` and `[CODE:legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00220_JS.jsp:125@2ae96d0]`.

The OpenAPI request remains the shared page shape with `isFinish`; it does not carry a client-controlled old-case flag. Backend service guard must derive old-case status from trusted case context and reject direct `isFinish=true` calls before mutation. Current backend has no source evidence of that guard, so RD must close the conformance gap.

### R16 Use the EPROC00120 function label/key for the migrated page - 強制點: FE
covers-prd: FR-008

Owner decision P-007 closes PRD TBD-007: the migrated C0 page must use the EPROC00120 function identity/label, including literal key `EPROC00120_FUNC_NAME`. The legacy RC mismatch (`EPROC0_0120_FUNC_NAME` under an 0220 path) is not carried into the new UI and has no backend mutation impact.

### R17 Keep this SRS C0-only despite shared FI table - 強制點: BE
covers-prd: FR-003, FR-004

Owner decision P-008 closes PRD TBD-008: `TB_FINANCIAL_EVALUATION_FI` is shared by C0/I0, but this SRS governs only C0 `EPROC00120`. Implementations must scope reads/writes by C0 application/page context and must not migrate, delete, or reinterpret I0 data under this bundle.

### R18 Use code-as-baseline for missing corporate refactor artifact - 強制點: both
covers-prd: FR-001, FR-002, FR-003, FR-004, FR-005, FR-006, FR-007, FR-008

Owner decision P-009 closes the missing-baseline gap under policy 1. Formal corporate refactor baseline for `EPROC00120` is UNFOUND. The SRS uses legacy corporate sources `EPROC0_0120`/`EPROC0_0220` and current corporate implementation at commit `2ae96d0` as the as-is baseline, with explicit parity deltas in R10-R20. No formal artifact is fabricated.

### R19 Assign parent progress to an independent parent/checkpoint endpoint - 強制點: both
covers-prd: FR-006, FR-008

Owner decision P-012 closes only the PRD/legacy parent-progress DTO gap: EPROC00120 save does not add `pageCheckMap`, `isAllTabsCheck`, or parent checkpoint aggregation fields to this page save contract. It does not remove the R1 page-local `applicationName` and `checkpoint` fields from the info response. The page save endpoint updates only its own `EPROC00120` checkpoint. Load sequence is: FE calls the info endpoint first to render `applicationName`, current `checkpoint`, and `financialList`; after save/finish, FE calls an independent parent/checkpoint endpoint to refresh parent tab progress and all-tab completion state.

Cross-page triggers remain traceable implementation obligations: 0119/0219 save resets 0120/0220 checkpoint, and 0110/0210 Business Type change deletes FI evaluation/statement data per PRD tests at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:619-621`. Ownership belongs to the parent/source pages or their orchestration endpoint, not to extra fields in the EPROC00120 save DTO.

### R20 Use legacy HALF_DOWN rounding for automatic ratios - 強制點: BE
covers-prd: FR-002

Owner decision P-013 closes the rounding decision: automatic ratio fields must use legacy `HALF_DOWN` semantics. Explicit division uses sufficient intermediate scale (minimum 10) with `RoundingMode.HALF_DOWN`; final display/storage is two decimals with the legacy `formatTwo`/HALF_DOWN behavior, preserving `N/A` where defined. Denominator-zero `N/A` cases include `GGL` previous `LOANS_DISCOUNTED=0`, `COST_INCOME` zero `CONTINUING_OP_INCOME_BT`, `LOANS_DEPOSITS` zero deposit denominator, ROA zero average `TOTAL_ASSETS`, and ROE zero average `TOTAL_STOCKHOLDER_EQUITY`.

Legacy 0120 uses `ROUND_HALF_DOWN` plus `formatTwo` in formula branches at `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:117@2ae96d0]`, `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:124@2ae96d0]`, `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:138@2ae96d0]`, `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:148@2ae96d0]`, `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:158@2ae96d0]`, and `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:164@2ae96d0]`. Current backend uses `RoundingMode.HALF_UP` helper paths at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:329@2ae96d0]`, `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:339@2ae96d0]`, `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:352@2ae96d0]`, and `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:355@2ae96d0]`; that is an RD conformance bug under owner policy 2.

## NFR
- Transaction: save/finish replacement and checkpoint update must commit or roll back together, and checkpoint update must affect exactly one row, per PRD transaction principle at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:589-595`.
- Security: mutating endpoint requires platform auth, `TB_API_AUTH` seed coverage, and service-level edit/role guard; seed-only authorization is insufficient.
- Audit: query/save actions must preserve safe audit trail behavior; legacy 0120 calls audit for query/save at `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:47@2ae96d0]`, `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:53@2ae96d0]`, `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:87@2ae96d0]`, and `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java:92@2ae96d0]`.
- Observability: logs must not print full request payloads with customer financial ratios; use bounded error context.

## Trade-offs
- Excluding `cetOneCapitalRatio` and `totalCapitalRatio` from OpenAPI keeps the SRS aligned to PRD/db-diff authority, while spec/schema still flag the current DTO/entity drift for RD/DBA release cleanup.
- Assigning parent progress to an independent endpoint keeps the EPROC00120 DTO aligned with current source and prevents cross-page status bloat in a row-save contract.

## DB Reconcile / Delta
| Delta | Source | Impact | Disposition |
|---|---|---|---|
| Target FI table is active/exact and string-stores ratio values. | `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:6-16`, `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:38-56` | R3-R5, schema.sql | Carried. |
| Source statement tables use numeric money fields and `PERIODS`. | `docs/db-diff/02_tables/TB_FIN_STATEMENT_BALANCE_FI.md:38-42`, `docs/db-diff/02_tables/TB_FIN_STATEMENT_INCOME_FI.md:38-41` | R2, R10-R11, R20 | Strict mismatch reject, PERIODS=0 -> `N/A`, HALF_DOWN rounding. |
| New checkpoint tables use `EPROC00120` columns for CS/CU. | `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:38-53`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:38-49` | R5, R19 | Carried; parent aggregation is independent endpoint. |
| Current DTO/entity contains two capital ratio fields absent from PRD/db-diff snapshot. | DTO evidence at `[CODE:backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/SaveCsuFinancialEvaluationTableFiRequest.java:102@2ae96d0]`; entity evidence at `[CODE:backend/src/main/java/khd/svc/epro/entity/TBFinancialEvaluationFiEntity.java:61@2ae96d0]`; DB snapshot at `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_FI.md:38-56` | R9 | Excluded from OpenAPI contract; RD/DBA conformance drift before release. |
| `EPROC00120` has no independent refactor-spec module. | Dispatch at `docs/build-tasks/prd-to-srs-codex-dispatch.md:79-80` | R18 | Code-as-baseline with legacy/current source and commit `2ae96d0`. |
| PRD/legacy parent-progress fields exceed current DTO/service evidence. | PRD at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:453-464`; current save DTO only has `applicationNo/isFinish/financialList` at `[CODE:backend/src/main/java/khd/svc/epro/dto/request/corporate/csuFinancialEvaluationTableFi/SaveCsuFinancialEvaluationTableFiRequest.java:17@2ae96d0]`; current save returns empty map at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:215@2ae96d0]` | R19 | Independent parent/checkpoint endpoint for parent aggregation; R1 still requires page-local `applicationName` and `checkpoint` on info. |

## To-Be Delta Register
| ID | Source defect / drift | Disposition | Rule impact | Evidence |
|---|---|---|---|---|
| REF-D1 | Source Balance/Income count or `DATA_SEQ` mismatch can otherwise lead to partial or unhandled calculation behavior. | fix | R2, R10 | Current code aligns income by `dataSeq` during calculation at `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:116@2ae96d0]`; PRD negative case is `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md:614`. |
| REF-D2 | Current helper can return blank for zero-average/period annualized cases; to-be requires `N/A` for `PERIODS=0`. | fix | R11 | Current helper evidence `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:344@2ae96d0]`; PRD/owner decision P-002. |
| REF-D3 | Current edit-mode behavior can return saved rows before date-aware recomputation; to-be preserves manual values only when `RATIOS_DATE` still matches. | fix | R13 | Current saved-row short path `[CODE:backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialEvaluationTableFiServiceImpl.java:85@2ae96d0]`; legacy ratio-date carryover evidence `[CODE:legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java:97@2ae96d0]`. |

## Money, Precision, Maxlength, and Truncation
Automatic ratio fields `growthOfGrossLoans`, `cost`, `roa`, `roe`, and `loans` use HALF_DOWN per R20. All `VARCHAR2(12)` stored ratio fields must reject overlength before DB write; no silent truncation is allowed.

| API field | DB/source column | Max/precision | Rule |
|---|---|---|---|
| `applicationNo` | `APPLICATION_NO` | 30 chars | Reject blank/overlength; no truncation. |
| `dataSeq` | `DATA_SEQ` | 2 chars | Preserve source order/key; reject mismatch per R10. |
| `ratiosDate` | `RATIOS_DATE` | 10 chars | Store/display date string per page contract; date-change behavior per R13. |
| `nplRatios` | `NPL` | 12 chars | Manual field; reject overlength before DB write. |
| `loanLossReserves` | `LLR` | 12 chars | Manual field; reject overlength before DB write. |
| `loanLossReserveOverNpl` | `LLR_OVER_NPL` | 12 chars | Manual field; reject overlength before DB write. |
| `growthOfGrossLoans` | `GGL` | 12 chars | First period or previous `LOANS_DISCOUNTED=0` -> `N/A`; HALF_DOWN per R20. |
| `aggregateLargeExposureRatio` | `AGREE_LARGE_EXPOSURE` | 12 chars | Required on Finished; reject overlength. |
| `creditExposureToSingleBeneficiary` | `CREDIT_EXPOSURE_TO_SB` | 12 chars | Required on Finished; reject overlength. |
| `relatedPartyExposure` | `RELATED_PARTY_EXPOSURE` | 12 chars | Required on Finished; reject overlength. |
| `unhedgedForeignCurrencyRatio` | `UNHEDGED_FOREIGN_CURR` | 12 chars | Required on Finished; reject overlength. |
| `netInterestMargin` | `NET_INTEREST_MARGIN` | 12 chars | Manual field; reject overlength. |
| `cost` | `COST_INCOME` | 12 chars | Legacy formula; denominator zero -> `N/A`; HALF_DOWN. |
| `roa` | `ROA` | 12 chars | First period, `PERIODS=0`, or zero average `TOTAL_ASSETS` -> `N/A`; HALF_DOWN. |
| `roe` | `ROE` | 12 chars | First period, `PERIODS=0`, or zero average `TOTAL_STOCKHOLDER_EQUITY` -> `N/A`; HALF_DOWN. |
| `loans` | `LOANS_DEPOSITS` | 12 chars | Denominator zero -> `N/A`; HALF_DOWN. |
| `liquidityCoverageRatio` | `LIQUIDITY_COVERAGE` | 12 chars | Required on Finished; reject overlength. |
| `solvencyRatio` | `SOLVENCY` | 12 chars | Required on Finished; reject overlength. |
| `tier1CapitalRatio` | `TIER_ONE_CAPITAL` | 12 chars | Manual field; not Finished-required by this SRS. |
| `cetOneCapitalRatio`, `totalCapitalRatio` | current entity maps `CET_ONE_CAPITAL` / `TOTAL_CAPITAL`, absent from PRD/db-diff | current DTO/entity drift | Excluded from OpenAPI contract; RD/DBA reconcile before release. |

## Decision Register
| ID | Decision | Source / Delta |
|---|---|---|
| P-001 | ✅ Closed: strict `DATA_SEQ`/count mismatch rejection; no partial calculation. | Owner 2026-06-24; R10; REF-D1. |
| P-002 | ✅ Closed: `PERIODS=0` annualized ROA/ROE renders `N/A`. | Owner 2026-06-24; R11; REF-D2. |
| P-003 | ✅ Closed: keep legacy `COST_INCOME` formula. | Owner 2026-06-24; R12. |
| P-004 | ✅ Closed: preserve manual values only for matching `RATIOS_DATE`; date changes require re-entry. | Owner 2026-06-24; R13; REF-D3. |
| P-005 | ✅ Closed: Save draft has minimal persistence validation; Finished BE enforces R5 required fields. | Owner 2026-06-24; R5, R14. |
| P-006 | ✅ Closed: RC old cases are Save-only; no Finished/callback done-state update. | Owner 2026-06-24; R15. |
| P-007 | ✅ Closed: use EPROC00120 function identity/label in migrated FE. | Owner 2026-06-24; R16. |
| P-008 | ✅ Closed: this bundle is C0-only; no I0 shared-table migration decision. | Owner 2026-06-24; R17. |
| P-009 | ✅ Closed: missing formal baseline handled by code-as-baseline plus parity verification at commit `2ae96d0`. | Owner policy 1; R18. |
| P-010 | ✅ Closed: `cetOneCapitalRatio`/`totalCapitalRatio` are excluded from the SRS OpenAPI contract; current DTO/entity exposure is RD/DBA conformance drift. | Owner-authorized self-resolution from current code/schema delta; R9. |
| P-011 | ✅ Closed: mutating save requires both `TB_API_AUTH` seed and service-level edit/role guard. | Owner policy 3; R8. |
| P-012 | ✅ Closed: parent progress/checkpoint aggregation belongs to independent endpoint; do not bloat EPROC00120 DTO. | Owner 2026-06-24; R19. |
| P-013 | ✅ Closed: automatic ratios use legacy HALF_DOWN rounding. | Owner 2026-06-24; R20. |

## Traceability Matrix
| PRD | Rules | QA |
|---|---|---|
| FR-001 | R1, R7, R18, R19 | QA dormant while QA generation is paused |
| FR-002 | R2, R3, R10, R11, R12, R13, R18, R20 | QA dormant while QA generation is paused |
| FR-003 | R3, R9, R13, R17, R18 | QA dormant while QA generation is paused |
| FR-004 | R4, R7, R8, R9, R14, R17, R18 | QA dormant while QA generation is paused |
| FR-005 | R5, R7, R8, R14, R18 | QA dormant while QA generation is paused |
| FR-006 | R5, R15, R18, R19 | QA dormant while QA generation is paused |
| FR-007 | R6, R18 | QA dormant while QA generation is paused |
| FR-008 | R1, R15, R16, R18, R19 | QA dormant while QA generation is paused |

## Hard Boundaries
- Do not use `EPROI00120` as C0 as-is evidence. It may only inform risk comparison because dispatch marks it as a nearby mirror, not a corporate baseline.
- Do not self-promote to Approved. This bundle is ready for owner finalization only after gate PASS and A-F review PASS.
- Do not add parent progress fields to the EPROC00120 save DTO unless owner reverses P-012; use the independent parent/checkpoint endpoint.
- Treat current HALF_UP rounding, missing auth rows/service guard, weak Finished validator, missing checkpoint affected-row enforcement, and capital-ratio DTO/entity drift as RD conformance work, not as unresolved SRS decisions.
