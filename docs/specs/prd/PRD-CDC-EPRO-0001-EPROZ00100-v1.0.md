# 業務需求導向的功能規格書

CDC-EPRO-0001 EPROZ00100 TO DO LIST / Work-list Dashboard
Version 1.1
文件日期：2026/06/08

| 文件狀態 | PM Review Draft - 待 PM / SA / RD / QA 確認 |
| --- | --- |
| 功能範圍 | EPROZ0_0100 TO DO LIST：角色待辦清單、CAD 查詢、案件導頁、刪除、結案、proposal download、session context。 |
| 界外範圍 | 下游業務頁籤內容、授信審查計算、proposal 報表內容本身、登入與角色管理維護不在本文件展開。 |

## 0. 文件控管

## 0.1 版本紀錄

| 日期 | 版本 | 異動內容 | 作者 |
| --- | --- | --- | --- |
| 2026/06/08 | 1.0 | 依 EPROZ0_0100 source code 與既有 migration design 建立 TO DO LIST SRS 初稿。 | AI Agent |
| 2026/06/08 | 1.1 | 補 API 草案、role matrix、DB 影響、非功能需求、Given/When/Then 與 TBD。 | AI Agent |

## 0.2 文件 Review 紀錄

| 日期 | 文件 Review 記錄 | Review 版本 | Reviewer |
| --- | --- | --- | --- |
|  | PM 確認 dashboard 業務範圍、刪除/結案 reason、CAD 查詢與 download 使用情境。 | 1.1 |  |
|  | SA 確認角色權限、CASE_PROGRESS code table、CA/CR redistribution 是否保留。 | 1.1 |  |
|  | RD 確認 API schema、session/routing、transaction、download file handling 與 SQL mapping。 | 1.1 |  |
|  | QA 確認 Given / When / Then 測試案例與 DB 驗證點是否足夠。 | 1.1 |  |

## 0.3 待確認項目

| TBD ID | 待確認項目 | 影響範圍 | 建議處理 |
| --- | --- | --- | --- |
| TBD-001 | 角色 001/002/003/101/102/103/201/202/203/301/302/404/405 的正式名稱與權限。 | UI / API auth / 測試 | PM / SA 補正式 role code table。 |
| TBD-002 | prompt 是否可保留 CA/CR redistribution 資料異動 side effect。 | API method / audit / transaction | SA 決策；若保留，init 應使用 POST。 |
| TBD-003 | CASE_PROGRESS D1/C1/R0305/R0313/R0397 與 CAD 21/22/23/24/25 的正式語意。 | 查詢 / 導頁 / 測試 | PM / SA 補 code table。 |
| TBD-004 | CAD 查詢 JSP 送 DOC_NO，但 module 讀 NO 的 legacy mismatch。 | CAD doc no 查詢 | RD 實作時需決定相容欄位 mapping。 |
| TBD-005 | CAD decision date range 是否需 backend 強制六個月限制。 | validation / performance | SA / RD 確認。 |
| TBD-006 | Proposal download 回傳 encrypted temp file path 是否符合新系統安全與檔案下載規範。 | 安全 / 檔案處理 | RD 補 file download 設計。 |
| TBD-007 | DEL_REASON / CLO_REASON code table 與 D99/C99 other reason 規則。 | reason validation | PM / SA 補正式 code table。 |
| TBD-008 | 下游頁面尚依賴 server session 時，setSession/clearSession 的保留期限。 | routing / migration | RD 規劃 session-to-route 遷移。 |

## 1. 文件目的與邊界

本文件描述 EPROZ0_0100 現行業務邏輯與 EPROZ00100 重構需求，並提供業務層 API / Interface 草案。正式 endpoint、DTO 型別、欄位 enum、validation annotation、DB schema detail 與 repository / SQL 設計，仍以後續系統開發規格書為準。

## 1.1 目標

| 目標 ID | 目標 | 驗收方式 |
| --- | --- | --- |
| GOAL-001 | 依登入角色顯示正確 TO DO LIST 或 CAD search/list。 | 不同 role code 顯示正確欄位與可用動作。 |
| GOAL-002 | 支援從待辦清單點選 applicationNo 後建立 current application context 並導向正確頁面。 | setSession 與 page routing 驗證。 |
| GOAL-003 | 支援 AO/CA/CR/CO/SCO task list 與 CAD task list 查詢。 | initQuery/queryCAD response 與 SQL 條件驗證。 |
| GOAL-004 | 支援刪除與 CAD 結案，並寫入 reason、history 與 summary 狀態。 | DB transaction 驗證。 |
| GOAL-005 | 支援 CA proposal download。 | 依 attribute dispatch 正確 printProposal module。 |

## 2. Source Code 對應

| 類型 | 路徑 | 用途 |
| --- | --- | --- |
| Trx | EPROWeb/JavaSource/com/cathaybk/epro/z0/trx/EPROZ0_0100.java | action dispatch、role flags、audit log、download dispatch。 |
| Module | EPROWeb/JavaSource/com/cathaybk/epro/z0/module/EPROZ0_0100_mod.java | task query、CAD query、redistribution、delete、close、routing。 |
| Main JSP | EPROWeb/WebContent/html/cathaybk/system/epro/z0/EPROZ0_0100/EPROZ00100.jsp | role-based table、CAD search、delete/close/download buttons。 |
| Delete popup | EPROZ00101.jsp | delete reason selection and D99 other reason validation。 |
| Close popup | EPROZ00102.jsp | close reason selection and C99 other reason validation。 |
| SQL | SQL_QUERY_001~005 | main list、redistribution、CAD search。 |

## 2.1 Action 對應

| Action | 業務用途 | 主要輸出 / side effect |
| --- | --- | --- |
| prompt | 進入 dashboard。 | 清 session，輸出 role flags；CA/CR 可能觸發 redistribution。 |
| initQuery | 查詢非 CAD 待辦清單。 | dataList。 |
| queryCAD | CAD 條件查詢。 | dataList。 |
| downloadFile | 下載 proposal report。 | encryptTempFileFullPath。 |
| getReason | 取得刪除原因。 | DEL_REASON map。 |
| getCloReason | 取得結案原因。 | CLO_REASON map。 |
| execute | 刪除案件。 | CASE_PROGRESS=D1，寫 DEL_REASON/history。 |
| executeclose | 結案 CAD 案件。 | CASE_PROGRESS=C1，寫 CLO_REASON/history。 |
| setSession | 設定 current application。 | session APPLICATION_NO/action。 |
| clearSession | 清除 current application。 | session cleared。 |

## 3. 角色與畫面需求

## 3.1 Role Matrix

| Role group | Role codes | 畫面 | 可用動作 |
| --- | --- | --- | --- |
| AO | 001,002,003 | AO TO DO LIST | 開啟案件；role 001/002 可刪除，role 003 不顯示 delete。 |
| CA | 101 | CA TO DO LIST | 開啟案件、download proposal；prompt 會觸發 CA redistribution。 |
| CR | 102,103 | Review TO DO LIST | 開啟案件；prompt 會觸發 CR redistribution。 |
| CO/SCO | 201,202,203,301,302 | Review/approval TO DO LIST | 開啟案件。 |
| CAD Maker/Checker | 404,405 | CAD Search + CAD TO DO LIST | 查詢、開啟案件、結案。 |

## 3.2 CAD 查詢欄位

| 欄位 | 規則 |
| --- | --- |
| APPLICATION_NO | 選填；maxlength 30。 |
| DOC_NO | 選填；maxlength 30；source mismatch：module reads NO。 |
| MAIN_BORROWER_NAME | 選填；maxlength 30；module upper-case like 查詢。 |
| START_DECISION_DATE | 選填；格式 dd/MM/yyyy；若填 end date 則必填。 |
| END_DECISION_DATE | 選填；格式 dd/MM/yyyy；若填 start date 則必填。 |
| 條件組合 | 至少 applicationNo、docNo、mainBorrowerName 或完整 decision date range 其中一組。 |
| 日期範圍 | JSP 有約六個月限制；backend 是否強制待確認。 |

## 4. 業務需求

## 4.1 EPROZ00100-REQ-001 Dashboard 初始化

| 項目 | 需求 |
| --- | --- |
| REQ-001-01 | 進入 dashboard 時必須清除前次 APPLICATION_NO/action session。 |
| REQ-001-02 | Backend 必須回傳 isAO、role、isCA、isCRCOSCO、isCOSCO、isCADMERCER。 |
| REQ-001-03 | CA role 進入時，依 source 規則執行 CA redistribution。 |
| REQ-001-04 | CR role 進入時，依 source 規則執行 CR redistribution。 |
| REQ-001-05 | 因 prompt 可能異動資料，重構 API 不應用純 GET 表示無 side effect。 |

## 4.2 EPROZ00100-REQ-002 Main Task List

| 項目 | 需求 |
| --- | --- |
| REQ-002-01 | initQuery 必須依 CURRENT_USER_ID 查詢目前使用者待辦案件。 |
| REQ-002-02 | 必須排除 CASE_PROGRESS 03、D1、R0305、R0313、R0397。 |
| REQ-002-03 | 個人案件顯示 main borrower name；公司案件顯示 corp borrower name。 |
| REQ-002-04 | APPLICATION_DATE=01/01/1900 顯示為空白。 |
| REQ-002-05 | 若存在 IS_Y=Y related party record，showRelated=Y，否則 N。 |
| REQ-002-06 | 須依 loan condition detail 加總 USD/KHR 金額。 |

## 4.3 EPROZ00100-REQ-003 CAD Task Search

| 項目 | 需求 |
| --- | --- |
| REQ-003-01 | queryCAD 必須以 current CAD user 加上 active proxy employees 為查詢範圍。 |
| REQ-003-02 | CAD 查詢只允許 LON_TYPE_CODE 01/02/03/04。 |
| REQ-003-03 | 查詢可依 applicationNo、doc no、main borrower name、decision date range 篩選。 |
| REQ-003-04 | 回傳須包含 decision date display、approval level display、docNo1、borrower name、sales channel、page。 |
| REQ-003-05 | 公司案件 docNo1 使用 REGISTER_NO；個人案件使用文件欄位轉換結果。 |

## 4.4 EPROZ00100-REQ-004 Page Routing

| 角色 / 條件 | Page routing |
| --- | --- |
| CA + IS | EPROIS_0171 |
| CA + IU | EPROIU_0171 |
| CA + CS | EPROCS_0171 |
| CA + CU | EPROCU_0171 |
| CAD Maker + CASE_PROGRESS 21/22 | EPROIS_0910 |
| CAD Maker + CASE_PROGRESS 24/25 | EPROIS_0920 |
| CAD Checker + CASE_PROGRESS 23 | EPROIS_0910 |
| CAD Checker + CASE_PROGRESS 25 | EPROIS_0920 |
| CAD otherwise | MANUALAPP |
| Other roles | EPRO_Z0Z006.getCheckPage first page。 |

## 4.5 EPROZ00100-REQ-005 Delete

| 項目 | 需求 |
| --- | --- |
| REQ-005-01 | AO role 003 不得從本頁刪除案件。 |
| REQ-005-02 | delete 必須要求 APPLICATION_NO 與至少一個 reason。 |
| REQ-005-03 | D99 選取時 other reason 必填，maxlength 100。 |
| REQ-005-04 | execute 必須在同一交易寫入 DEL_REASON、APP_HISTORY，並更新 summary CASE_PROGRESS=D1。 |
| REQ-005-05 | 若使用代理人身份處理，history 必須記錄 PROCESS_AGENT_CODE / NAME。 |

## 4.6 EPROZ00100-REQ-006 Close

| 項目 | 需求 |
| --- | --- |
| REQ-006-01 | CAD close 必須要求 APPLICATION_NO 與至少一個 close reason。 |
| REQ-006-02 | C99 選取時 other reason 必填，maxlength 100。 |
| REQ-006-03 | executeclose 必須在同一交易寫入 CLO_REASON、APP_HISTORY，並更新 summary CASE_PROGRESS=C1。 |
| REQ-006-04 | close 後 CURRENT_USER_ID 必須清空。 |
| REQ-006-05 | 若 IS_AUTODIS=M，close 後改為 MC；若 IS_AUTODIS=Y，close 後改為 YC。 |

## 4.7 EPROZ00100-REQ-007 Proposal Download

| TYPE | Dispatch module |
| --- | --- |
| CS | EPRO_CS0180.printProposal |
| CU | EPRO_CU0180.printProposal |
| IS | EPRO_IS0180.printProposal |
| IU | EPRO_IU0180.printProposal |
| Output | RptUtils.encrypt 後回傳 encryptTempFileFullPath；新系統安全處理待 RD 確認。 |

## 5. 資料與交易需求

## 5.1 DB 影響矩陣

| 資料表 / DAO | 操作 | 時機 | 驗證點 |
| --- | --- | --- | --- |
| TB_LON_SUMMARY_INFO | select | initQuery/queryCAD | 依 current user / proxy scope / filters 取得待辦案件。 |
| TB_LON_SUMMARY_INFO | update | delete | CASE_PROGRESS=D1。 |
| TB_LON_SUMMARY_INFO | update | close | CASE_PROGRESS=C1、CURRENT_USER_ID 空白、IS_AUTODIS 依規則轉 MC/YC。 |
| TB_LON_SUMMARY_INFO | update | CA/CR redistribution | CURRENT_USER_ID、CR_CODE、RE_DISTRIBUTION、RECEIVED_DATE、DISTRIBUTION_DATE 正確。 |
| TB_APP_HISTORY | insert | delete/close/redistribution | APP_PROCESS_CODE 與 processor/agent 資訊正確。 |
| TB_DEL_REASON | insert | delete | REASON_CODE 分號串接、DEL_DATE、OTH_REASON。 |
| TB_CLO_REASON | insert | close | REASON_CODE 分號串接、CLOSE_DATE、OTH_REASON。 |
| TB_RELATED_PARTY_INFO | select | initQuery row enrichment | IS_Y=Y 時 showRelated=Y。 |
| TB_LOAN_CONDITION_DETAIL | select | initQuery amount enrichment | USD/KHR 加總正確。 |
| TB_EMP_PROXY | select | queryCAD / CA/CR redistribution | active proxy scope 正確。 |

## 5.2 Transaction / Rollback

| 場景 | 交易要求 |
| --- | --- |
| CA/CR redistribution | summary update 與 history insert 必須同一交易；任一失敗 rollback。 |
| Delete | DEL_REASON、APP_HISTORY、summary update 必須同一交易；任一失敗 rollback。 |
| Close | CLO_REASON、APP_HISTORY、summary update 必須同一交易；任一失敗 rollback。 |
| Download | 不應異動業務資料；需記錄 print/download audit。 |

## 6. API / Interface 草案

## 6.1 Endpoint

| Action | HTTP Method | Endpoint 草案 | 用途 |
| --- | --- | --- | --- |
| prompt | POST | /api/eproz0-0100/prompt | 初始化 dashboard、清 session、回傳 role flags，可能觸發 redistribution。 |
| initQuery | GET | /api/eproz0-0100/initQuery | 取得非 CAD task list。 |
| queryCAD | POST | /api/eproz0-0100/queryCAD | CAD 條件查詢。 |
| downloadFile | POST | /api/eproz0-0100/downloadFile | 產生 proposal download file。 |
| getReason | GET | /api/eproz0-0100/getReason | 取得 delete reason。 |
| getCloReason | GET | /api/eproz0-0100/getCloReason | 取得 close reason。 |
| execute | POST | /api/eproz0-0100/execute | 刪除案件。 |
| executeclose | POST | /api/eproz0-0100/executeclose | 結案 CAD 案件。 |
| setSession | POST | /api/eproz0-0100/setSession | 設定 current application context。 |
| clearSession | DELETE | /api/eproz0-0100/clearSession | 清除 current application context。 |

## 6.2 Request Schema 草案

| 欄位 | 型別 | 允許值 / validation | 適用 action |
| --- | --- | --- | --- |
| applicationNo | string | 必填於 setSession/delete/close/download；maxlength 待 RD 定義。 | setSession, execute, executeclose, downloadFile, queryCAD |
| action | string | legacy session action；允許 null。 | setSession |
| type | string | CS/CU/IS/IU。 | downloadFile |
| reasonList | array<string> | 至少一筆；delete 使用 DEL_REASON，close 使用 CLO_REASON。 | execute, executeclose |
| othReason | string | D99/C99 選取時必填；maxlength 100。 | execute, executeclose |
| docNo | string | CAD 查詢文件號碼；需相容 legacy NO。 | queryCAD |
| mainBorrowerName | string | CAD 查詢姓名；trim/upper-case like。 | queryCAD |
| startDecisionDate | date | dd/MM/yyyy；需與 endDecisionDate 成對。 | queryCAD |
| endDecisionDate | date | dd/MM/yyyy；需與 startDecisionDate 成對。 | queryCAD |

## 6.3 Response Schema 草案

| Response | 欄位 | 說明 |
| --- | --- | --- |
| prompt | role flags | isAO、role、isCA、isCRCOSCO、isCOSCO、isCADMERCER。 |
| initQuery | dataList[] | applicationNo、dates、loanType、productName、borrowerName、processName、amount、page、showRelated。 |
| queryCAD | dataList[] | applicationNo、decisionDate、approvalLevel、docNo1、borrowerName、salesChannel、caseProgress、page。 |
| downloadFile | encryptTempFileFullPath | encrypted temp file path；新系統可改為 download token。 |
| reason APIs | dataMap | reason code/display map。 |

## 6.4 Error Response

| HTTP Status | Error Code 草案 | 觸發條件 |
| --- | --- | --- |
| 400 | MISSING_APPLICATION_NO | delete/close/download/setSession 未提供 applicationNo。 |
| 400 | MISSING_REASON | delete/close 未選 reason。 |
| 400 | MISSING_OTHER_REASON | D99/C99 選取但 other reason 空白。 |
| 400 | INVALID_CAD_QUERY_CONDITION | CAD 查詢未提供任何有效條件或日期區間不完整。 |
| 403 | FORBIDDEN_ACTION | 角色無權刪除、結案或下載。 |
| 500 | REDISTRIBUTION_FAILED | CA/CR redistribution transaction 失敗。 |
| 500 | DOWNLOAD_FAILED | proposal 產製或加密失敗。 |

API schema 本章為業務層草案。實作前 RD 需於系統開發規格書補齊 DTO 欄位型別、enum、validation annotation、錯誤訊息 mapping 與 request / response 範例。

## 7. 非功能需求

| 分類 | 需求 |
| --- | --- |
| 效能 | initQuery/queryCAD 需避免無限制大量回傳；CAD 查詢需有條件與日期範圍限制。 |
| 安全 | Backend 必須驗證 role authorization，不得只依前端按鈕顯示控制 delete/close/download。 |
| Audit | prompt、query、download、delete、close、session set/clear 需保留 audit log；資料異動需記錄 processor。 |
| Log | delete/close/redistribution 應記錄 applicationNo、role、processor、reason、old/new caseProgress 與 rollback reason。 |
| Transaction timeout | redistribution 批次更新需設定 timeout 與筆數上限；逾時 rollback。 |
| File handling | downloadFile 不應暴露可重複使用的本機路徑；新系統建議轉 download token。 |

## 8. 測試案例草案

| TC ID | Given | When | Then | DB 驗證點 |
| --- | --- | --- | --- | --- |
| TC-001 | AO role 001 進入 dashboard。 | 呼叫 prompt/initQuery。 | 顯示 AO task list 並可刪除。 | session APPLICATION_NO 清空；查詢排除 D1/R0305/R0313/R0397。 |
| TC-002 | AO role 003 進入 dashboard。 | 載入 task list。 | 不顯示 delete 動作。 | 無 DB 異動。 |
| TC-003 | CA role 101 進入 dashboard 且存在 active CR proxy case。 | 呼叫 prompt。 | 觸發 CA redistribution。 | summary current user 改 CA、CR_CODE 空白、history 新增。 |
| TC-004 | CR role 102 進入 dashboard 且存在過期 proxy stale case。 | 呼叫 prompt。 | 觸發 CR redistribution。 | summary current user 回 CA_CODE、history 新增。 |
| TC-005 | CAD role 404 提供 applicationNo。 | 呼叫 queryCAD。 | 回傳 CAD task list 與 page。 | 只查 current/proxy user 且 loan type in 01/02/03/04。 |
| TC-006 | CAD query 未提供任何條件。 | 呼叫 queryCAD。 | 前後端應拒絕或不允許空查詢。 | 不得執行全量查詢；實作需補 backend validation。 |
| TC-007 | 使用者點選 applicationNo。 | 呼叫 setSession。 | current application context 建立。 | session APPLICATION_NO 正確。 |
| TC-008 | CA 點選 proposal download 且 TYPE=IS。 | 呼叫 downloadFile。 | 回傳 encrypted file reference。 | 無業務 DB 異動；audit log 有 print/download。 |
| TC-009 | delete 未選 reason。 | 呼叫 execute。 | 回傳 missing reason。 | DEL_REASON/history/summary 不得異動。 |
| TC-010 | delete 選 D99 且填 other reason。 | 呼叫 execute。 | 案件刪除成功。 | DEL_REASON、APP_HISTORY 新增；summary CASE_PROGRESS=D1。 |
| TC-011 | CAD close 選 C99 且 IS_AUTODIS=Y。 | 呼叫 executeclose。 | 案件結案成功。 | CLO_REASON、APP_HISTORY 新增；summary CASE_PROGRESS=C1、CURRENT_USER_ID 空白、IS_AUTODIS=YC。 |
| TC-012 | delete transaction 中 history insert 失敗。 | 呼叫 execute。 | 交易 rollback。 | 不得留下 DEL_REASON 或 CASE_PROGRESS=D1。 |
| TC-013 | CAD Maker caseProgress=21。 | 呼叫 queryCAD。 | page=EPROIS_0910。 | response page 正確。 |
| TC-014 | 非授權角色嘗試 close。 | 呼叫 executeclose。 | 應回 403。 | 不得新增 CLO_REASON/history。 |

## 9. Definition of Ready

| 條件 | 狀態 | 說明 |
| --- | --- | --- |
| Role code table 已確認 |  | 包含每個 role 可見欄位與可執行 action。 |
| CASE_PROGRESS code table 已確認 |  | 包含 D1/C1/R0305/R0313/R0397 與 CAD 21~25。 |
| prompt side effect 已決策 |  | 確認 CA/CR redistribution 是否保留及 API method。 |
| CAD DOC_NO/NO mapping 已確認 |  | 避免文件號碼查詢失效。 |
| Delete/close reason code table 已確認 |  | 包含 D99/C99 other reason。 |
| Download file 安全設計已完成 |  | 確認 token/path、授權與檔案有效期限。 |
| Session/routing 遷移策略已確認 |  | 下游頁面改 route param 或暫保留 session。 |
| QA DB 驗證腳本已完成 |  | 涵蓋 query、redistribution、delete、close、download audit。 |
