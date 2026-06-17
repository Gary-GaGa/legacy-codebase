# Drift Re-check — refactor-audit vs feature-inventory（2026-06-17）

> **性質**：`/refactor-audit` 的 **S-final-style drift 校正回路**，里程碑（#82 merged + Phase G 06-15 + 06-16 owner 裁定輪）後重對。
> **⚠️ 信度降級（SOURCE=docs-only）**：本次在**規劃 repo**跑，**無產品 source**（`legacy-epro/`/`backend/`/`frontend/` 實碼皆在母資料夾、不在本 repo）。skill 核心「只信碼」此處**做不到** → 本報告**只做 docs 層 drift 校正**（既有 audit 產出 ↔ 現 feature-inventory ↔ 06-16 裁定），**不是** code 重 grep。真正的 zero-based 重 grep 需 source → 交 Codex（見 §4）。**不改 `feature-inventory.md`（report-only）。**

## 1. 主結論：`diff-vs-inventory.md`（06-11）已 stale，勿照其 `[ ]` 回填
06-11 audit 的 code-state 快照（116 碼在/37 UNFOUND）**早於 Phase G（06-15）與 06-16 owner 輪** → 其 §4 建議回填多數**已被後續工作蓋過**。**最關鍵**：DIFF-001（企金 CS/CU FE UNFOUND）的建議是「inventory FE ✅→UNFOUND」，但 **Phase G（06-15，audit 之後）實際把那些 FE 建出來了**（G1–G6，`feature-inventory §2B`）。**照 06-11 回填會把 Phase G 的成果反向砍掉＝regression。** inventory 正確地沒套 DIFF-001、而是讓 Phase G 收口。

→ **處置建議**：`diff-vs-inventory.md` + `master.md` 標 `SUPERSEDED by 2026-06-17 re-check（code-state 過期；重 grep 待 Codex+source）`，避免有人誤照其 `[ ]` 回填。

## 2. 16 個 DIFF 現況（docs 層追溯；✅=已被後續解 / ⏳=仍開且已別處追蹤）
| DIFF | 06-11 議題 | 現況 | 證據（feature-inventory / 裁定）|
|---|---|---|---|
| 001 | 企金 CS/CU FE UNFOUND | ✅ **Phase G 建齊**（非降級）| §2B G1–G6 ✅ 06-12~15 |
| 002 | `EPROIS_0240` UNFOUND | ✅ AUD-1 關（確認不遷）| §2A:60、pending ✅ |
| 003 | `EPROIU_0140/0240` UNFOUND | ✅ AUD-1 關 | 同上 |
| 004 | 0920/0921 碼在、0922 🟡 | ✅ 已套 | §2A:57-59、§2F |
| 005 | M6 總量 22 | ✅ 已反映 | §1:30「audit 22 列」|
| 006 | `EPROC00114` FE→🟡 | ✅ 已套 | §2D:101 |
| 007 | `EPROC0_0211/0213` UNFOUND | ⏳ **開＝AUD-2**（待信用評分 domain）| §2D:110、pending AUD-2 |
| 008 | `EPROC00119` FE→🟡 | ✅ F-8 修（`6919da5`，options 接上→✅）| §2D:106 |
| 009 | M7 總量 20 | ✅ 已反映 | §1:31「audit 20 列」|
| 010 | `EPROZ00100` FE→🟡 + popup | ✅ F-10 修（`2599752`）| §2E:116 |
| 011 | `EPROZ00300` 狀態衝突 | ✅ 修 06-15（`40d931c`）| §2E:118、§4④ |
| 012 | `EPROZ00601` popup 漏列 | ✅ 補列 | §2E:122 |
| 013 | `EPROZ00640` PDF BE→🟡 | ✅ PDF blob 修（`c1bda77`）| §2E:126、§4⑩ |
| 014 | `EPROZ00660` endpoint 不符 | ✅ F-12 修（`5a47038`）| §2E:128 |
| 015 | `EPROZ00800` reviseditem FE POST↔BE GET | ◑ **RP9 裁定 GET（06-16）+ get-body #3 卡 ready**（待 Codex 修）| §2E:130、get-body card |
| 016 | M9 `~50` vs 16 頁級 | ✅ 已反映（11 列/頁級 16）+ ⏳ admin/demo＝AUD-3/4 | §1:33、§4⑩ |
| QC-INPUT-UNFOUND | `refactor-audit-qc.md` 缺 | ✅ 現存（F-1~F-12）| `build-tasks/refactor-audit-qc.md` |

**小結**：16 項中 **13 已解（Phase G / 修復包 / AUD 關）**、2 仍開但**已追蹤**（DIFF-007=AUD-2、DIFF-016 admin/demo=AUD-3/4）、1 裁定+派工中（DIFF-015=RP9+get-body#3）。**無遺落、無新隱藏缺口。**

## 3. feature-inventory 內部不一致（1 項，建議回填；本報告不改）
- [x] **AUD-10 狀態自相矛盾** → ✅ **2026-06-17 已回填**：`§1:15` 與 `§4⑩` 現已將 AUD-10 列入「已關（AUD-1/5/6/9/**10** 已關）」、待裁清單收斂為 `AUD-2/3/4/7/8/11`（無 10）→ feature-inventory 三處一致。
  - 〔原狀（保留 audit trail）：`§2F:140` 已記 AUD-10 結（06-16，app 層 6 FOUND + B005 銷案 + B008 ops），但 `§1:15`/`§4⑩` 待裁清單一度仍列 AUD-10；依據＝`§2F:140` + `pending-register`（AUD-10 ✅）+ `decisions.md`（AUD-10 碼驗回）。〕

## 4. 需 source 才能做的（交 Codex，本 repo 做不到）
docs 層校正只能對「狀態表 ↔ 裁定」一致性，**無法重驗碼**。下列模組自 06-11 後有增量改動（inventory `audit 驗證` 欄已 stale）、需 **Codex 帶 source 重 grep** 才能更新 audit 列：
- **M4-cs / M5-cu**：Phase G 後 FE 應從 UNFOUND→碼在（audit 檔仍記 UNFOUND）。`audit 驗證`欄已標「06-11 S4 → 06-15 G1-G6 落地」。
- **M7-c0**：F-7/F-8 修後 00114/00119 狀態應重確認。
- **M8-z0**：修復包（00100/00300/00600/00640/00660/00800）後多列應更新。
- 方式＝對應 `M*-*.md` 各跑一場 `/refactor-audit` 單模組 session（**帶 source**），更新該模組小計 → 再出新 `diff-vs-inventory`。

## 5. 口徑確認（migration 總量）
owner 權威盤點（`owner-inventory-reconcile §1`）＝**67 distinct 新頁 + 8 批次 + `EPROZ00670` + 共用 API**；166 列＝其細粒度（01xx/02xx 變體、action 級）展開。**本次無口徑變動**——Phase G/06-16 是把既有列從 UNFOUND/🟡/🔴 推向碼在，**未新增/刪除工作單位**。

## DoD（本次 docs 層 re-check）
- ✅ 既有 audit 產出 ↔ 現 inventory ↔ 06-16 裁定 三方對齊；16 DIFF 逐項結案/追蹤確認。
- ✅ 抓到 1 內部不一致（AUD-10）+ 標 `diff-vs-inventory` stale。
- ⏳ **code 重 grep（M4/M5/M7/M8）留 Codex+source**——本 repo 結構性做不到（誠實標示，非略過）。
- report-only：未改 `feature-inventory.md`。

> 過了：知道「06-11 audit diff 已過期、勿照套」+ 1 個 inventory 內部不一致待修 + code 重 baseline 的明確 Codex 派工範圍。下次帶 source 重盤直接從 §4 清單起手。
