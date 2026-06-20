# PRD → SRS dispatch prompt（給 Codex；新版 Bible/PRD 用）

> **用法**：在母資料夾（產品碼 + 規劃 repo 可讀 + 新版 Bible/PRD 放好）開 Codex。下方 prompt＝**單頁轉換單元**（填 `<funcId>` / `<PRD 路徑>`）；產 SRS bundle → 過閘門 → 回填。
> **批量 = drain（2026-06-20）**：規模化由 SRS orchestrator（`orchestration-playbook §5b/§6b`）驅動——允許**多頁同時 `prd-ready`**，orchestrator **序列**逐頁套用本 prompt（一次一頁、每頁各自過 gate＋N 軸＋回填），**持續 drain 直到所有既有 `prd-ready` 都轉成 `in-review`** 才停（batch checkpoint）。本 prompt 本身不變、仍是單頁；改的是外層迴圈不再每頁停。
> **依賴**：① 新版 PRD（必）+ Bible（有則接上游追溯）② 該頁產品碼（as-is）③ 規劃 repo 的 skill/SOP（prompt 已內聯關鍵，不可讀亦能跑）④ **對比輸入 md**（新舊 DB 差異/新 schema + 既有重構 spec，見 prompt 內 §5）。
> **risk-tier 批次順序**：① 企金線 T1〔`EPROC00118`/`EPROC00120`/`EPROCSU0170`〕→ ② 企金線 T2/T3（見 `c0-legacy-parity-recheck.md`）→ ③ 撥貸〔0921/0922+T24〕→ ④ `EPROZ00800` 重產（新版 PRD；v0.9 已封存）→ ⑤ 主流程 ISU/i0/z0 增量。

## PRD 放置與對應（PM 貼給 Codex 前；2026-06-18 EPROZ00100 首跑實測歸納）
> **對應鍵＝funcId**（如 `EPROZ00100`）。PRD 檔名含 funcId → SRS 自動產到 `srs/<funcId>/`、db-diff 用 table_name、refactor-spec 用 module_code（EPRO* 碼、≈funcId）反查、trace 配同 funcId。**一頁一 PRD、funcId 不重複**（同 funcId 多版會被 gateⒷ glob 同時命中、取字典序最後一個 → **只留最新一份在資料夾**）。

| 檔案 | 放哪 | 由誰 |
|---|---|---|
| Bible v1.1 | `docs/specs/bible/bible-eproposal.md` | 已在 repo |
| **PRD 快照** | `docs/specs/prd/`（**扁平放、可一次 bulk**），名 `PRD-*<funcId>*.md`（rename 腳本 `scripts/rename-prd.ps1`）| **PM 放** |
| trace | `docs/specs/prd/trace-*<funcId>*.md` | **prd-to-srs 產**（PM 不放）|
| **SRS bundle** | `docs/specs/srs/<funcId>/`（spec.md/openapi.yaml/schema.sql/qa-cases.md）| **prd-to-srs 產**（PM 不放、目錄名＝funcId）|
| 新 DB schema | local `docs/db-diff/`（**留母資料夾、不進規劃 repo**）| owner（dev host）|
| 70% baseline | local `docs/refactor-spec/`（**留母資料夾**）| owner（dev host）|

**PRD 內容格式預檢**（讓閘門接得上；涵蓋範圍以 `scripts/check-srs-bundle.py` 檔頭為準）：
1. **檔名** `PRD-*<funcId>*.md`（`PRD-` 開頭＋含 funcId）；不符 → gateⒷ/gateⒺ 找不到快照、覆蓋驗證**靜默略過**。
2. **錯誤碼** Error Response 表用 `MSG_*`/`COMMON_MSG_*` 前綴 → 機械 gateⒺ 才逐碼守承載；**裸名（`MISSING_X`）gateⒺ 抓不到**（實測 0 碼納入）→ 只剩 spec-reviewer 守（該輪語意審不可省）。
3. **join key（更動範圍入口）** §DB 影響矩陣**明列實表名 `TB_*`**（→ db-diff by table_name）＋給 module_code/端點（→ refactor-spec by module_code/artifact_id）；delta 由本 prompt §5 在母資料夾算、**PRD 只需給鍵、不自算**。
4. **REQ id** 用 `REQ-NNN`（三位數）token（gateⒷ 上行追溯鍵）；每 REQ 後續對得到 ≥1 規則。
5. **TBD** 寫表格列、每條附 owner ＋ 影響範圍（→ SRS @PENDING；**不自裁**）。
6. **maxlength/必要** PRD 能給就給（餵 openapi↔schema 交叉比對 + refactor delta 佐證）。
7. **既有頁 as-is** 附該頁 verification findings 路徑（`build-tasks/done/<page>-*-findings.md`），bundle 的 as-is 才實。

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
   A. 新 Table schema（新側 snapshot）＝**local `docs/db-diff/`**（owner 提供；結構已盤點 2026-06-17，**2026-06-18 改名 db-diff 後重掃確認：187 檔/156 表/snapshot+change-hint 不變、非完整 diff**）：
      - 佈局：`02_tables/TB_<NAME>.md`（156 表，一檔一表）、索引 `00_HOME.md`（Table Map）、`01_groups/group-xx.md`。
        **索引鍵＝`table_name`**（非 funcId；table→funcId 反查多半缺）。
      - schema 形式＝**markdown 欄位表**（`| no | pk | fk | column_name | comments | data_type | nullable | data_default | note |`），
        **非 DDL** → 轉寫 schema.sql 時逐欄對映（column_name/data_type/nullable/pk/data_default 直接落 CREATE TABLE）。
      - ⚠️ **此資料夾＝新 schema 權威 snapshot（2025-05-14），不是完整新舊 diff**：舊→新差異**只**散在 per-column
        `note`（如「重構新增」）/`transpose_method` + per-table `usage_status`（removed_or_unused）/`match_status`（accepted_alias）
        ＝change-hint，非 row-level diff。→ schema.sql 帶這些 hint 當「重構新增/別名/已棄用」註記；**真要對舊行為（parity）
        回舊系統 behavior（`legacy-parity-sop`），不靠此資料夾**。
      - **找該頁碰哪些表**（無 funcId→table 反查）：由 ①as-is 產品碼 entity/`@Table`/native SQL ②`TB_CHECK_POINTS_{IS,CS,IU,CU}`
        內以 funcId 命名的 checkpoint 欄 ③Bible v1.1 DB 錨點（`TB_LON_SUMMARY_INFO`…）④`legacy/db-schema-catalog.md`
        推出 table set，逐表查 `02_tables/`（找不到→標 UNFOUND、不臆造）。
      - ⚠️ `OVSLXLON01/02`＝runtime 資料來源（A-2/B-1 escalations 已裁），**與此 schema 結構正交**、勿混。
   B. refactor-spec＝**latest-only spec index/artifact map ＋ legacy reference outputs**＝**local `docs/refactor-spec/`**（owner 提供；**2026-06-18 改名後重掃、結構已重排**）：
      - 佈局（737 檔；733 .md＋`manifest.json`＋tools）：**latest＝`03_artifacts/**/*.md`（466，已挑 selected latest artifact；一 module 可多 artifact、68 module 多 artifact）**、**legacy 多版＝`02_specs/`（146，含 `doc_status`/`修訂紀錄`/`待確認項目`；舊版在 `manifest.json.excluded_versions`）**、module 彙整 `02_modules/`（77）、索引 `00_HOME.md`/`README.md`（Source Map）、共用規則 `03_rules/`（7）＋`04_rules/`（8，含 `field_rule.md`/`validation.md`）、`04_assets/`（18，畫面/圖）、`01_groups/`（7）、issues `99_issues.md`。
      - **索引鍵＝`module_code`（EPRO* 頁碼、≈funcId）→ `artifact_id`（區分 API/FE/asset）；無 literal `funcId` 欄**。
        **latest 規則＝highest parsed version → newest filename date → non-old path**（跳 archive/old；見 `refactor-spec/README.md:26`）；一 module 可多 latest artifact → 撈齊該 module 全部 latest。
      - 當 **as-is baseline** 取用：① API Header 欄位表 `LVL|欄位名稱|資料型態|最大長度|必要|說明`
        ＝**maxlength/必填量化來源**（解 D5 FE/BE split-brain；latest 抽到 `04_rules/field_rule.md`）② `epl-*`（~270）＋request/response body＝endpoint/DTO 契約 grounding
        ③ validation signals（`04_rules/validation.md`，713；**literal `validation_rule`=0**）＝**驗證點素材**
        （**非正式 QA → SRS QA 仍新撰**）。⚠️ refactor-spec **無正式 Rn/REQ** → Rn 由新 PRD 合成、refactor-spec 供 as-is 佐證。
      - **「更動後需求」＝新 PRD ⟷ refactor-spec latest 的 delta**；as-built 狀態/開放項用 legacy `02_specs/` 的 `doc_status`/`修訂紀錄`/`待確認項目`
        ＋ latest map 的 `version`/`date`/`old_path`/`99_issues.md` 判讀（**`open_issue` 已無**）。
      - **覆蓋先查**：refactor-spec 缺該頁→無 baseline 可 reconcile→走 i0-mirror＋`legacy-parity-sop`（標 parity 風險、不臆造 baseline）。
        已知缺＝**`EPROC00119`/`EPROC00120`**（無獨立 module/artifact、只在 `EPROC00110` 規則被引；相近 `EPROI00119`/`EPROI00120` 存在——⚠️ 勿混；risk-tier T1 先跑頁 `EPROC00118` 與此只差一碼、不同維度）；其餘額外覆蓋（如 `EPROZ0B001-0B007` 批次）依 latest map 實查。
   C. 我方既有裁定/約束（repo，勿 re-litigate）：
      - `docs/decisions.md`＋`docs/archive/decisions-2026H1-disbursement.md`（已裁：AUD-6 精度 keep-new〔decisions〕、A-5 KHR 收窄/T24 照舊〔disbursement archive〕、頁合併 CS/CU→CSU…）
      - `docs/pending-register.md`（該頁開著的 @PENDING/escalation）
      - `docs/build-tasks/refactor-audit/per-page-reinventory-matrix.md`（該頁 disposition）
      - `docs/disbursement/disbursement-domain-escalations.md`+`disbursement-triage.md`（撥貸頁）
      - `docs/process/legacy-parity-sop.md`（三判）、parity findings（`done/*-findings.md`）
      〔00800 v0.9 SRS 已封存 `docs/archive/EPROZ00800-v0.9-superseded/`，重產時可參照其 RP/SR 裁定〕
   做法（更動後需求一律落 SRS，不得靜默遺漏）：
   - **DB delta**（local `docs/db-diff/`）：schema.sql 以新側 snapshot 為權威；change-hint（per-column `note`/`transpose_method`、
     per-table `usage_status`/`match_status`）標「重構新增/別名/已棄用」+ 三判；連動的 Rn 取數/驗證同步更新；
     若 hint 顯示結構縮減/改型可能影響需求（如精度）→ 寫進該 Rn 或開 @PENDING。**完整 row-level 舊→新 diff 此資料夾無
     → 需對舊行為者回 `legacy-parity-sop`**。
   - **refactor-spec delta**（新 PRD ⟷ local `docs/refactor-spec/`）：新 PRD 與 70% 當初依據的 baseline
     不同 → 該「更動後需求」明確寫進 Rn（標 to-be 新需求）或 @PENDING；baseline 有而新 PRD 漏的，
     確認是刪除還是漏列。
   - **既有決策 delta**（repo）：decisions 已改的需求（keep-new 精度、KHR 收窄、照舊、頁合併、
     disposition）→ 當 SRS 約束帶入、**不重議**；PRD 與既有決策/DB/refactor-spec 衝突 → 標 @PENDING
     （指回 decisions/pending）。
   - 每條 delta 附來源（db-diff 檔行 / refactor-spec 段 / decisions 列 / parity `file:line`）+ 三判 tag。

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
- **既有決策＝ provenance 帶進 Rn（SRS 為結論），非凍結為 done**：原系統處理／「code 已 push」＝**as-is 證據墊底、≠ SRS 已定版**；**讀 SRS 即見結論**，不必回翻決策檔（決策只當 provenance 連結）。金錢/交易/安全面凡未逐欄坐實或有缺口 → `@PENDING`、不標 ✅（ADR-0002 升級觸發：金額/交易/安全；先 SRS 結論、再以原系統處理為 as-is 佐證）。
- **⚠️ owner 明示 re-open 的決策＝不沿用為定案（現況：T24，見 `decisions.md`「T24 於 SRS 層 re-open」＋`pending-register` 同列）**：該域 SRS **逐欄/逐段重推 to-be**（as-is＝原系統處理 `file:line`）、**每欄 → `@PENDING` 待 owner 逐欄 confirm**、原 parity-fix code 僅 as-is 證據（confirm 後可維持或改），**不可寫成「照舊 ✅」**。一般決策仍照上條（帶入為約束、不重議）；本條限 owner 點名 re-open 者（T24＝0922 REQ-004）。

【DoD（Approved 前必過，含批判輪教訓）】
- 每 PRD REQ ≥1 Rn；每 Rn ≥1 QA covers + 強制點；完整性/安全的驗證 BE 有且權威。
- gate⑤：多分支 Rn 各 happy/error/edge ≥1 case（partial 判定詞見 `check-srs-bundle.py` 檔頭）。
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
  Rn/@PENDING 顯式承載、附來源+三判，未遺漏**；既有決策（AUD-6/A-5/T24/頁合併…）當約束不重議。**（2026-06-18 加 backstop：機械 `gateⓇ` warn『spec 無 delta 段』＋ spec-reviewer 紅旗⑥ 查『只寫待 RD』→ reconcile 不再只靠自律。）**

【過閘門（兩層，先機械再語意）】
1. 機械：`python scripts/check-srs-bundle.py docs/specs/srs/<funcId>` 必 exit 0。
2. 語意：**SRS N 軸驗證**（`orchestration-playbook §4b` 的 A–G 軸，七正交、各 read-only、最好跨模型；axis A＝`spec-reviewer`〔`.codex/agents/spec-reviewer.toml`＝部署後本機路徑、repo 範本 `docs/env/codex/spec-reviewer.toml`〕；risk-tier T1 全 A–G、低風險頁可 A+E+G）**全軸無未解 Blocker**；
   採納修正後【再審一輪】（修正可能引入新錯）。

【回填】bundle 連到 feature-inventory 該頁 + per-page-reinventory-matrix（SRS 欄）；
列出仍未關的 TBD（給 PM/SA）。每頁先唯讀盤點實際完成度再動工。
```

---

## 備註
- **序列一次一頁、但 drain 整批**（2026-06-20 改）：不並行吞整批；每頁各自過閘門＋N 軸＋回填，但 orchestrator **一頁達標即接下一頁、不在每頁停**，drain 完所有 `prd-ready`→`in-review` 才停在 batch checkpoint **一次交人審/裁 TBD**（非每頁人審）。終點仍是 `in-review`、不自升 approved（人裁 TBD 才升）。迴圈權威＝`orchestration-playbook §5b/§6b`。
- **parity 與 SRS 互補**：企金線 18 頁 parity 卡（`c0-legacy-parity-recheck.md`）的 findings 餵 SRS 的 as-is 欄；兩者可並行，但同頁建議 parity 先（as-is 才實）。
- **SRS 落點是規劃 repo**（`docs/specs/srs/`）：Codex 要能寫到規劃 repo；**Bible v1.1 已在 repo**（`docs/specs/bible/`），新版 PRD 放 `docs/specs/prd/`（舊 00800 PRD 已封存 `docs/archive/EPROZ00800-v0.9-superseded/`）。
- **00800 重產**：v0.9 SRS 已封存（`docs/archive/EPROZ00800-v0.9-superseded/srs/`）；用新版 PRD 從新 Bible v1.1 **重產**——封存內 RP1-10 裁定 + SR-B1/B2（2 錯誤碼）+ RP8/RP11 為重產輸入，一併承載。
