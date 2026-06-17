# PRD → SRS dispatch prompt（給 Codex；新版 Bible/PRD 用）

> **用法**：在母資料夾（產品碼 + 規劃 repo 可讀 + 新版 Bible/PRD 放好）開 Codex，**一次一頁**貼下方 prompt（填 `<funcId>` / `<PRD 路徑>`）。產 SRS bundle → 過閘門 → 回填。
> **依賴**：① 新版 PRD（必）+ Bible（有則接上游追溯）② 該頁產品碼（as-is）③ 規劃 repo 的 skill/SOP（prompt 已內聯關鍵，不可讀亦能跑）④ **對比輸入 md**（新舊 DB 差異/新 schema + 既有重構 spec，見 prompt 內 §5）。
> **risk-tier 批次順序**：① 企金線 T1〔`EPROC00118`/`EPROC00120`/`EPROCSU0170`〕→ ② 企金線 T2/T3（見 `c0-legacy-parity-recheck.md`）→ ③ 撥貸〔0921/0922+T24〕→ ④ `EPROZ00800` 重產（新版 PRD；v0.9 已封存）→ ⑤ 主流程 ISU/i0/z0 增量。

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
5. 【對比輸入：多個 md 檔 — 必讀並 reconcile，把「更動後需求」一起納入 SRS】
   A. 新舊 DB 差異 + 新 Table schema＝**local `docs/db-schema/`**（owner 提供）：
      - 內含新舊 DB 差異（add/remove/type/precision/nullable/rename）+ 新 table schema（DDL）。
      - **新 schema 權威＝此資料夾 / 新 DB 實查 / entity**（以 DB 為準）。
      - ⚠️ 結構（檔樹/差異形式/索引）**待 owner 回報後補「抽取細則」**——回報前 Codex 先讀該頁相關表的
        差異 + 新 DDL（找不到該頁碰哪些表 → 標 UNFOUND、不臆造）。
   B. 70% 當初依據的重構 spec＝**local `docs/refactor/`**（owner 提供）：
      - 這是當初 RD 建構 70% 所依據的 baseline spec。**「更動後需求」＝新 PRD ⟷ 此 baseline 的 delta**。
      - ⚠️ 結構（per-頁/模組、含哪些欄位/規則/狀態）**待 owner 回報後補「抽取細則」**。
   C. 我方既有裁定/約束（repo，勿 re-litigate）：
      - `docs/decisions.md`（已裁：AUD-6 精度 keep-new、A-5 KHR 收窄、T24 照舊、頁合併 CS/CU→CSU…）
      - `docs/pending-register.md`（該頁開著的 @PENDING/escalation）
      - `docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md`（該頁 disposition）
      - `docs/disbursement/disbursement-domain-escalations.md`+`disbursement-triage.md`（撥貸頁）
      - `docs/process/legacy-parity-sop.md`（三判）、parity findings（`done/*-findings.md`）
      〔00800 v0.9 SRS 已封存 `docs/archive/EPROZ00800-v0.9-superseded/`，重產時可參照其 RP/SR 裁定〕
   做法（更動後需求一律落 SRS，不得靜默遺漏）：
   - **DB delta**（local `docs/db-schema/`）：新 schema ≠ 舊（型別/精度/加欄/刪欄/改名）→ schema.sql
     列「舊→新對照 + change 類型 + 三判」；連動的 Rn 取數/驗證同步更新；若改動影響需求（如精度
     縮減影響計算）→ 寫進該 Rn 或開 @PENDING。
   - **refactor-spec delta**（新 PRD ⟷ local `docs/refactor/`）：新 PRD 與 70% 當初依據的 baseline
     不同 → 該「更動後需求」明確寫進 Rn（標 to-be 新需求）或 @PENDING；baseline 有而新 PRD 漏的，
     確認是刪除還是漏列。
   - **既有決策 delta**（repo）：decisions 已改的需求（keep-new 精度、KHR 收窄、照舊、頁合併、
     disposition）→ 當 SRS 約束帶入、**不重議**；PRD 與既有決策/DB/refactor-spec 衝突 → 標 @PENDING
     （指回 decisions/pending）。
   - 每條 delta 附來源（db-schema 檔行 / refactor spec 段 / decisions 列 / parity `file:line`）+ 三判 tag。

【輸出 bundle → 規劃 repo `docs/specs/srs/<funcId>/`】
- spec.md（Metadata header〔Status/Owner/Slug/版本/上游 PRD/as-is 來源〕、Scope+Non-Goals、
  Assumptions/Deps、Endpoints〔epl-*〕、業務規則 Rn〔每條 covers-prd: + 強制點 FE/BE/both +
  as-is✅⚠️🔴/to-be〕、NFR、Trade-offs、**新舊 DB 對照 + 更動 delta 清單**〔每條：來源
  〔DB-diff/decision/parity〕→ 影響 Rn → 三判 → carried(Rn)/@PENDING〕、@PENDING、
  Traceability Matrix、硬界線 + as-is/to-be 摘要）
- openapi.yaml（真實 epl-* request/response）
- schema.sql（涉及表/欄 DDL：型別/長度/PK/nullable；**+ 新舊對照**：舊欄→新欄、change 類型
  〔add/remove/type/precision/nullable/rename〕、三判 tag、來源 schema-diff 行）
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
- **新舊 DB + 既有 spec reconcile**：SRS 已對 schema-diff（新舊 DB 差異/新 schema）+
  feature-inventory/matrix/decisions/pending/escalations（既有重構 spec）；**更動後需求以
  Rn/@PENDING 顯式承載、附來源+三判，未遺漏**；既有決策（AUD-6/A-5/T24/頁合併…）當約束不重議。

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
- **SRS 落點是規劃 repo**（`docs/specs/srs/`）：Codex 要能寫到規劃 repo；**Bible v1.1 已在 repo**（`docs/specs/bible/`），新版 PRD 放 `docs/specs/prd/`（舊 00800 PRD 已封存 `docs/archive/EPROZ00800-v0.9-superseded/`）。
- **00800 重產**：v0.9 SRS 已封存（`docs/archive/EPROZ00800-v0.9-superseded/srs/`）；用新版 PRD 從新 Bible v1.1 **重產**——封存內 RP1-10 裁定 + SR-B1/B2（2 錯誤碼）+ RP8/RP11 為重產輸入，一併承載。
