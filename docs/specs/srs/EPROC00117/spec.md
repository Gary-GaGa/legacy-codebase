# SRS - EPROC00117 Financial Evaluation GI

## Metadata
| Field | Value |
|---|---|
| FuncId | EPROC00117 |
| Status | In Review / draft-for-controller-gate; awaiting parity and human review |
| N-axis review | spec-reviewer (axis A) 2026-06-23: mechanical gate PASS; 1🔴 + 5🟡. 🔴 = `MSG_QUERY_FAIL` declared in openapi errors but no Rn/QA carries it. (A prior schema.sql corruption 🔴 — qa-cases content prepended to the file — was fixed in commit d4326d7.) 🔴 fixed + re-review PASS 2026-06-23: `MSG_QUERY_FAIL` carried in R1 + new QA-017 + traceability matrix; re-review tightening applied same day (QA-017 now drives both option+info endpoints with simulated fault wording; R5 cross-refs SAVE-006 split). RP26-RP38 closed 2026-06-24; remains In Review pending bundle gate, axis A review, and owner approval. |
| Owner | SA / Credit decision domain / RD |
| Upstream PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00117-v1.0.md` |
| As-is source | Legacy `EPROC0_0117` + `EPROC0_0217`; current corporate implementation and refactor artifacts listed below |
| Bundle files | `spec.md`, `openapi.yaml`, `schema.sql`（`qa-cases.md` 2026-06-24 隨 QA 暫拔除） |

## Scope
- In scope: C0 Financial Evaluation GI option/query/save contract, GI ratio generation, DSR/business financial list persistence, checkpoint update, CS/CU checkpoint table routing, DB/refactor reconcile, and parity risk registration.
- Out of scope: Financial Statement GI editing, Scorecard calculation, FI financial evaluation, report generation, staff-loan endpoints, implementation code changes, and approval to close parity.
- Contract endpoints are real POST RPC paths: `epl-sele-c0-financial-list`, `epl-info-c0-financial-business`, and `epl-save-c0-financial-business`. Legacy `initQuery`, `getTotal`, `getExist`, and `save` are evidence, not public to-be paths.

## Assumptions And Dependencies
- The page is T1 corporate credit-decision support because it persists ratios used downstream for evaluation and checkpoint gates. It may reach `In Review`; it must not be marked Approved until parity, authorization, and data-integrity pending items are closed.
- 00117 is business-only by prior decision, but the implementation class is still named `CsuFinancialStaffController/ServiceImpl`; SRS names the business contract and RP35 closes the table fact: `TB_FINANCIAL_EVALUATION_INFO` and `TB_FINANCIAL_EVALUATION_INFO_CORP` are distinct active tables, not a harmless alias.
- Existing decision "c0 pages self-contained, no i0 service injection" is carried from `docs/decisions.md:39`.
- The corporate parity reopen remains open at `docs/pending-register.md:26`; this bundle points to that row and adds page-level RP items.

## Source Evidence
| Area | Evidence | SRS disposition |
|---|---|---|
| PRD | Legacy programs and scope at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00117-v1.0.md:9-18`, `:39-45`; open PRD issues at `:52-62`; endpoints at `:149-201`; data model at `:205+`. | Non-pending behavior becomes R1-R8; every PRD open issue is registered as RP26-RP38. |
| Refactor spec | Module index lists `epl-info-c0-financial-business` and `epl-save-c0-financial-business` as latest artifacts; query artifact defines `applicationNo`/`isQuery` and ratio response fields at `docs/refactor-spec/03_artifacts/be-corporate/EPROC00117/epl-info-c0-financial-business.md:76-111`, endpoint POST at `:136-138`, and computed/stored branch at `:201-214`; save artifact defines `isFinish`, transactional write, delete/insert sequence, and checkpoint update at `epl-save-c0-financial-business.md:76`, `:162-174`, `:183-206`. | Refactor spec grounds request/response shape for info/save. `getTotal`/inventory `getRate` are legacy/stale names and must not become public aliases; `getExist` remains under RP34. |
| Current backend | `CsuFinancialStaffController` exposes `epl-sele-c0-financial-list` at `backend/src/main/java/khd/svc/epro/controller/corporate/CsuFinancialStaffController.java:29`, save at `:36`, and info at `:43`; service wraps save in transaction at `CsuFinancialStaffServiceImpl.java:83-91`, info at `:95-174`, full replacement at `:181-240`, checkpoint update at `:709-727`. | Current backend is implementation evidence, not final approval. |
| Current frontend | FE calls `epl-info-c0-financial-business` and `epl-save-c0-financial-business` at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/financial-evaluation-gi/services/api.service.ts:45`, `:60`. | Confirms current route usage. |
| Legacy parity task | 00117 maps to `EPROC0_0117` and requires business-only parity follow-up at `docs/build-tasks/c0-legacy-parity-recheck.md:39`; c0 parity scope says compare against old corporate, not i0, at `:12`, `:48-55`. | As-is remains "待 parity 碼驗 / 待 RD 核對" where source is not directly reconciled. |
| DB snapshot | `TB_FINANCIAL_EVALUATION_GI` is active/exact with 33 columns and PK `APPLICATION_NO, DATA_SEQ` at `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_GI.md:13-16`, `:25-33`; `TB_FINANCIAL_EVALUATION_INFO` is active/exact with 24 columns and PK `APPLICATION_NO, APPLICANT_NAME, DATA_SEQ` at `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_INFO.md:13-16`, `:25-34`; `TB_FINANCIAL_EVALUATION_INFO_CORP` is active accepted_alias with 14 columns and PK `APPLICATION_NO, DATA_SEQ` at `TB_FINANCIAL_EVALUATION_INFO_CORP.md:13-16`, `:25-33`; latest reverify confirms both INFO tables at `legacy_schema_reverify_new02_columns.tsv:1091-1128` and PKs at `legacy_schema_reverify_new02_pk.tsv:146-150`; checkpoint columns `EPROC00117` exist in both CS and CU at `TB_CHECK_POINTS_CS.md:34-47`, `TB_CHECK_POINTS_CU.md:34-44`. | RP35 closes this as distinct active tables; `schema.sql` carries both INFO structures and the current implementation must reconcile table choice in code stage. |

## Endpoints
| Endpoint | Method | Purpose | Source |
|---|---|---|---|
| `/epl-sele-c0-financial-list` | POST | Return option data such as currency list for the page. | Controller `CsuFinancialStaffController.java:29`; feature inventory `docs/feature-inventory.md:104`. |
| `/epl-info-c0-financial-business` | POST | Query current financial list and GI ratios; current service computes from complete GI statement sources first and writes generated GI ratio rows, then falls back to persisted ratios only when source rows are unavailable and `isQuery=true`. | Refactor info artifact `:136-214`; controller `:43`; service `:95-174`. |
| `/epl-save-c0-financial-business` | POST | Save draft or Finished business financial list and aggregate DSR fields, then update checkpoint atomically. | Refactor save artifact `:134-174`; controller `:36`; service `:83-91`, `:181-240`, `:709-727`. |

## Rules

### R1 Load option and current-case context - 強制點: both - covers-prd: PRD §5.1/§5.3
When the EPROC00117 page is opened, the client shall call the option endpoint and the info endpoint with a server-recognized `applicationNo` and `isQuery`. The backend shall reject missing `applicationNo` or `isQuery` with controlled EPRO validation errors, and shall return the borrower/business financial list plus GI ratios in the EPRO envelope. A query/data-access failure during option or info retrieval shall surface as `MSG_QUERY_FAIL` in the EPRO envelope without performing any partial ratio write.

As-is: legacy `initQuery` loaded ccyMap and then either persisted or computed GI ratio data. Legacy `getTotal` calculated DSR while the method name was `doGetRate`, inventory used stale `getRate` wording, and legacy `getExist` existed as a shared-module action that this page's JS did not call. To-be: the public page contract uses only `epl-sele-c0-financial-list`, `epl-info-c0-financial-business`, and `epl-save-c0-financial-business`; `getTotal`, inventory `getRate`, and unused legacy `getExist` must not be exposed as compatibility aliases.

### R2 Select stored versus computed ratios by query mode - 強制點: BE - covers-prd: PRD §6.1/§6.2
When `isQuery=true`, the backend shall read persisted GI ratio rows from `TB_FINANCIAL_EVALUATION_GI` ordered by persisted ratio date/data sequence and shall not recompute from GI source statement rows or write generated ratio rows as a side effect of query mode. When `isQuery=false`, the backend shall compute ratios from complete `TB_FIN_STATEMENT_BALANCE_GI`, `TB_FIN_STATEMENT_INCOME_GI`, and `TB_FIN_STATEMENT_CASHFLOW_GI` source rows, and shall write the generated rows back to `TB_FINANCIAL_EVALUATION_GI` before returning them. If any required source or persisted list is missing and no applicable branch can produce ratios, the backend shall return an empty `ratios` array instead of null and shall not perform a partial ratio write.

Owner decision 2026-06-24 for RP27: query mode preserves historical persisted ratios, and edit mode recomputes from source rows. Current backend source-first write-back for `isQuery=true` is a code-stage correction item, not the SRS contract. RP30 closes null-list exposure: `ratios` must be a non-null array in every successful response, and a no-data branch must return `[]` or a controlled no-data/error envelope, never Java/null JSON list exposure. RP28 closes the computed-ratio guard: before any edit-mode computation/write-back, Balance/Income/Cashflow source lists must be non-empty, have equal counts, contain unique non-null `DATA_SEQ` values, expose identical `DATA_SEQ` sets, and be paired by `DATA_SEQ` rather than by unchecked list index. Validation failure shall return a controlled EPRO error such as `COMMON_MSG_TOTAL_FAIL` or a field validation envelope, and shall not partially compute or write ratio rows. Implementation and automated tests are code-stage DoD, pending RD.

### R3 Calculate GI ratios and DSR with explicit formatting - 強制點: BE - covers-prd: PRD §6.3/§7
When GI source rows are available, the backend shall calculate liquidity, leverage, turnover, margin, return, cashflow, and growth ratios per the PRD formula set, and shall return display strings with `%`, `x`, `N/A`, or `-` suffixes as applicable. Ratio values persisted to `TB_FINANCIAL_EVALUATION_GI` shall fit the `VARCHAR2(12)` snapshot columns.

As-is discrepancy: refactor spec states `ROUND_HALF_DOWN`, while current implementation uses `RoundingMode.HALF_UP` at `CsuFinancialStaffServiceImpl.java:706` and turnover helpers at `:578-604`. RP36 closes formula policy: ratio and growth calculations shall follow the PRD/legacy `ROUND_HALF_DOWN` basis, and Revenue Growth / Net Profit Growth shall keep the legacy comparison of current annualized value against the prior-period raw value rather than annualizing both periods. RP29 closes the AP-turnover legacy defect: when `AP_TURNOVER = 0`, the system shall set `DAYS_FOR_AP = N/A`, set `CASH_CONVERSION_CYCLE = N/A`, and shall not overwrite `NUM_OF_DAYS_FOR_INVENTORY` from the AP-days branch.

### R4 Maintain business financial list and DSR data - 強制點: both - covers-prd: PRD §5.2/§7
When the page displays DSR/business financial items, the system shall carry borrower name, borrower combine id, main-borrower flag, `DATA_SEQ`, income, expense, debit balance, `mExistInstallmentAmt`, `mEstInstallmentAmt`, `monExpenditureRatio`, `debtServiceRatio`, `totalDebtRatio`, `totalRemainingCashRatio`, and `debtToNetIncomeRatio`. RP32 closes currency policy: all DSR/business financial amount fields in this page are USD-only; the UI may display disabled USD currency, but backend save/info must enforce USD semantics and must reject or normalize any client attempt to submit a non-USD DSR item currency before persistence. No exchange-rate conversion, multi-currency storage, or editable `DSR_CURRENCY` behavior is part of this bundle.

When the user adds DSR/business financial items, the page shall allow at most five items. FE shall block adding the sixth item with `COMMON_MSG_LIMIT`, and BE shall reject save payloads with more than five `financialList` rows before mutation. When the user deletes DSR/business financial items, the client shall prevent deleting the final remaining item and show `COMMON_MSG_ONE_DATA`; the backend shall reject an empty `financialList` on save.

As-is: PRD notes the legacy UI effectively fixed DSR currency to USD while still loading `ccyMap`. Owner decision 2026-06-24 for RP32 keeps this page USD-only; loaded CCY/common options are not a multi-currency contract for DSR.

### R5 Save draft or Finished as full replacement in one transaction - 強制點: BE - covers-prd: PRD §6.4/NFR
When the user saves EPROC00117, the backend shall validate `applicationNo` and `isFinish`, load the case summary, delete existing business financial rows for that case, insert the submitted `financialList` and aggregate DSR fields, and update the active checkpoint in one transaction. Blank `applicationNo` on save shall return `COMMON_MSG_ERROR_LON` and shall not write data. Any failure after delete shall roll back the prior persisted state. The save request shall not accept client-submitted GI ratio rows; ratio persistence is owned by the info compute branch in R2. Per PRD SAVE-006, transaction failure shall roll back and return `COMMON_MSG_SAVE_FAIL`; SAVE-006's query-failure half (`MSG_QUERY_FAIL`) is carried on the read path by R1.

To-be: the backend is authoritative for `applicationNo`, `DATA_SEQ`, and checkpoint state. RP31 closes save detail-key authority: persisted detail `APPLICATION_NO` must always come from the server-recognized request/case scope, not from any client-supplied detail value; `financialList` rows must have unique, non-null, positive/allowed `DATA_SEQ` values within the request; duplicate, missing, negative, out-of-range, or cross-case/tampered detail keys must be rejected before delete/insert mutation with a controlled EPRO validation/security error. Implementation and automated tamper tests are code-stage DoD, pending RD. Current implementation uses request `applicationNo` when building entity IDs, but the SRS also requires explicit tamper rejection and `DATA_SEQ` validation. RP35 closes the table fact: `TB_FINANCIAL_EVALUATION_INFO` and `TB_FINANCIAL_EVALUATION_INFO_CORP` are both active and structurally different; implementation must deliberately reconcile current `TB_FINANCIAL_EVALUATION_INFO` entity usage with PRD/refactor corporate `TB_FINANCIAL_EVALUATION_INFO_CORP` evidence, and may not treat the names as interchangeable aliases.

RP38 closes the 0217 RC old-case behavior: when the case is identified as a legacy RC old case equivalent to `attrMap.isOld=true`, the migrated page shall allow draft Save only and shall not expose Finished. The backend must also reject direct old-case Finished attempts (`isFinish=true`) before mutation/checkpoint update with a controlled EPRO validation/security error. Old-case draft Save may persist the draft replacement data, but it shall not update parent done state and shall not mark the active checkpoint completed.

### R6 Route checkpoint writes by CS/CU case type - 強制點: BE - covers-prd: PRD §6.4
When save succeeds, the backend shall derive the checkpoint table from `LON_ATTRIBUTE + SECURE_ATTRIBUTE`: CS writes `TB_CHECK_POINTS_CS.EPROC00117`; CU writes `TB_CHECK_POINTS_CU.EPROC00117`. Draft save shall write unfinished state `"Y"` and Finished shall write completed state `"N"` to match the current corporate checkpoint convention.

As-is: legacy c0 used `EPROC0_0117` and `EPROC0_0217` keys. New DB snapshot uses unified `EPROC00117` columns in CS/CU tables. This is a DB-structure difference; schema stays new, behavior must preserve completion polarity. For RC old cases, legacy `EPROC0_0217` hid Finished and suppressed parent done update; to-be preserves that behavior and requires backend enforcement so direct API calls cannot complete old cases.

### R7 Enforce backend validation, authorization, and audit boundary - 強制點: BE - covers-prd: PRD §8/NFR
For every info/save request, the backend shall enforce platform authentication, page authorization, application access, required fields, numeric/date formats, and service-level edit authority before mutation, including the R2 info compute/write-back path. Missing or invalid inputs shall return controlled EPRO errors such as `E102`, `FAILED_E116`, `FAILED_E126`, `COMMON_MSG_ERROR_LON`, `COMMON_MSG_TOTAL_FAIL`, `COMMON_MSG_LIMIT`, `COMMON_MSG_ONE_DATA`, or `COMMON_MSG_SAVE_FAIL` as applicable.

FE validation may improve UX, but it is not authoritative for monetary/calculation/checkpoint integrity.

To-be: endpoint authorization and service-level case/page authorization are mandatory. `epl-sele-c0-financial-list` and `epl-info-c0-financial-business` require read access to the case/page scope; `epl-save-c0-financial-business` and any `epl-info-c0-financial-business` compute/write-back branch require edit/write access before mutation. Authorization or audit-boundary failure shall return the platform `E401`/`E405`/`E498` or `AuthError` envelope and shall not write business financial rows, GI ratio rows, or checkpoints. Controller-level logging exists as current evidence, but endpoint seed application, service guard implementation, audit verification, and automated negative tests are code-stage DoD, pending RD/Security/DBA.

### R8 Preserve known parity constraints without self-approving them - 強制點: both - covers-prd: PRD §2/§10
When generating or reviewing implementation work from this SRS, teams shall treat old corporate `EPROC0_0117` and `EPROC0_0217` as the parity target, not i0/ISU behavior. Prior c0 business-only decision B is carried as a constraint. The `getTotal`/inventory `getRate` naming conflict is closed as `EPL_ONLY_NO_GETTOTAL_GETRATE_ALIAS`; unused legacy `getExist` is closed as `NO_GETEXIST_COMPAT_API`; DB table distinction is closed as `INFO_AND_INFO_CORP_DISTINCT_TABLES`; service authorization is closed as `SERVICE_LEVEL_AUTH_AUDIT_REQUIRED`; growth/rounding is closed as `LEGACY_GROWTH_BASIS_ROUND_HALF_DOWN`; RC old-case behavior is closed as `KEEP_0217_OLD_CASE_SAVE_ONLY_NO_FINISH_DONE_UPDATE`.

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
| Legacy action compatibility | Keep new RPC endpoints only; legacy `getTotal`, inventory `getRate`, and unused legacy `getExist` are evidence/stale or non-called actions, not public aliases. | Refactor spec only formalizes `info/save`, current backend/FE calls the `epl-*` RPCs, PRD says `getExist` is not called by this page JS, and owner decisions on 2026-06-24 selected no compatibility aliases. |
| Query-mode ratio source | `isQuery=true` returns persisted GI ratios without recompute/write-back; `isQuery=false` recomputes complete GI source rows and writes generated ratios. | This follows legacy/PRD query semantics and avoids query-mode mutation. Current source-first behavior is a code-stage correction item. |
| AP turnover zero defect | Fix the legacy AP-days bug: `AP_TURNOVER = 0` drives `DAYS_FOR_AP = N/A` and `CASH_CONVERSION_CYCLE = N/A`; it must not overwrite inventory days. | PRD marks this as a legacy defect suspect and owner accepted the fix on 2026-06-24. Current backend already follows the AP-days direction. |
| Ratio no-data response | Return non-null `ratios` array (`[]` for no applicable data) or a controlled no-data/error envelope; never expose null list. | PRD flags legacy null-list exposure as a defect suspect and recommends empty array/no-data handling. |
| Save detail-key authority | Request/case `applicationNo` is authoritative for every persisted detail row; `DATA_SEQ` must be unique and valid in the request; tampered detail keys are rejected before mutation. | PRD TBD-006 and data-integrity notes forbid trusting client detail keys; current code already derives persisted applicationNo from the request, but tests must prove rejection rather than silent acceptance. |
| DSR item limit | Maximum five DSR/business financial items per request/case; FE and BE both enforce the limit. | Legacy used global `top.corSize` without local definition; owner accepted explicit cap 5 on 2026-06-24. |
| DSR currency | DSR/business financial item amounts are USD-only for this bundle; no editable multi-currency or exchange-rate conversion is introduced. | PRD/current UI fixed disabled USD and `DSR_CURRENCY` is not a usable policy input; owner accepted fixed USD on 2026-06-24. |
| DB table fact | Carry both `TB_FINANCIAL_EVALUATION_INFO` and `TB_FINANCIAL_EVALUATION_INFO_CORP` as distinct active tables; they are not aliases. | db-diff and latest reverify show different column sets and PKs; current code maps INFO while PRD/refactor corporate evidence names INFO_CORP. Implementation must reconcile deliberately. |
| Rounding and growth | Use PRD/legacy `ROUND_HALF_DOWN`; keep legacy Revenue Growth / Net Profit Growth annualization basis. | Owner accepted finance-compatible parity on 2026-06-24; current `HALF_UP` behavior is a code-stage correction item, not the SRS contract. |
| Service authorization and audit | Require endpoint auth plus service-level read/edit guards before info/save mutation or write-back; authorization failures return `E401`/`E405`/`E498`/`AuthError` with no mutation. | API seed alone is insufficient for case/page authorization. Current controller logging is evidence, while service guard/audit proof and tests remain code-stage DoD. |
| RC old-case behavior | Preserve 0217 old-case Save-only behavior: hide/disable Finished, reject direct old-case `isFinish=true`, do not update parent done, and do not mark checkpoint completed. | PRD TBD-010 was confirmed by owner on 2026-06-24. Legacy JSP/JS hide Finished and suppress parent done for `attrMap.isOld`; backend enforcement is required because current migrated FE/BE otherwise allows direct finish. |

## New/Old DB Reconcile And Delta
| ID | Table / Field | Source | Three-way tag | SRS disposition |
|---|---|---|---|---|
| DB-D1 | `TB_FINANCIAL_EVALUATION_GI` active/exact; PK `APPLICATION_NO, DATA_SEQ`; ratio columns `VARCHAR2(12)`. | `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_GI.md:13-33` | (c) DB structure as new | Use in `schema.sql`; code must fit persisted string widths. |
| DB-D2 | `TB_FINANCIAL_EVALUATION_INFO` and `TB_FINANCIAL_EVALUATION_INFO_CORP` are both active in DB evidence and structurally different: INFO has 24 columns and PK `APPLICATION_NO, APPLICANT_NAME, DATA_SEQ`; INFO_CORP has 14 columns and PK `APPLICATION_NO, DATA_SEQ`. Current entity/repository maps INFO, while PRD/refactor corporate evidence names INFO_CORP. | `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_INFO.md:13-34`; `docs/db-diff/02_tables/TB_FINANCIAL_EVALUATION_INFO_CORP.md:13-33`; latest reverify `legacy_schema_reverify_new02_columns.tsv:1091-1128`, PK `legacy_schema_reverify_new02_pk.tsv:146-150`; `TBFinancialEvaluationInfoEntity.java:10`; `TBFinancialEvaluationInfoRepository.java:29`, `:41`, `:46`, `:57`; refactor save artifact `epl-save-c0-financial-business.md:185-199`. | (a) DB fact closed by RP35 | `schema.sql` emits both table structures. Treating INFO and INFO_CORP as interchangeable aliases is forbidden; RD/DBA must reconcile the current INFO entity/repository path with the corporate INFO_CORP PRD/refactor evidence before implementation closeout. |
| DB-D3 | New checkpoint columns are `TB_CHECK_POINTS_CS.EPROC00117` and `TB_CHECK_POINTS_CU.EPROC00117`; legacy keys were `EPROC0_0117/0217`. | `TB_CHECK_POINTS_CS.md:34-47`; `TB_CHECK_POINTS_CU.md:34-44`; PRD `:94-102` | (c) DB structure as new | To-be uses unified columns and preserves polarity. |
| DB-D4 | Source ratio rows come from GI statement tables; current info compute branch writes generated rows to `TB_FINANCIAL_EVALUATION_GI`. | PRD `:82-92`; service `CsuFinancialStaffServiceImpl.java:143-174` | (a) regression if list alignment omitted | R2/RP28 require backend count/`DATA_SEQ` guard and no partial write before computation; AP-days defect disposition remains `RP29`. |
| REF-D1 | Refactor artifact exposes info/save only; current controller also has select. | `EPROC00117.md` latest map; `CsuFinancialStaffController.java:29-44` | intended evolution / incomplete artifact | Include select as current real endpoint; close `getTotal`/inventory `getRate` and unused `getExist` as no-alias legacy/stale/non-called names. |

## @PENDING
| ID | Status | Owner | Blocking For | Required closure |
|---|---|---|---|---|
| RP26 | ✅ closed 2026-06-24 | SA/RD | R1/R8 | Closed: `EPL_ONLY_NO_GETTOTAL_GETRATE_ALIAS`. Public contract exposes only `epl-*` endpoints; legacy `getTotal` and inventory `getRate` are evidence/stale naming and must not become compatibility aliases. |
| RP27 | ✅ closed 2026-06-24 | PM/SA/RD | R2 | Closed: `QUERY_MODE_PERSISTED_EDIT_MODE_RECOMPUTE`. `isQuery=true` reads persisted ratios without recompute/write-back; `isQuery=false` recomputes complete GI source rows and writes generated rows. |
| RP28 | ✅ closed 2026-06-24 | SA/RD/QA | R2/R3 | Closed: `SOURCE_LIST_DATA_SEQ_ALIGNMENT_REQUIRED`. Balance/Income/Cashflow source lists must pass count, unique non-null `DATA_SEQ`, identical `DATA_SEQ` set, and `DATA_SEQ` pairing validation before computation/write-back; implementation and automated tests are code-stage DoD, pending RD. |
| RP29 | ✅ closed 2026-06-24 | SA/RD | R3 | Closed: `FIX_AP_TURNOVER_ZERO_DAYS_FOR_AP`. AP turnover zero shall set `DAYS_FOR_AP = N/A` and `CASH_CONVERSION_CYCLE = N/A`, and shall not overwrite `NUM_OF_DAYS_FOR_INVENTORY`; implementation and regression tests are code-stage DoD. |
| RP30 | ✅ closed 2026-06-24 | SA/RD | R2 | Closed: `RATIOS_EMPTY_ARRAY_NO_NULL_LIST`. Successful responses must return non-null `ratios`; no-data branches return `[]` or a controlled no-data/error envelope, never null-list exposure. Implementation and automated tests are code-stage DoD, pending RD. |
| RP31 | ✅ closed 2026-06-24 | Security/RD | R5/R7 | Closed: `SAVE_DETAIL_KEY_AUTHORITY_REQUIRED`. Persisted detail `APPLICATION_NO` must come from request/case scope; `DATA_SEQ` must be unique and valid; tampered/mismatched/duplicate keys must be rejected before mutation. Implementation and automated tests are code-stage DoD, pending RD. |
| RP32 | ✅ closed 2026-06-24 | PM/SA | R4 | Closed: `DSR_FIXED_USD_NO_MULTICURRENCY`. DSR/business financial item amount fields are USD-only; no exchange-rate conversion or editable multi-currency behavior is introduced. |
| RP33 | ✅ closed 2026-06-24 | SA/RD | R4/R5 | Closed: `DSR_ITEM_LIMIT_FIVE`. Maximum five DSR/business financial items; FE shows `COMMON_MSG_LIMIT`, and BE rejects more than five rows before mutation. Implementation and automated tests are code-stage DoD, pending RD. |
| RP34 | ✅ closed 2026-06-24 | SA/RD | R1/R8 | Closed: `NO_GETEXIST_COMPAT_API`. Legacy `getExist` is not used by this page's JS and must not be exposed as a migrated public compatibility API. |
| RP35 | ✅ closed 2026-06-24 | SA/RD/DBA | R5/DB-D2 | Closed: `INFO_AND_INFO_CORP_DISTINCT_TABLES`. DB evidence confirms both tables are active and structurally different; they must not be treated as aliases. Implementation reconcile and tests are code-stage DoD, pending RD/DBA. |
| RP36 | ✅ closed 2026-06-24 | SA/Finance/RD | R3 | Closed: `LEGACY_GROWTH_BASIS_ROUND_HALF_DOWN`. Use PRD/legacy `ROUND_HALF_DOWN`; keep current annualized value compared against prior-period raw value for Revenue Growth / Net Profit Growth. Implementation and regression tests are code-stage DoD, pending RD. |
| RP37 | ✅ closed 2026-06-24 | Security/RD/DBA | R7 | Closed: `SERVICE_LEVEL_AUTH_AUDIT_REQUIRED`. Endpoint auth plus service-level read/edit guard and audit coverage are required before info/save mutation or write-back; implementation, seed application, audit proof, and negative tests are code-stage DoD, pending RD/Security/DBA. |
| RP38 | ✅ closed 2026-06-24 | PM/SA/RD | R5/R6/R8 | Closed: `KEEP_0217_OLD_CASE_SAVE_ONLY_NO_FINISH_DONE_UPDATE`. RC old cases preserve Save-only behavior; Finished is hidden/disabled and direct old-case finish must be rejected before mutation/checkpoint update; parent done and completed checkpoint are not updated. Implementation and regression tests are code-stage DoD, pending RD/QA. |

## Traceability Matrix
> ⚠️ **QA 2026-06-24 暫拔除**：`qa-cases.md` 已刪。本 bundle 所有 QA-0XX 引用（下表 QA 欄、metadata 的 QA-017 佐證、RP26-38 closeout 的 QA 掛鉤）均為 **dormant、不得視為已驗證**；RP26-38 待決登記仍在本檔 §@PENDING 表（未遺失）。REQ↔Rn 追溯仍有效；恢復 QA 後重建。
| PRD area | Rules | QA |
|---|---|---|
| Page load / initQuery | R1, R2 | QA-001, QA-002, QA-003, QA-005, QA-017, QA-018 |
| GI ratio calculation | R2, R3 | QA-004, QA-005, QA-006, QA-019, QA-020, QA-021, QA-027 |
| DSR/business financial list | R4 | QA-007, QA-008, QA-015, QA-023, QA-024 |
| Save / Finished / transaction | R5, R6 | QA-009, QA-010, QA-011, QA-016, QA-022, QA-024, QA-026, QA-029 |
| Validation/security | R7 | QA-012, QA-013, QA-022, QA-028 |
| Legacy parity and deltas | R8 | QA-014, QA-018, QA-025, QA-029 |

## Hard Boundaries And As-Is/To-Be Summary
- As-is used old c0 actions and keys: `EPROC0_0117`, `EPROC0_0217`, `initQuery`, `getTotal`, `getExist`, `save`, and legacy checkpoint fields.
- To-be uses POST RPC `epl-*` endpoints, new `TB_CHECK_POINTS_CS/CU.EPROC00117`, backend-owned save/checkpoint authority, info-branch GI ratio write-back, and db-diff snapshot table definitions.
- Anything not verified against old corporate c0 code remains a code-stage parity verification item and must not be used to mark this bundle Approved without owner review.
