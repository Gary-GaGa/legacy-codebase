# Tech-debt Sweep ③ — Logback 硬編碼路徑外部化

> 載具：Codex（後端）。**性質**：設定外部化；**DB-無關**、最小最安全（建議當收尾快手）。
> **落地**：master-direct；**單一 commit、build 綠、報 diff 等審**。
> **病根**：log 路徑硬編碼 `D:\temp\...`（Windows 絕對路徑）→ 換機/上線/非 Windows 即壞。

## 步驟
1. **唯讀掃描**：找所有硬編碼絕對 log 路徑——`logback-spring.xml`/`logback.xml`（`<file>`、`<fileNamePattern>`）優先，順帶掃 code/properties 內 `D:\\temp`、`D:/temp` 或其他寫死絕對路徑。產出清單（file:line）。
2. **外部化**：改為可注入的屬性 + **合理預設**（依專案慣例擇一）：
   - Spring property，如 `${LOG_PATH:-logs}` / `${log.path}`（logback `<property>` 或 `springProperty`），預設用**相對路徑**（如 `logs/` 或 `${user.home}`-相對），**勿留 Windows 絕對路徑當預設**。
   - 對齊既有設定風格（看 `application.yml`/`.properties` 怎麼注入）。
3. 確認**輸出行為不變**（檔名 pattern、rolling policy 不動，只改 base 路徑來源）。

## ⚠️ 注意
- **保留可用預設**：沒設環境變數時也要能起得來、log 寫得出去（別只留 `${LOG_PATH}` 沒預設）。
- 只改路徑來源，**不動** appender 種類 / pattern / level / rolling 設定。
- 若同時有測試用 log path（如 `-Dlogging…path`）→ 確認不衝突（測試指令已在 `SETUP-codex.md` 用 `build/test-logs`）。

## 鐵則
1. 只外部化路徑、不改 logging 行為。
2. 有預設、跨平台可起。
3. build 綠；**單一 commit**（標 sweep③ + 改的設定檔）；報 diff。

## 回報
- 硬編碼路徑清單（file:line）+ 改後的注入方式 + 預設值；
- 確認預設可起、輸出行為不變；
- build 結果；`git status --short`（應乾淨）。

> 過了 → ⑨ tech-debt 的三項靜態 sweep 收齊。剩餘主線即卡 DB / 卡決策（A-1 OQ、00800 側效、Phase V）。
