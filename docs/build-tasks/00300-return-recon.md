# Build Task — `EPROZ00300` Document Checklist：return action 坐實（唯讀 recon）

> 載具：Codex（母資料夾，需新碼；舊 EPRO source 可讀則一併比對，不在則標 `UNFOUND`）。
> **性質＝唯讀坐實**（❓→✅/🔴）：**不修碼**；產出＝findings 報告。修復另開卡。
> **背景**：`feature-inventory.md` §2E/④——`00300` return action **空回、疑未完成**（`DocumentChecklistController:57`）。是「舊系統本來就 no-op」還是「新碼漏實作」未坐實。

## 目標
回答一題：**舊系統 Document Checklist 的 return（退回）action 做了什麼？新碼缺多少？** 寫進 `docs/build-tasks/00300-return-recon-findings.md`。

## 取證項
1. **新碼 as-is**：`DocumentChecklistController:57` 起的 return 路徑——controller/service 全鏈，確認回了什麼（空 DTO？）、有無 DB 寫入/狀態變更/通知；附 `file:line`。
2. **舊系統 to-be 基準**：舊 `z0` Document Checklist 的 return action——更新哪些表/欄（案件狀態？`CASE_PROGRESS`？通知/mail？）、前置驗證；附 `file:line`。
3. **gap 清單**：舊有新無，逐項列（表/欄/規則/通知）；若舊系統該 action 同樣 no-op → 結論「非缺陷、建議 inventory 升 ✅」。

## 鐵則
唯讀、不猜、`file:line` 必附、UNFOUND 必標（同 `00800-pending-recon.md` 鐵則 1–3）。

## 回報
- findings 三節齊；結論一句：🔴 需補碼（附 gap 範圍）or ✅ 舊本 no-op；產品 repo `git status --short` 乾淨。

> 過了：🔴 → 開 `00300-return-fix.md` 修復卡（走 PRD→SRS 或小修流程由 SA 裁量）；✅ → 回填 `feature-inventory.md` §2E/④ 升 ✅、關此項。
