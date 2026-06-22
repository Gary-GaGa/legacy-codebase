# 專案分析決策簡報（2026-06-20）

> **性質**：一次性分析快照 / decision brief（衍生視圖，非 SSOT）。權威狀態仍以 `STATUS.md`、`feature-inventory.md`、`pending-register.md`、`build-tasks/refactor-audit/per-page-reinventory-matrix.md` 為準。
> **方法**：讀 SSOT 三件套 + 多 agent 獨立查核（規格層 / 任務卡盤點 / 瓶頸與待決），交叉驗證後統整。
> **用途**：給 owner 一眼看「目標、進度、卡在誰、該決定什麼」，並承載一個明確的範圍決策建議（SRS 不該追全量 67）。

---

## 一、專案是什麼

規劃/規格 repo（**無原始碼**；`frontend/`、`backend/` 僅有 `AGENTS.md`）。實際前後端在各自 product repo，由 Codex 在母資料夾執行。本 repo 跑 spec 工作流 `Legacy→Bible→PRD→SRS→QA→RD`，目標＝把舊 eProposal（~250 JSP / 9 模組 M1–M9）遷移到 **Angular + Spring Boot**。

⚠️ **含義**：任何需要 product code / 舊 source / DB 的工作（parity 碼驗、Phase V runtime、撥貸執行）**無法在本 remote repo 跑**，必須在母資料夾以 Codex 進行。

---

## 二、進度雙軸（核心落差）

| 軸 | 進度 | 來源 |
|---|---|---|
| **程式遷移（碼在）** | **~80%**（133/166 audit 列）；FE 補建 100% 收口 | `feature-inventory §1`、`drift-recheck-2026-06-19`（drift＝零） |
| **PRD→SRS 規格層** | **2/67 Approved**（`EPROZ00100`、`EPROC00118`，06-20 contract closeout 後雙軸 Approved） | `per-page-reinventory-matrix §ledger`、`decisions.md:68` |

獨立查核結論：SSOT 三件套高度自洽，**「主線無紅色 owner-decision blocker」屬實**；數字可信。

---

## 三、撥貸（原唯一真缺口）→ 已從「決策」轉「執行」

- ✅ A-1 換匯 stub 已實作 + conformance 4/4 PASS（`daae4c3`）
- ✅ T24 B-group parity fix 已 commit/push（`3d6f446`，金錢欄人審過）
- ✅ 批次層 AUD-10 結；殘 domain（A-4/M6/B-1/G·H）06-17 owner **全裁「照舊系統」**
- 🔵 剩：T24 端到端 / UAT + Codex 收尾執行（非 owner 決策）

---

## 四、真正瓶頸（卡在誰，非卡在決策）

1. **🔧 ops 未套 `c0-authz-sql`（OVSLXLON02）** ← **最高槓桿單點**。未套 → c0/csu endpoint 全 403 → Phase V smoke V-2~V-6 全卡（runtime 驗證僅 ~25%）。
2. **🟡 企金線 18 頁 parity 補比**（CSU 主流程 9 + c0 評分 9）：鏡像個金 i0/ISU 建、**從未對舊企金 cs/cu 比過** → 最大潛在行為分歧風險。卡 `c0-legacy-parity-recheck.md`（需 Codex 帶 source 跑）。
3. **🟡 待 owner 裁定的單頁項**（皆不擋主線）：c0 E1/E2、AUD-2/3/4/7/8、AUD-11。派工卡皆已存在於 `build-tasks/`。

---

## 五、SRS「2/67」範圍決策（本簡報重點）

### 「67」是什麼
67 = 去重合併（IS+IU→ISU、CS+CU→CSU）後**可遷移的獨立新頁 funcId 總數**，權威清單＝`legacy/legacy-function-inventory.md`，覆蓋計數 SSOT＝矩陣 ledger。**已排除**批次層 B001–B008、無源頁 EPROZ00670、共用 API（故 `drift-recheck` 的工作單位 77 = 67 + 8 批次 + 1 無源 + 1 shared）。**67 ≠ audit 的 166 列**（後者是 FE/BE/action 展開的細粒度，服務遷移軸；67 是頁粒度，服務規格軸）。

### 建議：不要追全量 67，只追風險頁（~25 頁）
這是 brownfield（碼已 ~80% 在），**SRS 是回溯補規格、程式不靠它出貨**。SRS 的價值依頁 disposition 而定：

| 類別 | 頁數 | 要不要 SRS | 理由 |
|---|---|---|---|
| REBUILD | 1（00800） | **必須** | 重寫上游 |
| ❓ parity-gated | ~18（企金線） | **高價值** | 若 parity 判 rebuild 立即需 |
| 撥貸金錢核心 | ~6 | **高價值** | 目前無正式規格、金錢風險最高 |
| FIX / KEEP | 40+（ISU/i0/z0/deputy） | **低優先（增量）** | 已修+待 Phase V；SRS 屬文件價值、非關鍵路徑 |

**真正需要 SRS ≈ 25 頁**，不是 67。把 KPI 設成 67/67 會把大量低價值文件工作排進關鍵路徑。建議將 SRS 範圍重新定義為「REBUILD + parity-gated + 撥貸 ≈ 25 頁」，其餘列為獨立增量 track、不擋遷移上線。

### 兩個節流點
- **Phase S 卡在 owner 供 PRD**：本 repo 只有 Bible v1.1；PRD 需 PM 產並放入 `docs/specs/prd/` 或母資料夾，Claude 無法自產 → SRS 吞吐量受 owner 出 PRD 速度決定。
- **企金線 SRS 應等 parity 結果**：那 18 頁 disposition 仍是 `❓`；**先 parity、後 SRS**，否則可能為「其實 KEEP 的頁」白產規格。

---

## 六、建議下一步（依槓桿排序）

1. **催 ops 套 `c0-authz-sql`（OVSLXLON02）** — 一動解鎖整個 Phase V。
2. **Codex 在母資料夾跑企金線 18 頁 parity 補比**（`c0-legacy-parity-recheck.md`，risk-tier 00118/00120/0170 先）— 同時定 rebuild 範圍與真正要產的 SRS 頁。
3. **重新定義 SRS 範圍為 ~25 風險頁**，撥貸/企金線優先；KEEP/FIX 頁列增量。
4. owner 並行裁定：c0 E1/E2、AUD-2/3/4/7/8、AUD-11（DBA/RD）。

> **本 remote repo 能做的**：審查 / 記帳 / 盤點統整 / 出派工 prompt。
> **本 remote repo 不能做的**：parity 碼驗、Phase V runtime、撥貸執行、ops 套 SQL、owner domain 裁定 — 皆需母資料夾或對應角色。
