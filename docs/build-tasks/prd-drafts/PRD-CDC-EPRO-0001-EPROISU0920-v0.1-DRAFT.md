# PRD — EPROISU0920 撥貸流程（Disbursement Process 頁框）

> 🟠 **DRAFT SKELETON（v0.1）— 規劃 repo 從撥貸 triage/escalations + matrix 反推，非 PM 定稿**。
> **定稿後**改名 `PRD-CDC-EPRO-0001-EPROISU0920-v1.0.md`、移 `docs/specs/prd/`、ledger 升 `prd-ready`。本資料夾期間 orchestrator 不 pick。
> **來源**：`per-page-reinventory-matrix §T1 撥貸`（EPROISU0920＝FIX domain-gated、DIFF-004 碼在）、`disbursement-triage.md`、`disbursement-domain-escalations §B-6`。brownfield＝舊行為基準。
> ⚠️ PM 待補＝`〔PM:…〕` + §7 TBD（0920 為頁框，業務 gating 細節多待 PM/domain）。

---

## Metadata
| 欄 | 值 |
|---|---|
| funcId | `EPROISU0920` |
| doc id | `CDC-EPRO-0001` |
| 名稱 | 撥貸流程（Disbursement Process 頁框 / container）|
| Status | **DRAFT（規格定版：DRAFT／實作完成：partial）** |
| Owner | PM（業務 gating）＋撥貸 domain（架構/狀態）|
| 版本 | v0.1-DRAFT |
| 上游 | Bible v1.1（撥貸個金 only）；舊頁 `EPROIS_0920` |

> **SoT 原則（ADR-0002）**：以 Rn 為結論（SRS 即權威）；既有決策（架構/狀態「照舊」）＝provenance 帶進 Rn、原系統處理＝as-is 證據（「已建/已 push」≠ 定版）；金錢/交易/狀態缺口→`@PENDING`、不標 ✅。先 SRS 結論、再以原系統處理佐證。

## 1. 背景 / 目的
撥貸流程的**頁框/容器**：承接撥貸案進入撥貸階段，框住 `0921 資料輸入` → `0922 彙總/授權` 兩子步，顯示流程狀態並控制進入條件。〔PM: 業務目標一句話〕

## 2. 範圍 / Non-Goals
- **In**：頁框載入、子步導覽（0921/0922）、撥貸流程進入/狀態 gating、（如有）自動撥貸旗標。
- **Non-Goal**：0921 輸入內容、0922 授權/T24（各自 PRD）；批次結果處理本身（屬批次層 `EPROZ0B006/B007`，AUD-10）。

## 3. 角色
承辦（AO）。〔PM: 對 Bible `TB_ROLE_DEFINE` 確認進入撥貸的角色/權限〕

## 4. 功能需求（REQ；舊行為基準）

### REQ-001 撥貸頁框載入
載入撥貸流程容器、顯示該案撥貸階段狀態、框住 0921/0922 子步。
- **as-is**：✅ 碼在（matrix DIFF-004）。**強制點**：BE 提供狀態/導覽 DTO。
- **acceptance**：〔PM: 列頁框必顯狀態/可進子步條件〕。

### REQ-002 撥貸流程進入 gating（domain-gated）
控制案件何時可進撥貸（流程/狀態條件）。
- **as-is**：🟡 matrix 標 **FIX(domain-gated)**——進入條件屬 domain。
- **三判**：〔domain: 以舊系統進入條件為基準；差異→三判〕。
- **強制點**：BE。**acceptance**：〔PM/domain: 列進入條件（CASE_PROGRESS/狀態碼）〕→ §7 TBD-001。

### REQ-003 撥貸結果處理架構（async 批次，參照）
撥貸送出後結果由批次/async 處理（`t24DealResult`→`EPROZ0B006`、結案 `B007`、mail scheduler）。
- **as-is**：✅ 架構已建（AUD-10：B006 結果處理器、B007 結案皆 active scheduled）。
- **provenance**：B-6（escalations）；批次層屬 `EPROZ0B00x`（本頁只**參照**、非實作該批次）。
- **強制點**：BE。**@PENDING**：mail scheduler timing／`IS_AUTODIS=YC` 語意（§7 TBD-002）。

## 5. 錯誤回應
> 〔PM/RD: 0920 為頁框，錯誤多繼承子步；補進入失敗/狀態不符錯誤碼（`MSG_*`）〕

## 6. DB 影響矩陣
| 表 `TB_*` | 動作 | REQ | 備註 |
|---|---|---|---|
| `TB_LON_SUMMARY_INFO` | read | 001/002 | 案件狀態/CASE_PROGRESS（進入 gating）|
| `TB_CHECK_POINTS_IS` | read | 002 | 撥貸 checkpoint |
> module_code/端點：〔RD: 補真實 `epl-*`（頁框載入/導覽）〕

## 7. TBD（不自裁；附 owner）
| TBD | 內容 | owner |
|---|---|---|
| TBD-001 | 撥貸流程進入 gating 條件（CASE_PROGRESS/狀態碼，以舊為基準）| PM/撥貸 domain |
| TBD-002 | 結果處理 mail scheduler timing／`IS_AUTODIS=YC` 語意（架構已建、殘語意）| 撥貸 domain |

## 8. maxlength / 必要
〔頁框多為唯讀狀態，無大量輸入欄；PM/RD 視子步繼承補〕

## 9. as-is findings 路徑
- `docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md`（§T1 撥貸：0920 FIX domain-gated、DIFF-004）
- `docs/disbursement/disbursement-triage.md`（§3 架構）、`disbursement-domain-escalations.md`（B-6）

---
> **下一步（PM）**：填 `〔PM:…〕`+§7（0920 gating 最需 PM/domain）→ 定稿 v1.0 移 `docs/specs/prd/` → ledger `prd-ready` → drain。
> **Batch 1 撥貸三頁齊**：0920（本頁框）/0921（輸入+檢核）/0922（授權/T24）骨架皆備。
