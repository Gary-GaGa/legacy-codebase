# Build Task — Phase V API 自驗 harness（啟動後自動驗 API；v1 唯讀）

> **性質**：runtime 層自動驗證——人起服務後，跑一支 harness 打活的 `epl-*` + 斷言，出 PASS/FAIL。**與既有兩層互補**：`qa-to-test.md` Testcontainers＝**單元層**（隔離 DB）；`verification-execution.md`＝**唯讀碼/語意比對**；本卡＝**真的跑 endpoint 對真 OVSLXLON02**（找「跑不跑得動 / API 是否忠實反映 DB」，RV-1/RV-2 那層）。
> **載具**：harness 由 AI 產（腳本/manifest + 斷言，來源＝各頁 `qa-cases.md`）；**執行在你機器/母資料夾**（Codex 或你跑——同 localhost）。⚠️ **規劃 repo 的 agent（remote）打不到你本機 localhost**，故只產不跑。
> **長程序鐵則不變**：起服務（`spring-boot:run`/`ng serve`）仍人/腳本（`local-phase-v-bringup.md`）；本 harness ＝**啟動後的短命呼叫**（curl + 唯讀 SELECT），不持有程序 → 可自動連跑。
> **與生命週期解耦（owner 定）**：起停服務＝**通用可選工具** local-env manager（權威 `docs/process/local-env-manager.md`、`tools/local-env.ps1`；Phase V 消費見 `phase-v-env-manager.md`）；本 harness **不起停**、只吃 `-BaseUrl`（讀 descriptor `services.be.url`）跑斷言；打不到→回 `ENV_NOT_READY`（**與 test FAIL 區分**）。組合靠 `tools/phase-v-run.ps1`（env up→login→harness→finally down）。

## v1 範圍：唯讀「API ↔ DB 一致性」自驗（零寫入、零護欄負擔）
> 核心斷言：**read/list/init-query endpoint 的回應，應與等價唯讀 SQL 結果一致**（筆數/關鍵欄）。不一致＝FAIL——**RV-2 正是此類**（TODO init-query 回 0、DB 應有資料；修後筆數一致 `zh_TW`=`en_US`=**91**，見 `phase-v-harness-manifest-v1.md` LT-1）。**全程唯讀**（唯讀帳號 SELECT + GET/查詢呼叫），不寫 DB → **不需測試案件號段/teardown/快照**。
- **納入**：主流程 **i0 / z0** 的讀型 endpoint——如 `00600` search-options、`00100` todolist、`00300` checklist、`00800` init-query（reviseditem GET）、`00400` casedistribution、列表/選項類。
- **暫不納**：① **c0/csu** endpoint（未套 `c0-authz-sql` 前全 403——待 ops 套 `OVSLXLON02` 後納 v2）② **寫入**（save/submit／RI-MAT 側效——待 v3，帶 `local-phase-v-bringup §0.1` 護欄＋teardown）③ **FE 畫面 render/dialog**（瀏覽器層，需 Playwright 類＝另案，非 API 自驗）。

## harness 形狀（v1）
```
前置（人）：start-local 起 BE+FE → 真 dev 帳號登入拿 JWT（存環境變數，不進 repo）
自動（Codex/腳本，同 localhost）：
  讀 manifest（每列＝一條讀型 QA case：endpoint / method / params / 等價唯讀 SQL / 斷言）
  for each：
    call  → curl epl-*（帶 JWT、method/params 依 openapi）
    assert→ ① HTTP 200 + response 非錯誤碼 ② 唯讀 SELECT 跑等價 SQL → 比筆數/關鍵欄一致
  輸出 PASS/FAIL 表（QA-id ↔ endpoint ↔ 期望 vs 實際 ↔ 證據）
```
- **manifest 來源**：各頁 `qa-cases.md` 的讀型 case（When＝epl-*、Then＝DB 驗證點）；等價 SQL＝該 endpoint 的查詢（從 `verification-handoff`/findings 已知者起手，如 langType 五頁的 count 比對）。
- **可重複 / idempotent**：唯讀、可連跑、結果一致（同 `verification-execution §1.5`）。
- **langType regression 守門**：v1 必含「`zh_TW` 與 `en_US` 筆數一致」斷言（五頁）——直接把 RV-2 修復變成**回歸守門**，未來再有人加 langType WHERE 會被這支抓到。**此段 manifest 約定已 grounded 寫出＝`phase-v-harness-manifest-v1.md` 段①（五列 endpoint/handler/repo `file:line` + 基準筆數齊、差分斷言定義）；該檔段②另含 `EPROZ00800` init-query 兩條讀型一致斷言。harness author materialize 成 runnable 即可。**

## 可貼 Codex 啟動（v1 materialize；母資料夾）
```
任務：materialize Phase V API 自驗 harness v1（唯讀 API↔DB 一致性），照本卡 +
docs/build-tasks/phase-v-harness-manifest-v1.md。範圍 v1＝段① langType 五頁筆數一致
（LT-1~5）+ 段② EPROZ00800 init-query 讀型（RI-1/2）；皆唯讀、零寫入。
1. manifest 段①五列+段②兩列 → runnable manifest（YAML/JSON：id/endpoint/method/params/equiv_sql/assert）。
2. equiv_sql 從各列 repository native query（manifest 給的 file:line）抽、**去 langType 過濾、business filter 全留**。
3. harness 腳本（落產品 repo / 母資料夾 tools/）：人起服務（local-phase-v-bringup）+ 拿 JWT（環境變數、不進 repo）
   → 逐列 curl epl-*（langType zh_TW/en_US 各一）+ 唯讀 SELECT → 出 PASS/FAIL 表。
   主守門＝差分 count(resp[zh_TW])==count(resp[en_US])（不需 DB）；次守門＝count(resp)==count(equiv_sql)。
4. method/params 以 openapi 為準；全唯讀、不寫 DB、不啟動長程序（短命呼叫）。
回報：PASS/FAIL 表 → verification-handoff §6；FAIL 開 runtime-bug 卡。規劃 repo 留本卡+manifest、runnable 落產品 repo。
鐵則：唯讀；JWT 不進 repo；斷言失敗只報不自動改碼。
```

## 鐵則
1. **v1 全唯讀**：只 GET/查詢 + 唯讀帳號 SELECT；**不寫 DB**（任何寫入留 v3）。
2. 不啟動長程序（起服務人做）；harness 只短命呼叫。
3. JWT/帳密走環境變數**不進 repo**；FE/BE local profile **不 commit 進正式**。
4. endpoint/method/params **以 openapi 為準**（如 00800 init-query＝GET query，get-body #3 修後）。
5. 斷言失敗只報（PASS/FAIL + 證據），**不自動改碼**。

## 回報
PASS/FAIL 表 → 回填 `verification/verification-handoff.md §6`（runtime）；FAIL 項開 runtime-bug 卡（同 RV-1/RV-2 流程）。harness 腳本/manifest 落產品 repo（或母資料夾 tools/），規劃 repo 留本卡 + manifest 約定。

## 後續階段（v1 過後）
- **v2**：~~ops 套 `c0-authz-sql`~~ **✅ 已套+驗（403 解除）** → 可納 c0/csu 讀型 endpoint（v1 過後接續）。
- **v3**：寫入自驗（save/submit）——帶 `local-phase-v-bringup §0.1` 護欄（測試案件號段 + teardown SQL 人審 + 快照）；唯讀斷言可全自動、寫入需 seed/清理。
- **FE 層**（選配）：Playwright 類 render/dialog smoke＝另案，非本卡。

> 過了：Phase V 從「人工點」變「人起服務 → 跑自驗 → PASS/FAIL」；langType/get-body 類 regression 進**自動回歸守門**；smoke V-2~V-6 的 API 部分自動化（FE-render 部分另案）。
