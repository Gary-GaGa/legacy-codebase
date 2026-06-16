# Build Task — 新舊「幣別處理」差異坐實（KHR vs USD；解 A-5「疑似」）

> **性質**：唯讀碼驗（Codex 母資料夾，新後端 + legacy 對照）。**只報不改**。
> **背景**：A-5「KHR 在地化＝刻意演進」一直是**推斷未確認**（escalations「🟢 疑似」、handoff「多半」）。owner 06-16 質疑「USD+KHR 維持新」是否亂寫 → 需把「疑似」**坐實成確定/否**：新系統到底對各幣別做什麼、跟舊差在哪、是**新增（舊沒有）**還是**改寫（舊有但不同）**。
> **已知線索（待逐項 file:line 證）**：
> - 新 0921 fee rounding 有 `KHR`+`RoundingMode.DOWN` 分支、舊 fee rounding **僅 USD 分支**（`verification-handoff §2.1:54`）。
> - 新 E21 對 KHR 處理（`handoff §2.3:85`「E21 KHR rounding 未誤用 DOWN」）；A-3：E21 非 USD 非 KHR 輸出 0、**舊全換匯**。
> - 舊 `getExchangeRate` request `CcyCode=KHR`（`done/a1-oq-legacy-recon-findings.md:8`）→ 舊**非全無 KHR**。

## 範圍（聚焦撥貸：換匯 / fee / T24 E21·G·H）
1. **新 backend**：grep `CcyCode`／`currency`／`KHR`／`USD`／`RoundingMode` 的分支——
   - fee rounding（0921 fee 公式 / `RoundingMode`）
   - 換匯（`funcGetExchangeRate`、authorize 換匯）
   - T24 組檔 E21 / G / H 換匯欄（`SummaryServiceImpl`）
   逐處 `file:line` + 該分支對 **USD / KHR / 其他幣別** 各做什麼。
2. **舊 legacy**：對應處（`EPRO_IS0922`、`EPROIS_0921` fee、`EPROIS_0922_mod` 換匯）——同樣列 USD/KHR/其他各做什麼。
3. **交叉對照**：產表 `幣別 × (舊行為 / 新行為 / 差異 / 性質[新增|改寫|相同])`，逐格附 `file:line`。

## 要回答的問題
- **A-5 結論**：新系統的 KHR 處理是**真的新增在地化**（舊無→新有，keep 合理）還是**改寫舊行為**（舊有 KHR、新改了，需對等性裁定）？
- E21「非 USD 非 KHR 輸出 0」vs 舊「全換匯」——是隨 KHR 在地化的刻意改，還是 regression？
- 有無**舊有、新漏**的幣別處理（反向缺口）？

## 鐵則
1. 唯讀；每格附 `file:line`；推不出＝`UNFOUND`，不猜、不拿 inventory/triage 當證據。
2. 區分**新增**（舊 grep 全無）vs **改寫**（舊有但不同）——這是 A-5「刻意 vs regression」的關鍵。
3. 不改碼、不跑 build。

## 回報
對照表 + A-5 結論（含建議：keep / 對等修 / 升 domain）；findings 寫 `khr-currency-handling-recon-findings.md`。**先報給人審**——據此定 T24 KHR 分支去留（連動 `t24-bgroup-legacy-parity-fix.md` 邊界）。

> 過了：A-5 從「疑似」變確定；T24 KHR 邊界有據可定（keep / 修），撥貸 T24 batch-fix 的幣別分支解鎖。
