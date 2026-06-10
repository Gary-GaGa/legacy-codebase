# 企金申貸 shell 重用確認（`cs` / `cu` vs `is` / `iu`）— B3 結果

> **結論：外層 shell 機制可重用，但不是 1:1 套用。** pageMenu/pageMap/prompt/initQuery/切頁重查/`APPLICATION_NO` context 全相同（`EPRO_Z0Z006` 有 `formatCS()/formatCU()`，與 IS/IU 同由 `getAttribute()` 派發）。
> 差異需：**頁清單配置化（每模組）+ 企金內層元件 + 處理企金特有的 c0 評分/檢核橋接層**。

## 1. ✅ 可重用（殼 / 機制）
- 外層 `pageMenu` + `{funcId}/prompt` 導頁、切頁重查；`pageMap` 驅動（`EPRO_Z0Z006.formatCS()/formatCU()`）。
- `APPLICATION_NO` 主鍵 + session/attrMap + 每頁 `initQuery` + Ajax `execute`。
- header / 權限 / 導頁機制共用。

## 2. ⚠️ 不能直接硬套（差異）
### 2.1 流程頁清單（必須配置化，每模組一份）
| is | cs | 說明 |
|---|---|---|
| 0110↔0210 | 0110↔0210 | 主借款戶 |
| 0120 | 0120 | 共同借款戶 |
| 0130 | 0130 | 保證人 |
| **0140** | — | 個人住宅頁（**cs 無**）|
| 0150 | 0150 | 擔保品 |
| 0160 | 0160 | 條件/檢核 |
| 0170/0270 | 0170/0270 | 審批 hub |
| **0190** | — | 擔保品提供人（**cs 無**）|
| — | **0240** | 公司核心資料（舊 cs 0200 端有；**新系統不開發**，2026-06-06 確認無使用）|
| 0181 | 0181 | CAD report（**兩邊都有，非企金獨有**）|
- cs 0100 實際：`0110/0120/0130/0150/0160/0170/0171/0172/0173/0174/0175/0181`。
- cs 0200 實際（舊）：`0210/0220/0230/0240/0250/0260/0261/0270`（⚠️ `0240` 公司核心資料**新系統不開發**）。

### 2.2 cs vs cu：不只差 collateral
- cu 0100 少：`0140`、`0150`、`0176`。
- cu 0200 少：`0240`、`0250`、`0251`、`0290`。
- → cu 是**更簡化的無擔流程**，不只少 collateral。

### 2.3 內層 tabs：每頁可選，不在主借款戶頁（修正）
- ⚠️ **`EPROCS_0110`/`EPROCU_0110` 只有單一 tab**（單頁表單包一層 Tabs 殼）——**不是** IS/IU 的 Personal/Work/Family 多 tab。
- 企金真正多 tab 的是 **`EPROCS_0250` 擔保品**：Collateral Info / Valuation Info / Site Visit Report。
- → 架構修正：內層 `mat-tab-group` 是 **每頁可選**，勿假設主借款戶頁必有多 tab。

### 2.4 企金特有：c0 評分/檢核橋接層
- **`EPROC0_0110` 被 pageMap 額外掛進** 企金流程當共用節點；c0 子頁用 `pageCheckMap`/`getTabsCheckPage()` 追蹤完成度。
- → 企金流程 = CS/CU 頁 + **嵌入一層 c0 評分 shell**；page descriptor 需表達「掛載的評分/檢核節點 + 完成狀態」。
- 另有跨模組檢核頁 `EPROZ0_0300`/`0410`/`0500`。
- ⚠️ **連帶影響**：M6/M7（i0/c0）的 c0 部分與主流程（M4/M5）綁定，排程時需一起考慮。

## 3. `_0100` / `_0200`：同 is 模式 ✅
0100 蒐集/建檔；0200 覆核/審批/條件調整 + popup（`0260→0261`、`0270→0174/0175`）。

## 4. 對共用 shell 設計的影響（已套用回 `module-is-iu-shell.md` / golden-template §八）
1. **page descriptor set 改「每模組 × mode」一份**（is/iu/cs/cu × edit/review），由後端 `pageMap`(formatXX) 產出 → 前端 shell 仍泛型。
2. **內層 tabs 改每頁可選**：PageDescriptor 加 `sections?`（主借款戶 0/1 個；collateral 0250 多個）。
3. **新增 `group` 與檢核狀態**：PageDescriptor 加 `group`(borrower/collateral/conditions/scoring/approval) + `checkStatus?`（對應 `pageCheckMap`）。
4. **c0 評分節點**：以 descriptor（`group=scoring`）掛入同一外層 shell，共用 c0 section 元件。

## 5. 重用判定（結論）
- [x] 外層 shell（nav + 子路由 + context + pageMap 機制）**可重用**。
- [x] 子路由框架可重用。
- [ ] ~~只改一份頁清單~~ → **否**：需每模組 config + 企金內層元件（`0250` collateral 三分頁、c0 評分橋接）。
- **M4/M5 成本修正**：**殼免費**；要做 cs/cu × edit/review 的 descriptor config + 企金 section 元件（主借款戶單頁、collateral 三分頁、c0 評分橋接）。比「幾乎免費」多，但仍**遠低於重做一套 shell**。
