# Build Task — c0 評分新 endpoint 授權列 SQL 預產（DB-free，待 DB 通套用）

> 載具：Codex（母資料夾，讀新碼 + repo 內既有 SQL/seed/migration）。**不連 DB、不執行 SQL**——DB 連線未通（`feature-inventory.md` §5 🔒），本卡只「先寫好、待套用」。
> **背景**：`feature-inventory.md` §4⑥——Phase F 已收工，但新 c0 endpoint 的 `TB_API_AUTH`/`TB_ROLE_TASK` 授權列未建；**授權列未套用前打 c0 endpoint 會 403**，DB 一通這是第一件事。

## 目標
產出可直接套用的 INSERT SQL + 對照表：`docs/build-tasks/c0-authz-sql-findings.md`（對照表）+ SQL 檔（放產品 repo 慣例位置，如既有 seed/migration 資料夾；位置照既有慣例、回報路徑）。

## 步驟
1. **找 pattern**：repo 內既有 `TB_API_AUTH`/`TB_ROLE_TASK` 的 seed/migration SQL——以 **i0 對應頁**（`EPROI00115/116/118/119/120`）的授權列為範本（欄位、角色、命名）；附出處 `file:line`。
2. **列 endpoint 名單**（核對新碼 controller 實際路由，勿抄文件）：
   - 必做（⑥ 名單）：`00115` BGE、`00116` FinStmt GI、`00118` corporateScorecard、`00119` FinStmt FI、`00120` FinEval FI 的全部 `epl-*-c0-*` 端點（sele/sele-list/info/calc/save/export 依各頁實有）。
   - **順帶核對**：`00110` 容器 tab、`00112` CBC、`00114` Collateral Assessment 的 `-c0-` 端點是否已有授權列；沒有→併入產出，有→列存在證據。
   - `00117` 既有（`CsuFinancialStaffController` 沿用）→ **不動**，只核對列存在。
3. **產 SQL**：每 endpoint × 角色一筆，角色對照 i0 同功能頁；i0 無對應或角色不確定 → 該筆照常產出但標 `-- UNSURE: 待 ops 確認`，並列入對照表 UNSURE 節。
4. **對照表**：`endpoint ↔ 對應 i0 範本列 ↔ 角色 ↔ UNSURE?`，SA/ops 可逐列簽核。

## 鐵則
1. 不連 DB、不執行；SQL 語法照 repo 既有 seed 慣例（Oracle 方言，R1）。
2. endpoint 名單以**新碼 controller 路由**為準（grep 證據附上）；文件與碼不符 → 以碼為準並回報差異。
3. 角色授權**不猜**：有 i0 範本照抄對應，無範本標 UNSURE。

## 回報
- SQL 檔路徑 + 筆數（含 UNSURE 數）；對照表；00110/112/114/117 的核對結論各一句；`git status --short`（應只有新增 SQL 檔與 findings）。

> 過了：DB 一通 → ops 簽核 UNSURE → 套用 → Phase V 整合驗證才打得動 c0 endpoint（403 解除）。
