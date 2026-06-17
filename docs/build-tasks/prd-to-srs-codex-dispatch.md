# PRD → SRS dispatch prompt（給 Codex；新版 Bible/PRD 用）

> **用法**：在母資料夾（產品碼 + 規劃 repo 可讀 + 新版 Bible/PRD 放好）開 Codex，**一次一頁**貼下方 prompt（填 `<funcId>` / `<PRD 路徑>`）。產 SRS bundle → 過閘門 → 回填。
> **依賴**：① 新版 PRD（必）+ Bible（有則接上游追溯）② 該頁產品碼（as-is）③ 規劃 repo 的 skill/SOP（prompt 已內聯關鍵，不可讀亦能跑）。
> **risk-tier 批次順序**：① 企金線 T1〔`EPROC00118`/`EPROC00120`/`EPROCSU0170`〕→ ② 企金線 T2/T3（見 `c0-legacy-parity-recheck.md`）→ ③ 撥貸〔0921/0922+T24〕→ ④ `EPROZ00800` 重產（新版 PRD 取代 v0.9）→ ⑤ 主流程 ISU/i0/z0 增量。

---

## ⬇️ 複製以下給 Codex（一次一頁）

```
任務：把新版 PRD `<PRD 路徑>`（funcId `<funcId>`）轉成 SRS bundle（SA + AI 步驟，what→how）。

【權威工作流】先讀規劃 repo 的 `.claude/skills/prd-to-srs/SKILL.md` 正文（忽略 YAML
frontmatter），照其〔輸入 / 輸出四檔 / spec.md 十段結構 / SRS 鐵則 / Brownfield 鐵則 /
步驟 / DoD〕全照做。若該檔不可讀，依本 prompt 的內聯要點。

【本專案 context（2026-06-17）— 必遵】
1. 舊系統為主 + 三判（規劃 repo `docs/process/legacy-parity-sop.md`）：to-be 規則以
   「舊系統對應行為」為基準；新≠舊的差異在 spec 明標三判——
   (a) regression → 照舊修回　(b) 刻意演進/縮編 → keep 新 + 寫理由
   (c) DB 結構差 → code 對齊舊行為、schema 以新為準（不回滾 DB）。
   「刻意演進」須有依據（法規/PRD 明載/已知需求），無依據預設當 regression 上報。
   每差異附【新舊雙方 file:line】。
2. as-is 來源 = 該頁產品碼（母資料夾）。企金頁對【舊企金 EPROCS_*/EPROCU_*/EPROC0_*】
   比、非對個金 i0/ISU（每頁舊對應與維度見 `c0-legacy-parity-recheck.md`）。
   若該頁已有 parity findings（done/c0-legacy-parity-recheck-T*-findings.md）→ 用作 as-is；
   無則 as-is 標「待 parity 碼驗 / 待 RD 核對」，不臆造。
3. Brownfield 最低驗證深度（結構在 ≠ 行為對）：逐一追 ① 每個 DB 寫入有無 return/commit
   ② 每個 stub/TODO/throw-Unsupported ③ 每條 error/分支 path ④ 跨頁副作用。
4. 真實 endpoint = RPC `epl-{verb}-{scope}-{feature}`（非 PRD 理想化 /api/...）；
   mutate=POST。Oracle native query 未加引號 alias → label 大寫（大小寫對映注意）。

【輸出 bundle → 規劃 repo `docs/specs/srs/<funcId>/`】
- spec.md（Metadata header〔Status/Owner/Slug/版本/上游 PRD/as-is 來源〕、Scope+Non-Goals、
  Assumptions/Deps、Endpoints〔epl-*〕、業務規則 Rn〔每條 covers-prd: + 強制點 FE/BE/both +
  as-is✅⚠️🔴/to-be〕、NFR、Trade-offs、@PENDING、Traceability Matrix、硬界線 + as-is/to-be 摘要）
- openapi.yaml（真實 epl-* request/response）
- schema.sql（涉及表/欄 DDL：型別/長度/PK/nullable）
- qa-cases.md（每條 covers: Rn；test-ready：Given 可 seed、When 對 epl-*+method、
  Then 有 DB 驗證點〔表/欄/期望值〕；多分支 Rn 的 happy/error/edge 各 ≥1 case）

【鐵則】
- 一條業務規則 = 一個 Rn；行為句用 EARS（普通/當…時/在…期間/若…）。
- PRD 的 TBD 不可自行裁定 → 寫 R?-PENDING + owner + 待關 TBD-xxx。
- PRD 內若帶 legacy 細節（checkpoint key 名/現行 method/欄寬）不可原樣搬進 openapi/schema
  契約 → 辨識並標 to-be 或 @PENDING。
- 不臆造 file:line；未證標「待 RD 核對」。

【DoD（Approved 前必過，含批判輪教訓）】
- 每 PRD REQ ≥1 Rn；每 Rn ≥1 QA covers + 強制點；完整性/安全的驗證 BE 有且權威。
- gate⑤：多分支 Rn 各 happy/error/edge ≥1 case（「僅…/未撰寫/RD 補」會被判 partial）。
- Bible 安全/災難條件逐條對：carried(Rn) 或 disclaimed；【安全/災難類未承載 → 不得 Approved
  （連 subset 也不行）】。
- PRD Error Response 每個錯誤碼 → 落某 Rn + openapi response（對的 HTTP status），否則明文
  disclaim + owner；勿把「查詢失敗 500」併進「輸入錯誤 400」。【逐碼比時先去 markdown 底線
  跳脫 `MSG\_X`→`MSG_X` 再比，否則 literal `_` 漏抓】。
- mutating 端點（execute/POST）若強制點 FE-only → 必列對應 BE 強制 Rn 或記「為何 FE-only 足夠」。
- 標「後端為準/不信前端」的 Rn → 檢查 request 契約不得讓 client 送該決策欄。
- Status 雙軸（規格定版 vs 實作完成），勿單一 Approved(subset) 混用。

【過閘門（兩層，先機械再語意）】
1. 機械：`python scripts/check-srs-bundle.py docs/specs/srs/<funcId>` 必 exit 0。
2. 語意：spec-reviewer（`.codex/agents/spec-reviewer.toml`，唯讀）無未解 Blocker；
   採納修正後【再審一輪】（修正可能引入新錯）。

【回填】bundle 連到 feature-inventory 該頁 + per-page-reinventory-matrix（SRS 欄）；
列出仍未關的 TBD（給 PM/SA）。每頁先唯讀盤點實際完成度再動工。
```

---

## 備註
- **一次一頁**：別一次吞整批；T1 三頁各自跑、各自過閘門、各自人審。
- **parity 與 SRS 互補**：企金線 18 頁 parity 卡（`c0-legacy-parity-recheck.md`）的 findings 餵 SRS 的 as-is 欄；兩者可並行，但同頁建議 parity 先（as-is 才實）。
- **SRS 落點是規劃 repo**（`docs/specs/srs/`）：Codex 要能寫到規劃 repo；新版 Bible/PRD 建議也放 `docs/specs/bible`、`docs/specs/prd`（與 00800 同位）。
- **00800 重產**：用新版 PRD 覆蓋現 v0.9（現版標「砍掉重建在即」）；SR-B1/B2 折進重建的 2 錯誤碼承載在此一併補。
