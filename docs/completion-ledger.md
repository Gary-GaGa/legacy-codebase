# 30% 補完 — 總盤點（Completion Ledger）

> 一頁 SSOT：舊系統比對後，**已重構(70%) + 後續補完(30%)** 還有多少「功能/細節未實作」。
> 彙整 `page-mapping.md` §2、`verification-handoff.md`、`disbursement-triage.md`。
> **分類關鍵**：「未實作(碼缺/會錯)」≠「已實作待驗(碼在、待整合驗證)」≠「判斷題(待 owner)」。三者別混。

## 0. 一句話結論
- **前端**：✅ 完成（無從零頁；`EPROCSU0130` 2026-06-05 收尾，ng build 綠）。
- **企金評分後端 c0（00115–00120，6 支）**：🟡 **碼已實作、待整合驗證**（鏡像 i0、build 綠）——**非缺碼**，但「已實作」目前**靠 build 綠 + 鏡像推定**，尚未做 runtime stub 掃（見 §4 盲點）。
- **撥貸（0920/0921/0922）**：🔴 **唯一真正「功能未實作/會錯」的區塊**——authorize 換匯核心是 throw-stub（從未端到端跑過）+ T24 組檔錯位 + ~18 項行為分歧。

## 1. Bucket A — ✅ 已完成（不需再動碼）
| 範圍 | 狀態 |
|---|---|
| 前端全部頁（含報表 00610/00620–00650/00660、deputy=00700、CSU0130）| 結構/功能完成，待整合驗證呈現 |
| c0 評分**結構**（controller/DTO/checkpoint/entity 重用）| 6 支齊、build 綠 |

## 2. Bucket B — 🟡 已實作、待整合驗證（碼在，**非未實作**；owner：整合測試/DB）
> 詳 `verification-handoff.md` §3–5。皆「正確性/授權/呈現」驗證，非補碼。
- c0 新 endpoint 的 `TB_API_AUTH`/`TB_ROLE_TASK` 授權列（00115/00116/00118/00119/00120）。
- export 模板沿用 i0（00116/00119/00118）是否需 c0 專屬。
- 報表呈現（00610 CR、00620–00650）；⚠️ 00640 export FE POST blob vs BE GET `@RequestBody` 介面不一致。
- FE↔BE `epl-*` DTO 契約對齊（真資料/真授權各跑一次）。

## 3. Bucket C — 🔴 真正未實作 / 會錯（撥貸；owner：撥貸 domain + 返工）
> 完整清單 + 修法 `disbursement-triage.md`（P0–P3、§7 機械 allowlist）。量級：
| 層級 | 內容 | 量 |
|---|---|---|
| **P0 blocker** | ① `funcGetExchangeRate` throw-stub（authorize 核心無 return、T24/SFTP/定案到不了）② `T24_COMPANY` B8/C9 死路（讀已移除欄）③ T24 結構錯位（H 未 append、E/H 順序、多餘 `\n` 欄）| 3 |
| **P1 真 bug** | 0921 4 項（完工日寫 null、fee 過刪、fee alias null、RECEIVED_DATE 時機）+ 0922-main 3 項（匯率源 ID、submit mail 空、history 碼）+ T24 值來源 ~8（A52 漏、C12/C13/C20/G4/G10/H8 源錯、AGREEMENT_NO 截斷、E21→0）| ~15 |
| **P2 判斷** | 檢核對等（CheckMainBorr/CoBorr/CO_CHECK）、架構（批次 t24DealResult、scheduler mail）、KHR（**刻意、勿改回**）| 多 |
| **P3 UNSURE** | 金額精度（NUMBER(17,2) vs 舊 UNKNOWN）、IS_CONTR 等，待 DDL/DBA | 數項 |
> 進行中：Codex 先修 §7 機械項（Tier1 M2/M3/M4 → Tier2 → Tier3，逐項閘門）；stub 實作/T24_COMPANY/匯率源等判斷題升級 domain。

## 4. ⚠️ 盤點自身的盲點（**唯一可能把「已實作」翻成「未實作」的未知**）
**`build 綠 ≠ 無 runtime stub`**：`funcGetExchangeRate` 是 IDE 自動產生的 `throw UnsupportedOperationException`，**編譯完全通過**、只在執行時爆。我們的 stub 掃**只跑過撥貸那 2 個檔**。
- 🔴 **關鍵關聯**：該 stub 所在的 **`FunctionServiceImpl` 是共用檔，c0 `00118` calc 也注入它**（`funcGetRate`）。我們確認了 `funcGetExchangeRate` 是 stub，但**尚未確認 `funcGetRate` 及 c0 依賴的其他 `FunctionService`/common 方法不是 stub**。
- 因此「c0 6 支已實作」目前是**推定**（build 綠 + 鏡像 + 00118 語意審），**非經 runtime-stub 掃證實**（00117 是既有模組、推定會跑；00115/116/119/120 未明確掃 stub）。
- **關閉動作（建議下一步）**：對「c0 6 支新 ServiceImpl + 它們呼叫的 `FunctionServiceImpl`/common 方法」做一次 stub 掃——grep `UnsupportedOperationException` / `TODO` / `throw new .*NotImplemented` / 空 body / 佔位 `return null`，逐一確認有 return 路徑。掃完才能把 c0 從「推定實作」升為「確認實作」。

## 5. 比對深度差異（誠實標註）
- **撥貸**：對**舊系統**做了深度逐項比對（0921 Step B 7P/15F/5U、0922 Step B、T24 B-step）→ 分歧已坐實。
- **c0**：oracle 是**新等價物 i0**（非 raw 舊系統）；正確性**繼承自 i0 對舊的驗證**，未對舊獨立重驗（此為 §2E 設計，可接受，但深度不同於撥貸）。

---
> 維護：本檔為總盤點 SSOT；細節改動回填 `page-mapping.md` §2 / `verification-handoff.md` / `disbursement-triage.md`，此處只更新「桶別歸屬 + 盲點關閉狀態」。
