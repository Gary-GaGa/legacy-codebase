# 重構決策與事實紀錄（Decisions Log）

> 本檔＝**append-only 決策/事實流水帳**（每列自帶日期、不回溯改寫；被推翻的列由後列/ADR supersede 並互相標註——2026-06-11 健檢定位，取代原「最後更新」header，過期 header 本身曾是失步源）。
> 作為產出 `AGENTS.md` 與各樣板的依據；「決策」類另逐則 ADR（`docs/adr/`），本檔保留 log。
> **結案即歸檔（standing，2026-06-18 立）**：一束 saga（如撥貸/T24、c0 audit）**決策全結案**後（owner-decision 清空、剩執行/UAT）→ 把該束**已結案決策列 verbatim 凍結**到 `archive/decisions-YYYYHn-<topic>.md`、主表留一列 🗄 指標（含現行結論＋現狀 SSOT 指向），免本檔無限長吃 context。**凍結＝搬遷非改寫**（append-only 不破，同 `completion-ledger`/`archive/` 慣例）；**活躍/未結案 saga 不動**；新決策仍 append 本檔。首批＝2026-06-18 撥貸（16 列）+ c0 audit（6 列）。

## 一、已確認事實

| 項目 | 內容 |
|---|---|
| 🗄 撥貸 0921/0922 final 收尾已歸檔（2026-06-25 壓縮）| 2026-06-22~23 的 4 列（0922 `T24_COMPANY` new DB reverify／owner follow-legacy signoff／0921+0922 D-axis implementation closeout／0921+0922 SRS **Approved**(owner stamp)）verbatim append 至 [`archive/decisions-2026H1-disbursement.md`](archive/decisions-2026H1-disbursement.md)。**現行結論**：`EPROISU0921`/`EPROISU0922` 兩 spec `Status: Approved`+Implementation Conformant、撥貸頁覆蓋 4/67、`TBD-0922-007`/`TBD-0921-001~005` 全關（owner follow-legacy/逐項裁定）。**現狀 SSOT＝`feature-inventory.md §2F`、`pending-register` 列 14/15（closed）**。|
| 開發環境 | Windows + VSCode + Codex CLI + GitHub Copilot（產品碼開發側）。~~不使用 Claude 產品~~ → **superseded by ADR-0001（2026-06-09）**：Claude Code 用於本 repo 規劃/規格/審查（雙軌）；本 repo 僅作規劃與樣板 |
| 重構方向 | 全端（Java 8 + JSP）→ 前後端分離 |
| repo 結構 | **monorepo**：`backend/` + `frontend/`；指令檔分資料夾自動套用 |
| 執行策略 | 重構系統實際為**前後端兩個獨立專案**（不上 GitHub）、**已完成 ~70%**；目標 = **補完剩 30%**（gap 分析驅動，非從零）。原始碼不外流 → 本 repo 只放規格/backlog/任務單。**載具 = Codex CLI**（兩專案放同一**母資料夾**、在母資料夾啟動 → 同時看前後端、階層式讀 AGENTS.md，**免手動橋接 DTO**；見 `SETUP-codex.md`）。工作單位 = **新系統頁**（多舊頁合併為一新頁）。對應/backlog 見 `page-mapping.md`、任務單見 `build-tasks/` |
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
| 文件語言 | **繁中 + 英文技術術語（維持現狀）**；程式識別字/表名/endpoint/config key 一律英文。Codex 與團隊皆可讀，不全英文化 |
| c0 鏡像策略（2026-06-05 釐清） | **c0 頁一律自足鏡像 i0**（`backend/AGENTS.md` §6.1：禁注入/委派 i0 service、禁 reflection、禁 import `*.individual.*`；需 i0 邏輯則**複製進 c0、接受重複、不抽共用**）。既有 `Csu*`（如 `00114 CsuCollateralAssessment` 注入 `individual.FunctionService`、import individual function DTO）為 **grandfathered 既有主流程慣例 → 不得作為新 c0 頁範本、不得修改**（§6.1）。已完成 c0 頁（狀態見 `page-mapping.md` §2B）皆符合此鐵則，`00115` 之 CS/CU 判斷另經 code review 確認正確。「是否比照既有頁耦合 i0」之風格題**結案＝維持自足**，不回頭改。唯一活著的風險是 §6.6「計分算法不准分叉」，只適用於有真正計分的 `00118`。 |
| 🗄 撥貸 saga 已歸檔（2026-06-18 壓縮）| 撥貸/T24/批次層 **16 列**已結案決策（0920·0921 audit／authorize 核心／Tier-1~3 落地紀律／A-1 換匯 stub+conformance／A-5·KHR 幣別／T24 全欄照舊／AUD-10 批次層／B-group commit `3d6f446`／殘 domain 全裁）凍結至 [`archive/decisions-2026H1-disbursement.md`](archive/decisions-2026H1-disbursement.md)（verbatim、append-only 不改寫）。**現行結論**：owner-decision 全清空＝一律照舊系統 parity（A-5 USD+KHR 收窄＋KHR rounding `DOWN` keep、其餘照舊）；剩 Codex 執行＋T24 UAT。**現狀 SSOT＝`feature-inventory.md §2F`**、待決＝`disbursement/disbursement-domain-escalations.md`。|
| 🗄 c0/評分 audit saga 已歸檔（2026-06-18 壓縮）| c0 評分線 audit **6 列**已結案決策（00118 calc 注入例外＋gate-b→E1/E2 escalation／00117 結案＋盤點兩裁示／00117·00120 business-only 決策 B／CSU0130 鏡像 twin 裁決）凍結至 [`archive/decisions-2026H1-c0-audit.md`](archive/decisions-2026H1-c0-audit.md)（verbatim）。**現行結論**：c0 評分線 00114–00120 結清；E1/E2 escalation 在 `pending-register.md`＋`build-tasks/c0-crediteval-e1-e2-escalation.md`；對舊企金 c0 parity 補比 reopen 見下「c0 老系統 parity 補比」列。**現狀 SSOT＝`feature-inventory.md §2C/2D`**。|
| 開發 pipeline 願景（2026-06-05 起草） | 30% 補完之上的下一步：`Bible → PRD → SRS → QA → RD-Agent` 一條**往上可追溯、往下可驗證**的鏈。核心原則＝**每個交接點都要機器可驗證的契約**（AI 各層會 confabulate；deterministic gate 可信、LLM gate 只輔助——30% 經驗往上推）。**Bible 為敘事特例 → 證據接地**（引用 legacy `file:line`）。RD↔SA/QA 的 DoD＝閘門 1 contract / 2 schema / 3 verify-c0 / 4 QA 測試 / 5 覆蓋率 / 6 build（+7 LLM 輔助）。**OpenAPI source of truth 先 code-first + snapshot、contract-first 為北極星**；QA case 寫成可跑測試、escalation＝`@PENDING` case。詳見 `docs/process/vision-pipeline.md`；worked example＝`docs/specs/srs/EPROZ00800/`（原 golden-template/boundary-bundle，2026-06-09 移）。 |
| Model A：spec 移母資料夾、Codex 擁（owner 2026-06-26）| Bible/PRD/SRS bundle 本體移出本 repo → Codex 在母資料夾擁/產/驗（SRS 機械閘+spec-reviewer 在母資料夾跑）。本 repo 留範本/腳本/方法論/治理/trackers；Stop-hook 改驗 parity。**現狀 SSOT＝`build-tasks/refactor-audit/per-page-reinventory-matrix.md` ledger**。取捨（放棄 Claude 側 SRS 驗證換 Codex hooks）/驗證細節見 git history。|
| gate ⑧ 範圍＝讀型 only；寫入 v3 + FE L3 歸 QA Flow（owner 2026-06-27）| RD Flow 的 gate ⑧ **只含讀型 API↔DB conformance**（v1 langType/RI、v2 c0 讀型；per-page blocking）。**寫入 save/submit（v3）+ FE 瀏覽器層（L3 Playwright）不當 RD-per-page 閘**——案件流程耦合（CASE_PROGRESS 狀態/角色/上游頁/checkpoint 鏈），本質整合/acceptance、單頁難孤立驗 → **歸未來 QA Flow 整合 tier**。**QA Flow 回來時的分層**：單元 acceptance（Testcontainers 隔離）＋ 整合 conformance（**吸收 Phase V harness/真庫**）＋ 流程 UAT；gate ⑧ 讀型＝整合 tier 中「可 per-page 跑進 RD 的快子集」。過渡（QA 未回）：高風險寫入 fixture-case 半自動 + 廣面 UAT。理由：Phase V 真庫 conformance 與隔離 QA 互補（真庫才現形 vs 逐 Rn 窮舉）、不重複。|
| DoD gate ⑧ runtime conformance（owner 2026-06-26）| 立**第四種驗證「runtime conformance」**（跑活 endpoint 對真 DB、oracle＝openapi 契約＋等價唯讀 SQL；**非 QA**）為 DoD gate ⑧、**併入 RD per-page**（有 harness manifest 的頁 rd-done 前 blocking）。自修界線＝只修 assertion-conformance、契約模糊/判斷/安全/infra/auth escalate（不靠放寬契約湊綠）。**首例閉環＝RI-2**（EPROZ00800 query 空案件漏 required `revisedType`→RD 修→harness 綠→owner Done 2026-06-26）。權威＝`orchestration-playbook §4c`；同口徑 10 檔。|
| QA 產生/驗收暫拔除（2026-06-24）| 主線從 `Bible→PRD→SRS→QA→RD→DoD` 收斂為 **`Bible→PRD→SRS→RD→DoD`**：SRS bundle 不再產 `qa-cases.md`（＝spec/openapi/schema 三契約檔，另 `README.md` 人讀 digest 非 gate）、Traceability Matrix 表移除（追溯改靠每 `Rn` 的 `covers-prd:`）、DoD gate④（QA 測試）/⑤（覆蓋率）暫停、`docs/specs/qa-to-test.md` 休眠；code 階段驗證暫由機械閘門＋`spec-reviewer`＋Phase V runtime 自驗承接。**此為 prose 各處「QA 暫拔除」字樣的權威來源**（描述檔不再重複日期）。**恢復**：見本列前 git history。**現狀 SSOT＝各 bundle metadata + `check-srs-bundle.py`（gate⑤ skip）**。|
| 前端 i18n 語系範圍＋語意（Owner 裁示 2026-06-15）| **①語系僅 `zh_TW`+`en_US`**（繁中+英文，其餘移除）**②語系切換只影響元件翻譯（呈現層 i18n）、不影響查詢資料筆數**。背景＝Phase V 本機坐實 TODO 查詢用 `LOAN_TYPE_LANG_TYPE=:langType` 當資料過濾（`zh_TW`→0/`en_US`→92），**舊版 initQuery 無此條件＝regression**（handoff RV-2、`build-tasks/done/00100-todo-empty-recon-findings.md`）。**修向**：langType 退出資料 WHERE；多語系 view 改 LEFT JOIN+fallback（沒該語系退英文）、不可無腦拿掉（會案件重複）；同型頁盤點+修＝`build-tasks/done/langtype-data-filter-sweep.md`。 |
| 🗄 PRD→SRS pipeline 硬化 saga 已歸檔（2026-06-25 壓縮）| 2026-06-16~24 的 33 列（批判輪2/3+gate 加裝〔Ⓢ/Ⓔ/Ⓡ〕+owner 裁定輪〔RP9/AUD-6〕+Copilot 第三軌移除+`docs/legacy/` 去留+00800 spec 層重置/封存+Bible v1.1 ingest+legacy-parity SOP+砍掉重來 vs 逐頁驗證裁定 A+local 對比輸入盤點/改名/重掃+文件矛盾掃查多輪+STATUS 納 PRD→SRS+EPROZ00100/EPROC00118 產出/pilot/全清重跑/重產/Blocker 修正/contract closeout/Approved+drain 模式+orchestrator 度量化）凍至 [`archive/decisions-2026H1-prd-srs-pipeline.md`](archive/decisions-2026H1-prd-srs-pipeline.md)（verbatim、append-only）。**現行結論**：pipeline 已建（gateⓈ/Ⓔ/Ⓡ+N 軸 A–G+orchestrator drain+pilot 卡）、9 包企金 SRS 已 Approved+RD done；**現狀 SSOT＝`feature-inventory.md`/`build-tasks/refactor-audit/per-page-reinventory-matrix.md` ledger**。|
| 🗄 撥貸 SRS re-open saga 已歸檔（2026-06-23 壓縮）| 撥貸 T24/A-4/M6 SRS-層 re-open（06-20→06-22）逐項決策 **17 列**（T24 re-open Option B／0921 A-4·M6 re-open／§5b SoT 梯裁／0922·00800 bundle 驗證／0922 T24 residual·`T24_COMPANY` entity closeout／0921 A-4 逐項裁定 CO_CHECK·mbCheck·law firm `REF-D3`·address·business-section·M6 `REF-D4`·Product mapping·Return cleanup·`collproSize`）凍結至 [`archive/decisions-2026H1-disbursement.md`](archive/decisions-2026H1-disbursement.md)（verbatim、append-only）。**現行結論**：0921/0922 SRS **Approved（2026-06-23）**＝見上方「D-axis implementation closeout」+「SRS Approved」列；**現狀 SSOT＝`feature-inventory.md §2F`、`pending-register` 列 14/15（closed）**。 |

## 二、待確認項目（用 Codex 在實際專案查證後回填）

### 環境 / 版本
- [ ] 後端 Spring Boot 確切版本（BOM/parent 版本）— prompt A1
- [ ] 後端 Java 版本設定方式（java.version / compiler.release）— prompt A1
- [x] 前端版本與 `engines.node`（A2 已驗證）：Angular 14.2.x / TS 4.7.2 / RxJS 7.5 / zone.js 0.11.4 / **Node 16.20.2**
- [x] 前端企業自製元件庫（A2→C2 修正）：實際為**未加 scope 的 `cub-lib-view-ng14plus` / `cub-lib-view-iconfont`**（`.yarnrc` 雖設 `@internal` 但本專案未使用該 scope）
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
- [x] `AGENTS.md`（完整規範，階層式 root/backend/frontend）已起草，自包含可複製到實際 repo〔原並列的 .github/copilot-instructions.md 精簡版已隨 GitHub Copilot 第三軌移除（2026-06-16，見 §一 Copilot 移除列）→ 回歸 Claude↔Codex 雙軌〕
- [x] `AGENTS.md` TODO 已全部填補（B2/B3/C2/版本/認證皆補入）；CORS 收斂與 OpenAPI 導入列為「正式環境/實作建議」
- [x] repo 結構：**monorepo**（`backend/` + `frontend/`）→ 指令檔採階層式：root `AGENTS.md`(共用) + `backend/AGENTS.md` + `frontend/AGENTS.md`（Codex 依資料夾階層式自動套用；Claude 側＝`CLAUDE.md`）。〔Copilot repo-wide .github/copilot-instructions.md + .github/instructions/* 已隨第三軌移除，2026-06-16，見 §一 Copilot 移除列〕

### 舊專案 JSP
- [x] JSP 清單、共用版型機制、JSTL/EL/自訂 tag、前端 JS — **D1 完成**，見 `migration-backlog.md`
- [x] 一個代表頁面的端到端鏈路（Servlet→Service/DAO→資料表）— **D2 完成**：選定 `EPROZ0_0700`，build spec 見 `archive/phase1-eproz0_0700-spec.md`
- [ ] 遷移清單每頁加一欄「對應 Adobe XD 畫面/連結」作為視覺依據與驗收基準（D1/D2 時一併）

#### 舊系統(EPRO) 架構事實（D1）
- 自製框架 **`HttpDispatcher` + `@CallMethod`**（非 Spring MVC）；版型靠 `<%@ include %>`（無 Tiles/tag files）。
- taglib：JSTL + 自訂 `CXL`/`cathaybk`（TLD 在 jar，不在 repo）。前端 jQuery + 自家 JS 元件。
- 認證 **MIS/SSO**（`SSOFilter`/`SSOUtils`）✅ 與新後端 JWT+MIS 一致；報表 **JasperReports 3.5.2**；檔案走 commons-fileupload 內部服務。
- ≈250 JSP，但結構為 9 模組 × 兩平行流程（申請/覆核），`is↔iu`、`cs↔cu` 平行 → **重用度高，遷移單位是模組流程**。
- 主流程 shell 為**兩層**（D3）：外層「流程頁籤」由後端 `pageMap`(`EPRO_Z0Z006.formatIS/IU`)驅動、切頁 server 重查；內層「區塊頁籤」僅主借款人頁 client 切換。主鍵 **`APPLICATION_NO`**；**IS=有擔、IU=無擔**（差 collateral 頁）。目標：一套 shell + 多份 config（見 `module-is-iu-shell.md`、`golden-template` §八）。
- 企金 cs/cu（B3）：**重用外層 shell 機制**（有 `formatCS/CU`），但差異需每模組 descriptor config + 企金內層元件；**內層 tabs 為每頁可選**（企金 `0110` 單頁、多 tab 在 `0250`）；企金特有 **c0 評分/檢核橋接層**（`EPROC0_0110` 掛入 pageMap）→ c0 與主流程綁定。PageDescriptor 加 `group`/`sections?`/`checkStatus?`。
- i0/c0（D6）：**可共用 shell + config**（i0↔c0 平行，各頁 trx/DAO/SQL/表分開）；子頁**多為輸入表單**（非唯讀），唯 FinStatement `0116/0119/0216/0219` 有 printPDF（R2）。c0 評分經 `pageCheckMap`/checkpoint 綁主流程（`getTabsCheckPage`→`isAllTabsCheck`→外層 done）→ **維持綁定**。CBC=外部資料接入 track（**R8**）。共用資產：tab shell + pageCheckMap 回寫 + done 聚合 + print/open 封裝。
- 新 DB schema（Excel HOME，~71 表，表名同舊、無 schema 限定；~~無 `EPRO_` 前綴~~ **06-12 實查更正：舊庫表名本即 `TB_*`、無前綴可去**——`EPRO_TB_*` 為舊 Java VO **類名**慣例，非表名）：解 **B4**（`TB_APP_NO_SEQ`=APPLICATION_NO 序號）、shell 來源（`TB_PAGE_MENU`=pageMap）、**R7**（`TB_FUNCTION_AUTH`/`TB_API_AUTH`/`TB_ROLE_TASK`/`TB_ROLE_DEFINE` 已建表）；checkpoint 改名 `TB_CHECK_POINTS_IS/IU/CS/CU`。✅ CBC/財報/財務評估/Scorecard 表**全在同一 Excel**（先前 HOME 輸出截斷誤判）；i0/c0 schema 來源確定。Excel ~70+ sheet、一表一 sheet → **一律用「指定表名」Prompt B 抽**（HOME 會截斷）。詳見 `db-schema-catalog.md`。
- B1 基礎建設表（Prompt B）：**`TB_PAGE_MENU`** = shell pageMap 來源，鍵 = `LON_ATTRIBUTE`×`SECURE_ATTRIBUTE`×`PRODUCT_CODE`×`LON_TYPE_CODE` → `PAGE_CODE`（多 product/lontype 兩軸）；**`TB_APP_NO_SEQ`** = 案號序號（日期+類型+貸放類型+MAX_SEQ）；**權限三層**（R7 落地）：`TB_FUNCTION_AUTH`(FUNCTION_ID→ROLE)、`TB_API_AUTH`(API_ID→ROLE+`REF_FUNCTION_ID`，filter 讀此)、`TB_ROLE_TASK`(PAGE_CODE+FUNCTION→ROLE 編輯權)、`TB_ROLE_DEFINE`(角色主檔)。詳見 `db-schema-catalog.md` §4。
- 前後端 cross-check 對齊（✅）：30% 缺口 = ① **6 個企金評分頁**（`EPROC00115-00120`）缺後端 controller（鏡像 i0 補）② **撥貸 `EPROISU0920`** 缺後端 ③ **7 個 z0/共用前端頁**（後端已就緒，含 `EPROZ00700`=`DeputyController`）。
  > ⚠️ **2026-06-06 翻案（以 `feature-inventory.md` §2D 為準）**：①的 c0 評分**前端**當時被當「已就緒」，實則 **corporate 評分容器+8 子頁整組缺** → 現 Phase F 鏡像 i0 補建中。即「c0 缺口」不只後端 controller，前端也缺。**後端 API 慣例 = RPC 式 `epl-{verb}-{scope}-{feature}`（非 REST）**；phase1 spec 的 `/api/emp-proxy` 為理想化、實際以 `DeputyController` 為準。詳見 `page-mapping.md` §2。
- Phase 1 entity 定稿（Prompt B）：✅ A1 關閉（註：`EPROZ00700` 後端已存在為 `DeputyController`，本頁實作只缺前端）。**⚠️ `TB_EMP_PROXY` 新 DB PK = `EMP_ID` 單鍵**（與舊 DAO 複合鍵不一致 → 一人一筆代理、存檔為 upsert）→ 待業務確認。`STR_TIME` NOT NULL；`RETURN_CASE_TO_CA` default 'N'；~~新 DB 無 `T24_COMPANY`~~ **→ ⚠️ 已推翻（2026-06-16，DB 通後重驗）：`TB_BRANCH_PROFILE.T24_COMPANY` 實存於兩 schema（`schema-diff-findings.md:246`、escalations B-1）；原推斷係 DB 未通時之誤。其餘三表欄/PK 以 DB DDL（`schema-diff-findings`）為準**。
- ⚠️ 舊系統 DB **歷史配置標示 DB2**（`DB2PoolSvc.xml`）→ 原以跨引擎遷移立論；**2026-06-12 實連更正：現行舊庫實例＝Oracle（新舊皆 Oracle、皆可連、皆唯讀開放 agent）**——R1 重新定性為「舊 schema→新 schema」遷移，方言改寫視舊源 SQL 實況（見 migration-backlog R1）。
- 權限（A2）：`AuthManager` **source=db**，function→role 在 `TB_FUNCTION_INFO`+`TB_FUNCTION_AUTH`(FUNC_ID/USER_ROLE)；funcId = bean 名**去底線**（`EPROZ0_0700`→`EPROZ00700`）。與新 `APIAuthorizationFilter`(apiPath+roleId) **同型** → 整系統權限為「搬資料 + `FUNC_ID↔apiPath`」（R7），實際 roleId 為 runtime DB 內容。

#### 待確認決策（D1 浮現）
- [x] **R1 已定：DB→Oracle**（06-12 更正：舊庫實例亦 Oracle，原依 `DB2PoolSvc.xml` 誤判跨引擎）。實質＝舊 schema→新 schema 對映；舊源殘留 DB2 方言照改、已是 Oracle 方言仍須對 schema 改名/型別調整。
- [x] **R2 已定：改用新報表服務**（汰換 Jasper，獨立 track）；含報表/列印頁初期暫緩、不納入 Phase 1～初期模組。
- [x] **Phase 1 切片已定：z0 單純查詢/管理頁**（避開 Jasper/多頁籤）→ 下一步 D2 鎖定具體頁。

## 三、待決架構議題

> 共同主軸：既有前後端在開發機上其實都**部分繞過 Nexus**（前端預設 registry=公開 npmjs、後端=Maven Central）。Phase 0 的核心工作即用 `docs/env/` 樣板把建置環境標準化，使一切走內網。

- [x] **後端 Maven 來源合規（✅ 2026-06-12 已部署）**：`docs/env/maven-settings.xml` 已安裝至 `%USERPROFILE%\.m2\settings.xml`（maven-public group 代理 Central，全走內網）。
- [x] **npm 預設 registry 政策（✅ 2026-06-12 已採用）**：`docs/env/frontend.yarnrc` 已部署至前端專案 `.yarnrc`（預設 registry＝`npm-all`，公開+企業套件全走內網）。
- [x] 認證模式（已定案，依既有後端）：**Spring Security + JWT，STATELESS**（非 cookie+CSRF）；外部整合 MIS token/session verifier；前端 interceptor 附 Bearer
- [ ] 過渡期 reverse proxy 路由規劃（/legacy、/app、/api）
- [ ] DB schema 是否維持凍結（初期建議凍結）
- [x] **agent DB 存取政策（2026-06-12 已定，DB 連線打通同日；同日補：新舊兩庫皆 Oracle、皆可連）**：AI agent（Codex/Claude）僅配**唯讀帳號（新舊兩庫各一）**；帳密走環境變數、不進 repo（CLAUDE.md §7）；**任何 DML/DDL 一律產 SQL 檔交人審執行**（同 `c0-authz-sql` 卡模式；舊庫無寫入情境、純查證）；Codex 端 DB 指令 approval 設 ask。**MCP 暫不導入**——Phase V 需要 agent 自主驗 DB 驗證點時再評（先 SQL CLI 唯讀即可）。
