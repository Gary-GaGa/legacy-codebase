# RD orchestrator — drain 啟動卡（SRS Approved → code 批量）

> **用途**：把 `approved→rd-ready` 的頁批量 drain 成 code。owner 標多頁 `rd-ready`，orchestrator **序列一次一頁**逐頁產 code，drain 到所有 `rd-ready`→`rd-done` 才停。
> **迴圈權威＝`docs/process/orchestration-playbook.md §5c/§6c`**（本卡＝可貼運行殼，內容權威在 playbook）；殼 ↔ 權威迴圈不變式由 `python scripts/check-prompt-parity.py` 機械驗（anchor 漏一邊＝FAIL）。
> **單頁實作 prompt＝`rd-codex-dispatch.md`**（orchestrator 逐頁套它）。
> **在哪跑**：母資料夾 Codex（產品碼可寫 + db-diff/refactor-spec 在）。本 planning repo 跑不了。

---

## 步驟 0 — owner 前置（放行進開發）
1. 該頁 SRS 必須 `Status: 規格定版 Approved`（N 軸無 Blocker、@PENDING 全裁）——**RD 入口閘**。
2. 在 ledger（`refactor-audit/per-page-reinventory-matrix.md`）把要這批開發的頁 status 由 `approved` 改 `rd-ready`。
3. **owner 控放量、orchestrator 控 drain**：標多少 `rd-ready` 就 drain 多少；未 approved 的頁不可標。

---

## 步驟 1 — 貼這段給母資料夾 Codex（drain orchestrator）

```
你是 RD orchestrator（drain 模式）。任務板＝per-page-reinventory-matrix ledger。權威迴圈＝
orchestration-playbook §5c/§6c、§4c（RD 軸）。

0. 入口閘：只取 status=rd-ready 且其 SRS status=規格定版 Approved（N軸無Blocker、@PENDING全裁）。
   非 approved 衍生的 rd-ready→拒、回報、不動工。

1. DRAIN 迴圈——只要 ledger 還有 status=rd-ready（可多頁）就繼續：
   a. 取 risk-tier 最前、同 risk 依表序的【一頁】（序列、一次只一頁、不並行、不吞整批）。
   b. spawn 獨立 sub-agent 跑 rd-codex-dispatch.md 的單頁 prompt（填 funcId）→ 產 code 到產品 repo。
   c. DoD 機械閘門（blocking）：① 契約 openapi 對齊 ② schema entity↔DB ③ verify-c0.py --git exit 0
      ⑥ build：mvn + ng build exit 0。（④⑤ 在 rd-done 後的 DoD 閘門牆跑。）
   d. RD 軸（§4c，跨模型、advisory）：spawn verifier-contract/scope/regression/enforcement（強制點
      落實：BE 權威 enforce、mutating 非 FE-only、決策欄 client 不可送）各一隻 read-only、獨立
      session、不同指示 → 採納修正後再審一輪。
   e. 達標（①②③⑥ 綠 + RD 軸無 Blocker）→ ledger status=rd-done、填 code 路徑（commit/PR）→ 回 1a。
   f. 未達標（build 紅 / verify-c0 違規 / 軸 Blocker 需 C 類）→ status=blocked+原因（離開 rd-ready
      集合→不重取）→ 續下一頁（單頁失敗不擋整批）。
   g. ⚠️ T1 頁（金錢/評分/授權；撥貸 0920/0921/0922+T24、c0 評分線）＝**per-page 多 agent 驗證點**
      （owner 改自「per-page 人審停點」）：code 產完 → spawn RD 軸（§4c）≥4 隻跨模型
      read-only 驗 → Blocker 則修該頁再驗 → 無 Blocker 即 rd-done、**drain 不停人、續下一頁**。
      不逐頁停人審；correlated-blindness 防護由 per-page 多 agent 跨模型驗承載；人審＝step 2 批末 + owner Done。

2. 守則：序列非並行；每頁全程過 gate＋RD 軸不跳；終點＝rd-done，【不得自宣 Done】（QA 還沒跑）；
   不得碰 C 類（風險/架構/domain）；不改既有 i0/Csu*；context 衛生＝每 sub-task 獨立 session、
   主控只收 PASS/FAIL/路徑；不中途改 ledger 排序。

2b. 🛑 circuit-breaker：系統性/重複失敗（同類 build/驗證錯連續多頁、共同 local 輸入缺陷）→
    暫停整批、回報、修根因再重啟。

3. 停點＝ledger 無 rd-ready（皆 rd-done 或 blocked）＝batch checkpoint。彙總每頁一行（rd-done /
   blocked=因）+ code 路徑，整批交人審。
```

---

## 步驟 1b — Context Window 管理
- **上限**：主控只存 ledger 行 + 當頁 sub-agent 的 PASS/Blocker(file:line)+code 路徑；不吞 diff/transcript 全文；一頁回填即丟細節（跨頁不累積）；接近上限停、輸出 ledger、resume 冪等下批接。
- **下限**：每 sub-agent 自讀原檔（SRS bundle 三檔 + 該頁產品碼 + db-diff/refactor-spec file:line + 軸 brief），不吃摘要。

## 步驟 2 — batch checkpoint（人）
- 全批停 `rd-done` 後 **先 spawn 批次多 agent 驗證**（跨頁一致性 + 跨批 regression + RD 軸對合併 diff，跨模型 read-only）→ 再逐頁人審 diff（T1 頁已在 1g per-page 多 agent 驗過）。
- `rd-done` 頁 → 進 DoD 閘門牆（①②③⑥⑦LLM審 + 人審；**④⑤ QA 暫拔除**）→ owner 蓋 `done`。
- `blocked` 頁：build/驗證可修者回母資料夾修、C 類進 pending-register 裁 → 修/裁後重標 `rd-ready`。
- 回填 STATUS / feature-inventory / ledger（code 路徑、覆蓋計數）。

### 首批放量（漸進）
- **首次跑先單頁**（殼只取一頁）驗四守則（不自宣 Done/不碰 C 類/不改既有 i0/軸真獨立）再批量。
- 首批 ≤5 頁同 risk-tier；T1 ≤3 頁/批；最高風險頁（撥貸金錢、c0）單跑。不為吞吐降軸。

---

## 守則速查（RD drain）
| 項 | 值 |
|---|---|
| 並行? | ❌ 序列一次一頁（context 衛生） |
| 每頁 gate+軸? | ✅ DoD ①②③⑥ + RD 軸（§4c，跨模型、advisory）；採納修正後再審一輪 |
| 自動到哪? | `rd-done`（**不自宣 Done**） |
| 停點 | 人審＝批末（batch checkpoint，含批次多 agent 驗證）；T1 頁每頁＝多 agent 驗證（drain 不停人）|
| 單頁 FAIL | 標因→`status=blocked`（離開 rd-ready）、續下一頁 |
| 系統性失敗 | 🛑 circuit-breaker 暫停整批、修根因 |
| C 類 / 既有 i0 | ❌ 不碰、不改 |

> 卡歸檔 `done/`：本批 drain 跑完、回填完成後移。
