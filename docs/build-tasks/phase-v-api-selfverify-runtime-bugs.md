# Build Task — Phase V API selfverify harness v1 runtime bugs

> 載具：Codex（本機 FE+BE bring-up + API/DB read-only harness）。**性質＝runtime verification FAIL card；只報不修**。
> 發現日：2026-06-25。DB：`OVSLXLON02`。服務已背景啟動、ready 後執行 harness，結束已 teardown，無 5500/4200 listener。

## 結論
- Build/bring-up gate 綠：BE Maven package、FE Yarn install、FE Angular build 均成功。
- LT-1～LT-5 在「授權 role 分片」下 API count 與 DB count 可對齊。
- v1 以單一 `PHASE_V_JWT` 跑完整 manifest 仍 FAIL，原因是目前 `TB_API_AUTH` 沒有單一 role 覆蓋全部 v1 endpoint。
- RI-1/RI-2 仍 FAIL，需要修 harness runtime 或釐清 revised item response contract。

## 實跑輸出
- `docs/verification/phase-v-api-selfverify-report.md`
- `docs/verification/phase-v-api-selfverify-report-role403.md`
- `docs/verification/phase-v-api-selfverify-report-role101.md`

## RB-1 manifest path mismatch
- `tools/phase-v-api-selfverify.ps1` default `ManifestPath` 指到：
  `docs/build-tasks/phase-v-api-selfverify-manifest-v1.json`
- 目前 repo 實際檔案是：
  `docs/build-tasks/phase-v-api-selfverify-harness-v1.json`
- 本次以 `-ManifestPath docs/build-tasks/phase-v-api-selfverify-harness-v1.json` 明確指定後才可執行。

## RB-2 single-JWT authorization coverage gap
- API auth 實作：`request.getRequestURI().replace("/", "")` 對 `TB_API_AUTH.API_ID`，並用 `ROLE LIKE %roleId%` 判斷。
- SELECT-only 授權覆蓋結果：沒有任何單一 role 覆蓋 v1 全部 endpoint。
- 觀察：
  - role `405`：LT-1/LT-2 PASS，LT-3/LT-4/LT-5 401。
  - role `403`：LT-2/LT-3/LT-4/LT-5 PASS，LT-1 401。
  - role `101`：LT-1/LT-2/LT-4/LT-5 PASS，LT-3 401。
- 建議擇一：
  - 為 Phase V selfverify 建立一個只讀 verification role，授權 v1 read/list/init-query endpoints。
  - 或把 manifest 拆成 role-scoped runs，harness 支援 per-case JWT/role。

## RB-3 RI-1 DB JSON parse fails under Windows PowerShell 5.1
- RI-1 FAIL：`Invalid JSON primitive: SP2-0734.`
- 直接原因：harness 內 `Invoke-DbSql` 用 `Set-Content -Encoding UTF8` 產 SQL temp file；Windows PowerShell 5.1 會寫 UTF-8 BOM，SQLPlus 將第一行視為 `SP2-0734`，污染 DB JSON scalar output。
- LT count cases 取最後一行，未受此污染；RI-1 需要整段 JSON，所以失敗。
- 建議：temp SQL 改 UTF-8 no BOM / ASCII，或要求用 PowerShell 7；本次不改碼。

## RB-4 RI-2 response shape mismatch
- RI-2 FAIL：`response missing revisedType`
- API call 成功進入 endpoint；DB row count = `0`，option SQL count = `9`。
- 需釐清：
  - empty revised item case 是否仍應回傳 `revisedType` option list。
  - 或 manifest assertion 應改成實際 response path。

## 待驗收條件
- `tools/phase-v-api-selfverify.ps1 -ManifestPath docs/build-tasks/phase-v-api-selfverify-harness-v1.json` 可在單一正式驗證策略下完成，不需手動改路徑。
- v1 所有 cases 可用明確授權策略跑完；若維持單 JWT，需有一個 role 覆蓋全部 v1 endpoint。
- RI-1 不再被 SQLPlus BOM 訊息污染。
- RI-2 empty-case response contract 與 manifest assertion 一致。
