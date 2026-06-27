# Phase V v2-c0 B4 Planning Reverify

Status: PASS
Date: 2026-06-27
Scope: B4 planning reverify after A1 auth seed, A2 RD fixes, and B3 v2-c0 runtime rerun.

## Conclusion

B4 is complete. The v2-c0 manifest rerun is green end-to-end:

- `tools/phase-v-run.ps1 -SkipBuild` completed with exit `0`.
- `docs/verification/phase-v-api-selfverify-report-v2-c0.md` has 17 cases, 17 PASS, 0 FAIL.
- `5500` / `4200` had no LISTENING socket after teardown.
- No JWT, empId, or real application number was written to repo.

## Reverify Matrix

| Check | Result | Evidence |
|---|---|---|
| Full v2-c0 runtime | PASS | `phase-v-api-selfverify-report-v2-c0.md`: 17 PASS / 0 FAIL |
| Harness fixture integrity | PASS | `docs/build-tasks/phase-v-api-selfverify-harness-v2-c0.json` has no git diff |
| langType fix is product behavior | PASS | `findByFields` keeps option parent rows and resolves label via requested lang, `en_US`, then `TO_NCHAR(MSG_OPTION)` |
| 00117 ratios is a contract gap fix | PASS | OpenAPI requires `data.ratios`; PRD says query action reads saved `TB_FINANCIAL_EVALUATION_GI`; runtime `C0-117-INFO` passes |
| 00119/00120 auth seed completeness | PASS | SELECT-only DB counts match i0 sources: `EPROC00119` category/detail `3/46`, `EPROC00120` category/detail `3/64` |

## Evidence

### langType

The fix did not change harness fixture data. The v2-c0 manifest has no git diff.

Code path:

- `backend/src/main/java/khd/svc/epro/repository/TBCommonFieldOptionsRepository.java`
- `findByFields` now joins `TB_MULTI_LANG` twice:
  - requested `:langType`
  - fallback `en_US`
- It no longer filters parent option rows by `L.LANG_TYPE = :langType`.
- Final fallback uses `TO_NCHAR(O.MSG_OPTION)`.

SELECT-only schema proof:

```text
TB_COMMON_FIELD_OPTIONS.MSG_OPTION = VARCHAR2
TB_MULTI_LANG.LANG_NAME = NVARCHAR2
```

Runtime proof:

- `C0-115-SELE`: PASS, zh_TW/en_US/DB counts match.
- `C0-116-SELE`: PASS, zh_TW/en_US/DB counts match.
- `C0-117-SELE`: PASS, zh_TW/en_US/DB counts match.
- `C0-119-SELE`: PASS, zh_TW/en_US/DB counts match.

### EPROC00117 ratios

Contract proof:

- `docs/specs/srs/EPROC00117/openapi.yaml` requires `data.ratios` in the `infoC0FinancialBusiness` response.
- `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00117-v1.0.md` says query action reads saved `TB_FINANCIAL_EVALUATION_GI`; non-query action recalculates from financial statement GI rows.
- v2-c0 manifest compares `data.ratios` to `TB_FINANCIAL_EVALUATION_GI`.

Code path:

- `backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuFinancialStaffServiceImpl.java`
- `isQuery=true` always reads persisted `TB_FINANCIAL_EVALUATION_GI`.
- Non-query compute/persist remains gated by source financial rows.

Runtime proof:

```text
C0-117-INFO PASS: financialList=0;ratios=1; DB financialList=0;ratios=1
```

### EPROC00119 / EPROC00120 page-column auth

Owner decision was to seed c0 page-column-auth, not map runtime to i0.

SELECT-only DB proof after DBA apply:

```text
EPROC00119 CATEGORY 3
EPROC00119 DETAIL   46
EPROC00120 CATEGORY 3
EPROC00120 DETAIL   64
EPROI00119 CATEGORY 3
EPROI00119 DETAIL   46
EPROI00120 CATEGORY 3
EPROI00120 DETAIL   64
```

Runtime proof:

- `C0-119-INFO`: PASS.
- `C0-119-QUER`: PASS.
- `C0-120-INFO`: PASS.

## Runtime Summary

Command shape:

```powershell
.\tools\phase-v-run.ps1 `
  -ManifestPath .\docs\build-tasks\phase-v-api-selfverify-harness-v2-c0.json `
  -OutFile .\docs\verification\phase-v-api-selfverify-report-v2-c0.md `
  -ResponseDumpDir .\docs\verification\phase-v-api-selfverify-responses-v2-c0 `
  -SkipBuild
```

Result:

```text
TOTAL=17 PASS=17 FAIL=0
exit=0
teardown=down completed
listeners=5500/4200 none
```

## Decision

B4 planning reverify is PASS. The Phase V v2-c0 read harness is ready to leave the v2 gap-fix lane and proceed to the next runbook step.
