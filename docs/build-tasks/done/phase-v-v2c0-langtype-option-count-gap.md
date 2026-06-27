# Phase V v2-c0 RD Contract Gap: c0 option langType count mismatch

Status: **Resolved**（v2-c0 17/17 PASS；待 Phase V 收尾一併歸檔 done/）
Owner: RD
Classification: assertion / conformance gap
Source report: `docs/verification/phase-v-api-selfverify-report-v2-c0.md`
Manifest: `docs/build-tasks/phase-v-api-selfverify-harness-v2-c0.json`
Runtime: `tools/phase-v-run.ps1 -SkipBuild`

## Scope

Read-only c0 option endpoints return HTTP 200 + success code, but `zh_TW` option lists are empty while `en_US` and equivalent DB counts are non-zero.

| case | endpoint | fixture | zh_TW excerpt | en_US / DB excerpt |
|---|---|---|---|---|
| C0-115-SELE | `/epl-sele-c0-borrower-group-exposure` | `-` | `facilityList=0; loanLimitTypeList=0; ccyList=0; titleDeedTypeList=0` | `3; 2; 2; 5` |
| C0-116-SELE | `/epl-sele-c0-financial-statement-comments` | `<c0-G-fixture>` | `currencyList=0; currencyUnitList=0; typeOfYearList=0` | `2; 3; 2` |
| C0-117-SELE | `/epl-sele-c0-financial-list` | `<c0-G-fixture>` | `ccyList=0` | `2` |
| C0-119-SELE | `/epl-sele-c0-financial-statement-comments` | `<c0-F-fixture>` | `currencyList=0; currencyUnitList=0; typeOfYearList=0` | `2; 3; 2` |

## Expected

- `zh_TW` count equals `en_US` count.
- API count equals equivalent read-only DB count.
- `langType` should select labels only, not remove option rows.

## Guardrails

- Do not patch by changing fixture data.
- Do not hit `calc`, `save`, `submit`, or export endpoints for this card.
- Keep true application numbers and JWTs out of repo.

