-- c0 scoring authorization backfill, DB-free pre-production SQL.
-- Do not run from Codex. Apply only after DB/ops review.
--
-- API_ID values intentionally use the slash-stripped RPC route id, matching
-- APIAuthorizationFilter request.getRequestURI().replace("/", "").
--
-- Role source:
-- - TB_API_AUTH rows copy ROLE from exact i0 API rows by API_ID and REF_FUNCTION_ID.
-- - TB_ROLE_TASK rows copy ROLE/FUNCTION/PAGE_NAME from exact i0 page rows.
-- Idempotency:
-- - TB_API_AUTH skips a target API_ID that already exists.
-- - TB_ROLE_TASK skips a target PAGE_CODE + FUNCTION that already exists.
-- If any i0 source row is missing, that mapping inserts 0 rows and must be
-- investigated by ops before Phase V verification.
-- UNSURE: OVSLXLON02 precheck found no source auth row for
-- epl-pxls-i0-financial-statement-comments; the corresponding c0 endpoint
-- currently has no row, so this mapping inserts 0 rows until ops supplies
-- a reviewed role/source row.

INSERT INTO TB_API_AUTH (
    API_ID,
    ROLE,
    REF_FUNCTION_ID,
    UPDATE_USER,
    UPDATE_DATE
)
WITH endpoint_map (
    TARGET_API_ID,
    TARGET_FUNCTION_ID,
    SOURCE_API_ID,
    SOURCE_FUNCTION_ID
) AS (
    SELECT 'epl-info-c0-credit-investigation-tab', 'EPROC00110', 'epl-info-i0-credit-investigation-tab', 'EPROI00110' FROM DUAL UNION ALL
    SELECT 'epl-save-c0-credit-investigation-tab', 'EPROC00110', 'epl-save-i0-credit-investigation-tab', 'EPROI00110' FROM DUAL UNION ALL
    SELECT 'epl-info-c0-cbc-banking-relationship', 'EPROC00112', 'epl-info-i0-cbc-banking-relationship', 'EPROI00112' FROM DUAL UNION ALL
    SELECT 'epl-save-c0-cbc-banking-relationship', 'EPROC00112', 'epl-save-i0-cbc-banking-relationship', 'EPROI00112' FROM DUAL UNION ALL
    SELECT 'epl-sele-c0-collateral-assessment', 'EPROC00114', 'epl-sele-i0-collateral-assessment', 'EPROI00114' FROM DUAL UNION ALL
    SELECT 'epl-info-c0-collateral-assessment', 'EPROC00114', 'epl-info-i0-collateral-assessment', 'EPROI00114' FROM DUAL UNION ALL
    SELECT 'epl-save-c0-collateral-assessment', 'EPROC00114', 'epl-save-i0-collateral-assessment', 'EPROI00114' FROM DUAL UNION ALL
    SELECT 'epl-info-c0-borrower-group-exposure', 'EPROC00115', 'epl-info-i0-borrower-group-exposure', 'EPROI00115' FROM DUAL UNION ALL
    SELECT 'epl-save-c0-borrower-group-exposure', 'EPROC00115', 'epl-save-i0-borrower-group-exposure', 'EPROI00115' FROM DUAL UNION ALL
    SELECT 'epl-sele-c0-borrower-group-exposure', 'EPROC00115', 'epl-sele-i0-borrower-group-exposure', 'EPROI00115' FROM DUAL UNION ALL
    SELECT 'epl-sele-c0-financial-statement-comments', 'EPROC00116', 'epl-sele-i0-financial-statement-comments', 'EPROI00116' FROM DUAL UNION ALL
    SELECT 'epl-quer-c0-financial-statement-comments', 'EPROC00116', 'epl-quer-i0-financial-statement-comments', 'EPROI00116' FROM DUAL UNION ALL
    SELECT 'epl-info-c0-financial-statement-comments', 'EPROC00116', 'epl-info-i0-financial-statement-comments', 'EPROI00116' FROM DUAL UNION ALL
    SELECT 'epl-calc-c0-financial-statement-comments', 'EPROC00116', 'epl-calc-i0-financial-statement-comments', 'EPROI00116' FROM DUAL UNION ALL
    SELECT 'epl-save-c0-financial-statement-comments', 'EPROC00116', 'epl-save-i0-financial-statement-comments', 'EPROI00116' FROM DUAL UNION ALL
    SELECT 'epl-ppdf-c0-financial-statement-comments', 'EPROC00116', 'epl-ppdf-i0-financial-statement-comments', 'EPROI00116' FROM DUAL UNION ALL
    SELECT 'epl-pxls-c0-financial-statement-comments', 'EPROC00116', 'epl-pxls-i0-financial-statement-comments', 'EPROI00116' FROM DUAL UNION ALL
    SELECT 'epl-sele-c0-corporateScorecard-list', 'EPROC00118', 'epl-sele-i0-corporateScorecard-list', 'EPROI00118' FROM DUAL UNION ALL
    SELECT 'epl-info-c0-corporateScorecard', 'EPROC00118', 'epl-info-i0-corporateScorecard', 'EPROI00118' FROM DUAL UNION ALL
    SELECT 'epl-calc-c0-corporateScorecard', 'EPROC00118', 'epl-calc-i0-corporateScorecard', 'EPROI00118' FROM DUAL UNION ALL
    SELECT 'epl-save-c0-corporateScorecard', 'EPROC00118', 'epl-save-i0-corporateScorecard', 'EPROI00118' FROM DUAL UNION ALL
    SELECT 'epl-quer-c0-financial-statement-cmts-fi', 'EPROC00119', 'epl-quer-i0-financial-statement-cmts-fi', 'EPROI00119' FROM DUAL UNION ALL
    SELECT 'epl-info-c0-financial-statement-cmts-fi', 'EPROC00119', 'epl-info-i0-financial-statement-cmts-fi', 'EPROI00119' FROM DUAL UNION ALL
    SELECT 'epl-calc-c0-financial-statement-cmts-fi', 'EPROC00119', 'epl-calc-i0-financial-statement-cmts-fi', 'EPROI00119' FROM DUAL UNION ALL
    SELECT 'epl-pxls-c0-financial-statement-cmts-fi', 'EPROC00119', 'epl-pxls-i0-financial-statement-cmts-fi', 'EPROI00119' FROM DUAL UNION ALL
    SELECT 'epl-ppdf-c0-financial-statement-cmts-fi', 'EPROC00119', 'epl-ppdf-i0-financial-statement-cmts-fi', 'EPROI00119' FROM DUAL UNION ALL
    SELECT 'epl-save-c0-financial-statement-cmts-fi', 'EPROC00119', 'epl-save-i0-financial-statement-cmts-fi', 'EPROI00119' FROM DUAL UNION ALL
    SELECT 'epl-info-c0-financial-evaluation-table-fi', 'EPROC00120', 'epl-info-i0-financial-evaluation-table-fi', 'EPROI00120' FROM DUAL UNION ALL
    SELECT 'epl-save-c0-financial-evaluation-table-fi', 'EPROC00120', 'epl-save-i0-financial-evaluation-table-fi', 'EPROI00120' FROM DUAL
)
SELECT
    DISTINCT
    m.TARGET_API_ID,
    src.ROLE,
    m.TARGET_FUNCTION_ID,
    'C0AUTHZ',
    SYSDATE
FROM endpoint_map m
JOIN TB_API_AUTH src
    ON src.API_ID = m.SOURCE_API_ID
    AND src.REF_FUNCTION_ID = m.SOURCE_FUNCTION_ID
WHERE NOT EXISTS (
    SELECT 1
    FROM TB_API_AUTH dst
    WHERE dst.API_ID = m.TARGET_API_ID
);

INSERT INTO TB_ROLE_TASK (
    PAGE_CODE,
    ROLE,
    FUNCTION,
    PAGE_NAME
)
WITH page_map (
    TARGET_PAGE_CODE,
    SOURCE_PAGE_CODE
) AS (
    SELECT 'EPROC00110', 'EPROI00110' FROM DUAL UNION ALL
    SELECT 'EPROC00112', 'EPROI00112' FROM DUAL UNION ALL
    SELECT 'EPROC00114', 'EPROI00114' FROM DUAL UNION ALL
    SELECT 'EPROC00115', 'EPROI00115' FROM DUAL UNION ALL
    SELECT 'EPROC00116', 'EPROI00116' FROM DUAL UNION ALL
    SELECT 'EPROC00118', 'EPROI00118' FROM DUAL UNION ALL
    SELECT 'EPROC00119', 'EPROI00119' FROM DUAL UNION ALL
    SELECT 'EPROC00120', 'EPROI00120' FROM DUAL
)
SELECT
    DISTINCT
    m.TARGET_PAGE_CODE,
    src.ROLE,
    src.FUNCTION,
    src.PAGE_NAME
FROM page_map m
JOIN TB_ROLE_TASK src
    ON src.PAGE_CODE = m.SOURCE_PAGE_CODE
WHERE NOT EXISTS (
    SELECT 1
    FROM TB_ROLE_TASK dst
    WHERE dst.PAGE_CODE = m.TARGET_PAGE_CODE
      AND dst.FUNCTION = src.FUNCTION
);

-- 00117 is intentionally check-only in this build task.
-- Run after DB connectivity is restored:
-- SELECT API_ID, ROLE, REF_FUNCTION_ID FROM TB_API_AUTH WHERE REF_FUNCTION_ID = 'EPROC00117' ORDER BY API_ID, ROLE;
-- SELECT PAGE_CODE, ROLE, FUNCTION, PAGE_NAME FROM TB_ROLE_TASK WHERE PAGE_CODE = 'EPROC00117' ORDER BY FUNCTION, ROLE;

COMMIT;
