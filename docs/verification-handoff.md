# 30% 補完 — 驗證交付清單（Verification Handoff）

> **程式/build 結構性（2026-06-05）**：c0 評分 `00115–00120` ✅、前端 ✅（含 `CSU0130`）；⚠️ **撥貸後端 `0921/0922` 端點在但核心未完成**——舊系統比對發現 `0922 authorize` 換匯為 throw-stub（執行核心未跑過）+ `0921` 多項分歧，詳 §2.1/§2.2，triage 進行中。
> 本檔彙整**所有殘留「驗證」項**，交 **dev/uat 整合測試 + 各 domain owner**。**非 build 阻擋項**——build 階段不擋，集中於有真資料/真授權時跑。
> 來源：`page-mapping.md` §2B、`decisions.md`、`build-tasks/EPROC00118-*`、boundary bundle `EPROC00118/`。

## 0. 原則
- 程式已到位 → 本階段只驗**正確性 / 授權 / 呈現**，**不再 build、不重寫、不臆測**。
- 驗證 oracle 優先用新系統等價物（`c0`對`i0`、`csu`對`isu`）；無等價物者（撥貸）回對**舊系統 / domain owner**。
- **怎麼跑**（分階段、context-bounded、可重複、含舊系統「抽取→比對」兩步）見 [`verification-execution.md`](verification-execution.md)；每項驗完在本檔對應列標 **☐→✅/⚠️** 並 commit（context window 拋棄式、進度存 doc）。

---

## 1. 🔴 c0 評分 — 2 條 escalation（owner：`CsuCreditEval*` / 信用決策 domain）
> 皆為**既有 `CsuCreditEvalAndCreditDecisionServiceImpl` 行為**、§6.1 禁改 → 非 00118 本體缺陷，須 owner 裁示。

| # | 項目 | 證據 | 怎麼確認 |
|---|---|---|---|
| **E1** | CU-return checkpoint 只清 `TB_CHECK_POINTS_CS`、無 CU 分流 | `CsuCreditEvalAndCreditDecisionServiceImpl:2985` | 確認 CU（無擔企金）是否真走到 `00118` checkpoint；**會**→授權加 CU 分流（破 §6.1 需核可）；**不會**→非 bug、結案 |
| **E2** | `crScoreCardCompleted` 整欄被覆寫成 `"NN"`（與「00114=第1碼/00118=第2碼」雙位元契約並存）| `CsuCreditEvalAndCreditDecisionServiceImpl:2890` | 確認 intended（決策重置）vs latent bug；與 `00118` save 的時序（覆寫前/後）、Y/N 語意是否影響 submit gate 期望值 |

## 2. 🟠 撥貸 `0920` — domain 正確性（owner：撥貸 domain + 整合測試）
> 舊 `EPROIS_0920` source 不在 workspace、無 i0/twin oracle → 既有 `0921 DataInputServiceImpl`/`0922 SummaryServiceImpl` 為實作基準，**正確性須 domain + 整合驗證**（§6.6：不臆測、不重寫）。

| # | 項目 | 證據（既有 service） | 怎麼確認 |
|---|---|---|---|
| **D1** | 撥貸狀態機 `CASE_PROGRESS` 24/25/26/98 + `TB_APP_HISTORY` process code | `DataInputServiceImpl` / `SummaryServiceImpl` | dev/uat 跑完整撥貸流程，對每個狀態轉移與歷程碼 |
| **D2** | T24 授權檔組檔 `funcIsuT24Authorize`（16 張表來源）| `SummaryServiceImpl:876` | domain 驗檔格式 / 欄位來源 / 金額正確 |
| **D3** | SFTP 上傳 + `TB_MESS_UPLOAD_SFTP_RECORD` | `SummaryServiceImpl:2265` | uat 驗上傳成功與記錄 |
| **D4** | mail 通知（submit / return / auth）| `SummaryServiceImpl` / `DataInputServiceImpl` | 驗收件對象與內容 |
| **D5** | checkpoint 走 `CASE_PROGRESS` + `TB_DISBUR_DATE.EPORIS_0921`、**非** `TB_CHECK_POINTS_IS/IU` | 盤點 | 確認此為撥貸流程**正常設計**（非缺漏）|
| **D6** | cleanup：`/epl-case-submit-isu-summary` stub（FE 未用）| `SummaryController:43` | 確認移除或補實作（FE 用的是 `epl-case-isu-summary-submit`）|
| **D7** | `TB_DISBUR_*` 三表未在 `db-schema-catalog` authority 首段 | 盤點 | 以既有 entity/repo 為準，或回補 catalog |
| **D8** | **schema-map 風險**（DB2→Oracle/整併；Step A2 2026-06-05）| `legacy-extract/disbursement-schema-map.md`（本機）| 🔴 **T24 組檔欄位來源**：`BRANCH_PROFILE.T24_COMPANY` 舊有新無，**A-0922-t24 確認用於 T24 `B8`/`C9`（collateral 段）** → 新 `funcIsuT24Authorize` B8/C9 填什麼（漏/hardcode/改源/併欄）？🟠 **金額精度**：舊 VO 無 DB2 length/precision（UNKNOWN）→ 需舊 DDL/DBA；T24 多為原字串 passthrough，唯一改值＝E 段非 USD `CHRG_AMOUNT=Math.round(CBC_FEE×中價)`（⚠️ `Math.round`/HALF_UP vs 0921 fee 的 `RoundingMode.DOWN`，查新碼是否搞混）🟡 `NOTIFICATION_INFO` `NO`→`No` 🟡 `LON_SUMMARY_INFO` 新增 `PROJECT_CODE` |

### 2.1 撥貸 `0921` Step B 比對結果（2026-06-05；舊 spec ↔ 新 `DataInputServiceImpl`）
> 詳細逐項表（含舊業務規則、`file:line` 證據）存本機 `legacy-extract/EPROIS_0921-compare.md`（gitignore）；此處只記主題/嚴重度/裁決方向。皆為**待裁決分歧**（部分倚賴舊 spec 的 UNKNOWN），非已坐實 bug。
>
> **結論：`0921`「結構在、行為不對等」— 7 PASS / 15 FAIL / 5 UNSURE。** 撥貸後端雖存在，正確性須逐項裁決——**不可一律「改回舊版」**（部分分歧是刻意演進）。
> **裁決（2026-06-05）：先跑完 `0922`（Summary + T24）再整體 triage，避免 piecemeal；本 `0921` 清單暫不動碼。**

**🔴 資料完整性（疑似 regression，最高、較高信心）**
- Collateral 完工日（`EST_COM_DATE`/`OTHER_EST_COM_DATE`）新固定寫 `null` → 疑資料遺失
- `dataReturn` fee cleanup 用 derived `deleteByIdApplicationNo` → 疑按 application 過度刪 fee（舊僅刪 `CON_TYPE=FN`）
- fee 公式 loan-amount alias 與讀取 key 不一致 → facility fee 可能 `null`
- `RECEIVED_DATE` 新在 Save 即寫（舊僅 Finished）；`dataReturn` 多寫一筆 history（舊僅 `APP_PROCESS_CODE=98`）

**🟠 檢核對等（需 domain 裁示 intended vs regression）**
- `CheckMainBorr`：身分比對、sector/industry 矩陣、account 規則、records-empty 不刪舊
- `CheckCoBorr`：`DATA_SEQ` 順序敏感、business-section 一律判 `N`
- `info` `CO_CHECK`：新 `='Y'` vs 舊 `!='N'`；Finished gate 未驗 `mbCheck`；law firm `IS_SHOW` 版本條件；address `UPD_DATE` 來源

**🟢 疑似刻意演進（勿改回舊）**
- fee rounding 新增 `KHR` + `RoundingMode.DOWN`（舊僅 `USD`）→ 多半 Cambodia 在地化，非 bug

**🟡 UNSURE（需 DDL/DBA/資料）**
- 金額 precision（`NUMBER(17,2)` vs 舊 UNKNOWN）；`IS_CONTRACT`/`IS_CONTR` persist 目標；contract source 可能 NPE；空 `APPLICATION_NO`（新 controller `@NotBlank` 擋、舊是否 throw 未明）

**✅ PASS（7）**：endpoint 對應、撥貸日（`CASE_PROGRESS=24`）寫入、`MB_CHECK`、save 重建表 + `EPORIS_0921` flag、CO placeholder、`dataReturn` summary 狀態、**`0921` 無 checkpoint（佐證 D5）**

### 2.2 撥貸 `0922` Step B（main）比對結果（2026-06-05；舊 spec ↔ 新 `SummaryServiceImpl`）
> 詳細表本機 gitignore；此處主題/嚴重度。T24 A–H 逐欄留 B-0922-t24。
>
> **🔴🔴 SHOWSTOPPER（已複驗確認 2026-06-05）**：`authorize`（`caseIsuSummaryAuth`）換匯 `funcGetExchangeRate` 在 `0000` 成功分支**寫完 `TB_DISBUR_DATE`/`TB_EXCHANGE_RATE` 後無條件丟** IDE 自動產生的 `UnsupportedOperationException("Unimplemented method 'funcGetExchangeRate'")`（`FunctionServiceImpl:1221`）——**全方法無 return 路徑**、呼叫端無繞過 → **T24/SFTP/record/狀態（26）全部到不了**。**確認＝撥貸 authorize 核心未完成（半成品：DB 寫入已寫、缺 return、留 IDE stub throw）**，非僅行為分歧 → **「`0920` 認列既有＝結構到位」更正為「authorize 核心未完成」**。範圍：此為兩檔內**唯一** stub（`:614` 是 catch 包裝、非 stub）→ 修點侷限此方法尾段，但 **authorize 從未端到端跑過**，且同路徑另有下列真 bug；另有 **partial-write 風險**（寫後拋，依交易邊界可能留半更新）。

**🔴 其他真 bug**
- `EXCHANGE_RATE` 來源 ID `OVSLXLON01`→`OVSLXLON02`（換錯匯率源，money；即使被 stub 擋住仍 latent）
- `submit` mail 建了 `MailList` 但未加入 → 送空清單，**checker 從未收到通知**
- `submit` app history `APP_PROCESS_CODE` 舊 `25` → 新 `24`（process code 錯）

**🟠 架構/實作（多疑刻意，需 domain 確認）**
- `t24DealResult` 由 action 改**批次** `EPROZ0B006`（async 處理結果檔）→ 疑刻意；需確認等價
- mail 改由 repository/scheduler 後送（只 insert `TB_NOTIFICATION_INFO`）→ 需確認 scheduler 存在且更新 S/F
- `authorize` 狀態 `CURRENT_USER_ID` key 尾端多空白（`DynamicUpdateSqlUtils`）→ 潛在 key bug
- 批次 T24 結果寫 `IS_AUTODIS=YC`（舊 `0922` 未見 flag 寫入）

**🟡 UNSURE**：`t24DealResult` 非 `0000`/無 done flag 是否更新 summary 狀態；`CLO_REASON=C10` 寫法差異

**✅ PASS**：submit/returnMaker 狀態轉移、`funcConfCheckDate` 檢核、returnMaker mail、SFTP/record（若可達）、t24 成功/失敗→`27`/`C1`（批次）、`NOTIFICATION_INFO No`（**D8 釐清＝同欄 ✅**）、`PROJECT_CODE` 未涉（**D8 釐清 ✅**）、checkpoint 新舊皆無

## 3. 🟡 授權列（owner：DB / ops）— 新 c0 endpoint 的 `TB_API_AUTH` / `TB_ROLE_TASK`
> `00117` 為既有模組（授權列應已有）；其餘新建 c0 頁的新 `epl-*-c0-*` endpoint 需建授權列。

| 頁 | endpoints |
|---|---|
| `00115` | `epl-{info/save/sele}-c0-borrower-group-exposure` |
| `00116` | `epl-{sele/quer/info/calc/save/ppdf/pxls}-c0-financial-statement-comments` |
| `00118` | `epl-{sele/info/calc/save}-c0-corporateScorecard(-list)` |
| `00119` | `epl-{quer/info/calc/save/ppdf/pxls}-c0-financial-statement-cmts-fi` |
| `00120` | `epl-{info/save}-c0-financial-evaluation-table-fi`、`epl-save-c0-financial-evaluation-staff-fi` |

## 4. 🟡 export 模板 / 報表呈現（owner：整合測試）
- `00116`/`00119`（及 `00118` 若有）export 模板**沿用 i0**（`EPROI00116`/`EPROI00119`）→ 確認可接受 or 需 c0 專屬路徑。
- 報表 `00620–00650` 呈現；⚠️ **`00640` scorecard export**：FE POST blob vs BE GET `@RequestBody` **介面不一致 → 優先對**。
- `EPROZ00610` Credit Reviewer On Hand：CR 呈現 / 資料。

## 5. 契約對齊（整合測試；多已 code review）
- 各 `c0`/`csu` 頁 **FE 送/收欄位 ↔ BE `epl-*` DTO**：以真資料 / 真授權跑一次（`00115` CS/CU 判斷已 code review 確認正確）。

---
> 驗完逐項打勾，回填本檔 + `page-mapping.md` §2B。整合驗證為**獨立後續階段**（`runbook-30pct.md` §5），不影響「程式補完」里程碑。
