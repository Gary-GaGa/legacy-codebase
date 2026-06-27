# Phase V v2-c0 RD Contract Gap: EPROC00117 financial-business ratios missing

Status: Open
Owner: RD
Classification: assertion / conformance gap
Source report: `docs/verification/phase-v-api-selfverify-report-v2-c0.md`
Manifest: `docs/build-tasks/phase-v-api-selfverify-harness-v2-c0.json`
Runtime: `tools/phase-v-run.ps1 -SkipBuild`

## Scope

`C0-117-INFO` calls `/epl-info-c0-financial-business` with `<c0-G-fixture>`.

Sanitized response/count excerpt:

| response path | API count | equivalent DB count |
|---|---:|---:|
| `data.financialList` | 0 | 0 |
| `data.ratios` | 0 | 1 |

## Expected

The read-only API response should expose the required `ratios` dictionary/list when the equivalent DB query has one row.

## Guardrails

- Confirm OpenAPI/SRS required fields before implementation changes.
- Preserve empty-data behavior only when equivalent DB count is also zero.
- Keep true application numbers and JWTs out of repo.

