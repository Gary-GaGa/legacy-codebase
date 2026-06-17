# 舊→新 頁面對應 & 補完清單（控制中心）

> 重構專案（前後端兩個獨立專案）已完成 **~70%**；目標 = 補完剩餘 **30%**。
> ⚠️ 原始碼**不外流、不上 GitHub**：本 repo 只放**對應/規格/backlog**；實作在前/後端專案內（Copilot 或本機 Claude Code），以本檔規格 + 既有 70% 模式為準。

## 0. 合併規律（新頁如何由舊頁合併）
- **有擔(S) + 無擔(U) → 單一新頁(SU)**：`EPROCS_*`+`EPROCU_*`→`EPROCSU*`；`EPROIS_*`+`EPROIU_*`→`EPROISU*`。
- **新案/增貸 + 展期/展變 → 同一新頁**：`_01x0`(申請) + `_02x0`(展期/覆核) 合成一頁，以**案件類型**當 mode。
- 新頁名 = 舊 funcId 去底線（`EPROC0_0110`→`EPROC00110`）；主流程 CS+CU→CSU、IS+IU→ISU。
- → 完全對應我們的 shell 設計：**案件類型(新案增貸/展期展變) × 有擔/無擔** 即 PageDescriptor 的 mode/secure 軸（`module-is-iu-shell.md`、`module-cs-cu-shell.md`）。

## 1. 新頁 catalog（= 補完目標；狀態待對兩專案後回填）

### 1A. 個金主流程 `EPROISU*`（IS+IU 合併）
| 新頁 | 合併舊 funcId | 名稱 |
|---|---|---|
| EPROISU0110 | IS/IU_0110 + _0210 | Main Borrower Info |
| EPROISU0120 | IS/IU_0120 + _0220 | Co-Borrower Info |
| EPROISU0130 | IS/IU_0130 + _0230 | Guarantor Info |
| EPROISU0140 | **IS_0190 + 0290** | Collateral Provider Info（佔用舊 0140 槽）|
| EPROISU0150 | IS_0150 + 0250 | Collateral（僅有擔）|
| EPROISU0160 | IS/IU_0160 + _0260 | Loan Condition |
| EPROISU0170 | IS/IU_0170 + _0270 | Credit Evaluation and Credit Decision |
| EPROISU0171 | IS/IU_0171 | Loan Committee Conclusion |
| EPROISU0172 | IS/IU_0172 | Approved Loan Condition |
| EPROISU0173 | IS/IU_0173 | Credit Evaluation Old |
| EPROISU0181 | IS/IU_0181 | TLOD Report（R2 報表）|
| EPROISU0910 | IS_0910 | Contract Preparation（頁框）|
| EPROISU0911 | IS_0911 | Condition Confirmation |
| EPROISU0912 | IS_0912 | Contract Production |
| EPROISU0913 | IS_0913 | Closed Info |
| EPROISU0920 | IS_0920 | Disbursement Process（頁框）|
| EPROISU0921 | IS_0921 | Data Input |
| EPROISU0922 | IS_0922 | Summary |

### 1B. 企金主流程 `EPROCSU*`（CS+CU 合併）
| 新頁 | 合併舊 funcId | 名稱 |
|---|---|---|
| EPROCSU0110 | CS/CU_0110 + _0210 | Main Borrower Info |
| EPROCSU0120 | CS/CU_0120 + _0220 | Co-Borrower Info |
| EPROCSU0130 | CS/CU_0130 + _0230 | Guarantor Info |
| EPROCSU0150 | CS_0150 + 0250 | Collateral（僅有擔）|
| EPROCSU0160 | CS/CU_0160 + _0260 | Loan Condition |
| EPROCSU0170 | CS/CU_0170 + _0270 | Credit Evaluation and Credit Decision |
| EPROCSU0171 | CS/CU_0171 | Loan Committee Conclusion |
| EPROCSU0172 | CS/CU_0172 | Approved Loan Condition |
| EPROCSU0173 | CS/CU_0173 | Credit Evaluation Old |
| （CAD）| CS/CU_0181 | TLOD(CAD) Report → 對映 **EPROISU0181**（與個金共用報表頁）|

### 1C. 個金評分 `EPROI00*`（i0，新案+展期合併）
`EPROI00110`(Credit Investigation 頁框)、`00111` Financial Evaluation Table、`00112` CBC、`00113` Individual Scorecard、`00114` Collateral Assessment、`00115` Borrower Group Exposure、`00116` Financial Statement GI、`00117` Financial Evaluation GI、`00118` Corporate Scorecard、`00119` Financial Statement FI、`00120` Financial Evaluation FI。

### 1D. 企金評分 `EPROC00*`（c0）
`EPROC00110`(頁框)、`00112` CBC、`00114` Collateral Assessment、`00115` BGE、`00116` FinStmt GI、`00117` FinEval GI、`00118` Corporate Scorecard、`00119` FinStmt FI、`00120` FinEval FI。
- ⚠️ `EPROC0_0211`、`EPROC0_0213`：**「流程中無對應頁籤」** → 待確認（c0 無個人 scorecard/FinEval Table，與 i0 差異）。

### 1E. 共用 `EPROZ00*`
`00100` TO DO LIST、`00200` New Case Application、`00300` Document Checklist、`00400` Case Distribution、`00410` Related Party Information、`00500` Comparison table…CUBC、`00600` Search、`00610` Credit Reviewer On Hand Status、`00620` Application Delete Report(R2)、`00630` Deviation Case Report(R2)、`00640` Scorecard Report(R2)、`00650` Application Cancel Report(R2)、`00660` CAD On Hand Status、**`00700` Assign Substitute（= 我們的 Phase 1）**、`00800` Revised Item。
> 前端狀態（2026-06-04 Codex 逐頁盤點校正）：`00610` 本期實作（待整合驗證）；`00620`/`00630`/`00640`/`00650` 報表頁**頁面結構已完成**（module/routing/component/service/config 齊全，僅 `spec.ts` 為樣板）→ 待整合驗證、**非從零**；`00660` CAD On Hand 已完成（即 CR 範本）；**`00700` Assign Substitute = 既有 `pages/deputy` feature，已完整實作**（清單+查詢+新增彈窗+刪除+role 驅動+options 動態載入；route `/deputy`、breadcrumb `E_DEPUTY`、選單來自後端 `epl-auth-menutree`）。→ **前端已無「從零新建」頁**；`EPROCSU0130` 已於 2026-06-05 收尾（ng build 綠）→ **前端全數完成**。

### 1F. 特例（不開發）
- **對應重構頁空白**（已合併上去）或標 **「已無使用」** → **不開發**。
- 已無使用（drop）：`EPROCS_0240`（公司核心資料，✅ 2026-06-06 owner 確認新系統無使用）、`EPROIS_0140`（Property Info）。
- 待確認：`EPROC0_0211`、`EPROC0_0213`（流程中無對應頁籤）。
- 共用 API：`EPROZZ_0100`（查詢地址欄位選單）。
- `EPROISU0181` 同時是企金 CAD 報表的對映頁（個/企共用）。

## 2. 剩餘 30% 補完 backlog（✅ 前後端 cross-check 已對齊）
> 對齊兩份後原列「前端 8 項 + 後端 7 項」。**2026-06-04 Codex 逐頁盤點校正**：`00610` 本期完成；報表 `00620–00650`+`00660` **結構已完成**；`00700` = 既有 `pages/deputy` **已完整實作** → 前端**僅剩 `EPROCSU0130` 半成品收尾**（無從零新建頁；`EPROCSU0130` 已於 2026-06-05 收尾 → 前端全數完成）。後端 6 個企金評分 controller 全數結清 → **真正 30% 缺口只剩撥貸 `0920`**。

### 2A. 前端要補（後端多已就緒）
| 新頁 | 名稱 | FE | BE | 補法（打既有 endpoint）|
|---|---|---|---|---|
| `EPROZ00700` | Assign Substitute | ✅已完成（= `pages/deputy`）| ✅ `DeputyController` | 既有 `pages/deputy` 已完整串 `epl-case-deputy-options/-query-deputy/-insert-deputy/-delete-deputy`，role 驅動、options 動態載入 → **不需新建**；嚴謹可做「deputy ↔ 00700 規格 gap-check」（欄位/role/流程差異、route 命名）。|
| `EPROZ00610` | Credit Reviewer On Hand Status | ✅實作（待整合驗證）| ✅ | **onhand-status 子頁**（在 `case-assignment/sub-pages/onhand-status/credit-reviewer-onhand-status`）：比照雙胞胎 `cad-onhand-status`、共用 `base-onhand-status`、既有 route。Codex 補共用 base 的 error handling；build 綠、結構對齊 CAD。**呈現/資料待整合測試（dev/uat 後端）**。→ `epl-case-credit-reviewer-onhandstatus-query-list` |
| `EPROZ00660` | CAD On Hand Status | ✅已完成（CR 範本）| ✅ | `cad-onhand-status` 完整實作，本身即 `00610` 的範本 → **不需開發**。→ `epl-case-CAD-onhandstatus-query-list` |
| `EPROZ00620` | Application Delete Report | ✅結構完成（待整合驗證）| ✅ | `application-delete-report` 已接 module/routing/component/service/config，繼承 `base-application-report`（與 cancel 雙胞胎）→ **不需開發**。→ `epl-case-application-delete-report-btn-search/-query-list` |
| `EPROZ00630` | Deviation Case Report | ✅結構完成（待整合驗證）| ✅（含 download）| `deviation-case-report` 已含查詢/統計卡/表格/Excel export/選單；無共用 base → **不需開發**。→ `epl-list-deviation`/`-file-download-deviation`/`-sele-dept-loantype-deviation` |
| `EPROZ00640` | Scorecard Report | ✅結構完成（待整合驗證）| ✅（含 pdf/excel export）| `scorecard-report` 已含 radio 動態欄位/footer/Excel+PDF export → **不需開發**。⚠️**整合風險**：前端 export 用 POST blob，後端 controller 宣告 GET `@RequestBody`，介面風格不一致 → 整合測試時優先驗。→ `epl-case-mis-report-scorecard-query-list`/`-export-pdf`/`-export-excel` |
| `EPROZ00650` | Application Cancel Report | ✅結構完成（待整合驗證）| ✅ | `application-cancel-report` 已接全套，繼承 `base-application-report`（最乾淨的報表範本）→ **不需開發**。→ `epl-sele-dept-loantype-canreason`/`epl-list-cancelreport` |
| `EPROCSU0130` | Corporate Guarantor Info | ✅實作（待整合驗證）| ✅ `CsuGuarantorController` | **✅ 2026-06-05 收尾完成（`ng build` 綠、3 檔）**：4 項全修——① `getGuarantorCorpResume()` 端點 `epl-resu-isu-guarantor`→`-csu-`（全檔掃 `-isu-/-iu-/-is-/-i0-` 僅此 1 筆、已清）② api.service/`getData()` 補 `catchError`+`finalize` loading reset（對齊 twin，失敗回空 DTO 不灌 mock）③ popup `enumGuarantor` 改引 corporate model ④ 狀態維持與個金 twin `EPROISU0130` 同級（未 gold-plate）。**裁決保留**：本頁＝案件編輯流程子頁，oracle＝twin、非 deputy 樣板（deputy 缺項豁免）。|

### 2B. 後端要補（前端多已就緒）
| 新頁 | 名稱 | FE | BE | 補法（鏡像既有）|
|---|---|---|---|---|
| `EPROISU0920` | Disbursement Process | ✅ | ⚠️ **端點在、核心未完成（2026-06-05 更正）** | **「BE 未做」係 stale**——0920 為頁框，API 落在 `0921 DataInputController`(6 端點)+`0922 SummaryController`(4 FE-used)，**已服務 FE 全部 9 個 `epl-*`**（後端為超集）。裁決：方案 A 認列既有、不新建 0920 facade。⚠️ **但舊系統比對（2026-06-05）推翻「結構到位＝完成」**：🔴 `0922 authorize` 換匯 `funcGetExchangeRate`（`FunctionServiceImpl:1221`）是 throw-stub → **執行核心（換匯→T24→SFTP→定案）未完成、從未端到端跑過**〔**2026-06-16 更正：A-1 換匯 stub 已實作（`daae4c3`）、authorize 可端到端跑；剩 T24 UAT，撥貸殘 domain 06-17 全裁照舊**〕；`0921` 7P/15F/5U、`0922-main` 另有真 bug（匯率源 ID、submit mail 空、history 碼）。詳 [`verification-handoff.md`](../verification/verification-handoff.md) §2.1/§2.2，triage 06-17 收斂（殘＝T24 UAT）。cleanup 候選：`/epl-case-submit-isu-summary` stub（FE 未用）。|
| `EPROC00115` | c0 Borrower Group Exposure | ✅ | ✅實作（待整合驗證）| 🟢**c0 範本完成（build 綠）**：新增 `CsuBorrowerGroupExposureController`/`Service(Impl)`/DTO（7 新檔、0 改既有）；endpoint `epl-info/save/sele-c0-borrower-group-exposure`；DTO 1:1 鏡像 i0（僅改 class/package，JSON property 不變）；checkpoint→`Cs/Cu.EPROC00115`（`isFinish` true→"N"/false→"Y"）；重用既有 entity/repo、未動 i0/既有 `Csu*`。CS/CU 判斷（`lonAttribute+secureAttribute`）經 code review **確認＝雙分流頁 `CsuCreditInvestigationServiceImpl`/`CsuMainBorrowerInfoServiceImpl` 同款（正確）**。**待驗**：新 endpoint 的 `TB_API_AUTH`/`TB_ROLE_TASK` 授權列。|
| `EPROC00116` | c0 Financial Statement GI | ✅ | ✅實作（待整合驗證）| **build 綠**。新增 `CsuFinancialStatementController`/`Service(Impl)`/15 DTO；7 endpoint `epl-{sele/quer/info/calc/save/ppdf/pxls}-c0-financial-statement-comments`；**自足鏡像** i0（不注入/不反射/不委派 i0），checkpoint→`Cs/Cu.EPROC00116`；重用 4 個 FinStmt GI entity/repo。曾修 CJK 編碼壞檔（`ServiceImpl` 418 處字串常數+大量註解，已 strict-UTF-8 驗）。**待驗**：export 模板沿用 i0 `EPROI00116` 是否可接受 / `TB_API_AUTH` 授權列。|
| `EPROC00117` | c0 Financial Evaluation GI | ✅ | ✅實作（待整合驗證）| **2026-06-05 唯讀 audit 確認：既有 `CsuFinancialStaff*`/`csuFinancialStaff` 模組已滿足 00117 規格（缺無、錯無）**——5 端點 `-c0-` 齊、**只取 00117 分支（無 00120/`-financial-evaluation-staff-fi` 夾帶）**、INFO/INFO_S/GI 三組接齊、`info-financial-business` 算 ratios `saveAll` 寫回 GI 的 side-effect 保留、checkpoint `Cs/Cu.EPROC00117`（`isFinish?"N":"Y"`、CS/CU 用 `lonAttribute+secureAttribute`）、DTO `@JsonProperty` 1:1、UTF-8/無 BOM、無 reflection/委派/`*.individual.*`（負向 grep 未命中）。sele 用 `commonFunctionService.funcIsStaffLoan`（`service.common`，**允許**）。**結論：早已完成**（先前 cross-check 誤判為「缺」）。|
| `EPROC00118` | c0 Corporate Scorecard | ✅ | ✅實作（待整合驗證）| **build 綠 + verify-c0 PASS + 獨立語意審查 9 PASS（2026-06-05）**。新增 `CsuCorporateScorecardController`/`Service(Impl)`/DTO/enum/assembler（純新增、0 改既有）；4 endpoint `epl-{sele/info/calc/save}-c0-corporateScorecard(-list)`；calc **注入 `FunctionService.funcGetRate`**（§6.1 唯一例外，未複製/重寫算法，餵入 22 欄 request 經審逐欄對齊 i0）；checkpoint→`Cs/Cu.EPROC00118`（CS/CU 用 `lonAttribute+secureAttribute`、`isFinish?"N":"Y"`、只寫一邊）；`crScoreCardCompleted` 只動第2碼、`loanDefDayFlag=Y→Default/-1` 皆照 i0；strict-UTF-8 12 新檔。⚠️ **2 條 escalation**（CU-return、crScoreCardCompleted 整欄覆寫）見下方清單。詳見 `build-tasks/done/EPROC00118-corporate-scorecard.md`、boundary bundle。|
| `EPROC00119` | c0 Financial Statement FI | ✅ | ✅實作（待整合驗證）| **build 綠**。新增 `CsuFinancialStatementCmtsFiController`/`Service(Impl)`/9 DTO；6 endpoint（無 sele）`epl-{quer/info/calc/save/ppdf/pxls}-c0-financial-statement-cmts-fi`；**自足鏡像** i0；checkpoint→`Cs/Cu`：`doCalc` `00119="Y"`、`doSave` `00119=isFinish?"N":"Y"` **且 `00120="Y"`**（鏡像 i0 跨頁副作用，同一條 CS/CU row）；重用 4 個 FinStmt FI entity/repo；strict-UTF-8 12/12。**待驗**：`TB_API_AUTH` 授權列 / export 模板沿用 i0 `EPROI00119`。|
| `EPROC00120` | c0 Financial Evaluation FI | ✅ | ✅實作（待整合驗證）| **build 綠**。照 i0 **拆兩支**：`CsuFinancialEvaluationTableFiController`（info/save table）+ `CsuFinancialEvaluationStaffFiController`（save staff-fi）；3 endpoint `epl-{info/save}-c0-financial-evaluation-table-fi`、`epl-save-c0-financial-evaluation-staff-fi`；**自足鏡像**（含 i0 `ValidateWhenFinish` 驗證類）；staff-fi **只取 00120 那條 URI 分支、未夾帶 00117**；兩個 save 都只寫 `Cs/Cu.EPROC00120`（`isFinish` false→"Y"/true→"N"），與 `00119` seed `00120="Y"` 一致；重用 `TBFinancialEvaluationFi`/`InfoS`/`LonSummary` entity/repo；UTF-8 No BOM 14/14。**待驗**：`TB_API_AUTH` 授權列。|
> c0 已有 entity/repo/checkpoint（`TBCheckPointsCs/Cu`=`EPROC001xx`）+ 部分邏輯散在既有 `Csu*` service；**缺 controller + corporate DTO package + 獨立 feature service**（非只缺 endpoint）。
> ⚠️ c0 **G/F 分流寫死在 `CsuCreditInvestigationServiceImpl`**：businessType=G 用 `EPROC00116+00117`、F 用 `EPROC00119+00120`，切換時清另一組 → 鏡像時沿用此既有 c0 規則，勿照 i0 重寫。c0 **無 `EPROC00111/00113`** → 不可把 i0 `FinancialEvaluationController`/`IndividualScoreCardController` 當 c0 對應頁。

### 2C. API 慣例（重要，所有任務遵循）
- 後端 endpoint = **RPC 式 `epl-{verb}-{scope}-{feature}`**（verb：`sele`/`info`/`save`/`case`/`quer`/`calc`/`comm`/`resu`/`list`/`ppdf`(印PDF)/`pxls`(匯Excel)/`file`…），**非 REST 資源路徑**。
- 前端一律打**既有同名 endpoint**；新後端頁**鏡像既有 i0/isu 控制器**的命名與結構。
- ⚠️ `archive/phase1-eproz0_0700-spec.md` 的 `/api/emp-proxy` REST 為理想化版，**實際以 `DeputyController` 的 `epl-*` 為準**。

### 2D. 參考來源原則（每張任務遵循）
| 來源 | 何時用 |
|---|---|
| **既有已完成頁（同專案）** | **主要 pattern**：前端鏡像既有 z0/isu 頁、後端鏡像 i0 controller。Codex 直接看得到。|
| **新後端 `epl-*` DTO** | 前端對接必需。Codex 在**母資料夾**啟動可同時讀後端 → 前端任務裡叫它**讀對應 controller 的 DTO、前端欄位對齊**（免手動複製；見 `SETUP-codex.md`）。|
| **新 DB schema** | 後端建 entity（JIT 抽，`db-schema-catalog.md`）。|
| **舊系統 JSP** | **多數不用**（新系統已合併/改過，恐誤導）；僅「**無新範本可鏡像**」的頁（如 `EPROISU0920` 撥貸）需追舊鏈路，其餘僅作業務語意次要參考、**勿當 spec**。|

### 2E. 正確性驗證（補完後怎麼確認「對」）
> 建置鏡像（2D）≠ 不驗正確性。驗的對象**優先用已驗證的新系統等價物**，非 raw 舊 JSP。
1. **契約對齊（第一層）**：前端打的欄位 ↔ 後端 `epl-*` DTO 必須一致（FE/BE 兩專案各跑、互相對齊）。
2. **有新等價物 → 以它為 oracle**：`c0` 對 `i0`、`csu` 對 `isu`、新報表頁對既有 z0（皆已從舊系統驗過）。
3. **無新等價物 → 回對舊系統**：如 `EPROISU0920` 撥貸（追舊 `EPROIS_0920` 行為當基準）。
4. **舊系統 = 最終業務基準**，但新系統已**刻意合併/改動** → 「對照 + 人工判斷差異」，**非逐欄硬比**；後端業務邏輯（計算/規則）正確性最依賴它（但多已 done 或由 i0 鏡像承接）。

### 觀察
- 30% 缺口（**2026-06-05 校正**）：① **企金評分後端 controller 全數結清**——`EPROC00115`/`00116`/`00117`/`00118`/`00119`/`00120` ✅（`00117` 為既有模組、audit 確認已滿足；`00118` 本期新建+語意審查）② **撥貸 `0920`**：2026-06-05 盤點發現**後端已存在**（`0921`/`0922` controllers 服務 FE 全部 9 端點），**非 build 缺口**；惟撥貸正確性 unverified（無舊源/無 oracle）→ 撥貸 domain + 整合驗證 ③ 前端 **全數完成**（`EPROCSU0130` 2026-06-05 收尾、ng build 綠）。→ **30% 的 CODE 結構性全到位；殘留＝驗證階段**（整合測試 + 2 條 escalation + 撥貸 domain 正確性）。
  > ⚠️ **2026-06-06 翻案（以 `feature-inventory.md` 為準）**：此「前端全數完成 / 30% CODE 全到位」**有誤**——**c0 評分前端（容器 + 8 子頁）整組缺**、現 Phase F 鏡像 i0 補建中。故殘留＝**c0 評分 FE（建置中）+ 撥貸核心 + 整合驗證**。
- ⚠️ **2026-06-05 教訓（後端版）**：`00117` 經 Codex Step-1 唯讀盤點發現 c0 模組**早已存在**（cross-check 誤判為「缺」）→ 證實**「未做其實已完成」在後端也會發生**，先前「後端 cross-check 較可靠」需修正。**任一頁開做前一律先 Codex 唯讀盤點實際完成度**（不分前後端），避免重造。
- 🚩 **escalation 1（待 `CsuCreditEval*` owner 人審，2026-06-05）**：`EPROC00118` 之 CU-return checkpoint 缺陷——既有 `CsuCreditEvalAndCreditDecisionServiceImpl` Return(98) 硬編碼只清 `TB_CHECK_POINTS_CS`、無 CU 分流（`:2985`）；§6.1 禁改既有 `Csu*`，故不在 00118 修。**待辦**：先 Codex 唯讀確認 CU（無擔企金）案件是否真會走到 `00118` checkpoint；若會→排既有 service 加 CU 分流之獨立修正（需授權破 §6.1「禁改 Csu*」），若不會→此非 bug、結案。
- 🚩 **escalation 2（gate-b 2026-06-05 發現，待同一 owner 人審）**：`crScoreCardCompleted` 兩碼契約（00114=第1碼 / 00118=第2碼）被既有 `CsuCreditEvalAndCreditDecisionServiceImpl:2890` **整欄覆寫成 `"NN"`**。00118 自身鏡像 i0 已驗正確（只動第2碼）；此覆寫屬企金信用決策生命週期之既有行為、§6.1 不改。**待辦**：確認整欄 "NN" 是 intended（決策重置）還是 latent bug + 與 00118 save 時序（含 Y/N 語意）→ 整合驗證涵蓋。
- 📋 **彙整交付清單見 [`verification-handoff.md`](../verification/verification-handoff.md)**（2026-06-05；按 owner 分組：c0 escalation / 撥貸 domain / 授權列 / export·報表 / 契約對齊）。原始散列：（dev/uat 後端真資料時集中跑，build 階段不阻擋）：`EPROZ00610` CR 呈現/資料；`EPROC00115` 新 `epl-*-c0-*` endpoint 的 `TB_API_AUTH`/`TB_ROLE_TASK` 授權列（CS/CU 判斷已 code review 確認正確）；`EPROC00116`/`00119` 新 endpoint 授權列 + export 模板沿用 i0（`EPROI00116`/`EPROI00119`）是否需 c0 專屬；`EPROC00120` 新 endpoint 授權列；`EPROC00118` 新 endpoint（`epl-*-c0-corporateScorecard`）`TB_API_AUTH`/`TB_ROLE_TASK` 授權列 + 上述 2 條 escalation（CU-return checkpoint、crScoreCardCompleted 整欄覆寫）；報表 `00620–00650` 呈現（`00640` scorecard export FE POST blob vs BE GET `@RequestBody` 介面不一致需對）。
- 報表 00620–00650 後端**已含 export** → 前端做查詢+觸發既有 export 即可，**R2 對這幾頁影響小**。
- ⚠️ **以 build manifest 校正（2026-06-03 `ng build`）**：前端已存在 lazy module —— `credit-reviewer-onhand-status`、`cad-onhand-status`、`deviation-case-report`、`scorecard-report`、`application-delete-report`、`application-cancel-report`、`deputy`（size 多很小=骨架）。→ 不少「未做」其實是**骨架待補、非從零**；**選頁前先看既有 module 完成度**（build chunk 大小可當粗略指標）。cross-check(Copilot 搜尋)會漏，**build manifest 為準**。
- ⚠️ **2026-06-04 再校正（Codex 逐頁盤點）**：`00620–00650` 報表頁**全部頁面結構已接好**（非骨架）；其中 `delete`/`cancel` 共用 `base-application-report`，**功能在共用 base 裡 → build chunk 小但完成度高** → build-size 啟發法會**低估「共用 base 的頁」**。教訓：**選頁/開做前一律先讓 Codex 唯讀盤點該頁實際完成度**，避免重做。
- ⚠️ **2026-06-04 三度校正**：`00700` Assign Substitute 也早已實作（= `pages/deputy`，**非新建**）。三次「未做其實已完成」（CAD→CR、4 報表、deputy）顯示**前端 cross-check（Copilot 關鍵字搜尋）系統性低估完成度**，主因：① build-size 啟發法低估共用 base 頁 ② 頁以 **domain 命名**（`deputy`）非 funcId（`assign-substitute`）→ 關鍵字搜尋漏掉。**結論：前端基本完成，剩餘 30% 真正落在後端**（6 個 c0 評分 controller + 撥貸 0920）。後端任一頁開做前仍照「先唯讀盤點實際完成度」紀律（半成品也可能比想像完整）。
  > ⚠️ **2026-06-06 補充**：偏誤其實**雙向**——多數頁被**低估**（做了當沒做），但 **c0 評分前端被高估**（當做了、其實整組沒做）。→ 結論修正：前端 **非** 全完成，**c0 評分 FE 為真缺口**（Phase F 補建中）。唯讀盤點紀律**前後端都要**。

## 3. 下一步：對照兩專案找出未完成（cross-check）
在**前端專案**與**後端專案**各跑一次（prompt 見對話），用 §1 新頁代碼逐一確認「已實作/半成品/未做 + 對應 component/route 或 controller/endpoint」→ 回填本檔狀態欄、彙整 §2 backlog。

### 已知關聯（前面盤點可直接餵入）
- 新頁內部結構（頁籤/區塊/狀態）：主流程見 `module-is-iu-shell.md`/`module-cs-cu-shell.md`；評分見 `module-i0-c0-scoring.md`。
- 權限：每頁 funcId → `TB_FUNCTION_AUTH`/`TB_API_AUTH`（R7，`db-schema-catalog.md` §4）。
- schema：JIT 抽（`db-schema-catalog.md`）。
