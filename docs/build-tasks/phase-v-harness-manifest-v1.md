# Phase V Harness — v1 Manifest 約定（讀型 API↔DB 一致；唯讀）

> **段索引**：v1 讀型守門目前 **2 段**——**段① langType 五頁筆數一致**（§1–§6）、**段② `EPROZ00800` init-query 讀型**（§7）。兩段皆 grounded、零臆測。其餘讀型列（`00600` search-options、`00100` checklist 等）待各頁 `qa-cases.md` 落地再增量補（本 repo 目前只有 `EPROZ00800` 一份 qa-cases）。
> **這是什麼**：`phase-v-api-selfverify-harness.md` 卡標「**v1 必含 langType 五頁筆數一致斷言**」+ 讀型 API↔DB 一致那部分、寫成 manifest 約定（schema + grounded 列）。
> **分工（卡鐵則）**：runnable manifest（YAML/JSON）+ harness 腳本**落產品 repo／母資料夾 `tools/`**，由 Codex 在你本機**materialize + 跑**（規劃 repo 的 remote agent 打不到 localhost＝產不跑）。**規劃 repo 只留本約定**——schema、grounded 的列、斷言語意、provenance。
> **grounding**：段① endpoint/handler/repository `file:line`＝`build-tasks/done/langtype-data-filter-sweep-findings.md`、筆數基準＝`verification/verification-handoff.md §6.2`（product `bbbaa19`+`7e1f0d2`，OVSLXLON02 實測）；段②＝`archive/EPROZ00800-v0.9-superseded/srs/qa-cases.md`（QA-001/002；**v0.9 封存**）。**全列 grounded、零臆測**。

## 1. manifest 列 schema（卡定義：endpoint / method / params / 等價唯讀 SQL / 斷言）
| 欄 | 意義 |
|---|---|
| `id` | manifest 列 id（`LT-n`）|
| `endpoint` | `epl-*` 路徑 |
| `method` | **以 openapi 為準**（harness 跑前對 openapi/handler 確認；list 端非 GET-query 即 POST-body，見 §4 鐵則）|
| `params` | 過濾參數集；**varying 維度只有 `langType ∈ {zh_TW, en_US}`**，其餘參數（同 JWT/同 filter）兩次呼叫間**固定不變** |
| `equiv_sql` | 等價唯讀 SQL＝該 endpoint 的 repository native query（`file:line`）**移除 `langType` 過濾**後的 business-row count（SQL body 在產品 repo，本 repo `UNFOUND`→harness author 抽）|
| `assert` | 見 §3 斷言語意 |

## 2. grounded 五列（langType 回歸守門）
| id | 頁 | endpoint | handler（controller→service）| repository SQL（抽 equiv 用）| class | 基準筆數 `zh_TW`=`en_US` |
|---|---|---|---|---|---|---|
| **LT-1** | TODO List（**RV-2 起源**：曾 `zh_TW`=0／DB=92）| `/epl-list-todolist` | `ToDoListController.java:64-66` → `ToDoListServiceImpl.java:167-170` | `VMainBorrowerInfoRepository.java:46-47` | (a) 移除 outer WHERE | **91 = 91** |
| **LT-2** | Case Distribution | `/epl-list-casedistribution` | `CaseDistributionController.java:38-39` → `CaseDistributionServiceImpl.java:115-117` | `VMainBorrowerInfoRepository.java:104-105` | (a) | **5 = 5**（role405）|
| **LT-3** | New Case Application | `/epl-list-caseapplication` | `NewCaseApplicationController.java:37-40` → `NewCaseApplicationServiceImpl.java:118-121` | `TBLonSummaryInfoRepository.java:43-45`(join)/`:75`(filter) | (b) join ON + fallback `en_US` | **569 = 569** |
| **LT-4** | Deviation Case Report | `/epl-list-deviation` | `DeviationCaseReportController.java:35-38` → `DeviationCaseReportServiceImpl.java:184-198` | `TBLonSummaryInfoRepository.java:353-355`(join)/`:366`(filter) | (b) | **293 = 293** |
| **LT-5** | Application Cancel Report | `/epl-list-cancelreport` | `ApplicationCancelReportController.java:47-49` → `ApplicationCancelReportServiceImpl.java:83-94` | `TBLonSummaryInfoRepository.java:557` | (b) | **10 = 10** |

## 3. 斷言語意（每列）
1. **主守門＝差分斷言（fully grounded、不需 DB）**：同 JWT、同 filter，只改 `langType`，呼叫兩次 → **`count(resp[zh_TW]) == count(resp[en_US])`**。
   - PASS＝相等（langType 不砍 business rows，class (a) 移除過濾／class (b) fallback `en_US` 後筆數仍齊）。
   - **FAIL＝`zh_TW < en_US`**（正是 RV-2 症狀：缺翻譯被當資料過濾砍掉 parent row）→ 開 runtime-bug 卡。
2. **次守門＝API↔DB 一致（需 equiv_sql）**：`count(resp) == count(equiv_sql business rows)`。抓「API 比 DB 少」這類（RV-2：API=0、DB=92）。`equiv_sql`＝該頁 repository native query 去掉 `langType` 過濾的 business-row count。
3. **基準筆數＝smoke 參考、非硬等式**：§2 的 91/5/569/293/10 係 OVSLXLON02 當時實測（且 LT-2 依 role＝405 user），**資料會變、勿 hardcode 成 `==91`**；真守門是 #1 差分 + #2 DB 一致（兩者對資料量變動 robust）。

## 4. 鐵則（承 harness 卡）
1. **全唯讀**：只 GET/查詢 + 唯讀帳號 SELECT；不寫 DB。
2. `method`/`params` **以 openapi 為準**（harness 跑前確認；list 端若已改 GET-query 用 `?langType=`，否則 POST body）。
3. JWT/帳密走環境變數**不進 repo**。
4. 斷言失敗**只報 PASS/FAIL + 證據、不自動改碼**。
5. `equiv_sql` 由 harness author 從產品 repo native query 抽（本 repo SQL body `UNFOUND`）；抽時**只去 `langType` 過濾、business filter 全留**（user/case-progress/date/role…）。

## 5. 為何這段先做（卡的 mandatory 段）
RV-2 修復（langType 退出資料過濾）目前靠人工筆數比對確認；本段把它**固化成自動回歸守門**——未來任何人再把 `langType` 塞回 outer WHERE，這 5 列差分斷言會立刻 FAIL。這是 harness v1 在規劃 repo 端就能 grounded 寫出的兩段之一（另一＝§7，源自 `EPROZ00800` qa-cases）。

## 6. materialize（harness author，產品 repo）
- 把 §2 五列轉成 runnable manifest（YAML/JSON：`id/endpoint/method/params/equiv_sql/assert`）。
- `equiv_sql` 從 §2 repository `file:line` 抽 native query、去 `langType` 過濾。
- 跑：人起服務（`local-phase-v-bringup.md`）+ 拿 JWT → harness 逐列打 endpoint（`langType=zh_TW`/`en_US` 各一）+ 唯讀 SELECT → 出 PASS/FAIL 表 → 回填 `verification-handoff.md §6`。

## 7. 段②：`EPROZ00800` init-query reviseditem 讀型（QA-001/002）
> 來源＝`archive/EPROZ00800-v0.9-superseded/srs/qa-cases.md`（v0.9 封存）。只取**讀型 init-query** 兩條（QA-001/002）；其餘 QA（save/execute/FE 行為）屬寫入（v3）或 FE 層、**非 v1 唯讀**。⚠️ 00800 disposition=REBUILD：段② 待 00800 重產後以新 qa-cases 重定（langType 段① 不受影響）。
> ⚠️ **依賴順序**：init-query endpoint＝`epl-case-query-reviseditem`（`RevisedItemController:38`）＝get-body #3、RP9 ✅關＝**GET query by `applicationNo`**。**本段須在 get-body #3 落地後跑**（之前是壞的 GET-body，會 E999）；harness 卡已標此順序（get-body #3 → harness）。
> ⚠️ **需已知唯讀 fixture 案號**：不同於段① langType 差分（用現有資料即可），這兩條各需一個「**有** revised item」與「**無** revised item」的**已知 `applicationNo`**——可先用 `equiv_sql` 從 DB 撈符合條件者當 fixture（唯讀 SELECT、不建不刪資料）。

| id | covers | endpoint（method）| params | equiv_sql（唯讀）| assert |
|---|---|---|---|---|---|
| **RI-1** | QA-001 / R2 | `epl-case-query-reviseditem`（GET，get-body #3 後）| `applicationNo`＝**有** revised item 的案號 | `SELECT ITEM1..ITEM14, REASON_MEMO FROM TB_REVISED_ITEM WHERE APPLICATION_NO = :applicationNo` | response 既有勾選（ITEM1~14）+ `REASON_MEMO` **逐欄 == DB 該列**（API 忠實反映 DB，同 RV-2 精神：不得漏/竄改 DB 有的值）|
| **RI-2** | QA-002 / R2,R9 | 同上（GET）| `applicationNo`＝**無** revised item 的案號 | (i) `SELECT COUNT(*) FROM TB_REVISED_ITEM WHERE APPLICATION_NO = :applicationNo` ＝ 0；(ii) revisedType 選項＝`SELECT ... FROM TB_COMMON_FIELD_OPTIONS WHERE FIELD = <revisedType field key，harness author 對 spec/openapi 確認>` | response.items **全空白**，且 revisedType 選項 count **== (ii) 筆數**（無案件資料但 code table 仍正確帶出）|

**斷言語意**：兩條都是 **API↔DB 一致**（次守門那層）——RI-1 驗「有資料時逐欄忠實」、RI-2 驗「無資料時 items 空、但選項字典正確」。無差分軸（非 langType），故 fixture 案號要先選定。
**鐵則補充**：v1 唯讀，這兩條只 GET + 唯讀 SELECT；fixture 案號用唯讀 SELECT 撈、不建不刪。`revisedType` 對應的 `TB_COMMON_FIELD_OPTIONS.FIELD` key 本 repo 未坐實 → harness author 對 `EPROZ00800` openapi/spec 確認（標 UNFOUND，不猜）。

> 過了：langType 五頁回歸從「人工比對」變「自動守門」；加上 `EPROZ00800` init-query 兩條讀型一致斷言，harness v1 有了**兩段**可跑的 grounded manifest（段① 5 列 + 段② 2 列），其餘讀型列待各頁 qa-cases 增量補。
