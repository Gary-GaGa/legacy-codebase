# Copilot Instructions（repo-wide）

專案：**monorepo**（`backend/` + `frontend/`）；全端（Java 8 + JSP）→ 前後端分離（後端 **Java 17 + Spring Boot 3.x**；前端 **Angular 14.2.x**）。絞殺者模式逐頁遷移。

> 後端/前端的詳細規則放在依資料夾自動套用的指令檔：`.github/instructions/backend.instructions.md`（`backend/**`）、`.github/instructions/frontend.instructions.md`（`frontend/**`）。完整規範見 `/AGENTS.md`、`backend/AGENTS.md`、`frontend/AGENTS.md` 與 `/docs`。

## 必守硬規則（違反即錯，全 repo 適用）
- **套件一律走內網 Nexus，禁止公開 registry。**
  - Maven：`~/.m2/settings.xml` mirror = `http://88.8.70.216:8081/repository/maven-public/`（`mirrorOf=*`）。
  - 前端 **Yarn Classic**：`.yarnrc` `registry` = `http://88.8.70.216:8081/repository/npm-all/`（企業套件 `cub-lib-view-ng14plus` 等未加 scope，由此解析）。
  - 勿新增 `registry.npmjs.org` / `repo.maven.apache.org` 等外部來源。
- **版本鎖定，勿升降**：Java 17 / Spring Boot 3.x；Angular 14.2.x / TS ~4.7.2 / RxJS ~7.5 / zone.js ~0.11.4 / Node 16.20.2 / Yarn Classic。

## 流程
- 每個任務 = 複製 `deputy` 結構 + 寫 config + 接 `api.service`，對應一個 JSP 頁。
- 改動後確保**離線可 build**：後端於 `backend/` 跑 `mvn -o package`；前端於 `frontend/` 跑 `yarn install --frozen-lockfile` + `ng build`。
- 遇未定項先向人確認，勿臆造慣例或外部來源。
