# 本機 App 環境生命週期管理器（local-env manager）— AI 流程可選工具

> **定位**：通用、**可選**的本機工具——把「在本機把 app（BE+FE）跑起來、確認健康、收乾淨」抽成一套，**任何需要 live 本機環境的 flow 階段都能呼叫**，不綁 Phase V。**非 spec pipeline 必經站＝可選**（需要 runtime 才用）。
> **載具**：腳本落產品 repo `tools/`（需 localhost），規劃 repo 留本契約（權威）。Codex 在母資料夾跑；Claude 側＝本檔。**單一共用腳本、非 Claude/Codex 雙版**（不列雙軌 parity anchor）。
> **為何抽出來**：① 失敗歸因清楚——「服務起不來」＝env FAIL（infra），「驗證不符」＝該測試 FAIL（assertion），不再混在一起；② 跨階段復用——下列每個消費者都靠同一套起停，不各自重刻；③ 把「埠殘留/卡死/上次沒關停擺」的強健性集中一處顧好。

## 1. 何時用（flow 可選接入點）
| 階段 | 用途 |
|---|---|
| **RD as-is/runtime 驗** | 母資料夾把 app 跑起來、人工或 agent 對 live 環境查「真的跑不跑得動」 |
| **Phase V L1/L2/L3** | L1＝起停本體；L2 API harness、L3 FE Playwright 都消費 descriptor 的 base URL |
| **手動 smoke** | 一鍵起、跑完一鍵收，不怕殘留 |
| **未來 DoD runtime gate / CI** | 自動起→驗→收的前置 |

> **可選＝預設不介入**：spec/RD 主線不強制用；要 live 環境時才 `up`，用完 `down`。

## 2. 通用契約（不 hardcode 單一 app）
**可配置 services profile**（每個 service 一組，預設 profile＝EPRO，但可換／可擴）：
| 欄位 | 說明 | EPRO 預設 |
|---|---|---|
| `name` | 服務名 | `be` / `fe` |
| `startCmd` | 啟動指令（背景 detached） | `mvn spring-boot:run` / `yarn ng serve` |
| `buildCmd` | （可選）build | `mvn clean package -Dmaven.test.skip=true` / `yarn install --frozen-lockfile && yarn ng build` |
| `port` | 監聽埠 | `5500` / `4200` |
| `healthUrl` | readiness 探測（得 200 才 ready） | BE health endpoint / `http://localhost:4200` |
| `readyTimeoutSec` | 逾時上限 | `180` / `300` |
| `log` | stdout/stderr 重導檔 | `logs/be.log` / `logs/fe.log` |

- profile 用設定檔/參數帶入（**本機 only、不 commit**）；DB/帳密走 env 不進 repo。換 app 只換 profile，腳本不動。

## 3. 介面（`tools/local-env.ps1 -Action <verb> [-Profile <name>]`）
| verb | 做什麼 | 退出 |
|---|---|---|
| `up` | pre-flight 埠清場 → (除非 `-SkipBuild`) build → 背景 detached 起各 service、寫 pidfile → wait-ready（health poll 帶逾時）→ 寫 descriptor | ready=0；逾時/失敗=非0（先 tail log + 自動 down）|
| `down` | kill pidfile pid **＋** kill-by-port → 驗證無 listener → 刪 pidfile/descriptor | 收乾淨=0 |
| `status` | 印 descriptor + 即時 listener/health 檢查 | up=0 / down=非0 |
| `wait-ready` | 輪詢至 ready 或逾時 | ready=0 / 逾時=非0 |
| `restart` | down + up | 同 up |

## 4. 鐵則（強健性，集中於此元件）
1. **idempotent up**：已 ready 就重用、不重起；起前必 pre-flight 清各 service port 殘留 listener + 舊 pidfile。
2. **single-instance mutex**（lockfile）：偵測既有 up 在跑＝上次沒收尾 → 先全清再起。
3. **fail-fast、永不前景阻塞**：背景 detached + log 重導；wait-ready 帶逾時，逾時 tail log → 自動 down → 非0。
4. **readiness 看 health/200，非只看 port**。
5. **down 雙保險**：kill pid ＋ kill-by-port ＋ **驗無 listener** 才算收尾。
6. **零副作用**：env manager **不碰 DB 內容、不碰 auth/JWT**（那是消費者的事）；只管程序生命週期。

## 5. descriptor（消費者契約，JSON；落 run 目錄、gitignore、**無 secret**）
```json
{ "status": "ready|starting|failed|down", "profile": "epro",
  "startedAt": "...", "readyAt": "...",
  "services": {
    "be": { "url": "http://localhost:5500", "pid": 1234, "health": "ok", "log": "logs/be.log" },
    "fe": { "url": "http://localhost:4200", "pid": 5678, "health": "ok", "log": "logs/fe.log" } } }
```
- **不含 JWT/帳密**。消費者只讀 `services.<name>.url`。

## 6. 消費者怎麼接（env manager 不知道測試、測試不知道起停）
- **API harness**：`tools/phase-v-api-selfverify.ps1 -BaseUrl <descriptor.services.be.url>`；打不到→回 `ENV_NOT_READY`（非 test FAIL）。
- **FE Playwright（未來）**：`baseURL = descriptor.services.fe.url`。
- **手動**：`up` → 自己點/curl → `down`。
- **runner 組合**（唯一 lifecycle+test 相遇處，測試側擁有）：
  ```
  try { local-env up; $d=read descriptor; login→JWT; <test> -BaseUrl $d.services.be.url } finally { local-env down }
  ```

## 7. 可貼 Codex 啟動（materialize 通用 local-env manager；母資料夾、零寫 DB）
```
任務：materialize 通用本機 app 環境生命週期管理器，並自測。依據 docs/process/local-env-manager.md。
本次只做 env manager（不碰測試/harness）；不寫 DB、背景起服務不前景阻塞、try/finally 保證收尾。
1. tools/local-env.ps1：實作 -Action up/down/status/wait-ready/restart、-Profile（預設 epro）、-SkipBuild。
   - services profile 可配置（§2 表；epro 預設 BE 5500 spring-boot:run / FE 4200 ng serve），不 hardcode。
   - up：pre-flight 清各 port 殘留 listener+舊 pidfile → (─SkipBuild 否則 build) → 背景 detached 起、log 重導、
     寫 pidfile → wait-ready（health 200 帶逾時）→ 寫 descriptor（§5 schema，無 secret）。逾時→tail log→自動 down→非0。
   - down：kill pid + kill-by-port + 驗無 listener + 刪 pidfile/descriptor。single-instance mutex；idempotent。
2. 自測（＝驗收）：
   a) 冷起 up→status ready；b) 再 up＝idempotent 重用不重起；c) down 後驗無 listener、descriptor/pidfile 已刪；
   d) 手動留一個佔 port 的程序 → up 應 pre-flight 清掉並正常起；e) 模擬起不來 → wait-ready 逾時自動 down+非0、不卡死。
回報：各 verb exit code + descriptor（去敏）+ 自測 a~e 結果 + 用的 health endpoint + ready 耗時。
鐵則：env manager 不碰 DB 內容、不碰 JWT；背景不前景阻塞、帶逾時；結束必 teardown（雙保險）；
      descriptor/pidfile/log/profile/local 設定不 commit（gitignore）；帳密走 env 不進 repo。
```

## 8. 關聯
- 強健性鐵則原始脈絡＝`build-tasks/local-phase-v-bringup.md §2.0`（本檔＝其通用化權威）。
- Phase V 消費見 `build-tasks/phase-v-env-manager.md`（profile=epro + harness/runner 接線）。
- harness＝`build-tasks/phase-v-api-selfverify-harness.md`（吃 `-BaseUrl`、不起停）。
