# EPROZ00800 Revised Item — 驗證結果（vs PRD CDC-EPRO-0001 v1.1）

> 2026-06-08 Codex 唯讀稽核（基準 `C:\project\legacy-codebase`）對 PRD 比對結論。
> **總評：結構在、行為不對等**（與撥貸同模式）——RI-MAT 副作用引擎**部分實作**、含資料風險與多處 bug。**先前 cross-check 只說「method 不符」嚴重低估。**
> ⚠️ **PRD 是 Draft、TBD-006「是否保留 legacy 側效」未決** → **側效類修正先別動，等 PM/SA 裁**；只先修「與 TBD 無關的硬缺陷」。

## 三句結論
1. **execute method 錯**：`RevisedItemController:52` execute=GET、FE 送 POST、PRD 要 POST → **改 BE 為 POST**（query 亦 FE-POST/BE-GET 不符，PRD 說 init-query=GET → 一併對齊）。
2. **RI-MAT 副作用＝部分實作**：ITEM2/3、ITEM1/4~11、ITEM12 有分支，但有缺陷 + checkpoint/page-menu 標錯。
3. **後端二次比對未達 PRD §5.4.1**：有重查 DB 既有 revised item，但**側效仍被 FE `isNotSame` gate 控制**（PRD 要求以 DB 比對為準、不可信前端旗標）。

## 🔴 TBD-無關硬缺陷（可先修，不等 TBD）
| # | 缺陷 | 證據 | 嚴重度 |
|---|---|---|---|
| D1 | **execute 無外層 `@Transactional`**；多表刪/複製/insert 各自交易 → **失敗可半更新**（刪了 guarantor/collateral 卻沒還原＝**資料遺失風險**）| `RevisedItemServiceImpl:73,173-191` | 🔴🔴 最高（資料完整性）|
| D2 | execute=GET 應 POST（會刪改資料）| `RevisedItemController:52` | 🔴 |
| D3 | BE 未驗 item Y/N（`InsertRevisedItemRequest` 無 `@Pattern`、直接 insert）→ 可存非 Y/N/blank（違 PRD §5.3.2）| `InsertRevisedItemRequest:22-29`、`RevisedItemServiceImpl:572-581` | 🔴 |
| D4 | `pageMenuCondition` 未回傳（response DTO 缺）→ 前端無法更新頁籤重處理狀態（違 PRD §6.3/GOAL-003）| `InsertRevisedItemResponse:5-11` | 🟠 |
| D5 | `REASON_MEMO` maxlength=**4000**（PRD 要 3000）、未 trim、BE 未驗 | `validate-rule.ts:32-37`、`TBRevisedItemEntity:17` | 🟠 |

## 🟠 側效/規則正確性（**待 PRD TBD-006 + SA 裁定後**再修，勿先改）
| # | 出入 | 證據 | 依賴 |
|---|---|---|---|
| S1 | 側效被 `request.getIsNotSame()` gate（應以 DB 二次比對為準，§5.4.1）| `RevisedItemServiceImpl:181-189,219-229,242-253` | TBD-006 |
| S2 | RI-MAT-001（ITEM2 Y→N）：取 `baseInfo.refApplicationNo/lonTypeCode` 但 baseInfo 即 ref → **傳空值**（還原失效）| `:316-345`、`FunctionServiceImpl:589-597` | bug，SA 確認後修 |
| S3 | RI-MAT-002（ITEM2 N→Y）：缺「reference 無 guarantor」判斷 | `:346-353` | SA |
| S4 | RI-MAT-003（ITEM3 Y→N）：未更新 `IS_ANY_COLLATERAL_PROVIDER` | `:357-413,436-446` | SA |
| S5 | RI-MAT-004：page-menu 標 `0110~0160`，**非 PRD §5.6 清單**（0210/0220/0230/0250/0290…）| `:584-602,691-719` | PRD §5.6 |
| S6 | RI-MAT-005：ITEM10/ITEM11 else ITEM1 **疑錯欄**，且仍受 isNotSame gate | `:509-566,605-689` | SA/TBD-005 |
| S7 | Checkpoint 標 `EPROZ00800`/`EPROISU0160`/`0110~0150`，**未對上 `EPRO{IS/IU/CS/CU}_0260`**（PRD §5.6）| `:722-762` | PRD §5.6 |
| S8 | 錯誤碼無 RevisedItem 專屬 mapping（MSG_INITIAL_FAIL / COMMON_MSG_ERROR_LON / COMMON_MSG_SAVE_FAIL）| `RevisedItemServiceImpl:199`、`ReturnEnum` | PRD §6.4 |

## ⚠️ FE 規則出入（小、可修；部分待 TBD）
- ITEM1（LON_TYPE=03）：會強制勾但欄位未 disabled；非 03 且 DB ITEM1=Y 仍可編輯（`revised-item.ts:68-73`）。
- ITEM3 isCU：用 `secureAttribute==='U'` 非 `attrMap.isCU` → 確認等價。
- isEdit=false：靠 auth canEditList/isShowList 達成、非直接綁 `attrMap.isEdit` → 確認等效。
- 查無既有 ITEM：只 ITEM2 特判 null，未全面正規化為 N。

## ✅ 符合
至少勾 1 項、變更提示、init-query blank、FE blank→N、刪+insert REVISED_ITEM、**RI-MAT-006**（LON_TYPE=04 ITEM12 N→Y 刪 fee）。

## ⏸ TBD
RI-MAT-007（ITEM13/14）：PRD 本就 TBD；BE 目前只持久化、**未亂做側效**（正確的保守做法）。

## 建議
- **00800 不在當前關鍵路徑**（c0 FE / 撥貸）→ 不急著全修。
- **可先修 D1–D3**（尤其 **D1 transaction＝資料風險**,與 TBD 無關）；D4/D5 視情況。
- **S1–S8 + ITEM 規則 → 升級 PM/SA/RD**：先關 PRD **TBD-006**（保留 legacy 側效 or 改使用者確認流程）+ **TBD-003/004/005**（ITEM 規則）,再決定側效引擎怎麼修。否則照 legacy 硬修、TBD-006 若翻盤就白做。
- 回填：本結果 + PRD 的 TBD 進 `feature-inventory.md`（00800 由「半成品」升為「結構在、行為不對等」）。
