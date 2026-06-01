# 重構決策與事實紀錄（Decisions Log）

> 本檔記錄已確認事實與待確認項目，作為產出 `AGENTS.md` /
> `.github/copilot-instructions.md` 與各樣板的依據。每輪討論更新。

最後更新：2026-06-01

## 一、已確認事實

| 項目 | 內容 |
|---|---|
| 開發環境 | Windows + VSCode + Codex CLI + GitHub Copilot（**不使用 Claude 產品**；本 repo 僅作規劃與樣板） |
| 重構方向 | 全端（Java 8 + JSP）→ 前後端分離 |
| 後端目標 | Java 17 + Spring Boot 3.x |
| 前端目標 | Angular 14.x |
| 後端 DB 存取 | **Spring Data JPA** |
| 前端套件管理器 | **Yarn Classic（`.yarnrc` 為設定入口；非 npm/`.npmrc`）** |
| 前端企業 scope | **`@internal`** → `http://88.8.70.216:8081/repository/npm-all/`（A2 已驗證） |
| 前端 UI 元件 | **企業自製 Angular 元件庫**（非 Material/PrimeNG），推測位於 `@internal/*` |
| Maven registry | `http://88.8.70.216:8081/repository/maven-public/`（Nexus；待後端 workspace 驗證） |
| npm registry (group) | `http://88.8.70.216:8081/repository/npm-all/`（Nexus **group**，已代理公開 npmjs + 託管 @internal；依 yarn.lock 多數套件 resolved 指向此） |
| 套件來源限制 | **一律走內網 Nexus，禁止連公開 registry** |
| 既有資產 | 已有「重構後的前後端」可參考；後端架構大致定案、前端需萃取樣板 |

## 二、待確認項目（用 Copilot 在實際專案查證後回填）

### 環境 / 版本
- [ ] 後端 Spring Boot 確切版本（BOM/parent 版本）— prompt A1
- [ ] 後端 Java 版本設定方式（java.version / compiler.release）— prompt A1
- [ ] 前端 `@angular/*` 確切版本、`engines.node` 設定 — prompt A2（registry 已驗證，版本仍待回填）
- [x] 前端企業自製元件庫 **scope = `@internal`** — A2 已確認（套件名稱仍待 C2）
- [x] 前端設定入口 = `.yarnrc`（Yarn Classic，非 `.npmrc`）；後端 `settings.xml` 仍待 A1（後端 workspace）

### 後端 JPA 慣例
- [ ] Entity annotation / 主鍵策略 / 是否 jakarta.persistence — prompt B2
- [ ] Repository 風格（JpaRepository / 自訂 / @Query / Specification）— prompt B2
- [ ] @Transactional 放置層級 — prompt B2
- [ ] Entity↔DTO 轉換（MapStruct / 手寫）— prompt B2
- [ ] 全域例外處理與 API 錯誤格式 — prompt B3
- [ ] 認證/授權機制（Spring Security / JWT / session）— prompt B3
- [ ] CORS、OpenAPI/Swagger — prompt B3

### 前端樣板
- [ ] 專案結構（core/shared/feature、lazy load）— prompt C1
- [ ] 企業元件庫：module import 方式、元件 selector 清單、@Input/@Output、theming — prompt C2
- [ ] Reactive Forms + 企業表單元件的驗證/錯誤訊息寫法 — prompt C3
- [ ] API service / HttpClient / interceptor / environment.ts — prompt C3
- [ ] 一個完整 CRUD 頁面（黃金樣板候選）— prompt C4

### 舊專案 JSP
- [ ] JSP 清單、共用版型機制、JSTL/EL/自訂 tag、前端 JS — prompt D1
- [ ] 一個代表頁面的端到端鏈路（Servlet→Service/DAO→資料表）— prompt D2

## 三、待決架構議題
- [ ] **npm 預設 registry 政策**：既有前端 `.yarnrc` 預設仍指向公開 `https://registry.npmjs.org/`（僅 @internal 走 Nexus），與「禁止公開 registry」衝突。新專案建議預設 registry 直接指向 `npm-all`（已代理公開套件），以符合離線/合規。**待確認採用。**
- [ ] 認證模式：JSP server-session → 新架構採 JWT(stateless) 或 cookie+CSRF？過渡期橋接方式？
- [ ] 過渡期 reverse proxy 路由規劃（/legacy、/app、/api）
- [ ] DB schema 是否維持凍結（初期建議凍結）
