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

## Owner decision (2026-06-27)
- **Seed `EPROC00119` page-column-auth**（corporate 自有授權）— 符 c0 自足鏡像 i0 鐵則（`backend/AGENTS.md §6.1`：c0 不委派 i0、自含）；**不**改 runtime 映射到 EPROI00119。
- 由 **DBA/owner 產 seed SQL（`TB_PAGE_COLUMN_AUTH_CATEGORY`/`_DETAIL` 的 EPROC00119 列）交人審執行**——DML 不由 agent 直執行（同 `c0-authz-sql` 模式）。
- **順帶（completeness check）**：DBA 唯讀盤點 c0-authz seed 對**其他 8 個 c0 頁**（00110/112/114/115/116/117/118/120）的 page-column-auth 覆蓋——確認是只 00119 漏、還是普遍漏；漏的一併補 seed SQL。
- 修+套 seed 後重跑 v2 → C0-119-INFO/QUER 應轉 PASS。

