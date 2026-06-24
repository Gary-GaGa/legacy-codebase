# PRD→SRS orchestrator — drain 啟動卡（批量；pilot 已過）

> **用途**：pilot（已歸檔 `done/prd-to-srs-orchestrator-pilot.md`）已過（`EPROZ00100`/`EPROC00118`→Approved）後的**批量 drain 運行卡**。一次標多頁 `prd-ready`，orchestrator **序列一次一頁**逐頁產 SRS，**drain 到所有既有 `prd-ready` 都 → `in-review`** 才停。
> **迴圈權威＝`docs/process/orchestration-playbook.md §5b/§6b`**（本卡＝可貼運行殼，內容權威在 playbook，勿在他處改語意）；殼 ↔ 權威的迴圈不變式由 `python scripts/check-prompt-parity.py` 機械驗（anchor 漏在一邊＝FAIL）。
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
   d. SRS N 軸驗證（playbook §4b 全 A–F，**pilot 同級、不因批量降軸**）：**每頁一律跑全 A–F 七軸**；**每軸各 spawn 一隻 read-only、獨立 session、不同指示、跨模型 sub-agent**（A 綜合/B as-is parity/C 錯誤碼/D 安全授權/E DB reconcile/F 金錢精度截斷/G 可測試性，brief=§4b 表「只看」欄）。軸多時可叢集成 **≥3 隻**（如 A+B｜C+D+E｜F+G），但每隻仍獨立 session、跨模型——**同質多隻＝theater 不算**。各軸回 PASS/Blocker(file:line) → **採納修正後再跑受影響軸一輪**。〔不再「低風險頁減軸」；F/D 綁欄位不可省。〕**每軸把 {提出 Blocker／確認為真／誤報} append 進 docs/process/n-axis-findings-ledger.md §1**（含再審輪；度量驅動軸配置，playbook §4b）。
   e. 達標（exit 0 + N 軸無 Blocker）→ 回填該頁 ledger status=in-review、填 srs 路徑（覆蓋計數由此衍生）→ 回 1a 取下一個 prd-ready。
   f. 未達標（gate FAIL / N 軸殘 Blocker 需 C 類裁定）→ 該頁 **status=blocked**+原因（**離開 prd-ready 集合→下輪不會被重取**；嚴禁留 prd-ready，否則同頁被無限重取）→ 回 1a 續跑下一頁（單頁失敗不擋整批）。
   g. ⚠️ **T1/金錢/授權頁＝per-page checkpoint**（2026-06-22；撥貸 0920/0921/0922+T24、c0 評分線）：該頁達標後**停下交人審**（全 A–F 跨模型 + 人審 + 採納修正再審一輪），**不自動接下一頁**（不併批末）；只有低風險頁才走 1e 續 drain + 批末 checkpoint。**最高風險頁（撥貸金錢、c0）用單跑**、不入長 drain 佇列。**T1 批量硬上限 ≤3 頁/批**。理由＝pilot 單跑/每頁人審抓到機械閘門看不到的金錢/授權 Blocker（`done/EPROZ00100-regenerate-pilot.md:43`、`EPROZ00100-EPROC00118-nfix-card.md`）。

2. 守則（不得違反）：序列非並行；每頁全程過 gate＋N 軸、不跳；終點＝in-review，【不得自宣 approved】（TBD 全關+人裁才 approved）；不得碰 C 類（裁 TBD/風險/架構/domain），只標 @PENDING；context 衛生＝每 sub-task 獨立 session、主控只收 PASS/FAIL/findings 路徑；**不中途改 ledger 排序**（要調序先停批再重啟）。

2b. 🛑 circuit-breaker：偵測**系統性/重複**失敗——同一 N 軸在連續多頁出同類 Blocker、或多頁共同 local 輸入缺陷（如 docs/db-diff 版本舊、reconcile 範本缺）——**暫停整批 drain、回報、不續跑**，等修根因再重啟（別把同一個錯複製到整批）。

2c. Context Window（上下限，批量必守）：
   - **上限（防爆/跨頁不累積）**：主控 context **只留**＝佇列 ledger（逐頁一行 status/srs）＋當前頁各 sub-agent 回的「PASS/Blocker(file:line) 一行＋findings 檔路徑」。**絕不**把 bundle 全文/PRD 全文/sub-agent transcript 貼進主控。**一頁回填 ledger 後即丟棄該頁細節**，下一頁從乾淨 context 起。接近 context 上限 → 停在當前頁完成處、輸出 ledger、靠 resume 冪等下批接續（別硬撐到爆）。
   - **下限（防空審/每隻吃飽）**：每隻 sub-agent **自己讀原檔**拿足量上下文＝該頁 PRD＋SRS bundle 三檔＋對應 db-diff/refactor-spec/legacy `file:line`＋該軸 §4b brief；**不可餵摘要代替原文**（摘要＝空審）。產 SRS 的 sub-agent 也要吃到 §5 reconcile 來源，不足則顯式 disclaim「待母資料夾複核」、不靜默。每隻單一職責、範圍小到能在自己 context 內窮舉。
   - sub-agent 間**不共享 context**（各自獨立 session）；主控不轉貼 A 軸輸出給 B 軸。

3. 停點＝ledger 已無 prd-ready（皆 in-review 或 blocked）才停＝batch checkpoint。彙總回報：每頁一行（in-review / blocked=gate-fail 或 待裁 C 類）+ bundle/findings 路徑，整批一起交人審/裁 TBD。
```

---

## 步驟 1b — Context Window 管理（為何批量 × 全 A–F 不會爆）
> 「批次多頁」×「每頁全 A–F 多 sub-agent」會放大 context；靠**隔離 + 壓縮 + 分批**控在上下限內,品質不打折。

| 維度 | 上限（防爆） | 下限（防空審） |
|---|---|---|
| **主控 orchestrator** | 只存 ledger 行 + 當頁 sub-agent 的 PASS/Blocker(file:line)+findings 路徑；不吞 bundle/PRD/transcript 全文 | 保有佇列 ledger 全貌（知道還有哪些頁、排序） |
| **每頁** | 回填 ledger 後**丟棄該頁細節**→ 跨頁不累積 | 該頁的 sub-agent 各拿到完整一頁材料 |
| **sub-agent** | 各自獨立 session、不共享、只回精簡 verdict | **自己讀原檔**（PRD+bundle 三檔+db-diff/refactor-spec/legacy file:line+軸 brief）、不吃摘要 |
| **批量** | 單批頁數上限（低風險 ≤5、T1 ≤3）；接近 context 上限即停、輸出 ledger | 長佇列分多批、**resume 冪等**（§5b）接續，不漏頁 |

- **隔離**：每隻 sub-agent 的 context 不計入主控 → 全 A–F × 多頁的 token 重擔落在「用完即拋」的子 session,不堆在主控。
- **壓縮**：每頁終態只壓成 ledger 一行（status/srs/blocker 因）；主控隨時可在「已完成頁=ledger、未完成頁=prd-ready」的乾淨狀態重入。
- **分批**：owner 放量 + 單批上限雙重節流;一批爆不了就靠 resume 接下一批（中斷安全）。

## 步驟 2 — batch checkpoint（人）
- 全批停在 `in-review` 後，逐頁人審 + 裁 open `@PENDING`/TBD（C 類 owner/RD/DBA/domain）。
- TBD 全關 + N 軸無 Blocker → 人把該頁 ledger 升 `approved`（orchestrator 不自升）。
- `blocked` 頁：看是 gate/N 軸可修（回 owner 母資料夾修）還是 C 類待裁（進 `pending-register`）→ 修/裁後**重標 `prd-ready`** 進下一批重跑（blocked 不會自動重試）。
- 回填 `STATUS §一/§二`、`feature-inventory §5 Phase S`、覆蓋計數（ledger `in-review`/`approved` 涵蓋頁數 / 67）。

### 首批放量（漸進，別一次全放）
- **首次跑先單頁**（規模化前驗四守則）：drain 殼**只取一頁**、跑通 gate＋N 軸＋ledger 回填、停人審，確認「停等審／不自宣 approved／不碰 C 類／N 軸真獨立」四條守得住，再開批量。（原 pilot 卡已歸檔 `done/prd-to-srs-orchestrator-pilot.md`。）
- **首次批量建議 ≤5 頁、同 risk-tier**（低風險先）；證實人審 + N 軸跟得上、circuit-breaker 沒被觸發，再擴大批量。
- **禁止為衝吞吐而降 N 軸**：**每頁一律全 A–F、多 sub-agent、跨模型（drain 對齊 pilot 品質，2026-06-22 起不再低風險減軸）**；T1 另加 per-page checkpoint。
- owner 一次標的 `prd-ready` 數＝該批 drain 範圍——**owner 即放量節流閥**（標少＝小批）。

---

## 守則速查（drain 與 pilot 共用）
| 項 | 值 |
|---|---|
| 並行? | ❌ 序列一次一頁（context 衛生） |
| 每頁 gate+N 軸? | ✅ 全程不跳；**N 軸＝全 A–F、每軸一隻 sub-agent（可叢集 ≥3）、跨模型、獨立 session（pilot 同級，不降軸）；採納修正後再審一輪** |
| N 軸度量 | 每軸 {提出/真/誤報} 回填 `docs/process/n-axis-findings-ledger.md`；≥10 頁(T1 ≥5)後用實測調軸 profile（playbook §4b） |
| Context Window | 主控只存 ledger+當頁 PASS/Blocker 路徑、每頁完丟細節；sub-agent 獨立 session 自讀原檔（不吃摘要）；批量上限（低風險≤5/T1≤3）、長佇列分批 resume 冪等 |
| 自動到哪? | `in-review`（**不自升 approved**） |
| 停點 | 低風險頁＝整批清空後一次（batch checkpoint）；**T1/金錢/授權頁＝每頁停（per-page checkpoint），不併批末** |
| 單頁 FAIL | 標因→**status=blocked**（離開 prd-ready，防無限重取）、續跑下一頁 |
| 首批放量 | 低風險 ≤5 頁同 risk-tier 漸進；**T1 ≤3 頁/批硬上限**；最高風險頁（撥貸金錢/c0）單跑；不為吞吐降 N 軸 |
| 系統性/重複失敗 | 🛑 暫停整批、回報、修根因再重啟 |
| C 類（裁定/風險/架構/domain） | ❌ 不碰，只標 @PENDING |

> 卡歸檔 `done/`：本批 drain 跑完、回填完成後移。
