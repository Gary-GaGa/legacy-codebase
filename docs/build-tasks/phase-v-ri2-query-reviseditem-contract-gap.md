# RD Contract Gap — EPROZ00800 RI-2 query revised item required options

> Status: **RESOLVED**（fix in 母資料夾 backend；gate ⑧ runtime conformance PASS 2026-06-26；**pending owner Done @ DoD 閘門牆**）  
> Created: 2026-06-26  
> Source: Phase V API selfverify harness v1.1, read-only runtime run  
> Scope: report only in this card; product code change must go through RD flow

## Resolution（2026-06-26；gate ⑧ 首例閉環）
- **as-is 對位**：legacy init 無條件先放 `revisedType`/`revisedTypeSize` 再放案件資料（`EPROZ0_0800.java:75`）；現行 query 是 `TB_LON_SUMMARY_INFO LEFT JOIN TB_REVISED_ITEM`、空案件本可回 blank items——根因＝query response path 原本沒組 required 選項字典。**openapi 確認權威**（required）後才修＝符 gate ⑧「先確認 openapi 權威」。
- **修（assertion-conformance、母資料夾 backend）**：response DTO 補 `revisedType/revisedTypeSize`；新增 DB-D5 選項查詢（`TB_COMMON_FIELD_OPTIONS` `MSG_CODE='REVISED_ITEM'`+langType label）；query path **無條件組 options**；**不改 GET/request shape**；**langType 只用於 option label、不套案件資料 WHERE**（守 LT 守門）；補單元測試（有效案件/無 row/blank items/options 仍回）。
- **驗證（gate ⑧）**：`tools/phase-v-run.ps1` → **RI-2 PASS（row=0 options=9）、RI-1+LT-1~5 不回歸**；mvn 單元測試 14/0/0、`mvn clean package` BUILD SUCCESS。
- **harness 配套**：`Get-ObjectMemberCount` 修為 `@(...).Count`（PowerShell 單屬性 `.Count` 失準的正當修正、**非弱化斷言**，commit `dd16262`，已複驗）。
- ✅ **gate ⑧ 模型端到端成立**：assertion-conformance → RD 自修（先確認契約權威）→ 不放寬契約/不抑制斷言 → harness 轉綠、無回歸。owner Done 仍待 DoD 閘門牆。

## Problem assessment
- `docs/specs/srs/EPROZ00800/openapi.yaml` defines `QueryRevisedItemResponse.data.revisedType` and `data.revisedTypeSize` as required fields.
- Phase V RI-2 uses an application that exists in `TB_LON_SUMMARY_INFO` and has no row in `TB_REVISED_ITEM`.
- Runtime response is a success data envelope with blank item fields, but it does not include `revisedType` or `revisedTypeSize`.
- This is no longer an auth or infra failure. The harness used role `403`, serviceability smoke passed, and the endpoint returned HTTP 200 + `code=0000`.

## Evidence
- Harness report: `docs/verification/phase-v-api-selfverify-report.md`
- Response dump: `docs/verification/phase-v-api-selfverify-responses/RI-2-response.json`
- Fixture:
  - RI-2 applicationNo: `<fixture-B 空revised-item>`（真案號留本機證據、不進 repo）
  - `TB_REVISED_ITEM` row count: `0`
  - revised item option SQL count: `9`
- Actual response excerpt:
  - `code`: `0000`
  - `message`: `Success`
  - `data.lonTypeCode`: `01`
  - `data.secureAttribute`: `S`
  - `data.item1`-`data.item14`: blank strings
  - `data.reasonMemo`: blank string
  - missing: `data.revisedType`
  - missing: `data.revisedTypeSize`

## Expected behavior
- For an existing case with no `TB_REVISED_ITEM` row, `/epl-case-query-reviseditem` should still return a success data envelope.
- The response should include the required revised item option dictionary and size:
  - `data.revisedType`
  - `data.revisedTypeSize`
- `revisedTypeSize` should match the read-only option SQL count for `MSG_CODE='REVISED_ITEM'` and the selected langType.

## Recommended approach
- Enter RD flow for `EPROZ00800`.
- Keep endpoint method and request shape aligned with the current SRS/openapi (`GET` query by `applicationNo`).
- Fix product behavior only after RD review confirms the current SRS required fields remain authoritative.

## Trade-offs
- Treating this as a harness path bug is now ruled out: the harness reads `data.revisedType`, and the dumped `data` object lacks that field.
- Treating this as an invalid fixture is also ruled out: the endpoint returned a success data envelope for an existing case, and DB row count for `TB_REVISED_ITEM` is zero.
- Product fix may need to decide the authoritative langType for option labels; current harness uses `PHASE_V_RI_OPTION_LANG_TYPE|en_US`.

## Minimal viable next step
- Assign RD owner to reconcile `QueryRevisedItemResponse` implementation with `docs/specs/srs/EPROZ00800/openapi.yaml`.
- Re-run `tools/phase-v-run.ps1` after the RD fix; RI-2 should pass with `row=0 options=9`.

## 可貼 Codex 啟動（RD 修復；母資料夾、產品碼變更走 RD flow）
> ⚠️ 這是**產品碼修**（非唯讀 harness）：照 brownfield 鐵則先 as-is 對位、以現行 SRS/openapi 為權威、過 DoD 機械閘門、只報不自 merge。
```
任務：修 EPROZ00800 epl-case-query-reviseditem——有效案件但無 revised-item 列時，
success envelope 仍回 required revisedType/revisedTypeSize 選項字典。
依據 docs/build-tasks/phase-v-ri2-query-reviseditem-contract-gap.md + docs/specs/srs/EPROZ00800/
（openapi.yaml QueryRevisedItemResponse required；spec.md R2/R5/R6；DB-D5 選項來源）。

1. as-is 對位（先讀不改）：
   - 比對 RevisedItemServiceImpl query 的「有 revised-item 列」vs「無列」兩條碼路——
     確認選項字典(revisedType/revisedTypeSize)的組裝是否被綁在「有列」分支裡（空案件就被略過）＝缺口根因。
   - 對照 legacy（EPROZ0_0800 init/query）空案件是否仍帶選項；以「現行 SRS/openapi required」為權威。
   - 若發現業務上空案件「本就不該帶選項」的依據 → 不自決、escalate owner（改 openapi relax，而非默默不修）。
2. 修（最小變更）：把選項字典組裝**移出「有列」分支、無條件建**：
   - revisedType＝選項清單、revisedTypeSize＝其筆數；來源 TB_COMMON_FIELD_OPTIONS/TB_MULTI_LANG（DB-D5），
     依 revised-item 欄位 key + langType 過濾。**選項本來就與案件有無資料無關**（下拉渲染所需）。
   - item1~14/reasonMemo 維持空白（spec R2「無列回 blank items」）；method/request shape 不動（GET by applicationNo，REF-D2）。
   - ⚠️ langType：選項標籤依 langType（TB_MULTI_LANG）正常過濾即可，**勿把 langType 套到資料筆數 WHERE**
     （別重蹈 RV-2/langType-as-data-filter regression；LT-1~5 守門會抓）。
3. DoD 機械閘門：mvn 後端 build 綠；契約對齊 openapi QueryRevisedItemResponse（required 二欄都在）。
4. 驗證（用既有 harness、唯讀）：跑 tools/phase-v-run.ps1 →
   RI-2 應 PASS（row=0 options=9）、RI-1 仍 PASS（不回歸）、LT-1~5 仍 PASS（langType 守門不破）。
回報：改了哪支/哪段（file:line）、build 結果、harness 重跑 PASS/FAIL 表、選項 langType 採何值。
鐵則：產品碼變更走 RD flow；as-is 先對位、現行 SRS/openapi 為權威；不改 method/request shape；
      無 DML（唯讀查證用唯讀帳號）；斷言/驗證只報不自 merge；空案件選項與 langType 守門兼顧。
```
