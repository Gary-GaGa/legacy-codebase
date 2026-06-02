# 企金申貸 shell 重用確認（`cs` / `cu` vs `is` / `iu`）— B3

> 目的：確認企金 `cs`/`cu` 能否**直接重用** `is`/`iu` 的兩層 shell（見 `module-is-iu-shell.md`），差異是否僅在 **config（頁清單）+ 內層 section 元件**。
> 預期：shell（外層 nav + 子路由 + context）重用；企金**內層 tabs 與部分頁不同**（要新做企金 section 元件）。
> 待 B3 回填。

## 1. pageMap 機制是否同套
- `EPRO_Z0Z006` 是否有 `formatCS()`/`formatCU()`、與 `formatIS/IU` 同一套 pageMap？切頁是否一樣 `{funcId}/prompt` 重查：_(待 B3)_

## 2. 外層流程頁對照（cs 0100 ↔ is 0100）
| cs funcId | 類型 | 對應 is | 企金獨有? |
|---|---|---|---|
| _(待 B3)_ | | | |

## 3. 有擔/無擔（cs ↔ cu）
- cu 缺哪些頁（對照 is/iu 的 collateral 缺頁）：_(待 B3)_

## 4. 內層區塊 tabs（`EPROCS_0110` 企金主借款戶）
- `Tabs()` 定義哪些頁內 tab：_(待 B3)_（個人為 Personal/Work/Family；企金預期為 公司基本資料/負責人/關係企業… → **新做企金 section 元件**）

## 5. 資料流 / 主鍵
- 是否同樣 `APPLICATION_NO` + session/attrMap + 每頁 initQuery + Ajax execute：_(待 B3)_

## 6. `_0100`（申請）/ `_0200`（覆核）
- 是否同 is 模式（審批段 `0170~` vs `0270`）：_(待 B3)_

## 7. 企金獨有
- CAD report `0181`、與 `c0` 財報/評分串接、其他 is/iu 沒有的：_(待 B3)_

## 8. 結論：shell 重用判定
- [ ] 外層 shell（nav + 子路由 + context）可重用？
- [ ] 差異是否僅 **config + 內層 section 元件**？
- → 若是：**M4/M5 = 既有 shell + cs/cu config + 企金 section 元件**（低成本，D3 紅利擴到企金）。
