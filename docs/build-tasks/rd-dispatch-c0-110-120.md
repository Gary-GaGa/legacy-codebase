# RD 開發派工卡 — 企金評分 9 包（EPROC00110–00120，一起開發）

> **狀態**：9 包 SRS **全數規格定版 Approved**（13/67 之企金評分線；2026-06-24/25 owner-stamped、axis A–F 獨立再審 0 Blocker）。本卡＝**批次 RD 派工殼**，給母資料夾 Codex 一次帶 9 包進開發 → 各過 DoD 機械閘門 + RD 軸 → `rd-done` → DoD 閘門牆 → owner 蓋 Done。
> **權威**：單頁實作單元＝`rd-codex-dispatch.md`（複製其 prompt、填 funcId）；批量迴圈＝`rd-orchestrator-drain.md` / `orchestration-playbook §5c/§6c`；RD 軸＝`§4c`；實作鐵則＝`backend/AGENTS.md`＋`frontend/AGENTS.md`；鏡像/禁樣式＝`scripts/verify-c0.py`。
> **在哪跑**：母資料夾 Codex（產品碼可寫 + 規劃 repo 可讀 + local `docs/db-diff/`/`docs/refactor-spec/`）。本規劃 repo 無原始碼、跑不了。
> **本卡只派 RD 開發**；spec.md 兩半翻新＝**獨立一輪**（不在本卡，見 plan）。

## 9 包清單（全 Approved；皆 T1 金錢/評分/授權 → per-page 停人審）
| funcId | 名稱 | 備註（實作要點，照 to-be 契約非 legacy as-is） |
|---|---|---|
| EPROC00110 | 評分容器 credit-investigation | R9 checkpoint 四併二互斥；BE 驅動動態 tab |
| EPROC00112 | CBC Banking Relationship | Bible RBAC tuple 403 |
| EPROC00114 | Collateral Assessment | — |
| EPROC00115 | Borrower Group Exposure | RP20 **雙層授權**（DB seed + service guard）；第三幣別只收 USD/KHR；報表幣別修正（REF-D3）；殘留 🟡（COMMON_MSG_LIMIT/legacyFunctionId/BR-001 碼綁）見 pending-register、非阻擋 |
| EPROC00116 | Financial Statement GI | R7 FE-blocks + to-be BE hardening；BR-016 KHR no-decimal |
| EPROC00117 | Financial Evaluation GI | SaveRequest DSR 金額欄 + fixed USD；INFO/INFO_CORP reconcile |
| EPROC00118 | Corporate Scorecard | TB_API_AUTH 四列、save guard、parseScore fail-fast、UTC+8、numeric guard（contract closeout 已定） |
| EPROC00119 | Financial Statement FI | **code-as-baseline @`3dfebcf`**；3 條 Finished gate＝RP43(END_BALANCE==CASH_AND_CASH_EQU) + DIFFERENCE!=0(E120) + 第一年度零(E119)，**全 BE 權威**；RD 註：回 backend 核 E119/E120 訊息碼方向勿標反 |
| EPROC00120 | Financial Evaluation FI | **code-as-baseline @`2ae96d0`**；P-011 雙層授權；P-012 parent checkpoint 走獨立 endpoint（本頁 DTO 不膨脹、R1/R19 保留本頁 applicationName/checkpoint）；P-013 rounding HALF_DOWN；P-005 Finished 必填＝PRD 5.3.1 人工欄；殘留 🟡（openapi 兩 row schema 重複）非阻擋 |

## 入口閘（全數已過）
- 9 包 spec.md `Status: 規格定版 Approved` ✅（N 軸無 Blocker、@PENDING 全 owner 裁）。
- ledger 將 9 頁 status 設 `rd-ready`（owner 放行進開發）。
- bundle＝三檔（spec/openapi/schema；qa-cases QA 暫拔除）；**openapi＝契約唯一真相**。

## 批次執行（drain，序列一次一頁）
1. 對每個 funcId 複製 `rd-codex-dispatch.md` 的 prompt、填 funcId，照其【入口閘】【權威工作流】【分流】【拆工(依強制點)】【不可做】跑。
2. **brownfield 主路徑＝對位驗碼**（非從零）：每條 Rn ↔ 實作 method:line 三面比對（spec / openapi / 實作）→ drift 分 regression(修回) vs 刻意演進(keep+理由，三判)；附新舊雙方 file:line。
3. **強制點為拆工主軸**：逐 Rn 看 FE/BE/both 拆子任務；**完整性/安全驗證 BE 必為權威**（FE 同款＝UX、永不信前端）；標「後端為準」決策欄，request 契約不得讓 client 送。
4. **code-as-baseline 包（119/120）**：實作 to-be delta（REF-Dn/DEC），**不可重新引入 legacy bug**；as-is 證據釘 `@SHA`。
5. **T1 per-page 停人審**：9 包全 T1（金錢/評分/授權）→ 每頁達標後**停、交人審**，不自動接下一頁。

## DoD 機械閘門（blocking，全綠才 rd-done）
①契約（openapi snapshot FE↔BE 對齊）②schema（entity↔DB 型別長度）③verify-c0（`python scripts/verify-c0.py --git` exit 0：鏡像/禁樣式/只新增）⑥build（mvn + ng build 各 exit 0）。
〔**④QA驗收 ⑤覆蓋率 隨 QA 2026-06-24 暫拔除**。〕

## RD 軸（§4c；advisory、跨模型、各 read-only）
verifier-contract（契約對齊）／verifier-scope（commit 範圍、誤動 OUT）／verifier-regression（舊系統/i0 偏離、reflection）／verifier-enforcement（強制點真落地：BE 權威 enforce、mutating 非 FE-only、決策欄 client 不可送）。各回 PASS/Blocker(file:line) → 採納修正後**再審一輪**。

## 不可做 / 邊界
- 不改既有 i0/個金頁（`/individual/`）、不改既有 `Csu*.java`（除非該 funcId 就是它）。
- 不臆造 file:line；未證標「待核對」。**不自宣 Done**（終點＝rd-done）。
- 不碰 C 類（風險/架構/domain 裁定）→ 回報不自決。
- **企金線老系統 parity 補比**（pending-register:26、18 頁含本 9 包）＝**獨立下游軌**，**不阻** RD 依 Approved SRS 契約開發；parity delta 另由 `c0-legacy-parity-recheck` 軌處理。

## 回填 + 終點
- 達標（①②③⑥ 綠 + RD 軸無 Blocker）→ ledger 該頁 `rd-done` + 填 code commit/PR；一頁一 commit。
- terminal＝rd-done → DoD 閘門牆（①②③⑥⑦LLM審 + 人審；④⑤ QA 暫拔除）→ owner 蓋 Done。
- 回報格式照 `rd-codex-dispatch.md`【回報格式】（funcId + commit + BE/FE 檔 + DoD exit + RD 軸逐行 + ledger diff + 待 C 類彙總 + 四守則一句）。
- 卡歸檔 `done/`：9 包 drain 跑完、回填完成後移。
