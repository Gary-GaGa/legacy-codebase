# Phase V v2-c0 Page-Column Auth Seed Findings

Status: **DB_SEED_APPLIED_VERIFIED; RUNTIME_AUTH_PASS**

No DML was executed by Codex. Owner/DBA reported the seed SQL was applied,
then Codex re-ran SELECT-only verification against `OVSLXLON02`.

## Artifacts

- SELECT-only precheck: `docs/build-tasks/phase-v-v2c0-page-column-auth-precheck.sql`
- DBA-reviewed seed candidate: `docs/build-tasks/phase-v-v2c0-page-column-auth-seed.sql`
- Runtime source report: `docs/verification/phase-v-api-selfverify-report-v2-c0.md`
- Original gap card: `docs/build-tasks/done/phase-v-v2c0-eproc00119-page-auth-seed-gap.md`

## Decision Applied To The Artifact

- Keep c0 authorization self-contained.
- Seed c0 `TB_PAGE_COLUMN_AUTH_CATEGORY` / `TB_PAGE_COLUMN_AUTH_DETAIL` rows.
- Do not remap runtime page authorization from `EPROC00119` to `EPROI00119`.
- Do not execute DML from agent runtime.

## SELECT-Only Precheck Result

Command:

```powershell
<epro-db>/new.cmd @docs\build-tasks\phase-v-v2c0-page-column-auth-precheck.sql
```

Physical columns confirmed:

- `TB_PAGE_COLUMN_AUTH_CATEGORY`: `FUNCTION_ID`, `ROLE`, `CASE_PROGRESS`, `ISQUERY`, `AUTH_TYPE`, `AUTH_REMARK`
- `TB_PAGE_COLUMN_AUTH_DETAIL`: `FUNCTION_ID`, `COLUMN_NAME`, `COLUMN_TYPE`, `AUTH_TYPE`, `SECURE_ATTRIBUTE`, `LON_TYPE_CODE`, `PRODUCT_CODE`, `CASE_PROGRESS`, `IS_SHOW`, `CAN_EDIT`, `SYSTEM_VER`, `OTHER_VER`, `UPD_DATE`
- Declared constraints: none found for either table in `OVSLXLON02`

Coverage result:

| Target funcId | Source funcId | Target category | Source category | Target detail | Source detail | Status |
|---|---|---:|---:|---:|---:|---|
| `EPROC00110` | `EPROI00110` | 3 | 3 | 2 | 6 | HAS_TARGET |
| `EPROC00112` | `EPROI00112` | 3 | 3 | 40 | 40 | HAS_TARGET |
| `EPROC00114` | `EPROI00114` | 4 | 4 | 78 | 78 | HAS_TARGET |
| `EPROC00115` | `EPROI00115` | 3 | 3 | 33 | 33 | HAS_TARGET |
| `EPROC00116` | `EPROI00116` | 3 | 3 | 38 | 24 | HAS_TARGET |
| `EPROC00117` | `EPROI00117` | 3 | 3 | 10 | 44 | HAS_TARGET |
| `EPROC00118` | `EPROI00118` | 4 | 4 | 156 | 156 | HAS_TARGET |
| `EPROC00119` | `EPROI00119` | 0 | 3 | 0 | 46 | MISSING_TARGET |
| `EPROC00120` | `EPROI00120` | 0 | 3 | 0 | 64 | MISSING_TARGET |

Conclusion:

- `EPROC00119` is missing page-column-auth seed rows.
- `EPROC00120` is also missing page-column-auth seed rows.
- The seed SQL covers both missing zero-target pages.
- Existing nonzero c0 pages are not auto-normalized to i0 row counts here; those
  differences may be deliberate c0-specific authorization config and need a
  separate owner parity review before any change.

## Seed Impact

Expected first apply from the precheck baseline:

- `TB_PAGE_COLUMN_AUTH_CATEGORY`: 6 inserted rows total
  - `EPROC00119`: 3 rows copied from `EPROI00119`
  - `EPROC00120`: 3 rows copied from `EPROI00120`
- `TB_PAGE_COLUMN_AUTH_DETAIL`: 110 inserted rows total
  - `EPROC00119`: 46 rows copied from `EPROI00119`
  - `EPROC00120`: 64 rows copied from `EPROI00120`

The SQL copies all source column values except `FUNCTION_ID`, which is changed
to the c0 target funcId. `UPD_DATE` is copied from source to preserve exact
mirror semantics.

## DBA Apply Checklist

1. Apply only after DBA/owner review.
2. Confirm current schema is `OVSLXLON02` before running DML.
3. Review whether c0 edit/query roles for `EPROC00119` and `EPROC00120` should
   be identical to i0 before accepting the mirror copy.
4. Run the post-apply verify queries at the bottom of the seed SQL.
5. Re-run Phase V v2-c0 cases at minimum:
   - `C0-119-INFO`
   - `C0-119-QUER`
   - `C0-120-INFO` as a no-regression smoke because 00120 is included in the seed.

Expected post-apply condition:

- `EPROC00119` category/detail row counts match `EPROI00119`.
- `EPROC00120` category/detail row counts match `EPROI00120`.
- `SOURCE_MINUS_TARGET=0` and `TARGET_MINUS_SOURCE=0` for both tables/pages.

## Post-Apply SELECT-Only Verification

Command:

```powershell
<epro-db>/new.cmd @docs\build-tasks\phase-v-v2c0-page-column-auth-precheck.sql
```

Post-apply coverage:

| Target funcId | Source funcId | Target category | Source category | Target detail | Source detail | Status |
|---|---|---:|---:|---:|---:|---|
| `EPROC00119` | `EPROI00119` | 3 | 3 | 46 | 46 | HAS_TARGET |
| `EPROC00120` | `EPROI00120` | 3 | 3 | 64 | 64 | HAS_TARGET |

Transformed mirror parity:

| Target funcId | Table | SOURCE_MINUS_TARGET | TARGET_MINUS_SOURCE |
|---|---|---:|---:|
| `EPROC00119` | `TB_PAGE_COLUMN_AUTH_CATEGORY` | 0 | 0 |
| `EPROC00119` | `TB_PAGE_COLUMN_AUTH_DETAIL` | 0 | 0 |
| `EPROC00120` | `TB_PAGE_COLUMN_AUTH_CATEGORY` | 0 | 0 |
| `EPROC00120` | `TB_PAGE_COLUMN_AUTH_DETAIL` | 0 | 0 |

## Runtime Rerun

Command shape:

```powershell
.\tools\phase-v-run.ps1 `
  -ManifestPath .\docs\build-tasks\phase-v-api-selfverify-harness-v2-c0.json `
  -OutFile .\docs\verification\phase-v-api-selfverify-report-v2-c0.md `
  -ResponseDumpDir .\docs\verification\phase-v-api-selfverify-responses-v2-c0 `
  -SkipBuild
```

Runtime setup:

- `tools/phase-v-run.ps1 -SkipBuild` was used for the final full v2-c0 rerun.
- Role-scoped login env for roles `001` and `405` was resolved from
  `TB_EMP_PROFILE` in the same process; values were not written to repo.
- c0 G and c0 F application numbers were set in process env only.
- The runner exited `0`, teardown completed, and no `5500` / `4200` LISTENING
  sockets remained after the run.

Result:

| Case | Status | Detail |
|---|---|---|
| `C0-119-INFO` | PASS | `balanceList=2;incomeList=2;cashflowList=2`, DB counts match |
| `C0-119-QUER` | PASS | `balanceList=2;incomeList=2;cashflowList=2`, DB counts match |
| `C0-120-INFO` | PASS | `financialList=2`, DB counts match |

The full v2-c0 manifest now passes 17/17 cases. No `C0-119-INFO` /
`C0-119-QUER` auth failure remains.
