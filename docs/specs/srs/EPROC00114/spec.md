# SRS - EPROC00114 Collateral Assessment

Status: 規格定版=draft；實作完成=draft  
N-axis review: spec-reviewer (axis A) 2026-06-23: mechanical gate PASS; 3🔴 + 7🟡; verdict = refine, do NOT regenerate. 🔴 = (1) phantom `epl-calc-c0-collateral-assessment` in openapi vs PENDING-007 (no c0 calc; score via save); (2) NUMBER(7,2) precision has no positive QA case (truncation/silent-corruption risk); (3) `langType` required but no PRD req/Rn/QA. Structure & traceability meet DoD; promote to In Review after 🔴 fixes + edge cases (boundary/CVer-default/map-key strictness).  
funcId: EPROC00114  
PRD: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00114-v1.0.md`  
Bundle: `docs/specs/srs/EPROC00114/`

## 1. 結論

- 本 SRS 採用 refactor/current 的 `epl-*` endpoint 作為最終契約：`epl-sele-c0-collateral-assessment`、`epl-info-c0-collateral-assessment`、`epl-calc-c0-collateral-assessment`、`epl-save-c0-collateral-assessment`。
- 舊系統 `check=Y/N` 僅保留為語意來源；新契約以 `isFinish=false/true` 承載，並在規則中明確映射。
- DB schema 以 `docs/db-diff/02_tables/TB_*.md` 加上 latest reverify TSV 補充；若兩者衝突，`schema.sql` 採 latest reverify，差異列在本檔「新舊 DB 對照 / 更動 delta / reconcile」。
- PRD TBD 與 C 類裁定不自裁，集中列於 `@PENDING`，包含 owner 與 evidence。

## 2. Sources

| 類型 | evidence |
| --- | --- |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00114-v1.0.md:19` func/page source；`:72`-`:77` TBD；`:173`-`:183` REQ；`:528`-`:545` field mapping；`:551`-`:568` main tables/SQL；`:583`-`:608` BR/error；`:614`-`:662` NFR/AC/TC |
| Refactor index | `docs/refactor-spec/02_modules/EPROC00114.md` lists BE artifacts for select/info/calc/save and FE screen artifact. |
| Refactor artifacts | `docs/refactor-spec/03_artifacts/**/EPROC00114/` defines `epl-sele-c0-collateral-assessment`, `epl-info-c0-collateral-assessment`, `epl-calc-c0-collateral-assessment`, `epl-save-c0-collateral-assessment` request/response and validation intent. |
| Legacy normal | `legacy-epro/JavaSource/com/cathaybk/epro/c0/web/EPROC0_0114.java:47` query；`:85` getRate；`:111` save；`legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0114_mod.java:54` query；`:92` save；`:121` AO `CR_SCORE_CARD_COMPLETED=NN`；`:130` CR second-char update；`:153` checkpoint update. |
| Legacy renewal/change | `legacy-epro/JavaSource/com/cathaybk/epro/c0/web/EPROC0_0214.java` mirrors query/getRate/save；module uses renewal/change checkpoint field `EPROC0_0214`. |
| Current BE | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCollateralAssessmentController.java:37`, `:51`, `:65` expose select/save/info only; `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCollateralAssessmentServiceImpl.java:118`, `:147`-`:150`, `:341`-`:355`, `:450`-`:457` implement transactional save, score calculation during save, and CS checkpoint update. |
| Auth evidence | `docs/build-tasks/c0-authz-sql-findings.md:45`-`:47`, `:147`-`:149`, `:203` verify current TB_API_AUTH rows for select/info/save and explicitly note no c0 calc endpoint/auth row. |
| DB diff | `docs/db-diff/02_tables/TB_COLL_ASS.md`, `TB_LON_SUMMARY_INFO.md`, `TB_MAIN_BORROWER_INFO_CORP.md`, `TB_SCORE_CARD_PARAM_DETAIL.md`, `TB_CHECK_POINTS_CS.md`, `TB_CHECK_POINTS_CU.md`, plus removed legacy checkpoint docs. |
| Latest DB reverify | `C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv` and `.../legacy_schema_reverify_new02_pk.tsv`. |
| Existing decisions | `docs/decisions.md:37` grandfathered c0 import exception；`docs/pending-register.md:18` c0 scorecard lifecycle pending；`docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md:137` page status `prd-ready`. |

## 3. Contract Summary

| endpoint | method | primary rules | notes |
| --- | --- | --- | --- |
| `epl-sele-c0-collateral-assessment` | POST | R3 | Loads C_V1-C_V8 option lists by application date and language. |
| `epl-info-c0-collateral-assessment` | POST | R2, R3 | Loads page data by `applicationNo` and `isQuery`; no mutation. |
| `epl-calc-c0-collateral-assessment` | POST | R4, R5 | To-be/refactor Rate endpoint; current controller/auth gap is tracked as `PENDING-007`, while the same score function path is already used during save. |
| `epl-save-c0-collateral-assessment` | POST | R5, R6, R7, R8, R9, R10 | Saves or finishes assessment in one transaction. |

## 4. Scope

- In scope: collateral assessment tab for corporate C0 normal and renewal/change flows, option list loading, query, Rate, Save, Finished, score-card completion flag, CS checkpoint update, parent completion status, DB reconcile.
- Out of scope: changing PRD, ledger, pending register, other SRS pages, DB migration scripts, page-level authorization seed deployment.

## 5. Business Rules

### R1 tab availability and route binding **強制點: both**

- covers-prd: REQ-001
- The collateral assessment tab is available for the C0 corporate flow when the parent page identifies the case as CS and not old-case display mode.
- Normal flow source is legacy `EPROC0_0114` under parent `EPROC0_0110`; renewal/change source is legacy `EPROC0_0214` under parent `EPROC0_0210`.
- New UI must route both flows to the same `EPROC00114` screen and use the `epl-*` contract in this SRS.

### R2 query by application number **強制點: BE**

- covers-prd: REQ-002, REQ-010
- `epl-info-c0-collateral-assessment` requires `applicationNo` and `isQuery`.
- Blank `applicationNo` must be rejected with `COMMON_MSG_ERROR_LON` or equivalent validation code `E102`; the same application-number validation applies to select, info, calc, and save.
- Query must load the loan summary, main borrower corporate data, and existing collateral assessment row for the same `applicationNo`.
- If no loan summary/main borrower data exists for an interactive query, return `MSG_DATA_NOT_FOUND`; do not return a visually successful empty page.

### R3 option lists and collateral assessment version **強制點: BE**

- covers-prd: REQ-003
- `epl-sele-c0-collateral-assessment` loads option lists from `TB_SCORE_CARD_PARAM_DETAIL` for C_V1-C_V8 according to `applicationNo` application date and `langType`.
- If CVer is missing, default to `001`.
- CVer `001` renders district, document, area, classification, loathsome, land shape, income.
- CVer `002` renders district, area, classification, loathsome, land shape, address, income.
- `TB_SCORE_CARD_PARAM_DETAIL.VAR_DESC` length is 180 per latest reverify and must not be truncated to the stale markdown value 100.

### R4 Rate calculation **強制點: BE**

- covers-prd: REQ-004, REQ-005, REQ-010
- `epl-calc-c0-collateral-assessment` calculates total score from submitted code selections through the collateral total score function, then derives risk level from the collateral risk-level seed range, application date, and total score.
- The score calculation is seed-driven: item scores and risk ranges are read from `TB_SCORE_CARD_PARAM_DETAIL.LOW_RANGE`, `UP_RANGE`, `SCORE`, `ST_DATE`, and `END_DATE`; `SCORE` is stored as text and must be converted to a number fail-fast. Nonnumeric score seed, no matching item/risk range, missing application data, or numeric overflow for `TB_COLL_ASS.AO_SCORE/CR_SCORE NUMBER(7,2)` is a Rate failure.
- Rate is a read-only calculation; it must not update `TB_COLL_ASS`, `TB_LON_SUMMARY_INFO`, or checkpoint tables.
- Rate no-data returns `MSG_DATA_NOT_FOUND`; Rate calculation/data failure returns `COMMON_MSG_RATE_FAIL` and must not overwrite the currently displayed risk level/date.
- Refactor artifact defines this endpoint, but current controller does not expose it; see `PENDING-007`. Current save still calls the same collateral score function before persistence, but that shared implementation currently truncates through integer conversion and silent zero fallback; see `PENDING-010`. The to-be contract remains BigDecimal/fail-fast and is testable through save-path fault injection until the standalone endpoint is added.

### R5 Finish validation and role edit authority **強制點: both**

- covers-prd: REQ-005
- Save can persist a draft without full field validation, but Finished must validate all required fields for the acting role.
- AO Finished requires AO collateral codes, calculated score/risk level, and action date.
- CR Finished requires CR collateral codes, calculated score/risk level, action date, and review comment.
- `isFinish=true` is invalid if Rate-derived fields are absent; FE may pre-check, but BE is authoritative.
- Unauthorized or missing role/page authority returns `E498`; the endpoint auth rows and service-level AO/CR write-side checks are both required.

### R6 persistence and legacy check mapping **強制點: BE**

- covers-prd: REQ-006
- `epl-save-c0-collateral-assessment` maps `isFinish=false` to legacy `check=Y` and `isFinish=true` to legacy `check=N`.
- Save/Finished must upsert the complete `TB_COLL_ASS` row for `applicationNo`, including the latest address code/score columns.
- Save/Finished must update `TB_LON_SUMMARY_INFO.CR_SCORE_CARD_COMPLETED` according to R7.
- All `TB_COLL_ASS`, `TB_LON_SUMMARY_INFO`, and checkpoint writes must be in one transaction; rollback on any write failure.

### R7 score-card completion status **強制點: BE**

- covers-prd: REQ-007
- AO save/finish sets `CR_SCORE_CARD_COMPLETED` to `NN` and copies AO collateral code/score values to the CR side while clearing CR score/risk/date fields.
- CR save/finish preserves the first character of `CR_SCORE_CARD_COMPLETED` and maintains only the second character: `N` for draft save, `Y` for Finished.
- The first character remains owned by company/individual scorecard flow; EPROC00114 must not infer or recalculate it.
- Existing c0 lifecycle pending in `docs/pending-register.md` remains out of scope for this bundle; this rule records PRD/legacy parity, not a new cross-page裁定.

### R8 CS checkpoint and parent completion **強制點: both**

- covers-prd: REQ-008, REQ-009
- For CS cases, Save sets `TB_CHECK_POINTS_CS.EPROC00114='Y'`; Finished sets `TB_CHECK_POINTS_CS.EPROC00114='N'`.
- After save/finish, response must return whether all parent-page tabs are complete by checking that all relevant checkpoint flags are not `Y`.
- Legacy normal/renewal tables `TB_CHECK_POINT_CORP` and `TB_CHECK_POINT_RC_CORP` are removed/unused in the new schema and must not be the write target.
- CU fallback behavior is not decided in this SRS; see R11/PENDING-004.

### R9 error handling compatibility **強制點: BE**

- covers-prd: REQ-010
- Query or Rate no data returns `MSG_DATA_NOT_FOUND`.
- Over-count returns `MSG_OVER_COUNT_LIMIT`.
- Query/save unexpected exception returns `MSG_QUERY_FAIL`, preserving legacy wording even for save failures.
- Rate unexpected exception returns `COMMON_MSG_RATE_FAIL`.
- Successful save/finish returns `COMMON_MSG_SAVE_SUCCESS`.
- API validation failures may also use refactor error code `E102`; authorization failures use `E498`. These codes must be documented in `openapi.yaml` and QA.

### R10 non-functional controls **強制點: both**

- covers-prd: REQ-005, REQ-006, REQ-010
- Authorization is enforced server-side for all exposed `epl-*` endpoints, not only by FE control state.
- Current TB_API_AUTH seed evidence covers select/info/save, but no current calc endpoint/auth row exists. Before QA deployment, the to-be calc endpoint must receive its own auth row, and save must reject non-AO/non-CR write attempts at service level instead of relying only on `APIAuthorizationFilter`.
- Query, Rate, Save, and Finished actions must be auditable with masked sensitive values; do not log full borrower identity or free-text review comment.
- Save/Finished transaction must be atomic and observable with a correlation id or equivalent request trace.
- Normal response time target is interactive page use; excessive query volume must produce `MSG_OVER_COUNT_LIMIT` or a controlled validation error rather than partial results.

### R11 @PENDING migration deltas and source TBDs **強制點: both**

- covers-prd: REQ-011
- This rule is intentionally pending because the following items require owner decisions or implementation closeout. Do not self-decide these in the SRS.

| id | owner | evidence | pending decision |
| --- | --- | --- | --- |
| PENDING-001 @PENDING | Data/DBA/UAT | PRD TBD-001; the official production seed export for C_V1-C_V8 and collateral risk-level ranges is not bundled with the PRD/SRS. The contract uses the latest physical table shape and seed-driven range algorithm. | Publish/version the official seed package for labels, scores, and ranges; QA may use controlled seed rows to verify algorithm boundaries. |
| PENDING-002 @PENDING | RD | PRD TBD-002; normal legacy calls `EPRO_I00113`, renewal calls `EPRO_C00113`; current BE imports individual function DTO/service under a grandfathered decision. | Confirm shared scoring module ownership and whether any wrapper rename is required. |
| PENDING-003 @PENDING | PM/SA/FE | PRD TBD-003; JSP i18n key names differ between page frame and function name. | Final display key naming for EPROC00114. |
| PENDING-004 @PENDING | PM/SA/RD | PRD TBD-004; latest reverify has both `TB_CHECK_POINTS_CS.EPROC00114` and `TB_CHECK_POINTS_CU.EPROC00114`, while PRD/current page evidence only proves CS flow and current save writes CS only. | Confirm whether EPROC00114 is CS-only despite the CU column, or define CU checkpoint behavior. |
| PENDING-005 @PENDING | RD/DBA | PRD TBD-005; legacy SQL mentions `CR_ADDR_CODE`/`CR_ADDR_SCR`, DAO/current/latest DB use `CR_COLL_ADDR_CODE`/`CR_COLL_ADDR_SCR`. | Confirm SQL naming is stale and `CR_COLL_ADDR_*` is authoritative. |
| PENDING-006 @PENDING | FE/SA | PRD TBD-006; legacy JS has copied handlers not tied to this page. | Confirm these handlers are not migrated. |
| PENDING-007 @PENDING | RD | Refactor artifact defines `epl-calc-c0-collateral-assessment`; current controller exposes only select/save/info and `c0-authz-sql-findings.md:203` records no calc auth row. Current save does invoke the collateral score function. | Add standalone Rate endpoint plus TB_API_AUTH row, or formally revise contract; until then test the shared score path through save fault injection. |
| PENDING-008 @PENDING | RD/FE | PRD save response requires parent `isAllTabsCheck`; current service save response evidence does not prove this field is returned. | Ensure save response carries parent completion state. |
| PENDING-009 @PENDING | RD/Security | Current platform `APIAuthorizationFilter` checks endpoint auth, but current `CsuCollateralAssessmentServiceImpl.validateFields` only branches AO/CR validation and does not explicitly reject unsupported write roles. | Add service-level rejection for non-AO/non-CR save/finish and protected-side tampering, returning `E498` with no mutation. |
| PENDING-010 @PENDING | RD | Current shared collateral score function uses `int totalScore`, `NumberUtil.toInteger(detail.getScore())`, and null fallback to `0` in `backend/src/main/java/khd/svc/epro/service/individual/impl/FunctionServiceImpl.java:3225`-`:3228`. | Replace with fail-fast numeric parsing, preserve decimal precision compatible with `TB_COLL_ASS.AO_SCORE/CR_SCORE NUMBER(7,2)`, and return `COMMON_MSG_RATE_FAIL` for nonnumeric seed, missing range, or overflow. |

## 6. 新舊 DB 對照 / 更動 delta / reconcile

| id | table | source | delta / reconcile | decision for schema.sql |
| --- | --- | --- | --- | --- |
| DB-001 | `TB_COLL_ASS` | db-diff active/exact has 41 columns; latest reverify adds `AO_COLL_ADDR_CODE`, `AO_COLL_ADDR_SCR`, `CR_COLL_ADDR_CODE`, `CR_COLL_ADDR_SCR`; PK `APPLICATION_NO`. | Latest DB is broader than markdown. Also reconciles PRD TBD-005 toward `*_COLL_ADDR_*` physical names, but owner confirmation remains pending. | Emit full 45 columns and PK from latest reverify. |
| DB-002 | `TB_LON_SUMMARY_INFO` | db-diff active/exact has 51 columns and PK `APPLICATION_NO`; latest reverify columns add `PROJECT_CODE`, but latest PK TSV has no `TB_LON_SUMMARY_INFO` row. | `CR_SCORE_CARD_COMPLETED` remains 2-char lifecycle field. PK source is db-diff/current entity, with latest PK TSV absence recorded as a source divergence. | Emit full 52 columns and PK from db-diff/current entity, not from latest PK TSV. |
| DB-003 | `TB_MAIN_BORROWER_INFO_CORP` | db-diff active/exact and latest reverify both list 38 columns; PK is composite. | Column order differs in docs versus TSV but no type/length conflict found. | Emit latest full 38 columns and composite PK. |
| DB-004 | `TB_SCORE_CARD_PARAM_DETAIL` | db-diff lists `VAR_DESC VARCHAR2(100)`; latest reverify lists `VAR_DESC VARCHAR2(180)` and physical range columns `LOW_RANGE`, `UP_RANGE`, `SCORE`, `VAR_ORDER`, `ST_DATE`, `END_DATE`. | Use latest length and range columns to avoid truncation and stale `PARM_1/2/3`/`BEGIN_DATE`/`SORT` names; no PK found in supplied PK TSV. | Emit full 10 latest columns with `VAR_DESC VARCHAR2(180)`. |
| DB-005 | `TB_CHECK_POINTS_CS` | db-diff active/exact and latest reverify include `EPROC00114`; latest TSV clarifies all flag columns are `VARCHAR2(2)`. | New write target for this page; replaces legacy `TB_CHECK_POINT_CORP` / `TB_CHECK_POINT_RC_CORP`. | Emit full CS checkpoint columns and PK. |
| DB-006 | `TB_CHECK_POINTS_CU` | latest reverify includes `EPROC00114`; db-diff markdown is stale at 13 columns. | Physical CU column exists, but page behavior still needs owner/RD decision because current save writes CS only; see PENDING-004. | Emit full latest CU table including `EPROC00114`. |
| DB-007 | `TB_CHECK_POINT_CORP`, `TB_CHECK_POINT_RC_CORP` | db-diff marks removed/unused and moved to new checkpoint tables. | Legacy evidence only; not active write target. | List as comments in `schema.sql`, not active DDL. |

## 7. Refactor / current implementation delta

| id | evidence | delta | handling |
| --- | --- | --- | --- |
| REF-001 | Refactor artifact has `epl-calc-c0-collateral-assessment`; current controller has select/save/info only; current save calls collateral score function before persistence. | Standalone Rate endpoint/auth row missing in current source, but shared score function path exists. | `PENDING-007`; keep endpoint in contract because PRD requires Rate and refactor artifact names it. |
| REF-002 | Current save request uses `isFinish`; PRD/legacy use `check`. | Contract vocabulary changed. | Accepted mapping in R6. |
| REF-003 | Current save implementation updates `TB_CHECK_POINTS_CS` only. | CU fallback is not implemented even though latest CU table has EPROC00114. | `PENDING-004`. |
| REF-004 | Current save evidence does not prove parent completion response. | PRD requires `isAllTabsCheck`. | `PENDING-008`; contract keeps response field. |
| REF-005 | Current save recalculates scores through function but does not prove standalone Rate response contract. | Rate-before-Finished must still be enforceable by BE. | R4/R5 plus `PENDING-007`. |
| REF-006 | Current shared score implementation uses integer conversion and zero fallback. | This can truncate decimal scores and hide invalid seed data. | `PENDING-010`; to-be contract requires BigDecimal-compatible fail-fast behavior. |

## 8. Error Codes

| code | owner endpoint | meaning | HTTP guidance |
| --- | --- | --- | --- |
| `0000` | all | Success. | 200 |
| `COMMON_MSG_SAVE_SUCCESS` | `epl-save-c0-collateral-assessment` | Save/Finished success message. | 200 |
| `E102` | all | Required field or validation failure in refactor contract. | 400 |
| `COMMON_MSG_ERROR_LON` | select/info/calc/save | Blank application number legacy-compatible message. | 400 |
| `MSG_DATA_NOT_FOUND` | info/calc/save pre-query | No application data found. | 404 |
| `MSG_OVER_COUNT_LIMIT` | info/select | Query result count exceeds legacy limit. | 429 |
| `MSG_QUERY_FAIL` | info/save/select | Query/save unexpected failure, legacy-compatible wording. | 500 |
| `COMMON_MSG_RATE_FAIL` | calc/save score phase | Rate calculation failure. | 500 |
| `E498` | all | Authorization/page-role failure. | 401 |

## 9. Traceability

| PRD | rules | QA |
| --- | --- | --- |
| REQ-001 | R1 | QA-001, QA-002 |
| REQ-002 | R2 | QA-003, QA-004, QA-005, QA-027, QA-028 |
| REQ-003 | R3 | QA-006, QA-007, QA-008, QA-028 |
| REQ-004 | R4 | QA-009, QA-010, QA-025, QA-026 |
| REQ-005 | R4, R5, R10 | QA-011, QA-012, QA-013 |
| REQ-006 | R6, R10 | QA-014, QA-015 |
| REQ-007 | R7 | QA-016, QA-017 |
| REQ-008 | R8 | QA-018 |
| REQ-009 | R8 | QA-019 |
| REQ-010 | R2, R4, R9, R10 | QA-020, QA-021, QA-022, QA-025, QA-026, QA-027, QA-028 |
| REQ-011 | R11 | Pending only; see PENDING-001..PENDING-010. |
