# Codex CLI 開發設定教學（補完 30% 用）

> 目標：設定一次，之後**每頁只貼一小段任務**，慣例由 Codex 自動套用。

## 0. 三個東西的角色（先搞清楚）
| 東西 | 是什麼 | 放哪 / 怎麼用 |
|---|---|---|
| **規劃 repo**（`legacy-codebase`，你下載的這個）| 參考/控制中心：AGENTS 來源、`build-tasks/`、`page-mapping.md`、`db-schema-catalog.md` | **不放進專案**；開發時當文件查 |
| **前端專案** | 實際 Angular code | 在這裡跑 Codex 做前端頁 |
| **後端專案** | 實際 Spring Boot code | 在這裡跑 Codex 做後端 API |

> Codex 一次只看「它所在的那個專案」→ 跨專案 context（前端要後端 DTO）要手動橋接（見 §3）。

## 1. 資料夾放置（一次性設定）
每個專案**根目錄**要有一份**自包含的 `AGENTS.md`**（Codex 會自動讀、自動套）。因為是兩個獨立專案，要把「共用 + 該域」兩份合成一份：

**前端專案：**
```
cat AGENTS.md frontend/AGENTS.md > <你的前端專案路徑>/AGENTS.md
```
**後端專案：**
```
cat AGENTS.md backend/AGENTS.md > <你的後端專案路徑>/AGENTS.md
```
- `AGENTS.md`(repo 根) = 共用硬規則（Nexus/版本/策略/流程）。
- `frontend|backend/AGENTS.md` = 該域慣例（前端 config-driven/元件庫…；後端 分層/JPA/API…）。

放好後 → Codex 在該專案任何地方執行都自動遵守這些 → **prompt 裡不用再寫它們**。

> （可選）若也用 Copilot：把 `.github/instructions/frontend.instructions.md` 內容放進前端專案的 `.github/copilot-instructions.md`，後端同理。用 Codex 的話 `AGENTS.md` 就夠。

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

> 一句話流程：**設定一次 → 選頁 →（前端頁先抓後端 DTO）→ 叫 Codex 做 → 看 diff + build → 驗 → commit → 回填狀態**。
> Codex 一次只看「它啟動所在的那個專案」，所以前後端要分開操作、用 DTO 橋接。

### Step 0 — 一次性前置（每個專案做一次）
1. **裝 Codex CLI**：`npm install -g @openai/codex`，再 `codex login`（或設環境變數 `OPENAI_API_KEY`，依官方）。
2. **放 AGENTS.md**（§1 的 `cat`）：確認**前端專案根目錄**、**後端專案根目錄**各有一份 `AGENTS.md`。
   - 驗證有讀到：在專案根啟 `codex`，問一句「你現在遵循哪些專案規範？」→ 它應該複述 AGENTS.md 重點。
3. **確認基準可 build**（先確定原本是好的，之後才分得出是不是你改壞）：
   - 後端：`mvn -o package`
   - 前端：`yarn install --frozen-lockfile` 然後 `ng build`
4. **開工作分支**：`git switch -c feat/eproz00610`。

### Step 1 — 選頁 → 取契約 → 開做（每頁的核心循環）
> 把「挑哪頁、拿後端契約、叫 Codex 動工」串成一氣。前端頁中間會切去後端抓 DTO（Codex 一次只看一個專案）。

**1a. 選頁**（在規劃 repo 的文件上看，不動 code）
- 開 `page-mapping.md` §2 挑一列。例：`EPROZ00610` Credit Reviewer On Hand Status。
- 判斷在 **§2A（前端補、後端已就緒）** 或 **§2B（後端補、前端已就緒）**。`EPROZ00610` = §2A。
- 到 `build-tasks/` 找該頁任務段（這裡是 `B-z0-reports-status-frontend.md` 的「§1) EPROZ00610」）。

**1b. 取契約**（前端頁才做；純查不改。§2B 後端頁或不需新 API 就跳過）
- `cd <後端專案>` → `codex`
- 輸入：「貼出 `CreditReviewerOnHandStatusController` 的 `epl-case-credit-reviewer-onhandstatus-query-list` 的 request 參數與 response DTO（欄位名+型別），**不要改任何檔案**。」
- **複製**回傳的 DTO，結束（沒動 code）。

**1c. 開做**（到目標專案叫 Codex）
- `cd <目標專案>`（前端頁→前端專案；後端頁→後端專案）→ `codex`
- 貼「任務段 +（前端）1b 的 DTO」：
  > （貼該頁 build-tasks 的 prompt）
  > 後端契約如下，欄位請對齊：（貼 1b 的 DTO）
- Codex 讀 `AGENTS.md` → 找既有同類頁當範本 → 提出檔案改動。
- **逐個 diff 看過再核准**（依版本按 `y` 或選 Approve）；看不懂先別批，追問「這檔為什麼這樣改」。

### Step 2 — Build + 看結果
1. 讓 Codex 跑 `ng build`（或你自己跑）。有錯就**把錯誤訊息整段貼回 Codex** 讓它修，反覆到綠燈。
2. 想看畫面：`ng serve` 開該 route（例 `/credit-reviewer-onhand-status`）確認版面/查詢正常。

### Step 3 — 驗證（正確性，見 `page-mapping.md` §2E）
- **① 契約對齊（最重要）**：前端送出/接收的欄位 == Step 1b 的後端 DTO。
- **② 狀態**：空清單、載入中、查詢失敗 都正確顯示。
- **③ 慣例自查**：可叫 Codex「檢查這次改動有沒有違反 AGENTS.md（config-driven？有沒有寫死色碼？元件優先序？）」。
- ④ 這類查詢頁通常**不用**對舊系統；有疑慮才 sanity check「該有哪些欄位」。

### Step 4 — commit（在**實際專案**，不是規劃 repo）
1. `git add -A`
2. `git commit -m "feat: EPROZ00610 Credit Reviewer On Hand Status (frontend)"`
3. 依你們內部流程推送 / 開 PR。

### Step 5 — 回填狀態
- 回**規劃 repo** 的 `page-mapping.md` §2A，把 `EPROZ00610` 標成 ✅ 完成，commit。

### 疑難排解
| 症狀 | 原因 / 解法 |
|---|---|
| Codex 自己編欄位 | 你沒餵後端 DTO → 回 Step 1b 抓了再餵 |
| 沒套慣例（沒用 config-driven 等）| `AGENTS.md` 沒在專案根、或你不是在專案根啟動 Codex → 確認位置後重啟 |
| 離線 build 裝不到套件 | 沒走 Nexus → 檢查 `.yarnrc` / `~/.m2/settings.xml`（樣板見 `docs/env/`）|
| Codex 改太多 / 跑偏 | `git restore .` 還原，把任務**拆更小**再給（例如先只做查詢、再做表格）|
| 同型頁要做很多次 | 把共用提示存成 `~/.codex/prompts/`（見 §2），之後叫 `/指令` 只補頁名 |

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
- 補完 30%（複製既有 pattern + 寫 config/controller）**只靠 `AGENTS.md` 就夠**。
- 不需要協調 agent 串前後端 → 手動在兩專案各跑 Codex、用 DTO 橋接（§3）。
- 可選小優化：B 批/A 批同型頁多 → 把各批「共用提示」存成 `~/.codex/prompts/`（如 `/fe-z0-page`、`/be-mirror-i0`），叫出來只補頁名。純省打字。
