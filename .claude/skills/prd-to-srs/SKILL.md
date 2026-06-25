---
name: prd-to-srs
description: Convert a PRD (產品需求, "what") into an SRS bundle (系統開發規格, "how") for this eProposal refactor. Use when the user has a PRD (e.g. CDC-EPRO-*, or a page's PRD) and wants the SA-level SRS — endpoints, rule-ids, OpenAPI, DB schema — i.e. the "SA + AI → SRS" step of the AI workflow (docs/assets/ai-workflow.mmd). Triggers: "PRD 轉 SRS", "產 SRS", "把 PRD 變規格", "SRS bundle for <funcId>".
---

# PRD → SRS（SA + AI 步驟）

把 PRD（what）轉成 **SRS bundle（how）**，產物餵 **SRS 定稿機械閘門**（`check-srs-bundle` ①②⑤＋字母 Ⓑ/Ⓟ/Ⓢ/Ⓔ/Ⓡ）＋ `spec-reviewer`（⑦語意）；牆上 **③verify-c0／④QA-Testcontainers／⑥Build 在 code 階段、不在此**。兩套編號對齊＝`docs/specs/srs/README.md §閘門編號對照`（唯一對齊處、以腳本檔頭為準）。位置見 `docs/assets/ai-workflow.mmd`。
範本＝worked example **重產中**（00100/00118 已全清、待母資料夾用最終 pipeline 重產；00800 v0.9 已封存 `docs/archive/EPROZ00800-v0.9-superseded/`）。結構/閘門對照見 `docs/specs/srs/README.md`。

## 輸入
1. **PRD**（主來源；如 `CDC-EPRO-0001` 00800）。
2. **Bible**（若有，取北極星/黃金旅程當上游追溯）。
3. **既有碼**（若該頁已實作 → 做 as-is vs to-be；用該頁的 verification findings）。
4. **慣例**：`backend/AGENTS.md` §6、`page-mapping.md`（真實 API 慣例＝RPC `epl-{verb}-{scope}-{feature}`）。
5. **對比輸入（多 md，reconcile，更動後需求顯式納入 SRS）**：① 新 table schema snapshot＝**local `docs/db-diff/`**（index `table_name`；markdown 欄位表非 DDL；新 schema 權威；舊→新僅 change-hint〔`note`/`usage_status`〕、**非完整 diff**）② latest-only spec/artifact map＝**local `docs/refactor-spec/`**（737 檔；**index＝module_code→artifact_id**〔非 funcId〕；latest 在 `03_artifacts/`、legacy 多版在 `02_specs/`；含 API 欄位表 maxlength/必要＝量化來源；無正式 Rn/QA；「更動需求」＝新 PRD ⟷ latest 的 delta）③ 我方既有裁定/約束＝repo `decisions`/`pending-register`/`refactor-audit/per-page-reinventory-matrix`/`disbursement-*-escalations`/`process/legacy-parity-sop`。→ 見 DoD「reconcile」；結構 **改名後重掃確認**（db-diff＝snapshot+change-hint **不變**；refactor-spec 已重排 latest-only，index 改 module_code）、抽取細則見 dispatch 範本 `build-tasks/prd-to-srs-codex-dispatch.md` §5。

## 輸出（bundle，放 `docs/specs/srs/<funcId>/`）
| 檔 | 內容 | 餵閘門 |
|---|---|---|
| `spec.md` | SRS 主檔：endpoints + 業務規則 `Rn` + @PENDING + 硬界線 + as-is/to-be | ⑤·Ⓑ·Ⓟ·Ⓢ·Ⓔ·Ⓡ |
| `openapi.yaml` | 真實 `epl-*` endpoint 的 request/response schema | ① |
| `schema.sql` | 涉及 DB 表/欄位 DDL（型別/長度/PK/nullable） | ② |
| ~~`qa-cases.md`~~ | 〔**暫拔除**：QA 產生/驗收先移除；恢復見 git history〕 | — |
| `README.md` | **人類 digest**（RD 速覽：頁目的/流程/規則速覽/雷區；衍生自 spec、spec 權威）。單一出處＝`docs/specs/srs/digest-template.md` | —（人讀層、非 gate）|

> 「餵閘門」＝**SRS 定稿 pre-check**（`check-srs-bundle` ①②⑤＋字母 Ⓑ/Ⓟ/Ⓢ/Ⓔ/Ⓡ＋xfile）；牆上 **③verify-c0／④QA-Testcontainers／⑥Build 屬 code 階段、不在此**。完整兩套編號對照＝`docs/specs/srs/README.md §閘門編號對照`。

## `spec.md` 結構（必含 — 吸收自通用 SRS 範本）
> **結構單一出處（canonical）＝`docs/specs/srs/spec-template.md`**（複製它起手）。**一檔兩半（可讀性演進）：上半 Contract＝to-be only 契約（Metadata / Scope / Assumptions / Endpoints / Rules / NFR / Hard Boundaries），實作者純掃即可開發；下半 `Appendix — Evidence & Decisions`＝佐證/出處/風險（Source Evidence / Trade-offs / DB Reconcile・Delta / @PENDING / Rule Evidence）。契約 Rn 不內嵌 as-is/current code/`RPxx closes`/`@SHA`/file:line——那些移 Appendix `Rule Evidence`、契約用 `[ev→Rn]` 指過去（1:1）；資訊不刪、只搬位。** 段標題用英文、不編號、同概念用 canonical 唯一名（DB 段＝`DB Reconcile / Delta`、待決段＝`@PENDING`…）。**新 bundle 須通過 `check-srs-bundle.py` 結構檢查（warn-clean；含 Contract 純淨度 + `[ev→Rn]` 指標）**；既有包標準定版前產出、漂移為已知（grandfathered，折進已排翻新再轉兩半）。**完整段序/段名以 template 為準**；下列為各段語意（追溯靠 Rn 的 `covers-prd:`、**無獨立 Traceability 段**）。
1. **Metadata header**（表格）：**`Status` 雙軸**＝`規格定版`（`Draft`/`In Review`/**`Approved (subset)`**/**`Approved`**）`; 實作完成`（`not-started`/`in-progress`/`done`）——勿單軸混用(gateⓈ(b) 會 warn;格式見 template)、`Owner`、`Slug`（＝funcId）、`版本`、`最後更新`、`上游 PRD`、`as-is 來源`。
   - **`Approved (subset)`＝部分核准**（避免 binary 卡死）：**TBD-無關子集已定稿、可交 RD 動工**；含 `@PENDING` 的部分未定稿。**必附**：① 就緒子集（哪些 `Rn`／對應 as-is→to-be「可先修」）② blocked 子集（哪些 `Rn` + 待哪個 `@PENDING`/TBD）。`@PENDING` 全關 → 整份升 `Approved`。**⚠️ 未承載的 Bible 安全/災難條件（`BPn-PENDING` seam）不得標 Approved（即使 subset）**——有此類 seam 應降 `Draft`/`In Review`、逼缺口浮上檯面，不得沉進 seam pending（gateⓈ 會 warn；源 00800 BR-014「不該顯示卻顯示」災難情境被降 BP1 seam、Approved subset 照發之教訓）。
2. **概述 / Scope + Non-Goals**：本 SRS 規格化哪個 PRD 的哪些 REQ；**本期 / 非本期**（防 scope creep）。
3. **Assumptions / Dependencies / Constraints**：成立前提、依賴服務/團隊、tech stack/法規限制。
4. **Endpoints**：真實 `epl-*`（method / as-is / DTO）。
5. **業務規則 `Rn`（Contract 半，to-be only）**：每條 `covers-prd:` + **強制點（FE / BE / FE+BE）** + 末尾 `[ev→Rn]` 指標。規則本體只寫 **to-be 契約**；as-is 現況/狀態/疑似 bug/決策/provenance → Appendix `Rule Evidence`（鍵到 Rn）。**完整性/安全的驗證 BE 必須有且為權威**（FE 同款＝UX，永不信前端）。
6. **NFR**：量化（perf/可用性/安全/觀測/交易一致性）。
7. **Trade-offs**（重大取捨）→ 連 `docs/adr/ADR-NNNN-<funcId>.md`。
8. **@PENDING**（每個 TBD 一條 + owner）。
9. **追溯**：靠每條 `Rn` 的 `covers-prd:` 欄（gateⒷ 強制對到 PRD REQ）;**不另出 Traceability Matrix 表**（移除——QA 拔除後與 covers-prd 重複;REQ 覆蓋缺口由 N 軸 axis A 完整性顧）。
10. **硬界線** + **as-is→to-be 摘要**（給 RD：可先修 vs 待 TBD）。

## SRS 撰寫鐵則
1. **rule-id 粒度**：一條業務規則 = 一個 `Rn`；複雜規則拆細。
1b. **行為句建議 EARS 句型**（SDD 技巧，建議非閘門、既有 R 不回溯改）：`Rn` 的行為敘述優先用四型之一——普通「系統應…」、事件「**當**〔觸發〕時，系統應…」、狀態「**在**〔狀態〕期間，系統應…」、非預期「**若**〔不該發生的事〕，系統應…」。一句一行為；量化照舊（§5 模糊詞量化）。
2. **雙向追溯**：每個 `Rn` 標 **`covers-prd:`**（上游對到 PRD 的 REQ-id / 章節）。funcId 串 Bible→PRD→SRS→code。〔下游 QA case `covers: Rn` 隨 QA 暫拔除。〕
3. **TBD → `@PENDING`**：PRD 未關的 TBD **不可自行裁定**；寫成 `R?-PENDING` 規則 + **owner** + 「待關 TBD-xxx」。**不把 legacy 行為當已核准需求**（守 PRD §13）。**例外**：可由新 DB 判定的 **fact**（字典/enum/欄寬/既有授權列）依 §DoD「DB-resolvable」直接解、**不列 Pending**（見 `docs/spec-architecture.md §5b` Rule 1）。
4. **理想化 REST → 真實 RPC**：PRD §6 的 `/api/...` 多為理想化（同 phase1 `/api/emp-proxy`）→ SRS endpoints 寫**實際 `epl-*`**；method 以 PRD 語意定（mutate=POST）。
5. **as-is vs to-be**（頁已存在時）：SRS 標 to-be（PRD 要的），並列 as-is（現碼實況，引 verification findings + `file:line`），差異即 RD 待補。
6. **不臆造**：`file:line`/欄位若未證 → 標「待 RD 核對」。
7. **NFR/錯誤碼/DB 矩陣**：PRD 的非功能/錯誤碼/DB mapping → 落進 `Rn` + openapi/schema。
8. **部分核准可先出貨**：TBD-無關子集可標 `Approved (subset)` 先交 RD（如 00800 D1–D5）；`@PENDING` 部分待裁定關閉後補做，**別讓整份卡在 Draft**。就緒/blocked 分界＝as-is→to-be 摘要的「可先修 vs 待 TBD」。

## Brownfield 鐵則（70% 既有碼專屬 — 失敗教訓回填，見 `docs/spec-architecture.md §9`）
- **動手前先唯讀盤點**：開做前先確認 ① 該頁**實際完成度**（防「未做其實已完成」/「已做誤判未做」）② mirror/算法的**正確來源**（防假設錯，如把換匯 stub 當 `funcGetRate` 計分）。
- **as-is 驗證 ≠ 看有沒有 controller/service**：**結構在 ≠ 行為對等**；migrated 碼要對舊系統/PRD 行為比，引 `file:line`。**最低驗證深度**（防 throw-stub 漏網，如 `funcGetExchangeRate` 無條件 throw 整個 authorize 跑不到）：逐一追 ① 每個 DB 寫入有無 return/commit（半更新？）② 每個 stub/TODO/`throw …Unsupported` ③ 每條 error/分支 path ④ 跨頁副作用。
- **regression vs 刻意演進的判準**：異於舊版 → **預設當 regression 上報**；要歸「刻意演進」**必須有依據**（在地化法規 / PRD 明載 / 已知需求，如 KHR fee rounding）；**無依據不准自判演進**（舊系統≠絕對正確、但新碼也≠忠實）。
- **PRD 內帶的 legacy 也要 reconcile**：PRD 可能寫進現行 as-is 細節（具體 checkpoint key 名 / 現行 method / 欄寬）→ **不可原樣搬進 `openapi`/`schema` 契約**，要辨識並標 to-be 或 `@PENDING`（B1 教訓）。
- **Oracle native query map-key**：未加引號 alias → JDBC 回傳 label **大寫**；schema/DTO 對映與 `Rn` 描述注意大小寫（M7 `LOANAMOUNT` 靜默 null）。

## 步驟
1. 讀 PRD，抽：endpoints、REQ 清單、規則、DB 表、錯誤碼、NFR、TBD、測試案例。
2. （頁已存在）讀現碼/findings → 標 as-is。
3. 產 `spec.md`（一檔兩半）：上半 Contract＝endpoints 表（epl-*）→ `Rn`（to-be + `covers-prd:` + 強制點 + `[ev→Rn]`）→ NFR → 硬界線；下半 `Appendix`＝Source Evidence / Trade-offs / DB Reconcile / `@PENDING`（每 TBD）/ `Rule Evidence`（每 Rn 的 as-is/決策/provenance）。
3b. 產 `README.md`（**人類 digest**）：照 `docs/specs/srs/digest-template.md` 從兩半 spec 衍生——繁中速覽（頁目的 1 句／流程 per-page／規則速覽依執行序／雷區／連結）；**精確 identifier 一律不複製、指回 spec**；spec.md 為權威、變更請重生。
4. 〔**產 `qa-cases.md` 暫拔除**：QA 產生/驗收先移除，bundle 不再產此檔。待主線跑順再納入。〕
5. 產 `openapi.yaml` + `schema.sql`（從 PRD §6/§7；未定處標 RD-TBD）。
6. 回填：bundle 連到 `feature-inventory.md` 該頁 + 列出仍未關的 TBD（給 PM/SA）。

## DoD（`Status: Approved` 前必過）
- [ ] 有明確 **Non-Goals / Scope**（防 scope creep）。
- [ ] 每個 PRD `REQ` 都有 ≥1 個 `Rn` 對上（或明確標非本期）。
- [ ] 每條 `Rn` 有可獨立驗證的 **acceptance**（Given/When/Then 或 checklist）。〔**≥1 QA case `covers`、happy/error/edge、gate⑤ 隨 QA 暫拔除**。〕
- [ ] 每條 `Rn` 標**強制點 FE / BE / FE+BE**；完整性/安全的驗證 **BE 有且權威**。
- [ ] **（批判輪2）安全網逐條對 Bible**：列 Bible 點名的 BR/SC/**災難情境** → 每條標 carried(`Rn`) 或 disclaimed(Non-Goals/@PENDING)；**安全/災難類未承載者 → 該 funcId 不得 Approved（連 subset 也不行）**（gateⓈ(a) warn；源 00800 BP1＝BR-014「不該顯示卻顯示」災難情境被降 seam 卻照發 Approved subset 之教訓——原則已在 §spec 結構，但無逐條 check 形同虛設）。
- [ ] **（批判輪2）契約 ⊥『後端為準』原則**：凡 `Rn` 標「後端為準／不得信前端」（如 R11 DB 二次比對為唯一側效依據），檢查 request 契約**不得**讓 client 送該決策欄（否則契約打臉規則；源 00800 `checkPointMap`/`isNotSame` 入 request body vs R11 之教訓）。
- [ ] **（批判輪2）mutating 端點的 FE-only 強制要質疑**：強制點＝**FE-only** 的規則若落在會 **mutate/刪資料** 的端點（execute/POST），必須**列對應 BE 強制 `Rn`** 或明記「為何 FE-only 足夠」——不可預設 FE 擋就夠（源 00800 R3/R5/R6/R7 FE-only on execute 之教訓；BE-權威原則早在 §spec/DoD 卻無 mutating-check 落實）。
- [ ] **（批判輪2）Status 雙軸**：Status 分『**規格定版**』與『**實作完成**』兩軸，禁單一 `Approved(subset)` 混用（gateⓈ(b) warn；源 00800「Approved subset 高估完成度——只 D1–D5 landed、餘『可實作』未做」之教訓）。
- [ ] **（批判輪3）PRD 錯誤碼逐碼承載**：PRD Error Response 表的**每個錯誤碼** → 必落進某 `Rn` 錯誤規則 **且** openapi response（含對的 HTTP status），否則明文 disclaim（如「init-query 無分頁→count-limit 不適用」）+ owner。**勿把「查詢失敗 500」併進「輸入錯誤 400」**（status 語意不同）。gateⒺ warn；源 00800 SR-B1（`MSG_OVER_COUNT_LIMIT`/`MSG_QUERY_FAIL` 漏承載、REQ-007 未完整）/SR-B2（400/500 conflation）。⚠️ 對 PRD 表格逐碼核時注意 markdown 底線跳脫（`MSG\_X`）→ 去跳脫再比，否則 literal `_` 漏抓。
- [ ] 每個 PRD `TBD` 都有一條 `@PENDING` + **owner + 是否 blocking**。
- [ ] **追溯完整**：每 `Rn` 有 `covers-prd:`（→PRD REQ、gateⒷ 驗）;每 PRD REQ ≥1 Rn（axis A 顧）;funcId 串到底。〔Traceability Matrix 表移除,covers-prd 為 SoT。〕
- [ ] endpoints 是真實 `epl-*`、method 符 PRD 語意（mutate=POST）；`openapi.yaml`/`schema.sql` 與 `Rn` 一致。
- [ ] 頁已存在 → **as-is/to-be** 差異清楚。
- [ ] **新舊 DB + 既有 spec reconcile**：SRS 對 ① **local `docs/db-diff/`**（新 table schema snapshot，index `table_name`；新 schema 權威；舊→新僅 change-hint、非完整 diff）② **local `docs/refactor-spec/`**（latest-only spec/artifact map，**index module_code→artifact_id**〔非 funcId〕、latest 在 `03_artifacts/`；API 欄位表 maxlength/必要＝量化來源；「更動需求」＝新 PRD ⟷ latest 的 delta）③ repo 既有裁定/約束（`decisions`/`pending-register`/`refactor-audit/per-page-reinventory-matrix`/`disbursement-*-escalations`）；**更動後需求以 `Rn`/`@PENDING` 顯式納入 SRS**（每條附來源〔db-diff 行/refactor-spec 段/decisions 列〕+ 三判 tag `process/legacy-parity-sop.md`），**不得靜默遺漏**；已裁決策（AUD-6 精度/A-5 KHR/頁合併 CS/CU→CSU）當**約束、不重議**；**⚠️ 例外：T24（0922）+A-4/M6（0921）「照舊」06-20 SRS-層 re-open＝可 re-litigate（其「照舊」僅 code as-is baseline；to-be 走 §5b 梯裁、refactor-spec 有 T24 調整→偏新；見 `decisions.md`「T24/0921 於 SRS 層 re-open」），勿凍結為約束**；PRD 與既有決策/DB/refactor-spec 衝突→標 `@PENDING`。`schema.sql` 以新 snapshot 為權威 + change-hint（`note`/`transpose_method`/`usage_status`/`match_status`）標「重構新增/別名/已棄用」+ 三判；**完整 row-level 舊→新 diff 此資料夾無→對舊行為回 `legacy-parity-sop`**。
- [ ] **來源優先序**：legacy/refactor/DB/PRD 衝突依 `docs/spec-architecture.md §5b` 梯裁——**refactor 限本層贏**（FE/API 契約，留 `REF-Dn` delta）、**不蓋** db-diff（物理）/Bible-PRD（意圖）；命中升級觸發（Bible/PRD 衝突·regression·高風險面 authZ/金額/刪改/安全/交易·同層無 upstream）→ 不自決、列 **C 類 `@PENDING`**。
- [ ] **DB-resolvable fact 不留 Pending**：可由 `docs/db-diff/` 判定的 fact（字典/enum/欄寬/既有授權列當 legacy-state）→ 撈出寫入、**不佔 `@PENDING`**；**三護欄**：只解 fact 非 policy、provenance（inline 標 `[DB:<table>@<snapshot-date>]`＋`REF-Dn`/`DB-Dn` 決策列，可被 audit grep）、與 PRD/Bible 矛盾→升級；讀不到 snapshot＝退回 `@PENDING` 標「待母資料夾撈」。**反向防呆**：每條撈入 fact 須可答「這是**現況描述**、非 to-be **應然**」；**authZ/金額 fact 僅作 legacy-state 證據、to-be 沿用與否待 PRD/升級**（不可默認進 to-be 契約）。
- [ ] 模糊詞已量化（NFR 可量測）。
- [ ] **已過 SRS N 軸驗證**（`orchestration-playbook §4b` 的 A–F 軸：綜合〔軸A＝`spec-reviewer`〕／as-is parity／錯誤碼承載〔含裸名〕／安全·授權／DB reconcile／金錢·精度·截斷；六正交（A–F；原 G 可測試性隨 QA 暫拔除）、跨模型；T1 與低風險頁一律全 A–F、不降軸），**全軸無未解 Blocker**（＝**SRS 定稿 blocking gate**；圖上 ⑦ 是 code 階段的 advisory LLM review，兩者不同）。**採納修正後要再審一輪**——修正可能引入新錯（B1 修法曾引入 checkPointMap 副作用，靠複審才抓）。

> 上游 Bible→PRD 可用官方 knowledge-work plugins（`/product-brainstorming`、`/write-spec`）；SRS 這步用本 skill（領域專屬）。
