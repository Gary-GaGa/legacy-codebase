台中資訊開發中心

業務需求導向的功能規格書

CDC-EPRO-EPROC00118 Corporate Scorecard / 企業授信評分卡

版本：v1.0　更新日期：2026-06-15　文件狀態：Draft for PM/SA/RD/QA Review

文件目的：本文件依舊系統 `EPROC0_0118` 與 `EPROC0_0218` Source code 反推 E-Proposal `EPROC00118` 的業務需求、功能規則、介面契約、資料影響與驗收測試。內容以 PM/SA/RD/QA 可 review 的業務需求為主，技術識別碼保留以便追溯 legacy source。

主系統鏈路：E-Proposal / C0 授信分析流程 / Corporate Scorecard。一般案件由 `EPROC0_0110` 父頁載入 `EPROC0_0118`，續約/變更案件由 `EPROC0_0210` 父頁載入 `EPROC0_0218`。

強化重點：AO 與 Credit Reviewer 分欄評分、Loan Default 90+ Days 特殊處理、評分參數有效日期、總分與 risk level 計算、`TB_CORP_SCRCARD` 儲存、`CR_SCORE_CARD_COMPLETED` 與 checkpoint 連動。

| 文件資訊 | 內容 |
| --- | --- |
| 文件代號 | `CDC-EPRO-EPROC00118_PRD_v1.0` |
| 功能代號 | `EPROC00118` |
| 舊系統程式 | `EPROC0_0118`, `EPROC0_0218` |
| 功能名稱 | Corporate Scorecard / 企業授信評分卡 |
| 適用流程 | C0 授信分析流程，一般案件與續約/變更案件 |
| 主要使用者 | AO、Credit Reviewer / Credit Manager、查詢角色 |
| 主要資料表 | `TB_CORP_SCRCARD`, `TB_SCORE_CARD_PARAM_DETAIL`, `TB_LON_SUMMARY_INFO`, checkpoint tables |
| 文件來源 | 舊系統 transaction、module、JSP/JS、DAO、SQL、父頁與同流程 scorecard 連動 |

## 文件 Review 資訊

| 角色 | Review 重點 | 狀態 |
| --- | --- | --- |
| PM | scorecard 項目、Default 規則、完成狀態定義 | 待確認 |
| SA | API 契約、角色流程、資料模型與參數表 mapping | 待確認 |
| RD | legacy 計算、DB transaction、欄位相容性 | 待確認 |
| QA | AO/CR SIT、default/非 default、checkpoint 與 summary 驗證 | 待確認 |

## 版本紀錄

| 版本 | 日期 | 作者 | 異動說明 |
| --- | --- | --- | --- |
| v1.0 | 2026-06-15 | Codex / pm-prd-skill | 依 `EPROC0_0118` 與 `EPROC0_0218` 舊系統 source 產出初版 PRD |

## 名詞與證據分級

| 名詞 | 說明 |
| --- | --- |
| Source confirmed | 直接由本功能 transaction、module、JSP/JS、DAO、SQL 觀察到的行為 |
| Cross-module confirmed | 由父頁、共用 scorecard module 或其他 scorecard 功能觀察到的連動 |
| Inferred | 由多個 source 點推論，仍需業務確認 |
| TBD | source 無法完整判定或需 PM/SA 決策 |
| Legacy defect suspect | 舊系統可疑或不一致行為，本 PRD 記錄為 review item，不直接修正 |

## TBD / Review Items

| ID | 類型 | 說明 | 建議決策 |
| --- | --- | --- | --- |
| TBD-001 | TBD | `TB_SCORE_CARD_PARAM_DETAIL` 的正式 option label、score 區間與 risk level 內容需由資料表資料確認；source 僅確認變數名稱與查詢規則。 | 匯出參數表資料作為附件或 migration seed。 |
| TBD-002 | TBD | `CR_SCORE_CARD_COMPLETED` 是兩碼狀態。source confirmed：`EPROC00118` 更新第一碼，`EPROC00114/00214` 更新第二碼；不同 CS/CU 父頁完成判斷不同。 | PM/SA 定義兩碼語意與各案件屬性的完成條件。 |
| TBD-003 | Legacy defect suspect | 後端 Save 只驗證 `APPLICATION_NO` 與目前角色的 `DEFAULT_DAY_FLG`，其他 required 欄位、Rate 是否已執行、CR comment 主要靠前端擋。 | 新系統是否補後端驗證需 SA/RD 決策。 |
| TBD-004 | Legacy defect suspect | `EPRO_Z0Z006.AO_ROLE` 包含 `001/002/003`，但本功能 JSP 與 module AO 儲存判斷只使用 `001/002`。 | 確認 role `003` 在本頁是否應可 AO 編輯。 |
| TBD-005 | Legacy defect suspect | AO 儲存時複製欄位清單未包含 `_AR_SCR` 與 `_INVENTORY_SCR`，但有複製 `_AR_CODE` 與 `_INVENTORY_CODE`。 | 確認是否為 legacy 缺漏；新系統若修正需註明行為差異。 |
| TBD-006 | Legacy defect suspect | `EPROC0_0218_mod.save` 重複設定 `whereFieldMap.APPLICATION_NO`，不影響結果但屬冗餘。 | 新系統可不保留冗餘。 |
| TBD-007 | Legacy defect suspect | JS 有一段 CR late transaction 連動使用不存在的 DOM id：`CR_TRA_LST_MON_CODE*`、`CR_MAX_DUE_CODE*`；同檔已有正確 id 的連動邏輯。 | 視為 dead code，不作新需求。 |
| TBD-008 | Legacy defect suspect | numeric input 初始載入與 default 切回 N 時的 input length/decimal 設定不完全一致。 | SA/RD 決定新系統採一致規格或相容舊畫面。 |
| TBD-009 | TBD | `TB_SCORE_CARD_PARAM_DETAIL.SQL_FIND_RANGE_001` 以 `ST_DATE = max(ST_DATE <= APP_DATE)` 判斷有效版本，未使用 `END_DATE`。 | 確認 scorecard 參數是否只以 ST_DATE 版本控管。 |
| TBD-010 | TBD | AO 選擇 Default 時，後端會同步設定 CR 為 Default 並將 CR score/risk/date 帶入，未要求 CR 再評。 | PM/風控確認是否符合現行審查流程。 |

## 1. 需求概述

### 1.1 需求背景

`EPROC00118` 是 C0 授信分析流程中的企業授信評分卡，供 AO 與 Credit Reviewer / Credit Manager 針對同一案件的 corporate scorecard 項目評分。畫面以 AO 與 Credit Manager 兩欄呈現 23 個評分項目，系統依各項 score 加總後，使用 `COR_RISK_LV` 參數計算 risk level。

舊系統依案件流程分成兩組程式：

| 流程 | 父頁 | 本頁 transaction | 本頁 JSP/JS | 前一頁 | 下一頁 |
| --- | --- | --- | --- | --- | --- |
| 一般案件 | `EPROC0_0110` | `EPROC0_0118` | `EPROC00118.jsp` / `EPROC00118_JS.jsp` | GI: `EPROC0_0117`; FI: `EPROC0_0120` | `EPROC0_0114` |
| 續約/變更案件 | `EPROC0_0210` | `EPROC0_0218` | `EPROC00218.jsp` / `EPROC00218_JS.jsp` | GI: `EPROC0_0217`; FI: `EPROC0_0220` | `EPROC0_0214` |

兩組程式的使用者可見行為與資料表相同，差異在於父頁、dispatcher、checkpoint table 與父頁完成狀態查詢方法。

### 1.2 需求目標

- 提供 Corporate Scorecard 的 AO 與 Credit Reviewer 兩欄評分畫面。
- 依案件申請日載入有效的 scorecard item options 與 score 區間。
- 支援 17 個下拉評分項目與 5 個數值輸入評分項目。
- 支援 Loan Default 90+ Days 為 Yes 時直接設為 `Default` risk level。
- 支援 Rate 計算，回傳 total score、risk level 與 rating date。
- 儲存 AO 或 CR 評分結果、評分人員、日期、comment 與完成狀態。
- 更新 checkpoint 與 `TB_LON_SUMMARY_INFO.CR_SCORE_CARD_COMPLETED`，供父頁與後續流程判斷。

### 1.3 需求範圍

| 範圍 | 內容 | 證據 |
| --- | --- | --- |
| 畫面查詢 | 查詢申請日、主借款人名稱、既有 scorecard、選項清單與 checkpoint | Source confirmed |
| AO 評分 | AO 欄位輸入、Rate、Save、Finished | Source confirmed |
| CR 評分 | CR 欄位輸入、Rate、comment、Save、Finished | Source confirmed |
| Default 處理 | Loan Default 90+ Days 為 Yes 時停用評分欄位並設定 Default | Source confirmed |
| 分數計算 | 選項分數、數值區間轉分、total score 與 risk level | Source confirmed |
| 儲存 | Upsert `TB_CORP_SCRCARD`、更新 summary 與 checkpoint | Source confirmed |
| 父頁連動 | `EPROC0_0110` / `EPROC0_0210` 頁籤與完成狀態 | Cross-module confirmed |

### 1.4 不在本次範圍

- 個人有擔/物 scorecard `EPROC0_0114` / `EPROC0_0214` 的完整評分邏輯。
- Consumer / IS / IU 其他 scorecard 頁面的完整邏輯。
- `TB_SCORE_CARD_PARAM_DETAIL` 參數資料維護畫面。
- risk level 與 score range 的業務合理性審核。
- 新系統 UI redesign；本文件僅描述 legacy-confirmed 行為與需求。

### 1.5 來源掃描摘要

| 類別 | Source path | 用途 |
| --- | --- | --- |
| Transaction | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0118.java` | 一般案件 query/getRate/getDate/save action |
| Transaction | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0218.java` | 續約/變更案件 query/getRate/getDate/save action |
| Module | `EPROWeb/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0118_mod.java` | 一般案件查詢、計算、儲存、checkpoint |
| Module | `EPROWeb/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0218_mod.java` | 續約/變更案件同構邏輯與 RC checkpoint |
| Shared module | `EPROWeb/JavaSource/com/cathaybk/epro/c0/module/EPRO_C00113.java` | scorecard option/risk level 查詢與 AO-to-CR copy |
| JSP/JS | `EPROC00118.jsp`, `EPROC00118_JS.jsp` | 一般案件畫面欄位、驗證、payload |
| JSP/JS | `EPROC00218.jsp`, `EPROC00218_JS.jsp` | 續約/變更案件畫面欄位、驗證、payload |
| DAO | `EPRO_TB_CORP_SCRCARD.java` | Corporate scorecard 欄位與 upsert |
| DAO | `EPRO_TB_SCORE_CARD_PARAM_DETAIL.java` | scorecard item option、score 區間與 risk level |
| Cross-module | `EPROC0_0110.java`, `EPROC0_0210.java`, parent JSP | 父頁 role、editor flag、tab 順序 |
| Cross-module | `EPRO_Z0Z006.java` | AO/CR role、父頁完成狀態、`CR_SCORE_CARD_COMPLETED` 連動 |
| Cross-module | `EPROC0_0114_mod.java`, `EPROC0_0214_mod.java` | `CR_SCORE_CARD_COMPLETED` 第二碼來源 |

## 2. 業務流程

### 2.1 End-to-End 流程

| 步驟 | 使用者/系統動作 | 系統行為 |
| --- | --- | --- |
| 1 | 使用者進入 C0 授信分析父頁 | 父頁依 GI/FI 流程載入 Corporate Scorecard 頁籤 |
| 2 | 本頁初始化 | 後端查詢申請日、scorecard options、既有 `TB_CORP_SCRCARD`、主借款人名稱與 checkpoint |
| 3 | AO 或 CR 編輯其對應欄位 | 前端依角色只開放 AO 或 CR 欄位 |
| 4 | 使用者按 Rate | 系統計算 total score、risk level 與 rating date |
| 5 | 使用者按 Save | 系統儲存目前角色資料，checkpoint 寫入 `Y` |
| 6 | 使用者按 Finished | 前端檢核必要欄位與已 Rate，系統儲存並將 checkpoint 寫入 `N` |
| 7 | 父頁更新完成狀態 | 系統回傳 `isAllTabsCheck`，父頁依結果更新 done 樣式 |

### 2.2 AO 流程

| 步驟 | 規則 |
| --- | --- |
| 1 | AO role source confirmed 為 JSP/module 的 `001` 或 `002` |
| 2 | AO 可編輯 AO 欄位，CR 欄位與 CR comment disabled |
| 3 | AO 若選擇 Loan Default 90+ Days = Yes，AO 欄位被清空/停用，`AO_RISK_LEVEL = Default`，並呼叫 `getDate` 取得 `AO_DATE` |
| 4 | AO 若選擇 No，需填完 AO required 欄位後按 Rate |
| 5 | AO Save/Finished 時，後端會將多數 AO 評分欄位 copy 到 CR 欄位 |
| 6 | AO Save 會將 `CR_SCORE_CARD_COMPLETED` 重設為 `NN` |

### 2.3 CR 流程

| 步驟 | 規則 |
| --- | --- |
| 1 | CR role source confirmed 為 `102` 或 `103` |
| 2 | CR 可編輯 CR 欄位與 `CR_COMMENT`，AO 欄位 disabled |
| 3 | CR 若選擇 Loan Default 90+ Days = Yes，CR 欄位被清空/停用，`CR_RISK_LEVEL = Default`，並呼叫 `getDate` 取得 `CR_DATE` |
| 4 | CR 若選擇 No，需填完 CR required 欄位與 comment 後按 Rate |
| 5 | CR Save/Finished 時，後端更新 CR 評分、CR 人員、CR date、CR comment date 與 `CR_SCORE_CARD_COMPLETED` 第一碼 |

### 2.4 狀態與頁籤流程

| 流程 | 本頁 checkpoint | checkpoint table | 父頁完成檢核 |
| --- | --- | --- | --- |
| `EPROC0_0118` CS 分支 | `EPROC0_0118` | `TB_CHECK_POINT_CORP` | `getCheckedProgressCORP` |
| `EPROC0_0118` 非 CS 分支 | `EPROC0_0118` | `TB_CHECK_POINT_CU` | `getCheckedProgressCORP` |
| `EPROC0_0218` CS 分支 | `EPROC0_0218` | `TB_CHECK_POINT_RC_CORP` | `getCheckedProgressRC_CORP` |
| `EPROC0_0218` 非 CS 分支 | `EPROC0_0218` | `TB_CHECK_POINT_RC_CU` | `getCheckedProgressRC_CORP` |

`check = Y` 代表 Save 尚未完成頁籤；`check = N` 代表 Finished。前端僅在 `check = N` 且 `isAllTabsCheck = true` 時將父頁 frame 標為 done。

## 3. 需求與來源矩陣

| Requirement ID | 功能名稱 | 證據分級 | Source mapping | 說明 |
| --- | --- | --- | --- | --- |
| FR-001 | 初始化查詢 | Source confirmed | `query` action / `mod.query` / `EPRO_C00113.getPromptMap*` | 載入案件、主借款人、scorecard options、既有資料與 checkpoint |
| FR-002 | Scorecard 項目維護 | Source confirmed | `EPROC00118.jsp`, `EPROC00218.jsp` | 維護 23 個 corporate scorecard item |
| FR-003 | Rate 計算 | Source confirmed | `getRate` action / `EPRO_C00113.getRate` | 計算 total score、risk level 與 rating date |
| FR-004 | Loan Default 處理 | Source confirmed | JS default flag handler / `save` branch | Default = Yes 時直接設 Default risk |
| FR-005 | AO/CR 角色控制 | Source confirmed | JSP c:if role checks / module role checks | AO 與 CR 欄位、button、comment 顯示與儲存邏輯不同 |
| FR-006 | Save/Finished 儲存 | Source confirmed | `mod.save` / `TB_CORP_SCRCARD` DAO | Upsert scorecard，更新 summary 與 checkpoint |
| FR-007 | 父頁與完成狀態連動 | Cross-module confirmed | `EPROC0_0110`, `EPROC0_0210`, `EPRO_Z0Z006` | 更新 page menu 與 `CR_SCORE_CARD_COMPLETED` |
| FR-008 | 參數有效日期 | Source confirmed | `TB_SCORE_CARD_PARAM_DETAIL.SQL_FIND_RANGE_001` | 依申請日取有效版本與 score range |

### 3.1 來源方法對照

| 程式 | Method/action | 需求意義 |
| --- | --- | --- |
| `EPROC0_0118.java`, `EPROC0_0218.java` | `@CallMethod(action = "query")` | 初始化查詢 |
| `EPROC0_0118.java`, `EPROC0_0218.java` | `getRate` | 計算 total score/risk level |
| `EPROC0_0118.java`, `EPROC0_0218.java` | `getDate` | Default 情境取得 rating date |
| `EPROC0_0118.java`, `EPROC0_0218.java` | `save` | 儲存 scorecard 與完成狀態 |
| `EPROC0_0118_mod.java`, `EPROC0_0218_mod.java` | `query` | 查 scorecard prompt data 與主借款人 |
| `EPROC0_0118_mod.java`, `EPROC0_0218_mod.java` | `getRate` | input 類欄位轉 score 後計算 |
| `EPROC0_0118_mod.java`, `EPROC0_0218_mod.java` | `save` | 驗證、upsert、summary/checkpoint update |
| `EPRO_C00113.java` | `getPromptMap`, `getPromptMapRC` | 載入 options、既有資料與 checkpoint |
| `EPRO_C00113.java` | `copySameField` | AO 儲存時 copy AO 欄位到 CR |

## 4. 功能需求

### 4.1 FR-001 初始化查詢

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-001 |
| 功能名稱 | 初始化查詢 |
| 需求說明 | 使用者進入 Corporate Scorecard 頁面時，系統需載入案件申請日、scorecard options、既有 scorecard 資料、主借款人名稱與本頁 checkpoint。 |
| Trigger | 前端呼叫 `query` action |
| Actor | AO、Credit Reviewer、查詢角色 |
| Evidence | Source confirmed |

功能規則：

- `APPLICATION_NO` 不可空白；空白時回傳 `COMMON_MSG_ERROR_LON`。
- 系統需由 `TB_LON_SUMMARY_INFO.APPLICATION_DATE` 取得申請日，並作為 scorecard 參數版本日期。
- 系統需查詢 `TB_CORP_SCRCARD` 既有資料；無資料時仍需載入 options 供新增。
- 系統需透過 `TB_SCORE_CARD_PARAM_DETAIL` 載入 17 個下拉項目的 options。
- 系統需查詢 `TB_MAIN_BORROWER_INFO_CORP.MAIN_BORROWER_NAME` 顯示 Name of Applicant。
- 系統需依 `LON_ATTRIBUTE + SECURE_ATTRIBUTE == CS` 判斷 checkpoint table。
- `EPROC0_0118` 使用 `EPRO_C00113.getPromptMap`；`EPROC0_0218` 使用 `getPromptMapRC`。
- 查詢時若 DB 儲存 `CUR_RATIO` 為小數比例，畫面顯示前需乘以 100 作為百分比。

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR001-01 | 有效 `APPLICATION_NO` 且有既有 scorecard | 開啟本頁 | 畫面帶入 AO/CR 已儲存欄位、risk level、date、comment |
| AC-FR001-02 | 有效 `APPLICATION_NO` 但無 scorecard | 開啟本頁 | 畫面仍載入下拉 options 與主借款人名稱 |
| AC-FR001-03 | `APPLICATION_NO` 空白 | 呼叫 query | 系統回傳案件錯誤 |

### 4.2 FR-002 Scorecard 項目維護

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-002 |
| 功能名稱 | Scorecard 項目維護 |
| 需求說明 | 系統需提供 AO 與 CR 兩欄，共同維護 corporate scorecard 的 23 個評分項目。 |
| Trigger | 使用者輸入或選擇 scorecard 項目 |
| Actor | AO、Credit Reviewer |
| Evidence | Source confirmed |

Scorecard 項目：

| No. | Item | 欄位 suffix | 參數 VAR_NAME | 類型 |
| --- | --- | --- | --- | --- |
| 1 | Loan Default 90+ Days | `DEFAULT_DAY_FLG` | 無，特殊 radio | Y/N |
| 2 | Management Executive's Age Range | `AGE_CODE` / `AGE_SCR` | `B_V4` | select |
| 3 | Age range of guarantor(s) | `GUAR_AGE_CODE` / `GUAR_AGE_SCR` | `B_V5` | select |
| 4 | Company Type | `COMP_TYPE_CODE` / `COMP_TYPE_SCR` | `B_V20` | select |
| 5 | Industry | `INDUSTRY_CODE` / `INDUSTRY_SCR` | `B_V19` | select |
| 6 | Years in Operation | `YEAR_OP_CODE` / `YEAR_OP_SCR` | `B_V9` | select |
| 7 | Loan Purpose | `LOAN_PURPOSE_CODE` / `LOAN_PURPOSE_SCR` | `B_V6` | select |
| 8 | Repayment Source(s) | `REPAYMENT_S_CODE` / `REPAYMENT_S_SCR` | `B_V7` | select |
| 9 | K-Score (CBC-Consumer Credit Report) | `K_SCORE_CODE` / `K_SCORE_SCR` | `B_V8` | select |
| 10 | Max. overdue days for late transaction in past 12 months | `MAX_OVERDUE_CODE` / `MAX_OVERDUE_SCR` | `B_V2` | select |
| 11 | No. of late transaction in past 12 months | `TRANS_12MON_CODE` / `TRANS_12MON_SCR` | `B_V3` | select |
| 12 | Substantiation of Repayment Source | `SUBS_REPAYMENT_S_CODE` / `SUBS_REPAYMENT_S_SCR` | `B_V22` | select |
| 13 | Company with Positive Net Income for both past 2 years? | `COMP_POSITIVE_CODE` / `COMP_POSITIVE_SCR` | `B_V15` | select |
| 14 | Company with Consecutive Sales Growth Ratio | `GROWTH_RATIO_CODE` / `GROWTH_RATIO_SCR` | `B_V16` | select |
| 15 | Company with Consecutive Net Profit Margin Growth Ratio | `PM_GROWTH_RATIO_CODE` / `PM_GROWTH_RATIO_SCR` | `B_V17` | select |
| 16 | Current Ratio | `CUR_RATIO`, `CUR_RATIO_CODE`, `CUR_RATIO_SCR` | `B_V18` | numeric input |
| 17 | Debt to Equity Ratio | `DE_RATIO`, `DE_RATIO_CODE`, `DE_RATIO_SCR` | `B_V10` | numeric input |
| 18 | Changes in A/P | `AP_CODE` / `AP_SCR` | `B_V11` | select |
| 19 | Changes in A/R | `AR_CODE` / `AR_SCR` | `B_V12` | select |
| 20 | Changes in Inventory | `INVENTORY_CODE` / `INVENTORY_SCR` | `B_V13` | select |
| 21 | Company Total Asset | `CMP_TOT_ASSET`, `CMP_TOT_ASSET_CODE`, `CMP_TOT_ASSET_SCR` | `B_V14` | numeric input |
| 22 | Total loan amount from Financial Institutes/Affiliate | `TOTAL_LOAN_AMT`, `TOTAL_LOAN_AMT_CODE`, `TOTAL_LOAN_AMT_SCR` | `B_V1` | numeric input |
| 23 | Debt Service Ratio | `DEBT_RATIO`, `DEBT_RATIO_CODE`, `DEBT_RATIO_SCR` | `B_V21` | numeric input |

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR002-01 | 申請日有有效參數 | 初始化 | 17 個 select 項目載入 options |
| AC-FR002-02 | 使用者選取 select option | Rate | option 對應 score 納入 total score |
| AC-FR002-03 | 使用者輸入 numeric item | Rate | 後端依 score range 轉出 code 與 score |

### 4.3 FR-003 Rate 計算

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-003 |
| 功能名稱 | Rate 計算 |
| 需求說明 | 系統需依目前角色欄位計算 total score、risk level 與 rating date。 |
| Trigger | 使用者點選 AO Rate 或 CR Rate |
| Actor | AO、Credit Reviewer |
| Evidence | Source confirmed |

計算規則：

- 前端將 select 類項目的 score 組成 `scoreMap`。
- 前端將 numeric input 類項目組成 `inputMap`。
- 後端對 numeric input 依 `LIST_INPUT_NM_MAP` 轉為 scorecard 參數 `VAR_NAME`。
- 後端使用 `TB_SCORE_CARD_PARAM_DETAIL` 找出 `LOW_RANGE <= input < UP_RANGE` 的分數。
- 系統將所有 score 加總為 `totalScore`。
- 系統以 `VAR_NAME = COR_RISK_LV` 且 `CODE = totalScore` 查回 risk level。
- 系統回傳 `level`、`scrDate`、`totalScore`。
- `scrDate` 格式為 `dd/MM/yyyy HH:mm:ss`。

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR003-01 | 必填評分欄位完整 | 點選 Rate | 系統顯示 risk level 與 date |
| AC-FR003-02 | Rate 後修改評分欄位 | 欄位 change | 前端清空 risk level/date/totalScore，需重新 Rate |
| AC-FR003-03 | numeric input 落在 range 上界 | Rate | 依 `LOW_RANGE <= input < UP_RANGE` 規則歸屬下一區間或無資料 |

### 4.4 FR-004 Loan Default 90+ Days 處理

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-004 |
| 功能名稱 | Loan Default 90+ Days 處理 |
| 需求說明 | 若使用者將 Loan Default 90+ Days 選為 Yes，系統需直接將該角色 risk level 設為 Default，並停用其他評分欄位。 |
| Trigger | 使用者選擇 `AO_DEFAULT_DAY_FLG` 或 `CR_DEFAULT_DAY_FLG` = `Y` |
| Actor | AO、Credit Reviewer |
| Evidence | Source confirmed |

功能規則：

- 選擇 Yes 時，前端提示 `EPROI00118_MSG_DATE`。
- 系統清空並停用該角色評分欄位。
- 系統停用該角色 Rate button。
- 系統將該角色 `RISK_LEVEL` 顯示為 `Default`。
- 系統呼叫 `getDate` 取得該角色 rating date。
- Save 時若 risk level 為 `Default`，該角色 score 寫入 `-1`。
- AO 若為 Default，後端同時設定 CR score/risk/date 為 Default 狀態。

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR004-01 | AO 選擇 Loan Default = Yes | Save | `AO_RISK_LEVEL = Default`, `AO_SCORE = -1` |
| AC-FR004-02 | CR 選擇 Loan Default = Yes | Save | `CR_RISK_LEVEL = Default`, `CR_SCORE = -1` |
| AC-FR004-03 | 使用者將 Default 改回 No | 畫面變更 | 欄位重新開放，risk/date 清空，需重新 Rate |

### 4.5 FR-005 AO/CR 角色控制

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-005 |
| 功能名稱 | AO/CR 角色控制 |
| 需求說明 | 系統需依使用者角色決定可編輯欄位、可按 Rate button、是否顯示 CR comment。 |
| Trigger | 畫面初始化與角色判斷 |
| Actor | AO、Credit Reviewer、查詢角色 |
| Evidence | Source confirmed |

角色規則：

| 角色 | Source 判斷 | 可編輯 | 補充 |
| --- | --- | --- | --- |
| AO | JSP/module 使用 `role == 001 || role == 002` | AO 欄位、AO Rate、Save/Finished | CR 欄位與 CR comment disabled |
| CR | JSP/module 使用 `role == 102 || role == 103` | CR 欄位、CR Rate、CR comment、Save/Finished | AO 欄位 disabled |
| Query | `attrMap.isQuery` | 不可編輯 | 所有 score 欄位與 comment disabled |
| Other | 不符合 AO/CR | 不可編輯 | 前端停用 score 欄位 |

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR005-01 | AO role 開啟頁面 | 初始化 | 只可編輯 AO 欄位 |
| AC-FR005-02 | CR role 開啟頁面 | 初始化 | 只可編輯 CR 欄位與 CR comment |
| AC-FR005-03 | query mode 開啟頁面 | 初始化 | 全頁 score 欄位與 comment disabled |

### 4.6 FR-006 Save/Finished 儲存

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-006 |
| 功能名稱 | Save/Finished 儲存 |
| 需求說明 | 系統需以 transaction 儲存目前角色 scorecard 資料，並同步更新 summary 與 checkpoint。 |
| Trigger | 使用者點選 Save 或 Finished |
| Actor | AO、Credit Reviewer |
| Evidence | Source confirmed |

儲存規則：

- 前端 Save 傳 `check = Y`；Finished 傳 `check = N`。
- 後端驗證 `APPLICATION_NO` 不可空白。
- 後端驗證目前角色的 `DEFAULT_DAY_FLG` 不可空白。
- 後端合併 `infoMap`、`scoreMap`、`codeMap` 與 numeric input 轉出的 code/score。
- 後端對 `CUR_RATIO` 儲存前除以 100，DB 儲存比例值；查詢時再乘以 100 顯示。
- `TB_CORP_SCRCARD` 採 update-first；update count 為 0 時 insert。
- 儲存同一 transaction 內更新 `TB_LON_SUMMARY_INFO` 與 checkpoint table。
- transaction 失敗需 rollback。

AO 儲存規則：

- AO 儲存時寫入 `AO_CODE`、`AO_NAME`、`AO_DATE`。
- AO 儲存時將多數 AO 欄位 copy 到 CR 欄位。
- AO risk level 為 `Default` 時，`AO_SCORE = -1`、`CR_SCORE = -1`、`CR_RISK_LEVEL = Default`、`CR_DATE = AO_DATE`。
- AO risk level 非 Default 時，`AO_SCORE = totalScore`、`CR_SCORE = null`、`CR_RISK_LEVEL = null`、`CR_DATE = null`。
- AO 儲存後 `CR_SCORE_CARD_COMPLETED = NN`。

CR 儲存規則：

- CR 儲存時寫入 `CR_CODE`、`CR_NAME`、`CR_DATE`、`CR_COMMENT_DATE`。
- CR risk level 為 `Default` 時，`CR_SCORE = -1`；否則 `CR_SCORE = totalScore`。
- CR 儲存時讀取既有 `CR_SCORE_CARD_COMPLETED` 第二碼並保留。
- CR Save (`check = Y`) 將第一碼寫為 `N`；CR Finished (`check = N`) 將第一碼寫為 `Y`。

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR006-01 | AO 填完並 Rate | Finished | 寫入 AO 資料，checkpoint 寫入 `N` |
| AC-FR006-02 | CR 填完、Rate、輸入 comment | Finished | 寫入 CR 資料，`CR_SCORE_CARD_COMPLETED` 第一碼寫為 `Y` |
| AC-FR006-03 | Save transaction 任一步失敗 | Save/Finished | `TB_CORP_SCRCARD`、summary、checkpoint 全部 rollback |

### 4.7 FR-007 父頁與完成狀態連動

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-007 |
| 功能名稱 | 父頁與完成狀態連動 |
| 需求說明 | 本頁儲存後需回傳父頁完成狀態，讓 `EPROC0_0110` / `EPROC0_0210` 更新頁籤進度。 |
| Trigger | Save/Finished 成功 |
| Actor | 系統 |
| Evidence | Cross-module confirmed |

連動規則：

- `EPROC0_0118` Save 後呼叫 `EPRO_Z0Z006.getTabsCheckPage(pageCheckMap, "EPROC0_0110")` 與 `getCheckedProgressCORP`。
- `EPROC0_0218` Save 後呼叫 `getTabsCheckPage(pageCheckMap, "EPROC0_0210")` 與 `getCheckedProgressRC_CORP`。
- 前端成功後會依 `isAllTabsCheck` 更新父頁 frame 的 done 樣式。
- AO 在一般 edit 且非 old case 時，前端會呼叫父頁 `check('EPROC0_0118', check)` 或 `check('EPROC0_0218', check)`。

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR007-01 | 所有必要 tab 完成且本頁 Finished | 儲存成功 | 父頁目前 frame 顯示 done |
| AC-FR007-02 | 本頁 Save 未 Finished | 儲存成功 | 父頁不可因本頁標示完成 |

### 4.8 FR-008 參數有效日期

| 項目 | 內容 |
| --- | --- |
| Requirement ID | FR-008 |
| 功能名稱 | Scorecard 參數有效日期 |
| 需求說明 | scorecard options、numeric score range 與 risk level 必須依案件申請日取用有效參數。 |
| Trigger | query / getRate / save numeric input mapping |
| Actor | 系統 |
| Evidence | Source confirmed |

參數規則：

- `APP_DATE` 來自 `TB_LON_SUMMARY_INFO.APPLICATION_DATE`。
- options 查詢使用 `VAR_NAME` 與 `APP_DATE`，排序欄位為 `VAR_ORDER`。
- numeric input score 查詢使用 `VAR_NAME`、`APP_DATE`、`LOW_RANGE <= input < UP_RANGE`。
- risk level 查詢使用 `VAR_NAME = COR_RISK_LV`、`CODE = totalScore`。
- source SQL 以 `ST_DATE = max(ST_DATE <= APP_DATE)` 選出版本。

Acceptance Criteria：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-FR008-01 | 不同申請日對應不同參數版本 | 初始化 | options 依申請日版本載入 |
| AC-FR008-02 | numeric input 落在不同 score range | Rate | 系統回傳對應分數 |

## 5. API / Interface 規格

### 5.1 API 總覽

| Action | Method | Request | Response | 說明 |
| --- | --- | --- | --- | --- |
| `query` | AJAX | `APPLICATION_NO`, `action` | `dataMap` | 初始化查詢 |
| `getRate` | AJAX | `scoreMap`, `inputMap`, `appDate` | `level`, `scrDate`, `totalScore` | 評分計算 |
| `getDate` | AJAX | 無必要參數 | `scrDate` | Default 情境取得日期 |
| `save` | AJAX | `APPLICATION_NO`, `scoreMap`, `codeMap`, `infoMap`, `inputMap`, `appDate`, `totalScore`, `check`, `pageCheckMap` | `isAllTabsCheck` | 儲存 scorecard |

### 5.2 Common Request Context

| 欄位 | 說明 |
| --- | --- |
| `APPLICATION_NO` | 目前案件編號，由父頁 context 帶入 |
| UserObject | 後端由 session 取得，用於 role、employee id/name 與 audit |
| `role` | 控制 AO/CR 欄位與儲存分支 |
| `attrMap.isQuery` | 查詢模式控制全頁唯讀 |
| `attrMap.isOld` | 前端控制是否更新新版父頁 page frame |
| `isEditor118` / `isEditor218` | 父頁輸出是否顯示 Save/Finished |

### 5.3 `query` Request / Response

| 類型 | 欄位 | 說明 |
| --- | --- | --- |
| Request | `APPLICATION_NO` | 目前案件編號 |
| Request | `action` | 前端傳入，module 未使用於核心查詢 |
| Response | `dataMap.APPLICATION_DATE` | 案件申請日 |
| Response | `dataMap.MAIN_BORROWER_NAME` | 主借款人名稱 |
| Response | `dataMap.listNMArray` | option VAR_NAME array |
| Response | `dataMap.B_V*List` | 各 scorecard item options |
| Response | `dataMap.AO_*` / `CR_*` | 既有 scorecard 欄位 |
| Response | `dataMap.check` | 本頁 checkpoint |
| Response | `dataMap.CR_COMMENT_DATE` | 已有 CR comment date 或目前 CR user 顯示字串 |

### 5.4 `getRate` Request / Response

| 類型 | 欄位 | 說明 |
| --- | --- | --- |
| Request | `scoreMap` | select 類 item 的 score map |
| Request | `inputMap` | numeric input 類 item 的原始輸入 |
| Request | `appDate` | 申請日，用於參數版本 |
| Response | `level` | risk level |
| Response | `scrDate` | rating date，`dd/MM/yyyy HH:mm:ss` |
| Response | `totalScore` | score 加總 |

### 5.5 `save` Request / Response

| 類型 | 欄位 | 說明 |
| --- | --- | --- |
| Request | `scoreMap` | 目前角色 select 類 score |
| Request | `codeMap` | 目前角色 select 類 code |
| Request | `infoMap` | `APPLICATION_NO`、default flag、risk level、date、CR comment 等 |
| Request | `inputMap` | 目前角色 numeric input |
| Request | `appDate` | 申請日 |
| Request | `totalScore` | Rate 後 total score |
| Request | `check` | Save=`Y`，Finished=`N` |
| Request | `pageCheckMap` | 父頁頁籤狀態 |
| Response | `isAllTabsCheck` | 父頁是否所有必要 tab 已完成 |

### 5.6 Error Response

| Action | 條件 | 舊系統訊息 key / 類型 |
| --- | --- | --- |
| `query` | `APPLICATION_NO` 空白 | `COMMON_MSG_ERROR_LON` |
| `query` | 查無資料 | `MSG_DATA_NOT_FOUND` |
| `query` | over count | `MSG_OVER_COUNT_LIMIT` |
| `query` | 查詢失敗 | `MSG_QUERY_FAIL` |
| `getRate` | module error | module message 或 `MSG_QUERY_FAIL` |
| `getRate` | general error | `COMMON_MSG_RATE_FAIL` |
| `getDate` | general error | `COMMON_MSG_RATE_FAIL` |
| `save` | `APPLICATION_NO` 空白 | `COMMON_MSG_ERROR_LON` |
| `save` | default flag 未選 | `EPROI00118_MSG_ERROR_FLG` |
| `save` | 儲存成功 | `COMMON_MSG_SAVE_SUCCESS` |
| `save` | 儲存失敗 | `COMMON_MSG_SAVE_FAIL` |

### 5.7 Timeout / Retry / Idempotency

| 項目 | 需求 |
| --- | --- |
| Timeout | 舊系統未見本功能專屬 timeout；新系統應遵循平台 AJAX 標準。 |
| Retry | Save 非安全自動 retry，因會更新 summary/checkpoint 與 comment date。 |
| Idempotency | 相同 payload 重送可覆寫相同 scorecard 欄位，但 `CR_COMMENT_DATE` 會更新為新時間。 |
| Transaction | Save 必須維持 `TB_CORP_SCRCARD`、summary、checkpoint 同 transaction。 |

## 6. 資料規格與 Mapping

### 6.1 `TB_CORP_SCRCARD`

`TB_CORP_SCRCARD` 以 `APPLICATION_NO` 為主要 key，保存 AO 與 CR 兩套欄位。DAO 名稱與 table 名稱保留 legacy spelling `SCRCARD`。

| 欄位群組 | 欄位 |
| --- | --- |
| Key | `APPLICATION_NO` |
| AO default/rating | `AO_DEFAULT_DAY_FLG`, `AO_RISK_LEVEL`, `AO_SCORE`, `AO_DATE`, `AO_CODE`, `AO_NAME` |
| CR default/rating | `CR_DEFAULT_DAY_FLG`, `CR_RISK_LEVEL`, `CR_SCORE`, `CR_DATE`, `CR_CODE`, `CR_NAME`, `CR_COMMENT`, `CR_COMMENT_DATE` |
| AO select code/score | `AO_AGE_CODE/SCR`, `AO_GUAR_AGE_CODE/SCR`, `AO_COMP_TYPE_CODE/SCR`, `AO_INDUSTRY_CODE/SCR`, `AO_YEAR_OP_CODE/SCR`, `AO_LOAN_PURPOSE_CODE/SCR`, `AO_REPAYMENT_S_CODE/SCR`, `AO_K_SCORE_CODE/SCR`, `AO_MAX_OVERDUE_CODE/SCR`, `AO_TRANS_12MON_CODE/SCR`, `AO_SUBS_REPAYMENT_S_CODE/SCR`, `AO_COMP_POSITIVE_CODE/SCR`, `AO_GROWTH_RATIO_CODE/SCR`, `AO_PM_GROWTH_RATIO_CODE/SCR`, `AO_AP_CODE/SCR`, `AO_AR_CODE/SCR`, `AO_INVENTORY_CODE/SCR` |
| CR select code/score | 同 AO 欄位，prefix 改為 `CR_` |
| AO numeric | `AO_CUR_RATIO`, `AO_CUR_RATIO_CODE/SCR`, `AO_DE_RATIO`, `AO_DE_RATIO_CODE/SCR`, `AO_CMP_TOT_ASSET`, `AO_CMP_TOT_ASSET_CODE/SCR`, `AO_TOTAL_LOAN_AMT`, `AO_TOTAL_LOAN_AMT_CODE/SCR`, `AO_DEBT_RATIO`, `AO_DEBT_RATIO_CODE/SCR` |
| CR numeric | 同 AO numeric 欄位，prefix 改為 `CR_` |

### 6.2 `TB_SCORE_CARD_PARAM_DETAIL`

| 欄位 | 說明 |
| --- | --- |
| `DOC_ID` | 參數文件/群組識別 |
| `VAR_NAME` | scorecard 變數，例如 `B_V4`, `B_V18`, `COR_RISK_LV` |
| `VAR_CODE` | option code 或 range code |
| `LOW_RANGE` / `UP_RANGE` | numeric input 與 total score range |
| `SCORE` | scorecard 分數 |
| `VAR_DESC` | option 顯示文字或 risk level |
| `VAR_ORDER` | option 排序 |
| `ST_DATE` / `END_DATE` | 參數有效期間欄位 |

### 6.3 `TB_LON_SUMMARY_INFO`

| 欄位 | 用途 |
| --- | --- |
| `APPLICATION_DATE` | scorecard 參數有效日期 |
| `LON_ATTRIBUTE`, `SECURE_ATTRIBUTE` | 組合判斷 `CS`，決定 checkpoint table |
| `CR_SCORE_CARD_COMPLETED` | 兩碼完成狀態，`EPROC00118` 更新第一碼 |

### 6.4 Checkpoint Tables

| 流程 | CS | 非 CS |
| --- | --- | --- |
| `EPROC0_0118` | `TB_CHECK_POINT_CORP.EPROC0_0118` | `TB_CHECK_POINT_CU.EPROC0_0118` |
| `EPROC0_0218` | `TB_CHECK_POINT_RC_CORP.EPROC0_0218` | `TB_CHECK_POINT_RC_CU.EPROC0_0218` |

### 6.5 SQL Mapping

| SQL | 用途 |
| --- | --- |
| `EPRO_TB_CORP_SCRCARD.SQL_FIND_001` | 依 `APPLICATION_NO` 查 corporate scorecard |
| `EPRO_TB_CORP_SCRCARD.SQL_INSERT_001` | 新增 corporate scorecard |
| `EPRO_TB_CORP_SCRCARD.SQL_UPDATE_002` | 依 `APPLICATION_NO` 更新 corporate scorecard |
| `EPRO_TB_SCORE_CARD_PARAM_DETAIL.SQL_FIND_RANGE_001` | 依 `VAR_NAME`、`APP_DATE`、range 取 option/score/risk level |
| `EPRO_TB_LON_SUMMARY_INFO.SQL_UPDATE_*` | 更新 `CR_SCORE_CARD_COMPLETED` |
| checkpoint SQL | 更新本頁 checkpoint |

### 6.6 Sensitive Data / Masking

| 項目 | 需求 |
| --- | --- |
| Scorecard | Scorecard 結果屬授信風險資料，log 不應輸出完整 request payload。 |
| Employee | `AO_CODE/NAME`, `CR_CODE/NAME` 應依平台權限顯示與稽核。 |
| Audit | query 使用 Query/Table audit，save 使用 Edit/Table audit。 |
| Authorization | 欄位編輯須依 role 與 `isEditor118/218` 控制；後端也應檢核角色權限。 |

## 7. 業務規則

| Rule ID | 規則 | 證據 |
| --- | --- | --- |
| BR-001 | 本功能在 C0 授信分析流程中作為 Corporate Scorecard 頁籤。 | Cross-module confirmed |
| BR-002 | `EPROC0_0118` 與 `EPROC0_0218` 行為相同，差異在父頁與 checkpoint table。 | Source confirmed |
| BR-003 | scorecard 參數需依案件 `APPLICATION_DATE` 取版本。 | Source confirmed |
| BR-004 | select 類項目以 `VAR_CODE` 儲存 code，以 `SCORE` 儲存分數。 | Source confirmed |
| BR-005 | numeric 類項目需依 input value 查 range，並儲存 input、code 與 score。 | Source confirmed |
| BR-006 | total score 是所有評分項目 score 的加總。 | Source confirmed |
| BR-007 | risk level 由 `COR_RISK_LV` 與 total score 反查。 | Source confirmed |
| BR-008 | Loan Default 90+ Days = Yes 時，該角色 risk level 為 `Default`，score 為 `-1`。 | Source confirmed |
| BR-009 | Rate 後修改欄位，risk level/date/totalScore 必須清空。 | Source confirmed |
| BR-010 | `MAX_OVERDUE_CODE = 01` 時 `TRANS_12MON_CODE = 01` 並 disabled；`MAX_OVERDUE_CODE = 07` 時 `TRANS_12MON_CODE = 05` 並 disabled。 | Source confirmed |
| BR-011 | 反向選擇 `TRANS_12MON_CODE = 01` 或 `05` 時需同步鎖定 `MAX_OVERDUE_CODE`。 | Source confirmed |
| BR-012 | AO 儲存會重設 `CR_SCORE_CARD_COMPLETED = NN`。 | Source confirmed |
| BR-013 | CR Save 將 `CR_SCORE_CARD_COMPLETED` 第一碼寫為 `N`；CR Finished 將第一碼寫為 `Y`。 | Source confirmed |
| BR-014 | `CUR_RATIO` 畫面以百分比顯示，DB 儲存前除以 100。 | Source confirmed |
| BR-015 | Save 採 update-first；無資料時 insert。 | Source confirmed |
| BR-016 | Save 必須同 transaction 更新 scorecard、summary 與 checkpoint。 | Source confirmed |

## 8. 錯誤與訊息處理

### 8.1 錯誤處理原則

- query/getRate/getDate 失敗不得改寫 DB。
- Rate 失敗時需保留畫面輸入，並提示 rating fail 類訊息。
- Save 失敗需 rollback scorecard、summary 與 checkpoint。
- 前端 validation 不足以成為資料完整性保證；新系統應評估補後端驗證。

### 8.2 訊息 Mapping

| 場景 | 舊系統訊息 key / 行為 | 新系統需求 |
| --- | --- | --- |
| 案件編號空白 | `COMMON_MSG_ERROR_LON` | 阻擋 query/save |
| default flag 未選 | `EPROI00118_MSG_ERROR_FLG` | 阻擋 save |
| 必填欄位未選 | `COMMON_UI_PLEASE_SELECT` | 前端顯示欄位錯誤 |
| 未執行 Rate | `COMMON_MSG_RATE` | Finished 前阻擋 |
| 選擇 Default | `EPROI00118_MSG_DATE` | 顯示提示並帶入 date |
| Rate 失敗 | `COMMON_MSG_RATE_FAIL` | 顯示計算失敗 |
| 查詢失敗 | `MSG_QUERY_FAIL` | 顯示查詢失敗 |
| 儲存成功 | `COMMON_MSG_SAVE_SUCCESS` | 顯示儲存成功 |
| 儲存失敗 | `COMMON_MSG_SAVE_FAIL` | 顯示儲存失敗 |

## 9. 非功能需求

| 類別 | 需求 |
| --- | --- |
| Performance | query 需載入固定數量 scorecard options，應在平台標準 AJAX timeout 內完成。 |
| Availability | scorecard 參數缺漏時需明確回報，避免使用者得到空白 risk level。 |
| Security | 僅 editor 可 Save/Finished；AO/CR 欄位必須依 role 控制。 |
| Data integrity | Save 必須 transaction 化；summary/checkpoint 不可與 scorecard 資料不同步。 |
| Audit | query 與 save 需保留 audit 行為；save 需記錄為 Edit/Table。 |
| Compatibility | 新系統若沿用 DB，需保留 `TB_CORP_SCRCARD` 與 legacy 欄位命名。 |
| Observability | 錯誤 log 應包含 action 與 application no，不應記錄完整 scorecard payload。 |
| Maintainability | scorecard 參數應由資料表驅動，不應硬編 option label 或 score range。 |

## 10. 驗收條件與測試案例

### 10.1 UAT / SIT 驗收條件

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-001 | `EPROC0_0118` 一般案件且 AO 有權限 | 開啟本頁 | AO 欄位可編輯，CR 欄位 disabled |
| AC-002 | `EPROC0_0218` 續約/變更案件且 CR 有權限 | 開啟本頁 | CR 欄位與 comment 可編輯，AO 欄位 disabled |
| AC-003 | 有效申請日 | 初始化 | 17 個 select options 依申請日載入 |
| AC-004 | 填完整非 default 評分欄位 | Rate | 顯示 total score、risk level、date |
| AC-005 | Rate 後異動欄位 | 畫面 change | risk level/date 被清空 |
| AC-006 | Loan Default = Yes | Save | risk level 為 Default，score 為 -1 |
| AC-007 | CR Finished | Save 成功 | `CR_SCORE_CARD_COMPLETED` 第一碼為 `Y` |
| AC-008 | Save 失敗 | 查 DB | scorecard、summary、checkpoint 不得部分更新 |
| AC-009 | Finished 且所有 tab 完成 | 儲存成功 | 父頁 frame 顯示 done |

### 10.2 SIT 測試案例

| Test Case ID | 測試類型 | 測試資料/步驟 | 預期結果 |
| --- | --- | --- | --- |
| TC-001 | Positive | AO role `001` 在 `EPROC0_0118` 填完 23 項、Rate、Finished | AO 欄位寫入，checkpoint `EPROC0_0118 = N` |
| TC-002 | Positive | CR role `102` 在 `EPROC0_0218` 填完 23 項與 comment、Rate、Finished | CR 欄位寫入，checkpoint `EPROC0_0218 = N` |
| TC-003 | Positive | AO 非 default Save | `TB_CORP_SCRCARD.AO_SCORE = totalScore`，CR score/risk/date 清空或維持 source 規則 |
| TC-004 | Positive | CR 非 default Finished，原 `CR_SCORE_CARD_COMPLETED = NY` | 更新為 `YY` |
| TC-005 | Positive | CR Save，原 `CR_SCORE_CARD_COMPLETED = YY` | 更新為 `NY` |
| TC-006 | Default | AO 選 Loan Default = Yes 後 Save | AO/CR risk level 依 source 設為 Default，score = -1 |
| TC-007 | Default | CR 選 Loan Default = Yes 後 Save | CR risk level Default，CR score = -1 |
| TC-008 | Negative | `APPLICATION_NO` 空白呼叫 query/save | 回傳 `COMMON_MSG_ERROR_LON` |
| TC-009 | Negative | 未選 default flag 直接 Save | 回傳 `EPROI00118_MSG_ERROR_FLG` |
| TC-010 | Negative | 非 default 但未 Rate 按 Finished | 前端以 `COMMON_MSG_RATE` 阻擋 |
| TC-011 | Boundary | numeric input 等於某 range `UP_RANGE` | 應不落在該 range，依下一 range 或無資料處理 |
| TC-012 | Boundary | `CUR_RATIO = 80` | DB 儲存 `0.80`，查詢畫面顯示 `80` |
| TC-013 | Linkage | `MAX_OVERDUE_CODE = 01` | `TRANS_12MON_CODE` 自動設 `01` 並 disabled |
| TC-014 | Linkage | `TRANS_12MON_CODE = 05` | `MAX_OVERDUE_CODE` 自動設 `07` 並 disabled |
| TC-015 | Transaction | 模擬 summary update 失敗 | `TB_CORP_SCRCARD` update/insert rollback |
| TC-016 | Authorization | role 非 AO/CR/editor 開啟 | scorecard 欄位 disabled，不可 Save |
| TC-017 | Cross-module | Corporate scorecard Finished 後進父頁 | 父頁依 `isAllTabsCheck` 更新 done |
| TC-018 | Cross-module | AO 重新 Save 已完成案件 | `CR_SCORE_CARD_COMPLETED` 被重設 `NN`，父頁完成狀態需重新檢核 |

### 10.3 DB 驗證建議

| 驗證點 | 查核方式 |
| --- | --- |
| scorecard 主資料 | 以 `APPLICATION_NO` 查 `TB_CORP_SCRCARD` |
| AO/CR 分數 | 比對 `AO_SCORE`、`CR_SCORE` 與前端 total score |
| Default | 確認 `*_RISK_LEVEL = Default` 且 `*_SCORE = -1` |
| CUR_RATIO | 確認 DB 值為畫面百分比除以 100 |
| summary | 查 `TB_LON_SUMMARY_INFO.CR_SCORE_CARD_COMPLETED` |
| checkpoint | 依流程查 CORP/CU 或 RC_CORP/RC_CU checkpoint |
| 參數版本 | 以申請日查 `TB_SCORE_CARD_PARAM_DETAIL` 版本 |

## 11. 附件與決策紀錄

### 11.1 Source 檢核清單

| 檢核項 | 狀態 | 備註 |
| --- | --- | --- |
| Transaction | 已檢核 | `EPROC0_0118.java`, `EPROC0_0218.java` |
| Module | 已檢核 | `EPROC0_0118_mod.java`, `EPROC0_0218_mod.java`, `EPRO_C00113.java` |
| JSP/JS | 已檢核 | `EPROC00118.jsp`, `EPROC00118_JS.jsp`, `EPROC00218.jsp`, `EPROC00218_JS.jsp` |
| DAO | 已檢核 | `EPRO_TB_CORP_SCRCARD`, `EPRO_TB_SCORE_CARD_PARAM_DETAIL` |
| SQL | 已檢核 | scorecard find/insert/update、param find range |
| Parent page | 已檢核 | `EPROC0_0110`, `EPROC0_0210` |
| Cross-scorecard | 已檢核 | `EPROC0_0114_mod`, `EPROC0_0214_mod` 的 `CR_SCORE_CARD_COMPLETED` 第二碼 |
| Code table data | 未取得 | 需 DB seed 或參數匯出確認正式 option/range |

### 11.2 決策紀錄

| Decision ID | 議題 | 決策 | 狀態 |
| --- | --- | --- | --- |
| DEC-001 | `EPROC0_0118` 與 `EPROC0_0218` 是否合併 PRD | 合併為 `EPROC00118`，以流程差異表標示差異 | Draft |
| DEC-002 | Default 是否直接設定 CR Default | 依 legacy source 記錄，待 PM/風控確認 | Open |
| DEC-003 | 後端是否補強 required/rate/comment validation | 待 SA/RD 決策 | Open |
| DEC-004 | `CR_SCORE_CARD_COMPLETED` 兩碼語意 | 待 PM/SA 確認後固定於新系統規格 | Open |

### 11.3 附件：主要欄位 prefix 規則

| Prefix | 說明 |
| --- | --- |
| `AO_` | AO 欄位、score、risk、date、employee |
| `CR_` | Credit Reviewer / Credit Manager 欄位、score、risk、date、employee、comment |
| `_CODE` | option code 或 numeric range code |
| `_SCR` | 對應 score |
| `_RISK_LEVEL` | risk level 顯示值 |
| `_DATE` | rating date |

### 11.4 附件：舊系統與新系統實作注意事項

- 新系統若沿用 legacy DB，請保留 `TB_CORP_SCRCARD` 欄位與 `TB_SCORE_CARD_PARAM_DETAIL` 參數模型。
- Scorecard 參數不可硬編；需依 `APPLICATION_DATE` 取參數版本。
- AO 儲存重設 CR 完成狀態與 AO-to-CR copy 是 source-confirmed 行為，但會影響 CR 後續工作，需納入 UAT。
- `CR_SCORE_CARD_COMPLETED` 同時被 corporate scorecard 與 personal/collateral scorecard 更新，SIT 必須串測 `EPROC00118` 與 `EPROC00114/00214`。
- Save 與 Finished 的 `check` 值語意需在新系統 API 文件中明確標示，避免前端誤用。
