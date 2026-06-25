# SRS - EPROC00118 Corporate Scorecard

# ───────────────── Contract（做什麼；to-be only、可純掃開發）─────────────────

## Metadata
| Field | Value |
|---|---|
| funcId | EPROC00118 |
| Status | 規格定版: Approved / 實作完成: done (owner 2026-06-25; RD/DBA closeout 2026-06-20 + 本輪 rd-done) |
| Owner | PM/SA/RD/QA review |
| PRD | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md` |
| Bundle | `docs/specs/srs/EPROC00118/` |
| Source baseline | PRD + Bible v1.1 + local db-diff + local refactor-spec |
| Output files | `spec.md`, `openapi.yaml`, `schema.sql`（`qa-cases.md` 2026-06-24 隨 QA 暫拔除） |
| N-axis review | （兩半轉換 2026-06-25：改 canonical Contract/Appendix 結構、Traceability 段移除（追溯靠 covers-prd）、各 Rn 加 [ev→Rn]；只重排、不改語意。原 2026-06-20 RD/DBA closeout + 本輪 rd-done 結論不變。） |

## Scope
- 本 SRS 只涵蓋企金 C0 Corporate Scorecard 頁籤：初始化查詢、評分計算、Default 處理、AO/CR 欄位控制、Save/Finished、summary 與 checkpoint 連動。
- 不涵蓋 `TB_SCORE_CARD_PARAM_DETAIL` 參數維護畫面、個金 scorecard、財務評估頁、collateral scorecard 第二碼更新與 UI redesign。
- API 採 current backend/TB_API_AUTH exact RPC 命名與 POST：`epl-sele-c0-corporateScorecard-list`、`epl-info-c0-corporateScorecard`、`epl-calc-c0-corporateScorecard`、`epl-save-c0-corporateScorecard`。

## Endpoints
| Endpoint | Method | Purpose | Rules |
|---|---|---|---|
| `epl-sele-c0-corporateScorecard-list` | POST | 查詢 corporate scorecard 17 組 select option list | R2 |
| `epl-info-c0-corporateScorecard` | POST | 查詢 main borrower、checkpoint status、AO/CR scorecard map、comment 與 comment date | R1, R2, R5 |
| `epl-calc-c0-corporateScorecard` | POST | 依輸入項目與參數規則計算 risk level 與 scoreDatetime | R3, R8 |
| `epl-save-c0-corporateScorecard` | POST | Save/Finished 持久化 `TB_CORP_SCRCARD`, `TB_LON_SUMMARY_INFO` 與 checkpoint | R4, R6, R7 |

## Rules
> 每條只寫 **to-be 契約**（系統最終應如何）；佐證/出處/as-is/決策 → 下半 `Rule Evidence`，用 `[ev→Rn]` 指過去。

### R1 初始化查詢 - 強制點: both
covers-prd: FR-001

系統收到 `applicationNo` 後，必須查詢 `TB_LON_SUMMARY_INFO.APPLICATION_DATE` 作為 scorecard 參數版本日期，查詢既有 `TB_CORP_SCRCARD`，並載入 `TB_SCORE_CARD_PARAM_DETAIL` options；若無 scorecard 主檔仍回傳可新增的空 AO/CR 結構。`applicationNo` 空白回 `COMMON_MSG_ERROR_LON`，查無資料回 `MSG_DATA_NOT_FOUND`，查詢失敗回 `MSG_QUERY_FAIL`。

Error-code contract: blank application returns `COMMON_MSG_ERROR_LON` (400); no case data returns `MSG_DATA_NOT_FOUND` (404); over-count returns `MSG_OVER_COUNT_LIMIT` (429); query failure returns `MSG_QUERY_FAIL` (500).

`epl-info-c0-corporateScorecard` must supply the full tab initialization contract. The response must include `mainBorrowerName` from `TB_MAIN_BORROWER_INFO_CORP.MAIN_BORROWER_NAME` and `checkpointStatus` from `TB_CHECK_POINTS_CS.EPROC00118` or `TB_CHECK_POINTS_CU.EPROC00118` after the CS/CU branch is selected by `TB_LON_SUMMARY_INFO.LON_ATTRIBUTE + SECURE_ATTRIBUTE`. [ev→R1]

### R2 Scorecard 項目與欄位形狀 - 強制點: both
covers-prd: FR-002

API DTO 必須支援 AO/CR 各一組 scorecard map，至少包含 23 個 corporate scorecard items 的 code/input/risk/date/comment 欄位；score 值為 BE function / DB side-effect 驗證，不新增未由 current info/save DTO 證明的 response score fields。select code 長度依 DB 為 2，risk level 長度依 DB 為 7，CR comment 依 DB 為 3000。

Late-transaction UI linkage is part of the to-be contract for both AO and CR through the canonical fields `MAX_OVERDUE_CODE` and `TRANS_12MON_CODE`: selecting `MAX_OVERDUE_CODE=01` sets/disables `TRANS_12MON_CODE=01`, selecting `MAX_OVERDUE_CODE=07` sets/disables `TRANS_12MON_CODE=05`, and reverse selection of `TRANS_12MON_CODE=01/05` synchronizes and disables `MAX_OVERDUE_CODE` to `01/07`. [ev→R2]

### R3 Rate 計算 - 強制點: BE
covers-prd: FR-003, FR-008

系統必須以 `TB_SCORE_CARD_PARAM_DETAIL` 的 `VAR_NAME`、`VAR_CODE`、`LOW_RANGE`、`UP_RANGE`、`SCORE`、`ST_DATE`，配合申請日計算每個 numeric/select 項目的 score、total score、risk level 與 scoreDatetime。Parameter version lookup must use `MAX(ST_DATE <= APP_DATE)` and must not apply `END_DATE` as an EPROC00118 runtime filter; `END_DATE` remains seed metadata only. `getRate`/calc 不得改寫 DB；計算失敗回 `COMMON_MSG_RATE_FAIL` 或 `MSG_QUERY_FAIL`。

Error-code contract: validation/module messages from `funcGetRate` are carried as 400 `module message` unless mapped to explicit platform code; generic rate failure returns `COMMON_MSG_RATE_FAIL`; query/data failure returns `MSG_QUERY_FAIL`. Calc must not write `TB_CORP_SCRCARD`, `TB_LON_SUMMARY_INFO`, or checkpoint tables.

`scoreDatetime` must be formatted as `dd/MM/yyyy HH:mm:ss` using an explicit Asia/Taipei / UTC+8 clock; reliance on JVM/container default timezone is rejected.

`TB_SCORE_CARD_PARAM_DETAIL.SCORE` is physically `VARCHAR2(10)`. BE must convert it with numeric parsing before summing; a nonnumeric `SCORE` seed is a data/query failure and must return `MSG_QUERY_FAIL` with safe diagnostic logging, not silently coerce to zero (fail-fast). [ev→R3]

### R4 Loan Default 90+ Days - 強制點: both
covers-prd: FR-004

若 AO 或 CR 的 `loanDefDayFlag = Y`，該角色 risk level 必須設為 `Default`，score 寫入 `-1`，評分欄位不可作為必填計算條件；系統需取得該角色 rating date。選擇 Default 時前端提示 `EPROI00118_MSG_DATE`，save 未選 default flag 時回 `EPROI00118_MSG_ERROR_FLG`。

Default contract: AO Default must set AO risk/score to `Default` / `-1`; AO Finished with AO Default also sets CR risk/score/date to `Default` / `-1` / the AO rating date without requiring CR re-rating first. Message contract carries `EPROI00118_MSG_DATE` for Default date prompt, `COMMON_MSG_RATE_FAIL` for Default date lookup failure, `EPROI00118_MSG_ERROR_FLG` for missing default flag, `COMMON_UI_PLEASE_SELECT` for required selection, and `COMMON_MSG_RATE` for Finished before Rate. Strict BE validation is the to-be contract: Finished must be rejected when required scorecard fields, required `riskLevel`/`actionDate`, Rate-before-Finished state, or CR Finished comment are missing, even if the FE validation is bypassed. [ev→R4]

### R5 AO/CR role 與唯讀控制 - 強制點: both
covers-prd: FR-005

AO role `001/002` 可維護 AO 欄位與 Save/Finished，CR role `102/103` 可維護 CR 欄位、CR comment 與 Save/Finished；query mode 或非 editor 必須使 score/comment 欄位唯讀，mutating endpoint 不得只依前端隱藏按鈕。Role `003` is not an AO editor for this page, despite the broader AO role pool in `EPRO_Z0Z006`.

Authorization contract: mutating calls must use the exact backend/TB_API_AUTH key `epl-save-c0-corporateScorecard` and must reject non-AO/non-CR roles with the platform access-denied response (current filter behavior: 401). Two layers are required before QA regression or any testing deployment: the four EPROC00118 `TB_API_AUTH` seeds must exist, and save must also have an explicit service-level reject for non-AO/non-CR roles.

Save authorization is side-scoped, not merely endpoint-scoped. BE must derive the writable side from the authenticated session role: AO roles may write AO-side fields only, and CR roles may write CR-side fields and CR comment only. Client-supplied non-writable side maps are not authoritative and must not update protected columns; if a request attempts to tamper with the non-writable side, BE must reject the save with the platform role-authorization response and leave scorecard, summary, and checkpoint data unchanged. AO-to-CR copy/reset/default side effects are allowed only as server-side rules described in R4/R6, never as client-provided CR writes from an AO request.

Read/query endpoints use independent `TB_API_AUTH` rows, not session-only authorization: `epl-sele-c0-corporateScorecard-list`, `epl-info-c0-corporateScorecard`, and `epl-calc-c0-corporateScorecard` each require their own endpoint auth seed. If a future design removes any read endpoint from `TB_API_AUTH`, the replacement guard must be explicitly approved before signoff. [ev→R5]

### R6 Save/Finished 持久化與交易一致性 - 強制點: BE
covers-prd: FR-006

`CR_SCORE_CARD_COMPLETED` two-character semantics: first character is this corporate scorecard completion status and second character is the other scorecard completion status from `EPROC00114/00214`. AO Save/re-save resets the full value to `NN`. CR Save (`isFinish=false`) writes first character `N` and preserves the second character. CR Finished (`isFinish=true`) writes first character `Y` and preserves the second character. AO-to-CR copy must include `_AR_SCR` and `_INVENTORY_SCR` with their matching `_AR_CODE` and `_INVENTORY_CODE`, so CR code/score pairs remain consistent.

Save/Finished 必須在單一 transaction 內 update-first/insert `TB_CORP_SCRCARD`、更新 `TB_LON_SUMMARY_INFO.CR_SCORE_CARD_COMPLETED`、更新新 checkpoint 表。任一步失敗必須 rollback。`isFinish=false` 對應 Save，`isFinish=true` 對應 Finished；此為 refactor-spec DTO 名稱，需對應 PRD legacy `check=Y/N`。

Scorecard, summary, and checkpoint updates locate the case with one `APPLICATION_NO` condition.

Response-code contract: blank `applicationNo` returns `COMMON_MSG_ERROR_LON`; successful save carries `COMMON_MSG_SAVE_SUCCESS`; save failure carries `COMMON_MSG_SAVE_FAIL`; query/data failure carries `MSG_QUERY_FAIL`. Save response must not expose unproven `checkpointTable`, `isAllTabsCheck`, or `pageCheckMap`; those remain DB/parent-frame side effects verified by QA and delta evidence. [ev→R6]

### R7 父頁與 checkpoint 連動 - 強制點: both
covers-prd: FR-007

一般企金有擔/無擔分別更新 `TB_CHECK_POINTS_CS.EPROC00118` 或 `TB_CHECK_POINTS_CU.EPROC00118`；續約/變更 legacy `EPROC0_0218` 在新系統與一般 corporate scorecard 合併，共用同一 `EPROC00118` checkpoint 欄位，不另建 RC-specific active table/column。父頁只有在 Finished 且 all-tabs check 通過時可標示 done。

Checkpoint mapping: CU-return/reset behavior must update `TB_CHECK_POINTS_CU.EPROC00118` for CU cases and must not only clear `TB_CHECK_POINTS_CS`; RC renewal/change reuses the same `EPROC00118` field selected by the CS/CU case branch. [ev→R7]

### R8 Numeric precision and conversion - 強制點: both
covers-prd: FR-003, FR-006, FR-008

`CUR_RATIO` 畫面以百分比輸入，查詢時 DB 值乘以 100，儲存前除以 100；`AO_CUR_RATIO`/`CR_CUR_RATIO` DB 型別為 `NUMBER(3,2)`，D/E 為 `NUMBER(9,2)`，total asset/total loan amount 為 `NUMBER(19,2)`，debt service ratio 為 `NUMBER(6,2)`，AO/CR score 為 `NUMBER(7,2)`。格式檢核需在 BE enforce，不得只靠 FE。

Precision policy: no silent rounding or truncation is allowed in BE. Inputs exceeding DB precision/scale or refactor DTO max length must be rejected with validation error before DB write. `CUR_RATIO` is the documented conversion exception: UI percent is limited to integer input with no decimal places, then divided by 100 for DB storage and multiplied by 100 for display; a value such as `80.5` is invalid. Range matching uses `LOW_RANGE <= input < UP_RANGE`; derived item score fields are integer precision (`NUMBER(3,0)`) and must reject values above `999` before DB write. `totalScore` / `AO_SCORE` / `CR_SCORE` must fit `NUMBER(7,2)`; if approved seed data can produce a larger total, BE must reject with `COMMON_MSG_RATE_FAIL` rather than write an overflowing value. Initial load and Default Y-to-N reset must use the same SRS/OpenAPI/DB precision rules, with no compatibility mode for the legacy mismatch. [ev→R8]

## NFR
- Security: Save/Finished authorization must be enforced by BE role/context, not only FE disabled state. EPROC00118 `TB_API_AUTH` seeds for select-list/info/calc/save endpoints were verified against `OVSLXLON02` on 2026-06-20; future missing seed rows are regressions. `epl-save-c0-corporateScorecard` additionally rejects non-AO/non-CR roles inside the save service so a seed/filter miss cannot fall into the CR branch.
- Data integrity: Save/Finished must be one transaction across `TB_CORP_SCRCARD`, `TB_LON_SUMMARY_INFO`, and `TB_CHECK_POINTS_CS/CU`.
- Privacy: do not log full scorecard payload or employee names; log action, masked application number, role, and result code only.
- Performance: query loads fixed scorecard parameter sets and must complete within the platform standard AJAX timeout. The PRD platform-timeout threshold is accepted; no page-specific p95/second target is defined for EPROC00118.

## Hard Boundaries
- 可先修（與 @PENDING 無關）：R1–R8 全部已由 owner 2026-06-19/2026-06-20 決策關閉，無開放 @PENDING；RD 可依契約全面實作。
- 待 TBD（涉 @PENDING）：無（本包所有 TBD 已關，見附錄 Decision Register）。
- 摘要：本包規格定版 Approved、實作 done；RD 變更時以本 spec.md 為權威。

# ───────────────── Appendix — Evidence & Decisions（為什麼/出處/風險）─────────────────

## Appendix — Evidence & Decisions
> 本半＝稽核/審查讀者用；契約推導的所有佐證。實作者開發時可後讀。

## Source Evidence
| Source | Evidence |
|---|---|
| PRD core | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:178`-`185` maps FR-001 through FR-008. |
| PRD API/error | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:469`-`472`, `528`-`538`. |
| PRD DB | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:551`-`601`. |
| Bible | `docs/specs/bible/bible-eproposal.md:398`-`399`, `739`-`744`, `796`. |
| db-diff | `docs/db-diff/02_tables/TB_CORP_SCRCARD.md:38`-`150`; `docs/db-diff/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:38`-`47`; `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:45`-`67`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:38`-`53`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:38`-`50`. |
| refactor-spec | `docs/refactor-spec/02_modules/EPROC00118.md:19`-`21`; `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-info-c0-corporatescorecard.md:138`-`140`; `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-calc-c0-corporatescorecard.md:138`-`140`; `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:138`-`140`. |

## BR/SC Coverage
| Source rule | SRS disposition |
|---|---|
| BR-001 C0 Corporate Scorecard tab | carried by scope and endpoints. |
| BR-002 `EPROC0_0118` / `EPROC0_0218` parity | carried; RC checkpoint mapping is resolved as shared `EPROC00118`; RC duplicate where-field behavior is treated as legacy redundancy and not preserved. |
| BR-003 parameter version by application date | carried by R1/R3. Owner decision on 2026-06-20 follows PRD/source/current backend: parameter version lookup uses `MAX(ST_DATE <= APP_DATE)` only; `END_DATE` is seed metadata and not an EPROC00118 runtime filter. |
| BR-004 select item `VAR_CODE` / `SCORE` | carried by R2/R3; `SCORE` string-to-number conversion is specified in R3. |
| BR-005 numeric range scoring | carried by R3/R8 and QA-013/QA-034. |
| BR-006 total score sum | carried as internal calculation only. Owner decision on 2026-06-20 accepts the current public calc response with `riskLevel` and `scoreDatetime` only; `totalScore` is not exposed by `epl-calc-c0-corporateScorecard`. |
| BR-007 risk level from `COR_RISK_LV` | carried by R3 and QA-010. |
| BR-008 Default sets risk/score | carried by R4. Owner decision on 2026-06-20 accepts the legacy/current backend AO-to-CR Default side effect: AO Finished with AO Default also sets CR risk/score/date to `Default` / `-1` / AO rating date. |
| BR-009 Rate state clears after field change | carried by QA-017. |
| BR-010/BR-011 late transaction linkage | carried by R2/R4 and QA-035/QA-036. Owner decision on 2026-06-20 keeps the canonical `MAX_OVERDUE_CODE` / `TRANS_12MON_CODE` linkage and treats the legacy `CR_TRA_LST_MON_CODE*` / `CR_MAX_DUE_CODE*` block as dead DOM-id code, not a to-be requirement. |
| BR-012 AO save resets `CR_SCORE_CARD_COMPLETED` | carried; owner decision on 2026-06-19 requires AO Save/re-save to reset the full value to `NN`. |
| BR-013 CR save/finished updates first character | carried; first character is this corporate scorecard, second character is the other scorecard. |
| BR-014 `CUR_RATIO` percent conversion | carried by R8; SRS now limits UI percent to integer input. |
| BR-015 update-first save | carried by R6 and QA-022A. |
| BR-016 single transaction save | carried by R6 and QA-025/QA-025A. |
| SC/E1 CU-return checkpoint split | carried; CU return/reset must update `TB_CHECK_POINTS_CU.EPROC00118`, not only CS. |
| SC/E2 full-column overwrite | carried; AO Save/re-save intentionally resets full `CR_SCORE_CARD_COMPLETED` value to `NN`. |

## As-is Parity Evidence
| Area | Evidence | SRS triage |
|---|---|---|
| Legacy query / over-count / getRate / save codes | `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0118.java:56`, `70`, `88`-`94`, `142`-`168`; RC twin `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0218.java:56`, `70`, `88`-`94`, `142`-`168`. | as-is parity carried for behavior evidence; raw JSP action names are not API contract names. |
| Legacy score and checkpoint write | `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0118_mod.java:123`-`143`, `203`, `219`, `221`; RC twin `legacy-epro/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0218_mod.java:123`-`143`, `203`, `220`, `222`. | checkpoint key migration is intentional evolution to new DB tables; owner decision maps RC to the shared `EPROC00118` checkpoint field. |
| Current backend endpoints | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:38`, `45`, `52`. | API path must preserve `corporateScorecard` casing for TB_API_AUTH matching. |
| Current backend select-list endpoint | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:31`-`34`; `backend/src/main/java/khd/svc/epro/dto/request/corporate/corporateScorecard/SeleCorporateScorecardListRequest.java:9`-`20`; `backend/src/main/java/khd/svc/epro/dto/response/corporate/corporateScoreCard/SeleCorporateScorecardListResponse.java:11`-`64`; `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCorporateScorecardServiceImpl.java:76`-`91`. | Select-list contract uses current `ValueLabel` list DTO; range rows remain repository/DB evidence, not option API fields. |
| Current backend calc/save DTO behavior | `backend/src/main/java/khd/svc/epro/dto/response/corporate/corporateScoreCard/CalCorporateScoreCardResponse.java:9`-`17`; `backend/src/main/java/khd/svc/epro/dto/request/corporate/corporateScorecard/SaveCorporateScorecardRequest.java:14`-`124`; `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCorporateScorecardServiceImpl.java:138`-`149`, `195`, `229`, `256`. | SRS contract excludes unproven `scoreMap`, `pageCheckMap`, `checkpointTable`, and `isAllTabsCheck` response fields. |

## Trade-offs
- Excluding legacy `totalScore`/`scoreMap` from the public calc response keeps the contract aligned to current backend/PRD evidence; `totalScore` remains a server-side calculation used to derive risk level and saved score values.
- Mapping RC renewal/change to the shared `EPROC00118` checkpoint field (instead of a new RC-specific table/column) keeps the schema aligned to the new DB snapshot and avoids carrying legacy RC redundancy.

## DB Reconcile / Delta
| Delta | 判定 | SRS action | Source |
|---|---|---|---|
| DB-D1 `TB_CORP_SCRCARD` active/exact，113 欄，PK `APPLICATION_NO`。 | carried | `schema.sql` 以新 DB 欄位/型別為物理契約；API 保留 AO/CR 兩套 map。 | `docs/db-diff/02_tables/TB_CORP_SCRCARD.md:13`-`16`, `32`, `38`-`150` |
| DB-D2 `TB_SCORE_CARD_PARAM_DETAIL` active/exact，但 `transpose_method=重新寫入`。 | changed | Owner decision on 2026-06-19 adopts the current DB snapshot as the seed baseline for option labels, scores, ranges, and risk levels; owner decision on 2026-06-20 keeps EPROC00118 runtime lookup on `MAX(ST_DATE <= APP_DATE)` only, with `END_DATE` as seed metadata. | `docs/db-diff/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:9`-`16`, `38`-`47`; PRD TBD-001/TBD-009 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:55`, `63`; seed verification `docs/build-tasks/done/pilot-srs-pending-verification.sql:155`-`196` |
| DB-D3 `TB_LON_SUMMARY_INFO` active/exact，`CR_SCORE_CARD_COMPLETED` 欄位為 `VARCHAR2(2 BYTE)`。 | carried | 物理欄位帶入 schema；owner decision on 2026-06-19 defines first character as this corporate scorecard status and second character as the other scorecard status. AO Save/re-save sets `NN`; CR Save sets first char `N` and preserves second char; CR Finished sets first char `Y` and preserves second char. | `docs/db-diff/02_tables/TB_LON_SUMMARY_INFO.md:11`-`16`, `67`; PRD TBD-002 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:56` |
| DB-D4 legacy `TB_CHECK_POINT_CORP/CU/RC_*` 在 db-diff 標 `removed_or_unused`，note 指向 `TB_CHECK_POINTS_CS/CU`。 | changed | 新契約使用 `TB_CHECK_POINTS_CS`/`TB_CHECK_POINTS_CU` 與欄位 `EPROC00118`；舊表只保留為 migration note。 | `docs/db-diff/02_tables/TB_CHECK_POINT_CORP.md:6`-`13`; `docs/db-diff/02_tables/TB_CHECK_POINT_CU.md:6`-`13`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:6`-`13`; `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:6`-`13`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:10`-`13`, `51`; `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:10`-`13`, `49` |
| DB-D5 PRD legacy `EPROC0_0218` RC checkpoint 未在 new DB snapshot 出現 `EPROC00218` 或 RC-specific active table 欄。 | changed | 不自建新欄；owner decision on 2026-06-19 maps RC renewal/change to the same `EPROC00118` checkpoint field in `TB_CHECK_POINTS_CS/CU`. | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:167`-`170`; old RC columns `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:50`, `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CU.md:49`; new DB `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:51`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:49` |
| DB-D6 `TB_MAIN_BORROWER_INFO_CORP` active/exact，`MAIN_BORROWER_NAME` is `VARCHAR2(100 BYTE)`. | carried | Owner decision on 2026-06-20 makes `mainBorrowerName` part of `epl-info-c0-corporateScorecard`; value comes from `TB_MAIN_BORROWER_INFO_CORP.MAIN_BORROWER_NAME`. | `docs/db-diff/02_tables/TB_MAIN_BORROWER_INFO_CORP.md:11`-`16`, `32`, `38`-`39`; PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:220`, `492` |
| AUTH-D1 `TB_API_AUTH` is active/exact, note `重構新增`, transpose method `重新寫入`. | changed | Contract uses exact backend API IDs including select-list/info/calc/save endpoints. Owner decision on 2026-06-20 requires all four EPROC00118 C0 target rows plus service-level non-AO/non-CR rejection before QA regression or testing deployment. The row-level precheck gap was closed by direct apply and SELECT-only recheck against `OVSLXLON02` on 2026-06-20. | `docs/db-diff/02_tables/TB_API_AUTH.md:10`-`16`, `32`, `38`-`40`; row precheck `docs/build-tasks/c0-authz-sql-findings.md:61`-`64`, `134`-`137`; backend controller `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:31`, `38`, `45`, `52` |
| REF-D1 refactor latest 僅有 BE corporate query/calculate/save 三 artifacts，無 FE artifact。 | carried | SRS endpoint 以 BE latest 為契約，FE 行為由 PRD/source parity 描述，不宣稱已有 FE spec。 | `docs/refactor-spec/02_modules/EPROC00118.md:3`-`21` |
| REF-D2 PRD legacy `query/getRate/getDate/save` 對應 refactor `info/calc/save` 三 POST RPC；`getDate` 不獨立成 endpoint。 | changed | `getDate` 行為折入 Default flow 與 save/calc date response；Default date failure still carries `COMMON_MSG_RATE_FAIL`; 不另建 date RPC。 | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:469`-`472`, `534`; refactor endpoints `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-calc-c0-corporatescorecard.md:138`-`140` |
| REF-D3 refactor save 使用 `isFinish`，PRD legacy 使用 `check=Y/N`。 | changed | OpenAPI 使用 `isFinish`; spec 明確 mapping：Save=`false`, Finished=`true`; legacy `check` 只作 migration note。 | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:380`; refactor `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:154`, `195` |
| REF-D4 refactor BE 對 Finished/CR comment/required fields 有比 PRD legacy 更強的後端驗證。 | changed | Owner decision on 2026-06-19 adopts the stricter BE validation as to-be enforce: required fields, Rate-before-Finished, and CR Finished comment must reject before DB write. | PRD TBD-003 `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:57`; refactor `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:156`, `170`-`180`; current backend `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuCorporateScorecardServiceImpl.java:366`-`425` |
| REF-D5 refactor calc has field typo signal `trans12mMnCode` / `debtRati` in extracted text. | changed | Public C0 DTO contract uses canonical `trans12MonCode` and `debtRatio`; current backend confirms these public request properties. The shared internal Function1 DTO still uses legacy/internal `debtRati` for the handoff, so `debtRati` is not a public C0 API field. | `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-calc-c0-corporatescorecard.md:107`, `163`, `210`; `backend/src/main/java/khd/svc/epro/dto/request/corporate/corporateScorecard/CalCorporateScoreCardRequest.java:69`-`77`, `129`-`132`; `backend/src/main/java/khd/svc/epro/dto/request/corporate/corporateScorecard/SaveCorporateScorecardRequest.java:80`-`86`, `128`-`130`; internal handoff `backend/src/main/java/khd/svc/epro/dto/request/individual/function/GetRateRequest.java:87`-`88` |

## Parity Triage
| Item | Triage | Decision |
|---|---|---|
| `EPROC0_0118/0218` action names (`query/getRate/getDate/save`) vs refactor RPC names | intentional evolution | Contract uses backend exact RPC names; legacy action names remain as-is evidence only. |
| old checkpoint tables `TB_CHECK_POINT_CORP/CU/RC_*` vs new `TB_CHECK_POINTS_CS/CU` | DB-schema triage | New DB snapshot wins for physical schema; RC branch maps to the shared `EPROC00118` field. |
| backend calc returns only `riskLevel` and `scoreDatetime` | regression guard | SRS intentionally excludes legacy `totalScore/scoreMap` from the public calc response; `totalScore` remains a server-side calculation used to derive risk level and saved score values. |
| backend save returns empty map | regression guard | SRS verifies save through response code and DB side effects, not unproven response fields. |
| backend non-AO roles fall into CR branch if TB_API_AUTH misses | regression/security guard | Closed by 2026-06-20 RD/DBA closeout: platform access-denied remains the response contract, four endpoint auth seeds were verified, and save has explicit service rejection for non-AO/non-CR roles. |

## @PENDING

### Decision Register
| ID | Decision | Source / Delta |
|---|---|---|
| P-118-001 | ✅ Closed: parameter version lookup uses `MAX(ST_DATE <= APP_DATE)` only; `END_DATE` is seed metadata, not a runtime filter. | Owner 2026-06-20; R1/R3; BR-003; DB-D2. |
| P-118-002 | ✅ Closed: current DB snapshot of `TB_SCORE_CARD_PARAM_DETAIL` adopted as EPROC00118 seed baseline for option labels, scores, ranges, risk levels. | Owner 2026-06-19; R3; DB-D2. |
| P-118-003 | ✅ Closed: public calc response carries `riskLevel` and `scoreDatetime` only; `totalScore` is internal-only. | Owner 2026-06-20; R3; BR-006. |
| P-118-004 | ✅ Closed: AO Finished with AO Default also sets CR risk/score/date to `Default` / `-1` / AO rating date. | Owner 2026-06-20; R4; BR-008. |
| P-118-005 | ✅ Closed: stricter BE validation is to-be enforce (required fields, Rate-before-Finished, CR Finished comment reject before DB write). | Owner 2026-06-19; R4; REF-D4; PRD TBD-003. |
| P-118-006 | ✅ Closed: role `003` is not an AO editor for this page despite the broader AO role pool. | Owner 2026-06-19; R5. |
| P-118-007 | ✅ Closed: two-layer save authorization (four `TB_API_AUTH` seeds + service-level non-AO/non-CR reject); seeds applied/rechecked against `OVSLXLON02`. | Owner 2026-06-20; R5; AUTH-D1. |
| P-118-008 | ✅ Closed: `CR_SCORE_CARD_COMPLETED` two-character semantics; AO Save/re-save = `NN`, CR Save = first char `N`, CR Finished = first char `Y`, second char preserved. | Owner 2026-06-19; R6; DB-D3; BR-012/BR-013. |
| P-118-009 | ✅ Closed: AO-to-CR copy must include `_AR_SCR`/`_INVENTORY_SCR` with matching `_AR_CODE`/`_INVENTORY_CODE` (corrects legacy omission). | Owner 2026-06-19; R6. |
| P-118-010 | ✅ Closed: RC save duplicate `APPLICATION_NO` where-field not preserved; single `APPLICATION_NO` condition. | Owner 2026-06-19; R6; BR-002. |
| P-118-011 | ✅ Closed: CU-return/reset updates `TB_CHECK_POINTS_CU.EPROC00118` (not only CS); RC renewal/change reuses shared `EPROC00118`. | Owner 2026-06-19; R7; DB-D4/DB-D5; SC/E1. |
| P-118-012 | ✅ Closed: `scoreDatetime` uses explicit Asia/Taipei / UTC+8 clock; JVM/container default timezone rejected. | Owner 2026-06-20; R3. |
| P-118-013 | ✅ Closed: nonnumeric `TB_SCORE_CARD_PARAM_DETAIL.SCORE` seed is fail-fast `MSG_QUERY_FAIL`, not silent coerce to zero. | Owner 2026-06-20; R3. |
| P-118-014 | ✅ Closed: `mainBorrowerName` part of `epl-info-c0-corporateScorecard` from `TB_MAIN_BORROWER_INFO_CORP.MAIN_BORROWER_NAME`. | Owner 2026-06-20; R1; DB-D6. |
| P-118-015 | ✅ Closed: legacy initial-load vs Default-to-N length/decimal mismatch treated as UI defect; one precision rule, no compatibility mode. | Owner 2026-06-20; R8. |
| P-118-016 | ✅ Closed: canonical `MAX_OVERDUE_CODE`/`TRANS_12MON_CODE` linkage kept; legacy `CR_TRA_LST_MON_CODE*`/`CR_MAX_DUE_CODE*` block is dead code. | Owner 2026-06-20; R2/R4; BR-010/BR-011. |

## Rule Evidence
> 每條 Rn 的 as-is（現況/legacy）、REF-Dn delta、provenance（`file:line`/`@SHA`）、決策 ID（RP/P）；鍵到 Rn，與上半 `[ev→Rn]` 1:1。
| Rn | as-is（現況/legacy；含疑似 bug） | to-be delta / 決策 ID | provenance |
|---|---|---|---|
| R1 | Legacy `query` action loads case/borrower/options/checkpoint; over-count guard returns `MSG_OVER_COUNT_LIMIT`. RD closeout added DTO/service alignment for `mainBorrowerName` and `checkpointStatus` on 2026-06-20. | Owner decision on 2026-06-20 requires `epl-info-c0-corporateScorecard` to supply the full tab initialization contract (`mainBorrowerName` + `checkpointStatus` after CS/CU branch by `LON_ATTRIBUTE + SECURE_ATTRIBUTE`). P-118-014. | PRD init/error `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:216`-`223`, `528`-`531`; refactor query contract `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-info-c0-corporatescorecard.md:152`-`160`; legacy `legacy-epro/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0118.java:70`. |
| R2 | Legacy CR handlers reference non-existent DOM ids `CR_TRA_LST_MON_CODE*` and `CR_MAX_DUE_CODE*` (dead code). PRD item list = 23 items; DB field lengths from refactor query response. | Owner decision on 2026-06-20 keeps canonical `MAX_OVERDUE_CODE`/`TRANS_12MON_CODE` linkage as to-be for both AO and CR; legacy dead DOM-id block not carried. P-118-016. | PRD item list `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:248`-`270`; DB fields `docs/db-diff/02_tables/TB_CORP_SCRCARD.md:39`-`150`; refactor response field lengths `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-info-c0-corporatescorecard.md:85`-`112`. |
| R3 | Legacy `getRate` computes total/risk; `TB_SCORE_CARD_PARAM_DETAIL.SCORE` is physically `VARCHAR2(10)`. RD closeout changed `FunctionServiceImpl.parseScore` to fail fast on nonnumeric seed and updated score datetime to explicit Asia/Taipei clock on 2026-06-20. | Owner decisions: version selection by `ST_DATE` only, `END_DATE` seed metadata (P-118-001); seed baseline adopted (P-118-002); calc public response = `riskLevel`+`scoreDatetime` only (P-118-003); UTC+8 clock (P-118-012); nonnumeric SCORE fail-fast (P-118-013). | PRD rate/effective-date `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:296`, `450`; DB param table `docs/db-diff/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:38`-`47`; refactor calc contract `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-calc-c0-corporatescorecard.md:84`-`110`, `186`-`195`. |
| R4 | Legacy/current backend AO Default side effect copies to CR. JS default flag handler prompts date; save branch validates flag. | Owner decision on 2026-06-20 accepts AO-to-CR Default side effect (P-118-004); owner decision on 2026-06-19 adopts strict BE Finished validation as to-be (P-118-005). | PRD default `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:323`-`336`, `647`-`651`; refactor save default flow `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:169`-`182`, `191`-`192`. |
| R5 | Current filter behavior: non-AO roles fall into CR branch if `TB_API_AUTH` misses. RD/DBA closeout implemented service-level reject and applied/rechecked four `TB_API_AUTH` rows against `OVSLXLON02` on 2026-06-20. | Owner decision on 2026-06-19 follows PRD page-level role rule (role `003` not AO editor, P-118-006); owner decision on 2026-06-20 requires two-layer save authz (P-118-007); side-scoped save authz; read endpoints use independent auth rows. | PRD role control `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:354`-`356`; Bible role dictionary `docs/specs/bible/bible-eproposal.md:398`-`399`, `796`; refactor save role validation `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:156`, `170`-`180`. |
| R6 | Legacy/current AO save/copy/reset across AO and CR fields. Legacy `EPROC0_0218_mod.save` sets `whereFieldMap.APPLICATION_NO` twice (redundant, result-neutral). | Owner decision on 2026-06-19 approves `CR_SCORE_CARD_COMPLETED` two-char semantics (P-118-008), AO-to-CR copy includes `_AR_SCR`/`_INVENTORY_SCR` (P-118-009), and single `APPLICATION_NO` where-condition (P-118-010). | PRD save rules `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:380`-`386`, `410`; refactor save SQL flow `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:193`-`197`, `210`-`216`; SoT precedence for DB physical truth `docs/spec-architecture.md:87`-`91`. |
| R7 | legacy `EPROC0_0218` RC checkpoint; old `TB_CHECK_POINT_CORP/CU/RC_*` removed_or_unused, note points to `TB_CHECK_POINTS_CS/CU`. | Owner decisions on 2026-06-19: CU-return/reset updates `TB_CHECK_POINTS_CU.EPROC00118` (not only CS); RC renewal/change reuses shared `EPROC00118` field. P-118-011. | PRD legacy checkpoint table `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:167`-`172`, `425`-`435`; old table removed hints `docs/db-diff/02_tables/TB_CHECK_POINT_CORP.md:6`-`13`, `docs/db-diff/02_tables/TB_CHECK_POINT_RC_CORP.md:6`-`13`; new checkpoint columns `docs/db-diff/02_tables/TB_CHECK_POINTS_CS.md:38`-`53`, `docs/db-diff/02_tables/TB_CHECK_POINTS_CU.md:38`-`50`. |
| R8 | Legacy `CUR_RATIO` percent conversion (×100/÷100); legacy initial-load vs Default-to-N input length/decimal mismatch. | Owner decision on 2026-06-20 treats the length/decimal mismatch as a UI defect/artifact; one precision rule, no compatibility mode; `CUR_RATIO` UI percent limited to integer input. P-118-015. | PRD conversion `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:223`, `384`, `630`; DB precision `docs/db-diff/02_tables/TB_CORP_SCRCARD.md:139`-`150`; refactor save validation `docs/refactor-spec/03_artifacts/be-corporate/EPROC00118/epl-save-c0-corporatescorecard.md:157`-`159`, `185`-`187`. |
