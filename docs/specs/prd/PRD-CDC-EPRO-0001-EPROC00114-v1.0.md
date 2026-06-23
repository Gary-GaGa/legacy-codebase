台中資訊開發中心

# 業務需求導向的功能規格書

# CDC-EPRO-EPROC00114 Collateral Scorecard 業務需求導向的功能規格書

版本：1.0

更新日期：2026/06/15

文件狀態：Draft for PM / SA / RD / QA review

主系統鏈：E-Proposal 企金徵信、公司戶評分資料、抵押品評分、一般案件 / 展延變更案件

強化重點：抵押品評分版本控制、AO / Credit Reviewer 雙欄評分、風險等級計算、checkpoint 與 `CR_SCORE_CARD_COMPLETED` 同步、一般案件與展延案件差異

| 文件角色 | 說明 |
| --- | --- |
| 文件目的 | 依 `EPROC0_0114` 與 `EPROC0_0214` 舊系統 Source code，整理 `EPROC00114` 抵押品評分業務需求、資料異動、介面與驗收測試。 |
| 功能代碼 | `EPROC00114` |
| 功能名稱 | Collateral Scorecard / 抵押品評分 |
| 本次指定來源 | `EPROC0_0114`、`EPROC0_0214` |
| Source confirmed 範圍 | legacy trx/module/JSP/JS/DAO/SQL usage、migration inventory、跨模組 checkpoint 與案件建立/授信條件異動引用。 |
| 輸出檔案 | `CDC-EPRO-EPROC00114_PRD_v1.0.md`、`CDC-EPRO-EPROC00114_PRD_v1.0.docx` |

## 文件審閱資訊

| 項目 | 內容 |
| --- | --- |
| 適用對象 | PM、SA、RD、QA、UAT 業務驗收人員 |
| 審閱目的 | 確認舊系統抵押品評分流程、資料欄位、完成狀態與跨模組影響，作為新系統需求與測試基準。 |
| 成功標準 | 新系統可重現舊系統已確認行為，並把疑似歷史問題列入決策，不默默修正。 |

## 名詞與縮寫

| 名詞 | 說明 |
| --- | --- |
| AO | Account Officer。來源以角色代碼 `001`、`002` 判定。 |
| CR | Credit Reviewer / Credit Manager。來源以角色代碼 `102`、`103` 判定。 |
| `CVer` | 抵押品評分表版本。由 `EPRO_IS0110.getcollassver` 依申請日查 `TB_SCORE_CARD_PARAM_DETAIL` 的 `C_Ver`，無資料時預設 `001`。 |
| `check` | 子頁完成狀態參數。舊系統 `Y` 代表尚未完成 / 暫存，`N` 代表完成。 |
| `CR_SCORE_CARD_COMPLETED` | 授信評分完成狀態字串。本功能維護第二碼，第一碼由公司戶 / 個人戶 Scorecard 相關頁籤維護。 |
| 一般案件 | 本文件對應 `EPROC0_0114`，掛載於 `EPROC0_0110` 頁框。 |
| 展延變更案件 | 本文件對應 `EPROC0_0214`，掛載於 `EPROC0_0210` 頁框。 |

## 來源掃描摘要

| 類型 | Source confirmed 檔案 / 方法 | 摘要 |
| --- | --- | --- |
| Transaction | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0114.java` | AJAX actions：`query`、`getRate`、`save`。一般案件使用。 |
| Transaction | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0214.java` | AJAX actions：`query`、`getRate`、`save`。展延變更案件使用。 |
| Module | `EPROWeb/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0114_mod.java` | 查詢抵押品評分資料、依角色儲存 AO / CR 評分、更新 `TB_COLL_ASS`、`TB_LON_SUMMARY_INFO`、`TB_CHECK_POINT_CORP`。 |
| Module | `EPROWeb/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0214_mod.java` | 同一般案件邏輯，但 checkpoint 寫入 `TB_CHECK_POINT_RC_CORP`。 |
| Shared module | `EPROWeb/JavaSource/com/cathaybk/epro/c0/module/EPRO_C00113.java` | 查詢評分參數、計算分數對應風險等級、格式化日期與 CR comment header、AO 欄位複製到 CR 欄位。 |
| Shared module | `EPROWeb/JavaSource/com/cathaybk/epro/i0/module/EPRO_I00113.java` | `EPROC0_0114.getRate` 實際引用此 I0 shared module；演算法與 C0 shared module 相同。 |
| JSP | `EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00114.jsp` | 一般案件抵押品評分畫面欄位與按鈕。 |
| JSP JS | `EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0_0100/EPROC00114_JS.jsp` | 一般案件前端初始化、下拉選單、評分、儲存與完成。 |
| JSP | `EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00214.jsp` | 展延變更案件抵押品評分畫面欄位與按鈕。 |
| JSP JS | `EPROWeb/WebContent/html/cathaybk/system/epro/c0/EPROC0_0200/EPROC00214_JS.jsp` | 展延變更案件前端初始化、下拉選單、評分、儲存與完成。 |
| Page frame | `EPROC00110.jsp`、`EPROC00210.jsp` | `!attrMap.isOld && attrMap.isCS` 時顯示 `EPROC0_0114` / `EPROC0_0214` tab，並納入頁籤完成狀態。 |
| DAO | `EPRO_TB_COLL_ASS.java` 與 SQL files | 抵押品評分主資料表 `OVSLXLON01.TB_COLL_ASS` 的查詢、insert、update、delete。 |
| DAO | `EPRO_TB_SCORE_CARD_PARAM_DETAIL.java` 與 `SQL_FIND_RANGE_001.sql` | 依 `VAR_NAME`、申請日、分數區間取得評分選項與風險等級。 |
| DAO | `EPRO_TB_CHECK_POINT_CORP.java`、`EPRO_TB_CHECK_POINT_RC_CORP.java` | 一般 / 展延公司戶 checkpoint 欄位包含 `EPROC0_0114`、`EPROC0_0214`。 |
| Cross-module | `EPROZ0_0200_mod.java` | 新建 CU 類別案件時會把 `EPROC0_0114` / `EPROC0_0214` checkpoint 預設為 `N`。 |
| Cross-module | `EPROCS_0170_mod.java`、`EPROCS_0270_mod.java` | 授信條件異動時，非 CR 流程會重設抵押品評分 checkpoint 並清除 CR 評分相關欄位。 |
| Inventory | `migration-inventory/function-inventory.csv` | `EPROC0_0114`、`EPROC0_0214` 各有 3 個 AJAX actions：`getRate`、`query`、`save`。 |

## TBD / 待確認事項

| ID | 待確認事項 | 來源依據 | 建議處理 |
| --- | --- | --- | --- |
| TBD-001 | `C_V1` 至 `C_V8`、`COL_RISK_LV` 的正式中文選項與分數區間需以資料庫 code table 匯出確認。 | Source 只確認 `TB_SCORE_CARD_PARAM_DETAIL` 讀取方式，未包含實際資料值。 | 資料轉換或 UAT 前提供正式參數資料。 |
| TBD-002 | `EPROC0_0114.getRate` 引用 `EPRO_I00113`，而 `EPROC0_0214.getRate` 引用 `EPRO_C00113`。兩者目前演算法相同，但 module 命名不一致。 | `EPROC0_0114.java` import `com.cathaybk.epro.i0.module.EPRO_I00113`；`EPROC0_0214.java` import `EPRO_C00113`。 | RD 確認新系統應採同一服務或保留 legacy 行為。 |
| TBD-003 | `EPROC00114_JS.jsp` / `EPROC00214_JS.jsp` 的 `_funcName` 使用 `EPROI0_0114_FUNC_NAME`，頁框則混用 `EPROI00114_FUNC_NAME`、`EPROC00114_FUNC_NAME`。 | JSP i18n key 不一致。 | 新系統統一文案 key 與顯示名稱；舊系統差異列為 migration mapping。 |
| TBD-004 | `EPRO_C00113.getPromptMap` 具備 CU checkpoint fallback，但頁框只有 `attrMap.isCS` 時顯示本 tab。 | Shared module 會依 `LON_ATTRIBUTE + SECURE_ATTRIBUTE` 選 CORP / CU checkpoint；page frame 只在 CS 顯示。 | PM/SA 確認 `EPROC00114` 是否只服務 CS，CU 預設 `N` 是否僅為歷史共用資料結構。 |
| TBD-005 | `TB_COLL_ASS.SQL_FIND_001.sql` 的 filter 欄位包含 `CR_ADDR_CODE` / `CR_ADDR_SCR`，與 DAO 欄位 `CR_COLL_ADDR_CODE` / `CR_COLL_ADDR_SCR` 不一致。 | SQL where clause 與 DAO 欄位不一致。 | 若新系統支援以 CR address 欄位查詢，需修正 mapping；舊功能主要以 `APPLICATION_NO` 查詢，未觀察到直接影響。 |
| TBD-006 | JS 中存在 `AO_TRA_LST_MON_CODE`、`AO_MAX_DUE_CODE`、`CR_TRA_LST_MON_CODE`、`CR_MAX_DUE_CODE` change handler，但本 JSP 沒有這些欄位。 | `EPROC00114_JS.jsp`、`EPROC00214_JS.jsp`。 | 判定為 legacy copied dead code；新系統不要移植，除非另有業務依據。 |

## 1. 需求概述

### 1.1 需求背景

`EPROC00114` 是公司戶徵信評分頁框中的抵押品評分子頁籤。舊系統拆成一般案件 `EPROC0_0114` 與展延變更案件 `EPROC0_0214`，兩者畫面欄位與行為高度一致，差異主要在父頁框、checkpoint table 與完成度查詢方法。

本功能提供 AO 與 Credit Reviewer 針對抵押品條件選擇評分項目，系統依所選項目加總分數，查詢有效日期內的風險等級，並將評分結果、評分日期、評語與完成狀態保存到案件資料。

### 1.2 需求目標

| 目標 ID | 需求目標 | 成功衡量 |
| --- | --- | --- |
| G-001 | 支援一般案件與展延變更案件的抵押品評分 | `EPROC0_0114` 與 `EPROC0_0214` 來源邏輯均被映射到新系統需求。 |
| G-002 | 支援依評分版本顯示不同抵押品評分項目 | `CVer=001` 與 `CVer=002` 的欄位組合可被重現。 |
| G-003 | 支援 AO / CR 不同角色的欄位可編輯性與儲存規則 | AO 只維護 AO 欄位；CR 維護 CR 欄位與 CR comment。 |
| G-004 | 支援風險等級計算 | 系統依 `TB_SCORE_CARD_PARAM_DETAIL` 的 score range 回傳 `level`、`scrDate`、`totalScore`。 |
| G-005 | 支援完成狀態同步 | 儲存後同步 `TB_COLL_ASS`、`TB_LON_SUMMARY_INFO.CR_SCORE_CARD_COMPLETED` 與對應 checkpoint。 |

### 1.3 需求範圍

| 範圍 | 包含 |
| --- | --- |
| 畫面 | 抵押品評分 tab、借款人名稱、AO / CR 欄位、風險等級、評分日期、CR comment、Rate / Save / Finished 按鈕。 |
| API | `query`、`getRate`、`save` 三個 AJAX action。 |
| 資料 | `TB_COLL_ASS`、`TB_LON_SUMMARY_INFO`、`TB_MAIN_BORROWER_INFO_CORP`、`TB_SCORE_CARD_PARAM_DETAIL`、公司戶 checkpoint table。 |
| 流程 | 一般案件、展延變更案件、AO 評分、CR 評分、暫存、完成、父頁框 done 狀態更新。 |
| 測試 | 正向、負向、邊界、資料副作用與跨模組重設測試。 |

### 1.4 不在本次範圍

| 項目 | 說明 |
| --- | --- |
| 實際評分參數維護 | 本文件只規格化讀取與套用方式，不新增 scorecard parameter 維護功能。 |
| `EPROC0_0110` / `EPROC0_0210` 頁框完整 PRD | 頁框只作為本子頁的掛載與 completion 來源；完整頁框規格另由 `EPROC00110` 文件處理。 |
| 歷史編碼異常註解修正 | Source comment 有多處 mojibake，本文件不把編碼異常文字當需求來源。 |
| 個人戶 I0 / IS / IU scorecard 詳細邏輯 | 僅在 shared module 差異與交叉比對時引用。 |

### 1.5 利害關係人與使用情境

| 角色 | 使用情境 | 主要權限 |
| --- | --- | --- |
| AO | 選擇抵押品評分項目、計算 AO 風險等級、暫存或完成 AO 評分。 | 編輯 AO 欄位；CR 欄位與 CR comment disabled。 |
| Credit Reviewer | 檢視 AO 評分，維護 CR 評分、CR comment、計算 CR 風險等級並完成。 | 編輯 CR 欄位與 CR comment；AO 欄位 disabled。 |
| 查詢使用者 | 檢視已保存的評分資料。 | 全部評分欄位 disabled。 |
| 系統 | 依申請日取參數、計算總分與風險等級、同步完成狀態。 | 後端資料異動與 checkpoint 更新。 |

## 2. 業務流程

### 2.1 End-to-End 流程摘要

1. 使用者進入 `EPROC0_0110` 或 `EPROC0_0210` 頁框。
2. 頁框判斷 `!attrMap.isOld && attrMap.isCS` 後顯示 `EPROC0_0114` 或 `EPROC0_0214` tab。
3. 使用者點擊抵押品評分 tab。
4. 前端呼叫 `query`，以 `APPLICATION_NO` 查詢借款人名稱、申請日、評分參數清單、既有 AO / CR 評分與 checkpoint。
5. 系統依 `CVer` 顯示 version 001 或 version 002 的評分項目。
6. AO 或 CR 選擇評分項目後按 Rate，前端送出各項 score，後端加總並查出風險等級。
7. 使用者按 Save 時送出 `check=Y`，保存資料但維持未完成狀態。
8. 使用者按 Finished 時送出 `check=N`，通過前端 required 與已 Rate 驗證後保存資料並更新完成狀態。
9. 後端回傳 `isAllTabsCheck`，前端依回傳值更新父頁框 done 樣式。

### 2.2 一般案件流程

| 步驟 | Source confirmed 行為 |
| --- | --- |
| 入口 | `EPROC00110.jsp` 在非 old case 且 `attrMap.isCS` 時加入 `EPROC0_0114` tab。 |
| 查詢 | `EPROC0_0114.doQuery` 呼叫 `EPROC0_0114_mod.query(APPLICATION_NO, user)`。 |
| 評分 | `EPROC0_0114.doGetRate` 呼叫 `EPRO_I00113.getRate(scoreMap, appDate, "COL_RISK_LV")`。 |
| 儲存 | `EPROC0_0114.doSave` 呼叫 `EPROC0_0114_mod.save(...)`。 |
| 完成度 | 儲存後以 `EPRO_Z0Z006.getTabsCheckPage(pageCheckMap, "EPROC0_0110")` 與 `getCheckedProgressCORP` 判斷父頁框是否 all tabs complete。 |
| checkpoint | 寫入 `TB_CHECK_POINT_CORP.EPROC0_0114`。 |

### 2.3 展延變更案件流程

| 步驟 | Source confirmed 行為 |
| --- | --- |
| 入口 | `EPROC00210.jsp` 在非 old case 且 `attrMap.isCS` 時加入 `EPROC0_0214` tab。 |
| 查詢 | `EPROC0_0214.doQuery` 呼叫 `EPROC0_0214_mod.query(APPLICATION_NO, user)`。 |
| 評分 | `EPROC0_0214.doGetRate` 呼叫 `EPRO_C00113.getRate(scoreMap, appDate, "COL_RISK_LV")`。 |
| 儲存 | `EPROC0_0214.doSave` 呼叫 `EPROC0_0214_mod.save(...)`。 |
| 完成度 | 儲存後以 `EPRO_Z0Z006.getTabsCheckPage(pageCheckMap, "EPROC0_0210")` 與 `getCheckedProgressRC_CORP` 判斷父頁框是否 all tabs complete。 |
| checkpoint | 寫入 `TB_CHECK_POINT_RC_CORP.EPROC0_0214`。 |

### 2.4 角色流程

| 角色 | 可執行流程 | Source confirmed 條件 |
| --- | --- | --- |
| AO | 選擇 AO 評分項目、Rate、Save、Finished。 | `role == 001 || role == 002` 且非 query mode。 |
| CR | 選擇 CR 評分項目、填寫 CR comment、Rate、Save、Finished。 | `role == 102 || role == 103` 且非 query mode。 |
| 其他角色 | 原則上只檢視。 | JS otherwise branch disable `.scorSel114/214` 與 `CR_COMMENT`。 |

## 3. 需求清單與追蹤矩陣

| Requirement ID | 功能需求 | 優先級 | 來源 | 狀態 |
| --- | --- | --- | --- | --- |
| REQ-001 | 系統應提供一般案件與展延變更案件的抵押品評分 tab。 | Must | `EPROC00110.jsp`、`EPROC00210.jsp` | Source confirmed |
| REQ-002 | 系統應依 `APPLICATION_NO` 查詢抵押品評分資料、借款人名稱、申請日與評分參數。 | Must | `EPROC0_0114_mod.query`、`EPROC0_0214_mod.query` | Source confirmed |
| REQ-003 | 系統應依 `CVer` 顯示 version 001 或 002 的評分項目。 | Must | JSP `c:if test="${CVer == '001'/'002'}"`、module `LIST_NM_ARRAY001/002` | Source confirmed |
| REQ-004 | 系統應支援 AO 與 CR 各自評分、計算風險等級與評分日期。 | Must | `*_JS.jsp`、`getRate` action | Source confirmed |
| REQ-005 | 系統應在使用者完成 Rate 後才允許 Finished。 | Must | `validSave114/214.register` | Source confirmed |
| REQ-006 | 系統應在 Save / Finished 時 upsert `TB_COLL_ASS`。 | Must | `EPRO_TB_COLL_ASS.update` 後 count 0 insert | Source confirmed |
| REQ-007 | 系統應依角色更新 `CR_SCORE_CARD_COMPLETED`。 | Must | `save` module | Source confirmed |
| REQ-008 | 系統應更新一般 / 展延公司戶 checkpoint 欄位。 | Must | `TB_CHECK_POINT_CORP`、`TB_CHECK_POINT_RC_CORP` | Source confirmed |
| REQ-009 | 系統應回傳父頁框 all tabs completion 狀態。 | Should | `EPRO_Z0Z006.getCheckedProgressCORP/RC_CORP` | Source confirmed |
| REQ-010 | 系統應保留來源確認的錯誤處理與訊息 mapping。 | Must | `doQuery`、`doGetRate`、`doSave` catch blocks | Source confirmed |
| REQ-011 | 系統應揭露 i18n key 與 shared module 差異為待確認事項。 | Should | JSP / Java import mismatch | TBD |

### 3.1 Traceability Matrix

| Requirement ID | Trx | Module | JSP / JS | DAO / SQL |
| --- | --- | --- | --- | --- |
| REQ-001 | `EPROC0_0110.prompt`、`EPROC0_0210.prompt` | `EPROC0_0110_mod`、`EPROC0_0210_mod` | `EPROC00110.jsp`、`EPROC00210.jsp` | Checkpoint DAO |
| REQ-002 | `doQuery` | `query` | `ajaxPost` | `TB_LON_SUMMARY_INFO`、`TB_MAIN_BORROWER_INFO_CORP`、`TB_COLL_ASS`、`TB_SCORE_CARD_PARAM_DETAIL` |
| REQ-003 | `doQuery` | `LIST_NM_ARRAY001/002`、`EPRO_IS0110.getcollassver` | `CVer` blocks | `TB_SCORE_CARD_PARAM_DETAIL.SQL_QUERY_002` |
| REQ-004 | `doGetRate` | `EPRO_C00113.getRate`、`EPRO_I00113.getRate` | `rateFun` | `TB_SCORE_CARD_PARAM_DETAIL.SQL_FIND_RANGE_001` |
| REQ-005 | `doSave` | `save` | `validSave114/214` | N/A |
| REQ-006 | `doSave` | `save` | `save(check)` | `TB_COLL_ASS.SQL_UPDATE_001`、`SQL_INSERT_001` |
| REQ-007 | `doSave` | `save` | `check` | `TB_LON_SUMMARY_INFO.update` |
| REQ-008 | `doSave` | `save` | `EPROC0_0110/0210.check` | `TB_CHECK_POINT_CORP`、`TB_CHECK_POINT_RC_CORP` |
| REQ-009 | `doSave` | `EPRO_Z0Z006` | parent done class update | Checkpoint find SQL |
| REQ-010 | all actions | all called modules | AJAX failure callbacks | DAO exceptions |

## 4. 功能需求

### 4.1 REQ-001 抵押品評分 tab 顯示

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | REQ-001 |
| 功能名稱 | 抵押品評分 tab 顯示 |
| 需求描述 | 系統應在公司戶徵信頁框中，依案件屬性顯示抵押品評分子頁籤。 |
| Trigger | 使用者進入 `EPROC0_0110` 或 `EPROC0_0210` 頁框。 |
| Actor | 系統、AO、CR、查詢使用者 |
| 前置條件 | 頁框已取得 `attrMap`、`CVer`、`dataMap`。 |
| 驗收條件 | 非 old case 且 `attrMap.isCS` 時顯示 `EPROC0_0114` 或 `EPROC0_0214`；否則不顯示。 |

#### Source Confirmed Behavior

| 項目 | 一般案件 | 展延變更案件 |
| --- | --- | --- |
| 父頁框 | `EPROC00110.jsp` | `EPROC00210.jsp` |
| tab id | `EPROC0_0114` | `EPROC0_0214` |
| 顯示條件 | `!attrMap.isOld && attrMap.isCS` | `!attrMap.isOld && attrMap.isCS` |
| 初始化 | `EPROC0_0114.initApp` | `EPROC0_0214.initApp` |
| 重查 | `EPROC0_0114.ajaxPost` | `EPROC0_0214.ajaxPost` |

### 4.2 REQ-002 查詢抵押品評分資料

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | REQ-002 |
| 功能名稱 | 查詢抵押品評分資料 |
| 需求描述 | 使用者進入 tab 時，系統應依 `APPLICATION_NO` 查詢申請日、主借款人名稱、既有抵押品評分資料與評分參數清單。 |
| Trigger | 前端 `ajaxPost()` 呼叫 `query` action。 |
| Actor | 系統 |
| 前置條件 | `APPLICATION_NO` 不可為空。 |
| 驗收條件 | 回傳 `dataMap` 供畫面填入借款人名稱、AO / CR 選項、評分日期、風險等級與 CR comment。 |

#### 查詢來源

| 資料 | Source confirmed 來源 |
| --- | --- |
| 申請日 | `TB_LON_SUMMARY_INFO.APPLICATION_DATE` |
| 申請屬性 | `TB_LON_SUMMARY_INFO.LON_ATTRIBUTE`、`SECURE_ATTRIBUTE` |
| 主借款人名稱 | `TB_MAIN_BORROWER_INFO_CORP.MAIN_BORROWER_NAME` |
| 既有抵押品評分 | `TB_COLL_ASS` |
| 評分參數 | `TB_SCORE_CARD_PARAM_DETAIL`，依 `VAR_NAME` 與 `APPLICATION_DATE` 取有效資料。 |
| checkpoint | 一般案件讀 `TB_CHECK_POINT_CORP`；展延變更案件讀 `TB_CHECK_POINT_RC_CORP`。 |

#### DataMap 主要欄位

| 欄位 | 說明 |
| --- | --- |
| `MAIN_BORROWER_NAME` | 主借款人名稱，來源 trim 後回傳。 |
| `APPLICATION_DATE` | 用於查評分參數與風險等級生效日期。 |
| `listNMArray` | 畫面欄位對應的 score parameter `VAR_NAME` 陣列。 |
| `C_V1List` 至 `C_V8List` | 各評分項目的選項清單，來源含 `VAR_CODE`、`VAR_DESC`、`SCORE`。 |
| `AO_*` | AO 端已保存的評分代碼、分數、風險等級、評分日期。 |
| `CR_*` | CR 端已保存的評分代碼、分數、風險等級、評分日期、評語。 |
| `CR_COMMENT_DATE` | 有既有 CR comment date 時顯示既有時間與 reviewer；CR 角色且尚無 comment date 時顯示目前時間與登入者。 |
| `check` | 目前子頁 checkpoint 欄位值。 |

### 4.3 REQ-003 依 CVer 顯示評分項目

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | REQ-003 |
| 功能名稱 | 評分版本控制 |
| 需求描述 | 系統應依 `CVer` 決定抵押品評分項目與 code table `VAR_NAME` 順序。 |
| Trigger | Query action 回傳 dataMap 後渲染畫面。 |
| Actor | 系統 |
| 前置條件 | `EPRO_IS0110.getcollassver(APPLICATION_NO)` 已回傳 `001` 或 `002`；查無資料預設 `001`。 |
| 驗收條件 | 畫面欄位與後端 `LIST_NM_ARRAY001/002` 一致。 |

#### CVer Mapping

| CVer | 顯示順序 | 畫面欄位 | 參數 VAR_NAME |
| --- | --- | --- | --- |
| `001` | 1 | Collateral Location (District) | `C_V1` |
| `001` | 2 | Collateral Document | `C_V2` |
| `001` | 3 | Collateral Area | `C_V3` |
| `001` | 4 | Location Classification (-ve Information) | `C_V4` |
| `001` | 5 | Collateral Near Loathsome Facility | `C_V5` |
| `001` | 6 | Collateral Land Shape | `C_V6` |
| `001` | 7 | Collateral Generates Income | `C_V7` |
| `002` | 1 | Collateral Location (District) | `C_V1` |
| `002` | 2 | Collateral Area | `C_V3` |
| `002` | 3 | Location Classification (-ve Information) | `C_V4` |
| `002` | 4 | Collateral Near Loathsome Facility | `C_V5` |
| `002` | 5 | Collateral Land Shape | `C_V6` |
| `002` | 6 | Collateral Location (Address) | `C_V8` |
| `002` | 7 | Collateral Generates Income | `C_V7` |

### 4.4 REQ-004 AO / CR 評分與風險等級計算

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | REQ-004 |
| 功能名稱 | 評分與風險等級計算 |
| 需求描述 | AO 或 CR 選擇所有 required 評分項目後，系統應計算總分並回傳風險等級與評分時間。 |
| Trigger | 使用者按 `BTN_RATE`。 |
| Actor | AO、CR |
| 前置條件 | 對應角色的所有評分項目已選擇。 |
| 驗收條件 | 後端回傳 `level`、`scrDate`、`totalScore`，前端顯示於對應角色欄位。 |

#### 計算規則

| 項目 | Source confirmed 行為 |
| --- | --- |
| 分數來源 | 前端依選項的 `SCORE` 組成 `scoreMap`。 |
| 總分 | `EPRO_C00113.getRate` / `EPRO_I00113.getRate` 對 `scoreMap` value 加總。 |
| 風險等級 | 以 `VAR_NAME = COL_RISK_LV`、`CODE = totalScore`、`APP_DATE = appDate` 查 `TB_SCORE_CARD_PARAM_DETAIL.findRange`。 |
| 區間條件 | `LOW_RANGE <= CODE` 且 `CODE < UP_RANGE`。 |
| 生效日期 | `ST_DATE = MAX(ST_DATE) where ST_DATE <= APP_DATE`。 |
| 回傳日期格式 | `dd/MM/yyyy HH:mm:ss`。 |

### 4.5 REQ-005 前端驗證

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | REQ-005 |
| 功能名稱 | Save / Finished 驗證 |
| 需求描述 | 系統應在前端限制未完成必要欄位與未執行 Rate 的資料不得 Finished。 |
| Trigger | 使用者按 Save 或 Finished。 |
| Actor | AO、CR |
| 前置條件 | 使用者具備 `isEditor114` 或 `isEditor214` 且非 query mode。 |
| 驗收條件 | 未選 required 欄位或未 Rate 時，Finished 不送出 save action。 |

#### 驗證規則

| 角色 | Save | Finished |
| --- | --- | --- |
| AO | required AO 評分欄位。 | required AO 評分欄位，且 `AO_RISK_LEVEL` 與 `AO_DATE` 已有值。 |
| CR | required CR 評分欄位與 `CR_COMMENT`。 | required CR 評分欄位、`CR_COMMENT`，且 `CR_RISK_LEVEL` 與 `CR_DATE` 已有值。 |
| Query mode | 欄位 disabled，不顯示可編輯儲存行為。 | 欄位 disabled，不顯示可編輯完成行為。 |

### 4.6 REQ-006 儲存抵押品評分資料

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | REQ-006 |
| 功能名稱 | 儲存抵押品評分資料 |
| 需求描述 | 系統應合併 `infoMap`、`scoreMap`、`codeMap` 後，以 `APPLICATION_NO` upsert `TB_COLL_ASS`。 |
| Trigger | 使用者按 Save 或 Finished。 |
| Actor | AO、CR |
| 前置條件 | `APPLICATION_NO` 不可為空；前端已送出對應角色資料。 |
| 驗收條件 | 既有資料 update；update count 0 時 insert；失敗 rollback。 |

#### 儲存資料處理

| 角色 | Source confirmed 行為 |
| --- | --- |
| AO | 將 AO 評分 code / score 寫入 `AO_*` 欄位；保存 `AO_CODE`、`AO_NAME`、`AO_DATE`、`AO_SCORE`、`AO_RISK_LEVEL`。 |
| AO | 透過 `copySameField("AO", "CR", COPY_FIELD)` 將 AO 抵押品 code / score 複製到 CR 對應欄位。 |
| AO | 清空 `CR_RISK_LEVEL`、`CR_SCORE`、`CR_DATE`，並將 `CR_SCORE_CARD_COMPLETED` 設為 `NN`。 |
| CR | 將 CR 評分 code / score、`CR_CODE`、`CR_NAME`、`CR_DATE`、`CR_COMMENT_DATE`、`CR_SCORE`、`CR_RISK_LEVEL`、`CR_COMMENT` 寫入資料表。 |
| CR | 保留 `CR_SCORE_CARD_COMPLETED` 第一碼，依 `check` 更新第二碼。 |

### 4.7 REQ-007 完成狀態與 Summary 更新

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | REQ-007 |
| 功能名稱 | 完成狀態同步 |
| 需求描述 | 系統應依角色與按鈕行為同步 `TB_LON_SUMMARY_INFO.CR_SCORE_CARD_COMPLETED`。 |
| Trigger | Save 或 Finished 成功儲存。 |
| Actor | 系統 |
| 前置條件 | `TB_LON_SUMMARY_INFO` 可依 `APPLICATION_NO` 查詢。 |
| 驗收條件 | AO 儲存重設為 `NN`；CR 儲存維持第一碼並依 `check` 改變第二碼。 |

#### Completion Mapping

| 按鈕 | 前端送出 `check` | checkpoint 欄位 | `CR_SCORE_CARD_COMPLETED` 第二碼 |
| --- | --- | --- | --- |
| Save | `Y` | `Y`，代表尚未完成 | `N` |
| Finished | `N` | `N`，代表完成 | `Y` |

注意：AO branch 會直接將 `CR_SCORE_CARD_COMPLETED` 設為 `NN`，即使 AO 按 Finished 也不代表 CR 評分已完成。

### 4.8 REQ-008 Checkpoint 更新

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | REQ-008 |
| 功能名稱 | Checkpoint 更新 |
| 需求描述 | 系統應更新對應案件類型的 checkpoint table，讓父頁框與 page menu 可判斷完成狀態。 |
| Trigger | Save 或 Finished 成功儲存。 |
| Actor | 系統 |
| 前置條件 | 對應 checkpoint row 已存在。 |
| 驗收條件 | 一般案件更新 `EPROC0_0114`；展延變更案件更新 `EPROC0_0214`。 |

#### Checkpoint Mapping

| 案件類型 | Table | 欄位 | 更新值 |
| --- | --- | --- | --- |
| 一般案件 | `TB_CHECK_POINT_CORP` | `EPROC0_0114` | request `check` |
| 展延變更案件 | `TB_CHECK_POINT_RC_CORP` | `EPROC0_0214` | request `check` |

### 4.9 REQ-009 父頁框完成狀態

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | REQ-009 |
| 功能名稱 | 父頁框完成狀態回傳 |
| 需求描述 | 儲存成功後，系統應回傳父頁框所需的 all tabs completion 結果。 |
| Trigger | Save 或 Finished 成功。 |
| Actor | 系統 |
| 前置條件 | 前端提供 `pageCheckMap`。 |
| 驗收條件 | 回傳 `isAllTabsCheck`；前端在 `check=N` 且 all tabs complete 時將父頁框加上 `done` class。 |

#### Parent Frame Mapping

| 子頁 | 父頁框 | Completion 方法 |
| --- | --- | --- |
| `EPROC0_0114` | `EPROC0_0110` | `EPRO_Z0Z006.getCheckedProgressCORP(APPLICATION_NO, tabsList)` |
| `EPROC0_0214` | `EPROC0_0210` | `EPRO_Z0Z006.getCheckedProgressRC_CORP(APPLICATION_NO, tabsList)` |

### 4.10 REQ-010 權限與可編輯性

| 欄位 | 內容 |
| --- | --- |
| Requirement ID | REQ-010 |
| 功能名稱 | 權限與可編輯性 |
| 需求描述 | 系統應依角色、query mode 與 editor flag 控制欄位與按鈕。 |
| Trigger | 畫面初始化。 |
| Actor | AO、CR、查詢使用者 |
| 前置條件 | 父頁框已注入 `role`、`isAO`、`isEditor114` / `isEditor214`、`attrMap`。 |
| 驗收條件 | 只有可編輯且非 query mode 的使用者可見 Save / Finished 按鈕；角色只能編輯自己的欄位。 |

#### 權限規則

| 條件 | 行為 |
| --- | --- |
| `isEditor114 && !attrMap.isQuery` | 一般案件顯示 `btnSave114`、`btnFinished114`。 |
| `isEditor214 && !attrMap.isQuery` | 展延變更案件顯示 `btnSave214`、`btnFinished214`。 |
| AO role | 啟用 AO select 與 AO Rate；禁用 CR select 與 CR comment。 |
| CR role | 啟用 CR select、CR Rate 與 CR comment；禁用 AO select。 |
| Query mode | 所有 `.scorSel114/214` 與 `CR_COMMENT` disabled。 |

## 5. API / Interface 規格

### 5.1 API Summary

| API | 一般案件 URL | 展延變更案件 URL | 用途 |
| --- | --- | --- | --- |
| `query` | `${dispatcher}/EPROC0_0114/query` | `${dispatcher}/EPROC0_0214/query` | 查詢抵押品評分資料與評分參數。 |
| `getRate` | `${dispatcher}/EPROC0_0114/getRate` | `${dispatcher}/EPROC0_0214/getRate` | 計算風險等級、評分日期與總分。 |
| `save` | `${dispatcher}/EPROC0_0114/save` | `${dispatcher}/EPROC0_0214/save` | 儲存或完成抵押品評分。 |

### 5.2 Common Header / Context

| 項目 | 來源 |
| --- | --- |
| 使用者角色 | `user.getRole()` |
| 使用者員編 | `user.getEmpId()` |
| 使用者姓名 | `user.getEmpName()` |
| Audit log | `query` 使用 `ActionType.Query` / `AccessObjectType.Table`；`getRate` 使用 `ActionType.Transfer` / `AccessObjectType.StoredProcedure`；`save` 使用 `ActionType.Edit` / `AccessObjectType.Table`。 |

### 5.3 `query` Request / Response

#### Request

| 欄位 | 型別 | 必填 | 說明 |
| --- | --- | --- | --- |
| `APPLICATION_NO` | String | Y | 案件申請書編號。 |
| `action` | String | N | 前端送出 `attrMap.action`，後端未使用。 |

#### Response

| 欄位 | 型別 | 說明 |
| --- | --- | --- |
| `dataMap` | Object | 包含主借款人、申請日、評分參數清單、既有 AO / CR 評分、checkpoint。 |

### 5.4 `getRate` Request / Response

#### Request

| 欄位 | 型別 | 必填 | 說明 |
| --- | --- | --- | --- |
| `scoreMap` | JSON Object | Y | key 為 `AO_*_SCR` 或 `CR_*_SCR`，value 為選項分數。 |
| `appDate` | String | Y | 申請日，用於查詢有效的風險等級參數。 |

#### Response

| 欄位 | 型別 | 說明 |
| --- | --- | --- |
| `level` | String | 風險等級描述，來源 `TB_SCORE_CARD_PARAM_DETAIL.VAR_DESC`。 |
| `scrDate` | String | 評分時間，格式 `dd/MM/yyyy HH:mm:ss`。 |
| `totalScore` | Decimal | 所有 score 加總。 |

### 5.5 `save` Request / Response

#### Request

| 欄位 | 型別 | 必填 | 說明 |
| --- | --- | --- | --- |
| `APPLICATION_NO` | String | Y | 案件申請書編號。 |
| `scoreMap` | JSON Object | Y | 對應角色的 score 欄位。 |
| `codeMap` | JSON Object | Y | 對應角色的 code 欄位。 |
| `infoMap` | JSON Object | Y | `APPLICATION_NO`、角色風險等級、日期、CR comment 等資訊。 |
| `totalScore` | String | Y | 前次 `getRate` 回傳總分。 |
| `check` | String | Y | `Y` 暫存未完成；`N` 完成。 |
| `pageCheckMap` | JSON Object | Y | 父頁框提供的頁籤判斷參數，供後端取 tabs list。 |

#### Response

| 欄位 | 型別 | 說明 |
| --- | --- | --- |
| `isAllTabsCheck` | Boolean | 父頁框所有子頁是否都不是 `Y`。 |
| message | String | 成功時 `COMMON_MSG_SAVE_SUCCESS`。 |

### 5.6 Timeout / Retry / Idempotency

| 項目 | 規格 |
| --- | --- |
| Timeout | Source 未定義。新系統依平台預設 API timeout。 |
| Retry | Save / Finished 涉及資料異動，不建議前端自動重試。 |
| Idempotency | 以 `APPLICATION_NO` upsert `TB_COLL_ASS`，重送相同 payload 會覆蓋同一筆資料；仍須避免重複點擊造成最後寫入者覆蓋。 |
| Transaction | `save` module 以 `Transaction.begin/commit/rollback` 包住 `TB_COLL_ASS`、`TB_LON_SUMMARY_INFO`、checkpoint 更新。 |

## 6. 資料規格與 Mapping

### 6.1 Field Mapping

| UI / Payload 欄位 | DB 欄位 | 說明 |
| --- | --- | --- |
| `APPLICATION_NO` | `TB_COLL_ASS.APPLICATION_NO` | 主鍵與案件編號。 |
| `AO_COLL_LOCATION_CODE` / `SCR` | `TB_COLL_ASS.AO_COLL_LOCATION_CODE` / `AO_COLL_LOCATION_SCR` | AO Collateral Location。 |
| `AO_COLL_DOC_CODE` / `SCR` | `TB_COLL_ASS.AO_COLL_DOC_CODE` / `AO_COLL_DOC_SCR` | AO Collateral Document，僅 `CVer=001` 使用。 |
| `AO_COLL_AREA_CODE` / `SCR` | `TB_COLL_ASS.AO_COLL_AREA_CODE` / `AO_COLL_AREA_SCR` | AO Collateral Area。 |
| `AO_COLL_LOCATION_CLASS_CODE` / `SCR` | `TB_COLL_ASS.AO_COLL_LOCATION_CLASS_CODE` / `AO_COLL_LOCATION_CLASS_SCR` | AO Location Classification。 |
| `AO_COLL_LOATHSOME_CODE` / `SCR` | `TB_COLL_ASS.AO_COLL_LOATHSOME_CODE` / `AO_COLL_LOATHSOME_SCR` | AO Near Loathsome Facility。 |
| `AO_COLL_LANDSHAP_CODE` / `SCR` | `TB_COLL_ASS.AO_COLL_LANDSHAP_CODE` / `AO_COLL_LANDSHAP_SCR` | AO Land Shape。 |
| `AO_COLL_ADDR_CODE` / `SCR` | `TB_COLL_ASS.AO_COLL_ADDR_CODE` / `AO_COLL_ADDR_SCR` | AO Location Address，僅 `CVer=002` 使用。 |
| `AO_COLL_GEN_INCOME_CODE` / `SCR` | `TB_COLL_ASS.AO_COLL_GEN_INCOME_CODE` / `AO_COLL_GEN_INCOME_SCR` | AO Generates Income。 |
| `AO_RISK_LEVEL` | `TB_COLL_ASS.AO_RISK_LEVEL` | AO 風險等級。 |
| `AO_DATE` | `TB_COLL_ASS.AO_DATE` | AO 評分時間，payload `dd/MM/yyyy HH:mm:ss` 轉 timestamp。 |
| `AO_SCORE` | `TB_COLL_ASS.AO_SCORE` | AO 總分。 |
| `AO_CODE` / `AO_NAME` | `TB_COLL_ASS.AO_CODE` / `AO_NAME` | AO 員編與姓名。 |
| `CR_*` collateral code / score | `TB_COLL_ASS.CR_*` | CR 評分欄位；AO 儲存時會先複製 AO 欄位到 CR 對應 code / score。 |
| `CR_RISK_LEVEL` | `TB_COLL_ASS.CR_RISK_LEVEL` | CR 風險等級。 |
| `CR_DATE` | `TB_COLL_ASS.CR_DATE` | CR 評分時間。 |
| `CR_COMMENT` | `TB_COLL_ASS.CR_COMMENT` | CR 評語，CR 角色 required。 |
| `CR_COMMENT_DATE` | `TB_COLL_ASS.CR_COMMENT_DATE` | CR 儲存時寫入系統目前時間。 |
| `CR_SCORE` | `TB_COLL_ASS.CR_SCORE` | CR 總分。 |
| `CR_CODE` / `CR_NAME` | `TB_COLL_ASS.CR_CODE` / `CR_NAME` | CR 員編與姓名。 |
| `CR_SCORE_CARD_COMPLETED` | `TB_LON_SUMMARY_INFO.CR_SCORE_CARD_COMPLETED` | AO 儲存設 `NN`；CR 儲存更新第二碼。 |
| `check` | `TB_CHECK_POINT_CORP.EPROC0_0114` 或 `TB_CHECK_POINT_RC_CORP.EPROC0_0214` | 子頁 checkpoint。 |

### 6.2 Main Tables / DAOs

| Table | DAO | 用途 |
| --- | --- | --- |
| `OVSLXLON01.TB_COLL_ASS` | `EPRO_TB_COLL_ASS` | 抵押品評分主資料。 |
| `TB_LON_SUMMARY_INFO` | `EPRO_TB_LON_SUMMARY_INFO` | 申請日、案件屬性、`CR_SCORE_CARD_COMPLETED`。 |
| `TB_MAIN_BORROWER_INFO_CORP` | `EPRO_TB_MAIN_BORROWER_INFO_CORP` | 主借款人名稱。 |
| `TB_SCORE_CARD_PARAM_DETAIL` | `EPRO_TB_SCORE_CARD_PARAM_DETAIL` | 評分項目選項、score、風險等級與 `C_Ver`。 |
| `TB_CHECK_POINT_CORP` | `EPRO_TB_CHECK_POINT_CORP` | 一般案件公司戶 checkpoint。 |
| `TB_CHECK_POINT_RC_CORP` | `EPRO_TB_CHECK_POINT_RC_CORP` | 展延變更案件公司戶 checkpoint。 |

### 6.3 SQL Mapping

| SQL ID | 用途 |
| --- | --- |
| `com.cathaybk.epro.dao.EPRO_TB_COLL_ASS.SQL_FIND_001` | 依 `APPLICATION_NO` 查詢抵押品評分資料。 |
| `com.cathaybk.epro.dao.EPRO_TB_COLL_ASS.SQL_INSERT_001` | 新增抵押品評分資料。 |
| `com.cathaybk.epro.dao.EPRO_TB_COLL_ASS.SQL_UPDATE_001` | 依 `APPLICATION_NO` 更新抵押品評分資料。 |
| `com.cathaybk.epro.dao.EPRO_TB_SCORE_CARD_PARAM_DETAIL.SQL_FIND_RANGE_001` | 依分數區間與生效日期查風險等級。 |
| `com.cathaybk.epro.is.module.EPRO_IS0110.SQL_QUERY_002` | 依申請日查 `C_Ver`。 |
| `EPRO_TB_CHECK_POINT_CORP.SQL_UPDATE_*` | 更新 `EPROC0_0114` checkpoint。 |
| `EPRO_TB_CHECK_POINT_RC_CORP.SQL_UPDATE_*` | 更新 `EPROC0_0214` checkpoint。 |

### 6.4 Sensitive Data / Masking Expectations

| 資料 | 敏感性 | 新系統建議 |
| --- | --- | --- |
| `MAIN_BORROWER_NAME` | 客戶名稱 | 依新系統個資遮罩與授權規範處理；舊系統未遮罩。 |
| `AO_CODE`、`AO_NAME`、`CR_CODE`、`CR_NAME` | 員工識別資料 | 僅授權角色可見；audit log 保留查詢與異動紀錄。 |
| `CR_COMMENT` | 授信審查意見 | 應納入存取控制與異動稽核。 |
| Scorecard code / score | 授信評分資料 | 不應暴露給未授權使用者。 |

## 7. 業務規則

| Rule ID | 規則 | Evidence |
| --- | --- | --- |
| BR-001 | `APPLICATION_NO` 為 query / save 必要欄位；空值應丟出 `COMMON_MSG_ERROR_LON`。 | Source confirmed |
| BR-002 | `CVer` 查無資料時預設 `001`。 | Source confirmed |
| BR-003 | `CVer=001` 顯示 `C_V1,C_V2,C_V3,C_V4,C_V5,C_V6,C_V7`。 | Source confirmed |
| BR-004 | `CVer=002` 顯示 `C_V1,C_V3,C_V4,C_V5,C_V6,C_V8,C_V7`。 | Source confirmed |
| BR-005 | `getRate` 的總分為 `scoreMap` 所有分數加總。 | Source confirmed |
| BR-006 | 風險等級以 `COL_RISK_LV`、申請日、分數區間取得。 | Source confirmed |
| BR-007 | Save 送出 `check=Y`，Finished 送出 `check=N`。 | Source confirmed |
| BR-008 | `check=Y` 代表未完成；`check=N` 代表完成。 | Source confirmed from checkpoint progress logic |
| BR-009 | AO 儲存時會將 AO 抵押品 code / score 複製到 CR 抵押品 code / score，但清空 CR score、risk level 與 CR date。 | Source confirmed |
| BR-010 | AO 儲存後 `CR_SCORE_CARD_COMPLETED` 必為 `NN`。 | Source confirmed |
| BR-011 | CR 儲存時保留 `CR_SCORE_CARD_COMPLETED` 第一碼，第二碼依 `check` 寫入 `N` 或 `Y`。 | Source confirmed |
| BR-012 | CR 完成前必須有 CR 評分欄位、CR risk level、CR date 與 CR comment。 | Source confirmed |
| BR-013 | 父頁框 done 狀態只在 `check=N` 且 all tabs checkpoint 都不是 `Y` 時加上。 | Source confirmed |
| BR-014 | 授信條件異動流程可能重設 `EPROC0_0114/0214` checkpoint 為 `Y` 並清除 CR 評分資料。 | Cross-module confirmed |

## 8. 錯誤處理

| 情境 | 舊系統處理 | 新系統需求 |
| --- | --- | --- |
| 查詢無資料 | `DataNotFoundException` 回 `MSG_DATA_NOT_FOUND`。 | 顯示資料不存在訊息，不得產生空白成功畫面。 |
| ModuleException 無 root cause | 回傳 exception message。 | 保留可讀業務錯誤訊息。 |
| Over count limit | 回 `MSG_OVER_COUNT_LIMIT`。 | 顯示查詢筆數超限訊息。 |
| Query / Save 其他例外 | 回 `MSG_QUERY_FAIL`。 | 保留相容訊息；但 save failure 使用 query fail 文案列為 legacy 相容。 |
| Rate 例外 | 回 `COMMON_MSG_RATE_FAIL`。 | 顯示評分失敗訊息，不更新畫面風險等級。 |
| Query AJAX failure | JS 對 `.isView114/214` 設 disabled。 | 新系統應明確呈現查詢失敗狀態；舊系統 disabled div 可能無法完整禁用子控制項。 |
| Save 成功 | `COMMON_MSG_SAVE_SUCCESS`。 | 顯示儲存成功，並更新父頁框完成狀態。 |

## 9. 非功能需求

| 類型 | 需求 |
| --- | --- |
| 權限 | 必須依角色與 editor flag 控制可編輯欄位與按鈕。 |
| 稽核 | Query / Rate / Save 需保留對應 audit action 與 access object 類型。 |
| 交易一致性 | Save 必須在同一交易中完成 `TB_COLL_ASS`、`TB_LON_SUMMARY_INFO` 與 checkpoint 更新；任一失敗需 rollback。 |
| 相容性 | `CVer=001` 與 `CVer=002` 欄位順序與參數來源需相容舊系統。 |
| 可觀測性 | Rate / Save 失敗需可追蹤 application no、function id、角色與錯誤原因。 |
| 資安 | `CR_COMMENT`、scorecard 分數與員工識別資料須遵循授權、遮罩與 log 最小揭露原則。 |
| 效能 | Query 應避免重複查詢相同 `VAR_NAME` 時造成明顯延遲；參數資料可依申請日與 `VAR_NAME` 快取，但不得破壞生效日邏輯。 |

## 10. 驗收標準與測試案例

### 10.1 Acceptance Criteria

| AC ID | Given | When | Then |
| --- | --- | --- | --- |
| AC-001 | 非 old case 且 `attrMap.isCS=true` | 開啟 `EPROC0_0110` | 顯示 `EPROC0_0114` tab。 |
| AC-002 | 非 old case 且 `attrMap.isCS=true` | 開啟 `EPROC0_0210` | 顯示 `EPROC0_0214` tab。 |
| AC-003 | `CVer=001` | 查詢抵押品評分 | 畫面顯示含 Collateral Document 的 7 個項目。 |
| AC-004 | `CVer=002` | 查詢抵押品評分 | 畫面顯示含 Collateral Location (Address)、不含 Collateral Document 的 7 個項目。 |
| AC-005 | AO 選完所有 AO 欄位 | 按 Rate | 回填 AO risk level、AO date 與 total score。 |
| AC-006 | CR 未填 CR comment | 按 Finished | 前端不得送出 save。 |
| AC-007 | CR 已評分且填寫 CR comment | 按 Finished | `TB_COLL_ASS` 更新 CR 資料，checkpoint 為 `N`，`CR_SCORE_CARD_COMPLETED` 第二碼為 `Y`。 |
| AC-008 | AO 修改並儲存 | 按 Save 或 Finished | CR score/risk/date 被清空，`CR_SCORE_CARD_COMPLETED=NN`。 |
| AC-009 | 所有子頁 checkpoint 都不是 `Y` | 本頁 Finished 成功 | 父頁框回傳 `isAllTabsCheck=true`，前端加上 done class。 |
| AC-010 | `APPLICATION_NO` 空白 | 呼叫 query 或 save | 回傳錯誤，不異動資料。 |

### 10.2 SIT / UAT Test Cases

| Test Case ID | 測試需求 | 測試資料 | 預期結果 |
| --- | --- | --- | --- |
| TC-001 | 一般案件 tab 顯示 | `EPROC0_0110`、非 old、CS | 出現 `EPROC0_0114` tab 並可初始化。 |
| TC-002 | 展延案件 tab 顯示 | `EPROC0_0210`、非 old、CS | 出現 `EPROC0_0214` tab 並可初始化。 |
| TC-003 | 非 CS 不顯示 | `attrMap.isCS=false` | 不顯示 `EPROC0_0114/0214` tab；若有 direct API call 需依授權規則處理。 |
| TC-004 | CVer 預設 | `TB_SCORE_CARD_PARAM_DETAIL` 查無 `C_Ver` | 後端回 `CVer=001` 對應資料。 |
| TC-005 | CVer 001 欄位 | `C_Ver=001` | 畫面項目順序與 `C_V1` 到 `C_V7` 一致。 |
| TC-006 | CVer 002 欄位 | `C_Ver=002` | 畫面項目順序為 `C_V1,C_V3,C_V4,C_V5,C_V6,C_V8,C_V7`。 |
| TC-007 | AO Rate | AO 選完所有欄位 | `getRate` 回 `level`、`scrDate`、`totalScore`，畫面顯示 AO 結果。 |
| TC-008 | AO Finished | AO 已 Rate | `TB_COLL_ASS` 寫入 AO 資料、複製 AO 抵押品 code/score 到 CR、清空 CR risk/date/score，summary 為 `NN`。 |
| TC-009 | CR Rate | CR 選完所有欄位 | `getRate` 回 CR 結果，畫面顯示 CR risk level/date。 |
| TC-010 | CR Save | CR 已 Rate 且填 comment，按 Save | checkpoint 為 `Y`，summary 第二碼為 `N`，資料可再次查回。 |
| TC-011 | CR Finished | CR 已 Rate 且填 comment，按 Finished | checkpoint 為 `N`，summary 第二碼為 `Y`，回傳 `isAllTabsCheck`。 |
| TC-012 | 未 Rate 完成阻擋 | AO 或 CR 欄位已選但未按 Rate | Finished 被前端驗證阻擋，未呼叫 save。 |
| TC-013 | 缺少 required 欄位 | 任一 required select 空白 | Rate / Finished 被前端驗證阻擋。 |
| TC-014 | 空白 application no | API request `APPLICATION_NO=""` | 回錯誤訊息，DB 無異動。 |
| TC-015 | 風險等級邊界 | total score 等於某 `LOW_RANGE` 或 `UP_RANGE` | `LOW_RANGE` 含邊界，`UP_RANGE` 不含邊界。 |
| TC-016 | Save rollback | 模擬 checkpoint update 失敗 | `TB_COLL_ASS` 與 `TB_LON_SUMMARY_INFO` 不應部分成功。 |
| TC-017 | 授信條件異動重設 | 觸發 `EPROCS_0170/0270` 非 CR 異動路徑 | `EPROC0_0114/0214` checkpoint 被重設為 `Y`，CR 評分資料被清除。 |
| TC-018 | Query mode | `attrMap.isQuery=true` | 所有欄位 disabled，不顯示可編輯儲存行為。 |
| TC-019 | i18n key 檢核 | 開啟一般與展延頁 | 功能名稱不應顯示錯誤 key；若沿用舊 key，需列入 migration mapping。 |
| TC-020 | CR address SQL mapping | 查詢/更新 `CR_COLL_ADDR_CODE/SCR` | 新系統欄位名稱應與 DAO 一致，不沿用 `CR_ADDR_CODE/SCR` 錯誤 where 名稱。 |

## 11. 附件與決策紀錄

### 11.1 Source File Inventory

| 類型 | 檔案 |
| --- | --- |
| Transaction | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\JavaSource\com\cathaybk\epro\c0\trx\EPROC0_0114.java` |
| Transaction | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\JavaSource\com\cathaybk\epro\c0\trx\EPROC0_0214.java` |
| Module | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\JavaSource\com\cathaybk\epro\c0\module\EPROC0_0114_mod.java` |
| Module | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\JavaSource\com\cathaybk\epro\c0\module\EPROC0_0214_mod.java` |
| Shared module | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\JavaSource\com\cathaybk\epro\c0\module\EPRO_C00113.java` |
| Shared module | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\JavaSource\com\cathaybk\epro\i0\module\EPRO_I00113.java` |
| JSP | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\WebContent\html\cathaybk\system\epro\c0\EPROC0_0100\EPROC00114.jsp` |
| JSP JS | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\WebContent\html\cathaybk\system\epro\c0\EPROC0_0100\EPROC00114_JS.jsp` |
| JSP | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\WebContent\html\cathaybk\system\epro\c0\EPROC0_0200\EPROC00214.jsp` |
| JSP JS | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\EPROWeb\WebContent\html\cathaybk\system\epro\c0\EPROC0_0200\EPROC00214_JS.jsp` |
| SQL | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\SQL\com\cathaybk\epro\dao\com.cathaybk.epro.dao.EPRO_TB_COLL_ASS.*.sql` |
| SQL | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\SQL\com\cathaybk\epro\dao\com.cathaybk.epro.dao.EPRO_TB_SCORE_CARD_PARAM_DETAIL.SQL_FIND_RANGE_001.sql` |
| SQL | `D:\Users\00584570\Documents\OVSLXLON01-EProposal\SQL\com\cathaybk\epro\is\module\com.cathaybk.epro.is.module.EPRO_IS0110.SQL_QUERY_002.sql` |
| Inventory | `D:\Users\00584570\Downloads\E-Proposal\Source code\舊系統ebaf\OVSLXLON01-EProposal\migration-inventory\function-inventory.csv` |

### 11.2 Decision Log

| Decision ID | 決策 | 狀態 | 說明 |
| --- | --- | --- | --- |
| DEC-001 | 文件將 `EPROC0_0114` 與 `EPROC0_0214` 合併為 `EPROC00114` PRD。 | Accepted | 使用者指定合併輸出。 |
| DEC-002 | 文件採 readable Chinese template heading，不沿用技能標準檔中的 mojibake heading。 | Accepted | 使用者先前要求封面中文需可讀。 |
| DEC-003 | `EPROC0_0114.getRate` 的 I0 shared module 引用列為待確認，不在 PRD 中自動修正。 | Pending | Source confirmed 但需 RD 決策。 |
| DEC-004 | `TB_COLL_ASS.SQL_FIND_001` 的 CR address where 欄位不一致列為 legacy defect suspect。 | Pending | 新系統 mapping 不應沿用錯誤欄位名。 |

### 11.3 Review Checklist

| 項目 | 狀態 |
| --- | --- |
| Transaction actions 已掃描 | Done |
| Module query / save 已掃描 | Done |
| JSP / JS 欄位與驗證已掃描 | Done |
| DAO / SQL 已掃描 | Done |
| Cross-module checkpoint reset 已掃描 | Done |
| TBD 與 legacy defect suspect 已列出 | Done |
| SIT / UAT 測試案例已列出 | Done |
