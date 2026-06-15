唯讀坐實（不改碼）：本機新版 AO 70201 登入後 TODO List 空，但 OVSLXLON02.TB_LON_SUMMARY_INFO 裡 70201（CURRENT_USER_ID/AO_CODE/AO_ASSISTANT_CODE 任一）有 194 筆，CASE_PROGRESS 分佈：01=86、R0397=59、D1=23、C1=15、27=7、08=4。

查 TODO List（EPROZ00100）後端查詢鏈：
1. 新碼 as-is：TODO query endpoint→controller→service→repository 的實際 SQL/JPA——SELECT 哪表、用哪個欄位匹配登入者、WHERE 限定哪些 CASE_PROGRESS 集合、有無 branch/role 額外條件。附 file:line。
2. 對照上面 70201 狀態分佈：這 194 筆依查詢條件「該不該出現在 TODO」逐值比對。
3. 舊系統對照（legacy-epro 唯讀）：舊 EPROZ0_0100 TODO 查詢用哪些狀態/user 條件，與新碼差在哪。
4. R0397：CASE_PROGRESS 正常 2 字元，此值異常——查它是合法狀態碼還是髒資料/別欄位混入。

findings 寫 docs/build-tasks/00100-todo-empty-recon-findings.md（新檔）。結論一句：TODO 空＝✅ 正常（這些狀態本就不入 TODO）or 🔴 查詢 bug（該顯示卻沒）。唯讀、file:line 必附。