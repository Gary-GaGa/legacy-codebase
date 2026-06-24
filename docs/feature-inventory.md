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

**全局結論（zero-based audit 2026-06-11；總量表＝`build-tasks/refactor-audit/diff-vs-inventory.md`）**：166 audit 列基線＝116 碼在(70%)/11🟡/2🚫/37 UNFOUND → **06-15 校正後 ~133 碼在(80%)**（Phase F/G＋修復落地）。**已收口**：企金主流程 FE 後半段（Phase G G1–G6，§2B）、c0 評分 FE（Phase F，§2D）、i0 全模組（audit 22/22）。**真缺口＝🟠 撥貸**（A-1 換匯 stub ✅ 已實作；剩 T24 正確性 domain-gated＋批次層碼驗＋conformance，詳 §2F）。**待裁＝AUD-2/3/4/7/8/11**（AUD-1/5/6/9/10 已關）；UNFOUND 多為 M9 雜項（AUD-3/4）。

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
| EPROISU0922 | IS 0922 | **Disbursement Summary（authorize/T24）** | ✅ | 🟡 | **A-1 換匯 stub ✅ 已實作（§2F `daae4c3` 06-16）；B-1 `T24_COMPANY` owner signoff closed 06-22；殘＝T24 端到端/UAT** |
> 不開發：`EPROIS_0140`(Property Info) 已 drop。popup `0174/0175/0176`→`mat-dialog`（隨審批頁）。audit：`EPROIS_0240`/`EPROIU_0140`/`EPROIU_0240`→**AUD-1 ✅已關（06-16 owner 權威盤點標「已無使用」＝確認不遷）**。

### 2B. 企金主流程 `EPROCSU*`（M4 cs + M5 cu 合併）
| 新頁 | 合併舊 funcId | 名稱 | FE | BE | 剩餘 / 備註 |
|---|---|---|:--:|:--:|---|
| EPROCSU0110 | CS/CU 0110+0210 | Main Borrower（單 tab）| ✅ | ✅ | 🟡 驗證 |
| EPROCSU0120 | 0120+0220 | Co-Borrower | ✅ | ✅ | 🟡 驗證 |
| EPROCSU0130 | 0130+0230 | Guarantor | ✅ | ✅ | **✅ 2026-06-05 收尾（ng build 綠）** |
| EPROCSU0150 | 0150+0250 | Collateral（僅有擔；內層 3 tab：Info/Valuation/Site Visit）| ✅ | ✅ | ✅ FE 補建 G2（`14b254e`）；⏸ 檔案 API；Phase V 待測 |
| EPROCSU0160 | 0160+0260 | Loan Condition（+0261 popup）| ✅ | ✅ | ✅ FE 補建 G1（`809d25d`，pilot；+0261 popup）；Phase V 待測 |
| EPROCSU0170 | 0170+0270 | Credit Eval & Decision（+0174/0175 popup）| ✅ | ✅ | ✅ FE 補建 G3（`646e178`；+0174/0175 popup）；SRS in-review：`docs/specs/srs/EPROCSU0170/`（RP12-RP24 open，gate+AG PASS，待人審）；Phase V 待測（❓ 審批段細節 B1、CSU download route 無）|
| EPROCSU0171 | 0171 | Loan Committee Conclusion | ✅ | ✅ | ✅ FE 補建 G4（`8badefc`）；Phase V 待測（檔案 upload/download 無 CSU route）|
| EPROCSU0172 | 0172 | Approved Loan Condition | ✅ | ✅ | ✅ FE 補建 G5（`0ff2140`）；⏸ 列印 R2；Phase V 待測 |
| EPROCSU0173 | 0173 | Credit Evaluation Old | ✅ | ✅ | ✅ FE 補建 G6（`4429551`）；Phase V 待測 |
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
| EPROC00110 | 評分容器（corporate credit-investigation）| ✅ | ✅ | `epl-info/save-c0-credit-investigation-tab`（`CsuCreditInvestigationController`；Step 1 容器，BE 驅動動態 tab）；SRS in-review：`docs/specs/srs/EPROC00110/`（gate PASS；N 軸 2026-06-24 PASS：3🔴 已清，checkpoint polarity 定為 `Y`=pending/`N`=completed，補 `visibleTabs`/`sourceTabMap`/`pageMap`，`EPROCSU0160` 排除本頁契約；R9 0210 parity fail-fast 亦已清；仍 @PENDING/owner stamp，非 Approved）|
| EPROC00112 | CBC Banking Relationship | ✅ | ✅ | `epl-info/save-c0-cbc-banking-relationship`（`7e8aaf7`）；SRS in-review：`docs/specs/srs/EPROC00112/`（gate PASS；N 軸 2026-06-23 0🔴/6🟡，方向可推進；待人審）|
| EPROC00114 | Collateral Assessment | 🟡 | ✅ | `epl-sele/info/save-c0-collateral-assessment`（`62ec62f`；無 c0 calc→隱 Calc 鈕、分數 BE save 算）；audit F-7：calc handler 空 return——**Phase V 驗鈕真隱→可降回 ✅**；SRS in-review：`docs/specs/srs/EPROC00114/`（gate PASS；N 軸 2026-06-24 PASS：3🔴 已清，移除 phantom C0 calc contract，Rate 併 save-path 且 save input 不承載 BE-derived risk/date/score，補 NUMBER(7,2) 正向精度、`langType`、boundary、CVer、strict map QA；仍 @PENDING/owner stamp，非 Approved）|
| EPROC00115 | Borrower Group Exposure | ✅ | ✅ | `epl-sele/info/save-c0-borrower-group-exposure`（Step 1 BGE pilot）；授權列；SRS in-review：`docs/specs/srs/EPROC00115/`（gate PASS；N 軸 2026-06-23 **1🔴**/6🟡：`COMMON_MSG_TOTAL_FAIL` 契約⊥R9；orphan 錯誤碼；save 授權 deferred RP20；待修）|
| EPROC00116 | Financial Statement GI | ✅ | ✅ | `epl-*-c0-financial-statement-comments`（`524d8dc`；calc 保留、export POST-blob 兩邊一致、無 00640 式不符）；授權列；export 模板沿用 i0？；SRS in-review：`docs/specs/srs/EPROC00116/`（gate PASS；N 軸 2026-06-24 PASS：2🔴 已清，補 R11 BR-006 recalculation/hide Print-PDF，補 QA-016/017/018 for Finished balance gates；仍 @PENDING/owner stamp，非 Approved）|
| EPROC00117 | Financial Evaluation GI | ✅ | ✅ | **business-only ✅**（`b14ae05`，決策 B）：接 `epl-sele-c0-financial-list`、`epl-info/save-c0-financial-business`；未接 `-financial-staff`（cleanup）；SRS in-review：`docs/specs/srs/EPROC00117/`（RP26-RP38 open，gate+AG PASS，待人審）；授權列 |
| EPROC00118 | Corporate Scorecard | ✅ | ✅ | `epl-{sele(-list)/info/calc/save}-c0-corporateScorecard`; SRS Approved after 2026-06-20 RD/DBA contract closeout: four TB_API_AUTH rows direct-applied/rechecked, info DTO/status, save guard, parseScore fail-fast, UTC+8 scoreDatetime, numeric guard implemented. |
| EPROC00119 | Financial Statement FI | ✅ | ✅ | ✅ F-8 已修（`6919da5`，options 接 `epl-sele-c0-financial-statement-comments`）；SRS in-review：`docs/specs/srs/EPROC00119/`（RP40-RP54 open，gate+AG PASS，待人審）；**Phase V 必驗**：下拉有值+save 帶值+GI-sele 對 FI（businessType F）無分支影響；授權列；export 模板沿用 i0？|
| EPROC00120 | Financial Evaluation FI | ✅ | ✅ | **business-only ✅**（`6b084fb`，決策 B）：接 `epl-info/save-c0-financial-evaluation-table-fi`；i0 FI list 不消費→`getMenu()`回`of({})`；未接 `-staff-fi`（cleanup）；授權列；SRS in-review：`docs/specs/srs/EPROC00120/`（gate PASS；N 軸 2026-06-23 0🔴/4🟡，方向可推進；blocked on P-009/11/12/13）|
> **範本＝i0 `individual/credit-investigation`**（容器動態載 tab、各子頁 `components/<name>/{component,services}`；c0 鏡像、改 `-c0-` endpoint + corporate DTO）。
> ⚠️ **G/F businessType 分頁**：FE 容器須吃 BE 回的 `businessType`+`pageMap`（預設 G→移除 00119/00120、F→移除 00116/00117；save 依 businessType 更 checkpoint，`CsuCreditInvestigationServiceImpl:129/264/279/366`）。i0 容器本就動態（tabControl 來自 BE）→ 鏡像即自然涵蓋。
> ⚠️ audit（06-11）：舊源有 `EPROC0_0211/0213`（展期限定 FinEvalTable/Scorecard），新系統 FE/BE 全無→**AUD-2 待裁**（是否由 00116-00120 涵蓋；`refactor-audit/M7a-c0-00110-00115.md`）。
> **進度**：✅ Phase F 收工（容器+8 子頁，2026-06-09；過程 `build-tasks/done/phase-f-*`）；✅ `00117`/`00120`＝business-only（決策 B，證據見 `archive/decisions-2026H1-c0-audit.md`）。⚠️ **watch（Phase V）**：① calc 逐頁不同（00118/00116/00119 有、00112/00114 無已隱，勿誤套）② 實跑 G/F 切換 ③ 00112 totals / 00114 rating 唯讀語意對 BE。

### 2E. 共用 `EPROZ00*`（M8 z0）
| 新頁 | 名稱 | FE | BE | 剩餘 / 備註 |
|---|---|:--:|:--:|---|
| EPROZ00100 | TO DO LIST (+00101/00102 popup) | ✅ | ✅ | SRS Approved after 2026-06-20 RD/DBA contract closeout: eight TB_API_AUTH rows direct-applied/rechecked, B2 init redistribution, B3 one-time proposal download token, B4 session bridge, reason/range/docNo1 gaps implemented. |
| EPROZ00200 | New Case Application（進件入口）| ✅ | ✅ | ✅；案號序列細節未深入 |
| EPROZ00300 | Document Checklist | ✅ | ✅ | ✅ FE 導回已修（`40d931c`，共用 `goPreviousPage()`→ToDo、BE 零改非缺陷）。⚠️ **Phase V 驗**：共用方法連帶 Related Party/Revised Item 三呼叫端語意（日後回原入口需 originPage 分流）。次要待裁：APP_HISTORY=98/權限等價（UNFOUND）|
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
| EPROZ00800 | Revised Item | ✅ | ✅ | **SRS bundle Approved 2026-06-23**（規格定版軸；實作完成軸由 DoD 閘門牆另裁）。RP1–RP11/BP1–BP5 全 closed；機械閘門 PASS、N 軸 spec-reviewer 兩輪 0🔴/0🟡。Implementation closeout 全綠：GET query、`isCorporateUnsecured`、backend mutation guard 已實作並測過；`TB_API_AUTH` query/save SELECT-only PASS；R7 `TB_PAGE_COLUMN_AUTH_DETAIL.reason.item` backfill 06-23 DBA/RD 套用、closeout 重跑 `PAGE_COLUMN_RESULT=PASS`/`MATCHED_ROWS=4`。 |
> 共用 API `EPROZZ_0100`（查地址欄位選單）。

### 2F. 撥貸 `EPROISU0920/0921/0922` + T24（🔴 唯一真未完成區塊）
| 區 | 狀態 | 內容 |
|---|---|---|
| 機械修正 M1–M10 | ✅ 全結案（master） | 尾欄/submit mail/RECEIVED_DATE/C20/fee key/E 位/H 段/A52/fee-delete-FN |
| ✅ **A-1 換匯 stub（+conformance PASS）** | **已實作＋碼驗（product `daae4c3`，06-16；mvn 綠）** | `funcGetExchangeRate` 補 return → authorize 換匯打通；**Codex conformance 4/4 PASS**（OQ-1 `OVSLXLON01`／OQ-3 `FAILED_E304` 中止／OQ-4 throw／兩表同交易）；規格/recon `done/` |
| ✅ B-1 `T24_COMPANY`（06-22 closed）| **RD 已接值＋owner 確認沿用** | 新庫 `TB_BRANCH_PROFILE.T24_COMPANY` 實存（OVSLXLON01/02 兩 schema，new DB reverify=`VARCHAR2(5)`）；entity 已補映射並對齊 T24 欄位長度，B8/C9 已接值且缺 row/缺值不落空白；owner 06-22 確認無另設 T24 contract override，沿用 legacy/current source |
| ✅ T24 B-group parity（06-17） | **code 已 commit/push（`3d6f446`，origin/master，06-17 10:41；金錢/截斷欄人審過）；剩端到端/T24 接收驗證** | B-2、B-3 非幣別欄、B-4、B-5 已照舊；`E21`、`G4`/`G10`/`H8` 依 A-5 USD+KHR-only 邊界 keep。findings：`build-tasks/done/t24-bgroup-legacy-parity-fix-findings.md` |
| 🟢 撥貸 domain | code 已裁／SRS Approved | A-4/M6/B-1 `T24_COMPANY`/KHR G·H code 已裁；**06-20 T24/A-4/M6 SRS-層 re-open → 06-22 SRS 產收口 → 06-23 0921/0922 兩 bundle Approved（gate PASS、N 軸 A–G PASS、cross-model spec-reviewer 0/0、D 軸 backend closeout 驗、owner stamp）：0922 T24_COMPANY entity 對齊+FAILED_E999、0921 core 舊+law firm REF-D3/M6 REF-D4 偏新**；剩 T24 端到端 UAT + E1/E2。 |
| ✅ **批次層 B001–B008** | **AUD-10 結（06-16，app 層完整）** | ✅ **6 FOUND**（新批次**重編號**≠legacy；B001-B007 對映見 findings）；✅ **B005 銷案**（inline 換匯取代每日批次、`TB_EXCHANGE_RATE` write-only）；⚪ **B008 log＝ops**。詳 `done/aud10-batch-layer-reverify-findings.md` |
| 整合測確認點 | 待驗 | 〔A-1 spec-conformance ✅ PASS 06-16〕M7 facility fee 值、M9 district name join、撥貸端到端（含批次層）|
> **完整歷史裁定見 [`disbursement-domain-escalations.md`](disbursement/disbursement-domain-escalations.md)。** ✅ **A-1 stub 已實作（`daae4c3`）→ 機械修正不再 inert、authorize 可端到端跑**；B-1 `T24_COMPANY`、A-4/M6 domain、KHR G/H 來源皆已裁定並落文件；剩撥貸真完成＝T24 B-group 端到端/T24 接收驗證（code 已 push `3d6f446`）與 UAT。

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
| R7 | **權限三表遷移**（`TB_FUNCTION_AUTH`/`TB_API_AUTH`/`TB_ROLE_TASK`）| 🟡 進行 | c0 endpoint 授權列 **SQL 已備齊**（`c0-authz-sql`）、**剩 ops 套 `OVSLXLON02`**（見 §4⑥）|
| R8 | CBC 聯徵資料接入 | 🟢 **釐清：非獨立 adapter** | CBC = 頁內 banking relationship（i0 已做；c0 FE 缺）；**無外部 adapter track** |
| — | **檔案上傳/下載 API** | ⏸ **待設計** | collateral 0150、審批 0170/0171/0173 上傳 |
| — | **FE/BE HTTP method 不一致** | ✅ sweep 收齊 | `48e687f`：00600/00640 對齊；00600 Phase V 補修 GET body regression；00800 init-query 已改為 GET query |

---

## 4. 剩餘事項彙整（= 還有多少事要做）— cross-check 後更新（2026-06-06）
> 🔗 **所有 open 決策/待決（@PENDING/escalation/OQ）的單一總表**＝[`pending-register.md`](pending-register.md)（誰欠裁定、卡什麼）。下面 ③⑤⑦ + ④b 的待決都登錄在那。
> ✅ **全量 zero-based 重盤完成（2026-06-11）**：結果＝`build-tasks/refactor-audit/diff-vs-inventory.md`（DIFF-001~016＋BIBLE-GAP-1~5）＋QC＝`build-tasks/refactor-audit-qc.md`（F-1~F-12）。**本檔已套用回填**；待裁＝AUD-1~5（`pending-register.md`）。
> **翻案**：新增 **c0 評分前端真缺口**（原以為前端全完）。❓ 多已坐實（i0/契約/多數 z0 ✅）。

**① ✅ c0 評分前端（Phase F 收工 2026-06-09；owner：前端）— 原本次最大缺口、已補齊**
- ✅ **整組已建齊＝1 容器 + 8 子頁**（00112/00114/00115/00116/00117/00118/00119/00120；c0 無 00111/00113）。00117/00120 為 **business-only**（決策 B）。
- **剩（非 coding）**：納入 Phase V 整合驗證 + c0 新 endpoint 授權列（見 ⑥）；staff 端點 cleanup（見 ⑨）。

**①b ✅ 企金主流程 FE 後半段（Phase G 全收口 06-15；audit F-1/DIFF-001；owner：前端）**
- 原況：六頁＋3 popup（0174/0175/0261）FE 全缺、BE `Csu*Controller` 全在 → **G1–G6 全 ✅**（0160+0261/0150/0170+popup/0171/0172/0173；審過、build 綠、BE 零改；各 commit 見 §2B 各列）。
- 卡已歸檔 `build-tasks/done/phase-g-csu-mainflow-fe.md`。**殘留＝Phase V runtime 待測**（見 `verification-handoff §6` V-2／本卡 §2B 各列）＋檔案 upload/download 無 CSU route（暫緩 track）＋XD 設計走查共通項。

**② 整合驗證（owner：dev/uat 整合測試）— 量大、非補碼**
- 主流程（is/iu/cs/cu 0110–0173）+ 契約頁（0910–0913）+ i0 全頁 FE↔BE `epl-*` DTO/授權各跑一次。
- z0 報表 00610/00620–00650 呈現。

**③ 🟡 撥貸 domain（code 決策清 06-17；T24/A-4/M6 06-20 SRS-層 re-open → 06-22 SRS 已產收口 In Review）— 見 escalation doc + pending 列 14/15**
- ✅ A-1 換匯 stub 已實作+conformance PASS（`daae4c3` 06-16）；✅ A-2 換匯源 ID＝`OVSLXLON01`；✅ B-1 `T24_COMPANY`→B8/C9 沿用 `TB_BRANCH_PROFILE.T24_COMPANY`、RD 已接值（entity 對齊+FAILED_E999）且 owner 06-22 確認無另設 override；A-4 檢核 / M6 完工日 / KHR G·H 來源 06-17 code 裁照舊；✅ T24 B-group commit/push（`3d6f446`）、批次層 AUD-10 結。
- **06-20 SRS-層 re-open → 06-22 產 0921/0922 SRS bundle → 06-23 兩 bundle Approved**（`check-srs-bundle` PASS、N 軸 A–G PASS、cross-model spec-reviewer 0 Blocker/0 Should-fix、D 軸 backend closeout 驗、owner stamp）：0922 T24 殘欄 TBD-007/008 closed（T24_COMPANY entity 對齊）；0921 core 維持舊 baseline、law firm `REF-D3`/M6 `REF-D4` 命中偏新。**殘＝T24 端到端 UAT + E1/E2（信用決策 domain）**。

**④ z0 半成品收尾（小修；owner：前後端）**
- `00300` Document Checklist：✅ **recon 坐實＋FE 導回已修 06-15**（recon `done/00300-return-recon.md`；fix `40d931c`，卡歸檔 `done/00300-return-fix.md`）——BE 非缺陷、FE 導回 ToDo 已實作（共用 `goPreviousPage()`）；DIFF-011 收。Phase V 驗共用方法連帶呼叫端語意。
- ✅ `00600` Search method 已修（sweep① `48e687f`；Phase V 補修 `GET + @RequestBody` regression，契約改 GET query 無 body）。

**④b 🟠 `00800` Revised Item（owner：RD 實作＋SA 取數）**
- ✅ D1–D5 硬缺陷已修（`88328f9`；卡 `done/00800-fix-step1-tbd-independent.md`）。
- ✅ TBD-001~007 全裁（06-11）；✅ **RI-MAT 修復包 F1–F9 落地**（`5580eb7`，06-12 審過；卡 `done/00800-rimat-fix.md`）。
- SRS 重產：`docs/specs/srs/EPROZ00800/` 已回填 `in-review`；RP8/RP11/BP1-5 已裁入。
- Implementation closeout：code/test/build 已通；`TB_API_AUTH` final query/save rows SELECT-only PASS。仍開：R7 page-column DB config 缺 `reason.item`，待 DBA/RD 套 `docs/build-tasks/00800-contract-closeout-authz-backfill.sql` 或等價修正後重跑 `docs/build-tasks/00800-contract-closeout-authz.sql`。

**⑤ c0 escalation（owner：信用決策 domain）— 2 條**：E1 CU-return checkpoint（`:2985`）、E2 `crScoreCardCompleted` 覆寫（`:2890`）。

**⑥ 授權列（owner：DB/ops）**：✅ **SQL 全就緒**（`c0-authz-sql.sql`，06-12 審過）——32 mappings/預期 insert 16、冪等；唯一 gap＝`epl-pxls-c0-financial-statement-comments`（UNSURE 交 ops）。**下一步＝ops 簽核→以 `OVSLXLON02` 套用→Phase V 開門**（403 解除）。

**⑦ 暫緩 track（需先拍板）**：R2 報表服務（→0181/i0·c0 PDF/z0 PDF）、檔案上傳 API（→collateral/審批上傳）。〔CBC 已釐清＝頁內、非獨立 track〕

**⑧ 已裁**：`CS 0240` → **不開發**（2026-06-06 確認新系統無使用）。

**⑨ Tech-debt / ops**（✅ 靜態 sweep 三批已收齊，2026-06-09；prompt 全歸檔 `done/`）
- ✅ **FE/BE method sweep**（`48e687f`）：00600/00640 FE→GET 對齊 BE；00600 Phase V 已補 GET query 無 body；00800 init-query 已在 implementation closeout 改為 GET query。
- ✅ **map-key 大小寫 sweep**（`709f65c`）：讀端對齊大寫；SELECT * Map 不靜態猜。⚠️ **A 修正 runtime-silent → Phase V 必複測**（compile 抓不到）。
- ✅ **Logback `D:\temp` 外部化**（`bbc4492`）：改 `${LOG_API_PATH:${LOG_PATH:logs}}` 等跨平台預設，appender/pattern/level 未動；連帶解掉 full `mvn clean package` 卡 D:\temp。
- ✅ **c0 staff 端點 cleanup**（`dcd9602`）：刪 staff controller/DTO/serviceImpl；**保留** 00117 用的 sele/business、00120 table-fi；i0 未碰。詳 `done/c0-staff-endpoints-cleanup.md`。

- 🟡 **命名 tech-debt（06-12 快檢記錄）**：`epl-comm-isu-update-total-amount`（+class/DTO）實為 case-type 無關（計算不落 DB；LDTC 副作用被 `LON_ATTRIBUTE='I'` gate 限定），corporate 沿用安全——rename 低優先、閒時清。

**⑩ audit 修復包（2026-06-11）**：✅ 已修×5（00660/00100/00119/00640/00300，卡全歸檔 `done/`）；F-7（00114 鈕隱驗證）入 Phase V；✅ BIBLE-GAP recon（AUD-5 關 06-15）；**待裁＝AUD-2/3/4/7/8/11**（AUD-1/5/6/9/10 已關）。

---

## 5. 建議排程（依依賴與風險）— cross-check 後更新
> 新增 **Phase F（c0 評分前端）**。原則：先坐實缺口 →（驗證已完成 ‖ 補 c0 FE，可並行）→ 攻撥貸 domain → 暫緩 track 待決策（spec 層 PRD→SRS 重產＝前置就緒、owner local 並行）。
> **✅ DB 連線已打通（2026-06-12）**——Phase V 解鎖。①②③（SQL 就緒/RP6 取數/A-1 DB 實查）✅ 06-12；**只等 ① ops 以 `OVSLXLON02` 套用**（未套 c0 endpoint 全 403）→ ④ Phase V 開跑（`verification-execution.md`；deferred-to-DB QA 群、00119 三條、map-key runtime 複測、M7/M9）。agent 驗 DB 用唯讀帳號、帳密走環境變數（CLAUDE.md §7）。

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
4. z0 報表呈現；z0 半成品收尾（00300 return；✅ 00600 method 已修；00800 init-query method 已修；00800 R7 `reason.item` DB backfill 待 RD/DBA）。

**Phase D — 撥貸解鎖（關鍵路徑，owner：撥貸 domain）**
5. 🟠→✅ **撥貸解鎖**：A-1 換匯 ✅ 已實作+conformance PASS（`daae4c3`）、批次層 AUD-10 結、T24 照舊 commit/push（`3d6f446`）、殘 domain 06-17 全裁照舊 → **剩端到端/T24 UAT**（非 coding；精度 C-1 已關＝舊=新無落差）。

**Phase E — c0 收尾 + 授權（owner：domain + DB/ops）**
6. c0 E1/E2 escalation 裁示；新 c0 endpoint 授權列。

**Phase R — 暫緩 track（待拍板，可獨立排）**
7. R2 報表服務 → 0181/i0·c0 PDF/z0 PDF；檔案上傳 API；FE/BE method-mismatch sweep；map-key sweep；Logback 外部化。

**Phase S — spec 層（PRD→SRS 重產；owner：PM/SA + Codex local；並行 track）**
8. Phase S status: SRS bundle coverage **5/67**; `EPROZ00100`, `EPROC00118`, `EPROISU0921`, `EPROISU0922`, and `EPROZ00800` are Approved (0921/0922 owner-stamped 2026-06-23 after N-axis A–G PASS + cross-model spec-reviewer 0/0; 00800 Approved 2026-06-23 after R7 `reason.item` page-column backfill + closeout re-run PASS, mechanical gate PASS, two-round spec-reviewer 0🔴/0🟡). Next expansion follows risk tier (corporate line). **決策頁 SRS 產出佇列 live＝`build-tasks/refactor-audit/per-page-reinventory-matrix.md §ledger`（逐頁列）；規劃展開視圖已歸檔 `archive/srs-production-queue-2026-06-20.md`**；企金線 18 頁 `prd-ready` 前須先有 `c0-legacy-parity-recheck` 碼驗餵入。

**關鍵路徑（兩條，2026-06-11 audit 後更新）**：① **撥貸上線 = Phase D（先 A-1 stub）**；② **企金申貸可用 = Phase G（主流程 FE 後半段；評分 Phase F 已收工）**。其餘 = **Phase V 驗證**＋§4⑩ 小修即可收。R2/檔案 = 獨立決策 track、不擋主里程碑。**spec 層（PRD→SRS 重產，Phase S）= 前置就緒、owner local 並行 track，不擋當前里程碑，但為 00800/企金線 rebuild 的上游**。

---
> 維護：本檔為**對應/排程主表**；逐項狀態變動回填本檔 + 對應細節 doc（`verification-handoff` 驗證、`disbursement-*` 撥貸；`completion-ledger` 已凍結）。❓ 項一經唯讀盤點即升 ✅/🔴。
> **行紀律（2026-06-11 健檢）**：每列＝狀態 + 一行摘要 + 連結；裁定理由/過程敘事不入本檔（→ `decisions.md` 或該頁 bundle spec §@PENDING）。
