-- DB schema（gate②）— EPROZ00100 TO DO LIST / Work-list Dashboard
-- 由 PRD CDC-EPRO-0001 §5 轉。精確型別/長度/PK/nullable/default 以新 DB schema（local docs/db-schema/，母資料夾）為準——
-- 本 repo 無該 snapshot（local-only）→ 下列長度為「與 openapi 契約一致」之 SA 草案，RD 對新 DB Excel 核對。
-- 寫入主表：delete→TB_DEL_REASON、close→TB_CLO_REASON、both→TB_APP_HISTORY(insert)＋TB_LON_SUMMARY_INFO(update)。
-- 讀取/受側效表列為註解（xfile：CREATE 或註解皆算「列了」），RD 補欄位。

-- 更新表（R2 redistribution / R9 delete / R10 close）-------------------------
CREATE TABLE TB_LON_SUMMARY_INFO (
  APPLICATION_NO     VARCHAR2(30)  NOT NULL,        -- PK；↔ openapi applicationNo maxLength 30
  CURRENT_USER_ID    VARCHAR2(20),                  -- R3 查詢鍵；R10 close 後清空
  CASE_PROGRESS      VARCHAR2(5),                   -- R3 排除集合 / R9=D1 / R10=C1；↔ openapi caseProgress maxLength 5
  IS_AUTODIS         VARCHAR2(2),                   -- R10：M→MC、Y→YC
  CR_CODE            VARCHAR2(20),                  -- R2 redistribution
  RE_DISTRIBUTION    VARCHAR2(1),                   -- R2 redistribution flag
  RECEIVED_DATE      DATE,                          -- R2 redistribution
  DISTRIBUTION_DATE  DATE,                          -- R2 redistribution
  CONSTRAINT PK_TB_LON_SUMMARY_INFO PRIMARY KEY (APPLICATION_NO)
);

-- 插入表（R9 delete reason）---------------------------------------------------
CREATE TABLE TB_DEL_REASON (
  APPLICATION_NO  VARCHAR2(30)  NOT NULL,           -- ↔ openapi applicationNo 30
  REASON_CODE     VARCHAR2(200),                    -- R9：多 reason 分號串接
  DEL_DATE        DATE,
  OTH_REASON      VARCHAR2(100)                     -- R9：D99 other reason；↔ openapi othReason maxLength 100
);

-- 插入表（R10 close reason）--------------------------------------------------
CREATE TABLE TB_CLO_REASON (
  APPLICATION_NO  VARCHAR2(30)  NOT NULL,           -- ↔ openapi applicationNo 30
  REASON_CODE     VARCHAR2(200),                    -- R10：多 reason 分號串接
  CLOSE_DATE      DATE,
  OTH_REASON      VARCHAR2(100)                     -- R10：C99 other reason；↔ openapi othReason maxLength 100
);

-- 插入表（R2/R9/R10 歷程）----------------------------------------------------
CREATE TABLE TB_APP_HISTORY (
  APPLICATION_NO      VARCHAR2(30)  NOT NULL,       -- ↔ openapi applicationNo 30
  APP_PROCESS_CODE    VARCHAR2(5),                  -- 對 TB_PROCESS_CODE.APP_PROCESS_CODE
  PROCESSOR_CODE      VARCHAR2(20),                 -- R14 log：processor
  PROCESS_AGENT_CODE  VARCHAR2(20),                 -- R9-05：代理人處理
  PROCESS_AGENT_NAME  VARCHAR2(60),                 -- R9-05
  CREATE_DATE         DATE
);

-- 讀取 / 受側效 / 字典表（R3/R5/R6/R8/R13/R14；RD 對欄位）---------------------
-- V_MAIN_BORROWER_INFO          : R3/R5/R6 清單主來源 view（CURRENT_USER_ID / LOAN_TYPE_LANG_TYPE / CASE_PROGRESS / DECISION_DATE / APPLICATION_DATE / borrower name / LON_TYPE_CODE）
-- TB_RELATED_PARTY_INFO         : R5 showRelated（IS_Y=Y）；as-is LEFT JOIN
-- TB_LOAN_CONDITION_DETAIL      : R5 USD/KHR 金額加總
-- TB_EMP_PROXY                  : R6 CAD active proxy scope（as-is 疑缺）/ R2 redistribution proxy
-- TB_PROCESS_CODE               : R3/R8 CASE_PROGRESS 字典（APP_PROCESS_CODE/IS_SHOW；R0397 IS_SHOW=N 證據，findings）；值＝@PENDING TBD-003
-- TB_ROLE_DEFINE                : R1/R14 角色字典（Bible 錨點）；值/權限＝@PENDING TBD-001
-- TB_API_AUTH                   : R14 API 授權（REF_FUNCTION_ID + API_ID + ROLE；Bible 錨點，BE 權威授權來源）

-- 待 RD 對新 DB schema（local docs/db-schema/，母資料夾）核對精確型別/長度/nullable/default；
-- reason/role/CASE_PROGRESS code table 值層＝@PENDING TBD-001/003/007（PM/SA 補，見 spec.md §@PENDING）。
