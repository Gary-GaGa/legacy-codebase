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

## 3. 每頁標準流程（SOP）
1. **（前端頁且要打 API）先在「後端專案」Codex 問該 endpoint 的 request/response DTO** → 複製。
2. 在對應專案的 Codex 貼該頁任務段（`build-tasks/*`）＋（前端）剛抓的 DTO。
3. **驗**：契約對齊（前端欄位 == 後端 DTO）、`ng build` / `mvn -o package` 過、狀態正常（驗證原則見 `page-mapping.md` §2E）。
4. 回填 `page-mapping.md` 狀態。

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
