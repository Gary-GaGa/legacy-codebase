台中資訊開發中心

業務需求導向的功能規格書

CDC-EPRO-0001 EPROC00120 Financial Evaluation Table FI

版本 1.0

更新日期：2026/06/15

# CDC-EPRO-0001 EPROC00120 Financial Evaluation Table FI PRD

| 文件項目 | 內容 |
|---|---|
| 文件狀態 | 初版，依舊系統 Source code 掃描產出 |
| 文件目的 | 定義公司戶 FI 財務評估表的查詢、比率計算、人工補登、儲存、完成與 checkpoint 連動需求。 |
| 主系統鏈結 | `EPROC0_0110` 一般公司戶徵信流程：`EPROC0_0119` 財務報表 FI -> `EPROC0_0120` 財務評估 FI -> `EPROC0_0118` Corporate Scorecard；`EPROC0_0210` RC 流程：`EPROC0_0219` -> `EPROC0_0220` -> `EPROC0_0218`。 |
| 強化重點 | 明確標示 source-confirmed 公式、人工輸入欄位、資料保存表、Save/Finished 差異、RC old case 行為，以及 legacy 風險。 |
| 產出檔案 | `CDC-EPRO-0001_EPROC00120_PRD_v1.0.md`、`CDC-EPRO-0001_EPROC00120_PRD_v1.0.docx` |

## 1. 文件控制

### 1.1 修訂紀錄

| 日期 | 版本 | 說明 | 作者 |
|---|---|---|---|
| 2026-06-15 | v1.0 | 依 `EPROC0_0120` 與 `EPROC0_0220` 舊系統 Source code 掃描產出初版 PRD | Codex |

### 1.2 文件 Review 紀錄

| 角色 | Review 重點 |
|---|---|
| PM | 確認 FI 財務評估表的業務名稱、比率項目、必填項目、Save/Finished 語意與 RC old case 行為。 |
| SA | 確認五個 source-calculated ratio 公式、十一個人工輸入 ratio 的來源、查詢模式與編輯模式資料來源差異。 |
| RD | 確認 API、DTO、日期格式、full replacement 儲存、資料表共享邊界、除以零與三表筆數對齊風險。 |
| QA | 依正向、負向、邊界、跨頁連動與資料副作用測試案例驗證 0120/0220 行為。 |

### 1.3 待確認項目

| ID | 待確認項目 | 影響範圍 | 建議處理 |
|---|---|---|---|
| TBD-001 | 非查詢模式以 `TB_FIN_STATEMENT_BALANCE_FI` 與 `TB_FIN_STATEMENT_INCOME_FI` 依 `DATA_SEQ`/index 對齊，但 source 未檢查兩張表筆數是否一致。 | ratio 計算、畫面顯示、儲存資料正確性 | 新系統應檢查筆數與 `DATA_SEQ` 對齊，不一致時回傳明確錯誤。 |
| TBD-002 | ROA/ROE 公式會使用 `PERIODS` 作除數；source 只檢查平均資產/平均權益是否為 0，未檢查 `PERIODS = 0`。 | 計算穩定性、查詢失敗風險 | RD 應補 `PERIODS` 不可為 0 的檢核；SA 確認無月份時應顯示 `N/A` 或阻擋。 |
| TBD-003 | `COST_INCOME` source 公式為 `OPERATING_EXPENSES / CONTINUING_OP_INCOME_BT * 100`，不是常見的 operating expense / operating income 或 net revenue 定義。 | 業務指標定義 | SA/風管確認是否沿用舊系統公式；若需修正須列入 migration decision。 |
| TBD-004 | 編輯模式下若同一 `RATIOS_DATE` 已有保存值，source 會保留人工輸入欄位並重算五個公式欄位；若日期改變，人工欄位可能無法帶入。 | 使用者體驗、資料延續 | PM/SA 確認日期變更後人工欄位是否應保留或要求重填。 |
| TBD-005 | 前端 Save 不執行 required validation，Finished 才檢核 required 欄位；後端只檢核 `APPLICATION_NO`。 | 暫存資料完整性 | PM 確認 Save 可否保存未完整資料；RD 需將 Save/Finished validation 分層。 |
| TBD-006 | 0219/0220 RC old case 下，JSP 不顯示 Finished，save callback 也不更新父頁 done 狀態。 | RC 舊案流程 | PM/SA 確認 old case 是否只能 Save 不能 Finished。 |
| TBD-007 | `EPROC00220_JS.jsp` 的 `_funcName` 使用 `EPROC0_0120_FUNC_NAME`，父頁則使用 `EPROC00120_FUNC_NAME`；功能名稱 key 命名不一致。 | i18n、畫面標題 | 新系統統一使用功能代號與名稱；舊系統 key 差異列入相容風險。 |
| TBD-008 | `TB_FINANCIAL_EVALUATION_FI` 同時被 C0 與 I0 FI 評估功能使用。 | 資料表共享、migration scope | 本文件只定義 C0 0120/0220；I0 行為需由 I0 PRD 獨立確認。 |

### 1.4 目錄

| 章節 | 標題 |
|---|---|
| 1 | 文件控制 |
| 2 | 需求概述 |
| 3 | 業務流程 |
| 4 | 需求清單與追蹤矩陣 |
| 5 | 功能需求 |
| 6 | API / Interface 規格 |
| 7 | 資料規格與 Mapping |
| 8 | 業務規則 |
| 9 | 錯誤處理 |
| 10 | 非功能需求 |
| 11 | 驗收標準與測試案例 |
| 12 | 附件與決策紀錄 |

## 2. 需求概述

### 2.1 需求背景

`EPROC00120` 是公司戶 FI 業務型態的財務評估表頁面。舊系統由 `EPROC0_0120` 支援一般公司戶流程，由 `EPROC0_0220` 支援 RC 流程。此頁位於 FI 財務報表 `EPROC0_0119`/`EPROC0_0219` 之後，會讀取前頁保存的 FI Balance Sheet 與 Income Statement，計算部分財務比率，並讓使用者補登無法由財報自動產生的監理或風險比率。

本文件以 source-confirmed 行為為主，不將疑似 legacy defect 自動視為新系統應保留的需求。涉及公式正確性、old case 流程與人工比率來源的事項，列入待確認項目。

### 2.2 業務目標

| ID | 業務目標 |
|---|---|
| GOAL-001 | 提供公司戶 FI 案件的財務評估表，整合自動計算比率與人工輸入比率。 |
| GOAL-002 | 在一般流程與 RC 流程中，依相同 FI ratio 邏輯產生五期評估資料。 |
| GOAL-003 | 保存完成後更新對應 checkpoint，讓父頁可判斷本頁是否已暫存或完成。 |
| GOAL-004 | 支援查詢模式讀取歷史保存值，編輯模式則依最新 FI 財報資料重算。 |
| GOAL-005 | 保留 source-confirmed 行為，同時揭露資料一致性、除以零與共享表風險供 migration 決策。 |

### 2.3 需求名稱與服務說明

| 項目 | 說明 |
|---|---|
| 需求名稱 | EPROC00120 公司戶 FI 財務評估表 |
| 舊系統功能 | `EPROC0_0120`、`EPROC0_0220` |
| 英文名稱 | Financial Evaluation Table FI |
| Source 註解名稱 | 償債能力分析表 BusinessOwner FI |
| 服務說明 | 查詢申請人名稱與 FI 評估資料，依 FI 財報計算 `GGL`、`COST_INCOME`、`ROA`、`ROE`、`LOANS_DEPOSITS`，並保存使用者輸入的 FI 風險比率。 |

### 2.4 本期範圍與非本期範圍

| 類別 | 範圍 |
|---|---|
| 本期範圍 | `EPROC0_0120`、`EPROC0_0220` transaction/module/JSP/JS、FI ratio 計算、`TB_FINANCIAL_EVALUATION_FI` 保存、CORP/CU 與 RC_CORP/RC_CU checkpoint 更新、父頁 0110/0210 連動。 |
| 非本期範圍 | FI 財務報表輸入頁 `EPROC0_0119`/`EPROC0_0219` 的欄位維護、Corporate Scorecard `EPROC0_0118`/`EPROC0_0218`、I0 個人戶/企業主 FI 評估頁、報表列印功能。 |
| 依賴功能 | 0119/0219 必須先保存 FI Balance/Income 資料；若缺任一資料來源，編輯模式回傳空清單。 |

### 2.5 角色與系統職責

| 角色/系統 | 職責 |
|---|---|
| RM/徵信人員 | 檢視自動計算 ratio，輸入人工 ratio，執行 Save 或 Finished。 |
| 覆核/查詢角色 | 在 query mode 檢視已保存 FI 評估資料。 |
| EPROC0_0120/0220 | 查詢申請人與 checkpoint，計算/查詢 FI ratio，保存 FI 評估資料。 |
| EPROC0_0119/0219 | 提供 FI 財報資料來源，並在保存後將 0120/0220 checkpoint 重設為 `Y`。 |
| EPROC0_0110/0210 | 控制頁籤順序、Business Type/Assessment Type 與父頁完成狀態。 |

## 3. 業務流程

### 3.1 End-to-End 流程總覽

| 步驟 | 流程 | 說明 |
|---|---|---|
| 1 | 父頁判斷 FI 流程 | 0110/0210 依 Business Type FI 啟用 0119/0120/0118 或 0219/0220/0218。 |
| 2 | 前頁保存 FI 財報 | 0119/0219 保存 Balance、Income、Cashflow FI，並重設 0120/0220 checkpoint 為 `Y`。 |
| 3 | 進入財務評估 FI | 前端呼叫 `/query`，取得申請人名稱、checkpoint、fiList。 |
| 4 | 顯示或計算比率 | query mode 讀已存 `TB_FINANCIAL_EVALUATION_FI`；編輯模式依 Balance/Income FI 即時計算。 |
| 5 | 人工補登比率 | 使用者在可編輯欄位輸入 NPL、LLR、Liquidity Coverage 等人工比率。 |
| 6 | Save/Finished | Save 以 `check = Y` 暫存；Finished 通過 required validation 後以 `check = N` 完成。 |
| 7 | 更新父頁進度 | save 成功後回傳 `isAllTabsCheck`，前端更新父頁 check 與 done 樣式。 |

### 3.2 正常流程

| ID | 正常流程 |
|---|---|
| NF-001 | 使用者進入 0120 或 0220 頁籤，前端設定 function description 並呼叫 `query`。 |
| NF-002 | 後端取得 `APPLICATION_NO`，回傳 `dataMap.APPLICATION_NAME`、`dataMap.check` 與 `fiList`。 |
| NF-003 | 前端依 `fiList.length` 顯示最多五期欄位，超過資料期數的欄位 disabled。 |
| NF-004 | 後端自動計算欄位顯示為文字；人工欄位依角色與狀態決定是否可編輯。 |
| NF-005 | 使用者可按 Save 暫存；Finished 時先執行 required validation，再儲存並標記完成。 |

### 3.3 例外流程

| ID | 例外流程 | 系統行為 |
|---|---|---|
| EX-001 | 查無 FI 財報來源 | 編輯模式下 balance 或 income 清單為 null 時回傳空清單，畫面不開放年度欄位。 |
| EX-002 | 查詢模式查無保存值 | query mode 若 `TB_FINANCIAL_EVALUATION_FI` 查無資料，module 回傳 null，前端轉為空清單。 |
| EX-003 | application no 空白 | save 時後端拋出 `COMMON_MSG_ERROR_LON`。 |
| EX-004 | 儲存發生例外 | transaction rollback，交易層回傳 `COMMON_MSG_SAVE_FAIL`。 |
| EX-005 | 查詢發生 OverCountLimit | 交易層回傳 `MSG_OVER_COUNT_LIMIT`。 |

### 3.4 決策點

| 決策點 | 條件 | 結果 |
|---|---|---|
| DP-001 查詢模式 | `EPRO_Z0Z002.isQuery(action)` 為 true | 直接讀取已保存 `TB_FINANCIAL_EVALUATION_FI`，日期由 `yyyy/MM/dd` 轉為 `dd/MM/yyyy`。 |
| DP-002 編輯模式 | 非 query action | 依 `TB_FIN_STATEMENT_BALANCE_FI` 與 `TB_FIN_STATEMENT_INCOME_FI` 即時計算五個比率。 |
| DP-003 一般/RC | 功能為 0120 或 0220 | 0120 更新 CORP/CU checkpoint；0220 更新 RC_CORP/RC_CU checkpoint。 |
| DP-004 CS/CU | `LON_ATTRIBUTE + SECURE_ATTRIBUTE == CS` | true 更新 CORP 或 RC_CORP；false 更新 CU 或 RC_CU。 |
| DP-005 Save/Finished | `check = Y` 或 `check = N` | `Y` 表示暫存未完成；`N` 表示完成本頁。 |

## 4. 需求清單與追蹤矩陣

| Requirement ID | 功能名稱 | 優先度 | 狀態 | 對應章節 |
|---|---|---|---|---|
| FR-001 | 初始化與查詢 FI 評估資料 | Must | Source confirmed | 5.1 |
| FR-002 | 編輯模式即時計算 FI ratio | Must | Source confirmed | 5.2 |
| FR-003 | 顯示與輸入五期 FI ratio | Must | Source confirmed | 5.3 |
| FR-004 | Save 暫存 | Must | Source confirmed | 5.4 |
| FR-005 | Finished 完成 | Must | Source confirmed | 5.5 |
| FR-006 | Checkpoint 與父頁進度連動 | Must | Cross-module confirmed | 5.6 |
| FR-007 | Query mode 歷史資料檢視 | Should | Source confirmed | 5.7 |
| FR-008 | RC old case 行為 | Should | Source confirmed / TBD | 5.8 |

### 4.1 需求完整性標準

| 標準 | 說明 |
|---|---|
| 來源完整 | 每項需求須能追溯至 transaction、module、JSP/JS、DAO/SQL 或跨模組 source。 |
| 行為分類 | source-confirmed 與 TBD/legacy defect suspect 必須分開，不把可疑 legacy 行為寫成未經確認的新需求。 |
| 資料完整 | 必須列出保存表、資料來源表、欄位 mapping、delete/insert 副作用與 checkpoint。 |
| 測試完整 | 測試需涵蓋正向、負向、邊界、資料副作用與跨頁連動。 |

## 5. 功能需求

### 5.1 FR-001 初始化與查詢 FI 評估資料

| 欄位 | 內容 |
|---|---|
| Requirement ID | FR-001 |
| 功能名稱 | 初始化與查詢 FI 評估資料 |
| 需求描述 | 系統須於進入 0120/0220 頁面時，取得申請人名稱、目前 checkpoint 狀態與 FI 評估比率清單。 |
| Trigger | 使用者開啟 `EPROC0_0120` 或 `EPROC0_0220` 頁籤，前端 `initApp` 呼叫 `ajaxPost`。 |
| Actor | RM、徵信人員、查詢使用者 |
| 前置條件 | `APPLICATION_NO` 已建立，父頁已載入本功能頁籤。 |
| 後置結果 | 畫面顯示申請人名稱與最多五期 ratio 欄位。 |

#### 5.1.1 處理邏輯

| 步驟 | 處理 |
|---|---|
| 1 | 前端呼叫 `/EPROC0_0120/query` 或 `/EPROC0_0220/query`，帶入 `APPLICATION_NO` 與 `action`。 |
| 2 | 交易層設定 AuditLog：`ActionType.Query`、`AccessObjectType.Table`、`AccessField_name = true`。 |
| 3 | module `getOther` 查 `TB_LON_SUMMARY_INFO` 判斷 CS/CU，查 `TB_MAIN_BORROWER_INFO_CORP.MAIN_BORROWER_NAME` 作申請人名稱。 |
| 4 | module 依 CS/CU 讀取 `EPROC0_0120` 或 `EPROC0_0220` checkpoint，回傳 `dataMap.check`。 |
| 5 | module `query` 依 action 決定讀保存值或即時計算值，回傳 `fiList`。 |

#### 5.1.2 驗收標準

| AC ID | Given | When | Then |
|---|---|---|---|
| AC-001 | 有效 application no | 進入 0120 | 畫面顯示 `APPLICATION_NAME` 與 0120 checkpoint 狀態。 |
| AC-002 | 有效 RC application no | 進入 0220 | 畫面顯示 `APPLICATION_NAME` 與 0220 checkpoint 狀態。 |
| AC-003 | 查無 fiList | 查詢完成 | 前端將 `_fiList` 設為空清單，不開放無資料年度欄位。 |

### 5.2 FR-002 編輯模式即時計算 FI ratio

| 欄位 | 內容 |
|---|---|
| Requirement ID | FR-002 |
| 功能名稱 | 編輯模式即時計算 FI ratio |
| 需求描述 | 非 query mode 下，系統須以 0119/0219 保存的 FI Balance 與 Income 資料計算五個自動 ratio。 |
| Trigger | 前端呼叫 `query` 且 `action` 非查詢模式。 |
| Actor | 系統 |
| 前置條件 | `TB_FIN_STATEMENT_BALANCE_FI` 與 `TB_FIN_STATEMENT_INCOME_FI` 至少各有資料。 |
| 後置結果 | `fiList` 包含 ratio date、data seq、五個計算欄位與可保存的人工欄位。 |

#### 5.2.1 處理邏輯

| 步驟 | 處理 |
|---|---|
| 1 | 依 `APPLICATION_NO` 查 `TB_FIN_STATEMENT_BALANCE_FI`，order by `DATA_SEQ`。 |
| 2 | 依 `APPLICATION_NO` 查 `TB_FIN_STATEMENT_INCOME_FI`，order by `DATA_SEQ`。 |
| 3 | 任一清單為 null 時回傳空清單。 |
| 4 | 對每筆 balance，以 `BALANCE_DATE` 對應 `RATIOS_DATE` 查已保存的 `TB_FINANCIAL_EVALUATION_FI`。 |
| 5 | 若已保存同日資料，保留既有人工欄位；再覆寫 `APPLICATION_NO`、`RATIOS_DATE`、`DATA_SEQ` 與五個計算欄位。 |
| 6 | 計算結果呼叫 `EPRO_C00111.formatTwo`，非 `N/A`、非 `-`、非 null 的計算欄位四捨五入至小數兩位。 |

#### 5.2.2 Data Impact

| 資料來源 | 用途 |
|---|---|
| `TB_FIN_STATEMENT_BALANCE_FI` | 提供 `BALANCE_DATE`、`DATA_SEQ`、loans、deposits、assets、equity 等 ratio 計算資料。 |
| `TB_FIN_STATEMENT_INCOME_FI` | 提供 operating expenses、continuing operation income、periods、continuing operation after tax。 |
| `TB_FINANCIAL_EVALUATION_FI` | 依同一 `APPLICATION_NO` 與 `RATIOS_DATE` 保留既有人工輸入欄位。 |

#### 5.2.3 驗收標準

| AC ID | Given | When | Then |
|---|---|---|---|
| AC-004 | Balance/Income 均有五期 | 編輯模式查詢 | 回傳五筆 fiList，年度依 `DATA_SEQ` 排序。 |
| AC-005 | Balance 或 Income 缺資料 | 編輯模式查詢 | 回傳空 fiList。 |
| AC-006 | 已保存同一 ratios date 的人工欄位 | 編輯模式查詢 | 人工欄位保留，自動欄位依最新 FI 財報重算。 |

### 5.3 FR-003 顯示與輸入五期 FI ratio

| 欄位 | 內容 |
|---|---|
| Requirement ID | FR-003 |
| 功能名稱 | 顯示與輸入五期 FI ratio |
| 需求描述 | 畫面須以最多五期欄位呈現 FI 評估 ratio；自動欄位唯讀顯示，人工欄位依權限可編輯。 |
| Trigger | `query` 成功回傳 `fiList`。 |
| Actor | RM、徵信人員 |
| 前置條件 | 使用者具備 `isEditor120` 或 `isEditor220` 且非 query mode，並有有效 `APPLICATION_NO`。 |
| 後置結果 | 使用者可在人工欄位輸入百分比數值。 |

#### 5.3.1 Ratio 類別與欄位

| 類別 | 欄位 | 欄位類型 |
|---|---|---|
| Asset Quality | `NPL`、`LLR`、`LLR_OVER_NPL`、`GGL`、`AGREE_LARGE_EXPOSURE`、`CREDIT_EXPOSURE_TO_SB`、`RELATED_PARTY_EXPOSURE`、`UNHEDGED_FOREIGN_CURR` | `GGL` 自動；其餘為人工輸入，其中 `AGREE_LARGE_EXPOSURE`、`CREDIT_EXPOSURE_TO_SB`、`RELATED_PARTY_EXPOSURE`、`UNHEDGED_FOREIGN_CURR` 為 required。 |
| Earnings and Profitability | `NET_INTEREST_MARGIN`、`COST_INCOME`、`ROA`、`ROE` | `COST_INCOME`、`ROA`、`ROE` 自動；`NET_INTEREST_MARGIN` 人工輸入。 |
| Funding and Liquidity | `LOANS_DEPOSITS`、`LIQUIDITY_COVERAGE`、`SOLVENCY` | `LOANS_DEPOSITS` 自動；`LIQUIDITY_COVERAGE`、`SOLVENCY` 為 required 人工輸入。 |
| Capital and Leverage | `TIER_ONE_CAPITAL` | 人工輸入。 |

#### 5.3.2 輸入格式

| 規則 | 說明 |
|---|---|
| 數字格式 | 前端使用 `InputUtility` 設定 Number、amount 格式、可輸入正負數、小數兩位補零。 |
| 整數長度 | 人工欄位設定 `integerLength = 12`。 |
| 顯示格式 | 自動欄位若為 number，前端以 `#,##0.00` 加 `%` 顯示。 |
| 年度啟用 | `fiList.length` 內的年度欄位 enabled；其餘欄位清空並 disabled。 |

#### 5.3.3 驗收標準

| AC ID | Given | When | Then |
|---|---|---|---|
| AC-007 | fiList 有三筆 | 畫面載入 | 只開放第 1 至第 3 期人工欄位，第 4 至第 5 期 disabled。 |
| AC-008 | 使用者非 editor 或 query mode | 畫面載入 | 所有 `.isView120` 或 `.isView220` 欄位 disabled。 |
| AC-009 | 自動欄位值為 number | 畫面載入 | 顯示兩位小數加 `%`。 |

### 5.4 FR-004 Save 暫存

| 欄位 | 內容 |
|---|---|
| Requirement ID | FR-004 |
| 功能名稱 | Save 暫存 |
| 需求描述 | 使用者可按 Save 暫存目前 FI 評估資料，source 行為不要求所有 required 欄位已填。 |
| Trigger | 使用者按 `btnSave120` 或 `btnSave220`。 |
| Actor | RM、徵信人員 |
| 前置條件 | 有效 `APPLICATION_NO`，頁面已取得 `fiList`。 |
| 後置結果 | `TB_FINANCIAL_EVALUATION_FI` 以 full replacement 保存，checkpoint 設為 `Y`。 |

#### 5.4.1 處理邏輯

| 步驟 | 處理 |
|---|---|
| 1 | 前端將 `_input120` 或 `_input220` 人工欄位寫回 `_fiList`。 |
| 2 | 前端呼叫 `/save`，帶入 `fiList`、`APPLICATION_NO`、`check = Y`、`pageCheckMap`。 |
| 3 | 後端檢查 `APPLICATION_NO` 不可空白。 |
| 4 | 後端將 `RATIOS_DATE` 由 `dd/MM/yyyy` 轉為 `yyyy/MM/dd`。 |
| 5 | 後端將數值型自動 ratio 轉為字串，以符合 DAO insert 欄位格式。 |
| 6 | transaction 內先依 `APPLICATION_NO` 刪除 `TB_FINANCIAL_EVALUATION_FI`，再逐筆 insert `fiList`。 |
| 7 | 更新對應 checkpoint 為 `Y`，commit 後回傳父頁完成狀態。 |

#### 5.4.2 Data Impact

| 資料表 | 操作 | 條件/欄位 |
|---|---|---|
| `TB_FINANCIAL_EVALUATION_FI` | Delete by application | `APPLICATION_NO` |
| `TB_FINANCIAL_EVALUATION_FI` | Insert | `APPLICATION_NO`、`DATA_SEQ`、所有 ratio 欄位、`RATIOS_DATE` |
| `TB_CHECK_POINT_CORP` / `TB_CHECK_POINT_CU` | Update | 0120 依 CS/CU 更新 `EPROC0_0120 = Y` |
| `TB_CHECK_POINT_RC_CORP` / `TB_CHECK_POINT_RC_CU` | Update | 0220 依 CS/CU 更新 `EPROC0_0220 = Y` |

#### 5.4.3 驗收標準

| AC ID | Given | When | Then |
|---|---|---|---|
| AC-010 | 0120 編輯者已載入 fiList | 按 Save | 資料保存，`EPROC0_0120` checkpoint 為 `Y`。 |
| AC-011 | 0220 編輯者已載入 fiList | 按 Save | 資料保存，`EPROC0_0220` checkpoint 為 `Y`。 |
| AC-012 | `APPLICATION_NO` 空白 | 呼叫 save | 後端回傳 `COMMON_MSG_ERROR_LON`。 |

### 5.5 FR-005 Finished 完成

| 欄位 | 內容 |
|---|---|
| Requirement ID | FR-005 |
| 功能名稱 | Finished 完成 |
| 需求描述 | 使用者按 Finished 時，前端須執行 required 欄位檢核，通過後保存並將 checkpoint 設為 `N`。 |
| Trigger | 使用者按 `btnFinished120` 或 `btnFinished220`。 |
| Actor | RM、徵信人員 |
| 前置條件 | 具備編輯權限、非 query mode、非 0220 old case，且 required 欄位已填。 |
| 後置結果 | FI 評估資料保存完成，父頁可視為本頁完成。 |

#### 5.5.1 Required 欄位

| 欄位 | 說明 |
|---|---|
| `AGREE_LARGE_EXPOSURE` | Aggregate Large Exposure Ratio |
| `CREDIT_EXPOSURE_TO_SB` | Credit Exposure to single beneficiary / Total net worth |
| `RELATED_PARTY_EXPOSURE` | Related party exposure / Total loans |
| `UNHEDGED_FOREIGN_CURR` | Unhedged foreign currency ratio |
| `LIQUIDITY_COVERAGE` | Liquidity Coverage Ratio |
| `SOLVENCY` | Solvency Ratio |

#### 5.5.2 驗收標準

| AC ID | Given | When | Then |
|---|---|---|---|
| AC-013 | required 欄位完整 | 按 Finished | 儲存成功，checkpoint 為 `N`。 |
| AC-014 | required 欄位缺漏 | 按 Finished | 前端 validation 阻擋，不送 save。 |
| AC-015 | 0220 old case | 載入頁面 | Finished 按鈕不顯示。 |

### 5.6 FR-006 Checkpoint 與父頁進度連動

| 欄位 | 內容 |
|---|---|
| Requirement ID | FR-006 |
| 功能名稱 | Checkpoint 與父頁進度連動 |
| 需求描述 | 儲存後系統須更新本頁 checkpoint，並回傳父頁是否所有頁籤已完成。 |
| Trigger | save 成功。 |
| Actor | 系統 |
| 前置條件 | `pageCheckMap` 已由父頁提供。 |
| 後置結果 | 父頁 check 與 done 樣式依 source 行為更新。 |

#### 5.6.1 處理邏輯

| 流程 | 行為 |
|---|---|
| 0120 | 後端使用 `EPRO_Z0Z006.getTabsCheckPage(pageCheckMap, "EPROC0_0110")` 與 `getCheckedProgressCORP` 回傳 `isAllTabsCheck`。 |
| 0220 | 後端使用 `EPRO_Z0Z006.getTabsCheckPage(pageCheckMap, "EPROC0_0210")` 與 `getCheckedProgressRC_CORP` 回傳 `isAllTabsCheck`。 |
| 前端 0120 | edit mode 下呼叫 `EPROC0_0110.check("EPROC0_0120", check)`；若 `check = N` 且 all tabs checked，父頁加上 done。 |
| 前端 0220 | 非 old case edit mode 下呼叫 `EPROC0_0210.check("EPROC0_0220", check)`；非 old case 才更新 done。 |

#### 5.6.2 驗收標準

| AC ID | Given | When | Then |
|---|---|---|---|
| AC-016 | 0120 Finished 且全頁籤完成 | save 回應 `isAllTabsCheck = true` | 父頁 frame 加上 done 樣式。 |
| AC-017 | 0220 old case | Save 成功 | 不更新父頁 done 樣式。 |

### 5.7 FR-007 Query mode 歷史資料檢視

| 欄位 | 內容 |
|---|---|
| Requirement ID | FR-007 |
| 功能名稱 | Query mode 歷史資料檢視 |
| 需求描述 | 查詢模式須讀取已保存的 FI 評估資料，不依目前 0119/0219 財報重新計算。 |
| Trigger | `EPRO_Z0Z002.isQuery(action)` 為 true。 |
| Actor | 查詢使用者、覆核使用者 |
| 前置條件 | `TB_FINANCIAL_EVALUATION_FI` 已保存資料。 |
| 後置結果 | 畫面以唯讀方式顯示保存值。 |

#### 5.7.1 處理邏輯

| 步驟 | 處理 |
|---|---|
| 1 | 依 `APPLICATION_NO` 查 `TB_FINANCIAL_EVALUATION_FI`，order by `RATIOS_DATE`。 |
| 2 | `RATIOS_DATE` 由 `yyyy/MM/dd` 轉為 `dd/MM/yyyy`。 |
| 3 | `COST_INCOME`、`LOANS_DEPOSITS`、`GGL`、`ROA`、`ROE` 若不是 `N/A`，轉為 BigDecimal。 |
| 4 | 前端將所有 `.isView120` 或 `.isView220` disabled。 |

### 5.8 FR-008 RC old case 行為

| 欄位 | 內容 |
|---|---|
| Requirement ID | FR-008 |
| 功能名稱 | RC old case 行為 |
| 需求描述 | 0220 在 `attrMap.isOld` 為 true 時，source 不顯示 Finished，save callback 不更新父頁 check/done。 |
| Trigger | RC old case 載入 `EPROC00220.jsp`。 |
| Actor | RC 使用者 |
| 前置條件 | `attrMap.isOld = true`。 |
| 後置結果 | 使用者可依 JSP 條件看到 Save，但不能 Finished。 |

## 6. API / Interface 規格

### 6.1 API 清單

| API | 0120 Endpoint | 0220 Endpoint | Method | 說明 |
|---|---|---|---|---|
| Query | `/EPROC0_0120/query` | `/EPROC0_0220/query` | AJAX POST | 查詢申請人、checkpoint 與 fiList。 |
| Save | `/EPROC0_0120/save` | `/EPROC0_0220/save` | AJAX POST | 保存 FI 評估資料並更新 checkpoint。 |

### 6.2 Common Header / Request Context

| 項目 | 說明 |
|---|---|
| Session user/role | 舊系統由父頁提供 `isEditor120` / `isEditor220` 與 `attrMap` 控制 UI。 |
| `APPLICATION_NO` | 案件編號；query/save 都必須帶入。 |
| `action` | query API 用於判斷是否為 query mode。 |
| Audit | query 使用 `ActionType.Query`；save 使用 `ActionType.Edit`；皆為 `AccessObjectType.Table`。 |

### 6.3 Query Request / Response 欄位草案

| Request 欄位 | 必填 | 說明 |
|---|---|---|
| `APPLICATION_NO` | Y | 案件編號。 |
| `action` | N | 判斷 query mode 的 action 值。 |

| Response 欄位 | 說明 |
|---|---|
| `dataMap.APPLICATION_NAME` | 申請人名稱，來自 `TB_MAIN_BORROWER_INFO_CORP.MAIN_BORROWER_NAME`。 |
| `dataMap.check` | 0120 或 0220 checkpoint 值。 |
| `fiList[]` | FI 評估資料清單，最多五期，由 source 實際資料筆數決定。 |

### 6.4 Save Request / Response 欄位草案

| Request 欄位 | 必填 | 說明 |
|---|---|---|
| `fiList` | Y | JSON array；每筆包含 `APPLICATION_NO`、`DATA_SEQ`、`RATIOS_DATE` 與 ratio 欄位。 |
| `APPLICATION_NO` | Y | 案件編號。 |
| `check` | Y | `Y` 暫存；`N` 完成。 |
| `pageCheckMap` | Y | 父頁頁籤進度計算所需資料。 |

| Response 欄位 | 說明 |
|---|---|
| `isAllTabsCheck` | 父頁是否所有相關頁籤已完成。 |

### 6.5 Common Error Response

| 錯誤 | 來源 | 訊息 |
|---|---|---|
| 查無資料 | transaction catch `DataNotFoundException` | `MSG_DATA_NOT_FOUND` |
| 查詢筆數超限 | `OverCountLimitException` | `MSG_OVER_COUNT_LIMIT` |
| 查詢失敗 | query 其他例外 | `MSG_QUERY_FAIL` |
| application no 空白 | module save | `COMMON_MSG_ERROR_LON` |
| 儲存失敗 | save module/exception | `COMMON_MSG_SAVE_FAIL` |
| 儲存成功 | save 成功 | `COMMON_MSG_SAVE_SUCCESS` |

### 6.6 Timeout / Retry / Idempotency

| 項目 | 規格 |
|---|---|
| Timeout | 舊系統未定義特殊 timeout；新系統沿用共通 AJAX timeout 與錯誤處理。 |
| Retry | save 不建議自動重試；因為使用 full replacement，若重送需確保 payload 完整且 request idempotent。 |
| Idempotency | 相同 `APPLICATION_NO` 與相同 `fiList` 重送 save，結果應相同；但併發儲存會以最後一次提交為準。 |

## 7. 資料規格與 Mapping

### 7.1 Field Mapping

| UI / DTO 欄位 | DB 欄位 | 類型 | 來源/輸入 |
|---|---|---|---|
| `applicationNo` | `APPLICATION_NO` | String | request / fiList |
| `dataSeq` | `DATA_SEQ` | Number/String | 由 FI 財報 `DATA_SEQ` 帶入 |
| `ratiosDate` | `RATIOS_DATE` | String date | 由 `BALANCE_DATE` 轉換；畫面 `dd/MM/yyyy`，DB `yyyy/MM/dd` |
| `npl` | `NPL` | Ratio | 人工輸入 |
| `llr` | `LLR` | Ratio | 人工輸入 |
| `llrOverNpl` | `LLR_OVER_NPL` | Ratio | 人工輸入 |
| `ggl` | `GGL` | Ratio | 系統計算 |
| `agreeLargeExposure` | `AGREE_LARGE_EXPOSURE` | Ratio | 人工輸入，required |
| `creditExposureToSb` | `CREDIT_EXPOSURE_TO_SB` | Ratio | 人工輸入，required |
| `relatedPartyExposure` | `RELATED_PARTY_EXPOSURE` | Ratio | 人工輸入，required |
| `unhedgedForeignCurr` | `UNHEDGED_FOREIGN_CURR` | Ratio | 人工輸入，required |
| `netInterestMargin` | `NET_INTEREST_MARGIN` | Ratio | 人工輸入 |
| `costIncome` | `COST_INCOME` | Ratio | 系統計算 |
| `roa` | `ROA` | Ratio | 系統計算 |
| `roe` | `ROE` | Ratio | 系統計算 |
| `loansDeposits` | `LOANS_DEPOSITS` | Ratio | 系統計算 |
| `liquidityCoverage` | `LIQUIDITY_COVERAGE` | Ratio | 人工輸入，required |
| `solvency` | `SOLVENCY` | Ratio | 人工輸入，required |
| `tierOneCapital` | `TIER_ONE_CAPITAL` | Ratio | 人工輸入 |

### 7.2 Main Tables / DAOs

| DAO / Table | 用途 |
|---|---|
| `EPRO_TB_FINANCIAL_EVALUATION_FI` / `TB_FINANCIAL_EVALUATION_FI` | 本功能主要保存表，主鍵順序為 `APPLICATION_NO`、`DATA_SEQ`。 |
| `EPRO_TB_FIN_STATEMENT_BALANCE_FI` / `TB_FIN_STATEMENT_BALANCE_FI` | 編輯模式下計算 ratio 的 Balance 來源。 |
| `EPRO_TB_FIN_STATEMENT_INCOME_FI` / `TB_FIN_STATEMENT_INCOME_FI` | 編輯模式下計算 ratio 的 Income 來源。 |
| `EPRO_TB_LON_SUMMARY_INFO` | 判斷 CS/CU 屬性與案件資訊。 |
| `EPRO_TB_MAIN_BORROWER_INFO_CORP` | 查詢 `MAIN_BORROWER_NAME` 作申請人名稱。 |
| `EPRO_TB_CHECK_POINT_CORP`、`EPRO_TB_CHECK_POINT_CU` | 0120 checkpoint 保存。 |
| `EPRO_TB_CHECK_POINT_RC_CORP`、`EPRO_TB_CHECK_POINT_RC_CU` | 0220 checkpoint 保存。 |

### 7.3 SQL Mapping

| SQL 檔案 | 用途 |
|---|---|
| `com.cathaybk.epro.dao.EPRO_TB_FINANCIAL_EVALUATION_FI.SQL_FIND_001.sql` | 依條件查詢 FI 評估表，支援 dynamic query fields 與 order by。 |
| `...SQL_INSERT_001.sql` | 新增 FI 評估資料全欄位。 |
| `...SQL_DELETE_002.sql` | 依 `APPLICATION_NO` 刪除整案 FI 評估資料；save 使用此 SQL。 |
| `...SQL_DELETE_001.sql` | 依 `APPLICATION_NO` + `DATA_SEQ` 刪除單筆；本頁 save 未直接使用。 |
| `...SQL_UPDATE_001.sql`、`...SQL_UPDATE_002.sql` | DAO 支援 update，但本功能 save 走 delete then insert。 |

### 7.4 Sensitive Data / Masking Expectations

| 項目 | 說明 |
|---|---|
| 申請人名稱 | query audit 設定 `AccessField_name = true`，屬需 audit 的姓名欄位。 |
| Ratio 資料 | 屬財務評估資料，未見遮罩需求；新系統仍應依角色/案件權限控管。 |
| 下載/列印 | 本功能 source 未提供 print/download action。 |

## 8. 業務規則

| 規則 ID | 規則 | 分類 |
|---|---|---|
| BR-001 | 查詢模式讀取已保存 `TB_FINANCIAL_EVALUATION_FI`，不重算 ratio。 | Source confirmed |
| BR-002 | 編輯模式依 `TB_FIN_STATEMENT_BALANCE_FI` 與 `TB_FIN_STATEMENT_INCOME_FI` 計算 ratio。 | Source confirmed |
| BR-003 | 若 Balance 或 Income 清單為 null，編輯模式回傳空清單。 | Source confirmed |
| BR-004 | `COST_INCOME = OPERATING_EXPENSES * 100 / CONTINUING_OP_INCOME_BT`；分母為 0 時為 `N/A`。 | Source confirmed / SA review |
| BR-005 | `LOANS_DEPOSITS = LOANS_DISCOUNTED * 100 / (DEPOSITS_FROM_CB_BF + DEPOSITS_REMITTANCES)`；分母為 0 時為 `N/A`。 | Source confirmed |
| BR-006 | 第一筆年度的 `GGL`、`ROA`、`ROE` 一律為 `N/A`。 | Source confirmed |
| BR-007 | 第二期起 `GGL = (本期 LOANS_DISCOUNTED - 前期 LOANS_DISCOUNTED) * 100 / 前期 LOANS_DISCOUNTED`；前期為 0 時為 `N/A`。 | Source confirmed |
| BR-008 | 第二期起 `ROA = CONTINUING_OP_AT * 100 / PERIODS * 12 / ((本期 TOTAL_ASSETS + 前期 TOTAL_ASSETS) / 2)`；平均資產為 0 時為 `N/A`。 | Source confirmed |
| BR-009 | 第二期起 `ROE = CONTINUING_OP_AT * 100 / PERIODS * 12 / ((本期 TOTAL_STOCKHOLDER_EQUITY + 前期 TOTAL_STOCKHOLDER_EQUITY) / 2)`；平均權益為 0 時為 `N/A`。 | Source confirmed |
| BR-010 | 計算欄位 `COST_INCOME`、`LOANS_DEPOSITS`、`GGL`、`ROA`、`ROE` 以小數兩位顯示，`N/A` 保留。 | Source confirmed |
| BR-011 | `RATIOS_DATE` 畫面格式為 `dd/MM/yyyy`，DB 保存格式為 `yyyy/MM/dd`。 | Source confirmed |
| BR-012 | Save 使用 full replacement，先刪除整案 FI 評估資料，再 insert 當次 `fiList`。 | Source confirmed |
| BR-013 | Save `check = Y`，Finished `check = N`。 | Source confirmed |
| BR-014 | 0120 依 CS/CU 更新 CORP 或 CU checkpoint；0220 依 CS/CU 更新 RC_CORP 或 RC_CU checkpoint。 | Source confirmed |
| BR-015 | 0119/0219 儲存 FI 財報時會將 0120/0220 checkpoint 重設為 `Y`。 | Cross-module confirmed |
| BR-016 | 0110/0210 變更 Business Type 或 Assessment Type 時，會刪除 FI 評估表與 FI/GI 財報資料。 | Cross-module confirmed |

## 9. 錯誤處理

### 9.1 Standard Error / Message Mapping

| 情境 | 來源 | 訊息 |
|---|---|---|
| 查無資料 | `DataNotFoundException` | `MSG_DATA_NOT_FOUND` |
| 查詢超過筆數限制 | `OverCountLimitException` | `MSG_OVER_COUNT_LIMIT` |
| 查詢失敗 | query module/exception | `MSG_QUERY_FAIL` |
| application no 空白 | save module validation | `COMMON_MSG_ERROR_LON` |
| input error | `ErrorInputException` | exception message |
| 儲存失敗 | save exception | `COMMON_MSG_SAVE_FAIL` |
| 儲存成功 | save success | `COMMON_MSG_SAVE_SUCCESS` |

### 9.2 Error Handling Principles

| 原則 | 說明 |
|---|---|
| 查詢錯誤不應覆蓋畫面 | 前端 error callback 將 `_fiList` 設為空清單。 |
| 儲存錯誤需 rollback | module save 包在 `Transaction.begin/commit/rollback`。 |
| 除以零需明確處理 | 舊系統部分分母有處理為 `N/A`，`PERIODS = 0` 尚待補強。 |
| 資料不一致需明確提示 | 新系統應將 Balance/Income 筆數不一致視為 validation error，而非 index exception。 |

## 10. 非功能需求

| ID | 需求 | 說明 |
|---|---|---|
| NFR-001 | 交易一致性 | save 的 delete/insert/checkpoint update 必須在同一 transaction，任一失敗 rollback。 |
| NFR-002 | 權限控管 | 只有 editor 且非 query mode 可編輯；0220 old case 不能 Finished。 |
| NFR-003 | Audit | query/save 均需保留 table access audit；姓名欄位需標記 name access。 |
| NFR-004 | 資料完整性 | 新系統需檢查 `APPLICATION_NO`、`DATA_SEQ`、`RATIOS_DATE` 與來源財報期數一致。 |
| NFR-005 | 併發控制 | full replacement 可能造成最後寫入覆蓋；新系統應避免多使用者同時儲存未提示。 |
| NFR-006 | 相容性 | query mode 應維持讀歷史保存值，編輯模式維持依最新財報重算的差異。 |
| NFR-007 | 可觀測性 | ratio 計算資料缺漏、除以零、筆數不一致應有 log 與可追蹤錯誤。 |

## 11. 驗收標準與測試案例

### 11.1 UAT / SIT 測試案例總表

| Test Case ID | 對應需求 | 測試情境 | 預期結果 |
|---|---|---|---|
| TC-P-001 | FR-001 | 0120 有效案件初始化 | 顯示申請人名稱、checkpoint 與 fiList。 |
| TC-P-002 | FR-001 | 0220 有效 RC 案件初始化 | 顯示申請人名稱、RC checkpoint 與 fiList。 |
| TC-P-003 | FR-002 | 非 query mode 且 0119/0219 有五期 Balance/Income | 回傳五期自動計算 ratio。 |
| TC-P-004 | FR-003 | fiList 只有兩期 | 只開放兩期人工欄位，其餘 disabled。 |
| TC-P-005 | FR-004 | 0120 按 Save | 保存資料，`EPROC0_0120 = Y`。 |
| TC-P-006 | FR-005 | 0120 required 欄位完整後 Finished | 保存資料，`EPROC0_0120 = N`，父頁 done 依 all tabs 狀態更新。 |
| TC-P-007 | FR-006 | 0220 Finished 且非 old case | 保存資料，`EPROC0_0220 = N`，父頁進度更新。 |
| TC-P-008 | FR-007 | query mode 查詢已保存資料 | 顯示歷史保存值，不重新依最新財報計算。 |
| TC-N-001 | FR-001 | Balance 或 Income FI 無資料 | 編輯模式回傳空清單，年度欄 disabled。 |
| TC-N-002 | FR-004 | save 不帶 `APPLICATION_NO` | 回傳 `COMMON_MSG_ERROR_LON`。 |
| TC-N-003 | FR-005 | Finished 缺 required 欄位 | 前端阻擋，不送 save。 |
| TC-N-004 | FR-002 | Balance 五筆、Income 四筆 | 新系統應回傳資料不一致錯誤；舊系統風險為 index error。 |
| TC-N-005 | FR-002 | `PERIODS = 0` 且平均資產/權益不為 0 | 新系統應回傳 validation error 或顯示 `N/A`；不得產生未處理 exception。 |
| TC-B-001 | FR-002 | 分母為 0 的 Cost/Income、Loans/Deposits、GGL | 對應欄位顯示 `N/A`。 |
| TC-B-002 | FR-002 | 第一年度資料 | `GGL`、`ROA`、`ROE` 顯示 `N/A`。 |
| TC-B-003 | FR-004 | Save 相同 payload 重送 | DB 結果一致，無重複資料。 |
| TC-X-001 | FR-006 | 0119 保存後進入 0120 | 0120 checkpoint 被重設為 `Y`，需重新確認/完成。 |
| TC-X-002 | FR-006 | 0219 保存後進入 0220 | 0220 checkpoint 被重設為 `Y`，需重新確認/完成。 |
| TC-X-003 | FR-006 | 0110 Business Type 變更 | FI 評估資料被刪除，checkpoint 依新 Business Type 重設。 |
| TC-X-004 | FR-008 | 0220 old case | Finished 不顯示，save 後不更新 done 樣式。 |

### 11.2 驗收完成條件

| ID | 條件 |
|---|---|
| DONE-001 | 0120/0220 query 與 save API 行為已依 source-confirmed 規格實作或文件化。 |
| DONE-002 | 五個自動 ratio 公式、十一個人工欄位、required 欄位與顯示格式均可驗證。 |
| DONE-003 | `TB_FINANCIAL_EVALUATION_FI` delete/insert 與 checkpoint update 的 DB 副作用可透過 SIT 驗證。 |
| DONE-004 | query mode 與 edit mode 的資料來源差異已被測試覆蓋。 |
| DONE-005 | 待確認項目已有 PM/SA/RD 決策或 migration backlog。 |

## 12. 附件與決策紀錄

### 12.1 參考文件

| 類別 | 路徑 / 說明 |
|---|---|
| Transaction | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0120.java`、`EPROC0_0220.java` |
| Module | `EPROWeb/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0120_mod.java`、`EPROC0_0220_mod.java` |
| UI | `EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00120.jsp`、`EPROC00120_JS.jsp`、`EPROC00220.jsp`、`EPROC00220_JS.jsp` |
| DAO | `EPROWeb/JavaSource/com/cathaybk/epro/dao/EPRO_TB_FINANCIAL_EVALUATION_FI.java` |
| SQL | `SQL/com/cathaybk/epro/dao/com.cathaybk.epro.dao.EPRO_TB_FINANCIAL_EVALUATION_FI.SQL_*.sql` |
| Cross-module | `EPROC0_0119_mod.java`、`EPROC0_0219_mod.java`、`EPROC0_0110_mod.java`、`EPROC0_0210_mod.java`、`EPROC00110.jsp`、`EPROC00210.jsp` |
| Inventory | `D:\Users\00584570\eproposal-inventory\function-inventory.csv` |

### 12.2 Decision Log

| ID | 決策 | 狀態 |
|---|---|---|
| DEC-001 | EPROC00120 PRD 檔名沿用 `CDC-EPRO-0001_EPROC00120_PRD_v1.0`。 | 已採用 |
| DEC-002 | 本文件只定義 C0 0120/0220；I0 同表行為列為共享資料表風險，不納入本期需求。 | 已採用 |
| DEC-003 | `PERIODS = 0`、Balance/Income 筆數不一致、Cost/Income 公式定義列為待確認，不在 PRD 中默默修正 legacy 行為。 | 已採用 |

### 12.3 後續文件建議

| 文件 | 建議內容 |
|---|---|
| API Spec | 補 REST/JSON DTO、validation error code、idempotency 與 concurrency policy。 |
| DB Migration Spec | 盤點 `TB_FINANCIAL_EVALUATION_FI` C0/I0 共表資料、日期格式與主鍵。 |
| Test Plan | 補完整五期公式試算資料、除以零案例、old case RC 案例與父頁 checkpoint regression。 |
