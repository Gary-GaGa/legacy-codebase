# 驗證執行協定 — 分階段、context-bounded、可重複（含舊系統比對）

> 配 [`verification-handoff.md`](verification-handoff.md)（**驗什麼**）。本檔定**怎麼跑**：把每個驗證項做成一個**塞得進 Codex context window** 的獨立任務，可重複 / 可續跑。
> 核心心法：**context window 是拋棄式的，真相存在 doc，不是存在 Codex 記憶。**

## 0. 為什麼一定要分階段
- 舊 EPRO 系統（Java + ~250 JSP + **DB2**）**不在 workspace**；「舊 + 新 + 比對」一次塞不進單一 context window。
- → 一律「**一頁 / 一關注點 = 一個 session**」，結果**寫回 doc**，context 用完即丟、可重跑。**會需要分階段且重複執行——這是正常做法，不是缺點。**

## 1. 七條 context-window 衛生規則（每個任務都遵守）
1. **一次一項**，絕不「驗全部」。
2. **指名檔案**：prompt 明寫「只讀這幾個檔」，**不要**叫它 explore 整個 repo（最大的 context 殺手）。
3. **extract-then-compare**：要比兩個大來源（舊 vs 新）→ 先各自抽成小 spec，再比小 spec（見 §3）。
4. **結果寫回 doc**（`verification-handoff.md` 對應列打勾 + `file:line` 證據），不靠記憶。
5. **idempotent / 可續跑**：任務可重跑、結果一致；session 中途掛了就重跑該項。
6. **任務獨立才並行**（注意耦合：`00119↔00120`、`00116/00117`、scorecard 散在共用 service）；**預設序列**。
7. **唯讀 + 小輸出**：每項只產 PASS / FAIL / UNSURE + 證據，**不吐大段 code**。

## 2. 進度追蹤（跨 session 不丟）
- 每項在 `verification-handoff.md` 對應列標 **☐ 未驗 / ✅ 通過 / ⚠️ 有發現**。
- **每驗一項 commit 一次**（doc 更新）→ 進度 durable，context reset 也接得回（同我們盤 00117/0920 的節奏）。

## 3. 舊系統比對 — 兩步「抽取→比對」（同時解 context 上限 + 解「舊源不在 workspace」）
> **適用對象**：
> - **主要＝撥貸 `0920`**（無新 oracle，舊系統才是基準）。
> - 次要＝2 條 CreditEval escalation（確認整欄覆寫 / CS-only-clear 是否**本來就是舊行為**）。
> - c0/csu 頁**只做業務語意 spot-check、不逐欄硬比**（已對 i0/isu 驗過，且新系統「刻意合併/改動」過 → 逐欄硬比會誤判）。
>
> **前提：舊 source 已就緒（採方案 a，2026-06-05 確認）**——舊 EPRO repo 以**唯讀 sibling** 放母資料夾（`legacy-epro/`），Codex 同時看舊 + 新。
> ⚠️ **鐵則**：① **本機 only，勿 commit/push 到任何 repo**（舊銀行原始碼，外流嚴重）② 放**母資料夾 sibling、不要放進 `backend/`**（否則被 Maven build 拉進、被 git 追蹤）③ 任務**一律唯讀**舊碼。
> ⚠️ 抽取出的 `docs/legacy-extract/*.md` 含舊系統內部（撥貸 SQL/T24/狀態機）→ **本機 only、已 gitignore，不進 GitHub**；只有**比對結論**（PASS/FAIL/UNSURE）進 `verification-handoff`，且不逐字貼敏感 SQL。
>
> **有了舊源後**：**小頁可一個 session 直接比**（讀「舊頁指名檔 + 新 service」對比）；**大頁（如撥貸 `0920`）仍先抽再比**（Step A→B）以控 context。**兩種都仍守：指名檔、一頁一 session。**
>
> **Step A — 抽（context = 只有舊那一頁）**
> 一個 session 只讀舊系統**該頁**的 trx/action/DAO/SQL（**指名檔**），輸出一份**小 spec** 到 `docs/legacy-extract/<page>.md`：步驟 / 表 / 關鍵 SQL / 狀態轉移 / DB2 方言點。**不比對、不碰新碼。**
>
> **Step B — 比（context = 小 spec + 新 service）**
> 另一個 session 讀 Step A 的小 spec + 新 service（**指名檔**），逐項 PASS/FAIL/UNSURE + 證據，寫回 `verification-handoff.md`。
>
> → 兩步都**不載入整個舊系統**，各自塞得下；且都可重跑。大頁（如 D2 T24 組檔 16 表）再把 Step A/B 各自拆更小。

### 3.1 ⚠️ DB2 → Oracle + 欄位整併（撥貸比對前必讀；c0/csu 遇整併也適用）
- **DB2 ↔ Oracle 方言差異 = 預期、不算 discrepancy**：比**業務語意**（WHERE 條件、join 意義、排序意圖、結果集、算出的值、狀態轉移），**不是 SQL 文字**。`FETCH FIRST`/`WITH UR`/`SYSIBM.SYSDUMMY1`/`days()`/型別 ↔ Oracle `ROWNUM`/`DUAL`/日期運算 等改寫**一律不報 bug**（否則整頁假紅）。
- **欄位整併 = 真風險，要先有 mapping**：某些舊表欄位在新系統併表/併欄。**沒有 old↔new 欄位 mapping 就比 →（a）假紅**（以為新少欄、其實併到別處）**（b）漏抓真 bug**（整併時掉欄/錯映關鍵欄：撥貸金額精度、狀態碼合併丟值）。
- → **新增 Step A2（schema mapping）**：就比對範圍觸及的表，對「舊 `EPRO_TB_*.java` VO 欄位 ↔ 新 `db-schema-catalog`/entity 欄位」逐欄對映，標**同名直映 / 改名 / 整併（多舊→一新 或 拆）/ 新增 / 移除 / 型別變更（DB2→Oracle：`CHAR/VARCHAR2`、`DECIMAL/NUMBER`、`DATE/TIMESTAMP`、`CLOB` 等）**。輸出 `docs/legacy-extract/<domain>-schema-map.md`（本機 only），含每表「⚠️ 整併/型別風險」清單（哪些併欄、是否可能掉精度/丟狀態值）。
- **Step B 以此 mapping 對齊欄位**，並明寫上面兩條規則。此 mapping 方法 c0/csu 頁若也遇整併可重用。

## 4. 各群組怎麼切（對 `verification-handoff.md` 五組）
| 組 | 切法 | session 數（約）|
|---|---|---|
| §1 c0 escalation E1/E2 | 各 1 session：讀指定 `CsuCreditEval*:line` + i0 對照；可選對舊系統 spot-check「整欄覆寫/CS-only 是否舊行為」 | 2（+2 可選舊比） |
| §2 撥貸 D1–D7 | **走 §3 三步**：A 抽舊 `0920/0921/0922` → A2 schema mapping（DB2→Oracle/整併）→ B 比新 `DataInput/Summary`；D2（T24 16 表）再拆 | 抽 ~3 + map 1 + 比 ~7 |
| §3 授權列 | **非 Codex 任務**：DB/ops 查 `TB_API_AUTH`/`TB_ROLE_TASK` | 0 |
| §4 export/報表 | dev/uat 跑頁面，非 context 重任務 | 0（人工/整測）|
| §5 契約對齊 | 每頁 1 session：讀 FE service + BE controller DTO（指名），對欄位 | ~7 |

## 5. 一個可貼的範本（Step A 抽舊）
```
（唯讀、只讀我指名的檔、不碰新碼、不比對）抽取舊系統 <page，如 EPROIS_0920/0921/0922> 的行為 spec：
讀這些檔：<列出舊 trx/action/DAO/SQL 檔路徑>。
輸出到 docs/legacy-extract/<page>.md，含：① 每個動作的步驟 ② 讀寫的表/欄位 ③ 關鍵 SQL（標 DB2 專用語法：FETCH FIRST/WITH UR/ROWNUM 等）
④ 狀態轉移（如 CASE_PROGRESS / checkpoint / flag）⑤ 外部整合（T24/SFTP/mail）。只描述舊行為，不評論新碼。
```
Step B 比對範本見 `archive/review-c0-prompt.md` 的結構（換成「小 spec ↔ 新 service」逐項 PASS/FAIL/UNSURE）。

## 6. 會不會「需要分階段重複執行」？— 會，而且是設計如此
- handoff 約 20 項 × 五組 → **約 20 個 bounded session**，序列跑、逐項 commit。
- 舊系統比對再 ×2（抽 + 比）。
- **UNSURE 或來源變更 → 重跑該項即可**（idempotent）。
- 這正是用「**小任務 + doc 持久化**」繞過 context window 上限的標準做法——跟我們盤 `00117`/`0920` 完全同一招，只是換成驗證。
