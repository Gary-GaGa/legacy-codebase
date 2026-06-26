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

- profile 用設定檔/參數帶入（**本機 only、不 commit**）；DB/帳密走 env 不進 repo。
- ⚠️ **YAGNI 護欄**：現況只有 EPRO 一個 app。**先把 BE/FE 兩 service 寫成預設、profile 只當「env/DB 覆寫 + timeout 調整」的薄層**，不為「未來換 app」預建多 app config 框架（無 driver）；真出現第 2 個 app 再抽（屆時＝機械重構、零損失）。

## 3. 介面（`tools/local-env.ps1 -Action <verb> [-Profile <name>]`）
| verb | 做什麼 | 退出 |
|---|---|---|
| `up` | pre-flight 埠清場 → (除非 `-SkipBuild`) build → 背景 detached 起各 service、寫 pidfile → wait-ready（health poll 帶逾時）→ 寫 descriptor | ready=0；逾時/失敗=非0（先 tail log + 自動 down）|
| `down` | kill pidfile pid **＋** kill-by-port → 驗證無 listener → 刪 pidfile/descriptor | 收乾淨=0 |
| `status` | 印 descriptor + 即時 listener/health 檢查 | up=0 / down=非0 |
| `wait-ready` | 輪詢至 ready 或逾時 | ready=0 / 逾時=非0 |
| `restart` | down + up | 同 up |

## 4. 鐵則（強健性，集中於此元件）
1. **PID 真相＝聽埠的 OwningProcess，不信 wrapper pid**（⚠️ 最關鍵、否則痛點復發）：`mvn spring-boot:run` 預設 fork 子 JVM、`yarn ng serve` 起 node/webpack 子程序——`Start-Process -PassThru` 拿到的是 **mvn/yarn wrapper pid，不是真正聽 5500/4200 的 java/node**。故：wait-ready 成功後**反查 `Get-NetTCPConnection -LocalPort <port>` 的 OwningProcess 回填 descriptor pid**；teardown **以 kill-by-port 為主**（殺真聽埠者）＋ `taskkill /PID <wrapperpid> /T /F` 殺整棵 process tree 為輔。殺 wrapper 留 orphan listener＝下次 bind 失敗＝「上次沒關停擺」復發。
2. **pre-flight 清埠要有歸屬判定**（防誤殺無辜程序）：起前清各 port 殘留，但**只殺認得的**（OwningProcess cmdline 含 `spring-boot.run`/`ng serve` + 本工具工作目錄，或對得上舊 pidfile）；**認不得的占用 → fail-fast 報明（PID+cmdline），要 `-Force` 才無條件清**，不靜默強殺；每次 kill 留 log（誰/cmdline/為何）。
3. **fail-fast、永不前景阻塞**：背景 detached + log 重導；**build 與 wait-ready 都帶逾時**（首次 `mvn`/`yarn` 可能 10min+ 或卡 Nexus；逾時 tail log → 自動 down → 非0）。首次建議先手動 build 過、之後 `-SkipBuild`。
4. **readiness 兩層、避免假綠**（解耦製造的接縫漏洞）：
   - **liveness（env manager 管、保持不碰 DB）**：BE health 200 **且 body `status:UP`**；FE **等 `ng serve` log 出 `Compiled successfully`**（非只首頁 200——bind 4200 早於編譯完成，會白屏/缺 chunk）。
   - **serviceability（消費者/runner 開跑前管）**：打**一條唯讀、會碰 DB 的代表性 endpoint** 得 200+非錯誤碼，才算「app 真能服務」；失敗回 `ENV_NOT_READY`（屬 infra、非 assertion）。env manager 維持 DB-free。
5. **down 收尾＝kill-by-port 為主 + tree-kill 補 + 驗無 listener**（承鐵則 1；wrapper pid 不可靠，故 pid 僅補刀）。
6. **單一起服務入口**：手動起一律走 `local-env up`（或其薄包裝），**不另開手動起法**——混用會產生工具不認得的無 pidfile 殘留、打穿歸屬判定。
7. **零副作用**：不碰 DB 內容、不碰 auth/JWT（那是消費者/runner 的事）；只管程序生命週期。
8. **single-instance＝靠 pre-flight + idempotent**（**不另設 lockfile mutex**：lockfile crash 殘留會永遠 abort，且 pre-flight 清埠 + 「已 ready 就重用」已達同效。真要鎖再加「記 owner pid + 驗活」的 stale-aware lock）。

## 5. descriptor（消費者契約，JSON；落 run 目錄、gitignore、**無 secret**）
```json
{ "schemaVersion": 1, "status": "ready|starting|failed|down", "profile": "epro",
  "startedAt": "...", "readyAt": "...",
  "services": {
    "be": { "url": "http://localhost:5500", "pid": 1234, "health": "ok", "log": "logs/be.log" },
    "fe": { "url": "http://localhost:4200", "pid": 5678, "health": "ok", "log": "logs/fe.log" } } }
```
- **不含 JWT/帳密**。消費者只讀 `services.<name>.url`。
- **`pid`＝聽埠的 OwningProcess**（非 wrapper；見 §4.1），供 down/除錯用。
- **descriptor＝discovery、非即時健康真相**：消費者讀到 url 後**開跑前須自己再探 health/serviceability**（§4.4）；並校驗 `schemaVersion` 與 `status==ready`，不符回 `ENV_NOT_READY`（不要拿 undefined url 跑出假 assertion FAIL）。

## 6. 消費者怎麼接（env manager 不知道測試、測試不知道起停）
- **API harness**：`tools/phase-v-api-selfverify.ps1 -BaseUrl <descriptor.services.be.url>`；打不到→回 `ENV_NOT_READY`（非 test FAIL）。
- **FE Playwright（未來）**：`baseURL = descriptor.services.fe.url`。
- **手動**：`up` → 自己點/curl → `down`。
- **runner 組合**（唯一 lifecycle+test 相遇處，測試側擁有）：
  ```
  try { local-env up; $d=read descriptor; auth=resolve per-case role→JWT; <test> -BaseUrl $d.services.be.url } finally { local-env down }
  ```

### 6b. 失敗歸因三分類（解耦的主要收益，別讓 auth 偽裝成 assertion）
拆開後失敗要能歸成**三檔**、各有 sentinel，headline 才不會像上次把 401 算進 FAIL（PARTIAL 低估成果）：
| 類 | 誰負責 | sentinel / 判定 |
|---|---|---|
| **infra**（起不來/不可達/serviceability 不過） | env manager / runner 開跑前 | env 非0 或 `ENV_NOT_READY` |
| **auth**（401/403、role 覆蓋不足） | runner/harness 的 auth 解析 | **`AUTH_FAILED`**（與 assertion 分開！RB-2 即此類） |
| **assertion**（200 但內容/契約不符） | harness | test FAIL（如 LT count、RI-2 契約） |
- **auth 是消費者/runner 的職責、非 env manager**（env 不碰 JWT）。目前 auth＝runner 一行 `resolve per-case role→JWT`（RB-2：per-case role 登入）；**先做最小**（per-case role map + `AUTH_FAILED` sentinel），**不過度建 token-cache 子系統**——真有跨多測試共用/刷新需求再抽成獨立 auth provider。

## 7. 可貼 Codex 啟動（materialize 通用 local-env manager；母資料夾、零寫 DB）
```
任務：materialize 通用本機 app 環境生命週期管理器，並自測。依據 docs/process/local-env-manager.md。
本次只做 env manager（不碰測試/harness）；不寫 DB、背景起服務不前景阻塞、try/finally 保證收尾。
1. tools/local-env.ps1：實作 -Action up/down/status、-Profile（預設 epro）、-SkipBuild。
   （wait-ready/restart 為 up 的內部步驟/糖衣，不必獨立 verb——精簡。）
   - BE/FE 兩 service 寫成預設（BE 5500 spring-boot:run / FE 4200 ng serve），profile 只當 env/DB/timeout 薄覆寫。
   - up：① pre-flight 清各 port 殘留——**但只殺認得的**（OwningProcess cmdline 含 spring-boot.run/ng serve+本工作目錄，或對得上舊 pidfile）；認不得→fail-fast 報（要 -Force 才清）、kill 留 log。
     ② (─SkipBuild 否則 build，**build 也帶逾時**) → 背景 detached 起、log 重導。
     ③ wait-ready 帶逾時＝**BE health 200 且 body status:UP；FE 等 log「Compiled successfully」**（非只首頁 200）。
     ④ **ready 後反查 Get-NetTCPConnection -LocalPort 5500/4200 的 OwningProcess 當 descriptor pid**（⚠️ 非 Start-Process 回傳的 mvn/yarn wrapper pid）。
     ⑤ 寫 descriptor（§5：schemaVersion+services.url/pid/health，無 secret）。逾時→tail log→自動 down→非0。
   - down：**kill-by-port 為主**（殺真聽埠者）＋ taskkill /PID <wrapper> /T /F 殺 tree 為輔 → 驗無 listener → 刪 pidfile/descriptor。idempotent；single-instance 靠 pre-flight（**不用 lockfile**）。
2. 自測（＝驗收）：
   a) 冷起 up→status ready；b) 再 up＝idempotent 重用不重起；c) down 後驗無 5500/4200 listener、descriptor/pidfile 已刪；
   d) **orphan 測（最關鍵）**：起一次→**只 kill mvn/yarn wrapper pid**（模擬殺錯層）→確認 5500/4200 仍被孫 java/node 佔→再 down→**驗 kill-by-port 真能清掉孫程序**（無殘留 listener）；
   e) 殘留清場：手動留一個「認得的」佔 port 程序→up pre-flight 清掉並正常起；留一個「認不得的」→up 應 fail-fast 報、不誤殺；
   f) 逾時：模擬 BE 起不來→wait-ready 逾時自動 down+非0、不卡死。
回報：各 verb exit code + descriptor（去敏，含確認 pid＝聽埠者非 wrapper）+ 自測 a~f 結果（特別 d orphan 清除）+ 用的 BE health endpoint + ready 耗時。
鐵則：env manager 不碰 DB 內容、不碰 JWT；背景不前景阻塞、build+wait 帶逾時；teardown 以 kill-by-port 為主+tree-kill；
      descriptor pid＝聽埠 OwningProcess（非 wrapper）；descriptor/pidfile/log/profile/local 不 commit；帳密走 env 不進 repo。
```

## 8. 關聯
- 強健性鐵則原始脈絡＝`build-tasks/local-phase-v-bringup.md §2.0`（本檔＝其通用化權威）。
- Phase V 消費見 `build-tasks/phase-v-env-manager.md`（profile=epro + harness/runner 接線）。
- harness＝`build-tasks/phase-v-api-selfverify-harness.md`（吃 `-BaseUrl`、不起停）。
