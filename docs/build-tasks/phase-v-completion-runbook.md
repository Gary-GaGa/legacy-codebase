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

## C. v3 前置（你定 2 項 → 才發正式 v3）
- [ ] **C⑤ owner 定**：
  - **測試案件號段**：哪個 `APPLICATION_NO` 範圍可用、不撞真案（SELECT 確認未佔）。
  - **v3 範圍**：納哪些 save/submit 頁；**排除**撥貸 authorize（T24/SFTP）/報表/上傳。
  - （隨後 ops/DBA：測試時段 + 受影響表快照。）
- [ ] **C⑥ 發正式 v3** — planning 依 v2 結果框候選頁 + 側效可逆性初判 + 你定號段/範圍 → 正式 v3 dispatch（草稿＝`phase-v-l2-v3-writes.md`）。

## D. v3 + L3 → Phase V 收尾
- [ ] **D⑦ v3 跑（母資料夾）** — 寫入經 app 端點、唯讀驗落庫、**產 teardown SQL 交人審**（不自跑 DML）→ 回報 → 複驗 → 寫入段收。
- [ ] **D⑧ L3 FE Playwright（可與 v3 並行）** — 草稿＝`phase-v-l3-fe-playwright.md`；ops 先定 browser 來源（系統 Chrome vs 內網 mirror）+ Node16 釘版。
- [ ] **完成**：gate ⑧ runtime conformance 覆蓋 讀(v2)+寫(v3)+FE(L3) → **Phase V 收尾** → 進 **B 段：全 SRS 轉換**（撥貸 0920/CSU 主流程/SU0170 finalize/ISU·i0·z0；母資料夾 Codex orchestrator drain）。

## 關聯卡
- 缺口：`phase-v-v2c0-langtype-option-count-gap.md`、`-eproc00117-financial-business-ratios-gap.md`、`-eproc00119-page-auth-seed-gap.md`
- 段卡：`phase-v-l2-v3-writes.md`（DRAFT）、`phase-v-l3-fe-playwright.md`（DRAFT）、`phase-v-automation-plan.md`、`phase-v-env-manager.md`、`process/local-env-manager.md`
- 機制：gate ⑧＝`orchestration-playbook §4c`；harness＝`phase-v-api-selfverify-harness.md`
