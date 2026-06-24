# QA orchestrator — drain 啟動卡（rd-done → 三層測試 + 報告 批量）

> **用途**：把 `rd-done→qa-ready` 的頁批量 drain 成「三層測試 + 測試報告清單」。owner 標多頁 `qa-ready`，orchestrator **序列一次一頁**逐頁產測試、跑、出報告，drain 到所有 `qa-ready`→`qa-passed` 才停。
> **迴圈權威＝`docs/process/orchestration-playbook.md §5d/§6d`**（本卡＝可貼運行殼，內容權威在 playbook）；殼 ↔ 權威由 `python scripts/check-prompt-parity.py` 機械驗。
> **單頁測試 prompt＝`qa-codex-dispatch.md`**；對映＝`qa-to-test.md`、FE＝`fe-test-convention.md`、報告＝`qa-report-format.md`。
> **在哪跑**：母資料夾 Codex（可跑 Testcontainers/Playwright + dev/uat DB）。本 planning repo 跑不了。

---

## 步驟 0 — owner 前置
1. 該頁 ledger status=`rd-done`（build 綠）——**QA 入口閘**。
2. 把要這批測的頁 status 由 `rd-done` 改 `qa-ready`。owner 控放量、orchestrator 控 drain。

---

## 步驟 1 — 貼這段給母資料夾 Codex（drain orchestrator）

```
你是 QA orchestrator（drain 模式）。任務板＝per-page-reinventory-matrix ledger。權威迴圈＝
orchestration-playbook §5d/§6d、§4d（QA 軸）。對映＝qa-to-test.md、fe-test-convention.md、報告＝qa-report-format.md。

0. 入口閘：只取 status=qa-ready 且其前置=rd-done、build 綠。build 紅→拒、回報。

1. DRAIN 迴圈——只要 ledger 還有 status=qa-ready（可多頁）就繼續：
   a. 取 risk-tier 最前、同 risk 依表序的【一頁】（序列、一次只一頁、不並行、不吞整批）。
   b. spawn 獨立 sub-agent 跑 qa-codex-dispatch.md（填 funcId）→ 依 qa-cases 產【三層測試】：
      DB（Testcontainers gvenzl/oracle-xe 自 seed→DB 斷言）／BE（epl-* + response/DB 斷言、強制點繞 FE negative）／
      FE（Playwright e2e：form/dialog/i18n/角色分支，selector 依 Adobe XD）。@PENDING case→@Disabled skeleton。
   c. 跑測試 + 機械閘門（blocking）：④ QA 驗收＝三層測試綠；⑤ 覆蓋率＝check-srs-bundle gate⑤ exit 0。
   d. QA 軸（§4d Q1–Q5，跨模型、各 read-only）：覆蓋完整性/oracle 真確/三層齊備/環境隔離/報告忠實
      → 採納修正後再審一輪。每軸 {提出/真/誤報} 回填 n-axis-findings-ledger（stage=QA）。
   e. 產【測試報告清單】（qa-report-format：逐案 PASS/FAIL/SKIP+證據 + Rollup 數據）。
   f. 達標（④⑤ 綠 + QA 軸無 Blocker + 報告產出）→ ledger status=qa-passed、填 report 路徑 → 回 1a。
   g. 紅燈分類（不自決 spec）：impl-gap→該頁回 RD（status=rd-ready 重排）／oracle-spec 錯→回 SRS（標、
      不自改 spec）／測試環境問題→status=blocked。
   h. ⚠️ T1 頁（金錢/評分/授權；撥貸、c0 評分線）＝per-page checkpoint：報告產完即停交 owner 審，
      不自動接下一頁、不併批末。

2. 守則：序列非並行；每頁全程過 gate＋QA 軸不跳；終點＝qa-passed，【不得自宣 Done】（owner 審報告才升 done）；
   不得改 oracle/spec 遷就實作；不碰 C 類；context 衛生＝每 sub-task 獨立 session、主控只收 PASS/FAIL/路徑；
   不中途改 ledger 排序。

2b. 🛑 circuit-breaker：系統性/重複失敗（同類測試紅連續多頁、共同環境缺陷如容器拉不動/DB 不可達）→
    暫停整批、回報、修根因再重啟。

3. 停點＝ledger 無 qa-ready（皆 qa-passed 或 blocked/回流）＝batch checkpoint。彙總每頁一行
   （qa-passed + Rollup 數據 / blocked=因 / 回 RD=impl-gap / 回 SRS=oracle-spec）+ report 路徑，整批交 owner 審報告。
```

---

## 步驟 1b — Context Window 管理
- **上限**：主控只存 ledger 行 + 當頁 sub-agent 的 PASS/Blocker + report 路徑 + Rollup 一行；不吞測試碼/log 全文；一頁回填即丟細節；接近上限停、輸出 ledger、resume 冪等。
- **下限**：每 sub-agent 自讀原檔（qa-cases + bundle 四檔 + 產品碼 endpoint + Adobe XD selector + 軸 brief），不吃摘要。

## 步驟 2 — batch checkpoint（人）
- 全批停後 owner 逐頁審【測試報告清單】；T1 頁已在 1h 單頁審。
- `qa-passed` 頁 + 報告無剩餘高風險 → owner 蓋 `done`（orchestrator 不自升）。
- 回流頁：impl-gap→RD 修（重標 rd-ready）；oracle-spec→SRS 修（人裁、重產 qa-cases 後重 qa-ready）；env→修環境重 qa-ready。
- 回填 STATUS / feature-inventory / ledger（report 路徑、覆蓋計數、測試通過數）。

### 首批放量（漸進）
- **首次跑先單頁**＝00118（spec+impl 已完成，唯一能立刻試 QA flow 的頁）：跑通「qa-cases→三層→報告」驗 QA flow + 報告格式 + Playwright harness，再批量。
- 首批 ≤5 頁同 risk-tier；T1 ≤3 頁/批。不為吞吐降軸。

---

## 守則速查（QA drain）
| 項 | 值 |
|---|---|
| 並行? | ❌ 序列一次一頁（context 衛生） |
| 每頁測什麼? | **三層**：DB(Testcontainers)＋BE(epl-*)＋FE(Playwright)；強制點決定哪層 |
| 每頁 gate+軸? | ✅ DoD ④QA驗收 ⑤覆蓋率 + QA 軸（§4d Q1–Q5 跨模型）；採納修正後再審一輪 |
| 產物 | 測試報告清單（qa-report-format：逐案 + Rollup 數據） |
| 自動到哪? | `qa-passed`（**不自宣 Done**，owner 審報告才 done） |
| 停點 | 低風險頁批末；T1 頁每頁停（per-page checkpoint） |
| 紅燈 | impl-gap→回 RD／oracle-spec→回 SRS（不自改）／env→blocked |
| 系統性失敗 | 🛑 circuit-breaker 暫停整批 |
| C 類 / 改 oracle 遷就實作 | ❌ 不碰、不改 |

> 卡歸檔 `done/`：本批 drain 跑完、回填完成後移。
