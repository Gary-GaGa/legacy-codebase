# Build Task — `EPROCU0160` 企金無擔 Loan Condition 頁碼驗（AUD-11；owner 盤點 F-OWN-4）

> **性質**：唯讀碼驗（Codex 母資料夾，新後端 + 前端 + legacy 對照）。**只報不改**。小卡、單一問題。
> **背景**：owner 權威盤點表（`legacy/legacy-function-inventory.md`）對企金 cs/cu 的併頁口徑**只有 0160 例外**——`EPROCS_0160/0260`（有擔 Loan Condition）→ `EPROCSU0160`，但 `EPROCU_0160/0260`（**無擔**）被列成**自成新頁 `EPROCU0160`**；其餘所有 cs/cu 對都併入 CSU（`EPROCU_0110`→`EPROCSU0110`、`EPROCU_0170`→`EPROCSU0170`…）。我們 `feature-inventory` 把無擔 0160 **併為 `EPROCSU0160`**（+`0261` popup，Phase G1 補建）。詳 `refactor-audit/owner-inventory-reconcile.md` §3 F-OWN-4 / §4(a)。
> **目的**：回答「**新系統企金無擔 Loan Condition 是併在 `EPROCSU0160`、還是真有獨立 `EPROCU0160`？**」——即 owner 表 **typo（併入正確）vs 真分歧（需獨立頁）**。

## 待驗問題（單一）
新系統「企金 × 無擔（CU）× Loan Condition（0160）」的頁/endpoint，是**由 `EPROCSU0160` 經 businessType/secureAttribute 共用服務**，還是**存在/需要獨立的 `EPROCU0160`**？

## 步驟（唯讀）
1. **新系統盤點頁/endpoint**：grep 新 FE+BE——
   - FE：`EPROCU0160` / `EPROCSU0160` component/module/route、`0160` page code、`csu*LoanCondition*`；列存在的頁與其檔 `file:line`。
   - BE：`0160` 相關 controller/endpoint（`epl-*`）、checkpoint key（`TB_CHECK_POINTS_CU` vs `_CS`）；列 `file:line`。
2. **routing 對映（關鍵證據）**：查 `TB_PAGE_MENU`/pageMap（`formatCS/CU`）——**無擔（`LON_ATTRIBUTE`）× `0160`** 的 `PAGE_CODE` 指向 `CSU0160` 共用頁、還是一個**獨立 page code**？這是「併 vs 分」的決定性證據。
3. **CS/CU 分流檢查**：`EPROCSU0160` 是否如其他 CSU 頁，以容器 `businessType`/`secureAttribute` 同時服務 CS（有擔）與 CU（無擔）？無擔走進來時欄位/檢核/checkpoint 有無被正確分流（對照既有 CSU 頁慣例，見 `decisions.md` CSU0130 裁決：案件編輯子頁鏡像 twin、CS/CU 由容器判定）。
4. **legacy 對照**：舊 `EPROCU_0160` 與 `EPROCS_0160` 是否同構（twin）、還是無擔有真正不同的欄位/邏輯到不能共用？附舊 `file:line`。

## 判性質（三選一，**每結論附 `file:line`**）
- **typo／併入正確**：無擔 0160 由 `EPROCSU0160` 經 businessType/secureAttribute 服務、無獨立頁，且 CU 分流正確 → owner 表 `EPROCU0160` 自成頁係 legacy naming artifact、我們併對。**處置**：關 AUD-11、`feature-inventory §1` 維持併（註記證據）。
- **真分歧**：新系統真有獨立 `EPROCU0160`，或無擔欄位/邏輯與有擔差異大到不能共用、現 `EPROCSU0160` 未正確服務 CU → **缺口**。**處置**：開補建/修卡、`feature-inventory §1` 改分列（66/67→明確）。
- **UNFOUND**：證據不足以判（缺 routing/缺源）→ 停手回報，不猜。

## 鐵則
1. 唯讀；每結論附 `file:line`；推不出＝`UNFOUND`，不准拿 page-mapping/inventory 當證據（它們正是待驗對象）。
2. 「併 vs 分」以 **pageMap routing + 實際 component/endpoint** 為準，**非僅靠名稱**（owner 表名 ≠ 新系統 page code）。
3. 不改碼、不跑 build。

## 回報
產表：`對象 ↔ 新系統 file:line ↔ routing(pageMap) ↔ legacy 對照 ↔ 結論(typo/分歧/UNFOUND)`，findings 寫 `docs/build-tasks/done/aud11-cu0160-page-reverify-findings.md`。**先報給人審** → 回填 `owner-inventory-reconcile §5.3`、`feature-inventory §1`、`pending-register` AUD-11。

> 過了：F-OWN-4 唯一頁級不一致（66/67）收斂、企金併頁口徑坐實，AUD-11 結。
