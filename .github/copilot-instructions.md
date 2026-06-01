# Copilot Instructions

專案：全端（Java 8 + JSP）→ 前後端分離（後端 **Java 17 + Spring Boot 3.x**；前端 **Angular 14.2.x**）。絞殺者模式逐頁遷移。完整規範見 `/AGENTS.md` 與 `/docs`。

## 必守硬規則（違反即錯）
- **套件一律走內網 Nexus，禁止公開 registry。**
  - Maven：`~/.m2/settings.xml` mirror = `http://88.8.70.216:8081/repository/maven-public/`（`mirrorOf=*`）。
  - 前端 **Yarn Classic**：`.yarnrc` `registry` = `http://88.8.70.216:8081/repository/npm-all/`，`@internal` scope 同。
  - 勿新增 `registry.npmjs.org` / `repo.maven.apache.org` 等外部來源。
- **版本鎖定，勿升降**：Java 17 / Spring Boot 3.x；Angular 14.2.x / TS ~4.7.2 / RxJS ~7.5 / zone.js ~0.11.4 / Node 16.20.2 / Yarn Classic。

## 後端（Spring Boot 3.3.0 / Java 17 / Oracle）
- `jakarta.*`（非 javax）。分層 Controller / Service / Repository，**DTO ≠ Entity**。
- JPA：`JpaRepository` + 大量 `@Query(nativeQuery=true)`（修改型加 `@Modifying`）；主鍵多複合鍵（`@EmbeddedId`/`@IdClass`）；**未用 Specification**。
- 交易用 Spring `@Transactional`（service 層）；DTO 轉換新碼**優先 MapStruct**（`componentModel="spring"`）。設定用 `.properties`/profile，**機密外部化勿提交**。
- 例外/驗證/認證/CORS/OpenAPI 見 `/AGENTS.md`（標 TODO 處先問再做，勿臆造）。

## 前端
- 架構：`app-routing` → `main-layout` shell → feature module（lazy）→ 清單 component + `popup-add-<feature>` 彈窗。
- **設定驅動 (config-driven)**：用 `*-config.ts`（search-item / field-item / form / validate-rule）宣告，交給共用元件 `app-table-search` / `app-search-item` / `app-field-item` 渲染。**勿手刻查詢/表單 HTML。**
- 新功能**照 `deputy` feature 結構複製改名**。UI 元件庫 = `cub-lib-view-ng14plus`（`cub-*`）+ Angular Material **混用**，集中於 `SharedModule` 匯入；feature 匯入 `SharedModule` 取得。使用優先序 `app-*` → `cub-*` → `mat-*`。

## 流程
- 每個任務 = 複製 `deputy` 結構 + 寫 config + 接 `api.service`，對應一個 JSP 頁。
- 改動後確保**離線可 build**：後端 `mvn -o package`；前端 `yarn install --frozen-lockfile` + `ng build`。
