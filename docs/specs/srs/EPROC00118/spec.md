# SRS - EPROC00118 Corporate Scorecard

## Metadata
| Field | Value |
|---|---|
| Status | Draft |
| Owner | PM/SA/RD/QA review |
| funcId | EPROC00118 |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md` |
| Bundle | `docs/specs/srs/EPROC00118/` |
| Source baseline | PRD + Bible v1.1 + local db-diff + local refactor-spec |

## Scope
- 本 SRS 只涵蓋企金 C0 Corporate Scorecard 頁籤：初始化查詢、評分計算、Default 處理、AO/CR 欄位控制、Save/Finished、summary 與 checkpoint 連動。
- 不涵蓋 `TB_SCORE_CARD_PARAM_DETAIL` 參數維護畫面、個金 scorecard、財務評估頁、collateral scorecard 第二碼更新與 UI redesign。
- API 採 current backend/TB_API_AUTH exact RPC 命名與 POST：`epl-info-c0-corporateScorecard`、`epl-calc-c0-corporateScorecard`、`epl-save-c0-corporateScorecard`。

## Sources
| Source | Evidence |
|---|---|
| PRD core | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:178`-`185` maps FR-001 through FR-008. |
| PRD API/error | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:469`-`472`, `528`-`538`. |
| PRD DB | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:551`-`601`. |
| Bible | `docs/specs/bible/bible-eproposal.md:398`-`399`, `739`-`744`, `796`. |
| db-diff | `docs/db-diff/02_tables/TB_CORP_SCRCARD.md:38`-`150`; `docs/db-diff/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:38`-`47`; `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:45`-`67`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:38`-`53`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:38`-`50`. |
| refactor-spec | `docs/refactor-spec/02_modules/EPROC00118.md:19`-`21`; `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-info-c0-corporatescorecard.md:138`-`140`; `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-calc-c0-corporatescorecard.md:138`-`140`; `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:138`-`140`. |

## As-is Parity Evidence
| Area | Evidence | SRS triage |
|---|---|---|
| Legacy query / over-count / getRate / save codes | `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0118.java:56`, `70`, `88`-`94`, `142`-`168`; RC twin `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0218.java:56`, `70`, `88`-`94`, `142`-`168`. | as-is parity carried for behavior evidence; raw JSP action names are not API contract names. |
| Legacy score and checkpoint write | `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0118_mod.java:123`-`143`, `203`, `219`, `221`; RC twin `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0218_mod.java:123`-`143`, `203`, `220`, `222`. | checkpoint key migration is intentional evolution to new DB tables; RC mapping remains `PENDING-002`. |
| Current backend endpoints | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:38`, `45`, `52`. | API path must preserve `corporateScorecard` casing for TB_API_AUTH matching. |
| Current backend select-list endpoint | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:31`-`34`; `backend/src/main/java/khd/svc/epro/dto/request/corporate/corporateScorecard/SeleCorporateScorecardListRequest.java:9`-`20`; `backend/src/main/java/khd/svc/epro/dto/response/corporate/corporateScoreCard/SeleCorporateScorecardListResponse.java:11`-`64`; `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCorporateScorecardServiceImpl.java:76`-`91`. | Select-list contract uses current `ValueLabel` list DTO; range rows remain repository/DB evidence, not option API fields. |
| Current backend calc/save DTO behavior | `backend/src/main/java/khd/svc/epro/dto/response/corporate/corporateScoreCard/CalCorporateScoreCardResponse.java:9`-`17`; `backend/src/main/java/khd/svc/epro/dto/request/corporate/corporateScorecard/SaveCorporateScorecardRequest.java:14`-`124`; `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCorporateScorecardServiceImpl.java:138`-`149`, `195`, `229`, `256`. | SRS contract excludes unproven `scoreMap`, `pageCheckMap`, `checkpointTable`, and `isAllTabsCheck` response fields. |

## Endpoints
| Endpoint | Method | Purpose | Covers |
|---|---|---|---|
| `epl-sele-c0-corporateScorecard-list` | POST | 查詢 corporate scorecard 17 組 select option list | R2 |
| `epl-info-c0-corporateScorecard` | POST | 查詢 AO/CR scorecard map、comment 與 comment date | R1, R2, R5 |
| `epl-calc-c0-corporateScorecard` | POST | 依輸入項目與參數規則計算 risk level 與 scoreDatetime | R3, R8 |
| `epl-save-c0-corporateScorecard` | POST | Save/Finished 持久化 `TB_CORP_SCRCARD`, `TB_LON_SUMMARY_INFO` 與 checkpoint | R4, R6, R7 |

### R1 初始化查詢 **強制點: both**
covers-prd: FR-001

系統收到 `applicationNo` 後，必須查詢 `TB_LON_SUMMARY_INFO.APPLICATION_DATE` 作為 scorecard 參數版本日期，查詢既有 `TB_CORP_SCRCARD`，並載入 `TB_SCORE_CARD_PARAM_DETAIL` options；若無 scorecard 主檔仍回傳可新增的空 AO/CR 結構。`applicationNo` 空白回 `COMMON_MSG_ERROR_LON`，查無資料回 `MSG_DATA_NOT_FOUND`，查詢失敗回 `MSG_QUERY_FAIL`。

Evidence: PRD 初始化與錯誤碼見 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:216`-`223`, `528`-`531`; refactor query contract 見 `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-info-c0-corporatescorecard.md:152`-`160`.

Error-code contract: blank application returns `COMMON_MSG_ERROR_LON` (400); no case data returns `MSG_DATA_NOT_FOUND` (404); over-count returns `MSG_OVER_COUNT_LIMIT` (429); query failure returns `MSG_QUERY_FAIL` (500). This follows PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:528`-`531` and legacy `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0118.java:70`.

PRD FR-001 also names main borrower display and initial checkpoint state. Current backend `GetCorporateScorecardInfoResponse` does not expose `mainBorrowerName` or checkpoint response fields, so these are not added to the API contract in this SRS; the gap is tracked as `PENDING-013` for SA/RD disposition.

### R2 Scorecard 項目與欄位形狀 **強制點: both**
covers-prd: FR-002

API DTO 必須支援 AO/CR 各一組 scorecard map，至少包含 23 個 corporate scorecard items 的 code/score/input/risk/date/comment 欄位；select code 長度依 DB 為 2，risk level 長度依 DB 為 7，CR comment 依 DB 為 3000。

Evidence: PRD item list 見 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:248`-`270`; DB 欄位見 `docs/db-diff/02_tables/TB_CORP_SCRCARD.md:39`-`150`; refactor query response field lengths 見 `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-info-c0-corporatescorecard.md:85`-`112`.

### R3 Rate 計算 **強制點: BE**
covers-prd: FR-003, FR-008

系統必須以 `TB_SCORE_CARD_PARAM_DETAIL` 的 `VAR_NAME`、`VAR_CODE`、`LOW_RANGE`、`UP_RANGE`、`SCORE`、`ST_DATE`，配合申請日計算每個 numeric/select 項目的 score、total score、risk level 與 scoreDatetime。`getRate`/calc 不得改寫 DB；計算失敗回 `COMMON_MSG_RATE_FAIL` 或 `MSG_QUERY_FAIL`。

Evidence: PRD rate 與有效日規則見 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:296`, `450`; DB 參數表見 `docs/db-diff/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:38`-`47`; refactor calc contract 見 `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-calc-c0-corporatescorecard.md:84`-`110`, `186`-`195`.

Error-code contract: validation/module messages from `funcGetRate` are carried as 400 `module message` unless mapped to explicit platform code; generic rate failure returns `COMMON_MSG_RATE_FAIL`; query/data failure returns `MSG_QUERY_FAIL`. Calc must not write `TB_CORP_SCRCARD`, `TB_LON_SUMMARY_INFO`, or checkpoint tables.

### R4 Loan Default 90+ Days **強制點: both**
covers-prd: FR-004

若 AO 或 CR 的 `loanDefDayFlag = Y`，該角色 risk level 必須設為 `Default`，score 寫入 `-1`，評分欄位不可作為必填計算條件；系統需取得該角色 rating date。選擇 Default 時前端提示 `EPROI00118_MSG_DATE`，save 未選 default flag 時回 `EPROI00118_MSG_ERROR_FLG`。

Evidence: PRD default 行為見 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:323`-`336`, `647`-`651`; refactor save default flow 見 `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:169`-`182`, `191`-`192`.

Default contract: AO Default must set AO risk/score to `Default` / `-1`; legacy/current backend also sets CR risk/score/date from AO Default, but the business approval is tracked as `PENDING-011` because PRD marks DEC-002/TBD-010 open. Message contract carries `EPROI00118_MSG_DATE` for Default date prompt, `COMMON_MSG_RATE_FAIL` for Default date lookup failure, `EPROI00118_MSG_ERROR_FLG` for missing default flag, `COMMON_UI_PLEASE_SELECT` for required selection, and `COMMON_MSG_RATE` for Finished before Rate.

### R5 AO/CR role 與唯讀控制 **強制點: both**
covers-prd: FR-005

AO role `001/002` 可維護 AO 欄位與 Save/Finished，CR role `102/103` 可維護 CR 欄位、CR comment 與 Save/Finished；query mode 或非 editor 必須使 score/comment 欄位唯讀，mutating endpoint 不得只依前端隱藏按鈕。

Evidence: PRD role 控制見 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:354`-`356`; Bible role dictionary 見 `docs/specs/bible/bible-eproposal.md:398`-`399`, `796`; refactor save role validation 見 `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:156`, `170`-`180`.

Authorization contract: mutating calls must use the exact backend/TB_API_AUTH key `epl-save-c0-corporateScorecard` and must reject non-AO/non-CR roles with the platform access-denied response (current filter behavior: 401). Current backend relies on TB_API_AUTH and has no explicit `!isAO && !isCR` service reject (`backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCorporateScorecardServiceImpl.java:229`), so implementation closure is tracked as `PENDING-012`.

### R6 Save/Finished 持久化與交易一致性 **強制點: BE**
covers-prd: FR-006

AO Save/Finished must copy confirmed AO scorecard fields into the corresponding CR fields for legacy parity; only the `_AR_SCR` and `_INVENTORY_SCR` copy decision remains in `PENDING-005`.

Save/Finished 必須在單一 transaction 內 update-first/insert `TB_CORP_SCRCARD`、更新 `TB_LON_SUMMARY_INFO.CR_SCORE_CARD_COMPLETED`、更新新 checkpoint 表。任一步失敗必須 rollback。`isFinish=false` 對應 Save，`isFinish=true` 對應 Finished；此為 refactor-spec DTO 名稱，需對應 PRD legacy `check=Y/N`。

Evidence: PRD save rules 見 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:380`-`386`, `410`; refactor save SQL flow 見 `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:193`-`197`, `210`-`216`; SoT precedence for DB physical truth 見 `docs/spec-architecture.md:87`-`91`.

Response-code contract: blank `applicationNo` returns `COMMON_MSG_ERROR_LON`; successful save carries `COMMON_MSG_SAVE_SUCCESS`; save failure carries `COMMON_MSG_SAVE_FAIL`; query/data failure carries `MSG_QUERY_FAIL`. Save response must not expose unproven `checkpointTable`, `isAllTabsCheck`, or `pageCheckMap`; those remain DB/parent-frame side effects verified by QA and delta evidence.

### R7 父頁與 checkpoint 連動 **強制點: both**
covers-prd: FR-007

一般企金有擔/無擔分別更新 `TB_CHECK_POINTS_CS.EPROC00118` 或 `TB_CHECK_POINTS_CU.EPROC00118`；續約/變更 legacy `EPROC0_0218` 在新 DB snapshot 未出現獨立 RC 新 checkpoint 欄位，需在 `@PENDING` 中交 owner 裁是否仍映射同一 `EPROC00118` 欄或另建 RC 分流。父頁只有在 Finished 且 all-tabs check 通過時可標示 done。

Evidence: PRD legacy checkpoint table 見 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:167`-`172`, `425`-`435`; old table removed hints 見 `docs/db-diff/02_tables/TB_CHECK_POINT_CORP.md:6`-`13`, `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:6`-`13`; new checkpoint columns 見 `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:38`-`53`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:38`-`50`.

### R8 Numeric precision and conversion **強制點: both**
covers-prd: FR-003, FR-006, FR-008

`CUR_RATIO` 畫面以百分比輸入，查詢時 DB 值乘以 100，儲存前除以 100；`AO_CUR_RATIO`/`CR_CUR_RATIO` DB 型別為 `NUMBER(3,2)`，D/E 為 `NUMBER(9,2)`，total asset/total loan amount 為 `NUMBER(19,2)`，debt service ratio 為 `NUMBER(6,2)`，AO/CR score 為 `NUMBER(7,2)`。格式檢核需在 BE enforce，不得只靠 FE。

Evidence: PRD conversion 見 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:223`, `384`, `630`; DB precision 見 `docs/db-diff/02_tables/TB_CORP_SCRCARD.md:139`-`150`; refactor save validation 見 `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:157`-`159`, `185`-`187`.

Precision policy: no silent rounding or truncation is allowed in BE. Inputs exceeding DB precision/scale or refactor DTO max length must be rejected with validation error before DB write. `CUR_RATIO` is the documented conversion exception: UI percent is divided by 100 for DB storage and multiplied by 100 for display. Range matching uses `LOW_RANGE <= input < UP_RANGE`; score fields are integer precision (`NUMBER(3,0)`).

## 新舊 DB / 更動 delta
| Delta | 判定 | SRS action | Source |
|---|---|---|---|
| DB-D1 `TB_CORP_SCRCARD` active/exact，113 欄，PK `APPLICATION_NO`。 | carried | `schema.sql` 以新 DB 欄位/型別為物理契約；API 保留 AO/CR 兩套 map。 | `docs/db-diff/02_tables/TB_CORP_SCRCARD.md:13`-`16`, `32`, `38`-`150` |
| DB-D2 `TB_SCORE_CARD_PARAM_DETAIL` active/exact，但 `transpose_method=重新寫入`。 | changed | 規格承載欄位與有效日查詢；參數資料 seed/正式 option label 不在本 SRS 自裁。 | `docs/db-diff/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:9`-`16`, `38`-`47`; PRD TBD-001 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:55` |
| DB-D3 `TB_LON_SUMMARY_INFO` active/exact，`CR_SCORE_CARD_COMPLETED` 欄位為 `VARCHAR2(2 BYTE)`。 | carried + @PENDING semantics | 物理欄位帶入 schema；兩碼語意與跨 scorecard owner 裁列 `PENDING-001`。 | `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:11`-`16`, `67`; PRD TBD-002 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:56` |
| DB-D4 legacy `TB_CHECK_POINT_CORP/CU/RC_*` 在 db-diff 標 `removed_or_unused`，note 指向 `TB_CHECK_POINTS_CS/CU`。 | changed | 新契約使用 `TB_CHECK_POINTS_CS`/`TB_CHECK_POINTS_CU` 與欄位 `EPROC00118`；舊表只保留為 migration note。 | `docs/db-diff/02_tables/TB_CHECK_POINT_CORP.md:6`-`13`; `docs/db-diff/02_tables/TB_CHECK_POINT_CU.md:6`-`13`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:6`-`13`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:6`-`13`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:10`-`13`, `51`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:10`-`13`, `49` |
| DB-D5 PRD legacy `EPROC0_0218` RC checkpoint 未在 new DB snapshot 出現 `EPROC00218` 或 RC-specific active table 欄。 | @PENDING | 不自建新欄；暫列 `PENDING-002`，待 SA/RD 決定 RC 是否映射同欄 `EPROC00118` 或另行 DB 變更。 | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:167`-`170`; old RC columns `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:50`, `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:49`; new DB `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:51`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:49` |
| AUTH-D1 `TB_API_AUTH` is active/exact, note `重構新增`, transpose method `重新寫入`. | changed | Contract uses exact backend API IDs including `epl-save-c0-corporateScorecard`; row-level precheck says EPROC00118 C0 target rows are not present yet while i0 source rows are present / will insert, so auth seed closure stays in `PENDING-012`. | `docs/db-diff/02_tables/TB_API_AUTH.md:10`-`16`, `32`, `38`-`40`; row precheck `docs/build-tasks/c0-authz-sql-findings.md:61`-`64`, `134`-`137`; backend controller `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:38`, `45`, `52` |
| REF-D1 refactor latest 僅有 BE corporate query/calculate/save 三 artifacts，無 FE artifact。 | carried | SRS endpoint 以 BE latest 為契約，FE 行為由 PRD/source parity 描述，不宣稱已有 FE spec。 | `docs/refactor-spec/02_modules/EPROC00118.md:3`-`21` |
| REF-D2 PRD legacy `query/getRate/getDate/save` 對應 refactor `info/calc/save` 三 POST RPC；`getDate` 不獨立成 endpoint。 | changed | `getDate` 行為折入 Default flow 與 save/calc date response；Default date failure still carries `COMMON_MSG_RATE_FAIL`; 不另建 date RPC。 | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:469`-`472`, `534`; refactor endpoints `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-calc-c0-corporatescorecard.md:138`-`140` |
| REF-D3 refactor save 使用 `isFinish`，PRD legacy 使用 `check=Y/N`。 | changed | OpenAPI 使用 `isFinish`; spec 明確 mapping：Save=`false`, Finished=`true`; legacy `check` 只作 migration note。 | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:380`; refactor `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:154`, `195` |
| REF-D4 refactor BE 對 Finished/CR comment/required fields 有比 PRD legacy 更強的後端驗證。 | changed | 作為 to-be BE enforce；是否修正 legacy defect 的流程影響列 `PENDING-003` 供 SA/RD 確認。 | PRD TBD-003 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:57`; refactor `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:156`, `170`-`180` |
| REF-D5 refactor calc has field typo signal `trans12mMnCode` / `debtRati` in extracted text. | @PENDING | OpenAPI uses canonical `trans12MonCode` and `debtRatio`; source typo requires RD confirmation against original doc/code. | `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-calc-c0-corporatescorecard.md:107`, `163`, `210` |

## Parity Triage
| Item | Triage | Decision |
|---|---|---|
| `EPROC0_0118/0218` action names (`query/getRate/getDate/save`) vs refactor RPC names | intentional evolution | Contract uses backend exact RPC names; legacy action names remain as-is evidence only. |
| old checkpoint tables `TB_CHECK_POINT_CORP/CU/RC_*` vs new `TB_CHECK_POINTS_CS/CU` | DB-schema triage | New DB snapshot wins for physical schema; RC branch mapping remains `PENDING-002`. |
| backend calc returns only `riskLevel` and `scoreDatetime` | regression guard | SRS excludes legacy `totalScore/scoreMap` from calc response until backend/refactor contract proves otherwise. |
| backend save returns empty map | regression guard | SRS verifies save through response code and DB side effects, not unproven response fields. |
| backend non-AO roles fall into CR branch if TB_API_AUTH misses | regression/security blocker | SRS requires platform access-denied response (current contract: 401) and explicit BE rejection; implementation closure tracked as `PENDING-012`. |

## @PENDING
| ID | Status | Owner | Blocking? | Evidence | Required decision |
|---|---|---|---|---|---|
| PENDING-001 | @PENDING | PM/SA/風控 | Yes for final approval | PRD TBD-002 and DEC-004: `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:56`, `743`; pending-register E1/E2 context `docs/pending-register.md:17`-`18` | Define two-character `CR_SCORE_CARD_COMPLETED` semantics across corporate scorecard and collateral/personal scorecard. |
| PENDING-002 | @PENDING | SA/RD/DBA | Yes for RC branch | PRD has `EPROC0_0218` RC checkpoint `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:169`-`170`; new DB only exposes `EPROC00118` in `TB_CHECK_POINTS_CS/CU` at `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:51`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:49` | Decide whether renewal/change corporate scorecard reuses `EPROC00118` checkpoint or needs separate DB/API branch. |
| PENDING-003 | @PENDING | SA/RD | Yes for validation parity | PRD TBD-003 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:57`; refactor save validation `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:156`-`159` | Confirm to-be BE validation strictness for required fields, Rate-before-Finished, and CR comment. Numeric precision is resolved by db-diff/schema and is not pending. |
| PENDING-004 | @PENDING | PM/SA | No for draft, Yes for role approval | PRD TBD-004 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:58`; Bible role dictionary includes `003` at `docs/specs/bible/bible-eproposal.md:796` | Decide whether role `003` can edit AO side on this page. |
| PENDING-005 | @PENDING | SA/RD | Yes if preserving legacy copy behavior | PRD TBD-005 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:59` | Decide whether AO-to-CR copy should include `_AR_SCR` and `_INVENTORY_SCR` or intentionally preserve legacy omission. |
| PENDING-006 | @PENDING | RD | No for draft | refactor typo signals `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-calc-c0-corporatescorecard.md:107`, `163`, `210` | Confirm canonical DTO property spellings in implementation. |
| PENDING-007 | @PENDING | PM/SA/RD | Yes for seed approval | PRD TBD-001 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:55`; `docs/db-diff/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:38`-`47` | Approve scorecard option labels, scores, risk levels, and migration seed source. |
| PENDING-008 | @PENDING | SA/RD | Yes for RC save parity | PRD TBD-006 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:60`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0218_mod.java:143`-`203` | Decide whether legacy RC save missing where-field behavior is defect to fix or behavior to preserve. |
| PENDING-009 | @PENDING | SA/RD/QA | No for draft, Yes before regression signoff | PRD TBD-007 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:61` | Decide whether CR late-transaction DOM-id behavior is dead code or required UI linkage. |
| PENDING-010 | @PENDING | SA/RD/DBA | Yes for parameter effective-date logic | PRD TBD-009 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:63`; `docs/db-diff/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:46`-`47` | Decide whether scorecard parameter lookup must also apply `END_DATE` or only max `ST_DATE <= APP_DATE`. |
| PENDING-011 | @PENDING | PM/SA/Risk | Yes for Default business approval | PRD TBD-010 and DEC-002 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:64`, `741`; current backend `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCorporateScorecardServiceImpl.java:214`-`226` | Confirm AO Default may automatically set CR risk/score/date without CR re-rating. |
| PENDING-012 | @PENDING | RD/Security | No for SRS draft, Yes before implementation signoff | D-axis evidence: `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCorporateScorecardServiceImpl.java:229`; controller path `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:52`; auth row precheck `docs/build-tasks/c0-authz-sql-findings.md:61`-`64`, `134`-`137` | Add or verify explicit BE rejection for non-AO/non-CR save roles and insert/verify EPROC00118 `TB_API_AUTH` rows. |
| PENDING-013 | @PENDING | SA/RD | No for SRS draft, Yes before UI/API signoff | PRD FR-001 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:216`-`223`; current DTO `backend/src/main/java/khd/svc/epro/dto/response/corporate/corporateScoreCard/GetCorporateScorecardInfoResponse.java:8`-`24` | Decide whether main borrower name and initial checkpoint state are supplied by this API, parent page, or separate API. |
| PENDING-014 | @PENDING | SA/RD/QA | No for SRS draft, Yes before UI regression signoff | PRD TBD-008 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:62` | Decide whether legacy UI display differences around default-to-N input length/decimal need compatibility handling; SRS numeric precision itself follows OpenAPI/schema and is not pending. |
| PENDING-015 | @PENDING | SA/RD | No for SRS draft, Yes before API signoff | PRD calc response `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:469`-`472`; current backend response `backend/src/main/java/khd/svc/epro/dto/response/corporate/corporateScoreCard/CalCorporateScoreCardResponse.java:9`-`17` | Decide whether `epl-calc-c0-corporateScorecard` must return `totalScore`, or whether current backend response with only `riskLevel` and `scoreDatetime` is accepted. |

## Traceability Matrix
| PRD | SRS | QA |
|---|---|---|
| FR-001 | R1 | QA-001, QA-002, QA-002A, QA-003, QA-004, QA-005, QA-006 |
| FR-002 | R2 | QA-007, QA-008, QA-009, QA-009A, QA-009B, QA-035, QA-036 |
| FR-003 | R3, R8 | QA-010, QA-010A, QA-011, QA-011A, QA-012, QA-013, QA-031, QA-032, QA-033, QA-034 |
| FR-004 | R4 | QA-014, QA-015, QA-016, QA-017, QA-017A, QA-017B, QA-017C, QA-017D, QA-035, QA-036 |
| FR-005 | R5 | QA-017B, QA-018, QA-019, QA-020, QA-020A, QA-021 |
| FR-006 | R6, R8 | QA-017A, QA-017D, QA-022, QA-022A, QA-023, QA-024, QA-025, QA-025A, QA-030, QA-031, QA-032, QA-033 |
| FR-007 | R7 | QA-025A, QA-026, QA-027, QA-028, QA-029, QA-030 |
| FR-008 | R3, R8 | QA-010, QA-011A, QA-013, QA-034 |

## NFR
- Security: Save/Finished authorization must be enforced by BE role/context, not only FE disabled state.
- Data integrity: Save/Finished must be one transaction across `TB_CORP_SCRCARD`, `TB_LON_SUMMARY_INFO`, and `TB_CHECK_POINTS_CS/CU`.
- Privacy: do not log full scorecard payload or employee names; log action, masked application number, role, and result code only.
- Performance: query loads fixed scorecard parameter sets and must complete within platform AJAX timeout.
