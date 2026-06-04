# 黃金樣板（Golden Template）— 前端 CRUD 功能

> 來源：C4 對既有前端代表性 CRUD 功能（feature = `deputy`）的結構盤點。
> **注意：因 source code 不可外流，本檔只描述「結構 / 命名 / 慣例 / 設計模式」，不含實際程式碼。**
> 正式開發時，在實際重構 repo 內把 `deputy` 當「活樣板」複製改名，並依本檔 checklist 套用。
>
> 標記：✅=C4 已確認（檔名/角色分層）；🔶=本檔建議（實體資料夾佈局/行為推測，待 C2 或實際 source 核對）。

## 一、層次與角色（✅ C4 確認）

| 層次 | 檔案 | 角色 |
|---|---|---|
| 根路由 | `app-routing.module.ts` | 掛載 shell 與各 feature（lazy route） |
| 後台 shell | `main-layout.module.ts` / `main-layout.component.{ts,html,scss}` | 所有功能頁的外框 |
| Header | `header.component.{ts,html,scss}` | shell 直接掛載的頂列 |
| Layout 服務/型別 | `main-layout.service.ts` / `main-layout.ts` | shell 狀態與 model |
| CRUD feature（清單） | `deputy.module.ts` / `deputy-routing.module.ts` / `deputy.component.{ts,html,scss}` | 功能模組 + 清單頁 |
| 詳情/表單彈窗 | `popup-add-deputy.module.ts` / `popup-add-deputy.component.{ts,html,scss}` | 新增/編輯表單（popup） |
| Feature 服務/型別 | `api.service.ts` / `deputy.ts` | 呼叫後端 API + DTO model |
| Feature 設定 | `search-item-config.ts` / `field-item-config.ts` / `form-config.ts` / `add-deputy-config.ts` / `validate-rule.ts` / `role-id-config.ts` | **設定驅動的核心** |

## 二、核心設計模式：設定驅動 (config-driven) 🔶（依檔名與共用元件強烈推測，待核對）

查詢條件、表單欄位、驗證規則皆以 `*-config.ts` **宣告**，交給站台共用元件渲染：

| Config | 搭配的共用元件 | 用途 |
|---|---|---|
| `search-item-config.ts` | `app-table-search` / `app-search-item` | 清單頁查詢列 |
| `field-item-config.ts` / `form-config.ts` | `app-field-item` | 表單/詳情欄位呈現 |
| `add-<feature>-config.ts` | （popup 表單） | 新增表單專屬設定 |
| `validate-rule.ts` | — | 欄位驗證規則 |
| `role-id-config.ts` | — | 權限/角色 |

→ **遷移一個 JSP 頁面 ≈ 寫這幾個 config + 照 deputy 結構接線**，而非每頁手刻 HTML。

## 三、站台共用元件（✅ 確認 selector，app-local）

| selector | 用途 |
|---|---|
| `app-table-search` | 清單頁查詢列（吃 search-item-config） |
| `app-search-item` | 單一查詢欄位 |

> ⚠️ **實際慣例（核實於 `cad-onhand-status`）**：**查詢列 = `app-search-item` + `search-item-config.ts`；結果表格 = `app-table-search`**（內含 `cub-table` + paginator）。本檔他處若把查詢列寫成 `app-table-search`，以此為準。
| `app-field-item` | 表單/詳情欄位（吃 field-item-config） |
| `app-side-bar-list` | 側邊選單 |
| `app-user-menu` | 使用者選單（header） |
| `app-lang-menu` | 語系選單（header） |

> 關於「可移植性」：這些 `app-*` 是平台的**可重用基礎元件**，新功能本來就該複用它們，**不需要 mock/切除**（除非要做獨立發佈的樣板，但那不是本專案目標）。
> 底層 UI 庫見下方 §三之二（C2 已確認）。

## 三之二、元件分層與企業庫（✅ C2 確認）

**元件三層**（使用優先序：`app-*` → `cub-*` → `mat-*`）：
1. **app-local 共用元件 `app-*`**（config-driven，包裝下層）— 如 `app-table-search` 內部用 `cub-table`。
2. **企業庫 `cub-lib-view-ng14plus`**（`cub-*` 元件/指令）+ icon font `cub-lib-view-iconfont`（未加 scope，從 npm-all 取得）。
3. **Angular Material 14.2.5**（`mat-*`，低階控件）。

**匯入慣例**：`Cub*Module` 與 `Mat*Module` 集中於 **`SharedModule`** 匯入並 re-export；feature/AppModule 匯入 `SharedModule`（少數 `CubBreadcrumbModule` 在 layout module 直接匯入）。新增元件 → 改 `SharedModule`。

**企業 `cub-*` 元件 selector（常用 @Input/@Output）**：

| selector | 常用綁定 |
|---|---|
| `cub-table` | `[value]`,`[scrollable]`,`[scrollHeight]`,`[customSort]`,`[(selection)]`,`[dataKey]`,`(sortFunction)` |
| `cub-paginator-page-jumping` | `[first]`,`[rows]`,`[totalRecords]`,`[rowsPerPageOptions]`,`(onPageChange)` |
| `cub-select` | `[multiple]`,`[placeholder]`,`[filter]`,`[options]`,`[formControlName]`,`(selectionChange)`,`(blur)` |
| `cub-datetimepicker` / `cub-datetimepicker-toggle` | `[type]` / `[for]` |
| `cub-card` / `-header` / `-content` | `color`,`appearance`,`[formGroup]` |
| `cub-nested-menu` / `cub-panel` / `cub-panel-menu` | `[multiple]`,`[model]`,`[items]`,`[selectedItem]`,`(onItemClick)`,`(onChange)` |
| `cub-breadcrumb` | 搭配 `cubTemplate="item\|childrenItem"` |
| `cub-mask` | `[supportedDevice]`,`[showCloseButton]`,`[language]` |
| `cub-toast` | （MessageService 驅動） |
| `cub-http-status` | `[error]`,`[mode]` |
| `cub-table-checkbox`/`-radio-button`/`-header-checkbox`/`-sort-icon` | `[value]` / `[field]` |

**常用 `cub*` directive**：`cubTemplate`（header/body/footer/emptymessage）、`cubFrozenColumn`、`cubSortableColumn`、`cubInputNumber`、`cubBadge/Color/Shape`、`cubRippleOnEnter`、`[cubDatetimepicker]`/`[cubDatetimepickerFilter]`。

**核心服務/Token**：`MessageService`(as `CubMessageService`，toast)、`ConfirmDialogComponent`/`dialog.service`、`DEVICE_BREAKPOINT`、`CUB_DATETIME_FORMATS`、`EventLanguage`(i18n)。

**theming**：於 `angular.json` 的 `styles` 配置 — Material `indigo-pink.css` + 企業主題 `cathay-bank.scss` + `cub-lib-view-iconfont.min.css`；`styles.scss` 僅少量覆寫（勿用 `@import` 重新引入主題）。

## 三之三、JSP 控件 → 元件 對應

| JSP 控件 | 建議元件 |
|---|---|
| 整頁查詢 + 結果表格 | `app-table-search`（config-driven，內含 `cub-table` + `cub-paginator-page-jumping`） |
| 下拉選單 `<select>` | `cub-select`（或經 `app-field-item`/`app-search-item`） |
| 日期欄位 | `cub-datetimepicker` + `cub-datetimepicker-toggle` |
| 數字輸入 | `cubInputNumber` directive |
| 文字輸入 / 表單欄位 | `app-field-item`（config）→ 內部 `mat-form-field`/`cub-form-field` |
| 按鈕 | `mat-button` 系列 |
| 卡片 / 區塊 | `cub-card` |
| 麵包屑 / 側選單 | `cub-breadcrumb` / `cub-nested-menu` / `cub-panel-menu` |
| 提示訊息 | `MessageService` → `cub-toast` |
| 確認對話框 | `dialog.service` → `ConfirmDialogComponent`（或 `mat-dialog`） |
| 表格凍結欄 / 排序 | `cubFrozenColumn` / `cubSortableColumn` directive |

## 四、泛化模板（把 `deputy` → `<feature>`）

```
src/app/<feature>/
├── <feature>.module.ts
├── <feature>-routing.module.ts
├── <feature>.component.{ts,html,scss}        # 清單頁（查詢 + 表格）
├── api.service.ts                            # 後端 API（list/get/create/update/delete）
├── <feature>.ts                              # model / DTO 型別
├── popup-add-<feature>/                       # 🔶 建議資料夾
│   ├── popup-add-<feature>.module.ts
│   └── popup-add-<feature>.component.{ts,html,scss}
└── config/                                    # 🔶 建議資料夾（C4 確認檔案存在，分組為建議）
    ├── search-item-config.ts
    ├── field-item-config.ts
    ├── form-config.ts
    ├── add-<feature>-config.ts
    ├── validate-rule.ts
    └── role-id-config.ts
```

## 五、每頁遷移 Checklist（JSP → Angular feature）

1. 在 shell/根路由加一條 lazy route 指向 `<feature>.module`
2. 建 `<feature>.module.ts` + `<feature>-routing.module.ts`
3. 清單頁 `<feature>.component.*`：用 `app-table-search` + `search-item-config` 做查詢，表格呈現結果
4. `api.service.ts`：對應後端 REST（list / by-id / create / update / delete）
5. model `<feature>.ts`：對齊後端 DTO
6. 表單彈窗 `popup-add-<feature>.*`：用 `app-field-item` + `field-item-config`/`form-config` 渲染，`validate-rule.ts` 驗證
7. 權限 `role-id-config.ts`；語系搭配 `app-lang-menu`
8. **對照該頁 Adobe XD 標註**：用既有元件還原版面與**所有狀態**（空/載入中/錯誤/disabled/無權限），一律用主題變數、不寫死色碼，不為了像 XD override 元件樣式（XD 與元件庫為同一套設計系統） 機制

## 六、JSP → 本樣板 對應（加強版，善用 config-driven）

| JSP | 本樣板做法 |
|---|---|
| 查詢表單 | `search-item-config` 條目 + `app-table-search` |
| 結果表格（`c:forEach`） | 清單 component 的 table（資料來自 `api.service`） |
| 新增/編輯表單 | `popup-add-<feature>` + `field-item-config`/`form-config` |
| 後端驗證訊息 | `validate-rule.ts` + API error 對應 |
| include / layout（header/側欄） | `main-layout` shell + `app-side-bar-list`/`app-user-menu`/`app-lang-menu` |
| session 屬性 | layout/feature service 狀態 + token |

## 七、待補（核對後更新本檔）
- [x] C2 已完成：企業庫 = `cub-lib-view-ng14plus`(+iconfont)，與 Material 混用、經 `SharedModule` 匯入；見 §三之二、§三之三。
- 實際 source 拉下後：核對 §二的 config-driven 行為、§四的實體資料夾佈局、各 `app-*` 內部如何包裝 `cub-*`。

## 八、子樣式：Workflow Shell + Section Tabs（複雜多頁籤主流程）

> 適用申貸主流程（is/iu/cs/cu × 申請/覆核）這類「多流程頁 + 頁內區塊 tabs」的頁；**不適用** deputy 式單頁 CRUD（§一~§七）。詳見 `docs/module-is-iu-shell.md`。
> 舊系統為兩層：外層「流程頁籤」（pageMap 驅動、切頁 **server 重查**）+ 內層「區塊頁籤」（僅主借款人頁、client 切換）。對映：

- **外層 = shell component + 子路由**：`<feature>-shell.component` 放流程頁籤 nav + `<router-outlet>`；每個流程頁是 **routed child**，`ngOnInit` 用案號（`APPLICATION_NO`）自取資料（對映「切頁重查」）。**勿做成單一巨型 component。**
- **內層 = `mat-tab-group`（每頁可選）**：只在含區塊 tabs 的頁切換、不重查。⚠️ **勿假設主借款頁必有多 tab**——IS/IU 主借款頁有 Personal/Work/Family，但企金 cs/cu 主借款頁是單頁、多 tab 反而在擔保品頁（見 `module-cs-cu-shell.md`）。
- **可見頁由後端決定**：流程頁清單/順序/權限來自後端 `GET …/{appNo}/pages?type=&mode=`（移植舊 `pageMap`/`formatIS|IU|CS|CU`），**每模組 × mode 一份 descriptor set**，前端 shell 泛型、勿硬寫。
- **參數化（一套 shell 重用）**：個人/企金 × 有擔/無擔 × 申請/覆核，全走 route data + descriptor set；企金另有 **c0 評分/檢核橋接頁**（`group=scoring`，`checkStatus` 追完成度）掛入同一 shell。
- **共用 context service**：只存 `APPLICATION_NO`/`mode`/`type`，**不做大 store**；各頁資料各自取。
- **完成度 / done 機制（共用）**：沿用舊 `pageCheckMap` 概念——各頁回報完成狀態集合，後端聚合算 `isAllTabsCheck` → 更新外層流程節點 `done`；**loan flow 與 i0/c0 scoring shell 共用此機制**（見 `module-i0-c0-scoring.md`）。建議一次抽好：tab shell + pageCheckMap 回寫 + done 聚合 + print/open 封裝。
- popup（補件/退件/條件調整）→ `mat-dialog`；report/upload 頁依 R2 暫緩。

`PageDescriptor` 欄位：`funcId / route / label / pageType(form|view|upload|report) / group(borrower|collateral|conditions|scoring|approval) / mode(edit|review|both) / order / sections?(頁內 tab，可選) / checkStatus?(評分檢核完成度) / visibleRule`。
