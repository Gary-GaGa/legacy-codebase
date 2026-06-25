# SRS - EPROC00114 Collateral Assessment

# ───────────────── Contract（做什麼；to-be only、可純掃開發）─────────────────

## Metadata
| Field | Value |
|---|---|
| funcId | EPROC00114 |
| Status | 規格定版=Approved (2026-06-24, owner — axis A–F 獨立確認 Blocker 全清)；實作完成=done (owner 2026-06-25; rd-done+獨立驗+ratify) (QA 暫拔除) |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00114-v1.0.md` |
| Bundle | `docs/specs/srs/EPROC00114/` |
| Source baseline | PRD v1.0 + legacy `EPROC0_0114`/`EPROC0_0214` + current corporate code + db-diff + latest reverify TSV + refactor-spec |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`（`qa-cases.md` 2026-06-24 隨 QA 暫拔除） |
| N-axis review | 2026-06-24 source/domain patch + Should-fix closeout PASS. Cleared the 2026-06-23 3🔴 by removing the phantom public C0 calc endpoint, carrying Rate through the save-path score phase, splitting read/write assessment maps so client save input no longer carries BE-derived `riskLevel`/`actionDate`/score fields, adding positive NUMBER(7,2) precision QA, grounding required `langType`, and adding edge QA for `LOW_RANGE <= score < UP_RANGE`, CVer default `001`, and strict maps. Later Should-fix closeout removed the stale standalone rate/calc auth wording from `schema.sql` and explicitly scoped PRD BR-014/TC-017 cross-module reset to `EPROCS_0170/0270` ownership. Mechanical gate PASS; axis-A reviewer PASS and cross-model reviewer PASS with no new Blocker/Should-fix. Owner-approved 2026-06-24 (規格定版) after axis A–F independent cross-model confirmation (AO CR-comment guard, totalScore precision, Rate no-data split closed); open pending rows closed; implementation/tests remain RD code-stage DoD. **2026-06-25 兩半轉換**：改 canonical Contract/Appendix 結構、Traceability 段已移除（追溯靠 covers-prd）、各 Rn 加 `[ev→Rn]`；散文式 `Status:` 正規化為 Metadata 表（值逐字保留）。Axis G / QA generation remains paused by process. |

## Scope
- In scope: collateral assessment tab for corporate C0 normal and renewal/change flows, option list loading, query, Rate, Save, Finished, score-card completion flag, CS checkpoint update, parent completion status, DB reconcile.
- Out of scope: changing PRD, unrelated ledgers/status files, other SRS pages, DB migration scripts, page-level authorization seed deployment.
- Cross-module reset behavior from `EPROCS_0170/0270` is owned by those授信條件異動 flows, not by this bundle. EPROC00114 only reads the resulting persisted state on query and writes its own save/finish result. [ev→R8]

## Assumptions / Dependencies / Constraints
- `TB_SCORE_CARD_PARAM_DETAIL` is the runtime seed source of truth for option labels, item scores, effective dates, and risk ranges; this SRS records the proven row distribution and algorithm contract but does not duplicate the full seed value set.
- The collateral score phase reuses the current grandfathered shared collateral score function; no C0 wrapper rename is a precondition for this bundle. [ev→R4]
- DB schema authority resolves `schema.sql` from db-diff plus latest reverify TSV; on conflict, latest reverify wins and the delta is recorded in DB Reconcile.

## Endpoints
| Endpoint | Method | Purpose | Rules |
|---|---|---|---|
| `epl-sele-c0-collateral-assessment` | POST | Loads C_V1-C_V8 option lists by application date and required `langType`. | R3 |
| `epl-info-c0-collateral-assessment` | POST | Loads page data by `applicationNo` and `isQuery`; no mutation. | R2, R3 |
| `epl-save-c0-collateral-assessment` | POST | Runs the Rate-equivalent score phase, then saves or finishes assessment in one transaction. | R4, R5, R6, R7, R8, R9, R10 |

## Rules
> 每條只寫 **to-be 契約**（系統最終應如何）；佐證/出處/as-is/決策 → 下半 `Rule Evidence`，用 `[ev→Rn]` 指過去。

### R1 tab availability and route binding - 強制點: both
covers-prd: REQ-001

The collateral assessment tab is available for the C0 corporate flow when the parent page identifies the case as CS and not old-case display mode. New UI must route both the normal and renewal/change flows to the same `EPROC00114` screen and use the `epl-*` contract in this SRS. The canonical migrated page key is `EPROC00114` and the display name is `Collateral Assessment`. [ev→R1]

### R2 query by application number - 強制點: BE
covers-prd: REQ-002, REQ-010

- `epl-info-c0-collateral-assessment` requires `applicationNo` and `isQuery`.
- Blank `applicationNo` must be rejected with `COMMON_MSG_ERROR_LON` or equivalent validation code `E102`; the same application-number validation applies to select, info, and save.
- Query must load the loan summary, main borrower corporate data, and existing collateral assessment row for the same `applicationNo`.
- If no loan summary/main borrower data exists for an interactive query, return `MSG_DATA_NOT_FOUND`; do not return a visually successful empty page. [ev→R2]

### R3 option lists and collateral assessment version - 強制點: BE
covers-prd: REQ-003

- `epl-sele-c0-collateral-assessment` requires `applicationNo` and `langType`. `langType` carries the locale/language contract for select requests; blank values are `E102` validation failures.
- Select loads option lists from `TB_SCORE_CARD_PARAM_DETAIL` for C_V1-C_V8 according to `applicationNo` application date.
- If CVer is missing, default to `001`.
- CVer `001` renders district, document, area, classification, loathsome, land shape, income.
- CVer `002` renders district, area, classification, loathsome, land shape, address, income.
- `TB_SCORE_CARD_PARAM_DETAIL.VAR_DESC` length is 180 and must not be truncated to the stale value 100. [ev→R3]

### R4 Rate calculation - 強制點: BE
covers-prd: REQ-004, REQ-005, REQ-010

- The save endpoint must execute the Rate-equivalent score phase before persistence: calculate total score from submitted code selections through the collateral total score function, then derive risk level and action date from BE seed/function data before writing `TB_COLL_ASS`.
- `SaveRequest.assistMap` and `SaveRequest.reviewerMap` are input-only code-selection maps. Client-sent `riskLevel`, `actionDate`, total score, item scores, or score datetime are not accepted as save inputs; the BE score phase must generate or overwrite those derived values.
- Save/Finished responses must include the user-observable BE-derived Rate result for the acting side as `SaveResponse.rateResult`: `riskLevel` (legacy `level`), `scoreDatetime` (legacy `scrDate`), and `totalScore`. FE must display/refresh from this response or a subsequent query response, not from client-side calculation.
- The score calculation is seed-driven: item scores and risk ranges are read from `TB_SCORE_CARD_PARAM_DETAIL.LOW_RANGE`, `UP_RANGE`, `SCORE`, `ST_DATE`, and `END_DATE`; item scores use C_V1-C_V8 variables and collateral risk-level lookup must use `VAR_NAME='COL_RISK_LV'`. `SCORE` is stored as text and must be converted to a number fail-fast.
- Risk-level range matching is inclusive on the lower bound and exclusive on the upper bound: `LOW_RANGE <= totalScore < UP_RANGE`.
- The calculation result must preserve decimal precision compatible with `TB_COLL_ASS.AO_SCORE/CR_SCORE NUMBER(7,2)`: for example, a computed `12.5` score is persisted/retrieved as `12.50`, not `12` or `12.5` truncated by integer conversion.
- Nonnumeric score seed, no matching item/risk range, missing derived value, zero/default fallback, integer truncation, score overflow, or using a non-collateral risk variable such as `P_RISK_LV` is a Rate failure returning `COMMON_MSG_RATE_FAIL` (500). Absent required application/borrower data is not a Rate failure: it is a no-data precondition handled by R9 as `MSG_DATA_NOT_FOUND` (404), so a 404 no-data case is never conflated with a 500 calculation fault.
- Rate failure inside save returns `COMMON_MSG_RATE_FAIL`; the whole save transaction rolls back and must not overwrite persisted risk level/date. [ev→R4]

### R5 Finish validation and role edit authority - 強制點: both
covers-prd: REQ-005

- Save can persist a draft without full field validation, but Finished must validate all required fields for the acting role.
- AO Finished requires AO collateral code selections and successful BE-derived calculated score/risk level/action date.
- CR Finished requires CR collateral code selections, successful BE-derived calculated score/risk level/action date, and review comment.
- `isFinish=true` is invalid if required code selections are absent or the R4 score phase cannot produce derived score/risk/date values; FE may pre-check code selections, but BE is authoritative.
- Unauthorized or missing role/page authority returns `E498`; the endpoint auth rows and service-level AO/CR write-side checks are both required. [ev→R5]

### R6 persistence and legacy check mapping - 強制點: BE
covers-prd: REQ-006

- `epl-save-c0-collateral-assessment` maps `isFinish=false` to legacy `check=Y` and `isFinish=true` to legacy `check=N`.
- Save/Finished must upsert the complete `TB_COLL_ASS` row for `applicationNo`, including the latest address code/score columns.
- Address code/score persistence uses the live DB/current DAO column names `AO_COLL_ADDR_CODE`, `AO_COLL_ADDR_SCR`, `CR_COLL_ADDR_CODE`, and `CR_COLL_ADDR_SCR`. Stale legacy SQL references to `CR_ADDR_CODE` or `CR_ADDR_SCR` must not appear in new SQL, entity mappings, OpenAPI field descriptions, or QA fixtures.
- Save/Finished must update `TB_LON_SUMMARY_INFO.CR_SCORE_CARD_COMPLETED` according to R7.
- All `TB_COLL_ASS`, `TB_LON_SUMMARY_INFO`, and checkpoint writes must be in one transaction; rollback on any write failure. [ev→R6]

### R7 score-card completion status - 強制點: BE
covers-prd: REQ-007

- AO save/finish sets `CR_SCORE_CARD_COMPLETED` to `NN` and copies AO collateral code/score values to the CR side while clearing CR score/risk/date fields.
- CR save/finish preserves the first character of `CR_SCORE_CARD_COMPLETED` and maintains only the second character: `N` for draft save, `Y` for Finished.
- The first character remains owned by company/individual scorecard flow; EPROC00114 must not infer or recalculate it. [ev→R7]

### R8 CS checkpoint and parent completion - 強制點: both
covers-prd: REQ-008, REQ-009

- For CS cases, Save sets `TB_CHECK_POINTS_CS.EPROC00114='Y'`; Finished sets `TB_CHECK_POINTS_CS.EPROC00114='N'`.
- EPROC00114 is a CS-only migrated page. The `TB_CHECK_POINTS_CU.EPROC00114` column is a shared-schema/history column and does not create CU page availability, CU save/finish behavior, or a CU checkpoint write contract. Direct save/finish requests for CU or otherwise non-CS cases must be rejected by route/page/service authority with no mutation; this bundle writes only `TB_CHECK_POINTS_CS.EPROC00114`.
- After save/finish, response must return whether all parent-page tabs are complete by checking that all relevant checkpoint flags are not `Y`. `SaveResponse.isAllTabsCheck` is mandatory for both draft Save and Finished responses, is computed server-side after the same transaction's checkpoint update, and must match the OpenAPI required `boolean` field. FE must consume this field for parent-tab completion display instead of inferring completion locally.
- Legacy normal/renewal tables `TB_CHECK_POINT_CORP` and `TB_CHECK_POINT_RC_CORP` must not be the write target. [ev→R8]

### R9 error handling compatibility - 強制點: BE
covers-prd: REQ-010

- Query no data or Rate no-data preconditions caused by missing required application/borrower context return `MSG_DATA_NOT_FOUND`; score seed/range faults and calculation exceptions are Rate failures and return `COMMON_MSG_RATE_FAIL`.
- Over-count returns `MSG_OVER_COUNT_LIMIT`.
- Query/save unexpected exception returns `MSG_QUERY_FAIL`, preserving legacy wording even for save failures.
- Rate unexpected exception returns `COMMON_MSG_RATE_FAIL`.
- Successful save/finish returns `COMMON_MSG_SAVE_SUCCESS`.
- API validation failures may also use refactor error code `E102`; authorization failures use `E498`. These codes must be documented in `openapi.yaml`. [ev→R9]

### R10 non-functional controls - 強制點: both
covers-prd: REQ-005, REQ-006, REQ-010

- Authorization is enforced server-side for all exposed `epl-*` endpoints, not only by FE control state.
- Save must reject non-AO/non-CR write attempts at service level instead of relying only on `APIAuthorizationFilter`. AO roles (`001`/`002`) must not write CR-only `reviewComment`/`CR_COMMENT`; BE must reject the request or ignore the tampered field before any mutation, and must record no CR comment change from AO save.
- save/finish must enforce a service-level write guard after endpoint authorization and before mutation. The guard must reject users without EPROC00114 page/write authority, unsupported roles outside AO (`001`/`002`) and CR (`102`/`103`), and payloads that attempt to write the protected side for the actor's role. Rejection returns `E498`/401 and must not mutate `TB_COLL_ASS`, `TB_LON_SUMMARY_INFO`, or checkpoint tables.
- Query, Rate, Save, and Finished actions must be auditable with masked sensitive values; do not log full borrower identity or free-text review comment.
- Save/Finished transaction must be atomic and observable with a correlation id or equivalent request trace.
- Normal response time target is interactive page use; excessive query volume must produce `MSG_OVER_COUNT_LIMIT` or a controlled validation error rather than partial results. [ev→R10]

### R11 migration deltas and source TBD closeout - 強制點: both
covers-prd: REQ-011

All formerly open migration deltas for this bundle are closed by owner decision, DB fact, or RD contract closeout. Closed rows are kept in the Appendix for traceability and are also synced to `docs/pending-register.md`; implementation-only closeouts remain code-stage DoD and must not be treated as already implemented. [ev→R11]

## NFR
- Authorization is server-side for all `epl-*` endpoints; mutating save/finish requires endpoint auth plus a service-level write guard (seed-only authorization is insufficient).
- Transaction: `TB_COLL_ASS`, `TB_LON_SUMMARY_INFO`, and checkpoint writes commit or roll back together; Rate failure inside save rolls back without overwriting persisted risk level/date.
- Precision: score calculation preserves decimal precision compatible with `TB_COLL_ASS.AO_SCORE/CR_SCORE NUMBER(7,2)`; nonnumeric/overflow/missing-range seed is fail-fast `COMMON_MSG_RATE_FAIL`.
- Audit/Observability: query/Rate/save/finish auditable with masked sensitive values; do not log full borrower identity or free-text review comment; transaction observable via correlation id.
- Throughput: excessive query volume must produce `MSG_OVER_COUNT_LIMIT` or a controlled validation error rather than partial results.

## Hard Boundaries
- 可先修（與 @PENDING 無關，皆已關閉為 owner/RD-contract 決策）：R1–R3, R6, R7, R9（route binding、query、option list、persistence、completion status、error mapping）。
- RD code-stage DoD（規格已鎖、實作待 RD）：R4/R5（BE-derived Rate、precision/fail-fast、`COL_RISK_LV`；PENDING-010）、R8（`isAllTabsCheck`；PENDING-008）、R10（service-level auth guard + AO CR-comment guard；PENDING-009/009A）。
- 摘要：契約 to-be 全鎖、無 open @PENDING；RD 可全面動工，PENDING-008/009/009A/010 為 implementation+test 閘門、非未決規格。

# ───────────────── Appendix — Evidence & Decisions（為什麼/出處/風險）─────────────────

## Appendix — Evidence & Decisions
> 本半＝稽核/審查讀者用；契約推導的所有佐證。實作者開發時可後讀。

## 結論（source/contract 取捨）
- 本 SRS 採用 current controller 的 `epl-*` endpoint 作為最終契約：`epl-sele-c0-collateral-assessment`、`epl-info-c0-collateral-assessment`、`epl-save-c0-collateral-assessment`。Refactor artifact 曾列 `epl-calc-c0-collateral-assessment`，但 current C0 controller/FE/auth evidence 均證明未實作；Rate is carried by save-path score phase.
- 舊系統 `check=Y/N` 僅保留為語意來源；新契約以 `isFinish=false/true` 承載，並在規則中明確映射。
- DB schema 以 `docs/db-diff/02_tables/TB_*.md` 加上 latest reverify TSV 補充；若兩者衝突，`schema.sql` 採 latest reverify，差異列在「DB Reconcile / Delta」。
- PRD TBD and source deltas are closed in the R11 migration-delta table with owner, DB, or RD-contract evidence.

## Source Evidence
| 類型 | evidence | SRS disposition |
| --- | --- | --- |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00114-v1.0.md:19` func/page source；`:72`-`:77` TBD；`:173`-`:183` REQ；`:528`-`:545` field mapping；`:551`-`:568` main tables/SQL；`:583`-`:608` BR/error；`:614`-`:662` NFR/AC/TC | Carried by R1-R11 |
| Refactor index | `docs/refactor-spec/02_modules/EPROC00114.md` lists BE artifacts for select/info/calc/save and FE screen artifact. | Reconciled: keeps only current controller endpoints |
| Refactor artifacts | `docs/refactor-spec/03_artifacts/**/EPROC00114/` defines select/info/save plus stale calc intent; SRS keeps only current controller endpoints and reconciles calc as stale artifact / save-path score phase. | REF-001/REF-005 |
| Legacy normal | `legacy-epro/JavaSource/com/cathaybk/epro/c0/web/EPROC0_0114.java:47` query；`:85` getRate；`:111` save；`legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0114_mod.java:54` query；`:92` save；`:121` AO `CR_SCORE_CARD_COMPLETED=NN`；`:130` CR second-char update；`:153` checkpoint update. | as-is baseline |
| Legacy renewal/change | `legacy-epro/JavaSource/com/cathaybk/epro/c0/web/EPROC0_0214.java` mirrors query/getRate/save；module uses renewal/change checkpoint field `EPROC0_0214`. | as-is baseline |
| Current BE | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCollateralAssessmentController.java:37`, `:51`, `:65` expose select/save/info only; no C0 calc route exists. `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCollateralAssessmentServiceImpl.java:118`, `:147`-`:150`, `:341`-`:355`, `:450`-`:457` implement transactional save, score calculation during save, and CS checkpoint update. | 現行實作 grounding |
| Current FE | C0 FE API service calls only `epl-info-c0-collateral-assessment`, `epl-sele-c0-collateral-assessment`, and `epl-save-c0-collateral-assessment` at `frontend/src/app/pages/case-edition/sub-pages/corporate/credit-investigation/components/collateral-assessment/services/api.service.ts:27-55`; no C0 calc API call exists. | 現行實作 grounding |
| Auth evidence | `docs/build-tasks/c0-authz-sql-findings.md:45`-`:47`, `:147`-`:149`, `:203` verify current TB_API_AUTH rows for select/info/save and explicitly note no c0 calc endpoint/auth row. | R10 |
| DB diff | `docs/db-diff/02_tables/TB_COLL_ASS.md`, `TB_LON_SUMMARY_INFO.md`, `TB_MAIN_BORROWER_INFO_CORP.md`, `TB_SCORE_CARD_PARAM_DETAIL.md`, `TB_CHECK_POINTS_CS.md`, `TB_CHECK_POINTS_CU.md`, plus removed legacy checkpoint docs. | schema 權威 |
| Latest DB reverify | `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv` and `.../legacy_schema_reverify_new02_pk.tsv`. | schema 權威（latest 優先） |
| Existing decisions | `docs/decisions.md:37` grandfathered c0 import exception；`docs/pending-register.md:18` c0 scorecard lifecycle pending；`docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md:137` page status `prd-ready`. | provenance |

## Contract Summary（佐證）
| endpoint | method | primary rules | notes |
| --- | --- | --- | --- |
| `epl-sele-c0-collateral-assessment` | POST | R3 | Loads C_V1-C_V8 option lists by application date and required `langType`. |
| `epl-info-c0-collateral-assessment` | POST | R2, R3 | Loads page data by `applicationNo` and `isQuery`; no mutation. |
| `epl-save-c0-collateral-assessment` | POST | R4, R5, R6, R7, R8, R9, R10 | Runs the Rate-equivalent score phase, then saves or finishes assessment in one transaction. |

## Trade-offs
- Removing the phantom standalone `epl-calc-c0-collateral-assessment` route and carrying Rate through the save-path score phase keeps the public contract aligned with current controller/FE/auth evidence while preserving Rate result visibility via `SaveResponse.rateResult`.
- Preserving the grandfathered individual `funcGetCollateralTotalScore` scoring module avoids a C0 wrapper rename; the SRS locks scoring behavior parity and seed/range semantics, not the legacy shared-module class name.

## DB Reconcile / Delta
| id | table | source | delta / reconcile | decision for schema.sql |
| --- | --- | --- | --- | --- |
| DB-001 | `TB_COLL_ASS` | db-diff active/exact has 41 columns; latest reverify adds `AO_COLL_ADDR_CODE`, `AO_COLL_ADDR_SCR`, `CR_COLL_ADDR_CODE`, `CR_COLL_ADDR_SCR`; PK `APPLICATION_NO`. | Latest DB is broader than markdown. PENDING-005 closes PRD TBD-005 toward the live/current `*_COLL_ADDR_*` physical names. | Emit full 45 columns and PK from latest reverify. |
| DB-002 | `TB_LON_SUMMARY_INFO` | db-diff active/exact has 51 columns and PK `APPLICATION_NO`; latest reverify columns add `PROJECT_CODE`, but latest PK TSV has no `TB_LON_SUMMARY_INFO` row. | `CR_SCORE_CARD_COMPLETED` remains 2-char lifecycle field. PK source is db-diff/current entity, with latest PK TSV absence recorded as a source divergence. | Emit full 52 columns and PK from db-diff/current entity, not from latest PK TSV. |
| DB-003 | `TB_MAIN_BORROWER_INFO_CORP` | db-diff active/exact and latest reverify both list 38 columns; PK is composite. | Column order differs in docs versus TSV but no type/length conflict found. | Emit latest full 38 columns and composite PK. |
| DB-004 | `TB_SCORE_CARD_PARAM_DETAIL` | db-diff lists `VAR_DESC VARCHAR2(100)`; latest reverify lists `VAR_DESC VARCHAR2(180)` and physical range columns `LOW_RANGE`, `UP_RANGE`, `SCORE`, `VAR_ORDER`, `ST_DATE`, `END_DATE`. | Use latest length and range columns to avoid truncation and stale `PARM_1/2/3`/`BEGIN_DATE`/`SORT` names; no PK found in supplied PK TSV. | Emit full 10 latest columns with `VAR_DESC VARCHAR2(180)`. |
| DB-005 | `TB_CHECK_POINTS_CS` | db-diff active/exact and latest reverify include `EPROC00114`; latest TSV clarifies all flag columns are `VARCHAR2(2)`. | New write target for this page; replaces legacy `TB_CHECK_POINT_CORP` / `TB_CHECK_POINT_RC_CORP`. | Emit full CS checkpoint columns and PK. |
| DB-006 | `TB_CHECK_POINTS_CU` | latest reverify includes `EPROC00114`; db-diff markdown is stale at 13 columns. | Physical CU column exists, but page behavior is CS-only; see PENDING-004. | Emit full latest CU table including `EPROC00114`. |
| DB-007 | `TB_CHECK_POINT_CORP`, `TB_CHECK_POINT_RC_CORP` | db-diff marks removed/unused and moved to new checkpoint tables. | Legacy evidence only; not active write target. | List as comments in `schema.sql`, not active DDL. |

## Refactor / current implementation delta
| id | evidence | delta | handling |
| --- | --- | --- | --- |
| REF-001 | Refactor artifact has `epl-calc-c0-collateral-assessment`; current controller has select/save/info only; current FE has no C0 calc API call; current save calls collateral score function before persistence. | Standalone Rate endpoint/auth row missing in current source; shared score function path exists in save. | Public contract removes the phantom calc endpoint and carries Rate through R4/R5 save-path score phase. |
| REF-002 | Current save request uses `isFinish`; PRD/legacy use `check`. | Contract vocabulary changed. | Accepted mapping in R6. |
| REF-003 | Current save implementation updates `TB_CHECK_POINTS_CS` only. | CU fallback is not implemented even though latest CU table has EPROC00114. | Closed by R8/PENDING-004: EPROC00114 is CS-only and does not write CU checkpoint. |
| REF-004 | Current save evidence does not prove parent completion response. | PRD requires `isAllTabsCheck`. | Closed by R8/PENDING-008: contract requires mandatory `SaveResponse.isAllTabsCheck`; implementation and tests remain code-stage DoD. |
| REF-005 | Current save recalculates scores through function and no standalone C0 Rate route is present. | Rate-before-Finished must still be enforceable by BE. | R4/R5 save-path score phase. |
| REF-006 | Current save request/service still accepts client-sent `riskLevel`/`actionDate` and does not overwrite them from the score function response. | This makes BE-derived Rate values client-authoritative and conflicts with save-path Rate ownership. | Closed by R4/PENDING-010: to-be `SaveRequest` uses input-only code-selection maps, rejects derived-field inputs, returns observable `rateResult`, and requires BE overwrite of derived values. |
| REF-007 | Current shared score implementation uses integer conversion, zero fallback, and current risk lookup through `P_RISK_LV` instead of legacy/proven `COL_RISK_LV`. | This can truncate decimal scores, hide invalid seed data, and choose the wrong collateral risk-level seed. | Closed by R4/PENDING-010: to-be contract requires decimal-compatible fail-fast behavior and `COL_RISK_LV`; implementation and tests remain code-stage DoD. |

## Error Codes
| code | owner endpoint | meaning | HTTP guidance |
| --- | --- | --- | --- |
| `0000` | all | Success. | 200 |
| `COMMON_MSG_SAVE_SUCCESS` | `epl-save-c0-collateral-assessment` | Save/Finished success message. | 200 |
| `E102` | all | Required field or validation failure in refactor contract. | 400 |
| `COMMON_MSG_ERROR_LON` | select/info/save | Blank application number legacy-compatible message. | 400 |
| `MSG_DATA_NOT_FOUND` | info/save pre-query | No application data found. | 404 |
| `MSG_OVER_COUNT_LIMIT` | info/select | Query result count exceeds legacy limit. | 429 |
| `MSG_QUERY_FAIL` | info/save/select | Query/save unexpected failure, legacy-compatible wording. | 500 |
| `COMMON_MSG_RATE_FAIL` | save score phase | Rate calculation failure. | 500 |
| `E498` | all | Authorization/page-role failure. | 401 |

## @PENDING
> All rows closed by owner decision, DB fact, or RD contract closeout. Kept for traceability; implementation-only closeouts (PENDING-008/009/009A/010) remain code-stage DoD and must not be treated as already implemented. Synced to `docs/pending-register.md`.

| id | owner | evidence | status / decision |
| --- | --- | --- | --- |
| PENDING-001 | Data/DBA/UAT | PRD TBD-001 asked for official `C_V1`-`C_V8` and `COL_RISK_LV` seed confirmation because the PRD only proved table access, not row values, at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00114-v1.0.md:72`. Read-only DB proof on 2026-06-24 against the new DB confirms runtime seed rows for all required variables: `C_V1=20`, `C_V2=3`, `C_V3=24`, `C_V4=20`, `C_V5=6`, `C_V6=9`, `C_V7=6`, `C_V8=16`, `C_Ver=3`, `COL_RISK_LV=33`; `COL_RISK_LV` has 33 scored range rows covering `LOW_RANGE=-999999` through `UP_RANGE=999999`. The seeded DOC_ID versions are `0000000001`, `0000000002`, and `0000000003`; `C_V8` exists only for `0000000002` and `0000000003`, matching the CVer `002` address-field contract. Latest schema reverify proves the physical columns at `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:2214`-`:2223`. | Closed: `DB_SEED_SOT_PRESENT`. Treat `TB_SCORE_CARD_PARAM_DETAIL` as the runtime seed source of truth; SRS records row distribution and algorithm constraints, while full seed value export/versioning remains a Data/DBA/UAT release artifact and QA may use controlled seed rows for boundary fixtures. |
| PENDING-002 | RD | PRD TBD-002 records that normal legacy `EPROC0_0114.getRate` calls `EPRO_I00113`, renewal/change `EPROC0_0214.getRate` calls `EPRO_C00113`, and the algorithms are currently the same at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00114-v1.0.md:73`. Legacy 0114 imports/calls `EPRO_I00113` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0114.java:16` and `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0114.java:92`-`:93`; legacy 0214 imports/calls `EPRO_C00113` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0214.java:16` and `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0214.java:92`-`:93`. Current C0 service imports/injects individual function DTO/service at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCollateralAssessmentServiceImpl.java:6`-`:22` and `:71`, then calls `funcGetCollateralTotalScore` at `:346`-`:353`. `docs/decisions.md:39` classifies `00114 CsuCollateralAssessment` use of individual FunctionService/DTO as grandfathered and not a new-page pattern. | Closed: `GRANDFATHERED_SCORE_FUNCTION_OK`. Preserve current grandfathered scoring-module ownership; no C0 wrapper rename is required. Behavior parity, BE-derived scoring, precision/fail-fast behavior, and seed/range semantics remain governed by R4/R5/PENDING-010. |
| PENDING-003 | PM/SA/FE | PRD TBD-003 records that legacy `EPROC00114_JS.jsp` / `EPROC00214_JS.jsp` `_funcName` uses `EPROI0_0114_FUNC_NAME`, while the page frame mixes `EPROI00114_FUNC_NAME` and `EPROC00114_FUNC_NAME`, and recommends one new-system display key/name at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00114-v1.0.md:74`. Legacy normal and renewal/change JS set `_funcName` from `EPROI0_0114_FUNC_NAME` and render `functionDescription` from `_funcId + _funcName` at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00114_JS.jsp:6`, `:28`, `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00214_JS.jsp:6`, and `:28`. Refactor FE artifact names the migrated page `EPROC00114-Collateral-Assessment` / `Collateral Assessment (頁籤)` at `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00114/eproc00114-collateral-assessment.md:1`, `:48`, and `:154`. | Closed: `EPROC00114_COLLATERAL_ASSESSMENT_CANONICAL_NAME`. Canonical key/name is `EPROC00114` / `Collateral Assessment`; legacy i18n keys (`EPROI0_0114_FUNC_NAME`, `EPROI00114_FUNC_NAME`, `EPROC00114_FUNC_NAME`) remain migration aliases only and must not create separate migrated pages or divergent menu labels. |
| PENDING-004 | PM/SA/RD | PRD TBD-004 asked whether `TB_CHECK_POINTS_CU.EPROC00114` should define CU behavior because latest reverify has both `TB_CHECK_POINTS_CS.EPROC00114` and `TB_CHECK_POINTS_CU.EPROC00114`, while PRD/current page evidence only proves CS flow and current save writes CS only. PRD page-frame and AC evidence show tab availability only for `!attrMap.isOld && attrMap.isCS` at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00114-v1.0.md:60`, `:628`-`:629`, and non-CS hidden behavior at `:645`. Current save evidence writes `TB_CHECK_POINTS_CS` only at `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCollateralAssessmentServiceImpl.java:450`-`:457`; current repository evidence lists `TB_CHECK_POINTS_CU.EPROC00114` but the service does not use the CU repository for this page. | Closed: `CS_ONLY_NO_CU_CHECKPOINT_CONTRACT`. EPROC00114 is CS-only; CU physical column presence does not create CU page availability or CU write behavior. |
| PENDING-005 | RD/DBA | PRD TBD-005 asked whether stale `TB_COLL_ASS.SQL_FIND_001.sql` filter names `CR_ADDR_CODE`/`CR_ADDR_SCR` should be migrated or corrected at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00114-v1.0.md:76`, and TC-020 expects new SQL to use `CR_COLL_ADDR_CODE/SCR` at `:662`. Legacy DAO field names include `AO_COLL_ADDR_CODE`, `AO_COLL_ADDR_SCR`, `CR_COLL_ADDR_CODE`, and `CR_COLL_ADDR_SCR` at `legacy-epro/JavaSource/com/cathaybk/epro/dao/EPRO_TB_COLL_ASS.java:55`; current entity maps the same columns at `backend/src/main/java/khd/svc/epro/entity/TBCollAssEntity.java:136`-`:145`; latest schema reverify lists them at `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:229`-`:232`. DB-live read-only verification on 2026-06-24 confirms `TB_COLL_ASS` has four address columns and zero `CR_ADDR_CODE`/`CR_ADDR_SCR` columns. | Closed: `CR_COLL_ADDR_COLUMNS_AUTHORITATIVE`. `*_COLL_ADDR_*` physical/current DAO names are authoritative; `CR_ADDR_*` is stale SQL wording only. |
| PENDING-006 | FE/SA | PRD TBD-006 records copied handlers for `AO_TRA_LST_MON_CODE`, `AO_MAX_DUE_CODE`, `CR_TRA_LST_MON_CODE`, and `CR_MAX_DUE_CODE` even though this JSP has no such fields at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00114-v1.0.md:77`. The copied handlers appear in legacy normal JS at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00114_JS.jsp:252`-`:304` and renewal/change JS at `legacy-epro/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00214_JS.jsp:252`-`:304`; repository search on 2026-06-24 found zero occurrences of those four DOM ids in the matching EPROC00114/EPROC00214 JSP files. Refactor FE field rules define the actual migrated collateral fields, including address only for CVer `002`, at `docs/refactor-spec/03_artifacts/fe-corporate/EPROC00114/eproc00114-collateral-assessment.md:193`-`:197` and `:205`-`:215`. | Closed: `COPIED_JS_HANDLERS_NOT_MIGRATED`. Do not migrate the unrelated `TRA_LST_MON/MAX_DUE` handlers or fields for EPROC00114. |
| PENDING-008 | RD/FE | PRD save response requires parent `isAllTabsCheck`, and current service save response evidence does not prove this field is returned. R8 and `openapi.yaml` require `SaveResponse.isAllTabsCheck` for both Save and Finished; QA-019 asserts true/false behavior. | Closed: `SAVE_RESPONSE_PARENT_COMPLETION_REQUIRED`. Contract is mandatory for BE response and FE parent-tab display; implementation and automated tests are code-stage DoD, pending RD. |
| PENDING-009 | RD/Security | Current platform `APIAuthorizationFilter` checks endpoint auth, but current `CsuCollateralAssessmentServiceImpl.validateFields` only branches AO/CR validation and does not explicitly reject unsupported write roles. R5/R10 and QA-013 require page/write authority, AO/CR role gating, protected-side tamper rejection, `E498`/401, and no mutation. | Closed: `SAVE_SERVICE_AUTH_GUARD_REQUIRED`. Contract is mandatory at service level in addition to endpoint auth; implementation and automated tests are code-stage DoD, pending RD. |
| PENDING-009A | RD/Security | `SaveRequest.reviewComment` is present for CR-side comment capture, but AO save payloads can otherwise attempt to tamper with CR-only `CR_COMMENT`. | Closed: `AO_SAVE_CANNOT_WRITE_CR_COMMENT`. AO roles (`001`/`002`) must not mutate `reviewComment`/`CR_COMMENT`; BE must reject or ignore the field before mutation and tests must prove no CR comment update from AO save. |
| PENDING-010 | RD | Current save request/service still accepts client-sent `riskLevel`/`actionDate`, copies them from `SaveCsuCollateralAssessmentRequest.CollateralAssessmentMap` in `CsuCollateralAssessmentServiceImpl.java:618`-`:620`, gates score execution on client `riskLevel` at `:345`/`:350`, and does not overwrite `riskLevel` from `GetCollateralTotalScoreResponse` because `setScoreToMap` comments out `data.setRiskLevel(...)` at `:390`. Current shared collateral score function also uses `int totalScore`, `NumberUtil.toInteger(detail.getScore())`, and null fallback to `0` in `backend/src/main/java/khd/svc/epro/service/individual/impl/FunctionServiceImpl.java:3225`-`:3228`; it calls `findRiskLevel` at `:3242`, whose repository query uses `VAR_NAME='P_RISK_LV'` at `backend/src/main/java/khd/svc/epro/repository/TBScoreCardParamDetailRepository.java:57` and `:63`, while legacy 0114/0214 pass `COL_RISK_LV` at `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0114.java:93` and `EPROC0_0214.java:93`. R4/OpenAPI/QA-009/QA-010/QA-026/QA-029/QA-030/QA-032 define the to-be strict input, BE-derived score, decimal precision, `COL_RISK_LV` lookup, observable `rateResult`, and fail-fast behavior. | Closed: `BE_DERIVED_RATE_FIELDS_REQUIRED`. Client authority over derived save fields is forbidden; save-path score phase must generate/overwrite derived values from BE data and use `COL_RISK_LV`. Implementation and automated tests are code-stage DoD, pending RD. |

Resolved source/domain note: prior `PENDING-007` is closed by source evidence. The public C0 contract removes standalone `epl-calc-c0-collateral-assessment` because current C0 controller exposes only select/save/info, current C0 FE calls only info/select/save, and auth findings record no C0 calc endpoint/auth row; Rate is carried by R4/R5 save-path score phase. The remaining save-path implementation gap is tracked by `PENDING-010` and does not reintroduce a public calc endpoint.

Scope note (cross-module reset): PRD BR-014 and TC-017 state that non-CR condition-change paths can reset `EPROC0_0114/0214` checkpoint to `Y` and clear CR scoring fields at `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00114-v1.0.md:596` and `:659`; that reset transaction and trigger rule are owned by the `EPROCS_0170/0270` 授信條件異動 flows. EPROC00114's R8 contract is limited to its own save/finish and query visibility of the resulting checkpoint/score state.

## Rule Evidence
> 每條 Rn 的 as-is（現況/legacy；含疑似 bug）、to-be delta / 決策 ID、provenance（`file:line`/seed proof）；鍵到 Rn，與上半 `[ev→Rn]` 1:1。

| Rn | as-is（現況/legacy；含疑似 bug） | to-be delta / 決策 ID | provenance |
|---|---|---|---|
| R1 | Normal flow source is legacy `EPROC0_0114` under parent `EPROC0_0110`; renewal/change source is legacy `EPROC0_0214` under parent `EPROC0_0210`. Legacy i18n keys mix `EPROI0_0114_FUNC_NAME`/`EPROI00114_FUNC_NAME`/`EPROC00114_FUNC_NAME`. | Owner decision 2026-06-24 (PENDING-003): canonical migrated page key/name is `EPROC00114` / `Collateral Assessment`; legacy i18n keys are migration aliases only and must not create separate pages or divergent menu labels. | PRD `:60`; legacy parents `EPROC0_0110`/`EPROC0_0210`; PENDING-003. |
| R2 | Legacy query loads loan summary, main borrower corporate data, existing collateral assessment row; blank application number rejected with legacy message. | Carried as to-be; blank `applicationNo` → `COMMON_MSG_ERROR_LON`/`E102`; interactive no-data → `MSG_DATA_NOT_FOUND` (not a visually successful empty page). | `legacy-epro/.../EPROC0_0114_mod.java:54`; current service `:118`. |
| R3 | Legacy select loads C_V1-C_V8 by application date and CVer; db-diff lists `VAR_DESC VARCHAR2(100)`. Current select request DTO carries `langType`; current service does not prove label branching. | Required `langType` (blank=`E102`); CVer default `001`; CVer 001/002 field sets; `VAR_DESC` length 180 not stale 100. Owner decision 2026-06-24 (PENDING-006): copied `AO_TRA_LST_MON_CODE`/`AO_MAX_DUE_CODE`/`CR_TRA_LST_MON_CODE`/`CR_MAX_DUE_CODE` handlers/fields are NOT migrated. DB-live read-only verify 2026-06-24 confirms seed rows `C_V1=20`,`C_V2=3`,`C_V3=24`,`C_V4=20`,`C_V5=6`,`C_V6=9`,`C_V7=6`,`C_V8=16`,`C_Ver=3`,`COL_RISK_LV=33`; DOC_ID versions `0000000001/0000000002/0000000003`; `C_V8` only for `0000000002`/`0000000003`; `COL_RISK_LV` 33 range rows `LOW_RANGE=-999999`..`UP_RANGE=999999`. | refactor select artifact; DB-004 reverify; PENDING-001/PENDING-006; refactor FE `eproc00114-collateral-assessment.md:193-197`,`:205-215`. |
| R4 | Refactor artifact defines a standalone calc endpoint, but current C0 controller/FE/auth evidence proves the public endpoint does not exist. Current save still calls the shared collateral score function before persistence, but the current request/service path still accepts client-sent `riskLevel`/`actionDate`, gates score execution on client `riskLevel`, does not overwrite `riskLevel`/`actionDate` from the function response, uses `int totalScore`/integer conversion/zero fallback, and looks up `P_RISK_LV` instead of `COL_RISK_LV`. | Public contract removes the standalone calc route (PENDING-007 resolved); Rate carried by save-path score phase. To-be is BE-derived, strict input-only maps, BigDecimal/fail-fast, `COL_RISK_LV`, decimal precision compatible with `NUMBER(7,2)`, observable `rateResult`. Owner decision 2026-06-24 (PENDING-002): grandfathered `funcGetCollateralTotalScore` may continue; no C0 wrapper rename required. RD contract closeout (PENDING-010): save always derives derived fields regardless of client payload; tests are code-stage DoD. | refactor artifact vs current controller/FE/auth; current `CsuCollateralAssessmentServiceImpl.java:341-355`,`:345`/`:350`,`:390`,`:618-620`; `FunctionServiceImpl.java:3225-3228`,`:3242`; `TBScoreCardParamDetailRepository.java:57`,`:63`,`:137-139`; legacy `EPROC0_0114.java:93`/`EPROC0_0214.java:93`; PENDING-002/PENDING-010; REF-006/REF-007. |
| R5 | Legacy `validSave114/214.register` enforces Rate-before-Finished and role validation. | Save persists draft without full validation; Finished validates all required fields per role (AO/CR code selections + BE-derived score/risk/date; CR also review comment); `isFinish=true` invalid if selections absent or score phase cannot derive; unauthorized → `E498` with both endpoint auth rows and service-level write checks (PENDING-009). | PRD `:318` (REQ-005); legacy `validSave114/214`; PENDING-009. |
| R6 | Legacy `save(check)` upserts `TB_COLL_ASS` (update then count-0 insert); legacy SQL references stale `CR_ADDR_CODE`/`CR_ADDR_SCR`. | `isFinish=false`→legacy `check=Y`, `isFinish=true`→`check=N`; upsert full `TB_COLL_ASS` incl. address columns using authoritative `*_COLL_ADDR_*` names (PENDING-005); update `TB_LON_SUMMARY_INFO.CR_SCORE_CARD_COMPLETED` per R7; single transaction. | legacy `EPRO_TB_COLL_ASS` upsert; PENDING-005; DB-001. |
| R7 | Legacy AO save sets `CR_SCORE_CARD_COMPLETED=NN` and copies AO values to CR while clearing CR fields; CR maintains second char only. | Carried as to-be: AO sets `NN`+copy+clear CR; CR preserves first char, second char `N` (draft)/`Y` (Finished); first char owned by company/individual scorecard flow, EPROC00114 must not infer/recalculate. Existing c0 lifecycle pending in `docs/pending-register.md` remains out of scope. | legacy `EPROC0_0114_mod.java:121`,`:130`; `docs/pending-register.md:18`. |
| R8 | Legacy writes `TB_CHECK_POINT_CORP`/`TB_CHECK_POINT_RC_CORP`; current save writes `TB_CHECK_POINTS_CS` only and does not prove parent-completion response. Physical schema also has `TB_CHECK_POINTS_CU.EPROC00114`. | CS-only (PENDING-004): Save `'Y'`/Finished `'N'` on `TB_CHECK_POINTS_CS.EPROC00114`; CU column is shared-schema/history, no CU page/write contract; non-CS direct save/finish rejected with no mutation. `SaveResponse.isAllTabsCheck` mandatory both Save/Finished, server-computed post-checkpoint (PENDING-008). Legacy CORP/RC_CORP not the write target. Cross-module resets owned by `EPROCS_0170/0270`. | current `CsuCollateralAssessmentServiceImpl.java:450-457`; legacy parents `:check`; PENDING-004/PENDING-008; REF-003/REF-004. |
| R9 | Legacy `doQuery`/`doGetRate`/`doSave` catch blocks map `MSG_DATA_NOT_FOUND`/`MSG_OVER_COUNT_LIMIT`/`MSG_QUERY_FAIL`/rate fail/save success, preserving wording. | Carried as to-be with explicit no-data vs Rate-fail split (404 `MSG_DATA_NOT_FOUND` ≠ 500 `COMMON_MSG_RATE_FAIL`); add refactor `E102`/`E498`; codes documented in openapi. | legacy catch blocks (PRD `:583-608`); Error Codes table above. |
| R10 | Current platform `APIAuthorizationFilter` checks endpoint auth; current `validateFields` only branches AO/CR and does not reject unsupported write roles; AO payload can tamper CR-only `CR_COMMENT`. TB_API_AUTH covers select/info/save, no c0 calc row. | Server-side auth for all `epl-*`; service-level write guard after endpoint auth and before mutation (page/write authority, AO `001`/`002` & CR `102`/`103` only, protected-side tamper → `E498`/401, no mutation; PENDING-009); AO must not write `reviewComment`/`CR_COMMENT` (PENDING-009A); masked audit; atomic+correlation-id observable; excess volume → `MSG_OVER_COUNT_LIMIT`/controlled error. | `docs/build-tasks/c0-authz-sql-findings.md:45-47`,`:147-149`,`:203`; current `validateFields`; PENDING-009/PENDING-009A. |
| R11 | PRD TBD-001..006 and source/current deltas (REF-001..007) were open migration deltas. | All closed by owner decision, DB fact, or RD contract closeout; closed rows kept here for traceability and synced to `docs/pending-register.md`; implementation-only closeouts remain code-stage DoD. | @PENDING table above; REF table above; `docs/pending-register.md`. |
