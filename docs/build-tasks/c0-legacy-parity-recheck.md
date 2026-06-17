# Build Task — c0 評分線 老系統 parity 補比（reopen；套 legacy-parity-sop 三判）

> **性質**：Codex 唯讀碼驗（帶 source：新 backend c0 + **舊企金 c0** `EPROCS_*/EPROCU_*` + i0 twin 對照）。**只報不改**。risk-tier、分批。
> **為何 reopen**：c0 評分線（00114–00120）當初**只對 i0 鏡像 audit、未對舊企金 c0 行為比**（`decisions.md` 0921 列：「c0 頁 00115–00120 當初只對 i0 audit、未對舊系統行為比 → **撥貸收斂後評估是否補比**」）。**撥貸已於 2026-06-17 收斂** → 補比到期。**E1/E2**（`CsuCreditEvalAndCreditDecisionServiceImpl:2985/:2890`）即此缺口的先聲；本卡涵蓋更廣。
> **判準＝`docs/process/legacy-parity-sop.md`**（舊系統為主 + 三判）。

## 目的
回答每頁：「**新 c0 行為（檢核/欄位/側效/checkpoint/計分）與舊企金 c0 是否對等？差異屬 regression / 刻意演進·縮編 / DB 結構差？**」——非「對 i0 像不像」（那已做過），而是「**對舊企金系統忠不忠實**」。

## risk-tier 順序（金錢/checkpoint/計分先）
| 批 | 頁 | 為何此序 |
|---|---|---|
| **T1** | **00118**（corporate scorecard，有計分/checkpoint；已帶 E1/E2）、**00120**（財評 FI，金錢欄）| 金錢/計分/決策生命週期，錯了最貴 |
| **T2** | **00116**（財評 comments）、**00119**（財評 cmts FI）、**00115**（borrower group exposure）| 財評/曝險，中風險 |
| **T3** | **00117**（財評 GI，已 business-only 裁定）、**00114**（CsuCollateralAssessment，grandfathered §6.1）| 較穩，殿後確認 |

## 每頁步驟（唯讀）
1. **定舊對應**：該新 c0 頁對應的**舊企金 c0** funcId（`EPROCS_xxx`/`EPROCU_xxx`）+ 其 trx/module/JSP `file:line`。
2. **逐維度比**（對舊、非對 i0）：
   - **檢核/gate**（submit/return 條件、必填、權限）
   - **欄位/取數**（來源表、欄名、DTO 映射）
   - **side-effect**（清欄/還原/連動寫回）
   - **checkpoint**（`TB_CHECK_POINTS_{CS,CU}` 寫哪些 key、CS/CU 分流）
   - **計分算法**（若該頁有；§6.6 算法不准分叉）
3. **三判每差異**（`legacy-parity-sop §1`）：(a) regression → 照舊修回 ／ (b) 刻意演進·縮編（CS/CU→CSU 等）→ keep 新 + 登錄 intended ／ (c) DB 結構差 → code 對齊舊行為 + schema 以新為準。
4. 附新舊雙方 `file:line`；推不出＝UNFOUND。

## 與 E1/E2 的關係
E1（CU-return 只清 CS、無 CU 分流）、E2（`crScoreCardCompleted` 整欄覆寫 `"NN"`）＝00118 既有 `Csu*` 的 parity 疑點，已有卡 `c0-crediteval-e1-e2-escalation.md`。本卡 **T1 00118** 與之**合流**：E1/E2 的「比舊系統 Return/覆寫行為」即本卡判準的具體化 → 一起做、findings 互引。

## 鐵則
1. **唯讀**；每結論附新舊 `file:line`；推不出＝UNFOUND，**不拿 i0 audit/inventory 當證據**（待驗對象是「對舊忠實度」，不是「對 i0 像」）。
2. **§6.1 禁改既有 `Csu*`**：發現 regression 要修既有 `Csu*` → **先核可例外**（比照 00118 `ALLOW_SHARED_FUNC` precedent）才動，單獨 commit、先報 diff。
3. **§6.6 計分算法不准分叉**：00118 等有計分頁的算法差異特別標。
4. 分批回報（T1 先），不一次吞全線。

## 回報落點
findings → `done/c0-legacy-parity-recheck-T{n}-findings.md`；三判結果 → 回填 `decisions.md`（個案裁定）、`pending-register`（c0 parity 列 + E1/E2）、`feature-inventory §2D/⑤`（頁狀態 parity 維度）。intended 差異**必登錄**（防 churn，`legacy-parity-sop §4`）。

> 過了：c0 評分線從「對 i0 像」升級為「對舊企金忠實」坐實；E1/E2 連同收斂；feature-inventory c0 頁的「✅」從結構義升為行為義。
