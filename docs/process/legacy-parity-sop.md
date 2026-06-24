# Legacy Parity SOP — 舊系統為主 + 差異三判（重構期 divergence 處理準則）

> **狀態**：standing SOP，owner 立 2026-06-17。**重構期遇「新≠舊」一律照本準則處置。**
> **怎麼來的**：owner 與團隊比對「已完成項」發現落差，成因＝①畫面/模組縮編②以舊為基礎+調整（如 T24）③新 DB 變動。owner 定調「**直接以舊系統為主，遇 DB 不同先按頁登記、再判調整需求、再確定樣板**」；本 SOP ＝該方針 + 本 repo 既有教訓的防呆。
> **單一出處**：方針權威＝本檔；個案裁定＝`decisions.md`（append-only）；待決登記＝`pending-register.md`/`escalations`；頁狀態＝`feature-inventory.md`。
> **多來源裁準延伸**：本 SOP 聚焦「舊系統 vs 新」三判；**多來源（PRD+舊系統+db-diff+refactor-spec）合成 SRS 的來源優先序＋DB-resolvable fact 規則＋refactor 層域規則＝`docs/spec-architecture.md §5b`**（本梯為三判的「來源版細化」、非平行制度——遇多源衝突先看 §5b）。
> **結案即歸檔（standing）**：一束 saga 決策全結案（剩執行/UAT）後，把已結案決策列 verbatim 凍結到 `archive/decisions-YYYYHn-<topic>.md`、`decisions.md` 留一列 🗄 指標——免流水帳無限長吃 context（凍結＝搬遷非改寫；細則見 `decisions.md` header）。

## 0. 核心防呆（讀這段就好）
**以舊系統為主，但「舊系統 ≠ 絕對正確」**——每個差異**必分三類**，預設「照舊」只適用第 (a) 類。
不分類就無腦照舊 ＝ 會把**刻意的演進/縮編改回去**＝反向 regression（本 repo 已踩過：A-5/KHR 舊「通吃」、新刻意收窄；`archive/decisions-2026H1-disbursement.md` 0921「KHR rounding 等屬刻意在地化演進，不可一律改回舊版」）。

## 1. 差異三判
| 類 | 判據 | 處置 |
|---|---|---|
| **(a) regression** | 新行為與舊不同、且**非刻意**（漏接/誤接/實作 bug）| **照舊修回**（對齊舊系統 file:line 行為）|
| **(b) 刻意演進·縮編** | 新行為刻意改良/收窄，或模組畫面**刻意合併縮編**（如 CS/CU→CSU、多舊頁併一新頁）| **keep 新、別動**；登錄為 intended（見 §4）|
| **(c) DB 結構差** | 新 DB schema 與舊不同 | **code 對齊舊行為值，但 schema 以新為準**（**不回滾 DB**，見 §2）|
> **判據一律「比舊系統對應行為」**（附舊 `file:line`）；推不出＝**停手登記 UNFOUND、不臆測**。(b) 的「刻意」需有依據（owner/規格/縮編表），不能用「新就是對」自我證成。

### 1a. 「疑似 bug」判準 + 「預設修正 vs 升級」分界（2026-06-24 立）
(a) regression 常以「疑似 legacy bug」現身——判別與處置：
- **常見模式**：throw-stub／無條件 return false、setter 寫 null、guard 永假、無條件 skip、寫入無 commit/return、object↔string 比較錯型、欄位取錯來源（如 `BORROWER_RISK_*` 取 `businessRisk`）、比較方向反（end-balance vs cash-equivalent）。
- **快速判別**：① DB 寫入有無 commit/return ② 該分支是否可達 ③ 有無邊界保護 ④ 與 PRD/Bible 意圖是否一致。
- **預設處置**：判為 (a) regression（非刻意）→ **預設修正成正確**（refactor 覆寫、標 `REF-Dn` delta + 新舊 `file:line`）；**除非該錯誤行為被外部依賴**（則保留+標、回灌 PRD）。
- **何時升級（不自決）**：疑似 bug 若**踩高風險面**（authZ/金額/精度/資料刪改/交易一致）→ 命中升級觸發 #3、停交 owner；**純邏輯 bug**（顯示/非金錢計算/流程）→ refactor 可自決修。
- 對應 §9#22（throw-stub 行為驗證漏網）、`spec-architecture §5b` 升級觸發 + Rule 2。

## 2. DB 特例（(c) 類展開）
- **新 DB ＝已部署事實**：`OVSLXLON01/02` 為準；`AUD-6`（財評精度 `(28,2)→(20,2)`、利率 `6→2` 位）已裁「**以新 DB 為準、不還原**」、schema-diff 定「**有 DB→以 DB 為準**」。
- **故「遇 DB 不同」的處置不是把 DB 改回舊**，而是：**先按頁登記哪裡差 → 判該差異是否真影響舊行為的可達成性 → code 對齊舊行為、entity/mapping 接新 schema 形狀**。
  - 範例＝**B-1 `T24_COMPANY`**：舊「死路（讀已移除欄）」其實是新庫欄位實存、盤點漏列 → entity 補映射接值，**不回滾 DB**。
- DB 差異常常是 **(b) 縮編的副產物**（模組合併→表/欄自然不同）→ 記錄時要連「**為何差**」一起判（`AUD-7` 54 表舊有新無＝刻意捨棄 vs 漏建、`AUD-11` CU0160 併入 CSU0160）。

## 3. 比對範圍（risk-tier，別全頁重比）
- 「已完成項回頭全部重 parity」成本極高（`0921` 教訓：**結構在 ≠ 行為對**，migrated service 存在不代表忠實）。
- **risk-tier**：**金錢 / checkpoint / T24 / 授權** 先比；低風險頁等 **UAT 觸發**再比。
- **誰偵測**：比對需 product code + 舊 source + DB（皆在母資料夾）→ **Codex（碼驗）+ DBA（DB）**，浮成 escalation 進 `pending-register`/`escalations`。規劃 repo（remote agent）只持有 register、不做偵測。

## 4. intended 差異要登錄（防 churn）
判為 (b) keep-new 後**必須 durable 登錄**（`decisions.md` append-only + `feature-inventory` 註記），否則**下一輪 audit 又把同一差異當缺陷 flag ＝重工**。已有機制＝AUD ledger / 決策流水帳。

## 5. 「確定樣板」≠ 每頁新造；調整需求要回灌 spec
- 已有 golden template：**`deputy`**（z0 獨立 CRUD）、**twin-mirror**（案件編輯子頁鏡像 isu↔csu）、**c0 自足鏡像 i0**（`§6.1`）。「確定樣板」＝**確認套哪個既有樣板**，非每頁發明。
- 「找出是否有調整需求」若找到的是**業務邊界**（顯示條件/案件類型/下游頁，如 `BP-1~5` 那種 Bible→PRD seam）→ **回灌 PRD/Bible**，否則 spec 又跟 code 漂移（＝00800 砍掉重建的成因）。

## 6. 掛既有 SSOT（不另造機制）
| 步驟 | 落點 |
|---|---|
| 差異按頁登記 | `pending-register`（擋頁）/ `disbursement-*-escalations`、各 escalation（domain）|
| 三判結果/裁定 | `decisions.md`（append-only，個案單一出處）|
| 頁狀態 | `feature-inventory.md`（SSOT）|
| 樣板確認 | `golden-template/` + `page-mapping.md` |
| 業務邊界調整 | 回 PRD/Bible（spec workflow）|

## 7. per-page 流程（checklist）
1. **偵測**（Codex/DBA 帶 source）：新 vs 舊行為/欄位/側效/checkpoint/DB → 列差異 + 雙方 `file:line`。
2. **三判**（§1）：(a) regression / (b) 刻意演進·縮編 / (c) DB 結構差；判據＝舊系統行為。
3. **處置**：(a) 照舊修回（§6.1 既有 `Csu*` 需例外核可）／ (b) keep 新 + 登錄 intended ／ (c) code 對齊舊行為 + 接新 schema。
4. **登錄**：裁定寫 `decisions.md`、狀態回 `feature-inventory`、待決留 `pending-register`、業務邊界回 PRD/Bible。
5. **不確定**＝停手、登記、不臆測（不拿 inventory/page-mapping 當證據——它們是待驗對象）。

> 一句話：**以舊為主是預設、不是教條**；防呆＝每差異分 regression / 刻意演進 / DB 三類，照舊只套 regression，DB 以新為準，intended 要登錄，調整回灌 spec。
