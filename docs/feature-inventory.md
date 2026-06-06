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

**全局結論（一句話）**：**前端 + 企金評分後端 = 碼全到位**（剩整合驗證）；**唯一真未完成 = 撥貸核心**（換匯 stub + T24 + domain 判斷）。整體已從「補碼階段」進到「**驗證 + 撥貸 domain**」階段。

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
| M7 | `c0` | 企金 財報/評分/CBC | 38 | `EPROC00*` | ✅ 後端本期結清（00115–120）／🟡 驗證 |
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
| EPROISU0910 | IS 0910 | Contract Preparation（頁框）| ✅❓ | ✅❓ | ❓ cross-check |
| EPROISU0911 | IS 0911 | Condition Confirmation | ✅❓ | ✅ | BE 存在（`ConditionConfirmationServiceImpl`）；❓ FE |
| EPROISU0912 | IS 0912 | Contract Production | ✅❓ | ✅❓ | ❓ cross-check |
| EPROISU0913 | IS 0913 | Closed Info | ✅❓ | ✅❓ | ❓ cross-check |
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
| （CS 0240）| CS 0240 | 公司核心資料（企金 0200 端）| ✅❓ | ✅❓ | ❓ cross-check（cu 無）|
| CAD 報表 | CS/CU 0181 | TLOD(CAD)→ 共用 `EPROISU0181` | ⏸ | ⏸ | ⏸ R2 |
> 不開發：`EPROCS_0240`（標已無使用，與上「公司核心資料」需釐清）；待確認 `EPROC0_0211/0213`（流程無對應頁籤）。

### 2C. 個金評分 `EPROI00*`（M6 i0；容器 `EPROI00110` 依 BUSINESS_TYPE 切頁；多為輸入表單）
| 新頁 | 名稱 | FE | BE | 剩餘 / 備註 |
|---|---|:--:|:--:|---|
| EPROI00110 | Credit Investigation（頁框）| ✅❓ | ✅❓ | ❓ cross-check（70% 重構）|
| EPROI00111 | Financial Evaluation Table | ✅❓ | ✅❓ | ❓ |
| EPROI00112 | CBC（查詢/維護）| ✅❓ | ✅❓ | ⏸ **CBC R8 資料接入 track** |
| EPROI00113 | Individual Scorecard | ✅❓ | ✅❓ | ❓ |
| EPROI00114 | Collateral Assessment | ✅❓ | ✅❓ | ❓ |
| EPROI00115 | Borrower Group Exposure | ✅❓ | ✅❓ | ❓ |
| EPROI00116 | Financial Statement GI（+印 PDF）| ✅❓ | ✅❓ | ⏸ PDF 印 R2 |
| EPROI00117 | Financial Evaluation GI | ✅❓ | ✅❓ | ❓ |
| EPROI00118 | Corporate Scorecard | ✅❓ | ✅❓ | ❓ |
| EPROI00119 | Financial Statement FI（+印 PDF）| ✅❓ | ✅❓ | ⏸ PDF 印 R2 |
| EPROI00120 | Financial Evaluation FI | ✅❓ | ✅❓ | ❓ |
> i0 是 c0 的鏡像 oracle → 推定 70% 已建；**開任何 i0 收尾前先 Codex 唯讀盤點**（前端 cross-check 系統性低估完成度，見教訓）。

### 2D. 企金評分 `EPROC00*`（M7 c0；本期重點）
| 新頁 | 名稱 | FE | BE | 剩餘 / 備註 |
|---|---|:--:|:--:|---|
| EPROC00110 | 頁框 | ✅❓ | ✅❓ | ❓ cross-check |
| EPROC00112 | CBC | ✅❓ | ✅❓ | ⏸ **CBC R8 track**；❓ |
| EPROC00114 | Collateral Assessment | ✅❓ | ✅❓ | ❓ **不在本期 6 支、狀態未證** |
| EPROC00115 | Borrower Group Exposure | ✅ | ✅ | 🟡 驗證；授權列 |
| EPROC00116 | Financial Statement GI | ✅ | ✅ | 🟡；授權列；export 模板沿用 i0？|
| EPROC00117 | Financial Evaluation GI | ✅ | ✅ | ✅ 既有模組 audit 確認滿足 |
| EPROC00118 | Corporate Scorecard | ✅ | ✅ | 🟡；授權列；🚩 **2 條 escalation**（見 §4）|
| EPROC00119 | Financial Statement FI | ✅ | ✅ | 🟡；授權列；export 模板沿用 i0？|
| EPROC00120 | Financial Evaluation FI（拆 table-fi + staff-fi 兩支）| ✅ | ✅ | 🟡；授權列 |
> c0 runtime-stub 盲點**已關**（六支 calc/save/info/sele/download 確認非 stub）。c0 **無 00111/00113**（與 i0 差異，勿硬補）。G/F 分流寫死在 `CsuCreditInvestigationServiceImpl`。

### 2E. 共用 `EPROZ00*`（M8 z0）
| 新頁 | 名稱 | FE | BE | 剩餘 / 備註 |
|---|---|:--:|:--:|---|
| EPROZ00100 | TO DO LIST | ✅❓ | ✅❓ | ❓ cross-check |
| EPROZ00200 | New Case Application（進件入口）| ✅❓ | ✅❓ | ❓（B4：案號來自 `TB_APP_NO_SEQ`）|
| EPROZ00300 | Document Checklist | ✅❓ | ✅❓ | ❓ |
| EPROZ00400 | Case Distribution | ✅❓ | ✅❓ | ❓ |
| EPROZ00410 | Related Party Info | ✅❓ | ✅❓ | ❓ |
| EPROZ00500 | Comparison table…CUBC | ✅❓ | ✅❓ | ❓ |
| EPROZ00600 | Search | ✅❓ | ✅❓ | ❓ |
| EPROZ00610 | Credit Reviewer On Hand | ✅ | ✅ | 🟡 呈現/資料驗證 |
| EPROZ00620 | Application Delete Report | ✅ | ✅ | 🟡（繼承 `base-application-report`）|
| EPROZ00630 | Deviation Case Report | ✅ | ✅ | 🟡（含 Excel export）|
| EPROZ00640 | Scorecard Report | ✅ | ✅ | 🟡；⚠️ **export FE POST blob vs BE GET `@RequestBody` 介面不一致→優先對** |
| EPROZ00650 | Application Cancel Report | ✅ | ✅ | 🟡 |
| EPROZ00660 | CAD On Hand Status | ✅ | ✅ | ✅（CR 範本）|
| EPROZ00700 | Assign Substitute | ✅ | ✅ | ✅（= `pages/deputy`）；嚴謹可做 deputy↔0700 gap-check |
| EPROZ00800 | Revised Item | ✅❓ | ✅❓ | ❓ cross-check |
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
| R8 | **CBC 聯徵資料接入** | ⏸ 獨立 track | i0/c0 `00112` CBC adapter |
| — | **檔案上傳/下載 API** | ⏸ **待設計** | collateral 0150、審批 0170/0171/0173 上傳 |

---

## 4. 剩餘事項彙整（= 還有多少事要做）
> 程式結構性已到位；殘留集中在**驗證 + 撥貸 domain + 暫緩 track**。

**① 整合驗證（owner：dev/uat 整合測試）— 量大但非補碼**
- 全主流程頁（is/iu/cs/cu 0110–0173）FE↔BE `epl-*` DTO 契約 + 真授權各跑一次。
- c0 六頁（00115–00120）呈現/授權/export。
- z0 報表 00610/00620–00650 呈現；**00640 export 介面不一致優先對**。

**② c0 escalation（owner：信用決策 domain）— 2 條**
- E1：CU-return checkpoint 只清 `TB_CHECK_POINTS_CS`、無 CU 分流（`:2985`）→ 確認 CU 是否走到 → 決定是否破 §6.1 修。
- E2：`crScoreCardCompleted` 整欄覆寫 `"NN"`（`:2890`）→ intended vs latent bug。

**③ 撥貸 domain（owner：撥貸 domain + T24 + DBA）— 見 escalation doc**
- 🔴 A-1 換匯 stub 實作（**最優先、總開關**）、B-1 `T24_COMPANY` 值來源、換匯源 ID、檢核嚴格度、KHR 確認、欄寬、async 架構、金額精度（待舊 DDL）、M6 完工日 DTO 缺源。

**④ 授權列（owner：DB/ops）**
- 新 c0 endpoint（00115/00116/00118/00119/00120）的 `TB_API_AUTH`/`TB_ROLE_TASK`（00117 既有應已有）。

**⑤ 暫緩 track（需先拍板才排）**
- R2 報表服務 → 解鎖 0181 CAD、i0/c0 PDF、z0 報表 PDF。
- 檔案上傳/下載 API → 解鎖 collateral/審批上傳。
- R8 CBC 資料接入 adapter。

**⑥ 待 cross-check（❓，開做前先唯讀盤點）**
- i0 全頁（00110–00120）、c0 `00112`/`00114`、契約頁（0910–0913）、z0（00100/00200/00300/00400/00410/00500/00600/00800）、CS 0240。

**⑦ Tech-debt / ops**
- map-key 大小寫混用全面 sweep（Oracle native query，可能藏靜默 null）。
- Logback 硬編碼 `D:\temp\...` 外部化。

---

## 5. 建議排程（依依賴與風險）
> 原則：**先驗證已完成的（解鎖里程碑）→ 再攻撥貸 domain（解鎖撥貸）→ 暫緩 track 待決策**。前兩者可並行（不同 owner）。

**Phase V — 整合驗證（即刻，owner：整合測試；可與下並行）**
1. 契約對齊 sweep：主流程 + c0 六頁 FE↔BE DTO（真資料/真授權）。
2. z0 報表呈現，**先解 00640 export 介面不一致**。
3. ❓ 項先做 Codex 唯讀盤點，把推定狀態坐實成已確認（i0、c0 00112/00114、契約頁、z0 其餘）。

**Phase D — 撥貸解鎖（關鍵路徑，owner：撥貸 domain）**
4. 🔴 **A-1 換匯 stub 實作**——撥貸總開關，最高優先；先做「實作前調查」（匯率來源 API/表、舊取法、回傳結構）。
5. A-1 通後第一次端到端跑 → 前面 10 筆機械修正才生效 → 驗 D1–D8（狀態機/T24/SFTP/mail/精度）。
6. B-1 `T24_COMPANY` 值來源 + 其餘 T24 來源欄（domain/T24 窗口，可與 4 並行籌備）。
7. 金額精度：取舊 DDL → DBA 對 scale。

**Phase E — c0 + 授權收尾（owner：domain + DB/ops）**
8. c0 E1/E2 escalation 裁示（含必要的既有 service 修正授權）。
9. 新 c0 endpoint 授權列建置。

**Phase R — 暫緩 track（待拍板才啟動，可獨立排）**
10. R2 報表服務選型 → 回頭做 0181/PDF/z0 報表。
11. 檔案上傳/下載 API → collateral/審批上傳。
12. R8 CBC 資料接入。
13. Tech-debt：map-key sweep、Logback 外部化。

**關鍵路徑**：撥貸能不能上線 = **Phase D（先 A-1 stub）**。前端/c0 = **Phase V 驗證**即可收。R2/檔案/CBC 是**獨立決策 track**、不擋主里程碑。

---
> 維護：本檔為**對應/排程主表**；逐項狀態變動回填本檔 + 對應細節 doc（`completion-ledger` 桶別、`verification-handoff` 驗證、`disbursement-*` 撥貸）。❓ 項一經唯讀盤點即升 ✅/🔴。
