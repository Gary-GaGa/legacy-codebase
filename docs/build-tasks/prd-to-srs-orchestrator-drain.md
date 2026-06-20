# PRD→SRS orchestrator — drain 啟動卡（批量；pilot 已過）

> **用途**：pilot（`prd-to-srs-orchestrator-pilot.md`）已過（`EPROZ00100`/`EPROC00118`→Approved）後的**批量 drain 運行卡**。一次標多頁 `prd-ready`，orchestrator **序列一次一頁**逐頁產 SRS，**drain 到所有既有 `prd-ready` 都 → `in-review`** 才停。
> **迴圈權威＝`docs/process/orchestration-playbook.md §5b/§6b`**（本卡＝可貼運行殼，內容權威在 playbook，勿在他處改語意）。
> **單頁轉換 prompt＝`prd-to-srs-codex-dispatch.md`**（orchestrator 逐頁套它）。
> **在哪跑**：母資料夾 Codex（產品碼 + 規劃 repo 可寫 + local `docs/db-diff/`+`docs/refactor-spec/` 在）。本 remote planning repo 無原始碼、跑不了。

---

## 步驟 0 — owner 前置（放 PRD + 標 prd-ready）
1. 把要這批處理的頁 PRD 放進 `docs/specs/prd/`，檔名 `PRD-*<funcId>*.md`（一頁一 PRD、funcId 不重複；rename 腳本 `scripts/rename-prd.ps1`）。
2. 在 matrix ledger（`build-tasks/refactor-audit/per-page-reinventory-matrix.md`）把**這些頁**的列 `status` 改 `prd-ready`＋填 `prd` 欄。
   - **佔位列（多 funcId，如「主流程 ISU/i0/z0 增量」）不可直接標** → 先**拆成一 funcId 一列**再標（守「一頁一列」）。
   - 企金線 18 頁：`prd-ready` 前**須先有 `c0-legacy-parity-recheck` 碼驗 findings**（`done/c0-legacy-parity-recheck-T*-findings.md`）餵 as-is 軸，否則 SRS 漏載對舊 cs/cu 差異。
3. （可選）orchestrator 步驟 0 會自動對帳「PRD 實檔 ⟷ ledger」，實檔有而仍 not-started 者會回報「待標 prd-ready」——可靠它兜底防漏。

> **drain 範圍＝owner 標了多少 `prd-ready`**：owner 控放量、orchestrator 把該批 drain 到 `in-review`。沒標的頁不碰。

---

## 步驟 1 — 貼這段給母資料夾 Codex（drain orchestrator）

```
你是 SRS orchestrator（drain 模式）。任務板＝docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md 的「PRD→SRS 佇列 + ledger」表。權威迴圈＝docs/process/orchestration-playbook.md §5b/§6b、§4b（N 軸）。

0. 起手對帳：列 docs/specs/prd/PRD-*.md 實檔 ⟷ ledger prd 欄。實檔有但表列 not-started→回報「PRD 已放、待標 prd-ready」並先停（不自行標、不臆造）。bundle/佔位列（多 funcId）不可 pick。

1. DRAIN 迴圈——只要 ledger 還有 status=prd-ready 列（可多頁）就繼續：
   a. 取 risk-tier 最前、同 risk 依表序的【一頁】（序列、一次只一頁、不並行、不一次吞整批）。
   b. spawn 獨立 sub-agent 跑 docs/build-tasks/prd-to-srs-codex-dispatch.md 的單頁 prompt（填該 funcId / PRD 路徑）→ 產 bundle 到 docs/specs/srs/<funcId>/。
   c. 機械 gate：python scripts/check-srs-bundle.py docs/specs/srs/<funcId> 必 exit 0（含 gateⓇ reconcile）。
   d. SRS N 軸驗證（playbook §4b 的 A–G）：各 spawn 一 read-only sub-agent、獨立 session、不同指示、最好跨模型（risk-tier T1 全 A–G；低風險頁可 A+E+G）→ 採納修正後【再審一輪】。
   e. 達標（exit 0 + N 軸無 Blocker）→ 回填該頁 ledger status=in-review、填 srs 路徑（覆蓋計數由此衍生）→ 回 1a 取下一個 prd-ready。
   f. 未達標（gate FAIL / N 軸殘 Blocker 需 C 類裁定）→ 該頁標 FAIL/blocked+原因、status 留 prd-ready（不誤升）→ 回 1a 續跑下一頁（單頁失敗不擋整批）。

2. 守則（不得違反）：序列非並行；每頁全程過 gate＋N 軸、不跳；終點＝in-review，【不得自宣 approved】（TBD 全關+人裁才 approved）；不得碰 C 類（裁 TBD/風險/架構/domain），只標 @PENDING；context 衛生＝每 sub-task 獨立 session、主控只收 PASS/FAIL/findings 路徑。

3. 停點＝ledger 的 prd-ready 全清（皆 in-review 或 FAIL/blocked）才停＝batch checkpoint。彙總回報：每頁一行（in-review / FAIL+原因 / blocked=待裁）+ bundle/findings 路徑，整批一起交人審/裁 TBD。
```

---

## 步驟 2 — batch checkpoint（人）
- 全批停在 `in-review` 後，逐頁人審 + 裁 open `@PENDING`/TBD（C 類 owner/RD/DBA/domain）。
- TBD 全關 + N 軸無 Blocker → 人把該頁 ledger 升 `approved`（orchestrator 不自升）。
- FAIL/blocked 頁：看是 gate/N 軸可修（回 owner 母資料夾修→重跑該頁）還是 C 類待裁（進 `pending-register`）。
- 回填 `STATUS §一/§二`、`feature-inventory §5 Phase S`、覆蓋計數（ledger `in-review`/`approved` 涵蓋頁數 / 67）。

---

## 守則速查（drain 與 pilot 共用）
| 項 | 值 |
|---|---|
| 並行? | ❌ 序列一次一頁（context 衛生） |
| 每頁 gate+N 軸? | ✅ 全程，不跳 |
| 自動到哪? | `in-review`（**不自升 approved**） |
| 停點 | 整批 prd-ready 清空後一次（batch checkpoint） |
| 單頁 FAIL | 標因、留 prd-ready、續跑下一頁 |
| C 類（裁定/風險/架構/domain） | ❌ 不碰，只標 @PENDING |

> 卡歸檔 `done/`：本批 drain 跑完、回填完成後移。
