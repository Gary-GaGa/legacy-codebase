# Per-Page 重新盤點矩陣（disposition: keep / fix / rebuild）— 證據驅動

> **怎麼來的**：owner 考慮「砍掉前後端重來」；分析後選 **A＝逐頁證據驅動**（非 all-or-nothing）。本矩陣＝每頁套 `process/legacy-parity-sop.md`（舊系統為主＋三判）後的 **disposition**，**讓 rebuild 是逐頁的結果、不是前置的賭注**。
> **⚠️ 信度**：parity 欄需 **product code + 舊 source + DB**（母資料夾、remote agent 碰不到）→ 本矩陣＝**scaffold + 已知 seed**；`parity vs 舊` 與最終 `disposition` 多數待 Codex 碼驗填實（派工見 §尾）。
> **基準＝owner 67 頁 + 8 批次**（`owner-inventory-reconcile §1`），**非「回報的 70%」**（那個 done 數已證不可靠：結構在≠行為對）。

## 圖例
**parity vs 舊**：✅已驗對等／🔶部分驗(有已知 delta)／🟡碼在·未對舊驗／❓未對舊·待碼驗／🔴已知不對等
**disposition**（套 SOP 三判）：**KEEP**(parity 過)／**FIX**(delta 可修·保留水管)／**REBUILD**(重寫該頁)／**❓**(待 parity 定·含 rebuild 候選)／**去留**(owner 裁遷不遷)／**⏸**(暫緩 track)
**SRS**：✅有／⟳需產(PRD→SRS)／N/A

## 🔑 矩陣浮現的三個結論（先看這個）
1. **確定 REBUILD 的只有 1 頁＝`EPROZ00800`**（本就標砍掉重建、Bible/PRD 更新中）。其餘**無一頁有「該重建」的證據** → **wholesale 砍掉重來不被資料支持**。
2. **最大系統性風險＝企金線**（CSU 主流程 9 + c0 評分 9 ＝ 18 頁）：**多由「鏡像個金 ISU/i0 twin」建、未對舊企金 cs/cu 行為驗** → 這 18 頁是 **parity-recheck 的重點**（結果再定 fix vs rebuild）。c0 reopen 已啟動，**CSU 主流程同病、應一併納**。
3. **其餘多是 FIX/KEEP**（撥貸在修、z0 多已修、i0/deputy 較穩）+ 幾項 **owner 去留**（M9 admin/demo、AUD-2/7/8）。

---

## T1 — 金錢 / checkpoint / T24 / 授權（最高風險，先比）

### 撥貸 + T24 + 批次
| 頁/單位 | 舊對應 | FE/BE | parity vs 舊 | disposition | SRS |
|---|---|---|---|---|---|
| EPROISU0920 Disbursement(頁框) | IS 0920 | ✅/✅ | 🟡 | **FIX**(domain-gated) | ⟳需產 |
| EPROISU0921 Data Input | IS 0921 | ✅/✅ | 🔶(7P/15F/5U;A-4/M6/Product/Return/collproSize closed) | **FIX**(SRS in-review) | `docs/specs/srs/EPROISU0921/` |
| EPROISU0922 Summary/T24 | IS 0922 | ✅/🟡 | 🔶(A-1✅·B-1 開) | **FIX**+UAT | ⟳需產 |
| T24 組檔(A–H) | createTransferA–H | —/✅ | 🔶(B-group 照舊修畢) | **FIX done**+UAT | ⟳需產 |
| 批次 B001–B008 | `EPROZ0_B00x` | —/✅ | 🟡(AUD-10:6 FOUND·B005 inline·B008 ops) | **KEEP**(碼驗過)；B008 ops | N/A |
> 撥貸**無 rebuild 候選**：全 FIX/KEEP + UAT。殘 domain A-4/M6/B-1/G·H 已 06-17 全裁照舊→Codex 收尾。

### c0 評分線（🔑 parity-recheck 重點；reopen）
| 頁 | 舊對應 | FE/BE | parity vs 舊 | disposition | SRS |
|---|---|---|---|---|---|
| EPROC00110 容器 | c0 0110 | ✅/✅ | ❓未對舊企金驗 | **❓**(c0-parity 卡) | ⟳需產 |
| EPROC00112 CBC | c0 0112 | ✅/✅ | ❓ | **❓** | ⟳需產 |
| EPROC00114 Collateral Assess | c0 0114 | 🟡/✅ | ❓(grandfathered §6.1) | **❓** | ⟳需產 |
| EPROC00115 Group Exposure | c0 0115 | ✅/✅ | ❓ | **❓** | ⟳需產 |
| EPROC00116 FinStmt GI | c0 0116 | ✅/✅ | ❓(有 calc) | **❓** | ⟳需產 |
| EPROC00117 FinEval GI | c0 0117 | ✅/✅ | 🔶(business-only 對舊驗畢·決策B) | **KEEP/FIX** | ⟳需產 |
| **EPROC00118 Corporate Scorecard** | c0 0118 | ✅/✅ | ❓(對舊未驗；E1/E2＝既有 Csu* 行為待裁、非本頁缺陷) | **❓**(T1·E1/E2 合流) | ⟳需產(全清重跑) |
| EPROC00119 FinStmt FI | c0 0119 | ✅/✅ | ❓(F-8 修過) | **❓** | ⟳需產 |
| **EPROC00120 FinEval FI** | c0 0120 | ✅/✅ | 🔶(business-only·金錢欄) | **❓**(T1) | ⟳需產 |
> 全線 **❓ parity-gated**（卡 `c0-legacy-parity-recheck.md`，risk-tier 00118/00120/CSU0170 先）；00117/00120 已部分對舊（決策 B）較穩。

### 00800 + deputy
| 頁 | 舊對應 | FE/BE | parity vs 舊 | disposition | SRS |
|---|---|---|---|---|---|
| **EPROZ00800 Revised Item** | z0 0800 | 🟡/✅ | 🔶(RP8/11) | **REBUILD**(v0.9 SRS 已封存 `archive/EPROZ00800-v0.9-superseded/`、待新 PRD 重產) | v0.9 封存→待重產 |
| EPROZ00700 Assign Substitute | z0 0700 | ✅/✅ | ✅(PK reverify·AUD-9) | **KEEP**(=golden `deputy`) | N/A |

---

## T2 — 企金/個金主流程 + i0 評分（行為/案件編輯）

### CSU 企金主流程（🔑 與 c0 同病：鏡像 ISU twin、未對舊 cs/cu 驗）
| 頁 | 舊對應 | FE/BE | parity vs 舊 | disposition | SRS |
|---|---|---|---|---|---|
| EPROCSU0110–0130 | cs/cu 0110–0130 | ✅/✅ | 🟡(鏡像 twin·未對舊驗) | **❓**(納 parity-recheck) | ⟳需產 |
| EPROCSU0150 Collateral | cs 0150+0250 | ✅/✅ | 🟡(Phase G·照舊 cs 結構) | **❓** | ⟳需產 |
| EPROCSU0160 Loan Condition(+0261) | cs/cu 0160+0260 | ✅/✅ | 🟡(+AUD-11 routing 待證) | **❓** | ⟳需產 |
| EPROCSU0170–0173 | cs/cu 0170–0173 | ✅/✅ | 🟡(Phase G 鏡像 ISU) | **❓** | ⟳需產 |
> **建議**：把 CSU 主流程**併入 c0-parity 同一波**（企金線整體對舊 cs/cu 驗）——目前只 reopen 了 c0 評分，主流程同樣未對舊。

### ISU 個金主流程
| 頁 | 舊對應 | FE/BE | parity vs 舊 | disposition | SRS |
|---|---|---|---|---|---|
| EPROISU0110–0173 | is/iu 01xx+02xx | ✅/✅ | 🟡(碼在待整合驗) | **❓→多 KEEP/FIX** | ⟳需產 |
| EPROISU0910–0913 Contract | is 091x | ✅/✅ | 🟡 | **KEEP/FIX** | ⟳需產 |
| EPROISU0181 TLOD/CAD | is 0181 | ⏸/⏸ | — | **⏸**(R2 報表) | ⏸ |

### i0 個金評分
| 頁 | 舊對應 | FE/BE | parity vs 舊 | disposition | SRS |
|---|---|---|---|---|---|
| EPROI00110–00120(11 頁) | is/iu 01xx/02xx | ✅/✅ | 🟡(audit 22/22 完整·對舊行為未專驗) | **❓→多 KEEP** | ⟳需產 |
> i0 是 c0 的鏡像源 → i0 對舊驗清楚，c0 parity 才有乾淨基準。i0 較穩但「完整 ≠ 對舊行為」仍適用。

---

## T3 — z0 共用 / 查詢 / 報表
| 頁 | parity vs 舊 | disposition | SRS | 備註 |
|---|---|---|---|---|
| EPROZ00100 TODO(+101/102) | 🔶(RV-2/langType 修+筆數驗) | **FIX done/KEEP** | ⟳需產(全清重跑) | langType 回歸守門 |
| EPROZ00200 New Case | 🟡 | KEEP/FIX | ⟳需產 | 案號序列未深入 |
| EPROZ00300 Doc Checklist | 🔶(導回修 06-15) | FIX done/KEEP | ⟳需產 | Phase V 驗 goPreviousPage |
| EPROZ00400/00410/00500 | 🟡(cross-check ✅) | KEEP | ⟳需產 | |
| EPROZ00600 Search(+601) | 🔶(RV-1/get-body 修) | FIX done/KEEP | ⟳需產 | |
| EPROZ00610–00650 報表群 | 🟡 | KEEP/FIX | ⟳需產 | 00640 PDF Phase V 實測；含 R2 依賴 |
| EPROZ00660 CAD On Hand | 🔶(F-12 修) | FIX done | ⟳需產 | |
> z0 多是「已修+待 Phase V 跑」→ KEEP/FIX，**無 rebuild 候選**（除 00800）。

---

## T4 — admin / demo / 暫緩（owner 去留，非 parity）
| 項 | 待決 | disposition |
|---|---|---|
| M9 admin（SysNews/BatchManager/cacheMonitor）| AUD-3 遷不遷 | **去留**(PM/ops) |
| demo（DEMOA0_*）| AUD-4 不遷 | **去留**(PM，傾向不遷) |
| AUD-2（c0 0211/0213 展期）| 是否 00116-00120 涵蓋 | **去留**(信用評分 domain) |
| AUD-7（54 表去留）/ AUD-8（new02 權限表）| schema 差異 | **去留**(SA/DBA) |
| R2 報表服務 / 檔案上傳 API | track 未定 | **⏸** |

---

## 統計（disposition 分佈，seed 後）
| disposition | 數 | 說明 |
|---|---|---|
| **REBUILD** | **1** | 00800（已確定，Bible/PRD 更新中）|
| **❓ parity-gated（rebuild 候選）** | **~18** | 企金線 CSU 主流程 9 + c0 評分 9（對舊未驗）|
| **FIX / KEEP** | **大宗** | 撥貸、z0、ISU 主流程、i0、deputy、批次 |
| **去留 / ⏸** | 數項 | M9/AUD-2/7/8、R2/檔案 API |
> **意涵**：要「全砍重來」需這 ~18 的 parity 回來多數判 rebuild；目前**證據不支持**。先把企金線對舊驗清楚，再定那 18 頁各自 fix vs rebuild。

---

## PRD→SRS backlog（接「新版 Bible/PRD 跑 to SRS」）
> Current repo SRS coverage = **5/67** (`EPROZ00100` + `EPROC00118` approved after RD/DBA contract closeout on 2026-06-20; `EPROISU0921` + `EPROISU0922` approved 2026-06-23; `EPROZ00800` regenerated from v0.9 and approved 2026-06-23 after R7 `reason.item` page-column backfill + closeout re-run PASS; all bundles pass `check-srs-bundle`). Coverage counting remains defined by the PRD-to-SRS queue + ledger table below.
> **⚠️ 新版 PRD 放 `docs/specs/prd/` 或 local Codex 讀才跑得了**——Bible v1.1 已在 repo、舊 00800 PRD 已封存 `archive/`；DB/refactor 對比輸入＝local `docs/db-diff/`+`docs/refactor-spec/`。
> **risk-tier 產 SRS 順序**（= rebuild/fix 最需規格者先）：
> 1. **企金線**（CSU 主流程 + c0 評分，~18 頁）—— parity 回來若判 rebuild，立即需 SRS。
> 2. **撥貸**（0920/0921/0922 + T24 + 批次）—— 金錢核心，目前只有 escalations/triage、無 SRS。
> 3. **00800 重產**（用新版 PRD 取代 v0.9）。
> 4. 主流程 ISU / i0 / z0 —— 多 KEEP/FIX，SRS 可隨 parity 結果增量補。
> 每產一份過 `check-srs-bundle`（含 gateⓇ）+ **SRS N 軸驗證**（`orchestration-playbook §4b`）（DoD）。

### PRD→SRS 佇列 + ledger（orchestrator 機械迭代來源；2026-06-18）
> **orchestrator 的 enumerable 來源 + 完成 ledger**（SRS 軌迴圈＝`orchestration-playbook §5b/§6b`，非 `STATUS §六`＝code 板）：依 risk 排序，**drain 模式（2026-06-20）**＝只要本表還有 `status=prd-ready` 列（可多頁），就取最前一頁產 SRS、**序列逐頁**過 gate＋N 軸→**每產一份即回填本表 `status=in-review`/`srs`（防重複/防漏）→ 接下一個 `prd-ready`**，直到 `prd-ready` 全清才停（batch checkpoint）；**終點 `in-review`、升 `approved` 仍須人裁 TBD**（orchestrator 不自升）。單頁 FAIL → **`status=blocked`+原因**（離開 prd-ready 集合，避免被重取＝無窮迴圈）、續跑下一頁；`blocked` 頁待修/裁後重標 `prd-ready` 再進下一批。〔終止保證：每輪一頁必轉 in-review 或 blocked，|prd-ready| 嚴格遞減。〕**覆蓋計數**：分子＝本表 `status∈{in-review,approved}` 列**所涵蓋的頁數**（bundle/佔位列展開計頁、**非列數**）；分母 **67＝`docs/legacy/legacy-function-inventory.md` 權威盤點**（非由本表衍生）；上方 §覆蓋「x/67」＝此計數的人類快照、改動時與本表同步（**單一出處＝本表**）。同 risk tier 內 tie-break＝**表序由上而下**（已照 dispatch:5 / `c0-legacy-parity-recheck` T1 序）；`approved` 由人審/裁 TBD 後回填（orchestrator 只到 `in-review`）。
> status：`not-started`｜`prd-ready`（PRD 快照已放 `docs/specs/prd/`、檔名 `PRD-*<funcId>*.md`）｜`in-review`（SRS 產出＋機械 gate＋N 軸 PASS、待人審/裁 TBD）｜`blocked`（本批未達標：gate FAIL 或 N 軸殘 Blocker 需 C 類；標原因、退出本批 drain；owner 修/裁後重標 `prd-ready` 再跑）｜`approved`（TBD 全關、N 軸無 Blocker、人裁）。

| funcId | risk | prd（`docs/specs/prd/`）| status | srs（`docs/specs/srs/`）|
|---|---|---|---|---|
| `EPROZ00100` | z0 shared | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md` | approved | `docs/specs/srs/EPROZ00100/` |
| `EPROC00118` | T1 corporate | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00118-v1.0.md` | approved | `docs/specs/srs/EPROC00118/` |
| `EPROC00120` | T1 企金線(先) | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00120-v1.0.md` | in-review | `docs/specs/srs/EPROC00120/` |
| `EPROCSU0170` | T1 企金線(先) | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROCSU0170-v1.0.md` | prd-ready | 待 parity 碼驗餵入 |
| `EPROC00110` | T1 企金線 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00110-v1.0.md` | in-review | `docs/specs/srs/EPROC00110/` |
| `EPROC00112` | T1 企金線 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00112-v1.0.md` | in-review | `docs/specs/srs/EPROC00112/` |
| `EPROC00114` | T1 企金線 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00114-v1.0.md` | in-review | `docs/specs/srs/EPROC00114/` |
| `EPROC00115` | T1 企金線 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00115-v1.0.md` | in-review | `docs/specs/srs/EPROC00115/` |
| `EPROC00116` | T1 企金線 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00116-v1.0.md` | in-review | `docs/specs/srs/EPROC00116/` |
| `EPROC00117` | T1 企金線 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00117-v1.0.md` | prd-ready | 待 parity 碼驗餵入(business-only·較穩) |
| `EPROC00119` | T1 企金線 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROC00119-v1.0.md` | prd-ready | 待 parity 碼驗餵入(i0-mirror·無 refactor baseline) |
| `EPROCSU0110` | T2 企金線 | — | not-started | 待 parity 碼驗餵入 |
| `EPROCSU0120` | T2 企金線 | — | not-started | 待 parity 碼驗餵入 |
| `EPROCSU0130` | T2 企金線 | — | not-started | 待 parity 碼驗餵入 |
| `EPROCSU0150` | T2 企金線 | — | not-started | 待 parity 碼驗餵入 |
| `EPROCSU0160` | T2 企金線 | — | not-started | 待 parity 碼驗餵入(+AUD-11 routing) |
| `EPROCSU0171` | T2 企金線 | — | not-started | 待 parity 碼驗餵入 |
| `EPROCSU0172` | T2 企金線 | — | not-started | 待 parity 碼驗餵入 |
| `EPROCSU0173` | T2 企金線 | — | not-started | 待 parity 碼驗餵入 |
| `EPROISU0920` | 撥貸 T1 | — | not-started | 差異源已備(triage/db-diff)·只缺 PRD |
| `EPROISU0921` | 撥貸 T1 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md` | Approved (2026-06-23) | `docs/specs/srs/EPROISU0921/` |
| `EPROISU0922`(+T24) | 撥貸 T1 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROISU0922-v1.0.md` | Approved (2026-06-23) | `docs/specs/srs/EPROISU0922/` |
| `EPROZ00800` | 00800 重產 | `docs/specs/prd/PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md`| Approved (2026-06-23) | `docs/specs/srs/EPROZ00800/` |
| 主流程 ISU/i0/z0 增量 | 增量 | — | not-started（佔位·待拆列）| — |
> ⚠️ 一頁一列、funcId 不重複；新頁 PRD 放進來→該列 `status=prd-ready`+填 `prd`。**2026-06-20 回填**：決策頁（企金線 18 + 撥貸 3 + 00800 ≈22，＝有未決差異需 owner 裁者）已**拆成逐 funcId 列**（規劃展開視圖已歸檔＝`docs/archive/srs-production-queue-2026-06-20.md`，2026-06-20 快照；本 ledger 為 live SSOT），含各頁「要餵的輸入」，仍 `not-started`（待 PRD 才升 `prd-ready`；orchestrator 只 pick `prd-ready`，故 not-started 列不影響迭代）。**僅剩 `主流程 ISU/i0/z0 增量`＝佔位**（KEEP/增量、無待裁差異、非派工單位，隨 PRD 進場再拆）。完整 67 頁清單＝owner 權威盤點 `docs/legacy/legacy-function-inventory.md`。⚠️ 企金線各列 `prd-ready` 前須先有 `c0-legacy-parity-recheck` 碼驗結果餵入 as-is parity 軸，否則 SRS 漏載對舊 cs/cu 差異。

## 派工（填實本矩陣）
- **企金線對舊 parity**（Codex 帶 source）：擴 `c0-legacy-parity-recheck.md` 涵蓋範圍 → c0 評分 **+ CSU 主流程**；risk-tier 00118/00120/0170 先。
- **M4/M5/M7 重 grep**（drift-recheck §4）：順帶填 CSU/c0 的 parity 欄。
- **新版 Bible/PRD → SRS**：owner 提供後，按上方 risk-tier 跑 `prd-to-srs`（**規模化前先跑 pilot＝`prd-to-srs-orchestrator-pilot.md` 一頁**，過了再批量；orchestrator 迴圈見 `orchestration-playbook §5b/§6b`）。
- 結果回填本矩陣 `parity vs 舊` + `disposition` 兩欄 → 逐頁定 keep/fix/rebuild。

> 過了：每頁有了「對舊 parity + disposition + 需不需 SRS」三件事 → **rebuild 變逐頁證據結果**，wholesale 與否由矩陣統計自然回答。
