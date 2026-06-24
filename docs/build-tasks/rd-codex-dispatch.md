# RD dispatch prompt（給 Codex；SRS Approved → code）

> **用法**：母資料夾（產品碼可寫 + 規劃 repo 可讀 + local `docs/db-diff/`/`docs/refactor-spec/`）開 Codex。下方 prompt＝**單頁實作單元**（填 `<funcId>`）；接 SRS bundle → 產 code → 過 DoD 機械閘門 → RD 軸 → 回填 ledger。
> **批量＝drain**：規模化由 RD orchestrator（`orchestration-playbook §5c/§6c`）驅動——序列逐頁套本 prompt，drain 到所有 `rd-ready`→`rd-done`。本 prompt 本身不變、仍單頁。
> **權威**：迴圈＝`orchestration-playbook §5c`；RD 軸＝`§4c`；實作鐵則＝`backend/AGENTS.md`／`frontend/AGENTS.md`；鏡像/禁樣式＝`scripts/verify-c0.py`。
> **在哪跑**：母資料夾 Codex（本 remote planning repo 無原始碼、跑不了）。

## 入口閘（不過不收）
- 該 funcId SRS `Status: 規格定版 Approved`（N 軸無 Blocker、@PENDING **全 owner 裁**）。
- 非 Approved（仍 In Review / 殘 @PENDING）→ **拒收、回報「待 SRS Approved」**，不臆造實作。
- ledger 該頁 status=`rd-ready`（owner 已放行進開發）。

## SRS bundle = 唯一實作輸入
| 檔 | 角色 |
|---|---|
| `docs/specs/srs/<funcId>/spec.md` | 業務規則 Rn + **強制點 FE/BE/both** + as-is✅⚠️🔴/to-be + delta |
| `docs/specs/srs/<funcId>/openapi.yaml` | **契約鎖**＝唯一真相（epl-* request/response、method） |
| `docs/specs/srs/<funcId>/schema.sql` | 表/欄 DDL（型別/長度/PK/nullable） |
| ~~`qa-cases.md`~~ | **QA 2026-06-24 暫拔除**：bundle 無此檔（三檔制）；DoD gate④驗收/⑤覆蓋率 隨之暫停。 |

---

## ⬇️ 複製以下給 Codex（一次一頁）

```
任務：把 SRS bundle（funcId <funcId>，Status=Approved）實作成 code（RD-Agent，how→code）。
brownfield 主路徑＝對位驗碼（非從零寫）；產品碼在母資料夾。

【入口閘】先確認 docs/specs/srs/<funcId>/spec.md 的 Status＝規格定版 Approved、N 軸無
Blocker、@PENDING 全裁。否則停、回報「待 SRS Approved」，不動工。

【權威工作流】讀 backend/AGENTS.md + frontend/AGENTS.md 的實作鐵則全照做；c0 鏡像/禁樣式
依 scripts/verify-c0.py 規則（無 reflection/委派、只新增不改既有 i0、c0 不呼叫 i0 endpoint、
checkpoint 用 Cs/Cu 非 Is/Iu、endpoint -c0- 非 -i0-）。

【分流】
- 有 migrated/refactor code（brownfield 主路徑）→ as-is 第二次驗證：對位每條 Rn ↔ 實作
  method:line，三面比對（spec / openapi 契約 / 實作）→ 標 drift；drift 分 regression（修回）
  vs 刻意演進（keep + 理由，依 legacy-parity-sop 三判）。每差異附【新舊雙方 file:line】。
- 無 code（greenfield）→ 先唯讀盤點舊鏈路 + 出實作計畫 → 停等人審，不直接寫。

【拆工（依強制點）】
- 逐 Rn 看強制點 FE/BE/both，拆 BE / FE 子任務，各獨立 session。
- openapi.yaml = 契約唯一真相：DTO 欄位/型別/method 對齊它（非對 i0 DTO、非自由發揮）。
- 完整性/安全的驗證：BE 必須有且為權威；FE 同款只是 UX（永不信前端）。標「後端為準」的
  決策欄，request 契約不得讓 client 送。
- schema 對齊 bundle schema.sql 的型別/長度/PK/nullable；金錢欄精度照 schema、不 silent 截斷。

【不可做】
- 不改既有 i0/個金頁（路徑含 /individual/）、不改既有 Csu*.java（除非該 funcId 就是它）。
- 不臆造 file:line；未證標「待核對」。不自宣 Done。
- 不碰 C 類（風險/架構/domain 裁定）——遇到回報，不自決。

【過 DoD 機械閘門（blocking，全綠才算 rd-done）】
1. ① 契約：openapi snapshot 對齊（FE↔BE DTO/method 一致）。
2. ② schema：entity ↔ DB（型別長度）。
3. ③ verify-c0：python scripts/verify-c0.py --git exit 0（鏡像/禁樣式/只新增）。
4. ⑥ build：mvn（BE）、ng build（FE）各 exit 0。
（④QA驗收 ⑤覆蓋率 隨 QA 2026-06-24 暫拔除；rd-done 後 DoD 閘門牆現＝①契約②schema③verify-c0⑥build⑦LLM審 + owner。）

【RD 軸（§4c；advisory、跨模型、各 read-only）】
spawn：verifier-contract（契約對齊）／verifier-scope（commit 範圍、誤動 OUT、聚焦）／
verifier-regression（舊系統/i0 偏離、既有回歸、reflection）／verifier-enforcement（強制點
真落地：BE 權威 enforce、mutating 非 FE-only、決策欄 client 不可送）。
各回 PASS/Blocker(file:line) → 採納修正後再審一輪。

【回填 + 停】
- 達標（①②③⑥ 綠 + RD 軸無 Blocker）→ ledger 該頁 status=rd-done、填 code 路徑（commit/PR）。
- 一頁一 commit（金融頁逐頁）；回報 diff 摘要。
- T1 頁（金錢/評分/授權，含撥貸 0920/0921/0922+T24、c0 評分線）→ 停此交人審（不自動接下一頁）。
- 不自宣 Done：終點＝rd-done（待 DoD 閘門牆 + 人審）。

【回報格式】
- funcId + code commit/PR 路徑 + 改動 BE/FE 檔清單。
- DoD ①②③⑥：各 exit code / PASS。
- RD 軸：每軸一行（PASS / Blocker+file:line）+ 採納修正結果。
- ledger 回填 diff（status→rd-done、code 路徑）。
- 仍待 C 類/未決：彙總（不自決）。
- 一句：rd-done 是否四守則守住（不自宣 Done/不碰 C 類/不改既有 i0/軸真獨立）。
```

---

## 備註
- **序列一次一頁、drain 整批**（同 SRS）：每頁各自過閘門＋軸＋回填，一頁達標即接下一頁（T1 例外＝per-page 停人審），drain 完 `rd-ready` 才停 batch checkpoint。
- **強制點是拆工主軸**：FE/BE/both 決定該頁拆幾個子任務、誰是權威驗證層（`spec-architecture §5.5`）。
- **terminal＝rd-done**，進 DoD 閘門牆（①契約②schema③verify-c0⑥build⑦LLM審 + 人審；**④QA驗收⑤覆蓋率 隨 QA 2026-06-24 暫拔除**）→ owner 蓋 Done。
- 卡歸檔 `done/`：本批 drain 跑完、回填完成後移。
