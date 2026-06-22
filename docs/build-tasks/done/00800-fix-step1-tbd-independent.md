# Build Task — `EPROZ00800` Revised Item：TBD-無關硬缺陷修正（D1–D5）

> 載具：Codex（後端為主，D5 含一處前端）。**規格來源＝SRS bundle** `docs/golden-template/boundary-bundle/EPROZ00800/`（`spec.md` 的 `Rn` + `openapi.yaml` + `qa-cases.md`）；**as-is 證據＝** `docs/build-tasks/done/00800-verification-findings.md`（file:line）。
> **落地**：master-direct；**單一 commit、build 綠、報 diff 等審**。
> ⚠️ **只修「與 TBD 無關的硬缺陷」**（D1–D5）。**RI-MAT 側效引擎（R13 / findings S1–S8）整批不准動**——受 PRD `TBD-006`（是否保留 legacy 側效）+ `§5.6` + SA 裁定控制，現在改＝賭 TBD 不翻盤。

## 目標
對既有 `RevisedItemController` / `RevisedItemServiceImpl` / DTO / entity（brownfield，現碼 file:line 見 findings），套 SRS to-be 的 **5 個 TBD-無關修正**。每項標 `Rn` + `Dn` + QA。

## 範圍內（IN）— 逐項
| # | 修什麼 | as-is 證據 | to-be（SRS）| QA |
|---|---|---|---|---|
| **D1 / R10** ⭐最高 | execute（刪/複製/insert/checkpoint）**包單一 `@Transactional`**，任一失敗整批 rollback | `RevisedItemServiceImpl:73,173-191`（多表各自交易→半更新＝**資料遺失風險**）| 整個 execute 一個 transaction 邊界 | QA-012 |
| **D2 / R10** | execute method **GET→POST**（會刪改資料）| `RevisedItemController:52`（GET）| POST | QA-013 |
| **D3 / R9** | BE 驗 item **只允許 Y/N**（拒絕或正規化非 Y/N；blank 不得入庫）| `InsertRevisedItemRequest:22-29` 無 `@Pattern`、`RevisedItemServiceImpl:572-581` 直接 insert | DTO 加 `@Pattern(Y/N)` 或 service 正規化 | QA-014 |
| **D4 / R14** | **回傳 `pageMenuCondition`**（response DTO 補欄並填值，FE 才能更新頁籤重處理狀態）| `InsertRevisedItemResponse:5-11` 缺欄 | response 含 `pageMenuCondition` | QA-016 |
| **D5 / R4** | `REASON_MEMO` maxlength **4000→3000** + **trim** + **BE 驗**（前後端一致）| `validate-rule.ts:32-37`(FE 4000)、`TBRevisedItemEntity:17`、BE DTO 未驗 | FE 3000 + BE `@Size(max=3000)` + trim | QA-017 |

## 範圍外（OUT，**不准碰**）
- **R13 整個 RI-MAT 側效引擎**（findings S1–S6：ITEM2/3、ITEM1/4~11 的刪/還原/還原失效/欄位疑錯/isNotSame gate）→ 待 `TBD-006`/SA。
- **checkpoint `_0260` key 重映射**（findings S7）→ 待 PRD `§5.6` 的確切 key 清單（openapi 標 `@PENDING(checkpoint-keys)`）。**D4 只加 `pageMenuCondition` 回傳，不改 checkpoint 寫入的 key 值**。
- **init-query method**（GET vs POST）→ SRS 標 `@PENDING(method)`，RD/架構未定，**不在本次改**（只動 execute）。
- 錯誤碼專屬 mapping（S8）、FE ITEM1/3/isEdit 規則微調（部分 TBD）→ 另案。

## 鐵則
1. **D1 是骨幹**：先把 execute 包成單一 transaction，再做其餘；確認 rollback 涵蓋所有刪/複製/insert/checkpoint 寫入。
2. **嚴守 IN/OUT 界線**：碰到 RI-MAT 側效邏輯（S1–S7）**只讀不改**；本次任何 diff 不得改變側效行為（除非純粹被 transaction 包覆）。
3. 對齊 SRS `Rn` 與 `openapi.yaml`（D2 POST、D3 ItemFlag Y/N、D4 response `pageMenuCondition`、D5 `maxLength:3000`）。
4. build 綠；**單一 commit**（標 `EPROZ00800` + D1–D5）；報 diff。

## 回報
- diff 範圍 + 主要檔案；**確認 execute 已單一 `@Transactional`、rollback 範圍**；D2–D5 各一句落點。
- **明確聲明未動 R13/S1–S7 側效、未改 init-query method、未改 checkpoint key 值**。
- build 結果；可跑的 QA（QA-013/014/017 屬靜態/單元可驗）；**QA-012 rollback 整合測標 deferred-to-DB**（DB 未通，本次不跑、列待測）。
- `git status --short`（應乾淨）。

> 過了：00800 的「資料風險」項清除；剩 S1–S8 側效引擎等 `TBD-006`/§5.6 裁定（PM/SA/RD）後另案。
