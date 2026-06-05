-- DB schema 邊界 — EPROC00118 c0 Corporate Scorecard（SA → RD 邊界，DoD 閘門 2）
--
-- 用途：列「本頁真的會讀寫」的表 + 欄位/約束，當 entity↔schema 的 validate 目標
--       （產品專案 hibernate.ddl-auto=validate 或 migration check）。
-- 原則：JIT 從 docs/db-schema-catalog.md 抽，**不要全表貼**；只列本頁碰到的。
-- ⚠️ Oracle 方言；欄位為「已知 + TODO」，確切型別/長度對 db-schema-catalog 補。
-- 新 DB 表名無 EPRO_ 前綴、無 schema 限定。

-- == 寫回（save / calc）：評分主檔 ====================================
-- repo: TBCorpScrcardRepository.findCorpScrcard(...)
CREATE TABLE TB_CORP_SCRCARD (
  APPLICATION_NO      VARCHAR2(/*TODO*/)   NOT NULL,
  -- TODO: AO/CR 兩端評分欄位（R2/R7）、CR_RISK_LEVEL、CR_SCORE_CARD_COMPLETED…
  -- CR_SCORE_CARD_COMPLETED 為兩碼字串（R4：00114=第1碼 / 00118=第2碼）
  CR_RISK_LEVEL       VARCHAR2(/*TODO*/),
  CONSTRAINT PK_TB_CORP_SCRCARD PRIMARY KEY (APPLICATION_NO /*, TODO 複合鍵其餘欄位 */)
);

-- == 唯讀（calc / sele）：評分參數明細 ================================
-- repo: TBScoreCardParamDetailRepository
--   .findScoreParamsByApplicationDate(...)  -- R1/R6 取 B_V* 的 score/code
--   .findRiskLevelByTotalScore(...)         -- R1 用 COR_RISK_LV 對 totalScore 找 riskLevel
CREATE TABLE TB_SCORE_CARD_PARAM_DETAIL (
  -- TODO: VAR_NAME (B_V1..B_V22)、VAR_CODE、SCORE、range 上下界、PARAM_TYPE(含 COR_RISK_LV)、APPLICATION_DATE…
  VAR_NAME            VARCHAR2(/*TODO*/),
  SCORE               NUMBER(/*TODO*/)
  -- 唯讀，不寫
);

-- == 寫回（save）：checkpoint，欄位 EPROC00118（R3）===================
-- 寫法：DynamicUpdateSqlUtils；值 isFinish==true→'N' / false→'Y'
-- CS/CU 由 lonAttribute+secureAttribute 決定 → 寫 CS 或 CU 其一（不是兩個都寫）
CREATE TABLE TB_CHECK_POINTS_CS (
  APPLICATION_NO      VARCHAR2(/*TODO*/)   NOT NULL,
  EPROC00118          VARCHAR2(1),         -- 'Y' 未完 / 'N' 完成
  -- TODO: 其餘 checkpoint 欄位 + 複合鍵
  CONSTRAINT PK_TB_CHECK_POINTS_CS PRIMARY KEY (APPLICATION_NO /*, TODO */)
);

CREATE TABLE TB_CHECK_POINTS_CU (
  APPLICATION_NO      VARCHAR2(/*TODO*/)   NOT NULL,
  EPROC00118          VARCHAR2(1),
  CONSTRAINT PK_TB_CHECK_POINTS_CU PRIMARY KEY (APPLICATION_NO /*, TODO */)
);

-- 🚩 R8-PENDING：既有 CsuCreditEvalAndCreditDecisionServiceImpl Return(98) 只清 TB_CHECK_POINTS_CS、
--    無 CU 分流 → CU 案件 return 留錯狀態。本頁不修，見 spec.md R8-PENDING / page-mapping §2B escalation。
