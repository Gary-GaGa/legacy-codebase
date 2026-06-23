# SRS - EPROC00117 Financial Evaluation GI

## Metadata
| Field | Value |
|---|---|
| FuncId | EPROC00117 |
| Status | In Review / draft-for-controller-gate; awaiting parity and human review |
| Owner | SA / Credit decision domain / RD |
| Upstream PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00117-v1.0.md` |
| As-is source | Legacy `EPROC0_0117` + `EPROC0_0217`; current corporate implementation and refactor artifacts listed below |
| Bundle files | `spec.md`, `openapi.yaml`, `schema.sql`, `qa-cases.md` |

## Scope
- In scope: C0 Financial Evaluation GI option/query/save contract, GI ratio generation, DSR/business financial list persistence, checkpoint update, CS/CU checkpoint table routing, DB/refactor reconcile, and parity risk registration.
- Out of scope: Financial Statement GI editing, Scorecard calculation, FI financial evaluation, report generation, staff-loan endpoints, implementation code changes, and approval to close parity.
- Contract endpoints are real POST RPC paths: `epl-sele-c0-financial-list`, `epl-info-c0-financial-business`, and `epl-save-c0-financial-business`. Legacy `initQuery`, `getTotal`, `getExist`, and `save` are evidence, not public to-be paths.

## Assumptions And Dependencies
- The page is T1 corporate credit-decision support because it persists ratios used downstream for evaluation and checkpoint gates. It may reach `In Review`; it must not be marked Approved until parity, authorization, and data-integrity pending items are closed.
- 00117 is business-only by prior decision, but the implementation class is still named `CsuFinancialStaffController/ServiceImpl`; SRS names the business contract and tracks the naming/table conflict as `RP35`.
- Existing decision "c0 pages self-contained, no i0 service injection" is carried from `docs/decisions.md:39`.
- The corporate parity reopen remains open at `docs/pending-register.md:26`; this bundle points to that row and adds page-level RP items.

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD | Legacy programs and scope at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00117-v1.0.md:9-18`, `:39-45`; open PRD issues at `:52-62`; endpoints at `:149-201`; data model at `:205+`. | Non-pending behavior becomes R1-R8; every PRD open issue is registered as RP26-RP38. |
| Refactor spec | Module index lists `epl-info-c0-financial-business` and `epl-save-c0-financial-business` as latest artifacts; query artifact defines `applicationNo`/`isQuery` and ratio response fields at `docs/refactor-spec/03_artifacts/be-corporate/EPROC00117/epl-info-c0-financial-business.md:76-111`, endpoint POST at `:136-138`, and computed/stored branch at `:201-214`; save artifact defines `isFinish`, transactional write, delete/insert sequence, and checkpoint update at `epl-save-c0-financial-business.md:76`, `:162-174`, `:183-206`. | Refactor spec grounds request/response shape for info/save. `getTotal/getExist` remain legacy-only unless owner approves compatibility. |
| Current backend | `CsuFinancialStaffController` exposes `epl-sele-c0-financial-list` at `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStaffController.java:29`, save at `:36`, and info at `:43`; service wraps save in transaction at `CsuFinancialStaffServiceImpl.java:83-91`, info at `:95-174`, full replacement at `:181-240`, checkpoint update at `:709-727`. | Current backend is implementation evidence, not final approval. |
| Current frontend | FE calls `epl-info-c0-financial-business` and `epl-save-c0-financial-business` at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-evaluation-gi/services/api.service.ts:45`, `:60`. | Confirms current route usage. |
| Legacy parity task | 00117 maps to `EPROC0_0117` and requires business-only parity follow-up at `docs/build-tasks/c0-legacy-parity-recheck.md:39`; c0 parity scope says compare against old corporate, not i0, at `:12`, `:48-55`. | As-is remains "待 parity 碼驗 / 待 RD 核對" where source is not directly reconciled. |
| DB snapshot | `TB_FINANCIAL_EVALUATION_GI` is active/exact with 33 columns and PK `APPLICATION_NO, DATA_SEQ` at `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_GI.md:13-16`, `:25-33`; `TB_FINANCIAL_EVALUATION_INFO_CORP` is active accepted_alias at `TB_FINANCIAL_EVALUATION_INFO_CORP.md:13-16`; checkpoint columns `EPROC00117` exist in both CS and CU at `TB_CHECK_POINTS_CS.md:34-47`, `TB_CHECK_POINTS_CU.md:34-44`. | `schema.sql` uses new snapshot names and records current entity alias conflict. |

## Endpoints
| Endpoint | Method | Purpose | Source |
|---|---|---|---|
| `/epl-sele-c0-financial-list` | POST | Return option data such as currency list for the page. | Controller `CsuFinancialStaffController.java:29`; feature inventory `docs/feature-inventory.md:104`. |
| `/epl-info-c0-financial-business` | POST | Query current financial list and GI ratios; current service computes from complete GI statement sources first and writes generated GI ratio rows, then falls back to persisted ratios only when source rows are unavailable and `isQuery=true`. | Refactor info artifact `:136-214`; controller `:43`; service `:95-174`. |
| `/epl-save-c0-financial-business` | POST | Save draft or Finished business financial list and aggregate DSR fields, then update checkpoint atomically. | Refactor save artifact `:134-174`; controller `:36`; service `:83-91`, `:181-240`, `:709-727`. |

## Rules

### R1 Load option and current-case context - 強制點: both - covers-prd: PRD §5.1/§5.3
When the EPROC00117 page is opened, the client shall call the option endpoint and the info endpoint with a server-recognized `applicationNo` and `isQuery`. The backend shall reject missing `applicationNo` or `isQuery` with controlled EPRO validation errors, and shall return the borrower/business financial list plus GI ratios in the EPRO envelope.

As-is: legacy `initQuery` loaded ccyMap and then either persisted or computed GI ratio data. To-be: the page uses `epl-sele-c0-financial-list` and `epl-info-c0-financial-business`; compatibility for legacy `getTotal/getExist` is not assumed and is tracked by `RP26` and `RP34`.

### R2 Select stored versus computed ratios by query mode - 強制點: BE - covers-prd: PRD §6.1/§6.2
When complete GI source rows exist, the backend shall compute ratios from `TB_FIN_STATEMENT_BALANCE_GI`, `TB_FIN_STATEMENT_INCOME_GI`, and `TB_FIN_STATEMENT_CASHFLOW_GI`, and shall write the generated rows back to `TB_FINANCIAL_EVALUATION_GI` before returning them regardless of `isQuery`. When source rows are unavailable and `isQuery=true`, the backend shall read persisted GI ratio rows from `TB_FINANCIAL_EVALUATION_GI`. If any required GI source list is missing and no persisted fallback is applicable, the backend shall return an empty `ratios` array instead of null and shall not perform a partial ratio write.

As-is/current implementation: complete source rows take precedence over persisted rows, while the PRD/refactor query-mode intent still needs owner confirmation. To-be for this bundle keeps the current contract in review; empty array is the contract; count and `DATA_SEQ` validation is required before treating computed ratios as complete, but exact parity remains `RP27` and `RP29`.

### R3 Calculate GI ratios and DSR with explicit formatting - 強制點: BE - covers-prd: PRD §6.3/§7
When GI source rows are available, the backend shall calculate liquidity, leverage, turnover, margin, return, cashflow, and growth ratios per the PRD formula set, and shall return display strings with `%`, `x`, `N/A`, or `-` suffixes as applicable. Ratio values persisted to `TB_FINANCIAL_EVALUATION_GI` shall fit the `VARCHAR2(12)` snapshot columns.

As-is discrepancy: refactor spec states `ROUND_HALF_DOWN`, while current implementation uses `RoundingMode.HALF_UP` at `CsuFinancialStaffServiceImpl.java:706` and turnover helpers at `:578-604`. This is not silently normalized; exact rounding and legacy defect handling are pending under `RP28`, `RP30`, and `RP36`.

### R4 Maintain business financial list and DSR data - 強制點: both - covers-prd: PRD §5.2/§7
When the page displays DSR/business financial items, the system shall carry borrower name, borrower combine id, main-borrower flag, `DATA_SEQ`, income, expense, debit balance, `mExistInstallmentAmt`, `mEstInstallmentAmt`, `monExpenditureRatio`, `debtServiceRatio`, `totalDebtRatio`, `totalRemainingCashRatio`, and `debtToNetIncomeRatio`. Currency behavior shall not depend on client-side disabled controls as the source of truth.

When the user deletes DSR/business financial items, the client shall prevent deleting the final remaining item and show `COMMON_MSG_ONE_DATA`; the backend shall reject an empty `financialList` on save.

As-is: PRD notes the legacy UI effectively fixed DSR currency to USD while still loading `ccyMap`. To-be: backend and product owner must confirm currency policy before Approved; this remains `RP32`.

### R5 Save draft or Finished as full replacement in one transaction - 強制點: BE - covers-prd: PRD §6.4/NFR
When the user saves EPROC00117, the backend shall validate `applicationNo` and `isFinish`, load the case summary, delete existing business financial rows for that case, insert the submitted `financialList` and aggregate DSR fields, and update the active checkpoint in one transaction. Blank `applicationNo` on save shall return `COMMON_MSG_ERROR_LON` and shall not write data. Any failure after delete shall roll back the prior persisted state. The save request shall not accept client-submitted GI ratio rows; ratio persistence is owned by the info compute branch in R2.

To-be: the backend is authoritative for `applicationNo`, `DATA_SEQ`, and checkpoint state. Client-supplied detail keys are not trusted as authority. Current implementation partially rewrites parent `applicationNo` but page-specific key/entity parity remains `RP31` and `RP35`.

### R6 Route checkpoint writes by CS/CU case type - 強制點: BE - covers-prd: PRD §6.4
When save succeeds, the backend shall derive the checkpoint table from `LON_ATTRIBUTE + SECURE_ATTRIBUTE`: CS writes `TB_CHECK_POINTS_CS.EPROC00117`; CU writes `TB_CHECK_POINTS_CU.EPROC00117`. Draft save shall write unfinished state `"Y"` and Finished shall write completed state `"N"` to match the current corporate checkpoint convention.

As-is: legacy c0 used `EPROC0_0117` and `EPROC0_0217` keys. New DB snapshot uses unified `EPROC00117` columns in CS/CU tables. This is a DB-structure difference; schema stays new, behavior must preserve completion polarity.

### R7 Enforce backend validation, authorization, and audit boundary - 強制點: BE - covers-prd: PRD §8/NFR
For every info/save request, the backend shall enforce platform authentication, page authorization, application access, required fields, numeric/date formats, and service-level edit authority before mutation, including the R2 info compute/write-back path. Missing or invalid inputs shall return controlled EPRO errors such as `E102`, `FAILED_E116`, `FAILED_E126`, `COMMON_MSG_ERROR_LON`, `COMMON_MSG_TOTAL_FAIL`, `COMMON_MSG_LIMIT`, `COMMON_MSG_ONE_DATA`, or `COMMON_MSG_SAVE_FAIL` as applicable.

FE validation may improve UX, but it is not authoritative for monetary/calculation/checkpoint integrity. Service-level authorization proof remains open under `RP37`.

### R8 Preserve known parity constraints without self-approving them - 強制點: both - covers-prd: PRD §2/§10
When generating or reviewing implementation work from this SRS, teams shall treat old corporate `EPROC0_0117` and `EPROC0_0217` as the parity target, not i0/ISU behavior. Prior c0 business-only decision B is carried as a constraint, but unresolved action naming, old-case behavior, item limits, and formula defects stay open until RD parity evidence is attached.

This rule intentionally keeps the bundle in `In Review`. It does not close `docs/pending-register.md:26`.

## NFR
| ID | Requirement | Rule |
|---|---|---|
| NF001 | Save must be transactional; delete/insert/checkpoint failures roll back together. | R5 |
| NF002 | Ratio output must be deterministic and must document rounding mode and suffix behavior. | R3 |
| NF003 | Detail list counts and `DATA_SEQ` alignment must be checked server-side before computed ratios are trusted. | R2 |
| NF004 | Payload keys and checkpoint decisions are backend-owned. | R5-R7 |
| NF005 | No i0/ISU behavior may be promoted to corporate as-is without old c0 parity evidence. | R8 |

## Trade-offs
| Topic | Decision | Rationale |
|---|---|---|
| Legacy action compatibility | Keep new RPC endpoints only; legacy `getTotal/getExist` compatibility is pending. | Refactor spec only formalizes `info/save`, and current FE calls the new RPCs. |
| DB table conflict | Use new db-diff snapshot for `TB_FINANCIAL_EVALUATION_INFO_CORP`, but record current entity `TB_FINANCIAL_EVALUATION_INFO` conflict. | Schema snapshot is DB authority; implementation must be reconciled without silently changing SRS. |
| Rounding mode | Do not choose between `ROUND_HALF_DOWN`, legacy, and current `HALF_UP` in SRS. | This affects financial ratios; needs RD/SA parity proof. |

## New/Old DB Reconcile And Delta
| ID | Table / Field | Source | Three-way tag | SRS disposition |
|---|---|---|---|---|
| DB-D1 | `TB_FINANCIAL_EVALUATION_GI` active/exact; PK `APPLICATION_NO, DATA_SEQ`; ratio columns `VARCHAR2(12)`. | `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_GI.md:13-33` | (c) DB structure as new | Use in `schema.sql`; code must fit persisted string widths. |
| DB-D2 | `TB_FINANCIAL_EVALUATION_INFO_CORP` active accepted_alias, but current entity maps `TB_FINANCIAL_EVALUATION_INFO`. | `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_INFO_CORP.md:13-16`; `TBFinancialEvaluationInfoEntity.java:10` | pending parity/schema alias | Register `RP35`; do not assume old/new table alias is harmless. |
| DB-D3 | New checkpoint columns are `TB_CHECK_POINTS_CS.EPROC00117` and `TB_CHECK_POINTS_CU.EPROC00117`; legacy keys were `EPROC0_0117/0217`. | `TB_CHECK_POINTS_CS.md:34-47`; `TB_CHECK_POINTS_CU.md:34-44`; PRD `:94-102` | (c) DB structure as new | To-be uses unified columns and preserves polarity. |
| DB-D4 | Source ratio rows come from GI statement tables; current info compute branch writes generated rows to `TB_FINANCIAL_EVALUATION_GI`. | PRD `:82-92`; service `CsuFinancialStaffServiceImpl.java:143-174` | (a) regression if list alignment omitted | R2 requires backend count/`DATA_SEQ` guard and no partial write; open in `RP29`. |
| REF-D1 | Refactor artifact exposes info/save only; current controller also has select. | `EPROC00117.md` latest map; `CsuFinancialStaffController.java:29-44` | intended evolution / incomplete artifact | Include select as current real endpoint; keep getTotal/getExist pending. |

## @PENDING
| ID | Status | Owner | Blocking For | Required closure |
|---|---|---|---|---|
| RP26 | open | SA/RD | R1/R8 | Decide whether legacy `getTotal` / inventory `getRate` / new `info` contract needs compatibility alias. |
| RP27 | open | PM/SA/RD | R2 | Confirm whether current source-first compute/write-back regardless of `isQuery` is intended, or whether query mode must prefer persisted historical ratios. |
| RP28 | open | SA/RD/QA | R2/R3 | Define and implement GI Balance/Income/Cashflow list count and `DATA_SEQ` alignment validation. |
| RP29 | open | SA/RD | R3 | Decide AP turnover zero defect: fix `DAYS_FOR_AP` versus preserve legacy `NUM_OF_DAYS_FOR_INVENTORY` side effect. |
| RP30 | open | SA/RD | R2 | Confirm empty-array behavior when persisted GI ratios are missing, and remove null-list exposure. |
| RP31 | open | Security/RD | R5/R7 | Prove backend overwrites detail `APPLICATION_NO`/`DATA_SEQ` authority and rejects payload tampering. |
| RP32 | open | PM/SA | R4 | Confirm DSR currency policy: fixed USD or multi-currency with exchange-rate rules. |
| RP33 | open | SA/RD | R4/R5 | Confirm page item limit replacing legacy `top.corSize`. |
| RP34 | open | SA/RD | R1/R8 | Decide whether unused legacy `getExist` must remain as compatibility API. |
| RP35 | open | SA/RD/DBA | R5/DB-D2 | Reconcile `TB_FINANCIAL_EVALUATION_INFO_CORP` snapshot with current `TB_FINANCIAL_EVALUATION_INFO` entity/table usage. |
| RP36 | open | SA/Finance/RD | R3 | Decide revenue/net-profit growth annualization basis and rounding mode. |
| RP37 | open | Security/RD/DBA | R7 | Provide service-level authorization and audit proof for info/save; DB seed alone is insufficient. |
| RP38 | open | PM/SA/RD | R5/R6/R8 | Close PRD `TBD-010`: confirm 0217 RC old-case save/Finished operability, parent done update, and status/checkpoint behavior. |

## Traceability Matrix
| PRD area | Rules | QA |
|---|---|---|
| Page load / initQuery | R1, R2 | QA-001, QA-002, QA-003 |
| GI ratio calculation | R2, R3 | QA-004, QA-005, QA-006 |
| DSR/business financial list | R4 | QA-007, QA-008, QA-015 |
| Save / Finished / transaction | R5, R6 | QA-009, QA-010, QA-011, QA-016 |
| Validation/security | R7 | QA-012, QA-013 |
| Legacy parity and deltas | R8 | QA-014 |
| Open PRD issues | R1-R8, RP26-RP38 | QA-P01 through QA-P13 |

## Hard Boundaries And As-Is/To-Be Summary
- As-is used old c0 actions and keys: `EPROC0_0117`, `EPROC0_0217`, `initQuery`, `getTotal`, `getExist`, `save`, and legacy checkpoint fields.
- To-be uses POST RPC `epl-*` endpoints, new `TB_CHECK_POINTS_CS/CU.EPROC00117`, backend-owned save/checkpoint authority, info-branch GI ratio write-back, and db-diff snapshot table definitions.
- Anything not verified against old corporate c0 code is marked "待 parity 碼驗 / 待 RD 核對" and remains in @PENDING.
