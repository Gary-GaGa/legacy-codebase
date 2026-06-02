# 重構決策與事實紀錄（Decisions Log）

> 本檔記錄已確認事實與待確認項目，作為產出 `AGENTS.md` /
> `.github/copilot-instructions.md` 與各樣板的依據。每輪討論更新。

最後更新：2026-06-01

## 一、已確認事實

| 項目 | 內容 |
|---|---|
| 開發環境 | Windows + VSCode + Codex CLI + GitHub Copilot（**不使用 Claude 產品**；本 repo 僅作規劃與樣板） |
| 重構方向 | 全端（Java 8 + JSP）→ 前後端分離 |
| repo 結構 | **monorepo**：`backend/` + `frontend/`；指令檔分資料夾自動套用 |
| 後端目標 | Java 17 + **Spring Boot 3.3.0**（parent 帶入，無額外 BOM） |
| 前端目標 | Angular 14.x |
| 後端 DB 存取 | **Spring Data JPA**（`JpaRepository` + 大量 `@Query(nativeQuery=true)`）；DB = **Oracle**；設定用 `.properties`/profile |
| 後端 API/認證 | 統一 `EPROResponse<code,message,data>`；全域 `@ControllerAdvice`；**Spring Security + JWT (STATELESS)** + DB 權限表 + 外接 MIS；CORS 既有全開（待收斂）；OpenAPI 未落地（建議導入 springdoc） |
| 前端套件管理器 | **Yarn Classic（`.yarnrc` 為設定入口；非 npm/`.npmrc`）** |
| 前端企業 scope | `.yarnrc` 設有 `@internal`→npm-all，但**本專案未使用該 scope**；實際企業套件為未加 scope 的 `cub-*`（見下） |
| 前端版本 | Angular **14.2.x**（core/common/forms/router 等 ^14.2.0；cli ~14.2.13）、TypeScript ~4.7.2、RxJS ~7.5.0、zone.js ~0.11.4 |
| 前端執行環境 | `engines.node` = **16.20.2**；無 `engines.yarn/npm`、無 `packageManager` 欄位 |
| 前端架構慣例 | 根 `app-routing` → `main-layout` shell → feature module(lazy) → 清單 component + `popup-add-<feature>` 表單彈窗；參考 feature = `deputy`（見 `docs/golden-template/`） |
| 前端設計模式 | **設定驅動 (config-driven)**：查詢/欄位/驗證以 `*-config.ts`（search-item / field-item / form / validate-rule…）宣告，由共用元件渲染 |
| 前端共用元件 | `app-table-search`、`app-search-item`、`app-field-item`、`app-side-bar-list`、`app-user-menu`、`app-lang-menu`（app-local 可重用元件） |
| 程式碼可見性 | **既有專案 source 不可外流**；本 repo 僅存「規格/樣板/慣例」，正式開發時於實際 repo 內複製 `deputy` feature 套用 |
| 前端 UI 元件 | 企業庫 **`cub-lib-view-ng14plus`**（`cub-*`）+ **`cub-lib-view-iconfont`**（未加 scope，npm-all）；**與 Angular Material 14.2.5 混用**；集中於 `SharedModule` 匯入；`app-*` 共用元件包裝 `cub-*`/Material；theming 於 angular.json（indigo-pink + cathay-bank.scss + iconfont） |
| 前端設計規範 | **Adobe XD** 標註每頁細節/通用版型；與 `cub-lib-view-ng14plus`+`cathay-bank` 主題**同一套設計系統**；定位為每頁視覺真實來源（用既有元件+主題變數，不重刻、不 override 樣式） |
| Maven registry | `http://88.8.70.216:8081/repository/maven-public/`（Nexus **group**，標準預設會代理 Maven Central + 託管 releases/snapshots） |
| 後端 build 現況 | **A1 驗證：目前未走 Nexus，落到 Maven Central**；pom 無 `<repositories>`、無 user `~/.m2/settings.xml`、全域 settings 僅含 default http-blocker；Maven 3.9.16 |
| npm registry (group) | `http://88.8.70.216:8081/repository/npm-all/`（Nexus **group**，已代理公開 npmjs + 託管 @internal；依 yarn.lock 多數套件 resolved 指向此） |
| 套件來源限制 | **一律走內網 Nexus，禁止連公開 registry** |
| 既有資產 | 已有「重構後的前後端」可參考；後端架構大致定案、前端需萃取樣板 |

## 二、待確認項目（用 Copilot 在實際專案查證後回填）

### 環境 / 版本
- [ ] 後端 Spring Boot 確切版本（BOM/parent 版本）— prompt A1
- [ ] 後端 Java 版本設定方式（java.version / compiler.release）— prompt A1
- [x] 前端版本與 `engines.node`（A2 已驗證）：Angular 14.2.x / TS 4.7.2 / RxJS 7.5 / zone.js 0.11.4 / **Node 16.20.2**
- [x] 前端企業自製元件庫 **scope = `@internal`** — A2 已確認（套件名稱仍待 C2）
- [x] 前端設定入口 = `.yarnrc`（Yarn Classic，非 `.npmrc`）
- [x] 後端 Maven 來源（A1 已驗證）：目前**未走 Nexus、落到 Maven Central**（詳見上表「後端 build 現況」）

### 後端 JPA 慣例
- [x] Entity（B2）：`jakarta.persistence`；`@Entity/@Table/@Column/@EmbeddedId/@Embeddable/@IdClass`；主鍵**多複合鍵**，少數 SEQUENCE
- [x] Repository（B2）：`JpaRepository` 為主 + 大量 `@Query(nativeQuery=true)` + `@Modifying`；少數 custom impl 用 EntityManager；**未用 Specification**
- [x] @Transactional（B2）：主要 service 層；修改型 repository 也標；既有**混用 jakarta/spring 兩種** → 新碼統一 Spring 版
- [x] Entity↔DTO（B2）：混用 MapStruct / DTOMapper(反射) / ObjectMapper.convertValue / 手寫 → 新碼**優先 MapStruct**
- [x] DB/設定（B2）：**Oracle**；`.properties`（非 yml），profile local/ut/uat/prod；uat/prod datasource 外部注入
- [x] 全域例外處理（B3）：`@ControllerAdvice`(`CommonErrorHandler`)；統一格式 `EPROResponse<code,message,data>`（成功/錯誤同）
- [x] 認證/授權（B3）：**Spring Security + JWT，STATELESS**；filter `JwtTokenAuthenticationFilter`→`APIAuthorizationFilter`(roleId+apiPath 查 DB)；外部 MIS session 驗證；前端附 `Authorization: Bearer`
- [x] 驗證（B3）：`@Valid` on `@RequestBody` + 自訂驗證(@ValidDate/@CustomDigits)；訊息強制英文(LocaleValidatorConfig)
- [x] CORS（B3）：在 `SecurityConfig`，既有**全開**(`*`)+allowCredentials → ⚠️ 正式環境收斂
- [x] OpenAPI（B3）：README 要求但**未落地** → 建議導入 springdoc-openapi

### 前端樣板
- [ ] 專案結構（core/shared/feature、lazy load）— prompt C1
- [x] 企業元件庫（C2 已完成）：`cub-lib-view-ng14plus`+iconfont、與 Material **混用**、經 `SharedModule` 匯入；selector/directive/對照表詳見 `docs/golden-template/README.md` §三之二、§三之三
- [ ] Reactive Forms + 企業表單元件的驗證/錯誤訊息寫法 — prompt C3
- [ ] API service / HttpClient / interceptor / environment.ts — prompt C3
- [x] 一個完整 CRUD 頁面（黃金樣板）— C4 已驗證（僅結構/命名，**不含 source**）：見 `docs/golden-template/README.md`

### 指令檔（已起草，含 TODO）
- [x] `AGENTS.md`（完整規範）+ `.github/copilot-instructions.md`（精簡版）已起草，自包含可複製到實際 repo
- [x] `AGENTS.md` TODO 已全部填補（B2/B3/C2/版本/認證皆補入）；CORS 收斂與 OpenAPI 導入列為「正式環境/實作建議」
- [x] repo 結構：**monorepo**（`backend/` + `frontend/`）→ 指令檔採階層式：root `AGENTS.md`(共用) + `backend/AGENTS.md` + `frontend/AGENTS.md`；Copilot repo-wide `.github/copilot-instructions.md` + `.github/instructions/{backend,frontend}.instructions.md`（`applyTo` 依資料夾自動套用）。若實際資料夾名非 backend/frontend，改 `applyTo` glob 與連結即可。

### 舊專案 JSP
- [x] JSP 清單、共用版型機制、JSTL/EL/自訂 tag、前端 JS — **D1 完成**，見 `migration-backlog.md`
- [x] 一個代表頁面的端到端鏈路（Servlet→Service/DAO→資料表）— **D2 完成**：選定 `EPROZ0_0700`，build spec 見 `phase1-eproz0_0700-spec.md`
- [ ] 遷移清單每頁加一欄「對應 Adobe XD 畫面/連結」作為視覺依據與驗收基準（D1/D2 時一併）

#### 舊系統(EPRO) 架構事實（D1）
- 自製框架 **`HttpDispatcher` + `@CallMethod`**（非 Spring MVC）；版型靠 `<%@ include %>`（無 Tiles/tag files）。
- taglib：JSTL + 自訂 `CXL`/`cathaybk`（TLD 在 jar，不在 repo）。前端 jQuery + 自家 JS 元件。
- 認證 **MIS/SSO**（`SSOFilter`/`SSOUtils`）✅ 與新後端 JWT+MIS 一致；報表 **JasperReports 3.5.2**；檔案走 commons-fileupload 內部服務。
- ≈250 JSP，但結構為 9 模組 × 兩平行流程（申請/覆核），`is↔iu`、`cs↔cu` 平行 → **重用度高，遷移單位是模組流程**。
- 主流程 shell 為**兩層**（D3）：外層「流程頁籤」由後端 `pageMap`(`EPRO_Z0Z006.formatIS/IU`)驅動、切頁 server 重查；內層「區塊頁籤」僅主借款人頁 client 切換。主鍵 **`APPLICATION_NO`**；**IS=有擔、IU=無擔**（差 collateral 頁）。目標：一套 shell + 多份 config（見 `module-is-iu-shell.md`、`golden-template` §八）。
- 企金 cs/cu（B3）：**重用外層 shell 機制**（有 `formatCS/CU`），但差異需每模組 descriptor config + 企金內層元件；**內層 tabs 為每頁可選**（企金 `0110` 單頁、多 tab 在 `0250`）；企金特有 **c0 評分/檢核橋接層**（`EPROC0_0110` 掛入 pageMap）→ c0 與主流程綁定。PageDescriptor 加 `group`/`sections?`/`checkStatus?`。
- i0/c0（D6）：**可共用 shell + config**（i0↔c0 平行，各頁 trx/DAO/SQL/表分開）；子頁**多為輸入表單**（非唯讀），唯 FinStatement `0116/0119/0216/0219` 有 printPDF（R2）。c0 評分經 `pageCheckMap`/checkpoint 綁主流程（`getTabsCheckPage`→`isAllTabsCheck`→外層 done）→ **維持綁定**。CBC=外部資料接入 track（**R8**）。共用資產：tab shell + pageCheckMap 回寫 + done 聚合 + print/open 封裝。
- 新 DB schema（Excel HOME，~71 表，表名同舊但**無 `EPRO_` 前綴、無 schema 限定**）：解 **B4**（`TB_APP_NO_SEQ`=APPLICATION_NO 序號）、shell 來源（`TB_PAGE_MENU`=pageMap）、**R7**（`TB_FUNCTION_AUTH`/`TB_API_AUTH`/`TB_ROLE_TASK`/`TB_ROLE_DEFINE` 已建表）；checkpoint 改名 `TB_CHECK_POINTS_IS/IU/CS/CU`。✅ CBC/財報/財務評估/Scorecard 表**全在同一 Excel**（先前 HOME 輸出截斷誤判）；i0/c0 schema 來源確定。Excel ~70+ sheet、一表一 sheet → **一律用「指定表名」Prompt B 抽**（HOME 會截斷）。詳見 `db-schema-catalog.md`。
- B1 基礎建設表（Prompt B）：**`TB_PAGE_MENU`** = shell pageMap 來源，鍵 = `LON_ATTRIBUTE`×`SECURE_ATTRIBUTE`×`PRODUCT_CODE`×`LON_TYPE_CODE` → `PAGE_CODE`（多 product/lontype 兩軸）；**`TB_APP_NO_SEQ`** = 案號序號（日期+類型+貸放類型+MAX_SEQ）；**權限三層**（R7 落地）：`TB_FUNCTION_AUTH`(FUNCTION_ID→ROLE)、`TB_API_AUTH`(API_ID→ROLE+`REF_FUNCTION_ID`，filter 讀此)、`TB_ROLE_TASK`(PAGE_CODE+FUNCTION→ROLE 編輯權)、`TB_ROLE_DEFINE`(角色主檔)。詳見 `db-schema-catalog.md` §4。
- Phase 1 entity 定稿（Prompt B）：✅ A1 關閉。**⚠️ `TB_EMP_PROXY` 新 DB PK = `EMP_ID` 單鍵**（與舊 DAO 複合鍵不一致 → 一人一筆代理、存檔為 upsert）→ 待業務確認。`STR_TIME` NOT NULL；`RETURN_CASE_TO_CA` default 'N'；新 DB 無 `T24_COMPANY`。
- ⚠️ 舊系統 DB 為 **DB2**（`DB2PoolSvc.xml`），與新後端 Oracle 慣例不一致 → R1。
- 權限（A2）：`AuthManager` **source=db**，function→role 在 `TB_FUNCTION_INFO`+`TB_FUNCTION_AUTH`(FUNC_ID/USER_ROLE)；funcId = bean 名**去底線**（`EPROZ0_0700`→`EPROZ00700`）。與新 `APIAuthorizationFilter`(apiPath+roleId) **同型** → 整系統權限為「搬資料 + `FUNC_ID↔apiPath`」（R7），實際 roleId 為 runtime DB 內容。

#### 待確認決策（D1 浮現）
- [x] **R1 已定：DB2 → Oracle 遷移**。目標 Oracle（`OracleDialect`/`OracleDriver`）；DB2 native SQL 逐一改寫為 Oracle 方言。
- [x] **R2 已定：改用新報表服務**（汰換 Jasper，獨立 track）；含報表/列印頁初期暫緩、不納入 Phase 1～初期模組。
- [x] **Phase 1 切片已定：z0 單純查詢/管理頁**（避開 Jasper/多頁籤）→ 下一步 D2 鎖定具體頁。

## 三、待決架構議題

> 共同主軸：既有前後端在開發機上其實都**部分繞過 Nexus**（前端預設 registry=公開 npmjs、後端=Maven Central）。Phase 0 的核心工作即用 `docs/env/` 樣板把建置環境標準化，使一切走內網。

- [ ] **後端 Maven 來源未合規**：既有後端機器無 Nexus settings.xml，實際從 Maven Central 下載，違反「禁止公開 registry」。修正：安裝 `docs/env/maven-settings.xml` 至 `%USERPROFILE%\.m2\settings.xml`（maven-public 為 group，會代理 Central，安裝後即全走內網）。
- [ ] **npm 預設 registry 政策**：既有前端 `.yarnrc` 預設仍指向公開 `https://registry.npmjs.org/`（僅 @internal 走 Nexus），與「禁止公開 registry」衝突。新專案建議預設 registry 直接指向 `npm-all`（已代理公開套件），以符合離線/合規。**待確認採用。**
- [x] 認證模式（已定案，依既有後端）：**Spring Security + JWT，STATELESS**（非 cookie+CSRF）；外部整合 MIS token/session verifier；前端 interceptor 附 Bearer
- [ ] 過渡期 reverse proxy 路由規劃（/legacy、/app、/api）
- [ ] DB schema 是否維持凍結（初期建議凍結）
