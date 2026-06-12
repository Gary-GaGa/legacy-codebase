# DB 唯讀存取部署範本（agent 用；新舊兩庫皆 Oracle）

> **本檔＝範本，repo 永不放真實帳密**（CLAUDE.md §7）。政策＝`decisions.md` §三（2026-06-12）：agent 唯讀（新舊各一）、DML/DDL 一律產 SQL 人審、MCP 暫不導入。
> **06-12 修訂**：開發機鎖 PATH/環境變數權限 → 改「人工優先＋絕對路徑 wrapper」兩級制，**不依賴 PATH/setx**。

## 第一級（現行預設）：人工跑查詢、結果貼給 agent
零設定。當前查詢量小（RP6 取數、精度 DDL、表名確認），由人用 SQL Developer/sqlplus 執行，結果貼回對話/findings 檔。**agent 不直連 DB。**

## 第二級（Phase V agent 自查時啟用）：絕對路徑 wrapper（免 PATH/env var/admin）
0. **client 免安裝三選一**（wrapper 內用絕對路徑指向，不碰系統設定）：
   - (a) 已裝 SQL Developer → 內附 SQLcl：`<SQLDeveloper>\sqlcl\bin\sql.exe`（語法同 sqlplus）。
   - (b) SQLcl standalone：zip 解壓即用（純 Java，吃既有 JDK 17）。
   - (c) Instant Client Basic + SQL*Plus package：兩 zip 解壓同資料夾即用。
1. 任選一個**可寫、且在兩個 repo 之外**的資料夾，如 `C:\work\epro-db\`。
2. 放兩個 wrapper（帳密直接寫在檔內；**此資料夾永不進 git**）：
   ```bat
   @echo off
   rem === new.cmd — 新庫唯讀（本檔含帳密，絕不進 git）===
   "C:\Program Files\sqldeveloper\sqlcl\bin\sql.exe" -S "epro_ro/<pass>@//<host>:1521/<新庫svc>" %*
   ```
   `old.cmd` 同形（舊庫帳號/密碼/service）。用法：`old.cmd @C:\work\sql\rp6.sql` 或互動。
   ⚠️ 密碼含 `@`/`"`/`%` 等特殊字元 → 換密碼或改 Oracle Wallet（`/@tns_alias`），別跟 cmd 轉義搏鬥。
3. agent 以**完整路徑**呼叫：`C:\work\epro-db\old.cmd`——不需改 PATH、不需環境變數。
4. Codex `.codex/config.toml`：對 `C:\work\epro-db\*` 設 **ask**；`sqlplus`/`sql` 直呼不核准（帳密只存在 wrapper 檔，prompt/紀錄永遠不含）。

## 部署驗收（第二級啟用時）
1. `C:\work\epro-db\new.cmd` 跑 `SELECT 1 FROM DUAL;` → 通。
2. `old.cmd` 跑 RP6 取數：先 `SELECT table_name FROM all_tables WHERE table_name LIKE '%COMMON_FIELD%';` 確認表名（可能帶 `EPRO_` 前綴），再 `SELECT * FROM <表名> WHERE SYSTEM='EPRO' AND FIELD_NAME='REVISED_ITEM';`。
