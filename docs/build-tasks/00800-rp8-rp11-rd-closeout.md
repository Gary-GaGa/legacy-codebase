# Build Task — EPROZ00800 RP8 / RP11 as-is 等價性 + DTO 形狀（RD 收尾）

> **性質**：兩個 `spec.md §@PENDING`（**仍開**）——皆需 **RD 對產品碼判斷**（判據等價、DTO 形狀），planning repo 解不了。**只 RD 能結。**
> **背景**：`docs/archive/EPROZ00800-v0.9-superseded/srs/spec.md §@PENDING`（RP8/RP11；**v0.9 封存·待重產**，2026-06-17）、as-is 碼位置見 `docs/build-tasks/00800-verification-findings.md`（產品碼在開發機）。⚠️ 00800 disposition=REBUILD：RP8/RP11 判定為重產輸入，新 SRS 產出時承載。
> **注意**：00800 標「砍掉重建在即」（Bible/PRD 待更新）；RP8/RP11 的 as-is 判定**結果會餵進重建**，故先由 RD 坐實，不隨重建空等。

---

## 任務 A（RD）— RP8：R6/R7 的 as-is 判據與 to-be 是否全情境等價

to-be 規則寫的判據與 as-is 現碼用的判據**不同名**，需 RD 對產品碼確認**是否所有情境都等價/等效**（QA-006/QA-019 只驗 to-be 行為表象、不驗判據；QA-023＝@PENDING 待補 case）。

| 規則 | to-be 判據（spec）| as-is 現碼判據 | RD 要確認 |
|---|---|---|---|
| **R6**（ITEM3 受 CU 強制不勾不可編）`spec.md:57-58` | `attrMap.isCU` | `secureAttribute==='U'` | `isCU` 與 `secureAttribute==='U'` 是否**所有情境**同值？（有無 `secureAttribute` 為 U 但非 CU、或 CU 但非 U 的案件型態？）|
| **R7**（`isEdit=false` 全唯讀+隱藏完成鈕）`spec.md:60-61` | `isEdit` | auth `canEditList`/`isShowList` | 靠 auth 清單達成的唯讀，是否與直接綁 `isEdit` **全情境等效**？（有無 `isEdit=false` 但 auth 清單仍允許編輯、或反向的破口？）|

**做什麼（唯讀為主）**：
1. 在產品碼找 R6/R7 的 as-is 實作點（起點＝`00800-verification-findings.md` 的 file:line），讀 `secureAttribute`/`isCU`、`canEditList`/`isShowList`/`isEdit` 的賦值與分支。
2. 判定每條：**等價**（→ 確認 to-be 可安全用 `isCU`/`isEdit`，as-is 判據係等效實作）/ **不等價**（→ 列出分歧情境，定哪個為正確 to-be）。

**回報**：RP8 兩條各一句結論（等價/不等價＋分歧情境）＋ file:line；回填 `spec.md §@PENDING RP8`、補 **QA-023**（判據等價性 case）。

---

## 任務 B（RD）— RP11：execute request body DTO 形狀

execute（`epl-case-insert-reviseditem`）request body 形狀 to-be 與 as-is 不一致，需 RD 定契約：

| | 形狀 | 出處 |
|---|---|---|
| **to-be** | `itemMap.item1..14`（巢狀 map）| `spec.md §@PENDING RP11`、openapi `InsertRevisedItemRequest` |
| **as-is** | 平鋪欄位（現碼）| `00800-verification-findings.md` |

**做什麼**：
1. 看現碼 execute 實際收的 request body 形狀（平鋪欄名）。
2. 定 DTO：**改 DTO 對齊 openapi `itemMap`**、或 **改 openapi 對齊現碼平鋪**——擇一，使 spec/openapi/碼三者一致（牽動 **R10/R12 契約**）。
3. **順帶（S-3）**：openapi 目前讓 client 送整個 `checkPointMap`（`openapi.yaml:68,91-96`），與 R14「BE 自行依 attribute 寫 checkpoint」、R11「後端為準/不信前端」有張力。定 DTO 時一併界定 **`checkPointMap` 哪些 key 由 BE 權威**（RP11 原只涵蓋 itemMap、未涵蓋此）。

**回報**：RP11 DTO 形狀決定（含 checkPointMap 權威界定）＋ file:line；回填 `spec.md §@PENDING RP11`、`openapi.yaml`、R10/R12。

---

## 結案
- RP8 兩條等價性判定 + QA-023 補 → `spec.md §@PENDING RP8` 標 ✅。
- RP11 DTO 形狀定版 + openapi/R10/R12 對齊 → `spec.md §@PENDING RP11` 標 ✅。
- 兩者 ✅ 後，00800 的「仍待」只剩重建相關（BP-1~5 seam + SR-B1/B2 折進重建）。

## 鐵則
1. as-is 以產品碼現碼為準（`00800-verification-findings.md` 為起點索引）；每結論附 file:line。
2. 「等價/不等價」「DTO 形狀」是契約定版題 → RD 裁；改碼為單獨 commit、先報 diff 供人審。
3. 推不出＝停手回報，不猜。

> 採納後若改動 R6/R7 或 openapi request schema → 比照 SRS 紀律**再過一輪** `spec-reviewer` + `check-srs-bundle`。
