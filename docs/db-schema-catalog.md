# DB Schema Catalog（新 Oracle DB，表名同舊）

> 來源：使用者提供的 Excel —— **已遷移至新 Oracle DB 後的 schema**，表名與舊系統相同。
> `HOME` 工作表 = 全表索引；其餘每個工作表 = 單一表細節。
> 用途：補齊各 entity 的**精確 Oracle 型別 / 長度 / nullable / PK**（直接收掉 **A1**，並供後續各模組 entity 定稿）。

## 1. 全表索引（Prompt A 回填）— 約 71 表（新 DB，**表名無 `EPRO_` 前綴**）

### 1.1 與我們盤點的對應（present ✅，依領域分組）
- **Phase 1**：`TB_EMP_PROXY` ✅、`TB_EMP_PROFILE` ✅、`TB_BRANCH_PROFILE` ✅
- **借款人/主流程**：`TB_MAIN_BORROWER_PERSONAL/WORK/FAMILY_INFO`、`TB_MAIN_BORROWER_INFO_CORP`、`TB_CO_BORROWER_*`、`TB_GUARANTOR_INFO(_CORP)`、`TB_COLL_PROVIDER_INFO`
- **擔保品**：`TB_COLL_INFO`/`_VALUE_INFO`/`_SITE_VISIT`/`_LTV`/`_TITLE_DETAIL`/`_VALUE_DETAIL`/`_CROSS_CHARGE_DETAIL`、`TB_INSPE_AO`、`TB_COLL_TITLE_REGIS_OWNER`、`TB_LTV(_DEVIATION/_CORP)`
- **條件/原因**：`TB_LOAN_CONDITION_FEE`、`TB_REVISED_ITEM(_DETAIL)`（條件調整 0176）、`TB_RETURN_INFO`/`TB_DEL_REASON`/`TB_CLO_REASON`/`TB_CAN_REASON`（退/刪/結/取消 → 審批 popup 0174/0175、z0 報表）
- **Checkpoint**：`TB_CHECK_POINTS_IS/IU/CS/CU`（⚠️ 新命名，與 D6 舊名 `TB_CHECK_POINT_RC_CORP/CU` 不同 → 以新名為準）
- **權限/選單（R7、shell）**：`TB_FUNCTION_AUTH`、`TB_API_AUTH`、`TB_ROLE_TASK`、`TB_ROLE_DEFINE`、`TB_MENU(_TRANSLATION)`、`TB_PAGE_MENU`、`TB_SYSTEM_API/_ENTRANCE/_MAIN`
- **參數/選單**：`TB_MULTI_LANG`、`TB_COMMON_FIELD_OPTIONS/_MAPPING`、`TB_LON_TYPE`、`TB_NATIONALITY`、`TB_DOCUMENT_TYPE`、`TB_PROVINCE/DISTRICT/COMMUNE/VILLAGE`、`TB_COLL_VALUE_COMP`、`TB_LAW_FIRM`、`TB_LTV_DEVIATION_TYPE`、`TB_PROCESS_CODE`、`TB_PRODUCT_CATEGORY`、`TB_EXCHANGE_RATE`
- **其他**：`TB_APP_NO_SEQ`、`TB_LON_SUMMARY_INFO`、`TB_APP_HISTORY`、`TB_NOTIFICATION_INFO`、`TB_SVC_LOG`、`TB_MESS_UPLOAD_SFTP_RECORD`、`TB_BATCH_COUNT_MANAGER/_ERROR_LOG/_LOG`

### 1.2 🔑 高價值發現（解既有開放項）
- **`TB_APP_NO_SEQ`（「系統更新」）= `APPLICATION_NO` 序號生成** → 解 **B4**（主流程主鍵來源）。
- **`TB_PAGE_MENU` = 外層流程頁(pageMap) 的資料來源** → 正是 shell 的 **PageDescriptor 後端來源**（對映 D3/B3 §5.4 的 pages endpoint）。
- **`TB_FUNCTION_AUTH`/`TB_API_AUTH`/`TB_ROLE_TASK`/`TB_ROLE_DEFINE` = 新權限模型已建表** → 解 **R7**（apiPath/roleId 對映就在這幾張）。
- **退/刪/結/取消原因表** → 對映審批 popup（0174/0175）與 z0 報表（Application Delete/Cancel）。

### 1.3 ✅ 缺口已釐清：全在同一份 Excel（先前 HOME 輸出被截斷）
- 先前 HOME 看似缺 CBC/財報/評分，實為**工具輸出截斷**（HOME 為單一工作表、內容很長，非 Excel 缺表）。Excel **約 70+ 張工作表、一表一 sheet**。
- ✅ i0/c0 表**全在此 Excel**（新名、無 `EPRO_`）：
  - CBC：`TB_CBC_BBL(_INFO)`、`TB_CBC_BGL(_INFO)`、`TB_CBC_GBGL(_INFO)`
  - 財報：`TB_FIN_STATEMENT_MAIN`、`_BALANCE_FI/GI`、`_CASHFLOW_FI/GI`、`_INCOME_FI/GI`
  - 財務評估：`TB_FINANCIAL_EVALUATION_FI/GI/INFO/INFO_CORP/INFO_S`
  - Scorecard：`TB_SCORE_CARD_PARAM_MAIN/SUB/DETAIL`、`TB_IND_SCRCARD`、`TB_CORP_SCRCARD`、`TB_COLL_ASS`
- **操作結論**：因 HOME 輸出會截斷，**一律用「指定表名」的 Prompt B 抽**（不依賴完整 HOME）。
- 新表名 `TB_*`（無 `EPRO_`、Phase 1 三表 schema 為「-」即無 schema 限定）。

## 2. Phase 1 三表細節（Prompt B）✅ 已回填、entity 定稿於 `phase1-eproz0_0700-spec.md` §2
- `TB_EMP_PROXY` — PK **`EMP_ID` 單鍵**（⚠️ 與舊 DAO 複合鍵不一致 → 一人一筆代理，待業務確認）；`EMP_ID`/`PROXY_ID`/`UPDATE_EMP_ID` VARCHAR2(10)、`STR_TIME` TIMESTAMP(6) **NOT NULL**、`END_TIME`/`UPDATE_DATE` TIMESTAMP(6)、`RETURN_CASE_TO_CA` VARCHAR2(1) default `'N'`。
- `TB_EMP_PROFILE` — PK (`ROLE_ID`,`EMP_ID`)；`EMP_ID` VARCHAR2(5)、`EMP_NAME`(50)、`BRANCH_CODE`(8)、`E_MAIL`(100)、`DEPT_CODE`(8)、`STATUS`(10)。
- `TB_BRANCH_PROFILE` — PK (`BRANCH_CODE`,`DEPT_CODE`)；`BRANCH_CODE`(5)、`BRANCH_NAME`(100)、`DEPT_CODE`(3)、`DEPT_NAME`(100)、`DATA_SEQ` NUMBER(3)、`DISPLAY`(1)、`T24_BRANCH_CODE`(5)、`T24_DEPT_CODE`(5)；**無 `T24_COMPANY`**。

### 全域學習（適用所有 entity）
- 新 DB **無 schema 限定、無 `EPRO_` 前綴** → `@Table(name="TB_…")` 不加 `schema=`、SQL 不加前綴。
- 多 entity 同欄位**長度可能不一致**（如 `EMP_ID` 5 vs 10）→ 以各表自身 schema 為準。
- 各表 PK 一律以**新 DB schema 為準**（可能與舊 DAO 不同，遇不一致標業務確認）。

## 3. 後續抽取批次（Prompt B）
> 順序：**B1 基礎建設 → B2 借款人/擔保品主流程 → 其餘依模組**。表名以新 DB 為準（無 `EPRO_` 前綴）。

**B1 — 基礎建設（shell / auth / 序號）← 先抽**
- `TB_PAGE_MENU`（shell 流程頁來源）、`TB_APP_NO_SEQ`（APPLICATION_NO 序號）
- `TB_FUNCTION_AUTH`、`TB_API_AUTH`、`TB_ROLE_TASK`、`TB_ROLE_DEFINE`（R7 權限）

**B2 — 借款人 / 擔保品主流程**
- `TB_MAIN_BORROWER_PERSONAL/WORK/FAMILY_INFO`、`TB_MAIN_BORROWER_INFO_CORP`
- `TB_CO_BORROWER_*`、`TB_GUARANTOR_INFO(_CORP)`、`TB_COLL_PROVIDER_INFO`
- 擔保品：`TB_COLL_INFO`/`_VALUE_INFO`/`_SITE_VISIT`/`_LTV`/`_TITLE_DETAIL`/`_VALUE_DETAIL`/`_CROSS_CHARGE_DETAIL`、`TB_INSPE_AO`、`TB_COLL_TITLE_REGIS_OWNER`、`TB_LTV(_DEVIATION/_CORP)`
- 條件/原因：`TB_LOAN_CONDITION_FEE`、`TB_REVISED_ITEM(_DETAIL)`、`TB_RETURN_INFO`/`TB_DEL_REASON`/`TB_CLO_REASON`/`TB_CAN_REASON`
- checkpoint：`TB_CHECK_POINTS_IS/IU/CS/CU`

**B3 — i0/c0 財報 / 評分 / CBC（✅ 確認在同一 Excel）**
- CBC：`TB_CBC_BBL(_INFO)`、`TB_CBC_BGL(_INFO)`、`TB_CBC_GBGL(_INFO)`
- 財報：`TB_FIN_STATEMENT_MAIN`、`_BALANCE_FI/GI`、`_CASHFLOW_FI/GI`、`_INCOME_FI/GI`
- 財務評估：`TB_FINANCIAL_EVALUATION_FI/GI/INFO/INFO_CORP/INFO_S`
- Scorecard：`TB_SCORE_CARD_PARAM_MAIN/SUB/DETAIL`、`TB_IND_SCRCARD`、`TB_CORP_SCRCARD`、`TB_COLL_ASS`

## 4. B1 基礎建設表細節（shell / 案號 / 權限）✅ 已回填
### `TB_PAGE_MENU`（shell 流程頁來源）
- 邏輯鍵：`LON_ATTRIBUTE`(個/企) + `SECURE_ATTRIBUTE`(有擔/無擔) + `PRODUCT_CODE` + `LON_TYPE_CODE`(新/增/展/變)；`PAGE_CODE` VARCHAR2(350) = 該組合下「頁框的頁籤頁面清單」（分隔字串）。
- → **shell PageDescriptor set 的後端來源**；可見頁 = 依這 4 個業務屬性查 `PAGE_CODE`。**新增軸：`PRODUCT_CODE`、`LON_TYPE_CODE`**（比原設想的 個/企 × 有擔無擔 × 申請覆核 更細）。
### `TB_APP_NO_SEQ`（APPLICATION_NO 序號）
- PK (`APP_GEN_DATE` YYMMDD, `APP_TYPE` 個/企有擔無擔, `LON_TYPE_CODE` 新增展變) + `MAX_SEQ` NUMBER(5)。
- → 案號 = 日期 + 類型 + 貸放類型 + 流水號（依此鍵遞增）。
### 權限三層（R7 具體化）
- **`TB_FUNCTION_AUTH`**（頁/功能存取）：`FUNCTION_ID`(20) → `ROLE`(100，角色清單字串)。無顯式 PK（FUNCTION_ID 為邏輯鍵）。
- **`TB_API_AUTH`**（API 端點存取 ← `APIAuthorizationFilter` 讀）：PK `API_ID`(100) → `ROLE`(100) + **`REF_FUNCTION_ID`(100，連回功能)** ← **R7 的 `FUNC_ID↔apiPath` 橋接已建模**。
- **`TB_ROLE_TASK`**（頁面操作權，如可否編輯）：PK (`PAGE_CODE`(20), `FUNCTION`(20，暫 `E`=EDIT)) → `ROLE`(300)、`PAGE_NAME`。→ 控 review/readonly、欄位可編輯。
- **`TB_ROLE_DEFINE`**（角色主檔）：PK `ROLE_ID`(3) → `ROLE_NAME`/`ROLE_DESC`。⚠️ 此處 `ROLE_ID` VARCHAR2(3)，但 `TB_EMP_PROFILE.ROLE_ID` VARCHAR2(5) → 留意。
