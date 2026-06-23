# EPROZ00800 Implementation Closeout Findings

Date: 2026-06-21 (updated 2026-06-23)

Status: code/test closeout implemented; DB page-column config backfill applied and re-verified — closeout fully green

## Summary

| Area | Result | Evidence |
|---|---|---|
| REF-D2 query method/body | PASS | BE query now uses GET `@ModelAttribute`; FE calls GET query string. |
| R6 corporate-unsecured predicate | PASS | BE computes `isCorporateUnsecured` from `LON_ATTRIBUTE='C'` and `SECURE_ATTRIBUTE='U'`; FE no longer infers from `secureAttribute='U'` alone. |
| R7 service-level mutation guard | CODE PASS | BE checks page-column auth before Revised Item/side-effect/checkpoint writes and rejects with `ACCESS_DENIED`; unit test covers rejection before mutation. |
| DB-D7 `TB_API_AUTH` query/save rows | PASS | SELECT-only run found both final API IDs with `REF_FUNCTION_ID=EPROZ00800` and no duplicate rows. |
| R7 page-column config | PASS | Backfill applied 2026-06-23; SELECT-only re-run found all four rows (`revised.item`, `reason.item`, `button.butSave`, `button.butFinish`). |

## Files Changed

- `backend/src/main/java/khd/svc/epro/controller/common/RevisedItemController.java`
- `backend/src/main/java/khd/svc/epro/dto/response/common/revisedItem/QueryReviseditemResponse.java`
- `backend/src/main/java/khd/svc/epro/repository/TBLonSummaryInfoRepository.java`
- `backend/src/main/java/khd/svc/epro/service/common/impl/RevisedItemServiceImpl.java`
- `frontend/src/app/core/models/pages/case-edition/common/revised-item.ts`
- `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/services/api.service.ts`
- `frontend/src/app/pages/case-edition/sub-pages/common/revised-item/revised-item.component.ts`
- `backend/src/test/java/khd/svc/epro/controller/common/CommonControllerApiTestSupport.java`
- `backend/src/test/java/khd/svc/epro/controller/common/RevisedItemControllerTest.java`
- `backend/src/test/java/khd/svc/epro/service/common/impl/RevisedItemServiceImplTest.java`

## DB Evidence

SELECT-only script:

- `docs/build-tasks/done/00800-contract-closeout-authz.sql`

Result excerpt:

| Check | Result |
|---|---|
| `epl-case-query-reviseditem` in `TB_API_AUTH` | FOUND, `REF_FUNCTION_ID=EPROZ00800` |
| `epl-case-insert-reviseditem` in `TB_API_AUTH` | FOUND, `REF_FUNCTION_ID=EPROZ00800` |
| `TB_API_AUTH` duplicate check | no rows |
| DB-D7 pass condition | PASS, `FOUND_ROWS=2` |
| page-column pass condition (initial 2026-06-21) | BLOCKER, `MATCHED_ROWS=3` of 4 |
| page-column pass condition (re-run 2026-06-23) | PASS, `MATCHED_ROWS=4` of 4 |

Initially-missing page-column row (now backfilled):

- `TB_PAGE_COLUMN_AUTH_DETAIL`: `FUNCTION_ID=EPROZ00800`, `COLUMN_TYPE=reason`, `COLUMN_NAME=item`

## Re-run (2026-06-23): backfill applied, closeout PASS

- `docs/build-tasks/done/00800-contract-closeout-authz-backfill.sql` was DBA/RD-applied to the page-column auth schema.
- Re-ran SELECT-only `docs/build-tasks/done/00800-contract-closeout-authz.sql`:
  - `DB_D7_RESULT=PASS`, `FOUND_ROWS=2`
  - `PAGE_COLUMN_RESULT=PASS`, `MATCHED_ROWS=4` (all of `revised.item`, `reason.item`, `button.butSave`, `button.butFinish` present).
  - The backfilled `reason.item` row carries `AUTH_TYPE=aoEdit`, `CAN_EDIT=Y`, and `SECURE_ATTRIBUTE`/`LON_TYPE_CODE`/`PRODUCT_CODE`/`CASE_PROGRESS`/`SYSTEM_VER`/`OTHER_VER` aligned to the existing `revised.item` editable source row (backfill cloned the source row, per the script's `INSERT ... SELECT`).
- R7/R16 page/edit authorization closeout is fully green; no approval blocker remains.

## Verification

- `mvn "-Dtest=RevisedItemControllerTest,RevisedItemServiceImplTest" test`
  - PASS: 20 tests, 0 failures, 0 errors.
- `node -v; .\node_modules\.bin\ng.cmd build` with Node 16.20.2
  - PASS: Angular build completed.
  - Existing warnings remain: initial bundle budget and selector parse warnings.

## Closeout Condition

Met as of 2026-06-23. The `reason.item` page-column mapping was backfilled and the SELECT-only closeout re-run returned:

- `DB_D7_RESULT=PASS`
- `PAGE_COLUMN_RESULT=PASS`

Implementation closeout (code/test/build + DB authz) is fully closed.
