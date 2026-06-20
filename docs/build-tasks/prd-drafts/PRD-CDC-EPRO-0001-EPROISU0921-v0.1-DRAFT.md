# PRD — EPROISU0921 撥貸資料輸入（Disbursement Data Input）

> 🟠 **DRAFT SKELETON（v0.1）— 規劃 repo 從撥貸 triage/escalations 反推，非 PM 定稿**。
> **定稿後**改名 `PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md`、移 `docs/specs/prd/`、ledger 升 `prd-ready`。本資料夾期間 orchestrator 不 pick。
> **來源**：`docs/disbursement/disbursement-triage.md`（§2/§3/§7 M4/M6/M7/M10）、`disbursement-domain-escalations.md`（A-4/D-1）。brownfield＝舊行為基準（`legacy-parity-sop` 三判）。
> ⚠️ PM 待補＝`〔PM:…〕` + §7 TBD。

---

## Metadata
| 欄 | 值 |
|---|---|
| funcId | `EPROISU0921` |
| doc id | `CDC-EPRO-0001` |
| 名稱 | 撥貸資料輸入（Disbursement Data Input）|
| Status | **DRAFT（規格定版：DRAFT／實作完成：partial）** |
| Owner | PM（業務）＋撥貸 domain（A-4 裁示）＋ RD（M6 接值）|
| 版本 | v0.1-DRAFT |
| 上游 | Bible v1.1（撥貸個金 only）；舊頁 `EPROIS_0921` |

> **SoT 原則（ADR-0002）**：以 Rn 為結論（SRS 即權威）；既有決策（A-4/M6「照舊」）＝provenance 帶進 Rn、原系統處理＝as-is 證據（「已修/已 push」≠ 定版）；金錢/檢核缺口→`@PENDING`、不標 ✅。

## 1. 背景 / 目的
撥貸流程前段：承辦輸入撥貸明細（撥貸金額/日期/費用/擔保完工日…）並對借款人/共借人做撥貸前**檢核**，通過後進 0922 彙總授權。〔PM: 業務目標一句話〕

## 2. 範圍 / Non-Goals
- **In**：撥貸資料輸入載入/保存、借款人/共借人檢核、collateral 完工日、fee 處理、Finished gate。
- **Non-Goal**：authorize/T24/submit（屬 `EPROISU0922`）；報表（R2）；企金撥貸。

## 3. 角色
承辦（AO）。〔PM: 對 Bible `TB_ROLE_DEFINE` 確認〕

## 4. 功能需求（REQ；舊行為基準，差異標三判）

### REQ-001 撥貸資料輸入載入/保存
載入該案撥貸明細、可保存（Save）。
- **as-is**：✅ 既有（`EPROIS_0921`）。**強制點**：BE。〔PM: 列必填/可編欄位〕

### REQ-002 借款人/共借人檢核（A-4，照舊）
撥貸前檢核 `CheckMainBorr`/`CheckCoBorr`：身分、sector、account、`DATA_SEQ` 順序、business-section；`info CO_CHECK` 判定；law firm 顯示條件；address 來源。
- **as-is**：🟡 各檢核新舊有分歧（`CO_CHECK ='Y'` vs 舊 `!='N'`、Finished gate 未驗 `mbCheck`、law firm `IS_SHOW` 版本條件、address `UPD_DATE` 來源）。
- **三判**：(a) **owner 06-17 裁＝照舊系統處理**（差異視為 regression、對齊舊判據）→ RD/Codex 逐項坐實舊+對齊。
- **強制點**：BE。**acceptance**：各檢核行為＝舊系統判據（逐項 §7 TBD-001 追）。

### REQ-003 擔保完工日寫入（M6/D-1，照舊）
collateral 完工日寫 `EST_COM_DATE`/`OTHER_EST_COM_DATE`（**非 null**）。
- **as-is**：🔴 現況 `setEstComDate(null)`/`setOtherEstComDate(null)`＝資料遺失（request DTO 無日期值來源）。
- **三判**：(a) regression → **owner 06-17 裁照舊**：完工日照舊系統來源接回（RD trace legacy FE/衍生點寫回非 null）。
- **強制點**：BE。**acceptance**：兩欄寫入非 null、值＝舊來源。→ §7 TBD-002（RD 接值）。

### REQ-004 費用處理（fee 公式 / cleanup）
facility fee＝loan amount × FEE_1；資料返回時 fee cleanup **只刪 `CON_TYPE=FN`**。
- **as-is**：✅ 已修（M7 alias→`LOANAMOUNT`＝facility fee 非 null；M10 cleanup 改 `deleteByApplicationNo(applicationNo,"FN")`、非過度刪）。
- **三判**：(a) 兩者皆 regression→已修回。
- **強制點**：BE。**acceptance**：facility fee 有值；cleanup 不刪非-FN。

### REQ-005 RECEIVED_DATE 寫入時機
`RECEIVED_DATE` **只在 Finished 時寫**。
- **as-is**：✅ 已修（M4 加 `isFinish` guard，舊僅 Finished 寫）。
- **強制點**：BE。**acceptance**：未 Finished 不寫 RECEIVED_DATE。

### REQ-006 Finished gate
資料完成（Finished）的判定條件。
- **as-is**：🟡 新 Finished gate 未驗 `mbCheck`（A-4）。
- **三判**：(a) 照舊→補驗 `mbCheck`〔待 TBD-001 坐實舊判據〕。
- **強制點**：BE。

## 5. 錯誤回應
> ⚠️ as-is 多為裸名碼；要 gateⒺ 守承載改 `MSG_*`。〔PM/RD: 補檢核失敗/保存失敗錯誤碼表〕
| 情境 | 碼 | HTTP | 備註 |
|---|---|---|---|
| 檢核未過（主/共借人）| 〔as-is 碼〕| 400 | REQ-002 |
| 保存失敗 | 〔as-is 碼〕| | REQ-001 |

## 6. DB 影響矩陣
| 表 `TB_*` | 動作 | REQ | 備註 |
|---|---|---|---|
| `TB_CHECK_POINTS_IS` | read/upd | 002/006 | 撥貸 checkpoint（funcId 命名欄）|
| collateral 完工日表〔PM/RD 確認表名〕| write | 003 | `EST_COM_DATE`/`OTHER_EST_COM_DATE` |
| `TB_LOAN_CONDITION_FEE` | read/del | 004 | facility fee；cleanup 只刪 FN |
| `TB_LOAN_CONDITION_DETAIL` | del | 004 | 本就 FN-scoped |
| `TB_LON_SUMMARY_INFO` / 撥貸日期表 | upd | 005 | `RECEIVED_DATE`（Finished 才寫）|
> module_code/端點：〔RD: 補真實 `epl-*`；mutate=POST〕

## 7. TBD（不自裁；附 owner）
| TBD | 內容 | owner |
|---|---|---|
| TBD-001 | A-4 各檢核（CO_CHECK 判定/mbCheck gate/law firm IS_SHOW/address UPD_DATE/DATA_SEQ）逐項坐實舊判據+對齊（已裁照舊→執行）| 撥貸 domain + RD |
| TBD-002 | M6 完工日舊來源 trace + 寫回非 null（已裁照舊→執行）| RD |

## 8. maxlength / 必要
〔PM/RD: 由 refactor-spec `04_rules/field_rule.md` 抽〕

## 9. as-is findings 路徑
- `docs/disbursement/disbursement-triage.md`（§2/§3/§7 M4/M6/M7/M10、§7.1 進度）
- `docs/disbursement/disbursement-domain-escalations.md`（A-4/D-1）

---
> **下一步（PM）**：填 `〔PM:…〕`+§7 → 定稿 v1.0 移 `docs/specs/prd/` → ledger `prd-ready` → drain。
