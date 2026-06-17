# 30% 補完 — 驗證交付清單（Verification Handoff）

> **程式/build 結構性（2026-06-05；2026-06-06 修）**：c0 評分 `00115–00120` **後端** ✅（**前端原缺、Phase F 補建中**，見 `feature-inventory.md` §2D）、其餘前端（主流程/i0/契約/z0/`CSU0130`）✅；⚠️ **撥貸後端 `0921/0922` 端點在但核心未完成**——舊系統比對發現 `0922 authorize` 換匯為 throw-stub（執行核心未跑過）+ `0921` 多項分歧，詳 §2.1/§2.2，triage 進行中。
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
| **D8** | **schema-map 風險**（舊→新 schema/整併；Step A2 2026-06-05）| `legacy-extract/disbursement-schema-map.md`（本機）| 🔴 **T24 組檔欄位來源**：`BRANCH_PROFILE.T24_COMPANY` 舊有新無，**A-0922-t24 確認用於 T24 `B8`/`C9`（collateral 段）** → 新 `funcIsuT24Authorize` B8/C9 填什麼（漏/hardcode/改源/併欄）？✅ **金額精度已關**（06-12 DDL 實查：舊＝新，`(17,2)`/匯率 `(17,4)`）；🟡 **T24_COMPANY 前提推翻**（新庫實存於 OVSLXLON01/02 兩 schema → B-1 降級轉 RD 接值）；T24 多為原字串 passthrough，唯一改值＝E 段非 USD `CHRG_AMOUNT=Math.round(CBC_FEE×中價)`（⚠️ `Math.round`/HALF_UP vs 0921 fee 的 `RoundingMode.DOWN`，查新碼是否搞混）🟡 `NOTIFICATION_INFO` `NO`→`No` 🟡 `LON_SUMMARY_INFO` 新增 `PROJECT_CODE` |

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
> **⚠️ 2026-06-17 更正（§2.1–2.3 為 06-05 快照，下列已解決，勿照舊判讀）**：① A-1 `funcGetExchangeRate` throw-stub **已實作＋conformance 4/4 PASS**（product `daae4c3`，06-16）→ 下方 🔴🔴 SHOWSTOPPER 已解。② `EXCHANGE_RATE` 來源 ID 已裁**回 `OVSLXLON01`**（A-2 舊 parity，非 bug；下方 `:67` 方向過時）。③ 金額精度 **C-1 已關**（06-12 DDL：舊=新 `(17,2)`、匯率 `(17,4)`，無落差）→ §2.3「需 DDL/DBA」過時。④ `T24_COMPANY` **非死路**（新庫實存→取 `OVSLXLON01`、RD 接值，B-1）。⑤ KHR rounding 實為**收窄**（非「新增在地化」；舊 non-USD 通吃、新只 USD/KHR，06-17 G/H 來源照舊）。現況權威＝`disbursement/disbursement-domain-escalations.md`＋`decisions.md`。
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

### 2.3 撥貸 `0922` Step B（T24 組檔）+ 整體 triage（2026-06-05）
> B-0922-t24（舊 `createTransferA–H` ↔ 新 `funcIsuT24Authorize`，碼層）：**即使補完 stub，T24 仍 FAIL**。
> **🔴 結構（高信心）**：`H` 段建了**未 append**（不輸出）、`E14–E23`/`E24-25` 位移、`H1–H8` 順序錯、`B9/C27/D8/G13` 各多尾端 `\n` 空欄 → 整檔欄位錯位。
> **🔴 值來源**：`B8/C9` `T24_COMPANY` 死路（讀已移除欄→空）；`A52` 漏、`C12/C13/C20/G4/G10/H8` 來源欄錯、`A31/G7` `AGREEMENT_NO` 截斷、`E21` 非 USD 非 KHR 輸出 0。
> **✅ 大段 PASS**：A1-14/17-30/32-51、B1-7、C 多段、D1-7、E1-13、G 多段；E21 KHR rounding 未誤用 DOWN。
> **🟡 金額精度**：多為直接字串輸出、無 `setScale`；新 `NUMBER(17,2)` vs 舊 UNKNOWN → 需 DDL/DBA。
>
> **→ 全撥貸（0921+0922-main+0922-t24）綜合裁決見 [`disbursement-triage.md`](../disbursement/disbursement-triage.md)**（P0 blockers / P1 bug / P2 domain 裁示 / P3 UNSURE + 工作量 + 建議路徑）。

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

## 6. 🟢 runtime 整合 bring-up（owner：dev；本機 FE+BE 同跑）
> **怎麼跑＝`build-tasks/local-phase-v-bringup.md`**（前置 gate + bring-up order + 能驗/不能驗矩陣 + smoke 順序）。DB 連線已通（06-12）後 runtime 這層才可行；與本檔 §1–§5 的「程式碼/語意逐項比對」互補。
> ⚠️ **寫測 schema＝`OVSLXLON02`（使用者裁定 06-14，直連正式新庫）**——護欄見該卡 §0.1（保留測試案件號段 / teardown SQL 交人審 / DBA 快照 / 唯讀帳號查證）。

| # | 項目 | 對應 smoke | 狀態 |
|---|---|---|---|
| **V-1** | 登入 + 唯讀載入頁通（FE↔BE↔DB 三段）| smoke 1 | ✅ 06-15（AO 登入通；起服務正常）|
| **V-2** | Phase G 新頁 render/載入（0150/0160/0170）| smoke 2 | ☐ |
| **V-3** | 主流程 save 落庫正確（測試案件段）| smoke 3 | ☐ |
| **V-4** | c0/csu 評分頁非 403（授權列已套）| smoke 4 | ☐ |
| **V-5** | G3 共用 return dialog ISU 回歸 | smoke 5 | ☐ |
| **V-6** | teardown SQL 產出交人審清庫 | smoke 6 | ☐ |

### 6.1 runtime findings（2026-06-15 Phase V 本機，AO 70201／連 `OVSLXLON02`）
| # | 發現 | 性質 | 處置 |
|---|---|---|---|
| **RV-1** | **Search 頁開即 E999**：`getSearchOptions` `Required request body is missing`（GET 無 body＋BE `@RequestBody` 殘留，疑 sweep① `48e687f` 不完整 regression）| ✅ 已修 runtime bug（角色無關，AO 也噴）| `getSearchOptions` 改為 GET query/model binding；FE 改用 `?langType=`，不再送 GET body；見 `build-tasks/done/00600-search-options-fix.md` |
| **RV-2** | **TODO List 空**（中文 UI）| ✅ **已修（06-16）**：langType 退出資料過濾；**筆數一致驗證 `zh_TW`=`en_US`=91**（langType 不再砍資料）| 修＝langtype sweep (a) 移除 `VMainBorrowerInfoRepository` outer WHERE（product `bbbaa19`）；根因＝新版多 `LOAN_TYPE_LANG_TYPE=:langType`、舊 initQuery 無＝regression。Owner 裁示落實（語系只剩 zh_TW+en_US、只影響翻譯不影響資料）|

### 6.2 橫向 sweep 結果（盤點 06-15 審過；**修 06-16 落地**）
> 兩份盤點 findings 審查 PASS（file:line 密、舊系統對照齊、UNFOUND 誠實標、附「正確用法不算候選」反向清單）。

**langType 當資料過濾（5 處）＝✅ 全修（product `bbbaa19`+`7e1f0d2`，06-16；筆數一致驗證 `zh_TW`=`en_US` 五頁全通）**：
- **(a) 移除 outer WHERE（2）✅**：`/epl-list-todolist`（91/91）、`/epl-list-casedistribution`（role405 5/5）。
- **(b) 改 join ON + fallback en_US（3）✅**：`/epl-list-caseapplication`（569/569）、`/epl-list-deviation`（293/293）、`/epl-list-cancelreport`（10/10）。

**GET 端配 request body（3 處）**：
- **#1/#2 scorecard export（pdf/excel）＝✅ 兩邊改 POST body（product `751f78f`，06-16）**：`ScorecardReportController:55/73` + FE `apiPostRequestForBlob`、`@RequestBody` 保留、query-list 未誤動。
- **🔧 #3 `epl-case-query-reviseditem`（`RevisedItemController:38`）= 00800 init-query → RP9 ✅ 關（06-16 RD/架構：GET，Follow PRD §6.1）**：解鎖。修向＝**GET query 同 00600**（BE `@RequestBody`→`@ModelAttribute` applicationNo、FE 改 GET query）。**可派工**（get-body sweep 卡 #3）。
- 00600 已修為樣板（不算候選）。

---
> 驗完逐項打勾，回填本檔 + `page-mapping.md` §2B。整合驗證為**獨立後續階段**（`verification-execution.md`），不影響「程式補完」里程碑。
