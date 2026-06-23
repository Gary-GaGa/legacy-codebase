# 業務需求導向的功能規格書

## CDC-EPRO-0001 EPROC00112 CBC 銀行往來關係 PRD

台中資訊開發中心

版本 1.0

文件日期：2026/06/15

| 文件屬性 | 內容 |
|---|---|
| 文件類型 | 業務需求導向的功能規格書 |
| 目標功能代號 | EPROC00112 |
| 舊系統功能代號 | EPROC0_0112、EPROC0_0212 |
| 功能名稱 | CBC 銀行往來關係（CBC Banking Relationship） |
| 模組 | C0 公司戶徵信/評分資料 |
| 適用對象 | PM / SA / RD / QA |
| Source 掃描範圍 | `EPROC0_0112.java`、`EPROC0_0212.java`、`EPROC0_0112_mod.java`、`EPROC0_0212_mod.java`、`EPROC00112.jsp`、`EPROC00112_JS.jsp`、`EPROC00212.jsp`、`EPROC00212_JS.jsp`、對應 SQL、CBC DAO、檢核點 DAO、migration inventory |
| 產出檔案 | `CDC-EPRO-0001_EPROC00112_PRD_v1.0.md`、`CDC-EPRO-0001_EPROC00112_PRD_v1.0.docx` |

## 0. 文件控制

| 日期 | 版本 | 說明 | 作者 |
|---|---|---|---|
| 2026-06-15 | v1.0 | 依 `EPROC0_0112`、`EPROC0_0212` 舊系統 Source code 掃描產出公司戶 CBC 銀行往來關係 PRD。 | Codex |

| 角色 | Review 重點 |
|---|---|
| PM | 確認 EPROC00112 是否以同一功能承接 0112/0212，並確認新案/增貸與展期/展變的業務差異。 |
| SA | 確認 BBL、BGL、GBGL 的資料來源、必填、幣別加總、日期格式、保證人刪除條件與 checkpoint 分流。 |
| RD | 確認 API、DTO、交易一致性、六張 CBC 資料表覆寫策略、`INFO_SEQ_NO` 產生方式與共用 DAO 欄位 mapping。 |
| QA | 覆蓋初始化、Save、Finish、幣別計算、BBL/BGL/GBGL、0112/0212 差異、資料庫交易失敗 rollback 測試。 |

## 0.1 功能目的與範圍

| 項目 | 說明 |
|---|---|
| 功能目的 | 讓公司戶授信案件維護 CBC 報告與客戶聲明中的銀行往來關係，包含借款人借款負債、借款人保證負債、保證人借款/保證負債。 |
| 適用流程 | C0 公司戶 Credit Investigation / Scoring 資料維護頁籤。舊系統以 `EPROC0_0112` 處理一般流程，以 `EPROC0_0212` 處理展期/展變或 RC 流程。 |
| 涵蓋範圍 | 初始化查詢、代碼下拉、BBL/BGL/GBGL 主檔與明細維護、USD/KHR 彙總、Save / Finish、checkpoint 更新、頁籤完成狀態回傳。 |
| 不涵蓋範圍 | CBC 報告外部介接、授信額度核算、其他 C0 頁籤內容、客戶/保證人基本資料維護。 |
| 成功標準 | 使用者可查詢並維護公司戶 CBC 銀行往來關係資料；系統可依 0112/0212 正確保存資料、計算總額、更新 checkpoint，且交易失敗不留下半套資料。 |

## 0.2 待確認與來源差異

| 編號 | 事項 | 影響 | 負責角色 |
|---|---|---|---|
| 待確認-001 | 目標功能代號已依需求命名為 `EPROC00112`，需確認現代化系統路由、選單與文件編號是否同名。 | 若命名不同，API path、選單與測試案例需同步調整。 | PM / SA |
| 待確認-002 | 舊系統 `EPROC0_0112` 的 GBGL 個人/公司保證人 SQL 未過濾 `CR_DEL != 'Y'`；`EPROC0_0212` 會排除 `CR_DEL='Y'`。 | 來源差異可能造成 0112 顯示已刪除保證人；建議新版排除刪除保證人，但需 PM/SA 定案。 | PM / SA |
| 待確認-003 | `calculation` action 將非 USD 幣別全部加到 KHR；查詢格式化 `formateData` 只加總 USD/KHR，其他幣別不納入。 | 若代碼表 `CCY` 未限制只有 USD/KHR，總額可能與明細不一致。 | SA / RD |
| 待確認-004 | `save` 的 `check` 值在舊系統為 `Y=Save`、`N=Finished`，欄位語意與一般布林命名相反。 | 新版 DTO 若使用 `isFinish`，需明確轉換，避免 checkpoint 反寫。 | RD / QA |
| 待確認-005 | `formateDB` 直接迭代每張卡片的 `infoList`；JSP 會補空陣列，但 API 直接呼叫若缺欄位可能造成錯誤。 | 新版 API 建議將 null 視為空陣列並加 validation。 | RD |
| 待確認-006 | 舊系統以 `LON_ATTRIBUTE + SECURE_ATTRIBUTE == "CS"` 判斷公司戶 secured 流程，其他值都走 CU checkpoint。 | 若 C0 公司戶還有其他屬性組合，需確認 checkpoint 分流規則。 | SA |
| 待確認-007 | `EPROC00212.jsp` 在 `${attrMap.isOld}` 為 true 時不顯示 Finished 按鈕。 | 展期/展變舊案是否只能 Save、不能 Finish，需確認新版是否保留。 | PM / SA |

## 1. 目標與範圍

| 目標 | 說明 |
|---|---|
| GOAL-001 | 正確載入公司戶主借款人、共同借款人、個人保證人、公司保證人及其既有 CBC 資料。 |
| GOAL-002 | 支援 BBL、BGL、GBGL 三類 CBC 關係資料的主檔與明細維護。 |
| GOAL-003 | 依幣別彙總 Credit Amount 與 Outstanding Balance，並維持 UI 顯示與保存資料一致。 |
| GOAL-004 | 以單一 EPROC00112 規格承接 `EPROC0_0112` 與 `EPROC0_0212`，但保留 checkpoint、父頁籤與 0212 舊案按鈕差異。 |
| GOAL-005 | Save 可暫存資料；Finished 必須通過完整驗證後保存並更新完成狀態。 |

## 2. Source Scan 與來源對照

| 類別 | Source | Source-confirmed 行為 |
|---|---|---|
| 0112 交易 | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0112.java` | AJAX actions：`initQuery`、`calculation`、`save`；保存後呼叫 `EPRO_Z0Z006.getTabsCheckPage(..., "EPROC0_0110")` 與 `getCheckedProgressCORP`。 |
| 0212 交易 | `EPROWeb/JavaSource/com/cathaybk/epro/c0/trx/EPROC0_0212.java` | AJAX actions 同 0112；保存後呼叫 `EPRO_Z0Z006.getTabsCheckPage(..., "EPROC0_0210")` 與 `getCheckedProgressRC_CORP`。 |
| 0112 模組 | `EPROWeb/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0112_mod.java` | 查詢 BBL/BGL/GBGL、格式化日期、計算總額、整包覆寫 CBC 資料，依 CS/CU 更新 `EPRO_TB_CHECK_POINT_CORP` 或 `EPRO_TB_CHECK_POINT_CU` 的 `EPROC0_0112`。 |
| 0212 模組 | `EPROWeb/JavaSource/com/cathaybk/epro/c0/module/EPROC0_0212_mod.java` | 行為同 0112，但更新 `EPRO_TB_CHECK_POINT_RC_CORP` 或 `EPRO_TB_CHECK_POINT_RC_CU` 的 `EPROC0_0212`。 |
| 0112 JSP | `EPROC00112.jsp`、`EPROC00112_JS.jsp` | 畫面包含 BBL、BGL、GBGL fieldset、Save、Finished；Save 送 `check=Y`，Finished 送 `check=N`。 |
| 0212 JSP | `EPROC00212.jsp`、`EPROC00212_JS.jsp` | UI 與 0112 相同；`EPROC00212.jsp` 在 `${attrMap.isOld}` 為 true 時不顯示 Finished。 |
| SQL | `EPROC0_0112_mod.SQL_QUERY_001` 到 `006`、`EPROC0_0212_mod.SQL_QUERY_001` 到 `006` | BBL/BGL 從公司戶主借款人與共同借款人 left join CBC 表；GBGL 從個人/公司保證人 left join CBC 表。0212 GBGL 多 `CR_DEL != 'Y'`。 |
| 共用 DAO | `com.cathaybk.epro.dao.EPRO_TB_CBC_BBL*`、`EPRO_TB_CBC_BGL*`、`EPRO_TB_CBC_GBGL*` | 六張 CBC 主檔/明細表支援 `deleteApp`、`insert`、`find`。 |
| Checkpoint DAO | `EPRO_TB_CHECK_POINT_CORP`、`EPRO_TB_CHECK_POINT_CU`、`EPRO_TB_CHECK_POINT_RC_CORP`、`EPRO_TB_CHECK_POINT_RC_CU` | 0112 寫一般 checkpoint；0212 寫 RC checkpoint。 |
| Inventory | `eproposal-inventory/function-inventory.csv`、舊系統 `migration-inventory/function-inventory.csv` | `EPROC0_0112` 與 `EPROC0_0212` 均標示 `query;maintain/update`，actions 為 `calculation;initQuery;save`。 |

## 3. 舊系統行為摘要

| 行為 | 說明 | 分類 |
|---|---|---|
| 初始化 | `initQuery` 回傳 `ccyMap`、`statusMap`、`productMap`、`securityMap` 與 `dataMap`。代碼來源為 `EPRO_Z0Z001.getCommonFieldOptions("EPRO", language, ...)`，代碼項目為 `CCY`、`CBC_LOAN_STATUS`、`CBC_PRODUCT_TYPE`、`CBC_SECURITY_TYPE`。 | Source confirmed |
| BBL 查詢 | 主借款人來自 `TB_MAIN_BORROWER_INFO_CORP`，共同借款人來自 `TB_CO_BORROWER_INFO_CORP`，再 left join `TB_CBC_BBL`。主借款人固定 `IS_MAIN_BORR=Y`、`SEQ_NO=0`，共同借款人為 `IS_MAIN_BORR=N`。 | Source confirmed |
| BGL 查詢 | 資料來源同 BBL，但 left join `TB_CBC_BGL`，保存到 BGL 專用主檔與明細表。 | Source confirmed |
| GBGL 查詢 | 個人保證人來自 `TB_GUARANTOR_INFO` 並設 `IS_IND=Y`；公司保證人來自 `TB_GUARANTOR_INFO_CORP` 並設 `IS_IND=N`，再 left join `TB_CBC_GBGL`。 | Source confirmed |
| GBGL 刪除條件 | 0112 SQL 未過濾 `CR_DEL != 'Y'`；0212 SQL 會排除 `CR_DEL='Y'`。 | Legacy defect suspect |
| 明細查詢 | BBL/BGL 明細用 `APPLICATION_NO`、`BORROWER_NAME`、`SEQ_NO` 查詢；GBGL 明細再加 `IS_IND`。 | Source confirmed |
| 日期格式 | 查詢時 `AS_OF_DATE`、`MATURITY_DATE` 由 DB `yyyy-MM-dd` 轉 UI `dd/MM/yyyy`；保存時由 UI `dd/MM/yyyy` 轉 `Date`。 | Source confirmed |
| 幣別加總 | 查詢格式化時只加總 USD/KHR；前端計算呼叫 `calculation`，該 action 將 USD 加到 `usdAmt`，非 USD 全加到 `khrAmt`。 | Source confirmed / TBD |
| Save | Save 按鈕移除日期必填限制，通過簡易驗證後送 `check=Y`，可保存未完整資料。 | Source confirmed |
| Finished | Finished 按鈕加入主檔日期與明細欄位必填，且驗證 radio、日期、逾期年月格式後送 `check=N`。 | Source confirmed |
| 保存交易 | 後端先依 `APPLICATION_NO` 刪除六張 CBC 表，再依 payload 全量新增，最後更新 checkpoint；全部包在 `Transaction.begin/commit/rollback`。 | Source confirmed |
| 頁籤完成狀態 | 0112 由 `getCheckedProgressCORP` 判斷；0212 由 `getCheckedProgressRC_CORP` 判斷。只有 `check=N` 且全部頁籤完成時，前端把頁籤加上 `done`。 | Source confirmed |
| 0212 舊案 | `EPROC00212.jsp` 在 `${attrMap.isOld}` 為 true 時不渲染 Finished 按鈕。 | Source confirmed |

## 4. 需求矩陣

| 需求編號 | 需求 | 驗收重點 | 來源分類 |
|---|---|---|---|
| REQ-001 | 系統應提供 EPROC00112 初始化查詢，回傳三個區塊資料與四組下拉代碼。 | 代碼包含幣別、CBC loan status、product type、security type。 | Source confirmed |
| REQ-002 | 系統應建立 BBL 借款人借款負債區塊，包含主借款人與共同借款人。 | 主借款人 `SEQ_NO=0`、`IS_MAIN_BORR=Y`；共同借款人使用來源 `DATA_SEQ`。 | Source confirmed |
| REQ-003 | 系統應建立 BGL 借款人保證負債區塊，資料來源同 BBL 但保存表不同。 | BBL 與 BGL 資料不可互相覆寫。 | Source confirmed |
| REQ-004 | 系統應建立 GBGL 保證人借款/保證負債區塊，區分個人與公司保證人。 | 個人 `IS_IND=Y`，公司 `IS_IND=N`。 | Source confirmed |
| REQ-005 | 系統應支援每張卡片的 CBC 主檔欄位與明細欄位維護。 | Finished 時必填；Save 可暫存。 | Source confirmed |
| REQ-006 | 系統應依明細幣別計算 USD/KHR 的 Total Credit Amount 與 Total Outstanding Balance。 | USD/KHR 加總正確；非 USD 規則待確認。 | Source confirmed / TBD |
| REQ-007 | 系統應在保存時全量覆寫六張 CBC 資料表並維持交易一致性。 | 任一 insert 或 checkpoint update 失敗時全部 rollback。 | Source confirmed |
| REQ-008 | 系統應依 0112/0212 與 CS/CU 分流更新正確 checkpoint 欄位。 | 0112 寫 `EPROC0_0112`；0212 寫 `EPROC0_0212`。 | Source confirmed |
| REQ-009 | 系統應回傳頁籤是否全部完成，讓父頁籤更新 done 狀態。 | 0112 使用一般公司戶 progress；0212 使用 RC 公司戶 progress。 | Source confirmed |
| REQ-010 | 系統應處理舊系統來源差異，並在 PM/SA 定案前不得把疑似缺陷默認為新版規則。 | `CR_DEL` 與非 USD 幣別規則需有決策紀錄。 | Inferred |

## 5. 功能規格

### 5.1 頁籤與使用情境

| 情境 | 舊功能 | 規格 |
|---|---|---|
| 一般公司戶案件 | `EPROC0_0112` | 使用 EPROC00112 的一般流程模式，父頁籤對應 `EPROC0_0110`，保存後檢查一般公司戶頁籤完成度。 |
| 展期/展變或 RC 公司戶案件 | `EPROC0_0212` | 使用 EPROC00112 的 RC 流程模式，父頁籤對應 `EPROC0_0210`，保存後檢查 RC 公司戶頁籤完成度。 |
| 0212 舊案檢視 | `EPROC00212.jsp` | 當案件為舊案時，Finished 按鈕不顯示；是否保留於新版依待確認-007。 |

### 5.2 畫面區塊

| 區塊 | 英文含義 | 資料來源 | 顯示規則 |
|---|---|---|---|
| BBL | Borrower's Borrowing Liability | 公司戶主借款人、共同借款人 left join `TB_CBC_BBL`。 | 顯示每一位借款人的 CBC 借款負債卡片與明細表。 |
| BGL | Borrower's Guaranteed Liability | 公司戶主借款人、共同借款人 left join `TB_CBC_BGL`。 | 顯示每一位借款人的 CBC 保證負債卡片與明細表。 |
| GBGL | Guarantor's Borrowing / Guaranteed Liability | 個人保證人、公司保證人 left join `TB_CBC_GBGL`。 | 顯示每一位保證人的 CBC 借款/保證負債卡片與明細表。 |

### 5.3 主檔欄位規則

| 欄位 | 規則 |
|---|---|
| 借款人 / 保證人姓名 | 由來源資料帶入，不提供使用者新增借款人或保證人。BBL/BGL 使用 `BORROWER_NAME`；GBGL 使用 `GUARANTOR_NAME`，前端以姓名欄顯示。 |
| CBC active record available | Radio：Y/N。Finished 必選。若由 Y 改為 N，前端清空明細、隱藏明細表與 Add New，並清空總額。 |
| CBC status for all other loans including active and inactive | Radio：`N` / `A`。Finished 必選。代碼文字由 JSP message 控制。 |
| CBC cycles showing any late payment | Radio：Y/N。Finished 必選。選 Y 時需輸入 `LATE_PAYMENT_MONTH_YEAR`；選 N 時清空並停用該欄位。 |
| Late Payment Month/Year | 格式 `MM/YYYY`，舊系統正規式允許 `M/YYYY` 或 `MM/YYYY`，年份允許 2 或 4 碼且以 19/20 開頭。 |
| As of date | Finished 必填，格式 `DD/MM/YYYY`。保存時轉 DB Date。 |
| Note | 文字欄位，maxlength 1000。 |

### 5.4 明細欄位規則

| 欄位 | 規則 |
|---|---|
| Banker Name | Finished 必填，maxlength 20。 |
| Credit Amount Currency | Finished 必選，來源為 `CCY`。變更時同步 Outstanding Balance Currency，並清空兩個金額欄位。 |
| Credit Amount | Finished 必填，正數金額；USD 允許 2 位小數且補零，非 USD 使用 0 位小數。 |
| Outstanding Balance Currency | 由 Credit Amount Currency 同步，舊系統前端停用不可直接選。 |
| Outstanding Balance | Finished 必填，正數金額；精度規則同 Credit Amount。 |
| Tenor | Finished 必填，maxlength 20。 |
| Status Code | Finished 必選，來源為 `CBC_LOAN_STATUS`。 |
| Maturity Date | Finished 必填，格式 `DD/MM/YYYY`。 |
| Product Code | Finished 必選，來源為 `CBC_PRODUCT_TYPE`。 |
| Security Code | Finished 必選，來源為 `CBC_SECURITY_TYPE`。 |
| Repay Records | Radio：Normal=`N`、Abnormal=`A`。Finished 必選。 |
| INFO_SEQ_NO | 保存時後端依每張卡片明細順序重新編為 1..n。 |

### 5.5 明細增刪與上限

| 行為 | 規格 |
|---|---|
| Add New | 僅可編輯且非查詢模式顯示。新增一筆空白明細，預設帶 `APPLICATION_NO`、姓名與空欄位。 |
| 上限 | 舊系統使用 `top.cbcInfoSize` 控制明細筆數上限；新版需沿用全域設定或明確定義上限。 |
| Delete | 僅可編輯且非查詢模式顯示。每張卡片至少保留一筆明細；若只剩一筆，顯示 `COMMON_MSG_ONE_DATA`。 |
| CBC available = N | 清空該卡片 `infoList`、隱藏明細表、隱藏 Add New、清空 USD/KHR 總額。 |

### 5.6 幣別加總

| 項目 | 規格 |
|---|---|
| Total Credit Amount | 依明細 `CREDIT_AMOUNT_CURRENCY` 加總 `CREDIT_AMOUNT`，畫面顯示 USD 與 KHR 兩列。 |
| Total Outstanding Balance | 依明細 `OUTSTANDING_BALANCE_CURRENCY` 加總 `OUTSTANDING_BALANCE`，畫面顯示 USD 與 KHR 兩列。 |
| 查詢時計算 | 舊系統 `formateData` 僅明確加總 USD/KHR。 |
| 前端即時計算 | 舊系統 `calculation` action 將 USD 歸 USD，非 USD 歸 KHR。 |
| 新版建議 | 若代碼表只允許 USD/KHR，需在規格與 validation 寫明；若可能有其他幣別，需新增錯誤處理或額外幣別顯示，不能默默歸 KHR。 |

### 5.7 Save / Finished

| 操作 | 舊系統參數 | 驗證 | 後端行為 |
|---|---|---|---|
| Save | `check=Y` | 不強制所有日期與明細欄位必填；仍執行已註冊的簡易檢核。 | 保存 payload、更新 checkpoint 為 `Y`。 |
| Finished | `check=N` | 主檔 radio、`AS_OF_DATE`、明細欄位、`MATURITY_DATE`、`REPAY_RECORDS`、逾期年月格式均需通過。 | 保存 payload、更新 checkpoint 為 `N`，並回傳全部頁籤完成狀態。 |

> 注意：舊系統 `check=Y/N` 的業務語意與一般「完成=true」命名相反。若新版使用 `isFinish`，建議明確轉換：`isFinish=false -> check=Y`，`isFinish=true -> check=N`。

## 6. API / Interface 規格草案

> 以下 endpoint 為現代化命名草案；實際 path 可依既有 API 命名規範調整。payload 欄位與行為依舊系統 Source confirmed。

| API | 用途 | 對應舊 action |
|---|---|---|
| `GET /api/epro/eproc00112/info` | 初始化查詢三個 CBC 區塊與下拉代碼。 | `initQuery` |
| `POST /api/epro/eproc00112/calculate` | 依幣別計算總額。 | `calculation` |
| `POST /api/epro/eproc00112/save` | Save 或 Finished 保存資料並更新 checkpoint。 | `save` |

### 6.1 查詢 Request / Response

| 欄位 | 必填 | 說明 |
|---|---|---|
| `applicationNo` | Y | 案件編號，對應舊 `APPLICATION_NO`。 |
| `legacyFunctionId` | Y | `EPROC0_0112` 或 `EPROC0_0212`，用於決定父頁籤與 checkpoint 類型。 |

| Response 欄位 | 說明 |
|---|---|
| `ccyMap` | 幣別選項，來源 `CCY`。 |
| `statusMap` | CBC loan status 選項，來源 `CBC_LOAN_STATUS`。 |
| `productMap` | CBC product type 選項，來源 `CBC_PRODUCT_TYPE`。 |
| `securityMap` | Security 選項，來源 `CBC_SECURITY_TYPE`。 |
| `bBLList` | BBL 卡片清單，每張含主檔欄位、總額與 `infoList`。 |
| `bGLList` | BGL 卡片清單，每張含主檔欄位、總額與 `infoList`。 |
| `gBGLList` | GBGL 卡片清單，每張含主檔欄位、`IS_IND`、總額與 `infoList`。 |
| `check` | 舊 checkpoint 欄位值。 |

### 6.2 保存 Request / Response

| 欄位 | 必填 | 說明 |
|---|---|---|
| `applicationNo` | Y | 案件編號。 |
| `legacyFunctionId` | Y | `EPROC0_0112` 或 `EPROC0_0212`。 |
| `isFinish` | Y | 建議新版欄位。保存時需轉換為舊 `check` 值。 |
| `bBLList` | Y | BBL 卡片與明細。 |
| `bGLList` | Y | BGL 卡片與明細。 |
| `gBGLList` | Y | GBGL 卡片與明細。 |
| `pageCheckMap` | Y | 父頁籤狀態，對應舊 `EPROC0_0110.getPageObj()` 或 `EPROC0_0210.getPageObj()`。 |

| Response 欄位 | 說明 |
|---|---|
| `isAllTabsCheck` | 保存後是否所有相關頁籤都完成。0112 由一般公司戶 progress 判斷；0212 由 RC 公司戶 progress 判斷。 |
| `message` | 成功回 `COMMON_MSG_SAVE_SUCCESS`；失敗依錯誤規則回傳。 |

## 7. 資料設計與 Mapping

### 7.1 CBC 主檔資料表

| 區塊 | 資料表 | 主鍵 / 識別 | 欄位 |
|---|---|---|---|
| BBL | `OVSLXLON01.TB_CBC_BBL` | `APPLICATION_NO`、`BORROWER_NAME`、`SEQ_NO` | `IS_MAIN_BORR`、`IS_REPORT_AVAILABLE`、`ALL_LOANS_STATUS`、`IS_ANY_LATE_PAYMENT`、`LATE_PAYMENT_MONTH_YEAR`、`AS_OF_DATE`、`NOTE` |
| BGL | `OVSLXLON01.TB_CBC_BGL` | `APPLICATION_NO`、`BORROWER_NAME`、`SEQ_NO` | 同 BBL 主檔。 |
| GBGL | `OVSLXLON01.TB_CBC_GBGL` | `APPLICATION_NO`、`GUARANTOR_NAME`、`SEQ_NO` | `IS_REPORT_AVAILABLE`、`ALL_LOANS_STATUS`、`IS_ANY_LATE_PAYMENT`、`LATE_PAYMENT_MONTH_YEAR`、`AS_OF_DATE`、`NOTE`、`IS_IND` |

### 7.2 CBC 明細資料表

| 區塊 | 資料表 | 主鍵 / 識別 | 欄位 |
|---|---|---|---|
| BBL | `OVSLXLON01.TB_CBC_BBL_INFO` | `APPLICATION_NO`、`BORROWER_NAME`、`SEQ_NO`、`INFO_SEQ_NO` | `BANKER_NAME`、`CREDIT_AMOUNT_CURRENCY`、`CREDIT_AMOUNT`、`OUTSTANDING_BALANCE_CURRENCY`、`OUTSTANDING_BALANCE`、`TENOR`、`STATUS_CODE`、`MATURITY_DATE`、`PRODUCT_CODE`、`SECURITY_CODE`、`REPAY_RECORDS` |
| BGL | `OVSLXLON01.TB_CBC_BGL_INFO` | `APPLICATION_NO`、`BORROWER_NAME`、`SEQ_NO`、`INFO_SEQ_NO` | 同 BBL 明細。 |
| GBGL | `OVSLXLON01.TB_CBC_GBGL_INFO` | `APPLICATION_NO`、`BORROWER_NAME`、`SEQ_NO`、`INFO_SEQ_NO` | 同 BBL 明細，另有 `IS_IND`。舊 DAO 欄位名使用 `BORROWER_NAME` 保存保證人姓名。 |

### 7.3 來源資料表

| 用途 | 來源表 | 規則 |
|---|---|---|
| 公司戶主借款人 | `TB_MAIN_BORROWER_INFO_CORP` | BBL/BGL 主借款人來源；姓名比對時使用 `TRIM(MAIN_BORROWER_NAME)`。 |
| 公司戶共同借款人 | `TB_CO_BORROWER_INFO_CORP` | BBL/BGL 共同借款人來源；`DATA_SEQ` 對應 `SEQ_NO`。 |
| 個人保證人 | `TB_GUARANTOR_INFO` | GBGL 個人保證人來源；`DATA_SEQ` 對應 `SEQ_NO`；`IS_IND=Y`。 |
| 公司保證人 | `TB_GUARANTOR_INFO_CORP` | GBGL 公司保證人來源；`DATA_SEQ` 對應 `SEQ_NO`；`IS_IND=N`。 |
| 案件屬性 | `TB_LON_SUMMARY_INFO` | 以 `LON_ATTRIBUTE + SECURE_ATTRIBUTE` 判斷 CS/CU checkpoint。 |

### 7.4 Checkpoint Mapping

| 舊功能 | 條件 | Checkpoint 表 | 欄位 | 頁籤完成度 |
|---|---|---|---|---|
| `EPROC0_0112` | `LON_ATTRIBUTE + SECURE_ATTRIBUTE == "CS"` | `EPRO_TB_CHECK_POINT_CORP` | `EPROC0_0112` | `getCheckedProgressCORP` |
| `EPROC0_0112` | 非 CS | `EPRO_TB_CHECK_POINT_CU` | `EPROC0_0112` | `getCheckedProgressCORP` |
| `EPROC0_0212` | `LON_ATTRIBUTE + SECURE_ATTRIBUTE == "CS"` | `EPRO_TB_CHECK_POINT_RC_CORP` | `EPROC0_0212` | `getCheckedProgressRC_CORP` |
| `EPROC0_0212` | 非 CS | `EPRO_TB_CHECK_POINT_RC_CU` | `EPROC0_0212` | `getCheckedProgressRC_CORP` |

## 8. 業務規則

| 編號 | 規則 | 分類 |
|---|---|---|
| BR-001 | `applicationNo` 不可空白；空白時舊系統拋 `COMMON_MSG_ERROR_LON`。 | Source confirmed |
| BR-002 | BBL/BGL 的借款人清單由公司戶主借款人與共同借款人來源表產生，使用者不可在本頁新增借款人。 | Source confirmed |
| BR-003 | GBGL 的保證人清單由個人與公司保證人來源表產生，使用者不可在本頁新增保證人。 | Source confirmed |
| BR-004 | BBL/BGL 主借款人固定 `IS_MAIN_BORR=Y`、`SEQ_NO=0`；共同借款人固定 `IS_MAIN_BORR=N`。 | Source confirmed |
| BR-005 | GBGL 個人保證人固定 `IS_IND=Y`；公司保證人固定 `IS_IND=N`。 | Source confirmed |
| BR-006 | 每次保存為 full replacement：刪除同 `APPLICATION_NO` 的六張 CBC 表資料，再重新 insert payload。 | Source confirmed |
| BR-007 | 六張 CBC 表與 checkpoint update 必須在同一交易內完成。 | Source confirmed |
| BR-008 | `AS_OF_DATE`、`MATURITY_DATE` UI 格式為 `DD/MM/YYYY`；逾期年月格式為 `MM/YYYY`。 | Source confirmed |
| BR-009 | Finished 需完成全部必填與 radio 選項；Save 可暫存未完整資料。 | Source confirmed |
| BR-010 | 0112/0212 不可混用 checkpoint 表與父頁籤完成度計算。 | Source confirmed |
| BR-011 | 0112 是否排除 `CR_DEL='Y'` 保證人需 PM/SA 決定；新版實作不得未經確認複製疑似缺陷。 | Legacy defect suspect |

## 9. 錯誤處理

| 場景 | 舊系統行為 | 新版規格 |
|---|---|---|
| 查詢無資料 | `DataNotFoundException` 回 `MSG_DATA_NOT_FOUND`。 | 回可辨識錯誤碼與訊息，不應顯示空白成功頁。 |
| 查詢超過筆數 | `OverCountLimitException` 回 `MSG_OVER_COUNT_LIMIT`。 | 保留等價錯誤碼。 |
| 初始化查詢失敗 | 一般 module exception 回 `MSG_QUERY_FAIL`。 | 回查詢失敗並記錄交易代號與 applicationNo。 |
| 幣別加總失敗 | `calculation` exception 回 `COMMON_MSG_TOTAL_FAIL`。 | 前端需提示小計失敗，避免保存錯誤總額。 |
| 保存輸入錯誤 | `ErrorInputException` 回原 exception message，例如 `COMMON_MSG_ERROR_LON`。 | 回 400 類型錯誤與業務訊息。 |
| 保存失敗 | 一般 exception 回 `COMMON_MSG_SAVE_FAIL`，交易 rollback。 | 不得留下部分刪除或部分新增資料。 |

## 10. 非功能需求

| 類別 | 需求 |
|---|---|
| 交易一致性 | 保存時六張 CBC 表與 checkpoint 必須原子化；任一失敗全部 rollback。 |
| 稽核 | 舊系統對 initQuery 使用 Query/Table，calculation 使用 Transfer/StoredProcedure，save 使用 Edit/Table。新版需保留等價 audit log。 |
| 權限 | 非編輯模式或查詢模式需停用欄位並隱藏 Save / Finished / Add / Delete。 |
| 資料完整性 | 明細 `INFO_SEQ_NO` 必須由後端穩定產生或驗證，避免前端任意序號造成主鍵衝突。 |
| 相容性 | 日期與金額格式需與舊 UI 相容，特別是 USD 2 位小數、KHR 0 位小數。 |
| 可追蹤性 | 每次保存需可追蹤 `applicationNo`、legacy function id、操作類型、checkpoint 值。 |

## 11. 測試與驗收

| 測試編號 | 情境 | 前置條件 | 預期結果 | 優先 |
|---|---|---|---|---|
| AC-001 | 0112 初始化 | 案件有主借款人、共同借款人、保證人。 | 回傳 BBL/BGL/GBGL 清單與四組代碼，父頁籤為 `EPROC0_0110`。 | 高 |
| AC-002 | 0212 初始化 | 案件有 RC 流程資料。 | 回傳資料同 0112，但父頁籤為 `EPROC0_0210`。 | 高 |
| AC-003 | BBL 主借款人 | 主借款人存在。 | BBL 產生 `IS_MAIN_BORR=Y`、`SEQ_NO=0` 卡片。 | 高 |
| AC-004 | BGL 共同借款人 | 共同借款人存在。 | BGL 產生 `IS_MAIN_BORR=N` 卡片，`SEQ_NO` 對應來源 `DATA_SEQ`。 | 高 |
| AC-005 | GBGL 個人與公司保證人 | 兩種保證人都存在。 | 個人資料 `IS_IND=Y`，公司資料 `IS_IND=N`。 | 高 |
| AC-006 | 0212 排除刪除保證人 | 保證人 `CR_DEL=Y`。 | 0212 不回傳該保證人。 | 高 |
| AC-007 | 0112 刪除保證人差異 | 保證人 `CR_DEL=Y`。 | 依待確認-002 決策驗證；若新版排除，需明確記錄與舊系統差異。 | 中 |
| AC-008 | Save 草稿 | 必填欄位尚未完整。 | 可保存，checkpoint 寫入 Save 對應狀態，頁籤不標示全部完成。 | 高 |
| AC-009 | Finished 完成 | 所有必填欄位完整。 | 保存成功，checkpoint 寫入 Finished 對應狀態，回傳 `isAllTabsCheck`。 | 高 |
| AC-010 | Finished 缺主檔 radio | 未選 CBC active record available。 | 前端或 API validation 阻擋。 | 高 |
| AC-011 | Finished 缺明細欄位 | 明細缺 Banker Name 或 Security Code。 | validation 阻擋，不保存。 | 高 |
| AC-012 | 逾期年月格式錯誤 | 選 late payment=Y 且輸入非 `MM/YYYY`。 | validation 阻擋。 | 中 |
| AC-013 | CBC available 改 N | 原本有多筆明細。 | 明細清空、總額清空、保存後資料庫不保留該卡片舊明細。 | 高 |
| AC-014 | 幣別加總 USD/KHR | 明細同時有 USD 與 KHR。 | Total Credit Amount 與 Total Outstanding Balance 分幣別正確加總。 | 高 |
| AC-015 | 非 USD/KHR 幣別 | 代碼表存在第三幣別。 | 依待確認-003 決策驗證，不可默默造成查詢與即時計算不一致。 | 中 |
| AC-016 | 明細刪除剩一筆 | 卡片只剩一筆明細。 | 阻擋刪除並顯示等價 `COMMON_MSG_ONE_DATA`。 | 中 |
| AC-017 | 明細上限 | 明細數等於上限。 | 阻擋新增並顯示等價 `COMMON_MSG_LIMIT`。 | 中 |
| AC-018 | 0112 checkpoint CS | `LON_ATTRIBUTE + SECURE_ATTRIBUTE = CS`。 | 更新 `EPRO_TB_CHECK_POINT_CORP.EPROC0_0112`。 | 高 |
| AC-019 | 0112 checkpoint CU | 屬性非 CS。 | 更新 `EPRO_TB_CHECK_POINT_CU.EPROC0_0112`。 | 高 |
| AC-020 | 0212 checkpoint CS | `LON_ATTRIBUTE + SECURE_ATTRIBUTE = CS`。 | 更新 `EPRO_TB_CHECK_POINT_RC_CORP.EPROC0_0212`。 | 高 |
| AC-021 | 0212 checkpoint CU | 屬性非 CS。 | 更新 `EPRO_TB_CHECK_POINT_RC_CU.EPROC0_0212`。 | 高 |
| AC-022 | 0212 舊案 | `${attrMap.isOld}=true` 或新版等價條件。 | 不顯示 Finished 或依待確認-007 決策處理。 | 中 |
| AC-023 | 交易失敗 rollback | 刪除後 insert 或 checkpoint update 發生例外。 | 六張 CBC 表與 checkpoint 不得部分成功。 | 高 |
| AC-024 | applicationNo 空白 | Request 未帶案件編號。 | 回 `COMMON_MSG_ERROR_LON` 等價錯誤，不進行查詢或保存。 | 高 |

## 12. Source Evidence 與決策紀錄

| 證據 | 檔案 | 結論 |
|---|---|---|
| AJAX action | `EPROC0_0112.java`、`EPROC0_0212.java` | 舊功能只暴露 `initQuery`、`calculation`、`save` 三個 action。 |
| 下拉代碼 | `EPROC0_0112.java`、`EPROC0_0212.java` | 四組代碼皆由 `EPRO_Z0Z001.getCommonFieldOptions` 取得。 |
| 0112 父頁籤 | `EPROC0_0112.java` | 保存後使用 `EPROC0_0110` 與 `getCheckedProgressCORP`。 |
| 0212 父頁籤 | `EPROC0_0212.java` | 保存後使用 `EPROC0_0210` 與 `getCheckedProgressRC_CORP`。 |
| Save/Finished check 值 | `EPROC00112_JS.jsp`、`EPROC00212_JS.jsp` | Save 呼叫 `save('Y')`；Finished 呼叫 `save('N')`。 |
| Finished validation | `EPROC00112_JS.jsp`、`EPROC00212_JS.jsp` | Finished 時把日期欄位加回 required，並執行 radio、明細欄位與格式檢核。 |
| 0212 舊案 | `EPROC00212.jsp` | `${!attrMap.isOld}` 才渲染 Finished 按鈕。 |
| BBL/BGL 來源 | `EPROC0_0112_mod.SQL_QUERY_001` 到 `004`、`EPROC0_0212_mod.SQL_QUERY_001` 到 `004` | 主借款人與共同借款人 left join BBL/BGL。 |
| GBGL 來源 | `EPROC0_0112_mod.SQL_QUERY_005`、`006`、`EPROC0_0212_mod.SQL_QUERY_005`、`006` | 個人與公司保證人 left join GBGL；0212 才有 `CR_DEL != 'Y'`。 |
| 保存交易 | `EPROC0_0112_mod.java`、`EPROC0_0212_mod.java` | `Transaction.begin` 後刪除六張表、insert、更新 checkpoint，例外時 rollback。 |
| DAO 欄位 | `EPRO_TB_CBC_BBL.java`、`EPRO_TB_CBC_BBL_INFO.java`、`EPRO_TB_CBC_GBGL.java`、`EPRO_TB_CBC_GBGL_INFO.java` | 主檔、明細欄位與主鍵 mapping 由 DAO fieldNames / orderPrimaryKey 確認。 |

## 13. 準備與完成定義

| 階段 | 條件 |
|---|---|
| 開發前 | 待確認-002、003、004、007 已有 PM/SA/RD 決策。 |
| 開發前 | API path、DTO 命名、`isFinish` 與舊 `check` 值轉換已定案。 |
| 開發完成 | 0112/0212 初始化、Save、Finished、checkpoint、rollback 測試通過。 |
| 開發完成 | Source 差異有測試案例覆蓋，且文件記錄新版是否修正舊系統疑似缺陷。 |
| 上線前 | UAT 以至少一筆 CS、一筆 CU、一筆 0212 RC 舊案/新案測試完成。 |
