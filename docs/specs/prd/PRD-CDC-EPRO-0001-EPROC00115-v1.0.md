# 業務需求導向的功能規格書

## CDC-EPRO-0001 EPROC00115 Borrower Group Exposure PRD

台中資訊開發中心

版本 1.0

文件日期：2026/06/15

| 文件屬性 | 內容 |
|---|---|
| 文件類型 | 業務需求導向的功能規格書 |
| 目標功能代號 | EPROC00115 |
| 舊系統功能代號 | EPROC0_0115、EPROC0_0215 |
| 功能名稱 | Borrower Group Exposure（借款人集團曝險） |
| 模組 | C0 公司戶徵信/評分資料 |
| 適用對象 | PM / SA / RD / QA |
| Source 掃描範圍 | `EPROC0_0115.java`、`EPROC0_0215.java`、`EPROC0_0115_mod.java`、`EPROC0_0215_mod.java`、`EPROC00115.jsp`、`EPROC00115_JS.jsp`、`EPROC00215.jsp`、`EPROC00215_JS.jsp`、`EPRO_TB_GROUP_EXPOSURE` DAO/SQL、checkpoint DAO、cross-module report/score usage、migration inventory |
| 產出檔案 | `CDC-EPRO-0001_EPROC00115_PRD_v1.0.md`、`CDC-EPRO-0001_EPROC00115_PRD_v1.0.docx` |

## 0. 文件控制

| 日期 | 版本 | 說明 | 作者 |
|---|---|---|---|
| 2026-06-15 | v1.0 | 依 `EPROC0_0115`、`EPROC0_0215` 舊系統 Source code 掃描產出公司戶 Borrower Group Exposure PRD。 | Codex |

| 角色 | Review 重點 |
|---|---|
| PM | 確認 Borrower Group Exposure 的業務目的、Exposure of Borrower Group 選項語意、Save / Finished 狀態與 0215 舊案處理。 |
| SA | 確認 `LOAN_LIMIT_TYPE` 各代碼標籤與條件式必填、幣別加總、跨模組報表/評分使用影響。 |
| RD | 確認 API / DTO、資料表 full replacement、checkpoint 分流、交易一致性、`APPLICATION_NO` 資料完整性與非 USD 幣別處理。 |
| QA | 覆蓋 0115/0215 初始化、Save、Finished、條件式必填、幣別加總、資料重建、checkpoint、cross-module DB side effect 驗證。 |

## 0.1 功能目的與範圍

| 項目 | 說明 |
|---|---|
| 功能目的 | 維護公司戶授信案件的借款人集團曝險資料，列示 borrower group member 的授信額度、未償餘額、擔保品價值、權狀類型、利率、期間、到期日與 LTV，供徵信、評分、核決層級與報表使用。 |
| 適用流程 | C0 公司戶 Credit Investigation / Scoring 資料維護頁籤。舊系統以 `EPROC0_0115` 處理一般流程，以 `EPROC0_0215` 處理展期/展變或 RC 流程。 |
| 涵蓋範圍 | 初始化查詢、四組下拉代碼、明細增刪、金額輸入、USD/KHR 彙總、Save / Finished、checkpoint 更新、頁籤完成狀態回傳。 |
| 不涵蓋範圍 | 借款人集團成員外部資料自動帶入、授信核決公式改寫、報表版面改版、其他 C0 頁籤內容。 |
| 成功標準 | 使用者可維護 borrower group exposure 明細；系統可正確保存至 `TB_GROUP_EXPOSURE`、計算總額、更新 0115/0215 checkpoint，且資料可供報表與評分模組正確讀取。 |

## 0.2 待確認與來源差異

| 編號 | 事項 | 影響 | 負責角色 |
|---|---|---|---|
| 待確認-001 | 目標功能代號已依需求命名為 `EPROC00115`，需確認現代化系統路由、選單與文件編號是否同名。 | 若命名不同，API path、選單與測試案例需同步調整。 | PM / SA |
| 待確認-002 | `FACILITY_VALUE` 欄位畫面標題為 Exposure of Borrower Group，但下拉來源是 code table `FACILITY_TYPE`。 | 需確認新版欄位命名與顯示標籤，避免與授信條件頁的 Facility Type 混淆。 | PM / SA |
| 待確認-003 | `LOAN_LIMIT_TYPE` 的 code label 未在目標 source 中定義；source 只確認值 `1` 或空白時 Finished 需填 Outstanding Amount 與 Maturity Date，其他值不強制。 | 條件式必填若依錯誤 label 解讀，可能造成驗證邏輯相反。 | SA / RD |
| 待確認-004 | 舊系統 `calculation` 將非 USD 幣別全部加到 KHR；查詢總額只明確加總 USD/KHR。 | 若 `CCY` 包含第三幣別，畫面即時計算與查詢總額可能不一致。 | PM / SA / RD |
| 待確認-005 | 舊系統以 `top.groupSize` 控制新增列上限，source 未顯示此全域值實際數字。 | 新版需確認上限是否沿用全域設定，或明確定義最大筆數。 | PM / SA |
| 待確認-006 | 0215 在 `${attrMap.isOld}` 為 true 時不顯示 Finished，且不更新父頁籤 done 狀態。 | 展期/展變舊案是否只能 Save、不能 Finished，需 PM/SA 定案。 | PM / SA |
| 待確認-007 | 舊系統查到既有 `TB_GROUP_EXPOSURE.LOAN_LIMIT_TYPE` 為 null 時，前端會把父頁籤 check 設為 `Y` 並移除 done。 | 這是舊資料補正機制或資料品質警示，需決定新版是否保留。 | SA / RD |
| 待確認-008 | Cross-module report code 讀取 collateral currency 時疑似使用 `OUTSTAND_AMOUNT_CUR` 而非 `COLLATERAL_CUR`。 | 報表顯示擔保品幣別可能與本頁保存值不一致，需確認是否為 legacy defect。 | SA / RD |
| 待確認-009 | 舊後端保存時沒有強制以 request `APPLICATION_NO` 覆寫每筆明細的 `APPLICATION_NO`，而是信任前端 `dataList`。 | 新版 API 應由後端統一寫入案件編號，避免跨案件資料污染。 | RD / QA |

## 1. 目標與範圍

| 目標 | 說明 |
|---|---|
| GOAL-001 | 正確載入公司戶案件的 borrower group exposure 明細與四組下拉選項。 |
| GOAL-002 | 支援使用者新增、刪除與維護 borrower group member exposure 明細。 |
| GOAL-003 | 依幣別彙總 Loan or Credit Card Limit Amount 與 Outstanding Amount 的 USD/KHR 總額。 |
| GOAL-004 | 以單一 EPROC00115 規格承接 `EPROC0_0115` 與 `EPROC0_0215`，並保留一般/RC checkpoint 與父頁籤差異。 |
| GOAL-005 | Save 可暫存資料；Finished 必須通過完整必填與日期格式驗證後保存。 |

## 2. Source Scan 與來源對照

| 類別 | Source | Source-confirmed 行為 |
|---|---|---|
| 0115 交易 | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0115.java` | AJAX actions：`query`、`calculation`、`save`；保存後呼叫 `EPRO_Z0Z006.getTabsCheckPage(..., "EPROC0_0110")` 與 `getCheckedProgressCORP`。 |
| 0215 交易 | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0215.java` | AJAX actions 同 0115；保存後呼叫 `EPRO_Z0Z006.getTabsCheckPage(..., "EPROC0_0210")` 與 `getCheckedProgressRC_CORP`。 |
| 0115 模組 | `EPROC0_0115_mod.java` | 查詢 `TB_GROUP_EXPOSURE`、回傳下拉選項與總額、保存 full replacement、依 CS/CU 更新 `EPRO_TB_CHECK_POINT_CORP` 或 `EPRO_TB_CHECK_POINT_CU` 的 `EPROC0_0115`。 |
| 0215 模組 | `EPROC0_0215_mod.java` | 行為同 0115，但更新 `EPRO_TB_CHECK_POINT_RC_CORP` 或 `EPRO_TB_CHECK_POINT_RC_CU` 的 `EPROC0_0215`。 |
| 0115 JSP | `EPROC00115.jsp`、`EPROC00115_JS.jsp` | 顯示 exposure field、明細 grid、Add、Save、Finished、USD/KHR total。Save 送 `check=Y`，Finished 送 `check=N`。 |
| 0215 JSP | `EPROC00215.jsp`、`EPROC00215_JS.jsp` | UI 與 0115 相同；`EPROC00215.jsp` 在 `${attrMap.isOld}` 為 true 時不顯示 Finished。 |
| DAO | `com.cathaybk.epro.dao.EPRO_TB_GROUP_EXPOSURE` | 主要表 `OVSLXLON01.TB_GROUP_EXPOSURE`，主鍵排序為 `APPLICATION_NO`、`DATA_SEQ`，支援 `find`、`deleteApp`、`insert`、`update`。 |
| SQL | `EPRO_TB_GROUP_EXPOSURE.SQL_FIND_001`、`SQL_INSERT_001`、`SQL_DELETE_APP_001` | 查詢、依 `APPLICATION_NO` 刪除、逐筆新增 exposure 明細。 |
| Checkpoint DAO | `EPRO_TB_CHECK_POINT_CORP`、`EPRO_TB_CHECK_POINT_CU`、`EPRO_TB_CHECK_POINT_RC_CORP`、`EPRO_TB_CHECK_POINT_RC_CU` | 0115/0215 欄位存在於對應 checkpoint 表。 |
| Cross-module report | `EPRO_CS0180`、`EPRO_CS0181`、`EPRO_CU0180`、`EPRO_CU0181` | 讀取 `TB_GROUP_EXPOSURE` 產出 Borrower Group Exposure 報表區塊與總額。 |
| Cross-module score | `EPROCS_0170_mod`、`EPROCS_0270_mod`、`EPROCU_0170_mod`、`EPROCU_0270_mod` | 讀取 `LCC_AMOUNT_CUR`、`LCC_AMOUNT` 計算 suggested approval level；KHR 依 `LOAN_RATE` 換算。 |
| Cross-module submit | `EPROZ0_0300_mod`、`EPROZ0_0300.java` | 回傳 `queryGroupExposure`；若 `LOAN_LIMIT_TYPE` 為 null，前端需導向或標記 Credit Investigation 未完成。 |
| Inventory | `eproposal-inventory/function-inventory.csv`、舊系統 `migration-inventory/function-inventory.csv` | `EPROC0_0115` 與 `EPROC0_0215` 均標示 `query;maintain/update`，actions 為 `calculation;query;save`。 |

## 3. 舊系統行為摘要

| 行為 | 說明 | 分類 |
|---|---|---|
| 初始化查詢 | `query` action 以 `APPLICATION_NO` 呼叫 module `query` 與 `queryGroupExposure`，回傳 `dataMap` 與 `queryGroupExposure`。 | Source confirmed |
| 下拉選項 | module 讀取 `FACILITY_TYPE`、`LOAN_LIMIT_TYPE`、`CCY`、`TITLE_DEED_TYPE` 四組 common field options。 | Source confirmed |
| exposure value | `FACILITY_VALUE` 取自 `groupList[0].FACILITY_VALUE`；若查無資料則回空字串。畫面欄位為必填下拉。 | Source confirmed |
| 明細資料 | `groupList` 來自 `EPRO_TB_GROUP_EXPOSURE.find(APPLICATION_NO)`，預設依 `APPLICATION_NO`、`DATA_SEQ` 排序。 | Source confirmed |
| 查無明細 | 前端若 `dataMap.groupList` 為空/null，建立一筆空白列，預設三組 currency 為 USD。 | Source confirmed |
| 日期格式 | 查詢時 `MATURITY_DATE` 由 DB `yyyy-MM-dd` 轉 UI `dd/MM/yyyy`；保存時由 UI `dd/MM/yyyy` 轉 SQL Date。 | Source confirmed |
| 總額 | 查詢時計算 `totalLccUsd`、`totalLccKhr`、`totalOutstandUsd`、`totalOutstandKhr`。 | Source confirmed |
| 即時計算 | 前端在 LCC/Outstanding 幣別或金額變動時呼叫 `calculation`，回傳 `totalUsd`、`totalKhr`。 | Source confirmed |
| 非 USD 幣別 | `calculation` 將 USD 歸 USD，其他所有幣別歸 KHR；查詢總額只處理 USD/KHR。 | TBD / Legacy defect suspect |
| Outstanding currency | 前端 `OUTSTAND_AMOUNT_CUR` disabled，且在 LCC currency 變更時同步為同一幣別。 | Source confirmed |
| Collateral currency | 前端可獨立選擇 `COLLATERAL_CUR`；報表端疑似用 `OUTSTAND_AMOUNT_CUR` 格式化 collateral。 | Source confirmed / Legacy defect suspect |
| Save | Save 只驗證 `FACILITY_VALUE` 與已輸入 maturity date 格式，送 `check=Y`。 | Source confirmed |
| Finished | Finished 驗證 `FACILITY_VALUE` 與各列必填欄位，送 `check=N`。 | Source confirmed |
| 條件式必填 | `LOAN_LIMIT_TYPE == "1"` 或空白時，Finished 必填 Outstanding Amount 與 Maturity Date；其他值不強制這兩欄。 | Source confirmed |
| 保存交易 | 後端刪除該 `APPLICATION_NO` 所有 `TB_GROUP_EXPOSURE` 資料，再依前端順序重新 insert，並更新 checkpoint；全程包在 transaction。 | Source confirmed |
| 補正旗標 | 若查得任一明細 `LOAN_LIMIT_TYPE` 為 null，`queryGroupExposure=true`，前端把父頁籤 check 設回 `Y` 並移除 done。 | Source confirmed |
| 0215 舊案 | 0215 舊案不顯示 Finished，save callback 也不更新父頁籤 done 狀態。 | Source confirmed |

## 4. 需求矩陣

| Requirement ID | 需求 | 驗收重點 | 來源分類 |
|---|---|---|---|
| REQ-001 | 系統應提供 EPROC00115 初始化查詢，回傳 borrower group exposure 明細與四組下拉代碼。 | 可取得 `FACILITY_TYPE`、`LOAN_LIMIT_TYPE`、`CCY`、`TITLE_DEED_TYPE`。 | Source confirmed |
| REQ-002 | 系統應以 `APPLICATION_NO` 查詢 `TB_GROUP_EXPOSURE` 並依 `DATA_SEQ` 顯示。 | 查有資料時顯示全部明細；查無資料時建立一筆空白列。 | Source confirmed |
| REQ-003 | 系統應提供 exposure value 下拉欄位，保存時同一值寫入本案件所有明細列。 | `FACILITY_VALUE` 必填；保存後每列值一致。 | Source confirmed |
| REQ-004 | 系統應支援明細列新增、刪除與至少保留一列。 | 超過 `top.groupSize` 阻擋新增；只剩一列時阻擋刪除。 | Source confirmed |
| REQ-005 | 系統應依明細幣別計算 LCC 與 Outstanding 的 USD/KHR 總額。 | 查詢與即時計算結果一致；非 USD 規則需定案。 | Source confirmed / TBD |
| REQ-006 | 系統應依 Save / Finished 不同操作執行不同驗證與 checkpoint 值。 | Save -> `check=Y`；Finished -> `check=N`。 | Source confirmed |
| REQ-007 | 系統應在保存時 full replacement `TB_GROUP_EXPOSURE`，並在同一交易中更新 checkpoint。 | 任一 insert 或 checkpoint update 失敗時全部 rollback。 | Source confirmed |
| REQ-008 | 系統應依 0115/0215 與 CS/CU 分流更新正確 checkpoint 欄位。 | 0115 寫一般 checkpoint；0215 寫 RC checkpoint。 | Source confirmed |
| REQ-009 | 系統應提供舊資料補正機制或等價警示，處理 `LOAN_LIMIT_TYPE` 為 null 的既有資料。 | 是否保留需依待確認-007；若保留需讓頁籤回未完成。 | Source confirmed / TBD |
| REQ-010 | 系統應保護 `TB_GROUP_EXPOSURE` 作為跨模組資料來源，不得破壞報表與評分計算。 | 0170/0270、0180/0181、submit check 測試需覆蓋。 | Cross-module confirmed |

## 5. 功能規格

### 5.1 頁籤與使用情境

| 情境 | 舊功能 | 規格 |
|---|---|---|
| 一般公司戶案件 | `EPROC0_0115` | 使用 EPROC00115 的一般流程模式，父頁籤對應 `EPROC0_0110`，保存後檢查一般公司戶頁籤完成度。 |
| 展期/展變或 RC 公司戶案件 | `EPROC0_0215` | 使用 EPROC00115 的 RC 流程模式，父頁籤對應 `EPROC0_0210`，保存後檢查 RC 公司戶頁籤完成度。 |
| 0215 舊案檢視 | `EPROC00215.jsp` | 當案件為舊案時，Finished 按鈕不顯示；保存 callback 不更新父頁籤 done 狀態。 |

### 5.2 畫面欄位

| 區塊 | 欄位 | Source 欄位 / 來源 | 規則 |
|---|---|---|---|
| Header | Exposure of Borrower Group (including this facility) | `FACILITY_VALUE`；選項來源 `FACILITY_TYPE` | Save / Finished 均必填。 |
| Grid | Name in Borrower Group | `BORROWER_GROUP_NAME` | Finished 必填；maxlength 50。 |
| Grid | Loan or Limit Type | `LOAN_LIMIT_TYPE`；選項來源 `LOAN_LIMIT_TYPE` | Finished 必填；值 `1`/空白時啟用較嚴格必填。 |
| Grid | Loan or Credit Card Limit Amount - Currency | `LCC_AMOUNT_CUR`；選項來源 `CCY` | Finished 必填；變更時同步 Outstanding currency。 |
| Grid | Loan or Credit Card Limit Amount - Amount | `LCC_AMOUNT` | Finished 必填；正數金額；USD 2 位小數，非 USD 0 位小數。 |
| Grid | Outstanding Amount - Currency | `OUTSTAND_AMOUNT_CUR` | 前端 disabled，由 `LCC_AMOUNT_CUR` 同步。 |
| Grid | Outstanding Amount - Amount | `OUTSTAND_AMOUNT` | `LOAN_LIMIT_TYPE=1` 或空白時 Finished 必填；其他值不強制。 |
| Grid | Collateral Value - Currency | `COLLATERAL_CUR`；選項來源 `CCY` | Finished 必填；可與 LCC currency 不同。 |
| Grid | Collateral Value - Amount | `COLLATERAL_AMOUNT` | Finished 必填；正數金額。 |
| Grid | Type of Title Deed | `TITLE_DEED_TYPE`；選項來源 `TITLE_DEED_TYPE` | Finished 必填。 |
| Grid | Interest Rate (%) | `INTEREST_RATE` | Finished 必填；舊前端以金額數值限制處理。 |
| Grid | Tenor (Months) | `TENOR` | Finished 必填；integer length 5，0 位小數。 |
| Grid | Maturity Date | `MATURITY_DATE` | `LOAN_LIMIT_TYPE=1` 或空白時 Finished 必填；格式 `DD/MM/YYYY`。 |
| Grid | LTV (%) | `LTV` | Finished 必填；舊前端以金額數值限制處理。 |
| Total | Total Loan or Credit Card Limit Amount | `totalLccUsd`、`totalLccKhr` | 顯示用，不保存至 `TB_GROUP_EXPOSURE`。 |
| Total | Total Outstanding Amount | `totalOutstandUsd`、`totalOutstandKhr` | 顯示用，不保存至 `TB_GROUP_EXPOSURE`。 |

### 5.3 明細增刪

| 行為 | 規格 |
|---|---|
| 初始空列 | 查無 `groupList` 時，前端建立一列空白明細，`LCC_AMOUNT_CUR`、`OUTSTAND_AMOUNT_CUR`、`COLLATERAL_CUR` 預設 USD。 |
| Add | 僅可編輯且非查詢模式顯示；筆數達 `top.groupSize` 時阻擋並顯示 `COMMON_MSG_LIMIT`。 |
| Delete | 僅可編輯且非查詢模式顯示；刪除前顯示確認；只剩一列時阻擋並顯示 `COMMON_MSG_ONE_DATA`。 |
| DATA_SEQ | 保存時後端依 payload 順序重新編為 1..n。 |

### 5.4 Save / Finished

| 操作 | 舊系統參數 | 驗證 | 後端行為 |
|---|---|---|---|
| Save | `check=Y` | 必填 `FACILITY_VALUE`；已輸入的 `MATURITY_DATE` 若不空白需為有效柬埔寨日期格式。 | full replacement 保存資料，更新 checkpoint 為 `Y`。 |
| Finished | `check=N` | `FACILITY_VALUE` 與各列必要欄位必填；`LOAN_LIMIT_TYPE=1` 或空白時，Outstanding Amount 與 Maturity Date 也必填。 | full replacement 保存資料，更新 checkpoint 為 `N`，回傳全部頁籤完成狀態。 |

> 注意：舊系統 `check=Y/N` 的語意為 Save/Finished 狀態，不等同一般 `isFinish=true/false`。新版若使用 `isFinish`，需明確轉換：`isFinish=false -> check=Y`，`isFinish=true -> check=N`。

### 5.5 幣別與金額

| 項目 | 規格 |
|---|---|
| 金額輸入 | 正數；USD 使用 2 位小數並補零；非 USD 使用 0 位小數。 |
| LCC total | 依 `LCC_AMOUNT_CUR` 加總 `LCC_AMOUNT`，顯示 USD/KHR。 |
| Outstanding total | 依 `OUTSTAND_AMOUNT_CUR` 加總 `OUTSTAND_AMOUNT`，顯示 USD/KHR。 |
| 非 USD 幣別 | Source confirmed 的 `calculation` 將非 USD 歸 KHR，但查詢總額只明確處理 USD/KHR；新版需先定案，不可默默歸 KHR。 |
| Cross-module score | 0170/0270 suggested approval level 讀取 `LCC_AMOUNT_CUR`、`LCC_AMOUNT`；KHR 依 `LOAN_RATE` 換算為 USD 後納入核決層級判斷。 |

## 6. API / Interface 規格草案

> 以下 endpoint 為現代化命名草案；實際 path 可依既有 API 命名規範調整。payload 欄位與行為依舊系統 Source confirmed。

| API | 用途 | 對應舊 action |
|---|---|---|
| `GET /api/epro/eproc00115/info` | 初始化查詢 exposure 明細、總額、下拉代碼與補正旗標。 | `query` |
| `POST /api/epro/eproc00115/calculate` | 依幣別計算總額。 | `calculation` |
| `POST /api/epro/eproc00115/save` | Save 或 Finished 保存明細並更新 checkpoint。 | `save` |

### 6.1 查詢 Request / Response

| 欄位 | 必填 | 說明 |
|---|---|---|
| `applicationNo` | Y | 案件編號，對應舊 `APPLICATION_NO`。 |
| `legacyFunctionId` | Y | `EPROC0_0115` 或 `EPROC0_0215`，用於決定父頁籤與 checkpoint 類型。 |

| Response 欄位 | 說明 |
|---|---|
| `facilityMap` | Exposure of Borrower Group 選項，舊來源 `FACILITY_TYPE`。 |
| `loanLimitTypeMap` | Loan or Limit Type 選項，來源 `LOAN_LIMIT_TYPE`。 |
| `ccyMap` | 幣別選項，來源 `CCY`。 |
| `titleDeedMap` | Type of Title Deed 選項，來源 `TITLE_DEED_TYPE`。 |
| `facilityValue` | 舊 `FACILITY_VALUE`。 |
| `groupList` | `TB_GROUP_EXPOSURE` 明細列。 |
| `totalLccUsd` / `totalLccKhr` | LCC USD/KHR 合計。 |
| `totalOutstandUsd` / `totalOutstandKhr` | Outstanding USD/KHR 合計。 |
| `check` | 舊 checkpoint 欄位值。 |
| `hasBlankLoanLimitType` | 對應舊 `queryGroupExposure`。若任一明細 `LOAN_LIMIT_TYPE` 為 null，回 true。 |

### 6.2 保存 Request / Response

| 欄位 | 必填 | 說明 |
|---|---|---|
| `applicationNo` | Y | 案件編號。後端應以此值寫入每筆明細，不應信任明細列自帶案件編號。 |
| `legacyFunctionId` | Y | `EPROC0_0115` 或 `EPROC0_0215`。 |
| `isFinish` | Y | 建議新版欄位。保存時需轉換為舊 `check` 值。 |
| `facilityValue` | Y | 舊 `FACILITY_VALUE`。 |
| `groupList` | Y | Exposure 明細列。可為至少一列；是否允許空陣列需另定。 |
| `pageCheckMap` | Y | 父頁籤狀態，對應舊 `EPROC0_0110.getPageObj()` 或 `EPROC0_0210.getPageObj()`。 |

| Response 欄位 | 說明 |
|---|---|
| `isAllTabsCheck` | 保存後是否所有相關頁籤都完成。0115 由一般公司戶 progress 判斷；0215 由 RC 公司戶 progress 判斷。 |
| `message` | 成功回 `COMMON_MSG_SAVE_SUCCESS`；失敗依錯誤規則回傳。 |

## 7. 資料設計與 Mapping

### 7.1 主要資料表

| 資料表 | 用途 | 主鍵 / 排序 | 存取型態 |
|---|---|---|---|
| `OVSLXLON01.TB_GROUP_EXPOSURE` | Borrower group exposure 明細 | `APPLICATION_NO`、`DATA_SEQ` | 查詢、依案件刪除、逐筆新增 |
| `OVSLXLON01.TB_LON_SUMMARY_INFO` | 案件屬性判斷 | `APPLICATION_NO` | 讀取 `LON_ATTRIBUTE`、`SECURE_ATTRIBUTE` |
| `EPRO_TB_CHECK_POINT_CORP` | 一般公司戶 CS checkpoint | `APPLICATION_NO` | 更新 `EPROC0_0115` |
| `EPRO_TB_CHECK_POINT_CU` | 一般公司戶 CU checkpoint | `APPLICATION_NO` | 更新 `EPROC0_0115` |
| `EPRO_TB_CHECK_POINT_RC_CORP` | RC 公司戶 CS checkpoint | `APPLICATION_NO` | 更新 `EPROC0_0215` |
| `EPRO_TB_CHECK_POINT_RC_CU` | RC 公司戶 CU checkpoint | `APPLICATION_NO` | 更新 `EPROC0_0215` |

### 7.2 `TB_GROUP_EXPOSURE` 欄位 Mapping

| DB 欄位 | 畫面 / API 欄位 | 規則 |
|---|---|---|
| `APPLICATION_NO` | `applicationNo` | 後端應使用 request 案件編號。 |
| `DATA_SEQ` | `dataSeq` | 保存時依畫面順序重新編號 1..n。 |
| `FACILITY_VALUE` | `facilityValue` | 同一案件所有列保存相同 exposure value。 |
| `BORROWER_GROUP_NAME` | `borrowerGroupName` | Finished 必填，maxlength 50。 |
| `LOAN_LIMIT_TYPE` | `loanLimitType` | 選項來源 `LOAN_LIMIT_TYPE`；Finished 必填。 |
| `LCC_AMOUNT_CUR` | `lccAmountCurrency` | 選項來源 `CCY`。 |
| `LCC_AMOUNT` | `lccAmount` | 正數金額。 |
| `OUTSTAND_AMOUNT_CUR` | `outstandingAmountCurrency` | 前端由 LCC currency 同步。 |
| `OUTSTAND_AMOUNT` | `outstandingAmount` | 條件式必填。 |
| `COLLATERAL_CUR` | `collateralCurrency` | 選項來源 `CCY`。 |
| `COLLATERAL_AMOUNT` | `collateralAmount` | 正數金額。 |
| `TITLE_DEED_TYPE` | `titleDeedType` | 選項來源 `TITLE_DEED_TYPE`。 |
| `INTEREST_RATE` | `interestRate` | Finished 必填。 |
| `TENOR` | `tenor` | Finished 必填，月數。 |
| `MATURITY_DATE` | `maturityDate` | UI `DD/MM/YYYY`，DB Date。 |
| `LTV` | `ltv` | Finished 必填。 |

### 7.3 Checkpoint Mapping

| 舊功能 | 條件 | Checkpoint 表 | 欄位 | 頁籤完成度 |
|---|---|---|---|---|
| `EPROC0_0115` | `LON_ATTRIBUTE + SECURE_ATTRIBUTE == "CS"` | `EPRO_TB_CHECK_POINT_CORP` | `EPROC0_0115` | `getCheckedProgressCORP` |
| `EPROC0_0115` | 非 CS | `EPRO_TB_CHECK_POINT_CU` | `EPROC0_0115` | `getCheckedProgressCORP` |
| `EPROC0_0215` | `LON_ATTRIBUTE + SECURE_ATTRIBUTE == "CS"` | `EPRO_TB_CHECK_POINT_RC_CORP` | `EPROC0_0215` | `getCheckedProgressRC_CORP` |
| `EPROC0_0215` | 非 CS | `EPRO_TB_CHECK_POINT_RC_CU` | `EPROC0_0215` | `getCheckedProgressRC_CORP` |

### 7.4 Cross-module Data Impact

| 消費模組 | 使用資料 | 影響 |
|---|---|---|
| `EPROCS_0170_mod`、`EPROCS_0270_mod` | `LCC_AMOUNT_CUR`、`LCC_AMOUNT` | suggested approval level 計算會加總 borrower group LCC；KHR 會依 `LOAN_RATE` 換算。 |
| `EPROCU_0170_mod`、`EPROCU_0270_mod` | `LCC_AMOUNT_CUR`、`LCC_AMOUNT` | CU 流程核決層級同樣受本頁保存金額影響。 |
| `EPRO_CS0180`、`EPRO_CS0181`、`EPRO_CU0180`、`EPRO_CU0181` | 明細全欄位與總額 | 產出 Borrower Group Exposure 報表區塊與 `TOTAL_LCC_AMOUNT`、`TOTAL_OUTSTAND_AMOUNT`。 |
| `EPROZ0_0300` | `LOAN_LIMIT_TYPE` 是否 null | submit / upload 前的 Credit Investigation 完成性檢核。 |

## 8. 業務規則

| 編號 | 規則 | 分類 |
|---|---|---|
| BR-001 | `applicationNo` 不可空白；空白時舊系統拋 `COMMON_MSG_ERROR_LON`。 | Source confirmed |
| BR-002 | 進入頁籤需回傳 `FACILITY_TYPE`、`LOAN_LIMIT_TYPE`、`CCY`、`TITLE_DEED_TYPE` 選項。 | Source confirmed |
| BR-003 | 查無 `TB_GROUP_EXPOSURE` 時，畫面需提供一筆空白列供輸入。 | Source confirmed |
| BR-004 | Save 與 Finished 保存時，`TB_GROUP_EXPOSURE` 採 full replacement。 | Source confirmed |
| BR-005 | `DATA_SEQ` 由後端依保存順序重新編號，不由使用者輸入。 | Source confirmed |
| BR-006 | `OUTSTAND_AMOUNT_CUR` 應與 `LCC_AMOUNT_CUR` 同步。 | Source confirmed |
| BR-007 | `LOAN_LIMIT_TYPE=1` 或空白時，Finished 必填 Outstanding Amount 與 Maturity Date。 | Source confirmed |
| BR-008 | `LOAN_LIMIT_TYPE` 非 `1` 時，Finished 不強制 Outstanding Amount 與 Maturity Date。 | Source confirmed |
| BR-009 | Save 只需驗證 exposure value 與非空 maturity date 格式，不要求全部明細必填。 | Source confirmed |
| BR-010 | Finished 必須通過完整欄位必填與格式驗證後才可保存。 | Source confirmed |
| BR-011 | 0115 與 0215 不可混用 checkpoint 表與父頁籤完成度計算。 | Source confirmed |
| BR-012 | 若任一既有明細 `LOAN_LIMIT_TYPE` 為 null，需依待確認-007 決定是否將頁籤重新標為未完成。 | Source confirmed / TBD |
| BR-013 | 新版保存時應以 request `applicationNo` 寫入所有明細，避免沿用舊系統信任前端 row-level `APPLICATION_NO` 的風險。 | Recommendation from legacy defect suspect |

## 9. 錯誤處理

| 場景 | 舊系統行為 | 新版規格 |
|---|---|---|
| 查詢無資料 | `DataNotFoundException` 回 `MSG_DATA_NOT_FOUND`。 | 回可辨識錯誤碼；若只是 `TB_GROUP_EXPOSURE` 無明細，應回空清單而非錯誤。 |
| 查詢超過筆數 | `OverCountLimitException` 回 `MSG_OVER_COUNT_LIMIT`。 | 保留等價錯誤碼。 |
| 查詢失敗 | 一般 exception 回 `MSG_QUERY_FAIL`。 | 回查詢失敗並記錄 transaction id、legacyFunctionId、applicationNo。 |
| 幣別加總失敗 | `calculation` exception 回 `COMMON_MSG_TOTAL_FAIL`。 | 前端需提示總額計算失敗，避免使用者誤判總額。 |
| 保存輸入錯誤 | `ErrorInputException` 回原 exception message，例如 `COMMON_MSG_ERROR_LON`。 | 回 400 類型業務錯誤。 |
| 保存失敗 | 舊 trx catch 區塊多回 `MSG_QUERY_FAIL`；module 會 rollback。 | 新版應回保存失敗訊息，並確保 DB 沒有部分刪除或部分新增。 |

## 10. 非功能需求

| 類別 | 需求 |
|---|---|
| 交易一致性 | 保存時 `TB_GROUP_EXPOSURE` 刪除/新增與 checkpoint update 必須原子化；任一失敗全部 rollback。 |
| 稽核 | 舊系統對 query 使用 Query/Table，calculation 使用 Transfer/StoredProcedure，save 使用 Edit/Table。新版需保留等價 audit log。 |
| 權限 | 非編輯模式或查詢模式需停用欄位並隱藏 Add / Delete / Save / Finished。 |
| 資料完整性 | 後端需統一填入 `APPLICATION_NO`、`DATA_SEQ`、`FACILITY_VALUE`，避免前端 payload 污染 DB。 |
| 相容性 | 日期格式需維持 `DD/MM/YYYY`；金額 USD 2 位小數、KHR 0 位小數。 |
| 可觀測性 | 記錄保存前後筆數、legacyFunctionId、checkpoint 值與 rollback 事件，便於追查跨模組報表/評分差異。 |
| Cross-module compatibility | 調整欄位與幣別規則前，需評估 0170/0270 suggested approval level 與 0180/0181 報表輸出。 |

## 11. 測試與驗收

| 測試編號 | 情境 | 前置條件 | 預期結果 | 優先 |
|---|---|---|---|---|
| AC-001 | 0115 初始化 | 案件有 `TB_GROUP_EXPOSURE` 明細。 | 回傳明細、總額、四組下拉選項、一般 checkpoint 值。 | 高 |
| AC-002 | 0215 初始化 | 案件有 RC 流程資料。 | 回傳明細、總額、四組下拉選項、RC checkpoint 值。 | 高 |
| AC-003 | 查無明細 | `TB_GROUP_EXPOSURE` 無資料。 | 畫面建立一筆空白列，三組 currency 預設 USD，`FACILITY_VALUE` 空白。 | 高 |
| AC-004 | 讀取日期 | DB `MATURITY_DATE` 有值。 | 畫面顯示 `DD/MM/YYYY`。 | 中 |
| AC-005 | Add 上限 | 明細筆數等於 `top.groupSize` 或新版上限。 | 阻擋新增並顯示等價 `COMMON_MSG_LIMIT`。 | 中 |
| AC-006 | Delete 剩一列 | 畫面只剩一筆明細。 | 阻擋刪除並顯示等價 `COMMON_MSG_ONE_DATA`。 | 中 |
| AC-007 | LCC currency 變更 | 將某列 LCC currency 由 USD 改 KHR。 | 清空 LCC/Outstanding 金額，同步 Outstanding currency，重新計算總額。 | 高 |
| AC-008 | Collateral currency | 將 collateral currency 改為不同於 LCC。 | 畫面與保存資料保留獨立 `COLLATERAL_CUR`。 | 中 |
| AC-009 | Save 草稿 | 部分 Finished 必填欄位空白，但 `FACILITY_VALUE` 已填。 | 可保存，checkpoint 寫 `Y`，資料表依 payload 重建。 | 高 |
| AC-010 | Save 日期格式錯誤 | `MATURITY_DATE` 非空但格式錯誤。 | Save 阻擋，不呼叫保存。 | 高 |
| AC-011 | Finished 完整資料 | 所有必填欄位完整。 | 保存成功，checkpoint 寫 `N`，回傳 `isAllTabsCheck`。 | 高 |
| AC-012 | Finished 缺 exposure value | `FACILITY_VALUE` 空白。 | validation 阻擋，不保存。 | 高 |
| AC-013 | Finished loanLimitType=1 缺 outstanding | `LOAN_LIMIT_TYPE=1` 且 `OUTSTAND_AMOUNT` 空白。 | validation 阻擋。 | 高 |
| AC-014 | Finished loanLimitType=1 缺 maturity | `LOAN_LIMIT_TYPE=1` 且 `MATURITY_DATE` 空白。 | validation 阻擋。 | 高 |
| AC-015 | Finished loanLimitType 非 1 | `LOAN_LIMIT_TYPE` 為非 `1` 值，Outstanding/Maturity 空白。 | 不因這兩欄空白而阻擋；其他必填仍需通過。 | 高 |
| AC-016 | USD/KHR total | 多筆明細含 USD 與 KHR。 | LCC 與 Outstanding 的 USD/KHR 合計正確。 | 高 |
| AC-017 | 第三幣別 | `CCY` 有 USD/KHR 以外幣別。 | 依待確認-004 決策驗證，不可造成查詢與即時計算不一致。 | 中 |
| AC-018 | 0115 checkpoint CS | `LON_ATTRIBUTE + SECURE_ATTRIBUTE = CS`。 | 更新 `EPRO_TB_CHECK_POINT_CORP.EPROC0_0115`。 | 高 |
| AC-019 | 0115 checkpoint CU | 屬性非 CS。 | 更新 `EPRO_TB_CHECK_POINT_CU.EPROC0_0115`。 | 高 |
| AC-020 | 0215 checkpoint CS | `LON_ATTRIBUTE + SECURE_ATTRIBUTE = CS`。 | 更新 `EPRO_TB_CHECK_POINT_RC_CORP.EPROC0_0215`。 | 高 |
| AC-021 | 0215 checkpoint CU | 屬性非 CS。 | 更新 `EPRO_TB_CHECK_POINT_RC_CU.EPROC0_0215`。 | 高 |
| AC-022 | 0215 舊案 | `${attrMap.isOld}=true` 或新版等價條件。 | 不顯示 Finished，或依待確認-006 決策處理。 | 中 |
| AC-023 | LOAN_LIMIT_TYPE null 補正 | DB 有舊資料 `LOAN_LIMIT_TYPE` 為 null。 | 依待確認-007；若保留，頁籤狀態回未完成。 | 中 |
| AC-024 | 保存交易失敗 | delete 後 insert 或 checkpoint update 發生例外。 | `TB_GROUP_EXPOSURE` 與 checkpoint 不得部分成功。 | 高 |
| AC-025 | Cross-module approval level | 保存 LCC 金額後進入 0170/0270 評分。 | suggested approval level 讀到最新 `LCC_AMOUNT_CUR` / `LCC_AMOUNT`。 | 高 |
| AC-026 | Cross-module report | 保存明細後產 0180/0181 報表。 | Borrower Group Exposure 區塊依 `DATA_SEQ` 顯示，總額正確。 | 高 |
| AC-027 | applicationNo 防護 | payload 明細帶錯誤 `APPLICATION_NO`。 | 新版後端應以 request `applicationNo` 覆寫或拒絕，不能寫到其他案件。 | 高 |

## 12. Source Evidence 與決策紀錄

| 證據 | 檔案 | 結論 |
|---|---|---|
| AJAX action | `EPROC0_0115.java`、`EPROC0_0215.java` | 舊功能暴露 `query`、`calculation`、`save` 三個 action。 |
| 下拉代碼 | `EPROC0_0115_mod.java`、`EPROC0_0215_mod.java` | 四組選項為 `FACILITY_TYPE`、`LOAN_LIMIT_TYPE`、`CCY`、`TITLE_DEED_TYPE`。 |
| 0115 父頁籤 | `EPROC0_0115.java`、`EPROC00115_JS.jsp` | 保存後使用 `EPROC0_0110` 與 `getCheckedProgressCORP`。 |
| 0215 父頁籤 | `EPROC0_0215.java`、`EPROC00215_JS.jsp` | 保存後使用 `EPROC0_0210` 與 `getCheckedProgressRC_CORP`；舊案不更新 done。 |
| Save/Finished check 值 | `EPROC00115_JS.jsp`、`EPROC00215_JS.jsp` | Save 呼叫 `save('Y')`；Finished 呼叫 `save('N')`。 |
| 條件式必填 | `EPROC00115_JS.jsp`、`EPROC00215_JS.jsp` | `LOAN_LIMIT_TYPE == '1'` 或空白時，Outstanding Amount 與 Maturity Date 必填。 |
| 資料表欄位 | `EPRO_TB_GROUP_EXPOSURE.java` | fieldNames 與 `orderPrimaryKey` 確認 exposure 欄位與排序。 |
| 資料庫 SQL | `EPRO_TB_GROUP_EXPOSURE.SQL_FIND_001`、`SQL_INSERT_001`、`SQL_DELETE_APP_001` | 查詢條件、insert 欄位與依案件刪除規則。 |
| 保存交易 | `EPROC0_0115_mod.java`、`EPROC0_0215_mod.java` | `Transaction.begin` 後 deleteApp、insert、checkpoint update，例外時 rollback。 |
| 補正旗標 | `EPROC0_0115_mod.queryGroupExposure`、`EPROC0_0215_mod.queryGroupExposure`、`EPROZ0_0300_mod.queryGroupExposure` | `LOAN_LIMIT_TYPE` null 會回 true。 |
| Cross-module score | `EPROCS_0170_mod`、`EPROCS_0270_mod`、`EPROCU_0170_mod`、`EPROCU_0270_mod` | Suggested approval level 使用 group exposure LCC 金額。 |
| Cross-module report | `EPRO_CS0180`、`EPRO_CS0181`、`EPRO_CU0180`、`EPRO_CU0181` | 報表讀取 group exposure 明細與總額。 |

## 13. 準備與完成定義

| 階段 | 條件 |
|---|---|
| 開發前 | 待確認-002、003、004、006、007、008、009 已有 PM/SA/RD 決策。 |
| 開發前 | API path、DTO 命名、`isFinish` 與舊 `check` 值轉換已定案。 |
| 開發完成 | 0115/0215 初始化、Save、Finished、checkpoint、rollback 測試通過。 |
| 開發完成 | `TB_GROUP_EXPOSURE` 的 cross-module report 與 score 影響有測試案例覆蓋。 |
| 上線前 | UAT 以至少一筆 CS、一筆 CU、一筆 0215 RC 舊案/新案測試完成。 |
