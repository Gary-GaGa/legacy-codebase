# SRS 產出佇列 — 決策頁清單 + 各頁輸入需求（2026-06-20）

> **性質**：衍生規劃視圖（非 SSOT）。覆蓋計數權威＝`refactor-audit/per-page-reinventory-matrix.md §ledger`；67 頁全清單＝`legacy/legacy-function-inventory.md`。
> **為何有這張**：owner 的決策模型＝**「先產出 SRS、才能裁差異」**——SRS bundle 的 reconcile delta 段 + N 軸 as-is parity 軸會把每個「對舊系統的差異」變成 `@PENDING`，owner 對著它套 `legacy-parity-sop` 三判（照舊修回／keep 演進／DB 對齊）。沒有 SRS＝沒有乾淨的差異決策面。
> **範圍**：只列「**有未決差異需要 owner 裁**」的頁（≈22）。已驗 parity 對等的 KEEP 頁（i0/deputy/多數 z0）無差異可裁 → 不在本佇列，SRS 屬增量文件、隨後補。

---

## 一、決策頁集合（≈22 頁）怎麼來的

| 類別 | 頁數 | 為何需要 SRS（差異決策面）|
|---|---|---|
| **REBUILD** | 1（`EPROZ00800`）| 重寫，SRS＝重建上游 |
| **parity-gated 企金線** | 18（c0 評分 9 + CSU 主流程 9）| 鏡像個金 i0/ISU 建、**從未對舊企金 cs/cu 碼比** → 差異未現形、未裁 |
| **撥貸金錢核心** | 3（`EPROISU0920/0921/0922`，T24 併入 0922）| 目前只有 escalation/triage、無正式規格 → owner 無乾淨決策面 |

> KEEP/FIX-done 頁（撥貸批次層、z0 已修群、ISU/i0/deputy）**不在本佇列**：差異已驗對等或已修裁畢，無待裁差異。

---

## 二、SRS 產出佇列（逐頁輸入需求）

> **status** 對齊 matrix ledger：`not-started`｜`prd-ready`（PRD 已放 `docs/specs/prd/`）｜`in-review`（SRS 產出+gate+N 軸 PASS）｜`approved`。
> **要餵的輸入**＝產出帶實質差異的 SRS 之前，該頁還缺什麼。

### 撥貸（差異輸入已備，**最快能產出帶差異的 SRS**）
| funcId | disposition | SRS 現況 | 要餵的輸入 | 卡在誰 |
|---|---|---|---|---|
| `EPROISU0920` | FIX(domain-gated) | 無 | **PRD** | owner 出 PRD |
| `EPROISU0921` | FIX(A-4 已裁照舊) | 無 | **PRD**（差異源：escalation/triage/db-diff 已備；A-4/M6/B-1/G·H 已裁照舊→入 SRS 當已決 delta）| owner 出 PRD |
| `EPROISU0922`(+T24) | FIX+UAT | 無 | **PRD**（A-1✅、T24 B-group 照舊✅、B-1 接值待 RD）| owner 出 PRD |

### 00800 重產（差異輸入已備）
| funcId | disposition | SRS 現況 | 要餵的輸入 | 卡在誰 |
|---|---|---|---|---|
| `EPROZ00800` | REBUILD | v0.9 封存 `archive/` | **新版 PRD**（Bible v1.1 已承載 BP-1~5；v0.9 RP1-10/SR-B1/B2/RP8/RP11 為重產輸入）| owner 出新 PRD |

### 企金線 18 頁（差異輸入**不足**，需先補 parity 碼驗）
> ⚠️ **關鍵**：光跑 `prd-to-srs`（比 refactor-spec 70% baseline + db-diff）**抓不到**這 18 頁的核心差異——它們的問題是「對舊 cs/cu 未驗」。必須讓 `c0-legacy-parity-recheck.md`（Codex 帶 source 碼驗）的結果**餵進 SRS 的 as-is parity 軸**，產出的 SRS 才會把對舊企金的分歧列成 `@PENDING` 給 owner 裁。
> ⚠️ `refactor-spec` 缺 `EPROC00119/00120` baseline（`decisions.md:54`）→ 這兩頁走 i0-mirror + parity。

| funcId | disposition | SRS 現況 | 要餵的輸入 | 卡在誰 |
|---|---|---|---|---|
| `EPROC00118` Corporate Scorecard | ❓(T1·E1/E2 合流) | **✅ Approved** | parity 碼驗 + E1/E2 裁定 → 補後續 `@PENDING` | 信用決策 domain |
| `EPROC00120` FinEval FI | ❓(T1·金錢欄) | 無 | **PRD + parity 碼驗**（i0-mirror，無 refactor baseline）| owner PRD + Codex parity |
| `EPROCSU0170` Credit Eval | ❓ | 無 | **PRD + parity 碼驗** | owner PRD + Codex parity |
| `EPROC00110/112/114/115/116/117/119` | ❓ parity-gated | 無 | **PRD + parity 碼驗** | owner PRD + Codex parity |
| `EPROCSU0110/0120/0130/0150/0160/0171/0172/0173` | ❓ parity-gated | 無 | **PRD + parity 碼驗**（0160 另含 AUD-11 routing 待證）| owner PRD + Codex parity |

---

## 三、產出順序建議（兩個視角的張力 + 我的取捨）

- **最高風險視角**（matrix risk-tier）＝企金線 → 撥貸 → 00800。
- **最快能產出「帶實質差異」SRS 視角**＝撥貸 / 00800（差異輸入已備，只缺 PRD）→ 企金線（還需 parity 碼驗才有差異內容）。

**建議取捨**：
1. **先 pilot 一頁走通**（risk 最高且差異輸入相對完整）＝`EPROC00118` 的後續（已 Approved，補 E1/E2 + parity 碼驗的 `@PENDING`）或 `EPROC00120`（金錢欄、i0-mirror）。
2. **撥貸 3 頁**緊接（差異已裁照舊、SRS 主要formalize → owner 裁量小、產出快、金錢風險高值得正式化）。
3. **企金線其餘**：**並行啟動 `c0-legacy-parity-recheck` 碼驗**（這是企金線 SRS 有意義的前置），碼驗結果回填後再逐頁產 SRS。
4. **00800 重產**：待 owner 出新版 PRD。

---

## 四、兩個共同節流點（都需 owner 端供，本 remote repo 無法自產）

1. **PRD（全部頁通用）**：本 repo 只有 Bible v1.1；PRD 由 PM 產、放 `docs/specs/prd/`（檔名 `PRD-*<funcId>*.md`）或母資料夾 → Codex 才跑得動 `prd-to-srs`。**SRS 吞吐量 = owner 出 PRD 速度**。
2. **企金線 18 頁的對舊 parity 碼驗**：需母資料夾 Codex 帶 source 跑（本 repo 無原始碼）。**不先做，企金線 SRS 會漏掉正是 owner 最想裁的那些差異**。

---

## 五、對接 matrix ledger

本佇列 = matrix ledger（`per-page-reinventory-matrix §ledger`）的**展開規劃視圖**。
- **✅ 2026-06-20 已回填**：本佇列 ≈22 決策頁已拆成逐 funcId 列寫進 matrix ledger（risk-ordered、`not-started`）。僅 `主流程 ISU/i0/z0 增量` 仍為佔位（KEEP/增量、無待裁差異）。
- 每當 owner 把某頁 PRD 放進 `docs/specs/prd/` → 該 funcId 在 **matrix ledger 升 `prd-ready` + 填 `prd` 欄**（orchestrator 只 pick `prd-ready`，故 not-started 列不影響迭代、無 churn）。
- **ledger 仍是覆蓋計數與 orchestrator 的單一出處**；本佇列＝該 ledger 的「各頁輸入需求」註解視圖。
- 規模化前先跑 `prd-to-srs-orchestrator-pilot.md` 一頁，過了再批量（`orchestration-playbook §5b/§6b`）。

---

## 六、PRD 作清單（execution；給 PM/owner）

> **要產的 PRD ＝下表 funcId**（00100/00118 已有 PRD+SRS，不在內）。每份 PRD 作完→放 `docs/specs/prd/`→matrix ledger 該列升 `prd-ready`→orchestrator(母資料夾 Codex) drain。
> **檔名規約**＝`PRD-CDC-EPRO-0001-<funcId>-v1.0.md`（同既有 `PRD-CDC-EPRO-0001-EPROZ00100-v1.0.md`）。
> **PRD 內容預檢**（讓閘門接得上，完整見 `build-tasks/prd-to-srs-codex-dispatch.md §PRD 內容格式預檢`）：① 檔名含 funcId ② 錯誤碼用 `MSG_*`/`COMMON_MSG_*`（裸名 gateⒺ 抓不到）③ §DB 影響矩陣列實表名 `TB_*`+module_code/端點 ④ REQ 用 `REQ-NNN` ⑤ TBD 列表＋owner ⑥ maxlength/必要能給就給 ⑦ 附該頁 as-is findings 路徑。
> **分批鐵則**（circuit-breaker，§drain 卡）：**首批 ≤5 頁、同 risk-tier**；T1 一律全 A–G N 軸、不為吞吐降軸；一批 drain 完人審過再放下一批。

### Batch 1（建議先做：輸入已備、無 parity 前置）— 4 份
| 順 | funcId | PRD 檔名 | 差異輸入來源（作 PRD 時引）| 備註 |
|---|---|---|---|---|
| 1 | `EPROISU0921` | `PRD-CDC-EPRO-0001-EPROISU0921-v1.0.md` | `disbursement-triage.md`/`disbursement-domain-escalations.md`（A-4 已裁照舊）+db-diff | 撥貸 Data Input |
| 2 | `EPROISU0922` | `PRD-CDC-EPRO-0001-EPROISU0922-v1.0.md` | 同上（A-1✅/T24 照舊✅/B-1 接值）+T24 組檔 | 撥貸 Summary/T24 |
| 3 | `EPROISU0920` | `PRD-CDC-EPRO-0001-EPROISU0920-v1.0.md` | 同上（頁框，domain-gated）| 撥貸 Process |
| 4 | `EPROZ00800` | `PRD-CDC-EPRO-0001-EPROZ00800-v1.0.md` | Bible v1.1 BR-014~017/SC-002~005 + 封存 `archive/EPROZ00800-v0.9-superseded/`（RP1-10/SR-B1/B2/RP8/RP11 為輸入）| REBUILD、新版 PRD 取代 v0.9 |

### Batch 2+（企金線；**每份 PRD 前須先有該頁 `c0-legacy-parity-recheck` 碼驗 findings** 餵 as-is）— 17 份
> risk-tier 先：`EPROC00120`、`EPROCSU0170`（00118 已有 SRS，其 parity 為 follow-up、非新 PRD）。**每批 ≤5、同 tier**。
| tier | funcId（PRD 檔名同規約）| parity 前置 |
|---|---|---|
| T1 企金線(先) | `EPROC00120`、`EPROCSU0170` | 需 parity 碼驗（00120 i0-mirror·無 refactor baseline）|
| T1 企金線 c0 | `EPROC00110`/`00112`/`00114`/`00115`/`00116`/`00117`/`00119` | 需 parity 碼驗（00119 i0-mirror）|
| T2 企金線 CSU | `EPROCSU0110`/`0120`/`0130`/`0150`/`0160`/`0171`/`0172`/`0173` | 需 parity 碼驗（0160 另含 AUD-11 routing）|

> 增量 KEEP 頁（ISU/i0/z0 多數）＝**無待裁差異、暫不需 PRD**；要補純文件 SRS 時再隨增量 track 拆列。
> **00118 follow-up**（已有 SRS）：E1/E2 + parity 碼驗結果以**新 @PENDING** 補進既有 bundle，非重作 PRD。
