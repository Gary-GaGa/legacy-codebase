# SRS - EPROC00118 Corporate Scorecard / 企業授信評分卡

| 欄位 | 內容 |
|---|---|
| Status | **規格定版**: In Review - PRD TBD-001~010 與既有 CreditEval escalation 尚未全關；**實作完成**: 後端 2026-06-05 已完成並通過既有 gate，但本 SRS 只描述邊界與待決；ledger 由 orchestrator gate/N 軸後回填 |
| Owner | SA/RD/QA（待指派） |
| Slug | `EPROC00118` |
| 版本 | v0.1-draft |
| 最後更新 | 2026-06-18 |
| 上游 PRD | `../../prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md` |
| 5 reconcile | PRD、legacy/as-is findings、local `docs/refactor` by funcId/epl-*、local `docs/db-schema` by table_name、decisions/pending matrix |

## Scope / Non-Goals
- 本期承載 `EPROC00118` 企業授信評分卡：初始化查詢、23 項 AO/CR 評分、Rate 計算、Default 處理、Save/Finished 儲存、summary/checkpoint 連動、參數有效日期。
- 不承載 scorecard 參數維護畫面、Consumer/IS/IU scorecard、信用決策 submit/return 主流程修正、既有 `CsuCreditEval*` escalation 修補。
- 本 SRS 不新增任務板 ledger 狀態；主控 gate/N 軸過後再回填。

## Assumptions / Dependencies / Constraints
- 企金 c0 endpoint 使用 `epl-*-c0-corporateScorecard` 命名；refactor latest 顯示 calc/info/save 三支皆為 `EPROC00118` latest（`docs/refactor/00_HOME.md:361-363`），下拉清單 endpoint 由現碼 controller 與授權盤點補足。
- 計分引擎不分叉：既有人審決策要求 c0 calc 注入 `FunctionService.funcGetRate`，避免複製/重寫 scorecard 算法（`docs/build-tasks/done/EPROC00118-corporate-scorecard.md:24-25`）。
- 新 DB snapshot 為 Oracle；`docs/db-schema/00_HOME.md:5-10` 標示來源 workbook 與 2025-05-14 snapshot，table doc 是本 bundle 的欄位來源。
- Query mode、AO/CR role、editor 權限仍須由後端強制檢核，不只依前端 disabled 狀態。

## Endpoints
| 動作 | endpoint | method | 對應 PRD action | refactor source |
|---|---|---|---|---|
| 取得 scorecard options | `epl-sele-c0-corporateScorecard-list` | POST | `query` options | `backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:31-34`; `docs/build-tasks/c0-authz-sql-findings.md:64`, `docs/build-tasks/c0-authz-sql-findings.md:134` |
| 查詢本頁資料 | `epl-info-c0-corporateScorecard` | POST | `query` | `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-info-c0-corporateScorecard_查詢Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0_20260603--ddcacb78e8.md:17`, `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-info-c0-corporateScorecard_查詢Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0_20260603--ddcacb78e8.md:88`, `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-info-c0-corporateScorecard_查詢Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0_20260603--ddcacb78e8.md:132-133` |
| 計算 score/risk/date | `epl-calc-c0-corporateScorecard` | POST | `getRate` | `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-calc-c0-corporateScorecard_計算Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0.20260611--5ef77eaa6f.md:17`, `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-calc-c0-corporateScorecard_計算Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0.20260611--5ef77eaa6f.md:78`, `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-calc-c0-corporateScorecard_計算Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0.20260611--5ef77eaa6f.md:122-145` |
| 儲存/完成 | `epl-save-c0-corporateScorecard` | POST | `save` | `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-save-c0-corporateScorecard_儲存企業評分卡評估頁籤_後端系統規格書_v1.0_20260610--76017ee27f.md:17`, `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-save-c0-corporateScorecard_儲存企業評分卡評估頁籤_後端系統規格書_v1.0_20260610--76017ee27f.md:78`, `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-save-c0-corporateScorecard_儲存企業評分卡評估頁籤_後端系統規格書_v1.0_20260610--76017ee27f.md:122-124` |
| 取得 rating date | `getDate` 不獨立開新 c0 endpoint | internal / merged | `getDate` | PRD 保留為 legacy action；新 refactor 未見獨立日期 endpoint，以 save/calc response 的 `scoreDatetime`/`actionDate` 承載 |

## 業務規則

### R1 - 初始化查詢載入案件、既有 scorecard、options 與 checkpoint `covers-prd: FR-001` **強制點：FE+BE**
系統在開啟 Corporate Scorecard 時，必須以 `applicationNo` 查 `TB_LON_SUMMARY_INFO` 取得申請日、案件屬性與主借款人，查 `TB_CORP_SCRCARD` 帶入 AO/CR 既有資料，並透過 `epl-sele-c0-corporateScorecard-list` 載入 scorecard options。`applicationNo` 空白時回 `COMMON_MSG_ERROR_LON` 或新契約 `E102`。來源：PRD `FR-001`（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:203-231`）、refactor info request/response（`docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-info-c0-corporateScorecard_查詢Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0_20260603--ddcacb78e8.md:132-133`, `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-info-c0-corporateScorecard_查詢Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0_20260603--ddcacb78e8.md:153-206`, `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-info-c0-corporateScorecard_查詢Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0_20260603--ddcacb78e8.md:296-309`）、c0 controller（`backend/src/main/java/khd/svc/epro/controller/corporate/CsuCorporateScorecardController.java:31-34`）。

### R2 - 23 項 AO/CR scorecard 欄位與欄位長度 `covers-prd: FR-002` **強制點：FE+BE**
系統必須提供 AO 與 CR 兩組同構欄位，包含 17 個 select/code 項與 5 個 numeric input，再加 Default flag。欄位代碼與 UI 項目依 PRD 清單，不得只保存總分。`riskLevel` 長度以新 DB `AO_RISK_LEVEL`/`CR_RISK_LEVEL` `VARCHAR2(7 BYTE)` 為準。Numeric input 不得隱性截斷或 rounding；超出 precision/scale 時回 validation error body 且不得更新 DB。來源：PRD 23 項清單（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:233-278`）、DB 欄位（`docs/db-schema/02_tables/TB_CORP_SCRCARD.md:84`, `docs/db-schema/02_tables/TB_CORP_SCRCARD.md:133`, `docs/db-schema/02_tables/TB_CORP_SCRCARD.md:139-150`）。

| API field | DB columns | DB precision | API maxLength / pattern | storage rule | invalid handling |
|---|---|---|---|---|---|
| `curRatio` | `AO_CUR_RATIO` / `CR_CUR_RATIO` | `NUMBER(3,2)` | `maxLength=3`, `^[0-9]{1,3}$` | UI percent integer `0`-`999`; save divides by 100, query multiplies by 100 | reject decimal, negative, length > 3, or value that cannot fit DB ratio; no truncation/rounding |
| `deRatio` | `AO_DE_RATIO` / `CR_DE_RATIO` | `NUMBER(9,2)` | `maxLength=10`, `^[0-9]{1,7}(\.[0-9]{1,2})?$` | save exact decimal value | reject more than 7 integer digits or 2 decimal digits; no truncation/rounding |
| `totalAsset` | `AO_CMP_TOT_ASSET` / `CR_CMP_TOT_ASSET` | `NUMBER(19,2)` | `maxLength=20`, `^[0-9]{1,17}(\.[0-9]{1,2})?$` | save exact decimal value | reject more than 17 integer digits or 2 decimal digits; no truncation/rounding |
| `totalLoanAmt` | `AO_TOTAL_LOAN_AMT` / `CR_TOTAL_LOAN_AMT` | `NUMBER(19,2)` | `maxLength=20`, `^[0-9]{1,17}(\.[0-9]{1,2})?$` | save exact decimal value | reject more than 17 integer digits or 2 decimal digits; no truncation/rounding |
| `debtRatio` | `AO_DEBT_RATIO` / `CR_DEBT_RATIO` | `NUMBER(6,2)` | `maxLength=7`, `^[0-9]{1,4}(\.[0-9]{1,2})?$` | save exact decimal value | reject more than 4 integer digits or 2 decimal digits; no truncation/rounding |

### R3 - Rate 計算使用共用 FunctionService，不分叉算法 `covers-prd: FR-003` **強制點：BE**
當使用者按 Rate，後端以 22 項 code/input 查 scorecard 參數並回 `riskLevel`、`totalScore`、`scoreDatetime`；c0 不得另寫一套計分算法，必須使用已核准的 `FunctionService.funcGetRate`。來源：PRD `getRate`（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:280-308`）、refactor calc response（`docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-calc-c0-corporateScorecard_計算Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0.20260611--5ef77eaa6f.md:270-305`）、人審決策（`docs/build-tasks/done/EPROC00118-corporate-scorecard.md:24-25`）。

### R4 - Loan Default 90+ Days = Yes 的 Default 規則 `covers-prd: FR-004` **強制點：FE+BE**
若 AO 或 CR 的 `loanDefDayFlag` 為 `Y`，該角色欄位停用、risk level 顯示 `Default`、score 寫 `-1`；AO default 會同步設定 CR default/risk/date，此行為保留但標 PM/風控確認。來源：PRD default 規則（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:310-337`）、完成任務明確要求照 i0 複製（`docs/build-tasks/done/EPROC00118-corporate-scorecard.md:28`）。

### R5 - AO/CR/query role 欄位控制 `covers-prd: FR-005` **強制點：FE+BE**
AO role `001/002` 可編輯 AO 欄位與操作 AO Rate/Save/Finished；CR role `102/103` 可編輯 CR 欄位、CR comment 與操作 CR Rate/Save/Finished；query mode 全頁唯讀。Role `003` 是否可 AO 編輯維持 `@PENDING(TBD-004)`，未裁前不得擴權。來源：PRD role 表（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:339-365`）、refactor info 服務角色（`docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-info-c0-corporateScorecard_查詢Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0_20260603--ddcacb78e8.md:70-88`）。

### R6 - Save/Finished 單一交易與 summary/checkpoint `covers-prd: FR-006` **強制點：BE**
Save/Finished 必須在同一交易 upsert `TB_CORP_SCRCARD`、更新 `TB_LON_SUMMARY_INFO.CR_SCORE_CARD_COMPLETED` 與 checkpoint；任一步失敗 rollback。Save 表示未完成，Finished 表示完成。PRD legacy payload `check=Y/N` 在新契約改為 `isFinish=false/true`，屬 changed。來源：PRD transaction 規則（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:367-410`）、refactor save request/validation（`docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-save-c0-corporateScorecard_儲存企業評分卡評估頁籤_後端系統規格書_v1.0_20260610--76017ee27f.md:122-124`, `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-save-c0-corporateScorecard_儲存企業評分卡評估頁籤_後端系統規格書_v1.0_20260610--76017ee27f.md:222-242`）。

### R7 - 父頁完成狀態與 `CR_SCORE_CARD_COMPLETED` 兩碼契約 `covers-prd: FR-007` **強制點：BE**
`CR_SCORE_CARD_COMPLETED` 為兩碼；本頁只負責 scorecard 位元，與 `EPROC00114/00214` 擔保品 scorecard 另一位元並存。AO Save 會重設為 `NN`；CR Save/Finished 會更新第一碼的 PRD 敘述仍須與新實作「00118 只動第 2 碼」決策 reconcile。既有 CreditEval 對整欄覆寫 `"NN"` 是外部 escalation，不在本頁修。來源：PRD 兩碼 TBD 與流程（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:56`, `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:151`, `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:161`, `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:402`）、人審/決策（`docs/build-tasks/done/EPROC00118-corporate-scorecard.md:28`, `docs/build-tasks/done/EPROC00118-corporate-scorecard.md:46-48`; `docs/decisions.md:35-36`）。

### R8 - 參數有效日期與 score range `covers-prd: FR-008` **強制點：BE**
Options、numeric score range 與 risk level 由 `TB_SCORE_CARD_PARAM_DETAIL` 依 `APPLICATION_DATE` 取得；PRD 指出 legacy 以 `ST_DATE = max(ST_DATE <= APP_DATE)` 判斷有效版本，未用 `END_DATE`，保留 `@PENDING(TBD-009)` 給 SA/RD 裁定是否加上結束日。來源：PRD `FR-008`（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:444-461`）、DB 欄位（`docs/db-schema/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:38-47`）。

### R9 - 非功能：安全、交易、audit、敏感資料 `covers-prd: NFR` **強制點：BE**
後端必須驗證 editor/role 才允許 Save/Finished；不得記錄完整 scorecard payload、員工姓名代碼須依平台日誌規則遮罩。Save/calc/query 的 timeout/retry/idempotency 依平台 AJAX 標準；相同 payload 重送可覆寫 scorecard 欄位，但 CR comment date 可能更新。來源：PRD timeout/idempotency/security（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:540-546`, `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:604`, `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:661-663`）。

### R10 - 錯誤碼承載與 HTTP status 未裁 `covers-prd: FR-001, FR-003, FR-006, NFR` **強制點：FE+BE**
本頁契約必須承載 PRD Error Response 與 refactor validation 裸名碼：`COMMON_MSG_ERROR_LON`、`MSG_DATA_NOT_FOUND`、`MSG_OVER_COUNT_LIMIT`、`MSG_QUERY_FAIL`、`COMMON_MSG_RATE`、`COMMON_MSG_RATE_FAIL`、`EPROI00118_MSG_ERROR_FLG`、`COMMON_MSG_SAVE_SUCCESS`、`COMMON_MSG_SAVE_FAIL`，以及新平台/refactor 層 `E102`、`E130`、`E998`、`E999`。OpenAPI 以 `default` + `ErrorResponse{code,message,data}` 承載錯誤 body；HTTP status mapping 尚未由 SA/RD 裁定，維持 `@PENDING(TBD-ERR-STATUS)`，不得把 `MSG_DATA_NOT_FOUND`、`MSG_OVER_COUNT_LIMIT` 等 legacy message 逕自定為 404/409。來源：PRD Error Response（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:524-538`）、PRD message mapping（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:643-655`）、refactor error examples（`docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-info-c0-corporateScorecard_查詢Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0_20260603--ddcacb78e8.md:132-133`; `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-save-c0-corporateScorecard_儲存企業評分卡評估頁籤_後端系統規格書_v1.0_20260610--76017ee27f.md:230-242`）。

QA 驗證時，所有錯誤路徑必須直接檢查 response body 的 `code`、`message`、`data`，並記錄實際 HTTP status 對照平台 exception mapping；在 `TBD-ERR-STATUS` 未裁前，單一數字 status 不作為本頁 SRS 的硬失敗條件，但缺少錯誤 body、成功寫入 DB、或回傳未列入的錯誤碼皆為失敗。

### R11 - Late transaction 欄位連動 `covers-prd: FR-002, FR-006` **強制點：FE+BE**
`MAX_OVERDUE_CODE` 與 `TRANS_12MON_CODE` 必須維持 legacy-confirmed 連動：`MAX_OVERDUE_CODE=01` 時 `TRANS_12MON_CODE=01` 且 disabled；`MAX_OVERDUE_CODE=07` 時 `TRANS_12MON_CODE=05` 且 disabled；反向選 `TRANS_12MON_CODE=01` 或 `05` 時需同步鎖定 `MAX_OVERDUE_CODE`。前端需即時連動，Save/Finished 不得接受違反連動的組合；PRD TBD-007 所述不存在 DOM id 的 CR dead-code linkage 不列為新需求，見 PRD TBD disposition。來源：PRD BR-010/011（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:626-627`）、PRD TC-013/014（`docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:702-703`）。

## 新舊 DB 對照 / 更動 delta
> 三判標籤固定使用：`regression`、`intended evolution`、`DB structure diff`；若未裁，於同格標 `@PENDING(...)`。

| 項 | 來源 file:line | delta | 三判 |
|---|---|---|---|
| `TB_CORP_SCRCARD` 主表沿用；PK `APPLICATION_NO`；113 欄 active/exact | `docs/db-schema/02_tables/TB_CORP_SCRCARD.md:3-20`, `docs/db-schema/02_tables/TB_CORP_SCRCARD.md:32`, `docs/db-schema/02_tables/TB_CORP_SCRCARD.md:38` | 舊 DAO/PRD 使用 `TB_CORP_SCRCARD`，新 DB snapshot 同名同 PK，欄位群可直接承載 AO/CR scorecard；無行為差異 | DB structure diff（no schema rename） |
| `TB_SCORE_CARD_PARAM_DETAIL` 為固定參數且 `transpose_method=重新寫入` | `docs/db-schema/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:6-16`, `docs/db-schema/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:38-47`; `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:55`, `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:63` | 舊行為依 DB 參數內容與 `ST_DATE` 版本；新 DB 要重寫入 seed。正式 label/range/risk level 仍待資料附件或 migration seed | DB structure diff + @PENDING(TBD-001, TBD-009) |
| `TB_LON_SUMMARY_INFO.CR_SCORE_CARD_COMPLETED` 仍為 `VARCHAR2(2)` | `docs/db-schema/02_tables/TB_LON_SUMMARY_INFO.md:38`, `docs/db-schema/02_tables/TB_LON_SUMMARY_INFO.md:45`, `docs/db-schema/02_tables/TB_LON_SUMMARY_INFO.md:50-51`, `docs/db-schema/02_tables/TB_LON_SUMMARY_INFO.md:67`; `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:56` | 兩碼欄位沿用，但本頁/擔保品頁分工與既有 CreditEval 整欄覆寫衝突需照決策處理；未裁前不放入 OpenAPI 硬 response 欄位 | intended evolution + @PENDING(TBD-002) |
| checkpoint table/column 由 legacy `EPROC0_0118/0218` 與 RC/CORP/CU 表述改為新 DB `TB_CHECK_POINTS_CS/CU.EPROC00118` | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:165-170`; `docs/db-schema/02_tables/TB_CHECK_POINTS_CS.md:1-16`, `docs/db-schema/02_tables/TB_CHECK_POINTS_CS.md:38`, `docs/db-schema/02_tables/TB_CHECK_POINTS_CS.md:51`; `docs/db-schema/02_tables/TB_CHECK_POINTS_CU.md:1-16`, `docs/db-schema/02_tables/TB_CHECK_POINTS_CU.md:38`, `docs/db-schema/02_tables/TB_CHECK_POINTS_CU.md:49` | 新 DB 以 funcId 欄位 `EPROC00118` 表示頁籤，不保留 transaction id 欄名；RC legacy 分支在 c0 新 DB 併入 CS/CU checkpoint 表 | DB structure diff |
| `CUR_RATIO` 儲存比例值，畫面以百分比呈現 | `docs/db-schema/02_tables/TB_CORP_SCRCARD.md:139-140`; `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-info-c0-corporateScorecard_查詢Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0_20260603--ddcacb78e8.md:254-256`; `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-save-c0-corporateScorecard_儲存企業評分卡評估頁籤_後端系統規格書_v1.0_20260610--76017ee27f.md:256-264` | 查詢時 DB `0.80` 顯示 `80`，儲存時百分比除以 100；schema.sql 需保留 number precision hint | intended evolution |
| `AO_AR_SCR`/`AO_INVENTORY_SCR` 與 CR 對應分數欄在 DB 存在 | `docs/db-schema/02_tables/TB_CORP_SCRCARD.md:75`, `docs/db-schema/02_tables/TB_CORP_SCRCARD.md:77`, `docs/db-schema/02_tables/TB_CORP_SCRCARD.md:124`, `docs/db-schema/02_tables/TB_CORP_SCRCARD.md:126`; `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:59` | PRD 指出 legacy AO copy 清單疑未複製 `_AR_SCR`/`_INVENTORY_SCR`；新 DB 有欄，是否修正 copy 差異待裁 | regression + @PENDING(TBD-005) |
| c0 calc 可例外注入 i0 `FunctionService` | `docs/decisions.md:34-35`; `docs/build-tasks/done/EPROC00118-corporate-scorecard.md:24-25` | 通常 c0 自足鏡像，但本頁計分引擎為唯一例外；schema 不新增 duplicated calculation table | intended evolution（已裁決） |
| 新 endpoint 授權列需補 `TB_API_AUTH`/`TB_ROLE_TASK` | `docs/build-tasks/done/EPROC00118-corporate-scorecard.md:48`; `docs/build-tasks/c0-authz-sql-findings.md:61-64`, `docs/build-tasks/c0-authz-sql-findings.md:83`; `docs/db-schema/02_tables/TB_API_AUTH.md:15`, `docs/db-schema/02_tables/TB_API_AUTH.md:32`, `docs/db-schema/02_tables/TB_API_AUTH.md:38-42`; `docs/db-schema/02_tables/TB_ROLE_TASK.md:15`, `docs/db-schema/02_tables/TB_ROLE_TASK.md:32`, `docs/db-schema/02_tables/TB_ROLE_TASK.md:38-41` | 後端完成紀錄仍列授權列為遺留；SRS 標為部署前配置要求；四支 c0 endpoint 均需入授權檢核，但 role 值/seed 套用仍待 RD/SA | DB structure diff + @PENDING(TBD-AUTH) |

## @PENDING
> Numeric precision is closed by R2. Open TBD rows cannot override R2 maxLength, pattern, precision, scale, or no truncation/rounding rules.

| id | 狀態 | owner | 待裁事項 | 來源 |
|---|---|---|---|---|
| TBD-001 | open | PM/SA/RD | `TB_SCORE_CARD_PARAM_DETAIL` option label、score range、risk level seed | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:55`; DB `docs/db-schema/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:6-16` |
| TBD-002 | open | PM/SA/CreditEval owner | `CR_SCORE_CARD_COMPLETED` 兩碼語意、00118/00114 分工與既有 CreditEval 整欄覆寫風險 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:56`; `docs/decisions.md:35-36` |
| TBD-003 | open | SA/RD | Save 是否補後端 required/rate/comment 強檢；refactor 已補 `E102` 規則，需確認是否採新嚴格行為 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:57`; `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-save-c0-corporateScorecard_儲存企業評分卡評估頁籤_後端系統規格書_v1.0_20260610--76017ee27f.md:230-242` |
| TBD-004 | open | PM/SA | AO Manager role `003` 本頁是否可編輯 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:58`; `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-info-c0-corporateScorecard_查詢Corporate_Score_Card評分卡頁籤_後端系統規格書_v1.0_20260603--ddcacb78e8.md:72-78` |
| TBD-005 | open | SA/RD | AO copy 是否補 `_AR_SCR`/`_INVENTORY_SCR` | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:59`; `docs/db-schema/02_tables/TB_CORP_SCRCARD.md:75`, `docs/db-schema/02_tables/TB_CORP_SCRCARD.md:77` |
| TBD-008 | open | SA/RD | Default toggle behavior only: when default flag returns from `Y` to `N`, decide whether UI clears or restores the prior numeric input values; R2 numeric constraints remain authoritative | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:62`; `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-save-c0-corporateScorecard_儲存企業評分卡評估頁籤_後端系統規格書_v1.0_20260610--76017ee27f.md:141-148`, `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-save-c0-corporateScorecard_儲存企業評分卡評估頁籤_後端系統規格書_v1.0_20260610--76017ee27f.md:167-174` |
| TBD-009 | open | SA/RD | 參數有效日期是否只看 `ST_DATE`，或新系統也納入 `END_DATE` | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:63`; `docs/db-schema/02_tables/TB_SCORE_CARD_PARAM_DETAIL.md:46-47` |
| TBD-010 | open | PM/風控 | AO Default 是否同步帶 CR Default 且不要求 CR 再評 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:64`, `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:329`; `docs/build-tasks/done/EPROC00118-corporate-scorecard.md:28` |
| TBD-AUTH | open | RD/SA | 新 endpoint 的 `TB_API_AUTH`/`TB_ROLE_TASK` 授權 seed | done `docs/build-tasks/done/EPROC00118-corporate-scorecard.md:48`; authz `docs/build-tasks/c0-authz-sql-findings.md:61-64`, `docs/build-tasks/c0-authz-sql-findings.md:83`; DB `docs/db-schema/02_tables/TB_API_AUTH.md:38-42`, `docs/db-schema/02_tables/TB_ROLE_TASK.md:38-41` |
| TBD-ERR-STATUS | open | SA/RD | legacy/refactor 錯誤碼對 HTTP status 的平台映射；未裁前 OpenAPI 只用 `default` error body 承載 | PRD `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:524-538`; refactor `docs/refactor/02_specs/fe-spec/corporate/EPROC00118/epl-save-c0-corporateScorecard_儲存企業評分卡評估頁籤_後端系統規格書_v1.0_20260610--76017ee27f.md:230-242` |

## PRD TBD disposition（non-open）
| id | disposition | 理由 | 來源 |
|---|---|---|---|
| TBD-006 | closed / non-goal | `EPROC0_0218_mod.save` 重複設定 `whereFieldMap.APPLICATION_NO`，PRD 已標不影響結果；新契約不要求保留冗餘實作細節 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:60` |
| TBD-007 | closed / non-goal | CR late-transaction linkage 的不存在 DOM id 視為 dead code；SRS 承載 BR-010/011 的有效連動，不承載 dead code id | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:61`, `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md:626-627` |

## Traceability Matrix
| PRD | SRS rule | QA |
|---|---|---|
| FR-001 初始化查詢 | R1 | QA-001, QA-008, QA-018 |
| FR-002 23 項欄位 | R2, R11 | QA-001, QA-003, QA-020, QA-021A, QA-021B, QA-021C, QA-021D, QA-021E |
| FR-003 Rate | R3 | QA-002, QA-010 |
| FR-004 Default | R4 | QA-004, QA-005 |
| FR-005 role/query mode | R5 | QA-006, QA-016 |
| FR-006 Save/Finished | R6, R10, R11 | QA-007, QA-009, QA-015, QA-019, QA-020, QA-022 |
| FR-007 父頁完成狀態 | R7 | QA-011, QA-012, QA-017 |
| FR-008 參數日期 | R8 | QA-002, QA-010, QA-018, QA-021A, QA-021B, QA-021C, QA-021D, QA-021E |
| NFR | R9, R10 | QA-013, QA-014, QA-016, QA-019, QA-022 |
