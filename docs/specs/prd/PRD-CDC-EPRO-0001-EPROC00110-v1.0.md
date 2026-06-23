台中資訊開發中心

# 業務需求導向的功能規格書

CDC-EPRO-EPROC00110 Credit Investigation Corporate Frame 業務需求導向的功能規格書

版本：1.0  
更新日期：2026/06/15  
文件狀態：Draft for PM / SA / RD / QA review  
主系統鏈：E-Proposal 企金徵信、公司戶評分資料、頁籤 checkpoint、一般案件 / 展延變更案件  
強化重點：C0 頁框控制、GI/FI business type 切換、子頁 checkpoint、資料清除邊界、一般件與展延件差異

| 文件角色 | PM / SA / RD / QA 共同審閱的業務需求導向功能規格書 |
| --- | --- |
| 功能代碼 | `EPROC00110` |
| 功能名稱 | Credit Investigation Corporate Frame |
| 本次指定來源 | `EPROC0_0110`、`EPROC0_0210` |
| Source confirmed 範圍 | `EPROC0_0110`、`EPROC0_0210` 的 legacy trx/module/JSP/DAO usage；本功能無專屬 SQL file。 |
| 範圍定位 | C0 公司戶徵信/評分資料頁框，負責載入子頁、控制 GI/FI 切換、讀寫 summary assessment/business type、重設子頁 checkpoint 與清除受影響子頁資料。 |
| 輸出檔名 | `CDC-EPRO-EPROC00110_PRD_v1.0.md` / `CDC-EPRO-EPROC00110_PRD_v1.0.docx` |

## 文件控制

### 修訂紀錄

| 日期 | 版本 | 說明 | 作者 |
| --- | --- | --- | --- |
| 2026/06/15 | 1.0 | 依 `EPROC0_0110` 與 `EPROC0_0210` legacy source 建立 EPROC00110 PRD。 | AI Agent |

### 文件 Review 紀錄

| 角色 | 審閱重點 |
| --- | --- |
| PM | 確認 EPROC00110 是否作為一般件與展延/變更件的公司戶徵信/評分資料頁框整併規格。 |
| SA | 確認 GI/FI 切換時需清除的子頁資料、checkpoint 重設規則、舊案與查詢模式限制。 |
| RD | 確認新系統 page frame / tab state / checkpoint / transaction / child module reload 的 API 設計。 |
| QA | 依一般件、展延件、CS/CU、有擔/無擔、GI/FI 切換與 rollback 情境設計 SIT/UAT。 |

### 待確認項目

| ID | 待確認項目 | 影響範圍 | 建議處理 |
| --- | --- | --- | --- |
| TBD-001 | `EPROC0_0210_mod.getChangeCheck` 支援 `ASSESSMENT_TYPE=1` 時啟用 `EPROC0_0211`、`EPROC0_0213`，但 `EPROC00210.jsp` 主畫面只看到 GI/FI business type tab 組合，未看到 personal assessment type 切換 UI。 | 展延件是否需支援個人/企業 assessment type 切換。 | SA/RD 確認 0211/0213 是否由其他入口使用；新版不可在未確認前暴露個人型態切換。 |
| TBD-002 | JSP AJAX payload 使用 `${APPLICATION_NO}`，畫面顯示使用 `${attrMap.APPLICATION_NO}`；transaction 未直接 `addOutputData("APPLICATION_NO", ...)`。 | `getPage`、child page frame info 是否可穩定取得 application no。 | RD 確認 framework 是否自動帶入 request attribute；若無，應改為使用 `attrMap.APPLICATION_NO`。 |
| TBD-003 | 0210 transaction catch `ErrorInputException` 後未設定 return message。 | 0210 初始錯誤回饋。 | 列為 legacy defect suspect；新版需補標準錯誤處理。 |
| TBD-004 | 0210 JSP `_funcName` 使用 `EPROC0_0110_FUNC_NAME`，fieldset legend 使用 `EPROI0_0110_FUNC_NAME`；0110 也混用 `EPROI0_0110_FUNC_NAME`。 | 畫面標題、多語系 key ownership。 | SA/RD 確認 C0 與 I0 是否共用文案 key，避免新版顯示錯誤。 |
| TBD-005 | Business Type `G` / `F` 的正式中文名稱由 i18n key 決定，本次未找到 properties 來源。 | UI 文案與測試案例名稱。 | SA 補正式顯示文字；本文依 JSP 註解標示 GI / FI。 |
| TBD-006 | 切換 GI/FI 時會刪除多張財務與 scorecard 資料，legacy 只以前端 confirm 提醒。 | 使用者資料遺失風險。 | 新版應強化提示文字與 server-side confirmation token。 |

### 目錄

1. 需求概述  
2. 業務流程  
3. 需求清單與追蹤矩陣  
4. 功能需求  
5. API / Interface 規格  
6. 資料規格與 Mapping  
7. 業務規則  
8. 錯誤處理  
9. 非功能需求  
10. 驗收標準與測試案例  
11. 附件與決策紀錄

## 1. 需求概述

### 1.1 需求背景

`EPROC00110` 是企金 C0 徵信/評分資料的頁框規格，legacy 由 `EPROC0_0110` 支援一般案件，由 `EPROC0_0210` 支援展延/變更案件。此頁框本身不承載完整資料輸入，而是依案件 summary 的 `ASSESSMENT_TYPE`、`BUSINESS_TYPE`、`LON_ATTRIBUTE`、`SECURE_ATTRIBUTE`、`PRODUCT_CODE`、`LON_TYPE_CODE` 決定顯示哪些子頁籤，並負責在使用者切換 GI / FI business type 時清除受影響子頁資料與重設 checkpoint。

本版只將頁框 source 直接確認的行為寫為需求；各子頁如 Borrower Group Exposure、CBC、Financial Statement、Financial Evaluation、Corporate Scorecard、Collateral Scorecard 的欄位與保存規則，應由各子頁功能 PRD 承接。

### 1.2 業務目標

| 目標 | 說明 | 成功標準 |
| --- | --- | --- |
| GOAL-001 | 提供公司戶徵信/評分資料頁框。 | 使用者可從同一入口依案件型態進入應填子頁。 |
| GOAL-002 | 支援一般件與展延/變更件。 | 一般件使用 `EPROC0_0110`，展延/變更件使用 `EPROC0_0210`，但共用 GI/FI 頁框邏輯。 |
| GOAL-003 | 維持 checkpoint 與頁籤狀態一致。 | 子頁完成狀態可由 Tabs checkbox / checkpoint 反映，父頁可回寫 page menu condition。 |
| GOAL-004 | 切換 business type 時避免舊資料混用。 | GI/FI 切換後清除財報、償債能力分析與 corporate scorecard 等受影響資料。 |
| GOAL-005 | 區分 CS/CU 有擔/無擔 checkpoint 表。 | CS 使用 CORP checkpoint；CU 使用 CU checkpoint；0210 使用 RC checkpoint。 |

### 1.3 需求名稱與服務說明

| 項目 | 描述 |
| --- | --- |
| 需求名稱 | EPROC00110 Credit Investigation Corporate Frame |
| 服務說明 | 依案件屬性載入公司戶徵信/評分資料子頁，管理 GI/FI business type 與子頁 checkpoint。 |
| 適用 legacy 功能 | `EPROC0_0110` 一般件；`EPROC0_0210` 展延/變更件。 |
| 主要使用者 | AO、CR、審核相關角色；實際可編輯與可顯示由 `attrMap` 與 `EPRO_Z0Z002.isEditor` 決定。 |
| 主要資料產出 | `TB_LON_SUMMARY_INFO.ASSESSMENT_TYPE/BUSINESS_TYPE`、`TB_CHECK_POINT_CORP/CU`、`TB_CHECK_POINT_RC_CORP/CU`；切換時刪除受影響子頁資料。 |

### 1.4 本期範圍與非本期範圍

| 類別 | 描述 |
| --- | --- |
| 本期範圍 | `prompt` 載入頁框資料、角色與子頁 editor flags。 |
| 本期範圍 | `getPage` / `changePage` 切換 business type、更新 summary、清除子頁資料、重設 checkpoint。 |
| 本期範圍 | JSP tab 顯示、GI/FI radio、read-only / edit / old case 顯示控制。 |
| 本期範圍 | 一般件 `0110` 與展延/變更件 `0210` 差異。 |
| 非本期範圍 | 各子頁的完整欄位、計算、保存與報表規則。 |
| 非本期範圍 | I0 個金頁框與個金 assessment type 切換邏輯。 |

### 1.5 角色與系統職責

| 角色 / 系統 | 職責 |
| --- | --- |
| 使用者 | 進入 C0 頁框、檢視目前 business type、必要時切換 GI/FI、進入各子頁完成資料。 |
| EPROC00110 前端 | 建立 tab list、控制 checkbox、呼叫子頁 init/ajaxPost、提供 `getPageObj` 與 `getPageFrameInfo` 給子頁。 |
| EPROC00110 後端 | 載入案件 assessment/business type、判定 CS/CU、讀寫 checkpoint、切換頁籤時清除資料。 |
| 子頁功能 | 保存各子頁資料，並透過頁框 `check(pageName, isCheck)` 更新 tab checkbox。 |
| Page menu / checkpoint 共用服務 | 根據子頁完成狀態決定父頁是否完成與 page menu 是否可進入。 |

## 2. 業務流程

### 2.1 End-to-End 流程總覽

1. 使用者從 E-Proposal 案件流程進入 `EPROC0_0110` 或 `EPROC0_0210`。
2. 後端取得 `attrMap`、role、editor flags 與 `dataMap`。
3. 若案件 summary 尚無 `ASSESSMENT_TYPE` 與 `BUSINESS_TYPE`，系統預設為 `ASSESSMENT_TYPE=2`、`BUSINESS_TYPE=G`，並初始化相關 checkpoint。
4. 前端依 `BUSINESS_TYPE` 組成 tab list：GI 顯示 GI 財報/分析；FI 顯示 FI 財報/分析。
5. 使用者點選 tab 時，第一次呼叫子頁 `initApp`，之後呼叫子頁 `ajaxPost`。
6. 使用者切換 GI/FI 時，前端要求確認；確認後呼叫 `getPage`，後端清除受影響資料、更新 summary 與 checkpoint，再重新載入頁框。

### 2.2 正常流程

| 步驟 | Actor | 系統行為 |
| --- | --- | --- |
| 1 | 使用者 | 開啟 `EPROC0_0110` 或 `EPROC0_0210`。 |
| 2 | 後端 | 呼叫 `EPRO_Z0Z006.getAttribute` 取得權限與案件 context。 |
| 3 | 後端 | 呼叫 module `initQuery(APPLICATION_NO)` 載入 summary 與 checkpoint。 |
| 4 | 前端 | 顯示 application no、business type radio、子頁 tabs。 |
| 5 | 使用者 | 點選子頁 tab，進入資料維護。 |
| 6 | 子頁 | 完成或未完成時呼叫父頁 `check` 更新 checkbox 狀態。 |
| 7 | 使用者 | 若需改 GI/FI，點選 business type radio 並確認。 |
| 8 | 後端 | 執行 `changePage` 清除資料、更新 summary、重設 checkpoint。 |

### 2.3 例外流程

| 情境 | 系統反應 |
| --- | --- |
| `APPLICATION_NO` 對應 summary 查無資料 | `prompt` 或 `getPage` 回傳初始/查詢失敗或 `MSG_DATA_NOT_FOUND`。 |
| 切換 GI/FI 使用者取消 confirm | 不呼叫後端；radio 還原為原 business type。 |
| `getPage` DB 異動失敗 | transaction rollback，回傳 `MSG_QUERY_FAIL` 或 module error。 |
| 無編輯權限或舊案模式 | radio disable，不顯示 checkbox 或不允許切換。 |
| 0210 初始捕捉 `ErrorInputException` | legacy 未設定 return message，見 TBD-003。 |

### 2.4 決策點

| 決策點 | 規則 |
| --- | --- |
| 一般件 / 展延變更件 | `EPROC0_0110` 使用一般 checkpoint；`EPROC0_0210` 使用 RC checkpoint。 |
| CS / CU | 以 `LON_ATTRIBUTE + SECURE_ATTRIBUTE == CS` 判定企金有擔；否則使用 CU checkpoint。 |
| Default type | summary 的 `ASSESSMENT_TYPE` 與 `BUSINESS_TYPE` 同時空白時，預設 `ASSESSMENT_TYPE=2`、`BUSINESS_TYPE=G`。 |
| GI / FI tabs | `BUSINESS_TYPE=G` 顯示 GI 財報與 GI 償債能力分析；`BUSINESS_TYPE=F` 顯示 FI 財報與 FI 償債能力分析。 |
| 舊案模式 | `attrMap.isOld` 時不顯示 Corporate Scorecard / Collateral Scorecard，0210 也不顯示 tab checkbox。 |
| CS 有擔 | 非舊案且 `attrMap.isCS` 時顯示 Collateral Scorecard tab。 |

## 3. 需求清單與追蹤矩陣

| Requirement ID | 功能名稱 | 優先度 | 狀態 | 對應章節 |
| --- | --- | --- | --- | --- |
| FR-001 | 開啟 C0 頁框 | Must | Source confirmed | 4.1 |
| FR-002 | 初始化 assessment/business type | Must | Source confirmed | 4.2 |
| FR-003 | 顯示 GI/FI business type 控制 | Must | Source confirmed | 4.3 |
| FR-004 | 依 business type 顯示子頁 tabs | Must | Source confirmed | 4.4 |
| FR-005 | 管理 tab checkbox / checkpoint | Must | Source confirmed | 4.5 |
| FR-006 | 切換 GI/FI 並清除受影響資料 | Must | Source confirmed | 4.6 |
| FR-007 | 支援一般件與展延/變更件差異 | Must | Source confirmed | 4.7 |
| FR-008 | 控制 edit/query/old case 權限 | Must | Source confirmed | 4.8 |
| FR-009 | 提供子頁共用 context | Should | Source confirmed | 4.9 |
| FR-010 | 跨模組 page menu 完成狀態 | Should | Cross-module confirmed | 4.10 |

### 3.1 需求完整性標準

| 標準 | 判斷方式 |
| --- | --- |
| Source confirmed | 直接來自 `EPROC0_0110/0210` transaction、module、JSP、DAO field。 |
| Cross-module confirmed | 來自 `EPRO_Z0Z006`、`EPROCS_*`、`EPROCU_*` 對 C0 checkpoint / page menu 的使用。 |
| Inferred | 由頁框與子頁互動推論，會明確標示。 |
| TBD | UI/文案/隱含框架行為無法由本次 source 完整確認。 |
| Legacy defect suspect | source 行為疑似缺漏或不一致，不直接作為新版需求。 |

## 4. 功能需求

### 4.1 FR-001 開啟 C0 頁框

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | FR-001 |
| 功能名稱 | 開啟 C0 頁框 |
| 需求描述 | 系統須依案件類型開啟公司戶徵信/評分資料頁框。 |
| Trigger | 使用者進入 `prompt` action。 |
| Actor | AO / CR / 授信相關角色。 |
| 前置條件 | 案件已存在於 `TB_LON_SUMMARY_INFO`。 |
| 後置結果 | 顯示 `EPROC00110.jsp` 或 `EPROC00210.jsp`。 |

處理邏輯：

- `EPROC0_0110.prompt` 導向 `/cathaybk/system/epro/c0/EPROC0_0100/EPROC00110.jsp`。
- `EPROC0_0210.prompt` 導向 `/cathaybk/system/epro/c0/EPROC0_0200/EPROC00210.jsp`。
- 後端輸出 `attrMap`、`role`、`isAO`、各子頁 `isEditor*` flags、`isShow`、`dataMap`、`CVer`。
- 0210 額外輸出 `isCR`。

驗收標準：

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-001 | 一般件有效 `APPLICATION_NO` | 開啟 `EPROC0_0110` | 顯示 EPROC00110 頁框與對應子頁 tabs。 |
| AC-002 | 展延/變更件有效 `APPLICATION_NO` | 開啟 `EPROC0_0210` | 顯示 EPROC00210 頁框與對應子頁 tabs。 |

### 4.2 FR-002 初始化 assessment/business type

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | FR-002 |
| 功能名稱 | 初始化 assessment/business type |
| 需求描述 | 系統須從 summary 載入 `ASSESSMENT_TYPE`、`BUSINESS_TYPE`，若兩者皆空則設定預設值。 |
| Trigger | `prompt` 呼叫 module `initQuery`。 |
| Actor | 系統。 |
| 前置條件 | `APPLICATION_NO` 有效。 |
| 後置結果 | `dataMap` 具有 assessment/business type 與 checkpoint map。 |

處理邏輯：

- 查詢 `TB_LON_SUMMARY_INFO` 欄位：`ASSESSMENT_TYPE`、`BUSINESS_TYPE`、`LON_ATTRIBUTE`、`SECURE_ATTRIBUTE`、`PRODUCT_CODE`、`LON_TYPE_CODE`。
- 若 `ASSESSMENT_TYPE` 與 `BUSINESS_TYPE` 都空白，設定 `ASSESSMENT_TYPE=2`、`BUSINESS_TYPE=G`。
- 初始化時同時更新 checkpoint：一般件寫 `TB_CHECK_POINT_CORP/CU`；展延件寫 `TB_CHECK_POINT_RC_CORP/CU`。
- `LON_ATTRIBUTE + SECURE_ATTRIBUTE == CS` 時使用 CORP checkpoint，否則使用 CU checkpoint。

Data impact：

| 表格 | 異動 |
| --- | --- |
| `TB_LON_SUMMARY_INFO` | 初始空白時 update `ASSESSMENT_TYPE=2`、`BUSINESS_TYPE=G`。 |
| `TB_CHECK_POINT_CORP` / `TB_CHECK_POINT_CU` | 0110 初始化 checkpoint。 |
| `TB_CHECK_POINT_RC_CORP` / `TB_CHECK_POINT_RC_CU` | 0210 初始化 checkpoint。 |

### 4.3 FR-003 顯示 GI/FI business type 控制

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | FR-003 |
| 功能名稱 | 顯示 GI/FI business type 控制 |
| 需求描述 | 頁框須顯示 business type radio，讓可編輯使用者選擇 General Industry 或 Financial Industry。 |
| Trigger | JSP initApp。 |
| Actor | 使用者。 |
| 前置條件 | `dataMap.BUSINESS_TYPE` 已載入。 |
| 後置結果 | `busGi` 或 `busFi` 依目前值 checked。 |

處理邏輯：

- `BUSINESS_TYPE=G` 時選取 `busGi`。
- `BUSINESS_TYPE=F` 時選取 `busFi`。
- 無編輯權限時 radio disabled。
- 0110 只判斷 `attrMap.isEdit`；0210 要求 `attrMap.isEdit && !attrMap.isOld` 才提供 checkbox/check function。

### 4.4 FR-004 依 business type 顯示子頁 tabs

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | FR-004 |
| 功能名稱 | 依 business type 顯示子頁 tabs |
| 需求描述 | 系統須依 GI/FI 與 CS/old case 條件顯示對應子頁。 |
| Trigger | JSP `tabFun()`。 |
| Actor | 系統。 |
| 前置條件 | `BUSINESS_TYPE`、`attrMap.isOld`、`attrMap.isCS` 已載入。 |
| 後置結果 | 顯示正確 tab list，第一次點擊子頁時才 init。 |

子頁組合：

| 範圍 | Business Type | 顯示子頁 |
| --- | --- | --- |
| 0110 / 0210 | `G` | Borrower Group Exposure、CBC、Financial Statement GI、Financial Evaluation GI；非舊案另顯示 Corporate Scorecard；非舊案且 CS 顯示 Collateral Scorecard。 |
| 0110 / 0210 | `F` | Borrower Group Exposure、CBC、Financial Statement FI、Financial Evaluation FI；非舊案另顯示 Corporate Scorecard；非舊案且 CS 顯示 Collateral Scorecard。 |

Tab 對應：

| 一般件 0110 | 展延件 0210 | 子頁說明 |
| --- | --- | --- |
| `EPROC0_0115` | `EPROC0_0215` | Borrower Group Exposure |
| `EPROC0_0112` | `EPROC0_0212` | CBC |
| `EPROC0_0116` | `EPROC0_0216` | Financial Statement GI |
| `EPROC0_0117` | `EPROC0_0217` | Financial Evaluation GI |
| `EPROC0_0119` | `EPROC0_0219` | Financial Statement FI |
| `EPROC0_0120` | `EPROC0_0220` | Financial Evaluation FI |
| `EPROC0_0118` | `EPROC0_0218` | Corporate Scorecard |
| `EPROC0_0114` | `EPROC0_0214` | Collateral Scorecard，CS only |

### 4.5 FR-005 管理 tab checkbox / checkpoint

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | FR-005 |
| 功能名稱 | 管理 tab checkbox / checkpoint |
| 需求描述 | 可編輯頁框須依 checkpoint 顯示子頁是否完成，並提供子頁更新 checkbox 狀態。 |
| Trigger | 頁框初始化或子頁保存後呼叫父頁 `check`。 |
| Actor | 系統 / 子頁。 |
| 前置條件 | checkpoint map 已讀取。 |
| 後置結果 | tab checkbox 與 checkpoint 狀態一致。 |

處理邏輯：

- `initQuery` 回傳 `updateCheckMap`。
- 前端若可編輯，呼叫 `_tabs.setCheckboxStatus(pageName, updateCheckMap[pageName] == 'N')`。
- 子頁可呼叫父頁 `check(pageName, isCheck)`，父頁以 `isCheck == 'N'` 設定 checkbox status。
- `getPageObj` 提供 `LON_ATTRIBUTE`、`SECURE_ATTRIBUTE`、`PRODUCT_CODE`、`LON_TYPE_CODE`，供子頁呼叫 `EPRO_Z0Z006.getTabsCheckPage` 判定頁框下子頁清單。

### 4.6 FR-006 切換 GI/FI 並清除受影響資料

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | FR-006 |
| 功能名稱 | 切換 GI/FI 並清除受影響資料 |
| 需求描述 | 使用者切換 business type 並確認後，系統須清除不再適用的財報、償債能力分析與 scorecard 資料，並重設 checkpoint。 |
| Trigger | 使用者變更 `BUSINESS_TYPE` radio 並確認。 |
| Actor | 可編輯使用者。 |
| 前置條件 | 使用者同意切換提示。 |
| 後置結果 | Summary business type 更新，受影響資料清除，頁框重新載入。 |

處理邏輯：

- 前端顯示 `EPROI00110_UI_CHANGE_PAGE` confirm。
- 使用者確認後呼叫 `getPage`，傳入 `APPLICATION_NO`、`ASSESSMENT_TYPE`、`BUSINESS_TYPE`。
- 後端 transaction 中刪除以下資料：
  - `TB_FINANCIAL_EVALUATION_GI`
  - `TB_FINANCIAL_EVALUATION_FI`
  - `TB_FIN_STATEMENT_MAIN`
  - `TB_FIN_STATEMENT_BALANCE_GI`
  - `TB_FIN_STATEMENT_CASHFLOW_GI`
  - `TB_FIN_STATEMENT_INCOME_GI`
  - `TB_FIN_STATEMENT_BALANCE_FI`
  - `TB_FIN_STATEMENT_CASHFLOW_FI`
  - `TB_FIN_STATEMENT_INCOME_FI`
  - `TB_CORP_SCRCARD`
- 更新 `TB_LON_SUMMARY_INFO.ASSESSMENT_TYPE/BUSINESS_TYPE`。
- 依 GI/FI 重設 checkpoint：
  - 一般件 `G`：`0116`、`0117`、`0118` = `Y`；`0119`、`0120` = `N`。
  - 一般件 `F`：`0119`、`0120`、`0118` = `Y`；`0116`、`0117` = `N`。
  - 展延件 `G`：`0216`、`0217`、`0218` = `Y`；其他變動頁籤 = `N`。
  - 展延件 `F`：`0219`、`0220`、`0218` = `Y`；其他變動頁籤 = `N`。

### 4.7 FR-007 支援一般件與展延/變更件差異

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | FR-007 |
| 功能名稱 | 支援一般件與展延/變更件差異 |
| 需求描述 | 系統須以同一業務頁框概念支援一般案件與展延/變更案件，但使用不同子頁代號與 checkpoint table。 |
| Trigger | 使用者依流程入口進入 0110 或 0210。 |
| Actor | 系統。 |
| 前置條件 | 已知案件流程類型。 |
| 後置結果 | 使用正確 JSP、child tabs 與 checkpoint table。 |

差異：

| 項目 | 一般件 `EPROC0_0110` | 展延/變更件 `EPROC0_0210` |
| --- | --- | --- |
| JSP | `EPROC00110.jsp` | `EPROC00210.jsp` |
| Checkpoint | `TB_CHECK_POINT_CORP` / `TB_CHECK_POINT_CU` | `TB_CHECK_POINT_RC_CORP` / `TB_CHECK_POINT_RC_CU` |
| 子頁代號 | `0112/0114/0115/0116/0117/0118/0119/0120` | `0212/0214/0215/0216/0217/0218/0219/0220` |
| 角色輸出 | `isAO`、`isEditor111~120` | `isAO`、`isCR`、`isEditor211~220` |

### 4.8 FR-008 控制 edit/query/old case 權限

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | FR-008 |
| 功能名稱 | 控制 edit/query/old case 權限 |
| 需求描述 | 系統須依 `attrMap` 與 role 控制頁框是否可編輯、是否顯示 checkbox、是否顯示 scorecard 子頁。 |
| Trigger | `prompt` 與 JSP render。 |
| Actor | 系統。 |
| 前置條件 | `attrMap` 已載入。 |
| 後置結果 | 無權限使用者只能檢視允許內容。 |

處理邏輯：

- `attrMap.isEdit=false` 時，GI/FI radio disabled，tabs 不顯示 checkbox。
- 0210 在 `attrMap.isOld=true` 時，即使可編輯也不啟用 checkbox。
- `attrMap.isOld=true` 時不顯示 Corporate Scorecard 與 Collateral Scorecard。
- 非舊案且 `attrMap.isCS=true` 時顯示 Collateral Scorecard。
- 子頁 editor flags 由 `EPRO_Z0Z002.isEditor(functionId, role)` 輸出。

### 4.9 FR-009 提供子頁共用 context

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | FR-009 |
| 功能名稱 | 提供子頁共用 context |
| 需求描述 | 頁框須提供子頁共用案件 context 與 page frame info。 |
| Trigger | 子頁 JS 需要共用 context。 |
| Actor | 子頁。 |
| 前置條件 | 頁框已初始化。 |
| 後置結果 | 子頁可取得 page frame id、application no 與 page-check context。 |

處理邏輯：

- `getPageObj()` 回傳 `LON_ATTRIBUTE`、`SECURE_ATTRIBUTE`、`PRODUCT_CODE`、`LON_TYPE_CODE`。
- `getPageFrameInfo()` 回傳 `_funcId` 與 `APPLICATION_NO`。
- `focus(id)` 允許子頁完成後切換到下一頁並更新 checkbox。
- `tabsClickEvent` 第一次點擊子頁時執行 `initApp`，後續點擊呼叫 `ajaxPost`。

### 4.10 FR-010 跨模組 page menu 完成狀態

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | FR-010 |
| 功能名稱 | 跨模組 page menu 完成狀態 |
| 需求描述 | 子頁保存後，CS/CU 模組會依 C0 子頁完成狀態更新父頁 page menu condition。 |
| Trigger | CS/CU 主 borrower / co-borrower / guarantor 等頁面保存。 |
| Actor | 系統。 |
| 前置條件 | 子頁已保存並回傳 checkpoint。 |
| 後置結果 | `EPROC0_0110` 或 `EPROC0_0210` page menu 狀態可反映 C0 徵信/評分資料是否完成。 |

Cross-module confirmed：

- `EPROCS_0110/0120/0130`、`EPROCU_0110/0120/0130` 會設定 `pageMenuCondition.put("EPROC0_0110", isCreditFinished)`。
- `EPROCS_0210/0220/0230`、`EPROCU_0210/0220/0230` 會設定 `pageMenuCondition.put("EPROC0_0210", isCreditFinished)`。
- `EPRO_Z0Z006` 依 `CR_SCORE_CARD_COMPLETED` 與角色判斷 C0 頁面在 page menu 中是否可進入。

## 5. API / Interface 規格

### 5.1 API 清單

| Action | Legacy Endpoint | Method Type | 說明 |
| --- | --- | --- | --- |
| `prompt` | `/EPROC0_0110/prompt` | Submit | 開啟一般件公司戶徵信/評分資料頁框。 |
| `prompt` | `/EPROC0_0210/prompt` | Submit | 開啟展延/變更件公司戶徵信/評分資料頁框。 |
| `getPage` | `/EPROC0_0110/getPage` | AJAX | 一般件切換 GI/FI，清除資料並重設 checkpoint。 |
| `getPage` | `/EPROC0_0210/getPage` | AJAX | 展延/變更件切換 GI/FI，清除資料並重設 RC checkpoint。 |

### 5.2 Common Header or common request context

| Context | 說明 |
| --- | --- |
| `user.role` | 判斷 `isAO`、`isCR`、子頁 editor flags、`attrMap` 權限。 |
| `attrMap.APPLICATION_NO` | 案件主鍵；JSP 另使用 `${APPLICATION_NO}`，需確認來源。 |
| `attrMap.isEdit` | 控制是否可切換 business type、是否顯示 checkbox。 |
| `attrMap.isOld` | 控制舊案模式下是否顯示 scorecard 與 checkbox。 |
| `attrMap.isCS` | 控制 CS only Collateral Scorecard tab。 |

### 5.3 Request / Response 欄位草案

| Action | Request | Response |
| --- | --- | --- |
| `prompt` | request context / `APPLICATION_NO` | `attrMap`、`role`、`isAO`、`isCR`(0210)、`isEditor*`、`isShow`、`dataMap`、`CVer` |
| `getPage` | `APPLICATION_NO`、`ASSESSMENT_TYPE`、`BUSINESS_TYPE` | 成功時重新 submit 到 `prompt`，無業務資料 response body。 |

`dataMap` 欄位：

| 欄位 | 說明 |
| --- | --- |
| `ASSESSMENT_TYPE` | 評估類型；source 預設為 `2`。 |
| `BUSINESS_TYPE` | `G` = GI，`F` = FI。 |
| `LON_ATTRIBUTE` | 案件屬性。 |
| `SECURE_ATTRIBUTE` | 有擔/無擔屬性。 |
| `PRODUCT_CODE` | 產品代碼，提供子頁判斷 page list。 |
| `LON_TYPE_CODE` | 案件類型代碼，提供子頁判斷 page list。 |
| `updateCheckMap` | 子頁 checkpoint 狀態 map。 |

### 5.4 Common Error Response

| Error 類型 | Legacy ReturnCode / Message |
| --- | --- |
| 初始失敗 | `ReturnCode.ERROR` + `MSG_INITIAL_FAIL` |
| 查無資料 | `ReturnCode.DATA_NOT_FOUND` + `MSG_DATA_NOT_FOUND` |
| Module error | `ReturnCode.ERROR_MODULE` + module message 或 `MSG_QUERY_FAIL` |
| 筆數超限 | `ReturnCode.ERROR_MODULE` + `MSG_OVER_COUNT_LIMIT` |
| 查詢/切換失敗 | `ReturnCode.ERROR` + `MSG_QUERY_FAIL` |

### 5.5 Timeout / Retry / Idempotency

| 項目 | 規格 |
| --- | --- |
| `prompt` idempotency | 若 summary 已有 type，只讀取資料；若兩個 type 皆空，第一次會寫入預設值與 checkpoint。 |
| `getPage` idempotency | 同一 type 重送仍會重複刪除受影響子頁資料並更新 checkpoint；新版應避免無變更時重複清除。 |
| Transaction | `initQuery` 預設值寫入與 `changePage` 切換均使用 transaction。 |
| Retry | legacy 無 retry；DB 異常由 transaction rollback。 |

## 6. 資料規格與 Mapping

### 6.1 Field mapping

| 欄位 | 表格 | 說明 |
| --- | --- | --- |
| `APPLICATION_NO` | 多表 PK | 案件主鍵。 |
| `ASSESSMENT_TYPE` | `TB_LON_SUMMARY_INFO` | 評估類型；空白時預設 `2`。 |
| `BUSINESS_TYPE` | `TB_LON_SUMMARY_INFO` | `G` / `F`，決定 GI/FI tab 組合。 |
| `LON_ATTRIBUTE` | `TB_LON_SUMMARY_INFO` | 與 `SECURE_ATTRIBUTE` 組合判定 CS/CU。 |
| `SECURE_ATTRIBUTE` | `TB_LON_SUMMARY_INFO` | 與 `LON_ATTRIBUTE` 組合判定 CS/CU。 |
| `PRODUCT_CODE` | `TB_LON_SUMMARY_INFO` | 子頁 page-check context。 |
| `LON_TYPE_CODE` | `TB_LON_SUMMARY_INFO` | 子頁 page-check context。 |
| `EPROC0_0116/0117/0118/0119/0120` | `TB_CHECK_POINT_CORP/CU` | 一般件 C0 變動子頁 checkpoint。 |
| `EPROC0_0216/0217/0218/0219/0220` | `TB_CHECK_POINT_RC_CORP/CU` | 展延/變更件 C0 變動子頁 checkpoint。 |

### 6.2 Main tables / DAOs

| DAO / Table | 用途 |
| --- | --- |
| `EPRO_TB_LON_SUMMARY_INFO` / `TB_LON_SUMMARY_INFO` | 查詢與更新 assessment/business type、案件屬性。 |
| `EPRO_TB_CHECK_POINT_CORP` / `TB_CHECK_POINT_CORP` | 一般件 CS 子頁完成狀態。 |
| `EPRO_TB_CHECK_POINT_CU` / `TB_CHECK_POINT_CU` | 一般件 CU 子頁完成狀態。 |
| `EPRO_TB_CHECK_POINT_RC_CORP` / `TB_CHECK_POINT_RC_CORP` | 展延/變更件 CS 子頁完成狀態。 |
| `EPRO_TB_CHECK_POINT_RC_CU` / `TB_CHECK_POINT_RC_CU` | 展延/變更件 CU 子頁完成狀態。 |
| `EPRO_TB_FINANCIAL_EVALUATION_GI` | 切換 GI/FI 時刪除 GI 償債能力分析。 |
| `EPRO_TB_FINANCIAL_EVALUATION_FI` | 切換 GI/FI 時刪除 FI 償債能力分析。 |
| `EPRO_TB_FIN_STATEMENT_MAIN` | 切換 GI/FI 時刪除財報主檔。 |
| `EPRO_TB_FIN_STATEMENT_BALANCE_GI/FI` | 切換 GI/FI 時刪除資產負債表。 |
| `EPRO_TB_FIN_STATEMENT_CASHFLOW_GI/FI` | 切換 GI/FI 時刪除現金流量表。 |
| `EPRO_TB_FIN_STATEMENT_INCOME_GI/FI` | 切換 GI/FI 時刪除損益表。 |
| `EPRO_TB_CORP_SCRCARD` | 切換 GI/FI 時刪除 Corporate Scorecard。 |

### 6.3 SQL mapping

| SQL | 用途 |
| --- | --- |
| 專屬 SQL | 未找到 `EPROC0_0110` / `EPROC0_0210` module 專屬 SQL file。 |
| DAO SQL | 透過 DAO 內建 SQL id 查詢、更新、刪除，例如 checkpoint、summary、financial statement、scorecard DAO。 |

### 6.4 Sensitive data / masking expectations

| 資料 | 風險 | 新版要求 |
| --- | --- | --- |
| `APPLICATION_NO` | 案件識別資訊。 | log 可記錄但需遵循內部案件資訊控管。 |
| 子頁資料 | 財報、CBC、scorecard 可能含高度敏感企業/個人資料。 | 頁框切換造成刪除前需明確提示並保留 audit trail。 |
| Role / permission | 權限 flags 決定子頁可編輯。 | 新版需後端重做權限檢查，不能只依前端 disable。 |

## 7. 業務規則

| ID | 規則 | Evidence |
| --- | --- | --- |
| BR-001 | `EPROC0_0110` 為一般件 C0 公司戶徵信/評分資料頁框。 | Source confirmed |
| BR-002 | `EPROC0_0210` 為展延/變更件 C0 公司戶徵信/評分資料頁框。 | Source confirmed |
| BR-003 | summary 的 `ASSESSMENT_TYPE` 與 `BUSINESS_TYPE` 同時空白時，預設為 `2/G`。 | Source confirmed |
| BR-004 | `LON_ATTRIBUTE + SECURE_ATTRIBUTE == CS` 時使用 CORP checkpoint，否則使用 CU checkpoint。 | Source confirmed |
| BR-005 | `BUSINESS_TYPE=G` 顯示 GI 財報、GI 償債能力分析與 Corporate Scorecard。 | Source confirmed |
| BR-006 | `BUSINESS_TYPE=F` 顯示 FI 財報、FI 償債能力分析與 Corporate Scorecard。 | Source confirmed |
| BR-007 | 非舊案且 CS 時顯示 Collateral Scorecard。 | Source confirmed |
| BR-008 | 舊案不顯示 Corporate Scorecard / Collateral Scorecard。 | Source confirmed |
| BR-009 | 切換 GI/FI 必須先經前端 confirm。 | Source confirmed |
| BR-010 | 切換 GI/FI 時會刪除 GI/FI financial evaluation、financial statement 與 corporate scorecard。 | Source confirmed |
| BR-011 | 0110 一般件 GI checkpoint 啟用 `0116/0117/0118`；FI checkpoint 啟用 `0119/0120/0118`。 | Source confirmed |
| BR-012 | 0210 展延件 GI checkpoint 啟用 `0216/0217/0218`；FI checkpoint 啟用 `0219/0220/0218`。 | Source confirmed |
| BR-013 | 子頁透過父頁 `check` 更新 tab checkbox，並透過 `getPageObj` 取得 page-check context。 | Source confirmed |
| BR-014 | 0210 module 的 `ASSESSMENT_TYPE=1` 分支不可視為已確認 UI 行為。 | Legacy defect suspect / TBD |

## 8. 錯誤處理

### 8.1 Standard error/message mapping

| 情境 | Message key / 處理 |
| --- | --- |
| prompt 初始失敗 | `MSG_INITIAL_FAIL` |
| getPage 查無資料 | `MSG_DATA_NOT_FOUND` |
| getPage module error | module message 或 `MSG_QUERY_FAIL` |
| OverCountLimitException | `MSG_OVER_COUNT_LIMIT` |
| getPage 一般錯誤 | `MSG_QUERY_FAIL` + exception message |
| 0210 ErrorInputException | legacy 空 catch，無 return message，列 TBD-003。 |

### 8.2 Error handling principles

- 切換 GI/FI 會刪除資料，必須有明確可理解的使用者確認。
- server-side 不應只依前端 confirm 防止誤刪，新版應要求 confirmation token 或版本檢查。
- 任何 DB 清除、summary update、checkpoint update 失敗須 rollback。
- 0210 的空 catch 應修正為標準 error response。

## 9. 非功能需求

| 類別 | 需求 |
| --- | --- |
| Performance | prompt 應快速載入 summary 與 checkpoint；子頁第一次點擊才 init，以避免一次載入所有子頁資料。 |
| Availability | `changePage` 多表 delete/update 必須 transaction 保護。 |
| Security | 角色權限與 edit/query/old case 控制需由後端再次驗證。 |
| Audit | GI/FI 切換造成資料清除，需記錄 actor、application no、old/new business type、清除表清單。 |
| Observability | 頁框載入、切換成功/失敗、rollback 應可追蹤。 |
| Compatibility | 需保留 `BUSINESS_TYPE=G/F` 與 checkpoint `Y/N` 語意。 |
| UX | 切換 GI/FI 的提示需明確告知會刪除哪些子頁資料。 |

## 10. 驗收標準與測試案例

### 10.1 UAT / SIT 測試案例總表

| Test Case ID | 對應需求 | 測試情境 | 預期結果 |
| --- | --- | --- | --- |
| TC-001 | FR-001 | 一般件開啟 `EPROC0_0110`。 | 顯示 EPROC00110 頁框、application no、business type radio、子頁 tabs。 |
| TC-002 | FR-001 | 展延/變更件開啟 `EPROC0_0210`。 | 顯示 EPROC00210 頁框與 RC 子頁代號。 |
| TC-003 | FR-002 | Summary assessment/business type 皆空。 | 系統預設寫入 `ASSESSMENT_TYPE=2`、`BUSINESS_TYPE=G` 並初始化 checkpoint。 |
| TC-004 | FR-003 | `BUSINESS_TYPE=G`。 | `busGi` checked，顯示 GI tab group。 |
| TC-005 | FR-003 | `BUSINESS_TYPE=F`。 | `busFi` checked，顯示 FI tab group。 |
| TC-006 | FR-004 | 一般件 GI。 | 顯示 `0115/0112/0116/0117`，非舊案顯示 `0118`，CS 非舊案顯示 `0114`。 |
| TC-007 | FR-004 | 一般件 FI。 | 顯示 `0115/0112/0119/0120`，非舊案顯示 `0118`，CS 非舊案顯示 `0114`。 |
| TC-008 | FR-004 | 展延件 GI。 | 顯示 `0215/0212/0216/0217`，非舊案顯示 `0218`，CS 非舊案顯示 `0214`。 |
| TC-009 | FR-004 | 展延件 FI。 | 顯示 `0215/0212/0219/0220`，非舊案顯示 `0218`，CS 非舊案顯示 `0214`。 |
| TC-010 | FR-005 | 子頁保存後回呼父頁 `check(pageName,"N")`。 | 對應 tab checkbox 顯示完成。 |
| TC-011 | FR-006 | 從 GI 切換 FI 並確認。 | 清除 GI/FI 財報、償債能力分析、corporate scorecard；summary 更新為 FI；checkpoint 重設。 |
| TC-012 | FR-006 | 從 FI 切換 GI 但取消 confirm。 | 不呼叫 getPage，business type 維持原值。 |
| TC-013 | FR-006 | `changePage` 任一 delete 失敗。 | transaction rollback，summary 與 checkpoint 不應部分更新。 |
| TC-014 | FR-007 | CS 一般件初始化。 | 使用 `TB_CHECK_POINT_CORP`。 |
| TC-015 | FR-007 | CU 一般件初始化。 | 使用 `TB_CHECK_POINT_CU`。 |
| TC-016 | FR-007 | CS 展延件初始化。 | 使用 `TB_CHECK_POINT_RC_CORP`。 |
| TC-017 | FR-007 | CU 展延件初始化。 | 使用 `TB_CHECK_POINT_RC_CU`。 |
| TC-018 | FR-008 | 查詢模式開啟頁框。 | radio disabled，不顯示 tab checkbox。 |
| TC-019 | FR-008 | 舊案模式開啟 0210。 | 不啟用 checkbox，不顯示 scorecard tabs。 |
| TC-020 | FR-010 | CS/CU borrower 頁保存後 C0 子頁全部完成。 | page menu 中 `EPROC0_0110` 或 `EPROC0_0210` 狀態更新為完成。 |

### 10.2 驗收完成條件

| 條件 | 說明 |
| --- | --- |
| AC-DONE-001 | 0110 / 0210 prompt 皆可依 CS/CU、GI/FI、old/query/edit 模式顯示正確 tab。 |
| AC-DONE-002 | GI/FI 切換會清除 source-confirmed 受影響資料，並 transaction rollback 測試通過。 |
| AC-DONE-003 | Checkpoint `Y/N` 與 tab checkbox 顯示一致。 |
| AC-DONE-004 | Cross-module page menu 狀態在子頁完成後正確更新。 |
| AC-DONE-005 | TBD-001 至 TBD-006 已由 PM/SA/RD 決議或轉入 backlog。 |

## 11. 附件與決策紀錄

### 11.1 參考文件

| 類別 | 路徑 / 說明 |
| --- | --- |
| Legacy trx | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\JavaSource\com\cathaybk\epro\c0\trx\EPROC0_0110.java` |
| Legacy module | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\JavaSource\com\cathaybk\epro\c0\module\EPROC0_0110_mod.java` |
| Legacy JSP | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\WebContent\html\cathaybk\system\epro\c0\EPROC0_0100\EPROC00110.jsp` |
| Legacy trx | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\JavaSource\com\cathaybk\epro\c0\trx\EPROC0_0210.java` |
| Legacy module | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\JavaSource\com\cathaybk\epro\c0\module\EPROC0_0210_mod.java` |
| Legacy JSP | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\WebContent\html\cathaybk\system\epro\c0\EPROC0_0200\EPROC00210.jsp` |
| DAO | `EPRO_TB_CHECK_POINT_CORP`、`EPRO_TB_CHECK_POINT_CU`、`EPRO_TB_CHECK_POINT_RC_CORP`、`EPRO_TB_CHECK_POINT_RC_CU`、`EPRO_TB_LON_SUMMARY_INFO` |
| Cross-module | `EPRO_Z0Z006`、`EPROCS_0110/0120/0130`、`EPROCU_0110/0120/0130`、`EPROCS_0210/0220/0230`、`EPROCU_0210/0220/0230` |
| Inventory | `D:\Users\00584570\eproposal-inventory\function-inventory.csv` |

### 11.2 Decision Log

| ID | 決策 | 理由 |
| --- | --- | --- |
| DEC-001 | 本 PRD 以 `EPROC00110` 統一描述 `EPROC0_0110` 與 `EPROC0_0210`。 | 使用者指定合併產出；兩者皆為 C0 公司戶徵信/評分資料頁框。 |
| DEC-002 | 子頁欄位規則不在本 PRD 完整展開。 | 0110/0210 source 直接負責頁框與切換，子頁有各自 trx/module/JSP。 |
| DEC-003 | GI/FI 切換的資料清除列為核心需求。 | `changePage` 明確 delete 多張財報、分析與 scorecard table。 |
| DEC-004 | `ASSESSMENT_TYPE=1` 的 0210 module 分支列為 TBD。 | JSP 主頁未確認對應 UI，不能寫成已確認業務功能。 |

### 11.3 後續文件建議

| 文件 | 建議內容 |
| --- | --- |
| 子頁 PRD | 依 `EPROC0_0112/0114/0115/0116/0117/0118/0119/0120` 與 `0212/0214/0215/0216/0217/0218/0219/0220` 分別補欄位與保存規則。 |
| API Spec | 定義新系統 page frame API、tab state API、business type change API 與 confirmation token。 |
| DB Spec | 定義 checkpoint table mapping、summary type 欄位、切換時清除資料表清單與 audit log。 |
| Test Plan | 覆蓋 CS/CU、一般/展延、GI/FI、old/query/edit、rollback 與資料刪除確認。 |
