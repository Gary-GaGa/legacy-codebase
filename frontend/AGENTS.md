# AGENTS.md — 前端規範（Angular 14 / Yarn / cub-lib-view-ng14plus）

> 本檔為 `frontend/` 專屬規範，**與 repo 根 [`../AGENTS.md`](../AGENTS.md) 的共用規則一起適用**。
> 黃金樣板與「JSP 控件→元件」對照見 repo 根 `docs/golden-template/README.md`。

## 1. 架構分層
根 `app-routing.module.ts` → `main-layout` shell（所有功能頁外框）→ feature module（**lazy load**）→ 清單 component + `popup-add-<feature>` 表單彈窗。

## 2. 設定驅動 (config-driven) — 核心慣例
查詢條件、表單欄位、驗證規則以 `*-config.ts` **宣告**，交由站台共用元件渲染。**不要每頁手刻查詢/表單 HTML。**

| Config | 搭配共用元件 | 用途 |
|---|---|---|
| `search-item-config.ts` | `app-table-search` / `app-search-item` | 清單頁查詢列 |
| `field-item-config.ts` / `form-config.ts` | `app-field-item` | 表單/詳情欄位 |
| `add-<feature>-config.ts` | popup 表單 | 新增表單專屬設定 |
| `validate-rule.ts` | — | 驗證規則 |
| `role-id-config.ts` | — | 權限/角色 |

共用元件（app-local）：`app-table-search`、`app-search-item`、`app-field-item`、`app-side-bar-list`、`app-user-menu`、`app-lang-menu`。**複用，勿重造。**

## 3. 新功能結構（照參考 feature `deputy` 複製改名）
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

## 4. UI 元件庫（cub-lib-view-ng14plus + Angular Material，混用）
- 企業自製元件庫：**`cub-lib-view-ng14plus`**（`cub-*` 元件/指令）+ **`cub-lib-view-iconfont`**（icon font），未加 scope，從 Nexus npm-all 取得。
- **與 Angular Material 14.2.5 混用**：低階控件（按鈕/分頁/checkbox/dialog 等）用 `mat-*`；企業控件用 `cub-*`。
- **匯入慣例**：大部分 `Cub*Module` 與 `Mat*Module` 集中在 **`SharedModule`** 匯入並 re-export；feature module 匯入 `SharedModule` 取得（少數如 `CubBreadcrumbModule` 在 layout module 直接匯入）。**新增元件時於 `SharedModule` 補匯入/匯出**，勿在各 feature 散落直接 import。
- **app-local 共用元件（`app-*`）包裝 `cub-*`/Material + config-driven**（如 `app-table-search` 內部用 `cub-table`）。使用優先序：**`app-*` → `cub-*` → `mat-*`**。
- theming：於 `angular.json` 的 `styles` 配置（Material `indigo-pink.css` + 企業 `cathay-bank.scss` + `cub-lib-view-iconfont.min.css`）；`styles.scss` 僅少量覆寫，**勿用 `@import` 重新引入主題**。
- 元件 selector / directive 清單與「JSP 控件→元件」對照見 `docs/golden-template/README.md`。

## 5. 設計規範（Adobe XD）
- UI/UX 以 **Adobe XD** 標註每頁細節與通用版型；與既有元件庫(`cub-lib-view-ng14plus`)+`cathay-bank` 主題為**同一套設計系統**（XD 是標註版，色/字/間距一致）。
- **視覺一律用既有元件 + 主題變數**；**禁止寫死色碼/間距魔術數字、禁止為了「像 XD」override 元件內部樣式**（兩者本就一致）。
- XD 規範的是：**用哪個元件、版面排列、各種狀態（空/載入/錯誤/disabled/無權限）、文案、RWD 斷點**（`DEVICE_BREAKPOINT`、`cub-mask [supportedDevice]`）。
- AI 工具讀不到 XD 檔 → 每頁遷移時由人把 XD 摘成「元件 + 版面 + 狀態」寫進 config / 任務 prompt；**AI 不自行還原像素或臆測視覺**。
- 通用 cover / 共用版型 → 對應 `main-layout` shell 與 `app-*`/`cub-*` 共用元件。
- XD 與元件庫若有衝突 → **標記並升級確認**，勿硬改 CSS。

## 6. JSP → Angular 對應
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

## 7. 每頁遷移 Checklist（JSP → Angular feature）
1. shell/根路由加一條 lazy route 指向 `<feature>.module`
2. 建 `<feature>.module.ts` + `<feature>-routing.module.ts`
3. 清單頁：`app-table-search` + `search-item-config` 查詢、表格呈現
4. `api.service.ts`：對應後端 REST（附 `Authorization: Bearer` interceptor）
5. model `<feature>.ts`：對齊後端 DTO
6. 表單彈窗 `popup-add-<feature>.*`：`app-field-item` + `field-item-config`/`form-config`，`validate-rule.ts` 驗證
7. 權限 `role-id-config.ts`；語系搭配 `app-lang-menu`
8. **對照該頁 Adobe XD**：用既有元件還原版面與**所有狀態**（空/載入/錯誤/disabled/無權限），用主題變數、不寫死色碼、不 override 元件樣式
