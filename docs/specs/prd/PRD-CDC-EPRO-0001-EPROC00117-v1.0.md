業務需求導向的功能規格書

CDC-EPRO-0001 EPROC00117 Financial Evaluation Table GI PRD

台中資訊開發中心

版本 1.0

文件日期：2026/06/15

# EPROC00117 公司戶財務評估表 GI PRD

| 文件項目 | 內容 |
|---|---|
| 文件名稱 | EPROC00117 公司戶財務評估表 GI PRD |
| 系統 | E-Proposal |
| 模組 | C0 公司戶徵信/評分資料 |
| 功能代號 | EPROC00117 |
| 舊系統程式 | EPROC0_0117、EPROC0_0217 |
| 功能英文名稱 | Financial Evaluation Table GI |
| 功能中文名稱 | 公司戶財務評估表 GI / 償債能力分析 |
| 適用流程 | EPROC0_0110 一般公司戶徵信流程；EPROC0_0210 RC 流程 |
| 主要使用者 | RM、徵信/審查人員、覆核人員 |
| 產出檔案 | CDC-EPRO-0001_EPROC00117_PRD_v1.0.md、CDC-EPRO-0001_EPROC00117_PRD_v1.0.docx |

## 0. 文件控制

| 日期 | 版本 | 說明 | 作者 |
|---|---|---|---|
| 2026-06-15 | v1.0 | 依 EPROC0_0117 與 EPROC0_0217 舊系統 Source code 掃描產出初版 PRD | Codex |

| 角色 | Review 重點 |
|---|---|
| PM | 確認 GI 財務評估表的業務名稱、適用流程、Save/Finished 語意、需呈現的比率與 DSR 項目是否符合現行作業 |
| SA | 確認 ratio 公式、資料來源表、查詢模式與編輯模式資料來源差異、checkpoint 與父頁異動規則 |
| RD | 確認 API/DTO、交易一致性、full replacement 儲存策略、日期格式與後端欄位信任邊界 |
| QA | 依正向、負向、邊界與跨頁資料連動測試案例驗證 0117/0217 行為 |

## 0.1 文件目的與範圍

| 項目 | 說明 |
|---|---|
| 文件目的 | 定義公司戶 GI 業務型態下，財務評估表與 DSR 資訊的查詢、計算、儲存、完成與跨頁連動需求。 |
| 涵蓋功能 | EPROC0_0117 一般流程、EPROC0_0217 RC 流程、前端 JSP/JS、交易層 AJAX action、module 計算邏輯、DAO/SQL 資料表、checkpoint 更新。 |
| 不涵蓋功能 | FI 財務評估表 EPROC0_0120/0220、個人戶 I0 財務評估、報表版面細節、Corporate Scorecard 公式本身。 |
| 來源限制 | 本文件以舊系統 Source code 為主要事實來源；中文註解在原始碼終端顯示有亂碼時，以 class/method/field 名稱與可辨識流程作為判讀依據。 |

## 0.2 待確認事項與風險

| ID | 類型 | 說明 | 建議處理 |
|---|---|---|---|
| TBD-001 | Source 差異 | inventory 將 0117/0217 action 記為 `getRate`，但交易層 annotation 實際為 `getTotal`；method 名稱是 `doGetRate`。 | API 規格以 source annotation `getTotal` 為準，migration inventory 需修正。 |
| TBD-002 | 需求確認 | `initQuery` 在 query action 下讀取已存 `TB_FINANCIAL_EVALUATION_GI`；非 query action 則由 0116/0216 財報 GI 即時計算。 | PM/SA 確認「查詢模式看歷史保存值、編輯模式重算」是否為目標行為。 |
| TBD-003 | 資料一致性 | ratio 計算用 Balance/Income/Cashflow 三張 GI 清單按 `DATA_SEQ` 對齊，但 source 未檢查三張筆數是否一致。 | 新系統應補筆數與 `DATA_SEQ` 對齊檢核，避免 index 錯誤或年度錯配。 |
| TBD-004 | Legacy defect suspect | AP turnover 為 0 時，source 將 `NUM_OF_DAYS_FOR_INVENTORY` 設為 `N/A`，不是 `DAYS_FOR_AP`。 | SA/RD 確認是否修正為 AP days 欄位；若為相容性需求需明確註記。 |
| TBD-005 | Legacy defect suspect | query action 若查無已存 GI ratio，module 回傳 `null`，但 JS 直接讀 `_giList.length`。 | 新系統應統一回傳空陣列並顯示無資料或提示需先完成財報 GI。 |
| TBD-006 | 資安/資料完整性 | `infoList` 的 `APPLICATION_NO` 與 `DATA_SEQ` 由前端組出，後端 save 未逐筆覆寫成 request `APPLICATION_NO`。 | API 儲存時應以 path/body 主鍵覆寫明細主鍵，避免 payload 竄改。 |
| TBD-007 | 需求確認 | DSR item currency select 在 JS 中固定 disabled `USD`，交易層仍取得 `ccyMap` 但本頁未使用。 | PM/SA 確認 DSR 金額是否永遠 USD；若需多幣別，需補匯率與 UI 規格。 |
| TBD-008 | 需求確認 | Item 數量上限使用全域 `top.corSize`，source 未在本功能內定義實際數值。 | SA/RD 需確認現行參數值與新系統上限。 |
| TBD-009 | Legacy exposure | `getExist` action 存在但 EPROC00117/00217 JS 未呼叫，屬共用 module 保留介面。 | 若新系統只實作本頁，需評估是否保留相容 API。 |
| TBD-010 | 需求確認 | 0217 RC 舊案 `${attrMap.isOld}` 時 Save callback 不更新父頁 done 狀態，Finished 按鈕也依 JSP 條件隱藏。 | PM/SA 確認 old case 的可操作性與狀態更新規則。 |
| TBD-011 | 公式確認 | Revenue growth 與 Net profit growth 使用當期年化值對前期原始值比較；若前期期間不是 12 個月，可能不一致。 | SA/財務規格確認是否維持 legacy 邏輯或改為兩期皆年化。 |

## 1. 業務目標

| ID | 目標 |
|---|---|
| GOAL-001 | 讓徵信人員可檢視公司戶 GI 財報資料計算出的流動性、財務結構、營運能力、獲利能力與其他財務指標。 |
| GOAL-002 | 讓使用者維護一到多筆 DSR item，輸入 EBIT 與債務付款資訊，系統計算每筆 DSR 倍數。 |
| GOAL-003 | 在一般流程 0117 與 RC 流程 0217 使用同一套財務評估邏輯，但分別更新不同父頁與 checkpoint。 |
| GOAL-004 | 當 0116/0216 財報 GI 來源資料異動時，能要求 0117/0217 重新檢視並完成。 |
| GOAL-005 | 儲存時維持舊系統 full replacement 行為，確保同一申請案的 GI ratio 與 DSR item 與畫面一致。 |

## 2. Source Scan 摘要

| 類別 | Source | Source-confirmed 結論 |
|---|---|---|
| 0117 交易層 | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0117.java` | AJAX actions 為 `initQuery`、`getTotal`、`getExist`、`save`；save 後用 `EPROC0_0110` 計算父頁完成狀態。 |
| 0217 交易層 | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0217.java` | actions 與 0117 相同；save 後用 `EPROC0_0210` 與 `getCheckedProgressRC_CORP` 計算 RC 父頁完成狀態。 |
| 0117 module | `EPROC0_0117_mod.java` | 查詢/計算 GI ratio、格式化日期與數值、儲存 `TB_FINANCIAL_EVALUATION_GI` 與 `TB_FINANCIAL_EVALUATION_INFO_CORP`，更新 CORP/CU checkpoint 欄位 `EPROC0_0117`。 |
| 0217 module | `EPROC0_0217_mod.java` | 與 0117 同邏輯，更新 RC CORP/CU checkpoint 欄位 `EPROC0_0217`。 |
| 共用 module | `EPRO_C00111.java` | 查主借戶名稱與 DSR item，計算 `DSR = EBIT / (Debt Payment + Existing Payment + Estimate Payment + Other Debt Payment)`。 |
| 0117 UI | `EPROC00117.jsp`、`EPROC00117_JS.jsp` | 顯示 Applicant Name、Item、Ratios；Add/Remove、Save、Finished；Finished 先做必填檢核。 |
| 0217 UI | `EPROC00217.jsp`、`EPROC00217_JS.jsp` | UI 與 0117 同邏輯；RC old case 對 Finished 與父頁 done 更新有條件限制。 |
| Ratio DAO | `EPRO_TB_FINANCIAL_EVALUATION_GI.java` | 主鍵排序 `APPLICATION_NO, DATA_SEQ`；欄位包含 30 個 ratio 與 `RATIOS_DATE`。 |
| DSR DAO | `EPRO_TB_FINANCIAL_EVALUATION_INFO_CORP.java` | 主鍵排序 `APPLICATION_NO, DATA_SEQ`；欄位包含 EBIT、付款資訊與 DSR。 |
| 財報來源 DAO | `EPRO_TB_FIN_STATEMENT_BALANCE_GI`、`INCOME_GI`、`CASHFLOW_GI` | ratio 計算來源，依 `DATA_SEQ` 對齊年度資料。 |
| 父頁 module | `EPROC0_0110_mod.java`、`EPROC0_0210_mod.java` | 切換 Assessment Type 或 Business Type 時刪除 GI/FI 財報與評估資料，並依業務型態重設可用頁籤 checkpoint。 |
| 財報頁 module | `EPROC0_0116_mod.java`、`EPROC0_0216_mod.java` | 儲存 GI 財報後把 `EPROC0_0117` 或 `EPROC0_0217` checkpoint 設回 `Y`，要求重新完成財務評估表。 |
| CS/CU report | `EPRO_CS0180.java`、`EPRO_CU0180.java` | 若 `BUSINESS_TYPE = G`，讀取 `TB_FINANCIAL_EVALUATION_INFO_CORP` 並輸出 DSR1、DSR2 等報表摘要。 |
| CS/CU common | `EPRO_CS0110.java`、`EPRO_CU0110.java` | 依 Assessment Type 與 Business Type 異動 0112/0111/0117 或 0212/0211/0217 checkpoint。 |
| Inventory | `eproposal-inventory/function-inventory.csv` | 0117 描述為 Financial Evaluation Table GI；0217 同屬 C0 公司戶徵信/評分資料，但 action 名稱與 source 有差異。 |

## 3. 角色與權限

| 規則 | 說明 | 證據等級 |
|---|---|---|
| 編輯權限 | JSP 依 `isEditor117` 或 `isEditor217` 並且非 query mode 顯示 Add/Save/Finished；無權或查詢模式時 `.isView117/.isView217` disabled。 | Source confirmed |
| 0117 狀態更新 | 0117 Save/Finished callback 在 edit mode 呼叫 `EPROC0_0110.check('EPROC0_0117', check)`，並依 `isAllTabsCheck` 更新父頁 done class。 | Source confirmed |
| 0217 狀態更新 | 0217 callback 僅在 edit 且非 old case 呼叫 `EPROC0_0210.check('EPROC0_0217', check)`；非 old case 才更新父頁 done class。 | Source confirmed |
| Save/Finished 語意 | Save 傳 `check=Y`；Finished 先做前端 validation，通過後傳 `check=N`。 | Source confirmed |
| CS/CU checkpoint | 0117 依 `LON_ATTRIBUTE + SECURE_ATTRIBUTE == CS` 更新 CORP checkpoint，否則更新 CU checkpoint；0217 對應 RC CORP/CU checkpoint。 | Source confirmed |

## 4. 功能流程

### 4.1 初始化

| 步驟 | 系統行為 | 證據等級 |
|---|---|---|
| INIT-001 | 前端呼叫 `/EPROC0_0117/initQuery` 或 `/EPROC0_0217/initQuery`，傳入 `APPLICATION_NO` 與 `action`。 | Source confirmed |
| INIT-002 | 後端取得幣別 common field options `CCY`，但本頁 Item 金額 select 實際固定 disabled `USD`。 | Source confirmed / TBD |
| INIT-003 | 後端用 `EPRO_C00111.query(APPLICATION_NO)` 取得主借戶名稱與已存 DSR item list。 | Source confirmed |
| INIT-004 | 後端用 0117/0217 module 取得 `giList`。query action 讀已存 ratio；非 query action 從 0116/0216 財報 GI 即時計算。 | Source confirmed |
| INIT-005 | 前端顯示主借戶名稱、建立 DSR item table、填入 ratio span；不足 5 個年度欄位以空白顯示。 | Source confirmed |

### 4.2 Item 維護與 DSR 計算

| 步驟 | 系統行為 | 證據等級 |
|---|---|---|
| ITEM-001 | 每筆 item 顯示 EBIT、Debt Payment、Existing Payment、Estimate Payment、Other Debt Payment 與 DSR。 | Source confirmed |
| ITEM-002 | 使用者可按 Add New 新增 item；若 item 數量等於 `top.corSize`，顯示 `COMMON_MSG_LIMIT` 並禁止新增。 | Source confirmed / TBD |
| ITEM-003 | 使用者可刪除 item；若只剩一筆則顯示 `COMMON_MSG_ONE_DATA` 並禁止刪除。 | Source confirmed |
| ITEM-004 | 使用者異動非 DSR 金額後，前端呼叫 `getTotal`，後端回傳 DSR 並更新畫面。 | Source confirmed |
| ITEM-005 | Save 不執行前端必填檢核；Finished 會執行 `valid.executeCheck()`，檢核 item 金額欄位。 | Source confirmed |

### 4.3 Ratio 顯示

| 步驟 | 系統行為 | 證據等級 |
|---|---|---|
| RATIO-001 | ratio 最多顯示 5 個年度欄位，欄位 id 為 `RATIOS_DATE_0` 到 `RATIOS_DATE_4` 與各 ratio 對應 span。 | Source confirmed |
| RATIO-002 | 百分比欄位加 `%`；`INTEREST_COVERAGE`、`LEVERAGE`、`DE_RATIO` 加 `x`；其他數值顯示 2 位小數。 | Source confirmed |
| RATIO-003 | 內部計算 scale 5、`ROUND_HALF_DOWN`，最後透過 `formatTwo` 轉為 2 位小數；`N/A` 與 `-` 不轉換。 | Source confirmed |
| RATIO-004 | 如果任一財報 GI 來源清單不存在，非 query action 回傳空清單。 | Source confirmed |
| RATIO-005 | query action 讀取已存 ratio 時將 `RATIOS_DATE` 從 `yyyy/MM/dd` 轉為 `dd/MM/yyyy`。 | Source confirmed |

### 4.4 儲存與完成

| 步驟 | 系統行為 | 證據等級 |
|---|---|---|
| SAVE-001 | 前端整理全部 item 為 `infoList`，逐筆放入 `APPLICATION_NO` 與 `DATA_SEQ`。 | Source confirmed |
| SAVE-002 | 前端將目前 `_giList` 與 `infoList` 一起送至 `save`。ratio 表本身為顯示資料，畫面沒有直接編輯 ratio 的 input。 | Source confirmed |
| SAVE-003 | 後端儲存前把 `RATIOS_DATE` 從 `dd/MM/yyyy` 轉為 `yyyy/MM/dd`，數值型 ratio 轉字串。 | Source confirmed |
| SAVE-004 | 後端以 transaction 執行 full replacement：刪除該 `APPLICATION_NO` 的 `TB_FINANCIAL_EVALUATION_GI` 後重插 `giList`；刪除 `TB_FINANCIAL_EVALUATION_INFO_CORP` 後重插 `infoList`。 | Source confirmed |
| SAVE-005 | 後端依 `check` 更新 `EPROC0_0117` 或 `EPROC0_0217` checkpoint；成功回 `COMMON_MSG_SAVE_SUCCESS`。 | Source confirmed |
| SAVE-006 | 交易失敗 rollback，回 `COMMON_MSG_SAVE_FAIL`；查詢失敗回 `MSG_QUERY_FAIL` 或 module message。 | Source confirmed |

## 5. API 規格

### 5.1 initQuery

| 項目 | 0117 | 0217 |
|---|---|---|
| Endpoint | `/EPROC0_0117/initQuery` | `/EPROC0_0217/initQuery` |
| Method | AJAX POST | AJAX POST |
| Request | `APPLICATION_NO`, `action` | `APPLICATION_NO`, `action` |
| Response | `ccyMap`, `dataMap`, `giList` | `ccyMap`, `dataMap`, `giList` |
| Audit | Query / Table | Query / Table |

| Response 欄位 | 說明 |
|---|---|
| `dataMap.MAIN_BORROWER_NAME` | 主借戶名稱，來源 `TB_MAIN_BORROWER_INFO_CORP`。 |
| `dataMap.infoList` | DSR item list，來源 `TB_FINANCIAL_EVALUATION_INFO_CORP`。 |
| `dataMap.check` | 前端嘗試讀取並設定 checkbox；source scan 未在 `EPRO_C00111.query` 找到輸出來源，需 SA/RD 補確認。 |
| `giList` | GI ratio list，來源為已存 ratio 或財報 GI 即時計算結果。 |

### 5.2 getTotal

| 項目 | 規格 |
|---|---|
| Endpoint | `/EPROC0_0117/getTotal`、`/EPROC0_0217/getTotal` |
| Method | AJAX POST |
| Request | `infoMap` JSON |
| Response | `dataMap.DSR` |
| Formula | `DSR = EBIT / (DEBT_PAYMENT + EXISTING_PAYMENT + ESTIMATE_PAYMENT + OTHER_DEBT_PAYMENT)` |
| Rounding | 小數 2 位，`ROUND_HALF_DOWN` |
| Zero rule | `EBIT = 0` 或分母為 0 時回傳 `0` |
| Error | `COMMON_MSG_TOTAL_FAIL` |

### 5.3 getExist

| 項目 | 規格 |
|---|---|
| Endpoint | `/EPROC0_0117/getExist`、`/EPROC0_0217/getExist` |
| Method | AJAX POST |
| Request | `infoMap` JSON |
| Source 行為 | 呼叫 `EPRO_C00111.getExist`，使用 `M_EXIST_INSTALLMENT_AMT` 與 `M_EST_INSTALLMENT_AMT` 計算 `TOTAL_INSTALLME`，並計算月支出比、負債服務比等共用欄位。 |
| 本頁使用狀態 | EPROC00117/00217 JS 未呼叫此 action。 |
| Error | `COMMON_MSG_TOTAL_FAIL` |

### 5.4 save

| 項目 | 0117 | 0217 |
|---|---|---|
| Endpoint | `/EPROC0_0117/save` | `/EPROC0_0217/save` |
| Method | AJAX POST | AJAX POST |
| Request | `APPLICATION_NO`, `giList`, `infoList`, `check`, `pageCheckMap` | 同 0117 |
| Parent page | `EPROC0_0110` | `EPROC0_0210` |
| Progress check | `getCheckedProgressCORP` | `getCheckedProgressRC_CORP` |
| Checkpoint | `EPROC0_0117` | `EPROC0_0217` |
| Success | `COMMON_MSG_SAVE_SUCCESS` | `COMMON_MSG_SAVE_SUCCESS` |
| Error | `COMMON_MSG_SAVE_FAIL` | `COMMON_MSG_SAVE_FAIL` |

## 6. 資料模型

### 6.1 EPRO_TB_FINANCIAL_EVALUATION_INFO_CORP

| 欄位 | 說明 | 來源/規則 |
|---|---|---|
| `APPLICATION_NO` | 申請案號 | 前端送出；建議後端覆寫為 request 主鍵 |
| `DATA_SEQ` | item 序號 | 前端依 item id 送出 |
| `EBIT_CURRENCY` | EBIT 幣別 | UI 固定 disabled USD |
| `EBIT` | EBIT 金額 | 必填檢核於 Finished；允許 2 位小數 |
| `DEBT_PAYMENT_CURRENCY` | Debt Payment 幣別 | UI 固定 disabled USD |
| `DEBT_PAYMENT` | Debt Payment 金額 | DSR 分母之一 |
| `EXISTING_PAYMENT_CURRENCY` | Existing Payment 幣別 | UI 固定 disabled USD |
| `EXISTING_PAYMENT` | Existing Payment 金額 | DSR 分母之一 |
| `ESTIMATE_PAYMENT_CURRENCY` | Estimate Payment 幣別 | UI 固定 disabled USD |
| `ESTIMATE_PAYMENT` | Estimate Payment 金額 | DSR 分母之一 |
| `OTHER_DEBT_PAYMENT_CURRENCY` | Other Debt Payment 幣別 | UI 固定 disabled USD |
| `OTHER_DEBT_PAYMENT` | Other Debt Payment 金額 | DSR 分母之一 |
| `DSR_CURRENCY` | DSR 幣別欄位 | DAO 欄位存在，但本頁 JS save 未設定；DSR 為倍數非幣別 |
| `DSR` | DSR 倍數 | `getTotal` 回傳，畫面顯示 `x` |

### 6.2 EPRO_TB_FINANCIAL_EVALUATION_GI

| 欄位 | 說明 |
|---|---|
| `APPLICATION_NO` | 申請案號 |
| `DATA_SEQ` | 財報年度序號，與來源財報 GI 的 `DATA_SEQ` 對應 |
| `RATIOS_DATE` | ratio 日期；畫面使用 `dd/MM/yyyy`，儲存使用 `yyyy/MM/dd` |
| `CUR_RATIO`, `QUICK_RATIO`, `INTEREST_COVERAGE` | Liquidity |
| `LEVERAGE`, `DE_RATIO`, `FIXED_RATIO`, `FIXED_LT_RATIO`, `OWN_CAPITAL_RATIO` | Financial Structure |
| `AR_TURNOVER`, `DAYS_FOR_AR`, `INVENTORY_TURNOVER`, `NUM_OF_DAYS_FOR_INVENTORY`, `AP_TURNOVER`, `DAYS_FOR_AP`, `CASH_CONVERSION_CYCLE`, `TOTAL_ASSET_TURNOVER` | Operating |
| `GROSS_PROFIT_MARGIN`, `OP_PROFIT_MARGIN`, `NET_PROFIT_MARGIN`, `RETURN_ON_EQUITY`, `RETURN_ON_ASSETS` | Profitability |
| `REVENUE_CREDIT_RATIO`, `IN_OUT_RATIO`, `CASH_FLOW_RATIO`, `LT_INVEST_DIV_TOTAL_EQUITY`, `LT_INVEST_DIV_TOTAL_ASSETS`, `REVENUE_GROWTH`, `NET_PROFIT_GROWTH`, `AR_GROWTH`, `BORROWING_GROWTH` | Other Info |

### 6.3 財報 GI 來源表

| 來源表 | 主要欄位 | 用途 |
|---|---|---|
| `TB_FIN_STATEMENT_BALANCE_GI` | `TOTAL_CUR_ASSETS`, `CUR_LIABILITIES`, `INVENTORIES`, `TOTAL_EQUITY`, `ST_BORROWINGS`, `BILLS_PAYABLE`, `CPLTD`, `LT_BORROWINGS`, `BONDS_PAYABLE`, `NET_FIXED_ASSETS`, `FUNDS_INVESTMENT`, `TOTAL_ASSETS`, AR/AP 欄位 | Liquidity、Financial Structure、Operating、Other Info 公式來源 |
| `TB_FIN_STATEMENT_INCOME_GI` | `REVENUES`, `PERIODS`, `COST_OF_GOOD_SOLD`, `GROSS_PROFIT`, `OPERATING_PROFIT`, `CUR_PERIOD_PROFIT`, `FINANCE_COST_INT_EXP`, `PROFIT_BEFORE_TAX` | 年化收入/獲利、Profitability、Interest Coverage |
| `TB_FIN_STATEMENT_CASHFLOW_GI` | `OPERATING_NET_CASHFLOW` | Cash Flow Ratio |

## 7. Ratio 計算規格

### 7.1 共通規則

| 規則 | 說明 |
|---|---|
| 年化收入 | `annualizedRevenue = REVENUES / PERIODS * 12` |
| 年化淨利 | `annualizedProfit = CUR_PERIOD_PROFIT / PERIODS * 12` |
| 年化銷貨成本 | `annualizedCOGS = COST_OF_GOOD_SOLD * 12 / PERIODS` |
| 借款總額 | `borrowing = ST_BORROWINGS + BILLS_PAYABLE + CPLTD + LT_BORROWINGS` |
| D/E 分子 | `ST_BORROWINGS + BILLS_PAYABLE + CPLTD + LT_BORROWINGS + BONDS_PAYABLE` |
| AR | `AR_RELATED_PARTIES + AR_NON_RELATED_PARTIES` |
| AP | `AP_RELATED_PARITIES + AP_NON_RELATED_PARTIES` |
| 第一年度判斷 | 以第一筆 `balanceList[0].BALANCE_DATE` 與目前年度 `BALANCE_DATE` 相等作為第一年度 |
| 後續年度平均 | AR、Inventory、AP turnover 使用當期與前期平均值 |
| 除數為 0 | 多數欄位顯示 `N/A`；`INTEREST_COVERAGE` 與 `TOTAL_ASSET_TURNOVER` 特定情境顯示 `-` |
| 小數 | 先以 scale 5 計算，再以 `ROUND_HALF_DOWN` 格式化為 2 位 |

### 7.2 Liquidity

| 欄位 | 公式 | 特殊規則 | 顯示 |
|---|---|---|---|
| `CUR_RATIO` | `TOTAL_CUR_ASSETS * 100 / CUR_LIABILITIES` | `CUR_LIABILITIES = 0` 則 `N/A` | `%` |
| `QUICK_RATIO` | `(TOTAL_CUR_ASSETS - INVENTORIES) * 100 / CUR_LIABILITIES` | `CUR_LIABILITIES = 0` 則 `N/A` | `%` |
| `INTEREST_COVERAGE` | `(FINANCE_COST_INT_EXP + PROFIT_BEFORE_TAX) / FINANCE_COST_INT_EXP` | `FINANCE_COST_INT_EXP = 0` 則 `-` | `x` |

### 7.3 Financial Structure

| 欄位 | 公式 | 特殊規則 | 顯示 |
|---|---|---|---|
| `LEVERAGE` | `(CUR_LIABILITIES + NON_CUR_LIABILITIES) / TOTAL_EQUITY` | `TOTAL_EQUITY = 0` 則 `N/A` | `x` |
| `DE_RATIO` | `(ST_BORROWINGS + BILLS_PAYABLE + CPLTD + LT_BORROWINGS + BONDS_PAYABLE) / TOTAL_EQUITY` | `TOTAL_EQUITY = 0` 則 `N/A` | `x` |
| `FIXED_RATIO` | `NET_FIXED_ASSETS * 100 / TOTAL_EQUITY` | `TOTAL_EQUITY = 0` 則 `N/A` | `%` |
| `FIXED_LT_RATIO` | `(NET_FIXED_ASSETS + FUNDS_INVESTMENT) * 100 / (LT_BORROWINGS + TOTAL_EQUITY)` | 分母為 0 則 `N/A` | `%` |
| `OWN_CAPITAL_RATIO` | `TOTAL_EQUITY * 100 / (TOTAL_CUR_ASSETS + NON_CUR_ASSETS)` | 分母為 0 則 `N/A` | `%` |

### 7.4 Operating

| 欄位 | 第一年度公式 | 後續年度公式 | 特殊規則 |
|---|---|---|---|
| `AR_TURNOVER` | `annualizedRevenue / AR` | `annualizedRevenue / ((currentAR + previousAR) / 2)` | 分母 0 或 `PERIODS = 0` 則 `N/A` |
| `DAYS_FOR_AR` | `365 / AR_TURNOVER` | 同第一年度 | `AR_TURNOVER = 0` 則 `N/A` |
| `INVENTORY_TURNOVER` | `annualizedCOGS / INVENTORIES` | `annualizedCOGS / ((currentInventory + previousInventory) / 2)` | 分母 0 或 `PERIODS = 0` 則 `N/A` |
| `NUM_OF_DAYS_FOR_INVENTORY` | `365 / INVENTORY_TURNOVER` | 同第一年度 | `INVENTORY_TURNOVER = 0` 則 `N/A` |
| `AP_TURNOVER` | `annualizedCOGS / AP` | `annualizedCOGS / ((currentAP + previousAP) / 2)` | 分母 0 或 `PERIODS = 0` 則 `N/A` |
| `DAYS_FOR_AP` | `365 / AP_TURNOVER` | 同第一年度 | `AP_TURNOVER = 0` 邏輯有 legacy defect suspect |
| `CASH_CONVERSION_CYCLE` | `DAYS_FOR_AR + NUM_OF_DAYS_FOR_INVENTORY - DAYS_FOR_AP` | 同第一年度 | 任一 turnover 天數不可算時為 `N/A` |
| `TOTAL_ASSET_TURNOVER` | `annualizedRevenue / TOTAL_ASSETS` | 同第一年度 | `PERIODS = 0` 則 `N/A`；`TOTAL_ASSETS = 0` 則 `-` |

### 7.5 Profitability

| 欄位 | 公式 | 特殊規則 | 顯示 |
|---|---|---|---|
| `GROSS_PROFIT_MARGIN` | `GROSS_PROFIT * 100 / REVENUES` | `REVENUES = 0` 則 `N/A` | `%` |
| `OP_PROFIT_MARGIN` | `OPERATING_PROFIT * 100 / REVENUES` | `REVENUES = 0` 則 `N/A` | `%` |
| `NET_PROFIT_MARGIN` | `CUR_PERIOD_PROFIT * 100 / REVENUES` | `REVENUES = 0` 則 `N/A` | `%` |
| `RETURN_ON_EQUITY` | `annualizedProfit * 100 / TOTAL_EQUITY` | `PERIODS = 0` 或 `TOTAL_EQUITY = 0` 則 `N/A` | `%` |
| `RETURN_ON_ASSETS` | `annualizedProfit * 100 / TOTAL_ASSETS` | `PERIODS = 0` 或 `TOTAL_ASSETS = 0` 則 `N/A` | `%` |

### 7.6 Other Info

| 欄位 | 公式 | 特殊規則 | 顯示 |
|---|---|---|---|
| `REVENUE_CREDIT_RATIO` | `borrowing * 100 / annualizedRevenue` | `PERIODS = 0` 或年化收入 0 則 `N/A` | `%` |
| `IN_OUT_RATIO` | `NET_FIXED_ASSETS * 100 / annualizedRevenue` | `PERIODS = 0` 或年化收入 0 則 `N/A` | `%` |
| `CASH_FLOW_RATIO` | `OPERATING_NET_CASHFLOW * 100 / CUR_LIABILITIES` | `CUR_LIABILITIES = 0` 則 `N/A` | `%` |
| `LT_INVEST_DIV_TOTAL_EQUITY` | `FUNDS_INVESTMENT * 100 / TOTAL_EQUITY` | `TOTAL_EQUITY = 0` 則 `N/A` | `%` |
| `LT_INVEST_DIV_TOTAL_ASSETS` | `FUNDS_INVESTMENT * 100 / TOTAL_ASSETS` | `TOTAL_ASSETS = 0` 則 `N/A` | `%` |
| `REVENUE_GROWTH` | `(annualizedRevenue - previousREVENUES) * 100 / previousREVENUES` | 第一年度、前期收入 0、或 `PERIODS = 0` 則 `N/A` | `%` |
| `NET_PROFIT_GROWTH` | `(annualizedProfit - previousCUR_PERIOD_PROFIT) * 100 / previousCUR_PERIOD_PROFIT` | 第一年度、前期淨利 0、或 `PERIODS = 0` 則 `N/A` | `%` |
| `AR_GROWTH` | `(currentAR - previousAR) * 100 / previousAR` | 第一年度或前期 AR 0 則 `N/A` | `%` |
| `BORROWING_GROWTH` | `(currentBorrowing - previousBorrowing) * 100 / previousBorrowing` | 第一年度或前期 borrowing 0 則 `N/A` | `%` |

## 8. 畫面規格

### 8.1 頁面區塊

| 區塊 | 欄位/元件 | 規格 |
|---|---|---|
| Header | Applicant Name | `borrowNM117` 或 `borrowNM217`，disabled，值為 `MAIN_BORROWER_NAME`。 |
| Item | Add New | 只有 editor 且非 query mode 可用；新增 item table。 |
| Item | Remove | 每筆 item 有 remove button；至少保留一筆。 |
| Item | Amount fields | text input，maxlength 15，integerLength 12，decimalLength 2，decimalNeedPadding true，isPositive false。 |
| Item | DSR | disabled input，粗體綠色，顯示 `x`。 |
| Ratios | 5 年度欄 | 顯示 `RATIOS_DATE_0` 到 `RATIOS_DATE_4`；不足補空白。 |
| Footer | Save | 傳 `check=Y`。 |
| Footer | Finished | 先 validation，再傳 `check=N`。 |

### 8.2 Ratio 分組

| 分組 | 欄位 |
|---|---|
| Liquidity | Current Ratio、Quick Ratio、Interest Coverage |
| Financial Structure | Leverage、Debt/Equity、Fixed Ratio、Fixed Assets / LT Debt + Equity、Total Equity / Total Assets |
| Operating | AR Turnover、Days for AR、Inventory Turnover、Days for Inventory、AP Turnover、Days for AP、Cash Conversion Cycle、Revenues / Assets |
| Profitability | Gross Profit Margin、Operating Profit Margin、Net Profit Margin、Return on Equity、Return on Assets |
| Other Info | Total Debts / Revenues、Fixed Assets / Revenues、Operating Cashflow / Current Liabilities、LT Investment / Equity、LT Investment / Assets、Revenue Growth、Net Profit Growth、AR Growth、Borrowing Growth |

## 9. 跨模組行為

| 情境 | 行為 | 證據等級 |
|---|---|---|
| 0116 GI 財報儲存 | 0116 儲存 Balance/Income/Cashflow GI 後，將 `EPROC0_0117` checkpoint 設為 `Y`。 | Cross-module confirmed |
| 0216 GI 財報儲存 | 0216 儲存 Balance/Income/Cashflow GI 後，將 `EPROC0_0217` checkpoint 設為 `Y`。 | Cross-module confirmed |
| 0110 切換 Business Type | 刪除 GI/FI 財務評估與財報資料、Corporate Scorecard，並依 Business Type 重設 0116/0117/0118 或 0119/0120/0118 checkpoint。 | Cross-module confirmed |
| 0210 切換 Assessment/Business Type | 刪除 GI/FI 財務評估與財報資料、Corporate Scorecard，並依 type 重設 0216/0217/0218 或 0219/0220/0218 checkpoint。 | Cross-module confirmed |
| CS/CU 0110 共用異動 | 若 Assessment Type 非空且 Business Type 為 G，會將 `EPROC0_0117` 或 `EPROC0_0217` 設為 `Y`。 | Cross-module confirmed |
| Report 0180 | CS/CU 0180 若 `BUSINESS_TYPE = G`，讀 `TB_FINANCIAL_EVALUATION_INFO_CORP` 輸出 DSR1、DSR2 等內容。 | Cross-module confirmed |

## 10. 驗收標準

| ID | 驗收標準 |
|---|---|
| AC-001 | 0117/0217 初始化時可顯示主借戶名稱、已存 item、GI ratio；無 item 時自動建立一筆空白 item 且 DSR 為 0。 |
| AC-002 | 使用者修改 item 金額後，系統以 `getTotal` 即時計算 DSR，並顯示 2 位小數與 `x`。 |
| AC-003 | 使用者新增 item 達上限時不得新增，並顯示限制訊息；刪到剩一筆時不得再刪。 |
| AC-004 | Save 可不做必填檢核並保存目前資料，checkpoint 寫入 `Y`。 |
| AC-005 | Finished 必須通過前端必填檢核後才保存，checkpoint 寫入 `N`。 |
| AC-006 | 儲存成功後，資料表 `TB_FINANCIAL_EVALUATION_GI` 與 `TB_FINANCIAL_EVALUATION_INFO_CORP` 中該申請案資料與畫面一致，且舊資料已被 full replacement。 |
| AC-007 | 0117 更新 CORP/CU checkpoint，0217 更新 RC CORP/RC CU checkpoint，選擇依 `LON_ATTRIBUTE + SECURE_ATTRIBUTE` 判斷。 |
| AC-008 | query action 讀取已存 GI ratio；非 query action 依 0116/0216 財報 GI 重新計算 ratio。 |
| AC-009 | 0116/0216 財報 GI 異動後，0117/0217 checkpoint 被設回 `Y`。 |
| AC-010 | 0217 old case 行為符合確認後規格，包含 Finished 是否隱藏與父頁 done 狀態是否更新。 |

## 11. 測試案例

### 11.1 正向測試

| ID | 測試情境 | 前置條件 | 預期結果 |
|---|---|---|---|
| TC-P01 | 0117 初始化有既有 DSR item 與財報 GI | 申請案有主借戶、`TB_FINANCIAL_EVALUATION_INFO_CORP` 與 0116 GI 財報 | 顯示主借戶、item、5 欄 ratio；ratio 格式含 `%` 或 `x`。 |
| TC-P02 | 0217 初始化有既有 DSR item 與財報 GI | 申請案有 RC checkpoint 與 0216 GI 財報 | 顯示 0217 資料，save 後呼叫 RC progress check。 |
| TC-P03 | DSR 即時計算 | EBIT=120，四個付款合計=40 | `getTotal` 回傳 DSR=3.00，畫面顯示 `3.00 x`。 |
| TC-P04 | 新增多筆 item 後 Save | editor 且非 query mode | 每筆 item 寫入 `DATA_SEQ`，`TB_FINANCIAL_EVALUATION_INFO_CORP` full replacement。 |
| TC-P05 | Finished 完成 | 必填欄位皆有值 | 儲存成功，checkpoint 欄位寫入 `N`，父頁 done 依 `isAllTabsCheck` 更新。 |
| TC-P06 | query action 讀已存 ratio | 已有 `TB_FINANCIAL_EVALUATION_GI` | `RATIOS_DATE` 從 DB 格式轉為畫面格式，數值顯示 2 位。 |

### 11.2 負向與邊界測試

| ID | 測試情境 | 前置條件 | 預期結果 |
|---|---|---|---|
| TC-N01 | 申請案號空白 save | `APPLICATION_NO` 空白 | 回 `COMMON_MSG_ERROR_LON`，不寫入資料。 |
| TC-N02 | DSR 分母為 0 | 四個付款欄位皆為 0 | DSR 回 0，不發生除以零錯誤。 |
| TC-N03 | EBIT 為 0 | EBIT=0，付款合計大於 0 | DSR 回 0。 |
| TC-N04 | Finished 缺必填 | 任一 item 金額空白 | `valid.executeCheck()` 失敗，不送 save。 |
| TC-N05 | item 新增達上限 | item 數量等於 `top.corSize` | 顯示 `COMMON_MSG_LIMIT` 並不新增。 |
| TC-N06 | 刪除最後一筆 item | 僅一筆 item | 顯示 `COMMON_MSG_ONE_DATA` 並不刪除。 |
| TC-N07 | 財報來源缺任一表 | Balance/Income/Cashflow GI 任一不存在 | 非 query action 回空 ratio list；新系統應顯示可理解提示。 |
| TC-N08 | 三張財報 GI 筆數不一致 | Balance 2 筆、Income 1 筆、Cashflow 2 筆 | 新系統應擋下並提示資料不一致；legacy 可能發生 index error。 |
| TC-N09 | `CUR_LIABILITIES = 0` | 財報 GI current liabilities 為 0 | Current Ratio、Quick Ratio、Cash Flow Ratio 顯示 `N/A`。 |
| TC-N10 | `FINANCE_COST_INT_EXP = 0` | Interest expense 為 0 | Interest Coverage 顯示 `-`。 |
| TC-N11 | `PERIODS = 0` | Income GI periods 為 0 | 年化相關欄位顯示 `N/A`，不發生除以零錯誤。 |
| TC-N12 | 0217 old case save | `attrMap.isOld=true` | 依確認規格不更新父頁 done；若有調整，需更新此案例。 |

### 11.3 跨模組測試

| ID | 測試情境 | 前置條件 | 預期結果 |
|---|---|---|---|
| TC-X01 | 0116 儲存 GI 財報後回 0117 | 0117 原本 completed | 0116 save 後 `EPROC0_0117` checkpoint 變 `Y`，0117 重新計算 ratio。 |
| TC-X02 | 0216 儲存 GI 財報後回 0217 | 0217 原本 completed | 0216 save 後 `EPROC0_0217` checkpoint 變 `Y`。 |
| TC-X03 | 0110 切換 Business Type | 原本為 GI 且已有 0117 資料 | 0110 changePage 刪除 GI ratio 與財報 GI 相關資料，重設可用頁籤。 |
| TC-X04 | Report 0180 輸出 DSR | `BUSINESS_TYPE=G` 且有多筆 DSR item | 報表摘要出現 DSR1、DSR2，內容為各筆 `DSR + " x"`。 |

## 12. 非功能需求

| 類別 | 需求 |
|---|---|
| 交易一致性 | save 必須以單一 transaction 包住刪除、重插 ratio、重插 item、更新 checkpoint；任一失敗 rollback。 |
| 資料完整性 | 新系統應以 request `APPLICATION_NO` 作為所有明細寫入主鍵，不信任前端逐筆傳入的 `APPLICATION_NO`。 |
| 可觀測性 | 查詢、計算與儲存錯誤需保留 audit/log；錯誤訊息需對應 legacy message code。 |
| 相容性 | 既有 DB 欄位名稱、日期格式、ratio 顯示格式與 full replacement 行為需維持，除非 TBD 決議修正 legacy defect。 |
| 安全性 | editor/query/old case 權限需在前後端皆可驗證；不得只依前端 disabled 控制。 |

## 13. Migration 建議

| 項目 | 建議 |
|---|---|
| API 命名 | 對外規格採 `getTotal`，並在 migration note 記錄舊 method 名稱 `doGetRate` 與 inventory `getRate` 差異。 |
| DTO | 分成 `FinancialEvaluationGiRatioDto` 與 `FinancialEvaluationInfoCorpDto`；儲存 request 包含 `applicationNo`, `check`, `pageCheckMap`, `ratios`, `items`。 |
| Validation | 後端補 `APPLICATION_NO` 一致性、`DATA_SEQ` 唯一性、財報三表筆數與 `DATA_SEQ` 對齊檢核。 |
| Legacy defect | AP turnover zero 欄位設錯、query null list、growth 年化比較不一致，應由 SA 決定修正或保留。 |
| 回歸測試 | 優先覆蓋 DSR、30 個 ratio 的除數為 0、保存 full replacement、checkpoint、0116/0216 連動、0217 old case。 |

## 14. 手動驗證路徑

| 步驟 | 操作 | 預期 |
|---|---|---|
| 1 | 以 editor 身分開啟 0117 並載入有 GI 財報的申請案 | 頁面顯示主借戶、Item、Ratios。 |
| 2 | 修改 EBIT 與 payment 欄位 | DSR 透過 `getTotal` 更新。 |
| 3 | 按 Save | 儲存成功，checkpoint 為 `Y`，資料表內容 full replacement。 |
| 4 | 補齊必填後按 Finished | 儲存成功，checkpoint 為 `N`，父頁 done 狀態依 all tabs check 更新。 |
| 5 | 編輯 0116 GI 財報並儲存 | 0117 checkpoint 回到 `Y`，重新進入 0117 可看到 ratio 依新財報重算。 |
| 6 | 重複 0217/0216 流程 | 使用 RC checkpoint 與 RC parent progress，old case 行為依確認規格。 |

## 15. Open Items

| ID | 問題 | Owner |
|---|---|---|
| OI-001 | 需確認 GI 財務評估表中文正式名稱是否採「公司戶財務評估表 GI」或「償債能力分析表 GI」。 | PM |
| OI-002 | 需確認 `top.corSize` 的現行設定值與新系統限制文案。 | SA |
| OI-003 | 需確認 DSR item 金額是否固定 USD，或需啟用 `ccyMap` 多幣別。 | PM/SA |
| OI-004 | 需決定是否修正 AP turnover zero 欄位錯置與 growth 年化比較問題。 | SA/RD |
| OI-005 | 需決定新系統是否保留未被本頁 JS 呼叫的 `getExist` 相容 API。 | SA/RD |
