-- SRS schema excerpt for EPROC00115 Borrower Group Exposure.
-- Only SRS-relevant columns are listed for shared tables.
-- Source priority: latest reverify TSV, then docs/db-diff markdown, then current entity/refactor evidence.
--
-- Reverify evidence:
-- - TB_GROUP_EXPOSURE columns: C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_columns.tsv:1398-1413
-- - TB_GROUP_EXPOSURE PK: C:/Users/00596357/Documents/project/kh/epro/epro-db/out/legacy_schema_reverify_new02_pk.tsv:161-162
-- - TB_CHECK_POINTS_CS/CU EPROC00115 columns: ...legacy_schema_reverify_new02_columns.tsv:126,142
-- - TB_CHECK_POINTS_CS/CU PK: ...legacy_schema_reverify_new02_pk.tsv:35-36
-- - TB_COMMON_FIELD_OPTIONS columns: ...legacy_schema_reverify_new02_columns.tsv:402-412
-- - TB_COMMON_FIELD_OPTIONS PK: ...legacy_schema_reverify_new02_pk.tsv:66-70
--
-- Stale-source divergences:
-- - Legacy/PRD references EPRO_TB_CHECK_POINT_RC_CORP and EPRO_TB_CHECK_POINT_RC_CU for EPROC0_0215.
--   db-diff marks TB_CHECK_POINT_RC_CORP/CU removed_or_unused and moved to TB_CHECK_POINTS_CS/CU;
--   TB_CHECK_POINT_RC_CORP is not recreated by this SRS bundle.
--   TB_CHECK_POINT_RC_CU is not recreated by this SRS bundle.
--   latest active new-schema evidence found only TB_CHECK_POINTS_CS/CU for EPROC00115.
--   Owner decision 2026-06-24 closes RC 0215 as unified into CS/CU EPROC00115.
-- - db-diff markdown carries checkpoint default 'N'; latest column TSV used here does not expose default text.
--   Type, length, nullability, and PK still match for the columns used by this SRS.
--   DEFAULT 'N' is kept from db-diff because the latest column TSV has no default field.
-- - TB_COMMON_FIELD_OPTIONS.MSG_CODE is VARCHAR2(30) in db-diff and VARCHAR2(50) in latest reverify;
--   latest reverify is used here per source priority.

CREATE TABLE TB_GROUP_EXPOSURE (
  APPLICATION_NO VARCHAR2(30 BYTE) NOT NULL,
  FACILITY_VALUE VARCHAR2(2 BYTE),
  BORROWER_GROUP_NAME VARCHAR2(50 BYTE),
  LCC_AMOUNT_CUR VARCHAR2(3 BYTE),
  LCC_AMOUNT NUMBER(17,2),
  OUTSTAND_AMOUNT_CUR VARCHAR2(3 BYTE),
  OUTSTAND_AMOUNT NUMBER(17,2),
  COLLATERAL_CUR VARCHAR2(3 BYTE),
  COLLATERAL_AMOUNT NUMBER(17,2),
  TITLE_DEED_TYPE VARCHAR2(2 BYTE),
  INTEREST_RATE NUMBER(17,2),
  TENOR NUMBER(5,0),
  MATURITY_DATE DATE,
  LTV NUMBER(17,2),
  DATA_SEQ NUMBER(2,0) NOT NULL,
  LOAN_LIMIT_TYPE VARCHAR2(2 BYTE),
  CONSTRAINT PK_TB_GROUP_EXPOSURE PRIMARY KEY (APPLICATION_NO, DATA_SEQ)
);

CREATE TABLE TB_CHECK_POINTS_CS (
  APPLICATION_NO VARCHAR2(30 BYTE) NOT NULL,
  EPROC00115 VARCHAR2(2 BYTE) DEFAULT 'N',
  CONSTRAINT PK_TB_CHECK_POINTS_CS PRIMARY KEY (APPLICATION_NO)
);

CREATE TABLE TB_CHECK_POINTS_CU (
  APPLICATION_NO VARCHAR2(30 BYTE) NOT NULL,
  EPROC00115 VARCHAR2(2 BYTE) DEFAULT 'N',
  CONSTRAINT PK_TB_CHECK_POINTS_CU PRIMARY KEY (APPLICATION_NO)
);

CREATE TABLE TB_LON_SUMMARY_INFO (
  APPLICATION_NO VARCHAR2(30 BYTE) NOT NULL,
  LON_ATTRIBUTE VARCHAR2(2 BYTE),
  SECURE_ATTRIBUTE VARCHAR2(2 BYTE),
  REF_APPLICATION_NO VARCHAR2(30 BYTE),
  -- PK follows db-diff/current entity; latest PK TSV has no TB_LON_SUMMARY_INFO row.
  CONSTRAINT PK_TB_LON_SUMMARY_INFO PRIMARY KEY (APPLICATION_NO)
);

CREATE TABLE TB_COMMON_FIELD_OPTIONS (
  SYS_CODE VARCHAR2(10 BYTE) NOT NULL,
  MSG_CODE VARCHAR2(50 BYTE) NOT NULL,
  MSG_OPTION VARCHAR2(50 BYTE) NOT NULL,
  MSG_SER_NO NUMBER(4,0) NOT NULL,
  LANG_KEY VARCHAR2(50 BYTE) NOT NULL,
  UPD_EMP_NO VARCHAR2(10 BYTE) NOT NULL,
  UPD_EMP_ID VARCHAR2(10 BYTE) NOT NULL,
  UPD_EMP_NAME NVARCHAR2(20) NOT NULL,
  UPD_DATE DATE NOT NULL,
  IS_SHOW VARCHAR2(1 BYTE) NOT NULL,
  MSG_VER VARCHAR2(5 BYTE) NOT NULL,
  CONSTRAINT PK_TB_COMMON_FIELD_OPTIONS PRIMARY KEY (SYS_CODE, MSG_CODE, MSG_OPTION, LANG_KEY, MSG_VER)
);

CREATE TABLE TB_API_AUTH (
  API_ID VARCHAR2(100 BYTE) NOT NULL,
  ROLE VARCHAR2(100 BYTE) NOT NULL,
  REF_FUNCTION_ID VARCHAR2(100 BYTE),
  CONSTRAINT PK_TB_API_AUTH PRIMARY KEY (API_ID)
);

-- Required endpoint seed baseline from docs/build-tasks/c0-authz-sql-findings.md:48-50.
-- API_ID values:
--   epl-info-c0-borrower-group-exposure
--   epl-save-c0-borrower-group-exposure
--   epl-sele-c0-borrower-group-exposure
-- REF_FUNCTION_ID must be EPROC00115.
-- Route/API seed rows do not replace service-level case/edit authorization.
-- TB_PAGE_MENU is the route/menu data source, but no EPROC00115 menu DDL is owned by this bundle.
-- Route/menu identity is closed in spec.md R18 as EPROC00115 from owner decision plus inventory/schema evidence.

-- New-vs-old mapping:
-- legacy EPRO_TB_GROUP_EXPOSURE -> new TB_GROUP_EXPOSURE: carried/exact.
-- legacy EPRO_TB_CHECK_POINT_CORP.EPROC0_0115 -> new TB_CHECK_POINTS_CS.EPROC00115 for CS branch.
-- legacy EPRO_TB_CHECK_POINT_CU.EPROC0_0115 -> new TB_CHECK_POINTS_CU.EPROC00115 for CU branch.
-- legacy EPRO_TB_CHECK_POINT_RC_CORP.EPROC0_0215 and EPRO_TB_CHECK_POINT_RC_CU.EPROC0_0215:
-- db-diff says moved to CS/CU; owner decision 2026-06-24 maps modern RC 0215 behavior to CS/CU EPROC00115.
