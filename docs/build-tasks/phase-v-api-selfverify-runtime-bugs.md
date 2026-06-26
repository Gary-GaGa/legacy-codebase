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

## RB-4 RI-2 response shape mismatch（獨立複驗：升級為「疑真契約缺口」，非單純釐清）
- RI-2 FAIL：`response missing revisedType`
- API call 成功進入 endpoint；DB row count = `0`，option SQL count = `9`。
- **獨立複驗補正（planning-side 對現行契約查證）**：現行 `docs/specs/srs/EPROZ00800/openapi.yaml` 的 `QueryRevisedItemResponse` **把 `revisedType`/`revisedTypeSize` 列為 `required`**（`:216`-`:217`、`:236`/`:241`）；`spec.md` R2（`:42`）要求「case 存在但無 revised item 列時回 blank items」（即仍是 data envelope、非錯誤）。**故若 fixture 是「有 case、無 revised item」的有效案號，API 不回 `revisedType`＝違反現行 openapi required＝真 runtime 契約缺口**（正是 Phase V 要抓的 build-綠/runtime-錯）。
- **先消歧（harness 下一輪必做，才能定真假）**：
  1. **dump 完整 response JSON**（非只看缺欄旗標）——確認回的是 **data envelope**（含 blank items）還是 **error envelope `MSG_DATA_NOT_FOUND`**（spec R2：「no matching case」才回此）。
  2. **確認 fixture 案號性質**：是「有 case、無 revised-item 列」(→應有 revisedType，缺＝真 bug) 還是「無 case」(→ `MSG_DATA_NOT_FOUND` 屬正確、harness 該改取有效空案號)。
  3. 確認 harness 取 `revisedType` 的 path（top-level vs `data.revisedType`）對齊 openapi envelope。
- **判定分支**：有效空案號 + data envelope 缺 `revisedType` → **開 RD 契約缺口卡**（API 漏必填 option 字典）；若 fixture 是無 case / path 取錯 → 修 fixture/assertion，非產品 bug。
- ⚠️ **非過期 v0.9 問題**：00800 已重產（現行 bundle 在 `docs/specs/srs/EPROZ00800/`、非 archive v0.9）；本斷言對**現行** openapi 有效，manifest §② 不需等重產。

## 獨立複驗結論（planning-side 交叉驗證，2026-06-25）
- ✅ **v1 核心目標達成**：合併 3 份 role 分片報告，**LT-1~LT-5 五頁全部 count 對齊 PASS**（`zh_TW==en_US==DB`：todolist `1=1=1`、casedist `5=5=5`/`0`、caseapp `0=0=0`、deviation `293=293=293`、cancelreport `10=10=10`）。主報告 LT-3/4/5 的「FAIL」**純為 401 role 覆蓋、非 count 不符**＝langType RV-2 回歸守門已自動化且綠。headline `PARTIAL` 低估此成果。
- 🟡 **RB-1/RB-2/RB-3＝harness/env，非產品回歸**：RB-1 檔名 mismatch（tooling）、RB-2 單 JWT 覆蓋（TB_API_AUTH per-endpoint role scoping 正確、401 是正確授權行為，需 per-case role 或唯讀 verification role）、RB-3 RI-1 Windows PS5.1 BOM（env）。
- 🔴 **RB-4＝疑真契約缺口**（見上、需 dump 消歧）。
- 📌 **附帶觀察（既有已知）**：API auth 用 `ROLE LIKE %roleId%` 子字串比對（role `10` 會中 `101`/`1010`）＝over-match 風險，屬「`TB_API_AUTH` seed 單獨不足、必配 service-guard」既有議題（spec-architecture §5b Rule 3、N 軸 D），非本次新 bug。

## 待驗收條件
- `tools/phase-v-api-selfverify.ps1 -ManifestPath docs/build-tasks/phase-v-api-selfverify-harness-v1.json` 可在單一正式驗證策略下完成，不需手動改路徑。
- v1 所有 cases 可用明確授權策略跑完；若維持單 JWT，需有一個 role 覆蓋全部 v1 endpoint。
- RI-1 不再被 SQLPlus BOM 訊息污染。
- RI-2 empty-case response contract 與 manifest assertion 一致。

## 可貼 Codex 啟動（v1.1 harness 修復 + 重跑；母資料夾、全唯讀）
> 起停服務改用已驗收的 **`tools/local-env.ps1`**（`process/local-env-manager.md`）；harness 不起停、只吃 `-BaseUrl`。
```
任務：harness v1.1——改吃 local-env 的 BaseUrl、修 RB-1/3、per-case role(RB-2)、消歧 RB-4，
加歸因三分類 + serviceability smoke，重跑至全 PASS（或 RI-2 開 RD 契約卡）。
照 docs/build-tasks/phase-v-api-selfverify-runtime-bugs.md + process/local-env-manager.md。
全唯讀、零寫 DB、結束必 down。

0. 順手修 LE-2：tools/local-env.ps1 line 91 Get-Node16Root 的硬編 C:\Users\00596357\...node\v16.20.2
   改走 -Profile/env（如 NODE16_ROOT），找不到再 fallback PATH node；不在腳本內留機器路徑/工號。
1. RB-1：tools/phase-v-api-selfverify.ps1 -ManifestPath 預設改指
   docs/build-tasks/phase-v-api-selfverify-harness-v1.json（或 rename 對齊），免帶參數即可跑。
2. RB-3（RI-1 BOM）：harness 寫 temp SQL 改 UTF-8 no BOM（.NET UTF8Encoding($false) 或 -Encoding ascii；
   或用 PS7）→ SQLPlus 不吐 SP2-0734、DB JSON 可解析。修後 RI-1 才真正跑得出逐欄比對。
3. RB-2（授權覆蓋）：manifest 每 case 標所需 role、harness per-case 用對應 role 登入
   （open /epl-ut-login 對既有 TB_EMP_PROFILE role 拿 JWT＝唯讀、不建 role、不寫 DB）→ 單次涵蓋全 v1。
   〔不新建 verification role：需 TB_API_AUTH DML 須人審、違 v1 唯讀。〕
4. 歸因三分類 sentinel（讓 401 不被算成 test FAIL）：
   - infra（env 起不來/打不到/serviceability 不過）→ ENV_NOT_READY
   - auth（401/403、role 覆蓋不足）→ AUTH_FAILED（與 assertion 分開！）
   - assertion（200 但內容/契約不符）→ test FAIL
5. RB-4（RI-2 消歧）：對「有 case、無 revised-item 列」的有效空案號跑，dump 完整 response JSON：
   - data envelope 但缺 required revisedType（對 docs/specs/srs/EPROZ00800/openapi.yaml QueryRevisedItemResponse）
     → 開 RD 契約缺口卡（只報不修產品碼）。
   - error envelope MSG_DATA_NOT_FOUND → 該 fixture 是「無 case」、改取有效空案號重跑。
   - revisedType 在 data.* 而 harness 取錯 path → 修 assertion path 對齊 openapi envelope。
6. runner（tools/phase-v-run.ps1）組合：
   try {
     tools/local-env.ps1 -Action up -Profile epro        # 已驗收的 env manager（含 pre-flight/逾時/真 pid）
     $d = read local-env descriptor；校驗 schemaVersion + status==ready，否則 ENV_NOT_READY
     serviceability smoke：打一條唯讀、會碰 DB 的代表性 endpoint 得 200+非錯誤碼（env 的 UP 只是 liveness、非真健康）
                           → 不過＝ENV_NOT_READY（infra，非 assertion）
     login → per-role JWT（env，不進 repo）
     tools/phase-v-api-selfverify.ps1 -BaseUrl $d.services.be.url -ManifestPath ...harness-v1.json
   } finally { tools/local-env.ps1 -Action down }        # 成敗都收（kill-by-port 為主）
7. 重跑 LT-1~5 + RI-1 + RI-2 → 出 PASS/FAIL 表（三分類標明）→ 回填 verification-handoff §6.3、更新本卡。
回報：PASS/FAIL 表（infra/auth/assertion 分類）+ 用的 role/fixture 案號 + RI-2 完整 response 摘錄（去敏）
     + serviceability smoke 結果 + LE-2 修畢確認 + down 後無 5500/4200 listener。
鐵則：全唯讀；JWT/帳密走 env 不進 repo；斷言失敗只報不自動改產品碼；harness 不起停（靠 local-env）；
     finally 必 down；c0 授權列已套 OVSLXLON02、c0 不再 403。
```

> **獨立複驗定調**：v1 核心（langType RV-2 回歸守門）**已綠**（LT 五頁全 PASS）；本卡修的是 harness/env（RB-1/2/3）+ 釐清 RB-4 真假。RB-4 若確認＝產品契約缺口，走 RD flow 修（非本 harness 卡範圍）。
