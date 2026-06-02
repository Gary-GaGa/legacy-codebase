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

### 1.3 ⚠️ 缺口（需你確認）
- **CBC / 財報 / 財務評估 / Scorecard 的表未出現在 HOME**：D6 的 `TB_CBC_*`、`TB_FIN_STATEMENT_*`、`TB_FINANCIAL_EVALUATION_*`、`TB_IND_SCRCARD`、`TB_SCORE_CARD_PARAM_DETAIL`、`TB_CORP_SCRCARD` 都不在這份清單 → **這份 Excel 是否只涵蓋部分模組？i0/c0 的財報/評分/CBC 表在另一份/另一 schema 嗎？**（或 HOME 清單被截斷？）
- **`EPRO_` 前綴消失 + schema**：新表名為 `TB_*`（無 `EPRO_`）→ entity `@Table` 需確認**是否仍有 schema（如 `OVSLXLON01`）**、前綴是否一律去除（Prompt B 會帶出 schema）。

## 2. Phase 1 三表細節（Prompt B 回填）→ 定稿 `phase1-eproz0_0700-spec.md` §2
- `TB_EMP_PROXY`、`TB_EMP_PROFILE`、`TB_BRANCH_PROFILE`

## 3. 後續高價值表（依模組，之後用 Prompt B 批次抽）
- **CBC**：`EPRO_TB_CBC_BBL/_INFO`、`_BGL/_INFO`、`_GBGL/_INFO`
- **財報**：`EPRO_TB_FIN_STATEMENT_MAIN`、`_BALANCE_GI`、`_CASHFLOW_GI`、`_INCOME_GI`（+`_FI`）
- **財務評估**：`EPRO_TB_FINANCIAL_EVALUATION_INFO/_GI/_FI/_INFO_S`、`EPRO_TB_IND_SCRCARD`
- **Scorecard**：`EPRO_TB_SCORE_CARD_PARAM_DETAIL`、`EPRO_TB_MAIN_BORROWER_PERSONAL/WORK/FAMILY_INFO`、`EPRO_TB_COLL_ASS`、`EPRO_TB_CORP_SCRCARD`
- **Checkpoint**：`EPRO_TB_CHECK_POINT`（/`_IU`/`_RC_CORP`/`_RC_CU`）
- **權限**：`TB_FUNCTION_INFO`、`TB_FUNCTION_AUTH`（順便確認 R7 對映欄位）
