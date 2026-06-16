# 舊→新 功能總盤點（Feature Inventory）— 70% + 30% 全量

> **用途**：把舊 EPRO 系統（~250 JSP / 9 模組）轉新系統（前端 Angular + 後端 Spring Boot）的**每一項功能**、前後端狀態、剩餘事項、橫向 track、建議排程，收斂成一張可排程追蹤的主表。
> **來源**（2026-06-10 已分資料夾）：`legacy/page-mapping.md`（舊→新對應）、`archive/completion-ledger.md`（總盤點，已凍結）、`verification/verification-handoff.md`（驗證待辦）、`disbursement/`（撥貸 triage+escalations）、`legacy/migration-backlog.md`（模組地圖/R1–R8）、`legacy/module-*.md`（頁內結構）。
> ⚠️ 原始碼不外流；本 repo 只放對應/規格。前後端實作在各自專案。

## 0. 怎麼讀
**狀態圖例**
- ✅ **完成**（碼到位；多數仍需一輪整合驗證但非補碼）
- 🟡 **碼到位、待整合驗證**（dev/uat 真資料/真授權跑一次）
- 🔴 **真未完成 / 會錯**（需補碼或 domain 決策）
- ⏸ **暫緩 track**（R2 報表服務 / 檔案 API / CBC R8——刻意延後、非遺漏）
- ❓ **待 cross-check**（推定既有，未實證；開做前先唯讀盤點）

**全局結論（zero-based audit 後更新 2026-06-11；總量表＝`build-tasks/refactor-audit/diff-vs-inventory.md`）**：166 audit 列基線＝116 碼在(70%)/11🟡/2🚫/37 UNFOUND；**06-15 校正後＝~133 碼在(80%)**（G1–G6＋修復落地）。真缺口＝🟠 **撥貸**（**A-1 換匯 stub ✅ 已實作 `daae4c3` 06-16**；剩 T24 正確性 domain-gated + **批次層 B001–B008 待碼驗** F-OWN-1 + A-1 spec-conformance 確認）。✅ **企金主流程 FE 後半段 Phase G 全收口（G1–G6，06-15）**＝0150/0160/0170/0171/0172/0173＋0261/0174/0175 三 popup（Phase V runtime 待測）。已收口：c0 評分 FE（Phase F）、i0 全模組（audit 22/22）。剩 UNFOUND 多為 M9 雜項群（AUD-3/4 待裁）；0140/0240 家族 AUD-1 ✅已關（06-16 owner 盤點＝已無使用）；另待裁 AUD-2/3/4/7/8/10/11。

**三層結構**（避免把「模組」當「單頁」）：① 模組流程（M1–M9）② 流程頁（外層 pageMap 頁籤）③ 頁內區塊（內層 tab）。遷移單位＝模組流程。

---

## 1. 模組總表（M1–M9）
> **audit 驗證**欄＝最近一次 zero-based 盤點（`/refactor-audit` skill）校正該模組的日期＋ref。**該欄日期 stale ＝ 該模組自上次校正後有增量改動但未重盤 → 提醒該再跑一次**（drift 可見化；首盤 2026-06-11＝`build-tasks/refactor-audit/`）。
| # | 舊模組 | 用途 | 舊 JSP | 新對應 | 狀態 | audit 驗證 |
|---|---|---|---:|---|---|---|
| M1 | `zz` | 登入/首頁（SSO）| 1 | `main-layout` + Spring Security/JWT（驗 MIS） | ✅ | 06-11 `S1` |
| M2 | `is` | 個人申貸 主流程（有擔）| 39 | `EPROISU*`（IS+IU 合併） | ✅ 前端／🟡 驗證 | 06-11 `S2/S3` |
| M3 | `iu` | 個人申貸（無擔）| 20 | 併入 `EPROISU*` | ✅ 前端／🟡 驗證 | 06-11 `S3` |
| M4 | `cs` | 企金申貸（有擔）| 20 | `EPROCSU*`（CS+CU 合併） | ✅ **FE 後半補建完 6/6（Phase G 收口，§4①b）**／BE ✅ | 06-11 `S4`（F-1 翻案）→06-15 G1–G6 落地 |
| M5 | `cu` | 企金申貸（無擔）| 17 | 併入 `EPROCSU*` | ✅ **FE 後半補建完（同 M4）**／BE ✅ | 06-11 `S4`（F-1 翻案）→06-15 G1–G6 落地 |
| M6 | `i0` | 個人 財報/評分/CBC | 42（audit 22 列，01xx/02xx 變體） | `EPROI00*` | ✅ **audit 22/22 全綠（06-11）** | 06-11 `S5/S6` |
| M7 | `c0` | 企金 財報/評分/CBC | 38（audit 20 列） | `EPROC00*` | ✅ BE＋評分 FE（Phase F）；audit 4🟡＋2 待裁（§2D）| 06-11 `S7/S8` |
| M8 | `z0` | 管理/報表/工具 | 18 | `EPROZ00*` | ✅ 大多／⏸ 報表服務 R2 | 06-11 `S9` |
| M9 | common/demo | 版型/例外/demo | 11 列（頁級 16；audit 重數） | `main-layout`/error pages | 🟡 殼/error ✅；admin/demo 10 列 UNFOUND 待裁（AUD-3/4）| 06-11 `S1` |

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
| EPROISU0920 | IS 0920 | **Disbursement Process（頁框）** | ✅ | ✅ | audit 碼在（DIFF-004）；domain 風險見 §2F |
| EPROISU0921 | IS 0921 | **Disbursement Data Input** | ✅ | ✅ | audit 碼在；行為分歧屬 triage 軌（§2F）|
| EPROISU0922 | IS 0922 | **Disbursement Summary（authorize/T24）** | ✅ | 🟡 | **A-1 throw-stub（見 §2F）** |
> 不開發：`EPROIS_0140`(Property Info) 已 drop。popup `0174/0175/0176`→`mat-dialog`（隨審批頁）。audit：`EPROIS_0240`/`EPROIU_0140`/`EPROIU_0240`→**AUD-1 ✅已關（06-16 owner 權威盤點標「已無使用」＝確認不遷）**。

### 2B. 企金主流程 `EPROCSU*`（M4 cs + M5 cu 合併）
| 新頁 | 合併舊 funcId | 名稱 | FE | BE | 剩餘 / 備註 |
|---|---|---|:--:|:--:|---|
| EPROCSU0110 | CS/CU 0110+0210 | Main Borrower（單 tab）| ✅ | ✅ | 🟡 驗證 |
| EPROCSU0120 | 0120+0220 | Co-Borrower | ✅ | ✅ | 🟡 驗證 |
| EPROCSU0130 | 0130+0230 | Guarantor | ✅ | ✅ | **✅ 2026-06-05 收尾（ng build 綠）** |
| EPROCSU0150 | 0150+0250 | Collateral（僅有擔；內層 3 tab：Info/Valuation/Site Visit）| ✅ | ✅ | **FE 補建 G2 ✅ 06-12**（`14b254e`，三 mat-tab 照舊 cs 結構）；⏸ 檔案 API（上傳區守現狀）；Phase V 待測 |
| EPROCSU0160 | 0160+0260 | Loan Condition（+0261 popup）| ✅ | ✅ | **FE 補建 G1 ✅ 06-12**（`809d25d`，pilot；0261 CSU popup 變體、ISU 零修改）；Phase V 待測 |
| EPROCSU0170 | 0170+0270 | Credit Eval & Decision（+0174/0175 popup）| ✅ | ✅ | **FE 補建 G3 ✅ 06-12**（`646e178`；return dialog `endpointConfig` 參數化＋cancel CSU 變體、ISU 零 diff、build 綠）；Phase V 待測（含 ❓ 審批段細節(B1)、CSU download route 無）|
| EPROCSU0171 | 0171 | Loan Committee Conclusion | ✅ | ✅ | **FE 補建 G4 ✅ 06-15**（`8badefc`；接 `epl-sele/info/save-csu-loan-committee`＋CSU save mapper、build 綠）；Phase V 待測（檔案 upload/download 無 CSU route＝現狀）|
| EPROCSU0172 | 0172 | Approved Loan Condition | ✅ | ✅ | **FE 補建 G5 ✅ 06-15**（`0ff2140`；接 `epl-info-csu-app-loan-cond`、列印/下載鏡像 ISU 現狀）；⏸ 列印 R2；Phase V 待測 |
| EPROCSU0173 | 0173 | Credit Evaluation Old | ✅ | ✅ | **FE 補建 G6 ✅ 06-15**（`4429551`；接 `epl-info-csu-cr-eval-old`、build 綠）；Phase V 待測 |
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
> i0 全做 → c0 的 FE 缺口（§2D）＝「照 i0 鏡像補 c0 評分 FE」。✅ **zero-based audit（06-11）：M6 22/22 全綠**（舊 01xx/02xx 變體計 22 列，11 新頁全涵蓋；`refactor-audit/M6-i0.md`）。

### 2D. 企金評分 `EPROC00*`（M7 c0）— 🔴 **FE 整組缺口（已坐實，2026-06-06）**
> **確認**：c0 後端齊（`controller/corporate/*`）；corporate 前端評分容器原本**完全未建**。→ ✅ **整組 c0 評分 FE 已建齊＝1 容器 + 8 子頁**（**Phase F 收工 2026-06-09**；c0 無 00111/00113）。原本次盤點**最大缺口、現已補齊**。
| 新頁 | 名稱 | FE | BE | 對接 c0 endpoint（BE 已齊）|
|---|---|:--:|:--:|---|
| EPROC00110 | 評分容器（corporate credit-investigation）| ✅ | ✅ | `epl-info/save-c0-credit-investigation-tab`（`CsuCreditInvestigationController`；Step 1 容器，BE 驅動動態 tab）|
| EPROC00112 | CBC Banking Relationship | ✅ | ✅ | `epl-info/save-c0-cbc-banking-relationship`（`7e8aaf7`）|
| EPROC00114 | Collateral Assessment | 🟡 | ✅ | `epl-sele/info/save-c0-collateral-assessment`（`62ec62f`；無 c0 calc→隱 Calc 鈕、分數 BE save 算）；audit F-7：calc handler 空 return——**Phase V 驗鈕真隱→可降回 ✅** |
| EPROC00115 | Borrower Group Exposure | ✅ | ✅ | `epl-sele/info/save-c0-borrower-group-exposure`（Step 1 BGE pilot）；授權列 |
| EPROC00116 | Financial Statement GI | ✅ | ✅ | `epl-*-c0-financial-statement-comments`（`524d8dc`；calc 保留、export POST-blob 兩邊一致、無 00640 式不符）；授權列；export 模板沿用 i0？|
| EPROC00117 | Financial Evaluation GI | ✅ | ✅ | **business-only ✅**（`b14ae05`，決策 B）：接 `epl-sele-c0-financial-list`、`epl-info/save-c0-financial-business`（info 保留 BE 要的 isQuery、save 不帶）；**未接 `-financial-staff`/funcIsStaffLoan**（cleanup）；guard scan/BOM 過。授權列 |
| EPROC00118 | Corporate Scorecard | ✅ | ✅ | `epl-{sele(-list)/info/calc/save}-c0-corporateScorecard`（`39e95dd`；**calc 保留接上**）；授權列；🚩 2 escalation |
| EPROC00119 | Financial Statement FI | ✅ | ✅ | ✅ F-8 已修（`6919da5`，options 接 `epl-sele-c0-financial-statement-comments`）；**Phase V 必驗**：下拉有值+save 帶值+GI-sele 對 FI（businessType F）無分支影響；授權列；export 模板沿用 i0？|
| EPROC00120 | Financial Evaluation FI | ✅ | ✅ | **business-only ✅**（`6b084fb`，決策 B）：接 `epl-info/save-c0-financial-evaluation-table-fi`（info 留 isQuery、save 送 applicationNo/isFinish/financialList + cetOne/totalCapitalRatio）；i0 FI 有 list 但頁不消費 options → `getMenu()`回`of({})`不接；**未接 `-staff-fi`/funcIsStaffLoan**（cleanup）；BOM/build 過。授權列 |
> **範本＝i0 `individual/credit-investigation`**：容器 component 動態載 tab（`epl-*-i0-credit-investigation-tab`、`creditInvestigationNav()` config、`CreditInvestigationPageCode` enum）、各子頁 `components/<name>/{component,services}`。c0 照此鏡像、改 `-c0-` endpoint + corporate DTO。
> ⚠️ **G/F businessType 分頁**：FE 容器須吃 BE 回的 `businessType`+`pageMap`（預設 G→移除 00119/00120、F→移除 00116/00117；save 依 businessType 更 checkpoint，`CsuCreditInvestigationServiceImpl:129/264/279/366`）。i0 容器本就動態（tabControl 來自 BE）→ 鏡像即自然涵蓋。
> ⚠️ audit（06-11）：舊源有 `EPROC0_0211/0213`（展期限定 FinEvalTable/Scorecard），新系統 FE/BE 全無→**AUD-2 待裁**（是否由 00116-00120 涵蓋；`refactor-audit/M7a-c0-00110-00115.md`）。
> **進度**：✅ Step 1 容器 + 00115 pilot；✅ Step 2 八子頁齊（**Phase F 收工 2026-06-09**；各頁 commit/calc 註記見上表列、過程見 `build-tasks/done/phase-f-*`）。✅ `00117`/`00120`＝business-only（**決策 B**，對舊 source 驗畢、非 regression——證據/裁決全文見 `decisions.md`；staff 端點 cleanup 已清 `dcd9602`）。⚠️ **watch（Phase V）**：① calc 逐頁不同——00118/00116/00119 有 calc 要保留接上、00112/00114 無（已隱），勿誤套 ② 真元件就緒後實跑 G/F 切換 ③ 整合測確認 00112 totals / 00114 rating 唯讀語意與 BE 一致。

### 2E. 共用 `EPROZ00*`（M8 z0）
| 新頁 | 名稱 | FE | BE | 剩餘 / 備註 |
|---|---|:--:|:--:|---|
| EPROZ00100 | TO DO LIST（+00101/00102 popup）| ✅ | ✅ | ✅ F-10 已修（`2599752`，popup reason 回 API 來源）；F-9＝`@PENDING` 掛 R2（呈報書下載走 goPath）/檔案 API（upload stub）兩 ⏸ track |
| EPROZ00200 | New Case Application（進件入口）| ✅ | ✅ | ✅；案號序列細節未深入 |
| EPROZ00300 | Document Checklist | ✅ | ✅ | **FE 導回已修 06-15**（`40d931c`；實作共用 `goPreviousPage()`＝`addContentOnly('/to-do-list')`+navigate、backend 零改）；BE return 早坐實非缺陷。⚠️ **Phase V 驗**：共用方法由 no-op→一律回 ToDo，連帶 Related Party/Revised Item 三呼叫端，語意確認（日後要回原入口再加 originPage 分流）。次要待裁：APP_HISTORY=98/branch-vs-dept/權限·錯誤訊息等價（UNFOUND）|
| EPROZ00400 | Case Distribution | ✅ | ✅ | cross-check ✅ |
| EPROZ00410 | Related Party Info | ✅ | ✅ | cross-check ✅ |
| EPROZ00500 | Comparison table…CUBC | ✅ | ✅ | cross-check ✅ |
| EPROZ00600 | Search（+00601 處理履歷 popup）| ✅ | ✅ | options FE→GET 對齊 BE（`48e687f`，sweep①）；Phase V runtime 補修：`getSearchOptions` 改 GET query/model binding、FE 改 `?langType=` 無 body；00601 audit 補列 ✅ |
| EPROZ00610 | Credit Reviewer On Hand | ✅ | ✅ | 🟡 呈現/資料驗證 |
| EPROZ00620 | Application Delete Report | ✅ | ✅ | 🟡（繼承 `base-application-report`）|
| EPROZ00630 | Deviation Case Report | ✅ | ✅ | 🟡（含 Excel export）|
| EPROZ00640 | Scorecard Report | ✅ | ✅ | export 介面已對齊（sweep①）；BE PDF 改回 blob（`ResponseEntity<byte[]>`，openhtmltopdf/FileService），Excel 正常且未動；Phase V 待實測 PDF |
| EPROZ00650 | Application Cancel Report | ✅ | ✅ | 🟡 |
| EPROZ00660 | CAD On Hand Status | ✅ | ✅ | ✅ F-12 已修（product `5a47038`，FE endpoint 改 CAD）→ 復稱 CR 範本；Phase V 實測查詢一條 |
| EPROZ00700 | Assign Substitute | ✅ | ✅ | ✅（= `pages/deputy`）；**DB 複合 PK 已對齊**（06-16 reverify，`@EmbeddedId` EMP_ID+STR_TIME，AUD-9 關）|
| EPROZ00800 | Revised Item | 🟡 | ✅ | FE 🟡＝RP9 method 殘；BE ✅（D1–D5 `88328f9`＋**F1–F9 `5580eb7`**）；仍開 RP8/RP9/RP11——**單一出處＝bundle spec.md §@PENDING**；Phase V 待測：QA-007/008/009a/b/012/024/025＋F6 ≠03 分支＋audit userId。**SRS bundle**＝`specs/srs/EPROZ00800/`（v0.9）|
> 共用 API `EPROZZ_0100`（查地址欄位選單）。

### 2F. 撥貸 `EPROISU0920/0921/0922` + T24（🔴 唯一真未完成區塊）
| 區 | 狀態 | 內容 |
|---|---|---|
| 機械修正 M1–M10 | ✅ 全結案（master） | 尾欄/submit mail/RECEIVED_DATE/C20/fee key/E 位/H 段/A52/fee-delete-FN |
| ✅ **A-1 換匯 stub（+conformance PASS）** | **已實作＋碼驗（product `daae4c3`，06-16；mvn 綠）** | `funcGetExchangeRate` 補 return＋移尾端 throw → authorize 換匯總開關打通。**Codex 唯讀 conformance 4/4 PASS**：OQ-1 `IdNo=OVSLXLON01`(`:1181`)、OQ-3 非0000拋錯中止 authorize（碼＝專屬 `FAILED_E304`）、OQ-4 throw 勿回 null、兩表同 `@Transactional`。規格/recon 收 `done/` |
| 🟡 B-1 `T24_COMPANY`（06-12 降級）| **前提推翻→RD 接值** | 新庫 `TB_BRANCH_PROFILE.T24_COMPANY` 實存（OVSLXLON01/02 兩 schema，DDL 實查）；entity 補映射＋B8/C9 接值 |
| 🔴 其餘 domain | 未決 | 換匯源 ID（已裁 01）、檢核嚴格度、KHR、欄寬、async 架構… |
| 🟠 **批次層 B001–B008** | **碼驗部分回（06-16，AUD-10）** | ✅ B006 結果檔/B007 SFTP＝**FOUND**（撥貸下游交付不缺）；🔴 **B005 匯率排程＝app 碼缺**（新只有 inline 換匯 A-1；待 domain 判「inline 取代 vs 漏建」——查 `TB_EXCHANGE_RATE` 非-authorize 讀者）；⚪ B008 log 歸檔→ops；❓ B001–B004 待完整 findings。新批次重編號≠legacy 號 |
| 整合測確認點 | 待驗 | 〔A-1 spec-conformance ✅ PASS 06-16〕M7 facility fee 值、M9 district name join、撥貸端到端（含批次層）|
> **完整待裁清單見 [`disbursement-domain-escalations.md`](disbursement/disbursement-domain-escalations.md)。** ✅ **A-1 stub 已實作（`daae4c3`）→ 機械修正不再 inert、authorize 可端到端跑**；剩撥貸真完成＝T24 正確性（domain-gated）＋批次層（F-OWN-1 待碼驗）＋A-1 spec-conformance 確認。

---

## 3. 橫向基礎建設 track（R1–R8）
| R | 主題 | 狀態 | 影響面 |
|---|---|---|---|
| R1 | 舊→新 **Oracle schema** 遷移（**06-12 更正：舊庫亦 Oracle**，原依 `DB2PoolSvc.xml` 誤判 DB2）| ✅ 已定/進行（SQL 以新 Oracle 慣例改寫＋schema 改名對映）| 全後端；⚠️ map-key 大小寫 sweep（見 §4）|
| R2 | **報表服務（汰換 Jasper）** | ⏸ **未定（獨立 track）** | `*_0181` CAD、i0/c0 FinStmt PDF（0116/0119）、z0 報表呈現 |
| R3 | 主流程 shell 子樣式 | ✅ 已定（Workflow Shell + Section Tabs）| is/iu/cs/cu 共用 |
| R4 | 後端 action→REST 重寫 | ✅ 進行 pattern | 全後端 |
| R5 | 自訂 taglib 語意 | 低 | 元件對應 |
| R6 | shell 重用（避免 4–8x 重工）| ✅ 已定 | 主流程 |
| R7 | **權限三表遷移**（`TB_FUNCTION_AUTH`/`TB_API_AUTH`/`TB_ROLE_TASK`）| 🟡 進行 | **新 c0 endpoint 授權列待建**（見 §4）|
| R8 | CBC 聯徵資料接入 | 🟢 **釐清：非獨立 adapter** | CBC = 頁內 banking relationship（i0 已做；c0 FE 缺）；**無外部 adapter track** |
| — | **檔案上傳/下載 API** | ⏸ **待設計** | collateral 0150、審批 0170/0171/0173 上傳 |
| — | **FE/BE HTTP method 不一致** | ✅ sweep 收齊 | `48e687f`：00600/00640 對齊；00600 Phase V 補修 GET body regression；00800 init-query 列 @PENDING 待裁定 |

---

## 4. 剩餘事項彙整（= 還有多少事要做）— cross-check 後更新（2026-06-06）
> 🔗 **所有 open 決策/待決（@PENDING/escalation/OQ）的單一總表**＝[`pending-register.md`](pending-register.md)（誰欠裁定、卡什麼）。下面 ③⑤⑦ + ④b 的待決都登錄在那。
> ✅ **全量 zero-based 重盤完成（2026-06-11）**：結果＝`build-tasks/refactor-audit/diff-vs-inventory.md`（DIFF-001~016＋BIBLE-GAP-1~5）＋QC＝`build-tasks/refactor-audit-qc.md`（F-1~F-12）。**本檔已套用回填**；待裁＝AUD-1~5（`pending-register.md`）。
> **翻案**：新增 **c0 評分前端真缺口**（原以為前端全完）。❓ 多已坐實（i0/契約/多數 z0 ✅）。

**① ✅ c0 評分前端（Phase F 收工 2026-06-09；owner：前端）— 原本次最大缺口、已補齊**
- ✅ **整組已建齊＝1 容器 + 8 子頁**（00112/00114/00115/00116/00117/00118/00119/00120；c0 無 00111/00113）。00117/00120 為 **business-only**（決策 B）。
- **剩（非 coding）**：納入 Phase V 整合驗證 + c0 新 endpoint 授權列（見 ⑥）；staff 端點 cleanup（見 ⑨）。

**①b ✅ 企金主流程 FE 後半段（Phase G 全收口 06-15；audit F-1/DIFF-001；owner：前端）**
- 原況：六頁＋3 popup（0174/0175/0261）FE 全缺；BE `Csu*Controller` 全在。**G1（0160+0261，`809d25d`）/G2（0150 三 tab，`14b254e`）/G3（0170+0174/0175，`646e178`）/G4（0171，`8badefc`）/G5（0172，`0ff2140`）/G6（0173，`4429551`）全 ✅、審過、build 綠、BE 零改。**
- 卡已歸檔 `build-tasks/done/phase-g-csu-mainflow-fe.md`。**殘留＝Phase V runtime 待測**（見 `verification-handoff §6` V-2／本卡 §2B 各列）＋檔案 upload/download 無 CSU route（暫緩 track）＋XD 設計走查共通項。

**② 整合驗證（owner：dev/uat 整合測試）— 量大、非補碼**
- 主流程（is/iu/cs/cu 0110–0173）+ 契約頁（0910–0913）+ i0 全頁 FE↔BE `epl-*` DTO/授權各跑一次。
- z0 報表 00610/00620–00650 呈現。

**③ 🔴 撥貸 domain（owner：撥貸 domain + T24 + DBA）— 見 escalation doc**
- A-1 換匯 stub（**撥貸總開關、最優先**；OQ-2 精度✅已關 06-12）、B-1 `T24_COMPANY`（✅前提推翻→RD 接值）、換匯源 ID（=新庫兩 schema 選一）、檢核嚴格度、KHR、欄寬、async、M6 完工日 DTO 缺源。

**④ z0 半成品收尾（小修；owner：前後端）**
- `00300` Document Checklist：✅ **recon 坐實＋FE 導回已修 06-15**（recon `done/00300-return-recon.md`；fix `40d931c`，卡歸檔 `done/00300-return-fix.md`）——BE 非缺陷、FE 導回 ToDo 已實作（共用 `goPreviousPage()`）；DIFF-011 收。Phase V 驗共用方法連帶呼叫端語意。
- ✅ `00600` Search method 已修（sweep① `48e687f`；Phase V 補修 `GET + @RequestBody` regression，契約改 GET query 無 body）。

**④b 🟠 `00800` Revised Item（owner：RD 實作＋SA 取數）**
- ✅ D1–D5 硬缺陷已修（`88328f9`，2026-06-09；prompt 歸檔 `done/00800-fix-step1-tbd-independent.md`；QA-013/014/016/017 過、QA-012 rollback deferred-to-DB）。
- ✅ TBD-001~007 全裁（06-11，SRS v0.5）；✅ **RI-MAT 修復包 F1–F9 已落地**（product `5580eb7`，06-12 審過：isNotSame gate 移除、R13.1–13.3、R16 audit、R5 disabled、Finished、R14 checkpoint 對齊、R13.4/13.5 矩陣修正＋seqNo 括號 bug 加修；prompt 歸檔 `done/00800-rimat-fix.md`）。
- 仍開：**只剩 RP8/RP9/RP11**（06-12 三連關：RP10 DDL 枚舉、RP6 取數、RP4 設計非缺陷 → R13.4/13.5+R14+ITEM 名稱全定版，rimat 擴至 F1–F9）——**裁定內容單一出處＝`specs/srs/EPROZ00800/spec.md` §@PENDING**（視圖＝`pending-register.md`）；取證證據＝`build-tasks/done/00800-pending-recon-findings.md`（原 recon 卡歸檔 done/）。

**⑤ c0 escalation（owner：信用決策 domain）— 2 條**：E1 CU-return checkpoint（`:2985`）、E2 `crScoreCardCompleted` 覆寫（`:2890`）。

**⑥ 授權列（owner：DB/ops）**：✅ **SQL 全就緒**（`c0-authz-sql.sql`＋findings，precheck `203c375`＋00117 翻案補產 `78f0b51`，06-12 審過）——**32 mappings、預期 insert 16**（13＋00117 三列；使用者已裁「補」）、ROLE_TASK 8/8 已存在、NOT EXISTS 冪等；唯一 gap＝`epl-pxls-c0-financial-statement-comments`（i0 source 亦無列，UNSURE 交 ops）。卡已歸檔 done/。**下一步＝ops 照 findings『Ops Apply Checklist』簽核→以 `OVSLXLON02` 套用→Phase V 開門**（403 解除）。

**⑦ 暫緩 track（需先拍板）**：R2 報表服務（→0181/i0·c0 PDF/z0 PDF）、檔案上傳 API（→collateral/審批上傳）。〔CBC 已釐清＝頁內、非獨立 track〕

**⑧ 已裁**：`CS 0240` → **不開發**（2026-06-06 確認新系統無使用）。

**⑨ Tech-debt / ops**（✅ 靜態 sweep 三批已收齊，2026-06-09；prompt 全歸檔 `done/`）
- ✅ **FE/BE HTTP method 不一致 sweep**（`48e687f`）：00600 search-options、00640 export PDF/Excel FE→GET 對齊 BE；00600 Phase V 已補修為 GET query 無 body；00800 init-query 列 B 待裁定（按 SRS @PENDING 不動）。
- ✅ **map-key 大小寫 sweep**（`709f65c`）：A＝quote alias / 讀端對齊大寫（loan summary/collateral/guarantor/T24/loan-condition 等）；B/UNSURE＝SELECT * Map、無法靜態綁定者不猜。⚠️ **A 修正屬 runtime-silent 類 → Phase V 必複測**（compile 抓不到）。
- ✅ **Logback `D:\temp` 外部化**（`bbc4492`）：改 `${LOG_API_PATH:${LOG_PATH:logs}}` 等跨平台預設，appender/pattern/level 未動；連帶解掉 full `mvn clean package` 卡 D:\temp。
- ✅ **c0 staff 端點 cleanup 已完成**（`dcd9602`，2026-06-09；prompt 已歸檔 `done/c0-staff-endpoints-cleanup.md`）：刪 `epl-info/save-c0-financial-staff` + `CsuFinancialEvaluationStaffFiController` 整檔（+ staff DTO/serviceImpl、staff option/funcIsStaffLoan 依賴）；**保留** `CsuFinancialStaffController` 的 sele(list)/business method（00117 在用）、table-fi（00120）；i0 未碰；mvn + npm build 綠。

- 🟡 **命名 tech-debt（06-12 快檢記錄）**：`epl-comm-isu-update-total-amount`（+class/DTO）實為 case-type 無關（計算不落 DB；LDTC 副作用被 `LON_ATTRIBUTE='I'` gate 限定），corporate 沿用安全——rename 低優先、閒時清。

**⑩ audit 修復包（2026-06-11；owner：前後端）**：✅ 已修×5（`00660`/`00100`/`00119` `5a47038`/`2599752`/`6919da5`，06-11；**`00640` PDF `c1bda77`、`00300` FE 導回 `40d931c`，06-15**，卡全歸檔 `done/`）；F-7（00114 鈕隱驗證）入 Phase V；✅ **BIBLE-GAP recon 完成（AUD-5 關 06-15）**；待裁＝AUD-2/3/4/7/8/10/11（AUD-1/5/6/9 已關）。

---

## 5. 建議排程（依依賴與風險）— cross-check 後更新
> 新增 **Phase F（c0 評分前端）**。原則：先坐實缺口 →（驗證已完成 ‖ 補 c0 FE，可並行）→ 攻撥貸 domain → 暫緩 track 待決策。
> **✅ DB 連線已打通（2026-06-12）**——Phase V 全隊列解鎖。**解鎖順序**：① ✅ SQL 全就緒（含 00117 三列，見 ⑥）→**剩 ops 簽核＋以 `OVSLXLON02` 套用**（未套打 c0 endpoint 全 403）② ✅ RP6 取數完（14 名齊；RP4 順帶裁定=設計非缺陷，均已關 06-12）③ ✅ A-1 DB 端實查完（01=舊/02=新坐實、`EXCHANGR_RATE` 欄兩庫 DDL 皆無——OQ-1/OQ-5 證據入 `pending-register.md`，剩 owner 蓋章）④ Phase V 開跑（`verification-execution.md` 分階段；deferred-to-DB QA-007/008/009a/b/012/024/025、00119 三條必驗、00660 實測、map-key runtime 複測、M7/M9 確認點）——**只等 ① 的 ops 套用**。agent 自主驗 DB 時用**唯讀帳號**、帳密走環境變數不進 repo（CLAUDE.md §7）。

**Phase 0 — 坐實缺口（c0 FE ✅ 已坐實）**
0. ✅ c0 評分 FE 範圍已坐實（容器 + 8 子頁）；✅ `CS 0240` 裁定**不開發**。**Phase 0 清空。**

**Phase F — c0 評分前端 ✅ 收工（2026-06-09；owner：前端）**
1. ✅ corporate `credit-investigation` 容器（BE 驅動動態 tab + businessType G/F 分頁）。
2. ✅ 8 子頁 component/service（00112/114/115/116/117/118/119/120）各對接 `-c0-` endpoint + corporate DTO；00117/00120 business-only（決策 B）。
3. **剩**：納入 Phase V 驗證 + c0 新 endpoint 授權列（⑥）；staff 端點 cleanup（⑨）。

**Phase G — 企金主流程 FE 後半段（2026-06-11 audit 坐實；owner：前端；DB-無關可即做）**
2b. ✅ **完成 06-15**：`EPROCSU0160`(pilot)→`0150/0170(+popup)/0171/0172/0173` 照 isu 鏡像補建，對接既有 `Csu*` endpoints；卡已歸檔 `done/phase-g-csu-mainflow-fe.md`。**G1–G6 全審過、build 綠、BE 零改；殘留歸 Phase V runtime（`local-phase-v-bringup.md`）。**

**Phase V — 整合驗證（即刻，可與 Phase F 並行；owner：整合測試）**
3. 契約對齊 sweep：主流程 + i0 全頁 + 契約頁 FE↔BE DTO（真資料/真授權）。
4. z0 報表呈現；z0 半成品收尾（00300 return；✅ 00600 method 已修；00800 init-query method＝@PENDING 待 RD）。

**Phase D — 撥貸解鎖（關鍵路徑，owner：撥貸 domain）**
5. 🔴 **A-1 換匯 stub**（先「實作前調查」：匯率來源 API/表、舊取法、回傳結構）→ 端到端 → 驗 D1–D8 → B-1/T24 來源 → 精度（舊 DDL/DBA）。

**Phase E — c0 收尾 + 授權（owner：domain + DB/ops）**
6. c0 E1/E2 escalation 裁示；新 c0 endpoint 授權列。

**Phase R — 暫緩 track（待拍板，可獨立排）**
7. R2 報表服務 → 0181/i0·c0 PDF/z0 PDF；檔案上傳 API；FE/BE method-mismatch sweep；map-key sweep；Logback 外部化。

**關鍵路徑（兩條，2026-06-11 audit 後更新）**：① **撥貸上線 = Phase D（先 A-1 stub）**；② **企金申貸可用 = Phase G（主流程 FE 後半段；評分 Phase F 已收工）**。其餘 = **Phase V 驗證**＋§4⑩ 小修即可收。R2/檔案 = 獨立決策 track、不擋主里程碑。

---
> 維護：本檔為**對應/排程主表**；逐項狀態變動回填本檔 + 對應細節 doc（`verification-handoff` 驗證、`disbursement-*` 撥貸；`completion-ledger` 已凍結）。❓ 項一經唯讀盤點即升 ✅/🔴。
> **行紀律（2026-06-11 健檢）**：每列＝狀態 + 一行摘要 + 連結；裁定理由/過程敘事不入本檔（→ `decisions.md` 或該頁 bundle spec §@PENDING）。
