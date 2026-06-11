# 30% 補完 — 總盤點（Completion Ledger）

> 🗄 **已凍結（2026-06-11 健檢）**：內容已由 `feature-inventory.md`（狀態 SSOT）吸收，本檔停止維護、僅供歷史參考。「SSOT」一詞限 `feature-inventory.md`（狀態）與 `pending-register.md`（待決）兩處。
> ~~一頁 SSOT~~：舊系統比對後，**已重構(70%) + 後續補完(30%)** 還有多少「功能/細節未實作」。
> 彙整 `page-mapping.md` §2、`verification-handoff.md`、`disbursement-triage.md`。**逐頁狀態/排程明細以 `feature-inventory.md` 為準**（最新校正版；本檔只到桶別）。
> **分類關鍵**：「未實作(碼缺/會錯)」≠「已實作待驗(碼在、待整合驗證)」≠「判斷題(待 owner)」。三者別混。

## 0. 一句話結論
- **前端**：🟡 **大致完成，但 c0 評分前端整組缺**（2026-06-06 cross-check 翻案：corporate 缺評分容器+8 子頁、現 Phase F 鏡像 i0 補建中，見 `feature-inventory.md` §2D）。其餘前端頁（主流程/i0/契約/z0/deputy/CSU0130）✅。
- **企金評分後端 c0（00115–00120，6 支）**：🟡 **碼已實作、待整合驗證**（鏡像 i0、build 綠）——**非缺碼**。runtime-stub 盲點**已關（2026-06-06）**：六支 calc/save/info/sele/download 與其呼叫的 `funcGetRate`/common 方法皆有 return 路徑、無會被踩到的 stub（§4）→「已實作」從**推定**升為**確認**；剩正確性/授權/呈現待整合驗證（Bucket B）。
- **撥貸（0920/0921/0922）**：🔴 **唯一真正「功能未實作/會錯」的區塊**——authorize 換匯核心是 throw-stub（從未端到端跑過）+ T24 組檔錯位 + ~18 項行為分歧。

## 1. Bucket A — ✅ 已完成（不需再動碼）
| 範圍 | 狀態 |
|---|---|
| 前端頁（主流程、i0 評分、契約頁、報表 00610/00620–00650/00660、deputy=00700、CSU0130）| 結構/功能完成，待整合驗證呈現。⚠️ **c0 評分前端不在此列**（整組缺、Phase F 補建中，見 `feature-inventory.md` §2D）|
| c0 評分**結構**（controller/DTO/checkpoint/entity 重用）| 6 支齊、build 綠、runtime 非 stub（§4 已確認） |

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
| **P0 blocker** | ① `funcGetExchangeRate` throw-stub（`common/impl/FunctionServiceImpl`:1156，authorize 核心無 return、T24/SFTP/定案到不了；stub-sweep 再坐實）② `T24_COMPANY` B8/C9 死路（讀已移除欄）③ T24 結構錯位（H 未 append、E/H 順序、多餘 `\n` 欄）| 3 |
| **P1 真 bug** | 0921 4 項（完工日寫 null、fee 過刪、fee alias null、RECEIVED_DATE 時機）+ 0922-main 3 項（匯率源 ID、submit mail 空、history 碼）+ T24 值來源 ~8（A52 漏、C12/C13/C20/G4/G10/H8 源錯、AGREEMENT_NO 截斷、E21→0）| ~15 |
| **P2 判斷** | 檢核對等（CheckMainBorr/CoBorr/CO_CHECK）、架構（批次 t24DealResult、scheduler mail）、KHR（**刻意、勿改回**）| 多 |
| **P3 UNSURE** | 金額精度（NUMBER(17,2) vs 舊 UNKNOWN）、IS_CONTR 等，待 DDL/DBA | 數項 |
> 進度（2026-06-06）：**§7 機械 allowlist（M1–M10）全數結案、全上 master 並審過**（M10＝`06f39df`，fee delete 縮為 `CON_TYPE='FN'`、detail 本就 FN-scoped；落地＝master-direct 前向修，見 triage §7.1）。**M6 升級 domain**（DTO 無完工日來源）。剩下全是 §6.6 **domain 判斷題**（P0 stub 實作、`T24_COMPANY` 值來源、匯率源 ID、檢核嚴格度、精度…）→ 整理在 `disbursement-domain-escalations.md`，待 owner。整合測確認點：M7 facility fee 值、M9 district name join。

## 4. ✅ 盤點盲點 — 已關閉（2026-06-06 stub-sweep）
**原盲點**：`build 綠 ≠ 無 runtime stub`。`funcGetExchangeRate` 是 IDE 自動產生的 `throw UnsupportedOperationException`、編譯通過只在執行時爆；先前 stub 掃只跑過撥貸 2 個檔，故「c0 6 支已實作」一度只是**推定**。
**掃描結果（Codex 唯讀、工作樹未動、`git diff` 空）**：
- **c0 六支目標**（CsuBorrowerGroupExposure / CsuFinancialStatement(GI) / CsuFinancialStatementCmtsFi / CsuCorporateScorecard / CsuFinancialEvaluationTableFi / CsuFinancialEvaluationStaffFi 之 calc/save/info/sele/download）**皆有 return 路徑、無會被踩到的 stub**；六支 Controller 全 thin pass-through。
- 🟢 **關鍵釐清（修正先前誤判）**：先前怕「`funcGetRate` 與 `funcGetExchangeRate` 同檔、恐同為 stub」——實為**不同類/不同檔**。c0/00118 呼叫的是 `individual/impl/FunctionServiceImpl.funcGetRate`（**有正常 return**，缺料回 0 為容錯，:3498/:3728）；throw-stub 是 `common/impl/FunctionServiceImpl.funcGetExchangeRate`（:1156），**c0 六支沒有呼叫它**。同名不同類，盲點源於此。
- 其餘共用方法（`CommonServiceImpl.getCommonFieldOptions`:149〔TODO 在 catch、非未實作〕、`FileServiceImpl`/`PdfServiceImpl` download:386/:410/:52、`DynamicUpdateSqlUtils.dynamicUpdate`:28 / `SqlValidationUtils.getSummeryEntityOrThrow`:20）皆有實作。
- → **c0 從「推定實作」升為「確認實作（非 stub）」**；正確性/授權/呈現仍走 Bucket B 整合驗證。
**順帶坐實（非 c0）**：`common.FunctionServiceImpl.funcGetExchangeRate`(:1156) 即 §3 撥貸 **P0①** 那支 throw-stub，本次再次確認位置；c0 不受其影響。
**保留風險（非 stub，歸 Bucket B 整合/資源）**：GI/FI Excel 產生失敗會包成 `RuntimeException`、PDF 字型/模板缺失會 runtime error——屬資源/錯誤處理風險，非「編譯過但未實作」。c0 的 PDF/XLS download 路徑整合驗證時留意。

## 5. 比對深度差異（誠實標註）
- **撥貸**：對**舊系統**做了深度逐項比對（0921 Step B 7P/15F/5U、0922 Step B、T24 B-step）→ 分歧已坐實。
- **c0**：oracle 是**新等價物 i0**（非 raw 舊系統）；正確性**繼承自 i0 對舊的驗證**，未對舊獨立重驗（此為 §2E 設計，可接受，但深度不同於撥貸）。

---
> （已凍結——見檔頭；勿再回填本檔，狀態一律回填 `feature-inventory.md`。）
