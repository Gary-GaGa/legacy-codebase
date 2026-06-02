---
applyTo: "frontend/**"
---
# 前端（Angular 14 / Yarn / cub-lib-view-ng14plus）

> 與 repo-wide `.github/copilot-instructions.md` 的硬規則一起適用。詳見 `frontend/AGENTS.md` 與 `docs/golden-template/README.md`。

- 架構：`app-routing` → `main-layout` shell → feature module（lazy）→ 清單 component + `popup-add-<feature>` 彈窗。
- **設定驅動 (config-driven)**：用 `*-config.ts`（search-item / field-item / form / validate-rule）宣告，交給共用元件 `app-table-search` / `app-search-item` / `app-field-item` 渲染。**勿手刻查詢/表單 HTML。**
- 新功能**照 `deputy` feature 結構複製改名**。UI 元件庫 = `cub-lib-view-ng14plus`（`cub-*`）+ Angular Material **混用**，集中於 `SharedModule` 匯入；feature 匯入 `SharedModule` 取得。使用優先序 `app-*` → `cub-*` → `mat-*`。
- 視覺依 **Adobe XD**（與 `cub-*`/`cathay-bank` **同一套設計系統**）：一律用既有元件 + 主題變數，**勿寫死色碼或 override 元件樣式**；XD 決定元件/版面/狀態/文案/RWD。每頁要涵蓋 空/載入/錯誤/disabled 等狀態。
- API service 經 HTTP interceptor 附 `Authorization: Bearer <JWT>`（後端為 JWT stateless）。
