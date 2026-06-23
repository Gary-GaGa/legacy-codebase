# CDC-EPRO-0001 EPROCSU0170 Credit Evaluation and Credit Decision PRD

| 文件屬性 | 內容 |
| --- | --- |
| 文件名稱 | EPROCSU0170 Credit Evaluation and Credit Decision PRD |
| 目標功能代號 | EPROCSU0170 |
| 舊系統功能代號 | EPROCS_0170、EPROCS_0270、EPROCU_0170、EPROCU_0270 |
| 文件版本 | v1.0 |
| 文件日期 | 2026/06/15 |
| 產出依據 | 舊系統 Source code 掃描、既有 migration inventory、function inventory |
| Evidence 原則 | Source confirmed / Cross-module confirmed / Inferred / TBD / Legacy defect suspect |

# 文件控制

## 修訂記錄

| 版本 | 日期 | 作者 | 說明 |
| --- | --- | --- | --- |
| v1.0 | 2026/06/15 | Codex | 依據四支舊系統功能 source scan 建立 EPROCSU0170 PRD 初版 |

## Review 範圍

| 範圍 | 說明 |
| --- | --- |
| In scope | 公司戶新案/增貸與展期/展變的 Credit Evaluation、Credit Decision、退回、取消、上傳 LLC 文件、列印 Proposal、通知與流程送件行為 |
| In scope | EPROCS_0170、EPROCS_0270、EPROCU_0170、EPROCU_0270 四支 legacy transaction/module/JSP/SQL/DAO 行為整併 |
| In scope | 主要資料表更新、流程狀態、業務規則、驗收測試案例與 legacy defect suspect 記錄 |
| Out of scope | 新 UI 視覺設計、資料庫實體 DDL 調整、信件模板重寫、Scorecard/Collateral Assessment 子系統重構 |

## 待確認事項

| 編號 | Evidence | 待確認內容 | 影響 |
| --- | --- | --- | --- |
| TBD-001 | Inferred | 本 PRD 假設 `EPROCSU0170` 是四支 legacy 功能的整併目標，並以案件類型/異動類型區分 CS/CU 與 0170/0270。 | 影響目標 API、路由、權限與 UI 分頁設計 |
| TBD-002 | Legacy defect suspect | `EPROCS_0270.doPrompt` 使用 `EPROIS_0270` 取得權限屬性，但同檔其他 popup/action 使用 `EPROCS_0270`。 | 影響權限 mapping；需確認 target 是否修正為 `EPROCS_0270` |
| TBD-003 | Legacy defect suspect | CU submit 驗證 `CR_SCORE_CARD_COMPLETED == "YN"`，CS 驗證 `YY`；legacy 註解描述與 CU 條件不一致。 | 影響 CU 案件送審條件，需 PM/SA 確認保留或修正 |
| TBD-004 | Legacy defect suspect | `doUpload` 在非 `DATA_SEQ=0` 路徑存在清空 PK map 後查詢與 `TMP_COMMENT3` 複製 `COMMENT2` 的疑似錯誤。 | 影響歷史留言與上傳檔案關聯 |
| TBD-005 | Legacy defect suspect | `delReturnInfo`、`delFile` 使用 Print 類型 audit log。 | 影響稽核事件分類 |
| TBD-006 | Source confirmed / TBD | UAT 信件可被 legacy 參數導向固定收件人 `chancheauy@kh.cathaybk.com`。 | 影響 target 環境化設定與資訊安全 |
| TBD-007 | TBD | `CAN_REASON`、`CAN_REASON_CU`、`REVISED_ITEM`、`TYPE_OF_LEVEL` 等 code table 顯示文字未在本次 source scan 完整解析。 | UI label 與 UAT 文件需補齊 |

## 目錄

1. 業務需求概述
2. Source Scan 與系統流程
3. 需求矩陣
4. 功能規格
5. API / Interface 規格
6. 資料設計與 Mapping
7. 業務規則
8. 錯誤處理
9. 非功能需求
10. 測試與驗收
11. Source Evidence 與決策紀錄

# 1. 業務需求概述

## 1.1 背景

Legacy E-Proposal 在公司戶徵審流程中，使用四支高度相似的功能支援 Credit Evaluation and Credit Decision：

| Legacy 功能 | 模組 | 業務場景 | 頁面 | Evidence |
| --- | --- | --- | --- | --- |
| EPROCS_0170 | CS | 公司戶新案/增貸 | EPROCS0170.jsp | Source confirmed |
| EPROCS_0270 | CS | 公司戶展期/展變 | EPROCS0270.jsp | Source confirmed |
| EPROCU_0170 | CU | 公司戶新案/增貸或 CU 類案件 | EPROCU0170.jsp | Source confirmed |
| EPROCU_0270 | CU | 公司戶展期/展變或 CU 類案件 | EPROCU0270.jsp | Source confirmed |

本 PRD 定義目標功能 `EPROCSU0170`，以整併方式承接上述四支 legacy 功能的查詢、暫存、送件、退回、取消、通知、上傳與列印需求。

## 1.2 目標

1. 以單一目標需求文件描述 CS/CU 與 0170/0270 的共同流程與差異。
2. 保留 legacy source confirmed 的流程狀態、資料更新與 validation 行為。
3. 將疑似 legacy defect 與來源不足的規則明確標示為 TBD，避免在 target design 中默默猜測。
4. 提供 RD、SA、QA 可直接 review 的功能規格、資料 mapping、測試與驗收條件。

## 1.3 使用者角色

| 角色 | Legacy role/code 線索 | 主要操作 | Evidence |
| --- | --- | --- | --- |
| AO / AO Assistant | `AO_CODE`、`AO_ASSISTANT_CODE` | 檢視案件、接收退回、補件後重新送出 | Source confirmed |
| CR | role `102`、`103` 等 CR 角色 | Credit Evaluation、送審、退回、建議核准條件 | Source confirmed |
| CA | `CA_CODE` | LC/後續流程承接 | Source confirmed |
| Manager / Committee related users | `approvalLevel`、`LEVEL_SUMBIT`、LLC/LC 流程 | 核准層級、LLC/LC decision path | Source confirmed |
| System | notification、AutoDisbursement、audit log | 送信、流程後處理、稽核 | Source confirmed |

## 1.4 成功標準

| 編號 | 成功標準 |
| --- | --- |
| SC-001 | 使用者可依案件類型進入新案/增貸或展期/展變的 Credit Evaluation and Credit Decision 主頁。 |
| SC-002 | 頁面初始化可取得案件基本資料、保證人、擔保品、費用、核准條件、CP 文件、歷史 comment 與下拉選項。 |
| SC-003 | 使用者可暫存 SG evaluation comment、費用、核准條件與必要 collateral/LTV 資料。 |
| SC-004 | Submit/Return/Cancel/Reject/Agreed Proposed/Agreed Suggested/LLC/LC 動作可依 legacy 規則更新案件狀態、歷史與相關資料表。 |
| SC-005 | Return、Cancel、Upload、Delete file、Print proposal、Notification 可被獨立驗收。 |
| SC-006 | Source confirmed 規則皆有驗收案例；TBD 與 legacy defect suspect 不被當成已確認需求。 |

# 2. Source Scan 與系統流程

## 2.1 掃描來源

| 類型 | Source |
| --- | --- |
| Inventory | `eproposal-inventory/function-inventory.csv` |
| CS 0170 transaction | `EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS_0170.java` |
| CS 0270 transaction | `EPROWeb/JavaSource/com/cathaybk/epro/cs/trx/EPROCS_0270.java` |
| CU 0170 transaction | `EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU_0170.java` |
| CU 0270 transaction | `EPROWeb/JavaSource/com/cathaybk/epro/cu/trx/EPROCU_0270.java` |
| CS 0170 module | `EPROWeb/JavaSource/com/cathaybk/epro/cs/module/EPROCS_0170_mod.java` |
| CS 0270 module | `EPROWeb/JavaSource/com/cathaybk/epro/cs/module/EPROCS_0270_mod.java` |
| CU 0170 module | `EPROWeb/JavaSource/com/cathaybk/epro/cu/module/EPROCU_0170_mod.java` |
| CU 0270 module | `EPROWeb/JavaSource/com/cathaybk/epro/cu/module/EPROCU_0270_mod.java` |
| JSP | `EPROCS0170.jsp`、`EPROCS0270.jsp`、`EPROCU0170.jsp`、`EPROCU0270.jsp` |
| SQL | `SQL/com/cathaybk/epro/*/module/com.cathaybk.epro.*.module.EPRO*_0170_mod.*.sql`、`EPRO*_0270_mod.*.sql` |
| Prior analysis | `migration-inventory/EPROCS_0170-業務邏輯分析.md`、`migration-inventory/EPROCU_0170-業務邏輯分析.md` |

## 2.2 Legacy Action Map

| Action | Legacy 用途 | Target 需求分類 | Evidence |
| --- | --- | --- | --- |
| `prompt` | 進入主頁並載入頁面選項、權限、案件狀態 | Page bootstrap | Source confirmed |
| `init` | 查詢案件主資料與頁面明細 | Main data query | Source confirmed |
| `prompt_Pop` | 開啟退回資訊 popup | Return popup | Source confirmed |
| `prompt_Cancel_Pop` | 開啟取消原因 popup | Cancel popup | Source confirmed |
| `queryPop` | 查詢退回/個人相關 popup 資料 | Return query | Source confirmed |
| `getGuarantorMap` | 查詢保證人資料 | Guarantor query | Source confirmed |
| `getCollateralMap` | 查詢擔保品資料 | Collateral query | Source confirmed |
| `countTotalAmount` | 計算金額合計 | Amount calculation | Source confirmed |
| `save` | 暫存 evaluation/comment/fee/terms/collateral | Save draft | Source confirmed |
| `action` | 送件、退回、取消、核准、LLC、LC 流程狀態更新 | Workflow action | Source confirmed |
| `tosendEmail` | 流程後寄送通知並觸發 AutoDisbursement | Notification / post action | Source confirmed |
| `execute` | 儲存退回項目與退回 memo | Return execution | Source confirmed |
| `executeCancel` | 儲存取消原因 | Cancel execution | Source confirmed |
| `delReturnInfo` | 刪除退回資訊 | Return delete | Source confirmed |
| `upload` | 上傳 LLC 文件 | File upload | Source confirmed |
| `printProposal` | 產生/下載 Proposal | Print proposal | Source confirmed |
| `delFile` | 刪除已上傳 LLC 文件 | File delete | Source confirmed |
| `getReason` | 查詢取消原因選項 | Cancel reason options | Source confirmed |
| `getLoanSubSectorCode` | 查詢 loan sub-sector cascade | Dropdown cascade | Source confirmed |
| `getLoanSectionCode` | 查詢 loan section cascade | Dropdown cascade | Source confirmed |

## 2.3 End-to-End 流程

1. 使用者從案件清單或 dashboard 進入 `EPROCSU0170`。
2. 系統依 legacy function/scenario 載入頁面權限、案件狀態、下拉選項、核准層級與必要 flags。
3. 系統查詢案件明細，包含 basic info、guarantor、collateral、loan condition fee/detail、evaluation comment、CP 文件、LLC 歷史與 return/cancel 狀態。
4. 使用者可暫存 draft；暫存不推進流程狀態。
5. 使用者可執行 submit、return、cancel、reject、agreed proposed、agreed suggested、LLC、LC 等 workflow action。
6. 系統依 action 更新 `TB_LON_SUMMARY_INFO`、condition、comment、return/cancel、checkpoint、scorecard/collateral assessment、app history 等資料。
7. 系統執行通知；legacy 在通知流程後觸發 `EPROZ0_0400_mod.AutoDisbursement(APPLICATION_NO, user)`。
8. 使用者可列印 proposal 或維護 LLC 上傳檔案。

## 2.4 四支 Legacy 功能差異

| 差異點 | CS 0170 | CS 0270 | CU 0170 | CU 0270 |
| --- | --- | --- | --- | --- |
| 主要場景 | 新案/增貸 | 展期/展變 | 新案/增貸或 CU 類案件 | 展期/展變或 CU 類案件 |
| JSP | `EPROCS0170.jsp` | `EPROCS0270.jsp` | `EPROCU0170.jsp` | `EPROCU0270.jsp` |
| Before/After revised data | 無 | 有 | 無 | 有 |
| `REF_APPLICATION_NO` | 無 | 有 | 無 | 有 |
| `EPRO_TB_REVISED_ITEM` | 無 | 有 | 無 | 有 |
| LTV / Collateral assessment enforcement | 有 | 有 | 無或註解停用 | 無或註解停用 |
| Checkpoint table | `EPRO_TB_CHECK_POINT_CORP` | `EPRO_TB_CHECK_POINT_RC_CORP` | `EPRO_TB_CHECK_POINT_CU` | `EPRO_TB_CHECK_POINT_RC_CU` |
| Cancel reason code table | `CAN_REASON` | `CAN_REASON` | `CAN_REASON_CU` | `CAN_REASON_CU` |
| Proposal print helper | `EPRO_CS0180` | `EPRO_CS0180` | `EPRO_CU0180` | `EPRO_CU0180` |
| Return deletes SG fee | 未見同 0270 行為 | 有 | 未見同 0270 行為 | 有 |

# 3. 需求矩陣

| Requirement ID | 需求名稱 | 優先級 | Legacy Source | Evidence |
| --- | --- | --- | --- | --- |
| REQ-001 | 整併四支入口與場景識別 | Must | function inventory / trx prompt | Inferred + Source confirmed |
| REQ-002 | Page bootstrap 與權限/下拉載入 | Must | `doPrompt` / `getPrompt` | Source confirmed |
| REQ-003 | 主頁資料初始化 | Must | `doInit` / `getInit` | Source confirmed |
| REQ-004 | 0270 revised before/after 資料 | Must | `EPROCS_0270_mod` / `EPROCU_0270_mod` | Source confirmed |
| REQ-005 | 暫存 draft | Must | `save` | Source confirmed |
| REQ-006 | Workflow action 狀態推進 | Must | `action` / `getSInfoMap` | Source confirmed |
| REQ-007 | Submit validation | Must | JSP validation / module validation | Source confirmed |
| REQ-008 | Return info 維護 | Must | `execute` / `delReturnInfo` | Source confirmed |
| REQ-009 | Cancel reason 維護 | Must | `getReason` / `executeCancel` | Source confirmed |
| REQ-010 | LLC 檔案上傳與刪除 | Must | `upload` / `delFile` | Source confirmed |
| REQ-011 | Proposal 列印 | Must | `printProposal` | Source confirmed |
| REQ-012 | 金額計算與 loan sector cascade | Should | `countTotalAmount` / cascade actions | Source confirmed |
| REQ-013 | 通知與 AutoDisbursement | Must | `tosendEmail` / `sendEmail` | Source confirmed |
| REQ-014 | Audit log | Must | transaction audit setup | Source confirmed |
| REQ-015 | Legacy defect suspect 處理 | Must | source scan findings | Legacy defect suspect |

# 4. 功能規格

## REQ-001 整併四支入口與場景識別

| 項目 | 內容 |
| --- | --- |
| Description | Target `EPROCSU0170` 必須可承接 legacy `EPROCS_0170`、`EPROCS_0270`、`EPROCU_0170`、`EPROCU_0270` 四種場景。 |
| Trigger | 使用者從案件清單、dashboard 或流程 task 進入 Credit Evaluation and Credit Decision。 |
| Actor | AO、CR、CA、Manager、System |
| Source | `function-inventory.csv`、四支 transaction `doPrompt` |
| Evidence | Inferred + Source confirmed |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-001-01 | 系統可依輸入 context 辨識 `caseDomain=CS/CU` 與 `caseScenario=0170/0270`。 |
| AC-001-02 | `0170` 場景不要求 `REF_APPLICATION_NO`；`0270` 場景需支援原案 `REF_APPLICATION_NO` 與 revised item。 |
| AC-001-03 | CS 與 CU 差異規則不可硬編碼成單一路徑導致 legacy 行為遺失。 |
| AC-001-04 | 若 target 決定拆 API 或拆頁面，仍須保留本 PRD 規則矩陣中的四場景驗收。 |

## REQ-002 Page Bootstrap 與權限/下拉載入

| 項目 | 內容 |
| --- | --- |
| Description | 進入頁面時，系統載入權限屬性、案件狀態、核准層級、使用者角色、下拉選項與頁面判斷 flags。 |
| Trigger | Page load / `prompt` |
| Source | transaction `doPrompt`、module `getPrompt` |
| Evidence | Source confirmed |

### 系統輸出

| 類別 | 欄位或資料 | 說明 |
| --- | --- | --- |
| 權限 | `attrMap` | 依 function ID 與 role 取得頁面控制屬性。 |
| 使用者 | `ROLE_ID`、`empList` | 依 role 與流程選出可派送人員。 |
| 案件 | `CASE_PROGRESS`、`approvalLevel`、`LEVEL`、`LEVEL_SUMBIT` | 決定按鈕、下一關與核准層級。 |
| 下拉 | `loanPurposeMap`、`loanTypeMap`、`facilityTypeMap`、`repaymentModeMap`、`repaymentFrequencyMap`、`ccyMap`、`loanSectorMap` | Legacy common field option maps。 |
| CS/0170 flags | `isHousingLoan`、`isAfterOnlineDate`、`isAfterOnlineDate02`、`isAfterVer0200`、`isAfterVer0210`、`isAfterVer0211` | 版本/日期相關 UI 與 validation 判斷。 |
| 0270 flags | `REF_APPLICATION_NO`、`loanTypeMapRC`、`isCR` | 0270 revised case 額外資料。 |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-002-01 | 系統回傳頁面初始化所需 option map，且 code/value 與 legacy common field 一致。 |
| AC-002-02 | 系統回傳 `CASE_PROGRESS` 與 role，使前端可判斷可執行按鈕。 |
| AC-002-03 | 0270 場景需回傳 `REF_APPLICATION_NO` 與 `loanTypeMapRC`。 |
| AC-002-04 | `EPROCS_0270` 權限 function ID 疑似錯誤需在 target 設計前決議；未決議前不得默默採用 `EPROIS_0270`。 |

## REQ-003 主頁資料初始化

| 項目 | 內容 |
| --- | --- |
| Description | 系統依 `APPLICATION_NO` 查詢主頁顯示與編輯所需資料。 |
| Trigger | Page init / `init` |
| Source | transaction `doInit`、module `getInit` |
| Evidence | Source confirmed |

### 查詢資料

| 類別 | Legacy output | 說明 |
| --- | --- | --- |
| 基本資料 | `basicQuery` | 案件摘要、客戶、流程、授信基本資料。 |
| 保證人 | `guarantorSelect`、`initGuarantor` | 保證人清單與初始化資料。 |
| 擔保品 | `collateralSelect`、`initCollateral` | CS 場景需支援 LTV/Collateral Assessment linkage。 |
| Deviation | `initDeviation` | 授信偏離或例外相關資料。 |
| 費用 | `initFees`、`editFees` | AO/SG condition fee；編輯預設由 SG 優先，否則 AO。 |
| 核准條件 | `initApprovedTerms`、`editApprovedTerms` | AO/SG condition detail；編輯預設由 SG 優先，否則 AO。 |
| 其他 | `otherMap`、`lvtInfo` | 其他頁面區塊與 LTV 資訊。 |
| CP 文件 | `approvedCP` | 已核准 CP upload file list，download path/name 需加密。 |
| Comment | `historyOfComment`、`COMMENT`、`DATA_SEQ` | `SG` evaluation comment，`DATA_SEQ=0` 為目前編輯資料。 |
| Session | `NOW_DATE`、`USER_INFO` | 畫面預設日期與使用者顯示字串。 |
| Return | `seqNoList`、`isReturnFinished` | 退回歷史與是否尚有未完成退回項目。 |
| Role | `isCR` | CR 操作者判斷。 |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-003-01 | `APPLICATION_NO` 不可空白；空白時回傳 legacy 對應錯誤。 |
| AC-003-02 | 系統可同時回傳顯示用資料與編輯用 SG/AO default 資料。 |
| AC-003-03 | `EPRO_TB_LOAN_EVAL_COMMENT.TYPE=SG, DATA_SEQ=0` 的 `TMP_COMMENT1-3` 必須合併為畫面 comment。 |
| AC-003-04 | CP 文件 download path/name 不得以明碼檔案路徑暴露。 |

## REQ-004 0270 Revised Before/After 資料

| 項目 | 內容 |
| --- | --- |
| Description | 0270 場景需呈現展期/展變前後資料，並追蹤原案與原條件資料。 |
| Trigger | 0270 page init / save / action |
| Source | `EPROCS_0270_mod`、`EPROCU_0270_mod` |
| Evidence | Source confirmed |

### 功能需求

| 編號 | 需求 |
| --- | --- |
| FR-004-01 | 系統需查詢 `EPRO_TB_REVISED_ITEM`，輸出 `revisedType`、`revisedTypeSize`、`revisedItemMap`。 |
| FR-004-02 | 系統需依 `REF_APPLICATION_NO` 查詢 before guarantor、before collateral、before fee、before approved terms。 |
| FR-004-03 | 儲存或送件時，系統需保留 `ORI_APPLICATION_NO`、`ORI_CON_TYPE`、`ORI_SEQNO` 以追溯原條件。 |
| FR-004-04 | 0270 return/cancel 路徑對 fee/detail 的刪除行為需依 legacy 差異驗收。 |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-004-01 | 0270 場景的 init response 必須包含 revised item 與 before/after 資料。 |
| AC-004-02 | 0170 場景不可強制要求 revised item。 |
| AC-004-03 | 0270 儲存 SG detail 時需寫入原案 reference 欄位。 |

## REQ-005 暫存 Draft

| 項目 | 內容 |
| --- | --- |
| Description | 使用者可暫存 evaluation comment、fee、approved terms、summary info 與 CS collateral/LTV 資料。 |
| Trigger | Save button / `save` |
| Source | module `save` |
| Evidence | Source confirmed |

### Save 行為

| 資料 | 行為 |
| --- | --- |
| `SINFO` | 更新 `EPRO_TB_LON_SUMMARY_INFO`；`MEETING_DATE` 由 `dd/MM/yyyy` 轉 SQL date。 |
| `FEE` | upsert `EPRO_TB_LOAN_CONDITION_FEE`，`OTHER_FEE` 拆分為多個欄位。 |
| `DETAIL` | upsert `EPRO_TB_LOAN_CONDITION_DETAIL`。 |
| `EVAL` | upsert `EPRO_TB_LOAN_EVAL_COMMENT`，`TYPE=SG`，`DATA_SEQ=0`，comment 拆分為 `TMP_COMMENT1-3`。 |
| `COLL` | CS 0170/0270 更新 `EPRO_TB_COLL_LTV`；CU source 未見同等啟用邏輯。 |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-005-01 | Save 不得推進 `CASE_PROGRESS`。 |
| AC-005-02 | Save 必須在同一交易中寫入 summary、fee、detail、comment 與必要 collateral/LTV。 |
| AC-005-03 | Comment 超過單欄可存長度時需依 legacy split 規則寫入 `TMP_COMMENT1-3`。 |
| AC-005-04 | Save 成功後畫面重新查詢應可看到已暫存資料。 |

## REQ-006 Workflow Action 狀態推進

| 項目 | 內容 |
| --- | --- |
| Description | 使用者執行流程按鈕時，系統依 `NEW_CASE_PROGRESS` 更新案件狀態與相關資料。 |
| Trigger | Submit / Return / Cancel / Reject / Agreed / LLC / LC button |
| Source | module `action`、`getSInfoMap` |
| Evidence | Source confirmed |

### CASE_PROGRESS Mapping

| `NEW_CASE_PROGRESS` | Legacy 語意 | Summary update |
| --- | --- | --- |
| `06` | Submit / 送下一關 | 依 role/approval routing 指定下一位處理者；需檢查 scorecard 與 related party。 |
| `08` | Agreed Proposed | `CURRENT_USER_ID=""`、`FIN_APPR_LEVEL` 依 role mapping、`DECISION_DATE=now`、`APP_CON_TYPE=AO`。 |
| `09` | Agreed Suggested | `CURRENT_USER_ID=""`、`FIN_APPR_LEVEL` 依 role mapping、`DECISION_DATE=now`、`APP_CON_TYPE=SG`。 |
| `95` | To LC | `CURRENT_USER_ID=CA_CODE`、`IS_LC=Y`。 |
| `96` | Reject | `CURRENT_USER_ID=""`、`DECISION_DATE=now`。 |
| `97` | To LLC | `CURRENT_USER_ID=CR_CODE`、`IS_LLC=Y`。 |
| `98` | Return | CR return 指回 AO/AO Assistant；non-CR return 指回 CR，並執行 return cleanup。 |
| `99` | Cancel | `CURRENT_USER_ID=""`、`DECISION_DATE=now`。 |

### Action 資料寫入

| 資料 | 行為 |
| --- | --- |
| Summary | 更新 `EPRO_TB_LON_SUMMARY_INFO.CASE_PROGRESS`、`CURRENT_USER_ID`、`RECEIVED_DATE` 與 action-specific 欄位。 |
| Fee/detail | 一般 action upsert SG fee/detail；return/cancel 依 0170/0270 差異刪除或保留。 |
| Evaluation comment | upsert `DATA_SEQ=0`，並新增一筆歷史 comment。 |
| Return info | return 時更新或清除 `EPRO_TB_RETURN_INFO`。 |
| Scorecard | return 時清空 CR scorecard fields，並依場景更新 checkpoint。 |
| Collateral assessment | CS 場景 return 時清除 collateral assessment CR fields 與 checkpoint。 |
| History | 新增 `EPRO_TB_APP_HISTORY`。 |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-006-01 | `NEW_CASE_PROGRESS` 不可空白；空白時回傳 validation error。 |
| AC-006-02 | 每次成功 action 必須新增 app history。 |
| AC-006-03 | `08` 與 `09` 必須分別設定 `APP_CON_TYPE=AO` 與 `APP_CON_TYPE=SG`。 |
| AC-006-04 | Return 需依 CR/non-CR 與 CS/CU、0170/0270 差異執行 cleanup。 |
| AC-006-05 | Action 與通知可分段執行，但不得造成 action 成功後 history 或 summary 狀態遺漏。 |

## REQ-007 Submit Validation

| 項目 | 內容 |
| --- | --- |
| Description | Submit/approval 類 action 前需驗證必要條件。 |
| Trigger | `action` with `NEW_CASE_PROGRESS` |
| Source | JSP validation、module `action` |
| Evidence | Source confirmed |

### Validation Rules

| Rule ID | 條件 | 驗證 |
| --- | --- | --- |
| VAL-001 | `NEW_CASE_PROGRESS=06` 且操作者為 CR | CS 要求 `CR_SCORE_CARD_COMPLETED=YY`；CU 要求 `YN`，但標示 TBD。 |
| VAL-002 | 存在 related party `IS_Y=Y` | `CR_RELATED_PARTY_COMPLETED` 必須為 `Y`。 |
| VAL-003 | CS 且流程為 `06/08/09/97/95` | 若 housing loan，需依 credit rating、collateral grade 與 LTV 計算檢查 SG coverage。 |
| VAL-004 | 需要退回 | 必須先透過 return popup 建立 return info。 |
| VAL-005 | 需要取消 | 必須選擇取消原因。 |
| VAL-006 | 需要 LLC 文件 | JSP 會要求先上傳文件。 |
| VAL-007 | 需要下一關 | `approvalLevel` 與 `nextEmp` 依畫面狀態為必填。 |
| VAL-008 | `MEETING_DATE` | 格式為 `dd/MM/yyyy`。 |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-007-01 | 未完成 CR scorecard 時，Submit 不可成功。 |
| AC-007-02 | Related party 未完成時，Submit 不可成功。 |
| AC-007-03 | CS housing loan 超過 LTV level 時，對應 action 不可成功。 |
| AC-007-04 | Validation error 必須回傳可對應 legacy message code 或 target error code。 |

## REQ-008 Return Info 維護

| 項目 | 內容 |
| --- | --- |
| Description | 使用者可建立、查詢、刪除退回資訊，並在 return action 中套用。 |
| Trigger | `prompt_Pop`、`queryPop`、`execute`、`delReturnInfo`、`action=98` |
| Source | transaction/module return methods |
| Evidence | Source confirmed |

### 功能需求

| 編號 | 需求 |
| --- | --- |
| FR-008-01 | Return popup 需查詢可退回項目與既有 return info。 |
| FR-008-02 | `execute` 儲存時，若 `RETURN_STATUS=Y`，使用者必須選取 return item。 |
| FR-008-03 | Return item 以分號串接為 `RETURN_CODE`。 |
| FR-008-04 | 若已有未完成退回資料，系統需更新；否則新增下一個 `SEQNO`。 |
| FR-008-05 | `delReturnInfo` 可依 `APPLICATION_NO` 與 `SEQNO` 刪除退回資料。 |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-008-01 | 未選 return item 時不可儲存未完成退回資訊。 |
| AC-008-02 | Return action 成功後，CR return 的舊 `RETURN_STATUS=Y` 需改為 `R` 並寫入 return date。 |
| AC-008-03 | 刪除 return info 後重新查詢不可看到已刪資料。 |

## REQ-009 Cancel Reason 維護

| 項目 | 內容 |
| --- | --- |
| Description | 使用者取消案件時必須維護取消原因。 |
| Trigger | `prompt_Cancel_Pop`、`getReason`、`executeCancel`、`action=99` |
| Source | transaction/module cancel methods |
| Evidence | Source confirmed |

### 功能需求

| 編號 | 需求 |
| --- | --- |
| FR-009-01 | CS 場景讀取 `CAN_REASON`；CU 場景讀取 `CAN_REASON_CU`。 |
| FR-009-02 | 使用者至少需選擇一個取消原因。 |
| FR-009-03 | 多個原因以分號串接寫入 `REASON_CODE`。 |
| FR-009-04 | 系統先刪除同案件舊取消原因，再新增最新取消原因、日期與其他原因說明。 |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-009-01 | 未選取消原因時不可儲存。 |
| AC-009-02 | CU 與 CS 使用不同 reason code table。 |
| AC-009-03 | 重複執行 cancel reason 儲存時，資料表只保留最新一筆理由集合。 |

## REQ-010 LLC 檔案上傳與刪除

| 項目 | 內容 |
| --- | --- |
| Description | 使用者可上傳或刪除 LLC 相關附件。 |
| Trigger | `upload`、`delFile` |
| Source | module `doUpload`、`delFile` |
| Evidence | Source confirmed + Legacy defect suspect |

### 功能需求

| 編號 | 需求 |
| --- | --- |
| FR-010-01 | 上傳檔名以 `{APPLICATION_NO}LLC{extension}` 建立暫存檔。 |
| FR-010-02 | 系統將 file path/name 寫入 `EPRO_TB_LOAN_EVAL_COMMENT.UPLOAD_FILE_PATH`、`UPLOAD_FILE_NAME`。 |
| FR-010-03 | 若 `DATA_SEQ` 空白，legacy 預設 `DATA_SEQ=0`。 |
| FR-010-04 | 刪除時需清空資料表 path/name，並刪除實體檔案。 |
| FR-010-05 | 非 `DATA_SEQ=0` 的 legacy 程式碼有疑似 defect；target 行為需另行確認。 |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-010-01 | 上傳成功後，頁面 init 可取得上傳檔案名稱。 |
| AC-010-02 | 刪除成功後，資料表 path/name 應為空，實體檔案不存在。 |
| AC-010-03 | 不得讓使用者下載未授權或明碼 filesystem path。 |

## REQ-011 Proposal 列印

| 項目 | 內容 |
| --- | --- |
| Description | 使用者可列印或下載 proposal。 |
| Trigger | `printProposal` |
| Source | transaction/module `printProposal` |
| Evidence | Source confirmed |

### 功能需求

| 編號 | 需求 |
| --- | --- |
| FR-011-01 | CS 場景使用 `EPRO_CS0180.printProposal(APPLICATION_NO)` 對應邏輯。 |
| FR-011-02 | CU 場景使用 `EPRO_CU0180.printProposal(APPLICATION_NO)` 對應邏輯。 |
| FR-011-03 | 回傳給前端的 temp file path/name 必須加密或以安全 token 表示。 |
| FR-011-04 | 列印需記錄 audit log。 |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-011-01 | 有效案件可產出 proposal 檔案連結。 |
| AC-011-02 | 無效案件或產檔失敗時回傳明確錯誤，不產生空白下載。 |

## REQ-012 金額計算與 Loan Sector Cascade

| 項目 | 內容 |
| --- | --- |
| Description | 系統需支援畫面金額合計與 loan sector/sub-sector/section 連動選單。 |
| Trigger | `countTotalAmount`、`getLoanSubSectorCode`、`getLoanSectionCode` |
| Source | transaction/module methods |
| Evidence | Source confirmed |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-012-01 | 使用者修改相關金額欄位後，可取得與 legacy 一致的合計結果。 |
| AC-012-02 | 選擇 loan sector 後，可查詢對應 sub-sector。 |
| AC-012-03 | 選擇 loan sub-sector 後，可查詢對應 loan section。 |

## REQ-013 通知與 AutoDisbursement

| 項目 | 內容 |
| --- | --- |
| Description | Workflow action 後，系統需依 legacy 規則建立通知、必要時呼叫 email service，並觸發 AutoDisbursement。 |
| Trigger | `tosendEmail` |
| Source | module `tosendEmail`、`sendEmail` |
| Evidence | Source confirmed |

### 通知規則

| 條件 | 收件人 |
| --- | --- |
| `CASE_PROGRESS` 屬於 `08,09,14,96,99` | AO、AO Assistant、Manager、Account Office 相關人員 |
| 其他流程狀態 | `CURRENT_USER_ID` |
| UAT/PROD | 可呼叫外部 email URL |
| UAT 且 `SEND_EMAIL=YES` | legacy 可導向固定測試收件人，需 target 環境化確認 |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-013-01 | Action 成功後，系統可建立 `EPRO_TB_NOTIFICATION_INFO` 對應通知。 |
| AC-013-02 | 非 UAT/PROD 環境不得誤送外部信件。 |
| AC-013-03 | AutoDisbursement side effect 必須保留或由 target 架構明確替代。 |

## REQ-014 Audit Log

| 項目 | 內容 |
| --- | --- |
| Description | Target 需保留 legacy audit log 目的與敏感欄位控管。 |
| Trigger | Query / Edit / Add / Transfer / Print actions |
| Source | transaction audit log setup |
| Evidence | Source confirmed |

### Audit 要求

| 動作 | Legacy audit 分類 |
| --- | --- |
| `prompt` / `init` / query actions | Query |
| `save` | Edit/Add |
| `action` | Transfer |
| `upload` | Edit/Add |
| `printProposal` | Print |
| `delReturnInfo` / `delFile` | Legacy 使用 Print，標示待確認 |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-014-01 | 查詢類動作需記錄敏感查詢欄位，包含 id/name/birthday/address 類資訊。 |
| AC-014-02 | 流程狀態異動需可追蹤操作者、時間與案件號。 |
| AC-014-03 | Delete 類動作 audit 分類需由資安/稽核確認。 |

## REQ-015 Legacy Defect Suspect 處理

| 項目 | 內容 |
| --- | --- |
| Description | 對 source scan 中發現的疑似 legacy defect，target 不得未經確認直接複製或修正。 |
| Trigger | SA/RD design review |
| Source | source scan findings |
| Evidence | Legacy defect suspect |

### Acceptance Criteria

| 編號 | 驗收條件 |
| --- | --- |
| AC-015-01 | 每項 legacy defect suspect 必須有 PM/SA 決議後才能進入開發規格。 |
| AC-015-02 | 若決議保留 legacy 行為，需在測試案例中明確標示 backward compatibility。 |
| AC-015-03 | 若決議修正 legacy 行為，需建立 regression test 防止回歸。 |

# 5. API / Interface 規格

## 5.1 Target API 建議

Target API 命名可依實際架構調整；本節描述需求面的 interface 能力，不強制技術路由。

| API capability | Legacy action | Method 建議 | Request key | Response key |
| --- | --- | --- | --- | --- |
| Page bootstrap | `prompt` | GET | `applicationNo`、`caseDomain`、`caseScenario` | option maps、role、case progress、permissions、flags |
| Main init | `init` | GET | `applicationNo`、`caseDomain`、`caseScenario` | basic、guarantor、collateral、fees、terms、comments、files |
| Save draft | `save` | POST | `applicationNo`、`sinfo`、`fee`、`detail`、`eval`、`coll` | success/error |
| Workflow action | `action` | POST | `applicationNo`、`newCaseProgress`、draft payload | updated case status、history result |
| Send notification | `tosendEmail` | POST / event | `applicationNo`、`caseProgress` | notification result |
| Return popup query | `queryPop` | GET | `applicationNo`、`seqNo` | return item list、return info |
| Return save | `execute` | POST | `applicationNo`、`itemList`、memo | return info result |
| Return delete | `delReturnInfo` | DELETE | `applicationNo`、`seqNo` | success/error |
| Cancel reason options | `getReason` | GET | `caseDomain` | reason option map |
| Cancel save | `executeCancel` | POST | `applicationNo`、`reasonList`、`othReason` | cancel reason result |
| Upload LLC file | `upload` | POST multipart | `applicationNo`、`dataSeq`、file | file metadata |
| Delete LLC file | `delFile` | DELETE | `applicationNo`、`dataSeq` | success/error |
| Print proposal | `printProposal` | POST/GET | `applicationNo`、`caseDomain` | secure download token |
| Amount calculation | `countTotalAmount` | POST | amount fields | total amount |
| Loan sector cascade | `getLoanSubSectorCode`、`getLoanSectionCode` | GET | selected code | option map |

## 5.2 Request Context

| 欄位 | 必填 | 說明 |
| --- | --- | --- |
| `applicationNo` | Yes | 案件號；legacy 多數方法以 `APPLICATION_NO` 為主鍵。 |
| `caseDomain` | Yes | `CS` 或 `CU`。 |
| `caseScenario` | Yes | `0170` 或 `0270`。 |
| `newCaseProgress` | Workflow action required | 送件目標狀態。 |
| `roleId` | Server derived | 應由登入 session 或 token 解析，不信任前端傳入。 |
| `userId` | Server derived | 操作者 ID。 |
| `branchId` | Server derived | 操作者分行。 |

## 5.3 Error Response

| 欄位 | 說明 |
| --- | --- |
| `code` | Target error code；可 mapping legacy message code。 |
| `message` | 前端可顯示訊息。 |
| `legacyMessageCode` | 若由 legacy rule 轉換，保留原 message code 便於 UAT 對照。 |
| `field` | 欄位型錯誤時回傳欄位名稱。 |
| `severity` | `ERROR` / `WARNING` / `INFO`。 |

# 6. 資料設計與 Mapping

## 6.1 主要資料表

| Table / DAO | 用途 | 主要行為 | Evidence |
| --- | --- | --- | --- |
| `EPRO_TB_LON_SUMMARY_INFO` | 案件主檔與流程狀態 | 查詢、更新 `CASE_PROGRESS`、current user、decision date、APP_CON_TYPE | Source confirmed |
| `EPRO_TB_LOAN_CONDITION_FEE` | 費用條件 | AO/SG fee 查詢與 upsert；0270 return 會刪除 SG fee | Source confirmed |
| `EPRO_TB_LOAN_CONDITION_DETAIL` | 核准條件明細 | AO/SG detail 查詢與 upsert；return 會刪除 SG detail | Source confirmed |
| `EPRO_TB_LOAN_EVAL_COMMENT` | Credit evaluation comment 與 LLC file | `TYPE=SG`、`DATA_SEQ=0` 現行 comment；歷史 comment；file path/name | Source confirmed |
| `EPRO_TB_COLL_LTV` | CS LTV 資料 | CS save/action 更新與清空 SG coverage | Source confirmed |
| `EPRO_TB_RETURN_INFO` | 退回資訊 | 儲存 return code/memo/status/date | Source confirmed |
| `EPRO_TB_CAN_REASON` | 取消原因 | 刪除舊資料後新增 reason code/date/other reason | Source confirmed |
| `EPRO_TB_APP_HISTORY` | 流程歷史 | action 成功新增 history | Source confirmed |
| `EPRO_TB_NOTIFICATION_INFO` | 通知 | email notification 建立 | Source confirmed |
| `EPRO_TB_CHECK_POINT_CORP` | CS 0170 checkpoint | return cleanup | Source confirmed |
| `EPRO_TB_CHECK_POINT_RC_CORP` | CS 0270 checkpoint | return cleanup | Source confirmed |
| `EPRO_TB_CHECK_POINT_CU` | CU 0170 checkpoint | return cleanup | Source confirmed |
| `EPRO_TB_CHECK_POINT_RC_CU` | CU 0270 checkpoint | return cleanup | Source confirmed |
| `EPRO_TB_REVISED_ITEM` | 0270 revised items | 查詢展期/展變項目 | Source confirmed |
| `EPRO_TB_UPLOAD_FILE_PTH` | CP 文件路徑 | 查詢 approved CP files | Source confirmed |
| `EPRO_TB_IND_SCRCARD` / `EPRO_TB_CORP_SCRCARD` | Scorecard | submit validation、return cleanup | Source confirmed |
| `EPRO_TB_COLL_ASS` | Collateral assessment | CS submit LTV validation、return cleanup | Source confirmed |
| `EPRO_TB_LTV` | LTV level | CS housing loan level 查詢 | Source confirmed |

## 6.2 Comment Mapping

| Target logical field | Legacy table/field | 說明 |
| --- | --- | --- |
| `evaluationComment` | `TMP_COMMENT1` + `TMP_COMMENT2` + `TMP_COMMENT3` | 畫面顯示合併 comment。 |
| `commentType` | `TYPE` | Credit evaluation 使用 `SG`；LLC history 依流程可能使用 `LLC`。 |
| `dataSeq` | `DATA_SEQ` | `0` 為目前編輯資料；歷史資料使用遞增 seq。 |
| `uploadFilePath` | `UPLOAD_FILE_PATH` | 實體路徑，不應直接暴露給前端。 |
| `uploadFileName` | `UPLOAD_FILE_NAME` | 顯示用檔名。 |
| `updatedBy` | `UPD_USER` | 操作者。 |
| `updatedAt` | `UPD_TIME` | 更新時間。 |

## 6.3 Workflow Side Effects

| Action | Side effect |
| --- | --- |
| Save | 更新 summary、fee、detail、comment、CS LTV。 |
| Submit `06` | 驗證 scorecard/related party；更新 summary；新增 history；必要時清除完成退回資料。 |
| Return `98` | 刪除 SG detail；0270 也刪除 SG fee；清 scorecard；CS 清 collateral assessment；更新 checkpoint；新增 history。 |
| Cancel `99` | 設定 decision date、current user empty；取消原因另由 `executeCancel` 維護。 |
| Agreed `08/09` | 設定 `FIN_APPR_LEVEL`、`DECISION_DATE`、`APP_CON_TYPE`。 |
| LLC `97` | 設定 `IS_LLC=Y`，current user 指向 CR。 |
| LC `95` | 設定 `IS_LC=Y`，current user 指向 CA。 |
| Notification | 建立 notification info；UAT/PROD 可能呼叫 email URL；呼叫 AutoDisbursement。 |

# 7. 業務規則

| Rule ID | 規則 | Evidence |
| --- | --- | --- |
| BR-001 | `APPLICATION_NO` 是所有主要 query/save/action 的必要輸入。 | Source confirmed |
| BR-002 | 0170 使用目前案件資料；0270 需同時參考 `REF_APPLICATION_NO` 與 revised item。 | Source confirmed |
| BR-003 | Edit fee/detail 預設使用 SG；若 SG 不存在則使用 AO。 | Source confirmed |
| BR-004 | Evaluation comment 以 `TYPE=SG`、`DATA_SEQ=0` 代表目前編輯版本。 | Source confirmed |
| BR-005 | `NEW_CASE_PROGRESS=08` 時核准條件採 AO proposed，`APP_CON_TYPE=AO`。 | Source confirmed |
| BR-006 | `NEW_CASE_PROGRESS=09` 時核准條件採 SG suggested，`APP_CON_TYPE=SG`。 | Source confirmed |
| BR-007 | Return `98` 會清除或重置 scorecard/related workflow completion 狀態。 | Source confirmed |
| BR-008 | CR return 指回 AO Assistant；若無 AO Assistant 則指回 AO。 | Source confirmed |
| BR-009 | Non-CR return 指回 CR。 | Source confirmed |
| BR-010 | CS housing loan 需依 credit rating、collateral grade 與 LTV level 驗證 SG coverage。 | Source confirmed |
| BR-011 | CU LTV enforcement 在 source 中未見與 CS 相同的啟用邏輯；target 不應直接套用 CS 規則到 CU。 | Source confirmed |
| BR-012 | 0270 return 需刪除 SG fee 與 SG detail；0170 source 僅確認刪除 SG detail。 | Source confirmed |
| BR-013 | Cancel reason CS/CU 使用不同 common field code。 | Source confirmed |
| BR-014 | Return code 與 cancel reason code 以分號串接多選項。 | Source confirmed |
| BR-015 | Proposal print helper 依 CS/CU 分流。 | Source confirmed |
| BR-016 | Notification 在 case progress `08,09,14,96,99` 走 AO/AO assistant/manager/account office 收件邏輯，其餘走 current user。 | Source confirmed |
| BR-017 | `tosendEmail` 後存在 AutoDisbursement side effect。 | Source confirmed |
| BR-018 | `EPROCS_0270` 權限 function ID 疑似誤植，需在 target 決議。 | Legacy defect suspect |
| BR-019 | CU scorecard completion 驗證值 `YN` 需 PM/SA 確認。 | Legacy defect suspect |

# 8. 錯誤處理

| 場景 | Legacy message / 行為 | Target 處理 |
| --- | --- | --- |
| `APPLICATION_NO` 空白 | `COMMON_MSG_ERROR_LON` | 回傳 validation error，禁止 query/save/action。 |
| `NEW_CASE_PROGRESS` 空白 | module validation error | 回傳 validation error，禁止 action。 |
| Return 未選 item | `EPROCS0170_MSG_009` | 回傳 validation error，提示需選擇退回項目。 |
| Cancel 未選 reason | `EPROZ00100_MSG_REASON` | 回傳 validation error，提示需選擇取消原因。 |
| Related party 未完成 | `COMMON_MSG_RELATED_YET` | 回傳 validation error，禁止 submit。 |
| LTV level 查無資料或為 0 | `EPROI00113_MSG_ERROR_LEVEL` | 回傳 validation error，禁止 CS 指定 action。 |
| SG coverage 超過 LTV level | `EPROIS0170_UI_MSG_ERROR_DEVIATION` | 回傳 validation error，禁止 CS 指定 action。 |
| Upload 寫檔失敗 | legacy exception | 回傳 file upload error，不更新 DB 或需 rollback。 |
| Print 產檔失敗 | legacy exception | 回傳 print error，不產生下載 token。 |
| Email service 失敗 | legacy 可能記錄 exception | Target 需定義 action 成功但通知失敗時的 retry/補償策略。 |

# 9. 非功能需求

## 9.1 Transaction

| 編號 | 需求 |
| --- | --- |
| NFR-001 | Save/action 對 summary、fee、detail、comment、history 等多表寫入需維持交易一致性。 |
| NFR-002 | Return cleanup 涉及 scorecard、checkpoint、collateral assessment 時，任一關鍵更新失敗應 rollback。 |
| NFR-003 | File upload 的 DB update 與實體檔案寫入需有補償或一致性策略。 |

## 9.2 Security

| 編號 | 需求 |
| --- | --- |
| NFR-004 | 使用者 ID、role、branch 不得信任前端輸入，需由 server session/token 解析。 |
| NFR-005 | Download/print/upload file path 不得直接暴露明碼 filesystem path。 |
| NFR-006 | Audit log 需記錄敏感查詢欄位與流程異動。 |
| NFR-007 | UAT/PROD email routing 需以環境設定控管，避免測試收件人進入 production。 |

## 9.3 Performance

| 編號 | 需求 |
| --- | --- |
| NFR-008 | 主頁 init 查詢包含多組明細，target 應避免無必要的重複查詢。 |
| NFR-009 | Dropdown options 可快取，但需保留 code table 更新後可刷新機制。 |
| NFR-010 | Print proposal 與 email service 可採非同步，但需回傳可追蹤狀態。 |

## 9.4 Compatibility

| 編號 | 需求 |
| --- | --- |
| NFR-011 | Target 欄位與資料表 mapping 需支援 legacy 資料直接查詢。 |
| NFR-012 | 若修正 legacy defect suspect，需建立 migration/compatibility 說明。 |
| NFR-013 | Message code 與 UAT 驗收應可追溯 legacy 行為。 |

# 10. 測試與驗收

## 10.1 Positive Test Cases

| Test ID | 場景 | 步驟 | 預期結果 |
| --- | --- | --- | --- |
| TC-P-001 | CS 0170 init | 以有效 CS 0170 案件進入頁面 | 回傳 basic、guarantor、collateral、fee、detail、comment、CP file、role/options。 |
| TC-P-002 | CS 0270 init | 以有效 CS 0270 案件進入頁面 | 除主資料外，回傳 `REF_APPLICATION_NO`、revised item、before fee/detail/guarantor/collateral。 |
| TC-P-003 | CU 0170 init | 以有效 CU 0170 案件進入頁面 | 回傳 CU 場景資料，且不套用 CS-only LTV enforcement 到 CU。 |
| TC-P-004 | CU 0270 init | 以有效 CU 0270 案件進入頁面 | 回傳 CU revised item 與 before/after 資料。 |
| TC-P-005 | Save draft | 修改 comment、fee、detail 後暫存 | DB 寫入 SG comment/fee/detail；重新 init 可看到修改內容。 |
| TC-P-006 | Submit `06` | CR 完成必要檢核後送件 | Summary 更新、history 新增、通知可建立。 |
| TC-P-007 | Agreed proposed `08` | 執行同意 proposed condition | `APP_CON_TYPE=AO`、`DECISION_DATE`、`FIN_APPR_LEVEL` 正確。 |
| TC-P-008 | Agreed suggested `09` | 執行同意 suggested condition | `APP_CON_TYPE=SG`、`DECISION_DATE`、`FIN_APPR_LEVEL` 正確。 |
| TC-P-009 | Return `98` | 建立 return info 後執行退回 | Summary 指派正確使用者，return/status/history/checkpoint 更新。 |
| TC-P-010 | Cancel `99` | 選擇取消原因後取消案件 | Cancel reason 寫入，summary decision date/current user 正確。 |
| TC-P-011 | Upload LLC file | 上傳 LLC 文件 | 檔案建立，comment table path/name 更新，init 顯示檔名。 |
| TC-P-012 | Print proposal | 執行列印 | 回傳安全下載 token 或加密下載資訊。 |

## 10.2 Negative Test Cases

| Test ID | 場景 | 步驟 | 預期結果 |
| --- | --- | --- | --- |
| TC-N-001 | Missing application no | 呼叫 init/save/action 不帶 `APPLICATION_NO` | 回傳 validation error，不更新資料。 |
| TC-N-002 | Missing case progress | 呼叫 action 不帶 `NEW_CASE_PROGRESS` | 回傳 validation error，不更新資料。 |
| TC-N-003 | Return no item | 未選 return item 執行 return info save | 回傳 `EPROCS0170_MSG_009` 對應錯誤。 |
| TC-N-004 | Cancel no reason | 未選取消原因執行 cancel reason save | 回傳 `EPROZ00100_MSG_REASON` 對應錯誤。 |
| TC-N-005 | Related party incomplete | 有 related party `IS_Y=Y` 但未完成檢核時 submit | Submit 失敗並提示 related party 未完成。 |
| TC-N-006 | CS LTV exceeded | CS housing loan SG coverage 超過 LTV level | Action 失敗，回傳 deviation 錯誤。 |
| TC-N-007 | Upload failure | 模擬檔案寫入失敗 | DB 不得留下不可下載的 path/name。 |
| TC-N-008 | Unauthorized role | 無權限 role 嘗試 action | 系統拒絕，audit 記錄查詢/異動嘗試。 |

## 10.3 Boundary Test Cases

| Test ID | 邊界 | 預期結果 |
| --- | --- | --- |
| TC-B-001 | `COMMENT` 長度跨越 `TMP_COMMENT1-3` 分段 | 儲存與重新查詢後文字完整且順序正確。 |
| TC-B-002 | `OTHER_FEE` 多筆拆分 | DB 欄位拆分與合計結果正確。 |
| TC-B-003 | `MEETING_DATE` 為合法閏年日期 | 成功轉換 SQL date。 |
| TC-B-004 | `MEETING_DATE` 格式錯誤 | 前端或後端 validation 失敗。 |
| TC-B-005 | 0270 revised item 為空 | 依 PM/SA 決議處理；不得產生空指標錯誤。 |
| TC-B-006 | Return item 多選 | `RETURN_CODE` 分號串接正確。 |
| TC-B-007 | Cancel reason 多選且含 other reason | `REASON_CODE` 與 `OTH_REASON` 正確寫入。 |

## 10.4 Regression Focus

| Focus | 驗證重點 |
| --- | --- |
| CS vs CU | 確認 CS-only LTV/collateral assessment 規則不誤套 CU。 |
| 0170 vs 0270 | 確認 0270 before/after 與 ORI_* 欄位不影響 0170。 |
| Return cleanup | 確認 checkpoint、scorecard、collateral assessment、SG fee/detail 清理符合四場景差異。 |
| Notification | 確認不同 `CASE_PROGRESS` 的收件人規則。 |
| Legacy defect decisions | 確認 TBD 決議後有對應測試。 |

# 11. Source Evidence 與決策紀錄

## 11.1 Evidence Map

| Evidence ID | Source | 支援內容 |
| --- | --- | --- |
| EV-001 | `function-inventory.csv` | 四支功能代號、module、JSP、action 清單與業務描述。 |
| EV-002 | `EPROCS_0170.java`、`EPROCS_0270.java` | CS transaction action、audit log、JSP routing、request/response key。 |
| EV-003 | `EPROCU_0170.java`、`EPROCU_0270.java` | CU transaction action、audit log、JSP routing、request/response key。 |
| EV-004 | `EPROCS_0170_mod.java`、`EPROCS_0270_mod.java` | CS prompt/init/save/action/return/cancel/upload/print/email source behavior。 |
| EV-005 | `EPROCU_0170_mod.java`、`EPROCU_0270_mod.java` | CU prompt/init/save/action/return/cancel/upload/print/email source behavior。 |
| EV-006 | `EPROCS0170.jsp`、`EPROCS0270.jsp` | CS UI validation、button action、Ajax route、popup behavior。 |
| EV-007 | `EPROCU0170.jsp`、`EPROCU0270.jsp` | CU UI validation、button action、Ajax route、popup behavior。 |
| EV-008 | module SQL files | Query prompt/init/revised item/return/cancel supporting SQL。 |
| EV-009 | DAO/table classes | Table field mapping、PK usage、CRUD behavior。 |
| EV-010 | prior migration inventory for `EPROCS_0170` and `EPROCU_0170` | Cross-check 0170 business flow and known logic。 |

## 11.2 決策紀錄

| Decision ID | 決策 | 狀態 |
| --- | --- | --- |
| DEC-001 | 本 PRD 以 `EPROCSU0170` 作為四支 legacy 功能整併目標名稱。 | Proposed |
| DEC-002 | Source confirmed 行為先完整保留；legacy defect suspect 需 PM/SA 決議後才決定保留或修正。 | Proposed |
| DEC-003 | Target API 可調整命名，但能力需覆蓋 legacy action map。 | Proposed |
| DEC-004 | CS/CU、0170/0270 差異以 scenario/domain 控制，不在 PRD 中強制單一實作方式。 | Proposed |

## 11.3 Source Scan Checklist

| 檢查項目 | 結果 |
| --- | --- |
| Transaction action 掃描 | Completed |
| Module prompt/init/save/action 掃描 | Completed |
| JSP button/action/validation 掃描 | Completed |
| 0170 prior migration inventory cross-check | Completed |
| 0270 revised item source scan | Completed |
| SQL/query file inventory | Completed |
| DAO/table side effect mapping | Completed |
| Legacy defect suspect 標示 | Completed |
| Code table label 完整解析 | Partial，列為 TBD |

## 11.4 Open Items

| Open Item | Owner 建議 | 說明 |
| --- | --- | --- |
| Confirm `EPROCSU0170` integration boundary | PM / SA | 確認四支 legacy 是否在 target 合併為一個功能或拆子流程。 |
| Confirm legacy defect handling | PM / SA / RD | 針對 `EPROCS_0270` function ID、CU `YN`、upload comment defect、delete audit type 做決議。 |
| Confirm code table labels | SA / BA | 補齊 `CAN_REASON`、`CAN_REASON_CU`、`REVISED_ITEM`、`TYPE_OF_LEVEL` 顯示文字。 |
| Confirm email routing | SA / Infra / Security | 定義 target UAT/PROD 信件收件與測試覆寫策略。 |
| Confirm AutoDisbursement integration | SA / RD | 決定保留 synchronous call、改 event 或由 downstream workflow 替代。 |
