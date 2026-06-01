# AGENTS.md — 全端 → 前後端分離 重構規範

> 給 **Codex CLI / GitHub Copilot** 的專案規範，實作前**必讀並遵守**。
> 本檔涵蓋前端與後端；若前後端為**獨立 repo**，請把對應段落分別放到各自 repo 根目錄。
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
- **Phase 0 門檻**：前後端骨架在**斷網**下可 build（後端 `mvn -o package`；前端 `yarn install --frozen-lockfile` + `ng build`）才往下走。

## 3. 後端規範（Java 17 + Spring Boot 3）
- **`javax.* → jakarta.*`** 全面遷移（servlet / persistence / validation）。可用 OpenRewrite recipe，recipe 亦須走內網 Nexus。
- 分層：**Controller(REST) / Service / Repository**；DTO 與 Entity 分離。
- 資料存取：**Spring Data JPA**。
- 認證由舊 JSP 的 server-session 改為 token/stateless 或 cookie+CSRF（TODO：定案）。
- `TODO（待 B2）`：Entity annotation 與主鍵策略、Repository 風格（JpaRepository / 自訂 / @Query / Specification）、`@Transactional` 放置層級、Entity↔DTO 轉換（MapStruct？手寫？）、datasource 設定慣例。
- `TODO（待 B3）`：全域例外處理(@RestControllerAdvice)與 API 錯誤格式、Bean Validation、認證/授權(Spring Security/JWT?)、CORS、OpenAPI/Swagger。
- `TODO`：Spring Boot 確切版本（環境 Maven 3.9.16）。

## 4. 前端規範（Angular 14 / Yarn / @internal）

### 4.1 架構分層
根 `app-routing.module.ts` → `main-layout` shell（所有功能頁外框）→ feature module（**lazy load**）→ 清單 component + `popup-add-<feature>` 表單彈窗。

### 4.2 設定驅動 (config-driven) — 核心慣例
查詢條件、表單欄位、驗證規則以 `*-config.ts` **宣告**，交由站台共用元件渲染。**不要每頁手刻查詢/表單 HTML。**

| Config | 搭配共用元件 | 用途 |
|---|---|---|
| `search-item-config.ts` | `app-table-search` / `app-search-item` | 清單頁查詢列 |
| `field-item-config.ts` / `form-config.ts` | `app-field-item` | 表單/詳情欄位 |
| `add-<feature>-config.ts` | popup 表單 | 新增表單專屬設定 |
| `validate-rule.ts` | — | 驗證規則 |
| `role-id-config.ts` | — | 權限/角色 |

共用元件（app-local）：`app-table-search`、`app-search-item`、`app-field-item`、`app-side-bar-list`、`app-user-menu`、`app-lang-menu`。**複用，勿重造。**

### 4.3 新功能結構（照參考 feature `deputy` 複製改名）
```
src/app/<feature>/
├── <feature>.module.ts
├── <feature>-routing.module.ts
├── <feature>.component.{ts,html,scss}     # 清單頁（查詢 + 表格）
├── api.service.ts                         # 後端 API：list/get/create/update/delete
├── <feature>.ts                           # model / DTO 型別
├── popup-add-<feature>/                    # 新增/編輯 表單彈窗
│   ├── popup-add-<feature>.module.ts
│   └── popup-add-<feature>.component.{ts,html,scss}
└── config/
    ├── search-item-config.ts
    ├── field-item-config.ts
    ├── form-config.ts
    ├── add-<feature>-config.ts
    ├── validate-rule.ts
    └── role-id-config.ts
```

### 4.4 UI 元件庫（cub-lib-view-ng14plus + Angular Material，混用）
- 企業自製元件庫：**`cub-lib-view-ng14plus`**（`cub-*` 元件/指令）+ **`cub-lib-view-iconfont`**（icon font），未加 scope，從 Nexus npm-all 取得。
- **與 Angular Material 14.2.5 混用**：低階控件（按鈕/分頁/checkbox/dialog 等）用 `mat-*`；企業控件用 `cub-*`。
- **匯入慣例**：大部分 `Cub*Module` 與 `Mat*Module` 集中在 **`SharedModule`** 匯入並 re-export；feature module 匯入 `SharedModule` 取得（少數如 `CubBreadcrumbModule` 在 layout module 直接匯入）。**新增元件時於 `SharedModule` 補匯入/匯出**，勿在各 feature 散落直接 import。
- **app-local 共用元件（`app-*`）包裝 `cub-*`/Material + config-driven**（如 `app-table-search` 內部用 `cub-table`）。使用優先序：**`app-*` → `cub-*` → `mat-*`**。
- theming：於 `angular.json` 的 `styles` 配置（Material `indigo-pink.css` + 企業 `cathay-bank.scss` + `cub-lib-view-iconfont.min.css`）；`styles.scss` 僅少量覆寫，**勿用 `@import` 重新引入主題**。
- 元件 selector / directive 清單與「JSP 控件→元件」對照見 `docs/golden-template/README.md`。

## 5. JSP → Angular 對應
| JSP | 做法 |
|---|---|
| 查詢表單 | `search-item-config` 條目 + `app-table-search` |
| 結果表格（`c:forEach`） | 清單 component 的 table（資料來自 `api.service`） |
| 新增/編輯表單 | `popup-add-<feature>` + `field-item-config`/`form-config` |
| `c:if`/`c:choose` | `*ngIf`/`ngSwitch` |
| `${expr}` (EL) | 插值 / property binding |
| 後端驗證訊息 | `validate-rule.ts` + API error 對應 |
| include/layout(header/側欄) | `main-layout` shell + `app-side-bar-list`/`app-user-menu`/`app-lang-menu` |
| session 屬性 | layout/feature service 狀態 + token |

## 6. 每頁遷移 Checklist（JSP → Angular feature）
1. shell/根路由加一條 lazy route 指向 `<feature>.module`
2. 建 `<feature>.module.ts` + `<feature>-routing.module.ts`
3. 清單頁：`app-table-search` + `search-item-config` 查詢、表格呈現
4. `api.service.ts`：對應後端 REST
5. model `<feature>.ts`：對齊後端 DTO
6. 表單彈窗 `popup-add-<feature>.*`：`app-field-item` + `field-item-config`/`form-config`，`validate-rule.ts` 驗證
7. 權限 `role-id-config.ts`；語系搭配 `app-lang-menu`

## 7. 工作流程約定
- 每個遷移任務 = 「複製 `deputy` 結構 + 寫 config + 接 `api.service`」對應一個 JSP 頁。
- 任一改動後，確保**離線可 build**（見 §2 Phase 0 指令）。
- 遇 `TODO` 標記的未定項：**先向人確認，不要臆造慣例或外部來源。**
