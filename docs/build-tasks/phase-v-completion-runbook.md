# Phase V 完成 Runbook（照表走到 Phase V 收尾 → B 段全 SRS）

> 單一操作清單：從「v2 三缺口」到「v3 + L3 收尾」。每步標 **誰做 / gate / 狀態**。執行載具＝母資料夾 Codex（產品/DB/localhost）；本 repo 留本卡追蹤。
> 現況：L1 env manager ✅、v1（langType LT + EPROZ00800 RI）✅、**v2-c0 已跑＝抓 3 真 bug（FAIL，修復中）**。

## A. 修 v2 三缺口（A① 與 A② 可並行）
- [ ] **A① #3 seed（你/DBA @ OVSLXLON02）** — `phase-v-v2c0-eproc00119-page-auth-seed-gap.md` 的 recipe：
  - 步驟0 確認欄名 → 步驟1 盤點（EPROC00119 cnt=0?其他 c0 頁漏否）→ 步驟2 鏡像 `INSERT…SELECT`（EPROI00119→EPROC00119）→ commit。套前審：角色同組否 / 冪等 / 只動 c0 funcId。
  - **gate**：`SELECT … funcId='EPROC00119'` 有列。
- [ ] **A② #1+#2 RD 修（母資料夾 Codex）** — 貼「v2-c0 三缺口修復」dispatch 的 #1/#2：
  - #1 langType（115/116/117/119 sele）：c0 選項查詢改「label-join 不刪列」（同 `done/langtype-data-filter-sweep`）。
  - #2 00117 ratios：確認 openapi required → 補 BE 回 ratios（契約模糊則 escalate）。
  - **gate**：`mvn` build 綠；不改 fixture、不放寬斷言。

## B. 重跑 v2 + 複驗
- [ ] **B③ 重跑 v2（母資料夾）** — `tools/phase-v-run.ps1`（v2 manifest）→ 目標 **17 cases 全 PASS**（LT/RI + 5 assertion + 2 auth〔119〕）。**gate**：無 assertion FAIL、119 不再 AUTH_FAILED、down 後無 5500/4200 listener。
- [ ] **B④ 回報 → planning 複驗** — langType 真改 label（非改 fixture 湊綠）、#2 對現行 openapi 為真缺口、#3 seed 完整、全綠。

## C. RD-gate-⑧ 讀型收尾（v2 綠即達成）
> **owner 2026-06-27：gate ⑧（RD Flow）＝讀型 v1/v2 only**。A+B 完成（v2 17 cases 全綠）＝**9 c0 頁讀型 runtime conformance 收尾**＝RD 端 gate ⑧ 這批達標。
- [ ] **C⑤** v2 綠 + 複驗過 → gate ⑧ 讀型對 9 c0 頁達成；回填 ledger/handoff。

## D. 移出 RD 的部分（不阻 B 段）
- **v3 寫入＝PARKED → QA Flow**（owner 2026-06-27；案件流程耦合、單頁難孤立）：**不在 RD gate ⑧**。卡＝`phase-v-l2-v3-writes.md`（QA Flow 整合 tier 草稿）。過渡：高風險 save fixture-case 半自動 + 廣面 UAT。
- **L3 FE Playwright**：草稿＝`phase-v-l3-fe-playwright.md`；**歸屬待定**（FE 偏整合——留 Phase V 獨立段 or 一併歸 QA Flow？owner 定）。ops 前置：browser 來源 + Node16 釘版。
- **完成**：RD 端 = gate ⑧ 讀型(v1/v2)綠即收；寫入/整合 → QA Flow（未來）。→ **可進 B 段：全 SRS 轉換**（撥貸 0920/CSU 主流程/SU0170 finalize/ISU·i0·z0；母資料夾 Codex orchestrator drain）。**B 段不被 v3/L3 阻擋。**

## 關聯卡
- 缺口：`phase-v-v2c0-langtype-option-count-gap.md`、`-eproc00117-financial-business-ratios-gap.md`、`-eproc00119-page-auth-seed-gap.md`
- v3/L3（移出 RD）：`phase-v-l2-v3-writes.md`（PARKED→QA Flow）、`phase-v-l3-fe-playwright.md`（DRAFT，歸屬待定）
- 機制：gate ⑧＝`orchestration-playbook §4c`（讀型 only）；harness＝`phase-v-api-selfverify-harness.md`；分層決策＝`decisions.md`
