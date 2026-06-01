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
| `app-field-item` | 表單/詳情欄位（吃 field-item-config） |
| `app-side-bar-list` | 側邊選單 |
| `app-user-menu` | 使用者選單（header） |
| `app-lang-menu` | 語系選單（header） |

> 關於「可移植性」：這些 `app-*` 是平台的**可重用基礎元件**，新功能本來就該複用它們，**不需要 mock/切除**（除非要做獨立發佈的樣板，但那不是本專案目標）。
> 另有底層 `@internal/*` 元件庫（疑似包裝 Angular Material）——其與 `app-*` 的關係待 **C2** 釐清。

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
7. 權限 `role-id-config.ts`；語系搭配 `app-lang-menu` 機制

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
- C2：`@internal` 元件庫清單、與 `app-*` 與 Angular Material 的關係 → 補「用哪個元件取代哪種 JSP 控件」對應表
- 實際 source 拉下後：核對 §二的 config-driven 行為、§四的實體資料夾佈局
