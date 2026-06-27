# Phase V 完成 Runbook（照表走到 Phase V 收尾 → B 段全 SRS）

> 單一操作清單：從「v2 三缺口」到「v3 + L3 收尾」。每步標 **誰做 / gate / 狀態**。執行載具＝母資料夾 Codex（產品/DB/localhost）；本 repo 留本卡追蹤。
> 現況：L1 env manager ✅、v1（langType LT + EPROZ00800 RI）✅、**v2-c0 A① auth PASS；A② RD 修 build pass；B③ runtime 17/17 PASS**。

Runtime update (2026-06-27): v2-c0 rerun completed with `tools/phase-v-run.ps1
-SkipBuild` exit `0`; all 17 manifest cases passed, including `C0-115-SELE`,
`C0-116-SELE`, `C0-117-SELE`, `C0-117-INFO`, `C0-119-SELE`, `C0-119-INFO`,
`C0-119-QUER`, and `C0-120-INFO`. Final teardown left no `5500` / `4200`
listener.

## A. 修 v2 三缺口（A① 與 A② 可並行）
- [x] **A① #3 seed（你/DBA @ OVSLXLON02）** — `phase-v-v2c0-eproc00119-page-auth-seed-gap.md` 已收斂：
  - DBA 已套 seed；SELECT-only 複驗 `EPROC00119` 與順帶缺漏的 `EPROC00120` 均已補齊 page-column-auth。
  - **gate**：`EPROC00119` category/detail = `3/46`、`EPROC00120` category/detail = `3/64`，且 transformed mirror parity 均為 `0/0`。
- [x] **A② #1+#2 RD 修（母資料夾 Codex）** — 貼「v2-c0 三缺口修復」dispatch 的 #1/#2：
  - #1 langType（115/116/117/119 sele）：`findByFields` 改為 requested lang label + `en_US` fallback，不再用 `langType` 刪 parent option rows。
  - #2 00117 ratios：`isQuery=true` 時即使 `financialList` 空，也回 persisted `TB_FINANCIAL_EVALUATION_GI` ratios。
  - **gate**：`mvn clean package "-Dmaven.test.skip=true"` 綠；不改 fixture、不放寬斷言。B③ runtime 已 17/17 PASS。

## B. 重跑 v2 + 複驗
- [x] **B③ 重跑 v2（母資料夾）** — `tools/phase-v-run.ps1`（v2 manifest）→ **17 cases 全 PASS**（LT/RI + 5 assertion + 2 auth〔119〕）。**gate**：無 assertion FAIL、119 不再 AUTH_FAILED、down 後無 5500/4200 listener。
- [x] **B④ 回報 → planning 複驗** — `phase-v-v2c0-b4-planning-reverify.md`：langType 真改 label（非改 fixture 湊綠）、#2 對現行 openapi 為真缺口、#3 seed 完整、全綠。

## C. RD-gate-⑧ 讀型收尾（v2 綠即達成）
> **owner 2026-06-27（在 v2-c0 PASS 之後定）：gate ⑧（RD Flow）＝讀型 v1/v2 only**。A+B 完成（v2 17/17 全綠）＝**9 c0 頁讀型 runtime conformance 收尾**＝RD 端 gate ⑧ 這批達標。〔註：v2-c0 結果是此決策前跑的；下方 v3/L3 已依新決策改歸屬。〕
- [x] **C⑤** v2 綠 + 複驗過 → gate ⑧ 讀型對 9 c0 頁達成（B④ reverify PASS）。

## D. 移出 RD 的部分（不阻 B 段）
- **v3 寫入＝PARKED → QA Flow**（owner 2026-06-27；案件流程耦合、單頁難孤立）：**不在 RD gate ⑧**、**不是 v2 後的下一步**。卡＝`phase-v-l2-v3-writes.md`（QA Flow 整合 tier 草稿）。過渡：高風險 save fixture-case 半自動 + 廣面 UAT。
- **L3 FE Playwright＝PARKED → QA Flow**（owner 2026-06-27；FE 整合層，與 v3 同歸）：**不在 RD gate ⑧**。卡＝`phase-v-l3-fe-playwright.md`。
- **RD 端收尾**：gate ⑧ 讀型(v1/v2)綠即收；寫入/整合 → QA Flow（未來）。→ **下一步＝B 段全 SRS 轉換**（撥貸 0920/CSU 主流程/SU0170 finalize/ISU·i0·z0；母資料夾 Codex orchestrator drain）。**B 段不被 v3/L3 阻擋。**

## 關聯卡
- 缺口（已 resolved）：`phase-v-v2c0-langtype-option-count-gap.md`、`-eproc00117-financial-business-ratios-gap.md`、`-eproc00119-page-auth-seed-gap.md`；複驗＝`phase-v-v2c0-b4-planning-reverify.md`、seed＝`phase-v-v2c0-page-column-auth-seed-findings.md`
- v3/L3（移出 RD）：`phase-v-l2-v3-writes.md`（PARKED→QA Flow）、`phase-v-l3-fe-playwright.md`（PARKED→QA Flow）
- 機制：gate ⑧＝`orchestration-playbook §4c`（讀型 only）；分層決策＝`decisions.md`
