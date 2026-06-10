# Tech-debt Sweep ① — FE/BE HTTP method 不一致（系統性）

> 載具：Codex（前後端母資料夾）。**性質**：靜態掃描 + 修不歧義者；**DB-無關**。
> **落地**：master-direct；**單一 commit、前後端 build 綠、報 diff 等審**。
> **病根**：FE service 呼叫的 HTTP method ≠ BE `@XxxMapping` 宣告 → 同一 `epl-*` 兩邊各說各話（00800 D2、00600 已知）。**原則：mutate=POST、pure-read=GET，且 FE/BE 必須一致**（契約單一真相）。

## 步驟（investigate → classify → fix unambiguous → escalate）
1. **唯讀掃描**：
   - BE：列出所有 `epl-*` endpoint 的宣告 method（`@GetMapping`/`@PostMapping`/`@RequestMapping(method=…)`，controller package 全掃）。
   - FE：列出對應 endpoint 的呼叫 method（`api.service.ts` 的 `apiGetRequest`/`apiPostRequest*` / `http.get|post`）。
   - 交叉比對，產出**不一致表**：`endpoint | BE method | FE method | 行為(read/mutate) | 判定`。
2. **分類每筆**：
   - **(A) 不歧義可修**：會刪改資料的操作（insert/save/update/delete/calc-with-writes）卻是 GET → **改 BE 為 POST + FE 對齊**；純讀卻 method 不一致但語意明確 → 對齊到正確側。
   - **(B) 歧義/需裁定**：read-or-mutate 不明、或屬已標 `@PENDING` 者 → **只回報、不改**。
3. **只修 (A)**，逐筆對齊（BE method + FE 呼叫同步改）。

## ⚠️ 不准碰
- **`epl-case-query-reviseditem`（00800 init-query）**：SRS 標 `@PENDING(method)`（GET vs RPC-POST，RD 未定）→ **列 (B) 回報、不改**。
- `epl-case-insert-reviseditem`（00800 execute）**已修為 POST**（`88328f9`）→ 應已一致，掃描確認即可。
- 任何改 method 會連動授權列/閘道設定者 → 標出、別只改一半。

## 鐵則
1. **FE 與 BE 同一筆一起改**，不得只改單側（否則製造新的不一致）。
2. 不改行為、只改 method 對齊；不順手重構。
3. 前後端 build 綠；**單一 commit**（標 sweep① + 修的 endpoint 清單）；報 diff。

## 回報
- **完整不一致表**（含 (A) 已修 / (B) 待裁定兩區）；
- (A) 實際對齊的 endpoint 清單（BE+FE 各一處）；
- (B) 待人裁定清單（含 00800 init-query）；
- 前後端 build 結果；`git status --short`（應乾淨）。

> 過了接 sweep ②（map-key 大小寫）。(B) 待裁定清單我看過後再決定怎麼處理。
