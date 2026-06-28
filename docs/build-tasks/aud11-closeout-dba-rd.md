# Build Task — AUD-11 收尾：併頁裁決已關；`:597` checkpoint key 轉企金 parity

> **2026-06-28 closeout**：新版 owner Excel `function-review.xlsx` / `查核總表` target 欄 `E137:E140` 是 merged cell，視覺值全為 `EPROCSU0160`；因此 `EPROCU_0160/0260` 併入 `EPROCSU0160`，`EPROCU0160` 非新 target。AUD-11「併 vs 分」三判＝(b) 刻意演進·縮編 + (c) DB 結構差，已關。
> **剩餘風險**：`CsuLoanConditionServiceImpl:597` 讀 `EPROISU0160`（個金 key）仍是 checkpoint potential regression，轉入 `c0-legacy-parity-recheck.md` 的 EPROCSU0160 五維度補比，不再作為 AUD-11 開口。
> **背景全文**：`refactor-audit/owner-inventory-reconcile.md §3 F-OWN-4`、`pending-register` AUD-11 closed row、`done/aud11-cu0160-page-reverify-findings.md` closeout。
>
> 命名前綴：`CS`＝企金有擔、`CU`＝企金無擔、`CSU`＝新併頁（CS+CU）、`ISU`／`IS`／`I0`＝**個金**（individual）。企金服務讀到 `ISU` key ＝跨域、可疑。

---

## 任務 A（DBA）— `TB_PAGE_MENU` routing row 唯讀查證（superseded）

> Superseded by owner Excel 2026-06-28 merged-cell target 裁決；保留本節作歷史派工背景。

**為什麼**：新系統頁籤顯示由「`TB_PAGE_MENU` 查 `PAGE_CODE` → 拆 `pageMap`」決定（`backend/.../repository/TBPageMenuRepository.java:16-24` 以 `lonAttribute/secureAttribute/productCode/lonTypeCode` 查 `PAGE_CODE`；`TBPageMenuEntity.java:21-34` 定義欄位）。本 checkout **只有 schema＋查詢邏輯、無 row data** → 無法決定性證明「企金無擔 × 0160」這條 routing 的 `PAGE_CODE` 究竟是 `EPROCSU0160`（併）還是 `EPROCU0160`（分）。

**做什麼**：在真 DB（兩 schema `OVSLXLON01`/`OVSLXLON02` 都查，企金通常落 `OVSLXLON02`）跑唯讀 SQL：

```sql
SELECT LON_ATTRIBUTE, SECURE_ATTRIBUTE, PRODUCT_CODE, LON_TYPE_CODE, PAGE_CODE
FROM TB_PAGE_MENU
WHERE LON_ATTRIBUTE  = 'C'     -- C = 企金
  AND SECURE_ATTRIBUTE = 'U'   -- U = 無擔
  AND PAGE_CODE LIKE '%0160%';
```

**回報**：把 query 結果（每列 `PAGE_CODE` 全文）貼回。關鍵只看一件事——**無擔×0160 的 `PAGE_CODE` 是 `EPROCSU0160` 還是 `EPROCU0160`？**（若兩 schema 不一致，兩邊都回報。）

> ⚠️ 唯讀；不 UPDATE/DELETE；若 `LON_ATTRIBUTE`/`SECURE_ATTRIBUTE` 代碼與此處假設不同（如企金非 `C`、無擔非 `U`），先回報實際代碼字典再調 WHERE。

---

## 任務 B（RD）— `CsuLoanConditionServiceImpl:597` checkpoint key 判 bug（轉企金 parity）

**為什麼**：服務先依 `secureAttribute` 選 CS 或 CU checkpoint 表（`backend/src/main/java/khd/svc/epro/service/corporate/impl/CsuLoanConditionServiceImpl.java:590-596`，分流**存在**），但 **`:597` 讀的 key 是 `StringUtil.nvl(sql9Entity.get("EPROISU0160"))`**——`ISU`＝**個金**前綴，而新企金 CS/CU checkpoint 表欄位皆為 **`EPROCSU0160`**（`TBCheckPointsCsEntity.java:53-54`、`TBCheckPointsCuEntity.java:50-51`；CS/CU 建案 `NewCaseUtil.java:556-564/628-635` 也都寫 `insertCheckMap.get("EPROCSU0160")`）。→ 像是**從個金 twin 複製忘了改前綴**，使「CU 分流完全正確」不能成立。

**做什麼**：
1. 看 `CsuLoanConditionServiceImpl.java:590-600` 上下文，確認 `sql9Entity` 來源欄位實際 key 名（是 `EPROCSU0160` 還是真有 `EPROISU0160`）。
2. 判定：
   - **bug**（最可能）：應讀 `EPROCSU0160`、誤植個金 key → 修正字串；確認修正後 CS（有擔）/CU（無擔）兩路 checkpoint 讀寫都正確。
   - **刻意共用**：若 `sql9Entity` 真有 `EPROISU0160` 欄且設計上共用個金 key（需有依據）→ 文件化原因、不改。
3. **影響評估**：此 key 若讀錯，企金 0160 Loan Condition 的 checkpoint 狀態判斷可能失準（不只分類問題、是 runtime 正確性）→ 不論 AUD-11 typo 結論如何，這條都該獨立判。

**回報**：`:597` 結論（bug→已修 commit / 刻意→原因），附修正 `file:line` 或佐證；落點改為 `c0-legacy-parity-recheck.md` / `per-page-reinventory-matrix.md` 的 EPROCSU0160 disposition。

---

## 舊結案門檻（superseded）

> 2026-06-28 起不再以任務 A 決定 AUD-11；`EPROCU0160` vs `EPROCSU0160` 已由 owner Excel 裁定。下表保留歷史。

| 任務 A（SQL `PAGE_CODE`）| 任務 B（`:597`）| → AUD-11 |
|---|---|---|
| 含 **`EPROCSU0160`** | 修/確認後 CU flow 正常 | ✅ **typo／已正確併入** → 關案，`feature-inventory §1` 維持併（註證據），頁級覆蓋 66/67→67/67 |
| 含 **`EPROCU0160`** | — | 🔴 **真分歧／缺口** → 新系統無對應 FE/BE，開補建獨立頁卡、`feature-inventory §1` 改分列 |
| 查無 row / 代碼不符 | — | ⏸ UNFOUND 維持，回報代碼字典再議 |

## 鐵則
1. 任務 A 唯讀（SELECT only）；任務 B 若修為單獨 commit、先報 diff 供人審才推 product repo（金錢/檢核外的小修，仍守 §6.7 紀律）。
2. 「併 vs 分」決定性證據＝ **pageMap routing row**（任務 A），非名稱；owner 表名 ≠ 新系統 page code。
3. 推不出＝UNFOUND，不拿 page-mapping/inventory 當證據（它們正是待驗對象）。

## 回報落點
findings 併入 `done/aud11-cu0160-page-reverify-findings.md`（同檔追加「收尾」節）或新 `done/aud11-closeout-findings.md`；回填 `owner-inventory-reconcile §5.3`/`§1`、`feature-inventory §1`、`pending-register` AUD-11、`STATUS §五`。
