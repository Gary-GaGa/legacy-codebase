業務需求導向的功能規格書

CDC-EPRO-0001 EPROC00119 Financial Statement and Comments FI PRD

台中資訊開發中心

版本 1.0

文件日期：2026/06/15

# EPROC00119 公司戶財務報表與說明 FI PRD

| 文件項目 | 內容 |
|---|---|
| 文件名稱 | EPROC00119 公司戶財務報表與說明 FI PRD |
| 系統 | E-Proposal |
| 模組 | C0 公司戶徵信/評分資料 |
| 功能代號 | EPROC00119 |
| 舊系統程式 | EPROC0_0119、EPROC0_0219 |
| 功能英文名稱 | Financial Statement and Comments FI |
| 功能中文名稱 | 公司戶財務報表與說明 FI |
| 適用流程 | EPROC0_0110 一般公司戶徵信流程；EPROC0_0210 RC 流程 |
| 主要使用者 | RM、徵信/審查人員、覆核人員 |
| 產出檔案 | CDC-EPRO-0001_EPROC00119_PRD_v1.0.md、CDC-EPRO-0001_EPROC00119_PRD_v1.0.docx |

## 0. 文件控制

| 日期 | 版本 | 說明 | 作者 |
|---|---|---|---|
| 2026-06-15 | v1.0 | 依 EPROC0_0119 與 EPROC0_0219 舊系統 Source code 掃描產出初版 PRD | Codex |

| 角色 | Review 重點 |
|---|---|
| PM | 確認 FI 財務報表與說明的業務名稱、適用流程、Save/Finished 語意、匯入前案與列印需求是否符合現行作業。 |
| SA | 確認 Balance Sheet、Income Statement、Cashflow Statement 的年度欄位、公式、檢核、checkpoint 與後續 0120/0220 財務評估表連動。 |
| RD | 確認 API/DTO、交易一致性、full replacement 儲存策略、日期格式、欄位信任邊界與 legacy defect 相容策略。 |
| QA | 依正向、負向、邊界、跨頁連動、報表下載與 0119/0219 差異測試案例驗證。 |

## 0.1 文件目的與範圍

| 項目 | 說明 |
|---|---|
| 文件目的 | 定義公司戶 FI 業務型態下，財務報表主檔、資產負債表、損益表、現金流量表、財務說明、匯入前案、計算、儲存、完成與列印需求。 |
| 涵蓋功能 | EPROC0_0119 一般流程、EPROC0_0219 RC 流程、前端 JSP/JS、交易層 AJAX action、module 計算與儲存邏輯、DAO/SQL 資料表、checkpoint 更新、Excel/PDF 匯出。 |
| 不涵蓋功能 | EPROC0_0120/0220 財務評估表 FI 的比率計算實作、GI 財務報表 0116/0216、個人戶 I0 財務功能、Jasper 報表版面細節。 |
| 來源限制 | 本文件以舊系統 Source code 為主要事實來源；中文註解若受終端編碼影響，則以 class、method、field、SQL 與可辨識流程作為判讀依據。 |

## 0.2 待確認事項與風險

| ID | 類型 | 說明 | 建議處理 |
|---|---|---|---|
| TBD-001 | Legacy defect suspect | EPROC0_0119 交易層 init annotation 實際為 `inti`，EPROC00119_JS.jsp 也呼叫 `inti`；inventory 與一般命名預期為 `init`。0219 則為 `init`。 | 新系統 API 建議使用標準 `init`，若需相容舊前端，另保留 `inti` alias 並註記來源差異。 |
| TBD-002 | Legacy defect suspect | EPROC0_0119_mod.query 讀取 checkpoint 時使用 key `EPROI0_0119`，但 save 寫入與父頁勾選使用 `EPROC0_0119`。0219 query 使用 `EPROC0_0219`。 | PM/SA/RD 確認 0119 顯示完成狀態是否曾異常；新系統應以 `EPROC0_0119` 為主，必要時規劃資料修補。 |
| TBD-003 | Legacy defect suspect | 前端註解顯示「End Balance and Cash and Cash Equivalent is not equal」應不允許兩者不相等，但 JS 實作條件為兩者相等時回傳 false。 | SA/QA 需確認實際業務規則；新系統不可直接照抄前端反向條件。 |
| TBD-004 | 需求確認 | Search 前案資料時，後端條件是 `APP_CON_TYPE` 空白且 `CASE_PROGRESS` 不在 `08,09,14` 才視為無資料，因此只要其中一項符合就可查詢。 | PM/SA 確認前案可匯入條件應為 AND 或 OR；必要時調整為明確的 eligibility rule。 |
| TBD-005 | 資料一致性 | save 以 balance 清單筆數迴圈，同步取 income 與 cashflow 同 index，但 source 未檢查三張表筆數一致。 | 新系統應檢查三張明細筆數與 `DATA_SEQ` 對齊，避免 index error 或年度錯配。 |
| TBD-006 | 需求確認 | JSP Save/Finished 顯示權限使用 `isEditor116` 與 `isEditor216`，不是本頁 suffix 的 `isEditor119` 與 `isEditor219`。 | PM/SA 確認 FI 財報頁是否沿用前一頁編輯權限；若非預期，需修正授權旗標。 |
| TBD-007 | Legacy defect suspect | PDF 組版使用 `EPRO_C00116_GI`、`EPRO_C00116_GI_1` 與 `EPRO_I00119_FI_1/_2/_3` 混合報表 ID；0119 產生檔名為 `EPRO_C00119_GI.pdf`。 | RD/SA 確認是範本共用或命名錯誤；新系統報表 ID 與檔名應與 FI 功能一致。 |
| TBD-008 | 資料完整性 | 前端送出的 `main`、`balancePar`、`incomePar`、`cashflowPar` 皆含 `APPLICATION_NO`，後端 save 主要依 payload 值處理，未逐筆覆寫成可信 request/path 主鍵。 | API 儲存時應以 authenticated context 與 path/body 主鍵覆寫明細主鍵，避免 payload 竄改。 |
| TBD-009 | 需求確認 | Save 僅檢核 `CURRENCY` 與第一至第五年 `BALANCE_DATE`；Finished 才增加公司名、單位、財務說明、audit 問題等 required 檢核。後端只檢核 application no 與 currency。 | PM/SA 確認 Save 可暫存未完整資料；RD 需將 Finished 與 Save validation 分層實作。 |
| TBD-010 | Legacy defect suspect | `getPar` 內對 cashflow 第一年度 `OPENING_BALANCE_0_FI` 的特殊處理使用 jQuery object 與字串比較，條件不會成立。 | RD 檢查第一年度 opening balance 是否仍由一般欄位收集；若資料遺漏需補正。 |

## 1. 業務目標

| ID | 目標 |
|---|---|
| GOAL-001 | 讓 RM 或徵信人員可於公司戶 FI 業務型態輸入五期財務報表資料，作為後續財務評估表 FI 與審查依據。 |
| GOAL-002 | 提供前案匯入能力，降低重複輸入成本，並讓使用者可依本案情況修正後儲存。 |
| GOAL-003 | 依 Balance Sheet、Income Statement、Cashflow Statement 的舊系統公式計算彙總欄位，並在完成前檢核資產負債表平衡與現金流勾稽。 |
| GOAL-004 | 支援一般流程 0119 與 RC 流程 0219，兩者共用 FI 報表資料結構與公式，但連動不同父頁與 checkpoint。 |
| GOAL-005 | 提供 Excel 與 PDF 下載，供案件審查、留存與覆核使用。 |

## 2. Source Scan 摘要

| 類別 | Source | Source-confirmed 行為 |
|---|---|---|
| 0119 交易層 | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0119.java` | AJAX actions 包含 `inti`、`search`、`calculation`、`save`、`print`、`printPDF`；save 後回查 `EPROC0_0110` 父頁進度。 |
| 0219 交易層 | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0219.java` | AJAX actions 包含 `init`、`search`、`calculation`、`save`、`print`、`printPDF`；save 後回查 `EPROC0_0210` RC 父頁進度。 |
| 0119 module | `EPROC0_0119_mod.java` | 查詢 FI 主檔與三張明細表、計算 Balance/Income/Cashflow、儲存 full replacement、更新 CORP/CU checkpoint、產出 Excel/PDF。 |
| 0219 module | `EPROC0_0219_mod.java` | 與 0119 類似，但使用 RC CORP/CU checkpoint，並更新 `EPROC0_0220` 下一頁重算狀態。 |
| 0119 UI | `EPROC00119.jsp`、`EPROC00119_JS.jsp` | 顯示前案查詢、Criteria、audit 問題、Financial Institution、Currency、Unit、Balance/Income/Cashflow/Highlight、Calculation、Save、Finished、Print。 |
| 0219 UI | `EPROC00219.jsp`、`EPROC00219_JS.jsp` | 與 0119 類似，RC old case 下 Finished 依 source 有額外隱藏/不更新 done 狀態行為。 |
| 主檔 DAO | `EPRO_TB_FIN_STATEMENT_MAIN.java` | 主鍵 `APPLICATION_NO`；欄位包含幣別、單位、公司名稱、criteria、audit 問題、audit firm、opinion memo、highlight。 |
| Balance DAO | `EPRO_TB_FIN_STATEMENT_BALANCE_FI.java` | 主鍵依 `APPLICATION_NO` 與 `DATA_SEQ`；保存 FI Balance Sheet 五期資料與計算欄位。 |
| Income DAO | `EPRO_TB_FIN_STATEMENT_INCOME_FI.java` | 主鍵依 `APPLICATION_NO` 與 `DATA_SEQ`；保存 FI Income Statement 五期資料與計算欄位。 |
| Cashflow DAO | `EPRO_TB_FIN_STATEMENT_CASHFLOW_FI.java` | 主鍵依 `APPLICATION_NO` 與 `DATA_SEQ`；保存 FI Cashflow Statement 五期資料與計算欄位。 |
| 父頁連動 | `EPROC0_0110_mod.java`、`EPROC0_0210_mod.java` | Business Type 為 FI 時啟用 0119/0120/0118 或 0219/0220/0218；Business Type 變更會清除 FI/GI 相關財報、評估與 scorecard 資料。 |
| 下游連動 | `EPROC0_0120_mod.java`、`EPROC0_0220_mod.java` | 財務評估表 FI 讀取 0119/0219 保存的 Balance 與 Income FI 資料計算指標。 |
| 報表 | `reports/xml/EPRO/EPRO_I00119_FI*.jrxml` | PDF 使用 FI 報表子範本與部分 GI 命名範本；Excel 匯出三個 sheet：Balance Sheet、Income Statement、Cashflow Statement。 |
| Inventory | `eproposal-inventory/function-inventory.csv` | 0119/0219 功能屬 C0 公司戶徵信/評分資料，action 包含 init、search、calculation、save、print/report/download。 |

## 3. 使用者與權限

| 角色/狀態 | 可執行行為 | Source-confirmed / 備註 |
|---|---|---|
| 編輯者 | 可查詢前案、輸入財務資料、執行計算、Save、Finished、Print、Print PDF。 | Source confirmed；但 JSP 使用 `isEditor116`/`isEditor216` 控制 Save/Finished，需確認是否沿用前頁權限。 |
| 查詢模式 | 只能檢視資料與下載報表，不可儲存或重新計算。 | Source confirmed；JS 會 disable `.isView119` 或 `.isView219`，並隱藏 Save/Calculation。 |
| RC old case | 0219 Finished 與 done class 更新受 `attrMap.isOld` 影響。 | Source confirmed；需與 RC 舊案作業規則對齊。 |
| 一般公司戶 | 使用 EPROC0_0110 父頁進度與 CORP/CU checkpoint。 | Source confirmed。 |
| RC 公司戶 | 使用 EPROC0_0210 父頁進度與 RC_CORP/RC_CU checkpoint。 | Source confirmed。 |

## 4. 功能流程

### 4.1 初始化

| ID | 需求 | 來源 |
|---|---|---|
| INIT-001 | 使用者進入 0119 頁面時，前端呼叫 `/EPROC0_0119/inti` 並帶入 `APPLICATION_NO`。 | Source confirmed / Legacy defect suspect |
| INIT-002 | 使用者進入 0219 頁面時，前端呼叫 `/EPROC0_0219/init` 並帶入 `APPLICATION_NO`。 | Source confirmed |
| INIT-003 | 後端應載入 select options：`CCY` 作為 Currency、`CCY_UNIT` 作為 Unit、`TYPE_OF_YEAR` 作為年度類型。 | Source confirmed |
| INIT-004 | 後端應讀取 `TB_FIN_STATEMENT_MAIN`、`TB_FIN_STATEMENT_BALANCE_FI`、`TB_FIN_STATEMENT_INCOME_FI`、`TB_FIN_STATEMENT_CASHFLOW_FI`。 | Source confirmed |
| INIT-005 | 若 Balance、Income、Cashflow 三張明細皆有資料，回傳 `haveData = Y`；否則回傳 `haveData = N`。 | Source confirmed |
| INIT-006 | 前端收到 `haveData = Y` 時顯示 Print 與 Print PDF；無完整資料時隱藏列印按鈕。 | Source confirmed |
| INIT-007 | 前端應將 `HIGHLIGHT` 依序拆回五個 textarea：Loan Repayment Basis、Financial Situation、Business Risk、Borrower Risk、Summary。 | Source confirmed |

### 4.2 匯入前案資料

| ID | 需求 | 來源 |
|---|---|---|
| SEARCH-001 | 使用者可輸入前案 `RE_APPLICATION_NO` 並按 Search，呼叫 `/search`。 | Source confirmed |
| SEARCH-002 | 後端以 `TB_LON_SUMMARY_INFO.find` 檢查前案案件狀態與 application condition type。 | Source confirmed |
| SEARCH-003 | 前案必須存在主檔、Balance、Income、Cashflow；任一缺漏時回傳無資料錯誤。 | Source confirmed |
| SEARCH-004 | 匯入成功後，前端清空本頁既有輸入，再將前案主檔與三張報表資料帶入畫面。 | Source confirmed |
| SEARCH-005 | 匯入後應讓 Calculation 重新啟用，Print/Print PDF 隱藏，避免使用者列印未重新確認的資料。 | Source confirmed |

### 4.3 財報主檔輸入

| ID | 需求 | 來源 |
|---|---|---|
| MAIN-001 | 使用者須選擇 Currency 與 Unit。 | Source confirmed |
| MAIN-002 | 使用者須輸入 Financial Institution。 | Source confirmed |
| MAIN-003 | 使用者可勾選 Criteria 1、Criteria 2、Criteria 3。 | Source confirmed |
| MAIN-004 | 使用者須回答是否需要 audited financial statements，以及是否已提供 audited financial statements 給銀行。 | Source confirmed |
| MAIN-005 | 使用者可輸入 Audit Firm，長度上限 50。 | Source confirmed |
| MAIN-006 | 使用者可輸入 Opinion Memo，長度上限 500。 | Source confirmed |
| MAIN-007 | 使用者須輸入五段 Financial Highlight 說明，Finished 時列為 required。 | Source confirmed |

### 4.4 Balance Sheet 輸入與計算

| ID | 需求 | 來源 |
|---|---|---|
| BAL-001 | 畫面顯示五期 Balance Sheet 欄位，以 `DATA_SEQ` 1 至 5 對應年度欄。 | Source confirmed |
| BAL-002 | 使用者輸入 Balance Date 後，前端自動同步 Income Date 與 Cashflow Date，並依月份設定 Periods。 | Source confirmed |
| BAL-003 | Balance Date 可接受 `dd/MM/yyyy` 或 `ddMMyyyy`，前端統一轉為 `dd/MM/yyyy` 顯示。 | Source confirmed |
| BAL-004 | 使用者可選擇各期 Type of Year，前端同步顯示至 Income 與 Cashflow。 | Source confirmed |
| BAL-005 | 計算後 Difference 應為 0，Finished 前若有日期且 Difference 不為 0 則不得完成。 | Source confirmed |
| BAL-006 | 第一年度 Total Assets 與 Total Liabilities Equity 不得為 0。 | Source confirmed |

### 4.5 Income Statement 輸入與計算

| ID | 需求 | 來源 |
|---|---|---|
| INC-001 | Income Statement 以 Balance Date 同步出的 Income Date 與 Periods 為年度基準。 | Source confirmed |
| INC-002 | 使用者輸入 Interest Income、Interest Expenses、各項 non-interest gain/loss、allowance、expense、tax 等欄位。 | Source confirmed |
| INC-003 | Calculation 會計算 Net Interest Income、Net Other Non Interest Gain、Net Revenues、Continuing Operation Income Before Tax、Continuing Operation After Tax 與 Consolidated Net Income Merge。 | Source confirmed |
| INC-004 | Income 明細與 Balance 明細須以相同 `DATA_SEQ` 保存。 | Source confirmed / 資料一致性風險 |

### 4.6 Cashflow Statement 輸入與計算

| ID | 需求 | 來源 |
|---|---|---|
| CF-001 | Cashflow Statement 以 Balance Date 同步出的 Cashflow Date 與 Periods 為年度基準。 | Source confirmed |
| CF-002 | 使用者輸入 Operating Net Cashflow、Investing Net Cashflow、Financing Net Cashflow、Depreciation、Amortisation 等欄位。 | Source confirmed |
| CF-003 | Calculation 會計算 Net Increase Decrease Cash、Opening Balance、End Balance。 | Source confirmed |
| CF-004 | 第一年度 Opening Balance 來自畫面輸入；第二年度起 Opening Balance 等於前一年度 End Balance。 | Source confirmed / 前端收值需確認 |
| CF-005 | 前端有 End Balance 與 Cash and Cash Equivalent 的勾稽檢核，但 source 條件與註解相反，需確認正確規則。 | Legacy defect suspect |

### 4.7 Save 與 Finished

| ID | 需求 | 來源 |
|---|---|---|
| SAVE-001 | Save 代表暫存，前端以 `check = Y` 呼叫 `/save`。 | Source confirmed |
| SAVE-002 | Finished 代表完成本頁，前端以 `check = N` 呼叫 `/save`，並執行較完整 validation。 | Source confirmed |
| SAVE-003 | 後端 save 必須檢查 request 不為空、`APPLICATION_NO` 不為空、`CURRENCY` 不為空。 | Source confirmed |
| SAVE-004 | 後端使用 transaction，先 upsert 主檔，再刪除本 application 的 Balance/Income/Cashflow FI 明細，再逐筆 insert/update。 | Source confirmed |
| SAVE-005 | 後端儲存時若日期不含 `/`，會將 `ddMMyyyy` 轉為 `dd/MM/yyyy`，並同步寫入 Income/Cashflow 日期。 | Source confirmed |
| SAVE-006 | 0119 儲存成功後，更新 CORP 或 CU checkpoint，並將下一頁 `EPROC0_0120` 設為 `Y`。 | Source confirmed |
| SAVE-007 | 0219 儲存成功後，更新 RC_CORP 或 RC_CU checkpoint，並將下一頁 `EPROC0_0220` 設為 `Y`。 | Source confirmed |
| SAVE-008 | 前端 save callback 應呼叫父頁 `check` 重新計算頁籤進度；若全頁籤完成，父頁 done 樣式更新。 | Source confirmed |
| SAVE-009 | 儲存發生例外時，transaction rollback 並回傳 save fail message。 | Source confirmed |

### 4.8 匯出與列印

| ID | 需求 | 來源 |
|---|---|---|
| PRINT-001 | 使用者按 Print 時呼叫 `/print`，後端產出 Excel 暫存檔並回傳加密下載參數。 | Source confirmed |
| PRINT-002 | Excel 檔名為 `FIyyyyMMdd.xls`，包含 `Balance Sheet`、`Income Statement`、`Cashflow Statement` 三個 sheet。 | Source confirmed |
| PRINT-003 | 使用者按 Print PDF 時呼叫 `/printPDF`，後端產出 PDF 暫存檔並回傳加密路徑。 | Source confirmed |
| PRINT-004 | 若無 `APPLICATION_NO` 或查無完整資料，後端不得產生檔案並應回傳錯誤。 | Source confirmed |
| PRINT-005 | 0119 PDF 檔名 source 為 `EPRO_C00119_GI.pdf`，0219 為 `EPRO_C00219_FI.pdf`；命名一致性需確認。 | Legacy defect suspect |

## 5. API 規格

### 5.1 init / inti

| 項目 | 0119 | 0219 |
|---|---|---|
| Endpoint | `/EPROC0_0119/inti` | `/EPROC0_0219/init` |
| Method | AJAX POST |
| Request | `APPLICATION_NO` |
| Response | `RE_MAP`、`SEL_CURRENCY`、`SEL_UNIT`、`SEL_TYPE_YEAR` |
| Audit | Query / Table |
| Error | `COMMON_MSG_ERROR_LON`、`MSG_DATA_NOT_FOUND`、`MSG_OVER_COUNT_LIMIT`、`MSG_QUERY_FAIL` |

| Response 欄位 | 說明 |
|---|---|
| `RE_MAP.main` | `TB_FIN_STATEMENT_MAIN` 主檔資料。 |
| `RE_MAP.balance` | `TB_FIN_STATEMENT_BALANCE_FI` 明細清單。 |
| `RE_MAP.income` | `TB_FIN_STATEMENT_INCOME_FI` 明細清單。 |
| `RE_MAP.cashFlow` | `TB_FIN_STATEMENT_CASHFLOW_FI` 明細清單。 |
| `RE_MAP.haveData` | 三張明細皆存在時為 `Y`，否則 `N`。 |
| `RE_MAP.check` | checkpoint 狀態；0119 source 讀取 key 疑似錯誤，詳 TBD-002。 |
| `SEL_CURRENCY` | `CCY` common field options。 |
| `SEL_UNIT` | `CCY_UNIT` common field options。 |
| `SEL_TYPE_YEAR` | `TYPE_OF_YEAR` common field options。 |

### 5.2 search

| 項目 | 說明 |
|---|---|
| Endpoint | `/EPROC0_0119/search`、`/EPROC0_0219/search` |
| Method | AJAX POST |
| Request | `reApplication` |
| Response | `reMap` |
| Audit | Query / Table |
| Success message | `MSG_QUERY_SUCCESS` |
| Error | `MSG_ERROR_APPLICATION_NO`、`MSG_OVER_COUNT_LIMIT`、`MSG_QUERY_FAIL`、common no data message |

| Response 欄位 | 說明 |
|---|---|
| `reMap.main` | 前案主檔。 |
| `reMap.balance` | 前案 Balance FI。 |
| `reMap.income` | 前案 Income FI。 |
| `reMap.cashFlow` | 前案 Cashflow FI。 |

### 5.3 calculation

| 項目 | 說明 |
|---|---|
| Endpoint | `/EPROC0_0119/calculation`、`/EPROC0_0219/calculation` |
| Method | AJAX POST |
| Request | `balancePar` JSON、`incomePar` JSON、`cashflowPar` JSON |
| Response | `RE_LIST` |
| Audit | Transfer / Table |
| Error | `COMMON_MSG_TOTAL_FAIL` |

| Response 欄位 | 說明 |
|---|---|
| `RE_LIST.balancePar` | 依 Balance formula 補入的各期計算欄位。 |
| `RE_LIST.incomePar` | 依 Income formula 補入的各期計算欄位。 |
| `RE_LIST.cashflowPar` | 依 Cashflow formula 補入的各期計算欄位。 |

### 5.4 save

| 項目 | 說明 |
|---|---|
| Endpoint | `/EPROC0_0119/save`、`/EPROC0_0219/save` |
| Method | AJAX POST |
| Request | `main` JSON、`balancePar` JSON、`incomePar` JSON、`cashflowPar` JSON、`checkPoint` JSON、`pageCheckMap` JSON |
| Response | `tabsList`、`isAllTabsCheck` |
| Audit | Edit / Table |
| Success message | `COMMON_MSG_SAVE_SUCCESS` |
| Error | `COMMON_MSG_SAVE_FAIL`、`COMMON_MSG_ERROR_LON`、currency required message |

| Request 欄位 | 說明 |
|---|---|
| `main` | 主檔欄位，包含 `APPLICATION_NO`、`CURRENCY`、`CCY_UNIT`、`COMPANY_NAME`、criteria、audit 欄位、highlight。 |
| `balancePar` | Balance FI 五期明細，前端會略過空白 Balance Date 年度。 |
| `incomePar` | Income FI 五期明細，須與 Balance `DATA_SEQ` 對齊。 |
| `cashflowPar` | Cashflow FI 五期明細，須與 Balance `DATA_SEQ` 對齊。 |
| `checkPoint` | 0119 使用 `EPROC0_0119`，0219 使用 `EPROC0_0219`，value 為 `Y` 或 `N`。 |
| `pageCheckMap` | 父頁進度重新計算所需資料。 |

### 5.5 print / printPDF

| 項目 | print | printPDF |
|---|---|---|
| Endpoint | `/EPROC0_0119/print`、`/EPROC0_0219/print` | `/EPROC0_0119/printPDF`、`/EPROC0_0219/printPDF` |
| Method | AJAX POST |
| Request | `APPLICATION_NO` |
| Response | 加密下載參數 | 加密暫存 PDF 路徑 |
| Audit | Print / Table | Print / Table；含 ID/Name/Birthday/Address access flags |
| Success message | `MSG_EXPORT_SUCCESS` | `COMMON_MSG_DOWNLOAD_SUCCESS` |
| Error | `COMMON_MSG_PRINT_FAIL` | `COMMON_MSG_DOWNLOAD_FAIL` |

## 6. 資料模型

### 6.1 主檔 TB_FIN_STATEMENT_MAIN

| 欄位 | 說明 | 來源 |
|---|---|---|
| `APPLICATION_NO` | 案件編號，主鍵。 | Source confirmed |
| `CURRENCY` | 財報幣別。 | Source confirmed |
| `CCY_UNIT` | 金額單位。 | Source confirmed |
| `HIGHLIGHT` | 五段財務說明，以分隔字元組成一個欄位保存。 | Source confirmed |
| `COMPANY_NAME` | Financial Institution。 | Source confirmed |
| `CRITERIA_1` | Criteria 1 勾選值。 | Source confirmed |
| `CRITERIA_2` | Criteria 2 勾選值。 | Source confirmed |
| `CRITERIA_3` | Criteria 3 勾選值。 | Source confirmed |
| `DOES_NEED_AUDITED_FS` | 是否需要 audited financial statements。 | Source confirmed |
| `HAVE_PROVIDED_AUDITED_FS` | 是否已提供 audited financial statements 給銀行。 | Source confirmed |
| `AUDIT_FIRM` | Audit Firm。 | Source confirmed |
| `OPINION_MEMO` | Opinion Memo。 | Source confirmed |

### 6.2 Balance FI 明細

| 類別 | 代表欄位 | 說明 |
|---|---|---|
| 主鍵 | `APPLICATION_NO`、`DATA_SEQ` | 每案每年度一筆，`DATA_SEQ` 由 1 至 5。 |
| 年度資訊 | `BALANCE_DATE`、`PERIODS`、`TYPE_OF_YEAR` | Balance Date、月份期間、年度類型。 |
| Assets | `CASH_AND_CASH_EQU`、`FINANCIAL_ASSETS`、`RECEIVABLES`、`LOANS_DISCOUNTED`、`FIXED_ASSETS`、`OTHER_ASSETS`、`TOTAL_ASSETS` | 資產相關欄位與總資產。 |
| Liabilities | `DEPOSITS_REMITTANCES`、`FINANCIAL_LIAB`、`PAYABLES`、`BONDS_PAYABLE`、`OTHER_LIABILITIES`、`TOTAL_LIABILITIES` | 負債相關欄位與總負債。 |
| Equity | `PAID_IN_CAPITAL`、`CAPITAL_SURPLUS`、`RETAINED_EARNING`、`OTHER_EQUITY`、`TOTAL_STOCKHOLDER_EQUITY` | 股東權益相關欄位。 |
| 勾稽 | `TOTAL_LIAB_EQUITY`、`DIFFERENCE` | 負債加權益與資產差額。 |

### 6.3 Income FI 明細

| 類別 | 代表欄位 | 說明 |
|---|---|---|
| 主鍵 | `APPLICATION_NO`、`DATA_SEQ` | 每案每年度一筆，須與 Balance 對齊。 |
| 年度資訊 | `INCOME_DATE`、`PERIODS`、`TYPE_OF_YEAR` | Income Date、月份期間、年度類型。 |
| Interest | `INTEREST_INCOME`、`INTEREST_EXPENSES`、`NET_INTEREST_INCOME` | 利息收入、支出與淨利息收入。 |
| Non-interest | `NET_FEE_COMMISSION_INCOME`、`FIAN_ASSETS_BONDS_FVTPL`、`AVAILABLE_SALE_FIN_ASSETS_RI`、`EXCHANGE_GAIN`、`OTH_NET_GAIN`、`NET_OTH_NON_INTEREST_GAIN` | 非利息收益與損失。 |
| Profit | `NET_REVENUES`、`CONTINUING_OP_INCOME_BT`、`CONTINUING_OP_AT`、`CONSOLIDATED_NET_INCOME_MERGE`、`CONSOLIDATED_NET_INCOME` | 收入、稅前稅後與合併淨利。 |

### 6.4 Cashflow FI 明細

| 類別 | 代表欄位 | 說明 |
|---|---|---|
| 主鍵 | `APPLICATION_NO`、`DATA_SEQ` | 每案每年度一筆，須與 Balance 對齊。 |
| 年度資訊 | `CASHFLOW_DATE`、`PERIODS`、`TYPE_OF_YEAR` | Cashflow Date、月份期間、年度類型。 |
| Cashflow | `OPERATING_NET_CASHFLOW`、`INVESTING_NET_CASHFLOW`、`FINANCING_NET_CASHFLOW` | 營業、投資、籌資現金流。 |
| 調整 | `DEPRECIATION`、`AMORTISATION` | 折舊與攤銷。 |
| 勾稽 | `NET_INCRE_DECRE_CASH`、`OPENING_BALANCE`、`END_BALANCE` | 現金增加減少、期初與期末餘額。 |

## 7. 計算規則

### 7.1 Balance Sheet

| 欄位 | 公式 | 來源 |
|---|---|---|
| `RETAINED_EARNING` | `LEGAL_RESERVE + SPECIAL_RESERVE + UNAPPROPRIATED_EARN` | Source confirmed |
| `TOTAL_STOCKHOLDER_EQUITY` | `PAID_IN_CAPITAL + CAPITAL_SURPLUS + RETAINED_EARNING + OTHER_EQUITY + TOTAL_EQUITY_ATTR_OWNER_PARENT + NON_CONTROL_INTEREST` | Source confirmed |
| `DEPOSITS_REMITTANCES` | `CHECKING_ACCT_DEPOSITS + DEMAND_DEPOSITS + NEGOTIABLE_CERT_DEPOSIT + TERM_DEPOSITS + SAVINGS_ACCT_DEPOSITS + TERM_SAVINGS_DEPOSITS + SAVING_DEPOSITS + OTH_DEPOSITS_REMITTANCES` | Source confirmed |
| `FINANCIAL_LIAB` | `FINANCIAL_LIAB_FAIT_VALUE + SECURITIES_SOLD + PREFER_STOCK_LIAB + OTHER_FINAN_LIAB` | Source confirmed |
| `TOTAL_LIABILITIES` | `DEPOSITS_FROM_CB_BF + BORROWER_FROM_CB_BF + COMMERCIAL_PAPER_ISSUED + FINANCIAL_LIAB + PAYABLES + LIABILITIES_RELATED_ASSETS + DEPOSITS_REMITTANCES + BONDS_PAYABLE + OTHER_LIABILITIES` | Source confirmed |
| `ACCUMULATED_DEPRECIATION` | `ACCUMULATED_DEPRECIATION_BS + ACC_DEP_MACHINE_COMPUTER + ACC_DEP_OTH_FIX_ASSETS` | Source confirmed |
| `FIXED_ASSETS_COST` | `LAND + BUILDING_STRUCTURES + MACHINERY_COMPUTER_EQU + OTHER_FIXED_ASSETS` | Source confirmed |
| `FIXED_ASSETS` | `FIXED_ASSETS_COST - ACCUMULATED_DEPRECIATION - ACC_IMPAIRMENT` | Source confirmed |
| `LOANS_DISCOUNTED` | `BILLS_NEGOTIATED_ND + OVERDRAFTS + SHORT_TERM_LOANS + ACCOUNTS_RECEIVABLE_FIN + SECURED_OVERDRAFTS + SHORT_TERM_SECURED_LOANS + MARGIN_LOANS_RECEIVABLE + MEDIUM_TERM_LOANS + MEDIUM_TERM_SECURED_LOANS + LONG_TERM_LOANS + LONG_TERM_SECURED_LOANS + OVERDUE_LOANS + PREMIUM_ADJ_ON_DISCOUNT_LOAN - LESS_AFBDDAL` | Source confirmed |
| `FINANCIAL_ASSETS` | `FINANCIAL_ASSETS_AT_FV + SECURITIES_PURCHASED_URA + AVAILALE_FOR_SFA + HELD_TO_MATURITY_FA + OTHER_FA` | Source confirmed |
| `TOTAL_LIAB_EQUITY` | `TOTAL_LIABILITIES + TOTAL_STOCKHOLDER_EQUITY` | Source confirmed |
| `TOTAL_ASSETS` | `CASH_AND_CASH_EQU + DEPOSITS_PLACEMENT_WITH_CB_FIS + FINANCIAL_ASSETS + RECEIVABLES + ASSETS_CLASSIFIED_AS_HFS + LOANS_DISCOUNTED + INVESTMENTS_ACCOUNT_FOR_UEM + FIXED_ASSETS + INTANGILBLE_ASSETS_NET + OTHER_ASSETS` | Source confirmed |
| `DIFFERENCE` | `TOTAL_ASSETS - TOTAL_LIAB_EQUITY` | Source confirmed |

### 7.2 Income Statement

| 欄位 | 公式 | 來源 |
|---|---|---|
| `NET_INTEREST_INCOME` | `INTEREST_INCOME - INTEREST_EXPENSES` | Source confirmed |
| `NET_OTH_NON_INTEREST_GAIN` | `NET_FEE_COMMISSION_INCOME + FIAN_ASSETS_BONDS_FVTPL + AVAILABLE_SALE_FIN_ASSETS_RI + HOLDING_MATURIRY_FIN_ASSETS_RI + USER_EQUITY_METHOD + EXCHANGE_GAIN + IMPAIRMENT_LOSSES + OTH_NET_GAIN` | Source confirmed |
| `NET_REVENUES` | `NET_INTEREST_INCOME + NET_OTH_NON_INTEREST_GAIN` | Source confirmed |
| `CONTINUING_OP_INCOME_BT` | `NET_REVENUES - ALLOWANCE_BAD_DEBT_LOAN - OPERATING_EXPENSES - DEPRECIATION_AMORTISATION` | Source confirmed |
| `CONTINUING_OP_AT` | `CONTINUING_OP_INCOME_BT - INCOME_TAX_EXPENSE` | Source confirmed |
| `CONSOLIDATED_NET_INCOME_MERGE` | `CONTINUING_OP_AT + DISCOUNTINUED_UNITS + EXTRAORDINARY_GAIN + CUMULATIVE_EFFECTS` | Source confirmed |

### 7.3 Cashflow Statement

| 欄位 | 公式 | 來源 |
|---|---|---|
| `NET_INCRE_DECRE_CASH` | `OPERATING_NET_CASHFLOW + INVESTING_NET_CASHFLOW + FINANCING_NET_CASHFLOW` | Source confirmed |
| `OPENING_BALANCE` 第一年度 | 使用前端輸入的第一年度 opening balance。 | Source confirmed / 前端收值需確認 |
| `OPENING_BALANCE` 第二年度起 | 前一年度 `END_BALANCE`。 | Source confirmed |
| `END_BALANCE` | `NET_INCRE_DECRE_CASH + OPENING_BALANCE`。 | Source confirmed |

## 8. 驗證與錯誤處理

| 情境 | 規則 | 訊息/處理 |
|---|---|---|
| 初始化缺 application no | 後端拒絕查詢。 | `COMMON_MSG_ERROR_LON` |
| 查無本案資料 | 後端回傳無資料。 | `MSG_DATA_NOT_FOUND` 或 common no data message |
| 前案查詢空白 | 後端回傳 application no error。 | `MSG_ERROR_APPLICATION_NO` |
| 前案資料不完整 | 主檔、Balance、Income、Cashflow 任一缺漏即視為無資料。 | common no data message |
| Calculation 無資料 | 前端若三張報表都沒有輸入，不呼叫或提示需輸入資料。 | `COMMON_MSG_FIELD_CALCULATED` |
| Balance 不平衡 | 有 Balance Date 且 `DIFFERENCE != 0` 時不得 Finished。 | 前端錯誤提示 |
| 第一年度金額為 0 | 第一年度 Total Assets 或 Total Liab Equity 為 0 時不得 Finished。 | 前端錯誤提示 |
| Currency 空白 | 後端 save 拒絕。 | `EPROI0_0160_MSG_ERRO_CURRENCY` |
| Save 失敗 | transaction rollback。 | `COMMON_MSG_SAVE_FAIL` |
| Print 無資料 | 不產生下載檔。 | `COMMON_MSG_PRINT_FAIL` 或 download fail |

## 9. 跨模組連動

| 模組 | 連動內容 | 來源 |
|---|---|---|
| EPROC0_0110 | Business Type 為 FI 時啟用 `EPROC0_0119`、`EPROC0_0120`、`EPROC0_0118`；變更 Business Type 時會清除 FI/GI 財報與評估資料。 | Cross-module confirmed |
| EPROC0_0210 | RC 流程在 Assessment Type 與 Business Type 條件下啟用 `EPROC0_0219`、`EPROC0_0220`、`EPROC0_0218`。 | Cross-module confirmed |
| EPROC0_0120 | 讀取 `TB_FIN_STATEMENT_BALANCE_FI` 與 `TB_FIN_STATEMENT_INCOME_FI`，產生 FI 財務評估表。 | Cross-module confirmed |
| EPROC0_0220 | RC 讀取 FI Balance/Income 產生後續財務評估。 | Cross-module confirmed |
| Checkpoint CORP/CU | 0119 根據 `LON_ATTRIBUTE + SECURE_ATTRIBUTE == CS` 決定更新 CORP 或 CU checkpoint。 | Source confirmed |
| Checkpoint RC_CORP/RC_CU | 0219 根據 `LON_ATTRIBUTE + SECURE_ATTRIBUTE == CS` 決定更新 RC_CORP 或 RC_CU checkpoint。 | Source confirmed |

## 10. 非功能需求

| ID | 需求 | 說明 |
|---|---|---|
| NFR-001 | 交易一致性 | save 必須使用 transaction；任一主檔、明細或 checkpoint 更新失敗時 rollback。 |
| NFR-002 | 可追溯性 | query、search、calculation、save、print、printPDF 應保留既有 audit 行為。 |
| NFR-003 | 資料完整性 | 新系統應檢查三張明細的筆數、`DATA_SEQ` 與日期一致性。 |
| NFR-004 | 安全性 | 明細 `APPLICATION_NO` 不應信任前端逐筆 payload，應由 server-side 主鍵覆寫。 |
| NFR-005 | 可相容性 | 若前端或外部連結仍依賴 0119 `inti`，需提供相容路由或 migration rewrite。 |
| NFR-006 | 報表可用性 | Excel/PDF 下載參數需加密，暫存檔路徑不可直接暴露。 |
| NFR-007 | 編碼品質 | Markdown 與 DOCX 必須使用 UTF-8/OpenXML 正常保存中文封面文字。 |

## 11. 測試案例

### 11.1 正向測試

| ID | 測試情境 | 步驟 | 預期結果 |
|---|---|---|---|
| TC-P-001 | 0119 初始化既有資料 | 以有完整 FI 財報資料的 application no 進入 0119。 | 畫面帶出主檔與三張報表，Print/Print PDF 顯示，checkpoint 依確認後 key 顯示。 |
| TC-P-002 | 0219 初始化既有資料 | 以有完整 FI 財報資料的 RC application no 進入 0219。 | 畫面帶出資料，checkpoint 讀取 `EPROC0_0219`。 |
| TC-P-003 | 匯入前案 | 輸入具有完整 FI 財報資料的前案並 Search。 | 前案資料帶入本頁，Calculation 重新啟用，列印按鈕隱藏。 |
| TC-P-004 | 執行 Calculation | 輸入 Balance、Income、Cashflow 必要金額後按 Calculation。 | 計算欄位依公式更新，通過檢核後 Calculation disabled。 |
| TC-P-005 | Save 暫存 | 填入 application no、currency 與部分日期後按 Save。 | 後端保存資料，checkpoint value 為 `Y`，下一頁 checkpoint 重設為 `Y`。 |
| TC-P-006 | Finished 完成 | 填入所有 required 欄位，計算通過後按 Finished。 | 後端保存資料，checkpoint value 為 `N`，父頁進度更新。 |
| TC-P-007 | Excel 下載 | 完整資料保存後按 Print。 | 下載 Excel，包含三個 sheet。 |
| TC-P-008 | PDF 下載 | 完整資料保存後按 Print PDF。 | 下載 PDF 或取得加密暫存路徑，audit print 記錄成立。 |

### 11.2 負向測試

| ID | 測試情境 | 步驟 | 預期結果 |
|---|---|---|---|
| TC-N-001 | 初始化無 application no | 呼叫 init/inti 不帶 `APPLICATION_NO`。 | 回傳 `COMMON_MSG_ERROR_LON`。 |
| TC-N-002 | 前案不存在 | Search 輸入不存在或無完整財報資料的前案。 | 顯示無資料或 application no error，畫面不覆蓋現有資料。 |
| TC-N-003 | Currency 空白 Save | 清空 Currency 後呼叫 save。 | 後端拒絕並回傳 currency required message。 |
| TC-N-004 | Balance 不平衡 | 輸入有日期但 Difference 不為 0 後 Finished。 | 前端阻擋，不送 save 或不標記完成。 |
| TC-N-005 | 第一年度總額為 0 | 第一年度 Total Assets 或 Total Liab Equity 為 0 後 Finished。 | 前端阻擋。 |
| TC-N-006 | 三張明細筆數不一致 | 送出 Balance 兩筆、Income 一筆、Cashflow 兩筆。 | 新系統應回傳 validation error；舊系統可能發生 index error，列為修正點。 |
| TC-N-007 | Print 無完整資料 | `haveData = N` 或任一明細缺漏時呼叫 print。 | 不產檔並回傳 print fail。 |

### 11.3 邊界測試

| ID | 測試情境 | 步驟 | 預期結果 |
|---|---|---|---|
| TC-B-001 | 五期資料全滿 | 輸入五期 Balance/Income/Cashflow 並計算保存。 | 五筆明細依 `DATA_SEQ` 1 至 5 保存且順序正確。 |
| TC-B-002 | 僅第一期資料 | 只輸入第一期 Balance Date 與相關資料。 | 只保存一筆明細；若 Finished，仍需符合 required 與計算規則。 |
| TC-B-003 | 日期格式 ddMMyyyy | 輸入 `31032026`。 | 前端或後端轉為 `31/03/2026`，Periods 為 3。 |
| TC-B-004 | KHR 幣別 | Currency 選 KHR 後輸入金額。 | 金額格式以整數顯示。 |
| TC-B-005 | Audit Firm 長度 | 輸入 50 與 51 字元。 | 50 可輸入；51 應由前端 maxlength 或 validation 阻擋。 |
| TC-B-006 | Opinion Memo 長度 | 輸入 500 與 501 字元。 | 500 可輸入；501 應由前端 maxlength 或 validation 阻擋。 |

### 11.4 跨模組測試

| ID | 測試情境 | 步驟 | 預期結果 |
|---|---|---|---|
| TC-X-001 | 0119 完成後進 0120 | 在 0119 Finished 後進入 0120。 | 0120 可讀取 FI Balance/Income 並計算財務評估。 |
| TC-X-002 | 0219 完成後進 0220 | 在 0219 Finished 後進入 0220。 | 0220 可讀取 FI Balance/Income 並計算 RC 財務評估。 |
| TC-X-003 | Business Type 變更 | 在 0110 或 0210 變更 Business Type。 | 舊 FI/GI 財報、評估與 scorecard 資料依 source 被清除，checkpoint 重新配置。 |
| TC-X-004 | CS/CU checkpoint | 以 CS 與非 CS 屬性案件分別保存。 | 0119 更新 CORP 或 CU checkpoint；0219 更新 RC_CORP 或 RC_CU checkpoint。 |

## 12. 新系統建議 DTO

| DTO | 欄位 | 說明 |
|---|---|---|
| `FinancialStatementFiInitRequest` | `applicationNo` | 初始化查詢。 |
| `FinancialStatementFiInitResponse` | `main`、`balanceRows`、`incomeRows`、`cashflowRows`、`haveData`、`check`、`currencyOptions`、`unitOptions`、`typeOfYearOptions` | 對應 legacy `RE_MAP` 與 select maps。 |
| `FinancialStatementFiSearchRequest` | `referenceApplicationNo` | 前案匯入查詢。 |
| `FinancialStatementFiCalculationRequest` | `balanceRows`、`incomeRows`、`cashflowRows` | 計算但不保存。 |
| `FinancialStatementFiCalculationResponse` | `balanceRows`、`incomeRows`、`cashflowRows` | 回填計算欄位。 |
| `FinancialStatementFiSaveRequest` | `applicationNo`、`main`、`balanceRows`、`incomeRows`、`cashflowRows`、`completionStatus`、`pageCheckContext` | 保存或完成。 |
| `FinancialStatementFiSaveResponse` | `tabs`、`allTabsChecked` | 父頁進度顯示所需資料。 |

## 13. 相容與修正策略

| 項目 | 建議 |
|---|---|
| 0119 `inti` | 新 API 命名採 `init`；若舊前端尚未完全替換，提供 `inti` alias。 |
| 0119 checkpoint key | 查詢與保存統一使用 `EPROC0_0119`；若 DB 已有錯誤 key 資料需另行資料盤點。 |
| Cashflow 勾稽 | 以 PM/SA 確認後的規則為準；若是「End Balance 應等於 Cash and Cash Equivalent」，則修正 legacy 反向判斷。 |
| 三表筆數一致 | 儲存前加 validation，錯誤時回傳明確訊息，不以 balance size 直接索引其他清單。 |
| 報表命名 | FI 功能報表檔名與 report ID 建議統一為 FI 命名；若共用 GI 範本需在程式與文件註明。 |
| 主鍵信任邊界 | 後端依 request `applicationNo` 覆寫所有明細 application no，並檢核資料屬於目前案件。 |

## 14. 手動驗證路徑

| 步驟 | 驗證內容 |
|---|---|
| 1 | 開啟 0119 頁面，以有資料與無資料 application no 各測一次 init/inti。 |
| 2 | 開啟 0219 頁面，以有資料與無資料 application no 各測一次 init。 |
| 3 | 使用 Search 匯入完整前案與不完整前案，確認畫面覆蓋、訊息與列印按鈕狀態。 |
| 4 | 輸入五期 Balance/Income/Cashflow，執行 Calculation，核對本文件第 7 章公式。 |
| 5 | 分別測 Save 與 Finished，確認 checkpoint value、下一頁 0120/0220 重設、父頁 done 狀態。 |
| 6 | 下載 Excel 與 PDF，確認檔案可開啟且內容對應本案資料。 |
| 7 | 進入 0120/0220，確認可讀取 0119/0219 保存的 FI Balance/Income 資料。 |

## 15. 完成標準

| ID | 標準 |
|---|---|
| DONE-001 | PRD 明確涵蓋 EPROC0_0119 與 EPROC0_0219 的初始化、前案匯入、計算、儲存、完成、列印與跨模組連動。 |
| DONE-002 | Source-confirmed、Cross-module confirmed、Legacy defect suspect、TBD 類型已明確標示。 |
| DONE-003 | Markdown 與 DOCX 均產出於指定 PRD 目錄，且封面包含「業務需求導向的功能規格書」與「台中資訊開發中心」。 |
| DONE-004 | DOCX 可作為 zip 開啟，`word/document.xml` 可被 XML parser 解析，且可搜尋到本功能關鍵文字。 |
| DONE-005 | 剩餘風險與需 PM/SA/RD/QA 確認的事項已列入第 0.2 與第 13 章。 |
