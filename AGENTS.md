# AGENTS.md — 全端 → 前後端分離 重構規範（共用）

> 給 **Codex CLI** 的專案規範，實作前**必讀並遵守**。（GitHub Copilot 第三軌已於 2026-06-16 移除。）
> 重構系統實際為**前後端兩個獨立專案**（原始碼**不外流、不上 GitHub**）。本規劃 repo 以 `backend/`+`frontend/` 對應之，僅放**規範/規格/backlog，不放原始碼**。
> 部署：把 [`frontend/AGENTS.md`](frontend/AGENTS.md) 放到**前端專案**根目錄、[`backend/AGENTS.md`](backend/AGENTS.md) 放到**後端專案**根目錄。本檔（共用規則）兩專案皆適用。
> 標 `TODO` 之處尚待確認——遇到時**先詢問或保守處理，切勿臆造**。

## 0. 專案目標
全端（Java 8 + JSP）→ 前後端分離：**後端 Java 17 + Spring Boot 3.3.0**、**前端 Angular 14.x**。
採絞殺者模式（Strangler Fig）逐頁遷移，舊 JSP 與新系統並存、可隨時上線/回退。

## 1. 🚫 硬性限制（最高優先，違反即錯）

### 1.1 套件來源：一律走企業內網 Nexus，**禁止任何公開 registry**
- **Maven**：使用 `~/.m2/settings.xml`（Windows：`%USERPROFILE%\.m2\settings.xml`），mirror 指向
  `http://88.8.70.216:8081/repository/maven-public/`，且 `<mirrorOf>*</mirrorOf>`。
- **前端（Yarn Classic）**：`.yarnrc` 預設 `registry` 指向
  `http://88.8.70.216:8081/repository/npm-all/`。企業元件庫為**未加 scope** 的套件
  （`cub-lib-view-ng14plus`、`cub-lib-view-iconfont`），由預設 registry 解析。
  （`.yarnrc` 雖另設 `@internal` scope→同位址，但本專案實際未使用該 scope。）
- **不得**新增或改寫任何指向 `registry.npmjs.org`、`repo.maven.apache.org` 等公開來源的設定。
- 兩個 registry 都是 Nexus group（maven-public 代理 Maven Central、npm-all 代理 npmjs），故公開與私有套件皆走內網。

### 1.2 版本鎖定（不得擅自升降）
- 後端：**Java 17、Spring Boot 3.3.0**（具體版見 `backend/AGENTS.md §1`）。
- 前端：**Angular 14.2.x**、TypeScript `~4.7.2`、RxJS `~7.5`、zone.js `~0.11.4`、**Node 16.20.2**、**Yarn Classic**。

## 2. 整體策略
- **絞殺者模式**：reverse proxy 把已遷移路由導到 Angular + 新 API，其餘留舊 JSP。
- **契約優先**：後端先產出 OpenAPI 當前後端合約。
- **DB schema 初期凍結**：新後端先包住既有資料存取，先不動資料表。
- **垂直切片**：先打通一條「畫面→API→DB」端到端，再規模化。
- **Phase 0 門檻**：前後端骨架在**斷網**下可 build（後端於 `backend/` 跑 `mvn -o package`；前端於 `frontend/` 跑 `yarn install --frozen-lockfile` + `ng build`）才往下走。

## 3. 工作流程約定
- 每個遷移任務 = 「複製 `deputy` 結構 + 寫 config + 接 `api.service`」對應一個 JSP 頁。
- 任一改動後，確保**離線可 build**（見 §2 Phase 0 指令，於對應資料夾執行）。
- 遇 `TODO` 標記的未定項：**先向人確認，不要臆造慣例或外部來源。**

## 子目錄規範（依資料夾）
- 後端：[`backend/AGENTS.md`](backend/AGENTS.md)
- 前端：[`frontend/AGENTS.md`](frontend/AGENTS.md)
- 前端黃金樣板與「JSP 控件→元件」對照：`docs/golden-template/README.md`

## docs 導覽（規格/狀態/任務）
- **索引**：[`docs/README.md`](docs/README.md)（分類導覽，先看）。
- **狀態 SSOT（權威）**：`docs/feature-inventory.md` — 舊→新逐頁對應 + 前後端狀態 + 剩餘事項 + 排程。任何「某頁做了沒/缺什麼」以此為準（其他文件若有出入，以本檔最新校正為主）。
- **任務單**：`docs/build-tasks/`（進行中）；已完成歷史在 `docs/build-tasks/done/`、已消化文件在 `docs/archive/`。
- ⚠️ 進度提醒（2026-06-06 快照；**現況以 `docs/STATUS.md`/`feature-inventory.md` 為準**）：前端**非**全完成——**c0 評分前端（容器+8 子頁）整組缺、Phase F 鏡像 i0 補建中**；撥貸核心（換匯 stub + T24）未通。細節見 `docs/feature-inventory.md`。

## Spec workflow（PRD→SRS，雙軌 Claude/Codex）
AI workflow＝`Bible→PRD→SRS→QA→RD`（見 `docs/assets/ai-workflow.mmd`）；funcId＝追溯 slug。**Codex 側工具**（部署 `docs/env/codex/` 範本到本機/專案 `.codex/`）：
- **Legacy→Bible**：custom prompt `.codex/prompts/legacy-to-bible.md`（範本 `docs/env/codex/prompts/legacy-to-bible.md`）→ `/legacy-to-bible <domain>`。反推業務 Bible（敘事、證據接地）到 `docs/specs/bible/bible-<domain>.md`。
- **PRD→SRS**：custom prompt `.codex/prompts/prd-to-srs.md`（範本 `docs/env/codex/prompts/prd-to-srs.md`）→ 互動介面 `/prd-to-srs <PRD|funcId>`。產 SRS bundle 到 `docs/specs/srs/<funcId>/`（worked example 重產中〔00100/00118 已全清 2026-06-18、待重產〕；00800 v0.9 已封存；規格分層 bible→prd→srs 見 `docs/specs/README.md`）。
- **spec 審查（唯讀）**：subagent `.codex/agents/spec-reviewer.toml`（範本 `docs/env/codex/spec-reviewer.toml`）；定稿（`Status: Approved`）前必跑（＝SRS **N 軸 axis A**，全軸 A–G 見 `docs/process/orchestration-playbook.md §4b`）。
- **進度盤點（zero-based）**：custom prompt `.codex/prompts/refactor-audit.md`（範本 `docs/env/codex/prompts/refactor-audit.md`）→ `/refactor-audit <module|all>`。唯讀重推重構總量、對 `feature-inventory.md` 做 diff（只報不改）；inventory drift 的定期校正回路。
- **權限/安全**：`.codex/config.toml`（sandbox/approval；範本 `docs/env/codex/config-permissions.md`）+ `.codex/hooks.json`（`verify-c0` + `check-srs-bundle` 形式閘門；SRS 機械閘門涵蓋範圍以 `scripts/check-srs-bundle.py` 檔頭為準）。
- **多任務編排（orchestration，Codex 側）**：方法論＝`docs/process/orchestration-playbook.md`（三類任務 A/B/C＋依賴 DAG＋完成定義＋三軸正交驗證；orchestrator **自動到 checkpoint、停交人審**）。三軸 read-only 驗證 agent 範本＝`docs/env/codex/verifier-{contract,scope,regression}.toml`（部署 `.codex/agents/`，建議跨模型降 correlated blindness）。**硬強制＝機械 gate**（hooks 掛 `verify-c0`+`check-srs-bundle`）；「≥3 獨立 agent」靠 playbook 規範＋完工報告列名/結論（hook 驗不了數量）。**天花板＝自動到等審、非上線**（內容權威＝playbook，本條薄殼指標）。
- **來源優先序（SoT precedence）**：SRS 由 PRD+舊系統+db-diff+refactor-spec 多源合成；衝突裁準（refactor 限本層贏·不蓋 DB/Bible-PRD·DB-resolvable fact 不留 Pending·升級觸發→C 類）**內容權威＝`docs/spec-architecture.md §5b`**（決策 `docs/adr/ADR-0002-srs-sot-precedence.md`；本條薄殼指標）。
- **下游 flow（RD Agent Flow，2026-06-24）**：SRS Approved→code＝**RD flow**（`build-tasks/rd-codex-dispatch.md`／`rd-orchestrator-drain.md`、迴圈 `orchestration-playbook §5c/§6c`、軸 `§4c`＋`verifier-enforcement.toml`）→ 進 **DoD 閘門牆**（gate④ 跑 qa-cases、⑤覆蓋率 + 人審）→ owner 蓋 Done。殼↔playbook 迴圈不變式由 `scripts/check-prompt-parity.py` 驗（SRS/RD 兩軌）。**內容權威＝playbook（薄殼指標）**。〔QA Agent Flow（三層測試/報告編排）暫不納入，待 Bible→PRD→SRS→RD→DoD 跑順再決定介入點。〕
- **完整對照表 + 品質門檻 DoD**：見 `CLAUDE.md`（Claude 側等價）。**鏡像＝薄殼指標**（2026-06-11）：Codex prompt/agent 範本只含指標＋差異清單，**內容權威＝Claude 版檔案**（詳 `CLAUDE.md §2`）。
