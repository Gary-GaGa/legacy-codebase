# Build Task — Phase V 環境生命週期管理器（env manager；與測試解耦）

> **載具**：Codex 在母資料夾 materialize（腳本落產品 repo `tools/`，需 localhost）；規劃 repo 只留本契約。
> **定位**：把「起/停 BE+FE 服務」抽成**獨立可重用元件**，**與自驗 harness / Playwright 測試分開**。服務生命週期 = 本元件；測試只「消費已起好的環境」。
> **為何拆**：① **失敗歸因清楚**——「服務起不來」=infra（env manager FAIL），「斷言不符」=test（harness FAIL）；上次 PARTIAL_PASS_FAIL 正是兩者混在一起。② **跨層復用**——L2 API harness（v1/v2/v3）、L3 FE Playwright、手動 smoke 都靠同一套起停。③ **harness 變簡單**——可對「已起好的環境」（人起的 / CI / 別處起的）直接跑。

## 1. 三層邊界（職責切開）
```
┌─ env manager (tools/phase-v-env.ps1) ─ 純程序生命週期，不碰測試/不碰 JWT ─┐
│   up / down / status / wait-ready / restart                              │
│   產出 env descriptor（base URL + pid + health）→ 消費者讀               │
└──────────────────────────────────────────────────────────────────────────┘
        ▲ 讀 descriptor.be.url                    ▲ 讀 descriptor.fe.url
┌─ harness (tools/phase-v-api-selfverify.ps1) ─┐  ┌─ L3 Playwright（未來）──┐
│  -BaseUrl <descriptor.be.url>                │  │  baseURL=descriptor.fe  │
│  只跑 case→PASS/FAIL，不起/不停服務          │  └─────────────────────────┘
└───────────────────────────────────────────────┘
        ▲ 組合（唯一讓 lifecycle+test 相遇處）
┌─ runner (tools/phase-v-run.ps1) ─ try{ env up → login→JWT → harness } finally{ env down } ─┐
└──────────────────────────────────────────────────────────────────────────────────────────┘
```
- **env manager 不碰 JWT/授權**——那是 test/runner 的事（harness 需 per-case role，見 runtime-bug RB-2）。env manager = 純「服務起得來、健康、收得乾淨」。
- **harness 不碰起停**——拿 BaseUrl 就跑；打不到 → 回 `ENV_NOT_READY`（**與 test FAIL 區分**），叫人先 `env up`。

## 2. env manager 介面（`tools/phase-v-env.ps1 -Action <verb>`）
| verb | 做什麼 | 退出 |
|---|---|---|
| `up` | pre-flight 埠清場 → (可選)build → 背景 detached 起 BE+FE → 寫 pidfile → wait-ready（health poll 帶逾時）→ 寫 descriptor | ready=0；逾時/失敗=非0（先 tail log + 自動 down）|
| `down` | kill pidfile pid **＋** kill-by-port(5500/4200) → 驗證無 listener → 刪 pidfile/descriptor | 收乾淨=0 |
| `status` | 印 descriptor + 即時 listener/health 檢查 | up=0 / down=非0 |
| `wait-ready` | 輪詢至 ready 或逾時 | ready=0 / 逾時=非0 |
| `restart` | = down + up | 同 up |

**參數（皆有預設、無 secret）**：`-SkipBuild`（環境已 build 過時跳過）、`-BeTimeoutSec 180`、`-FeTimeoutSec 300`（ng serve 編譯較久）、`-BePort 5500`、`-FePort 4200`、`-LogDir`、`-Profile`。DB url=OVSLXLON02、帳密走 env 不進 repo。

## 3. 鐵則（＝既有 `local-phase-v-bringup.md §2.0` 的元件化落地）
1. **idempotent up**：已 ready 就重用、不重起；起前必 pre-flight 清 5500/4200 殘留 listener + 舊 pidfile。
2. **single-instance mutex**：lockfile 防同時兩份 up（上次沒收尾 → 先全清再起）。
3. **fail-fast，永不前景阻塞**：背景 detached + log 重導；wait-ready 帶逾時，逾時 tail log → 自動 down → 非0。
4. **readiness 看 health/200，非只看 port**：BE 打 health endpoint、FE 打 `http://localhost:<FePort>` 得 200 才算 ready。
5. **down 雙保險**：kill pid **＋** kill-by-port + **驗無 listener** 才算收尾（pid 可能遺失）。
6. **零寫 DB**：env manager 不碰 DB 內容（連線設定除外）；唯讀原則同 v1。

## 4. env descriptor（消費者契約，JSON；落 run 目錄、gitignore、無 secret）
```json
{ "status": "ready|starting|failed|down",
  "startedAt": "...", "readyAt": "...",
  "be": { "url": "http://localhost:5500", "pid": 1234, "health": "ok", "log": "logs/be.log" },
  "fe": { "url": "http://localhost:4200", "pid": 5678, "health": "ok", "log": "logs/fe.log" } }
```
- **不含 JWT/帳密**（auth 是 harness/runner 的事）。harness/Playwright 只讀 `be.url`/`fe.url`。

## 5. harness 對應調整（解耦後）
- `tools/phase-v-api-selfverify.ps1` **移除起停邏輯**，新增 `-BaseUrl`（從 descriptor `be.url`）；拿不到 → 回 `ENV_NOT_READY`（非 test FAIL）。
- per-case role/JWT（RB-2）仍在 harness/runner（env manager 不碰）。
- 既有 RB-1/RB-3/RB-4 修正不變，只是「起服務」那段移到 env manager。

## 6. runner 組合（唯一 lifecycle+test 相遇處）
```
tools/phase-v-run.ps1：
  try {
    tools/phase-v-env.ps1 -Action up            # 起+wait-ready（含 pre-flight）
    $env = read phase-v-env.json
    login (env 帳密) → 各 role JWT             # auth 在這層，不在 env manager
    tools/phase-v-api-selfverify.ps1 -BaseUrl $env.be.url -ManifestPath ...
  } finally {
    tools/phase-v-env.ps1 -Action down          # 成敗都收，雙保險 teardown
  }
```

## 7. 可貼 Codex 啟動（materialize env manager；母資料夾、全唯讀）
```
任務：materialize Phase V env manager（服務生命週期，與 harness 解耦），照
docs/build-tasks/phase-v-env-manager.md。產品 repo tools/，全唯讀（不寫 DB）、不前景阻塞。
1. tools/phase-v-env.ps1：實作 -Action up/down/status/wait-ready/restart（§2 介面）。
   - up：pre-flight 清 5500/4200 listener+舊 pidfile → (─SkipBuild 否則 build) → 背景 detached
     起 BE(spring-boot:run)+FE(ng serve)、log 重導、寫 pidfile → wait-ready（BE health 200 ≤180s、
     FE :4200 200 ≤300s）→ 寫 phase-v-env.json（§4 schema，無 secret）。逾時→tail log→自動 down→非0。
   - down：kill pidfile pid + kill-by-port(5500/4200) + 驗無 listener + 刪 pidfile/descriptor。
   - single-instance mutex（lockfile）；idempotent（已 ready 重用）。
2. 改 tools/phase-v-api-selfverify.ps1：移除起停，新增 -BaseUrl（讀 descriptor be.url）；
   打不到→回 ENV_NOT_READY（非 test FAIL）。RB-1/3/4 修正照 runtime-bug 卡。
3. tools/phase-v-run.ps1：try{ env up → login→per-role JWT → harness -BaseUrl } finally{ env down }（§6）。
4. 自測：env up→status（ready）→down（驗無 listener）跑兩輪確認 idempotent + 收乾淨；
   故意留一個殘留 listener 再 up，確認 pre-flight 清得掉。
回報：env up/down/status 各 exit code + descriptor 內容（去敏）+ 兩輪 idempotent 結果。
鐵則：全唯讀；帳密/JWT 走 env 不進 repo；背景不前景阻塞、帶逾時；結束必 teardown（雙保險）；
      env manager 不碰 DB 內容、不碰 JWT。descriptor/pidfile/log/local profile 不 commit（gitignore）。
```

## 8. 關聯
- 鐵則來源＝`local-phase-v-bringup.md §2.0`（本元件＝其落地）；harness 行為＝`phase-v-api-selfverify-harness.md` + runtime-bug 卡（RB-1/2/3/4）。
- 未來 L3 Playwright 直接讀 descriptor `fe.url` 當 baseURL，不另起服務。
- 自動化計畫定位見 `phase-v-automation-plan.md`（L1 bring-up＝本元件）。
