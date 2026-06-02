# AGENTS.md — 全端 → 前後端分離 重構規範（共用）

> 給 **Codex CLI / GitHub Copilot** 的專案規範，實作前**必讀並遵守**。
> 重構系統實際為**前後端兩個獨立專案**（原始碼**不外流、不上 GitHub**）。本規劃 repo 以 `backend/`+`frontend/` 對應之，僅放**規範/規格/backlog，不放原始碼**。
> 部署：把 [`frontend/AGENTS.md`](frontend/AGENTS.md) 放到**前端專案**根目錄、[`backend/AGENTS.md`](backend/AGENTS.md) 放到**後端專案**根目錄；各專案 `.github/copilot-instructions.md` 用對應的 `frontend|backend.instructions.md` 內容。本檔（共用規則）兩專案皆適用。
> 標 `TODO` 之處尚待確認——遇到時**先詢問或保守處理，切勿臆造**。

## 0. 專案目標
全端（Java 8 + JSP）→ 前後端分離：**後端 Java 17 + Spring Boot 3.x**、**前端 Angular 14.x**。
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
- 後端：**Java 17、Spring Boot 3.x**。
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
