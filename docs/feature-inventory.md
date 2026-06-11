# 舊→新 功能總盤點（Feature Inventory）— 70% + 30% 全量

> **用途**：把舊 EPRO 系統（~250 JSP / 9 模組）轉新系統（前端 Angular + 後端 Spring Boot）的**每一項功能**、前後端狀態、剩餘事項、橫向 track、建議排程，收斂成一張可排程追蹤的主表。
> **來源**（2026-06-10 已分資料夾）：`legacy/page-mapping.md`（舊→新對應）、`process/completion-ledger.md`（總盤點）、`verification/verification-handoff.md`（驗證待辦）、`disbursement/`（撥貸 triage+escalations）、`legacy/migration-backlog.md`（模組地圖/R1–R8）、`legacy/module-*.md`（頁內結構）。
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
> **確認**：c0 後端齊（`controller/corporate/*`）；corporate 前端評分容器原本**完全未建**。→ ✅ **整組 c0 評分 FE 已建齊＝1 容器 + 8 子頁**（**Phase F 收工 2026-06-09**；c0 無 00111/00113）。原本次盤點**最大缺口、現已補齊**。
| 新頁 | 名稱 | FE | BE | 對接 c0 endpoint（BE 已齊）|
|---|---|:--:|:--:|---|
| EPROC00110 | 評分容器（corporate credit-investigation）| ✅ | ✅ | `epl-info/save-c0-credit-investigation-tab`（`CsuCreditInvestigationController`；Step 1 容器，BE 驅動動態 tab）|
| EPROC00112 | CBC Banking Relationship | ✅ | ✅ | `epl-info/save-c0-cbc-banking-relationship`（`7e8aaf7`）|
| EPROC00114 | Collateral Assessment | ✅ | ✅ | `epl-sele/info/save-c0-collateral-assessment`（`62ec62f`；無 c0 calc→隱 Calc 鈕、分數 BE save 算）|
| EPROC00115 | Borrower Group Exposure | ✅ | ✅ | `epl-sele/info/save-c0-borrower-group-exposure`（Step 1 BGE pilot）；授權列 |
| EPROC00116 | Financial Statement GI | ✅ | ✅ | `epl-*-c0-financial-statement-comments`（`524d8dc`；calc 保留、export POST-blob 兩邊一致、無 00640 式不符）；授權列；export 模板沿用 i0？|
| EPROC00117 | Financial Evaluation GI | ✅ | ✅ | **business-only ✅**（`b14ae05`，決策 B）：接 `epl-sele-c0-financial-list`、`epl-info/save-c0-financial-business`（info 保留 BE 要的 isQuery、save 不帶）；**未接 `-financial-staff`/funcIsStaffLoan**（cleanup）；guard scan/BOM 過。授權列 |
| EPROC00118 | Corporate Scorecard | ✅ | ✅ | `epl-{sele(-list)/info/calc/save}-c0-corporateScorecard`（`39e95dd`；**calc 保留接上**）；授權列；🚩 2 escalation |
| EPROC00119 | Financial Statement FI | ✅ | ✅ | `epl-*-c0-financial-statement-cmts-fi`（`02d50e7`；無 sele、calc 保留、export POST-blob 一致、保留 c0 FI 需要的 isQuery）；授權列；export 模板沿用 i0？|
| EPROC00120 | Financial Evaluation FI | ✅ | ✅ | **business-only ✅**（`6b084fb`，決策 B）：接 `epl-info/save-c0-financial-evaluation-table-fi`（info 留 isQuery、save 送 applicationNo/isFinish/financialList + cetOne/totalCapitalRatio）；i0 FI 有 list 但頁不消費 options → `getMenu()`回`of({})`不接；**未接 `-staff-fi`/funcIsStaffLoan**（cleanup）；BOM/build 過。授權列 |
> **範本＝i0 `individual/credit-investigation`**：容器 component 動態載 tab（`epl-*-i0-credit-investigation-tab`、`creditInvestigationNav()` config、`CreditInvestigationPageCode` enum）、各子頁 `components/<name>/{component,services}`。c0 照此鏡像、改 `-c0-` endpoint + corporate DTO。
> ⚠️ **G/F businessType 分頁**：FE 容器須吃 BE 回的 `businessType`+`pageMap`（預設 G→移除 00119/00120、F→移除 00116/00117；save 依 businessType 更 checkpoint，`CsuCreditInvestigationServiceImpl:129/264/279/366`）。i0 容器本就動態（tabControl 來自 BE）→ 鏡像即自然涵蓋。
> **進度（2026-06-06）**：✅ **Step 1**＝c0 容器（BE 驅動動態 tab、`epl-*-c0-credit-investigation-tab`）+ **00115 BGE** pilot，`ng build` 綠（容器 DTO 對齊 c0＝只 `businessType`/`pageMap`、無 i0 的 `assessmentType`/`isStaffLoan`，故容器只留 businessType radio）。✅ **Step 2 完成（Phase F 收工 2026-06-09，8 子頁齊）**：✅ `00112` CBC（`7e8aaf7`；無 calc→totals 本地加總）、✅ `00114` Collateral Assessment（`62ec62f`；無 calc→隱鈕、分數 BE save 算）、✅ `00118` Corp Scorecard（`39e95dd`；calc 保留、回填 riskLevel/scoreDatetime）、✅ `00116` FinStmt GI（`524d8dc`；calc 保留、export POST-blob 一致）、✅ `00119` FinStmt FI（`02d50e7`；無 sele、保留 c0 需要的 isQuery、`report.service.ts` 確認加法無 i0 回歸）；**staff 批 `00117`/`00120`**（business-only，決策 B；✅ `00117`=`b14ae05`、✅ `00120`=`6b084fb`）。✅ **2026-06-09 對舊 source 驗畢 → 決策 B**：舊 corporate c0 00117/00120 是 BusinessOwner-only（舊 c0 trx/module 無 staff 分版/staff save、staff token grep 全空），新 `funcIsStaffLoan` 對 CS/CU 恆 false 是**忠實沿用舊 i0**（staff 僅 IS+03 / IU+01，`legacy-epro/.../EPRO_I00111.java:267`）、**非 regression**。→ **只建 business 版**；c0 staff 端點（`epl-info/save-c0-financial-staff`、`epl-save-c0-financial-evaluation-staff-fi`）＝鏡像 i0 多餘物 → **cleanup backlog（不接 FE、刪除另案）**。判定來源＝容器 `businessType`/`pageMap`（**FE 不打 funcIsStaffLoan**；00117 在 G、00120 在 F 分支）。⚠️ **watch**：① 🔑 **calc 逐頁不同**——00112/00114 無 calc（已隱），但 **00118 Corp Scorecard 有 `epl-calc-c0-corporateScorecard`、00116/00119 FinStmt 亦有 calc → 這幾頁 calc 鈕要保留接上**，勿誤套「隱 calc」。② ✅ c0 staff-vs-business 判定已決（B：business-only，讀容器 businessType/pageMap、不打 funcIsStaffLoan）③ 真元件就緒後實跑 G/F 切換 ④ 整合測確認：00112 totals、00114 rating 是否仍**唯讀顯示**(BE save 算後回傳)、語意與 BE 一致。

### 2E. 共用 `EPROZ00*`（M8 z0）
| 新頁 | 名稱 | FE | BE | 剩餘 / 備註 |
|---|---|:--:|:--:|---|
| EPROZ00100 | TO DO LIST | ✅ | ✅ | cross-check ✅ |
| EPROZ00200 | New Case Application（進件入口）| ✅ | ✅ | ✅；案號序列細節未深入 |
| EPROZ00300 | Document Checklist | 🟡 | 🟡 | ⚠️ **return action 空回、疑未完成**（`DocumentChecklistController:57`）|
| EPROZ00400 | Case Distribution | ✅ | ✅ | cross-check ✅ |
| EPROZ00410 | Related Party Info | ✅ | ✅ | cross-check ✅ |
| EPROZ00500 | Comparison table…CUBC | ✅ | ✅ | cross-check ✅ |
| EPROZ00600 | Search | ✅ | ✅ | options FE→GET 對齊 BE（`48e687f`，sweep①） |
| EPROZ00610 | Credit Reviewer On Hand | ✅ | ✅ | 🟡 呈現/資料驗證 |
| EPROZ00620 | Application Delete Report | ✅ | ✅ | 🟡（繼承 `base-application-report`）|
| EPROZ00630 | Deviation Case Report | ✅ | ✅ | 🟡（含 Excel export）|
| EPROZ00640 | Scorecard Report | ✅ | ✅ | 🟡；⚠️ **export FE POST blob vs BE GET `@RequestBody` 介面不一致→優先對** |
| EPROZ00650 | Application Cancel Report | ✅ | ✅ | 🟡 |
| EPROZ00660 | CAD On Hand Status | ✅ | ✅ | ✅（CR 範本）|
| EPROZ00700 | Assign Substitute | ✅ | ✅ | ✅（= `pages/deputy`）；嚴謹可做 deputy↔0700 gap-check |
| EPROZ00800 | Revised Item | 🟠 | 🟠 | **D1–D5 已修（`88328f9`）**；**✅ TBD-001~007 全裁（2026-06-11，SRS v0.5）**：RP1=**A 保留側效** → R5/R13.1–13.3/13.6/13.7 定版、**RI-MAT 修復解鎖**（isNotSame gate 移除、R13.1~13.3 bug、R5 disable、audit 摘要、Finished）。剩 R13.4/13.5（RP4←RP6 取數）、`_0260` key §5.6、init-query method、RP8。**SRS bundle**＝`specs/srs/EPROZ00800/` |
> 共用 API `EPROZZ_0100`（查地址欄位選單）。

### 2F. 撥貸 `EPROISU0920/0921/0922` + T24（🔴 唯一真未完成區塊）
| 區 | 狀態 | 內容 |
|---|---|---|
| 機械修正 M1–M10 | ✅ 全結案（master） | 尾欄/submit mail/RECEIVED_DATE/C20/fee key/E 位/H 段/A52/fee-delete-FN |
| 🔴 **A-1 換匯 stub** | **未做（總開關）** | `funcGetExchangeRate` throw-stub → authorize 全斷、從未端到端跑過 |
| 🔴 B-1 `T24_COMPANY` 值來源 | 未決 | B8/C9 讀已移除欄、無替代 |
| 🔴 其餘 domain | 未決 | 換匯源 ID、檢核嚴格度、KHR、欄寬、async 架構、精度… |
| 整合測確認點 | 待驗 | M7 facility fee 值、M9 district name join |
> **完整待裁清單見 [`disbursement-domain-escalations.md`](disbursement/disbursement-domain-escalations.md)。** ⚠️ 機械修正全 inert——A-1 未通,撥貸跑不起來。

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
| — | **FE/BE HTTP method 不一致** | ✅ sweep 收齊 | `48e687f`：00600/00640 對齊；00800 init-query 列 @PENDING 待裁定 |

---

## 4. 剩餘事項彙整（= 還有多少事要做）— cross-check 後更新（2026-06-06）
> 🔗 **所有 open 決策/待決（@PENDING/escalation/OQ）的單一總表**＝[`pending-register.md`](pending-register.md)（誰欠裁定、卡什麼）。下面 ③⑤⑦ + ④b 的待決都登錄在那。
> **翻案**：新增 **c0 評分前端真缺口**（原以為前端全完）。❓ 多已坐實（i0/契約/多數 z0 ✅）。

**① ✅ c0 評分前端（Phase F 收工 2026-06-09；owner：前端）— 原本次最大缺口、已補齊**
- ✅ **整組已建齊＝1 容器 + 8 子頁**（00112/00114/00115/00116/00117/00118/00119/00120；c0 無 00111/00113）。00117/00120 為 **business-only**（決策 B）。
- **剩（非 coding）**：納入 Phase V 整合驗證 + c0 新 endpoint 授權列（見 ⑥）；staff 端點 cleanup（見 ⑨）。

**② 整合驗證（owner：dev/uat 整合測試）— 量大、非補碼**
- 主流程（is/iu/cs/cu 0110–0173）+ 契約頁（0910–0913）+ i0 全頁 FE↔BE `epl-*` DTO/授權各跑一次。
- z0 報表 00610/00620–00650 呈現。

**③ 🔴 撥貸 domain（owner：撥貸 domain + T24 + DBA）— 見 escalation doc**
- A-1 換匯 stub（**撥貸總開關、最優先**）、B-1 `T24_COMPANY`、換匯源 ID、檢核嚴格度、KHR、欄寬、async、精度（待舊 DDL）、M6 完工日 DTO 缺源。

**④ z0 半成品收尾（小修；owner：前後端）**
- `00300` Document Checklist：return action 空回 → 補實作。
- ✅ `00600` Search method 已修（sweep① `48e687f`）。

**④b 🟠 `00800` Revised Item（D1–D5 已修；✅ TBD 裁定輪 06-11 完成；owner：RD 實作＋SA 取數）**
- ✅ **TBD-無關硬缺陷 D1–D5 已修**（`88328f9`，2026-06-09；prompt 已歸檔 `done/00800-fix-step1-tbd-independent.md`）：execute→POST、**execute 單一 `@Transactional`（資料遺失風險已除）**、item Y/N 驗證、回傳 pageMenuCondition、reason maxlength 3000+trim。QA-013/014/016/017 過；**QA-012 rollback 整合測 deferred-to-DB**。
- ✅ **TBD-001~007 全裁（2026-06-11，SRS v0.5）**：`TBD-006`=**A 保留側效＋修bug＋audit**、`003/004`=保留原因後補、`007`=維持現狀定版、`002`=Finished、`001`=動作項化（**SA 匯 `TB_COMMON_FIELD_OPTIONS`**）、`005`=連動 001 取數後裁。**解鎖 RD 修復**：isNotSame gate 移除（R11）、R13.1 還原空值、R13.2 補判斷、R13.3 補 `IS_ANY_COLLATERAL_PROVIDER`、R5 disable、R16 audit 側效摘要、`Finshed`→`Finished`。
- **剩**：R13.4/13.5（RP4 ← RP6 取數）、`_0260` checkpoint key 清單（§5.6）、init-query method、R6/R7 判據（RP8）。詳 `specs/srs/EPROZ00800/spec.md` v0.5。

**⑤ c0 escalation（owner：信用決策 domain）— 2 條**：E1 CU-return checkpoint（`:2985`）、E2 `crScoreCardCompleted` 覆寫（`:2890`）。

**⑥ 授權列（owner：DB/ops）**：新 c0 endpoint（00115/116/118/119/120）`TB_API_AUTH`/`TB_ROLE_TASK`（00117 既有）。

**⑦ 暫緩 track（需先拍板）**：R2 報表服務（→0181/i0·c0 PDF/z0 PDF）、檔案上傳 API（→collateral/審批上傳）。〔CBC 已釐清＝頁內、非獨立 track〕

**⑧ 已裁**：`CS 0240` → **不開發**（2026-06-06 確認新系統無使用）。

**⑨ Tech-debt / ops**（✅ 靜態 sweep 三批已收齊，2026-06-09；prompt 全歸檔 `done/`）
- ✅ **FE/BE HTTP method 不一致 sweep**（`48e687f`）：00600 search-options、00640 export PDF/Excel FE→GET 對齊 BE；00800 init-query 列 B 待裁定（按 SRS @PENDING 不動）。
- ✅ **map-key 大小寫 sweep**（`709f65c`）：A＝quote alias / 讀端對齊大寫（loan summary/collateral/guarantor/T24/loan-condition 等）；B/UNSURE＝SELECT * Map、無法靜態綁定者不猜。⚠️ **A 修正屬 runtime-silent 類 → Phase V 必複測**（compile 抓不到）。
- ✅ **Logback `D:\temp` 外部化**（`bbc4492`）：改 `${LOG_API_PATH:${LOG_PATH:logs}}` 等跨平台預設，appender/pattern/level 未動；連帶解掉 full `mvn clean package` 卡 D:\temp。
- ✅ **c0 staff 端點 cleanup 已完成**（`dcd9602`，2026-06-09；prompt 已歸檔 `done/c0-staff-endpoints-cleanup.md`）：刪 `epl-info/save-c0-financial-staff` + `CsuFinancialEvaluationStaffFiController` 整檔（+ staff DTO/serviceImpl、staff option/funcIsStaffLoan 依賴）；**保留** `CsuFinancialStaffController` 的 sele(list)/business method（00117 在用）、table-fi（00120）；i0 未碰；mvn + npm build 綠。

---

## 5. 建議排程（依依賴與風險）— cross-check 後更新
> 新增 **Phase F（c0 評分前端）**。原則：先坐實缺口 →（驗證已完成 ‖ 補 c0 FE，可並行）→ 攻撥貸 domain → 暫緩 track 待決策。
> **🔒 DB 連線尚未打通（2026-06-09 更正；先前誤記「已可用」）**：以下仍 **gated on DB** → **Phase V 整合驗證、c0 授權列「套用/驗證」、DB-相關 OQ（精度/schema/DDL）、M7/M9 確認點、z0 半成品(method/return) 實測**。DB 打通前 **先做 DB-無關工作**：00800 可先修子集（code+build）、c0 staff cleanup、靜態 tech-debt sweep（HTTP method 不一致、map-key 大小寫、Logback 外部化）、c0 授權列 **SQL 產出（先寫好、待 DB 套用）**。⚠️ 提醒：c0 FE 已做完，但 **授權列未套用前打 c0 endpoint 會 403** → DB 一通先套授權列。

**Phase 0 — 坐實缺口（c0 FE ✅ 已坐實）**
0. ✅ c0 評分 FE 範圍已坐實（容器 + 8 子頁）；✅ `CS 0240` 裁定**不開發**。**Phase 0 清空。**

**Phase F — c0 評分前端 ✅ 收工（2026-06-09；owner：前端）**
1. ✅ corporate `credit-investigation` 容器（BE 驅動動態 tab + businessType G/F 分頁）。
2. ✅ 8 子頁 component/service（00112/114/115/116/117/118/119/120）各對接 `-c0-` endpoint + corporate DTO；00117/00120 business-only（決策 B）。
3. **剩**：納入 Phase V 驗證 + c0 新 endpoint 授權列（⑥）；staff 端點 cleanup（⑨）。

**Phase V — 整合驗證（即刻，可與 Phase F 並行；owner：整合測試）**
3. 契約對齊 sweep：主流程 + i0 全頁 + 契約頁 FE↔BE DTO（真資料/真授權）。
4. z0 報表呈現；z0 半成品收尾（00300 return；✅ 00600 method 已修；00800 init-query method＝@PENDING 待 RD）。

**Phase D — 撥貸解鎖（關鍵路徑，owner：撥貸 domain）**
5. 🔴 **A-1 換匯 stub**（先「實作前調查」：匯率來源 API/表、舊取法、回傳結構）→ 端到端 → 驗 D1–D8 → B-1/T24 來源 → 精度（舊 DDL/DBA）。

**Phase E — c0 收尾 + 授權（owner：domain + DB/ops）**
6. c0 E1/E2 escalation 裁示；新 c0 endpoint 授權列。

**Phase R — 暫緩 track（待拍板，可獨立排）**
7. R2 報表服務 → 0181/i0·c0 PDF/z0 PDF；檔案上傳 API；FE/BE method-mismatch sweep；map-key sweep；Logback 外部化。

**關鍵路徑（兩條）**：① **撥貸上線 = Phase D（先 A-1 stub）**；② **企金評分可用 = Phase F（c0 評分前端，本次新發現、先前漏估）**。其餘前端 + i0 + c0 BE = **Phase V 驗證**即可收。R2/檔案 = 獨立決策 track、不擋主里程碑。

---
> 維護：本檔為**對應/排程主表**；逐項狀態變動回填本檔 + 對應細節 doc（`completion-ledger` 桶別、`verification-handoff` 驗證、`disbursement-*` 撥貸）。❓ 項一經唯讀盤點即升 ✅/🔴。
