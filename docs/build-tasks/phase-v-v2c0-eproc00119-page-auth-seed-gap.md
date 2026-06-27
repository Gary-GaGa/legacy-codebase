# Phase V v2-c0 Auth Gap: EPROC00119 page auth seed mismatch

Status: Open
Owner: Auth/DBA + RD
Classification: auth / AUTH_FAILED
Source report: `docs/verification/phase-v-api-selfverify-report-v2-c0.md`
Manifest: `docs/build-tasks/phase-v-api-selfverify-harness-v2-c0.json`
Runtime: `tools/phase-v-run.ps1 -SkipBuild`

## Scope

`C0-119-INFO` and `C0-119-QUER` authenticate successfully, but page-level authorization returns `E405`.

Sanitized response excerpt:

```json
{"code":"E405","message":"Access denied: You do not have permission to access this resource.","data":{}}
```

## Evidence

- Runtime service checks page access with function name `EPROC00119`.
- Read-only DB inspection found page-column auth rows for `EPROI00119`, but `EPROC00119` was `UNFOUND` in `TB_PAGE_COLUMN_AUTH_CATEGORY` / `TB_PAGE_COLUMN_AUTH_DETAIL`.
- API auth exists for `/epl-info-c0-financial-statement-cmts-fi` and `/epl-quer-c0-financial-statement-cmts-fi`; this is not a JWT login failure.

## Expected

Either seed page-column auth for `EPROC00119`, or formally decide that runtime should map this c0 FI page to the existing `EPROI00119` auth function. Do not change product behavior merely to make the harness green without owner decision.

