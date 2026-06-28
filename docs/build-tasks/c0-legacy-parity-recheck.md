# Build Task — 企金線 老系統 parity 補比（c0 評分 9 + CSU 主流程 9 ＝18 頁；reopen）

> **性質**：Codex 唯讀碼驗（帶 source：新 backend/frontend **企金** + **舊企金 `EPROCS_*`/`EPROCU_*`/`EPROC0_*`** + 個金 twin 對照）。**只報不改**。risk-tier、分批回報。
> **判準＝`docs/process/legacy-parity-sop.md`**（舊系統為主 + 三判）。逐頁 disposition 回填 `refactor-audit/per-page-reinventory-matrix.md` 的 `parity vs 舊` / `disposition` 兩欄。
>
> **為何 reopen（整條企金線同病）**：
> - **c0 評分線（00110–00120）**＝當初只對**個金 i0** 鏡像 audit、未對舊企金 c0 行為比（`archive/decisions-2026H1-disbursement.md` 0921「撥貸收斂後評估補比」）。
> - **CSU 主流程（0110–0173）**＝Phase G 由**鏡像個金 ISU twin** 補建（`archive/decisions-2026H1-c0-audit.md` CSU0130「案件編輯子頁鏡像 twin」）、同樣**未對舊企金 cs/cu 驗**。
> - 兩者都是「對個金像、未對舊企金忠實」→ **企金線整體**是 parity 系統性缺口（per-page 矩陣坐實）。撥貸已 06-17 收斂 → 補比到期。

## 現狀更新
> 本卡 06-17 reopen 時 9 包企金尚未產 SRS;現況已變,**比的對象＝rd-done 的碼**:
> - **9 包企金評分（00110/112/114/115/116/117/118/119/120）已 SRS Approved + RD `rd-done` + owner Done**;CSU 主流程(0110–0173)仍多未產 SRS。
> - **部分 parity 已順帶做掉**(矩陣 `parity vs 舊` 欄):**00115 ✅ 對舊驗畢**(fix-round)、**00117 🔶/00120 🔶 business-only 對舊驗畢(決策 B)** → 這 3 頁 parity recheck **降為確認範圍/補殘維度**,非從零。
> - 其餘 ❓ 頁(00110/112/114/116/118/119 + CSU 全線)＝**真缺口、本卡主戰場**:比 rd-done 碼 vs 舊企金 cs/cu/c0。
> - ⚠️ **發現 regression 的後果**:這些頁已 Approved+done → 修正要動 Approved SRS / rd-done 碼,**走 §6.1 例外(owner-gated)+ 回該頁 fix 再審**(同 srs-fix 流程);intended 差異登錄防 churn。
> - SRS 的 N 軸 B(as-is parity)+ RD verifier-regression 已對「i0/現碼」比過;**本卡專補「對舊企金 cs/cu/c0」這軸**(未被前兩者涵蓋者)。

## 可貼 Codex 啟動（母資料夾、T1 先；唯讀碼驗）
```
任務：企金線老系統 parity 補比（唯讀碼驗、只報不改），照 docs/build-tasks/c0-legacy-parity-recheck.md。
本批＝T1（EPROC00118 / EPROC00120 / EPROCSU0170）。
輸入：新企金 backend/frontend（rd-done 碼）+ 舊企金 EPROCS_*/EPROCU_*/EPROC0_*（含 01xx/02xx 展期變體）source + DB。
逐頁照「每頁步驟」五維度（檢核/欄位/side-effect/checkpoint/計分）對【舊企金】比（非對個金 i0）；
每差異三判（legacy-parity-sop §1：regression/刻意演進/DB 結構差）+ 附【新舊雙方】file:line；推不出＝UNFOUND 不猜。
合流：00118 帶 E1/E2（c0-crediteval-e1-e2-escalation.md）；0170 帶審批 gate。
回報：findings → done/c0-legacy-parity-recheck-T1-findings.md（分批、只報不改）；
三判 disposition 回填 per-page-reinventory-matrix.md 的 parity/disposition 兩欄。
規則：唯讀；§6.1 禁改既有 Csu*（要修先核可例外、單獨 commit 先報 diff）；§6.6 計分不准分叉；不拿 i0 audit/inventory 當證據。
停在回報、不自動修、不自裁三判結果（個案裁定回 owner）。
```

## 目的
每頁回答：「**新企金行為（檢核/欄位/側效/checkpoint/計分）與舊企金系統是否對等？差異屬 (a) regression / (b) 刻意演進·縮編 / (c) DB 結構差？**」——非「對個金像不像」（那已做過），而是「**對舊企金 cs/cu/c0 忠不忠實**」。

## risk-tier 批次（金錢/計分/決策生命週期/checkpoint 先）
> 「比的維度重點」＝該頁最該盯的；通則五維（檢核·欄位·side-effect·checkpoint·計分）每頁都過一遍。

### T1（金錢/計分/決策生命週期）— 先做
| 新頁 | 舊企金對應 | 比的維度重點 |
|---|---|---|
| **EPROC00118** Corporate Scorecard | `EPROC0_0118`（+0218 展期變體）| **計分算法**（§6.6 不准分叉）、checkpoint、**E1/E2 合流**（見下）|
| **EPROC00120** FinEval FI | `EPROC0_0120`（+0220）| 財評**金錢欄**取數/精度（連動 AUD-6 caveat）、business-only 決策 B 已對舊驗→確認範圍 |
| **EPROCSU0170** Credit Eval & Decision | `EPROCS_0170+0270`/`EPROCU_0170+0270` | 審批 hub：**submit/return gate 條件**、checkpoint 寫入、CS/CU 分流、決策側效 |

### T2（財評/曝險/案件核心 + checkpoint）
| 新頁 | 舊企金對應 | 比的維度重點 |
|---|---|---|
| **EPROC00116** FinStmt GI | `EPROC0_0116`（+0216）| **calc 保留**正確性、comments 取數 |
| **EPROC00119** FinStmt FI | `EPROC0_0119`（+0219）| 同上（F-8 修過→確認對舊）|
| **EPROC00115** Borrower Group Exposure | `EPROC0_0115`（+0215）| 曝險計算/取數 |
| **EPROCSU0160** Loan Condition(+0261) | `EPROCS_0160+0260`/`EPROCU_0160+0260` | checkpoint 分流；AUD-11 併 vs 分已裁 keep CSU，`:597` checkpoint key 另驗 |
| **EPROCSU0150** Collateral（僅有擔）| `EPROCS_0150+0250` | 三 mat-tab（Info/Valuation/Site Visit）欄位/side-effect、檔案區現狀 |

### T3（borrower 核心 + 其餘評分頁）
| 新頁 | 舊企金對應 | 比的維度重點 |
|---|---|---|
| EPROC00110 容器 | `EPROC0_0110` | businessType/pageMap 動態 tab vs 舊、G/F 分頁 |
| EPROC00112 CBC | `EPROC0_0112` | banking relationship + 幣別計算 |
| EPROC00114 Collateral Assess | `EPROC0_0114` | 無 calc（隱鈕）、rating 唯讀語意（grandfathered §6.1）|
| EPROC00117 FinEval GI | `EPROC0_0117` | business-only（決策 B 已對舊驗）；**AUD-2**：`EPROC0_0211/0213` 展期變體是否本頁涵蓋 |
| EPROCSU0110 Main Borrower | `EPROCS_0110+0210`/`EPROCU_0110+0210` | 欄位/檢核、CS/CU 分流 |
| EPROCSU0120 Co-Borrower | `…0120+0220` | 同 |
| EPROCSU0130 Guarantor | `…0130+0230` | 同（已收尾，確認對舊）|
| EPROCSU0171 Loan Committee Conclusion | `…0171` | save mapper、checkpoint |
| EPROCSU0172 Approved Loan Condition | `…0172` | 檢視/列印鏡像現狀 |
| EPROCSU0173 Credit Evaluation Old | `…0173` | 取數 |

## 每頁步驟（唯讀）
1. **定舊對應**：上表舊 funcId 的 trx/module/JSP `file:line`（注意舊 cs/cu 是兩支 handler、新併為 CSU；舊 c0 有 01xx/02xx 展期變體）。
2. **逐維度比**（對**舊企金**、非對個金）：
   - **檢核/gate**（submit/return 條件、必填、權限）
   - **欄位/取數**（來源表、欄名、DTO 映射）
   - **side-effect**（清欄/還原/連動寫回）
   - **checkpoint**（`TB_CHECK_POINTS_{CS,CU}` 寫哪些 key、CS/CU 分流）
   - **計分算法**（有計分頁；§6.6 不准分叉）
3. **三判每差異**（`legacy-parity-sop §1`）：(a) regression→照舊修回 ／ (b) 刻意演進·縮編（CS/CU→CSU 等）→ keep 新 + 登錄 intended ／ (c) DB 結構差→code 對齊舊行為 + schema 以新為準。
4. 附**新舊雙方** `file:line`；推不出＝UNFOUND，不猜。

## 合流的既有 escalation（一起做、findings 互引）
- **E1/E2 → T1 00118**：`CsuCreditEvalAndCreditDecisionServiceImpl:2985`（CU-return 只清 CS）、`:2890`（`crScoreCardCompleted` 整欄覆寫 `"NN"`）——卡 `c0-crediteval-e1-e2-escalation.md`；「比舊系統 Return/覆寫行為」即本卡 00118 判準的具體化。
- **AUD-11 → T2 CSU0160**：併 vs 分已由 owner Excel（2026-06-28）裁定 `EPROCU_0160/0260` 併入 `EPROCSU0160`；`CsuLoanConditionServiceImpl:597` 讀 `EPROISU0160` 仍作 checkpoint potential regression，CSU0160 對舊比時一併坐實。

## 鐵則
1. **唯讀**；每結論附**新舊** `file:line`；推不出＝UNFOUND，**不拿個金 i0/ISU audit 或 inventory 當證據**（待驗對象是「對舊企金忠實度」）。
2. **§6.1 禁改既有 `Csu*`**：發現 regression 要修既有 `Csu*` → **先核可例外**（比照 00118 `ALLOW_SHARED_FUNC` precedent）才動，單獨 commit、先報 diff。
3. **§6.6 計分算法不准分叉**：00118 等有計分頁特別標。
4. **分批回報**（T1 先），不一次吞 18 頁。

## 回報落點
findings → `done/c0-legacy-parity-recheck-T{n}-findings.md`（分批）；三判結果 → 回填 `decisions.md`（個案裁定）、`pending-register`（企金線 parity 列 + E1/E2）、`feature-inventory §2B/2D`、**`per-page-reinventory-matrix.md`（parity/disposition 兩欄）**。intended 差異**必登錄**（防 churn，`legacy-parity-sop §4`）。

> 過了：企金線 18 頁從「對個金像」升級為「對舊企金忠實」坐實 → 矩陣那 18 個 `❓ parity-gated` 各自落定 keep/fix/rebuild；wholesale 與否由此自然回答。
