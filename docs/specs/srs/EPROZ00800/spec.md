# SRS — EPROZ00800 Revised Item（SA 規格層）

| 欄位 | 內容 |
|---|---|
| Status | **Draft（blocked on RP1 / TBD-006）** |
| Owner | SA（待指派）|
| Slug | `EPROZ00800`（＝funcId）|
| 版本 | v0.3（round 2 複審：確認 B1–B3 已清 + 修 checkPointMap.required 語意 + QA-022 懸空標註）|
| 最後更新 | 2026-06-09 |
| 上游 PRD | `CDC-EPRO-0001 v1.1` |
| as-is 來源 | `docs/build-tasks/00800-verification-findings.md` |

> **上游 PRD**：`CDC-EPRO-0001 v1.1`（PM Review Draft，TBD-001~007 未關）。本 SRS 由 `prd-to-srs` skill 產出。
> **as-is 來源**：現有新系統碼之驗證結果 `docs/build-tasks/00800-verification-findings.md`（產品碼在開發機）。
> **每條規則一個 `Rn`，標 `covers-prd:` 上游追溯**；QA 用 `covers: Rn`（見 `qa-cases.md`）。
> ⚠️ **TBD 一律寫 `@PENDING` + owner，不自行裁定**；**不把 legacy 行為當已核准需求**（PRD §13）。`file:line` 待 RD 對產品碼核對。

## Scope / Non-Goals
- **本期**：Revised Item 初始查詢、選項顯示、必填檢核、儲存、關聯資料清除/還原、checkpoint/page-menu 更新。
- **非本期**：ITEM1~14 code table 維護、非本頁的其他頁籤重構、報表內容重製。

## Assumptions / Dependencies / Constraints
- **Assumptions**：`TB_LON_SUMMARY_INFO` 有 `LON_TYPE_CODE`/`REF_APPLICATION_NO`/`LON_ATTRIBUTE`/`SECURE_ATTRIBUTE`；`REVISED_ITEM` code table 已建。
- **Dependencies**：guarantor/collateral/loan-condition/fee 各模組的資料表與 reference-copy 邏輯；checkpoint DAO（IS/IU/CS/CU）。
- **Constraints**：Oracle；RPC `epl-*` 慣例；既有 `RevisedItemController`/`RevisedItemServiceImpl`（brownfield，見 as-is）。

## Endpoints（真實 `epl-*`；PRD §6 的 `/api/...` REST 為理想化）
| 動作 | endpoint（to-be） | method（to-be） | as-is | DTO |
|---|---|---|---|---|
| prompt（開頁/屬性）| 由 routing/attr 取得（RD 定）| — | — | attrMap、lonTypeCode |
| init-query | `epl-case-query-reviseditem` | GET（PRD §6.1）或全站一致 RPC（RD 定）| **FE POST / BE GET 不一致** | `QueryRevisedItemRequest/Response` |
| execute（儲存）| `epl-case-insert-reviseditem` | **POST**（會刪改資料）| 🔴 **BE GET（bug）**、FE POST | `InsertRevisedItemRequest/Response` |

> ⚠️ **init-query method（B3）**：PRD §6.1=GET vs 站上 RPC=POST vs as-is 兩端不符 → **RD/架構待定**（openapi 標 @PENDING）。
> ⚠️ **request body 結構（B2）**：to-be 用 `itemMap.item1..14`（見 `openapi.yaml`）；as-is `InsertRevisedItemRequest` 為平鋪欄位 → **RD 確認 DTO 形狀**（改 DTO 或 openapi 對齊）。

## 業務規則（Rn）
> 狀態：✅ as-is 符合 ／ ⚠️ as-is 出入 ／ 🔴 as-is 缺/風險 ／ 標 to-be＝PRD 要求。

### R1 — 開頁取屬性　`covers-prd: REQ-001`
prompt 取 `attrMap`（`applicationNo`、`isEdit`、CU 判定）+ `lonTypeCode`；初始化失敗回 `MSG_INITIAL_FAIL`。

### R2 — init-query 選項與既有資料　`covers-prd: REQ-002`
查 `REVISED_ITEM` code table（`getCommonFieldOptions("EPRO",locale,"REVISED_ITEM")` ← `TB_COMMON_FIELD_OPTIONS`）→ `revisedType`+`revisedTypeSize`；查 `TB_LON_SUMMARY_INFO` → `LON_TYPE_CODE`；查 `TB_REVISED_ITEM` → `ITEM1~14`+`REASON_MEMO`（無則 blank）。**as-is ✅**（left join、null→""）。

### R3 — 至少勾 1 項　`covers-prd: REQ-003`
未勾任一 → 前端阻擋送出。**as-is ✅**。

### R4 — REASON_MEMO 必填 / maxlength **3000** / trim　`covers-prd: REQ-003`
必填、上限 **3000**、需 trim；BE 亦應驗。**as-is ⚠️**：maxlength=**4000**、未 trim、BE DTO 未驗 → RD 修。

### R5 — ITEM1 受 `LON_TYPE_CODE=03` 強制　`covers-prd: REQ-003`（業務原因 → `@PENDING RP2`）
`=03` → ITEM1 強制勾且**不可編輯**；`≠03` → 強制不勾且不可編輯。**as-is ⚠️**：會強制勾回但欄位未 disabled；非 03 且 DB ITEM1=Y 仍可編輯 → RD 修。

### R6 — ITEM3 受 `isCU` 強制　`covers-prd: REQ-003`
`isCU=true` → ITEM3 強制不勾且不可編輯。**as-is ⚠️**：用 `secureAttribute==='U'` 而非 `attrMap.isCU` → 確認等價。

### R7 — `isEdit=false` 全唯讀 + 隱藏完成鈕　`covers-prd: REQ-003`
**as-is ⚠️**：靠 auth `canEditList`/`isShowList` 達成、非直接綁 `isEdit` → 確認等效。

### R8 — 變更提示　`covers-prd: §2.3 / §3.1-6`
checkbox 與既有不同 → 送出前提示「移除 Revised Item 會清除相關修改」。**as-is ✅**。

### R9 — blank/N/Y 正規化　`covers-prd: §5.3.2`
init-query 允許 blank；execute request / DB **只允許 Y/N**；FE 送出前 blank→N；BE 不得存 blank。**as-is**：FE ✅；**BE 🔴**（`InsertRevisedItemRequest` 無 `@Pattern`，可存非 Y/N）→ RD 修。

### R10 — execute = POST + **單一 transaction**　`covers-prd: REQ-004 / §9`
execute 為 **POST**；整個儲存（刪/複製/insert/checkpoint）在**單一 `@Transactional`**，任一失敗整批 rollback。**as-is 🔴🔴**：BE GET；**無外層 `@Transactional`** → 多表刪/還原可**半更新＝資料遺失風險**（最高優先）。

### R11 — execute 後端二次比對為準　`covers-prd: §5.4.1`
重查 DB 既有 `ITEM1~14`、與 request 正規化結果比對，作為觸發側效之**唯一依據**；`isNotSame` 僅前端提示輔助、**不得作判斷依據**；查無既有 → 全部視為 N。**as-is ⚠️**：有重查，但側效仍被 `request.getIsNotSame()` gate；僅 ITEM2 特判 null → RD 修。

### R12 — 刪+insert TB_REVISED_ITEM　`covers-prd: §5.4-6/7`
刪目前 `APPLICATION_NO` 的 `TB_REVISED_ITEM` → insert `ITEM1~14`+`REASON_MEMO`+`UPD_DATE`。**as-is ✅**。

### R13 — 關聯資料清除/還原矩陣 RI-MAT　`covers-prd: REQ-005 / §5.5`　**⚠️ 受 `@PENDING RP1`（TBD-006）控制**
> 下列為 source-confirmed 行為；**「是否保留」待 TBD-006**。各條附 as-is。
- **R13.1 RI-MAT-001**（ITEM2 Y→N）：刪 `GUARANTOR_INFO`/`_CORP`，由 `REF_APPLICATION_NO` 複製還原 + 還原 `IS_ANY_GUARANTOR`。as-is ⚠️：取 `baseInfo.refApplicationNo/lonTypeCode` 傳**空值**（還原失效）。
- **R13.2 RI-MAT-002**（ITEM2 N→Y，reference 無 guarantor）：borrower `IS_ANY_GUARANTOR=Y`。as-is ⚠️：缺「reference 無 guarantor」判斷。
- **R13.3 RI-MAT-003**（ITEM3 Y→N）：刪 collateral/valuation/site-visit/title/provider/owner，由 reference 複製 + 更新 `IS_ANY_COLLATERAL_PROVIDER`。as-is ⚠️：未更新 `IS_ANY_COLLATERAL_PROVIDER`。
- **R13.4 RI-MAT-004**（ITEM1/4~11 特定組合）：刪 `LOAN_CONDITION_DETAIL`+`REVISED_ITEM_DETAIL`，相關 page menu 標重處理。as-is ⚠️：page menu 標 0110~0160（非 §5.6 清單，見 R14）。
- **R13.5 RI-MAT-005**（ITEM1/4~11 Y→N）：從原始 detail 還原欄位（§5.5.2 矩陣）+ 更新 `REVISED_ITEM_DETAIL`。as-is ⚠️：ITEM10/11 else ITEM1 疑錯欄、受 isNotSame gate。
- **R13.6 RI-MAT-006**（`LON_TYPE=04` 且 ITEM12 N→Y）：刪 `LOAN_CONDITION_FEE`（業務原因 → `@PENDING RP3`）。**as-is ✅**。
- **R13.7 RI-MAT-007**（ITEM13/14）：→ `@PENDING RP5`（TBD-007）。as-is：只持久化、未做側效（保守、可接受）。

### R14 — Checkpoint / Page Menu 更新　`covers-prd: REQ-006 / §5.6`
依 `IS/IU/CS/CU` 寫對 checkpoint 表（`TB_CHECK_POINT_RC` / `_IU` / `_CORP` / `_CU`）、標 `EPRO{IS/IU/CS/CU}_0260`；execute 回傳 `pageMenuCondition`（§5.6 重處理頁清單，如 IS：0210/0220/0230/0250/0290）。**as-is 🔴**：標 `EPROZ00800`/`0160`/`0110~0150`（非 `_0260`）；`pageMenuCondition` **未回傳** → RD 修。

### R15 — 錯誤處理　`covers-prd: REQ-007 / §6.4 / §8`
`MSG_INITIAL_FAIL`(prompt)、`COMMON_MSG_ERROR_LON`/`MSG_DATA_NOT_FOUND`(init/execute)、`COMMON_MSG_SAVE_FAIL`(execute rollback)、`COMMON_MSG_SAVE_SUCCESS`。**as-is ⚠️**：無 RevisedItem 專屬 mapping。

### R16 — 非功能　`covers-prd: §9`
單一 transaction（→R10）；init-query≤3s / execute≤5s（大量複製另測）；log 含 requestId/applicationNo/userId/action/result/耗時、敏感遮罩；execute 留 audit；維持 IS/IU/CS/CU 四態 checkpoint。

## 🚩 @PENDING（PRD TBD → 規則，須 owner 關閉才實作）
| id | 待決（PRD TBD）| 影響規則 | owner |
|---|---|---|---|
| **RP1-PENDING** | **TBD-006：保留 legacy 清除/還原副作用，或改明確使用者確認流程** | **R13 全部** | PM/SA/RD |
| RP2-PENDING | TBD-003：`LON_TYPE=03` 強制 ITEM1 之業務原因 | R5 | SA |
| RP3-PENDING | TBD-004：`LON_TYPE=04` ITEM12 N→Y 刪 fee 之業務原因 | R13.6 | SA/RD |
| RP4-PENDING | TBD-005：ITEM1 與 ITEM10 皆 TENOR（legacy 設計 or 缺陷）| R13.4/5 | RD/SA |
| RP5-PENDING | TBD-007：ITEM13/14 是否有下游資料影響 | R13.7 | SA/RD |
| RP6-PENDING | TBD-001：ITEM1~14 正式業務名稱（DB code table）| 畫面顯示 | SA |
| RP7-PENDING | TBD-002：`Finshed` → `Finished` | UI 文字 | PM/UX/RD |

## Trade-offs（架構取捨）
- **RI-MAT 側效保留 legacy vs 改使用者確認流程**：核心取捨，**待 TBD-006**；若改使用者確認流程，R13/R11 大改 → 寫成 ADR 後再定版。
- **side-effect 判定來源**：以「DB 二次比對」（R11）為準 vs 信前端 `isNotSame`——SRS 選前者（正確性 > 省一次查詢）。
> 重大取捨關閉後補 `docs/adr/ADR-NNNN-EPROZ00800-*.md`。

## Traceability Matrix（PRD REQ → Rn → QA）
| PRD REQ | Rn | QA covers |
|---|---|---|
| REQ-001 | R1 | QA-018 |
| REQ-002 | R2 | QA-001, QA-002 |
| REQ-003 | R3,R4,R5,R6,R9 | QA-003,004,005,006,014,017 |
| REQ-003 | R7,R8 | QA-019, QA-020 |
| REQ-004 | R10,R11,R12 | QA-012,013,015,021 |
| REQ-005 | R13.1–13.5（@PENDING RP1）| QA-007,008,009 |
| REQ-005 | R13.6 fee（as-is ✅；業務原因 RP3）| QA-010 |
| REQ-005 | R13.7 ITEM13/14 | @PENDING RP5 |
| REQ-006 | R14 | QA-011,016 |
| REQ-007 | R15 | QA-012（rollback）；成功/not-found path 尚無實 case → QA-022（RD 補，未撰寫）|
| §9 NFR | R16 | QA-012（transaction）；perf/log/audit（RD 補）|

## 硬界線
- **不得自行裁定 ITEM 業務名稱**（RP6）、**不得把 legacy 側效當已核准需求**（RP1 未關前 R13 不定版）。
- execute 必須單一 transaction（R10）——此條與 TBD 無關、**最高優先可先修**。
- as-is 的 `file:line` 證據見 `00800-verification-findings.md`；實作以該頁現碼 + 本 SRS to-be 為準。

## as-is → to-be 摘要（給 RD）
- **可先修（與 TBD 無關）**：R10 transaction（資料風險）、execute→POST、R9 BE Y/N 驗證、R14 回 pageMenuCondition + 改 `_0260`、R4 maxlength 3000。
- **待 RP1（TBD-006）**：R13 整個 RI-MAT 引擎正確性（含 R11 isNotSame gate 移除、R13.1~13.5 諸 bug）。
