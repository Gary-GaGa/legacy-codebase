# 舊→新 功能總盤點（Feature Inventory）— 70% + 30% 全量

> **用途**：把舊 EPRO 系統（~250 JSP / 9 模組）轉新系統（前端 Angular + 後端 Spring Boot）的**每一項功能**、前後端狀態、剩餘事項、橫向 track、建議排程，收斂成一張可排程追蹤的主表。
> **來源**：`page-mapping.md`（舊→新對應）、`completion-ledger.md`（總盤點 SSOT）、`verification-handoff.md`（驗證待辦）、`disbursement-triage.md` + `disbursement-domain-escalations.md`（撥貸）、`migration-backlog.md`（模組地圖/橫向 R1–R8）、`module-{is-iu,cs-cu,i0-c0}-*.md`（頁內結構）。
> ⚠️ 原始碼不外流；本 repo 只放對應/規格。前後端實作在各自專案。

## 0. 怎麼讀
**狀態圖例**
- ✅ **完成**（碼到位；多數仍需一輪整合驗證但非補碼）
- 🟡 **碼到位、待整合驗證**（dev/uat 真資料/真授權跑一次）
- 🔴 **真未完成 / 會錯**（需補碼或 domain 決策）
- ⏸ **暫緩 track**（R2 報表服務 / 檔案 API / CBC R8——刻意延後、非遺漏）
- ❓ **待 cross-check**（推定既有，未實證；開做前先唯讀盤點）

**全局結論（cross-check 後更新 2026-06-06）**：碼大致到位，但確認**兩個真缺口**——① 🔴 **撥貸核心**（換匯 stub + T24 + domain 判斷）② 🔴 **c0 評分前端**（後端齊、但 corporate **整組評分 FE 未建＝容器+8 子頁**，已坐實；**本次翻案發現、先前漏估**）。其餘（主流程 is/iu/cs/cu、i0 全頁、契約頁、多數 z0、c0 後端）＝碼到位、剩整合驗證。

**三層結構**（避免把「模組」當「單頁」）：① 模組流程（M1–M9）② 流程頁（外層 pageMap 頁籤）③ 頁內區塊（內層 tab）。遷移單位＝模組流程。

---

## 1. 模組總表（M1–M9）
| # | 舊模組 | 用途 | 舊 JSP | 新對應 | 狀態 |
|---|---|---|---:|---|---|
| M1 | `zz` | 登入/首頁（SSO）| 1 | `main-layout` + Spring Security/JWT（驗 MIS） | ✅ |
| M2 | `is` | 個人申貸 主流程（有擔）| 39 | `EPROISU*`（IS+IU 合併） | ✅ 前端／🟡 驗證 |
| M3 | `iu` | 個人申貸（無擔）| 20 | 併入 `EPROISU*` | ✅ 前端／🟡 驗證 |
| M4 | `cs` | 企金申貸（有擔）| 20 | `EPROCSU*`（CS+CU 合併） | ✅ 前端／🟡 驗證 |
| M5 | `cu` | 企金申貸（無擔）| 17 | 併入 `EPROCSU*` | ✅ 前端／🟡 驗證 |
| M6 | `i0` | 個人 財報/評分/CBC | 42 | `EPROI00*` | ✅ 推定（70% 重構）／🟡 驗證 |
| M7 | `c0` | 企金 財報/評分/CBC | 38 | `EPROC00*` | ✅ 後端結清／🔴 **評分前端缺口（§2D）** |
| M8 | `z0` | 管理/報表/工具 | 18 | `EPROZ00*` | ✅ 大多／⏸ 報表服務 R2 |
| M9 | common/demo | 版型/例外/demo | ~50 | `main-layout`/error pages | ✅ |

---

## 2. 逐頁清單

### 2A. 個金主流程 `EPROISU*`（M2 is + M3 iu 合併；有擔/無擔 × 申請/覆核）
| 新頁 | 合併舊 funcId | 名稱 | FE | BE | 剩餘 / 備註 |
|---|---|---|:--:|:--:|---|
| EPROISU0110 | IS/IU 0110+0210 | Main Borrower（內層 3 tab：Personal/Work/Family）| ✅ | ✅ | 🟡 驗證 |
| EPROISU0120 | 0120+0220 | Co-Borrower | ✅ | ✅ | 🟡 驗證 |
| EPROISU0130 | 0130+0230 | Guarantor | ✅ | ✅ | 🟡 驗證 |
| EPROISU0140 | IS 0190+0290 | Collateral Provider（僅有擔）| ✅ | ✅ | 🟡 驗證 |
| EPROISU0150 | 0150+0250 | Collateral（僅有擔；含上傳）| ✅ | ✅ | 🟡 驗證；⏸ 檔案 API |
| EPROISU0160 | 0160+0260 | Loan Condition | ✅ | ✅ | 🟡 驗證 |
| EPROISU0170 | 0170+0270 | Credit Eval & Decision（審批 hub；含列印/上傳）| ✅ | ✅ | 🟡 驗證；❓ 審批段欄位細節(B1)；⏸ 檔案/列印 |
| EPROISU0171 | 0171 | Loan Committee Conclusion（上傳）| ✅ | ✅ | 🟡；⏸ 檔案 API |
| EPROISU0172 | 0172 | Approved Loan Condition（檢視/列印）| ✅ | ✅ | 🟡；⏸ 列印 R2 |
| EPROISU0173 | 0173 | Credit Evaluation Old | ✅ | ✅ | 🟡 驗證 |
| EPROISU0181 | 0181 | TLOD/CAD Report（R2 報表）| ⏸ | ⏸ | ⏸ **R2 報表服務未定** |
| EPROISU0910 | IS 0910 | Contract Preparation（頁框）| ✅ | ✅ | cross-check ✅ |
| EPROISU0911 | IS 0911 | Condition Confirmation | ✅ | ✅ | FE+BE 確認 |
| EPROISU0912 | IS 0912 | Contract Production | ✅ | ✅ | 多 save/submit/auth/upload/download endpoint |
| EPROISU0913 | IS 0913 | Closed Info | ✅ | ✅ | cross-check ✅ |
| EPROISU0920 | IS 0920 | **Disbursement Process（頁框）** | ✅ | 🔴 | **見 §2F** |
| EPROISU0921 | IS 0921 | **Disbursement Data Input** | ✅ | 🔴 | **見 §2F** |
| EPROISU0922 | IS 0922 | **Disbursement Summary（authorize/T24）** | ✅ | 🔴 | **見 §2F** |
> 不開發：`EPROIS_0140`(Property Info) 已 drop。popup `0174/0175/0176`→`mat-dialog`（隨審批頁）。

### 2B. 企金主流程 `EPROCSU*`（M4 cs + M5 cu 合併）
| 新頁 | 合併舊 funcId | 名稱 | FE | BE | 剩餘 / 備註 |
|---|---|---|:--:|:--:|---|
| EPROCSU0110 | CS/CU 0110+0210 | Main Borrower（單 tab）| ✅ | ✅ | 🟡 驗證 |
| EPROCSU0120 | 0120+0220 | Co-Borrower | ✅ | ✅ | 🟡 驗證 |
| EPROCSU0130 | 0130+0230 | Guarantor | ✅ | ✅ | **✅ 2026-06-05 收尾（ng build 綠）** |
| EPROCSU0150 | 0150+0250 | Collateral（僅有擔；內層 3 tab：Info/Valuation/Site Visit）| ✅ | ✅ | 🟡 驗證；⏸ 檔案 API |
| EPROCSU0160 | 0160+0260 | Loan Condition | ✅ | ✅ | 🟡 驗證 |
| EPROCSU0170 | 0170+0270 | Credit Eval & Decision | ✅ | ✅ | 🟡；❓ 審批段細節(B1) |
| EPROCSU0171 | 0171 | Loan Committee Conclusion | ✅ | ✅ | 🟡 驗證 |
| EPROCSU0172 | 0172 | Approved Loan Condition | ✅ | ✅ | 🟡；⏸ 列印 |
| EPROCSU0173 | 0173 | Credit Evaluation Old | ✅ | ✅ | 🟡 驗證 |
| ~~CS 0240~~ | CS 0240 | 公司核心資料（舊 cs 0200 端）| — | — | **不開發**：2026-06-06 owner 確認新系統無使用（舊有、未遷移）|
| CAD 報表 | CS/CU 0181 | TLOD(CAD)→ 共用 `EPROISU0181` | ⏸ | ⏸ | ⏸ R2 |
> 不開發：`EPROCS_0240` 公司核心資料（✅ 2026-06-06 確認新系統無使用、舊有未遷移）、`EPROIS_0140` Property Info；待確認 `EPROC0_0211/0213`（流程無對應頁籤）。

### 2C. 個金評分 `EPROI00*`（M6 i0）— ✅ cross-check 確認**全做**（2026-06-06）
> FE 全在 `case-edition/sub-pages/individual/credit-investigation/*`，BE 全在 `controller/individual/*Controller`。00110–00120 十一頁 **FE+BE 皆 ✅**。
| 新頁 | 名稱 | FE | BE | 備註 |
|---|---|:--:|:--:|---|
| EPROI00110 | Credit Investigation（頁框）| ✅ | ✅ | `CreditInvestigationController` |
| EPROI00111 | Financial Evaluation Table | ✅ | ✅ | |
| EPROI00112 | CBC（banking relationship）| ✅ | ✅ | **= 頁內 banking relationship + 幣別計算、無獨立外部 adapter**（R8 釐清）|
| EPROI00113 | Individual Scorecard | ✅ | ✅ | |
| EPROI00114 | Collateral Assessment | ✅ | ✅ | |
| EPROI00115 | Borrower Group Exposure | ✅ | ✅ | |
| EPROI00116 | Financial Statement GI（+印 PDF）| ✅ | ✅ | ⏸ PDF 印 R2 |
| EPROI00117 | Financial Evaluation GI | ✅ | ✅ | staff GI 由 `FinancialStaffController` |
| EPROI00118 | Corporate Scorecard | ✅ | ✅ | |
| EPROI00119 | Financial Statement FI（+印 PDF）| ✅ | ✅ | ⏸ PDF 印 R2 |
| EPROI00120 | Financial Evaluation FI | ✅ | ✅ | staff FI 由 `FinancialStaffController` |
> i0 全做 → c0 的 FE 缺口（§2D）＝「照 i0 鏡像補 c0 評分 FE」。

### 2D. 企金評分 `EPROC00*`（M7 c0）— 🔴 **FE 整組缺口（已坐實，2026-06-06）**
> **確認**：c0 後端齊（`controller/corporate/*`），但 corporate 前端**完全沒有評分容器**（route 只有 4 個 basic 頁）。→ **整組 c0 評分 FE 未建＝1 容器 + 8 子頁**（c0 無 00111/00113）。BE endpoint 已齊、可直接對接。**本次盤點最大缺口。**
| 新頁 | 名稱 | FE | BE | 對接 c0 endpoint（BE 已齊）|
|---|---|:--:|:--:|---|
| EPROC00110 | 評分容器（corporate credit-investigation）| 🔴 | ✅ | `epl-info/save-c0-credit-investigation-tab`（`CsuCreditInvestigationController`）|
| EPROC00112 | CBC Banking Relationship | ✅ | ✅ | `epl-info/save-c0-cbc-banking-relationship`（`7e8aaf7`）|
| EPROC00114 | Collateral Assessment | ✅ | ✅ | `epl-sele/info/save-c0-collateral-assessment`（`62ec62f`；無 c0 calc→隱 Calc 鈕、分數 BE save 算）|
| EPROC00115 | Borrower Group Exposure | 🔴 | ✅ | `epl-sele/info/save-c0-borrower-group-exposure`；授權列 |
| EPROC00116 | Financial Statement GI | ✅ | ✅ | `epl-*-c0-financial-statement-comments`（`524d8dc`；calc 保留、export POST-blob 兩邊一致、無 00640 式不符）；授權列；export 模板沿用 i0？|
| EPROC00117 | Financial Evaluation GI | 🔴 | ✅ | `epl-{info/save}-c0-financial-{staff/business}`、`epl-sele-c0-financial-list` |
| EPROC00118 | Corporate Scorecard | ✅ | ✅ | `epl-{sele(-list)/info/calc/save}-c0-corporateScorecard`（`39e95dd`；**calc 保留接上**）；授權列；🚩 2 escalation |
| EPROC00119 | Financial Statement FI | 🔴 | ✅ | `epl-*-c0-financial-statement-cmts-fi`；授權列；export 沿用 i0？|
| EPROC00120 | Financial Evaluation FI（table-fi + staff-fi）| 🔴 | ✅ | `epl-{info/save}-c0-financial-evaluation-table-fi`、`epl-save-c0-financial-evaluation-staff-fi`；授權列 |
> **範本＝i0 `individual/credit-investigation`**：容器 component 動態載 tab（`epl-*-i0-credit-investigation-tab`、`creditInvestigationNav()` config、`CreditInvestigationPageCode` enum）、各子頁 `components/<name>/{component,services}`。c0 照此鏡像、改 `-c0-` endpoint + corporate DTO。
> ⚠️ **G/F businessType 分頁**：FE 容器須吃 BE 回的 `businessType`+`pageMap`（預設 G→移除 00119/00120、F→移除 00116/00117；save 依 businessType 更 checkpoint，`CsuCreditInvestigationServiceImpl:129/264/279/366`）。i0 容器本就動態（tabControl 來自 BE）→ 鏡像即自然涵蓋。
> **進度（2026-06-06）**：✅ **Step 1**＝c0 容器（BE 驅動動態 tab、`epl-*-c0-credit-investigation-tab`）+ **00115 BGE** pilot，`ng build` 綠（容器 DTO 對齊 c0＝只 `businessType`/`pageMap`、無 i0 的 `assessmentType`/`isStaffLoan`，故容器只留 businessType radio）。🔵 **Step 2 進行中**：✅ `00112` CBC（`7e8aaf7`；無 calc→totals 本地加總）、✅ `00114` Collateral Assessment（`62ec62f`；無 calc→隱鈕、分數 BE save 算）、✅ `00118` Corp Scorecard（`39e95dd`；calc 保留、回填 riskLevel/scoreDatetime）、✅ `00116` FinStmt GI（`524d8dc`；calc 保留、export POST-blob 兩邊一致、動到共用 `report.service.ts` 待確認加法）；其餘 3（00119 有 calc+export、00117/00120 staff）待。⚠️ **watch**：① 🔑 **calc 逐頁不同**——00112/00114 無 calc（已隱），但 **00118 Corp Scorecard 有 `epl-calc-c0-corporateScorecard`、00116/00119 FinStmt 亦有 calc → 這幾頁 calc 鈕要保留接上**，勿誤套「隱 calc」。② c0 staff-vs-business 判定（00117/00120 動手前先查）③ 真元件就緒後實跑 G/F 切換 ④ 整合測確認：00112 totals、00114 rating 是否仍**唯讀顯示**(BE save 算後回傳)、語意與 BE 一致。

### 2E. 共用 `EPROZ00*`（M8 z0）
| 新頁 | 名稱 | FE | BE | 剩餘 / 備註 |
|---|---|:--:|:--:|---|
| EPROZ00100 | TO DO LIST | ✅ | ✅ | cross-check ✅ |
| EPROZ00200 | New Case Application（進件入口）| ✅ | ✅ | ✅；案號序列細節未深入 |
| EPROZ00300 | Document Checklist | 🟡 | 🟡 | ⚠️ **return action 空回、疑未完成**（`DocumentChecklistController:57`）|
| EPROZ00400 | Case Distribution | ✅ | ✅ | cross-check ✅ |
| EPROZ00410 | Related Party Info | ✅ | ✅ | cross-check ✅ |
| EPROZ00500 | Comparison table…CUBC | ✅ | ✅ | cross-check ✅ |
| EPROZ00600 | Search | 🟡 | ✅ | ⚠️ **options FE POST vs BE GET 介面不一致** |
| EPROZ00610 | Credit Reviewer On Hand | ✅ | ✅ | 🟡 呈現/資料驗證 |
| EPROZ00620 | Application Delete Report | ✅ | ✅ | 🟡（繼承 `base-application-report`）|
| EPROZ00630 | Deviation Case Report | ✅ | ✅ | 🟡（含 Excel export）|
| EPROZ00640 | Scorecard Report | ✅ | ✅ | 🟡；⚠️ **export FE POST blob vs BE GET `@RequestBody` 介面不一致→優先對** |
| EPROZ00650 | Application Cancel Report | ✅ | ✅ | 🟡 |
| EPROZ00660 | CAD On Hand Status | ✅ | ✅ | ✅（CR 範本）|
| EPROZ00700 | Assign Substitute | ✅ | ✅ | ✅（= `pages/deputy`）；嚴謹可做 deputy↔0700 gap-check |
| EPROZ00800 | Revised Item | 🟠 | 🔴 | **驗證完(vs PRD)：結構在、行為不對等**——execute GET 應 POST、**execute 無 `@Transactional`(多表刪/還原可半更新＝資料風險)**、Y/N 未驗、pageMenuCondition 未回、RI-MAT 側效部分+多 bug、checkpoint 標錯頁。詳 `build-tasks/00800-verification-findings.md`。⚠️ 側效修正待 PRD TBD-006/SA |
> 共用 API `EPROZZ_0100`（查地址欄位選單）。

### 2F. 撥貸 `EPROISU0920/0921/0922` + T24（🔴 唯一真未完成區塊）
| 區 | 狀態 | 內容 |
|---|---|---|
| 機械修正 M1–M10 | ✅ 全結案（master） | 尾欄/submit mail/RECEIVED_DATE/C20/fee key/E 位/H 段/A52/fee-delete-FN |
| 🔴 **A-1 換匯 stub** | **未做（總開關）** | `funcGetExchangeRate` throw-stub → authorize 全斷、從未端到端跑過 |
| 🔴 B-1 `T24_COMPANY` 值來源 | 未決 | B8/C9 讀已移除欄、無替代 |
| 🔴 其餘 domain | 未決 | 換匯源 ID、檢核嚴格度、KHR、欄寬、async 架構、精度… |
| 整合測確認點 | 待驗 | M7 facility fee 值、M9 district name join |
> **完整待裁清單見 [`disbursement-domain-escalations.md`](disbursement-domain-escalations.md)。** ⚠️ 機械修正全 inert——A-1 未通,撥貸跑不起來。

---

## 3. 橫向基礎建設 track（R1–R8）
| R | 主題 | 狀態 | 影響面 |
|---|---|---|---|
| R1 | DB2 → **Oracle** 遷移 | ✅ 已定/進行（native SQL 逐一改 Oracle 方言）| 全後端；⚠️ map-key 大小寫 sweep（見 §4）|
| R2 | **報表服務（汰換 Jasper）** | ⏸ **未定（獨立 track）** | `*_0181` CAD、i0/c0 FinStmt PDF（0116/0119）、z0 報表呈現 |
| R3 | 主流程 shell 子樣式 | ✅ 已定（Workflow Shell + Section Tabs）| is/iu/cs/cu 共用 |
| R4 | 後端 action→REST 重寫 | ✅ 進行 pattern | 全後端 |
| R5 | 自訂 taglib 語意 | 低 | 元件對應 |
| R6 | shell 重用（避免 4–8x 重工）| ✅ 已定 | 主流程 |
| R7 | **權限三表遷移**（`TB_FUNCTION_AUTH`/`TB_API_AUTH`/`TB_ROLE_TASK`）| 🟡 進行 | **新 c0 endpoint 授權列待建**（見 §4）|
| R8 | CBC 聯徵資料接入 | 🟢 **釐清：非獨立 adapter** | CBC = 頁內 banking relationship（i0 已做；c0 FE 缺）；**無外部 adapter track** |
| — | **檔案上傳/下載 API** | ⏸ **待設計** | collateral 0150、審批 0170/0171/0173 上傳 |
| — | **FE/BE HTTP method 不一致** | 🔴 **系統性** | 已知 `00600`/`00800`/`00640` options/export 的 POST↔GET 不符 → 整批 sweep |

---

## 4. 剩餘事項彙整（= 還有多少事要做）— cross-check 後更新（2026-06-06）
> **翻案**：新增 **c0 評分前端真缺口**（原以為前端全完）。❓ 多已坐實（i0/契約/多數 z0 ✅）。

**① 🔴 c0 評分前端（NEW，本次最大缺口；owner：前端）— 範圍已坐實**
- **整組未建＝1 容器 + 8 子頁**（00112/00114/00115/00116/00117/00118/00119/00120；c0 無 00111/00113）。
- BE endpoint + corporate DTO 已齊；**照 i0 `credit-investigation` 鏡像**（容器動態 tab + 各子頁 component），改 `-c0-` endpoint；FE 容器吃 BE `businessType`/`pageMap`（G/F 分頁）。
- 低風險（範本清楚、BE+DTO 就緒）但量 ≈ **一個 sprint（9 個 FE 單位）**。

**② 整合驗證（owner：dev/uat 整合測試）— 量大、非補碼**
- 主流程（is/iu/cs/cu 0110–0173）+ 契約頁（0910–0913）+ i0 全頁 FE↔BE `epl-*` DTO/授權各跑一次。
- z0 報表 00610/00620–00650 呈現。

**③ 🔴 撥貸 domain（owner：撥貸 domain + T24 + DBA）— 見 escalation doc**
- A-1 換匯 stub（**撥貸總開關、最優先**）、B-1 `T24_COMPANY`、換匯源 ID、檢核嚴格度、KHR、欄寬、async、精度（待舊 DDL）、M6 完工日 DTO 缺源。

**④ z0 半成品收尾（小修；owner：前後端）**
- `00300` Document Checklist：return action 空回 → 補實作。
- `00600` Search：FE/BE HTTP method 不一致。

**④b 🔴 `00800` Revised Item（驗證後升級，非小修；owner：前後端 + PM/SA/RD）**
- 結構在、行為不對等。**TBD-無關可先修**：execute→POST、**execute 加 `@Transactional`（資料風險最高）**、item Y/N 驗證、回傳 pageMenuCondition、reason maxlength 3000。
- **側效/checkpoint 正確性（RI-MAT-001~005、0260 頁目標、isNotSame gate）→ 待 PRD `TBD-006`（保留 legacy 側效?）+ `TBD-003/004/005`（ITEM 規則）裁定再修**。詳 `build-tasks/00800-verification-findings.md`。

**⑤ c0 escalation（owner：信用決策 domain）— 2 條**：E1 CU-return checkpoint（`:2985`）、E2 `crScoreCardCompleted` 覆寫（`:2890`）。

**⑥ 授權列（owner：DB/ops）**：新 c0 endpoint（00115/116/118/119/120）`TB_API_AUTH`/`TB_ROLE_TASK`（00117 既有）。

**⑦ 暫緩 track（需先拍板）**：R2 報表服務（→0181/i0·c0 PDF/z0 PDF）、檔案上傳 API（→collateral/審批上傳）。〔CBC 已釐清＝頁內、非獨立 track〕

**⑧ 已裁**：`CS 0240` → **不開發**（2026-06-06 確認新系統無使用）。

**⑨ Tech-debt / ops**
- **FE/BE HTTP method 不一致 sweep**（系統性：00600/00800/00640…）。
- map-key 大小寫 sweep（Oracle native query 靜默 null）。
- Logback 硬編碼 `D:\temp\...` 外部化。

---

## 5. 建議排程（依依賴與風險）— cross-check 後更新
> 新增 **Phase F（c0 評分前端）**。原則：先坐實缺口 →（驗證已完成 ‖ 補 c0 FE，可並行）→ 攻撥貸 domain → 暫緩 track 待決策。
> **🔓 DB 連線已可用（2026-06-06）**：原卡「待 dev/uat/DBA」的 **Phase V 整合驗證、c0 授權列、DB-相關 OQ（精度/schema/DDL）、M7/M9 確認點、z0 半成品(method/return)** 全部**即刻可跑** → 建議與 Phase F coding **並行先攻**。⚠️ **先建 c0 新 endpoint 授權列**（`TB_API_AUTH`/`TB_ROLE_TASK`），否則 c0 FE 做完仍 403 打不通、白測。

**Phase 0 — 坐實缺口（c0 FE ✅ 已坐實）**
0. ✅ c0 評分 FE 範圍已坐實（容器 + 8 子頁）；✅ `CS 0240` 裁定**不開發**。**Phase 0 清空。**

**Phase F — c0 評分前端（NEW；owner：前端；BE 已齊、可直接對接）— 範圍已坐實**
1. 建 corporate `credit-investigation` 容器（鏡像 i0 動態 tab + businessType G/F 分頁）。
2. 補 8 子頁 component/service（00112/114/115/116/117/118/119/120），各對接對應 `-c0-` endpoint + corporate DTO。
3. 補完接 c0 BE、納入 Phase V 驗證 + 授權列。建議**先做容器 + 1 子頁打通動態 tab/businessType 再展開其餘**。

**Phase V — 整合驗證（即刻，可與 Phase F 並行；owner：整合測試）**
3. 契約對齊 sweep：主流程 + i0 全頁 + 契約頁 FE↔BE DTO（真資料/真授權）。
4. z0 報表呈現；z0 半成品收尾（00300 return、00600/00800 method）。

**Phase D — 撥貸解鎖（關鍵路徑，owner：撥貸 domain）**
5. 🔴 **A-1 換匯 stub**（先「實作前調查」：匯率來源 API/表、舊取法、回傳結構）→ 端到端 → 驗 D1–D8 → B-1/T24 來源 → 精度（舊 DDL/DBA）。

**Phase E — c0 收尾 + 授權（owner：domain + DB/ops）**
6. c0 E1/E2 escalation 裁示；新 c0 endpoint 授權列。

**Phase R — 暫緩 track（待拍板，可獨立排）**
7. R2 報表服務 → 0181/i0·c0 PDF/z0 PDF；檔案上傳 API；FE/BE method-mismatch sweep；map-key sweep；Logback 外部化。

**關鍵路徑（兩條）**：① **撥貸上線 = Phase D（先 A-1 stub）**；② **企金評分可用 = Phase F（c0 評分前端，本次新發現、先前漏估）**。其餘前端 + i0 + c0 BE = **Phase V 驗證**即可收。R2/檔案 = 獨立決策 track、不擋主里程碑。

---
> 維護：本檔為**對應/排程主表**；逐項狀態變動回填本檔 + 對應細節 doc（`completion-ledger` 桶別、`verification-handoff` 驗證、`disbursement-*` 撥貸）。❓ 項一經唯讀盤點即升 ✅/🔴。
