# DB 唯讀存取部署範本（agent 用；新舊兩庫皆 Oracle）

> **本檔＝範本，repo 永不放真實帳密**（CLAUDE.md §7）。政策＝`decisions.md` §三（2026-06-12）：agent 唯讀（新舊各一）、DML/DDL 一律產 SQL 人審、MCP 暫不導入。
> **06-12 修訂×2**：開發機鎖 PATH/環境變數權限 → 絕對路徑 wrapper（不依賴 PATH/setx）；**agent 自查為預設模式**（人工跑查詢僅為備援）。

## Agent 自查（預設）：絕對路徑 wrapper（免 PATH/env var/admin）
1. 建立資料夾（可寫、**在兩個 repo 之外**、**永不進 git**）：
   ```
   C:\work\epro-db\
   ├── client\    ← sqlplus.exe 必須與 Instant Client 全部 DLL 同層（單獨複製 exe 跑不動）；
   │               機器上已有 Oracle 安裝者，改讓 wrapper 直接指向原安裝路徑、勿複製 exe
   ├── new.cmd
   ├── old.cmd
   └── sql\       ← 查詢檔（rp6.sql、precision.sql…）
   ```
2. wrapper（帳密直接寫在檔內）：
   ```bat
   @echo off
   rem === new.cmd — 新庫唯讀（本檔含帳密，絕不進 git）===
   set NLS_LANG=TRADITIONAL CHINESE_TAIWAN.AL32UTF8
   "C:\work\epro-db\client\sqlplus.exe" -S "epro_ro/<pass>@//<host>:1521/<新庫svc>" %*
   ```
   `old.cmd` 同形（舊庫帳號/密碼/service）。用法：`old.cmd @C:\work\epro-db\sql\rp6.sql` 或互動。
   - **NLS_LANG 必設**——RP6 等查詢回中文，不設會亂碼。
   - ⚠️ 密碼含 `@`/`"`/`%` 等特殊字元 → 換密碼或改 Oracle Wallet（`/@tns_alias`），別跟 cmd 轉義搏鬥。
   - 用 SQLcl 代替：把 exe 路徑換成 `<SQLDeveloper>\sqlcl\bin\sql.exe`（語法相同，純 Java、吃既有 JDK 17）。
3. agent 以**完整路徑**呼叫：`C:\work\epro-db\old.cmd`——不需改 PATH、不需環境變數。
4. Codex `.codex/config.toml`：對 `C:\work\epro-db\*` 設 **ask**；`sqlplus`/`sql` 直呼不核准（帳密只存在 wrapper 檔，prompt/紀錄永遠不含）。agent 鐵則：SELECT only，DML/DDL 一律產 `.sql` 交人審。

## 部署驗收（第二級啟用時）
1. `C:\work\epro-db\new.cmd` 跑 `SELECT 1 FROM DUAL;` → 通。
2. `old.cmd` 跑 RP6 取數：先 `SELECT table_name FROM all_tables WHERE table_name LIKE '%COMMON_FIELD%';` 確認表名（可能帶 `EPRO_` 前綴），再 `SELECT * FROM <表名> WHERE SYSTEM='EPRO' AND FIELD_NAME='REVISED_ITEM';`。
