# 個人申貸主流程 共用 Shell 分析（`is` / `iu`）— D3

> 目的：抽出 `is`/`iu` × 申請(`_0100`)/覆核(`_0200`) 的**共用多頁籤 shell**，**一次設計、參數化重用**（解 R6 的 4–8 倍重工），並補出 `golden-template` 缺的「頁籤容器」子樣式（R3）。
> ⚠️ 這是規模化前最關鍵的一步：shell 設計對，後面 is/iu/cs/cu 都省；設計錯，整批重工。
> 待 D3 結果回填。

## 1. 頁籤結構（容器 `EPROIS_0110`）
| Tab | 子 JSP / action | 類型（表單/檢視/報表/上傳）| 對應後端 | 備註 |
|---|---|---|---|---|
| _(待 D3)_ | | | | |

> 報表/上傳 tab 依 R2 暫緩、不納入初期。

## 2. `is` vs `iu`、`_0100`（申請）vs `_0200`（覆核）差異
- **相同（共用 shell 基底）**：_(待 D3)_
- **不同（參數化軸）**：_(待 D3)_ — 預期軸：個人別(is/iu) × 流程(申請/覆核) × 可編輯性(覆核多為唯讀+意見)

## 3. 跨頁籤共用狀態 / 資料流
- 案件 / 申請主鍵：_(待 D3)_
- session 屬性 / hidden field：_(待 D3)_
- tab 間傳遞機制（`Tabs.js` / `CSRUtil.AjaxHandler`）：_(待 D3)_

## 4. 共用動作
- 存草稿 / 驗證 / 頁籤導航 / 列印 / 檔案：_(待 D3)_

## 5. → 新架構：共用 shell 設計（回填後產出）
- Angular：`loan-application` shell（`mat-tab-group`）+ 各 tab lazy child component + 共用 **state service**（跨 tab 案件狀態）。
- 參數化：`personal/corporate` × `apply/review` × `is/iu`（route data 或 config 驅動）。
- 各 tab 仍照 config-driven（`field-item-config`/`form-config`）；報表/上傳 tab 暫緩（R2）。
- 補進 `golden-template`：新增「頁籤容器 + 子表單 + 跨頁狀態」子樣式（R3）。
