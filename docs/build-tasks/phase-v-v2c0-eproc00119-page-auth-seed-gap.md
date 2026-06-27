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

## Seed recipe（鏡像生成；值來自 DB、不手寫——planning 側無法給死值）
> 表結構/EPROI00119 實列在母資料夾 OVSLXLON02。下列為**可跑配方**：先確認欄名 → 盤點 → 鏡像 INSERT…SELECT（複製 EPROI00119 列、funcId 換 EPROC00119）。**DBA 審 + 跑**（DML 不由 agent）。
```sql
-- 0) 確認兩表欄名 + 哪欄是 funcId（OVSLXLON02）
SELECT table_name, column_name, data_type, nullable
FROM all_tab_columns
WHERE table_name IN ('TB_PAGE_COLUMN_AUTH_CATEGORY','TB_PAGE_COLUMN_AUTH_DETAIL')
ORDER BY table_name, column_id;

-- 1) 盤點：EPROC00119 缺 vs EPROI00119 有；順帶查 9 c0 頁完整性（<FUNC_COL>=步驟0的 funcId 欄）
SELECT <FUNC_COL>, COUNT(*) cnt FROM TB_PAGE_COLUMN_AUTH_DETAIL
WHERE <FUNC_COL> IN ('EPROC00110','EPROC00112','EPROC00114','EPROC00115','EPROC00116',
                     'EPROC00117','EPROC00118','EPROC00119','EPROC00120','EPROI00119')
GROUP BY <FUNC_COL> ORDER BY <FUNC_COL>;     -- CATEGORY 表同查

-- 2) 鏡像生成 seed（冪等：步驟1 確認 EPROC00119 cnt=0 才跑）；<col...>＝步驟0 全欄、funcId 欄填字面 'EPROC00119'
INSERT INTO TB_PAGE_COLUMN_AUTH_DETAIL (<col1>,<col2>,...,<FUNC_COL>,...)
SELECT <col1>,<col2>,...,'EPROC00119',...    -- funcId 欄改字面、其餘照抄 i0
FROM TB_PAGE_COLUMN_AUTH_DETAIL WHERE <FUNC_COL> = 'EPROI00119';
-- TB_PAGE_COLUMN_AUTH_CATEGORY 同模式
COMMIT;
```
- ⚠️ **套用前審**：① 確認 c0 該頁編輯角色＝i0 同一組(若 corporate 角色不同需改 role 欄、非純鏡像) ② 冪等(EPROC00119 不存在才 INSERT) ③ 限 c0 funcId、不動他列。
- 完整性：步驟1 若發現其他 c0 頁也缺(v2 只測到 119 缺、其他讀型 PASS→多半只 119)，比照鏡像補。

