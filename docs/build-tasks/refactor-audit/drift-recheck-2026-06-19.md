# Drift Re-check — refactor-audit vs feature-inventory（2026-06-19）

> **性質**：`/refactor-audit` 的 **S-final-style drift 校正回路**，里程碑（PRD→SRS 2/67 in-review＋#113~#116 SSOT/健檢）後重對。接續 `drift-recheck-2026-06-17.md`。
> **⚠️ 信度標註（SOURCE=docs-only）**：本次在**規劃 repo** 跑，**workspace 零產品 source**（`*.jsp/*.java/*.ts` glob＝0；legacy＋新碼皆母資料夾-local）。skill 核心「只信碼」的**碼在/UNFOUND 狀態重 grep 此處做不到** → 本報告做兩件 docs 層能做的事：①**獨立重推總量（denominator）**（owner 權威表＝可在 repo 讀，trust-nothing 重數）②對 06-16/06-17 既有產出做 drift 校正。**carried-status 重 grep 仍須 source → 交 Codex（見 §4）。不改 `feature-inventory.md`（report-only）。**

## 1. 主結論：總量（denominator）獨立重推＝**零 drift**，口徑穩定
本次**親自從 owner 權威表**（`docs/legacy/legacy-function-inventory.md`，197 資料列）重數 distinct 新頁，**不引用** `owner-inventory-reconcile.md`/`feature-inventory.md` 的既有數字：

| 類別 | 重數 | 明細（owner 表「對應重構系統頁籤」欄）|
|---|---:|---|
| i0 distinct 新頁 | 11 | `EPROI00110–00120`（行 10–31）|
| ISU distinct 新頁 | 22 | `0110/0120/0130/0140/0150/0160/0170/0171/0172/0173`＋`0180–0184`＋`0910–0913`＋`0920/0921/0922`（行 35–82）|
| c0 distinct 新頁 | 9 | `EPROC00110/00112/00114/00115/00116/00117/00118/00119/00120`（`00111/00113`＝NaN SQL-support，不計；行 106–128）|
| CSU distinct 新頁 | 9 | `EPROCSU0110/0120/0130/0150/0160/0170/0171/0172/0173`（行 130–167）|
| CU 例外新頁 | 1 | `EPROCU0160`（唯一未併入 CSU 的 cu；行 147–148）|
| Z0 distinct 新頁 | 15 | `EPROZ00100/00200/00300/00400/00410/00500/00600/00610/00620/00630/00640/00650/00660/00700/00800`（行 175–190）|
| **小計 distinct 新頁** | **67** | — |
| 舊系統無→新頁 | +1 | `EPROZ00670`（TLOD 查詢，舊無源；行 188）|
| 批次 B001–B008 | +8 | `EPROZ0_B001–B008`（行 194–201）|
| 共用 API | +1 | `EPROZZ_0100`（行 202）|
| **新系統工作單位** | **77** | ＝67 頁＋00670＋8 批次＋1 API |

→ **與 06-16 `owner-inventory-reconcile §1` 完全一致**（77 工作單位；166 audit 列＝其 action／FE+BE 細粒度展開）。**自 06-16 起無新增/刪除工作單位** → Phase G／06-16~17 裁定／**本批 PRD→SRS 與 #113~#116 皆未動 migration 口徑**（spec 軌是替既有 67 頁產 SRS，非新增遷移單位）。

## 2. 兩條「67」對齊（migration target ≡ spec-coverage target）
- migration 頁級 target＝**67 distinct 新頁**（§1）。
- spec 覆蓋 `SRS bundle 2/67`（`per-page-reinventory-matrix.md`）的分母＝**同一批 67 頁**。
- 已產 2 束＝`EPROZ00100`（Z0 15 之一）＋`EPROC00118`（c0 9 之一）→ **皆落在 67 集合內、口徑自洽**。兩軸不同（§1＝碼遷移狀態；§2＝spec 覆蓋狀態），分母同源、不矛盾。

## 3. 06-16 建議回填現況（本次親查 `feature-inventory.md` 確認已落地）
| 06-16 建議（`owner-inventory-reconcile §5`）| 現況 | 證據 |
|---|---|---|
| 關 AUD-1（Property Info 家族已無使用）| ✅ **已關** | `feature-inventory.md:60`「AUD-1 ✅已關（06-16 owner 權威盤點標『已無使用』＝確認不遷）」|
| 新增批次層 8 工作單位（F-OWN-1 最大漏列）| ✅ **已補＋AUD-10 結** | `:141`「批次層 B001–B008｜AUD-10 結（06-16 app 層完整）｜6 FOUND（新批次重編號≠legacy）＋B005 銷案＋B008 ops」|
| CU0160 碼驗（F-OWN-4）| ◑ **碼驗回 UNFOUND、AUD-11 先不關** | `:208` 待裁含 AUD-11；殘 `TB_PAGE_MENU` data＋`:597` ISU0160 分流→DBA(SQL)+RD（`aud11-closeout-dba-rd.md`）|
| 口徑註記（67 頁+8 批次+00670+API＝upstream）| ✅ 已反映 | `:165` zero-based 盤點完成回填；§1/§5 口徑列 |

→ **06-16 兩大 structural 建議（批次層、AUD-1）皆已落地**；唯 CU0160 仍 UNFOUND（結構性需 source，非本 repo 可結）。

## 4. 仍須 source 才能做的（交 Codex；範圍同 06-17 §4，**無變動**）
本批工作（spec 軌＋SSOT/健檢）未觸碰 166 列碼遷移審計 → 06-17 §4 的 carried-status 重 grep 範圍**原樣留存、無新增/收斂**：
- **M4-cs / M5-cu**：Phase G 後 FE 應 UNFOUND→碼在（audit 檔仍記 UNFOUND）。
- **M7-c0**：F-7/F-8 修後 `00114/00119` 狀態重確認。
- **M8-z0**：修復包（`00100/00300/00600/00640/00660/00800`）後多列更新。
- **CU0160（AUD-11）**：`TB_PAGE_MENU` 唯讀 SQL＋`CsuLoanConditionServiceImpl:597` ISU0160 分流＝DBA+RD。
- 方式＝對應 `M*-*.md` 各跑一場 `/refactor-audit` 單模組 session（**帶 source**）→ 更新小計 → 出新 `diff-vs-inventory`。

## 5. 與 06-17 re-check 的關係
- 06-17 的 **16 DIFF 逐項結案/追蹤**分析**仍有效**（本次未推翻任一項）。
- 本次**新增**：①親手獨立重數 denominator（trust-nothing，非引用既有數）→ 證口徑零 drift；②親查確認 06-16 批次層/AUD-1 建議**已落地**（06-17 未明驗此點）；③證 spec 軌 `2/67` 與 migration `67` 同源自洽。
- `master.md` 狀態指標 06-17→**06-19**（chain）。

## DoD（本次 docs 層 re-check）
- ✅ denominator 親手 trust-nothing 重推＝77 工作單位／166 列，與 06-16 零差異；口徑無 drift。
- ✅ 06-16 兩大建議（批次層、AUD-1）落地確認；CU0160 仍 UNFOUND（須 source）。
- ✅ spec `2/67` ↔ migration `67` 同源自洽。
- ⏳ carried-status 重 grep（M4/M5/M7/M8＋CU0160）留 Codex+source——本 repo 結構性做不到（誠實標示，非略過）。
- report-only：未改 `feature-inventory.md`。

> 過了：migration 口徑**截至 2026-06-19 仍 77 工作單位/166 列、零 drift**；spec 軌未污染碼遷移分母；批次層/AUD-1 已收。下次帶 source 重盤直接從 §4 清單起手（範圍同 06-17、未變）。
