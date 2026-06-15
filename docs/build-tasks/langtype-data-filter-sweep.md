# Build Task — langType 當資料過濾 盤點＋修（Phase V 橫向 sweep；RV-2 起）

> ✅ **盤點完成（2026-06-15，審過，findings `8a06253`）＝5 處**：(a) 純過濾移除×2（`/epl-list-todolist` `VMainBorrowerInfoRepository:46`＝RV-2 首例、`/epl-list-casedistribution` `:104`）、(b) 多語系 join 誤放 outer WHERE→改 join ON+fallback×3（`/epl-list-caseapplication` `TBLonSummaryInfoRepository:75`、`/epl-list-deviation` `:366`、`/epl-list-cancelreport` `:557`）。**下一步＝C 階段批量修**（清單見 `langtype-data-filter-sweep-findings.md`）。

> 載具：Codex（母資料夾，FE+BE+legacy-epro 唯讀對照）。**性質＝橫向 sweep**：先盤點同型、再批量修。
> **背景**：Phase V 本機坐實 TODO（`EPROZ00100`）查詢用 `S.LOAN_TYPE_LANG_TYPE = :langType` 當**資料過濾**（`zh_TW`→`totalCount:0`／`en_US`→`92`），**舊版 initQuery 無此條件＝regression**（`VMainBorrowerInfoRepository:46`；findings `00100-todo-empty-recon-findings.md`）。
> **Owner 裁示（2026-06-15，`decisions.md`）**：①語系僅 `zh_TW`+`en_US` ②**語系切換只影響元件翻譯、不影響查詢資料筆數**＝修向定案。
> **目的**：回答「**這樣調整需要更動多少地方**」——產盤點清單（＝更動範圍）＋分類＋批量修。

## 步驟
### A. 盤點（grep，只報不改）
1. 後端所有 native SQL / `@Query` 含 `LANG_TYPE` / `langType` 出現在 **WHERE 當資料過濾**的 handler——逐處 `file:line`。
2. 每處分類：
   - **(a) 純資料過濾、舊版無對應** → regression，該**移除** langType WHERE 條件。
   - **(b) 多語系 view 去重必要**（view 因 join 多語系名稱表而每案多列）→ 改 **LEFT JOIN 多語系名稱 + langType fallback**（沒該語系退 `en_US`），案件一律出現、不重複。
3. 舊系統對照（legacy-epro 唯讀）：該查詢舊版**有無** langType 過濾（有→`file:line`；舊 named SQL 找不到→標 `UNFOUND` + 用 Java 參數注入推斷）。

### B. 清單（＝「更動多少地方」的答案）
產一張表：`endpoint/頁 ↔ SQL 位置 ↔ langType 角色（過濾/去重）↔ 舊版有無 ↔ 修法（移除/fallback）`。findings 寫本資料夾新檔 `langtype-data-filter-sweep-findings.md`。**先報清單給人審，不批量改。**

### C. 修（清單審過後）
- TODO（RV-2）為**首例**：langType 退出資料 WHERE；多語系 view 用 LEFT JOIN+fallback。修後本機驗 `zh_TW` 與 `en_US` 回**相同筆數**（92）。
- 其餘同型頁依清單分類批量修。
- Owner 語系範圍裁示：若有 `zh_CN`／其他語系的殘留處理，**標出**、可一併收斂到僅 `zh_TW`+`en_US`，但大改先報不擅動。

## 鐵則
1. **先盤點報清單、不亂改**；修向依「langType 只影響呈現、不影響資料」（Owner 定案）。
2. 多語系 view **不可無腦拿掉** langType（會案件重複）→ LEFT JOIN+fallback。
3. 每修一處 `mvn`／`ng build` 綠；FE 翻譯切換功能不破壞（切語系只換字、筆數不變）。
4. 舊系統對照附 `file:line`；找不到 named SQL 文字則標 `UNFOUND` + 參數注入推斷。

## 回報
- 盤點清單（= 更動地方數）＋分類；舊版對照結論；修了哪些（commit hash）；build 結果；本機 `zh_TW`/`en_US` 筆數一致驗證。

> 過了：TODO + 同型頁 langType regression 收；回填 handoff RV-2 + 各頁 `feature-inventory.md` ✅；Owner 語系裁示落地。
