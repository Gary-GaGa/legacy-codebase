# i0 / c0 財報 · 評分 · CBC 盤點（D6）

> 目的：盤點 `i0`(個人)/`c0`(企金) 的 財報/財務評估/Scorecard/CBC 結構與資料來源；釐清 **c0 評分如何掛進企金主流程**（B3 發現的橋接），以及 i0↔c0 能否共用「檢視 shell + config」。
> 注意：含 printPDF 報表頁依 **R2 暫緩**；CBC 可能是**外部整合 track**。待 D6 回填。
> D1 已知子頁用途：`0212` CBC、`0216/0219` Financial Statement、`0217/0220` Financial Evaluation、`0218` Scorecard、`0214/0215` 查詢/輔助。已知表：`EPRO_TB_CBC_BGL/_INFO/_GBGL/_GBGL_INFO`。

## 1. 容器與子頁結構
### i0（`EPROI0_0110` / `_0210`）
| funcId | 用途 | 類型（輸入/唯讀/CBC/報表）| 主要表 |
|---|---|---|---|
| _(待 D6)_ | | | |
### c0（`EPROC0_0110` / `_0210`）
| funcId | 用途 | 類型 | 主要表 |
|---|---|---|---|
| _(待 D6)_ | | | |

## 2. i0 vs c0 平行性
- 相同 / 不同（能否共用檢視元件 + config）：_(待 D6)_

## 3. c0 評分橋接（與 M4/M5 綁定）
- `EPROC0_0110` 如何掛進 cs/cu 的 pageMap：_(待 D6)_
- `pageCheckMap` / `getTabsCheckPage()` 追蹤什麼：_(待 D6)_
- 是否申貸**必經步驟**、完成度如何回寫主流程：_(待 D6)_

## 4. 資料來源
- CBC：`EPRO_TB_CBC_BGL/_INFO/_GBGL/_GBGL_INFO`
- 財報 / 財務評估 / Scorecard 各用表：_(待 D6)_
- **輸入（會寫回）** vs **計算後唯讀**：_(待 D6)_

## 5. 報表 / 列印（R2 暫緩）
- printPDF / Jasper 子頁：_(待 D6)_

## 6. CBC 外部整合
- 是否查外部聯徵/信用資料；是否另立 track（如報表）：_(待 D6)_

## 7. → 新架構判定（回填後產出）
- [ ] i0/c0 能否共用「檢視 shell + config」（個人/企金僅 config 差）？
- [ ] c0 評分節點併入 `loan-application` shell（`group=scoring`、`checkStatus`）？
- [ ] CBC / 報表 是否拆為獨立 track？
- 排程：c0 評分與 M4/M5（企金主流程）的綁定程度。
