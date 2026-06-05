# Codex CLI 開發設定教學（補完 30% 用）

> 目標：設定一次，之後**每頁只貼一小段任務**，慣例由 Codex 自動套用。

## 0. 三個東西的角色（先搞清楚）
| 東西 | 是什麼 | 放哪 / 怎麼用 |
|---|---|---|
| **規劃 repo**（`legacy-codebase`，你下載的這個）| 參考/控制中心：AGENTS 來源、`build-tasks/`、`page-mapping.md`、`db-schema-catalog.md` | **不放進專案**；開發時當文件查 |
| **前端專案** | 實際 Angular code | 在這裡跑 Codex 做前端頁 |
| **後端專案** | 實際 Spring Boot code | 在這裡跑 Codex 做後端 API |

> 在**母資料夾**啟動 Codex → 它**同時看到前後端**；前端要後端的 DTO 它自己讀，**免手動橋接**（見 §1、§3）。

## 1. 資料夾放置（一次性設定）
把兩個專案放進**同一個母資料夾**，依**本 repo 的結構**擺 3 個 `AGENTS.md`。在**母資料夾**啟動 Codex 時，它會「母目錄共用 + 最近子目錄專屬」自動疊加，且同時看得到前後端：

```
<母資料夾>/                  ← 在這裡執行 codex（同時看到前後端）
├── AGENTS.md               ← 複製本 repo 根 AGENTS.md（共用：Nexus/版本/策略/流程）
├── frontend/               ← 你的前端專案（可為獨立 git repo）
│   └── AGENTS.md           ← 複製本 repo frontend/AGENTS.md（前端慣例）
└── backend/                ← 你的後端專案（可為獨立 git repo）
    └── AGENTS.md           ← 複製本 repo backend/AGENTS.md（後端慣例）
```
- **不用 `cat` 合併** —— 3 個檔原樣丟到對應位置即可（Codex 階層式自動疊加）。
- 兩專案**即使各自是獨立 git repo 也沒關係**：本機放同一母資料夾即可；母目錄 `AGENTS.md` 不屬於任一 repo（純本機給 Codex 讀）。
- 子資料夾名若非 `frontend`/`backend`，改成你的實際名即可。

放好後 → 在母資料夾執行 Codex 就自動遵守全部慣例 → **prompt 裡不用再寫它們**。

> （可選）若也用 Copilot：path-scoped `.github/instructions/*.instructions.md` 同理放各子目錄。用 Codex 的話 `AGENTS.md` 就夠。

## 2. 不用每次重打 prompt 的關鍵
重複的「慣例」（config-driven、`app-*→cub-*→mat-*`、空/載入/錯誤狀態、JWT、分層、`EPROResponse`…）**已在 `AGENTS.md` 裡** → Codex 自動吃。**每張任務你只貼「頁面專屬」那一小段**（從 `docs/build-tasks/*.md` 複製）。

例：做 `EPROZ00610`，你只要貼這麼短：
> 實作 Credit Reviewer On Hand Status（EPROZ00610）。鏡像既有 z0 查詢頁；查詢清單打 `epl-case-credit-reviewer-onhandstatus-query-list`；篩選/欄位以該後端 controller DTO 為準。

其餘規範 Codex 從 `AGENTS.md` 自己知道。

### （可選）把共用前綴存成可重用指令
若你的 Codex CLI 版本支援自訂提示（`~/.codex/prompts/*.md`）：把 `build-tasks/B-z0-...md` 的「共用提示」存成一個檔（如 `~/.codex/prompts/fe-page.md`）→ 之後在 Codex 裡打 `/fe-page` 叫出，再補頁面細節。連那段共用提示都免重打。（版本不支援就略過，`AGENTS.md` 已消掉大部分重複。）

### （可選）全域/模型設定
- `~/.codex/AGENTS.md`：跨所有專案的個人偏好。
- `~/.codex/config.toml`：模型、approval 模式等預設。

## 3. 完整操作步驟（SOP，以 `EPROZ00610` 為實例）

> 一句話流程：**設定一次 → 做一頁（選頁→做→build→自驗）→ 出報告給人審 → commit → 回填**。
> 在**母資料夾**啟動 Codex → 同時看到前後端，前端要後端 DTO 它自己讀（**免手動橋接**）。

### Step 0 — 一次性前置（每個專案做一次）
1. **裝 Codex CLI**：`npm install -g @openai/codex`，再 `codex login`（或設環境變數 `OPENAI_API_KEY`，依官方）。
2. **放 AGENTS.md**（§1 的 `cat`）：確認**前端專案根目錄**、**後端專案根目錄**各有一份 `AGENTS.md`。
   - 驗證有讀到：在專案根啟 `codex`，問一句「你現在遵循哪些專案規範？」→ 它應該複述 AGENTS.md 重點。
   - （若各專案還沒有 `.gitignore`）複製 `docs/env/frontend.gitignore`→前端、`docs/env/backend.gitignore`→後端，各改名為 `.gitignore`。
3. **確認基準可 build**（先確定原本是好的，之後才分得出是不是你改壞）：
   - **⚠️ 前端 Node 必須 = 16.20.2**（專案鎖定；Node 18/20+ 會壞 OpenSSL/node-sass）。用 nvm 切：`nvm install 16.20.2` → `nvm use 16.20.2` → `node -v` 確認 v16；**切版後刪 `node_modules` 重裝**（原生模組綁 Node ABI，走 Nexus）。前端專案放 `.nvmrc`（內容 `16.20.2`）可固定。**勿用「升 Node + `--openssl-legacy-provider`」硬撐。**
   - 後端：先裝 Nexus 設定 `copy docs\env\maven-settings.xml %USERPROFILE%\.m2\settings.xml`（否則走 Maven Central、找不到 `ojdbc8`/`cub.util` 內部套件）；build：`mvn clean package "-Dmaven.test.skip=true"`（PowerShell 要把 `-D` 參數**加引號**；baseline 測試與 main 不同步 → **暫跳過測試編譯**；離線檢查再加 `-o`）。
   - 前端：`yarn install --frozen-lockfile` 然後 `yarn ng build`
4. **開工作分支**：`git switch -c feat/eproz00610`。

### Step 1 — 實作一頁（選頁 → 開做 → build → 自驗）
> 在**母資料夾**啟動 Codex（同時看得到前後端），一氣呵成把一頁做到「自己驗過」。

**1a. 選頁**（規劃 repo 文件上看，不動 code）
- 開 `page-mapping.md` §2 挑一列（例 `EPROZ00610`），判斷在 **§2A（前端補）** 或 **§2B（後端補）**；到 `build-tasks/` 找該頁任務段。

**1b. 開做**（在母資料夾啟 `codex`）
- 貼該頁 build-tasks 的 prompt。**前端頁**再加一句叫它自己讀後端契約（免手動抓）：
  > （貼該頁 build-tasks 的 prompt）
  > 先讀後端 `CreditReviewerOnHandStatusController` 的 `epl-case-credit-reviewer-onhandstatus-query-list` 的 DTO，前端送/收欄位與它對齊。
- Codex 讀 `AGENTS.md` + 既有同類頁範本 +（前端）後端 controller → 提出改動；**逐個 diff 看過再核准**（看不懂先追問再批）。

**1c. Build**（⚠️ **自己跑，別讓 Codex 跑長 build**）
- `ng build` ~170s、輸出量大 → **Codex 等不到結束會卡住**。**在你自己的終端機跑**：前端 `yarn ng build`、後端 `mvn clean package "-Dmaven.test.skip=true"`。Codex 只負責改 code。
- 有錯 → **把錯誤訊息整段貼回 Codex** 修，反覆到綠燈。
- 想看畫面：`yarn ng serve`（長駐程序，**絕不要在 Codex 裡跑**，它會永遠等不到結束）。

**1d. 自驗**（Codex 先自查，見 `page-mapping.md` §2E）
- 契約對齊（前端欄位 == 後端 DTO）、狀態（空/載入/錯誤/disabled）、慣例（叫 Codex「檢查有沒有違反 AGENTS.md」）。
- **本機預覽標準**：版面/查詢列/欄位/狀態正確 render 即算前端 OK ——**「有皮沒資料」是正常的**（本機無真 session、API 會 401）。**真實資料**走整合測試：把前端 `environment` 的 API base 指向 dev/uat 後端 + 正常登入（勿把該指向 commit 進正式 profile）。

### Step 2 — 產出審查報告（給人審查）
> commit 前叫 Codex 產一份**完工報告**讓 reviewer 快速覆核（人審通過才進版）。
- 在目標專案 Codex 輸入（**不要動 code**）：
  > 針對這次改動產出「完工報告」(Markdown)：① 頁面/funcId ② 新增/修改檔案清單 ③ 接的 endpoint + **契約對齊**(前端欄位 vs 後端 DTO 是否一致) ④ 涵蓋狀態(空/載入/錯誤/disabled) ⑤ 遵循/違反 AGENTS.md 哪些慣例 ⑥ 與既有頁/舊系統的**差異或 TODO**(待人判斷) ⑦ build 結果 ⑧ 風險/待確認。
- 報告交 reviewer（或貼進 PR 描述）。**人審通過 → Step 3；有問題 → 回 1c 修。**

### Step 3 — commit（人審通過後，在**實際專案**）
1. `git add -A`
2. `git commit -m "feat: EPROZ00610 Credit Reviewer On Hand Status (frontend)"`
3. 依你們內部流程推送 / 開 PR（報告可貼 PR 描述）。

### Step 4 — 回填狀態
- 回**規劃 repo** 的 `page-mapping.md` §2A，把 `EPROZ00610` 標 ✅ 完成，commit。

### 疑難排解
| 症狀 | 原因 / 解法 |
|---|---|
| Codex 自己編欄位 | 沒叫它讀後端 controller → 在任務裡明確加「先讀後端 `XxxController` 的 DTO 再做」 |
| 沒套慣例（沒用 config-driven 等）| `AGENTS.md` 沒在專案根、或你不是在專案根啟動 Codex → 確認位置後重啟 |
| 離線 build 裝不到套件 | 沒走 Nexus → 檢查 `.yarnrc` / `~/.m2/settings.xml`（樣板見 `docs/env/`）|
| 切 Node 後 `yarn`/`ng` 不認得 | 全域工具綁 Node 版本 → 為 16.20.2 重裝 yarn（走 Nexus：`npm i -g yarn --registry=http://88.8.70.216:8081/repository/npm-all/`）；`ng` **不裝全域**，`yarn install` 後用 `yarn ng` / `npx ng`（專案內建 CLI 14.2.13）|
| PowerShell 擋 `yarn.ps1`（執行原則 Restricted、UnauthorizedAccess）| `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`（免 admin）；若公司用 Group Policy 鎖住改不了 → 改用 `yarn.cmd`，或在 **CMD / Git Bash** 跑（不受 PS 執行原則限制）|
| 後端 build 連到 `repo.maven.apache.org`、找不到 `ojdbc8`/`cub.util:db-encrypt` | 沒裝 Nexus settings.xml → 複製 `docs/env/maven-settings.xml`→`%USERPROFILE%\.m2\settings.xml`，`mvn -U clean package`（`-U` 強制清掉「找不到」失敗快取；必要時刪 `~/.m2/repository/com/oracle`、`~/.m2/repository/cub`）|
| 後端 testCompile `cannot find symbol`（FileService/JwtUtil/LoginEmployee…）| **既有測試與 main 不同步、非你造成** → baseline 用 `mvn clean package "-Dmaven.test.skip=true"`（連測試編譯都跳；勿用 `-DskipTests`，那仍會編譯測試）。測試修復另列工作 |
| PowerShell：`Unknown lifecycle phase '.test.skip=true'` | PowerShell 把 `-D` 參數拆掉 → **加引號** `mvn ... "-Dmaven.test.skip=true"`；或用 `--%`，或改在 CMD 跑。之後所有 `-D...` 在 PowerShell 都要加引號 |
| Codex 跑 `yarn ng build` 卡住不結束 | build ~170s + 大量輸出，agent 等不到結束 → **改由你在獨立終端機跑 build，Codex 只改 code**；錯誤再貼回 Codex。**勿讓 Codex 跑 `ng serve`/`--watch`**（長駐、永不結束）。需 Codex 自己 build 時加 `--progress=false` 並確認其指令逾時夠長 |
| `ng serve` 強制 login、想預覽頁面 | **看版面**：問 Codex「auth guard 看哪個 storage key」→ DevTools 在 local/sessionStorage 塞 dummy token → 進頁（API 會 401 但版面 render，看完清掉還原）。**看真實資料**：後端跑起來 + dev 帳號真登入。⚠️ 任何 auth bypass **只限本機、絕不 commit**（改 code 關 guard 尤其危險）|
| Codex 改太多 / 跑偏 | `git restore .` 還原，把任務**拆更小**再給（例如先只做查詢、再做表格）|
| 同型頁要做很多次 | 把共用提示存成 `~/.codex/prompts/`（見 §2），之後叫 `/指令` 只補頁名 |
| Codex 鏡像既有頁時**偷換成 reflection / runtime 委派**原服務（注入原 service、呼叫其 private method）| 違反「自足新 feature」、**build 會綠但 runtime 才爆**、原檔一改就壞 → **不收**。要求**複製鏡像邏輯**（接受程式碼重複）；真的太大才**有意識地**抽共用 service，**絕不用 reflection 繞**。計畫寫「鏡像」時，實作回報要逐項核對沒換成委派（曾在 `00116` 發生）|
| Codex 新增 Java 檔的中文**註解/字串常數變亂碼**（無 BOM 但非有效 UTF-8）| Codex 寫 CJK 偶爾吐壞位元組（曾在 `00116` 一個檔壞 400+ 處字串常數）→ **每頁新檔建立後先驗**：strict-UTF-8 解碼 + BOM 檢查。壞了：因 c0 是 i0 的 1:1 鏡像，**照對應 i0 檔還原中文**再套 c0 差異，存**乾淨 UTF-8 / 無 BOM**。⚠️**字串常數壞掉是 bug**（進 log/UI），要**全掃**、不能只補抽查到的那個。順手查 PowerShell 漏進來的 `` `r`n `` 字面量 |

## 4. 哪些不用做
- `page-mapping.md` 中對應重構頁**空白** 或標 **「已無使用」** → 不開發。
- **多數頁不用翻舊系統**（建置鏡像既有新頁、驗證用新等價物；見 §2D/§2E）。只有無範本的頁（如 `EPROISU0920`）才追舊鏈路。

## 5. 對照速查
- 缺什麼、誰要補：`page-mapping.md` §2A/§2B
- 某頁任務怎麼下：`build-tasks/`
- 要 entity/欄位：`db-schema-catalog.md`（JIT 抽）
- 頁面內部結構（頁籤/區塊）：`module-is-iu-shell.md`/`module-cs-cu-shell.md`/`module-i0-c0-scoring.md`
- 所有定案：`decisions.md`

## 6. 需要加 Skill / Agent 嗎？→ 不用
- 「Skill / Subagent」是 **Claude Code** 的功能，**Codex CLI 沒有對應機制** → 專案裡不需要裝 skill 或定義 agent。
- Codex CLI 的等價物：**`AGENTS.md`（必要，= config）** + `~/.codex/prompts/`（可選，存重複任務為 slash 指令）+ `~/.codex/config.toml`（可選，模型/approval）+ MCP（這次用不到）。

## 7. 自走（goal mode）補完剩餘 30%
> 把「人工 review」寫進 repo，讓自走盡量安全。**`build 綠 ≠ 正確`**（本專案已多次綠但有 bug）。
- **硬規則**：`backend/AGENTS.md` §6（自足鏡像、禁反射/委派/individual、checkpoint、UTF-8 No BOM、`-c0-` 命名、§6.6 煞車）。
- **控制文件**：`docs/runbook-30pct.md`（剩餘 backlog 順序、每頁迴圈、閘門、停止點、並行注意）。
- **硬閘門腳本**：`python scripts/verify-c0.py --git`（每頁做完跑，PASS 才算完成）—— 驗 strict-UTF-8 + No BOM、禁用樣式、`-c0-` 命名。**只攔形式錯；語意正確性仍需對 i0/人審**。
- **頁卡**：`docs/build-tasks/EPROC00118-*`、`EPROISU0920-*`、`EPROCSU0130-*`（含鏡像來源與煞車）。
- **獨立審查 agent**：每頁 `verify-c0` PASS 後，**另起全新 Codex session**（review-only）跑 `docs/review-c0-prompt.md` 對照 i0 逐項審（PASS/FAIL/UNSURE + 引用 i0:line↔c0:line），全 PASS 才 build。用獨立 agent 避免實作者自審偏誤；仍非萬無一失（human + 整合測試留著）。
- **必須有人審的頁**：`00118`（算法不准分叉）、`0920`（無 i0、先盤點+計畫）。其餘可自走但每頁過閘門。
- ⚠️ 上述 `AGENTS.md` / `scripts/` / 頁卡，需**存在於 Codex 實際執行的資料夾**（你本機後端專案）；本 repo 為來源，請同步過去。
- ⚠️ 並行 multi-agent：頁間有耦合（`00119↔00120`、`00116/00117`、scorecard）→ 預設**序列**；要並行只挑真正獨立的（如後端 `00117` 與前端 `CSU0130`）。
- 補完 30%（複製既有 pattern + 寫 config/controller）**只靠 `AGENTS.md` 就夠**。
- 不需要協調 agent 串前後端 → 手動在兩專案各跑 Codex、用 DTO 橋接（§3）。
- 可選小優化：B 批/A 批同型頁多 → 把各批「共用提示」存成 `~/.codex/prompts/`（如 `/fe-z0-page`、`/be-mirror-i0`），叫出來只補頁名。純省打字。
