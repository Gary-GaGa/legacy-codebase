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

> **SoT 原則（ADR-0002／§5b）＋ A-4/M6 re-open（owner 06-20）**：以 Rn 為結論（SRS 即權威）。**A-4 檢核（REQ-002/006）＋ M6 完工日（REQ-003）＝owner 明示 re-open**，to-be **走 §5b SoT 梯裁**：**撥貸核心 as-is baseline＝還原舊版** → 逐項比對 `db-diff`＋`refactor-spec`（過三判）→ **(b) 刻意演進才改＝to-be 新＋`REF-Dn` delta；否則維持舊 baseline；無從裁＝`@PENDING`** → owner 逐項 confirm。06-17「照舊」**降為 as-is baseline、非 SRS 結論**。**不可寫「照舊 ✅」**。已修回 regression（REQ-004/005）維持。〔與 T24 差別：T24 refactor-spec 有對應調整→偏新；核心 A-4/M6 預設舊 baseline、僅命中 delta 才改。〕依據＝`decisions.md`「0921 A-4/M6 於 SRS 層 re-open」＋「撥貸 re-open 的 to-be＝走 §5b SoT 梯裁」。

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

### REQ-002 借款人/共借人檢核（A-4）— ⚠️ owner re-open（不沿用「照舊」為定案）
撥貸前檢核 `CheckMainBorr`/`CheckCoBorr`：身分、sector、account、`DATA_SEQ` 順序、business-section；`info CO_CHECK` 判定；law firm 顯示條件；address 來源。
- **結論方式（§5b 梯裁）**：各檢核項 to-be——①**as-is baseline＝舊判據**（撥貸核心還原舊版；引 `file:line`）②比對 `db-diff`＋`refactor-spec`（過三判）③(b) 刻意演進才改＝to-be 新＋`REF-Dn`；否則維持舊 baseline；無從裁＝`@PENDING`④**owner 逐項 confirm**。**不可寫「照舊 ✅」**。
- **as-is 證據（待逐項坐實、≠結論，confirm 後可維持＝舊 或 改）**：新舊分歧 `CO_CHECK ='Y'` vs 舊 `!='N'`、Finished gate 未驗 `mbCheck`、law firm `IS_SHOW` 版本條件、address `UPD_DATE` 來源。
- **re-open 依據**：`decisions.md`「0921 A-4/M6 於 SRS 層 re-open（06-20 owner）」；06-17「照舊」降為 as-is 輸入。
- **逐項清單（各需 as-is 坐實＋to-be 提案＋owner confirm）**：`CO_CHECK` 判定、`mbCheck` gate（→REQ-006）、law firm `IS_SHOW` 條件、address `UPD_DATE` 來源、`DATA_SEQ` 順序、business-section。
- **強制點**：BE。**@PENDING**：每項未 owner-confirm 前皆 @PENDING（§7 TBD-001）。

### REQ-003 擔保完工日寫入（M6/D-1）— ⚠️ owner re-open（不沿用「照舊」為定案）
collateral 完工日寫 `EST_COM_DATE`/`OTHER_EST_COM_DATE`（**非 null**）。
- **結論方式（§5b 梯裁）**：兩欄值來源 to-be——①**as-is baseline＝舊系統來源**（RD trace legacy FE／衍生點 `file:line`）②比對 `db-diff`＋`refactor-spec` ③有 delta(三判 b) 才改＝to-be 新＋`REF-Dn`；否則維持舊來源；無從裁＝`@PENDING`④**owner confirm**。
- **as-is 證據（≠結論，confirm 後可維持＝舊來源 或 改）**：🔴 現況 `setEstComDate(null)`/`setOtherEstComDate(null)`＝資料遺失（request DTO 無日期值來源）。
- **re-open 依據**：`decisions.md`「0921 A-4/M6 於 SRS 層 re-open（06-20 owner）」。
- **強制點**：BE。**@PENDING**：to-be 值來源未 owner-confirm 前 @PENDING（§7 TBD-002）。

### REQ-004 費用處理（fee 公式 / cleanup）
facility fee＝loan amount × FEE_1；資料返回時 fee cleanup **只刪 `CON_TYPE=FN`**。
- **as-is**：✅ 已修（M7 alias→`LOANAMOUNT`＝facility fee 非 null；M10 cleanup 改 `deleteByApplicationNo(applicationNo,"FN")`、非過度刪）。
- **三判**：(a) 兩者皆 regression→已修回。
- **強制點**：BE。**acceptance**：facility fee 有值；cleanup 不刪非-FN。

### REQ-005 RECEIVED_DATE 寫入時機
`RECEIVED_DATE` **只在 Finished 時寫**。
- **as-is**：✅ 已修（M4 加 `isFinish` guard，舊僅 Finished 寫）。
- **強制點**：BE。**acceptance**：未 Finished 不寫 RECEIVED_DATE。

### REQ-006 Finished gate — ⚠️ owner re-open（A-4，不沿用「照舊」為定案）
資料完成（Finished）的判定條件。
- **結論方式（§5b 梯裁）**：Finished 判定條件 to-be——as-is baseline＝舊判據（含是否驗 `mbCheck`）→ 比對 `db-diff`＋`refactor-spec`（過三判）→ 有 delta 才改、否則維持舊 → **owner confirm**；無從裁＝`@PENDING`。**不可寫「照舊 ✅」**。
- **as-is 證據（≠結論）**：🟡 新 Finished gate 未驗 `mbCheck`（A-4）。confirm 後決定是否補驗。
- **re-open 依據**：`decisions.md`「0921 A-4/M6 於 SRS 層 re-open（06-20 owner）」。
- **強制點**：BE。**@PENDING**：§7 TBD-001（`mbCheck` gate 項）。

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
| TBD-001 | **A-4 各檢核 to-be 走 §5b 梯裁＋owner 逐項 confirm**（re-open；CO_CHECK 判定／mbCheck gate／law firm IS_SHOW／address UPD_DATE／DATA_SEQ；as-is baseline=舊→比對 refactor-spec/db-diff→delta 才改／否則舊→confirm；未 confirm＝@PENDING）| 撥貸 domain（confirm）＋ RD/Codex（as-is 坐實＋讀 refactor-spec）|
| TBD-002 | **M6 完工日值來源 to-be 走 §5b 梯裁＋owner confirm**（re-open；舊來源 trace as-is→比對 refactor-spec/db-diff→delta 才改／否則舊→confirm；未 confirm＝@PENDING）| 撥貸 domain（confirm）＋ RD（trace＋讀 refactor-spec）|

## 8. maxlength / 必要
〔PM/RD: 由 refactor-spec `04_rules/field_rule.md` 抽〕

## 9. as-is findings 路徑
- `docs/disbursement/disbursement-triage.md`（§2/§3/§7 M4/M6/M7/M10、§7.1 進度）
- `docs/disbursement/disbursement-domain-escalations.md`（A-4/D-1）

---
> **下一步（PM）**：填 `〔PM:…〕`+§7 → 定稿 v1.0 移 `docs/specs/prd/` → ledger `prd-ready` → drain。
