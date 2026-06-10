# Tech-debt Sweep ② — Oracle native query map-key 大小寫（靜默 null）

> 載具：Codex（後端）。**性質**：靜態掃描 + 修不歧義者；**DB-無關**（純讀碼，不需連 DB）。
> **落地**：master-direct；**單一 commit、build 綠、報 diff 等審**。
> **病根**：Oracle native query 的**未加引號 alias → JDBC 回傳欄位 label 變大寫**；若 Java 以 camelCase/小寫 key 讀該 Map，**取到 null 卻不報錯**（M7 `LOANAMOUNT` 教訓）。這是**靜默資料 bug**，比看起來嚴重。

## 步驟（investigate → classify → fix unambiguous → escalate）
1. **唯讀掃描**：
   - 找所有 `nativeQuery = true` 的 `@Query`（或 `EntityManager.createNativeQuery`）**回傳 Map / List<Map> / Tuple / Object[]** 者。
   - 對每個，看其 **SELECT 的 alias**：未加雙引號的 alias（如 `SUM(x) AS loanAmount`）→ 實際 label = **大寫**（`LOANAMOUNT`）。
   - 找**消費端**怎麼讀 key（`map.get("loanAmount")` / `rs.getXxx("loanAmount")` / mapper）。
   - 產出**疑慮表**：`query 位置 | alias 原文 | 實際 label(推定) | 讀取 key | 是否不符`。
2. **分類**：
   - **(A) 明確不符**（讀 key 大小寫 ≠ 推定 label）→ 修。
   - **(B) 不確定**（label 受 DB/driver 設定影響、或無法純靜態判定）→ **標 UNSURE、回報、不改**（別猜）。
3. **修 (A)**——擇一最小且**合乎現有慣例**的修法，整檔一致：
   - 讀取端 key 對齊實際 label（大寫），或
   - native query alias 加雙引號固定大小寫，或
   - 顯式 result mapping。
   > **同一查詢/同一 mapper 用同一種修法**，勿混搭。

## ⚠️ 注意
- 不要為了「順手」把所有 alias 全加引號 → 只動**真的會靜默 null** 的點（(A)）。
- 無法純靜態確定 label 的（如依賴 DB 端設定）一律 (B) UNSURE，**不猜 PASS**。
- 不改 SQL 語意、不改回傳欄位集合。

## 鐵則
1. investigate-then-fix：(A) 才修、(B) 只報。
2. 不改行為/欄位集；同檔一致修法。
3. build 綠；**單一 commit**（標 sweep② + 修的 query/mapper 清單）；報 diff。

## 回報
- **疑慮表**（(A) 已修 / (B) UNSURE 兩區，各附 file:line + alias↔key 證據）；
- (A) 修法說明（對齊 key / 引號 / 顯式 mapping，擇一）；
- build 結果；`git status --short`（應乾淨）。

> 過了接 sweep ③（Logback 路徑外部化）。(B) UNSURE 清單留待 DB 可連時實測確認。
