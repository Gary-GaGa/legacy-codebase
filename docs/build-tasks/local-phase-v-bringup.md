# Build Task — 本機 FE+BE 同跑 runtime 整合驗證（Phase V runtime 層）

> 載具：**你/Codex 在母資料夾**（規劃 repo 起不了服務——無原始碼）。**性質＝runtime 整合測試**，與 `verification/verification-execution.md`（Codex bounded session 逐項唯讀「程式碼/語意比對」）互補：那層找邏輯 gap，本卡找「真的跑不跑得動」。
> **觸發**：DB 連線已通，runtime 這層第一次可行。
> **長程序鐵則**（`process/SETUP-codex.md`）：`ng serve` / `spring-boot:run` **絕不讓 agent 跑**（等不到結束會卡死）——你在自己終端跑，agent 只改 code / 看錯誤。

## 0. 決策：寫入測試打 `OVSLXLON02`（使用者裁定）
> 本機 BE 用 **DB 既有帳號**（**不創新帳號**——讀 backend datasource config 既有 profile，或唯讀查 `ALL_USERS` 撈 `OVSLXLON02` 既有可用帳號）直連 **正式新 app schema `OVSLXLON02`** 做 save/submit 寫測。**已知代價＝測試髒資料會寫進正式新庫**——故下列護欄為**強制**：

### 0.1 護欄（寫測前必讀，強制）
1. **測試案件可識別**：寫測一律用**保留測試案件號段**（與真案件不撞；開測前先 SELECT 確認該段未被佔用，記錄用了哪些 `APPLICATION_NO`/caseNo）。
2. **可清除**：寫測前列「預期會動到的表」清單；測完產 **teardown SQL**（DELETE 限定測試案件號）——**DML 不由 agent 直執行**（`decisions.md §三`），產檔交人審套用，同 `c0-authz-sql` 模式。
3. **快照**：寫測前請 DBA 對受影響表（或整 schema）做一次快照/備份；無法快照則只挑「可由 teardown 完全還原」的頁先測。
4. **不撞線上使用**：避開他人實際使用 `OVSLXLON02` 的時段；寫測時段與 owner 對齊。
5. **唯讀帳號做查證/清單**：寫測後的「比對實際落庫」用 agent **唯讀帳號** SELECT（不另開寫權給 agent）。

## 1. 前置 gate（缺一不可往下）
- [ ] **後端可 build**：Nexus `maven-settings.xml` → `mvn clean package -Dmaven.test.skip=true` 綠（baseline 測試與 main 不同步，跳測試編譯）。
- [ ] **前端可 build**：Node **16.20.2**（`nvm use`；切版刪 `node_modules` 重裝）→ `yarn install --frozen-lockfile` → `yarn ng build` 綠。
- [x] **授權列已套+驗**（測 c0/csu 頁的前提）：`OVSLXLON02` 已套 `docs/build-tasks/c0-authz-sql.sql`（**ops applied + DBA verified**，33 rows incl ratified pxls/confirm；pxls==ppdf、confirm==save 驗畢）——c0 endpoint 403 前置解除。service-guard 層仍 RD code-stage。
- [ ] **BE profile** 指向：DB URL=`OVSLXLON02`、**既有帳號**（讀 config／`ALL_USERS` 撈，不創新；密碼不進 repo）、（護欄 0.1 的測試案件段就緒）。
- [ ] **FE `environment`** API base 指向 local BE（**勿 commit 進正式 profile**）。

## 2. Bring-up 順序

### 2.0 Bring-up 強健性鐵則（防「起不來/卡死/上次沒關停擺」——每次起服務前後必遵）
> **元件化（owner 定）**：下列鐵則抽成**獨立 env manager 元件**（`tools/phase-v-env.ps1` up/down/status），**與自驗 harness/測試解耦**——契約見 **`phase-v-env-manager.md`**。本節＝該元件的鐵則來源；harness 改為「消費已起好的環境」（拿 `BaseUrl`、不起停）。
> 已知兩大坑：① **埠殘留**——上次 BE/FE 沒 teardown，5500/4200 被佔 → 本次 bind 失敗、整個停擺；② **起服務卡住**——前景長程序或等不到 ready 卻無逾時 → 卡死 turn。對策：

1. **Pre-flight 埠清場（起服務前必做、idempotent）**：先掃並清掉 5500(BE)/4200(FE) 殘留 listener + 舊 pidfile，**才**起新服務。
   - PS：`Get-NetTCPConnection -LocalPort 5500,4200 -State Listen -EA SilentlyContinue | Select -Expand OwningProcess | Sort -Unique | %{ Stop-Process -Id $_ -Force -EA SilentlyContinue }`（fallback：`netstat -ano | findstr ":5500 :4200"` 取 PID → `taskkill /PID <pid> /F`）。
   - 若偵測到既有 Phase V BE/FE 仍在跑＝上次未收尾 → **先全清再起**（單跑互斥）。
2. **起服務 fail-fast（防卡死）**：背景 detached 起、stdout/stderr 重導到 log 檔；**health-poll 帶逾時**（BE ≤180s、FE ng serve 編譯較久 ≤300s）；逾時 → tail log 回報 → teardown → 標 FAIL，**絕不無限等**。
3. **健康判定看 readiness、非只看 port**：BE 打 health/ready endpoint 得 200；FE 打 `http://localhost:4200` 得 200（首頁/asset）才算 ready。
4. **保證 teardown（finally/trap，成敗都收）**：把 harness 包在 try/finally（PS：`try{..}finally{..}` 或 trap）→ 無論 PASS/FAIL/例外都 teardown；**kill 記錄 pid ＋ kill-by-port**（pid 可能遺失，雙保險）＋**驗證 5500/4200 已無 listener** 才算收尾。
5. **pidfile 紀律**：起服務即寫 pidfile（含啟動時間）；teardown 後刪。下次 pre-flight 讀到舊 pidfile＝上次沒收乾淨 → 一併清。

> **分工（v1 唯讀 self-driving）**：原「AI 只設定、人起服務」是為避開**前景長程序卡死 session**；改用**背景 detached 程序**即可解 → **v1 唯讀由 Codex 自啟動全跑**（不再需人手起服務）。
```
v1 自啟動（Codex，全背景、不阻塞 turn）：
  設定    撈既有帳號→設 BE profile(url=OVSLXLON02、不創新帳號、密碼 env 不進 repo)→ mvn build 綠 / yarn install
  起服務  背景 detached 起 BE(spring-boot:run)+FE(ng serve)、記 pid（不阻塞）
  待命    輪詢 health 直到 BE/FE ready（逾時則回報、teardown）
  登入    帳密(env、不進 repo)打 login API 拿 JWT → 設 PHASE_V_JWT 等 env
  自驗    跑 tools/phase-v-api-selfverify.ps1 → PASS/FAIL 表
  teardown kill BE/FE pid（不留殭屍程序）→ 回填 handoff §6.3、FAIL 開 runtime-bug 卡
```
> **fallback（帳密不可放 env）**：Codex 自啟動+poll+teardown 照跑，唯 JWT 由你手動登入貼一次、其餘自動。
> **⚠️ v3 寫入仍需人審**：save/submit 的 teardown SQL/DML **不由 Codex 直執行**（打正式新庫 OVSLXLON02），產檔交人審，同 `c0-authz-sql` 模式。v1 唯讀零寫入故可全自動。
> auth bypass（dummy token / 關 guard）**只限本機、絕不 commit**。BE/FE profile/啟動腳本＝**本機 only、勿 commit**（含本機路徑/帳密；母資料夾已 gitignore）。

### 可貼 Codex 自啟動殼（v1 唯讀，全自動）
```
任務：Phase V harness v1 自啟動全自動驗（照 docs/build-tasks/local-phase-v-bringup.md +
phase-v-api-selfverify-harness.md）。全背景、不阻塞 turn；v1 唯讀零寫入。
1. 設定：用 Nexus settings → mvn clean package -Dmaven.test.skip=true 綠；Node 16.20.2 →
   yarn install --frozen-lockfile → yarn ng build 綠。設 BE profile（DB url=OVSLXLON02、
   既有帳號〔讀 config 或唯讀查 ALL_USERS〕、密碼走 env〔不創新帳號、不進 repo〕）、FE environment 指 local BE。
2. 起服務（背景 detached、記 pid，勿前景阻塞）：BE `spring-boot:run`、FE `ng serve`。
3. 輪詢 health 至 BE/FE ready（逾時 → 回報 + teardown 收尾、不留殭屍）。
4. 登入：帳密（env、不進 repo）打 login API 拿 JWT → 設 PHASE_V_JWT；設 PHASE_V_DB_RUNNER、
   PHASE_V_RI_WITHOUT_REVISED_APP_NO 等 fixture、PHASE_V_RI_OPTION_LANG_TYPE。
   （帳密無法放 env → 停在這步、請人貼一次 JWT，其餘續自動。）
5. 跑 tools/phase-v-api-selfverify.ps1（短命 curl + 唯讀 SELECT；ps1 內建擋寫 SQL）→ PASS/FAIL 表。
6. teardown：kill BE/FE pid（務必，不留殭屍程序）。
7. 回報：PASS/FAIL 表 → 回填 docs/verification/verification-handoff.md §6.3；FAIL 開 runtime-bug 卡。
鐵則：全程唯讀零寫入；帳密/JWT 走 env 不進 repo；起服務用背景不前景阻塞；結束必 teardown；
      斷言失敗只報不自動改碼；c0 授權列已套 OVSLXLON02，c0 不再 403。
```

## 3. 能驗 / 不能驗矩陣
| 範圍 | 能否本機 | 前提 / 備註 |
|---|---|---|
| 個金/企金主流程 載入·save·submit·return | ✅ 端到端 | 寫帳號 + 測試案件段（護欄 0.1）|
| Phase G 新頁 G1–G3（0150/0160/0170+popup）互動·save | ✅ | 同上；**G3 共用 return dialog 改造的 ISU 回歸一併測**（caseType 切 ISU 走預設 endpoint）|
| c0/csu 評分頁 00110–00120 | ✅（需先套授權列）| 否則 403（gate §1）|
| 契約對齊 FE↔BE DTO | ✅ | 真資料/真授權跑一次（handoff §5）|
| 角色權限分支顯示、businessType G/F 切換 | ⚠️ 受限 | 需真 JWT + 真案件資料 |
| 撥貸 authorize（T24）| 🚫 本機測不到 | T24/SFTP 外部整合起不來（authorize 核心 A-1 換匯 stub **已實作＋conformance PASS**，`daae4c3` 06-16；但 T24 端到端仍需外部整合，見 handoff §2.2 更正）|
| R2 報表 PDF（0181/00640 PDF…）| 🚫 | R2 報表服務未建 |
| 檔案上傳 API | 🚫 | 暫緩 track |

## 4. 建議 smoke 順序（由淺入深，先驗不寫的）
1. 登入 + 開一個**唯讀載入頁**（如個金主流程 borrower 載入）→ 確認 FE↔BE↔DB 三段通、JWT/授權鏈活。
2. 開 **Phase G 新頁**（0150/0160/0170）render + dropdown + 載入（不 save）→ 驗版面/契約。
3. 對**測試案件**做一次 **save**（個金或企金主流程）→ 唯讀帳號 SELECT 確認落庫正確。
4. 套授權列後，開 **c0/csu 評分頁** → 確認非 403、載入/calc/save。
5. G3 **共用 return dialog**：CSU return → CSU endpoint；切 ISU → 預設 endpoint（**回歸**）。
6. 寫測收尾：產 **teardown SQL**（限測試案件）交人審清庫。

## Tasks（checklist——session 中斷在此記斷點續跑）
- [ ] T0 AI 撈既有帳號→設 BE profile→build 確認→**產 start-local 腳本交人**（AI 到此停，不啟動）
- [ ] T1 前置 gate 四項綠（build×2 / 授權列 / profile+environment）
- [ ] T2 人執行 start-local → BE+FE 起來、登入通（smoke 1）
- [ ] T3 Phase G 新頁 render/載入（smoke 2）
- [ ] T4 主流程 save 落庫驗證（smoke 3；測試案件段）
- [ ] T5 c0/csu 評分頁非 403（smoke 4；授權列已套）
- [ ] T6 G3 return dialog ISU 回歸（smoke 5）
- [ ] T7 teardown SQL 產出交人審（smoke 6）
- 斷點：（起手＝T1）

## 回報
- 每項 PASS/FAIL/⚠️ + 證據（畫面截點 / 唯讀 SELECT 結果 / 錯誤訊息）；**不吐大段 code**。
- 用了哪些測試 `APPLICATION_NO`；teardown SQL 路徑 + 預期刪除筆數。
- 結果回填 `verification/verification-handoff.md` §6（runtime）對應列 + `feature-inventory.md`。

> 過了：主流程/Phase G/c0-csu 的 runtime 整合驗證落地；撥貸/報表/上傳留待 T24·R2·檔案 API 就緒（各自 track）。
