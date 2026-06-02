# 遷移清單（Migration Backlog）

> 由 D1 盤點舊 JSP（**EPRO 授信/申貸系統**）彙整。舊系統 ≈ 250 JSP（主系統 200 active + 50 versioned/common）。
> ⚠️ **遷移單位是「模組流程」，不是「單一 JSP」**——多數 JSP 是被 `<%@ include %>` 進容器的頁籤/子頁/`_JS.jsp` partial，不是獨立 entry page。
> 每個實際遷移任務仍照 `golden-template`（複製 feature 結構 + config + `api.service`），但主流程屬**多頁籤複雜表單**，需在 deputy 式 CRUD 之上加「頁籤容器 + 子表單」子樣式（見 R3）。

## 0. 舊系統架構（D1 確認）→ 新架構對應
| 舊（EPRO, Java 8 全端） | 新（目標） |
|---|---|
| 路由：自製 **`HttpDispatcher` + `@CallMethod`**（非 Spring MVC）| Spring Boot REST Controller（action → endpoint） |
| 版型：`<%@ include %>` 串 `header`/`skeleton-*`/`pageMenu` | `main-layout` shell + 共用元件 |
| View：JSP + JSTL + 自訂 taglib（`CXL`/`cathaybk`/`input`）| Angular component + config-driven |
| 前端：jQuery + 自家 JS 元件（CSRUtil/Tabs/TableUI/FileUpload/Validate/ZRUtil…）| Angular + `cub-*`/Material + HttpClient |
| 認證：**MIS/SSO**（`SSOFilter`/`SSOUtils`，MIS token）| Spring Security + JWT(STATELESS)，驗 MIS session ✅ **與新後端一致** |
| DB：**DB2**（`DB2PoolSvc.xml`）| ⚠️ 新後端慣例為 **Oracle** → 見風險 **R1** |
| 報表：**JasperReports 3.5.2**（`RptUtils`、printPDF/printProposal）| 報表策略待定 → 見風險 **R2** |
| 檔案：commons-fileupload，內部 upload/downloadFile | 檔案上傳/下載 API（待設計） |
| 權限/選單：`AuthManager`/`MenuService`（FunctionAuth/MenuTree/UserRole.xml）| `APIAuthorizationFilter`（roleId+apiPath 查 DB）+ 前端 `role-id-config` |

## 1. 模組地圖（遷移單位 = 模組流程）
> 共通樣式：每個業務模組有兩套近乎平行流程——`_0100` 申請、`_0200` 覆核；且 `is↔iu`、`cs↔cu` 兩兩平行。
> **重用度極高 → 建議先抽一套共用「申貸」feature shell，跨 is/iu/cs/cu × 申請/覆核 參數化重用，而非各搬一遍（見 R6）。**

| # | 模組 | 網域 / 用途 | JSP 數 | 主要類型 | 複雜度 | 重用群 |
|---|---|---|---:|---|---|---|
| M1 | `zz` | 登入 / 首頁（SSO 初始化）| 1 | 登入（特殊）| 特殊 | — |
| M2 | `is` | 個人申貸 主流程（_0100 申請 / _0200 覆核）| 39 | 多頁籤主表單 + 文件/列印/報表 | L–XL | A |
| M3 | `iu` | 個人申貸（另一套，與 is 平行）| 20 | 同 is | L–XL | A |
| M4 | `cs` | 企金申貸（_0100/_0200）| 20 | 多頁籤主表單 + CAD 報表 | L–XL | B |
| M5 | `cu` | 企金申貸（與 cs 平行）| 17 | 同 cs | L–XL | B |
| M6 | `i0` | 個人 財報/評分/CBC（容器 + 子報表頁）| 42 | 唯讀報表/評分檢視 + printPDF | L | C |
| M7 | `c0` | 企金 財報/評分/CBC | 38 | 同 i0 | L | C |
| M8 | `z0` | 管理 / 報表 / 工具 | 18 | 查詢/管理 + 報表群 + 上傳 | M（查詢）/ L（報表）| — |
| M9 | common/demo/resource | 共用版型 / 例外頁 / demo | ~50 | 版型 / error / 範例 | — | → main-layout / error pages |

子頁類型分佈（共通）：主容器(頁籤) · 子表單分頁 · `_JS.jsp`（頁面 JS partial → component 邏輯）· 上傳/下載 · 列印(Jasper) · popup。
已知具名報表：`*_0181` CAD Report、`z0_0620` Application Delete、`z0_0630` Deviation Case、`z0_0640` MIS Scorecard/CRCG、`z0_0650` Application Cancel。
已知具名表：CBC `EPRO_TB_CBC_BGL/_INFO`、`_GBGL/_INFO`。

## 2. 跨頁共用（D1 回填）
- **共用版型**：無 Tiles、無 `.tag`/`.tagx`；靠 `<%@ include %>` 串 `header` + `skeleton-header/sidebar/footer` + `pageMenu` → 對應 `main-layout` shell + `app-side-bar-list`/`app-user-menu`/`app-lang-menu`。
- **JSTL/EL / 自訂 tag**：JSTL `c/fn/fmt`；自訂 `CXL:csCommon`（注入 htmlBase/dispatcher）、`cathaybk:Button/configManager/i18nFmt/out`。⚠️ **TLD 本體在相依 jar、不在 repo** → 語意需取 jar/原始碼確認（R5）。
- **前端 JS（jQuery + 自家元件）→ 新對應**：

  | 舊 JS | 作用 | 新對應 |
  |---|---|---|
  | `CSRUtil.AjaxHandler` | AJAX | `HttpClient` + `api.service.ts`（interceptor 附 JWT）|
  | `Tabs.js` | 頁籤 | `mat-tab` / cub 頁籤 |
  | `TableUI.js` | 表格 | `app-table-search` / `cub-table` |
  | `Validate.js` | 驗證 | reactive forms + `validate-rule.ts` |
  | `FileUpload.js` | 上傳 | 檔案上傳元件 + 檔案 API |
  | `ZRUtil` print/download | 列印/下載 | 報表/檔案 API（見 R2）|
  | `SimplePopupWin`/`MsgBox` | 彈窗 | `mat-dialog` / `popup-add-*` |
  | `quill`/`html2canvas` | 富文本/截圖 | 視需求引入（走 Nexus）|

- **外部整合**：MIS/SSO 登入與權限、JasperReports、應用內部檔案上傳/下載、CBC/Scorecard/MIS 報表、**DB2**。

## 3. 風險 / 待確認決策
- **R1（高）DB：舊 DB2 vs 新後端 Oracle**。新重構後端慣例為 Oracle，舊系統為 DB2 → 是否做 DB2→Oracle 遷移？或新後端先連 DB2？**需與團隊確認**（影響 entity / native SQL 全面性，且既有 native SQL 多為 DB2 方言）。
- **R2（高）報表 Jasper**：i0/c0/z0 大量 printPDF/printProposal + Excel 匯出，佔比高。前端不重刻；報表要嘛沿用 Jasper（後端產 PDF、前端只觸發/下載），要嘛改報表服務 → **獨立 track 決策**。
- **R3（中）主流程是多頁籤複雜表單**，非 `deputy` 式 list+popup CRUD。`golden-template` 直接適用於 z0 查詢/管理與簡單清單；**主申貸流程需擴充「頁籤容器 + 子表單 + 跨頁狀態」子樣式**（建議 Phase 1 後補進 golden-template）。
- **R4（中）後端是重寫非搬移**：自製 `HttpDispatcher`/`@CallMethod` action → 逐一對應成 REST endpoint + service/repository；DTO/驗證重新定義。
- **R5（低）自訂 taglib 語意**：`CXL`/`cathaybk` TLD 在 jar，需原始碼/文件確認輸出，才能正確對應元件。
- **R6（重用）**：is↔iu、cs↔cu、_0100↔_0200 高度平行 → 若各自搬會 4–8 倍重工。**務必先抽共用 shell 再展開。**

## 4. Phase 1 垂直切片（建議）
目標：用**一條最單純的「查詢 → API → DB → Auth」**打通整套（不碰多頁籤/報表/上傳），驗證架構與離線環境。
- 建議從 **z0 的管理/查詢頁**（如 `EPROZ0_0500`/`0700` 類單表查詢）或一個**單純清單**著手——避開 Jasper 與多頁籤。
- 待 **D2** 對選定頁追完整鏈路（JSP 欄位 → CallMethod action → service/DAO → DB 表 → 權限）後，落成第一個 Angular feature + 後端 REST。

## 5. 下一步
- [ ] 確認 **R1（DB 目標）**、**R2（報表策略）**
- [ ] 選定 Phase 1 切片頁 → 跑 **D2** 深掘
- [ ] 依模組逐步展開「逐頁明細」（建議順序：`z0` 簡單頁 → `is`/`iu` 共用 shell → `cs`/`cu` 重用 → `i0`/`c0` 報表檢視 → 主流程文件/列印）
