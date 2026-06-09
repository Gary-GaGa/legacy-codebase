# 驗證 — EPROZ00800 Revised Item 對 PRD（CDC-EPRO-0001 v1.1）唯讀稽核

> **目的**：拿 PRD `CDC-EPRO-0001 v1.1`（EPROZ00800 Revised Item）當 oracle，稽核**新系統現有 EPROZ00800 FE + BE** 符合度。**唯讀**，不改碼（結束 `git diff` 空）。
> **PRD 身分校準**：PRD 是 **PM Review Draft、有 TBD-001~007 未關**，且明示「legacy 行為 ≠ 已核准需求」。故：
> - **source-confirmed 規則**（行為/method/矩陣/checkpoint）→ 硬驗，標 ✅符合 / 🔴缺 / ⚠️出入。
> - **TBD-依賴**（ITEM 業務名稱、是否保留 legacy 副作用…）→ 標 **⏸ 待決**，不判對錯，不自行推論 ITEM 名稱。
> **endpoint 校準**：PRD §6 的 `/api/eproposal/...` REST 是**理想化**；新系統實際是 RPC `epl-*`。**對真實 `RevisedItemController` + `revised-item` 前端驗 method + 行為，不比字面路徑。**
> 啟動：前端專案（母資料夾，可同讀後端）。

## A. API method / 動作（先驗這個——解 method 不一致）
PRD §6.1：prompt=**GET**、init-query=**GET**、**execute=POST**（execute 會刪改資料）。
- [ ] 列出 `RevisedItemController` 實際 endpoint + 各自 HTTP method（`file:line`）。
- [ ] **execute（儲存）是否為 POST?** cross-check 曾見「BE 兩個 endpoint 皆 GET、FE 用 POST」→ 確認:**execute 該 POST、BE 若是 GET = bug**（PRD 站 FE）。標 🔴 並指出該改哪邊。
- [ ] FE `revised-item` service 打的 method 是否與 BE 一致。

## B. 畫面 / 驗證規則（PRD §5.3）
- [ ] 至少勾 1 項 Revised Item 才可送出。
- [ ] `REASON_MEMO` 必填、maxlength 3000、trim。
- [ ] `LON_TYPE_CODE=03` → ITEM1 強制勾且不可編輯；非 03 → ITEM1 強制不勾且不可編輯。
- [ ] `attrMap.isCU=true` → ITEM3 強制不勾且不可編輯。
- [ ] `attrMap.isEdit=false` → 全欄唯讀 + 隱藏完成按鈕。
- [ ] checkbox 狀態與既有不同 → 送出前提示「移除 Revised Item 會清除相關修改」。

## C. blank / N / Y 正規化（PRD §5.3.2）
- [ ] init-query 回傳允許 blank（尚未建資料）。
- [ ] execute request / DB 寫入**只允許 Y / N**；FE 送出前把 blank 正規化為 N；BE 不得存 blank。

## D. Backend execute 邏輯（PRD §5.4 / 5.4.1）— 正確性重點
- [ ] execute 在**單一 transaction** 內。
- [ ] **重查 DB 既有 ITEM1~14 與 request 二次比對**作為觸發清除/還原的依據；**不可只信前端 `isNotSame`**（isNotSame 僅輔助）。
- [ ] 查無既有 → 既有 ITEM 視為 N。
- [ ] 流程：刪目前 APPLICATION_NO 的 `EPRO_TB_REVISED_ITEM` → insert 新（ITEM1~14 + REASON_MEMO + UPD_DATE）。

## E. 🔍 關聯資料清除/還原矩陣（PRD §5.5.1，RI-MAT-001~007）— 最可能的大缺口
逐條確認 BE **有無實作**（不是只存 ITEM 值）：
- [ ] **RI-MAT-001** ITEM2 Y→N：刪 `GUARANTOR_INFO`/`_CORP`，由 `REF_APPLICATION_NO` 複製還原 + 還原 `IS_ANY_GUARANTOR`。
- [ ] **RI-MAT-002** ITEM2 N→Y 且 reference 無 guarantor：borrower `IS_ANY_GUARANTOR=Y`。
- [ ] **RI-MAT-003** ITEM3 Y→N：刪 collateral/valuation/site-visit/title/provider/owner，由 reference 複製 + 更新 `IS_ANY_COLLATERAL_PROVIDER`。
- [ ] **RI-MAT-004** ITEM1/4~11 特定組合：刪 `LOAN_CONDITION_DETAIL` + `REVISED_ITEM_DETAIL`，相關 page menu 標需重處理。
- [ ] **RI-MAT-005** ITEM1/4~11 Y→N：從原始 loan condition detail 還原對應欄位（§5.5.2 欄位矩陣）+ 更新 `REVISED_ITEM_DETAIL`。
- [ ] **RI-MAT-006** `LON_TYPE_CODE=04` 且 ITEM12 N→Y：刪 `LOAN_CONDITION_FEE`。
- [ ] **RI-MAT-007** ITEM13/14：PRD 標 source 無明確規則 → ⏸ 待決，確認新碼**有沒有**亂做。
> 結論請明說：**RI-MAT 副作用引擎是「已實作 / 部分 / 完全沒做」**。這比 method bug 重要得多。

## F. Checkpoint / Page Menu（PRD §5.6）
- [ ] 依 IS/IU/CS/CU 寫對 checkpoint 表（`CHECK_POINT_RC` / `_IU` / `_CORP` / `_CU`）、標 `EPRO{IS/IU/CS/CU}_0260`。
- [ ] 回傳 `pageMenuCondition`，相關頁籤（§5.6 清單，如 IS 的 0210/0220/0230/0250/0290）標需重處理。

## G. 錯誤處理（PRD §6.4 / 8）
- [ ] `MSG_INITIAL_FAIL`(prompt)、`COMMON_MSG_ERROR_LON`/`MSG_DATA_NOT_FOUND`(init/execute)、`COMMON_MSG_SAVE_FAIL`(execute rollback)、save success 有對上。
- [ ] 非功能（§9）：execute 失敗整批 rollback、無部分更新。

## 回報格式
一張表：`檢查項 | 判定(✅符合/🔴缺/⚠️出入/⏸TBD) | 證據(file:line) | 說明`。**最前面給三句結論**：
1. execute method 對不對（POST？）；
2. **RI-MAT 副作用引擎實作程度**（全/部分/無）；
3. 後端二次比對（§5.4.1）有沒有做。
末附 `git diff --name-only`（應空）。**判不準/TBD-依賴 → 標出、別硬判。**
