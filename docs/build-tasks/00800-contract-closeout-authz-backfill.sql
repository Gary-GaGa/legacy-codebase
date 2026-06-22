-- EPROZ00800 page-column auth backfill for implementation closeout.
-- Apply only after DBA/RD review. This script is idempotent.
--
-- Rationale:
-- - Refactor FE spec expects data.reason.canEditList to contain "item".
-- - Current OVSLXLON02 SELECT-only proof has revised.item and buttons, but no reason.item rows.
-- - Backend mutation guard intentionally requires revised.item + reason.item + save/finish button auth.

INSERT INTO TB_PAGE_COLUMN_AUTH_DETAIL (
    FUNCTION_ID,
    COLUMN_NAME,
    COLUMN_TYPE,
    AUTH_TYPE,
    SECURE_ATTRIBUTE,
    LON_TYPE_CODE,
    PRODUCT_CODE,
    CASE_PROGRESS,
    IS_SHOW,
    CAN_EDIT,
    SYSTEM_VER,
    OTHER_VER,
    UPD_DATE
)
SELECT
    src.FUNCTION_ID,
    'item',
    'reason',
    src.AUTH_TYPE,
    src.SECURE_ATTRIBUTE,
    src.LON_TYPE_CODE,
    src.PRODUCT_CODE,
    src.CASE_PROGRESS,
    src.IS_SHOW,
    src.CAN_EDIT,
    src.SYSTEM_VER,
    src.OTHER_VER,
    SYSDATE
FROM TB_PAGE_COLUMN_AUTH_DETAIL src
WHERE src.FUNCTION_ID = 'EPROZ00800'
  AND src.COLUMN_TYPE = 'revised'
  AND src.COLUMN_NAME = 'item'
  AND NOT EXISTS (
      SELECT 1
      FROM TB_PAGE_COLUMN_AUTH_DETAIL dst
      WHERE dst.FUNCTION_ID = src.FUNCTION_ID
        AND dst.COLUMN_TYPE = 'reason'
        AND dst.COLUMN_NAME = 'item'
        AND dst.AUTH_TYPE = src.AUTH_TYPE
        AND dst.SECURE_ATTRIBUTE = src.SECURE_ATTRIBUTE
        AND dst.LON_TYPE_CODE = src.LON_TYPE_CODE
        AND dst.PRODUCT_CODE = src.PRODUCT_CODE
        AND dst.CASE_PROGRESS = src.CASE_PROGRESS
        AND dst.SYSTEM_VER = src.SYSTEM_VER
        AND dst.OTHER_VER = src.OTHER_VER
  );

COMMIT;
