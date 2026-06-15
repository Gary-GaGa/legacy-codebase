# STATUS — 重構總彙整 Dashboard（單一入口）

> **定位**：一眼看「整體進度／還剩什麼／卡在誰」。**細節不在這**——逐頁狀態＝`feature-inventory.md`（SSOT）、待決＝`pending-register.md`（SSOT）、Phase V runtime＝`verification/verification-handoff.md`。本檔只彙總層、指向 SSOT，數字來源見各列。
> 更新：里程碑後刷新；最後更新 **2026-06-15**。

## 一、總進度（一句話）
**程式遷移 ~80% 碼在；FE 補建（Phase F+G）全收口；剩唯一 🔴 coding 缺口＝撥貸核心（A-1 換匯 stub）。當前主戰場＝Phase V runtime 驗證（已起本機 FE+BE，挖出並收斂 2 類系統性 bug）。其餘卡在 owner 裁定（AUD/RP/BP/撥貸 domain）。**

```
程式遷移(碼在)   ████████████████░░░░  ~80%   133/166 audit 列（源 feature-inventory §1）
FE 補建          ████████████████████  100%   Phase F c0 評分 9 頁 + Phase G 企金主流程 6 頁+popup
audit 修復包      ████████████████████  100%   5/5（00660/00100/00119/00640/00300）
Phase V runtime  ████░░░░░░░░░░░░░░░░░  ~20%   V-1 登入✅；2 bug 收斂中；smoke V-2~V-6 待跑
撥貸核心(A-1)     ██░░░░░░░░░░░░░░░░░░░  ~10%   throw-stub；OQ recon 中→T24/domain 蓋章
owner 裁定收口    ██████░░░░░░░░░░░░░░░  ~30%   AUD/RP/BP 多項待 owner
```

## 二、各階段狀態（排程見 `feature-inventory.md §5`）
| 階段 | 內容 | 狀態 |
|---|---|---|
| Phase 0 | 坐實缺口 | ✅ |
| Phase F | c0 評分 FE（9 頁） | ✅ 收工 06-09 |
| Phase G | 企金主流程 FE 後半（6 頁+3 popup） | ✅ 收口 06-15 |
| audit 修復包 | 00660/00100/00119/00640/00300 | ✅ 5/5 |
| **Phase V** | **runtime 整合驗證** | 🔵 **進行中**（本檔 §四） |
| Phase D | 撥貸解鎖（A-1+T24+domain） | 🔴 卡 owner（§三） |
| Phase E | c0 收尾 + 授權列套用 | ⏳ 等 ops 套 `c0-authz-sql` |
| Phase R | 暫緩 track（R2 報表/檔案 API） | ⏸ 待拍板 |

## 三、真缺口（剩的 coding）— 只有一個
**🔴 撥貸核心（A-1 `funcGetExchangeRate`）**：authorize 換匯 throw-stub，擋撥貸端到端。施工規格已備（`build-tasks/a1-funcGetExchangeRate-spec.md`），卡在 4 個 OQ → 06-15 改走舊系統對等 recon（OQ-3/4/5 舊系統可定、OQ-1 縮小至 T24 確認）。**執行者＝撥貸 domain RD（非 Codex 逕補）**。

## 四、Phase V runtime（本機 FE+BE，06-15 起；詳 `verification-handoff §6`）
| 項 | 狀態 |
|---|---|
| 起服務 + 登入（V-1） | ✅ |
| **RV-1 Search E999** | ✅ 已修（GET+@RequestBody 矛盾→GET query；`00600`） |
| **RV-2 TODO 空** | 🔧 根因坐實（langType 砍資料）+Owner 裁示定向，修向定（langType 退出資料過濾） |
| 橫向 sweep① langType 砍資料 | 📋 盤點完＝**5 處**待修（2 移除+3 join fallback） |
| 橫向 sweep② GET-body | 📋 盤點完＝**3 處**（2 scorecard→POST；#3 reviseditem 待 RP9） |
| smoke V-2~V-6（Phase G render/save/c0/dialog/teardown） | ⏳ 待跑（c0 需先套授權列） |

## 五、待 owner 裁定（卡在誰 — 不是 Claude 能裁）
> 詳 `pending-register.md`（SSOT）。Claude 角色＝審查/記帳/坐實/把每項「備到蓋章即可」，**裁定權在 owner**。

| 群 | 項 | owner |
|---|---|---|
| 🔴 撥貸 | A-1 OQ（recon→確認）、撥貸 domain group（0921/0922/T24） | T24／撥貸 domain／DBA |
| 🟡 00800 | RP9（init-query method，method 慣例 recon 解鎖）、RP11（execute DTO）、RP8（R6/R7 判據） | RD／架構 |
| 🟡 c0 | E1（CU-return checkpoint）、E2（crScoreCardCompleted 覆寫） | 信用決策 domain |
| 🟡 audit | AUD-1（Property Info 家族）、AUD-2（0211/0213）、AUD-3（admin）、AUD-4（demo）、AUD-6 🔴（財評精度）、AUD-7（54 表）、AUD-8（權限表） | PM／SA／DBA／domain |
| 🧩 seam | BP-1~4（00800 顯示條件/type 軸/展期展變/下游映射）、BP-5（nit） | PM／SA |

## 六、進行中 / 待派（Codex）
- **A 組**：langType 5 處修（Owner 已定向）
- **B 組**：GET-body #1/#2 scorecard export→POST
- **recon**：A-1 OQ 舊系統對等、全站 `epl-*` method 慣例（解鎖 RP9→#3）
- **ops**：`c0-authz-sql` 套 `OVSLXLON02`（解鎖 c0/csu Phase V 與 403）

## 七、SSOT 指引（細節去哪查）
| 要看 | 去 |
|---|---|
| 逐頁 FE/BE 狀態、排程 | `feature-inventory.md` ⭐ |
| 所有待決 + owner + 卡什麼 | `pending-register.md` ⭐ |
| Phase V runtime findings | `verification/verification-handoff.md §6` |
| 任務單（live/done） | `build-tasks/` |
| 盤點總量 diff | `build-tasks/refactor-audit/diff-vs-inventory.md` |
| 決策/事實流水帳 | `decisions.md` |
