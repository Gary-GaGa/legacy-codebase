# Phase V Harness — v1 Manifest 約定（langType 五頁筆數一致回歸守門段）

> **這是什麼**：`phase-v-api-selfverify-harness.md` 卡標「**v1 必含 langType 五頁筆數一致斷言**」的那一段、寫成 manifest 約定（schema + grounded 列）。
> **分工（卡鐵則）**：runnable manifest（YAML/JSON）+ harness 腳本**落產品 repo／母資料夾 `tools/`**，由 Codex 在你本機**materialize + 跑**（規劃 repo 的 remote agent 打不到 localhost＝產不跑）。**規劃 repo 只留本約定**——schema、grounded 的五列、斷言語意、provenance。
> **grounding**：endpoint/handler/repository `file:line`＝`build-tasks/done/langtype-data-filter-sweep-findings.md`；修後筆數基準＝`verification/verification-handoff.md §6.2`（product `bbbaa19`+`7e1f0d2`，OVSLXLON02 實測）。**全列 grounded、零臆測**。
> **範圍**：v1 只含這 5 列（langType 回歸守門）。其餘讀型列（`00600` search-options、`00100` checklist、`00300`、`00800` init-query…）待各頁 `qa-cases.md` 落地再補（本 repo 目前只有 `EPROZ00800` 的 qa-cases）。

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
RV-2 修復（langType 退出資料過濾）目前靠人工筆數比對確認；本段把它**固化成自動回歸守門**——未來任何人再把 `langType` 塞回 outer WHERE，這 5 列差分斷言會立刻 FAIL。這是 harness v1 唯一在規劃 repo 端就能 grounded 寫出的段（其餘頁待 qa-cases）。

## 6. materialize（harness author，產品 repo）
- 把 §2 五列轉成 runnable manifest（YAML/JSON：`id/endpoint/method/params/equiv_sql/assert`）。
- `equiv_sql` 從 §2 repository `file:line` 抽 native query、去 `langType` 過濾。
- 跑：人起服務（`local-phase-v-bringup.md`）+ 拿 JWT → harness 逐列打 endpoint（`langType=zh_TW`/`en_US` 各一）+ 唯讀 SELECT → 出 PASS/FAIL 表 → 回填 `verification-handoff.md §6`。

> 過了：langType 五頁回歸從「人工比對」變「自動守門」；harness v1 有了第一段可跑的 grounded manifest，其餘讀型列待 qa-cases 增量補。
