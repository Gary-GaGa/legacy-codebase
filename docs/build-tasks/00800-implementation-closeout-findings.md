# EPROZ00800 Implementation Closeout Findings

Date: 2026-06-21

Status: code/test closeout implemented; DB page-column config backfill pending

## Summary

| Area | Result | Evidence |
|---|---|---|
| REF-D2 query method/body | PASS | BE query now uses GET `@ModelAttribute`; FE calls GET query string. |
| R6 corporate-unsecured predicate | PASS | BE computes `isCorporateUnsecured` from `LON_ATTRIBUTE='C'` and `SECURE_ATTRIBUTE='U'`; FE no longer infers from `secureAttribute='U'` alone. |
| R7 service-level mutation guard | CODE PASS | BE checks page-column auth before Revised Item/side-effect/checkpoint writes and rejects with `ACCESS_DENIED`; unit test covers rejection before mutation. |
| DB-D7 `TB_API_AUTH` query/save rows | PASS | SELECT-only run found both final API IDs with `REF_FUNCTION_ID=EPROZ00800` and no duplicate rows. |
| R7 page-column config | BLOCKER | SELECT-only run found `revised.item`, `button.butSave`, and `button.butFinish`, but no `reason.item` row. |

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

- `docs/build-tasks/00800-contract-closeout-authz.sql`

Result excerpt:

| Check | Result |
|---|---|
| `epl-case-query-reviseditem` in `TB_API_AUTH` | FOUND, `REF_FUNCTION_ID=EPROZ00800` |
| `epl-case-insert-reviseditem` in `TB_API_AUTH` | FOUND, `REF_FUNCTION_ID=EPROZ00800` |
| `TB_API_AUTH` duplicate check | no rows |
| DB-D7 pass condition | PASS, `FOUND_ROWS=2` |
| page-column pass condition | BLOCKER, `MATCHED_ROWS=3` of 4 |

Missing page-column row:

- `TB_PAGE_COLUMN_AUTH_DETAIL`: `FUNCTION_ID=EPROZ00800`, `COLUMN_TYPE=reason`, `COLUMN_NAME=item`

Prepared backfill, not executed:

- `docs/build-tasks/00800-contract-closeout-authz-backfill.sql`

## Verification

- `mvn "-Dtest=RevisedItemControllerTest,RevisedItemServiceImplTest" test`
  - PASS: 20 tests, 0 failures, 0 errors.
- `node -v; .\node_modules\.bin\ng.cmd build` with Node 16.20.2
  - PASS: Angular build completed.
  - Existing warnings remain: initial bundle budget and selector parse warnings.

## Closeout Condition

Implementation closeout is not fully closed until DBA/RD applies or otherwise resolves the missing `reason.item` page-column mapping, then re-runs:

```sql
@docs/build-tasks/00800-contract-closeout-authz.sql
```

Expected final result:

- `DB_D7_RESULT=PASS`
- `PAGE_COLUMN_RESULT=PASS`
