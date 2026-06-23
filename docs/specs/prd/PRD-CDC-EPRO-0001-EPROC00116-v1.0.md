台中資訊開發中心

業務需求導向的功能規格書

CDC-EPRO-EPROC00116 Financial Statement GI / 一般產業財務報表

版本：v1.0　更新日期：2026-06-15　文件狀態：Draft for PM/SA/RD/QA Review

文件目的：本文件依舊系統 `EPROC0_0116` 與 `EPROC0_0216` Source code 反推 E-Proposal `EPROC00116` 的業務需求、功能規則、介面契約、資料影響與驗收測試。內容以需求規格為主，技術識別碼保留以便 SA/RD 追溯。

主系統鏈路：E-Proposal / C0 授信分析流程 / GI 一般產業 / Financial Statement GI。一般案件由 `EPROC0_0110` 父頁載入 `EPROC0_0116`，續約/變更案件由 `EPROC0_0210` 父頁載入 `EPROC0_0216`。

強化重點：財務報表資料輸入、跨年度計算、參照案件帶入、儲存交易一致性、列印與 PDF 產出、checkpoint 與後續財務評估頁連動。

| 文件資訊 | 內容 |
| --- | --- |
| 文件代號 | `CDC-EPRO-EPROC00116_PRD_v1.0` |
| 功能代號 | `EPROC00116` |
| 舊系統程式 | `EPROC0_0116`, `EPROC0_0216` |
| 功能名稱 | Financial Statement GI / 一般產業財務報表 |
| 適用流程 | C0 授信分析 GI 流程 |
| 主要使用者 | 授信經辦、覆核/查詢角色 |
| 主要資料表 | `TB_FIN_STATEMENT_MAIN`, `TB_FIN_STATEMENT_BALANCE_GI`, `TB_FIN_STATEMENT_INCOME_GI`, `TB_FIN_STATEMENT_CASHFLOW_GI` |
| 文件來源 | 舊系統 transaction、module、JSP/JS、DAO、SQL、父頁與後續頁交互邏輯 |

## 文件 Review 資訊

| 角色 | Review 重點 | 狀態 |
| --- | --- | --- |
| PM | 業務流程、欄位定義、TBD 決策 | 待確認 |
| SA | 介面契約、資料模型、跨頁連動 | 待確認 |
| RD | 舊系統邏輯、交易一致性、匯出報表 | 待確認 |
| QA | 驗收條件、SIT/UAT 測試案例 | 待確認 |

## 版本紀錄

| 版本 | 日期 | 作者 | 異動說明 |
| --- | --- | --- | --- |
| v1.0 | 2026-06-15 | Codex / pm-prd-skill | 依 `EPROC0_0116` 與 `EPROC0_0216` 舊系統 source 產出初版 PRD |

## 名詞與證據分級

| 名詞 | 說明 |
| --- | --- |
| Source confirmed | 直接由本功能 transaction、module、JSP/JS、DAO、SQL 觀察到的行為 |
| Cross-module confirmed | 由父頁或後續頁觀察到的跨功能連動 |
| Inferred | 由多個 source 點推論，仍需業務確認 |
| TBD | source 無法完整判定或需 PM/SA 決策 |
| Legacy defect suspect | 舊系統可疑或不一致行為，本 PRD 記錄為 review item，不直接修正 |

## TBD / Review Items

| ID | 類型 | 說明 | 建議決策 |
| --- | --- | --- | --- |
| TBD-001 | TBD | 參照案件查詢條件使用 `APP_CON_TYPE` 空白與 `CASE_PROGRESS in 08,09,14` 判斷；狀態碼與合約類型的正式業務名稱未在本功能 source 內定義。 | PM/SA 補充狀態碼與合約類型業務定義。 |
| TBD-002 | Legacy defect suspect | 初始化 action 名稱為 `inti`，疑似拼字錯誤但為既有前後端契約。 | 新系統若需相容舊前端或轉換測試，保留對應或建立 adapter。 |
| TBD-003 | Legacy defect suspect | 參照案件無資料時使用 message key `COMMOM_MSG_NO_DATA`，疑似拼字錯誤。 | 新系統可維持對應 key 或轉成標準錯誤碼，需 SA 決策。 |
| TBD-004 | Legacy defect suspect | GI JS 計算驗證使用 `EPROI00119_MSG_VALIDATE_004`，此 key 名稱看似 FI 模組。 | 確認訊息內容是否仍為 GI 適用。 |
| TBD-005 | TBD | Save 前端驗證列出 `BALANCE_DATE_0` 至 `BALANCE_DATE_4`，但組 payload 時會跳過空白日期欄位。 | 確認是否要求完整五年資料，或只要求至少一年度。 |
| TBD-006 | Legacy defect suspect | DB/source 欄位保留拼字：`IMCOME_DATE`, `IMPAIMENT_LOSS`, `SHARDHOLDERS_LOAN`, `AP_RELATED_PARITIES`。 | 新系統資料模型若改名，需定義 migration mapping。 |
| TBD-007 | TBD | `HIGHLIGHT` 以 pipe 字元串接五段文字，未看到 delimiter escaping 規則。 | 若新系統改為結構化欄位，需定義舊資料拆分策略。 |
| TBD-008 | Legacy defect suspect | PDF 報表代號同時使用 `EPRO_C00116_GI` 與 `EPRO_I00116_GI_*`。 | 確認報表模板命名與 ownership。 |

## 1. 需求概述

### 1.1 需求背景

`EPROC00116` 是 C0 授信分析 GI 一般產業流程中的財務報表資料頁，負責蒐集企業財務報表主檔、資產負債表、損益表、現金流量表與財務重點說明。舊系統依案件流程分成兩組程式：

| 流程 | 父頁 | 本頁 transaction | 本頁 JSP | 後續頁 |
| --- | --- | --- | --- | --- |
| 一般案件 | `EPROC0_0110` | `EPROC0_0116` | `EPROC00116.jsp` / `EPROC00116_JS.jsp` | `EPROC0_0117` Financial Evaluation GI |
| 續約/變更案件 | `EPROC0_0210` | `EPROC0_0216` | `EPROC00216.jsp` / `EPROC00216_JS.jsp` | `EPROC0_0217` Financial Evaluation GI |

兩組程式的業務行為與資料表相同，差異在於父流程、權限輸出、checkpoint table 與下一頁 checkpoint 欄位。

### 1.2 需求目標

- 提供 GI 一般產業財務報表輸入與查詢畫面。
- 支援從參照案件帶入既有 GI 財務資料，供使用者複製後再儲存至目前案件。
- 支援前端與後端共同計算財務科目合計、差額與現金流量衍生欄位。
- 儲存主檔與三張明細表，並同步更新頁籤完成狀態與下一頁 checkpoint。
- 支援 Excel 下載與 PDF 列印，供授信審查與留存。
- 作為後續 `EPROC0_0117` / `EPROC0_0217` Financial Evaluation GI 的資料來源。

### 1.3 需求範圍

| 範圍 | 內容 | 證據 |
| --- | --- | --- |
| 畫面初始化 | 載入 currency、unit、year options 與既有財務資料 | Source confirmed |
| 參照案件查詢 | 以 Reference Application No. 查詢另一案件財務資料 | Source confirmed |
| 財報輸入 | 主檔欄位、criteria、audited FS 問題、公司名稱、幣別、單位 | Source confirmed |
| 三大報表 | Balance Sheet、Income Statement、Cashflow Statement，最多五年度欄位 | Source confirmed |
| 財務重點 | Loan Repayment Basis、Financial Situation、Business Risk、Borrower Risk、Summary | Source confirmed |
| 計算 | 資產負債、損益、現金流量公式 | Source confirmed |
| 儲存 | delete-and-upsert 主檔與 GI 明細，更新 checkpoint | Source confirmed |
| 匯出列印 | Excel `GIyyyyMMdd.xls` 與 PDF 報表 | Source confirmed |
| 後續頁連動 | 後續 Financial Evaluation GI 讀取本頁 GI 明細 | Cross-module confirmed |

### 1.4 不在本次範圍

- FI 金融產業財務報表 `EPROC0_0119` / `EPROC0_0219`。
- Financial Evaluation GI `EPROC0_0117` / `EPROC0_0217` 的評分與比率計算細節。
- 父頁 `EPROC0_0110` / `EPROC0_0210` 的完整授信分析流程規格。
- 報表模板本身版型設計與 Jasper/iText 報表樣板維護。
- code table 顯示名稱的最終中文翻譯，除非 source 已明確提供。

### 1.5 來源掃描摘要

| 類別 | Source path | 用途 |
| --- | --- | --- |
| Transaction | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0116.java` | 一般案件 AJAX actions、錯誤處理、輸出資料 |
| Transaction | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0216.java` | 續約/變更案件 AJAX actions、錯誤處理、輸出資料 |
| Module | `EPROWeb/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0116_mod.java` | 查詢、參照查詢、計算、儲存、匯出、PDF |
| Module | `EPROWeb/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0216_mod.java` | 續約/變更案件同構邏輯與 RC checkpoint |
| JSP/JS | `EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00116.jsp` | 一般案件畫面欄位 |
| JSP/JS | `EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00116_JS.jsp` | 一般案件前端初始化、驗證、payload |
| JSP/JS | `EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00216.jsp` | 續約/變更案件畫面欄位 |
| JSP/JS | `EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00216_JS.jsp` | 續約/變更案件前端初始化、驗證、payload |
| DAO | `EPRO_TB_FIN_STATEMENT_MAIN.java` | 財務報表主檔欄位 |
| DAO | `EPRO_TB_FIN_STATEMENT_BALANCE_GI.java` | GI 資產負債表欄位 |
| DAO | `EPRO_TB_FIN_STATEMENT_INCOME_GI.java` | GI 損益表欄位 |
| DAO | `EPRO_TB_FIN_STATEMENT_CASHFLOW_GI.java` | GI 現金流量表欄位 |
| Cross-module | `EPROC0_0110_mod.java`, `EPROC0_0210_mod.java` | GI/FI business type 切換與頁籤 checkpoint |
| Cross-module | `EPROC0_0117_mod.java`, `EPROC0_0217_mod.java` | 後續 Financial Evaluation GI 讀取本頁資料 |

## 2. 業務流程

### 2.1 End-to-End 流程

| 步驟 | 使用者/系統動作 | 系統行為 |
| --- | --- | --- |
| 1 | 使用者進入授信分析 GI 流程 | 父頁依 `BUSINESS_TYPE = G` 載入本頁與後續 GI 頁籤 |
| 2 | 本頁初始化 | 後端執行 `inti` action，載入選單與目前案件已儲存資料 |
| 3 | 使用者輸入或參照案件帶入 | 前端填入主檔、Balance、Income、Cashflow 與 highlight |
| 4 | 使用者執行 Calculation | 後端回傳衍生計算欄位，前端驗證差額與期末現金 |
| 5 | 使用者 Save 或 Finished | 系統驗證必要欄位，儲存主檔與明細，更新 checkpoint |
| 6 | 儲存完成後列印/匯出 | 若已有完整資料，顯示 Excel 下載與 PDF 列印 |
| 7 | 使用者進入下一頁 | 後續 Financial Evaluation GI 讀取本頁 GI 明細作為分析來源 |

### 2.2 使用者流程

| 情境 | 前置條件 | 操作 | 預期結果 |
| --- | --- | --- | --- |
| 新增/編輯本案財報 | 使用者具備 `EPROC0_0116` 或 `EPROC0_0216` 編輯權限 | 輸入公司、幣別、五年財務資料、重點說明後儲存 | 寫入本案財報資料並更新 checkpoint |
| 從參照案件帶入 | 畫面顯示 reference application 區塊 | 輸入參照案號並查詢 | 畫面帶入參照案件財報資料，但需另行儲存才會寫入本案 |
| 查詢模式 | `attrMap.isQuery` 或非 editor | 檢視畫面 | 欄位 disabled，Save/Calculation 不可操作 |
| 匯出 Excel | 本案已存在主檔與三張明細 | 點選 Print/Excel | 下載 `GIyyyyMMdd.xls` |
| 列印 PDF | 本案已存在主檔與三張明細 | 點選 Print PDF | 產出加密暫存路徑供列印 |

### 2.3 狀態與頁籤流程

| 流程 | 本頁 checkpoint | 下一頁 checkpoint | checkpoint table |
| --- | --- | --- | --- |
| `EPROC0_0116` CS 分支 | `TB_CHECK_POINT_CORP.EPROC0_0116` | `TB_CHECK_POINT_CORP.EPROC0_0117 = Y` | `TB_CHECK_POINT_CORP` |
| `EPROC0_0116` 非 CS 分支 | `TB_CHECK_POINT_CU.EPROC0_0116` | `TB_CHECK_POINT_CU.EPROC0_0117 = Y` | `TB_CHECK_POINT_CU` |
| `EPROC0_0216` CS 分支 | `TB_CHECK_POINT_RC_CORP.EPROC0_0216` | `TB_CHECK_POINT_RC_CORP.EPROC0_0217 = Y` | `TB_CHECK_POINT_RC_CORP` |
| `EPROC0_0216` 非 CS 分支 | `TB_CHECK_POINT_RC_CU.EPROC0_0216` | `TB_CHECK_POINT_RC_CU.EPROC0_0217 = Y` | `TB_CHECK_POINT_RC_CU` |

Cross-module confirmed：父頁在 `BUSINESS_TYPE = G` 時顯示 GI 路徑，且 `changePage` 會刪除 GI/FI 財報資料並重設 GI 或 FI 相關 checkpoint。本 PRD 僅列入本頁被影響的 GI checkpoint 與資料表。

### 2.4 權限與顯示

| 規則 | 說明 | 證據 |
| --- | --- | --- |
| 編輯權限 | 父頁輸出 `isEditor116` 或 `isEditor216` 控制本頁是否可編輯 | Source confirmed |
| 查詢模式 | `attrMap.isQuery` 時本頁欄位 disabled，Save 與 Calculation 隱藏 | Source confirmed |
| 參照案件區塊 | 僅在 editor 且 `isShow` 時顯示 Reference Application No. 查詢 | Source confirmed |
| 列印按鈕 | 初始化若 `haveData = Y` 顯示，資料異動或計算前隱藏 | Source confirmed |

## 3. 需求與來源矩陣

| Requirement ID | 功能名稱 | 證據分級 | Source mapping | 說明 |
| --- | --- | --- | --- | --- |
| FR-001 | 畫面初始化與資料查詢 | Source confirmed | `doInit` / `querySel` / `query` | 載入選單、主檔、GI 明細與 checkpoint |
| FR-002 | 參照案件查詢與帶入 | Source confirmed | `search` action / `mod.search` | 以參照案號查詢可複製的 GI 財報 |
| FR-003 | 主檔與問題欄位維護 | Source confirmed | JSP main section / `TB_FIN_STATEMENT_MAIN` | 維護公司、幣別、單位、criteria、audited FS 與 highlight |
| FR-004 | Balance Sheet 輸入 | Source confirmed | JSP balance table / BALANCE DAO | 維護每年度資產、負債、權益與合計 |
| FR-005 | Income Statement 輸入 | Source confirmed | JSP income table / INCOME DAO | 維護每年度營收、費用、損益與合計 |
| FR-006 | Cashflow Statement 輸入 | Source confirmed | JSP cashflow table / CASHFLOW DAO | 維護每年度現金流量與期初/期末餘額 |
| FR-007 | 財務計算 | Source confirmed | `calculationBalanceList`, `calculationIncomePar`, `calculationCashflowPar` | 計算合計、差額、損益與現金流衍生欄位 |
| FR-008 | 儲存與 checkpoint 更新 | Source confirmed | `save` action / `mod.save` | Upsert 主檔、刪除重建明細、更新本頁與下一頁狀態 |
| FR-009 | Excel 匯出 | Source confirmed | `print` action / `export` | 產出 GI Excel 檔含三個 sheet |
| FR-010 | PDF 列印 | Source confirmed | `printPDF` action / `exportPDF` | 產出 PDF 暫存檔並回傳加密路徑 |
| FR-011 | 後續頁資料供應 | Cross-module confirmed | `EPROC0_0117_mod`, `EPROC0_0217_mod` | Financial Evaluation GI 讀取本頁 GI 明細 |

### 3.1 來源方法對照

| 程式 | Method/action | 需求意義 |
| --- | --- | --- |
| `EPROC0_0116.java`, `EPROC0_0216.java` | `@CallMethod(action = "inti")` | 初始化選單、資料、checkpoint |
| `EPROC0_0116.java`, `EPROC0_0216.java` | `search` | 參照案件資料查詢 |
| `EPROC0_0116.java`, `EPROC0_0216.java` | `calculation` | 後端計算報表衍生值 |
| `EPROC0_0116.java`, `EPROC0_0216.java` | `save` | 儲存主檔、明細與 checkpoint |
| `EPROC0_0116.java`, `EPROC0_0216.java` | `print` | Excel 下載 |
| `EPROC0_0116.java`, `EPROC0_0216.java` | `printPDF` | PDF 產出與加密暫存路徑 |
| `EPROC0_0116_mod.java`, `EPROC0_0216_mod.java` | `querySel` | 查詢 `CCY`, `CCY_UNIT`, `TYPE_OF_YEAR` options |
| `EPROC0_0116_mod.java`, `EPROC0_0216_mod.java` | `query` | 查詢目前案件財報 |
| `EPROC0_0116_mod.java`, `EPROC0_0216_mod.java` | `save` | DB transaction、delete-and-upsert |

## 4. 功能需求

### 4.1 FR-001 畫面初始化與目前案件查詢

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-001 |
| 功能名稱 | 畫面初始化與目前案件查詢 |
| 需求說明 | 使用者進入本頁時，系統需載入選單、目前案件財報資料、明細資料與 checkpoint 狀態。 |
| Trigger | 前端呼叫 `inti` action |
| Actor | 授信經辦、查詢角色 |
| Evidence | Source confirmed |

功能規則：

- 系統需依目前 `APPLICATION_NO` 查詢 `TB_FIN_STATEMENT_MAIN`。
- 系統需查詢 `TB_FIN_STATEMENT_BALANCE_GI`、`TB_FIN_STATEMENT_INCOME_GI`、`TB_FIN_STATEMENT_CASHFLOW_GI` 三組明細。
- 當三組明細皆存在時，回傳 `haveData = Y`；任一明細不存在時，回傳 `haveData = N`。
- 系統需依 `LON_ATTRIBUTE + SECURE_ATTRIBUTE` 判斷是否為 `CS`，並讀取對應 checkpoint table。
- 系統需回傳下列選單：`SEL_CURRENCY`, `SEL_UNIT`, `SEL_TYPE_YEAR`。

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR001-01 | 案件已有主檔與三張 GI 明細 | 開啟本頁 | 畫面帶入既有資料，Print/PDF 可顯示 |
| AC-FR001-02 | 案件缺少任一 GI 明細 | 開啟本頁 | 畫面仍可載入，但 `haveData = N` 並隱藏 Print/PDF |
| AC-FR001-03 | 使用者為查詢模式 | 開啟本頁 | 欄位 disabled，Save 與 Calculation 不可操作 |

### 4.2 FR-002 參照案件查詢與帶入

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-002 |
| 功能名稱 | 參照案件查詢與帶入 |
| 需求說明 | 使用者可輸入 Reference Application No. 查詢另一案件的 GI 財務資料，帶入畫面後再儲存至目前案件。 |
| Trigger | 前端呼叫 `search` action |
| Actor | 授信經辦 |
| Evidence | Source confirmed |

功能規則：

- 前端以 `reApplication` 傳送參照案號。
- 後端需查詢參照案件 `TB_LON_SUMMARY_INFO` 的 `CASE_PROGRESS` 與 `APP_CON_TYPE`。
- 若 `APP_CON_TYPE` 為空且 `CASE_PROGRESS` 不屬於 `08`, `09`, `14`，舊系統視為不可帶入並拋出無資料錯誤。
- 參照案件需同時存在主檔、Balance GI、Income GI、Cashflow GI；任一不存在即回傳無資料錯誤。
- 參照查詢只帶入畫面資料，不得直接改寫目前案件；使用者仍須執行 Save。
- 參照查詢成功後，前端會清空目前畫面欄位再填入參照資料，並隱藏 Print/PDF、啟用 Calculation。

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR002-01 | 參照案件符合條件且財報完整 | 查詢參照案號 | 畫面帶入參照案件資料 |
| AC-FR002-02 | 參照案件缺少主檔或任一明細 | 查詢參照案號 | 系統回傳「請輸入有效 Application No.」類型錯誤 |
| AC-FR002-03 | 查詢成功但未 Save | 離開本頁 | 目前案件資料不應被改寫 |

### 4.3 FR-003 主檔與問題欄位維護

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-003 |
| 功能名稱 | 主檔與問題欄位維護 |
| 需求說明 | 系統需維護本案 GI 財報主檔資料，包含 criteria、audited FS 問題、公司名稱、幣別、單位與財務重點說明。 |
| Trigger | 使用者輸入主檔欄位並 Save |
| Actor | 授信經辦 |
| Evidence | Source confirmed |

主檔欄位：

| 欄位 | 說明 | 規則 |
| --- | --- | --- |
| `APPLICATION_NO` | 案件編號 | 由父頁帶入，不可由使用者任意改動 |
| `CRITERIA_1` / `CRITERIA_2` / `CRITERIA_3` | Criteria checkbox | 前端轉為 `Y` / `N` |
| `DOES_NEED_AUDITED_FS` | Does the company need to have financial statements audited? | Finished 時需選擇 |
| `HAVE_PROVIDED_AUDITED_FS` | Have the company provided audited financial statements to our bank? | Finished 時需選擇 |
| `AUDIT_FIRM` | Audit Firm | 最長 50 |
| `OPINION_MEMO` | Opinion Memo | 最長 500 |
| `COMPANY_NAME` | Company Name | Finished 時必填 |
| `CURRENCY` | Currency | Save 必填，選項來自 `CCY` |
| `CCY_UNIT` | Currency Unit | Finished 時必填，選項來自 `CCY_UNIT` |
| `HIGHLIGHT` | Financial Highlight | 五段文字以 pipe 字元串接，單段 textarea 最長 6000 |

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR003-01 | 使用者勾選 criteria | Save | DB 欄位寫入 `Y`，未勾選寫入 `N` |
| AC-FR003-02 | 未輸入 `CURRENCY` | Save | 系統阻擋並回傳幣別不可空白類錯誤 |
| AC-FR003-03 | Finished 時未選 audited FS 問題 | Finished | 前端阻擋送出 |

### 4.4 FR-004 Balance Sheet 輸入與計算

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-004 |
| 功能名稱 | Balance Sheet 輸入與計算 |
| 需求說明 | 系統需提供最多五年度 Balance Sheet 欄位，並計算資產、負債、權益與差額。 |
| Trigger | 使用者輸入 Balance Sheet 並執行 Calculation |
| Actor | 授信經辦 |
| Evidence | Source confirmed |

主要計算規則：

| 衍生欄位 | 公式 |
| --- | --- |
| `TOTAL_CUR_ASSETS` | `CASH_EQUIVALENT + SECUR_OTHER_FINCL_ASSETS + AR_RELATED_PARTIES + AR_NON_RELATED_PARTIES + OTHER_RECEIVABLES + LOANS_TO_OTHERS + INVENTORIES + PREPAYMENTS + OTH_CUR_ASSETS` |
| `NET_FIXED_ASSETS` | `LAND + BUILDING + EQUIPMENT + OTH_FIXED_ASSETS - DEPRECIATION_AMORTIZATION` |
| `NON_CUR_ASSETS` | `NET_FIXED_ASSETS + INTANGLIBLE_ASSET + FUNDS_INVESTMENT + OTH_NON_CUR_ASSETS` |
| `TOTAL_ASSETS` | `TOTAL_CUR_ASSETS + NON_CUR_ASSETS` |
| `CUR_LIABILITIES` | `ST_BORROWINGS + BILLS_PAYABLE + FINANCIAL_LIABILITIES + AP_RELATED_PARITIES + AP_NON_RELATED_PARTIES + TAX_PAYABLE + OTH_PAYABLE + OTH_PAYABLE_FEES + PRE_RECEIVE_PAYMENTS + CPLTD + OTH_CUR_LIABILITIES` |
| `NON_CUR_LIABILITIES` | `LT_BORROWINGS + BONDS_PAYABLE + SHARDHOLDERS_LOAN + OTH_NON_CUR_LIABILITIES` |
| `TOTAL_EQUITY` | `PAID_UP_CAPITAL + RESERVES + RETAINED_EARNINGS + MINORITY_INTEREST_EQUITY + OTH_ADJUSTMENTS` |
| `TOTAL_LIAB_EQUITY` | `CUR_LIABILITIES + NON_CUR_LIABILITIES + TOTAL_EQUITY` |
| `DIFFERENCE` | `TOTAL_ASSETS - TOTAL_LIAB_EQUITY` |

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR004-01 | 使用者輸入年度資產與負債明細 | Calculation | 系統回填 Balance Sheet 衍生欄位 |
| AC-FR004-02 | 某年度 `DIFFERENCE` 不為 0 | Finished | 前端阻擋完成 |
| AC-FR004-03 | 第一年度總資產與負債權益皆為 0 | Calculation/Finished | 前端阻擋或顯示驗證錯誤 |

### 4.5 FR-005 Income Statement 輸入與計算

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-005 |
| 功能名稱 | Income Statement 輸入與計算 |
| 需求說明 | 系統需提供最多五年度 Income Statement 欄位，並計算毛利、營業利益、稅前利益、本期利益與歸屬母公司利益。 |
| Trigger | 使用者輸入 Income Statement 並執行 Calculation |
| Actor | 授信經辦 |
| Evidence | Source confirmed |

主要計算規則：

| 衍生欄位 | 公式 |
| --- | --- |
| `GROSS_PROFIT` | `REVENUES - COST_OF_GOOD_SOLD` |
| `OPERATING_EXPENSES` | `SALARY + COMMISSION + MARKETING_EXPENSE + TRANSPORTATION + UTILITIES` |
| `OPERATING_PROFIT` | `GROSS_PROFIT - OPERATING_EXPENSES` |
| `NON_OPERATING_INCOME` | `INTEREST_INCOME + INVESTMENT_INCOME + INTEREST_DISPOSAL_FA + INTEREST_DISPOSAL_INVEST + FX_GAIN + RENTAL_INCOME + REVERSALS + FINANCE_ASSETS_EVALUATION + DEBT_EVALUATION + OTH_EVALUATION + OTH_NON_OP_INCOME` |
| `NON_OPERATING_EXPENSES` | `FINANCE_COST_INT_EXP + INVESTMENT_LOSS + LOSS_DISPOSAL_FA + LOSS_DISPOSAL_INVESTMENT + FX_LOSS + IMPAIMENT_LOSS + LOSS_ON_FIN_ASSETS_EVALUATION + LOSS_ON_OTH_EVALUATION + OTH_NON_OP_EXPENSE` |
| `PROFIT_BEFORE_TAX` | `OPERATING_PROFIT + NON_OPERATING_INCOME - NON_OPERATING_EXPENSES` |
| `CUR_PERIOD_PROFIT` | `PROFIT_BEFORE_TAX - TAX_AND_OTH` |
| `ATTRIBUTED_TO_PARENT_COMP` | `CUR_PERIOD_PROFIT - MINORITY_INTERESTS` |

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR005-01 | 使用者輸入收入與費用明細 | Calculation | 系統回填損益衍生欄位 |
| AC-FR005-02 | 修改金額欄位 | 畫面偵測變更 | Calculation 重新啟用，Print/PDF 隱藏 |

### 4.6 FR-006 Cashflow Statement 輸入與計算

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-006 |
| 功能名稱 | Cashflow Statement 輸入與計算 |
| 需求說明 | 系統需提供最多五年度 Cashflow Statement 欄位，並以 Balance/Income 資料推算現金流量欄位。 |
| Trigger | 使用者輸入相關欄位並執行 Calculation |
| Actor | 授信經辦 |
| Evidence | Source confirmed |

主要計算規則：

| 欄位 | 規則 |
| --- | --- |
| 第一年度 | 前端開放 `OPERATING_NET_CASHFLOW_0`, `INVESTING_NET_CASHFLOW_0`, `FINANCING_NET_CASHFLOW_0`, `NET_I_D_IN_CASH_0`, `OPENING_BALANCE_0` 輸入 |
| `OPENING_BALANCE_i` | i 大於 0 時等於上一年度 `END_BALANCE_(i-1)` |
| `NET_I_D_IN_CASH_i` | i 大於 0 時等於本年度 `CASH_EQUIVALENT_i - CASH_EQUIVALENT_(i-1)` |
| `FINANCING_NET_CASHFLOW` | 本年度融資相關 balance 欄位變動合計，扣除本年度 `CUR_PERIOD_PROFIT` |
| `INVESTING_NET_CASHFLOW` | 固定資產、非流動投資相關欄位變動與投資處分/損益欄位組合計算 |
| `OPERATING_NET_CASHFLOW` | `NET_I_D_IN_CASH - FINANCING_NET_CASHFLOW - INVESTING_NET_CASHFLOW` |
| `END_BALANCE` | `NET_I_D_IN_CASH + OPENING_BALANCE` |

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR006-01 | 使用者輸入至少兩年度資料 | Calculation | 第二年度起期初餘額等於上一年度期末餘額 |
| AC-FR006-02 | 某年度 `END_BALANCE` 不等於 Balance Sheet `CASH_EQUIVALENT` | Finished | 前端阻擋完成 |

### 4.7 FR-007 財務重點說明

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-007 |
| 功能名稱 | Financial Highlight |
| 需求說明 | 系統需提供五段財務重點說明，供授信經辦記錄還款來源、財務狀況、營運風險、借款人風險與總結。 |
| Trigger | 使用者輸入 highlight 後 Save |
| Actor | 授信經辦 |
| Evidence | Source confirmed |

| 序號 | 欄位標題 | DB 儲存方式 |
| --- | --- | --- |
| 1 | Loan Repayment Basis | `HIGHLIGHT` 第 1 段 |
| 2 | Financial Situation | `HIGHLIGHT` 第 2 段 |
| 3 | Business Risk | `HIGHLIGHT` 第 3 段 |
| 4 | Borrower Risk | `HIGHLIGHT` 第 4 段 |
| 5 | Summary | `HIGHLIGHT` 第 5 段 |

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR007-01 | 使用者輸入五段 highlight | Save | 系統以 legacy delimiter 串接寫入主檔 |
| AC-FR007-02 | 重新開啟既有案件 | 初始化 | 系統拆分 `HIGHLIGHT` 並回填五段 textarea |

### 4.8 FR-008 儲存與 checkpoint 更新

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-008 |
| 功能名稱 | 儲存與 checkpoint 更新 |
| 需求說明 | 系統需以交易方式儲存財報主檔與三張 GI 明細，並更新本頁與下一頁 checkpoint。 |
| Trigger | 使用者按 Save 或 Finished |
| Actor | 授信經辦 |
| Evidence | Source confirmed |

儲存規則：

- 後端需驗證 request map 不可為空。
- `APPLICATION_NO` 不可空白。
- `CURRENCY` 不可空白。
- 主檔採 update-first；update count 為 0 時 insert。
- 明細表採先依 `APPLICATION_NO` 刪除，再逐年度 update/insert。
- 後端以 `balancePar.size()` 控制寫入年度筆數，對應 income 與 cashflow 同 index 資料。
- 若 `BALANCE_DATE` 不含 `/`，後端會將 `ddMMyyyy` 轉為 `dd/MM/yyyy`，並同步設定 `IMCOME_DATE`、`CASHFLOW_DATE`。
- 儲存後查回主檔與三張明細皆存在時，回傳 `result = Y`。
- 不論本頁 checkbox 值為何，後端皆會將下一頁 checkpoint 設為 `Y`。

資料影響：

| Table | 操作 | 條件 |
| --- | --- | --- |
| `TB_FIN_STATEMENT_MAIN` | update 或 insert | `APPLICATION_NO` |
| `TB_FIN_STATEMENT_BALANCE_GI` | delete by application，再逐筆 update/insert | `APPLICATION_NO`, `DATA_SEQ` |
| `TB_FIN_STATEMENT_INCOME_GI` | delete by application，再逐筆 update/insert | `APPLICATION_NO`, `DATA_SEQ` |
| `TB_FIN_STATEMENT_CASHFLOW_GI` | delete by application，再逐筆 update/insert | `APPLICATION_NO`, `DATA_SEQ` |
| checkpoint tables | update | 依流程與 `CS` 判斷 table |

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR008-01 | 使用者填妥必要資料 | Save | 主檔與三張明細寫入同一交易，回傳 `result = Y` |
| AC-FR008-02 | 儲存任一 DB 操作失敗 | Save | 交易 rollback，不留下部分寫入資料 |
| AC-FR008-03 | `EPROC0_0116` 儲存成功 | Save | 更新本頁 checkpoint 並將 `EPROC0_0117` 設為 `Y` |
| AC-FR008-04 | `EPROC0_0216` 儲存成功 | Save | 更新本頁 checkpoint 並將 `EPROC0_0217` 設為 `Y` |

### 4.9 FR-009 Excel 匯出

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-009 |
| 功能名稱 | Excel 匯出 |
| 需求說明 | 系統需依目前案件資料產出 GI 財務報表 Excel。 |
| Trigger | 使用者點選 Print/Excel |
| Actor | 授信經辦、查詢角色 |
| Evidence | Source confirmed |

匯出規則：

- 前端呼叫 `print` action 並傳入 `APPLICATION_NO`。
- 若 `APPLICATION_NO` 空白，回傳案件錯誤。
- 後端產生檔名 `GIyyyyMMdd.xls`。
- Excel sheet 包含 `Balance Sheet`、`Income Statement`、`Cashflow Statement`。
- 後端使用 `RptUtils.cryptoDownloadParameterToResp` 回傳下載資訊。

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR009-01 | 案件已有完整 GI 財報 | 點選 Print | 下載 Excel，且三個 sheet 皆存在 |
| AC-FR009-02 | 案號空白 | 點選 Print | 系統回傳案件錯誤，不產生檔案 |

### 4.10 FR-010 PDF 列印

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-010 |
| 功能名稱 | PDF 列印 |
| 需求說明 | 系統需依目前案件資料產出 PDF，並回傳加密暫存路徑供前端列印。 |
| Trigger | 使用者點選 Print PDF |
| Actor | 授信經辦、查詢角色 |
| Evidence | Source confirmed |

PDF 規則：

- 前端呼叫 `printPDF` action 並傳入 `APPLICATION_NO`。
- 後端呼叫 `exportPDF(APPLICATION_NO)` 產出 PDF 暫存檔。
- 回應欄位為 `encryptTempFileFullPath`。
- PDF 幣別單位顯示規則：`CCY_UNIT = 1` 顯示 dollar；`2` 顯示 thousands；其他顯示 millions。
- PDF 使用 report IDs：`EPRO_C00116_GI`, `EPRO_C00116_GI_1`, `EPRO_I00116_GI_1`, `EPRO_I00116_GI_2`, `EPRO_I00116_GI_3`。

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR010-01 | 案件已有完整 GI 財報 | 點選 Print PDF | 回傳 `encryptTempFileFullPath` |
| AC-FR010-02 | PDF 產出失敗 | 點選 Print PDF | 系統回傳 download fail 類型訊息 |

### 4.11 FR-011 後續 Financial Evaluation GI 資料供應

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-011 |
| 功能名稱 | 後續頁資料供應 |
| 需求說明 | 本頁儲存的 GI 財報資料需供後續 Financial Evaluation GI 頁籤讀取與分析。 |
| Trigger | 使用者進入 `EPROC0_0117` 或 `EPROC0_0217` |
| Actor | 授信經辦 |
| Evidence | Cross-module confirmed |

跨頁規則：

- `EPROC0_0117_mod` / `EPROC0_0217_mod` 在非 query mode 讀取 `TB_FIN_STATEMENT_BALANCE_GI`、`TB_FIN_STATEMENT_INCOME_GI`、`TB_FIN_STATEMENT_CASHFLOW_GI`。
- 若三組 GI 明細任一為 null，後續頁回傳 empty list。
- 因此本頁儲存完整性會直接影響後續 Financial Evaluation GI 是否可計算。

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR011-01 | 本頁已儲存完整三張 GI 明細 | 進入後續頁 | 後續頁可讀取 GI 明細 |
| AC-FR011-02 | 本頁缺少任一 GI 明細 | 進入後續頁 | 後續頁取得 empty list 或無可計算資料 |

## 5. API / Interface 規格

### 5.1 API 總覽

| Action | Method | Request | Response | 說明 |
| --- | --- | --- | --- | --- |
| `inti` | AJAX | `APPLICATION_NO` | `RE_MAP`, `SEL_CURRENCY`, `SEL_UNIT`, `SEL_TYPE_YEAR` | 初始化 |
| `search` | AJAX | `reApplication` | `reMap` | 查詢參照案件 |
| `calculation` | AJAX | `balancePar2`, `incomePar`, `cashflowPar` | `RE_LIST` | 計算衍生欄位 |
| `save` | AJAX | `main`, `balancePar`, `incomePar`, `cashflowPar`, `checkPoint`, `pageCheckMap` | `result`, `isAllTabsCheck` | 儲存 |
| `print` | AJAX/download | `APPLICATION_NO` | encrypted download response | Excel 匯出 |
| `printPDF` | AJAX | `APPLICATION_NO` | `encryptTempFileFullPath` | PDF 列印 |

### 5.2 Common Request Context

| 欄位 | 說明 |
| --- | --- |
| `APPLICATION_NO` | 目前案件編號，由父頁 JSP context 帶入 |
| UserObject | 後端由 session 取得，用於儲存 audit/update user |
| `role` / editor flags | 父頁判斷 `isEditor116` 或 `isEditor216` |
| `attrMap.isQuery` | 查詢模式控制畫面唯讀 |

### 5.3 `inti` Request / Response

| 類型 | 欄位 | 說明 |
| --- | --- | --- |
| Request | `APPLICATION_NO` | 目前案件編號 |
| Response | `RE_MAP.main` | `TB_FIN_STATEMENT_MAIN` |
| Response | `RE_MAP.balance` | `TB_FIN_STATEMENT_BALANCE_GI` list |
| Response | `RE_MAP.income` | `TB_FIN_STATEMENT_INCOME_GI` list |
| Response | `RE_MAP.cashFlow` | `TB_FIN_STATEMENT_CASHFLOW_GI` list |
| Response | `RE_MAP.check` | 本頁 checkpoint 值 |
| Response | `RE_MAP.haveData` | 是否有完整三張明細 |
| Response | `SEL_CURRENCY` | `CCY` options |
| Response | `SEL_UNIT` | `CCY_UNIT` options |
| Response | `SEL_TYPE_YEAR` | `TYPE_OF_YEAR` options |

### 5.4 `search` Request / Response

| 類型 | 欄位 | 說明 |
| --- | --- | --- |
| Request | `reApplication` | Reference Application No. |
| Response | `reMap.main` | 參照案件主檔 |
| Response | `reMap.balance` | 參照案件 Balance GI |
| Response | `reMap.income` | 參照案件 Income GI |
| Response | `reMap.cashFlow` | 參照案件 Cashflow GI |

### 5.5 `calculation` Request / Response

| 類型 | 欄位 | 說明 |
| --- | --- | --- |
| Request | `balancePar2` | 前端收集的 Balance Sheet list |
| Request | `incomePar` | 前端收集的 Income Statement list |
| Request | `cashflowPar` | 前端收集的 Cashflow Statement list |
| Response | `RE_LIST` | 每年度計算結果 map list |

### 5.6 `save` Request / Response

| 類型 | 欄位 | 說明 |
| --- | --- | --- |
| Request | `main` | JSON object，主檔欄位 |
| Request | `balancePar` | JSON array，Balance GI list |
| Request | `incomePar` | JSON array，Income GI list |
| Request | `cashflowPar` | JSON array，Cashflow GI list |
| Request | `checkPoint` | JSON object，含 `APPLICATION_NO` 與本頁 checkpoint |
| Request | `pageCheckMap` | 父頁頁籤狀態 map |
| Response | `result` | `Y` 表示儲存後查回完整資料 |
| Response | `isAllTabsCheck` | 父頁完成狀態判斷 |

### 5.7 Error Response

| Action | 條件 | 舊系統訊息 key / 類型 |
| --- | --- | --- |
| `inti` | 查無資料 | `MSG_DATA_NOT_FOUND` |
| `inti` | over count | `MSG_OVER_COUNT_LIMIT` |
| `inti` | module/general error | `MSG_QUERY_FAIL` |
| `search` | 無效參照案號或資料不完整 | `MSG_ERROR_APPLICATION_NO` |
| `calculation` | module/root exception | `COMMON_MSG_TOTAL_FAIL` |
| `print` | 案號空白 | `COMMON_MSG_ERROR_LON` |
| `print` | 匯出失敗 | `COMMON_MSG_PRINT_FAIL` |
| `printPDF` | 下載成功 | `COMMON_MSG_DOWNLOAD_SUCCESS` |
| `printPDF` | 下載失敗 | `COMMON_MSG_DOWNLOAD_FAIL` |
| `save` | 案號空白 | `COMMON_MSG_ERROR_LON` |
| `save` | 幣別空白 | `EPROI0_0160_MSG_ERRO_CURRENCY` |
| `save` | 儲存成功 | `COMMON_MSG_SAVE_SUCCESS` |
| `save` | 儲存失敗 | `COMMON_MSG_SAVE_FAIL` |

### 5.8 Timeout / Retry / Idempotency

| 項目 | 需求 |
| --- | --- |
| Timeout | 舊系統未見本功能專屬 timeout 設定；新系統應遵循平台 AJAX/download timeout 標準。 |
| Retry | Save 非安全 retry，因明細採 delete-and-upsert，前端不得自動重送造成使用者誤判。 |
| Idempotency | 同一 payload 重送理論上會覆寫為相同結果，但仍需交易成功後才顯示完成。 |
| Transaction | Save 必須維持單一 DB transaction，失敗 rollback。 |

## 6. 資料規格與 Mapping

### 6.1 主檔 `TB_FIN_STATEMENT_MAIN`

| 欄位 | 來源/畫面 | 說明 |
| --- | --- | --- |
| `APPLICATION_NO` | 父頁 context | 案件編號 |
| `CURRENCY` | `CURRENCY` select | 幣別 |
| `CCY_UNIT` | `CCY_UNIT` select | 金額單位 |
| `HIGHLIGHT` | 五段 textarea | 以 delimiter 串接 |
| `COMPANY_NAME` | Company Name | 公司名稱 |
| `CRITERIA_1` | checkbox | Criteria 1 |
| `CRITERIA_2` | checkbox | Criteria 2 |
| `CRITERIA_3` | checkbox | Criteria 3 |
| `DOES_NEED_AUDITED_FS` | radio Y/N | 是否需要 audited FS |
| `HAVE_PROVIDED_AUDITED_FS` | radio Y/N | 是否已提供 audited FS |
| `AUDIT_FIRM` | text | Audit Firm |
| `OPINION_MEMO` | textarea | Opinion Memo |

### 6.2 Balance GI `TB_FIN_STATEMENT_BALANCE_GI`

主要 key：`APPLICATION_NO`, `DATA_SEQ`。日期欄位為 `BALANCE_DATE`，年度型態為 `TYPE_OF_YEAR`，期間為 `PERIODS`。

| 欄位群組 | 欄位 |
| --- | --- |
| Current assets | `CASH_EQUIVALENT`, `SECUR_OTHER_FINCL_ASSETS`, `AR_RELATED_PARTIES`, `AR_NON_RELATED_PARTIES`, `OTHER_RECEIVABLES`, `LOANS_TO_OTHERS`, `INVENTORIES`, `PREPAYMENTS`, `OTH_CUR_ASSETS`, `TOTAL_CUR_ASSETS` |
| Non-current assets | `LAND`, `BUILDING`, `EQUIPMENT`, `OTH_FIXED_ASSETS`, `DEPRECIATION_AMORTIZATION`, `NET_FIXED_ASSETS`, `INTANGLIBLE_ASSET`, `FUNDS_INVESTMENT`, `OTH_NON_CUR_ASSETS`, `NON_CUR_ASSETS` |
| Liabilities | `ST_BORROWINGS`, `BILLS_PAYABLE`, `FINANCIAL_LIABILITIES`, `AP_RELATED_PARITIES`, `AP_NON_RELATED_PARTIES`, `TAX_PAYABLE`, `OTH_PAYABLE`, `OTH_PAYABLE_FEES`, `PRE_RECEIVE_PAYMENTS`, `CPLTD`, `OTH_CUR_LIABILITIES`, `CUR_LIABILITIES`, `LT_BORROWINGS`, `BONDS_PAYABLE`, `SHARDHOLDERS_LOAN`, `OTH_NON_CUR_LIABILITIES`, `NON_CUR_LIABILITIES` |
| Equity | `PAID_UP_CAPITAL`, `RESERVES`, `RETAINED_EARNINGS`, `MINORITY_INTEREST_EQUITY`, `OTH_ADJUSTMENTS`, `TOTAL_EQUITY` |
| Derived | `TOTAL_ASSETS`, `TOTAL_LIAB_EQUITY`, `DIFFERENCE` |

### 6.3 Income GI `TB_FIN_STATEMENT_INCOME_GI`

主要 key：`APPLICATION_NO`, `DATA_SEQ`。日期欄位 source spelling 為 `IMCOME_DATE`。

| 欄位群組 | 欄位 |
| --- | --- |
| Revenue and gross profit | `REVENUES`, `COST_OF_GOOD_SOLD`, `GROSS_PROFIT` |
| Operating expense | `SALARY`, `COMMISSION`, `MARKETING_EXPENSE`, `TRANSPORTATION`, `UTILITIES`, `OPERATING_EXPENSES`, `OPERATING_PROFIT` |
| Non-operating income | `INTEREST_INCOME`, `INVESTMENT_INCOME`, `INTEREST_DISPOSAL_FA`, `INTEREST_DISPOSAL_INVEST`, `FX_GAIN`, `RENTAL_INCOME`, `REVERSALS`, `FINANCE_ASSETS_EVALUATION`, `DEBT_EVALUATION`, `OTH_EVALUATION`, `OTH_NON_OP_INCOME`, `NON_OPERATING_INCOME` |
| Non-operating expense | `FINANCE_COST_INT_EXP`, `INVESTMENT_LOSS`, `LOSS_DISPOSAL_FA`, `LOSS_DISPOSAL_INVESTMENT`, `FX_LOSS`, `IMPAIMENT_LOSS`, `LOSS_ON_FIN_ASSETS_EVALUATION`, `LOSS_ON_OTH_EVALUATION`, `OTH_NON_OP_EXPENSE`, `NON_OPERATING_EXPENSES` |
| Profit | `PROFIT_BEFORE_TAX`, `TAX_AND_OTH`, `CUR_PERIOD_PROFIT`, `MINORITY_INTERESTS`, `ATTRIBUTED_TO_PARENT_COMP` |
| Period | `PERIODS`, `TYPE_OF_YEAR` |

### 6.4 Cashflow GI `TB_FIN_STATEMENT_CASHFLOW_GI`

| 欄位 | 說明 |
| --- | --- |
| `APPLICATION_NO` | 案件編號 |
| `DATA_SEQ` | 年度序號 |
| `CASHFLOW_DATE` | 現金流量表日期 |
| `PERIOD` | 期間 |
| `OPERATING_NET_CASHFLOW` | Operating net cashflow |
| `DEPRE` | Depreciation |
| `AMORTISATION` | Amortisation |
| `INVESTING_NET_CASHFLOW` | Investing net cashflow |
| `FINANCING_NET_CASHFLOW` | Financing net cashflow |
| `NET_I_D_IN_CASH` | Net increase/decrease in cash |
| `OPENING_BALANCE` | Opening balance |
| `END_BALANCE` | Ending balance |
| `TYPE_OF_YEAR` | 年度類型 |

### 6.5 Code Table / Option Mapping

| 畫面欄位 | 來源 | 說明 |
| --- | --- | --- |
| Currency | `EPRO_Z0Z001.getCommonFieldOptions("EPRO", language, "CCY")` | 幣別選項 |
| Currency Unit | `EPRO_Z0Z001.getCommonFieldOptions("EPRO", language, "CCY_UNIT")` | 金額單位 |
| Type of Year | `EPRO_Z0Z001.getCommonFieldOptions("EPRO", language, "TYPE_OF_YEAR")` | 年度類型 |

### 6.6 DAO / SQL Mapping

| DAO / SQL | 用途 |
| --- | --- |
| `EPRO_TB_FIN_STATEMENT_MAIN.SQL_FIND_BY_PK_001` | 依 `APPLICATION_NO` 查詢主檔 |
| `EPRO_TB_FIN_STATEMENT_MAIN.SQL_INSERT_001` | 新增主檔 |
| `EPRO_TB_FIN_STATEMENT_MAIN.SQL_UPDATE_001` | 更新主檔 |
| `EPRO_TB_FIN_STATEMENT_BALANCE_GI.SQL_FIND_001` | 查詢 Balance GI |
| `EPRO_TB_FIN_STATEMENT_BALANCE_GI.SQL_DELETE_002` | 依案件刪除 Balance GI |
| `EPRO_TB_FIN_STATEMENT_INCOME_GI.SQL_FIND_001` | 查詢 Income GI |
| `EPRO_TB_FIN_STATEMENT_INCOME_GI.SQL_DELETE_002` | 依案件刪除 Income GI |
| `EPRO_TB_FIN_STATEMENT_CASHFLOW_GI.SQL_FIND_001` | 查詢 Cashflow GI |
| `EPRO_TB_FIN_STATEMENT_CASHFLOW_GI.SQL_DELETE_002` | 依案件刪除 Cashflow GI |
| checkpoint DAO SQL | 更新 `EPROC0_0116` / `EPROC0_0216` 與下一頁 checkpoint |

### 6.7 Sensitive Data / Masking

| 項目 | 需求 |
| --- | --- |
| Audit | `printPDF` action 設定 audit 欄位包含 id、name、birthday、address 類型；新系統需沿用平台稽核規則。 |
| Download | Excel/PDF download path 需使用既有加密下載參數或新平台等效機制。 |
| Logs | 不應在 application log 直接輸出完整財報 payload 或敏感個資。 |
| Authorization | 編輯與查詢需沿用父頁 editor/query 權限控制。 |

## 7. 業務規則

| Rule ID | 規則 | 證據 |
| --- | --- | --- |
| BR-001 | 本功能僅在 C0 父頁 `BUSINESS_TYPE = G` 時載入。 | Cross-module confirmed |
| BR-002 | `EPROC0_0116` 與 `EPROC0_0216` 功能行為相同，流程差異為父頁、checkpoint table 與下一頁代號。 | Source confirmed |
| BR-003 | `inti` 初始化需同時回傳選單與本案資料。 | Source confirmed |
| BR-004 | `haveData = Y` 的條件是 Balance GI、Income GI、Cashflow GI 三張明細皆存在。 | Source confirmed |
| BR-005 | 參照案件查詢不直接寫入本案。 | Source confirmed |
| BR-006 | 計算後如任一金額欄位再被修改，前端需重新啟用 Calculation 並隱藏 Print/PDF。 | Source confirmed |
| BR-007 | Finished 時，已輸入年度的 `DIFFERENCE` 必須為 0。 | Source confirmed |
| BR-008 | Finished 時，已輸入年度的 `END_BALANCE` 必須等於同年度 `CASH_EQUIVALENT`。 | Source confirmed |
| BR-009 | Finished 時需選擇兩個 audited FS 問題。 | Source confirmed |
| BR-010 | Save 時 `APPLICATION_NO` 與 `CURRENCY` 不可空白。 | Source confirmed |
| BR-011 | Save 採單一 transaction；任一儲存步驟失敗需 rollback。 | Source confirmed |
| BR-012 | 儲存明細前需先刪除本案三張 GI 明細，再依 payload 重建。 | Source confirmed |
| BR-013 | Save 成功後，下一頁 Financial Evaluation GI checkpoint 會重設為 `Y`。 | Source confirmed |
| BR-014 | `CS` 案件讀寫 CORP checkpoint table；非 `CS` 案件讀寫 CU checkpoint table。 | Source confirmed |
| BR-015 | 後續 Financial Evaluation GI 若讀不到三張 GI 明細，無法取得可計算 list。 | Cross-module confirmed |
| BR-016 | Currency 為 `KHR` 時前端金額格式不顯示小數。 | Source confirmed |

## 8. 錯誤與訊息處理

### 8.1 錯誤處理原則

- 查詢類錯誤不得改寫 DB。
- 計算錯誤不得改寫畫面既有資料，需回傳總計失敗類訊息。
- 儲存錯誤需 rollback DB transaction。
- 匯出與 PDF 錯誤需回傳使用者可理解的下載/列印失敗訊息。
- Legacy defect suspect 的 message key 拼字仍列入 mapping，避免 migration 遺漏相容性需求。

### 8.2 訊息 Mapping

| 場景 | 舊系統訊息 key / 行為 | 新系統需求 |
| --- | --- | --- |
| 初始化查無資料 | `MSG_DATA_NOT_FOUND` | 呈現查無資料 |
| 初始化查詢失敗 | `MSG_QUERY_FAIL` | 呈現查詢失敗 |
| 參照案號無效 | `MSG_ERROR_APPLICATION_NO` | 提示輸入有效 Application No. |
| 計算失敗 | `COMMON_MSG_TOTAL_FAIL` | 提示計算失敗 |
| 案號空白 | `COMMON_MSG_ERROR_LON` | 阻擋操作 |
| 幣別空白 | `EPROI0_0160_MSG_ERRO_CURRENCY` | 阻擋儲存 |
| 儲存成功 | `COMMON_MSG_SAVE_SUCCESS` | 顯示儲存成功 |
| 儲存失敗 | `COMMON_MSG_SAVE_FAIL` | 顯示儲存失敗 |
| 匯出成功 | `MSG_EXPORT_SUCCESS` | 觸發下載 |
| 列印失敗 | `COMMON_MSG_PRINT_FAIL` / `COMMON_MSG_DOWNLOAD_FAIL` | 顯示列印或下載失敗 |

## 9. 非功能需求

| 類別 | 需求 |
| --- | --- |
| Performance | 初始化與計算需在平台標準 AJAX timeout 內完成；五年度資料為固定規模，計算不得依 DB 大量掃描。 |
| Availability | Save、Calculation、Print、PDF 失敗時需提供明確錯誤，不得使父頁整體不可操作。 |
| Security | 僅具備 editor 權限者可 Save；query mode 只可檢視與列印。 |
| Audit | 查詢、儲存、列印需保留既有 audit log 行為；PDF 需保留敏感資料 audit flags。 |
| Data integrity | Save 必須維持 transaction；三張明細與主檔不可出現部分成功。 |
| Compatibility | 新系統若仍需與舊前端/測試資料對齊，需支援 legacy action 名稱與 DB 欄位拼字。 |
| Observability | 儲存失敗需記錄足以追查的案件編號、action 與 exception，不記錄完整財報內容。 |
| Export | Excel/PDF 應以目前 DB 已儲存資料為準，不應使用未儲存的前端暫存資料。 |

## 10. 驗收條件與測試案例

### 10.1 UAT / SIT 驗收條件

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-001 | GI 一般案件且使用者有編輯權限 | 開啟 `EPROC0_0116` | 顯示可編輯 Financial Statement GI |
| AC-002 | GI 續約/變更案件且使用者有編輯權限 | 開啟 `EPROC0_0216` | 顯示可編輯 Financial Statement GI |
| AC-003 | 案件已有完整三張明細 | 初始化 | Print/PDF 按鈕可顯示 |
| AC-004 | 案件缺任一明細 | 初始化 | Print/PDF 按鈕隱藏 |
| AC-005 | 使用者修改金額欄位 | 儲存前 | Calculation 需重新執行 |
| AC-006 | Calculation 後 `DIFFERENCE = 0` 且 `END_BALANCE = CASH_EQUIVALENT` | Finished | 可儲存並更新 checkpoint |
| AC-007 | Calculation 後存在差額 | Finished | 前端阻擋完成 |
| AC-008 | 儲存成功 | 查 DB | 主檔與三張 GI 明細皆存在 |
| AC-009 | 儲存失敗 | 查 DB | 不得出現部分寫入 |
| AC-010 | 儲存成功後進入後續頁 | 後續頁初始化 | Financial Evaluation GI 可讀取本頁 GI 明細 |

### 10.2 SIT 測試案例

| Test Case ID | 測試類型 | 測試資料/步驟 | 預期結果 |
| --- | --- | --- | --- |
| TC-001 | Positive | `EPROC0_0116` 新增一筆完整五年度 GI 財報並 Save | `result = Y`，四張財報表資料正確寫入，`EPROC0_0117 = Y` |
| TC-002 | Positive | `EPROC0_0216` 新增一筆完整五年度 GI 財報並 Save | `result = Y`，四張財報表資料正確寫入，`EPROC0_0217 = Y` |
| TC-003 | Positive | 參照案件查詢符合條件且資料完整 | 畫面帶入參照資料，未 Save 前 DB 不變 |
| TC-004 | Negative | 參照案件不存在或缺明細 | 回傳 invalid application 類錯誤 |
| TC-005 | Negative | Save 時 `CURRENCY` 空白 | 儲存被阻擋，DB 不變 |
| TC-006 | Negative | Save 時 `APPLICATION_NO` 空白 | 儲存被阻擋，DB 不變 |
| TC-007 | Boundary | 只填第一年度，其他年度日期空白 | 依 TBD-005 決策驗證是否允許；目前需標記 legacy 行為 |
| TC-008 | Boundary | `KHR` 幣別輸入小數 | 前端格式不顯示小數 |
| TC-009 | Calculation | Balance Sheet 輸入使 `TOTAL_ASSETS = TOTAL_LIAB_EQUITY` | `DIFFERENCE = 0` |
| TC-010 | Calculation | Balance Sheet 輸入不平 | Finished 被阻擋 |
| TC-011 | Calculation | Cashflow `END_BALANCE` 不等於 `CASH_EQUIVALENT` | Finished 被阻擋 |
| TC-012 | Data side effect | Save 既有案件並減少年份筆數 | 舊年度明細因 delete-and-rebuild 被移除，只保留新 payload |
| TC-013 | Transaction | 模擬 Income GI insert 失敗 | 主檔、Balance、Cashflow 與 checkpoint 全部 rollback |
| TC-014 | Export | 完整資料點選 Print | 下載 `GIyyyyMMdd.xls` 且含三 sheet |
| TC-015 | Export | 完整資料點選 Print PDF | 回傳 `encryptTempFileFullPath` |
| TC-016 | Authorization | query mode 開啟本頁 | 欄位 disabled，Save/Calculation 不可操作 |
| TC-017 | Cross-module | Save 後進入 `EPROC0_0117` | 後續頁讀取本頁三張 GI 明細 |
| TC-018 | Cross-module | 父頁從 GI 改 FI 或 FI 改 GI | 父頁 changePage 刪除舊財報資料並重設 checkpoint |

### 10.3 DB 驗證建議

| 驗證點 | 查核方式 |
| --- | --- |
| 主檔存在 | 以 `APPLICATION_NO` 查 `TB_FIN_STATEMENT_MAIN` |
| 明細筆數 | 以 `APPLICATION_NO` 查三張 GI 明細，確認 `DATA_SEQ` 與年度數一致 |
| 日期格式 | 確認 `BALANCE_DATE`, `IMCOME_DATE`, `CASHFLOW_DATE` 為預期格式 |
| checkpoint | 依流程查 CORP/CU 或 RC_CORP/RC_CU table |
| 匯出資料 | 比對 Excel/PDF 金額是否來自 DB 儲存資料 |

## 11. 附件與決策紀錄

### 11.1 Source 檢核清單

| 檢核項 | 狀態 | 備註 |
| --- | --- | --- |
| Transaction | 已檢核 | `EPROC0_0116.java`, `EPROC0_0216.java` |
| Module | 已檢核 | `EPROC0_0116_mod.java`, `EPROC0_0216_mod.java` |
| JSP/JS | 已檢核 | `EPROC00116.jsp`, `EPROC00116_JS.jsp`, `EPROC00216.jsp`, `EPROC00216_JS.jsp` |
| DAO | 已檢核 | main、balance GI、income GI、cashflow GI、checkpoint |
| SQL | 已檢核 | find/insert/update/delete/deleteApp |
| Parent page | 已檢核 | `EPROC0_0110`, `EPROC0_0210` |
| Downstream page | 已檢核 | `EPROC0_0117`, `EPROC0_0217` |
| Code table | 部分檢核 | 已確認 key；正式 label 需 code table source 或 PM/SA 補充 |

### 11.2 決策紀錄

| Decision ID | 議題 | 決策 | 狀態 |
| --- | --- | --- | --- |
| DEC-001 | `EPROC0_0116` 與 `EPROC0_0216` 是否合併為同一新功能 PRD | 本文件合併為 `EPROC00116`，以流程差異表標示差異 | Draft |
| DEC-002 | Legacy 拼字錯誤 action/key/欄位是否修正 | 本 PRD 不直接修正，列為 compatibility/TBD | Draft |
| DEC-003 | 五年度日期是否全部必填 | 待 PM/SA 確認 | Open |
| DEC-004 | `HIGHLIGHT` 是否維持 delimiter 或改結構化欄位 | 待 SA/RD 決策 | Open |

### 11.3 附件：主要公式摘要

| 類別 | 公式摘要 |
| --- | --- |
| Balance | `TOTAL_ASSETS = TOTAL_CUR_ASSETS + NON_CUR_ASSETS` |
| Balance | `TOTAL_LIAB_EQUITY = CUR_LIABILITIES + NON_CUR_LIABILITIES + TOTAL_EQUITY` |
| Balance | `DIFFERENCE = TOTAL_ASSETS - TOTAL_LIAB_EQUITY` |
| Income | `GROSS_PROFIT = REVENUES - COST_OF_GOOD_SOLD` |
| Income | `OPERATING_PROFIT = GROSS_PROFIT - OPERATING_EXPENSES` |
| Income | `PROFIT_BEFORE_TAX = OPERATING_PROFIT + NON_OPERATING_INCOME - NON_OPERATING_EXPENSES` |
| Income | `ATTRIBUTED_TO_PARENT_COMP = CUR_PERIOD_PROFIT - MINORITY_INTERESTS` |
| Cashflow | `END_BALANCE = NET_I_D_IN_CASH + OPENING_BALANCE` |
| Cashflow | `OPERATING_NET_CASHFLOW = NET_I_D_IN_CASH - FINANCING_NET_CASHFLOW - INVESTING_NET_CASHFLOW` |

### 11.4 附件：舊系統與新系統實作注意事項

- 新系統若保留舊 DB schema，需保留 source 欄位拼字，避免 migration 與報表 mapping 斷裂。
- 新系統若使用結構化 JSON/API，仍需能輸出舊報表所需的欄位集合。
- Save delete-and-rebuild 行為會移除 payload 未帶入的年度資料；前端與 API 文件需明確標示。
- 參照案件帶入後不自動儲存，需維持使用者確認與 Save 的業務行為。
- 後續 Financial Evaluation GI 對本頁三張明細有完整性依賴，SIT 必須串測。
