# Phase D · A-1 — `funcGetExchangeRate` 換匯 stub 實作前調查（唯讀，產規格）

> **唯讀**：不改任何碼，結束 `git diff --name-only` 必須是空的。
> **產出**：一份**可直接交撥貸 domain 實作的規格**。`funcGetExchangeRate` 是金錢核心、§6.6 **不由 Codex 逕自實作**，本輪只調查 + 寫規格。
> **背景**：它是撥貸 authorize 的總開關——目前在 `0000` 成功分支寫完 `TB_DISBUR_DATE`/`TB_EXCHANGE_RATE` 後**無條件丟** `UnsupportedOperationException`，全方法無 return → T24/SFTP/狀態(26) 全到不了，撥貸從未端到端跑過。

---

## 要查並逐點回答
1. **stub 本體**：`backend/.../service/common/impl/FunctionServiceImpl.funcGetExchangeRate`（約 :1156）
   - 現在 body 寫了哪些表、在哪一行 throw；
   - method **簽章**（入參型別/名稱）、**預期回傳型別**；
   - 呼叫端（`SummaryServiceImpl` authorize / `caseIsuSummaryAuth`）**拿回傳值做什麼**、後續（T24 組檔 / SFTP / 狀態 26）需要它給出什麼結構。

2. **可參照的兄弟**：`backend/.../service/individual/impl/FunctionServiceImpl.funcGetRate`（約 :3498，c0/00118 用、**有正常實作**）
   - 它**怎麼取匯率**、資料源為何、回傳結構；
   - 撥貸 stub 能否沿用同 pattern / 同 source？簽章與回傳差在哪？

3. **匯率資料源**：匯率從哪來（外部 API or DB 表）？
   - 哪張表 / 欄位存匯率（有沒有 `TB_EXCHANGE_RATE` 或外部匯率 API）？
   - ⚠️ 已知問題：來源 ID `OVSLXLON01` → `OVSLXLON02`（疑換錯源、疑刻意）——查清正確來源 ID 應為何。

4. **舊系統行為**：若 `legacy-extract`（本機）有舊 `EPROIS_0922` 換匯邏輯，舊的**取法 / 來源 / rounding / 回傳**是什麼？

5. **rounding / 精度**：套匯率時的 rounding 規則——注意 E 段 `CHRG_AMOUNT` 用 `Math.round`/HALF_UP、0921 fee 用 `RoundingMode.DOWN`，**標出此處該用哪個**。

6. **partial-write 風險**：stub 是「先寫表後 throw」。
   - 該方法 / 呼叫鏈的**交易邊界**為何？
   - 實作後要確保「寫入 + 回傳」一致（目前依交易邊界可能留半更新）——標出實作時要注意的 transaction 處理。

## 產出（一份規格）
- **method 合約**：入參、回傳結構（對齊呼叫端期望）；
- **匯率讀取來源**：表/欄位 或 API + 正確來源 ID；
- **rounding 規則**；
- **open questions**（需 domain / DBA 確認的點，例如來源 ID 是否刻意、精度 scale）；
- **結論**：是否建議**鏡像 `funcGetRate`**（同源同 pattern）or 另寫，理由。

**唯讀**；回報附 `git diff --name-only`（應為空）。
