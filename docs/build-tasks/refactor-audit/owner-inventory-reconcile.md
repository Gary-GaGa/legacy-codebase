# Refactor-Audit 補跑 — owner 權威盤點表 vs 我們 inventory（2026-06-16）

> **觸發**：owner 提供最新權威「舊系統 function 盤點表」（durable 存 `docs/legacy/legacy-function-inventory.md`，197 資料列）。本檔＝以該表為 upstream、zero-based 重推總量後對 `feature-inventory.md`／`diff-vs-inventory.md` 的 diff（**只報不改**，循 refactor-audit skill S-final）。
> **信度標註**：本補跑為 **`SOURCE=docs-only`**——產品碼（FE/BE/legacy）不在本 repo，故「碼在/未做」狀態**不由本檔裁定**；本檔只做 owner 表 ↔ 我們 inventory 的**結構對照**＋坐實/推翻假設＋標出需 Codex 碼驗的點。

## 1. 口徑／總量（owner 表權威）
| 類別 | 數 | 說明 |
|---|---|---|
| **distinct 新頁（對應重構系統頁籤；工作單位）** | **67** | i0 11・ISU 22・c0 9・CSU 9・CU0160 1・Z0 15 |
| 舊系統無 → 新頁 | 1 | `EPROZ00670`（TLOD 查詢；舊無源）|
| **批次 B001–B008** | **8** | 系統層工作單位（見 §3 F-OWN-1）|
| 共用 API | 1 | `EPROZZ_0100`（地址欄位選單）|
| 已無使用（明確不遷） | 5 舊func | Property Info 家族（見 §3 F-OWN-2）|
| fragment／群組／SQL 支援（**非**工作單位）| 53 | 頁籤名稱＝「群組/路徑/註解提及」「前端頁籤/片段」「SQL/module 支援」且新頁＝NaN |

> **新系統應有工作單位 ≈ 67 頁 + 1（00670）+ 8 批次 + 1 API ＝ 77**。
> **與我們 166 audit 列的關係**：166 是**action／FE+BE 雙端細粒度**列（殼/common 拆 action）；owner 67 是**頁級**。兩者**不矛盾、是兩個粒度**——owner 表給出**頁級權威 target 清單**，我們 166 是其細粒度展開。**頁級覆蓋對照見 §2。**

## 2. 覆蓋對照（67 頁家族 → 我們 inventory）
| owner 頁家族 | 數 | 我們 inventory 承載 | 結論 |
|---|---|---|---|
| `EPROI00110–00120` | 11 | §1 i0 全模組（audit 22/22 ✅）| ✅ 全覆蓋 |
| `EPROISU0110…0922` | 22 | §1 個金主流程（含 Phase G 0150–0173、撥貸 0920/0921/0922、報表 0180–0184/0181）| ✅ 覆蓋；0922 撥貸核心 🔴（A-1）、報表 0180/0182/0183/0184 屬 R2 track |
| `EPROC00110…00120` | 9 | §1 c0 評分（Phase F 收口）| ✅ 全覆蓋 |
| `EPROCSU0110…0173` | 9 | §1 企金主流程（Phase G 收口）| ✅ 覆蓋 |
| `EPROCU0160` | 1 | 我們併為 `EPROCSU0160` | ⚠️ **不一致**（見 §3 F-OWN-4）|
| `EPROZ00100…00800` | 15 | §1 共用（z0）| ✅ 覆蓋 |
| `EPROZ00670` | 1 | §⑦ R2／AUD-5 已關 | ✅（舊無源、收斂）|
> 頁級覆蓋＝**66/67 對得上**，1 待確認（CU0160）。**惟「碼在 vs 碼在疑未完」需 Codex 碼驗**（本檔 docs-only 不裁）。

## 3. 發現（F-OWN-n；裁定留人/Codex 碼驗）
### 🔴 F-OWN-1 — 批次層 8 個工作單位**完全未被當工作單位追蹤**
owner 表列 8 個批次，**我們 `feature-inventory`／`diff-vs-inventory` 皆無對應狀態列**（grep 全空）；僅 `B005`/`B006` 在撥貸脈絡**側面**出現（B-6 async、A-1 parity 來源），從未問過「新系統的批次等價物做了沒」。
| 批次 | 職責（owner 表）| 關聯 | 新系統狀態 |
|---|---|---|---|
| `EPROZ0_B001` | Branch/Dept profile 匯入→`TB_BRANCH_PROFILE` | B-1 `T24_COMPANY` 接值來源 | ❓ 需 Codex 碼驗 |
| `EPROZ0_B002` | Employee profile 匯入→`TB_EMP_PROFILE` | deputy/權限基礎資料 | ❓ |
| `EPROZ0_B003` | 自動結案/逾期放款→`APP_HISTORY`/`CLO_REASON` | 案件狀態機 | ❓ |
| `EPROZ0_B004` | 暫存報表檔清理（Jasper/temp）| R2 報表 track | ❓ |
| `EPROZ0_B005` | 匯率匯入（呼 `KH_B_FTR37001`）→`TB_EXCHANGE_RATE` | **A-1 換匯同源**（recon 已坐實舊碼）| ❓（A-1 是 authorize 內聯換匯；B005 是排程批次，**兩條路**）|
| `EPROZ0_B006` | 放款/訊息結果檔→更新通知/歷程/結案/狀態 | **撥貸 B-6**（async 架構）| ❓ |
| `EPROZ0_B007` | SFTP 檔案傳送 | **撥貸 T24 下游交付** | ❓ |
| `EPROZ0_B008` | DB/security log 歸檔 | ops | ❓ |
> **影響**：我們的進度 %（166 列/67 頁）**不含批次層**；撥貸「端到端」除了 A-1 stub，**下游 B006/B007 是否有新等價物**也決定能否真的撥出去。**建議**：① inventory 增「批次層」工作單位（8 列）② 派 Codex 唯讀碼驗新系統批次等價物（Spring `@Scheduled`/批次入口？或外部排程？）→ 缺則開卡。

### 🟢 F-OWN-2 — Property Info 家族全 `已無使用` → **AUD-1 可結**
owner 表明確標 `EPROIS_0140`/`EPROIS_0240`/`EPROIU_0140`/`EPROIU_0240`/`EPROCS_0240` **全＝已無使用**。我們：`CS_0240` 早已裁不開發 ✅；但 **AUD-1**（`EPROIS_0240`/`EPROIU_0140`/`EPROIU_0240` 未被點名）一直開著。**owner 權威表＝已無使用 ＝ owner 等同裁定不遷** → **建議關 AUD-1**（證據＝owner 盤點表「已無使用」）。

### 🟢 F-OWN-3 — 坐實既有裁定
- `EPROZ00670`＝**舊系統無**（owner 表）→ 獨立坐實 **AUD-5**（已關 06-15，bible-gap recon 同結論）。
- demo `DEMOA0_0100/0110/0200` → 新頁＝NaN（不遷）→ 坐實 **AUD-4**（demo 不遷）。

### 🟡 F-OWN-4 — `EPROCU0160` 對應不一致（需 Codex 碼驗）
owner 表：`EPROCS_0160/0260`（企金有擔 Loan Condition）→ `EPROCSU0160`；但 `EPROCU_0160/0260`（無擔）→ **`EPROCU0160`（自成新頁）**。**其餘所有 cs/cu 對皆併入 CSU**（如 `EPROCU_0110`→`EPROCSU0110`、`EPROCU_0170`→`EPROCSU0170`）——**只有 0160 的 cu 例外**。我們 inventory 併為 `EPROCSU0160`（+0261 popup，G1 補建）。**待 Codex 碼驗**：新系統企金無擔 Loan Condition 是併在 `EPROCSU0160` 還是真有獨立 `EPROCU0160`？（owner 表 typo vs 真分歧）。
> **Codex 碼驗回（2026-06-17）＝UNFOUND（AUD-11 先不關）**：新 source **查無獨立 `EPROCU0160`**——FE pageCode/route/API + BE controller 全指向 `EPROCSU0160`/`epl-*-csu-*`（**傾向 typo/已併、支持我們 inventory**），**但兩點擋住結案**：① checkout **無 `TB_PAGE_MENU` row data** → 無法證「無擔×0160」routing row 實際指向 `EPROCSU0160`（需唯讀 SQL 查菜單表）；② `CsuLoanConditionServiceImpl:597` 讀 `EPROISU0160`，而 CS/CU checkpoint 新表欄位＝`EPROCSU0160` → **不能宣稱 CU 分流完全正確**（疑 ISU0160 誤接，待 RD 判 bug vs 刻意共用）。完整 findings＝`build-tasks/done/aud11-cu0160-page-reverify-findings.md`（50 行，Codex 工作樹**待 push**）。→ §1「66/67」維持 1 待確認（CU0160 仍 UNFOUND）。

### 🟡 F-OWN-5 — AUD-2 佐證
owner 表 `EPROC0_0211`＝「流程中無看到對應的頁籤」、`EPROC0_0213`＝NaN 新頁 → **支持 AUD-2「展期限定 FinEval/Scorecard 無獨立新頁／由 00116–00120 涵蓋」傾向不遷**（仍待信用評分 domain 蓋章）。

## 4. diff 四類（對 `feature-inventory.md`）
- **(a) inventory ✅ 但本表存疑**：`EPROCSU0160`（F-OWN-4，owner 表分出 CU0160）→ Codex 碼驗。
- **(b) inventory 漏列**：**批次 8 列（F-OWN-1）**＝最大漏列；`EPROZZ_0100` 有提及（:131）但非狀態列（輕）。
- **(c) audit 🚫/不遷 但 inventory 仍開**：**AUD-1 Property Info 家族**（F-OWN-2）→ owner 表已無使用、建議關。
- **(d) 狀態矛盾**：無新增（page 家族狀態與我們一致；撥貸 0922 🔴 兩邊一致）。

## 5. 建議回填（人審逐條打勾 → 主流程改；本檔不改 inventory）
1. **關 AUD-1**：pending-register AUD-1 → ✅，證據＝owner 盤點表「Property Info 家族已無使用」。同步 feature-inventory §1/§2A 註記。
2. **新增批次層**：feature-inventory 增 8 批次工作單位（M9/共用節下「批次」子表），狀態先 ❓ → 派 Codex 碼驗後回填。
3. **CU0160 碼驗**：派 Codex 確認 cu Loan Condition 是否獨立頁；結果回填 §1（併 or 分）。
4. **口徑註記**：feature-inventory 全局結論加一句「owner 權威頁級 target＝67 頁+8 批次+00670+API；166 為其細粒度展開」，並把 owner 表列為 upstream 來源之一。
5. AUD-2／AUD-4／AUD-5：本表佐證/坐實，無新動作（AUD-2 仍待 domain）。

## 6. 待 Codex 碼驗派工（docs-only 升級為碼驗）
- **批次等價物**（最重要）：新系統有沒有 B001–B008 的等價物？（Spring `@Scheduled`/batch 入口 grep；尤其 B005 匯率排程、B006 放款結果檔、B007 SFTP）→ 逐個 found/UNFOUND + `file:line`。
- **CU0160**：新系統企金無擔 Loan Condition 頁/endpoint 對應（**派工卡＝`build-tasks/aud11-cu0160-page-reverify.md`**＝AUD-11；typo 併入 vs 真分歧）→ ✅ **碼驗回 06-17＝UNFOUND·先不關**（無獨立 CU0160→傾向已併；殘 `TB_PAGE_MENU` data + `:597` ISU0160 分流存疑，見 §3 F-OWN-4）。
- （其餘 67 頁的「碼在 vs 疑未完」沿用既有 audit；本表未推翻任何頁級狀態。）

---
> 維護：人審 §5 逐條裁 → 主流程改 `feature-inventory.md`（含批次層新缺口開卡）+ 本表結論回填後本檔隨 refactor-audit/ 一起歸檔。
