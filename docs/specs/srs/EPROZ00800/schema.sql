-- DB schema（gate ②）— EPROZ00800 Revised Item
-- 由 PRD CDC-EPRO-0001 §7 轉。精確型別/長度/PK/nullable/default 以「新 DB schema Excel」為準（db-schema-catalog.md）。
-- 本頁「寫入」主表 = TB_REVISED_ITEM（+ TB_REVISED_ITEM_DETAIL）；其餘為「讀/受側效影響」表（R13），列為註解供 RD 對。

-- 主寫入表（R12）-----------------------------------------------------------
CREATE TABLE TB_REVISED_ITEM (
  APPLICATION_NO  VARCHAR2(30)   NOT NULL,          -- PK
  ITEM1           CHAR(1),                          -- R9：Y/N（不得存 blank）；ITEM1~14
  ITEM2           CHAR(1),
  ITEM3           CHAR(1),
  ITEM4           CHAR(1),
  ITEM5           CHAR(1),
  ITEM6           CHAR(1),
  ITEM7           CHAR(1),
  ITEM8           CHAR(1),
  ITEM9           CHAR(1),
  ITEM10          CHAR(1),
  ITEM11          CHAR(1),
  ITEM12          CHAR(1),
  ITEM13          CHAR(1),
  ITEM14          CHAR(1),
  REASON_MEMO     VARCHAR2(3000),                   -- R4：上限 3000（as-is entity 為 4000，RD 對齊）；⚠️ BYTE/CHAR 語意待 RD 對 DB Excel——多位元組文字 3000「字元」需 VARCHAR2(3000 CHAR)，Oracle 預設 BYTE 會少於 3000 字
  UPD_DATE        DATE,
  CONSTRAINT PK_TB_REVISED_ITEM PRIMARY KEY (APPLICATION_NO)
  -- CHECK ITEMn IN ('Y','N') ← R9，RD 評估是否加 DB constraint 或僅 app 層
);

-- loan condition 修訂明細（R13.4/13.5）-------------------------------------
-- TB_REVISED_ITEM_DETAIL：保存/更新 loan condition 相關修訂明細。欄位由 RD 依 DB Excel 補。

-- 讀取 / 受側效影響表（R2 / R13；RD 對欄位）---------------------------------
-- TB_LON_SUMMARY_INFO            : R2 取 LON_TYPE_CODE、REF_APPLICATION_NO、LON_ATTRIBUTE、SECURE_ATTRIBUTE
-- TB_COMMON_FIELD_OPTIONS        : R2 REVISED_ITEM code table（revisedType）
-- TB_MAIN_BORROWER_PERSONAL_INFO : R13.1/13.2 IS_ANY_GUARANTOR、IS_ANY_COLLATERAL_PROVIDER flag（個人）
-- TB_MAIN_BORROWER_INFO_CORP     : 同上（法人）
-- TB_GUARANTOR_INFO / _CORP      : R13.1 刪/複製
-- TB_COLL_* / _PROVIDER_INFO / _TITLE_REGIS_OWNER : R13.3 刪/複製
-- TB_LOAN_CONDITION_DETAIL       : R13.4/13.5 刪/還原
-- TB_LOAN_CONDITION_FEE          : R13.6 刪（LON_TYPE=04 ITEM12 N→Y）
-- TB_CHECK_POINT_RC / _IU / _CORP / _CU : R14 checkpoint（標 EPRO{IS/IU/CS/CU}_0260）

-- ✅ RP1(TBD-006) 已裁（2026-06-11）＝A 保留側效：R13.1–13.3/13.6/13.7 之刪除/複製範圍已定版、可實作。
-- ⚠️ 僅 R13.4/13.5（TB_LOAN_CONDITION_DETAIL / TB_REVISED_ITEM_DETAIL）仍受 RP4 控制 → 未關前勿定版其刪除/還原範圍。
