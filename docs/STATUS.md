# STATUS — 重構總彙整 Dashboard（單一入口）

> **定位**：一眼看「整體進度／還剩什麼／卡在誰」。**細節不在這**——逐頁狀態＝`feature-inventory.md`（SSOT）、待決＝`pending-register.md`（SSOT）、Phase V runtime＝`verification/verification-handoff.md`。本檔只彙總層、指向 SSOT，數字來源見各列。
> 更新：里程碑後刷新；最後更新 **2026-06-16**（orchestration pilot + legacy schema 全面復驗）。

## 一、總進度（一句話）
**程式遷移 ~80% 碼在；FE 補建（Phase F+G）全收口；🟢 撥貸核心 A-1 換匯 stub 06-16 已實作（`daae4c3`，mvn 綠）→ 原唯一 🔴 coding 缺口收。撥貸真完成剩＝T24 正確性（domain-gated）＋新查出的批次層 B001–B008（待碼驗，F-OWN-1）。當前主戰場＝Phase V runtime 驗證。其餘卡在 owner 裁定（AUD/RP/BP/撥貸 domain）。**

```
程式遷移(碼在)   ████████████████░░░░  ~80%   133/166 audit 列（源 feature-inventory §1）
FE 補建          ████████████████████  100%   Phase F c0 評分 9 頁 + Phase G 企金主流程 6 頁+popup
audit 修復包      ████████████████████  100%   5/5（00660/00100/00119/00640/00300）
Phase V runtime  ████░░░░░░░░░░░░░░░░░  ~20%   V-1 登入✅；2 bug 收斂中；smoke V-2~V-6 待跑
撥貸核心(A-1)     ████████████░░░░░░░░  ~60%   ✅ A-1 stub+conformance、✅ 批次層 AUD-10(6/8+B005銷案)；剩 T24 檔正確性(B-group,domain/T24-spec)
owner 裁定收口    ████████████░░░░░░░░  ~60%   06-16 關 RP9/AUD-6/AUD-9/A-1 OQ/AUD-1；餘 AUD-2/3/4/7/8/10/11、RP8/11、E1/E2、BP、撥貸 group
```

## 二、各階段狀態（排程見 `feature-inventory.md §5`）
| 階段 | 內容 | 狀態 |
|---|---|---|
| Phase 0 | 坐實缺口 | ✅ |
| Phase F | c0 評分 FE（9 頁） | ✅ 收工 06-09 |
| Phase G | 企金主流程 FE 後半（6 頁+3 popup） | ✅ 收口 06-15 |
| audit 修復包 | 00660/00100/00119/00640/00300 | ✅ 5/5 |
| **Phase V** | **runtime 整合驗證** | 🔵 **進行中**（本檔 §四） |
| Phase D | 撥貸解鎖（A-1+T24+domain） | 🟠 **A-1 stub ✅ 已實作（`daae4c3`）**；剩 T24 正確性（domain）+批次層 B001–B008（碼驗）+spec-conformance（§三） |
| Phase E | c0 收尾 + 授權列套用 | ⏳ 等 ops 套 `c0-authz-sql` |
| Phase R | 暫緩 track（R2 報表/檔案 API） | ⏸ 待拍板 |

## 三、真缺口（剩的 coding）— 只有一個
**🟢 撥貸核心（A-1 `funcGetExchangeRate`）＝已實作＋conformance PASS（`daae4c3`，06-16，mvn 綠）**：補 return＋移尾端 throw → authorize 換匯總開關打通；**Codex 唯讀碼驗 4/4 PASS**（OQ-1 `IdNo=OVSLXLON01`、OQ-3 非0000拋錯中止 authorize〔碼＝專屬 `FAILED_E304`〕、OQ-4 throw 勿回 null、兩表同 `@Transactional`）。OQ-5 G/H 欄名 bug 另已修 `581e717`。**剩撥貸端到端真完成**：① **T24 正確性**（B-group 來源欄/格式，domain/T24-spec gated）② ✅ **批次層 AUD-10 結**（06-16）：6/8 FOUND（新批次重編號）+ **B005 銷案**（無 `TB_EXCHANGE_RATE` read 點→inline 取代每日批次）→ **撥貸下游交付不缺**；B008 log 歸檔＝ops（非 app）③ 唯一復驗點＝新環境 T24 拒收 `IdNo=01` 則改 02。**撥貸真正剩的大塊＝T24 檔正確性（B-group，domain/T24-spec）**。

## 四、Phase V runtime（本機 FE+BE，06-15 起；詳 `verification-handoff §6`）
| 項 | 狀態 |
|---|---|
| 起服務 + 登入（V-1） | ✅ |
| **RV-1 Search E999** | ✅ 已修（`00600`） |
| **RV-2 TODO 空** | ✅ 已修（`bbbaa19`；筆數一致 zh_TW=en_US=91） |
| 橫向 sweep① langType 砍資料 | ✅ **5 處全修**（`bbbaa19`+`7e1f0d2`；五頁筆數一致；卡歸檔） |
| 橫向 sweep② GET-body | 🔧 #1/#2 scorecard ✅；**#3 reviseditem 解鎖**（RP9 ✅ 06-16=GET）→ 改 GET query 同 00600，可派工 |
| smoke V-2~V-6（Phase G render/save/c0/dialog/teardown） | ⏳ 待跑（c0 需先套授權列） |

## 五、待 owner 裁定（卡在誰 — 不是 Claude 能裁）
> 詳 `pending-register.md`（SSOT）。Claude 角色＝審查/記帳/坐實/把每項「備到蓋章即可」，**裁定權在 owner**。

| 群 | 項 | owner |
|---|---|---|
| 🟠 撥貸 | 〔A-1 stub ✅ 已實作 `daae4c3`〕撥貸 domain group（T24 正確性、檢核嚴格度、KHR、欄寬、async、M6）＋**批次層 B001–B008（AUD-10 待碼驗）**＋A-1 spec-conformance | T24／撥貸 domain／RD |
| 🟡 00800 | RP11（execute DTO）、RP8（R6/R7 判據）〔RP9 init-query＝GET 已 06-16 關（Follow PRD）〕| RD／架構 |
| 🟡 c0 | E1（CU-return checkpoint）、E2（crScoreCardCompleted 覆寫） | 信用決策 domain |
| 🟡 audit | AUD-2（0211/0213）、AUD-3（admin）、AUD-4（demo）、AUD-7（54 表）、AUD-8（權限表）、**AUD-10（批次層碼驗）**、**AUD-11（CU0160 碼驗）**〔AUD-1 Property Info、AUD-6 財評精度、AUD-9 deputy PK 已 06-16 關〕| PM／SA／DBA／domain／RD |
| 🧩 seam | BP-1~4（00800 顯示條件/type 軸/展期展變/下游映射）、BP-5（nit） | PM／SA |

## 六、進行中 / 待派（Codex）
- ✅ **A 組 langType 5 處**（`bbbaa19`+`7e1f0d2`）、**B 組 get-body #1/#2**（`751f78f`）、**A-1 OQ recon**（`fe3f129`）全完成
- ✅ **orchestration pilot 通過（06-16）**：Task1 method recon（→ RP9 證據齊）+ Task2 0922 typo（`581e717`）;四條紀律全守→可放大批量 PRD→SRS
- ✅ **0922 T24 G/H typo 修**（`581e717`，OQ-5）→ 歸檔
- **RP9 待 RD/架構裁**（method recon 證據已齊：POST 全站一致 vs GET RESTful/PRD）→ 裁後 get-body #3 解鎖
- ✅ **legacy schema 全面復驗（06-16）**：7 🔴 早期推斷（DB 未通時代）已校正回 legacy 內文（71→142表/CROSS_CHARGE 表名/SCORE_CARD/EMP_PROXY 複合PK/T24_BRANCH_CODE/FUNCTION_ID/FUNCTION_INFO）；deputy 已完成頁複合 PK **驗證無 bug**（AUD-9 關）
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
