# Build Task — `EPROISU0920` Disbursement Process（後端）

> 載具：Codex（後端專案/母資料夾）。**硬規則見 `backend/AGENTS.md` §6**。
> 🛑 **不可直接開做**：這是**唯一沒有 i0 可鏡像**的後端缺口（前端已就緒、只缺後端 API；授權 page-map 有、無 controller）。

## 為何特別
- 其餘 c0 頁都有 i0 孿生可鏡像；**撥貸沒有** → 必須回去追**舊系統 `EPROIS_0920`**（Data Input `0921` / Summary `0922`）的行為當基準。
- 這正是 `page-mapping.md` §2E 第 3、4 點的情境：**無新等價物 → 回對舊系統，但「對照＋人工判斷」，非逐欄硬搬**（舊 DB2 SQL 要改 Oracle 方言；舊 `HttpDispatcher`/`@CallMethod` 改 REST）。

## 步驟（強制 plan-first，人審後才開做）
1. **唯讀盤點**：舊 `EPROIS_0920`/`0921`/`0922` 的 trx/DAO/SQL/表/欄位/流程；前端已就緒的撥貸頁打哪些 endpoint、期望什麼 DTO。
2. **產計畫**：建議的 controller/service/DTO/entity（新 DB 表名，無 `EPRO_` 前綴）、endpoint `epl-*`（依既有命名）、checkpoint（若有）、Oracle 方言改寫點。
3. **等人審** → 通過後才實作。
4. 實作後照 `runbook-30pct.md` §2 gate（`verify-c0` 對撥貸檔較不適用反射/individual 規則，但編碼/命名仍驗；build 綠；對前端契約自檢）。

## 煞車
- 任何業務規則（撥貸金額/條件/序號/狀態機）拿不準 → 停下回報，**別憑舊 JSP 臆測硬寫**。
